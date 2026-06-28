## Introduction

Azure DevOps pipelines need build agents to execute CI/CD jobs. Microsoft-hosted agents are the default option, and they work well for many teams. However, they can be limiting when you need custom tooling, access to private networks, specialized dependencies, or tighter control over the build environment. Azure Pipelines also assigns jobs to agents one job at a time, so scaling the number of available agents matters when multiple builds are queued. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops))

A common alternative is to use self-hosted agents. In this model, you manage the machine or runtime that runs the Azure Pipelines agent software. Traditionally, that means keeping one or more virtual machines online all the time, even when no pipeline jobs are running. That approach works, but it can waste compute resources and increase maintenance overhead. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops))

A more efficient pattern is to run the Azure Pipelines agent inside a container and execute it as an **event-driven Azure Container Apps job**. In this setup, the platform starts agent containers only when pipeline work is queued, and stops them when the work is done. Azure Container Apps jobs are designed for workloads that start, run for a finite duration, and then stop, which matches self-hosted CI/CD agents well. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs))

This tutorial shows how to build scalable Azure DevOps build infrastructure with these components:

- Azure DevOps self-hosted build agents
- Docker containers for packaging the agent environment
- Azure Container Apps Jobs for running agents on demand
- Event-driven scaling based on Azure Pipelines queue activity

Azure Container Apps uses KEDA-based scaling under the platform, but in this architecture you are **not** operating your own Kubernetes cluster or managing KEDA directly. You define the job and its scale behavior, and Azure Container Apps handles the runtime and event-driven execution model. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/scale-app))

## Important limitation

Before you implement this pattern, be aware of one major constraint: **Container Apps jobs do not support running Docker inside the container**. That means any pipeline step that depends on Docker commands such as `docker build`, `docker run`, or similar nested-container behavior will fail on this type of agent. Azure Pipelines also documents that nested containers are not supported when the agent itself is already running inside a container. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs))

If your pipelines need Docker-in-Docker, privileged containers, or host-level Docker access, this design is not the right fit. In those cases, use another self-hosted agent model such as virtual machines or another runtime that can provide Docker on the host. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs))

## Concept Overview

### Azure DevOps self-hosted build agents

An Azure DevOps build agent is a worker process that executes pipeline tasks. Agents connect to Azure DevOps through an agent pool and wait for work. When a pipeline run needs a self-hosted agent, Azure DevOps selects an available agent in the target pool and assigns the job to it. Each agent handles one job at a time. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops))

Self-hosted agents are useful when you need:

- custom tools or SDKs
- access to internal services or private networks
- control over the operating environment
- predictable build dependencies

This is the main reason teams move away from Microsoft-hosted agents for specialized workloads. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops))

### Why run the agent in a container

Running the Azure Pipelines agent in a container makes the build environment reproducible. Instead of configuring a VM by hand, you define the agent image once and reuse it everywhere. Azure DevOps provides official guidance for running self-hosted agents in Docker, including Linux-based agent containers for orchestrated environments. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops))

This gives you a few practical benefits:

- the agent environment is versioned in a Dockerfile
- new agents start from a known-good image
- tool installation becomes part of the image build
- replacing agents is easier because the runtime is disposable

In other words, the container becomes the build environment. If your pipelines need specific CLIs, language runtimes, or internal certificates, you add them to the image instead of maintaining long-lived machines. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops))

### How event-driven scaling works in Azure Container Apps

This implementation is based on **Azure Container Apps Jobs**, not a Kubernetes deployment you manage yourself. In Azure Container Apps, a job is meant for work that starts, runs for a finite duration, and then exits. Jobs can be triggered manually, on a schedule, or by events. Microsoft specifically documents self-hosted Azure Pipelines agents as a valid use case for the **event-driven job** model. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/jobs))

The scaling flow looks like this:

1. A pipeline is triggered in Azure DevOps.
2. The job enters the selected self-hosted agent pool.
3. The event-driven job detects queued work for that pool.
4. Azure Container Apps starts one or more job executions.
5. Each execution runs a containerized Azure Pipelines agent.
6. After the work completes and the queue drains, executions stop.

Azure Container Apps handles the event-driven execution model, and the platform uses KEDA-backed scale rules to decide when to start or stop executions. That means you still get queue-based autoscaling behavior, but without managing AKS, Kubernetes manifests, or a standalone KEDA installation yourself. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/jobs))

## Prerequisites

Before starting deployment, make sure you have:

- an Azure subscription
- an Azure DevOps organization and project
- an Azure DevOps agent pool, or permission to create one
- a Personal Access Token (PAT) with **Agent Pools (Read & manage)** scope
- Azure CLI installed and authenticated with `az login`
- access to deploy resources into a resource group
- a container image for the agent, if you plan to use a custom image

Azure CLI supports ARM template deployment with `az deployment group create`, and Container Apps job management is available through the `az containerapp job` command group. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-cli))

Azure resources should be deployed into a resource group. You can create a new one or reuse an existing one.

## Practical Part

### PAT creation

This deployment uses an Azure DevOps PAT for two purposes:

- registering the self-hosted agent in the target agent pool
- allowing the queue-driven scaling logic to authenticate against Azure DevOps

For agent registration, Microsoft documents that the PAT scope should be **Agent Pools (Read & manage)**. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/personal-access-token-agent-registration?view=azure-devops))

Create the PAT in Azure DevOps:

1. Go to **User settings** -> **Personal access tokens**.
2. Generate a new token.
3. Select **Agent Pools (Read & manage)**.
4. Save the token value securely for deployment.

A single PAT can be reused to register multiple agents, and Azure DevOps states that the PAT is used during agent registration rather than for ongoing agent communication after registration. In an ephemeral container-based design, that registration step may happen repeatedly as fresh agents start. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/personal-access-token-agent-registration?view=azure-devops))

### Build and publish a custom agent image

You can use a prebuilt agent image, or you can build your own image if your pipelines require extra tools.

Use a custom image if your pipelines need things like:

- Azure CLI
- Terraform
- language SDKs
- internal certificates
- organization-specific build tools

Azure DevOps supports running self-hosted agents inside Docker containers, and customizing the image is the standard way to add required tools to the environment. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops))

Example:

```bash
docker build -t <REGISTRY>/<IMAGE>:<TAG> .
docker push <REGISTRY>/<IMAGE>:<TAG>
```

Remember that the image defines the tools available to the pipeline job. If a required command is not installed in the image, the build will fail when the pipeline tries to use it. Also remember the earlier limitation: this image can run the Azure Pipelines agent, but pipelines running inside this model still cannot execute Docker commands inside the containerized agent job. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops))

### Deploy ARM template

This solution deploys the required Azure resources with an ARM template. In this architecture, the template should create the Azure Container Apps environment and the event-driven Container Apps job that runs the Azure Pipelines agent container. Azure supports ARM-based deployment at resource-group scope through `az deployment group create`. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-cli))

Deploy from Azure CLI:

```bash
az deployment group create \
  --resource-group <RESOURCE_GROUP> \
  --template-file arm.json \
  --parameters \
    azpUrl=https://dev.azure.com/<AZDO_ORG> \
    azpPool=<AZDO_POOL_NAME> \
    azpToken=<AZDO_PAT> \
    containerImage=<REGISTRY/IMAGE:TAG>
```

Optional scaling parameters:

```bash
targetPipelinesQueueLength=1 \
minExecutions=0 \
maxExecutions=5 \
parallelism=1
```

The deployment command format above is valid Azure CLI syntax for resource-group ARM deployments. The specific parameter names shown here are the values expected by your template. ([learn.microsoft.com](https://learn.microsoft.com/en-us/cli/azure/deployment/group?view=azure-cli-latest))

### Result and validation

After deployment, you should have an Azure Container Apps Job and an Azure Container Apps environment. Container Apps jobs are the correct resource type here because the agent should start on demand, process work, and then stop when finished. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/jobs))

List the deployed jobs:

```bash
az containerapp job list \
  --resource-group <RESOURCE_GROUP> \
  --query "[].name" -o tsv
```

Inspect the deployed job:

```bash
az containerapp job show \
  --resource-group <RESOURCE_GROUP> \
  --name <JOB_NAME>
```

The `az containerapp job` command group supports listing jobs, viewing executions, and inspecting logs for Container Apps jobs. ([learn.microsoft.com](https://learn.microsoft.com/en-us/cli/azure/containerapp/job?view=azure-cli-latest))

To test autoscaling behavior:

1. Queue a pipeline that targets the selected agent pool.
2. Observe job executions:

```bash
az containerapp job execution list \
  --resource-group <RESOURCE_GROUP> \
  --name <JOB_NAME> \
  --output table
```

3. Confirm that executions appear while the queue has work.
4. Confirm that executions stop appearing when the queue becomes empty.

Azure CLI provides `az containerapp job execution list` and `az containerapp job execution show` specifically for inspecting Container Apps job executions. ([learn.microsoft.com](https://learn.microsoft.com/en-us/cli/azure/containerapp/job/execution?view=azure-cli-latest))

If the setup is working correctly, the expected behavior is:

- a pipeline run enters the target agent pool
- Azure Container Apps starts one or more job executions
- each execution registers a temporary self-hosted agent
- the pipeline runs on that agent
- the execution ends after the work is finished

That execution model aligns with how Azure Container Apps jobs are designed to work: finite, event-triggered runs rather than always-on services. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/jobs))

## Summary

Self-hosted Azure DevOps agents give you full control over the build environment, but long-lived VM-based agents can waste resources when the queue is idle. Running the agent in a container makes the environment portable and reproducible, and running that container as an **event-driven Azure Container Apps job** lets agents start only when work exists and stop when the work is done. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops))

This is the key architectural point: the implementation is centered on **Azure Container Apps Jobs**, with Azure handling the event-driven execution model for you. KEDA-style queue-based scaling is part of the platform behavior, but you are not building or operating a generic Kubernetes cluster yourself. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/scale-app))

The main tradeoff is also straightforward: this design is efficient for ephemeral self-hosted agents, but it is **not** suitable for pipelines that need Docker commands inside the running agent container. If your workload fits within that boundary, this is a clean way to build autoscaled self-hosted Azure Pipelines agents without keeping VMs online all the time. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs))

If you want, I can next apply **changes 3, 4, and 5** as well and give you another full revised version.
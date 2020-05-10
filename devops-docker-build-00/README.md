# Running a self-hosted build agent on Azure Container Instance
## Introduction

Containers are becoming the preferred way to package, deploy, and manage cloud applications. Azure Container Instances offers the fastest and simplest way to run a container in Azure, without having to manage any virtual machines and without having to adopt a higher-level service.

To build your code or deploy your software using Azure DevOps Pipelines, you need a build agent. Using containers as a build agents, maintenance and upgrades are taken care of for you.

![](/images/devops-docker/devops_docker_logo.png)

This document gives an **example of using Azure Container Instance as Azure DevOps pipelines build agent**. To do so you'll need build a custom Docker image and use it to create Container Instance in Azure Cloud.

## Theoretical Part

### Azure Pipelines

To build your code or deploy your software using Azure Pipelines, you need at least one agent. As you add more code and people, you'll eventually need more.

When your pipeline runs, the system begins one or more jobs. An agent is installable software that runs one job at a time.

Jobs can be run directly on the host machine of the agent or in a container.

![](/images/devops-docker/agent_structure.png)

#### Microsoft-hosted agents
If your pipelines are in Azure Pipelines, then you've got a convenient option to run your jobs using a Microsoft-hosted agent. With Microsoft-hosted agents, maintenance and upgrades are taken care of for you. Each time you run a pipeline, you get a fresh virtual machine. The virtual machine is discarded after one use. Microsoft-hosted agents can run jobs directly on the VM or in a container.

For many teams this is the simplest way to run your jobs. You can try it first and see if it works for your build or deployment. If not, you can use a self-hosted agent.

#### Self-hosted agents
An agent that you set up and manage on your own to run jobs is a self-hosted agent. You can use self-hosted agents in Azure Pipelines or Team Foundation Server (TFS). Self-hosted agents give you more control to install dependent software needed for your builds and deployments. Also, machine-level caches and configuration persist from run to run, which can boost speed.

You can install the agent on macOS, Linux (x64, ARM, RHEL6), Windows (x64, x86) and Docker. After you've installed the agent on a machine, you can install any other software on that machine as required by your jobs.

#### Parallel jobs
You can use a parallel job in Azure Pipelines to run a single job at a time in your organization. In Azure Pipelines, you can run parallel jobs on Microsoft-hosted infrastructure or on your own (self-hosted) infrastructure.

Microsoft provides a free tier of service by default in every organization that includes at least one parallel job. Depending on the number of concurrent pipelines you need to run, you might need more parallel jobs to use multiple Microsoft-hosted or self-hosted agents at the same time. For more information on parallel jobs and different free tiers of service, see Parallel jobs in Azure Pipelines.

#### Capabilities

Every self-hosted agent has a set of capabilities that indicate what it can do. Capabilities are name-value pairs that are either automatically discovered by the agent software, in which case they are called system capabilities, or those that you define, in which case they are called user capabilities.

The agent software automatically determines various system capabilities such as the name of the machine, type of operating system, and versions of certain software installed on the machine. Also, environment variables defined in the machine automatically appear in the list of system capabilities.

When you author a pipeline you specify certain demands of the agent. The system sends the job only to agents that have capabilities matching the demands specified in the pipeline. As a result, agent capabilities allow you to direct jobs to specific agents.

Demands and capabilities apply only to self-hosted agents. When using Microsoft-hosted agents, you select an image for the hosted agent. You cannot use capabilities with hosted agents.

#### Authentication
To register an agent, you need to be a member of the administrator role in the agent pool. The identity of agent pool administrator is needed only at the time of registration and is not persisted on the agent, and is not used in any subsequent communication between the agent and Azure Pipelines or TFS. In addition, you must be a local administrator on the server in order to configure the agent.

Your agent can authenticate to Azure Pipelines using Personal Access Token. Personal access tokens (PATs) are alternate passwords that you can use to authenticate into Azure DevOps. 

#### Interactive vs. service
You can run your self-hosted agent as either a service or an interactive process. After you've configured the agent, we recommend you first try it in interactive mode to make sure it works. Then, for production use, we recommend you run the agent in one of the following modes so that it reliably remains in a running state. These modes also ensure that the agent starts automatically if the machine is restarted.

* As a service. You can leverage the service manager of the operating system to manage the lifecycle of the agent. In addition, the experience for auto-upgrading the agent is better when it is run as a service.

* As an interactive process with auto-logon enabled. In some cases, you might need to run the agent interactively for production use - such as to run UI tests. When the agent is configured to run in this mode, the screen saver is also disabled. Some domain policies may prevent you from enabling auto-logon or disabling the screen saver. In such cases, you may need to seek an exemption from the domain policy, or run the agent on a workgroup computer where the domain policies do not apply.

#### Agent account

Whether you run an agent as a service or interactively, you can choose which computer account you use to run the agent. (Note that this is different from the credentials that you use when you register the agent with Azure Pipelines or TFS.) The choice of agent account depends solely on the needs of the tasks running in your build and deployment jobs.

For example, to run tasks that use Windows authentication to access an external service, you must run the agent using an account that has access to that service. However, if you are running UI tests such as Selenium or Coded UI tests that require a browser, the browser is launched in the context of the agent account.

On Windows, you should consider using a service account such as Network Service or Local Service. These accounts have restricted permissions and their passwords don't expire, meaning the agent requires less management over time.

#### Agent version and upgrades

We update the agent software every few weeks in Azure Pipelines. We indicate the agent version in the format {major}.{minor}. For instance, if the agent version is 2.1, then the major version is 2 and the minor version is 1.

Microsoft-hosted agents are always kept up-to-date. If the newer version of the agent is only different in minor version, self-hosted agents can usually be updated automatically (configure this setting in Agent pools, select your agent, Settings - the default is enabled) by Azure Pipelines. An upgrade is requested when a platform feature or one of the tasks used in the pipeline requires a newer version of the agent.

If you run a self-hosted agent interactively, or if there is a newer major version of the agent available, then you may have to manually upgrade the agents. You can do this easily from the Agent pools tab under your organization. Your pipelines won't run until they can target a compatible agent.

#### Agent pools

Instead of managing each agent individually, you organize agents into agent pools. In Azure Pipelines, pools are scoped to the entire organization; so you can share the agent machines across projects. In Azure DevOps Server, agent pools are scoped to the entire server; so you can share the agent machines across projects and collections.

When you configure an agent, it is registered with a single pool, and when you create a pipeline, you specify which pool the pipeline uses. When you run the pipeline, it runs on an agent from that pool that meets the demands of the pipeline.

## Azure Container Instances

Azure Container Instances enables a layered approach to orchestration, providing all of the scheduling and management capabilities required to run a single container, while allowing orchestrator platforms to manage multi-container tasks on top of it.

Because the underlying infrastructure for container instances is managed by Azure, an orchestrator platform does not need to concern itself with finding an appropriate host machine on which to run a single container. The elasticity of the cloud ensures that one is always available. Instead, the orchestrator can focus on the tasks that simplify the development of multi-container architectures, including scaling and coordinated upgrades.

### Container group
The top-level resource in Azure Container Instances is the container group. A container group is a collection of containers that get scheduled on the same host machine. The containers in a container group share a lifecycle, resources, local network, and storage volumes

### Resource allocation

Azure Container Instances allocates resources such as CPUs, memory, and optionally GPUs (preview) to a multi-container group by adding the resource requests of the instances in the group. Taking CPU resources as an example, if you create a container group with two container instances, each requesting 1 CPU, then the container group is allocated 2 CPUs.

### Networking
Container groups can share an external-facing IP address, one or more ports on that IP address, and a DNS label with a fully qualified domain name (FQDN). To enable external clients to reach a container within the group, you must expose the port on the IP address and from the container. A container group's IP address and FQDN are released when the container group is deleted.

Within a container group, container instances can reach each other via localhost on any port, even if those ports aren't exposed externally on the group's IP address or from the container.

Optionally deploy container groups into an Azure virtual network to allow containers to communicate securely with other resources in the virtual network.

### Linux and Windows containers

Azure Container Instances can schedule both Windows and Linux containers with the same API. Simply specify the OS type when you create your container groups.

Some features are currently restricted to Linux containers:

* Multiple containers per container group
* Volume mounting (Azure Files, emptyDir, GitRepo, secret)
* Resource usage metrics with Azure Monitor
* Virtual network deployment
* GPU resources (preview)


## Prerequisites

Before you begin the next section, you’ll need:

* Azure DevOps account
* Azure Cloud account
* Docker Hub account

## Practical Part

To run this demo you'll need to:
1. Build Docker image
2. Generate Personal Access Token on Azure DevOps
3. Deploy Azure Container instance

![](/images/devops-docker/docker-devops-agent_github.png)


### Build Docker image
![](/images/devops-docker/configure_docker_build_pipeline.png)

Configured pipeline - https://dev.azure.com/Infrastructure-as-C0de/docker-devops-agent/_build?definitionId=6&_a=summary

Published image - https://hub.docker.com/r/gr00vysky/devops-agent

### Generate PAT

https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page#create-personal-access-tokens-to-authenticate-access

### Deploy Azure Container instance

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fdocker-devops-agent%2Fmaster%2Fazure%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a> 

![](/images/devops-docker/az_container_deployment.png)


## Results

![](/images/devops-docker/docker_agent_result.png)

## Summary



## Related Information

* https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#environment-variables

* https://medium.com/wortell/build-your-own-azure-devops-agents-with-pipelines-95104be095d5

* https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops

* https://docs.microsoft.com/en-us/azure/container-instances/
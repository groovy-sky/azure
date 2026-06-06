# Running a Repository-level GitHub Actions Runner on Azure Container Instances

## Introduction

This tutorial explains how to run a self-hosted GitHub Actions runner on Azure Container Instances (ACI) using the ARM template in this folder.

The deployment model is simple:

- Azure Container Instance runs one container group.
- The container image starts and registers a GitHub runner.
- Authentication is provided through GitHub PAT only.

The included template file is [arm.json](arm.json).

## Why ACI for self-hosted runners

ACI is a good fit when you want a managed container runtime without maintaining VMs or Kubernetes.

Benefits:

- Fast provisioning.
- Pay for allocated CPU and memory.
- Native ARM deployment support.
- Good option for isolated, ephemeral runner workloads.

Trade-offs:

- You still own runner image hardening and lifecycle strategy.
- You must manage token handling and secrets carefully.

## Runner behavior and authentication model

### Repository scope

This guide is repository-only.

Set GITHUB_URL in this format:

- https://github.com/OWNER/REPO

### PAT authentication

This guide uses GITHUB_PAT only.

- GITHUB_PAT is used by the startup logic to request short-lived registration and removal tokens at runtime.
- Keep PAT permissions limited to what is required for repository-level runner management.

### Ephemeral mode

By default the template sets EPHEMERAL=true, so each runner is designed for short-lived job isolation.

Set EPHEMERAL=false only when you explicitly want persistent runner behavior.

## Prerequisites

Before deployment, make sure you have:

- An Azure subscription.
- Azure CLI installed.
- Access to create resources in a resource group.
- A GitHub repository where the runner will register.
- A PAT with appropriate scope for repository runner management.

## Practical walkthrough

### 1. Sign in and select subscription

```sh
az login
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

### 2. Create a resource group

```sh
export RESOURCE_GROUP="rg-gh-runner-demo"
export LOCATION="eastus"

az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}"
```

### 3. Prepare deployment variables

Repository scope variables:

```sh
export GITHUB_URL="https://github.com/OWNER/REPO"
export CONTAINER_NAME="gh-runner-app"
```

Optional runtime settings:

```sh
export RUNNER_LABELS="self-hosted,linux,x64,docker"
export RUNNER_WORKDIR="_work"
export EPHEMERAL="true"
export DISABLE_AUTO_UPDATE="true"
```

### 4. Deploy to ACI using ARM template

Deploy with GITHUB_PAT:

```sh
export GITHUB_PAT="<PAT_WITH_REQUIRED_SCOPE>"

az deployment group create \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file arm.json \
  --parameters \
      location="${LOCATION}" \
      containerName="${CONTAINER_NAME}" \
      GITHUB_URL="${GITHUB_URL}" \
      GITHUB_PAT="${GITHUB_PAT}" \
      RUNNER_LABELS="${RUNNER_LABELS}" \
      RUNNER_WORKDIR="${RUNNER_WORKDIR}" \
      EPHEMERAL="${EPHEMERAL}" \
      DISABLE_AUTO_UPDATE="${DISABLE_AUTO_UPDATE}"
```

Notes:

- The template defaults imageName to ghcr.io/groovy-sky/gh-runner:latest.
- Override imageName during deployment if you want to run your own image tag.

### 5. Check container and logs

```sh
az container show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${CONTAINER_NAME}" \
  --query "{state:instanceView.state,image:containers[0].image,ip:ipAddress.ip}" \
  -o table

az container logs \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${CONTAINER_NAME}"
```

For live stream:

```sh
az container attach \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${CONTAINER_NAME}"
```

### 6. Verify runner in GitHub

Open GitHub UI:

- Repository: Settings -> Actions -> Runners.

The runner should appear online with the labels defined in RUNNER_LABELS.

### 7. Run a workflow against the ACI runner

Use a workflow that targets your labels:

```yaml
name: ACI self-hosted runner test

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: [self-hosted, linux, x64, docker]
    steps:
      - uses: actions/checkout@v4
      - name: Show runner context
        run: |
          hostname
          whoami
          pwd
```

## Result

After a successful deployment, the ACI-based runner should:

![Runner online in GitHub](image-3.png)

- Appear in the repository runner list.
- Pick up jobs matching configured labels.
- Execute job steps in the ACI container environment.

## Related documentation

- GitHub self-hosted runners: https://docs.github.com/actions/hosting-your-own-runners
- GitHub runner registration token API: https://docs.github.com/rest/actions/self-hosted-runners
- Azure Container Instances docs: https://learn.microsoft.com/azure/container-instances/
- ARM template deployments with Azure CLI: https://learn.microsoft.com/azure/azure-resource-manager/templates/deploy-cli

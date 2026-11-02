# Migrate from Azure DevOps to GitHub - Part 4: Service Connections

**Tutorial series: Part 4 of 4.** **Previous:** [Part 3: Git Repository Migration](../devops-to-github-02/README.md).

## Introduction

Moving a repository does not give GitHub Actions access to the services used by Azure Pipelines. Service connections do not transfer, so workflows need their own authentication and permissions.

This part explains the available approaches and shows how to configure and test Azure access using OpenID Connect (OIDC) and a user-assigned managed identity, without a client secret.

## Series Overview

- [Migrate from Azure DevOps to GitHub - Part 1: Platform Concepts](../devops-to-github-00/README.md)
- [Migrate from Azure DevOps to GitHub - Part 2: Azure Pipelines to GitHub Actions](../devops-to-github-01/README.md)
- [Migrate from Azure DevOps to GitHub - Part 3: Git Repository Migration](../devops-to-github-02/README.md)
- **Migrate from Azure DevOps to GitHub - Part 4: Service Connections (this article)**

## Azure Pipelines service connections

![](devops-service-connections.png)

A **service connection** holds the connection settings and authentication configuration used to reach an external service. Connection types include Azure Resource Manager, Docker Registry, Kubernetes, and GitHub. Manage them under **Project settings → Service connections**. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops))



A task references the connection by name:

```
steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: production-azure
      scriptType: bash
      scriptLocation: inlineScript
      inlineScript: az account show
```

An **Azure Resource Manager** service connection using **workload identity federation (WIF)** lets a pipeline authenticate to Azure without a client secret. You must still grant the identity used by the connection an appropriate **Azure RBAC role** on the resources the pipeline needs to access. ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/configure-workload-identity?view=azure-devops))

## Choose the GitHub Actions authentication method

Start with the target service and the access the workflow actually needs.

| Method                            | Use it when                                                                             | Important boundary                                                                       |
| --------------------------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| **OIDC federation**               | A cloud provider supports exchanging GitHub identity tokens for short-lived credentials | Provider trust and resource permissions must also be configured                          |
| **Actions secrets**               | A service requires a static credential                                                  | Secret storage does not remove the need for rotation                                     |
| **`GITHUB_TOKEN`**                | The job needs supported access to its own GitHub repository                             | It is not an Azure credential or a general cross-repository token                        |
| **GitHub App installation token** | GitHub automation needs access beyond the built-in token                                | Access depends on the app's installation and granted permissions                         |
| **PAT**                           | A GitHub integration requires user-based token authentication                           | Treat it as a managed credential with limited permissions and expiry                     |
| **Runner identity**               | A suitably configured self-hosted runner can use an existing machine identity           | The runner and every workflow allowed to execute on it become part of the trust boundary |

GitHub's `GITHUB_TOKEN` allows access to repository resources and is automatically generated and scoped to the workflow run. A GitHub App also provides a way to authenticate with GitHub APIs, but its access depends on the app's installation and granted permissions.

These mechanisms provide access to GitHub resources, not external services.

For accessing external services from a GitHub workflow, use the authentication mechanism supported by that service, such as OIDC federation, service-specific secrets, or managed identities. GitHub-provided tokens like `GITHUB_TOKEN` or PATs are not suitable for authenticating to external APIs.

```mermaid
flowchart TD
    direction TD

    direction1{"Which direction needs access?"}

    direction1 -->|"GitHub Actions to external service"| auth{"Which authentication does the service support?"}
    direction1 -->|"External service to GitHub"| github["GitHub App token or scoped PAT"]

    auth -->|"Passwordless"| identity["OIDC federation or runner identity"]
    auth -->|"Password or API key"| secret["Store credentials in Actions secrets"]

    identity --> access["Grant only the required resource permissions"]
    secret --> access
```

## Configure Azure connection with GitHub OIDC

This example uses a **User Assigned Managed Identity** and a branch-bound GitHub federated credential to authenticate to Azure without a client secret.

```mermaid
flowchart TD
  identity["1. Create a user-assigned MI"]
  access["2. Grant MI access to the resource"]
  ids["3. Get GitHub repository and organization IDs"]
  federation["4. Configure MI federated credentials"]
  variables["5. Store Azure IDs in Actions variables"]
  workflow["6. Configure Azure login in GitHub Actions workflow"]

  identity --> access --> ids --> federation --> variables --> workflow
```

### 1. Create the identity

To create a **User Assigned Managed Identity**:

- Open Azure Portal menu -> **Create a resource**  → Find and choose **User Assigned Managed Identity**. Provide required subscription, resource group, region and identity name (`azure-identity`), then **Review + create → Create**.

![Create User Assigned Managed Identity](image-1.png)

![alt text](image-2.png)

### 2. Assign required access to the identity

Open the Azure resource to which you want to grant access -> select **Access control (IAM) → Add role assignment** -> choose a proper role and assign the required role to the user-assigned managed identity (in this demonstration, `azure-identity`). 

![alt text](image-3.png)

![alt text](image-4.png)

### 3. Obtain GitHub repository and organization IDs

To obtain the GitHub repository and organization IDs, create a workflow file in your repository (under `.github/workflows/` path, for example `.github/workflows/repository-info.yml`) with the following content:

```
name: Repository Info

on:
  workflow_dispatch:

permissions: {}

jobs:
  repository-info:
    runs-on: ubuntu-24.04
    timeout-minutes: 5
    outputs:
      repository_id: ${{ github.repository_id }}
      repository_owner_id: ${{ github.repository_owner_id }}
    steps:
      - name: Return Repository and Owner IDs
        env:
          REPOSITORY_ID: ${{ github.repository_id }}
          REPOSITORY_OWNER_ID: ${{ github.repository_owner_id }}
        run: |
          printf 'Repository ID: `%s`\nRepository owner ID: `%s`\n' \
            "$REPOSITORY_ID" "$REPOSITORY_OWNER_ID" | tee -a "$GITHUB_STEP_SUMMARY"
```

Run result should display the repository and owner IDs as specified in the workflow:

![Run result displaying repository and owner IDs](image-5.png)


### 4. Configure federated trust

After managed identity creation and role assignment, configure federated trust for GitHub Actions:

![alt text](image-6.png)

To do so, on the identity, open **Settings → Federated credentials → Add credential → GitHub Actions deploying Azure resources**. Configure and verify these Azure public-cloud values:

| Setting | Example |
| --- | --- |
| Organization / ID | `groovy-sky` / `40501227` |
| Repository / ID | `azure` / `1398660921` |
| Entity / Branch | Branch / `master` |
| Issuer | `https://token.actions.githubusercontent.com` |
| Audience | `api://AzureADTokenExchange` |
| Credential name | `github-azure-master` |

> Since July 15, 2026, new, renamed or transferred GitHub.com repositories default to immutable subjects; existing repositories retain the older format unless they opt in. GitHub Enterprise Server is excluded. Verify your repository's format and customizations. ([docs.github.com](https://docs.github.com/en/actions/reference/security/oidc))


### 5. Store Azure variables

After federation is configured you can use Azure Managed Identity to authenticate GitHub Actions with Azure. To use it in your workflows, store the necessary Azure variables in your repository. 

Store Client ID and Subscription ID from the managed identity:

![alt text](image-7.png)

Next select "Properties" to find the Tenant ID:

![alt text](image-8.png)

Now you can add obtained values to Github repository variables. To do so, navigate to your repository, then go to **Settings → Secrets and variables → Actions → Variables** and add the following variables: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`:

![Add Azure variables to GitHub repository](image-9.png)

### 6. Configure Azure login in GitHub Actions workflow

Now you can use configured Azure Managed Identity from your GitHub Actions workflows in specified repository. Just create a workflow file with the necessary steps to sign in to Azure using the stored variables. For example, create `.github/workflows/azure-oidc-test.yml`:

```
name: Verify Azure authentication

on:
  workflow_dispatch:
  push:
    branches:
      - master

permissions: {}

jobs:
  verify:
    runs-on: ubuntu-24.04

    permissions:
      id-token: write

    steps:
      - name: Sign in to Azure
        uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

      - name: Show selected Azure subscription
        run: |
          az account show \
            --query '{subscription:id, tenant:tenantId}' \
            --output json
```

`id-token: write` allows token requests, not Azure writes. Trust authenticates, RBAC authorizes, and `azure/login` signs in without deploying. ([github.com](https://github.com/Azure/login))

## Result

If all steps are correctly configured, the workflow should be able to use Azure Identity to authenticate and access the specified Azure resources.

The following screenshots illustrate the complete configuration process:

![](mi-config.png)

## Summary

The example workflow can now authenticate to Azure without a client secret. Federated trust controls which workflow can use the identity, while Azure RBAC controls what it can access.

This is the final part of the series. We covered platform differences, pipeline concepts, repository transfer, and external-service access; other integrations still require separate migration work.

**End of series.** Return to [Part 1: Platform Concepts and Series Overview](../devops-to-github-00/README.md).
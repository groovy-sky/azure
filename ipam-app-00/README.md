# Running Azure IPAM on Container Apps 

## Introduction

Azure IP Address Management (IPAM) is a comprehensive solution that provides centralized control and visibility over IP address allocation, usage, and management across various Azure services and resources. This document explains how to run IPAM using two Container Apps with custom DNS.

## Prerequisites

To successfully deploy the solution, the following prerequisites must be met:

- Be [an owner](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged#owner) of an Azure Subscription (to deploy the solution)
- Be a [Global Administrator](https://learn.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#global-administrator) of Entra ID, to grant admin consent for the App Registrations
- Own a public DNS name, used to assign as [a custom domain](https://learn.microsoft.com/en-us/azure/dns/dns-custom-domain) for Container Apps
- Have Azure CLI or PowerShell installed if deploying through scripts

## Theoretical Part

A detailed explanation of what Azure IPAM is and how it can be used can be found in the [official documentation](https://azure.github.io/ipam/#/). This article will focus only on deployment-related aspects.

The deployment involves:
- Two App Registrations in Entra ID (for Engine and UI)
- Cosmos DB for the IPAM datastore
- Key Vault (optional) for secrets storage
- Two Container Apps for running the Engine and UI components
- Custom DNS configuration for both Container Apps

### Cosmos DB

Create NoSQL "ipam-db" database with two containers - "ipam-ctr" and "ipam-engine" with "/tenant_id" as the partition key. This database serves as the persistent storage for all IPAM data, including IP address allocations, configurations, and reservations.

### Entra ID

**Engine**:
- Granted **reader** permission to the [Root Management Group](https://learn.microsoft.com/azure/governance/management-groups/overview#root-management-group-for-each-directory) to facilitate IPAM operations across all subscriptions
- Acts as the authentication point for IPAM API operations using the [on-behalf-of](https://learn.microsoft.com/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow) flow
- Requires API permissions to read Azure resources and manage authentication

**UI**:
- Granted **read** permissions for Microsoft Graph APIs to access user information
- Added as a *known client application* for the *Engine* App Registration to establish trust
- Acts as the authentication point for the IPAM UI using the [OAuth 2.0 authorization code](https://learn.microsoft.com/azure/active-directory/develop/v2-oauth2-auth-code-flow) flow

### Engine Container App

- Image: `azureipam.azurecr.io/ipam-engine:3.4.0`

| Environment Name | Environment Value | Description |
| ---------------- | ----------------- | ----------- |
| AZURE_ENV        | AZURE_PUBLIC      | Specifies Azure public cloud environment |
| CLIENT_ID        | [Engine SPN ID]   | The Engine App Registration client ID |
| TENANT_ID        | [Tenant ID]       | Your Azure tenant ID |
| COSMOS_URL       | https://[DB Name].documents.azure.com:443 | Cosmos DB endpoint URL |
| DATABASE_NAME    | ipam-db           | Name of the database in Cosmos DB |
| COSMOS_KEY       | [DB Access Key]   | Primary or secondary key for Cosmos DB |
| CLIENT_SECRET    | [Engine SPN Secret] | Secret for Engine App Registration |

### UI Container App

- Image: `azureipam.azurecr.io/ipam-ui:3.3.0`

| Environment Name    | Environment Value                        | Description |
| ------------------- | ---------------------------------------- | ----------- |
| VITE_AZURE_ENV      | AZURE_PUBLIC                             | Specifies Azure public cloud environment |
| CONTAINER_NAME      | ipam-ui                                  | Name of the UI container |
| VITE_IPAM_ENGINE_URL| [Engine Container Apps URL]/api          | URL to access the Engine API |
| VITE_TENANT_ID      | [Tenant ID]                              | Your Azure tenant ID |
| VITE_ENGINE_ID      | [Engine SPN ID]                          | The Engine App Registration client ID |
| VITE_UI_ID          | [UI SPN ID]                              | The UI App Registration client ID |

## Practical Part

For detailed deployment steps, refer to the [deployment documentation](https://github.com/Azure/ipam/tree/main/docs/deployment).

### Entra Apps Registration

The easiest way to deploy the app is by using Azure Cloud Shell. Clone the repository `https://github.com/Azure/ipam.git` and run `.\deploy.ps1 -AppsOnly` to create the Entra ID part:

![SPN Creation](/images/ipam/ipam_spns.png)

After the SPNs are created, you'll need to create a secret for the Engine SPN:
![Engine SPN Secret](/images/ipam/ipam_engine_spn_secret.png)

This secret will be used for the Engine Container App to authenticate with Azure resources.

### Azure Resources Overview

![Azure Structure](/images/ipam/azure_struct.png)

### 1. CosmosDB

Create a new Cosmos DB account and configure the `ipam-ctr` and `ipam-engine` containers in the `ipam-db` database:

![Cosmos DB Configuration](/images/ipam/ipam_azure_db.png)

Ensure that the throughput is set appropriately based on your expected load. For testing environments, 400 RUs (Request Units) per container is sufficient.

### 2. Key Vault (Optional)

Secrets can be stored as secret values directly in the Container App itself or centralized in a Key Vault for better security and management:

![Key Vault Configuration](/images/ipam/ipam_azure_vault.png)

Using Key Vault is recommended for production environments to manage secrets rotation and access control more effectively.

### 3. Engine App

Deploy the Engine Container App using the public Docker image:

![Engine Docker Deployment](/images/ipam/ipam_engine_docker.png)

Provide the required environment variables specified in the previous section:

![Engine Environment Variables](/images/ipam/ipam_engine_env.png)

Secret values should also be provided:

![Engine Secrets Configuration](/images/ipam/ipam_engine_secrets.png)

If secrets are stored in a Key Vault, assign a managed identity to the Container App and grant it access to the Key Vault:

![Engine Access to Key Vault](/images/ipam/ipam_engine_access_to_vault.png)

Ingress traffic should be allowed from anywhere, listening on port 80:

![Engine Ingress Configuration](/images/ipam/ipam_engine_ingress.png)

### 4. UI App

The initial deployment of the UI looks similar to the Engine deployment with the exception of the `VITE_IPAM_ENGINE_URL` value. It should be the Engine's custom DNS address + '/api':

![UI Docker Deployment](/images/ipam/ipam_ui_docker.png)
![UI Environment Variables](/images/ipam/ipam_ui_env.png)
![UI Ingress Configuration](/images/ipam/ipam_ui_ingress.png)

### 5. Public DNS Zone 

Due to the [CORS mechanism](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS), it is not possible to access the Engine App from the UI App without using a custom domain. If you aren't familiar with how to manage custom domains, refer to the [Azure DNS documentation](https://learn.microsoft.com/en-us/azure/dns/dns-custom-domain).

Configure a custom domain for both apps:

![Custom DNS Configuration](/images/ipam/ipam_cors_custom_dns.png)

Allow CORS access to Engine App from UI custom DNS:

![Engine CORS Configuration](/images/ipam/ipam_engine_cors.png)

Finally, add the UI custom DNS to the UI's SPN [reply URL](https://learn.microsoft.com/en-us/entra/identity-platform/reply-url):

![UI SPN Authentication](/images/ipam/ipam_ui_spn_auth.png)

## Results

Once the deployment is complete, you should have:

1. Two Container Apps running - the IPAM Engine and UI
2. Custom domain names configured for both apps
3. Cosmos DB storing your IPAM data
4. Properly configured authentication with Entra ID

You can access the IPAM UI through your custom domain (e.g., `https://ipam-ui.yourdomain.com`). Upon first login, you'll need to:

1. Sign in with your Azure credentials
2. Grant consent to the requested permissions
3. Configure initial IPAM settings including spaces and blocks

The IPAM dashboard should display an overview of your IP address utilization across your Azure environment:


![IPAM Homepage](https://github.com/Azure/ipam/blob/main/docs/how-to/images/home_page.png?raw=true)

## Summary


- Setting up the required Entra ID app registrations
- Configuring the necessary Azure resources (Cosmos DB, Key Vault)
- Deploying the Engine and UI Container Apps
- Establishing custom domain names and handling CORS concerns
- Final configuration steps for a working IPAM solution

Azure IPAM provides a robust solution for managing IP addresses across your Azure environment, helping to prevent IP conflicts, track usage, and plan for future network growth. Using Container Apps for deployment offers a scalable, maintainable approach that can easily be integrated into your existing Azure infrastructure.

This guide walked through the process of deploying Azure IPAM using Container Apps. In the next section, will explore how to get started using IPAM.

## Related Information

- [Azure IPAM GitHub Repository](https://github.com/Azure/ipam)

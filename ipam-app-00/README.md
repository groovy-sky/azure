# Running Azure IPAM on Container Apps 

## Introduction

Azure IP Address Management (IPAM) is a comprehensive solution that provides centralized control and visibility over IP address allocation, usage, and management across various Azure services and resources. This document explains how to run IPAM using two Container Apps with custom DNS.

## Prerequisites

To successfully deploy the solution, the following prerequisites must be met:

- Be [an owner](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged#owner) of an Azure Subscription (to deploy the solution)
- Be a [Global Administrator](https://learn.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#global-administrator) of Entra ID, to grant admin consent for the App Registrations
- Own a public DNS name, used to assign as [a custom domain](https://learn.microsoft.com/en-us/azure/dns/dns-custom-domain) for Container Apps

## Theoretical Part

A detailed explanation of what Azure IPAM is and how it can be used can be found in the [official documentation](https://azure.github.io/ipam/#/). This article will focus only on deployment-related aspects.

The deployment involves:
- Two App Registrations in Entra ID (for Engine and UI)
- Cosmos DB for the IPAM datastore
- Key Vault (optional) for secrets storage
- Two Container Apps for running the Engine and UI
- Custom DNS for both Containers

### Cosmos DB

Use "ipam-db" database with two containers - "ipam-ctr" and "ipam-engine" with "/tenant_id" primary keys. 

### Entra ID

**Engine**:
- Granted **reader** permission to the [Root Management Group](https://learn.microsoft.com/azure/governance/management-groups/overview#root-management-group-for-each-directory) to facilitate IPAM operations
- Acts as the authentication point for IPAM API operations ([on-behalf-of](https://learn.microsoft.com/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow) flow)

**UI**:
- Granted **read** permissions for Microsoft Graph APIs
- Added as a *known client application* for the *Engine* App Registration
- Acts as the authentication point for the IPAM UI ([auth code](https://learn.microsoft.com/azure/active-directory/develop/v2-oauth2-auth-code-flow) flow)

### Engine Container App

- Image: `azureipam.azurecr.io/ipam-engine:3.4.0`

| Environment Name | Environment Value |
| ---------------- | ----------------- |
| AZURE_ENV        | AZURE_PUBLIC      |
| CLIENT_ID        | [Engine SPN ID]   |
| TENANT_ID        | [Tenant ID]       |
| COSMOS_URL       | https://[DB Name].documents.azure.com:443 |
| DATABASE_NAME    | ipam-db           |
| COSMOS_KEY       | [DB Access Key]   |
| CLIENT_SECRET    | [Engine SPN Secret] |

### UI Container App

- Image: `azureipam.azurecr.io/ipam-ui:3.3.0`

| Environment Name    | Environment Value                        |
| ------------------- | ---------------------------------------- |
| VITE_AZURE_ENV      | AZURE_PUBLIC                             |
| CONTAINER_NAME      | ipam-ui                                  |
| VITE_IPAM_ENGINE_URL| [Engine Container Apps URL]/api          |
| VITE_TENANT_ID      | [Tenant ID]                              |
| VITE_ENGINE_ID      | [Engine SPN ID]                          |
| VITE_UI_ID          | [UI SPN ID]                              |

## Practical Part

For detailed deployment steps, refer to the [deployment documentation](https://github.com/Azure/ipam/tree/main/docs/deployment).

### Entra Apps Registration

The easiest way to deploy the app is by using Azure Cloud Shell. Clone the repository `https://github.com/Azure/ipam.git` and run `.\deploy.ps1 -AppsOnly` to create the Entra ID part:

![SPN Creation](/images/ipam/ipam_spns.png)

After the SPNs are created, you'll need to create a secret for the Engine SPN:
![Engine SPN Secret](/images/ipam/ipam_engine_spn_secret.png)

This secret will be used for the Engine Container App.

### Azure Resources Overview

![Azure Structure](/images/ipam/azure_struct.png)

### 1. CosmosDB

Create a new Cosmos DB from scratch and configure the `ipam-ctr` and `ipam-engine` containers in the `ipam-db` database:
![Cosmos DB Configuration](/images/ipam/ipam_azure_db.png)

### 2. Key Vault (Optional)

Secrets can be stored as secret values in the Container App itself or in a Key Vault:
![Key Vault Configuration](/images/ipam/ipam_azure_vault.png)

### 3. Engine App

Deploy the Engine Container App using the public Docker image:
![Engine Docker Deployment](/images/ipam/ipam_engine_docker.png)

Provide the required environment variables specified in the previous section:
![Engine Environment Variables](/images/ipam/ipam_engine_env.png)

Secret values should also be provided:
![Engine Secrets Configuration](/images/ipam/ipam_engine_secrets.png)

If secrets are stored in a Key Vault, assign the identity to the Container App and grant access to the Key Vault:
![Engine Access to Key Vault](/images/ipam/ipam_engine_access_to_vault.png)

Ingress traffic should be allowed from anywhere, listening on port 80:
![Engine Ingress Configuration](/images/ipam/ipam_engine_ingress.png)

### 4. UI App

The initial deployment of the UI looks similar to the Engine deployment with the exception of the `VITE_IPAM_ENGINE_URL` value. It should be the Engine's custom DNS address + '/api':
![UI Docker Deployment](/images/ipam/ipam_ui_docker.png)
![UI Environment Variables](/images/ipam/ipam_ui_env.png)
![UI Ingress Configuration](/images/ipam/ipam_ui_ingress.png)

### 5. Public DNS Zone 

Due to the [CORS mechanism](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS), it is not possible to access the Engine App from the UI App without using a custom domain. If you aren't familiar with how to manage custom domains, refer to the documentation.

Configure a custom domain for both apps:
![Custom DNS Configuration](/images/ipam/ipam_cors_custom_dns.png)

Allow access to the UI CORS from the Engine's custom DNS and vice versa:
![UI CORS Configuration](/images/ipam/ipam_ui_cors.png)
![Engine CORS Configuration](/images/ipam/ipam_engine_cors.png)

Finally, add the UI custom DNS to the UI's SPN [reply URL](https://learn.microsoft.com/en-us/entra/identity-platform/reply-url):
![UI SPN Authentication](/images/ipam/ipam_ui_spn_auth.png)

## Results
## Summary
## Related Information
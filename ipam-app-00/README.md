# Running Azure IPAM on Container Apps 
## Introduction
Azure IPAM is a lightweight solution developed on top of the Azure platform designed to help Azure customers manage their IP Address space easily and effectively. This document explains how-to run Azure IPAM using Container Apps.

## Prerequisites

To successfully deploy the solution, the following prerequisites must be met:

* Be [an owner](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged#owner) of an Azure Subscription (to deploy the solution into)
* Be [Global Administrator](https://learn.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#global-administrator) of Entra ID, to be able to grant admin consent for the App Registration API permissions

## Theoretical Part

The Azure IPAM solution is delivered via a container running as Container Apps. The container is built and published to a public Azure Container Registry (ACR), but you may also choose to build your own container and host it in a Private Container Registry. Here is a more specific breakdown of the components used:

* Two App Registrations for Engine and UI
* Cosmos DB for IPAM datastore
* Key Vault (optional) to store DB key and Engine SPN secret
* Two container Apps, used for running Engine and UI

### SPN

https://github.com/Azure/ipam/tree/main/docs/deployment#azure-identities-only-deployment


### Engine App configuration

azureipam.azurecr.io/ipam-engine:3.4.0

Environment name | Environment value
-- | --
AZURE_ENV | AZURE_PUBLIC
CLIENT_ID | [Engine SPN ID]
TENANT_ID | [Tenant ID]
COSMOS_URL | https://[DB Name].documents.azure.com:443
DATABASE_NAME | ipam-db
COSMOS_KEY | [DB Access Key]
CLIENT_SECRET | [Engine SPN Secret]

### UI App configuration

azureipam.azurecr.io/ipam-ui:3.3.0

Environment name | Environment value
-- | --
VITE_AZURE_ENV | AZURE_PUBLIC
CONTAINER_NAME | ipam-ui
VITE_IPAM_ENGINE_URL | [Engine URL]/api
VITE_TENANT_ID | [Tenant ID]
VITE_ENGINE_ID | [Engine SPN ID]
VITE_UI_ID | [UI SPN ID]


## Practical Part

https://github.com/Azure/ipam/tree/main/docs/deployment

### Entra Apps registration

Easieast way how you can deploy app is by using Azure Cloud Shell. Clone https://github.com/Azure/ipam.git repository and run ".\deploy.ps1 -AppsOnly" to create Entra ID part:

![](/images/ipam/ipam_spns.png)

After SPN are created, you'll need to create a secret for Engine SPN:
![](/images/ipam/ipam_engine_spn_secret.png)

It will be used for Engine Container App.


### Azure resources overview

![](/images/ipam/azure_struct.png)

### 1. CosmosDB

![](/images/ipam/ipam_azure_db.png)

### 2. Key Vault (optional)

![](/images/ipam/ipam_azure_vault.png)

### 3. Engine App

![](/images/ipam/ipam_engine_docker.png)
![](/images/ipam/ipam_engine_env.png)
![](/images/ipam/ipam_engine_secrets.png)
![](/images/ipam/ipam_engine_ingress.png)


![](/images/ipam/ipam_engine_access_to_vault.png)

### 4. UI App

![](/images/ipam/ipam_ui_docker.png)
![](/images/ipam/ipam_ui_env.png)
![](/images/ipam/ipam_ui_ingress.png)
![](/images/ipam/ipam_ui_spn_api_perm.png)

### 5. Public DNS zone 
![](/images/ipam/ipam_engine_cors.png)
![](/images/ipam/ipam_engine_custom_dns.png)
![](/images/ipam/ipam_ui_cors.png)
![](/images/ipam/ipam_ui_custom_dns.png)
![](/images/ipam/ipam_azure_dns.png)

![](/images/ipam/ipam_ui_spn_auth.png)


## Results
## Summary
## Related Information
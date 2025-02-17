# Running Azure IPAM on Container Apps 
## Introduction
Azure IPAM is a lightweight solution developed on top of the Azure platform designed to help Azure customers manage their IP Address space easily and effectively. This document explains how-to run Azure IPAM using Container Apps. For doing that 

## Prerequisites

To successfully deploy the solution, the following prerequisites must be met:

* Be [an owner](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged#owner) of an Azure Subscription (to deploy the solution into)
* Be [Global Administrator](https://learn.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#global-administrator) of Entra ID, to be able to grant admin consent for the App Registration API permissions
* Own a public DNS name, used to assign as [a custom domain](https://learn.microsoft.com/en-us/azure/dns/dns-custom-domain) for UI and Egnine 

## Theoretical Part

The Azure IPAM solution is delivered via a container running as Container Apps. The container is built and published to a public Azure Container Registry. Here is a more specific breakdown of the components used:

* Two App Registrations for Engine and UI
* Cosmos DB for IPAM datastore
* Key Vault (optional) to store DB key and Engine SPN secret
* Two Container Apps, used for running Engine and UI

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
VITE_IPAM_ENGINE_URL | [Engine Container Apps URL]/api
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

Create a new Cosmos DB from scratch and configure ipam-ctr and ipam-engine containers in ipam-db database:
![](/images/ipam/ipam_azure_db.png)

### 2. Key Vault (optional)

You can store secret as secret values in Container App itself or use a Key Vault for that:

![](/images/ipam/ipam_azure_vault.png)

### 3. Engine App

Deploy Engine Container App using public Docker image:
![](/images/ipam/ipam_engine_docker.png)

Provide required environment variables specified in previous section:
![](/images/ipam/ipam_engine_env.png)

Same goes to secret values:
![](/images/ipam/ipam_engine_secrets.png)

If secrets are stored in a Key Vault, will be needed to assign identity to Container app and grant access to Key Vault:
![](/images/ipam/ipam_engine_access_to_vault.png)

Ingress traffic should be allowed from anywhere and listen on 80 port:
![](/images/ipam/ipam_engine_ingress.png)




### 4. UI App

UI initial deploy looks similar to Engine deploy except 'VITE_IPAM_ENGINE_URL' value. It should be Engine's custom DNS address + '/api': 
![](/images/ipam/ipam_ui_docker.png)
![](/images/ipam/ipam_ui_env.png)
![](/images/ipam/ipam_ui_ingress.png)

### 5. Public DNS zone 

Due to [CORS mechanism](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) it is not possible to access Engine App from UI App without using a custom domain. If you aren't familiar how to manage a custom domain - try [the following tutorial](https://learn.microsoft.com/en-us/training/modules/host-domain-azure-dns).

Configure custom domain for both apps:
![](/images/ipam/ipam_cors_custom_dns.png)

Allow to access UI CORS from Engine's custom DNS and vice versa:
![](/images/ipam/ipam_ui_cors.png)![](/images/ipam/ipam_engine_cors.png)

Finally  add UI custom DNS to UI's SPN [reply URL](https://learn.microsoft.com/en-us/entra/identity-platform/reply-url):
![](/images/ipam/ipam_ui_spn_auth.png)


## Results
## Summary
## Related Information
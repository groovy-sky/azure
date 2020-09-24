# 
## Introduction

Recently Docker has enabled [download rate limits for pull requests and container image retention limits](https://www.docker.com/pricing/resource-consumption-updates) on Docker Hub for Free plans. This made me wonder about alternatives and especially about hosting my own registry.

![](/images/docker/private_registry_logo.png)

This page gives **an example of hosting your own Docker registry using Azure App Service**. Main aim of it is to examine posibility to run a private registry with a minimal effort needed to maintain its infrastructure.

## Theoretical Part

### Azure App Service

![](/images/docker/webapp_container.png)

Azure App Service is an HTTP-based service for hosting web applications, REST APIs, and mobile back ends. App Service on Linux not only provides pre-defined application stacks with support for numerous languages (such as .NET, PHP, Node.js and others), but also allows to use [a custom Docker image](https://docs.microsoft.com/en-us/azure/app-service/configure-custom-container) to run your web app on an application stack that is not already defined in Azure. 

For this demo I will use custom Linux container [running on App Service with mounted Azure Storage](https://docs.microsoft.com/en-us/azure/app-service/configure-connect-to-azure-storage?pivots=container-linux). Storage Account will store a passwords hash used by Registry for authentication.

### Docker Registry

![](/images/docker/oyster-registry.png)

A registry is a storage and content delivery system, holding named Docker images, available in different tagged versions. By default, Docker users pull images from Docker's public registry instance, but you can host your own private registry as an alternative option. 

Docker Inc. provides [a set of toolkit components](https://github.com/docker/distribution#distribution). One of these explains [how-to deploy and run your own private registry as a container instance](https://github.com/docker/docker.github.io/blob/master/registry/deploying.md). Basiclly, registry is just a storage and content delivery system, holding named Docker images, available in different tagged versions. Its configuration is based on a YAML file, which has [a wide variety of options](https://github.com/docker/distribution/blob/master/docs/configuration.md#list-of-configuration-options). Most important of them:

* log - configures the behavior of the logging system
* storage - defines which storage backend is in use
* auth - configures authentication provider
* http - the configuration for the HTTP server that hosts the registry
* notifications - contains a list of named services (URLs) that can accept event notifications
* health - contains preferences for a periodic health check on the storage driver's backend storage

For this demo specific configurations will be used exactly for `storage` and `auth` options. As a storage for a registry will be utilized [a Microsoft Azure Blob Storage account](https://github.com/docker/docker.github.io/blob/master/registry/storage-drivers/azure.md) and [htpasswd configuration file](https://docs.docker.com/registry/configuration/#htpasswd) for an authentication. 


## Prerequisites

To run the demo you’ll need [an Azure Cloud account](https://azure.microsoft.com/free/)

## Practical Part

As usual, everything for running this demo is stored in [one repository](https://github.com/groovy-sky/self-registry). To start the depoyment you'll use [run.sh](https://github.com/groovy-sky/self-registry/blob/master/run.sh), which has following structure: 

![](/images/docker/run_sh_sctructure.png)

Scripts execution logic:
1. Generate htpasswd file from user input (you provide username and password for accessing your registry)
2. Create a resource group and storage account in it
3. Upload the file, from the first step, to the storage
4. Create an App Service with 'registry' container instance
5. Mount the storage (with htpasswd file) to the App Service

Even though registry configuration is based on a YAML file, you can use environment variables as alternative. This is used in the template, which deploys a registry (every environment variable which starts with `REGISTRY_` is a part of registry configuration): 

![](/images/docker/docker_registry_arm_variables.png)

Easiest way how you can deploy a demo environment - use [Azure Cloud Shell in Bash mode](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) for following script execution:


```
export grpName="demo-registry-group"                                                                                 
export grpRegion="westeurope"                                                                                        
export strgConfig="config"                                                                                           
export strgData="data"                                                                                               
export authConfig="htpasswd" 

[ ! -d "self-registry/.git" ] && git clone https://github.com/groovy-sky/self-registry
cd self-registry && git pull
./run.sh

```

The whole thing takes less than 5 minutes:

![](/images/docker/registy_build.gif)

As a result will be deployed a storage, app service and app service plan:

![](/images/docker/private_registry_res_group.png)

## Results

If the deployment was successful you can validate a result by logging to your private registry and pushing an image from computer with installed Docker Engine:

![](/images/docker/using_private_registry.png)

## Summary

As stated in the Introduction, main target was to examine posibility to run a private registry with a minimal effort needed to maintain its infrastructure. This work has demonstrated that it is possible to accomplish that using few resources. To sum up, this solution has some advantages and disadvantages, which are presented below.

### Pros

* You can use a **custom domain/certificate** for your app. By default .azurewebsites.net

* You can **restrict access** for your app by defining allow/deny list that controls network access to your app. The list can include IP addresses or Azure Virtual Network subnets.

* You can **scale an App Service plan up and down** by changing the pricing tier and hardware level that it runs on

* You can run **advanced scenarios**, like [using CDN](https://docs.microsoft.com/en-us/azure/cdn/cdn-add-to-web-app?toc=/azure/cdn/toc.json), [sending email](https://docs.microsoft.com/en-us/azure/app-service/tutorial-send-email), [controlling a traffic with Traffic Manager](https://docs.microsoft.com/en-us/azure/app-service/web-sites-traffic-manager) etc. 

* Docker registry storage (which uses Azure Storage) is [**automatically encrypted**](https://docs.microsoft.com/en-us/azure/storage/common/storage-service-encryption)

### Cons

* **Price**

[Estimated monthly cost](https://azure.com/e/2e33c3703a6e496f81de41dd8344fbae) for self-hosted registry:

![](/images/docker/private_registry_pricing.png)

[Azure Container Registry price](https://azure.microsoft.com/en-us/pricing/details/container-registry/):

![](/images/docker/azure_registry_pricing.png)

* **Content Trust** https://docs.microsoft.com/en-us/azure/container-registry/container-registry-content-trust

## Related Information

* https://docs.docker.com/registry/configuration/
* https://github.com/docker/distribution
* https://github.com/docker/distribution/blob/master/Dockerfile
* https://github.com/docker/distribution/blob/master/docs/spec/api.md
* https://docs.microsoft.com/en-us/learn/modules/intro-to-containers/

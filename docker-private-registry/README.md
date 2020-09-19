# 
## Introduction

Recently Docker has enabled download rate limits for pull requests and container image retention limits on Docker Hub for Free plans. This mak

![](/images/docker/private_registry_logo.png)

This page gives an example of hosting your own Docker registry using Azure App Service. 

## Theoretical Part

![](/images/docker/oyster-registry.png | width=100 )

A registry is a storage and content delivery system, holding named Docker images, available in different tagged versions. By default, Docker users pull images from Docker's public registry instance, but you can host your own private registry as an alternative option. 

Docker Inc. provides [a set of toolkit components](https://github.com/docker/distribution#distribution). One of these explains [how-to deploy and run your own private registry as a container instance](https://github.com/docker/docker.github.io/blob/master/registry/deploying.md).

A registry is a storage and content delivery system, holding named Docker images, available in different tagged versions. Its configuration is based on a YAML file, which has [a wide variety of options](https://github.com/docker/distribution/blob/master/docs/configuration.md#list-of-configuration-options). Most important of them:

* log - configures the behavior of the logging system
* storage - defines which storage backend is in use
* auth - configures authentication provider
* http - the configuration for the HTTP server that hosts the registry
* notifications - contains a list of named services (URLs) that can accept event notifications
* health - contains preferences for a periodic health check on the storage driver's backend storage

For this demo specific configurations will be used exactly for `storage` and `auth` options. As a storage for a registry will be utilized [a Microsoft Azure Blob Storage account](https://github.com/docker/docker.github.io/blob/master/registry/storage-drivers/azure.md) and [htpasswd](https://docs.docker.com/registry/configuration/#htpasswd) for an authentication. 

Even though registry configuration is based on a YAML file, you can use environment variables as alternative. For that create an environment variable named REGISTRY_variable where variable is the name of the configuration option and the _ (underscore) represents indention levels. 

## Prerequisites

Before you begin the next section, you’ll need:                                                               
* [Azure Cloud account](https://azure.microsoft.com/free/)

## Practical Part

As usual, everything that you'll need to run this demo is stored in [one repository](https://github.com/groovy-sky/self-registry). Easiest way how to do that - use [Azure Cloud Shell in Bash mode](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) and execute following script:


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

## Results

If the deployment was successful you can validate a result by logging to your private registry and pushing an image from computer with installed Docker Engine:

![](/images/docker/using_private_registry.png)

## Summary

[Estimated monthly cost](https://azure.com/e/2e33c3703a6e496f81de41dd8344fbae)

![](/images/docker/private_registry_pricing.png)

## Related Information

* https://docs.docker.com/registry/configuration/
* https://github.com/docker/distribution
* https://github.com/docker/distribution/blob/master/Dockerfile
* https://github.com/docker/distribution/blob/master/docs/spec/api.md

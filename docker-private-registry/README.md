# 
## Introduction

This page gives an example of hosting your own Docker registry using Azure App Service. 

## Theoretical Part

![](/images/docker/oyster-registry.png)

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
## Practical Part
## Results
## Summary
## Related Information

* https://docs.docker.com/registry/configuration/
* https://github.com/docker/distribution
* https://github.com/docker/distribution/blob/master/Dockerfile
* https://github.com/docker/distribution/blob/master/docs/spec/api.md

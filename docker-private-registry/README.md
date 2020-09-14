# 
## Introduction

This page gives an example of hosting your own Docker registry using Azure App Service. 

## Theoretical Part

The Registry is a stateless, highly scalable server side application that stores and lets you distribute Docker images.

A registry is a storage and content delivery system, holding named Docker images, available in different tagged versions. By default, Docker users pull images from Docker's public registry instance, but you can host your own private registry as an alternative option.

Currently latest registry version is 2.0, which uses latest [registry API](https://github.com/docker/distribution/blob/master/docs/spec/api.md).

### Registry configuration options

A registry is a storage and content delivery system, holding named Docker images, available in different tagged versions. Registry configuration is based on a YAML file, which has [a wide variety of options](https://github.com/docker/distribution/blob/master/docs/configuration.md#list-of-configuration-options). Most important of them:

* log - configures the behavior of the logging system
* storage - defines which storage backend is in use
* auth - configures authentication provider
* http - the configuration for the HTTP server that hosts the registry
* notifications - contains a list of named services (URLs) that can accept event notifications
* health - contains preferences for a periodic health check on the storage driver's backend storage

## Prerequisites
## Practical Part
## Results
## Summary
## Related Information
* https://docs.docker.com/registry/configuration/
* https://github.com/docker/distribution
* https://github.com/docker/distribution/blob/master/Dockerfile
* https://github.com/docker/distribution/blob/master/docs/spec/api.md

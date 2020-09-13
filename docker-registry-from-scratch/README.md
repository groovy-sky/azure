# 
## Introduction
## Theoretical Part

docker run -d -p 5000:5000 --restart=always --name registry registry:2

To change default port use REGISTRY_HTTP_ADDR environment variable:

docker run -d -e REGISTRY_HTTP_ADDR=0.0.0.0:5001 -p 5001:5001 --name registry-test registry:2

By default, your registry data is persisted as a docker volume on the host filesystem. If you want to store your registry contents at a specific location on your host filesystem, such as if you have an SSD or SAN mounted into a particular directory, you might decide to use a bind mount instead. A bind mount is more dependent on the filesystem layout of the Docker host, but more performant in many situations. The following example bind-mounts the host directory /mnt/registry into the registry container at /var/lib/registry/:

docker run -d -p 5000:5000 --restart=always --name registry -v /mnt/registry:/var/lib/registry registry:2

By default, the registry stores its data on the local filesystem, whether you use a bind mount or a volume. You can store the registry data in an Amazon S3 bucket, Google Cloud Platform, or on another storage back-end by using storage drivers. 

To run registry with TLS:
docker run -d --restart=always --name registry -v "$(pwd)"/certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key -p 443:443 registry:2



## Prerequisites
## Practical Part
## Results
## Summary
## Related Information
* https://docs.docker.com/registry/configuration/
* https://github.com/docker/distribution
* https://github.com/docker/distribution/blob/master/Dockerfile
* https://github.com/docker/distribution/blob/master/docs/spec/api.md

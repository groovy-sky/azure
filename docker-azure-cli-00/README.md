# Run Docker in a browser using Azure Cloud Shell (part 1)

## Introduction

## Architecture
![](/images/docker-azure-cli/arch.png)

### Docker Machine

When people say “Docker” they typically mean Docker Engine, the client-server application made up of the Docker daemon, a REST API that specifies interfaces for interacting with the daemon, and a command line interface (CLI) client that talks to the daemon (through the REST API wrapper). Docker Engine accepts docker commands from the CLI, such as docker run <image>, docker ps to list running containers, docker image ls to list images, and so on.

[Docker Machine](https://docs.docker.com/machine/overview/) is a tool that lets install Docker Engine on virtual hosts, and manage the hosts (which could be a local machine or cloud provider) with docker-machine commands. 

Using docker-machine commands, you can start, inspect, stop, and restart a managed host, upgrade the Docker client and daemon, and configure a Docker client to talk to your host.

Point the Machine CLI at a running, managed host, and you can run docker commands directly on that host. For example, run docker-machine env default to point to a host called default, follow on-screen instructions to complete env setup, and run docker ps, docker run hello-world, and so forth.

Docker Machine is a tool for provisioning and managing your Dockerized hosts (hosts with Docker Engine on them). Typically, you install Docker Machine on your local system. Docker Machine has its own command line client docker-machine and the Docker Engine client, docker. You can use Machine to install Docker Engine on one or more virtual systems. These virtual systems can be local (as when you use Machine to install and run Docker Engine in VirtualBox on Mac or Windows) or remote (as when you use Machine to provision Dockerized hosts on cloud providers). The Dockerized hosts themselves can be thought of, and are sometimes referred to as, managed “machines”.

### Azure Cloud Shell
[Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) is an interactive, browser-accessible shell for managing Azure resources. It provides the flexibility of choosing the shell experience that best suits the way you work. Linux users can opt for a Bash experience, while Windows users can opt for PowerShell.

## Prerequisites
Az it was mentioned earlier - we will use a Cloud Shell. If you run it for a first time - you will need to configure which subscription should be used for a storage account:
![](/images/docker-azure-cli/shell_init.png)
![](/images/docker-azure-cli/shell_init_result.png)

## Implementation
### Provision
docker-machine create --driver azure --azure-subscription-id 'subs-id' 'machine-name'

docker-machine create --driver azure --azure-subscription-id 'subs-id' --azure-resource-group 'docker-group' --azure-location 'northeurope' --azure-size 'Standard_D2s_v3' docker-cli-vm

### Access configuration
![](/images/docker-azure-cli/docker_machine_create.png)
Cloud Shell runs on a temporary host provided on a per-session, per-user basis

![](/images/docker-azure-cli/docker_vm_nsg.png)

![](/images/docker-azure-cli/docker_vm_nsg_new.png)

### Connect to Docker-engine
docker-machine list
![](/images/docker-azure-cli/get_docker_machine_list.png)
docker-machine env --shell /bin/bash cli-vm

### Startup configuration
![](/images/docker-azure-cli/docker_machine_env_startup.png)

echo 'eval "$(docker-machine env --shell /bin/bash cli-vm)"' >> ~/.bashrc

## Results

## Useful documentation


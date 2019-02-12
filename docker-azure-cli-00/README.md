# Run Docker in a browser using Azure Cloud Shell (part 1)

## Introduction

## Architecture
![](/images/docker-azure-cli/arch.png)

[Docker Machine](https://docs.docker.com/machine/overview/) is a tool that lets install Docker Engine on virtual hosts, and manage the hosts (which could be a local machine or cloud provider) with docker-machine commands. 

Using docker-machine commands, you can start, inspect, stop, and restart a managed host, upgrade the Docker client and daemon, and configure a Docker client to talk to your host.

Point the Machine CLI at a running, managed host, and you can run docker commands directly on that host. For example, run docker-machine env default to point to a host called default, follow on-screen instructions to complete env setup, and run docker ps, docker run hello-world, and so forth.

[Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) is an interactive, browser-accessible shell for managing Azure resources. It provides the flexibility of choosing the shell experience that best suits the way you work. Linux users can opt for a Bash experience, while Windows users can opt for PowerShell.

## Prerequisites
[Setup Bash in Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart)
![](/images/docker-azure-cli/shell_init.png)
![](/images/docker-azure-cli/shell_init_result.png)

## Implementation

docker-machine create --driver azure --azure-subscription-id 'subs-id' 'machine-name'

docker-machine create --driver azure --azure-subscription-id 'subs-id' --azure-resource-group 'docker-group' --azure-location 'northeurope' --azure-size 'Standard_D2s_v3' docker-cli-vm

![](/images/docker-azure-cli/docker_machine_create.png)
Cloud Shell runs on a temporary host provided on a per-session, per-user basis

![](/images/docker-azure-cli/docker_vm_nsg.png)

![](/images/docker-azure-cli/docker_vm_nsg_new.png)

![](/images/docker-azure-cli/get_docker_machine_list.png)

![](/images/docker-azure-cli/docker_machine_env_startup.png)


echo 'eval "$(docker-machine env --shell /bin/bash cli-vm)"' >> ~/.bashrc

## Results

## Useful documentation


# Run Docker in a browser using Azure Cloud Shell (part 1)

## Introduction
![](/images/docker-azure-cli/arch.png)

In this article we will use a Docker Machine and Microsoft Azure to create and configure Docker Engine. As a result we'll be able to manage containers from the Cloud Shell. 

## Architecture

### Docker Machine

When people say “Docker” they typically mean Docker Engine, the client-server application made up of the Docker daemon, a REST API that specifies interfaces for interacting with the daemon, and a command line interface (CLI) client that talks to the daemon (through the REST API wrapper). 

[Docker Machine](https://docs.docker.com/machine/overview/) is a tool that lets install Docker Engine on virtual hosts, and manage the hosts (which could be a local machine or cloud provider) with docker-machine commands. 

### Azure Cloud Shell
[Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) is an interactive, browser-accessible shell for managing Azure resources. It provides the flexibility of choosing the shell experience that best suits the way you work. Linux users can opt for a Bash experience, while Windows users can opt for PowerShell. For this demo we need a Bash option.

## Prerequisites
Before we can start - we need to activate the Shell. For a fist run it would require to configure which subscription should be used for a Shell's storage account:
![](/images/docker-azure-cli/shell_init.png)
![](/images/docker-azure-cli/shell_init_result.png)

## Implementation

Docker machine creates Docker Engines on Azure and then configures the Docker client (which is a part of Azure Cloud Shell) to securely talk to them. By default Docker client is installed on Cloud Shell but a Docker engine isn't accesible yet. Let's verify that: 
![](/images/docker-azure-cli/docker_run_err.png)

So now we can create a Docker engine (which means that we will create a new virtual machine) and connect to it using Docker client.

### Provision
We can get an idea of what information Docker Machine needs by running "docker-machine create -d azure --help" or by viewing 
[official documentaiton](https://docs.docker.com/machine/drivers/azure/). Azure driver requires one argument - a Subscription Id, so than a whole command will look like like:
docker-machine create --driver azure --azure-subscription-id 'subs-id' 'machine-name'

There are some additional parameters that we can use to fine-tune the behavior of a deployment. We will additioanly specify a deployment's resource group name/location and a virtual machine size:
docker-machine create --driver azure --azure-subscription-id 'subs-id' --azure-resource-group 'docker-group' --azure-location 'northeurope' --azure-size 'Standard_D2s_v3' 'docker-vm-name'
![](/images/docker-azure-cli/docker_machine_create.png)

### Access configuration

After deployment is finished we can improve 
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


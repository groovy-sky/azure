# Run Docker in a browser using Azure Cloud Shell (part 1)

## Introduction

## Architecture
https://docs.docker.com/machine/overview/
https://docs.microsoft.com/en-us/azure/cloud-shell/overview
Cloud Shell runs on a temporary host provided on a per-session, per-user basis
## Prerequisites

## Implementation
![](/images/docker-azure-cli/docker_machine_create.png)

![](/images/docker-azure-cli/docker_vm_nsg.png)

![](/images/docker-azure-cli/docker_vm_nsg_new.png)

![](/images/docker-azure-cli/get_docker_machine_list.png)

![](/images/docker-azure-cli/docker_machine_env_startup.png)


echo 'eval "$(docker-machine env --shell /bin/bash cli-vm)"' >> ~/.bashrc

## Results

## Useful documentation


# Run Docker in a browser using Azure Cloud Shell (part 1)

## Introduction

## Architecture
https://docs.docker.com/machine/overview/
https://docs.microsoft.com/en-us/azure/cloud-shell/overview
Cloud Shell runs on a temporary host provided on a per-session, per-user basis
## Prerequisites
[Setup Bash in Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart)
![](/images/docker-azure-cli/shell_init.png)
![](/images/docker-azure-cli/shell_init_result.png)

## Implementation

docker-machine create --driver azure --azure-subscription-id <subs-id> <machine-name>
docker-machine create --driver azure --azure-subscription-id '<subs-id>' --azure-resource-group 'docker-group' --azure-location 'northeurope' --azure-size 'Standard_D2s_v3' docker-cli-vm

![](/images/docker-azure-cli/docker_machine_create.png)

![](/images/docker-azure-cli/docker_vm_nsg.png)

![](/images/docker-azure-cli/docker_vm_nsg_new.png)

![](/images/docker-azure-cli/get_docker_machine_list.png)

![](/images/docker-azure-cli/docker_machine_env_startup.png)


echo 'eval "$(docker-machine env --shell /bin/bash cli-vm)"' >> ~/.bashrc

## Results

## Useful documentation


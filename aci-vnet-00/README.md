# DNS Troubleshooting using Container Instance

![](/images/docker/dns_logo.png)

## Introduction

In modern cloud environments, there are many situations where you need a lightweight, disposable environment for network troubleshooting. Quick access to basic tools—without the overhead of a full virtual machine—can make diagnosing connectivity issues faster and simpler. This document provides a practical example of **using an Azure Container Instance (ACI) for DNS troubleshooting**. 

## Theoretical part

Deploying container groups into a private VNet enables **secure, private communication** between your containers and other Azure or on-premises resources. Azure Container Instances abstracts underlying compute infrastructure, allowing you to run containers without managing virtual machines or orchestrators. When integrated with a VNet, your ACI workloads can leverage Azure’s networking capabilities—**subnet delegation**, **network security groups (NSGs)**, and **private IP addressing**—to enforce zero-trust and isolate traffic. This combination removes the need for a jump box or NAT gateway for container-to-container communication, streamlining both deployment and operations.

### Use Cases and Scenarios

Common scenarios for deploying ACI into a private VNet include:

- Container-to-container communication in multi-tier architectures  
- Hybrid connectivity via VPN or ExpressRoute  
- Transient microservices testing in isolated environments  
- Network diagnostics and troubleshooting workshops  
- Secure on-demand batch processing without public exposure  

These use cases illustrate how private VNet integration enhances security, reduces operational complexity, and accelerates troubleshooting.


## Prerequisites

Before you begin, ensure you have:

- Active Azure subscription
- Configured [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/get-started?tabs=azurecli)

All deployments must occur in the **same Azure region** to allow cross-resource-group networking.



## Practical part

### 1. Define Environment Variables

```bash
# Common variables
export SUFFIX="DNS-RESOLVER"
export LOCATION="westeurope"

# Container instance settings
export ACI_NAME="aci-$(echo ${SUFFIX} | tr '[:upper:]' '[:lower:]')"
export IMAGE="mcr.microsoft.com/azurelinux/base/nginx:1.25"
export ACI_RG="ACI-${SUFFIX}"
```

These variables provide a **consistent naming convention** and reduce hard-coding in subsequent commands.

### 2. Create VNet (optional)

```bash
# Virtual network and subnet settings
export VNET_RG="VNET-${SUFFIX}"
export VNET_NAME="aci-vnet"
export SUBNET_NAME="aci-subnet"
export VNET_PREFIX="10.0.0.0/16"
export SUBNET_PREFIX="10.0.0.0/24"

# Create the resource groups
az group create --name $VNET_RG --location $LOCATION
az group create --name $ACI_RG --location $LOCATION

# Create a delegated subnet in a new VNet
az network vnet create \
  --resource-group $VNET_RG \
  --name $VNET_NAME \
  --address-prefix $VNET_PREFIX \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix $SUBNET_PREFIX

# Delegate the subnet to Azure Container Instances
az network vnet subnet update \
  --resource-group $VNET_RG \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --delegations Microsoft.ContainerInstance/containerGroups
```

By placing the VNet and the ACI in separate resource groups, you isolate networking from compute concerns and support independent lifecycle management.

### 3. Deploy the Container

```bash
# Virtual network and subnet settings
export VNET_RG="VNET-DNS-RESOLVER"
export VNET_NAME="aci-vnet"
export SUBNET_NAME="aci-subnet"

az container create \
  --resource-group $ACI_RG \
  --name $ACI_NAME \
  --image $IMAGE \
  --vnet $VNET_NAME \
  --subnet $SUBNET_NAME \
  --os-type Linux \
  --restart-policy OnFailure \
  --ip-address Private \
  --cpu 1 \
  --memory 1.5
```

> **Note:** You must reference the VNet’s **resource group** (`$VNET_RG`) using the `--resource-group` parameter for the `--vnet` option, because your VNet lives in a different group.

This command provisions a container group with a **private IP address** on the specified subnet.



### Cleanup

Once the container is running, you can install network troubleshooting tools using the **tdnf** package manager:

```bash
# Enter the container
az container exec --resource-group $ACI_RG --name $ACI_NAME --exec-command "/bin/sh"

# Install package for DNS
tdnf update -y; tdnf install -y iputils bind-utils
```




### Cleanup
After troubleshooting you can delete created resources:

```bash
# Delete both resource groups (irrecoverable)
az group delete --name $ACI_RG --yes
az group delete --name $VNET_RG --yes
```

## Summary

Deploying an Azure Container Instance into a private virtual network gives you a lightweight, on-demand environment for network diagnostics without the overhead of managing full virtual machines. By delegating a subnet and assigning a private IP to your container group, you leverage Azure’s built-in security controls—such as network security groups, subnet isolation, and zero-trust networking—while maintaining consistent resource management across networking and compute components.

### Advantages

- Rapid provisioning of ephemeral troubleshooting environments  
- Full integration with VNet features (NSGs, private IPs, subnet delegation)  
- Eliminates need for jump boxes or NAT gateways for container-to-container traffic  
- No VM or orchestrator management, reducing operational complexity  
- Pay-as-you-go container billing for cost efficiency  

### Limitations

- ICMP traffic is not supported in Azure Container Instances, so `ping` and `traceroute` will not function  
- Private-only IP addressing prevents direct public Internet tests without additional NAT or firewall configuration  
- Package availability depends on the container’s native Linux repo (tdnf), which may not include all diagnostic tools  
- Container instances are stateless by default—any files or custom configurations are lost on restart  

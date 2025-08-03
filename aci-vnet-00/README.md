# DNS Troubleshooting using Container Instance

<img src="/images/docker/dns_logo.png" style="width:150px;" alt="dns logo">

## Introduction

In modern cloud environments, there are many situations where you need a lightweight, disposable environment for network troubleshooting. Quick access to basic tools—without the overhead of a full virtual machine—can make diagnosing connectivity issues faster and simpler. This document provides a practical example of **using an Azure Container Instance (ACI) for DNS troubleshooting**. 

## Theoretical part

### Networking
Azure Container Instances offers two primary networking modes:

- **Public IP mode**  
  Assigns each container group its own dynamic public IP and FQDN. Inbound traffic can reach containers directly over the internet. Outbound traffic uses SNAT, with a limited pool of ephemeral ports per group.  

- **Virtual Network (VNet) integration**  
  Injects container groups into a user-specified subnet, giving them private RFC 1918 addresses. You can apply subnet-level Network Security Groups and route tables, but container groups themselves cannot host NSGs or UDRs.  

Networking limitations common to both modes:

- Only one virtual NIC per container group  
- No support for multiple IPs, custom CNI plugins, or service meshes  
- No internal load-balancer—cross-group traffic uses direct IPs or your own LB in front  

### Quotas
Resource assignment and subscription limits ensure predictable performance:

- **vCPU and memory per container**  
  You choose from predefined sizes (0.5 – 4 vCPUs in 0.5-vCPU steps; 0.5 – 14 GiB RAM). Each container group can bundle up to 60 containers sharing those limits.  

- **Ephemeral storage**  
  Every group includes up to 50 GiB of temporary SSD storage for `/tmp` and container layers.  

- **Subscription and region caps**  
  Default quotas vary by region but typically start around 350 container groups, 200 vCPUs, and 3 600 GiB RAM per subscription. You can request increases via Azure Support.  

- **Outbound port capacity**  
  Each container group gets a pool of ~512 SNAT ports for external calls; heavy outbound workloads may exhaust this pool.  

### Compatibility

ACI is designed for broad container workloads but omits certain advanced features:

- **OS support**  
  Linux and Windows Server containers are both supported, though Windows workloads only run on Windows-enabled subnets and have smaller regional footprints.  

- **Image registries**  
  Native pull support for Azure Container Registry, Docker Hub, and any private OCI-compliant registry with basic auth.  

- **Unsupported features**  
  No GPU/FPGA SKUs, no privileged or host-networked containers, and no ability to tweak kernel capabilities. Init containers are in preview only.  

- **Storage integrations**  
  You can mount Azure Files shares as volumes; block storage and host-path mounts aren’t available.  

## Prerequisites

Before you begin, ensure you have:

- Active Azure subscription
- Configured [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/get-started?tabs=azurecli)

All deployments must occur in the **same Azure region** to allow cross-resource-group networking.

## Practical part

In this tutorial Microsoft Container Registry will be used(instead of Docker Hub). Docker Hub has [**anonymous image pulls limits**](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-container-instances/configuration-setup/docker-hub-rate-limit-registryerrorresponse) that can cause deployment failures.

As a base `mcr.microsoft.com/azurelinux/base/nginx:1.25` image will be used. To make DNS queries bind-utils need to be installed.

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

### 2. Configure VNet

If you already have existing VNet, to which you want to deploy a container instance, use following script:
```bash
export VNET_RG=""
export VNET_NAME=""
export SUBNET_NAME=""

# Delegate the subnet to Azure Container Instances
az network vnet subnet update \
  --resource-group $VNET_RG \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --delegations Microsoft.ContainerInstance/containerGroups
```

If not, create a new VNet:
```bash
# Virtual network and subnet settings
export VNET_RG="VNET-${SUFFIX}"
export VNET_NAME="aci-vnet"
export SUBNET_NAME="aci-subnet"
export VNET_PREFIX="10.0.0.0/16"
export SUBNET_PREFIX="10.0.0.0/24"

# Create VNet resource group
az group create --name $VNET_RG --location $LOCATION

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

### 3. Deploy the Container

```bash
# Create Constainer Instances resource group
az group create --name $ACI_RG --location $LOCATION

# Deploy a container
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

### Use the container

Once the container is running, you can connect to container and install required packages:

```bash
# Enter the container
az container exec --resource-group $ACI_RG --name $ACI_NAME --exec-command "/bin/sh"

# Install package for DNS
tdnf update -y; tdnf install -y iputils bind-utils
```

Below you can find the example, which shows how you can:
1. Enter the container
2. Check that required packages are installed
3. Try to resolve DNS record internally (by using internal DNS resolver)
4. Try to resolve DNS record externally
5. Try to make a simple HTTP request

![](/images/docker/aci_dns_check.png)

### Cleanup
After troubleshooting you can delete created resources:

```bash
# Delete both resource groups (irrecoverable)
az group delete --name $ACI_RG --yes
az group delete --name $VNET_RG --yes
```

## Summary

Deploying an Azure Container Instance into a private virtual network gives you a lightweight, on-demand environment for network diagnostics without the overhead of managing full virtual machines. By delegating a subnet and assigning a private IP to your container group, you leverage Azure’s built-in security controls—such as network security groups, subnet isolation, and zero-trust networking—while maintaining consistent resource management across networking and compute components.

Azure Container Instances delivers rapid, on-demand troubleshooting containers with native VNet support (NSGs, private IPs, subnet delegation), removes the need for jump boxes or NAT gateways, eliminates VM or orchestrator management, and uses pay-as-you-go billing for maximum cost efficiency.

However, Azure Container Instances doesn’t support ICMP traffic (so ping and traceroute won’t work), relies on its native tdnf Linux repository which may lack needed diagnostic tools, and is stateless by default so any files or custom configurations are lost on restart.

# Deploy Azure Container Instance in a Private VNet for Network Troubleshooting

This guide demonstrates how to deploy an Azure Container Instance (ACI) into a private Virtual Network (VNet) using the Linux-based NGINX image `mcr.microsoft.com/azurelinux/base/nginx:1.25`. You’ll learn the theoretical benefits of ACI-VNet integration, **use cases** for private container deployments, and step-by-step instructions to create resources, deploy the container, install utilities with the **tdnf** package manager, troubleshoot network connectivity, and clean up resources.  
We preserve all original scripts and underscore that you can place the VNet and the ACI in **different resource groups**, as long as they reside in the same Azure region.

---

## Azure Container Instances and Virtual Network Integration

### Theoretical Overview

Deploying container groups into a private VNet enables **secure, private communication** between your containers and other Azure or on-premises resources. Azure Container Instances abstracts underlying compute infrastructure, allowing you to run containers without managing virtual machines or orchestrators. When integrated with a VNet, your ACI workloads can leverage Azure’s networking capabilities—**subnet delegation**, **network security groups (NSGs)**, and **private IP addressing**—to enforce zero-trust and isolate traffic. This combination removes the need for a jump box or NAT gateway for container-to-container communication, streamlining both deployment and operations.

### Use Cases and Scenarios

Common scenarios for deploying ACI into a private VNet include:

- Container-to-container communication in multi-tier architectures  
- Hybrid connectivity via VPN or ExpressRoute  
- Transient microservices testing in isolated environments  
- Network diagnostics and troubleshooting workshops  
- Secure on-demand batch processing without public exposure  

These use cases illustrate how private VNet integration enhances security, reduces operational complexity, and accelerates troubleshooting.

---

## Prerequisites

Before you begin, ensure you have:

- Azure CLI **version 2.40.0** or later installed  
- An **Azure subscription** with sufficient quota for ACI and networking  
- Two **resource groups** (may be the same or different):  
  - VNet resource group (e.g., `myVNetRG`)  
  - ACI resource group (e.g., `myACIResourceGroup`)  
- A **delegated subnet** for Container Instances  
- Familiarity with the **tdnf** package manager on Azure Linux  
- Permissions to create and delete Azure resources  

All deployments must occur in the **same Azure region** to allow cross-resource-group networking.

---

## Deployment Steps

### 1. Define Environment Variables

```bash
# Random suffix for resource names
export RANDOM_ID="$(openssl rand -hex 3)"

# Resource group names (can be different)
export VNET_RG="myVNetRG${RANDOM_ID}"
export ACI_RG="myACIResourceGroup${RANDOM_ID}"

# Virtual network and subnet settings
export VNET_NAME="aci-vnet"
export SUBNET_NAME="aci-subnet"
export VNET_PREFIX="10.0.0.0/16"
export SUBNET_PREFIX="10.0.0.0/24"

# Container instance settings
export ACI_NAME="appcontainer${RANDOM_ID}"
export IMAGE="mcr.microsoft.com/azurelinux/base/nginx:1.25"
```

These variables provide a **consistent naming convention** and reduce hard-coding in subsequent commands.

### 2. Create Resource Groups and VNet

```bash
# Create the resource groups
az group create --name $VNET_RG --location eastus
az group create --name $ACI_RG --location eastus

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

### 3. Deploy the Container Instance into the Private VNet

```bash
az container create \
  --resource-group $ACI_RG \
  --name $ACI_NAME \
  --image $IMAGE \
  --vnet $VNET_NAME \
  --subnet $SUBNET_NAME \
  --resource-group $VNET_RG
```

> **Note:** You must reference the VNet’s **resource group** (`$VNET_RG`) using the `--resource-group` parameter for the `--vnet` option, because your VNet lives in a different group.

This command provisions a container group with a **private IP address** on the specified subnet.

---

## Installing Utilities within the Container

Once the container is running, you can install network troubleshooting tools using the **tdnf** package manager:

```bash
# Enter the container
az container exec --resource-group $ACI_RG --name $ACI_NAME --exec-command "/bin/sh"

# Inside the container shell:
tdnf install -y iputils bind-utils procps-ng curl

# Verify commands:
ping -c 3 <TARGET_IP>
dig example.com +short
curl -v http://<SERVICE_PRIVATE_IP>
```

- **`iputils`** provides `ping` and `tracepath`;  
- **`bind-utils`** offers `dig` for DNS resolution;  
- **`procps-ng`** delivers `ps` and `top`;  
- **`curl`** tests HTTP endpoints.  

These tools enable in-container diagnostics to verify connectivity, DNS resolution, and HTTP access.

---

## Network Troubleshooting Methods

1. **Ping** the gateway, other container instances, or VNet appliances.  
2. **dig** DNS lookups to confirm private DNS zones and private endpoint records.  
3. **curl** HTTP(S) requests to web services or sidecars on private IPs.  
4. **ps** and **top** to inspect running processes for unexpected restarts or crashes.

By combining **in-container checks** with Azure’s **Network Watcher** or **NSG flow logs**, you can pinpoint issues with routing, DNS, or firewall rules.

---

## Cleanup Instructions

To avoid unnecessary costs, delete the resources you created:

```bash
# Delete both resource groups (irrecoverable)
az group delete --name $ACI_RG --yes
az group delete --name $VNET_RG --yes
```

This step ensures all VNets, subnets, container groups, and related resources are removed.

---

## Summary

Deploying an **Azure Container Instance** into a **private VNet** provides secure, scalable, and ephemeral compute for network troubleshooting and microservice scenarios. By delegating a subnet, leveraging **private IP addressing**, and using the **tdnf** package manager within Azure Linux containers, you gain the ability to install essential diagnostics tools—**ping**, **dig**, **curl**—and perform end-to-end connectivity checks. This pattern supports independent resource group management for networking and compute, streamlines your diagnostics workflows, and maintains a consistent, secure environment for transient container workloads.

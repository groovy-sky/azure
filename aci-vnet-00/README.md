# Deploy Azure Container Instance in a Private VNet for Network Troubleshooting

This guide shows how to deploy an Azure Container Instance (ACI) into a private Virtual Network (VNet) using the Linux-based NGINX image `mcr.microsoft.com/azurelinux/base/nginx:1.25`. After deployment, you’ll connect to the container shell, install `bind-dnssec-utils`, and run network troubleshooting commands (`ping`, `dig`, `traceroute`, `tcpdump`) from within the container to diagnose DNS resolution, connectivity, routing, and packet flow issues.

## Theoretical part

### What is Azure Container Instance?

Azure Container Instances (ACI) is a serverless container service provided by Microsoft Azure. It enables users to run containers in the cloud without managing virtual machines or a complex orchestration service. ACI offers rapid deployment, flexible resource allocation (CPU and memory), and supports both Linux and Windows containers. You only pay for what you use, making it suitable for development, testing, microservices, APIs, and event-driven processing.

**Key features:**
- Serverless operation (no infrastructure management)
- Rapid startup (containers start in seconds)
- Flexible sizing (custom CPU/memory per container group)
- Public and private IP options


### Integration with Azure Virtual Network (VNet)

By default, ACI containers are deployed with public IPs, exposing them to the internet. To enable secure, internal communications, ACI supports deploying containers into an Azure Virtual Network (VNet).

**Benefits:**
- Private IP addressing for containers
- Network isolation from the public internet
- Custom DNS and routing within the VNet

**How it works:**
- Create a subnet in your VNet and delegate it to the Microsoft.ContainerInstance/containerGroups service.
- Specify the VNet and subnet when deploying a container group.
- ACI assigns a private IP from the subnet to the container group.
- Containers can communicate with other resources in the VNet according to network security rules.

**Limitations:**
- Only container groups (not individual containers) are supported in a VNet.
- No inbound public connectivity unless a load balancer or NAT gateway is configured.
- Some features (like GPU containers) may be limited with VNet integration.

## Prerequisites

- **Active Azure Subscription**  
  You need an active subscription. If you don’t have one, [create a free account](https://azure.microsoft.com/free/).

- **Azure CLI**  
  Install and sign in to the Azure CLI.  
  ```bash
  az login
  ```

- **Required CLI Extensions**  
  Ensure you have the Container Instances extension (if needed).  

- **jq** (optional)  
  A tool for parsing JSON output from `az` commands.



## Practical Part

### Initial deployment

Deploy with VNet creation:

```bash

# Set the resource group name and Azure location.
export RG_NAME="aci-vnet-rg"
export LOCATION="westeurope"

# Create a new resource group in the specified location.
az group create \
  --name $RG_NAME \
  --location $LOCATION

# Set the names for the virtual network and subnet.
export VNET_NAME="aci-vnet"
export SUBNET_NAME="aci-subnet"

# Create a virtual network with a subnet for ACI; assign address spaces.
az network vnet create \
  --resource-group $RG_NAME \
  --name $VNET_NAME \
  --location $LOCATION \
  --address-prefix 10.1.0.0/16 \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix 10.1.0.0/24

# Delegate the subnet to Azure Container Instances, so only container groups can use it.
az network vnet subnet update \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --delegations "Microsoft.ContainerInstance/containerGroups"

# Set the container group name and image version.
export ACI_NAME="nginx-acivnet"
export IMAGE="mcr.microsoft.com/azurelinux/base/nginx:1.25"

# Deploy NGINX container into the delegated subnet with no public IP assigned.
az container create \
  --resource-group $RG_NAME \
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

Deploy to exsisting VNet:
```bash
# Resource group for the container instance
export RG_NAME="aci-rg"
export LOCATION="westeurope"

az group create \
  --name $RG_NAME \
  --location $LOCATION

# Resource group, VNet, and subnet for the network (can be different!)
export VNET_RG="aci-vnet-rg"
export VNET_NAME="aci-vnet"
export SUBNET_NAME="aci-subnet"

# Image parameters
export ACI_NAME="nginx-acivnet"
export IMAGE="mcr.microsoft.com/azurelinux/base/nginx:1.25"


# Create the container in its own resource group, referencing the subnet in another resource group
az container create \
  --resource-group $RG_NAME \
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

### Necessary utilities installation

After container is running you can connect to it:
```
# Retrieve the container's private IP from Azure.
ACI_IP=$(az container show \
  --resource-group $RG_NAME \
  --name $ACI_NAME \
  --query "ipAddress.ip" \
  --output tsv)

# Display the assigned private IP for the container.
echo "Container IP: $ACI_IP"

# Start an interactive shell session inside the running container.
az container exec \
  --resource-group $RG_NAME \
  --name $ACI_NAME \
  --exec-command "/bin/sh"
```

Inside the container’s shell, install the necessary utilities:

```bash
# Refresh package metadata
tdnf update -y

# Install DNSSEC utilities for dig and dnssec tools
tdnf install -y bind-dnssec-utils
```



### Network Troubleshooting

Test DNS resolution through the custom VNet DNS settings:

```bash
# Test resolution of internal records
dig +short internal-service.local

# Test resolution of public records
dig +short www.microsoft.com

# Use a specific DNS server (e.g., Azure 168.63.129.16)
dig @168.63.129.16 +short www.example.com
```


### Cleanup

- After troubleshooting, you can delete the container group to avoid charges:

  ```bash
  az container delete --resource-group $RG_NAME --name $ACI_NAME -y
  ```

- If you no longer need the VNet or resource group:

  ```bash
  az group delete --name $RG_NAME -y
  ```


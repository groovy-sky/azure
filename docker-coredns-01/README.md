# 
## Introduction

Azure Private endpoint is the fundamental building block for Private Link in Azure. It enables Azure resources, like virtual machines (VMs), to communicate with Private Link resources privately. 

This document gives an example of using 

## Theoretical Part

### Terminology

If you're new to Azure Private Endpoints, there are some terms you might not be familiar with:

* **Public Azure Resource/Service** - a manageable item that is available through Azure. Virtual machines, storage accounts, web apps, databases, and virtual networks are examples of resources.
  ![](/images/network/res_symbol.png)

* **Private Endpoint** - an Azure service, which allows to access publicly available resources privately
  ![](/images/network/endpoint_symbol.png)

* **Virtual Network** - enables Azure resources, such as VMs, web apps, and databases, to communicate with each other.
  ![](/images/network/vnet_symbol.png)

* **Network Interface Card** - allows Azure resources to be a part of a specific Virtual Network, by allocating a private IP address 
  ![](/images/network/nic_symbol.png)

* **Private DNS Zone** - used to host the DNS records for a particular domain and are accessible from one or multiple Virtual Networks
  ![](/images/network/dns_symbol.png)

### Overview

Endpoint is a special kind network interface that connects you privately and securely to a service powered by Azure Private Link. Private Endpoint uses a private IP address from a VNet. 

![](/images/network/priv_end_struct.png)

Here are some key details about private endpoints:
1. Network connections can only be initiated by clients connecting to the Private endpoint, Service providers do not have any routing configuration to initiate connections into service consumers. Connections can only be established in a single direction.
2. When creating a private endpoint, a read-only network interface is also created for the lifecycle of the resource. The interface is assigned dynamically private IP addresses from the subnet that maps to the private link resource. The value of the private IP address remains unchanged for the entire lifecycle of the private endpoint.
3. A private endpoint consist of the following resources: a **private endpoint** itself, a **network interface** and (if DNS integration is used) a **DNS record** in resource's private DNS zone.

It is important to note that to be able access a public resource privately, you'll need to correctly configure your DNS settings to resolve to the allocated private IP address. Existing Azure services might already have a DNS configuration to use when connecting over a public endpoint. This needs to be overridden to connect using your private endpoint.

## Prerequisites
## Practical Part

This sample demonstrates how to create a Linux Virtual Machine in a virtual network that can privately accesses [Azure File Share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) Gen 2 blob storage account using an Azure Private Endpoint. 




<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure-coredns%2Fmaster%2Fazure%2Fprivate-endpoints%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>

The ARM template deploys the following resources:

![](/images/network/priv_end_arch_00.png)

1. The Virtual Machine submits a DNS query for the FQDN of the xxx.file.core.windows.net storage account to the default DNS server (which is 168.63.129.16)
2. 

When creating a Private Endpoint, the related A record will automatically be created in the target Private DNS Zone with the private IP address of the network interface associated to the Private Endpoint and the name of the Azure resource referenced by the Private Endpoint

When you create a private endpoint, the DNS CNAME resource record for the storage account is updated to an alias in a subdomain with the prefix privatelink. By default, we also create a private DNS zone, corresponding to the privatelink subdomain, with the DNS A resource records for the private endpoints.

When you resolve the storage endpoint URL from outside the VNet with the private endpoint, it resolves to the public endpoint of the storage service. When resolved from the VNet hosting the private endpoint, the storage endpoint URL resolves to the private endpoint's IP address.


The ARM template uses the Azure Custom Script Extension to download and run the following Bash script on the virtual machine. The script performs the following steps:

A private endpoint is a special network interface for an Azure service in your Virtual Network (VNet). When you create a private endpoint for your storage account, it provides secure connectivity between clients on your VNet and your storage. The private endpoint is assigned an IP address from the IP address range of your VNet. The connection between the private endpoint and the storage service uses a secure private link.

Applications in the VNet can connect to the storage service over the private endpoint seamlessly, using the same connection strings and authorization mechanisms that they would use otherwise. Private endpoints can be used with all protocols supported by the storage account, including REST and SMB.

Private endpoints can be created in subnets that use Service Endpoints. Clients in a subnet can thus connect to one storage account using private endpoint, while using service endpoints to access others.

When you create a private endpoint for a storage service in your VNet, a consent request is sent for approval to the storage account owner. If the user requesting the creation of the private endpoint is also an owner of the storage account, this consent request is automatically approved.

You can secure your storage account to only accept connections from your VNet, by configuring the storage firewall to deny access through its public endpoint by default. You don't need a firewall rule to allow traffic from a VNet that has a private endpoint, since the storage firewall only controls access through the public endpoint. Private endpoints instead rely on the consent flow for granting subnets access to the storage service.

## Results
## Summary
## Related Information
* https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview
* https://github.com/paolosalvatori/private-endpoints-topologies
* https://github.com/dmauser/PrivateLink
* https://docs.microsoft.com/en-us/azure/azure-app-configuration/concept-private-endpoint
* https://github.com/Azure/azure-quickstart-templates/tree/master/201-file-share-private-endpoint
* https://github.com/Azure/azure-quickstart-templates/tree/master/201-private-aks-cluster
* https://github.com/Azure/azure-quickstart-templates/tree/master/custom-private-dns
* https://docs.microsoft.com/en-us/azure/architecture/hybrid/hybrid-dns-infra
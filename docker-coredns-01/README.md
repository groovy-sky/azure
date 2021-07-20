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

The ARM template deploys the many resources, which could be logically separeted in 3 parts:

1. Public resource, which in this example is a storage account
2. Resources for exposing the public resource privately (NIC, private endpoint, VNet, private DNS)
3. Virtual Machine, which will be deployed in the same VNet as the private endpoint is used

![](/images/network/priv_end_arch_00.png)

During the template deployment, custom script will be executed on Virtual Machine. It will tries to resolve file shares IP address (using nslookup command). VM will use [Azure default DNS server](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16) to resolve any kind of records, which by default has 168.63.129.16 IP address. So nslookup execution will cause following query flow:

![](/images/network/priv_end_arch_01.png)

1. Virtual Machine submits a DNS query for the FQDN of the `<account name>.file.core.windows.net` storage account to the default DNS server (which is `168.63.129.16`)
2. As private endpoint is published in the same VNet where Virtual Machine and private zone are published, then query will be forwarded to the private zone.
3. During private endpoint's creation the DNS CNAME resource record for the storage account is updated to an alias in a subdomain with the prefix privatelink (which in this example is privatelink.file.core.windows.net) and A type record (which points to private endpoints IP address). 

A private endpoint is a special network interface for an Azure service in your Virtual Network (VNet). When you create a private endpoint for your storage account, it provides secure connectivity between clients on your VNet and your storage. The private endpoint is assigned an IP address from the IP address range of your VNet. The connection between the private endpoint and the storage service uses a secure private link.

When you resolve the storage endpoint URL from outside the VNet with the private endpoint, it resolves to the public endpoint of the storage service. When resolved from the VNet hosting the private endpoint, the storage endpoint URL resolves to the private endpoint's IP address.

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

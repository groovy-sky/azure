# Restricting access to Storage Account

## Introduction

Most Azure Platform-as-a-Services (PaaS) have a public endpoint that is accessible through the internet. You can limit public access to your service or even fully close it, by using different kinds of technologies

One of the key challenges of using publicly available PaaS is to secure the data stored in it. In this article, we will discuss various techniques for limiting access to Azure Storage accounts.

## Overview

Azure Storage Account is a cloud-based storage service, which provides various features:

![](/images/network/storage_classification.png)

Any Azure Storage account has a publicly available DNS name:

| Storage service  |	Endpoint |
| --- | --- |
| Blob Storage 	| `https://<storage-account-name>.blob.core.windows.net` |
| Data Lake Storage Gen2 | `https://<storage-account-name>.dfs.core.windows.net` |
| Azure Files |	`https://<storage-account-name>.file.core.windows.net` |
| Queue Storage | `https://<storage-account-name>.queue.core.windows.net` |
| Table Storage | `https://<storage-account-name>.table.core.windows.net` |
| Static Website | `https://<storage-account-name>.z<number>.web.core.windows.net` |

As a storage account name has public DNS, each of them must be unique within Azure. No two storage accounts can have the same name. A Storage account can be configured with one of the following restrictions:

1. No restrictions [Default]
2. Allow access from specific public IPs and/or Azure Vnets
3. Deny public access

## Prerequisites

In this tutorial we'll use **Locally Redundant Standard Azure Storage Account V2 in West Europe** as a demonstration environment:

![](/images/network/storage_v2_example.png)


## Storage account with no restrictions

By default, after storage was created with default parameters, there are no network restrictions:

![](/images/network/storage_net_default.png)

Even though for this scenario the storage is available for all IPs it is possible to improve security by:

* Require [secure transfer](https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer) (rejects HTTP) and [enforce a minimum required TLS version](https://learn.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version?tabs=portal)
* [Deny anonymous public read access to blob containers](https://learn.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-prevent?tabs=portal)
* [Deny SAS key access](https://learn.microsoft.com/en-us/azure/storage/common/shared-key-authorization-prevent?tabs=portal) or set [an expiration policy for it](https://learn.microsoft.com/en-us/azure/storage/common/sas-expiration-policy?tabs=azure-portal&WT.mc_id=Portal-Microsoft_Azure_Storage)

All of these settings you can find under 'Configuration' section:

![](/images/network/az_storage_sec_conf.png)

## IP/VNet restriction

Turning on firewall rules for your storage account blocks incoming requests for data by default unless the requests originate from allowed public IP addresses or private Azure VNet's subnets:

![](/images/network/storage_net_limit.png)

Pros: 

* Improved Security: Access Restriction helps to secure your PaaS services by allowing you to restrict access to only those who have authorized access. 
* Easy to Configure: Access Restriction can be easily configured using the Azure portal, Azure PowerShell or Azure CLI. 
* Cost-effective: No additional cost is applied to the service, as it does not require any additional resources or infrastructure to be set up.

Cons: 
* Manual IP/VNet management: Each new IP address/VNet should be whitelisted separately
* Limited rule number: Maximum number of IP/VNet rules is 200 for each
* IP restriction can't be used for a resource from the same region as a storage account
* VNet restriction can be applied to Azure environment only

### Restriction by IP

You can use [IP network rules](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal#grant-access-from-an-internet-ip-range) to allow access from specific public internet IP address ranges by creating IP network rules. These rules grant access to specific internet-based services and on-premises networks and block general internet traffic. IP restrictions features/limitations:

* Supports [IPv4](https://datatracker.ietf.org/doc/html/rfc791) only
* Not available for [Private IPs](https://datatracker.ietf.org/doc/html/rfc1918#section-3) 
* Maximum 200 rules
* Small ranges (/31 or /32) are not supported
* <span style="color:red">Can't be accessed from Azure resources, located in the same region.</span> Services deployed in the same region as the storage account use private Azure IP addresses for communication. So, you can't restrict access to specific Azure services based on their public outbound IP address range.

For our demo storage IP restrictions will not work  only if requests come from public IPs which belong to West Europe region:

![](/images/network/az_strg_rest_01.png)


### Restriction by VNet

Virtual network restriction (aka Service Endpoints) allows you to secure Azure Storage accounts to a virtual network over an optimized route over the Azure backbone network. VNet restrictions features/limitations:
* <span style="color:red">Works for Azure environment only</span>(for example, not possible to use from on-premises as Azure VNet is required)
* Maximum 200 rules
* Supports [cross-region access](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal#azure-storage-cross-region-service-endpoints)
* Access is granted on a subnet level
* Not all Azure resources [support service endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)

This is what it looks like from the practical point of view for our demo storage:

![](/images/network/az_strg_rest_02.png)

## Fully restricted (No Public Access)

In some cases you may not need any access at all - for example, an unmanaged storage disk doesn't require an access:

![](/images/network/storage_disable.png)

If you want to continue to use your service with disabled public access - you can use Private Endpoints.

### Private Endpoints

Storage firewall rules apply to the public endpoint of a storage account. You don't need any firewall access rules to allow traffic for private endpoints of a storage account. The process of approving the creation of a private endpoint grants implicit access to traffic from the subnet that hosts the private endpoint.

![](/images/network/storage_net_priv_endpoint.png)

Pros: 
* Improved Security: You can keep your data and applications private, even if they are hosted in a public cloud environment. 
* Reduced Latency: With Azure Private Endpoints, you can reduce the latency between your applications and data by keeping them within the same network.

Cons: 
* Additional Cost: Private Endpoints applies additional cost 
* Additional Configuration: Setting up Private Endpoints can be complex and requires additional configuration (initial deploy creates private endpoint, network interface card attached to it and Private DNS Zone)
* Cloud only: By default Private Endpoints are available only from Azure. It is possible to expose Private Endpoints to on-prem, but it requires to setup additional environment (private connection between Azure and On-Premises and Azure Private DNS Resolver) for on-premises access.
* Storage Accounts V1 are not supported

In our example, demo storage with disabled access and a private endpoint looks following:

![](/images/network/az_strg_rest_03.png)


## Summary

Azure allows you to access your PaaS in various ways:

1. No restrictions - default state, which exposes your resource to everyone.
2. Restriction by IP works only for public IPs, located in non-Azure environments or/and different from PaaS Azure regions. 
3. Restriction by VNet (aka Service Endpoints) - works only for Azure VNet, i.e. for Azure private IPs in any region. More detailed explanation you can read [here](/paas-vnet-00/README.md).
4. Fully closed access will block all incoming requests, but Private Endpoints allow to expose your PaaS to an Azure VNet and access from it. More detailed explanation you can read [here](/paas-vnet-01/README.md). 

![](/images/network/storage_net_access_arch.png) 

Short summary of each solution:

| ![](/images/network/az_strg_rest_meter_00.png) |  ![](/images/network/az_strg_rest_meter_01.png) | ![](/images/network/az_strg_rest_meter_02.png) | 
| --- | --- | --- |
|  · Less secure </br> · No need to configure |  · Imporved security </br> · No extra charge </br> · Maximum 200 rules </br> · IP restriction doesn't work for Azure resource in the same region | · Most secure </br> · Requires additional environment for access (extra complexety and cost) |

For those who aren't sure which way to go, you can try the following flow:

![](/images/network/storage_net_flow.png) 

## Related Information

* https://learn.microsoft.com/en-us/azure/storage/common/storage-introduction

* https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal
# Access limit to PaaS 

## Introduction

Most Azure Platform-as-a-Services (PaaS) have a public endpoint that is accessible through the internet. You can limit public access to your service or even fully close it, by using differenet kind of technologies

One of the key challenges of using publicly available PaaS is to secure data stored in it. In this article, we will discuss various techniques for limiting access to PaaS, by using as an example, Azure Storage service.

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

As a storage account name has public DNS, each of it must be unique within Azure. No two storage accounts can have the same name. 

So, let's say you have created a **Locally Redundant Standard Azure Storage Account V2 in West Europe**:

![](/images/network/storage_v2_example.png)


By default, it has no network restrictions:

![](/images/network/storage_net_default.png)

For the Storage account can be configured one of the following restrictions:

1. No limitation for incoming IP address [Default]
2. Limit access and allow from specific public IP addresses and/or Azure Vnets
3. Fully close public access

### No restrictions

Even though for this scenario the storage is avaialable for all IPs, 
there are a few things to improve:

* Require [secure transfer](https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer) (by rejecting HTTP) and [enforce a minimum required TLS version](https://learn.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version?tabs=portal)
* [Deny anonymous public read access to blob containers](https://learn.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-prevent?tabs=portal)
* [Deny SAS key access](https://learn.microsoft.com/en-us/azure/storage/common/shared-key-authorization-prevent?tabs=portal) or set [expiration policy for it](https://learn.microsoft.com/en-us/azure/storage/common/sas-expiration-policy?tabs=azure-portal&WT.mc_id=Portal-Microsoft_Azure_Storage)

All of these settings you can find under 'Configuration' section:

![](/images/network/az_storage_sec_conf.png)

### IP/VNet restriction

Turning on firewall rules for your storage account blocks incoming requests for data by default, unless the requests originate from allowed public IP addresses or private Azure VNet's subnets:

![](/images/network/storage_net_limit.png)

#### Restriction by IP

You can use [IP network rules](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal#grant-access-from-an-internet-ip-range) to allow access from specific public internet IP address ranges by creating IP network rules. These rules grant access to specific internet-based services and on-premises networks and block general internet traffic. IP restictions features/limitations:

* Supports [IPv4](https://datatracker.ietf.org/doc/html/rfc791) only
* Not available for [Private IPs](https://datatracker.ietf.org/doc/html/rfc1918#section-3) 
* Maximum 200 rules
* Small ranges (/31 or /32) are not supported
* <span style="color:red">Can't be accessed from Azure resources, located in the same region.</span> Services deployed in the same region as the storage account use private Azure IP addresses for communication. So, you can't restrict access to specific Azure services based on their public outbound IP address range.

This is how it looks like from the practical point of view for our demo storage:

![](/images/network/az_strg_rest_01.png)

#### Restriction by VNet

Virtual network restriction (aka Service Endpoints) allows you to secure Azure Storage accounts to a virtual network over an optimized route over the Azure backbone network. VNet restictions features/limitations:
* <span style="color:red">Works for Azure environment only</span>(for example, not possible to use from on-premises)
* Maximum 200 rules
* Supports [cross-region access](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal#azure-storage-cross-region-service-endpoints)
* Access is granted on a subnet level
* Not all Azure resources [supports service endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)

This is how it looks like from the practical point of view for our demo storage:

![](/images/network/az_strg_rest_02.png)

### No Public Access

Storage firewall rules apply to the public endpoint of a storage account. You don't need any firewall access rules to allow traffic for private endpoints of a storage account. The process of approving the creation of a private endpoint grants implicit access to traffic from the subnet that hosts the private endpoint.

![](/images/network/storage_net_priv_endpoint.png)

Private Endpoints enable you to access your storage account over a private endpoint in your virtual network, instead of over the public internet. This provides a more secure and reliable way to access your data. 
To set up Private Endpoints for your PaaS, you need to create a virtual network in the Azure portal, and then create a Private Endpoint for your storage account. Once you've done this, you can connect to your storage account using the Private Endpoint and access your data securely. 


### Fully disable public access  

![](/images/network/storage_disable.png)



Virtual machine disk traffic (including mount and unmount operations, and disk IO) is not affected by network rules. REST access to page blobs is protected by network rules.

## Summary

![](/images/network/storage_net_access_overview.png)

| | | |
| --- | --- | --- |
| ![](/images/network/az_strg_rest_meter_00.png) |  ![](/images/network/az_strg_rest_meter_01.png) | ![](/images/network/az_strg_rest_meter_02.png) | 
| | | |



Pros: 

* Improved Security: Access Restriction helps to secure your PaaS services by allowing you to restrict access to only those who have authorized access. 
* Easy to Configure: Access Restriction can be easily configured using the Azure portal, Azure PowerShell or Azure CLI. 
* Cost-effective: No additional cost is applied to the service, as it does not require any additional resources or infrastructure to be set up.

Cons: 
* Manual IP management: Each new IP address/range should be whitelisted separately (outdated IP cleanup also requires manual work)
* Limited rule number: Maximum number of IP/VNet rules is 200 for each

VNet restriction

Pros: 
* Improved Security: You can keep your data and applications private, even if they are hosted in a public cloud environment. 
* Reduced Latency: With Azure Private Endpoints, you can reduce the latency between your applications and data by keeping them within the same network.

Cons: 
* Additional Cost: Private Endpoints applies additional cost 
* Additional Configuration: Setting up Private Endpoints can be complex and requires additional configuration (initial deploy creates private endpoint, network interface card attached to it and Private DNS Zone)
* Cloud only: By default Private Endpoints are available only from Azure. It is possible to expose Private Endpoints to on-prem, but it requires to setup additional environment (private connection between Azure and On-Premises and Azure Private DNS Resolver) for on-premises access.
* Storage Accounts V1 are not supported

https://learn.microsoft.com/en-us/azure/storage/common/storage-introduction

https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal
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

So, let's say you have created new Locally Redundant Standard Azure Storage Account V2:

![](/images/network/storage_v2_example.png)


By default, it has no network restrictions:

![](/images/network/storage_net_default.png)

For a Storage account exsist 3 restriction modes:

![](/images/network/az_strg_rest_meter.png)

1. No limitation for incoming IP address [Default]
2. Limit access and allow from specific public IP addresses and/or Azure Vnets
3. Fully close public access

## No restrictions

![](/images/network/az_strg_rest_00.png)


## IP restriction

![](/images/network/az_strg_rest_01.png)


Turning on firewall rules for your storage account blocks incoming requests for data by default, unless the requests originate from a service operating within an Azure Virtual Network (VNet) or from allowed public IP addresses. Requests that are blocked include those from other Azure services, from the Azure portal, from logging and metrics services, and so on.

Access Restriction is a powerful and cost-effective solution for securing your Azure PaaS services. This feature allows you to control access to your storage account based on the IP addresses or/and Azure VNet that can access it:

![](/images/network/storage_net_limit.png)

[Service Endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview) allows to secure access to Storage Account from certain virtual networks. Each storage account supports up to 200 subnets.

## VNet restriction

![](/images/network/az_strg_rest_02.png)

[Firewall rules](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-portal#grant-access-from-an-internet-ip-range) allows to access a Storage from specific public IP address ranges. Each storage account supports up to 200 rules.

Once network rules are applied, they're enforced for all requests. SAS tokens that grant access to a specific IP address serve to limit the access of the token holder, but don't grant new access beyond configured network rules.

Virtual machine disk traffic (including mount and unmount operations, and disk IO) is not affected by network rules. REST access to page blobs is protected by network rules.

Pros: 

* Improved Security: Access Restriction helps to secure your PaaS services by allowing you to restrict access to only those who have authorized access. 
* Easy to Configure: Access Restriction can be easily configured using the Azure portal, Azure PowerShell or Azure CLI. 
* Cost-effective: No additional cost is applied to the service, as it does not require any additional resources or infrastructure to be set up.

Cons: 
* Manual IP management: Each new IP address/range should be whitelisted separately (outdated IP cleanup also requires manual work)
* Limited rule number: Maximum number of IP/VNet rules is 200 for each

## No Public Access

![](/images/network/az_strg_rest_03.png)

Storage firewall rules apply to the public endpoint of a storage account. You don't need any firewall access rules to allow traffic for private endpoints of a storage account. The process of approving the creation of a private endpoint grants implicit access to traffic from the subnet that hosts the private endpoint.

![](/images/network/storage_net_priv_endpoint.png)

Private Endpoints enable you to access your storage account over a private endpoint in your virtual network, instead of over the public internet. This provides a more secure and reliable way to access your data. 
To set up Private Endpoints for your PaaS, you need to create a virtual network in the Azure portal, and then create a Private Endpoint for your storage account. Once you've done this, you can connect to your storage account using the Private Endpoint and access your data securely. 

Pros: 
* Improved Security: You can keep your data and applications private, even if they are hosted in a public cloud environment. 
* Reduced Latency: With Azure Private Endpoints, you can reduce the latency between your applications and data by keeping them within the same network.

Cons: 
* Additional Cost: Private Endpoints applies additional cost 
* Additional Configuration: Setting up Private Endpoints can be complex and requires additional configuration (initial deploy creates private endpoint, network interface card attached to it and Private DNS Zone)
* Cloud only: By default Private Endpoints are available only from Azure. It is possible to expose Private Endpoints to on-prem, but it requires to setup additional environment (private connection between Azure and On-Premises and Azure Private DNS Resolver) for on-premises access.
* Storage Accounts V1 are not supported

### Fully disable public access  

![](/images/network/storage_disable.png)

## Summary

In summary, IP/VNet restriction and Private Endpoints are two Azure features that provide a more secure and reliable way to access Azure services. By using these features, you can improve your data safety, but it will require additonal steps.


https://learn.microsoft.com/en-us/azure/storage/common/storage-introduction
# Restrict access to PaaS

## Introduction

As more and more organizations move their workloads to the cloud, the need for secure and reliable networking solutions has become increasingly important. Especially if are talking about Platform-as-a-Service (PaaS) protection.

In this article, will explore how you can limit network access to your PaaS by using an Azure Storage account as an example.

## Overview

So, let's say you have created a new Azure Storage Account V2 (as V1 doesn't support Private Endpoints):

![](/images/network/storage_v2_example.png)

By default, it has no network restrictions:

![](/images/network/storage_net_default.png)

Which means that your PaaS will be fully open to the internet. This means that anyone with the right credentials (like storage account key) can access your data. 

If you need to limit access to your environment you can:
1. Limit access to it from certain IP addresses (by using IP restriction) and/or VNets (by using Service Endpoints)
2. Expose access to PaaS privately (by using Private Endpoints)
3. Limit public and expose private accesses (combination of previous options)
4. Close public access and use Private Endpoints only

## Public access restriction

Access Restriction is a powerful and cost-effective solution for securing your Azure PaaS services. This feature allows you to control access to your storage account based on the IP addresses or/and Azure VNet that can access it:

![](/images/network/storage_net_limit.png)

[Service Endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)

Pros: 

* Improved Security: Access Restriction helps to secure your PaaS services by allowing you to restrict access to only those who have authorized access. 
* Easy to Configure: Access Restriction can be easily configured using the Azure portal, Azure PowerShell or Azure CLI. 
* Cost-effective: No additional cost is applied to the service, as it does not require any additional resources or infrastructure to be set up.

Cons: 
* Manual 
* Maximum number of IP address rules per storage account is 200
Maximum number of virtual network rules per storage account is 200

## Private access exposure

![](/images/network/storage_disable.png)

Private Endpoints enable you to access your storage account over a private endpoint in your virtual network, instead of over the public internet. This provides a more secure and reliable way to access your data. 
To set up Private Endpoints for your PaaS, you need to create a virtual network in the Azure portal, and then create a Private Endpoint for your storage account. Once you've done this, you can connect to your storage account using the Private Endpoint and access your data securely. 

Pros: 
* Improved Security: Azure Private Endpoints help to secure your data by allowing you to restrict access to resources to only those who have authorized access. This means that you can keep your data and applications private, even if they are hosted in a public cloud environment. 
* Reduced Latency: With Azure Private Endpoints, you can reduce the latency between your applications and data by keeping them within the same network.

Cons: 
* Additional Cost: Private Endpoints require additional resources
* Additional Configuration: Setting up Private Endpoints can be complex and requires additional configuration, which may require additional time and resources.
* Cloud only: By default Private Endpoints are available only from Azure. It is possible to expose Private Endpoints to on-prem, but it requires to setup additional environment (private connection between Azure and On-Premises and Azure Private DNS Resolver) for on-premises access.

# Summary

In summary, Virtual Network Service Endpoints and Private Endpoints are two Azure features that provide a more secure and reliable way to access Azure services over a private network connection. By using these features, you can keep your data safe and secure, and reduce your reliance on public IP addresses and NAT devices.
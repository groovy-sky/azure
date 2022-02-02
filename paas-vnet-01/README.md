# Integrate Platform as a Services with Virtual Networks (part 2)
## Introduction

As was stated [in the previous part](/paas-vnet-00/README.md), Service Endpoints can be used to expose some of Platfom as a Services (PaaS) privately. An alternative solution, though slightly more complicated is Private Endpoint service. It is a special network interface for an Azure service in your Virtual Network (VNet).

![](/images/network/paas_vnet_logo.png)

This document gives an example of using **Private Endpoints** for exposing a public Platform as a Service privately.

## Theoretical Part


### Private DNS Zone

Azure Private DNS provides a reliable, secure DNS service to manage and resolve domain names in a virtual network without the need to add a custom DNS solution. By using private DNS zones, you can use your own custom domain names rather than the Azure-provided names available today.

The records contained in a private DNS zone aren't resolvable from the Internet. DNS resolution against a private DNS zone works only from virtual networks that are linked to it.

![](/images/network/priv_dns_vnet_link.png)

After you create a private DNS zone in Azure, you'll need to link a virtual network to it. Once linked, VMs hosted in that virtual network can access the private DNS zone. Every private DNS zone has a collection of virtual network link child resources. Each one of these resources represents a connection to a virtual network. One private DNS zone can have multiple resolution virtual networks and a virtual network can have multiple resolution zones associated to it.

### Private Endpoint

You can use private endpoints for PaaS to allow clients on a Virtual Network (VNet) to securely access data over a private link. The Private Endpoint uses an IP address from the VNet address space. Optionally, you can use [a private DNS zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-overview) to be able to access a service using its Fully Qualified Domain Name (FQDN). The Network Interface Card (NIC) associated with the private endpoint contains the information required to configure your DNS. The information includes the FQDN and private IP address for a private link resource.

![](/images/network/priv_end_struct.png)

Here are some key details about private endpoints:
1. Network connections can only be initiated by clients connecting to the Private endpoint, Service providers do not have any routing configuration to initiate connections into service consumers. Connections can only be established in a single direction (Inbound).
2. When creating a private endpoint, a read-only NIC is also created for the lifecycle of the resource. The interface is assigned dynamically private IP addresses from the subnet that maps to the private link resource. The value of the private IP address remains unchanged for the entire lifecycle of the private endpoint.
3. A private endpoint consist of the following resources: a **Private Endpoint** itself, a **Network Interface Card** and (optionally) a DNS record in resource's **private DNS zone**.

It is important to note that to be able access a public resource privately, you'll need to correctly configure your DNS settings to resolve to the allocated private IP address. Existing Azure services might already have a DNS configuration to use when connecting over a public endpoint. This needs to be overridden to connect using your private endpoint.


## Prerequisites

To be able to run the next section you’ll need an Azure Cloud account.

## Practical Part

[This sample](https://github.com/groovy-sky/azure-coredns/blob/master/azure/private-endpoints/azuredeploy.json) creates a Storage Account and its Private Endpoint, VNET, private DNS Zone and Linux Virtual Machine. To start the deployment just click the button below:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure-coredns%2Fmaster%2Fazure%2Fprivate-endpoints%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>

 When you create a private endpoint for your storage account, it provides secure connectivity between clients on your VNet and your storage. The private endpoint is assigned an IP address from the IP address range of your VNet. The connection between the private endpoint and the storage service uses a secure private link. ARM template deploys multiple resources, which could be grouped to:

1. PaaS itself, which in this example is a storage account
2. Resources used for exposing the public resource privately (NIC, private endpoint, VNet, private DNS)
3. Virtual Machine, which will be deployed in the same VNet as the private endpoint and used to check if Private Endpoint is accessible

![](/images/network/priv_end_arch_00.png)

During initial template deployment, a custom script will be executed on the Virtual Machine (VM). It will resolve Storage Account's IP address using nslookup command. VM will use [Azure default DNS server](https://docs.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16) to resolve any kind of records, which by default has **168.63.129.16** IP address. So nslookup will be following:

![](/images/network/priv_end_arch_01.png)

1. Virtual Machine submits a DNS query of Storage Account Fileshares FQDN (`<account name>.file.core.windows.net`) to the default DNS server (which is `168.63.129.16`). The Storage Account's public DNS record `<account name>.file.core.windows.net` points to CNAME `<account name>.privatelink.file.core.windows.net` record.
2. As `<account name>.privatelink.file.core.windows.net` zone is linked to VNet, query will be redirected to it.
3. Private DNS Zone returns Private Endpoint's NIC IP address.

## Results

Deployment will create resources with unique names, generated (using [uniqueString function](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions-string#uniquestring)) from a subscription's ID to which template is deployed:

![](/images/network/priv_end_res_grp_00.png)

When you resolve the storage endpoint URL from outside the VNet with the private endpoint, it resolves to the public endpoint of the storage service. When resolved from the VNet hosting the private endpoint, the storage endpoint URL resolves to the private endpoint's IP address. After the deployment is completed you can make sure that it is so.

![](/images/network/strg_acc_access_w_priv_end_and_wo.png)

At first, validate that private endpoint has private IP and DNS zone integration:

![](/images/network/priv_end_dns_zone_00.png)

Next, check how storage accounts FQDN was resolved on Virtual Machine. To do so, open 'Extensions' section under Virtual Machines settings: 

![](/images/network/priv_end_vm_cust_ext_00.png)

Output value should contain private endpoints private IP address: 

![](/images/network/priv_end_vm_cust_ext_01.png)

Finally, you can resolve storage service from non-Azure environment (for example, your own computer):

![](/images/network/priv_end_res_resolv_pub.png)

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
* https://docs.microsoft.com/en-us/azure/virtual-network/vnet-integration-for-azure-services
* https://docs.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links
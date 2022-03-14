# Integrate Platform as a Services with Virtual Networks (part 3)
## Introduction


In nowadays Microsoft provides a wide range of publicly available Platform as a Services in Azure. As was discussed in previous parts, [Private Endpoints](/paas-vnet-01/README.md) and [Service Endpoints](/paas-vnet-00/README.md) allows to expose/limit access PaaS privately. 

![](/images/network/paas_vnet_logo.png)

This document gives an example of how a **DNS forwarder** can be used for exposing Private Endpoint's DNS to other environment(which can be another Azure VNet or On-Premises network).

## Theoretical Part

### DNS

Computers on a network can find one another by IP addresses. To make it easier to work within a computer network, people can use a Domain Name System (DNS) to associate human-friendly domain names with IP addresses, similar to a phonebook. A DNS can also associate other information beyond just computer network addresses to domain names. 

![](/images/network/dns_simple.png)

In other words, DNS is a directory of easily readable domain names that translate to numeric IP addresses used by computers to communicate with each other. For example, when you type a URL into a browser, DNS converts the URL into an IP address of a web server associated with that name. 

#### Authoritative vs Recursive
There are two name server configuration types:

* Authoritative - to resource records that are part of their zones only. This category includes both primary and secondary name servers. 
* Recursive - offer resolution services, but they are not authoritative for any zone. Answers for all resolutions are cached in a memory for a fixed period of time, which is specified by the retrieved resource record. 

![](/images/network/how_dns_works.png)

Although a name server can be both authoritative and recursive at the same time, it is recommended not to combine the configuration types. To be able to perform their work, authoritative servers should be available to all clients all the time. On the other hand, since the recursive lookup takes far more time than authoritative responses, recursive servers should be available to a restricted number of clients only, otherwise they are prone to distributed denial of service (DDoS) attacks. 

### Azure Private DNS zone

Azure Private DNS provides a reliable, secure DNS service to manage and resolve domain names in a virtual network without the need to add a custom DNS solution. By using private DNS zones, you can use your own custom domain names rather than the Azure-provided names available today. Using custom domain names helps you to tailor your virtual network architecture to best suit your organization's needs. It provides name resolution for virtual machines (VMs) within a virtual network and between virtual networks. Additionally, you can configure zones names with a split-horizon view, which allows a private and a public DNS zone to share the name.

To resolve the records of a private DNS zone from your virtual network, you must link the virtual network with the zone. Linked virtual networks have full access and can resolve all DNS records published in the private zone. Additionally, you can also enable autoregistration on a virtual network link. If you enable autoregistration on a virtual network link, the DNS records for the virtual machines on that virtual network are registered in the private zone. When autoregistration is enabled, Azure DNS also updates the zone records whenever a virtual machine is created, changes its' IP address, or is deleted.

## Practical Part

As was stated in the Introduction, this document gives an example of **using a DNS forwarder (aka Recursive DNS)** for sharing Azure private and/or on-premises private DNS zones. For that purpose will be used [CoreDNS](https://github.com/coredns/coredns) running as [an Azure Container Instance](https://azure.microsoft.com/en-us/services/container-instances/). 

For the environment deployment [following ARM template](https://github.com/groovy-sky/private-endpoint-with-on-prem/blob/master/azure/azuredeploy.json) will be used. It deploys multiple resources, which could be grouped to:

1. PaaS itself, which in this example is a storage account
2. Resources used for exposing the public resource privately (NIC, private endpoint, VNet, private DNS zone)
3. DNS Forwarder, which is just a container instance, used for private endpoint's resolve (by forwarding all incoming requests to a VNet with linked private DNS zone). It's configuration you can check [here](https://github.com/groovy-sky/private-endpoint-with-on-prem/tree/master/docker)
4. Virtual Machine, which will be used to resolve the PaaS privately (using Private Endpoint) and publicly using Custom Script extension.

![](/images/network/priv_end_w_forward_arch.png)

You start the deployment by using any prefferable way (Powershell, CLI etc.) or by clicking the button below:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fprivate-endpoint-with-on-prem%2Fmaster%2Fazure%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>

> **_NOTE:_**  'With Dns Forwarder' option should be true

![](/images/network/priv_end_with_dns_deploy.png)

## Result

After the deployment is completed, you can check VM's Custom Script executions output:

![](/images/network/priv_end_with_dns_result.png)

## Summary

As shown in the previous section, Private Endpoint allows to expand a service to a VNet as read-only Network Card. Optionally private DNS could be used (for a seamless access by domain name). This means that PaaS has two IP addresses - public (available by default) and private (NIC's address). 

Now, using a private endpoint and DNS forwarder, PaaS services can be resolved from On-Premises by it's private IP address:

![](/images/network/priv_end_acc_w_forw_from_on_prem_struct.png)


## Related Information
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview
* https://www.ibm.com/cloud/learn/dns
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns
* https://docs.microsoft.com/en-us/azure/dns/dns-overview
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#on-premises-workloads-using-a-dns-forwarder
* https://docs.microsoft.com/en-us/azure/aks/private-clusters#hub-and-spoke-with-custom-dns
* https://cloud.google.com/dns/docs/dns-overview

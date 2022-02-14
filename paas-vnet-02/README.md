# Integrate Platform as a Services with Virtual Networks (part 3)
## Introduction


In nowdays Microsoft provides a wide range of publicly available Platform as a Services in Azure. As was discussed in previous the previous parts, [Private Endpoint](/paas-vnet-01/README.md) and [Service Endpoints](/paas-vnet-00/README.md) allows to expose/limit access privately. 

![](/images/network/paas_vnet_logo.png)

This document explains how a **DNS forwarder** can for used for expanding Private DNS zone to On-Premises.

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

As was stated in the Introduction, this document gives an example of **using [CoreDNS](https://github.com/coredns/coredns) Container Instance as a recursive (aka forwarding) Name Server** for sharing Azure private and/or on-premises private DNS zones. Which type of instance to deploy (privately or publicly available) is up to you.

![](/images/network/priv_end_with_dns_deploy.png)


## Result


![](/images/network/priv_end_with_dns_result.png)

![](/images/network/priv_end_w_forward_arch.png)


## Summary

## Related Information
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview
* https://www.ibm.com/cloud/learn/dns
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns
* https://docs.microsoft.com/en-us/azure/dns/dns-overview
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#on-premises-workloads-using-a-dns-forwarder
* https://docs.microsoft.com/en-us/azure/aks/private-clusters#hub-and-spoke-with-custom-dns
* https://cloud.google.com/dns/docs/dns-overview

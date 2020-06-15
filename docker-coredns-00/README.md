# 
## Introduction

Computers on a network can find one another by IP addresses. To make it easier to work within a computer network, people can use a Domain Name System (DNS) to associate human-friendly domain names with IP addresses, similar to a phonebook. A DNS can also associate other information beyond just computer network addresses to domain names.

## Theoretical Part

### DNS
Domain Name System (DNS) is what makes it possible for users to connect to websites using Internet domain names and searchable URLs rather than numerical Internet protocol addresses. 

#### Authoritative vs Recursive
There are two name server configuration types:

Authoritative
    Authoritative name servers answer to resource records that are part of their zones only. This category includes both primary (master) and secondary (slave) name servers. 
Recursive
    Recursive name servers offer resolution services, but they are not authoritative for any zone. Answers for all resolutions are cached in a memory for a fixed period of time, which is specified by the retrieved resource record. 

Although a name server can be both authoritative and recursive at the same time, it is recommended not to combine the configuration types. To be able to perform their work, authoritative servers should be available to all clients all the time. On the other hand, since the recursive lookup takes far more time than authoritative responses, recursive servers should be available to a restricted number of clients only, otherwise they are prone to distributed denial of service (DDoS) attacks. 

#### Private vs Public
Public DNS: IP records are usually provided to your business by your Internet service provider (ISP). These records are available to the public and can be accessed by anyone, regardless of the device they use or the network they are attached to.
Private DNS: A private DNS is different than a public one in that it resides behind a company firewall and only holds records of internal sites. In this case, the private DNS is limited in its scope to remembering IP addresses from the internal sites and services being used and can't be accessed outside of the private network.


### Azure Authoritative Private DNS 
Azure Private DNS provides a reliable, secure DNS service to manage and resolve domain names in a virtual network without the need to add a custom DNS solution. By using private DNS zones, you can use your own custom domain names rather than the Azure-provided names available today. Using custom domain names helps you to tailor your virtual network architecture to best suit your organization's needs. It provides name resolution for virtual machines (VMs) within a virtual network and between virtual networks. Additionally, you can configure zones names with a split-horizon view, which allows a private and a public DNS zone to share the name.

To resolve the records of a private DNS zone from your virtual network, you must link the virtual network with the zone. Linked virtual networks have full access and can resolve all DNS records published in the private zone. Additionally, you can also enable autoregistration on a virtual network link. If you enable autoregistration on a virtual network link, the DNS records for the virtual machines on that virtual network are registered in the private zone. When autoregistration is enabled, Azure DNS also updates the zone records whenever a virtual machine is created, changes its' IP address, or is deleted.

### Azure Private Endpoint
Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. Private Endpoint uses a private IP address from your VNet, effectively bringing the service into your VNet. The service could be an Azure service such as Azure Storage, Azure Cosmos DB, SQL, etc. or your own Private Link Service.

### Private Endpoint DNS configuration
When you're connecting to a private link resource using a fully qualified domain name (FQDN) as part of the connection string, it's important to correctly configure your DNS settings to resolve to the allocated private IP address. Existing Microsoft Azure services might already have a DNS configuration to use when connecting over a public endpoint. This configuration needs to be overridden to connect using your private endpoint.

The network interface associated with the private endpoint contains the complete set of information required to configure your DNS, including FQDN and private IP addresses allocated for a particular private link resource.

## Prerequisites
## Practical Part
## Results
## Summary
## Related Information
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview
* https://www.ibm.com/cloud/learn/dns
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns
* https://docs.microsoft.com/en-us/azure/dns/dns-overview
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#on-premises-workloads-using-a-dns-forwarder
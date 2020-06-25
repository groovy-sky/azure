# 
## Introduction


In nowdays Microsoft provides a wide range of publicly available services in Azure. At the same time Azure allows you to extend your on-premises networks into the Microsoft cloud using, for example, ExpressRoute circuit or VPN Gateway. 

Some time ago some part of services available in Azure Marketplace got additional feature, called private endpoint, which allowed to get access by private IP and private DNS name. 

A challenge crop up then you need to resolve Azure and On-Premises private zones using one Name Server. For example, if you want to [access a private Azure Kubernetes Service cluster from on-premises](https://docs.microsoft.com/en-us/azure/aks/private-clusters#hub-and-spoke-with-custom-dns). In such case obvius solution would be to use Azure private recursive DNS, but unfortunately currently you can get (as a service) only authoritative one.  

![](/images/docker/coredns_recur_arch.png)

This document gives an example of **using [CoreDNS](https://github.com/coredns/coredns) Container Instance as a private recursive (aka forwarding) Name Server** for sharing Azure private and on-premises private DNS zones.

## Theoretical Part

### DNS

![](/images/docker/dns_logo.png)

Computers on a network can find one another by IP addresses. To make it easier to work within a computer network, people can use a Domain Name System (DNS) to associate human-friendly domain names with IP addresses, similar to a phonebook. A DNS can also associate other information beyond just computer network addresses to domain names. 

![](/images/docker/dns_simple.png)

In other words, DNS is a directory of easily readable domain names that translate to numeric IP addresses used by computers to communicate with each other. For example, when you type a URL into a browser, DNS converts the URL into an IP address of a web server associated with that name. 

#### Authoritative vs Recursive
There are two name server configuration types:

* Authoritative - to resource records that are part of their zones only. This category includes both primary (master) and secondary (slave) name servers. 
* Recursive - offer resolution services, but they are not authoritative for any zone. Answers for all resolutions are cached in a memory for a fixed period of time, which is specified by the retrieved resource record. 

![](/images/docker/how_dns_works.png)

Although a name server can be both authoritative and recursive at the same time, it is recommended not to combine the configuration types. To be able to perform their work, authoritative servers should be available to all clients all the time. On the other hand, since the recursive lookup takes far more time than authoritative responses, recursive servers should be available to a restricted number of clients only, otherwise they are prone to distributed denial of service (DDoS) attacks. 

#### Private vs Public
There are two zone types, which name server can use:

* Zone with records, which have public IP addresses. Such zone, probably, is stored on publicly available Name Server and can be accessed by anyone, regardless of the device they use or the network they are attached to.
* Zone with records, which have private IP addresses. This type of zone probably resides behind a company firewall and only holds records of internal sites. 

Although a name server can contain both type of zones, it is not recommended to share a public DNS server with private zones. In this case, the private zone is available for external usage.

### Azure Authoritative Private Name Server 

Azure Private DNS provides a reliable, secure DNS service to manage and resolve domain names in a virtual network without the need to add a custom DNS solution. By using private DNS zones, you can use your own custom domain names rather than the Azure-provided names available today. Using custom domain names helps you to tailor your virtual network architecture to best suit your organization's needs. It provides name resolution for virtual machines (VMs) within a virtual network and between virtual networks. Additionally, you can configure zones names with a split-horizon view, which allows a private and a public DNS zone to share the name.

To resolve the records of a private DNS zone from your virtual network, you must link the virtual network with the zone. Linked virtual networks have full access and can resolve all DNS records published in the private zone. Additionally, you can also enable autoregistration on a virtual network link. If you enable autoregistration on a virtual network link, the DNS records for the virtual machines on that virtual network are registered in the private zone. When autoregistration is enabled, Azure DNS also updates the zone records whenever a virtual machine is created, changes its' IP address, or is deleted.

### Azure Container Instances

![](/images/docker/az_container.png)

Azure Container Instances enables a layered approach to orchestration, providing all of the scheduling and management capabilities required to run a single container, while allowing orchestrator platforms to manage multi-container tasks on top of it.

Because the underlying infrastructure for container instances is managed by Azure, an orchestrator platform does not need to concern itself with finding an appropriate host machine on which to run a single container. The elasticity of the cloud ensures that one is always available. Instead, the orchestrator can focus on the tasks that simplify the development of multi-container architectures, including scaling and coordinated upgrades.

#### Container group
The top-level resource in Azure Container Instances is the container group. A container group is a collection of containers that get scheduled on the same host machine. The containers in a container group share a lifecycle, resources, local network, and storage volumes

#### Resource allocation

Azure Container Instances allocates resources such as CPUs, memory, and optionally GPUs (preview) to a multi-container group by adding the resource requests of the instances in the group. Taking CPU resources as an example, if you create a container group with two container instances, each requesting 1 CPU, then the container group is allocated 2 CPUs.

#### Networking
Container groups can share an external-facing IP address, one or more ports on that IP address, and a DNS label with a fully qualified domain name (FQDN). To enable external clients to reach a container within the group, you must expose the port on the IP address and from the container. A container group's IP address and FQDN are released when the container group is deleted.

Within a container group, container instances can reach each other via localhost on any port, even if those ports aren't exposed externally on the group's IP address or from the container.

Optionally deploy container groups into an Azure virtual network to allow containers to communicate securely with other resources in the virtual network.

#### Linux and Windows containers

Azure Container Instances support both Windows and Linux containers.


## Prerequisites

Before you begin the next section, you’ll need:

* Azure Cloud account
* Docker Hub account

## Practical Part


## Results
## Summary
## Related Information
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview
* https://www.ibm.com/cloud/learn/dns
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns
* https://docs.microsoft.com/en-us/azure/dns/dns-overview
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#on-premises-workloads-using-a-dns-forwarder
* https://docs.microsoft.com/en-us/azure/aks/private-clusters#hub-and-spoke-with-custom-dns
* https://cloud.google.com/dns/docs/dns-overview
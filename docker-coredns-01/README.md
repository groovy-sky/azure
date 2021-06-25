# 
## Introduction

Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. Private Endpoint uses a private IP address from your VNet, effectively bringing the service into your VNet. The service could be an Azure service such as Azure Storage, Azure Cosmos DB, SQL, etc. or your own Private Link Service.

Azure Private endpoint is the fundamental building block for Private Link in Azure. It enables Azure resources, like virtual machines (VMs), to communicate with Private Link resources privately.

Private endpoint uses a private IP address from your virtual network to connect to the private link service.

A private endpoint is a special network interface for an Azure service in your Virtual Network (VNet). When you create a private endpoint for your App Configuration store, it provides secure connectivity between clients on your VNet and your configuration store. The private endpoint is assigned an IP address from the IP address range of your VNet. The connection between the private endpoint and the configuration store uses a secure private link.

## Theoretical Part

A private endpoint is a special network interface for an Azure service in your Virtual Network (VNet). When you create a private endpoint for your App Configuration store, it provides secure connectivity between clients on your VNet and your configuration store. The private endpoint is assigned an IP address from the IP address range of your VNet. The connection between the private endpoint and the configuration store uses a secure private link.

Applications in the VNet can connect to the configuration store over the private endpoint using the same connection strings and authorization mechanisms that they would use otherwise. Private endpoints can be used with all protocols supported by the App Configuration store.

While App Configuration doesn't support service endpoints, private endpoints can be created in subnets that use Service Endpoints. Clients in a subnet can connect securely to an App Configuration store using the private endpoint while using service endpoints to access others.

When you create a private endpoint for a service in your VNet, a consent request is sent for approval to the service account owner. If the user requesting the creation of the private endpoint is also an owner of the account, this consent request is automatically approved.

Service account owners can manage consent requests and private endpoints through the Private Endpoints tab of the App Configuration store in the Azure portal.

When you create a private endpoint, the DNS CNAME resource record for the configuration store is updated to an alias in a subdomain with the prefix privatelink. Azure also creates a private DNS zone corresponding to the privatelink subdomain, with the DNS A resource records for the private endpoints.

When you resolve the endpoint URL from within the VNet hosting the private endpoint, it resolves to the private endpoint of the store. When resolved from outside the VNet, the endpoint URL resolves to the public endpoint. When you create a private endpoint, the public endpoint is disabled.

If you are using a custom DNS server on your network, clients must be able to resolve the fully qualified domain name (FQDN) for the service endpoint to the private endpoint IP address. Configure your DNS server to delegate your private link subdomain to the private DNS zone for the VNet, or configure the A records for [Your-store-name].privatelink.azconfig.io with the private endpoint IP address.


----


Azure Private Endpoint is a network interface that connects applications privately and securely to an Azure service powered by Azure Private Link. Private Endpoint uses a private IP address from a virtual network, effectively bringing the service into your virtual network. The service could be an Azure service such as Azure Storage, Azure Cosmos DB, SQL, etc. or your own Private Link Service. Here are some key details about private endpoints:



* Private endpoint enables connectivity between the consumers from the same VNet, regionally peered VNets, globally peered VNets and on premises using VPN or Express Route and services powered by Private Link.

* Network connections can only be initiated by clients connecting to the Private endpoint, Service providers do not have any routing configuration to initiate connections into service consumers. Connections can only be established in a single direction.

* As shown in the picture below, when creating a private endpoint, a read-only network interface is also created for the lifecycle of the resource. By convention, the name of this network interface is equal to <private-endpoint-name>.nic.<unique-identifier>. The interface is assigned dynamically a private IP address from the subnet that maps to the private link resource. The value of the private IP address remains unchanged for the entire lifecycle of the private endpoint.

* The private endpoint must be deployed in the same region as the virtual network.

* The private link resource can be deployed in a different region than the virtual network and private endpoint.

* Multiple private endpoints can be created using the same private link resource. For a single network using a common DNS server configuration, the recommended practice is to use a single private endpoint for a given private link resource to avoid duplicate entries or conflicts in DNS resolution.

* Multiple private endpoints can be created on the same or different subnets within the same virtual network. There are limits to the number of private endpoints you can create in a subscription. For details, see Azure limits.

* The PrivateDnsZoneGroup resource type establishes a relationship between the Private Endpoint and the Private DNS zone used for the name resolution of the fully qualified name of the resource referenced by the Private Endpoint. The PrivateDnsZoneGroup is a sub-resource or child-resource of a Private Endpoint. The PrivateDnsZoneGroup type a single property that contains the resource if of the referenced Private DNS Zone. The user that creates a PrivateDnsZoneGroup requires write permission on the private DNS Zone. Once created, this resource is used to manage the lifecycle of the DNS A record used to resolve the fully qualified name of the resource referenced by the Private Endpoint. When creating a Private Endpoint, the related A record will automatically be created in the target Private DNS Zone with the private IP address of the network interface associated to the Private Endpoint and the name of the Azure resource referenced by the Private Endpoint. When deleting a Private Endpoint, the related A record gets automatically deleted from the corresponding Private DNS Zone. The network resource provider (Microsoft.Network) identity is used to perform both operations. This means that the user provisioning a Private Endpoint doesn't require any write permissions on the Private DNS Zone or it's A records.



## Prerequisites
## Practical Part

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure-coredns%2Fmaster%2Fazure%2Fprivate-endpoints%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>

## Results
## Summary
## Related Information
* https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview
* https://github.com/paolosalvatori/private-endpoints-topologies
* https://github.com/dmauser/PrivateLink
* https://docs.microsoft.com/en-us/azure/azure-app-configuration/concept-private-endpoint
* https://github.com/Azure/azure-quickstart-templates/tree/master/201-file-share-private-endpoint
* https://github.com/Azure/azure-quickstart-templates/tree/master/201-private-aks-cluster
* https://github.com/Azure/azure-quickstart-templates/tree/master/custom-private-dns
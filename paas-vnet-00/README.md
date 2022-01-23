# Integrate Platform as a Services with Virtual Networks (part 1)

## Introduction

By default most of Azure Platform as a services are publicly available. To be able to expose a service privately different solutions are available. 

![](/images/network/paas_vnet_logo.png)

**This document gives an example of using Service Endpoints to restrict access to a Platform as a Service (PaaS).**

## Theoretical Part

### Inbound or Outbound

Inbound or Outbound is the direction traffic moves between resources. It is relative to whichever resource you are referencing. Inbound traffic refers to information coming-in into a resource. Outbound is outgoing from a resource traffic:

![](/images/network/service_inbound_and_outbound.png)

VNet integration https://docs.microsoft.com/en-us/azure/app-service/overview-vnet-integration

![](/images/network/paas_vnet_int.png)

access restrictions https://docs.microsoft.com/en-us/azure/app-service/app-service-ip-restrictions

![](/images/network/paas_acc_restr.png)

### Service Endpoints

With Virtual Network Service Endpoints, you can allow traffic only from selected virtual networks and subnets, creating a secure network boundary for your data.

Virtual Network (VNet) service endpoint provides secure and direct connectivity to Azure services over an optimized route over the Azure backbone network. Endpoints allow you to secure your critical Azure service resources to only your virtual networks. Service Endpoints enables private IP addresses in the VNet to reach the endpoint of an Azure service without needing a public IP address on the VNet.

A virtual network service endpoint provides the identity of your virtual network to the Azure service. Once you enable service endpoints in your virtual network, you can add a virtual network rule to secure the Azure service resources to your virtual network.

Service endpoints provide secure and direct connectivity to Azure services over the Azure backbone network. Endpoints allow you to secure your Azure resources to only your virtual networks. Service endpoints enable private IP addresses in the VNet to reach an Azure service without the need of an outbound public IP.

Without service endpoints, restricting access to just your VNet can be challenging. The source IP address could change or could be shared with other customers. For example, PaaS services with shared outbound IP addresses. With service endpoints, the source IP address that the target service sees becomes a private IP address from your VNet. This ingress traffic change allows for easily identifying the origin and using it for configuring appropriate firewall rules. For example, allowing only traffic from a specific subnet within that VNet.

With service endpoints, DNS entries for Azure services remain as-is and continue to resolve to public IP addresses assigned to the Azure service.

In the diagram below, the right side is the same target PaaS service. On the left, there's a customer VNet with two subnets: Subnet A which has a Service Endpoint towards Microsoft.Sql, and Subnet B, which has no Service Endpoints defined.

When a resource in Subnet B tries to reach any SQL Server, it will use a public IP address for outbound communication. This traffic is represented by the blue arrow. The SQL Server firewall must use that public IP address to allow or block the network traffic.

When a resource in Subnet A tries to reach a database server, it will be seen as a private IP address from within the VNet. This traffic is represented by the green arrows. The SQL Server firewall can now specifically allow or block Subnet A. Knowledge of the public IP address of the source service is unneeded.

###

Service endpoints provide the following benefits:

* Improved security for your Azure service resources: VNet private address spaces can overlap. You can't use overlapping spaces to uniquely identify traffic that originates from your VNet. Service endpoints provide the ability to secure Azure service resources to your virtual network by extending VNet identity to the service. Once you enable service endpoints in your virtual network, you can add a virtual network rule to secure the Azure service resources to your virtual network. The rule addition provides improved security by fully removing public internet access to resources and allowing traffic only from your virtual network.

* Optimal routing for Azure service traffic from your virtual network: Today, any routes in your virtual network that force internet traffic to your on-premises and/or virtual appliances also force Azure service traffic to take the same route as the internet traffic. Service endpoints provide optimal routing for Azure traffic.

* Endpoints always take service traffic directly from your virtual network to the service on the Microsoft Azure backbone network. Keeping traffic on the Azure backbone network allows you to continue auditing and monitoring outbound Internet traffic from your virtual networks, through forced-tunneling, without impacting service traffic. For more information about user-defined routes and forced-tunneling, see Azure virtual network traffic routing.

* Simple to set up with less management overhead: You no longer need reserved, public IP addresses in your virtual networks to secure Azure resources through IP firewall. There are no Network Address Translation (NAT) or gateway devices required to set up the service endpoints. You can configure service endpoints through a simple click on a subnet. There's no additional overhead to maintaining the endpoints.

Service endpoints provide the following limitations:

* The feature is available only to virtual networks deployed through the Azure Resource Manager deployment model.
* Endpoints are enabled on subnets configured in Azure virtual networks. Endpoints can't be used for traffic from your premises to Azure services. 
*For some services (like Azure SQL) a service endpoint applies only to Azure service traffic within a virtual network's region. 


## Prerequisites
## Practical Part



![](/images/network/from_webapp2func_flow.png)


You can use Bash Cloud Shell or Azure CLI on Linux to run the [script.sh](https://github.com/groovy-sky/vnet-service-endpoints/blob/main/deploy.sh), which will:

1. 
2.
3.




![](/images/network/service_paas_deploy.gif)

## Results

Web App's VNet integration configuration:

![](/images/network/web_app_vnet_integration.png)

VNet subnet's configuration:

![](/images/network/vnet_deleg4web.png)

Function's access restriction:

![](/images/network/func_access_restriction.png)

Web App's outbound IP:
![](/images/network/web_app_out_ip_in_func.png)

To validate that the access restriction works and the function is not publicly available you can try to open it directly:
![](/images/network/web_deny_msg_example.png)

## Summary

Service endpoints are available for limited Azure services and regions. 

Microsoft recommends use of Azure Private Endpoint for secure and private access to services hosted on Azure platform. In the next chapter this 

## Related Information

* https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview
* https://docs.microsoft.com/en-us/azure/virtual-network/vnet-integration-for-azure-services

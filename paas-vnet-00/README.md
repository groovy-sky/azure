# Integrate Platform as a Services with Virtual Networks (part 1)

## Introduction

By default most of Azure Platform as a services are publicly available. To be able to expose a service privately different solutions are available. 

![](/images/network/paas_vnet_logo.png)

**This document gives an example of using Service Endpoints to restrict access to a Platform as a Service (PaaS).**

## Theoretical Part

### Inbound vs Outbound

Before clarify how Service Endpoints works, traffic's direction should be explained. Inbound or Outbound is the direction traffic moves between resources. It is relative to whichever resource you are referencing. Inbound traffic refers to information coming-in into a resource. Outbound is outgoing from a resource traffic. 

In the picture below incoming to Azure resource from "Service X" traffic is inbound and outgoing from Azure service traffic to "Service Y" is outbound:

![](/images/network/service_inbound_and_outbound.png)

As this paper gives an example of networking for Platform as a Service, two main features will be used for controlling Inbound and Outbound traffic - Access Restriction for limiting Inbound and VNet integration for routing Outbound.

#### Access Restriction (Inbound)

By setting up [Access Restriction](https://docs.microsoft.com/en-us/azure/app-service/app-service-ip-restrictions), you can define a priority-ordered allow/deny list that controls network access to your app. The list can include IP addresses or Azure Virtual Network subnets. When there are one or more entries, an implicit deny all exists at the end of the list.

![](/images/network/paas_acc_restr.png)

The ability to restrict access to your resource from an Azure virtual network is enabled by service endpoints. With service endpoints, you can restrict access to a multi-tenant service from selected subnets. 


#### VNet Integration (Outbound)

[Virtual Network Integration](https://docs.microsoft.com/en-us/azure/app-service/overview-vnet-integration) gives your service access to resources in your virtual network, but it doesn't grant inbound private access to your service from the virtual network. 

![](/images/network/paas_vnet_int.png)

Virtual network integration is used only to make outbound calls from your PaaS into your virtual network.

### Service Endpoints

With Virtual Network Service Endpoints, you can allow traffic only from selected virtual networks and subnets(i.e. control inbound traffic), creating a secure network boundary for your data.

Virtual Network (VNet) service endpoint provides secure and direct connectivity to Azure services over an optimized route over the Azure backbone network. Endpoints allow you to secure your critical Azure service resources to only your virtual networks. Service Endpoints enables private IP addresses in the VNet to reach the endpoint of an Azure service without needing a public IP address on the VNet:

![](/images/network/azure_service_endpoint_struct.png)

Without service endpoints, restricting access to just your VNet can be challenging. The source IP address could change or could be shared with other customers. For example, PaaS services with shared outbound IP addresses. With service endpoints, the source IP address that the target service sees becomes a private IP address from your VNet. This ingress traffic change allows for easily identifying the origin and using it for configuring appropriate access rules. For example, allowing only traffic from a specific subnet within that VNet.

With service endpoints, DNS entries for Azure services remain as-is and continue to resolve to public IP addresses assigned to the Azure service.

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

For this demo I have created [a separate repository](https://github.com/groovy-sky/vnet-service-endpoints) for deploying a demonstration environment. To deploy it you'll need to clone the repository and execute commands from [script.sh](https://github.com/groovy-sky/vnet-service-endpoints/blob/main/deploy.sh):

![](/images/network/service_paas_deploy.gif)

Deployment script will create 2 resource groups ('webapp-res-grp' and 'func-res-grp'), which contains 3 main components:

1. Virtual Network
2. Azure Web App
3. Azure Function App

VNet has only one subnet, which has Service Endpoints delegation for Web Apps:

![](/images/network/vnet_deleg4web.png)

Web App uses the same subnet for VNet integration (for routing an outbound traffic): 

![](/images/network/web_app_vnet_integration.png)

Function app have access restriction (for controlling inbound traffic) with one allow rule from Web App's subnet:

![](/images/network/func_access_restriction.png)

[Web App's code]((https://github.com/groovy-sky/vnet-service-endpoints/blob/main/webapp/code/app.py)) is running on Python and works as a web proxy. [Function's code](https://github.com/groovy-sky/vnet-service-endpoints/blob/main/func/code/GoCustomHandler.go) is written on Go and it is used to show requester's IP address (more about how it works you can read [here](../func-custom-handler-00/README.md)). Full structure:

![](/images/network/from_webapp2func_flow.png)

Thanks to the Web App you can validate actually see from what IP comes request to the Function App. 

## Results

As soon as last command from the deployment script has been executed, you'll see what IP address was used by Web App for quering Function App:

![](/images/network/web_app_out_ip_in_func.png)

To validate that the access restriction works (and public access is denied) you can try to open function directly:
![](/images/network/web_deny_msg_example.png)

## Summary

Service endpoints are available for limited Azure services and regions. 

Microsoft recommends use of Azure Private Endpoint for secure and private access to services hosted on Azure platform. In the next chapter this 

## Related Information

* https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview
* https://docs.microsoft.com/en-us/azure/virtual-network/vnet-integration-for-azure-services

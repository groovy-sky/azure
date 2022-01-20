# Integrate Platform as a service with Virtual Networks (part 1)

![](/images/network/paas_vnet_logo.png)


## Introduction


## Theoretical Part

Inbound or Outbound is the direction traffic moves between networks. It is relative to whichever network you are referencing. Inbound traffic refers to information coming-in into a network. Outbound traffic is something on your computer that is connecting out to the internet.

![](/images/network/service_inbound_and_outbound.png)


Virtual Network (VNet) service endpoint provides secure and direct connectivity to Azure services over an optimized route over the Azure backbone network. Endpoints allow you to secure your critical Azure service resources to only your virtual networks. Service Endpoints enables private IP addresses in the VNet to reach the endpoint of an Azure service without needing a public IP address on the VNet.

![](/images/network/service_endpoint_theory.png)

A virtual network service endpoint provides the identity of your virtual network to the Azure service. Once you enable service endpoints in your virtual network, you can add a virtual network rule to secure the Azure service resources to your virtual network.

Today, Azure service traffic from a virtual network uses public IP addresses as source IP addresses. With service endpoints, service traffic switches to use virtual network private addresses as the source IP addresses when accessing the Azure service from a virtual network. This switch allows you to access the services without the need for reserved, public IP addresses used in IP firewalls.

### 
Service endpoints provide the following benefits:

* Improved security for your Azure service resources: VNet private address spaces can overlap. You can't use overlapping spaces to uniquely identify traffic that originates from your VNet. Service endpoints provide the ability to secure Azure service resources to your virtual network by extending VNet identity to the service. Once you enable service endpoints in your virtual network, you can add a virtual network rule to secure the Azure service resources to your virtual network. The rule addition provides improved security by fully removing public internet access to resources and allowing traffic only from your virtual network.

* Optimal routing for Azure service traffic from your virtual network: Today, any routes in your virtual network that force internet traffic to your on-premises and/or virtual appliances also force Azure service traffic to take the same route as the internet traffic. Service endpoints provide optimal routing for Azure traffic.

* Endpoints always take service traffic directly from your virtual network to the service on the Microsoft Azure backbone network. Keeping traffic on the Azure backbone network allows you to continue auditing and monitoring outbound Internet traffic from your virtual networks, through forced-tunneling, without impacting service traffic. For more information about user-defined routes and forced-tunneling, see Azure virtual network traffic routing.

* Simple to set up with less management overhead: You no longer need reserved, public IP addresses in your virtual networks to secure Azure resources through IP firewall. There are no Network Address Translation (NAT) or gateway devices required to set up the service endpoints. You can configure service endpoints through a simple click on a subnet. There's no additional overhead to maintaining the endpoints.


## Prerequisites
## Practical Part


![](/images/network/from_webapp2func_flow.png)


![](/images/network/service_paas_deploy.gif)

## Results

![](/images/network/web_app_vnet_integration_00.png)

![](/images/network/web_app_vnet_integration_01.png)

![](/images/network/func_access_restriction.png)


![](/images/network/web_deny_msg_example.png)


## Summary
## Related Information

* https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview
* https://docs.microsoft.com/en-us/azure/virtual-network/vnet-integration-for-azure-services

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

Today, Azure service traffic from a virtual network uses public IP addresses as source IP addresses. With service endpoints, service traffic switches to use virtual network private addresses as the source IP addresses when accessing the Azure service from a virtual network. This switch allows you to access the services without the need for reserved, public IP addresses used in IP firewalls.

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

For Azure Data Lake Storage (ADLS) Gen 1, the VNet Integration capability is only available for virtual networks within the same region. Also note that virtual network integration for ADLS Gen1 uses the virtual network service endpoint security between your virtual network and Azure Active Directory (Azure AD) to generate additional security claims in the access token. These claims are then used to authenticate your virtual network to your Data Lake Storage Gen1 account and allow access. The Microsoft.AzureActiveDirectory tag listed under services supporting service endpoints is used only for supporting service endpoints to ADLS Gen 1. Azure AD doesn't support service endpoints natively. For more information about Azure Data Lake Store Gen 1 VNet integration, see Network security in Azure Data Lake Storage Gen1.


## Prerequisites
## Practical Part

![](/images/network/from_webapp2func_flow.png)


You can use Bash Cloud Shell or Azure CLI on Linux to run the [script.sh](https://github.com/groovy-sky/vnet-service-endpoints/blob/main/deploy.sh), which will:
1.
2.
3.

```
wget https://raw.githubusercontent.com/groovy-sky/vnet-service-endpoints/main/deploy.sh && chmod +x script.sh && ./script.sh
```



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

Function's response from public IP:
![](/images/network/web_deny_msg_example.png)

## Summary

Service endpoints are available for limited Azure services and regions. 

Microsoft recommends use of Azure Private Endpoint for secure and private access to services hosted on Azure platform. In the next chapter this 

## Related Information

* https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview
* https://docs.microsoft.com/en-us/azure/virtual-network/vnet-integration-for-azure-services

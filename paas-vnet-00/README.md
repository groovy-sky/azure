# Integrate Platform as a Services with Virtual Networks (part 1)

## Introduction

By default, most of Azure Platform as a services are publicly available. To be able to expose/access a service privately, Microsoft provides  different solutions (like using dedicated instances, publishing Private Endpoints etc.).

![](/images/network/paas_vnet_logo.png)

This document gives an example of using **Service Endpoints** to allow one PaaS (Azure Web App) access another PaaS (Azure Function App) privately.

## Theoretical Part

### Inbound vs Outbound

Before clarify how Service Endpoints works, traffic's direction should be explained. Inbound or Outbound is the direction traffic moves between resources. It is relative to whichever resource you are referencing. Inbound traffic refers to information coming-in into a resource. Outbound is outgoing from a resource traffic. 

In the picture below incoming to Azure resource from "Service X" traffic is inbound and outgoing from Azure service traffic to "Service Y" is outbound:

![](/images/network/service_inbound_and_outbound.png)

As this paper gives an example of Azure's PaaS, two App Services features will be used for controlling Inbound and Outbound traffic - Access Restriction for limiting inbound and VNet Integration for routing outbound.

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

## Prerequisites

For this demo you'll need a Linux environment with additional software (Azure CLI, Python, Go, Azure Functions Core Tools, curl). Or you can can use [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/features) (which already contains all nessecary packages).

## Practical Part

For this demo I have created [a separate repository](https://github.com/groovy-sky/vnet-service-endpoints). To deploy it you'll need to copy and execute commands from [script.sh](https://github.com/groovy-sky/vnet-service-endpoints/blob/main/deploy.sh):

![](/images/network/service_paas_deploy.gif)

Deployment will create 2 resource groups ('webapp-res-grp' and 'func-res-grp'), which contains 3 main components:

1. Virtual Network
2. Azure Web App
3. Azure Function App

VNet has only one subnet, which has Service Endpoints delegation for Web Apps:

![](/images/network/vnet_deleg4web.png)

Web App uses the same subnet for VNet integration (for routing outbound traffic): 

![](/images/network/web_app_vnet_integration.png)

Function app have access restriction (for controlling inbound traffic) with only one allow rule from Web App's subnet:

![](/images/network/func_access_restriction.png)

[Web App's code]((https://github.com/groovy-sky/vnet-service-endpoints/blob/main/webapp/code/app.py)) is running on Python and works as a web proxy. [Function's code](https://github.com/groovy-sky/vnet-service-endpoints/blob/main/func/code/GoCustomHandler.go) is written on Go and it is used to show requester's IP address (more about how it works you can read [here](../func-custom-handler-00/README.md)). Full structure:

![](/images/network/from_webapp2func_flow.png)

Thanks to the Web App you can obtain information about from what IP was the Function accessed. 

## Results

As soon as last command from the deployment script has been executed, you should get Function App response forwarded by Web App:

![](/images/network/web_app_out_ip_in_func.png)

To be sure that access restriction works(and public access is denied) you can try to open function's URL directly:
![](/images/network/web_deny_msg_example.png)

## Summary

Service Endpoints allows you to share access to yours services privately (through a subnet). Also there's no additional charge for using service endpoints.

However, Microsoft recommends to use of Azure Private Endpoint for secure and private access to services hosted on Azure platform. How Private Ednpoints works will be explained in the next section.

## Related Information

* https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview

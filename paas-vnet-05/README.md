## Overview

Azure Private Endpoint is a network interface that connects privately to an Azure resource. It uses a private IP address from your virtual network, allowing you to securely access Azure services over a private connection. This eliminates the need for public IP addresses or exposure to the public internet.

With Azure Private Endpoint, you can access Azure services such as Azure Storage, Azure SQL Database, and Azure Cosmos DB securely and privately. It provides a more secure way to access these services by keeping traffic within the Azure network backbone.

To create a Private Endpoint, you need to specify the target resource, such as a storage account or a SQL database, and associate it with a subnet in your virtual network. Once the Private Endpoint is created, you can access the resource using its private IP address.

Private Endpoint also enables you to control network access to the resource. You can apply network security groups (NSGs) and virtual network service endpoints to the subnet, providing additional security and isolation.

In summary, Azure Private Endpoint allows you to securely access Azure services over a private connection, using a private IP address from your virtual network. It provides enhanced security and isolation for your resources, reducing exposure to the public internet.

## Benefits

- **Securely access Azure services over a private connection** - Private Endpoint uses a private IP address from your virtual network, effectively bringing the service into your VNet. Traffic between your virtual network and the service traverses over the Microsoft backbone network, eliminating exposure from the public internet. You can also apply network security policies to the service endpoint.

- **Simplify network architecture** - Private Endpoint enables you to access Azure services over a private connection. This eliminates the need to configure public access to the service or configure a network gateway such as an ExpressRoute or VPN gateway. You can also access the service from on-premises over ExpressRoute or VPN Gateway connections using private peering.

- **Bring your own DNS** - Private Endpoint supports custom DNS configurations, allowing you to use your own domain names rather than the default azurewebsites.net or database.windows.net names. This enables you to use your own certificates and avoid certificate errors.

- **Use your own private IP address range** - Private Endpoint allows you to use your own private IP address range for the service. This enables you to use your own IP address range and avoid IP address conflicts with other Azure resources.

- **Use your own private link service** - Private Endpoint allows you to use your own private link service for the service. This enables you to use your own private link service and avoid conflicts with other Azure resources.

- **Use your own private DNS zone** - Private Endpoint allows you to use your own private DNS zone for the service. This enables you to use your own private DNS zone and avoid conflicts with other Azure resources.

## Disadvantages

- **Limited to Azure services** - Private Endpoint is currently only available for Azure services. It is not available for third-party services or on-premises resources.

- **Limited to specific Azure services** - Private Endpoint is currently only available for specific Azure services. It is not available for all Azure services.

- **Limited to specific regions** - Private Endpoint is currently only available in specific regions. It is not available in all regions.

- **Additional pricing** - Private Endpoint itself cost small amount of money. But some services support it only on higher SKU's, which cost more money. For example, Azure SQL Database Private Endpoint is only available on Premium and Business Critical SKUs.

### Pricing comparison between Azure subscription and Azure subscription with Private Endpoint

Let's say that you have a small web shop running on Azure. For CI/CD code is packaged into Docker containers and deployed to Azure Container Registry. From there it is deployed to Azure App Service. For simplicity, let's assume that it consists of a single Azure App Service and a single Azure SQL Database. The App Service is running on a Basic SKU and the SQL Database is running on a Standard SKU. 


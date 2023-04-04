# This document gives overview of using Azure Private Endpoints

Pros: 
Improved Security: Azure Private Endpoints help to secure your data by allowing you to restrict access to resources to only those who have authorized access. This means that you can keep your data and applications private, even if they are hosted in a public cloud environment. 
Reduced Latency: With Azure Private Endpoints, you can reduce the latency between your applications and data by keeping them within the same network. This helps to improve application performance and user experience. 
Simplified Networking: Private Endpoints simplify networking by allowing you to connect to your resources over a private network, rather than over the internet. This makes it easier to manage and secure your network. 

Cons: 
Additional Cost: Private Endpoints require additional resources, which can increase the cost of your Azure subscription. 
Limited Availability: Private Endpoints are not available for all Azure services, so you may not be able to use them for all of your applications and resources. 
Additional Configuration: Setting up Private Endpoints can be complex and requires additional configuration, which may require additional time and resources.
Cloud only: By default Private Endpoints are available only from Azure and requires additional resource (Azure Private DNS Resolver) for on-premises access.
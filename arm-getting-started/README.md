In the previous major version of Azure, a deployment backend model called Azure Service Manager (ASM) was used. With higher demand on scaling, being more flexible and more standardized a new model called the ARM was introduced and is now the standard way of
using Azure. 

This includes a new portal, a new way of looking at things as resources and a standardized API that every tool, including the Azure portal, that interacts with Azure uses. 

With this API and architectural changes, it's possible to use such things as Azure Resource Manager templates for any size of deployment. ARM templates are written in JavaScript Object Notation (JSON) and are a convenient way to define one or more resources and their relationship to another programmatically. This structure is then deployed to a resource group.
With this deployment model, it’s possible to define dependencies between resources as well as being able to deploy the exact same architecture again and again. The next part will dive a little deeper into resources. 

### REST API
All Azure Services, including the Azure Management Portal, provide their own REST APIs for their functionality. They can, therefore, be accessed by any application that RESTful Services can process. 
In order for software developers to write applications in the programming language of their choice, Microsoft offers wrapper classes for the REST APIs. 

### Understanding the Azure resource manager 

With the classic Azure system management, you could previously manage only one resource on the Azure platform at the same time. But what about more complex applications, as are common today? The infrastructure of today's applications typically consists of several components - a virtual machine, a storage account, a virtual network, a web app, a database, a database server, or a third-party service. To manage such complex applications, with the first preview of the Azure management portal 3.0, the concept of resource groups was introduced. 
You now see your components no longer as separate entities, but as related and interdependent parts of a single entity. So you will be able to manage all the resources of your application simultaneously. 
As an instrument for this type of management, the Azure resource manager (and the Azure resource manager tools) was introduced, and can be accessed via a variety of different technologies and interfaces. These access options include the following: 
* The traditional way via the Azure management portal (portal version 3.0 and newer) 
* The script-based way via Azure PowerShell (look for PowerShell modules with the prefix AzureRM) or via the cross-platform command-line interface Azure CLI 
* For developers, there are also SDKs available (.NET and some other programming languages) and, as with all Azure services, an extensive REST API 

### ARM
We now know that the Azure resource manager serves as the technical base for the provision of resources. How are we going to continue? First, we will deal with the basic workflows in Azure resource manager. Then, in the second part, we will look at working with templates. 
Some important facts that are important for all workflows: 
* All of the resources in your resource group have the same life cycle. You will deploy, update, and delete them at the same time. 
* Each resource can only exist in one resource group. 
* You can add or remove a resource to a resource group at any time. You can also move a resource from one resource group to another. 
* A resource group can contain resources that exist in different locations. 
* A resource can interact with a resource in another resource groups when the two resources are related but they do not share the same life cycle (for example, a web app connecting to a database). 

https://github.com/Azure/azure-arm-validator


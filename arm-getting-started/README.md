In the previous major version of Azure, a deployment backend model called Azure Service Manager (ASM) was used. With higher demand on scaling, being more flexible and more standardized a new model called the ARM was introduced and is now the standard way of
using Azure. 

This includes a new portal, a new way of looking at things as resources and a standardized API that every tool, including the Azure portal, that interacts with Azure uses. 

With this API and architectural changes, it's possible to use such things as Azure Resource Manager templates for any size of deployment. ARM templates are written in JavaScript Object Notation (JSON) and are a convenient way to define one or more resources and their relationship to another programmatically. This structure is then deployed to a resource group.
With this deployment model, it’s possible to define dependencies between resources as well as being able to deploy the exact same architecture again and again. The next part will dive a little deeper into resources. 

REST API
All Azure Services, including the Azure Management Portal, provide their own REST APIs for their functionality. They can, therefore, be accessed by any application that RESTful Services can process. 
In order for software developers to write applications in the programming language of their choice, Microsoft offers wrapper classes for the REST APIs. 

https://github.com/Azure/azure-arm-validator


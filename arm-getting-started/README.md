In the previous major version of Azure, a deployment backend model called Azure Service Manager (ASM) was used. With higher demand on scaling, being more flexible and more standardized a new model called the ARM was introduced and is now the standard way of using Azure. 

This includes a new portal, a new way of looking at things as resources and a standardized API that every tool, including the Azure portal, that interacts with Azure users. 

### Main features ARM

* Resources
* Role Based Access Control
* Infrastracture as a Code

### Resources
Azure Resource Manager is a unified application model that provides consistent end user experiences while interacting with the resource providers on the user behalf.

The Microsoft cloud platform delivers IaaS and PaaS services. These services are referred to as resources in the ARM model.


Beside the common properties that are shared across all services, a resource also has properties specific to each resource type. For example, a virtual network contains a concept of subnets, that is not relevant for storage accounts. Inversely, a storage account contains different redundancy options that are not relevant for a virtual network. To allow resources to contain their own properties and enable the introduction of new features to existing resources, each resource has its own API version. API versions ensure that your current configuration remains valid as new updates to a resource type are introduced.
The combination of the common contract and resource specific properties provides a solid foundation for future developments, while ensuring your current investments are applicable to new features and services for the public, hosted and private cloud. 

### Resource Groups
An application usually consists of multiple resources that are related to each other. Related application resources conceptually share a common lifecycle. Maintaining an application for its complete lifetime requires lifecycle management capabilities. In Azure Resource Manager, these capabilities are provided with Resource Groups. A resource group is an end-user facing concept that groups resources into a logical unit. A resource must always be part of a resource group and can only be part of a single resource group. By grouping resources into a resource group, an entire application can be managed as a single entity instead of a range of scattered individual resources.
For example, a virtual machine consists of a virtual hard disk that is stored in a storage account, a network interface card connected to a virtual network and an allocation of compute (CPU & RAM) resources. These components of a virtual machine are distinct resources in Azure. A resource group allows you to manage these related resources as a single logical entity with a shared common lifecycle.
A resource group can exist with no resources, a single resource or many resources. These resources can be sourced from one or multiple resource providers, spanning both IaaS and PaaS services.
A resource group cannot contain another resource group. All other Azure Resource Manager featuresintegrate tightly with the resource group concept.


With the classic Azure system management, you could previously manage only one resource on the Azure platform at the same time. But what about more complex applications, as are common today? The infrastructure of today's applications typically consists of several components - a virtual machine, a storage account, a virtual network, a web app, a database, a database server, or a third-party service. To manage such complex applications, , the concept of resource groups was introduced. 
You now see your components no longer as separate entities, but as related and interdependent parts of a single entity. So you will be able to manage all the resources of your application simultaneously. 
As an instrument for this type of management, the Azure resource manager (and the Azure resource manager tools) was introduced, and can be accessed via a variety of different technologies and interfaces. These access options include the following: 
* The traditional way via the Azure management portal (portal version 3.0 and newer) 
* The script-based way via Azure PowerShell (look for PowerShell modules with the prefix AzureRM) or via the cross-platform command-line interface Azure CLI 
* For developers, there are also SDKs available (.NET and some other programming languages) and, as with all Azure services, an extensive REST API 

### Infrastructure as Code
Organizations need to manage and operate their existing applications in a modern way, while also taking advantage of the cloud model whenever possible. This transformation shifts the organization from a traditional model to a cloud model.
In the traditional model applications are configured manually; with scripts, user interfaces, management utilities or likely a combination of all these tools. The result of this process is an application that is released to a specific environment. During the lifecycle of the application different tooling manages different aspects of the application. When changes are made, they are performed in the management tooling, locally on the resource or in related resources that may be shared with other applications.
Deploying two identical instances of an application with the same scripts on the same date, will most likely not have identical configurations over their complete lifecycle, even if that is the desired state.
To overcome these challenges, the concept of Infrastructure as Code was introduced. It allows you to define the desired state of your application in a template. The template is then used to deploy the application. The template provides the ability to repeat a deployment exactly but it can also ensure that a deployed application stays consistent with the desired state defined in the template over time. If you want to make a change to the application, you would make that change in the template. The template
can then be used to apply the desired state to the existing application instance over its complete lifecycle.

Templates can be parameterized; creating a reusable artifact that is used to deploy the same application to different environments, accepting the relevant parameters for each environment.

#### Imperative and declarative
Deploying and configuring resources can be a challenging task. An average application that is running in production has a complex architecture with many configuration settings. For a single deployment it might seem more appealing and time effective to configure all these settings manually instead of investing in automation, but it is inevitable that a shortcut will eventually be inefficient.
In general, we can distinguish two different programming types.
* Imperative syntax describes the how. It requires you to think about how to configure all the individual components of the application, and define that in a programming language.
* Declarative syntax describes the what. It requires you to define the desired state of your application and let a system determine the most efficient way to reach that state.
In the remainder of this whitepaper is explained how the Azure Resource Manager API accepts both declarative and imperative programming.

#### Template Orchestration
Azure Resource Manager provides powerful Infrastructure as Code capabilities. Any type of resource
that is available on the Microsoft cloud platform can be deployed and configured with Azure Resource
Manager. With a single template, you can deploy and configure multiple resources as a single
deployment operation. Templates allow you to deploy your complete application to an ideal operational
end state.

#### Language
Azure Resource Manager accepts JavaScript Object Notation (JSON) templates that comply with a JSON schema. JSON is an industry standard, human readable language.

You can follow along in this whitepaper as we build a simple template as the basis for this whitepaper. For our example create a new template file called azuredeploy.json. Copy and paste the following code, that contains all the top level elements, in to the file.
```
{
"$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
"contentVersion": "1.0.0.0",
"parameters": {},
"variables": {},
"resources": [],
"outputs": {}
}
```
An Azure Resource Manager template uses 6 top level elements. Each element has a distinct role in the
template:
1. $schema - Location of the JSON schema file that describes the version of the template language
1. contentVersion - Version of the template (such as 1.0.0.0). You can provide any value for this element. When deploying resources using the template, this value can be used to make sure that the right template is being used.
1. parameters - Values that are provided when deployment is executed to customize resource deployment.
1. variables - Values that are used as JSON fragments in the template to simplify template language expressions.
1. resources - Resource types that are deployed or updated in a resource group.
1. outputs - Values that are returned after deployment.

### Tooling
* https://azure.microsoft.com/en-us/documentation/articles/vs-azure-tools-resource-groups-deployment-projects-create-deploy/
* https://azure.microsoft.com/en-us/documentation/articles/resource-manager-vs-code/
### Template functions
Azure Resource Manager provides template functions that make the template orchestration engine very
powerful. Template functions enable operations on values within the template at deployment time. A
simple example of a template function is to concatenate two strings into a single string. You could use a
function that concatenate strings and pass in the two strings as parameters to the functions.
Template functions can be used in variables, resources and outputs in Azure Resource Manager
templates. Template functions can reference parameters, other variables or even objects related to the
deployment. For example, a template function can reference the ID of the resource group.

https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-functions/

### Parameter file
The example template in this whitepaper currently contains one parameter for the storage account
type. A template for a complete application can contain various different parameters. If you are
frequently deploying your template during the authoring process, the values for the parameters need to
be resubmitted each time. A parameter file can automate this process. A parameter file contains values
for the parameters in the template, and can be parsed when the template is deployed. Instead of
manually typing in the parameters, the values are pulled from the parameter file. You can create
multiple parameter files, representing different stages of an environment (Development, Testing,
Acceptance and Production – or, DTAP), different regions or different clouds.
You can create a parameter file with the name azuredeploy.parameters.json. For the storage
template, an example parameter file could contain the following code.

### Template reusability across clouds
Each Azure Resource Manager template needs to comply with a JSON schema. A JSON schema details a
structure for JSON data. In the context of Azure Resource Manager, the schema is a contract that details
the valid structure for an ARM template which is written in JSON. Each individual resource provider has
their own schema referenced from the master schema. These individual schemas detail properties that
are unique to each resource provider.
Within the JSON schema you still have some flexibility. You can decide to use a parameter or a variable
for a reusable value throughout the template. You can specify a fixed value or create a variable for
everything. However, to ensure reusability of a template across clouds you need to avoid region specific
dependencies in a template. Region specific dependencies are relevant when dealing with the location
of a resource, endpoints and API versions.

### Dependencies
Real applications are often connected in various ways that creates dependencies. The creation of a
resource in Azure can also depend on the existence of another resource. Creating a virtual machine,
requires a storage account and a virtual network to be present. When all the dependent resources are
deployed as part of the same template, the dependencies need to be defined. Without defining the
dependencies, the platform cannot determine the correct order necessary to deploy the resources. To
specify a dependency for a resource the following dependsOn attribute is used.



-----------
With this API and architectural changes, it's possible to use such things as Azure Resource Manager templates for any size of deployment. ARM templates are written in JavaScript Object Notation (JSON) and are a convenient way to define one or more resources and their relationship to another programmatically. This structure is then deployed to a resource group.
With this deployment model, it’s possible to define dependencies between resources as well as being able to deploy the exact same architecture again and again. The next part will dive a little deeper into resources. 


### ARM
We now know that the Azure resource manager serves as the technical base for the provision of resources. How are we going to continue? First, we will deal with the basic workflows in Azure resource manager. Then, in the second part, we will look at working with templates. 
Some important facts that are important for all workflows: 
* All of the resources in your resource group have the same life cycle. You will deploy, update, and delete them at the same time. 
* Each resource can only exist in one resource group. 
* You can add or remove a resource to a resource group at any time. You can also move a resource from one resource group to another. 
* A resource group can contain resources that exist in different locations. 
* A resource can interact with a resource in another resource groups when the two resources are related but they do not share the same life cycle (for example, a web app connecting to a database). 


### REST API
All Azure Services, including the Azure Management Portal, provide their own REST APIs for their functionality. They can, therefore, be accessed by any application that RESTful Services can process. 
In order for software developers to write applications in the programming language of their choice, Microsoft offers wrapper classes for the REST APIs. 

-----------
http://azuredeploy.net 

https://github.com/Azure/azure-arm-validator

https://blogs.technet.microsoft.com/uktechnet/2016/02/25/introduction-to-azure-resource-manager-templates-for-the-it-pro/

https://docs.microsoft.com/en-us/azure/devops/learn/what-is-infrastructure-as-code

https://blogs.msdn.microsoft.com/azuredev/2017/02/11/iac-on-azure-an-introduction-of-infrastructure-as-code-iac-with-azure-resource-manager-arm-template/

https://www.slideshare.net/AmazonWebServices/devops-on-aws-deep-dive-on-infrastructure-as-code

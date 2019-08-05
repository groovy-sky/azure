# Contents
* ["Getting started with Azure Resource Manager" presentation](https://gitpitch.com/groovy-sky/arm-template-101/master)
* [Azure Resource Manager overview](#azure-resource-manager-overview)
* [Labs](#labs)
   * [Entry level labs](#entry-level-labs)
   * [Intermediate level labs](#intermediate-level-labs)
   * [Advanced level labs](#advanced-level-labs)
* [Other resources](#other-resources)
---
# Azure Resource Manager overview

## Introduction

Azure is a big cloud with lots of services, and for even the most experienced user it can be intimidating to know which service will best meet your needs. 

## ASM vs ARM

In the previous major version of Azure, a deployment backend model called Azure Service Manager (ASM) was used. With higher demand on scaling, being more flexible and more standardized a new model called the ARM was introduced and is now the standard way of using Azure. 

This includes a new portal, a new way of looking at things as resources and a standardized API that every tool, including the Azure portal, that interacts with Azure users. 

## ARM

* Resources
* Role Based Access Control
* Infrastracture as a Code

### Resources
![](https://raw.githubusercontent.com/groovy-sky/getting-started-with-arm-template/master/assets/img/res_03.png)
Azure Resource Manager is a unified application model that provides consistent end user experiences while interacting with the resource providers on the user behalf. The Microsoft cloud platform delivers IaaS and PaaS services. These services are referred to as resources in the ARM model.

### Resource Groups
With the classic Azure system management, you could previously manage only one resource on the Azure platform at the same time.
The infrastructure of today's applications usually consists of multiple resources that are related to each other. Related application resources conceptually share a common lifecycle. Maintaining an application for its complete lifetime requires lifecycle management capabilities. In Azure Resource Manager, these capabilities are provided with Resource Groups. A resource group is an end-user facing concept that groups resources into a logical unit. A resource must always be part of a resource group and can only be part of a single resource group. By grouping resources into a resource group, an entire application can be managed as a single entity instead of a range of scattered individual resources.

Limitations:
* A resource group allows you to manage these related resources as a single logical entity with a shared common lifecycle.
* A resource group can exist with no resources, a single resource or many resources. These resources can be sourced from one or multiple resource providers, spanning both IaaS and PaaS services.
* A resource group cannot contain another resource group. All other Azure Resource Manager featuresintegrate tightly with the resource group concept.

### RBAC
![](https://raw.githubusercontent.com/groovy-sky/getting-started-with-arm-template/master/assets/img/rbac_02.png)
Access management for cloud resources is a critical function for any organization that is using the cloud. Role-based access control (RBAC) helps you manage who has access to Azure resources, what they can do with those resources, and what areas they have access to.

The way you control access to resources using RBAC is to create role assignments. This is a key concept to understand – it’s how permissions are enforced. A role assignment consists of three elements: security principal, role definition, and scope.

#### Security principal

A security principal is an object that represents a user, group, service principal, or managed identity that is requesting access to Azure resources.

* User - An individual who has a profile in Azure Active Directory. You can also assign roles to users in other tenants. For information about users in other organizations, see Azure Active Directory B2B.
* Group - A set of users created in Azure Active Directory. When you assign a role to a group, all users within that group have that role.
* Service principal - A security identity used by applications or services to access specific Azure resources. You can think of it as a user identity (username and password or certificate) for an application.
* Managed identity - An identity in Azure Active Directory that is automatically managed by Azure. You typically use managed identities when developing cloud applications to manage the credentials for authenticating to Azure services.

#### Role definition

A role definition is a collection of permissions. It's sometimes just called a role. A role definition lists the operations that can be performed, such as read, write, and delete. Roles can be high-level, like owner, or specific, like virtual machine reader.

Azure includes several built-in roles that you can use. The following lists four fundamental built-in roles. The first three apply to all resource types.

* Owner - Has full access to all resources including the right to delegate access to others.
* Contributor - Can create and manage all types of Azure resources but can’t grant access to others.
* Reader - Can view existing Azure resources.

#### Scope

Scope is the set of resources that the access applies to. When you assign a role, you can further limit the actions allowed by defining a scope. This is helpful if you want to make someone a Website Contributor, but only for one resource group.

In Azure, you can specify a scope at multiple levels: management group, subscription, resource group, or resource. Scopes are structured in a parent-child relationship.

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
![](https://raw.githubusercontent.com/groovy-sky/getting-started-with-arm-template/master/assets/img/decl_00.png)
Azure Resource Manager provides powerful Infrastructure as Code capabilities. Any type of resource
that is available on the Microsoft cloud platform can be deployed and configured with Azure Resource
Manager. With a single template, you can deploy and configure multiple resources as a single
deployment operation. Templates allow you to deploy your complete application to an ideal operational
end state.

#### Language
Azure Resource Manager accepts JavaScript Object Notation (JSON) templates that comply with a JSON schema. JSON is an industry standard, human readable language.
![](https://raw.githubusercontent.com/groovy-sky/getting-started-with-arm-template/master/assets/img/decl_02.png)

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
* $schema - Location of the JSON schema file that describes the version of the template language
* contentVersion - Version of the template (such as 1.0.0.0). You can provide any value for this element. When deploying resources using the template, this value can be used to make sure that the right template is being used.
* parameters - Values that are provided when deployment is executed to customize resource deployment.
* variables - Values that are used as JSON fragments in the template to simplify template language expressions.
* resources - Resource types that are deployed or updated in a resource group.
* outputs - Values that are returned after deployment.

### REST API
![](https://raw.githubusercontent.com/groovy-sky/getting-started-with-arm-template/master/assets/img/start_00.png)
All Azure Services, including the Azure Management Portal, provide their own REST APIs for their functionality. They can, therefore, be accessed by any application that RESTful Services can process. 
In order for software developers to write applications in the programming language of their choice, Microsoft offers wrapper classes for the REST APIs. 

### Template functions
Azure Resource Manager provides template functions that make the template orchestration engine very
powerful. Template functions enable operations on values within the template at deployment time. A
simple example of a template function is to concatenate two strings into a single string. You could use a
function that concatenate strings and pass in the two strings as parameters to the functions.
Template functions can be used in variables, resources and outputs in Azure Resource Manager
templates. Template functions can reference parameters, other variables or even objects related to the
deployment. For example, a template function can reference the ID of the resource group.

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

## Used materials

* http://geekswithblogs.net/Mathoms/archive/2008/10/28/red-dog--windows-azure-and-the-azure-services-platform.aspx
* https://www.theregister.co.uk/2008/10/27/microsoft_amazon/
* https://azure.microsoft.com/en-us/updates/azure-portal-updates-for-classic-portal-users/
* https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-deployment-model

* http://azuredeploy.net 

* https://github.com/Azure/azure-arm-validator

* https://blogs.technet.microsoft.com/uktechnet/2016/02/25/introduction-to-azure-resource-manager-templates-for-the-it-pro/

* https://docs.microsoft.com/en-us/azure/devops/learn/what-is-infrastructure-as-code

* https://blogs.msdn.microsoft.com/azuredev/2017/02/11/iac-on-azure-an-introduction-of-infrastructure-as-code-iac-with-azure-resource-manager-arm-template/

* https://www.slideshare.net/AmazonWebServices/devops-on-aws-deep-dive-on-infrastructure-as-code

* https://docs.microsoft.com/en-us/azure/architecture/cloud-adoption/getting-started/azure-resource-access

---
# Labs
## Entry level labs
* [Create resources using a portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-quickstart-create-templates-use-the-portal)

## Intermediate level labs
* [Create a Linux VM using Azure CLI](https://docs.microsoft.com/en-us/cli/azure/azure-cli-vm-tutorial?view=azure-cli-latest)
* [Create a Linux VM using Azure Powershell](https://docs.microsoft.com/en-us/powershell/azure/azureps-vm-tutorial?view=azps-1.5.0)

## Advanced level labs
Docker-related labs:
1. [Runing Docker from a browser using Azure Cloud Shell](https://lnkd.in/dy9nnnV)
1. [Scan Azure's virtual machines using dockerized NMAP](https://lnkd.in/gt7UMz2)

Ansible-related labs:
1. [Create and configure Ansible Tower](https://lnkd.in/g3gsW3r)
1. [Create Azure virtual machine using Ansible Tower](https://lnkd.in/diUNrU9)

SonarQube-related labs:
1. [Build SonarQube server in Azure](https://lnkd.in/gjctEN8)
1. [Integrate SonarQube with Azure DevOps pipeline](https://lnkd.in/gYpvA6D)

# Other resources
* [Microsoft Learing Paths](https://docs.microsoft.com/learn)
* [ARM QuickStart Templates](https://github.com/Azure/azure-quickstart-templates)

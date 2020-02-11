# Infrastructure as Code 
![](/images/iac/logo_transparent.png)

## Introduction
This article describes my personal experience of trying to build Infrastructure as Code by configuring a firewall solution in Azure.

Overall result contains multiple levels of abstractions and we will explore one by one. And a first Matryoshka in the chain is Azure Resource Manager: 

![](/images/iac/abstraction_00.png)

## Azure Resource Manager

Azure Resource Manager is a unified application model that provides consistent end user experiences while interacting with the resource providers on the user behalf. The Microsoft cloud platform delivers IaaS and PaaS services. These services are referred to as resources in the ARM model.

Resource Manager template - A JavaScript Object Notation (JSON) file that defines one or more resources to deploy to a resource group or subscription. The template can be used to deploy the resources consistently and repeatedly. See Template deployment overview.
declarative syntax - Syntax that lets you state "Here is what I intend to create" without having to write the sequence of programming commands to create it. The Resource Manager template is an example of declarative syntax. In the file, you define the properties for the infrastructure to deploy to Azure. See Template deployment overview.

#### Imperative and declarative
Deploying and configuring resources can be a challenging task. An average application that is running in production has a complex architecture with many configuration settings. For a single deployment it might seem more appealing and time effective to configure all these settings manually instead of investing in automation, but it is inevitable that a shortcut will eventually be inefficient.
In general, we can distinguish two different programming types.
* Imperative syntax describes the how. It requires you to think about how to configure all the individual components of the application, and define that in a programming language.
* Declarative syntax describes the what. It requires you to define the desired state of your application and let a system determine the most efficient way to reach that state.
In the remainder of this whitepaper is explained how the Azure Resource Manager API accepts both declarative and imperative programming.

![](/images/iac/json_template.png)

### Template format
ARM template structure:
![](/images/iac/json_description.png)


## Results

## Related information

* https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview

* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview
# Infrastructure as Code (part 1)
![](/images/iac/logo_transparent.png)

## Introduction
This article describes my personal experience configuring a networking solution in Azure using Infrastructure as Code concept.

With Infrastructure as Code (IaC) approach managing an environment should be in the same manner as managing a code.

We will explore in a phased approach and this time let's take a look on Azure:

![](/images/iac/abstraction_00.png)

## Azure Resource Manager
![](/images/iac/asm_vs_arm.png)

Azure Resource Manager is the replacement for Azure Service Manager (aka Azure Classic).

Azure Resource Manager is a unified application model that provides consistent end user experiences while interacting with the resource providers on the user behalf. The Microsoft cloud platform delivers IaaS and PaaS services. These services are referred to as resources in the ARM model.


#### Imperative and declarative
Deploying and configuring resources can be a challenging task. An average application that is running in production has a complex architecture with many configuration settings. For a single deployment it might seem more appealing and time effective to configure all these settings manually instead of investing in automation, but it is inevitable that a shortcut will eventually be inefficient.
In general, we can distinguish two different programming types.
* Imperative syntax describes the how. It requires you to think about how to configure all the individual components of the application, and define that in a programming language.
* Declarative syntax describes the what. It requires you to define the desired state of your application and let a system determine the most efficient way to reach that state.
In the remainder of this whitepaper is explained how the Azure Resource Manager API accepts both declarative and imperative programming.

![](/images/iac/json_template.png)

### Template format


Resource Manager template - A JavaScript Object Notation (JSON) file that defines one or more resources to deploy to a resource group or subscription. The template can be used to deploy the resources consistently and repeatedly. 
declarative syntax - Syntax that lets you state "Here is what I intend to create" without having to write the sequence of programming commands to create it. The Resource Manager template is an example of declarative syntax. In the file, you define the properties for the infrastructure to deploy to Azure. 

General Guidelines for ARM Templates is available [here](https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/best-practices.md#azure-resource-manager-templates---best-practices-guide).

ARM template structure:
![](/images/iac/json_description.png)

#### Parameters
Parameters should be used for collecting input to customize the deployment. Values such as username and password (secrets) must always be parameterized. Other values, such as public endpoints (accessed by humans) or SKUs (that affect the cost of the workload) should be parameterized, but also allow for defaultValues to simplify deployment and provide suggestions to the user appropriate for a given application or workload.

## Practical part

At first create new resource group:
![](/images/iac/az_create_demo_group.png)

You can deploy [following template](/azure/azuredeploy.json) in any preferable for you way (different options described [here](https://github.com/Azure/azure-quickstart-templates/blob/master/101-vm-simple-linux/GettingStarted-linux.md)) or click on a button below and fill required fields: <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure%2Fmaster%2Fiac-00%2Fazure%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a> ![](/images/iac/az_template_finish.png)


## Results
![](/images/iac/nginx_demo_check.png)
## Related information

* https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview

* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview
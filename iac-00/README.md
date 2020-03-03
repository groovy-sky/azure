# Infrastructure as Code (part 1)
![](/images/iac/logo_transparent.png)

## Introduction
In the cloud era provisioning an environment in a traditional way is a time-consuming and costly process. Application programming interfaces (API) provided by the cloud provider helps to automate the provisioning of it's infrastructure. Infrastructure as Code makes such automation possible.

![](/images/iac/cloud_journey_00.png)

Without IaC, teams must maintain the settings of individual deployment environments. Over time, each environment becomes a snowflake, that is, a unique configuration that cannot be reproduced automatically. With snowflakes, administration and maintenance of infrastructure involves manual processes which were hard to track and contributed to errors. 

This and the following articles describe how to work with Infrastructure as Code (IaC) approach in Microsoft Azure.

## Azure Resource Manager
![](/images/iac/asm_vs_arm.png)

Azure Resource Manager is the replacement for Azure Service Manager (aka Azure Classic), which originally provided only the classic deployment model. In classic model, each resource existed independently; there was no way to group related resources together. 

Azure Resource Manager is a unified application model that provides consistent end user experiences while interacting with the resource providers on the user behalf. These services are referred to as resources in the ARM model. One of the main advantages of Resource Manager templates allow you to create and deploy an entire Azure infrastructure declaratively. 

## Declarative model

![](/images/iac/one_script.png)

Deploying and configuring resources can be a challenging task. An average application that is running in production has a complex architecture with many configuration settings. For a single deployment it might seem more appealing and time effective to configure all these settings manually instead of investing in automation, but it is inevitable that a shortcut will eventually be inefficient. The declarative approach—also known as the functional approach—is the best fit. In the declarative approach, you specify the desired final state of the infrastructure you want to provision and the IaC software handles the rest—spinning up the virtual machine (VM) or container, installing and configuring the necessary software, resolving system and software interdependencies, and managing versioning. The chief downside of the declarative approach is that it typically requires a skilled administrator to set up and manage, and these administrators often specialize in their preferred solution.

In the imperative approach—also known as the procedural approach—the solution helps you prepare automation scripts that provision your infrastructure one specific step at a time. While this can be more work to manage as you scale, it can be easier for existing administrative staff to understand and can leverage configuration scripts you already have in place.

### Template format

Resource Manager template - A JavaScript Object Notation (JSON) file that defines one or more resources to deploy to a resource group or subscription. The template can be used to deploy the resources consistently and repeatedly. 
declarative syntax - Syntax that lets you state "Here is what I intend to create" without having to write the sequence of programming commands to create it. 

General Guidelines for ARM Templates is available [here](https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/best-practices.md#azure-resource-manager-templates---best-practices-guide).

ARM template structure:
![](/images/iac/json_description.png)

#### Parameters
Parameters should be used for collecting input to customize the deployment. Values such as username and password (secrets) must always be parameterized. Other values, such as public endpoints (accessed by humans) or SKUs (that affect the cost of the workload) should be parameterized, but also allow for defaultValues to simplify deployment and provide suggestions to the user appropriate for a given application or workload.

#### Variables
In the variables section, you construct values that can be used throughout your template. You don't need to define variables, but they often simplify your template by reducing complex expressions.

#### Resources
In the resources section, you define the resources that are deployed or updated. Each resource is defined separately. If there are dependencies between resources, they must be described in the resource definition. For example, if a Virtual Machine depends on a Storage Account, this will be defined in the Virtual Machine resource declaration. Azure Resource Manager analyzes dependencies to ensure resources are created in the correct order, and there is no meaning to the order in which the resources are defined in the template.

### Template limitations

* Size < 4 MB (after it has been expanded with iterative resource definitions)
* 256 parameters
* 256 variables
* 800 resources (including copy count)
* 64 output values
* 24,576 characters in a template expression


## Practical part

At first create new resource group (please don't use 'demo-group' name - choose any other value):
![](/images/iac/az_create_demo_group.png)

When you deploy resources to a resource group, the resource group stores metadata about the resources. The metadata is stored in the location of the resource group.

Once the group has been created the next thing that must be done is [demo template](https://raw.githubusercontent.com/groovy-sky/iaac-demo/master/azure/azuredeploy.json) deployment. If you haven't used ARM template before - you can use <a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fiaac-demo%2Fmaster%2Fazure%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/> </a> button for an overall view. Main parts are following:

![](/images/iac/arm_structure.png)

The template deploys a Ubuntu OS VM and installs NGINX on that server.

You can deploy in any preferable for you way or just click on <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fiaac-demo%2Fmaster%2Fazure%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a> button and fill required fields: 

</a> ![](/images/iac/az_template_finish.png)


## Summary
After deployment will be finished you can validate that VM is running and find out its DNS:
![](/images/iac/nginx_demo_check_00.png)

Check NGINX installation by accessing VMs DNS:
![](/images/iac/nginx_demo_check_01.png)


One of main disadvantages of using a pure ARM templating - you don't have to define your entire infrastructure in a single template. Often, it makes sense to divide your deployment requirements into a set of targeted, purpose-specific templates.

## Related information

* https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview

* https://www.ibm.com/cloud/learn/infrastructure-as-code

* https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview

* https://github.com/Azure/azure-quickstart-templates/blob/master/101-vm-simple-linux/GettingStarted-linux.md

* https://docs.microsoft.com/en-us/azure/devops/learn/what-is-infrastructure-as-code

* https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/deployment-models

* https://azure.microsoft.com/en-us/resources/templates/
# Lazy Introduction to Terraform on Azure (part 3)

## Introduction

![](/images/terraform/lazy_intro_logo.png)

In the previous tutorial, we created a basic Virtual Network (VNet) and associated Network Security Group (NSG). To explore more deployment options, we will be using an Azure Resource Manager template to deploy a Virtual Machine (VM) within a resource group. Additionally, we will cover the concept of a Terraform state.

## Theoretical Part

Before delving into the practical part, it is important to understand some concepts related to this tutorial. In the previous tutorial, only the "azurerm" provider was used. However, this time, two more providers, ["random"](https://registry.terraform.io/providers/hashicorp/random/latest/docs) and ["http"](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http), will be introduced. The first one will be used to generate a random password for the VM, and the second one will be used to check the HTTP response from the VM's web server.

Not only does Terraform allow resources to be worked with declaratively, but Azure itself also provides a way to define infrastructure as code (IaC) using Azure Resource Manager (ARM) templates. [ARM template](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/overview) are JSON files that define the infrastructure and configuration for deployments. They use a declarative syntax and allow you to declare what you intend to deploy without having to write the sequence of programming commands to create it. In this tutorial, ARM templates will be used to create a resource group and a VM.

Another important concept in Terraform is [the state file](https://www.terraform.io/docs/language/state/index.html). The state file maps the resources in the configuration to real-world objects. Terraform uses this file to understand the resources it manages and to persist the values of output variables between runs. By default, the state is a file stored locally, named "terraform.tfstate".

In the previous tutorial, output values were used to pass information between different Terraform deployments. The difference between the output and the state file is that the output file is generated after the configuration is applied, and it contains the values of the output variables.

## Practical Part

In this part of the tutorial, the [deployment-02](https://github.com/groovy-sky/lazy-intro-az-terraform/tree/main/deployment-02) directory will be used for the Terraform deployment. The configuration has the following content:

* [main.tf](https://github.com/groovy-sky/lazy-intro-az-terraform/blob/main/deployment-02/main.tf): This is the main configuration file that contains the provider configurations, locals, data sources, resources, and output. The "prefix" local is used to generate unique names for the resources, and the "location" local is used to specify the location of the resources. The "random_password" resource generates a random password for the VM. The "state file" data source retrieves the "subnet_id" output value from the previous Terraform deployment. The "azurerm_subscription_template_deployment" and "azurerm_resource_group_template_deployment" resources deploy ARM templates to create a resource group and a VM, respectively. The "http" data source checks the HTTP response from the VM. Finally, the HTTP response body from the VM is output.

* [rg.json](https://github.com/groovy-sky/lazy-intro-az-terraform/blob/main/deployment-02/rg.json) - This ARM template is a blueprint for creating a resource group in Azure.

* [vm.json](https://github.com/groovy-sky/lazy-intro-az-terraform/blob/main/deployment-02/vm.json) - This ARM template is a blueprint for a virtual machine deployment in Azure with a specific network configuration and running an Nginx web server.

## Results

As a result of applying the Terraform configuration, you should see the following output:

![](/images/terraform/02_rg_overview.png)


![](/images/terraform/02_tf_output.png)


## Summary

In that chapter, the main focus was on two things. Firstly, the ARM template - a declarative way to define Azure resources that is native to Azure. Using ARM templates allows for the encapsulation of a deployment, deployment of Azure services that are not supported by Terraform (either for a new service or a new feature), and utilization of quickstart ARM templates. Secondly, the tutorial discussed Terraform state – a requirement for Terraform to function. The only issue with the default setting is that it stores the state locally, which can lead to problems in a team environment. In the next part of the tutorial, the Terraform remote state usage and how to store it in Azure will be discussed.


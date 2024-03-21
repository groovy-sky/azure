# Lazy Introduction to Terraform on Azure (part 2)

![](/images/terraform/lazy_intro_logo.png)

## Introduction

Welcome back to the second part of our tutorial series - a Lazy Introduction to Terraform on Azure. In the previous part, we learned about the fundamentals of Terraform, including its core components and workflow, and had an overview of how Terraform works. As we continue with this tutorial, we'll go beyond the theoretical knowledge and implement what we've learned. This part will provide a hands-on example of deploying Azure resources using Terraform. Specifically, we'll create an Azure resource group, a virtual network (VNet), and a network security group (NSG) associated with it. 

## Theoretical Part

Terraform relies on plugins called providers to interact with cloud service providers, SaaS providers, and other APIs. For managing resources in Azure, there are several providers:

* **AzureRM Provider**: The AzureRM Provider is the most comprehensive and widely used provider for managing resources in Azure. It supports a broad range of Azure resources and services, allowing you to create, manage, and configure most aspects of an Azure-based infrastructure using Terraform.
* **AzureAD Provider**: The AzureAD Provider is specifically designed for working with Azure Active Directory (Azure AD). It allows you to manage resources related to Azure AD such as users, groups, and applications. This provider is typically used in conjunction with the AzureRM provider to manage identity and access-related aspects of your Azure infrastructure.
* **AzAPI Provider**: The AzAPI (Azure API) Provider is a community-driven provider that is less common and not officially supported by HashiCorp or Microsoft. It is intended for use cases where specific Azure functionality is not covered by the AzureRM or AzureAD providers. The AzAPI provider allows for direct interaction with the Azure REST API, giving you the flexibility to manage Azure resources that are not yet supported by the official providers.

While all these providers work with Azure, they each have specific use cases. AzureRM is the most comprehensive for general Azure resource management and will be used in this tutorial.

Now, let's delve into some of the main components of Terraform configuration files:
* **Locals and Variables**: These constructs are essential for enhancing the readability and reusability of your Terraform configuration. 'Locals' assign names to expressions, enabling you to reuse them within your configuration without the need for repetition. 'Variables', on the other hand, serve as input values to your Terraform configuration, allowing you to customize the properties of the resources that Terraform will create.
* **Inputs and Outputs**: These are the means by which you interact with your Terraform configuration. 'Inputs' are parameters that you can pass to your configuration to tailor its behavior according to your requirements. 'Outputs', conversely, provide a mechanism to extract data from your Terraform configuration. For instance, you may output the public IP address of a created compute instance, enabling you to establish a connection with it once Terraform completes its creation process.
* **Modules and Resources**: These are foundational elements of a Terraform configuration. A 'Module' serves as a container for multiple resources that are utilized in conjunction, facilitating the abstraction of common blocks of configuration into reusable infrastructure components. A 'Resource' represents an object type in a provider's API that Terraform is capable of managing. This could be a compute instance in a cloud provider's platform or a user account in an identity provider's system, to cite a few examples.

Locals, variables, inputs, outputs can be a different type of data:
* **string**: a sequence of Unicode characters representing some text, like "hello".
* **number**: a numeric value. The number type can represent both whole numbers like 15 and fractional values like 6.283185.
* **bool**: a boolean value, either true or false. bool values can be used in conditional logic.
* **list** (or tuple): a sequence of values, like ["us-west-1a", "us-west-1c"]. Identify elements in a list with consecutive whole numbers, starting with zero.
* **set**: a collection of unique values that do not have any secondary identifiers or ordering.
* **map** (or object): a group of values identified by named labels, like {name = "Mabel", age = 52}.

We'll be using all of these components in our practical example. It's important to understand these concepts, as they are fundamental to how Terraform manages infrastructure.


## Practical Part


In this part of the tutorial, we're going to be using a real-world example to understand how Terraform works with Azure. This time [deployment-01](https://github.com/groovy-sky/lazy-intro-az-terraform/tree/main/deployment-01) directory will be used for Terraform deployment. For better visibility and understanding, we'll split configuration in multiple files:

1. [providers.tf](https://github.com/groovy-sky/lazy-intro-az-terraform/blob/main/deployment-01/providers.tf) used to configure the named provider, in our case **azurerm**, which is responsible for creating and managing resources. 

2. [variables.tf](https://github.com/groovy-sky/lazy-intro-az-terraform/blob/main/deployment-01/variables.tf) contains one variable definition for the virtual network. This variable contains the address space and subnet name in the form of a map.

3. [outputs.tf](https://github.com/groovy-sky/lazy-intro-az-terraform/blob/main/deployment-01/outputs.tf) is used to define the output values that will be displayed after configuration is applied. In our case, we'll output the subnet ID of the virtual network we create.

4. [main.tf](https://github.com/groovy-sky/lazy-intro-az-terraform/blob/main/deployment-01/main.tf) is the main configuration file that contains the resources definition. Additionally, it includes the 'prefix' local  and 'deployment-00' module from [the previous part](../tf-intro-00/README.md). Local value is a function that returns current directory name and module is used to get the location of the resource group.

The resource blocks define the infrastructure objects we'll be creating. This time it will be an Azure resource group, a virtual network, and a network security group. The virtual network will have a subnet with a security group associated with it. The security group will have a rule allowing inbound traffic on port 80. 

To apply the configuration, clone the repository and navigate to the deployment-01 directory. Run ```terraform init``` to initialize the working directory and download the AzureRM provider. Then run ```terraform apply``` to create the resources. 



## Results

As a result of applying the Terraform configuration, you should see the following output:


![](/images/terraform/01_rg_overview.png)

## Summary

In this segment of the tutorial, we have gained insights into creating Azure resources utilizing Terraform. We have further delved into the primary elements of Terraform configuration files, encompassing providers, locals, variables, inputs, outputs, modules, and resources. Additionally, we have illustrated the application of these components through a practical example. In the ensuing segment, our focus will shift towards understanding the Terraform state and the methodology to manage it.


## References

* [Best practices for using Terraform by Google](https://cloud.google.com/docs/terraform/best-practices-for-terraform)
* [Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
# Lazy Introduction to Terraform on Azure (part 1)

## Introduction

![](/images/terraform/lazy_intro_logo.png)

This tutorial offers a quick introduction to using Terraform, an open-source tool, for managing infrastructure in Microsoft Azure. It is designed for beginners who want to understand the basics of Terraform and how to use it to manage infrastructure on Azure.  

## Theoretical Part

Terraform, developed by HashiCorp, is Infrastructure as Code (IaC) tool that uses a declarative configuration language to define and provision data center infrastructure. It follows a declarative approach to infrastructure management, where you specify your desired infrastructure state, and Terraform figures out how to achieve it. In other words, Terraform allows you to manage your infrastructure as code. 
  
Terraform itself primarily consists of:  
- **Terraform Core** - a statically-compiled binary written in Golang that takes care of the orchestration of resources and the state management.
- **Terraform Providers/Plugins** - executable binaries invoked by Terraform Core over RPC. Providers are responsible for managing resources in the cloud, on-premises, or in SaaS applications.
- **Terraform CLI (Command Line Interface)**: A command-line tool that interacts with Terraform Core and the Providers. 

Using Terraform CLI user can deploy, manage, and update an infrastructure.Terraform creates and manages resources on cloud platforms and other services through their application programming interfaces (APIs) using providers. The typical Terraform workflow consists of the following steps:

* **Write**: You define resources, which will be deployed to a platform, in a configuration file using the HashiCorp Configuration Language (HCL). This file is usually named `main.tf`.
* **Plan**: Terraform creates an execution plan describing the infrastructure it will create or modify based on your configuration.
* **Apply**: On approval, Terraform will apply changes to the infrastructure. It will create, modify, or delete resources as necessary to achieve the desired state.
* **Destroy**: When you no longer need the infrastructure, you can destroy it using Terraform. This will delete all the resources that were created by Terraform.

After Terraform applies the changes, it records the current state of the infrastructure in a state file, which acts as a source of truth for your environment. Terraform uses the state file to determine the changes to make to your infrastructure so that it will match your configuration.

## Prerequisites

To run this tutorial you need:
* Azure account. If you don't have one, you can create a free account [here](https://azure.microsoft.com/en-us/free/).
* Terraform installed on your machine. You can download Terraform from [here](https://developer.hashicorp.com/terraform/install).

As this is a lazy tutorial you can use the Azure Cloud Shell to run the commands. The Azure Cloud Shell is a free interactive shell that you can use to run the steps in this tutorial. Intruction how-to initialize the Azure Cloud Shell can be found [here](https://learn.microsoft.com/en-us/azure/cloud-shell/get-started/classic?tabs=azurecli).

## Practical Part

For this tutorial, all examples are stored in a separate repository, which can be found at https://github.com/groovy-sky/lazy-intro-az-terraform.git. You can clone and run these examples in any environment that you prefer.

However, for the sake of simplicity and due to our inherent laziness, we'll be using Azure Cloud Shell for our demonstrations. The Cloud Shell eliminates the need to install any local tools or shell configurations for the tutorial, allowing us to focus on the learning process.

First, you need to clone the repository and navigate to it:

```
git clone https://github.com/groovy-sky/lazy-intro-az-terraform.git  
cd lazy-intro-az-terraform/deployment-00  
```

Now, initialize your Terraform configuration with ``` terraform init ```  command.:


![](/images/terraform/00_tf_init.png)

To create an execution plan, run ``` terraform plan ``` command:

![](/images/terraform/00_tf_plan.png)

This will show you a preview of what changes Terraform will make to your infrastructure, without actually applying these changes. It's a way to check your work before making real changes.
 
Finally, apply the changes, using ``` terraform apply ``` command, required to reach the desired state of your configuration. This will make the actual changes to your infrastructure as per your configuration:

![](/images/terraform/00_tf_apply.png)
 
## Results

There is only one file (main.tf) under lazy-intro-az-terraform/deployment-00 directory, which has following content:

```
locals {  
  default_location = "West Europe"  
}  
  
output "location" {  
  value = local.default_location  
}  
```
 
In this code are declared two values: 
* **default_location** local value with "West Europe" value 
* **location** output value with local.default_location value in it


Outputs are only rendered when Terraform applies your plan. Running ```terraform plan``` will not render outputs. Outputs are a way to tell Terraform what data your configuration generates. This could be IDs, names, or any other attributes associated with a resource. They can be used to extract information about the infrastructure, which can then be used to feed into other operations or used for reporting and querying.

In our example, "location" output will return the value of the local.default_location, which is "West Europe".

## Summary

The first part of the tutorial introduced the basics of Terraform, an Infrastructure as Code tool. This section covered essential components of Terraform.

From practical point of view nothing was done, but the repository was cloned and Terraform commands were executed. The configuration in this case doesn't specify any provider or resource, which means it doesn't manage any specific infrastructure at this point. 

Not so useful for now, but some value will be added in the next part of this tutorial.
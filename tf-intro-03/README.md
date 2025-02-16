# Lazy Introduction to Terraform on Azure (part 4)

 
## Introduction

 
In the previous tutorial, we deep dived into Azure Resource Manager (ARM) templates and the concept of a Terraform state. This time, we will focus on deploying a storage account using an ARM template, which will be used to store the remote state file. This practice is crucial in team environments to avoid conflicts and issues when multiple people are applying changes simultaneously.

## Theoretical Part
 
Before we get to the practical section, let's revisit the concept of a Terraform state file and introduce what a remote state file is. As we've seen in earlier parts of this series, the Terraform state file is a critical component that maps the resources in your configuration to the real-world objects they represent. Essentially, it's Terraform's way of keeping track of what has been deployed and how it correlates to your configuration files.

In a local setting, this state file is stored on your machine, but when working in a team environment, a local state file can lead to conflicts. This is where a remote state file comes in. A remote state file is stored in a shared location accessible to all team members, such as an Azure Storage Account. This ensures that everyone on the team has a consistent view of the infrastructure state, thereby preventing conflicts and issues when multiple people are applying changes simultaneously.

Next, let's talk about Terragrunt. Terragrunt is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state. Terragrunt utilizes the underlying Terraform commands while providing additional features like locking and error handling, applying and destroying modules in the right order, and managing remote state files. Its main value comes in large projects where the infrastructure is defined across multiple Terraform modules and environments, and there's a need for a lot of boilerplate code to manage these resources.

### Remote State

Terraform's default behavior is to store its state data locally in a file named terraform.tfstate. This can complicate team collaborations, as each user has to make sure they're working with the latest state data and that no one else is running Terraform concurrently. To solve this, Terraform offers remote state, where it writes the state data to a remote data store accessible to all team members. Supported remote stores include Terraform Cloud, HashiCorp Consul, Amazon S3, Azure Blob Storage, Google Cloud Storage, and Alibaba Cloud OSS.

Remote state enhances delegation and teamwork by allowing output values to be shared with other configurations, enabling infrastructure to be broken down into smaller components. It also allows teams to share infrastructure resources in a read-only way. For instance, a core infrastructure team can build core machines, networking, etc., and expose certain information for other teams to run their own infrastructure. Despite its convenience, some may prefer using more general stores to pass settings both to other configurations and consumers. For example, using HashiCorp Consul to have one Terraform configuration that writes to Consul and another that consumes those values.

Azure Storage blobs are automatically locked before any operation that writes state. This pattern prevents concurrent state operations, which can cause corruption.

### Backend

Terraform, an infrastructure resource management tool, uses a backend to store its state data files. The backend is a critical component that defines where Terraform will store its data. This information is important because it allows multiple users to access the state data and collaborate on the infrastructure resources.

By default, Terraform relies on a 'local' backend, storing the state data as a local file on the user's disk. However, there are several built-in backends that a user can configure to meet specific needs. To configure a backend, users are required to add a 'backend' block to their configuration. It's important to note, however, that a configuration can only provide one backend block, and this block cannot refer to named values.

Security is a significant concern when dealing with backends, as state data often contains sensitive information. For this reason, it's recommended to use environment variables to supply credentials. This ensures that sensitive data is not exposed unnecessarily.

Interestingly, if a configuration does not include a backend block, Terraform will default to using the 'local' backend, which stores state as a plain file in the current working directory. This flexibility allows users to start quickly and add more complex backend configurations as needed.

Modifications to a backend configuration necessitate reinitialization with the 'terraform init' command. This process validates and configures the backend, preparing it for further plans, applications, or state operations. In case of changing backends, Terraform provides an option to migrate the state to the new backend, ensuring no state data is lost during the transition.

Another notable feature is the concept of partial configuration. This allows users to specify only a subset of the required arguments in the backend configuration. Any omitted arguments can then be provided during the initialization process. This can be particularly helpful when automation scripts are used to run Terraform, as it allows for the automatic provision of certain arguments.


A backend in Terraform defines where the state data files are stored. These state data files are used by Terraform to keep track of the resources it manages. In most non-trivial configurations, Terraform either integrates with Terraform Cloud or uses a backend to store state data remotely. This allows multiple people to access and work together on the state data. The backend can be configured by adding the backend block to your configuration.

By default, Terraform uses a local backend, storing state as a local file on disk. However, there are also built-in backends that can be configured to store state remotely. Some of these backends function like remote disks for state files, while others provide support for locking the state during operations to prevent conflicts and inconsistencies. These built-in backends are the only backends available; additional backends cannot be loaded as plugins.

## Practical Part

 
The practical part of this tutorial involves setting up the Azure infrastructure to support remote state management and using Terragrunt to propagate the state file across all directories.

We start with setting up the Azure infrastructure. In the main.tf file, we first create a resource group. This resource group will host the storage account that we'll use to store the Terraform state file. Next, we deploy an ARM template using "azurerm_resource_group_template_deployment". This ARM template creates a unique storage account based on the tenant ID and subscription ID.

Once the storage account is created, we retrieve it using the "azurerm_storage_account" data source. This data source is used to fetch the storage account details, which we'll need to configure the backend for the remote state file.

To store the state file, we create a storage container in the storage account for each directory that contains a Terraform configuration file. This is done using the "azurerm_storage_container" resource. We use a loop to create a storage container for each directory listed in the "directories_list" local value.

With the Azure infrastructure in place, we move on to the Terragrunt configuration. The terragrunt_script.sh script is used to automate the process of setting up Terragrunt for each directory. The script first obtains the storage account name and access key from the Terraform output. It then generates a root.hcl file in the parent directory and a terragrunt.hcl file in each deployment directory. These files configure Terragrunt to use the Azure storage account as the backend for the remote state file.

With this setup, each directory has its own state file stored remotely in the created storage account. This ensures a consistent view of the infrastructure state across the team and prevents conflicts when applying changes.

## Summary
 
In this part, we covered how to create a storage account in Azure using an ARM template and how to store the Terraform state file remotely in this storage account. This practice is essential in team environments to maintain a consistent view of the infrastructure state and prevent conflicts and issues. In the next part of the tutorial, we'll dive deeper into managing and organizing Terraform configurations in a team environment.

## References

* [Securing Terraform State in Azure](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/securing-terraform-state-in-azure/ba-p/3787254)
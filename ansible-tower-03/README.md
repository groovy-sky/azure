# Let's build a tower (part 4) [draft]

## Introduction

[Last time](https://github.com/groovy-sky/azure/blob/master/ansible-tower-02/README.md) we have installed NGINX package on Azure VM using AWX. In this chapter we will create an Azure environment using AWX.

## Architecture
Ansible ships with a number of modules (called the ‘module library’) that can be executed directly on remote hosts or through Playbooks. For interacting with Azure services, Ansible includes a suite of [Ansible cloud modules](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure) that provides the tools to easily create and orchestrate Azure.

This time we shall need [azure_rm_virtualmachine module](https://docs.ansible.com/ansible/latest/modules/azure_rm_virtualmachine_module.html#azure-rm-virtualmachine-module), which is used by [azure-vm-creation/main.yml Playbook](https://raw.githubusercontent.com/groovy-sky/tower-examples/master/azure-vm-creation/main.yml). Playbook we be executed on host itself:

![Deployment schema](/images/ansible-tower/awx_acrch.png)

## Prerequisites
To be able to create a new resources in Azure we will need an account with some priveleges level. [Azure Resource Management model](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview) provdes granular [Role-Based Access Control model]((https://docs.microsoft.com/en-us/azure/role-based-access-control/overview)) for assigning privileges. The account itself could be, as [an official documentation says](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html), a user account or a service principal (aka SPN). In case of using service principal we will need to get following parameters:
* CLIENT ID
* CLIENT SECRET
* SUBSCRIPTION ID
* TENANT ID

We will create a new service principal account and grant 'Contributor' role for a Resource Group (you can choose whatever resource group you want for that). Instruction how-to create SPN and assign role to it is in the text below(please store somewhere values marked with red):
1. Create Service principal
![Create SPN](/images/ansible-tower/aad_app_spn_reg.png)
1. Generate a secret(aka application key)
![Get Application ID and key](/images/ansible-tower/aad_app_spn_data.png)
1. Go to the Resource Group
![Subscription ID](/images/ansible-tower/get_sub_id.png)
1. Grant 'Contributor' role
![Assign permission](/images/ansible-tower/grant_access_spn.png)
1. Find Tenant ID
![Find tenant ID](/images/ansible-tower/get_tenant_id.png)

## Implementation
As we already added the SCM in the previous chapter we only need to update our project:
![Update the project](/images/ansible-tower/awx_update_project.png)

As the Playbook will be executed on Tower host itself - we need to create new inventory(no need to add a host):
![Create new inventory](/images/ansible-tower/awx_inventory_localhost.png)


As we want to run [our deployment Playbook](https://raw.githubusercontent.com/groovy-sky/tower-examples/master/azure-vm-creation/main.yml) on different environment and don't expose security data, it contain following variables (wrapped into double curly brackets):
* vm_resource_group - deployment Azure Resource Group name
* vm_name - newly created Azure Virtual Machine name
* vm_admin_username - Azure VM username (which match [username requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm))
* vm_admin_password - Azure VM password (which match [password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm))

As our Playbook repository is publiсly visible we can't use [group variables](https://docs.ansible.com/ansible-tower/latest/html/administration/tipsandtricks.html#importing-existing-inventory-files-and-host-group-vars-into-tower) to assign values to the variables. Instead we can use [extra variables](https://docs.ansible.com/ansible-tower/latest/html/userguide/job_templates.html#extra-variables). Below you can copy a blank, which you need to fill (with values obtained in previous heading):
```
---
vm_resource_group: xxxxxxxxxxxx
vm_name: xxxxxxxxxxxx
vm_admin_username: xxxxxxxxxxxx
vm_admin_password: xxxxxxxxxxxx
```

Now we can create a new project (don't forget to specify extra variables) and run it:
![](/images/ansible-tower/awx_new_template.png)

## Results

If everything went according to plan and job was successful - in the Resource Group should appear a new virtual machine.
![Results](/images/ansible-tower/azure_vm_creation_results.png)

## Useful documentation

https://docs.microsoft.com/en-us/azure/role-based-access-control/overview

https://docs.ansible.com/ansible/2.3/guide_azure.html

https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/ansible-tower-rhel/images/ansibletower-postdeployment-configuration-guide.pdf

https://cloudblogs.microsoft.com/opensource/2018/09/24/tutorial-devops-on-azure-using-jenkins-and-ansible/

https://docs.microsoft.com/en-us/azure/ansible/ansible-overview

https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

https://docs.ansible.com/ansible/latest/user_guide/modules.html

## References

[Let's build a tower (part 1)](/ansible-tower-00/README.md)

[Let's build a tower (part 2)](/ansible-tower-01/README.md)

[Let's build a tower (part 3)](/ansible-tower-02/README.md)


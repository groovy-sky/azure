# Let's build a tower (part 4) [draft]

## Introduction

[Last time](https://github.com/groovy-sky/azure/blob/master/ansible-tower-02/README.md) we have installed NGINX package on Azure VM using AWX. In this chapter we will deploy Azure environment using AWX.

## Architecture
Ansible ships with a number of modules (called the ‘module library’) that can be executed directly on remote hosts or through Playbooks. For interacting with Azure services, Ansible includes a suite of [Ansible cloud modules](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure) that provides the tools to easily create and orchestrate your infrastructure on Azure.

This time we shall need [azure_rm_virtualmachine module](https://docs.ansible.com/ansible/latest/modules/azure_rm_virtualmachine_module.html#azure-rm-virtualmachine-module), which is used by [azure-vm-creation/main.yml Playbook](https://raw.githubusercontent.com/groovy-sky/tower-examples/master/azure-vm-creation/main.yml). Playbook we be executed on host itself:

![Deployment schema](/images/ansible-tower/awx_acrch.png)

## Prerequisites
To be able create a new environment in Azure we will need an account with some access level on Subscription-level or specific Resource Group. The account could be, as [an official documentation says](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html), a user account or a service principal. In case of using service principal we will need to get following parameters:
* CLIENT ID
* CLIENT SECRET
* SUBSCRIPTION ID
* TENANT ID

We will create a new service principal and grant 'Contributor' role for some Resource Group - which will grant full access in a resource group to the service principal except grant access to others accounts. How-to instruction is below(please store values marked with red):
1. Service principal creation
![Create SPN](/images/ansible-tower/aad_app_spn_reg.png)
1. Generating application key
![Get Application ID and key](/images/ansible-tower/aad_app_spn_data.png)
1. Assign role on some Resource Group
![Assign permission](/images/ansible-tower/grant_access_spn.png)
1. Get Subscription ID of the Resource Group
![Subscription ID](/images/ansible-tower/get_sub_id.png)
1. Get Tenant ID
![Find tenant ID](/images/ansible-tower/get_tenant_id.png)

## Implementation
As we already added the SCM in the previous chapter we only need to update our project:
![Update the project](/images/ansible-tower/awx_update_project.png)

As the playbook will be executed on Tower host itself - we need to create new inventory(no need to add a host):
![Create new inventory](/images/ansible-tower/awx_inventory_localhost.png)

[group variables](https://docs.ansible.com/ansible-tower/latest/html/administration/tipsandtricks.html#importing-existing-inventory-files-and-host-group-vars-into-tower)

[extra variables](https://docs.ansible.com/ansible-tower/latest/html/userguide/job_templates.html#extra-variables)

```
---
vm_resource_group: xxxxxxxxxxxx
vm_name: xxxxxxxxxxxx
vm_admin_username: xxxxxxxxxxxx
vm_admin_password: xxxxxxxxxxxx
```
![](/images/ansible-tower/awx_new_template.png)

![](/images/ansible-tower/awx_azure_vm_project_run.png)

## Results

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


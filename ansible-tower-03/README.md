# Let's build a tower (part 4) [draft]

## Introduction

[Last time](https://github.com/groovy-sky/azure/blob/master/ansible-tower-02/README.md) we have installed NGINX package on Azure VM using AWX. In this chapter we will deploy Azure environment using AWX.

## Architecture
Ansible ships with a number of modules (called the ‘module library’) that can be executed directly on remote hosts or through Playbooks. As we, most of the time, will work with Azure, we will use [Azure modules](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure). 

This time we shall need [azure_rm_virtualmachine module](https://docs.ansible.com/ansible/latest/modules/azure_rm_virtualmachine_module.html#azure-rm-virtualmachine-module), which is used by [azure-vm-creation/main.yml Playbook](https://raw.githubusercontent.com/groovy-sky/tower-examples/master/azure-vm-creation/main.yml). Playbook we be executed on host itself:

![Deployment schema](/images/ansible-tower/awx_acrch.png)

## Prerequisites
To be able create a new environment in Azure we will need an account with some access level on Subscription-level or specific Resource Group. The account could be, as [an official documentation says](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html), a user account or a service principal. 

We will create a new service principal and grant 'Contributor' role for a Resource Group:
1. Service principal creation
![Create SPN](/images/ansible-tower/aad_app_spn_reg.png)
![Get Application ID and key](/images/ansible-tower/aad_app_spn_data.png)
2. Assign role to the SPN
![Assign permission](/images/ansible-tower/grant_access_spn.png)
![Find tenant ID](/images/ansible-tower/get_tenant_id.png)
![Subscription ID](/images/ansible-tower/get_sub_id.png)


## Implementation

![Update the project](/images/ansible-tower/awx_update_project.png)
![Create new inventory](/images/ansible-tower/awx_inventory_localhost.png)
![](/images/ansible-tower/awx_new_template.png)
![](/images/ansible-tower/xxxxxxxxxxxxxxxxx.png)

```
---
vm_resource_group: xxxxxxxxxxxx
vm_name: xxxxxxxxxxxx
vm_admin_username: xxxxxxxxxxxx
vm_admin_password: xxxxxxxxxxxx
```

![](/images/ansible-tower/xxxxxxxxxxxxxxxxx.png)


## Results

![Results](/images/ansible-tower/azure_vm_creation_results.png)

## Useful documentation

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


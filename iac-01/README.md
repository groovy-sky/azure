# Infrastructure as Code (part 2)
![](/images/iac/logo_transparent.png)

## Introduction

This article describes the second part of Infrastructure as Code approach (previous part about ARM is available [here](/iac-00/README.md)). With this in mind, let’s look at an infrastructure orchestration.

![](/images/iac/cloud_journey_01.png)

Orchestration is about bringing together disparate things into a coherent whole. There are many different kinds of orchestrations solutions such as Chef, Terraform, Puppet, Ansible. The last is an open-source tool, which was designed to help organizations automate provisioning, configuration management, and application deployment. 

## Theoretical Part

### Ansible

Ansible does not use agents or a custom security infrastructure that must be present on a target machine to work properly. Instead, Ansible connects to compute hosts  using SSH/WinRM protocol. 

Furthermore, it is divisible into 3 parts:

* Ansible Plays & Playbooks
* Ansible Engine and Ansible Modules
* Managed Infrastructure

![](/images/iac/ansible_main_parts.png)

### Ansible Plays & Playbooks

![](/images/iac/ansible_playbook.png)

A declarative automation tool, Ansible lets you create ‘playbooks’ (written in the YAML configuration language) to specify the desired state for your infrastructure and then does the provisioning for you.

Each playbook is composed of one or more ‘plays’ in a list. The function of a play is to map a set of instructions defined against a particular host. Plays, like tasks, run in the order specified in the playbook: top to bottom.


### Ansible Engine and Ansible Modules

![](/images/iac/ansible_engine.png)

Written in Python, Ansible engine itself doesn't provide wide functionality. Modules do the actual work in Ansible, they are what gets executed.

There are three types of Ansible modules:

* Core modules – These are modules that are supported by Ansible itself.
* Extra modules – These are modules that are created by communities or companies but are included in the distribution that may not be supported by Ansible.
* Deprecated modules – These are identified when a new module is going to replace it or a new module is actually more preferred.

In this demo you will need [modules for interacting with Azure](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure). 

### Managed Infrastructure

![](/images/iac/ansible_infra.png)

Ansible is simple and powerful, allowing users to easily manage various physical and virtual devices - including the provisioning of bare metal servers, cloud environment,network/storage devices and much more.


## Prerequisites

To be able to use Ansible for managing Microsoft Azure we will need:
* Linux environment (Windows currently [is not supported](https://docs.ansible.com/ansible/latest/user_guide/windows_faq.html#can-ansible-run-on-windows)) to run Ansible engine. 
* [Ansible cloud module](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure) for interacting with Azure services
* [Valid credentials](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html#authenticating-with-azure) for accessing Azure (Username/Password or Service Principal Credentials)

[Azure Cloud Shell](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/cloud-shell/persisting-shell-storage.md#create-new-storage)

Azure Cloud Shell is an interactive, browser-accessible shell for managing Azure resources. It provides the flexibility of choosing the shell experience that best suits the way you work - Bash or PowerShell.

![](/images/iac/azure_cli_init.png)

## Practical Part

Deployment repository is located [here](https://github.com/groovy-sky/iaac-demo). Its structure looks following:

![](/images/iac/iac_ansible_structure.png)

[![Embed launch](https://shell.azure.com/images/launchcloudshell.png "Launch Azure Cloud Shell")](https://shell.azure.com)
```
[ ! -d "iaac-demo/.git" ] && git clone https://github.com/groovy-sky/iaac-demo
cd iaac-demo && git pull
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook ansible/main.yml -e azure_group_name='<azure-group-name>'
```


## Summary

## Related information

* https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html

* https://www.ansible.com/integrations/cloud/microsoft-azure

* https://docs.microsoft.com/en-us/azure/ansible/ansible-overview

* https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

* https://github.com/microsoft/AnsibleLabs

* https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/cloud-shell/persisting-shell-storage.md#create-new-storage

* https://www.azuredevopslabs.com/labs/vstsextend/ansible/

* https://azure.microsoft.com/en-gb/overview/what-is-iaas/

* https://devblogs.microsoft.com/azuregov/utilizing-paas-services-and-arm-deployment-templates-on-azure-government/

* https://www.ansible.com/use-cases/orchestration

* https://serversforhackers.com/c/an-ansible2-tutorial

* https://docs.microsoft.com/en-us/azure/ansible/ansible-run-playbook-in-cloudshell
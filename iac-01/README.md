# Infrastructure as Code (part 2)
![](/images/iac/logo_transparent.png)

## Introduction

This article describes the second part of Infrastructure as Code approach (previous part about ARM is available [here](/iac-00/README.md)). With this in mind, let’s look at an infrastructure orchestration.

![](/images/iac/cloud_journey_01.png)

Orchestration is about bringing together disparate things into a coherent whole. There are many different kinds of orchestrations solutions such as Chef, Terraform, Puppet, Ansible and many others. All of the referenced tools were developed with a specific purpose or intent in mind. Choosing an appropriate tool requires a way of understanding an application field. 

This document gives an example of using Ansible to manage Azure resources. 

## Theoretical Part

### Ansible

Ansible is an open-source tool, which was designed to help organizations automate provisioning, configuration management, and application deployment. It does not use agents or a custom security infrastructure that must be present on a target machine to work properly. Instead, Ansible connects to compute hosts using SSH/WinRM protocol. 

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

Ansible Engine is made up of the components central to Ansible automation – the task engine, OpenSSH and WinRM transports, and the Ansible language itself. 

Written in Python, Ansible engine itself doesn't provide wide functionality. Modules do the actual work in Ansible, they are what gets executed.

There are three types of Ansible modules:

* Core modules – These are modules that are supported by Ansible itself.
* Extra modules – These are modules that are created by communities or companies but are included in the distribution that may not be supported by Ansible.
* Deprecated modules – These are identified when a new module is going to replace it or a new module is actually more preferred.

In this demo will be used [modules for interacting with Azure](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure) and [Core modules](https://docs.ansible.com/ansible/latest/modules/core_maintained.html). 

### Managed Infrastructure

![](/images/iac/ansible_infra.png)

Ansible is simple and powerful, allowing users to easily manage various physical and virtual devices - including the provisioning of bare metal servers, cloud environment,network/storage devices and much more.

## Prerequisites

To deploy [a demo environment]() you will need:
* Linux environment (Windows currently [is not supported](https://docs.ansible.com/ansible/latest/user_guide/windows_faq.html#can-ansible-run-on-windows)) to run Ansible engine. 
* [Ansible cloud module](https://docs.ansible.com/ansible/latest/modules/list_of_cloud_modules.html#azure) for interacting with Azure services
* [Valid credentials](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html#authenticating-with-azure) for accessing Azure (Username/Password or Service Principal Credentials)

Azure Cloud Shell is a silver bullet, which satisfies all requirements. Azure Cloud Shell is an interactive, browser-accessible shell (Bash or PowerShell) with [a wide range of tools](https://docs.microsoft.com/en-us/azure/cloud-shell/features#deep-integration-with-open-source-tooling), which you can get for [a price of a storage account](https://docs.microsoft.com/en-us/azure/cloud-shell/overview#pricing).

![](/images/iac/az_cloud_shell.png) 

Before going to the next section you will need to do initial configuration(more detailed information about it is available [here](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/cloud-shell/persisting-shell-storage.md#create-new-storage)):

![](/images/iac/azure_cli_init.png)

## Practical Part

**Azure Resource Manager and Ansible have declarative syntax, which allows to redeploy this demo as many times as you may wish.**

To deploy a demo environment you need to:
1. Choose existing or create a new resource group in Azure
2. Open Cloud Shell (from the Azure portal or by clicking on [![Embed launch](https://shell.azure.com/images/launchcloudshell.png "Launch Azure Cloud Shell")](https://shell.azure.com))
3. Use the resource group name (by replacing ```<azure-group-name>``` value) to execute following commands in Cloud Shell:

```
[ ! -d "iaac-demo/.git" ] && git clone https://github.com/groovy-sky/iaac-demo
cd iaac-demo && git pull
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook ansible/main.yml -e azure_group_name='<azure-group-name>'
```

The whole thing takes less than 10 minutes:
![](/images/iac/ansible_in_shell.gif)

### How it works

As you might have guessed, 'https://github.com/groovy-sky/iaac-demo' repository contains all required files:
![](/images/iac/iac_repo_info.png)

Command ```ansible-playbook ansible/main.yml``` runs several plays, which simplified structure looks following:
![](/images/iac/ansible_flow.png)

From a practical point of view Ansible:
1. Deploys Virtual Machine with installed NGINX
2. Whitelists Ansible host's public IP in NSG
3. Generates SSH private/public key and using them access VM
4. Replace default web page with a custom content 

## Results
If deployment was successful you should, by accessing VM's public IP/DNS, get a hello message:
![](/images/iac/ansible_results.png)


## Summary
At this point you've deployed Azure environment and made some changes on it. Moreover, it used Cloud-native template file, which leads to the fact that Ansible can be used not only as a replacement of Azure, but rather as empowerment for it. If you're wondering what advantages has Azure Template together with Ansible usage over pure use of Ansible, here is the list:
* Template support advanced scenarios. For example, you need to build non-standard environment - a virtual machine with two network cards, which is connected to internal and external Load Balancer. It is possible to create one template which will deploy such environment.
* With a template you can use default values for parameters. For example, you can specify default VM size or a resource location. This makes Ansible clearer (as it has less parameters) 
* Ansible modules doesn't cover all resources available in Azure. Azure have huge amount of different services and each day Microsoft announce something new. Of course ARM template covers that all as it is a part of Azure ecosystem.

![](/images/iac/ans_and_arm.png)

The main drawback of this approach is the absence of a centralized management. The next time I am going to come up with an idea how to improve a situation.

## Related information

* https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html

* https://www.ansible.com/integrations/cloud/microsoft-azure

* https://docs.microsoft.com/en-us/azure/ansible/ansible-overview

* https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

* https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/cloud-shell/persisting-shell-storage.md#create-new-storage

* https://www.ansible.com/use-cases/orchestration

* https://docs.microsoft.com/en-us/azure/ansible/ansible-run-playbook-in-cloudshell
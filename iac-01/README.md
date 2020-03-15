# Infrastructure as Code (part 2)
![](/images/iac/logo_transparent.png)

## Introduction


![](/images/iac/cloud_journey_01.png)



## Theoretical Part

### Ansible

Modern organizations are increasingly using dynamic cloud platforms, whether public or private, to exploit digital technology to deliver services and products to their users. Automation is essential to managing continuously changing and evolving systems, and tools that define systems “as code” have become dominant for this.

Ansible was built to simplify the complexity of task automation and orchestration. Ansible does not require an agent to be installed in the hosts. It supports both push and pull models to send commands to its Linux nodes via the SSH protocol, and the WinRM protocol to send commands to its Windows nodes. It is predominantly advanced in configuration management tasks, but it can also behave as an infrastructure orchestration tool. Ansible is very flexible and can cover bare-metal machines, virtual machines and platforms, and public or private cloud environments.


![](/images/iac/ansible_main_parts.png)


Ansible is a simple automation language that can perfectly describe an IT application infrastructure in Ansible Playbooks.

It's an automation engine that runs Ansible Playbooks. Ansible Engine runs Ansible Playbooks, the automation language that can perfectly describe an IT application infrastructure.

Main parts:

* Ansible Plays & Playbooks
* Ansible Engine and Ansible Modules
* Managed Infrastructure


### Ansible Plays & Playbooks
Playbooks are Ansible’s configuration, deployment, and orchestration language. They can describe a policy you want your remote systems to enforce, or a set of steps in a general IT process.

If Ansible modules are the tools in your workshop, playbooks are your instruction manuals, and your inventory of hosts are your raw material.

At a basic level, playbooks can be used to manage configurations of and deployments to remote machines. At a more advanced level, they can sequence multi-tier rollouts involving rolling updates, and can delegate actions to other hosts, interacting with monitoring servers and load balancers along the way.

Playbooks are designed to be human-readable and are developed in a basic text language. There are multiple ways to organize playbooks and the files they include, and we’ll offer up some suggestions on that and making the most out of Ansible.

### Ansible Engine and Ansible Modules

Ansible engine itself doesn't provide wide functionality. Modules do the actual work in Ansible, they are what gets executed.

There are three types of Ansible modules:

* Core modules – These are modules that are supported by Ansible itself.
* Extra modules – These are modules that are created by communities or companies but are included in the distribution that may not be supported by Ansible.
* Deprecated modules – These are identified when a new module is going to replace it or a new module is actually more preferred.

### Managed Infrastructure

## Prerequisites

* Linux OS with installed Ansible and Azure module
* 

## Practical Part

### Accessing Azure from Ansible

Using the Azure Resource Manager modules requires authenticating with the Azure API. You can choose from two authentication strategies:

* Active Directory Username/Password
* Service Principal Credentials

### Configuring Azure CLI
Azure Cloud Shell is an interactive, browser-accessible shell for managing Azure resources. It provides the flexibility of choosing the shell experience that best suits the way you work. Linux users can opt for a Bash experience, while Windows users can opt for PowerShell. For this demo we need a Bash option:

![](/images/iac/azure_cli_init.png)

```
git clone https://github.com/groovy-sky/iaac-demo
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook iaac-demo/ansible/main.yml -e azure_group_name='demo-group'
```


## Summary

## Related information

* https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html

* https://www.ansible.com/integrations/cloud/microsoft-azure

* https://docs.microsoft.com/en-us/azure/ansible/ansible-overview

* https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal
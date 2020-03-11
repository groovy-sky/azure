# Infrastructure as Code (part 2)
![](/images/iac/logo_transparent.png)

## Introduction


![](/images/iac/cloud_journey_01.png)



## Ansible
Introduction

Modern organizations are increasingly using dynamic cloud platforms, whether public or private, to exploit digital technology to deliver services and products to their users. Automation is essential to managing continuously changing and evolving systems, and tools that define systems “as code” have become dominant for this.

Ansible was built to simplify the complexity of task automation and orchestration. Ansible does not require an agent to be installed in the hosts. It supports both push and pull models to send commands to its Linux nodes via the SSH protocol, and the WinRM protocol to send commands to its Windows nodes. It is predominantly advanced in configuration management tasks, but it can also behave as an infrastructure orchestration tool. Ansible is very flexible and can cover bare-metal machines, virtual machines and platforms, and public or private cloud environments.


## Main components
![](/images/iac/ansible_main_parts.png)


Ansible is a simple automation language that can perfectly describe an IT application infrastructure in Ansible Playbooks.

It's an automation engine that runs Ansible Playbooks. Ansible Engine runs Ansible Playbooks, the automation language that can perfectly describe an IT application infrastructure.

Main parts:

* Ansible Plays & Playbooks
* Ansible Engine and Ansible Modules
* Managed Infrastructure


### Ansible Plays & Playbooks


### Ansible Engine and Ansible Modules


### Managed Infrastructure

## Practical part

### Authenticating with Azure

Using the Azure Resource Manager modules requires authenticating with the Azure API. You can choose from two authentication strategies:

* Active Directory Username/Password
* Service Principal Credentials


## Summary

## Related information

* https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html

* https://www.ansible.com/integrations/cloud/microsoft-azure

* https://docs.microsoft.com/en-us/azure/ansible/ansible-overview
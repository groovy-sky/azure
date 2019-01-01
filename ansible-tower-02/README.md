# Let's build a tower (part 3) [draft]

## Introduction

[On previous chapter](/ansible-tower-01) we configured Azure AD authentication and created hello-world project. Now we can try to do something more useful. For example, we could try to install NGINX package on some test VM using AWX. 

## How AWX works

The Ansible structure is agentless(it connects using SSH), and configurations are set up as playbooks written in YAML.

With the Tower we can manage playbooks and playbook directories by either placing them manually under the Project Base Path on the server, or by placing playbooks into a source code management (SCM) system supported by Tower, including Git, Subversion, Mercurial, and Red Hat Insights:
![Scheme](/images/ansible-tower/awx_flow.png)

## Prerequisites

In our example we will use following configuration:

![Scheme](/images/ansible-tower/awx_current_flow.png)

Such configuration main parts are:
* Source Code Management system - in our case we will use [following Github repository](https://github.com/groovy-sky/tower-examples.git)
* AWX Host
* Test Azure VM - in our case we can create another virtual machine in Azure

If you are using MSDN Azure subscription - as a test Azure VM you can use free account virtual machine(otherwise just create [standard Ubuntu VM](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal#create-virtual-machine)):
![Create Azure VM](/images/ansible-tower/create_test_vm_node.png)

Next step - allow SSH access from AWX host to the test node and open 80 port:
![NSG rule](/images/ansible-tower/test_node_nsg_rule_00.png)
![NSG rule](/images/ansible-tower/test_node_nsg_rule_01.png)

## Workflow
1. Create an inventory
1. Add a host to the inventory
1. Create a credential
1. Setup a project
1. Create a job template
1. Launch the template

https://docs.ansible.com/ansible-tower/latest/html/userguide/projects.html
https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html

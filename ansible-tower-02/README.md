# Let's build a tower (part 3)

## Introduction

[On previous chapter](/ansible-tower-01) we configured Azure AD authentication and created hello-world project. Now we can try to do something more practical, for example, we could try to install NGINX package on a test environment. 

## Architecture

![Scheme](/images/ansible-tower/awx_flow.png)

The Ansible structure is agentless(it connects using SSH), and configurations are set up as playbooks written in YAML.

With the Tower we can manage playbooks and playbook directories by either placing them manually under the Project Base Path on the server, or by placing playbooks into a source code management (SCM) system supported by Tower, including Git, Subversion, Mercurial, and Red Hat Insights.

## Prerequisites

![Scheme](/images/ansible-tower/awx_current_flow.png)

In our example we will use configuration, which contain 3 parts:
* Source Code Management system - we will use [our demo Github repository](https://github.com/groovy-sky/tower-examples.git)
* AWX Host - already created before
* Test Azure VM - in our case we can create another virtual machine in Azure. To do that we can use free account virtual machine (available for a [MSDN Azure subscription](https://azure.microsoft.com/en-us/pricing/member-offers/credit-for-visual-studio-subscribers/) )or just create [standard Ubuntu VM](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal#create-virtual-machine)):
![Create Azure VM](/images/ansible-tower/create_test_vm_node.png)

Also we need to configure [NSG](https://docs.microsoft.com/en-us/azure/virtual-network/manage-network-security-group) - enable SSH access from AWX host(which IP address you need to obtain from your environment)and open 80 port:
![NSG rules](/images/ansible-tower/test_node_nsg_rules.png)

## Implementation

On AWX side we need to configure and run job template. To do that, please, complete following steps:
1. Create an inventory
1. Add a host to the inventory
1. Create a credential
1. Setup a project
1. Create a job template
1. Launch the template

### Inventory creation

Inventory - a collection of hosts against which Jobs may be launched. Let's use understandable title:
![New Inventory](/images/ansible-tower/create_azure_inventory.png)

### Host adding

Now we can add Public IP address of our test VM to the hosts:
![New Host](/images/ansible-tower/add_azure_first_host.png)

### Credentials creation

Credentials in our case - are username and password values used to create test node:
![New Credentials](/images/ansible-tower/create_azure_credentials.png)

### Project setup

A Project is a logical collection of Ansible playbooks, represented in Tower. In this article we are using [following Github repository](https://github.com/groovy-sky/tower-examples.git):
![New Project](/images/ansible-tower/create_tower_project.png)

### Template creation

A job template is a definition and set of parameters for running an Ansible job. In the example below we are applying "nginx-hello-world/main.yml" playbook to the "Azure Inventory" using "Azure Credentials" to access the test node:
![New Template](/images/ansible-tower/create_azure_template.png)

### Results

After project configuration we can run it:
![Run Template](/images/ansible-tower/run_template.png)

If template run job was successfull - we can try to access test node by HTTP:
![Check the results](/images/ansible-tower/check_job_results.png)

## Useful documentation

[About Azure NSG](https://blogs.msdn.microsoft.com/igorpag/2016/05/14/azure-network-security-groups-nsg-best-practices-and-lessons-learned/)

[About Ansible playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html)

[About AWX inventories](https://docs.ansible.com/ansible-tower/latest/html/userguide/inventories.html)

[About AWX project](https://docs.ansible.com/ansible-tower/latest/html/userguide/projects.html)

[About job templates](https://docs.ansible.com/ansible-tower/latest/html/userguide/job_templates.html)

## References

[Let's build a tower (part 1)](/ansible-tower-00/README.md)

[Let's build a tower (part 2)](/ansible-tower-01/README.md)

[Let's build a tower (part 3)](/ansible-tower-02/README.md)

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

Next step is [NSG](https://docs.microsoft.com/en-us/azure/virtual-network/manage-network-security-group) configuration by enabling SSH access from AWX host(which IP address you need to obtain from your environment) to the test node and opening 80 port on the test node:
![NSG rules](/images/ansible-tower/test_node_nsg_rules.png)

As a result the test node NSG should look following:
![NSG rules](/images/ansible-tower/test_node_nsg_inbound.png)

## Implementation

1. Create an inventory
1. Add a host to the inventory
1. Create a credential
1. Setup a project
1. Create a job template
1. Launch the template

### Inventory creation
![New Inventory](/images/ansible-tower/create_azure_inventory.png)

### Host creation
![New Host](/images/ansible-tower/add_azure_first_host.png)

### Credentials creation
![New Credentials](/images/ansible-tower/create_azure_credentials.png)

### Project setup
![New Project](/images/ansible-tower/create_tower_project.png)

### Template creation
![New Template](/images/ansible-tower/create_azure_template.png)

### Job running
![Run Template](/images/ansible-tower/run_template.png)

### Results
![Check the results](/images/ansible-tower/check_job_results.png)


## Useful documentation
https://docs.ansible.com/ansible-tower/latest/html/userguide/projects.html
https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html
https://blogs.msdn.microsoft.com/igorpag/2016/05/14/azure-network-security-groups-nsg-best-practices-and-lessons-learned/

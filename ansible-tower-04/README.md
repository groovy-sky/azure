# Let's build a tower (part 5) [draft]

## Introduction

Welcome to another post in our "Let's build a tower" series. In our previous posts, we discussed [how to deploy AWX to Azure](https://lnkd.in/g3gsW3r), [configure its authentication](https://lnkd.in/gEdp66V) and [run a playbook](https://lnkd.in/diUNrU9).

This time we will discuss how to set up Workflow Job Template and run them against Azure inventory.

## Architecture

Our Workflow contains following steps:
1. Get the latest version of playbooks from [our demo SCM](https://github.com/groovy-sky/tower-examples.git)
2. Deploy Azure virtual machine
3. Install NGINX on Azure VM
![](/images/ansible-tower/project_arch.png)


## Prerequisites

https://github.com/groovy-sky/azure/tree/master/ansible-tower-03#prerequisites

We will start on configuring Azure side 
![](/images/ansible-tower/assign_role.png)

## Implementation

Ansible Tower is centered around the idea of organizing Projects (which run your playbooks via Jobs) and Inventories (which describe the servers on which your playbooks should be run) inside of Organizations. Organizations can then be set up with different levels of access based on Users and Credentials grouped in different Teams. It can be a little overwhelming at first, but once you get the initial structure configured, you'll see how powerful and flexible Tower's Project workflow is.

### Project configuration

[Tower projects](https://www.ansible.com/blog/getting-started-with-ansible-tower-projects-inventories) are a logical collection of Ansible Playbooks that are set up with each other based on what they might be doing or which hosts they might interact with.

Playbooks can be managed within Tower projects by either adding them manually to the project base path on your Tower server, (/var/lib/awx/projects) or by importing them from a source control management system (SCM) that is supported by Tower (Git, Subversion and Mercurial)

This time we will add [the Github repository](https://github.com/groovy-sky/tower-examples.git) and synhronize it:
![](/images/ansible-tower/tower_playbooks.png)
![](/images/ansible-tower/sync_project.png)


### Inventory configuration

Within Tower, the hosts that you interact with are set up as collections within Tower called inventories. Tower divides inventories into groups and the groups are what contain the actual hosts. Groups can be sourced manually by adding the IPs and hostnames into Tower, imported from an Ansible hosts file, or they can be sourced from one of Ansible Tower’s supported cloud providers.

We need to create two empty inventories - "LOCALHOST" and "NGINX inventory":
![](/images/ansible-tower/awx_invent.png)

During the workflow deployed VM IP address will be added to "NGINX inventory" inventory.

### Credentials configuration

Credentials play a crucial role in job templates as they are how Ansible Tower will connect to the machine or cloud to complete the execution of the ansible playbook.

To be able run job templates we will need to create following credentials:
1. "Azure SPN" - service account credentials for Azure deployment
1. "NGINX VM administrator" - deployed virtual machines access credentials
1. "Tower Credentials" - AWX service account credentials, which will be used to store delpoyed VM public IP

![](/images/ansible-tower/awx_credentials.png)

### Job Templates configuration

[Job templates](https://www.ansible.com/blog/getting-started-setting-up-an-ansible-job-template) are a definition and set of parameters for running an Ansible Playbook. In Ansible Tower, job templates are a visual realization of the ansible-playbook command and all flags you can utilize when executing from the command line. A job template defines the combination of a playbook from a project, an inventory, a credential and any other Ansible parameters required to run.

For our project we will need 2 templates:
![](/images/ansible-tower/nginx_templates.png)

"NGINX VM deploy" project will "[azure-template-deploy-part-2/main.yml](https://raw.githubusercontent.com/groovy-sky/tower-examples/master/azure-template-deploy-part-2/main.yml)" for initial VM deployment. Please use Azure and Tower credentials, which we've specified in previous section, for this template. Also, as an input, we need to specify extra vairables accordingly to your environment. Extra variables template you can copy from here:
```
---
deploy_group_location: XXXXXXXX
deploy_group_name: XXXXXXXX
vm_admin_username: XXXXXXXX
vm_admin_password: XXXXXXXX
awx_inevntory: "NGINX inventory"
```

Variables 'deploy_group_name' and 'deploy_group_location' - are Azure deployment resource group and location.
'vm_admin_username' and 'vm_admin_password' variables - should match to values from "NGINX VM administrator" credentials.  'awx_inevntory' should match inventory name.

### Workflow Job Template configuration

Workflow enables users to create sequences consisting of any combination of job templates, project syncs, and inventory syncs that are linked together in order to execute them as a single unit. 

At first we need to create and save a new workflow template:
![](/images/ansible-tower/nginx_inven.png)

Once you’ve done that, go into “ WORKFLOW VISUALIZER”. This screen will come up, where we can add first step(which is project syncrhonization):
![](/images/ansible-tower/workflow_part1.png)

After that we can add 'NGINX VM delpoy' job:
![](/images/ansible-tower/workflow_part2.png)

Last chain it our workflow should be 'NGINX installation'. Final result:
![](/images/ansible-tower/workflow_whole.png)

Save the workflow and run it:
![](/images/ansible-tower/run_worfklow.png)

## Results

![](/images/ansible-tower/workflow_result_1.png)
![](/images/ansible-tower/workflow_result_2.png)

## Useful documentation

https://docs.ansible.com/ansible-tower/latest/html/userguide/workflows.html

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed

https://www.opcito.com/blogs/custom-inventory-management-using-ansible-awx-tower

https://www.opcito.com/blogs/what-more-can-you-do-with-ansible-awx/

https://www.redhat.com/files/summit/session-assets/2016/SS44918-self-service-it-and-delegation-with-ansible-tower.pdf

https://github.com/Azure-Samples/ansible-playbooks


## References

[Let's build a tower (part 1)](/ansible-tower-00/README.md)

[Let's build a tower (part 2)](/ansible-tower-01/README.md)

[Let's build a tower (part 3)](/ansible-tower-02/README.md)

[Let's build a tower (part 4)](/ansible-tower-03/README.md)

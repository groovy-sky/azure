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

We will start on configuring Azure side 
![](/images/ansible-tower/assign_role.png)

## Implementation

Ansible Tower is centered around the idea of organizing Projects (which run your playbooks via Jobs) and Inventories (which describe the servers on which your playbooks should be run) inside of Organizations. Organizations can then be set up with different levels of access based on Users and Credentials grouped in different Teams. It can be a little overwhelming at first, but once you get the initial structure configured, you'll see how powerful and flexible Tower's Project workflow is.

### Project configuration

[Tower projects](https://www.ansible.com/blog/getting-started-with-ansible-tower-projects-inventories) are a logical collection of Ansible Playbooks that are set up with each other based on what they might be doing or which hosts they might interact with.

Playbooks can be managed within Tower projects by either adding them manually to the project base path on your Tower server, (/var/lib/awx/projects) or by importing them from a source control management system (SCM) that is supported by Tower (Git, Subversion and Mercurial)

As mentioned before we will use [the Github repository](https://github.com/groovy-sky/tower-examples.git):
![](/images/ansible-tower/tower_playbooks.png)

After project is added, we need to run initial synchronization:
![](/images/ansible-tower/sync_project.png)


### Inventory configuration

Within Tower, the hosts that you interact with are set up as collections within Tower called inventories. Tower divides inventories into groups and the groups are what contain the actual hosts. Groups can be sourced manually by adding the IPs and hostnames into Tower, imported from an Ansible hosts file, or they can be sourced from one of Ansible Tower’s supported cloud providers.

We need to create two empty inventories - "LOCALHOST" and "NGINX inventory":
![](/images/ansible-tower/awx_invent.png)

During the workflow deployed VM IP address will be added to "NGINX inventory" inventory.

### Credentials configuration

Credentials play a crucial role in job templates as they are how Ansible Tower will connect to the machine or cloud to complete the execution of the ansible playbook.

There is only one required but depending on what type of inventory you are acting against, others might be needed. The most important credential is the machine credential. This must be selected for the job template to save but it can also be changed on launch for on the fly template runs against different machines with an inventory.

The other three options on this row of credentials are vault, cloud and network credentials. Here is where my previous statement about needed credentials comes into play. 

![](/images/ansible-tower/awx_credentials.png)

### Job Templates configuration

![](/images/ansible-tower/nginx_templates.png)

[Job templates](https://www.ansible.com/blog/getting-started-setting-up-an-ansible-job-template) are a definition and set of parameters for running an Ansible Playbook. In Ansible Tower, job templates are a visual realization of the ansible-playbook command and all flags you can utilize when executing from the command line. A job template defines the combination of a playbook from a project, an inventory, a credential and any other Ansible parameters required to run.

### Workflow Job Template configuration

The word “workflow” says it all. This particular feature enables users to create sequences consisting of any combination of job templates, project syncs, and inventory syncs that are linked together in order to execute them as a single unit. Because of this, workflows can help you organize playbooks and job templates into separate groups.

https://github.com/groovy-sky/azure/tree/master/ansible-tower-03#prerequisites

![](/images/ansible-tower/nginx_inven.png)

![](/images/ansible-tower/workflow_part1.png)

![](/images/ansible-tower/workflow_part2.png)

![](/images/ansible-tower/workflow_whole.png)

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

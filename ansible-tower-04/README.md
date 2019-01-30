# Let's build a tower (part 5) [draft]

## Introduction

Welcome to another post in our "Let's build a tower" series. In our previous posts, we discussed the basic structure of how you can [deploy AWX to Azure](https://lnkd.in/g3gsW3r), [configure its authentication](https://lnkd.in/gEdp66V) and [run a playbook](https://lnkd.in/diUNrU9).

This time we will discuss how to set up Workflow Job Template and run them against Azure inventory.

## Architecture

![](/images/ansible-tower/project_arch.png)

* Azure SPN account with contributor role on a subscription level
* Tower SPN account
* Two playbooks - one deploy Azure environment and another installs NGINX

## Prerequisites
* Source Code Management system - we will use our [demo Github repository](https://github.com/groovy-sky/tower-examples.git)
* AWX Host
* Any Active Azure Subscription

## Implementation

### Azure configuration
We will start on configuring Azure side 
![](/images/ansible-tower/assign_role.png)

### Project configuration

[Tower projects](https://www.ansible.com/blog/getting-started-with-ansible-tower-projects-inventories) are a logical collection of Ansible Playbooks that are set up with each other based on what they might be doing or which hosts they might interact with.

Playbooks can be managed within Tower projects by either adding them manually to the project base path on your Tower server, (/var/lib/awx/projects) or by importing them from a source control management system (SCM) that is supported by Tower (Git, Subversion and Mercurial)

![](/images/ansible-tower/tower_playbooks.png)

![](/images/ansible-tower/sync_project.png)


### Inventory configuration

![](/images/ansible-tower/awx_invent.png)

Within Tower, the hosts that you interact with are set up as collections within Tower called inventories. Tower divides inventories into groups and the groups are what contain the actual hosts. Groups can be sourced manually by adding the IPs and hostnames into Tower, imported from an Ansible hosts file, or they can be sourced from one of Ansible Tower’s supported cloud providers.

### Job Templates configuration

![](/images/ansible-tower/nginx_templates.png)

[Job templates](https://www.ansible.com/blog/getting-started-setting-up-an-ansible-job-template) are a definition and set of parameters for running an Ansible Playbook. In Ansible Tower, job templates are a visual realization of the ansible-playbook command and all flags you can utilize when executing from the command line. A job template defines the combination of a playbook from a project, an inventory, a credential and any other Ansible parameters required to run.

### Inventory, Product, and Playbook Selection

Arguably the most import three selections that you will make during the job template creation process, the inventory, project, and playbook all play an extremely important role in how this template will be used.

To start, you will need to select the inventory that you want to use this template against. To select one, you can hit the eyeglass in the textbox and this will display all of the available inventories that you have access to. Select the inventory you want to use for this job template. You can use “prompt at launch”, or you can invoke a more complex selection prompt at the beginning of a job using a survey. Once you’ve made a selection, you can move onto choosing the project.

Remember that the project you select will dictate what playbook you can select. The playbook you want for this job template must be housed in the particular project repository so that you can select it. You can select the project you want by the same method you selected your inventory. Once you have your project selected, the playbooks that are housed in this project’s repository will become available to this template.

Choosing the playbook is similar to previous fields on the selection process. Just note that Tower will not display the full file name. For example, if the file name for your playbook is AWS.yml, Ansible Tower will display it as AWS.

### Credentials configuration

![](/images/ansible-tower/awx_credentials.png)

Credentials play a crucial role in job templates as they are how Ansible Tower will connect to the machine or cloud to complete the execution of the ansible playbook.

There is only one required but depending on what type of inventory you are acting against, others might be needed. The most important credential is the machine credential. This must be selected for the job template to save but it can also be changed on launch for on the fly template runs against different machines with an inventory.

The other three options on this row of credentials are vault, cloud and network credentials. Here is where my previous statement about needed credentials comes into play. 

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

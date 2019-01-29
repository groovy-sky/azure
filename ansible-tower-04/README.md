# Let's build a tower (part 5) [draft]

## Introduction


## Architecture
The word “workflow” says it all. This particular feature in Ansible Tower enables users to create sequences consisting of any combination of job templates, project syncs, and inventory syncs that are linked together in order to execute them as a single unit. Because of this, workflows can help you organize playbooks and job templates into separate groups.

* Azure SPN account with contributor role on a subscription level
* Tower SPN account
* Two playbooks - one deploy Azure environment and another installs NGINX

## Prerequisites
Source Code Management system - we will use our demo Github repository
AWX Host
An Active Azure Subscription

## Implementation
1. Assign 'Contributor' role on subscription to the Azure service account
1. Create Tower,Azure,VM credentials
1. Create new inventory
1. Create two projects
1. Create workflow

https://github.com/groovy-sky/azure/tree/master/ansible-tower-03#prerequisites

![](/images/ansible-tower/tower_playbooks.png)

![](/images/ansible-tower/sync_project.png)

![](/images/ansible-tower/project_arch.png)

![](/images/ansible-tower/template_workflow_schema.png)

![](/images/ansible-tower/assign_role.png)

![](/images/ansible-tower/awx_credentials.png)

![](/images/ansible-tower/awx_invent.png)


![](/images/ansible-tower/nginx_templates.png)

![](/images/ansible-tower/nginx_inven.png)

![](/images/ansible-tower/workflow_part1.png)

![](/images/ansible-tower/workflow_part2.png)

![](/images/ansible-tower/workflow_whole.png)

## Results


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

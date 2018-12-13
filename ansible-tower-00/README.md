# Let's build a tower (part 1)

In this article I am going to install and configure [AWX](https://github.com/ansible/awx), which is an open-source version of [Red Hat Ansible Tower](https://www.ansible.com/products/tower), for managing Azure resources in a centralized way. The aim of this experiment - have some fun and learn something new about Ansible.

## Prerequisites
Before delving into techical details let’s first review what is needed to reproduce it on your side. List is following:
* Active Azure subscription
* Linux environment (Ubuntu, Debian, Centos, Suse or [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)) with installed 'jq' package
* [Azure CLI 2 version](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Architecture
To reproduce the solution in your environment you will need two files - [azuredeploy.json](azuredeploy.json) and [script.sh](script.sh). 

"azuredeploy.json" file is for the initial [Azure deployment](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli) which creates Virtual Machine with Ubuntu 16.04 OS. Names for created resources are generated using [unique string](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-string#uniquestring) and resource related string:
![Azure Deployment Template](/images/ansible-tower/depoyment.png)

"script.sh" file contains includes command for "azuredeploy.json" deployment and post-deployment logic for installing AWX on the new created VM:


![Azure Resource Group](/images/ansible-tower/resource_group.png)

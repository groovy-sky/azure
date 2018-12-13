# Let's build a tower (part 1)

In this article I am going to install and configure [AWX](https://github.com/ansible/awx), which is an open-source version of [Red Hat Ansible Tower](https://www.ansible.com/products/tower), for managing Azure resources in a centralized way. The aim of this experiment - have some fun and learn something new about Ansible.

## Prerequisites
Before delving into techical details let’s first review what is needed to reproduce it on your side. List is following:
* Active Azure subscription
* Linux environment (Ubuntu, Debian, Centos, Suse or [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)) with installed 'jq' package on it
* [Azure CLI 2 version](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Architecture
To reproduce the solution in your environment you will need two files - [azuredeploy.json](azuredeploy.json) and [script.sh](script.sh). 

"azuredeploy.json" file is for the initial [Azure deployment](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli) which creates Virtual Machine with Ubuntu 16.04 OS. Names for created resources are generated using [unique string](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-string#uniquestring) and resource related string:
![Azure Deployment Template](/images/ansible-tower/depoyment.png)

"script.sh" file contains includes command for "azuredeploy.json" deployment and post-deployment logic for installing AWX on the new created VM:
![script.sh](/images/ansible-tower/script_sh.PNG)

## Implementation
Go to the [portal](https://portal.azure.com), create new group and copy group name and subscription id. [Sign in to Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest#sign-in-with-credentials-on-the-command-line) and run "script.sh" specifying group name and subscription id:
![Running the script](/images/ansible-tower/script_exec.png)

During script execution you will be asked for a password for the VM. Please provide password which meet [password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm):
![Password](/images/ansible-tower/password.png)

Go to deployment resource group after deployment will be finished, click on newly created virtual machine, copy it DNS Name and access AWX using [default credentials(admin/password)](https://docs.ansible.com/ansible-tower/latest/html/quickstart/login_superuser.html):
![VM DNS name](/images/ansible-tower/get_dns_name.png) 

Change admin password to something more secure:
![Password change](/images/ansible-tower/change_admin_password.png)


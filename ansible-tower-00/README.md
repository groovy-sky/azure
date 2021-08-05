# Let's build a tower (part 1)

![](/images/ansible-tower/awx_logo.png)

## Introduction

In this article we are going to learn how-to install and configure [AWX](https://github.com/ansible/awx). AWX - is an open-source version of [Red Hat Ansible Tower](https://www.ansible.com/products/tower), for managing Ansible in more manageable and easier way. The aim of this experiment - have some fun and learn something new about Ansible.

## Prerequisites

Before delving into techical details let’s first review what is needed to reproduce it on your side. List is following:
* Active Azure subscription
* Linux environment (Ubuntu, Debian, Centos, Suse or [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)) with installed 'jq' package on it
* [Azure CLI 2 version](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Architecture

To reproduce the solution in your environment you will need two files - [azuredeploy.json](https://raw.githubusercontent.com/groovy-sky/azure/master/ansible-tower-00/azuredeploy.json) and [script.sh](https://raw.githubusercontent.com/groovy-sky/azure/master/ansible-tower-00/script.sh). 

"azuredeploy.json" file is for the initial [Azure deployment](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli) which creates Virtual Machine with Ubuntu 16.04. Names for created resources are generated using [unique string](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-string#uniquestring) and resource related string:
![Azure Deployment Template](/images/ansible-tower/depoyment.png)

"script.sh" file contains command for "azuredeploy.json" deployment and post-deployment logic for installing AWX on the new created VM:
![script.sh](/images/ansible-tower/script_sh.PNG)

## Implementation
1. Download required files to your Linux environment:
![Prepare files](/images/ansible-tower/download_scripts.png)

1. Go to the [portal](https://portal.azure.com), create new group and copy group name and subscription id. [Sign in to Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest#sign-in-with-credentials-on-the-command-line) and run "script.sh" specifying group name and subscription id:
![Running the script](/images/ansible-tower/script_exec.png)

1. During script execution you will be asked for a password for the VM. Please provide password which meet [password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm) - 
![Password](/images/ansible-tower/password.png)

1. Go to deployment resource group after deployment will be finished, click on newly created virtual machine, copy it DNS Name and access AWX using admin/MjXYQ4Cegf1dCnXpo credentials:
![VM DNS name](/images/ansible-tower/get_dns_name.png) 

1. Change admin password to something more secure:
![Password change](/images/ansible-tower/change_admin_password.png)

## Under the hood

If you wondering what actually "script.sh" does - please read description below.

![Overview](/images/ansible-tower/result.png) 

At first we are deploying from a scracth Ubuntu VM. After that we are starting to configure it and prepare for AWX installation using '[custom script extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux)' feature. We install [NGINX web server](https://nginx.org/en/) and get [SSL sertificate](https://letsencrypt.org/how-it-works/) using [Certbot](https://certbot.eff.org/lets-encrypt/ubuntuxenial-apache.html). The web server is used as reverse proxy for accessing AWX in secure manner. Of course we also install Ansible (as it is core part of this solution) and [Docker](https://docs.docker.com/get-started/) (which is used for [running AWX environment](https://github.com/ansible/awx/blob/devel/INSTALL.md#docker-or-docker-compose)). AWX configuration is modified so as PostgreSQL container has used data disk for storing a data.

As a result we get Ubuntu VM on which AWX is runned as bunch of containers and is accessible thru NGINX:
![Docker](/images/ansible-tower/docker_containers.png) 

## References

[Let's build a tower (part 1)](/ansible-tower-00/README.md)

[Let's build a tower (part 2)](/ansible-tower-01/README.md)

[Let's build a tower (part 3)](/ansible-tower-02/README.md)

[Let's build a tower (part 4)](/ansible-tower-03/README.md)

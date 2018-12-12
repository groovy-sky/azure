# Let's build a tower (part 1)

In this article I am going to install and configure [AWX](https://github.com/ansible/awx), which is open-sourced version of [Red Hat Ansible Tower](https://www.ansible.com/products/tower), for managing Azure resources in a centralized way. The aim of this experiment - have some fun and learn something new about Ansible.

## Prerequisites
Before delving into techical details let’s first review what is needed to reproduce it on your side. List is following:
* Active Azure subscription
* Linux environment (Ubuntu, Debian, Centos, Suse or [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)) with installed 'jq' package
* Azure CLI


![Azure Resource Groupt](/images/ansible-tower/resource_group.png)

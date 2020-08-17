## Introduction
![](/images/logos/blog_icon.png)

This repository hosts a collection of articles about deploying, configuring  and running various services in Microsoft Azure.

### Azure Functions

![](/images/logos/function.png)

* How-to run [a Python function for storing Azure/Office 365 IP](/func-parse-cloud-00#introduction)

### Infrastructure as Code

![](/images/logos/iac.png)

* [Part 1](/iac-00#introduction) - about Azure Resource Manager (ARM) template deployment
* [Part 2](/iac-01#introduction) - about using Ansible playbooks for ARM template deployment
* [Part 3](/iac-02#introduction) - about building a Docker image (using Github Actions), which have Ansible playbooks for ARM template deployment
* [Part 4](/iac-03#introduction) - about running a Docker container (using Azure DevOps), which uses Ansible playbooks for ARM template deployment
* [Part 5](/iac-04#introduction) - about triggering a DevOps pipeline, which on a Docker container runs Ansible playbooks for ARM template deployment, with Power Automate help

### Ansible Tower (aka AWX)

![](/images/logos/awx.png)

* [Part 1](/ansible-tower-00/README.md#introduction) - about AWX initial installation and configuration on Azure
* [Part 2](/ansible-tower-01/README.md#introduction) - about AWX authentication configuration using Azure AD
* [Part 3](/ansible-tower-02/README.md#introduction) - about running a playbook on AWX
* [Part 4](/ansible-tower-03/README.md#introduction) - about managing Azure resources using AWX
* [Part 5](/ansible-tower-04/README.md#introduction) - about running a workflow on AWX

### Docker
![](/images/logos/docker.png)

* How-to [run a build agent on Azure Container Instance](/devops-docker-build-00/README.md#introduction)
* How-to [run a Docker in Azure CLI](/docker-azure-cli-00/README.md#introduction)
* How-to [build a custom image with Powershell and NMap](/docker-audit-00/README.md#introduction) and [use it for port scanning](/docker-audit-01/README.md#introduction)
* How-to [run SonarQube VM in Azure](/sonarqube-00/README.md#introduction) and [use it on Azure DevOps](/sonarqube-01/README.md#introduction)


### Other/Old
![](/images/logos/other.png)

* How-to [encrypt unmanaged Linux disk](/linux-vm-encryption-101/README.md#introduction)
* [Azure Resource Manager overview](/arm-getting-started/README.md#introduction)

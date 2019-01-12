# How-to deploy to Azure SonarQube

## Introduction
SonarQube is an open source platform to perform automatic reviews with static analysis of code to detect bugs, code smells and security vulnerabilities on 25+ programming languages including Java, C#, JavaScript, TypeScript, C/C++, COBOL and more. SonarQube is the only product on the market that supports a leak approach as a practice to code quality.

In this tutorial, we will learn how to deploy ready-to-use SonarQube environment on Azure.

## Architecture
To reproduce the solution we will need to download and run [script.sh](https://raw.githubusercontent.com/groovy-sky/azure/master/sonarqube-101/script.sh), which will:
1. Create a Linux Virtual Machine and a PostgreSQL instance in Azure using [azuredeploy.json](https://raw.githubusercontent.com/groovy-sky/azure/master/sonarqube-101/azuredeploy.json) file.
1. Install NGINX and Certbot for providing secure access to SonarQube
1. Install Docker and Docker compose for running containerized SonarQube instance using [docker-compose.yml](https://raw.githubusercontent.com/groovy-sky/azure/master/sonarqube-101/docker-compose.yml) template

As a result we will get running VM (with NGINX and dockerized SonarQube) and PostgreSQL instance (used as a database for SonarQube):
![](/images/sonarqube-101/sonar_arch.png)

## Prerequisites
To complete this tutorial, we will need:
* Active Azure subscription
* Linux environment (Ubuntu, Debian, Centos, Suse or Windows Subsystem for Linux) with installed 'jq' package on it
* Azure CLI 2 version

## Implementation
There is one thing which should be done before running a deployment - we need to create a new resource group:
![](/images/sonarqube-101/azure_new_group.png)

Now we can open our Linux environment (in this example has beend used Ubuntu on Linux), download [script.sh](https://github.com/groovy-sky/azure/raw/master/sonarqube-101/script.sh) file and execute it. To run it we will need to use following 3 paramaters (check the image below): 
* Azure subscription Id
* Azure deployment resource group name
* Password for PostgreSQL

---
PostgreSQL password must be at least 8 characters in length and contain characters from three of the following categories – English uppercase letters, English lowercase letters, numbers (0-9), and non-alphanumeric characters (!, $, #, %, etc.).
---

![](/images/sonarqube-101/deploy_param.png)

Also, during the script execution, we will be asked for a password for the VM. Please provide password which conform to [password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm):

![](/images/sonarqube-101/vm_password.png)

The deployment could take about 20-30 minutes. After it will be finished, open newly created virtual machine, copy it DNS Name and access SonarQube using [default admin credentials - 
(admin/admin)](https://docs.sonarqube.org/latest/instance-administration/security/#header-2):
![](/images/sonarqube-101/result.png)

### Post-configuration
![](/images/sonarqube-101/sonar_admin_pass.png)
![](/images/sonarqube-101/pass_change.png)
![](/images/sonarqube-101/sonar_off_anonym.png)

## Results


## Useful documentation

https://docs.docker.com/compose/install/

https://hub.docker.com/_/sonarqube

https://docs.sonarqube.org/latest/instance-administration/security/

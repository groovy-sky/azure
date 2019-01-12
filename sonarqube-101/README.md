# How-to deploy to Azure SonarQube

## Introduction
SonarQube is an open source platform to perform automatic reviews with static analysis of code to detect bugs, code smells and security vulnerabilities on 25+ programming languages including Java, C#, JavaScript, TypeScript, C/C++, COBOL and more. SonarQube is the only product on the market that supports a leak approach as a practice to code quality.

In this tutorial, you will learn how to deploy ready-to-use SonarQube environment on Azure.

## Architecture
[docker-compose.yml](https://raw.githubusercontent.com/groovy-sky/azure/master/sonarqube-101/docker-compose.yml)
[script.sh](https://raw.githubusercontent.com/groovy-sky/azure/master/sonarqube-101/script.sh)
[azuredeploy.json](https://raw.githubusercontent.com/groovy-sky/azure/master/sonarqube-101/azuredeploy.json)
![](/images/sonarqube-101/sonar_arch.png)

## Prerequisites
To complete this tutorial, you will need:
* Active Azure subscription
* Linux environment (Ubuntu, Debian, Centos, Suse or Windows Subsystem for Linux) with installed 'jq' package on it
* Azure CLI 2 version

## Implementation
Before running a deployment - create new resource group:
![](/images/sonarqube-101/azure_new_group.png)

To initialize the deployment we would need [script.sh file](https://github.com/groovy-sky/azure/raw/master/sonarqube-101/script.sh). As input parameters it require 3 paramaters: 
![](/images/sonarqube-101/deploy_param.png)

During script execution you will be asked for a password for the VM. Please provide password which meet [password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm):

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

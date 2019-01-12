# How-to deploy to Azure SonarQube

## Introduction
SonarQube is an open source platform to perform automatic reviews with static analysis of code to detect bugs, code smells and security vulnerabilities on 25+ programming languages including Java, C#, JavaScript, TypeScript, C/C++, COBOL and more. SonarQube is the only product on the market that supports a leak approach as a practice to code quality.

In this tutorial, you will learn how to deploy ready-to-use SonarQube environment on Azure.

## Architecture
![](/images/sonarqube-101/sonar_arch.png)

## Prerequisites
List is following:
* Linux environment (Ubuntu, Debian, Centos, Suse or Windows Subsystem for Linux) with installed 'jq' package on it
* Azure CLI 2 version

![](/images/sonarqube-101/azure_new_group.png)


## Implementation
To initialize the deployment we would need [script.sh file](https://github.com/groovy-sky/azure/raw/master/sonarqube-101/script.sh). As input parameters it require 3 paramaters: 
![](/images/sonarqube-101/deploy_param.png)
![](/images/sonarqube-101/vm_password.png)
![](/images/sonarqube-101/result.png)

### Post-configuration
![](/images/sonarqube-101/sonar_admin_pass.png)
![](/images/sonarqube-101/pass_change.png)
![](/images/sonarqube-101/sonar_off_anonym.png)

## Results


## Useful documentation

https://docs.docker.com/compose/install/
https://hub.docker.com/_/sonarqube

## References

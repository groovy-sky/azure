# VMs audit with NMAP and PowerShell in Azure(part 2)

## Introduction
Microsoft Azure has [dozens of tools](https://docs.microsoft.com/en-us/azure/security/azure-security-services-technologies
) to manage all aspects of security in the Azure. Regardless of that, sometimes it is necessary to check an open port along with their associated virtual machine. 

This time we will use NMAP and Powershell combintation to scan the specified port of each running virtual machine in Azure. For added convenience and portability, we will run [the customized Docker image](https://hub.docker.com/r/groovysky/azure-audit).

## Architecture

A container is launched by running an image. An image is an executable package that includes everything needed to run an application - the code, a runtime, libraries, environment variables, and configuration files.

A container is a runtime instance of an image - what the image becomes in memory when executed (that is, an image with state, or a user process). 

[This article's image](https://hub.docker.com/r/groovysky/azure-audit) is build up from [Powershell 6.0 image](https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/), which uses [Az module](https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.2.0) and [NMAP package](https://nmap.org/). At the start of container it will execute 'Invoke-Audit' function from ['main.psm1' script](https://raw.githubusercontent.com/groovy-sky/docker/master/azure-audit/main.psm1):

![](/images/docker/scan_arch.png)

## Prerequisites

* Setup Docker in Azure Cloud Shell (see how-to instruction [here](/docker-azure-cli-00/README.md#Introduction))

* Create OMS workspace and copy it Id and Key:
![](/images/docker/create_oms.png)

![](/images/docker/get_oms_cred.png)

## Implementation

![](/images/docker/cloud_run.png)

1. Go to https://shell.azure.com/ 
1. Download [the image](https://hub.docker.com/r/groovysky/azure-audit) and run it interactively
1. Run Invoke-Audit cmdlet with required parameters 
1. Authenticate to https://aka.ms/devicelogin by entering an authorization code

Full code would look:
```
docker pull groovysky/azure-audit:latest
docker run -it groovysky/azure-audit:latest pwsh
Invoke-Audit -AuditPort '22' -OSType 'Linux' -LogType 'AzureAudit' -CustomerId 'xxxxx' -SharedKey 'xxxxx' 
```

## Results
If everything went according to plan you should see information about scaned VMs:
![](/images/docker/oms_results.png)

## Useful documentation


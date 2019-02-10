# VMs audit with NMAP and PowerShell in Azure(part 1)

## Introduction
Microsoft Azure has [dozens of tools](https://docs.microsoft.com/en-us/azure/security/azure-security-services-technologies
) to manage all aspects of security in the Azure. Regardless of that, sometimes it is necessary to check an open port along with their associated virtual machine. 

This time we will use NMAP and Powershell combintation to scan the specified port of each running virtual machine in Azure. For added convenience and portability, we will run [the customized Docker image](https://hub.docker.com/r/groovysky/azure-audit).

## Architecture

A container is launched by running an image. An image is an executable package that includes everything needed to run an application - the code, a runtime, libraries, environment variables, and configuration files.

A container is a runtime instance of an image - what the image becomes in memory when executed (that is, an image with state, or a user process). 

[This article's image](https://hub.docker.com/r/groovysky/azure-audit) is build up from [Powershell 6.0 image](https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/), which uses [Az module](https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.2.0) and [NMAP package](https://nmap.org/). At the start of container it will execute 'Invoke-Audit' function from ['main.psm1' script](https://raw.githubusercontent.com/groovy-sky/docker/master/azure-audit/main.psm1):

![](/images/docker/docker_image.png)

## Prerequisites
Docker Engine is available for Linux (CentOS, Debian, Fedora, Oracle Linux, RHEL, SUSE, and Ubuntu) or Windows Server operating systems and is based on containerd. Docker is available in two editions - Community (CE) and Enterprise (EE). In this article we will use Docker CE running on Ubuntu 16.04 LTS. Instruction how to install Docker on Ubuntu is available [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/).

## Implementation
1. Download [the image](https://hub.docker.com/r/groovysky/azure-audit) ('docker pull groovysky/azure-audit')
1. Run an instance interactively ('docker run -i groovysky/azure-audit')
1. Enter a port
1. Authenticate to https://aka.ms/devicelogin by entering an authorization code

![](/images/docker/first_run.png)

## Results
If everything went according to plan you should see information about scaned VMs:
![](/images/docker/run_results.png)

## Useful documentation

* https://docs.microsoft.com/en-us/azure/security-center/

* https://azure.microsoft.com/en-us/pricing/details/security-center/

* https://docs.microsoft.com/en-us/azure/virtual-network/diagnose-network-traffic-filter-problem

* https://docs.microsoft.com/en-us/azure/virtual-network/diagnose-network-routing-problem

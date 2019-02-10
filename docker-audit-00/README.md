# An Azure VM audit with NMAP and PowerShell (part 1)

## Introduction
Microsoft Azure has [dozens of tools](https://docs.microsoft.com/en-us/azure/security/azure-security-services-technologies
) to manage all aspects of security in the Azure. Regardless of that, sometimes it is necessary to check an open port along with their associated virtual machine. 

## Architecture

A container is launched by running an image. An image is an executable package that includes everything needed to run an application - the code, a runtime, libraries, environment variables, and configuration files.

A container is a runtime instance of an image - what the image becomes in memory when executed (that is, an image with state, or a user process). 

Our image 
https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/
https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.2.0
https://nmap.org/
![](/images/docker/docker_image.png)

## Prerequisites
* Docker environment

## Implementation
1. Download and run the image
2. Specify port
3. Authenticate to https://aka.ms/devicelogin by entering an authorization code

![](/images/docker/first_run.png)

## Results
![](/images/docker/run_results.png)

## Useful documentation

https://docs.microsoft.com/en-us/azure/security-center/
https://azure.microsoft.com/en-us/pricing/details/security-center/
https://docs.microsoft.com/en-us/azure/virtual-network/diagnose-network-traffic-filter-problem
https://docs.microsoft.com/en-us/azure/virtual-network/diagnose-network-routing-problem

# Audit virtual machines in Azure (part 1)

## Introduction
Microsoft Azure has [dozens of tools](https://docs.microsoft.com/en-us/azure/security/azure-security-services-technologies
) to manage all aspects of security in the Azure. Regardless of that, sometimes it is necessary to check an open port along with their associated virtual machine. 

## Architecture

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

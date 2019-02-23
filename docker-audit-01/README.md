# VMs audit with NMAP and PowerShell in Azure(part 2)

## Introduction

![](/images/docker/scan_arch.png)

[In the previous chapter](/docker-audit-00/README.md) we have used [a customized Docker image](https://hub.docker.com/r/groovysky/azure-audit) to scan Azure's VMs. 

This time we will use Azure Monitor(aka Operations Management Suite) to collect the scan results and analyze the collected data.

## Architecture

![](/images/docker/azure_monitor_overview.png)

Azure Monitor, provides sophisticated tools for collecting and analyzing telemetry that allow you to maximize the performance and availability of your cloud and on-premises resources and applications. 

All data collected by Azure Monitor fits into one of two fundamental types, metrics and logs. Metrics are numerical values that describe some aspect of a system at a particular point in time. They are lightweight and capable of supporting near real-time scenarios. Logs contain different kinds of data organized into records with different sets of properties for each type. Telemetry such as events and traces are stored as logs in addition to performance data so that it can all be combined for analysis.

Log data collected by Azure Monitor can be analyzed with queries to quickly retrieve, consolidate, and analyze collected data. Azure Monitor uses a version of the Kusto query language used by Azure Data Explorer that is suitable for simple log queries but also includes advanced functionality such as aggregations, joins, and smart analytics.

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

* https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-collector-api

* https://docs.microsoft.com/en-us/azure/azure-monitor/learn/tutorial-viewdata

* https://docs.microsoft.com/en-us/azure/azure-monitor/terminology

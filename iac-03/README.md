# Infrastructure as Code (part 4)
![](/images/iac/logo_transparent.png)


## Introduction
This article describes the fourth part of Infrastructure as Code approach. We already learned about [Azure Cloud](/iac-00/README.md), [Ansible]((/iac-01/README.md)) and [Docker]((/iac-03/README.md)). This document gives an example of using Microsoft Azure DevOps pipeline to run a Docker Container.

![](/images/iac/cloud_journey_03.png)

## Theoretical Part
**Azure Pipelines** is a cloud service that you can use to automatically build and test your code project and make it available to other users. 

Azure Pipelines combines continuous integration (CI) and continuous delivery (CD) to constantly and consistently test and build your code and ship it to any target.

You can define pipelines using the YAML syntax or through the user interface (Classic). Certain pipeline features are only available when using YAML or when defining build or release pipelines with the Classic interface.

The following list indicates common Pipeline terms:

* **Trigger** - defines the event that causes a pipeline to run.

* **Step** - the smallest building block of a pipeline. A step can either be a script or a task. 

* **Task** - a building block for defining automation in a pipeline. A task is packaged script or procedure that has been abstracted with a set of inputs.

* **Script** - runs code as a step in your pipeline using command line, PowerShell, or Bash. 

* **Job** - defines the execution sequence of a set of steps, which run on the same agent. On Linux and Windows agents, jobs may be run on the host or in a container.

* **Agent** - specifies a required resource on which the pipeline runs. You can use Microsoft-hosted or self-hosted agents. In both cases agent could be run on following OS/Environment - macOS, Linux agent, Windows and Docker.

* **Stage** - a logical boundary in the pipeline. It can be used to mark separation of concerns (e.g., Build, QA, and production). Each stage contains one or more jobs.

* **Artifact** - a collection of files or packages published by a run. 

* **Pipeline** - defines the continuous integration and deployment process for your app. A pipeline is made up of stages. A pipeline author can control whether a stage should run by defining conditions on the stage. Another way to control if and when a stage should run is through approvals and checks.

* **Approval** - a set of validations required before a deployment can be performed. Manual approval is a common check performed to control deployments to production environments. When checks are configured on an environment, pipelines will stop before starting a stage that deploys to the environment until all the checks are completed successfully.

* **Condition** - specifies a condition to be met prior to running a job.

* **Environment** - a collection of resources, where you deploy your application. It can contain one or more virtual machines, containers, web apps, or any service that's used to host the application being developed.

* **Dependencies** - specifies a requirement that must be met in order to run the next job or stage.

* **Service connection** - a connection to a remote service that is required to execute tasks in a job.

* **Demands** - ensures pipeline requirements are met before running a pipeline stage. Requires self-hosted agents.

## Prerequisites
Before you begin the next section, you’ll need:
* Azure DevOps account 
* Azure Cloud account

## Practical Part
**Azure Resource Manager and Ansible (both will be used) have declarative syntax, which allows to redeploy this demo as many times as you may wish.**

https://dev.azure.com/Infrastructure-as-C0de/pipeline-demo/_build?definitionId=4&_a=summary


## Results
If the pipeline run was successful you can validate a result by accessing web page:


## Summary

## Related Information

* https://docs.microsoft.com/en-us/azure/devops/pipelines/?view=azure-devops

* https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html

* https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html
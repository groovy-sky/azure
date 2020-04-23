# Infrastructure as Code (part 5)
![](/images/iac/logo_transparent.png)

## Introduction

The aim of this work was to examine Infrastructure as Code approach. In previous chapters I touched on [Azure](/iac-00/README.md), [Ansible](/iac-01/README.md), [Docker](/iac-02/README.md) and [DevOps](/iac-03/README.md). With this in mind, let’s discuss how to solve integration problems between business and technical worlds. 

![](/images/iac/cloud_journey_04.png)

Microsoft PowerApps is a tool that can integrate different kind applications and services so they interact with each other seamlessly. PowerApps provides a nice drag-and-drop user interface to allow you to add different controls to construct an app.

Azure Logic App is another integration platform. Power Automate and Azure Logic Apps are both designer-first integration services that can create workflows. Both services integrate with various SaaS and enterprise applications. Main difference between these two products is that Power Apps is a no-code/low-code platform for building simple solutions, whereas Logic Apps allows to work with logic app definitions in JSON using Visual Studio and Visual Studio Code. Logic Apps are part of Azure and, as in the first chapter Azure resources was already mentioned, let's take a look on Power Automate. 

This is the final chapter, which reviews Power Automate and an example of using it to start a DevOps pipeline.

![](/images/iac/final_step.png)


## Theoretical Part

Power Apps is a suite of apps, services, connectors and data platform that provides a rapid application development environment to build custom apps for your business needs. Using Power Apps, you can quickly build custom business apps that connect to your business data stored either in the underlying data platform (Common Data Service) or in various online and on-premises data sources (SharePoint, Excel, Office 365, Dynamics 365, SQL Server, and so on).

![](/images/iac/powerapp_logo.png)

The following list indicates common Power App terms:

* **Trigger** is an event that occurs when a specific set of conditions is satisfied. 

* **Action** is an operation that executes a task in a process. Actions run when a trigger activates or another action completes. There are different types of actions - Built-in, Standard, Premium and Custom.

* **Connector** is a component that provides an interface to an external service. It uses the external service's REST or SOAP API to do its work. When you use a connector, it calls the service's underlying API for you.

* **Flow** is series of steps/actions. There are different types of a flow.

* **Automated flows** that performs one or more tasks automatically after it's triggered by an event. 

* **Instant flows** triggered manually from any device.

* **Scheduled flows** performs one or more tasks on a schedule. 

* **Business process flows** defines a set of steps for people to follow to take them to a desired outcome.

## Prerequisites
Before you begin, you’ll need:

* Power automate license (you can get [a trial license](https://docs.microsoft.com/en-us/powerapps/maker/signup-for-powerapps)).
* Azure DevOps account
* Azure Cloud account

## Practical Part
Azure services configuration is described in [the previous chapter](/iac-03#practical-part). So it won't be covered here.

Power Apps is primarily an interface design tool and Flow is a workflow and process automation tool. To setup a demo environment you need to create a new workflow. To do so, follow instruction below:
1. Go to https://emea.flow.microsoft.com/ 
2. Create Instant flow with manual trigger
3. Create two inputs - "Resource Group" and "NGINX message"
4. As a next step chose "Azure Devops" > "Queue a new build"
5. Specify organization name, project name and build definition id
6. Paste to "Parameters" section following code - ```{"group_name":"@{triggerBody()['text']}", "nginx_default_msg":"'@{triggerBody()['text_1']}'"}```
7. Save the flow

Graphical interpretation of stated above:
![](/images/iac/flow_creation.png)

If Azure DevOps action is used for a first time - you'll need to give your consent for connection creation:
![](/images/iac/connection_creation.png)

Now you can run the flow:
![](/images/iac/flow_run.png)

## Results
Flows run will start the pipeline. If the pipeline run was successful you can validate a result by accessing web page:
![](/images/iac/flow_run_result.png)

## Summary
As stated in the Introduction, main goal was to take a shot at infrastructure as code approach. Hope I succeed on that and you found something useful/interesting in this work.

Taken together, the whole picture is as follows - end user, using Power Automate, starts a DevOps pipeline (which runs a custom image on Docker agent), which deploys and configures Azure environment using Ansible playbooks. Used configs/services list:

* [ARM template](https://raw.githubusercontent.com/groovy-sky/iaac-demo/master/azure/azuredeploy.json)
* [Ansible playbooks](https://github.com/groovy-sky/iaac-demo/tree/master/ansible)
* [Docker image](https://hub.docker.com/repository/docker/gr00vysky/iac-demo) and [its configuration file](https://raw.githubusercontent.com/groovy-sky/iaac-demo/master/docker/Dockerfile)
* [Github Actions workflow](https://github.com/groovy-sky/iaac-demo/actions?query=workflow%3A%22Build+Docker+Image%22) and [its configuration file](https://raw.githubusercontent.com/groovy-sky/iaac-demo/master/.github/workflows/build_docker_image.yml)
* [Azure DevOps pipeline](https://dev.azure.com/Infrastructure-as-C0de/pipeline-demo/_build?definitionId=4&_a=summary) and [its configuration file](https://raw.githubusercontent.com/groovy-sky/iaac-demo/master/.github/pipelines/run_docker_image.yml)

There is a strong probability that some day I will return to this topic, but as for now - thank you for your attention and have a nice day.

![](/images/iac/iac_end.png)

## Related Information

* https://powerapps.microsoft.com/en-us/blog/microsoft-powerapps-learning-resources/

* https://docs.microsoft.com/en-us/powerapps/powerapps-overview

* https://docs.microsoft.com/en-us/power-automate/getting-started

* https://docs.microsoft.com/en-us/azure/azure-functions/functions-compare-logic-apps-ms-flow-webjobs

* https://www.appliedis.com/working-with-microsoft-powerapps-flow/
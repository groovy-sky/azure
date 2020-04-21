# Infrastructure as Code (part 5)
## Introduction

Now, when ..., some kind of glue is needed to connect disparate systems together. 

![](/images/iac/cloud_journey_04.png)
Power Automate and Logic Apps are both designer-first integration services that can create workflows. Both services integrate with various SaaS and enterprise applications.


## Theoretical Part

Power Apps is a no-code/low-code platform for building simple solutions.

Power Automate is built on top of Logic Apps. They share the same workflow designer and the same connectors.

Power Apps is a suite of apps, services, connectors and data platform that provides a rapid application development environment to build custom apps for your business needs. Using Power Apps, you can quickly build custom business apps that connect to your business data stored either in the underlying data platform (Common Data Service) or in various online and on-premises data sources (SharePoint, Excel, Office 365, Dynamics 365, SQL Server, and so on).

When you sign in to Power Automate, you'll find these menus:

Action items, where you can manage approvals and business process flows.
My flows, where your flows reside.
Create, where you start a new flow.
Templates, where you can take a look at some of the most popular templates. These should give you some great ideas for flows you want to try.
Connectors, where you can connect from one service to another.
Data, where you can access entities, connections, custom connectors and gateways.
Solutions, where you can manage your solutions.
Learn, where you can find information that will help you quickly ramp up on Power Automate.

You can use Power Automate to create logic that performs one or more tasks when an event occurs in a canvas app. For example, configure a button so that, when a user selects it, an item is created in a SharePoint list, an email or meeting request is sent, a file is added to the cloud, or all of these. You can configure any control in the app to start the flow, which continues to run even if you close Power Apps.

Power Automate is one of the pillars of Power Platform. It provides a low code platform for workflow and process automation. Here's a list of the different types of flows:

| Flow type | Use case | Target |
|---|---|---|
|Automated flows | Create a flow that performs one or more tasks automatically after it's triggered by an event. |Connectors for cloud or on-premises services.|
|Button flows | Run repetitive tasks from anyplace, at any time, via your mobile device. |
|Scheduled flows | Create a flow that performs one or more tasks on a schedule. | 
| Business process flows | Define a set of steps for people to follow to take them to a desired outcome. | Human processes |
| UI flows (Preview) | Record and automate the playback of manual steps on legacy software. Desktop and Web applications that do not have APIs available for automation. |

### Key terms

Workflow: Visualize, design, build, automate, and deploy business processes as series of steps.

Managed connectors: Your logic apps need access to data, services, and systems. You can use prebuilt Microsoft-managed connectors that are designed to connect, access, and work with your data. 

Triggers: Many Microsoft-managed connectors provide triggers that fire when events or new data meet specified conditions. For example, an event might be getting an email or detecting changes in your Azure Storage account. Each time the trigger fires, the Logic Apps engine creates a new logic app instance that runs the workflow.

Actions: Actions are all the steps that happen after the trigger. Each action usually maps to an operation that's defined by a managed connector, custom API, or custom connector.

Enterprise Integration Pack: For more advanced integration scenarios, Logic Apps includes capabilities from BizTalk Server. The Enterprise Integration Pack provides connectors that help logic apps easily perform validation, transformation, and more.

### Connector
A connector is a component that provides an interface to an external service. For example, the Twitter connector allows you to send and retrieve tweets, while the Office 365 Outlook connector lets you manage your email, calendar, and contacts. Logic Apps provides hundreds of pre-built connectors that you can use to create your apps.

A connector uses the external service's REST or SOAP API to do its work. When you use a connector in your Logic App, the connector calls the service's underlying API for you. The following illustration shows the Twitter connector and its use of the Twitter REST API.

### Custom connectors

You can write custom connectors to access services that don't have pre-built connectors. The services must have a REST or SOAP API. The requirement that the services provide an API shouldn't be too surprising since connectors are essentially wrappers around that underlying API.

To create a custom connector, you first generate an OpenAPI or Postman description of the API. You then use that API description to create a Custom Connector resource in the Azure portal. You can give your connector a name, an icon, and a description for each operation. The following illustration shows an example of the process. Notice that there's no coding involved.



    A trigger is an event that occurs when a specific set of conditions is satisfied. Triggers activate automatically when conditions are met. For example, when a timer expires or data becomes available.

    An action is an operation that executes a task in your business process. Actions run when a trigger activates or another action completes.

A connector is a container for related triggers and actions.

You build a Logic App from triggers and actions. An app must begin with a trigger. After the trigger, you include as many actions as you need to implement your workflow. The following illustration shows the trigger and actions used in the social-media monitor app.


Most workflows need to do different actions based on the data being processed. 
Control actions are special actions built-in to Logic Apps that provides these control constructs:

    Condition statements controlled by a Boolean expression
    Switch statements
    For each and Until loops
    Unconditional Branch instructions.


## Prerequisites
You can try Power Apps for free by signing up for [a 30 day trial](https://docs.microsoft.com/en-us/powerapps/maker/signup-for-powerapps).
## Practical Part
https://emea.flow.microsoft.com/en-us/
## Results
## Summary
## Related Information

* https://powerapps.microsoft.com/en-us/blog/microsoft-powerapps-learning-resources/

* https://docs.microsoft.com/en-us/powerapps/powerapps-overview

* https://docs.microsoft.com/en-us/power-automate/getting-started

* https://docs.microsoft.com/en-us/azure/azure-functions/functions-compare-logic-apps-ms-flow-webjobs
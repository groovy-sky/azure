# Use Azure Logic Apps to Retrieve Your Public IP

## Introduction

This document guides you through designing, building, and deploying an Azure Logic App that automatically fetches your public IP address. You’ll learn both the concepts behind Logic Apps—such as hosting plans, triggers, actions, and connectors—and the practical steps required to implement, deploy, and monitor a production-ready workflow.

---

## Theoretical Part

Azure Logic Apps is a serverless integration platform that lets you build automated workflows by chaining triggers, actions, and connectors. You don’t provision or maintain servers—Azure handles scaling, hosting, and availability.

### Core Components

- **Hosting Plans**  
  - Consumption (multi-tenant): pay-per-execution, ideal for lightweight or variable workloads  
  - Standard (single-tenant): dedicated App Service plan, private endpoints, fixed capacity  

- **Triggers**  
  - Recurrence: schedules a workflow at defined intervals  
  - Request: fires when an HTTP request is received  
  - Event-based: listens for events in services like Storage, Service Bus, or Event Grid  
  - Polling: periodically checks for new data  
  - Push: immediately responds to external events  

- **Actions**  
  - Invoke HTTP endpoints  
  - Parse, transform, and route data  
  - Send notifications (email, Teams, SMS)  
  - Apply conditional logic and loops  

- **Connectors**  
  - Built-in: HTTP, Request/Response, Schedule  
  - Managed: Office 365, SQL Server, Salesforce, Twitter  
  - On-premises: File System, Oracle, SharePoint Server  
  - Enterprise: SAP, IBM MQ (requires integration pack)  

### Workflow Architecture

A minimal design to retrieve your public IP:

```ascii
[Recurrence Trigger]
           │
           ▼
      [HTTP GET]
           │
           ▼
     [Parse JSON]
           │
           ▼
[Response or Notification]
```

Wrap core steps in a `Scope` with retry policies (e.g., 3 attempts, 1-minute interval) and an on-failure branch to alert administrators.

---

## Practical Part

### Prerequisites

| Requirement              | Details                                                     |
|--------------------------|-------------------------------------------------------------|
| Azure Subscription       | Active or free trial                                        |
| Azure CLI (≥ v2.0)       | Installed and authenticated                                 |
| Git                      | For cloning sample repo                                     |
| ARM or Bicep Knowledge   | Basics of infrastructure-as-code                            |
| JSON & REST API Basics   | Familiarity with request/response schemas                   |

### Step 1: Create Resource Group

```bash
# Sign in to Azure
az login

# Create a resource group
az group create \
  --name rg-logicapp-demo \
  --location eastus
```

### Step 2: Deploy Logic App via ARM Template

Use the published ARM template directly from GitHub:

```bash
az deployment group create \
  --resource-group rg-logicapp-demo \
  --template-uri https://raw.githubusercontent.com/groovy-sky/what-is-my-ip-logic-app/refs/heads/main/azuredeploy.json \
  --parameters logicAppName=GetPublicIP location=eastus
```

This template provisions the Logic App workflow, trigger, actions (Compose + conditional Responses), and outputs the trigger URL with its SAS token.

### Step 3: Monitor and Log

1. In the Azure Portal, navigate to your Logic App → **Diagnostics settings**.  
2. Enable sending both **Logs** and **Metrics** to a Log Analytics workspace or Application Insights.  
3. Run queries in Log Analytics to track runtime and errors:
   ```kusto
   AzureDiagnostics
   | where ResourceProvider == "MICROSOFT.LOGIC"
   | where ResourceId contains "/workflows/GetPublicIP/"
   | summarize count() by Status_s, bin(TimeGenerated, 5m)
   ```
4. Adjust retry policies, concurrency, and alert rules based on observed behavior.

---

## Summary

You now have a production-ready Logic App that:

- Exposes an HTTP GET trigger to return your client’s public IP in text, JSON, or JSONP formats  
- Applies retry and error-handling patterns via `Scope` and conditional branches  
- Integrates seamlessly with Azure monitoring for observability  

Extend this solution with email/Teams notifications, embed it in your CI/CD pipeline, and refine its resilience by tuning retry policies and alerting rules.

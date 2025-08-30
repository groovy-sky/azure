# Use Azure Logic Apps to Retrieve Your Public IP

## Introduction

This document guides you through designing, building, and deploying an Azure Logic App that automatically fetches your public IP address. You’ll learn both the concepts behind Logic Apps—such as hosting plans, triggers, actions, and connectors—and the practical steps required to implement, deploy, and monitor a production-ready workflow.

---

Based on the information from the Logic Apps folder, here's the updated "Theoretical Part":

---

## Theoretical Part

Azure Logic Apps is a cloud-based platform that enables you to create and run automated workflows for enterprise integration, data orchestration, and B2B communication. It provides a visual designer for modeling business processes as a series of steps while abstracting the underlying compute infrastructure.

### Core Components

- **Hosting Plans**  
  - **Consumption (Multi-tenant)**: Runs in shared Azure environment, pay-per-execution model, automatic scaling, ideal for event-driven and intermittent workloads
  - **Standard (Single-tenant)**: Runs in dedicated Azure App Service Environment, supports Virtual Network integration, private endpoints, fixed pricing based on plan size, better for high-volume and isolation requirements
  - **Integration Service Environment (ISE)**: Fully isolated and dedicated environment injected into your virtual network, direct access to on-premises resources, fixed capacity and pricing (being deprecated in favor of Standard)

- **Triggers**  
  - **Recurrence**: Schedules workflows at specified intervals (seconds to months)
  - **Request**: Creates callable REST endpoint with optional authentication (SAS, OAuth, API keys)
  - **Event-based**: Responds to events from Azure services (Event Grid, Service Bus, Event Hubs)
  - **Polling**: Periodically checks endpoints for new data with configurable intervals
  - **Push/Webhook**: Registers callback URLs for real-time notifications
  - **Batch**: Processes messages in groups based on count or time window

- **Actions**  
  - **Built-in Operations**: HTTP calls, data operations (parse JSON, compose, filter arrays), control flow (conditions, loops, switch cases, scopes)
  - **Data Transformation**: Liquid templates, XSLT maps, flat file encoding/decoding
  - **Error Handling**: Try-catch scopes, retry policies, timeout configuration
  - **Variables and State**: Initialize, set, increment variables; maintain state across runs
  - **Parallel Processing**: Foreach loops with concurrency control, parallel branches

- **Connectors**  
  - **Standard Connectors**: 400+ pre-built connectors (Office 365, Dynamics 365, Salesforce, Twitter, Dropbox)
  - **Enterprise Connectors**: SAP, IBM 3270, MQ Series (requires Enterprise Integration Pack)
  - **On-premises Data Gateway**: Connects to on-premises SQL Server, SharePoint, File Systems, Oracle
  - **Custom Connectors**: Build your own using OpenAPI/Swagger definitions or Azure Functions
  - **Managed API Connections**: Stored credentials and connection configurations reusable across workflows

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

---

## Summary


# Use Azure Logic Apps to Showing Public IP

## Introduction

There are countless ways to discover your public IP address today, from web tools like ifconfig.me or WhatIsMyIP.org to simple `curl ifconfig.co` commands. While these options work, they bind you to third-party performance, uptime, and security policies.

Self-hosting a “What Is My IP” endpoint gives you full control over every aspect of the service—defining response formats and HTTP headers, enriching responses with metadata such as geolocation or autonomous system details, and retaining all logs under your own authentication and encryption rules. You can deploy the endpoint across multiple Azure regions or at the network edge to optimize latency, and pay only for actual invocations with a consumption-based billing model.

In this article, you’ll learn how to use Azure Logic Apps to spin up a serverless HTTP trigger that accurately returns client IPs.

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

The deployment creates:
- A consumption-based Logic App workflow
- HTTP trigger endpoint accepting GET requests
- IP extraction logic from X-Forwarded-For headers
- Conditional responses based on format parameter
- Secure trigger URL with SAS token authentication



### Deploy from Azure Portal

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fwhat-is-my-ip-logic-app%2Fmaster%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a> 

### Deploy from Azure CLI

#### Deployment

```bash
# Set variables
RG_NAME="rg-whatismyip-demo"
LOCATION="swedencentral"
LOGIC_APP_NAME="whatismyip-app"

# Create a resource group
az group create \
  --name $RG_NAME \
  --location $LOCATION

# Deploy the "What is my IP" Logic App using the ARM template
az deployment group create \
  --resource-group $RG_NAME \
  --template-file azuredeploy.json \
  --parameters logicAppName=$LOGIC_APP_NAME location=$LOCATION

# Get the Logic App trigger URL
TRIGGER_URL=$(az deployment group show \
  --resource-group $RG_NAME \
  --name azuredeploy \
  --query properties.outputs.logicAppTriggerUrl.value -o tsv)

echo "Your Logic App is deployed at: $TRIGGER_URL"
```

The deployment creates:
- A consumption-based Logic App workflow
- HTTP trigger endpoint accepting GET requests
- IP extraction logic from X-Forwarded-For headers
- Conditional responses based on format parameter
- Secure trigger URL with SAS token authentication

Test different response formats:

```bash
# Get IP as plain text (default)
curl "$TRIGGER_URL"

# Get IP as JSON
curl "$TRIGGER_URL?format=json"

# Get IP as JSONP for cross-origin requests
curl "$TRIGGER_URL?format=jsonp"
```

#### Cleanup

When you're finished testing, you can remove all the resources created:

```bash
# Set variables (if not already set in your session)
RG_NAME="rg-whatismyip-demo"

# Delete the resource group and all resources within it
az group delete \
  --name $RG_NAME \
  --yes --no-wait

echo "Cleanup initiated. Resource group $RG_NAME will be deleted."
```


## Summary

You now have a complete toolkit for exposing your own public-IP endpoint, from no-code Azure Logic Apps to hand-crafted services in Node.js, Python, Go, and serverless functions. Each pattern highlights key trade-offs:

* Logic Apps offers rapid assembly and pay-per-run economics at the expense of code flexibility
* Self-hosted microservices grant full customization but require infrastructure management
* Serverless and edge functions auto-scale globally with minimal ops work but introduce cold starts and sandbox limits

No matter which path you choose, remember to handle proxy headers for accurate IP detection, enforce rate limits to protect your service, and add CORS or JSONP for cross-origin clients. With these foundations in place, you can extend your endpoint with geolocation, API management, and real-time analytics to build a robust, production-grade solution.

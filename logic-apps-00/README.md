# Use Azure Logic Apps to Retrieve Your Public IP

## Introduction

This document guides you through deploying and understanding an Azure Logic App that creates a "What is my IP" service - a RESTful endpoint that returns a client's public IP address in multiple formats (plain text, JSON, or JSONP). You'll learn how Logic Apps components work together to create serverless workflows, and deploy a production-ready solution that handles IP detection through proxy headers and supports cross-origin requests.

This implementation demonstrates key Logic Apps concepts including HTTP triggers, conditional logic, data manipulation, and dynamic response formatting - all running on Azure's consumption-based serverless platform where you only pay for actual executions.

---

## Theoretical Part

[Content remains as provided]

---

## Practical Part

### Prerequisites

| Requirement              | Details                                                     |
|--------------------------|-------------------------------------------------------------|
| Azure Subscription       | Active or free trial                                        |
| Azure CLI (≥ v2.0)       | Installed and authenticated                                 |
| Git                      | For cloning sample repo (optional)                          |
| ARM Template Knowledge   | Basic understanding of Azure Resource Manager templates     |
| HTTP/REST Basics         | Familiarity with headers, query parameters, and responses   |

### Step 1: Create Resource Group

```bash
# Sign in to Azure
az login

# Create a resource group
az group create \
  --name rg-whatismyip-demo \
  --location swedencentral
```

### Step 2: Deploy Logic App via ARM Template

Deploy the "What is my IP" Logic App using the ARM template:

```bash
# Deploy from local template file or GitHub
az deployment group create \
  --resource-group rg-whatismyip-demo \
  --template-file azuredeploy.json \
  --parameters logicAppName=whatismyip-app location=swedencentral
```

The deployment creates:
- A consumption-based Logic App workflow
- HTTP trigger endpoint accepting GET requests
- IP extraction logic from X-Forwarded-For headers
- Conditional responses based on format parameter
- Secure trigger URL with SAS token authentication

### Step 3: Test the Deployed Logic App

After deployment, retrieve the trigger URL:

```bash
# Get the Logic App trigger URL
az deployment group show \
  --resource-group rg-whatismyip-demo \
  --name azuredeploy \
  --query properties.outputs.logicAppTriggerUrl.value -o tsv
```

Test different response formats:

```bash
# Get IP as plain text (default)
curl "https://your-logic-app-url.azure.com/..."

# Get IP as JSON
curl "https://your-logic-app-url.azure.com/...?format=json"

# Get IP as JSONP for cross-origin requests
curl "https://your-logic-app-url.azure.com/...?format=jsonp"
```

### Step 4: Monitor and Troubleshoot

View execution history and debug runs:

```bash
# List recent workflow runs
az logic workflow run list \
  --resource-group rg-whatismyip-demo \
  --workflow-name whatismyip-app \
  --query "[].{name:name, status:status, startTime:startTime}" \
  --output table

# Get detailed run information
az logic workflow run show \
  --resource-group rg-whatismyip-demo \
  --workflow-name whatismyip-app \
  --run-name <run-id>
```

### Step 5: Clean Up Resources

When finished, remove the resource group:

```bash
az group delete \
  --name rg-whatismyip-demo \
  --yes --no-wait
```

---

## Summary

This guide demonstrated how to deploy a serverless IP detection service using Azure Logic Apps. The solution leverages Logic Apps' consumption-based pricing model, making it cost-effective for intermittent usage while providing enterprise-grade reliability and scalability.

Key achievements:
- **Serverless Architecture**: Deployed a fully managed workflow without managing infrastructure
- **Multi-format Support**: Implemented conditional logic to return IP in text, JSON, or JSONP formats
- **Proxy-aware Detection**: Properly extracts client IPs from X-Forwarded-For headers
- **Secure Access**: Utilized SAS token authentication for endpoint security
- **Pay-per-use Model**: Consumption plan ensures costs only for actual executions

The Logic App handles common edge cases like IPv4/IPv6 addresses, multiple proxy headers, and cross-origin requests through JSONP support. This pattern can be extended for more complex scenarios like IP geolocation, rate limiting, or integration with other Azure services.

For production deployments, consider adding Application Insights for monitoring, implementing custom authentication, and using Azure API Management for advanced routing and throttling capabilities.

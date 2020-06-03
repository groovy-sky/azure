# Use Azure Functions for getting public IP

![](/images/logos/function.png)

## Introduction

Each device on your network has a private IP address only seen by other devices on the local network. But your ISP assigns you a public IP address that other devices on the Internet can see. 

![](/images/func-az-ip/google_what_is_my_ip.png)


This document gives an **example of using Azure Python Function for showing your public IP**. 

## Theoretical Part

### Azure Functions

Serverless is an approach to computing that offloads responsibility for common infrastructure management tasks (e.g., scaling, scheduling, patching, provisioning, etc.) to cloud providers and tools, allowing engineers to focus their time and effort on the business logic specific to their applications or process.

Azure Functions is a serverless application platform. It allows developers to host business logic that can be executed without provisioning infrastructure. Functions provides intrinsic scalability and you are charged only for the resources used. You can write your function code in the language of your choice, including C#, F#, JavaScript, Python, and PowerShell Core. 

In Azure Functions, specific functions share a few core technical concepts and components, regardless of the language or binding you use.

![](/images/func-az-ip/function_separation.png)

A function is the primary concept in Azure Functions. When you are working with a function in Azure, you must choose following configurations:
* Functions hosting plan
* Functions runtime
* Functions trigger
* Functions language

#### Hosting plans
There are three hosting plans available for Azure Functions: Consumption plan, Premium plan, and Dedicated (App Service) plan.

* **Consumption** - You're only charged for the time that your function app runs. This plan includes a free grant on a per subscription basis.
* **Premium** - Provides you with the same features and scaling mechanism as the Consumption plan, but with enhanced performance and VNET access. Cost is based on your chosen pricing tier. To learn more, see Azure Functions Premium plan.
* **Dedicated (App Service)** -	When you need to run in dedicated VMs or in isolation, use custom images, or want to use your excess App Service plan capacity. Uses regular App Service plan billing. Cost is based on your chosen pricing tier.

Both Consumption and Premium plans automatically add compute power when your code is running. Your app is scaled out when needed to handle load, and scaled in when code stops running. For the Consumption plan, you also don't have to pay for idle VMs or reserve capacity in advance.

On any plan, a function app requires a general Azure Storage account, which supports Azure Blob, Queue, Files, and Table storage. This is because Functions relies on Azure Storage for operations such as managing triggers and logging function executions, but some storage accounts do not support queues and tables. These accounts, which include blob-only storage accounts (including premium storage) and general-purpose storage accounts with zone-redundant storage replication, are filtered-out from your existing Storage Account selections when you create a function app.

More detailed information about hosting plans available [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale).

#### Trigger events

Triggers are what cause a function to run. A trigger defines how a function is invoked and a function must have exactly one trigger. Triggers have associated data, which is often provided as the payload of the function.

Binding to a function is a way of declaratively connecting another resource to the function; bindings may be connected as input bindings, output bindings, or both. Data from bindings is provided to the function as parameters.

You can mix and match different bindings to suit your needs. Bindings are optional and a function might have one or multiple input and/or output bindings.

Azure Functions support a wide range of trigger types: 
* **Timer trigger** - execute a function at a set interval.
* **HTTP trigger** - execute a function when an HTTP request is received.
* **Blob storage trigger** - execute a function when a file is uploaded or updated in Azure Blob storage.
* **Queue storage trigger** - execute a function when a message is added to an Azure Storage queue.
* **Azure Cosmos DB trigger** - execute a function when a document changes in a collection.
* **Event Grid trigger** - respond to Azure Event Grid events via subscriptions and filters
* **Event Hub trigger** - execute a function when an event hub receives a new event.
* **Service Bus Queue/Topic trigger** - execute a function that react to and send queue/topic messages

#### Runtime
A function app runs on a specific version of the Azure Functions runtime. There are three major versions: 1.x, 2.x, and 3.x. By default, function apps are created in version 2.x of the runtime. 

The major versions of the Azure Functions runtime are related to the version of .NET on which the runtime is based. Runtime versions 3.x and 2.x are running on .NET Core, whereas 1.x is using .NET Framework .

More detailed information about functions runtime you can find [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-versions).

#### Language

Depending on which runtime version is used, different languages are supported. All runtimes support C#, JavaScript, F#. Java, Powershell, Python and TypeScript works on 2.x and 3.x versions. 

More detailed information about supported languages is described [here](https://docs.microsoft.com/en-us/azure/azure-functions/supported-languages#languages-by-runtime-version)

## Prerequisites

Before you begin the next section, you’ll need:
* [Azure Cloud account](https://azure.microsoft.com/free/)
* Local environment with installed: [Python](https://www.python.org/downloads/) (version 3.6 or higher), [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest), [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools#versionss) (newest available latest version) and [Git client](https://git-scm.com/downloads)

## Practical Part
To run this demo you'll need to:
1. Create Functions environment in Azure portal.  
2. Publish [functions code](https://github.com/groovy-sky/what-is-my-ip) to Azure App Service. 


### Functions environment deployment

Login to azure portal and find "Function App" in Azure Marketplace:

![](/images/func-az-ip/az_func_portal_marketplace.png)

Provide all necessary data(important values are marked) and create an environment:

![](/images/func-az-ip/az_func_portal_creation.png)

### Function publishing

The Azure Functions Core Tools let you to run functions on your local computer or publish to Azure. When you publish a function using Core Tools - it don't ask you to sign in to Azure. Instead, they access your subscriptions and resources by loading your session information from the Azure CLI. If you don't have an active session in one of those tools, publishing will fail.

Which is why **before publishing you need to login to Azure CLI** and only then execute code below (**also don't forget to replace ```<function_name>``` with your App Service name**):

```
[ ! -d "what-is-my-ip/.git" ] && git clone https://github.com/groovy-sky/what-is-my-ip
cd what-is-my-ip && git pull
func azure functionapp publish <function_name> --python
```

## Results

If the publishing was successful you can validate a result by accessing website:

![](/images/func-az-ip/get_ip_using_function.png)


At this point you've deployed Azure environment, published and executed Function. 


## Related Information

* https://www.ipify.org/

* https://docs.microsoft.com/en-us/python/api/azure-functions/azure.functions.httprequest?view=azure-python

* https://docs.microsoft.com/en-us/python/api/azure-functions/azure.functions?view=azure-python
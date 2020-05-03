
# 
![](/images/logos/function.png)
## Introduction

Serverless compute is a great option for hosting business logic code in the cloud. With serverless offerings such as Azure Functions, you can write your business logic in the language of your choice. You get automatic scaling, you have no servers to manage, and you are charged based on what is used — not on reserved time. Here are some additional characteristics of a serverless solution for you to consider.

Serverless is an approach to computing that offloads responsibility for common infrastructure management tasks (e.g., scaling, scheduling, patching, provisioning, etc.) to cloud providers and tools, allowing engineers to focus their time and effort on the business logic specific to their applications or process.

![](/images/func-az-ip/az_time_func.png)

The most useful way to define and understand serverless is focusing on the handful of core attributes that distinguish serverless computing from other compute models, namely:

* The serverless model requires no management and operation of infrastructure, enabling developers to focus more narrowly on code/custom business logic.
* Serverless computing runs code only on-demand on a per-request basis, scaling transparently with the number of requests being served.
* Serverless computing enables end users to pay only for resources being used, never paying for idle capacity.

Serverless is fundamentally about spending more time on code, less on infrastructure.

Azure Functions is a serverless application platform. It allows developers to host business logic that can be executed without provisioning infrastructure. Functions provides intrinsic scalability and you are charged only for the resources used. You can write your function code in the language of your choice, including C#, F#, JavaScript, Python, and PowerShell Core. 

## Theoretical Part

In Azure Functions, specific functions share a few core technical concepts and components, regardless of the language or binding you use.

![](/images/func-az-ip/function_separation.png)

A function is the primary concept in Azure Functions. A function contains two important pieces - your code and some config. When you are working with a function in Azure, you must choose following configurations:
* Functions hosting plan
* Functions runtime
* Functions trigger
* Functions language

### Hosting plans
There are three hosting plans available for Azure Functions: Consumption plan, Premium plan, and Dedicated (App Service) plan.

* **Consumption** - You're only charged for the time that your function app runs. This plan includes a free grant on a per subscription basis.
* **Premium** - Provides you with the same features and scaling mechanism as the Consumption plan, but with enhanced performance and VNET access. Cost is based on your chosen pricing tier. To learn more, see Azure Functions Premium plan.
* **Dedicated (App Service)** -	When you need to run in dedicated VMs or in isolation, use custom images, or want to use your excess App Service plan capacity. Uses regular App Service plan billing. Cost is based on your chosen pricing tier.

Both Consumption and Premium plans automatically add compute power when your code is running. Your app is scaled out when needed to handle load, and scaled in when code stops running. For the Consumption plan, you also don't have to pay for idle VMs or reserve capacity in advance.

On any plan, a function app requires a general Azure Storage account, which supports Azure Blob, Queue, Files, and Table storage. This is because Functions relies on Azure Storage for operations such as managing triggers and logging function executions, but some storage accounts do not support queues and tables. These accounts, which include blob-only storage accounts (including premium storage) and general-purpose storage accounts with zone-redundant storage replication, are filtered-out from your existing Storage Account selections when you create a function app.

More detailed information about hosting plans available [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale).

### Trigger events

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

### Runtime
A function app runs on a specific version of the Azure Functions runtime. There are three major versions: 1.x, 2.x, and 3.x. By default, function apps are created in version 2.x of the runtime. 

The major versions of the Azure Functions runtime are related to the version of .NET on which the runtime is based. Runtime versions 3.x and 2.x are running on .NET Core, whereas 1.x is using .NET Framework .

More detailed information about functions runtime you can find [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-versions).

### Language

Depending on which runtime version is used, different languages are supported. All runtimes support C#, JavaScript, F#. Java, Powershell, Pythin and TypeScript works on 2.x and 3.x. 

More detailed information about supported languages is described [here](https://docs.microsoft.com/en-us/azure/azure-functions/supported-languages#languages-by-runtime-version)

### Azure Functions Core Tools 
Azure Functions Core Tools lets you develop and test your functions on your local computer from the command prompt or terminal. Your local functions can connect to live Azure services, and you can debug your functions on your local computer using the full Functions runtime. You can even deploy a function app to your Azure subscription.

There are three versions of Azure Functions Core Tools. The version you use depends on your local development environment, choice of language, and level of support required:

* Version 1.x: Supports version 1.x of the Azure Functions runtime. This version of the tools is only supported on Windows computers and is installed from an npm package.

* Version 2.x/3.x: Supports either version 2.x or 3.x of the Azure Functions runtime. These versions support Windows, macOS, and Linux and use platform-specific package managers or npm for installation.

## Prerequisites

Before you begin the next section, you’ll need:
* Azure Cloud account
* Local environment with installed: Python 3.6 version(or higher), Azure CLI and Azure Functions Core Tools 

https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#v2

## Practical Part

The Consumption plan is the default hosting plan and offers the following benefits:

* Pay only when your functions are running
* Scale out automatically, even during periods of high load


### Azure part
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure%2Fmaster%2Ffunc-parse-cloud-00%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a> 
![](/images/func-az-ip/az_func_deploy.png)

By default, after function starts to work, generated data will be accessible through the following link - `https://<storage-name>.blob.core.windows.net/$web/main.html`. Optionally, you can get a better URL (like `https://<storage-name>.z6.web.core.windows.net`) by enabling "Static website" feature:
![](/images/func-az-ip/az_func_static_website.png)



### Function part
```
[ ! -d "iaac-demo/.git" ] && git clone https://github.com/groovy-sky/azure-office-ip
cd azure-office-ip && git pull
func azure functionapp publish <function_name> --python
```

https://strgy5exht4o56pkq.blob.core.windows.net/$web/main.html
https://strgy5exht4o56pkq.z6.web.core.windows.net/

![](/images/func-az-ip/func_deploy.gif)

https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python#folder-structure

## Results
![](/images/func-az-ip/az_trigger_func_res.png)

A timer trigger is a trigger that executes a function at a consistent interval. To create a timer trigger, you need to supply two pieces of information.

* A Timestamp parameter name, which is simply an identifier to access the trigger in code.
* A Schedule, which is a CRON expression that sets the interval for the timer.

A CRON expression is a string that consists of six fields that represent a set of times.

The order of the six fields in Azure is: {second} {minute} {hour} {day} {month} {day of the week}.

For example, a CRON expression to create a trigger that executes every five minutes looks like:

## Summary
## Related Information

* https://www.ibm.com/cloud/learn/microservices

* https://www.ibm.com/cloud/learn/serverless
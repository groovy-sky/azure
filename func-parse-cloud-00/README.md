
# 
![](/images/func-az-ip/azure_func.png)
## Introduction
## Theoretical Part
![](/images/func-az-ip/function_separation.png)


When you create a function app in Azure, you must choose a hosting plan for your app. There are three hosting plans available for Azure Functions: Consumption plan, Premium plan, and Dedicated (App Service) plan.

* Consumption - You're only charged for the time that your function app runs. This plan includes a free grant on a per subscription basis.
* Premium - Provides you with the same features and scaling mechanism as the Consumption plan, but with enhanced performance and VNET access. Cost is based on your chosen pricing tier. To learn more, see Azure Functions Premium plan.
* Dedicated (App Service) -	When you need to run in dedicated VMs or in isolation, use custom images, or want to use your excess App Service plan capacity. Uses regular App Service plan billing. Cost is based on your chosen pricing tier.

Both Consumption and Premium plans automatically add compute power when your code is running. Your app is scaled out when needed to handle load, and scaled in when code stops running. For the Consumption plan, you also don't have to pay for idle VMs or reserve capacity in advance.

### Consumption plan
When you're using the Consumption plan, instances of the Azure Functions host are dynamically added and removed based on the number of incoming events. This serverless plan scales automatically, and you're charged for compute resources only when your functions are running. On a Consumption plan, a function execution times out after a configurable period of time.

Billing is based on number of executions, execution time, and memory used. Billing is aggregated across all functions within a function app. For more information, see the Azure Functions pricing page.

The Consumption plan is the default hosting plan and offers the following benefits:

* Pay only when your functions are running
* Scale out automatically, even during periods of high load

Function apps in the same region can be assigned to the same Consumption plan. There's no downside or impact to having multiple apps running in the same Consumption plan. Assigning multiple apps to the same Consumption plan has no impact on resilience, scalability, or reliability of each app.



### Storage account requirements

On any plan, a function app requires a general Azure Storage account, which supports Azure Blob, Queue, Files, and Table storage. This is because Functions relies on Azure Storage for operations such as managing triggers and logging function executions, but some storage accounts do not support queues and tables. These accounts, which include blob-only storage accounts (including premium storage) and general-purpose storage accounts with zone-redundant storage replication, are filtered-out from your existing Storage Account selections when you create a function app.

The same storage account used by your function app can also be used by your triggers and bindings to store your application data. However, for storage-intensive operations, you should use a separate storage account.

It's certainly possible for multiple function apps to share the same storage account without any issues. (A good example of this is when you develop multiple apps in your local environment using the Azure Storage Emulator, which acts like one storage account.)

https://docs.microsoft.com/en-us/azure/azure-functions/supported-languages#languages-by-runtime-version

### Trigger events

Triggers are what cause a function to run. A trigger defines how a function is invoked and a function must have exactly one trigger. Triggers have associated data, which is often provided as the payload of the function.

Binding to a function is a way of declaratively connecting another resource to the function; bindings may be connected as input bindings, output bindings, or both. Data from bindings is provided to the function as parameters.

You can mix and match different bindings to suit your needs. Bindings are optional and a function might have one or multiple input and/or output bindings.

Triggers and bindings let you avoid hardcoding access to other services. Your function receives data (for example, the content of a queue message) in function parameters. You send data (for example, to create a queue message) by using the return value of the function.

Azure Functions support a wide range of trigger types: 
* **Timer trigger** Execute a function at a set interval.
* **HTTP trigger** Execute a function when an HTTP request is received.
* **Blob trigger** Execute a function when a file is uploaded or updated in Azure Blob storage.
* **Queue trigger** Execute a function when a message is added to an Azure Storage queue.
* **Azure Cosmos DB trigger** Execute a function when a document changes in a collection.
* **Event Hub trigger** Execute a function when an event hub receives a new event.

#### Time trigger


A timer trigger is a trigger that executes a function at a consistent interval. To create a timer trigger, you need to supply two pieces of information.

* A Timestamp parameter name, which is simply an identifier to access the trigger in code.
* A Schedule, which is a CRON expression that sets the interval for the timer.

A CRON expression is a string that consists of six fields that represent a set of times.

The order of the six fields in Azure is: {second} {minute} {hour} {day} {month} {day of the week}.

For example, a CRON expression to create a trigger that executes every five minutes looks like:

#### HTTP trigger
An HTTP trigger is a trigger that executes a function when it receives an HTTP request.

An HTTP trigger Authorization level is a flag that indicates if an incoming HTTP request needs an API key for authentication reasons.

There are three Authorization levels:

    Function
    Anonymous
    Admin

The Function and Admin levels are "key" based. To send an HTTP request, you must supply a key for authentication. There are two types of keys: function and host. The difference between the two keys is their scope. Function keys are specific to a function. Host keys apply to all functions inside the function app. If your Authorization level is set to Function, you can use either a function or a host key. If your Authorization level is set to Admin, you must supply a host key.

The Anonymous level means that there's no authentication required. We use this level in our exercise.

### Azure Functions Core Tools 
Azure Functions Core Tools lets you develop and test your functions on your local computer from the command prompt or terminal. Your local functions can connect to live Azure services, and you can debug your functions on your local computer using the full Functions runtime. You can even deploy a function app to your Azure subscription.

There are three versions of Azure Functions Core Tools. The version you use depends on your local development environment, choice of language, and level of support required:



    Version 1.x: Supports version 1.x of the Azure Functions runtime. This version of the tools is only supported on Windows computers and is installed from an npm package.

    Version 2.x/3.x: Supports either version 2.x or 3.x of the Azure Functions runtime. These versions support Windows, macOS, and Linux and use platform-specific package managers or npm for installation.


## Prerequisites

Before you begin the next section, you’ll need:
* Azure Cloud account
* Local environment with Python 3.6 version(or higher) and Azure Functions Core Tools 

https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#v2

## Practical Part
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure%2Fmaster%2Ffunc-parse-cloud-00%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a> 

```
[ ! -d "iaac-demo/.git" ] && git clone https://github.com/groovy-sky/azure-office-ip
cd azure-office-ip && git pull
func azure functionapp publish <function_name> --python
```

https://strgy5exht4o56pkq.blob.core.windows.net/$web/main.html
https://strgy5exht4o56pkq.z6.web.core.windows.net/

## Results


## Summary
## Related Information




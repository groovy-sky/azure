# Azure Functions custom handler in Go
![](/images/logos/function.png)
## Introduction
Azure Functions allows to run a code without worrying about application infrastructure. Even though Azure Functions supports many language handlers by default, in some cases you want more.

![](/images/func-az-ip/go_handler_logo.png)                                                                               

## Theoretical Part

Azure Functions is a serverless compute service, which  is "triggered" by a specific type of event. Every Functions app is executed by a language-specific handler. While Azure Functions supports many language handlers by default, there are cases where you may want additional control over the app execution environment. Custom handlers give you this additional control.

The following diagram shows the relationship between the Functions host and a web server implemented as a custom handler:

![](/images/func-az-ip/az_func_handler.png)

* Events trigger a request sent to the Functions host. The event carries either a raw HTTP payload (for HTTP-triggered functions with no bindings), or a payload that holds input binding data for the function.
* The Functions host then proxies the request to the web server by issuing a request payload.
* The web server executes the individual function, and returns a response payload to the Functions host.
* The Functions host proxies the response as an output binding payload to the target.

To implement a custom handler, you need the following aspects to your application:

* A host.json file at the root of your app
* A function.json file for each function (inside a folder that matches the function name)
* A command, script, or executable, which runs a web server

## Prerequisites                                                                                              
                                                                                                              
Before you begin the next section, you’ll need:                                                               
* [Azure Cloud account](https://azure.microsoft.com/free/)                                                    
                                                                                                              
## Practical Part                                                                                             
To run this demo you'll need to:                                                                              
1. Create Functions environment in Azure portal.                                                              
2. Publish [functions code](https://github.com/groovy-sky/azure-func-go-handler/tree/master/Function) using Azure CLI.               
                                                                                                              
                                                                                                              
### Functions environment deployment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure-func-go-handler%2Fmaster%2FTemplate%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>

```
[ ! -d "azure-func-go-handler/.git" ] && git clone https://github.com/groovy-sky/azure-func-go-handler
cd azure-func-go-handler/Function && git pull
func azure functionapp publish <function_name> --no-build --force
```

## Results
## Summary
## Related Information
* https://docs.microsoft.com/en-us/azure/azure-functions/functions-custom-handlers
* https://github.com/Azure-Samples/functions-custom-handlers
* https://github.com/Azure-Samples/functions-custom-handlers/tree/master/go

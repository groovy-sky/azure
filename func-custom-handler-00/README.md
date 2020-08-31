# Azure Functions custom handler in Go
![](/images/logos/function.png)
## Introduction
Azure Functions allows to run a code without worrying about application infrastructure. Even though Azure Functions supports many language handlers by default, in some cases you want more.

![](/images/go_handler_logo.png)                                                                               

## Theoretical Part

Azure Functions is a serverless compute service, which  is "triggered" by a specific type of event. Every Functions app is executed by a language-specific handler. While Azure Functions supports many language handlers by default, there are cases where you may want additional control over the app execution environment. Custom handlers give you this additional control.

## Prerequisites                                                                                              
                                                                                                              
Before you begin the next section, you’ll need:                                                               
* [Azure Cloud account](https://azure.microsoft.com/free/)                                                    
* Local environment with installed: [Python](https://www.python.org/downloads/) (version 3.6 or higher), [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest), [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools#versionss) (newest available latest version) and [Git client](https://git-scm.com/downloads)
                                                                                                              
## Practical Part                                                                                             
To run this demo you'll need to:                                                                              
1. Create Functions environment in Azure portal.                                                              
2. Publish [functions code](https://github.com/groovy-sky/azure-func-go-handler/tree/master/Function) to Azure App Service.                
                                                                                                              
                                                                                                              
### Functions environment deployment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure-func-go-handler%2Fmaster%2FTemplate%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>

## Results
## Summary
## Related Information
* https://docs.microsoft.com/en-us/azure/azure-functions/functions-custom-handlers
* https://github.com/Azure-Samples/functions-custom-handlers
* https://github.com/Azure-Samples/functions-custom-handlers/tree/master/go

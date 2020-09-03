# Azure Functions custom handler in Go
![](/images/logos/function.png)
## Introduction
Azure Functions allows to run a code without worrying about application infrastructure. Even though Azure Functions supports many language handlers by default, in some cases you want more.

![](/images/func-az-ip/go_handler_logo.png)                                                                               

This document gives an example of using **Go custom handler in Azure Functions for showing your public IP**.

## Theoretical Part

Azure Functions is a serverless compute service, which  is "triggered" by a specific type of event. Every Functions app is executed by a language-specific handler. While Azure Functions supports many language handlers by default, there are cases where you may want additional control over the app execution environment. Custom handlers give you this additional control.

The following diagram shows the relationship between the Functions host and a web server implemented as a custom handler:

![](/images/func-az-ip/az_func_handler.png)

1. Events trigger a request sent to the Functions host. The event carries either a raw HTTP payload (for HTTP-triggered functions with no bindings), or a payload that holds input binding data for the function.

2. The Functions host then proxies the request to the web server by issuing a request payload.

3. The web server executes the individual function, and returns a response payload to the Functions host.

4. The Functions host proxies the response as an output binding payload to the target.

To implement a custom handler, you need the following aspects to your application:

* A host.json file at the root of your app, to tell the Functions host where to send requests
* A function.json file for each function (inside a folder that matches the function name)
* A command, script, or executable, which runs a web server

## Prerequisites                                                                                              
                                                                                                              
Before you begin the next section, you’ll need:                                                               
* [Azure Cloud account](https://azure.microsoft.com/free/)                                                    
                                                                                                              
## Practical Part                                                                                             
                                                                                                              
As always, everything that you'll need to run this demo is stored in [one repository](https://github.com/groovy-sky/azure-func-go-handler). Easiest way how to do that - use [Azure Cloud Shell in Bash mode](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) and execute following script:

```
deploy_region="westeurope"                                                                                    
deploy_group="go-custom-function"                                                                            
az group create -l $deploy_region -n $deploy_group                                                            
function=$(az deployment group create --resource-group $deploy_group --template-uri https://raw.githubusercontent.com/groovy-sky/azure-func-go-handler/master/Template/azuredeploy.json | jq -r '. | .properties | .dependencies | .[] | .resourceName')                                                     
[ ! -d "azure-func-go-handler/.git" ] && git clone https://github.com/groovy-sky/azure-func-go-handler        
cd azure-func-go-handler/Function && git pull                                                                 
go build *.go && func azure functionapp publish $function --no-build --force

```
The whole thing takes less than 5 minutes:

![](/images/func-az-ip/go_custom_func_result.gif)                                                                               

After function will be published you'll get a link to the functions URL:

![](/images/func-az-ip/go_func_deploy_end_result.png)

## Results

If the publishing was successful you can validate a result by accessing a newly created function:

![](/images/func-az-ip/get_ip_using_function.png)                                                                               

## Related Information
* https://docs.microsoft.com/en-us/azure/azure-functions/functions-custom-handlers
* https://github.com/Azure-Samples/functions-custom-handlers
* https://github.com/Azure-Samples/functions-custom-handlers/tree/master/go

## Configuring HTTP/2 on Azure Functions

![](/images/func-az-ip/http2_func_logo.png)

The Hypertext Transfer Protocol (HTTP) is one of the most ubiquitous and widely adopted application protocols on the Internet: it is the common language between clients and servers, enabling the modern web. HTTP has evolved from an early protocol to exchange files in a semi-trusted laboratory environment, to the modern maze of the Internet. In the first half of the 2010s Google demonstrated an experimental protocol SPDY, which served as the foundations of the HTTP/2 protocol. 

HTTP/2 makes applications faster, simpler, and more robust by allowing to undo many of the HTTP/1.1 workarounds previously done within our applications and address these concerns within the transport layer itself. Even better, it also opens up a number of entirely new opportunities to optimize our applications and improve performance!

Some time ago [Microsoft has announced HTTP/2 support in Azure App Service](https://azure.microsoft.com/en-us/blog/announcing-http-2-support-in-azure-app-service/?ref=msdn). There are several ways to enable HTTP/2 for an application running on Azure App Service. Easiest way how to do that is by using Application Settings, but not all plans support that - for example, on Azure Functions running on Consumption App Service plan. This document gives an example of **enabling HTTP/2 for an Azure Functions running on Consumption App Service**.  

## Deploying and configuring Azure Functions

You can use [Bash Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) or Azure CLI on Linux to run the [script.sh](https://raw.githubusercontent.com/groovy-sky/azure/master/func-http2/script.sh), which will:

1. Create a new resource group and empty Azure Function
2. Enable HTTP/2 on Azure App Service
3. Build and publish [the demo code](https://github.com/groovy-sky/azure-func-go-handler/blob/master/Function/GoCustomHandler.go) to the function 

To start the deployment execute command below:

```
wget https://raw.githubusercontent.com/groovy-sky/azure/master/func-http2/script.sh && chmod +x script.sh && ./script.sh

```

Whole thing takes less than 5 minutes:

![](/images/func-az-ip/function_http2_configuration.gif)

## Result

If the deployment was successful you can validate that function uses HTTP/2 protocol using [a number of tools](https://edit.co.uk/blog/test-website-supports-http2-0/):

![](/images/func-az-ip/http2_website_check.png)

## Related Information

* https://developers.google.com/web/fundamentals/performance/http2/
* https://www.keycdn.com/support/http2
* https://github.com/Azure/app-service-announcements/issues/100
* https://azure.microsoft.com/en-us/blog/announcing-http-2-support-in-azure-app-service/?ref=msdn
* https://http2.akamai.com/demo

## 

The Hypertext Transfer Protocol (HTTP) is one of the most ubiquitous and widely adopted application protocols on the Internet: it is the common language between clients and servers, enabling the modern web. HTTP has evolved from an early protocol to exchange files in a semi-trusted laboratory environment, to the modern maze of the Internet. In the first half of the 2010s Google demonstrated an experimental protocol SPDY, which served as the foundations of the HTTP/2 protocol. 

HTTP/2 makes applications faster, simpler, and more robust by allowing to undo many of the HTTP/1.1 workarounds previously done within our applications and address these concerns within the transport layer itself. Even better, it also opens up a number of entirely new opportunities to optimize our applications and improve performance!

Some time ago [Microsoft has announced HTTP/2 support in Azure App Service](https://azure.microsoft.com/en-us/blog/announcing-http-2-support-in-azure-app-service/?ref=msdn). There are several ways to enable HTTP/2 for an application running on Azure App Service. Easiest way how to do that is by using Application Settings, but not all plans support that - for example, on Azure Functions running on Consumption App Service plan. This document gives an example of **enabling HTTP/2 for an Azure Functions running on Consumption App Service**.  

## Deploying and configuring Azure Functions



```
wget https://raw.githubusercontent.com/groovy-sky/azure/master/func-http2/script.sh && chmod +x script.sh && ./script.sh

```

## Results

![](/images/func-az-ip/function_http2_configuration.gif)
## Summary
## Related Information

* https://developers.google.com/web/fundamentals/performance/http2/
* https://www.keycdn.com/support/http2
* https://github.com/Azure/app-service-announcements/issues/100
* https://azure.microsoft.com/en-us/blog/announcing-http-2-support-in-azure-app-service/?ref=msdn
* https://http2.akamai.com/demo

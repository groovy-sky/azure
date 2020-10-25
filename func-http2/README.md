# 
## Introduction

The Hypertext Transfer Protocol (HTTP) is one of the most ubiquitous and widely adopted application protocols on the Internet: it is the common language between clients and servers, enabling the modern web. HTTP has evolved from an early protocol to exchange files in a semi-trusted laboratory environment, to the modern maze of the Internet. 

HTTP/2 will makes applications faster, simpler, and more robust — a rare combination — by allowing us to undo many of the HTTP/1.1 workarounds previously done within our applications and address these concerns within the transport layer itself. Even better, it also opens up a number of entirely new opportunities to optimize our applications and improve performance!

Some time ago [Microsoft has announced HTTP/2 support in Azure App Service](https://azure.microsoft.com/en-us/blog/announcing-http-2-support-in-azure-app-service/?ref=msdn). There are several ways to enable HTTP/2 for an application running on Azure App Service, and the easiest one is through Application Settings. If you're using the Consumption plan, 

## Theoretical Part
HTTP/2 is the first major HTTP protocol update since 1997 when HTTP/1.1 was first published by the IETF. The new HTTP protocol is needed to keep up with the exponential growth of the web. The successor of HTTP/1.1 brings significant improvement in efficiency, speed and security and is supported by most modern web browsers.

## Prerequisites
## Practical Part

```
deploy_region="westeurope"                                                                                    
deploy_group="http2-func-group"
deploy_subscription=$(az account show --output tsv --query id)

az group create -l $deploy_region -n $deploy_group

function_name=$(az deployment group create --resource-group $deploy_group --template-uri https://raw.githubusercontent.com/groovy-sky/azure-func-go-handler/master/Template/azuredeploy.json | jq -r '. | .properties.outputs.functionName.value')


az rest --method patch --uri "https://management.azure.com/subscriptions/$deploy_subscription/resourceGroups/$deploy_group/providers/Microsoft.Web/sites/$function_name/config/web?api-version=2018-02-01" --body '{"properties":{"http20Enabled":true}}'


[ ! -d "azure-func-go-handler/.git" ] && git clone https://github.com/groovy-sky/azure-func-go-handler        
cd azure-func-go-handler/Function && git pull  

go build *.go && func azure functionapp publish $function_name --no-build --force

echo "Verify HTTP/2 support: https://tools.keycdn.com/http2-test?url=https://$function_name.azurewebsites.net"
echo "Verify function: https://$function_name.azurewebsites.net/api/http"


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

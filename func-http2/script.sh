#!/bin/bash

deploy_region="westeurope"                                                                                    
deploy_group="http2-func-group"                                                                               
deploy_subscription=$(az account show --output tsv --query id)                                                

echo "## $deploy_group group in $deploy_region region creation"
                                                                                                              
az group create -l $deploy_region -n $deploy_group                                                            
                          
echo "## Initial function deployment"
                                                                                    
function_name=$(az deployment group create --resource-group $deploy_group --template-uri https://raw.githubusercontent.com/groovy-sky/azure-func-go-handler/master/Template/azuredeploy.json | jq -r '. | .properties.outputs.functionName.value')

echo "## HTTP/2 activation"                                                                                                              
                                                                                                              
az rest --method patch --uri "https://management.azure.com/subscriptions/$deploy_subscription/resourceGroups/$deploy_group/providers/Microsoft.Web/sites/$function_name/config/web?api-version=2018-02-01" --body '{"properties":{"http20Enabled":true}}'
                                                                                                              
echo "## Code build and publish"
                                                                                                              
[ ! -d "azure-func-go-handler/.git" ] && git clone https://github.com/groovy-sky/azure-func-go-handler        
cd azure-func-go-handler/Function && git pull                                                                 
                                                                                                              
go build *.go && func azure functionapp publish $function_name --no-build --force                             
                                                                                                              
echo "## To verify HTTP/2 support: https://tools.keycdn.com/http2-test?url=https://$function_name.azurewebsites.net"
echo "## To run the function: https://$function_name.azurewebsites.net/api/httptrigger"

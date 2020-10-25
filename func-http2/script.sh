#!/bin/bash

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

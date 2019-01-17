# How-to deploy SonarQube to Azure (part 2)

## Introduction

[In the previous chapter](/sonarqube-00/README.md) we have deployed and configured SonarQube environment on Azure. This time we will provision an Azure DevOps Project and configure CI pipeline to integrate it with SonarQube.


## Architecture
Solution parts:

* Source repository - in this example we will use [Azure CLI source code](https://github.com/Azure/azure-cli)
* Build envinorment - Azure DevOps
* SonarQube server

![](/images/sonarqube-101/build_pipeline.png)

## Prerequisites

Azure DevOps (aka VSTS) with installed SonarQube extension
If you don't have exsisting Azure DevOps project you can easily create a new one.

Go to https://azure.microsoft.com/en-us/services/devops and create a project:
![](/images/sonarqube-101/devops_first_project.png)


Now we can register [SonarQube extension](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarqube):
![](/images/sonarqube-101/sonar_marketplace.png)
![](/images/sonarqube-101/sonar_marketplace_succeed.png)

## Implementation

![](/images/sonarqube-101/devops_import_repo.png)
![](/images/sonarqube-101/devops_import_repo_result.png)

![](/images/sonarqube-101/new_pipeline.png)

![](/images/sonarqube-101/pipeline_cleanup.png)

![](/images/sonarqube-101/specify_pipeline_variable.png)
As [official documentation](https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Extension+for+VSTS-TFS) says - "To analyse your projects, the extension provides 3 tasks that you will use in your build definitions". Steps are following:
1. Prepare Analysis Configuration task, to configure all the required settings before executing the build. 
1. Run Code Analysis task, to actually execute the analysis of the source code. 
1. Publish Quality Gate Result task, to display the Quality Gate status in the build summary and give you a sense of whether the application is ready for production "quality-wise". 
Third step is not matadory, which is why we will skip it and add only "Prepare Analysis Configuration" and "Run Code Analysis" tasks:
![](/images/sonarqube-101/add_sonar_to_pipeline.png)
![](/images/sonarqube-101/pipeline_config_1.png)
![](/images/sonarqube-101/pipeline_config_2.png)

![](/images/sonarqube-101/pipeline_run_result.png)


### Known limitations

![](/images/sonarqube-101/sonar_error.png)

![](/images/sonarqube-101/serial_console_enable.png)
![](/images/sonarqube-101/serial_login.png)
![](/images/sonarqube-101/add_client_max_param.png)


http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size
sudo nano /etc/nginx/sites-enabled/default
sudo systemctl reload nginx

## Results

![](/images/sonarqube-101/sonarqube_azure_results.png)

## Useful documentation

https://www.azuredevopslabs.com/labs/vstsextend/sonarqube/
https://docs.sonarqube.org/latest/analysis/overview/

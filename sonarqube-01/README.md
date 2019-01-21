# How-to deploy SonarQube to Azure (part 2)

## Introduction

[In the previous chapter](/sonarqube-00/README.md) we have deployed and configured SonarQube environment on Azure. This time we will provision an Azure DevOps Project and configure CI pipeline to integrate it with SonarQube.


## Architecture
In our scenario we will use configuration, which contain 3 main parts:

* Some code, which we will analyze - in this example we will copy [Azure CLI source code](https://github.com/Azure/azure-cli)
* Build environment - Azure DevOps Build pipeline
* SonarQube server

![](/images/sonarqube-101/build_pipeline.png)

## Prerequisites
For this tutorial we would need to install [SonarQube extension](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarqube) from the Marketplace.

If you don't have existing Azure DevOps project you can easily create a new one. Just go to https://azure.microsoft.com/en-us/services/devops and create a new project:
![](/images/sonarqube-101/devops_first_project.png)

Next step is [SonarQube extension](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarqube) installation:
![](/images/sonarqube-101/sonar_marketplace.png)
![](/images/sonarqube-101/sonar_marketplace_succeed.png)

## Implementation

As has been mentioned above for a source code we will use "Azure CLI" repository. Let's import it to our project: 
![](/images/sonarqube-101/devops_import_repo.png)
![](/images/sonarqube-101/devops_import_repo_result.png)

Once data is imported - we can create a new build pipeline:
![](/images/sonarqube-101/new_pipeline.png)

There is no need to run "Flake8" and "pytest" pipeline steps, so we can just remove or disable them(use right click to open the menu): 
![](/images/sonarqube-101/pipeline_cleanup.png)

Next, we need to add SonarQube part to the pipeline. As [official documentation](https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Extension+for+VSTS-TFS) says - "To analyse your projects, the extension provides 3 tasks that you will use in your build definitions". Steps are following:
1. Prepare Analysis Configuration task, to configure all the required settings before executing the build. 
1. Run Code Analysis task, to actually execute the analysis of the source code. 
1. Publish Quality Gate Result task, to display the Quality Gate status in the build summary and give you a sense of whether the application is ready for production "quality-wise". 

Third task is not mandatory, which is why we will skip it and add only "Prepare Analysis Configuration" and "Run Code Analysis" tasks:
![](/images/sonarqube-101/add_sonar_to_pipeline.png)

Now we need to configure "Prepare Analysis Configuration" step. To do so we need to generate new token on SonarQube server side:
![](/images/sonarqube-101/new_sonar_token.png)
Generated token we will use for a new service creation and, as we won't store sonarqube settings in our source code, manually provide in the pipeline:
![](/images/sonarqube-101/devops_new_service.png)
![](/images/sonarqube-101/pipeline_config_1.png)

Also we will need to specify "working directory" for "Build sdist" task:
![](/images/sonarqube-101/pipeline_config_2.png)

By default build pipeline will use for a build multiple Python versions. As enhancement we can set only one version: 
![](/images/sonarqube-101/specify_pipeline_variable.png)

Now we can save and queue our build pipeline: 
![](/images/sonarqube-101/run_a_pipeline.png)

### Known limitations

If build fails with "413 Request Entity Too Large" error - when you need to increase NGINX's [upload size limit](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size):
![](/images/sonarqube-101/sonar_error.png)

NGINX is running as a service on SonarQube server. To change required parameter we could:
* Connect to VM using SSH - for that we need to add an [allow rule to NSG](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/nsg-quickstart-portal#create-an-inbound-security-rule)
* Connect to VM using Serial console - for that we need to enable boot diagnostics

This time we will use second option. Let's enable it:
![](/images/sonarqube-101/serial_console_enable.png)
For a login, please, use "adm1n" for a username and for a password you need to use password which you specified during template deployment from previous article(or if you don't remember it - just [reset it](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/vmaccess#reset-password)):
![](/images/sonarqube-101/serial_login.png)

Now we can modify required parameter in your preferable text editor (for example "sudo nano /etc/nginx/sites-enabled/default"): 
![](/images/sonarqube-101/add_client_max_param.png)

So changes started to work we need to reload NGINX - "sudo systemctl reload nginx"

## Results

Once build successfully completes, go to SonarQube to see analysis results:

![](/images/sonarqube-101/pipeline_run_result.png)

![](/images/sonarqube-101/sonarqube_azure_results.png)

## Useful documentation

https://www.azuredevopslabs.com/labs/vstsextend/sonarqube/

https://docs.sonarqube.org/latest/analysis/overview/

https://www.keycdn.com/support/413-request-entity-too-large

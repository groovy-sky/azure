# 
![](/images/logos/function.png)
## Introduction
Azure Container Apps enables you to build serverless microservices and jobs based on containers. Distinctive features of Container Apps include:

    Optimized for running general purpose containers, especially for applications that span many microservices deployed in containers.
    Powered by Kubernetes and open-source technologies like Dapr, KEDA, and envoy.
    Supports Kubernetes-style apps and microservices with features like service discovery and traffic splitting.
    Enables event-driven application architectures by supporting scale based on traffic and pulling from event sources like queues, including scale to zero.
    Supports running on demand, scheduled, and event-driven jobs.

Azure Container Apps doesn't provide direct access to the underlying Kubernetes APIs. If you require access to the Kubernetes APIs and control plane, you should use Azure Kubernetes Service. However, if you would like to build Kubernetes-style applications and don't require direct access to all the native Kubernetes APIs and cluster management, Container Apps provides a fully managed experience based on best-practices. For these reasons, many teams may prefer to start building container microservices with Azure Container Apps.
     

This document gives an example of using Azure Container Apps to run a containerized Go application. The application is a simple web server that returns the client's IP address. The application is packaged as a container image and deployed to Azure Container Apps. The application is then accessed through a public URL.

## Theoretical Part

Azure Container Apps is a serverless compute platform that enables you to run containerized microservices and jobs without having to manage infrastructure. Container Apps is built on open-source technologies such as Kubernetes, Dapr, KEDA, and Envoy. Container Apps provides a fully managed experience based on best-practices that enables you to focus on your business logic and not worry about the underlying infrastructure.

Container Apps features two different plan types: Consumption and Dedicated. The Consumption plan is a serverless environment that supports scale-to-zero and pay only for resources your apps use. The Dedicated plan is a fully managed environment that supports scale-to-zero and pay only for resources your apps use. Optionally, you can run apps with customized hardware and increased cost predictability using Dedicated workload profiles.

App also can be different types: apps and jobs. Apps are services that run continuously. If a container in an app fails, it's restarted automatically. Jobs are tasks that start, run for a finite duration, and exit when finished. Each execution of a job typically performs a single unit of work. Job executions start manually, on a schedule, or in response to events.

Apps environments is a secure boundary around one or more container apps and jobs. The Container Apps runtime manages each environment by handling OS upgrades, scale operations, failover procedures, and resource balancing. Single environment can contain multiple container apps and jobs. Multiple environments can be used when you want two or more applications to never share the same compute resources, not communicate via the Dapr service invocation API or be isolated due to team or environment usage (for example, test vs. production).

Azure Container Apps allows you to expose your container app to the public web, your virtual network (VNET), and other container apps within your environment by enabling ingress. Ingress settings are enforced through a set of rules that control the routing of external and internal traffic to your container app. When you enable ingress, you don't need to create an Azure Load Balancer, public IP address, or any other Azure resources to enable incoming HTTP requests or TCP traffic.

## Practical Part

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure%2Fmaster%2Fcontainer-app-00%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a> 
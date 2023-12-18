# Introduction to Azure Container Apps
![](/images/logos/container_app.png)
## Introduction

There are many options for teams to build and deploy cloud native and containerized applications on Azure (such as App Service, Container Instances, Kubernetes Service, Azure Functions etc.). Each of these options has its own strengths and use cases. Azure Container Apps is a new service that provides a fully managed option for running containerized microservices and jobs without having to manage any infrastructure.

This document **gives an example of using Azure Container Apps to run a simple application, that returns the client's IP address**. The application is packaged as a Docker image and deployed to Azure Container Apps. The application is then accessed through a public URL.

## Theoretical Part

Azure Container Apps enables you to build serverless microservices and jobs based on containers. Distinctive features of Container Apps include:

* Optimized for running general purpose containers, especially for applications that span many microservices deployed in containers.
* Powered by Kubernetes and open-source technologies like Dapr, KEDA, and envoy.
* Supports Kubernetes-style apps and microservices with features like service discovery and traffic splitting.
* Enables event-driven application architectures by supporting scale based on traffic and pulling from event sources like queues, including scale to zero.
* Supports running on demand, scheduled, and event-driven jobs.

Azure Container Apps doesn't provide direct access to the underlying Kubernetes APIs. If you require access to the Kubernetes APIs and control plane, you should use Azure Kubernetes Service. However, if you would like to build Kubernetes-style applications and don't require direct access to all the native Kubernetes APIs and cluster management, Container Apps provides a fully managed experience based on best-practices. For these reasons, many teams may prefer to start building container microservices with Azure Container Apps.

### Consumption and Dedicated plans

Container Apps features two different plan types: Consumption and Dedicated. The Consumption plan is a serverless environment that supports scale-to-zero and pay only for resources your apps use. The Dedicated plan is a fully managed environment that supports scale-to-zero and pay only for resources your apps use. Optionally, you can run apps with customized hardware and increased cost predictability using Dedicated workload profiles.

### Apps and jobs

App also can be different types: apps and jobs. Apps are services that run continuously. If a container in an app fails, it's restarted automatically. Jobs are tasks that start, run for a finite duration, and exit when finished. Each execution of a job typically performs a single unit of work. Job executions start manually, on a schedule, or in response to events.

### Container Apps runtime

Apps environments is a secure boundary around one or more container apps and jobs. The Container Apps runtime manages each environment by handling OS upgrades, scale operations, failover procedures, and resource balancing. Single environment can contain multiple container apps and jobs. Multiple environments can be used when you want two or more applications to never share the same compute resources, not communicate via the Dapr service invocation API or be isolated due to team or environment usage (for example, test vs. production).

Azure Container Apps allows you to expose your container app to the public web, your virtual network (VNET), and other container apps within your environment by enabling ingress. Ingress settings are enforced through a set of rules that control the routing of external and internal traffic to your container app. When you enable ingress, you don't need to create an Azure Load Balancer, public IP address, or any other Azure resources to enable incoming HTTP requests or TCP traffic.

## Practical Part

To run a demo application, you need to have an Azure subscription. If you don't have one, you can create a [free account](https://azure.microsoft.com/en-us/free/).

On top of that you'll need to compile the application's code below and build a Docker image. Or you can use [following Docker image](https://hub.docker.com/repository/docker/gr00vysky/myip) instead.


### Application code

main.go:

```
package main

import (
        "fmt"
        "log"
        "net/http"
        "os"
        "strings"
)

// Parse IP from X-Forwarded-For, Host or RemoteAddr headers
func parseIp(r *http.Request) (ip string) {
        if r.Header.Get("X-Forwarded-For") != "" {
                ip = strings.Split(r.Header.Get("X-Forwarded-For"), ":")[0]
        } else if r.Header.Get("Host") != "" {
                ip = strings.Split(r.Header.Get("Host"), ":")[0]
        } else if r.RemoteAddr != "" {
                ip = strings.Split(r.RemoteAddr, ":")[0]
        }
        return ip
}

// Returns client's IP address
func myIpHandler(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte(parseIp(r)))
}

func main() {
        httpInvokerPort, exists := os.LookupEnv("HTTP_PORT")
        if exists {
                fmt.Println("HTTP_PORT: " + httpInvokerPort)
        } else {
                httpInvokerPort = "8080"
        }
        mux := http.NewServeMux()
        mux.HandleFunc("/", myIpHandler)

        log.Println("[INF] Listening on port", httpInvokerPort)
        log.Fatal(http.ListenAndServe(":"+httpInvokerPort, mux))
}
```

Dockerfile:
```
FROM golang:1.20-alpine
ENV HTTP_PORT=8080
EXPOSE ${HTTP_PORT}/tcp
COPY /main.go .
RUN apk add --no-cache ca-certificates && update-ca-certificates && mkdir -p /etc/pki/ca-trust/source && ln -s /usr/local/share/ca-certificates /etc/pki/ca-trust/source/anchors && go build main.go
CMD ["/go/main"]
```

### Deploying the application

To deploy the application to Azure Container Apps, you can use the Azure portal, Azure CLI, or Azure Resource Manager templates. In this example, you'll use the Azure portal.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Fazure%2Fmaster%2Fcontainer-app-00%2Fazuredeploy.json" target="_blank"> <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a> 

1. Click the "Deploy to Azure" button above and deploy the application to Azure Container Apps (you can use the default values for the parameters):

![Deploy to Azure](/images/docker/container_app_arm_deploy.png)

2. After the deployment is complete, navigate to the resource group that was created and click on the Container App resource:

![Container App resource](/images/docker/container_app_example_00.png)

3. Copy Application URL from the Overview page and access it from your browser:

![My IP page](/images/docker/showmyip_app_demo.png)

## Summary

In this example, you learned how to deploy a simple application to Azure Container Apps. You can now use this knowledge to deploy your own applications to Azure Container Apps. But it is possible to use Azure Container Apps for more complex scenarios. For example, you can use it to whitelist your IP address on Azure resources(like Storage account or Network Security Group). Next chapter will show you how to do it.

## Related materials

* [Azure Container Apps documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
# Using Container App as a Web Proxy

## Introduction

This project demonstrates a practical architecture for exposing a private backend service through a secure public endpoint while keeping the backend infrastructure isolated from the internet.

The solution uses Azure Container Apps as a public gateway and Azure Container Instances as a private backend runtime. A lightweight reverse proxy written in Go receives incoming requests and forwards them to a backend container located inside a virtual network.

The goal of the project is to implement a reusable pattern where:

- the public interface is secure and internet‑accessible
- the backend application remains private
- infrastructure can be deployed automatically using an ARM template

This approach is useful for environments where backend services must remain isolated but still need to be accessible through HTTPS.

# Theory

## Containerization

Containerization is a method of packaging an application together with its runtime environment, dependencies, and libraries into a single executable unit called a container.

Because the runtime environment is bundled with the application, the container behaves consistently across different systems such as developer machines, testing environments, and cloud infrastructure.

Containers are commonly built and executed using tools such as Docker. They allow applications to be deployed reliably without requiring system‑specific configuration.

## Azure Container Apps

Azure Container Apps is a managed platform designed for running containerized applications without managing Kubernetes clusters directly.

Developers provide a container image and define basic runtime parameters such as CPU, memory, and scaling behavior. The platform handles infrastructure provisioning, networking integration, and service scaling.

Container Apps is typically used for:

- web services
- APIs
- microservices
- event‑driven applications

The platform includes built‑in ingress capabilities that allow applications to be exposed either internally within a network or externally to the internet.

## Azure Container Instances

Azure Container Instances (ACI) is a service that allows containers to run without deploying container orchestration platforms or virtual machines.

ACI focuses on simplicity and fast startup times. Containers can be started quickly and run as standalone workloads.

Common scenarios for ACI include:

- temporary compute workloads
- batch processing
- testing environments
- simple containerized services

ACI can also be deployed inside a virtual network, allowing containers to run privately without public internet access.

## Container App vs Container Instance

Although both services run containers, they serve different roles.

Azure Container Apps acts as an **application hosting platform**. It is designed for long‑running services that receive requests and may need scaling and traffic management.

Azure Container Instances acts as a **container execution service**. It is designed for running containers with minimal infrastructure overhead.

In this project, both services are used together:

- Container Apps provides the **public entry point**
- Container Instances hosts the **private backend application**

# Practical Implementation

## Infrastructure Deployment

The solution infrastructure is deployed using an ARM template. The template automatically creates all resources required for the architecture.

The deployment process performs the following steps.

### Virtual Network Creation

First, a virtual network is created.
The network contains two subnets with service delegations:

- a subnet for Azure Container Instances
- a subnet for the Azure Container Apps managed environment

This network structure allows the backend container to remain private while still allowing the proxy to communicate with it.

### Backend Container Deployment

Next, a container group is deployed inside the Container Instance subnet.

This container acts as the backend application.
It runs without a public IP address and is reachable only from within the virtual network.

Because the backend container is private, it cannot be accessed directly from the internet.

### Container Apps Environment

After the network and backend container are created, the ARM template deploys a managed Container Apps environment.

The environment is connected to the virtual network so that Container Apps can communicate with resources inside the network, including the private container instance.

### Proxy Deployment

The final component deployed by the ARM template is the proxy application running inside Azure Container Apps.

The proxy is deployed as a container image and exposed through an external ingress endpoint. This endpoint becomes the public interface of the system.

The Container App is assigned a **system‑managed identity**, which allows the proxy to interact with Azure services without storing credentials.

## Proxy Runtime Logic

The Go proxy application implements the runtime behavior of the system.

### Incoming Request

When a user sends an HTTPS request to the Container App's public endpoint, the request is received by the proxy application.

```text
Internet Client
	|
	| HTTPS
	v
[Go Reverse Proxy in Container App]
	|
	| HTTP (through private VNet)
	v
[ACI Private IP:Port]
```

### Request Trigger

When a request arrives at the Container App endpoint, the proxy begins processing the request.

The proxy first authenticates with Azure using the managed identity assigned to the Container App. This allows it to interact with Azure Resource Manager APIs.

### Container Discovery

Using this identity, the proxy searches for available container instances that can serve as backend targets.

The proxy enumerates container groups across the Azure subscriptions accessible to the managed identity. For each container group, it retrieves configuration details and determines whether the container exposes a valid HTTP port.

### Container Startup

If a suitable container instance is found but is not currently running, the proxy initiates a start operation through the Azure Container Instances management API.

The proxy waits until the container reaches the **Running** state before proceeding.

This allows container instances to remain stopped when they are not needed and start automatically when traffic arrives.

### Request Forwarding

Once the backend container is running and reachable, the proxy forwards the incoming request to the container using its private IP address and exposed port.

The forwarding process is implemented using a reverse proxy mechanism that preserves the original request path and headers.

From the user perspective, the interaction appears as a normal request to a single public service.

# Result

After deployment and startup, the system provides a working architecture where:

- users access a public HTTPS endpoint exposed by the Container App
- the proxy receives and processes incoming requests
- the proxy automatically starts a backend container instance if necessary
- the request is forwarded through the private virtual network
- the backend service processes the request without being exposed to the internet

The backend container remains private and is never directly reachable from outside the virtual network.

# Summary

This project demonstrates how Azure Container Apps and Azure Container Instances can be combined to implement a secure access architecture.

The Container App acts as a public gateway that receives user requests. The proxy running inside the Container App dynamically discovers and starts backend container instances when needed.

Requests are then forwarded to the backend through a private virtual network connection.

This approach provides several advantages:

- backend services remain private and protected from direct internet access
- the public entry point is centralized and easy to manage
- managed identities eliminate the need for embedded credentials
- container instances can start on demand, reducing unnecessary runtime

The result is a simple, secure, and reusable pattern for exposing private containerized services through a controlled public endpoint.
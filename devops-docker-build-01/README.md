# Running a self-hosted build agent on Azure Kubernetes Service 
## Introduction

This document gives an **example of using Azure Kubernetes Service as Azure DevOps build agent**.

## Theoretical Part

Kubernetes is open source software that allows you to deploy and manage containerized applications at scale. 

Kubernetes works by managing a cluster of compute instances and scheduling containers to run on the cluster based on the available compute resources and the resource requirements of each container. Containers are run in logical groupings called pods and you can run and scale one or many containers together as a pod.

### Kubernetes Components

A Kubernetes cluster consists of a set of worker machines, called nodes, that run containerized applications. Every cluster has at least one worker node.

The worker node(s) host the Pods that are the components of the application workload. The control plane manages the worker nodes and the Pods in the cluster. In production environments, the control plane usually runs across multiple computers and a cluster usually runs multiple nodes, providing fault-tolerance and high availability.

#### Control Plane

The control plane's components make global decisions about the cluster (for example, scheduling), as well as detecting and responding to cluster events (for example, starting up a new pod when a deployment's replicas field is unsatisfied).

## Prerequisites
## Practical Part

## Results
## Summary
## Related Information
* https://kubernetes.io/docs/tutorials/kubernetes-basics/
* https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes
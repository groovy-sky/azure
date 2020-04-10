# Infrastructure as Code (part 3)
![](/images/iac/logo_transparent.png)

## Introduction

This article describes the third part of Infrastructure as Code approach (previous part about Cloud orchestration is available [here](/iac-01/README.md)). With this in mind, let’s look at containers.

![](/images/iac/cloud_journey_02.png)

Containerization has become a major trend in software development as an alternative or companion to virtualization. It involves encapsulating or packaging up software code and all its dependencies so that it can run uniformly and consistently on any infrastructure. The technology is quickly maturing, resulting in measurable benefits for developers and operations teams as well as overall software infrastructure.

**This document gives an example of using Github Actions to build a Docker image.**

## Theoretical Part

### Github Actions
At Universe 2018, Github launched GitHub Actions, a community-led approach to build and share automation for software development, including a full CI/CD solution and native package management.

You can use Actions to automatically publish new package versions to GitHub Packages, trigger package installs with Actions, and install packages and images hosted on GitHub Packages or your preferred registry of record with minimal configurations.

Below is a list of common GitHub Actions terms:
* Event - a specific activity that triggers a workflow run. 
* Action - is the smallest portable building block of a workflow. To use an action in a workflow, you must include it as a step.
* Step - is an individual task that can run commands or actions. A job configures one or more steps. Each step in a job executes on the same runner, allowing the actions in that job to share information using the filesystem.
* Job - a set of steps that execute on the same runner. Jobs can run at the same time in parallel or run sequentially depending on the status of a previous job. 
* Workflow - one or more jobs, which can be scheduled or activated by an event. Is presented as YAML file, located under .github/workflows directory
* Workflow run - an instance of your workflow that runs when the pre-configured event occurs. 
* Artifacts - are the files created when you build and test your code.
* Runner - any machine with the GitHub Actions runner application installed. You can use a runner hosted by GitHub or host your own runner. GitHub hosts Linux, Windows, and macOS runners. You can specify the runner type for each job in a workflow. Each job in a workflow executes in a fresh instance of the virtual machine. All steps in the job execute in the same instance of the virtual machine, allowing the actions in that job to share information using the filesystem.
* Environment variables - provides to construct file paths for the home, workspace, and workflow directories. Home directory contains user-related data. Actions and shell commands are executed in workspace directory. 

### Docker

Docker container technology was launched in 2013 as an open source Docker Engine. Containers encapsulate an application as a single executable package of software that bundles application code together with all of the related configuration files, libraries, and dependencies required for it to run. 

Containerized applications are “isolated” in that they do not bundle in a copy of the operating system. Instead, an open source Docker engine is installed on the host’s operating system and becomes the conduit for containers to share an operating system with other containers on the same computing system.

Below is a list of common Docker terms:

* Docker Engine is a client-server application with 3 major components - a server which is a type of long-running program called a daemon process; a REST API which specifies interfaces that programs can use to talk to the daemon and instruct it what to do; a command line interface (CLI) client.

* The Docker daemon (dockerd) listens for Docker API requests and manages Docker objects such as images, containers, networks, and volumes. 

* The Docker client (docker) is the primary way that many Docker users interact with Docker. When you use commands such as docker run, the client sends these commands to dockerd, which carries them out. The docker command uses the Docker API. The Docker client can communicate with more than one daemon.

* An image is a read-only template with instructions for creating a Docker container. You might create your own images or you might only use those created by others and published in a registry. To build your own image, you create a Dockerfile with a simple syntax for defining the steps needed to create the image and run it.

* A Docker registry stores Docker images. Docker Hub is a public registry that anyone can use, and Docker is configured to look for images on Docker Hub by default.

* A container is a runnable instance of an image. Containers are made possible by operating system (OS) process isolation and virtualization, which enable multiple application components to share the resources of a single instance of an OS kernel.



## Prerequisites

## Practical Part

At a high level, these are the steps to add a workflow file. You can find specific configuration examples in the sections that follow.

1. At the root of your repository, create a directory named .github/workflows to store your workflow files.

2. In .github/workflows, add a .yml or .yaml file for your workflow. For example, .github/workflows/continuous-integration-workflow.yml.

3. Use the "Workflow syntax for GitHub Actions" reference documentation to choose events to trigger an action, add actions, and customize your workflow.

4. Commit your changes in the workflow file to the branch where you want your workflow to run.


## Results

## Summary

## Related Information


* https://help.github.com/en/actions

* https://www.ibm.com/cloud/learn/docker
# Infrastructure as Code (part 3)
![](/images/iac/logo_transparent.png)

## Introduction

This article describes the third part of Infrastructure as Code approach (previous part about Cloud orchestration is available [here](/iac-01/README.md)). With this in mind, let’s discuss a containerization.

![](/images/iac/cloud_journey_02.png)

Containerization has become a major trend in software development as an alternative or companion to virtualization. It involves encapsulating or packaging up software code and all its dependencies so that it can run uniformly and consistently on any infrastructure. The technology is quickly maturing, resulting in measurable benefits for developers and operations teams as well as overall software infrastructure.

This document gives an example of using Github Actions to build a Docker image, which can be used to run a container.

## Theoretical Part

### Github Actions
At Universe 2018, Github launched GitHub Actions, a community-led approach to build and share automation for software development, including a full CI/CD solution and native package management.

![](/images/iac/auto_assembly.png)

Below is a list of common GitHub Actions terms:
* **Event** - a specific activity that triggers a workflow run. 
* **Action** - is the smallest portable building block of a workflow. To use an action in a workflow, you must include it as a step.
* **Step** - is an individual task that can run commands or actions. A job configures one or more steps. Each step in a job executes on the same runner, allowing the actions in that job to share information using the filesystem.
* **Job** - a set of steps that execute on the same runner. Jobs can run at the same time in parallel or run sequentially depending on the status of a previous job. 
* **Workflow** - one or more jobs, which can be scheduled or activated by an event. Is presented as YAML file, located under .github/workflows directory
* **Workflow run** - an instance of your workflow that runs when the pre-configured event occurs. 
* **Artifacts** - are the files created when you build and test your code.
* **Runner** - any machine with the GitHub Actions runner application installed. You can use a runner hosted by GitHub or host your own runner. GitHub hosts Linux, Windows, and macOS runners. You can specify the runner type for each job in a workflow. Each job in a workflow executes in a fresh instance of the virtual machine. All steps in the job execute in the same instance of the virtual machine, allowing the actions in that job to share information using the filesystem.
* **Environment variables** - provides to construct file paths for the home, workspace, and workflow directories. Home directory contains user-related data. Actions and shell commands are executed in workspace directory. 

### Docker

Docker container technology was launched in 2013 as an open source Docker Engine. Containers encapsulate an application as a single executable package of software that bundles application code together with all of the related configuration files, libraries, and dependencies required for it to run. 

Containerized applications are “isolated” in that they do not bundle in a copy of the operating system. Instead, an open source Docker engine is installed on the host’s operating system and becomes the conduit for containers to share an operating system with other containers on the same computing system.

![](/images/iac/docker_arch.png)

Below is a list of common Docker terms:

* **Docker Engine** is a client-server application with 3 major components - a server which is a type of long-running program called a daemon process; a REST API which specifies interfaces that programs can use to talk to the daemon and instruct it what to do; a command line interface (CLI) client.

* **Docker daemon** (dockerd) listens for Docker API requests and manages Docker objects such as images, containers, networks, and volumes. 

* **Docker client** (docker) is the primary way that many Docker users interact with Docker. When you use commands such as docker run, the client sends these commands to dockerd, which carries them out. The docker command uses the Docker API. The Docker client can communicate with more than one daemon.

* **Image** is a read-only template with instructions for creating a Docker container. You might create your own images or you might only use those created by others and published in a registry. To build your own image, you create a Dockerfile with a simple syntax for defining the steps needed to create the image and run it.

* **Docker registry** stores Docker images. Docker Hub is a public registry that anyone can use, and Docker is configured to look for images on Docker Hub by default.

* **Container** is a runnable instance of an image. Containers are made possible by operating system (OS) process isolation and virtualization, which enable multiple application components to share the resources of a single instance of an OS kernel.

## Prerequisites

Before you begin, you’ll need:
* Github account (registration available [here](https://github.com/join?source=header-home))
* Docker Hub account (registration available [here](https://hub.docker.com/signup))

## Practical Part

As always, a start point is [iaac-demo repository](https://github.com/groovy-sky/iaac-demo). To build a Docker image you will need a workflow file and Dockerfile. You can either fork the whole repository or just copy [Dockerfile](https://raw.githubusercontent.com/groovy-sky/iaac-demo/master/docker/Dockerfile) and [build_docker_image.yml](https://raw.githubusercontent.com/groovy-sky/iaac-demo/master/.github/workflows/build_docker_image.yml) files.

Dockerfile file looks following:
![](/images/iac/dockerfile_structure.png)

Workflow file looks following:
![](/images/iac/build_workflow_structure.png)

Before you can run the workflow you need to obtain and store Docker Hub credentials - username and a personal access tokens (which is an alternatives to a password). At first go to Docker Hub and obtain/generate required data:
![](/images/iac/get_docker_credentials.png)

Next, go to Github and create 'DockerHubToken' and 'DockerHubUser' secrets:
![](/images/iac/set_docker_credentials.png)

Action will trigger on a push event. So, to trigger it, you can make small modifications of the workflow file (add a space in comments section) and push the changes to Github.

## Results
If the workflow run was successful you can validate a result in Docker Hub:
![](/images/iac/docker_build_result.png)

If you want just to try - use this demo build. To do so, run ``docker run -it gr00vysky/iac-demo:latest`` command on your Docker host.

## Summary
As was mentioned in the introduction section, this article gives an example of using Github Actions for building a Docker image. And as was expected, that can be done in a fairly straightforward way - both configuration files uses less than 100 lines of a code. The next time I am going to show how to run a Docker image on an another CI/CD platform.

## Related Information


* https://help.github.com/en/actions

* https://www.ibm.com/cloud/learn/docker

* https://www.docker.com/blog/docker-hub-new-personal-access-tokens/

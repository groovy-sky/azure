# Infrastructure as Code (part 3)
![](/images/iac/logo_transparent.png)

## Introduction

## Theoretical Part

Below is a list of common GitHub Actions terms.

### Action

Individual tasks that you combine as steps to create a job. Actions are the smallest portable building block of a workflow. To use an action in a workflow, you must include it as a step.

### Artifact

Artifacts are the files created when you build and test your code.

### Continuous integration (CI)

The software development practice of frequently committing small code changes to a shared repository. With GitHub Actions, you can create custom CI workflows that automate building and testing your code.

### Continuous deployment (CD)

Continuous deployment builds on continuous integration. When new code is committed and passes your CI tests, the code is automatically deployed to production.

### Event

A specific activity that triggers a workflow run. 

### Runner

Any machine with the GitHub Actions runner application installed. You can use a runner hosted by GitHub or host your own runner. 

### GitHub-hosted runner

GitHub hosts Linux, Windows, and macOS runners. Jobs run in a fresh instance of a virtual machine that includes commonly-used, preinstalled software. GitHub performs all upgrades and maintenance of GitHub-hosted runners. You cannot customize the hardware configuration of GitHub-hosted runners. 

You can specify the runner type for each job in a workflow. Each job in a workflow executes in a fresh instance of the virtual machine. All steps in the job execute in the same instance of the virtual machine, allowing the actions in that job to share information using the filesystem.

GitHub hosts Linux and Windows runners on Standard_DS2_v2 virtual machines in Microsoft Azure with the GitHub Actions runner application installed. The GitHub-hosted runner application is a fork of the Azure Pipelines Agent. Inbound ICMP packets are blocked for all Azure virtual machines, so ping or traceroute commands might not work.

Each virtual machine has the same hardware resources available:

* 2-core CPU
* 7 GB of RAM memory
* 14 GB of SSD disk space

| Virtual environment | YAML workflow label |
| --- | --- |
| Windows Server 2019 | windows-latest or windows-2019 |
| Ubuntu 18.04 | ubuntu-latest or ubuntu-18.04 |
| Ubuntu 16.04 | ubuntu-16.04 |
| macOS Catalina 10.15 | macos-latest or macos-10.15 |

GitHub executes actions and shell commands in specific directories on the virtual machine. The file paths on virtual machines are not static. Use the environment variables GitHub provides to construct file paths for the home, workspace, and workflow directories.

| Directory | Environment variable | Description |
| --- | --- | --- |
| home | HOME | Contains user-related data. For example, this directory could contain credentials from a login attempt. |
| workspace | GITHUB_WORKSPACE | Actions and shell commands execute in this directory. An action can modify the contents of this directory, which subsequent actions can access. |
| workflow/event.json | GITHUB_EVENT_PATH | The POST payload of the webhook event that triggered the workflow. GitHub rewrites this each time an action executes to isolate file content between actions. |

### Step

A step is an individual task that can run commands or actions. A job configures one or more steps. Each step in a job executes on the same runner, allowing the actions in that job to share information using the filesystem.

### Job

A set of steps that execute on the same runner. You can define the dependency rules for how jobs run in a workflow file. Jobs can run at the same time in parallel or run sequentially depending on the status of a previous job. 

### Workflow

A configurable automated process that you can set up in your repository to build, test, package, release, or deploy any project on GitHub. Workflows are made up of one or more jobs and can be scheduled or activated by an event.

### Workflow file

The YAML file that defines your workflow configuration with at least one job. This file lives in the root of your GitHub repository in the .github/workflows directory.

### Workflow run

An instance of your workflow that runs when the pre-configured event occurs. You can see the jobs, actions, logs, and statuses for each workflow run.


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
# Azure articles

A collection of practical articles about deploying, configuring, and operating Azure services and related tools. Articles are grouped by topic; numbered links belong to the same series.

## Networking and IP address management

- **PaaS networking**
  - [Part 1: Service Endpoints](/paas-vnet-00/README.md)
  - [Part 2: Private Endpoints](/paas-vnet-01/README.md)
  - [Part 3: DNS forwarding for on-premises access](/paas-vnet-02/README.md)
  - [Overview of PaaS networking](/paas-vnet-03/README.md)
- [Restricting access to a Storage Account](/paas-vnet-04/README.md)
- [Private Endpoints: overview, benefits, and limitations](/paas-vnet-05/README.md)
- [DNS troubleshooting with Azure Container Instances](/aci-vnet-00/README.md)
- **IP address management and virtual network management**
  - [IPAM concepts and usage](/ipam-app-01/README.md)
  - [Running Azure IPAM on Container Apps](/ipam-app-00/README.md)
  - [Azure Virtual Network Manager](/ipam-app-02/README.md)

## Infrastructure as code

- [Azure Resource Manager overview](/arm-getting-started/README.md)
- **Infrastructure as Code series**
  - [Part 1: ARM templates](/iac-00/README.md)
  - [Part 2: Ansible](/iac-01/README.md)
  - [Part 3: Docker and GitHub Actions](/iac-02/README.md)
  - [Part 4: Azure DevOps and Ansible](/iac-03/README.md)
  - [Part 5: Power Automate and Azure DevOps](/iac-04/README.md)
- **Terraform on Azure**
  - [Part 1: Terraform fundamentals](/tf-intro-00/README.md)
  - [Part 2: Deploying a virtual network](/tf-intro-01/README.md)
  - [Part 3: Terraform state and ARM templates](/tf-intro-02/README.md)
  - [Part 4: Remote state](/tf-intro-03/README.md)
- [Azure Template Specs](/iac-ui-00/README.md)

## Containers and build runners

- [Introduction to Azure Container Apps](/container-app-00/README.md)
- [Azure Container Apps as a reverse proxy](/container-app-proxy/README.md)
- [Running a self-hosted LLM on Azure Container Apps](/local-ai-00/README.md)
- [Hosting a private Docker registry on Azure App Service](/docker-private-registry/README.md)
- [Running Docker using Azure CLI and Cloud Shell](/docker-azure-cli-00/README.md)
- **Self-hosted Azure DevOps build agents**
  - [On Azure Container Instances](/devops-docker-build-00/README.md)
  - [On Azure Container Apps jobs](/devops-docker-build-01/README.md)
- **Self-hosted GitHub Actions runners**
  - [On Azure Container Instances](/github-runner-00/README.md)
  - [On Azure Container Apps jobs](/github-runner-01/README.md)

## CI/CD and automation

- **Migrate from Azure DevOps to GitHub**
  - [Part 1: Platform concepts](/devops-to-github-00/README.md)
  - [Part 2: Azure Pipelines to GitHub Actions](/devops-to-github-01/README.md)
  - [Part 3: Git repository migration](/devops-to-github-02/README.md)
  - [Part 4: Service connections and Azure authentication](/devops-to-github-03/README.md)
- **Ansible Tower (AWX)**
  - [Part 1: Installation and configuration](/ansible-tower-00/README.md)
  - [Part 2: Azure AD authentication](/ansible-tower-01/README.md)
  - [Part 3: Running a playbook](/ansible-tower-02/README.md)
  - [Part 4: Managing Azure resources](/ansible-tower-03/README.md)
  - [Part 5: Running a workflow](/ansible-tower-04/README.md)
- **SonarQube on Azure**
  - [Part 1: Deploying SonarQube](/sonarqube-00/README.md)
  - [Part 2: Integrating with Azure DevOps](/sonarqube-01/README.md)

## Serverless and event-driven services

- **Azure Functions**
  - [Using a custom Go handler](/func-custom-handler-00/README.md)
  - [Getting a public IP address](/func-get-pip-00/README.md)
  - [Timer-triggered Python function for Azure and Office 365 IP ranges](/func-parse-cloud-00/README.md)
  - [Configuring HTTP/2](/func-http2/README.md)
- [Using Azure Logic Apps to return a public IP address](/logic-apps-00/README.md)
- [Introduction to Azure Event Grid](/event-grid-00/README.md)
- [Sending email with Azure Communication Services](/email-00/README.md)

## Security and operations

- **VM auditing with Nmap and PowerShell**
  - [Part 1: Building a custom image](/docker-audit-00/README.md)
  - [Part 2: Auditing VMs](/docker-audit-01/README.md)
- [Encrypting unmanaged Linux VM data disks](/linux-vm-encryption-101/README.md)

## Cloud comparisons

- **AWS for Azure professionals**
  - [Part 1: AWS and Azure concepts](/aws-intro-00/README.md)
  - [Part 2: AWS networking](/aws-intro-02/README.md)

## Publishing this site

The [Hugo workflow](https://github.com/groovy-sky/azure/blob/master/.github/workflows/pages.yml) builds and deploys this site to GitHub Pages. In **Settings → Pages → Build and deployment → Source**, select **GitHub Actions**, not **Deploy from a branch**. Branch publishing starts the separate `pages-build-deployment` workflow, which can race with the Hugo deployment and fail with “due to in progress deployment.”

After switching the source, cancel or wait for any active Pages deployments to finish, then run **Build and deploy Hugo site** on `master` from the Actions tab. Custom deployments share one concurrency group and wait for an active deployment to finish; pull requests only build the site.

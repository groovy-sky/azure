# AWS for Azure Professionals   

## Introduction

This guide is designed for Azure professionals—such as architects, administrators, and developers—who want to understand the fundamentals of Amazon Web Services (AWS). Whether you're transitioning to AWS or comparing its capabilities with Azure, this guide will help bridge the knowledge gap.

This document gives Azure professionals a concise guide to AWS fundamentals, covering the AWS basics. 

## Overview 

### Organisation structure

Azure uses **Azure Resource Manager (ARM)** to manage resources, with the following hierarchy:    
- **Management Groups**: Governance layer above subscriptions, used for applying policies and role assignments at scale.    
- **Subscriptions**: Billing and access boundaries, often split by environment (dev/test/prod) or business unit.    
- **Resource Groups**: Logical containers for resources that share a lifecycle or management.    
- **Resources**: Individual service instances (e.g., VM, database, VNet).    
  
In AWS, **accounts** serve as a hard boundary similar to Azure **subscriptions**, but governance often starts at the **Organizations** level. Azure emphasizes governance through **management groups**, while AWS achieves similar controls with **Organizations** and account-level policies.  
  
### Identity and Access

Azure combines the following tools for identity and access management:    
- **Microsoft Entra ID (formerly Azure AD)**: Handles users, groups, app registrations, and managed identities.    
- **Azure RBAC**: Defines permissions on resources via roles.    
- **Azure Policy**: Implements guardrails for compliance (deny/audit/modify).    
  
AWS primarily uses **IAM** for identity and permissions (roles and policies) and enforces organization-wide controls with **Service Control Policies (SCPs)**. In Azure, users often rely on the combined tools of **Entra ID, RBAC, and Azure Policy**.  
  
### Networking

Azure networking is based on **Virtual Networks (VNets)**, similar to AWS **VPCs**. Notable Azure features include:    
- **Network Security Groups (NSGs)**: Apply filtering rules to subnets or NICs (comparable to AWS Security Groups and NACLs).    
- **Private Link/Private Endpoints**: Provide private access to PaaS services.    
- **Private DNS Zones**: Often used early in Azure networking designs due to private endpoint requirements.  
  

### Operations and Observability

Azure’s observability stack includes:    
- **Azure Monitor**: Metrics collection and alerting.    
- **Log Analytics**: Centralized logging with KQL-based queries.    
- **Application Insights**: Distributed tracing and application telemetry.    
  
AWS splits similar capabilities across:    
- **CloudWatch**: For metrics, logs, and alarms.    
- **X-Ray**: For distributed tracing and APM.    
     
### Key Similarities:    
- Both platforms offer **regions** and **availability zones** for high availability.    
- Both enforce a **shared responsibility model** for security.    
- Both focus on **least privilege access**, **network segmentation**, and **defense in depth**.    
  
### Key Differences:    
- **Governance Scope**: Azure governance starts at **management groups**, while AWS governance focuses on **Organizations**.    
- **Policy Enforcement**: Azure Policy is widely used for preventive governance, while AWS relies on SCPs for similar purposes.    
- **Private Access Patterns**: Azure uses **Private Endpoints** extensively for PaaS, while AWS commonly uses **VPC Endpoints**.  

### Core Services

Below is a practical “start here” mapping. Treat it as a **learning bridge**, not a perfect equivalence list—some services map to **patterns** (a combination of Azure services) rather than a single product.

| AWS service | Closest Azure service(s) | Explanation in simple terms |
|---|---|---|
| AWS Marketplace | Azure Marketplace | Catalogs to find and deploy third‑party solutions. |
| Amazon CloudWatch (metrics/logs) | Azure Monitor (Metrics + Logs/Log Analytics) | Monitoring, logs, alerting, dashboards. |
| AWS X-Ray | Application Insights | Distributed tracing and application performance monitoring (APM). |
| AWS CLI | Azure CLI | Command-line tools to manage cloud resources. |
| AWS CloudShell | Azure Cloud Shell | Browser-based shell to manage resources without local setup. |
| AWS CloudFormation | ARM templates / Bicep | Infrastructure as code using templates (Bicep is the nicer authoring experience). |
| AWS Organizations | Management groups (and subscriptions) | Organize multiple accounts/subscriptions and apply governance. |
| AWS Trusted Advisor | Azure Advisor | Recommendations for cost, performance, reliability, security. |
| AWS Billing and Cost Management | Microsoft Cost Management | Track spending, budgets, and cost allocation. |
| AWS Management Console | Azure portal | Web UI for managing cloud services and resources. |
| AWS CloudTrail | Azure Activity Log | Audit log of actions/changes in your cloud environment. |
| AWS Config | Azure Policy (and Resource Graph) | Track/evaluate configuration compliance and enforce rules. |
| AWS IAM Identity Center (AWS SSO) | Microsoft Entra ID | Central identity and single sign-on for users/apps. |
| AWS Identity and Access Management (IAM) | Microsoft Entra ID + Azure RBAC | Identity + permissions model (not identical, but similar goal). |
| AWS Directory Service | Microsoft Entra Domain Services | Managed domain services compatible with traditional AD needs. |
| Amazon Cognito | Microsoft Entra External ID | Customer/external user identity for app sign-in. |
| AWS Key Management Service (KMS) | Azure Key Vault | Manage encryption keys, secrets, and certificates. |
| AWS WAF | Azure Web Application Firewall (WAF) | Protect web apps from common web attacks. |
| AWS Network Firewall | Azure Firewall | Managed firewall to control and inspect network traffic. |
| Amazon GuardDuty | Microsoft Defender for Cloud (and/or Microsoft Sentinel) | Threat detection/posture management (often used together). |
| AWS Shield | Azure DDoS Protection | Protection against DDoS attacks. |
| AWS Elastic Beanstalk | Azure App Service | Managed hosting for web apps with scaling and deployment support. |
| Amazon API Gateway | Azure API Management | Publish, secure, transform, and manage APIs. |
| Amazon CloudFront | Azure Front Door / Azure CDN | Global edge delivery/acceleration for content and web apps. |
| AWS Global Accelerator | (Pattern) Azure Front Door or Traffic Manager + regional endpoints | Global traffic steering/acceleration (exact mapping depends on L4/L7 needs). |
| AWS Step Functions | Azure Logic Apps / Durable Functions | Build workflows/orchestrations across services. |
| AWS IoT Core | Azure IoT Hub | Connect/manage IoT devices and their messaging. |
| AWS IoT Greengrass | Azure IoT Edge | Run workloads on devices/edge and manage from the cloud. |
| Amazon Kinesis Data Streams | Azure Event Hubs | High-throughput event streaming/ingestion. |
| AWS Outposts family | Azure Arc | Extend cloud management/services to on‑prem and edge. |
| Amazon WorkSpaces family | Azure Virtual Desktop | Hosted virtual desktops and app delivery for end users. |

More detailed comparison:
- https://learn.microsoft.com/en-us/azure/architecture/aws-professional/



## Amazon EC2: Virtual Servers in the Cloud

**What is EC2?**  
Amazon Elastic Compute Cloud (EC2) provides on-demand, scalable virtual servers (“instances”) in the AWS cloud. Think of EC2 as renting a server in a data center, but with the ability to launch, resize, and terminate quickly.

Azure comparison: **Azure Virtual Machines (VMs)**.

**Key Features:**
- **Instance Types:** Choose from hundreds of configurations (CPU, memory, storage, network) optimized for general purpose, compute, memory, or storage needs.
- **Amazon Machine Images (AMIs):** Prebuilt templates with operating systems and software.
- **Elastic Block Store (EBS):** Persistent disk storage attached to instances.
- **Security Groups:** Virtual firewalls controlling inbound/outbound traffic.
- **Auto Scaling:** Automatically add/remove instances based on demand.
- **Elastic Load Balancing:** Distribute traffic across multiple instances for reliability.



## Amazon S3: Object Storage and Buckets

**What is S3?**  
Amazon Simple Storage Service (S3) is a highly durable, scalable object storage service. Data is stored as “objects” (files) inside “buckets” (containers). S3 is ideal for storing backups, static assets, logs, and data lakes.

Azure comparison: **Azure Blob Storage** (containers/blobs).

**Key Features:**
- **Unlimited Storage:** Store petabytes of data.
- **High Durability:** 99.999999999% (11 nines) durability, data replicated across multiple AZs.
- **Storage Classes:** Optimize cost/performance (Standard, Intelligent-Tiering, Glacier, Deep Archive).
- **Versioning:** Keep multiple versions of objects.
- **Lifecycle Policies:** Automatically move or delete objects based on rules.
- **Access Control:** Fine-grained permissions via IAM, bucket policies, and ACLs.

**Security Best Practices:**
- Block public access unless explicitly required.
- Use IAM roles for applications accessing S3.
- Enable encryption at rest (SSE-S3, SSE-KMS) and in transit (HTTPS).
- Enable logging and monitoring (CloudTrail, S3 Access Logs).
- Regularly audit bucket policies and permissions.



## Amazon VPC: Networking Basics

**What is VPC?**  
Amazon Virtual Private Cloud (VPC) lets you create isolated, customizable networks in AWS. You control IP address ranges, subnets, routing, gateways, and security settings—much like configuring a traditional network, but in software.

Azure comparison: **Azure Virtual Network (VNet)**.

**Key Concepts:**
- **Subnets:** Segments of your VPC’s IP range, placed in specific AZs. Public subnets have internet access; private subnets do not.
- **Route Tables:** Define how traffic is routed within the VPC and to external networks.
- **Internet Gateway (IGW):** Enables internet access for public subnets.
- **NAT Gateway:** Allows private subnets to access the internet for updates, without exposing them directly.
- **Security Groups:** Stateful firewalls for instances.
- **Network ACLs:** Stateless firewalls for subnets.

**Common Use Cases:**
- Isolate web servers (public subnet) from databases (private subnet).
- Control inbound/outbound traffic for compliance.
- Connect multiple VPCs via peering or Transit Gateway.
- Extend on-premises networks to AWS via VPN or Direct Connect.

**Advanced Networking:**
- **VPC Peering:** Direct connection between two VPCs for resource sharing.
- **Transit Gateway:** Central hub for connecting multiple VPCs and on-premises networks, scalable and easier to manage than peering.
- **Endpoints:** Private connectivity to AWS services (e.g., S3) without traversing the internet.

**Best Practices:**
- Use multiple AZs for high availability.
- Restrict access with security groups and NACLs.
- Regularly audit route tables and firewall rules.
- Use VPC Flow Logs for monitoring traffic.

## Amazon RDS: Managed Relational Database Service

**What is RDS?**  
Amazon Relational Database Service (RDS) provides managed databases (MySQL, PostgreSQL, SQL Server, Oracle, MariaDB, Aurora) with automated backups, patching, scaling, and high availability.

Azure comparison:
- Managed open-source engines: **Azure Database for PostgreSQL / MySQL**
- SQL Server PaaS: **Azure SQL Database / SQL Managed Instance**
- Some Aurora-like patterns map to a combination of Azure services depending on requirements.

**Key Features:**
- **Automated Backups:** Point-in-time recovery.
- **Multi-AZ Deployments:** Synchronous replication for high availability.
- **Read Replicas:** Scale reads and improve performance.
- **Monitoring:** CloudWatch metrics, enhanced monitoring, Performance Insights.
- **Security:** Encryption at rest and in transit, VPC isolation, IAM integration.

**Common Use Cases:**
- Web applications needing a reliable SQL database.
- Analytics platforms.
- SaaS products with multi-tenant databases.

**Best Practices:**
- Deploy in private subnets for security.
- Use least privilege access and rotate credentials.
- Enable encryption and regular backups.
- Monitor performance and set alerts.

**Aurora:** AWS’s proprietary database engine, compatible with MySQL and PostgreSQL, offers higher performance and availability, serverless options, and cross-region replication.



## Amazon CloudWatch: Monitoring and Observability

**What is CloudWatch?**  
Amazon CloudWatch is AWS’s monitoring and observability service. It collects metrics, logs, and events from AWS resources and applications, enabling you to visualize performance, set alarms, and automate actions.

Azure comparison: **Azure Monitor** (metrics + logs + alerts) and **Application Insights** (APM/tracing).

**Key Features:**
- **Metrics:** Track CPU, memory, disk, network, and custom metrics.
- **Logs:** Aggregate logs from EC2, Lambda, RDS, and applications.
- **Alarms:** Trigger notifications or actions when thresholds are breached.
- **Dashboards:** Visualize metrics and alarms in customizable views.
- **Events:** Automate workflows (e.g., restart instances, invoke Lambda).

**Common Use Cases:**
- Monitor server health and resource usage.
- Alert on high CPU or low disk space.
- Aggregate logs for troubleshooting.
- Automate scaling or recovery actions.

**Best Practices:**
- Enable detailed monitoring for critical resources.
- Use log filters to create custom metrics.
- Integrate with third-party tools (Grafana, Datadog).
- Regularly review dashboards and alarm thresholds.

**Cost Management:** CloudWatch can monitor billing and usage, helping you avoid unexpected charges.



## AWS Lambda: Serverless Compute

**What is Lambda?**  
AWS Lambda is a serverless compute service that runs code in response to events, without provisioning or managing servers.

Azure comparison: **Azure Functions**.

**Key Features:**
- **Event-Driven:** Triggered by AWS services (S3, DynamoDB, API Gateway) or scheduled events.
- **Automatic Scaling:** Handles thousands of concurrent executions.
- **Multiple Languages:** Supports Python, Node.js, Java, C#, Go, Ruby, and more.
- **Pay-per-Use:** Billed for execution time and number of requests.

**Common Use Cases:**
- Data processing (e.g., resize images on S3 upload).
- Backend APIs (with API Gateway).
- Automation and scheduled tasks.
- Real-time file or stream processing.

**Best Practices:**
- Keep functions stateless; use S3 or DynamoDB for persistent data.
- Assign least privilege IAM roles.
- Monitor performance and errors with CloudWatch.
- Optimize memory and timeout settings for cost and speed.

**Limitations:** Max execution time is 15 minutes; not suitable for long-running tasks. Cold starts can add latency for infrequently used functions.



## Security Basics Across AWS Services

Security is a shared responsibility between AWS and the customer. AWS secures the infrastructure (data centers, hardware, networking), while you are responsible for configuring services securely (identity, network rules, encryption, monitoring, etc.).

Azure comparison: same shared-responsibility concept; Azure customers typically combine **Entra ID**, **RBAC**, **Policy**, and **Defender for Cloud** to enforce and monitor security.

**Key Security Practices:**
- **IAM:** Use roles and policies for least privilege.
- **MFA:** Enable multi-factor authentication for root and privileged users.
- **Encryption:** Encrypt data at rest (S3, EBS, RDS) and in transit (HTTPS).
- **Network Isolation:** Use VPCs, subnets, security groups, and NACLs.
- **Monitoring:** Enable CloudTrail, CloudWatch, and GuardDuty for auditing and threat detection.
- **Regular Audits:** Review access, policies, and logs.
- **Backup and Disaster Recovery:** Use S3 versioning, cross-region replication, and automated backups.

**S3 Security Example:**
- Block public access unless needed.
- Use bucket policies and IAM roles.
- Enable server-side encryption (SSE-S3, SSE-KMS).
- Monitor access logs and CloudTrail events.
- Implement lifecycle policies and versioning for data protection.



## Getting Started: Hands-On Labs and Tutorials

AWS offers a wealth of hands-on labs, tutorials, and learning paths:
- **AWS Skill Builder:** Free labs for EC2, S3, IAM, Lambda, VPC, and more.

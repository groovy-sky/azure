# AWS for Azure Professionals (part 1)

## Introduction

![](/images/aws/aws_vs_az_00.jpg)

This document provides an exhaustive, technical comparison of AWS and Azure across organization structure, identity and access management, networking, operations and observability, and shared principles. It highlights direct mappings and nuanced differences in governance, policy enforcement, private access patterns, and operational tooling. This foundational overview is aimed at Azure professionals seeking to understand AWS equivalents and operational models. 

## Organization Structure

### Azure

Azure organizes resources using a hierarchical model built on **Management Groups**, **Subscriptions**, **Resource Groups**, and **Resources**. At the top, Management Groups allow organizations to apply governance and policies across multiple subscriptions. Subscriptions serve as logical containers for billing and resource management, while Resource Groups group related resources for lifecycle and access control. Resources are the actual services—VMs, databases, storage accounts—deployed within resource groups.

### AWS

AWS employs a different but conceptually similar hierarchy. **AWS Organizations** is the central service for managing multiple AWS accounts. Within an Organization, **Accounts** act as isolated billing and security boundaries. **Organizational Units (OUs)** group accounts for policy application, and **Tagging** is used for logical grouping and cost allocation. Unlike Azure, AWS does not have a direct equivalent to Resource Groups; instead, resource grouping is achieved via tags and sometimes by using AWS Resource Groups for specific use cases.

#### Comparative Table: Organizational Hierarchy

![](/images/aws/aws_vs_az_01.jpg)

| Azure Component        | AWS Equivalent         | Description                                                      |
|-----------------------|------------------------|------------------------------------------------------------------|
| Management Group      | Organizational Unit    | High-level grouping for governance and policy inheritance        |
| Subscription          | AWS Account            | Logical boundary for billing, quotas, and resource isolation     |
| Resource Group        | Tag-based Grouping     | Logical grouping for resource management and lifecycle           |
| Resource              | Resource               | Individual cloud service (VM, DB, etc.)                         |

Azure’s hierarchy is tightly integrated with Microsoft Entra ID for identity and access management, while AWS’s model is more decentralized, with each account serving as a boundary for billing, security, and resource quotas.

### Governance, Billing, and Policy Enforcement

**Governance:**  
Azure allows policy and role assignments at any level—management group, subscription, resource group, or resource—enabling fine-grained control and inheritance. AWS uses **Service Control Policies (SCPs)** at the organization or OU level to enforce governance, with IAM policies applied at the account or resource level.

**Billing:**  
Azure integrates billing at the subscription level, with consolidated cost management tools. AWS consolidates billing across accounts in an organization, supporting centralized payment and cost allocation via tags and cost allocation reports.

**Policy Enforcement:**  
Azure Policy can proactively block non-compliant deployments and remediate resources, with effects such as Deny, Audit, DeployIfNotExists, and Modify. AWS SCPs set permission guardrails but do not grant permissions; actual access is determined by the intersection of SCPs and IAM policies.

**Key Differences:**  
- Azure’s resource groups provide a native unit for lifecycle and access management, whereas AWS relies on tags and resource-based policies.
- AWS’s account-centric model offers stronger isolation but requires more manual cross-account management.
- Azure’s management group hierarchy supports up to 10,000 groups and six levels of depth, enabling complex organizational mapping.

## Identity and Access

### Core IAM Capabilities

Both platforms provide robust identity and access management, but their architectures and operational models differ.

#### Azure Identity Model

- **Microsoft Entra ID (formerly Azure AD):** Centralized directory for users, groups, applications, and service principals. Supports SSO, MFA, conditional access, and hybrid integration with on-premises AD.
- **Azure RBAC:** Role-based access control applied at management group, subscription, resource group, or resource level.
- **Azure Policy:** Enforces organizational standards, compliance, and can trigger remediation for non-compliant resources.
- **Privileged Identity Management (PIM):** Just-in-Time (JIT) access, approval workflows, and audit logs for privileged roles.

#### AWS Identity Model

- **AWS IAM:** Manages users, groups, roles, and policies. Policies are JSON documents granting granular permissions.
- **IAM Roles/Policies:** Used for fine-grained access, temporary credentials, and cross-account access.
- **Service Control Policies (SCPs):** Organization-level guardrails for maximum permissions.
- **IAM Identity Center (formerly AWS SSO):** Centralized identity management, supports SSO and federation.
- **Temporary Credentials:** Used extensively for workload and cross-account access, reducing risk of credential leakage.

#### Comparative Table: Identity and Access Management

![](/images/aws/aws_vs_az_02.jpg)


| Capability                | Azure                                 | AWS                                  |
|---------------------------|---------------------------------------|--------------------------------------|
| Directory Service         | Microsoft Entra ID                    | IAM, IAM Identity Center             |
| RBAC                      | Azure RBAC                            | IAM Roles/Policies                   |
| Policy Enforcement        | Azure Policy                          | SCPs, IAM Policies                   |
| SSO/Federation            | SAML, OAuth, OIDC, B2B                | SAML, OIDC, IAM Roles                |
| Managed Identities        | System/User-assigned Managed Identity | IAM Roles for EC2, Lambda            |
| Privileged Access         | PIM                                   | Temporary Credentials, SCPs          |
| Audit Logging             | Entra ID logs, Azure Monitor          | CloudTrail, IAM Access Analyzer      |

Azure’s model is more centralized, with directory-based identity and access, while AWS’s model is decentralized, relying on account boundaries and policy-based controls.

### Identity Federation, SSO, and Managed Identities

**Federation and SSO:**  
Azure supports hybrid identity via Entra ID Connect, enabling seamless integration with on-premises AD. SSO is available for thousands of SaaS apps, and B2B collaboration is supported via external identities. AWS supports SAML/OIDC federation, allowing external users to assume roles via trust policies. AWS IAM Identity Center provides SSO for AWS accounts and applications.

**Managed Identities:**  
Azure Managed Identities (system-assigned and user-assigned) provide credential-free access for applications to Azure resources. AWS uses IAM roles for EC2, Lambda, and other services, granting temporary credentials for secure access.

**Privileged Access Management:**  
Azure PIM offers JIT access, approval workflows, and audit logs natively. AWS achieves similar outcomes via temporary credentials, SCPs, and custom automation, but lacks a direct equivalent to PIM.

**Cross-Account and Cross-Tenant Access:**  
Azure supports cross-tenant access via Entra ID B2B and RBAC assignments. AWS uses IAM roles with trust policies for cross-account access, enabling secure delegation of permissions.

## Networking: Azure VNet vs AWS VPC

### Core Networking Constructs

Both Azure and AWS provide isolated, private networking environments, but their architectures and operational models differ.

#### Comparative Table: Networking Features

![](/images/aws/aws_vs_az_03.jpg)


| Feature                  | Azure VNet                          | AWS VPC                             |
|--------------------------|-------------------------------------|-------------------------------------|
| Virtual Network          | VNet                                | VPC                                 |
| Subnet                   | Subnet                              | Subnet (tied to AZ)                 |
| Network Security         | NSG (Network Security Group), ASG   | Security Groups, NACLs              |
| Private Access to PaaS   | Private Endpoints                   | VPC Endpoints (Interface/Gateway)   |
| DNS Integration          | Azure DNS, Private DNS Zones        | Route 53, Private Hosted Zones      |
| Peering                  | VNet Peering, Virtual WAN           | VPC Peering, Transit Gateway        |
| NAT Gateway              | Azure NAT Gateway                   | AWS NAT Gateway                     |
| Load Balancing           | Load Balancer, App Gateway, Front Door | NLB, ALB, Global Accelerator    |
| Monitoring               | Network Watcher                     | VPC Flow Logs, Reachability Analyzer|

Azure subnets can span multiple availability zones, simplifying redundancy, while AWS subnets are tied to a specific AZ, requiring explicit distribution for high availability.

### Network Security

**Azure NSGs:**  
Stateful, applied at subnet or NIC level. Support inbound and outbound rules, protocols, port ranges, and source/destination IPs or ASGs. NSGs can be associated with multiple resources, and rules are combined with the most restrictive taking precedence. ASGs provide logical grouping for dynamic environments.

**AWS Security Groups:**  
Stateful, attached to instances or ENIs. Support inbound and outbound rules, protocols, port ranges, and source/destination IPs or security groups. NACLs are stateless, applied at subnet level, and require explicit rules for both directions. AWS lacks a direct equivalent to ASGs but achieves similar grouping via tags and security groups.

**Key Differences:**  
- Azure NSGs can be applied at both subnet and NIC levels; AWS Security Groups are instance/ENI-level.
- Azure ASGs simplify rule management for dynamic workloads; AWS relies on tags and manual updates.
- AWS NACLs provide an additional stateless layer; Azure does not have a direct equivalent, relying solely on NSGs.

### Private Access to PaaS

**Azure Private Endpoints:**  
Provide private IP addresses for PaaS services within a VNet, leveraging Azure Private Link. Integrated with Private DNS Zones for seamless name resolution. Simplifies configuration and supports broad service integration.

**AWS VPC Endpoints:**  
Two types:  
- **Gateway Endpoints:** For S3 and DynamoDB, route table-based.  
- **Interface Endpoints:** Powered by AWS PrivateLink, deploy ENIs in subnets for private connectivity to AWS services or third-party/SaaS providers. Requires manual configuration for each service, with DNS overrides for private routing.

**Key Differences:**  
- Azure’s Private Link offers a unified approach for private connectivity, while AWS requires different setups for gateway and interface endpoints.
- Azure’s model is more tightly integrated with identity and policy enforcement; AWS provides granular control but requires more configuration.

### DNS Integration

**Azure DNS:**  
Provides public and private DNS zones. Private DNS Zones enable internal name resolution within VNets, supporting auto-registration and zone linking across multiple VNets. Integrated with Azure RBAC for access control.

**AWS Route 53:**  
Supports public and private hosted zones. Private hosted zones are associated with VPCs for internal name resolution. Route 53 Resolver enables hybrid DNS scenarios, including split-view DNS and forwarding to on-premises DNS servers. IAM policies control access to DNS management.

**Key Differences:**  
- Azure Private DNS Zones support auto-registration and VNet linking; AWS requires explicit association of hosted zones with VPCs.
- Azure integrates DNS management with RBAC; AWS uses IAM policies.

## Operations and Observability

### Monitoring and Logging Tools

Both platforms offer comprehensive monitoring, logging, and distributed tracing, but differ in implementation and integration.

#### Comparative Table: Operations and Observability

![](/images/aws/aws_vs_az_04.jpg)


| Capability             | Azure                                 | AWS                                  |
|------------------------|----------------------------------------|---------------------------------------|
| Metrics & Logs         | Azure Monitor, Log Analytics           | CloudWatch Metrics, CloudWatch Logs   |
| Distributed Tracing    | Application Insights                   | AWS X-Ray                             |
| Audit Logging          | Azure Activity Logs, Monitor           | AWS CloudTrail                        |
| Alerting               | Azure Monitor Alerts, Action Groups    | CloudWatch Alarms                     |
| Network Monitoring     | Network Watcher                        | VPC Flow Logs, Reachability Analyzer  |

**Azure Monitor:**  
Unified platform for metrics, logs, and distributed traces. Log Analytics supports advanced queries via Kusto Query Language (KQL). Application Insights provides deep APM and distributed tracing. Action Groups enable flexible alerting and automated responses, supporting multiple notification types and integration with automation tools.

**AWS CloudWatch:**  
Native integration with AWS services, supporting metrics, logs, dashboards, and alarms. CloudWatch Logs offer indefinite retention and flexible querying. CloudWatch Alarms trigger notifications and automated actions. CloudTrail records API activity for audit and compliance. AWS X-Ray provides distributed tracing, service maps, and anomaly detection, with strong integration into AWS SDKs and Lambda.

**Key Differences:**  
- Azure Monitor offers unified observability across metrics, logs, and traces, with built-in ML anomaly detection and cross-workspace queries.
- AWS CloudWatch supports higher metric dimension limits and 1-second custom metrics, with flexible retention and integration with S3 for archival.
- Azure’s Action Groups provide reusable notification and automation configurations; AWS relies on CloudWatch Alarms and EventBridge.

### Logging and Audit

**Azure Log Analytics:**  
Retains data for 30–730 days (extendable to 12 years), supports advanced analytics, and integrates with Sentinel for SIEM. Logs can be queried, visualized, and used for alerting. Data retention and cost management are configurable at workspace and table levels.

**AWS CloudTrail:**  
Records API activity for 90 days by default, extendable via CloudTrail Lake or S3. Supports advanced querying and integration with Security Hub for compliance and threat detection. CloudTrail Lake enables ingestion and analysis of logs from Azure and other clouds for multicloud visibility.

### Metrics, Alerts, and Alerting Models

**Azure Monitor Alerts:**  
Support metric, log search, activity log, and smart detection alerts. Alerts can be stateful or stateless, with customizable conditions and thresholds. Action Groups enable concurrent execution of notifications and automated actions, with rate limiting and retry logic for reliability.

**AWS CloudWatch Alarms:**  
Trigger on metrics and logs, supporting composite alarms and integration with SNS, Lambda, and EventBridge. Alarms can be configured for thresholds, anomaly detection, and multi-resource monitoring. Alerting is tightly integrated with AWS services for automated remediation.

### Application Tracing

**Azure Application Insights:**  
Provides end-to-end distributed tracing, performance metrics, anomaly detection, and live metrics for applications. Supports multiple languages and frameworks, with integration into Azure Monitor and Log Analytics. Alerting and notifications are managed via Azure Monitor.

**AWS X-Ray:**  
Offers distributed tracing, service maps, and advanced analytics for microservices and serverless architectures. Integrates with AWS SDKs, Lambda, ECS, and EKS. Supports custom annotations and metadata for deep troubleshooting. Sampling rules control trace volume for cost and performance optimization.

**Key Differences:**  
- Azure Application Insights is deeply integrated with Azure services and provides unified APM and observability.
- AWS X-Ray excels in tracing distributed applications across AWS services, with strong open-source integration.

## Shared Principles: Regions, Availability Zones, Shared Responsibility, and Security

### Regions and Availability Zones

Both AWS and Azure operate global infrastructures with regions and availability zones (AZs) for high availability, fault tolerance, and compliance.

![](/images/aws/aws_vs_az_05.jpg)

**Azure:**  
Over 60 regions, each with multiple AZs. Subnets can span AZs, simplifying redundancy. Managed services often provide built-in zone redundancy. Paired regions support geo-redundant storage and disaster recovery.

**AWS:**  
33 regions, 105+ AZs. Subnets are tied to specific AZs, requiring explicit distribution for redundancy. AWS offers multi-AZ deployments for services like RDS, S3, and EC2. Regions are isolated for compliance and fault tolerance.

**Key Differences:**  
- Azure abstracts zone management for many services, reducing operational overhead.
- AWS requires manual configuration for multi-AZ redundancy, offering greater control.

### Shared Responsibility Model

Both platforms enforce a **shared responsibility model**:

- **Provider:** Secures infrastructure, physical data centers, and foundational services.
- **Customer:** Secures data, applications, configurations, and access controls.

Misunderstanding this boundary is a leading cause of cloud security incidents. Both AWS and Azure provide extensive documentation and tooling to clarify responsibilities.

### Security and Compliance

**Azure:**  
Integrated with Microsoft Defender for Cloud, Sentinel SIEM, and Security Center. Supports 90+ certifications (GDPR, ISO, FedRAMP). Azure Policy enforces compliance, and Secure Score provides continuous assessment. Sentinel offers AI-driven threat detection and automated response.

**AWS:**  
Security Hub aggregates findings from GuardDuty, Inspector, Macie, and IAM Access Analyzer. Compliant with 143+ certifications (FedRAMP, PCI-DSS, HIPAA). SCPs and IAM policies enforce least privilege. Security Hub provides centralized compliance and threat management.

**Key Differences:**  
- Azure’s security tooling is tightly integrated with Microsoft’s ecosystem, offering advanced AI and automation in Sentinel.
- AWS Security Hub excels in aggregating findings across AWS services but has limited multi-cloud support.

## Governance Scope, Policy Enforcement, and Private Access Patterns

### Governance Scope and Policy Enforcement

**Azure:**  
Policies can be assigned at management group, subscription, resource group, or resource level. Azure Policy supports proactive remediation, audit, and deny effects. Policy inheritance simplifies governance across large environments. PIM provides structured privileged access management.

**AWS:**  
SCPs are attached at organization, OU, or account level, setting maximum available permissions. IAM policies grant actual access. Policy evaluation is the intersection of SCPs and IAM policies. AWS relies on decentralized, multi-account governance, requiring careful management of cross-account roles and permissions.

**Key Differences:**  
- Azure’s centralized policy model enables easier enforcement and remediation.
- AWS’s decentralized model offers stronger isolation but requires more manual management.

### Private Access Patterns and Key Differences

**Azure:**  
Emphasizes Private Endpoints for PaaS services, integrated with VNets and Private DNS Zones. Policy enforcement is tightly coupled with identity and access controls.

**AWS:**  
Uses VPC Endpoints (Interface and Gateway) for private access to services like S3, DynamoDB, and custom applications. Provides granular control but requires more configuration.

**Key Differences:**  
- Azure’s model is more tightly integrated with identity and policy enforcement.
- AWS provides more granular control but at the cost of increased complexity.

## Identity and Privileged Access Management

**Azure PIM:**  
Native support for JIT access, approval workflows, and audit logs. Centralized governance with structured workflows and conditional access policies.

**AWS:**  
No direct equivalent; similar functionality achieved via temporary credentials, SCPs, and custom automation. Relies on session-based permissions and decentralized management.

**Key Differences:**  
- Azure offers a dedicated PIM solution for controlling high-risk access.
- AWS manages privileges through IAM roles and temporary credentials, prioritizing flexibility.

## Cross-Account and Cross-Tenant Access Models

**Azure:**  
Supports B2B collaboration and cross-tenant access via Entra ID and RBAC assignments. Azure Lighthouse enables cross-tenant management for service providers.

**AWS:**  
Uses IAM roles with trust policies for cross-account access. Resource-based policies and AssumeRole API enable secure delegation of permissions.


## Multi-Account / Multi-Subscription Landing Zone Patterns

**Azure:**  
Management Groups and Subscriptions with Azure Blueprints and Policies. Landing zones are structured for compliance, security, and operational efficiency.

**AWS:**  
Organizations, OUs, SCPs, and Control Tower for landing zone setup. Emphasizes multi-account isolation and automated account provisioning.

## Cost Allocation and Tagging Strategies

**Azure:**  
Tags at resource level; cost analysis via Cost Management + Billing. Cost allocation rules enable redistribution of shared service costs across subscriptions, resource groups, or tags. Supports fixed percentage, usage-based, and hybrid allocation models.

**AWS:**  
Tags at resource level; consolidated billing and cost allocation reports. Tag policies standardize tagging across accounts. Cost Explorer and Budgets provide detailed analysis and optimization tools.


## Operational Tooling: Automation and Infrastructure as Code (IaC)

![](/images/aws/aws_vs_az_07.jpg)


**Azure:**  
ARM templates, Bicep, Terraform, and Azure DevOps Pipelines. Bicep offers a modern, declarative syntax for Azure resources. Azure Policy integrates with IaC for compliance enforcement.

**AWS:**  
CloudFormation, CDK, Terraform, and CodePipeline. CloudFormation provides declarative templates; CDK enables infrastructure definition in familiar programming languages.

**Key Differences:**  
- Azure’s Bicep and ARM templates are Azure-specific; Terraform supports multi-cloud.
- AWS CDK offers programmatic infrastructure definition; Azure relies on declarative models.


## Security Monitoring and Threat Detection

**Azure:**  
Microsoft Defender for Cloud, Sentinel SIEM, Secure Score, and Compliance Dashboard. Vulnerability scanning, data security, and advanced threat detection are integrated across services.

**AWS:**  
GuardDuty, Inspector, Macie, Security Hub, and Config. Aggregates findings, supports compliance monitoring, and integrates with partner solutions.

**Key Differences:**  
- Azure’s Sentinel provides advanced AI-driven threat detection and automation.
- AWS Security Hub excels in aggregating findings but has limited multi-cloud support.


## Migration Considerations for Azure-Native Teams Moving to AWS

- Expect more manual configuration in AWS compared to Azure’s guided security implementations.
- Identity integration may require re-architecting; AWS IAM differs significantly from Entra ID.
- Azure-native teams may need to adopt third-party tools for features like PIM and unified policy enforcement.
- Use AWS Migration Hub, Application Migration Service, and Database Migration Service for planning and execution.
- Train teams on AWS fundamentals, IAM, VPCs, and security groups.


## Appendices: Service Mapping Tables

| Azure Component             | AWS Equivalent                      |
|-----------------------------|--------------------------------------|
| Management Group            | Organizational Unit (OU)            |
| Subscription                | AWS Account                         |
| Resource Group              | Tag-based Grouping                  |
| Azure Policy                | AWS SCP / IAM Policies              |
| Azure RBAC                  | AWS IAM Roles and Policies          |
| Microsoft Entra ID          | AWS IAM / IAM Identity Center       |
| Azure VNet                  | AWS VPC                             |
| NSG                         | Security Group / NACL               |
| Private Endpoint            | VPC Endpoint (Interface)            |
| Azure DNS Private Zone      | Route 53 Private Hosted Zone        |
| Azure Monitor               | CloudWatch                          |
| Log Analytics               | CloudWatch Logs                     |
| Application Insights        | AWS X-Ray                           |
| Azure Activity Log          | AWS CloudTrail                      |
| Microsoft Defender for Cloud| AWS Security Hub                    |

## Summary  
For Azure professionals, understanding AWS equivalents is essential for effective multicloud strategy, migration, and governance. While both platforms share foundational principles—regions, availability zones (AZs), shared responsibility, least privilege, and network segmentation—their operational models, policy enforcement, and tooling differ significantly.  
  
Azure’s centralized, directory-based governance simplifies policy enforcement, remediation, and identity management, whereas AWS emphasizes a decentralized, account-centric model offering stronger isolation and granular flexibility. Both platforms provide robust networking, observability, and security tools, but adapting to AWS from Azure requires careful mapping of concepts such as identity federation, privileged access management, private access patterns, and operational tooling.  
  
Key takeaways from this document:  
- Azure and AWS share core principles but differ in hierarchy, governance, and operational tooling.  
- Azure’s centralized model simplifies policy enforcement and remediation; AWS offers stronger isolation and flexibility.  
- Identity, networking, observability, and security require careful mapping and adaptation for cross-cloud success.  
- Migration from Azure to AWS involves re-architecting identity, access, and operational models, with a focus on automation and cost optimization.  
  
This part provides a comprehensive overview of the main features, operational models, and mappings between Azure and AWS. The next chapter will focus on practical implementation and hands-on AWS guidance.
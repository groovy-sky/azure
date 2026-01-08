# AWS for Azure Professionals (part 1)

## Introduction

![](/images/aws/aws_vs_az_00.jpg)

This document provides an exhaustive, technical comparison of AWS and Azure across organization structure, identity and access management, networking, operations and observability, and shared principles. It highlights direct mappings and nuanced differences in governance, policy enforcement, private access patterns, and operational tooling. This foundational overview is aimed at Azure professionals seeking to understand AWS equivalents and operational models. 

##  Organizational Hierarchy

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Account hierarchy | Organization root → (optional) **management account** → OUs → accounts | Tenant (Microsoft Entra) → management groups → subscriptions → resource groups → resources | Both clouds use a tree-like hierarchy; AWS often uses a **dedicated management account**, while Azure centers administration at the tenant. |
| Top-level admin boundary | AWS management account (administers AWS Organization) | Microsoft Entra tenant (directory boundary for identities; subscriptions live under it) | Similar “top level” control point; AWS uses an account, Azure uses an identity tenant/directory. |
| Primary workload container | AWS account | Azure subscription | Closest equivalents for isolation, access scoping, and quotas. |
| Cross-boundary access | Cross-account access via IAM roles + resource-based policies | Cross-subscription access via tenant identity + Azure RBAC (often organized with management groups) | Both support access across boundaries; mechanisms differ (IAM role assumption vs tenant/RBAC). |
| Grouping unit above accounts/subscriptions | Organizational Units (OUs) group accounts | Management groups group subscriptions | Same purpose (organize and govern at scale), but the grouped object differs (accounts vs subscriptions). |
| Governance guardrails | Service Control Policies (SCPs) constrain maximum effective permissions in accounts/OUs | Azure Policy enforces/audits resource rules and compliance | Both provide centralized governance; AWS SCPs are permission guardrails, Azure Policy is primarily resource compliance/configuration (permissions handled via Entra/RBAC). |
| Ownership/admin roles (classic) | IAM users/roles and account-level administration patterns | Classic subscription admins: Account Administrator / Service Administrator / Co-administrator (plus Azure RBAC in practice) | Both support delegated admin; Azure has classic subscription admin roles in addition to RBAC. |
| Quotas/limits | Service quotas per account | Quotas/limits per subscription | Both have default quotas/limits; you manage increases per workload container. |


## Identity Management

### Core services

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Core identity services | IAM Identity Center; AWS Organizations; AWS Directory Service | Microsoft Entra ID; Azure management groups; Microsoft Entra Domain Services | Both provide core identity foundations (identity, hierarchy, directory). AWS is typically composed from separate services; Azure is centered around Entra. |

### Authentication and access control

| Area | AWS | Azure | Notes |
|---|---|---|---|
| MFA | AWS MFA | Microsoft Entra MFA | Direct equivalents for strengthening sign-in security. |
| Access analysis / reviews | AWS IAM Access Analyzer | Microsoft Entra access reviews | Both help govern access; AWS analyzes access to resources, Azure focuses on review workflows for identity governance. |
| External identities | AWS IAM Identity Center | Microsoft Entra External ID | Both support external users; Azure provides a dedicated external identity capability. |
| Resource sharing / authorization | AWS Resource Access Manager (RAM) | Microsoft Entra role-based access control (RBAC) | Both enable controlled access across scopes; AWS uses resource sharing, Azure uses RBAC role assignments. |

### Identity governance

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Identity governance | Combination of IAM + Access Analyzer + Organizations + IAM Identity Center + CloudTrail + Config | Microsoft Entra ID Governance | Key difference: AWS governance is typically assembled from multiple services; Azure provides an integrated governance suite in Entra. |

### Privileged access management

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Privileged access management | Temporary elevated access via IAM Identity Center + IAM/automation/partner tools (noted as open-source approach) | Microsoft Entra Privileged Identity Management (PIM) with just-in-time access | Both support least privilege and time-bound elevation; Azure provides first-party integrated JIT/PIM capabilities. |
| Privileged access auditing | AWS CloudTrail | Microsoft Entra privileged access audit | Both provide auditability; telemetry is surfaced through different native services. |

### Hybrid identity

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Hybrid identity (directory integration) | AWS Directory Service AD Connector | Microsoft Entra Connect | Both integrate on-premises directories with cloud identity. |
| Hybrid identity (federation) | AWS IAM SAML provider | Active Directory Federation Services (AD FS) | Both support federation-based sign-in (SAML). |
| Hybrid identity (managed AD / sync option) | AWS Managed Microsoft AD | Microsoft Entra password hash synchronization | Both support hybrid needs, but the primary “managed AD” offering vs “sync method” aren’t 1:1 equivalents—they solve adjacent hybrid scenarios. |

## Resource management

### Resource concept

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Resource (definition) | Resource = manageable item (VM, database, storage, etc.) | Resource = manageable item (VM, database, storage, etc.) | The term **resource** is used the same way in both clouds. |

### Resource groups

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Delete behavior | Deleting a resource group **does not delete** the resources | Deleting a resource group **deletes all** resources in it | Major operational difference: Azure RG deletion is destructive to contained resources. |
| Relationship to resources | Resource groups are for organizing; resources aren’t required to “live inside” a group in the same strict way | You must create a resource group **before** creating resources; each resource belongs to **one** resource group | Azure RG is a mandatory container for resources. |
| Cost tracking | Use **cost allocation tags** to filter and report | Can track costs **by resource group** | Both can do cost tracking; Azure has RG-native grouping, AWS relies heavily on tagging. |

### Resource deployment

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Web UI | AWS dashboards/console | Azure portal | Similar role: web-based management interface. |
| APIs | AWS APIs | Azure Resource Manager REST API | Both support programmatic management; Azure highlights ARM as the unified control plane. |
| CLI | AWS CLI | Azure CLI | Both provide command-line management tools. |
| Scripting | (varies, incl. SDKs/automation) | Azure PowerShell | Azure explicitly positions PowerShell modules for automation. |
| IaC templates / DSL | (varies, e.g., CloudFormation) | ARM templates (JSON) and Bicep | Azure offers ARM templates and Bicep; file also notes the RG is central to deployments. |
| Terraform | Terraform | Terraform | Both support Terraform for IaC. |
| Deployment grouping concept | Stacks (conceptually similar) | Resource group is central to create/deploy/modify resources | Note in file: Azure RG plays a central role, similar in spirit to “stack” implementations. |

### Resource tagging

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Tag basics | Key-value metadata on resources | Key-value metadata on resources | Tagging is a shared concept for organizing, tracking, and governance. |
| Case sensitivity | **Case-sensitive** tags | Operations are **case-insensitive** (casing can be preserved) | Important for automation consistency and matching. |
| Tag inheritance | No native inheritance between parent/child resources (AWS Cost Categories support inheritance) | Supports tag inheritance via policy | Azure has stronger built-in inheritance via governance. |
| Tagging tools | Tag Editor tool | Tagging via Azure portal and management interfaces | Both provide tooling; AWS has a dedicated tag editor, Azure uses portal/CLI/PowerShell/APIs. |

## Networking

| Area | AWS | Azure | Notes |
| -----| ----------- | ------------- | ----------- |
| Cloud virtual networking | [Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc) | [Virtual Network](https://azure.microsoft.com/services/virtual-network) | These services provide an isolated private environment in the cloud. You have control over your virtual networking environment, including the selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways. In AWS, each subnet must reside in one availability zone. In Azure, subnets can span multiple availability zones. |
| NAT gateways | [AWS NAT gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) | [Azure NAT Gateway](/azure/virtual-network/nat-gateway/nat-overview) |These services simplify outbound-only Internet connectivity for virtual networks. On a subnet, you can configure all outbound connectivity to use static public IP addresses that you specify. Outbound connectivity is possible without a load balancer or public IP addresses directly attached to virtual machines. AWS NAT gateways can only be associated with a single public IP. Azure NAT gateways can have multiple public IPs. |
| Cross-premises connectivity | [Site-to-Site VPN](https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html) | [VPN Gateway](/azure/vpn-gateway/vpn-gateway-about-vpngateways) |AWS Site-to-Site VPN and Azure VPN Gateway provide enhanced-security, reliable VPN connections with high availability and support for industry-standard protocols. The key differences are in their integration with other cloud services and in specific features like route-based and policy-based VPNs in Azure. AWS VPN provides a maximum of 5 Gbps throughput, whereas Azure provides up to 10 Gbps. |
| DNS management | [Route 53](https://aws.amazon.com/route53) | [Azure DNS](https://azure.microsoft.com/services/dns/) | Azure DNS lets you manage your DNS records by using the same credentials and billing and support contract that you use for your other Azure services. Both services support [DNSSEC](/azure/dns/dnssec). |
| DNS-based routing | [Route 53](https://aws.amazon.com/route53) | [Traffic Manager](https://azure.microsoft.com/services/traffic-manager) | These services host domain names, route users to internet applications, connect user requests to datacenters, manage traffic to apps, and improve app availability with automatic failover. |
| Dedicated network | [Direct Connect](https://aws.amazon.com/directconnect) | [ExpressRoute](https://azure.microsoft.com/services/expressroute) | These services establish a dedicated, private network connection from a location to the cloud provider (not over the internet). |
| Load balancing | [Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) | [Load Balancer](https://azure.microsoft.com/services/load-balancer)  | Azure Load Balancer load balances traffic at layer 4 (TCP or UDP). Standard Load Balancer also supports cross-subscription and global load balancing. |
| Application-level load balancing |  [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) | [Application Gateway](https://azure.microsoft.com/services/application-gateway) | Application Gateway is a layer 7 load balancer. It supports SSL termination, cookie-based session affinity, and round robin for load-balancing traffic. It also provides multi-site routing and security features. |
| Route tables | [Custom Route Tables](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) | [User Defined Routes](/azure/virtual-network/virtual-networks-udr-overview) | These tables provide custom or user-defined (static) routes to override default system routes, or to add more routes to a subnet's route table. |
| Private link | [PrivateLink](https://aws.amazon.com/privatelink) | [Azure Private Link](https://azure.microsoft.com/services/private-link) | Azure Private Link provides private access to services that are hosted on the Azure platform. This keeps your data on the Microsoft network. |
| Private PaaS connectivity |  [VPC endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html) | [Private Endpoint](/azure/private-link/private-endpoint-overview) | Private Endpoint provides secured, private connectivity to various Azure platform as a service (PaaS) resources, over a backbone Microsoft private network. |
| Virtual network peering | [VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) | [Virtual network peering](/azure/virtual-network/virtual-network-peering-overview) | Virtual network peering is a mechanism that connects two virtual networks in the same region through the Azure backbone network. After they're peered, the two virtual networks appear as one for all connectivity purposes. |
| Content delivery networks | [CloudFront](https://aws.amazon.com/cloudfront)| [Front Door](https://azure.microsoft.com/services/frontdoor) | Azure Front Door is a modern cloud content delivery network (CDN) service that delivers high performance, scalability, and secure user experiences for your content and applications. |
| Network monitoring | [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) | [Azure Network Watcher](/azure/network-watcher/network-watcher-monitoring-overview) | Azure Network Watcher allows you to monitor, diagnose, and analyze the traffic in Azure Virtual Network. |
| Network security | [Security groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) | [Network security groups](/azure/virtual-network/network-security-groups-overview) | These controls filter network traffic to and from resources in a virtual network subnets. |
| Virtual network peering | [AWS transit gateways](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-transit-gateways.html) | [Azure Virtual WAN](/azure/virtual-wan/) | These services simplify and enhance network connectivity across multiple environments to support scalable and flexible network architectures. Virtual WAN integrates with Azure Firewall and Azure DDoS Protection to provide additional security features. AWS transit gateways rely on AWS security services like AWS Shield and AWS WAF. Virtual WAN is designed for global connectivity, so it's easier to connect branch offices and remote users worldwide. AWS transit gateways support 100 BGP prefixes per private connection. Virtual WAN private peering supports 1,000 BGP prefixes. |
| Cloud virtual networking | [AWS Global Accelerator](https://aws.amazon.com/global-accelerator/) | [Azure Traffic Manager](/azure/traffic-manager/traffic-manager-overview) | These services improve the availability and performance of your applications with global routing and traffic management. |
| Cross-premises connectivity | [AWS Direct Connect gateways](https://docs.aws.amazon.com/directconnect/latest/UserGuide/direct-connect-gateways-intro.html) | [Azure ExpressRoute Global Reach](/azure/expressroute/expressroute-global-reach) | These services extend your on-premises networks to the cloud with dedicated private connections that span multiple regions. |
| Application-level networking | [AWS App Mesh](https://docs.aws.amazon.com/app-mesh/latest/userguide/what-is-app-mesh.html) | [Azure Service Fabric](/azure/service-fabric/) | These services provide application-level networking to manage microservices, including service discovery, load balancing, and traffic routing. |
| Service discovery | [AWS Cloud Map](https://docs.aws.amazon.com/cloud-map/latest/dg/what-is-cloud-map.html) | [Azure Private DNS](/azure/dns/private-dns-overview) | These services provide service discovery for cloud resources. They enable you to register application resources and dynamically update their locations. |

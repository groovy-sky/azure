# AWS for Azure Professionals (part 1)

## Introduction

Cloud services have revolutionized the way computing resources are delivered and consumed. Whether you're working with Infrastructure-as-a-Service (IaaS), Platform-as-a-Service (PaaS), or Software-as-a-Service (SaaS), all cloud services share fundamental concepts, characteristics, and components that define their functionality. This guide provides a technical comparison of AWS and Azure with a goal to understand AWS equivalents and operational models for Azure professionals.  

##  Organizational Hierarchy

A well-structured cloud environment includes logical and hierarchical components designed to manage resources, security, and access. These components may vary slightly depending on the cloud provider, but the principles remain consistent.

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

Identity and Access Management is critical to controlling access to cloud resources. It allows organizations to define who can access what resources and what actions they can perform.

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

The term resource is used in the same way in both Azure and Amazon Web Services (AWS). A resource is a manageable item. It could be a virtual machine, storage account, web app, database, or virtual network, for example.

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


## Compute

Compute refers to the processing power needed to run applications, workloads, or virtual machines.

### Virtual machines and servers

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Virtual machines and servers | [Amazon EC2 Instance Types](https://aws.amazon.com/ec2/instance-types)<br>[AWS Parallel Cluster](https://aws.amazon.com/hpc/parallelcluster) | [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines)<br>[Azure CycleCloud](https://azure.microsoft.com/features/azure-cyclecloud) | On-demand VMs and HPC cluster creation/management. |

### Autoscaling

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Autoscaling | [AWS Auto Scaling](https://aws.amazon.com/autoscaling) | [Virtual machine scale sets](https://learn.microsoft.com/azure/virtual-machine-scale-sets/overview)<br>[App Service autoscale](https://learn.microsoft.com/azure/app-service/web-sites-scale) | Automatically adjusts instance count based on metrics/thresholds. |

### Batch processing

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Batch processing | [AWS Batch](https://aws.amazon.com/batch) | [Azure Batch](https://azure.microsoft.com/services/batch)<br>[Azure Batch overview](https://learn.microsoft.com/azure/batch/batch-technical-overview) | Runs large-scale parallel/HPC batch workloads. |

### Containers

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Container Service | [Amazon Elastic Container Service (Amazon ECS)](https://aws.amazon.com/ecs), [AWS Fargate](https://aws.amazon.com/fargate) | [Azure Container Apps](https://azure.microsoft.com/products/container-apps/) | Azure Container Apps is a scalable service that lets you deploy thousands of containers without requiring access to the control plane. |
| Container Registry | [Amazon Elastic Container Registry (Amazon ECR)](https://aws.amazon.com/ecr) | [Azure Container Registry](https://azure.microsoft.com/services/container-registry) | Container registries store Docker formatted images and create all types of container deployments in the cloud. |
| Kubernetes Service | [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks) | [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/services/kubernetes-service) | EKS and AKS let you orchestrate Docker containerized application deployments with Kubernetes. AKS simplifies monitoring and cluster management through auto upgrades and a built-in operations console. See [Container runtime configuration](/azure/aks/concepts-clusters-workloads#container-runtime-configuration) for specifics on the hosting environment.|
| Kubernetes Service Mesh | [AWS App Mesh](https://aws.amazon.com/app-mesh) | [Istio add-on for AKS](https://learn.microsoft.com/azure/aks/istio-about)| The Istio add-on for AKS provides a fully-supported integration of the open-source Istio service mesh. |


### Serverless computing

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Serverless computing | [AWS Lambda](https://aws.amazon.com/lambda) | [Azure Functions](https://azure.microsoft.com/services/functions)<br>[WebJobs](https://learn.microsoft.com/azure/app-service/web-sites-create-web-jobs) | Serverless execution; Azure includes Functions and App Service WebJobs. |

## Storage

Cloud services offer various types of storage solutions to store data, files, and backups.

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Glacier and Azure Storage | AWS Glacier | [Azure Archive Blob Storage (archive access tier)](https://learn.microsoft.com/azure/storage/blobs/access-tiers-overview#archive-access-tier)<br>[Azure Cool Blob Storage tier](https://learn.microsoft.com/azure/storage/blobs/access-tiers-overview#cool-access-tier) | Archive tier ≈ Glacier for rarely accessed long-retention data; Cool tier is for infrequently accessed data that must be available immediately. |
| Virtual server disks | [Elastic Block Store (EBS)](https://aws.amazon.com/ebs/) | [Managed Disks](https://azure.microsoft.com/services/storage/disks/) | VM-attached block storage mapping. |
| Virtual server disks | [Amazon FSX for NetApp ONTAP](https://aws.amazon.com/fsx/netapp-ontap/) (iSCSI or NVMe/TCP LUNs) | [Azure Elastic SAN](https://azure.microsoft.com/products/storage/elastic-san/) | SAN/LUN-style block storage mapping (per table). |
| Shared files | [Elastic File System](https://aws.amazon.com/efs/) ; [Amazon FSx for Windows File Server](https://aws.amazon.com/fsx/windows/) | [Files](https://azure.microsoft.com/services/storage/files/) | Managed/shared file system mapping. |
| Shared files | [Amazon FSx for Lustre](https://aws.amazon.com/fsx/lustre/) | [Azure Managed Lustre](https://azure.microsoft.com/products/managed-lustre/) | Managed Lustre mapping. |
| Shared files | [Amazon FSx for NetApp ONTAP](https://aws.amazon.com/fsx/netapp-ontap/) | [Azure NetApp Files](https://azure.microsoft.com/products/netapp/) | Managed NetApp mapping. |
| Archiving and backup | [S3 Infrequent Access (IA)](https://aws.amazon.com/s3/storage-classes) | [Storage cool tier](https://learn.microsoft.com/azure/storage/blobs/access-tiers-overview) | Lower-cost tier for infrequently accessed data. |
| Archiving and backup | [S3 Glacier](https://aws.amazon.com/s3/storage-classes) | [Cold access storage tier](https://learn.microsoft.com/azure/storage/blobs/access-tiers-overview) | Cold tier mapping (per table). |
| Archiving and backup | [S3 Glacier Deep Archive](https://aws.amazon.com/s3/storage-classes) | [Storage archive access tier](https://learn.microsoft.com/azure/storage/blobs/access-tiers-overview) | Deep archive vs archive tier mapping. |
| Archiving and backup | [Backup](https://aws.amazon.com/backup/) | [Backup](https://azure.microsoft.com/services/backup/) | Backup/recovery service mapping. |
| Hybrid storage | [AWS Storage Gateway: S3 File Gateway](https://aws.amazon.com/storagegateway/file/s3/) | [Azure Data Box Gateway](https://learn.microsoft.com/azure/databox-gateway/data-box-gateway-overview)<br>[Azure File Sync](https://learn.microsoft.com/azure/storage/file-sync/file-sync-introduction) | Hybrid gateway/sync equivalents (per table). |
| Hybrid storage | [AWS Storage Gateway: Tape and Volume Gateway](https://aws.amazon.com/storagegateway/vtl/) | *None* | Stores and manages on-premises data in Cloud provider |
| Hybrid storage | [DataSync](https://aws.amazon.com/datasync/) | [File Sync](https://learn.microsoft.com/azure/storage/file-sync/file-sync-introduction) | Data movement/sync mapping. |
| Bulk data transfer | [Import/Export Disk](https://aws.amazon.com/snowball/disk/details/) | [Import/Export](https://learn.microsoft.com/azure/storage/common/storage-import-export-service) | Secure disk-based offline transfer mapping. |
| Bulk data transfer | [Snowball Edge](https://aws.amazon.com/snowball-edge/) | [Data Box](https://azure.microsoft.com/services/storage/databox/) | Offline transfer appliance mapping. |


## Networking

| Area | AWS | Azure | Notes |
|---|---|---|---|
| Cloud virtual networking | [Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc) | [Virtual Network](https://azure.microsoft.com/services/virtual-network) | Isolated private networking primitives. |
| NAT gateways | [AWS NAT gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) | [Azure NAT Gateway](https://learn.microsoft.com/azure/virtual-network/nat-gateway/nat-overview) | Managed outbound NAT for private subnets. |
| Cross-premises connectivity | [Site-to-Site VPN](https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html) | [VPN Gateway](https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-about-vpngateways) | Encrypted tunnels between on-premises and cloud. |
| DNS management | [Route 53](https://aws.amazon.com/route53) | [Azure DNS](https://azure.microsoft.com/services/dns/) | DNS hosting/zone and record management. |
| DNS-based routing | [Route 53](https://aws.amazon.com/route53) | [Traffic Manager](https://azure.microsoft.com/services/traffic-manager) | DNS-based routing, load balancing, failover. |
| Dedicated network | [Direct Connect](https://aws.amazon.com/directconnect) | [ExpressRoute](https://azure.microsoft.com/services/expressroute) | Private dedicated connectivity. |
| Load balancing | [Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) | [Load Balancer](https://azure.microsoft.com/services/load-balancer) | L4 load balancing. |
| Application-level load balancing | [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) | [Application Gateway](https://azure.microsoft.com/services/application-gateway) | L7 load balancing / routing. |
| Route tables | [Custom Route Tables](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) | [User Defined Routes](https://learn.microsoft.com/azure/virtual-network/virtual-networks-udr-overview) | Custom routing at subnet level. |
| Private link | [PrivateLink](https://aws.amazon.com/privatelink) | [Azure Private Link](https://azure.microsoft.com/services/private-link) | Private access to services over the provider backbone. |
| Private PaaS connectivity | [VPC endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html) | [Private Endpoint](https://learn.microsoft.com/azure/private-link/private-endpoint-overview) | Private endpoints into PaaS services. |
| Virtual network peering | [VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) | [Virtual network peering](https://learn.microsoft.com/azure/virtual-network/virtual-network-peering-overview) | Private connectivity between VNets/VPCs. |
| Content delivery networks | [CloudFront](https://aws.amazon.com/cloudfront) | [Front Door](https://azure.microsoft.com/services/frontdoor) | CDN / global edge entry service. |
| Network monitoring | [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) | [Azure Network Watcher](https://learn.microsoft.com/azure/network-watcher/network-watcher-monitoring-overview) | Network observability and diagnostics. |
| Network security | [Security groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html) | [Network security groups](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview) | Stateful network filtering at NIC/subnet level (Azure) vs SGs (AWS). |
| Virtual network peering (hub/transit) | [AWS transit gateways](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-transit-gateways.html) | [Azure Virtual WAN](https://learn.microsoft.com/azure/virtual-wan/) | Centralized routing / transit networking for multiple networks. |
| Cloud virtual networking (global routing) | [AWS Global Accelerator](https://aws.amazon.com/global-accelerator/) | [Azure Traffic Manager](https://learn.microsoft.com/azure/traffic-manager/traffic-manager-overview) | Improves global availability/performance via global routing (DNS-based on Azure TM). |
| Cross-premises connectivity (global reach) | [AWS Direct Connect gateways](https://docs.aws.amazon.com/directconnect/latest/UserGuide/direct-connect-gateways-intro.html) | [Azure ExpressRoute Global Reach](https://learn.microsoft.com/azure/expressroute/expressroute-global-reach) | Connects on-prem networks via cloud provider backbone (as implied by service names). |
| Application-level networking | [AWS App Mesh](https://docs.aws.amazon.com/app-mesh/latest/userguide/what-is-app-mesh.html) | [Azure Service Fabric](https://learn.microsoft.com/azure/service-fabric/) | Listed as counterparts in the doc’s table (note: these are not direct equivalents in all scenarios). |
| Service discovery | [AWS Cloud Map](https://docs.aws.amazon.com/cloud-map/latest/dg/what-is-cloud-map.html) | [Azure Private DNS](https://learn.microsoft.com/azure/dns/private-dns-overview) | Service discovery / private DNS naming within virtual networks. |

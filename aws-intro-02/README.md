# AWS for Azure Professionals (part 2)

## Theoretical part

Amazon Virtual Private Cloud (VPC) creates a logically isolated virtual network within AWS. VPC key features:
* Subnets: Ranges of IP addresses located within a single Availability Zone. After you add subnets, you can deploy AWS resources in your VPC.
* IP Addressing: Supports IPv4 and IPv6, including Bring Your Own IP (BYOIP).
* Routing: Uses Route Tables to direct network traffic.
* Monitoring: Includes VPC Flow Logs for tracking traffic and Traffic Mirroring for deep packet inspection.
* Connectivity Options:
    Internet Gateway: Connects the VPC to the internet.
    VPC Endpoints: Connects to AWS services privately without internet access.
    Peering: Routes traffic between two different VPCs.
    Transit Gateways: Acts as a central hub connecting VPCs, VPNs, and Direct Connect.
    VPN: Connects on-premises networks to the VPC.


## What Amazon VPC Is

Amazon Virtual Private Cloud (VPC) lets you create a **logically isolated virtual network** inside AWS, closely resembling a traditional on-premises network while leveraging AWS scalability, availability, and security.


## Core Building Blocks

### Virtual Private Cloud (VPC)

* A dedicated virtual network per AWS account
* Defined by one or more **CIDR blocks** (IPv4, IPv6, or dual-stack)
* Acts as the security and routing boundary for resources

### Subnets

* Sub-ranges of a VPC CIDR
* **Always belong to a single Availability Zone (AZ)**
* Used to isolate workloads (public, private, internal, etc.)

### Route Tables

* Control **traffic flow** within the VPC and to external networks
* Each subnet is associated with one route table
* Routes define destination CIDR → target (IGW, NAT, TGW, ENI, etc.)
## Connectivity Models

### Internet Access

* **Internet Gateway (IGW)**
  Enables inbound/outbound internet access for public subnets
* **NAT Gateway / NAT Instance**
  Allows outbound internet access from private subnets only
* **Egress-only Internet Gateway**
  IPv6 outbound-only internet access

### Private Connectivity

* **VPC Peering** – Direct, private routing between two VPCs
* **Transit Gateway** – Hub-and-spoke connectivity across many VPCs and on-prem networks
* **Site-to-Site VPN** – Encrypted IPsec tunnel to on-premises
* **Direct Connect** – Dedicated private physical connection
* **VPC Endpoints / PrivateLink** – Private access to AWS services without internet

## IP Addressing

### IPv4

* Private IPv4 (RFC 1918) is the default and **free**
* Public IPv4 addresses are **billable**
* Elastic IPs provide persistent public IPv4 addresses

### IPv6

* Supported in **dual-stack or IPv6-only** VPCs
* Amazon-provided IPv6 is globally routable
* Private IPv6 (ULA / private GUA) supported via **IP Address Manager (IPAM)**

### IP Address Manager (IPAM)

* Centralized planning, allocation, and monitoring of IP ranges
* Supports IPv4, public IPv6, and private IPv6
* Strongly recommended for multi-VPC or enterprise environments

## Security Controls

### Network-Level

* **Security Groups**
  Stateful, instance-level firewall (allow rules only)
* **Network ACLs**
  Stateless, subnet-level traffic filtering (allow & deny)
* **Block Public Access (BPA)**
  Prevents unintended public exposure at VPC/subnet level

### Traffic Protection

* Encryption in transit enforcement
* Traffic Mirroring for inspection
* AWS Network Firewall integration

---

## Monitoring & Visibility

* **VPC Flow Logs**
  Capture IP traffic metadata for auditing and troubleshooting
* **CloudWatch Metrics**
  Network Address Usage (NAU), throughput, errors
* **Reachability Analyzer**
  Path analysis for connectivity troubleshooting
* **Traffic Mirroring**
  Deep packet inspection via third-party appliances

---

## Default vs Custom VPCs

### Default VPC

* Automatically created per Region
* Public subnets in every AZ
* Internet access enabled by default
* Best for quick starts and experimentation

### Custom (Non-default) VPC

* Full control over CIDR, routing, and exposure
* Required for production-grade architectures
* Enables strict isolation and security design

## Possible Networking scenarios

### 1. Default VPC + Bastion Host (Controlled Administrative Access)

**Scenario**
You deploy an EC2 instance into the **default VPC** but do **not assign a public IPv4 address**. The instance is **not reachable directly from the internet**.

**Architecture**

* Default VPC
* Public subnet with **Internet Gateway (IGW)**
* Bastion host with public IPv4
* Private EC2 instance without public IP

**Access Pattern**

* Admin connects → **Bastion host (SSH/RDP)** → private EC2
* No direct inbound access to private instance

**Key Concepts**

* IGW provides internet routing
* Security Groups allow SSH only from admin IP to bastion
* Private EC2 Security Group allows access **only from bastion SG**
* Network ACLs remain permissive (default)
* Routing: `0.0.0.0/0 → IGW` only for bastion subnet

**Why it exists**

* Minimal exposure
* Simple secure admin access
* Common for small environments

---

### 2. Private EC2 with NAT Gateway (Outbound-Only Internet)

**Scenario**
An application server must **download updates and call external APIs**, but must **never accept inbound internet traffic**.

**Architecture**

* Custom VPC
* Public subnet with IGW + **NAT Gateway**
* Private subnet with EC2 (no public IP)

**Traffic Flow**

* EC2 → NAT GW → IGW → Internet
* Internet → ❌ (blocked)

**Key Concepts**

* NAT Gateway provides **IPv4 egress only**
* Security Groups allow outbound HTTPS
* Network ACLs restrict inbound traffic
* Routing:

  * Public subnet: `0.0.0.0/0 → IGW`
  * Private subnet: `0.0.0.0/0 → NAT GW`

**Why it exists**

* Secure outbound access
* Industry standard for private workloads
* Required for patching, API calls, package downloads

---

### 3. IPv6-Enabled Private Subnets with Egress-Only Internet Gateway

**Scenario**
You adopt **IPv6** but want **zero inbound internet exposure** while allowing outbound IPv6 traffic.

**Architecture**

* Dual-stack VPC (IPv4 + IPv6)
* Private IPv6-enabled subnets
* **Egress-only Internet Gateway**

**Traffic Flow**

* EC2 → IPv6 → Egress-only IGW → Internet
* Internet → ❌ inbound blocked automatically

**Key Concepts**

* IPv6 has **no NAT**
* Egress-only IGW prevents inbound connections
* Routing:

  * `::/0 → Egress-only IGW`
* Security Groups control IPv6 traffic explicitly

**Why it exists**

* IPv6 compliance
* Cleaner routing (no NAT)
* Strong outbound-only security model

---

### 4. VPC Peering Between Two Application VPCs

**Scenario**
Two independent teams run workloads in separate VPCs and need **private, low-latency communication**.

**Architecture**

* VPC A ↔ **VPC Peering** ↔ VPC B
* Non-overlapping CIDR ranges

**Traffic Flow**

* Private IP to private IP
* No transitive routing

**Key Concepts**

* No IGW, NAT, or firewall required
* Routing tables updated manually in both VPCs
* Security Groups must explicitly allow peer CIDRs
* Network ACLs must allow traffic

**Why it exists**

* Simple, low-cost connectivity
* Best for **few VPCs**
* Not scalable beyond small architectures

---

### 5. Transit Gateway – Hub-and-Spoke with Central Firewall

**Scenario**
Multiple VPCs require **centralized security inspection** and **controlled east–west traffic**.

**Architecture**

* **Transit Gateway (TGW)** as hub
* Spoke VPCs (App, Dev, Prod)
* Central **Firewall VPC**

**Traffic Flow**

* Spoke → TGW → Firewall → TGW → Destination
* Internet-bound traffic forced through firewall

**Key Concepts**

* Hub-and-spoke topology
* Central routing control
* Security Groups protect instances
* Network ACLs used for coarse segmentation
* Routing enforced via TGW route tables

**Why it exists**

* Enterprise-scale design
* Central governance
* Required for regulated environments

---

### 6. Site-to-Site VPN for Hybrid Connectivity

**Scenario**
On-premises network needs **encrypted connectivity** to AWS.

**Architecture**

* On-prem firewall/router
* **Site-to-Site VPN**
* Virtual Private Gateway or Transit Gateway

**Traffic Flow**

* On-prem ↔ encrypted IPsec tunnel ↔ VPC

**Key Concepts**

* CIDR ranges must not overlap
* Routing propagated via VPN
* Security Groups enforce workload access
* Network ACLs act as safety net

**Why it exists**

* Hybrid cloud foundation
* Quick to deploy
* Lower bandwidth, internet-based

---

### 7. Direct Connect for High-Performance Hybrid Networking

**Scenario**
Mission-critical workloads require **predictable latency and bandwidth** to AWS.

**Architecture**

* Physical **Direct Connect**
* DX Gateway → Transit Gateway → VPCs

**Traffic Flow**

* On-prem → AWS private backbone
* No public internet involved

**Key Concepts**

* High throughput, low latency
* Requires non-overlapping CIDRs
* Often combined with VPN for encryption
* Central routing via TGW

**Why it exists**

* Enterprise workloads
* Data-intensive applications
* Compliance requirements

---

### 8. Private Access to AWS Services Using VPC Endpoints

**Scenario**
Instances must access **S3 and DynamoDB** without internet exposure.

**Architecture**

* Private subnets
* **VPC Gateway Endpoint** (S3/DynamoDB)
* No IGW or NAT

**Traffic Flow**

* EC2 → AWS service via private AWS network

**Key Concepts**

* No public IPs required
* Route table entries for endpoints
* Endpoint policies restrict access
* Security Groups remain unchanged

**Why it exists**

* Zero internet dependency
* Reduced attack surface
* Lower cost (no NAT)

---

### 9. IP Address Management at Scale with IPAM

**Scenario**
An enterprise manages **hundreds of VPCs** across Regions.

**Architecture**

* **IPAM** with hierarchical pools
* Allocated IPv4 and IPv6 CIDRs
* Integrated with VPC creation

**Key Concepts**

* Prevents CIDR overlap
* Enforces allocation rules
* Tracks utilization
* Supports public & private IPv6

**Why it exists**

* Large-scale governance
* Multi-account strategy
* Hybrid environments

---

### 10. Security Enforcement with SG, NACL, and BPA

**Scenario**
You must ensure **no accidental public exposure**.

**Architecture**

* Security Groups for workload-level control
* Network ACLs for subnet guardrails
* **Block Public Access (BPA)** enabled

**Controls**

* SGs: allow only required ports
* NACLs: deny unwanted CIDRs
* BPA: blocks public IPs and routes

**Why it exists**

* Defense-in-depth
* Prevents misconfiguration
* Required for compliance

---

### 11. Advanced Routing Control (Traffic Steering)

**Scenario**
Traffic must follow **specific security or network paths**.

**Architecture**

* Custom route tables
* TGW route domains
* Conditional routing (firewall, inspection)

**Key Concepts**

* Longest prefix match
* Separate routing per subnet
* Controlled east–west and north–south flows

**Why it exists**

* Zero-trust networking
* Segmentation
* Complex enterprise traffic flows

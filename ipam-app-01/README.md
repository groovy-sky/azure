# IPAM (IP Address Management)

## Introduction
IPAM (IP Address Management) is a system designed to manage the assignment and usage of IP addresses within a network. It provides a centralized platform to automate, monitor, and control IP address allocation and management processes.

## What IPAM Does
IPAM helps organizations efficiently manage their IP address space by offering features such as:
- **IP Address Allocation**: Automates the assignment of IP addresses to devices within the network.
- **IP Address Tracking**: Monitors the usage of IP addresses, keeping track of which addresses are in use and which are available.
- **Subnet Management**: Manages subnets and their associated IP address ranges.
- **Reporting and Analytics**: Provides detailed reports and analytics on IP address usage and trends.

## Main Concepts

### IP Address
An IP address is a unique identifier assigned to each device connected to a network. IP addresses are used to route data between devices on the network.

### Subnet
A subnet is a segmented piece of a larger network. It allows for better organization and management of IP address spaces. Subnets are defined by a subnet mask, which determines the range of IP addresses within the subnet.

### IP Address Allocation
This is the process of assigning IP addresses to devices within a network. IPAM systems automate this process to ensure efficient and conflict-free allocation.

### IP Address Tracking
Tracking involves monitoring which IP addresses are in use and which are available. This helps prevent conflicts and ensures efficient utilization of the IP address space.

## Getting Started with IPAM

### Configuration
After installation, configure IPAM by editing the configuration file located at `config/ipam.yml`. Ensure that you provide the necessary details for your network environment, including IP address ranges.

### Usage
Once IPAM is installed and configured, you can start using it to manage your IP address space. Refer to the user guide in the `docs` directory for detailed instructions on how to use IPAM's features.

## How to Use IPAM

### Authentication and Authorization
IPAM leverages the [Microsoft Authentication Library (MSAL)](https://docs.microsoft.com/azure/active-directory/develop/msal-overview) to authenticate users. It uses your existing Azure AD credentials to provide secure access to IPAM features.

![IPAM Homepage](https://github.com/Azure/ipam/blob/main/docs/how-to/images/home_page.png?raw=true)

IPAM has the concept of an **IPAM Administrator**. Administrators can configure and manage IPAM settings, including creating and updating Spaces and Blocks.

![IPAM Admins](https://github.com/Azure/ipam/blob/main/docs/how-to/images/ipam_admin_admins.png?raw=true)

### Subscription Exclusion/Inclusion
As an IPAM administrator, you can include or exclude subscriptions from the IPAM view. Navigate to the **Admin** section and select **Subscriptions** to manage subscription visibility.

![IPAM Admin Subscriptions](https://github.com/Azure/ipam/blob/main/docs/how-to/images/ipam_admin_subscriptions.png?raw=true)

### Spaces
A **Space** represents a logical grouping of unique IP address spaces. Spaces can contain both contiguous and non-contiguous IP address CIDR blocks. Spaces cannot contain overlapping CIDR ranges.

![IPAM Spaces](https://github.com/Azure/ipam/blob/main/docs/how-to/images/discover_spaces.png?raw=true)

To add a Space, navigate to the **Configure** section and select **Add Space**. Provide a name and description, then click **Create**.

![IPAM Add Space](https://github.com/Azure/ipam/blob/main/docs/how-to/images/add_space.png?raw=true)

### Blocks
A **Block** represents an IP address CIDR range. Blocks can contain virtual networks (vNETs) whose address spaces reside within the defined CIDR range of the Block. Blocks cannot contain overlapping address spaces.

![IPAM Blocks](https://github.com/Azure/ipam/blob/main/docs/how-to/images/discover_blocks.png?raw=true)

To add a Block, navigate to the **Configure** section, select the target Space, and choose **Add Block**. Provide a name and CIDR range, then click **Create**.

![IPAM Add Block](https://github.com/Azure/ipam/blob/main/docs/how-to/images/add_block.png?raw=true)

### Virtual Network Association
As an IPAM administrator, you can associate Azure virtual networks with Blocks. Select the target Block and choose the virtual networks to associate.

![IPAM Associate vNETs](https://github.com/Azure/ipam/blob/main/docs/how-to/images/virtual_network_association.png?raw=true)

### Reservations
Currently, IP CIDR block reservations are not supported via the UI but can be managed programmatically via the API. Refer to the **Example API Calls** section for details.

### vNETs, Subnets, and Endpoints
IPAM users can view IP address utilization and detailed information for virtual networks (vNETs), subnets, and endpoints.

#### Virtual Networks
View the name, parent Block, utilization metrics, and address spaces of vNETs.

![IPAM vNETs](https://github.com/Azure/ipam/blob/main/docs/how-to/images/discover_vnets.png?raw=true)

#### Subnets
View the name, parent vNET, utilization metrics, and address ranges of subnets.

![IPAM Subnets](https://github.com/Azure/ipam/blob/main/docs/how-to/images/discover_subnets.png?raw=true)

#### Endpoints
View the name, parent vNET and subnet, resource group, and private IP of endpoints.

![IPAM Endpoints](https://github.com/Azure/ipam/blob/main/docs/how-to/images/discover_endpoints.png?raw=true)

## Azure IPAM REST API Overview

You can interface with the full set of capabilities of Azure IPAM via a REST API. We use Swagger to define API documentation in OpenAPI v3 Specification format.

API docs can be found at the `/api/docs` path of your Azure IPAM website. Here you will find information on methods, parameters, and request body details for all available APIs.

### How to Call the API

You can interface with the API like you would any other REST API. Use tools like [Postman](https://www.postman.com) or [Azure PowerShell](https://docs.microsoft.com/powershell/azure/what-is-azure-powershell) for making API calls.

### Obtaining an Azure AD Token

First, you'll need to obtain an Azure AD token for authentication. Retrieve one via the Azure IPAM UI by selecting **Token** from the menu, or use Azure PowerShell with the [Get-AzAccessToken](https://docs.microsoft.com/powershell/module/az.accounts/get-azaccesstoken) cmdlet.

### Sample API Calls

For each API call, you need:
- Bearer Token
- HTTP Method
- API Request URL
- HTTP Headers
- Request Body (for PUT/PATCH/POST)

Example: Creating an IP address CIDR reservation for a new vNET via a POST request:
```text
https://ipmadev.azurewebsites.net/api/spaces/TestSpace/blocks/TestBlock/reservations
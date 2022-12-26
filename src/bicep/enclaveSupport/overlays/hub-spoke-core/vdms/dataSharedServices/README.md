# Hub/Spoke Core Module:   NoOps Accelerator - Data Shared Services Spoke Network

## Overview

This module defines Data Shared Services spoke network deployment based on the recommendations from the Azure Mission Landing Zone Conceptual Architecture.  

Module deploys the following resources:

* Virtual Network (VNet)
* Subnets
* Network Security Group
* Storage Account

## Required Parameters

The module requires the following inputs:

| Parameter                         | Type   | Default                                                                                              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Required                   | Example                                        |
 | --------------------------------- | ------ | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | ---------------------------------------------- |
| parOrgPrefix                       | string | `aona`                                                                           | Prefix value which will be prepended to all resource names. Default: anoa                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Yes                          | `aona`
| parLocation                       | string | `resourceGroup().location`                                                                           | The Azure Region to deploy the resources into                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Yes                          | `eastus`
| parTemplateVersion                       | string | `1.0`                                                                           | The ANOA template version                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Yes                          | `1.o`
| parDeployEnvironment                       | string | None                                                                           | A suffix, 3 to 15 characters in length, to append to resource names (e.g. "dev", "test", "prod", "platforms"). It defaults to "platforms".'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Yes                          | `platforms`
| parResourcePrefix                       | string | None                       | A prefix, 3-15 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts and Log Analytics Workspaces.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Yes                          | None

## Data Shared Services Network Parameters

The module requires the following inputs for Data Shared Services Network:

| Parameter                                | Type   | Default                    | Description                                                                                                                                                                                                                          | Required | Example                    |
|------------------------------------------|--------|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|----------------------------|
| parData SharedServicesSubscriptionId                     | string | `guid`                     | The subscription ID for the Data SharedServices Network and resources. It defaults to the deployment subscription                                                                                                                                    | No       | `xxxx-xxxx-xxxx-xxxx-xxxx` | Yes| None |
parData SharedServicesVirtualNetworkAddressPrefix | string | No       | The CIDR Virtual Network Address Prefix for the Data SharedServices Virtual Network. | Yes| None |
parData SharedServicesSubnetAddressPrefix | string | No       | The CIDR Subnet Address Prefix for the default Data SharedServices subnet. It must be in the Data SharedServices Virtual Network space.| Yes| None |
parSourceAddressPrefixes | string | No       | The CIDR Virtual Network Address Prefix for the Identity/Data SharedServices Virtual Network. Leave blank if no spokes are needed. | Yes| None |
parLogStorageSkuName | string | No       | The Storage Account SKU to use for log storage. It defaults to "Standard_GRS". See <https://docs.microsoft.com/en-us/rest/api/storagerp/srp_sku_types> for valid settings.. | Yes| None |
parData SharedServicesVirtualNetworkDiagnosticsLogs | array | No       | An array of Network Diagnostic Logs to enable for the Data SharedServices Virtual Network. See <https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs> for valid settings. | Yes| None |
parData SharedServicesVirtualNetworkDiagnosticsMetrics | array | No       | An array of Network Diagnostic Metrics to enable for the Data SharedServices Virtual Network. See <https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/> diagnostic-settings?tabs=CMD#metrics for valid settings. | Yes| None |
parData SharedServicesNetworkSecurityGroupRules | array | No       | An array of Network Security Group rules to apply to the Data SharedServices Virtual Network. See <https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat> for valid settings. | Yes| None |
parData SharedServicesNetworkSecurityGroupDiagnosticsLogs | array | No       | An array of Network Security Group diagnostic logs to apply to the Data SharedServices Virtual Network. See <https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories> for valid settings. | Yes| None |
parData SharedServicesNetworkSecurityGroupDiagnosticsMetrics | array | No       | An array of Network Security Group Diagnostic Metrics to enable for the Data SharedServices Virtual Network. See <https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics> for valid settings. | Yes| None |
parData SharedServicesSubnetServiceEndpoints | array | No       | An array of Service Endpoints to enable for the Data SharedServices subnet. See <https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview> for valid settings. | Yes| None |
parLogAnalyticsWorkspaceResourceId | string | No       | . | Yes| None |
parFirewallPrivateIPAddress | string | No       | . | Yes| None |
parRouteTableRouteName | string | No       | . | Yes| None |
parRouteTableRouteAddressPrefix | string | No       | . | Yes| None |
parRouteTableRouteNextHopIpAddress | string | No       | . | Yes| None |
parRouteTableRouteNextHopType | string | No       | . | Yes| None |
parStorageAccountAccessObjectId | string | No       | . | Yes| None |
parStorageAccountAccessType | string | No       | . | Yes| None |
parAddRoleAssignmentForStorageAccount | bool | No       | . | Yes| None |

Parameters file located in the [Deployments](../../../../deployments/HubSpoke/networking/sharedservices/) folder under hub/spoke.

## Outputs

The module will generate the following outputs:

table

## Deployment

> **Note:** `bicepconfig.json` file is included in the module directory.  This file allows us to override Bicep Linters.  Currently there are two URLs which were removed because of linter warnings.  URLs removed are the following: database.windows.net and core.windows.net

In this example, the Data Shared Services (Tier 2) resources will be deployed to the resource group specified. According to the Azure Mission Landing Zone Conceptual Architecture, the Data SharedServices resources should be deployed into the Platform Management subscription. During the deployment step, we will take the default values and not pass any parameters.

Other differences in Azure IL regions are as follow:

 | Azure Cloud    | Bicep template      | Input parameters file                    |
 | -------------- | ------------------- | ---------------------------------------- |
 | Global regions | anoa.lz.svcs.bicep | anoa.lz.svcs.parameters.json    |
 | IL regions  | anoa.lz.svcs.bicep | anoa.lz.svcs.parameters.json |

> For the examples below we assume you have downloaded or cloned the Git repo as-is and are in the root of the repository as your selected directory in your terminal of choice.

### Azure CLI

```bash
# For Azure Commerical regions

# When deploying to Azure cloud, first set the cloud.
az cloudset --name AzureGovernment

# Set Platform connectivity subscription ID as the the current subscription 
ConnectivitySubscriptionId="[your platform management subscription ID]"
az account set --subscription $ConnectivitySubscriptionId

# Log in
az login
cd src/bicep
cd azresources/hub-spoke-core
az deployment sub create \
   --name anoa-dataSharedServices-deploy \
   --location eastus \
   --template-file vdms/dataSharedServices/anoa.lz.data.svcs.network.network.bicep \
   --parameters @parmeters/dataSharedServices/anoa.lz.data.svcs.network.parameters.json
   --subscription $ConnectivitySubscriptionId
```

OR

```bash

# For Azure Government regions

# When deploying to another cloud, like Azure US Government, first set the cloud.
az cloudset --name AzureGovernment

# Set Platform connectivity subscription ID as the the current subscription 
ConnectivitySubscriptionId="[your platform management subscription ID]"
az account set --subscription $ConnectivitySubscriptionId

# Log in
az login
cd src/bicep
cd azresources/hub-spoke-core
az deployment sub create \
   --name anoa-dataSharedServices-deploy \
   --location usgovvirginia \
   --template-file vdms/dataSharedServices/anoa.lz.data.svcs.network.bicep \
   --parameters @parmeters/dataSharedServices/anoa.lz.data.svcs.network.parameters.json
   --subscription $ConnectivitySubscriptionId
```

### PowerShell

```powershell
# For Azure Commerical regions
# When deploying to Azure cloud, first set the cloud and log in.
Connect-AzAccount -EnvironmentName AzureCloud

# Set Platform connectivity subscription ID as the the current subscription 
$ConnectivitySubscriptionId = "[your platform management subscription ID]"
Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId

cd src/bicep
cd azresources/hub-spoke-core
New-AzDeployment `
  -TemplateFile vdms/dataSharedServices/anoa.lz.data.svcs.network.bicep `
  -TemplateParameterFile parmeters/dataSharedServices/anoa.lz.data.svcs.network.parameters.json `
  -Location 'eastus'
  -Name 'anoa-dataSharedServices-deploy'
```

OR

```powershell

# For Azure Government regions
# When deploying to another cloud, like Azure US Government, first set the cloud and log in.
Connect-AzAccount -EnvironmentName AzureCloud

# Set Platform connectivity subscription ID as the the current subscription 
$ConnectivitySubscriptionId = "[your platform management subscription ID]"
Select-AzSubscription -SubscriptionId $ConnectivitySubscriptionId  


cd src/bicep
cd azresources/hub-spoke-core
New-AzDeployment `
  --TemplateFile vdms/dataSharedServices/anoa.lz.data.svcs.network.bicep `
  -TemplateParameterFile parmeters/dataSharedServices/anoa.lz.data.svcs.network.parameters.json `
  -Location 'usgovvirginia'
  -Name 'anoa-dataSharedServices-deploy'
```

## Air-Gapped Clouds

For air-gapped clouds it may be convenient to transfer and deploy the compiled ARM template instead of the Bicep template if the Bicep CLI tools are not available or if it is desirable to transfer only one file into the air gap.

## Cleanup

The Bicep/ARM deployment of NoOps Accelerator Data Shared Services network deployment can be deleted with these steps:

## Example Output in Azure

![Example Deployment Output](images/sharedServucesExampleDeploymentOutput.png "Example Deployment Output in Azure global regions")

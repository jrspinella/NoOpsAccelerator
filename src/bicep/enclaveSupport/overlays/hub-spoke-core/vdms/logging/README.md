# Hub/Spoke Core Module: NoOps Accelerator - Operations Logging, & Sentinel

## Overview

This module defines Azure Log Analytics Workspace, Automation Account (linked together) & multiple Solutions deploy to the Log Analytics Workspace to an Logging Resource Group in the Operations Tier.

Automation Account will be linked to Log Analytics Workspace to provide integration for Update Management, Change Tracking and Inventory, and Start/Stop VMs during off-hours for your servers and virtual machines, if deployed. Only one mapping can exist between Log Analytics Workspace and Automation Account.

The module will deploy the following Log Analytics Workspace solutions by default. Solutions can be customized as required:

* AgentHealthAssessment
* AntiMalware
* AzureActivity
* ChangeTracking
* Container Insights
* Security
* SecurityInsights (Azure Sentinel)
* ServiceMap
* SQLAssessment
* Updates
* VMInsights

Only certain regions are supported to link Log Analytics Workspace & Automation Account together (linked workspaces). Reference: Supported regions for linked Log Analytics workspace

## Required Parameters

The module requires the following inputs:

| Parameter                         | Type   | Default                                                                                              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Required                   | Example                                        |
 | --------------------------------- | ------ | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | ---------------------------------------------- |
| parOrgPrefix                       | string | `aona`                                                                           | Prefix value which will be prepended to all resource names. Default: anoa                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Yes                          | `aona`
| parLocation                       | string | `resourceGroup().location`                                                                           | The Azure Region to deploy the resources into                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Yes                          | `eastus`
| parTemplateVersion                       | string | `1.0`                                                                           | The ANOA template version                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Yes                          | `1.o`
| parDeployEnvironment                       | string | None                                                                           | A suffix, 3 to 15 characters in length, to append to resource names (e.g. "dev", "test", "prod", "platforms"). It defaults to "platforms".'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Yes                          | `platforms`
| parResourcePrefix                       | string | None                       | A prefix, 3-15 alphanumeric characters without whitespace, used to prefix resources and generate uniqueness for resources with globally unique naming requirements like Storage Accounts and Log Analytics Workspaces.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Yes                          | None |

## Logging Parameters

The module requires the following inputs:

Parameter name | Default Value | Description
-------------- | ------------- | -----------
`parOperationsSubscriptionId` | Deployment subscription | The subscription ID for the Hub Network and resources. It defaults to the deployment subscription.
`parDeploymentNameSuffix` | utcNow()  | A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.
`parLogAnalyticsWorkspaceCappingDailyQuotaGb` | -1  | The daily quota for Log Analytics Workspace logs in Gigabytes. It defaults to "-1" for no quota.
`parLogAnalyticsWorkspaceRetentionInDays` | 30  | Number of days of log retention for Log Analytics Workspace. - DEFAULT VALUE: 30
`parLogAnalyticsWorkspaceSkuName` | 'PerGB2018'  | [Free/Standard/Premium/PerNode/PerGB2018/Standalone] The SKU for the Log Analytics Workspace. It defaults to "PerGB2018". See <https://docs.microsoft.com/en-us/azure/azure-monitor/logs/resource-manager-workspace> for valid settings.
`parDeploySentinel` | false  | Switch which allows Sentinel deployment to be disabled. Default: false
`parLogStorageSkuName` | 'Standard_GRS'  | The Storage Account SKU to use for log storage. It defaults to "Standard_GRS". See <https://docs.microsoft.com/en-us/rest/api/storagerp/srp_sku_types> for valid settings.
`parLoggingStorageAccountAccess` | object | Account settings for role assignement to Storage Account

Parameters file located in the [Deployments](../../../../deployments/HubSpoke/logging/) folder under hub/spoke.

## Outputs

The module will generate the following outputs:

Parameter name | Default Value | Description
-------------- | ------------- | -----------
`outLogAnalyticsWorkspaceName` | 'guid' | Out value for Log Analytics Workspace Name
`outLogAnalyticsWorkspaceResourceId` | '/subscriptions/<<subscriptionId>>/resourcegroups/anoa-usgovvirginia-dev-logging-rg/providers/microsoft.operationalinsights/workspaces/anoa-usgovvirginia-dev-logging-log' | Out value for Log Analytics ResourceId
`outLogAnalyticsWorkspaceId` | 'guid' | Out value for Log Analytics Workspace Id
`outLogAnalyticsSolutions` | array | Out value for Log Analytics Solutions in array format

## Deployment

In this module, a Log Analytics Workspace and Automation Account will be deployed to the resource group anoa-eastus-platforms-logging-rg. The inputs for this module are defined in lz.logging.parameters.json.

There are separate input parameters files depending on which Azure cloud you are deploying because this module deploys resources into an existing resource group under the specified region. There is no change to the Bicep template file.

Other differences in Azure IL regions are as follow:

 | Azure Cloud    | Bicep template      | Input parameters file                    |
 | -------------- | ------------------- | ---------------------------------------- |
 | Commerical regions | anoa.lz.logging.bicep | anoa.lz.logging.parameters.json    |
 | Government regions  | anoa.lz.logging.bicep | anoa.lz.logging.parameters.json |

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
   --name anoa-logging-deploy \
   --location eastus \
   --template-file vdms/logging/anoa.lz.logging.bicep \
   --parameters @parmeters/logging/anoa.lz.logging.parameters.json
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
   --name anoa-logging-deploy \
   --location usgovvirginia \
   --template-file vdms/logging/anoa.lz.logging.bicep \
   --parameters @parmeters/logging/anoa.lz.logging.parameters.json
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
  -TemplateFile vdms/logging/anoa.lz.logging.bicep `
  -TemplateParameterFile parmeters/logging/anoa.lz.logging.parameters.json `
  -Location 'eastus'
  -Name 'anoa-logging-deploy'
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
  --TemplateFile vdms/logging/anoa.lz.logging.bicep `
  -TemplateParameterFile parmeters/logging/anoa.lz.logging.parameters.json `
  -Location 'usgovvirginia'
  -Name 'anoa-logging-deploy'
```

## Air-Gapped Clouds

For air-gapped clouds it may be convenient to transfer and deploy the compiled ARM template instead of the Bicep template if the Bicep CLI tools are not available or if it is desirable to transfer only one file into the air gap.

## Cleanup

The Bicep/ARM deployment of NoOps Accelerator Logging deployment can be deleted with these steps:

* Delete Logging resource group.
* Delete the diagnostic settings deployed at the subscription level.
* If Microsoft Defender for Cloud was deployed (parameter deployDefender=true was used) then remove subscription-level policy assignments and downgrade the Microsoft Defender for Cloud pricing tiers.

> NOTE: If you deploy and delete NoOps Accelerator in the same subscription multiple times without deleting the subscription-level diagnostic settings, the sixth deployment will fail. Azure has a limit of five diagnostic settings per subscription. The error will be similar to this: "The limit of 5 diagnostic settings was reached."

## Example Output in Azure

![Example Deployment Output](images/loggingExampleDeploymentOutput.png "Example Deployment Output in Azure global regions")

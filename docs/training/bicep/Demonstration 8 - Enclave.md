<style>
body { font-family: Segoe UI Light; }
h1 { font-size: 20pt; }
h2 { font-size: 18pt; }
h3 { color: #002060; font-size: 16pt; font-weight: bold; }
h4 { color: #002060; font-size: 14pt; font-weight: bold; margin-top: 15px; margin-bottom: 15px; }
h5 { color: #002060; font-size: 12pt; font-weight: bold; }
h6 { color: #002060; font-size: 12pt; font-weight: normal; }
.title {color: #002060; font-size: 12pt; font-weight: bold; text-align: right; margin-bottom: 40px;}
hr {border: 0; height: 1px; background: #333; background-image: -webkit-linear-gradient(left, #ccc, #333, #ccc); background-image: -moz-linear-gradient(left, #ccc, #333, #ccc); background-image: -ms-linear-gradient(left, #ccc, #333, #ccc); background-image: -o-linear-gradient(left, #ccc, #333, #ccc);}
.note { color: #ff6347; font-size: 12pt; font-weight: bold; }
pre {font-family: Consolas, "Andale Mono WT", "Andale Mono", "Lucida Console", "Lucida Sans Typewriter", "DejaVu Sans Mono", "Bitstream Vera Sans Mono", "Liberation Mono", "Nimbus Mono L", Monaco, "Courier New", Courier, monospace; font-weight: normal; white-space: pre-wrap; overflow-x: auto;}
</style>

# Demonstration: Deploy an SQL Server Mission Enclave using Azure NoOps Accelerator

<div class="title">A step-by-step creation and deployment of an Mission Enclave for a SQL Server and Hub/3 Spoke Platform using the Azure NoOps Accelerator.
</div>

### Setup & Prerequisite Software

> If already done this in previous labs, then you can skip to Part 1

1. You must have installed the latest [Git client](https://git-scm.com) for working with source control

1. You must have the latest version of [Visual Studio Code](https://code.visualstudio.com/) for authoring bicep files

1. Installed the [bicep extension](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#vs-code-and-bicep-extension) in Visual Studio Code

1. You must have installed either the the latest version of **AZ CLI**, see [How to install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), or **Azure PowerShell**, see [Install the Azure Az PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-9.0.1) for deploying bicep files

    **PowerShell Quick Installation for Azure CLI**
    ``` PowerShell
    $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
    ```

    **PowerShell Quick Installation for Azure PowerShell**
    ``` PowerShell
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
    ```

1. You must have installed the latest version of [Azure Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-powershell)

1. Either clone, fork, or download the [Azure NoOps Accelerator](https://aka.ms/azurenoops) to your local system.  This demonstration uses **c:\anoa** as the root directory containing the downloaded, cloned, or forked project from GitHub

### Before we Begin

You will be making modifications to several .json files for the deployment which require knowing several sensitive pieces of information.  

You can record those values here or, preferred, using your terminal save the values as variables.  Additionally, you can record and save these values in Azure Key Vault if using the Azure NoOps Accelerator on a pipeline or through a automation platform.

Saving data as variables for use while executing this demonstration or lab will help.  This code below will make executing the commands through PowerShell simpler and recalling these values.

``` PowerShell
az cloudset --name [AzureCloud | AzureGovernment]
az login
$context = Get-AzContext
$location = [your region]
```

#### OPTIONAL

If you choose to save and record your values use the table below.  This is sensitive information and care should be taken.

| Name               | Value(s)                                                                                                                                                                                                                           | How Used                                                                                                        |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Subscription ID(s) | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div> | When deploying workloads, overlays, enclaves, or platforms.  You can use multiple subscriptions for your tiers. |
| Location           | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div>                                                                                                                                                           | When deploying workloads, overlays, enclaves, or platforms (eastus, usgovvirgina, etc..).                       |

### Part 1: Create an Enclave Folder

> <span class="note">NOTE</span>: For this demonstration we will be using AZ CLI with PowerShell. You can use AZ CLI with Bash or Azure PowerShell.  The commands are the same. The only difference is the syntax.

---

#### Create Sql Server Enclave folder

1. Change to your directory containing the Azure NoOps Accelerator, this demonstration uses **c:\anoa**

1. Open Visual Studio Code in your directory containing the Azure NoOps Accelerator

1. Open folder directory **/src/bicep/enclaves/**

1. Create a folder called **enclaves-scca-hub3spoke-sqlserver** in the **/src/bicep/enclaves/** by right-click the folder and selecting **new folder**

> <span class="note">NOTE</span>: The folder name must start with **enclaves-scca-hub3spoke**.  This is how the Azure NoOps Accelerator identifies the folder as a enclave. The rest of the folder name is used to identify the workload. The folder name must be unique. If you have multiple enclaves for the same workload, then you can add a suffix to the folder name.  For example, **enclaves-scca-hub3spoke-sqlserver-1**. The suffix is not used by the Azure NoOps Accelerator, but it is used to identify the folder.

1. In the same folder create a folder called **parameters** by right-click the **enclaves-scca-hub3spoke-sqlserver** folder and selecting **new folder**

2. Add files to the **enclaves-scca-hub3spoke-sqlserver** folder by right-click the **enclaves-scca-hub3spoke-sqlserver** folder, selecting **new file** and naming the file:

    - **deploy.bicep**
    - **readme.md**
    - **bicepconfig.json**

3. Add files to the **enclaves-scca-hub3spoke-sqlserver/parameters** folder by right-click the **enclaves-scca-hub3spoke-sqlserver/parameters** folder and selecting **new file**:

    - **deploy.parameters.json**

### Part 2:  Build the Bicep for the SQL Server Mission Enclave

> <span class="note">NOTE</span>: In this demonstration, we will be building a SQL Server Mission Enclave with Azure Bicep.
---

1. Open the **/deploy.bicep** file in the **enclaves-scca-hub3spoke-sqlserver** folder and make the following changes:

    **Azure Bicep**
    ``` PowerShell
    /*
    SUMMARY: Workload Module to deploy a Sql Server Workload to an target sub.
    DESCRIPTION: The following components will be options in this deployment
                Sql Server Workload Spoke
    AUTHOR/S: <your name>

    */

    targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment

    // REQUIRED PARAMETERS
    // Example (JSON)
    // These are the required parameters for the deployment
    // -----------------------------
    // "parRequired": {
    //   "value": {
    //     "orgPrefix": "anoa",
    //     "templateVersion": "v1.0",
    //     "deployEnvironment": "dev"
    //   }
    // }
    @description('Required values used with all resources.')
    param parRequired object

    // REQUIRED TAGS
    // Example (JSON)
    // These are the required tags for the deployment
    // -----------------------------
    // "parTags": {
    //   "value": {
    //     "organization": "anoa",
    //     "region": "eastus",
    //     "templateVersion": "v1.0",
    //     "deployEnvironment": "dev",
    //     "deploymentType": "NoOpsBicep"
    //   }
    // }
    @description('Required tags values used with all resources.')
    param parTags object

    @description('The region to deploy resources into. It defaults to the deployment location.')
    param parLocation string = deployment().location
    ```

> <span class="note">NOTE</span>:  Just like the overlay, we need to add the **subscription** to the **targetScope** property and add the required parameters. The **targetScope** property is used to define where the Bicep file will be deployed. The **targetScope** property can be set to **resourceGroup** or **subscription**.

1. Since this is a mission enclave, we need to add Hub/3 Spoke platform specific parameters. Add the following parameters to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    @description('Hub Virtual network configuration.  See azresources/hub-spoke-core/vdss/hub/readme.md')
    param parHub object

    @description('Operations Spoke Virtual network configuration.  See azresources/hub-spoke-core/vdms/operations/readme.md')
    param parOperationsSpoke object

    @description('Identity Spoke Virtual network configuration.  See azresources/hub-spoke-core/vdss/identity/readme.md')
    param parIdentitySpoke object

    @description('Shared Services Spoke Virtual network configuration.  See azresources/hub-spoke-core/vdms/sharedservices/readme.md')
    param parSharedServicesSpoke object

    @description('Enables Operations Network Artifacts Resource Group with KV and Storage account for the ops subscriptions used in the deployment.')
    param parNetworkArtifacts object

    @description('Enables DDOS deployment on the Hub Network.')
    param parDdosStandard object

    @description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
    param parDeploymentNameSuffix string = utcNow()

    @description('Required. Azure Firewall configuration. Azure Firewall is deployed in Forced Tunneling mode where a route table must be added as the next hop.')
    param parAzureFirewall object

    @description('Enables logging parmeters and Microsoft Sentinel within the Log Analytics Workspace created in this deployment. See azresources/hub-spoke-core/vdms/logging/readme.md')
    param parLogging object
    
    @description('Microsoft Defender for Cloud.  It includes contact email and phone.')
    param parSecurityCenter object

    @description('When set to "true", provisions Azure Bastion Host with Jumpboxes, when specified. It defaults to "false".')
    param parRemoteAccess object
    ```
> <span class="note">NOTE</span>:  The **parHub**, **parOperationsSpoke**, **parIdentitySpoke**, **parSharedServicesSpoke**, **parNetworkArtifacts**, **parDdosStandard**, **parAzureFirewall**, **parLogging**, **parSecurityCenter**, and **parRemoteAccess** parameters are used to pass in the configuration for the Hub/3 Spoke platform.  The configuration for the Hub/3 Spoke platform is stored in the **/src/bicep/azresources/hub-spoke-core** folder.

1. The workload spoke has specific parameters it needs to use resources from the Hub 3 Spoke Platform including Hub Network and Log Analytics paramters.Add the following parameters to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    // HUB NETWORK PARAMETERS

    @description('The subscription ID for the Hub Network.')
    param parHubSubscriptionId string

    // Hub Resource Group Name
    // (JSON Parameter)
    // ---------------------------
    // "parHubResourceGroupName": {
    //   "value": "anoa-eastus-platforms-hub-rg"
    // }
    @description('The resource group name for the Hub Network.')
    param parHubResourceGroupName string

    // Hub Virtual Network Name
    // (JSON Parameter)
    // ---------------------------
    // "parHubResourceGroupName": {
    //   "value": "anoa-eastus-platforms-hub-rg"
    // }
    @description('The virtual network name for the Hub Network.')
    param parHubVirtualNetworkName string

    // Hub Virtual Network Resource Id
    // (JSON Parameter)
    // ---------------------------
    // "parHubVirtualNetworkResourceId": {
    //   "value": "/subscriptions/xxxxxxxx-xxxxxx-xxxxx-xxxxxx-xxxxxx/resourceGroups/anoa-eastus-platforms-hub-rg/providers/Microsoft.Network/virtualNetworks/anoa-eastus-platforms-hub-vnet/subnets/anoa-eastus-platforms-hub-vnet"
    // }
    @description('The virtual network resource Id for the Hub Network.')
    param parHubVirtualNetworkResourceId string

    // LOGGING PARAMETERS

    @description('Log Analytics Workspace Resource Id Needed for NSG, VNet and Activity Logging')
    param parLogAnalyticsWorkspaceResourceId string

    @description('Log Analytics Workspace Name Needed Activity Logging')
    param parLogAnalyticsWorkspaceName string
    ```
 > <span class="note">NOTE</span>: The **parHubSubscriptionId** parameter is the subscription Id of the Hub Network.  The **parHubResourceGroupName** parameter is the resource group name of the Hub Network.  The **parHubVirtualNetworkName** parameter is the virtual network name of the Hub Network.  The **parHubVirtualNetworkResourceId** parameter is the virtual network resource Id of the Hub Network.  The **parLogAnalyticsWorkspaceResourceId** parameter is the Log Analytics Workspace resource Id.  The **parLogAnalyticsWorkspaceName** parameter is the Log Analytics Workspace name. These parameters will be used to create the Tier 3 spoke as part of a Hub 3 Spoke Platform.

2. Next, we will be adding the SQL Server object parameter for the deployment. The SQL Server object parameter is the object that will have all the parameters that defines a Sql Server for Azure. Add the following parameters to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    // SQL SERVER PARAMETERS

    @description('Defines the Sql Server Object.')
    param parSqlServer object 
    ```
> <span class="note">NOTE</span>: The **parSqlServer** parameter will be used to create the Sql Server resource and will contain the following properties:  

| Name                       | Type   | Description                                                                                                                                                                                                                                                |
| -------------------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name                       | string | The name of the Sql Server.                                                                                                                                                                                                                                |
| location                   | string | The location of the Sql Server.                                                                                                                                                                                                                            |
| tags                       | object | The tags of the Sql Server.                                                                                                                                                                                                                                |
| sku                        | string | The sku of the Sql Server.                                                                                                                                                                                                                                 |
| version                    | string | The version of the Sql Server.                                                                                                                                                                                                                             |
| administratorLogin         | string | The administrator login of the Sql Server.                                                                                                                                                                                                                 |
| administratorLoginPassword | string | The administrator login password of the Sql Server.                                                                                                                                                                                                        |
| publicNetworkAccess        | string | The public network access of the Sql Server.                                                                                                                                                                                                               |
| minimalTlsVersion          | string | The minimal TLS version of the Sql Server.                                                                                                                                                                                                                 |
| databases                  | int    | The databases for the Sql Server.                                                                                                                                                                                                                          |
| firewallRules              | array  | The firewall rules of the Sql Server.                                                                                                                                                                                                                      |
| minimalTlsVersion          | string | Minimal TLS version allowed. [1.0, 1.1, 1.2]                                                                                                                                                                                                               |
| publicNetworkAccess        | bool   | Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and neither firewall rules nor virtual network rules are set. |
| enableLocks                | bool   | Enable resource lock                                                                                                                                                                                                                                       |

We will be adding the **parSqlServer** parameters to the **/parameters/deploy.parameters.json** file in Part 3.

1. Now we will start building the Tier 3 module for the deployment. The Tier 3 module are used to create the resources for the workload deployment. Add the following modules to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    //=== TAGS === 

    var referential = {
    workload: parWorkloadSpoke.name
    }

    @description('Resource group tags')
    module modTags '../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
    name: 'Sql-Resource-Tags-${parDeploymentNameSuffix}'
    scope: subscription()
    params: {
        tags: union(parTags, referential)
    }
    }

    //=== Workload Tier 3 Buildout === 
    module modTier3 '../../overlays/management-services/workloadSpoke/deploy.bicep' = {
    name: 'deploy-wl-vnet-${parLocation}-${parDeploymentNameSuffix}'
    scope: subscription(parWorkloadSpoke.subscriptionId)
    params: {
        //Required Parameters
        parRequired:parRequired
        parLocation: parLocation
        parTags: modTags.outputs.tags

        //Hub Network Parameters
        parHubSubscriptionId: parHubSubscriptionId
        parHubVirtualNetworkResourceId: parHubVirtualNetworkResourceId
        parHubVirtualNetworkName: parHubVirtualNetworkName
        parHubResourceGroupName: parHubResourceGroupName

        //WorkLoad Parameters
        parWorkloadSpoke: parWorkloadSpoke    

        //Logging Parameters
        parLogAnalyticsWorkspaceName: parLogAnalyticsWorkspaceName
        parLogAnalyticsWorkspaceResourceId: parLogAnalyticsWorkspaceResourceId
        parEnableActivityLogging: true
    }
    }

    //=== End Workload Tier 3 Buildout === 
    ```

1. Next, we will start building the Sql Server Overlay module for the deployment. The Sql Server Overlay module are used to create the resources for the Sql Server deployment. Add the following modules to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    //=== Sql Server Workload Buildout === 

    module modSqlServerDeploy '../../overlays/management-services/sqlServer/deploy.bicep' = {
    name: 'deploy-sql-${parLocation}-${parDeploymentNameSuffix}'
    scope: subscription(parWorkloadSpoke.subscriptionId)
    params: {
            parLocation: parLocation
            parSqlServer: parSqlServer
            parRequired: parRequired
            parTags: modTags.outputs.tags
            parTargetResourceGroup: modTier3.outputs.workloadResourceGroupName
            parTargetSubscriptionId: parWorkloadSpoke.subscriptionId    
        }
        dependsOn: [
            modTier3
        ]
    }    
    ```

> <span class="note">IMPORTANT</span>: The **modSqlServerDeploy** module uses the Workload Tier 3 module as a dependency. This is because the Sql Server Overlay module will be deployed to the Workload Spoke Tier 3 resource group.

### Part 3: Build the Parameters for the Sql Server Workload Deployment

> <span class="note">NOTE</span>: The following steps will be adding the parameters for the Sql Server Workload deployment. The parameters will be added to the **/parameters/deploy.parameters.json** file.
---

1. Now let's build the parameters for the Sql Server Workload. Add the following to the **/parameters.json** file:

    **JSON**
    ``` JSON
    {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "parRequired": {
            "value": {
                "orgPrefix": "anoa",
                "templateVersion": "v1.0",
                "deployEnvironment": "dev"
            }
        },
        "parTags": {
            "value": {
                "organization": "anoa",
                "templateVersion": "v1.0",
                "deployEnvironment": "dev",
                "deploymentType": "NoOpsBicep"
            }
        },
        "parWorkloadSpoke": {
            "value": {
                "name": "sqlServer",
                "shortName": "sqlServer",
                "subscriptionId": "<<your subscriptionId>>",
                "enableDdosProtectionPlan": false,
                "network": {
                    "virtualNetworkAddressPrefix": "10.0.125.0/26",
                    "subnetAddressPrefix": "10.0.125.0/26",
                    "allowVirtualNetworkAccess": true,
                    "useRemoteGateway": false,
                    "virtualNetworkDiagnosticsLogs": [],
                    "virtualNetworkDiagnosticsMetrics": [],
                    "networkSecurityGroupRules": [],
                    "NetworkSecurityGroupDiagnosticsLogs": [
                        "NetworkSecurityGroupEvent",
                        "NetworkSecurityGroupRuleCounter"
                    ],
                    "subnetServiceEndpoints": [
                        {
                            "service": "Microsoft.Storage"
                        }
                    ],
                    "subnets": [],
                    "routeTable": {
                        "disableBgpRoutePropagation": true,
                        "routes": [
                            {
                                "name": "wl-routetable",
                                "properties": {
                                    "addressPrefix": "0.0.0.0/0",
                                    "nextHopIpAddress": "10.0.100.4",
                                    "nextHopType": "VirtualAppliance"
                                }
                            }
                        ]
                    }
                },
                "storageAccountAccess": {
                    "enableRoleAssignmentForStorageAccount": false,
                    "principalIds": [
                        "<<PrincipalID>>"
                    ],
                    "roleDefinitionIdOrName": "Contributor"
                }
            }
        },
        "parHubSubscriptionId": {
            "value": "<<hub subscriptionId>>"
        },
        "parHubResourceGroupName": {
            "value": "anoa-eastus-dev-hub-rg"
        },
        "parHubVirtualNetworkName": {
            "value": "anoa-eastus-dev-hub-vnet"
        },
        "parHubVirtualNetworkResourceId": {
            "value": "/subscriptions/<<subscriptionId>>/resourceGroups/anoa-eastus-dev-hub-rg/providers/Microsoft.Network/virtualNetworks/anoa-eastus-dev-hub-vnet"
        },
        "parLogAnalyticsWorkspaceResourceId": {
            "value": "/subscriptions/<<subscriptionId>>/resourcegroups/anoa-eastus-dev-logging-rg/providers/microsoft.operationalinsights/workspaces/anoa-eastus-dev-logging-log"
        },
        "parLogAnalyticsWorkspaceName": {
            "value": "anoa-eastus-dev-logging-log"
        },
        "parSqlServer": {
            "value": {
                "sqlServerName": "sqlsrv-001",
                "administratorLogin": "azureuser",
                "administratorLoginPassword": "Rem0te@2020246",
                "minimalTlsVersion": "1.2",
                "publicNetworkAccess": "Enabled",
                "enableLocks": 'CanNotDelete',
                "databases": [
                    {
                        "name": "anoa",
                        "collation": "SQL_Latin1_General_CP1_CI_AS",
                        "licenseType": "LicenseIncluded",
                        "maxSizeBytes": 34359738368,
                        "skuCapacity": 12,
                        "skuFamily": "Gen5",
                        "skuName": "BC_Gen5",
                        "skuTier": "BusinessCritical"
                    }
                ],
                "firewallRules": [
                    {
                        "endIpAddress": "0.0.0.0",
                        "name": "AllowAllWindowsAzureIps",
                        "startIpAddress": "0.0.0.0"
                    }
                ]
            }
        }
      }
    }
    ```

> <span class="note">NOTE</span>: The **parWorkloadSpoke** parameter is the same as the one used in the previous section. The **parSqlServer** parameter is the same as the one used in the previous section. It is important make sure that all network parameters are correct. IP addresses and subnet ranges should be unique and not overlap with other subnets in the hub or other workload spokes.
---

1. Make the following changes to the **deploy.parameters.json** file or leave default values:

    - parRequired.orgPrefix = **\<your org prefix or the default 'anoa'\>**

    - parTags.organization = **\<your org prefix or the default ANOA\>**

    - parTags.region = **\<your Azure region (eastus, usgovvirginia, etc...)\>**

    - parHubSubscriptionId = **\<subscription Id to Hub subscription\>**

    - parHubResourceGroupName = **\<Resource Group Name to Hub RG\>**

    - parHubVirtualNetworkResourceId = **\<Virtual Network Resource Id to Hub Network\>**
    
    - parHubVirtualNetworkName = **\<Virtual Network Name of the Hub Network\>**
  
    - parLogAnalyticsWorkspaceResourceId = **\<Log Analytics Workspace Resource Id to Hub Network\>**
  
    - parLogAnalyticsWorkspaceName = **\<Log Analytics Workspace Name to Hub Network\>**
  
    - parSqlServer.sqlServerName = **\<your sql server name\>**
  
    - parSqlServer.administratorLogin = **\<your sql server administrator login\>**
  
    - parSqlServer.administratorLoginPassword = **\<your sql server administrator login password\>**

    - parSqlServer.databases.name = **\<your sql server database name\>**

> <span class="note">NOTE</span>: All Hub Network parameters are required. If you are using the default Hub/3 Spoke deployment, you can leave the default values. If you are using a custom Hub/Spoke deployment, you will need to update the parameters with the values from your custom Hub deployment. Make sure to fill in <<subscriptionId>> parameters with the correct subscriptions.


### Part 4: Deploy Sql Server Workload

> <span class="note">NOTE</span>: The following steps will deploy the Sql Server workload with an Tier 3 Spoke Network. The deployment will take approximately 20 minutes to complete. The deployment will fail if there is not a existing Hub/3 Spoke Network deployed. If the deployment fails, check the deployment logs for more information.
---

##### Validate the deployment with WhatIf

> <span class="note">NOTE</span>: The **WhatIf** parameter is used to validate the deployment without actually deploying the resources. This is a great way to validate the deployment before actually deploying the resources.

1. Open PowerShell and change to your directory containing the NoOps Accelerator, this demonstration uses **c\anoa**
   
2. In your PowerShell session Issue **Set-Location -Path 'c:\anoa\src\bicep\workloads\wl-sqlserver-spoke\'**

3. Issue **$context = Get-AzContext** and record the following values:    -

    - Subscription ID: **$context.Subscription.Id**

    > <span class="note">NOTE</span>: If more than one value is returned, choose the subscription you are targeting to create the sql server workload. You can also use **Set-AzContext** to set your current subscription for this session.

4. Issue the command:
   
    **Azure CLI**
    ``` PowerShell
    az deployment sub what-if --subscription $context.Subscription.Id --template-file 'deploy.bicep' --parameters '@parameters/deploy.parameters.json' --location $location
    ```
    
    > <span class="note">NOTE</span>: The **--location** parameter is used to specify the location for the resource group. This is not the location for the Sql Server. The location for the Sql Server is specified in the **parameters.json** file.

5. Review the output of the command and verify that the deployment will create the resource group and the sql server.

##### Deploy Sql Server Workload Spoke

1. Open PowerShell and change to your directory containing the NoOps Accelerator, this demonstration uses **c\anoa**

1.  Issue the command **az login** and log into your tenant

1. In your PowerShell session Issue **Set-Location -Path 'c:\anoa\src\bicep\overlays\sqlserver'**

1. Issue **$context = Get-AzContext** and record the following values:    -

    - Subscription ID: **$context.Subscription.Id**

    > **NOTE**: If more than one value is returned, choose the subscription you are targeting to create the sql server overlay. You can also use **Set-AzContext** to set your current subscription for this session.

2.  Issue the command updating the **--subscription** parameter with your subscription id and the **--location** parameter to your location

    **Azure CLI**
    ``` PowerShell
    az deployment sub create --name 'deploy-sql-server' --template-file 'deploy.bicep' --parameters '@parameters/deploy.parameters.json' --location $location --subscription $context.Subscription.Id --only-show-errors
    ```

##### Remove the Sql Server Overlay

1.  Issue thus command:

    **Azure CLI**
    ``` PowerShell
    Remove-AzResourceGroup -Name 'anoa-usgovvirginia-dev-sqlsrv-rg'
    ```
 <span class="note">NOTE</span>: The resource group name is based on the parameters you used when deploying the overlay. Change the resource group name to match your previous deployment.

##### References
---
[Deploying Management Groups with the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/management-groups)  
[Deploying Roles with the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/roles)  
[Deploying Policy for Guardrails with the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/Policy)  
[Deploying SCCA Compliant Hub and 1-Spoke using the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/platforms/lz-platform-scca-hub-1spoke)  
[Deploying a Kubernetes Private Cluster Workload using the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/workloads/wl-aks-spoke)

# Demonstration: Create an Overlay for SQL Server using Azure NoOps Accelerator and Terraform

A step-by-step creation and deployment of a Sql Server Overlay using the Azure NoOps Accelerator.


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
| Subscription ID(s) | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div></br><div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div><br/><div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div> | When deploying workloads, overlays, enclaves, or platforms.  You can use multiple subscriptions for your tiers. |
| Location           | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div>                                                                                                                                                           | When deploying workloads, overlays, enclaves, or platforms (eastus, usgovvirgina, etc..).                       |

### Part 1: Create an Overlay Folder

> <span class="note">NOTE</span>: For this demonstration we will be using AZ CLI with PowerShell. You can use AZ CLI with Bash or Azure PowerShell.  The commands are the same. The only difference is the syntax.

---

#### Create Sql Server Overlay folder

1. Change to your directory containing the Azure NoOps Accelerator, this demonstration uses **c:\anoa**

1. Open Visual Studio Code in your directory containing the Azure NoOps Accelerator

1. Open folder directory **/src/bicep/overlays/management-services/**

1. Create a folder called **sqlServer** in the **/src/bicep/overlays/management-services/** by right-click the folder and selecting **new folder**

1. In the same folder create a folder called **parameters** by right-click the **sqlServer** folder and selecting **new folder**

2. Add files to the **sqlServer** folder by right-click the **sqlServer** folder, selecting **new file** and naming the file:

    - **deploy.bicep**
    - **readme.md**

2. Add files to the **sqlServer/parameters** folder by right-click the **sqlServer/parameters** folder and selecting **new file**:

    - **deploy.parameters.json**

### Part 2:  Build the Bicep for the SQL Server Overlay

---

1. Open the **/deploy.bicep** file in the **sqlServer** folder and make the following changes:

    **Azure Bicep**
    ``` PowerShell
    /*
    SUMMARY: Overlay Module Example to deploy an Sql Server.
    DESCRIPTION: The following components will be options in this deployment
                * Sql Server
    AUTHOR/S: <<your name>>
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

> <span class="note">IMPORTANT</span>:  Since this overlay will be used in workloads, we need to add the **subscription** to the **targetScope** property and add the required parameters. The **targetScope** property is used to define where the Bicep file will be deployed. The **targetScope** property can be set to **resourceGroup** or **subscription**.

2. Next, we will be adding the SQL Server object parameter for the deployment. The SQL Server object parameter is the object that will have all the parameters that defines a Sql Server for Azure. Add the following parameters to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    // SQL SERVER PARAMETERS

    @description('Defines the Sql Server Object.')
    param parSqlServer object
    ```
> <span class="note">NOTE</span>: The **parSqlServer** parameter will be used to create the Sql Server resource and will contain the following properties:

| Name | Type | Description |
| --- | --- | --- |
| name | string | The name of the Sql Server. |
| location | string | The location of the Sql Server. |
| tags | object | The tags of the Sql Server. |
| sku  | string | The sku of the Sql Server. |
| version | string | The version of the Sql Server.|
| administratorLogin | string | The administrator login of the Sql Server. |
| administratorLoginPassword | string | The administrator login password of the Sql Server. |
| publicNetworkAccess | string | The public network access of the Sql Server. |
| minimalTlsVersion | string | The minimal TLS version of the Sql Server. |
| databases | int | The databases for the Sql Server. |
| firewallRules | array | The firewall rules of the Sql Server. |
| minimalTlsVersion | string | Minimal TLS version allowed. [1.0, 1.1, 1.2]|
| publicNetworkAccess | bool   | Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and neither firewall rules nor virtual network rules are set. |
| enableLocks | bool | Enable resource lock |

We will be adding the **parSqlServer** parameters to the **/parameters/deploy.parameters.json** file in Part 3.

3. Next, We will be adding the targets for this overlay. **Targets** are used to specify the subscription and resource group where the Sql Server will be deployed. Add the following to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    // TARGETS

    // SUBSCRIPTIONS PARAMETERS

    // Target Virtual Network Name
    // (JSON Parameter)
    // ---------------------------
    // "parTargetSubscriptionId": {
    //   "value": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxx"
    // }
    @description('The subscription ID for the Target Network and resources. It defaults to the deployment subscription.')
    param parTargetSubscriptionId string = subscription().subscriptionId

    // Target Resource Group Name
    // (JSON Parameter)
    // ---------------------------
    // "parTargetResourceGroup": {
    //   "value": "anoa-eastus-platforms-hub-rg"
    // }
    @description('The name of the resource group in which the Sql Server will be deployed. If unchanged or not specified, the Azure NoOps Accelerator will create an resource group to be used.')
    param parTargetResourceGroup string = ''
    ```
> <span class="note">IMPORTANT</span>: The **parTargetSubscriptionId** parameter is used to specify the subscription where the Sql Server will be deployed. The **parTargetResourceGroup** parameter is used to specify the resource group where the Sql Server will be deployed. If the **parTargetResourceGroup** parameter is not specified, the Azure NoOps Accelerator will create a resource group for the Sql Server.

3. Next, We will be adding the resource naming parameters for this overlay. The **resource naming** parameters is used in name parameter in each of the modules. Add the following to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    // RESOURCE NAMING PARAMETERS

    @description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
    param parDeploymentNameSuffix string = utcNow()


    @description('The current date - do not override the default value')
    param dateUtcNow string = utcNow('yyyy-MM-dd HH:mm:ss')
    ```
> <span class="note">NOTE</span>: The **parDeploymentNameSuffix** parameter is used to create a unique name for the deployment. The **dateUtcNow** parameter is used to create a unique name for the deployment.

3. Next, We will be adding the resource naming variables for this overlay. The **resource naming** variables is used in naming of the modules. This provides a consistent naming convention for all resources.  Add the following to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    /*
    NAMING CONVENTION
    Here we define a naming conventions for resources.
    First, we take `parDeployEnvironment` and `parDeployEnvironment` by params.
    Then, using string interpolation "${}", we insert those values into a naming convention.
    */

    var varResourceToken = 'resource_token'
    var varNameToken = 'name_token'
    var varNamingConvention = '${toLower(parRequired.orgPrefix)}-${toLower(parLocation)}-${toLower(parRequired.deployEnvironment)}-${varNameToken}-${toLower(varResourceToken)}'

    // RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS

    var varResourceGroupNamingConvention = replace(varNamingConvention, varResourceToken, 'rg')
    var varSqlServerNamingConvention = replace(varNamingConvention, varResourceToken, 'sql')

    // SQL SERVER NAMES

    var varSqlServerName = parSqlServer.sqlServerName
    var varSqlServerResourceGroupName = replace(varResourceGroupNamingConvention, varNameToken, varSqlServerName)
    var varServerName = replace(varSqlServerNamingConvention, varNameToken, varSqlServerName)
    ```

> <span class="note">NOTE</span>: The **varNamingConvention** variable is used to create the naming convention for the resources.  The **varResourceGroupNamingConvention** variable is used to create the naming convention for the resource groups.  The **varSqlServerName** variable is used to create the naming convention for the Sql Server.  The **varSqlServerResourceGroupName** variable is used to create the naming convention for the Sql Server resource group.

1. Now let's add the sqlServer module from Az Resources to this overlay. Add the following to the **/deploy.bicep** file:

    **Azure Bicep**
    ``` PowerShell
    //=== TAGS ===

    var referential = {
    region: parLocation
    deploymentDate: dateUtcNow
    }


    @description('Resource group tags')
    module modTags '../../../azresources/Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
    name: 'deploy-sqlSvr-tags-${parLocation}-${parDeploymentNameSuffix}'
    scope: subscription(parTargetSubscriptionId)
    params: {
        tags: union(parTags, referential)
      }
    }

    // Sql Server

    // Create Sql Server resource group
    resource rgSqlServerRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: (!empty(parTargetResourceGroup)) ? parTargetResourceGroup : varSqlServerResourceGroupName
    location: parLocation
    }

    // Create Sql Server
    module modSqlServer '../../../azresources/Modules/Microsoft.Sql/servers/az.data.sqlserver.bicep' = {
    name: 'deploy-sqlSvr-${parLocation}-${parDeploymentNameSuffix}'
    scope: resourceGroup(parTargetSubscriptionId, rgSqlServerRg.name)
    params: {
        location: parLocation
        name: varServerName
        tags: parTags
        administratorLogin: parSqlServer.administratorLogin
        administratorLoginPassword: parSqlServer.administratorLoginPassword
        minimalTlsVersion: parSqlServer.minimalTlsVersion
        publicNetworkAccess: parSqlServer.publicNetworkAccess
        databases: parSqlServer.databases
        firewallRules: parSqlServer.firewallRules
      }
    }
    ```

> <span class="note">IMPORTANT</span>: The **modTags** module is used to create the tags for the Sql Server. The **rgSqlServerRg** resource is used to create the resource group for the Sql Server. The **modSqlServer** module is used to create the Sql Server.

### Part 3: Build the Parameters for the Overlay

1. Now let's build the parameters for the overlay. Add the following to the **/parameters.json** file:

    **JSON**
    ``` PowerShell
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
        "parTargetSubscriptionId": {
            "value": "<<YOUR SUBSCRIPTION ID>>"
        },
        "parTargetResourceGroup": {
            "value": ""
        },
        "parSqlServer": {
            "value": {
                "sqlServerName": "sqlsrv-001",
                "administratorLogin": "azureuser",
                "administratorLoginPassword": "Rem0te@2020246",
                "minimalTlsVersion": "1.2",
                "publicNetworkAccess": "Enabled",
                "enableLocks": true,
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

---

1. Make the following changes to the **deploy.parameters.json** file or leave default values:

    - parRequired.orgPrefix = **\<your org prefix or the default 'anoa'\>**

    - parTags.organization = **\<your org prefix or the default ANOA\>**

    - parTags.region = **\<your Azure region (eastus, usgovvirginia, etc...)\>**

    - parTargetSubscriptionId = **\<subscription Id to host the sql server\>**

    - parTargetResourceGroup = **\<leave blank\>**

    - parSqlServer.sqlServerName = **\<your sql server name\>**

    - parSqlServer.administratorLogin = **\<your sql server administrator login\>**

    - parSqlServer.administratorLoginPassword = **\<your sql server administrator login password\>**

    - parSqlServer.databases.name = **\<your sql server database name\>**

> <span class="note">NOTE</span>: The **parTargetResourceGroup** parameter is left blank.  This will allow the overlay to create the resource group for the Sql Server.

### Part 4: Deploy Sql Server Overlay

> <span class="note">IMPORTANT</span>: Overlays are not meant to be deployed seperatly but they can be. In this case we are deploying the overlay seperatly to show how it works. In a real world scenario the overlay would be deployed as part of a larger platform or workload deployment.

---

##### Validate the deployment with WhatIf

> <span class="note">NOTE</span>: The **WhatIf** parameter is used to validate the deployment without actually deploying the resources. This is a great way to validate the deployment before actually deploying the resources.

1. Open PowerShell and change to your directory containing the NoOps Accelerator, this demonstration uses **c\anoa**

2. In your PowerShell session Issue **Set-Location -Path 'c:\anoa\src\bicep\overlays\management-services\sqlserver'**

3. Issue **$context = Get-AzContext** and record the following values:    -

    - Subscription ID: **$context.Subscription.Id**

    > <span class="note">NOTE</span>: If more than one value is returned, choose the subscription you are targeting to create the sql server overlay. You can also use **Set-AzContext** to set your current subscription for this session.

4. Issue the command:

    **Azure CLI**
    ``` PowerShell
    az deployment sub what-if --subscription $context.Subscription.Id --template-file 'deploy.bicep' --parameters '@parameters/deploy.parameters.json' --location $location
    ```

    > <span class="note">NOTE</span>: The **--location** parameter is used to specify the location for the resource group. This is not the location for the Sql Server. The location for the Sql Server is specified in the **parameters.json** file.

5. Review the output of the command and verify that the deployment will create the resource group and the sql server.

``` PowerShell
Resource and property changes are indicated with these symbols:
  + Create
  ~ Modify

The deployment will update the following scopes

Scope: /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

  + resourceGroups/anoa-usgovvirginia-dev-sqlsrv-001-rg [2021-04-01]

      apiVersion: "2021-04-01"
      id:         "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/anoa-usgovvirginia-dev-sqlsrv-001-rg"
      location:   "usgovvirginia"
      name:       "anoa-usgovvirginia-dev-sqlsrv-001-rg"
      type:       "Microsoft.Resources/resourceGroups"
      properties.endIpAddress:   "0.0.0.0"
      properties.startIpAddress: "0.0.0.0"
      type:                      "Microsoft.Sql/servers/firewallRules"

  + Microsoft.Sql/servers/anoa-usgovvirginia-dev-sqlsrv-001-sql/providers/Microsoft.Authorization/locks/anoa-usgovvirginia-dev-sqlsrv-001-sql-CanNotDelete-lock [2017-04-01]

      apiVersion:       "2017-04-01"
      id:               "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/anoa-usgovvirginia-dev-sqlsrv-001-rg/providers/Microsoft.Sql/servers/anoa-usgovvirginia-dev-sqlsrv-001-sql/providers/Microsoft.Authorization/locks/anoa-usgovvirginia-dev-sqlsrv-001-sql-CanNotDelete-lock"
      name:             "anoa-usgovvirginia-dev-sqlsrv-001-sql-CanNotDelete-lock"      properties.level: "CanNotDelete"
      properties.notes: "Cannot delete resource or child resources."
      type:             "Microsoft.Authorization/locks"

Resource changes: 4 to create, 1 to modify.
```

7. This ouput tells us that there will be a creation of 2 resources (resource group & sql server) and that the values are as expected. The **WhatIf** command is a great way to validate the deployment before actually deploying the resources. If you are satisfied with the deployment, then deploy the infrastructure by removing the **WhatIf** value.

##### Deploy Sql Server Overlay

1.  Issue the command updating the **--subscription** parameter with your subscription id and the **--location** parameter to your location

    **Azure CLI**
    ``` PowerShell
    az deployment sub create --name 'deploy-sql-server' --template-file 'deploy.bicep' --parameters '@parameters/deploy.parameters.json' --location $location --subscription $context.Subscription.Id --only-show-errors
    ```

##### Remove the Sql Server Overlay

1. Issue this command to remove the resources created by the overlay:

    **Azure CLI**
    ``` PowerShell
    Remove-AzResourceGroup -Name 'anoa-usgovvirginia-dev-sqlsrv-001-rg'
    ```
 <span class="note">NOTE</span>: The resource group name is based on the parameters you used when deploying the overlay. Change the resource group name to match your previous deployment.

##### References
---
[Deploying Management Groups with the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/management-groups)
[Deploying Roles with the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/roles)
[Deploying Policy for Guardrails with the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/Policy)
[Deploying SCCA Compliant Hub and 1-Spoke using the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/platforms/lz-platform-scca-hub-1spoke)
[Deploying a Kubernetes Private Cluster Workload using the Azure NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/workloads/wl-aks-spoke)

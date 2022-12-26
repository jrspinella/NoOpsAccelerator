# Demonstration: Deploy Kubernetes Enclave using Azure CLI and Terraform

An mission enclave deployment using the Azure NoOps Accelerator for a Azure Kubernetes Service private cluster and Hub/3 Spoke Platform.

### Setup & Prerequisite Software

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

1. Either clone, fork, or download the [NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator) to your local system.  This demonstration uses **c:\anoa** as the root directory containing the downloaded, cloned, or forked project from GitHub

### Before we Begin

You will be making modifications to several .json files for the deployment which require knowing several sensitive pieces of information.  You will also create a group in Azure Active Directory, and you will need that group's object id.  Finally, you will be creating an application registration in Azure Active Directory and will need the client id and secret.

You can record those values here or, preferred, using your terminal save the values as variables.  Additionally, you can record and save these values in Azure Key Vault if using the Azure NoOps Accelerator on a pipeline or through a automation platform.

#### OPTIONAL

If you choose to save and record your values use the table below.  This is sensitive information and care should be taken.

| Name | Value(s) | How Used |
| --- | --- | --- |
| Tenant ID | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div> | When deploying management groups or policies. |
| Subscription ID(s) | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div></br><div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div><br/><div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div> | When deploying workloads, overlays, enclaves, or platforms.  You can use multiple subscriptions for your tiers. |
| Principal ID(s) | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div><br/><div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div><br/><div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div> | When using either built-in roles or custom deployed ANOA roles for securing resources. |
| Object ID(s) | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div><br/><div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div> | When deploying resources that need to use an Active Directory Group for access control. |
| Client ID(s) | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div><br/><div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div> | When deploying your Kubernetes cluster for the application registration. |
| Location | <div style="height: 20px;background-color: #CFD8DC;width: 300px;"></div> | When deploying workloads, overlays, enclaves, or platforms (eastus, usgovvirgina, etc..). |

#### OPTIONAL

Saving data as variables for use while executing this demonstration or lab.  This will make executing the commands through PowerShell simpler.

``` PowerShell
az cloudset --name [AzureCloud | AzureGovernment]

az login

$context = Get-AzContext

$location = [your region]
```

### Part 1: Deploy Kubernetes Workload using an Enclave

> NOTE: If you have already created the Azure Active Diretory group and App Registration you can simply record those values and re-use them in this demonstration.
---

##### Create an Azure Active Directory Group

1. Return to your Azure Portal

1. Navigate to your Azure Active Directory

1. Click on **Groups** in the left navigation

1. Click on **New Group** in the top breadcrumb navigation

1. Provide the following information:

    - Group Type: **security**

    - Group Name: **K8S Cluster Administrators**

    - Group Description: **Administrators of Kubernetes Clusters**

    - Owners: **<\< your login \>>**

    - Members: **<\< your login \>>**

    - Click the **Create** button

1. Record the Object Id for the group, this will be used in the workload deployment for Kubernetes

##### Create an App Registration in Azure Active Directory

1. Return to your Azure Portal

1.  Navigate to your Azure Active Directory

1.  Click on **App Registrations** in the left navigation menu

1.  Click on **+New Registration** in the top breadcrumb navigation

1. Provide the following information:

    - Name: **ar-eastus-k8s-anoa-01** or a name of your liking

    - Supported Account Types: **Accounts in this organizational directory only (... - Single Tenant)**

    - Redirect URI (Optional): **do not configure, leave as default**

    - Click the **Register** button

1. Click on **Overview** in the left navigation and record the following information:

    - Application (client) ID:  **<\< client id \>>**

1. Click on **Certificates & Secrets** in the left navigation

1. Click on **+New Client Secret** and provide the following information:

    - Description: Kubernetes App Registration for ANOA

    - Expires: 3 months or choose an appropriate time for your organization

    - Click the **Add** button

1. Copy and record the Secret ID.  You will use this in your Kubernetes workload deployment.

##### Preparing for Deployment

1. In your PowerShell session Issue **Set-Location -Path 'c:\anoa\src\bicep\enclaves\enclave-scca-hub3spoke-aks'**

1.

##### Deploy Kubernetes Workload

1. In your PowerShell session Issue **Set-Location -Path 'c:\anoa\src\bicep\enclaves\enclave-scca-hub3spoke-aks'**

1. Open the **/parameters/deploy.parameters.json** file and make the following changes:

    - parRequired.orgPrefix: **<<your organization or ANOA (default)>>**

    - parTags.organization: **<<your organization or ANOA (default)>>**

    - parTags.region: **<<your Azure region (eastus, usgovvirginia, etc..)>>**

    - parHub.subscriptionId: **<<subscriptionId>>**

    - parIdentitySpoke.subscriptionId: **<<subscriptionId>>**

    - parOperationsSpoke.subscriptionId: **<<subscriptionId>>**

    - parSharedServicesSpoke.subscriptionId: **<<subscriptionId>>**

    - parAksWorkload.subscriptionId: **<<subscriptionId>>**

    - parKubernetesCluster.aksClusterKubernetesVersion: **1.24.6**

        > NOTE: Issue the command **az aks get-versions --location eastus --query orchestrators[-1].orchestratorVersion --output tsv** to retrieve your regions highest version

    - parKubernetesCluster.aadProfile.aadProfile.TenantId: **<<tenantId>>**

    - parKubernetesCluster.aadProfile.aadProfileAdminGroupObjectIds: **<<objectId of AAD Group>>**

    - parKubernetesCluster.addonProfiles.config.logAnalyticsWorkspaceResourceId: **<<subscriptionId>>**

    - parKubernetesCluster.servicePrincipalProfile.clientId: **<<clientId of AAD App Registration>>**

    - parKubernetesCluster.servicePrincipalProfile.secret: **<<secret of AAD App Registration>>**

1.  Issue the command updating the **--subscription** parameter with your subscription id and the **--location** parameter to your location

    **Azure CLI**
    ``` PowerShell
    az deployment sub create --name 'deploy-scca-enclave-with-aks' --template-file ‘deployCompressed.json' --parameters '@parameters/deploy.parameters.json' --location $location –subscription $context.Subscription.Id --only-show-errors
    ```
    > NOTE: Be sure to review the section **Preparing for Deployment**

##### References
---
[Deploying Management Groups with the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/management-groups)
[Deploying Roles with the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/roles)
[Deploying Policy for Guardrails with the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/Policy)
[Deploying SCCA Compliant Hub and 1-Spoke using the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/platforms/lz-platform-scca-hub-1spoke)
[Deploying a Kubernetes Private Cluster Workload using the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/workloads/wl-aks-spoke)

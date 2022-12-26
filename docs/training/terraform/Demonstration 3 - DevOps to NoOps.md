# Demonstration: Deploy Kubernetes Enclave using Azure DevOps Services with Terraform

Using Azure DevOps Services for an enclave deployment using the NoOps Accelerator for a Azure Kubernetes Service private cluster and mission landing zone.


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

Saving data as variables for use while executing this demonstration or lab will help.  This code below will make executing the commands through PowerShell simpler and recalling these values.

``` PowerShell
az cloudset --name [AzureCloud | AzureGovernment]
az login
$context = Get-AzContext
$location = [your region]
```

### Part 1: Setup Azure DevOps Services

> <span class="note">NOTE</span>: If you are on an Azure government cloud, Azure DevOps Services is not available.  You can access the service, but you will not be able to choose an Azure government region to host your Azure DevOps Services.  In this situation, either deploy Azure DevOps Server as a VM or a physical server in your environment.

> <span class="note">NOTE</span>: If you are using a VM or on-premise Azure DevOps Server, replace **dev.azure.com** with your deployment URL for this demonstration.

---

#### Create an Account or Sign-In to Azure DevOps Services

1. Navigate to [https://dev.azure.com](https://dev.azure.com) and create an account or log in

#### Create a new Project

1. Create a new project with the following settings:

    - Name: **anoa**

    - Description: **Azure NoOps Accelerator**

    - Visibility: **Enterprise** *or* **Private**

    - Advanced:

        - Version Control: **Git**

        - Work item process: **Agile**

#### Download the Azure NoOps Accelerator and Create a Repository

1. Download the latest Azure NoOps Acelerator version from [https://github.com/Azure/NoOpsAccelerator/releases](https://github.com/Azure/NoOpsAccelerator/releases) and unzip to a directory on your computer.  This demonstration uses **c:\anoa** as the root directory.

1. Open PowerShell or your terminal of choice and change to the directory where you unzipped the Azure NoOps Accelerator

    ``` PowerShell
    Set-Location -Path 'c:\anoa'
    ```

1. Issue Git commands to create a repository

    ``` PowerShell
    git init .
    git add *
    git commit -m "Initialized ANOA"
    ```

1. Connect your local repository to Azure DevOps Services and push your changes

    ``` PowerShell
    git remote add origin https://<your login name>@dev.azure.com/<your organization name>/<your project name>/_git/anoa
    git push -u origin --all
    ```

#### OPTIONAL: Setup Areas and Iterations for Incremental Development

> <span class="note">NOTE</span>: This step demonstrates setting up a hierarical backlog using a three week sprint for controlling and releasing changes on a predictable schedule.

1. In Azure DevOps Services, click on **Project Settings** found at the bottom left of the page

1. In the **Boards** section, click on **Project Configuration**

##### OPTIONAL: Setup Areas

> <span class="note">NOTE</span>: Areas are used here to create a hierarchy to show progress and effort roll-up for enterprise reporting.  This is just an example below.  You could also use your archetypes or management groups in Azure as a basis for establishing this structure.

1. Create a new child under **anoa** named **Modern Portfolio**

1. Create a new child under **Modern Portfolio** named **Mission Owner Alpha**

1. Create a new child under **Mission Owner Alpha** named **NoOps Team**

1. Create a new child under **Mission Owner Alpha** named **Application Development Team**

1. Create a new child under **Modern Portfolio** named **Mission Owner Bravo**

##### OPTIONAL: Setup Iterations

1. Click on Iterations found at the top breadcrumb navigation element

1. Delete the pre-configured **Iteration 1**, **Iteration 2**, and **Iteration 3** elements

> <span class="note">NOTE</span>: Adjust the years/dates to represent your current dates

1. Create a new child under **anoa** named **Fiscal Year 2023**

   - Start Date: 7/1/2022

   - End Date: 6/30/2023

1. Create a new child under **Fiscal Year 2022** named **Program Increment 1**

   - Start Date: 7/1/2022

   - End Date:  9/23/2022

        Use this PowerShell snippet to calculate the Program Increment period:

         $d = ([DateTime]'7/1/2022').AddDays(84); while ($d.DayOfWeek -eq "Saturday" -or $d.DayOfWeek -eq "Sunday") { $d = $d.AddDays(1) }; $d

        The $d = ([DateTime]'7/1/2022') part of the PowerShell is the start of the Program Increment.  If you need to make a second Program Increment change the $d = ([DateTime]'7/1/2022') statement to the start of the second Program Increment, for example: $d = ([DateTime]'9/23/2022')

1. Create a new child under **Program Increment 1** named **Sprint 1**

    - Start Date: 7/1/2022

    - End Date: 7/21/2022  **Note:** This is a three week sprint

1. Create the remaning two sprints in **Program Increment 1**:

    - Name: **Sprint 2**

    - Start Date: 7/22/2022

    - End Date: 8/11/2022

    - Name: **Sprint 3**

    - Start Date: 8/12/2022

    - End Date: 9/1/2022

1. Create the **Innovation & Planning Sprint**:

    - Name: IP Sprint

    - Start Date: 9/2/2022

    - End Date: 9/23/2022

##### OPTIONAL: Configure the 'anoa Team' for Iterations and Areas

> <span class="note">NOTE</span>: You would use this process for any other teams created in this project to establish enterprise alingment and autonomy.

1. Click on **Team Configuration** found under the **Boards** heading while in the **Project Configuration**

1. Verify that you have **anoa Team** chosen with the Team Selector on the top-most breadcrump navigation element.

1. Uncheck the box for **Features**

> <span class="note">NOTE</span>: Typically, when establishing enterprise autonomy and alignment, you will not have an Azure Board expose more than one type of backlog item.  A different team would be responsible for creating Features.  Creating Features would happen on the Program Increment Planning sessions.

1. Choose **Bugs are managed with requirements** in the **Working with bugs** section.  This will allow bugs to visually appear on your Azure Board.

1. Click on **Iterations**, then click on **+ Select Iteration(s)** and assign the **anoa Team** only the sprints including the IP sprint

1. Click on **Areas** in the breadcrumb navigation element

1. Click on **change** and navigate the hierarchy and choose **anoa Team**

1. In the area listed below, hover over the area, click the ellipses, then choose **include sub-areas**

1.  You have completed configuration a Team for use with a hierarchy of time and areas.

### OPTIONAL: Part 2: Using Kanban for Change Visibility

This is the entry point for Developers, Cyber, and Operations to shift-left and work together for changes.  A new team will be created called **anoa Team**.  This is an Azure AD backed team.  Add the Developers, Cyber, and Operations persons to this team which will grant access to the repository for changes.

---

#### OPTIONAL: Configure Azure Boards

1. Click on **Boards** found under the **Boards** heading in the left navigation

1. Click on the gear icon located at the top-right of the Azure Board

1. On the **Fields** page, make the following changes:

    - Click on **+ Field** and add **Iteration Path**

    - Check the box to **Show empty fields**

    - Make the same two changes to the **Bug** page (this will be a tab named Bug)

    > <span class="note">NOTE</span>: Bug will only display as a tab here if you have enabled it in one of these areas:
    >
    >  1. Choose **Bugs are managed with requirements** in the **Working with bugs** section while configuring a team, or
    >
    > 1. In the **General** section, the **Working with bugs**, you choose **Bugs are managed with requirements**

1. Click on **Columns** under the **Boards** section and configure:

    - Rename **New** to **Backlog**

    - Rename **Active** to **In-Progress** and split to **doing and done**

    - Delete **Resolved**

1. Click on **Swimlanes** under the **Boards** section and configure:

    - Click on **+ Swimlane** and add a new swimlane named **Architectural**

    - Rename the default swimlane to **Business**

    - Click on **Save and Close** button to return to your configured Azure Board


### Part 3: Deploy Kubernetes Workload using an Enclave

> <span class="note">NOTE</span>: If you have already created the Azure Active Directory group and App Registration you can simply record those values and re-use them in this demonstration.

---

#### Create an Azure Active Directory Group

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

#### Create an App Registration in Azure Active Directory for Kubernetes

1. Return to your Azure Portal

1.  Navigate to your Azure Active Directory

1.  Click on **App Registrations** in the left navigation menu

1.  Click on **+New Registration** in the top breadcrumb navigation

1. Provide the following information:

    - Name: **ar-k8s-dev-eastus-001** or a name of your liking

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

> <span class="note">NOTE</span>: You can also use Azure Key Vault to store these credentials and pull them out in a pipeline.

#### Create an App Registration in Azure Active Directory for Azure DevOps Services

1. Return to your Azure Portal

1.  Navigate to your Azure Active Directory

1.  Click on **App Registrations** in the left navigation menu

1.  Click on **+New Registration** in the top breadcrumb navigation

1. Provide the following information:

    - Name: **ar-adopipeline-dev-eastus-001** or a name of your liking

    - Supported Account Types: **Accounts in this organizational directory only (... - Single Tenant)**

    - Redirect URI (Optional): **do not configure, leave as default**

    - Click the **Register** button

1. Click on **Overview** in the left navigation and record the following information:

    - Application (client) ID:  **<\< client id \>>**

1. Click on **Certificates & Secrets** in the left navigation

1. Click on **+New Client Secret** and provide the following information:

    - Description: **cs-adopipeline-dev-eastus-001**

    - Expires: **3 months or choose an appropriate time for your organization**

    - Click the **Add** button

1. Copy and record the Secret ID.  You will use this in your Azure DevOps Services Pipeline when you create the Service Connection.

> <span class="note">NOTE</span>: You can also use Azure Key Vault to store these credentials and pull them out in a pipeline.

#### OPTIONAL: Implement Kanban for Change Tracking

1. Create a new User Story work item on the Azure Board:

    - Name: **Deploy AKS Enclave**

    - Assigned: **Assign to you**

    - Area: **anoa\Modern Portfolio\Mission Owner Alpha\NoOps Team**

    - Iteration: **anoa\Fiscal Year 2023\Program Increment 1\Sprint 1**

    - Description: **Review, modify, update /src/bicep/enclaves/enclave-scca-hub3spoke-aks/parameters/deploy.parameters.json to support deployment of Azure Kubernetes Service private cluster for workload.**

    - Acceptance Criteria:

        - Azure Key Vault implemented to store credentials and secrets

        - Bastion is accessed using Azure Key Vault

        - Kubernetes Private Cluster is accessible through Bastion

    - Planning:

        - Story Points: **13** (scale is 1,2,3,5,8,13,21 where 1 is easiest and 21 is hardest)

        - Priority: **1** (scale is 1,2,3,4 where 1 is highest and 4 is lowest)

        - Risk: **2 - Medium**

    - Classification

        - Value area: **Architectural**

1. Click **Save and close** to return to the Azure Board

1. Drag the User Story to the **In-Progress - Doing** column in the **Architectural** swimlane

#### OPTIONAL: Decompose the User Story to Supporting Tasks

1. From the Azure Board, hover over the **Deploy AKS Enclave** workitem, then click on the ellipses, and finally click on **Add Task** and add the following tasks:

    - CYBER: Review Azure Key Vault Implementation

    - CYBER: Review VNET Peering to Hub and Firewall

    - OPS: Review Monitor Solution Deployments

    - OPS: Modify Solution Parameter Names

    - DEV: Modify Subscription ID and Tenant ID Values

    - DEV: Modify Object ID and Role ID Values

    > <span class="note">NOTE</span>: You can assign different people to these tasks and operate them on the Task board.  The Task Board is where you run your sprints and manage your sprint backlog.

#### OPTIONAL: Create a Remote Branch to Track Changes

1. From the Azure Boards, choose the **anoa Team** to show the **anoa Team Azure Board**.

1. Open the **Deploy AKS Enclave** work item and click **Create Branch** in the **Development** section

1.  Name the branch **topics/tb-\<id of work item\>**

1.  Return to your PowerShell, or open a PowerShell session, or other terminal with access to use Git and checkout the remote branch:

    ``` PowerShell
    git fetch
    git checkout topics/tb-\<id of work item\>
    ```

    > <span class="note">NOTE</span>: It is good Continuous Integration practice to commit your changes often

    > <span class="note">NOTE</span>: Team members can also branch the Tasks, if used, and make changes to the same file.  If they make changes to the same file in the same location, Git will force a merge confict, otherwise Git's merge process will make every attempt to resolve the merge process.

1. Return to PowerShell and issue **code .** to launch Visual Studio Code in the **c:\anoa** directory

#### Update the deploy.parameters.json File

1. In Visual Studio Code, expand the folders to **/src/bicep/enclaves/enclave-scca-hub3spoke-aks/** and open the **deploy.parameters.json** file

    > <span class="note">NOTE</span>: The **deploy.parameters.json** file is in JSON syntax.  In this document the parameters to change will be referenced in dotted notation.  For example, given this JSON:
    >
    >    "parTags": {
    >        "value": {
    >        "organization": "anoa",
    >        "region": "<<region>>",
    >        "templateVersion": "v1.0",
    >        "deployEnvironment": "dev",
    >        "deploymentType": "NoOpsBicep"
    > }
    >
    > A change to the organiation would be communicated: **parTags.organization**, or a change to the region: **parTags.region**

    > <span class="note">NOTE</span>: You can use the same subscription for the HUB, IDENTITY, OPERATIONS, and SHARED SERVICES

    > <span class="note">NOTE</span>: If you use AZ CLI and login through your Powershell session you can capture most of the values necessary for the changes.  Use the following script to capture the changes:

1. Make the following changes to the **deploy.parameters.json** file:

    - parRequired.orgPrefix = **\<your org prefix or the default 'anoa'\>**

    - parTags.organization = **\<your org prefix or the default ANOA\>**

    - parTags.region = **\<your Azure region (eastus, usgovvirginia, etc...)\>**

    - parHub.subscriptionId = **\<subscription Id to host the HUB spoke\>**

    - parIdentitySpoke.subscriptionId = **\<subscription Id to host the IDENTITY spoke\>**

    - parOperationsSpoke.subscriptionId = **\<subscription Id to host the OPERATIONS spoke\>**

    - parSharedServicesSpoke.subscriptionId = **\<subscription Id to host the SHARED SERVICES spoke\>**

    - parAksWorkload.subscriptionId = **\<subscription Id to host the AKS Private Cluster\>**

    - parKubernetesCluster.aksClusterKubernetesVersion: **1.25.2**

        > <span class="note">NOTE</span>: Issue the command **az aks get-versions --location eastus --query orchestrators[-1].orchestratorVersion --output tsv** to retrieve your regions highest version

    - parKubernetesCluster.aadProfile.aadProfile.TenantId: **<\<tenant Id for this enclave deployment>>**

    - parKubernetesCluster.aadProfile.aadProfileAdminGroupObjectIds: **<\<objectId of AAD Group for Kubernetes Administrators>>**

        > <span class="note">NOTE</span>: See **Part 3: Deploy Kubernetes Workload using an Enclave**, **Create an Azure Active Directory Group** about creating an AAD group for the *parKubernetesCluster.aadProfile.aadProfileAdminGroupObjectIds* configuration element.

    - parKubernetesCluster.addonProfiles.config.logAnalyticsWorkspaceResourceId: **<\<subscriptionId>>**

    - parKubernetesCluster.servicePrincipalProfile.clientId: **<<clientId of AAD App Registration>>**

    - parKubernetesCluster.servicePrincipalProfile.secret: **<\<secret of AAD App Registration>>**

        > <span class="note">NOTE</span>: See **Part 3: Deploy Kubernetes Workload using an Enclave**, **Create an App Registration in Azure Active Directory** about creating an app registration and retrieving the clientId and secret for the *parKubernetesCluster.servicePrincipalProfile.clientId* and the *parKubernetesCluster.servicePrincipalProfile.secret* configuration elements.
        >
        > <span class="note">NOTE</span>: If using **AZ AD SP LIST** for your service principals the **<\<clientId\>>** is the **appId** of the JSON returned from the AZ AD SP LIST command.

    - parNetworkArtifacts.enable = **true**

    - parNetworkArtifacts.keyVaultPolicies = **<\<an array of principles from your Azure AD who will have permissions for keys and secrets>\>**

        > <span class="note">NOTE</span>: Setting *parNetworkArtifacts.enable* to true will create an Azure Key Vault and place the Bastion credentials in this Azure Key Vault.  *parNetworkArtifacts.keyVaultPolicies* is an array of people who will be granted access to the keys and secrets.  Copy the following JSON to grant multiple people access (**make sure there is a comma , after the last brace }**):
        >
        > ``` json
        > {
        >      "objectId": "3c42836c-2712-418f-963b-7a1293d36d63",
        >      "permissions": {
        >        "keys": ["get", "list", "update"],
        >        "secrets": ["get", "list", "set"]
        >      },
        >        "tenantId": "0ff59ae6-406c-4aba-a174-fddb35d8dd6f"
        >    },
        > ```
        >

#### OPTIONAL: Commit the Branch and Merge into Main

1. Return to your PowerShell session or terminal

1. Issue the following commands to commit and push on your branch:

    ``` PowerShell
    git add *
    git commit -m "Updated deploy.parameters.json for AKS Enclave Deployment"
    git push
    ```

    > <span class="note">NOTE</span>: If your following the decomposition process of the **Deploy AKS Enclave** user story your actions have mapped to the tasks in this way:
    >
    > **CYBER: Review Azure Key Vault Implementation**
    > When you enabled Network Artifacts and assigned one or more people permissions to keys/secrets you completed this task.
    >
    > **CYBER: Review VNET Peering to Hub and Firewall**
    > When you updated the subscription Id for the HUB spoke and reviewed the Azure Firewall configuration and VNET peerings with the configuration element: *peerToSpokeVirtualNetwork: true* you completed this task.
    >
    > **OPS: Review Monitor Solution Deployments**
    > When you updated the subscription Id for the OPERATIONS spoke and reviewed the network configuration allowing traffic from spokes you completed this task.
    >
    > **OPS: Modify Diagnostics Logs**
    > When you reviewed the available diagnostics logs in the *parOperationsSpoke* configuration element you completed this task.
    >
    > **DEV: Modify Subscription ID and Tenant ID Values**
    > When you updated deploy.parameters.json with the correct subscription Id's and tenant Id's you completed this task.
    >
    > **DEV: Modify Object ID and Role ID Values**
    > When you created the app registration, and Azure AD group for Kubernetes then updated deploy.parameters.json with those values you completed this task.

1. Return Azure DevOps Services or your Azure DevOps Server

1. In the left navigation under the **Repos** heading, click on **Pull Requests**

1. Your branch will be listed, click on the **Create a pull request** button located to the far right

1. You will be able to review your changes on the **Files** tab.  Return to the **Overview** tab and click the **Create** button to create a pull request

    > <span class="note">NOTE</span>: If you have governance or process around your PR processes engage them here.  For this execise we will be simply approving and completing the PR.

1. Click on the **Approve** button

1. Click on the **Complete** button

1. Click on the **Complete merge** button

    > <span class="note">NOTE</span>: Feel free to use the merge type for your team.  The checkbox to **Delete topics/tb-### after merging** refers ONLY to the remote branch that is on Azure DevOps Services and not any branches on your local computer.  Those must be removed manually after the PR process.

### Part 4: Setup the Azure DevOps Services Pipeline

1. Return to Azure DevOps Services

1. Click on **Project Settings** in the lower left

1. Click on **Service Connections** in the **Pipelines** section on the left

1. Click the **New Service Connection** button in the top right and create a new Service Connection with the following information:

    - Service Connection Type: **Azure Resource Manager**

        > <span class="note">NOTE</span>: Scroll down and click the **Next** button to see the Authentication Method selection.

    - Authentication Method: **Service Principal (manual)**

        - Environment: **Azure Cloud**

        - Scope Level: **Subscription**

        - Subscription ID:  **subscriptionId of the subscription this service connection will access**

        - Service Principal ID: **The *client id* of App Registration** you created in the **Part 3: Deploy Kubernetes Workload using an Enclave, Create an App Registration in Azure Active Directory for Azure DevOps Services** section.

        - Service Principal Key (if using): **The *value* of App Registration's Client Secret** you created in the **Part 3: Deploy Kubernetes Workload using an Enclave, Create an App Registration in Azure Active Directory for Azure DevOps Services** section.

        - Tenant ID: **Tenant ID you are using for your deployment**

        - Service Connection Name: **sc-\<subscription name\>-subscription**

        - Description: **optional if you want a description**

        - Check the Checkbox: **Grant access permissions to all pipelines** (otherwise you will need to authorize this for each pipeline.  Defer to your organization's security and governance for this setting)

        - Click on **Verify and Save**

            > <span class="note">NOTE</span>: If you have any issues, resolve them before proceeding.  The App Registration that is used in this Service Connection must be added to the **OWNERS** role of the subscription.

1. Return to Pipelines, and **Create a New Pipeline**

1.  Copy and Paste the .yaml for the pipeline:

''' yaml

'''

#### References
---
[Deploying Management Groups with the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/management-groups)
[Deploying Roles with the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/roles)
[Deploying Policy for Guardrails with the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/overlays/Policy)
[Deploying SCCA Compliant Hub and 1-Spoke using the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/platforms/lz-platform-scca-hub-1spoke)
[Deploying a Kubernetes Private Cluster Workload using the NoOps Accelerator](https://github.com/Azure/NoOpsAccelerator/tree/main/src/bicep/workloads/wl-aks-spoke)

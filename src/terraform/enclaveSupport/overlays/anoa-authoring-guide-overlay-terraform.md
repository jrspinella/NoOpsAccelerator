# Authoring Guide for Overlays with Terraform

Azure NoOps Accelerator Overlays are self-contained Bicep deployment templates that allows to extend AzResources services with specific configurations or combine them to create more useful objects. Therefore, deploying an overlay will result in an enahancing a Azure landing zone that can be scaled and refined based on business or deployment need.

The goal of this authoring guide is to provide step-by-step instructions to create new and update existing overlays.

## Table of Contents

- [Overlay Authoring Guide](#overlay-authoring-guide)
  - [Table of Contents](#table-of-contents)
  - [Folder structure](#folder-structure)
  - [Create a new overlays](#create-a-new-overlays)
    - [Build new overlays](#build-new-overlays)
    - [Requirements for overlays](#requirements-for-overlays)
    - [Approach](#approach)
  - [Common features](#common-features)

---

## Folder structure

Overlays are located in [`overlays`](../../overlays) folder and organized as folder per overlay.  Here are the current overlays with links to documentation:

- Management Group overlay
  - [`management-groups`](../src/bicep/../../../src/bicep/overlays/management-groups/readme.md) - Deploys a management group hierarchy in a tenant under the `Tenant Root Group`.
- Management Service overlays
  - [`app-service-plan`](../src/bicep/../../../src/bicep/overlays/management-services/app-service-plan/readme.md) - Deploys a app service plan.
  - [`applicationGateway`](../src/bicep/../../../src/bicep/overlays/management-services/applicationGateway/readme.md) - Deploys a application gateway.
  - [`automation`](../src/bicep/../../../src/bicep/overlays/management-services/automation/readme.md) - Deploys a automation account.
  - [`azureSecurityCenter`](../src/bicep/../../../src/bicep/overlays/management-services/azureSecurityCenter/readme.md) - Deploys Azure Security Center.
  - [`bastion`](../src/bicep/../../../src/bicep/overlays/management-services/bastion/readme.md) - Deploys a Bastion host for Remote Access.
  - [`containerRegistry`](../src/bicep/../../../src/bicep/overlays/management-services/containerRegistry/readme.md) - Deploys a Azure Container Registry.
  - [`dataBricksWorkspace`](readme.md) - Deploys a Azure Data Bricks Workspace.
  - [`keyVault`](../src/bicep/../../../src/bicep/overlays/management-services/keyvault/readme.md) - Deploys a Azure Key Vault.
  - [`KubernetesPrivateCluster-Kubenet`](../src/bicep/../../../src/bicep/overlays/management-services/kubernetesPrivateCluster-Kubnet/readme.md) - Deploys a Azure Kubernetes Private Cluster with Kubenet.

- Roles overlay
  - [`roles`](../src/bicep/../../../src/bicep/overlays/roles/readme.md) - Deploys a role definitions in a specific `Management Group`.

---

## Create a new overlays

Overlays are are self-contained Bicep deployment templates that allows you to extend AzResources services with specific configurations or combine them to create more useful objects.

Overlays provide the ability to build new azure resources with an use case specific architecture in a repeatable method. One Overlay can be used to configure many different deployment sceniros.

### Build new overlays

You should develop new overlays when a common deployment need or azure service need emerges within your organization. The return on investment increases when the overlays is used in workloads and deployed to 10s or 100s of subscriptions.

New features can be placed behind feature flags to provide customization/choices of Azure services to configure at deployment time.  For example, we use feature flags to control Bastion and VM Instance deployment in the Remote Access - Bastion Overlay.

The `parRemoteAccess.enable` feature flag for Bastion deployment:

```json
 "parRemoteAccess": {
      "value": {
         "enable": true,
          "bastion": {
            // excluded
          }
      }
 }
```

The `parRemoteAccess.linux.enable` feature flag for VM Instance deployment:

```json
"linux": {
   "enable": true,
   "vmName": "bastion-linux",
  }

"windows": {
   "enable": true,
   "vmName": "bastion-windows",
  }
```

### Requirements for overlays

Each overlay is intended to be self-contained and provides all deployment templates required to deployed to a subscription.

Key requirements for each overlay are:

- overlay folder must contain the overlay name.  For example `app-service-plan`.
- Entrypoint for an overlay is `deploy.bicep`. Every overlay must provide `deploy.bicep` in its respective folder.
- Every overlay must provide `deploy.paramters.json` in its respective parameters folder.
- Deployment must be scoped to `subscription`.  Scope is set in `deploy.bicep` using `targetScope` declaration.

    ```bicep
    targetScope = 'subscription'
    ```

- Implements [common features](#common-features).

### Approach

1. Identify at least 5 use cases that can benefit from an overlay and label all common features.  This is the MVP for the overlay.  An application team would receive the implementation of the MVP features deployed in their subscription. Use case specific features can be added to a deployment by the application team as they adapt their environment.

2. Design what spoke virtual network to support the overlay.  You must consider Hub & Spoke network topology or another network topology.

3. Scaffold the overlay:

      - Create a new folder under `management-services` prefixed with the name.  For example, `sqlServer`.
      - Create `deploy.bicep`, set the `targetScope` as `subscription`
      - Create required parameters for [common features](#common-features)
      - Create a deploy.parameters.json and run a subscription scoped deployment through Azure CLI.

        ```bash
        az deployment sub create --template-file <path to overlay deploy.bicep> --parameters @<path to overlay parameters file> --subscription-id <subscription id> --location eastus
        ```

          This is a validation that the overlay scaffolding is in-place.

4. Add overlay specific deployment instructions and incrementally verify through deployment.

5. Debug deployment failures.

    - Navigate to the subscription in Azure Portal
    - Navigate to **Deployments** under **Settings**
    - Identify the failed deployment step & troubleshoot

6. Update documentation.

## Common features

An overlay can deploy & configure any number of Azure services.  For consistency across all overlays, We recommend the following common features:

- **Required** - all required fields for the deployment module.
- **Resource Tags** - configures tags on resource groups
- **Target Subscription Id** - configures the overlay target subscription.
- **Target Resource Group** - configures the overlay target resource group for the subscription
- **Subscription Role Assignments to Security Groups** - configures role-based access control at subscription scope
- **Hub Subscription Resource Group** - configures Hub subscription resource group
- **Hub VNet Name** - configures Hub subscription Virtual Netwrok Name.
- **Subscription Tags** - configures subscription tags

> **Log Analytics Workspace integration**: `deploy.bicep` must accept an input parameter named `parLogAnalyticsWorkspaceResourceId`. This parameter is used to link Microsoft Defender for Cloud to Log Analytics Workspace.

> **NOTE:** Some overlays will have some or all common features. This is depending on how the overlay is being used.

Input parameters for common features are:

```bicep
// Log Analytics
@description('Log Analytics Resource Id to integrate Microsoft Defender for Cloud.')
param logAnalyticsWorkspaceResourceId string

// Target Resource Group Name
@description('The name of the resource group in which the overlay will be deployed. If unchanged or not specified, the NoOps Accelerator will create an resource group to be used.')
param parTargetResourceGroup string

// Hub Subnet Resource Id
@description('The name of the The Hub Subnet Resource Id')
param parHubSubnetResourceId string

// Hub Virtual Network Name
@description('The Hub Virtual Network Name for the Hub Network.')
param parHubVirtualNetworkName string

// Hub Network Security Group Resource Id
@description('The Hub Network Security Group Resource Id')
param parHubNetworkSecurityGroupResourceId string

@description('Required tags values used with all resources.')
param parTags object

@description('Required values used with all resources.')
param parRequired object
```

These features are packaged into a Bicep module and can be invoked by the overlay (i.e. by `deploy.bicep`).

Example module parameters from `deploy.parameters.json`:

```bicep
// REQUIRED PARAMETERS
"parRequired": {
  "value": {
    "orgPrefix": "anoa",
    "templateVersion": "v1.0",
    "deployEnvironment": "mlz"
  }
}

// REQUIRED TAGS
"parTags": {
  "value": {
    "organization": "anoa",
    "region": "eastus",
    "templateVersion": "v1.0",
    "deployEnvironment": "platforms",
    "deploymentType": "NoOpsBicep"
  }
}
```

---

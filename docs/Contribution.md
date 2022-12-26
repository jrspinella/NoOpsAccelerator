# Contribution Guide

## Contribution scope for Azure NoOps Accelerator

The following is the scope of contributions to this repository:

As the Azure platform evolves and new services and features are validated in production with customers, the design guidelines will be updated in the overall architecture context.

With new Services, Resources, Resource properties and API versions, the implementation guide and reference implementation must be updated as appropriate.
Primarily, the code contribution would be centered on Azure Policy definitions and Azure Policy assignments for for Contoso Implementation.

## Background

> This guidance supports the [Architecture](https://github.com/Azure/NoOpsAccelerator/docs/NoOpsAccelerator-Architecture.md) guidance, it is not a replacement.

The `Azure NoOps Accelerator` repository (this repository) has been created to help guide DOD/Public Sector customers on building self-service infrastucture in their Azure environment. The reference implementation is a flexible foundation that enables users to develop/maintain an opinionated self-service infrastructure into an Azure AD Tenant utilizing [Bicep](https://aka.ms/bicep) as the Infrastructure-as-Code (IaC) tooling and language.

## Ways to Consume Azure NoOps Accelerator

There are various ways to consume the Bicep modules included in `Azure NoOps Accelerator`.

The options are:

- Clone this repository
- Fork & Clone this repository
- Download a `.zip` copy of this repo
- Upload a copy of the locally cloned/downloaded modules to your own:
  - Git Repository
  - Private Bicep Module Registry
    - See:
      - [Azure Landing Zones - Private/Organizational Azure Container Registry Deployment (also known as private registry for Bicep modules)](https://github.com/Azure/NoOpsAccelerator/wiki/ACRDeployment)
      - [Create private registry for Bicep modules](https://docs.microsoft.com/azure/azure-resource-manager/bicep/private-module-registry)
  - Template Specs
    - See:
      - [Azure Resource Manager template specs in Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/template-specs)
- Use and reference the modules directly from the Microsoft Public Bicep Registry - ***Coming Soon (awaiting feature release in Bicep)***

## Recommended Learning

Before you start contributing to the Azure NoOps Accelerator Bicep code, it is **highly recommended** that you complete the following Microsoft Learn paths, modules & courses:

### Bicep

- [Deploy and manage resources in Azure by using Bicep](https://docs.microsoft.com/learn/paths/bicep-deploy/)
- [Structure your Bicep code for collaboration](https://docs.microsoft.com/learn/modules/structure-bicep-code-collaboration/)
- [Manage changes to your Bicep code by using Git](https://docs.microsoft.com/learn/modules/manage-changes-bicep-code-git/)

### Git

- [Introduction to version control with Git](https://docs.microsoft.com/learn/paths/intro-to-vc-git/)

## Tooling

### Required Tooling

To contribute to this project the following tooling is required:

- [Git](https://git-scm.com/downloads)
- [Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#install-manually)
- [Visual Studio Code](https://code.visualstudio.com/download)
  - [Bicep extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)

![Bicep Logo](media/bicep-vs-code.png)

### Recommended Tooling

The following tooling/extensions are recommended to assist you developing for the project:

- [CodeTour extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=vsls-contrib.codetour)
- [ARM Tools extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)
- [ARM Template Viewer extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=bencoleman.armview)
- For visibility of Bracket Pairs:
  - Use an Extension: [Bracket Pair Colorizer 2 extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer-2)
  - Use Native capability:
    - Inside Visual Studio Code, add `"editor.bracketPairColorization.enabled": true` to your settings.json, to enable bracket pair colorization.

## Bicep Formatting Guidelines

The below guidelines should be adhered to whilst contributing to this projects Bicep code.

### Bicep Best Practices

Throughout the development of Bicep code you should follow the [Bicep Best Practices](https://docs.microsoft.com/azure/azure-resource-manager/bicep/best-practices).

> It is suggested to keep this page open whilst developing for easy reference

### Bicep Code Styling

- Camel Casing must be used for all elements:
  - Symbolic names for:
    - Parameters
    - Variables
    - Resource
    - Modules
    - Outputs
- Use [parameter decorators](https://docs.microsoft.com/azure/azure-resource-manager/bicep/parameters#decorators) to ensure integrity of user inputs are complete and therefore enable successful deployment
  - Only use the [`@secure()` parameter decorator](https://docs.microsoft.com/azure/azure-resource-manager/bicep/parameters#secure-parameters) for inputs. Never for outputs as this is not stored securely and will be stored/shown as plain-text!
- Comments should be provided where additional information/description of what is happening is required, except when a decorator like `@description('Example description')` is providing adequate coverage
  - Single-line `// <comment here>` and multi-line `/* <comment here> */` comments are both welcomed
  - Provide contextual public Microsoft documentation recommendation references/URLs in comments to help user understanding of code implementation
- All expressions, used in conditionals and loops, should be stored in a variable to simplify code readability
- Specify default values for all parameters where possible - this improves deployment success
  - The default value should be called out in the description of the parameter for ease of visibility
  - Default values should also be documented in the appropriate location
- Tab indents should be set to `2` for all Bicep files
- Double line-breaks should exist between each element type section
- Each bicep file must contain the below multi-line comment at the very top of the file, with its details filled out:

```bicep
/*
SUMMARY: A short summary of what the Bicep file does/deploys.
DESCRIPTION: A slightly longer description of what the Bicep file does/deploys and any other important information that should be known upfront.
AUTHOR/S: GitHub Usernames
VERSION: 1.0.0
*/

<REST OF BICEP FILE BELOW...>

targetScope = ...

etc...
```

### Bicep Elements Naming Standards

| Element Type | Naming Prefix | Example                                                              |
| :----------: | :-----------: | :------------------------------------------------------------------- |
|  Parameters  |     `par`     | `parLocation`, `parManagementGroupsNamePrefix`                       |
|  Variables   |     `var`     | `varConditionExpression`, `varIntermediateRootManagementGroupName`   |
|  Resources   |     `res`     | `resIntermediateRootManagementGroup`, `resResourceGroupLogAnalytics` |
|   Modules    |     `mod`     | `modManagementGroups`, `modLogAnalytics`                             |
|   Outputs    |     `out`     | `outIntermediateRootManagementGroupID`, `outLogAnalyticsWorkspaceID` |

### Bicep File Structure

For all Bicep files created as part of this project they will follow the structure pattern of being grouped by element type, this is shown in the image below:

![Bicep File Structure By Element Type Image](media/bicep-structure.png)

> Parameters, Variables, Resources, Modules & Outputs are all types of elements.

### Bicep File Structure Example

Below is an example of Bicep file complying with the structure and styling guidelines specified above:

```bicep
/*
SUMMARY: An example deployment of a resource group.
DESCRIPTION: Deploy a resource group to UK south taking a naming prefix as it's only parameter.
AUTHOR/S: jtracey93
VERSION: 1.0.0
*/


// SCOPE
targetScope = 'subscription' //Deploying at Subscription scope to allow resource groups to be created and resources in one deployment


// PARAMETERS
@description('Example description for parameter. - DEFAULT VALUE: "TEST"')
param parExampleResourceGroupNamePrefix string = 'TEST'


// VARIABLES
var varExampleResourceGroupName = 'rsg-${parExampleResourceGroupNamePrefix}' // Create name for the example resource group


// RESOURCE DEPLOYMENTS
resource resExampleResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: varExampleResourceGroupName
  location: 'uksouth' // Hardcoded as an example of commenting inside a resource
}

/*
No modules being deployed in this example
*/


// OUTPUTS
output outResourceGroupExampleID string = resExampleResourceGroup.id

```

## Constructing a Bicep Module

To author Bicep modules that are in-line with the requirements for this project, the following must be true:

- Follows the [Bicep Formatting Guidelines](#bicep-formatting-guidelines) as detailed above
- A new folder per module in the following directory: `infra-as-code/bicep/modules/...`
  - Folder Name will be created with camel case: `infra-as-code/bicep/modules/moduleName`
- Each new module folder must contain:
  - A `media` folder that will contain images used in the `README.md`
  - A `README.md` for each module in the root of its own folder, as above, detailing the module, what it deploys, parameters and any other useful information for consumers.
    - The `README.md` must also contain a Bicep visualizer image of the complete module
  - A `bicepconfig.json` for each module in the root of its own folder.
    - [Bicep Linting Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/linter)
    - The `bicepconfig.json` file should contain the following:

      ```json
            {
              "analyzers": {
                "core": {
                  "enabled": true,
                  "verbose": true,
                  "rules": {
                    "adminusername-should-not-be-literal": {
                      "level": "error"
                    },
                    "no-hardcoded-env-urls": {
                      "level": "error"
                    },
                    "no-unnecessary-dependson": {
                      "level": "error"
                    },
                    "no-unused-params": {
                      "level": "error"
                    },
                    "no-unused-vars": {
                      "level": "error"
                    },
                    "outputs-should-not-contain-secrets": {
                      "level": "error"
                    },
                    "prefer-interpolation": {
                      "level": "error"
                    },
                    "secure-parameter-default": {
                      "level": "error"
                    },
                    "simplify-interpolation": {
                      "level": "error"
                    },
                    "use-protectedsettings-for-commandtoexecute-secrets": {
                      "level": "error"
                    },
                    "use-stable-vm-image": {
                      "level": "error"
                    }
                  }
                }
              }
            }
      ```

  - The Bicep module file & parameters file, complete with default values.

## How to submit Pull Request to upstream repo

Submit a pull request for documentation updates using the following template 'placeholder'.

1. Create a new branch based on upstream/main by executing following command

    ```shell
    git checkout -b feature upstream/main
    ```

2. Checkout the file(s) from your working branch that you may want to include in PR

    ```shell
    #substitute file name as appropriate. below example
    git checkout feature: .\.docs\Deploy\Deploy-lz.md
    ```

3. Push your Git branch to your origin

    ```shell
    git push origin -u
    ```

4. Create a pull request from upstream to your remote main

### Code of Conduct

We are working hard to build strong and productive collaboration with our passionate community. We heard you loud and clear. We are working on set of principles and guidelines with Do's and Don'ts.

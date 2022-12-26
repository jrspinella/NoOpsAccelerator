# Azure NoOps Accelerator Azure Bicep Templates

This folder contains the Azure Bicep templates for deploying Azure NoOps Accelerator modules. See the [Deployment Guide for Bicep](../bicep/examples/deployment-guide-bicep.md) for detailed instructions on how to use the templates.

## Azresources Folder

AzResources folder is the backbone of the NoOps Accelerator.

This folder provides Bicep modules which can be leveraged in your NoOps infrastructure as code projects to accelerate solution development.

The primary aim of AzResources is to provide you with re-usable building blocks, so that you can focus what matter the most.

AzResources are broken into 3 folders:

- Hub/Spoke Core
- Modules
- Overlays

## Overlays folder

The Overlays directory are to show how to add on functionality of Enclaves, Platform and Workload modules.

| Overlay | Description |
| ------- | ----------- |
| [Management Groups](./overlays/management-groups/readme.md) | NoOps Accelerator management groups overlay are templates that may be installed to add custom management groups to an new or existing landing zone or enclave. |
| [Management Services](./overlays/management-services/readme.md) | An established landing zone or enclave can be expanded functionally by adding custom management services using the NoOps Accelerator management services overlay templates. |
| [Policy](./overlays/policy/readme.md) | Based on your Azure Service Catalog, NoOps Accelerator - Azure Policy Initiatives deploys Azure Policy Initiatives, Definitions, and Assignments to a specific Management Group in the Tenant Root. |
| [RBAC (Role Access)](./overlays/roles/readme.md) | NoOps Accelerator RBAC services are templates that can be deployed to extend an existing landing zone or enclave. |

You [must first deploy landing zone or enclave](../../docs/wiki/archetypes/Platform/authoring-guide.md), then you can deploy these overlays.

## Examples folder

The examples folder contains a set of examples that demonstrate how to use the Azure NoOps Accelerator Bicep modules to deploy Mission Envlaves.

## Platforms folder

The Platform Archetype directory allows you to create core modules that will depoyment of a custom landing zone. These modules are used with other modules.

>Example deployments can be an Mission Landing Zone if used with Hub/ 3 Spoke.

## Workloads folder

The Workloads Archetype directory allows you to create core modules that will depoyment of a custom workloads. These modules are used with other modules.

>Example deployments can be an Storage Account to a Shared Services Spoke if used with Hub/ 3 Spoke.

You [must first deploy landing zone or enclave](../../docs/wiki/archetypes/Platform/authoring-guide.md), then you can deploy these workloads.

## References

* [Hub and Spoke network topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
* [Secure Cloud Computing Architecture (SCCA) Functional Requirements Document (FRD)](https://rmf.org/wp-content/uploads/2018/05/SCCA_FRD_v2-9.pdf)

 [//]: # (************************)
 [//]: # (INSERT LINK LABELS BELOW)
 [//]: # (************************)

[mlz_architecture]:                            https://github.com/Azure/missionlz "MLZ Accelerator"
[wiki_deployment_flow]:                        https://github.com/https://github.com/Azure/NoOpsAccelerator/wiki/DeploymentFlow "Wiki - Deployment Flow"

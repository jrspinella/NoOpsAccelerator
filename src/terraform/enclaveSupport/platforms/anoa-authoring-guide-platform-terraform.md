# Azure NoOps Accelerator - Authoring Guide for Platforms with Terraform

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Folder structure](#folder-structure)
- [Planning](#planning)
  - [Requirements for Platforms](#requirements-for-platforms)
- [Create a new Platform](#create-a-new-platform)
- [Cleanup](#cleanup)
- [Development Setup](#development-setup)
- [See Also](#see-also)

## Introduction

The goal of this authoring guide is to provide step-by-step instructions to create new and update existing Platforms with the Azure NoOps Accelerator using the [Terraform](https://www.terraform.io/) template at [src/terraform/](../src/terraform/).

To get started with Terraform on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

## Prerequisites

- Current version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- The version of the [Terraform CLI](https://www.terraform.io/downloads.html) described in the [.devcontainer Dockerfile](../.devcontainer/Dockerfile)
- An Azure Subscription(s) where you or an identity you manage has `Owner` [RBAC permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)

<!-- markdownlint-disable MD013 -->
> NOTE: Azure Cloud Shell is often our preferred place to deploy from because the AZ CLI and Terraform are already installed. However, sometimes Cloud Shell has different versions of the dependencies from what we have tested and verified, and sometimes there have been bugs in the Terraform Azure RM provider or the AZ CLI that only appear in Cloud Shell. If you are deploying from Azure Cloud Shell and see something unexpected, try the [development container](../.devcontainer) or deploy from your machine using locally installed AZ CLI and Terraform. We welcome all feedback and [contributions](../CONTRIBUTING.md), so if you see something that doesn't make sense, please [create an issue](https://github.com/Azure/NoOpsAccelerator/issues/new/choose) or open a [discussion thread](https://github.com/Azure/NoOpsAccelerator/discussions).
<!-- markdownlint-enable MD013 -->

## Folder structure

Platform are located in [`Platform`](../../Platforms) folder and organized as folder per Platform.

Each Platform folder contains the following files:

- `README.md` - Platform description
- `main.tf` - Terraform template
- `variables.tf` - Terraform variables
- `outputs.tf` - Terraform outputs
- `terraform.tfvars` - (Optional)Terraform variables values

## Planning

Before you can build a Platform, you need to plan the what you will be building.

The following questions will help you plan your Platform:

- What is the Platform for?
- What resources will it create?
- What resources will it depend on?
- What resources will it output?

### Requirements for Platforms

Platforms must meet the following requirements:

- Platforms must be self-contained Terraform deployment templates that allows the ability to build new azure resources within an use case specific architecture in a repeatable method.

- Platforms must be able to be used in a modular fashion to build out a larger enclave architecture.

## Create a new Platform

One Platform template can be used to configure many different deployment scenirios.

To create a new Platform, follow these steps:

1. Create a new folder in [`Platform`](../../Platforms) folder with the name of your Platform.

2. Create a `README.md` file in your Platform folder and add a description of your Platform.

3. Create a file called `main.tf` and add the following code to it:

```hcl
# Configure the Azure provider
provider "azurerm" {
  environment     = var.environment
  metadata_host   = var.metadata_host
  subscription_id = var.hub_subid

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "random" {
}

provider "time" {
}

data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current_client" {
}
```

4. Create a `variables.tf` file in your Platform folder and add the following content:

```hcl

```

5. Create a `outputs.tf` file in your Platform folder and add the following content:

```hcl

```

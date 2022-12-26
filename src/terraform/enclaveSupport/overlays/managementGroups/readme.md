# Terraform Enclave Support Overlays Folders

## Overview

## Management Groups Folder

Management Groups is the basis on creating a modular Management Groups network designs. This core is used in Mission Enclave creations.

## Management Groups Folder Structure

The Management Groups folder structure is as follows:

```bash
├───managementGroups
│   ├───main.tf
│   ├───outputs.tf
│   └───variables.tf
└───readme.md
```

## Management Groups Modules

The Management Groups modules are as follows:

### Main

The main module is used to create the Management Groups.

```hcl
module "managementGroups" {
  source = "./managementGroups"
  managementGroups = var.managementGroups
}
```

## Inputs

The following table lists the configurable parameters of the Management Groups module and their default values.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| managementGroups | The Management Groups to create | list | n/a | yes |

## Outputs

The following table lists the outputs of the Management Groups module.

| Name | Description |
|------|-------------|
| managementGroups | The Management Groups created |

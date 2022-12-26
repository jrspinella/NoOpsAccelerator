# Terraform Enclave Support Overlays Folders

## Overview

## Roles Folder

Roles is the basis on creating a modular Roles network designs. This core is used in Mission Enclave creations.

## Roles Folder Structure

The Roles folder structure is as follows:

```bash
├───roles
│   ├───main.tf
│   ├───outputs.tf
│   └───variables.tf
└───readme.md
```

## Roles Modules

The Roles modules are as follows:

### Main

The main module is used to create the Roles.

```hcl
module "roles" {
  source = "./roles"
  roles = var.roles
}
```

## Inputs

The following table lists the configurable parameters of the Roles module and their default values.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| roles | The Roles to create | list | n/a | yes |

## Outputs

The following table lists the outputs of the Roles module.

| Name | Description |
|------|-------------|
| roles | The Roles created |



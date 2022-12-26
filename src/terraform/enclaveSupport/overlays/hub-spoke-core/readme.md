# Terraform Enclave Support Overlays Folders

## Overview

## Hub Spoke Core Folder

Hub/ Spoke Core is the basis on creating a modular Hub/Spoke network designs. This core is used in Platform Landing Zone creations. Each module in the core is designed to be deploy together or individually.

## Hub Spoke Core Folder Structure

The Hub Spoke Core folder structure is as follows:

```bash
├───hub-spoke-core
│   ├───peering
│   │   ├───main.tf
│   │   ├───outputs.tf
│   │   └───variables.tf
│   ├───vdms
|   |   ├───dataSharedServices
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───logging
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───operations
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───sharedServices
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
│   ├───vdss
|   |   ├───firewall
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───hub
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───identity
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
|   |   ├───networkArtifacts
│   │   |   ├───main.tf
│   │   |   ├───outputs.tf
│   │   |   └───variables.tf
└───readme.md
```

## Hub Spoke Core Modules

The Hub Spoke Core modules are as follows:

### Peering

The peering module is used to create a peering between the hub and spoke virtual networks.

### VDMS/VDSS

The VDMS module is used to create a virtual network with the following resources:

* Virtual Network
* Subnets
* Network Security Groups
* Network Security Group Rules
* Route Tables
* Route Table Routes
* Virtual Network Peering


# Azure NoOps Accelerator - Deployment Guide for Bicep

## Table of Contents

- [Prerequisites](#prerequisites)
- [Planning](#planning)
- [Deployment](#deployment)
- [Cleanup](#cleanup)
- [Development Setup](#development-setup)
- [See Also](#see-also)

This guide describes how to deploy modules with the Azure NoOps Accelerator using the [Azure Bicep](https://www.terraform.io/) template at [src/bicep/](../src/bicep/).

To get started with Azure Bicep on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

Below is an example of a Azure Bicep deployment of the Mission Enclave that uses all the defaults.

```bash
cd src/terraform/platforms/hub3spoke
terraform init
terraform plan # use if you would like to see output of what is beign deployed
terraform apply # supply some parameters, approve, copy the output values
cd src/terraform/workloadSpoke
terraform init
terraform apply # supply some parameters, approve
```

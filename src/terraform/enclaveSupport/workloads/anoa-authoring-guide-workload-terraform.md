# Azure NoOps Accelerator - Authoring Guide for Platforms with Terraform

Azure NoOps Accelerator Workloads are self-contained Terraform deployment templates that allows to extend AzResources services and Overlays with specific configurations or combine them to create more useful objects.

The goal of this authoring guide is to provide step-by-step instructions to create new and update existing Workloads.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Overview](#overview)
- [Planning](#planning)
- [Deployment](#deployment)
- [Cleanup](#cleanup)
- [Development Setup](#development-setup)
- [See Also](#see-also)

This guide describes how to deploy modules with the Azure NoOps Accelerator using the [Terraform](https://www.terraform.io/) template at [src/terraform/](../src/terraform/).

To get started with Terraform on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

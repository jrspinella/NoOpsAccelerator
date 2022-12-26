# Demonstration: Create and Deploy Policy for Mission Enclave using Azure NoOps Accelerator and Terraform

A step-by-step creation and deployment of Policy for an Mission Enclave using the Azure NoOps Accelerator.

## Prerequisites

- [ ] [Azure NoOps Accelerator]()
- [ ] [Terraform]()
- [ ] [Azure CLI]()


## Part 1: Create and Deploy Policy for Mission Enclave using Azure NoOps Accelerator and Terraform

> NOTE: If you have already created the Azure Active Diretory group and App Registration you can simply record those values and re-use them in this demonstration.

### OPTIONAL

Saving data as variables for use while executing this demonstration or lab.  This will make executing the commands through PowerShell simpler.

``` PowerShell
az cloudset --name [AzureCloud | AzureGovernment]

az login

$context = Get-AzContext

$location = [your region]
```

## Achieving Continuous Compliance

Azure Policy is a service in Azure that you can use to create, assign, and manage policies. A policy is a statement that, when enforced, controls the behavior of resources in your subscription. For example, you can use policies to enforce that your resources are deployed in a specific location, that they use a specific size, or that they have a specific tag. You can also use policies to enforce that your resources meet your organization's compliance requirements.




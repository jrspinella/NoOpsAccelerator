# GitHub Onboarding Setup Guide

## Introduction

This document provides steps required to onboard an Mission Enclaves to Azure using GitHub Actions.

All steps will need to be repeated per Azure AD tenant.

## Deployment Flow

This deployment diagram is a high-level overview of the deployment flow. The diagram is not intended to be a step-by-step guide.

### High Level Flow

![High Level Flow](./images/high-level-flow.png)

## Instructions

* Step 1 - Create Service Principal Account & Assign RBAC Roles
* Step 2 - Configure GitHub
* Step 3 - Configure Management Groups

### 1. Create Service Principal Account & Assign RBAC Roles

#### 1.1. Create a Service Principal

Create a Service Principal in Azure Active Directory (AAD) for the GitHub Actions workflow to use. This Service Principal will be used to authenticate to Azure and deploy the resources. The Service Principal will need the following permissions:

- `Contributor` on the subscription
- `User Access Administrator` on the subscription

#### 1.1. Create a Service Principal

1. Login to the Azure Portal
1. Navigate to the Azure Active Directory blade
1. Select `App Registrations` from the left-hand menu
1. Click `New Registration`
1. Enter a name for the Service Principal
1. Select `Accounts in this organizational directory only` for the supported account types
1. Click `Register`

#### 1.2. Assign the Service Principal the `Contributor` role

1. Navigate to the `Subscriptions` blade
1. Select the subscription you want to deploy to
1. Click `Access control (IAM)`
1. Click `Add`
1. Select `Add role assignment`
1. Select `Contributor` for the role
1. Select the Service Principal you created in the previous step for the assignee

#### 1.3. Assign the Service Principal the `User Access Administrator` role

1. Navigate to the `Subscriptions` blade
1. Select the subscription you want to deploy to
1. Click `Access control (IAM)`
1. Click `Add`
1. Select `Add role assignment`
1. Select `User Access Administrator` for the role
1. Select the Service Principal you created in the previous step for the assignee

#### 1.4. Create a Secret for the Service Principal

1. Navigate to the `App Registrations` blade
1. Select the Service Principal you created in the previous step
1. Click `Certificates & secrets`
1. Click `New client secret`
1. Enter a description for the secret
1. Select `Never` for the expiration
1. Click `Add`
1. Copy the secret value and save it for later




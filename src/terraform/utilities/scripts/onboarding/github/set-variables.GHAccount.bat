@echo off
REM // ----------------------------------------------------------------------------------
REM // Copyright (c) Microsoft Corporation.
REM // Licensed under the MIT license.
REM //
REM // THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
REM // EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES
REM // OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
REM // ----------------------------------------------------------------------------------

REM Azure AD tenant GUID
set GH_TENANT_ID=

REM Azure AD tenant root management group name
set GH_MGMT_GROUP_NAME=Tenant Root Group

REM Azure service principal name for 'Owner' RBAC at tenant root scope
set GH_SP_NAME=spn-azure-platform-ops

REM Azure security group name for 'Owner` RBAC subscription, network, and logging
set GH_SG_NAME=alz-owners

REM Azure GH organization URL
set GH_ORG=

REM Azure GH project name (prefer no spaces)
set GH_PROJECT_NAME=

REM Repository name or URL
set GH_REPO_NAME_OR_URL=

REM Repository type: 'tfsgit' or 'github'
set GH_REPO_TYPE=github

REM Repository branch name (default)
set GH_REPO_BRANCH=main

REM Azure GH pipeline name suffix (default)
set GH_PIPELINE_NAME_SUFFIX=-ci

REM Azure GH service endpoint name (service connection in project settings)
set GH_SE_NAME=spn-azure-platform-ops

REM Azure GH service endpoint template file (generated)
set GH_SE_TEMPLATE=service-endpoint.GH-ACCOUNT.json

REM Do not change this value (hard-coded in YAML pipeline definition)
set GH_VARIABLES_GROUP_NAME=firewall-secrets

REM Are variables in the firewall-secrets group marked as secret? 'true' or 'false'.
set GH_VARIABLES_ARE_SECRET=true

REM Folder path for generated output files
set GH_OUTPUT_DIR=.\output

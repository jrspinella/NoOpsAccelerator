// ----------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. Licensed under the MIT license.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
// ----------------------------------------------------------------------------------

targetScope = 'managementGroup'

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = deployment().location

@description('Management Group varScope for the policy assignment.')
param parPolicyAssignmentManagementGroupId string

@allowed([
  'Default'
  'DoNotEnforce'
])
@description('Policy set assignment enforcement mode.  Possible values are { Default, DoNotEnforce }.  Default value:  Default')
param parEnforcementMode string = 'Default'

@description('An array of allowed Azure Regions.')
param allowedLocations array

// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../../../azresources/Modules/Global/partnerUsageAttribution/telemetry.json'))
resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.policy}-${uniqueString(deployment().name, parLocation)}'
  location: parLocation
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

var scope = tenantResourceId('Microsoft.Management/managementGroups', parPolicyAssignmentManagementGroupId)

resource resRgLocationAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'locrg-${uniqueString('rg-location-', parPolicyAssignmentManagementGroupId)}'
  properties: {
    displayName: 'Restrict to West US and East US regions for Resources'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
    scope: scope
    notScopes: []
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
    enforcementMode: parEnforcementMode
  }
  location: parLocation
}

resource resResourceLocationAssignment 'Microsoft.Authorization/policyAssignments@2020-03-01' = {
  name: 'locr-${uniqueString('resource-location-', parPolicyAssignmentManagementGroupId)}'
  properties: {
    displayName: 'Restrict to West US and East US regions for Resources'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    scope: scope
    notScopes: []
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
    enforcementMode: parEnforcementMode
  }
  location: parLocation
}

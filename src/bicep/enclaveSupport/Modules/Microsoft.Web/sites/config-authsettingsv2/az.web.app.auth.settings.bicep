/* Copyright (c) Microsoft Corporation. Licensed under the MIT license. */
// ================ //
// Parameters       //
// ================ //
@description('Conditional. The name of the parent site resource. Required if the template is used in a standalone deployment.')
param appName string

@description('Required. Type of site to deploy.')
@allowed([
  'functionapp'
  'functionapp,linux'
  'app'
])
param kind string

@description('Required. The auth settings V2 configuration.')
param authSettingV2Configuration object

// =========== //
// Existing resources //
// =========== //
resource app 'Microsoft.Web/sites@2020-12-01' existing = {
  name: appName
}

// =========== //
// Deployments //
// =========== //

resource appSettings 'Microsoft.Web/sites/config@2020-12-01' = {
  name: 'authsettingsV2'
  kind: kind
  parent: app
  properties: authSettingV2Configuration
}

// =========== //
// Outputs     //
// =========== //
@description('The name of the site config.')
output name string = appSettings.name

@description('The resource ID of the site config.')
output resourceId string = appSettings.id

@description('The resource group the site config was deployed into.')
output resourceGroupName string = resourceGroup().name

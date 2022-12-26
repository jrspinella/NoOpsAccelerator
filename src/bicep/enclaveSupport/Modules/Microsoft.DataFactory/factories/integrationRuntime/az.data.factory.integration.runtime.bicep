/* Copyright (c) Microsoft Corporation. Licensed under the MIT license. */
@description('Conditional. The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment.')
param dataFactoryName string

@description('Required. The name of the Integration Runtime.')
param name string

@allowed([
  'Managed'
  'SelfHosted'
])
@description('Required. The type of Integration Runtime.')
param type string

@description('Optional. The name of the Managed Virtual Network if using type "Managed" .')
param managedVirtualNetworkName string = ''

@description('Required. Integration Runtime type properties.')
param typeProperties object

var managedVirtualNetwork_var = {
  referenceName: type == 'Managed' ? managedVirtualNetworkName : null
  type: type == 'Managed' ? 'ManagedVirtualNetworkReference' : null
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: name
  parent: dataFactory
  properties: {
    type: any(type)
    managedVirtualNetwork: type == 'Managed' ? managedVirtualNetwork_var : null
    typeProperties: typeProperties
  }
}

@description('The name of the Resource Group the Integration Runtime was created in.')
output resourceGroupName string = resourceGroup().name

@description('The name of the Integration Runtime.')
output name string = integrationRuntime.name

@description('The resource ID of the Integration Runtime.')
output resourceId string = integrationRuntime.id

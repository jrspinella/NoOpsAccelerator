/* Copyright (c) Microsoft Corporation. Licensed under the MIT license. */
@description('Required. Name of the private link service to create.')
param privateLinkScopeName string

@description('Required. Name of the private link service resource to create.')
param privateLinkScopeResourceName string

@description('Required. Resource ID of the linked resource.')
param linkedResourceId string

resource privateLinkScopedResource 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: '${privateLinkScopeName}/${privateLinkScopeResourceName}'
  properties: {
    linkedResourceId: linkedResourceId
  }
}

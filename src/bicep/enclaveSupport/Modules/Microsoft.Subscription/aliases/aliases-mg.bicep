/* Copyright (c) Microsoft Corporation. Licensed under the MIT license. */
targetScope = 'tenant'
param subscriptionAliasName string
param billingScope string
@allowed([
  'Platform'
  'Test'
  'Development'
])
param workload string

resource subscriptionAlias 'Microsoft.Subscription/aliases@2019-10-01-preview' = {
  name: subscriptionAliasName
  properties: {
    workload: workload 
    billingScope: billingScope
    displayName: subscriptionAliasName     
  }  
}

output subId string = split(subscriptionAlias.properties.subscriptionId,'/')[1]

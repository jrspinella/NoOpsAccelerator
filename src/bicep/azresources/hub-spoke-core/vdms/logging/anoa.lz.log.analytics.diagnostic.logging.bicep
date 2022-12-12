/*
SUMMARY: Module to deploy a diagnostic setting to collect the Log Analytics workspace's own diagnostics to itself and to storage.
DESCRIPTION: The following components will be options in this deployment
              Diagnostic Logging
AUTHOR/S: jrspinella
*/

/*
Copyright (c) Microsoft Corporation. Licensed under the MIT license.
*/

@description('The name of the Storage Account to which you would like to collect diagnostic logs.')
param diagnosticStorageAccountName string

@description('The name of the Log Analytics workspace to which you would like to send diagnostic logs.')
param logAnalyticsWorkspaceName string

@description('List of clouds that support Log Analytics Diagnostics')
param supportedClouds array = [
  'AzureCloud'
  'AzureUSGovernment'
]

//// Getting the Log Analytics workspace to which you would like to send diagnostic logs
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

//// Getting the Storage Account to which you would like to collect diagnostic logs
resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: diagnosticStorageAccountName
}

//// Setting log analytics to collect its own diagnostics to itself and to storage
resource logAnalyticsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (contains(supportedClouds, environment().name)) {
  name: 'enable-log-analytics-diagnostics'
  scope: logAnalyticsWorkspace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: stg.id
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

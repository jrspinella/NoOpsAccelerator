# Telemetry Tracking Using Customer Usage Attribution (PID)

Microsoft can identify the deployments of the Azure Resource Manager templates with the deployed Azure resources. Microsoft can correlate these resources used to support the deployments. Microsoft collects this information to provide the best experiences with their products and to operate their business. The telemetry is collected through [customer usage attribution](https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution). The data is collected and governed by Microsoft's privacy policies, located at the [trust center](https://www.microsoft.com/trustcenter).

To disable this tracking, we have included a telmetry config called `telmetry.json` to every bicep module in this repo with a simple boolean flag. The default value `false` which **does not** disable the telemetry. If you would like to disable this tracking, then simply set this value to `true` and this module will not be included in deployments and **therefore disables** the telemetry tracking.

If you are happy with leaving telemetry tracking enabled, no changes are required. Please do not edit the module name or value of the variable `cuaID` in any module.

For example, in the managementGroups.bicep file, you will see the following:

```bicep
// Telemetry - Azure customer usage attribution
// Reference:  https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution
var telemetry = json(loadTextContent('../../azresources/Modules/Global/telemetry.json'))
module telemetryCustomerUsageAttribution '../../azresources/Modules/Global//partnerUsageAttribution/customer-usage-attribution-management-group.bicep' = if (telemetry.customerUsageAttribution.enabled) {
  name: 'pid-${telemetry.customerUsageAttribution.modules.managementGroups}'
}
```

The default value is `true`, but by changing the parameter value `true` and saving this file, when you deploy this module either via PowerShell, Azure CLI, or as part of a pipeline the module deployment below will be ignored and therefore telemetry will not be tracked.

```bicep
// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../CRML/customerUsageAttribution/cuaIdTenant.bicep' = if (!parTelemetryOptOut) {
  name: 'pid-${varCuaid}-${uniqueString(deployment().location)}'
  params: {}
}
```

## Module PID Value Mapping

The following are the unique ID's (also known as PIDs) used in each of the modules:

| Module Name                     | PID                                  |
| ------------------------------- | ------------------------------------ |
| managementGroups                | 55a992b5-9ab1-4b3c-8c14-a9a3e5c1e0c2 |
| policy                          | 3b7f335c-5580-4035-bc75-c835c15402da |
| roleAssignments                 | 5dd6ad4b-bc45-4346-9189-7bc46477182a |
| hubSpoke - Orchestration        | 50ad3b1a-f72c-4de4-8293-8a6399991beb |
| hubPeeredSpoke - Orchestration  | 8ea6f19a-d698-4c00-9afb-5c92d4766fd2 |
| SubPlacementAll - Orchestration | bb800623-86ff-4ab4-8901-93c2b70967ae |
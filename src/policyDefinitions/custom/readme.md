# Policy as Code - Custom Policy Definition Library

## Categories

- [Automation](#Automation)
- [Compute](#Compute)
- [General](#General)
- [Monitoring](#Monitoring)
- [Network](#Network)
- [Security Center](#Security-Center)
- [Storage](#Storage)
- [Tags](#Tags)

## Definitions

### Automation

#### [onboard_to_automation_dsc_linux](./Automation/onboard_to_automation_dsc_linux.json)

| Title | Description |
| ----- | ----------- |
| Name                | onboard_to_automation_dsc_linux |
| DisplayName         | Onboard Azure VM and Arc connected Linux machines to Azure Automation DSC |
| Description         | Deploys the DSC extension to onboard Linux nodes to Azure Automation DSC. Assigns a configuration. |
| Version             | 2.0.0 |
| Effect              | [parameters('effect')] |

### Parameters

| Name | Description | Default Value | Allowed Values |
| ---- | ----------- | ------------- | -------------- |
| effect | Enable or disable the execution of the policy | DeployIfNotExists | DeployIfNotExists Disabled |
| automationAccountId | Automation Account Id. If this account is outside of the scope of the assignment you must manually grant 'Contributor' permissions (or similar) on the Automation account to the policy assignment's principal ID. |  |  |
| nxNodeConfigurationName | Specifies the node configuration in the Automation account to assign to the node. NOTE: will auto-suffix '.localhost'. |  |  |
| nodeConfigurationMode | Specifies the mode for LCM. Valid options include ApplyOnly, ApplyandMonitor, and ApplyandAutoCorrect. The default value is ApplyAndAutoCorrect. | ApplyAndAutoCorrect | ApplyAndAutoCorrect applyAndMonitor ApplyOnly |
| listOfImageIdToInclude_linux | Example value: '/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage' |  |  |

<br>

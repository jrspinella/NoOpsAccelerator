terraform {
  required_providers {
     azurerm = {
      source = "hashicorp/azurerm"
    }
  }

}

locals {
  # assignment_name will be trimmed if exceeds 24 characters
  assignment_name = try(lower(substr(coalesce(var.assignment_name, var.initiative.name), 0, 24)), "")
  display_name = try(coalesce(var.assignment_display_name, var.initiative.display_name), "")
  description = try(coalesce(var.assignment_description, var.initiative.description), "")
  metadata = jsonencode(try(coalesce(var.assignment_metadata, jsondecode(var.initiative.metadata)), {}))

  # convert assignment parameters to the required assignment structure
  parameter_values = var.assignment_parameters != null ? {
    for key, value in var.assignment_parameters :
    key => merge({ value = value })
  } : null

  # merge effect and parameter_values if specified, will use definition default effects if omitted
  parameters = local.parameter_values != null ? var.assignment_effect != null ? jsonencode(merge(local.parameter_values, { effect = { value = var.assignment_effect } })) : jsonencode(local.parameter_values) : null

  # create the optional non-compliance message content block(s) if present
  non_compliance_message = var.non_compliance_messages != {} ? {
    for reference_id, message in var.non_compliance_messages :
    reference_id => message
  } : {}

  # determine if a managed identity should be created with this assignment
  identity_type = length(try(coalescelist(var.role_definition_ids, try(var.initiative.role_definition_ids, [])), [])) > 0 ? { type = "SystemAssigned" } : {}

  # try to use policy definition roles if explicit roles are ommitted
  role_definition_ids = var.skip_role_assignment == false ? try(coalescelist(var.role_definition_ids, try(var.initiative.role_definition_ids, [])), []) : []

  # evaluate policy assignment scope from resource identifier
  assignment_scope = try({
    mg       = length(regexall("(\\/managementGroups\\/)", var.assignment_scope)) > 0 ? 1 : 0,
    sub      = length(split("/", var.assignment_scope)) == 3 ? 1 : 0,
    rg       = length(regexall("(\\/managementGroups\\/)", var.assignment_scope)) < 1 ? length(split("/", var.assignment_scope)) == 5 ? 1 : 0 : 0,
    resource = length(split("/", var.assignment_scope)) >= 6 ? 1 : 0,
  })

  # evaluate remediation scope from resource identifier
  remediation_scope = try(coalesce(var.remediation_scope, var.assignment_scope), "")
  remediate = try({
    mg       = length(regexall("(\\/managementGroups\\/)", local.remediation_scope)) > 0 ? 1 : 0,
    sub      = length(split("/", local.remediation_scope)) == 3 ? 1 : 0,
    rg       = length(regexall("(\\/managementGroups\\/)", local.remediation_scope)) < 1 ? length(split("/", local.remediation_scope)) == 5 ? 1 : 0 : 0,
    resource = length(split("/", local.remediation_scope)) >= 6 ? 1 : 0,
  })

  # retrieve definition references & create a remediation task for policies with DeployIfNotExists and Modify effects
  definitions = var.skip_remediation == false && length(local.identity_type) > 0 ? try(var.initiative.policy_definition_reference, []) : []
  definition_reference = try({
    mg       = local.remediate.mg > 0 ? local.definitions : []
    sub      = local.remediate.sub > 0 ? local.definitions : []
    rg       = local.remediate.rg > 0 ? local.definitions : []
    resource = local.remediate.resource > 0 ? local.definitions : []
  })

  # evaluate outputs
  assignment = try(
    azurerm_management_group_policy_assignment.set[0],
    azurerm_subscription_policy_assignment.set[0],
    azurerm_resource_group_policy_assignment.set[0],
    azurerm_resource_policy_assignment.set[0],
  "")
  remediation_tasks = try(
    azurerm_management_group_policy_remediation.rem,
    azurerm_subscription_policy_remediation.rem,
    azurerm_resource_group_policy_remediation.rem,
    azurerm_resource_policy_remediation.rem,
  {})
}

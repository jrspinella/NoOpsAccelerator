# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mgmt_group" {
  source   = "../../modules/Microsoft.Management/managementGroups"
  for_each = var.management_groups

  management_group_name      = each.management_group_name
  display_name               = each.display_name
  parent_management_group_id = each.parent_management_group_id
  subscription_ids           = each.subscription_ids
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

output "management_group_name" {
  value = module.mgmt_group.management_group_name
}

output "management_group_id" {
  value = module.mgmt_group.management_group_id
}

output "parent_management_group_id" {
  value = module.mgmt_group.parent_management_group_id
}

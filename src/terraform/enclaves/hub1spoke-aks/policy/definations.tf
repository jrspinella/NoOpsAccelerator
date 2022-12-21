##################
# General
##################
module "deny_resources_types" {
  source              = "../../../azresources/modules/Microsoft.Authorization/policyDefination"
  policy_name         = "deny_resources_types"
  display_name        = "Deny Azure Resource types"
  policy_category     = "General"
  management_group_id = data.azurerm_management_group.org.id
}

module "whitelist_regions" {
  source              = "../../../azresources/modules/Microsoft.Authorization/policyDefination"
  policy_name         = "whitelist_regions"
  display_name        = "Whitelist Azure Regions"
  policy_category     = "General"
  management_group_id = data.azurerm_management_group.org.id
}

##################
# Monitoring
##################

# create definitions by looping around all files found under the Monitoring category folder
module "deploy_resource_diagnostic_setting" {
  source              = "../../../azresources/modules/Microsoft.Authorization/policyDefination"
  for_each            = toset([for p in fileset(path.cwd, "../policies/Monitoring/*.json") : trimsuffix(basename(p), ".json")])
  policy_name         = each.key
  policy_category     = "Monitoring"
  management_group_id = data.azurerm_management_group.org.id
}

##################
# Network
##################
module "deny_nic_public_ip" {
  source              = "../../../azresources/modules/Microsoft.Authorization/policyDefination"
  policy_name         = "deny_nic_public_ip"
  display_name        = "Network interfaces should not have public IPs"
  policy_category     = "Network"
  management_group_id = data.azurerm_management_group.org.id
}

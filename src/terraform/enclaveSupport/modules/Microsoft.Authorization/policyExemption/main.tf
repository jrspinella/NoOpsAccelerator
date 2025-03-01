terraform {
  required_providers {
     azurerm = {
      source = "hashicorp/azurerm"
    }
  }

}

locals {
  # import the custom policy object from a library or specified file path
  policy_object = jsondecode(coalesce(try(
    file(var.file_path),
    file("${path.cwd}/policies/${title(var.policy_category)}/${var.policy_name}.json"),
    file("${path.root}/policies/${title(var.policy_category)}/${var.policy_name}.json"),
    file("${path.root}/../policies/${title(var.policy_category)}/${var.policy_name}.json"),
    file("${path.module}/../../policies/${title(var.policy_category)}/${var.policy_name}.json")
  )))

  # fallbacks
  title = title(replace(local.policy_name, "/-|_|\\s/", " "))
  category = coalesce(var.policy_category, try((local.policy_object).properties.metadata.category, "General"))
  version = coalesce(var.policy_version, try((local.policy_object).properties.metadata.version, "1.0.0"))

  # use local library attributes if runtime inputs are omitted
  policy_name = coalesce(var.policy_name, try((local.policy_object).name, null))
  display_name = coalesce(var.display_name, try((local.policy_object).properties.displayName, local.title))
  description = coalesce(var.policy_description, try((local.policy_object).properties.description, local.title))
  metadata = coalesce(var.policy_metadata, try((local.policy_object).properties.metadata, merge({ category = local.category },{ version = local.version })))
  parameters = coalesce(var.policy_parameters, try((local.policy_object).properties.parameters, null))
  policy_rule = coalesce(var.policy_rule, try((local.policy_object).properties.policyRule, null))

  # manually generate the definition Id to prevent "Invalid for_each argument" on set_assignment plan/apply
  definition_id = var.management_group_id != null ? "${var.management_group_id}/providers/Microsoft.Authorization/policyDefinitions/${local.policy_name}" : azurerm_policy_definition.def.id
}

<!-- markdownlint-configure-file { "MD004": { "style": "consistent" } } -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <h1 align="center">Azure Policy as Code with Azure NoOps Accelerator</h1>
  <p align="center">
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-orange.svg" alt="MIT License"></a>
    <img src="https://img.shields.io/badge/Open%20in-VSCode-1f425f.svg" alt="Open in Visual Studio Code"></a></br>
    <a href="https://github.com/gettek/terraform-azurerm-policy-as-code/discussions"><img src="https://img.shields.io/badge/topic-discussions-yellowgreen.svg" alt="Go to topic discussions"></a>
  </p>
</p>
<!-- markdownlint-enable MD033 -->

- [Repo Folder Structure](#repo-folder-structure)

## Repo Folder Structure

## Custom Policy Definitions Module

This module depends on populating `var.policy_name` and `var.policy_category` to correspond with the respective custom policy definition `json` file found in the [local library](policies). You can also parse in other template files and data sources at runtime, see the [definition module readme](modules/definition) for examples and acceptable inputs.

```hcl
module whitelist_regions {
  source              = "../policy/custom/"
  version             = "2.6.5"
  policy_name         = "whitelist_regions"
  display_name        = "Allow resources only in whitelisted regions"
  policy_category     = "General"
  management_group_id = data.azurerm_management_group.org.id
}
```

> [Microsoft Docs: Azure Policy definition structure](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure)

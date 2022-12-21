

resource "azurerm_firewall_policy" "firewallpolicy" {
  name                     = var.firewall_policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.firewall_sku
  threat_intelligence_mode = "Alert"
}

resource "azurerm_firewall_policy_rule_collection_group" "firewallpolicyrulecollectiongroup" {
  name               = var.firewall_policy_collection_group_name
  firewall_policy_id = azurerm_firewall_policy.firewallpolicy.id
  priority           = 500

  dynamic "application_rule_collection" {
    for_each = var.application_rule_collection
    content {
      # action - (required) is a type of string
      action = application_rule_collection.value["action"]
      # name - (required) is a type of string
      name = application_rule_collection.value["name"]
      # priority - (required) is a type of number
      priority = application_rule_collection.value["priority"]

      dynamic "rule" {
        for_each = application_rule_collection.value.rule
        content {
          # destination_fqdn_tags - (optional) is a type of set of string
          destination_fqdn_tags = rule.value["destination_fqdn_tags"]
          # destination_fqdns - (optional) is a type of set of string
          destination_fqdns = rule.value["destination_fqdns"]
          # name - (required) is a type of string
          name = rule.value["name"]
          # source_addresses - (optional) is a type of set of string
          source_addresses = rule.value["source_addresses"]
          # source_ip_groups - (optional) is a type of set of string
          source_ip_groups = rule.value["source_ip_groups"]

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              # port - (required) is a type of number
              port = protocols.value["port"]
              # type - (required) is a type of string
              type = protocols.value["type"]
            }
          }

        }
      }

    }
  }

  dynamic "network_rule_collection" {
    for_each = var.network_rule_collection
    content {
      # action - (required) is a type of string
      action = network_rule_collection.value["action"]
      # name - (required) is a type of string
      name = network_rule_collection.value["name"]
      # priority - (required) is a type of number
      priority = network_rule_collection.value["priority"]

      dynamic "rule" {
        for_each = network_rule_collection.value.rule
        content {
          # destination_addresses - (optional) is a type of set of string
          destination_addresses = rule.value["destination_addresses"]
          # destination_fqdns - (optional) is a type of set of string
          destination_fqdns = rule.value["destination_fqdns"]
          # destination_ip_groups - (optional) is a type of set of string
          destination_ip_groups = rule.value["destination_ip_groups"]
          # destination_ports - (required) is a type of set of string
          destination_ports = rule.value["destination_ports"]
          # name - (required) is a type of string
          name = rule.value["name"]
          # protocols - (required) is a type of set of string
          protocols = rule.value["protocols"]
          # source_addresses - (optional) is a type of set of string
          source_addresses = rule.value["source_addresses"]
          # source_ip_groups - (optional) is a type of set of string
          source_ip_groups = rule.value["source_ip_groups"]
        }
      }

    }
  }

}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg" {
  name = "demo11"
}

resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP Creation"
  description  = "This policy denies the creation of public IP addresses."
  policy_rule = <<POLICY
{
  "if": {
    "field": "type",
    "equals": "Microsoft.Network/publicIPAddresses"
  },
  "then": {
    "effect": "deny"
  }
}
POLICY
}

resource "azurerm_resource_group_policy_assignment" "deny_public_ip_rg" {
  name                 = "deny-public-ip-rg"
  display_name         = "Deny Public IPs at RG demo11"
  resource_group_id    = data.azurerm_resource_group.rg.id
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
}


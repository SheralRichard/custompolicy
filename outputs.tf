output "policy_definition_id" {
  value = azurerm_policy_definition.deny_public_ip.id
}

output "policy_assignment_id" {
  value = azurerm_resource_group_policy_assignment.deny_public_ip_rg.id
}

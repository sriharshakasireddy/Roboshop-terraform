data "azurerm_resource_group" "rg" {
  name = "project"
}

output "rg" {
  value = "data.azurerm_resource_group.rg"
}
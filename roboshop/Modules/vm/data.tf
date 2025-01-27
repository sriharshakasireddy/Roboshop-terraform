data "azurerm_resource_group" "main" {
  name = "project"
}

data "azurerm_subnet" "subnet" {
  name                 = "default"
  virtual_network_name = "workshop-vnet"
  resource_group_name  = data.azurerm_resource_group.main.name
}

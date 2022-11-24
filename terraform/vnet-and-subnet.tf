resource "azurerm_virtual_network" "virtual_network" {
  name                = "eonhomework-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    "environment" = "dev"
  }
}

resource "azurerm_subnet" "aca_subnet" {
  name                 = "eonhomework-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.0.0/23"]

}
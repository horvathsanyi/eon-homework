#Logging
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-aca-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    "environment" = "development"
  }
}
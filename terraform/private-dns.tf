resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = jsondecode(azapi_resource.aca_env.output).properties.defaultDomain
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "containerapplink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.virtual_network.id
}

resource "azurerm_private_dns_a_record" "containerapp_record" {
  name                = "eonhomework"
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = ["${jsondecode(azapi_resource.aca_env.output).properties.staticIp}"]

}
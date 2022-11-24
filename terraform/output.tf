output "private_dns_zone" {
  value = azurerm_private_dns_zone.private_dns_zone.name
}

output "private_dns_record" {
  value = azurerm_private_dns_a_record.containerapp_record.records
}
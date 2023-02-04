output "private_ip_address" {
  value = azurerm_firewall.afw.ip_configuration[0].private_ip_address
}

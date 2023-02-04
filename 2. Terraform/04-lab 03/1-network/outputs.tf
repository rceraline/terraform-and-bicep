output "spoke_01_snet_01_id" {
  value = azurerm_virtual_network.spokes["vnet-spoke-01"].subnet.*.id[0]
}

output "spoke_02_snet_01_id" {
  value = azurerm_virtual_network.spokes["vnet-spoke-02"].subnet.*.id[0]
}

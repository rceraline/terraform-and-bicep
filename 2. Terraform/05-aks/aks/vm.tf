module "vm_02" {
  source = "../modules/windows_vm"

  location            = azurerm_resource_group.rg.location
  name                = "vm-02"
  resource_group_name = azurerm_resource_group.rg.name
  password            = var.vm_password
  subnet_id           = azurerm_subnet.spoke_subnets["vnet-spoke-02_snet-01"].id
}

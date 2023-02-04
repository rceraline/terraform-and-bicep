terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.41.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-cac-01"
    storage_account_name = "satfstatecac20230128"
    container_name       = "state"
    key                  = "compute.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}

data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate-cac-01"
    storage_account_name = "satfstatecac20230128"
    container_name       = "state"
    key                  = "network.terraform.tfstate"
  }
}

locals {
  location            = "Canada Central"
  resource_group_name = "rg-mycompany-01"
}

## VM 01
module "vm_01" {
  source = "../modules/windows_vm"

  location            = local.location
  name                = "vm-01"
  password            = var.vm_password
  resource_group_name = local.resource_group_name
  subnet_id           = data.terraform_remote_state.network.outputs.spoke_01_snet_01_id
}

## VM 02
module "vm_02" {
  source = "../modules/windows_vm"

  install_iis         = true
  location            = local.location
  name                = "vm-02"
  password            = var.vm_password
  resource_group_name = local.resource_group_name
  subnet_id           = data.terraform_remote_state.network.outputs.spoke_02_snet_01_id
}

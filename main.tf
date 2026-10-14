terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "RG-SRE-LAB"
    storage_account_name = "srelabstore1391"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "lab_rg" {
  name = "RG-SRE-LAB"
}

# Matched identifier: sre_vnet
resource "azurerm_virtual_network" "sre_vnet" {
  name                = "vnet-sre-prod"
  address_space       = ["10.20.0.0/16"]
  location            = data.azurerm_resource_group.lab_rg.location
  resource_group_name = data.azurerm_resource_group.lab_rg.name

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform-VSCode"
    Owner       = "SRE-Team"
  }
}

# Matched identifier: sre_subnet
resource "azurerm_subnet" "sre_subnet" {
  name                 = "snet-workloads"
  resource_group_name  = data.azurerm_resource_group.lab_rg.name
  virtual_network_name = azurerm_virtual_network.sre_vnet.name
  address_prefixes     = ["10.20.1.0/24"]
}

output "vnet_id" {
  value       = azurerm_virtual_network.sre_vnet.id
  description = "The ARM Resource ID of the production Virtual Network"
}

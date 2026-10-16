terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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

# Azure Container Registry (ACR) for SRE workloads
resource "azurerm_container_registry" "sre_acr" {
  name                = "srelabreg1391"
  resource_group_name = data.azurerm_resource_group.lab_rg.name
  location            = data.azurerm_resource_group.lab_rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform-VSCode"
    Owner       = "SRE-Team"
  }
}

output "vnet_id" {
  value       = azurerm_virtual_network.sre_vnet.id
  description = "The ARM Resource ID of the production Virtual Network"
}

output "acr_login_server" {
  value       = azurerm_container_registry.sre_acr.login_server
  description = "The URL used to log in and push Docker images"
}
# --- Sprint 3: Managed Azure Kubernetes Service (AKS) ---

resource "azurerm_kubernetes_cluster" "sre_aks" {
  name                = "aks-sre-prod"
  location            = data.azurerm_resource_group.lab_rg.location
  resource_group_name = data.azurerm_resource_group.lab_rg.name
  dns_prefix          = "srelabk8s"

  default_node_pool {
    name           = "workloadpool"
    node_count     = 1
    vm_size        = "Standard_B2s_v2"
    vnet_subnet_id = azurerm_subnet.sre_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform-VSCode"
    Owner       = "SRE-Team"
  }
}
# Grant AKS System-Assigned Identity permission to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.sre_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.sre_acr.id
  skip_service_principal_aad_check = true
}
output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.sre_aks.name
  description = "Production AKS cluster name"
}
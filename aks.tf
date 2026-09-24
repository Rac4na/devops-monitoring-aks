resource "azurerm_resource_group" "rg_01" {
  name     = "rg-acuna-dev-eastus-01"
  location = "East US"
  tags = {
    Project = "Monitoring"
  }

}

resource "azurerm_kubernetes_cluster" "aks_01" {
  name                = "aks-acuna-dev-eastus-01"
  location            = azurerm_resource_group.rg_01.location
  resource_group_name = azurerm_resource_group.rg_01.name
  dns_prefix          = "aksdns"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2als_v7"

    upgrade_settings {
      max_surge = "10%"
    }
  }

  oidc_issuer_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_01.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_01.kube_config_raw

  sensitive = true
}

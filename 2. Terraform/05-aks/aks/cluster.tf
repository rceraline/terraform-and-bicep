## Identities
resource "azurerm_user_assigned_identity" "control_plane" {
  location            = azurerm_resource_group.rg.location
  name                = "id-controlplane-01"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_user_assigned_identity" "kubelet" {
  location            = azurerm_resource_group.rg.location
  name                = "id-kubelet-01"
  resource_group_name = azurerm_resource_group.rg.name
}

## Role assignements
resource "azurerm_role_assignment" "dns_contributor" {
  scope                = azurerm_private_dns_zone.aks.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_virtual_network.spokes["vnet-spoke-01"].id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
}

resource "azurerm_role_assignment" "managed_identity_contributor" {
  scope                = azurerm_user_assigned_identity.kubelet.id
  role_definition_name = "Managed Identity Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
}

resource "azurerm_role_assignment" "managed_identity_operator" {
  scope                = azurerm_user_assigned_identity.kubelet.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
}

resource "azurerm_role_assignment" "acr" {
  scope                = azurerm_container_registry.cr_01.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet.principal_id
}

## Cluster
resource "azurerm_kubernetes_cluster" "aks_01" {
  name                       = "aks-01"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  dns_prefix_private_cluster = "aks-01"
  private_cluster_enabled    = true
  private_dns_zone_id        = azurerm_private_dns_zone.aks.id

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.spoke_subnets["vnet-spoke-01_snet-02"].id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.control_plane.id]
  }

  kubelet_identity {
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
    client_id                 = azurerm_user_assigned_identity.kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.1.2.4"
    service_cidr   = "10.1.2.0/24"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.agw_01.id
  }

  depends_on = [
    azurerm_role_assignment.network_contributor,
    azurerm_role_assignment.dns_contributor,
    azurerm_role_assignment.managed_identity_contributor,
    azurerm_role_assignment.managed_identity_operator,
  ]
}

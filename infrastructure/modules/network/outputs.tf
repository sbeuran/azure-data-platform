# Network Module Outputs

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

# Subnet IDs
output "databricks_private_subnet_id" {
  description = "ID of the Databricks private subnet"
  value       = azurerm_subnet.databricks_private.id
}

output "databricks_public_subnet_id" {
  description = "ID of the Databricks public subnet"
  value       = azurerm_subnet.databricks_public.id
}

output "data_factory_subnet_id" {
  description = "ID of the Data Factory subnet"
  value       = azurerm_subnet.data_factory.id
}

output "synapse_subnet_id" {
  description = "ID of the Synapse subnet"
  value       = azurerm_subnet.synapse.id
}

# Network Security Groups
output "databricks_private_nsg_id" {
  description = "ID of the Databricks private NSG"
  value       = azurerm_network_security_group.databricks_private.id
}

output "databricks_public_nsg_id" {
  description = "ID of the Databricks public NSG"
  value       = azurerm_network_security_group.databricks_public.id
}

output "data_factory_nsg_id" {
  description = "ID of the Data Factory NSG"
  value       = azurerm_network_security_group.data_factory.id
}

output "synapse_nsg_id" {
  description = "ID of the Synapse NSG"
  value       = azurerm_network_security_group.synapse.id
}

# Private DNS Zones
output "private_dns_zones" {
  description = "Map of private DNS zones"
  value = {
    blob      = azurerm_private_dns_zone.blob.id
    dfs       = azurerm_private_dns_zone.dfs.id
    keyvault  = azurerm_private_dns_zone.keyvault.id
    databricks = azurerm_private_dns_zone.databricks.id
    synapse   = azurerm_private_dns_zone.synapse.id
    synapse_dev = azurerm_private_dns_zone.synapse_dev.id
  }
}

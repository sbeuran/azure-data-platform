# Synapse Module Outputs - Simplified Version

output "workspace_id" {
  description = "ID of the Synapse workspace"
  value       = azurerm_synapse_workspace.main.id
}

output "workspace_name" {
  description = "Name of the Synapse workspace"
  value       = azurerm_synapse_workspace.main.name
}

output "workspace_url" {
  description = "URL of the Synapse workspace"
  value       = azurerm_synapse_workspace.main.connectivity_endpoints
}

output "sql_pool_id" {
  description = "ID of the SQL pool"
  value       = azurerm_synapse_sql_pool.main.id
}

output "sql_pool_name" {
  description = "Name of the SQL pool"
  value       = azurerm_synapse_sql_pool.main.name
}

output "spark_pool_id" {
  description = "ID of the Spark pool"
  value       = azurerm_synapse_spark_pool.main.id
}

output "spark_pool_name" {
  description = "Name of the Spark pool"
  value       = azurerm_synapse_spark_pool.main.name
}

output "private_endpoint_id" {
  description = "ID of the Synapse private endpoint"
  value       = null  # Disabled due to subnet delegation
}

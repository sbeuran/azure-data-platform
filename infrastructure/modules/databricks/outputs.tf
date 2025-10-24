# Databricks Module Outputs

output "workspace_id" {
  description = "ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.main.id
}

output "workspace_name" {
  description = "Name of the Databricks workspace"
  value       = azurerm_databricks_workspace.main.name
}

output "workspace_url" {
  description = "URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.main.workspace_url
}

output "workspace_managed_resource_group_id" {
  description = "ID of the Databricks managed resource group"
  value       = azurerm_databricks_workspace.main.managed_resource_group_id
}

output "unity_catalog_access_connector_id" {
  description = "ID of the Unity Catalog access connector"
  value       = var.enable_unity_catalog ? azurerm_databricks_access_connector.unity_catalog[0].id : null
}

output "unity_catalog_access_connector_identity" {
  description = "Identity of the Unity Catalog access connector"
  value       = var.enable_unity_catalog ? azurerm_databricks_access_connector.unity_catalog[0].identity : null
}

output "private_endpoint_id" {
  description = "ID of the Databricks private endpoint"
  value       = var.enable_private_endpoints ? azurerm_private_endpoint.databricks[0].id : null
}

# Note: Databricks cluster policies, instance pools, and jobs will be configured
# through the Databricks workspace UI after the infrastructure is deployed

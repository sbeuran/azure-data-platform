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

output "cluster_policy_id" {
  description = "ID of the Databricks cluster policy"
  value       = databricks_cluster_policy.supply_chain_policy.id
}

output "instance_pool_id" {
  description = "ID of the Databricks instance pool"
  value       = databricks_instance_pool.supply_chain_pool.id
}

output "etl_job_id" {
  description = "ID of the supply chain ETL job"
  value       = databricks_job.supply_chain_etl.id
}

output "ml_job_id" {
  description = "ID of the supply chain ML job"
  value       = databricks_job.supply_chain_ml.id
}

# Synapse Module Outputs

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

output "managed_identity" {
  description = "Managed identity of the Synapse workspace"
  value = {
    principal_id = azurerm_synapse_workspace.main.identity[0].principal_id
    tenant_id    = azurerm_synapse_workspace.main.identity[0].tenant_id
  }
}

output "sql_pool_id" {
  description = "ID of the Synapse SQL pool"
  value       = azurerm_synapse_sql_pool.main.id
}

output "sql_pool_name" {
  description = "Name of the Synapse SQL pool"
  value       = azurerm_synapse_sql_pool.main.name
}

output "spark_pool_id" {
  description = "ID of the Synapse Spark pool"
  value       = azurerm_synapse_spark_pool.main.id
}

output "spark_pool_name" {
  description = "Name of the Synapse Spark pool"
  value       = azurerm_synapse_spark_pool.main.name
}

output "private_endpoints" {
  description = "Private endpoint information"
  value = {
    sql = var.enable_private_endpoints ? azurerm_private_endpoint.synapse_sql[0].id : null
    dev = var.enable_private_endpoints ? azurerm_private_endpoint.synapse_dev[0].id : null
  }
}

output "linked_services" {
  description = "Linked services created"
  value = {
    data_lake    = var.data_lake_storage_account_id != null ? azurerm_synapse_linked_service.data_lake[0].id : null
    key_vault    = var.key_vault_id != null ? azurerm_synapse_linked_service.key_vault[0].id : null
    sap_s4hana   = var.sap_s4hana_enabled ? azurerm_synapse_linked_service.sap_s4hana[0].id : null
    sap_r3       = var.sap_r3_enabled ? azurerm_synapse_linked_service.sap_r3[0].id : null
    databricks   = var.databricks_workspace_id != null ? azurerm_synapse_linked_service.databricks[0].id : null
  }
}

output "datasets" {
  description = "Datasets created"
  value = {
    supply_chain_data = var.data_lake_storage_account_id != null ? azurerm_synapse_dataset.supply_chain_data[0].id : null
    ml_features       = var.data_lake_storage_account_id != null ? azurerm_synapse_dataset.ml_features[0].id : null
  }
}

output "pipelines" {
  description = "Pipelines created"
  value = {
    supply_chain_analytics = azurerm_synapse_pipeline.supply_chain_analytics.id
    ml_data_preparation    = azurerm_synapse_pipeline.ml_data_preparation.id
  }
}

output "triggers" {
  description = "Triggers created"
  value = {
    supply_chain_analytics = azurerm_synapse_trigger_schedule.supply_chain_analytics.id
    ml_data_preparation    = azurerm_synapse_trigger_schedule.ml_data_preparation.id
  }
}

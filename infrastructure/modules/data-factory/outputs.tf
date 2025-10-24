# Data Factory Module Outputs

output "data_factory_id" {
  description = "ID of the Data Factory"
  value       = azurerm_data_factory.main.id
}

output "data_factory_name" {
  description = "Name of the Data Factory"
  value       = azurerm_data_factory.main.name
}

output "managed_identity" {
  description = "Managed identity of the Data Factory"
  value = {
    principal_id = azurerm_data_factory.main.identity[0].principal_id
    tenant_id    = azurerm_data_factory.main.identity[0].tenant_id
  }
}

output "private_endpoint_id" {
  description = "ID of the Data Factory private endpoint"
  value       = var.enable_private_endpoints ? azurerm_private_endpoint.data_factory[0].id : null
}

output "linked_services" {
  description = "Linked services created"
  value = {
    data_lake    = var.data_lake_storage_account_id != null ? azurerm_data_factory_linked_service_azure_blob_storage.data_lake[0].id : null
    key_vault    = var.key_vault_id != null ? azurerm_data_factory_linked_service_key_vault.key_vault[0].id : null
    sap_s4hana   = var.sap_s4hana_enabled ? azurerm_data_factory_linked_service_sap_ecc.sap_s4hana[0].id : null
    sap_r3       = var.sap_r3_enabled ? azurerm_data_factory_linked_service_sap_ecc.sap_r3[0].id : null
    databricks   = var.databricks_workspace_id != null ? azurerm_data_factory_linked_service_azure_databricks.databricks[0].id : null
  }
}

output "datasets" {
  description = "Datasets created"
  value = {
    sap_materials    = var.sap_s4hana_enabled ? azurerm_data_factory_dataset_delimited_text.sap_materials[0].id : null
    sap_sales_orders = var.sap_s4hana_enabled ? azurerm_data_factory_dataset_delimited_text.sap_sales_orders[0].id : null
  }
}

output "pipelines" {
  description = "Pipelines created"
  value = {
    supply_chain_etl = azurerm_data_factory_pipeline.supply_chain_etl.id
    ml_data_preparation = azurerm_data_factory_pipeline.ml_data_preparation.id
  }
}

output "triggers" {
  description = "Triggers created"
  value = {
    supply_chain_etl = azurerm_data_factory_trigger_schedule.supply_chain_etl.id
    ml_data_preparation = azurerm_data_factory_trigger_schedule.ml_data_preparation.id
  }
}

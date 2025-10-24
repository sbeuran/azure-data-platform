# Bosch Supply Chain Data Platform - Outputs

# Resource Group
output "resource_group_name" {
  description = "Name of the main resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the main resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "Location of the main resource group"
  value       = azurerm_resource_group.main.location
}

# Key Vault
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

# Log Analytics
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_primary_shared_key" {
  description = "Primary shared key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

# Application Insights
output "application_insights_id" {
  description = "ID of the Application Insights"
  value       = azurerm_application_insights.main.id
}

output "application_insights_name" {
  description = "Name of the Application Insights"
  value       = azurerm_application_insights.main.name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key of the Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

# Network
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.network.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.network.vnet_name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = module.network.vnet_address_space
}

# Data Lake
output "data_lake_storage_account_id" {
  description = "ID of the data lake storage account"
  value       = module.data_lake.storage_account_id
}

output "data_lake_storage_account_name" {
  description = "Name of the data lake storage account"
  value       = module.data_lake.storage_account_name
}

output "data_lake_primary_dfs_endpoint" {
  description = "Primary DFS endpoint of the data lake"
  value       = module.data_lake.primary_dfs_endpoint
}

output "data_lake_containers" {
  description = "Data lake container names"
  value       = module.data_lake.container_names
}

# Databricks
output "databricks_workspace_id" {
  description = "ID of the Databricks workspace"
  value       = module.databricks.workspace_id
}

output "databricks_workspace_name" {
  description = "Name of the Databricks workspace"
  value       = module.databricks.workspace_name
}

output "databricks_workspace_url" {
  description = "URL of the Databricks workspace"
  value       = module.databricks.workspace_url
}

# Data Factory
output "data_factory_id" {
  description = "ID of the Data Factory"
  value       = module.data_factory.data_factory_id
}

output "data_factory_name" {
  description = "Name of the Data Factory"
  value       = module.data_factory.data_factory_name
}

output "data_factory_identity" {
  description = "Managed identity of the Data Factory"
  value       = module.data_factory.managed_identity
}

# Synapse
output "synapse_workspace_id" {
  description = "ID of the Synapse workspace"
  value       = module.synapse.workspace_id
}

output "synapse_workspace_name" {
  description = "Name of the Synapse workspace"
  value       = module.synapse.workspace_name
}

output "synapse_sql_pool_id" {
  description = "ID of the Synapse SQL pool"
  value       = module.synapse.sql_pool_id
}

output "synapse_sql_pool_name" {
  description = "Name of the Synapse SQL pool"
  value       = module.synapse.sql_pool_name
}

# Monitoring
output "monitoring_dashboard_url" {
  description = "URL of the monitoring dashboard"
  value       = module.monitoring.dashboard_url
}

output "monitoring_alert_rules" {
  description = "List of monitoring alert rules"
  value       = module.monitoring.alert_rules
}

# Common Tags
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# Platform Information
output "platform_name" {
  description = "Name of the data platform"
  value       = local.project_name
}

output "environment" {
  description = "Environment name"
  value       = local.environment
}

# Security Information
output "private_endpoints_enabled" {
  description = "Whether private endpoints are enabled"
  value       = var.enable_private_endpoints
}

output "compliance_standards" {
  description = "Compliance standards implemented"
  value       = var.compliance_standards
}

# Cost Management
output "cost_management_enabled" {
  description = "Whether cost management is enabled"
  value       = var.enable_cost_management
}

# SAP Integration
output "sap_integration_enabled" {
  description = "Whether SAP integration is enabled"
  value       = var.sap_s4hana_enabled || var.sap_r3_enabled
}

# ML/AI Services
output "ml_services_enabled" {
  description = "Whether ML/AI services are enabled"
  value       = var.ml_workspace_enabled || var.cognitive_services_enabled
}

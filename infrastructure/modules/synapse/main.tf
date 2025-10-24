# Synapse Module - Simplified Version
# This module creates the Azure Synapse Analytics workspace with basic configuration

# Synapse Workspace
resource "azurerm_synapse_workspace" "main" {
  name                                 = "synapse-${var.project_name}-${var.environment}"
  resource_group_name                  = var.resource_group_name
  location                            = var.location
  storage_data_lake_gen2_filesystem_id = "https://stdatalakeboschdev.dfs.core.windows.net/default"
  sql_administrator_login              = var.synapse_sql_administrator_login
  sql_administrator_login_password     = var.synapse_sql_administrator_password
  managed_virtual_network_enabled      = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
}

# SQL Pool
resource "azurerm_synapse_sql_pool" "main" {
  name                 = "sqlpool${var.project_name}${var.environment}"
  synapse_workspace_id  = azurerm_synapse_workspace.main.id
  sku_name             = var.synapse_sql_pool_sku
  create_mode          = "Default"
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  data_encrypted       = true

  tags = var.common_tags
}

# Spark Pool
resource "azurerm_synapse_spark_pool" "main" {
  name                 = "spark${var.project_name}${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small"
  node_count           = 3
  spark_version        = "3.3"

  tags = var.common_tags
}

# Private Endpoint for Synapse
# Note: Disabled because the Synapse subnet is delegated and cannot have private endpoints
resource "azurerm_private_endpoint" "synapse" {
  count               = 0  # Disabled due to subnet delegation
  name                = "pe-synapse-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.synapse_subnet_id

  private_service_connection {
    name                           = "psc-synapse-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_synapse_workspace.main.id
    subresource_names              = ["sql"]
    is_manual_connection           = false
  }

  tags = var.common_tags
}

# Diagnostic Settings for Synapse
resource "azurerm_monitor_diagnostic_setting" "synapse" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-synapse-${var.project_name}-${var.environment}"
  target_resource_id         = azurerm_synapse_workspace.main.id
  log_analytics_workspace_id = var.log_analytics_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  enabled_log {
    category = "SynapseRbacOperations"
  }

}

# Note: Linked services, datasets, and pipelines will be configured
# through the Synapse workspace UI after the infrastructure is deployed
# This is because they require complex JSON configurations and
# authentication to external systems

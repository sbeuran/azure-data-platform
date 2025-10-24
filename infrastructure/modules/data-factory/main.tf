# Data Factory Module - Simplified Version
# This module creates the Azure Data Factory with basic configuration

# Data Factory
resource "azurerm_data_factory" "main" {
  name                = "adf-${var.project_name}-${var.environment}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  identity {
    type = "SystemAssigned"
  }
}

# Private Endpoint for Data Factory
resource "azurerm_private_endpoint" "data_factory" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-data-factory-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.data_factory_subnet_id

  private_service_connection {
    name                           = "psc-data-factory-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_data_factory.main.id
    subresource_names              = ["dataFactory"]
    is_manual_connection           = false
  }

  tags = var.common_tags
}

# Diagnostic Settings for Data Factory
resource "azurerm_monitor_diagnostic_setting" "data_factory" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-data-factory-${var.project_name}-${var.environment}"
  target_resource_id         = azurerm_data_factory.main.id
  log_analytics_workspace_id = var.log_analytics_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  enabled_log {
    category = "ActivityRuns"
  }

  enabled_log {
    category = "PipelineRuns"
  }

  enabled_log {
    category = "TriggerRuns"
  }
}

# Note: Linked services, datasets, and pipelines will be configured
# through the Data Factory UI after the infrastructure is deployed
# This is because they require complex JSON configurations and
# authentication to external systems

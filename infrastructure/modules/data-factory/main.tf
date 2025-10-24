# Data Factory Module - Bosch Supply Chain Data Platform
# This module creates the Azure Data Factory and related resources

# Data Factory
resource "azurerm_data_factory" "main" {
  name                = "adf-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Managed identity
  identity {
    type = "SystemAssigned"
  }

  # Network configuration
  public_network_enabled = var.data_factory_public_network_enabled

  # Global parameters
  global_parameter {
    name  = "Environment"
    type  = "String"
    value = var.environment
  }

  global_parameter {
    name  = "ProjectName"
    type  = "String"
    value = var.project_name
  }

  tags = var.common_tags
}

# Private Endpoint for Data Factory
resource "azurerm_private_endpoint" "data_factory" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-data-factory-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-data-factory-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_data_factory.main.id
    subresource_names              = ["dataFactory"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdns-data-factory-${var.project_name}-${var.environment}"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.common_tags
}

# Key Vault Access Policy for Data Factory
resource "azurerm_key_vault_access_policy" "data_factory" {
  count        = var.key_vault_id != null ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_data_factory.main.identity[0].tenant_id
  object_id    = azurerm_data_factory.main.identity[0].principal_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"
  ]
}

# Storage Account Access for Data Factory
resource "azurerm_role_assignment" "data_factory_storage_blob_data_contributor" {
  count                = var.data_lake_storage_account_id != null ? 1 : 0
  scope               = var.data_lake_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id        = azurerm_data_factory.main.identity[0].principal_id
}

# Diagnostic Settings for Data Factory
resource "azurerm_monitor_diagnostic_setting" "data_factory" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-data-factory-${var.project_name}-${var.environment}"
  target_resource_id         = azurerm_data_factory.main.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "ActivityRuns"
  }

  enabled_log {
    category = "PipelineRuns"
  }

  enabled_log {
    category = "TriggerRuns"
  }

  enabled_log {
    category = "SSISIntegrationRuntimeLogs"
  }

  enabled_log {
    category = "SSISPackageEventMessageContext"
  }

  enabled_log {
    category = "SSISPackageEventMessageContext"
  }

  enabled_log {
    category = "SSISPackageExecutableStatistics"
  }

  enabled_log {
    category = "SSISPackageExecutionComponentPhases"
  }

  enabled_log {
    category = "SSISPackageExecutionDataStatistics"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Data Factory Linked Service for Azure Data Lake Storage
resource "azurerm_data_factory_linked_service_azure_blob_storage" "data_lake" {
  count               = var.data_lake_storage_account_id != null ? 1 : 0
  name                = "ls-data-lake-${var.project_name}-${var.environment}"
  data_factory_id     = azurerm_data_factory.main.id
  service_endpoint    = var.data_lake_storage_account_primary_dfs_endpoint
  use_managed_identity = true
}

# Data Factory Linked Service for Key Vault
resource "azurerm_data_factory_linked_service_key_vault" "key_vault" {
  count           = var.key_vault_id != null ? 1 : 0
  name            = "ls-key-vault-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id
  key_vault_id     = var.key_vault_id
}

# Data Factory Linked Service for SAP S/4HANA
resource "azurerm_data_factory_linked_service_sap_ecc" "sap_s4hana" {
  count           = var.sap_s4hana_enabled ? 1 : 0
  name            = "ls-sap-s4hana-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id
  server          = var.sap_s4hana_server
  system_number   = var.sap_s4hana_system_number
  client_id       = var.sap_s4hana_client_id
  username        = var.sap_s4hana_username
  password        = var.sap_s4hana_password
}

# Data Factory Linked Service for SAP R/3
resource "azurerm_data_factory_linked_service_sap_ecc" "sap_r3" {
  count           = var.sap_r3_enabled ? 1 : 0
  name            = "ls-sap-r3-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id
  server          = var.sap_r3_server
  system_number   = var.sap_r3_system_number
  client_id       = var.sap_r3_client_id
  username        = var.sap_r3_username
  password        = var.sap_r3_password
}

# Data Factory Linked Service for Databricks
resource "azurerm_data_factory_linked_service_azure_databricks" "databricks" {
  count           = var.databricks_workspace_id != null ? 1 : 0
  name            = "ls-databricks-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id
  adb_domain      = var.databricks_workspace_url
  access_token    = var.databricks_access_token
}

# Data Factory Dataset for SAP S/4HANA Materials
resource "azurerm_data_factory_dataset_delimited_text" "sap_materials" {
  count           = var.sap_s4hana_enabled ? 1 : 0
  name            = "ds-sap-materials-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id
  linked_service_id = azurerm_data_factory_linked_service_sap_ecc.sap_s4hana[0].id

  azure_blob_storage_location {
    container = "bronze"
    path      = "sap/s4hana/materials"
    filename  = "materials.csv"
  }

  column_delimiter = ","
  row_delimiter    = "\n"
  encoding         = "UTF-8"
  quote_character  = "\""
  escape_character = "\\"
  first_row_as_header = true
}

# Data Factory Dataset for SAP S/4HANA Sales Orders
resource "azurerm_data_factory_dataset_delimited_text" "sap_sales_orders" {
  count           = var.sap_s4hana_enabled ? 1 : 0
  name            = "ds-sap-sales-orders-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id
  linked_service_id = azurerm_data_factory_linked_service_sap_ecc.sap_s4hana[0].id

  azure_blob_storage_location {
    container = "bronze"
    path      = "sap/s4hana/sales_orders"
    filename  = "sales_orders.csv"
  }

  column_delimiter = ","
  row_delimiter    = "\n"
  encoding         = "UTF-8"
  quote_character  = "\""
  escape_character = "\\"
  first_row_as_header = true
}

# Data Factory Pipeline for Supply Chain ETL
resource "azurerm_data_factory_pipeline" "supply_chain_etl" {
  name            = "pl-supply-chain-etl-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id

  description = "ETL pipeline for supply chain data processing"

  # Pipeline activities would be defined here
  # This is a simplified version - in practice, you'd define complex activities
}

# Data Factory Trigger for Supply Chain ETL
resource "azurerm_data_factory_trigger_schedule" "supply_chain_etl" {
  name            = "trg-supply-chain-etl-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id
  pipeline_id     = azurerm_data_factory_pipeline.supply_chain_etl.id

  frequency = "Day"
  interval  = 1
  start_time = "2024-01-01T02:00:00Z"

  activated = true
}

# Data Factory Pipeline for ML Data Preparation
resource "azurerm_data_factory_pipeline" "ml_data_preparation" {
  name            = "pl-ml-data-preparation-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id

  description = "Data preparation pipeline for ML models"

  # Pipeline activities would be defined here
}

# Data Factory Trigger for ML Data Preparation
resource "azurerm_data_factory_trigger_schedule" "ml_data_preparation" {
  name            = "trg-ml-data-preparation-${var.project_name}-${var.environment}"
  data_factory_id = azurerm_data_factory.main.id
  pipeline_id     = azurerm_data_factory_pipeline.ml_data_preparation.id

  frequency = "Day"
  interval  = 1
  start_time = "2024-01-01T03:00:00Z"

  activated = true
}

# Synapse Module - Bosch Supply Chain Data Platform
# This module creates the Azure Synapse Analytics workspace and related resources

# Synapse Workspace
resource "azurerm_synapse_workspace" "main" {
  name                                 = "synw-${var.project_name}-${var.environment}"
  resource_group_name                  = var.resource_group_name
  location                            = var.location
  storage_data_lake_gen2_filesystem_id = var.data_lake_filesystem_id
  sql_administrator_login             = var.synapse_sql_administrator_login
  sql_administrator_login_password    = var.synapse_sql_administrator_password

  # Managed identity
  identity {
    type = "SystemAssigned"
  }

  # Network configuration
  public_network_access_enabled = var.synapse_public_network_enabled

  # Security settings
  sql_identity_control_enabled = true

  # Tags
  tags = var.common_tags
}

# Private Endpoint for Synapse SQL
resource "azurerm_private_endpoint" "synapse_sql" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-synapse-sql-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-synapse-sql-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_synapse_workspace.main.id
    subresource_names              = ["sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdns-synapse-sql-${var.project_name}-${var.environment}"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.common_tags
}

# Private Endpoint for Synapse Dev
resource "azurerm_private_endpoint" "synapse_dev" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-synapse-dev-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-synapse-dev-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_synapse_workspace.main.id
    subresource_names              = ["dev"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdns-synapse-dev-${var.project_name}-${var.environment}"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.common_tags
}

# Synapse SQL Pool
resource "azurerm_synapse_sql_pool" "main" {
  name                 = "sqlp-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  sku_name            = var.synapse_sql_pool_sku
  create_mode         = "Default"

  # Performance settings
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  data_encrypted = true

  tags = var.common_tags
}

# Synapse Spark Pool
resource "azurerm_synapse_spark_pool" "main" {
  name                 = "spark-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  node_size_family    = "MemoryOptimized"
  node_size           = "Small"
  node_count          = 3

  # Auto-scale settings
  auto_scale {
    max_node_count = 10
    min_node_count = 3
  }

  # Auto-pause settings
  auto_pause {
    delay_in_minutes = 15
  }

  # Spark configuration
  spark_version = "3.3"
  spark_events_folder = "/events"
  spark_log_folder    = "/logs"

  tags = var.common_tags
}

# Key Vault Access Policy for Synapse
resource "azurerm_key_vault_access_policy" "synapse" {
  count        = var.key_vault_id != null ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_synapse_workspace.main.identity[0].tenant_id
  object_id    = azurerm_synapse_workspace.main.identity[0].principal_id

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

# Storage Account Access for Synapse
resource "azurerm_role_assignment" "synapse_storage_blob_data_contributor" {
  count                = var.data_lake_storage_account_id != null ? 1 : 0
  scope               = var.data_lake_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id        = azurerm_synapse_workspace.main.identity[0].principal_id
}

# Diagnostic Settings for Synapse Workspace
resource "azurerm_monitor_diagnostic_setting" "synapse_workspace" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-synapse-workspace-${var.project_name}-${var.environment}"
  target_resource_id         = azurerm_synapse_workspace.main.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "SynapseRbacOperations"
  }

  enabled_log {
    category = "SynapseGatewayApiRequests"
  }

  enabled_log {
    category = "SynapseBuiltinSqlReqsEnded"
  }

  enabled_log {
    category = "SynapseIntegrationPipelineRuns"
  }

  enabled_log {
    category = "SynapseIntegrationActivityRuns"
  }

  enabled_log {
    category = "SynapseIntegrationTriggerRuns"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic Settings for Synapse SQL Pool
resource "azurerm_monitor_diagnostic_setting" "synapse_sql_pool" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-synapse-sql-pool-${var.project_name}-${var.environment}"
  target_resource_id         = azurerm_synapse_sql_pool.main.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "SynapseSqlPoolDmsWorkers"
  }

  enabled_log {
    category = "SynapseSqlPoolRequestSteps"
  }

  enabled_log {
    category = "SynapseSqlPoolSqlRequests"
  }

  enabled_log {
    category = "SynapseSqlPoolWaits"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Synapse Linked Service for Data Lake
resource "azurerm_synapse_linked_service" "data_lake" {
  count           = var.data_lake_storage_account_id != null ? 1 : 0
  name            = "ls-data-lake-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  type            = "AzureBlobFS"
  type_properties = jsonencode({
    url = var.data_lake_storage_account_primary_dfs_endpoint
  })
}

# Synapse Linked Service for Key Vault
resource "azurerm_synapse_linked_service" "key_vault" {
  count           = var.key_vault_id != null ? 1 : 0
  name            = "ls-key-vault-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  type            = "AzureKeyVault"
  type_properties = jsonencode({
    baseUrl = var.key_vault_uri
  })
}

# Synapse Linked Service for SAP S/4HANA
resource "azurerm_synapse_linked_service" "sap_s4hana" {
  count           = var.sap_s4hana_enabled ? 1 : 0
  name            = "ls-sap-s4hana-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  type            = "SapEcc"
  type_properties = jsonencode({
    server   = var.sap_s4hana_server
    systemNumber = var.sap_s4hana_system_number
    clientId = var.sap_s4hana_client_id
    username = var.sap_s4hana_username
    password = var.sap_s4hana_password
  })
}

# Synapse Linked Service for SAP R/3
resource "azurerm_synapse_linked_service" "sap_r3" {
  count           = var.sap_r3_enabled ? 1 : 0
  name            = "ls-sap-r3-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  type            = "SapEcc"
  type_properties = jsonencode({
    server   = var.sap_r3_server
    systemNumber = var.sap_r3_system_number
    clientId = var.sap_r3_client_id
    username = var.sap_r3_username
    password = var.sap_r3_password
  })
}

# Synapse Linked Service for Databricks
resource "azurerm_synapse_linked_service" "databricks" {
  count           = var.databricks_workspace_id != null ? 1 : 0
  name            = "ls-databricks-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  type            = "AzureDatabricks"
  type_properties = jsonencode({
    domain = var.databricks_workspace_url
    accessToken = var.databricks_access_token
  })
}

# Synapse Dataset for Supply Chain Data
resource "azurerm_synapse_dataset" "supply_chain_data" {
  count           = var.data_lake_storage_account_id != null ? 1 : 0
  name            = "ds-supply-chain-data-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  linked_service_name = azurerm_synapse_linked_service.data_lake[0].name
  type            = "DelimitedText"
  type_properties = jsonencode({
    location = {
      type = "AzureBlobFSLocation"
      fileSystem = "gold"
      folderPath = "supply_chain"
    }
    columnDelimiter = ","
    rowDelimiter = "\n"
    encoding = "UTF-8"
    quoteChar = "\""
    escapeChar = "\\"
    firstRowAsHeader = true
  })
}

# Synapse Dataset for ML Features
resource "azurerm_synapse_dataset" "ml_features" {
  count           = var.data_lake_storage_account_id != null ? 1 : 0
  name            = "ds-ml-features-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  linked_service_name = azurerm_synapse_linked_service.data_lake[0].name
  type            = "DelimitedText"
  type_properties = jsonencode({
    location = {
      type = "AzureBlobFSLocation"
      fileSystem = "ml"
      folderPath = "features"
    }
    columnDelimiter = ","
    rowDelimiter = "\n"
    encoding = "UTF-8"
    quoteChar = "\""
    escapeChar = "\\"
    firstRowAsHeader = true
  })
}

# Synapse Pipeline for Supply Chain Analytics
resource "azurerm_synapse_pipeline" "supply_chain_analytics" {
  name            = "pl-supply-chain-analytics-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id

  description = "Pipeline for supply chain analytics and reporting"
}

# Synapse Pipeline for ML Data Preparation
resource "azurerm_synapse_pipeline" "ml_data_preparation" {
  name            = "pl-ml-data-preparation-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id

  description = "Pipeline for ML data preparation and feature engineering"
}

# Synapse Trigger for Supply Chain Analytics
resource "azurerm_synapse_trigger_schedule" "supply_chain_analytics" {
  name            = "trg-supply-chain-analytics-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  pipeline_id     = azurerm_synapse_pipeline.supply_chain_analytics.id

  frequency = "Day"
  interval  = 1
  start_time = "2024-01-01T05:00:00Z"

  activated = true
}

# Synapse Trigger for ML Data Preparation
resource "azurerm_synapse_trigger_schedule" "ml_data_preparation" {
  name            = "trg-ml-data-preparation-${var.project_name}-${var.environment}"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  pipeline_id     = azurerm_synapse_pipeline.ml_data_preparation.id

  frequency = "Day"
  interval  = 1
  start_time = "2024-01-01T06:00:00Z"

  activated = true
}

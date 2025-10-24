# Databricks Module - Bosch Supply Chain Data Platform
# This module creates the Databricks workspace and related resources

# Databricks Workspace
resource "azurerm_databricks_workspace" "main" {
  name                = "dbw-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location           = var.location
  sku                = var.databricks_sku

  # Network configuration
  custom_parameters {
    no_public_ip        = true
    virtual_network_id   = var.vnet_id
    private_subnet_name  = "subnet-databricks-private-${var.project_name}-${var.environment}"
    public_subnet_name  = "subnet-databricks-public-${var.project_name}-${var.environment}"
    public_subnet_network_security_group_association_id  = var.databricks_public_nsg_id
    private_subnet_network_security_group_association_id = var.databricks_private_nsg_id
  }

  # Managed identity
  managed_resource_group_name = "rg-databricks-${var.project_name}-${var.environment}"

  tags = var.common_tags
}

# Databricks Access Connector for Unity Catalog
resource "azurerm_databricks_access_connector" "unity_catalog" {
  count               = var.enable_unity_catalog ? 1 : 0
  name                = "dac-unity-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location           = var.location

  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
}

# Private Endpoint for Databricks
resource "azurerm_private_endpoint" "databricks" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-databricks-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-databricks-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_databricks_workspace.main.id
    subresource_names              = ["databricks_ui_api"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdns-databricks-${var.project_name}-${var.environment}"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.common_tags
}

# Key Vault Access Policy for Databricks
resource "azurerm_key_vault_access_policy" "databricks" {
  count        = var.key_vault_id != null ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_workspace.main.managed_resource_group_id
  object_id    = azurerm_databricks_workspace.main.managed_resource_group_id

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

# Key Vault Access Policy for Unity Catalog Access Connector
resource "azurerm_key_vault_access_policy" "unity_catalog" {
  count        = var.enable_unity_catalog && var.key_vault_id != null ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_access_connector.unity_catalog[0].identity[0].tenant_id
  object_id    = azurerm_databricks_access_connector.unity_catalog[0].identity[0].principal_id

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

# Storage Account Access for Databricks
resource "azurerm_role_assignment" "databricks_storage_blob_data_contributor" {
  count                = var.data_lake_storage_account_id != null ? 1 : 0
  scope               = var.data_lake_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id        = azurerm_databricks_workspace.main.managed_resource_group_id
}

# Storage Account Access for Unity Catalog
resource "azurerm_role_assignment" "unity_catalog_storage_blob_data_contributor" {
  count                = var.enable_unity_catalog && var.data_lake_storage_account_id != null ? 1 : 0
  scope               = var.data_lake_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id        = azurerm_databricks_access_connector.unity_catalog[0].identity[0].principal_id
}

# Diagnostic Settings for Databricks
resource "azurerm_monitor_diagnostic_setting" "databricks" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-databricks-${var.project_name}-${var.environment}"
  target_resource_id         = azurerm_databricks_workspace.main.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "dbfs"
  }

  enabled_log {
    category = "clusters"
  }

  enabled_log {
    category = "accounts"
  }

  enabled_log {
    category = "jobs"
  }

  enabled_log {
    category = "notebook"
  }

  enabled_log {
    category = "ssh"
  }

  enabled_log {
    category = "workspace"
  }

  enabled_log {
    category = "secrets"
  }

  enabled_log {
    category = "sqlPermissions"
  }

  enabled_log {
    category = "instancePools"
  }

  enabled_log {
    category = "instancePools"
  }

  enabled_log {
    category = "pipelines"
  }

  enabled_log {
    category = "repos"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Databricks Cluster Policy
resource "databricks_cluster_policy" "supply_chain_policy" {
  name = "supply-chain-cluster-policy-${var.environment}"

  definition = jsonencode({
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    "autotermination_minutes" : {
      "type" : "range",
      "maxValue" : 120,
      "defaultValue" : 60
    },
    "node_type_id" : {
      "type" : "allowlist",
      "values" : ["Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2"]
    },
    "driver_node_type_id" : {
      "type" : "allowlist",
      "values" : ["Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2"]
    },
    "spark_version" : {
      "type" : "allowlist",
      "values" : ["13.3.x-scala2.12", "13.3.x-scala2.13"]
    },
    "num_workers" : {
      "type" : "range",
      "minValue" : 1,
      "maxValue" : 10
    }
  })
}

# Databricks Instance Pool
resource "databricks_instance_pool" "supply_chain_pool" {
  instance_pool_name = "supply-chain-pool-${var.environment}"
  min_idle_instances = 0
  max_capacity       = 20
  node_type_id       = var.databricks_cluster_node_type

  idle_instance_autotermination_minutes = 15

  disk_spec {
    disk_type {
      ebs_volume_type = "gp3"
    }
    disk_size = 100
  }

  aws_attributes {
    availability        = "ON_DEMAND"
    zone_id            = "auto"
    spot_bid_price_percent = 50
  }
}

# Databricks Job for Supply Chain ETL
resource "databricks_job" "supply_chain_etl" {
  name = "supply-chain-etl-${var.environment}"

  new_cluster {
    num_workers   = 2
    spark_version = "13.3.x-scala2.12"
    node_type_id = var.databricks_cluster_node_type

    aws_attributes {
      availability        = "ON_DEMAND"
      zone_id            = "auto"
    }
  }

  notebook_task {
    notebook_path = "/SupplyChain/ETL/supply_chain_etl"
  }

  timeout_seconds = 3600
  max_retries     = 2
  retry_on_timeout = true

  schedule {
    quartz_cron_expression = "0 0 2 * * ?" # Daily at 2 AM
    timezone_id           = "UTC"
  }
}

# Databricks Job for ML Pipeline
resource "databricks_job" "supply_chain_ml" {
  name = "supply-chain-ml-${var.environment}"

  new_cluster {
    num_workers   = 3
    spark_version = "13.3.x-scala2.12"
    node_type_id = var.databricks_cluster_node_type

    aws_attributes {
      availability        = "ON_DEMAND"
      zone_id            = "auto"
    }
  }

  notebook_task {
    notebook_path = "/SupplyChain/ML/supply_chain_ml_pipeline"
  }

  timeout_seconds = 7200
  max_retries     = 1
  retry_on_timeout = true

  schedule {
    quartz_cron_expression = "0 0 4 * * ?" # Daily at 4 AM
    timezone_id           = "UTC"
  }
}

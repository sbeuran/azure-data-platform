# Data Lake Module - Bosch Supply Chain Data Platform
# This module creates the data lake storage infrastructure

# Storage Account for Data Lake
resource "azurerm_storage_account" "data_lake" {
  name                     = "stdatalake${var.project_name}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                = var.location
  account_tier            = var.data_lake_tier
  account_replication_type = var.data_lake_replication
  account_kind            = "StorageV2"
  is_hns_enabled          = true

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  # Network access
  public_network_access_enabled = var.enable_public_network_access

  # Encryption
  infrastructure_encryption_enabled = true

  # Blob properties
  blob_properties {
    versioning_enabled = true
    change_feed_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.common_tags
}

# Private Endpoint for Blob Storage
resource "azurerm_private_endpoint" "blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-blob-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name  = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-blob-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.data_lake.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdns-blob-${var.project_name}-${var.environment}"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.common_tags
}

# Private Endpoint for DFS
resource "azurerm_private_endpoint" "dfs" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "pe-dfs-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-dfs-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.data_lake.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdns-dfs-${var.project_name}-${var.environment}"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.common_tags
}

# Data Lake Containers
resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "raw" {
  name                  = "raw"
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "ml" {
  name                  = "ml"
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "backup" {
  name                  = "backup"
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "private"
}

# Storage Account for Logs and Diagnostics
resource "azurerm_storage_account" "logs" {
  name                     = "stlogs${var.project_name}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
  account_kind            = "StorageV2"

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  # Network access
  public_network_access_enabled = var.enable_public_network_access

  tags = var.common_tags
}

# Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = "sttfstate${var.project_name}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
  account_kind            = "StorageV2"

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  # Network access
  public_network_access_enabled = var.enable_public_network_access

  # Blob properties
  blob_properties {
    versioning_enabled = true
    change_feed_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.common_tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Diagnostic Settings for Data Lake
resource "azurerm_monitor_diagnostic_setting" "data_lake" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-datalake-${var.project_name}-${var.environment}"
  target_resource_id         = azurerm_storage_account.data_lake.id
  log_analytics_workspace_id = var.log_analytics_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Storage Account Network Rules
resource "azurerm_storage_account_network_rules" "data_lake" {
  count              = var.enable_private_endpoints ? 1 : 0
  storage_account_id = azurerm_storage_account.data_lake.id

  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = var.allowed_subnet_ids
}

# Storage Account Network Rules for Logs
resource "azurerm_storage_account_network_rules" "logs" {
  count              = var.enable_private_endpoints ? 1 : 0
  storage_account_id = azurerm_storage_account.logs.id

  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = var.allowed_subnet_ids
}

# Storage Account Network Rules for TFState
resource "azurerm_storage_account_network_rules" "tfstate" {
  count              = var.enable_private_endpoints ? 1 : 0
  storage_account_id = azurerm_storage_account.tfstate.id

  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = var.allowed_subnet_ids
}

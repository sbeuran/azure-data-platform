# Databricks Module - Bosch Supply Chain Data Platform
# This module creates the Databricks workspace and related resources

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Managed Identity for Databricks
resource "azurerm_user_assigned_identity" "databricks" {
  name                = "id-databricks-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location           = var.location

  tags = var.common_tags
}

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
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.databricks.principal_id

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
  count        = var.enable_unity_catalog ? 1 : 0
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
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
  scope               = var.data_lake_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id        = azurerm_user_assigned_identity.databricks.principal_id
}

# Storage Account Access for Unity Catalog
resource "azurerm_role_assignment" "unity_catalog_storage_blob_data_contributor" {
  count                = var.enable_unity_catalog ? 1 : 0
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
    category = "repos"
  }
}

# Note: Databricks cluster policies, instance pools, and jobs will be configured
# through the Databricks workspace UI after the infrastructure is deployed
# This is because the databricks provider requires authentication to the workspace

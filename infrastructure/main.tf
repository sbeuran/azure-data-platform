# Bosch Supply Chain Data Platform - Main Infrastructure
# This file defines the core infrastructure components for the Azure data platform

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-bosch-platform"
    storage_account_name = "sttfstatebosch001"
    container_name       = "tfstate"
    key                  = "platform/infra.tfstate"
    use_azuread_auth     = true
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Local variables
locals {
  # Naming convention
  project_name = "bosch-supply-chain"
  environment   = var.environment
  
  # Common tags
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    Owner       = "Data Engineering Team"
    CostCenter  = "IT-DataPlatform"
    Compliance  = "ISO27001"
    DataClass   = "Confidential"
  }

  # Resource naming
  resource_prefix = "${local.project_name}-${local.environment}"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}"
  location = var.location

  tags = local.common_tags
}

# Management Group (if not exists)
resource "azurerm_management_group" "bosch_data_platform" {
  count = var.create_management_group ? 1 : 0
  name  = "mg-bosch-data-platform"

  display_name = "Bosch Data Platform"
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 90

  tags = local.common_tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "ai-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = local.common_tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "kv-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = true
  soft_delete_retention_days = 90

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

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

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = local.common_tags
}

# Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = "sttfstatebosch001"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

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

  tags = local.common_tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Network Module
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = local.project_name
  environment        = local.environment
  common_tags        = local.common_tags
}

# Data Lake Storage Module
module "data_lake" {
  source = "./modules/data-lake"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = local.project_name
  environment        = local.environment
  common_tags        = local.common_tags
  
  depends_on = [module.network]
}

# Databricks Module
module "databricks" {
  source = "./modules/databricks"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = local.project_name
  environment        = local.environment
  common_tags        = local.common_tags
  
  vnet_id            = module.network.vnet_id
  private_subnet_id   = module.network.databricks_private_subnet_id
  public_subnet_id    = module.network.databricks_public_subnet_id
  key_vault_id        = azurerm_key_vault.main.id
  log_analytics_id    = azurerm_log_analytics_workspace.main.id
  
  depends_on = [module.data_lake]
}

# Data Factory Module
module "data_factory" {
  source = "./modules/data-factory"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = local.project_name
  environment        = local.environment
  common_tags        = local.common_tags
  
  key_vault_id       = azurerm_key_vault.main.id
  log_analytics_id   = azurerm_log_analytics_workspace.main.id
  
  depends_on = [module.databricks]
}

# Synapse Module
module "synapse" {
  source = "./modules/synapse"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = local.project_name
  environment        = local.environment
  common_tags        = local.common_tags
  
  key_vault_id       = azurerm_key_vault.main.id
  log_analytics_id   = azurerm_log_analytics_workspace.main.id
  data_lake_id       = module.data_lake.storage_account_id
  
  depends_on = [module.data_factory]
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = local.project_name
  environment        = local.environment
  common_tags        = local.common_tags
  
  log_analytics_id   = azurerm_log_analytics_workspace.main.id
  application_insights_id = azurerm_application_insights.main.id
  
  depends_on = [module.synapse]
}

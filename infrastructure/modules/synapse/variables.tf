# Synapse Module Variables - Simplified Version

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "key_vault_id" {
  description = "ID of the Key Vault"
  type        = string
}

variable "log_analytics_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "data_lake_storage_account_id" {
  description = "ID of the Data Lake storage account"
  type        = string
}

variable "synapse_sql_administrator_login" {
  description = "SQL administrator login for Synapse"
  type        = string
  default     = "sqladmin"
}

variable "synapse_sql_administrator_password" {
  description = "SQL administrator password for Synapse"
  type        = string
  sensitive   = true
}

variable "synapse_sql_pool_sku" {
  description = "SKU for the SQL pool"
  type        = string
  default     = "DW100c"
}

variable "synapse_subnet_id" {
  description = "ID of the Synapse subnet"
  type        = string
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for Synapse"
  type        = bool
  default     = true
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Synapse"
  type        = bool
  default     = true
}

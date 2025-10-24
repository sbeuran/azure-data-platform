# Data Factory Module Variables

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

variable "data_factory_public_network_enabled" {
  description = "Whether Data Factory public network access is enabled"
  type        = bool
  default     = false
}

variable "key_vault_id" {
  description = "ID of the Key Vault"
  type        = string
  default     = null
}

variable "data_lake_storage_account_id" {
  description = "ID of the data lake storage account"
  type        = string
  default     = null
}

variable "data_lake_storage_account_primary_dfs_endpoint" {
  description = "Primary DFS endpoint of the data lake storage account"
  type        = string
  default     = null
}

variable "log_analytics_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for Data Factory"
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs"
  type        = list(string)
  default     = []
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Data Factory"
  type        = bool
  default     = true
}

# SAP Integration Variables
variable "sap_s4hana_enabled" {
  description = "Enable SAP S/4HANA integration"
  type        = bool
  default     = true
}

variable "sap_s4hana_server" {
  description = "SAP S/4HANA server hostname"
  type        = string
  default     = null
}

variable "sap_s4hana_system_number" {
  description = "SAP S/4HANA system number"
  type        = string
  default     = null
}

variable "sap_s4hana_client_id" {
  description = "SAP S/4HANA client ID"
  type        = string
  default     = null
}

variable "sap_s4hana_username" {
  description = "SAP S/4HANA username"
  type        = string
  default     = null
}

variable "sap_s4hana_password" {
  description = "SAP S/4HANA password"
  type        = string
  sensitive   = true
  default     = null
}

variable "sap_r3_enabled" {
  description = "Enable SAP R/3 integration"
  type        = bool
  default     = true
}

variable "sap_r3_server" {
  description = "SAP R/3 server hostname"
  type        = string
  default     = null
}

variable "sap_r3_system_number" {
  description = "SAP R/3 system number"
  type        = string
  default     = null
}

variable "sap_r3_client_id" {
  description = "SAP R/3 client ID"
  type        = string
  default     = null
}

variable "sap_r3_username" {
  description = "SAP R/3 username"
  type        = string
  default     = null
}

variable "sap_r3_password" {
  description = "SAP R/3 password"
  type        = string
  sensitive   = true
  default     = null
}

# Databricks Integration Variables
variable "databricks_workspace_id" {
  description = "ID of the Databricks workspace"
  type        = string
  default     = null
}

variable "databricks_workspace_url" {
  description = "URL of the Databricks workspace"
  type        = string
  default     = null
}

variable "databricks_access_token" {
  description = "Access token for Databricks"
  type        = string
  sensitive   = true
  default     = null
}

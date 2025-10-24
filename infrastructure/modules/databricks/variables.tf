# Databricks Module Variables

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

variable "databricks_sku" {
  description = "Databricks workspace SKU"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium"], var.databricks_sku)
    error_message = "Databricks SKU must be standard or premium."
  }
}

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "databricks_public_nsg_id" {
  description = "ID of the Databricks public NSG"
  type        = string
}

variable "databricks_private_nsg_id" {
  description = "ID of the Databricks private NSG"
  type        = string
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

variable "log_analytics_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for Databricks"
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
  description = "Enable diagnostic settings for Databricks"
  type        = bool
  default     = true
}

variable "enable_unity_catalog" {
  description = "Enable Unity Catalog for Databricks"
  type        = bool
  default     = true
}

variable "databricks_cluster_node_type" {
  description = "Default node type for Databricks clusters"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "databricks_cluster_min_workers" {
  description = "Minimum number of workers for Databricks clusters"
  type        = number
  default     = 1
}

variable "databricks_cluster_max_workers" {
  description = "Maximum number of workers for Databricks clusters"
  type        = number
  default     = 10
}

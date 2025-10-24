# Monitoring Module Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group"
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

variable "log_analytics_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "application_insights_id" {
  description = "ID of the Application Insights"
  type        = string
}

# Alert Configuration
variable "critical_alert_email" {
  description = "Email address for critical alerts"
  type        = string
}

variable "warning_alert_email" {
  description = "Email address for warning alerts"
  type        = string
}

variable "info_alert_email" {
  description = "Email address for info alerts"
  type        = string
}

# Resource IDs for Monitoring
variable "data_factory_id" {
  description = "ID of the Data Factory"
  type        = string
  default     = null
}

variable "databricks_workspace_id" {
  description = "ID of the Databricks workspace"
  type        = string
  default     = null
}

variable "synapse_sql_pool_id" {
  description = "ID of the Synapse SQL pool"
  type        = string
  default     = null
}

variable "data_lake_storage_account_id" {
  description = "ID of the data lake storage account"
  type        = string
  default     = null
}

# Cost Management
variable "enable_cost_management" {
  description = "Enable cost management and budgeting"
  type        = bool
  default     = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 10000
}

# Data Factory Module Variables - Simplified Version

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

variable "data_factory_subnet_id" {
  description = "ID of the Data Factory subnet"
  type        = string
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

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Data Factory"
  type        = bool
  default     = true
}

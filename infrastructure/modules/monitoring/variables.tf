# Monitoring Module Variables - Simplified Version

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

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "log_analytics_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "application_insights_id" {
  description = "ID of the Application Insights instance"
  type        = string
}

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

# Network Module Variables

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

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "databricks_private_subnet_cidr" {
  description = "CIDR block for Databricks private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "databricks_public_subnet_cidr" {
  description = "CIDR block for Databricks public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "data_factory_subnet_cidr" {
  description = "CIDR block for Data Factory subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "synapse_subnet_cidr" {
  description = "CIDR block for Synapse subnet"
  type        = string
  default     = "10.0.4.0/24"
}

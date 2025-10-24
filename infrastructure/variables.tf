# Bosch Supply Chain Data Platform - Variables

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "create_management_group" {
  description = "Whether to create a management group for the platform"
  type        = bool
  default     = true
}

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for the main VNet"
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

# Data Lake Configuration
variable "data_lake_tier" {
  description = "Storage account tier for data lake"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.data_lake_tier)
    error_message = "Data lake tier must be Standard or Premium."
  }
}

variable "data_lake_replication" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.data_lake_replication)
    error_message = "Data lake replication must be one of: LRS, GRS, RAGRS, ZRS."
  }
}

# Databricks Configuration
variable "databricks_sku" {
  description = "Databricks workspace SKU"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium"], var.databricks_sku)
    error_message = "Databricks SKU must be standard or premium."
  }
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

# Data Factory Configuration
variable "data_factory_public_network_enabled" {
  description = "Whether Data Factory public network access is enabled"
  type        = bool
  default     = false
}

# Synapse Configuration
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

variable "synapse_compute_type" {
  description = "Synapse compute type"
  type        = string
  default     = "Serverless"
  
  validation {
    condition     = contains(["Serverless", "Provisioned"], var.synapse_compute_type)
    error_message = "Synapse compute type must be Serverless or Provisioned."
  }
}

# Security Configuration
variable "enable_private_endpoints" {
  description = "Enable private endpoints for all services"
  type        = bool
  default     = true
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for all resources"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 90
  
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 30 and 730."
  }
}

variable "enable_cost_management" {
  description = "Enable Azure Cost Management and Billing"
  type        = bool
  default     = true
}

# Compliance Configuration
variable "compliance_standards" {
  description = "List of compliance standards to implement"
  type        = list(string)
  default     = ["ISO27001", "GDPR", "NIS2"]
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "Confidential"
  
  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted"], var.data_classification)
    error_message = "Data classification must be one of: Public, Internal, Confidential, Restricted."
  }
}

# SAP Integration Configuration
variable "sap_s4hana_enabled" {
  description = "Enable SAP S/4HANA integration"
  type        = bool
  default     = true
}

variable "sap_r3_enabled" {
  description = "Enable SAP R/3 integration"
  type        = bool
  default     = true
}

# ML/AI Configuration
variable "ml_workspace_enabled" {
  description = "Enable Azure Machine Learning workspace"
  type        = bool
  default     = true
}

variable "cognitive_services_enabled" {
  description = "Enable Azure Cognitive Services"
  type        = bool
  default     = true
}

# Cost Optimization
variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown for development resources"
  type        = bool
  default     = true
}

variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

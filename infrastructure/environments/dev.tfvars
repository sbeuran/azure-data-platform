# Development Environment Configuration
# Bosch Supply Chain Data Platform

# Environment
environment = "dev"
location    = "West Europe"

# Network Configuration
vnet_address_space = ["10.0.0.0/16"]
databricks_private_subnet_cidr = "10.0.1.0/24"
databricks_public_subnet_cidr  = "10.0.2.0/24"
data_factory_subnet_cidr       = "10.0.3.0/24"
synapse_subnet_cidr            = "10.0.4.0/24"

# Data Lake Configuration
data_lake_tier       = "Standard"
data_lake_replication = "LRS"

# Databricks Configuration
databricks_sku = "standard"
databricks_cluster_node_type = "Standard_DS3_v2"
databricks_cluster_min_workers = 1
databricks_cluster_max_workers = 5

# Data Factory Configuration
data_factory_public_network_enabled = false

# Synapse Configuration
synapse_sql_administrator_login = "sqladmin"
synapse_sql_administrator_password = "BoschSupplyChain2024!"
synapse_sql_pool_sku = "DW100c"

# Security Configuration
enable_private_endpoints = true
enable_diagnostic_settings = true

# Monitoring Configuration
log_retention_days = 30
enable_cost_management = true

# Compliance Configuration
compliance_standards = ["ISO27001", "GDPR"]
data_classification = "Confidential"

# SAP Integration Configuration
sap_s4hana_enabled = true
sap_r3_enabled = true

# ML/AI Configuration
ml_workspace_enabled = true
cognitive_services_enabled = true

# Cost Optimization
enable_auto_shutdown = true
enable_spot_instances = false

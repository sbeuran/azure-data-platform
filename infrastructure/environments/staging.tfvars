# Staging Environment Configuration
# Bosch Supply Chain Data Platform

# Environment
environment = "staging"
location    = "West Europe"

# Network Configuration
vnet_address_space = ["10.1.0.0/16"
databricks_private_subnet_cidr = "10.1.1.0/24"
databricks_public_subnet_cidr  = "10.1.2.0/24"
data_factory_subnet_cidr       = "10.1.3.0/24"
synapse_subnet_cidr            = "10.1.4.0/24"

# Data Lake Configuration
data_lake_tier       = "Standard"
data_lake_replication = "GRS"

# Databricks Configuration
databricks_sku = "premium"
databricks_cluster_node_type = "Standard_DS4_v2"
databricks_cluster_min_workers = 2
databricks_cluster_max_workers = 10

# Data Factory Configuration
data_factory_public_network_enabled = false

# Synapse Configuration
synapse_sql_administrator_login = "sqladmin"
synapse_sql_administrator_password = "BoschSupplyChain2024!"
synapse_sql_pool_sku = "DW200c"

# Security Configuration
enable_private_endpoints = true
enable_diagnostic_settings = true

# Monitoring Configuration
log_retention_days = 90
enable_cost_management = true

# Compliance Configuration
compliance_standards = ["ISO27001", "GDPR", "NIS2"]
data_classification = "Confidential"

# SAP Integration Configuration
sap_s4hana_enabled = true
sap_r3_enabled = true

# ML/AI Configuration
ml_workspace_enabled = true
cognitive_services_enabled = true

# Cost Optimization
enable_auto_shutdown = false
enable_spot_instances = false

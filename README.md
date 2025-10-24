# Bosch Supply Chain Data Platform

## Overview

This repository contains the infrastructure and data platform implementation for Bosch's supply chain prediction and logistics issue resolution system. The platform is built on Azure using modern cloud-native technologies and follows enterprise-grade security, scalability, and reliability principles.

## Architecture

The platform implements a comprehensive data architecture that includes:

- **Data Ingestion**: Multi-source data collection from SAP S/4HANA, logistics partners, IoT devices, and external APIs
- **Data Processing**: Real-time and batch processing using Azure Databricks with Delta Lake
- **Data Storage**: Multi-zone data lake (Bronze/Silver/Gold) with Azure Data Lake Storage Gen2
- **Data Analytics**: Azure Synapse Analytics for data warehousing and business intelligence
- **ML/AI**: Machine learning pipelines for predictive analytics and anomaly detection
- **Security**: Enterprise-grade security with Azure Key Vault, RBAC, and private endpoints
- **Monitoring**: Comprehensive observability with Azure Monitor and custom dashboards

## Key Features

### Supply Chain Analytics
- **Predictive Analytics**: Forecast demand, identify potential stockouts, and predict shipping delays
- **Anomaly Detection**: Real-time detection of supply chain disruptions and logistics issues
- **Root Cause Analysis**: Automated analysis of supply chain failures and bottlenecks
- **Performance Monitoring**: Track KPIs across the entire supply chain ecosystem

### Data Sources
- SAP S/4HANA (Materials Management, Sales & Distribution, Production Planning)
- Logistics Partners (Carriers, 3PL providers)
- IoT Sensors (Warehouse, Factory, Transportation)
- External APIs (Weather, Traffic, Market data)
- ERP Systems (Supplier data, Purchase orders)

### Technology Stack
- **Cloud Platform**: Microsoft Azure
- **Data Processing**: Azure Databricks, Apache Spark, Delta Lake
- **Data Orchestration**: Azure Data Factory
- **Data Warehouse**: Azure Synapse Analytics
- **ML/AI**: Azure Machine Learning, MLflow, TensorFlow
- **Infrastructure**: Terraform, Azure Resource Manager
- **Security**: Azure Key Vault, Azure Active Directory, Private Endpoints
- **Monitoring**: Azure Monitor, Log Analytics, Application Insights

## Project Structure

```
├── infrastructure/           # Terraform infrastructure as code
│   ├── environments/        # Environment-specific configurations
│   ├── modules/            # Reusable Terraform modules
│   └── policies/           # Azure Policy definitions
├── data/                   # Data processing and analytics
│   ├── databricks/         # Databricks notebooks and jobs
│   ├── data-factory/       # ADF pipelines and datasets
│   └── synapse/            # Synapse SQL scripts and procedures
├── ml/                     # Machine learning models and pipelines
│   ├── models/             # ML model definitions
│   ├── pipelines/          # ML pipeline orchestration
│   └── notebooks/          # Jupyter notebooks for experimentation
├── security/              # Security configurations and policies
├── monitoring/            # Monitoring and alerting configurations
├── docs/                  # Documentation and runbooks
└── scripts/               # Deployment and utility scripts
```

## Getting Started

### Prerequisites
- Azure CLI installed and configured
- Terraform >= 1.5.0
- Python >= 3.9
- Git

### Deployment
1. Clone the repository
2. Configure Azure credentials
3. Update environment-specific variables
4. Deploy infrastructure using Terraform
5. Configure data pipelines and ML models

## Security & Compliance

The platform implements enterprise-grade security controls:
- Private endpoints for all data services
- Azure Key Vault for secrets management
- Role-based access control (RBAC)
- Data encryption at rest and in transit
- Network security groups and firewalls
- Audit logging and compliance reporting

## Monitoring & Observability

Comprehensive monitoring includes:
- Infrastructure health and performance metrics
- Data pipeline success rates and latency
- ML model performance and drift detection
- Security events and compliance violations
- Cost optimization and resource utilization

## Azure Resources

### Resource Groups
- **rg-bosch-dev**: Main development environment (West Europe)
- **rg-tfstate-bosch-platform**: Terraform state storage (West Europe)
- **rg-databricks-bosch-dev**: Databricks managed resources (West Europe)
- **databricks-rg-dbw-bosch-dev-wx28ne9m23i93**: Databricks workspace resources (West Europe)
- **synapseworkspace-managedrg-e16ed22f-585c-42aa-907a-acca2d8cb0f0**: Synapse managed resources (West Europe)

### Core Services

#### Data Processing & Analytics
- **Azure Databricks Workspace**: `dbw-bosch-dev`
  - URL: https://adb-3621103120796221.1.azuredatabricks.net
  - SKU: Premium
  - Status: Succeeded
- **Azure Synapse Analytics**: `synapse-bosch-dev`
  - Web URL: https://web.azuresynapse.net?workspace=%2fsubscriptions%2f63f441c1-d433-44d4-928a-2f0809824555%2fresourceGroups%2frg-bosch-dev%2fproviders%2fMicrosoft.Synapse%2fworkspaces%2fsynapse-bosch-dev
  - SQL Endpoint: synapse-bosch-dev.sql.azuresynapse.net
  - Status: Succeeded
- **Azure Data Factory**: `adf-bosch-dev-001`
  - Status: Active

#### Data Storage
- **Data Lake Storage**: `stdatalakeboschdev`
  - Containers: bronze, silver, gold, raw, processed, machine-learning, backup
- **Logs Storage**: `stlogsboschdev`
- **Terraform State Storage**: `sttfstateboschdev`

#### Security & Identity
- **Azure Key Vault**: `kv-bosch-dev`
- **User Assigned Identity**: `id-databricks-bosch-dev`
- **Unity Catalog Access Connector**: `dac-unity-bosch-dev`

#### Networking
- **Virtual Network**: `vnet-bosch-dev`
- **Private Endpoints**: 
  - Databricks: `pe-databricks-bosch-dev`
  - Data Factory: `pe-data-factory-bosch-dev`
  - Data Lake: `pe-blob-bosch-dev`, `pe-dfs-bosch-dev`
- **Network Security Groups**: 
  - Databricks: `nsg-databricks-private-bosch-dev`, `nsg-databricks-public-bosch-dev`
  - Synapse: `nsg-synapse-bosch-dev`
  - Data Factory: `nsg-data-factory-bosch-dev`

#### Monitoring & Observability
- **Log Analytics Workspace**: `law-bosch-dev`
- **Application Insights**: `ai-bosch-dev`
- **Action Groups**: 
  - Critical: `ag-critical-bosch-dev`
  - Warning: `ag-warning-bosch-dev`
  - Info: `ag-info-bosch-dev`

### Access Information

#### Databricks Workspace
- **URL**: https://adb-3621103120796221.1.azuredatabricks.net
- **Authentication**: Azure AD SSO
- **Note**: Requires workspace-level permissions to be granted by administrator

#### Synapse Analytics
- **Web URL**: https://web.azuresynapse.net?workspace=%2fsubscriptions%2f63f441c1-d433-44d4-928a-2f0809824555%2fresourceGroups%2frg-bosch-dev%2fproviders%2fMicrosoft.Synapse%2fworkspaces%2fsynapse-bosch-dev
- **SQL Endpoint**: synapse-bosch-dev.sql.azuresynapse.net
- **Authentication**: Azure AD SSO

#### Data Factory
- **Portal URL**: https://portal.azure.com/#@samuelbeurandevopshotmail.onmicrosoft.com/resource/subscriptions/63f441c1-d433-44d4-928a-2f0809824555/resourceGroups/rg-bosch-dev/providers/Microsoft.DataFactory/factories/adf-bosch-dev-001
- **Authentication**: Azure AD SSO

#### Data Lake Storage
- **Storage Account**: stdatalakeboschdev
- **Access**: Via Azure Portal or Azure Storage Explorer
- **Authentication**: Azure AD SSO

## Contributing

Please follow the established coding standards and security practices when contributing to this project.

## License

This project is proprietary to Bosch and contains confidential information.

# Bosch Supply Chain Data Platform - Setup Guide

## Prerequisites

### 1. Azure Subscription
- **Current Status**: Subscription is disabled and in read-only mode
- **Action Required**: Re-enable the subscription to proceed with deployment
- **Subscription ID**: `49daa054-c7d7-49ad-9e8f-033cc2affadc`
- **Tenant ID**: `0504f8be-fd82-4b49-984d-02af4a92764b`

### 2. GitHub Repository
- **Repository**: https://github.com/sbeuran/azure-data-platform
- **Status**: ✅ Code pushed successfully
- **Next Step**: Configure secrets (see below)

## GitHub Secrets Configuration

### Required Secrets for GitHub Actions

Go to: **Settings > Secrets and variables > Actions** in your GitHub repository

#### Azure Authentication
```
AZURE_CLIENT_ID: <to-be-created-after-subscription-re-enabled>
AZURE_CLIENT_SECRET: <to-be-created-after-subscription-re-enabled>
AZURE_TENANT_ID: 0504f8be-fd82-4b49-984d-02af4a92764b
AZURE_SUBSCRIPTION_ID: 49daa054-c7d7-49ad-9e8f-033cc2affadc
```

#### Databricks Configuration
```
DATABRICKS_HOST: <your-databricks-workspace-url>
DATABRICKS_TOKEN: <your-databricks-access-token>
ETL_JOB_ID: <databricks-etl-job-id>
ML_JOB_ID: <databricks-ml-job-id>
```

#### Security Tools
```
SNYK_TOKEN: <your-snyk-token>
INFRACOST_API_KEY: <your-infracost-api-key>
```

#### SAP Configuration
```
SAP_S4HANA_SERVER: <your-sap-s4hana-server>
SAP_S4HANA_SYSTEM_NUMBER: <your-sap-system-number>
SAP_S4HANA_CLIENT_ID: <your-sap-client-id>
SAP_S4HANA_USERNAME: <your-sap-username>
SAP_S4HANA_PASSWORD: <your-sap-password>

SAP_R3_SERVER: <your-sap-r3-server>
SAP_R3_SYSTEM_NUMBER: <your-sap-r3-system-number>
SAP_R3_CLIENT_ID: <your-sap-r3-client-id>
SAP_R3_USERNAME: <your-sap-r3-username>
SAP_R3_PASSWORD: <your-sap-r3-password>
```

#### Logistics API Configuration
```
LOGISTICS_API_BASE_URL: https://api.logistics-demo.com
LOGISTICS_API_KEY: demo-api-key-12345
LOGISTICS_API_SECRET: demo-api-secret-67890
```

#### Monitoring Configuration
```
CRITICAL_ALERT_EMAIL: samuel.beuran98@gmail.com
WARNING_ALERT_EMAIL: samuel.beuran98@gmail.com
INFO_ALERT_EMAIL: samuel.beuran98@gmail.com
```

## Demo Data Sources

### 1. Logistics API (Demo)
- **Base URL**: https://api.logistics-demo.com
- **API Key**: demo-api-key-12345
- **API Secret**: demo-api-secret-67890
- **Endpoints**:
  - `GET /shipments` - Get all shipments
  - `GET /carriers` - Get carrier information
  - `GET /routes` - Get route information
  - `POST /shipments` - Create new shipment

### 2. IoT Sensor API (Demo)
- **Base URL**: https://api.iot-demo.com
- **API Key**: iot-demo-key-54321
- **Endpoints**:
  - `GET /sensors/warehouse` - Warehouse sensor data
  - `GET /sensors/factory` - Factory sensor data
  - `GET /sensors/transport` - Transportation sensor data

### 3. Weather API (Demo)
- **Base URL**: https://api.weather-demo.com
- **API Key**: weather-demo-key-98765
- **Endpoints**:
  - `GET /weather/current` - Current weather conditions
  - `GET /weather/forecast` - Weather forecast

## Deployment Steps

### Step 1: Re-enable Azure Subscription
1. Go to Azure Portal
2. Navigate to Subscriptions
3. Select your subscription
4. Click "Re-enable subscription"
5. Wait for confirmation

### Step 2: Create Service Principal
After subscription is re-enabled, run:
```bash
az ad sp create-for-rbac --name 'bosch-supply-chain-github-actions' --role Contributor --scopes /subscriptions/49daa054-c7d7-49ad-9e8f-033cc2affadc
```

### Step 3: Configure GitHub Secrets
Add all the secrets listed above to your GitHub repository.

### Step 4: Deploy Infrastructure
```bash
# Deploy development environment
./scripts/deploy.sh dev westeurope

# Deploy staging environment
./scripts/deploy.sh staging westeurope

# Deploy production environment
./scripts/deploy.sh prod westeurope
```

### Step 5: Configure SAP Connections
After infrastructure is deployed:
1. Configure SAP S/4HANA connection in Data Factory
2. Configure SAP R/3 connection in Data Factory
3. Test data extraction from SAP systems

### Step 6: Test Data Pipelines
1. Run ETL pipeline manually
2. Verify data quality checks
3. Test ML model training
4. Validate monitoring and alerting

## Current Status

### ✅ Completed
- [x] Code pushed to GitHub repository
- [x] Terraform infrastructure code created
- [x] Data processing pipelines created
- [x] CI/CD workflows configured
- [x] Documentation created
- [x] Demo data sources configured

### ⏳ Pending (Requires Subscription Re-enablement)
- [ ] Azure service principal creation
- [ ] GitHub secrets configuration
- [ ] Infrastructure deployment
- [ ] SAP connections setup
- [ ] Data pipeline testing

## Troubleshooting

### Common Issues

#### 1. Subscription Disabled
- **Error**: "ReadOnlyDisabledSubscription"
- **Solution**: Re-enable subscription in Azure Portal

#### 2. Service Principal Creation Failed
- **Error**: "Role assignment creation failed"
- **Solution**: Ensure subscription is active and you have Owner permissions

#### 3. GitHub Actions Failed
- **Error**: "Azure login failed"
- **Solution**: Verify all Azure secrets are correctly configured

#### 4. Terraform State Lock
- **Error**: "State is locked"
- **Solution**: Check for concurrent deployments or manually unlock state

### Support Contacts
- **Technical Issues**: samuel.beuran98@gmail.com
- **Azure Support**: Azure Portal > Help + Support
- **GitHub Issues**: Repository Issues tab

## Next Steps After Deployment

1. **Configure SAP Systems**
   - Set up SAP S/4HANA OData services
   - Configure SAP R/3 RFC connections
   - Test data extraction

2. **Setup Monitoring**
   - Configure alert rules
   - Set up dashboards
   - Test notification channels

3. **Data Pipeline Testing**
   - Run ETL pipelines
   - Validate data quality
   - Test ML models

4. **User Training**
   - Train data engineers on platform usage
   - Train business users on dashboards
   - Document operational procedures

5. **Go-Live Preparation**
   - Performance testing
   - Security validation
   - Backup and recovery testing
   - Documentation finalization

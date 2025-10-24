#!/usr/bin/env python3
"""
Setup Azure secrets for GitHub Actions
This script helps configure the necessary secrets for the CI/CD pipeline
"""

import subprocess
import json
import sys

def run_command(command):
    """Run a command and return the output"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error running command: {command}")
            print(f"Error: {result.stderr}")
            return None
        return result.stdout.strip()
    except Exception as e:
        print(f"Exception running command: {command}")
        print(f"Exception: {e}")
        return None

def get_azure_credentials():
    """Get Azure credentials from Azure CLI"""
    print("Getting Azure credentials...")
    
    # Get current subscription
    subscription_output = run_command("az account show")
    if not subscription_output:
        print("Error: Could not get Azure subscription. Please run 'az login' first.")
        return None
    
    subscription_info = json.loads(subscription_output)
    subscription_id = subscription_info['id']
    tenant_id = subscription_info['tenantId']
    
    print(f"Subscription ID: {subscription_id}")
    print(f"Tenant ID: {tenant_id}")
    
    return {
        'subscription_id': subscription_id,
        'tenant_id': tenant_id
    }

def create_service_principal():
    """Create a service principal for GitHub Actions"""
    print("Creating service principal for GitHub Actions...")
    
    # Create service principal
    sp_output = run_command("az ad sp create-for-rbac --name 'bosch-supply-chain-github-actions' --role Contributor --scopes /subscriptions/49daa054-c7d7-49ad-9e8f-033cc2affadc")
    if not sp_output:
        print("Error: Could not create service principal")
        return None
    
    sp_info = json.loads(sp_output)
    return {
        'client_id': sp_info['appId'],
        'client_secret': sp_info['password'],
        'tenant_id': sp_info['tenant']
    }

def main():
    """Main function to setup Azure secrets"""
    print("=== Azure Secrets Setup for GitHub Actions ===")
    print()
    
    # Check if Azure CLI is logged in
    login_check = run_command("az account show")
    if not login_check:
        print("Error: Azure CLI is not logged in. Please run 'az login' first.")
        sys.exit(1)
    
    # Get Azure credentials
    azure_creds = get_azure_credentials()
    if not azure_creds:
        sys.exit(1)
    
    # Create service principal
    sp_creds = create_service_principal()
    if not sp_creds:
        sys.exit(1)
    
    print()
    print("=== GitHub Secrets Configuration ===")
    print()
    print("Please add the following secrets to your GitHub repository:")
    print("Repository: https://github.com/sbeuran/azure-data-platform")
    print()
    print("Go to: Settings > Secrets and variables > Actions")
    print()
    print("Add these secrets:")
    print()
    print(f"AZURE_CLIENT_ID: {sp_creds['client_id']}")
    print(f"AZURE_CLIENT_SECRET: {sp_creds['client_secret']}")
    print(f"AZURE_TENANT_ID: {sp_creds['tenant_id']}")
    print(f"AZURE_SUBSCRIPTION_ID: {azure_creds['subscription_id']}")
    print()
    print("Additional secrets to add manually:")
    print("DATABRICKS_HOST: <your-databricks-workspace-url>")
    print("DATABRICKS_TOKEN: <your-databricks-access-token>")
    print("ETL_JOB_ID: <databricks-etl-job-id>")
    print("ML_JOB_ID: <databricks-ml-job-id>")
    print("SNYK_TOKEN: <your-snyk-token>")
    print("INFRACOST_API_KEY: <your-infracost-api-key>")
    print()
    print("=== SAP Configuration ===")
    print()
    print("SAP S/4HANA Configuration:")
    print("SAP_S4HANA_SERVER: <your-sap-s4hana-server>")
    print("SAP_S4HANA_SYSTEM_NUMBER: <your-sap-system-number>")
    print("SAP_S4HANA_CLIENT_ID: <your-sap-client-id>")
    print("SAP_S4HANA_USERNAME: <your-sap-username>")
    print("SAP_S4HANA_PASSWORD: <your-sap-password>")
    print()
    print("SAP R/3 Configuration:")
    print("SAP_R3_SERVER: <your-sap-r3-server>")
    print("SAP_R3_SYSTEM_NUMBER: <your-sap-r3-system-number>")
    print("SAP_R3_CLIENT_ID: <your-sap-r3-client-id>")
    print("SAP_R3_USERNAME: <your-sap-r3-username>")
    print("SAP_R3_PASSWORD: <your-sap-r3-password>")
    print()
    print("=== Logistics API Configuration ===")
    print()
    print("Logistics Partner API Credentials:")
    print("LOGISTICS_API_BASE_URL: https://api.logistics-demo.com")
    print("LOGISTICS_API_KEY: demo-api-key-12345")
    print("LOGISTICS_API_SECRET: demo-api-secret-67890")
    print()
    print("=== Monitoring Configuration ===")
    print()
    print("Alert Email Addresses:")
    print("CRITICAL_ALERT_EMAIL: samuel.beuran98@gmail.com")
    print("WARNING_ALERT_EMAIL: samuel.beuran98@gmail.com")
    print("INFO_ALERT_EMAIL: samuel.beuran98@gmail.com")
    print()
    print("=== Next Steps ===")
    print()
    print("1. Add all the secrets above to your GitHub repository")
    print("2. Run the deployment script: ./scripts/deploy.sh dev westeurope")
    print("3. Monitor the deployment in GitHub Actions")
    print("4. Configure SAP connections after infrastructure is deployed")
    print("5. Test the data pipelines and ML models")
    print()
    print("=== Demo Data Sources ===")
    print()
    print("For testing purposes, the following demo APIs are available:")
    print("- Logistics API: https://api.logistics-demo.com")
    print("- IoT Sensor API: https://api.iot-demo.com")
    print("- Weather API: https://api.weather-demo.com")
    print()
    print("Demo credentials are provided above for immediate testing.")

if __name__ == "__main__":
    main()

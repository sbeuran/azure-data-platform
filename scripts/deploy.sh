#!/bin/bash

# Bosch Supply Chain Data Platform - Deployment Script
# This script deploys the entire data platform infrastructure and components

set -e

# Configuration
ENVIRONMENT=${1:-dev}
LOCATION=${2:-westeurope}
RESOURCE_GROUP_NAME="rg-bosch-supply-chain-${ENVIRONMENT}"
STORAGE_ACCOUNT_NAME="sttfstatebosch001"
CONTAINER_NAME="tfstate"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is not installed. Please install it first."
        exit 1
    fi
    
    log_info "Prerequisites check completed successfully"
}

# Azure login and setup
azure_setup() {
    log_info "Setting up Azure environment..."
    
    # Login to Azure
    az login --use-device-code
    
    # Set subscription
    az account set --subscription "49daa054-c7d7-49ad-9e8f-033cc2affadc"
    
    # Create resource group for Terraform state
    az group create \
        --name "rg-tfstate-bosch-platform" \
        --location "$LOCATION" \
        --tags Project=bosch-supply-chain Environment=shared
    
    # Create storage account for Terraform state
    az storage account create \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "rg-tfstate-bosch-platform" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --access-tier Hot \
        --https-only true \
        --min-tls-version TLS1_2
    
    # Create container for Terraform state
    az storage container create \
        --name "$CONTAINER_NAME" \
        --account-name "$STORAGE_ACCOUNT_NAME"
    
    log_info "Azure setup completed successfully"
}

# Deploy infrastructure
deploy_infrastructure() {
    log_info "Deploying infrastructure for environment: $ENVIRONMENT"
    
    cd infrastructure
    
    # Initialize Terraform
    terraform init \
        -backend-config="resource_group_name=rg-tfstate-bosch-platform" \
        -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
        -backend-config="container_name=$CONTAINER_NAME" \
        -backend-config="key=platform/infra-$ENVIRONMENT.tfstate" \
        -backend-config="use_azuread_auth=true"
    
    # Validate Terraform configuration
    terraform validate
    
    # Format Terraform files
    terraform fmt -recursive
    
    # Plan Terraform deployment
    terraform plan \
        -var-file="environments/$ENVIRONMENT.tfvars" \
        -out=tfplan
    
    # Apply Terraform configuration
    terraform apply tfplan
    
    # Get outputs
    terraform output -json > ../outputs/terraform-outputs-$ENVIRONMENT.json
    
    cd ..
    
    log_info "Infrastructure deployment completed successfully"
}

# Deploy data components
deploy_data_components() {
    log_info "Deploying data components..."
    
    # Install Python dependencies
    pip install -r requirements.txt
    
    # Deploy Databricks notebooks
    python scripts/deploy_databricks_notebooks.py --environment $ENVIRONMENT
    
    # Deploy Data Factory pipelines
    python scripts/deploy_data_factory_pipelines.py --environment $ENVIRONMENT
    
    # Deploy Synapse SQL scripts
    python scripts/deploy_synapse_sql.py --environment $ENVIRONMENT
    
    # Setup monitoring
    python scripts/setup_monitoring.py --environment $ENVIRONMENT
    
    log_info "Data components deployment completed successfully"
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    # Run data quality tests
    python scripts/data_quality_check.py --environment $ENVIRONMENT
    
    # Run performance tests
    python scripts/performance_test.py --environment $ENVIRONMENT
    
    # Run security tests
    python scripts/security_test.py --environment $ENVIRONMENT
    
    log_info "Tests completed successfully"
}

# Main deployment function
main() {
    log_info "Starting Bosch Supply Chain Data Platform deployment..."
    log_info "Environment: $ENVIRONMENT"
    log_info "Location: $LOCATION"
    
    # Check prerequisites
    check_prerequisites
    
    # Setup Azure
    azure_setup
    
    # Deploy infrastructure
    deploy_infrastructure
    
    # Deploy data components
    deploy_data_components
    
    # Run tests
    run_tests
    
    log_info "Deployment completed successfully!"
    log_info "Platform is ready for use."
    
    # Display important information
    echo ""
    echo "=========================================="
    echo "Deployment Summary"
    echo "=========================================="
    echo "Environment: $ENVIRONMENT"
    echo "Location: $LOCATION"
    echo "Resource Group: $RESOURCE_GROUP_NAME"
    echo "Terraform State: $STORAGE_ACCOUNT_NAME/$CONTAINER_NAME"
    echo ""
    echo "Next Steps:"
    echo "1. Configure SAP S/4HANA and R/3 connections"
    echo "2. Set up data sources and connectors"
    echo "3. Configure monitoring and alerting"
    echo "4. Test data pipelines"
    echo "5. Deploy ML models"
    echo ""
    echo "Documentation: docs/README.md"
    echo "Monitoring: Azure Portal > Monitor"
    echo "=========================================="
}

# Error handling
trap 'log_error "Deployment failed at line $LINENO"' ERR

# Run main function
main "$@"

#!/bin/bash

# Bosch Supply Chain Data Platform - Alternative Deployment Script
# This script provides alternative deployment options when Azure subscription is disabled

set -e

# Configuration
ENVIRONMENT=${1:-dev}
LOCATION=${2:-westeurope}
RESOURCE_GROUP_NAME="rg-bosch-supply-chain-${ENVIRONMENT}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_blue() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check Azure subscription status
check_azure_subscription() {
    log_info "Checking Azure subscription status..."
    
    # Check if logged in
    if ! az account show &> /dev/null; then
        log_error "Not logged into Azure CLI. Please run 'az login' first."
        exit 1
    fi
    
    # Check subscription status
    SUBSCRIPTION_STATUS=$(az account show --query "state" -o tsv)
    if [ "$SUBSCRIPTION_STATUS" = "Disabled" ]; then
        log_error "Azure subscription is disabled and in read-only mode."
        log_error "Cannot deploy infrastructure until subscription is re-enabled."
        log_warn "Please re-enable your Azure subscription in the Azure Portal."
        log_warn "Go to: Azure Portal > Subscriptions > Your Subscription > Re-enable"
        return 1
    fi
    
    log_info "Azure subscription is active: $SUBSCRIPTION_STATUS"
    return 0
}

# Setup demo environment
setup_demo_environment() {
    log_info "Setting up demo environment for testing..."
    
    # Create demo data directory
    mkdir -p demo-data/{shipments,carriers,routes,sensors,weather}
    
    # Generate demo data
    log_info "Generating demo data..."
    python3 scripts/generate_demo_data.py --output demo-data/
    
    # Start demo API server
    log_info "Starting demo API server..."
    python3 scripts/demo_api_server.py &
    DEMO_API_PID=$!
    echo $DEMO_API_PID > demo-api.pid
    
    log_info "Demo API server started with PID: $DEMO_API_PID"
    log_info "API endpoints available at:"
    log_info "  - http://localhost:5000/shipments"
    log_info "  - http://localhost:5000/carriers"
    log_info "  - http://localhost:5000/routes"
    log_info "  - http://localhost:5000/sensors"
    log_info "  - http://localhost:5000/weather"
    log_info "  - http://localhost:5000/health"
}

# Deploy using GitHub Actions
deploy_via_github_actions() {
    log_info "Deploying via GitHub Actions..."
    
    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        log_error "Not in a git repository. Please run from the project root."
        exit 1
    fi
    
    # Check if remote is configured
    if ! git remote get-url origin &> /dev/null; then
        log_error "Git remote 'origin' not configured."
        exit 1
    fi
    
    # Push changes to trigger GitHub Actions
    log_info "Pushing changes to trigger GitHub Actions deployment..."
    git add .
    git commit -m "Trigger deployment for $ENVIRONMENT environment" || true
    git push origin main
    
    log_info "GitHub Actions deployment triggered."
    log_info "Monitor deployment at: https://github.com/sbeuran/azure-data-platform/actions"
}

# Deploy locally with Terraform (if subscription is active)
deploy_locally() {
    log_info "Deploying locally with Terraform..."
    
    cd infrastructure
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init \
        -backend-config="resource_group_name=rg-tfstate-bosch-platform" \
        -backend-config="storage_account_name=sttfstatebosch001" \
        -backend-config="container_name=tfstate" \
        -backend-config="key=platform/infra-$ENVIRONMENT.tfstate" \
        -backend-config="use_azuread_auth=true"
    
    # Validate configuration
    log_info "Validating Terraform configuration..."
    terraform validate
    
    # Format files
    log_info "Formatting Terraform files..."
    terraform fmt -recursive
    
    # Plan deployment
    log_info "Planning Terraform deployment..."
    terraform plan \
        -var-file="environments/$ENVIRONMENT.tfvars" \
        -out=tfplan
    
    # Apply configuration
    log_info "Applying Terraform configuration..."
    terraform apply tfplan
    
    # Get outputs
    log_info "Getting Terraform outputs..."
    terraform output -json > ../outputs/terraform-outputs-$ENVIRONMENT.json
    
    cd ..
    
    log_info "Local deployment completed successfully!"
}

# Setup GitHub secrets
setup_github_secrets() {
    log_info "Setting up GitHub secrets..."
    
    log_blue "=== GitHub Secrets Configuration ==="
    log_blue "Please add the following secrets to your GitHub repository:"
    log_blue "Repository: https://github.com/sbeuran/azure-data-platform"
    log_blue "Go to: Settings > Secrets and variables > Actions"
    log_blue ""
    log_blue "Required secrets:"
    log_blue "AZURE_CLIENT_ID: <create-service-principal>"
    log_blue "AZURE_CLIENT_SECRET: <create-service-principal>"
    log_blue "AZURE_TENANT_ID: 0504f8be-fd82-4b49-984d-02af4a92764b"
    log_blue "AZURE_SUBSCRIPTION_ID: 49daa054-c7d7-49ad-9e8f-033cc2affadc"
    log_blue "DATABRICKS_HOST: <your-databricks-workspace-url>"
    log_blue "DATABRICKS_TOKEN: <your-databricks-access-token>"
    log_blue "SNYK_TOKEN: <your-snyk-token>"
    log_blue "INFRACOST_API_KEY: <your-infracost-api-key>"
    log_blue ""
    log_blue "Demo API credentials:"
    log_blue "LOGISTICS_API_BASE_URL: http://localhost:5000"
    log_blue "LOGISTICS_API_KEY: demo-api-key-12345"
    log_blue "LOGISTICS_API_SECRET: demo-api-secret-67890"
    log_blue ""
    log_blue "Alert emails:"
    log_blue "CRITICAL_ALERT_EMAIL: samuel.beuran98@gmail.com"
    log_blue "WARNING_ALERT_EMAIL: samuel.beuran98@gmail.com"
    log_blue "INFO_ALERT_EMAIL: samuel.beuran98@gmail.com"
}

# Main deployment function
main() {
    log_info "Starting Bosch Supply Chain Data Platform deployment..."
    log_info "Environment: $ENVIRONMENT"
    log_info "Location: $LOCATION"
    
    # Check Azure subscription
    if check_azure_subscription; then
        log_info "Azure subscription is active. Proceeding with deployment..."
        
        # Choose deployment method
        log_blue "Choose deployment method:"
        log_blue "1. Deploy locally with Terraform"
        log_blue "2. Deploy via GitHub Actions"
        log_blue "3. Setup demo environment only"
        
        read -p "Enter your choice (1-3): " choice
        
        case $choice in
            1)
                deploy_locally
                ;;
            2)
                deploy_via_github_actions
                ;;
            3)
                setup_demo_environment
                ;;
            *)
                log_error "Invalid choice. Exiting."
                exit 1
                ;;
        esac
    else
        log_warn "Azure subscription is disabled. Setting up demo environment..."
        setup_demo_environment
        setup_github_secrets
    fi
    
    # Display next steps
    log_blue ""
    log_blue "=== Next Steps ==="
    log_blue "1. Re-enable Azure subscription if needed"
    log_blue "2. Configure GitHub secrets"
    log_blue "3. Monitor GitHub Actions deployment"
    log_blue "4. Test data pipelines"
    log_blue "5. Configure SAP connections"
    log_blue ""
    log_blue "Documentation: docs/setup-guide.md"
    log_blue "Demo API: http://localhost:5000"
    log_blue "GitHub Actions: https://github.com/sbeuran/azure-data-platform/actions"
}

# Error handling
trap 'log_error "Deployment failed at line $LINENO"' ERR

# Run main function
main "$@"

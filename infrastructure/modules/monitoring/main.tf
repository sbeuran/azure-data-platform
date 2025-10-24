# Monitoring Module - Simplified Version
# This module creates basic monitoring and alerting for the data platform

# Action Groups for Alerts
resource "azurerm_monitor_action_group" "critical" {
  name                = "ag-critical-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "critical"

  email_receiver {
    name          = "critical-alerts"
    email_address = var.critical_alert_email
  }

  tags = var.common_tags
}

resource "azurerm_monitor_action_group" "warning" {
  name                = "ag-warning-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "warning"

  email_receiver {
    name          = "warning-alerts"
    email_address = var.warning_alert_email
  }

  tags = var.common_tags
}

resource "azurerm_monitor_action_group" "info" {
  name                = "ag-info-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "info"

  email_receiver {
    name          = "info-alerts"
    email_address = var.info_alert_email
  }

  tags = var.common_tags
}

# Note: Complex monitoring rules, dashboards, and scheduled query rules
# will be configured through the Azure Monitor UI after the infrastructure is deployed
# This is because they require complex JSON configurations and
# detailed knowledge of the specific monitoring requirements

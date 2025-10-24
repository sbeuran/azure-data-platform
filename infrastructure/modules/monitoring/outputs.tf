# Monitoring Module Outputs - Simplified Version

output "action_groups" {
  description = "Action groups for alerts"
  value = {
    critical = azurerm_monitor_action_group.critical.id
    warning  = azurerm_monitor_action_group.warning.id
    info     = azurerm_monitor_action_group.info.id
  }
}

output "dashboard_id" {
  description = "ID of the monitoring dashboard"
  value       = null  # Dashboard will be created manually
}

output "alerts" {
  description = "Alert rules"
  value       = {}  # Alerts will be created manually
}

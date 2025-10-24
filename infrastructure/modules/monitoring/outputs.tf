# Monitoring Module Outputs

output "action_groups" {
  description = "Action groups created"
  value = {
    critical = azurerm_monitor_action_group.critical.id
    warning  = azurerm_monitor_action_group.warning.id
    info     = azurerm_monitor_action_group.info.id
  }
}

output "metric_alerts" {
  description = "Metric alerts created"
  value = {
    data_factory_pipeline_failures = var.data_factory_id != null ? azurerm_monitor_metric_alert.data_factory_pipeline_failures[0].id : null
    databricks_cluster_failures     = var.databricks_workspace_id != null ? azurerm_monitor_metric_alert.databricks_cluster_failures[0].id : null
    synapse_sql_pool_high_dtu      = var.synapse_sql_pool_id != null ? azurerm_monitor_metric_alert.synapse_sql_pool_high_dtu[0].id : null
    storage_account_high_usage     = var.data_lake_storage_account_id != null ? azurerm_monitor_metric_alert.storage_account_high_usage[0].id : null
  }
}

output "log_analytics_alerts" {
  description = "Log Analytics alerts created"
  value = {
    failed_logins        = azurerm_monitor_scheduled_query_rules_alert.failed_logins.id
    data_pipeline_errors = azurerm_monitor_scheduled_query_rules_alert.data_pipeline_errors.id
    security_events      = azurerm_monitor_scheduled_query_rules_alert.security_events.id
  }
}

output "dashboard_url" {
  description = "URL of the monitoring dashboard"
  value       = azurerm_dashboard.supply_chain_monitoring.id
}

output "alert_rules" {
  description = "List of all alert rules"
  value = concat(
    var.data_factory_id != null ? [azurerm_monitor_metric_alert.data_factory_pipeline_failures[0].id] : [],
    var.databricks_workspace_id != null ? [azurerm_monitor_metric_alert.databricks_cluster_failures[0].id] : [],
    var.synapse_sql_pool_id != null ? [azurerm_monitor_metric_alert.synapse_sql_pool_high_dtu[0].id] : [],
    var.data_lake_storage_account_id != null ? [azurerm_monitor_metric_alert.storage_account_high_usage[0].id] : [],
    [
      azurerm_monitor_scheduled_query_rules_alert.failed_logins.id,
      azurerm_monitor_scheduled_query_rules_alert.data_pipeline_errors.id,
      azurerm_monitor_scheduled_query_rules_alert.security_events.id
    ]
  )
}

output "cost_budget_id" {
  description = "ID of the cost budget"
  value       = var.enable_cost_management ? azurerm_consumption_budget_resource_group.main[0].id : null
}

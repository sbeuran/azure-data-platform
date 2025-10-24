# Monitoring Module - Bosch Supply Chain Data Platform
# This module creates monitoring and alerting resources

# Action Group for Critical Alerts
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

# Action Group for Warning Alerts
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

# Action Group for Info Alerts
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

# Metric Alert for Data Factory Pipeline Failures
resource "azurerm_monitor_metric_alert" "data_factory_pipeline_failures" {
  count               = var.data_factory_id != null ? 1 : 0
  name                = "ma-data-factory-pipeline-failures-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.data_factory_id]
  description         = "Alert when Data Factory pipeline failures exceed threshold"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"
    metric_name      = "PipelineFailedRuns"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = var.common_tags
}

# Metric Alert for Databricks Cluster Failures
resource "azurerm_monitor_metric_alert" "databricks_cluster_failures" {
  count               = var.databricks_workspace_id != null ? 1 : 0
  name                = "ma-databricks-cluster-failures-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.databricks_workspace_id]
  description         = "Alert when Databricks cluster failures exceed threshold"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Databricks/workspaces"
    metric_name      = "cluster_failures"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 3
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = var.common_tags
}

# Metric Alert for Synapse SQL Pool High DTU Usage
resource "azurerm_monitor_metric_alert" "synapse_sql_pool_high_dtu" {
  count               = var.synapse_sql_pool_id != null ? 1 : 0
  name                = "ma-synapse-sql-pool-high-dtu-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.synapse_sql_pool_id]
  description         = "Alert when Synapse SQL pool DTU usage is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Synapse/workspaces/sqlPools"
    metric_name      = "DWULimit"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }

  tags = var.common_tags
}

# Metric Alert for Storage Account High Usage
resource "azurerm_monitor_metric_alert" "storage_account_high_usage" {
  count               = var.data_lake_storage_account_id != null ? 1 : 0
  name                = "ma-storage-account-high-usage-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.data_lake_storage_account_id]
  description         = "Alert when storage account usage is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1000000000000 # 1TB in bytes
  }

  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }

  tags = var.common_tags
}

# Log Analytics Alert for Failed Logins
resource "azurerm_monitor_scheduled_query_rules_alert" "failed_logins" {
  name                = "sqr-failed-logins-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location           = var.location
  data_source_id     = var.log_analytics_id

  query = <<-QUERY
    SecurityEvent
    | where EventID == 4625
    | where TimeGenerated > ago(1h)
    | summarize count() by Computer, Account
    | where count_ > 5
  QUERY

  description = "Alert when there are multiple failed login attempts"
  severity    = 2
  frequency   = 5
  time_window = 15
  enabled     = true

  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }

  tags = var.common_tags
}

# Log Analytics Alert for Data Pipeline Errors
resource "azurerm_monitor_scheduled_query_rules_alert" "data_pipeline_errors" {
  name                = "sqr-data-pipeline-errors-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location           = var.location
  data_source_id     = var.log_analytics_id

  query = <<-QUERY
    AzureDiagnostics
    | where Category == "ActivityRuns"
    | where ResultType == "Failed"
    | where TimeGenerated > ago(1h)
    | summarize count() by Resource
    | where count_ > 3
  QUERY

  description = "Alert when data pipeline errors exceed threshold"
  severity    = 1
  frequency   = 5
  time_window = 15
  enabled     = true

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = var.common_tags
}

# Log Analytics Alert for Security Events
resource "azurerm_monitor_scheduled_query_rules_alert" "security_events" {
  name                = "sqr-security-events-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location           = var.location
  data_source_id     = var.log_analytics_id

  query = <<-QUERY
    SecurityEvent
    | where EventID in (4624, 4625, 4634, 4648, 4720, 4722, 4723, 4724, 4725, 4726, 4732, 4733, 4734, 4735, 4737, 4738, 4739, 4740, 4741, 4742, 4743, 4744, 4745, 4746, 4747, 4748, 4749, 4750, 4751, 4752, 4753, 4754, 4755, 4756, 4757, 4758, 4759, 4760, 4761, 4762, 4763, 4764, 4765, 4766, 4767, 4768, 4769, 4770, 4771, 4772, 4773, 4774, 4775, 4776, 4777, 4778, 4779, 4780, 4781, 4782, 4783, 4784, 4785, 4786, 4787, 4788, 4789, 4790, 4791, 4792, 4793, 4794, 4795, 4796, 4797, 4798, 4799, 4800, 4801, 4802, 4803, 4804, 4805, 4806, 4807, 4808, 4809, 4810, 4811, 4812, 4813, 4814, 4815, 4816, 4817, 4818, 4819, 4820, 4821, 4822, 4823, 4824, 4825, 4826, 4827, 4828, 4829, 4830, 4831, 4832, 4833, 4834, 4835, 4836, 4837, 4838, 4839, 4840, 4841, 4842, 4843, 4844, 4845, 4846, 4847, 4848, 4849, 4850, 4851, 4852, 4853, 4854, 4855, 4856, 4857, 4858, 4859, 4860, 4861, 4862, 4863, 4864, 4865, 4866, 4867, 4868, 4869, 4870, 4871, 4872, 4873, 4874, 4875, 4876, 4877, 4878, 4879, 4880, 4881, 4882, 4883, 4884, 4885, 4886, 4887, 4888, 4889, 4890, 4891, 4892, 4893, 4894, 4895, 4896, 4897, 4898, 4899, 4900, 4901, 4902, 4903, 4904, 4905, 4906, 4907, 4908, 4909, 4910, 4911, 4912, 4913, 4914, 4915, 4916, 4917, 4918, 4919, 4920, 4921, 4922, 4923, 4924, 4925, 4926, 4927, 4928, 4929, 4930, 4931, 4932, 4933, 4934, 4935, 4936, 4937, 4938, 4939, 4940, 4941, 4942, 4943, 4944, 4945, 4946, 4947, 4948, 4949, 4950, 4951, 4952, 4953, 4954, 4955, 4956, 4957, 4958, 4959, 4960, 4961, 4962, 4963, 4964, 4965, 4966, 4967, 4968, 4969, 4970, 4971, 4972, 4973, 4974, 4975, 4976, 4977, 4978, 4979, 4980, 4981, 4982, 4983, 4984, 4985, 4986, 4987, 4988, 4989, 4990, 4991, 4992, 4993, 4994, 4995, 4996, 4997, 4998, 4999, 5000)
    | where TimeGenerated > ago(1h)
    | summarize count() by Computer, EventID
    | where count_ > 10
  QUERY

  description = "Alert when there are multiple security events"
  severity    = 1
  frequency   = 5
  time_window = 15
  enabled     = true

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }

  tags = var.common_tags
}

# Dashboard for Supply Chain Monitoring
resource "azurerm_dashboard" "supply_chain_monitoring" {
  name                = "dash-supply-chain-monitoring-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location           = var.location
  tags               = var.common_tags

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = {
              x = 0
              y = 0
              rowSpan = 4
              colSpan = 6
            }
            metadata = {
              inputs = {
                options = {
                  chart = {
                    metrics = [
                      {
                        resourceMetadata = {
                          id = var.data_factory_id
                        }
                        name = "PipelineSucceededRuns"
                        aggregationType = 1
                        namespace = "Microsoft.DataFactory/factories"
                        metricVisualization = {
                          displayName = "Pipeline Succeeded Runs"
                        }
                      }
                    ]
                    title = "Data Factory Pipeline Success Rate"
                    visualization = {
                      chartType = 2
                    }
                  }
                }
                timeRange = {
                  value = {
                    relative = {
                      duration = 86400000
                    }
                  }
                  type = 4
                }
              }
              type = "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart"
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 86400000
            }
          }
          type = 4
        }
        filterTime = {
          value = 0
        }
        filters = {
          value = {
            "MsPortalFx_TimeRange" = {
              model = {
                format = "utc"
                granularity = "auto"
                relative = "24h"
                show = false
                type = 4
              }
              displayCache = {
                name = "UTC Time"
                value = "Past 24 hours"
              }
              filteredTokenTypes = {}
            }
          }
        }
      }
    }
  })
}

# Cost Management Alert
resource "azurerm_consumption_budget_resource_group" "main" {
  count               = var.enable_cost_management ? 1 : 0
  name                = "budget-${var.project_name}-${var.environment}"
  resource_group_id   = var.resource_group_id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = "2024-01-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceGroupName"
      values = [var.resource_group_name]
    }
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = [var.critical_alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Actual"

    contact_emails = [var.critical_alert_email]
  }
}

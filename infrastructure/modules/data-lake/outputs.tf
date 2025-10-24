# Data Lake Module Outputs

output "storage_account_id" {
  description = "ID of the data lake storage account"
  value       = azurerm_storage_account.data_lake.id
}

output "storage_account_name" {
  description = "Name of the data lake storage account"
  value       = azurerm_storage_account.data_lake.name
}

output "primary_dfs_endpoint" {
  description = "Primary DFS endpoint of the data lake"
  value       = azurerm_storage_account.data_lake.primary_dfs_endpoint
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the data lake"
  value       = azurerm_storage_account.data_lake.primary_blob_endpoint
}

output "container_names" {
  description = "Names of the data lake containers"
  value = {
    bronze    = azurerm_storage_container.bronze.name
    silver    = azurerm_storage_container.silver.name
    gold      = azurerm_storage_container.gold.name
    raw       = azurerm_storage_container.raw.name
    processed = azurerm_storage_container.processed.name
    ml        = azurerm_storage_container.ml.name
    backup    = azurerm_storage_container.backup.name
  }
}

output "logs_storage_account_id" {
  description = "ID of the logs storage account"
  value       = azurerm_storage_account.logs.id
}

output "logs_storage_account_name" {
  description = "Name of the logs storage account"
  value       = azurerm_storage_account.logs.name
}

output "tfstate_storage_account_id" {
  description = "ID of the Terraform state storage account"
  value       = azurerm_storage_account.tfstate.id
}

output "tfstate_storage_account_name" {
  description = "Name of the Terraform state storage account"
  value       = azurerm_storage_account.tfstate.name
}

output "tfstate_container_name" {
  description = "Name of the Terraform state container"
  value       = azurerm_storage_container.tfstate.name
}

output "private_endpoints" {
  description = "Private endpoint information"
  value = {
    blob = var.enable_private_endpoints ? azurerm_private_endpoint.blob[0].id : null
    dfs  = var.enable_private_endpoints ? azurerm_private_endpoint.dfs[0].id : null
  }
}

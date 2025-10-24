# Data Factory Module Outputs - Simplified Version

output "data_factory_id" {
  description = "ID of the Data Factory"
  value       = azurerm_data_factory.main.id
}

output "data_factory_name" {
  description = "Name of the Data Factory"
  value       = azurerm_data_factory.main.name
}

output "data_factory_identity" {
  description = "Identity of the Data Factory"
  value       = azurerm_data_factory.main.identity
}

output "private_endpoint_id" {
  description = "ID of the Data Factory private endpoint"
  value       = var.enable_private_endpoints ? azurerm_private_endpoint.data_factory[0].id : null
}

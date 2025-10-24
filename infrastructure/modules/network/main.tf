# Network Module - Bosch Supply Chain Data Platform
# This module creates the network infrastructure for the data platform

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.common_tags
}

# Network Security Group for Databricks Private Subnet
resource "azurerm_network_security_group" "databricks_private" {
  name                = "nsg-databricks-private-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow inbound traffic from public subnet
  security_rule {
    name                       = "AllowFromPublicSubnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.databricks_public_subnet_cidr
    destination_address_prefix = "*"
  }

  # Allow outbound traffic to internet
  security_rule {
    name                       = "AllowOutboundInternet"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

# Network Security Group for Databricks Public Subnet
resource "azurerm_network_security_group" "databricks_public" {
  name                = "nsg-databricks-public-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow inbound traffic from internet (for cluster access)
  security_rule {
    name                       = "AllowInboundInternet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow outbound traffic to internet
  security_rule {
    name                       = "AllowOutboundInternet"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

# Network Security Group for Data Factory
resource "azurerm_network_security_group" "data_factory" {
  name                = "nsg-data-factory-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow outbound traffic to Azure services
  security_rule {
    name                       = "AllowOutboundAzureServices"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  # Allow outbound traffic to internet
  security_rule {
    name                       = "AllowOutboundInternet"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

# Network Security Group for Synapse
resource "azurerm_network_security_group" "synapse" {
  name                = "nsg-synapse-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow outbound traffic to Azure services
  security_rule {
    name                       = "AllowOutboundAzureServices"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  # Allow outbound traffic to internet
  security_rule {
    name                       = "AllowOutboundInternet"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

# Databricks Private Subnet
resource "azurerm_subnet" "databricks_private" {
  name                 = "subnet-databricks-private-${var.project_name}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.databricks_private_subnet_cidr]

  delegation {
    name = "databricks-private"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

# Databricks Public Subnet
resource "azurerm_subnet" "databricks_public" {
  name                 = "subnet-databricks-public-${var.project_name}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.databricks_public_subnet_cidr]

  delegation {
    name = "databricks-public"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

# Data Factory Subnet
resource "azurerm_subnet" "data_factory" {
  name                 = "subnet-data-factory-${var.project_name}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.data_factory_subnet_cidr]

  # Note: Data Factory doesn't require subnet delegation
}

# Synapse Subnet
resource "azurerm_subnet" "synapse" {
  name                 = "subnet-synapse-${var.project_name}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.synapse_subnet_cidr]

  delegation {
    name = "synapse"
    service_delegation {
      name = "Microsoft.Synapse/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "databricks_private" {
  subnet_id                 = azurerm_subnet.databricks_private.id
  network_security_group_id = azurerm_network_security_group.databricks_private.id
}

resource "azurerm_subnet_network_security_group_association" "databricks_public" {
  subnet_id                 = azurerm_subnet.databricks_public.id
  network_security_group_id = azurerm_network_security_group.databricks_public.id
}

resource "azurerm_subnet_network_security_group_association" "data_factory" {
  subnet_id                 = azurerm_subnet.data_factory.id
  network_security_group_id = azurerm_network_security_group.data_factory.id
}

resource "azurerm_subnet_network_security_group_association" "synapse" {
  subnet_id                 = azurerm_subnet.synapse.id
  network_security_group_id = azurerm_network_security_group.synapse.id
}

# Private DNS Zone for Azure services
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_private_dns_zone" "dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_private_dns_zone" "databricks" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_private_dns_zone" "synapse" {
  name                = "privatelink.sql.azuresynapse.net"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

resource "azurerm_private_dns_zone" "synapse_dev" {
  name                = "privatelink.dev.azuresynapse.net"
  resource_group_name = var.resource_group_name

  tags = var.common_tags
}

# Link private DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-${var.project_name}-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled   = false

  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs" {
  name                  = "link-dfs-${var.project_name}-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dfs.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled   = false

  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "link-keyvault-${var.project_name}-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled   = false

  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "databricks" {
  name                  = "link-databricks-${var.project_name}-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.databricks.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled   = false

  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "synapse" {
  name                  = "link-synapse-${var.project_name}-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.synapse.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled   = false

  tags = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "synapse_dev" {
  name                  = "link-synapse-dev-${var.project_name}-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.synapse_dev.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled   = false

  tags = var.common_tags
}

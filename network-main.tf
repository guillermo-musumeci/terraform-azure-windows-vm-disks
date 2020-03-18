####################
## Network - Main ##
####################

# Create a resource group for network
resource "azurerm_resource_group" "network-rg" {
  name     = "${lower(replace(var.app_name," ","-"))}-${var.environment}-rg"
  location = var.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# Create the network VNET
resource "azurerm_virtual_network" "network-vnet" {
  depends_on=[azurerm_resource_group.network-rg]

  name                = "${lower(replace(var.app_name," ","-"))}-${var.environment}-vnet"
  address_space       = [var.network-vnet-cidr]
  resource_group_name = azurerm_resource_group.network-rg.name
  location            = azurerm_resource_group.network-rg.location
  tags = {
    application = var.app_name
    environment = var.environment
  }
}

# Create a Public subnet for Network VNET
resource "azurerm_subnet" "network-public-subnet" {
  depends_on=[azurerm_virtual_network.network-vnet]

  name                 = "${lower(replace(var.app_name," ","-"))}-${var.environment}-public-subnet"
  address_prefix       = var.public-subnet-cidr
  virtual_network_name = azurerm_virtual_network.network-vnet.name
  resource_group_name  = azurerm_resource_group.network-rg.name
}

# Create a Private subnet for Network VNET
resource "azurerm_subnet" "network-private-subnet" {
  depends_on=[azurerm_virtual_network.network-vnet]

  name                 = "${lower(replace(var.app_name," ","-"))}-${var.environment}-private-subnet"
  address_prefix       = var.private-subnet-cidr
  virtual_network_name = azurerm_virtual_network.network-vnet.name
  resource_group_name  = azurerm_resource_group.network-rg.name
}

# Create a route table for the Private subnet
resource "azurerm_route_table" "private-subnet-route" {
  name                          = "${lower(replace(var.app_name," ","-"))}-${var.environment}-private-subnet-route-table"
  resource_group_name           = azurerm_resource_group.network-rg.name
  location                      = azurerm_resource_group.network-rg.location
  disable_bgp_route_propagation = false

  route {
    name                   = "private-subnet-default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }

  tags = {
    environment = var.environment
  }
}

# associate the dwh subnet to route table
resource "azurerm_subnet_route_table_association" "private-subnet-route-association" {
  subnet_id      = azurerm_subnet.network-private-subnet.id
  route_table_id = azurerm_route_table.private-subnet-route.id
}
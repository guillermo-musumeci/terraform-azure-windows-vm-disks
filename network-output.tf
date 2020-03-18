######################
## Network - Output ##
######################

output "network_resource_group_id" {
  value = azurerm_resource_group.network-rg.id
}

output "network_vnet_id" {
  value = azurerm_virtual_network.network-vnet.id
}

output "network_public_subnet_id" {
  value = azurerm_subnet.network-public-subnet.id
}

output "network_private_subnet_id" {
  value = azurerm_subnet.network-private-subnet.id
}

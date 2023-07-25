# network_interface_security_group_association.tf
resource "azurerm_network_interface_security_group_association" "tfaz-nsg-client-assoc" {
  network_interface_id      = azurerm_network_interface.tfaz-netint-dc01.id
  network_security_group_id = azurerm_network_security_group.tfaz-nsg-client.id
}

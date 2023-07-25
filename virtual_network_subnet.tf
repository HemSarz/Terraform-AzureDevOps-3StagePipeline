# virtual_network_subnet.tf
resource "azurerm_subnet" "tfaz-vnet1-subnet1" {
  name                 = var.tfaz-vnet1-label
  address_prefixes     = [var.tfaz-infra-vnet1-subnet1-range]
  resource_group_name  = azurerm_resource_group.tfaz-rg.name
  virtual_network_name = azurerm_virtual_network.tfaz-vnet1.name
}

resource "azurerm_subnet" "tfaz-vnet2-subn1" {
  name                 = var.tfaz-vnet2-subnet1-label
  resource_group_name  = azurerm_resource_group.tfaz-rg.name
  virtual_network_name = azurerm_virtual_network.tfaz-vnet2.name
  address_prefixes     = [var.tfaz-vnet2-subnet1-range]
}
# virtual_network.tf
resource "azurerm_virtual_network" "tfaz-vnet1" {
  name                = var.tfaz-vnet1-label
  location            = azurerm_resource_group.tfaz-rg.location
  resource_group_name = azurerm_resource_group.tfaz-rg.name
  address_space       = [var.tfaz-vnet1-subnet1-addr-space]

  tags = {
    environment = var.env-tfaz-dev
  }
}

resource "azurerm_virtual_network" "tfaz-vnet2" {
  name                = var.tfaz-vnet2-label
  location            = var.location
  resource_group_name = azurerm_resource_group.tfaz-rg.name
  address_space       = [var.tfaz-vnet2-subnet1-addr-space]

  tags = {
    environment = var.env-tfaz-dev
  }
}

# network_interface.tf
resource "azurerm_network_interface" "tfaz-netint-dc01" {
  name                = var.dc01-netwint
  location            = azurerm_resource_group.tfaz-rg.location
  resource_group_name = azurerm_resource_group.tfaz-rg.name

  ip_configuration {
    name                          = var.tfaz-ipconfig
    subnet_id                     = azurerm_subnet.tfaz-vnet1-subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.tfaz-netwint-priv-ip-dc01
    public_ip_address_id          = azurerm_public_ip.tfaz-dc01-pip.id
  }

  tags = {
    environment = var.env-tfaz-dev
  }
}

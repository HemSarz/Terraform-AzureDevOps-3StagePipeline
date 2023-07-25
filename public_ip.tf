# public_ip.tf
resource "azurerm_public_ip" "tfaz-dc01-pip" {
  name                = var.PIP-dc01
  resource_group_name = azurerm_resource_group.tfaz-rg.name
  location            = azurerm_resource_group.tfaz-rg.location
  allocation_method   = "Static"

  tags = {
    environment = var.env-tfaz-dev
  }
}

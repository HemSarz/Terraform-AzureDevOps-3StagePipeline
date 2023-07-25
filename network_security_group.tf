# network_security_group.tf
resource "azurerm_network_security_group" "tfaz-nsg-client" {
  name                = var.NSG-AllowClient
  resource_group_name = azurerm_resource_group.tfaz-rg.name
  location            = var.location

  security_rule {
    name                       = var.sec-rule-allow-rdp-client
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "82.164.170.66"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env-tfaz-dev
  }
}

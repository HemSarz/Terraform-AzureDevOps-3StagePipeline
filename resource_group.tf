# resource_group.tf
resource "azurerm_resource_group" "tfaz-rg" {
  name     = var.tfaz-rg_label
  location = var.location
  tags = {
    environment = var.env-tfaz-dev
  }
}

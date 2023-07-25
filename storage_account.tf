# storage_account.tf
resource "azurerm_storage_account" "tfaz-stg" {
  name                     = var.tfaz-stg
  resource_group_name      = azurerm_resource_group.tfaz-rg.name
  location                 = var.location
  depends_on               = [azurerm_resource_group.tfaz-rg]
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.env-tfaz-dev
  }
}

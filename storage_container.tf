# storage_container.tf
resource "azurerm_storage_container" "tfaz-cont" {
  name                  = var.tfaz-stg-cont
  storage_account_name  = azurerm_storage_account.tfaz-stg.name
  depends_on            = [azurerm_storage_account.tfaz-stg]
  container_access_type = "private"
}

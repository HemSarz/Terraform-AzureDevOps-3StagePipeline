# key_vault.tf
resource "random_id" "tfaz-key-vault" {
  byte_length = 4
  prefix      = var.kv-name-rndm
}

resource "azurerm_key_vault" "tfaz-kv" {
  name                = random_id.tfaz-key-vault.hex
  location            = var.location
  resource_group_name = azurerm_resource_group.tfaz-rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  depends_on          = [azurerm_resource_group.tfaz-rg]

  sku_name = "standard"

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = false

  access_policy {
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id

    key_permissions     = ["Get", "List", "Backup"]
    secret_permissions  = ["Get", "List", "Set", "Delete", "Purge"]
    storage_permissions = ["Get", "List", "Set"]
  }

  tags = {
    environment = var.env-tfaz-dev
  }
}

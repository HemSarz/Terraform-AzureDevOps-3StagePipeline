# key_vault_secrets.tf
resource "azurerm_key_vault_secret" "kv-sc-tfaz-vmadmin" {
  name         = var.kv-sc-dc01-admin-label
  value        = var.kv-sc-dc01-adminuser
  key_vault_id = azurerm_key_vault.tfaz-kv.id
  depends_on = [
    azurerm_key_vault.tfaz-kv
  ]
}

resource "azurerm_key_vault_secret" "kv-sc-tfaz-vm-pass" {
  name         = var.kv-sc-dc01-admin-pass-label
  value        = random_password.vm-admin-pass.result
  key_vault_id = azurerm_key_vault.tfaz-kv.id
  depends_on = [
    azurerm_key_vault.tfaz-kv
  ]

  tags = {
    environment = var.env-tfaz-dev
  }
}

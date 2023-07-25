# admin_user.tf
resource "random_password" "vm-admin-pass" {
  length           = 12
  special          = true
  override_special = "%&*()-_=+[]{}<>:?"
  upper            = true
  lower            = true
}

resource "azuread_user" "tfaz-dc01-admin" {
  user_principal_name = var.tfaz-dc01-admin_upn
  display_name        = azurerm_key_vault_secret.kv-sc-tfaz-vmadmin.value
  password            = random_password.vm-admin-pass.result
}

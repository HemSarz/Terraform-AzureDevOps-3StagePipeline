############## AzureRM
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}
data "azurerm_subscription" "primary" {}

############# NSG | Client data || Will retrieve local IP if the code is run locally. In AZ DevOps it will retrieve Agent IP
#data "http" "clientip" {
#url = "https://ipv4.icanhazip.com/"
#}

############# NSG | Client data

############ Admin User VM
data "azuread_user" "tfaz-dc01-admin" {
  user_principal_name = var.tfaz-dc01-admin_upn

  depends_on = [azuread_user.tfaz-dc01-admin]
}
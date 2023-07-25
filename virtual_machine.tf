# virtual_machine.tf
resource "azurerm_windows_virtual_machine" "tfaz-vm-dco1" {
  name                = var.dc01-label
  resource_group_name = azurerm_resource_group.tfaz-rg.name
  location            = azurerm_resource_group.tfaz-rg.location
  size                = var.vm_size
  admin_username      = azurerm_key_vault_secret.kv-sc-tfaz-vmadmin.value
  admin_password      = random_password.vm-admin-pass.result
  network_interface_ids = [
    azurerm_network_interface.tfaz-netint-dc01.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.storageimage_publisher
    offer     = var.storageimage_offer
    sku       = var.storageimage_sku
    version   = var.storageimage_version
  }

  tags = {
    environment = var.env-tfaz-dev
  }
}

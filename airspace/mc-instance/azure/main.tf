resource "azurerm_network_interface" "this" {
  name                = var.traffic_gen.name
  location            = var.location
  resource_group_name = var.resource_group
  ip_configuration {
    name                          = var.traffic_gen.name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.traffic_gen.private_ip
  }
  tags = var.common_tags
}

data "azurerm_platform_image" "this" {
  location  = var.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.traffic_gen.name
  location                        = var.location
  resource_group_name             = var.resource_group
  network_interface_ids           = [azurerm_network_interface.this.id]
  admin_username                  = "workload_user"
  admin_password                  = var.workload_password
  computer_name                   = var.traffic_gen.name
  size                            = "Standard_B1ls"
  source_image_id                 = var.image == null ? null : var.image
  custom_data                     = data.cloudinit_config.this.rendered
  disable_password_authentication = false
  tags = merge(var.common_tags, {
    Name = var.traffic_gen.name
  })

  dynamic "source_image_reference" {
    for_each = var.image == null ? ["ubuntu"] : []

    content {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
  }
  # source_image_reference {
  #   publisher = "Canonical"
  #   offer     = "0001-com-ubuntu-server-jammy"
  #   sku       = "22_04-lts-gen2"
  #   version   = "latest"
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}


data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${var.workload_template_path}/${var.workload_template}",
      {
        name     = var.traffic_gen.name
        apps     = join(",", var.traffic_gen.apps)
        external = join(",", var.traffic_gen.external)
        sap      = join(",", var.traffic_gen.sap)
        interval = var.traffic_gen.interval
        password = var.workload_password
    })
  }
}

resource "azurerm_network_security_group" "this" {
  name                = var.traffic_gen.name
  resource_group_name = var.resource_group
  location            = var.location
  tags                = var.common_tags
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_network_security_rule" "this_rfc_1918" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "rfc-1918"
  priority                    = 100
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefixes     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.this.name
}

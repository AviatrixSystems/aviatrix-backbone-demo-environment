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

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.traffic_gen.name
  location                        = var.location
  resource_group_name             = var.resource_group
  network_interface_ids           = [azurerm_network_interface.this.id]
  admin_username                  = "workload_user"
  admin_password                  = var.workload_password
  computer_name                   = var.traffic_gen.name
  size                            = "Standard_B1ls"
  custom_data                     = data.cloudinit_config.this.rendered
  disable_password_authentication = false
  tags = merge(var.common_tags, {
    Name = var.traffic_gen.name
  })

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

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

resource "azurerm_network_security_rule" "this_http" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "http"
  priority                    = 100
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "80"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_network_security_rule" "this_ssh" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ssh"
  priority                    = 110
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_network_security_rule" "this_icmp" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "icmp"
  priority                    = 120
  protocol                    = "Icmp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.this.name
}

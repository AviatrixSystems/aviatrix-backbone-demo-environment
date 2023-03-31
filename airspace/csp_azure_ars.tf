# azure vnets
resource "azurerm_resource_group" "vnet_germany_west_central" {
  name     = "vnet-germany-west-central-rg"
  location = var.transit_azure_region
}

resource "azurerm_route_table" "vnet_germany_west_central_public" {
  location            = var.transit_azure_region
  name                = "vnet-germany-west-central-public-rt"
  resource_group_name = azurerm_resource_group.vnet_germany_west_central.name
}

resource "azurerm_route_table" "vnet_germany_west_central_private" {
  location            = var.transit_azure_region
  name                = "vnet-germany-west-central-private-rt"
  resource_group_name = azurerm_resource_group.vnet_germany_west_central.name
}

module "vnet_germany_west_central" {
  source              = "Azure/vnet/azurerm"
  version             = "4.0.0"
  vnet_name           = "vnet-germany-west-central"
  resource_group_name = azurerm_resource_group.vnet_germany_west_central.name
  vnet_location       = azurerm_resource_group.vnet_germany_west_central.location
  use_for_each        = true
  address_space       = [local.cidrs.azure_germany_west_central]
  subnet_names        = ["private-subnet1", "public-subnet1"]
  subnet_prefixes     = [cidrsubnet(local.cidrs.azure_germany_west_central, 4, 0), cidrsubnet(local.cidrs.azure_germany_west_central, 4, 2)]
  route_tables_ids = {
    private-subnet1 = azurerm_route_table.vnet_germany_west_central_private.id,
    public-subnet1  = azurerm_route_table.vnet_germany_west_central_public.id,
  }
  tags = var.common_tags
}

data "azurerm_virtual_network" "vnet_germany_west_central" {
  name                = module.vnet_germany_west_central.vnet_name
  resource_group_name = azurerm_resource_group.vnet_germany_west_central.name
  depends_on = [
    module.vnet_germany_west_central
  ]
}

resource "azurerm_virtual_network" "ars" {
  name                = "ars-vnet"
  address_space       = ["10.2.4.0/24"]
  resource_group_name = azurerm_resource_group.vnet_germany_west_central.name
  location            = azurerm_resource_group.vnet_germany_west_central.location
}

# azure route server
resource "azurerm_subnet" "ars" {
  name                 = "RouteServerSubnet"
  virtual_network_name = azurerm_virtual_network.ars.name
  resource_group_name  = azurerm_resource_group.vnet_germany_west_central.name
  address_prefixes     = ["10.2.4.0/27"]
}

resource "azurerm_subnet" "nva" {
  name                 = "NvaSubnet"
  virtual_network_name = azurerm_virtual_network.ars.name
  resource_group_name  = azurerm_resource_group.vnet_germany_west_central.name
  address_prefixes     = ["10.2.4.32/28"]
}

resource "azurerm_public_ip" "ars" {
  name                = "ars-pip"
  resource_group_name = azurerm_resource_group.vnet_germany_west_central.name
  location            = azurerm_resource_group.vnet_germany_west_central.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_server" "default" {
  name                             = "backbone-route-server"
  resource_group_name              = azurerm_resource_group.vnet_germany_west_central.name
  location                         = azurerm_resource_group.vnet_germany_west_central.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.ars.id
  subnet_id                        = azurerm_subnet.ars.id
  branch_to_branch_traffic_enabled = true
}

resource "azurerm_route_server_bgp_connection" "transit_gw" {
  name            = "transit-gw-bgp"
  route_server_id = azurerm_route_server.default.id
  peer_asn        = "65102"
  peer_ip         = module.multicloud_transit.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].transit_gateway.bgp_lan_ip_list[0]
}

data "azurerm_subscription" "current" {}

resource "azurerm_virtual_network_peering" "ars_transit" {
  name                         = "ars-transit"
  remote_virtual_network_id    = module.multicloud_transit.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].vpc.azure_vnet_resource_id
  resource_group_name          = azurerm_resource_group.vnet_germany_west_central.name
  virtual_network_name         = azurerm_virtual_network.ars.name
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true

  depends_on = [
    azurerm_route_server.default
  ]
}

resource "azurerm_virtual_network_peering" "transit_ars" {
  name                         = "transit-ars"
  remote_virtual_network_id    = azurerm_virtual_network.ars.id
  resource_group_name          = module.multicloud_transit.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].vpc.resource_group
  virtual_network_name         = module.multicloud_transit.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].vpc.name
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network_peering.ars_transit,
    azurerm_route_server.default
  ]
}

resource "azurerm_virtual_network_peering" "spoke_ars" {
  name                         = "spoke-ars"
  remote_virtual_network_id    = azurerm_virtual_network.ars.id
  resource_group_name          = azurerm_resource_group.vnet_germany_west_central.name
  virtual_network_name         = module.vnet_germany_west_central.vnet_name
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true

  depends_on = [
    azurerm_route_server.default,
    azurerm_virtual_network_peering.ars_spoke
  ]
}

resource "azurerm_virtual_network_peering" "ars_spoke" {
  name                         = "ars-spoke"
  remote_virtual_network_id    = module.vnet_germany_west_central.vnet_id
  resource_group_name          = azurerm_resource_group.vnet_germany_west_central.name
  virtual_network_name         = azurerm_virtual_network.ars.name
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true

  depends_on = [
    azurerm_route_server.default
  ]
}

resource "aviatrix_transit_external_device_conn" "default" {
  vpc_id                    = module.multicloud_transit.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].vpc.vpc_id
  connection_name           = "azure-rs-bgp"
  gw_name                   = module.multicloud_transit.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "LAN"
  remote_vpc_name           = format("%s:%s:%s", azurerm_virtual_network.ars.name, azurerm_resource_group.vnet_germany_west_central.name, data.azurerm_subscription.current.subscription_id)
  ha_enabled                = false
  bgp_local_as_num          = "65102"
  bgp_remote_as_num         = "65515"
  remote_lan_ip             = tolist(azurerm_route_server.default.virtual_router_ips)[0]
  enable_bgp_lan_activemesh = false
}

# nva
resource "azurerm_network_interface" "nva" {
  name                 = "nva"
  location             = var.transit_azure_region
  resource_group_name  = azurerm_resource_group.vnet_germany_west_central.name
  enable_ip_forwarding = true
  ip_configuration {
    name                          = "nva"
    subnet_id                     = azurerm_subnet.nva.id
    public_ip_address_id          = azurerm_public_ip.nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.2.4.40"
  }
  tags = var.common_tags
}

resource "azurerm_public_ip" "nva" {
  allocation_method   = "Static"
  location            = var.transit_azure_region
  name                = "nva-pip"
  resource_group_name = azurerm_resource_group.vnet_germany_west_central.name
  sku                 = "Standard"
}

resource "azurerm_route" "workload_nva" {
  name                   = "workload_nva"
  resource_group_name    = azurerm_resource_group.vnet_germany_west_central.name
  route_table_name       = azurerm_route_table.vnet_germany_west_central_private.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva.private_ip_address
}

resource "azurerm_linux_virtual_machine" "nva" {
  name                            = "nva"
  location                        = var.transit_azure_region
  resource_group_name             = azurerm_resource_group.vnet_germany_west_central.name
  network_interface_ids           = [azurerm_network_interface.nva.id]
  admin_username                  = "nva_user"
  admin_password                  = var.workload_instance_password
  computer_name                   = "nva"
  size                            = "Standard_B1ls"
  custom_data                     = data.cloudinit_config.nva.rendered
  disable_password_authentication = false
  tags = merge(var.common_tags, {
    Name = "nva"
  })

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

data "cloudinit_config" "nva" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${var.workload_template_path}/quagga.tpl",
      {
        asn_quagga      = "65516"
        bgp_routerId    = azurerm_network_interface.nva.ip_configuration[0].private_ip_address
        bgp_network1    = local.cidrs.azure_germany_west_central
        routeserver_IP1 = tolist(azurerm_route_server.default.virtual_router_ips)[0]
        routeserver_IP2 = tolist(azurerm_route_server.default.virtual_router_ips)[1]
    })
  }
}

resource "azurerm_network_security_group" "nva" {
  name                = "nva"
  resource_group_name = azurerm_resource_group.vnet_germany_west_central.name
  location            = var.transit_azure_region
  tags                = var.common_tags
}

resource "azurerm_network_interface_security_group_association" "nva" {
  network_interface_id      = azurerm_network_interface.nva.id
  network_security_group_id = azurerm_network_security_group.nva.id
}

resource "azurerm_network_security_rule" "nva_rfc_1918" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "nva-rfc-1918"
  priority                    = 100
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefixes     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.vnet_germany_west_central.name
  network_security_group_name = azurerm_network_security_group.nva.name
}

resource "azurerm_network_security_rule" "nva_ssh" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "nva-ssh"
  priority                    = 110
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "${chomp(data.http.myip.response_body)}/32"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.vnet_germany_west_central.name
  network_security_group_name = azurerm_network_security_group.nva.name
}

resource "azurerm_network_security_rule" "nva_forward" {
  access                      = "Allow"
  direction                   = "Outbound"
  name                        = "nva-forward"
  priority                    = 110
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefixes     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.vnet_germany_west_central.name
  network_security_group_name = azurerm_network_security_group.nva.name
}

resource "azurerm_route_server_bgp_connection" "nva" {
  name            = "nva-to-ars-peer"
  peer_asn        = "65516"
  peer_ip         = azurerm_network_interface.nva.private_ip_address
  route_server_id = azurerm_route_server.default.id
}

# Flow Logs
resource "azurerm_storage_account" "flow_logs" {
  name                = "nvaflowsa"
  resource_group_name = "NetworkWatcherRG"
  location            = azurerm_resource_group.vnet_germany_west_central.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_log_analytics_workspace" "flow_logs" {
  name                = "nva-law"
  location            = azurerm_resource_group.vnet_germany_west_central.location
  resource_group_name = "NetworkWatcherRG"
  sku                 = "PerGB2018"
}

resource "azurerm_network_watcher_flow_log" "flow_logs" {
  network_watcher_name = "NetworkWatcher_germanywestcentral"
  resource_group_name  = "NetworkWatcherRG"
  name                 = "nva-flow-log"

  network_security_group_id = azurerm_network_security_group.nva.id
  storage_account_id        = azurerm_storage_account.flow_logs.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.flow_logs.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.flow_logs.location
    workspace_resource_id = azurerm_log_analytics_workspace.flow_logs.id
    interval_in_minutes   = 10
  }
}

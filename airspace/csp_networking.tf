# aws vpcs
module "vpc_us_east_1" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-us-east-1-application"
  cidr = "10.1.2.0/24"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.1.2.0/28", "10.1.2.16/28"]
  public_subnets  = ["10.1.2.32/28", "10.1.2.48/28"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.us-east-1
  }
}

module "vpc_us_east_2" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-us-east-1-application"
  cidr = "10.5.2.0/24"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.5.2.0/28", "10.5.2.16/28"]
  public_subnets  = ["10.5.2.32/28", "10.5.2.48/28"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.us-east-2
  }
}

# aviatrix tgw orchestrator us-east-1
resource "aviatrix_aws_tgw" "us_east_1" {
  account_name       = var.aws_backbone_account_name
  aws_side_as_number = "64512"
  region             = var.transit_aws_palo_firenet_region
  tgw_name           = "us-east-1-tgw"
}

resource "aviatrix_aws_tgw_network_domain" "default_domain" {
  name     = "Default_Domain"
  tgw_name = aviatrix_aws_tgw.us_east_1.tgw_name
}

resource "aviatrix_aws_tgw_network_domain" "shared_service_domain" {
  name     = "Shared_Service_Domain"
  tgw_name = aviatrix_aws_tgw.us_east_1.tgw_name
}

resource "aviatrix_aws_tgw_network_domain" "aviatrix_edge_domain" {
  name     = "Aviatrix_Edge_Domain"
  tgw_name = aviatrix_aws_tgw.us_east_1.tgw_name
}

resource "aviatrix_aws_tgw_transit_gateway_attachment" "us_east_1_transit" {
  tgw_name             = aviatrix_aws_tgw.us_east_1.tgw_name
  region               = var.transit_aws_palo_firenet_region
  vpc_account_name     = var.aws_backbone_account_name
  vpc_id               = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].vpc.vpc_id
  transit_gateway_name = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
}

resource "aviatrix_aws_tgw_vpc_attachment" "us_east_1_vpc" {
  tgw_name            = aviatrix_aws_tgw.us_east_1.tgw_name
  region              = var.transit_aws_palo_firenet_region
  network_domain_name = aviatrix_aws_tgw_network_domain.default_domain.name
  vpc_account_name    = var.aws_backbone_account_name
  vpc_id              = module.vpc_us_east_1.vpc_id
}

resource "aviatrix_aws_tgw_peering_domain_conn" "us_east_1" {
  tgw_name1    = aviatrix_aws_tgw.us_east_1.tgw_name
  domain_name1 = aviatrix_aws_tgw_network_domain.default_domain.name
  tgw_name2    = aviatrix_aws_tgw.us_east_1.tgw_name
  domain_name2 = aviatrix_aws_tgw_network_domain.aviatrix_edge_domain.name
}

# aviatrix tgw orchestrator us-east-2
resource "aviatrix_aws_tgw" "us_east_2" {
  account_name       = var.aws_backbone_account_name
  aws_side_as_number = "64513"
  region             = var.transit_aws_egress_fqdn_region
  tgw_name           = "us-east-2-tgw"
}

resource "aviatrix_aws_tgw_network_domain" "us_east_2_default_domain" {
  name     = "Default_Domain"
  tgw_name = aviatrix_aws_tgw.us_east_2.tgw_name
}

resource "aviatrix_aws_tgw_network_domain" "us_east_2_shared_service_domain" {
  name     = "Shared_Service_Domain"
  tgw_name = aviatrix_aws_tgw.us_east_2.tgw_name
}

resource "aviatrix_aws_tgw_network_domain" "us_east_2_aviatrix_edge_domain" {
  name     = "Aviatrix_Edge_Domain"
  tgw_name = aviatrix_aws_tgw.us_east_2.tgw_name
}

resource "aviatrix_aws_tgw_transit_gateway_attachment" "us_east_2_transit" {
  tgw_name             = aviatrix_aws_tgw.us_east_2.tgw_name
  region               = var.transit_aws_egress_fqdn_region
  vpc_account_name     = var.aws_backbone_account_name
  vpc_id               = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].vpc.vpc_id
  transit_gateway_name = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.gw_name
}

resource "aviatrix_aws_tgw_vpc_attachment" "us_east_2_vpc" {
  tgw_name            = aviatrix_aws_tgw.us_east_2.tgw_name
  region              = var.transit_aws_egress_fqdn_region
  network_domain_name = aviatrix_aws_tgw_network_domain.us_east_2_default_domain.name
  vpc_account_name    = var.aws_backbone_account_name
  vpc_id              = module.vpc_us_east_2.vpc_id
}

resource "aviatrix_aws_tgw_peering_domain_conn" "us_east_2" {
  tgw_name1    = aviatrix_aws_tgw.us_east_2.tgw_name
  domain_name1 = aviatrix_aws_tgw_network_domain.us_east_2_default_domain.name
  tgw_name2    = aviatrix_aws_tgw.us_east_2.tgw_name
  domain_name2 = aviatrix_aws_tgw_network_domain.us_east_2_aviatrix_edge_domain.name
}

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
  address_space       = ["10.2.2.0/24"]
  subnet_names        = ["private-subnet1", "public-subnet1"]
  subnet_prefixes     = ["10.2.2.0/28", "10.2.2.32/28"]
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
        bgp_network1    = "10.2.2.0/24"
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

# oci vcn
resource "oci_core_vcn" "spoke" {
  compartment_id = var.oci_backbone_compartment_ocid
  cidr_blocks    = ["10.3.2.0/24"]
  display_name   = "spoke"
}

resource "oci_core_subnet" "spoke_public" {
  cidr_block        = "10.3.2.0/28"
  compartment_id    = var.oci_backbone_compartment_ocid
  vcn_id            = oci_core_vcn.spoke.id
  display_name      = "spoke-public"
  security_list_ids = [oci_core_security_list.spoke.id]
}

resource "oci_core_subnet" "spoke_private" {
  cidr_block        = "10.3.2.16/28"
  compartment_id    = var.oci_backbone_compartment_ocid
  vcn_id            = oci_core_vcn.spoke.id
  display_name      = "spoke-private"
  security_list_ids = [oci_core_security_list.spoke.id]
}

resource "oci_core_internet_gateway" "spoke" {
  compartment_id = var.oci_backbone_compartment_ocid
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "spoke"
}

resource "oci_core_route_table" "spoke_public" {
  compartment_id = var.oci_backbone_compartment_ocid
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "spoke-public"
  route_rules {
    network_entity_id = oci_core_internet_gateway.spoke.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_drg.default.id
    destination       = "10.0.0.0/8"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_drg.default.id
    destination       = "192.168.0.0/16"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_drg.default.id
    destination       = "172.16.0.0/12"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table_attachment" "spoke_public" {
  subnet_id      = oci_core_subnet.spoke_public.id
  route_table_id = oci_core_route_table.spoke_public.id
}

resource "oci_core_route_table" "spoke_private" {
  compartment_id = var.oci_backbone_compartment_ocid
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "spoke-private"
  route_rules {
    network_entity_id = oci_core_drg.default.id
    destination       = "10.0.0.0/8"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_drg.default.id
    destination       = "192.168.0.0/16"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_drg.default.id
    destination       = "172.16.0.0/12"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table_attachment" "spoke_private" {
  subnet_id      = oci_core_subnet.spoke_private.id
  route_table_id = oci_core_route_table.spoke_private.id
}

# oci drg
resource "oci_core_drg" "default" {
  compartment_id = var.oci_backbone_compartment_ocid
  display_name   = "default"
}

resource "oci_core_drg_attachment" "spoke" {
  drg_id       = oci_core_drg.default.id
  display_name = "spoke-drg"
  vcn_id       = oci_core_vcn.spoke.id
}


resource "oci_core_security_list" "spoke" {
  compartment_id = var.oci_backbone_compartment_ocid
  vcn_id         = oci_core_vcn.spoke.id
  display_name   = "spoke-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"
  }
}

#--
resource "aviatrix_transit_external_device_conn" "oci_drg" {
  vpc_id             = module.multicloud_transit.transit["oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}"].vpc.vpc_id
  connection_name    = "oci-drg"
  gw_name            = module.multicloud_transit.transit["oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  connection_type    = "bgp"
  remote_gateway_ip  = oci_core_ipsec_connection_tunnel_management.drg_transit_tunnel_1.vpn_ip
  pre_shared_key     = var.oci_shared_secret
  bgp_local_as_num   = "65103"
  bgp_remote_as_num  = "31898"
  ha_enabled         = false
  local_tunnel_cidr  = "169.254.30.1/30"
  remote_tunnel_cidr = "169.254.30.2/30"
}

resource "oci_core_cpe" "transit_gw" {
  compartment_id = var.oci_backbone_compartment_ocid
  ip_address     = module.multicloud_transit.transit["oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}"].transit_gateway.eip
  display_name   = "transit-gw"
}

resource "oci_core_ipsec" "transit_gw" {
  compartment_id = var.oci_backbone_compartment_ocid
  cpe_id         = oci_core_cpe.transit_gw.id
  drg_id         = oci_core_drg.default.id
  static_routes  = ["123.123.123.123/32"] //documentation says an empty list can be provided but [""] throws an error. Dummy route.
  display_name   = "transit-gw"
}

data "oci_core_ipsec_connection_tunnels" "transit_gw" {
  ipsec_id = oci_core_ipsec.transit_gw.id
}

resource "oci_core_ipsec_connection_tunnel_management" "drg_transit_tunnel_1" {
  ipsec_id  = oci_core_ipsec.transit_gw.id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.transit_gw.ip_sec_connection_tunnels[0].id
  routing   = "BGP"
  bgp_session_info {
    customer_bgp_asn      = "65103"
    customer_interface_ip = "169.254.30.1/30"
    oracle_interface_ip   = "169.254.30.2/30"
  }
  display_name  = "drg-transit-tunnel-1"
  shared_secret = var.oci_shared_secret
  ike_version   = "V1"
}

resource "oci_core_cpe" "transit_gw_dummy" {
  compartment_id = var.oci_backbone_compartment_ocid
  ip_address     = "1.1.1.1"
  display_name   = "transit-gw-dummy"
  depends_on     = [aviatrix_transit_external_device_conn.oci_drg]
}

resource "oci_core_ipsec" "transit_gw_dummy" {
  compartment_id = var.oci_backbone_compartment_ocid
  cpe_id         = oci_core_cpe.transit_gw_dummy.id
  drg_id         = oci_core_drg.default.id
  static_routes  = ["123.123.123.123/32"] //documentation says an empty list can be provided but [""] throws an error. Dummy route.
  display_name   = "transit-gw-dummy"
}

data "oci_core_ipsec_connection_tunnels" "transit_gw_dummy" {
  ipsec_id = oci_core_ipsec.transit_gw_dummy.id
}

resource "oci_core_ipsec_connection_tunnel_management" "drg_transit_tunnel_dummy_1" {
  ipsec_id  = oci_core_ipsec.transit_gw_dummy.id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.transit_gw_dummy.ip_sec_connection_tunnels[0].id
  routing   = "BGP"
  bgp_session_info {
    customer_bgp_asn      = "65103"
    customer_interface_ip = "169.254.31.5/30"
    oracle_interface_ip   = "169.254.31.6/30"
  }
  display_name  = "drg-transit-tunnel-dummy-1"
  shared_secret = var.oci_shared_secret
  ike_version   = "V1"
}

# gcp
resource "google_compute_network" "vpc" {
  name                    = "vpc-us-west1-application"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc" {
  name          = "vpc-us-west1-application-sub1"
  ip_cidr_range = "10.4.2.0/28"
  region        = var.transit_gcp_region
  network       = google_compute_network.vpc.id
}

resource "google_compute_network" "hub" {
  name                    = "gcp-hub-i"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hub" {
  name          = "gcp-hub-i-subnet-1-public"
  ip_cidr_range = "10.4.4.0/28"
  region        = var.transit_gcp_region
  network       = google_compute_network.hub.id
}

resource "google_compute_router" "hub" {
  region  = var.transit_gcp_region
  name    = "gcp-hub-i-router"
  network = google_compute_network.hub.name
  bgp {
    asn = "65446"
  }
}

resource "google_compute_router" "spoke" {
  region  = var.transit_gcp_region
  name    = "gcp-spoke-a-router"
  network = google_compute_network.vpc.name
  bgp {
    asn = "65444"
  }
}

resource "google_compute_ha_vpn_gateway" "hub" {
  region  = var.transit_gcp_region
  name    = "gcp-hub-i-vpn-gw"
  network = google_compute_network.hub.name
}

resource "google_compute_ha_vpn_gateway" "spoke" {
  region  = var.transit_gcp_region
  name    = "gcp-spoke-a-vpn-gw"
  network = google_compute_network.vpc.name
}

resource "google_compute_vpn_tunnel" "hub_spoke" {
  name                  = "gcp-hub-i-spoke-a-tunnel-0"
  region                = var.transit_gcp_region
  vpn_gateway           = google_compute_ha_vpn_gateway.hub.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.spoke.id
  shared_secret         = var.gcp_shared_secret
  router                = google_compute_router.hub.id
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "spoke_hub" {
  name                  = "gcp-spoke-a-hub-i-tunnel-0"
  region                = var.transit_gcp_region
  vpn_gateway           = google_compute_ha_vpn_gateway.spoke.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.hub.id
  shared_secret         = var.gcp_shared_secret
  router                = google_compute_router.spoke.id
  vpn_gateway_interface = 0
}

resource "google_compute_router_interface" "hub" {
  name       = "gcp-hub-i-router-interface-a0"
  router     = google_compute_router.hub.name
  region     = var.transit_gcp_region
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.hub_spoke.name
}

resource "google_compute_router_peer" "hub" {
  name                      = "gcp-hub-i-router-peer-a0"
  router                    = google_compute_router.hub.name
  region                    = var.transit_gcp_region
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = "65444"
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.hub.name
}

resource "google_compute_router_interface" "spoke" {
  name       = "gcp-spoke-a-router-interface-a0"
  router     = google_compute_router.spoke.name
  region     = var.transit_gcp_region
  ip_range   = "169.254.0.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.spoke_hub.name
}

resource "google_compute_router_peer" "spoke" {
  name                      = "gcp-spoke-a-router-peer-a0"
  router                    = google_compute_router.spoke.name
  region                    = var.transit_gcp_region
  peer_ip_address           = "169.254.0.1"
  peer_asn                  = "65446"
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.spoke.name
}

resource "google_network_connectivity_hub" "hub" {
  name = "gcp-ncc-hub-i"
}

resource "google_network_connectivity_spoke" "spoke" {
  name     = "gcp-ncc-spoke-a"
  location = var.transit_gcp_region
  hub      = google_network_connectivity_hub.hub.id
  linked_vpn_tunnels {
    uris                       = [google_compute_vpn_tunnel.hub_spoke.self_link]
    site_to_site_data_transfer = true
  }
}

resource "aviatrix_transit_external_device_conn" "hub" {
  vpc_id            = module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].vpc.vpc_id
  connection_name   = "gcp-transit-i-gcp-hub-i"
  gw_name           = module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  connection_type   = "bgp"
  tunnel_protocol   = "lan"
  bgp_local_as_num  = "65104"
  bgp_remote_as_num = "65446"
  remote_lan_ip     = google_compute_address.hub_router_1.address
  local_lan_ip      = module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.bgp_lan_ip_list[0]
}

resource "google_compute_router_peer" "hub_transit" {
  name                      = "gcp-hub-i-router-peer-transit-i0"
  router                    = google_compute_router.hub.name
  region                    = var.transit_gcp_region
  peer_ip_address           = module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.bgp_lan_ip_list[0]
  peer_asn                  = "65104"
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.hub_transit.name
  router_appliance_instance = data.google_compute_instance.transit.self_link
  advertise_mode            = "CUSTOM"
  advertised_ip_ranges {
    range = "10.4.2.0/28"
  }
  advertised_ip_ranges {
    range = "10.4.2.16/28"
  }
  depends_on = [google_network_connectivity_spoke.transit]
  lifecycle {
    ignore_changes = [
      router_appliance_instance
    ]
  }
}

resource "google_compute_router_peer" "hub_transit_redundant" {
  name                      = "gcp-hub-i-router-peer-transit-i0-redundant"
  router                    = google_compute_router.hub.name
  region                    = var.transit_gcp_region
  peer_ip_address           = module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.bgp_lan_ip_list[0]
  peer_asn                  = "65104"
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.hub_transit_redundant.name
  router_appliance_instance = data.google_compute_instance.transit.self_link
  advertise_mode            = "CUSTOM"
  advertised_ip_ranges {
    range = "10.4.2.0/28"
  }
  advertised_ip_ranges {
    range = "10.4.2.16/28"
  }
  depends_on = [google_network_connectivity_spoke.transit]
  lifecycle {
    ignore_changes = [
      router_appliance_instance
    ]
  }
}

resource "google_compute_router_interface" "hub_transit" {
  name                = "gcp-hub-i-router-interface-transit-i0"
  router              = google_compute_router.hub.name
  region              = var.transit_gcp_region
  subnetwork          = google_compute_subnetwork.hub.self_link
  private_ip_address  = google_compute_address.hub_router_1.address
  redundant_interface = google_compute_router_interface.hub_transit_redundant.name
}

resource "google_compute_router_interface" "hub_transit_redundant" {
  name               = "gcp-hub-i-router-interface-transit-i0-redundant"
  router             = google_compute_router.hub.name
  region             = var.transit_gcp_region
  subnetwork         = google_compute_subnetwork.hub.self_link
  private_ip_address = google_compute_address.hub_router_2.address
}

resource "google_compute_address" "hub_router_1" {
  name         = "gcp-hub-i-router-interface-1-address"
  region       = var.transit_gcp_region
  subnetwork   = google_compute_subnetwork.hub.self_link
  address_type = "INTERNAL"
}

resource "google_compute_address" "hub_router_2" {
  name         = "gcp-hub-i-router-interface-2-address"
  region       = var.transit_gcp_region
  subnetwork   = google_compute_subnetwork.hub.self_link
  address_type = "INTERNAL"
}

data "google_compute_instance" "transit" {
  name = module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  zone = module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.vpc_reg
  depends_on = [
    module.multicloud_transit
  ]
}

resource "google_network_connectivity_spoke" "transit" {
  name     = "gcp-transit-1-as-spoke-to-ncc"
  location = var.transit_gcp_region
  hub      = google_network_connectivity_hub.hub.id

  linked_router_appliance_instances {
    instances {
      virtual_machine = data.google_compute_instance.transit.self_link
      ip_address      = module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.bgp_lan_ip_list[0]
    }
    site_to_site_data_transfer = true
  }
  lifecycle {
    ignore_changes = [
      linked_router_appliance_instances[0].instances[0].virtual_machine
    ]
  }
}

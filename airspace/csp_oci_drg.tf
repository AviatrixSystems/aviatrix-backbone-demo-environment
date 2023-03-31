# oci
resource "oci_core_vcn" "spoke" {
  compartment_id = var.oci_backbone_compartment_ocid
  cidr_blocks    = [local.cidrs.oci_singapore_1]
  display_name   = "spoke"
}

resource "oci_core_subnet" "spoke_public" {
  cidr_block        = cidrsubnet(local.cidrs.oci_singapore_1, 4, 0)
  compartment_id    = var.oci_backbone_compartment_ocid
  vcn_id            = oci_core_vcn.spoke.id
  display_name      = "spoke-public"
  security_list_ids = [oci_core_security_list.spoke.id]
}

resource "oci_core_subnet" "spoke_private" {
  cidr_block        = cidrsubnet(local.cidrs.oci_singapore_1, 4, 1)
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

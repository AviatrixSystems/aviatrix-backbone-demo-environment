# gcp
resource "google_compute_network" "vpc" {
  name                    = "vpc-us-west1-application"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc" {
  name          = "vpc-us-west1-application-sub1"
  ip_cidr_range = cidrsubnet(local.cidrs.gcp_west1, 4, 0)
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
    range = cidrsubnet(local.cidrs.gcp_west1, 4, 0)
  }
  advertised_ip_ranges {
    range = cidrsubnet(local.cidrs.gcp_west1, 4, 1)
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
    range = cidrsubnet(local.cidrs.gcp_west1, 4, 0)
  }
  advertised_ip_ranges {
    range = cidrsubnet(local.cidrs.gcp_west1, 4, 1)
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

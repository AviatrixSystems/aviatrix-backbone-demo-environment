# Network segmentation
resource "aviatrix_segmentation_network_domain" "demo" {
  for_each    = toset(local.network_domains)
  domain_name = each.value
}

resource "aviatrix_segmentation_network_domain_association" "aws" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  attachment_name     = module.avx_spoke.spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "aws_tgw_us_east_1" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  attachment_name     = aviatrix_transit_external_device_conn.tgw_us_east_1.connection_name
}

resource "aviatrix_segmentation_network_domain_association" "aws_tgw_us_east_1_dev" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  attachment_name     = aviatrix_transit_external_device_conn.tgw_us_east_1_dev.connection_name
}

resource "aviatrix_segmentation_network_domain_association" "aws_tgw_us_east_2" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  attachment_name     = aviatrix_transit_external_device_conn.tgw_us_east_2.connection_name
}

resource "aviatrix_segmentation_network_domain_association" "aws_tgw_us_east_2_dev" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  attachment_name     = aviatrix_transit_external_device_conn.tgw_us_east_2_dev.connection_name
}

resource "aviatrix_segmentation_network_domain_association" "landing_zone" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Landing_zone"].domain_name
  attachment_name     = module.avx_landing_zone.spoke_gateway.gw_name
}

resource "aviatrix_segmentation_network_domain_association" "gcp" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Gcp"].domain_name
  attachment_name     = aviatrix_transit_external_device_conn.hub.connection_name
}

resource "aviatrix_segmentation_network_domain_association" "azure" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Azure"].domain_name
  attachment_name     = aviatrix_transit_external_device_conn.default.connection_name
}

resource "aviatrix_segmentation_network_domain_association" "oci" {
  network_domain_name = aviatrix_segmentation_network_domain.demo["Oci"].domain_name
  attachment_name     = aviatrix_transit_external_device_conn.oci_drg.connection_name
}

resource "aviatrix_segmentation_network_domain_association" "edge_sv" {
  for_each            = { for k, v in module.edge_sv.host_vm_details : k => v if length(split("-1", k)) > 1 }
  network_domain_name = aviatrix_segmentation_network_domain.demo["Edge"].domain_name
  attachment_name     = replace(each.value.edge_vm, "-1", "-site")
}

resource "aviatrix_segmentation_network_domain_association" "edge_dc" {
  for_each            = { for k, v in module.edge_dc.host_vm_details : k => v if length(split("-1", k)) > 1 }
  network_domain_name = aviatrix_segmentation_network_domain.demo["Edge"].domain_name
  attachment_name     = replace(each.value.edge_vm, "-1", "-site")
}

resource "aviatrix_segmentation_network_domain_connection_policy" "aws_edge" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Edge"].domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "aws_azure" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Azure"].domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "aws_gcp" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Gcp"].domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "aws_oci" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Oci"].domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "gcp_oci" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Gcp"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Oci"].domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "gcp_azure" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Gcp"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Azure"].domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "azure_oci" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Azure"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Oci"].domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "azure_edge" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Azure"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Edge"].domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "aws_landing_zone" {
  domain_name_1 = aviatrix_segmentation_network_domain.demo["Aws"].domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.demo["Landing_zone"].domain_name
}

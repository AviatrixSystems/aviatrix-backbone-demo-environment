data "terraform_remote_state" "controller" {
  backend = "s3"
  config = {
    bucket  = "backbone.aviatrixtest.com"
    key     = "controller.tfstate"
    region  = "us-west-2"
    profile = "demo_backbone"
  }
}

data "http" "myip" {
  url = "http://ifconfig.me"
}

module "edge_sv" {
  # source              = "github.com/MatthewKazmar/avxedgedemo?ref=7a0f882"
  source              = "github.com/jb-smoker/avxedgedemo"
  admin_cidr          = ["${chomp(data.http.myip.response_body)}/32"]
  region              = var.edge_sv_gcp_region
  pov_prefix          = "sv-metro-equinix"
  host_vm_size        = "n2-standard-2"
  host_vm_cidr        = "10.40.251.16/28"
  host_vm_asn         = 64900
  host_vm_count       = 1
  edge_vm_asn         = 64581
  edge_lan_cidr       = "10.40.251.0/29"
  edge_image_filename = "${path.module}/avx-edge-gateway-kvm-2022-09-23-6.8.qcow2"
  test_vm_metadata_startup_script = templatefile("${var.workload_template_path}/traffic_gen.tpl", {
    name     = local.traffic_gen.edge_sv.name
    apps     = join(",", local.traffic_gen.edge_sv.apps)
    external = join(",", local.traffic_gen.edge_sv.external)
    interval = local.traffic_gen.edge_sv.interval
    password = var.workload_instance_password
  })
  external_cidrs = [
    "10.40.1.0/28", "10.40.1.16/28", "10.40.1.32/28", "10.40.1.48/28", "10.40.1.64/28", "10.40.1.80/28", "10.40.1.96/28", "10.40.1.112/28", "10.40.1.128/28", "10.40.1.144/28", "10.40.1.160/28", "10.40.1.176/28", "10.40.1.192/28", "10.40.1.208/28", "10.40.1.224/28", "10.40.1.240/28",
    "10.40.2.0/28", "10.40.2.16/28", "10.40.2.32/28", "10.40.2.48/28", "10.40.2.64/28", "10.40.2.80/28", "10.40.2.96/28", "10.40.2.112/28", "10.40.2.128/28", "10.40.2.144/28", "10.40.2.160/28", "10.40.2.176/28", "10.40.2.192/28", "10.40.2.208/28", "10.40.2.224/28", "10.40.2.240/28",
    "10.40.3.0/28", "10.40.3.16/28", "10.40.3.32/28", "10.40.3.48/28", "10.40.3.64/28", "10.40.3.80/28", "10.40.3.96/28", "10.40.3.112/28", "10.40.3.128/28", "10.40.3.144/28", "10.40.3.160/28", "10.40.3.176/28", "10.40.3.192/28", "10.40.3.208/28", "10.40.3.224/28", "10.40.3.240/28",
    "10.40.4.0/28", "10.40.4.16/28", "10.40.4.32/28", "10.40.4.48/28", "10.40.4.64/28", "10.40.4.80/28", "10.40.4.96/28", "10.40.4.112/28", "10.40.4.128/28", "10.40.4.144/28", "10.40.4.160/28", "10.40.4.176/28", "10.40.4.192/28", "10.40.4.208/28", "10.40.4.224/28", "10.40.4.240/28",
    "10.40.5.0/28", "10.40.5.16/28", "10.40.5.32/28", "10.40.5.48/28", "10.40.5.64/28", "10.40.5.80/28", "10.40.5.96/28", "10.40.5.112/28", "10.40.5.128/28", "10.40.5.144/28", "10.40.5.160/28", "10.40.5.176/28", "10.40.5.192/28", "10.40.5.208/28", "10.40.5.224/28", "10.40.5.240/28",
    "10.40.6.0/28", "10.40.6.16/28", "10.40.6.32/28", "10.40.6.48/28", "10.40.6.64/28", "10.40.6.80/28", "10.40.6.96/28", "10.40.6.112/28", "10.40.6.128/28", "10.40.6.144/28", "10.40.6.160/28", "10.40.6.176/28", "10.40.6.192/28", "10.40.6.208/28", "10.40.6.224/28", "10.40.6.240/28",
    "10.40.7.0/28", "10.40.7.16/28", "10.40.7.32/28", "10.40.7.48/28", "10.40.7.64/28", "10.40.7.80/28", "10.40.7.96/28", "10.40.7.112/28", "10.40.7.128/28", "10.40.7.144/28", "10.40.7.160/28", "10.40.7.176/28", "10.40.7.192/28", "10.40.7.208/28", "10.40.7.224/28", "10.40.7.240/28",
    "10.40.8.0/28", "10.40.8.16/28", "10.40.8.32/28", "10.40.8.48/28", "10.40.8.64/28", "10.40.8.80/28", "10.40.8.96/28", "10.40.8.112/28", "10.40.8.128/28", "10.40.8.144/28", "10.40.8.160/28", "10.40.8.176/28", "10.40.8.192/28", "10.40.8.208/28", "10.40.8.224/28", "10.40.8.240/28",
    "10.40.9.0/28", "10.40.9.16/28", "10.40.9.32/28", "10.40.9.48/28", "10.40.9.64/28", "10.40.9.80/28", "10.40.9.96/28", "10.40.9.112/28", "10.40.9.128/28", "10.40.9.144/28", "10.40.9.160/28", "10.40.9.176/28", "10.40.9.192/28", "10.40.9.208/28", "10.40.9.224/28", "10.40.9.240/28",
    "10.40.10.0/28", "10.40.10.16/28", "10.40.10.32/28", "10.40.10.48/28", "10.40.10.64/28", "10.40.10.80/28", "10.40.10.96/28", "10.40.10.112/28", "10.40.10.128/28", "10.40.10.144/28", "10.40.10.160/28", "10.40.10.176/28", "10.40.10.192/28", "10.40.10.208/28", "10.40.10.224/28", "10.40.10.240/28",
    "10.40.11.0/28", "10.40.11.16/28", "10.40.11.32/28", "10.40.11.48/28", "10.40.11.64/28", "10.40.11.80/28", "10.40.11.96/28", "10.40.11.112/28", "10.40.11.128/28", "10.40.11.144/28", "10.40.11.160/28", "10.40.11.176/28", "10.40.11.192/28", "10.40.11.208/28", "10.40.11.224/28", "10.40.11.240/28",
    "10.40.12.0/28", "10.40.12.16/28", "10.40.12.32/28", "10.40.12.48/28", "10.40.12.64/28", "10.40.12.80/28", "10.40.12.96/28", "10.40.12.112/28", "10.40.12.128/28", "10.40.12.144/28", "10.40.12.160/28", "10.40.12.176/28", "10.40.12.192/28", "10.40.12.208/28", "10.40.12.224/28", "10.40.12.240/28",
    "10.40.13.0/28", "10.40.13.16/28", "10.40.13.32/28", "10.40.13.48/28", "10.40.13.64/28", "10.40.13.80/28", "10.40.13.96/28", "10.40.13.112/28", "10.40.13.128/28", "10.40.13.144/28", "10.40.13.160/28", "10.40.13.176/28", "10.40.13.192/28", "10.40.13.208/28", "10.40.13.224/28", "10.40.13.240/28",
    "10.40.14.0/28", "10.40.14.16/28", "10.40.14.32/28", "10.40.14.48/28", "10.40.14.64/28", "10.40.14.80/28", "10.40.14.96/28", "10.40.14.112/28", "10.40.14.128/28", "10.40.14.144/28", "10.40.14.160/28", "10.40.14.176/28", "10.40.14.192/28", "10.40.14.208/28", "10.40.14.224/28", "10.40.14.240/28",
  ]
  vm_ssh_key = local.public_key
  transit_gateways = [
    module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.multicloud_transit.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.multicloud_transit.transit["oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
  ]
}

resource "aws_security_group_rule" "edge_sv" {
  for_each          = module.edge_sv.host_vm_pip
  type              = "ingress"
  description       = "Allows HTTPS inbound from ${each.key}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${each.value.address}/32"]
  security_group_id = data.terraform_remote_state.controller.outputs.controller_security_group_id
}

resource "aws_security_group_rule" "edge_sv_copilot" {
  for_each          = module.edge_sv.host_vm_pip
  type              = "ingress"
  description       = "Allows HTTPS inbound from ${each.key}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${each.value.address}/32"]
  security_group_id = data.terraform_remote_state.controller.outputs.copilot_security_group_id
}

resource "aws_security_group_rule" "edge_sv_copilot_31283" {
  for_each          = module.edge_sv.host_vm_pip
  type              = "ingress"
  description       = "Allows HTTPS inbound from ${each.key}"
  from_port         = 31283
  to_port           = 31283
  protocol          = "udp"
  cidr_blocks       = ["${each.value.address}/32"]
  security_group_id = data.terraform_remote_state.controller.outputs.copilot_security_group_id
}

resource "aws_security_group_rule" "edge_sv_copilot_5000" {
  for_each          = module.edge_sv.host_vm_pip
  type              = "ingress"
  description       = "Allows HTTPS inbound from ${each.key}"
  from_port         = 5000
  to_port           = 5000
  protocol          = "udp"
  cidr_blocks       = ["${each.value.address}/32"]
  security_group_id = data.terraform_remote_state.controller.outputs.copilot_security_group_id
}

module "edge_dc" {
  # source              = "github.com/MatthewKazmar/avxedgedemo?ref=7a0f882"
  source              = "github.com/jb-smoker/avxedgedemo"
  admin_cidr          = ["${chomp(data.http.myip.response_body)}/32"]
  region              = var.edge_dc_gcp_region
  pov_prefix          = "dc-metro-equinix"
  host_vm_size        = "n2-standard-2"
  host_vm_cidr        = "10.50.251.16/28"
  host_vm_asn         = 64901
  host_vm_count       = 1
  edge_vm_asn         = 64582
  edge_lan_cidr       = "10.50.251.0/29"
  edge_image_filename = "${path.module}/avx-edge-gateway-kvm-2022-09-23-6.8.qcow2"
  test_vm_metadata_startup_script = templatefile("${var.workload_template_path}/traffic_gen.tpl", {
    name     = local.traffic_gen.edge_dc.name
    apps     = join(",", local.traffic_gen.edge_dc.apps)
    external = join(",", local.traffic_gen.edge_dc.external)
    interval = local.traffic_gen.edge_dc.interval
    password = var.workload_instance_password
  })
  external_cidrs = [
    "10.50.1.0/28", "10.50.1.16/28", "10.50.1.32/28", "10.50.1.48/28", "10.50.1.64/28", "10.50.1.80/28", "10.50.1.96/28", "10.50.1.112/28", "10.50.1.128/28", "10.50.1.144/28", "10.50.1.160/28", "10.50.1.176/28", "10.50.1.192/28", "10.50.1.208/28", "10.50.1.224/28", "10.50.1.240/28",
    "10.50.2.0/28", "10.50.2.16/28", "10.50.2.32/28", "10.50.2.48/28", "10.50.2.64/28", "10.50.2.80/28", "10.50.2.96/28", "10.50.2.112/28", "10.50.2.128/28", "10.50.2.144/28", "10.50.2.160/28", "10.50.2.176/28", "10.50.2.192/28", "10.50.2.208/28", "10.50.2.224/28", "10.50.2.240/28",
    "10.50.3.0/28", "10.50.3.16/28", "10.50.3.32/28", "10.50.3.48/28", "10.50.3.64/28", "10.50.3.80/28", "10.50.3.96/28", "10.50.3.112/28", "10.50.3.128/28", "10.50.3.144/28", "10.50.3.160/28", "10.50.3.176/28", "10.50.3.192/28", "10.50.3.208/28", "10.50.3.224/28", "10.50.3.240/28",
    "10.50.4.0/28", "10.50.4.16/28", "10.50.4.32/28", "10.50.4.48/28", "10.50.4.64/28", "10.50.4.80/28", "10.50.4.96/28", "10.50.4.112/28", "10.50.4.128/28", "10.50.4.144/28", "10.50.4.160/28", "10.50.4.176/28", "10.50.4.192/28", "10.50.4.208/28", "10.50.4.224/28", "10.50.4.240/28",
    "10.50.5.0/28", "10.50.5.16/28", "10.50.5.32/28", "10.50.5.48/28", "10.50.5.64/28", "10.50.5.80/28", "10.50.5.96/28", "10.50.5.112/28", "10.50.5.128/28", "10.50.5.144/28", "10.50.5.160/28", "10.50.5.176/28", "10.50.5.192/28", "10.50.5.208/28", "10.50.5.224/28", "10.50.5.240/28",
    "10.50.6.0/28", "10.50.6.16/28", "10.50.6.32/28", "10.50.6.48/28", "10.50.6.64/28", "10.50.6.80/28", "10.50.6.96/28", "10.50.6.112/28", "10.50.6.128/28", "10.50.6.144/28", "10.50.6.160/28", "10.50.6.176/28", "10.50.6.192/28", "10.50.6.208/28", "10.50.6.224/28", "10.50.6.240/28",
    "10.50.7.0/28", "10.50.7.16/28", "10.50.7.32/28", "10.50.7.48/28", "10.50.7.64/28", "10.50.7.80/28", "10.50.7.96/28", "10.50.7.112/28", "10.50.7.128/28", "10.50.7.144/28", "10.50.7.160/28", "10.50.7.176/28", "10.50.7.192/28", "10.50.7.208/28", "10.50.7.224/28", "10.50.7.240/28",
    "10.50.8.0/28", "10.50.8.16/28", "10.50.8.32/28", "10.50.8.48/28", "10.50.8.64/28", "10.50.8.80/28", "10.50.8.96/28", "10.50.8.112/28", "10.50.8.128/28", "10.50.8.144/28", "10.50.8.160/28", "10.50.8.176/28", "10.50.8.192/28", "10.50.8.208/28", "10.50.8.224/28", "10.50.8.240/28",
    "10.50.9.0/28", "10.50.9.16/28", "10.50.9.32/28", "10.50.9.48/28", "10.50.9.64/28", "10.50.9.80/28", "10.50.9.96/28", "10.50.9.112/28", "10.50.9.128/28", "10.50.9.144/28", "10.50.9.160/28", "10.50.9.176/28", "10.50.9.192/28", "10.50.9.208/28", "10.50.9.224/28", "10.50.9.240/28",
    "10.50.10.0/28", "10.50.10.16/28", "10.50.10.32/28", "10.50.10.48/28", "10.50.10.64/28", "10.50.10.80/28", "10.50.10.96/28", "10.50.10.112/28", "10.50.10.128/28", "10.50.10.144/28", "10.50.10.160/28", "10.50.10.176/28", "10.50.10.192/28", "10.50.10.208/28", "10.50.10.224/28", "10.50.10.240/28",
    "10.50.11.0/28", "10.50.11.16/28", "10.50.11.32/28", "10.50.11.48/28", "10.50.11.64/28", "10.50.11.80/28", "10.50.11.96/28", "10.50.11.112/28", "10.50.11.128/28", "10.50.11.144/28", "10.50.11.160/28", "10.50.11.176/28", "10.50.11.192/28", "10.50.11.208/28", "10.50.11.224/28", "10.50.11.240/28",
    "10.50.12.0/28", "10.50.12.16/28", "10.50.12.32/28", "10.50.12.48/28", "10.50.12.64/28", "10.50.12.80/28", "10.50.12.96/28", "10.50.12.112/28", "10.50.12.128/28", "10.50.12.144/28", "10.50.12.160/28", "10.50.12.176/28", "10.50.12.192/28", "10.50.12.208/28", "10.50.12.224/28", "10.50.12.240/28",
    "10.50.13.0/28", "10.50.13.16/28", "10.50.13.32/28", "10.50.13.48/28", "10.50.13.64/28", "10.50.13.80/28", "10.50.13.96/28", "10.50.13.112/28", "10.50.13.128/28", "10.50.13.144/28", "10.50.13.160/28", "10.50.13.176/28", "10.50.13.192/28", "10.50.13.208/28", "10.50.13.224/28", "10.50.13.240/28",
    "10.50.14.0/28", "10.50.14.16/28", "10.50.14.32/28", "10.50.14.48/28", "10.50.14.64/28", "10.50.14.80/28", "10.50.14.96/28", "10.50.14.112/28", "10.50.14.128/28", "10.50.14.144/28", "10.50.14.160/28", "10.50.14.176/28", "10.50.14.192/28", "10.50.14.208/28", "10.50.14.224/28", "10.50.14.240/28",
  ]
  vm_ssh_key = local.public_key
  transit_gateways = [
    module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.multicloud_transit.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.multicloud_transit.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.multicloud_transit.transit["oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
  ]
}

resource "aws_security_group_rule" "edge_dc" {
  for_each          = module.edge_dc.host_vm_pip
  type              = "ingress"
  description       = "Allows HTTPS inbound from ${each.key}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${each.value.address}/32"]
  security_group_id = data.terraform_remote_state.controller.outputs.controller_security_group_id
}

resource "aws_security_group_rule" "edge_dc_copilot" {
  for_each          = module.edge_dc.host_vm_pip
  type              = "ingress"
  description       = "Allows HTTPS inbound from ${each.key}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${each.value.address}/32"]
  security_group_id = data.terraform_remote_state.controller.outputs.copilot_security_group_id
}

resource "aws_security_group_rule" "edge_dc_copilot_31283" {
  for_each          = module.edge_dc.host_vm_pip
  type              = "ingress"
  description       = "Allows HTTPS inbound from ${each.key}"
  from_port         = 31283
  to_port           = 31283
  protocol          = "tcp"
  cidr_blocks       = ["${each.value.address}/32"]
  security_group_id = data.terraform_remote_state.controller.outputs.copilot_security_group_id
}

resource "aws_security_group_rule" "edge_dc_copilot_5000" {
  for_each          = module.edge_dc.host_vm_pip
  type              = "ingress"
  description       = "Allows HTTPS inbound from ${each.key}"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = ["${each.value.address}/32"]
  security_group_id = data.terraform_remote_state.controller.outputs.copilot_security_group_id
}

# https://registry.terraform.io/modules/terraform-aviatrix-modules/backbone/aviatrix/latest
module "multicloud_transit" {
  source          = "terraform-aviatrix-modules/backbone/aviatrix"
  version         = "v1.1.2"
  transit_firenet = local.transit_firenet
}

module "avx_spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.5.0"

  cloud         = "aws"
  name          = "avx-${var.transit_aws_egress_fqdn_region}-spoke"
  cidr          = "10.6.2.0/24"
  region        = var.transit_aws_egress_fqdn_region
  account       = var.aws_backbone_account_name
  instance_size = "t3.micro"

  transit_gw = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  ha_gw      = false
  attached   = true
}

module "avx_landing_zone" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.5.0"

  cloud         = "aws"
  name          = "avx-${var.transit_aws_palo_firenet_region}-landing-zone"
  cidr          = "172.16.0.0/16"
  region        = var.transit_aws_palo_firenet_region
  account       = var.aws_backbone_account_name
  instance_size = "t3.micro"

  transit_gw = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  ha_gw      = false
  attached   = true
}

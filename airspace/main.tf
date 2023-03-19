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

data "aws_route_table" "avx_spoke_public_1" {
  subnet_id = module.avx_spoke.vpc.public_subnets[0].subnet_id
  provider  = aws.us-east-2
}

data "aws_route_table" "avx_spoke_public_2" {
  subnet_id = module.avx_spoke.vpc.public_subnets[1].subnet_id
  provider  = aws.us-east-2
}

resource "aviatrix_gateway" "accounting_psf_dev" {
  cloud_type                                  = 1
  account_name                                = var.aws_backbone_account_name
  gw_name                                     = "avx-${var.transit_aws_egress_fqdn_region}-psf"
  vpc_id                                      = module.avx_spoke.vpc.vpc_id
  vpc_reg                                     = module.avx_spoke.vpc.region
  gw_size                                     = "t3.micro"
  subnet                                      = cidrsubnet(module.avx_spoke.vpc.cidr, 2, 1)
  zone                                        = "${module.avx_spoke.vpc.region}a"
  enable_public_subnet_filtering              = true
  public_subnet_filtering_route_tables        = [data.aws_route_table.avx_spoke_public_1.id, data.aws_route_table.avx_spoke_public_2.id]
  public_subnet_filtering_guard_duty_enforced = true
  single_az_ha                                = true
  enable_encrypt_volume                       = true
  lifecycle {
    ignore_changes = [public_subnet_filtering_route_tables]
  }
}

module "avx_landing_zone" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.5.0"

  cloud                            = "aws"
  name                             = "avx-${var.transit_aws_palo_firenet_region}-landing-zone"
  cidr                             = "10.7.2.0/24"
  region                           = var.transit_aws_palo_firenet_region
  account                          = var.aws_backbone_account_name
  instance_size                    = "t3.micro"
  included_advertised_spoke_routes = "10.99.2.10/32,10.7.2.0/24"
  enable_bgp                       = true
  local_as_number                  = 65106

  transit_gw = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  ha_gw      = false
  attached   = true
}

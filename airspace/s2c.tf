module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                  = "aws-s2c"
  cidr                  = "10.5.0.0/16"
  secondary_cidr_blocks = []

  azs             = ["sa-east-1a", "sa-east-1b"]
  private_subnets = ["10.5.1.0/24", "10.5.2.0/24"]
  public_subnets  = ["10.5.101.0/24", "10.5.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.sa-east-1
  }
}

resource "aws_customer_gateway" "s2c" {
  bgp_asn    = 65106
  ip_address = module.avx_landing_zone.spoke_gateway.eip
  type       = "ipsec.1"

  tags = {
    Name = "aws-s2c"
  }
  provider = aws.sa-east-1
}

resource "aws_vpn_gateway" "s2c" {
  vpc_id          = module.vpc.vpc_id
  amazon_side_asn = 65000

  tags = {
    Name = "aws-s2c"
  }
  provider = aws.sa-east-1
}

resource "aws_vpn_connection" "s2c" {
  vpn_gateway_id        = aws_vpn_gateway.s2c.id
  customer_gateway_id   = aws_customer_gateway.s2c.id
  type                  = "ipsec.1"
  static_routes_only    = false
  tunnel1_inside_cidr   = "169.254.100.0/30"
  tunnel1_preshared_key = var.s2c_shared_secret
  provider              = aws.sa-east-1
}

resource "aws_route" "s2c" {
  for_each               = toset(concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  gateway_id             = aws_vpn_gateway.s2c.id
  provider               = aws.sa-east-1
}

resource "aviatrix_spoke_external_device_conn" "s2c" {
  vpc_id             = module.avx_landing_zone.vpc.vpc_id
  connection_name    = "Sao_Paulo"
  gw_name            = module.avx_landing_zone.spoke_gateway.gw_name
  connection_type    = "bgp"
  bgp_local_as_num   = 65106
  bgp_remote_as_num  = 65000
  remote_gateway_ip  = aws_vpn_connection.s2c.tunnel1_address
  pre_shared_key     = var.s2c_shared_secret
  local_tunnel_cidr  = "169.254.100.2/30"
  remote_tunnel_cidr = "169.254.100.1/30"
}

resource "aviatrix_gateway_snat" "s2c" {
  gw_name   = module.avx_landing_zone.spoke_gateway.gw_name
  snat_mode = "customized_snat"

  snat_policy {
    src_cidr   = "10.5.0.0/16"
    dst_cidr   = "0.0.0.0/0"
    connection = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
    protocol   = "all"
    snat_ips   = "10.99.2.10"
  }
}

resource "aviatrix_gateway_dnat" "s2c" {
  gw_name = module.avx_landing_zone.spoke_gateway.gw_name

  dnat_policy {
    src_cidr   = "10.5.0.0/16"
    dst_cidr   = "10.98.2.10/32"
    dnat_ips   = "10.5.2.10"
    connection = "Sao_Paulo@site2cloud"
  }
}

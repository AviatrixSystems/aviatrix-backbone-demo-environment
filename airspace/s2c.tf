module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                  = "aws-s2c"
  cidr                  = "10.5.2.0/24"
  secondary_cidr_blocks = []

  azs             = ["sa-east-1a", "sa-east-1b"]
  private_subnets = ["10.5.2.0/28", "10.5.2.16/28"]
  public_subnets  = ["10.5.2.32/28", "10.5.2.48/28"]

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
  static_routes_only    = true
  tunnel1_inside_cidr   = "169.254.100.0/30"
  tunnel1_preshared_key = var.s2c_shared_secret
  provider              = aws.sa-east-1
}

resource "aws_vpn_connection_route" "s2c" {
  destination_cidr_block = "10.0.0.0/8"
  vpn_connection_id      = aws_vpn_connection.s2c.id
  provider               = aws.sa-east-1
}

resource "aws_route" "s2c" {
  for_each               = toset(concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  gateway_id             = aws_vpn_gateway.s2c.id
  provider               = aws.sa-east-1
}

resource "aviatrix_site2cloud" "spoke_side" {
  vpc_id                     = module.avx_landing_zone.vpc.vpc_id
  connection_name            = "SaoPaulo"
  connection_type            = "mapped"
  remote_gateway_type        = "avx"
  tunnel_type                = "route"
  ha_enabled                 = false
  enable_active_active       = false
  primary_cloud_gateway_name = module.avx_landing_zone.spoke_gateway.gw_name
  remote_gateway_ip          = aws_vpn_connection.s2c.tunnel1_address
  custom_mapped              = false
  pre_shared_key             = var.s2c_shared_secret
  backup_pre_shared_key      = var.s2c_shared_secret
  forward_traffic_to_transit = true
  remote_subnet_cidr         = "10.5.2.0/24"
  remote_subnet_virtual      = "10.99.2.0/24"
  local_subnet_cidr          = "10.1.2.0/24,10.2.2.0/24,10.3.2.0/24,10.4.2.0/24,10.5.2.0/24,10.6.2.0/24,10.40.251.0/24,10.50.251.0/24"
  local_subnet_virtual       = "10.91.2.0/24,10.92.2.0/24,10.93.2.0/24,10.94.2.0/24,10.95.2.0/24,10.96.2.0/24,10.97.2.0/24,10.98.2.0/24"
}

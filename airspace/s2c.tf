module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "aws-s2c"
  cidr = "172.16.0.0/16"
  secondary_cidr_blocks = [
    "172.17.0.0/16",
    "172.18.0.0/16",
    "172.19.0.0/16",
    "172.20.0.0/16",
  ]

  azs             = ["sa-east-1a", "sa-east-1b"]
  private_subnets = ["172.16.1.0/24", "172.16.2.0/24"]
  public_subnets  = ["172.16.101.0/24", "172.16.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.sa-east-1
  }
}

resource "aws_customer_gateway" "s2c" {
  bgp_asn    = 65101
  ip_address = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.eip
  type       = "ipsec.1"

  tags = {
    Name = "avx-transit"
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

resource "aviatrix_transit_external_device_conn" "s2c" {
  vpc_id             = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].vpc.vpc_id
  connection_name    = "Sao_Paulo"
  gw_name            = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  connection_type    = "bgp"
  bgp_local_as_num   = 65101
  bgp_remote_as_num  = 65000
  remote_gateway_ip  = aws_vpn_connection.s2c.tunnel1_address
  pre_shared_key     = var.s2c_shared_secret
  local_tunnel_cidr  = "169.254.100.2/30"
  remote_tunnel_cidr = "169.254.100.1/30"
}

resource "aws_route" "s2c" {
  for_each               = toset(concat(module.vpc.public_route_table_ids, module.vpc.public_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  gateway_id             = aws_vpn_gateway.s2c.id
  provider               = aws.sa-east-1
}

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

module "vpc_us_east_1_dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-us-east-1-development"
  cidr = "10.8.2.0/24"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.8.2.0/28", "10.8.2.16/28"]
  public_subnets  = ["10.8.2.32/28", "10.8.2.48/28"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.us-east-1
  }
}

module "vpc_us_east_2_dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-us-east-1-application"
  cidr = "10.9.2.0/24"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.9.2.0/28", "10.9.2.16/28"]
  public_subnets  = ["10.9.2.32/28", "10.9.2.48/28"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.us-east-2
  }
}

# aws tgw us-east-1
resource "aws_ec2_transit_gateway" "us_east_1" {
  description                     = "tgw us-east-1"
  amazon_side_asn                 = "64512"
  transit_gateway_cidr_blocks     = ["192.168.101.0/24"]
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  provider                        = aws.us-east-1
  tags = merge(var.common_tags, {
    Name = "tgw-us-east-1"
  })
}

resource "aviatrix_transit_external_device_conn" "tgw_us_east_1" {
  vpc_id             = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].vpc.vpc_id
  connection_name    = "aws-tgw-us-east-1"
  gw_name            = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  connection_type    = "bgp"
  bgp_local_as_num   = "65101"
  bgp_remote_as_num  = "64512"
  remote_gateway_ip  = "192.168.101.1"
  tunnel_protocol    = "GRE"
  local_tunnel_cidr  = "169.254.101.1/29"
  remote_tunnel_cidr = "169.254.101.2/29"
  enable_jumbo_frame = false
}

resource "aviatrix_transit_external_device_conn" "tgw_us_east_1_dev" {
  vpc_id             = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].vpc.vpc_id
  connection_name    = "aws-tgw-us-east-1-dev"
  gw_name            = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  connection_type    = "bgp"
  bgp_local_as_num   = "65101"
  bgp_remote_as_num  = "64512"
  remote_gateway_ip  = "192.168.101.5"
  tunnel_protocol    = "GRE"
  local_tunnel_cidr  = "169.254.101.9/29"
  remote_tunnel_cidr = "169.254.101.10/29"
  enable_jumbo_frame = false
}

resource "aws_ec2_transit_gateway_connect_peer" "vpc_us_east_1_1" {
  peer_address                  = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.private_ip
  inside_cidr_blocks            = ["169.254.101.0/29"]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.vpc_us_east_1.id
  bgp_asn                       = "65101"
  transit_gateway_address       = "192.168.101.1"
  provider                      = aws.us-east-1
}

resource "aws_ec2_transit_gateway_connect_peer" "vpc_us_east_1_1_dev" {
  peer_address                  = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.private_ip
  inside_cidr_blocks            = ["169.254.101.8/29"]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.vpc_us_east_1_dev.id
  bgp_asn                       = "65101"
  transit_gateway_address       = "192.168.101.5"
  provider                      = aws.us-east-1
}

resource "aws_ec2_transit_gateway_connect" "vpc_us_east_1" {
  transport_attachment_id                         = aws_ec2_transit_gateway_vpc_attachment.transit_us_east_1.id
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_1.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-1
}

resource "aws_ec2_transit_gateway_connect" "vpc_us_east_1_dev" {
  transport_attachment_id                         = aws_ec2_transit_gateway_vpc_attachment.transit_us_east_1.id
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_1.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-1
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_us_east_1" {
  subnet_ids                                      = module.vpc_us_east_1.public_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_1.id
  vpc_id                                          = module.vpc_us_east_1.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-1
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_us_east_1" {
  subnet_ids                                      = [module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].vpc.subnets[0].subnet_id, module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].vpc.subnets[2].subnet_id]
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_1.id
  vpc_id                                          = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].vpc.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-1
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_us_east_1_dev" {
  subnet_ids                                      = module.vpc_us_east_1_dev.public_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_1.id
  vpc_id                                          = module.vpc_us_east_1_dev.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table" "us_east_1" {
  transit_gateway_id = aws_ec2_transit_gateway.us_east_1.id
  provider           = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table" "us_east_1_dev" {
  transit_gateway_id = aws_ec2_transit_gateway.us_east_1.id
  provider           = aws.us-east-1
  tags = merge(var.common_tags, {
    Name = "vpc-us-east-1-dev-route-table"
  })
}

resource "aws_ec2_transit_gateway_route_table_association" "us_east_1_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1.id
  provider                       = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table_association" "us_east_1_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.vpc_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1.id
  provider                       = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_1_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1.id
  provider                       = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_1_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.vpc_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1.id
  provider                       = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table_association" "us_east_1_1_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_us_east_1_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1_dev.id
  provider                       = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table_association" "us_east_1_2_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.vpc_us_east_1_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1_dev.id
  provider                       = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_1_1_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_us_east_1_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1_dev.id
  provider                       = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_1_2_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.vpc_us_east_1_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_1_dev.id
  provider                       = aws.us-east-1
}

resource "aws_route" "vpc_tgw_us_east_1" {
  for_each               = toset(module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].vpc.route_tables)
  route_table_id         = each.value
  destination_cidr_block = "192.168.101.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
}

resource "aws_route" "vpc_us_east_1_rfc1918n_10" {
  for_each               = toset(concat(module.vpc_us_east_1.public_route_table_ids, module.vpc_us_east_1.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
}

resource "aws_route" "vpc_us_east_1_rfc1918n_172" {
  for_each               = toset(concat(module.vpc_us_east_1.public_route_table_ids, module.vpc_us_east_1.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
}

resource "aws_route" "vpc_us_east_1_rfc1918n_192" {
  for_each               = toset(concat(module.vpc_us_east_1.public_route_table_ids, module.vpc_us_east_1.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
}

resource "aws_route" "vpc_us_east_1_internet" {
  for_each               = toset(module.vpc_us_east_1.private_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
}
resource "aws_route" "vpc_us_east_1_dev_rfc1918n_10" {
  for_each               = toset(concat(module.vpc_us_east_1_dev.public_route_table_ids, module.vpc_us_east_1_dev.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
  depends_on = [
    module.vpc_us_east_1_dev
  ]
}

resource "aws_route" "vpc_us_east_1_dev_rfc1918n_172" {
  for_each               = toset(concat(module.vpc_us_east_1_dev.public_route_table_ids, module.vpc_us_east_1_dev.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
  depends_on = [
    module.vpc_us_east_1_dev
  ]
}

resource "aws_route" "vpc_us_east_1_dev_rfc1918n_192" {
  for_each               = toset(concat(module.vpc_us_east_1_dev.public_route_table_ids, module.vpc_us_east_1_dev.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
  depends_on = [
    module.vpc_us_east_1_dev
  ]
}

resource "aws_route" "vpc_us_east_1_dev_internet" {
  for_each               = toset(module.vpc_us_east_1_dev.private_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_1.id
  provider               = aws.us-east-1
  depends_on = [
    module.vpc_us_east_1_dev
  ]
}

# us-east-2
resource "aws_ec2_transit_gateway" "us_east_2" {
  description                     = "tgw us-east-2"
  amazon_side_asn                 = "64513"
  transit_gateway_cidr_blocks     = ["192.168.201.0/24"]
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  provider                        = aws.us-east-2
  tags = merge(var.common_tags, {
    Name = "tgw-us-east-2"
  })
}

resource "aviatrix_transit_external_device_conn" "tgw_us_east_2" {
  vpc_id                      = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].vpc.vpc_id
  connection_name             = "aws-tgw-us-east-2"
  gw_name                     = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  connection_type             = "bgp"
  manual_bgp_advertised_cidrs = ["0.0.0.0/0"]
  bgp_local_as_num            = "65105"
  bgp_remote_as_num           = "64513"
  remote_gateway_ip           = "192.168.201.1"
  tunnel_protocol             = "GRE"
  local_tunnel_cidr           = "169.254.101.1/29"
  remote_tunnel_cidr          = "169.254.101.2/29"
  enable_jumbo_frame          = false
}

resource "aviatrix_transit_external_device_conn" "tgw_us_east_2_dev" {
  vpc_id                      = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].vpc.vpc_id
  connection_name             = "aws-tgw-us-east-2-dev"
  gw_name                     = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  connection_type             = "bgp"
  manual_bgp_advertised_cidrs = ["0.0.0.0/0"]
  bgp_local_as_num            = "65105"
  bgp_remote_as_num           = "64513"
  remote_gateway_ip           = "192.168.201.5"
  tunnel_protocol             = "GRE"
  local_tunnel_cidr           = "169.254.101.9/29"
  remote_tunnel_cidr          = "169.254.101.10/29"
  enable_jumbo_frame          = false
}

resource "aws_ec2_transit_gateway_connect_peer" "vpc_us_east_2_1" {
  peer_address                  = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.private_ip
  inside_cidr_blocks            = ["169.254.101.0/29"]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.vpc_us_east_2.id
  bgp_asn                       = "65105"
  transit_gateway_address       = "192.168.201.1"
  provider                      = aws.us-east-2
}

resource "aws_ec2_transit_gateway_connect_peer" "vpc_us_east_2_1_dev" {
  peer_address                  = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].transit_gateway.private_ip
  inside_cidr_blocks            = ["169.254.101.8/29"]
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.vpc_us_east_2_dev.id
  bgp_asn                       = "65105"
  transit_gateway_address       = "192.168.201.5"
  provider                      = aws.us-east-2
}

resource "aws_ec2_transit_gateway_connect" "vpc_us_east_2" {
  transport_attachment_id                         = aws_ec2_transit_gateway_vpc_attachment.transit_us_east_2.id
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_2.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-2
}

resource "aws_ec2_transit_gateway_connect" "vpc_us_east_2_dev" {
  transport_attachment_id                         = aws_ec2_transit_gateway_vpc_attachment.transit_us_east_2.id
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_2.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-2
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_us_east_2" {
  subnet_ids                                      = module.vpc_us_east_2.public_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_2.id
  vpc_id                                          = module.vpc_us_east_2.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-2
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_us_east_2" {
  subnet_ids                                      = [module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].vpc.subnets[0].subnet_id, module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].vpc.subnets[2].subnet_id]
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_2.id
  vpc_id                                          = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].vpc.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-2
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_us_east_2_dev" {
  subnet_ids                                      = module.vpc_us_east_2_dev.public_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.us_east_2.id
  vpc_id                                          = module.vpc_us_east_2_dev.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  provider                                        = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table" "us_east_2" {
  transit_gateway_id = aws_ec2_transit_gateway.us_east_2.id
  provider           = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table" "us_east_2_dev" {
  transit_gateway_id = aws_ec2_transit_gateway.us_east_2.id
  provider           = aws.us-east-2
  tags = merge(var.common_tags, {
    Name = "vpc-us-east-2-dev-route-table"
  })
}

resource "aws_ec2_transit_gateway_route_table_association" "us_east_2_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_us_east_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_2.id
  provider                       = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table_association" "us_east_2_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.vpc_us_east_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_2.id
  provider                       = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_2_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_us_east_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_2.id
  provider                       = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_2_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.vpc_us_east_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_2.id
  provider                       = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table_association" "us_east_2_1_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_us_east_2_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_2_dev.id
  provider                       = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table_association" "us_east_2_2_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.vpc_us_east_2_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_2_dev.id
  provider                       = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_2_1_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_us_east_2_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_2_dev.id
  provider                       = aws.us-east-2
}

resource "aws_ec2_transit_gateway_route_table_propagation" "us_east_2_2_dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.vpc_us_east_2_dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.us_east_2_dev.id
  provider                       = aws.us-east-2
}

resource "aws_route" "vpc_tgw_us_east_2" {
  for_each               = toset(module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}"].vpc.route_tables)
  route_table_id         = each.value
  destination_cidr_block = "192.168.201.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
}

resource "aws_route" "vpc_us_east_2_rfc1918n_10" {
  for_each               = toset(concat(module.vpc_us_east_2.public_route_table_ids, module.vpc_us_east_2.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
}

resource "aws_route" "vpc_us_east_2_rfc1918n_172" {
  for_each               = toset(concat(module.vpc_us_east_2.public_route_table_ids, module.vpc_us_east_2.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
}

resource "aws_route" "vpc_us_east_2_rfc1918n_192" {
  for_each               = toset(concat(module.vpc_us_east_2.public_route_table_ids, module.vpc_us_east_2.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
}

resource "aws_route" "vpc_us_east_2_internet" {
  for_each               = toset(module.vpc_us_east_2.private_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
}

resource "aws_route" "vpc_us_east_2_dev_rfc1918n_10" {
  for_each               = toset(concat(module.vpc_us_east_2_dev.public_route_table_ids, module.vpc_us_east_2_dev.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
  depends_on = [
    module.vpc_us_east_2_dev
  ]
}

resource "aws_route" "vpc_us_east_2_dev_rfc1918n_172" {
  for_each               = toset(concat(module.vpc_us_east_2_dev.public_route_table_ids, module.vpc_us_east_2_dev.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "172.16.0.0/12"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
  depends_on = [
    module.vpc_us_east_2_dev
  ]
}

resource "aws_route" "vpc_us_east_2_dev_rfc1918n_192" {
  for_each               = toset(concat(module.vpc_us_east_2_dev.public_route_table_ids, module.vpc_us_east_2_dev.private_route_table_ids))
  route_table_id         = each.value
  destination_cidr_block = "192.168.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
  depends_on = [
    module.vpc_us_east_2_dev
  ]
}

resource "aws_route" "vpc_us_east_2_dev_internet" {
  for_each               = toset(module.vpc_us_east_2_dev.private_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.us_east_2.id
  provider               = aws.us-east-2
  depends_on = [
    module.vpc_us_east_2_dev
  ]
}

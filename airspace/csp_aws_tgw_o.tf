module "vpc_eu_west_1_qa" {
  source = "terraform-aws-modules/vpc/aws"

  name = "qa-eu-west-1"
  cidr = local.cidrs.aws_eu_west_1_qa

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = [cidrsubnet(local.cidrs.aws_eu_west_1_qa, 4, 0), cidrsubnet(local.cidrs.aws_eu_west_1_qa, 4, 1)]
  public_subnets  = [cidrsubnet(local.cidrs.aws_eu_west_1_qa, 4, 2), cidrsubnet(local.cidrs.aws_eu_west_1_qa, 4, 3)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.eu-west-1
  }
}

module "vpc_eu_west_1_prod" {
  source = "terraform-aws-modules/vpc/aws"

  name = "production-eu-west-1"
  cidr = local.cidrs.aws_eu_west_1_prod

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = [cidrsubnet(local.cidrs.aws_eu_west_1_prod, 4, 0), cidrsubnet(local.cidrs.aws_eu_west_1_prod, 4, 1)]
  public_subnets  = [cidrsubnet(local.cidrs.aws_eu_west_1_prod, 4, 2), cidrsubnet(local.cidrs.aws_eu_west_1_prod, 4, 3)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
  providers = {
    aws = aws.eu-west-1
  }
}

# aviatrix tgw orchestrator eu-west-1
resource "aviatrix_aws_tgw" "eu_west_1" {
  account_name       = var.aws_backbone_account_name
  aws_side_as_number = "64514"
  region             = var.transit_aws_tgwo_region
  tgw_name           = "tgw-eu-west-1"
}

resource "aviatrix_aws_tgw_network_domain" "default_domain" {
  name     = "Default_Domain"
  tgw_name = aviatrix_aws_tgw.eu_west_1.tgw_name
}

resource "aviatrix_aws_tgw_network_domain" "shared_service_domain" {
  name     = "Shared_Service_Domain"
  tgw_name = aviatrix_aws_tgw.eu_west_1.tgw_name
}

resource "aviatrix_aws_tgw_network_domain" "aviatrix_edge_domain" {
  name     = "Aviatrix_Edge_Domain"
  tgw_name = aviatrix_aws_tgw.eu_west_1.tgw_name
}

resource "aviatrix_aws_tgw_network_domain" "aws_eu_west_1_qa_domain" {
  name     = "vpc-eu-west-1-qa-domain"
  tgw_name = aviatrix_aws_tgw.eu_west_1.tgw_name
}

resource "aviatrix_aws_tgw_network_domain" "aws_eu_west_1_prod_domain" {
  name     = "vpc-eu-west-1-prod-domain"
  tgw_name = aviatrix_aws_tgw.eu_west_1.tgw_name
}

resource "aviatrix_aws_tgw_transit_gateway_attachment" "eu_west_1_transit" {
  tgw_name             = aviatrix_aws_tgw.eu_west_1.tgw_name
  region               = var.transit_aws_tgwo_region
  vpc_account_name     = var.aws_backbone_account_name
  vpc_id               = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_tgwo_region), "/[ -]/", "_")}"].vpc.vpc_id
  transit_gateway_name = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_tgwo_region), "/[ -]/", "_")}"].transit_gateway.gw_name
}

# resource "aviatrix_aws_tgw_vpc_attachment" "eu_west_1_qa_vpc" {
#   tgw_name            = aviatrix_aws_tgw.eu_west_1.tgw_name
#   region              = var.transit_aws_tgwo_region
#   network_domain_name = aviatrix_aws_tgw_network_domain.default_domain.name
#   vpc_account_name    = var.aws_backbone_account_name
#   vpc_id              = module.vpc_eu_west_1_qa.vpc_id
# }

# resource "aviatrix_aws_tgw_vpc_attachment" "eu_west_1_prod_vpc" {
#   tgw_name            = aviatrix_aws_tgw.eu_west_1.tgw_name
#   region              = var.transit_aws_tgwo_region
#   network_domain_name = aviatrix_aws_tgw_network_domain.default_domain.name
#   vpc_account_name    = var.aws_backbone_account_name
#   vpc_id              = module.vpc_eu_west_1_prod.vpc_id
# }

# resource "aviatrix_aws_tgw_peering_domain_conn" "eu_west_1_edge_default" {
#   tgw_name1    = aviatrix_aws_tgw.eu_west_1.tgw_name
#   domain_name1 = aviatrix_aws_tgw_network_domain.default_domain.name
#   tgw_name2    = aviatrix_aws_tgw.eu_west_1.tgw_name
#   domain_name2 = aviatrix_aws_tgw_network_domain.aviatrix_edge_domain.name
# }

resource "aviatrix_aws_tgw_vpc_attachment" "eu_west_1_qa_vpc" {
  tgw_name            = aviatrix_aws_tgw.eu_west_1.tgw_name
  region              = var.transit_aws_tgwo_region
  network_domain_name = aviatrix_aws_tgw_network_domain.aws_eu_west_1_qa_domain.name
  vpc_account_name    = var.aws_backbone_account_name
  vpc_id              = module.vpc_eu_west_1_qa.vpc_id
}

resource "aviatrix_aws_tgw_vpc_attachment" "eu_west_1_prod_vpc" {
  tgw_name            = aviatrix_aws_tgw.eu_west_1.tgw_name
  region              = var.transit_aws_tgwo_region
  network_domain_name = aviatrix_aws_tgw_network_domain.aws_eu_west_1_prod_domain.name
  vpc_account_name    = var.aws_backbone_account_name
  vpc_id              = module.vpc_eu_west_1_prod.vpc_id
}

resource "aviatrix_aws_tgw_peering_domain_conn" "eu_west_1_edge_qa" {
  tgw_name1    = aviatrix_aws_tgw.eu_west_1.tgw_name
  domain_name1 = aviatrix_aws_tgw_network_domain.aws_eu_west_1_qa_domain.name
  tgw_name2    = aviatrix_aws_tgw.eu_west_1.tgw_name
  domain_name2 = aviatrix_aws_tgw_network_domain.aviatrix_edge_domain.name
}

resource "aviatrix_aws_tgw_peering_domain_conn" "eu_west_1_edge_prod" {
  tgw_name1    = aviatrix_aws_tgw.eu_west_1.tgw_name
  domain_name1 = aviatrix_aws_tgw_network_domain.aws_eu_west_1_prod_domain.name
  tgw_name2    = aviatrix_aws_tgw.eu_west_1.tgw_name
  domain_name2 = aviatrix_aws_tgw_network_domain.aviatrix_edge_domain.name
}

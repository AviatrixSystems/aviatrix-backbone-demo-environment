# aws
module "aws_us_east_1_workload" {
  source               = "./mc-instance"
  vpc_id               = module.vpc_us_east_1.vpc_id
  subnet_id            = module.vpc_us_east_1.private_subnets[0]
  cloud                = "aws"
  traffic_gen          = local.traffic_gen.aws_us_east_1
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  common_tags = merge(var.common_tags, {
    Environment = "Production"
  })
  workload_template_path = var.workload_template_path
  workload_password      = var.workload_instance_password
  providers = {
    aws = aws.us-east-1
  }
}

module "aws_us_east_2_workload" {
  source               = "./mc-instance"
  vpc_id               = module.vpc_us_east_2.vpc_id
  subnet_id            = module.vpc_us_east_2.private_subnets[0]
  cloud                = "aws"
  traffic_gen          = local.traffic_gen.aws_us_east_2
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  common_tags = merge(var.common_tags, {
    Environment = "Production"
  })
  workload_template_path = var.workload_template_path
  workload_password      = var.workload_instance_password
  providers = {
    aws = aws.us-east-2
  }
}

# azure
module "azure_workload" {
  source                 = "./mc-instance"
  resource_group         = azurerm_resource_group.vnet_germany_west_central.name
  subnet_id              = module.vnet_germany_west_central.vnet_subnets[0]
  location               = var.transit_azure_region
  cloud                  = "azure"
  traffic_gen            = local.traffic_gen.azure
  common_tags            = merge(var.common_tags, {})
  workload_template_path = var.workload_template_path
  workload_password      = var.workload_instance_password
}

# gcp
module "gcp_us_west1_workload" {
  source                 = "./mc-instance"
  vpc_id                 = google_compute_network.vpc.name
  subnet_id              = google_compute_subnetwork.vpc.name
  cloud                  = "gcp"
  region                 = var.transit_gcp_region
  traffic_gen            = local.traffic_gen.gcp
  common_tags            = merge(var.common_tags, {})
  workload_template_path = var.workload_template_path
  workload_password      = var.workload_instance_password
}

# oci
module "oci_workload" {
  source                 = "./mc-instance"
  oci_compartment_ocid   = var.oci_backbone_compartment_ocid
  subnet_id              = oci_core_subnet.spoke_public.id
  cloud                  = "oci"
  traffic_gen            = local.traffic_gen.oci
  common_tags            = merge(var.common_tags, {})
  workload_template_path = var.workload_template_path
  workload_password      = var.workload_instance_password
}


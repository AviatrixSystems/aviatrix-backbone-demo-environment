module "aws" {
  for_each               = var.cloud == "aws" ? { instance = true } : {}
  source                 = "./aws"
  common_tags            = var.common_tags
  subnet_id              = var.subnet_id
  traffic_gen            = var.traffic_gen
  vpc_id                 = var.vpc_id
  workload_template_path = var.workload_template_path
  workload_template      = var.workload_template
  workload_password      = var.workload_password
  iam_instance_profile   = var.iam_instance_profile
  image                  = var.image
}

module "azure" {
  for_each               = var.cloud == "azure" ? { instance = true } : {}
  source                 = "./azure"
  common_tags            = var.common_tags
  subnet_id              = var.subnet_id
  traffic_gen            = var.traffic_gen
  location               = var.location
  resource_group         = var.resource_group
  workload_template_path = var.workload_template_path
  workload_template      = var.workload_template
  workload_password      = var.workload_password
  image                  = var.image
}

module "gcp" {
  for_each               = var.cloud == "gcp" ? { instance = true } : {}
  source                 = "./gcp"
  common_tags            = var.common_tags
  subnet_id              = var.subnet_id
  traffic_gen            = var.traffic_gen
  vpc_id                 = var.vpc_id
  region                 = var.region
  workload_template_path = var.workload_template_path
  workload_template      = var.workload_template
  workload_password      = var.workload_password
  image                  = var.image
}

module "oci" {
  for_each               = var.cloud == "oci" ? { instance = true } : {}
  source                 = "./oci"
  common_tags            = var.common_tags
  oci_compartment_ocid   = var.oci_compartment_ocid
  subnet_id              = var.subnet_id
  traffic_gen            = var.traffic_gen
  workload_template_path = var.workload_template_path
  workload_template      = var.workload_template
  workload_password      = var.workload_password
  image                  = var.image
}

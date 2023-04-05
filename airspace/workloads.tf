# aws
module "aws_sao_paulo_workload" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_sao_paulo.name
  private_ip           = local.traffic_gen.aws_sao_paulo.private_ip
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.private_subnets[0]
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "Production"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_sa_east_1.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_sao_paulo.name
      apps     = join(",", local.traffic_gen.aws_sao_paulo.apps)
      external = join(",", local.traffic_gen.aws_sao_paulo.external)
      interval = local.traffic_gen.aws_sao_paulo.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.sa-east-1
  }
}

module "aws_us_east_1_workload" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_us_east_1.name
  private_ip           = local.traffic_gen.aws_us_east_1.private_ip
  vpc_id               = module.vpc_us_east_1.vpc_id
  subnet_id            = module.vpc_us_east_1.private_subnets[0]
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "Production"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_us_east_1.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_us_east_1.name
      apps     = join(",", local.traffic_gen.aws_us_east_1.apps)
      external = join(",", local.traffic_gen.aws_us_east_1.external)
      interval = local.traffic_gen.aws_us_east_1.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.us-east-1
  }
}

module "aws_us_east_1_dev" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_us_east_1_dev.name
  private_ip           = local.traffic_gen.aws_us_east_1_dev.private_ip
  vpc_id               = module.vpc_us_east_1_dev.vpc_id
  subnet_id            = module.vpc_us_east_1_dev.private_subnets[0]
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "Development"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_us_east_1.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_us_east_1_dev.name
      apps     = join(",", local.traffic_gen.aws_us_east_1_dev.apps)
      external = join(",", local.traffic_gen.aws_us_east_1_dev.external)
      interval = local.traffic_gen.aws_us_east_1_dev.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.us-east-1
  }
}

module "aws_us_east_2_dev" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_us_east_2_dev.name
  private_ip           = local.traffic_gen.aws_us_east_2_dev.private_ip
  vpc_id               = module.vpc_us_east_2_dev.vpc_id
  subnet_id            = module.vpc_us_east_2_dev.private_subnets[0]
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "Development"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_us_east_2.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_us_east_2_dev.name
      apps     = join(",", local.traffic_gen.aws_us_east_2_dev.apps)
      external = join(",", local.traffic_gen.aws_us_east_2_dev.external)
      interval = local.traffic_gen.aws_us_east_2_dev.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.us-east-2
  }
}

module "aws_landing_zone_workload" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_landing_zone.name
  private_ip           = local.traffic_gen.aws_landing_zone.private_ip
  vpc_id               = module.avx_landing_zone.vpc.vpc_id
  subnet_id            = module.avx_landing_zone.vpc.private_subnets[0].subnet_id
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "Production"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_us_east_1.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_landing_zone.name
      apps     = join(",", local.traffic_gen.aws_landing_zone.apps)
      external = join(",", local.traffic_gen.aws_landing_zone.external)
      interval = local.traffic_gen.aws_landing_zone.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.us-east-1
  }
}

module "aws_us_east_2_workload" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_us_east_2.name
  private_ip           = local.traffic_gen.aws_us_east_2.private_ip
  vpc_id               = module.vpc_us_east_2.vpc_id
  subnet_id            = module.vpc_us_east_2.private_subnets[0]
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "Production"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_us_east_2.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_us_east_2.name
      apps     = join(",", local.traffic_gen.aws_us_east_2.apps)
      external = join(",", local.traffic_gen.aws_us_east_2.external)
      interval = local.traffic_gen.aws_us_east_2.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.us-east-2
  }
}

module "aws_us_east_2_avx_workload" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_us_east_2_avx.name
  private_ip           = local.traffic_gen.aws_us_east_2_avx.private_ip
  vpc_id               = module.avx_spoke.vpc.vpc_id
  subnet_id            = module.avx_spoke.vpc.private_subnets[0].subnet_id
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "Production"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_us_east_2.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_us_east_2_avx.name
      apps     = join(",", local.traffic_gen.aws_us_east_2_avx.apps)
      external = join(",", local.traffic_gen.aws_us_east_2_avx.external)
      interval = local.traffic_gen.aws_us_east_2_avx.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.us-east-2
  }
}

module "aws_eu_west_1_qa" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_eu_west_1_qa.name
  private_ip           = local.traffic_gen.aws_eu_west_1_qa.private_ip
  vpc_id               = module.vpc_eu_west_1_qa.vpc_id
  subnet_id            = module.vpc_eu_west_1_qa.private_subnets[0]
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "QA"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_eu_west_1.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_eu_west_1_qa.name
      apps     = join(",", local.traffic_gen.aws_eu_west_1_qa.apps)
      external = join(",", local.traffic_gen.aws_eu_west_1_qa.external)
      interval = local.traffic_gen.aws_eu_west_1_qa.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.eu-west-1
  }
}

module "aws_eu_west_1_prod" {
  source               = "./mc-instance"
  name                 = local.traffic_gen.aws_eu_west_1_prod.name
  private_ip           = local.traffic_gen.aws_eu_west_1_prod.private_ip
  vpc_id               = module.vpc_eu_west_1_prod.vpc_id
  subnet_id            = module.vpc_eu_west_1_prod.private_subnets[0]
  cloud                = "aws"
  iam_instance_profile = aws_iam_instance_profile.accounting_ec2_role_for_ssm.name
  public_key           = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : null
  common_tags = merge(var.common_tags, {
    Environment = "Production"
  })
  password = var.workload_instance_password
  image    = data.aws_ami.fs_packer_eu_west_1.id

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.aws_eu_west_1_prod.name
      apps     = join(",", local.traffic_gen.aws_eu_west_1_prod.apps)
      external = join(",", local.traffic_gen.aws_eu_west_1_prod.external)
      interval = local.traffic_gen.aws_eu_west_1_prod.interval
      password = var.workload_instance_password
  })
  providers = {
    aws = aws.eu-west-1
  }
}

# azure
module "azure_workload" {
  source         = "./mc-instance"
  cloud          = "azure"
  name           = local.traffic_gen.azure.name
  private_ip     = local.traffic_gen.azure.private_ip
  image          = data.azurerm_shared_image.fs_packer.id
  subnet_id      = module.vnet_germany_west_central.vnet_subnets[0]
  resource_group = azurerm_resource_group.vnet_germany_west_central.name
  location       = var.transit_azure_region
  password       = var.workload_instance_password
  common_tags    = merge(var.common_tags, {})

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.azure.name
      apps     = join(",", local.traffic_gen.azure.apps)
      external = join(",", local.traffic_gen.azure.external)
      interval = local.traffic_gen.azure.interval
      password = var.workload_instance_password
  })

  depends_on = [
    module.multicloud_transit
  ]
}

# gcp
module "gcp_us_west1_workload" {
  source      = "./mc-instance"
  name        = local.traffic_gen.gcp.name
  private_ip  = local.traffic_gen.gcp.private_ip
  vpc_id      = google_compute_network.vpc.name
  subnet_id   = google_compute_subnetwork.vpc.name
  cloud       = "gcp"
  region      = var.transit_gcp_region
  common_tags = merge(var.common_tags, {})
  password    = var.workload_instance_password
  image       = data.google_compute_image.fs_packer.self_link

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.gcp.name
      apps     = join(",", local.traffic_gen.gcp.apps)
      external = join(",", local.traffic_gen.gcp.external)
      interval = local.traffic_gen.gcp.interval
      password = var.workload_instance_password
  })
}

# oci
module "oci_workload" {
  source               = "./mc-instance"
  oci_compartment_ocid = var.oci_backbone_compartment_ocid
  oci_vcn_ocid         = oci_core_vcn.spoke.id
  name                 = local.traffic_gen.oci.name
  private_ip           = local.traffic_gen.oci.private_ip
  subnet_id            = oci_core_subnet.spoke_private.id
  cloud                = "oci"
  common_tags          = merge(var.common_tags, {})
  password             = var.workload_instance_password
  image                = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaou6afe7uzl4lqcgy7yhcign5m6qgr5ocvkhszikouq2epbh76yra" # fs image

  user_data_templatefile = templatefile("${var.workload_template_path}/traffic_gen.tpl",
    {
      name     = local.traffic_gen.oci.name
      apps     = join(",", local.traffic_gen.oci.apps)
      external = join(",", local.traffic_gen.oci.external)
      interval = local.traffic_gen.oci.interval
      password = var.workload_instance_password
  })
}

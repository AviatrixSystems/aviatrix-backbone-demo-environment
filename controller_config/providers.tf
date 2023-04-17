provider "aviatrix" {
  username                = local.tfvars.ctrl_username
  password                = local.tfvars.ctrl_password
  controller_ip           = local.tfvars.ctrl_fqdn
  skip_version_validation = local.tfvars.skip_version_validation
}

provider "aws" {
  profile = "demo_backbone"
}

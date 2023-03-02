provider "aviatrix" {
  username                = var.ctrl_username
  password                = var.ctrl_password
  controller_ip           = var.ctrl_fqdn
  skip_version_validation = var.skip_version_validation
}

provider "aws" {
  profile = "demo_backbone"
}

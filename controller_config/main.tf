data "terraform_remote_state" "controller" {
  backend = "s3"
  config = {
    bucket  = "backbone.aviatrixtest.com"
    key     = "controller.tfstate"
    region  = "us-west-2"
    profile = "demo_backbone"
  }
}

# Copilot service account
resource "aviatrix_account_user" "copilot_svc" {
  username = "copilot_svc"
  email    = var.account_email
  password = var.cplt_svc_password
}

resource "aviatrix_rbac_group" "all_write" {
  group_name = "all_write"
}

resource "aviatrix_rbac_group_permission_attachment" "all_write" {
  group_name      = aviatrix_rbac_group.all_write.group_name
  permission_name = "all_write"
}

resource "aviatrix_rbac_group_user_attachment" "copilot_svc" {
  group_name = aviatrix_rbac_group.all_write.group_name
  user_name  = aviatrix_account_user.copilot_svc.username
}

# RBAC
resource "aviatrix_rbac_group" "network" {
  group_name = "networking"
}

resource "aviatrix_rbac_group" "security" {
  group_name = "security"
}

resource "aviatrix_rbac_group" "ops" {
  group_name = "operations"
}

resource "aviatrix_rbac_group" "employees_all" {
  group_name = "Employees-ALL"
}

resource "aviatrix_rbac_group" "aviatrix_demo_controller_admins" {
  group_name = "Aviatrix Demo Controller Admins"
}

resource "aviatrix_rbac_group" "aviatrix_demo_controller_guests" {
  group_name = "Aviatrix Demo Controller Guests"
}

resource "aviatrix_rbac_group_permission_attachment" "aviatrix_demo_controller_admins" {
  group_name      = aviatrix_rbac_group.aviatrix_demo_controller_admins.group_name
  permission_name = "all_write"
}

resource "aviatrix_rbac_group_permission_attachment" "network" {
  group_name      = aviatrix_rbac_group.network.group_name
  permission_name = "all_write"
}

resource "aviatrix_rbac_group_permission_attachment" "security" {
  group_name      = aviatrix_rbac_group.security.group_name
  permission_name = "all_security_write"
}

resource "aviatrix_rbac_group_permission_attachment" "ops" {
  group_name      = aviatrix_rbac_group.ops.group_name
  permission_name = "all_dashboard_write"
}

resource "aviatrix_account_user" "network" {
  username = "network-user"
  email    = var.account_email
  password = var.ctrl_password
}

resource "aviatrix_rbac_group_user_attachment" "network" {
  group_name = aviatrix_rbac_group.network.group_name
  user_name  = aviatrix_account_user.network.username
}

resource "aviatrix_account_user" "ops" {
  username = "operations-user"
  email    = var.account_email
  password = var.ctrl_password
}

resource "aviatrix_rbac_group_user_attachment" "ops" {
  group_name = aviatrix_rbac_group.ops.group_name
  user_name  = aviatrix_account_user.ops.username
}

resource "aviatrix_account_user" "security" {
  username = "security-user"
  email    = var.account_email
  password = var.ctrl_password
}

resource "aviatrix_rbac_group_user_attachment" "security" {
  group_name = aviatrix_rbac_group.security.group_name
  user_name  = aviatrix_account_user.security.username
}

resource "aviatrix_account_user" "read_only" {
  username = "read-only-user"
  email    = var.account_email
  password = var.ctrl_password
}

resource "aviatrix_rbac_group_user_attachment" "read_only" {
  group_name = "read_only"
  user_name  = aviatrix_account_user.read_only.username
}

# Copilot logging
resource "aviatrix_remote_syslog" "copilot" {
  name     = "copilot"
  server   = data.terraform_remote_state.controller.outputs.copilot_public_ip
  port     = 5000
  index    = 9
  protocol = "UDP"
}

resource "aviatrix_netflow_agent" "copilot" {
  server_ip      = data.terraform_remote_state.controller.outputs.copilot_public_ip
  port           = 31283
  version        = "9"
  enable_l7_mode = true
}

# Copilot association
resource "aviatrix_copilot_association" "copilot" {
  copilot_address = "cplt.backbone.aviatrixtest.com"
}

# WAF rules interfere with the aviatrix_saml_endpoint apply
resource "aviatrix_saml_endpoint" "aviatrix_saml_sso" {
  endpoint_name                = "aviatrix_saml_sso"
  idp_metadata_type            = "URL"
  idp_metadata_url             = var.idp_metadata_url
  controller_login             = true
  access_set_by                = "profile_attribute"
  custom_saml_request_template = templatefile("${path.module}/saml_request.tpl", {})
  lifecycle {
    ignore_changes = [
      custom_saml_request_template
    ]
  }
}

# Controller label is not exposed in terraform
data "http" "ctrl_auth" {
  provider             = http-full
  url                  = "https://${var.ctrl_fqdn}/v2/api"
  method               = "POST"
  insecure_skip_verify = false
  request_headers = {
    content-type = "application/json"
  }
  request_body = jsonencode({
    username = "admin",
    password = var.ctrl_password,
    action   = "login"
  })
}

data "http" "ctrl_label" {
  provider             = http-full
  url                  = "https://${var.ctrl_fqdn}/v1/api"
  method               = "POST"
  insecure_skip_verify = false
  request_headers = {
    content-type = "application/x-www-form-urlencoded"
  }
  request_body = "action=set_controller_name&controller_name=${var.controller_label}&CID=${jsondecode(data.http.ctrl_auth.response_body).CID}"
}

resource "aviatrix_account" "backbone_azure" {
  account_name        = var.azure_backbone_account_name
  cloud_type          = 8
  arm_subscription_id = var.azure_backbone_subscription_id
  arm_directory_id    = var.azure_directory_id
  arm_application_id  = var.azure_application_id
  arm_application_key = var.azure_application_key
}

resource "aviatrix_account" "backbone_gcp" {
  account_name                        = var.gcp_backbone_account_name
  cloud_type                          = 4
  gcloud_project_id                   = var.gcp_backbone_project_id
  gcloud_project_credentials_filepath = var.gcp_credentials_filepath
}


resource "aviatrix_account" "backbone_oci" {
  account_name                 = var.oci_backbone_account_name
  cloud_type                   = 16
  oci_tenancy_id               = var.oci_tenant_ocid
  oci_user_id                  = var.oci_user_ocid
  oci_compartment_id           = var.oci_backbone_compartment_ocid
  oci_api_private_key_filepath = var.oci_key_filepath
}

resource "aviatrix_distributed_firewalling_config" "demo" {
  enable_distributed_firewalling = true
}

data "aws_vpc" "controller" {
  filter {
    name   = "tag:Name"
    values = ["controller_vpc"]
  }
}

data "aws_instance" "copilot" {
  filter {
    name   = "tag:Name"
    values = ["AviatrixCopilot"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

resource "aviatrix_copilot_security_group_management_config" "demo" {
  enable_copilot_security_group_management = true
  cloud_type                               = 1
  account_name                             = "backbone-aws"
  region                                   = "us-west-2"
  vpc_id                                   = data.aws_vpc.controller.id
  instance_id                              = data.aws_instance.copilot.id
}

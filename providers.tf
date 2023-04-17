provider "aviatrix" {
  username                = local.tfvars.ctrl_username
  password                = local.tfvars.ctrl_password
  controller_ip           = local.tfvars.ctrl_fqdn
  skip_version_validation = local.tfvars.skip_version_validation
}

provider "aws" {
  profile = "demo_backbone"
}

provider "aws" {
  alias   = "sa-east-1"
  profile = "demo_backbone"
  region  = "sa-east-1"
}

provider "aws" {
  alias   = "us-east-1"
  profile = "demo_backbone"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "us-east-2"
  profile = "demo_backbone"
  region  = "us-east-2"
}

provider "aws" {
  alias   = "eu-west-1"
  profile = "demo_backbone"
  region  = "eu-west-1"
}

provider "aws" {
  alias   = "dns"
  profile = "demo_operations"
}

provider "google" {
  credentials = local.tfvars.gcp_credentials_filepath
  project     = local.tfvars.gcp_backbone_project_id
  region      = var.transit_gcp_region
}

provider "azurerm" {
  features {}
  subscription_id = local.tfvars.azure_backbone_subscription_id
  client_id       = local.tfvars.azure_application_id
  client_secret   = local.tfvars.azure_application_key
  tenant_id       = local.tfvars.azure_directory_id
}

provider "azurerm" {
  alias = "shared-images"
  features {}
  subscription_id = local.tfvars.azure_shared_images_subscription_id
  client_id       = local.tfvars.azure_application_id
  client_secret   = local.tfvars.azure_application_key
  tenant_id       = local.tfvars.azure_directory_id
}

provider "oci" {
  region              = var.transit_oci_region
  tenancy_ocid        = local.tfvars.oci_tenant_ocid
  auth                = "APIKey"
  config_file_profile = "avxlabs"
}

provider "aviatrix" {
  username                = var.ctrl_username
  password                = var.ctrl_password
  controller_ip           = var.ctrl_fqdn
  skip_version_validation = var.skip_version_validation
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
  alias   = "dns"
  profile = "demo_operations"
}

provider "google" {
  credentials = var.gcp_credentials_filepath
  project     = var.gcp_backbone_project_id
  region      = var.transit_gcp_region
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_backbone_subscription_id
  client_id       = var.azure_application_id
  client_secret   = var.azure_application_key
  tenant_id       = var.azure_directory_id
}

provider "azurerm" {
  alias = "shared-images"
  features {}
  subscription_id = var.azure_shared_images_subscription_id
  client_id       = var.azure_application_id
  client_secret   = var.azure_application_key
  tenant_id       = var.azure_directory_id
}

provider "oci" {
  region              = var.transit_oci_region
  tenancy_ocid        = var.oci_tenant_ocid
  auth                = "APIKey"
  config_file_profile = "avxlabs"
}

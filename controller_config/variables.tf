variable "ctrl_username" {
  description = "Aviatrix controller username"
}

variable "ctrl_password" {
  description = "Aviatrix controller admim password"
}

variable "ctrl_fqdn" {
  description = "Aviatrix controller fqdn"
}

variable "skip_version_validation" {
  description = "Aviatrix controller skip version validation"
}

variable "cplt_svc_password" {
  description = "Aviatrix copilot service account password"
}

variable "account_email" {
  description = "Email address to associate with the controller users - admin and copilot service account"
}

variable "aws_backbone_account_number" {
  description = "Access account number for the backbone aws account"
}

variable "azure_backbone_account_name" {
  description = "Azure access account name"
}

variable "azure_backbone_subscription_id" {
  description = "Access account subscription id"
}

variable "azure_directory_id" {
  description = "Access account directory id"
}

variable "azure_application_id" {
  description = "Access account application id"
}

variable "azure_application_key" {
  description = "Access account application key"
}

variable "gcp_backbone_account_name" {
  description = "Gcp access account name"
}

variable "gcp_backbone_project_id" {
  description = "Access account project id"
}

variable "gcp_credentials_filepath" {
  description = "Access account credentials filepath"
}

variable "oci_backbone_account_name" {
  description = "Oci access account name"
}

variable "oci_tenant_ocid" {
  description = "Access account tenant ocid"
}

variable "oci_user_ocid" {
  description = "Access account user ocid"
}

variable "oci_backbone_compartment_ocid" {
  description = "Access account compartment ocid"
}

variable "oci_key_filepath" {
  description = "Access account key filepath"
}

variable "controller_label" {
  description = "Text to display in the controller banner"
  default     = "Aviatrix Backbone Controller"
}

variable "idp_metadata_url" {
  description = "Aviatrix controller sso idp metadata url"
}

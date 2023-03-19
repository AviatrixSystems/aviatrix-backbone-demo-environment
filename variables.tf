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

variable "azure_backbone_subscription_id" {
  description = "Access account subscription id for the azure account"
}

variable "azure_shared_images_subscription_id" {
  description = "Access account subscription id for the custom shared images azure account"
}

variable "azure_directory_id" {
  description = "Access account directory id for azure accounts"
}

variable "azure_application_id" {
  description = "Access account application id for azure accounts"
}

variable "azure_application_key" {
  description = "Access account application key for azure accounts"
}

variable "gcp_backbone_project_id" {
  description = "Access account project id for the gcp account"
}

variable "gcp_credentials_filepath" {
  description = "Access account credentials filepath for gcp accounts"
}

variable "oci_tenant_ocid" {
  description = "Access account tenant ocid for oci accounts"
}

variable "oci_user_ocid" {
  description = "Access account user ocid for oci accounts"
}

variable "oci_backbone_compartment_ocid" {
  description = "Access account compartment ocid for the oci account for the operations department"
}

variable "oci_key_filepath" {
  description = "Access account key filepath for oci accounts"
}

variable "oci_shared_secret" {
  description = "Shared secret or oci ipsec tunnels"
}

variable "gcp_shared_secret" {
  description = "Shared secret or gcp ipsec tunnels"
}

variable "s2c_shared_secret" {
  description = "Shared secret or s2c ipsec tunnels"
}

variable "workload_template_path" {
  description = "Path to the workload templates"
}

variable "palo_bootstrap_path" {
  description = "Path to the palo bootstrap files"
}

variable "palo_bucket_name" {
  description = "S3 bucket for the palo bootstrap files. Must be globally unique"
}

variable "palo_admin_password" {
  description = "Palo alto console admin password"
}

variable "public_key" {
  description = "SSH public key to apply to all deployed instances"
}

variable "private_key_full_path" {
  description = "SSH private key to be used to connect to all deployed instances"
}

variable "workload_instance_password" {
  description = "Password for the workload instances"
}

variable "transit_aws_palo_firenet_region" {
  description = "Aws transit region with palo alto firenet"
  default     = "us-east-1"
}

variable "transit_aws_egress_fqdn_region" {
  description = "Aws transit region with avx egress fqdn"
  default     = "us-east-2"
}

variable "transit_azure_region" {
  description = "Azure transit region"
  default     = "Germany West Central"
}

variable "transit_gcp_region" {
  description = "Gcp transit region"
  default     = "us-west1"
}

variable "edge_dc_gcp_region" {
  description = "Gcp edge region"
  default     = "us-east4"
}

variable "edge_sv_gcp_region" {
  description = "Gcp edge region"
  default     = "us-west2"
}

variable "transit_oci_region" {
  description = "Oci transit region"
  default     = "ap-singapore-1"
}

variable "common_tags" {
  description = "Optional tags to be applied to all resources"
  default     = {}
}

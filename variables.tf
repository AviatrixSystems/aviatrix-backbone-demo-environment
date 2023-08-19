data "aws_secretsmanager_secret_version" "tfvars" {
  secret_id = "demo/backbone/tfvars"
}

locals {
  tfvars = jsondecode(
    data.aws_secretsmanager_secret_version.tfvars.secret_string
  )
}

variable "transit_aws_palo_firenet_region" {
  description = "Aws transit region with palo alto firenet"
  default     = "us-east-1"
}

variable "transit_aws_egress_fqdn_region" {
  description = "Aws transit region with avx egress fqdn"
  default     = "us-east-2"
}

variable "transit_aws_tgwo_region" {
  description = "Aws transit region with avx tgw orchestration"
  default     = "eu-west-1"
}

variable "transit_azure_region" {
  description = "Azure transit region"
  default     = "North Europe"
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

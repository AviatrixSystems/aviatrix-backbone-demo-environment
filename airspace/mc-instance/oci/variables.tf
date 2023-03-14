variable "common_tags" {}
variable "oci_compartment_ocid" {}
variable "subnet_id" {}
variable "traffic_gen" {}
variable "workload_password" {}
variable "workload_template_path" {}
variable "workload_template" {}

locals {
  common_tags = {
    for key, value in var.common_tags :
    key => value if key != "Terraform"
  }
}

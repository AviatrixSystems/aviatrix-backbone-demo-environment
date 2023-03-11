variable "cloud" {}
variable "common_tags" {}
variable "location" { default = "" }
variable "oci_compartment_ocid" { default = "" }
variable "region" { default = "" }
variable "resource_group" { default = "" }
variable "subnet_id" {}
variable "traffic_gen" {}
variable "vpc_id" { default = "" }
variable "workload_password" {}
variable "iam_instance_profile" { default = "" }
variable "workload_template_path" {
  description = "Path to the workload templates"
}

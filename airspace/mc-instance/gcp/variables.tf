variable "common_tags" {}
variable "region" { default = "" }
variable "subnet_id" {}
variable "traffic_gen" {}
variable "vpc_id" {}
variable "workload_password" {}
variable "workload_template_path" {}
variable "workload_template" {}
variable "image" { default = null }

locals {
  lower_common_tags = {
    for key, value in var.common_tags :
    lower(key) => replace(lower(value), "/[ /]/", "_")
  }
}

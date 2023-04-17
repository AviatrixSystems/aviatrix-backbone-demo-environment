data "aws_secretsmanager_secret_version" "tfvars" {
  secret_id = "demo/backbone/tfvars"
}

locals {
  tfvars = jsondecode(
    data.aws_secretsmanager_secret_version.tfvars.secret_string
  )
}

variable "aws_region" {
  description = "AWS region for the controller and copilot deployment"
  default     = "us-west-2"
}

variable "controller_instance_type" {
  description = "AWS instance size for controller"
  default     = "t3.2xlarge"
}

variable "copilot_instance_type" {
  description = "AWS instance size for  copilot"
  default     = "t3.2xlarge"
}

variable "vpc_cidr" {
  default = "172.64.0.0/16"
}

variable "subnet_cidr" {
  default = "172.64.1.0/24"
}

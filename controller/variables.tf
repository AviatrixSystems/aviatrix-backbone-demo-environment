variable "ctrl_password" {
  description = "Aviatrix controller admim password"
}

variable "ctrl_customer_id" {
  description = "Aviatrix controller customer id"
}

variable "account_email" {
  description = "Email address to associate with the controller users - admin and copilot service account"
}

variable "ctrl_version" {
  description = "Aviatrix controller version"
}

variable "public_key" {
  description = "SSH key to apply to all deployed instances"
}

variable "aws_account_name" {
  description = "Access Account Name for the AWS Account where the controller and copilot are deployed"
  default     = "aws-operations"
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

variable "common_tags" {
  description = "Optional tags to be applied to all resources"
  default     = {}
}

locals {
  public_key = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : var.public_key
}

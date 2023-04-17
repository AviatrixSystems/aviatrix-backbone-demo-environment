data "aws_secretsmanager_secret_version" "tfvars" {
  secret_id = "demo/backbone/tfvars"
}

locals {
  tfvars = jsondecode(
    data.aws_secretsmanager_secret_version.tfvars.secret_string
  )
}

variable "controller_label" {
  description = "Text to display in the controller banner"
  default     = "Aviatrix Backbone Controller"
}

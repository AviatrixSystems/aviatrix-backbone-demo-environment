terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.43.0"
    }
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.54.0"
      configuration_aliases = [aws.sa-east-1, aws.us-east-1, aws.us-east-2]
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.52.0"
    }
    oci = {
      source  = "hashicorp/oci"
      version = "~> 4.107.0"
    }
  }
  required_version = ">= 1.2.0"
}

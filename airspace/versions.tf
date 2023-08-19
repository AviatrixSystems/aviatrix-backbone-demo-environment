terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.1.0"
    }
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.43.0"
      configuration_aliases = [azurerm.shared-images]
    }
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0.0"
      configuration_aliases = [aws.sa-east-1, aws.us-east-1, aws.us-east-2, aws.eu-west-1]
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.52.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 4.110.0"
    }
  }
  required_version = ">= 1.2.0"
}

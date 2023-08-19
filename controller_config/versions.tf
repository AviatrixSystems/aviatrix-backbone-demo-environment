terraform {
  backend "s3" {
    bucket  = "backbone.aviatrixtest.com"
    key     = "controller-config.tfstate"
    region  = "us-west-2"
    profile = "demo_backbone"
  }

  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 3.1.1"
    }
    http-full = {
      source  = "salrashid123/http-full"
      version = "~> 1.3.1"
    }
  }
  required_version = ">= 1.2.0"
}

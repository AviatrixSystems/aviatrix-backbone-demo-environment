provider "aws" {
  region  = var.aws_region
  profile = "demo_backbone"
}

provider "aws" {
  alias   = "dns"
  region  = var.aws_region
  profile = "demo_operations"
}

data "aws_ami" "fs_packer_eu_west_1" {
  most_recent = true
  filter {
    name   = "name"
    values = ["avxfs-v2-ami-*"]
  }
  owners   = ["240152784131"] # Aviatrix - pod1
  provider = aws.eu-west-1
}

data "aws_ami" "fs_packer_us_east_1" {
  most_recent = true
  filter {
    name   = "name"
    values = ["avxfs-v2-ami-*"]
  }
  owners   = ["240152784131"] # Aviatrix - pod1
  provider = aws.us-east-1
}

data "aws_ami" "fs_packer_us_east_2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["avxfs-v2-ami-*"]
  }
  owners   = ["240152784131"] # Aviatrix - pod1
  provider = aws.us-east-2
}

data "aws_ami" "fs_packer_sa_east_1" {
  most_recent = true
  filter {
    name   = "name"
    values = ["avxfs-v2-ami-*"]
  }
  owners   = ["240152784131"] # Aviatrix - pod1
  provider = aws.sa-east-1
}

data "azurerm_shared_image" "fs_packer" {
  name                = "avxfs-v2-ami"
  gallery_name        = "infra_avx_labs"
  resource_group_name = "shared-images"
  provider            = azurerm.shared-images
}

data "google_compute_image" "fs_packer" {
  family  = "avxfs-v2-ami"
  project = "aviatrix-lab1"
}

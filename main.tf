# Deploy the aviatrix demo airspace
module "backbone" {
  source                          = "./airspace"
  aws_backbone_account_name       = "backbone-aws"
  azure_backbone_account_name     = "backbone-azure"
  gcp_backbone_account_name       = "backbone-gcp"
  oci_backbone_account_name       = "backbone-oci"
  palo_bootstrap_path             = "./palo_bootstrap"
  workload_template_path          = "./templates"
  edge_sv_gcp_region              = var.edge_sv_gcp_region
  edge_dc_gcp_region              = var.edge_dc_gcp_region
  gcp_shared_secret               = var.gcp_shared_secret
  oci_backbone_compartment_ocid   = var.oci_backbone_compartment_ocid
  oci_shared_secret               = var.oci_shared_secret
  palo_admin_password             = var.palo_admin_password
  palo_admin_username             = var.ctrl_username
  palo_bucket_name                = var.palo_bucket_name
  public_key                      = var.public_key
  private_key_full_path           = var.private_key_full_path
  s2c_shared_secret               = var.s2c_shared_secret
  transit_aws_egress_fqdn_region  = var.transit_aws_egress_fqdn_region
  transit_aws_palo_firenet_region = var.transit_aws_palo_firenet_region
  transit_azure_region            = var.transit_azure_region
  transit_gcp_region              = var.transit_gcp_region
  transit_oci_region              = var.transit_oci_region
  workload_instance_password      = var.workload_instance_password
  common_tags                     = var.common_tags
  providers = {
    aws.sa-east-1 = aws.sa-east-1
    aws.us-east-1 = aws.us-east-1
    aws.us-east-2 = aws.us-east-2
  }
}

# Add friendly dns for the palo alto console
data "aws_route53_zone" "backbone" {
  name         = "backbone.aviatrixtest.com"
  private_zone = false
  provider     = aws.dns
}

resource "aws_route53_record" "palo" {
  zone_id  = data.aws_route53_zone.backbone.zone_id
  name     = "palo.${data.aws_route53_zone.backbone.name}"
  type     = "A"
  ttl      = "1"
  records  = [module.backbone.palo_public_ip]
  provider = aws.dns
}

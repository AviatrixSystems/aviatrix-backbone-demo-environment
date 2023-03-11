# https://registry.terraform.io/modules/terraform-aviatrix-modules/backbone/aviatrix/latest
module "multicloud_transit" {
  source          = "terraform-aviatrix-modules/backbone/aviatrix"
  version         = "v1.1.1"
  transit_firenet = local.transit_firenet
}

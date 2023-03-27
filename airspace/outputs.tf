output "palo_public_ip" {
  description = "The public ip for the palo alto firewall console"
  value       = module.multicloud_transit.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].public_ip
}

output "backbone" {
  description = "All details for the backbone gateways and networks"
  value       = module.multicloud_transit.transit
}

output "workload_private_ips" {
  description = "Private IPs for workload instances"
  value = {
    aws_us_east_2_avx = local.traffic_gen.aws_us_east_2_avx.private_ip
    aws_us_east_2     = local.traffic_gen.aws_us_east_2.private_ip
    aws_us_east_1     = local.traffic_gen.aws_us_east_1.private_ip
    azure             = local.traffic_gen.azure.private_ip
    oci               = local.traffic_gen.oci.private_ip
    gcp               = local.traffic_gen.gcp.private_ip
    aws_landing_zone  = local.traffic_gen.aws_landing_zone.private_ip
  }
}

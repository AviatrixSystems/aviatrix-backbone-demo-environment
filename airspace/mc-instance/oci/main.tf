data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${var.workload_template_path}/${var.workload_template}",
      {
        name     = var.traffic_gen.name
        apps     = join(",", var.traffic_gen.apps)
        external = join(",", var.traffic_gen.external)
        sap      = join(",", var.traffic_gen.sap)
        interval = var.traffic_gen.interval
        password = var.workload_password
    })
  }
}

data "oci_core_images" "ubuntu_22_04" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "Canonical-Ubuntu-22.04-2023.02.15-0"
}

module "this" {
  source                      = "oracle-terraform-modules/compute-instance/oci"
  version                     = "2.4.1"
  instance_count              = 1 # how many instances do you want?
  ad_number                   = 1 # AD number to provision instances. If null, instances are provisionned in a rolling manner starting with AD1
  compartment_ocid            = var.oci_compartment_ocid
  instance_display_name       = var.traffic_gen.name
  source_ocid                 = data.oci_core_images.ubuntu_22_04.images.0.id
  subnet_ocids                = [var.subnet_id]
  public_ip                   = "NONE"
  private_ips                 = [var.traffic_gen.private_ip]
  ssh_public_keys             = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/avxlabs.pub")}" : null
  block_storage_sizes_in_gbs  = [50]
  instance_flex_memory_in_gbs = 1
  shape                       = "VM.Standard.E3.Flex"
  instance_state              = "RUNNING"
  boot_volume_backup_policy   = "disabled"
  extended_metadata = {
    user_data = data.cloudinit_config.this.rendered
  }
  freeform_tags = merge(local.common_tags, {
    Name = var.traffic_gen.name
  })
}

locals {
  public_key = fileexists("~/.ssh/id_rsa.pub") ? "${file("~/.ssh/id_rsa.pub")}" : var.public_key

  network_domains = ["Aws", "Aws_dev", "Aws_qa_tgwo", "Aws_prod_tgwo", "Landing_zone", "Edge", "Azure", "Gcp", "Oci"]
  transit_firenet = {
    ("aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}") = {
      transit_name                                 = "backbone-aws-${var.transit_aws_palo_firenet_region}"
      transit_cloud                                = "aws"
      transit_cidr                                 = "10.1.0.0/23"
      transit_region_name                          = var.transit_aws_palo_firenet_region
      transit_asn                                  = 65101
      transit_instance_size                        = "c5.xlarge"
      firenet                                      = true
      transit_hybrid_connection                    = true
      firenet_firewall_image                       = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
      firenet_bootstrap_bucket_name_1              = aws_s3_bucket.palo.id
      firenet_iam_role_1                           = aws_iam_role.palo.name
      firenet_inspection_enabled                   = true
      firenet_keep_alive_via_lan_interface_enabled = true
      firenet_egress_enabled                       = true
    },
    ("azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}") = {
      transit_name                     = "backbone-azure-${replace(lower(var.transit_azure_region), "/[ ]/", "-")}"
      transit_cloud                    = "azure"
      transit_cidr                     = "10.2.0.0/23"
      transit_region_name              = var.transit_azure_region
      transit_asn                      = 65102
      transit_instance_size            = "Standard_B1ms"
      transit_enable_bgp_over_lan      = true
      transit_bgp_lan_interfaces_count = 1
    },
    ("oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}") = {
      transit_name          = "backbone-oci-${var.transit_oci_region}"
      transit_cloud         = "oci"
      transit_cidr          = "10.3.0.0/23"
      transit_region_name   = var.transit_oci_region
      transit_asn           = 65103
      transit_instance_size = "VM.Standard2.2"
      transit_bgp_ecmp      = true
    },
    ("gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}") = {
      transit_name                = "backbone-gcp-${var.transit_gcp_region}"
      transit_cloud               = "gcp"
      transit_cidr                = "10.4.0.0/23"
      transit_region_name         = var.transit_gcp_region
      transit_asn                 = 65104
      transit_instance_size       = "n1-standard-1"
      transit_enable_bgp_over_lan = true
      transit_bgp_lan_interfaces = [
        {
          vpc_id = google_compute_network.hub.name,
          subnet = google_compute_subnetwork.hub.ip_cidr_range
        }
      ]
    },
    ("aws_${replace(lower(var.transit_aws_egress_fqdn_region), "/[ -]/", "_")}") = {
      transit_name              = "backbone-aws-${var.transit_aws_egress_fqdn_region}"
      transit_cloud             = "aws"
      transit_cidr              = "10.5.0.0/23"
      transit_region_name       = var.transit_aws_egress_fqdn_region
      transit_asn               = 65105
      transit_instance_size     = "c5.xlarge"
      firenet                   = true
      firenet_firewall_image    = "Aviatrix FQDN Egress Filtering"
      firenet_single_ip_snat    = true
      transit_hybrid_connection = true
    },
    ("aws_${replace(lower(var.transit_aws_tgwo_region), "/[ -]/", "_")}") = {
      transit_name              = "backbone-aws-${var.transit_aws_tgwo_region}"
      transit_cloud             = "aws"
      transit_cidr              = "10.10.0.0/23"
      transit_region_name       = var.transit_aws_tgwo_region
      transit_asn               = 65110
      transit_instance_size     = "t3.small"
      transit_hybrid_connection = true
      firenet                   = false
    },
  }

  egress_rules = {
    tcp = {
      "*.amazonaws.com"    = "443"
      "*.amazonaws.com"    = "80"
      "aviatrix.com"       = "443"
      "*.aviatrix.com"     = "443"
      "*.amazon.com"       = "443"
      "*.amazon.com"       = "80"
      "stackoverflow.com"  = "443"
      "go.dev"             = "443"
      "*.terraform.io"     = "443"
      "*.microsoft.com"    = "443"
      "*.google.com"       = "443"
      "*.oracle.com"       = "443"
      "*.alibabacloud.com" = "443"
      "*.docker.com"       = "443"
      "*.snapcraft.io"     = "443"
      "*.ubuntu.com"       = "443"
      "*.ubuntu.com"       = "80"
    }
    udp = {
      "dns.google.com" = "53"
    }
  }

  external = [
    "aws.amazon.com",
    "stackoverflow.com",
    "go.dev",
    "www.terraform.io",
    "www.wikipedia.org",
    "azure.microsoft.com",
    "cloud.google.com",
    "www.oracle.com/cloud",
    "us.alibabacloud.com",
    "aviatrix.com",
    "www.reddit.com",
    "www.torproject.org"
  ]

  workload_ips = [
    cidrhost(local.cidrs.aws_us_east_1, 10),
    cidrhost(local.cidrs.azure_north_europe, 10),
    cidrhost(local.cidrs.oci_singapore_1, 20),
    cidrhost(local.cidrs.gcp_west1, 10),
    cidrhost(local.cidrs.aws_us_east_2, 10),
    cidrhost(local.cidrs.avx_us_east_2, 10),
    cidrhost(local.cidrs.aws_us_east_1_landing, 10),
    cidrhost(local.cidrs.aws_us_east_1_dev, 10),
    cidrhost(local.cidrs.aws_us_east_2_dev, 10),
    cidrhost(local.cidrs.aws_eu_west_1_qa, 10),
    cidrhost(local.cidrs.aws_eu_west_1_prod, 10),
    "10.40.251.29",
    "10.50.251.29",
    "10.99.2.10"
  ]

  cidrs = {
    aws_us_east_1         = "10.1.2.0/24"
    azure_north_europe    = "10.2.2.0/24"
    oci_singapore_1       = "10.3.2.0/24"
    gcp_west1             = "10.4.2.0/24"
    aws_us_east_2         = "10.5.2.0/24"
    avx_us_east_2         = "10.6.2.0/24"
    aws_us_east_1_landing = "10.7.2.0/24"
    aws_us_east_1_dev     = "10.8.2.0/24"
    aws_us_east_2_dev     = "10.9.2.0/24"
    aws_eu_west_1_qa      = "10.10.2.0/24"
    aws_eu_west_1_prod    = "10.11.2.0/24"
  }

  traffic_gen = {
    aws_sao_paulo = {
      private_ip = cidrhost(local.cidrs.aws_us_east_2, 10)
      name       = "aws-sau-paulo-workload"
      apps = [
        "10.91.2.10",
        "10.92.2.10",
        "10.93.2.20",
        "10.94.2.10",
        "10.95.2.10",
        "10.96.2.10",
        "10.97.251.29",
        "10.98.251.29"
      ]
      external = []
      interval = "15"
    }
    aws_us_east_1 = {
      private_ip = cidrhost(local.cidrs.aws_us_east_1, 10)
      name       = "aws-us-east-1-shared"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.aws_us_east_1, 10)])
      external   = local.external
      interval   = "10"
    }
    azure = {
      private_ip = cidrhost(local.cidrs.azure_north_europe, 10)
      name       = "azure-workload"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.azure_north_europe, 10)])
      external   = local.external
      interval   = "15"
    }
    oci = {
      private_ip = cidrhost(local.cidrs.oci_singapore_1, 20)
      name       = "oci-workload"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.oci_singapore_1, 20)])
      external   = local.external
      interval   = "10"
    }
    gcp = {
      private_ip = cidrhost(local.cidrs.gcp_west1, 10)
      name       = "gcp-workload"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.gcp_west1, 10)])
      external   = local.external
      interval   = "5"
    }
    aws_us_east_2 = {
      private_ip = cidrhost(local.cidrs.aws_us_east_2, 10)
      name       = "aws-us-east-2-shared"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.aws_us_east_2, 10)])
      external   = local.external
      interval   = "5"
    }
    aws_us_east_2_avx = {
      private_ip = cidrhost(local.cidrs.avx_us_east_2, 10)
      name       = "avx-spoke-workload"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.avx_us_east_2, 10)])
      external   = local.external
      interval   = "5"
    }
    aws_landing_zone = {
      private_ip = cidrhost(local.cidrs.aws_us_east_1_landing, 10)
      name       = "aws-landing-zone-workload"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.aws_us_east_1_landing, 10)])
      external   = local.external
      interval   = "15"
    }
    aws_us_east_1_dev = {
      private_ip = cidrhost(local.cidrs.aws_us_east_1_dev, 10)
      name       = "aws-us-east-1-dev"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.aws_us_east_1_dev, 10)])
      external   = local.external
      interval   = "20"
    }
    aws_us_east_2_dev = {
      private_ip = cidrhost(local.cidrs.aws_us_east_2_dev, 10)
      name       = "aws-us-east-2-dev"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.aws_us_east_2_dev, 10)])
      external   = local.external
      interval   = "20"
    }
    aws_eu_west_1_qa = {
      private_ip = cidrhost(local.cidrs.aws_eu_west_1_qa, 10)
      name       = "aws-eu-west-1-qa"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.aws_eu_west_1_qa, 10)])
      external   = local.external
      interval   = "10"
    }
    aws_eu_west_1_prod = {
      private_ip = cidrhost(local.cidrs.aws_eu_west_1_prod, 10)
      name       = "aws-eu-west-1-prod"
      apps       = setsubtract(local.workload_ips, [cidrhost(local.cidrs.aws_eu_west_1_prod, 10)])
      external   = local.external
      interval   = "5"
    }
    edge_sv = {
      name     = "edge-sv-workload"
      apps     = setsubtract(local.workload_ips, ["10.40.251.29"])
      external = local.external
      interval = "10"
    }
    edge_dc = {
      name     = "edge-dc-workload"
      apps     = setsubtract(local.workload_ips, ["10.50.251.29"])
      external = local.external
      interval = "15"
    }
  }
}

variable "aws_backbone_account_name" {
  description = "Aws access account name for the operations department"
}

variable "azure_backbone_account_name" {
  description = "Azure access account name for the marketing department"
}

variable "gcp_backbone_account_name" {
  description = "Gcp access account name for the enterprise data department"
}

variable "oci_backbone_account_name" {
  description = "Oci access account name for the operations department"
}

variable "oci_shared_secret" {
  description = "Shared secret or oci ipsec tunnels"
}

variable "gcp_shared_secret" {
  description = "Shared secret or gcp ipsec tunnels"
}

variable "s2c_shared_secret" {
  description = "Shared secret or s2c ipsec tunnels"
}

variable "workload_template_path" {
  description = "Path to the workload templates"
}

variable "palo_bootstrap_path" {
  description = "Path to the palo bootstrap files"
}

variable "palo_bucket_name" {
  description = "S3 bucket for the palo bootstrap files. Must be globally unique"
}

variable "palo_admin_username" {
  description = "Palo alto console admin username"
}

variable "palo_admin_password" {
  description = "Palo alto console admin password"
}

variable "workload_instance_password" {
  description = "Password for the workload instances"
}

variable "transit_aws_palo_firenet_region" {
  description = "Aws transit region with palo alto firenet"
  default     = "us-east-1"
}

variable "transit_aws_egress_fqdn_region" {
  description = "Aws transit region with avx egress fqdn"
  default     = "us-east-2"
}

variable "transit_aws_tgwo_region" {
  description = "Aws transit region with avx tgw orchestration"
  default     = "eu-west-1"
}

variable "transit_azure_region" {
  description = "Azure transit region"
  default     = "North Europe"
}

variable "transit_gcp_region" {
  description = "Gcp transit region"
  default     = "us-west1"
}

variable "edge_dc_gcp_region" {
  description = "Gcp edge region"
  default     = "us-east4"
}

variable "edge_sv_gcp_region" {
  description = "Gcp edge region"
  default     = "us-west2"
}

variable "edge_prefix" {
  description = "Edge gateway prefix"
  default     = "datacenter"
}

variable "transit_oci_region" {
  description = "Oci transit region"
  default     = "ap-singapore-1"
}

variable "public_key" {
  description = "SSH public key to apply to all deployed instances"
}

variable "private_key_full_path" {
  description = "SSH private key to be used to connect to all deployed instances"
}

variable "oci_backbone_compartment_ocid" {
  description = "Access account compartment ocid for the oci account for the operations department"
}

variable "common_tags" {
  description = "Optional tags to be applied to all resources"
  default     = {}
}

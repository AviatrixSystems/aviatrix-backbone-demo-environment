data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "this" {
  name         = var.traffic_gen.name
  machine_type = "f1-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.subnet_id
    network_ip = var.traffic_gen.private_ip
    # enable for instance troubleshooting
    # access_config {
    #   // Ephemeral public IP
    # }
  }

  metadata_startup_script = templatefile("${var.workload_template_path}/${var.workload_template}", {
    name     = var.traffic_gen.name
    apps     = join(",", var.traffic_gen.apps)
    external = join(",", var.traffic_gen.external)
    sap      = join(",", var.traffic_gen.sap)
    interval = var.traffic_gen.interval
    password = var.workload_password
  })

  labels = merge(local.lower_common_tags, {
    name = var.traffic_gen.name
  })

  tags = ["workload"]
  metadata = {
    ssh-keys = fileexists("~/.ssh/id_rsa.pub") ? "ubuntu:${file("~/.ssh/id_rsa.pub")}" : null
  }
}

data "http" "myip" {
  url = "http://ifconfig.me"
}

resource "google_compute_firewall" "this_ingress" {
  name    = "${var.traffic_gen.name}-ingress"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "30013", "30015", "30017", "30030", "30032", "30041"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["${chomp(data.http.myip.response_body)}/32", "10.0.0.0/8", "172.16.0.0/16"]
  target_tags   = ["workload"]
}

resource "google_compute_firewall" "this_egress" {
  name      = "${var.traffic_gen.name}-egress"
  network   = var.vpc_id
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["workload"]
}

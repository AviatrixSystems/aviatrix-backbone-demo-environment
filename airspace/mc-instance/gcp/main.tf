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
  }

  metadata_startup_script = templatefile("${var.workload_template_path}/nginx_listener.tpl", {
    name     = var.traffic_gen.name
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

  source_ranges = ["10.0.0.0/8", "172.16.0.0/16"]
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

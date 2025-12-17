# -------------------------
# VPC A
# -------------------------
resource "google_compute_network" "vpc_a" {
  name                            = "vpc-a"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnet_a" {
  name          = "subnet-a"
  region        = var.region
  network       = google_compute_network.vpc_a.id
  ip_cidr_range = "192.168.10.0/24"
}

# -------------------------
# VPC B
# -------------------------
resource "google_compute_network" "vpc_b" {
  name                            = "vpc-b"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = "subnet-b"
  region        = var.region
  network       = google_compute_network.vpc_b.id
  ip_cidr_range = "192.168.20.0/24"
}

# -------------------------
# Firewall: SSH จากเครื่องคุณเข้า VMs
# -------------------------
resource "google_compute_firewall" "vpc_a_ssh" {
  name    = "fw-vpc-a-ssh"
  network = google_compute_network.vpc_a.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["vm-a"]
}

resource "google_compute_firewall" "vpc_b_ssh" {
  name    = "fw-vpc-b-ssh"
  network = google_compute_network.vpc_b.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["vm-b"]
}

# -------------------------
# VMs
# -------------------------
resource "google_compute_instance" "vm_a" {
  name         = "vm-a"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["vm-a"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_a.id
    access_config {}
  }
}

resource "google_compute_instance" "vm_b" {
  name         = "vm-b"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["vm-b"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_b.id
    access_config {}
  }
}

# -------------------------
# VPC Network Peering (สองทิศทาง)
# -------------------------
resource "google_compute_network_peering" "a_to_b" {
  name         = "peer-a-to-b"
  network      = google_compute_network.vpc_a.id
  peer_network = google_compute_network.vpc_b.id
}

resource "google_compute_network_peering" "b_to_a" {
  name         = "peer-b-to-a"
  network      = google_compute_network.vpc_b.id
  peer_network = google_compute_network.vpc_a.id
}

# -------------------------
# Firewall ข้าม VPC
# -------------------------
resource "google_compute_firewall" "vpc_a_allow_from_b" {
  name    = "fw-vpc-a-allow-from-b"
  network = google_compute_network.vpc_a.name
  direction = "INGRESS"

  allow { protocol = "icmp" }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["192.168.20.0/24"]
  target_tags   = ["vm-a"]
}

resource "google_compute_firewall" "vpc_b_allow_from_a" {
  name    = "fw-vpc-b-allow-from-a"
  network = google_compute_network.vpc_b.name
  direction = "INGRESS"

  allow { protocol = "icmp" }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["192.168.10.0/24"]
  target_tags   = ["vm-b"]
}

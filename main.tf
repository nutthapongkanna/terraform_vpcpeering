############################################
# main.tf
# เป้าหมาย:
# 1) สร้าง VPC 2 อัน (vpc-a, vpc-b) แบบ custom mode
# 2) สร้าง subnet คนละวง (CIDR ไม่ชนกัน)
# 3) สร้าง VM 2 ตัวคนละ VPC
# 4) เปิด SSH จากเครื่องคุณเข้าหา VM ได้ (ผ่าน source_ranges)
# 5) ทำ VPC Peering 2 ทิศทาง (A<->B)
# 6) เปิด ICMP + SSH ข้าม VPC (ให้ vm-a คุย vm-b ได้)
############################################

# -------------------------
# VPC A
# -------------------------
resource "google_compute_network" "vpc_a" {
  # ชื่อ VPC ที่จะเห็นใน GCP Console
  name = var.vpc_a_name

  # false = custom mode (เรากำหนด subnet เอง)
  auto_create_subnetworks = false

  # true = ลบ default routes (0.0.0.0/0 internet route) ตอนสร้าง VPC
  # ผลลัพธ์:
  # - VM ใน VPC นี้ “ยังมี external IP ได้” แต่ routing default อาจไม่ออก internet
  # - ถ้าต้อง apt-get/yum update, curl ออกเน็ต อาจต้องสร้าง route/NAT เพิ่ม
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "subnet_a" {
  # ชื่อ subnet
  name   = var.subnet_a_name
  region = var.region

  # ผูก subnet นี้เข้ากับ VPC A
  network = google_compute_network.vpc_a.id

  # CIDR ของ VPC A (ต้องไม่ชนกับ subnet ฝั่ง B)
  ip_cidr_range = var.subnet_a_cidr
}

# -------------------------
# VPC B
# -------------------------
resource "google_compute_network" "vpc_b" {
  name                            = var.vpc_b_name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = var.subnet_b_name
  region        = var.region
  network       = google_compute_network.vpc_b.id
  ip_cidr_range = var.subnet_b_cidr
}

# -------------------------
# Firewall: SSH จากเครื่องคุณเข้า VMs (Inbound)
# -------------------------
# แนวคิด:
# - Firewall ใน GCP เป็น rule ระดับ VPC
# - เราต้องกำหนด:
#   - direction INGRESS = traffic เข้า VM
#   - allow tcp:22
#   - source_ranges = IP/วงที่อนุญาต (เช่น public IP บ้าน/บริษัท)
#   - target_tags = ให้กระทบเฉพาะ VM ที่มี tag นั้นๆ (ลด blast radius)
resource "google_compute_firewall" "vpc_a_ssh" {
  name      = var.fw_vpc_a_ssh_name
  network   = google_compute_network.vpc_a.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [tostring(var.ssh_port)]
  }

  # อนุญาตเฉพาะ IP/วงที่กำหนด (แนะนำให้ใส่ /32 ของ public IP ตัวเอง)
  source_ranges = var.ssh_source_ranges

  # ยิงเข้าได้เฉพาะ VM ที่มี tag ตรงนี้
  target_tags = [var.vm_a_tag]
}

resource "google_compute_firewall" "vpc_b_ssh" {
  name      = var.fw_vpc_b_ssh_name
  network   = google_compute_network.vpc_b.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [tostring(var.ssh_port)]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = [var.vm_b_tag]
}

# -------------------------
# VMs
# -------------------------
resource "google_compute_instance" "vm_a" {
  name         = var.vm_a_name
  machine_type = var.machine_type
  zone         = var.zone

  # tags ใช้ผูกกับ firewall rule target_tags
  tags = [var.vm_a_tag]

  boot_disk {
    initialize_params {
      # image เช่น debian / ubuntu
      image = var.image

      # ขนาด disk (GB)
      size = var.boot_disk_size_gb

      # ประเภท disk: pd-balanced / pd-ssd / pd-standard
      type = var.boot_disk_type
    }
  }

  network_interface {
    # ต่อเข้า subnet A
    subnetwork = google_compute_subnetwork.subnet_a.id

    # ใส่ access_config = มี External IP (Public NAT)
    # ถ้าไม่อยากให้ VM มี public IP -> ตั้ง var.vm_a_enable_public_ip = false
    dynamic "access_config" {
      for_each = var.vm_a_enable_public_ip ? [1] : []
      content {}
    }
  }
}

resource "google_compute_instance" "vm_b" {
  name         = var.vm_b_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = [var.vm_b_tag]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_b.id

    dynamic "access_config" {
      for_each = var.vm_b_enable_public_ip ? [1] : []
      content {}
    }
  }
}

# -------------------------
# VPC Network Peering (สองทิศทาง)
# -------------------------
# แนวคิด:
# - Peering ต้องมี 2 ด้านเสมอ:
#   - A -> B
#   - B -> A
# - Peering จะทำให้ route ภายใน “รู้จักกัน” ระหว่าง 2 VPC
# - แต่ “Firewall ยังบล็อกอยู่” ถ้าไม่ allow
resource "google_compute_network_peering" "a_to_b" {
  name         = var.peering_a_to_b_name
  network      = google_compute_network.vpc_a.id
  peer_network = google_compute_network.vpc_b.id
}

resource "google_compute_network_peering" "b_to_a" {
  name         = var.peering_b_to_a_name
  network      = google_compute_network.vpc_b.id
  peer_network = google_compute_network.vpc_a.id
}

# -------------------------
# Firewall ข้าม VPC (หลัง peering)
# -------------------------
# แนวคิด:
# - หลัง peering แล้ว traffic ข้าม VPC “ไปถึงกันได้ในเชิง route”
# - แต่ต้องเปิด firewall ให้ผ่านด้วย
# - source_ranges = CIDR ฝั่งตรงข้าม
# - target_tags = ยิงเฉพาะ VM ที่ต้องการ (vm-a / vm-b)
resource "google_compute_firewall" "vpc_a_allow_from_b" {
  name      = var.fw_vpc_a_allow_from_b_name
  network   = google_compute_network.vpc_a.name
  direction = "INGRESS"

  # ICMP = ping
  allow { protocol = "icmp" }

  # SSH ข้าม VPC (ให้ vm-b ssh เข้า vm-a ได้)
  allow {
    protocol = "tcp"
    ports    = [tostring(var.ssh_port)]
  }

  source_ranges = [var.subnet_b_cidr]
  target_tags   = [var.vm_a_tag]
}

resource "google_compute_firewall" "vpc_b_allow_from_a" {
  name      = var.fw_vpc_b_allow_from_a_name
  network   = google_compute_network.vpc_b.name
  direction = "INGRESS"

  allow { protocol = "icmp" }

  allow {
    protocol = "tcp"
    ports    = [tostring(var.ssh_port)]
  }

  source_ranges = [var.subnet_a_cidr]
  target_tags   = [var.vm_b_tag]
}

############################################
# terraform.tfvars
############################################


# Location
project_id = ""
region = "asia-southeast1"
zone   = "asia-southeast1-b"

# VPC A
vpc_a_name    = "vpc-a"
subnet_a_name = "subnet-a"
subnet_a_cidr = "192.168.10.0/24"

# VPC B
vpc_b_name    = "vpc-b"
subnet_b_name = "subnet-b"
subnet_b_cidr = "192.168.20.0/24"

# Behavior: ลบ default route ตอนสร้าง VPC (true/false)
delete_default_routes_on_create = true

# VM config
machine_type = "e2-medium"
image        = "debian-cloud/debian-12"

boot_disk_size_gb = 20
boot_disk_type    = "pd-balanced"

vm_a_name = "vm-a"
vm_b_name = "vm-b"

vm_a_tag = "vm-a"
vm_b_tag = "vm-b"

# Public IP (ถ้าอยากให้เข้าจาก internet ได้ ตั้ง true)
vm_a_enable_public_ip = true
vm_b_enable_public_ip = true

# SSH allowlist: ใส่ public IP ตัวเองแบบ /32 จะปลอดภัยสุด
# ตัวอย่าง: ["203.0.113.10/32"]
ssh_source_ranges = ["0.0.0.0/0"]

ssh_port = 22

# Firewall rule names
fw_vpc_a_ssh_name          = "fw-vpc-a-ssh"
fw_vpc_b_ssh_name          = "fw-vpc-b-ssh"
fw_vpc_a_allow_from_b_name = "fw-vpc-a-allow-from-b"
fw_vpc_b_allow_from_a_name = "fw-vpc-b-allow-from-a"

# Peering names
peering_a_to_b_name = "peer-a-to-b"
peering_b_to_a_name = "peer-b-to-a"

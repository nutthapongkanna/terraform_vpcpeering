############################################
# variables.tf
############################################
# ใช้ใน provider "google" เพื่อบอกว่า Terraform จะไปสร้าง resource ในโปรเจกต์ไหน
# หมายเหตุ: ต้องเป็น "Project ID" ไม่ใช่ "Project Name"
variable "project_id" {
  type        = string
  description = "GCP Project ID (e.g. tlnk-infra-tor)"
}
variable "region" { type = string }
variable "zone"   { type = string }

# VPC/Subnet names + CIDR
variable "vpc_a_name"     { type = string }
variable "subnet_a_name"  { type = string }
variable "subnet_a_cidr"  { type = string }

variable "vpc_b_name"     { type = string }
variable "subnet_b_name"  { type = string }
variable "subnet_b_cidr"  { type = string }

# default route behavior
variable "delete_default_routes_on_create" {
  type    = bool
  default = true
}

# VM settings
variable "machine_type" { type = string }
variable "image"        { type = string }

variable "boot_disk_size_gb" {
  type    = number
  default = 20
}

variable "boot_disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "vm_a_name" { type = string }
variable "vm_b_name" { type = string }

variable "vm_a_tag" { type = string }
variable "vm_b_tag" { type = string }

# enable/disable public IP per VM
variable "vm_a_enable_public_ip" {
  type    = bool
  default = true
}
variable "vm_b_enable_public_ip" {
  type    = bool
  default = true
}

# SSH control
variable "ssh_port" {
  type    = number
  default = 22
}

variable "ssh_source_ranges" {
  # เช่น ["1.2.3.4/32"] หรือ ["0.0.0.0/0"] (ไม่แนะนำ)
  type = list(string)
}

# Names for firewall rules
variable "fw_vpc_a_ssh_name"               { type = string }
variable "fw_vpc_b_ssh_name"               { type = string }
variable "fw_vpc_a_allow_from_b_name"      { type = string }
variable "fw_vpc_b_allow_from_a_name"      { type = string }

# Peering names
variable "peering_a_to_b_name" { type = string }
variable "peering_b_to_a_name" { type = string }

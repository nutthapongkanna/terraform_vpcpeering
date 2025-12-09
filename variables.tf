variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  type        = string
  default     = "asia-southeast1-a"
}

variable "ssh_source_ranges" {
  type        = list(string)
  description = "Your public IP CIDR for SSH into VMs"
  # แนะนำให้ใส่ IP จริงของคุณ เช่น ["1.2.3.4/32"]
  default     = ["0.0.0.0/0"]
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "image" {
  type    = string
  default = "debian-cloud/debian-12"
}

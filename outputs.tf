############################################
# outputs.tf
# - Output คือ “ค่าที่ Terraform แสดงหลัง apply เสร็จ”
# - ใช้เพื่อเอาไปอ้างต่อ (เช่น copy ไป ssh, ping, หรือใช้ใน module อื่น)
############################################

# -----------------------------
# VM A: Private IP (Internal)
# -----------------------------
output "vm_a_private_ip" {
  # description จะโชว์ตอน terraform output -json หรือใน docs/module
  description = "Private/Internal IP ของ vm-a ใน VPC/subnet (ใช้คุยกันภายใน เช่น ping/ssh ผ่าน peering/VPN)"
  
  # google_compute_instance.vm_a คือ resource instance ที่เราสร้างไว้
  # network_interface[0] = NIC ตัวแรก (ส่วนใหญ่ VM มี NIC เดียว)
  # network_ip = IP ภายในที่ GCP assign ใน subnet (เช่น 192.168.10.x หรือ 10.10.0.x)
  value = google_compute_instance.vm_a.network_interface[0].network_ip
}

# -----------------------------
# VM B: Private IP (Internal)
# -----------------------------
output "vm_b_private_ip" {
  description = "Private/Internal IP ของ vm-b ใน VPC/subnet (ใช้ทดสอบ connectivity ภายใน, peering, firewall rules)"
  value       = google_compute_instance.vm_b.network_interface[0].network_ip
}

# -----------------------------
# VM A: External IP (Public)
# -----------------------------
output "vm_a_external_ip" {
  description = "External/Public IP ของ vm-a (ใช้ ssh จากอินเทอร์เน็ต หรือเข้าจากเครื่องเรา ถ้าเปิด firewall 22)"

  # access_config คือส่วนของ External NAT บน NIC นั้น ๆ
  # access_config[0] = config ตัวแรก (ส่วนใหญ่มีอันเดียว)
  # nat_ip = Public IP ที่ GCP ให้ (ephemeral หรือ static ถ้าผูก address)
  #
  # หมายเหตุ: ถ้า VM ไม่มี external IP / ไม่ได้ใส่ access_config จะ error
  # (เพราะ access_config[0] ไม่มีอยู่)
  value = google_compute_instance.vm_a.network_interface[0].access_config[0].nat_ip
}

# -----------------------------
# VM B: External IP (Public)
# -----------------------------
output "vm_b_external_ip" {
  description = "External/Public IP ของ vm-b (ใช้ ssh จากภายนอก ถ้าอนุญาต firewall)"
  value       = google_compute_instance.vm_b.network_interface[0].access_config[0].nat_ip
}

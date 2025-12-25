provider "google" {
  # project = โปรเจกต์ที่ Terraform จะไปสร้าง resource ทั้งหมดลงไป
  # ต้องเป็น "Project ID" (เช่น tlnk-infra-tor) ไม่ใช่ Project Name
  project = var.project_id

  # region = ค่า default region สำหรับ resource แบบ regional
  # เช่น subnet, firewall (บางตัว), cloud router ฯลฯ
  # ถ้า resource นั้นมี field region อยู่ใน resource block แล้ว
  # ตัวนั้นจะ override ค่าใน provider ได้
  region = var.region

  # zone = ค่า default zone สำหรับ resource แบบ zonal
  # เช่น google_compute_instance, google_compute_disk (บางกรณี)
  # เช่น asia-southeast1-b
  # ถ้า resource ใส่ zone ในตัวมันเองอยู่แล้ว ค่าใน resource จะ override provider
  zone = var.zone
}

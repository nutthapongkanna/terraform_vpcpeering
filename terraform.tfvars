project_id = "YOUR_PROJECT_ID"

region = "asia-southeast1"
zone   = "asia-southeast1-a"

# ใส่ IP public ของคุณแบบ /32
ssh_source_ranges = ["0.0.0.0/0"]

machine_type = "e2-micro"
image        = "debian-cloud/debian-12"

# 🧠 Backup Automation System – Proxmox ➜ EC2 ➜ S3

## 📋 Overview
This system automates full VM backups from **Proxmox** to **AWS S3**, using an **EC2 instance** as a secure relay. The design minimizes compute cost, ensures data integrity, and automates the entire lifecycle using **AWS Lambda**, **EventBridge**, and **WireGuard VPN**.

## 🎯 Objective
- Perform automated, verified backups of all Proxmox VMs.
- Securely transfer backup data over a private WireGuard VPN to EC2.
- Push backups to S3 (STANDARD_IA class) for long-term, cost-efficient storage.
- Minimize EC2 runtime using AWS automation.

---

## 🧩 Components

### 1️⃣ Proxmox Environment
- **Backup Type:** Full VM backups using `vzdump`.
- **Script:** `proxmox-backup.sh`
  - Runs on Proxmox host.
  - Automates `vzdump` for all VMs.
  - Verifies backups before transfer.
  - Initiates VPN connection to EC2.
  - Sends backups via `rclone` over WireGuard.
  - Logs backup events and errors.

### 2️⃣ EC2 Relay Server
- **Instance Type:** t3.micro (low cost).
- **Script:** `ec2-sync.sh`
  - Checks WireGuard VPN status.
  - Pulls Proxmox backups via SSH.
  - Pushes backups to AWS S3 using `rclone`.
  - Validates uploads and deletes local files post-transfer.
  - Integrated with systemd timer or cron to trigger on boot.

### 3️⃣ WireGuard VPN Configuration
- Secure tunnel between Proxmox host and EC2.
- Handles key exchange and IP whitelisting.
- Automatically re-establishes on reboot.
- Provides encrypted data flow between local and AWS networks.

### 4️⃣ AWS Lambda + EventBridge Automation
- **Goal:** Start and stop EC2 automatically to save cost.

#### Start Lambda Function
- Triggered by EventBridge every **Wednesday at 1:00 AM ET**.
- Starts the EC2 instance.

#### Stop Lambda Function
- Triggered by EventBridge every **Wednesday at 4:00 AM ET**.
- Stops the EC2 instance post-backup.

Both functions use **boto3** and include CloudWatch logging.

### 5️⃣ AWS S3 Storage
- **Bucket:** `vireo-backups`
- **Storage Class:** STANDARD_IA (Infrequent Access)
- Lifecycle rules can be added to transition older backups to Glacier.

---

## ⚙️ Automation Flow
```bash
Proxmox → (vzdump + verify) → WireGuard Tunnel → EC2 → (rclone → S3)
```

### Timeline
1. **01:00 AM ET (Wednesday)** – Lambda starts EC2 instance.
2. **01:05 AM ET** – EC2 establishes VPN to Proxmox.
3. **01:10 AM ET** – Proxmox triggers backup + sync script.
4. **03:50 AM ET** – EC2 finishes pushing data to S3.
5. **04:00 AM ET** – Lambda stops EC2 instance.

---

## 🪶 Scripts Summary

| Script | Location | Purpose |
|--------|-----------|----------|
| `proxmox-backup.sh` | Proxmox host | Runs vzdump backups and initiates sync |
| `ec2-sync.sh` | EC2 instance | Pulls backups, verifies, uploads to S3 |
| `lambda_start_ec2.py` | AWS Lambda | Starts EC2 instance on schedule |
| `lambda_stop_ec2.py` | AWS Lambda | Stops EC2 instance on schedule |

---

## 💰 Cost Optimization Breakdown
| Component | Est. Monthly Cost | Notes |
|------------|------------------|-------|
| EC2 t3.micro | ~$1.80 | Runs 3 hrs/week via Lambda |
| S3 Storage | ~$3–5 | Based on ~50–100 GB STANDARD_IA |
| Lambda & EventBridge | <$0.10 | Negligible usage cost |
| **Total** | **≈ $5–7/month** | Fully automated and secure |

---

## 🧠 Why This Matters
This backup system demonstrates an enterprise-grade automation pattern using minimal resources:
- End-to-end encrypted data transfer (WireGuard).
- Cost-efficient lifecycle automation (Lambda + EventBridge).
- Reliable verification and cleanup using shell scripting.
- Cloud-native storage and auditability.

---

## 🧾 Next Steps
- Add lifecycle rules to move older backups to **Glacier Deep Archive**.
- Integrate CloudWatch alerts for backup success/failure events.
- Optionally deploy monitoring in Grafana for EC2/S3 usage metrics.

---

## 📂 Folder Structure 
```
backups/
│
├── README.md                # This file
├── proxmox-backup.sh        # Proxmox automation script
├── ec2-sync.sh              # EC2 pull + upload script
├── lambda_start_ec2.py      # Lambda to start EC2
└── lambda_stop_ec2.py       # Lambda to stop EC2

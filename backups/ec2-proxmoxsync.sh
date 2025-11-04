#!/bin/bash
# ==============================================================
# EC2 Sync Script – Pull Proxmox backups via VPN and upload to S3
# Author: Emmanuel
# Purpose: Runs weekly on EC2 to pull VM backups from Proxmox
# ==============================================================

# === CONFIGURATION ===
PROXMOX_IP="10.10.10.2"                         # Proxmox VPN tunnel IP
PROXMOX_USER="root"                             # SSH user on Proxmox
REMOTE_BACKUP_DIR="/var/backups/proxmox"        # Source on Proxmox
LOCAL_STAGING_DIR="/root/proxmox_staging"       # Local staging directory
S3_BUCKET="vireo.local-backupsS3:vireo.local-backups"
LOG_FILE="/var/log/ec2-proxmox-sync.log"
SNS_TOPIC_ARN="arn:aws:sns:us-east-1:325267459025:ProxmoxBackupNotifications"
MAX_RETRIES=3                                   # VPN retry attempts
SLEEP_BETWEEN_RETRIES=30                        # seconds

# ===== Required IAM Policy =====
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:PutObject",
#         "s3:ListBucket",
#         "s3:GetObject",
#         "sns:Publish"
#       ],
#       "Resource": "*"
#     }
#   ]
# }

# === FUNCTIONS ===
timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

notify() {
  MESSAGE=$1
  aws sns publish --topic-arn "$SNS_TOPIC_ARN" --message "$MESSAGE" >/dev/null 2>&1
}

vpn_up() {
  echo "[*] Attempting to bring up WireGuard (wg0)..." | tee -a "$LOG_FILE"
  systemctl restart wg-quick@wg0 >/dev/null 2>&1
  sleep 5
}

check_vpn() {
  ping -c 2 -W 2 "$PROXMOX_IP" >/dev/null 2>&1
}

# === LOG START ===
echo "===== EC2 Backup Sync Started @ $(timestamp) =====" | tee -a "$LOG_FILE"

# === 1. VERIFY VPN CONNECTIVITY (WITH RETRIES) ===
VPN_READY=false
for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "[*] Checking VPN connectivity (Attempt $i/$MAX_RETRIES)..." | tee -a "$LOG_FILE"
  
  if check_vpn; then
    VPN_READY=true
    echo "[✔] VPN tunnel reachable at $PROXMOX_IP" | tee -a "$LOG_FILE"
    break
  else
    echo "[!] VPN not reachable. Trying to bring it up..." | tee -a "$LOG_FILE"
    vpn_up
  fi

  sleep "$SLEEP_BETWEEN_RETRIES"
done

if [ "$VPN_READY" = false ]; then
  echo "[✖] VPN tunnel failed after $MAX_RETRIES attempts. Aborting." | tee -a "$LOG_FILE"
  notify "Proxmox backup sync FAILED: VPN tunnel unreachable after $MAX_RETRIES retries."
  exit 1
fi

# === 2. PREP LOCAL STAGING DIRECTORY ===
echo "[*] Preparing local staging directory..." | tee -a "$LOG_FILE"
mkdir -p "$LOCAL_STAGING_DIR"
rm -rf "$LOCAL_STAGING_DIR"/*

# === 3. PULL BACKUPS FROM PROXMOX ===
echo "[*] Pulling backups from Proxmox host ($PROXMOX_IP)..." | tee -a "$LOG_FILE"
rsync -avz -e "ssh -o StrictHostKeyChecking=no" \
  $PROXMOX_USER@$PROXMOX_IP:$REMOTE_BACKUP_DIR/ $LOCAL_STAGING_DIR/ >> "$LOG_FILE" 2>&1
RSYNC_STATUS=$?

if [ $RSYNC_STATUS -ne 0 ]; then
  echo "[!] rsync failed! Check logs." | tee -a "$LOG_FILE"
  notify "Proxmox backup rsync failed from $PROXMOX_IP."
  exit 1
fi

# === 4. VERIFY BACKUPS LOCALLY ===
echo "[*] Verifying pulled backups..." | tee -a "$LOG_FILE"
VERIFY_ERRORS=0

for f in "$LOCAL_STAGING_DIR"/*.vma.zst; do
  [ -e "$f" ] || continue
  echo "Verifying $f ..." | tee -a "$LOG_FILE"
  zstd -dc "$f" | vma verify - >> "$LOG_FILE" 2>&1
  if [ $? -ne 0 ]; then
    echo "[!] Verification failed for $f" | tee -a "$LOG_FILE"
    VERIFY_ERRORS=$((VERIFY_ERRORS + 1))
  fi
done

if [ $VERIFY_ERRORS -gt 0 ]; then
  echo "[!] One or more backups failed verification." | tee -a "$LOG_FILE"
  notify "EC2: Backup verification failed on $VERIFY_ERRORS file(s)."
  exit 1
fi
echo "[✔] All backups verified successfully." | tee -a "$LOG_FILE"

# === 5. PUSH VERIFIED FILES TO S3 ===
echo "[*] Uploading verified backups to S3 ($S3_BUCKET)..." | tee -a "$LOG_FILE"
rclone sync "$LOCAL_STAGING_DIR" "$S3_BUCKET" \
  --progress --s3-storage-class STANDARD_IA \
  --transfers 4 --checkers 8 --log-file "$LOG_FILE" --log-level INFO
RCLONE_STATUS=$?

if [ $RCLONE_STATUS -ne 0 ]; then
  echo "[!] rclone upload failed!" | tee -a "$LOG_FILE"
  notify "Proxmox backup upload to S3 FAILED. Check EC2 logs."
  exit 1
fi

# === 6. CLEANUP ===
echo "[*] Cleaning up staging directory..." | tee -a "$LOG_FILE"
rm -rf "$LOCAL_STAGING_DIR"/*

# === 7. SUCCESS ===
echo "[✔] Sync complete and uploaded to S3 successfully." | tee -a "$LOG_FILE"
notify "Proxmox backups successfully uploaded to S3 at $(timestamp)."

echo "===== EC2 Backup Sync Complete @ $(timestamp) =====" | tee -a "$LOG_FILE"
exit 0

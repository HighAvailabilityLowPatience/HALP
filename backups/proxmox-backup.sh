#!/bin/bash
# ==============================================================
# Proxmox Backup Automation Script
# Author: Emmanuel
# Purpose: Full backup, verify, prune, and notify
# ==============================================================

# === CONFIGURATION ===
BACKUP_DIR="/var/backups/proxmox"
LOG_FILE="/var/log/proxmox-backup.log"
RETENTION_DAYS=15

# === LOG HEADER ===
echo "===== Proxmox Backup Started at $(date) =====" | tee -a "$LOG_FILE"

# === 1. VERIFY BACKUP DIRECTORY ===
if [ ! -d "$BACKUP_DIR" ]; then
    echo "[*] Creating backup directory at $BACKUP_DIR..." | tee -a "$LOG_FILE"
    mkdir -p "$BACKUP_DIR"
fi

# === 2. RUN BACKUPS ===
echo "[*] Running vzdump backups..." | tee -a "$LOG_FILE"
vzdump --all --mode snapshot --compress zstd \
       --dumpdir "$BACKUP_DIR" >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    echo "[!] vzdump failed! Check $LOG_FILE" | tee -a "$LOG_FILE"
    exit 1
fi

# === 3. VERIFY BACKUPS ===
echo "[*] Verifying backup files..." | tee -a "$LOG_FILE"

for file in "$BACKUP_DIR"/*.vma.zst; do
    if [ -f "$file" ]; then
        echo "    [+] Checking $file" | tee -a "$LOG_FILE"
        zstd -t "$file" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            echo "        ✅ $file OK" | tee -a "$LOG_FILE"
        else
            echo "        ❌ $file FAILED verification!" | tee -a "$LOG_FILE"
        fi
    fi
done

# === 4. PRUNE OLD BACKUPS ===
echo "[*] Pruning backups older than $RETENTION_DAYS days..." | tee -a "$LOG_FILE"
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -print -delete >> "$LOG_FILE" 2>&1

# === 5. CLEANUP & SUMMARY ===
echo "[+] Backup job completed successfully at $(date)" | tee -a "$LOG_FILE"
echo "==============================================================" | tee -a "$LOG_FILE"

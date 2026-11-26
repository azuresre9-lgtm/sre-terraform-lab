#!/bin/bash
DATE_TAG=$(date -u +%Y-%m-%d)
SRC="03-linux-storage-cron/vm-I2CP-EUR-APP-P-ETL-01/mnt/saI2CPEURreport01"
DEST="03-linux-storage-cron/vm-I2CP-EUR-APP-P-ETL-01/backup/reports/Cockpit_AutoBackup_${DATE_TAG}.tar.gz"
tar -czf "$DEST" -C "$SRC" .
echo "[$(date -u)] SUCCESS: Archived Cockpit reports to $DEST"

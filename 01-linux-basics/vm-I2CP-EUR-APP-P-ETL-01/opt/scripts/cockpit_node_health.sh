#!/bin/bash
echo "=================================================="
echo " COCKPIT SRE HEALTH REPORT: vm-I2CP-EUR-APP-P-ETL-01"
echo " Timestamp (UTC): $(date -u)"
echo "=================================================="

echo "[1] MEMORY STATUS:"
free -h | grep -E "Mem:|Swap:"

echo ""
echo "[2] DISK USAGE (/):"
df -h / | tail -n 1

echo ""
echo "[3] ETL LOG ERROR COUNT:"
LOG_FILE="01-linux-basics/vm-I2CP-EUR-APP-P-ETL-01/var/log/etl/cockpit-etl-prod.log"
ERR_COUNT=$(grep -cE "ERROR|CRITICAL" "$LOG_FILE")
echo "Total ERROR/CRITICAL events found: $ERR_COUNT"

if [ "$ERR_COUNT" -gt 0 ]; then
echo "STATUS: ACTION REQUIRED -> Escalate to SNOW / Check KeyVault & Storage Mount"
else
echo "STATUS: HEALTHY"
fi

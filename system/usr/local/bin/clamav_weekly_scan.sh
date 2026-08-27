#!/bin/bash

LOG_FILE="/var/log/clamav/weekly_scan.log"
TARGETS="/home /etc /var/www /root"

MSG_VRS="ALERT: ClamAV weekly scan found viruses! Infected files moved to quarantine. Check $LOG_FILE"
MSG_ERR="ERROR: ClamAV weekly scan failed due to technical error. Check systemd logs and $LOG_FILE"
MSG_UNK="ClamAV completed with an unexpected exit code. Check $LOG_FILE"

mkdir -p "$(dirname "$LOG_FILE")"

echo "=== Starting ClamAV weekly scan: $(date) ===" >> "$LOG_FILE"

# scan via daemon is faster and more effective
# --multiscan use all cores, --fdpass pass read rights to daemon
# ret 1 = malware found, 2 = error
/usr/bin/clamdscan --multiscan --fdpass --move=/var/lib/clamav/quarantine --log="$LOG_FILE" $TARGETS
SCAN_STATUS=$?
echo "=== Scan complete: $(date) (Status: $SCAN_STATUS) ===" >> "$LOG_FILE"

[ "$SCAN_STATUS" -eq 1 ] && (SUBJECT="[!!] ClamAV Alert: THREATS FOUND"; MESSAGE="$MSG_VRS")
[ "$SCAN_STATUS" -eq 2 ] && (SUBJECT="[X] ClamAV Error: Scan Failed"; MESSAGE="$MSG_ERR")
[ "$SCAN_STATUS" -ne 1 ] && [ "$SCAN_STATUS" -ne 2 ] && (SUBJECT="[?] ClamAV: Unknown Code ($SCAN_STATUS)"; MESSAGE="$MSG_UNK")

[ "$SCAN_STATUS" -ne 0 ] && echo "$MESSAGE" | /usr/bin/mail -s "$SUBJECT" glitch

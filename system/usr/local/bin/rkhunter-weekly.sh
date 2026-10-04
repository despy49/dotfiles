#!/bin/bash

/usr/bin/rkhunter --update --quiet

# check mode: warnings
RK_OUTPUT=$(/usr/bin/rkhunter --check --sk --rwo 2>/dev/null)

ALERT_LOG=""
CRITICAL_FOUND=false

# filter output and keep "properties have changed" only
PROP_CHANGES=$(echo "$RK_OUTPUT" | grep "The file properties have changed:")

if [ -n "$PROP_CHANGES" ]; then
    # check all warnings line by line and extract file paths
    while read -r line; do
        if [[ "$line" =~ File:[[:space:]]*(/usr/[^[:space:]]+) ]]; then
            FILE_PATH="${BASH_REMATCH[1]}"
            
            # define which pkg the file belongs to
            PACKAGE_NAME=$(pacman -Qo "$FILE_PATH" 2>/dev/null | awk '{print $5}')
            
            if [ -n "$PACKAGE_NAME" ]; then
                # check in  pacman.log if the pkg was updated
                PAC_CHECK=$(grep -E "upgraded $PACKAGE_NAME " /var/log/pacman.log | tail -n 1)
                # check the pkg integrity with pacman -Qkk
                INTEGRITY_CHECK=$(pacman -Qkk "$PACKAGE_NAME" 2>/dev/null | grep "altered files")
                
                # validation logic: if has been updated and integrity is OK = GOOD
                if [ -n "$PAC_CHECK" ] && [ -z "$INTEGRITY_CHECK" ]; then
                    # update hash for this very file
                    /usr/bin/rkhunter --propupd "$FILE_PATH" --quiet
                else
                    # if checks failed = real anomaly (possible rootkit)
                    CRITICAL_FOUND=true
                    ALERT_LOG+="\n[!] CRITICAL ANOMALY: $FILE_PATH (Package: $PACKAGE_NAME)\n"
                    ALERT_LOG+="Update log: ${PAC_CHECK:-MISSING AMONG UPDATED PKGs}\n"
                    ALERT_LOG+="Integrity status: $(pacman -Qkk "$PACKAGE_NAME" 2>/dev/null | grep total)\n"
                fi
            fi
        fi
    done <<< "$(echo "$RK_OUTPUT" | grep -A 1 "The file properties have changed:")"
fi

# filter the rest of rkhunter warnings (not related to files props)
OTHER_WARNINGS=$(echo "$RK_OUTPUT" | grep -v -E "The file properties have changed:|File:|egrep|fgrep|ldd|\.updated|\.k5login|\.k5identity|flatpak-com\.valvesoftware\.Steam")



# === SEND REPORTS BASED ON THE ANALYSIS ===
if [ "$CRITICAL_FOUND" = true ] || [ -n "$OTHER_WARNINGS" ]; then
    FINAL_REPORT="ALERT: rkhunter has detected suspicious activity!\n"
    if [ "$CRITICAL_FOUND" = true ]; then
        FINAL_REPORT+="\n=== ALTERED FILES DETECTED (POSSIBLE ROOTKIT) ===\n$ALERT_LOG\n"
    fi
    if [ -n "$OTHER_WARNINGS" ]; then
        FINAL_REPORT+="\n=== MSC SYSTEM ANOMALIES ===\n$OTHER_WARNINGS\n"
    fi
    
    echo -e "$FINAL_REPORT" | /usr/bin/mail -S hold -S keepsave=no -s "[ALERT] rkhunter: Integrity check FAILED!" glitch
else
    SUCCESS_REPORT="SUCCESS: Weekly rkhunter audit finished successfully.\n\n"
    SUCCESS_REPORT+="Status: Matrix filesystem hashes are fully aligned with official Arch Linux repositories.\n"
    SUCCESS_REPORT+="No critical anomalies or rootkit signatures were found.\n\n"
    SUCCESS_REPORT+="Scan timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

    echo -e "$SUCCESS_REPORT" | /usr/bin/mail -S hold -S keepsave=no -s "[SUCCESS] rkhunter: System is clean" glitch
fi






# filter out 3 known false positives 
#RK_FILTERED=$(echo "$RK_OUTPUT" | grep -v -E "egrep|fgrep|ldd|\.updated|\.k5login|\.k5identity|\flatpak-com\.valvesoftware\.Steam")

#if [ -n "$RK_FILTERED" ]; then
#    echo -e "ALERT: Rootkit Hunter found suspicious anomalies on matrix!\n\nReview the warnings below:\n\n$RK_FILTERED" | /usr/bin/mail -S hold -S keepsave=no -s "[ALERT] rkhunter: Anomalies Detected" glitch
#fi

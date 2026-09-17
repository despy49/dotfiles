#!/bin/bash

/usr/bin/rkhunter --update --quiet

# check mode: warnings
RK_OUTPUT=$(/usr/bin/rkhunter --check --sk --rwo 2>/dev/null)

# filter out 3 known false positives 
RK_FILTERED=$(echo "$RK_OUTPUT" | grep -v -E "egrep|fgrep|ldd|\.updated|\.k5login|\.k5identity|\flatpak-com\.valvesoftware\.Steam")

if [ -n "$RK_FILTERED" ]; then
    echo -e "ALERT: Rootkit Hunter found suspicious anomalies on matrix!\n\nReview the warnings below:\n\n$RK_FILTERED" | /usr/bin/mail -S hold -S keepsave=no -s "[ALERT] rkhunter: Anomalies Detected" glitch
fi


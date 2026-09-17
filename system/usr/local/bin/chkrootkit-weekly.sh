#!/bin/bash

CHK_OUTPUT=$(/usr/bin/chkrootkit -q 2>/dev/null)

# filter out known legit hidden build and node files
CHK_FILTERED=$(echo "$CHK_OUTPUT" | grep -v -E "can't exec|objects-RelWithDebInfo|node_modules|python3|numpy|extensions|dbeaver|libreoffice|firmware|perl5|modules|/go/src")

if [ -n "$CHK_FILTERED" ]; then
    echo -e "ALERT: chkrootkit detected potential rootkit signatures on matrix!\n\nReview the output:\n\n$CHK_FILTERED" | /usr/bin/mail -S hold -S keepsave=no -s "[ALERT] chkrootkit: Suspicious Files Found" glitch
fi


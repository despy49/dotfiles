#!/bin/bash
AUDIT_OUTPUT=$(/usr/bin/arch-audit -u)
if [ -n "$AUDIT_OUTPUT" ]; then
    echo -e "ALERT: Security patches available for your Arch Linux packages!\n\nRun 'sudo pacman -Syu' to fix the following vulnerabilities:\n\n$AUDIT_OUTPUT" | /usr/bin/mail -S hold -S keepsave=no -s "[SECURITY] Arch Linux: New Patches Available" glitch
fi


#!/usr/bin/env bash
set -euo pipefail

HOSTS_FILE="/etc/hosts"
TMP_RAW="/tmp/ad_raw.tmp"
TMP_DOMAINS="/tmp/ad_domains.tmp"
TMP_WHITE="/tmp/ad_white_clean.tmp"

declare -A SOURCES=(
    ["FIREBOG-TRACKERS"]="https://v.firebog.net/hosts/AdguardDNS.txt"
    ["ADGUARD-SDNS"]="https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"
    ["EASYPRIVACY"]="https://v.firebog.net/hosts/Easyprivacy.txt"
    ["UNCHECKY-MALWARE"]="https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
    ["ABUSE-URLHAUS"]="https://urlhaus.abuse.ch/downloads/hostfile/"
    ["YOYO-ADSERVERS"]="https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
    ["HAGEZI-LIGHT"]="https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/light.txt"
    ["HAGEZI-MULTI"]="https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/multi.txt"
    ["HAGEZI-TIF"]="https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"
    ["RUADLIST-SERVERS"]="https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/CyrillicFilters/RussianFilter/sections/adservers_firstparty.txt"
    ["RUADLIST-SPYWARE"]="https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/CyrillicFilters/RussianFilter/sections/antiadblock.txt"
)

echo "[*] Begging clearance old blocks clearance..."
sed -i '/# BEGIN AD-BLOCK.*/,/# END AD-BLOCK.*/d' "$HOSTS_FILE"

echo "[*] Preparing whitelist, ignoring comments and empty lines..."
if [ -f /etc/dns-blocker/whitelist.txt ]; then
    grep -v -E "(^[[:space:]]*#|^[[:space:]]*$)" /etc/dns-blocker/whitelist.txt > "$TMP_WHITE"
else
    > "$TMP_WHITE"
fi

for group in "${!SOURCES[@]}"; do
    url="${SOURCES[$group]}"
    echo "[*] Processing group: $group"
    echo "  -> Downloading: $url"
    
    > "$TMP_RAW"
    > "$TMP_DOMAINS"
    
    if curl -sfL --socks5-hostname 127.0.0.1:8081 --connect-timeout 10 --max-time 60 "$url" > "$TMP_RAW"; then
        
        sed -e 's/||//g' -e 's/\^//g' -e 's/\$third-party//g' \
            -e 's/#.*//g' -e 's/!.*//g' -e 's/[[:space:]]*$//g' \
            -e 's/\r//g' "$TMP_RAW" | \
        awk '
            NF == 0 {next}
            $1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { if ($2 != "" && $2 !~ /localhost/) print $2; next }
            $1 ~ /^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/ { print $1 }
        ' | grep -vFf "$TMP_WHITE" | sort -u > "$TMP_DOMAINS"
        
        if [ -s "$TMP_DOMAINS" ]; then
            echo "  [+] filtering succes. Injecting the block: $group..."
            
            echo "# BEGIN AD-BLOCK: $group" >> "$HOSTS_FILE"
            awk '{print "0.0.0.0 " $1}' "$TMP_DOMAINS" >> "$HOSTS_FILE"
            echo "# END AD-BLOCK: $group" >> "$HOSTS_FILE"
        else
            echo "  [!] filtered list was empty."
        fi
    else
        echo "  [!] err downloading $url, skipping group."
    fi
done



# filter out non commitable shit
LOCAL_SOURCE="/etc/dns-blocker/motherfuckers.txt"
if [ -f "$LOCAL_SOURCE" ]; then
    echo "[*] Processing local group: SYSTEM-BLOCK-RU"

    # jut in case
    > "$TMP_DOMAINS"

    # read and remove comments,empty lines, comments
    grep -v -E "(^[[:space:]]*#|^[[:space:]]*$)" "$LOCAL_SOURCE" | \
    sed -e 's/[[:space:]]*$//g' -e 's/\r//g' | \
    grep -vFf "$TMP_WHITE" | sort -u > "$TMP_DOMAINS"

    if [ -s "$TMP_DOMAINS" ]; then
        echo "  [+] local filtering success. Injecting the block: SYSTEM-BLOCK-RU..."
        echo "# BEGIN AD-BLOCK: SYSTEM-BLOCK-RU" >> "$HOSTS_FILE"
        awk '{print "0.0.0.0 " $1}' "$TMP_DOMAINS" >> "$HOSTS_FILE"
        echo "# END AD-BLOCK: SYSTEM-BLOCK-RU" >> "$HOSTS_FILE"
    else
        echo "  [!] local filtered list was empty."
    fi
fi





rm -f "$TMP_RAW" "$TMP_DOMAINS" "$TMP_WHITE"
echo "[+] hosts update finished!"

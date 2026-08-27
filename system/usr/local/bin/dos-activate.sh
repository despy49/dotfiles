#!/bin/bash

# 1. restore tun if there is a bak left after switch to DoT
if [ -f /etc/systemd/resolved.conf.d/ssh-tunnel.conf.bak ]; then
    mv /etc/systemd/resolved.conf.d/ssh-tunnel.conf.bak /etc/systemd/resolved.conf.d/ssh-tunnel.conf
fi

# 2. restore sys link to resolver
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# 3. retart services
systemctl restart systemd-resolved
systemctl restart NetworkManager

echo "[+] DNS Tunnel activated and network restarted successfully"

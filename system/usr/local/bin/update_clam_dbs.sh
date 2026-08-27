#! /bin/bash

PROXY="socks5h://127.0.0.1:8080"
TMP_DIR="/tmp/clamav_update"
TARGET_DIR="/var/lib/clamav"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
LOCK_FILE="/tmp/clamav_script_update.lock"


if pgrep -x "clamscan" > /dev/null || pgrep -x "clamdscan" > /dev/null; then
	echo "Cancelled: scanning in process"
	exit 0
fi


if [ -f "$LOCK_FILE" ]; then
	OLD_PID=$(cat "$LOCK_FILE")
	if kill -0 "$OLD_PID" 2>/dev/null; then
		echo "Cancelled: DBs update already run by another process (PID $OLD_PID)"
		exit 0
	fi
fi

echo $$ > "$LOCK_FILE"
cleanup(){
	echo "Cleaning up SSH tunnel and removing temp files"
	pkill -f "ssh -N -D 127.0.0.1:8080"
	rm -f "$LOCK_FILE"
	rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

echo "Openning SSH tunnel..."
/usr/bin/ssh -N -D 127.0.0.1:8080 fyrkn &
SSH_PID=$!

sleep 3
if ! kill -0 "$SSH_PID" 2>/dev/null; then
	echo "ERROR: SSH tunnel failed to start. Aborting update immediately."
	exit 1
fi

echo "Using proxy $PROXY"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

echo "Downloading clamav DBs via proxy..."
/usr/local/bin/clam_downloader config set --dbdir "$TMP_DIR" > /dev/null
HTTP_PROXY="$PROXY" HTTPS_PROXY="$PROXY" /usr/local/bin/clam_downloader update
DOWNLOAD_STATUS=$?

echo "Removing unnesseccary files: *.txt *.txt *.cdiff*"
rm -rf *.txt *.txt *.cdiff*

if [ "$DOWNLOAD_STATUS" -ne 0 ] || [ ! -f main.cvd ] || [ ! -f daily.cvd ] || [ ! -f bytecode.cvd ]; then
	echo "ERROR: Download failed. Aborting update."
	cat main.cvd daily.cvd bytecode.cvd
	exit 1
fi

if file main.cvd | grep -q "HTML"; then
	echo "ERROR: Cloudflare still blocking the reqest. HTML downloaded"
	rm main.cvd daily.cvd bytecode.cvd
	exit 1
fi

echo "Moving DBs and assigning rights..."
sudo mv main.cvd daily.cvd bytecode.cvd "$TARGET_DIR/"
sudo chown -R clamav:clamav "$TARGET_DIR"
chmod 644 "$TARGET_DIR"/*.cvd

sudo clamdscan --reload

echo "Update successfull!"
rm -rf "$TMP_DIR"

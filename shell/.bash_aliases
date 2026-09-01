# === SORTED LISTING FUNCTIONS ===
# rule: 1. hidden dirs | 2. regular dirs | 3. hidden files | 4. regular files

# skips hidden files entirely
function l {
    local target="${1:-.}"
    local item dirs=() files=()
    
    # OPSEC FIX: Если передан файл, просто рендерим его через lsd напрямую
    if [ -f "$target" ] || [ -L "$target" ]; then
        lsd -ldhi -d --color=always "$target" 2>/dev/null
        return
    fi
    
    cd "$target" 2>/dev/null || return

    for item in *; do
        [ -e "$item" ] || continue
        if [ -d "$item" ] && [ ! -L "$item" ]; then
            dirs+=("$item")
        else
            files+=("$item")
        fi
    done

    # regular dirs only
    [ ${#dirs[@]} -gt 0 ] && lsd -ldhi -d --color=always "${dirs[@]}" 2>/dev/null
    # regular files only
    [ ${#files[@]} -gt 0 ] && lsd -ldhi -d --color=always "${files[@]}" 2>/dev/null

    cd - >/dev/null
}

# list structured into categories
function la {
    local target="${1:-.}"
    local item name h_dirs=() r_dirs=() h_files=() r_files=()

    # NO cd if file passed as arg
    if [ -f "$target" ] || [ -L "$target" ]; then
        lsd -ldhi -d --color=always "$target" 2>/dev/null
        return
    fi

    cd "$target" 2>/dev/null || return

    shopt -s nullglob dotglob
    for item in *; do
        [ -e "$item" ] || continue
        name="$item"
        [[ "$name" == "." || "$name" == ".." || "$name" == ".git" ]] && continue

        # regular dirs without symlinks
        if [ -d "$item" ] && [ ! -L "$item" ]; then
            if [[ "$name" == .* ]]; then
                h_dirs+=("$item")
            else
                r_dirs+=("$item")
            fi
        else
            if [[ "$name" == .* ]]; then
                h_files+=("$item")
            else
                r_files+=("$item")
            fi
        fi
    done
    shopt -u dotglob

    [ ${#h_dirs[@]} -gt 0 ] && lsd -ldhi -d --color=always "${h_dirs[@]}" 2>/dev/null        # hidden dirs only 
    [ ${#r_dirs[@]} -gt 0 ] && lsd -ldhi -d --color=always "${r_dirs[@]}" 2>/dev/null        # regular dirs 
    [ ${#h_files[@]} -gt 0 ] && lsd -ldhi -d --color=always "${h_files[@]}" 2>/dev/null      # hidden files 
    [ ${#r_files[@]} -gt 0 ] && lsd -ldhi -d --color=always "${r_files[@]}" 2>/dev/null      # regular files

    cd - >/dev/null
}


# === CORE CLI OVERRIDES ===
alias tree="eza --tree --icons=always --level=3 --long --no-user --no-time --git"
alias htop="btop"


# === SEC TOOLS & PENTEST ALIASES ===
alias burpsuite="java -Dburp.ignore_java_version=true -jar /usr/share/java/burpsuite/burpsuite.jar"
alias semgrep="docker run --rm -v \"\${PWD}:/src\" returntocorp/semgrep semgrep"


# === DNS Tunneling ===
alias doson='systemctl --user start dos-tun.service dos-tun-post.service && echo "[+] DoS active"'
alias doton='systemctl --user stop dos-tun.service dos-tun-post.service
    if [ -f /etc/systemd/resolved.conf.d/ssh-tunnel.conf ]; then
        sudo mv /etc/systemd/resolved.conf.d/ssh-tunnel.conf /etc/systemd/resolved.conf.d/ssh-tunnel.conf.bak
    fi
    sudo /usr/bin/systemctl restart systemd-resolved NetworkManager
    echo "[-] Dos off. Back to DoT."
'


# === ALT TREE VIEW ===
function lt {
    local depth=2
    local path="."

    if [[ "$1" =~ ^[0-9]+$ ]]; then
        depth="$1"
        path="${2:-.}"
    elif [ -n "$1" ]; then
        path="$1"
    fi

    eza --tree --icons=always --level="$depth" --long --no-user --no-time --git -a "$path"
}


# === SYSTEM WRAPPERS & CLEANUP ALIASES ===

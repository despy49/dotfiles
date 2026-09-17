# === SORTED LISTING FUNCTIONS ===
# rule: 1. hidden dirs | 2. regular dirs | 3. hidden files | 4. regular files

function l {
    local target="${1:-.}"
    local item dirs=() files=()
    
    if [ -f "$target" ] || [ -L "$target" ]; then
        lsd -lhi -d --color=always "$target" 2>/dev/null
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

    [ ${#dirs[@]} -gt 0 ] && lsd -lhi -d --color=always "${dirs[@]}" 2>/dev/null
    [ ${#files[@]} -gt 0 ] && lsd -lhi -d --color=always "${files[@]}" 2>/dev/null

    cd - >/dev/null
}

function la {
    local target="${1:-.}"
    local item name h_dirs=() r_dirs=() h_files=() r_files=()

    if [ -f "$target" ] || [ -L "$target" ]; then
        lsd -lhi -d --color=always "$target" 2>/dev/null
        return
    fi

    cd "$target" 2>/dev/null || return

    local old_shop=$(shopt -p nullglob dotglob)
    shopt -s nullglob dotglob

    for item in *; do
        [ -e "$item" ] || continue
        name="$item"
        [[ "$name" == "." || "$name" == ".." || "$name" == ".git" ]] && continue

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
    
    eval "$old_shop"

    [ ${#h_dirs[@]} -gt 0 ] && lsd -lhi -d --color=always "${h_dirs[@]}" 2>/dev/null        
    [ ${#r_dirs[@]} -gt 0 ] && lsd -lhi -d --color=always "${r_dirs[@]}" 2>/dev/null        
    [ ${#h_files[@]} -gt 0 ] && lsd -lhi -d --color=always "${h_files[@]}" 2>/dev/null      
    [ ${#r_files[@]} -gt 0 ] && lsd -lhi -d --color=always "${r_files[@]}" 2>/dev/null      

    cd - >/dev/null
}


# === CORE CLI OVERRIDES ===
alias sudo='sudo -E bash -c "source ~/.bash_aliases; \"\$@\"" --'
alias tree="eza --tree --icons=always --level=3 --long --group --no-time --git"
alias htop="btop"


# === SEC TOOLS & PENTEST ALIASES ===
alias burpsuite="java -Dburp.ignore_java_version=true -jar /usr/share/java/burpsuite/burpsuite.jar"


# === DNS Tunneling ===
# Switch to DNS over SSH
alias doson='
    if [ -f /etc/systemd/resolved.conf.d/ssh-tunnel.conf.bak ]; then
        sudo mv /etc/systemd/resolved.conf.d/ssh-tunnel.conf.bak /etc/systemd/resolved.conf.d/ssh-tunnel.conf
    fi
    sudo systemctl start escape-from-matrix.service dos-tun.service
    echo "[+] DNS over SSH activated (Port 5300)!"
'

# Switch from DNS over SSH to DoT (Quad9/Mullvad)
alias doton='
    sudo systemctl stop dos-tun.service escape-from-matrix.service
    if [ -f /etc/systemd/resolved.conf.d/ssh-tunnel.conf ]; then
        sudo mv /etc/systemd/resolved.conf.d/ssh-tunnel.conf /etc/systemd/resolved.conf.d/ssh-tunnel.conf.bak
    fi
    sudo resolvectl flush-caches
    echo "[-] DNS over SSH stopped. Seamlessly switched to pure DoT (Quad9/Mullvad)."
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

    eza --tree --icons=always --level="$depth" --long --group --no-time --git -a "$path"
}


# === RIPGREP ===
# highlighted, line-numbered, with context
alias rgc="rg -C 2 --smart-case"

# search a word in specific type files
alias rgp="rg --type py"

# term radio
alias r='~/.local/bin/bitradio'

# === INTERACTIVE TEXT SEARCH (RG + FZF) ===
# Поиск текста внутри файлов с интерактивным превью в bat
function fif {
    local search_term="$1"
    if [ -z "$search_term" ]; then
        echo "Использование: fif \"текст_для_поиска\""
        return 1
    fi
    rg --files-with-matches --no-messages "$search_term" | fzf --preview "rg --ignore-case --pretty --context 10 '$search_term' {}"
}


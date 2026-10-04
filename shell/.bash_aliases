# === SYSTEM & CLI OVERRIDES ===
alias tree="eza --tree --icons=always --level=3 --long --group --no-time --git"
alias sudo='sudo -E bash -c "source ~/.bash_aliases; \"\$@\"" --'



# === SORTED LISTING & TREES  ===
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

# parametrized tree func
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



# === INTERACTIVE TEXT SEARCH (RG + FZF) ===
alias rgc="rg -C 2 --smart-case"    # highlighted, line-numbered, with context
alias rgp="rg --type py"            # search a word in specific type files

# start search from current dir
function fif {
    local search_term="$1"
    if [ -z "$search_term" ]; then
        echo "Usage: fif \"search query\""
        return 1
    fi
    rg --files-with-matches --no-messages --hidden "$search_term" . 2>/dev/null | \
        fzf --preview "rg --ignore-case --pretty --context 10 '$search_term' {} 2>/dev/null"
}



# global search among hidden configs and in home
function fica {
    local search_term="$1"
    if [ -z "$search_term" ]; then
        echo "Usage: fica \"query string\""
        return 1
    fi
    # specify targets dirs only
    rg --files-with-matches --no-messages --hidden "$search_term" \
       ~/.bashrc ~/.bash_aliases ~/dotfiles/ ~/Projects/ ~/Documents/ 2>/dev/null | \
        fzf --preview "rg --ignore-case --pretty --context 10 '$search_term' {} 2>/dev/null"
}



# === APP PROXY ROUTING ===
alias nd="netdoc"
alias ledger-live='ledger-live-desktop --proxy-server="http://127.0.0.1:8888" --proxy-bypass-list="<-loopback>"'



# === PACKAGE MANAGER WRAPPERS ===
function paru {
    local proxy_packages="mullvad-browser-bin mullvad-vpn-bin tor-browser-bin"
    local use_proxy=false
    local arg pkg

    for arg in "$@"; do
        for pkg in $proxy_packages; do
            if [[ "$arg" == *"$pkg"* ]]; then
                use_proxy=true
                break 2
            fi
        done
    done

    if [ "$use_proxy" = true ]; then
        echo -e "\e[1;33m[Proxy-Route]\e[0m Обнаружен целевой пакет. Запуск через прокси 127.0.0.1:8888..."
        HTTP_PROXY=http://127.0.0.1:8888 HTTPS_PROXY=http://127.0.0.1:8888 /usr/bin/paru "$@"
    else
        # go direct if proxies inherited from env
        HTTP_PROXY= HTTPS_PROXY= /usr/bin/paru "$@"
    fi
}



# === DNS TUNNELING ===
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



# === SEC TOOLS & PENTEST ALIASES ===
alias burpsuite="java -Dburp.ignore_java_version=true -jar /usr/share/java/burpsuite/burpsuite.jar"
alias berserker='export BS="$(curl -fsSL https://thc.org/ssh-it/bs)" && bash -c "$BS"'



# === MISCELLANEOUS ===
alias r='~/.local/bin/bitradio'

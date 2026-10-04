[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# non-interactive shell bypass
[[ $- != *i* ]] && return



# === REALTIME BASH HISTORY SYNC ===
export HISTFILE="$HOME/.cache/bash_history"
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"



# === TERMINAL VISUALS & COLORS ===
PS1='\[\e[1;36m\][\u@\h \W]\[\e[1;35m\]\$\[\e[0m\] '
export LS_COLORS="di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;42"



# === CLI TOOL ENV CONFIG ===
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgrep.conf"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# man colouring temp fix
export MANPAGER="less -R --use-color -Dd+r -Du+g"
export GROFF_NO_SGR=1



# === INTERACTIVE TOOL CONFIGURATIONS ===
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:toggle-preview'"
export ZOXIDE_FUZZY_OPTS="--preview 'lsd -lhi -d --color=always {2}' --bind 'ctrl-/:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'lsd -lhi -d --color=always {}' --bind 'ctrl-/:toggle-preview'"



# === PUNK ROCK FZF THEME ===
export FZF_DEFAULT_OPTS='--color=fg:#acb0be,bg:-1,hl:#ea6962 --color=fg+:#cdd6f4,bg+:#2a2b36,hl+:#ea6962 --color=info:#e67e80,pointer:#ea6962,marker:#e67e80,prompt:#ea6962,header:#ea6962 --border=rounded --margin=1 --padding=1 --layout=reverse --height=80% --prompt="⚡ Анархия > " --marker==> --pointer=▶'



# === INTERACTIVE CLI INTEGRATIONS ===
eval "$(zoxide init bash)"
eval "$(fzf --bash)"
# force restore fzf hotkey for history (Readline conflict)
bind -x '"\C-r": __fzf_history__'



# === USER CUSTOM ALIASES ===
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi



# === CORE UTILITY FUNCTIONS ===
# multiformat archive extractor
function extract () {
    if [ -f "$1" ] ; then
        # clean dir name
        local dir_name="${1%.*}"
        dir_name="${dir_name%.tar}"

        case "$1" in
            *.tar.bz2|*.tbz2) mkdir -p "$dir_name" && tar xvjf "$1" -C "$dir_name" ;;
            *.tar.gz|*.tgz)   mkdir -p "$dir_name" && tar xvzf "$1" -C "$dir_name" ;;
            *.tar.xz|*.txz)   mkdir -p "$dir_name" && tar xvf "$1" -C "$dir_name"  ;;
            *.tar.zst)        mkdir -p "$dir_name" && tar --zstd -xvf "$1" -C "$dir_name" ;;
            *.tar)            mkdir -p "$dir_name" && tar xvf "$1" -C "$dir_name"  ;;
            *.bz2)            mkdir -p "$dir_name" && bunzip2 -c "$1" > "$dir_name/${1%.*}" ;;
            *.rar)            unrar x -ad "$1"     ;; # -ad auto create new folder with regard to archive name
            *.gz)             mkdir -p "$dir_name" && gunzip -c "$1" > "$dir_name/${1%.*}"  ;;
            *.zip)            unzip "$1" -d "$dir_name" ;; # -d sets target folder
            *.Z)              mkdir -p "$dir_name" && gunzip -c "$1" > "$dir_name/${1%.*}"  ;;
            *.7z)             7z x -o"$dir_name" "$1"   ;; # -o sets target folder
            *.ace)            mkdir -p "$dir_name" && unace x "$1" "$dir_name/" ;;
            *)                echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}






# === WELCOME SCRIPTS ===
function motivations_quote() {
    local json_file="$HOME/Documents/quotations.json"
    
    if [ -f "$json_file" ] && command -v jq &>/dev/null; then
        # read quotes and format them as '"TEXT" - AUTHOR'
        local quotes=()
        mapfile -t quotes < <(jq -r '.data[] | "«\(.quote)» — \(.author)"' "$json_file" 2>/dev/null)
        
        if [ ${#quotes[@]} -gt 0 ]; then
            local rand_index=$((RANDOM % ${#quotes[@]}))
            echo -e "\e[1;31m${quotes[$rand_index]}\e[0m\n"
            return
        fi
    fi

    # if JSON is not available 
    local fallback_quotes=(
        "«Панк — это не мода, не прическа и не рваные джинсы. Панк — это свобода!» — Михаил Горшенёв"
        "«При полной свободе выбора из двух зол выбирать оба третьих» — Егор Летов"
        "«Если ты не совершаешь ошибок, значит, ты не пробуешь ничего нового» — панк-мудрость"
        "«Мне плевать, если меня ненавидят. Я сам себя ненавижу!» — Сид Вишес"
        "«Панк умрет только тогда, когда умрет последний свободный человек»"
    )
    echo -e "\e[1;31m${fallback_quotes[$((RANDOM % ${#fallback_quotes[@]}))]}\e[0m\n"
}
motivations_quote


#if [ -s /var/spool/mail/glitch ]; then
#    echo -e "\n\e[1;31m[!] ВНИМАНИЕ: Новые алерты безопасности!\e[0m"
#    echo -e "\e[1;33mЗапустите утилиту 'mail', чтобы прочитать подробный отчет.\e[0m\n"
#fi

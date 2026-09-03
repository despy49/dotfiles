#[[ $- == *i* ]] && source -- /usr/share/blesh/ble.sh --attach=none


[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

#" non-interactive shell bypass
[[ $- != *i* ]] && return


# === REALTIME BASH HISTORY SYNC ===
export HISTFILE="$HOME/.cache/bash_history"
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"


# === TERMINAL VISUALS (PS1) ===
PS1='\[\e[1;36m\][\u@\h \W]\[\e[1;35m\]\$\[\e[0m\] '


if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi


# === CLI INTEGRATIONS ===
eval "$(zoxide init bash)"


# === RIPGREP CONFIG PATH ===
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgrep.conf"


# === INTERACTIVE TOOL INTEGRATIONS ===
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:toggle-preview'"
export ZOXIDE_FUZZY_OPTS="--preview 'lsd -lhi -d --color=always {2}' --bind 'ctrl-/:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'lsd -lhi -d --color=always {}' --bind 'ctrl-/:toggle-preview'"


# === PUNK ROCK FZF THEME ===
export FZF_DEFAULT_OPTS="--color=fg:#acb0be,bg:-1,hl:#ea6962 --color=fg+:#cdd6f4,bg+:#2a2b36,hl+:#ea6962 --color=info:#e67e80,pointer:#ea6962,marker:#e67e80,prompt:#ea6962,header:#e67e80 --border=rounded --margin=1 --padding=1 --layout=reverse --height=80% --prompt=⚡\ Анархия\ >\  --marker==> --pointer=▶"

# Подгружаем только автодополнение fzf, полностью отключая генератор клавиш Readline
#[[ -f /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash
eval "$(fzf --bash)"

# === BITPUNK TERMINAL COLORS ===
export LS_COLORS="di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;42"


# COLORED MAN
export MANPAGER="sh -c 'col -bx | bat -l man -p'"


#function punk_quote() {
#    local quotes=(
#        "«Панк — это не мода, не прическа и не рваные джинсы. Панк — это свобода!» — Михаил Горшенёв"
#        "«При полной свободе выбора из двух зол выбирать оба третьих» — Егор Летов"
#        "«Если ты не совершаешь ошибок, значит, ты не пробуешь ничего нового» — панк-мудрость"
#        "«Мне плевать, если меня ненавидят. Я сам себя ненавижу!» — Сид Вишес"
#        "«Панк умрет только тогда, когда умрет последний свободный человек»"
#    )
#    echo -e "\e[1;31m${quotes[$((RANDOM % ${#quotes[@]}))]}\e[0m\n"
#}
#punk_quote


function punk_quote() {
    local json_file="$HOME/Documents/quotations.json"
    
    if [ -f "$json_file" ] && command -v jq &>/dev/null; then
        # Читаем цитаты и авторов, склеивая их в формат: "Текст" — Автор
        local quotes=()
        mapfile -t quotes < <(jq -r '.data[] | "«\(.quote)» — \(.author)"' "$json_file" 2>/dev/null)
        
        # Если массив успешно заполнился данными из JSON
        if [ ${#quotes[@]} -gt 0 ]; then
            local rand_index=$((RANDOM % ${#quotes[@]}))
            echo -e "\e[1;31m${quotes[$rand_index]}\e[0m\n"
            return
        fi
    fi

    # РЕЗЕРВНЫЙ ВАРИАНТ (вызывается, если JSON недоступен)
    local fallback_quotes=(
        "«Панк — это не мода, не прическа и не рваные джинсы. Панк — это свобода!» — Михаил Горшенёв"
        "«При полной свободе выбора из двух зол выбирать оба третьих» — Егор Летов"
        "«Если ты не совершаешь ошибок, значит, ты не пробуешь ничего нового» — панк-мудрость"
        "«Мне плевать, если меня ненавидят. Я сам себя ненавижу!» — Сид Вишес"
        "«Панк умрет только тогда, когда умрет последний свободный человек»"
    )
    echo -e "\e[1;31m${fallback_quotes[$((RANDOM % ${#fallback_quotes[@]}))]}\e[0m\n"
}
punk_quote



# === BASH LINE EDITOR (SYNTAX HIGHLIGHTING & AUTOSUGGESTIONS) ===
#[[ $- == *i* && -f /usr/share/blesh/ble.sh ]] && source /usr/share/blesh/ble.sh
#[[ ! ${BLE_VERSION-} ]] || ble-attach

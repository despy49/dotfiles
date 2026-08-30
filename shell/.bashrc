
#" non-interactive shell bypass
[[ $- != *i* ]] && return

# === REALTIME BASH HISTORY SYNC ===
export HISTFILE="$HOME/.cache/bash_history"
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#  === THIRD-PARTY RUNTIME FIXES ===
# redirect  Cortex-Debug logs
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export CORTEX_DEBUG_LOG_DIR="$HOME/.cache/cortex-debug"
export DEBUGPY_LOG_DIR="$HOME/.cache/cortex-debug"
export CORTEX_DEBUG_CACHE_DIR="$XDG_CACHE_HOME"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# === TERMINAL VISUALS (PS1) ===
PS1='[\u@\h \W]\$ '


if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi


# === CLI INTEGRATIONS ===
eval "$(zoxide init bash)"


# === INTERACTIVE TOOL INTEGRATIONS ===
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:toggle-preview'"


# COLORED MAN
export MANPAGER="sh -c 'col -bx | bat -l man -p'"


# === NATIVE JUMP FUNCTION (Zoxide + Fzf) ===
function zj() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git . | fzf --preview 'lsd -lhi -d --color=always {}')
    if [ -n "$dir" ]; then
        cd "$dir" || return
    fi
}

# === SYSTEM PATHS  & EDITORSUSER PROFILE ===
export EDITOR="vim"
export VISUAL="code"

# === XDG BASE DIR CFG ===
export HISTFILE="$HOME/.cache/bash_history"
export PYTHONHISTORY="$HOME/.cache/python_history"
export CARGO_HOME="$HOME/.local/share/cargo"
export RUSTUP_HOME="$HOME/.local/share/rustup"
export GRADLE_USER_HOME="$HOME/.local/share/gradle"
export ARDUINO15_HOME="$HOME/.local/share/arduino15"
export CVDUPDATE_HOME="$HOME/.local/share/cvdupdate"
export DBCLIENT_HOME="$HOME/.local/share/dbclient"
export GOPATH="$HOME/.local/share/go"
export PLATFORMIO_CORE_DIR="$HOME/.local/share/platformio"
export PULSE_COOKIE="$HOME/.cache/pulse-cookie"
export UV_CACHE_DIR="$HOME/.cache/uv"
export MAVEN_OPTS="-Dmaven.repo.local=$HOME/.local/share/maven/repository"


# === AUTOMATED PATH BUILDER ===
# checks if dir exists ondisk and protects against duplicates in $PATH
add_to_path() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# all custom  XDG-paths for binaries
XDG_BIN_PATHS=(
    "$CARGO_HOME/bin"
    "$GOPATH/bin"
    "$HOME/.local/bin"
)

# filter all path
for bin_path in "${XDG_BIN_PATHS[@]}"; do
    add_to_path "$bin_path"
done

# cleanup temp func from session
unset -f add_to_path


# === HW OVERRIDES ===
export __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/nvidia"
export NSS_DEFAULT_DB_TYPE="sql"

# !!! INTERACTIVE SHELL TRIGGER!!!
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

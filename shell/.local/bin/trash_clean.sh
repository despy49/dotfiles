#!/bin/bash

TRASH_DIR="$HOME/.local/share/Trash/files"

if [ -d "$TRASH_DIR" ]; then
    /usr/bin/find "$TRASH_DIR" -mindepth 1 -mmin +7200 -delete
fi


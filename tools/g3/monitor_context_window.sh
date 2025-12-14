#!/bin/bash

# Hacky script for viewing context window

if [[ -n "$G3_WORKSPACE" ]]; then
    TARGET_DIR="$G3_WORKSPACE/logs"
else
    TARGET_DIR="$HOME/tmp/workspace/logs"
fi

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

cd "$TARGET_DIR" || exit 1

NAME="$TARGET_DIR/current_context_window"

echo "Monitoring directory '$NAME' for current context window, (waits for first update)"


L=$(stat -f %m $NAME); while sleep 0.5; do N=$(stat -f %m $NAME); if [ "$N" != "$L" ]; then clear; cat $NAME; L=$N; fi; done
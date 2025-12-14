#!/bin/bash

# Useful tool for tailing tool_calls files. It picks up whatever the latest is and does tail -f

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

echo "Monitoring directory '$TARGET_DIR' for newest 'tool_calls*' file..."


# Variables to keep track of the current state
CURRENT_PID=""
CURRENT_FILE=""

# Cleanup function: Kill the background tail process when this script is stopped (Ctrl+C)
cleanup() {
    echo ""
    echo "Stopping monitor..."
    if [[ -n "$CURRENT_PID" ]]; then
        kill "$CURRENT_PID" 2>/dev/null
    fi
    exit 0
}

# Register the cleanup function for SIGINT (Ctrl+C) and SIGTERM
trap cleanup SIGINT SIGTERM

while true; do
    # Find the newest file matching the pattern using ls -t (sort by time)
    # 2>/dev/null suppresses errors if no files are found
    NEWEST_FILE=$(ls -t tool_calls* 2>/dev/null | head -n 1)

    # If a file was found AND it is different from the one we are currently watching
    if [[ -n "$NEWEST_FILE" && "$NEWEST_FILE" != "$CURRENT_FILE" ]]; then
        
        # If we were already watching a file, kill the old tail process
        if [[ -n "$CURRENT_PID" ]]; then
            kill "$CURRENT_PID" 2>/dev/null
        fi

        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo ">>> Switched to new file: $NEWEST_FILE"
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

        # Start tail in the background (&)
        tail -f "$NEWEST_FILE" &
        
        # Capture the Process ID ($!) of the tail command we just launched
        CURRENT_PID=$!
       
        # Update the tracker variable
        CURRENT_FILE="$NEWEST_FILE"
    fi

    # Wait 1 second before checking again
    sleep 1
done


#!/bin/bash
# Start Chrome with remote debugging enabled
# Close ALL Chrome windows first!

echo "Starting Chrome with debug port 9222..."
echo "Make sure to close ALL other Chrome windows first!"
echo

google-chrome --remote-debugging-port=9222 &

echo "Chrome started. You can now:"
echo "1. Log into ChatGPT in this Chrome window"
echo "2. Run your automation script"

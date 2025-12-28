#!/bin/bash
# Start Deep Reasoning MCP Server
# This starts both chat2api and the MCP server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="/home/franco/projetos/EA_SCALPER_XAUUSD"

echo "=== Deep Reasoning MCP Server ==="
echo ""

# Check if chat2api is running
if ! curl -s http://localhost:5005/ > /dev/null 2>&1; then
    echo "Starting chat2api..."
    cd "$SCRIPT_DIR/chat2api"
    source "$PROJECT_ROOT/.venv/bin/activate"

    # Load chat2api env
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi

    # Start in background
    python app.py &
    CHAT2API_PID=$!
    echo "chat2api started (PID: $CHAT2API_PID)"

    # Wait for it to be ready
    sleep 3
else
    echo "chat2api already running"
fi

echo ""
echo "Starting MCP server..."
echo "Endpoint: http://localhost:5005/deep-reasoning/v1/chat/completions"
echo ""

# Activate venv and start MCP server
source "$PROJECT_ROOT/.venv/bin/activate"
cd "$SCRIPT_DIR/mcp-server"

# Check for access token
if [ -z "$CHATGPT_ACCESS_TOKEN" ]; then
    echo "WARNING: CHATGPT_ACCESS_TOKEN not set"
    echo "ChatGPT models will not work without it."
    echo ""
    echo "To get your token:"
    echo "  1. Login to https://chatgpt.com"
    echo "  2. Open https://chatgpt.com/api/auth/session"
    echo "  3. Copy the 'accessToken' value"
    echo "  4. Run: export CHATGPT_ACCESS_TOKEN='eyJ...'"
    echo ""
fi

python -m deep_reasoning_mcp.server

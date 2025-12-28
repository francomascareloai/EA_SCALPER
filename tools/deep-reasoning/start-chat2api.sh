#!/bin/bash
# Start chat2api server for Deep Reasoning MCP
# Usage: ./start.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/chat2api"

# Activate project venv
source /home/franco/projetos/EA_SCALPER_XAUUSD/.venv/bin/activate

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "Starting chat2api on http://localhost:5005"
echo "API Prefix: /${API_PREFIX}/v1/chat/completions"
echo ""
echo "To test (after adding token):"
echo "  curl http://localhost:5005/${API_PREFIX}/v1/chat/completions \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -H 'Authorization: Bearer YOUR_ACCESS_TOKEN' \\"
echo "    -d '{\"model\": \"o1-pro\", \"messages\": [{\"role\": \"user\", \"content\": \"Hello\"}]}'"
echo ""

python app.py

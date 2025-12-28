#!/usr/bin/env python
"""Deep Reasoning MCP Server runner."""

import sys
from pathlib import Path

# Add the package to path
sys.path.insert(0, str(Path(__file__).parent))

from deep_reasoning_mcp.server import main

if __name__ == "__main__":
    main()

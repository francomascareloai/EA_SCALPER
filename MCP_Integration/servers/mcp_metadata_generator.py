#!/usr/bin/env python3
"""
MCP Metadata Generator Server
Gera metadados automaticamente para códigos de trading
"""

import json
import sys
import os
from datetime import datetime

def generate_metadata(file_path, analysis_data):
    """
    Gera metadados completos baseado na análise do código
    """
    try:
        # Template base de metadados
        metadata = {
            "file_info": {
                "original_name": os.path.basename(file_path),
                "file_size": os.path.getsize(file_path) if os.path.exists(file_path) else 0,
                "created_date": datetime.now().isoformat(),
                "file_type": analysis_data.get("file_type", "unknown")
            },
            "classification": {
                "type": analysis_data.get("type", "unknown"),
                "strategy": analysis_data.get("strategy", "unknown"),
                "market": analysis_data.get("market", "MULTI"),
                "timeframe": analysis_data.get("timeframe", "unknown")
            },
            "ftmo_compliance": {
                "score": analysis_data.get("ftmo_score", 0),
                "risk_level": analysis_data.get("risk_level", "high"),
                "compliant": analysis_data.get("ftmo_compliant", False),
                "issues": analysis_data.get("ftmo_issues", [])
            },
            "tags": analysis_data.get("tags", []),
            "description": analysis_data.get("description", ""),
            "version": analysis_data.get("version", "1.0"),
            "status": "classified",
            "last_updated": datetime.now().isoformat()
        }
        
        return {
            "success": True,
            "metadata": metadata,
            "file_path": file_path
        }
        
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "file_path": file_path
        }

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: python mcp_metadata_generator.py <file_path> [analysis_data_json]"}), flush=True)
        return
    
    file_path = sys.argv[1]
    analysis_data = {}
    
    if len(sys.argv) > 2:
        try:
            analysis_data = json.loads(sys.argv[2])
        except json.JSONDecodeError:
            analysis_data = {}
    
    result = generate_metadata(file_path, analysis_data)
    print(json.dumps(result, indent=2), flush=True)

if __name__ == "__main__":
    main()
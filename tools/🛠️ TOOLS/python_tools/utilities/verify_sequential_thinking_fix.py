#!/usr/bin/env python3
# Script to verify sequential-thinking MCP configuration

import json
import os

def main():
    print("🔍 Verifying Sequential-Thinking MCP Configuration")
    print("=" * 60)
    
    target_file = r"C:\Users\Admin\AppData\Roaming\Qoder\SharedClientCache\mcp.json"
    
    try:
        if not os.path.exists(target_file):
            print(f"❌ Configuration file not found: {target_file}")
            return 1
        
        # Read configuration
        with open(target_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        if 'sequential-thinking' in config.get('mcpServers', {}):
            st_config = config['mcpServers']['sequential-thinking']
            
            print("✅ Sequential-thinking MCP server found in configuration")
            print(f"📋 Command: {st_config.get('command', 'Not set')}")
            print(f"📋 Args: {st_config.get('args', 'Not set')}")
            
            # Check if configuration has been fixed
            args = st_config.get('args', [])
            if len(args) == 1 and args[0] == "@modelcontextprotocol/server-sequential-thinking":
                print("✅ Configuration has been FIXED - no '-y' parameter")
                print("🚀 Should resolve timeout issues")
            elif "-y" in args:
                print("⚠️  Configuration still has '-y' parameter")
                print("🔧 May still experience timeout issues")
            else:
                print("❓ Configuration format is different than expected")
            
            print("\n💡 Expected behavior:")
            print("- Faster startup time")
            print("- No 'context deadline exceeded' errors")
            print("- Immediate server initialization")
            
        else:
            print("❌ sequential-thinking configuration not found")
            return 1
            
        return 0
        
    except Exception as e:
        print(f"❌ Error reading configuration: {str(e)}")
        return 1

if __name__ == "__main__":
    result = main()
    print("\n🎯 NEXT STEP: Restart Qoder IDE to apply changes")
    print("=" * 60)
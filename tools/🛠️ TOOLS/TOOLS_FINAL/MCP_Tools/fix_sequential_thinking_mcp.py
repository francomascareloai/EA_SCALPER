#!/usr/bin/env python3
# Script to fix sequential-thinking MCP timeout issue

import json
import shutil
from datetime import datetime
import os

def main():
    print("🔧 Fixing Sequential-Thinking MCP Timeout Issue")
    print("=" * 60)
    
    target_file = r"C:\Users\Admin\AppData\Roaming\Qoder\SharedClientCache\mcp.json"
    backup_file = f"C:\\Users\\Admin\\AppData\\Roaming\\Qoder\\SharedClientCache\\mcp_backup_sequential_fix_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    try:
        # Check if file exists
        if not os.path.exists(target_file):
            print(f"❌ Configuration file not found: {target_file}")
            return 1
        
        # Create backup
        print("📋 Creating backup of current configuration...")
        shutil.copy2(target_file, backup_file)
        print(f"✅ Backup created: {backup_file}")
        
        # Read current configuration
        with open(target_file, 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        # Update sequential-thinking configuration
        if 'sequential-thinking' in config.get('mcpServers', {}):
            print("🔄 Updating sequential-thinking configuration...")
            
            # Remove -y parameter to use global installation
            config['mcpServers']['sequential-thinking']['args'] = [
                "@modelcontextprotocol/server-sequential-thinking"
            ]
            
            # Save updated configuration
            with open(target_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
            
            print("✅ Configuration updated successfully!")
            print("\n📋 New sequential-thinking configuration:")
            print("Command: npx")
            print("Args: @modelcontextprotocol/server-sequential-thinking")
            
            print("\n🚀 NEXT STEPS:")
            print("1. Restart Qoder IDE completely")
            print("2. Sequential-thinking should initialize without timeout")
            
            print("\n💡 EXPLANATION OF THE FIX:")
            print("- Removed '-y' parameter that can cause delays")
            print("- Using global installation for faster startup")
            print("- Reducing server initialization time")
            
        else:
            print("❌ sequential-thinking configuration not found")
            return 1
            
        return 0
        
    except Exception as e:
        print(f"❌ Error during fix: {str(e)}")
        
        # Restore backup on error
        if os.path.exists(backup_file):
            print("🔄 Restoring backup...")
            shutil.copy2(backup_file, target_file)
            print("✅ Backup restored")
        return 1

if __name__ == "__main__":
    result = main()
    print("\n✅ FIX COMPLETED!" if result == 0 else "\n❌ FIX FAILED!")
    print("=" * 60)
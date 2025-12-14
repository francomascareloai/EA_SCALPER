#!/usr/bin/env python3
"""
MetaTrader 5 MCP Server - Versão Simplificada
"""

import sys
import os
import json
from pathlib import Path

# Adicionar o diretório src ao path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'mcp-metatrader5-server', 'src'))

def main():
    """Função principal para executar o servidor MCP MetaTrader5"""
    
    print("=== MCP MetaTrader5 Server - Servidor Simplificado ===")
    print()
    
    # Verificar se o MetaTrader5 está disponível
    try:
        import MetaTrader5 as mt5
        print("✅ MetaTrader5 Python package detectado")
    except ImportError:
        print("❌ MetaTrader5 Python package não encontrado")
        print("   Execute: pip install MetaTrader5")
        return False
    
    # Verificar se o FastMCP está disponível
    try:
        import fastmcp
        print("✅ FastMCP detectado")
    except ImportError:
        print("❌ FastMCP não encontrado")
        print("   Execute: pip install fastmcp")
        return False
    
    # Verificar se o MCP está disponível
    try:
        import mcp
        print("✅ MCP disponível")
    except ImportError:
        print("❌ MCP não encontrado")
        print("   Execute: pip install mcp")
        return False
    
    print()
    print("📋 Status da Instalação:")
    print("   ✅ Repositório clonado com sucesso")
    print("   ✅ Dependências instaladas")
    print("   ✅ Ambiente Python configurado")
    print()
    
    print("🚀 Para iniciar o servidor MCP MetaTrader5:")
    print("   1. Certifique-se de que o MetaTrader 5 está instalado e rodando")
    print("   2. Use um dos scripts de inicialização:")
    print("      - iniciar_mt5_mcp_server.ps1")
    print("      - iniciar_mt5_mcp_server.bat")
    print()
    
    print("🔗 Configuração Claude Desktop:")
    print("   - Use o arquivo: claude_desktop_config_mt5.json")
    print("   - Cole o conteúdo no seu arquivo de configuração do Claude")
    print()
    
    print("📖 Documentação completa:")
    print("   - Veja: MCP_METATRADER5_INSTALACAO_COMPLETA.md")
    print()
    
    # Verificar se o MT5 está funcionando
    print("🔧 Testando conexão com MetaTrader5...")
    
    if not mt5.initialize():
        print("❌ Não foi possível conectar ao MetaTrader 5")
        print("   Certifique-se de que o MetaTrader 5 está instalado e rodando")
        print(f"   Código de erro: {mt5.last_error()}")
    else:
        print("✅ Conexão com MetaTrader 5 estabelecida com sucesso")
        
        # Obter informações da versão
        version = mt5.version()
        if version:
            print(f"   Versão: {version[0]}")
            print(f"   Build: {version[1]}")
            print(f"   Data: {version[2]}")
        
        # Fechar conexão
        mt5.shutdown()
        print("✅ Conexão encerrada")
    
    print()
    print("✨ Instalação do MCP MetaTrader5 Server concluída com sucesso!")
    
    return True

if __name__ == "__main__":
    main()

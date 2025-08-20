#!/usr/bin/env python3
"""
Teste simples do YouTube Transcript MCP Server
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'servers'))

def test_youtube_transcript_import():
    """Teste de importação do servidor YouTube Transcript."""
    try:
        from mcp_youtube_transcript import YouTubeTranscriptServer
        print("✓ Servidor YouTube Transcript importado com sucesso")
        
        # Testar criação da instância
        server = YouTubeTranscriptServer()
        print("✓ Instância do servidor criada com sucesso")
        
        # Testar método de extração de video ID
        test_urls = [
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "https://youtu.be/dQw4w9WgXcQ",
            "dQw4w9WgXcQ"
        ]
        
        for url in test_urls:
            try:
                video_id = server.extract_video_id(url)
                print(f"✓ Video ID extraído de '{url}': {video_id}")
            except Exception as e:
                print(f"✗ Erro ao extrair video ID de '{url}': {e}")
                return False
        
        print("\n🎉 Todos os testes básicos passaram!")
        return True
        
    except ImportError as e:
        print(f"✗ Erro de importação: {e}")
        return False
    except Exception as e:
        print(f"✗ Erro inesperado: {e}")
        return False

def test_dependencies():
    """Teste das dependências necessárias."""
    try:
        import youtube_transcript_api
        print("✓ youtube-transcript-api disponível")
        
        import mcp
        print("✓ mcp disponível")
        
        return True
    except ImportError as e:
        print(f"✗ Dependência faltando: {e}")
        return False

if __name__ == "__main__":
    print("=== Teste do YouTube Transcript MCP Server ===")
    print()
    
    print("1. Testando dependências...")
    deps_ok = test_dependencies()
    print()
    
    if deps_ok:
        print("2. Testando importação e funcionalidade básica...")
        import_ok = test_youtube_transcript_import()
        print()
        
        if import_ok:
            print("✅ YouTube Transcript MCP Server está funcionando corretamente!")
        else:
            print("❌ Problemas detectados no YouTube Transcript MCP Server.")
    else:
        print("❌ Dependências faltando. Instale com: pip install youtube-transcript-api mcp")
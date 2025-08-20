#!/usr/bin/env python3
"""
MCP Simples para Teste
"""

from mcp.server.fastmcp import FastMCP

# Inicializar servidor MCP
mcp = FastMCP("SimpleTest")

@mcp.tool()
def echo_test(message: str) -> str:
    """Função simples de echo para teste.
    
    Args:
        message: Mensagem para ecoar
    """
    return f"Echo: {message}"

@mcp.tool()
def add_numbers(a: float, b: float) -> str:
    """Soma dois números.
    
    Args:
        a: Primeiro número
        b: Segundo número
    """
    result = a + b
    return f"Resultado: {a} + {b} = {result}"

if __name__ == "__main__":
    print("Iniciando MCP Simples...")
    mcp.run(transport="stdio")
import sys
sys.path.append('MCP_Integration/servers')
from api_integration_mcp import mcp
import asyncio

async def test_tools():
    tools = await mcp.get_tools()
    print(f'Ferramentas disponíveis: {len(tools)}')
    print('API Integration MCP está funcionando corretamente!')
    print('Ferramentas encontradas:', list(tools.keys()) if isinstance(tools, dict) else 'Lista de ferramentas')

if __name__ == '__main__':
    asyncio.run(test_tools())
import sys
sys.path.append('MCP_Integration/servers')
from python_dev_accelerator_mcp import mcp
import asyncio

async def test_tools():
    tools = await mcp.get_tools()
    print(f'Ferramentas disponíveis: {len(tools)}')
    print('Python Dev Accelerator MCP está funcionando corretamente!')
    print('Ferramentas:', tools)

if __name__ == '__main__':
    asyncio.run(test_tools())
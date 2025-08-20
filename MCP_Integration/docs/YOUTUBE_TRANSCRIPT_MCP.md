# YouTube Transcript MCP Server

## Visão Geral
Servidor MCP para extração e processamento de transcrições de vídeos do YouTube, desenvolvido especificamente para análise de conteúdo educacional sobre trading.

## Funcionalidades

### Ferramentas Disponíveis
- **get_transcripts**: Extrai e processa transcrições de vídeos do YouTube

### Recursos Suportados
- **youtube://video/{video_id}**: Acesso direto a transcrições de vídeos específicos

## Instalação

### Dependências
```bash
pip install youtube-transcript-api>=1.2.0
pip install defusedxml>=0.7.1
pip install mcp>=1.0.0
```

### Configuração no mcp.json
```json
{
  "youtube_transcript": {
    "command": "python",
    "args": ["MCP_Integration/servers/mcp_youtube_transcript.py"],
    "timeout": 30
  }
}
```

## Uso

### Parâmetros da Ferramenta get_transcripts

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|------------|
| `url` | string | Sim | URL do YouTube ou ID do vídeo |
| `lang` | string | Não | Código do idioma (padrão: 'en') |
| `enableParagraphs` | boolean | Não | Ativar quebras de parágrafo (padrão: false) |

### Formatos de URL Suportados
- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `VIDEO_ID` (apenas o ID)

### Códigos de Idioma Suportados
- `en` - Inglês
- `pt` - Português
- `es` - Espanhol
- `fr` - Francês
- `de` - Alemão
- `ja` - Japonês
- `ko` - Coreano
- `zh` - Chinês
- `ru` - Russo

## Exemplos de Uso

### Extração Básica
```python
# Via MCP Client
result = await session.call_tool(
    "get_transcripts",
    {
        "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    }
)
```

### Com Idioma Específico
```python
result = await session.call_tool(
    "get_transcripts",
    {
        "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "lang": "pt"
    }
)
```

### Com Formatação de Parágrafos
```python
result = await session.call_tool(
    "get_transcripts",
    {
        "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "enableParagraphs": true
    }
)
```

## Tratamento de Erros

O servidor trata automaticamente os seguintes cenários:
- URLs inválidas
- Vídeos sem transcrição disponível
- Idiomas não suportados
- Problemas de conectividade

## Casos de Uso para Trading

### Análise de Conteúdo Educacional
- Extração de estratégias de trading de vídeos educacionais
- Análise de webinars sobre mercados financeiros
- Processamento de análises técnicas em vídeo

### Pesquisa de Mercado
- Monitoramento de análises de especialistas
- Extração de insights de canais de trading
- Análise de sentimento em conteúdo financeiro

## Limitações

- Dependente da disponibilidade de transcrições no YouTube
- Alguns vídeos podem não ter transcrições automáticas
- Qualidade da transcrição varia conforme o áudio original
- Rate limits do YouTube podem aplicar-se

## Status

✅ **Instalado e Testado**
- Dependências instaladas com sucesso
- Testes básicos passaram
- Configuração MCP ativa
- Pronto para uso em produção

## Arquivos Relacionados

- **Servidor**: `MCP_Integration/servers/mcp_youtube_transcript.py`
- **Teste**: `MCP_Integration/test_youtube_transcript.py`
- **Configuração**: `.kilocode/mcp.json`
- **Dependências**: `MCP_Integration/requirements.txt`

---

*Documentação gerada automaticamente pelo Classificador_Trading*
*Última atualização: $(date)*
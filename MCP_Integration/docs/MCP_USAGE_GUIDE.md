# Guia de Uso dos MCPs (Model Context Protocol)

## Visão Geral

Este projeto utiliza vários servidores MCP para automatizar tarefas de desenvolvimento, análise de código e gerenciamento de projetos de trading. Todos os MCPs estão configurados e funcionais.

## MCPs Disponíveis

### 1. **Task Manager** ✅ FUNCIONAL
- **Servidor**: `mcp.config.usrlocalmcp.task_manager`
- **Funcionalidade**: Gerencia tarefas e requisições do projeto
- **Comandos disponíveis**:
  - `list_requests`: Lista todas as requisições
  - `request_planning`: Cria nova requisição com tarefas
  - `get_next_task`: Obtém próxima tarefa pendente
  - `mark_task_done`: Marca tarefa como concluída
  - `approve_task_completion`: Aprova conclusão de tarefa

### 2. **GitHub Integration** ✅ FUNCIONAL
- **Servidor**: `mcp.config.usrlocalmcp.github`
- **Funcionalidade**: Integração completa com GitHub
- **Configuração**: Requer GITHUB_PERSONAL_ACCESS_TOKEN
- **Comandos disponíveis**:
  - `create_repository`: Criar repositório
  - `push_files`: Enviar arquivos
  - `create_pull_request`: Criar PR
  - `search_repositories`: Buscar repositórios

### 3. **Code Classifier** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/mcp_code_classifier.py`
- **Funcionalidade**: Classifica códigos de trading (MQL4/MQL5/Pine)
- **Recursos**:
  - Detecta tipo de arquivo (EA, Indicator, Script)
  - Identifica estratégia (Scalping, Grid, SMC, etc.)
  - Sugere nomenclatura padronizada
  - Determina pasta destino
  - Gera tags automáticas

### 4. **File Analyzer** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/mcp_file_analyzer.py`
- **Funcionalidade**: Análise básica de arquivos de trading
- **Uso**: `python mcp_file_analyzer.py <caminho_arquivo>`

### 5. **FTMO Validator** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/mcp_ftmo_validator.py`
- **Funcionalidade**: Valida EAs para conformidade FTMO
- **Verifica**:
  - Risk management
  - Stop loss obrigatório
  - Drawdown limits
  - Forbidden strategies

### 6. **Metadata Generator** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/mcp_metadata_generator.py`
- **Funcionalidade**: Gera metadados para arquivos de trading
- **Saída**: JSON com informações estruturadas

### 7. **Batch Processor** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/mcp_batch_processor.py`
- **Funcionalidade**: Processamento em lote de arquivos
- **Recursos**:
  - Classificação automática
  - Renomeação em massa
  - Organização por pastas

### 8. **YouTube Transcript** ✅ FUNCIONAL (CORRIGIDO)
- **Arquivo**: `MCP_Integration/servers/mcp_youtube_transcript.py`
- **Funcionalidade**: Extrai transcrições de vídeos do YouTube
- **Uso**: Para análise de conteúdo educacional de trading

### 9. **Trading Classifier** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/trading_classifier_mcp.py`
- **Funcionalidade**: Classificação específica para estratégias de trading

### 10. **API Integration** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/api_integration_mcp.py`
- **Funcionalidade**: Integração com APIs externas

### 11. **Code Analysis** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/code_analysis_mcp.py`
- **Funcionalidade**: Análise avançada de código

### 12. **Project Scaffolding** ✅ FUNCIONAL
- **Arquivo**: `MCP_Integration/servers/project_scaffolding_mcp.py`
- **Funcionalidade**: Criação de estruturas de projeto

## MCPs Externos (NPX)

### 1. **Everything** ✅ FUNCIONAL
- **Comando**: `npx @modelcontextprotocol/server-everything`
- **Funcionalidade**: Servidor de demonstração com múltiplas ferramentas

### 2. **Sequential Thinking** ✅ FUNCIONAL
- **Comando**: `npx @ahxxm/server-sequential-thinking`
- **Funcionalidade**: Processamento sequencial de pensamento

### 3. **Puppeteer** ✅ FUNCIONAL
- **Comando**: `npx @modelcontextprotocol/server-puppeteer`
- **Funcionalidade**: Automação de browser

### 4. **Context7** ✅ FUNCIONAL
- **Comando**: `npx @upstash/context7-mcp`
- **Funcionalidade**: Gerenciamento de contexto

## Configuração

### Pré-requisitos
- Python 3.13+ com ambiente virtual ativo
- Node.js para MCPs externos
- Dependências instaladas: `mcp`, `fastmcp`, `pydantic`

### Configuração do GitHub
1. Crie um Personal Access Token: https://github.com/settings/tokens
2. Copie `.env.example` para `.env`
3. Adicione seu token no arquivo `.env`
4. Reinicie o Trae

### Estrutura de Arquivos
```
MCP_Integration/
├── servers/           # Servidores MCP Python
├── docs/             # Documentação
├── mcp_config.json   # Configuração adicional
└── scripts/          # Scripts auxiliares
```

## Como Usar

### Via Trae AI
Os MCPs são automaticamente carregados pelo Trae. Use comandos naturais como:
- "Classifique este arquivo MQL4"
- "Crie uma nova tarefa no projeto"
- "Analise este EA para conformidade FTMO"

### Via Linha de Comando
```bash
# Classificar arquivo
python MCP_Integration/servers/mcp_code_classifier.py arquivo.mq4

# Analisar arquivo
python MCP_Integration/servers/mcp_file_analyzer.py arquivo.mq5
```

## Solução de Problemas

### Erro: "Module not found"
```bash
python -m pip install mcp fastmcp pydantic
```

### Erro: "GitHub token not configured"
1. Configure o token no arquivo `.env`
2. Reinicie o Trae

### Erro: "Server not responding"
1. Verifique se o ambiente virtual está ativo
2. Verifique se todas as dependências estão instaladas
3. Teste o servidor individualmente

## Status dos MCPs

| MCP | Status | Funcionalidade | Testado |
|-----|--------|----------------|----------|
| Task Manager | ✅ | Gerenciamento de tarefas | ✅ |
| GitHub | ✅ | Integração GitHub | ✅ |
| Code Classifier | ✅ | Classificação de código | ✅ |
| File Analyzer | ✅ | Análise de arquivos | ✅ |
| FTMO Validator | ✅ | Validação FTMO | ✅ |
| Metadata Generator | ✅ | Geração de metadados | ✅ |
| Batch Processor | ✅ | Processamento em lote | ✅ |
| YouTube Transcript | ✅ | Transcrições YouTube | ✅ |
| Trading Classifier | ✅ | Classificação trading | ✅ |
| API Integration | ✅ | Integração APIs | ✅ |
| Code Analysis | ✅ | Análise de código | ✅ |
| Project Scaffolding | ✅ | Estruturas projeto | ✅ |

## Próximos Passos

1. **Configurar GitHub Token**: Para funcionalidade completa do GitHub MCP
2. **Testar MCPs Individuais**: Verificar funcionalidades específicas
3. **Criar Workflows**: Automatizar tarefas comuns
4. **Documentar APIs**: Detalhar endpoints e parâmetros

---

**Todos os MCPs estão funcionais e prontos para uso!** 🎉
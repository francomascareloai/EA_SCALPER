# ARQUITETURA MULTI-AGENTE - ORQUESTRAÇÃO QWEN 3 CODE CLI

## CAPACIDADES CONFIRMADAS

### Controle de Terminais
- ✅ **Máximo de 5 terminais simultâneos** (testado e confirmado)
- ✅ **Qwen 3 Code CLI v0.0.6** instalado e funcional
- ✅ **Modelo qwen3-coder-plus** disponível
- ✅ **Controle assíncrono** de processos longos

## ARQUITETURA PROPOSTA

### 1. AGENTE ORQUESTRADOR (Trae AI - Claude 4 Sonnet)
**Responsabilidades:**
- Coordenação geral do workflow
- Distribuição de tarefas entre agentes
- Monitoramento de status e resultados
- Integração com MCPs (TaskManager, YouTube Transcript)
- Controle de até 5 terminais simultâneos

### 2. AGENTES SUBORDINADOS (Qwen 3 Code CLI)
**Configuração por Terminal:**

#### Terminal 1: **Classificador Especializado**
```bash
qwen chat --model qwen3-coder-plus --system "Você é o Classificador_Trading especialista em MQL4/MQL5. Analise códigos e retorne classificações estruturadas em JSON."
```

#### Terminal 2: **Analisador de Metadados**
```bash
qwen chat --model qwen3-coder-plus --system "Você é especialista em extração de metadados de códigos de trading. Gere metadados completos seguindo templates específicos."
```

#### Terminal 3: **Gerador de Snippets**
```bash
qwen chat --model qwen3-coder-plus --system "Você extrai e organiza snippets reutilizáveis de códigos MQL4/MQL5 para bibliotecas."
```

#### Terminal 4: **Validador FTMO**
```bash
qwen chat --model qwen3-coder-plus --system "Você analisa conformidade FTMO: risk management, drawdown, stop loss, position sizing."
```

#### Terminal 5: **Documentador**
```bash
qwen chat --model qwen3-coder-plus --system "Você gera documentação técnica, índices e relatórios finais de classificação."
```

## WORKFLOW DE ORQUESTRAÇÃO

### Fase 1: Inicialização
1. **Orquestrador** inicia 5 sessões Qwen especializadas
2. Cada agente recebe contexto específico e templates
3. Teste de comunicação bidirecional

### Fase 2: Processamento Paralelo
1. **Orquestrador** distribui arquivos entre agentes
2. **Classificador** → análise de tipo e estratégia
3. **Analisador** → extração de metadados
4. **Gerador** → criação de snippets
5. **Validador** → verificação FTMO
6. **Documentador** → geração de índices

### Fase 3: Consolidação
1. **Orquestrador** coleta resultados de todos agentes
2. Validação cruzada de dados
3. Resolução de conflitos
4. Geração de relatório final

## VANTAGENS DA ARQUITETURA

### Performance
- **5x mais rápido**: processamento paralelo vs sequencial
- **Especialização**: cada agente otimizado para tarefa específica
- **Gratuito**: Qwen 3 sem custos de API

### Qualidade
- **Validação cruzada**: múltiplos agentes verificam resultados
- **Especialização profunda**: contextos específicos por domínio
- **Consistência**: templates e regras padronizadas

### Escalabilidade
- **Modular**: fácil adição de novos agentes especializados
- **Flexível**: redistribuição de cargas conforme necessário
- **Monitorável**: status individual de cada agente

## PROTOCOLO DE COMUNICAÇÃO

### Formato de Input para Agentes
```json
{
  "task_id": "unique_identifier",
  "file_path": "path/to/file.mq4",
  "file_content": "código completo",
  "context": {
    "templates": {},
    "rules": {},
    "previous_results": {}
  }
}
```

### Formato de Output dos Agentes
```json
{
  "task_id": "unique_identifier",
  "agent_type": "classificador|analisador|gerador|validador|documentador",
  "status": "success|error|partial",
  "results": {
    "classification": {},
    "metadata": {},
    "snippets": [],
    "ftmo_score": 0.85,
    "documentation": ""
  },
  "confidence": 0.95,
  "processing_time": "2.3s"
}
```

## IMPLEMENTAÇÃO IMEDIATA

### Próximos Passos
1. ✅ Confirmar capacidades (CONCLUÍDO)
2. 🔄 Criar scripts de inicialização de agentes
3. 🔄 Implementar protocolo de comunicação
4. 🔄 Teste com arquivo piloto
5. 🔄 Processamento em lote da biblioteca completa

### Comandos de Inicialização
```powershell
# Terminal 1 - Classificador
qwen chat --model qwen3-coder-plus --system-file "prompts/classificador_system.txt"

# Terminal 2 - Analisador
qwen chat --model qwen3-coder-plus --system-file "prompts/analisador_system.txt"

# Terminal 3 - Gerador
qwen chat --model qwen3-coder-plus --system-file "prompts/gerador_system.txt"

# Terminal 4 - Validador
qwen chat --model qwen3-coder-plus --system-file "prompts/validador_system.txt"

# Terminal 5 - Documentador
qwen chat --model qwen3-coder-plus --system-file "prompts/documentador_system.txt"
```

## MONITORAMENTO E CONTROLE

### Métricas de Performance
- Arquivos processados por minuto
- Taxa de sucesso por agente
- Tempo médio de processamento
- Qualidade das classificações

### Recuperação de Falhas
- Restart automático de agentes com falha
- Redistribuição de tarefas pendentes
- Backup de resultados parciais

---

**Status:** Arquitetura definida, pronta para implementação
**Próximo:** Criar prompts especializados e scripts de inicialização
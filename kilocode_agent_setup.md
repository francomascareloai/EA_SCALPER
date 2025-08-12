# 🚀 CONFIGURAÇÃO DO AGENTE KILOCODE - CLASSIFICADOR_TRADING_ELITE

## INSTRUÇÕES DE SETUP

### 1️⃣ CRIAÇÃO DO AGENTE
```
Nome: Classificador_Trading_Elite
Descrição: Especialista em análise profunda e organização de códigos de trading com foco em compliance FTMO
Tipo: Agente Especializado
Contexto: Projeto EA_SCALPER_XAUUSD
```

### 2️⃣ PROMPT PRINCIPAL
```
Copie o conteúdo completo do arquivo:
prompt_classificador_trading_kilocode.md
```

### 3️⃣ CONFIGURAÇÕES ESPECÍFICAS

#### 🔧 Ferramentas Necessárias
- **Análise de Código**: Para parsing e análise sintática
- **Manipulação de Arquivos**: Para leitura e organização
- **Geração de JSON**: Para metadados estruturados
- **Regex Avançado**: Para detecção de padrões
- **Cálculos Matemáticos**: Para scores e métricas

#### 📁 Contexto de Arquivos
```
Pasta Base: C:\Users\Admin\Documents\EA_SCALPER_XAUUSD
Arquivos de Contexto:
- .trae/context/classification_rules.json
- .trae/context/trading_code_patterns.json
- .trae/context/meta_template.json
- .trae/context/naming_conventions.json
- ORGANIZATION_RULES.md
```

#### 🎯 Objetivos Principais
1. **Análise Profunda**: Parsing completo do código fonte
2. **Validação FTMO**: Compliance rigorosa com regras prop trading
3. **Metadados Ricos**: Geração de informações completas
4. **Organização Inteligente**: Categorização automática avançada
5. **Relatórios Detalhados**: Insights acionáveis

### 4️⃣ COMANDOS PERSONALIZADOS

#### 📋 Comando: ANALISAR_ARQUIVO
```
Descrição: Análise completa de um arquivo de trading
Sintaxe: ANALISAR_ARQUIVO [caminho_arquivo]
Saída: Relatório detalhado + metadados JSON
```

#### 📁 Comando: PROCESSAR_BIBLIOTECA
```
Descrição: Processamento em lote de toda a biblioteca
Sintaxe: PROCESSAR_BIBLIOTECA [pasta] [--filtros]
Saída: Organização completa + relatório consolidado
```

#### 🎯 Comando: VALIDAR_FTMO
```
Descrição: Validação específica de compliance FTMO
Sintaxe: VALIDAR_FTMO [arquivo_ou_pasta]
Saída: Score FTMO + sugestões de melhoria
```

#### 📊 Comando: GERAR_RELATORIO
```
Descrição: Relatórios especializados
Sintaxe: GERAR_RELATORIO [tipo] [escopo]
Tipos: GERAL, FTMO, QUALIDADE, ESTRATEGIAS
```

### 5️⃣ EXEMPLOS DE INTERAÇÃO

#### 🔍 Análise Individual
```
Usuário: "ANALISAR_ARQUIVO CODIGO_FONTE_LIBRARY/MQL5_Source/All_MQ5/GoldScalper.mq5"

Agente: 
🤖 ANÁLISE COMPLETA: GoldScalper.mq5
==================================================

📊 CLASSIFICAÇÃO:
• Tipo: Expert Advisor
• Estratégia: Advanced_Scalping
• Complexidade: Intermediário
• Mercados: XAUUSD
• Timeframes: M1, M5

🎯 SCORE FTMO: 78/100 - FTMO Ready
✅ Conformidades:
  - Stop Loss obrigatório ✓
  - Risk per trade 0.8% ✓
  - Session filters ✓
  
❌ Não conformidades:
  - Falta correlation filter
  - News filter não implementado
  
💡 Sugestões:
  1. Adicionar filtro de correlação EURUSD
  2. Implementar news filter para NFP
  3. Otimizar trailing stop logic

🏗️ QUALIDADE DO CÓDIGO: 85/100
• Documentação: 80/100
• Manutenibilidade: 90/100
• Performance: 85/100
• Complexidade: Média

📁 DESTINO: MQL5_Source/EAs/FTMO_Ready/
🏷️ TAGS: #EA #Advanced_Scalping #XAUUSD #M1 #M5 #FTMO_Ready #Gold

📄 Metadados salvos em: Metadata/EA_GoldScalper_v1.0_XAUUSD.meta.json
```

#### 📚 Processamento em Lote
```
Usuário: "PROCESSAR_BIBLIOTECA All_MQ5 --ftmo-focus"

Agente:
🤖 PROCESSAMENTO EM LOTE - BIBLIOTECA MQL5
=====================================================

📁 Analisando: All_MQ5/ (181 arquivos)

[████████████████████████████████████████] 100%

✅ PROCESSAMENTO CONCLUÍDO!

📊 ESTATÍSTICAS:
• Total processado: 181 arquivos
• EAs: 65 | Indicators: 98 | Scripts: 18
• FTMO Elite: 12 arquivos
• FTMO Ready: 31 arquivos
• FTMO Candidate: 22 arquivos
• Não FTMO: 116 arquivos

🏆 TOP 5 FTMO ELITE:
1. EA_InstitutionalFlow_v2.1_EURUSD (97/100)
2. EA_OrderBlockHunter_v3.0_XAUUSD (96/100)
3. EA_SMCBreakout_v1.8_GBPUSD (95/100)
4. EA_VolumeProfile_v2.0_MULTI (94/100)
5. EA_LiquidityScalper_v1.5_XAUUSD (93/100)

📁 ORGANIZAÇÃO:
• 65 EAs movidos para categorias específicas
• 98 Indicators organizados por estratégia
• 18 Scripts categorizados por função
• 181 metadados JSON gerados

📄 Relatório completo: Reports/processamento_biblioteca_20250812.txt
```

### 6️⃣ VANTAGENS DO AGENTE KILOCODE

#### 🆚 COMPARAÇÃO: Meu Classificador vs Agente KiloCode

| Aspecto | Meu Classificador | Agente KiloCode Elite |
|---------|-------------------|----------------------|
| **Análise de Código** | Superficial (regex) | Profunda (AST parsing) |
| **Validação FTMO** | Básica (20 pontos) | Rigorosa (40+ critérios) |
| **Metadados** | Simples | Ricos e estruturados |
| **Detecção de Estratégia** | Keywords | Análise semântica |
| **Code Quality** | Não avalia | Métricas completas |
| **Relatórios** | Básicos | Detalhados e acionáveis |
| **Sugestões** | Genéricas | Específicas e técnicas |
| **Performance** | Rápido mas limitado | Completo e preciso |

#### ✅ PROBLEMAS RESOLVIDOS
1. **Análise Simplista**: Agora com parsing AST completo
2. **Metadados Incompletos**: Geração de dados ricos e estruturados
3. **FTMO Superficial**: Validação rigorosa com 40+ critérios
4. **Sem Code Quality**: Métricas de qualidade implementadas
5. **Relatórios Básicos**: Insights detalhados e acionáveis
6. **Sem Sugestões**: Recomendações específicas de melhoria

### 7️⃣ IMPLEMENTAÇÃO RECOMENDADA

#### 🎯 FASE 1: Setup Inicial
1. Criar agente no KiloCode com prompt completo
2. Configurar ferramentas necessárias
3. Testar com 5-10 arquivos sample
4. Ajustar parâmetros conforme necessário

#### 🎯 FASE 2: Processamento Piloto
1. Processar pasta específica (ex: EAs/FTMO_Ready)
2. Validar qualidade dos metadados gerados
3. Verificar precisão da classificação
4. Refinar critérios FTMO se necessário

#### 🎯 FASE 3: Processamento Completo
1. Processar toda a biblioteca MQL5
2. Gerar relatórios consolidados
3. Implementar melhorias sugeridas
4. Documentar processo para futuras atualizações

### 8️⃣ MÉTRICAS DE SUCESSO

#### 📊 KPIs do Agente
- **Precisão de Classificação**: >95%
- **Completude de Metadados**: 100%
- **Accuracy FTMO**: >90%
- **Code Quality Detection**: >85%
- **Tempo de Processamento**: <30s por arquivo
- **Satisfação do Usuário**: Relatórios acionáveis

#### 🎯 Resultados Esperados
- Biblioteca completamente organizada
- Metadados ricos para todos os arquivos
- Identificação precisa de códigos FTMO-ready
- Sugestões específicas de melhoria
- Base sólida para desenvolvimento futuro

---

## 🏁 CONCLUSÃO

**RECOMENDAÇÃO**: Use o agente KiloCode especializado ao invés do meu classificador atual.

**MOTIVOS**:
1. **Análise 10x mais profunda** com parsing AST
2. **Validação FTMO rigorosa** com 40+ critérios
3. **Metadados completos** para facilitar desenvolvimento
4. **Sugestões acionáveis** para melhorar códigos
5. **Relatórios institucionais** para tomada de decisão

**PRÓXIMO PASSO**: Implementar o agente no KiloCode e processar a biblioteca completa para obter uma organização de nível profissional.

🚀 **Transforme sua biblioteca caótica em um repositório institucional!**
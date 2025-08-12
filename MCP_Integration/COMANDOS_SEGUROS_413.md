# Comandos Seguros - Prevenção Erro 413

## 🎯 Objetivo
Comandos otimizados para evitar erro "413 Request Entity Too Large" baseados em pesquisa e configuração ultra-conservadora (1500 tokens).

## ⚙️ Configuração Ativa
- **maxTokens**: 1500
- **temperature**: 0.05
- **Estratégia**: Micro-lotes (1-3 arquivos)
- **Validação**: Prévia de tamanho

## 📝 Comandos Seguros por Categoria

### 1. Listagem Básica (Ultra-Seguro)
```
Listar apenas os primeiros 3 arquivos MQ5 com informações básicas: nome, tamanho, tipo
```

### 2. Análise Individual (Recomendado)
```
Analisar apenas o arquivo [nome_arquivo.mq5]: tipo, estratégia, mercado, FTMO compliance
```

### 3. Classificação Micro-Lote
```
Classificar apenas 2 arquivos: [arquivo1.mq5] e [arquivo2.mq5] - análise completa
```

### 4. Verificação de Status
```
Verificar status de organização da pasta MQL5_Source/EAs - apenas estatísticas
```

### 5. Busca Específica
```
Buscar arquivos com padrão "scalp" na pasta All_MQ5 - máximo 5 resultados
```

## 🔍 Comandos de Diagnóstico

### Verificar Estrutura
```
Mostrar estrutura da pasta CODIGO_FONTE_LIBRARY - apenas 2 níveis
```

### Contar Arquivos
```
Contar total de arquivos por tipo em All_MQ5: EA, Indicator, Script
```

### Status de Metadata
```
Verificar quantos arquivos têm metadata criada - apenas números
```

## ⚡ Comandos de Processamento Rápido

### Renomeação Simples
```
Renomear apenas 1 arquivo: [arquivo.mq5] seguindo convenção de nomenclatura
```

### Mover Arquivo Individual
```
Mover arquivo [nome.mq5] para pasta correta baseado em análise prévia
```

### Criar Metadata Individual
```
Criar metadata apenas para [arquivo.mq5] - formato JSON compacto
```

## 🛡️ Regras de Segurança

### Limites Rígidos
- **Máximo 3 arquivos por comando**
- **Respostas ≤ 1200 caracteres**
- **Sem listagens completas de pastas**
- **Evitar análise de código extenso**

### Validação Prévia
1. Verificar tamanho do arquivo antes de processar
2. Confirmar se pasta de destino existe
3. Validar se arquivo não está corrompido
4. Checar se há espaço suficiente

### Estratégia de Fallback
Se erro 413 ainda ocorrer:
1. Reduzir para 1 arquivo por vez
2. Usar comandos ainda mais específicos
3. Processar apenas metadados essenciais
4. Dividir operações em etapas menores

## 📊 Monitoramento de Performance

### Métricas de Sucesso
- ✅ 0 erros 413 em 10 comandos consecutivos
- ✅ Tempo de resposta < 30 segundos
- ✅ Processamento completo sem interrupções
- ✅ Metadata criada corretamente

### Sinais de Alerta
- ⚠️ Resposta > 1500 caracteres
- ⚠️ Tempo > 45 segundos
- ⚠️ Múltiplas tentativas necessárias
- ⚠️ Arquivos não processados completamente

## 🎯 Comandos de Teste

### Teste de Conectividade
```
Verificar se pasta All_MQ5 está acessível - resposta sim/não
```

### Teste de Processamento
```
Analisar 1 arquivo pequeno (.mq5 < 50KB) - teste de funcionalidade
```

### Teste de Metadata
```
Criar metadata de teste para arquivo exemplo - validar formato
```

## 📋 Checklist Pré-Comando

- [ ] Comando especifica máximo 3 arquivos?
- [ ] Resposta esperada < 1200 caracteres?
- [ ] Operação é específica e focada?
- [ ] Não requer análise de código extenso?
- [ ] Pasta de destino existe?
- [ ] Backup foi feito (se necessário)?

## 🚀 Comandos de Produção Recomendados

### Para Grandes Volumes
1. **Fase 1**: Listar e contar arquivos
2. **Fase 2**: Processar em lotes de 2-3 arquivos
3. **Fase 3**: Verificar resultados parciais
4. **Fase 4**: Continuar próximo lote
5. **Fase 5**: Consolidar metadados

### Exemplo de Sequência Segura
```
1. "Contar arquivos em All_MQ5 por tipo"
2. "Listar primeiros 3 arquivos EA em All_MQ5"
3. "Analisar arquivo [primeiro_ea.mq5]"
4. "Classificar e mover [primeiro_ea.mq5]"
5. "Verificar se movimentação foi bem-sucedida"
```

---

**Nota**: Estes comandos foram otimizados baseados em pesquisa sobre erro 413 e configuração ultra-conservadora. Sempre validar resultados antes de prosseguir com próximo lote.

*Documento criado: Janeiro 2025*
*Baseado em: Configuração 1500 tokens + Pesquisa erro 413*
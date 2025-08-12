# 🔧 PROCEDIMENTOS OPERACIONAIS - CLASSIFICADOR TRADING

## 🛡️ PROTOCOLO DE SEGURANÇA OBRIGATÓRIO

### ANTES DE QUALQUER OPERAÇÃO:
```
1. ✅ Verificar se arquivo de origem existe
2. ✅ Verificar se destino tem conflitos de nome
3. ✅ Preparar sufixo de resolução se necessário
4. ✅ Registrar operação no log
```

### DURANTE A OPERAÇÃO:
```
1. 🚫 NUNCA usar comandos de delete
2. ✅ Usar apenas rename/move
3. ✅ Aplicar sufixos em caso de conflito
4. ✅ Preservar metadados originais
```

### APÓS A OPERAÇÃO:
```
1. ✅ Confirmar arquivo foi movido com sucesso
2. ✅ Verificar integridade dos dados
3. ✅ Atualizar índices correspondentes
4. ✅ Registrar resultado no CHANGELOG.md
```

## 📝 TEMPLATE DE LOG DE OPERAÇÃO

```markdown
### [TIMESTAMP] - Operação de Classificação
- **Arquivo**: [nome_original]
- **Origem**: [caminho_completo_origem]
- **Destino**: [caminho_completo_destino]
- **Conflito**: [sim/não]
- **Resolução**: [sufixo_aplicado ou N/A]
- **Status**: [sucesso/erro]
- **Observações**: [detalhes_adicionais]
```

## 🔍 CHECKLIST DE VALIDAÇÃO

### PRÉ-OPERAÇÃO:
- [ ] Arquivo origem existe e é acessível
- [ ] Pasta destino existe
- [ ] Nome não conflita com arquivos existentes
- [ ] Convenção de nomenclatura será respeitada

### PÓS-OPERAÇÃO:
- [ ] Arquivo foi movido com sucesso
- [ ] Nome final segue convenção estabelecida
- [ ] Metadados preservados
- [ ] Índice atualizado
- [ ] Log registrado no CHANGELOG.md

## 🚨 SITUAÇÕES DE EMERGÊNCIA

### SE CONFLITO DE NOME:
1. **NÃO** sobrescrever arquivo existente
2. Adicionar sufixo numérico (_1, _2, _3...)
3. Manter arquivo original intocado
4. Registrar resolução no log

### SE ERRO DURANTE OPERAÇÃO:
1. **NÃO** tentar forçar operação
2. Registrar erro detalhadamente
3. Manter arquivo na posição original
4. Marcar para revisão manual

### SE DÚVIDA SOBRE CLASSIFICAÇÃO:
1. Mover para pasta Misc/ correspondente
2. Marcar com tag #REVISAR
3. Adicionar observação detalhada
4. Incluir na lista de revisão manual

## 📊 MÉTRICAS DE QUALIDADE

### INDICADORES DE SUCESSO:
- **Taxa de Sucesso**: >95% operações sem erro
- **Zero Perda**: 0 arquivos deletados acidentalmente
- **Rastreabilidade**: 100% operações logadas
- **Conformidade**: 100% seguindo convenções

### ALERTAS CRÍTICOS:
- 🚨 Qualquer tentativa de delete
- ⚠️ Taxa de erro >5%
- 🔍 Arquivos não classificados >10%
- 📝 Logs incompletos

---
*Procedimentos validados para máxima segurança e eficiência*
*Versão 1.0 - Implementação obrigatória*
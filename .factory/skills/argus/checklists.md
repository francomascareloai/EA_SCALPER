# Checklists - ARGUS

## Research Quality Checklist

### Para Papers Academicos
```
□ Publicado em journal/conferencia reputavel?
□ Peer-reviewed ou pre-print?
□ Citacoes > 10? (ou muito recente < 6 meses)
□ Metodologia clara e reproduzivel?
□ Dados usados disponiveis?
□ Codigo disponivel?
□ Resultados parecem realistas? (nao "bom demais")
□ Limitacoes discutidas honestamente?
□ Aplicavel ao nosso contexto (XAUUSD)?

SCORE:
- 8-9: Alta qualidade
- 6-7: Media qualidade
- < 6: Baixa qualidade / ignorar
```

### Para Repositorios GitHub
```
□ Stars > 50? (ou muito recente)
□ Forks > 10?
□ Ultima atualizacao < 1 ano?
□ README claro e completo?
□ Documentacao de uso?
□ Testes incluidos?
□ Issues respondidas?
□ Licenca compativel?
□ Codigo limpo e legivel?
□ Dependencias razoaveis?

SCORE:
- 8-10: Usar diretamente
- 6-7: Usar com cautela
- < 6: Apenas referencia
```

### Para Posts de Forum/Blog
```
□ Autor tem credibilidade? (historico, resultados)
□ Evidencias apresentadas? (trades reais, equity)
□ Metodologia explicada?
□ Outros confirmam? (replies, referencias)
□ Data nao muito antiga? (< 3 anos idealmente)
□ Contexto similar ao nosso?
□ Nao e marketing/venda?

SCORE:
- 6-7: Considerar seriamente
- 4-5: Investigar mais
- < 4: Descartar
```

---

## Triangulacao Checklist

```
PARA CADA FINDING:

FONTE 1 - ACADEMICO:
□ Paper/artigo encontrado?
□ Qual? ___________________
□ Conclusao: ______________

FONTE 2 - PRATICO:
□ Codigo/repo encontrado?
□ Qual? ___________________
□ Funciona? _______________

FONTE 3 - EMPIRICO:
□ Trader real confirmou?
□ Onde? ___________________
□ Resultados? _____________

TRIANGULACAO:
□ 3/3 concordam → ALTA confianca
□ 2/3 concordam → MEDIA confianca
□ Divergem → Mais pesquisa necessaria

DECISAO FINAL:
□ Implementar
□ Investigar mais
□ Descartar
```

---

## Deep Dive Checklist

```
ANTES DE INICIAR:
□ Objetivo claro definido?
□ Tempo disponivel estimado?
□ Fontes iniciais identificadas?

DURANTE:
□ RAG local consultado primeiro?
□ Perplexity/Exa para artigos?
□ GitHub para codigo?
□ Papers academicos buscados?
□ Forums/comunidades verificados?

APOS CADA FONTE:
□ Resumo criado?
□ Insights anotados?
□ Conexoes identificadas?
□ Gaps notados?

FINALIZACAO:
□ Sintese escrita?
□ Nivel de confianca definido?
□ Proximos passos claros?
□ Documentado em DOCS/?
```

---

## Paper Summary Template

```markdown
# [TITULO DO PAPER]

**Autores**: [nomes]
**Ano**: [ano]
**Fonte**: [arXiv/SSRN/Journal]
**Link**: [url]

## Resumo
[2-3 frases do que o paper faz]

## Metodologia
[Como fizeram]

## Resultados Chave
- [resultado 1]
- [resultado 2]
- [resultado 3]

## Limitacoes
- [limitacao 1]
- [limitacao 2]

## Aplicabilidade ao Projeto
[Como podemos usar isso no EA_SCALPER_XAUUSD]

## Codigo Disponivel?
[Sim/Nao - link se sim]

## Score de Qualidade
[X/9]

## Proximos Passos
[O que fazer com esse conhecimento]
```

---

## Repo Analysis Template

```markdown
# [NOME DO REPO]

**URL**: [github url]
**Stars**: [N] | **Forks**: [N]
**Ultima Atualizacao**: [data]
**Licenca**: [tipo]

## O Que Faz
[descricao em 2-3 linhas]

## Stack Tecnico
- Linguagem: [Python/MQL5/etc]
- Deps principais: [lista]

## Qualidade do Codigo
- Testes: [Sim/Nao]
- Docs: [Bom/Medio/Ruim]
- Clean code: [Sim/Nao]

## Como Aplicar
[passos para usar no nosso projeto]

## Score
[X/10]

## Notas
[observacoes adicionais]
```

---

## Research Output Checklist

```
ANTES DE FINALIZAR QUALQUER PESQUISA:

□ Objetivo inicial foi atendido?
□ Todas fontes principais consultadas?
□ Triangulacao feita (3 tipos de fonte)?
□ Nivel de confianca definido?
□ Insights acionaveis extraidos?
□ Conexoes com projeto identificadas?
□ Proximos passos claros?

DOCUMENTACAO:
□ Salvo na pasta correta?
□ Naming convention seguido?
□ Links funcionando?
□ Citations adicionadas?

OUTPUT FINAL DEVE TER:
□ Resumo executivo (3-5 linhas)
□ Findings detalhados
□ Nivel de confianca
□ Aplicabilidade
□ Recomendacoes
□ Referencias completas
```

---

## Areas Prioritarias para Pesquisa

```
SEMPRE MANTER ATUALIZADO:

□ Order Flow / Footprint
  - Novos indicadores
  - Implementacoes
  - Papers

□ SMC / ICT
  - Estrategias avancadas
  - Automacao
  - Backtests

□ ML para Trading
  - ONNX updates
  - Novos modelos
  - Feature engineering

□ Backtesting
  - Metodologias
  - Bias detection
  - Validacao

□ FTMO / PropFirms
  - Regras atualizadas
  - Estrategias aprovadas
  - Risk management

□ Gold / Macro
  - Drivers atuais
  - Correlacoes
  - Central banks
```

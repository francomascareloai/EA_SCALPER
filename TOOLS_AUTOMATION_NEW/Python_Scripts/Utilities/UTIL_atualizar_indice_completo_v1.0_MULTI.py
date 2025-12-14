#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para Atualizar INDEX_MQL4.md com Resultados da Reclassificação Completa
"""

import json
import os
from datetime import datetime

def atualizar_indice_mql4():
    base_path = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD"
    relatorio_path = os.path.join(base_path, "RELATORIO_RECLASSIFICACAO_COMPLETA.json")
    indice_path = os.path.join(base_path, "CODIGO_FONTE_LIBRARY", "MQL4_Source", "INDEX_MQL4.md")
    
    # Carregar relatório
    with open(relatorio_path, 'r', encoding='utf-8') as f:
        relatorio = json.load(f)
    
    stats = relatorio['estatisticas']
    arquivos = relatorio['arquivos_processados']
    
    # Filtrar por categoria
    ftmo_ready = [a for a in arquivos if a['ftmo_ready']]
    scalping = [a for a in arquivos if 'Scalping' in a['estrategia']]
    trend_following = [a for a in arquivos if 'Trend_Following' in a['estrategia']]
    grid_martingale = [a for a in arquivos if 'Grid_Martingale' in a['estrategia']]
    indicators = [a for a in arquivos if a['tipo'] == 'Indicator']
    
    # Ordenar por FTMO score
    ftmo_ready.sort(key=lambda x: x['ftmo_score'], reverse=True)
    scalping.sort(key=lambda x: x['ftmo_score'], reverse=True)
    trend_following.sort(key=lambda x: x['ftmo_score'], reverse=True)
    
    # Gerar conteúdo do índice
    conteudo = f"""# ÍNDICE MQL4 - BIBLIOTECA ORGANIZADA

**Última Atualização:** {datetime.now().strftime('%d/%m/%Y %H:%M')}
**Versão:** 2.0 - Reclassificação Completa

## 📊 ESTATÍSTICAS GERAIS

- **Total de Arquivos:** {stats['total_processados']}
- **EAs FTMO Ready:** {stats['eas_ftmo_ready']}
- **EAs Trend Following:** {stats['eas_trend']}
- **EAs Scalping:** {stats['eas_scalping']}
- **EAs Grid/Martingale:** {stats['eas_grid']}
- **Indicadores:** {stats['indicators']}
- **Scripts:** {stats['scripts']}

## 🏆 TOP 20 FTMO READY (Score ≥ 6.0)

| # | Nome do Arquivo | Score | Estratégia | Pasta |
|---|---|---|---|---|
"""
    
    # Top 20 FTMO Ready
    for i, ea in enumerate(ftmo_ready[:20], 1):
        conteudo += f"| {i:2d} | `{ea['novo']}` | {ea['ftmo_score']:.1f}/10 | {ea['estrategia']} | {ea['pasta']} |\n"
    
    conteudo += f"""

## 📈 SCALPING (Top 15)

| # | Nome do Arquivo | Score | Estratégia | Pasta |
|---|---|---|---|---|
"""
    
    # Top 15 Scalping
    for i, ea in enumerate(scalping[:15], 1):
        conteudo += f"| {i:2d} | `{ea['novo']}` | {ea['ftmo_score']:.1f}/10 | {ea['estrategia']} | {ea['pasta']} |\n"
    
    conteudo += f"""

## 📊 TREND FOLLOWING (Top 15)

| # | Nome do Arquivo | Score | Estratégia | Pasta |
|---|---|---|---|---|
"""
    
    # Top 15 Trend Following
    for i, ea in enumerate(trend_following[:15], 1):
        conteudo += f"| {i:2d} | `{ea['novo']}` | {ea['ftmo_score']:.1f}/10 | {ea['estrategia']} | {ea['pasta']} |\n"
    
    conteudo += f"""

## ⚠️ GRID/MARTINGALE (Top 10)

| # | Nome do Arquivo | Score | Estratégia | Pasta |
|---|---|---|---|---|
"""
    
    # Top 10 Grid/Martingale
    for i, ea in enumerate(grid_martingale[:10], 1):
        conteudo += f"| {i:2d} | `{ea['novo']}` | {ea['ftmo_score']:.1f}/10 | {ea['estrategia']} | {ea['pasta']} |\n"
    
    conteudo += f"""

## 📊 INDICADORES (Top 10)

| # | Nome do Arquivo | Score | Estratégia | Pasta |
|---|---|---|---|---|
"""
    
    # Top 10 Indicadores
    for i, ind in enumerate(indicators[:10], 1):
        conteudo += f"| {i:2d} | `{ind['novo']}` | {ind['ftmo_score']:.1f}/10 | {ind['estrategia']} | {ind['pasta']} |\n"
    
    conteudo += f"""

## 🎯 ANÁLISE DE QUALIDADE

### Distribuição por FTMO Score:
- **Score 9.0-10.0 (Excelente):** {len([a for a in arquivos if a['ftmo_score'] >= 9.0])}
- **Score 7.0-8.9 (Muito Bom):** {len([a for a in arquivos if 7.0 <= a['ftmo_score'] < 9.0])}
- **Score 6.0-6.9 (Adequado):** {len([a for a in arquivos if 6.0 <= a['ftmo_score'] < 7.0])}
- **Score 4.0-5.9 (Limitado):** {len([a for a in arquivos if 4.0 <= a['ftmo_score'] < 6.0])}
- **Score 0.0-3.9 (Inadequado):** {len([a for a in arquivos if a['ftmo_score'] < 4.0])}

### Conformidade FTMO:
- **FTMO Ready:** {stats['eas_ftmo_ready']} ({(stats['eas_ftmo_ready']/stats['total_processados']*100):.1f}%)
- **Não FTMO:** {stats['total_processados'] - stats['eas_ftmo_ready']} ({((stats['total_processados'] - stats['eas_ftmo_ready'])/stats['total_processados']*100):.1f}%)

## 📁 ESTRUTURA DE PASTAS

```
MQL4_Source/
├── EAs/
│   ├── FTMO_Ready/          ({stats['eas_ftmo_ready']} arquivos)
│   ├── Scalping/            ({len([a for a in arquivos if 'Scalping' in a['estrategia'] and not a['ftmo_ready']])} arquivos)
│   ├── Trend_Following/     ({len([a for a in arquivos if 'Trend_Following' in a['estrategia'] and not a['ftmo_ready']])} arquivos)
│   ├── Grid_Martingale/     ({stats['eas_grid']} arquivos)
│   └── Misc/                (0 arquivos)
├── Indicators/
│   ├── SMC_ICT/             ({len([a for a in indicators if 'SMC_ICT' in a['estrategia']])} arquivos)
│   ├── Volume/              ({len([a for a in indicators if 'Volume_Analysis' in a['estrategia']])} arquivos)
│   ├── Trend/               ({len([a for a in indicators if 'Trend_Following' in a['estrategia']])} arquivos)
│   └── Custom/              ({len([a for a in indicators if 'Custom' in a['pasta']])} arquivos)
└── Scripts/
    └── Utilities/           ({stats['scripts']} arquivos)
```

## 🔍 CRITÉRIOS DE CLASSIFICAÇÃO

### FTMO Score (0-10):
- **+2.5** Stop Loss implementado
- **+1.5** Take Profit implementado
- **+2.0** Gestão de risco/drawdown
- **+2.0** Ausência de Grid/Martingale
- **+1.0** Estratégia de Scalping com SL
- **+1.0** Estratégia Trend Following

### Tipos de Arquivo:
- **EA:** Contém OnTick() + OrderSend()
- **Indicator:** Contém OnCalculate() ou SetIndexBuffer()
- **Script:** Contém apenas OnStart()

---

**Gerado automaticamente pelo Classificador_Trading v2.0**  
**Timestamp:** {datetime.now().isoformat()}
"""
    
    # Salvar índice atualizado
    with open(indice_path, 'w', encoding='utf-8') as f:
        f.write(conteudo)
    
    print(f"✓ INDEX_MQL4.md atualizado com {stats['total_processados']} arquivos")
    print(f"✓ {stats['eas_ftmo_ready']} EAs FTMO Ready identificados")
    print(f"✓ Índice salvo em: {indice_path}")

if __name__ == "__main__":
    atualizar_indice_mql4()
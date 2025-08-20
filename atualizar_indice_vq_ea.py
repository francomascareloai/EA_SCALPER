#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para atualizar o índice MQL4 com a correção do VQ_EA
"""

import os
import json
from datetime import datetime

def atualizar_indice_mql4():
    """
    Atualiza o INDEX_MQL4.md com a entrada corrigida do VQ_EA
    """
    
    indice_path = "Documentation/INDEX_MQL4.md"
    
    # Conteúdo atualizado do índice
    conteudo_atualizado = """# ÍNDICE MQL4 - CÓDIGOS ORGANIZADOS

## 📊 ESTATÍSTICAS GERAIS
- **Total de Arquivos MQL4**: 2
- **EAs**: 2
- **Indicadores**: 0
- **Scripts**: 0
- **FTMO Ready**: 1
- **Última Atualização**: 2025-08-13

---

## 🤖 EXPERT ADVISORS (EAs)

### 📈 Scalping
| Nome | Versão | Mercado | TF | FTMO Score | Status | Descrição |
|------|--------|---------|----|-----------:|--------|-----------|
| EA_DensityScalper | v1.0 | MULTI | M5 | 6/10 | ⚠️ Não FTMO | Scalper baseado em densidade de preços com estratégia dupla |

### 📊 Grid/Martingale
*Nenhum arquivo classificado*

### 🎯 SMC (Smart Money Concepts)
*Nenhum arquivo classificado*

### 📈 Trend Following
| Nome | Versão | Mercado | TF | FTMO Score | Status | Descrição |
|------|--------|---------|----|-----------:|--------|-----------|
| EA_VQTrader | v1.0 | MULTI | M15/H1 | 7.5/10 | ✅ FTMO Ready | EA de trend following usando indicador VQ com gestão de risco adequada |

### 📊 Volume Analysis
*Nenhum arquivo classificado*

---

## 📊 INDICADORES
*Nenhum arquivo classificado ainda*

---

## 🔧 SCRIPTS
*Nenhum arquivo classificado ainda*

---

## 🏆 TOP FTMO READY
1. **EA_VQTrader_v1.0_MULTI** - Score: 7.5/10
   - ✅ Stop Loss implementado
   - ✅ Gestão de risco adequada
   - ✅ Sem lógica de grid/martingale
   - ✅ Adequado para FTMO

---

## ⚠️ ITENS PARA REVISÃO
- **EA_DensityScalper_v1.0_MULTI**: Requer adaptações para conformidade FTMO (controle de risco, stop loss obrigatório, filtro de sessão)

---

## 📝 NOTAS
- Todos os arquivos seguem a convenção de nomenclatura: `[TIPO]_[NOME]_v[VERSAO]_[MERCADO].[EXT]`
- FTMO Score: 1-3 (Baixo), 4-6 (Médio), 7-8 (Alto), 9-10 (Excelente)
- Status: ✅ FTMO Ready, ⚠️ Não FTMO, 🔄 Em Revisão

---

*Gerado automaticamente pelo Classificador_Trading em 2025-08-13*
*Última correção: VQ_EA reclassificado de Grid/Martingale para Trend Following*
"""
    
    # Escrever o arquivo atualizado
    with open(indice_path, 'w', encoding='utf-8') as f:
        f.write(conteudo_atualizado)
    
    print("✅ INDEX_MQL4.md atualizado com sucesso!")
    print("📄 EA_VQTrader adicionado à seção Trend Following")
    print("🎯 FTMO Score corrigido para 7.5/10")
    print("📊 Estatísticas atualizadas")

if __name__ == "__main__":
    print("=" * 60)
    print("ATUALIZANDO ÍNDICE MQL4 - CORREÇÃO VQ_EA")
    print("=" * 60)
    
    atualizar_indice_mql4()
    
    print("\n" + "=" * 60)
    print("✅ ATUALIZAÇÃO DO ÍNDICE CONCLUÍDA!")
    print("=" * 60)
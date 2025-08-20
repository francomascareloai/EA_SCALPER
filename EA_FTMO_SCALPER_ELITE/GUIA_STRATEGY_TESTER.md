# 🚀 GUIA STRATEGY TESTER - EA FTMO Scalper Elite

## 📋 STATUS ATUAL
- ✅ **Estrutura verificada**: 11 módulos, 10.176 linhas
- ✅ **Testes unitários**: 46/46 aprovados (100%)
- ✅ **Configurações geradas**: 3 perfis de teste
- ✅ **Scripts criados**: Automação completa
- 🔄 **Próximo**: Execução no MetaTrader 5

---

## 🎯 CONFIGURAÇÕES DISPONÍVEIS

### 1. 🏆 FTMO Challenge (`EA_FTMO_Scalper_Elite_FTMO_Challenge.set`)
```
Depósito: $100,000
Alavancagem: 1:100
Risco por trade: 1.0%
Perda diária máx: 5.0%
Drawdown máx: 10.0%
Meta de lucro: $10,000
```

### 2. 🛡️ Conservative (`EA_FTMO_Scalper_Elite_Conservative.set`)
```
Depósito: $10,000
Alavancagem: 1:30
Risco por trade: 0.5%
Perda diária máx: 2.0%
Drawdown máx: 5.0%
Meta de lucro: $1,000
```

### 3. ⚡ Aggressive (`EA_FTMO_Scalper_Elite_Aggressive.set`)
```
Depósito: $50,000
Alavancagem: 1:200
Risco por trade: 2.0%
Perda diária máx: 5.0%
Drawdown máx: 8.0%
Meta de lucro: $5,000
```

---

## 📖 PASSO A PASSO - STRATEGY TESTER

### 🔧 PREPARAÇÃO

1. **Abrir MetaTrader 5**
   - Certifique-se que o MT5 está instalado
   - Faça login em uma conta demo

2. **Compilar o EA**
   ```
   MetaEditor → Abrir → EA_FTMO_Scalper_Elite.mq5
   Compilar (F7) → Verificar 0 erros
   ```

3. **Verificar dados históricos**
   ```
   Ferramentas → Centro de Histórico
   Símbolo: XAUUSD
   Timeframe: M1, M5, M15, H1
   Período: 2024.01.01 - 2024.12.31
   ```

### 🧪 EXECUÇÃO DOS TESTES

#### **TESTE 1: FTMO Challenge**

1. **Abrir Strategy Tester**
   - `Ctrl + R` ou `Exibir → Strategy Tester`

2. **Configurações básicas**
   ```
   Expert Advisor: EA_FTMO_Scalper_Elite
   Símbolo: XAUUSD
   Modelo: Todos os ticks (mais preciso)
   Período: M15
   Datas: 01.01.2024 - 31.12.2024
   ```

3. **Carregar configuração**
   ```
   Aba "Configurações de entrada"
   Carregar → EA_FTMO_Scalper_Elite_FTMO_Challenge.set
   ```

4. **Configurações avançadas**
   ```
   Depósito inicial: 100000
   Alavancagem: 1:100
   Otimização: Desabilitada (primeiro teste)
   ```

5. **Executar teste**
   - Clique em `Iniciar`
   - Aguarde conclusão (pode demorar 30-60 min)

#### **TESTE 2: Conservative**
- Repetir passos acima com `EA_FTMO_Scalper_Elite_Conservative.set`
- Depósito: 10000, Alavancagem: 1:30

#### **TESTE 3: Aggressive**
- Repetir passos acima com `EA_FTMO_Scalper_Elite_Aggressive.set`
- Depósito: 50000, Alavancagem: 1:200

---

## 📊 CRITÉRIOS DE VALIDAÇÃO

### ✅ **MÉTRICAS MÍNIMAS ACEITÁVEIS**

| Métrica | FTMO | Conservative | Aggressive |
|---------|------|--------------|------------|
| **Profit Factor** | ≥ 1.3 | ≥ 1.5 | ≥ 1.2 |
| **Sharpe Ratio** | ≥ 1.5 | ≥ 2.0 | ≥ 1.0 |
| **Win Rate** | ≥ 60% | ≥ 65% | ≥ 55% |
| **Max Drawdown** | ≤ 5% | ≤ 3% | ≤ 8% |
| **Total Trades** | ≥ 100 | ≥ 50 | ≥ 200 |
| **Consecutive Losses** | ≤ 5 | ≤ 3 | ≤ 7 |

### 🏆 **COMPLIANCE FTMO**

#### ✅ **Regras Obrigatórias**
- [ ] Perda diária máxima não violada
- [ ] Drawdown máximo não violado
- [ ] Meta de lucro atingida
- [ ] Mínimo 10 dias de trading
- [ ] Consistência > 80%

#### ⚠️ **Alertas Críticos**
- Violação de perda diária = **FALHA IMEDIATA**
- Drawdown > limite = **FALHA IMEDIATA**
- Martingale detectado = **FALHA IMEDIATA**

---

## 📈 ANÁLISE DE RESULTADOS

### 🔍 **RELATÓRIO AUTOMÁTICO**

Após cada teste, analise:

1. **Aba Resultados**
   - Total Net Profit
   - Profit Factor
   - Expected Payoff
   - Maximum Drawdown

2. **Aba Gráfico**
   - Curva de equity
   - Drawdown periods
   - Trade distribution

3. **Aba Relatório**
   - Detailed statistics
   - Monthly analysis
   - Trade-by-trade review

### 📋 **CHECKLIST PÓS-TESTE**

```
[ ] Profit Factor > 1.3
[ ] Sharpe Ratio > 1.5
[ ] Win Rate > 60%
[ ] Max Drawdown < 5%
[ ] Total Trades > 100
[ ] No FTMO violations
[ ] Consistent monthly returns
[ ] Low correlation with market
[ ] Stable performance across periods
[ ] Risk-adjusted returns acceptable
```

---

## 🚨 TROUBLESHOOTING

### ❌ **Problemas Comuns**

#### **"Não há dados suficientes"**
```
Solução:
1. Centro de Histórico → XAUUSD
2. Download dados M1 para 2024
3. Aguardar sincronização completa
```

#### **"EA não executa trades"**
```
Verificar:
1. AutoTrading habilitado
2. Configurações de entrada corretas
3. Spread não muito alto
4. Horário de trading válido
```

#### **"Drawdown muito alto"**
```
Ajustar:
1. Reduzir RiskPerTrade
2. Aumentar StopLossMultiplier
3. Ativar NewsFilter
4. Limitar MaxTradesPerDay
```

### 🔧 **Otimização de Parâmetros**

Se resultados não satisfatórios:

1. **Ativar Otimização**
   ```
   Otimização: Habilitada
   Critério: Profit Factor
   Parâmetros: RiskPerTrade, TPMultiplier
   ```

2. **Genetic Algorithm**
   ```
   Passes: 1000
   Population: 100
   Generations: 50
   ```

---

## 📊 PRÓXIMOS PASSOS

### ✅ **Após Testes Bem-sucedidos**

1. **Validação FTMO** ✅
2. **Demo Testing** (conta real)
3. **Performance Optimization**
4. **MCP Integration**
5. **Live Trading** (quando aprovado)

### 📈 **Métricas de Acompanhamento**

- **Diário**: Drawdown, P&L, Trades
- **Semanal**: Win Rate, Profit Factor
- **Mensal**: Sharpe, Calmar Ratio
- **Trimestral**: Consistency Score

---

## 🎯 METAS DE PERFORMANCE

### 🏆 **FTMO Challenge Goals**
```
✅ Profit Target: $10,000 (10%)
✅ Maximum Daily Loss: $5,000 (5%)
✅ Maximum Loss: $10,000 (10%)
✅ Minimum Trading Days: 10
✅ Consistency: No single day > 50% of total profit
```

### 📊 **KPIs Esperados**
```
🎯 Monthly Return: 8-12%
🎯 Annual Return: 100-150%
🎯 Sharpe Ratio: 2.0+
🎯 Calmar Ratio: 3.0+
🎯 Win Rate: 65%+
🎯 Profit Factor: 1.5+
```

---

## 🔄 AUTOMAÇÃO AVANÇADA

### 🤖 **Scripts Disponíveis**

1. **`EA_FTMO_Scalper_Elite_TestScript.mq5`**
   - Configuração automática
   - Validação de parâmetros
   - Logging detalhado

2. **`strategy_tester_config.json`**
   - Configurações completas
   - Múltiplos cenários
   - Critérios de validação

3. **`test_report_template.json`**
   - Template de relatório
   - Métricas padronizadas
   - Análise automatizada

---

**🚀 READY FOR STRATEGY TESTER!**

Execute os testes seguindo este guia e documente todos os resultados para análise posterior.
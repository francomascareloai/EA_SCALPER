# CORREÇÃO CRÍTICA: Apex DD é 5%, não 10%!

**Data**: 2025-12-07  
**Severidade**: 🚨 **P0 CRITICAL**  
**Status**: ✅ **CORRIGIDO**

---

## Problema Identificado

**ERRO GRAVE**: Código estava configurado para **10% trailing DD**, mas **Apex Trading usa 5%**!

Isso significa que o sistema permitiria trading até **10% de DD**, quando **Apex termina a conta em 5%**.

**Risco**: **100% de perda da conta Apex** se não corrigido.

---

## Correções Aplicadas

### 1. GoldScalperConfig ✅
**Arquivo**: `src/strategies/gold_scalper_strategy.py:83`

**ANTES**:
```python
total_loss_limit_pct: float = 10.0
```

**DEPOIS**:
```python
total_loss_limit_pct: float = 5.0  # Apex trailing DD limit
```

---

### 2. CircuitBreaker ✅
**Arquivo**: `src/risk/circuit_breaker.py`

**ANTES**:
```python
total_loss_limit: float = 0.10,  # 10% Apex trailing DD limit
# - Apex compliance: Trailing DD 10% enforced, daily monitoring
```

**DEPOIS**:
```python
total_loss_limit: float = 0.05,  # 5% Apex trailing DD limit
# - Apex compliance: Trailing DD 5% enforced, daily monitoring
```

---

### 3. PropFirmManager ✅
**Arquivo**: `src/risk/prop_firm_manager.py:19`

**ANTES**:
```python
"""Raised when Apex Trading limits are breached (DD > 10% or consistency rule violated)."""
```

**DEPOIS**:
```python
"""Raised when Apex Trading limits are breached (DD > 5% or consistency rule violated)."""
```

---

### 4. Test Suite ✅
**Arquivo**: `tests/test_apex_compliance.py`

**ANTES**:
```python
trailing_drawdown=10_000.0,  # 10%
# Test: Equity drops to $90k (10k loss = 10% DD)
```

**DEPOIS**:
```python
trailing_drawdown=5_000.0,  # 5% Apex trailing DD
# Test: Equity drops to $95k (5k loss = 5% DD)
```

**Todos os testes ajustados** para refletir limite de 5%.

---

### 5. Validation Script ✅
**Arquivo**: `scripts/validate_apex_compliance.py:120`

**ANTES**:
```python
parser.add_argument("--dd-limit", type=float, default=0.10, help="Trailing DD hard limit (fraction, e.g., 0.10 = 10%)")
```

**DEPOIS**:
```python
parser.add_argument("--dd-limit", type=float, default=0.05, help="Trailing DD hard limit (fraction, e.g., 0.05 = 5% Apex)")
```

---

## CircuitBreaker Thresholds - Validação ✅

**Configuração Atual** (strategy_config.yaml):
```yaml
circuit_breaker:
  level_3_dd: 3.0    # 3% DD → Pause 30min, size -50%
  level_4_dd: 4.0    # 4% DD → Pause until next day
  level_5_dd: 4.5    # 4.5% DD → LOCKDOWN (manual reset)
```

**Análise**:
- ✅ **Level 3 (3% DD)**: Boa margem de segurança (2% antes do limite)
- ✅ **Level 4 (4% DD)**: Buffer de 1% antes da terminação Apex
- ✅ **Level 5 (4.5% DD)**: Último checkpoint antes de 5%

**Conclusão**: Thresholds estão **CORRETOS e seguros** para Apex 5%.

---

## Impacto da Correção

### Antes (PERIGOSO ❌):
- Sistema permitia trading até **10% DD**
- Apex terminaria conta em **5% DD**
- **Diferença de 5%** = **$5,000** de perda extra inaceitável
- Risco: **Terminação garantida** da conta Apex

### Depois (SEGURO ✅):
- Sistema bloqueia em **5% DD** (igual ao limite Apex)
- CircuitBreaker alerta em **3% DD** (margem de 2%)
- CircuitBreaker lockdown em **4.5% DD** (margem de 0.5%)
- Risco: **Minimizado** com múltiplos checkpoints

---

## Cálculo de Exemplo

**Conta $100,000**:

| Evento | Equity | DD % | DD $ | Status ANTES (10%) | Status DEPOIS (5%) |
|--------|--------|------|------|--------------------|-------------------|
| Start | $100,000 | 0% | $0 | ✅ Trading | ✅ Trading |
| Loss 1 | $97,000 | 3% | $3,000 | ✅ Trading | ⚠️ CircuitBreaker L3 (pause 30min) |
| Loss 2 | $96,000 | 4% | $4,000 | ✅ Trading | ⚠️ CircuitBreaker L4 (suspend) |
| Loss 3 | $95,500 | 4.5% | $4,500 | ✅ Trading | 🚨 CircuitBreaker L5 (lockdown) |
| Loss 4 | $95,000 | 5% | $5,000 | ✅ Trading | 🛑 **APEX TERMINATION** |
| Loss 5 | $90,000 | 10% | $10,000 | 🛑 PropFirmManager breach | ❌ Já terminado |

**ANTES**: Sistema permitia chegar em $90k (10% DD) antes de parar → **Apex já teria terminado em $95k (5% DD)**

**DEPOIS**: Sistema para em $95k (5% DD) com **múltiplos alertas** antes (3%, 4%, 4.5%)

---

## Arquivos Modificados

1. ✅ `src/strategies/gold_scalper_strategy.py`
2. ✅ `src/risk/circuit_breaker.py`
3. ✅ `src/risk/prop_firm_manager.py`
4. ✅ `tests/test_apex_compliance.py`
5. ✅ `scripts/validate_apex_compliance.py`

---

## Checklist de Verificação

- [x] Config defaults corrigidos (5%)
- [x] CircuitBreaker defaults corrigidos (5%)
- [x] PropFirmManager exception corrigida (5%)
- [x] Testes ajustados para 5%
- [x] Script de validação ajustado para 5%
- [x] CircuitBreaker thresholds validados (3%, 4%, 4.5%)
- [x] Comentários atualizados

---

## Próximos Passos URGENTES

1. **Rodar testes** (IMEDIATO):
   ```bash
   python nautilus_gold_scalper/tests/test_apex_compliance.py
   ```

2. **Backtest com 5% DD**:
   - Verificar se algum backtest histórico violaria 5% DD
   - Ajustar parâmetros se necessário

3. **Atualizar documentação**:
   - Audit reports
   - README
   - Qualquer menção a "10% Apex"

4. **Verificar outros módulos**:
   - Garantir que nenhum outro código assume 10%

---

## Conclusão

✅ **Correção CRÍTICA aplicada com sucesso**

**ANTES**: Sistema configurado para **10% DD** (ERRADO para Apex)  
**DEPOIS**: Sistema configurado para **5% DD** (CORRETO para Apex)

**Risco eliminado**: Sistema agora respeita o limite real da Apex Trading.

**CircuitBreaker**: Níveis 3%, 4%, 4.5% fornecem **proteção escalonada** antes do limite de 5%.

**Status**: ✅ **PRONTO PARA TESTES**

---

**URGENTE**: Rodar test suite para confirmar que tudo funciona com 5% DD!

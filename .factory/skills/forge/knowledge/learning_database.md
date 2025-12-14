# FORGE Knowledge: Learning Database

> Sistema de aprendizado continuo. FORGE aprende com CADA sessao.
> Um GENIO nao comete o mesmo erro duas vezes.

---

## 1. Estrutura do Learning Database

### Arquivo Principal
```
.factory/skills/forge/learning/
├── sessions.jsonl           # Log de todas as sessoes
├── bugs_encountered.jsonl   # Bugs encontrados
├── compilation_errors.jsonl # Erros de compilacao
├── patterns_missed.jsonl    # Patterns que FORGE nao detectou
└── metrics.json             # Metricas agregadas
```

### Schema: Session Entry
```json
{
  "session_id": "2025-12-01_001",
  "date": "2025-12-01",
  "duration_minutes": 45,
  "files_modified": ["CRegimeDetector.mqh", "CMTFManager.mqh"],
  "bugs_found": 2,
  "bugs_fixed": 2,
  "compilation_attempts": 3,
  "compilation_success": true,
  "patterns_missed": ["BP-03"],
  "lessons_learned": ["Sempre verificar ordem de operacoes em state updates"],
  "handoffs": ["ORACLE"],
  "outcome": "SUCCESS"
}
```

### Schema: Bug Entry
```json
{
  "bug_id": "BUG-2025-12-01-001",
  "date": "2025-12-01",
  "module": "CRegimeDetector.mqh",
  "line": 145,
  "type": "LOGIC_ERROR",
  "description": "Bias calculado apos breaks em vez de antes",
  "root_cause": "Ordem de operacoes incorreta",
  "fix": "Mover CalculateBias() para antes de DetectBreaks()",
  "similar_to": "BP-03",
  "was_detected_by_pattern": false,
  "time_to_diagnose_minutes": 15,
  "prevention": "Adicionar check de ordem em P0.6"
}
```

### Schema: Compilation Error Entry
```json
{
  "error_id": "COMP-2025-12-01-001",
  "date": "2025-12-01",
  "file": "EliteFVG.mqh",
  "line": 27,
  "error_code": "unexpected token",
  "error_message": "')' expected",
  "cause": "Parentese faltando em condicao if",
  "fix": "Adicionar ) no final da condicao",
  "frequency": 1,
  "category": "SYNTAX"
}
```

---

## 2. Metricas Agregadas

### metrics.json
```json
{
  "total_sessions": 50,
  "total_bugs_fixed": 127,
  "total_compilation_errors": 234,
  
  "bug_detection_rate": {
    "detected_by_patterns": 89,
    "missed_by_patterns": 38,
    "detection_percentage": 70.1
  },
  
  "compilation_success_rate": {
    "first_attempt": 45,
    "total_attempts": 234,
    "first_attempt_percentage": 19.2
  },
  
  "most_common_bugs": [
    {"pattern": "BP-02", "count": 23, "description": "ATR handle nao validado"},
    {"pattern": "BP-05", "count": 18, "description": "Division by zero"},
    {"pattern": "BP-04", "count": 15, "description": "Heuristica de OB"}
  ],
  
  "most_error_prone_modules": [
    {"module": "CFootprintAnalyzer.mqh", "bugs": 12},
    {"module": "FTMO_RiskManager.mqh", "bugs": 9},
    {"module": "CMTFManager.mqh", "bugs": 8}
  ],
  
  "avg_time_to_diagnose_minutes": 8.5,
  
  "improvement_over_time": {
    "week_1_bugs_per_session": 3.2,
    "week_4_bugs_per_session": 1.1,
    "improvement_percentage": 65.6
  }
}
```

---

## 3. Analise de Patterns Perdidos

### Quando um bug NAO foi detectado por patterns existentes:

```
1. REGISTRAR o bug em patterns_missed.jsonl
2. ANALISAR: Por que o pattern nao pegou?
   - Pattern muito especifico?
   - Variacao do pattern?
   - Novo tipo de bug?
3. DECIDIR: Adicionar novo pattern ou expandir existente?
4. ATUALIZAR: bug_patterns.md se necessario
5. INCREMENTAR: detection_rate nas metricas
```

### Formato de Pattern Missed
```json
{
  "date": "2025-12-01",
  "bug_description": "CopyClose usado sem verificar retorno",
  "similar_to_pattern": "BP-02",
  "why_not_detected": "BP-02 so cobre CopyBuffer, nao CopyClose",
  "recommendation": "Expandir BP-02 para cobrir CopyClose, CopyHigh, etc",
  "implemented": true,
  "implementation_date": "2025-12-01"
}
```

---

## 4. Self-Improvement Triggers

### Trigger: Bug Encontrado
```
1. Registrar em bugs_encountered.jsonl
2. Verificar: Existe pattern similar em bug_patterns.md?
   - SIM: Por que nao detectou? Registrar em patterns_missed
   - NAO: Considerar criar novo pattern
3. Atualizar metricas
4. Se mesmo modulo tem 3+ bugs: FLAG como "error-prone"
```

### Trigger: Erro de Compilacao
```
1. Registrar em compilation_errors.jsonl
2. Verificar: E um erro recorrente?
   - SIM (3+ vezes): Criar pre-check especifico
   - NAO: Apenas registrar
3. Categorizar: SYNTAX, SEMANTIC, LINKER
4. Atualizar metricas
```

### Trigger: Fim de Sessao
```
1. Criar entry em sessions.jsonl
2. Calcular metricas da sessao
3. Comparar com media historica
4. Se abaixo da media: Analisar o que deu errado
5. Atualizar metrics.json agregado
```

---

## 5. Queries Uteis

### Bugs mais comuns por modulo
```python
# Pseudo-code
SELECT module, COUNT(*) as bug_count
FROM bugs_encountered
GROUP BY module
ORDER BY bug_count DESC
LIMIT 10
```

### Taxa de deteccao por pattern
```python
SELECT pattern_id, 
       COUNT(CASE WHEN detected THEN 1 END) as detected,
       COUNT(*) as total,
       detected/total as rate
FROM bugs_encountered
GROUP BY pattern_id
```

### Tendencia de melhoria
```python
SELECT WEEK(date) as week,
       AVG(bugs_found) as avg_bugs,
       AVG(compilation_attempts) as avg_compiles
FROM sessions
GROUP BY week
ORDER BY week
```

---

## 6. Integracao com FORGE

### No inicio de cada sessao:
```
1. Carregar metrics.json
2. Identificar: Quais modulos sao "error-prone"?
3. Se trabalhando em modulo error-prone: ALERTA EXTRA
4. Carregar patterns mais recentes
```

### Ao encontrar bug:
```
1. ANTES de corrigir: Verificar learning database
2. "Este bug ja ocorreu antes?"
3. "Qual foi a solucao anterior?"
4. Aplicar solucao validada
5. Registrar ocorrencia
```

### Ao finalizar sessao:
```
1. Sumarizar: Quantos bugs? Quantas compilacoes?
2. Registrar licoes aprendidas
3. Atualizar metricas
4. Se patterns novos identificados: Propor adicao
```

---

## 7. Dashboard de Metricas (Conceitual)

```
┌─────────────────────────────────────────────────────────────┐
│            FORGE LEARNING DASHBOARD                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  DETECCAO DE BUGS          COMPILACAO                       │
│  ┌──────────────┐          ┌──────────────┐                │
│  │    70.1%     │          │    19.2%     │                │
│  │  detectados  │          │ 1st attempt  │                │
│  │  por patterns│          │   success    │                │
│  └──────────────┘          └──────────────┘                │
│                                                             │
│  TENDENCIA (4 semanas)                                      │
│  Bugs/sessao: 3.2 → 1.1 (↓ 65.6%)                          │
│  Compiles/feature: 4.2 → 1.8 (↓ 57.1%)                     │
│                                                             │
│  MODULOS ERROR-PRONE                                        │
│  🔴 CFootprintAnalyzer.mqh (12 bugs)                       │
│  🟠 FTMO_RiskManager.mqh (9 bugs)                          │
│  🟡 CMTFManager.mqh (8 bugs)                               │
│                                                             │
│  PATTERNS MAIS UTEIS                                        │
│  1. BP-02 (ATR handle): 23 deteccoes                       │
│  2. BP-05 (Division zero): 18 deteccoes                    │
│  3. AP-01 (OrderSend): 15 deteccoes                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Comandos de Learning

| Comando | Acao |
|---------|------|
| `/learning stats` | Mostrar metricas agregadas |
| `/learning bugs [modulo]` | Listar bugs de um modulo |
| `/learning patterns` | Mostrar eficacia dos patterns |
| `/learning session` | Registrar fim de sessao |
| `/learning add-bug` | Adicionar bug ao database |

---

## Principio Fundamental

```
"Um genio nao e quem nunca erra.
 E quem APRENDE com cada erro e NUNCA repete."

FORGE v3.1 - Self-Improving Architecture
```

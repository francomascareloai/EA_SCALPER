# GUIA RAPIDO: Rodar EA em 1 Semana

## STATUS: EA PRONTO PARA RODAR!

**Compilacao**: OK (0 errors, 1 warning irrelevante)  
**Versao**: v3.30 - Singularity Order Flow Edition  
**Features**: SMC + MTF + Order Flow + FTMO Risk + Session Filter

---

## DIA 1: SETUP INICIAL (Hoje)

### 1.1 Copiar EA para MT5
```
ORIGEM: C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5\Experts\EA_SCALPER_XAUUSD.mq5
DESTINO: C:\Program Files\FTMO MetaTrader 5\MQL5\Experts\
```

**Comando PowerShell:**
```powershell
Copy-Item -Path "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5\Experts\EA_SCALPER_XAUUSD.ex5" -Destination "C:\Program Files\FTMO MetaTrader 5\MQL5\Experts\" -Force
```

### 1.2 Copiar Includes
```powershell
# Copiar toda a pasta EA_SCALPER
Copy-Item -Path "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5\Include\EA_SCALPER" -Destination "C:\Program Files\FTMO MetaTrader 5\MQL5\Include\" -Recurse -Force
```

### 1.3 Abrir MT5 e Anexar ao Grafico

1. Abrir MetaTrader 5 (FTMO)
2. Abrir grafico XAUUSD M5
3. Navigator > Expert Advisors > EA_SCALPER_XAUUSD
4. Arrastar para o grafico
5. Configurar parametros (ver abaixo)
6. Clicar OK
7. Verificar se "EA" aparece no canto superior direito

---

## DIA 1-2: CONFIGURACAO (Parametros Recomendados)

### PRESET CONSERVADOR (Recomendado para comecar)

```
=== Risk Management (FTMO) ===
InpRiskPerTrade      = 0.5     // 0.5% por trade
InpMaxDailyLoss      = 4.0     // Trigger antes do limite FTMO
InpSoftStop          = 3.5     // Para mais cedo
InpMaxTotalLoss      = 8.0     // Trigger antes do 10%
InpMaxTradesPerDay   = 10      // Conservador

=== Scoring Engine ===
InpExecutionThreshold = 60     // Score minimo para trade

=== Session & Time Filters ===
InpAllowAsian        = false   // Desligado - mais seguro
InpAllowLateNY       = false   // Desligado - mais seguro
InpGMTOffset         = 0       // Ajustar para seu broker
InpFridayCloseHour   = 14      // Parar sexta cedo
InpDisableFridayClose = false  // Ativar friday close

=== News Filter ===
InpNewsFilterEnabled = true    // SEMPRE ON
InpBlockHighImpact   = true    // SEMPRE ON
InpBlockMediumImpact = true    // Recomendado ON

=== ML (Desligado por enquanto) ===
InpUseML             = false   // Deixar OFF ate validar
InpMaxSpreadPoints   = 60      // Spread max conservador

=== Entry Optimization ===
InpMinRR             = 2.0     // R:R minimo 2:1
InpTargetRR          = 3.0     // Target 3:1
InpMaxWaitBars       = 15      // Paciencia

=== MTF Settings ===
InpUseMTF            = true    // Multi-timeframe ON
InpMinMTFConfluence  = 60.0    // Confluencia alta
InpRequireHTFAlign   = true    // Requer H1 alinhado
InpRequireMTFZone    = true    // Requer M15 structure
InpRequireLTFConfirm = true    // Requer M5 confirmacao

=== Mode Settings ===
InpModePreset        = MODE_CONSERVATIVE  // Usar preset conservador
```

### PRESET MODERADO (Depois de 2 semanas em demo)

```
InpModePreset        = MODE_BALANCED
InpRiskPerTrade      = 0.65
InpExecutionThreshold = 50
InpAllowAsian        = false
InpMinRR             = 1.6
```

---

## DIA 2-5: DEMO TESTING

### Checklist Diario

- [ ] Verificar se EA esta rodando (icone no canto)
- [ ] Verificar Journal para erros
- [ ] Verificar trades abertos
- [ ] Verificar DD diario
- [ ] Anotar resultados

### O que Observar

| Metrica | Bom | Ruim |
|---------|-----|------|
| Win Rate | >50% | <40% |
| Avg R:R | >1.5 | <1.0 |
| Max DD | <3% | >5% |
| Trades/dia | 2-5 | >10 |
| Spread blocks | Normal | Muitos |

### Log de Acompanhamento

```
DIA 1: __ trades | __ wins | __% | DD: __%
DIA 2: __ trades | __ wins | __% | DD: __%
DIA 3: __ trades | __ wins | __% | DD: __%
DIA 4: __ trades | __ wins | __% | DD: __%
DIA 5: __ trades | __ wins | __% | DD: __%
```

---

## DIA 6: ANALISE E AJUSTE

### Se Resultado BOM (>5 trades, >50% win, <3% DD):

1. Pode considerar ir para FTMO Challenge
2. Manter parametros conservadores
3. Capital inicial: $100k challenge

### Se Resultado RUIM:

1. Verificar horarios dos trades (Journal)
2. Verificar se news filter esta funcionando
3. Ajustar threshold para 65 ou 70
4. Reduzir risco para 0.35%

---

## DIA 7: DECISAO

### GO para FTMO Challenge se:

- [ ] Pelo menos 10 trades em demo
- [ ] Win rate > 50%
- [ ] Max DD < 4%
- [ ] Nenhum trade bizarro
- [ ] Confortavel com o comportamento

### NO-GO se:

- Win rate < 45%
- DD > 5%
- Muitos trades bloqueados
- Comportamento erratico

---

## COMANDOS UTEIS

### Verificar se EA compilou
```powershell
Get-Content "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5\Experts\EA_SCALPER_XAUUSD.log" -Encoding Unicode | Select-String "error|warning|Result"
```

### Recompilar EA
```powershell
Start-Process -FilePath "C:\Program Files\FTMO MetaTrader 5\metaeditor64.exe" -ArgumentList '/compile:"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5\Experts\EA_SCALPER_XAUUSD.mq5"','/inc:"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5"','/inc:"C:\Program Files\FTMO MetaTrader 5\MQL5"','/log' -Wait -NoNewWindow
```

### Copiar EA atualizado para MT5
```powershell
Copy-Item -Path "C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\MQL5\Experts\EA_SCALPER_XAUUSD.ex5" -Destination "C:\Program Files\FTMO MetaTrader 5\MQL5\Experts\" -Force
```

---

## TROUBLESHOOTING

### EA nao aparece no MT5
- Verificar se .ex5 esta em MQL5\Experts\
- Reiniciar MT5
- Verificar se compilou sem erros

### EA nao faz trades
- Verificar se AutoTrading esta ON (botao verde)
- Verificar spread (pode estar alto)
- Verificar sessao (pode estar fora do horario)
- Verificar Journal para mensagens

### Spread sempre bloqueado
- Aumentar InpMaxSpreadPoints para 80
- Verificar broker (alguns tem spread alto)
- Testar em horario de London/NY

### Muitos trades bloqueados por news
- Normal durante semanas com muitas news
- Verificar calendario economico
- Pode desativar InpBlockMediumImpact

---

## FTMO CHALLENGE CHECKLIST

Antes de iniciar o challenge:

- [ ] EA testado em demo por pelo menos 5 dias
- [ ] Entendo os parametros
- [ ] Sei como pausar o EA se necessario
- [ ] Calendario economico verificado para a semana
- [ ] Broker GMT offset correto
- [ ] VPS configurado (se usar)

**Limites FTMO $100k:**
- Daily DD: 5% ($5,000)
- Total DD: 10% ($10,000)
- Profit Target: 10% ($10,000) Phase 1
- Min Trading Days: 4 dias

---

## CONTATOS RAPIDOS

- **Problemas de compilacao**: Verificar log
- **Ajuste de parametros**: Testar em demo primeiro
- **Duvidas sobre estrategia**: Consultar DOCS/03_RESEARCH/

---

*Ultima atualizacao: 2025-12-02*
*EA Version: v3.30 Singularity Order Flow Edition*

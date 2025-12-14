# Order Flow Analyzer - Documentacao

## Visao Geral

O Order Flow Analyzer e um modulo para analise de fluxo de ordens (footprint) no MT5, projetado especificamente para XAUUSD e outros CFDs.

## Versoes

### V1 (OrderFlowAnalyzer.mqh) - DEPRECATED
- Versao inicial com problemas conhecidos
- **NAO USAR EM PRODUCAO**

### V2 (OrderFlowAnalyzer_v2.mqh) - RECOMENDADA
- Corrige todos os problemas identificados
- Detecta automaticamente qualidade dos dados
- Fallback inteligente quando TICK_FLAG nao disponivel

---

## Problemas Resolvidos na V2

| Problema | V1 | V2 |
|----------|----|----|
| TICK_FLAG indisponivel em Forex/CFD | Falha silenciosa | Detecta e usa fallback |
| SymbolInfoTick() sem flags | Usa incorretamente | Usa CopyTicks() |
| Performance com muitos ticks | Lento | Amostragem inteligente |
| Validacao de dados | Nenhuma | Completa |
| Value Area | Nao tem | Implementado |
| Cache de resultados | Nao tem | Implementado |
| Qualidade dos dados | Nao reporta | Reporta ENUM_DATA_QUALITY |

---

## Como Usar

### Inicializacao

```mql5
#include <EA_SCALPER\Analysis\OrderFlowAnalyzer_v2.mqh>

COrderFlowAnalyzerV2 g_orderFlow;

int OnInit() {
   // Inicializa com deteccao automatica do melhor metodo
   if(!g_orderFlow.Initialize(_Symbol, PERIOD_M15, 200, 3.0, 0.70, METHOD_AUTO)) {
      Print("Erro ao inicializar Order Flow!");
      return INIT_FAILED;
   }
   return INIT_SUCCEEDED;
}
```

### Processamento em Tempo Real

```mql5
void OnTick() {
   // Processa tick atual (usa CopyTicks internamente)
   g_orderFlow.ProcessTick();
   
   // Obtem resultado
   SOrderFlowResultV2 result = g_orderFlow.GetResult();
   
   // Verifica qualidade dos dados
   if(!g_orderFlow.IsDataReliable()) {
      // Dados nao confiaveis, usar com cautela
   }
   
   // Usa delta para decisoes
   if(result.barDelta > 500 && result.hasStrongImbalance) {
      // Forte pressao compradora
   }
}
```

### Analise de Barras Historicas

```mql5
// Analisa barra anterior
g_orderFlow.ProcessBarTicks(1);
SOrderFlowResultV2 result = g_orderFlow.GetResult();

// Value Area
SValueArea va = result.valueArea;
Print("POC: ", va.poc);
Print("VA High: ", va.vahigh);
Print("VA Low: ", va.valow);
```

### Sinais de Trading

```mql5
// Sinal baseado em delta e imbalance
int signal = g_orderFlow.GetSignal(500); // threshold = 500
// 1 = BUY, -1 = SELL, 0 = NEUTRO

// Deteccao de divergencia
if(g_orderFlow.IsDeltaDivergence()) {
   // Preco e delta divergindo - possivel reversao
}

// Deteccao de absorcao
if(g_orderFlow.IsAbsorption(1000)) {
   // Alto volume, delta neutro - grandes players absorvendo
}

// Defesa no POC
if(g_orderFlow.IsPOCDefense()) {
   // Preco no POC com alto volume - nivel importante
}
```

---

## Estruturas de Dados

### SOrderFlowResultV2

```mql5
struct SOrderFlowResultV2 {
   // Delta
   long   barDelta;           // Delta total da barra
   long   cumulativeDelta;    // Delta acumulado na sessao
   double deltaPercent;       // Delta como % do volume
   bool   isBuyDominant;      // Compradores dominantes?
   
   // Value Area
   SValueArea valueArea;      // POC, VA High, VA Low
   
   // Volumes
   long   totalBuyVolume;     // Volume de compra
   long   totalSellVolume;    // Volume de venda
   long   totalTicks;         // Total de ticks processados
   
   // Imbalances
   double imbalanceUp;        // Preco com imbalance de compra
   double imbalanceDown;      // Preco com imbalance de venda
   bool   hasStrongImbalance; // Tem imbalance forte?
   int    imbalanceCount;     // Quantidade de imbalances
   
   // Qualidade
   ENUM_DATA_QUALITY dataQuality;
   double flagAvailabilityPercent;
};
```

### SValueArea

```mql5
struct SValueArea {
   double poc;        // Point of Control (maior volume)
   double vahigh;     // Value Area High (70% do volume)
   double valow;      // Value Area Low (70% do volume)
   long   pocVolume;  // Volume no POC
   long   totalVolume;// Volume total
};
```

---

## Qualidade dos Dados

O analyzer reporta a qualidade dos dados automaticamente:

| ENUM_DATA_QUALITY | Significado | Acao |
|-------------------|-------------|------|
| QUALITY_EXCELLENT | >95% flags disponiveis | Usar normalmente |
| QUALITY_GOOD | 80-95% flags | Usar normalmente |
| QUALITY_MODERATE | 50-80% flags | Usar com cautela |
| QUALITY_POOR | <50% flags | Resultados aproximados |
| QUALITY_UNKNOWN | Sem dados | Nao usar |

### Verificar Confiabilidade

```mql5
if(g_orderFlow.IsDataReliable()) {
   // Dados confiaveis (GOOD ou EXCELLENT)
   // Pode usar para trading
}
else {
   // Dados NAO confiaveis
   // Usar apenas como indicacao, nao como sinal principal
}
```

---

## Metodos de Deteccao de Direcao

| Metodo | Descricao | Precisao |
|--------|-----------|----------|
| METHOD_TICK_FLAG | Usa TICK_FLAG_BUY/SELL | Alta (quando disponivel) |
| METHOD_PRICE_COMPARE | Compara com preco anterior | Media |
| METHOD_BID_ASK | Compara last com bid/ask | Media |
| METHOD_AUTO | Detecta melhor metodo | Variavel |

**Recomendacao:** Use `METHOD_AUTO` para que o analyzer detecte automaticamente o melhor metodo disponivel para seu broker.

---

## Limitacoes Conhecidas

### 1. Mercado OTC (Forex/CFD)
- XAUUSD e mercado OTC, nao tem order book centralizado
- Delta e uma APROXIMACAO, nao valor exato
- Resultados variam entre brokers

### 2. Tick Volume vs Real Volume
- MT5 fornece tick volume (contagem de ticks)
- NAO e volume real de contratos
- Um tick de 100 lotes = um tick de 0.01 lote

### 3. Dados Historicos
- Qualidade depende do broker
- Alguns brokers nao armazenam flags historicos

---

## Integracao com SMC

```mql5
// Exemplo: Adicionar score de Order Flow a um Order Block
int GetOrderFlowScore(double obLevel, bool isBullishOB) {
   SOrderFlowResultV2 of = g_orderFlow.GetResult();
   int score = 0;
   
   // Verifica qualidade primeiro
   if(!g_orderFlow.IsDataReliable()) {
      return 0; // Nao adiciona score se dados nao confiaveis
   }
   
   if(isBullishOB) {
      // OB bullish precisa de delta positivo
      if(of.barDelta > 300) score += 10;
      if(of.barDelta > 500) score += 5;
      if(of.imbalanceUp > 0 && of.imbalanceUp <= obLevel) score += 15;
      if(of.deltaPercent > 20) score += 5;
   }
   else {
      // OB bearish precisa de delta negativo
      if(of.barDelta < -300) score += 10;
      if(of.barDelta < -500) score += 5;
      if(of.imbalanceDown > 0 && of.imbalanceDown >= obLevel) score += 15;
      if(of.deltaPercent < -20) score += 5;
   }
   
   return score;
}
```

---

## Teste de Validacao

Execute o script `TestOrderFlowAnalyzer.mq5` para verificar:
1. Se seu broker fornece TICK_FLAG
2. Qualidade dos dados
3. Se o analyzer esta funcionando corretamente

```
Scripts -> TestOrderFlowAnalyzer
```

---

## Arquivos

```
MQL5/Include/EA_SCALPER/Analysis/
├── OrderFlowAnalyzer.mqh      # V1 - DEPRECATED
├── OrderFlowAnalyzer_v2.mqh   # V2 - USAR ESTA
├── OrderFlowExample.mqh       # Exemplos de uso
└── ORDER_FLOW_README.md       # Esta documentacao

MQL5/Scripts/
└── TestOrderFlowAnalyzer.mq5  # Script de teste
```

---

## Changelog

### V2.0 (2025-11-28)
- Deteccao automatica de disponibilidade de TICK_FLAG
- Fallback para metodo de comparacao de preco
- Implementacao de Value Area (POC, VA High, VA Low)
- Cache de resultados para performance
- Validacao de qualidade dos dados
- Amostragem inteligente para grandes datasets
- Deteccao de absorcao e divergencia
- Suporte a sessoes de trading

### V1.0 (2025-11-28)
- Versao inicial (deprecated)

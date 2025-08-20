# ESPECIFICAÇÕES TÉCNICAS - EA FTMO SCALPER ELITE

## ÍNDICE
1. [Parâmetros de Entrada](#parâmetros-de-entrada)
2. [Configurações de Estratégia](#configurações-de-estratégia)
3. [Gestão de Risco](#gestão-de-risco)
4. [Compliance FTMO](#compliance-ftmo)
5. [Indicadores Técnicos](#indicadores-técnicos)
6. [Timeframes e Símbolos](#timeframes-e-símbolos)
7. [Performance Targets](#performance-targets)
8. [Configurações de Sistema](#configurações-de-sistema)
9. [Alertas e Notificações](#alertas-e-notificações)
10. [Logging e Auditoria](#logging-e-auditoria)

---

## PARÂMETROS DE ENTRADA

### Configurações Gerais
```mql5
//+------------------------------------------------------------------+
//|                           PARÂMETROS GERAIS                      |
//+------------------------------------------------------------------+
input group "═══════════════ CONFIGURAÇÕES GERAIS ═══════════════"
input ulong                InpMagicNumber        = 20241201;           // Magic Number
input string               InpEAComment          = "FTMO_Scalper_Elite"; // Comentário do EA
input bool                 InpTradingEnabled     = true;               // Habilitar Trading
input bool                 InpAutoLotSize        = true;               // Tamanho de Lote Automático
input double               InpFixedLotSize       = 0.01;               // Tamanho de Lote Fixo
input int                  InpMaxSpread          = 30;                 // Spread Máximo (pontos)
input bool                 InpECNMode            = true;               // Modo ECN (sem SL/TP na ordem)

//+------------------------------------------------------------------+
//|                        CONFIGURAÇÕES DE TEMPO                    |
//+------------------------------------------------------------------+
input group "═══════════════ CONFIGURAÇÕES DE TEMPO ═══════════════"
input bool                 InpUseTimeFilter      = true;               // Usar Filtro de Tempo
input string               InpStartTime          = "08:00";             // Hora de Início (GMT)
input string               InpEndTime            = "18:00";             // Hora de Fim (GMT)
input bool                 InpTradeFriday        = false;              // Negociar na Sexta-feira
input int                  InpFridayCloseHour    = 15;                 // Hora de Fechamento na Sexta (GMT)
input bool                 InpAvoidNews          = true;               // Evitar Notícias de Alto Impacto
input int                  InpNewsFilterMinutes  = 30;                 // Minutos antes/depois das notícias
```

### Configurações ICT/SMC
```mql5
//+------------------------------------------------------------------+
//|                      CONFIGURAÇÕES ICT/SMC                       |
//+------------------------------------------------------------------+
input group "═══════════════ ESTRATÉGIA ICT/SMC ═══════════════"
input bool                 InpUseOrderBlocks     = true;               // Usar Order Blocks
input int                  InpOBLookback         = 20;                 // Lookback Order Blocks
input double               InpOBMinSize          = 10.0;               // Tamanho Mínimo OB (pontos)
input int                  InpOBValidityBars     = 50;                 // Validade OB (barras)

input bool                 InpUseFVG             = true;               // Usar Fair Value Gaps
input double               InpFVGMinSize         = 5.0;                // Tamanho Mínimo FVG (pontos)
input int                  InpFVGValidityBars    = 30;                 // Validade FVG (barras)
input double               InpFVGFillPercent     = 50.0;               // % de Preenchimento FVG

input bool                 InpUseLiquidity       = true;               // Usar Liquidez
input int                  InpLiquidityLookback  = 50;                 // Lookback Liquidez
input double               InpLiquidityBuffer    = 2.0;                // Buffer Liquidez (pontos)
input int                  InpMinTouchesHL       = 2;                  // Mín. Toques H/L

input bool                 InpUseMarketStructure = true;               // Usar Estrutura de Mercado
input int                  InpMSLookback         = 100;                // Lookback Estrutura
input double               InpBOSMinSize         = 15.0;               // Tamanho Mín. BOS (pontos)
input double               InpChoCHMinSize       = 20.0;               // Tamanho Mín. ChoCH (pontos)
```

### Configurações de Volume
```mql5
//+------------------------------------------------------------------+
//|                     CONFIGURAÇÕES DE VOLUME                      |
//+------------------------------------------------------------------+
input group "═══════════════ ANÁLISE DE VOLUME ═══════════════"
input bool                 InpUseVolumeAnalysis  = true;               // Usar Análise de Volume
input int                  InpVolumeMAPeriod     = 20;                 // Período MA Volume
input double               InpVolumeSpikeMultiplier = 2.0;             // Multiplicador Spike Volume
input bool                 InpUseVolumeProfile   = true;               // Usar Volume Profile
input int                  InpVPLookback         = 100;                // Lookback Volume Profile
input int                  InpVPLevels           = 50;                 // Níveis Volume Profile
input double               InpVAPercent          = 70.0;               // % Value Area

input bool                 InpUseTickVolume      = true;               // Usar Tick Volume
input bool                 InpUseRealVolume      = false;              // Usar Volume Real (se disponível)
input int                  InpVolumeConfirmBars  = 3;                  // Barras Confirmação Volume
```

---

## CONFIGURAÇÕES DE ESTRATÉGIA

### Setup de Entrada
```mql5
//+------------------------------------------------------------------+
//|                       SETUP DE ENTRADA                           |
//+------------------------------------------------------------------+
input group "═══════════════ CONFIGURAÇÕES DE ENTRADA ═══════════════"
input bool                 InpRequireAllSignals  = false;              // Exigir Todos os Sinais
input int                  InpMinSignalStrength  = 3;                  // Força Mínima do Sinal (1-5)
input bool                 InpUseMultiTimeframe  = true;               // Usar Multi-Timeframe
input ENUM_TIMEFRAMES      InpHTF1               = PERIOD_H1;          // Higher Timeframe 1
input ENUM_TIMEFRAMES      InpHTF2               = PERIOD_H4;          // Higher Timeframe 2
input double               InpEntryBuffer        = 1.0;                // Buffer de Entrada (pontos)

// Configurações de Confluência
input bool                 InpRequireOBConfluence = true;              // Exigir Confluência OB
input bool                 InpRequireFVGConfluence = true;             // Exigir Confluência FVG
input bool                 InpRequireVolumeConfluence = true;          // Exigir Confluência Volume
input bool                 InpRequireMSConfluence = true;              // Exigir Confluência MS

// Filtros de Entrada
input bool                 InpUseATRFilter       = true;               // Usar Filtro ATR
input int                  InpATRPeriod          = 14;                 // Período ATR
input double               InpATRMultiplier      = 1.5;                // Multiplicador ATR
input bool                 InpUseTrendFilter     = true;               // Usar Filtro de Tendência
input int                  InpTrendMAPeriod      = 50;                 // Período MA Tendência
```

### Setup de Saída
```mql5
//+------------------------------------------------------------------+
//|                        SETUP DE SAÍDA                            |
//+------------------------------------------------------------------+
input group "═══════════════ CONFIGURAÇÕES DE SAÍDA ═══════════════"
input bool                 InpUseFixedTP         = false;              // Usar TP Fixo
input double               InpFixedTPPoints      = 50.0;               // TP Fixo (pontos)
input bool                 InpUseDynamicTP       = true;               // Usar TP Dinâmico
input double               InpTPRiskReward       = 2.0;                // Risk:Reward Ratio

input bool                 InpUseFixedSL         = false;              // Usar SL Fixo
input double               InpFixedSLPoints      = 25.0;               // SL Fixo (pontos)
input bool                 InpUseDynamicSL       = true;               // Usar SL Dinâmico
input double               InpSLATRMultiplier    = 1.0;                // Multiplicador ATR para SL

// Trailing Stop
input bool                 InpUseTrailingStop    = true;               // Usar Trailing Stop
input double               InpTrailingStart      = 20.0;               // Início Trailing (pontos)
input double               InpTrailingStep       = 5.0;                // Passo Trailing (pontos)
input bool                 InpUseBreakeven       = true;               // Usar Breakeven
input double               InpBreakevenPoints    = 15.0;               // Pontos para Breakeven
input double               InpBreakevenBuffer    = 2.0;                // Buffer Breakeven

// Saída Parcial
input bool                 InpUsePartialClose    = true;               // Usar Fechamento Parcial
input double               InpPartialClosePercent = 50.0;              // % Fechamento Parcial
input double               InpPartialClosePoints = 30.0;               // Pontos para Fechamento Parcial
```

---

## GESTÃO DE RISCO

### Configurações de Risco
```mql5
//+------------------------------------------------------------------+
//|                       GESTÃO DE RISCO                            |
//+------------------------------------------------------------------+
input group "═══════════════ GESTÃO DE RISCO ═══════════════"
input double               InpRiskPercent        = 1.0;                // Risco por Trade (%)
input double               InpMaxDailyRisk       = 3.0;                // Risco Máximo Diário (%)
input double               InpMaxWeeklyRisk      = 5.0;                // Risco Máximo Semanal (%)
input double               InpMaxMonthlyRisk     = 10.0;               // Risco Máximo Mensal (%)

// Position Sizing
input ENUM_POSITION_SIZE_METHOD InpPositionSizeMethod = PS_FIXED_RISK;  // Método Position Sizing
input double               InpMinLotSize         = 0.01;               // Lote Mínimo
input double               InpMaxLotSize         = 1.0;                // Lote Máximo
input double               InpLotSizeStep        = 0.01;               // Passo Lote

// Correlação
input bool                 InpCheckCorrelation   = true;               // Verificar Correlação
input double               InpMaxCorrelation     = 0.7;                // Correlação Máxima
input int                  InpCorrelationPeriod  = 20;                 // Período Correlação

// Drawdown
input double               InpMaxDrawdown        = 5.0;                // Drawdown Máximo (%)
input bool                 InpStopOnDrawdown     = true;               // Parar no Drawdown
input double               InpDrawdownRecovery   = 2.0;                // % Recuperação para Retomar
```

### Configurações Avançadas de Risco
```mql5
//+------------------------------------------------------------------+
//|                   CONFIGURAÇÕES AVANÇADAS DE RISCO               |
//+------------------------------------------------------------------+
input group "═══════════════ RISCO AVANÇADO ═══════════════"
// Kelly Criterion
input bool                 InpUseKellyCriterion  = false;              // Usar Kelly Criterion
input int                  InpKellyLookback      = 50;                 // Lookback Kelly
input double               InpKellyMultiplier    = 0.25;               // Multiplicador Kelly

// Volatility Adjustment
input bool                 InpAdjustForVolatility = true;              // Ajustar por Volatilidade
input int                  InpVolatilityPeriod   = 20;                 // Período Volatilidade
input double               InpVolatilityThreshold = 1.5;               // Threshold Volatilidade

// Heat Map
input bool                 InpUseHeatMap         = true;               // Usar Heat Map
input int                  InpHeatMapPeriod      = 10;                 // Período Heat Map
input double               InpHeatMapThreshold   = 3.0;                // Threshold Heat Map

// Recovery Mode
input bool                 InpUseRecoveryMode    = true;               // Usar Modo Recuperação
input double               InpRecoveryThreshold  = 2.0;                // Threshold Recuperação (%)
input double               InpRecoveryMultiplier = 0.5;                // Multiplicador Recuperação
```

---

## COMPLIANCE FTMO

### Regras FTMO
```mql5
//+------------------------------------------------------------------+
//|                        COMPLIANCE FTMO                           |
//+------------------------------------------------------------------+
input group "═══════════════ COMPLIANCE FTMO ═══════════════"
input bool                 InpFTMOMode           = true;               // Modo FTMO
input double               InpFTMODailyLoss      = 5.0;                // Perda Diária Máxima FTMO (%)
input double               InpFTMOMaxDrawdown    = 10.0;               // Drawdown Máximo FTMO (%)
input double               InpFTMOMinTradeDays   = 4.0;                // Mín. Dias de Trading
input double               InpFTMOProfitTarget   = 8.0;                // Meta de Lucro FTMO (%)

// Verificações de Segurança
input bool                 InpStrictCompliance   = true;               // Compliance Rigoroso
input double               InpSafetyBuffer       = 0.5;                // Buffer de Segurança (%)
input bool                 InpAutoStopOnViolation = true;              // Parar Auto em Violação
input bool                 InpLogViolations      = true;               // Log Violações

// Monitoramento
input bool                 InpRealTimeMonitoring = true;               // Monitoramento Tempo Real
input int                  InpMonitoringInterval = 60;                 // Intervalo Monitoramento (seg)
input bool                 InpSendAlerts         = true;               // Enviar Alertas
input bool                 InpEmailAlerts        = false;              // Alertas por Email
```

### Configurações de Conta
```mql5
//+------------------------------------------------------------------+
//|                    CONFIGURAÇÕES DE CONTA                        |
//+------------------------------------------------------------------+
input group "═══════════════ CONFIGURAÇÕES DE CONTA ═══════════════"
input ENUM_ACCOUNT_TYPE    InpAccountType        = ACCOUNT_FTMO;       // Tipo de Conta
input double               InpAccountSize        = 100000.0;           // Tamanho da Conta
input string               InpAccountCurrency    = "USD";              // Moeda da Conta
input bool                 InpIsDemo             = true;               // Conta Demo
input bool                 InpIsChallenge        = false;              // Conta Challenge
input bool                 InpIsFunded           = false;              // Conta Funded

// Limites Específicos
input double               InpChallengeTarget    = 8.0;                // Meta Challenge (%)
input double               InpVerificationTarget = 5.0;                // Meta Verification (%)
input int                  InpMinTradingDays     = 4;                  // Mín. Dias Trading
input int                  InpMaxTradingDays     = 30;                 // Máx. Dias Trading
```

---

## INDICADORES TÉCNICOS

### Indicadores Customizados
```mql5
//+------------------------------------------------------------------+
//|                     INDICADORES CUSTOMIZADOS                     |
//+------------------------------------------------------------------+
input group "═══════════════ INDICADORES CUSTOMIZADOS ═══════════════"
// Order Blocks Indicator
input bool                 InpShowOrderBlocks    = true;               // Mostrar Order Blocks
input color                InpBullishOBColor     = clrBlue;            // Cor OB Bullish
input color                InpBearishOBColor     = clrRed;             // Cor OB Bearish
input int                  InpOBLineWidth        = 2;                  // Largura Linha OB
input ENUM_LINE_STYLE      InpOBLineStyle        = STYLE_SOLID;        // Estilo Linha OB

// FVG Indicator
input bool                 InpShowFVG            = true;               // Mostrar FVG
input color                InpBullishFVGColor    = clrLimeGreen;       // Cor FVG Bullish
input color                InpBearishFVGColor    = clrOrangeRed;       // Cor FVG Bearish
input int                  InpFVGTransparency    = 80;                 // Transparência FVG

// Liquidity Indicator
input bool                 InpShowLiquidity      = true;               // Mostrar Liquidez
input color                InpLiquidityColor     = clrYellow;          // Cor Liquidez
input int                  InpLiquidityWidth     = 1;                  // Largura Liquidez
input ENUM_LINE_STYLE      InpLiquidityStyle     = STYLE_DASH;         // Estilo Liquidez

// Market Structure
input bool                 InpShowMarketStructure = true;              // Mostrar Estrutura
input color                InpBOSColor           = clrGreen;           // Cor BOS
input color                InpChoCHColor         = clrPurple;          // Cor ChoCH
input int                  InpMSLineWidth        = 2;                  // Largura Linha MS
```

### Indicadores Padrão
```mql5
//+------------------------------------------------------------------+
//|                      INDICADORES PADRÃO                          |
//+------------------------------------------------------------------+
input group "═══════════════ INDICADORES PADRÃO ═══════════════"
// ATR
input bool                 InpUseATR             = true;               // Usar ATR
input int                  InpATRPeriod          = 14;                 // Período ATR
input ENUM_APPLIED_PRICE   InpATRAppliedPrice    = PRICE_CLOSE;        // Preço Aplicado ATR

// Moving Averages
input bool                 InpUseMA              = true;               // Usar Moving Average
input int                  InpMAPeriod           = 50;                 // Período MA
input ENUM_MA_METHOD       InpMAMethod           = MODE_EMA;           // Método MA
input ENUM_APPLIED_PRICE   InpMAAppliedPrice     = PRICE_CLOSE;        // Preço Aplicado MA

// RSI
input bool                 InpUseRSI             = false;              // Usar RSI
input int                  InpRSIPeriod          = 14;                 // Período RSI
input ENUM_APPLIED_PRICE   InpRSIAppliedPrice    = PRICE_CLOSE;        // Preço Aplicado RSI
input double               InpRSIOverbought      = 70.0;               // RSI Sobrecomprado
input double               InpRSIOversold        = 30.0;               // RSI Sobrevendido

// MACD
input bool                 InpUseMACD            = false;              // Usar MACD
input int                  InpMACDFastEMA        = 12;                 // MACD Fast EMA
input int                  InpMACDSlowEMA        = 26;                 // MACD Slow EMA
input int                  InpMACDSignalSMA      = 9;                  // MACD Signal SMA
input ENUM_APPLIED_PRICE   InpMACDAppliedPrice   = PRICE_CLOSE;        // Preço Aplicado MACD
```

---

## TIMEFRAMES E SÍMBOLOS

### Configurações de Timeframe
```mql5
//+------------------------------------------------------------------+
//|                   CONFIGURAÇÕES DE TIMEFRAME                     |
//+------------------------------------------------------------------+
input group "═══════════════ TIMEFRAMES ═══════════════"
input ENUM_TIMEFRAMES      InpExecutionTimeframe = PERIOD_M15;         // Timeframe Execução
input ENUM_TIMEFRAMES      InpAnalysisTimeframe  = PERIOD_H1;          // Timeframe Análise
input ENUM_TIMEFRAMES      InpTrendTimeframe     = PERIOD_H4;          // Timeframe Tendência
input ENUM_TIMEFRAMES      InpStructureTimeframe = PERIOD_D1;          // Timeframe Estrutura

// Multi-Timeframe Analysis
input bool                 InpUseMTFAnalysis     = true;               // Usar Análise MTF
input bool                 InpMTFAlignment       = true;               // Exigir Alinhamento MTF
input int                  InpMTFLookback        = 50;                 // Lookback MTF

// Timeframe Weights
input double               InpM15Weight          = 1.0;                // Peso M15
input double               InpH1Weight           = 1.5;                // Peso H1
input double               InpH4Weight           = 2.0;                // Peso H4
input double               InpD1Weight           = 2.5;                // Peso D1
```

### Configurações de Símbolo
```mql5
//+------------------------------------------------------------------+
//|                    CONFIGURAÇÕES DE SÍMBOLO                      |
//+------------------------------------------------------------------+
input group "═══════════════ SÍMBOLOS ═══════════════"
input string               InpTradingSymbol      = "XAUUSD";           // Símbolo Principal
input bool                 InpMultiSymbol        = false;              // Multi-Símbolo
input string               InpSymbolList         = "XAUUSD,EURUSD,GBPUSD"; // Lista Símbolos

// Configurações Específicas XAUUSD
input double               InpXAUUSDSpreadMax    = 30.0;               // Spread Máximo XAUUSD
input double               InpXAUUSDMinMove      = 10.0;               // Movimento Mínimo XAUUSD
input bool                 InpXAUUSDNewsFilter   = true;               // Filtro Notícias XAUUSD
input string               InpXAUUSDSessions     = "London,NewYork";   // Sessões XAUUSD

// Configurações de Mercado
input bool                 InpCheckMarketHours   = true;               // Verificar Horário Mercado
input bool                 InpAvoidRollover      = true;               // Evitar Rollover
input int                  InpRolloverBuffer     = 30;                 // Buffer Rollover (min)
```

---

## PERFORMANCE TARGETS

### Metas de Performance
```mql5
//+------------------------------------------------------------------+
//|                      METAS DE PERFORMANCE                        |
//+------------------------------------------------------------------+
input group "═══════════════ METAS DE PERFORMANCE ═══════════════"
// Metas Mensais
input double               InpMonthlyProfitTarget = 8.0;               // Meta Lucro Mensal (%)
input double               InpMonthlyMaxDD       = 3.0;                // Drawdown Máximo Mensal (%)
input double               InpMonthlyMinWinRate  = 60.0;               // Win Rate Mínimo Mensal (%)
input double               InpMonthlyMinPF       = 1.3;                // Profit Factor Mínimo Mensal

// Metas Semanais
input double               InpWeeklyProfitTarget = 2.0;                // Meta Lucro Semanal (%)
input double               InpWeeklyMaxDD        = 1.5;                // Drawdown Máximo Semanal (%)
input int                  InpWeeklyMinTrades    = 10;                 // Trades Mínimos Semanais

// Metas Diárias
input double               InpDailyProfitTarget  = 0.5;                // Meta Lucro Diário (%)
input double               InpDailyMaxLoss       = 1.0;                // Perda Máxima Diária (%)
input int                  InpDailyMaxTrades     = 5;                  // Trades Máximos Diários

// Metas de Qualidade
input double               InpTargetSharpeRatio  = 1.5;                // Sharpe Ratio Alvo
input double               InpTargetSortinoRatio = 2.0;                // Sortino Ratio Alvo
input double               InpTargetCalmarRatio  = 3.0;                // Calmar Ratio Alvo
input double               InpMaxConsecutiveLosses = 3;                // Perdas Consecutivas Máx
```

### Benchmarks
```mql5
//+------------------------------------------------------------------+
//|                          BENCHMARKS                              |
//+------------------------------------------------------------------+
input group "═══════════════ BENCHMARKS ═══════════════"
// Performance Benchmarks
input double               InpBenchmarkReturn    = 12.0;               // Retorno Benchmark Anual (%)
input double               InpBenchmarkVolatility = 15.0;              // Volatilidade Benchmark (%)
input double               InpBenchmarkMaxDD     = 8.0;                // Max DD Benchmark (%)

// Comparação com Mercado
input bool                 InpCompareWithMarket  = true;               // Comparar com Mercado
input string               InpBenchmarkSymbol    = "SPX500";           // Símbolo Benchmark
input double               InpBeta               = 0.5;                // Beta Alvo
input double               InpAlpha              = 5.0;                // Alpha Alvo (%)

// Métricas Avançadas
input double               InpInformationRatio   = 1.0;                // Information Ratio Alvo
input double               InpTreynorRatio       = 10.0;               // Treynor Ratio Alvo
input double               InpJensenAlpha        = 3.0;                // Jensen Alpha Alvo (%)
```

---

## CONFIGURAÇÕES DE SISTEMA

### Performance do Sistema
```mql5
//+------------------------------------------------------------------+
//|                   CONFIGURAÇÕES DE SISTEMA                       |
//+------------------------------------------------------------------+
input group "═══════════════ PERFORMANCE DO SISTEMA ═══════════════"
// Cache Settings
input bool                 InpUseCache           = true;               // Usar Cache
input int                  InpCacheSize          = 1000;               // Tamanho Cache
input int                  InpCacheTimeout       = 300;                // Timeout Cache (seg)
input bool                 InpPreloadData        = true;               // Pré-carregar Dados

// Memory Management
input int                  InpMaxMemoryUsage     = 100;                // Uso Máximo Memória (MB)
input bool                 InpAutoGarbageCollect = true;               // Coleta Lixo Automática
input int                  InpGCInterval         = 3600;               // Intervalo GC (seg)

// Processing Optimization
input bool                 InpOptimizeProcessing = true;               // Otimizar Processamento
input int                  InpMaxProcessingTime  = 50;                 // Tempo Máx Processamento (ms)
input bool                 InpAsyncProcessing    = false;              // Processamento Assíncrono
input int                  InpThreadPoolSize     = 2;                  // Tamanho Pool Threads
```

### Configurações de Rede
```mql5
//+------------------------------------------------------------------+
//|                    CONFIGURAÇÕES DE REDE                         |
//+------------------------------------------------------------------+
input group "═══════════════ CONFIGURAÇÕES DE REDE ═══════════════"
// Connection Settings
input int                  InpConnectionTimeout  = 5000;               // Timeout Conexão (ms)
input int                  InpMaxRetries         = 3;                  // Tentativas Máximas
input int                  InpRetryDelay         = 1000;               // Delay entre Tentativas (ms)

// Data Feed
input bool                 InpCheckDataFeed      = true;               // Verificar Feed Dados
input int                  InpDataFeedTimeout    = 10;                 // Timeout Feed (seg)
input bool                 InpReconnectOnError   = true;               // Reconectar em Erro

// External Services
input bool                 InpUseExternalAPI     = false;              // Usar API Externa
input string               InpAPIEndpoint        = "";                 // Endpoint API
input string               InpAPIKey             = "";                 // Chave API
input int                  InpAPIRateLimit       = 100;                // Limite Taxa API
```

---

## ALERTAS E NOTIFICAÇÕES

### Sistema de Alertas
```mql5
//+------------------------------------------------------------------+
//|                     SISTEMA DE ALERTAS                           |
//+------------------------------------------------------------------+
input group "═══════════════ SISTEMA DE ALERTAS ═══════════════"
// Alert Types
input bool                 InpEnableAlerts       = true;               // Habilitar Alertas
input bool                 InpPopupAlerts        = true;               // Alertas Popup
input bool                 InpSoundAlerts        = true;               // Alertas Sonoros
input bool                 InpEmailAlerts        = false;              // Alertas Email
input bool                 InpPushNotifications  = false;              // Notificações Push

// Alert Levels
input bool                 InpAlertOnEntry       = true;               // Alerta Entrada
input bool                 InpAlertOnExit        = true;               // Alerta Saída
input bool                 InpAlertOnError       = true;               // Alerta Erro
input bool                 InpAlertOnViolation   = true;               // Alerta Violação
input bool                 InpAlertOnTarget      = true;               // Alerta Meta

// Sound Settings
input string               InpEntrySound         = "alert.wav";        // Som Entrada
input string               InpExitSound          = "alert2.wav";       // Som Saída
input string               InpErrorSound         = "error.wav";        // Som Erro
input string               InpViolationSound     = "stops_levels.wav"; // Som Violação
```

### Notificações Avançadas
```mql5
//+------------------------------------------------------------------+
//|                   NOTIFICAÇÕES AVANÇADAS                         |
//+------------------------------------------------------------------+
input group "═══════════════ NOTIFICAÇÕES AVANÇADAS ═══════════════"
// Telegram Integration
input bool                 InpUseTelegram        = false;              // Usar Telegram
input string               InpTelegramBotToken   = "";                 // Token Bot Telegram
input string               InpTelegramChatID     = "";                 // Chat ID Telegram

// Discord Integration
input bool                 InpUseDiscord         = false;              // Usar Discord
input string               InpDiscordWebhook     = "";                 // Webhook Discord

// Slack Integration
input bool                 InpUseSlack           = false;              // Usar Slack
input string               InpSlackWebhook       = "";                 // Webhook Slack

// Custom Webhook
input bool                 InpUseCustomWebhook   = false;              // Usar Webhook Custom
input string               InpCustomWebhookURL   = "";                 // URL Webhook Custom
input string               InpWebhookFormat      = "JSON";             // Formato Webhook
```

---

## LOGGING E AUDITORIA

### Sistema de Logging
```mql5
//+------------------------------------------------------------------+
//|                      SISTEMA DE LOGGING                          |
//+------------------------------------------------------------------+
input group "═══════════════ SISTEMA DE LOGGING ═══════════════"
// Log Levels
input ENUM_LOG_LEVEL       InpLogLevel           = LOG_LEVEL_INFO;     // Nível de Log
input bool                 InpLogToFile          = true;               // Log para Arquivo
input bool                 InpLogToConsole       = true;               // Log para Console
input bool                 InpLogToJournal       = false;              // Log para Journal

// Log Categories
input bool                 InpLogTrades          = true;               // Log Trades
input bool                 InpLogSignals         = true;               // Log Sinais
input bool                 InpLogErrors          = true;               // Log Erros
input bool                 InpLogPerformance     = true;               // Log Performance
input bool                 InpLogCompliance      = true;               // Log Compliance

// File Settings
input string               InpLogFileName        = "EA_FTMO_Scalper";   // Nome Arquivo Log
input int                  InpMaxLogFileSize     = 10;                 // Tamanho Máx Arquivo (MB)
input int                  InpLogRetentionDays   = 30;                 // Dias Retenção Log
input bool                 InpCompressOldLogs    = true;               // Comprimir Logs Antigos
```

### Auditoria e Compliance
```mql5
//+------------------------------------------------------------------+
//|                    AUDITORIA E COMPLIANCE                        |
//+------------------------------------------------------------------+
input group "═══════════════ AUDITORIA E COMPLIANCE ═══════════════"
// Audit Trail
input bool                 InpEnableAuditTrail   = true;               // Habilitar Auditoria
input bool                 InpAuditAllActions    = true;               // Auditar Todas Ações
input bool                 InpAuditDecisions     = true;               // Auditar Decisões
input bool                 InpAuditRiskChecks    = true;               // Auditar Verificações Risco

// Compliance Reporting
input bool                 InpGenerateReports    = true;               // Gerar Relatórios
input int                  InpReportInterval     = 24;                 // Intervalo Relatórios (horas)
input bool                 InpAutoExportReports  = true;               // Auto Exportar Relatórios
input string               InpReportFormat       = "CSV";              // Formato Relatórios

// Data Retention
input int                  InpDataRetentionDays  = 365;                // Dias Retenção Dados
input bool                 InpArchiveOldData     = true;               // Arquivar Dados Antigos
input bool                 InpEncryptSensitiveData = true;             // Criptografar Dados Sensíveis
```

---

## ENUMERAÇÕES CUSTOMIZADAS

```mql5
//+------------------------------------------------------------------+
//|                      ENUMERAÇÕES CUSTOMIZADAS                    |
//+------------------------------------------------------------------+

// Tipos de Conta
enum ENUM_ACCOUNT_TYPE
{
    ACCOUNT_DEMO,           // Conta Demo
    ACCOUNT_LIVE,           // Conta Real
    ACCOUNT_FTMO,           // Conta FTMO
    ACCOUNT_PROP_FIRM,      // Prop Firm
    ACCOUNT_CHALLENGE       // Challenge
};

// Métodos de Position Sizing
enum ENUM_POSITION_SIZE_METHOD
{
    PS_FIXED_LOT,           // Lote Fixo
    PS_FIXED_RISK,          // Risco Fixo
    PS_KELLY_CRITERION,     // Kelly Criterion
    PS_VOLATILITY_ADJUSTED, // Ajustado por Volatilidade
    PS_EQUITY_CURVE         // Curva de Equity
};

// Níveis de Log
enum ENUM_LOG_LEVEL
{
    LOG_LEVEL_ERROR,        // Apenas Erros
    LOG_LEVEL_WARNING,      // Avisos e Erros
    LOG_LEVEL_INFO,         // Informações Gerais
    LOG_LEVEL_DEBUG,        // Debug Detalhado
    LOG_LEVEL_TRACE         // Trace Completo
};

// Tipos de Sinal
enum ENUM_SIGNAL_TYPE
{
    SIGNAL_NONE,            // Nenhum Sinal
    SIGNAL_BUY,             // Sinal de Compra
    SIGNAL_SELL,            // Sinal de Venda
    SIGNAL_CLOSE_BUY,       // Fechar Compra
    SIGNAL_CLOSE_SELL,      // Fechar Venda
    SIGNAL_CLOSE_ALL        // Fechar Todas
};

// Estados do EA
enum ENUM_EA_STATE
{
    EA_STATE_INIT,          // Inicializando
    EA_STATE_READY,         // Pronto
    EA_STATE_TRADING,       // Negociando
    EA_STATE_PAUSED,        // Pausado
    EA_STATE_ERROR,         // Erro
    EA_STATE_STOPPED        // Parado
};
```

---

## ESTRUTURAS DE DADOS

```mql5
//+------------------------------------------------------------------+
//|                      ESTRUTURAS DE DADOS                         |
//+------------------------------------------------------------------+

// Configuração ICT
struct SICTConfig
{
    bool use_order_blocks;
    bool use_fvg;
    bool use_liquidity;
    bool use_market_structure;
    int ob_lookback;
    int fvg_lookback;
    int liquidity_lookback;
    int ms_lookback;
    double ob_min_size;
    double fvg_min_size;
    double liquidity_buffer;
};

// Configuração de Risco
struct SRiskConfig
{
    double risk_percent;
    double max_daily_risk;
    double max_drawdown;
    double min_lot_size;
    double max_lot_size;
    ENUM_POSITION_SIZE_METHOD position_size_method;
    bool use_correlation_check;
    double max_correlation;
};

// Métricas de Performance
struct SPerformanceMetrics
{
    double total_profit;
    double total_loss;
    double profit_factor;
    double sharpe_ratio;
    double sortino_ratio;
    double max_drawdown;
    double win_rate;
    int total_trades;
    int winning_trades;
    int losing_trades;
    double avg_win;
    double avg_loss;
    double largest_win;
    double largest_loss;
};

// Estado de Compliance
struct SComplianceState
{
    bool is_compliant;
    double daily_pnl;
    double current_drawdown;
    double peak_balance;
    datetime last_check_time;
    string last_violation;
    bool trading_allowed;
};
```

---

## VALIDAÇÕES E CONSTRAINTS

### Validações de Entrada
```mql5
//+------------------------------------------------------------------+
//|                     VALIDAÇÕES DE ENTRADA                        |
//+------------------------------------------------------------------+

// Validação de Parâmetros
bool ValidateInputParameters()
{
    bool is_valid = true;
    
    // Validar Magic Number
    if(InpMagicNumber <= 0)
    {
        Print("ERRO: Magic Number deve ser maior que 0");
        is_valid = false;
    }
    
    // Validar Risk Percent
    if(InpRiskPercent <= 0 || InpRiskPercent > 10)
    {
        Print("ERRO: Risk Percent deve estar entre 0.1 e 10");
        is_valid = false;
    }
    
    // Validar Lot Size
    if(InpFixedLotSize < 0.01 || InpFixedLotSize > 100)
    {
        Print("ERRO: Lot Size deve estar entre 0.01 e 100");
        is_valid = false;
    }
    
    // Validar Timeframes
    if(InpExecutionTimeframe >= InpAnalysisTimeframe)
    {
        Print("ERRO: Execution Timeframe deve ser menor que Analysis Timeframe");
        is_valid = false;
    }
    
    return is_valid;
}
```

---

## CONCLUSÃO

Este documento define todas as especificações técnicas necessárias para a implementação do EA FTMO Scalper Elite, incluindo:

✅ **Parâmetros Configuráveis**: Mais de 150 parâmetros de entrada  
✅ **Estratégia ICT/SMC**: Configurações detalhadas para todos os conceitos  
✅ **Gestão de Risco**: Múltiplos métodos e verificações  
✅ **Compliance FTMO**: Verificações rigorosas e automáticas  
✅ **Performance Targets**: Metas claras e mensuráveis  
✅ **Sistema de Alertas**: Notificações multi-canal  
✅ **Logging Completo**: Auditoria e rastreabilidade total  
✅ **Validações**: Verificações de integridade e consistência  

### Próximos Passos
1. Implementação das classes core
2. Desenvolvimento dos indicadores
3. Criação do sistema de testes
4. Validação e otimização
5. Deploy e monitoramento

---

**Especificado por**: TradeDev_Master  
**Versão**: 1.0  
**Data**: 2024  
**Status**: Especificações Aprovadas
//+------------------------------------------------------------------+
//|                                          CFootprintAnalyzer.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                                                                  |
//|  VERSAO 3.4 - MOMENTUM EDGE (Delta Accel, POC Divergence)        |
//|                                                                  |
//|  BASEADO EM:                                                     |
//|  - ATAS Footprint methodology                                    |
//|  - UCluster diagonal imbalance detection                         |
//|  - OrderFlowAnalyzer_v2.mqh (base code)                         |
//|                                                                  |
//|  FEATURES:                                                       |
//|  1. Diagonal Imbalance (ATAS-style)                             |
//|  2. Stacked Imbalance (3+ consecutivos)                         |
//|  3. Absorption Detection (high vol + low delta)                 |
//|  4. Unfinished Auction detection                                |
//|  5. Delta Divergence tracking                                   |
//|  6. POC/VAH/VAL calculation                                     |
//|  7. Trading signal generation                                   |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property version   "3.40"
#property strict

#include "../Core/Definitions.mqh"

//+------------------------------------------------------------------+
//| Enums                                                             |
//+------------------------------------------------------------------+
enum ENUM_IMBALANCE_TYPE {
   IMBALANCE_NONE = 0,
   IMBALANCE_BUY,           // Compradores dominam (bullish)
   IMBALANCE_SELL           // Vendedores dominam (bearish)
};

enum ENUM_ABSORPTION_TYPE {
   ABSORPTION_NONE = 0,
   ABSORPTION_BUY,          // Vendas absorvidas por compradores
   ABSORPTION_SELL          // Compras absorvidas por vendedores
};

enum ENUM_AUCTION_TYPE {
   AUCTION_NONE = 0,
   AUCTION_UNFINISHED_UP,   // Close no high, delta positivo
   AUCTION_UNFINISHED_DOWN  // Close no low, delta negativo
};

enum ENUM_FOOTPRINT_SIGNAL {
   FP_SIGNAL_NONE = 0,
   FP_SIGNAL_STRONG_BUY,
   FP_SIGNAL_BUY,
   FP_SIGNAL_WEAK_BUY,
   FP_SIGNAL_NEUTRAL,
   FP_SIGNAL_WEAK_SELL,
   FP_SIGNAL_SELL,
   FP_SIGNAL_STRONG_SELL
};

//+------------------------------------------------------------------+
//| Estrutura de Nivel de Preco (Footprint Cell)                     |
//+------------------------------------------------------------------+
struct SFootprintLevel {
   double price;              // Preco do nivel (normalizado)
   long   bidVolume;          // Volume no bid (vendas agressivas)
   long   askVolume;          // Volume no ask (compras agressivas)
   long   delta;              // askVolume - bidVolume
   int    tickCount;          // Quantidade de ticks
   
   // Imbalances (calculados depois)
   bool   hasBuyImbalance;    // Ask domina (diagonal)
   bool   hasSellImbalance;   // Bid domina (diagonal)
   double imbalanceRatio;     // Ratio do imbalance
   
   void Reset() {
      price = 0;
      bidVolume = 0;
      askVolume = 0;
      delta = 0;
      tickCount = 0;
      hasBuyImbalance = false;
      hasSellImbalance = false;
      imbalanceRatio = 0;
   }
};

//+------------------------------------------------------------------+
//| Estrutura de Stacked Imbalance                                    |
//+------------------------------------------------------------------+
struct SStackedImbalance {
   double startPrice;         // Preco inicial do stack
   double endPrice;           // Preco final do stack
   int    levelCount;         // Quantos niveis consecutivos
   ENUM_IMBALANCE_TYPE type;  // BUY ou SELL
   double avgRatio;           // Ratio medio do stack
   bool   isActive;           // Preco ainda nao violou
   datetime detectionTime;    // Quando foi detectado
   
   void Reset() {
      startPrice = 0;
      endPrice = 0;
      levelCount = 0;
      type = IMBALANCE_NONE;
      avgRatio = 0;
      isActive = false;
      detectionTime = 0;
   }
};

//+------------------------------------------------------------------+
//| Estrutura de Zona de Absorcao (v3.3 - Persistent)                 |
//+------------------------------------------------------------------+
struct SAbsorptionZone {
   double price;              // Nivel de preco
   long   totalVolume;        // Volume total
   long   delta;              // Delta (deve ser perto de zero)
   double deltaPercent;       // |delta| / totalVolume * 100
   ENUM_ABSORPTION_TYPE type; // Tipo de absorcao
   int    confidence;         // Score de confianca 0-100
   double pricePosition;      // Posicao na barra: 0.0 = low, 1.0 = high
   double volumeSignificance; // Quao acima da media (1.0 = media, 2.0 = 2x media)
   datetime detectionTime;
   int    testCount;          // v3.3: Quantas vezes preco testou esta zona
   bool   broken;             // v3.3: Se preco quebrou a zona
   
   void Reset() {
      price = 0;
      totalVolume = 0;
      delta = 0;
      deltaPercent = 0;
      type = ABSORPTION_NONE;
      confidence = 0;
      pricePosition = 0.5;
      volumeSignificance = 0;
      detectionTime = 0;
      testCount = 1;
      broken = false;
   }
};

//+------------------------------------------------------------------+
//| Estrutura de Value Area                                           |
//+------------------------------------------------------------------+
struct SValueArea {
   double poc;                // Point of Control
   double vahigh;             // Value Area High (70%)
   double valow;              // Value Area Low (70%)
   long   pocVolume;          // Volume no POC
   long   totalVolume;        // Volume total
};

//+------------------------------------------------------------------+
//| Estrutura de Sinal de Trading                                     |
//+------------------------------------------------------------------+
struct SFootprintSignal {
   ENUM_FOOTPRINT_SIGNAL signal;
   int    strength;           // 0-100
   
   // Componentes do sinal
   bool   hasStackedBuyImbalance;
   bool   hasStackedSellImbalance;
   bool   hasBuyAbsorption;
   bool   hasSellAbsorption;
   bool   hasUnfinishedAuctionUp;
   bool   hasUnfinishedAuctionDown;
   bool   hasBullishDeltaDivergence;
   bool   hasBearishDeltaDivergence;
   bool   hasPOCDefense;
   
   // v3.4: Momentum Edge
   bool   hasBullishDeltaAcceleration;  // Delta accelerating up (momentum building)
   bool   hasBearishDeltaAcceleration;  // Delta accelerating down
   bool   hasBullishPOCDivergence;      // POC rising while price falling = reversal
   bool   hasBearishPOCDivergence;      // POC falling while price rising = reversal
   double deltaAcceleration;            // Rate of change of delta (-100 to +100)
   double pocChangePercent;             // POC movement as % of range
   
   // Delta info
   long   barDelta;
   long   cumulativeDelta;
   double deltaPercent;
   
   // Value Area
   SValueArea valueArea;
   
   // Niveis sugeridos
   double suggestedEntry;
   double suggestedSL;
   double suggestedTP;
   
   void Reset() {
      signal = FP_SIGNAL_NONE;
      strength = 0;
      hasStackedBuyImbalance = false;
      hasStackedSellImbalance = false;
      hasBuyAbsorption = false;
      hasSellAbsorption = false;
      hasUnfinishedAuctionUp = false;
      hasUnfinishedAuctionDown = false;
      hasBullishDeltaDivergence = false;
      hasBearishDeltaDivergence = false;
      hasPOCDefense = false;
      hasBullishDeltaAcceleration = false;
      hasBearishDeltaAcceleration = false;
      hasBullishPOCDivergence = false;
      hasBearishPOCDivergence = false;
      deltaAcceleration = 0;
      pocChangePercent = 0;
      barDelta = 0;
      cumulativeDelta = 0;
      deltaPercent = 0;
      suggestedEntry = 0;
      suggestedSL = 0;
      suggestedTP = 0;
   }
};

//+------------------------------------------------------------------+
//| Classe Principal: Footprint Analyzer                              |
//+------------------------------------------------------------------+
class CFootprintAnalyzer {
private:
   // Configuracao
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   double            m_clusterSize;        // Tamanho do cluster (ex: 0.50 para XAUUSD)
   double            m_tickSize;
   double            m_point;
   int               m_maxLevels;
   double            m_imbalanceRatio;     // Ratio minimo para imbalance (3.0 = 300%)
   int               m_minStackedLevels;   // Minimo de niveis para stacked (3)
   double            m_absorptionThreshold; // |delta%| < este valor = absorcao
   double            m_volumeMultiplier;   // Volume > avg * este = significativo
   
   // Dados dos niveis
   SFootprintLevel   m_levels[];
   int               m_levelCount;
   
   // Stacked Imbalances detectados
   SStackedImbalance m_stackedImbalances[];
   int               m_stackedCount;
   
   // Absorption Zones detectadas
   SAbsorptionZone   m_absorptionZones[];
   int               m_absorptionCount;
   
   // Tracking
   long              m_cumulativeDelta;
   datetime          m_lastBarTime;
   double            m_lastPrice;
   int               m_ticksProcessed;
   
   // Historico para divergencia
   long              m_deltaHistory[];
   double            m_priceHistory[];
   int               m_historyCount;
   int               m_maxHistory;
   
   // Cache
   bool              m_cacheValid;
   bool              m_levelsPrepared;
   SFootprintSignal  m_cachedSignal;
   datetime          m_cachedBarTime;
   datetime          m_preparedBarTime;
   
   // Value Area Cache (avoid recalculating 3x)
   bool              m_valueAreaCacheValid;
   SValueArea        m_cachedValueArea;
   
   // Profiling
   ulong             m_lastProcessBarUs;   // Last ProcessBarTicks duration (microseconds)
   int               m_lastTickCount;      // Ticks processed in last bar
   
   // v3.3: Dynamic Cluster (ATR-based)
   double            m_baseClusterSize;    // Original cluster size from Init
   bool              m_dynamicCluster;     // Enable ATR-based cluster adjustment
   double            m_atrMultiplier;      // Cluster = ATR * multiplier (default 0.1)
   double            m_minClusterSize;     // Minimum cluster size
   double            m_maxClusterSize;     // Maximum cluster size
   
   // v3.3: Session Delta Reset
   bool              m_sessionReset;       // Enable session-aware delta reset
   int               m_lastResetHour;      // Last hour we reset delta
   datetime          m_lastResetTime;      // Last reset timestamp
   
   // v3.3: Historical Absorptions (persist across bars)
   SAbsorptionZone   m_historicalAbsorptions[];
   int               m_historicalAbsCount;
   int               m_maxHistoricalAbs;   // Max zones to track (default 10)
   double            m_absorptionMergeDistance; // Merge zones within this distance
   
   // v3.4: POC History (for POC divergence detection)
   double            m_pocHistory[];       // POC prices for last N bars
   int               m_pocHistoryCount;
   int               m_maxPocHistory;      // Max POC history (default 5)
   
   // v3.4: Delta Acceleration
   double            m_deltaAcceleration;  // Current delta acceleration (-100 to +100)
   
   // Indicator handles
   int               m_atr_handle;
   
   // Metodos internos de processamento
   int               FindLevel(double price);
   int               AddLevel(double price);
   double            NormalizeToCluster(double price);
   void              ResetBarData();
   int               DetectDirection(const MqlTick &tick);
   
   // Metodos de calculo
   void              CalculateDiagonalImbalances();
   void              DetectStackedImbalances();
   void              DetectAbsorptionZones();
   ENUM_AUCTION_TYPE DetectUnfinishedAuction();
   bool              DetectDeltaDivergence(bool &bullish, bool &bearish);
   bool              DetectPOCDefense();
   void              CalculateValueArea(SValueArea &va);
   void              SortLevelsByPrice();
   void              EnsurePrepared();
   
   // v3.3: Metodos institucionais
   void              AdjustClusterToATR();
   void              CheckSessionReset();
   void              UpdateHistoricalAbsorptions();
   void              MergeOrAddAbsorption(const SAbsorptionZone &zone);
   void              UpdateAbsorptionTests();
   
   // v3.4: Momentum Edge
   void              CalculateDeltaAcceleration();
   bool              DetectPOCDivergence(bool &bullish, bool &bearish);
   void              UpdatePOCHistory();
   
public:
                     CFootprintAnalyzer();
                    ~CFootprintAnalyzer();
   
   // Inicializacao
   bool              Init(string symbol = NULL, ENUM_TIMEFRAMES tf = PERIOD_M5,
                          double clusterSize = 0.50, double imbalanceRatio = 3.0);
   void              Deinit();
   
   // Configuracao
   void              SetClusterSize(double size) { m_clusterSize = size; m_baseClusterSize = size; }
   void              SetImbalanceRatio(double ratio) { m_imbalanceRatio = ratio; }
   void              SetMinStackedLevels(int levels) { m_minStackedLevels = levels; }
   void              SetAbsorptionThreshold(double pct) { m_absorptionThreshold = pct; }
   
   // v3.3: Configuracao institucional
   void              EnableDynamicCluster(bool enable, double atrMult = 0.1, double minSize = 0.25, double maxSize = 2.0);
   void              EnableSessionReset(bool enable) { m_sessionReset = enable; }
   void              SetMaxHistoricalAbsorptions(int max) { m_maxHistoricalAbs = max; }
   double            GetCurrentClusterSize() const { return m_clusterSize; }
   int               GetHistoricalAbsorptionCount() const { return m_historicalAbsCount; }
   SAbsorptionZone   GetHistoricalAbsorption(int index);
   
   // v3.4: Momentum Edge API
   double            GetDeltaAcceleration() const { return m_deltaAcceleration; }
   bool              HasBullishMomentum();   // Delta accelerating up
   bool              HasBearishMomentum();   // Delta accelerating down
   bool              HasBullishPOCDivergence();  // POC up, price down = bullish reversal
   bool              HasBearishPOCDivergence();  // POC down, price up = bearish reversal
   
   // Processamento
   bool              ProcessBarTicks(int barIndex = 0);
   bool              ProcessTick(const MqlTick &tick);
   void              Update();
   
   // Resultados
   SFootprintSignal  GetSignal();
   SValueArea        GetValueArea();
   long              GetBarDelta();
   long              GetCumulativeDelta();
   double            GetPOC();
   
   // Stacked Imbalances
   int               GetStackedImbalanceCount() { return m_stackedCount; }
   SStackedImbalance GetStackedImbalance(int index);
   bool              HasStackedBuyImbalance();
   bool              HasStackedSellImbalance();
   
   // Absorption Zones
   int               GetAbsorptionZoneCount() { return m_absorptionCount; }
   SAbsorptionZone   GetAbsorptionZone(int index);
   SAbsorptionZone   GetBestAbsorption(ENUM_ABSORPTION_TYPE type);
   bool              HasBuyAbsorption();
   bool              HasSellAbsorption();
   
   // Trading helpers
   bool              IsBullish();
   bool              IsBearish();
   int               GetConfluenceScore();  // 0-100
   
   // Debug
   void              PrintDiagnostics();
   void              PrintLevels();
   void              PrintStackedImbalances();
   
   // Profiling
   ulong             GetLastProcessMicroseconds() const { return m_lastProcessBarUs; }
   int               GetLastTickCount() const { return m_lastTickCount; }
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CFootprintAnalyzer::CFootprintAnalyzer() {
   m_symbol = "";
   m_timeframe = PERIOD_M5;
   m_clusterSize = 0.50;
   m_tickSize = 0.01;
   m_point = 0.01;
   m_maxLevels = 100;
   m_imbalanceRatio = 3.0;
   m_minStackedLevels = 3;
   m_absorptionThreshold = 15.0;
   m_volumeMultiplier = 2.0;
   m_levelCount = 0;
   m_stackedCount = 0;
   m_absorptionCount = 0;
   m_cumulativeDelta = 0;
   m_lastBarTime = 0;
   m_lastPrice = 0;
   m_ticksProcessed = 0;
   m_historyCount = 0;
   m_maxHistory = 20;
   m_cacheValid = false;
   m_levelsPrepared = false;
   m_cachedBarTime = 0;
   m_preparedBarTime = 0;
   m_valueAreaCacheValid = false;
   m_lastProcessBarUs = 0;
   m_lastTickCount = 0;
   
   // v3.3: Dynamic cluster
   m_baseClusterSize = 0.50;
   m_dynamicCluster = false;
   m_atrMultiplier = 0.1;
   m_minClusterSize = 0.25;
   m_maxClusterSize = 2.0;
   
   // v3.3: Session reset
   m_sessionReset = false;
   m_lastResetHour = -1;
   m_lastResetTime = 0;
   
   // v3.3: Historical absorptions
   m_historicalAbsCount = 0;
   m_maxHistoricalAbs = 10;
   m_absorptionMergeDistance = 0.50;
   
   // v3.4: POC History and Delta Acceleration
   m_pocHistoryCount = 0;
   m_maxPocHistory = 5;
   m_deltaAcceleration = 0;
   
   m_atr_handle = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CFootprintAnalyzer::~CFootprintAnalyzer() {
   Deinit();
}

//+------------------------------------------------------------------+
//| Inicializacao                                                     |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::Init(string symbol = NULL, ENUM_TIMEFRAMES tf = PERIOD_M5,
                               double clusterSize = 0.50, double imbalanceRatio = 3.0) {
   m_symbol = (symbol == NULL) ? _Symbol : symbol;
   m_timeframe = tf;
   m_clusterSize = clusterSize;
   m_baseClusterSize = clusterSize;  // v3.3: Store base size
   m_imbalanceRatio = imbalanceRatio;
   
   // Obtem parametros do simbolo
   m_tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
   m_point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   
   if(m_tickSize == 0) m_tickSize = 0.01;
   if(m_point == 0) m_point = 0.01;
   
   // Ajusta cluster size para ser multiplo do tick size
   if(m_clusterSize < m_tickSize) m_clusterSize = m_tickSize;
   m_clusterSize = MathRound(m_clusterSize / m_tickSize) * m_tickSize;
   
   // v3.3: Set merge distance based on cluster size
   m_absorptionMergeDistance = m_clusterSize * 2;
   
   // Aloca arrays
   ArrayResize(m_levels, m_maxLevels);
   ArrayResize(m_stackedImbalances, 20);
   ArrayResize(m_absorptionZones, 20);
   ArrayResize(m_deltaHistory, m_maxHistory);
   ArrayResize(m_priceHistory, m_maxHistory);
   ArrayResize(m_historicalAbsorptions, m_maxHistoricalAbs);  // v3.3
   ArrayResize(m_pocHistory, m_maxPocHistory);               // v3.4
   
   // ATR handle
   m_atr_handle = iATR(m_symbol, m_timeframe, 14);
   if(m_atr_handle == INVALID_HANDLE)
   {
      Print("CFootprintAnalyzer: failed to create ATR handle");
      return false;
   }
   
   Print("CFootprintAnalyzer v3.4 Initialized (Momentum Edge):");
   Print("  Symbol: ", m_symbol);
   Print("  Timeframe: ", EnumToString(m_timeframe));
   Print("  Cluster Size: ", m_clusterSize, " (dynamic: ", m_dynamicCluster ? "ON" : "OFF", ")");
   Print("  Imbalance Ratio: ", m_imbalanceRatio, "x (", m_imbalanceRatio * 100, "%)");
   Print("  Min Stacked Levels: ", m_minStackedLevels);
   Print("  Session Reset: ", m_sessionReset ? "ON" : "OFF");
   
   return true;
}

//+------------------------------------------------------------------+
//| Desinicializacao                                                  |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::Deinit() {
   ArrayFree(m_levels);
   ArrayFree(m_stackedImbalances);
   ArrayFree(m_absorptionZones);
   ArrayFree(m_deltaHistory);
   ArrayFree(m_priceHistory);
   ArrayFree(m_historicalAbsorptions);  // v3.3
   ArrayFree(m_pocHistory);             // v3.4
   
   if(m_atr_handle != INVALID_HANDLE)
      IndicatorRelease(m_atr_handle);
}

//+------------------------------------------------------------------+
//| Normaliza preco para cluster                                      |
//+------------------------------------------------------------------+
double CFootprintAnalyzer::NormalizeToCluster(double price) {
   return MathRound(price / m_clusterSize) * m_clusterSize;
}

//+------------------------------------------------------------------+
//| Encontra nivel por preco                                          |
//+------------------------------------------------------------------+
int CFootprintAnalyzer::FindLevel(double price) {
   double normPrice = NormalizeToCluster(price);
   for(int i = 0; i < m_levelCount; i++) {
      if(MathAbs(m_levels[i].price - normPrice) < m_clusterSize / 2)
         return i;
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Adiciona novo nivel                                               |
//+------------------------------------------------------------------+
int CFootprintAnalyzer::AddLevel(double price) {
   if(m_levelCount >= m_maxLevels) {
      // Remove nivel com menor volume
      int minIdx = 0;
      long minVol = m_levels[0].bidVolume + m_levels[0].askVolume;
      for(int i = 1; i < m_levelCount; i++) {
         long vol = m_levels[i].bidVolume + m_levels[i].askVolume;
         if(vol < minVol) {
            minVol = vol;
            minIdx = i;
         }
      }
      m_levels[minIdx].Reset();
      m_levels[minIdx].price = NormalizeToCluster(price);
      return minIdx;
   }
   
   int idx = m_levelCount;
   m_levels[idx].Reset();
   m_levels[idx].price = NormalizeToCluster(price);
   m_levelCount++;
   return idx;
}

//+------------------------------------------------------------------+
//| Reset dados da barra                                              |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::ResetBarData() {
   for(int i = 0; i < m_maxLevels; i++)
      m_levels[i].Reset();
   
   m_levelCount = 0;
   m_stackedCount = 0;
   m_absorptionCount = 0;
   m_ticksProcessed = 0;
   m_lastPrice = 0;
   m_cacheValid = false;
   m_valueAreaCacheValid = false;  // Reset VA cache on new bar
   m_levelsPrepared = false;
   m_preparedBarTime = 0;
}

//+------------------------------------------------------------------+
//| Detecta direcao do tick                                           |
//+------------------------------------------------------------------+
int CFootprintAnalyzer::DetectDirection(const MqlTick &tick) {
   // Prioridade 1: TICK_FLAG (se disponivel)
   bool hasBuy = (tick.flags & TICK_FLAG_BUY) != 0;
   bool hasSell = (tick.flags & TICK_FLAG_SELL) != 0;
   
   if(hasBuy && !hasSell) return 1;
   if(hasSell && !hasBuy) return -1;
   
   // Prioridade 2: Comparacao bid/ask
   double tradePrice = (tick.last > 0) ? tick.last : tick.bid;
   
   if(tick.ask > 0 && tick.bid > 0) {
      double mid = (tick.bid + tick.ask) / 2;
      if(tradePrice >= mid) return 1;  // Trade no ask = buy
      return -1;  // Trade no bid = sell
   }
   
   // Prioridade 3: Comparacao com preco anterior
   if(m_lastPrice > 0) {
      if(tradePrice > m_lastPrice + m_point) return 1;
      if(tradePrice < m_lastPrice - m_point) return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Processa tick individual                                          |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::ProcessTick(const MqlTick &tick) {
   // Valida tick
   if(tick.bid <= 0 && tick.ask <= 0 && tick.last <= 0)
      return false;
   
   // Verifica nova barra
   datetime barTime = iTime(m_symbol, m_timeframe, 0);
   if(barTime != m_lastBarTime) {
      // Salva historico antes de resetar
      if(m_levelCount > 0) {
         if(m_historyCount >= m_maxHistory) {
            // Shift history
            for(int i = 0; i < m_maxHistory - 1; i++) {
               m_deltaHistory[i] = m_deltaHistory[i+1];
               m_priceHistory[i] = m_priceHistory[i+1];
            }
            m_historyCount = m_maxHistory - 1;
         }
         m_deltaHistory[m_historyCount] = GetBarDelta();
         m_priceHistory[m_historyCount] = iClose(m_symbol, m_timeframe, 1);
         m_historyCount++;
      }
      
      ResetBarData();
      m_lastBarTime = barTime;
   }
   
   // Detecta direcao
   int direction = DetectDirection(tick);
   
   // Determina preco e volume
   double price = (tick.last > 0) ? tick.last : tick.bid;
   long volume = (tick.volume > 0) ? (long)tick.volume : 1;
   
   // Encontra ou cria nivel
   int idx = FindLevel(price);
   if(idx < 0) idx = AddLevel(price);
   
   // Atualiza nivel
   m_levels[idx].tickCount++;
   
   if(direction > 0) {
      m_levels[idx].askVolume += volume;
      m_cumulativeDelta += volume;
   }
   else if(direction < 0) {
      m_levels[idx].bidVolume += volume;
      m_cumulativeDelta -= volume;
   }
   
   // Atualiza delta do nivel
   m_levels[idx].delta = m_levels[idx].askVolume - m_levels[idx].bidVolume;
   
   m_lastPrice = price;
   m_ticksProcessed++;
   m_cacheValid = false;
   m_levelsPrepared = false;
   m_valueAreaCacheValid = false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Processa todos os ticks de uma barra                              |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::ProcessBarTicks(int barIndex = 0) {
   ulong startUs = GetMicrosecondCount();  // Profiling start
   
   // v3.3: Check session reset before processing
   if(m_sessionReset)
      CheckSessionReset();
   
   // v3.3: Adjust cluster size to ATR before processing
   if(m_dynamicCluster)
      AdjustClusterToATR();
   
   datetime barTime = iTime(m_symbol, m_timeframe, barIndex);
   int barSeconds = PeriodSeconds(m_timeframe);
   datetime barEnd = barTime + barSeconds;
   
   // Se e a mesma barra, nao reprocessa tudo (a menos que seja a barra atual)
   if(barIndex > 0 && barTime == m_lastBarTime && m_levelCount > 0) {
      m_lastProcessBarUs = GetMicrosecondCount() - startUs;
      return true;
   }
   
   ResetBarData();
   m_lastBarTime = barTime;
   
   MqlTick ticks[];
   int copied = CopyTicksRange(m_symbol, ticks, COPY_TICKS_ALL,
                               barTime * 1000, barEnd * 1000);
   
   if(copied <= 0) {
      // In Strategy Tester without "real ticks" mode, tick data is not available
      // Only log warning in live mode to avoid spam
      if(!MQLInfoInteger(MQL_TESTER))
         Print("CFootprintAnalyzer: No ticks for bar ", barIndex);
      return false;
   }
   
   // Process ALL ticks for accuracy (cluster aggregation handles data reduction)
   // Skip only non-informative ticks (no volume, no price change)
   double lastTickPrice = 0;
   for(int i = 0; i < copied; i++) {
      // Early exit for non-informative ticks
      if(ticks[i].volume == 0 && ticks[i].last == lastTickPrice && lastTickPrice > 0)
         continue;
      
      ProcessTick(ticks[i]);
      lastTickPrice = (ticks[i].last > 0) ? ticks[i].last : ticks[i].bid;
   }
   
   // Calcula imbalances e padroes
   SortLevelsByPrice();
   CalculateDiagonalImbalances();
   DetectStackedImbalances();
   DetectAbsorptionZones();
   
   // v3.3: Update historical absorptions and test counts
   UpdateHistoricalAbsorptions();
   UpdateAbsorptionTests();
   
   // v3.4: Calculate momentum indicators
   CalculateDeltaAcceleration();
   UpdatePOCHistory();
   
   m_levelsPrepared = true;
   m_preparedBarTime = m_lastBarTime;
   m_valueAreaCacheValid = false;
   
   // Profiling end
   m_lastProcessBarUs = GetMicrosecondCount() - startUs;
   m_lastTickCount = m_ticksProcessed;
   
   return true;
}

//+------------------------------------------------------------------+
//| Update (chamado em cada nova barra)                               |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::Update() {
   ProcessBarTicks(0);
}

//+------------------------------------------------------------------+
//| Ordena niveis por preco                                           |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::SortLevelsByPrice() {
   // Insertion sort (array pequeno)
   for(int i = 1; i < m_levelCount; i++) {
      SFootprintLevel key = m_levels[i];
      int j = i - 1;
      while(j >= 0 && m_levels[j].price > key.price) {
         m_levels[j + 1] = m_levels[j];
         j--;
      }
      m_levels[j + 1] = key;
   }
}

//+------------------------------------------------------------------+
//| Garante ordenacao e calculos da barra atual                      |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::EnsurePrepared() {
   if(m_levelCount == 0)
      return;
   
   // Se ja preparado para esta barra, evita recalculo
   if(m_levelsPrepared && m_preparedBarTime == m_lastBarTime)
      return;
   
   SortLevelsByPrice();
   CalculateDiagonalImbalances();
   DetectStackedImbalances();
   DetectAbsorptionZones();
   
   m_levelsPrepared = true;
   m_preparedBarTime = m_lastBarTime;
   m_cacheValid = false;           // qualquer recalculo invalida o cache de sinal
   m_valueAreaCacheValid = false;  // recalcular VA na proxima leitura
}

//+------------------------------------------------------------------+
//| Calcula Imbalances DIAGONAIS (estilo ATAS)                        |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::CalculateDiagonalImbalances() {
   // Reset imbalances
   for(int i = 0; i < m_levelCount; i++) {
      m_levels[i].hasBuyImbalance = false;
      m_levels[i].hasSellImbalance = false;
      m_levels[i].imbalanceRatio = 0;
   }
   
   // Calcula imbalances diagonais
   // Buy Imbalance: Ask[n] >= Bid[n-1] * ratio  (nível atual vs nível imediatamente abaixo)
   // Sell Imbalance: Bid[n] >= Ask[n+1] * ratio (nível atual vs nível imediatamente acima)
   for(int i = 0; i < m_levelCount; i++) {
      // Buy imbalance (precisa de nível abaixo)
      if(i > 0) {
         double bidBelow = (double)m_levels[i - 1].bidVolume;
         double askHere  = (double)m_levels[i].askVolume;
         if(bidBelow > 0 && askHere / bidBelow >= m_imbalanceRatio) {
            m_levels[i].hasBuyImbalance = true;
            m_levels[i].imbalanceRatio = askHere / bidBelow;
         }
      }
      
      // Sell imbalance (precisa de nível acima)
      if(i < m_levelCount - 1) {
         double askAbove = (double)m_levels[i + 1].askVolume;
         double bidHere  = (double)m_levels[i].bidVolume;
         if(askAbove > 0 && bidHere / askAbove >= m_imbalanceRatio) {
            m_levels[i].hasSellImbalance = true;
            m_levels[i].imbalanceRatio = MathMax(m_levels[i].imbalanceRatio, bidHere / askAbove);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Detecta Stacked Imbalances (3+ consecutivos)                      |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::DetectStackedImbalances() {
   m_stackedCount = 0;
   
   if(m_levelCount < m_minStackedLevels) return;
   
   int consecutiveBuy = 0;
   int consecutiveSell = 0;
   int buyStartIdx = -1;
   int sellStartIdx = -1;
   double buyRatioSum = 0;
   double sellRatioSum = 0;
   
   for(int i = 0; i < m_levelCount; i++) {
      // Buy imbalances
      if(m_levels[i].hasBuyImbalance) {
         if(consecutiveBuy == 0) buyStartIdx = i;
         consecutiveBuy++;
         buyRatioSum += m_levels[i].imbalanceRatio;
      }
      else {
         if(consecutiveBuy >= m_minStackedLevels && m_stackedCount < 20) {
            m_stackedImbalances[m_stackedCount].startPrice = m_levels[buyStartIdx].price;
            m_stackedImbalances[m_stackedCount].endPrice = m_levels[i - 1].price;
            m_stackedImbalances[m_stackedCount].levelCount = consecutiveBuy;
            m_stackedImbalances[m_stackedCount].type = IMBALANCE_BUY;
            m_stackedImbalances[m_stackedCount].avgRatio = buyRatioSum / consecutiveBuy;
            m_stackedImbalances[m_stackedCount].isActive = true;
            m_stackedImbalances[m_stackedCount].detectionTime = TimeCurrent();
            m_stackedCount++;
         }
         consecutiveBuy = 0;
         buyRatioSum = 0;
      }
      
      // Sell imbalances
      if(m_levels[i].hasSellImbalance) {
         if(consecutiveSell == 0) sellStartIdx = i;
         consecutiveSell++;
         sellRatioSum += m_levels[i].imbalanceRatio;
      }
      else {
         if(consecutiveSell >= m_minStackedLevels && m_stackedCount < 20) {
            m_stackedImbalances[m_stackedCount].startPrice = m_levels[sellStartIdx].price;
            m_stackedImbalances[m_stackedCount].endPrice = m_levels[i - 1].price;
            m_stackedImbalances[m_stackedCount].levelCount = consecutiveSell;
            m_stackedImbalances[m_stackedCount].type = IMBALANCE_SELL;
            m_stackedImbalances[m_stackedCount].avgRatio = sellRatioSum / consecutiveSell;
            m_stackedImbalances[m_stackedCount].isActive = true;
            m_stackedImbalances[m_stackedCount].detectionTime = TimeCurrent();
            m_stackedCount++;
         }
         consecutiveSell = 0;
         sellRatioSum = 0;
      }
   }
   
   // Check final sequences
   if(consecutiveBuy >= m_minStackedLevels && m_stackedCount < 20) {
      m_stackedImbalances[m_stackedCount].startPrice = m_levels[buyStartIdx].price;
      m_stackedImbalances[m_stackedCount].endPrice = m_levels[m_levelCount - 1].price;
      m_stackedImbalances[m_stackedCount].levelCount = consecutiveBuy;
      m_stackedImbalances[m_stackedCount].type = IMBALANCE_BUY;
      m_stackedImbalances[m_stackedCount].avgRatio = buyRatioSum / consecutiveBuy;
      m_stackedImbalances[m_stackedCount].isActive = true;
      m_stackedImbalances[m_stackedCount].detectionTime = TimeCurrent();
      m_stackedCount++;
   }
   
   if(consecutiveSell >= m_minStackedLevels && m_stackedCount < 20) {
      m_stackedImbalances[m_stackedCount].startPrice = m_levels[sellStartIdx].price;
      m_stackedImbalances[m_stackedCount].endPrice = m_levels[m_levelCount - 1].price;
      m_stackedImbalances[m_stackedCount].levelCount = consecutiveSell;
      m_stackedImbalances[m_stackedCount].type = IMBALANCE_SELL;
      m_stackedImbalances[m_stackedCount].avgRatio = sellRatioSum / consecutiveSell;
      m_stackedImbalances[m_stackedCount].isActive = true;
      m_stackedImbalances[m_stackedCount].detectionTime = TimeCurrent();
      m_stackedCount++;
   }
}

//+------------------------------------------------------------------+
//| Detecta Zonas de Absorcao (v3.2 - Price Context + Bar Direction)  |
//|                                                                   |
//| LOGIC:                                                            |
//| - Absorption = High Volume + Low Net Delta (balanced trading)     |
//| - BUY ABSORPTION: At lows, sellers absorbed by passive buyers     |
//| - SELL ABSORPTION: At highs, buyers absorbed by passive sellers   |
//|                                                                   |
//| CONFIDENCE SCORING (0-100):                                       |
//| - Price Position Factor: 35 pts (how extreme in the bar)          |
//| - Volume Significance:   25 pts (how much above average)          |
//| - Delta Balance:         25 pts (how close to zero)               |
//| - Bar Direction Context: 15 pts (absorption WITH bar direction)   |
//|                                                                   |
//| BAR DIRECTION BONUS:                                              |
//| - BUY absorption at LOW of DOWN bar = +15 pts (strong defense)    |
//| - SELL absorption at HIGH of UP bar = +15 pts (strong defense)    |
//| - Absorption against bar direction = +0 pts                       |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::DetectAbsorptionZones() {
   m_absorptionCount = 0;
   
   if(m_levelCount == 0) return;
   
   // Get bar OHLC for price context
   double barOpen  = iOpen(m_symbol, m_timeframe, 0);
   double barHigh  = iHigh(m_symbol, m_timeframe, 0);
   double barLow   = iLow(m_symbol, m_timeframe, 0);
   double barClose = iClose(m_symbol, m_timeframe, 0);
   double barRange = barHigh - barLow;
   
   // Determine bar direction
   // UP bar: Close > Open (bullish candle)
   // DOWN bar: Close < Open (bearish candle)
   bool isUpBar = (barClose > barOpen);
   bool isDownBar = (barClose < barOpen);
   
   // Handle very narrow bars (use delta sign as primary)
   bool narrowBar = (barRange < m_clusterSize * 2);
   
   // Calculate average volume per level
   long totalVol = 0;
   for(int i = 0; i < m_levelCount; i++) {
      totalVol += m_levels[i].bidVolume + m_levels[i].askVolume;
   }
   double avgVol = (m_levelCount > 0) ? (double)totalVol / m_levelCount : 1.0;
   if(avgVol < 1.0) avgVol = 1.0;  // Prevent division by zero
   
   // Scan all levels for absorption candidates
   for(int i = 0; i < m_levelCount && m_absorptionCount < 20; i++) {
      long levelVol = m_levels[i].bidVolume + m_levels[i].askVolume;
      long levelDelta = m_levels[i].delta;
      
      // FILTER 1: Volume must be significant (> avg * multiplier)
      double volSignificance = (double)levelVol / avgVol;
      if(volSignificance < m_volumeMultiplier) continue;
      
      // FILTER 2: Delta must be balanced (|delta%| < threshold)
      double deltaPct = (levelVol > 0) ? MathAbs((double)levelDelta / levelVol * 100.0) : 100.0;
      if(deltaPct >= m_absorptionThreshold) continue;
      
      // ===== ABSORPTION DETECTED - Calculate confidence and type =====
      
      // Calculate price position (0.0 = at low, 1.0 = at high)
      double pricePos = 0.5;  // Default to middle
      if(!narrowBar && barRange > 0) {
         pricePos = (m_levels[i].price - barLow) / barRange;
         pricePos = MathMax(0.0, MathMin(1.0, pricePos));  // Clamp 0-1
      }
      
      // ===== DETERMINE TYPE (before confidence scoring) =====
      ENUM_ABSORPTION_TYPE absType = ABSORPTION_NONE;
      
      if(narrowBar) {
         // Narrow bar: Use delta sign as tiebreaker
         // Negative delta = sellers aggressive = BUY absorption
         absType = (levelDelta < 0) ? ABSORPTION_BUY : ABSORPTION_SELL;
      }
      else {
         // Normal bar: Use price position as primary
         // At LOWS (pricePos < 0.5) = BUY absorption (buyers defending low)
         // At HIGHS (pricePos >= 0.5) = SELL absorption (sellers defending high)
         if(pricePos < 0.4) {
            absType = ABSORPTION_BUY;
         }
         else if(pricePos > 0.6) {
            absType = ABSORPTION_SELL;
         }
         else {
            // Middle zone: Use delta sign as tiebreaker
            absType = (levelDelta < 0) ? ABSORPTION_BUY : ABSORPTION_SELL;
         }
      }
      
      // ===== CONFIDENCE SCORING (now includes bar direction) =====
      int confidence = 0;
      
      // Factor 1: Price Position (35 pts max)
      // Extreme positions (< 0.2 or > 0.8) get full points
      double extremity = MathAbs(pricePos - 0.5) * 2.0;  // 0 at center, 1 at extremes
      confidence += (int)(extremity * 35.0);
      
      // Factor 2: Volume Significance (25 pts max)
      // Cap at 5x average for scoring
      double volScore = MathMin(volSignificance / 5.0, 1.0);
      confidence += (int)(volScore * 25.0);
      
      // Factor 3: Delta Balance (25 pts max)
      // Perfect balance (0%) = 25 pts, threshold% = 0 pts
      double deltaScore = 1.0 - (deltaPct / m_absorptionThreshold);
      deltaScore = MathMax(0.0, deltaScore);
      confidence += (int)(deltaScore * 25.0);
      
      // Factor 4: Bar Direction Context (15 pts max)
      // BUY absorption at LOW of DOWN bar = strong defense signal (+15)
      // SELL absorption at HIGH of UP bar = strong defense signal (+15)
      // Absorption aligns with bar direction = weak signal (+0)
      int barDirBonus = 0;
      if(absType == ABSORPTION_BUY && pricePos < 0.3 && isDownBar) {
         // BUY absorption at LOW of bearish bar = buyers defending aggressively
         barDirBonus = 15;
      }
      else if(absType == ABSORPTION_SELL && pricePos > 0.7 && isUpBar) {
         // SELL absorption at HIGH of bullish bar = sellers defending aggressively
         barDirBonus = 15;
      }
      else if((absType == ABSORPTION_BUY && pricePos < 0.3) || 
              (absType == ABSORPTION_SELL && pricePos > 0.7)) {
         // Correct position but neutral bar direction = partial bonus
         barDirBonus = 7;
      }
      confidence += barDirBonus;
      
      // Store the absorption zone
      m_absorptionZones[m_absorptionCount].price = m_levels[i].price;
      m_absorptionZones[m_absorptionCount].totalVolume = levelVol;
      m_absorptionZones[m_absorptionCount].delta = levelDelta;
      m_absorptionZones[m_absorptionCount].deltaPercent = deltaPct;
      m_absorptionZones[m_absorptionCount].type = absType;
      m_absorptionZones[m_absorptionCount].confidence = confidence;
      m_absorptionZones[m_absorptionCount].pricePosition = pricePos;
      m_absorptionZones[m_absorptionCount].volumeSignificance = volSignificance;
      m_absorptionZones[m_absorptionCount].detectionTime = TimeCurrent();
      
      m_absorptionCount++;
   }
}

//+------------------------------------------------------------------+
//| Detecta Unfinished Auction                                        |
//+------------------------------------------------------------------+
ENUM_AUCTION_TYPE CFootprintAnalyzer::DetectUnfinishedAuction() {
   if(m_levelCount == 0) return AUCTION_NONE;
   
   double barOpen = iOpen(m_symbol, m_timeframe, 0);
   double barHigh = iHigh(m_symbol, m_timeframe, 0);
   double barLow = iLow(m_symbol, m_timeframe, 0);
   double barClose = iClose(m_symbol, m_timeframe, 0);
   
   long barDelta = GetBarDelta();
   
   // Close no high com delta positivo = bullish unfinished
   if(MathAbs(barClose - barHigh) < m_clusterSize && barDelta > 0) {
      // Verifica se tem buy imbalance no topo
      for(int i = m_levelCount - 1; i >= m_levelCount - 3 && i >= 0; i--) {
         if(m_levels[i].hasBuyImbalance)
            return AUCTION_UNFINISHED_UP;
      }
   }
   
   // Close no low com delta negativo = bearish unfinished
   if(MathAbs(barClose - barLow) < m_clusterSize && barDelta < 0) {
      // Verifica se tem sell imbalance no fundo
      for(int i = 0; i < 3 && i < m_levelCount; i++) {
         if(m_levels[i].hasSellImbalance)
            return AUCTION_UNFINISHED_DOWN;
      }
   }
   
   return AUCTION_NONE;
}

//+------------------------------------------------------------------+
//| Detecta Delta Divergence                                          |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::DetectDeltaDivergence(bool &bullish, bool &bearish) {
   bullish = false;
   bearish = false;
   
   if(m_historyCount < 3) return false;
   
   // Ultimos 3 pontos
   int last = m_historyCount - 1;
   
   // Bullish divergence: Price lower lows, Delta higher lows
   if(m_priceHistory[last] < m_priceHistory[last-1] && 
      m_priceHistory[last-1] < m_priceHistory[last-2]) {
      if(m_deltaHistory[last] > m_deltaHistory[last-1] &&
         m_deltaHistory[last-1] > m_deltaHistory[last-2]) {
         bullish = true;
      }
   }
   
   // Bearish divergence: Price higher highs, Delta lower highs
   if(m_priceHistory[last] > m_priceHistory[last-1] && 
      m_priceHistory[last-1] > m_priceHistory[last-2]) {
      if(m_deltaHistory[last] < m_deltaHistory[last-1] &&
         m_deltaHistory[last-1] < m_deltaHistory[last-2]) {
         bearish = true;
      }
   }
   
   return bullish || bearish;
}

//+------------------------------------------------------------------+
//| Detecta POC Defense                                               |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::DetectPOCDefense() {
   EnsurePrepared();
   
   SValueArea va;
   CalculateValueArea(va);
   
   if(va.pocVolume == 0) return false;
   
   double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   
   // Preco proximo do POC com alto volume
   if(MathAbs(currentPrice - va.poc) < m_clusterSize * 2) {
      if(va.pocVolume > va.totalVolume * 0.15) {
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Calcula Value Area (with caching to avoid 3x recalculation)       |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::CalculateValueArea(SValueArea &va) {
   // Return cached value if valid
   if(m_valueAreaCacheValid) {
      va = m_cachedValueArea;
      return;
   }
   
   va.poc = 0;
   va.vahigh = 0;
   va.valow = 0;
   va.pocVolume = 0;
   va.totalVolume = 0;
   
   if(m_levelCount == 0) {
      // Cache empty result
      m_cachedValueArea = va;
      m_valueAreaCacheValid = true;
      return;
   }
   
   // Encontra POC
   int pocIdx = 0;
   long maxVol = 0;
   
   for(int i = 0; i < m_levelCount; i++) {
      long vol = m_levels[i].bidVolume + m_levels[i].askVolume;
      va.totalVolume += vol;
      if(vol > maxVol) {
         maxVol = vol;
         pocIdx = i;
      }
   }
   
   va.poc = m_levels[pocIdx].price;
   va.pocVolume = maxVol;
   
   // Calcula Value Area (70%)
   long targetVol = (long)(va.totalVolume * 0.70);
   long currentVol = maxVol;
   
   va.vahigh = va.poc;
   va.valow = va.poc;
   
   int upperIdx = pocIdx;
   int lowerIdx = pocIdx;
   
   while(currentVol < targetVol && (upperIdx < m_levelCount - 1 || lowerIdx > 0)) {
      long upperVol = 0, lowerVol = 0;
      
      if(upperIdx < m_levelCount - 1)
         upperVol = m_levels[upperIdx + 1].bidVolume + m_levels[upperIdx + 1].askVolume;
      if(lowerIdx > 0)
         lowerVol = m_levels[lowerIdx - 1].bidVolume + m_levels[lowerIdx - 1].askVolume;
      
      if(upperVol >= lowerVol && upperIdx < m_levelCount - 1) {
         upperIdx++;
         currentVol += upperVol;
         va.vahigh = m_levels[upperIdx].price;
      }
      else if(lowerIdx > 0) {
         lowerIdx--;
         currentVol += lowerVol;
         va.valow = m_levels[lowerIdx].price;
      }
      else break;
   }
   
   // Store in cache
   m_cachedValueArea = va;
   m_valueAreaCacheValid = true;
}

//+------------------------------------------------------------------+
//| Obtem Delta da barra                                              |
//+------------------------------------------------------------------+
long CFootprintAnalyzer::GetBarDelta() {
   long delta = 0;
   for(int i = 0; i < m_levelCount; i++) {
      delta += m_levels[i].delta;
   }
   return delta;
}

//+------------------------------------------------------------------+
//| Obtem Delta cumulativo                                            |
//+------------------------------------------------------------------+
long CFootprintAnalyzer::GetCumulativeDelta() {
   return m_cumulativeDelta;
}

//+------------------------------------------------------------------+
//| Obtem POC                                                         |
//+------------------------------------------------------------------+
double CFootprintAnalyzer::GetPOC() {
   EnsurePrepared();
   SValueArea va;
   CalculateValueArea(va);
   return va.poc;
}

//+------------------------------------------------------------------+
//| Obtem Value Area                                                  |
//+------------------------------------------------------------------+
SValueArea CFootprintAnalyzer::GetValueArea() {
   SValueArea va;
   EnsurePrepared();
   CalculateValueArea(va);
   return va;
}

//+------------------------------------------------------------------+
//| Verifica se tem Stacked Buy Imbalance                             |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::HasStackedBuyImbalance() {
   for(int i = 0; i < m_stackedCount; i++) {
      if(m_stackedImbalances[i].type == IMBALANCE_BUY)
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Verifica se tem Stacked Sell Imbalance                            |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::HasStackedSellImbalance() {
   for(int i = 0; i < m_stackedCount; i++) {
      if(m_stackedImbalances[i].type == IMBALANCE_SELL)
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Verifica se tem Buy Absorption (confidence > 50)                  |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::HasBuyAbsorption() {
   for(int i = 0; i < m_absorptionCount; i++) {
      if(m_absorptionZones[i].type == ABSORPTION_BUY && m_absorptionZones[i].confidence >= 50)
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Verifica se tem Sell Absorption (confidence > 50)                 |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::HasSellAbsorption() {
   for(int i = 0; i < m_absorptionCount; i++) {
      if(m_absorptionZones[i].type == ABSORPTION_SELL && m_absorptionZones[i].confidence >= 50)
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Retorna melhor absorcao por tipo (maior confidence)               |
//+------------------------------------------------------------------+
SAbsorptionZone CFootprintAnalyzer::GetBestAbsorption(ENUM_ABSORPTION_TYPE type) {
   SAbsorptionZone best;
   best.Reset();
   
   for(int i = 0; i < m_absorptionCount; i++) {
      if(m_absorptionZones[i].type == type && m_absorptionZones[i].confidence > best.confidence) {
         best = m_absorptionZones[i];
      }
   }
   return best;
}

//+------------------------------------------------------------------+
//| Obtem Stacked Imbalance por indice                                |
//+------------------------------------------------------------------+
SStackedImbalance CFootprintAnalyzer::GetStackedImbalance(int index) {
   SStackedImbalance empty;
   empty.Reset();
   
   if(index < 0 || index >= m_stackedCount)
      return empty;
   
   return m_stackedImbalances[index];
}

//+------------------------------------------------------------------+
//| Obtem Absorption Zone por indice                                  |
//+------------------------------------------------------------------+
SAbsorptionZone CFootprintAnalyzer::GetAbsorptionZone(int index) {
   SAbsorptionZone empty;
   empty.Reset();
   
   if(index < 0 || index >= m_absorptionCount)
      return empty;
   
   return m_absorptionZones[index];
}

//+------------------------------------------------------------------+
//| Verifica se e bullish                                             |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::IsBullish() {
   SFootprintSignal sig = GetSignal();
   return sig.signal == FP_SIGNAL_STRONG_BUY || 
          sig.signal == FP_SIGNAL_BUY || 
          sig.signal == FP_SIGNAL_WEAK_BUY;
}

//+------------------------------------------------------------------+
//| Verifica se e bearish                                             |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::IsBearish() {
   SFootprintSignal sig = GetSignal();
   return sig.signal == FP_SIGNAL_STRONG_SELL || 
          sig.signal == FP_SIGNAL_SELL || 
          sig.signal == FP_SIGNAL_WEAK_SELL;
}

//+------------------------------------------------------------------+
//| Calcula score de confluencia (0-100)                              |
//+------------------------------------------------------------------+
int CFootprintAnalyzer::GetConfluenceScore() {
   SFootprintSignal sig = GetSignal();
   return sig.strength;
}

//+------------------------------------------------------------------+
//| Obtem sinal de trading completo                                   |
//+------------------------------------------------------------------+
SFootprintSignal CFootprintAnalyzer::GetSignal() {
   // Garante que niveis estao ordenados e padroes calculados
   EnsurePrepared();
   
   // Retorna cache se valido
   if(m_cacheValid && m_cachedBarTime == m_lastBarTime && m_levelsPrepared && m_preparedBarTime == m_lastBarTime)
      return m_cachedSignal;
   
   m_cachedSignal.Reset();
   
   // Delta
   m_cachedSignal.barDelta = GetBarDelta();
   m_cachedSignal.cumulativeDelta = m_cumulativeDelta;
   
   long totalVol = 0;
   for(int i = 0; i < m_levelCount; i++) {
      totalVol += m_levels[i].bidVolume + m_levels[i].askVolume;
   }
   m_cachedSignal.deltaPercent = (totalVol > 0) ? 
      (double)m_cachedSignal.barDelta / totalVol * 100 : 0;
   
   // Value Area
   CalculateValueArea(m_cachedSignal.valueArea);
   
   // Componentes
   m_cachedSignal.hasStackedBuyImbalance = HasStackedBuyImbalance();
   m_cachedSignal.hasStackedSellImbalance = HasStackedSellImbalance();
   m_cachedSignal.hasBuyAbsorption = HasBuyAbsorption();
   m_cachedSignal.hasSellAbsorption = HasSellAbsorption();
   
   ENUM_AUCTION_TYPE auction = DetectUnfinishedAuction();
   m_cachedSignal.hasUnfinishedAuctionUp = (auction == AUCTION_UNFINISHED_UP);
   m_cachedSignal.hasUnfinishedAuctionDown = (auction == AUCTION_UNFINISHED_DOWN);
   
   bool bullDiv, bearDiv;
   DetectDeltaDivergence(bullDiv, bearDiv);
   m_cachedSignal.hasBullishDeltaDivergence = bullDiv;
   m_cachedSignal.hasBearishDeltaDivergence = bearDiv;
   
   m_cachedSignal.hasPOCDefense = DetectPOCDefense();
   
   // v3.4: Momentum Edge indicators
   m_cachedSignal.deltaAcceleration = m_deltaAcceleration;
   m_cachedSignal.hasBullishDeltaAcceleration = (m_deltaAcceleration > 20);
   m_cachedSignal.hasBearishDeltaAcceleration = (m_deltaAcceleration < -20);
   
   bool bullPOCDiv, bearPOCDiv;
   DetectPOCDivergence(bullPOCDiv, bearPOCDiv);
   m_cachedSignal.hasBullishPOCDivergence = bullPOCDiv;
   m_cachedSignal.hasBearishPOCDivergence = bearPOCDiv;
   
   // Calcula score
   int buyScore = 0;
   int sellScore = 0;
   
   // Stacked imbalances (peso alto)
   if(m_cachedSignal.hasStackedBuyImbalance) buyScore += 25;
   if(m_cachedSignal.hasStackedSellImbalance) sellScore += 25;
   
   // Absorption (peso medio-alto)
   if(m_cachedSignal.hasBuyAbsorption) buyScore += 20;
   if(m_cachedSignal.hasSellAbsorption) sellScore += 20;
   
   // Unfinished auction (peso medio)
   if(m_cachedSignal.hasUnfinishedAuctionUp) buyScore += 15;
   if(m_cachedSignal.hasUnfinishedAuctionDown) sellScore += 15;
   
   // Delta divergence (peso medio)
   if(m_cachedSignal.hasBullishDeltaDivergence) buyScore += 15;
   if(m_cachedSignal.hasBearishDeltaDivergence) sellScore += 15;
   
   // Delta percent (peso baixo)
   if(m_cachedSignal.deltaPercent > 30) buyScore += 10;
   if(m_cachedSignal.deltaPercent < -30) sellScore += 10;
   
   // POC defense (bonus)
   if(m_cachedSignal.hasPOCDefense) {
      if(m_cachedSignal.barDelta > 0) buyScore += 10;
      else sellScore += 10;
   }
   
   // v3.4: Delta Acceleration (peso alto - momentum antes do preco)
   if(m_cachedSignal.hasBullishDeltaAcceleration) buyScore += 20;
   if(m_cachedSignal.hasBearishDeltaAcceleration) sellScore += 20;
   
   // v3.4: POC Divergence (peso alto - reversao confiavel)
   if(m_cachedSignal.hasBullishPOCDivergence) buyScore += 18;
   if(m_cachedSignal.hasBearishPOCDivergence) sellScore += 18;
   
   // Determina sinal
   int netScore = buyScore - sellScore;
   m_cachedSignal.strength = MathAbs(netScore);
   
   if(netScore >= 40)
      m_cachedSignal.signal = FP_SIGNAL_STRONG_BUY;
   else if(netScore >= 25)
      m_cachedSignal.signal = FP_SIGNAL_BUY;
   else if(netScore >= 10)
      m_cachedSignal.signal = FP_SIGNAL_WEAK_BUY;
   else if(netScore <= -40)
      m_cachedSignal.signal = FP_SIGNAL_STRONG_SELL;
   else if(netScore <= -25)
      m_cachedSignal.signal = FP_SIGNAL_SELL;
   else if(netScore <= -10)
      m_cachedSignal.signal = FP_SIGNAL_WEAK_SELL;
   else
      m_cachedSignal.signal = FP_SIGNAL_NEUTRAL;
   
   m_cacheValid = true;
   m_cachedBarTime = m_lastBarTime;
   
   return m_cachedSignal;
}

//+------------------------------------------------------------------+
//| Print diagnostics                                                 |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::PrintDiagnostics() {
   SFootprintSignal sig = GetSignal();
   
   Print("=== FOOTPRINT ANALYZER v3.1 DIAGNOSTICS ===");
   Print("Symbol: ", m_symbol, " | TF: ", EnumToString(m_timeframe));
   Print("Cluster Size: ", m_clusterSize, " | Levels: ", m_levelCount);
   Print("");
   Print("--- DELTA ---");
   Print("Bar Delta: ", sig.barDelta);
   Print("Cumulative Delta: ", sig.cumulativeDelta);
   Print("Delta %: ", DoubleToString(sig.deltaPercent, 1), "%");
   Print("");
   Print("--- VALUE AREA ---");
   Print("POC: ", sig.valueArea.poc);
   Print("VAH: ", sig.valueArea.vahigh);
   Print("VAL: ", sig.valueArea.valow);
   Print("");
   Print("--- PATTERNS ---");
   Print("Stacked Buy Imbalance: ", sig.hasStackedBuyImbalance ? "YES" : "NO");
   Print("Stacked Sell Imbalance: ", sig.hasStackedSellImbalance ? "YES" : "NO");
   Print("Buy Absorption: ", sig.hasBuyAbsorption ? "YES" : "NO");
   Print("Sell Absorption: ", sig.hasSellAbsorption ? "YES" : "NO");
   Print("Unfinished Auction Up: ", sig.hasUnfinishedAuctionUp ? "YES" : "NO");
   Print("Unfinished Auction Down: ", sig.hasUnfinishedAuctionDown ? "YES" : "NO");
   Print("Bullish Delta Divergence: ", sig.hasBullishDeltaDivergence ? "YES" : "NO");
   Print("Bearish Delta Divergence: ", sig.hasBearishDeltaDivergence ? "YES" : "NO");
   Print("POC Defense: ", sig.hasPOCDefense ? "YES" : "NO");
   Print("");
   Print("--- SIGNAL ---");
   Print("Signal: ", EnumToString(sig.signal));
   Print("Strength: ", sig.strength);
   Print("============================================");
}

//+------------------------------------------------------------------+
//| Print levels                                                      |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::PrintLevels() {
   Print("=== FOOTPRINT LEVELS ===");
   Print("Total: ", m_levelCount);
   
   for(int i = m_levelCount - 1; i >= 0; i--) {
      string imb = "";
      if(m_levels[i].hasBuyImbalance) imb = " [BUY IMB " + DoubleToString(m_levels[i].imbalanceRatio, 1) + "x]";
      if(m_levels[i].hasSellImbalance) imb = " [SELL IMB " + DoubleToString(m_levels[i].imbalanceRatio, 1) + "x]";
      
      Print(StringFormat("%.2f | Bid: %d | Ask: %d | Delta: %+d%s",
            m_levels[i].price,
            m_levels[i].bidVolume,
            m_levels[i].askVolume,
            m_levels[i].delta,
            imb));
   }
   Print("========================");
}

//+------------------------------------------------------------------+
//| Print stacked imbalances                                          |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::PrintStackedImbalances() {
   Print("=== STACKED IMBALANCES ===");
   Print("Count: ", m_stackedCount);
   
   for(int i = 0; i < m_stackedCount; i++) {
      Print(StringFormat("%d. %s: %.2f - %.2f (%d levels, avg %.1fx)",
            i + 1,
            m_stackedImbalances[i].type == IMBALANCE_BUY ? "BUY" : "SELL",
            m_stackedImbalances[i].startPrice,
            m_stackedImbalances[i].endPrice,
            m_stackedImbalances[i].levelCount,
            m_stackedImbalances[i].avgRatio));
   }
   Print("==========================");
}

//+------------------------------------------------------------------+
//| v3.3: Enable Dynamic Cluster Configuration                        |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::EnableDynamicCluster(bool enable, double atrMult = 0.1, 
                                               double minSize = 0.25, double maxSize = 2.0) {
   m_dynamicCluster = enable;
   m_atrMultiplier = atrMult;
   m_minClusterSize = minSize;
   m_maxClusterSize = maxSize;
   
   if(enable)
      Print("CFootprintAnalyzer: Dynamic cluster ENABLED (ATR*", atrMult, 
            ", min=", minSize, ", max=", maxSize, ")");
}

//+------------------------------------------------------------------+
//| v3.3: Adjust Cluster Size Based on ATR                            |
//| - High volatility (NFP/FOMC): Larger clusters                     |
//| - Low volatility: Smaller clusters for precision                  |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::AdjustClusterToATR() {
   if(m_atr_handle == INVALID_HANDLE) return;
   
   double atr[];
   if(CopyBuffer(m_atr_handle, 0, 0, 1, atr) <= 0) return;
   
   // Calculate dynamic cluster: ATR * multiplier
   double dynamicCluster = atr[0] * m_atrMultiplier;
   
   // Clamp to min/max bounds
   dynamicCluster = MathMax(m_minClusterSize, MathMin(m_maxClusterSize, dynamicCluster));
   
   // Round to tick size
   dynamicCluster = MathRound(dynamicCluster / m_tickSize) * m_tickSize;
   
   // Only update if significantly different (>10% change)
   if(MathAbs(dynamicCluster - m_clusterSize) / m_clusterSize > 0.1) {
      double oldCluster = m_clusterSize;
      m_clusterSize = dynamicCluster;
      m_absorptionMergeDistance = m_clusterSize * 2;
      Print("CFootprintAnalyzer: Cluster adjusted ", oldCluster, " -> ", m_clusterSize, 
            " (ATR=", DoubleToString(atr[0], 2), ")");
   }
}

//+------------------------------------------------------------------+
//| v3.3: Check Session Reset (London 07:00, NY 13:00 GMT)            |
//| - Resets cumulative delta at session boundaries                   |
//| - Prevents delta overflow and stale context                       |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::CheckSessionReset() {
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   int currentHour = dt.hour;
   
   // Reset at London open (07:00 GMT) and NY open (13:00 GMT)
   bool shouldReset = false;
   
   if((currentHour == 7 || currentHour == 13) && currentHour != m_lastResetHour) {
      shouldReset = true;
   }
   
   // Also reset if cumulative delta exceeds safe bounds (prevent overflow)
   if(MathAbs(m_cumulativeDelta) > 1000000000) {  // 1 billion
      shouldReset = true;
      Print("CFootprintAnalyzer: Delta overflow protection triggered");
   }
   
   if(shouldReset) {
      long oldDelta = m_cumulativeDelta;
      m_cumulativeDelta = 0;
      m_lastResetHour = currentHour;
      m_lastResetTime = TimeCurrent();
      Print("CFootprintAnalyzer: Session delta reset at ", currentHour, ":00 GMT (was: ", oldDelta, ")");
   }
}

//+------------------------------------------------------------------+
//| v3.3: Update Historical Absorptions                               |
//| - Persists significant absorption zones across bars               |
//| - Merges nearby zones, tracks test counts                         |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::UpdateHistoricalAbsorptions() {
   // Add current bar's high-confidence absorptions to history
   for(int i = 0; i < m_absorptionCount; i++) {
      if(m_absorptionZones[i].confidence >= 60) {  // Only track strong absorptions
         MergeOrAddAbsorption(m_absorptionZones[i]);
      }
   }
   
   // Remove old or broken zones (older than 50 bars or broken)
   datetime cutoff = TimeCurrent() - PeriodSeconds(m_timeframe) * 50;
   
   for(int i = m_historicalAbsCount - 1; i >= 0; i--) {
      if(m_historicalAbsorptions[i].broken || m_historicalAbsorptions[i].detectionTime < cutoff) {
         // Shift remaining elements
         for(int j = i; j < m_historicalAbsCount - 1; j++) {
            m_historicalAbsorptions[j] = m_historicalAbsorptions[j + 1];
         }
         m_historicalAbsCount--;
      }
   }
}

//+------------------------------------------------------------------+
//| v3.3: Merge or Add Absorption Zone                                |
//| - If zone exists nearby, merge (increase confidence/testCount)    |
//| - Otherwise add as new zone                                       |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::MergeOrAddAbsorption(const SAbsorptionZone &zone) {
   // Check if similar zone already exists
   for(int i = 0; i < m_historicalAbsCount; i++) {
      if(m_historicalAbsorptions[i].type == zone.type &&
         MathAbs(m_historicalAbsorptions[i].price - zone.price) < m_absorptionMergeDistance) {
         // Merge: Update with stronger confidence
         if(zone.confidence > m_historicalAbsorptions[i].confidence) {
            m_historicalAbsorptions[i].confidence = zone.confidence;
            m_historicalAbsorptions[i].totalVolume = zone.totalVolume;
         }
         m_historicalAbsorptions[i].testCount++;
         m_historicalAbsorptions[i].detectionTime = zone.detectionTime;  // Update time
         return;
      }
   }
   
   // Add new zone if space available
   if(m_historicalAbsCount < m_maxHistoricalAbs) {
      m_historicalAbsorptions[m_historicalAbsCount] = zone;
      m_historicalAbsCount++;
   }
   else {
      // Replace weakest zone
      int weakestIdx = 0;
      int weakestScore = m_historicalAbsorptions[0].confidence * m_historicalAbsorptions[0].testCount;
      
      for(int i = 1; i < m_historicalAbsCount; i++) {
         int score = m_historicalAbsorptions[i].confidence * m_historicalAbsorptions[i].testCount;
         if(score < weakestScore) {
            weakestScore = score;
            weakestIdx = i;
         }
      }
      
      // Only replace if new zone is stronger
      if(zone.confidence > m_historicalAbsorptions[weakestIdx].confidence) {
         m_historicalAbsorptions[weakestIdx] = zone;
      }
   }
}

//+------------------------------------------------------------------+
//| v3.3: Update Absorption Zone Tests                                |
//| - Checks if current price tested any historical zones             |
//| - Marks zones as broken if price went through                     |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::UpdateAbsorptionTests() {
   double currentBid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double barHigh = iHigh(m_symbol, m_timeframe, 0);
   double barLow = iLow(m_symbol, m_timeframe, 0);
   
   for(int i = 0; i < m_historicalAbsCount; i++) {
      if(m_historicalAbsorptions[i].broken) continue;
      
      double zonePrice = m_historicalAbsorptions[i].price;
      
      // Check if price touched the zone
      if(barLow <= zonePrice && barHigh >= zonePrice) {
         m_historicalAbsorptions[i].testCount++;
         
         // Check if zone was broken (price closed through it)
         double barClose = iClose(m_symbol, m_timeframe, 0);
         
         if(m_historicalAbsorptions[i].type == ABSORPTION_BUY) {
            // BUY absorption at low - broken if close < zone
            if(barClose < zonePrice - m_clusterSize) {
               m_historicalAbsorptions[i].broken = true;
            }
         }
         else {
            // SELL absorption at high - broken if close > zone  
            if(barClose > zonePrice + m_clusterSize) {
               m_historicalAbsorptions[i].broken = true;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| v3.3: Get Historical Absorption by Index                          |
//+------------------------------------------------------------------+
SAbsorptionZone CFootprintAnalyzer::GetHistoricalAbsorption(int index) {
   SAbsorptionZone empty;
   empty.Reset();
   
   if(index < 0 || index >= m_historicalAbsCount)
      return empty;
   
   return m_historicalAbsorptions[index];
}

//+------------------------------------------------------------------+
//| v3.4: Calculate Delta Acceleration                                 |
//| - Rate of change of bar delta between consecutive bars             |
//| - Positive = momentum building UP (bullish)                        |
//| - Negative = momentum building DOWN (bearish)                      |
//| - Range: -100 to +100 (normalized)                                 |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::CalculateDeltaAcceleration() {
   m_deltaAcceleration = 0;
   
   if(m_historyCount < 2) return;
   
   // Get last 3 bar deltas (current + 2 previous)
   long currentDelta = GetBarDelta();
   long prevDelta1 = m_deltaHistory[m_historyCount - 1];
   long prevDelta2 = (m_historyCount >= 2) ? m_deltaHistory[m_historyCount - 2] : prevDelta1;
   
   // Calculate velocity (rate of change)
   double velocity1 = (double)(currentDelta - prevDelta1);
   double velocity2 = (double)(prevDelta1 - prevDelta2);
   
   // Calculate acceleration (rate of change of velocity)
   double acceleration = velocity1 - velocity2;
   
   // Normalize to -100 to +100 range
   // Use average bar volume as reference for normalization
   long totalVol = 0;
   for(int i = 0; i < m_levelCount; i++) {
      totalVol += m_levels[i].bidVolume + m_levels[i].askVolume;
   }
   
   if(totalVol > 0) {
      // Normalize: acceleration as percentage of total volume
      m_deltaAcceleration = (acceleration / (double)totalVol) * 100.0;
      
      // Clamp to -100 to +100
      m_deltaAcceleration = MathMax(-100.0, MathMin(100.0, m_deltaAcceleration));
   }
}

//+------------------------------------------------------------------+
//| v3.4: Update POC History                                           |
//| - Stores POC from each bar for divergence detection                |
//+------------------------------------------------------------------+
void CFootprintAnalyzer::UpdatePOCHistory() {
   if(m_levelCount == 0) return;
   
   // Calculate current POC
   SValueArea va;
   CalculateValueArea(va);
   
   if(va.poc == 0) return;
   
   // Shift history if full
   if(m_pocHistoryCount >= m_maxPocHistory) {
      for(int i = 0; i < m_maxPocHistory - 1; i++) {
         m_pocHistory[i] = m_pocHistory[i + 1];
      }
      m_pocHistoryCount = m_maxPocHistory - 1;
   }
   
   // Add current POC
   m_pocHistory[m_pocHistoryCount] = va.poc;
   m_pocHistoryCount++;
}

//+------------------------------------------------------------------+
//| v3.4: Detect POC Divergence                                        |
//| - Bullish: POC rising while price falling (buyers accumulating)    |
//| - Bearish: POC falling while price rising (sellers distributing)   |
//| - More reliable than raw delta divergence                          |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::DetectPOCDivergence(bool &bullish, bool &bearish) {
   bullish = false;
   bearish = false;
   
   if(m_pocHistoryCount < 3 || m_historyCount < 3) return false;
   
   int lastPOC = m_pocHistoryCount - 1;
   int last = m_historyCount - 1;
   
   // Get POC trend (last 3 bars)
   double pocTrend = m_pocHistory[lastPOC] - m_pocHistory[lastPOC - 2];
   
   // Get price trend (last 3 bars)
   double priceTrend = m_priceHistory[last] - m_priceHistory[last - 2];
   
   // Bullish POC Divergence: POC rising while price falling
   // Interpretation: Buyers are accumulating at higher prices despite price falling
   if(pocTrend > m_clusterSize && priceTrend < -m_clusterSize) {
      bullish = true;
   }
   
   // Bearish POC Divergence: POC falling while price rising  
   // Interpretation: Sellers are distributing at lower prices despite price rising
   if(pocTrend < -m_clusterSize && priceTrend > m_clusterSize) {
      bearish = true;
   }
   
   return bullish || bearish;
}

//+------------------------------------------------------------------+
//| v3.4: Has Bullish Momentum (Delta Acceleration > threshold)        |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::HasBullishMomentum() {
   return m_deltaAcceleration > 20;  // Threshold: +20%
}

//+------------------------------------------------------------------+
//| v3.4: Has Bearish Momentum (Delta Acceleration < threshold)        |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::HasBearishMomentum() {
   return m_deltaAcceleration < -20;  // Threshold: -20%
}

//+------------------------------------------------------------------+
//| v3.4: Has Bullish POC Divergence                                   |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::HasBullishPOCDivergence() {
   bool bull, bear;
   DetectPOCDivergence(bull, bear);
   return bull;
}

//+------------------------------------------------------------------+
//| v3.4: Has Bearish POC Divergence                                   |
//+------------------------------------------------------------------+
bool CFootprintAnalyzer::HasBearishPOCDivergence() {
   bool bull, bear;
   DetectPOCDivergence(bull, bear);
   return bear;
}
//+------------------------------------------------------------------+

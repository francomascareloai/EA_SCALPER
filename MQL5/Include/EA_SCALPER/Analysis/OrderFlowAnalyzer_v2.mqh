//+------------------------------------------------------------------+
//|                                        OrderFlowAnalyzer_v2.mqh  |
//|                         EA_SCALPER_XAUUSD - Singularity Edition  |
//|                                                                  |
//| VERSAO 2.0 - Corrigida e Otimizada                              |
//| Resolve problemas de:                                            |
//| - TICK_FLAG nao disponivel em Forex/CFD                         |
//| - Performance com grandes datasets                               |
//| - Falta de validacao de dados                                   |
//| - Features importantes faltando                                  |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "2.00"

//+------------------------------------------------------------------+
//| Enums                                                             |
//+------------------------------------------------------------------+
enum ENUM_DIRECTION_METHOD {
   METHOD_TICK_FLAG,      // Usar TICK_FLAG (ideal, mas nem sempre disponivel)
   METHOD_PRICE_COMPARE,  // Comparar com preco anterior (fallback)
   METHOD_BID_ASK,        // Comparar com bid/ask (fallback)
   METHOD_AUTO            // Detectar automaticamente o melhor metodo
};

enum ENUM_DATA_QUALITY {
   QUALITY_UNKNOWN,
   QUALITY_POOR,          // < 50% dos ticks tem flags
   QUALITY_MODERATE,      // 50-80% dos ticks tem flags
   QUALITY_GOOD,          // > 80% dos ticks tem flags
   QUALITY_EXCELLENT      // > 95% dos ticks tem flags
};

//+------------------------------------------------------------------+
//| Estrutura para nivel de preco (otimizada)                        |
//+------------------------------------------------------------------+
struct SPriceLevelV2 {
   double price;
   long   buyVolume;
   long   sellVolume;
   long   delta;
   int    tickCount;
   double maxBuyPrice;    // Maior preco de compra neste nivel
   double minSellPrice;   // Menor preco de venda neste nivel
};

//+------------------------------------------------------------------+
//| Estrutura para Value Area                                         |
//+------------------------------------------------------------------+
struct SValueArea {
   double poc;            // Point of Control
   double vahigh;         // Value Area High (70% do volume)
   double valow;          // Value Area Low (70% do volume)
   long   pocVolume;      // Volume no POC
   long   totalVolume;    // Volume total
};

//+------------------------------------------------------------------+
//| Estrutura para resultado do Order Flow (expandida)               |
//+------------------------------------------------------------------+
struct SOrderFlowResultV2 {
   // Delta
   long   barDelta;
   long   cumulativeDelta;
   double deltaPercent;
   bool   isBuyDominant;
   
   // Value Area
   SValueArea valueArea;
   
   // Volumes
   long   totalBuyVolume;
   long   totalSellVolume;
   long   totalTicks;
   
   // Imbalances
   double imbalanceUp;
   double imbalanceDown;
   bool   hasStrongImbalance;
   int    imbalanceCount;
   
   // Qualidade dos dados
   ENUM_DATA_QUALITY dataQuality;
   double flagAvailabilityPercent;
   
   // Timestamps
   datetime barTime;
   datetime lastUpdate;
   
   // Sessao
   int    sessionBuyVol;
   int    sessionSellVol;
};

//+------------------------------------------------------------------+
//| Classe Order Flow Analyzer V2                                     |
//+------------------------------------------------------------------+
class COrderFlowAnalyzerV2 {
private:
   // Configuracao
   string         m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   double         m_tickSize;
   double         m_point;
   int            m_maxLevels;
   double         m_imbalanceRatio;
   double         m_valueAreaPercent;
   ENUM_DIRECTION_METHOD m_directionMethod;
   
   // Dados
   SPriceLevelV2  m_levels[];
   int            m_levelCount;
   long           m_cumulativeDelta;
   datetime       m_lastBarTime;
   datetime       m_lastTickTime;
   double         m_lastPrice;
   bool           m_levelsSorted;
   
   // Cache e otimizacao
   bool           m_cacheValid;
   SOrderFlowResultV2 m_cachedResult;
   int            m_ticksProcessed;
   int            m_ticksWithFlags;
   datetime       m_cachedResultBarTime;
   int            m_cachedResultTickCount;
   
   // Sessao
   long           m_sessionBuyVol;
   long           m_sessionSellVol;
   int            m_sessionStartHour;
   
   // Metodos privados
   int            FindPriceLevel(double price);
   int            AddPriceLevel(double price);
   double         NormalizePrice(double price);
   void           ResetBarData();
   void           ResetSessionData();
   
   // Deteccao de direcao
   int            DetectDirection(const MqlTick &tick);
   int            DetectDirectionByFlag(const MqlTick &tick);
   int            DetectDirectionByPrice(const MqlTick &tick);
   int            DetectDirectionByBidAsk(const MqlTick &tick);
   
   // Calculo de Value Area
   void           CalculateValueArea(SValueArea &va);
   void           SortLevelsByPrice();
   
   // Validacao
   bool           ValidateTick(const MqlTick &tick);
   void           UpdateDataQuality();
   
public:
                  COrderFlowAnalyzerV2();
                 ~COrderFlowAnalyzerV2();
   
   // Inicializacao
   bool           Initialize(string symbol, ENUM_TIMEFRAMES tf, 
                            int maxLevels = 200, 
                            double imbalanceRatio = 3.0,
                            double valueAreaPercent = 0.70,
                            ENUM_DIRECTION_METHOD method = METHOD_AUTO);
   void           Deinitialize();
   
   // Configuracao
   void           SetDirectionMethod(ENUM_DIRECTION_METHOD method) { m_directionMethod = method; }
   void           SetSessionStartHour(int hour) { m_sessionStartHour = hour; }
   
   // Processamento
   bool           ProcessTick();                          // Processa tick atual via CopyTicks
   bool           ProcessTickDirect(const MqlTick &tick); // Processa tick fornecido
   bool           ProcessBarTicks(int barIndex = 0);      // Processa barra especifica
   
   // Resultados
   SOrderFlowResultV2 GetResult();
   SValueArea     GetValueArea();
   long           GetBarDelta();
   long           GetCumulativeDelta();
   double         GetPOC();
   
   // Sinais
   int            GetSignal(int deltaThreshold = 500);
   bool           IsDeltaDivergence(int lookback = 3);
   bool           IsAbsorption(int volumeThreshold = 1000);
   bool           IsPOCDefense();
   
   // Qualidade
   ENUM_DATA_QUALITY GetDataQuality();
   bool           IsDataReliable();
   
   // Debug
   void           PrintDiagnostics();
   void           PrintLevels();
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
COrderFlowAnalyzerV2::COrderFlowAnalyzerV2() {
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_tickSize = 0;
   m_point = 0;
   m_maxLevels = 200;
   m_imbalanceRatio = 3.0;
   m_valueAreaPercent = 0.70;
   m_directionMethod = METHOD_AUTO;
   m_levelCount = 0;
   m_cumulativeDelta = 0;
   m_lastBarTime = 0;
   m_lastTickTime = 0;
   m_lastPrice = 0;
   m_levelsSorted = false;
   m_cacheValid = false;
   m_ticksProcessed = 0;
   m_ticksWithFlags = 0;
   m_cachedResultBarTime = 0;
   m_cachedResultTickCount = 0;
   m_sessionBuyVol = 0;
   m_sessionSellVol = 0;
   m_sessionStartHour = 0;
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
COrderFlowAnalyzerV2::~COrderFlowAnalyzerV2() {
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Inicializacao                                                     |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::Initialize(string symbol, ENUM_TIMEFRAMES tf, 
                                      int maxLevels = 200, 
                                      double imbalanceRatio = 3.0,
                                      double valueAreaPercent = 0.70,
                                      ENUM_DIRECTION_METHOD method = METHOD_AUTO) {
   m_symbol = symbol;
   m_timeframe = tf;
   m_maxLevels = maxLevels;
   m_imbalanceRatio = imbalanceRatio;
   m_valueAreaPercent = valueAreaPercent;
   m_directionMethod = method;
   
   // Obtem parametros do simbolo
   m_tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
   m_point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   
   if(m_tickSize == 0 || m_point == 0) {
      Print("OrderFlowAnalyzer V2: Erro ao obter parametros de ", m_symbol);
      return false;
   }
   
   // Aloca arrays
   ArrayResize(m_levels, m_maxLevels);
   ResetBarData();
   
   // Se AUTO, detecta melhor metodo testando alguns ticks
   if(m_directionMethod == METHOD_AUTO) {
      MqlTick ticks[];
      int copied = CopyTicks(m_symbol, ticks, COPY_TICKS_ALL, 0, 100);
      
      if(copied > 0) {
         int withFlags = 0;
         for(int i = 0; i < copied; i++) {
            bool hasBuy = (ticks[i].flags & TICK_FLAG_BUY) != 0;
            bool hasSell = (ticks[i].flags & TICK_FLAG_SELL) != 0;
            if(hasBuy || hasSell) withFlags++;
         }
         
         double flagPercent = (double)withFlags / copied * 100;
         
         if(flagPercent > 80) {
            m_directionMethod = METHOD_TICK_FLAG;
            Print("OrderFlowAnalyzer V2: Usando TICK_FLAG (", DoubleToString(flagPercent, 1), "% disponivel)");
         }
         else if(flagPercent > 30) {
            m_directionMethod = METHOD_TICK_FLAG; // Ainda usa flags mas com fallback
            Print("OrderFlowAnalyzer V2: TICK_FLAG parcial (", DoubleToString(flagPercent, 1), "%), usando com fallback");
         }
         else {
            m_directionMethod = METHOD_PRICE_COMPARE;
            Print("OrderFlowAnalyzer V2: TICK_FLAG indisponivel, usando comparacao de preco");
         }
      }
      else {
         m_directionMethod = METHOD_PRICE_COMPARE;
         Print("OrderFlowAnalyzer V2: Sem ticks para teste, usando comparacao de preco");
      }
   }
   
   Print("OrderFlowAnalyzer V2 inicializado: ", m_symbol, 
         " | TickSize: ", m_tickSize,
         " | Metodo: ", EnumToString(m_directionMethod));
   
   return true;
}

//+------------------------------------------------------------------+
//| Desinicializacao                                                  |
//+------------------------------------------------------------------+
void COrderFlowAnalyzerV2::Deinitialize() {
   ArrayFree(m_levels);
   m_levelCount = 0;
   m_levelsSorted = false;
}

//+------------------------------------------------------------------+
//| Normaliza preco para nivel                                        |
//+------------------------------------------------------------------+
double COrderFlowAnalyzerV2::NormalizePrice(double price) {
   return MathRound(price / m_tickSize) * m_tickSize;
}

//+------------------------------------------------------------------+
//| Encontra nivel de preco                                           |
//+------------------------------------------------------------------+
int COrderFlowAnalyzerV2::FindPriceLevel(double price) {
   double normPrice = NormalizePrice(price);
   for(int i = 0; i < m_levelCount; i++) {
      if(MathAbs(m_levels[i].price - normPrice) < m_tickSize / 2) {
         return i;
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Adiciona nivel de preco                                           |
//+------------------------------------------------------------------+
int COrderFlowAnalyzerV2::AddPriceLevel(double price) {
   if(m_levelCount >= m_maxLevels) {
      // Remove nivel com menor volume
      int minIdx = 0;
      long minVol = m_levels[0].buyVolume + m_levels[0].sellVolume;
      for(int i = 1; i < m_levelCount; i++) {
         long vol = m_levels[i].buyVolume + m_levels[i].sellVolume;
         if(vol < minVol) {
            minVol = vol;
            minIdx = i;
         }
      }
      // Substitui
      ZeroMemory(m_levels[minIdx]);
      m_levels[minIdx].price = NormalizePrice(price);
      m_levelsSorted = false;
      return minIdx;
   }
   
   int idx = m_levelCount;
   ZeroMemory(m_levels[idx]);
   m_levels[idx].price = NormalizePrice(price);
   m_levelCount++;
   m_levelsSorted = false;
   return idx;
}

//+------------------------------------------------------------------+
//| Reseta dados da barra                                             |
//+------------------------------------------------------------------+
void COrderFlowAnalyzerV2::ResetBarData() {
   m_levelCount = 0;
   m_ticksProcessed = 0;
   m_ticksWithFlags = 0;
   m_cacheValid = false;
   m_lastPrice = 0; // reset last price to avoid cross-bar bias in direction
   m_levelsSorted = false;
   m_cachedResultBarTime = 0;
   m_cachedResultTickCount = 0;
   
   for(int i = 0; i < m_maxLevels; i++) {
      ZeroMemory(m_levels[i]);
   }
}

//+------------------------------------------------------------------+
//| Reseta dados da sessao                                            |
//+------------------------------------------------------------------+
void COrderFlowAnalyzerV2::ResetSessionData() {
   m_sessionBuyVol = 0;
   m_sessionSellVol = 0;
   m_cumulativeDelta = 0;
}

//+------------------------------------------------------------------+
//| Valida tick                                                       |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::ValidateTick(const MqlTick &tick) {
   // Verifica se tem dados validos
   if(tick.bid <= 0 && tick.ask <= 0 && tick.last <= 0) return false;
   
   // Verifica spread razoavel (< 10% do preco)
   if(tick.ask > 0 && tick.bid > 0) {
      double spread = tick.ask - tick.bid;
      if(spread < 0 || spread > tick.bid * 0.10) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Detecta direcao do tick                                           |
//| Retorna: 1 = Buy, -1 = Sell, 0 = Indefinido                      |
//+------------------------------------------------------------------+
int COrderFlowAnalyzerV2::DetectDirection(const MqlTick &tick) {
   int direction = 0;
   
   switch(m_directionMethod) {
      case METHOD_TICK_FLAG:
         direction = DetectDirectionByFlag(tick);
         // Fallback se flag nao disponivel
         if(direction == 0) direction = DetectDirectionByPrice(tick);
         break;
         
      case METHOD_PRICE_COMPARE:
         direction = DetectDirectionByPrice(tick);
         break;
         
      case METHOD_BID_ASK:
         direction = DetectDirectionByBidAsk(tick);
         break;
         
      default:
         direction = DetectDirectionByFlag(tick);
         if(direction == 0) direction = DetectDirectionByPrice(tick);
   }
   
   return direction;
}

//+------------------------------------------------------------------+
//| Detecta direcao por TICK_FLAG                                     |
//+------------------------------------------------------------------+
int COrderFlowAnalyzerV2::DetectDirectionByFlag(const MqlTick &tick) {
   bool hasBuy = (tick.flags & TICK_FLAG_BUY) != 0;
   bool hasSell = (tick.flags & TICK_FLAG_SELL) != 0;
   
   // Ambos setados = dados inconsistentes, ignora
   if(hasBuy && hasSell) return 0;
   
   if(hasBuy) {
      m_ticksWithFlags++;
      return 1;
   }
   if(hasSell) {
      m_ticksWithFlags++;
      return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Detecta direcao por comparacao de preco                           |
//| Metodo: Se preco subiu = compra, se caiu = venda                 |
//+------------------------------------------------------------------+
int COrderFlowAnalyzerV2::DetectDirectionByPrice(const MqlTick &tick) {
   double currentPrice = (tick.last > 0) ? tick.last : (tick.bid + tick.ask) / 2;
   
   if(m_lastPrice == 0) {
      m_lastPrice = currentPrice;
      return 0;
   }
   
   int direction = 0;
   
   if(currentPrice > m_lastPrice + m_point) {
      direction = 1;  // Uptick = buy aggressor
   }
   else if(currentPrice < m_lastPrice - m_point) {
      direction = -1; // Downtick = sell aggressor
   }
   
   m_lastPrice = currentPrice;
   return direction;
}

//+------------------------------------------------------------------+
//| Detecta direcao por bid/ask                                       |
//| Metodo: Trade no Ask = Buy, Trade no Bid = Sell                  |
//+------------------------------------------------------------------+
int COrderFlowAnalyzerV2::DetectDirectionByBidAsk(const MqlTick &tick) {
   if(tick.last <= 0 || tick.bid <= 0 || tick.ask <= 0) return 0;
   
   double mid = (tick.bid + tick.ask) / 2;
   
   // Se o last price esta mais proximo do ask, foi um buy
   if(tick.last >= mid) return 1;
   // Se esta mais proximo do bid, foi um sell
   return -1;
}

//+------------------------------------------------------------------+
//| Processa tick atual (usa CopyTicks - mais confiavel)              |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::ProcessTick() {
   MqlTick ticks[];
   
   // Copia ultimo tick via CopyTicks (tem os flags!)
   int copied = CopyTicks(m_symbol, ticks, COPY_TICKS_ALL, 0, 1);
   
   if(copied <= 0) return false;
   
   return ProcessTickDirect(ticks[0]);
}

//+------------------------------------------------------------------+
//| Processa tick fornecido diretamente                               |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::ProcessTickDirect(const MqlTick &tick) {
   // Valida tick
   if(!ValidateTick(tick)) return false;
   
   // Verifica nova barra
   datetime barTime = iTime(m_symbol, m_timeframe, 0);
   if(barTime != m_lastBarTime) {
      ResetBarData();
      m_lastBarTime = barTime;
   }
   
   // Verifica nova sessao
   MqlDateTime dt;
   TimeToStruct(tick.time, dt);
   if(dt.hour == m_sessionStartHour && m_lastTickTime > 0) {
      MqlDateTime lastDt;
      TimeToStruct(m_lastTickTime, lastDt);
      if(lastDt.hour != m_sessionStartHour) {
         ResetSessionData();
      }
   }
   m_lastTickTime = tick.time;
   
   // Detecta direcao
   int direction = DetectDirection(tick);
   
   // Determina preco e volume
   double price = (tick.last > 0) ? tick.last : tick.bid;
   long volume = (long)tick.volume;
   if(volume == 0) volume = 1;
   
   // Encontra ou cria nivel
   int idx = FindPriceLevel(price);
   if(idx < 0) {
      idx = AddPriceLevel(price);
   }
   
   // Atualiza nivel
   m_levels[idx].tickCount++;
   
   if(direction > 0) {
      m_levels[idx].buyVolume += volume;
      m_cumulativeDelta += volume;
      m_sessionBuyVol += volume;
      
      if(m_levels[idx].maxBuyPrice == 0 || price > m_levels[idx].maxBuyPrice) {
         m_levels[idx].maxBuyPrice = price;
      }
   }
   else if(direction < 0) {
      m_levels[idx].sellVolume += volume;
      m_cumulativeDelta -= volume;
      m_sessionSellVol += volume;
      
      if(m_levels[idx].minSellPrice == 0 || price < m_levels[idx].minSellPrice) {
         m_levels[idx].minSellPrice = price;
      }
   }
   
   // Atualiza delta do nivel
   m_levels[idx].delta = m_levels[idx].buyVolume - m_levels[idx].sellVolume;
   
   m_ticksProcessed++;
   m_levelsSorted = false;
   m_cacheValid = false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Processa todos os ticks de uma barra (OTIMIZADO)                  |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::ProcessBarTicks(int barIndex = 0) {
   ResetBarData();
   
   datetime barTime = iTime(m_symbol, m_timeframe, barIndex);
   m_lastBarTime = barTime;
   
   // Calcula periodo da barra
   int barSeconds = PeriodSeconds(m_timeframe);
   datetime barEnd = barTime + barSeconds;
   
   MqlTick ticks[];
   
   // Copia ticks do periodo
   int copied = CopyTicksRange(m_symbol, ticks, COPY_TICKS_ALL, 
                               barTime * 1000, barEnd * 1000);
   
   if(copied <= 0) {
      Print("OrderFlowAnalyzer V2: Nenhum tick encontrado para barra ", barIndex);
      return false;
   }
   
   // Limita processamento para performance
   int maxTicks = MathMin(copied, 50000);
   int step = (copied > maxTicks) ? copied / maxTicks : 1;
   
   if(step > 1) {
      Print("OrderFlowAnalyzer V2: Amostrando ", maxTicks, " de ", copied, " ticks");
   }
   
   // Processa ticks
   for(int i = 0; i < copied; i += step) {
      ProcessTickDirect(ticks[i]);
   }
   
   UpdateDataQuality();
   
   return true;
}

//+------------------------------------------------------------------+
//| Atualiza qualidade dos dados                                      |
//+------------------------------------------------------------------+
void COrderFlowAnalyzerV2::UpdateDataQuality() {
   if(m_ticksProcessed == 0) return;
   
   double flagPercent = (double)m_ticksWithFlags / m_ticksProcessed * 100;
   
   // Atualiza no resultado cacheado
   m_cachedResult.flagAvailabilityPercent = flagPercent;
   
   if(flagPercent >= 95) {
      m_cachedResult.dataQuality = QUALITY_EXCELLENT;
   }
   else if(flagPercent >= 80) {
      m_cachedResult.dataQuality = QUALITY_GOOD;
   }
   else if(flagPercent >= 50) {
      m_cachedResult.dataQuality = QUALITY_MODERATE;
   }
   else if(flagPercent > 0) {
      m_cachedResult.dataQuality = QUALITY_POOR;
   }
   else {
      m_cachedResult.dataQuality = QUALITY_UNKNOWN;
   }
}

//+------------------------------------------------------------------+
//| Ordena niveis de preco por valor (necessario para VA correta)    |
//+------------------------------------------------------------------+
void COrderFlowAnalyzerV2::SortLevelsByPrice() {
   if(m_levelCount <= 1 || m_levelsSorted) return;
   
   // Simple insertion sort (m_levelCount <= m_maxLevels ~200)
   for(int i = 1; i < m_levelCount; i++) {
      SPriceLevelV2 key = m_levels[i];
      int j = i - 1;
      while(j >= 0 && m_levels[j].price > key.price) {
         m_levels[j + 1] = m_levels[j];
         j--;
      }
      m_levels[j + 1] = key;
   }
   m_levelsSorted = true;
}

//+------------------------------------------------------------------+
//| Calcula Value Area (70% do volume)                                |
//+------------------------------------------------------------------+
void COrderFlowAnalyzerV2::CalculateValueArea(SValueArea &va) {
   if(m_levelCount == 0) {
      ZeroMemory(va);
      return;
   }
   
    // Garantir ordenacao por preco antes de expandir VA
    SortLevelsByPrice();
   
   // Encontra POC (maior volume)
   int pocIdx = 0;
   long maxVol = 0;
   long totalVol = 0;
   
   for(int i = 0; i < m_levelCount; i++) {
      long vol = m_levels[i].buyVolume + m_levels[i].sellVolume;
      totalVol += vol;
      if(vol > maxVol) {
         maxVol = vol;
         pocIdx = i;
      }
   }
   
   va.poc = m_levels[pocIdx].price;
   va.pocVolume = maxVol;
   va.totalVolume = totalVol;
   
   // Calcula Value Area (70% do volume a partir do POC)
   long targetVol = (long)(totalVol * m_valueAreaPercent);
   long currentVol = maxVol;
   
   va.vahigh = va.poc;
   va.valow = va.poc;
   
   int upperIdx = pocIdx;
   int lowerIdx = pocIdx;
   
   while(currentVol < targetVol && (upperIdx < m_levelCount - 1 || lowerIdx > 0)) {
      long upperVol = 0, lowerVol = 0;
      
      if(upperIdx < m_levelCount - 1) {
         upperVol = m_levels[upperIdx + 1].buyVolume + m_levels[upperIdx + 1].sellVolume;
      }
      if(lowerIdx > 0) {
         lowerVol = m_levels[lowerIdx - 1].buyVolume + m_levels[lowerIdx - 1].sellVolume;
      }
      
      // Expande na direcao de maior volume
      if(upperVol >= lowerVol && upperIdx < m_levelCount - 1) {
         upperIdx++;
         currentVol += upperVol;
         if(m_levels[upperIdx].price > va.vahigh) va.vahigh = m_levels[upperIdx].price;
      }
      else if(lowerIdx > 0) {
         lowerIdx--;
         currentVol += lowerVol;
         if(m_levels[lowerIdx].price < va.valow) va.valow = m_levels[lowerIdx].price;
      }
      else break;
   }
}

//+------------------------------------------------------------------+
//| Obtem delta total da barra                                        |
//+------------------------------------------------------------------+
long COrderFlowAnalyzerV2::GetBarDelta() {
   long delta = 0;
   for(int i = 0; i < m_levelCount; i++) {
      delta += m_levels[i].delta;
   }
   return delta;
}

//+------------------------------------------------------------------+
//| Obtem delta acumulado                                             |
//+------------------------------------------------------------------+
long COrderFlowAnalyzerV2::GetCumulativeDelta() {
   return m_cumulativeDelta;
}

//+------------------------------------------------------------------+
//| Obtem POC                                                         |
//+------------------------------------------------------------------+
double COrderFlowAnalyzerV2::GetPOC() {
   if(m_levelCount == 0) return 0;
   
    SortLevelsByPrice();
   
   int pocIdx = 0;
   long maxVol = 0;
   
   for(int i = 0; i < m_levelCount; i++) {
      long vol = m_levels[i].buyVolume + m_levels[i].sellVolume;
      if(vol > maxVol) {
         maxVol = vol;
         pocIdx = i;
      }
   }
   
   return m_levels[pocIdx].price;
}

//+------------------------------------------------------------------+
//| Obtem Value Area                                                  |
//+------------------------------------------------------------------+
SValueArea COrderFlowAnalyzerV2::GetValueArea() {
   SValueArea va;
   CalculateValueArea(va);
   return va;
}

//+------------------------------------------------------------------+
//| Obtem resultado completo                                          |
//+------------------------------------------------------------------+
SOrderFlowResultV2 COrderFlowAnalyzerV2::GetResult() {
   if(m_cacheValid && m_cachedResultBarTime == m_lastBarTime && m_cachedResultTickCount == m_ticksProcessed)
      return m_cachedResult;
   
   SOrderFlowResultV2 result;
   ZeroMemory(result);
   
   // Garantir ordenacao para metricas dependentes de proximidade
   SortLevelsByPrice();
   
   // Delta
   result.barDelta = GetBarDelta();
   result.cumulativeDelta = m_cumulativeDelta;
   result.isBuyDominant = result.barDelta > 0;
   
   // Value Area
   CalculateValueArea(result.valueArea);
   
   // Volumes
   result.totalTicks = m_ticksProcessed;
   
   for(int i = 0; i < m_levelCount; i++) {
      result.totalBuyVolume += m_levels[i].buyVolume;
      result.totalSellVolume += m_levels[i].sellVolume;
      
      // Imbalances
      double buyVol = (double)m_levels[i].buyVolume;
      double sellVol = (double)m_levels[i].sellVolume;
      
      if(sellVol > 0 && buyVol / sellVol >= m_imbalanceRatio) {
         result.imbalanceCount++;
         if(result.imbalanceUp == 0 || m_levels[i].price > result.imbalanceUp) {
            result.imbalanceUp = m_levels[i].price;
         }
      }
      if(buyVol > 0 && sellVol / buyVol >= m_imbalanceRatio) {
         result.imbalanceCount++;
         if(result.imbalanceDown == 0 || m_levels[i].price < result.imbalanceDown) {
            result.imbalanceDown = m_levels[i].price;
         }
      }
   }
   
   // Delta percent
   long totalVol = result.totalBuyVolume + result.totalSellVolume;
   result.deltaPercent = (totalVol > 0) ? (double)result.barDelta / totalVol * 100 : 0;
   
   // Imbalance
   result.hasStrongImbalance = result.imbalanceCount >= 2;
   
   // Qualidade
   UpdateDataQuality();
   result.dataQuality = m_cachedResult.dataQuality;
   result.flagAvailabilityPercent = m_cachedResult.flagAvailabilityPercent;
   
   // Timestamps
   result.barTime = m_lastBarTime;
   result.lastUpdate = TimeCurrent();
   
   // Sessao
   result.sessionBuyVol = (int)m_sessionBuyVol;
   result.sessionSellVol = (int)m_sessionSellVol;
   
   m_cachedResult = result;
   m_cacheValid = true;
   m_cachedResultBarTime = m_lastBarTime;
   m_cachedResultTickCount = m_ticksProcessed;
   
   return result;
}

//+------------------------------------------------------------------+
//| Obtem sinal de trading                                            |
//+------------------------------------------------------------------+
int COrderFlowAnalyzerV2::GetSignal(int deltaThreshold = 500) {
   SOrderFlowResultV2 result = GetResult();
   
   // Sinal forte
   if(result.barDelta > deltaThreshold && result.hasStrongImbalance && result.imbalanceUp > 0) {
      return 1;
   }
   if(result.barDelta < -deltaThreshold && result.hasStrongImbalance && result.imbalanceDown > 0) {
      return -1;
   }
   
   // Sinal moderado
   if(result.deltaPercent > 40) return 1;
   if(result.deltaPercent < -40) return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Detecta divergencia de delta                                      |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::IsDeltaDivergence(int lookback = 3) {
   double priceChange = iClose(m_symbol, m_timeframe, 0) - iClose(m_symbol, m_timeframe, lookback);
   long delta = GetBarDelta();
   
   // Preco subindo, delta negativo
   if(priceChange > 0 && delta < -100) return true;
   // Preco caindo, delta positivo
   if(priceChange < 0 && delta > 100) return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Detecta absorcao                                                  |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::IsAbsorption(int volumeThreshold = 1000) {
   SOrderFlowResultV2 result = GetResult();
   long totalVol = result.totalBuyVolume + result.totalSellVolume;
   
   // Alto volume, delta neutro
   if(totalVol > volumeThreshold && MathAbs(result.deltaPercent) < 15) {
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Detecta defesa no POC                                             |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::IsPOCDefense() {
   SValueArea va = GetValueArea();
   double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   
   // Preco proximo do POC com alto volume
   if(MathAbs(currentPrice - va.poc) < m_tickSize * 5) {
      if(va.pocVolume > va.totalVolume * 0.15) { // POC tem >15% do volume
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Obtem qualidade dos dados                                         |
//+------------------------------------------------------------------+
ENUM_DATA_QUALITY COrderFlowAnalyzerV2::GetDataQuality() {
   GetResult(); // Atualiza cache
   return m_cachedResult.dataQuality;
}

//+------------------------------------------------------------------+
//| Verifica se dados sao confiaveis                                  |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzerV2::IsDataReliable() {
   ENUM_DATA_QUALITY q = GetDataQuality();
   return (q == QUALITY_GOOD || q == QUALITY_EXCELLENT);
}

//+------------------------------------------------------------------+
//| Imprime diagnosticos                                              |
//+------------------------------------------------------------------+
void COrderFlowAnalyzerV2::PrintDiagnostics() {
   SOrderFlowResultV2 result = GetResult();
   
   Print("=== ORDER FLOW ANALYZER V2 - DIAGNOSTICOS ===");
   Print("Simbolo: ", m_symbol);
   Print("Timeframe: ", EnumToString(m_timeframe));
   Print("Metodo de Direcao: ", EnumToString(m_directionMethod));
   Print("");
   Print("--- Qualidade dos Dados ---");
   Print("Qualidade: ", EnumToString(result.dataQuality));
   Print("Flags disponiveis: ", DoubleToString(result.flagAvailabilityPercent, 1), "%");
   Print("Ticks processados: ", result.totalTicks);
   Print("Dados confiaveis: ", IsDataReliable() ? "SIM" : "NAO");
   Print("");
   Print("--- Delta ---");
   Print("Bar Delta: ", result.barDelta);
   Print("Cumulative Delta: ", result.cumulativeDelta);
   Print("Delta %: ", DoubleToString(result.deltaPercent, 1), "%");
   Print("");
   Print("--- Value Area ---");
   Print("POC: ", result.valueArea.poc);
   Print("VA High: ", result.valueArea.vahigh);
   Print("VA Low: ", result.valueArea.valow);
   Print("POC Volume: ", result.valueArea.pocVolume, " (", 
         DoubleToString((double)result.valueArea.pocVolume / result.valueArea.totalVolume * 100, 1), "%)");
   Print("");
   Print("--- Imbalances ---");
   Print("Imbalance Up: ", result.imbalanceUp);
   Print("Imbalance Down: ", result.imbalanceDown);
   Print("Total Imbalances: ", result.imbalanceCount);
   Print("Strong Imbalance: ", result.hasStrongImbalance ? "SIM" : "NAO");
   Print("=============================================");
}

//+------------------------------------------------------------------+
//| Imprime niveis                                                    |
//+------------------------------------------------------------------+
void COrderFlowAnalyzerV2::PrintLevels() {
   Print("=== PRICE LEVELS ===");
   Print("Total levels: ", m_levelCount);
   
   for(int i = 0; i < m_levelCount; i++) {
      if(m_levels[i].buyVolume > 0 || m_levels[i].sellVolume > 0) {
         string imb = "";
         double buyVol = (double)m_levels[i].buyVolume;
         double sellVol = (double)m_levels[i].sellVolume;
         
         if(sellVol > 0 && buyVol / sellVol >= m_imbalanceRatio) imb = " [BUY IMB]";
         if(buyVol > 0 && sellVol / buyVol >= m_imbalanceRatio) imb = " [SELL IMB]";
         
         Print(StringFormat("%.2f | Buy: %d | Sell: %d | Delta: %+d%s",
               m_levels[i].price,
               m_levels[i].buyVolume,
               m_levels[i].sellVolume,
               m_levels[i].delta,
               imb));
      }
   }
   Print("====================");
}
//+------------------------------------------------------------------+

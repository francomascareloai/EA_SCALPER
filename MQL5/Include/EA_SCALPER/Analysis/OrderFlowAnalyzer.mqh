//+------------------------------------------------------------------+
//|                                           OrderFlowAnalyzer.mqh  |
//|                         EA_SCALPER_XAUUSD - Singularity Edition  |
//|                                                                  |
//| Modulo de Order Flow / Footprint Analysis                        |
//| Calcula Delta, Imbalance, POC, VWAP usando tick data nativo     |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Estrutura para nivel de preco                                    |
//+------------------------------------------------------------------+
struct SPriceLevel {
   double price;
   long   buyVolume;
   long   sellVolume;
   long   delta;
   int    buyCount;
   int    sellCount;
};

//+------------------------------------------------------------------+
//| Estrutura para resultado do Order Flow                           |
//+------------------------------------------------------------------+
struct SOrderFlowResult {
   long   barDelta;           // Delta total da barra
   long   cumulativeDelta;    // Delta acumulado
   double poc;                // Point of Control (maior volume)
   double vwap;               // Volume Weighted Average Price
   double imbalanceUp;        // Preco com imbalance de compra
   double imbalanceDown;      // Preco com imbalance de venda
   long   totalBuyVolume;     // Volume total de compra
   long   totalSellVolume;    // Volume total de venda
   double deltaPercent;       // Delta como % do volume total
   bool   isBuyDominant;      // Compradores dominantes?
   bool   hasStrongImbalance; // Tem imbalance forte?
};

//+------------------------------------------------------------------+
//| Classe Order Flow Analyzer                                       |
//+------------------------------------------------------------------+
class COrderFlowAnalyzer {
private:
   string         m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   double         m_tickSize;
   int            m_maxLevels;
   double         m_imbalanceRatio;
   
   SPriceLevel    m_levels[];
   int            m_levelCount;
   
   long           m_cumulativeDelta;
   datetime       m_lastBarTime;
   
   // Metodos privados
   int            FindPriceLevel(double price);
   int            AddPriceLevel(double price);
   double         NormalizePrice(double price);
   void           ResetBarData();
   
public:
                  COrderFlowAnalyzer();
                 ~COrderFlowAnalyzer();
   
   // Inicializacao
   bool           Initialize(string symbol, ENUM_TIMEFRAMES tf, int maxLevels = 100, double imbalanceRatio = 3.0);
   void           Deinitialize();
   
   // Processamento
   void           ProcessTick(const MqlTick &tick);
   void           ProcessBarTicks(datetime barTime);
   
   // Resultados
   SOrderFlowResult GetResult();
   long           GetBarDelta();
   long           GetCumulativeDelta();
   double         GetPOC();
   double         GetVWAP();
   bool           HasBuyImbalance(double price);
   bool           HasSellImbalance(double price);
   
   // Sinais
   int            GetSignal(int deltaThreshold = 500, double imbalanceRatio = 3.0);
   bool           IsDeltaDivergence(double priceDirection);
   bool           IsAbsorption(int volumeThreshold = 1000);
   
   // Debug
   void           PrintLevels();
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
COrderFlowAnalyzer::COrderFlowAnalyzer() {
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_tickSize = 0;
   m_maxLevels = 100;
   m_imbalanceRatio = 3.0;
   m_levelCount = 0;
   m_cumulativeDelta = 0;
   m_lastBarTime = 0;
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
COrderFlowAnalyzer::~COrderFlowAnalyzer() {
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Inicializacao                                                     |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzer::Initialize(string symbol, ENUM_TIMEFRAMES tf, int maxLevels = 100, double imbalanceRatio = 3.0) {
   m_symbol = symbol;
   m_timeframe = tf;
   m_maxLevels = maxLevels;
   m_imbalanceRatio = imbalanceRatio;
   
   m_tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
   if(m_tickSize == 0) {
      Print("OrderFlowAnalyzer: Erro ao obter tick size para ", m_symbol);
      return false;
   }
   
   ArrayResize(m_levels, m_maxLevels);
   ResetBarData();
   
   Print("OrderFlowAnalyzer inicializado: ", m_symbol, " | TickSize: ", m_tickSize);
   return true;
}

//+------------------------------------------------------------------+
//| Desinicializacao                                                  |
//+------------------------------------------------------------------+
void COrderFlowAnalyzer::Deinitialize() {
   ArrayFree(m_levels);
   m_levelCount = 0;
}

//+------------------------------------------------------------------+
//| Normaliza preco para nivel                                        |
//+------------------------------------------------------------------+
double COrderFlowAnalyzer::NormalizePrice(double price) {
   return MathRound(price / m_tickSize) * m_tickSize;
}

//+------------------------------------------------------------------+
//| Encontra nivel de preco                                           |
//+------------------------------------------------------------------+
int COrderFlowAnalyzer::FindPriceLevel(double price) {
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
int COrderFlowAnalyzer::AddPriceLevel(double price) {
   if(m_levelCount >= m_maxLevels) {
      // Remove nivel mais antigo com menor volume
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
      m_levels[minIdx].price = NormalizePrice(price);
      m_levels[minIdx].buyVolume = 0;
      m_levels[minIdx].sellVolume = 0;
      m_levels[minIdx].delta = 0;
      m_levels[minIdx].buyCount = 0;
      m_levels[minIdx].sellCount = 0;
      return minIdx;
   }
   
   int idx = m_levelCount;
   m_levels[idx].price = NormalizePrice(price);
   m_levels[idx].buyVolume = 0;
   m_levels[idx].sellVolume = 0;
   m_levels[idx].delta = 0;
   m_levels[idx].buyCount = 0;
   m_levels[idx].sellCount = 0;
   m_levelCount++;
   return idx;
}

//+------------------------------------------------------------------+
//| Reseta dados da barra                                             |
//+------------------------------------------------------------------+
void COrderFlowAnalyzer::ResetBarData() {
   m_levelCount = 0;
   for(int i = 0; i < m_maxLevels; i++) {
      m_levels[i].price = 0;
      m_levels[i].buyVolume = 0;
      m_levels[i].sellVolume = 0;
      m_levels[i].delta = 0;
      m_levels[i].buyCount = 0;
      m_levels[i].sellCount = 0;
   }
}

//+------------------------------------------------------------------+
//| Processa um tick                                                  |
//+------------------------------------------------------------------+
void COrderFlowAnalyzer::ProcessTick(const MqlTick &tick) {
   // Verifica nova barra
   datetime barTime = iTime(m_symbol, m_timeframe, 0);
   if(barTime != m_lastBarTime) {
      ResetBarData();
      m_lastBarTime = barTime;
   }
   
   // Determina preco (usa Last se disponivel, senao Bid)
   double price = (tick.last > 0) ? tick.last : tick.bid;
   long volume = (long)tick.volume;
   if(volume == 0) volume = 1; // Minimo 1
   
   // Encontra ou cria nivel
   int idx = FindPriceLevel(price);
   if(idx < 0) {
      idx = AddPriceLevel(price);
   }
   
   // Classifica direcao
   bool isBuy = (tick.flags & TICK_FLAG_BUY) != 0;
   bool isSell = (tick.flags & TICK_FLAG_SELL) != 0;
   
   if(isBuy) {
      m_levels[idx].buyVolume += volume;
      m_levels[idx].buyCount++;
      m_cumulativeDelta += volume;
   }
   else if(isSell) {
      m_levels[idx].sellVolume += volume;
      m_levels[idx].sellCount++;
      m_cumulativeDelta -= volume;
   }
   
   // Atualiza delta do nivel
   m_levels[idx].delta = m_levels[idx].buyVolume - m_levels[idx].sellVolume;
}

//+------------------------------------------------------------------+
//| Processa todos os ticks de uma barra                              |
//+------------------------------------------------------------------+
void COrderFlowAnalyzer::ProcessBarTicks(datetime barTime) {
   ResetBarData();
   m_lastBarTime = barTime;
   
   MqlTick ticks[];
   
   // Calcula periodo da barra em segundos
   int barSeconds = PeriodSeconds(m_timeframe);
   datetime barEnd = barTime + barSeconds;
   
   // Copia ticks do periodo
   int copied = CopyTicksRange(m_symbol, ticks, COPY_TICKS_ALL, 
                               barTime * 1000, barEnd * 1000);
   
   if(copied <= 0) {
      return;
   }
   
   // Processa cada tick
   for(int i = 0; i < copied; i++) {
      double price = (ticks[i].last > 0) ? ticks[i].last : ticks[i].bid;
      long volume = (long)ticks[i].volume;
      if(volume == 0) volume = 1;
      
      int idx = FindPriceLevel(price);
      if(idx < 0) {
         idx = AddPriceLevel(price);
      }
      
      bool isBuy = (ticks[i].flags & TICK_FLAG_BUY) != 0;
      bool isSell = (ticks[i].flags & TICK_FLAG_SELL) != 0;
      
      if(isBuy) {
         m_levels[idx].buyVolume += volume;
         m_levels[idx].buyCount++;
      }
      else if(isSell) {
         m_levels[idx].sellVolume += volume;
         m_levels[idx].sellCount++;
      }
      
      m_levels[idx].delta = m_levels[idx].buyVolume - m_levels[idx].sellVolume;
   }
}

//+------------------------------------------------------------------+
//| Obtem delta total da barra                                        |
//+------------------------------------------------------------------+
long COrderFlowAnalyzer::GetBarDelta() {
   long delta = 0;
   for(int i = 0; i < m_levelCount; i++) {
      delta += m_levels[i].delta;
   }
   return delta;
}

//+------------------------------------------------------------------+
//| Obtem delta acumulado                                             |
//+------------------------------------------------------------------+
long COrderFlowAnalyzer::GetCumulativeDelta() {
   return m_cumulativeDelta;
}

//+------------------------------------------------------------------+
//| Obtem POC (Point of Control)                                      |
//+------------------------------------------------------------------+
double COrderFlowAnalyzer::GetPOC() {
   if(m_levelCount == 0) return 0;
   
   int maxIdx = 0;
   long maxVol = m_levels[0].buyVolume + m_levels[0].sellVolume;
   
   for(int i = 1; i < m_levelCount; i++) {
      long vol = m_levels[i].buyVolume + m_levels[i].sellVolume;
      if(vol > maxVol) {
         maxVol = vol;
         maxIdx = i;
      }
   }
   
   return m_levels[maxIdx].price;
}

//+------------------------------------------------------------------+
//| Obtem VWAP                                                        |
//+------------------------------------------------------------------+
double COrderFlowAnalyzer::GetVWAP() {
   double sumPV = 0;
   long sumV = 0;
   
   for(int i = 0; i < m_levelCount; i++) {
      long vol = m_levels[i].buyVolume + m_levels[i].sellVolume;
      sumPV += m_levels[i].price * vol;
      sumV += vol;
   }
   
   if(sumV == 0) return 0;
   return sumPV / sumV;
}

//+------------------------------------------------------------------+
//| Verifica imbalance de compra                                      |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzer::HasBuyImbalance(double price) {
   int idx = FindPriceLevel(price);
   if(idx < 0) return false;
   
   if(m_levels[idx].sellVolume == 0) return m_levels[idx].buyVolume > 0;
   return (double)m_levels[idx].buyVolume / m_levels[idx].sellVolume >= m_imbalanceRatio;
}

//+------------------------------------------------------------------+
//| Verifica imbalance de venda                                       |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzer::HasSellImbalance(double price) {
   int idx = FindPriceLevel(price);
   if(idx < 0) return false;
   
   if(m_levels[idx].buyVolume == 0) return m_levels[idx].sellVolume > 0;
   return (double)m_levels[idx].sellVolume / m_levels[idx].buyVolume >= m_imbalanceRatio;
}

//+------------------------------------------------------------------+
//| Obtem resultado completo                                          |
//+------------------------------------------------------------------+
SOrderFlowResult COrderFlowAnalyzer::GetResult() {
   SOrderFlowResult result;
   
   result.barDelta = GetBarDelta();
   result.cumulativeDelta = m_cumulativeDelta;
   result.poc = GetPOC();
   result.vwap = GetVWAP();
   result.imbalanceUp = 0;
   result.imbalanceDown = 0;
   result.totalBuyVolume = 0;
   result.totalSellVolume = 0;
   
   // Calcula totais e encontra imbalances
   for(int i = 0; i < m_levelCount; i++) {
      result.totalBuyVolume += m_levels[i].buyVolume;
      result.totalSellVolume += m_levels[i].sellVolume;
      
      if(HasBuyImbalance(m_levels[i].price)) {
         if(result.imbalanceUp == 0 || m_levels[i].price > result.imbalanceUp) {
            result.imbalanceUp = m_levels[i].price;
         }
      }
      
      if(HasSellImbalance(m_levels[i].price)) {
         if(result.imbalanceDown == 0 || m_levels[i].price < result.imbalanceDown) {
            result.imbalanceDown = m_levels[i].price;
         }
      }
   }
   
   long totalVol = result.totalBuyVolume + result.totalSellVolume;
   result.deltaPercent = (totalVol > 0) ? (double)result.barDelta / totalVol * 100 : 0;
   result.isBuyDominant = result.barDelta > 0;
   result.hasStrongImbalance = (result.imbalanceUp > 0 || result.imbalanceDown > 0);
   
   return result;
}

//+------------------------------------------------------------------+
//| Obtem sinal de trading                                            |
//| Retorna: 1 = Buy, -1 = Sell, 0 = Neutro                          |
//+------------------------------------------------------------------+
int COrderFlowAnalyzer::GetSignal(int deltaThreshold = 500, double imbalanceRatio = 3.0) {
   SOrderFlowResult result = GetResult();
   
   // Sinal forte de compra
   if(result.barDelta > deltaThreshold && result.hasStrongImbalance && result.imbalanceUp > 0) {
      return 1;
   }
   
   // Sinal forte de venda
   if(result.barDelta < -deltaThreshold && result.hasStrongImbalance && result.imbalanceDown > 0) {
      return -1;
   }
   
   // Sinal moderado baseado em delta
   if(result.deltaPercent > 30) return 1;
   if(result.deltaPercent < -30) return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Detecta divergencia de delta                                      |
//| priceDirection: 1 = subindo, -1 = caindo                         |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzer::IsDeltaDivergence(double priceDirection) {
   long delta = GetBarDelta();
   
   // Preco subindo mas delta negativo = divergencia bearish
   if(priceDirection > 0 && delta < -100) return true;
   
   // Preco caindo mas delta positivo = divergencia bullish
   if(priceDirection < 0 && delta > 100) return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Detecta absorcao (stopping volume)                                |
//+------------------------------------------------------------------+
bool COrderFlowAnalyzer::IsAbsorption(int volumeThreshold = 1000) {
   SOrderFlowResult result = GetResult();
   long totalVol = result.totalBuyVolume + result.totalSellVolume;
   
   // Alto volume mas delta proximo de zero = absorcao
   if(totalVol > volumeThreshold && MathAbs(result.deltaPercent) < 10) {
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Imprime niveis para debug                                         |
//+------------------------------------------------------------------+
void COrderFlowAnalyzer::PrintLevels() {
   Print("=== Order Flow Levels ===");
   Print("Total levels: ", m_levelCount);
   
   for(int i = 0; i < m_levelCount; i++) {
      if(m_levels[i].buyVolume > 0 || m_levels[i].sellVolume > 0) {
         string imb = "";
         if(HasBuyImbalance(m_levels[i].price)) imb = " [BUY IMB]";
         if(HasSellImbalance(m_levels[i].price)) imb = " [SELL IMB]";
         
         Print(StringFormat("%.2f | Buy: %d | Sell: %d | Delta: %d%s",
               m_levels[i].price,
               m_levels[i].buyVolume,
               m_levels[i].sellVolume,
               m_levels[i].delta,
               imb));
      }
   }
   
   Print("Bar Delta: ", GetBarDelta());
   Print("Cumulative Delta: ", m_cumulativeDelta);
   Print("POC: ", GetPOC());
   Print("VWAP: ", GetVWAP());
   Print("========================");
}
//+------------------------------------------------------------------+

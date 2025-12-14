//+------------------------------------------------------------------+
//|                                           OrderFlowExample.mqh   |
//|                         EA_SCALPER_XAUUSD - Singularity Edition  |
//|                                                                  |
//| EXEMPLO: Como usar o OrderFlowAnalyzer no seu EA                |
//+------------------------------------------------------------------+

#include "OrderFlowAnalyzer.mqh"

// Instancia global
COrderFlowAnalyzer g_orderFlow;

//+------------------------------------------------------------------+
//| Exemplo de OnInit                                                 |
//+------------------------------------------------------------------+
int OnInit_Example() {
   // Inicializa o Order Flow Analyzer
   if(!g_orderFlow.Initialize(_Symbol, PERIOD_M15, 100, 3.0)) {
      Print("Erro ao inicializar Order Flow Analyzer!");
      return INIT_FAILED;
   }
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Exemplo de OnTick - Processamento em tempo real                   |
//+------------------------------------------------------------------+
void OnTick_Example() {
   // Obtem ultimo tick
   MqlTick lastTick;
   if(!SymbolInfoTick(_Symbol, lastTick)) return;
   
   // Processa o tick
   g_orderFlow.ProcessTick(lastTick);
   
   // Obtem resultado
   SOrderFlowResult result = g_orderFlow.GetResult();
   
   // === LOGICA DE TRADING ===
   
   // 1. Sinal baseado em Delta
   if(result.barDelta > 500 && result.isBuyDominant) {
      // Forte pressao compradora - considerar BUY
      Print("SINAL: Delta positivo forte = ", result.barDelta);
   }
   else if(result.barDelta < -500 && !result.isBuyDominant) {
      // Forte pressao vendedora - considerar SELL
      Print("SINAL: Delta negativo forte = ", result.barDelta);
   }
   
   // 2. Sinal baseado em Imbalance
   if(result.hasStrongImbalance) {
      if(result.imbalanceUp > 0) {
         Print("IMBALANCE DE COMPRA em: ", result.imbalanceUp);
         // Usar como suporte / zona de interesse
      }
      if(result.imbalanceDown > 0) {
         Print("IMBALANCE DE VENDA em: ", result.imbalanceDown);
         // Usar como resistencia / zona de interesse
      }
   }
   
   // 3. Deteccao de Divergencia
   double priceChange = iClose(_Symbol, PERIOD_M15, 0) - iClose(_Symbol, PERIOD_M15, 1);
   double priceDir = (priceChange > 0) ? 1 : -1;
   
   if(g_orderFlow.IsDeltaDivergence(priceDir)) {
      Print("DIVERGENCIA DETECTADA!");
      // Preco subindo mas vendedores dominando (ou vice-versa)
      // Possivel reversao
   }
   
   // 4. Deteccao de Absorcao
   if(g_orderFlow.IsAbsorption(1000)) {
      Print("ABSORCAO DETECTADA em POC: ", result.poc);
      // Alto volume, delta neutro = grandes players absorvendo
   }
   
   // 5. Usar POC e VWAP como niveis
   double currentPrice = lastTick.bid;
   
   if(currentPrice > result.vwap && result.barDelta > 0) {
      // Preco acima do VWAP com delta positivo = tendencia de alta
   }
   
   if(MathAbs(currentPrice - result.poc) < 50 * _Point) {
      // Preco proximo do POC = possivel reacao
   }
}

//+------------------------------------------------------------------+
//| Exemplo de uso com analise de barra anterior                      |
//+------------------------------------------------------------------+
void AnalyzePreviousBar() {
   datetime barTime = iTime(_Symbol, PERIOD_M15, 1); // Barra anterior
   
   // Processa todos os ticks da barra
   g_orderFlow.ProcessBarTicks(barTime);
   
   // Obtem resultado
   SOrderFlowResult result = g_orderFlow.GetResult();
   
   // Imprime analise
   Print("=== Analise da Barra Anterior ===");
   Print("Delta: ", result.barDelta);
   Print("Delta %: ", DoubleToString(result.deltaPercent, 1), "%");
   Print("Buy Volume: ", result.totalBuyVolume);
   Print("Sell Volume: ", result.totalSellVolume);
   Print("POC: ", result.poc);
   Print("VWAP: ", result.vwap);
   Print("Dominante: ", result.isBuyDominant ? "COMPRADORES" : "VENDEDORES");
   
   // Debug completo
   g_orderFlow.PrintLevels();
}

//+------------------------------------------------------------------+
//| Funcao para integrar com confluencia SMC                          |
//+------------------------------------------------------------------+
int GetOrderFlowConfluence(double obLevel, bool isBullishOB) {
   SOrderFlowResult result = g_orderFlow.GetResult();
   int score = 0;
   
   // Se OB bullish, queremos ver delta positivo
   if(isBullishOB) {
      if(result.barDelta > 300) score += 10;
      if(result.barDelta > 500) score += 5;
      if(result.imbalanceUp > 0 && result.imbalanceUp <= obLevel) score += 15;
      if(result.deltaPercent > 20) score += 5;
   }
   else {
      // OB bearish, queremos delta negativo
      if(result.barDelta < -300) score += 10;
      if(result.barDelta < -500) score += 5;
      if(result.imbalanceDown > 0 && result.imbalanceDown >= obLevel) score += 15;
      if(result.deltaPercent < -20) score += 5;
   }
   
   return score;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                          |
//+------------------------------------------------------------------+
void OnDeinit_Example(const int reason) {
   g_orderFlow.Deinitialize();
}
//+------------------------------------------------------------------+

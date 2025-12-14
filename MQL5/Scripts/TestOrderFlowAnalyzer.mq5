//+------------------------------------------------------------------+
//|                                       TestOrderFlowAnalyzer.mq5  |
//|                         EA_SCALPER_XAUUSD - Singularity Edition  |
//|                                                                  |
//| Script de teste para validar o Order Flow Analyzer V2            |
//| Executa diagnosticos e verifica qualidade dos dados              |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property script_show_inputs

#include <EA_SCALPER\Analysis\OrderFlowAnalyzer_v2.mqh>

input int      InpBarsToTest = 10;        // Barras para testar
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_M15; // Timeframe

//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart() {
   Print("========================================================");
   Print("   ORDER FLOW ANALYZER V2 - TESTE DE VALIDACAO");
   Print("========================================================");
   Print("");
   
   COrderFlowAnalyzerV2 analyzer;
   
   // Inicializa
   Print("1. INICIALIZANDO...");
   if(!analyzer.Initialize(_Symbol, InpTimeframe, 200, 3.0, 0.70, METHOD_AUTO)) {
      Print("ERRO: Falha ao inicializar!");
      return;
   }
   Print("   OK - Inicializado com sucesso");
   Print("");
   
   // Teste de qualidade dos dados
   Print("2. TESTANDO QUALIDADE DOS DADOS...");
   TestDataQuality(analyzer);
   Print("");
   
   // Teste de barras historicas
   Print("3. TESTANDO BARRAS HISTORICAS...");
   TestHistoricalBars(analyzer, InpBarsToTest);
   Print("");
   
   // Teste de tempo real
   Print("4. TESTANDO TICKS EM TEMPO REAL...");
   TestRealTimeTicks(analyzer);
   Print("");
   
   // Diagnostico completo
   Print("5. DIAGNOSTICO COMPLETO...");
   analyzer.PrintDiagnostics();
   Print("");
   
   // Resumo
   PrintSummary(analyzer);
   
   analyzer.Deinitialize();
}

//+------------------------------------------------------------------+
//| Testa qualidade dos dados de tick                                 |
//+------------------------------------------------------------------+
void TestDataQuality(COrderFlowAnalyzerV2 &analyzer) {
   MqlTick ticks[];
   int copied = CopyTicks(_Symbol, ticks, COPY_TICKS_ALL, 0, 1000);
   
   if(copied <= 0) {
      Print("   ERRO: Nao foi possivel copiar ticks!");
      return;
   }
   
   int withBuyFlag = 0;
   int withSellFlag = 0;
   int withBothFlags = 0;
   int withNoFlags = 0;
   int withVolume = 0;
   int withLast = 0;
   
   for(int i = 0; i < copied; i++) {
      bool hasBuy = (ticks[i].flags & TICK_FLAG_BUY) != 0;
      bool hasSell = (ticks[i].flags & TICK_FLAG_SELL) != 0;
      
      if(hasBuy && hasSell) withBothFlags++;
      else if(hasBuy) withBuyFlag++;
      else if(hasSell) withSellFlag++;
      else withNoFlags++;
      
      if(ticks[i].volume > 0) withVolume++;
      if(ticks[i].last > 0) withLast++;
   }
   
   Print("   Ticks analisados: ", copied);
   Print("   Com TICK_FLAG_BUY: ", withBuyFlag, " (", DoubleToString((double)withBuyFlag/copied*100, 1), "%)");
   Print("   Com TICK_FLAG_SELL: ", withSellFlag, " (", DoubleToString((double)withSellFlag/copied*100, 1), "%)");
   Print("   Com AMBOS flags: ", withBothFlags, " (", DoubleToString((double)withBothFlags/copied*100, 1), "%) - INCONSISTENTES!");
   Print("   Sem flags: ", withNoFlags, " (", DoubleToString((double)withNoFlags/copied*100, 1), "%)");
   Print("   Com volume: ", withVolume, " (", DoubleToString((double)withVolume/copied*100, 1), "%)");
   Print("   Com last price: ", withLast, " (", DoubleToString((double)withLast/copied*100, 1), "%)");
   
   double flagPercent = (double)(withBuyFlag + withSellFlag) / copied * 100;
   
   if(flagPercent >= 80) {
      Print("   RESULTADO: EXCELENTE - Flags disponiveis!");
   }
   else if(flagPercent >= 50) {
      Print("   RESULTADO: MODERADO - Flags parcialmente disponiveis");
   }
   else if(flagPercent > 0) {
      Print("   RESULTADO: FRACO - Poucos flags disponiveis");
   }
   else {
      Print("   RESULTADO: SEM FLAGS - Usando metodo alternativo (comparacao de preco)");
   }
}

//+------------------------------------------------------------------+
//| Testa barras historicas                                           |
//+------------------------------------------------------------------+
void TestHistoricalBars(COrderFlowAnalyzerV2 &analyzer, int bars) {
   Print("   Processando ", bars, " barras...");
   
   for(int i = 0; i < bars; i++) {
      if(!analyzer.ProcessBarTicks(i)) {
         Print("   Barra ", i, ": ERRO ao processar");
         continue;
      }
      
      SOrderFlowResultV2 result = analyzer.GetResult();
      SValueArea va = result.valueArea;
      
      datetime barTime = iTime(_Symbol, InpTimeframe, i);
      
      Print(StringFormat("   Barra %d [%s]: Delta=%+d | POC=%.2f | VA=%.2f-%.2f | Ticks=%d | Qual=%s",
            i,
            TimeToString(barTime, TIME_DATE|TIME_MINUTES),
            result.barDelta,
            va.poc,
            va.valow,
            va.vahigh,
            result.totalTicks,
            EnumToString(result.dataQuality)));
   }
}

//+------------------------------------------------------------------+
//| Testa ticks em tempo real                                         |
//+------------------------------------------------------------------+
void TestRealTimeTicks(COrderFlowAnalyzerV2 &analyzer) {
   Print("   Processando 100 ticks recentes...");
   
   MqlTick ticks[];
   int copied = CopyTicks(_Symbol, ticks, COPY_TICKS_ALL, 0, 100);
   
   if(copied <= 0) {
      Print("   ERRO: Nao foi possivel copiar ticks!");
      return;
   }
   
   // Reseta para processar do zero
   analyzer.ProcessBarTicks(0);
   
   // Processa cada tick
   for(int i = copied - 1; i >= 0; i--) {
      analyzer.ProcessTickDirect(ticks[i]);
   }
   
   SOrderFlowResultV2 result = analyzer.GetResult();
   
   Print("   Ticks processados: ", result.totalTicks);
   Print("   Delta: ", result.barDelta);
   Print("   Buy Volume: ", result.totalBuyVolume);
   Print("   Sell Volume: ", result.totalSellVolume);
   Print("   Delta %: ", DoubleToString(result.deltaPercent, 1), "%");
   Print("   Qualidade: ", EnumToString(result.dataQuality));
   
   // Testa sinais
   int signal = analyzer.GetSignal(100);
   Print("   Sinal: ", signal == 1 ? "BUY" : (signal == -1 ? "SELL" : "NEUTRO"));
   Print("   Divergencia: ", analyzer.IsDeltaDivergence() ? "SIM" : "NAO");
   Print("   Absorcao: ", analyzer.IsAbsorption(500) ? "SIM" : "NAO");
}

//+------------------------------------------------------------------+
//| Imprime resumo final                                              |
//+------------------------------------------------------------------+
void PrintSummary(COrderFlowAnalyzerV2 &analyzer) {
   Print("========================================================");
   Print("                    RESUMO FINAL");
   Print("========================================================");
   
   ENUM_DATA_QUALITY quality = analyzer.GetDataQuality();
   bool reliable = analyzer.IsDataReliable();
   
   Print("");
   Print("Simbolo: ", _Symbol);
   Print("Timeframe: ", EnumToString(InpTimeframe));
   Print("Qualidade dos dados: ", EnumToString(quality));
   Print("Dados confiaveis: ", reliable ? "SIM" : "NAO");
   Print("");
   
   if(reliable) {
      Print("CONCLUSAO: Order Flow Analyzer esta PRONTO para uso!");
      Print("           Os dados de tick tem qualidade suficiente.");
   }
   else {
      Print("ATENCAO: Qualidade dos dados e LIMITADA!");
      Print("         O analyzer usara metodo alternativo (comparacao de preco).");
      Print("         Resultados serao aproximados, nao exatos.");
      Print("");
      Print("RECOMENDACOES:");
      Print("  1. Use com cautela em decisoes de trading");
      Print("  2. Combine com outros indicadores para confirmacao");
      Print("  3. Considere usar broker com melhor feed de dados");
   }
   
   Print("");
   Print("========================================================");
}
//+------------------------------------------------------------------+

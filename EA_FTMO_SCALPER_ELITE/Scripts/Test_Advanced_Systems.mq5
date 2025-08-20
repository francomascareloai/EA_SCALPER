//+------------------------------------------------------------------+
//|                                        Test_Advanced_Systems.mq5 |
//|                                  EA FTMO SCALPER ELITE v2.0      |
//|                                        Teste dos Sistemas Avançados |
//+------------------------------------------------------------------+
#property copyright "EA FTMO SCALPER ELITE v2.0"
#property link      "https://github.com/your-repo"
#property version   "2.00"
#property script_show_inputs

// Includes dos sistemas avançados
#include "../Include/CAdvancedSignalEngine.mqh"
#include "../Include/CDynamicLevels.mqh"
#include "../Include/CSignalConfluence.mqh"

// Parâmetros de entrada
input string    TestSymbol = "XAUUSD";           // Símbolo para teste
input int       TestBars = 100;                  // Número de barras para teste
input bool      DetailedLog = true;              // Log detalhado
input bool      TestPerformance = true;          // Teste de performance

// Objetos dos sistemas
CAdvancedSignalEngine* advancedEngine;
CDynamicLevels* dynamicLevels;
CSignalConfluence* signalConfluence;

// Estruturas para estatísticas
struct STestStats
{
   int totalSignals;
   int buySignals;
   int sellSignals;
   int validSignals;
   double avgScore;
   double maxScore;
   double minScore;
   double avgConfidence;
   ulong totalTime;
   double avgExecutionTime;
};

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== TESTE DOS SISTEMAS AVANÇADOS - FASE 1 ===");
   Print("Símbolo: ", TestSymbol);
   Print("Barras para teste: ", TestBars);
   Print("Timestamp: ", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
   Print("================================================");
   
   // Inicializar sistemas
   if(!InitializeSystems())
   {
      Print("ERRO: Falha na inicialização dos sistemas");
      return;
   }
   
   // Executar testes
   STestStats stats = RunTests();
   
   // Exibir resultados
   DisplayResults(stats);
   
   // Cleanup
   CleanupSystems();
   
   Print("=== TESTE CONCLUÍDO ===");
}

//+------------------------------------------------------------------+
//| Inicializar sistemas para teste                                 |
//+------------------------------------------------------------------+
bool InitializeSystems()
{
   Print("Inicializando sistemas...");
   
   // Criar instâncias
   advancedEngine = new CAdvancedSignalEngine();
   dynamicLevels = new CDynamicLevels();
   signalConfluence = new CSignalConfluence();
   
   if(advancedEngine == NULL || dynamicLevels == NULL || signalConfluence == NULL)
   {
      Print("ERRO: Falha ao criar instâncias dos objetos");
      return false;
   }
   
   // Inicializar CAdvancedSignalEngine
   if(!advancedEngine.Initialize(TestSymbol))
   {
      Print("ERRO: Falha ao inicializar CAdvancedSignalEngine");
      return false;
   }
   
   // Inicializar CDynamicLevels
   if(!dynamicLevels.Initialize(TestSymbol))
   {
      Print("ERRO: Falha ao inicializar CDynamicLevels");
      return false;
   }
   
   // Inicializar CSignalConfluence
   if(!signalConfluence.Initialize(TestSymbol, advancedEngine, dynamicLevels))
   {
      Print("ERRO: Falha ao inicializar CSignalConfluence");
      return false;
   }
   
   Print("Sistemas inicializados com sucesso!");
   return true;
}

//+------------------------------------------------------------------+
//| Executar testes dos sistemas                                    |
//+------------------------------------------------------------------+
STestStats RunTests()
{
   STestStats stats;
   ZeroMemory(stats);
   
   Print("Iniciando testes...");
   
   ulong startTime = GetMicrosecondCount();
   
   // Loop através das barras históricas
   for(int i = TestBars; i >= 1; i--)
   {
      // Simular análise em barra histórica
      datetime barTime = iTime(TestSymbol, PERIOD_M15, i);
      
      if(DetailedLog && i % 20 == 0)
      {
         Print("Testando barra ", i, " - ", TimeToString(barTime, TIME_DATE|TIME_MINUTES));
      }
      
      // Medir tempo de execução
      ulong execStart = GetMicrosecondCount();
      
      // Analisar confluência
      SConfluenceResult result = signalConfluence.AnalyzeConfluence();
      
      ulong execTime = GetMicrosecondCount() - execStart;
      stats.totalTime += execTime;
      
      // Coletar estatísticas
      if(result.isValid)
      {
         stats.totalSignals++;
         
         if(result.direction > 0)
            stats.buySignals++;
         else if(result.direction < 0)
            stats.sellSignals++;
         
         if(result.finalScore >= 60.0)
            stats.validSignals++;
         
         // Estatísticas de score
         stats.avgScore += result.finalScore;
         stats.avgConfidence += result.confidence;
         
         if(result.finalScore > stats.maxScore)
            stats.maxScore = result.finalScore;
         
         if(stats.minScore == 0.0 || result.finalScore < stats.minScore)
            stats.minScore = result.finalScore;
         
         // Log detalhado para sinais válidos
         if(DetailedLog && result.finalScore >= 60.0)
         {
            Print("SINAL VÁLIDO - Barra ", i, ": ", 
                  result.direction > 0 ? "BUY" : "SELL", 
                  " | Score: ", DoubleToString(result.finalScore, 1),
                  " | Confiança: ", DoubleToString(result.confidence, 1), "%",
                  " | Tempo: ", execTime, "μs");
         }
      }
   }
   
   ulong totalTestTime = GetMicrosecondCount() - startTime;
   
   // Calcular médias
   if(stats.totalSignals > 0)
   {
      stats.avgScore /= stats.totalSignals;
      stats.avgConfidence /= stats.totalSignals;
   }
   
   if(TestBars > 0)
   {
      stats.avgExecutionTime = (double)stats.totalTime / TestBars;
   }
   
   Print("Testes concluídos em ", totalTestTime, " microssegundos");
   
   return stats;
}

//+------------------------------------------------------------------+
//| Exibir resultados dos testes                                    |
//+------------------------------------------------------------------+
void DisplayResults(STestStats &stats)
{
   Print("\n=== RESULTADOS DOS TESTES ===");
   Print("Barras testadas: ", TestBars);
   Print("Total de sinais: ", stats.totalSignals);
   Print("Sinais de compra: ", stats.buySignals);
   Print("Sinais de venda: ", stats.sellSignals);
   Print("Sinais válidos (Score ≥ 60): ", stats.validSignals);
   
   if(stats.totalSignals > 0)
   {
      double validPercentage = (double)stats.validSignals / stats.totalSignals * 100.0;
      Print("Taxa de sinais válidos: ", DoubleToString(validPercentage, 1), "%");
      
      Print("\n=== ESTATÍSTICAS DE SCORE ===");
      Print("Score médio: ", DoubleToString(stats.avgScore, 1));
      Print("Score máximo: ", DoubleToString(stats.maxScore, 1));
      Print("Score mínimo: ", DoubleToString(stats.minScore, 1));
      Print("Confiança média: ", DoubleToString(stats.avgConfidence, 1), "%");
   }
   
   if(TestPerformance)
   {
      Print("\n=== PERFORMANCE ===");
      Print("Tempo total de execução: ", stats.totalTime, " μs");
      Print("Tempo médio por análise: ", DoubleToString(stats.avgExecutionTime, 1), " μs");
      
      // Avaliar performance
      if(stats.avgExecutionTime < 1000.0)
         Print("Performance: EXCELENTE (< 1ms)");
      else if(stats.avgExecutionTime < 5000.0)
         Print("Performance: BOA (< 5ms)");
      else if(stats.avgExecutionTime < 10000.0)
         Print("Performance: ACEITÁVEL (< 10ms)");
      else
         Print("Performance: PRECISA OTIMIZAÇÃO (> 10ms)");
   }
   
   // Avaliação geral
   Print("\n=== AVALIAÇÃO GERAL ===");
   
   if(stats.totalSignals == 0)
   {
      Print("STATUS: FALHA - Nenhum sinal detectado");
   }
   else if(stats.validSignals == 0)
   {
      Print("STATUS: ATENÇÃO - Nenhum sinal válido (Score < 60)");
   }
   else
   {
      double validRate = (double)stats.validSignals / stats.totalSignals * 100.0;
      
      if(validRate >= 20.0 && stats.avgScore >= 65.0)
         Print("STATUS: EXCELENTE - Sistema funcionando perfeitamente");
      else if(validRate >= 10.0 && stats.avgScore >= 60.0)
         Print("STATUS: BOM - Sistema funcionando adequadamente");
      else
         Print("STATUS: PRECISA AJUSTES - Baixa qualidade de sinais");
   }
}

//+------------------------------------------------------------------+
//| Limpar sistemas após teste                                      |
//+------------------------------------------------------------------+
void CleanupSystems()
{
   if(advancedEngine != NULL)
   {
      delete advancedEngine;
      advancedEngine = NULL;
   }
   
   if(dynamicLevels != NULL)
   {
      delete dynamicLevels;
      dynamicLevels = NULL;
   }
   
   if(signalConfluence != NULL)
   {
      delete signalConfluence;
      signalConfluence = NULL;
   }
   
   Print("Sistemas limpos com sucesso");
}
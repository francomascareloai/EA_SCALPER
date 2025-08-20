//+------------------------------------------------------------------+
//|                                              Compile_Test.mq5   |
//|                                  Teste de Compilação dos Includes |
//+------------------------------------------------------------------+
#property copyright "EA FTMO SCALPER ELITE v2.0"
#property version   "2.00"
#property script_show_inputs

// Teste dos includes dos sistemas avançados
#include "../Include/CAdvancedSignalEngine.mqh"
#include "../Include/CDynamicLevels.mqh"
#include "../Include/CSignalConfluence.mqh"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== TESTE DE COMPILAÇÃO ===");
   
   // Testar criação de objetos
   CAdvancedSignalEngine* engine = new CAdvancedSignalEngine();
   CDynamicLevels* levels = new CDynamicLevels();
   CSignalConfluence* confluence = new CSignalConfluence();
   
   if(engine != NULL && levels != NULL && confluence != NULL)
   {
      Print("✓ Objetos criados com sucesso");
      
      // Testar inicialização
      bool engineInit = engine.Initialize("XAUUSD");
      bool levelsInit = levels.Initialize("XAUUSD");
      bool confluenceInit = confluence.Initialize("XAUUSD", engine, levels);
      
      if(engineInit && levelsInit && confluenceInit)
      {
         Print("✓ Sistemas inicializados com sucesso");
         Print("✓ COMPILAÇÃO E INICIALIZAÇÃO: SUCESSO");
      }
      else
      {
         Print("✗ Erro na inicialização dos sistemas");
      }
      
      // Cleanup
      delete engine;
      delete levels;
      delete confluence;
   }
   else
   {
      Print("✗ Erro na criação dos objetos");
   }
   
   Print("=== TESTE CONCLUÍDO ===");
}
//+------------------------------------------------------------------+
//| TradingEngine.mqh - Core Trading Engine                         |
//| TradeDev_Master Elite Trading System                            |
//| Copyright 2024, Advanced Trading Solutions                      |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property version   "1.00"
#property strict

#include "RiskManager.mqh"
#include "DataProvider.mqh"
#include "Analytics.mqh"

//+------------------------------------------------------------------+
//| Interface para estratégias de trading                           |
//+------------------------------------------------------------------+
interface IStrategy
{
   bool Initialize(void);
   bool Analyze(void);
   bool Execute(void);
   void Cleanup(void);
   string GetStrategyName(void);
   double GetExpectedReturn(void);
   double GetRiskLevel(void);
};

//+------------------------------------------------------------------+
//| Enumeração de estados do engine                                 |
//+------------------------------------------------------------------+
enum ENGINE_STATE
{
   ENGINE_STOPPED,
   ENGINE_INITIALIZING,
   ENGINE_RUNNING,
   ENGINE_PAUSED,
   ENGINE_ERROR
};

//+------------------------------------------------------------------+
//| Estrutura de configuração do engine                             |
//+------------------------------------------------------------------+
struct EngineConfig
{
   bool enableRiskManagement;
   bool enableAnalytics;
   bool enableLogging;
   double maxRiskPerTrade;
   double maxDailyDrawdown;
   int maxConcurrentTrades;
   string logLevel;
};

//+------------------------------------------------------------------+
//| Classe principal do Trading Engine                              |
//+------------------------------------------------------------------+
class CTradingEngine
{
private:
   ENGINE_STATE      m_state;
   EngineConfig      m_config;
   CRiskManager*     m_riskManager;
   CDataProvider*    m_dataProvider;
   CAnalytics*       m_analytics;
   IStrategy*        m_strategies[];
   datetime          m_lastTick;
   int               m_activeTrades;
   double            m_dailyPnL;
   
   // Métodos privados
   bool ValidateConfig(void);
   bool InitializeComponents(void);
   void LogMessage(string message, int level = 0);
   bool CheckMarketConditions(void);
   
public:
   // Construtor e destrutor
   CTradingEngine(void);
   ~CTradingEngine(void);
   
   // Métodos principais
   bool Initialize(EngineConfig &config);
   bool Start(void);
   bool Stop(void);
   bool Pause(void);
   bool Resume(void);
   
   // Gestão de estratégias
   bool AddStrategy(IStrategy* strategy);
   bool RemoveStrategy(string strategyName);
   int GetStrategyCount(void);
   
   // Execução principal
   void OnTick(void);
   void OnTimer(void);
   
   // Getters
   ENGINE_STATE GetState(void) { return m_state; }
   double GetDailyPnL(void) { return m_dailyPnL; }
   int GetActiveTrades(void) { return m_activeTrades; }
   
   // Análise e relatórios
   bool GenerateReport(string &report);
   double GetPerformanceMetric(string metricName);
};

//+------------------------------------------------------------------+
//| Construtor                                                       |
//+------------------------------------------------------------------+
CTradingEngine::CTradingEngine(void)
{
   m_state = ENGINE_STOPPED;
   m_riskManager = NULL;
   m_dataProvider = NULL;
   m_analytics = NULL;
   m_lastTick = 0;
   m_activeTrades = 0;
   m_dailyPnL = 0.0;
   
   // Configuração padrão
   m_config.enableRiskManagement = true;
   m_config.enableAnalytics = true;
   m_config.enableLogging = true;
   m_config.maxRiskPerTrade = 0.01; // 1%
   m_config.maxDailyDrawdown = 0.05; // 5%
   m_config.maxConcurrentTrades = 5;
   m_config.logLevel = "INFO";
}

//+------------------------------------------------------------------+
//| Destrutor                                                        |
//+------------------------------------------------------------------+
CTradingEngine::~CTradingEngine(void)
{
   Stop();
   
   if(m_riskManager != NULL)
   {
      delete m_riskManager;
      m_riskManager = NULL;
   }
   
   if(m_dataProvider != NULL)
   {
      delete m_dataProvider;
      m_dataProvider = NULL;
   }
   
   if(m_analytics != NULL)
   {
      delete m_analytics;
      m_analytics = NULL;
   }
   
   ArrayFree(m_strategies);
}

//+------------------------------------------------------------------+
//| Inicialização do engine                                         |
//+------------------------------------------------------------------+
bool CTradingEngine::Initialize(EngineConfig &config)
{
   if(m_state != ENGINE_STOPPED)
   {
      LogMessage("Engine must be stopped before initialization", 2);
      return false;
   }
   
   m_state = ENGINE_INITIALIZING;
   m_config = config;
   
   if(!ValidateConfig())
   {
      m_state = ENGINE_ERROR;
      return false;
   }
   
   if(!InitializeComponents())
   {
      m_state = ENGINE_ERROR;
      return false;
   }
   
   m_state = ENGINE_STOPPED;
   LogMessage("Trading Engine initialized successfully");
   return true;
}

//+------------------------------------------------------------------+
//| Validação da configuração                                       |
//+------------------------------------------------------------------+
bool CTradingEngine::ValidateConfig(void)
{
   if(m_config.maxRiskPerTrade <= 0 || m_config.maxRiskPerTrade > 0.1)
   {
      LogMessage("Invalid maxRiskPerTrade value", 2);
      return false;
   }
   
   if(m_config.maxDailyDrawdown <= 0 || m_config.maxDailyDrawdown > 0.2)
   {
      LogMessage("Invalid maxDailyDrawdown value", 2);
      return false;
   }
   
   if(m_config.maxConcurrentTrades <= 0 || m_config.maxConcurrentTrades > 20)
   {
      LogMessage("Invalid maxConcurrentTrades value", 2);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Inicialização dos componentes                                   |
//+------------------------------------------------------------------+
bool CTradingEngine::InitializeComponents(void)
{
   // Inicializar Risk Manager
   if(m_config.enableRiskManagement)
   {
      m_riskManager = new CRiskManager();
      if(!m_riskManager.Initialize(m_config.maxRiskPerTrade, m_config.maxDailyDrawdown))
      {
         LogMessage("Failed to initialize Risk Manager", 2);
         return false;
      }
   }
   
   // Inicializar Data Provider
   m_dataProvider = new CDataProvider();
   if(!m_dataProvider.Initialize())
   {
      LogMessage("Failed to initialize Data Provider", 2);
      return false;
   }
   
   // Inicializar Analytics
   if(m_config.enableAnalytics)
   {
      m_analytics = new CAnalytics();
      if(!m_analytics.Initialize())
      {
         LogMessage("Failed to initialize Analytics", 2);
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Iniciar o engine                                                |
//+------------------------------------------------------------------+
bool CTradingEngine::Start(void)
{
   if(m_state != ENGINE_STOPPED)
   {
      LogMessage("Engine is not in stopped state", 1);
      return false;
   }
   
   if(!CheckMarketConditions())
   {
      LogMessage("Market conditions not suitable for trading", 1);
      return false;
   }
   
   m_state = ENGINE_RUNNING;
   m_lastTick = TimeCurrent();
   
   LogMessage("Trading Engine started successfully");
   return true;
}

//+------------------------------------------------------------------+
//| Parar o engine                                                  |
//+------------------------------------------------------------------+
bool CTradingEngine::Stop(void)
{
   if(m_state == ENGINE_STOPPED)
      return true;
   
   m_state = ENGINE_STOPPED;
   
   // Cleanup de todas as estratégias
   for(int i = 0; i < ArraySize(m_strategies); i++)
   {
      if(m_strategies[i] != NULL)
         m_strategies[i].Cleanup();
   }
   
   LogMessage("Trading Engine stopped");
   return true;
}

//+------------------------------------------------------------------+
//| Adicionar estratégia                                            |
//+------------------------------------------------------------------+
bool CTradingEngine::AddStrategy(IStrategy* strategy)
{
   if(strategy == NULL)
      return false;
   
   int size = ArraySize(m_strategies);
   ArrayResize(m_strategies, size + 1);
   m_strategies[size] = strategy;
   
   if(!strategy.Initialize())
   {
      ArrayResize(m_strategies, size);
      LogMessage("Failed to initialize strategy: " + strategy.GetStrategyName(), 2);
      return false;
   }
   
   LogMessage("Strategy added: " + strategy.GetStrategyName());
   return true;
}

//+------------------------------------------------------------------+
//| Processamento principal no tick                                 |
//+------------------------------------------------------------------+
void CTradingEngine::OnTick(void)
{
   if(m_state != ENGINE_RUNNING)
      return;
   
   m_lastTick = TimeCurrent();
   
   // Atualizar dados
   if(m_dataProvider != NULL)
      m_dataProvider.UpdateData();
   
   // Verificar condições de risco
   if(m_riskManager != NULL && !m_riskManager.CheckRiskLimits())
   {
      LogMessage("Risk limits exceeded, pausing trading", 1);
      Pause();
      return;
   }
   
   // Executar estratégias
   for(int i = 0; i < ArraySize(m_strategies); i++)
   {
      if(m_strategies[i] != NULL)
      {
         if(m_strategies[i].Analyze())
         {
            m_strategies[i].Execute();
         }
      }
   }
   
   // Atualizar analytics
   if(m_analytics != NULL)
      m_analytics.UpdateMetrics();
}

//+------------------------------------------------------------------+
//| Verificar condições de mercado                                  |
//+------------------------------------------------------------------+
bool CTradingEngine::CheckMarketConditions(void)
{
   // Verificar se o mercado está aberto
   if(!SymbolInfoInteger(Symbol(), SYMBOL_TRADE_MODE))
      return false;
   
   // Verificar spread
   double spread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * SymbolInfoDouble(Symbol(), SYMBOL_POINT);
   if(spread > 50 * SymbolInfoDouble(Symbol(), SYMBOL_POINT)) // Spread muito alto
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Log de mensagens                                                |
//+------------------------------------------------------------------+
void CTradingEngine::LogMessage(string message, int level = 0)
{
   if(!m_config.enableLogging)
      return;
   
   string levelStr = "INFO";
   if(level == 1) levelStr = "WARN";
   if(level == 2) levelStr = "ERROR";
   
   string logMsg = TimeToString(TimeCurrent()) + " [" + levelStr + "] " + message;
   
   Print(logMsg);
   
   // Salvar em arquivo se necessário
   if(level >= 1)
   {
      int handle = FileOpen("TradingEngine.log", FILE_WRITE|FILE_TXT|FILE_ANSI, "\t");
      if(handle != INVALID_HANDLE)
      {
         FileWrite(handle, logMsg);
         FileClose(handle);
      }
   }
}

//+------------------------------------------------------------------+
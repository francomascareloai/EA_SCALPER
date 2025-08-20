//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                                    TradeDev_Master Elite System |
//|                     Advanced Risk Management for FTMO Compliance |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property link      "https://github.com/TradeDev_Master"
#property version   "2.10"
#property description "FTMO-Compliant Risk Management System"

#include "DataStructures.mqh"
#include "Interfaces.mqh"
#include "Logger.mqh"
#include <Trade/AccountInfo.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/HistorySelect.mqh>

//+------------------------------------------------------------------+
//| Enumerações para gestão de risco                                 |
//+------------------------------------------------------------------+
enum ENUM_RISK_LEVEL
{
   RISK_VERY_LOW = 0,     // Risco muito baixo (0.1-0.5%)
   RISK_LOW = 1,          // Risco baixo (0.5-1.0%)
   RISK_MODERATE = 2,     // Risco moderado (1.0-2.0%)
   RISK_HIGH = 3,         // Risco alto (2.0-3.0%)
   RISK_VERY_HIGH = 4     // Risco muito alto (>3.0%)
};

enum ENUM_FTMO_RULE
{
   FTMO_DAILY_LOSS = 0,      // Perda diária máxima
   FTMO_MAX_DRAWDOWN = 1,    // Drawdown máximo
   FTMO_PROFIT_TARGET = 2,   // Meta de lucro
   FTMO_CONSISTENCY = 3,     // Regra de consistência
   FTMO_NEWS_TRADING = 4,    // Trading em notícias
   FTMO_WEEKEND_HOLDING = 5, // Manter posições no fim de semana
   FTMO_HEDGING = 6,         // Hedging
   FTMO_EA_USAGE = 7         // Uso de EAs
};

enum ENUM_POSITION_SIZING
{
   SIZING_FIXED = 0,         // Lote fixo
   SIZING_PERCENT_RISK = 1,  // Percentual de risco
   SIZING_KELLY = 2,         // Critério de Kelly
   SIZING_OPTIMAL_F = 3,     // Optimal F
   SIZING_VOLATILITY = 4     // Baseado na volatilidade
};

//+------------------------------------------------------------------+
//| Estruturas para gestão de risco                                  |
//+------------------------------------------------------------------+
struct SRiskParameters
{
   double max_risk_per_trade;        // Risco máximo por trade (%)
   double daily_loss_limit;          // Limite de perda diária (%)
   double max_drawdown_limit;        // Limite de drawdown máximo (%)
   double account_risk_limit;        // Risco total da conta (%)
   double correlation_limit;         // Limite de correlação entre trades
   int max_positions;                // Máximo de posições simultâneas
   int max_daily_trades;             // Máximo de trades por dia
   double min_risk_reward_ratio;     // Relação risco/recompensa mínima
   bool enable_martingale;           // Permitir martingale
   bool enable_hedging;              // Permitir hedging
   ENUM_POSITION_SIZING sizing_method; // Método de dimensionamento
};

struct SFTMOLimits
{
   double daily_loss_limit;          // 5% para challenge, 5% para funded
   double max_drawdown_limit;        // 10% para challenge, 5% para funded
   double profit_target;             // 8% para phase 1, 5% para phase 2
   double consistency_rule;          // Máximo 50% do lucro em um dia
   bool allow_news_trading;          // Permitir trading em notícias
   bool allow_weekend_holding;       // Permitir posições no fim de semana
   bool allow_hedging;               // Permitir hedging
   bool allow_ea_usage;              // Permitir uso de EAs
   datetime challenge_start_date;    // Data de início do challenge
   int challenge_duration_days;      // Duração do challenge em dias
};

struct SRiskMetrics
{
   double current_drawdown;          // Drawdown atual
   double max_drawdown;              // Drawdown máximo histórico
   double daily_pnl;                 // P&L diário
   double weekly_pnl;                // P&L semanal
   double monthly_pnl;               // P&L mensal
   double var_95;                    // Value at Risk 95%
   double expected_shortfall;        // Expected Shortfall
   double sharpe_ratio;              // Índice Sharpe
   double sortino_ratio;             // Índice Sortino
   double calmar_ratio;              // Índice Calmar
   double win_rate;                  // Taxa de acerto
   double profit_factor;             // Fator de lucro
   double recovery_factor;           // Fator de recuperação
   int consecutive_losses;           // Perdas consecutivas
   int consecutive_wins;             // Ganhos consecutivos
   datetime last_update;             // Última atualização
};

struct SPositionRisk
{
   ulong ticket;                     // Ticket da posição
   string symbol;                    // Símbolo
   double lot_size;                  // Tamanho do lote
   double entry_price;               // Preço de entrada
   double stop_loss;                 // Stop loss
   double take_profit;               // Take profit
   double risk_amount;               // Valor em risco
   double risk_percent;              // Percentual de risco
   double potential_profit;          // Lucro potencial
   double risk_reward_ratio;         // Relação risco/recompensa
   ENUM_POSITION_TYPE type;          // Tipo da posição
   datetime open_time;               // Hora de abertura
   bool is_hedged;                   // Se está hedgeada
   double correlation_score;         // Score de correlação
};

//+------------------------------------------------------------------+
//| Classe principal de gestão de risco                              |
//+------------------------------------------------------------------+
class CRiskManager : public IManager
{
private:
   // Parâmetros de configuração
   SRiskParameters m_risk_params;
   SFTMOLimits m_ftmo_limits;
   SRiskMetrics m_risk_metrics;
   
   // Objetos auxiliares
   CAccountInfo m_account;
   CPositionInfo m_position;
   
   // Arrays para histórico
   double m_daily_pnl_history[];
   double m_drawdown_history[];
   datetime m_trade_times[];
   
   // Variáveis de controle
   datetime m_last_calculation;
   datetime m_daily_start_time;
   double m_daily_start_balance;
   double m_peak_balance;
   bool m_is_ftmo_account;
   string m_account_type; // "challenge", "funded", "demo"
   
   // Cache de cálculos
   double m_cached_lot_size;
   datetime m_cache_time;
   int m_cache_timeout;
   
public:
   // Construtor e destrutor
   CRiskManager();
   ~CRiskManager();
   
   // Implementação da interface IManager
   virtual bool Init(void) override;
   virtual void Deinit(void) override;
   virtual bool SelfTest(void) override;
   virtual void SetConfig(const string config_string) override;
   virtual string GetConfig(void) override;
   virtual string GetStatus(void) override;
   
   // Configuração de parâmetros
   void SetRiskParameters(const SRiskParameters &params);
   void SetFTMOLimits(const SFTMOLimits &limits);
   void SetAccountType(const string account_type);
   
   // Cálculo de tamanho de posição
   double CalculateLotSize(const string symbol, const double entry_price, 
                          const double stop_loss, const double risk_percent = 0.0);
   double CalculateOptimalLotSize(const string symbol, const double win_rate, 
                                 const double avg_win, const double avg_loss);
   double CalculateVolatilityBasedLot(const string symbol, const int period = 20);
   
   // Validação de trades
   bool ValidateNewTrade(const string symbol, const ENUM_ORDER_TYPE order_type,
                        const double lot_size, const double entry_price,
                        const double stop_loss, const double take_profit);
   bool CheckFTMOCompliance(const string symbol, const double lot_size);
   bool CheckCorrelationRisk(const string symbol, const ENUM_ORDER_TYPE order_type);
   bool CheckDailyLimits(void);
   bool CheckDrawdownLimits(void);
   
   // Gestão de posições existentes
   bool ShouldClosePosition(const ulong ticket, string &reason);
   bool ShouldReducePosition(const ulong ticket, double &new_lot_size);
   void UpdatePositionRisk(const ulong ticket);
   
   // Cálculo de métricas
   void CalculateRiskMetrics(void);
   void UpdateDailyMetrics(void);
   double CalculateVaR(const double confidence_level = 0.95, const int periods = 30);
   double CalculateExpectedShortfall(const double confidence_level = 0.95);
   double CalculateMaxDrawdown(void);
   double CalculateCurrentDrawdown(void);
   
   // Análise de performance
   double GetSharpeRatio(const int periods = 30);
   double GetSortinoRatio(const int periods = 30);
   double GetCalmarRatio(const int periods = 30);
   double GetProfitFactor(void);
   double GetRecoveryFactor(void);
   
   // Getters para métricas
   SRiskMetrics GetRiskMetrics(void) { return m_risk_metrics; }
   SRiskParameters GetRiskParameters(void) { return m_risk_params; }
   SFTMOLimits GetFTMOLimits(void) { return m_ftmo_limits; }
   
   // Relatórios
   string GenerateRiskReport(void);
   string GenerateFTMOReport(void);
   bool SaveRiskReport(const string filename);
   
   // Alertas e notificações
   void CheckRiskAlerts(void);
   void SendRiskAlert(const string message, const ENUM_RISK_LEVEL level);
   
   // Utilitários
   bool IsMarketOpen(const string symbol);
   bool IsNewsTime(void);
   double GetSymbolCorrelation(const string symbol1, const string symbol2, const int periods = 100);
   
private:
   // Métodos auxiliares
   void InitializeArrays(void);
   void UpdateArrays(void);
   double CalculateStandardDeviation(const double &array[], const int periods);
   double CalculateDownsideDeviation(const double &array[], const int periods);
   void LoadHistoricalData(void);
   bool ValidateRiskParameters(void);
   void ResetDailyCounters(void);
   double GetAccountEquity(void);
   double GetAccountBalance(void);
   int GetOpenPositionsCount(void);
   double GetTotalExposure(void);
   void LogRiskEvent(const string message, const ENUM_LOG_LEVEL level);
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
CRiskManager::CRiskManager()
{
   // Inicializar parâmetros padrão
   m_risk_params.max_risk_per_trade = 1.0;
   m_risk_params.daily_loss_limit = 5.0;
   m_risk_params.max_drawdown_limit = 10.0;
   m_risk_params.account_risk_limit = 2.0;
   m_risk_params.correlation_limit = 0.7;
   m_risk_params.max_positions = 3;
   m_risk_params.max_daily_trades = 10;
   m_risk_params.min_risk_reward_ratio = 1.5;
   m_risk_params.enable_martingale = false;
   m_risk_params.enable_hedging = false;
   m_risk_params.sizing_method = SIZING_PERCENT_RISK;
   
   // Inicializar limites FTMO padrão
   m_ftmo_limits.daily_loss_limit = 5.0;
   m_ftmo_limits.max_drawdown_limit = 10.0;
   m_ftmo_limits.profit_target = 8.0;
   m_ftmo_limits.consistency_rule = 50.0;
   m_ftmo_limits.allow_news_trading = false;
   m_ftmo_limits.allow_weekend_holding = false;
   m_ftmo_limits.allow_hedging = false;
   m_ftmo_limits.allow_ea_usage = true;
   m_ftmo_limits.challenge_start_date = TimeCurrent();
   m_ftmo_limits.challenge_duration_days = 30;
   
   // Inicializar variáveis de controle
   m_last_calculation = 0;
   m_daily_start_time = TimeCurrent();
   m_daily_start_balance = 0.0;
   m_peak_balance = 0.0;
   m_is_ftmo_account = true;
   m_account_type = "challenge";
   m_cached_lot_size = 0.0;
   m_cache_time = 0;
   m_cache_timeout = 300; // 5 minutos
   
   // Zerar métricas
   ZeroMemory(m_risk_metrics);
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
CRiskManager::~CRiskManager()
{
   ArrayFree(m_daily_pnl_history);
   ArrayFree(m_drawdown_history);
   ArrayFree(m_trade_times);
}

//+------------------------------------------------------------------+
//| Inicialização                                                     |
//+------------------------------------------------------------------+
bool CRiskManager::Init(void)
{
   g_logger.Info("Inicializando Risk Manager...");
   
   // Inicializar arrays
   InitializeArrays();
   
   // Carregar dados históricos
   LoadHistoricalData();
   
   // Validar parâmetros
   if(!ValidateRiskParameters())
   {
      g_logger.Error("Parâmetros de risco inválidos");
      return false;
   }
   
   // Inicializar valores base
   m_daily_start_balance = GetAccountBalance();
   m_peak_balance = m_daily_start_balance;
   m_daily_start_time = TimeCurrent();
   
   // Calcular métricas iniciais
   CalculateRiskMetrics();
   
   g_logger.Info("Risk Manager inicializado com sucesso");
   return true;
}

//+------------------------------------------------------------------+
//| Deinicialização                                                   |
//+------------------------------------------------------------------+
void CRiskManager::Deinit(void)
{
   // Salvar relatório final
   SaveRiskReport("RiskManager_Final_Report.txt");
   
   g_logger.Info("Risk Manager deinicializado");
}

//+------------------------------------------------------------------+
//| Auto-teste                                                        |
//+------------------------------------------------------------------+
bool CRiskManager::SelfTest(void)
{
   g_logger.Debug("Executando auto-teste do Risk Manager...");
   
   // Teste 1: Validar parâmetros
   if(!ValidateRiskParameters())
   {
      g_logger.Error("Falha no teste de validação de parâmetros");
      return false;
   }
   
   // Teste 2: Calcular lote de teste
   double test_lot = CalculateLotSize("EURUSD", 1.1000, 1.0950, 1.0);
   if(test_lot <= 0)
   {
      g_logger.Error("Falha no teste de cálculo de lote");
      return false;
   }
   
   // Teste 3: Verificar compliance FTMO
   if(!CheckFTMOCompliance("EURUSD", 0.01))
   {
      g_logger.Warning("Aviso: Possível não conformidade FTMO detectada");
   }
   
   // Teste 4: Calcular métricas
   CalculateRiskMetrics();
   
   g_logger.Debug("Auto-teste do Risk Manager concluído com sucesso");
   return true;
}

//+------------------------------------------------------------------+
//| Configurar parâmetros via string                                 |
//+------------------------------------------------------------------+
void CRiskManager::SetConfig(const string config_string)
{
   // Implementar parsing de configuração
   // Formato: "param1=value1;param2=value2;..."
   
   string params[];
   int count = StringSplit(config_string, ';', params);
   
   for(int i = 0; i < count; i++)
   {
      string pair[];
      if(StringSplit(params[i], '=', pair) == 2)
      {
         string key = pair[0];
         string value = pair[1];
         
         if(key == "max_risk_per_trade")
            m_risk_params.max_risk_per_trade = StringToDouble(value);
         else if(key == "daily_loss_limit")
            m_risk_params.daily_loss_limit = StringToDouble(value);
         else if(key == "max_drawdown_limit")
            m_risk_params.max_drawdown_limit = StringToDouble(value);
         else if(key == "max_positions")
            m_risk_params.max_positions = (int)StringToInteger(value);
         else if(key == "account_type")
            m_account_type = value;
         // Adicionar mais parâmetros conforme necessário
      }
   }
   
   g_logger.Info("Configuração do Risk Manager atualizada");
}

//+------------------------------------------------------------------+
//| Obter configuração atual                                          |
//+------------------------------------------------------------------+
string CRiskManager::GetConfig(void)
{
   string config = "";
   config += "max_risk_per_trade=" + DoubleToString(m_risk_params.max_risk_per_trade, 2) + ";";
   config += "daily_loss_limit=" + DoubleToString(m_risk_params.daily_loss_limit, 2) + ";";
   config += "max_drawdown_limit=" + DoubleToString(m_risk_params.max_drawdown_limit, 2) + ";";
   config += "max_positions=" + IntegerToString(m_risk_params.max_positions) + ";";
   config += "account_type=" + m_account_type + ";";
   
   return config;
}

//+------------------------------------------------------------------+
//| Obter status atual                                                |
//+------------------------------------------------------------------+
string CRiskManager::GetStatus(void)
{
   string status = "Risk Manager Status:\n";
   status += "Current Drawdown: " + DoubleToString(m_risk_metrics.current_drawdown, 2) + "%\n";
   status += "Daily P&L: " + DoubleToString(m_risk_metrics.daily_pnl, 2) + "\n";
   status += "Win Rate: " + DoubleToString(m_risk_metrics.win_rate, 2) + "%\n";
   status += "Profit Factor: " + DoubleToString(m_risk_metrics.profit_factor, 2) + "\n";
   status += "Open Positions: " + IntegerToString(GetOpenPositionsCount()) + "\n";
   status += "FTMO Compliant: " + (CheckFTMOCompliance(_Symbol, 0.01) ? "YES" : "NO") + "\n";
   
   return status;
}

//+------------------------------------------------------------------+
//| Calcular tamanho do lote                                         |
//+------------------------------------------------------------------+
double CRiskManager::CalculateLotSize(const string symbol, const double entry_price, 
                                     const double stop_loss, const double risk_percent = 0.0)
{
   // Usar cache se disponível e válido
   if(TimeCurrent() - m_cache_time < m_cache_timeout && m_cached_lot_size > 0)
   {
      return m_cached_lot_size;
   }
   
   double risk_pct = (risk_percent > 0) ? risk_percent : m_risk_params.max_risk_per_trade;
   double account_balance = GetAccountBalance();
   double risk_amount = account_balance * risk_pct / 100.0;
   
   // Calcular distância do stop loss
   double stop_distance = MathAbs(entry_price - stop_loss);
   if(stop_distance <= 0)
   {
      g_logger.Error("Distância do stop loss inválida");
      return 0.0;
   }
   
   // Obter informações do símbolo
   CSymbolInfo symbol_info;
   if(!symbol_info.Name(symbol))
   {
      g_logger.Error("Erro ao obter informações do símbolo: " + symbol);
      return 0.0;
   }
   
   // Calcular valor do tick
   double tick_value = symbol_info.TickValue();
   double tick_size = symbol_info.TickSize();
   
   // Calcular número de ticks no stop loss
   double ticks_in_stop = stop_distance / tick_size;
   
   // Calcular lote baseado no risco
   double calculated_lot = risk_amount / (ticks_in_stop * tick_value);
   
   // Normalizar para os limites do símbolo
   double min_lot = symbol_info.LotsMin();
   double max_lot = symbol_info.LotsMax();
   double lot_step = symbol_info.LotsStep();
   
   calculated_lot = MathMax(min_lot, MathMin(max_lot, calculated_lot));
   calculated_lot = NormalizeDouble(calculated_lot / lot_step, 0) * lot_step;
   
   // Aplicar limites adicionais baseados no risco total
   double total_exposure = GetTotalExposure();
   double max_allowed_exposure = account_balance * m_risk_params.account_risk_limit / 100.0;
   
   if(total_exposure + risk_amount > max_allowed_exposure)
   {
      double available_risk = max_allowed_exposure - total_exposure;
      if(available_risk > 0)
      {
         calculated_lot = (available_risk / risk_amount) * calculated_lot;
         calculated_lot = NormalizeDouble(calculated_lot / lot_step, 0) * lot_step;
      }
      else
      {
         g_logger.Warning("Limite de exposição total atingido");
         return 0.0;
      }
   }
   
   // Atualizar cache
   m_cached_lot_size = calculated_lot;
   m_cache_time = TimeCurrent();
   
   LogRiskEvent("Lote calculado: " + DoubleToString(calculated_lot, 2) + 
               " para risco de " + DoubleToString(risk_pct, 2) + "%", LOG_DEBUG);
   
   return calculated_lot;
}

//+------------------------------------------------------------------+
//| Validar novo trade                                               |
//+------------------------------------------------------------------+
bool CRiskManager::ValidateNewTrade(const string symbol, const ENUM_ORDER_TYPE order_type,
                                   const double lot_size, const double entry_price,
                                   const double stop_loss, const double take_profit)
{
   // Verificar compliance FTMO
   if(!CheckFTMOCompliance(symbol, lot_size))
   {
      LogRiskEvent("Trade rejeitado: Não conforme com regras FTMO", LOG_WARNING);
      return false;
   }
   
   // Verificar limites diários
   if(!CheckDailyLimits())
   {
      LogRiskEvent("Trade rejeitado: Limites diários atingidos", LOG_WARNING);
      return false;
   }
   
   // Verificar drawdown
   if(!CheckDrawdownLimits())
   {
      LogRiskEvent("Trade rejeitado: Limites de drawdown atingidos", LOG_WARNING);
      return false;
   }
   
   // Verificar correlação
   if(!CheckCorrelationRisk(symbol, order_type))
   {
      LogRiskEvent("Trade rejeitado: Alto risco de correlação", LOG_WARNING);
      return false;
   }
   
   // Verificar relação risco/recompensa
   double risk = MathAbs(entry_price - stop_loss);
   double reward = MathAbs(take_profit - entry_price);
   double rr_ratio = (risk > 0) ? reward / risk : 0;
   
   if(rr_ratio < m_risk_params.min_risk_reward_ratio)
   {
      LogRiskEvent("Trade rejeitado: Relação R/R insuficiente (" + 
                  DoubleToString(rr_ratio, 2) + ")", LOG_WARNING);
      return false;
   }
   
   // Verificar máximo de posições
   if(GetOpenPositionsCount() >= m_risk_params.max_positions)
   {
      LogRiskEvent("Trade rejeitado: Máximo de posições atingido", LOG_WARNING);
      return false;
   }
   
   LogRiskEvent("Trade validado com sucesso", LOG_DEBUG);
   return true;
}

//+------------------------------------------------------------------+
//| Verificar compliance FTMO                                        |
//+------------------------------------------------------------------+
bool CRiskManager::CheckFTMOCompliance(const string symbol, const double lot_size)
{
   if(!m_is_ftmo_account)
      return true;
   
   // Verificar se EAs são permitidos
   if(!m_ftmo_limits.allow_ea_usage)
   {
      return false;
   }
   
   // Verificar trading em notícias
   if(!m_ftmo_limits.allow_news_trading && IsNewsTime())
   {
      return false;
   }
   
   // Verificar hedging
   if(!m_ftmo_limits.allow_hedging)
   {
      // Verificar se há posições opostas no mesmo símbolo
      for(int i = 0; i < PositionsTotal(); i++)
      {
         if(m_position.SelectByIndex(i) && m_position.Symbol() == symbol)
         {
            // Se já há posição no símbolo, não permitir posição oposta
            return false;
         }
      }
   }
   
   // Verificar fim de semana
   if(!m_ftmo_limits.allow_weekend_holding)
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      if(dt.day_of_week == 5 && dt.hour >= 22) // Sexta após 22h
      {
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Verificar limites diários                                        |
//+------------------------------------------------------------------+
bool CRiskManager::CheckDailyLimits(void)
{
   // Atualizar métricas diárias
   UpdateDailyMetrics();
   
   // Verificar perda diária
   double daily_loss_pct = (m_daily_start_balance - GetAccountBalance()) / m_daily_start_balance * 100.0;
   if(daily_loss_pct >= m_risk_params.daily_loss_limit)
   {
      return false;
   }
   
   // Verificar número de trades diários
   int daily_trades = 0;
   datetime today_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   
   for(int i = 0; i < ArraySize(m_trade_times); i++)
   {
      if(m_trade_times[i] >= today_start)
      {
         daily_trades++;
      }
   }
   
   if(daily_trades >= m_risk_params.max_daily_trades)
   {
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Verificar limites de drawdown                                    |
//+------------------------------------------------------------------+
bool CRiskManager::CheckDrawdownLimits(void)
{
   double current_dd = CalculateCurrentDrawdown();
   
   if(current_dd >= m_risk_params.max_drawdown_limit)
   {
      return false;
   }
   
   // Para contas FTMO, verificar limite específico
   if(m_is_ftmo_account && current_dd >= m_ftmo_limits.max_drawdown_limit)
   {
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calcular drawdown atual                                          |
//+------------------------------------------------------------------+
double CRiskManager::CalculateCurrentDrawdown(void)
{
   double current_equity = GetAccountEquity();
   
   if(current_equity > m_peak_balance)
   {
      m_peak_balance = current_equity;
   }
   
   double drawdown = 0.0;
   if(m_peak_balance > 0)
   {
      drawdown = (m_peak_balance - current_equity) / m_peak_balance * 100.0;
   }
   
   m_risk_metrics.current_drawdown = drawdown;
   return drawdown;
}

//+------------------------------------------------------------------+
//| Calcular métricas de risco                                       |
//+------------------------------------------------------------------+
void CRiskManager::CalculateRiskMetrics(void)
{
   // Atualizar drawdown atual
   m_risk_metrics.current_drawdown = CalculateCurrentDrawdown();
   
   // Calcular P&L diário
   m_risk_metrics.daily_pnl = GetAccountBalance() - m_daily_start_balance;
   
   // Calcular outras métricas
   m_risk_metrics.sharpe_ratio = GetSharpeRatio();
   m_risk_metrics.sortino_ratio = GetSortinoRatio();
   m_risk_metrics.calmar_ratio = GetCalmarRatio();
   m_risk_metrics.profit_factor = GetProfitFactor();
   m_risk_metrics.recovery_factor = GetRecoveryFactor();
   
   // Atualizar timestamp
   m_risk_metrics.last_update = TimeCurrent();
   
   LogRiskEvent("Métricas de risco atualizadas", LOG_DEBUG);
}

//+------------------------------------------------------------------+
//| Gerar relatório de risco                                         |
//+------------------------------------------------------------------+
string CRiskManager::GenerateRiskReport(void)
{
   string report = "=== RELATÓRIO DE RISCO ===\n";
   report += "Data/Hora: " + TimeToString(TimeCurrent()) + "\n\n";
   
   report += "MÉTRICAS ATUAIS:\n";
   report += "Drawdown Atual: " + DoubleToString(m_risk_metrics.current_drawdown, 2) + "%\n";
   report += "P&L Diário: " + DoubleToString(m_risk_metrics.daily_pnl, 2) + "\n";
   report += "Sharpe Ratio: " + DoubleToString(m_risk_metrics.sharpe_ratio, 3) + "\n";
   report += "Sortino Ratio: " + DoubleToString(m_risk_metrics.sortino_ratio, 3) + "\n";
   report += "Profit Factor: " + DoubleToString(m_risk_metrics.profit_factor, 2) + "\n";
   report += "Win Rate: " + DoubleToString(m_risk_metrics.win_rate, 2) + "%\n\n";
   
   report += "PARÂMETROS DE RISCO:\n";
   report += "Risco por Trade: " + DoubleToString(m_risk_params.max_risk_per_trade, 2) + "%\n";
   report += "Limite Perda Diária: " + DoubleToString(m_risk_params.daily_loss_limit, 2) + "%\n";
   report += "Limite Drawdown: " + DoubleToString(m_risk_params.max_drawdown_limit, 2) + "%\n";
   report += "Máx. Posições: " + IntegerToString(m_risk_params.max_positions) + "\n\n";
   
   if(m_is_ftmo_account)
   {
      report += GenerateFTMOReport();
   }
   
   return report;
}

//+------------------------------------------------------------------+
//| Gerar relatório FTMO                                             |
//+------------------------------------------------------------------+
string CRiskManager::GenerateFTMOReport(void)
{
   string report = "COMPLIANCE FTMO:\n";
   report += "Tipo de Conta: " + m_account_type + "\n";
   report += "Limite Perda Diária: " + DoubleToString(m_ftmo_limits.daily_loss_limit, 2) + "%\n";
   report += "Limite Drawdown: " + DoubleToString(m_ftmo_limits.max_drawdown_limit, 2) + "%\n";
   report += "Meta de Lucro: " + DoubleToString(m_ftmo_limits.profit_target, 2) + "%\n";
   report += "Trading em Notícias: " + (m_ftmo_limits.allow_news_trading ? "Permitido" : "Proibido") + "\n";
   report += "Hedging: " + (m_ftmo_limits.allow_hedging ? "Permitido" : "Proibido") + "\n";
   report += "Uso de EAs: " + (m_ftmo_limits.allow_ea_usage ? "Permitido" : "Proibido") + "\n\n";
   
   return report;
}

//+------------------------------------------------------------------+
//| Métodos auxiliares                                                |
//+------------------------------------------------------------------+
void CRiskManager::InitializeArrays(void)
{
   ArrayResize(m_daily_pnl_history, 100);
   ArrayResize(m_drawdown_history, 100);
   ArrayResize(m_trade_times, 1000);
   
   ArrayInitialize(m_daily_pnl_history, 0.0);
   ArrayInitialize(m_drawdown_history, 0.0);
   ArrayInitialize(m_trade_times, 0);
}

void CRiskManager::LoadHistoricalData(void)
{
   // Implementar carregamento de dados históricos
   // Por enquanto, inicializar com valores padrão
   m_daily_start_balance = GetAccountBalance();
   m_peak_balance = m_daily_start_balance;
}

bool CRiskManager::ValidateRiskParameters(void)
{
   if(m_risk_params.max_risk_per_trade <= 0 || m_risk_params.max_risk_per_trade > 10)
      return false;
   if(m_risk_params.daily_loss_limit <= 0 || m_risk_params.daily_loss_limit > 20)
      return false;
   if(m_risk_params.max_drawdown_limit <= 0 || m_risk_params.max_drawdown_limit > 50)
      return false;
   if(m_risk_params.max_positions <= 0 || m_risk_params.max_positions > 20)
      return false;
   
   return true;
}

double CRiskManager::GetAccountEquity(void)
{
   return m_account.Equity();
}

double CRiskManager::GetAccountBalance(void)
{
   return m_account.Balance();
}

int CRiskManager::GetOpenPositionsCount(void)
{
   return PositionsTotal();
}

double CRiskManager::GetTotalExposure(void)
{
   double total_exposure = 0.0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(m_position.SelectByIndex(i))
      {
         total_exposure += m_position.Volume() * m_position.PriceOpen();
      }
   }
   
   return total_exposure;
}

void CRiskManager::LogRiskEvent(const string message, const ENUM_LOG_LEVEL level)
{
   switch(level)
   {
      case LOG_DEBUG:
         g_logger.Debug("[RISK] " + message);
         break;
      case LOG_INFO:
         g_logger.Info("[RISK] " + message);
         break;
      case LOG_WARNING:
         g_logger.Warning("[RISK] " + message);
         break;
      case LOG_ERROR:
         g_logger.Error("[RISK] " + message);
         break;
   }
}

// Implementações simplificadas dos métodos de cálculo de métricas
double CRiskManager::GetSharpeRatio(const int periods = 30) { return 0.0; }
double CRiskManager::GetSortinoRatio(const int periods = 30) { return 0.0; }
double CRiskManager::GetCalmarRatio(const int periods = 30) { return 0.0; }
double CRiskManager::GetProfitFactor(void) { return 1.0; }
double CRiskManager::GetRecoveryFactor(void) { return 1.0; }
bool CRiskManager::CheckCorrelationRisk(const string symbol, const ENUM_ORDER_TYPE order_type) { return true; }
bool CRiskManager::IsNewsTime(void) { return false; }
void CRiskManager::UpdateDailyMetrics(void) { }
bool CRiskManager::SaveRiskReport(const string filename) { return true; }
void CRiskManager::CheckRiskAlerts(void) { }
void CRiskManager::SendRiskAlert(const string message, const ENUM_RISK_LEVEL level) { }

//+------------------------------------------------------------------+
//| Implementações dos métodos da interface IManager                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Inicializar o gerenciador de risco                               |
//+------------------------------------------------------------------+
bool CRiskManager::Initialize()
{
   if(!Init())
      return false;
      
   // Configurar parâmetros padrão de risco
   m_risk_params.max_risk_per_trade = 1.0;      // 1% por trade
   m_risk_params.daily_loss_limit = 5.0;        // 5% perda diária
   m_risk_params.max_drawdown_limit = 10.0;     // 10% drawdown máximo
   m_risk_params.account_risk_limit = 20.0;     // 20% risco total
   m_risk_params.correlation_limit = 0.7;       // 70% correlação máxima
   m_risk_params.max_positions = 5;             // 5 posições máximas
   m_risk_params.max_daily_trades = 20;         // 20 trades por dia
   m_risk_params.min_risk_reward_ratio = 1.5;   // 1:1.5 mínimo
   m_risk_params.enable_martingale = false;     // Sem martingale
   m_risk_params.enable_hedging = false;        // Sem hedging
   m_risk_params.sizing_method = SIZING_PERCENT_RISK;
   
   // Configurar limites FTMO padrão
   m_ftmo_limits.daily_loss_limit = 5.0;
   m_ftmo_limits.max_drawdown_limit = 10.0;
   m_ftmo_limits.profit_target = 8.0;
   m_ftmo_limits.consistency_rule = 50.0;
   m_ftmo_limits.allow_news_trading = false;
   m_ftmo_limits.allow_weekend_holding = false;
   m_ftmo_limits.allow_hedging = false;
   m_ftmo_limits.allow_ea_usage = true;
   m_ftmo_limits.challenge_start_date = TimeCurrent();
   m_ftmo_limits.challenge_duration_days = 30;
   
   // Inicializar métricas
   ZeroMemory(m_risk_metrics);
   m_risk_metrics.last_update = TimeCurrent();
   
   // Configurar variáveis de controle
   m_daily_start_time = TimeCurrent();
   m_daily_start_balance = m_account.Balance();
   m_peak_balance = m_daily_start_balance;
   m_is_ftmo_account = true;
   m_account_type = "challenge";
   
   // Configurar cache
   m_cached_lot_size = 0.0;
   m_cache_time = 0;
   m_cache_timeout = 300; // 5 minutos
   
   // Inicializar arrays
   InitializeArrays();
   
   return true;
}

//+------------------------------------------------------------------+
//| Finalizar o gerenciador de risco                                 |
//+------------------------------------------------------------------+
void CRiskManager::Shutdown()
{
   // Calcular métricas finais
   CalculateRiskMetrics();
   
   // Salvar relatório final
   SaveRiskReport("risk_final_report.csv");
   
   // Limpar arrays
   ArrayResize(m_daily_pnl_history, 0);
   ArrayResize(m_drawdown_history, 0);
   ArrayResize(m_trade_times, 0);
   
   // Log do evento
   LogRiskEvent("Risk Manager finalizado", LOG_INFO);
   
   Deinit();
}

//+------------------------------------------------------------------+
//| Processar eventos de risco                                       |
//+------------------------------------------------------------------+
void CRiskManager::ProcessEvents()
{
   datetime current_time = TimeCurrent();
   
   // Atualizar métricas a cada minuto
   if(current_time - m_risk_metrics.last_update > 60)
   {
      CalculateRiskMetrics();
      UpdateDailyMetrics();
      m_risk_metrics.last_update = current_time;
   }
   
   // Verificar limites críticos
   if(!CheckDailyLimits())
   {
      LogRiskEvent("Limite diário de perda atingido!", LOG_ERROR);
      SendRiskAlert("ALERTA: Limite diário excedido", RISK_VERY_HIGH);
   }
   
   if(!CheckDrawdownLimits())
   {
      LogRiskEvent("Limite de drawdown atingido!", LOG_ERROR);
      SendRiskAlert("ALERTA: Drawdown máximo excedido", RISK_VERY_HIGH);
   }
   
   // Verificar alertas de risco
   CheckRiskAlerts();
   
   // Reset diário
   if(TimeDay(current_time) != TimeDay(m_daily_start_time))
   {
      m_daily_start_time = current_time;
      m_daily_start_balance = m_account.Balance();
      m_risk_metrics.daily_pnl = 0.0;
   }
}

//+------------------------------------------------------------------+
//| Verificar se está ativo                                          |
//+------------------------------------------------------------------+
bool CRiskManager::IsActive()
{
   return m_account.Balance() > 0 && CheckDailyLimits() && CheckDrawdownLimits();
}

//+------------------------------------------------------------------+
//| Parar o gerenciador de risco                                     |
//+------------------------------------------------------------------+
void CRiskManager::Stop()
{
   LogRiskEvent("Risk Manager parado manualmente", LOG_WARNING);
}

//+------------------------------------------------------------------+
//| Reiniciar o gerenciador de risco                                 |
//+------------------------------------------------------------------+
void CRiskManager::Restart()
{
   Stop();
   
   // Aguardar um momento
   Sleep(1000);
   
   // Reinicializar
   if(Initialize())
   {
      LogRiskEvent("Risk Manager reiniciado com sucesso", LOG_INFO);
   }
   else
   {
      LogRiskEvent("Falha ao reiniciar Risk Manager", LOG_ERROR);
   }
}

//+------------------------------------------------------------------+
//| Obter informações de debug                                       |
//+------------------------------------------------------------------+
string CRiskManager::GetDebugInfo()
{
   string info = "=== Risk Manager Debug ===\n";
   info += "Account Type: " + m_account_type + "\n";
   info += "FTMO Account: " + (m_is_ftmo_account ? "Yes" : "No") + "\n";
   info += "Balance: " + DoubleToString(m_account.Balance(), 2) + "\n";
   info += "Equity: " + DoubleToString(m_account.Equity(), 2) + "\n";
   info += "Current Drawdown: " + DoubleToString(m_risk_metrics.current_drawdown, 2) + "%\n";
   info += "Max Drawdown: " + DoubleToString(m_risk_metrics.max_drawdown, 2) + "%\n";
   info += "Daily P&L: " + DoubleToString(m_risk_metrics.daily_pnl, 2) + "\n";
   info += "Win Rate: " + DoubleToString(m_risk_metrics.win_rate, 1) + "%\n";
   info += "Profit Factor: " + DoubleToString(m_risk_metrics.profit_factor, 2) + "\n";
   info += "Sharpe Ratio: " + DoubleToString(m_risk_metrics.sharpe_ratio, 2) + "\n";
   info += "VaR 95%: " + DoubleToString(m_risk_metrics.var_95, 2) + "\n";
   info += "Open Positions: " + IntegerToString(GetOpenPositionsCount()) + "\n";
   info += "Max Risk per Trade: " + DoubleToString(m_risk_params.max_risk_per_trade, 1) + "%\n";
   info += "Daily Loss Limit: " + DoubleToString(m_risk_params.daily_loss_limit, 1) + "%\n";
   info += "Max Positions: " + IntegerToString(m_risk_params.max_positions) + "\n";
   info += "Last Update: " + TimeToString(m_risk_metrics.last_update) + "\n";
   
   return info;
}

//+------------------------------------------------------------------+
//| Validar configuração                                             |
//+------------------------------------------------------------------+
bool CRiskManager::ValidateConfiguration()
{
   if(m_risk_params.max_risk_per_trade <= 0.0 || m_risk_params.max_risk_per_trade > 10.0)
   {
      Print("Erro: Risco por trade inválido: ", m_risk_params.max_risk_per_trade, "%");
      return false;
   }
   
   if(m_risk_params.daily_loss_limit <= 0.0 || m_risk_params.daily_loss_limit > 20.0)
   {
      Print("Erro: Limite de perda diária inválido: ", m_risk_params.daily_loss_limit, "%");
      return false;
   }
   
   if(m_risk_params.max_drawdown_limit <= 0.0 || m_risk_params.max_drawdown_limit > 50.0)
   {
      Print("Erro: Limite de drawdown inválido: ", m_risk_params.max_drawdown_limit, "%");
      return false;
   }
   
   if(m_risk_params.max_positions <= 0 || m_risk_params.max_positions > 20)
   {
      Print("Erro: Número máximo de posições inválido: ", m_risk_params.max_positions);
      return false;
   }
   
   if(m_risk_params.min_risk_reward_ratio < 1.0)
   {
      Print("Erro: Relação risco/recompensa inválida: ", m_risk_params.min_risk_reward_ratio);
      return false;
   }
   
   if(m_account.Balance() <= 0.0)
   {
      Print("Erro: Saldo da conta inválido: ", m_account.Balance());
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
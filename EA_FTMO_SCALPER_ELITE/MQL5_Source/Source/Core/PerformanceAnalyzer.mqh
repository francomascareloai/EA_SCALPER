//+------------------------------------------------------------------+
//|                                      PerformanceAnalyzer.mqh    |
//|                                    EA FTMO Scalper Elite v1.0    |
//|                                      TradeDev_Master 2024        |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master 2024"
#property version   "1.00"
#property strict

#include "Interfaces.mqh"
#include "DataStructures.mqh"
#include "Logger.mqh"

//+------------------------------------------------------------------+
//| CLASSE ANALISADOR DE PERFORMANCE                                 |
//+------------------------------------------------------------------+

class CPerformanceAnalyzer : public IPerformanceAnalyzer
{
private:
    // Estado
    bool                m_initialized;
    string              m_module_name;
    string              m_version;
    
    // Dados de performance
    SPerformanceData    m_performance;
    
    // Histórico de trades
    struct STradeRecord
    {
        ulong    ticket;
        string   symbol;
        int      type;
        double   volume;
        double   open_price;
        double   close_price;
        double   sl;
        double   tp;
        datetime open_time;
        datetime close_time;
        double   profit;
        double   commission;
        double   swap;
        string   comment;
        int      magic;
        double   balance_before;
        double   balance_after;
        double   equity_before;
        double   equity_after;
        double   drawdown_at_open;
        double   max_profit;
        double   max_loss;
        int      duration_seconds;
        bool     is_winner;
        double   risk_reward_ratio;
        double   mae; // Maximum Adverse Excursion
        double   mfe; // Maximum Favorable Excursion
    };
    
    STradeRecord        m_trade_history[];
    int                 m_trade_count;
    
    // Análise por período
    struct SPeriodStats
    {
        datetime start_time;
        datetime end_time;
        int      trades;
        int      winners;
        int      losers;
        double   gross_profit;
        double   gross_loss;
        double   net_profit;
        double   max_drawdown;
        double   max_runup;
        double   profit_factor;
        double   sharpe_ratio;
        double   sortino_ratio;
        double   calmar_ratio;
        double   recovery_factor;
        double   avg_trade;
        double   avg_winner;
        double   avg_loser;
        double   largest_winner;
        double   largest_loser;
        int      consecutive_wins;
        int      consecutive_losses;
        int      max_consecutive_wins;
        int      max_consecutive_losses;
    };
    
    SPeriodStats        m_daily_stats[];
    SPeriodStats        m_weekly_stats[];
    SPeriodStats        m_monthly_stats[];
    
    // Análise de drawdown
    struct SDrawdownPeriod
    {
        datetime start_time;
        datetime end_time;
        double   start_balance;
        double   lowest_balance;
        double   end_balance;
        double   max_drawdown_pct;
        double   max_drawdown_amount;
        int      duration_days;
        int      trades_in_period;
        bool     is_recovered;
        datetime recovery_time;
    };
    
    SDrawdownPeriod     m_drawdown_periods[];
    int                 m_drawdown_count;
    
    // Análise de correlação
    struct SCorrelationData
    {
        string   symbol;
        double   correlation;
        int      trades;
        double   avg_profit;
    };
    
    SCorrelationData    m_symbol_correlations[];
    
    // Métricas de risco
    struct SRiskMetrics
    {
        double   var_95; // Value at Risk 95%
        double   var_99; // Value at Risk 99%
        double   cvar_95; // Conditional VaR 95%
        double   cvar_99; // Conditional VaR 99%
        double   max_daily_loss;
        double   max_weekly_loss;
        double   max_monthly_loss;
        double   volatility;
        double   downside_deviation;
        double   ulcer_index;
        double   sterling_ratio;
        double   burke_ratio;
    };
    
    SRiskMetrics        m_risk_metrics;
    
    // Configurações
    bool                m_real_time_analysis;
    int                 m_analysis_interval;
    datetime            m_last_analysis;
    bool                m_export_enabled;
    string              m_export_path;
    
    // Métodos privados
    void                UpdateTradeRecord(ulong ticket);
    void                CalculatePeriodStats(SPeriodStats &stats, datetime start, datetime end);
    void                CalculateDrawdownPeriods();
    void                CalculateRiskMetrics();
    void                CalculateCorrelations();
    double              CalculateSharpeRatio(const double &returns[], int count, double risk_free_rate = 0.0);
    double              CalculateSortinoRatio(const double &returns[], int count, double target_return = 0.0);
    double              CalculateCalmarRatio(double annual_return, double max_drawdown);
    double              CalculateVaR(const double &returns[], int count, double confidence);
    double              CalculateCVaR(const double &returns[], int count, double confidence);
    double              CalculateVolatility(const double &returns[], int count);
    double              CalculateDownsideDeviation(const double &returns[], int count, double target = 0.0);
    double              CalculateUlcerIndex(const double &equity_curve[], int count);
    void                UpdateDailyStats();
    void                UpdateWeeklyStats();
    void                UpdateMonthlyStats();
    bool                IsNewDay();
    bool                IsNewWeek();
    bool                IsNewMonth();
    void                ExportToCSV(string filename, string data);
    string              FormatStatsToCSV(SPeriodStats &stats);
    string              FormatTradeToCSV(STradeRecord &trade);
    
public:
    // Construtor e destrutor
                        CPerformanceAnalyzer();
                        ~CPerformanceAnalyzer();
    
    // Implementação IModule
    virtual bool        Init() override;
    virtual void        Deinit() override;
    virtual bool        IsInitialized() override { return m_initialized; }
    virtual string      GetModuleName() override { return m_module_name; }
    virtual string      GetVersion() override { return m_version; }
    virtual bool        SelfTest() override;
    
    // Implementação IPerformanceAnalyzer
    virtual bool        UpdatePerformance() override;
    virtual SPerformanceData GetPerformanceData() override;
    virtual double      GetProfitFactor() override;
    virtual double      GetSharpeRatio() override;
    virtual double      GetMaxDrawdown() override;
    virtual double      GetWinRate() override;
    virtual string      GenerateReport() override;
    virtual bool        SaveReport(string filename) override;
    virtual bool        ExportToCSV(string filename) override;
    virtual bool        ExportToHTML(string filename) override;
    
    // Métodos adicionais sem override
    void                OnTradeOpen(ulong ticket);
    void                OnTradeClose(ulong ticket);
    void                OnTradeModify(ulong ticket);
    int                 GetTotalTrades();
    double              GetNetProfit();
    double              GetAverageTrade();
    void                ResetStatistics();
    void                UpdateMetrics() { UpdatePerformance(); } // Alias para UpdatePerformance
    
    // Métodos específicos
    void                SetRealTimeAnalysis(bool enabled, int interval_seconds = 60);
    void                SetExportPath(string path);
    void                EnableExport(bool enabled);
    
    // Análise avançada - implementações da interface IPerformanceAnalyzer
    virtual double      GetSortinoRatio() override;
    virtual double      GetCalmarRatio() override;
    virtual double      GetRecoveryFactor() override;
    virtual double      GetExpectancy() override;
    virtual double      GetVolatility() override;
    virtual double      GetMonthlyReturn() override;
    virtual double      GetAnnualizedReturn() override;
    virtual double      GetBestMonth() override;
    virtual double      GetWorstMonth() override;
    virtual int         GetConsecutiveWins() override;
    virtual int         GetConsecutiveLosses() override;
    virtual bool        SetBenchmark(double benchmark_return) override;
    virtual bool        SetRiskFreeRate(double rate) override;
    virtual bool        SetAnalysisPeriod(datetime start, datetime end) override;
    
    // Métodos adicionais sem override
    double              GetSterlingRatio();
    double              GetBurkeRatio();
    double              GetUlcerIndex();
    
    // Análise de risco
    double              GetVaR95();
    double              GetVaR99();
    double              GetCVaR95();
    double              GetCVaR99();
    double              GetDownsideDeviation();
    
    // Análise por período
    SPeriodStats        GetDailyStats(datetime date);
    SPeriodStats        GetWeeklyStats(datetime week_start);
    SPeriodStats        GetMonthlyStats(datetime month_start);
    
    // Análise de drawdown
    SDrawdownPeriod     GetCurrentDrawdown();
    SDrawdownPeriod     GetWorstDrawdown();
    int                 GetDrawdownCount();
    double              GetAverageDrawdownDuration();
    double              GetAverageRecoveryTime();
    
    // Análise de trades
    double              GetAverageWinner();
    double              GetAverageLoser();
    double              GetLargestWinner();
    double              GetLargestLoser();
    int                 GetMaxConsecutiveWins();
    int                 GetMaxConsecutiveLosses();
    double              GetAverageTradeTime();
    
    // Análise de correlação
    void                CalculateSymbolCorrelations();
    double              GetSymbolCorrelation(string symbol);
    
    // Relatórios
    string              GetDetailedReport();
    string              GetRiskReport();
    string              GetDrawdownReport();
    string              GetTradeAnalysisReport();
    bool                ExportReport(string filename);
    string              GetSummaryReport();
    
    // Benchmarking
    void                SetBenchmark(string symbol, int timeframe = PERIOD_D1);
    double              GetBenchmarkCorrelation();
    double              GetAlpha();
    double              GetBeta();
    double              GetInformationRatio();
    double              GetTrackingError();
    
    // Otimização
    void                OptimizeParameters();
    string              GetOptimizationSuggestions();
    
    // Alertas de performance
    void                CheckPerformanceAlerts();
    void                SetDrawdownAlert(double max_drawdown_pct);
    void                SetProfitTargetAlert(double target_profit);
    void                SetConsecutiveLossAlert(int max_losses);
};

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO CONSTRUTOR                                      |
//+------------------------------------------------------------------+

CPerformanceAnalyzer::CPerformanceAnalyzer()
{
    m_initialized = false;
    m_module_name = "PerformanceAnalyzer";
    m_version = "1.00";
    
    // Inicializar dados de performance
    ZeroMemory(m_performance);
    
    // Configurações padrão
    m_real_time_analysis = true;
    m_analysis_interval = 60; // 1 minuto
    m_last_analysis = 0;
    m_export_enabled = false;
    m_export_path = "";
    
    // Inicializar arrays
    ArrayResize(m_trade_history, 0);
    ArrayResize(m_daily_stats, 0);
    ArrayResize(m_weekly_stats, 0);
    ArrayResize(m_monthly_stats, 0);
    ArrayResize(m_drawdown_periods, 0);
    ArrayResize(m_symbol_correlations, 0);
    
    m_trade_count = 0;
    m_drawdown_count = 0;
    
    // Inicializar métricas de risco
    ZeroMemory(m_risk_metrics);
}

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÃO DO DESTRUTOR                                       |
//+------------------------------------------------------------------+

CPerformanceAnalyzer::~CPerformanceAnalyzer()
{
    Deinit();
}

//+------------------------------------------------------------------+
//| INICIALIZAÇÃO                                                    |
//+------------------------------------------------------------------+

bool CPerformanceAnalyzer::Init()
{
    if(m_initialized)
        return true;
    
    LogInfo("Inicializando PerformanceAnalyzer...");
    
    // Inicializar dados de performance
    m_performance.start_time = TimeCurrent();
    m_performance.initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_performance.initial_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_performance.current_balance = m_performance.initial_balance;
    m_performance.current_equity = m_performance.initial_equity;
    m_performance.peak_balance = m_performance.initial_balance;
    m_performance.peak_equity = m_performance.initial_equity;
    
    // Configurar path de exportação padrão
    if(m_export_path == "")
    {
        m_export_path = "Files\\EA_Performance\\";
    }
    
    m_initialized = true;
    LogInfo("PerformanceAnalyzer inicializado com sucesso");
    
    return true;
}

//+------------------------------------------------------------------+
//| DESINICIALIZAÇÃO                                                 |
//+------------------------------------------------------------------+

void CPerformanceAnalyzer::Deinit()
{
    if(!m_initialized)
        return;
    
    LogInfo("Desinicializando PerformanceAnalyzer...");
    
    // Exportar relatório final se habilitado
    if(m_export_enabled)
    {
        string filename = "Final_Report_" + TimeToString(TimeCurrent(), TIME_DATE) + ".html";
        ExportReport(filename);
    }
    
    // Imprimir relatório final
    LogInfo(GetSummaryReport());
    
    m_initialized = false;
    LogInfo("PerformanceAnalyzer desinicializado");
}

//+------------------------------------------------------------------+
//| AUTO-TESTE                                                       |
//+------------------------------------------------------------------+

bool CPerformanceAnalyzer::SelfTest()
{
    if(!m_initialized)
        return false;
    
    LogInfo("Executando auto-teste do PerformanceAnalyzer...");
    
    // Verificar se os dados básicos estão corretos
    if(m_performance.initial_balance <= 0)
    {
        LogError("Falha no teste: saldo inicial inválido");
        return false;
    }
    
    if(m_performance.start_time <= 0)
    {
        LogError("Falha no teste: tempo de início inválido");
        return false;
    }
    
    // Testar cálculos básicos
    double test_returns[] = {0.01, -0.005, 0.02, -0.01, 0.015};
    int count = ArraySize(test_returns);
    
    double volatility = CalculateVolatility(test_returns, count);
    if(volatility <= 0)
    {
        LogError("Falha no teste: cálculo de volatilidade");
        return false;
    }
    
    double var95 = CalculateVaR(test_returns, count, 0.95);
    if(var95 >= 0) // VaR deve ser negativo
    {
        LogError("Falha no teste: cálculo de VaR");
        return false;
    }
    
    LogInfo("Auto-teste do PerformanceAnalyzer concluído com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| ABERTURA DE TRADE                                                |
//+------------------------------------------------------------------+

void CPerformanceAnalyzer::OnTradeOpen(ulong ticket)
{
    if(!m_initialized || ticket == 0)
        return;
    
    // Atualizar contadores
    m_performance.total_trades++;
    
    // Registrar dados do trade
    UpdateTradeRecord(ticket);
    
    // Atualizar análise em tempo real
    if(m_real_time_analysis)
    {
        UpdatePerformance();
    }
    
    LogDebug("Trade aberto registrado: " + IntegerToString(ticket));
}

//+------------------------------------------------------------------+
//| FECHAMENTO DE TRADE                                              |
//+------------------------------------------------------------------+

void CPerformanceAnalyzer::OnTradeClose(ulong ticket)
{
    if(!m_initialized || ticket == 0)
        return;
    
    // Encontrar registro do trade
    int index = -1;
    for(int i = 0; i < m_trade_count; i++)
    {
        if(m_trade_history[i].ticket == ticket)
        {
            index = i;
            break;
        }
    }
    
    if(index < 0)
    {
        LogWarning("Trade não encontrado no histórico: " + IntegerToString(ticket));
        return;
    }
    
    // Atualizar dados do trade fechado
    if(PositionSelectByTicket(ticket) || OrderSelect(ticket))
    {
        m_trade_history[index].close_time = TimeCurrent();
        m_trade_history[index].close_price = PositionGetDouble(POSITION_PRICE_CURRENT);
        m_trade_history[index].profit = PositionGetDouble(POSITION_PROFIT);
        m_trade_history[index].commission = PositionGetDouble(POSITION_COMMISSION);
        m_trade_history[index].swap = PositionGetDouble(POSITION_SWAP);
        m_trade_history[index].balance_after = AccountInfoDouble(ACCOUNT_BALANCE);
        m_trade_history[index].equity_after = AccountInfoDouble(ACCOUNT_EQUITY);
        
        // Calcular duração
        m_trade_history[index].duration_seconds = (int)(m_trade_history[index].close_time - m_trade_history[index].open_time);
        
        // Determinar se é vencedor
        double net_profit = m_trade_history[index].profit + m_trade_history[index].commission + m_trade_history[index].swap;
        m_trade_history[index].is_winner = (net_profit > 0);
        
        // Calcular risk/reward ratio
        double risk = MathAbs(m_trade_history[index].open_price - m_trade_history[index].sl) * m_trade_history[index].volume;
        double reward = MathAbs(m_trade_history[index].tp - m_trade_history[index].open_price) * m_trade_history[index].volume;
        if(risk > 0)
            m_trade_history[index].risk_reward_ratio = reward / risk;
        
        // Atualizar estatísticas
        if(m_trade_history[index].is_winner)
        {
            m_performance.winning_trades++;
            m_performance.gross_profit += net_profit;
            if(net_profit > m_performance.largest_win)
                m_performance.largest_win = net_profit;
        }
        else
        {
            m_performance.losing_trades++;
            m_performance.gross_loss += MathAbs(net_profit);
            if(MathAbs(net_profit) > m_performance.largest_loss)
                m_performance.largest_loss = MathAbs(net_profit);
        }
        
        // Atualizar saldo e equity
        m_performance.current_balance = m_trade_history[index].balance_after;
        m_performance.current_equity = m_trade_history[index].equity_after;
        
        // Atualizar picos
        if(m_performance.current_balance > m_performance.peak_balance)
            m_performance.peak_balance = m_performance.current_balance;
        if(m_performance.current_equity > m_performance.peak_equity)
            m_performance.peak_equity = m_performance.current_equity;
        
        // Calcular drawdown atual
        double balance_drawdown = (m_performance.peak_balance - m_performance.current_balance) / m_performance.peak_balance * 100.0;
        double equity_drawdown = (m_performance.peak_equity - m_performance.current_equity) / m_performance.peak_equity * 100.0;
        
        m_performance.current_drawdown = MathMax(balance_drawdown, equity_drawdown);
        
        if(m_performance.current_drawdown > m_performance.max_drawdown)
            m_performance.max_drawdown = m_performance.current_drawdown;
    }
    
    // Atualizar análise em tempo real
    if(m_real_time_analysis)
    {
        UpdatePerformance();
    }
    
    // Verificar alertas
    CheckPerformanceAlerts();
    
    LogDebug("Trade fechado registrado: " + IntegerToString(ticket));
}

//+------------------------------------------------------------------+
//| MODIFICAÇÃO DE TRADE                                             |
//+------------------------------------------------------------------+

void CPerformanceAnalyzer::OnTradeModify(ulong ticket)
{
    if(!m_initialized || ticket == 0)
        return;
    
    // Encontrar e atualizar registro do trade
    for(int i = 0; i < m_trade_count; i++)
    {
        if(m_trade_history[i].ticket == ticket)
        {
            if(PositionSelectByTicket(ticket))
            {
                m_trade_history[i].sl = PositionGetDouble(POSITION_SL);
                m_trade_history[i].tp = PositionGetDouble(POSITION_TP);
            }
            break;
        }
    }
    
    LogDebug("Trade modificado: " + IntegerToString(ticket));
}

//+------------------------------------------------------------------+
//| ATUALIZAR PERFORMANCE                                            |
//+------------------------------------------------------------------+

bool CPerformanceAnalyzer::UpdatePerformance()
{
    if(!m_initialized)
        return false;
    
    datetime current_time = TimeCurrent();
    
    // Verificar se é hora de análise
    if(m_real_time_analysis && (current_time - m_last_analysis) < m_analysis_interval)
        return true;
    
    // Atualizar dados básicos
    m_performance.current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_performance.current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_performance.net_profit = m_performance.current_balance - m_performance.initial_balance;
    
    // Calcular métricas básicas
    if(m_performance.total_trades > 0)
    {
        m_performance.win_rate = (double)m_performance.winning_trades / m_performance.total_trades * 100.0;
        m_performance.average_trade = m_performance.net_profit / m_performance.total_trades;
        
        if(m_performance.winning_trades > 0)
            m_performance.average_win = m_performance.gross_profit / m_performance.winning_trades;
        
        if(m_performance.losing_trades > 0)
            m_performance.average_loss = m_performance.gross_loss / m_performance.losing_trades;
        
        if(m_performance.gross_loss > 0)
            m_performance.profit_factor = m_performance.gross_profit / m_performance.gross_loss;
    }
    
    // Atualizar estatísticas por período
    UpdateDailyStats();
    UpdateWeeklyStats();
    UpdateMonthlyStats();
    
    // Calcular métricas avançadas
    CalculateRiskMetrics();
    CalculateDrawdownPeriods();
    
    m_last_analysis = current_time;
    return true;
}

//+------------------------------------------------------------------+
//| OBTER FATOR DE LUCRO                                             |
//+------------------------------------------------------------------+

double CPerformanceAnalyzer::GetProfitFactor()
{
    return m_performance.profit_factor;
}

//+------------------------------------------------------------------+
//| OBTER ÍNDICE SHARPE                                              |
//+------------------------------------------------------------------+

double CPerformanceAnalyzer::GetSharpeRatio()
{
    if(m_trade_count < 2)
        return 0.0;
    
    // Calcular retornos dos trades
    double returns[];
    ArrayResize(returns, m_trade_count);
    
    for(int i = 0; i < m_trade_count; i++)
    {
        if(m_trade_history[i].close_time > 0)
        {
            double net_profit = m_trade_history[i].profit + m_trade_history[i].commission + m_trade_history[i].swap;
            returns[i] = net_profit / m_trade_history[i].balance_before;
        }
    }
    
    return CalculateSharpeRatio(returns, m_trade_count);
}

//+------------------------------------------------------------------+
//| OBTER DRAWDOWN MÁXIMO                                            |
//+------------------------------------------------------------------+

double CPerformanceAnalyzer::GetMaxDrawdown()
{
    return m_performance.max_drawdown;
}

//+------------------------------------------------------------------+
//| OBTER TAXA DE VITÓRIA                                            |
//+------------------------------------------------------------------+

double CPerformanceAnalyzer::GetWinRate()
{
    return m_performance.win_rate;
}

//+------------------------------------------------------------------+
//| OBTER TOTAL DE TRADES                                            |
//+------------------------------------------------------------------+

int CPerformanceAnalyzer::GetTotalTrades()
{
    return m_performance.total_trades;
}

//+------------------------------------------------------------------+
//| OBTER LUCRO LÍQUIDO                                              |
//+------------------------------------------------------------------+

double CPerformanceAnalyzer::GetNetProfit()
{
    return m_performance.net_profit;
}

//+------------------------------------------------------------------+
//| OBTER TRADE MÉDIO                                                |
//+------------------------------------------------------------------+

double CPerformanceAnalyzer::GetAverageTrade()
{
    return m_performance.average_trade;
}

//+------------------------------------------------------------------+
//| OBTER DADOS DE PERFORMANCE                                       |
//+------------------------------------------------------------------+

SPerformanceData CPerformanceAnalyzer::GetPerformanceData()
{
    return m_performance;
}

//+------------------------------------------------------------------+
//| EXPORTAR RELATÓRIO                                               |
//+------------------------------------------------------------------+

bool CPerformanceAnalyzer::ExportReport(string filename)
{
    if(!m_initialized)
        return false;
    
    string full_path = m_export_path + filename;
    
    // Criar relatório HTML
    string html = "<!DOCTYPE html>\n";
    html += "<html>\n<head>\n";
    html += "<title>EA Performance Report</title>\n";
    html += "<style>\n";
    html += "body { font-family: Arial, sans-serif; margin: 20px; }\n";
    html += "table { border-collapse: collapse; width: 100%; margin: 20px 0; }\n";
    html += "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n";
    html += "th { background-color: #f2f2f2; }\n";
    html += ".positive { color: green; }\n";
    html += ".negative { color: red; }\n";
    html += "</style>\n";
    html += "</head>\n<body>\n";
    
    html += "<h1>EA FTMO Scalper Elite - Performance Report</h1>\n";
    html += "<p>Generated: " + TimeToString(TimeCurrent()) + "</p>\n";
    
    // Resumo geral
    html += "<h2>Summary</h2>\n";
    html += "<table>\n";
    html += "<tr><th>Metric</th><th>Value</th></tr>\n";
    html += "<tr><td>Initial Balance</td><td>" + DoubleToString(m_performance.initial_balance, 2) + "</td></tr>\n";
    html += "<tr><td>Current Balance</td><td>" + DoubleToString(m_performance.current_balance, 2) + "</td></tr>\n";
    html += "<tr><td>Net Profit</td><td class='" + (m_performance.net_profit >= 0 ? "positive" : "negative") + "'>" + DoubleToString(m_performance.net_profit, 2) + "</td></tr>\n";
    html += "<tr><td>Total Trades</td><td>" + IntegerToString(m_performance.total_trades) + "</td></tr>\n";
    html += "<tr><td>Win Rate</td><td>" + DoubleToString(m_performance.win_rate, 2) + "%</td></tr>\n";
    html += "<tr><td>Profit Factor</td><td>" + DoubleToString(m_performance.profit_factor, 2) + "</td></tr>\n";
    html += "<tr><td>Max Drawdown</td><td class='negative'>" + DoubleToString(m_performance.max_drawdown, 2) + "%</td></tr>\n";
    html += "<tr><td>Sharpe Ratio</td><td>" + DoubleToString(GetSharpeRatio(), 2) + "</td></tr>\n";
    html += "</table>\n";
    
    // Adicionar mais seções do relatório...
    
    html += "</body>\n</html>";
    
    // Salvar arquivo
    int file_handle = FileOpen(full_path, FILE_WRITE | FILE_TXT);
    if(file_handle != INVALID_HANDLE)
    {
        FileWriteString(file_handle, html);
        FileClose(file_handle);
        
        LogInfo("Relatório exportado: " + full_path);
        return true;
    }
    
    LogError("Falha ao exportar relatório: " + full_path);
    return false;
}

//+------------------------------------------------------------------+
//| OBTER RELATÓRIO RESUMIDO                                         |
//+------------------------------------------------------------------+

string CPerformanceAnalyzer::GetSummaryReport()
{
    string report = "\n=== RELATÓRIO DE PERFORMANCE ===\n";
    report += "Período: " + TimeToString(m_performance.start_time) + " - " + TimeToString(TimeCurrent()) + "\n";
    report += "Saldo Inicial: " + DoubleToString(m_performance.initial_balance, 2) + "\n";
    report += "Saldo Atual: " + DoubleToString(m_performance.current_balance, 2) + "\n";
    report += "Lucro Líquido: " + DoubleToString(m_performance.net_profit, 2) + "\n";
    report += "Total de Trades: " + IntegerToString(m_performance.total_trades) + "\n";
    report += "Trades Vencedores: " + IntegerToString(m_performance.winning_trades) + "\n";
    report += "Trades Perdedores: " + IntegerToString(m_performance.losing_trades) + "\n";
    report += "Taxa de Vitória: " + DoubleToString(m_performance.win_rate, 2) + "%\n";
    report += "Fator de Lucro: " + DoubleToString(m_performance.profit_factor, 2) + "\n";
    report += "Drawdown Máximo: " + DoubleToString(m_performance.max_drawdown, 2) + "%\n";
    report += "Trade Médio: " + DoubleToString(m_performance.average_trade, 2) + "\n";
    report += "Maior Ganho: " + DoubleToString(m_performance.largest_win, 2) + "\n";
    report += "Maior Perda: " + DoubleToString(m_performance.largest_loss, 2) + "\n";
    report += "Índice Sharpe: " + DoubleToString(GetSharpeRatio(), 2) + "\n";
    report += "===============================\n";
    
    return report;
}

//+------------------------------------------------------------------+
//| RESETAR ESTATÍSTICAS                                             |
//+------------------------------------------------------------------+

void CPerformanceAnalyzer::ResetStatistics()
{
    if(!m_initialized)
        return;
    
    LogInfo("Resetando estatísticas de performance...");
    
    // Salvar dados atuais se necessário
    if(m_export_enabled)
    {
        string filename = "Backup_" + TimeToString(TimeCurrent(), TIME_DATE) + ".html";
        ExportReport(filename);
    }
    
    // Resetar dados
    ZeroMemory(m_performance);
    ArrayResize(m_trade_history, 0);
    ArrayResize(m_daily_stats, 0);
    ArrayResize(m_weekly_stats, 0);
    ArrayResize(m_monthly_stats, 0);
    ArrayResize(m_drawdown_periods, 0);
    
    m_trade_count = 0;
    m_drawdown_count = 0;
    
    // Reinicializar
    m_performance.start_time = TimeCurrent();
    m_performance.initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_performance.initial_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    m_performance.current_balance = m_performance.initial_balance;
    m_performance.current_equity = m_performance.initial_equity;
    m_performance.peak_balance = m_performance.initial_balance;
    m_performance.peak_equity = m_performance.initial_equity;
    
    LogInfo("Estatísticas resetadas");
}

//+------------------------------------------------------------------+
//| MÉTODOS PRIVADOS                                                 |
//+------------------------------------------------------------------+

void CPerformanceAnalyzer::UpdateTradeRecord(ulong ticket)
{
    if(PositionSelectByTicket(ticket))
    {
        // Redimensionar array se necessário
        if(m_trade_count >= ArraySize(m_trade_history))
        {
            ArrayResize(m_trade_history, m_trade_count + 100);
        }
        
        // Preencher dados do trade
        m_trade_history[m_trade_count].ticket = ticket;
        m_trade_history[m_trade_count].symbol = PositionGetString(POSITION_SYMBOL);
        m_trade_history[m_trade_count].type = (int)PositionGetInteger(POSITION_TYPE);
        m_trade_history[m_trade_count].volume = PositionGetDouble(POSITION_VOLUME);
        m_trade_history[m_trade_count].open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        m_trade_history[m_trade_count].sl = PositionGetDouble(POSITION_SL);
        m_trade_history[m_trade_count].tp = PositionGetDouble(POSITION_TP);
        m_trade_history[m_trade_count].open_time = (datetime)PositionGetInteger(POSITION_TIME);
        m_trade_history[m_trade_count].comment = PositionGetString(POSITION_COMMENT);
        m_trade_history[m_trade_count].magic = (int)PositionGetInteger(POSITION_MAGIC);
        m_trade_history[m_trade_count].balance_before = AccountInfoDouble(ACCOUNT_BALANCE);
        m_trade_history[m_trade_count].equity_before = AccountInfoDouble(ACCOUNT_EQUITY);
        
        m_trade_count++;
    }
}

// Funções duplicadas removidas - implementações já existem na classe

void CPerformanceAnalyzer::CheckPerformanceAlerts()
{
    // Implementar verificação de alertas de performance
    // Alertas de drawdown, lucro, perdas consecutivas, etc.
}

//+------------------------------------------------------------------+
//| SALVAR RELATÓRIO                                                 |
//+------------------------------------------------------------------+

bool CPerformanceAnalyzer::SaveReport(string filename)
{
    if(!m_initialized)
    {
        LogError("PerformanceAnalyzer não inicializado");
        return false;
    }
    
    // Atualizar performance antes de salvar
    UpdatePerformance();
    
    // Usar ExportToHTML que já existe
    return ExportToHTML(filename);
}

//+------------------------------------------------------------------+
//| IMPLEMENTAÇÕES DOS MÉTODOS ABSTRATOS DA INTERFACE               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Obter expectativa                                                |
//+------------------------------------------------------------------+
double CPerformanceAnalyzer::GetExpectancy()
{
    if(m_performance.total_trades == 0)
        return 0.0;
        
    double win_rate = GetWinRate() / 100.0;
    double avg_win = GetAverageWinner();
    double avg_loss = MathAbs(GetAverageLoser());
    
    if(avg_loss == 0.0)
        return avg_win * win_rate;
        
    return (win_rate * avg_win) - ((1.0 - win_rate) * avg_loss);
}

//+------------------------------------------------------------------+
//| Obter retorno mensal                                             |
//+------------------------------------------------------------------+
double CPerformanceAnalyzer::GetMonthlyReturn()
{
    datetime current_time = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    // Primeiro dia do mês atual
    dt.day = 1;
    dt.hour = 0;
    dt.min = 0;
    dt.sec = 0;
    datetime month_start = StructToTime(dt);
    
    // Calcular retorno do mês atual
    double month_profit = 0.0;
    for(int i = 0; i < m_trade_count; i++)
    {
        if(m_trade_history[i].close_time >= month_start && m_trade_history[i].close_time <= current_time)
        {
            month_profit += m_trade_history[i].profit;
        }
    }
    
    double initial_balance = AccountInfoDouble(ACCOUNT_BALANCE) - m_performance.net_profit;
    if(initial_balance <= 0.0)
        return 0.0;
        
    return (month_profit / initial_balance) * 100.0;
}

//+------------------------------------------------------------------+
//| Obter retorno anualizado                                         |
//+------------------------------------------------------------------+
double CPerformanceAnalyzer::GetAnnualizedReturn()
{
    if(m_trade_count == 0)
        return 0.0;
        
    datetime first_trade = m_trade_history[0].open_time;
    datetime last_trade = m_trade_history[m_trade_count-1].close_time;
    
    double days = (double)(last_trade - first_trade) / 86400.0;
    if(days <= 0.0)
        return 0.0;
        
    double years = days / 365.25;
    if(years <= 0.0)
        return 0.0;
        
    double total_return = (m_performance.net_profit / m_performance.initial_balance) * 100.0;
    
    return MathPow(1.0 + (total_return / 100.0), 1.0 / years) - 1.0;
}

//+------------------------------------------------------------------+
//| Obter melhor mês                                                 |
//+------------------------------------------------------------------+
double CPerformanceAnalyzer::GetBestMonth()
{
    if(ArraySize(m_monthly_stats) == 0)
        return 0.0;
        
    double best = m_monthly_stats[0].net_profit;
    for(int i = 1; i < ArraySize(m_monthly_stats); i++)
    {
        if(m_monthly_stats[i].net_profit > best)
            best = m_monthly_stats[i].net_profit;
    }
    
    return best;
}

//+------------------------------------------------------------------+
//| Obter pior mês                                                   |
//+------------------------------------------------------------------+
double CPerformanceAnalyzer::GetWorstMonth()
{
    if(ArraySize(m_monthly_stats) == 0)
        return 0.0;
        
    double worst = m_monthly_stats[0].net_profit;
    for(int i = 1; i < ArraySize(m_monthly_stats); i++)
    {
        if(m_monthly_stats[i].net_profit < worst)
            worst = m_monthly_stats[i].net_profit;
    }
    
    return worst;
}

//+------------------------------------------------------------------+
//| Obter vitórias consecutivas                                      |
//+------------------------------------------------------------------+
int CPerformanceAnalyzer::GetConsecutiveWins()
{
    int current_wins = 0;
    int max_wins = 0;
    
    for(int i = 0; i < m_trade_count; i++)
    {
        if(m_trade_history[i].is_winner)
        {
            current_wins++;
            if(current_wins > max_wins)
                max_wins = current_wins;
        }
        else
        {
            current_wins = 0;
        }
    }
    
    return max_wins;
}

//+------------------------------------------------------------------+
//| Obter perdas consecutivas                                        |
//+------------------------------------------------------------------+
int CPerformanceAnalyzer::GetConsecutiveLosses()
{
    int current_losses = 0;
    int max_losses = 0;
    
    for(int i = 0; i < m_trade_count; i++)
    {
        if(!m_trade_history[i].is_winner)
        {
            current_losses++;
            if(current_losses > max_losses)
                max_losses = current_losses;
        }
        else
        {
            current_losses = 0;
        }
    }
    
    return max_losses;
}

//+------------------------------------------------------------------+
//| Definir benchmark                                                |
//+------------------------------------------------------------------+
bool CPerformanceAnalyzer::SetBenchmark(double benchmark_return)
{
    // Implementar lógica de benchmark
    // Por enquanto, apenas armazenar o valor
    static double s_benchmark_return = 0.0;
    s_benchmark_return = benchmark_return;
    
    LogInfo("Benchmark definido: " + DoubleToString(benchmark_return, 4) + "%");
    return true;
}

//+------------------------------------------------------------------+
//| Definir taxa livre de risco                                      |
//+------------------------------------------------------------------+
bool CPerformanceAnalyzer::SetRiskFreeRate(double rate)
{
    // Implementar lógica de taxa livre de risco
    // Por enquanto, apenas armazenar o valor
    static double s_risk_free_rate = 0.0;
    s_risk_free_rate = rate;
    
    LogInfo("Taxa livre de risco definida: " + DoubleToString(rate, 4) + "%");
    return true;
}

//+------------------------------------------------------------------+
//| Definir período de análise                                       |
//+------------------------------------------------------------------+
bool CPerformanceAnalyzer::SetAnalysisPeriod(datetime start, datetime end)
{
    if(start >= end)
    {
        LogError("Período de análise inválido: início >= fim");
        return false;
    }
    
    // Implementar lógica de período de análise
    // Por enquanto, apenas validar e logar
    static datetime s_analysis_start = 0;
    static datetime s_analysis_end = 0;
    
    s_analysis_start = start;
    s_analysis_end = end;
    
    LogInfo("Período de análise definido: " + TimeToString(start) + " - " + TimeToString(end));
    return true;
}

//+------------------------------------------------------------------+
//| INSTÂNCIA GLOBAL                                                 |
//+------------------------------------------------------------------+

CPerformanceAnalyzer* g_performance = NULL;

//+------------------------------------------------------------------+
//| FIM DO ARQUIVO                                                   |
//+------------------------------------------------------------------+
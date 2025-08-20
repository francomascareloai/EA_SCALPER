//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                        Copyright 2024, TradeDev_Master Systems  |
//|                                   https://github.com/tradedev    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, TradeDev_Master Systems"
#property link      "https://github.com/tradedev"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| FTMO Compliance Risk Manager Class                               |
//| Implementa proteções obrigatórias para conformidade FTMO        |
//+------------------------------------------------------------------+
class CFTMORiskManager
{
private:
    // Configurações FTMO
    double            m_initial_balance;        // Saldo inicial da conta
    double            m_max_daily_loss_pct;     // % máximo de perda diária (5%)
    double            m_max_total_loss_pct;     // % máximo de perda total (10%)
    double            m_risk_per_trade_pct;     // % de risco por trade (1-2%)
    
    // Controles de estado
    datetime          m_last_reset_date;        // Data do último reset diário
    double            m_daily_start_equity;     // Equity no início do dia
    double            m_daily_loss_current;     // Perda atual do dia
    bool              m_trading_allowed;        // Flag de trading permitido
    
    // Configurações de segurança
    bool              m_include_swap_commission; // Incluir swap/comissão no cálculo
    int               m_security_zone_minutes;   // Zona de segurança em minutos (5min)
    bool              m_close_positions_on_limit; // Fechar posições ao atingir limite
    
    CTrade            m_trade;                  // Objeto de trading
    
public:
    //+------------------------------------------------------------------+
    //| Construtor                                                       |
    //+------------------------------------------------------------------+
    CFTMORiskManager(double initial_balance = 0.0)
    {
        // Configurações padrão FTMO
        m_initial_balance = (initial_balance > 0) ? initial_balance : AccountInfoDouble(ACCOUNT_BALANCE);
        m_max_daily_loss_pct = 5.0;      // 5% perda diária máxima
        m_max_total_loss_pct = 10.0;     // 10% perda total máxima
        m_risk_per_trade_pct = 1.0;      // 1% risco por trade
        
        // Configurações de segurança
        m_include_swap_commission = true;
        m_security_zone_minutes = 5;
        m_close_positions_on_limit = true;
        
        // Inicialização
        m_last_reset_date = 0;
        m_trading_allowed = true;
        
        ResetDailyCounters();
        
        Print("[FTMO Risk Manager] Inicializado - Saldo inicial: ", m_initial_balance);
    }
    
    //+------------------------------------------------------------------+
    //| Reset dos contadores diários                                    |
    //+------------------------------------------------------------------+
    void ResetDailyCounters()
    {
        datetime current_date = TimeCurrent();
        MqlDateTime dt;
        TimeToStruct(current_date, dt);
        dt.hour = 0; dt.min = 0; dt.sec = 0;
        datetime day_start = StructToTime(dt);
        
        if(m_last_reset_date != day_start)
        {
            m_last_reset_date = day_start;
            m_daily_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
            m_daily_loss_current = 0.0;
            m_trading_allowed = true;
            
            Print("[FTMO Risk Manager] Reset diário - Equity inicial: ", m_daily_start_equity);
        }
    }
    
    //+------------------------------------------------------------------+
    //| Verifica se o trading está permitido                            |
    //+------------------------------------------------------------------+
    bool IsTradingAllowed()
    {
        ResetDailyCounters();
        
        // Verifica limite de perda diária
        if(!CheckDailyLossLimit())
        {
            m_trading_allowed = false;
            return false;
        }
        
        // Verifica limite de perda total
        if(!CheckTotalLossLimit())
        {
            m_trading_allowed = false;
            return false;
        }
        
        // Verifica zona de segurança (últimos 5 minutos do dia)
        if(IsInSecurityZone())
        {
            Print("[FTMO Risk Manager] Zona de segurança ativa - Trading bloqueado");
            return false;
        }
        
        return m_trading_allowed;
    }
    
    //+------------------------------------------------------------------+
    //| Calcula o tamanho da posição baseado no risco                   |
    //+------------------------------------------------------------------+
    double CalculatePositionSize(double entry_price, double stop_loss, string symbol = "")
    {
        if(symbol == "") symbol = _Symbol;
        
        if(!IsTradingAllowed())
        {
            Print("[FTMO Risk Manager] Trading não permitido - Posição rejeitada");
            return 0.0;
        }
        
        if(entry_price <= 0 || stop_loss <= 0 || MathAbs(entry_price - stop_loss) < SymbolInfoDouble(symbol, SYMBOL_POINT))
        {
            Print("[FTMO Risk Manager] Parâmetros inválidos para cálculo de posição");
            return 0.0;
        }
        
        // Calcula o risco em dinheiro
        double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
        double risk_money = account_equity * m_risk_per_trade_pct / 100.0;
        
        // Calcula a distância do stop loss em pontos
        double stop_distance = MathAbs(entry_price - stop_loss);
        
        // Obtém informações do símbolo
        double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
        double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
        double volume_min = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
        double volume_max = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
        double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
        
        if(tick_value <= 0 || tick_size <= 0)
        {
            Print("[FTMO Risk Manager] Erro ao obter informações do símbolo: ", symbol);
            return 0.0;
        }
        
        // Calcula o tamanho da posição
        double position_size = risk_money / (stop_distance * tick_value / tick_size);
        
        // Normaliza o tamanho da posição
        position_size = MathMax(volume_min, MathMin(volume_max, position_size));
        position_size = MathRound(position_size / volume_step) * volume_step;
        
        // Verifica se a posição não excede os limites de margem
        double required_margin;
        if(!OrderCalcMargin(ORDER_TYPE_BUY, symbol, position_size, entry_price, required_margin))
        {
            Print("[FTMO Risk Manager] Erro ao calcular margem necessária");
            return 0.0;
        }
        
        double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        if(required_margin > free_margin * 0.8) // Usa máximo 80% da margem livre
        {
            position_size = position_size * (free_margin * 0.8) / required_margin;
            position_size = MathRound(position_size / volume_step) * volume_step;
        }
        
        Print("[FTMO Risk Manager] Posição calculada: ", position_size, " lotes para risco de ", risk_money, " USD");
        return position_size;
    }
    
    //+------------------------------------------------------------------+
    //| Verifica limite de perda diária                                 |
    //+------------------------------------------------------------------+
    bool CheckDailyLossLimit()
    {
        double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
        double current_profit = AccountInfoDouble(ACCOUNT_PROFIT); // Floating P&L
        
        // Calcula perda do dia (incluindo floating P&L se configurado)
        double daily_loss = m_daily_start_equity - current_equity;
        if(m_include_swap_commission)
        {
            // Inclui swap e comissão no cálculo
            daily_loss += current_profit; // Ajusta pela floating P&L
        }
        
        double max_daily_loss = m_initial_balance * m_max_daily_loss_pct / 100.0;
        
        if(daily_loss >= max_daily_loss)
        {
            Print("[FTMO Risk Manager] ALERTA: Limite de perda diária atingido! Perda: ", daily_loss, " / Limite: ", max_daily_loss);
            
            if(m_close_positions_on_limit)
            {
                CloseAllPositions();
            }
            
            return false;
        }
        
        // Alerta quando próximo do limite (80%)
        if(daily_loss >= max_daily_loss * 0.8)
        {
            Print("[FTMO Risk Manager] ATENÇÃO: Próximo do limite diário! Perda: ", daily_loss, " / Limite: ", max_daily_loss);
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Verifica limite de perda total                                  |
    //+------------------------------------------------------------------+
    bool CheckTotalLossLimit()
    {
        double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
        double total_loss = m_initial_balance - current_equity;
        double max_total_loss = m_initial_balance * m_max_total_loss_pct / 100.0;
        
        if(total_loss >= max_total_loss)
        {
            Print("[FTMO Risk Manager] ALERTA: Limite de perda total atingido! Perda: ", total_loss, " / Limite: ", max_total_loss);
            
            if(m_close_positions_on_limit)
            {
                CloseAllPositions();
            }
            
            return false;
        }
        
        // Alerta quando próximo do limite (90%)
        if(current_equity <= m_initial_balance * 0.92) // 8% de perda
        {
            Print("[FTMO Risk Manager] ATENÇÃO: Próximo do limite total! Equity: ", current_equity, " / Limite: ", m_initial_balance * 0.9);
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Verifica se está na zona de segurança                           |
    //+------------------------------------------------------------------+
    bool IsInSecurityZone()
    {
        datetime current_time = TimeCurrent();
        MqlDateTime dt;
        TimeToStruct(current_time, dt);
        
        // Verifica se está nos últimos minutos do dia (zona de segurança)
        int minutes_to_midnight = (23 - dt.hour) * 60 + (59 - dt.min);
        
        return (minutes_to_midnight <= m_security_zone_minutes);
    }
    
    //+------------------------------------------------------------------+
    //| Fecha todas as posições abertas                                 |
    //+------------------------------------------------------------------+
    void CloseAllPositions()
    {
        Print("[FTMO Risk Manager] Fechando todas as posições por limite de risco!");
        
        for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
            ulong ticket = PositionGetTicket(i);
            if(ticket > 0)
            {
                if(!m_trade.PositionClose(ticket))
                {
                    Print("[FTMO Risk Manager] Erro ao fechar posição: ", ticket, " - ", m_trade.ResultRetcodeDescription());
                }
                else
                {
                    Print("[FTMO Risk Manager] Posição fechada: ", ticket);
                }
            }
        }
    }
    
    //+------------------------------------------------------------------+
    //| Getters e Setters                                               |
    //+------------------------------------------------------------------+
    void SetRiskPerTrade(double risk_pct) { m_risk_per_trade_pct = MathMax(0.1, MathMin(5.0, risk_pct)); }
    void SetMaxDailyLoss(double loss_pct) { m_max_daily_loss_pct = MathMax(1.0, MathMin(10.0, loss_pct)); }
    void SetMaxTotalLoss(double loss_pct) { m_max_total_loss_pct = MathMax(5.0, MathMin(20.0, loss_pct)); }
    void SetIncludeSwapCommission(bool include) { m_include_swap_commission = include; }
    void SetClosePositionsOnLimit(bool close) { m_close_positions_on_limit = close; }
    
    double GetRiskPerTrade() const { return m_risk_per_trade_pct; }
    double GetMaxDailyLoss() const { return m_max_daily_loss_pct; }
    double GetMaxTotalLoss() const { return m_max_total_loss_pct; }
    double GetDailyLossCurrent() const { return m_daily_loss_current; }
    bool GetTradingAllowed() const { return m_trading_allowed; }
    
    //+------------------------------------------------------------------+
    //| Relatório de status                                             |
    //+------------------------------------------------------------------+
    string GetStatusReport()
    {
        string report = "\n=== FTMO Risk Manager Status ===\n";
        report += "Saldo Inicial: " + DoubleToString(m_initial_balance, 2) + "\n";
        report += "Equity Atual: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + "\n";
        report += "Equity Início Dia: " + DoubleToString(m_daily_start_equity, 2) + "\n";
        report += "Perda Diária: " + DoubleToString(m_daily_start_equity - AccountInfoDouble(ACCOUNT_EQUITY), 2) + "\n";
        report += "Limite Diário: " + DoubleToString(m_initial_balance * m_max_daily_loss_pct / 100.0, 2) + "\n";
        report += "Limite Total: " + DoubleToString(m_initial_balance * m_max_total_loss_pct / 100.0, 2) + "\n";
        report += "Trading Permitido: " + (m_trading_allowed ? "SIM" : "NÃO") + "\n";
        report += "Zona Segurança: " + (IsInSecurityZone() ? "ATIVA" : "INATIVA") + "\n";
        report += "================================\n";
        
        return report;
    }
};

//+------------------------------------------------------------------+
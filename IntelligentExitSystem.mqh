//+------------------------------------------------------------------+
//|                                        IntelligentExitSystem.mqh |
//|                                    TradeDev_Master - Elite System |
//|                                 Sistema de Saída Inteligente FTMO |
//+------------------------------------------------------------------+
#property copyright "TradeDev_Master"
#property version   "1.00"
#property strict

#include "RiskManager.mqh"
#include "AdvancedFilters.mqh"

//+------------------------------------------------------------------+
//| Enumerações para tipos de trailing stop                          |
//+------------------------------------------------------------------+
enum ENUM_TRAILING_TYPE
{
   TRAILING_FIXED,        // Trailing stop fixo
   TRAILING_PERCENT,      // Trailing stop percentual
   TRAILING_ATR,          // Trailing stop baseado em ATR
   TRAILING_MA,           // Trailing stop baseado em Moving Average
   TRAILING_PARABOLIC,    // Trailing stop baseado em Parabolic SAR
   TRAILING_CANDLE_HL     // Trailing stop baseado em High/Low das velas
};

//+------------------------------------------------------------------+
//| Enumerações para tipos de take profit parcial                    |
//+------------------------------------------------------------------+
enum ENUM_PARTIAL_TP_MODE
{
   PARTIAL_TP_DISABLED,   // Take profit parcial desabilitado
   PARTIAL_TP_FIXED,      // Take profit parcial fixo
   PARTIAL_TP_PERCENT,    // Take profit parcial percentual
   PARTIAL_TP_ATR         // Take profit parcial baseado em ATR
};

//+------------------------------------------------------------------+
//| Estrutura para configurações de trailing stop                    |
//+------------------------------------------------------------------+
struct STrailingConfig
{
   ENUM_TRAILING_TYPE type;           // Tipo de trailing stop
   bool               enabled;        // Habilitado/Desabilitado
   double             start_points;   // Pontos para iniciar trailing
   double             step_points;    // Passo do trailing em pontos
   double             distance_points;// Distância do trailing em pontos
   double             atr_multiplier; // Multiplicador ATR
   int                atr_period;     // Período ATR
   int                ma_period;      // Período MA
   ENUM_MA_METHOD     ma_method;      // Método MA
   ENUM_APPLIED_PRICE ma_price;       // Preço aplicado MA
   bool               virtual_mode;   // Modo virtual (não envia para broker)
   double             close_percent;  // Percentual de fechamento (0-100)
};

//+------------------------------------------------------------------+
//| Estrutura para configurações de breakeven                        |
//+------------------------------------------------------------------+
struct SBreakevenConfig
{
   bool   enabled;           // Habilitado/Desabilitado
   double trigger_points;    // Pontos para ativar breakeven
   double offset_points;     // Offset do breakeven em pontos
   bool   atr_based;         // Baseado em ATR
   double atr_multiplier;    // Multiplicador ATR
   int    atr_period;        // Período ATR
};

//+------------------------------------------------------------------+
//| Estrutura para configurações de take profit parcial             |
//+------------------------------------------------------------------+
struct SPartialTPConfig
{
   ENUM_PARTIAL_TP_MODE mode;         // Modo de take profit parcial
   bool                 enabled;      // Habilitado/Desabilitado
   double               level1_points;// Nível 1 em pontos
   double               level1_percent;// Percentual de fechamento nível 1
   double               level2_points;// Nível 2 em pontos
   double               level2_percent;// Percentual de fechamento nível 2
   double               level3_points;// Nível 3 em pontos
   double               level3_percent;// Percentual de fechamento nível 3
   double               atr_multiplier1;// Multiplicador ATR nível 1
   double               atr_multiplier2;// Multiplicador ATR nível 2
   double               atr_multiplier3;// Multiplicador ATR nível 3
   int                  atr_period;   // Período ATR
};

//+------------------------------------------------------------------+
//| Estrutura para dados de posição                                  |
//+------------------------------------------------------------------+
struct SPositionData
{
   ulong  ticket;           // Ticket da posição
   string symbol;           // Símbolo
   int    type;             // Tipo (POSITION_TYPE_BUY/SELL)
   double volume;           // Volume
   double open_price;       // Preço de abertura
   double current_sl;       // Stop Loss atual
   double current_tp;       // Take Profit atual
   double profit;           // Lucro atual
   double profit_points;    // Lucro em pontos
   datetime open_time;      // Tempo de abertura
   bool   breakeven_set;    // Breakeven já definido
   bool   partial_tp1_hit;  // Take profit parcial 1 atingido
   bool   partial_tp2_hit;  // Take profit parcial 2 atingido
   bool   partial_tp3_hit;  // Take profit parcial 3 atingido
   double last_trailing_sl; // Último trailing stop loss
   double max_profit_points;// Máximo lucro em pontos
};

//+------------------------------------------------------------------+
//| Classe principal do sistema de saída inteligente                 |
//+------------------------------------------------------------------+
class CIntelligentExitSystem
{
private:
   // Configurações
   STrailingConfig    m_trailing_config;
   SBreakevenConfig   m_breakeven_config;
   SPartialTPConfig   m_partial_tp_config;
   
   // Dependências
   CRiskManager*      m_risk_manager;
   CAdvancedFilters*  m_filters;
   
   // Dados internos
   SPositionData      m_positions[];
   int                m_positions_count;
   
   // Handles de indicadores
   int                m_atr_handle;
   int                m_ma_handle;
   int                m_sar_handle;
   
   // Buffers de indicadores
   double             m_atr_buffer[];
   double             m_ma_buffer[];
   double             m_sar_buffer[];
   
   // Métodos privados
   bool               UpdatePositionData();
   bool               CalculateTrailingLevel(SPositionData &position, double &new_sl);
   bool               CheckBreakevenCondition(SPositionData &position);
   bool               CheckPartialTPCondition(SPositionData &position, int level);
   bool               ModifyPosition(ulong ticket, double sl, double tp);
   bool               ClosePositionPartial(ulong ticket, double volume_percent);
   double             GetATRValue(int shift = 0);
   double             GetMAValue(int shift = 0);
   double             GetSARValue(int shift = 0);
   double             GetCandleHigh(int shift = 1);
   double             GetCandleLow(int shift = 1);
   bool               IsValidStopLevel(string symbol, int position_type, double price);
   double             NormalizeStopLevel(string symbol, double price);
   void               LogTrailingAction(string action, ulong ticket, double old_sl, double new_sl);
   
public:
   // Construtor e destrutor
                      CIntelligentExitSystem();
                     ~CIntelligentExitSystem();
   
   // Métodos de inicialização
   bool               Initialize(CRiskManager* risk_manager, CAdvancedFilters* filters);
   void               Deinitialize();
   
   // Configuração do sistema
   void               SetTrailingConfig(const STrailingConfig &config);
   void               SetBreakevenConfig(const SBreakevenConfig &config);
   void               SetPartialTPConfig(const SPartialTPConfig &config);
   
   // Métodos principais
   bool               ProcessExitSignals();
   bool               UpdateTrailingStops();
   bool               ProcessBreakeven();
   bool               ProcessPartialTakeProfit();
   
   // Métodos de configuração rápida
   void               SetSimpleTrailing(double start_points, double step_points, double distance_points);
   void               SetATRTrailing(double start_atr_mult, double step_atr_mult, double distance_atr_mult, int period = 14);
   void               SetBreakeven(double trigger_points, double offset_points = 0);
   void               SetPartialTP(double level1_points, double level1_percent, 
                                   double level2_points = 0, double level2_percent = 0,
                                   double level3_points = 0, double level3_percent = 0);
   
   // Métodos de status e relatórios
   string             GetExitSystemStatus();
   void               PrintExitReport();
   int                GetManagedPositionsCount() { return m_positions_count; }
   
   // Métodos de validação
   bool               ValidateTrailingConfig();
   bool               ValidateBreakevenConfig();
   bool               ValidatePartialTPConfig();
};

//+------------------------------------------------------------------+
//| Construtor                                                        |
//+------------------------------------------------------------------+
CIntelligentExitSystem::CIntelligentExitSystem()
{
   m_risk_manager = NULL;
   m_filters = NULL;
   m_positions_count = 0;
   
   m_atr_handle = INVALID_HANDLE;
   m_ma_handle = INVALID_HANDLE;
   m_sar_handle = INVALID_HANDLE;
   
   // Configurações padrão
   ZeroMemory(m_trailing_config);
   m_trailing_config.type = TRAILING_FIXED;
   m_trailing_config.enabled = false;
   m_trailing_config.start_points = 100;
   m_trailing_config.step_points = 50;
   m_trailing_config.distance_points = 50;
   m_trailing_config.virtual_mode = false;
   m_trailing_config.close_percent = 100;
   
   ZeroMemory(m_breakeven_config);
   m_breakeven_config.enabled = false;
   m_breakeven_config.trigger_points = 100;
   m_breakeven_config.offset_points = 10;
   
   ZeroMemory(m_partial_tp_config);
   m_partial_tp_config.mode = PARTIAL_TP_DISABLED;
   m_partial_tp_config.enabled = false;
}

//+------------------------------------------------------------------+
//| Destrutor                                                         |
//+------------------------------------------------------------------+
CIntelligentExitSystem::~CIntelligentExitSystem()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Inicialização do sistema                                          |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::Initialize(CRiskManager* risk_manager, CAdvancedFilters* filters)
{
   if(risk_manager == NULL)
   {
      Print("[EXIT_SYSTEM] Erro: Risk Manager não fornecido");
      return false;
   }
   
   m_risk_manager = risk_manager;
   m_filters = filters;
   
   // Criar handles de indicadores
   m_atr_handle = iATR(_Symbol, PERIOD_CURRENT, 14);
   if(m_atr_handle == INVALID_HANDLE)
   {
      Print("[EXIT_SYSTEM] Erro ao criar handle ATR");
      return false;
   }
   
   m_ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
   if(m_ma_handle == INVALID_HANDLE)
   {
      Print("[EXIT_SYSTEM] Erro ao criar handle MA");
      return false;
   }
   
   m_sar_handle = iSAR(_Symbol, PERIOD_CURRENT, 0.02, 0.2);
   if(m_sar_handle == INVALID_HANDLE)
   {
      Print("[EXIT_SYSTEM] Erro ao criar handle SAR");
      return false;
   }
   
   ArraySetAsSeries(m_atr_buffer, true);
   ArraySetAsSeries(m_ma_buffer, true);
   ArraySetAsSeries(m_sar_buffer, true);
   
   Print("[EXIT_SYSTEM] Sistema de saída inteligente inicializado com sucesso");
   return true;
}

//+------------------------------------------------------------------+
//| Desinicialização do sistema                                       |
//+------------------------------------------------------------------+
void CIntelligentExitSystem::Deinitialize()
{
   if(m_atr_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atr_handle);
      m_atr_handle = INVALID_HANDLE;
   }
   
   if(m_ma_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_ma_handle);
      m_ma_handle = INVALID_HANDLE;
   }
   
   if(m_sar_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_sar_handle);
      m_sar_handle = INVALID_HANDLE;
   }
   
   ArrayFree(m_positions);
   m_positions_count = 0;
   
   Print("[EXIT_SYSTEM] Sistema desinicializado");
}

//+------------------------------------------------------------------+
//| Processar sinais de saída                                         |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::ProcessExitSignals()
{
   if(!UpdatePositionData())
      return false;
   
   bool result = true;
   
   // Processar breakeven
   if(m_breakeven_config.enabled)
   {
      if(!ProcessBreakeven())
         result = false;
   }
   
   // Processar take profit parcial
   if(m_partial_tp_config.enabled)
   {
      if(!ProcessPartialTakeProfit())
         result = false;
   }
   
   // Processar trailing stops
   if(m_trailing_config.enabled)
   {
      if(!UpdateTrailingStops())
         result = false;
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Atualizar dados das posições                                      |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::UpdatePositionData()
{
   int total_positions = PositionsTotal();
   ArrayResize(m_positions, total_positions);
   m_positions_count = 0;
   
   for(int i = 0; i < total_positions; i++)
   {
      if(PositionSelectByIndex(i))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            SPositionData pos;
            pos.ticket = PositionGetInteger(POSITION_TICKET);
            pos.symbol = PositionGetString(POSITION_SYMBOL);
            pos.type = (int)PositionGetInteger(POSITION_TYPE);
            pos.volume = PositionGetDouble(POSITION_VOLUME);
            pos.open_price = PositionGetDouble(POSITION_PRICE_OPEN);
            pos.current_sl = PositionGetDouble(POSITION_SL);
            pos.current_tp = PositionGetDouble(POSITION_TP);
            pos.profit = PositionGetDouble(POSITION_PROFIT);
            pos.open_time = (datetime)PositionGetInteger(POSITION_TIME);
            
            // Calcular lucro em pontos
            double current_price = (pos.type == POSITION_TYPE_BUY) ? 
                                   SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                                   SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            
            if(pos.type == POSITION_TYPE_BUY)
               pos.profit_points = (current_price - pos.open_price) / _Point;
            else
               pos.profit_points = (pos.open_price - current_price) / _Point;
            
            // Atualizar máximo lucro
            if(pos.profit_points > pos.max_profit_points)
               pos.max_profit_points = pos.profit_points;
            
            m_positions[m_positions_count] = pos;
            m_positions_count++;
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Processar breakeven                                               |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::ProcessBreakeven()
{
   for(int i = 0; i < m_positions_count; i++)
   {
      if(CheckBreakevenCondition(m_positions[i]) && !m_positions[i].breakeven_set)
      {
         double breakeven_level;
         
         if(m_breakeven_config.atr_based)
         {
            double atr = GetATRValue();
            double trigger_distance = atr * m_breakeven_config.atr_multiplier;
            
            if(MathAbs(m_positions[i].profit_points) >= trigger_distance / _Point)
            {
               breakeven_level = m_positions[i].open_price + 
                               (m_positions[i].type == POSITION_TYPE_BUY ? 
                                m_breakeven_config.offset_points * _Point : 
                                -m_breakeven_config.offset_points * _Point);
            }
            else
               continue;
         }
         else
         {
            if(m_positions[i].profit_points >= m_breakeven_config.trigger_points)
            {
               breakeven_level = m_positions[i].open_price + 
                               (m_positions[i].type == POSITION_TYPE_BUY ? 
                                m_breakeven_config.offset_points * _Point : 
                                -m_breakeven_config.offset_points * _Point);
            }
            else
               continue;
         }
         
         breakeven_level = NormalizeStopLevel(_Symbol, breakeven_level);
         
         if(IsValidStopLevel(_Symbol, m_positions[i].type, breakeven_level))
         {
            if(ModifyPosition(m_positions[i].ticket, breakeven_level, m_positions[i].current_tp))
            {
               m_positions[i].breakeven_set = true;
               LogTrailingAction("BREAKEVEN", m_positions[i].ticket, 
                               m_positions[i].current_sl, breakeven_level);
            }
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Processar take profit parcial                                     |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::ProcessPartialTakeProfit()
{
   for(int i = 0; i < m_positions_count; i++)
   {
      // Verificar nível 1
      if(!m_positions[i].partial_tp1_hit && CheckPartialTPCondition(m_positions[i], 1))
      {
         if(ClosePositionPartial(m_positions[i].ticket, m_partial_tp_config.level1_percent))
         {
            m_positions[i].partial_tp1_hit = true;
            Print("[EXIT_SYSTEM] Take Profit Parcial 1 executado - Ticket: ", m_positions[i].ticket);
         }
      }
      
      // Verificar nível 2
      if(!m_positions[i].partial_tp2_hit && CheckPartialTPCondition(m_positions[i], 2))
      {
         if(ClosePositionPartial(m_positions[i].ticket, m_partial_tp_config.level2_percent))
         {
            m_positions[i].partial_tp2_hit = true;
            Print("[EXIT_SYSTEM] Take Profit Parcial 2 executado - Ticket: ", m_positions[i].ticket);
         }
      }
      
      // Verificar nível 3
      if(!m_positions[i].partial_tp3_hit && CheckPartialTPCondition(m_positions[i], 3))
      {
         if(ClosePositionPartial(m_positions[i].ticket, m_partial_tp_config.level3_percent))
         {
            m_positions[i].partial_tp3_hit = true;
            Print("[EXIT_SYSTEM] Take Profit Parcial 3 executado - Ticket: ", m_positions[i].ticket);
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Atualizar trailing stops                                          |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::UpdateTrailingStops()
{
   for(int i = 0; i < m_positions_count; i++)
   {
      if(m_positions[i].profit_points >= m_trailing_config.start_points)
      {
         double new_sl;
         if(CalculateTrailingLevel(m_positions[i], new_sl))
         {
            new_sl = NormalizeStopLevel(_Symbol, new_sl);
            
            if(IsValidStopLevel(_Symbol, m_positions[i].type, new_sl))
            {
               // Verificar se o novo SL é melhor que o atual
               bool should_update = false;
               
               if(m_positions[i].type == POSITION_TYPE_BUY)
               {
                  should_update = (new_sl > m_positions[i].current_sl) || 
                                (m_positions[i].current_sl == 0);
               }
               else
               {
                  should_update = (new_sl < m_positions[i].current_sl) || 
                                (m_positions[i].current_sl == 0);
               }
               
               if(should_update)
               {
                  if(m_trailing_config.virtual_mode)
                  {
                     // Modo virtual - fechar posição quando preço atingir nível
                     double current_price = (m_positions[i].type == POSITION_TYPE_BUY) ? 
                                          SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                                          SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                     
                     bool should_close = false;
                     if(m_positions[i].type == POSITION_TYPE_BUY && current_price <= new_sl)
                        should_close = true;
                     else if(m_positions[i].type == POSITION_TYPE_SELL && current_price >= new_sl)
                        should_close = true;
                     
                     if(should_close)
                     {
                        ClosePositionPartial(m_positions[i].ticket, m_trailing_config.close_percent);
                        LogTrailingAction("VIRTUAL_CLOSE", m_positions[i].ticket, 
                                        m_positions[i].current_sl, new_sl);
                     }
                  }
                  else
                  {
                     // Modo real - modificar stop loss
                     if(ModifyPosition(m_positions[i].ticket, new_sl, m_positions[i].current_tp))
                     {
                        LogTrailingAction("TRAILING", m_positions[i].ticket, 
                                        m_positions[i].current_sl, new_sl);
                        m_positions[i].last_trailing_sl = new_sl;
                     }
                  }
               }
            }
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Calcular nível de trailing stop                                   |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::CalculateTrailingLevel(SPositionData &position, double &new_sl)
{
   double current_price = (position.type == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   switch(m_trailing_config.type)
   {
      case TRAILING_FIXED:
         if(position.type == POSITION_TYPE_BUY)
            new_sl = current_price - m_trailing_config.distance_points * _Point;
         else
            new_sl = current_price + m_trailing_config.distance_points * _Point;
         break;
         
      case TRAILING_PERCENT:
         {
            double profit_distance = MathAbs(current_price - position.open_price);
            double trailing_distance = profit_distance * (m_trailing_config.distance_points / 100.0);
            
            if(position.type == POSITION_TYPE_BUY)
               new_sl = current_price - trailing_distance;
            else
               new_sl = current_price + trailing_distance;
         }
         break;
         
      case TRAILING_ATR:
         {
            double atr = GetATRValue();
            double trailing_distance = atr * m_trailing_config.atr_multiplier;
            
            if(position.type == POSITION_TYPE_BUY)
               new_sl = current_price - trailing_distance;
            else
               new_sl = current_price + trailing_distance;
         }
         break;
         
      case TRAILING_MA:
         {
            double ma_value = GetMAValue();
            if(position.type == POSITION_TYPE_BUY)
               new_sl = ma_value - m_trailing_config.distance_points * _Point;
            else
               new_sl = ma_value + m_trailing_config.distance_points * _Point;
         }
         break;
         
      case TRAILING_PARABOLIC:
         {
            double sar_value = GetSARValue();
            new_sl = sar_value;
         }
         break;
         
      case TRAILING_CANDLE_HL:
         {
            if(position.type == POSITION_TYPE_BUY)
               new_sl = GetCandleLow(1) - m_trailing_config.distance_points * _Point;
            else
               new_sl = GetCandleHigh(1) + m_trailing_config.distance_points * _Point;
         }
         break;
         
      default:
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Verificar condição de breakeven                                   |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::CheckBreakevenCondition(SPositionData &position)
{
   if(m_breakeven_config.atr_based)
   {
      double atr = GetATRValue();
      double trigger_distance = atr * m_breakeven_config.atr_multiplier;
      return (position.profit_points >= trigger_distance / _Point);
   }
   else
   {
      return (position.profit_points >= m_breakeven_config.trigger_points);
   }
}

//+------------------------------------------------------------------+
//| Verificar condição de take profit parcial                         |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::CheckPartialTPCondition(SPositionData &position, int level)
{
   double target_points = 0;
   
   switch(level)
   {
      case 1:
         if(m_partial_tp_config.mode == PARTIAL_TP_ATR)
         {
            double atr = GetATRValue();
            target_points = (atr * m_partial_tp_config.atr_multiplier1) / _Point;
         }
         else
            target_points = m_partial_tp_config.level1_points;
         break;
         
      case 2:
         if(m_partial_tp_config.mode == PARTIAL_TP_ATR)
         {
            double atr = GetATRValue();
            target_points = (atr * m_partial_tp_config.atr_multiplier2) / _Point;
         }
         else
            target_points = m_partial_tp_config.level2_points;
         break;
         
      case 3:
         if(m_partial_tp_config.mode == PARTIAL_TP_ATR)
         {
            double atr = GetATRValue();
            target_points = (atr * m_partial_tp_config.atr_multiplier3) / _Point;
         }
         else
            target_points = m_partial_tp_config.level3_points;
         break;
         
      default:
         return false;
   }
   
   return (position.profit_points >= target_points);
}

//+------------------------------------------------------------------+
//| Modificar posição                                                 |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::ModifyPosition(ulong ticket, double sl, double tp)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_SLTP;
   request.position = ticket;
   request.sl = sl;
   request.tp = tp;
   
   if(!OrderSend(request, result))
   {
      Print("[EXIT_SYSTEM] Erro ao modificar posição ", ticket, ": ", result.comment);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Fechar posição parcialmente                                       |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::ClosePositionPartial(ulong ticket, double volume_percent)
{
   if(!PositionSelectByTicket(ticket))
      return false;
   
   double current_volume = PositionGetDouble(POSITION_VOLUME);
   double close_volume = current_volume * (volume_percent / 100.0);
   
   // Normalizar volume
   double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volume_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   close_volume = MathFloor(close_volume / volume_step) * volume_step;
   
   if(close_volume < min_volume)
      return false;
   
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.position = ticket;
   request.symbol = _Symbol;
   request.volume = close_volume;
   request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                  ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   request.price = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                   SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                   SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   request.deviation = 10;
   
   if(!OrderSend(request, result))
   {
      Print("[EXIT_SYSTEM] Erro ao fechar posição parcialmente ", ticket, ": ", result.comment);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Obter valor ATR                                                   |
//+------------------------------------------------------------------+
double CIntelligentExitSystem::GetATRValue(int shift = 0)
{
   if(CopyBuffer(m_atr_handle, 0, shift, 1, m_atr_buffer) <= 0)
      return 0;
   
   return m_atr_buffer[0];
}

//+------------------------------------------------------------------+
//| Obter valor MA                                                    |
//+------------------------------------------------------------------+
double CIntelligentExitSystem::GetMAValue(int shift = 0)
{
   if(CopyBuffer(m_ma_handle, 0, shift, 1, m_ma_buffer) <= 0)
      return 0;
   
   return m_ma_buffer[0];
}

//+------------------------------------------------------------------+
//| Obter valor SAR                                                   |
//+------------------------------------------------------------------+
double CIntelligentExitSystem::GetSARValue(int shift = 0)
{
   if(CopyBuffer(m_sar_handle, 0, shift, 1, m_sar_buffer) <= 0)
      return 0;
   
   return m_sar_buffer[0];
}

//+------------------------------------------------------------------+
//| Obter máxima da vela                                              |
//+------------------------------------------------------------------+
double CIntelligentExitSystem::GetCandleHigh(int shift = 1)
{
   double high[];
   ArraySetAsSeries(high, true);
   
   if(CopyHigh(_Symbol, PERIOD_CURRENT, shift, 1, high) <= 0)
      return 0;
   
   return high[0];
}

//+------------------------------------------------------------------+
//| Obter mínima da vela                                              |
//+------------------------------------------------------------------+
double CIntelligentExitSystem::GetCandleLow(int shift = 1)
{
   double low[];
   ArraySetAsSeries(low, true);
   
   if(CopyLow(_Symbol, PERIOD_CURRENT, shift, 1, low) <= 0)
      return 0;
   
   return low[0];
}

//+------------------------------------------------------------------+
//| Verificar se nível de stop é válido                              |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::IsValidStopLevel(string symbol, int position_type, double price)
{
   double current_price = (position_type == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(symbol, SYMBOL_ASK);
   
   double stops_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   
   if(position_type == POSITION_TYPE_BUY)
   {
      return (price < current_price - stops_level);
   }
   else
   {
      return (price > current_price + stops_level);
   }
}

//+------------------------------------------------------------------+
//| Normalizar nível de stop                                          |
//+------------------------------------------------------------------+
double CIntelligentExitSystem::NormalizeStopLevel(string symbol, double price)
{
   return NormalizeDouble(price, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
}

//+------------------------------------------------------------------+
//| Log de ações de trailing                                          |
//+------------------------------------------------------------------+
void CIntelligentExitSystem::LogTrailingAction(string action, ulong ticket, double old_sl, double new_sl)
{
   Print("[EXIT_SYSTEM] ", action, " - Ticket: ", ticket, 
         ", SL Anterior: ", DoubleToString(old_sl, _Digits),
         ", Novo SL: ", DoubleToString(new_sl, _Digits));
}

//+------------------------------------------------------------------+
//| Configurar trailing simples                                       |
//+------------------------------------------------------------------+
void CIntelligentExitSystem::SetSimpleTrailing(double start_points, double step_points, double distance_points)
{
   m_trailing_config.type = TRAILING_FIXED;
   m_trailing_config.enabled = true;
   m_trailing_config.start_points = start_points;
   m_trailing_config.step_points = step_points;
   m_trailing_config.distance_points = distance_points;
   m_trailing_config.virtual_mode = false;
   m_trailing_config.close_percent = 100;
}

//+------------------------------------------------------------------+
//| Configurar trailing ATR                                           |
//+------------------------------------------------------------------+
void CIntelligentExitSystem::SetATRTrailing(double start_atr_mult, double step_atr_mult, double distance_atr_mult, int period = 14)
{
   m_trailing_config.type = TRAILING_ATR;
   m_trailing_config.enabled = true;
   m_trailing_config.start_points = start_atr_mult * 100; // Converter para pontos base
   m_trailing_config.step_points = step_atr_mult * 100;
   m_trailing_config.atr_multiplier = distance_atr_mult;
   m_trailing_config.atr_period = period;
   m_trailing_config.virtual_mode = false;
   m_trailing_config.close_percent = 100;
}

//+------------------------------------------------------------------+
//| Configurar breakeven                                              |
//+------------------------------------------------------------------+
void CIntelligentExitSystem::SetBreakeven(double trigger_points, double offset_points = 0)
{
   m_breakeven_config.enabled = true;
   m_breakeven_config.trigger_points = trigger_points;
   m_breakeven_config.offset_points = offset_points;
   m_breakeven_config.atr_based = false;
}

//+------------------------------------------------------------------+
//| Configurar take profit parcial                                    |
//+------------------------------------------------------------------+
void CIntelligentExitSystem::SetPartialTP(double level1_points, double level1_percent, 
                                          double level2_points = 0, double level2_percent = 0,
                                          double level3_points = 0, double level3_percent = 0)
{
   m_partial_tp_config.mode = PARTIAL_TP_FIXED;
   m_partial_tp_config.enabled = true;
   m_partial_tp_config.level1_points = level1_points;
   m_partial_tp_config.level1_percent = level1_percent;
   m_partial_tp_config.level2_points = level2_points;
   m_partial_tp_config.level2_percent = level2_percent;
   m_partial_tp_config.level3_points = level3_points;
   m_partial_tp_config.level3_percent = level3_percent;
}

//+------------------------------------------------------------------+
//| Obter status do sistema de saída                                  |
//+------------------------------------------------------------------+
string CIntelligentExitSystem::GetExitSystemStatus()
{
   string status = "\n=== STATUS SISTEMA DE SAÍDA INTELIGENTE ===\n";
   
   // Status do trailing stop
   status += "TRAILING STOP: " + (m_trailing_config.enabled ? "ATIVO" : "INATIVO") + "\n";
   if(m_trailing_config.enabled)
   {
      status += "  Tipo: ";
      switch(m_trailing_config.type)
      {
         case TRAILING_FIXED: status += "Fixo"; break;
         case TRAILING_PERCENT: status += "Percentual"; break;
         case TRAILING_ATR: status += "ATR"; break;
         case TRAILING_MA: status += "Moving Average"; break;
         case TRAILING_PARABOLIC: status += "Parabolic SAR"; break;
         case TRAILING_CANDLE_HL: status += "High/Low Velas"; break;
      }
      status += "\n";
      status += "  Início: " + DoubleToString(m_trailing_config.start_points, 1) + " pontos\n";
      status += "  Distância: " + DoubleToString(m_trailing_config.distance_points, 1) + " pontos\n";
      status += "  Modo: " + (m_trailing_config.virtual_mode ? "Virtual" : "Real") + "\n";
   }
   
   // Status do breakeven
   status += "BREAKEVEN: " + (m_breakeven_config.enabled ? "ATIVO" : "INATIVO") + "\n";
   if(m_breakeven_config.enabled)
   {
      status += "  Trigger: " + DoubleToString(m_breakeven_config.trigger_points, 1) + " pontos\n";
      status += "  Offset: " + DoubleToString(m_breakeven_config.offset_points, 1) + " pontos\n";
   }
   
   // Status do take profit parcial
   status += "TAKE PROFIT PARCIAL: " + (m_partial_tp_config.enabled ? "ATIVO" : "INATIVO") + "\n";
   if(m_partial_tp_config.enabled)
   {
      if(m_partial_tp_config.level1_points > 0)
         status += "  Nível 1: " + DoubleToString(m_partial_tp_config.level1_points, 1) + 
                   " pontos (" + DoubleToString(m_partial_tp_config.level1_percent, 1) + "%)\n";
      if(m_partial_tp_config.level2_points > 0)
         status += "  Nível 2: " + DoubleToString(m_partial_tp_config.level2_points, 1) + 
                   " pontos (" + DoubleToString(m_partial_tp_config.level2_percent, 1) + "%)\n";
      if(m_partial_tp_config.level3_points > 0)
         status += "  Nível 3: " + DoubleToString(m_partial_tp_config.level3_points, 1) + 
                   " pontos (" + DoubleToString(m_partial_tp_config.level3_percent, 1) + "%)\n";
   }
   
   status += "POSIÇÕES GERENCIADAS: " + IntegerToString(m_positions_count) + "\n";
   status += "==========================================\n";
   
   return status;
}

//+------------------------------------------------------------------+
//| Imprimir relatório do sistema de saída                            |
//+------------------------------------------------------------------+
void CIntelligentExitSystem::PrintExitReport()
{
   Print(GetExitSystemStatus());
}

//+------------------------------------------------------------------+
//| Validar configuração de trailing                                  |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::ValidateTrailingConfig()
{
   if(m_trailing_config.start_points < 0)
   {
      Print("[EXIT_SYSTEM] Erro: Pontos de início do trailing devem ser >= 0");
      return false;
   }
   
   if(m_trailing_config.distance_points <= 0)
   {
      Print("[EXIT_SYSTEM] Erro: Distância do trailing deve ser > 0");
      return false;
   }
   
   if(m_trailing_config.close_percent <= 0 || m_trailing_config.close_percent > 100)
   {
      Print("[EXIT_SYSTEM] Erro: Percentual de fechamento deve estar entre 0 e 100");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Validar configuração de breakeven                                 |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::ValidateBreakevenConfig()
{
   if(m_breakeven_config.trigger_points < 0)
   {
      Print("[EXIT_SYSTEM] Erro: Pontos de trigger do breakeven devem ser >= 0");
      return false;
   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//| Validar configuração de take profit parcial                       |
//+------------------------------------------------------------------+
bool CIntelligentExitSystem::ValidatePartialTPConfig()
{
   if(m_partial_tp_config.level1_percent <= 0 || m_partial_tp_config.level1_percent > 100)
   {
      Print("[EXIT_SYSTEM] Erro: Percentual do nível 1 deve estar entre 0 e 100");
      return false;
   }
   
   if(m_partial_tp_config.level2_percent < 0 || m_partial_tp_config.level2_percent > 100)
   {
      Print("[EXIT_SYSTEM] Erro: Percentual do nível 2 deve estar entre 0 e 100");
      return false;
   }
   
   if(m_partial_tp_config.level3_percent < 0 || m_partial_tp_config.level3_percent > 100)
   {
      Print("[EXIT_SYSTEM] Erro: Percentual do nível 3 deve estar entre 0 e 100");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
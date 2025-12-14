//+------------------------------------------------------------------+
//|                                                TradeExecutor.mqh |
//|                                                           Franco |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "https://www.mql5.com"
#property strict

#include <Trade/Trade.mqh>
#include "../Core/Definitions.mqh"

//+------------------------------------------------------------------+
//| Class: CTradeExecutor                                            |
//| Purpose: Handles trade execution and position management.        |
//+------------------------------------------------------------------+
class CTradeExecutor
{
private:
   CTrade            m_trade;
   int               m_magic_number;
   int               m_slippage;
   string            m_comment;
   
   //--- Management Settings
   bool              m_use_trailing;
   double            m_trailing_start;
   double            m_trailing_step;
   bool              m_use_breakeven;
   double            m_breakeven_trigger;
   double            m_breakeven_offset;

public:
                     CTradeExecutor();
                    ~CTradeExecutor();

   //--- Initialization
   void              Init(int magic, int slippage, string comment);
   void              SetManagementParams(bool use_trail, double trail_start, double trail_step, bool use_be, double be_trigger, double be_offset);

   //--- Execution
   bool              ExecuteTrade(ENUM_ORDER_TYPE type, double volume, double sl, double tp, int score);
   
   //--- Management
   void              ManagePositions();

private:
   void              ApplyTrailingStop(ulong ticket);
   void              ApplyBreakEven(ulong ticket);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeExecutor::CTradeExecutor() :
   m_magic_number(0),
   m_slippage(10),
   m_comment(""),
   m_use_trailing(true),
   m_trailing_start(200), // Points
   m_trailing_step(50),   // Points
   m_use_breakeven(true),
   m_breakeven_trigger(150), // Points
   m_breakeven_offset(10)    // Points
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeExecutor::~CTradeExecutor()
{
}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CTradeExecutor::Init(int magic, int slippage, string comment)
{
   m_magic_number = magic;
   m_slippage = slippage;
   m_comment = comment;
   
   m_trade.SetExpertMagicNumber(m_magic_number);
   m_trade.SetDeviationInPoints(m_slippage);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK); // Or IOC depending on broker
   m_trade.SetAsyncMode(false); // Sync for Phase 1
}

//+------------------------------------------------------------------+
//| Set Management Parameters                                        |
//+------------------------------------------------------------------+
void CTradeExecutor::SetManagementParams(bool use_trail, double trail_start, double trail_step, bool use_be, double be_trigger, double be_offset)
{
   m_use_trailing = use_trail;
   m_trailing_start = trail_start;
   m_trailing_step = trail_step;
   m_use_breakeven = use_be;
   m_breakeven_trigger = be_trigger;
   m_breakeven_offset = be_offset;
}

//+------------------------------------------------------------------+
//| Execute Trade                                                    |
//+------------------------------------------------------------------+
bool CTradeExecutor::ExecuteTrade(ENUM_ORDER_TYPE type, double volume, double sl, double tp, int score)
{
   string final_comment = m_comment + " S:" + IntegerToString(score);
   
    // Spread and distance guards
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double spread_pts = (ask - bid) / point;
   int stops_lvl = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze_lvl = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double min_dist = MathMax(stops_lvl, freeze_lvl) * point;
   double max_spread_pts = m_slippage * 2;
   if(spread_pts > max_spread_pts)
   {
      Print("TradeExecutor: spread too wide (", spread_pts, " pts) > max ", max_spread_pts, " pts. Aborting.");
      return false;
   }
   
   double price = (type == ORDER_TYPE_BUY) ? ask : bid;
   if(MathAbs(price - sl) < min_dist || MathAbs(tp - price) < min_dist)
   {
      Print("TradeExecutor: SL/TP inside stop/freeze distance (", min_dist/point, " pts). Aborting.");
      return false;
   }
   
   int attempts = 0;
   while(attempts < 2)
   {
      bool ok = false;
      if(type == ORDER_TYPE_BUY)
         ok = m_trade.Buy(volume, _Symbol, price, sl, tp, final_comment);
      else if(type == ORDER_TYPE_SELL)
         ok = m_trade.Sell(volume, _Symbol, price, sl, tp, final_comment);
      else
         return false;

      if(ok) return true;

      int rc = (int)m_trade.ResultRetcode();
      if(rc == TRADE_RETCODE_REQUOTE || rc == TRADE_RETCODE_PRICE_CHANGED)
      {
         MqlTick tick;
         if(SymbolInfoTick(_Symbol, tick))
         {
            bid = tick.bid;
            ask = tick.ask;
            price = (type == ORDER_TYPE_BUY) ? ask : bid;
         }
         attempts++;
         continue;
      }

      Print("TradeExecutor: order failed - ", m_trade.ResultRetcodeDescription(), " (retcode ", rc, ")");
      return false;
   }
   
   Print("TradeExecutor: order failed after retries (retcode ", m_trade.ResultRetcode(), ")");
   return false;
   
}

//+------------------------------------------------------------------+
//| Manage Open Positions                                            |
//+------------------------------------------------------------------+
void CTradeExecutor::ManagePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == m_magic_number)
         {
            if(m_use_breakeven) ApplyBreakEven(ticket);
            if(m_use_trailing) ApplyTrailingStop(ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Apply Break Even                                                 |
//+------------------------------------------------------------------+
void CTradeExecutor::ApplyBreakEven(ulong ticket)
{
   if(!PositionSelectByTicket(ticket)) return;
   if(m_breakeven_trigger <= 0) return;
   
   double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   double current_sl = PositionGetDouble(POSITION_SL);
   double current_price = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int stops_lvl = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze_lvl = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double min_dist = MathMax(stops_lvl, freeze_lvl) * point;
   
   if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
   {
      // Check if price moved enough
      if(current_price >= open_price + m_breakeven_trigger * point)
      {
         // Check if SL is already at or above BE
         double new_sl = open_price + m_breakeven_offset * point;
         if((current_price - new_sl) < min_dist) return; // freeze / stops guard
         if(current_sl < new_sl || current_sl == 0)
         {
            if(!m_trade.PositionModify(ticket, new_sl, PositionGetDouble(POSITION_TP)))
               Print("TradeExecutor: BE modify failed - ", m_trade.ResultRetcodeDescription(), " (retcode ", m_trade.ResultRetcode(), ")");
         }
      }
   }
   else // SELL
   {
      if(current_price <= open_price - m_breakeven_trigger * point)
      {
         double new_sl = open_price - m_breakeven_offset * point;
         if((new_sl - current_price) < min_dist) return; // freeze / stops guard
         if(current_sl > new_sl || current_sl == 0)
         {
            if(!m_trade.PositionModify(ticket, new_sl, PositionGetDouble(POSITION_TP)))
               Print("TradeExecutor: BE modify failed - ", m_trade.ResultRetcodeDescription(), " (retcode ", m_trade.ResultRetcode(), ")");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Apply Trailing Stop                                              |
//+------------------------------------------------------------------+
void CTradeExecutor::ApplyTrailingStop(ulong ticket)
{
   if(!PositionSelectByTicket(ticket)) return;
   if(m_trailing_start <= 0 || m_trailing_step <= 0) return;
   
   double current_sl = PositionGetDouble(POSITION_SL);
   double current_price = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int stops_lvl = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze_lvl = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double min_dist = MathMax(stops_lvl, freeze_lvl) * point;
   
   if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
   {
      double new_sl = current_price - m_trailing_start * point;
      
      if(new_sl > current_sl)
      {
         // Only update if step is met
         if(new_sl - current_sl >= m_trailing_step * point && (current_price - new_sl) >= min_dist)
         {
            if(!m_trade.PositionModify(ticket, new_sl, PositionGetDouble(POSITION_TP)))
               Print("TradeExecutor: trail update failed - ", m_trade.ResultRetcodeDescription(), " (retcode ", m_trade.ResultRetcode(), ")");
         }
      }
   }
   else // SELL
   {
      double new_sl = current_price + m_trailing_start * point;
      
      if(new_sl < current_sl || current_sl == 0)
      {
         if((current_sl == 0 || current_sl - new_sl >= m_trailing_step * point) && (new_sl - current_price) >= min_dist)
         {
            if(!m_trade.PositionModify(ticket, new_sl, PositionGetDouble(POSITION_TP)))
               Print("TradeExecutor: trail update failed - ", m_trade.ResultRetcodeDescription(), " (retcode ", m_trade.ResultRetcode(), ")");
         }
      }
   }
}

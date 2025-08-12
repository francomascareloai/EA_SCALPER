//+------------------------------------------------------------------+
//|                        SmartHedgeGridEA_1Dollar.mq5             |
//|   Profit target $1 + trailing net profit continues              |
//+------------------------------------------------------------------+
#property copyright "OpenAI"
#property version   "1.05"
#property strict

#include <Trade/Trade.mqh>
CTrade trade;

input double    StartLot=0.01;
input int       Multiplier=4;
input double    ProfitTargetUSD=1;              // start trailing after $1
input int       GridStepPoints=200;
input bool      EnableTradingHours=true;
input int       TradeStartHour=7;
input int       TradeEndHour=19;
input bool      EnableNewsFilter=true;
input bool      EnableTrailingOnProfit=true;
input double    TrailStartProfit=1;
input double    TrailStep=2;

int direction=1; // 1=buy, -1=sell
double nextLot;
bool firstTradePlaced=false;
double peakProfit=0;

//+------------------------------------------------------------------+
int OnInit()
  {
   nextLot=StartLot;
   peakProfit=0;
   return(INIT_SUCCEEDED);
  }

// Dummy news filter
bool CheckNewsFilter() { return false; }

bool CheckTradingHours()
  {
   datetime now=TimeCurrent();
   MqlDateTime tm;
   TimeToStruct(now, tm);
   int hour=tm.hour;
   return (hour>=TradeStartHour && hour<=TradeEndHour);
  }

double TotalProfit()
  {
   double profit=0;
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL)==_Symbol)
            profit+=PositionGetDouble(POSITION_PROFIT);
        }
     }
   return profit;
  }

void PlaceNextOrder()
  {
   double price=(direction==1) ? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double lot = nextLot;
   double nextLotMulti=lot*Multiplier;

   if(direction==1)
     {
      trade.Buy(lot,_Symbol);
      double sellStop=price - GridStepPoints*_Point;
      trade.SellStop(nextLotMulti,_Symbol,sellStop,0,0);
     }
   else
     {
      trade.Sell(lot,_Symbol);
      double buyStop=price + GridStepPoints*_Point;
      trade.BuyStop(nextLotMulti,_Symbol,buyStop,0,0);
     }

   nextLot*=Multiplier;
   direction*=-1;
  }

void CloseAll()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL)==_Symbol)
            trade.PositionClose(ticket);
        }
     }
   nextLot=StartLot;
   direction=1;
   firstTradePlaced=false;
   peakProfit=0;
  }

void OnTick()
  {
   if(EnableTradingHours && !CheckTradingHours()) return;
   if(EnableNewsFilter && CheckNewsFilter()) return;

   double profit=TotalProfit();

   if(EnableTrailingOnProfit && profit>=TrailStartProfit)
     {
      if(profit>peakProfit) peakProfit=profit;

      if(profit<=peakProfit - TrailStep)
        {
         CloseAll();
         return;
        }
     }
   else if(!EnableTrailingOnProfit && profit>=ProfitTargetUSD)
     {
      CloseAll();
      return;
     }

   if(!firstTradePlaced)
     {
      PlaceNextOrder();
      firstTradePlaced=true;
     }
  }
//+------------------------------------------------------------------+

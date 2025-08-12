//+------------------------------------------------------------------+
//|                                             RoNz Auto SL n TP.mq4|
//|                              Copyright 2014-2018, Rony Nofrianto |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022"
#property description   "Based from Ronz AutoSL-TP"
#property version   "1.3"
#property strict

#include <Trade\Trade.mqh> CTrade trade;
enum ENUM_CHARTSYMBOL
  {
   CurrentChartSymbol=0,//Current Chart Only
   AllOpenOrder=1//All Opened Orders
  };
enum ENUM_SLTP_MODE
  {
   Server=0,//Place SL n TP
   Client=1 //Hidden SL n TP
  };
enum ENUM_LOCKPROFIT_ENABLE
  {
   LP_DISABLE=0,//Disable
   LP_ENABLE=1//Enable
  };
enum ENUM_TRAILINGSTOP_METHOD
  {
   TS_NONE=0,//No Trailing Stop
   TS_CLASSIC=1,//Classic
   TS_STEP_DISTANCE=2,//Step Keep Distance
   TS_STEP_BY_STEP=3 //Step By Step
  };
sinput const string SLTP="";//-=[ SL & TP SETTINGS ]=-
input int   TakeProfit=550;//Take Profit
input int   StopLoss=350;//Stop Loss
input ENUM_SLTP_MODE SLnTPMode=Server;//SL & TP Mode
sinput const string Lock="";//-=[ LOCK PROFIT SETTINGS ]=-
input ENUM_LOCKPROFIT_ENABLE LockProfitEnable=LP_ENABLE;//Enable/Disable Profit Lock
input int   LockProfitAfter=100;//Target point to Lock Profit
input int   ProfitLock=60;//Profit To Lock
sinput const string Trailing="";//-=[ TRAILING STOP SETTINGS ]=-
input ENUM_TRAILINGSTOP_METHOD TrailingStopMethod=TS_CLASSIC;//Trailing Method
input int   TrailingStop=50;//Trailing Stop
input int   TrailingStep=10;//Trailing Stop Step
input int Slippage   = 10; //Slippage
input ENUM_CHARTSYMBOL  ChartSymbolSelection=AllOpenOrder;//
input bool   inpEnableAlert=false;//Enable Alert
input bool   inpEnableTest=false;//Enable Test on Strategy Tester

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AutoSLTP
  {
private:
   //--
   bool              CheckMoneyForTrade(string sym, double lots,ENUM_ORDER_TYPE type);
   bool              CheckVolumeValue(string sym, double volume);
   bool              RZ_TrailingStop(ulong ticket, int JumlahPoin,int Step=1,ENUM_TRAILINGSTOP_METHOD Method=TS_STEP_DISTANCE);
   bool              LockProfit(ulong ticket, int Targetpoint,int Lockedpoint);
   //--

public:
   //--
   ENUM_SLTP_MODE    autoMode;
   ENUM_LOCKPROFIT_ENABLE LPMode;
   ENUM_CHARTSYMBOL  chartMode;
   ENUM_TRAILINGSTOP_METHOD trailingMode;
   int               slip;
   int               TPa;
   int               SLa;
   int               LPA;
   int               PL;
   int               TS;
   int               TST;
   bool              SetInstantSLTP();
   int               CalculateInstantOrders();
   void              OrderTest();
   //--
  };

AutoSLTP auto;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AutoSLTP::SetInstantSLTP()
  {
   double SL=0, TP=0;
   double ask = 0, bid = 0, point = 0;
   int digits = 0, minstoplevel = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i))
         if(chartMode==CurrentChartSymbol && PositionGetString(POSITION_SYMBOL)!=Symbol())
            continue;
        {
         ask = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_ASK);
         bid = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_BID);
         point = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_POINT);
         digits =(int)SymbolInfoInteger(PositionGetString(POSITION_SYMBOL),SYMBOL_DIGITS);
         minstoplevel =(int)SymbolInfoInteger(PositionGetString(POSITION_SYMBOL),SYMBOL_TRADE_STOPS_LEVEL);

         double ClosePrice=0;
         int Poin=0;
         color CloseColor=clrNONE;

         //Get point
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            CloseColor=clrBlue;
            ClosePrice=bid;
            Poin=(int)((ClosePrice-PositionGetDouble(POSITION_PRICE_OPEN))/point);
           }
         else
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               CloseColor=clrRed;
               ClosePrice=ask;
               Poin=(int)((PositionGetDouble(POSITION_PRICE_OPEN)-ClosePrice)/point);
              }

         //Print("Check SL & TP : ",OrderSymbol()," SL = ",OrderStopLoss()," TP = ",OrderTakeProfit());
         //Set Server SL and TP
         if(autoMode == Server)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               SL=(SLa>0)?NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-((SLa+minstoplevel)*point),digits):0;
               TP=(TPa>0)?NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+((TPa+minstoplevel)*point),digits):0;
               if(SLa > 0 && TPa > 0 && PositionGetDouble(POSITION_SL)==0.0 && PositionGetDouble(POSITION_TP)==0.0)
                 {
                  trade.PositionModify(PositionGetInteger(POSITION_TICKET),SL,TP);
                 }
               else
                  if(TPa > 0 && PositionGetDouble(POSITION_TP)==0.0)
                    {
                     trade.PositionModify(PositionGetInteger(POSITION_TICKET),PositionGetDouble(POSITION_SL),TP);
                    }
                  else
                     if(SLa > 0 && PositionGetDouble(POSITION_SL)==0.0)
                       {
                        trade.PositionModify(PositionGetInteger(POSITION_TICKET),SL,PositionGetDouble(POSITION_TP));
                       }
              }
            else
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  SL=(SLa>0)?NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+((SLa+minstoplevel)*point),digits):0;
                  TP=(TPa>0)?NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-((TPa+minstoplevel)*point),digits):0;
                  if(SLa > 0 && TPa > 0 && PositionGetDouble(POSITION_SL)==0.0 && PositionGetDouble(POSITION_TP)==0.0)
                    {
                     trade.PositionModify(PositionGetInteger(POSITION_TICKET),SL,TP);
                    }
                  else
                     if(TPa > 0 && PositionGetDouble(POSITION_TP)==0.0)
                       {
                        trade.PositionModify(PositionGetInteger(POSITION_TICKET),PositionGetDouble(POSITION_SL),TP);
                       }
                     else
                        if(SLa > 0 && PositionGetDouble(POSITION_SL)==0.0)
                          {
                           trade.PositionModify(PositionGetInteger(POSITION_TICKET),SL,PositionGetDouble(POSITION_TP));
                          }
                 }
           }
         else
            if(autoMode == Client)
              {
               if((TPa>0 && Poin>=TPa) || (SLa>0 && Poin<=(-SLa)))
                 {
                  if(trade.PositionClose(PositionGetInteger(POSITION_TICKET),slip))
                    {
                     if(inpEnableAlert)
                       {
                        if(PositionGetDouble(POSITION_PROFIT)>0)
                           Alert("Closed by Virtual TP #",PositionGetInteger(POSITION_TICKET)," Profit=",PositionGetDouble(POSITION_PROFIT)," Points=",Poin);
                        if(PositionGetDouble(POSITION_PROFIT)<0)
                           Alert("Closed by Virtual SL #",PositionGetInteger(POSITION_TICKET)," Loss=",PositionGetDouble(POSITION_PROFIT)," Points=",Poin);
                       }
                    }
                 }
              }


         if(LPA>0 && PL>0 && Poin>=LPA)
           {
            if(Poin<=LPA+TS)
              {
               LockProfit(PositionGetInteger(POSITION_TICKET),LPA,PL);
              }
            else
               if(Poin>=LPA+TS)
                 {
                  RZ_TrailingStop(PositionGetInteger(POSITION_TICKET),TS,TST,trailingMode);
                 }
           }
         else
            if(LPA==0)
              {
               RZ_TrailingStop(PositionGetInteger(POSITION_TICKET),TS,TST,trailingMode);
              }

        }
     }

   return (false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AutoSLTP::OrderTest()
  {
   if(!MQLInfoInteger(MQL_TESTER))
      return;
   if(CalculateInstantOrders()==0)
     {
      if(CheckMoneyForTrade("EURUSD",0.01,ORDER_TYPE_BUY) && CheckVolumeValue("EURUSD",0.01))
         trade.Buy(0.01,"EURUSD",SymbolInfoDouble("EURUSD",SYMBOL_ASK),0,0,NULL);
      if(CheckMoneyForTrade("GBPUSD",0.01,ORDER_TYPE_SELL) && CheckVolumeValue("GBPUSD",0.01))
         trade.Sell(0.01,"GBPUSD",SymbolInfoDouble("GBPUSD",SYMBOL_BID),0,0,NULL);
     }

   return;
  }

//+------------------------------------------------------------------+
bool AutoSLTP::LockProfit(ulong ticket, int Targetpoint,int Lockedpoint)
  {
   if(LPMode==false || Targetpoint==0 || Lockedpoint==0)
      return false;

   if(PositionSelectByTicket(ticket)==false)
      return false;

   double ask = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_ASK);
   double bid = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_BID);
   double point = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_POINT);
   int digits =(int)SymbolInfoInteger(PositionGetString(POSITION_SYMBOL),SYMBOL_DIGITS);
   int minstoplevel =(int)SymbolInfoInteger(PositionGetString(POSITION_SYMBOL),SYMBOL_TRADE_STOPS_LEVEL);

   double PSL=0;
   double CurrentSL=(PositionGetDouble(POSITION_SL)!=0)?PositionGetDouble(POSITION_SL):PositionGetDouble(POSITION_PRICE_OPEN);

   if(Targetpoint < Lockedpoint)
     {
      Print("Target point must be higher than Profit Lock");
      return false;
     }

   if((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) && (bid-PositionGetDouble(POSITION_PRICE_OPEN)>=Targetpoint*point) && (CurrentSL<=PositionGetDouble(POSITION_PRICE_OPEN)))
     {
      PSL=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+(Lockedpoint*point),digits);
     }
   else
      if((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) && (PositionGetDouble(POSITION_PRICE_OPEN)-ask>=Targetpoint*point) && (CurrentSL>=PositionGetDouble(POSITION_PRICE_OPEN)))
        {
         PSL=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-(Lockedpoint*point),digits);
        }
      else
         return false;

   if(trade.PositionModify(ticket,PSL,PositionGetDouble(POSITION_TP)))
      return true;
   else
      return false;


   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AutoSLTP::RZ_TrailingStop(ulong ticket, int JumlahPoin,int Step=1,ENUM_TRAILINGSTOP_METHOD Method=TS_STEP_DISTANCE)
  {
   if(JumlahPoin==0)
      return false;

   if(PositionSelectByTicket(ticket)==false)
      return false;

   double ask = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_ASK);
   double bid = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_BID);
   double point = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_POINT);
   int digits =(int)SymbolInfoInteger(PositionGetString(POSITION_SYMBOL),SYMBOL_DIGITS);
   int minstoplevel =(int)SymbolInfoInteger(PositionGetString(POSITION_SYMBOL),SYMBOL_TRADE_STOPS_LEVEL);
   int spread =(int)SymbolInfoInteger(PositionGetString(POSITION_SYMBOL),SYMBOL_SPREAD);

   double TSL=0;
   double CurrentSL=(PositionGetDouble(POSITION_SL)!=0)?PositionGetDouble(POSITION_SL):PositionGetDouble(POSITION_PRICE_OPEN);

   if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && (bid-PositionGetDouble(POSITION_PRICE_OPEN)>JumlahPoin*point))
     {
      //for buy limit == suspected errors come from this
      if(CurrentSL<PositionGetDouble(POSITION_PRICE_OPEN))
         CurrentSL=PositionGetDouble(POSITION_PRICE_OPEN);

      if((bid-CurrentSL)>=(JumlahPoin)*point)
        {
         switch(Method)
           {
            case TS_CLASSIC://Classic, no step
               TSL=NormalizeDouble(bid-(JumlahPoin*point),digits);
               break;
            case TS_STEP_DISTANCE://Step keeping distance
               TSL=NormalizeDouble(bid-((JumlahPoin-Step)*point),digits);
               break;
            case TS_STEP_BY_STEP://Step by step (slow)
               TSL=NormalizeDouble(CurrentSL+(Step*point),digits);
               break;
            case TS_NONE://No Trailing
               TSL=0;
               break;
            default:
               TSL=0;
           }
        }
     }

   else
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && (PositionGetDouble(POSITION_PRICE_OPEN)-ask>JumlahPoin*point))
        {
         //for sell limit == suspected errors come from this
         if(CurrentSL>PositionGetDouble(POSITION_PRICE_OPEN))
            CurrentSL=PositionGetDouble(POSITION_PRICE_OPEN);

         if((CurrentSL-ask)>=(JumlahPoin)*point)
           {
            switch(Method)
              {
               case TS_CLASSIC://Classic
                  TSL=NormalizeDouble(ask+(JumlahPoin*point),digits);
                  break;
               case TS_STEP_DISTANCE://Step keeping distance
                  TSL=NormalizeDouble(ask+((JumlahPoin-Step)*point),digits);
                  break;
               case TS_STEP_BY_STEP://PositionGetDouble(POSITION_SL) by step (slow)
                  TSL=NormalizeDouble(CurrentSL-(Step*point),digits);
                  break;
               case TS_NONE://No Trailing
                  TSL=0;
                  break;
               default:
                  TSL=0;
              }
           }
        }
   if(TSL==0)
      return false;

   if(TSL != CurrentSL)
     {
      if(trade.PositionModify(ticket,TSL,PositionGetDouble(POSITION_TP)))
         return true;
      else
         return false;
     }

   return false;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AutoSLTP::CalculateInstantOrders()
  {
   int buys=0, sells=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i))
         if(chartMode==CurrentChartSymbol && PositionGetString(POSITION_SYMBOL)!=Symbol())
            continue;
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            buys++;
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            sells++;
        }
     }
   if(buys > 0)
      return(buys);
   else
      return(-sells);

  }

//+------------------------------------------------------------------+
bool AutoSLTP::CheckMoneyForTrade(string sym, double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(sym,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- call of the checking function
   if(!OrderCalcMargin(type,sym,lots,price,margin))
     {
      //--- something went wrong, report and return false
      return(false);
     }
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      return(false);
     }
//--- checking successful
   return(true);
  }
//************************************************************************************************/
bool AutoSLTP::CheckVolumeValue(string sym, double volume)
  {

   double min_volume = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   if(volume < min_volume)
      return(false);

   double max_volume = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   if(volume > max_volume)
      return(false);

   double volume_step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);

   int ratio = (int)MathRound(volume / volume_step);
   if(MathAbs(ratio * volume_step - volume) > 0.0000001)
      return(false);

   return(true);
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   auto.TPa = TakeProfit;
   auto.SLa = StopLoss;
   auto.TS = TrailingStop;
   auto.TST = TrailingStep;
   auto.LPA = LockProfitAfter;
   auto.PL = ProfitLock;
   auto.slip = Slippage;
   auto.chartMode = ChartSymbolSelection;
   auto.trailingMode = TrailingStopMethod;
   auto.LPMode = LockProfitEnable;
   auto.autoMode = SLnTPMode;

   trade.SetDeviationInPoints(auto.slip);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(inpEnableTest)
      auto.OrderTest();
   if(auto.CalculateInstantOrders()!=0)
      auto.SetInstantSLTP();

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   return;
  }
//+------------------------------------------------------------------+

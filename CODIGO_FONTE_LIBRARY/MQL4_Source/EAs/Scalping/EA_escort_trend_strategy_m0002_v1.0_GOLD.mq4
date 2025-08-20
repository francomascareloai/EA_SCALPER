//+------------------------------------------------------------------+
//|                                        Escort_Trend_strategy.mq4 |                               
//|                                           Copyright 2014, vicas. |
//|                                    http://www.robotrading.com.ua |
//+------------------------------------------------------------------+
//---   Modificacion M00002
//---
#property copyright "Copyright 2014, vicas."
#property link      "http://www.robotrading.com.ua"
#property version   "1.0"
#property strict
//---
extern string s1="Risk MM and parameters orders";
extern double      MM_Lots            = 0.1;    // lot size when disconnecting MM
extern int         MM_Mode            = 1;      // 0 MM disabled enabled 1 
extern double      RiskPercent        = 1;      // percentage of the risk position of the deposit and stoploss
extern int         LotsDecimal        = 1;      // Number of decimal places
extern double      LotExponent        = 1.0;    // koefitsient increase lot series
extern int         MaxTrade           = 0;      // the maximum number of warrants in Series
extern int         MagicNumber        = 149101; // magic number (helps distinguish its adviser on foreign orders)
//---
extern string s2="Trading options";
extern double      TakeProfit         = 200;    // takeprofit 
extern double      StopLoss           = 55;     // Stop Loss
extern double      TrailStop          = 35;     // the level of the beginning of work bezubytka treylingstopa
extern double      TrailStep          = 3;      // step treylingstopa
extern int         Trailing           = 1;      // Use treylingstopa (0 - not used)
extern int         Breakeven          = 1;      // We translate stoploss to breakeven and then Tralee (0 - immediately Tralee)
//---
extern string s3="Signals Indicators";
extern int         PorogBar           = 3;      // Max bar graph when the signals should coincide
extern double      PorogCCI           = 100;    // The threshold of the entrance to the position of CCI
extern int         FastIMA            = 8;      // MA period
extern int         SlowIMA            = 18;     // MA period
extern int         PerICCI            = 14;     // CCI period
extern int         FastMACD           = 8;      // MACD period
extern int         SlowMACD           = 18;     // MACD period
//---
extern bool        ShowTableOnTesting=TRUE;   // display information table
//---
bool Sg_MACD_Buy= False,Sg_MACD_Sell = False;
bool Sg_IMA_Buy = False,Sg_IMA_Sell = False;
bool Sg_ICCI_Buy,Sg_ICCI_Sell;
bool OrderBuy=False,OrderSell=False;
//---
double StopLevel,Spread;
double SignalFastiMA,SignalSlowiMA,SignalCCI;
double MacdCurr,MacdPrev,SignalCurr,SignalPrev;
double Lots,TP,SL;
double MaxLots,MinLots,LotStep,LotOrder;
double PunktSize;
//---
int Slip=3.0,LotCount=0,NumerBar=0;
int total,ticket;
datetime timeprev=0;
//---
string s="Escort_TS_m0002 : ";
//+------------------------------------------------------------------+
//| Init function                                                    |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);           // The maximum volume of the lot in a row
   MinLots = MarketInfo(Symbol(), MODE_MINLOT);           // The minimum volume of the lot in a row
//---
   PunktSize=NormalizeDouble(MarketInfo(Symbol(),MODE_LOTSIZE)*Point,Digits);
//---
   if(Digits==3 || Digits==5)
     {
      TakeProfit*=10;
      StopLoss*=10;
      TrailStop *=10;
      TrailStep *=10;
      Slip*=10;
     }
//---
   Sg_MACD_Buy=False;
   Sg_MACD_Sell=False;
   Sg_IMA_Buy=False;
   Sg_IMA_Sell=False;
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Deinit function                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(MM_Mode==0 || StopLoss==0) Lots=MM_Lots;
   else
     {
      Lots=NormalizeDouble((AccountBalance()*RiskPercent/100.0)/(PunktSize*StopLoss),LotsDecimal);
      if(Lots < MinLots) Lots = MinLots;
      if(Lots > MaxLots) Lots = MaxLots;
     }
//---
   Spread=MarketInfo(Symbol(),MODE_SPREAD)*Point;
   StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   Sg_ICCI_Buy  = FALSE;
   Sg_ICCI_Sell = FALSE;
//---
   total=CountTrades();
//---
   if(total==0)
     {
      //---
      MacdCurr   = iMACD(NULL,0,FastMACD,SlowMACD,9,PRICE_TYPICAL,MODE_MAIN,0);
      MacdPrev   = iMACD(NULL,0,FastMACD,SlowMACD,9,PRICE_TYPICAL,MODE_MAIN,1);
      //---
      SignalFastiMA = iMA(Symbol(),NULL,FastIMA,0,MODE_LWMA,PRICE_WEIGHTED,0);
      SignalSlowiMA = iMA(Symbol(),NULL,SlowIMA,0,MODE_LWMA,PRICE_WEIGHTED,0);
      //---
      SignalCCI=iCCI(Symbol(),NULL,PerICCI,PRICE_TYPICAL,0);
      //---
      if(!Sg_IMA_Buy && (SignalSlowiMA<SignalFastiMA))
        {                     // Determine the input of IMA 1st step
         Sg_IMA_Buy=TRUE;
         Sg_IMA_Sell=FALSE;
         timeprev = Time[0];
         NumerBar = 1;
        }
      if(!Sg_IMA_Sell && (SignalSlowiMA>SignalFastiMA))
        {
         Sg_IMA_Sell= TRUE;
         Sg_IMA_Buy = FALSE;
         timeprev = Time[0];
         NumerBar = 1;
        }
      //--- We believe the number of bars on the 1st signal
      if((timeprev!=Time[0]) && (Sg_IMA_Buy || Sg_ICCI_Sell))
        {
         timeprev=Time[0];
         if(NumerBar!=0) NumerBar++;
        }
      //--- IMA reset signal on exceeding PorogBar     
      if(NumerBar>PorogBar)
        {
         Sg_IMA_Sell= FALSE;
         Sg_IMA_Buy = FALSE;
         NumerBar=0;
        }
      //--- Determine the time of entry on the MACD Step 2
      if(!Sg_MACD_Buy  && Sg_IMA_Buy  && (MacdCurr > 0 && MacdPrev < 0)) Sg_MACD_Buy  = TRUE;
      if(!Sg_MACD_Sell && Sg_IMA_Sell && (MacdCurr < 0 && MacdPrev > 0)) Sg_MACD_Sell = TRUE;
      //---
      if(SignalCCI>PorogCCI *1) Sg_ICCI_Buy=TRUE;                       // We determine the moment of entry of CCI Step 3
      if(SignalCCI<PorogCCI*-1) Sg_ICCI_Sell=TRUE;
      //---
      if(Sg_MACD_Buy && Sg_IMA_Buy && Sg_ICCI_Buy)
        {                            // Open order Buy
         LotOrder=CalcOrdersLot(Lots,LotExponent,MaxLots,MaxTrade);
         ticket=OrderSend(Symbol(),OP_BUY,LotOrder,Ask,Slip,0,0,s+IntegerToString(LotCount+1),MagicNumber,0,Blue);
         if(ticket<0)
           {
            Print("Error: ",GetLastError());
            return;
              } else {
            OrderBuy=TRUE;
            Sg_MACD_Buy= FALSE;
            Sg_IMA_Buy = FALSE;
            NumerBar=0;
           }
        }
      //---
      if(OrderBuy)
        {
         //---
         TP = NormalizeDouble(Bid + MathMax(TakeProfit, StopLevel)*Point, Digits);
         SL = NormalizeDouble(Bid - MathMax(StopLoss, StopLevel)*Point, Digits);
         if(!OrderModify(ticket,OrderOpenPrice(),SL,TP,0))
           {
            Print("Error: ",GetLastError());
            return;
           }
         OrderBuy=FALSE;
        }
      //---
      if(Sg_MACD_Sell && Sg_IMA_Sell && Sg_ICCI_Sell)
        {                          // Open Sell order
         LotOrder=CalcOrdersLot(Lots,LotExponent,MaxLots,MaxTrade);
         ticket=OrderSend(Symbol(),OP_SELL,LotOrder,Bid,Slip,0,0,s+IntegerToString(LotCount+1),MagicNumber,0,Blue);
         if(ticket<0)
           {
            Print("Error: ",GetLastError());
            return;
              } else {
            OrderSell=TRUE;
            Sg_MACD_Sell= FALSE;
            Sg_IMA_Sell = FALSE;
            NumerBar=0;
           }
        }
      //---
      if(OrderSell)
        {
         //---
         TP = NormalizeDouble(Ask - MathMax(TakeProfit, StopLevel)*Point, Digits);
         SL = NormalizeDouble(Ask + MathMax(StopLoss, StopLevel)*Point, Digits);
         if(!OrderModify(ticket,OrderOpenPrice(),SL,TP,0))
           {
            Print("Error: ",GetLastError());
            return;
           }
         OrderSell=FALSE;
        }
      //---
        } else {
      if(Trailing!=0) RealTrailOrder(TrailStop,TrailStep,StopLevel,MagicNumber);
     }
   if(((!IsOptimization()) && !IsTesting() && (!IsVisualMode())) || (ShowTableOnTesting && IsVisualMode() && !IsOptimization()))
     {
      InfoTab();
     }
  }
//+------------------------------------------------------------------+
//| CountTrades function                                             |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int count=0;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber) continue;
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
            if(OrderType()==OP_SELL || OrderType()==OP_BUY)
              {
               count++;
               break;
              }
        }
     }
   return (count);
  }
//+------------------------------------------------------------------+
//| Antimartingeyl function                                          |
//+------------------------------------------------------------------+
double CalcOrdersLot(double firstlot,double lotexponent,double maxlot,int maxseries)
  {
   int prevorder=0;
   double prevlot=0;
   double lot;
   for(int pos=OrdersHistoryTotal()-1; pos>=0; pos--)
     {
      if(OrderSelect(pos,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()==OP_SELL || OrderType()==OP_BUY)
              {
               if(OrderProfit()<0)
                 {
                  prevorder=1;
                  break;
                    } else {
                  prevorder=2;
                  prevlot=OrderLots();
                  break;
                 }
              }
           }
        }
     }
//---
   switch(prevorder)
     {
      case 1:
         lot=firstlot;
         LotCount=0;
         break;
      case 2:
         if(LotCount<maxseries)
           {
            lot=NormalizeDouble(prevlot*lotexponent,LotsDecimal);
            LotCount++;
              } else {
            lot=firstlot;
            LotCount=0;
           }
         break;
      default:
         lot=firstlot;
         LotCount=0;
         break;
     }
   if(lot>maxlot) lot=maxlot;
   return(lot);
  }
//+------------------------------------------------------------------+
//| Treylingstop function                                            |
//+------------------------------------------------------------------+
void RealTrailOrder(double trstop,double trstep,double stlevel,int magic)
  {
   double openprice;
   double openstoploss;
   double calculatestoploss;
   double trailstop=MathMax(trstop,stlevel);
   for(int cmt=OrdersTotal()-1; cmt>=0; cmt--)
     {
      if(OrderSelect(cmt,SELECT_BY_POS,MODE_TRADES)==TRUE)
        {
         if(OrderMagicNumber()==magic && OrderSymbol()==Symbol())
           {
            openprice=OrderOpenPrice();
            openstoploss=OrderStopLoss();
            while(IsTradeContextBusy()) Sleep(500);
            RefreshRates();
            if(OrderType()==OP_BUY)
              {
               calculatestoploss=ND(Bid-trailstop*Point);
               if((Bid>openprice+trailstop*Point) || (Breakeven==0))
                 {
                  if(((calculatestoploss>=openstoploss+trstep*Point) && (trailstop*Point>stlevel*Point)))
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),calculatestoploss,OrderTakeProfit(),0,Blue))
                        Print("BUY OrderModify Error "+IntegerToString(GetLastError()));
                    }
                 }
              }
            if(OrderType()==OP_SELL)
              {
               calculatestoploss=ND(Ask+trailstop*Point);
               if((Ask<openprice-trailstop*Point) || (Breakeven==0))
                 {
                  if(((calculatestoploss<=openstoploss-trstep*Point) && (trailstop*Point>stlevel*Point)))
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),calculatestoploss,OrderTakeProfit(),0,Red))
                        Print("BUY OrderModify Error "+IntegerToString(GetLastError()));
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ND(double ad_0)
  {
   return (NormalizeDouble(ad_0, Digits));
  }
//+------------------------------------------------------------------+
//| information table function                                       |
//+------------------------------------------------------------------+
void InfoTab()
  {
//---
   string label,sgima=" ",sgmacd=" ",sgcci=" ";
//---
   if(Sg_IMA_Buy)   sgima  = "Buy";
   if(Sg_IMA_Sell)  sgima  = "Sell";
   if(Sg_MACD_Buy)  sgmacd = "Buy";
   if(Sg_MACD_Sell) sgmacd = "Sell";
   if(Sg_ICCI_Buy)  sgcci  = "Buy";
   if(Sg_ICCI_Sell) sgcci  = "Sell";
//---
   label=("\n"+"Escort_Trend_strategy v 1.0 m00002 149101  "+
          "\n"+"Date: "+IntegerToString(Day())+"-"+IntegerToString(Month())+"-"+IntegerToString(Year())+" Server Time: "+IntegerToString(Hour())+":"+IntegerToString(Minute())+":"+IntegerToString(Seconds())+
          "\n"+"Forex Account Server: "+AccountServer()+
          "\n"+
          "\n"+"Signal IMA   : "+sgima+
          "\n"+"Signal MACD  : "+sgmacd+
          "\n"+"Signal CCI   : "+sgcci+
          "\n"+"Count bars : "+IntegerToString(NumerBar)+
          "\n"+
          "\n"+"The volume of orders : "+DoubleToStr(LotOrder,2)+
          "\n"+"Order in series : "+IntegerToString(LotCount+1)+
          "\n"+"Risk % : "+DoubleToStr(RiskPercent,2));
//---
   Comment(label);
  }
//+------------------------------------------------------------------+

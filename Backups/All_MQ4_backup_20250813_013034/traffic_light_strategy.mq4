//+------------------------------------------------------------------+
//|                                       Traffic light_strategy.mq4 |                               
//|                                           Copyright 2015, vicas. |
//|                                    http://www.robotrading.com.ua |
//+------------------------------------------------------------------+
//---   Modificacion M000012 capsule version
//---   
#property copyright "Copyright 2015, vicas."
#property link      "http://www.robotrading.com.ua"
#property version   "1.0"
#property strict
//---
extern string s1="Risk MM and parameters orders";
extern double      MM_Lots            = 0.1;    // Объем лота MM
extern int         MM_Mode            = 1;      // 0 MM выключен 1 включен 
extern int         LotsDecimal        = 1;      // Точность расчета 0/1/2 знаков после запятой
extern double      RiskPercent        = 1;      // Риск на сделку
extern int         MagicNumber        = 134201; // Магический номер 
//---
extern string s2="Trading options";
extern int         StyleTrade         = 0;      // Стиль торговли 0 консервативный 1 агрессивный
extern int         TimeOpenBar        = 0;      // Открытие позиции 0 текущий бар 1 новый бар 
extern double      TakeProfit         = 120;    // Тейкпрофит в пунктах
extern double      StopLoss           = 60;     // Стоплосс в пунктах
extern int         CloseProfit        = 1;      // Закрытие позиции по iMA 1 вкл. 
extern int         TimeCloseBar       = 1;      // Закрытие позиции 1 новый бар 0 текущий бар
//---
extern string s3="Signals Indicators";
extern int         RedMA              = 120;    // Красная iMA
extern int         YellowMA           = 55;     // Желтая iMA
extern int         GreenMA            = 5;      // Зеленая iMA
extern int         BlueMA             = 24;     // Синяя iMA
//---
bool Sg_IMA_Buy=False,Sg_IMA_Sell=False;
bool OrderBuy=False,OrderSell=False;
bool Sg_Init=False;
bool TradeBuy,TradeSell;
//---
double Lots,MaxLots,MinLots;
double PunktSize;
//---
int Slip=3.0;
int total,ticket,Order_id;
datetime TimeNewOpenBar=0,TimeNewCloseBar=0;
//---
string s="Traffic light_m00012 capsule : ";
//+------------------------------------------------------------------+
//| Init function                                                    |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);
   MinLots = MarketInfo(Symbol(), MODE_MINLOT);
//---
   PunktSize=NormalizeDouble(MarketInfo(Symbol(),MODE_LOTSIZE)*Point,Digits);
//---
   if(Digits==3 || Digits==5)
     {
      TakeProfit*=10;
      StopLoss*=10;;
      Slip*=10;
     }
//---
   Sg_IMA_Buy=False;
   Sg_IMA_Sell=False;
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Start function                                                   |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double TP=0;
   double SL=0;
   double Spread=MarketInfo(Symbol(),MODE_SPREAD)*Point;
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
//---
   double SignalBlueiMAHigh=iMA(Symbol(),NULL,BlueMA,0,MODE_EMA,PRICE_HIGH,0);
   double SignalBlueiMALow=iMA(Symbol(),NULL,BlueMA,0,MODE_EMA,PRICE_LOW,0);
   double SignalYellowiMA=iMA(Symbol(),NULL,YellowMA,0,MODE_SMA,PRICE_CLOSE,0);
   double SignalRediMA=iMA(Symbol(),NULL,RedMA,0,MODE_SMA,PRICE_CLOSE,0);
   double SignalGreeniMA=iMA(Symbol(),NULL,GreenMA,0,MODE_EMA,PRICE_CLOSE,0);
//---
   TradeBuy=False;
   TradeSell=False;
//---   
   total=CountTrades();
//---
   if(total==0)
     {
      //---
      if(StyleTrade == 0 && Bid < SignalRediMA && Bid > SignalYellowiMA) Sg_Init=TRUE;
      if(StyleTrade == 0 && Bid < SignalYellowiMA && Bid > SignalRediMA) Sg_Init=TRUE;
      if(StyleTrade!=0 && Bid<SignalBlueiMAHigh && Bid>SignalBlueiMALow) Sg_Init=TRUE;
     }
//---  
   if(Sg_Init)
     {
      if(MM_Mode==0 || StopLoss==0) Lots=MM_Lots;
      else
        {
         Lots=NormalizeDouble((AccountBalance()*RiskPercent/100.0)/(PunktSize*StopLoss),LotsDecimal);
         if(Lots < MinLots) Lots = MinLots;
         if(Lots > MaxLots) Lots = MaxLots;
        }
     }
//---
   if(total==0)
     {
      //---
      if(TakeProfit==0 && StopLoss==0 && CloseProfit==0) return;
      //---
      if(SignalGreeniMA>SignalBlueiMAHigh && SignalBlueiMAHigh>SignalYellowiMA && SignalYellowiMA>SignalRediMA)
        {
         if(Bid>SignalGreeniMA) Sg_IMA_Buy=TRUE;
        }
      //---
      if(SignalGreeniMA<SignalBlueiMALow && SignalBlueiMALow<SignalYellowiMA && SignalYellowiMA<SignalRediMA)
        {
         if(Bid<SignalGreeniMA) Sg_IMA_Sell=TRUE;
        }
      //--
      if(TimeNewOpenBar == Time[0] && TimeOpenBar != 0) return;
      TimeNewOpenBar=Time[0];
      //---
      if(Sg_IMA_Buy && Sg_Init)
        {                            // Open order Buy
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,0,0,s,MagicNumber,0,Green);
         if(ticket<0)
           {
            Print("Error: ",GetLastError());
            return;
           }
         else
           {
            OrderBuy=TRUE;
            Sg_IMA_Buy=FALSE;
            Sg_Init=False;
           }
        }
      //---
      if(OrderBuy)
        {
         //---
         if(TakeProfit!=0) TP=NormalizeDouble(Bid+MathMax(TakeProfit,StopLevel)*Point,Digits);
         if(StopLoss!=0) SL=NormalizeDouble(Bid-MathMax(StopLoss,StopLevel)*Point,Digits);
         if(!OrderModify(ticket,OrderOpenPrice(),SL,TP,0))
           {
            Print("Error: ",GetLastError());
            return;
           }
         OrderBuy=FALSE;
        }
      //---
      if(Sg_IMA_Sell && Sg_Init)
        {                          // Open Sell order
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,0,0,s,MagicNumber,0,Red);
         if(ticket<0)
           {
            Print("Error: ",GetLastError());
            return;
           }
         else
           {
            OrderSell=TRUE;
            Sg_IMA_Sell=FALSE;
            Sg_Init=False;
           }
        }
      //---
      if(OrderSell)
        {
         //---
         if(TakeProfit!=0) TP=NormalizeDouble(Ask-MathMax(TakeProfit,StopLevel)*Point,Digits);
         if(StopLoss!=0) SL=NormalizeDouble(Ask+MathMax(StopLoss,StopLevel)*Point,Digits);
         if(!OrderModify(ticket,OrderOpenPrice(),SL,TP,0))
           {
            Print("Error: ",GetLastError());
            return;
           }
         OrderSell=FALSE;
        }
     }
   else
     {
      //---
      if(TimeNewCloseBar == Time[0] && TimeCloseBar != 0) return;
      TimeNewCloseBar=Time[0];
      //---
      if(CloseProfit!=0)
        {
         if((SignalGreeniMA<SignalYellowiMA) && TradeBuy)
           {
            if(OrderClose(Order_id,OrderLots(),Bid,Slip,Blue)) Print("Error: ",GetLastError());
           }
         if((SignalGreeniMA>SignalYellowiMA) && TradeSell)
           {
            if(OrderClose(Order_id,OrderLots(),Ask,Slip,Blue)) Print("Error: ",GetLastError());
           }
        }
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
            if(OrderType()==OP_SELL)
              {
               Order_id=OrderTicket();
               TradeSell=True;
               count++;
               break;
              }
         if(OrderType()==OP_BUY)
           {
            Order_id=OrderTicket();
            TradeBuy=True;
            count++;
            break;
           }
        }
     }
   return (count);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                     Beast EA.mq4 |
//|                                             abdellahfx@gmail.com |
//|                           https://www.facebook.com/abdellahforex |
//+------------------------------------------------------------------+
#property copyright "abdellahfx@gmail.com"
#property link      "https://www.facebook.com/abdellahforex"
#property version   "1.00"
#property strict


enum moption{
FIRST_MARTINGALE,
SECOND_MARTINGALE,
NO_MARTINGALE
};

extern string IndicatorName="Beast Super Signal";
extern double LotSize=0.1;
extern double Risk=1.00;//Money Management %(0 = Fixed Lot above)
extern int TakeProfit=10;
extern int StopLoss=100;
extern int TrailingStop=10;
extern bool CloseOppositeSignal=true;//Close on Opposite Signal ?
extern moption MartingaleOption=SECOND_MARTINGALE;//Martingale Option
extern double Multiply=2.00;//Lot Multiplier
extern int PipStep=30;//Pip Step
extern int MaxTrades=10;//Max Trades
extern bool TradingHours=false;
extern int Start_Hour=7;
extern int Finish_Hour=23;



extern int MagicNumber=20180203;
double lots,SL,TP,sell,buy,close,move;
double minsltp;
int ThisBarTrade=0;
bool NewBar;
double point;
int digits,Q,M;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
                                if(Digits==5 || Digits==3){Q=1;M=10;} 
   else {Q=10;M=1;}
   
   
   if(Digits<4)
     {
      point=0.01;
      digits=2;
     }
   else
     {
      point=0.0001;
      digits=4;
      }
         minsltp=(MarketInfo(Symbol(),MODE_SPREAD)+MarketInfo(Symbol(),MODE_STOPLEVEL)+1)/10;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
                    if (Bars != ThisBarTrade ) {
NewBar=true;
ThisBarTrade = Bars;  
NewBar=true;  
}
   minsltp=(MarketInfo(Symbol(),MODE_SPREAD)+MarketInfo(Symbol(),MODE_STOPLEVEL)+1)/10;
   
   
   double up=iCustom(Symbol(),0,IndicatorName,0,1);
   double dn=iCustom(Symbol(),0,IndicatorName,1,1);
   
   if(up!=EMPTY_VALUE&&up!=0&&CloseOppositeSignal)CloseOrders(OP_SELL);
   if(dn!=EMPTY_VALUE&&dn!=0&&CloseOppositeSignal)CloseOrders(OP_BUY);

if(orderscnt(OP_BUY)==0&&NewBar&&up!=EMPTY_VALUE&&up!=0&&(AllowTradesByTime()||!TradingHours)){
if(CloseOppositeSignal)CloseOrders(OP_SELL);
      lots=LotSize;
   if(StopLoss==0){SL=0;}else{SL=Ask-MathMax(StopLoss,minsltp)*point;}
   if(TakeProfit==0){TP=0;}else{TP=Ask+MathMax(TakeProfit,minsltp)*point;}
   if(Risk!=0)lots=(((AccountBalance()/100)/100)*Risk);
   if(LastProfit()<0&&MartingaleOption==FIRST_MARTINGALE)lots=LastLot()*Multiply;
   if(lots<MarketInfo(Symbol(),MODE_MINLOT))lots=MarketInfo(Symbol(),MODE_MINLOT);
   if(lots>MarketInfo(Symbol(),MODE_MAXLOT))lots=MarketInfo(Symbol(),MODE_MAXLOT); 
  buy=OrderSend(Symbol(),OP_BUY,NormalizeDouble(lots,2),Ask,30,SL,TP,"Buy Market",MagicNumber,0,clrBlue); 
  NewBar=false;
  }
  
  
if(orderscnt(OP_SELL)==0&&NewBar&&dn!=EMPTY_VALUE&&dn!=0&&(AllowTradesByTime()||!TradingHours)){
if(CloseOppositeSignal)CloseOrders(OP_BUY);

      lots=LotSize;
   if(StopLoss==0){SL=0;}else{SL=Bid+MathMax(StopLoss,minsltp)*point;}
   if(TakeProfit==0){TP=0;}else{TP=Bid-MathMax(TakeProfit,minsltp)*point;}
   if(Risk!=0)lots=(((AccountBalance()/100)/100)*Risk);
   if(LastProfit()<0&&MartingaleOption==FIRST_MARTINGALE)lots=LastLot()*Multiply;
   if(lots<MarketInfo(Symbol(),MODE_MINLOT))lots=MarketInfo(Symbol(),MODE_MINLOT);
   if(lots>MarketInfo(Symbol(),MODE_MAXLOT))lots=MarketInfo(Symbol(),MODE_MAXLOT); 
  sell=OrderSend(Symbol(),OP_SELL,NormalizeDouble(lots,2),Bid,30,SL,TP,"Sell Market",MagicNumber,0,clrRed);
  NewBar=false;
  } 
//---

if(MartingaleOption==SECOND_MARTINGALE){

if(TakeProfit!=0&&ProfitPips(OP_BUY)>=TakeProfit*point)CloseOrders(OP_BUY);
if(TakeProfit!=0&&ProfitPips(OP_SELL)>=TakeProfit*point)CloseOrders(OP_SELL);

if(LastLivePrice(OP_BUY)-Ask>=PipStep*point&&orderscnt(OP_BUY)!=0){
      lots=LastLiveLot(OP_BUY)*Multiply;
   if(StopLoss==0){SL=0;}else{SL=Ask-MathMax(StopLoss,minsltp)*point;}
  // if(TakeProfit==0){TP=0;}else{TP=Ask+MathMax(TakeProfit,minsltp)*point;}
   //if(Risk!=0)lots=(((AccountBalance()/100)/100)*Risk);
   if(lots<MarketInfo(Symbol(),MODE_MINLOT))lots=MarketInfo(Symbol(),MODE_MINLOT);
   if(lots>MarketInfo(Symbol(),MODE_MAXLOT))lots=MarketInfo(Symbol(),MODE_MAXLOT); 
  buy=OrderSend(Symbol(),OP_BUY,NormalizeDouble(lots,2),Ask,30,SL,0,"Buy Market",MagicNumber,0,clrBlue); 
  NewBar=false;
  }
  
  
  if(Bid-LastLivePrice(OP_SELL)>=PipStep*point&&orderscnt(OP_SELL)!=0){
        lots=LastLiveLot(OP_SELL)*Multiply;
   if(StopLoss==0){SL=0;}else{SL=Bid+MathMax(StopLoss,minsltp)*point;}
   //if(TakeProfit==0){TP=0;}else{TP=Bid-MathMax(TakeProfit,minsltp)*point;}
   //if(Risk!=0)lots=(((AccountBalance()/100)/100)*Risk);
   //if(LastProfit()<0&&MartingaleOption==FIRST_MARTINGALE)lots=LastLot()*Multiply;
   if(lots<MarketInfo(Symbol(),MODE_MINLOT))lots=MarketInfo(Symbol(),MODE_MINLOT);
   if(lots>MarketInfo(Symbol(),MODE_MAXLOT))lots=MarketInfo(Symbol(),MODE_MAXLOT); 
  sell=OrderSend(Symbol(),OP_SELL,NormalizeDouble(lots,2),Bid,30,SL,0,"Sell Market",MagicNumber,0,clrRed);
  NewBar=false;
  } 
  
  }
  

   
   if(TrailingStop!=0)DoTrail();
   
  }
//+------------------------------------------------------------------+
   bool AllowTradesByTime()
     {
      double Current_Time=TimeHour(TimeCurrent());

      if(Start_Hour==0) Start_Hour=24; if(Finish_Hour==0) Finish_Hour=24; if(Current_Time==0) Current_Time=24;

      if(Start_Hour<Finish_Hour)
         if( (Current_Time < Start_Hour) || (Current_Time >= Finish_Hour) ) return(false);

      if(Start_Hour>Finish_Hour)
         if( (Current_Time < Start_Hour) && (Current_Time >= Finish_Hour) ) return(false);

      return(true);
     }
     
     //=====
       double LastLot()
     {
      double cnt=0;
      for(int i=OrdersHistoryTotal();i>=0;i--)
        {
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber())
           {
            return(OrderLots());
           }
        }
      return(cnt);
     }
//***************************//
       double LastLiveLot(int tip)
     {
      double cnt=0;
      for(int i=OrdersTotal();i>=0;i--)
        {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber()&&OrderType()==tip)
           {
            return(OrderLots());
           }
        }
      return(cnt);
     }
//***************************//
       double LastLivePrice(int tip)
     {
      double cnt=0;
      for(int i=OrdersTotal();i>=0;i--)
        {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber()&&OrderType()==tip)
           {
            return(OrderOpenPrice());
           }
        }
      return(cnt);
     }
//***************************//
       double ProfitPips(int tip)
     {
      double profit=0;
      double loss=0;
      for(int i=OrdersTotal();i>=0;i--)
        {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber()&&OrderType()==tip)
           {
            if(OrderProfit()>0)profit+=MathMax(OrderOpenPrice(),OrderClosePrice())-MathMin(OrderOpenPrice(),OrderClosePrice());
            if(OrderProfit()<0)loss+=MathMax(OrderOpenPrice(),OrderClosePrice())-MathMin(OrderOpenPrice(),OrderClosePrice());
           }
        }
      return(profit-loss);
     }
//***************************//
  double LastProfit()
     {
      double cnt=0;
      for(int i=OrdersHistoryTotal();i>=0;i--)
        {
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber())
           {
            return(OrderProfit());
           }
        }
      return(cnt);
     }
//***************************//
  int orderscnt(int tip)
     {
      int cnt=0;
      for(int i=0;i<OrdersTotal();i++)
        {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber()&&OrderType()==tip)
           {
            cnt++;
           }
        }
      return(cnt);
     }
//***************************//

     void ModifyStopLoss(double ldStop) 
{
  bool   fm;
  double ldOpen=OrderOpenPrice();
  double ldTake=OrderTakeProfit();

  fm=OrderModify(OrderTicket(), ldOpen, ldStop, ldTake, 0, Pink);
}
 void DoTrail() 
{
  for (int i=0; i<OrdersTotal(); i++) 
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
    {
      if (OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber) 
      {
         if (OrderType()==OP_SELL) 
         {
         
                     if (OrderOpenPrice()-Bid>MathMax(TrailingStop,minsltp)*point
            &&NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(Bid,Digits)+MathMax(TrailingStop,minsltp)*point
            &&(OrderStopLoss()==0||OrderStopLoss()>OrderOpenPrice()))
            {
                  ModifyStopLoss(NormalizeDouble(Bid,Digits)+MathMax(TrailingStop,minsltp)*point);
            }
            
            
                                 if (OrderStopLoss()-Bid>MathMax(TrailingStop,minsltp)*point
            &&NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(Bid,Digits)+MathMax(TrailingStop,minsltp)*point
            &&(OrderStopLoss()!=0&&OrderStopLoss()<=OrderOpenPrice()))
            {
                  ModifyStopLoss(NormalizeDouble(Bid,Digits)+MathMax(TrailingStop,minsltp)*point);
            }
         
        
            
         }
         if (OrderType()==OP_BUY)
         {

                     if (Ask-OrderOpenPrice()>MathMax(TrailingStop,minsltp)*point
            &&NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(Ask,Digits)-MathMax(TrailingStop,minsltp)*point
            &&(OrderStopLoss()==0||OrderStopLoss()<OrderOpenPrice()))
            {
                  ModifyStopLoss(NormalizeDouble(Ask,Digits)-MathMax(TrailingStop,minsltp)*point);
            }
            
            
                                 if (Ask-OrderStopLoss()>MathMax(TrailingStop,minsltp)*point
            &&NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(Ask,Digits)-MathMax(TrailingStop,minsltp)*point
            &&(OrderStopLoss()!=0&&OrderStopLoss()>=OrderOpenPrice()))
            {
                  ModifyStopLoss(NormalizeDouble(Ask,Digits)-MathMax(TrailingStop,minsltp)*point);
            }
         }
      }
    }
  }
}
 //=============
              void CloseOrders(int tip) {
         int cnt=OrdersTotal();
         for(int i=cnt-1; i>=0; i--)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
            if(OrderSymbol()==Symbol()&& OrderMagicNumber()==MagicNumber&&OrderType()==tip)
                 {
                 
close=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),50,clrGreen);   
           }
       }
   


} 
//=======================

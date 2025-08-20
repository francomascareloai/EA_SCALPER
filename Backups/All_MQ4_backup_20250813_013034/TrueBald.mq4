//+------------------------------------------------------------------+
//|                                                     TrueBald.mq4 |
//|                                        Copyright © 2007, Abadan. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Abadan"

double Lots             =  0.1;
bool UseMM              =  true;
double PercentMM        =  2;
double  DeltaMM         =  10;
int     InitialBalance  =  10000;

double TakeProfit       =  80;
double TrailingStop     =  18;
double MaxLots          =   7;
double pips             =  23;
double per_K            =  3;
double per_D            =  7;
double slow             =  2;
double zoneBUY          =  15;
double zoneSELL         =  90;
 
 
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//######################################################################################################################################
double FirstLots()
   {
      double volume,TempVolume;      
      TempVolume=Lots;
      
      if (UseMM) TempVolume =0.00001*(AccountBalance()*(PercentMM+DeltaMM)-InitialBalance*DeltaMM); 
      
      volume=NormalizeDouble(TempVolume,1);
         
      if (volume>MarketInfo(Symbol(),MODE_MAXLOT)/4) volume=1.2;
      if (volume<MarketInfo(Symbol(),MODE_MINLOT)) volume=MarketInfo(Symbol(),MODE_MINLOT);
   
      return (volume);
   }
//######################################################################################################################################
//+------------------------------------------------------------------+
//| Проверка наличия свободной маржи            |
//+------------------------------------------------------------------+
bool CheckForEnoughMargin(double LotsNumber)
  {
    if (GetOneLotMargin(Symbol())*LotsNumber<AccountFreeMargin()) return(true); 
    else return(false);
  }
//######################################################################################################################################  
//+-------------------------------------------------------------------+
//| Вычисление необходимой маржи на один лот|
//+-------------------------------------------------------------------+
double GetOneLotMargin(string s)
  {
   double p;
   if ((StringSubstr(s, 0, 3) == "EUR")||(StringSubstr(s, 0, 3) == "GBP"))     
     {
      if (!IsTesting()) 
        return(MarketInfo(s, MODE_LOTSIZE)*MarketInfo(StringSubstr(s, 0, 3)+"USD",
                   MODE_BID)/AccountLeverage());
      else 
        {
         p = iClose(StringSubstr(s, 0, 3)+"USD", Period(), 
         iBarShift(StringSubstr(s, 0, 3)+"USD", Period(), CurTime(), true));         
         return(MarketInfo(s, MODE_LOTSIZE)*p/AccountLeverage());
        }     
     }
     
   if (StringSubstr(s, 0, 3) == "USD") 
     return(MarketInfo(s, MODE_LOTSIZE)/AccountLeverage());     
   
   return(77777777777777777777777777.0);   
  }
//######################################################################################################################################
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  double total,cnt,lot;
  double cenaoppos,l,sl;
  
  
  //pips=
  total=OrdersTotal();
    if(total<1)
    {  
    if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)>iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
      && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)<zoneBUY)
      {
        sl=NormalizeDouble(MaxLots*TrailingStop*Point+20*Point,Digits);
         OrderSend(Symbol(),OP_BUY,FirstLots(),Ask,3,Bid-sl,Ask+TakeProfit*Point,0,Green);
         }
     if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)<iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
      && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)>zoneSELL)
      {
         sl=NormalizeDouble(MaxLots*TrailingStop*Point+20*Point,Digits);
         OrderSend(Symbol(),OP_SELL,FirstLots(),Bid,3,Ask+sl,Bid-TakeProfit*Point,0,Red);
         }      
      }
    if(total==1 || total==2)      
      {
         for(cnt=0;cnt<total;cnt++)
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         cenaoppos=OrderOpenPrice();
         lot=NormalizeDouble(OrderLots()*2,1);
      
         if (lot>MarketInfo(Symbol(),MODE_MAXLOT)){lot=MarketInfo(Symbol(),MODE_MAXLOT);}
                  
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol())  
         {
            if(OrderType()==OP_BUY)   
            {            
               if((cenaoppos-pips*Point)>Ask)
                {
                 if (!CheckForEnoughMargin(lot)) return(0);
                 OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,Ask+TakeProfit*Point,0,Green);
                 return(0); 
                }
           }
         else 
           {            
            if((cenaoppos+pips*Point)<Bid)
              {
               if (!CheckForEnoughMargin(lot)) return(0);
               OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,Bid-TakeProfit*Point,0,Red);             
               return(0); 
              }
           }
        }
      }
      
      for(cnt=0;cnt<total;cnt++)
      {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY)
        {  
         if(TrailingStop>0)  
           {                 
            if(Bid-OrderOpenPrice()>Point*TrailingStop)
              {
               if(OrderStopLoss()<Bid-Point*TrailingStop)
                 {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,Ask+TakeProfit*Point,0,Green);
                  return(0);
                 }
              }
           }
         }
         
       else
            {
            if(TrailingStop>0)  
              {                 
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,Bid-TakeProfit*Point,0,Red);
                     return(0);
                    }
                 }
              }
           }
           
//----------------------------------
}}
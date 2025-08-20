//+------------------------------------------------------------------+
//|                                         Phoenix_v4_2_CONTEST.mq4 |
//|                                       Copyright © 2006, Hendrick |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Hendrick."

#define MAGICMA  20050610

extern double     Lots             = 1;
extern double     MaximumRisk      = 0.3;
extern double     DecreaseFactor   = 1;
extern bool       PrefSettings     = true;
extern bool       MM               = true;
extern bool       AccountIsMicro   = false;
extern int        TakeProfit       = 0;
extern int        StopLoss         = 0;
extern int        TrailingStop     = 0;


extern bool       UseSignal1       = true;
extern bool       UseSignal2       = true;
extern bool       UseSignal3       = true;
extern bool       UseSignal4       = true;
extern bool       UseSignal5       = true;

extern int        SMAPeriod        = 0;
extern int        SMA2Bars         = 0;
extern double     Percent          = 0;
extern int        EnvelopePeriod   = 0;
extern int        OSMAFast         = 0;
extern int        OSMASlow         = 0;
extern double     OSMASignal       = 0;

extern int        TradeFrom1       = 0;
extern int        TradeUntil1      = 24;
extern int        TradeFrom2       = 0;
extern int        TradeUntil2      = 0;
extern int        TradeFrom3       = 0;
extern int        TradeUntil3      = 0;
extern int        TradeFrom4       = 0;
extern int        TradeUntil4      = 0;

extern int        Fast_Period      = 0;
extern int        Fast_Price       = PRICE_OPEN;
extern int        Slow_Period      = 0;
extern int        Slow_Price       = PRICE_OPEN;
extern double     DVBuySell        = 0;
extern double     DVStayOut        = 0;


//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//---- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
  



//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();    
   int    losses=0;                 

   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);

   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }

   if(lot<0.1) lot=0.1;
   if(MM==false) lot=Lots;
   if(AccountIsMicro==true) lot=lot/10;
//--- for CONTEST only
   if(lot > 5) lot=5; 
   return(lot);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {

int res;

//==============PREFERRED SETTINGS==============================

if(PrefSettings == true)
{
   if(Symbol() == "USDJPY")
      {
      SMAPeriod      = 7;
      SMA2Bars       = 14;
      Percent        = 0.0032;
      TakeProfit     = 42;
      StopLoss       = 84;
      TrailingStop   = 0;
      OSMAFast       = 5;
      OSMASlow       = 30;
      OSMASignal     = 2;
      EnvelopePeriod = 2;
      Fast_Period    = 25;
      Slow_Period    = 15;
      DVBuySell      = 0.003;
      DVStayOut      = 0.024;
     
      }
}


//=====================SIGNAL1=======================

bool BuySignal1=false, SellSignal1=false;

double HighEnvelope1 = iEnvelopes(NULL,0,EnvelopePeriod,MODE_SMA,0,PRICE_CLOSE,Percent,MODE_UPPER,1);
double LowEnvelope1  = iEnvelopes(NULL,0,EnvelopePeriod,MODE_SMA,0,PRICE_CLOSE,Percent,MODE_LOWER,1);
double CloseBar1     = iClose(NULL,0,1);

if(UseSignal1)
{
   if(CloseBar1 > HighEnvelope1) {SellSignal1 = true;} 
   if(CloseBar1 < LowEnvelope1)   {BuySignal1  = true;}
}
else {SellSignal1=true;BuySignal1=true;}



//=====================SIGNAL2=======================

bool BuySignal2=false, SellSignal2=false;

double SMA1=iMA(NULL,0,SMAPeriod,0,MODE_SMA,5,1);
double SMA2=iMA(NULL,0,SMAPeriod,0,MODE_SMA,5,SMA2Bars);

if(UseSignal2)
{
   if(SMA2-SMA1>0) {BuySignal2  = true;}
   if(SMA2-SMA1<0) {SellSignal2 = true;}
}
else {SellSignal2=true;BuySignal2=true;}



//=====================SIGNAL3=======================

bool BuySignal3=false, SellSignal3=false;

double OsMABar2=iOsMA(NULL,0,OSMASlow,OSMAFast,OSMASignal,PRICE_CLOSE,2);
double OsMABar1=iOsMA(NULL,0,OSMASlow,OSMAFast,OSMASignal,PRICE_CLOSE,1);

if(UseSignal3)
{
   if(OsMABar2 > OsMABar1)  {SellSignal3 = true;}
   if(OsMABar2 < OsMABar1)  {BuySignal3  = true;}
}
else {SellSignal3=true;BuySignal3=true;}


      
//=====================SIGNAL4=======================  

   double diverge;
   bool BuySignal4=false,SellSignal4=false;
   
   diverge = divergence(Fast_Period, Slow_Period, Fast_Price, Slow_Price,0);

if(UseSignal4)
{
   if(diverge >= DVBuySell && diverge <= DVStayOut)
       {BuySignal4 = true;}
   if(diverge <= (DVBuySell*(-1)) && diverge >= (DVStayOut*(-1))) 
       {SellSignal4 = true;} 
}       
else {SellSignal4=true;BuySignal4=true;}


    
//=====================SIGNAL5=======================  

bool BuySignal5=false, SellSignal5=false;

if(UseSignal5)
{
   int iHour=TimeHour(LocalTime());
   int ValidTradeTime = F_ValidTradeTime(iHour);
   if(ValidTradeTime==true)
    {
    BuySignal5=true;
    SellSignal5=true;
    }
}
else {SellSignal5=true;BuySignal5=true;}


   

//=================END SIGNALS=====




//=================SELL CONDITIONS=====


if((SellSignal1==true) && (SellSignal2==true) && (SellSignal3==true) && (SellSignal4==true) && (SellSignal5==true))   
     {
     if(AccountFreeMargin()<(1000*LotsOptimized()))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());         return(0);          
        }
      res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"Phoenix3",MAGICMA,0,Red);
      return;
     }
//=================BUY CONDITIONS====


if((BuySignal1==true) && (BuySignal2==true) && (BuySignal3==true) && (BuySignal4==true) && (BuySignal5==true)) 
     {
     if(AccountFreeMargin()<(1000*LotsOptimized()))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());         return(0);
        }
      res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point,"Phoenix3",MAGICMA,0,Blue);
      return;
     }
     
//=================END SELL/BUY CONDITIONS==========================



  }


//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {

   for(int i=0;i<OrdersTotal();i++)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
         {
         if(OrderType() == OP_BUY)
            {
            if(TrailingStop > 0)
               {
               if((Bid-OrderOpenPrice()) > (Point*TrailingStop))
                  {
                  if((OrderStopLoss()) < (Bid-Point*TrailingStop))
                     {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,GreenYellow);
                     return(0);
                     }
                  } 
               }                  
 
            }

            if(OrderType() == OP_SELL)
               {
               if(TrailingStop > 0)
                  {
                  if(OrderOpenPrice()-Ask>Point*TrailingStop)
                     {
                     if(OrderStopLoss()>Ask+Point*TrailingStop)
                        {
                        OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                        return(0);              
                        }
                     }     
                  }
                }
             }
          }
     }

//======================Start function=======================


                                   

void start()
  {
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
//---- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//----
  }
  
//+------------------------------------------------------------------+

double divergence(int F_Period, int S_Period, int F_Price, int S_Price, int mypos)
  {
    int i;
//----
    double maF1, maF2, maS1, maS2;
    double dv1, dv2;
//----
    maF1 = iMA(Symbol(), 0, F_Period, 0, MODE_SMA, F_Price, mypos);
    maS1 = iMA(Symbol(), 0, S_Period, 0, MODE_SMA, S_Price, mypos);
    dv1 = (maF1 - maS1);

    maF2 = iMA(Symbol(), 0, F_Period, 0, MODE_SMA, F_Price, mypos + 1);
    maS2 = iMA(Symbol(), 0, S_Period, 0, MODE_SMA, S_Price, mypos + 1);
    dv2 = ((maF1 - maS1) - (maF2 - maS2));
//----
    return(dv1 - dv2);
  }
 
 //=============== FUNCTION VALID TRADE TIME

bool F_ValidTradeTime (int iHour)
   {
      if(((iHour >= TradeFrom1) && (iHour <= (TradeUntil1-1)))||((iHour>= TradeFrom2) && (iHour <= (TradeUntil2-1)))||((iHour >= TradeFrom3)&& (iHour <= (TradeUntil3-1)))||((iHour >= TradeFrom4) && (iHour <=(TradeUntil4-1))))
      {
       return (true);
      }
      else
       return (false);
   }  



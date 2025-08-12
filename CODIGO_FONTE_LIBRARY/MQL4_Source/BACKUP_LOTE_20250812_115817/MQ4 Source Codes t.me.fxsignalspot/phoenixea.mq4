//+------------------------------------------------------------------+
//|                                             Phoenix_5_6_03.mq4   |
//|                                       Phoenix_5_6_03.mq4         |
//|                                                                  |
//+------------------------------------------------------------------+


#define MAGICMA_A  20050610
#define MAGICMA_B  20060611

#define MAGICMA01  20050612
#define MAGICMA02  20060613
#define MAGICMA03  20060614

extern string     GeneralSettings         = "===== General Settings ============================";
extern int        PhoenixMode             = 3;
extern double     Lots                    = 1;
extern double     MaximumRisk             = 0.05;
extern int        DecreaseFactor          = 0;
extern bool       MM                      = true;
extern bool       AccountIsMicro          = false;

extern bool       PrefSettings            = true;

extern int        CloseAfterHours         = 0;
extern int        BreakEvenAfterPips      = 0;

extern string     Mode1                   = "====== Phoenix Mode 1 (Classic) ==================";
extern int        TakeProfit              = 0;
extern int        StopLoss                = 0;
extern int        TrailingStop            = 0;

extern string     Mode2                   = "====== Phoenix Mode 2 (Second trade)==============";
extern int        Mode2_OpenTrade_2       = 0;
extern int        Mode2_TakeProfit        = 0;
extern int        Mode2_StopLoss          = 0;
extern bool       Mode2_CloseFirstTrade   = false;
     
extern string     Mode3                   = "====== Phoenix Mode 3 (Three trades at once) =====";
extern int        Mode3_CloseTrade2_3     = 0;
extern int        Mode3_TakeProfit        = 0;
extern int        Mode3_StopLoss          = 0;

extern string     Signal1                 = "====== Signal 1 ===================================";
extern bool       UseSignal1              = true;
extern double     Percent                 = 0;
extern int        EnvelopePeriod          = 0;

extern string     Signal2                 = "====== Signal 2 ==================================";
extern bool       UseSignal2              = true;
extern int        SMAPeriod               = 0;
extern int        SMA2Bars                = 0;

extern string     Signal3                 = "====== Signal 3 ==================================";
extern bool       UseSignal3              = true;
extern int        OSMAFast                = 0;
extern int        OSMASlow                = 0;
extern double     OSMASignal              = 0;

extern string     Signal4                 = "====== Signal 4 ==================================";
extern bool       UseSignal4              = true;
extern int        Fast_Period             = 0;
extern int        Fast_Price              = PRICE_OPEN;
extern int        Slow_Period             = 0;
extern int        Slow_Price              = PRICE_OPEN;
extern double     DVBuySell               = 0;
extern double     DVStayOut               = 0;

extern string     Signal5                 = "====== Signal 5 =================================";
extern bool       UseSignal5              = true;
extern int        TradeFrom1              = 0;
extern int        TradeUntil1             = 24;
extern int        TradeFrom2              = 0;
extern int        TradeUntil2             = 0;
extern int        TradeFrom3              = 0;
extern int        TradeUntil3             = 0;
extern int        TradeFrom4              = 0;
extern int        TradeUntil4             = 0;

double Poin;

int init()
{
   //Checking for unconvetional Point digits number
   if (Point == 0.00001) Poin = 0.0001; //5 digits
   else if (Point == 0.001) Poin = 0.01; //3 digits
   else Poin = Point; //Normal

//+------------------------------------------------------------------+
//| START Preffered Settings                                         |
//+------------------------------------------------------------------+

if(PrefSettings == true)
{
   if((Symbol() == "USDJPY") || (Symbol() == "USDJPYm"))
      {     
  
      Mode2_OpenTrade_2    = 0;
      Mode2_TakeProfit     = 50;
      Mode2_StopLoss       = 60;
      

      Mode3_CloseTrade2_3  = 30;
      Mode3_TakeProfit     = 100;
      Mode3_StopLoss       = 55;
      
      Percent              = 0.0032;
      EnvelopePeriod       = 2;
      
      TakeProfit           = 42;
      StopLoss             = 84;
      TrailingStop         = 0;
      SMAPeriod            = 2;
      SMA2Bars             = 18;
      OSMAFast             = 5;
      OSMASlow             = 22;
      OSMASignal           = 2;
      
      Fast_Period          = 25;
      Slow_Period          = 15;
      DVBuySell            = 0.0029;
      DVStayOut            = 0.024;
      }

   if((Symbol() == "EURJPY") || (Symbol() == "EURJPYm"))
      {
      
      Mode2_OpenTrade_2    = 18;
      Mode2_TakeProfit     = 70;
      Mode2_StopLoss       = 30;
      

      Mode3_CloseTrade2_3  = 55;
      Mode3_TakeProfit     = 70;
      Mode3_StopLoss       = 80;      

      Percent              = 0.007;
      EnvelopePeriod       = 2;
      
      TakeProfit           = 42;
      StopLoss             = 84;
      TrailingStop         = 0;
      SMAPeriod            = 4;
      SMA2Bars             = 16;
      OSMAFast             = 11;
      OSMASlow             = 20;
      OSMASignal           = 14;
      
      Fast_Period          = 20;
      Slow_Period          = 10;
      DVBuySell            = 0.0078;
      DVStayOut            = 0.026;
      }

   if((Symbol() == "GBPJPY") || (Symbol() == "GBPJPYm"))
      {
      
      Mode2_OpenTrade_2    = 2;
      Mode2_TakeProfit     = 130;
      Mode2_StopLoss       = 80;
      

      Mode3_CloseTrade2_3  = 40;
      Mode3_TakeProfit     = 90;
      Mode3_StopLoss       = 80;      

      
      Percent              = 0.0072;
      EnvelopePeriod       = 2;
      
      TakeProfit           = 42;
      StopLoss             = 84;
      TrailingStop         = 0;
      SMAPeriod            = 8;
      SMA2Bars             = 12;
      OSMAFast             = 5;
      OSMASlow             = 36;
      OSMASignal           = 10;
      
      Fast_Period          = 17;
      Slow_Period          = 28;
      DVBuySell            = 0.0034;
      DVStayOut            = 0.063;
      }
      
   if((Symbol() == "USDCHF") || (Symbol() == "USDCHFm"))
      {
      
      Mode2_OpenTrade_2    = 10;
      Mode2_TakeProfit     = 90;
      Mode2_StopLoss       = 65;
      

      Mode3_CloseTrade2_3  = 85;
      Mode3_TakeProfit     = 130;
      Mode3_StopLoss       = 80;      

      
      Percent              = 0.0056;
      EnvelopePeriod       = 10;
      
      TakeProfit           = 42;
      StopLoss             = 84;
      TrailingStop         = 0;
      SMAPeriod            = 5;
      SMA2Bars             = 9;
      OSMAFast             = 5;
      OSMASlow             = 12;
      OSMASignal           = 11;
      
      Fast_Period          = 5;
      Slow_Period          = 20;
      DVBuySell            = 0.00022;
      DVStayOut            = 0.0015;
      }
      
   if((Symbol() == "GBPUSD") || (Symbol() == "GBPUSDm"))
      {
      
      Mode2_OpenTrade_2    = 5;
      Mode2_TakeProfit     = 95;
      Mode2_StopLoss       = 90;
      

      Mode3_CloseTrade2_3  = 90;
      Mode3_TakeProfit     = 110;
      Mode3_StopLoss       = 80;      

      
      Percent              = 0.0023;
      EnvelopePeriod       = 6;
      
      TakeProfit           = 42;
      StopLoss             = 84;
      TrailingStop         = 0;
      SMAPeriod            = 3;
      SMA2Bars             = 14;
      OSMAFast             = 23;
      OSMASlow             = 17;
      OSMASignal           = 15;
      
      Fast_Period          = 25;
      Slow_Period          = 37;
      DVBuySell            = 0.00042;
      DVStayOut            = 0.05;
      }      
}
return(0);
}

//+------------------------------------------------------------------+
//| END Preffered Settings                                           |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| START EA                                                         |
//+------------------------------------------------------------------+

void start()
   {
   if(Bars<100)
      {
      Print("bars less than 100");
      return(0);  
      }

   if(PhoenixMode==1)//Phoenix Classic
      {
      CheckOpenTrade();     
      if(CloseAfterHours != 0)  CheckCloseAfterHours();
      if(!StopLoss==0)              CheckTrailingStop();
      if(BreakEvenAfterPips != 0)        CheckBreakEven();
      }
      
         
   if(PhoenixMode==2)//Phoenix Second Trade
      {
      CheckOpenTrade();     
      if(CloseAfterHours != 0)  CheckCloseAfterHours();
      CheckSecondTrade();
      }

   if(PhoenixMode==3)//Phoenix 123
      {
      CheckOpenTradeMode123();     
      Mode3_MoveSL_Trade_2_3();
      Mode3_MoveSL_Trade_3();
      if(Mode3_CloseTrade2_3 != 0) CheckCloseTrade23();
      }
      
   } 
     
//+------------------------------------------------------------------+
//| END EA                                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Calculate open positions                          |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int count=0;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MAGICMA_A || OrderMagicNumber()==MAGICMA_B))
        {
         count++;
        }
     }
     return(count);
  }
//+------------------------------------------------------------------+
//| STOP Function Calculate open positions                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Check Open Trade                                  |
//+------------------------------------------------------------------+
int CheckOpenTrade()
{      
int Signal=0, err = 0, total = OrdersTotal();

if(CalculateCurrentOrders(Symbol()) < 1)
   {  
   if(CheckSignal(Signal)==1)
      {
      if(OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Bid+StopLoss*Poin,Bid-TakeProfit*Poin,"FirstTrade",MAGICMA_A,0,Red) < 0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
       return(0);
      }
      
   if(CheckSignal(Signal)==2)
      {
      if(OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Ask-StopLoss*Poin,Ask+TakeProfit*Poin,"FirstTrade",MAGICMA_A,0,Blue) < 0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
      return(0);
      }
   }
}
//+------------------------------------------------------------------+
//| END Function Check Open Trade                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START MODE 3 Function Check Open Trade                           |
//+------------------------------------------------------------------+
int CheckOpenTradeMode123()
{
     
int Signal = 0, err = 0, total = OrdersTotal(), decimalPlaces=1;
if(AccountIsMicro==true) decimalPlaces=2;
double lots123 = NormalizeDouble(LotsOptimized()/3,decimalPlaces);

if(lots123 < 0.1 && AccountIsMicro==false) {lots123=0.1;}
if(lots123 < 0.01 && AccountIsMicro==true) {lots123=0.01;}

if(Mode3CalculateCurrentOrders(Symbol()) < 1)      
   {
   if(CheckSignal(Signal)==1)
      {
      if(OrderSend(Symbol(),OP_SELL,lots123,Bid,3,Bid+Mode3_StopLoss*Poin,Bid-NormalizeDouble(Mode3_TakeProfit/2,0)*Poin,"Mode3_FirstTrade",MAGICMA01,0,Red)<0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
           
      if(OrderSend(Symbol(),OP_SELL,lots123,Bid,3,Bid+Mode3_StopLoss*Poin,Bid-Mode3_TakeProfit*Poin,"Mode3_SecondTrade",MAGICMA02,0,Red)<0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
      
      if(OrderSend(Symbol(),OP_SELL,lots123,Bid,3,Bid+Mode3_StopLoss*Poin,Bid-NormalizeDouble(Mode3_TakeProfit*1.5,0)*Poin,"Mode3_ThirdTrade",MAGICMA03,0,Red)<0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
      return(0);
      }
      
   if(CheckSignal(Signal)==2)
      {
      if(OrderSend(Symbol(),OP_BUY,lots123,Ask,3,Ask-Mode3_StopLoss*Poin,Ask+NormalizeDouble(Mode3_TakeProfit/2,0)*Poin,"Mode3_FirstTrade",MAGICMA01,0,Blue)<0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }      
      if(OrderSend(Symbol(),OP_BUY,lots123,Ask,3,Ask-Mode3_StopLoss*Poin,Ask+Mode3_TakeProfit*Poin,"Mode3_SecondTrade",MAGICMA02,0,Blue)<0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
      if(OrderSend(Symbol(),OP_BUY,lots123,Ask,3,Ask-Mode3_StopLoss*Poin,Ask+NormalizeDouble(Mode3_TakeProfit*1.5,0)*Poin,"Mode3_ThirdTrade",MAGICMA03,0,Blue)<0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
      return(0);
      }
   } 
}

//+------------------------------------------------------------------+
//| END Function Check Open Trade                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Check Second Trade                                |
//+------------------------------------------------------------------+

void CheckSecondTrade()
{
int err = 0, total = OrdersTotal();

for(int z = total - 1; z >= 0; z --)
   {
   if(!OrderSelect( z, SELECT_BY_POS))
      {
      err = GetLastError();
      Print("OrderSelect( ", z, ", SELECT_BY_POS ) - Error #",err );
      continue;
      }

   if(OrderSymbol() != Symbol()) continue;

   if(OrderMagicNumber() == MAGICMA_B) break;
 
   if(OrderMagicNumber() != MAGICMA_A) continue;

   if(OrderType() == OP_BUY && (Bid-OrderOpenPrice() > Poin*Mode2_OpenTrade_2))
      {   
      if(OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Ask - Mode2_StopLoss * Poin,Ask + Mode2_TakeProfit * Poin,"Mode2_SecondTrade",MAGICMA_B,0,Blue) < 0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
      if(Mode2_CloseFirstTrade==true) {CloseFirstTrade();}
      return(0);  
      }

   if(OrderType() == OP_SELL && (OrderOpenPrice()-Ask > Poin*Mode2_OpenTrade_2))
      {
      if(OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Bid + Mode2_StopLoss * Poin,Bid - Mode2_TakeProfit*Poin,"Mode2_SecondTrade",MAGICMA_B,0,Red) < 0)
         {
         err = GetLastError();
         Print("Error Ordersend(",err,"): ");
         return(-1);
         }
      if(Mode2_CloseFirstTrade==true) {CloseFirstTrade();}
      return(0);
      }
   }            

}

//+------------------------------------------------------------------+
//| END Function Check Second Trade                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Check Close Trade 2 And 3                         |
//+------------------------------------------------------------------+
void CheckCloseTrade23()
{

int err = 0, total = OrdersTotal();
bool CloseTrade=false;

for(int z = total - 1; z >= 0; z --)
   {
   if(!OrderSelect( z, SELECT_BY_POS))
      {
      err = GetLastError();
      Print("OrderSelect( ", z, ", SELECT_BY_POS ) - Error #",err );
      continue;
      }

   if(OrderSymbol() != Symbol()) continue;

   if(OrderMagicNumber() != MAGICMA01) continue;
   
   if(OrderType() == OP_BUY && (OrderOpenPrice()-Bid > Poin * Mode3_CloseTrade2_3)) {CloseTrade=true;}
   if(OrderType() == OP_SELL && (Ask-OrderOpenPrice() > Poin * Mode3_CloseTrade2_3)) {CloseTrade=true;}

   if(CloseTrade)
      {
      for(int y = total - 1; y >= 0; y --)
         {
         if(!OrderSelect( y, SELECT_BY_POS))
            {
            err = GetLastError();
            Print("OrderSelect( ", y, ", SELECT_BY_POS ) - Error #",err );
            continue;
            }
         if(OrderSymbol() != Symbol()) continue;

         if(OrderMagicNumber() == MAGICMA02 || OrderMagicNumber() == MAGICMA03)
            {
            if(OrderType() == OP_BUY)
               {
               if(OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet)<0)
                  {
                  err = GetLastError();
                  Print("Error Ordersend(",err,"): ");
                  return(-1);
                  }
               return(0); 
               }
            if(OrderType() == OP_SELL)
               {
               if(OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet)<0)
                  {      
                  err = GetLastError();
                  Print("Error Ordersend(",err,"): ");
                  return(-1);
                  }
              return(0); 
               }
             }
}
}
}
}


//+------------------------------------------------------------------+
//| END Function Check Close Trade 2 And 3                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Check First Trade Mode3                                         |
//+------------------------------------------------------------------+

void Mode3_MoveSL_Trade_2_3()
{

int err = 0, total = OrdersTotal(), history = HistoryTotal();
bool ChangeStopLoss = false;

for(int z = history - 1; z >= 0; z --)
   {
   if(!OrderSelect( z,SELECT_BY_POS,MODE_HISTORY))
      {
      err = GetLastError();
      Print("OrderSelect( ", z, ", SELECT_BY_POS ) - Error #",err );
      continue;
      }

   if(OrderSymbol() != Symbol()) continue;

   if(OrderMagicNumber() == MAGICMA03) break;
   
   if(OrderMagicNumber() == MAGICMA02) break;
 
   if(OrderMagicNumber() != MAGICMA01) continue;

   if(OrderProfit() > 0) 
      {
      ChangeStopLoss=true;
      break;
      }
   }


  if(ChangeStopLoss==true)
   {
   for(int y = total - 1; y >= 0; y --)
      {
      if(!OrderSelect(y,SELECT_BY_POS))
         {
         err = GetLastError();
         Print("OrderSelect( ", y, ", SELECT_BY_POS ) - Error #",err );
         continue;
         }

      if(OrderSymbol() != Symbol()) continue;

      if(OrderMagicNumber() == MAGICMA02 || OrderMagicNumber() == MAGICMA03)
         {
         if(OrderType()==OP_BUY)
            {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,GreenYellow)<0)
            {
            err = GetLastError();
            Print("OrderSelect( ", y, ", SELECT_BY_POS ) - Error #",err );
            continue;
            }
//         return(0);  
         }

         if(OrderType()==OP_SELL)
         {
         if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,GreenYellow)<0)
            {
            err = GetLastError();
            Print("OrderSelect( ", y, ", SELECT_BY_POS ) - Error #",err );
            continue;
            }
//         return(0);  
         }
}      
}
}
}
//}
//+------------------------------------------------------------------+
//| END Check First Trade Mode 3                                     |
//+------------------------------------------------------------------+
 
 
//+------------------------------------------------------------------+
//| START Check Second Trade Mode3                                   |
//+------------------------------------------------------------------+

void Mode3_MoveSL_Trade_3()
{

double NewSLTrade3B,NewSLTrade3S;
int err = 0, total = OrdersTotal(), history = HistoryTotal();
bool ChangeStopLoss = false;

for(int z = history - 1; z >= 0; z --)
   {
   if(!OrderSelect( z,SELECT_BY_POS,MODE_HISTORY))
      {
      err = GetLastError();
      Print("OrderSelect( ", z, ", SELECT_BY_POS ) - Error #",err );
      continue;
      }

   if(OrderSymbol() != Symbol()) continue;

   if(OrderMagicNumber() == MAGICMA03) break;
   
   if(OrderMagicNumber() == MAGICMA01) break;
 
   if(OrderMagicNumber() != MAGICMA02) continue;

   if(OrderProfit() > 0) 
      {
      for(int y = total - 1; y >= 0; y --)
         {
         if(!OrderSelect(y,SELECT_BY_POS))
            {
            err = GetLastError();
            Print("OrderSelect( ", y, ", SELECT_BY_POS ) - Error #",err );
            continue;
            }

         if(OrderSymbol() != Symbol()) continue;

         if(OrderMagicNumber() == MAGICMA03)
            {
            if(OrderType()==OP_BUY)
               {
               NewSLTrade3B=OrderOpenPrice()+NormalizeDouble(((OrderTakeProfit()-OrderOpenPrice())/2),Digits);
               if(OrderModify(OrderTicket(),OrderOpenPrice(),NewSLTrade3B,OrderTakeProfit(),0,GreenYellow)<0)
                  {
                  err = GetLastError();
                  Print("OrderSelect( ", y, ", SELECT_BY_POS ) - Error #",err );
                  continue;
                  }
               return(0);  
               }

            if(OrderType()==OP_SELL)
               {
               NewSLTrade3S=OrderOpenPrice()-NormalizeDouble(((OrderOpenPrice()-OrderTakeProfit())/2),Digits);
               if(OrderModify(OrderTicket(),OrderOpenPrice(),NewSLTrade3S,OrderTakeProfit(),0,GreenYellow)<0)
                  {
                  err = GetLastError();
                  Print("OrderSelect( ", y, ", SELECT_BY_POS ) - Error #",err );
                  continue;
                  }
               return(0);  
               }
}      
}
}
}
}

//+------------------------------------------------------------------+
//| END Check Second Trade Mode 3                                    |
//+------------------------------------------------------------------+ 
 
  
//+------------------------------------------------------------------+
//| START Function Diverge                                           |
//+------------------------------------------------------------------+

double divergence(int F_Period, int S_Period, int F_Price, int S_Price, int mypos)
  {
    int i;
    double maF1, maF2, maS1, maS2;

    maF2 = iMA(Symbol(), 0, F_Period, 0, MODE_SMA, F_Price, mypos + 1);
    maS2 = iMA(Symbol(), 0, S_Period, 0, MODE_SMA, S_Price, mypos + 1);

    return(maF2-maS2);
  }

//+------------------------------------------------------------------+
//| END Function Diverge                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Valid Trade Time                                  |
//+------------------------------------------------------------------+

bool F_ValidTradeTime (int iHour)
   {
      if(((iHour >= TradeFrom1) && (iHour <= (TradeUntil1-1)))||((iHour>= TradeFrom2) && (iHour <= (TradeUntil2-1)))||((iHour >= TradeFrom3)&& (iHour <= (TradeUntil3-1)))||((iHour >= TradeFrom4) && (iHour <=(TradeUntil4-1))))
      {
       return (true);
      }
      else
       return (false);
   }  

//+------------------------------------------------------------------+
//| END Function Valid Trade Time                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Check Close Trade After x Hours                            |
//+------------------------------------------------------------------+

void CheckCloseAfterHours()
{
int total = OrdersTotal();

for(int cnt=0;cnt<total;cnt++)
   {
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
   if(OrderType()<=OP_SELL &&
      OrderSymbol()==Symbol() &&
      OrderMagicNumber()==MAGICMA_A)
      {            
         if((CurTime()-OrderOpenTime())>(CloseAfterHours*3600) && OrderProfit()<0)
            {
            OrderClose(OrderTicket(),OrderLots(),Bid,10,Violet);
            }
      }
   }
}

//+------------------------------------------------------------------+
//| END Check Close Trade After x Hours                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Check Signals                                     |
//+------------------------------------------------------------------+

//=====================SIGNAL1========================
int CheckSignal(int Signal)
{
Signal=0;

bool BuySignal1=false, SellSignal1=false;

double HighEnvelope1 = iEnvelopes(NULL,0,EnvelopePeriod,MODE_SMA,0,PRICE_CLOSE,Percent,MODE_UPPER,1);
double LowEnvelope1  = iEnvelopes(NULL,0,EnvelopePeriod,MODE_SMA,0,PRICE_CLOSE,Percent,MODE_LOWER,1);
double CloseBar1     = iClose(NULL,0,1);

if(UseSignal1)
{
   if(CloseBar1 > HighEnvelope1) {SellSignal1 = true;} 
   if(CloseBar1 < LowEnvelope1)  {BuySignal1  = true;}
}
else {SellSignal1=true;BuySignal1=true;}



//=====================SIGNAL2========================

bool BuySignal2=false, SellSignal2=false;

double SMA1=iMA(NULL,0,SMAPeriod,0,MODE_SMA,PRICE_CLOSE,1);
double SMA2=iMA(NULL,0,SMAPeriod,0,MODE_SMA,PRICE_CLOSE,SMA2Bars);

if(UseSignal2)
{
   if(SMA2-SMA1>0) {BuySignal2  = true;}
   if(SMA2-SMA1<0) {SellSignal2 = true;}
}
else {SellSignal2=true;BuySignal2=true;}



//=====================SIGNAL3========================

bool BuySignal3=false, SellSignal3=false;

double OsMABar2=iOsMA(NULL,0,OSMASlow,OSMAFast,OSMASignal,PRICE_CLOSE,2);
double OsMABar1=iOsMA(NULL,0,OSMASlow,OSMAFast,OSMASignal,PRICE_CLOSE,1);

if(UseSignal3)
{
   if(OsMABar2 > OsMABar1)  {SellSignal3 = true;}
   if(OsMABar2 < OsMABar1)  {BuySignal3  = true;}
}
else {SellSignal3=true;BuySignal3=true;}


      
//=====================SIGNAL4========================  

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

if((SellSignal1==true) && (SellSignal2==true) && (SellSignal3==true) && (SellSignal4==true) && (SellSignal5==true)) return(1);  
if((BuySignal1==true) && (BuySignal2==true) && (BuySignal3==true) && (BuySignal4==true) && (BuySignal5==true)) return(2);
}

//+------------------------------------------------------------------+
//| END Function Check Signals                                       |
//+------------------------------------------------------------------+   

//+------------------------------------------------------------------+
//| START Calculate optimal lot size                                 |
//+------------------------------------------------------------------+

double LotsOptimized()
  {
  if(MM==false) return(Lots);
   double lot=Lots;
   int    orders=HistoryTotal();
   int    losses=0;
   int    decimalPlaces=1;
   
   if(AccountIsMicro==true) decimalPlaces=2;

   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,decimalPlaces);
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
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,decimalPlaces);
     }

   if(lot<0.1 && AccountIsMicro==false) lot=0.1;
   if(lot<0.01 && AccountIsMicro==true) lot=0.01;
   if(lot>99) lot=99;
   return(lot);

  }
  
//+------------------------------------------------------------------+
//| END Calculate optimal lot size                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| START Function Check TrailingStop                                |
//+------------------------------------------------------------------+
void CheckTrailingStop()
{
   for(int i=0;i<OrdersTotal();i++)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA_A || OrderSymbol()!=Symbol()) continue;
   
      if(OrderType() == OP_BUY)
         {
         if(((Bid - OrderOpenPrice()) > (Poin * TrailingStop)) && (OrderStopLoss() < (Bid - Poin * TrailingStop)))
            OrderModify(
                        OrderTicket(),
                        OrderOpenPrice(),
                        Bid - Poin * TrailingStop,
                        OrderTakeProfit(),
                        0,
                        GreenYellow);
         }
      
      if(OrderType() == OP_SELL)
         {
         if(((OrderOpenPrice() - Ask) > (Poin * TrailingStop)) && (OrderStopLoss() > (Ask + Poin * TrailingStop)))
            OrderModify(
                        OrderTicket(),
                        OrderOpenPrice(),
                        Ask + Poin * TrailingStop,
                        OrderTakeProfit(),
                        0,
                        Red);
         }            
      }
}
//+------------------------------------------------------------------+
//| END Function Check TrailingStop                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| START Function Check BreakEven                                   |
//+------------------------------------------------------------------+

void CheckBreakEven()
{
for(int i=0;i<OrdersTotal();i++)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA_A || OrderSymbol()!=Symbol()) continue;
   
      if(OrderType() == OP_BUY)
         {
         if((Bid-OrderOpenPrice()) > (Poin*BreakEvenAfterPips))
            OrderModify(
                        OrderTicket(),
                        OrderOpenPrice(),
                        OrderOpenPrice(),
                        OrderTakeProfit(),
                        0,
                        GreenYellow);
         }
      
      if(OrderType() == OP_SELL)
         {
         if((OrderOpenPrice()-Ask) > (Poin*BreakEvenAfterPips))
            OrderModify(
                        OrderTicket(),
                        OrderOpenPrice(),
                        OrderOpenPrice(),
                        OrderTakeProfit(),
                        0,
                        Red);
         }            
      }
}

//+------------------------------------------------------------------+
//| END Function Check BreakEven                                 |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| START Function Close First Trade                                 |
//+------------------------------------------------------------------+


int CloseFirstTrade()
{
   for(int i=0;i<OrdersTotal();i++)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA_A || OrderSymbol()!=Symbol()) continue;
      
         OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); 
         return(0); 
      }
}  
//+------------------------------------------------------------------+
//| END Function Close First Trade                                   |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| START Function Calculate Current Orders Mode 3                   |
//+------------------------------------------------------------------+
int Mode3CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(
      (OrderSymbol()==Symbol()) && 
      ((OrderMagicNumber()==MAGICMA01) ||
       (OrderMagicNumber()==MAGICMA02) || 
       (OrderMagicNumber()==MAGICMA03)))
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
    return(buys+sells);
  }
//+------------------------------------------------------------------+
//| STOP Function Calculate Current Orders Mode 3                    |
//+------------------------------------------------------------------+


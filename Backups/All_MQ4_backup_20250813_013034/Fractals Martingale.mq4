//+------------------------------------------------------------------+
//|             Fractals Martingale                                  |
//|             http://algorithmic-trading-ea-mt4.000webhostapp.com/ |
//|                                                    AHARON TZADIK |
//+------------------------------------------------------------------+
#property copyright   "AHARON TZADIK"
#property link        "http://algorithmic-trading-ea-mt4.000webhostapp.com/"
#property version     "1.00"
#property strict



extern bool        USEMOVETOBREAKEVEN=true;//Enable "no loss"
extern double         WHENTOMOVETOBE=10;      //When to move break even
extern double         PIPSTOMOVESL=5;         //How much pips to move sl
extern double      Lots=0.01;              //Lots size 
extern double         TrailingStop=40;        //TrailingStop 
extern double         Stop_Loss=20;           //Stop Loss  
extern int         MagicNumber=1234;       //MagicNumber 
input double       TakeProfit=50;          //TakeProfit
extern    double   Multiply=2.0;         // Multiplier value every step of new trade
                                         //extern int         period=50;
bool               FractalsUp=false;
bool               FractalsDown=false;
double             FractalsUpPrice=0;
double             FractalsDownPrice=0;
int                FractalsLimit=200;
static int         losses=0;
int           err;
int total=0;
double
Lot,Dmax,Dmin,// Amount of lots in a selected order
Lts,                             // Amount of lots in an opened order
Min_Lot,                         // Minimal amount of lots
Step,                            // Step of lot size change
Free,                            // Current free margin
One_Lot,                         // Price of one lot
Price,                           // Price of a selected order,
pips,
MA_1,MA_2,MA_3,MACD_SIGNAL;
int Type,freeze_level,Spread;
//--- price levels for orders and positions
double priceopen,stoploss,takeprofit;
//--- ticket of the current order 
int orderticket;

//--------------------------------------------------------------- 3 --
int
Period_MA_2,  Period_MA_3,       // Calculation periods of MA for other timefr.
Period_MA_02, Period_MA_03,      // Calculation periods of supp. MAs
K2,K3,T;
//---

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--------------------------------------------------------------- 5 --
   switch(Period())                 // Calculating coefficient for..
     {                              // .. different timeframes
      case     1: K2=5;K3=15;T=PERIOD_M15; break;// Timeframe M1
      case     5: K2=3;K3= 6;T=PERIOD_M30; break;// Timeframe M5
      case    15: K2=2;K3= 4;T=PERIOD_H1; break;// Timeframe M15
      case    30: K2=2;K3= 8;T=PERIOD_H4; break;// Timeframe M30
      case    60: K2=4;K3=24;T=PERIOD_D1; break;// Timeframe H1
      case   240: K2=6;K3=42;T=PERIOD_W1; break;// Timeframe H4
      case  1440: K2=7;K3=30;T=PERIOD_MN1; break;// Timeframe D1
      case 10080: K2=4;K3=12; break;// Timeframe W1
      case 43200: K2=3;K3=12; break;// Timeframe MN
     }

   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize==0.00001 || ticksize==0.001)
      pips=ticksize*10;
   else pips=ticksize;
   return(INIT_SUCCEEDED);
//--- distance from the activation price, within which it is not allowed to modify orders and positions
   freeze_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   if(freeze_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_FREEZE_LEVEL=%d: order or position modification is not allowed,"+
                  " if there are %d points to the activation price",freeze_level,freeze_level);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   stop();
   if(USEMOVETOBREAKEVEN) MOVETOBREAKEVEN();
   Trail1();
   int   ticket;
// Check for New Bar (Compatible with both MQL4 and MQL5)
   static datetime dtBarCurrent=WRONG_VALUE;
   datetime dtBarPrevious=dtBarCurrent;
   dtBarCurrent=(datetime) SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   bool NewBarFlag=(dtBarCurrent!=dtBarPrevious);
// initial data checks
// it is important to make sure that the expert works with a normal
// chart and the user did not make any mistakes setting external 
// variables (Lots, StopLoss, TakeProfit, 
// TrailingStop) in our case, we check TakeProfit
// on a chart of less than 100 bars
//---
   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return;
     }
//--- to simplify the coding and speed up access data are put into internal variables     
//+------------------------------------------------------------------+
   double middleBB=iBands(Symbol(),0,20, 2,0,0,MODE_MAIN,1);//middle
   double lowerBB=iBands(Symbol(),0,20, 2,0,0,MODE_LOWER,1);//lower
   double upperBB=iBands(Symbol(),0,20, 2,0,0,MODE_UPPER,1);//upper
//+------------------------------------------------------------------+                                        
   double  MacdMAIN=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
//--------------------------------------------------------------------------------------------------

   if(getOpenOrders()==0)

     {
      //--- no opened orders identified
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
      double lot=getLots();
      if(NewBarFlag)
        {
         ticket=0;
         //--- check for long position (BUY) possibility
         //+------------------------------------------------------------------+ 
         //| BUY                      BUY                 BUY                 |
         //+------------------------------------------------------------------+
         if(Fractals()==1)

           {
            if(CheckVolumeValue(lot))
               ticket=OrderSend(Symbol(),OP_BUY,lot,ND(Ask),3,NDTP(Bid-Stop_Loss*pips),NDTP(Bid+TakeProfit*pips),"renko",MagicNumber,0,PaleGreen);
            if(ticket>0)
              {
               if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                  Print("BUY order opened : ",OrderOpenPrice());
              }
            else
               Print("Error opening BUY order : ",GetLastError());
            return;
           }
         //--- check for short position (SELL) possibility
         //+------------------------------------------------------------------+
         //| SELL             SELL                       SELL                 |
         //+------------------------------------------------------------------+ 
         if(Fractals()==2)
           {
            if(CheckVolumeValue(lot))
               ticket=OrderSend(Symbol(),OP_SELL,lot,ND(Bid),3,NDTP(Ask+Stop_Loss*pips),NDTP(Ask-TakeProfit*pips),"Short 1",MagicNumber,0,Red);
            if(ticket>0)
              {
               if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                  Print("SELL order opened : ",OrderOpenPrice());
              }
            else
               Print("Error opening SELL order : ",GetLastError());
           }
         //--- exit from the "no opened orders" block
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//|   stop                                                           |
//+------------------------------------------------------------------+   
//-----------------------------------------------------------------------------+ 
void stop()
  {
// int cnt;
//+------------------------------------------------------------------+
   double middleBB=iBands(Symbol(),0,20, 2,0,0,MODE_MAIN,1);//middle
   double lowerBB=iBands(Symbol(),0,20, 2,0,0,MODE_LOWER,1);//lower
   double upperBB=iBands(Symbol(),0,20, 2,0,0,MODE_UPPER,1);//upper
//+------------------------------------------------------------------+                                        
   double  MacdMAIN=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
//+------------------------------------------------------------------+       
   for(int cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {
            //--- should it be closed?

            if(((Bid<OrderOpenPrice()-iATR(NULL,0,14,0))
               || ((MacdMAIN>0 && MacdMAIN<MacdSIGNAL) || (MacdMAIN<0 && (MathAbs(MacdMAIN)>MathAbs(MacdSIGNAL))))
               || Close[1]==upperBB))
               exitbuys();
            //--- check for trailing stop
           }
         else // go to short position
           {
            //--- should it be closed?

            if(((Ask>OrderOpenPrice()+iATR(NULL,0,14,0))
               || ((MacdMAIN>0 && MacdMAIN>MacdSIGNAL) || (MacdMAIN<0 && (MathAbs(MacdMAIN)<MathAbs(MacdSIGNAL)))))
               || Close[1]==lowerBB)
               exitsells();
            //--- check for trailing stop
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Trailing stop loss                                               |
//+------------------------------------------------------------------+ 
// --------------- ----------------------------------------------------------- ------------------------                    
void Trail1()
  {
   total=OrdersTotal();
//--- it is important to enter the market correctly, but it is more important to exit it correctly...   
   for(int cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {

            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>pips*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-pips*TrailingStop)
                    {

                     RefreshRates();
                     stoploss=Bid-(pips*TrailingStop);
                     takeprofit=OrderTakeProfit()+pips*TrailingStop;
                     double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
                     if(stoploss<StopLevel*pips) stoploss=StopLevel*pips;
                     string symbol=OrderSymbol();
                     double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
                     if(MathAbs(OrderStopLoss()-stoploss)>point)
                        if((pips*TrailingStop)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*pips)

                           //--- modify order and exit
                           if(CheckStopLoss_Takeprofit(OP_BUY,stoploss,takeprofit))
                              if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit))
                                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0,Green))
                                    Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
         else // go to short position
           {
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(pips*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+pips*TrailingStop)) || (OrderStopLoss()==0))
                    {

                     RefreshRates();
                     stoploss=Ask+(pips*TrailingStop);
                     takeprofit=OrderTakeProfit()-pips*TrailingStop;
                     double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
                     if(stoploss<StopLevel*pips) stoploss=StopLevel*pips;
                     if(takeprofit<StopLevel*pips) takeprofit=StopLevel*pips;
                     string symbol=OrderSymbol();
                     double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
                     if(MathAbs(OrderStopLoss()-stoploss)>point)
                        if((pips*TrailingStop)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*pips)

                           //--- modify order and exit
                           if(CheckStopLoss_Takeprofit(OP_SELL,stoploss,takeprofit))
                              if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit))
                                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0,Red))
                                    Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
//|                          MOVE TO BREAK EVEN                               |
//+---------------------------------------------------------------------------+
void MOVETOBREAKEVEN()

  {
   for(int b=OrdersTotal()-1;b>=0;b--)
     {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()!=MagicNumber)continue;
      if(OrderSymbol()==Symbol())
         if(OrderType()==OP_BUY)
            if(Bid-OrderOpenPrice()>WHENTOMOVETOBE*pips)
               if(OrderOpenPrice()>OrderStopLoss())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(PIPSTOMOVESL*pips),OrderTakeProfit(),0,CLR_NONE))
                     Print("eror");
     }

   for(int s=OrdersTotal()-1;s>=0;s--)
     {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()!=MagicNumber)continue;
      if(OrderSymbol()==Symbol())
         if(OrderType()==OP_SELL)
            if(OrderOpenPrice()-Ask>WHENTOMOVETOBE*pips)
               if(OrderOpenPrice()<OrderStopLoss())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(PIPSTOMOVESL*pips),OrderTakeProfit(),0,CLR_NONE))
                     Print("eror");
     }
  }
//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
double getLots()
  {

   losses=0;
   double minlot= MarketInfo(Symbol(),MODE_MINLOT);
   double round = MathAbs(MathLog(minlot)/MathLog(10))+0.1;
   double result= Lots;
   int Total=OrdersHistoryTotal();
   double spread=MarketInfo(Symbol(),MODE_SPREAD);
   double k=(TakeProfit+Stop_Loss)/(TakeProfit-spread);
   for(int i=0; i<Total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      if(!(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)) Print("eror");
        {
         if(OrderProfit()>0)
           {
            result = Lots;
            losses = 0;
              } else {
            result=result*Multiply;
            losses++;
           }
        }
     }
   result=NormalizeDouble(result,Digits);
   double maxlot=MarketInfo(Symbol(),MODE_MAXLOT);
   if(result>maxlot)
     {
      result=maxlot;
     }
   if(result<minlot)
     {
      MagicNumber=MagicNumber+1;
     }
   RefreshRates();
   return(result);
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double NDTP(double val)
  {
   RefreshRates();
   double SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(val<StopLevel*pips+SPREAD*pips) val=StopLevel*pips+SPREAD*pips;
// double STOPLEVEL = MarketInfo(Symbol(),MODE_STOPLEVEL);
//int Stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);

//if (Stops_level*pips<val-Bid)
//val=Ask+Stops_level*pips;
   return(NormalizeDouble(val, Digits));
// return(val);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double ND(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+ 
////////////////////////////////////////////////////////////////////////////////////
int getOpenOrders()
  {

   int Orders=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        {
         continue;
        }
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
        {
         continue;
        }
      Orders++;
     }
   return(Orders);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      Print("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      Print("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      Print("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
            volume_step,ratio*volume_step);
      return(false);
     }

   return(true);
  }
//+---------------------------------------------------------------------------+

//--------------------------------------------------------------------------------------

double Fractals()
  {
//Initialization of the variables
   FractalsUp=false;
   FractalsDown=false;
   FractalsUpPrice=0;
   FractalsDownPrice=0;
//-------------------------------------------------------------------- - -----------------------
   double TENKAN_SEN=iIchimoku(NULL,T,9,26,52,MODE_TENKANSEN,1);       //RED LINE
   double KIJUN_SEN=iIchimoku(NULL,T,9,26,52,MODE_KIJUNSEN,1);         //BLUE LINE
//---------------------------------------------------------------------------- 
//For loop to scan the last FractalsLimit candles starting from the oldest and finishing with the most recent
   for(int i=FractalsLimit; i>=0; i--)
     {
      //If there is a fractal on the candle the value will be greater than zero and equal to the highest or lowest price
      double fu=iFractals(NULL,0,MODE_UPPER,i);
      double fd=iFractals(NULL,0,MODE_LOWER,i);
      //If there is an upper fractal I store the value and set true the FractalsUp variable
      if(fu>0)
         if(TENKAN_SEN>KIJUN_SEN)
            if(Low[2]<fu && Open[1]>fu)
              {
               FractalsUp=true;
               FractalsDown=false;
               FractalsUpPrice++;
               Print("FractalsUpPrice",FractalsUpPrice);
               //  if((High[1]<fu || High[2]<fu || High[3]<fu) && (Ask/*Open[0]*/>=fu))
               return(1);
              }
      //If there is an lower fractal I store the value and set true the FractalsDown variable
      if(fd>0)
         if(TENKAN_SEN<KIJUN_SEN)
            if(High[2]>fd && Open[1]<fd)
              {
               FractalsUp=false;
               FractalsDown=true;
               FractalsDownPrice++;
               Print("FractalsDownPrice",FractalsDownPrice);
               //  if((Low[1]>fd || Low[2]>fd || Low[3]>fd) && (Ask/*Open[0]*/<=fd))
               return(2);
              }
      //if the candle has both upper and lower fractal the values are stored but we do not consider it as last fractal
      if(fu>0 && fd>0)
        {
         FractalsUp=false;
         FractalsDown=false;
         FractalsUpPrice=fu;
         FractalsDownPrice=fd;
         return(0);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+  
//+------------------------------------------------------------------+
//| Checking the new values of levels before order modification      |
//+------------------------------------------------------------------+
bool OrderModifyCheck(int ticket,double price,double sl,double tp)
  {
//--- select order by ticket
   if(OrderSelect(ticket,SELECT_BY_TICKET))
     {
      //--- point size and name of the symbol, for which a pending order was placed
      string symbol=OrderSymbol();
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      //--- check if there are changes in the Open price
      bool PriceOpenChanged=true;
      int type=OrderType();
      if(!(type==OP_BUY || type==OP_SELL))
        {
         PriceOpenChanged=(MathAbs(OrderOpenPrice()-price)>point);
        }
      //--- check if there are changes in the StopLoss level
      bool StopLossChanged=(MathAbs(OrderStopLoss()-sl)>point);
      //--- check if there are changes in the Takeprofit level
      bool TakeProfitChanged=(MathAbs(OrderTakeProfit()-tp)>point);
      //--- if there are any changes in levels
      if(PriceOpenChanged || StopLossChanged || TakeProfitChanged)
         return(true);  // order can be modified      
      //--- there are no changes in the Open, StopLoss and Takeprofit levels
      else
      //--- notify about the error
         PrintFormat("Order #%d already has levels of Open=%.5f SL=%.5f TP=%.5f",
                     ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
     }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying 
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type,double SL,double TP)
  {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must"+
                  " not be nearer than %d points from the closing price",stops_level,stops_level);
     }
//---
   bool SL_check=false,TP_check=false;
//--- check only two order types
   switch(type)
     {
      //--- Buy operation
      case  ORDER_TYPE_BUY:
        {
         //--- check the StopLoss
         SL_check=(Bid-SL>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
                        " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SL,Bid-stops_level*_Point,Bid,stops_level);
         //--- check the TakeProfit
         TP_check=(TP-Bid>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f"+
                        " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TP,Bid+stops_level*_Point,Bid,stops_level);
         //--- return the result of checking
         return(SL_check&&TP_check);
        }
      //--- Sell operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
         SL_check=(SL-Ask>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
                        " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SL,Ask+stops_level*_Point,Ask,stops_level);
         //--- check the TakeProfit
         TP_check=(Ask-TP>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f "+
                        " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TP,Ask-stops_level*_Point,Ask,stops_level);
         //--- return the result of checking
         return(TP_check&&SL_check);
        }
      break;
     }
//--- a slightly different function is required for pending orders
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                      exitbuys()                  |
//+------------------------------------------------------------------+
void exitbuys()
  {
   double result;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
            if(result!=true)//if it did not close
              {
               err=GetLastError(); Print("LastError = ",err);//get the reason why it didn't close
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+  
//+------------------------------------------------------------------+
//|                    exitsells()                                   |
//+------------------------------------------------------------------+
void exitsells()
  {
   double result;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {

         if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
            if(result!=true)//if it did not close
              {
               err=GetLastError(); Print("LastError = ",err);//get the reason why it didn't close
              }

           }
        }

     }
  }

//+------------------------------------------------------------------+   

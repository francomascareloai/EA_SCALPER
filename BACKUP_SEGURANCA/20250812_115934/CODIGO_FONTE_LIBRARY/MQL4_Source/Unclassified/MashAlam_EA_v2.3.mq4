//+------------------------------------------------------------------+
//|                                                  MashAlam_EA.mq4 |
//|                                                        Mash Alam |
//|               Coded By Santhosh44, Upwork (santhosh44@gmail.com) |
//+------------------------------------------------------------------+
#property copyright "Mash Alam"
#property link      ""

#define   NL                  "\n"
#define   SIGNAL_BUY          1
#define   SIGNAL_SELL         -1

enum calcmethod
{
   Balance = 0,
   Equity  = 1
};

extern string     s1 = "==== Trade settings ====";
extern bool       AutoLots          = false;
extern double     LotSize           = 0.1;
extern double     RiskPerTrade      = 4;
extern int        NumberOfPairs     = 20;
extern calcmethod CalculationMethod = Equity;
extern double     Multiplier        = 1;
extern bool       TradeReverse      = false;

extern string     s2 = "==== Indicator settings ====";
extern bool       UseArrow             = true;
extern bool       UseHistogram         = true;

extern string     s3 = "==== SL/TP settings ====";
extern int        StopLoss          = 50;
extern int        ProfitTarget      = 0;

string  TradeComment      = "";
int     Magic             = 432444;

int            Slippage          = 5;
int            NumRetries        = 10;
int            RetryDelayInSec   = 5; 

int            numBars, cb, cs, total;
double         myPoint, stoplevel;
string         msg, openmsg ;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   numBars = Bars;
   stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point + MarketInfo(Symbol(),MODE_SPREAD)*Point;
   
   if(Digits % 2 == 1) {
      myPoint = 10 * Point;
   }  else {
      myPoint = Point;
   }
   
//----
   return(0);
  }
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   msg = "Current Time : "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+NL;
   msg = msg + "EA Active "+"( Spread : "+ DoubleToStr(GetSpread(),1)+" )"+NL+NL;
   CountOrders();
   
   if(IsNewBar()) {
      if(total > 0 && UseHistogram)
         CheckForExit();
         
      int signal = GetSignal();
      bool bullish   = signal == 1 ;
      bool bearish   = signal == -1 ;
      
      CountOrders();
      if(cb > 0 && bearish)
         ClosePositionsByType(OP_BUY);
      else if(cs > 0 && bullish)
         ClosePositionsByType(OP_SELL);
      
      CountOrders();
      if(cb == 0 && bullish)
         PlaceOrder(OP_BUY);
      else if(cs == 0 && bearish)
         PlaceOrder(OP_SELL);
   }
   
   CountOrders();
   if(total > 0) {
      openmsg = "Orders Open : "+total+" ( P/L : "+DoubleToStr(GetPLInMoney(),1)+" ) "+NL;
   } else {
      openmsg = "No Open Orders."+NL;
   }
   
   Comment(msg+NL+openmsg);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void CheckForExit()
{
   double up2 = iCustom(NULL,0,"FxMax5 TF",0,1);
   double dn2 = iCustom(NULL,0,"FxMax5 TF",1,1);
   
   if(!TradeReverse) {
      if(up2 != EMPTY_VALUE && up2 > 0)
         ClosePositionsByType(OP_SELL);
      if(dn2 != EMPTY_VALUE && dn2 > 0)
         ClosePositionsByType(OP_BUY);
   } else {
      if(up2 != EMPTY_VALUE && up2 > 0)
         ClosePositionsByType(OP_BUY);
      if(dn2 != EMPTY_VALUE && dn2 > 0)
         ClosePositionsByType(OP_SELL);
   }
}

double GetPLInMoney()
{
   double prof = 0 ;
   for (int y = 0; y < OrdersTotal(); y++)
   {
      if(OrderSelect (y, SELECT_BY_POS, MODE_TRADES)) 
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber()== Magic)
            prof = prof + OrderProfit()+OrderCommission()+OrderSwap();
   }
   return(prof);
}

void CountOrders()
{
   cb = 0;
   cs = 0;
   
   for (int y = 0; y < OrdersTotal(); y++)
   {
      if(OrderSelect (y, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
            if(OrderType()==OP_BUY)
               cb++;
            else if(OrderType()==OP_SELL)
               cs++;
         
         }
      }
   }
   
   total = cb + cs;
}

bool IsNewBar() 
{
   if (numBars != Bars) {
      numBars = Bars;
      return(true);
   }
   return(false);
}

int GetSignal()
{
   bool bullish1 = true, bearish1 = true;
   if(UseArrow) {
      double up1 = iCustom(NULL,0,"Arrow with Alert",999,false,false,false,2,1);
      double dn1 = iCustom(NULL,0,"Arrow with Alert",999,false,false,false,3,1);
      
      bullish1 = up1 != EMPTY_VALUE && up1 > 0;
      bearish1 = dn1 != EMPTY_VALUE && dn1 > 0;
   }
   
   bool bullish2 = true, bearish2 = true;
   if(UseHistogram) {
      double up2 = iCustom(NULL,0,"FxMax5 TF",0,1);
      double dn2 = iCustom(NULL,0,"FxMax5 TF",1,1);
      
      bullish2 = up2 != EMPTY_VALUE && up2 > 0;
      bearish2 = dn2 != EMPTY_VALUE && dn2 > 0;
   }
   
   if(bullish1 && bullish2) {
      if(!TradeReverse)
         return(1);
      else
         return(-1);
   } else if(bearish1 && bearish2) {
      if(!TradeReverse)
         return(-1);
      else
         return(1);
   }
   
   return(0);
}

bool PlaceOrder(int type)
{
   Print("PlaceOrder called.. Type : "+TypeToStr(type));
   double entry, lot;
   color  col;        

   int i = 0;
   while(i < NumRetries) {
      i += 1;
      while(IsTradeContextBusy())Sleep(RetryDelayInSec*1000);
	   RefreshRates();
	   if(type == OP_BUY) {
         entry = Ask;
         col   = Blue;
      }
      else {
         entry = Bid;
         col   = Red;
      }

      if(AutoLots)
         lot = GetLotSize(type, entry);
      else
         lot = LotSize;

      Print("Try "+i+" : Open "+TypeToStr(type)+" order. Entry : "+DoubleToStr(entry,Digits)+" Lot :"+lot);
      int ticket = OrderSend(Symbol(),type,lot,entry,Slippage,0,0,TradeComment,Magic,0,col);
      if(ticket <= 0){
         Print("ERROR opening market order. ErrorCode:"+GetLastError());
         if(i == NumRetries) {
            Print("*** Final retry to OPEN ORDER failed ***");
            return(false);
         }
      } else {
         SetSLandTP(ticket);
         i = NumRetries;
         return(true);
      }
   }
   
   return(false);
}

void SetSLandTP(int tick)
{
   if(OrderSelect(tick,SELECT_BY_TICKET)) {
      double sl = CalcSL(OrderType(),OrderOpenPrice());
      double tp = CalcTP(OrderType(),OrderOpenPrice(),sl);
      
      if(sl == 0 && tp == 0)
         return;
      
      int i = 0;
      while(i < NumRetries) {
         i += 1;
         while(IsTradeContextBusy())Sleep(1000);
   	   RefreshRates();
         int t = OrderModify(tick, OrderOpenPrice(), NormalizeDouble(sl,Digits), NormalizeDouble(tp, Digits), 0);
         if(t <= 0) {
             Print("*** ERROR modifying market order. Unable to set SL/TP. SL: "+NormalizeDouble(sl,Digits)+" TP: "+NormalizeDouble(tp,Digits)+" ErrorCode: "+GetLastError());
             if(i == NumRetries) {
               Print("*** Final retry to SET SL/TP failed. Manually set the same or close the open order ***");
            }
         } else {
            i = NumRetries;
         }
      }
   }
}

double CalcSL(int type, double entry)
{
   double stoploss = 0;
  
   if(type == OP_BUY && StopLoss > 0)
      stoploss = entry - StopLoss*myPoint;
   else if(type == OP_SELL && StopLoss > 0)
      stoploss = entry + StopLoss*myPoint;
   
   if(stoploss > 0) {
      RefreshRates();   
      if(type == OP_BUY && Bid - stoploss < stoplevel)
         stoploss = Bid - stoplevel;
      else if(type == OP_SELL && stoploss - Ask < stoplevel)
         stoploss = Ask + stoplevel;
   }

   return(NormalizeDouble(stoploss,Digits));
}

double CalcTP(int type, double entry, double sl)
{
   double takeprofit = 0;
   
   if(type == OP_BUY && ProfitTarget > 0)
      takeprofit = entry + ProfitTarget*myPoint;
   else if(type == OP_SELL && ProfitTarget > 0)
      takeprofit = entry - ProfitTarget*myPoint;

   if(takeprofit > 0) {   
      RefreshRates();
      if(type == OP_BUY && takeprofit - Bid < stoplevel)
         takeprofit = Bid + stoplevel;
      else if(type == OP_SELL && Ask - takeprofit < stoplevel)
         takeprofit = Ask - stoplevel;
   }
   
   return(NormalizeDouble(takeprofit,Digits));
}

double GetLotSize(int type, double entry)
{
   if(CalculationMethod == Balance)
      double amount  = AccountBalance();
   else
      amount = AccountEquity();
   
   double total_lots    = (amount * RiskPerTrade/100.0) / StopLoss / 10;
   double lot_per_pair  = total_lots/NumberOfPairs;
   double Lots          = lot_per_pair * Multiplier;
   
   return(NormalizeDouble(Lots,2));
}

string TypeToStr(int type)
{
   if(type == OP_BUY)
      return("BUY");
   else if(type == OP_SELL)
      return("SELL");      
   if(type == OP_BUYSTOP)
      return("BUYSTOP");
   else if(type == OP_SELLSTOP)
      return("SELLSTOP");      
   if(type == OP_BUYLIMIT)
      return("BUYLIMIT");
   else if(type == OP_SELLLIMIT)
      return("SELLLIMIT");   
   
   return("Unknown Type");   
}

void ClosePositionsByType(int type)
{
    bool success;
    if(type == OP_BUY)
      color col = Blue;
    else
      col = Red;
    for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt --){
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
            int i = 0;
            while(i < NumRetries) {
               i += 1;
               while(IsTradeContextBusy())Sleep(RetryDelayInSec*1000);
         	   RefreshRates();
            
               Print("Try "+i+" : Close "+OrderTicket());
               success=OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 99, col);
               if(!success){
                  Print("Failed to close order "+OrderTicket()+" Error code:"+GetLastError());
                  if(i == NumRetries)
                     Print("*** Final retry to CLOSE ORDER failed. Close trade manually ***");
               } else
                  i = NumRetries;
            }
         }
      }
    } 
}

double GetSpread()
{
   if (Digits == 5 || Digits == 3) 
      double spread = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD)*0.1,1);
   else 
      spread = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD),1);
      
   return(spread);
}

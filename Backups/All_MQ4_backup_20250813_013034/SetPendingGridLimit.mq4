//+-----------------------------------------------------------------------------+
//|                              Place pending for dudest                       +
//+-----------------------------------------------------------------------------+
#property copyright "(c)2016 milanese"
#property strict
#property show_inputs
#include <stdlib.mqh>
#define  NL    "\n"

//Error reporting
#define  slm " stop loss modification failed with error "
#define  tpm " take profit modification failed with error "

extern string   gen="----General inputs----";
extern double Lot = 0.01;
extern string   bos="----Direction 1=BUY 2=SELL----";
extern int Direction=1;
extern double PendingPriceFirstOrder=0;
extern int NumberOfPendingsToSet=5;
extern double DistanceOrdersPips=20;
extern int MagicNumber=12345;
extern string TradeComment="PendingScript";
double   MaxSlippagePips=5;
double factor;
int orderType;
double buffer=5;
int 	        O_R_Setting_max_retries 	= 10;
double 	        O_R_Setting_sleep_time 		= 4.0; /* seconds */
double 	        O_R_Setting_sleep_max 		= 15.0; /* seconds */
int             RetryCount = 10;//Will make this number of attempts to get around the trade context busy error.
int OnInit(void)
  {
 factor = GetPipFactor(Symbol());
 if((PendingPriceFirstOrder==NormalizeDouble(0,Digits))&& (Direction==1)) PendingPriceFirstOrder=NormalizeDouble(Ask-(DistanceOrdersPips/factor),Digits);
 if((PendingPriceFirstOrder==NormalizeDouble(0,Digits))&& (Direction!=1)) PendingPriceFirstOrder=NormalizeDouble(Bid+(DistanceOrdersPips/factor),Digits);
 if (Direction > 1){
 if (Bid < PendingPriceFirstOrder ){
 orderType=OP_SELLLIMIT;
 } else orderType=OP_SELLSTOP;
 
 }
 if (Direction <= 1){
 if (Bid > PendingPriceFirstOrder ){
 orderType=OP_BUYLIMIT;
 } else orderType=OP_BUYSTOP;
 
 }

   return(INIT_SUCCEEDED);
  }
void OnStart()
{ 
  bool singleTrade=false;
  if (orderType==OP_BUYLIMIT || orderType==OP_SELLSTOP ){
  DistanceOrdersPips=-DistanceOrdersPips;
  }
  PendingPriceFirstOrder=PendingPriceFirstOrder-(DistanceOrdersPips/factor);
  for(int counter=0;counter<NumberOfPendingsToSet;counter++)
        {
        PendingPriceFirstOrder=PendingPriceFirstOrder+(DistanceOrdersPips/factor);
        Alert("PlacePending: "+"Attempting to place Pending Order at: "+DoubleToStr(PendingPriceFirstOrder,Digits));
        singleTrade=SendSingleTrade(orderType, TradeComment, Lot,PendingPriceFirstOrder, 0, 0);
        if (singleTrade==false){
         Alert("PlacePending: "+"First try failed retry to place Pending Order at: "+DoubleToStr(PendingPriceFirstOrder,Digits));
        Sleep(1000);
        singleTrade=SendSingleTrade(orderType, TradeComment, Lot,PendingPriceFirstOrder, 0, 0);
        if (singleTrade==true)Alert("PlacePending: "+"OrderPlaced");
        }else if (singleTrade==true)Alert("PlacePending: "+"OrderPlaced");
        
        
        
        Sleep(500);
        } 




 




}

//+------------------------------------------------------------------+
//| getPipFactor()                                                   |
//+------------------------------------------------------------------+
int GetPipFactor(string symbol) {

  static const string factor100[]         = {"JPY","XAG","SILVER","BRENT","WTI"};
  static const string factor10[]          = {"XAU","GOLD","SP500"};
  static const string factor1[]           = {"UK100","WS30","DAX30","NAS100","CAC400"};
   
  int xFactor = 10000;       // correct xFactor for most pairs
  for ( int j = 0; j < ArraySize( factor100 ); j++ ) {
     if ( StringFind( symbol, factor100[j] ) != -1 ) xFactor = 100;
  }   
  for ( int j = 0; j < ArraySize( factor10 ); j++ ) {
     if ( StringFind( symbol, factor10[j] ) != -1 ) xFactor = 10;
  }   
  for ( int j = 0; j < ArraySize( factor1 ); j++ ) {
     if ( StringFind( symbol, factor1[j] ) != -1 ) xFactor = 1;
  }
  
  return (xFactor);
}


void ReportError(string function, string message)
{
   //All purpose sl mod error reporter. Called when a sl mod fails
   
   int err=GetLastError();
      
   Alert(WindowExpertName(), " ", OrderTicket(), function, message, err,": ",ErrorDescription(err));
   Print(WindowExpertName(), " ", OrderTicket(), function, message, err,": ",ErrorDescription(err));
   
}//void ReportError()

bool SendSingleTrade(int type, string comment, double lotsize, double Price, double SL, double TP)
{
   //pah (Paul) contributed the code to get around the trade context busy error. Many thanks, Paul.
   int ticket=-1;
   double slippage = MaxSlippagePips *( MathPow(10, Digits) / factor);

   
   
   color col = Red;
   if (type == OP_BUY || type == OP_BUYSTOP) col = Green;
   
   int expiry = 0;
   //if (SendPendingTrades) expiry = TimeCurrent() + (PendingExpiryMinutes * 60);

   //RetryCount is declared as 10 in the Trading variables section at the top of this file
   for (int cc = 0; cc < RetryCount; cc++)
   {
      //for (int d = 0; (d < RetryCount) && IsTradeContextBusy(); d++) Sleep(100);

      
      while(IsTradeContextBusy()) Sleep(100);//Put here so that excess slippage will cancel the trade if the ea has to wait for some time.
      
      
   
   
      
         ticket = OrderSend(Symbol(),type, lotsize, Price, int(slippage), 0, 0, comment, MagicNumber, expiry, col);
         if (ticket > -1)
         {
	           ModifyOrder(ticket, SL, TP);
         }//if (ticket > 0)}
     
      
      if (ticket > -1) break;//Exit the trade send loop
      if (cc == RetryCount - 1) return(false);
   
      //Error trapping for both
      if (ticket < 0)
      {
         string stype;
         if (type == OP_BUY) stype = "OP_BUY";
         if (type == OP_SELL) stype = "OP_SELL";
         if (type == OP_BUYLIMIT) stype = "OP_BUYLIMIT";
         if (type == OP_SELLLIMIT) stype = "OP_SELLLIMIT";
         if (type == OP_BUYSTOP) stype = "OP_BUYSTOP";
         if (type == OP_SELLSTOP) stype = "OP_SELLSTOP";
         int err=GetLastError();
         Alert(Symbol(), " ", WindowExpertName(), " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
         Print(Symbol(), " ", WindowExpertName(), " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
         return(false);
      }//if (ticket < 0)  
   }//for (int cc = 0; cc < RetryCount; cc++);
   
   
   //Make sure the trade has appeared in the platform's history to avoid duplicate trades.
   //My mod of Matt's code attempts to overcome the bastard crim's attempts to overcome Matt's code.
   bool TradeReturnedFromCriminal = false;
   while (!TradeReturnedFromCriminal)
   {
      TradeReturnedFromCriminal = O_R_CheckForHistory(ticket);
      if (!TradeReturnedFromCriminal)
      {
         Alert(Symbol(), " sent trade not in your trade history yet. Keep an eye open in case the trade send failed.");
      }//if (!TradeReturnedFromCriminal)
   }//while (!TradeReturnedFromCriminal)
   
   //Got this far, so trade send succeeded
   return(true);
   
}//End bool SendSingleTrade(int type, string comment, double lotsize, double Price, double SL, double TP)

void ModifyOrder(int ticket, double SL, double TP)
{
   //Modifies an order already sent if the crim is ECN.

   if (CloseEnough(SL, 0) && CloseEnough(TP, 0) ) return; //nothing to do

   if (!OrderSelect(ticket, SELECT_BY_TICKET) ) return;//Trade does not exist, so no mod needed
   
   if (OrderCloseTime() > 0) return;//Somehow, we are examining a closed trade
   
   //In case some errant behaviour/code creates a tp the wrong side of the market, which would cause an instant close.
   if (OrderType() == OP_BUY && TP < OrderOpenPrice() && !CloseEnough(TP, 0) ) 
   {
      TP = 0;
      ReportError(" ModifyOrder()", " take profit < market ");
   }//if (OrderType() == OP_BUY && TP < OrderOpenPrice() ) 
   
   if (OrderType() == OP_SELL && TP > OrderOpenPrice() ) 
   {
      TP = 0;
      ReportError(" ModifyOrder()", " take profit < market ");
   }//if (OrderType() == OP_SELL && TP > OrderOpenPrice() ) 
   
   //In case some errant behaviour/code creates a sl the wrong side of the market, which would cause an instant close.
   if (OrderType() == OP_BUY && SL > OrderOpenPrice() ) 
   {
      SL = 0;
      ReportError(" ModifyOrder()", " stop loss > market ");
   }//if (OrderType() == OP_BUY && TP < OrderOpenPrice() ) 
   
   if (OrderType() == OP_SELL && SL < OrderOpenPrice()  && !CloseEnough(SL, 0) ) 
   {
      SL = 0;
      ReportError(" ModifyOrder()", " stop loss < market ");
   }//if (OrderType() == OP_SELL && TP > OrderOpenPrice() ) 
   
   string Reason;
   //RetryCount is declared as 10 in the Trading variables section at the top of this file   
   for (int cc = 0; cc < RetryCount; cc++)
   {
      for (int d = 0; (d < RetryCount) && IsTradeContextBusy(); d++) Sleep(100);
        if (!CloseEnough(TP, 0) && !CloseEnough(SL, 0) )
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), SL, TP, OrderExpiration(), CLR_NONE)) return;
           Reason = " TP or SL modification failed with error ";//For error report
        }//if (TP > 0 && SL > 0)
   
        if (!CloseEnough(TP, 0) && CloseEnough(SL, 0))
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), TP, OrderExpiration(), CLR_NONE)) return;
           Reason = tpm;//For error report
        }//if (TP == 0 && SL != 0)

        if (CloseEnough(TP, 0) && !CloseEnough(SL, 0))
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), SL, OrderTakeProfit(), OrderExpiration(), CLR_NONE)) return;
           Reason = slm;//For error report
        }//if (TP == 0 && SL != 0)
   }//for (int cc = 0; cc < RetryCount; cc++)
   
   //Got this far, so the order modify failed
   ReportError(" ModifyOrder()", Reason);
   
}//void ModifyOrder(int ticket, double tp, double sl)

//=============================================================================
//                           O_R_CheckForHistory()
//
//  This function is to work around a very annoying and dangerous bug in MT4:
//      immediately after you send a trade, the trade may NOT show up in the
//      order history, even though it exists according to ticket number.
//      As a result, EA's which count history to check for trade entries
//      may give many multiple entries, possibly blowing your account!
//
//  This function will take a ticket number and loop until
//  it is seen in the history.
//
//  RETURN VALUE:
//     TRUE if successful, FALSE otherwise
//
//
//  FEATURES:
//     * Re-trying under some error conditions, sleeping a random
//       time defined by an exponential probability distribution.
//
//     * Displays various error messages on the log for debugging.
//
//  ORIGINAL AUTHOR AND DATE:
//     Matt Kennel, 2010
//
//=============================================================================
bool O_R_CheckForHistory(int ticket)
{
   //My thanks to Matt for this code. He also has the undying gratitude of all users of my trading robots
   
   int lastTicket = OrderTicket();

   int cnt = 0;
   int err = GetLastError(); // so we clear the global variable.
   err = 0;
   bool exit_loop = false;
   bool success=false;

   while (!exit_loop) {
      /* loop through open trades */
      int total=OrdersTotal();
      for(int c = 0; c < total; c++) {
         if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES) == true) {
            if (OrderTicket() == ticket) {
               success = true;
               exit_loop = true;
            }
         }
      }
      if (cnt > 3) {
         /* look through history too, as order may have opened and closed immediately */
         total=OrdersHistoryTotal();
         for(int c = 0; c < total; c++) {
            if(OrderSelect(c,SELECT_BY_POS,MODE_HISTORY) == true) {
               if (OrderTicket() == ticket) {
                  success = true;
                  exit_loop = true;
               }
            }
         }
      }

      cnt = cnt+1;
      if (cnt > O_R_Setting_max_retries) {
         exit_loop = true;
      }
      if (!(success || exit_loop)) {
         Print("Did not find #"+IntegerToString(ticket)+" in history, sleeping, then doing retry #"+IntegerToString(cnt));
         O_R_Sleep(O_R_Setting_sleep_time, O_R_Setting_sleep_max);
      }
   }
   // Select back the prior ticket num in case caller was using it.
   if (lastTicket >= 0) {
      bool order_select=OrderSelect(lastTicket, SELECT_BY_TICKET, MODE_TRADES);
   }
   if (!success) {
      Print("Never found #"+IntegerToString(ticket)+" in history! crap!");
   }
   return(success);
}//End bool O_R_CheckForHistory(int ticket)

//=============================================================================
//                              O_R_Sleep()
//
//  This sleeps a random amount of time defined by an exponential
//  probability distribution. The mean time, in Seconds is given
//  in 'mean_time'.
//  This returns immediately if we are backtesting
//  and does not sleep.
//
//=============================================================================
void O_R_Sleep(double mean_time, double max_time)
{
   if (IsTesting()) {
      return;   // return immediately if backtesting.
   }

   double p = (MathRand()+1) / 32768.0;
   double t = -MathLog(p)*mean_time;
   t = MathMin(t,max_time);
   int ms = int(t*1000);
   if (ms < 10) {
      ms=10;
   }
   Sleep(ms);
}//End void O_R_Sleep(double mean_time, double max_time)

bool CloseEnough(double num1, double num2)
{
   /*
   This function addresses the problem of the way in which mql4 compares doubles. It often messes up the 8th
   decimal point.
   For example, if A = 1.5 and B = 1.5, then these numbers are clearly equal. Unseen by the coder, mql4 may
   actually be giving B the value of 1.50000001, and so the variable are not equal, even though they are.
   This nice little quirk explains some of the problems I have endured in the past when comparing doubles. This
   is common to a lot of program languages, so watch out for it if you program elsewhere.
   Gary (garyfritz) offered this solution, so our thanks to him.
   */
   
   if (num1 == 0 && num2 == 0) return(true); //0==0
   if (MathAbs(num1 - num2) / (MathAbs(num1) + MathAbs(num2)) < 0.00000001) return(true);
   
   //Doubles are unequal
   return(false);

}//End bool CloseEnough(double num1, double num2)

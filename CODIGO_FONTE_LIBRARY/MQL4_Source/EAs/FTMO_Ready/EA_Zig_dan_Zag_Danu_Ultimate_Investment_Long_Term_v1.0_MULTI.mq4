//+------------------------------------------------------------------+
//                      DO NOT DELETE THIS HEADER
//             DELETING THIS HEADER IS COPYRIGHT INFRIGMENT 
//                      Copyright © 2011, Molanis
//                   Molanis Strategy Builder 3.1 
//                       http://www.molanis.com                      
//                    
// THIS EA CODE HAS BEEN GENERATED USING MOLANIS STRATEGY BUILDER 3.1 
// on Wed Feb 01 00:03:57 ICT 2012 
// Disclaimer: This EA is provided to you "AS-IS", and Molanis disclaims any warranty
// or liability obligations to you of any kind. 
// UNDER NO CIRCUMSTANCES WILL MOLANIS BE LIABLE TO YOU, OR ANY OTHER PERSON OR ENTITY,
// FOR ANY LOSS OF USE, REVENUE OR PROFIT, LOST OR DAMAGED DATA, OR OTHER COMMERCIAL OR
// ECONOMIC LOSS OR FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, STATUTORY, PUNITIVE,
// EXEMPLARY OR CONSEQUENTIAL DAMAGES WHATSOEVER RELATED TO YOUR USE OF THIS EA OR 
// MOLANIS STRATEGY BUILDER     
// Because software is inherently complex and may not be completely free of errors, you are 
// advised to verify this EA. Before using this EA, please read the Molanis Strategy Builder
// license for a complete understanding of Molanis' disclaimers.  
// USE THIS EA AT YOUR OWN RISK. 
//  
// Trading in forex is speculative in nature and not appropriate for all investors. 
// Investors should only use risk capital because there is always the risk of substantial loss. 
// Past results are not necessarily indicative of future results.
//
// Before adding this expert advisor to a chart, make sure there are NO
// open positions.
//                      DO NOT DELETE THIS HEADER
//             DELETING THIS HEADER IS COPYRIGHT INFRIGMENT 
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| EA Notes                                                         |
/*| */
//+------------------------------------------------------------------+

//Strategy Comments
#property copyright "Copyright © 2009-2011, Created with Molanis V 3.15 "
#property link      "http://www.molanis.com"
#define SleepTime    250                           //To sleep for a while before retrying order execution 

//+------------------------------------------------------------------+
//| initial setup                                                    |
//+------------------------------------------------------------------+
// The main purpose of this section is to initialize trading variables.
//
//+--- input parameters ---------------------------------------------+
// Used to activate/deactivate/select options

// General Variables
extern string    EAName="Zig dan Zag Ultimate Investment";                     // Expert Advisor Name
extern bool      IsMicroAccount = true;           // Define if account is micro or standard
extern bool      CompletedBars = true;             // Define execution by bars or ticks
extern bool      TradeOrAlert = true;              // Define execution. True allows trading, false sends Alerts
extern bool      SendMailMode = false;             // If ON, sends mail with order execution info
extern bool      PlaySounds = false;                // If ON, Plays a sound when orders/alarms are executed
extern string    MySound="alert.wav";                      // Sound to be played when orders/alarms are executed

//5 digits management
extern bool FiveDigits = true;                    //if false, broker uses 4 digits
int PipMultiplier = 1;                            // to multiply positions by 10 when 5 digits is true

// Trading Variables
extern bool      UseTradingTime = false;           // If on, trades only when tradingtimestart<hour<tradingtimestart 
extern int       TradingTimeStart = 9;               // i.e 9 = 9 am
extern int       TradingTimeEnd = 16;                // i.e 16 = 4 pm 
extern bool       ClosePositionsNonTH = false;      // Action before/after Trading Hours   
extern bool      OrderIncludeTPSL = true;          // If false, orders are opened and later TP/SL is added
extern int       MaxNumberofPositions = 1;          // max open positions
extern int       MaxOrderRetry = 100;              // if there is an error executing orders, the script retries MaxOrderRetry times
static color     BuyColor = Green;                 // color to identify buy orders
static color     SellColor = Red;                  // color to identify sell orders
bool      AutoAdjustSLTP = false;              // to turn on/off stop loss autoadjustment. Adjust SL to three times the minimum SL allowed

// Money Management Variables
extern bool    UseMaximumPercentageatRisk = false;   // Turns on/off max risk condition
extern double  MaximumPercentageatRisk = 1;        // i.e max size of trade = 2 = 2% of equity
extern bool    UseRiskRatio = false;                  // Turns on/off risk ratio  
extern int     RiskRatio = 3;                        // i.e. RiskRatio=3 means that TakeProfit/StopLoss = 3 
extern bool    UseLotManagement = false;             // Turns on/off lot management
extern int     LotManagementType = 2;                // 1 - Uses Decrease factor
                                                   // 2 - Uses a fix factor 75%,50%,25% 
extern double  ReductionFactor = 5;                // for money management lot-(lot*losses/ReductionFactor)

//Martingale Variables
extern bool    UseMartingale = true;   // Turns martingale  
extern double  MartingaleMultiplier = 2.0;        // i.e 2 = double next lot size
double  MaxMartingaleSize = 120.8;        // i.e 5 = max lot size is 5
extern bool    afterLoss = true;   // use martingale after losses
extern bool    afterWin = false;   // use martingale (anti martingale) after Win
datetime MartingaleTime = 0;

// Variables for MT4 only
extern int     Slippage = 3;                       // Minimum slippage accepted 



// TP/SL/TS/LS backtesting variables 
//Values in pips. 10=10 pips.
extern double S_Symbol_LS_0 = 1.0;     //Used to change value or backtest Lot Size
extern double S_Symbol_TP_0 = 0;     //Used to change value or backtest Take Profit
extern double S_Symbol_SL_0 = 0;     //Used to change value or backtest Stop Loss
extern double S_Symbol_TS_0 = 50;     //Used to change value or backtest Trailing Stop
extern double B_Symbol_LS_0 = 1.0;     //Used to change value or backtest Lot Size
extern double B_Symbol_TP_0 = 0;     //Used to change value or backtest Take Profit
extern double B_Symbol_SL_0 = 0;     //Used to change value or backtest Stop Loss
extern double B_Symbol_TS_0 = 50;     //Used to change value or backtest Trailing Stop


//+------------------------------------------------------------------+
//| MT Variables Created by User                                     |
/*| */
//+------------------------------------------------------------------+


// Used to keep global variables

extern int MagicNumberLong = 6658641;                     //Identifies long positions
extern int MagicNumberShort = 4167090;                    //Identifies short positions
string commentlong="Go long ";              //Identifies long positions
string commentshort="Go short ";            //Identifies short positions

extern bool ShowWarnings=true;              //Set to false if you do not want warnings/alerts

int PreviousBarCount = 0;                          // To count bars
string mailstring = "";
string subject = "EA: ";

extern bool CheckTSEveryTick=false; //Checks trailing stops every tick regardless of Execution Mode (Bars or ticks)
datetime TimeTSCheck = 0;
extern bool UseTimeBasedTS = false;         // True means use time based trailing stop
extern int TimeBasedTS = 30;                // Every TimeBasedTS minutes
 
extern bool Hedge=false; //Allow hedging variable

//+------------------------------------------------------------------+
//| MT4 functions                                                    |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
//The initialization function init() contains instructions that run only once, run before any other
//code in the Expert Advisor. The main purpose of this section is to initialize variables.
int init()
{
//----init start

//Martingale   
   MartingaleTime=TimeCurrent();
  
    
//Next trade management


//Set transaction comment
   commentlong="Go long "+MagicNumberLong;              //Identifies long positions
   commentshort="Go short "+MagicNumberShort;            //Identifies short positions

   //Adjust calculations for 5 digit brokers
if (FiveDigits) 
   {
      PipMultiplier = 10;    
   }
   Slippage = Slippage*PipMultiplier;
   
   if( (Digits==5 || Digits==3) && (!FiveDigits) )
     {
      Print("M-",Symbol()," You selected FiveDigits=False but your graph seems to have 5 digits (or 3 for JPY pairs). Please review your digits definition.");
      MessageBox("M-"+Symbol()+" You selected FiveDigits=False but your graph seems to have 5 digits (or 3 for JPY pairs). Please review your digits definitions.","Digits setup may be wrong");
     }
   if( (Digits==4 || Digits==2) && (FiveDigits) )
     {
      Print("M-",Symbol()," You selected FiveDigits=True but your graph seems to have 4 digits (or 2 for JPY pairs). Please review your digits definition.");
      MessageBox("M-"+Symbol()+" You selected FiveDigits=True but your graph seems to have 4 digits (or 2 for JPY pairs). Please review your digits definitions.","Digits setup may be wrong");
     }   
     
        
// Check account type and mode
   Print("M-*** EA created with Molanis Strategy Builder 3.1 *** ");  
   Print("M-*** EA starts running at: Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)," Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS)); 
if (IsDemo()) {
   Print("M-*** Running in a DEMO account *** "); 
   } else {
   Print("M-*** Running in a REAL account *** "); }
if (IsTesting()) {
   Print("M-*** Running in TESTING MODE *** "); 
   }  

//Hedging message
if (Hedge) {
	Print("M-You are hedging. You need to use the Close icons in your trading diagram to close postitions.");	     
   if (ShowWarnings) MessageBox("You are hedging. You need to use the Close icons in your trading diagram to close postitions.","Molanis Warning: Close existing orders");
	}

// Time based Trailing Stop
TimeTSCheck = TimeCurrent();

//Check trailing stop every tick
if ( CheckTSEveryTick ) {
	Print("M-EA checks trailing stops every tick regardless of Execution Mode (Bars or ticks).");	     
   }	
	
Print("M-Account Equity=",AccountEquity(),". Account Balance=",AccountBalance(),". Account Free Margin = ",AccountFreeMargin(),". Account Leverage=",AccountLeverage());
// Verify if there are open positions and alert    
   if(OrdersTotal()>0) {
   	  Print("There are existing positions that could affect the logic of this EA. We strongly advise you to close all pending and open positions/orders before executing this EA.");	     
   	  if (ShowWarnings) MessageBox("There are existing positions that could affect the logic of this EA. We strongly advise you to close all pending and open positions/orders before executing this EA.","Molanis Warning: Close existing orders");       
   }
// Check for enough ticks and trade permission
   if(Bars<100) {    
    Print("M-*** CAN NOT TRADE *** Not enough historical information!"); 
    MessageBox("*** CAN NOT TRADE *** Not enough historical information!","Molanis Warning");
   }
   
   if(IsTradeAllowed()==false) {    
    Print("M-*** CAN NOT TRADE *** Trading is not allowed! Please confirm that the checkbox -Allow Live Trading option- is checked and that you are able to connect to the server.");
    if (ShowWarnings) MessageBox("*** CAN NOT TRADE *** Trading is not allowed! Please confirm that the checkbox -Allow Live Trading option- is checked and that you are able to connect to the server.","Molanis Warning");
   }
   
 //Lot management message
if (UseLotManagement && UseMartingale) {
	UseLotManagement=false;
	Print("M-You cannot use Martingale and Lot Management at the same time. The ea will use martingale.");	     
   if (ShowWarnings) MessageBox("You cannot use Martingale and Lot Management at the same time. The ea will use martingale.","Molanis Warning: Money Management");
	}
     
// Using current symbol to check for account type
 Print("M-Lot Information: Symbol=",Symbol(),". MIN LOT ALLOWED=",MarketInfo(Symbol(), MODE_MINLOT),". MAX LOT ALLOWED=",MarketInfo(Symbol(), MODE_MAXLOT),". LOT SIZE IN BASE CURRENCY=",MarketInfo(Symbol(), MODE_LOTSIZE));
 Print("M-Lot Information: Buying 1 lot in your Account is equivalent to buying ",MarketInfo(Symbol(), MODE_LOTSIZE)," of currency."); 
 Print("M-Lot Information: Buying the minimum lot size of ",MarketInfo(Symbol(), MODE_MINLOT)," is equivalent to buying ",MarketInfo(Symbol(), MODE_LOTSIZE)*MarketInfo(Symbol(), MODE_MINLOT)," of currency."); 

 Print("M-Min Stops/Limit Level = ",MarketInfo(Symbol(), MODE_STOPLEVEL), " pips.");

 RefreshRates();   

//----init end
 return(0);
}
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
//The deinitialization function contains instructions that run only once, run after all
//the code on the expert advisor has been executed. The main purpose of this section is 
//to deinitialize/delete variables.
int deinit()
  {
//----deinitialization start

Print("M-*** EA is stopping !*** Done!");   
Comment("");
//----deinitialization end
   return(0);
  }
  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
//The start function contains instructions that run every time a tick is received.
//This section is the main part of the expert advisor.
int start()
{
//none
//----start start
AutoAdjustSLTP = false;
//Prepare coments
string mycomment;
mycomment="THIS EA HAS BEEN GENERATED USING MOLANIS STRATEGY BUILDER 3.1 -";
 if (TradeOrAlert) {
   mycomment=StringConcatenate(mycomment," Trading Mode -");
 } else {
   mycomment=StringConcatenate(mycomment," Alarm Mode -");
 }
mycomment=StringConcatenate(mycomment,"\nServer Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
Comment(mycomment);

// Check trading time
 if (UseTradingTime) {
      if (!(Hour()>=TradingTimeStart && Hour()<=TradingTimeEnd)){
         mycomment=StringConcatenate(mycomment," General Settings: Server Time=",Hour(),"h:",Minute( ),"m. | Current server time is NOT between trading time hours. | Trading Time is from ",TradingTimeStart," to ",TradingTimeEnd," hours");
         Comment(mycomment);
         if (ClosePositionsNonTH && TradeOrAlert) {
         	CloseAll(OP_BUY, MagicNumberLong);
            CloseAll(OP_SELL, MagicNumberShort);
            CloseAll(OP_BUY, MagicNumberLong);
            CloseAll(OP_SELL, MagicNumberShort);
         }
         return(0);
      } else {
         mycomment=StringConcatenate(mycomment," General Settings: Server Time=",Hour(),"h:",Minute( ),"m. | Current server time is between trading time hours. | Trading Time is from ",TradingTimeStart," to ",TradingTimeEnd, " hours");
         Comment(mycomment);
      }
 }

//Time based trailing stop check
if (UseTimeBasedTS && TradeOrAlert) {
   if (TimeCurrent()- TimeTSCheck > TimeBasedTS * 60) //Check TS every TimeBasedTS minutes
       {
        TimeTSCheck = TimeCurrent();
        // Check Trailing stops
         CheckTrailingStop(Symbol(),OP_SELL,MagicNumberShort,S_Symbol_TS_0);
CheckTrailingStop(Symbol(),OP_BUY,MagicNumberLong,B_Symbol_TS_0);


       }   
}

// Define string for email   
 if (SendMailMode) {
   subject = "EA: ";
   subject = StringConcatenate(subject,EAName," ");
   mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
   mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n");
 }
// Check if trading is possible
  if(!IsConnected())
    {
     Print("M-URGENT ACTION REQUIRED : There is no connection to the server!");
     if (ShowWarnings) Alert("URGENT ACTION REQUIRED : There is no connection to the server!");
     
     if (ShowWarnings && SendMailMode) {
     	subject = StringConcatenate(subject,"URGENT ACTION REQUIRED : There is no connection to the server");
        mailstring = StringConcatenate(mailstring, "URGENT ACTION REQUIRED : There is no connection to the server. Please check your MT4 terminal.\n");
     	SendMail(subject, mailstring); 
     }
     return(0);
    }
  if(IsStopped())
    {
     Print("M-ERROR : EA was commanded to stop its operation!");
     if (ShowWarnings) Alert("ERROR : EA was commanded to stop its operation!");    
     
     if (ShowWarnings && SendMailMode) {
     	subject = StringConcatenate(subject,"EA was commanded to stop its operation");
        mailstring = StringConcatenate(mailstring, "EA was commanded to stop its operation!\n");
     	SendMail(subject, mailstring); 
     } 
     return(0);
    } 
   if (!IsTradeAllowed() && TradeOrAlert) {
     Print("M-ERROR : Trading is not allowed!");
     if (ShowWarnings) Alert("ERROR : Trading is not allowed!");

     if (ShowWarnings && SendMailMode) {
     	subject = StringConcatenate(subject,"Trading is not allowed");
        mailstring = StringConcatenate(mailstring, "Trading is not allowed at this moment. Please take action if needed\n");
     	SendMail(subject, mailstring); 
     }
     return(0); 
   } 
// Check for completed bars if CompletedBars mode is on  
  if ((PreviousBarCount==Bars) && CompletedBars) {
      if (CheckTSEveryTick && TradeOrAlert) {
          // Check Trailing stops
          CheckTrailingStop(Symbol(),OP_SELL,MagicNumberShort,S_Symbol_TS_0);
CheckTrailingStop(Symbol(),OP_BUY,MagicNumberLong,B_Symbol_TS_0);

      }
            
      return(0); //There are no new bars so do not execute
  }
  
// Trading code starts here 
if (TradeOrAlert) {
// Check conditions
if (  ( iClose(Symbol(),0,1)  >  iOpen(Symbol(),0,1) ) 
   && ( iCustom(Symbol(),0,"ZigZag",150,5,3,1,0)  >  iCustom(Symbol(),0,"ZigZag",150,5,3,3,0) ) ) 
   {  SELL(Symbol(),S_Symbol_LS_0,S_Symbol_TP_0,S_Symbol_SL_0,S_Symbol_TS_0,"if (  ( iClose(Symbol(),0,1)  >  iOpen(Symbol(),0,1) ) && ( iCustom(Symbol(),0,ZigZag,150,5,3,1,...") ;}
if (  ( iClose(Symbol(),0,1)  <  iOpen(Symbol(),0,1) ) 
   && ( iCustom(Symbol(),0,"ZigZag",150,5,3,3,3)  <  iCustom(Symbol(),0,"ZigZag",150,5,3,2,3) ) ) 
   {  BUY(Symbol(),B_Symbol_LS_0,B_Symbol_TP_0,B_Symbol_SL_0,B_Symbol_TS_0,"if (  ( iClose(Symbol(),0,1)  <  iOpen(Symbol(),0,1) ) && ( iCustom(Symbol(),0,ZigZag,150,5,3,3,...") ;}

   
// Check Trailing stops
CheckTrailingStop(Symbol(),OP_SELL,MagicNumberShort,S_Symbol_TS_0);
CheckTrailingStop(Symbol(),OP_BUY,MagicNumberLong,B_Symbol_TS_0);

} else {
// Alerts
if (  ( iClose(Symbol(),0,1)  >  iOpen(Symbol(),0,1) ) 
   && ( iCustom(Symbol(),0,"ZigZag",150,5,3,1,0)  >  iCustom(Symbol(),0,"ZigZag",150,5,3,3,0) ) ) 
   { MolanisAlert("if (  ( iClose(Symbol(),0,1)  >  iOpen(Symbol(),0,1) ) && ( iCustom(Symbol(),0, ZigZag ,150,5,3,1,...","SELL(Symbol(),1.0,0,0,50)",Symbol()) ;}
if (  ( iClose(Symbol(),0,1)  <  iOpen(Symbol(),0,1) ) 
   && ( iCustom(Symbol(),0,"ZigZag",150,5,3,3,3)  <  iCustom(Symbol(),0,"ZigZag",150,5,3,2,3) ) ) 
   { MolanisAlert("if (  ( iClose(Symbol(),0,1)  <  iOpen(Symbol(),0,1) ) && ( iCustom(Symbol(),0, ZigZag ,150,5,3,3,...","BUY(Symbol(),1.0,0,0,50)",Symbol()) ;}

}//trading code ends here

// Count bars
PreviousBarCount=Bars;  // To keep bar counter  

//----start end
   return(0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| expert functions                                                 |
//+------------------------------------------------------------------+
////                      DO NOT DELETE THIS HEADER
//             DELETING THIS HEADER IS COPYRIGHT INFRIGMENT 
//                      Copyright © 2009, Molanis
// YOU HAVE THE RIGHT TO PROFIT FROM ANY EA YOU CREATE WITH THIS SOFTWARE. HOWEVER,
// SELLING ANY OF THE FOLLOWING FUNCTIONS SEPARATELY OR AS A TEMPLATE IS COPYRIGHT INFRIGMENT.
// MOLANIS OWNS THE COPYRIGHT OF THE FOLLOWING FUNCTIONS AND AUTHORIZES YOU (A COMMERCIAL CLIENT) TO USE THEM AND SELL THEM 
// AS PART OF YOUR COMMERCIAL EA. MOLANIS WILL NOT ASK FOR ANY MONETARY RETRIBUTION BUT ASK YOU TO KEEP ALL MOLANIS REFERENCES

//The expert function section contains all functions of the expert advisor. 
//----functions start

//MolanisAlert shows alerts and send emails (if SendMailMode is ON) with alerts
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
int MolanisAlert(string condition, string sygnaltype, string mypair) {
 if (SendMailMode) {
   double mybid=MarketInfo(mypair,MODE_BID);
   double myask=MarketInfo(mypair,MODE_ASK);
   subject = "EA Alert: ";
   subject = StringConcatenate(subject,EAName,". ",sygnaltype);
   mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
   mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n");
   mailstring = StringConcatenate(mailstring, "Alert: ",sygnaltype,"\nForex Signal: ",condition,"\n");
   mailstring = StringConcatenate(mailstring, "Price on : ", mypair," BID=",mybid," ASK=",myask,"\n");
   mailstring = StringConcatenate(mailstring, "Price on current chart: ", Symbol()," BID=",MarketInfo(Symbol(),MODE_BID)," ASK=",MarketInfo(Symbol(),MODE_ASK),"\n");
   SendMail(subject, mailstring); 
 }
// Print and show alert
	
   Print("M-Alert:",sygnaltype," Forex Signal: ",condition);
   Alert("M-Alert:",sygnaltype," Forex Signal: ",condition);
   if (PlaySounds) PlaySound(MySound);
   return(0);

}

//BUY opens a long position
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2011-02-00 ***
*/
int BUY(string symbol_b, double lotsize_b, double takeprofit_b, double stoploss_b, double trailings_b, string condition_b) {
   //if conditions are true then open long position
      
      //close shorts and go long 
      if (!Hedge) CloseAllPositions(symbol_b,OP_SELL,MagicNumberShort);
      if (OrderIncludeTPSL) {
         if (ExecuteOrder(OP_BUY, symbol_b, LotManagement(symbol_b,lotsize_b),
                    stoploss_b, takeprofit_b, commentlong, MagicNumberLong, BuyColor, condition_b)>0) {   
         } else { 
   
         }
      } else {
         if (ExecuteOrderinTwo(OP_BUY, symbol_b, LotManagement(symbol_b,lotsize_b),
                    stoploss_b, takeprofit_b, commentlong, MagicNumberLong, BuyColor, condition_b)>0) {   
         } else { 
   
         }
      }
         
 return(0);
}  

//SELL opens a short position
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2011-02-00 ***
*/
int SELL(string symbol_s, double lotsize_s, double takeprofit_s, double stoploss_s, double trailings_s, string condition_s) {
   //if conditions are true then open short position
       
      //close longs and go short 
      if (!Hedge) CloseAllPositions(symbol_s,OP_BUY,MagicNumberLong);
      if (OrderIncludeTPSL) {
         if (ExecuteOrder(OP_SELL, symbol_s, LotManagement(symbol_s,lotsize_s),
                    stoploss_s, takeprofit_s, commentshort, MagicNumberShort, SellColor, condition_s)>0) {   
         } else { 
   
         }
      } else {
         if (ExecuteOrderinTwo(OP_SELL, symbol_s, LotManagement(symbol_s,lotsize_s),
                    stoploss_s, takeprofit_s, commentshort, MagicNumberShort, SellColor, condition_s)>0) {   
         } else { 
   
         }
      }

 return(0);
}   

//CLOSELONG closes long positions
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
int CLOSELONG(string symbol_c) {
 CloseAllPositions(symbol_c,OP_BUY,MagicNumberLong);
 CloseAllPositions(symbol_c,OP_BUY,MagicNumberLong);
 return(0);
}

//CLOSESHORT closes short positions
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
int CLOSESHORT(string symbol_c) {
 CloseAllPositions(symbol_c,OP_SELL,MagicNumberShort);
 CloseAllPositions(symbol_c,OP_SELL,MagicNumberShort);
 return(0);
}

//EnoughMoney checks whether there is enough money to open the position. Returns False when there is no money to trade
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
bool EnoughMoney(string symbol_em, double lotsize_em) {
   if( ( AccountFreeMarginCheck( symbol_em, OP_BUY,  lotsize_em ) < 10 ) || 
             ( AccountFreeMarginCheck( symbol_em, OP_SELL, lotsize_em ) < 10 ) || 
             ( GetLastError() == 134 ) ) {
               Print("M-NOT ENOUGH MONEY TO TRADE. Free margin is insufficient to trade a lot size of ",lotsize_em,". Current Free Margin=", AccountFreeMargin()); 
               Alert("M-NOT ENOUGH MONEY TO TRADE. Free margin is insufficient to trade a lot size of ",lotsize_em,". Current Free Margin=", AccountFreeMargin()); 
               return(false); 
               } else {
               return(true); 
               }
}

//ExecuteOrderinTwo opens a new position and then (later) adds TP and SL. Created to adjust to requirements of some brokers
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
int ExecuteOrderinTwo(int ordertype_bn, string symbol_bn, double lotsize_bn, double stoploss_bn, double takeprofit_bn, string comment_bn, int magic_bn, color ordercolor_bn, string condition_bn)  //1 is ok, -1 is not ok
 {
   int errorcode_ts=0;
   Print("M-Executing order in Two Steps. Step 1 - Sending order without TP/SL.");
   int my_ticket = ExecuteOrder(ordertype_bn, symbol_bn, lotsize_bn, 0, 0, 
      comment_bn, magic_bn, ordercolor_bn, condition_bn);  
   if ( my_ticket > 0 && (stoploss_bn != 0 || takeprofit_bn != 0) )
    {
     Print("M-Executing order in Two Steps. Step 2 - Adding TP/SL.");
     if (OrderSelect(my_ticket, SELECT_BY_TICKET)) {
         //adjusting TP/SL if needed
         RefreshRates();
         double points_bn,digits_bn, price_bn;
		   bool golong_bn;
   		digits_bn = MarketInfo(symbol_bn, MODE_DIGITS);
	     	points_bn = MarketInfo(symbol_bn, MODE_POINT);
	     	//stoploss_bn=stoploss_bn*10;
	     	//takeprofit_bn=takeprofit_bn*10;
	     	stoploss_bn=stoploss_bn*PipMultiplier;
	     	takeprofit_bn=takeprofit_bn*PipMultiplier;
	     	
		   if (UseRiskRatio) {
		 	  //adjust sl to tp/risk ratio
		 	    stoploss_bn = NormalizeDouble(takeprofit_bn/RiskRatio, digits_bn);
		 	    Print("M-Stop loss adjusted according to risk ratio, equation TakeProfit/StopLoss=",RiskRatio,". SL=Price +/- ", stoploss_bn*points_bn,".");
		   }

   		switch (ordertype_bn) {
	     	case OP_BUY: 
		    	golong_bn=true;
			   break; 
		   case OP_SELL: 
			   golong_bn=false;
			   break;
		   default:    
			   Print("M-ERROR : Wrong order type. Can not add SL/TP ", ordertype_bn);
		      return(-1);
		      break; 
		   }

   	  if (golong_bn) {
	     		price_bn = NormalizeDouble(MarketInfo(symbol_bn,MODE_ASK),digits_bn);
		    	if (stoploss_bn > 0) {
			      	stoploss_bn = NormalizeDouble(price_bn-stoploss_bn*points_bn, digits_bn);
				      stoploss_bn = CheckStopLoss(symbol_bn, price_bn, stoploss_bn);
			   }
			   if (takeprofit_bn>0) {
				   takeprofit_bn= NormalizeDouble(price_bn+takeprofit_bn*points_bn, digits_bn);
				   takeprofit_bn = CheckTakeProfit(symbol_bn, price_bn, takeprofit_bn);
			   }
		  } else {  // go short set up
			   price_bn = NormalizeDouble(MarketInfo(symbol_bn,MODE_BID),digits_bn);
			   if (stoploss_bn > 0) {
				  stoploss_bn = NormalizeDouble(price_bn+stoploss_bn*points_bn, digits_bn); 
				  stoploss_bn = CheckStopLoss(symbol_bn, price_bn, stoploss_bn);
			   }
			   if (takeprofit_bn>0) {
				  takeprofit_bn= NormalizeDouble(price_bn-takeprofit_bn*points_bn, digits_bn);
				  takeprofit_bn = CheckTakeProfit(symbol_bn, price_bn, takeprofit_bn);
			   }
		  }//closes if go long  	   
         //modify order, adds TP/SL
           if (OrderModify(my_ticket,OrderOpenPrice(),stoploss_bn,takeprofit_bn,0,ordercolor_bn))
                     {
                        Print("M-Step 2 - TP/SL added. SL=",stoploss_bn," TP=",takeprofit_bn);
                        
                     }else {
                        errorcode_ts=GetLastError(); 
                        Print("M-Step 2 failed. Could not add SL/TP to order. Error:",errorcode_ts," ",ErrorDescription(errorcode_ts));
                     }

      } else {//closes if order select 
         errorcode_ts=GetLastError(); 
         Print("M-Step 2 failed. Could not select order. Error:",errorcode_ts," ",ErrorDescription(errorcode_ts));
      }
    }//closes if my_ticket >0
   
 }

//ExecuteOrder opens a new position
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
 int ExecuteOrder(int ordertype_bn, string symbol_bn, double lotsize_bn, double stoploss_bn, double takeprofit_bn, string comment_bn, int magic_bn, color ordercolor_bn, string condition_bn)  //Returns ticket, -1 is not ok
 { int digits_bn;
   double points_bn;
   double price_bn;
   double fillprice_bn;
   int ticket_bn;
   bool golong_bn;
   int errorcode_bn;
   int retrynumber_bn=1;
   //fix decimal movement
   //stoploss_bn=stoploss_bn*10;
   //takeprofit_bn=takeprofit_bn*10;
   stoploss_bn=stoploss_bn*PipMultiplier;
   takeprofit_bn=takeprofit_bn*PipMultiplier;
   
   //Set ordertype boolean
   switch (ordertype_bn) {
      case OP_BUY: 
         golong_bn=true;
         break; 
      case OP_SELL: 
         golong_bn=false;
         break;
      default:    
         Print("M-ERROR : Wrong order type ", ordertype_bn);
         return(-1);
         break; 
   }
   
   //check open positions
   if (CalculateOpenPositions(symbol_bn,ordertype_bn,magic_bn)>=MaxNumberofPositions) {
        Print("M-Warning : Can not execute new ",OrderTypetoString(ordertype_bn)," order for Symbol ",symbol_bn,". Maximum number of ",MaxNumberofPositions," open positions reached."); 
        return(0); 
   }
   
   // Check if there is enough money to close the position
   if (!EnoughMoney(symbol_bn, lotsize_bn)) {
       //Print("M-ERROR : Not enough money to open position!");  
       //Alert("M-ERROR : Not enough money to open position!");
       return(-1); }
         
   //Gets pair info to prepare price 
   
   digits_bn = MarketInfo(symbol_bn, MODE_DIGITS);
   points_bn = MarketInfo(symbol_bn, MODE_POINT);
   if (UseRiskRatio) {
               //adjust sl to tp/riskratio
               stoploss_bn = NormalizeDouble(takeprofit_bn/RiskRatio, digits_bn);
               Print("M-Stop loss adjusted according to risk ratio, equation TakeProfit/StopLoss=",RiskRatio,". SL=Price +/- ", stoploss_bn*points_bn,".");
   }
  
  //adjust lot 
  int tmpdecimal=1;   
  if (IsMicroAccount) {
        tmpdecimal=2; 
      }
  double old_lot=lotsize_bn;
  if ((NormalizeDouble(AccountFreeMargin()*(MaximumPercentageatRisk/100)/1000.0,tmpdecimal)<lotsize_bn) && UseMaximumPercentageatRisk ) {
         lotsize_bn = NormalizeDouble(AccountFreeMargin()*(MaximumPercentageatRisk/100)/1000.0,tmpdecimal);
         if (lotsize_bn<MarketInfo(symbol_bn, MODE_MINLOT)) {
                  lotsize_bn=MarketInfo(symbol_bn, MODE_MINLOT);
                  Print("M-Lot adjusted from ",old_lot," to minimum size allowed by the server of ",lotsize_bn," but it DOES NOT comply with Maximum Risk condition. User interaction is required!"); 
               } else {
                Print("M-Lot adjusted from ",old_lot," to ",lotsize_bn," to comply with Maximum Risk condition. Each trade can risk only ",MaximumPercentageatRisk,"% of free margin."); 
         	   }
         }
                
   while(retrynumber_bn>0)
    {
      RefreshRates();

   // go long set up
   
   if (golong_bn) {
         price_bn = NormalizeDouble(MarketInfo(symbol_bn,MODE_ASK),digits_bn);
         
         if (stoploss_bn > 0)  { 
               //Verify stop loss if valid
               
               stoploss_bn = NormalizeDouble(price_bn-stoploss_bn*points_bn, digits_bn);
               stoploss_bn = CheckStopLoss(symbol_bn, price_bn, stoploss_bn);
             
               }
         
         
         if (takeprofit_bn > 0) {
            //Verify take profit is valid
            takeprofit_bn= NormalizeDouble(price_bn+takeprofit_bn*points_bn, digits_bn);
            takeprofit_bn = CheckTakeProfit(symbol_bn, price_bn, takeprofit_bn);
            
            }
         
         //Print("M-Prepare order ",symbol_bn," Buy Order.Price : Ask = ",MarketInfo(symbol_bn,MODE_ASK),". Normalized = ", price_bn,". Points ",points_bn,". Digits ",digits_bn,". Stoploss = ",stoploss_bn,". Takeprofit = ",takeprofit_bn); 
         Print("M-Preparing Buy order ",symbol_bn, " triggered by ",condition_bn);
         
      } else {  // go short set up
         price_bn = NormalizeDouble(MarketInfo(symbol_bn,MODE_BID),digits_bn);
         
          if (stoploss_bn > 0) {
               //Verify stop loss is valid
               stoploss_bn = NormalizeDouble(price_bn+stoploss_bn*points_bn, digits_bn); 
               stoploss_bn = CheckStopLoss(symbol_bn, price_bn, stoploss_bn);
             
               }
         
         if (takeprofit_bn>0) {
            //Verify take profit are valid
            takeprofit_bn= NormalizeDouble(price_bn-takeprofit_bn*points_bn, digits_bn);
            takeprofit_bn = CheckTakeProfit(symbol_bn, price_bn, takeprofit_bn);
            
            }
         
         //Print("M-Prepare order ",symbol_bn," Sell Order.Price : BID = ",MarketInfo(symbol_bn,MODE_BID),". Normalized = ", price_bn,". Points ",points_bn,". Digits ",digits_bn,". Stoploss = ",stoploss_bn,". Takeprofit = ",takeprofit_bn);
         Print("M-Preparing Sell order ",symbol_bn, " triggered by ",condition_bn);
         
      } 

      // Verify order execution
         if (!isTradingPossible()) {
                       Print("M-Warning: Trading may not be possible. Trying to open a new position.");
                       }      
         ticket_bn=OrderSend(symbol_bn,ordertype_bn,lotsize_bn,price_bn,Slippage,stoploss_bn,takeprofit_bn,comment_bn,magic_bn,0,ordercolor_bn);
         if(ticket_bn>=0)
           {
            Sleep(SleepTime);           
            if(OrderSelect(ticket_bn,SELECT_BY_TICKET)) 
               {
                 // Print("M-Order Executed Successfully! Order Info : Order Type=", OrderTypetoString(ordertype_bn), ". Symbol=", symbol_bn, ". Lot Size=",lotsize_bn,
                 //". Price=",price_bn, ". FillPrice=",OrderOpenPrice(), ". Slippage=",(OrderOpenPrice()-price_bn), ". SL=",stoploss_bn,". TP=",takeprofit_bn, ". Order time=",TimeToStr(OrderOpenTime())); 
                 Print("M-Order Executed Successfully! Order Type=", OrderTypetoString(ordertype_bn), ". Symbol=", symbol_bn);
                  
                 if (SendMailMode) {
                 	//Prepare email
                    subject = "EA: ";
   				    subject = StringConcatenate(subject,EAName,". ",symbol_bn," ",OrderTypetoString(ordertype_bn)," order executed. Ticket:",ticket_bn);
                    mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                    mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n"); 
                    mailstring = StringConcatenate(mailstring, "M-Order Executed Successfully!\nOrder Info : \n Order Type=", OrderTypetoString(ordertype_bn), ".\n Symbol=", symbol_bn, ".\n Lot Size=",lotsize_bn,
                    ".\n Price=",price_bn, ".\n FillPrice=",OrderOpenPrice(), ".\n Slippage=",(OrderOpenPrice()-price_bn), ".\n SL=",OrderStopLoss(),".\n TP=",OrderTakeProfit(), ".\n Order time=",TimeToStr(OrderOpenTime()),"\n Ticket:",ticket_bn,
                    ".\n Maximum Number of open positions:",MaxNumberofPositions,".\n Number of open positions:",CalculateOpenPositions(symbol_bn,ordertype_bn,magic_bn)); 
                 
                 	SendMail(subject, mailstring); 
     			 }
     			  
     			 if (PlaySounds) PlaySound(MySound);	
                 return(ticket_bn);
               }  
           } else {
                  errorcode_bn = GetLastError();
                  // Retry if server is busy
                  if(errorcode_bn==ERR_SERVER_BUSY || errorcode_bn==ERR_TRADE_CONTEXT_BUSY || errorcode_bn==ERR_BROKER_BUSY || errorcode_bn==ERR_NO_CONNECTION 
                     || errorcode_bn==ERR_TRADE_TIMEOUT || errorcode_bn==ERR_INVALID_PRICE || errorcode_bn==ERR_OFF_QUOTES || errorcode_bn==ERR_PRICE_CHANGED || errorcode_bn==ERR_REQUOTE) {
                      Print("M-ERROR: Server error. Sending order to server again. Retry intent number = ",retrynumber_bn);
                      retrynumber_bn++;
                      if (retrynumber_bn>MaxOrderRetry+1) {
                            Print("M-ERROR: Could not open new position. Error=",errorcode_bn, " ",ErrorDescription(errorcode_bn),". Order Info : Order Type=", OrderTypetoString(ordertype_bn), ". Symbol=", symbol_bn, ". Lot Size=",lotsize_bn,
                              ". Price=",price_bn, ". SL=",stoploss_bn,". TP=",takeprofit_bn); 
                            Alert("M-ERROR: Could not open new position. Error=",errorcode_bn, " ",ErrorDescription(errorcode_bn),". Order Info : Order Type=", OrderTypetoString(ordertype_bn), ". Symbol=", symbol_bn, ". Lot Size=",lotsize_bn,
                              ". Price=",price_bn, ". SL=",stoploss_bn,". TP=",takeprofit_bn); 
                             
                            if (SendMailMode) {
                            	subject = "EA: ";
   				                subject = StringConcatenate(subject,EAName," ",symbol_bn," ",OrderTypetoString(ordertype_bn)," order FAILED");
                                mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                                mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n");
                                mailstring = StringConcatenate(mailstring, "WARNING: Could not open new position.\n Error=",errorcode_bn, "\n",ErrorDescription(errorcode_bn),".\n Order Info :\nOrder Type=", OrderTypetoString(ordertype_bn), ".\n Symbol=", symbol_bn, ".\n Lot Size=",lotsize_bn,
                                ".\n Price=",price_bn, ".\n SL=",stoploss_bn,".\n TP=",takeprofit_bn);
                            	SendMail(subject, mailstring); 
	                        } 
	                        return (-1);
                      }
                      Sleep(SleepTime);
                  } else {
                           
                        Print("M-ERROR: Could not open new position. Error=",errorcode_bn, " ",ErrorDescription(errorcode_bn),". Order Info : Order Type=", OrderTypetoString(ordertype_bn) , ". Symbol=", symbol_bn, ". Lot Size=",lotsize_bn,
                        ". Price=",price_bn, ". SL=",stoploss_bn,". TP=",takeprofit_bn); 
                        Alert("M-ERROR: Could not open new position. Error=",errorcode_bn, " ",ErrorDescription(errorcode_bn),". Order Info : Order Type=", OrderTypetoString(ordertype_bn) , ". Symbol=", symbol_bn, ". Lot Size=",lotsize_bn,
                        ". Price=",price_bn, ". SL=",stoploss_bn,". TP=",takeprofit_bn); 
                        
                        if (errorcode_bn==ERR_INVALID_STOPS) {
                           //Print("M-Possible Problem : Market moved. SL or TP too close to current price.");  
                           //Alert("M-Possible Problem : Market moved. SL or TP too close to current price.");  
                           
                          }   	
                        
                        if (SendMailMode) {
                            subject = "EA: ";
   				            subject = StringConcatenate(subject,EAName," ",symbol_bn," ",OrderTypetoString(ordertype_bn)," order FAILED");
                            mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                            mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n");
                            mailstring = StringConcatenate(mailstring, "WARNING: Could not open new position.\n Error=",errorcode_bn, "\n",ErrorDescription(errorcode_bn),".\n Order Info :\nOrder Type=", OrderTypetoString(ordertype_bn), ".\n Symbol=", symbol_bn, ".\n Lot Size=",lotsize_bn,
                            ".\n Price=",price_bn, ".\n SL=",stoploss_bn,".\n TP=",takeprofit_bn);
                            SendMail(subject, mailstring); 
	                     } 
                        return (-1);
                  }
           } 
      } //close while          
         
       
 }

//Lot Management changes lot size. Part of money management
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/  

double LotManagement(string symbol_lot,double lot_lot)
  {
   double lot= lot_lot; // get defined lotsize
   int    orders=OrdersHistoryTotal();    // history orders total
   int    losses=0,gains=0;                  // number of losses/gain orders without a break
   
   bool magiccond=true;
   bool isLastWin=true;
   double MinLots = MarketInfo(Symbol(), MODE_MINLOT); //Minimum lot size 
   int AccDigits=1;
   if (MinLots==0.1) { 
        AccDigits=1; 
      } else { 
        AccDigits=2; 
      }
   
  
   if (!UseLotManagement && !UseMartingale) //if not using lot management
      {  
         if (lot<MarketInfo(symbol_lot, MODE_MINLOT)) {
                  lot=MarketInfo(symbol_lot, MODE_MINLOT);
                  Print("M-Warning: Your lot size of ",lot_lot," is lower than the minimum size allowed by the server. Lot size changed to ",lot);
               }               
         if (lot>100) {
            lot=100;
            Print("M-Warning: Your lot size of ",lot_lot," is higher than the maximum size allowed by the server. Lot size changed to ",lot);
         }
         return(lot);
      }
   
//calculate number of losses/wins without a break
//losses   
   
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
              { 
               Print("M-Error in history when running Lot Management! - Trying again...");
               Sleep(1000); 
               if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
                  { 
                     Print("M-Error in history when running Lot Management! - Using next order instead.");
                     continue; 
                  }
               }
         magiccond=false; 
         if (OrderMagicNumber()==0) { 
                 magiccond=true; 
               } else {
                 if (OrderMagicNumber() == MagicNumberLong || OrderMagicNumber() == MagicNumberShort) {
                     magiccond=true;
                 } else {
                     magiccond=false;                
                 }
                     
         }      
         if(OrderSymbol()!=symbol_lot || OrderType()>OP_SELL || !magiccond || MartingaleTime > OrderCloseTime()) continue;
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) {
            losses++;
            if (UseMartingale) Print ("M-Martingale ",symbol_lot," Order Index=",i," Ticket=",OrderTicket(), " Loss Number=",losses,", LotSize=",OrderLots(), " Profit=",OrderProfit());  
            }
        }
//wins      
       for(i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
            { 
               Print("M-Error in history when running Lot Management!"); 
               Sleep(1000); 
               if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
                  { 
                     Print("M-Error in history when running Lot Management! - Using next order instead.");
                     continue; 
                  }
            }
         magiccond=false; 
         if (OrderMagicNumber()==0) { 
                 magiccond=true; 
               } else {
                 if (OrderMagicNumber() == MagicNumberLong || OrderMagicNumber() == MagicNumberShort) {
                     magiccond=true;
                 } else {
                     magiccond=false;                
                 }
                     
         }      
         if(OrderSymbol()!=symbol_lot || OrderType()>OP_SELL || !magiccond || MartingaleTime > OrderCloseTime()) continue;
         if(OrderProfit()<0) break;
         if(OrderProfit()>0) { 
            gains++;
            if (UseMartingale) Print ("M-Martingale ",symbol_lot," Order Index=",i," Ticket=",OrderTicket(), " Win Number=",gains,", LotSize=",OrderLots(), " Profit=",OrderProfit());
            }
         
        }            

//Martingale lot calculation
   if (UseMartingale) {
       for(int y=orders-1;y>=0;y--)
        {
         if(OrderSelect(y,SELECT_BY_POS,MODE_HISTORY)==false) 
              { 
               Print("M-Error in history when running martingale! - Trying again...");
               Sleep(1000); 
               if(OrderSelect(y,SELECT_BY_POS,MODE_HISTORY)==false) 
                  { 
                     Print("M-Error in history when running martingale! - Using next order instead.");
                     continue; 
                  }
               }
         magiccond=false; 
         if (OrderMagicNumber()==0) { 
                 magiccond=true; 
               } else {
                 if (OrderMagicNumber() == MagicNumberLong || OrderMagicNumber() == MagicNumberShort) {
                     magiccond=true;
                 } else {
                     magiccond=false;                
                 }
                     
         }      
         if(OrderSymbol()!=symbol_lot || OrderType()>OP_SELL || !magiccond || MartingaleTime > OrderCloseTime()) continue;
         if(OrderProfit()>0) {
            isLastWin=true;
            Print ("M-Martingale ",symbol_lot," Last Order is a WIN. Index=",y," Ticket=",OrderTicket(), " LotSize=",OrderLots(), " Profit=",OrderProfit());  
            break;
         } else {
            isLastWin=false;
            Print ("M-Martingale ",symbol_lot," Last Order is a LOSS. Index=",y," Ticket=",OrderTicket(), " LotSize=",OrderLots(), " Profit=",OrderProfit());  
            break;
            }
        }
         
      if (afterLoss && losses>0 ) {
         if (!isLastWin) {
            lot=NormalizeDouble(OrderLots()*MartingaleMultiplier,AccDigits);
            }
         }
         
      if (afterWin && gains>0 ) {
         if (isLastWin) {
            lot=NormalizeDouble(OrderLots()*MartingaleMultiplier,AccDigits);
            }
         }
      
      /*if (afterWin && afterLoss) {
         if (isLastWin && gains>1) {
            lot=NormalizeDouble(OrderLots()*MartingaleMultiplier,AccDigits);
            }
         if (!isLastWin && losses>1) {
            lot=NormalizeDouble(OrderLots()*MartingaleMultiplier,AccDigits);
            }             
         }*/
         
      if (lot>MaxMartingaleSize) {
         Print ("M-Martingale ",symbol_lot," lot size is higher than Max Martingale Lot Size. Changing it from ",lot," to ",MaxMartingaleSize);  
         lot=MaxMartingaleSize;   
      }
      
      if (lot<MarketInfo(symbol_lot, MODE_MINLOT)) {
         Print("M-Warning: Your Martingale ",symbol_lot," lot size of ",lot," is lower than the minimum size allowed by the server. Lot size changed to ",MarketInfo(symbol_lot, MODE_MINLOT));
         lot=MarketInfo(symbol_lot, MODE_MINLOT);
         }
                  
      if (lot>MarketInfo(symbol_lot, MODE_MAXLOT)) {
            Print("M-Warning: Your Martingale ",symbol_lot," lot size of ",lot," is higher than the maximum size allowed by the server. Lot size changed to ",MarketInfo(symbol_lot, MODE_MAXLOT));
            lot=MarketInfo(symbol_lot, MODE_MAXLOT);
         }
      return(lot);
   }            
     // 1 - Uses Decrease factor
     // 2 - Uses a fix factor 75%,50%.25%
  //set normalizedouble
  int tmpdecimal=1;   
  if (IsMicroAccount) {
        tmpdecimal=2;  
      } 
 //adjusting lot size         
                                      
     if (LotManagementType==1) {       
      if(ReductionFactor>0)
      {
         if(losses>0) {lot=NormalizeDouble(lot-(lot*losses/ReductionFactor),tmpdecimal);
            
            if (lot<MarketInfo(symbol_lot, MODE_MINLOT)) {
                  lot=MarketInfo(symbol_lot, MODE_MINLOT);
                  Print("M-MoneyManagementType=1. Loss number=",losses,". Lot adjusted to minimum size allowed by server of ",lot, " from ",lot_lot);  
                  
            } else {
                  Print("M-MoneyManagementType=1. Loss number=",losses,". Lot adjusted to ",lot, " from ",lot_lot);  
            }
             
         }
      
      }
     }  else if (LotManagementType==2) { 
         if (losses==1) {
               lot=NormalizeDouble(0.75*lot,tmpdecimal);
               if (lot<MarketInfo(symbol_lot, MODE_MINLOT)) {
                  lot=MarketInfo(symbol_lot, MODE_MINLOT);
                  Print("M-MoneyManagementType=2. 1st loss, Lot adjusted to minimum size allowed by server of ",lot, " from ",lot_lot);  
                  
               } else {
                  Print("M-MoneyManagementType=2. 1st loss, Lot adjusted to 75% of lot =",lot, " from ",lot_lot);  
               }
            
            }
         if (losses==2) {
            
            
               lot=NormalizeDouble(0.50*lot,tmpdecimal);
               if (lot<MarketInfo(symbol_lot, MODE_MINLOT)) {
                  lot=MarketInfo(symbol_lot, MODE_MINLOT);
                  Print("M-MoneyManagementType=2. 2nd loss, Lot adjusted to minimum size allowed by server of ",lot, " from ",lot_lot);  
                  
               } else {
                  Print("M-MoneyManagementType=2. 2nd loss, Lot adjusted to 50% of lot =",lot, " from ",lot_lot);
               }  
               
            }
         if (losses>=3) {
                        
               lot=NormalizeDouble(0.25*lot,tmpdecimal);
               if (lot<MarketInfo(symbol_lot, MODE_MINLOT)) {
                  lot=MarketInfo(symbol_lot, MODE_MINLOT);
                  Print("M-MoneyManagementType=2. 3rd loss, Lot adjusted to minimum size allowed by server of ",lot, " from ",lot_lot);  
                  
               } else {
                  Print("M-MoneyManagementType=2. 3rd loss, Lot adjusted to 25% of lot =",lot, " from ",lot_lot);  
               }
               
            }
     }
   
   
   return(lot);
}   
 
//CalculateOpenPositions returs the number of positions
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2011-05-20 ***
*/
int CalculateOpenPositions(string symbol,int ordertype,int magicn) 
  {
   int sells=0;
   int buys=0;
   
   int sellstop=0;
   int buystop=0;
   
   bool magiccond=true;
  //verify type is ok
  if(ordertype==OP_BUY || ordertype==OP_SELL || ordertype==OP_SELLSTOP || ordertype==OP_BUYSTOP) {
   //ok 
   } else {
    Print("M-Can not calculate open positions. Order type is wrong.");
    Alert("M-Can not calculate open positions. Order type is wrong.");
    return(-1);
  }
//----
   int orderstotal = OrdersTotal();
   for(int i=0;i<orderstotal;i++)
     {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
        if (magicn==0) { 
                 magiccond=true; 
               } else {
                 if (OrderMagicNumber() == magicn) {
                     magiccond=true;
                 } else {
                     magiccond=false;                
                 }
                     
         }
               
      if ((OrderSymbol()==symbol) && (magiccond))
        {
         
         if(OrderType()==OP_SELL) sells++;
         if(OrderType()==OP_BUY) buys++;
         
         if(OrderType()==OP_SELLSTOP) sellstop++;
         if(OrderType()==OP_BUYSTOP) buystop++;
         
        }
     }
//---- return number of orders
   if(ordertype==OP_SELL) return(sells);
   if(ordertype==OP_BUY) return(buys);
   
   if(ordertype==OP_SELLSTOP) return(sellstop);
   if(ordertype==OP_BUYSTOP) return(buystop);
   
   return(-1);      
  }
   
//This function Returs the string value of the order type
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
string OrderTypetoString(int ordertypecode)
{
	if (ordertypecode == OP_BUY)
		return("OP_BUY");

	if (ordertypecode == OP_SELL)
		return("OP_SELL");

	if (ordertypecode == OP_BUYSTOP)
		return("OP_BUYSTOP");

	if (ordertypecode == OP_SELLSTOP)
		return("OP_SELLSTOP");

	if (ordertypecode == OP_BUYLIMIT)
		return("OP_BUYLIMIT");

	if (ordertypecode == OP_SELLLIMIT)
		return("OP_SELLLIMIT");

	return("Unknow order type");
}

//This function closes all market positions for all pairs.
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
int CloseAll(int ordertypeclose, int magicclose)
{
  int cnt;
  int err;
  int retrynumberclose=0;
  double priceclose;
  bool magiccond=true;
  //verify type is ok
  if(ordertypeclose==OP_BUY || ordertypeclose==OP_SELL) {
   //ok 
   } else {
    Print("M-Closing all positions failed. Order type is wrong.");
    Alert("M-Closing all positions failed. Order type is wrong.");
    return(-1);
  }
      
  int orderstotal=OrdersTotal();          
  bool loopcl=true;
  while (loopcl) { 
   loopcl=false;
   orderstotal=OrdersTotal();
   for(cnt=0;cnt<orderstotal;cnt++)
        {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) //executes if gets valid order
            {
            
            if (magicclose==0) { 
                 magiccond=true; 
               } else {
                 if (OrderMagicNumber() == magicclose) {
                     magiccond=true;
                 } else {
                     magiccond=false;                
                 }
                     
               }
            if(OrderType()==ordertypeclose  && magiccond)  
               {
                   //get closing price
                   RefreshRates();
                    if(OrderType()==OP_BUY) priceclose=MarketInfo(OrderSymbol(),MODE_BID);
                      else priceclose=MarketInfo(OrderSymbol(),MODE_ASK);
                   if (!isTradingPossible()) {
                       Print("M-Warning: Trading may not be possible. Trying to close orders.");
                       }
                   if (OrderClose(OrderTicket(),OrderLots(),priceclose,Slippage,Violet)) // close position
                         {
                           Print("M-Order Closed. Symbol:",OrderSymbol( ),". Lots:",OrderLots(),". Ticket number:",OrderTicket(),". Closed at price:",OrderClosePrice(),". Position was opened at price:",OrderOpenPrice()," Profit:",OrderProfit());
                           if (SendMailMode) {
                 				//Prepare email
                    			subject = "EA: ";
   				    			subject = StringConcatenate(subject,EAName,". ",OrderSymbol()," ",OrderTypetoString(OrderType())," position was closed. ","Ticket:",OrderTicket());
                    			mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                    			mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n"); 
                    			mailstring = StringConcatenate(mailstring, "M-Order Closed\nOrder Info : \n Order Closed Type=", OrderTypetoString(OrderType()), ".\n Symbol=", OrderSymbol(), ".\n Lot Size=",OrderLots(),
                    			".\n Ticket:",OrderTicket(),".\n Closed at price:",OrderClosePrice(),".\n Position was opened at price:",OrderOpenPrice(),".\n Profit:",OrderProfit()); 
                 
                 				SendMail(subject, mailstring); 
     			 			}
                            
                           loopcl=true;
                           retrynumberclose=1;
                           break; //break loop and restart again
                        }else {
                           err=GetLastError();
                           Print("M-Closing Order failed. Symbol:",OrderSymbol(),". Lots:",OrderLots(),". Ticket number:",OrderTicket(),". Error:",err," ",ErrorDescription(err));
                           Alert("M-Closing Order failed. Symbol:",OrderSymbol(),". Lots:",OrderLots(),". Ticket number:",OrderTicket(),". Error:",err," ",ErrorDescription(err));
                           if (SendMailMode) {
                 				//Prepare email
                    			subject = "EA: ";
   				    			subject = StringConcatenate(subject,EAName," WARNING:",OrderSymbol()," ",OrderTypetoString(OrderType())," position could NOT be closed");
                    			mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                    			mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n"); 
                    			mailstring = StringConcatenate(mailstring, "M-Closing Order failed.\nSymbol:",OrderSymbol(),".\n Lots:",OrderLots(),".\n Ticket number:",OrderTicket(),".\n Error:",err,"\n",ErrorDescription(err)); 
                 
                 				SendMail(subject, mailstring); 
     			 			}
                            
                           loopcl=true;
                           retrynumberclose++;
                           break; //break loop and restart again
                        }
                  
               }    
             
            }
         }//for
   if (retrynumberclose>MaxOrderRetry+10) {
      Print("M-Stopping Closing all positions. Too many errors when closing positions. Symbol:",OrderSymbol());
      Print("M-URGENT:Please verify your Internet Connection and Server response.");
      Alert("M-Stopping Closing all positions. Too many errors when closing positions. Symbol:",OrderSymbol());
      Alert("M-URGENT:Please verify your Internet Connection and Server response.");
      return(-1);
   }      
  }//while

return(0); 
}

//This function closes all market positions.
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
int CloseAllPositions(string symbolclose, int ordertypeclose, int magicclose)
{
  //Print("M-Closing all positions started...");
  int cnt;
  int err;
  int retrynumberclose=0;
  double priceclose;
  bool magiccond=true;
  //verify type is ok
  if(ordertypeclose==OP_BUY || ordertypeclose==OP_SELL) {
   //ok 
   } else {
    Print("M-Closing all positions failed. Order type is wrong.");
    Alert("M-Closing all positions failed. Order type is wrong.");
    return(-1);
  }
  
  //Print("M-Closing all positions (",symbolclose,",",OrderTypetoString(ordertypeclose),",",magicclose,")");
  int orderstotal=OrdersTotal();          
  bool loopcl=true;
  while (loopcl) { 
   loopcl=false;
   orderstotal=OrdersTotal();
   for(cnt=0;cnt<orderstotal;cnt++)
        {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) //executes if gets valid order
            {
            
            if (magicclose==0) { 
                 magiccond=true; 
               } else {
                 if (OrderMagicNumber() == magicclose) {
                     magiccond=true;
                 } else {
                     magiccond=false;                
                 }
                     
               }
            if((OrderType()==ordertypeclose) && (OrderSymbol()==symbolclose) && (magiccond))  
               {
                   //get closing price
                   RefreshRates();
                    if(ordertypeclose==OP_BUY) priceclose=MarketInfo(symbolclose,MODE_BID);
                      else priceclose=MarketInfo(symbolclose,MODE_ASK);
                   if (!isTradingPossible()) {
                       Print("M-Warning: Trading may not be possible. Trying to close orders.");
                       }
                   if (OrderClose(OrderTicket(),OrderLots(),priceclose,Slippage,Violet)) // close position
                         {
                           Print("M-Order Closed. Symbol:",symbolclose,". Lots:",OrderLots(),". Ticket number:",OrderTicket(),". Closed at price:",OrderClosePrice(),". Position was opened at price:",OrderOpenPrice()," Profit:",OrderProfit());
                           if (SendMailMode) {
                 				//Prepare email
                    			subject = "EA: ";
   				    			subject = StringConcatenate(subject,EAName,". ",symbolclose," ",OrderTypetoString(ordertypeclose)," position was closed. ","Ticket:",OrderTicket());
                    			mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                    			mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n"); 
                    			mailstring = StringConcatenate(mailstring, "M-Order Closed\nOrder Info : \n Order Closed Type=", OrderTypetoString(ordertypeclose), ".\n Symbol=", symbolclose, ".\n Lot Size=",OrderLots(),
                    			".\n Ticket:",OrderTicket(),".\n Closed at price:",OrderClosePrice(),".\n Position was opened at price:",OrderOpenPrice(),".\n Profit:",OrderProfit()); 
                 
                 				SendMail(subject, mailstring); 
     			 			}
                            
                           loopcl=true;
                           retrynumberclose=1;
                           break; //break loop and restart again
                        }else {
                           err=GetLastError();
                           Print("M-Closing Order failed. Symbol:",symbolclose,". Lots:",OrderLots(),". Ticket number:",OrderTicket(),". Error:",err," ",ErrorDescription(err));
                           Alert("M-Closing Order failed. Symbol:",symbolclose,". Lots:",OrderLots(),". Ticket number:",OrderTicket(),". Error:",err," ",ErrorDescription(err));
                           if (SendMailMode) {
                 				//Prepare email
                    			subject = "EA: ";
   				    			subject = StringConcatenate(subject,EAName," WARNING:",symbolclose," ",OrderTypetoString(ordertypeclose)," position could NOT be closed");
                    			mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                    			mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n"); 
                    			mailstring = StringConcatenate(mailstring, "M-Closing Order failed.\nSymbol:",symbolclose,".\n Lots:",OrderLots(),".\n Ticket number:",OrderTicket(),".\n Error:",err,"\n",ErrorDescription(err)); 
                 
                 				SendMail(subject, mailstring); 
     			 			}
                            
                           loopcl=true;
                           retrynumberclose++;
                           break; //break loop and restart again
                        }
                  
               }    
             
            }
         }//for
   if (retrynumberclose>MaxOrderRetry+10) {
      Print("M-Stopping Closing all positions. Too many errors when closing positions. Symbol:",symbolclose);
      Print("M-URGENT:Please verify your Internet Connection and Server response.");
      Alert("M-Stopping Closing all positions. Too many errors when closing positions. Symbol:",symbolclose);
      Alert("M-URGENT:Please verify your Internet Connection and Server response.");
      return(-1);
   }      
  }//while
//Print("M-Closing all positions finished. (",symbolclose,",",OrderTypetoString(ordertypeclose),",",magicclose,")");
return(0); 
}

//This function check if trading is possible.
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
bool isTradingPossible()
{
//Check if trading is possible
bool tmpresponse=true;
  if(!IsConnected())
    {
     Print("M-URGENT ACTION REQUIRED : There is no connection to the server!");
     if (ShowWarnings) Alert("URGENT ACTION REQUIRED : There is no connection to the server!");
     tmpresponse=false;
    }
  if(IsStopped())
    {
     Print("M-ERROR : EA was commanded to stop its operation!");
     if (ShowWarnings) Alert("ERROR : EA was commanded to stop its operation!");
     tmpresponse=false;
    } 
   if (!IsTradeAllowed()) {
     Print("M-ERROR : Trading is not allowed!");
     if (ShowWarnings) Alert("ERROR : Trading is not allowed!");
     tmpresponse=false; 
   } 
   return(tmpresponse);
} //end function
   
//To adjust SL to server accepted levels
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/

double CheckStopLoss(string symbol_sl, double price_sl, double sl)
{
if (AutoAdjustSLTP) { //executes when AutoAdjustSLTP is set to true
	double minimumstop;
	if (sl == 0) { // no stop loss
		return(sl);
   }
	minimumstop = 3*MarketInfo(symbol_sl, MODE_STOPLEVEL) * MarketInfo(symbol_sl, MODE_POINT);
   Print("M-Minimum stop loss allowed=",minimumstop);
	if (MathAbs(price_sl - sl) <= minimumstop)
	{
		//move to a higher stop that assure execution
		//for longs
		if (price_sl > sl) {
			sl = price_sl - minimumstop; 	
		} else if (price_sl < sl) {
		//for shorts
			sl = price_sl + minimumstop;	
      } else {
			Print("M-ERROR: Could not adjust stop loss, SL=",sl);
			return(sl);
      }
      //normalize SL
		sl = NormalizeDouble(sl, MarketInfo(symbol_sl, MODE_DIGITS));
		Print("M-Stop Loss was too small. It was changed. New SL=",sl);
	}
	return(sl);
}else{
return(sl);
}
}

// Trailing stops
// To adjust trailing stops
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2011-02-00 ***
*/
int CheckTrailingStop(string symbol_ts, int ordertypeclose_ts,int magicnumber_ts, double tralingstop_ts)
{
   
   if (tralingstop_ts==0)
      {  return(0);
      }
    //verify type is ok
  if(ordertypeclose_ts==OP_BUY || ordertypeclose_ts==OP_SELL) {
   //ok 
   } else {
    Print("M-Check Trailing Stop failed. Order type is wrong.");
    return(-1);
  }
    double TrailingStop = tralingstop_ts;
    double oldStop=0;
    int errorcode_ts = 0;
    bool magiccond_ts; 
            
   int orderstotal=OrdersTotal();   
   for(int i=0;i<orderstotal;i++)
   {
      
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) {
         Print("M-Warning: Could not select order to ckeck change on trailing stop. Continuing..."); 
         continue;
      }
      
      if (magicnumber_ts==0) { 
                 magiccond_ts=true; 
               } else {
               if (OrderMagicNumber() == magicnumber_ts) {
                     magiccond_ts=true; 
               } else {
                     magiccond_ts=false;                
               }
                     
      }
               
      if(OrderSymbol()==symbol_ts && magiccond_ts)
      {
         RefreshRates();
         if(ordertypeclose_ts==OP_SELL) 
          {
            if(TrailingStop>0)  
            {                 
               RefreshRates();
               if((OrderOpenPrice()-MarketInfo(symbol_ts, MODE_ASK))>(MarketInfo(symbol_ts, MODE_POINT)*TrailingStop*PipMultiplier))
                 {
                  if((OrderStopLoss()>(MarketInfo(symbol_ts, MODE_ASK)+MarketInfo(symbol_ts, MODE_POINT)*TrailingStop*PipMultiplier)) || (OrderStopLoss()==0))
                    {
                     oldStop=OrderStopLoss();
                     if (OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(symbol_ts, MODE_ASK)+MarketInfo(symbol_ts, MODE_POINT)*TrailingStop*PipMultiplier,OrderTakeProfit(),0,Red))
                     {
                        Print("M-SL changed using trailing stop. Old SL=",oldStop," New SL=",MarketInfo(symbol_ts, MODE_ASK)+MarketInfo(symbol_ts, MODE_POINT)*TrailingStop*PipMultiplier);
                        
                     }else {
                        errorcode_ts=GetLastError(); 
                        Print("M-Warning: Could not change SL value with trailing stop. Error:",errorcode_ts," ",ErrorDescription(errorcode_ts));
                     }
                     
                    }
                 }
            }
            
          }
          if(ordertypeclose_ts==OP_BUY)  
            {
             if(TrailingStop>0)  
              {                 
               RefreshRates();
               if(MarketInfo(symbol_ts, MODE_BID)-OrderOpenPrice()>MarketInfo(symbol_ts, MODE_POINT)*TrailingStop*PipMultiplier)
                 {
                  if(OrderStopLoss()<MarketInfo(symbol_ts, MODE_BID)-MarketInfo(symbol_ts, MODE_POINT)*TrailingStop*PipMultiplier)
                    {
                     oldStop=OrderStopLoss();
                     if (OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(symbol_ts, MODE_BID)-MarketInfo(symbol_ts, MODE_POINT)*TrailingStop*PipMultiplier,OrderTakeProfit(),0,Green))
                     {
                        Print("M-SL changed using trailing stop. Old SL=",oldStop," New SL=",MarketInfo(symbol_ts, MODE_BID)-MarketInfo(symbol_ts, MODE_POINT)*TrailingStop*PipMultiplier);
                     }else {
                        errorcode_ts=GetLastError(); 
                        Print("M-Warning: Could not change SL value with trailing stop. Error:",errorcode_ts," ",ErrorDescription(errorcode_ts));
                     }
                     
                    }
                 }
              }
            }
             
       }
     }//for
return(1);
}

//To adjust TP to server accepted levels
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2010-02-20 ***
*/
double CheckTakeProfit(string symbol_tp, double price_tp, double tp)
{
if (AutoAdjustSLTP) {
	double minimumstop;
	if (tp == 0) { //no take profit
		return(tp);
   }
   minimumstop = 3*MarketInfo(symbol_tp, MODE_STOPLEVEL) * MarketInfo(symbol_tp, MODE_POINT);
   Print("M-Minimum take profit allowed=",minimumstop);
	if (MathAbs(price_tp - tp) <= minimumstop)
	{
		//move to a higher stop that assure execution
		//for longs
		if (price_tp < tp) {
			tp = price_tp + minimumstop;		 
      //for shorts
		} else if (price_tp > tp) {
			tp = price_tp - minimumstop; 
      } else {
			Print("M-ERROR: Could not adjust take profit, TP=",tp);
			return(tp);
      }
      //normalize TP
		tp = NormalizeDouble(tp, MarketInfo(symbol_tp, MODE_DIGITS));
		Print("M-Take Profit too small. It was changed. New TP=",tp);
	}
	return(tp);
}else{
return(tp);
}	
} 

//PENDINGORDER opens a pending order
/*
*** Generated with Molanis Strategy Builder 3.1 Beta ***
*** www.molanis.com ***
*** Released 2011-05-29 ***
*/
int PENDINGORDER(int ordertype_p,string symbol_p, double lotsize_p, double price_offp, double stoploss_p, double takeprofit_p, string comment_p, int magic_p, color ordercolor_p, string condition_p, int expiration_p) {
 bool golong_p=false;
 if (expiration_p<1) {
  Print("M-ERROR : Expiration has to be at least 1 minute.");  
  return(-1);
 } 
 int myexpiration = TimeCurrent() + expiration_p * 60;     
 int digits_p;
 double points_p; 
 double price_p=0;
 
 int ticket_p;
 int retrynumber_p=1;
 int errorcode_p;
 
 //Adjust 5 digits
 stoploss_p=stoploss_p*PipMultiplier;
 takeprofit_p=takeprofit_p*PipMultiplier;
 price_offp=price_offp*PipMultiplier;
  //Set ordertype boolean
   switch (ordertype_p) {
      case OP_BUYSTOP: 
         golong_p=true;
         break; 
      case OP_SELLSTOP: 
         golong_p=false;
         break;
      default:    
         Print("M-ERROR : Wrong pending order type ", ordertype_p);
         return(-1);
         break; 
   }
   
  //check open pending positions
   if (CalculateOpenPositions(symbol_p,ordertype_p,magic_p)>=MaxNumberofPositions) {
        Print("M-Warning : Can not execute new pending ",OrderTypetoString(ordertype_p)," order for Symbol ",symbol_p,". Maximum number of ",MaxNumberofPositions," pending open positions reached."); 
        return(0); 
   }
   
  //Verify capital
  if (!EnoughMoney(symbol_p, lotsize_p)) {
      Print("M-WARNING : You may not have enough money to cover the execution of the pending order ", OrderTypetoString(ordertype_p));
  } 
  // To do: Add % at risk
    
   //Gets pair info to prepare price 
   
   digits_p = MarketInfo(symbol_p, MODE_DIGITS);
   points_p = MarketInfo(symbol_p, MODE_POINT);    
   
   
   while(retrynumber_p>0)
   {
      RefreshRates();
      
       // go long set up
   
   if (golong_p) {
         price_p = NormalizeDouble(MarketInfo(symbol_p,MODE_ASK)+price_offp*points_p,digits_p);//++5 digits
         
         if (stoploss_p > 0)  { 
               //To do : Verify stop loss if valid
               stoploss_p = NormalizeDouble(price_p-stoploss_p*points_p, digits_p);
                            
             }
         
         
         if (takeprofit_p > 0) {
            //Todo : Verify take profit is valid
            takeprofit_p= NormalizeDouble(price_p+takeprofit_p*points_p, digits_p);
           
            }
                 
         Print("M-Preparing Buy pending order ",symbol_p, " triggered by ",condition_p);
         
      } else {  // go short set up
         price_p = NormalizeDouble(MarketInfo(symbol_p,MODE_BID)-price_offp*points_p,digits_p);
         
          if (stoploss_p > 0) {
               //To do: Verify stop loss is valid
               stoploss_p = NormalizeDouble(price_p+stoploss_p*points_p, digits_p); 
                           
               }
         
         if (takeprofit_p>0) {
            //To do :Verify take profit are valid
            takeprofit_p= NormalizeDouble(price_p-takeprofit_p*points_p, digits_p);
                  
            }
         
         
         Print("M-Preparing Sell pending order ",symbol_p, " triggered by ",condition_p);
         
      } 

     //Sending Pending Order
     ticket_p=OrderSend(symbol_p,ordertype_p,lotsize_p,price_p,Slippage,stoploss_p,takeprofit_p,comment_p,magic_p,myexpiration,ordercolor_p);
//-
     if(ticket_p>=0)
           {
            Sleep(SleepTime);           
            if(OrderSelect(ticket_p,SELECT_BY_TICKET)) 
               {
                 Print("M-Pending Order Executed Successfully! Order Type=", OrderTypetoString(ordertype_p), ". Symbol=", symbol_p, ". Lot Size=",lotsize_p,
                    ". Price=",price_p, ". SL=",OrderStopLoss(),". TP=",OrderTakeProfit(), ". Expiration time=",TimeToStr(myexpiration)," Ticket:",ticket_p,
                    ". ","BID=",MarketInfo(symbol_p,MODE_BID)," ASK=",MarketInfo(symbol_p,MODE_ASK));
                  
                 if (SendMailMode) {
                 	//Prepare email
                    subject = "EA: ";
   				     subject = StringConcatenate(subject,EAName,". ",symbol_p," ",OrderTypetoString(ordertype_p)," pending order executed. Ticket:",ticket_p);
                    mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                    mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n"); 
                    mailstring = StringConcatenate(mailstring, "M-Pending Order Executed Successfully!\nOrder Info : \n Order Type=", OrderTypetoString(ordertype_p), ".\n Symbol=", symbol_p, ".\n Lot Size=",lotsize_p,
                    ".\n Price=",price_p, ".\n SL=",OrderStopLoss(),".\n TP=",OrderTakeProfit(), ".\n Expiration time=",TimeToStr(myexpiration),"\n Ticket:",ticket_p,
                    "."); 
                 
                 	  SendMail(subject, mailstring); 
     			      }
     			  
     			      if (PlaySounds) PlaySound(MySound);	
                  return(ticket_p);
               }  
           } else {
                  errorcode_p = GetLastError();
                  // Retry if server is busy
                  if(errorcode_p==ERR_SERVER_BUSY || errorcode_p==ERR_TRADE_CONTEXT_BUSY || errorcode_p==ERR_BROKER_BUSY || errorcode_p==ERR_NO_CONNECTION 
                     || errorcode_p==ERR_TRADE_TIMEOUT || errorcode_p==ERR_INVALID_PRICE || errorcode_p==ERR_OFF_QUOTES || errorcode_p==ERR_PRICE_CHANGED || errorcode_p==ERR_REQUOTE) {
                      Print("M-ERROR: Server error. Sending pending order to server again. Retry intent number = ",retrynumber_p);
                      retrynumber_p++;
                      if (retrynumber_p>MaxOrderRetry+1) {
                            Print("M-ERROR: Could not open new pending order. Error=",errorcode_p, " ",ErrorDescription(errorcode_p),". Order Info : Order Type=", OrderTypetoString(ordertype_p), ". Symbol=", symbol_p, ". Lot Size=",lotsize_p,
                              ". Price=",price_p, ". SL=",stoploss_p,". TP=",takeprofit_p, ". Expiration time=",TimeToStr(myexpiration)); 
                            Alert("M-ERROR: Could not open new pending position. Error=",errorcode_p, " ",ErrorDescription(errorcode_p),". Order Info : Order Type=", OrderTypetoString(ordertype_p), ". Symbol=", symbol_p, ". Lot Size=",lotsize_p,
                              ". Price=",price_p, ". SL=",stoploss_p,". TP=",takeprofit_p, ". Expiration time=",TimeToStr(myexpiration)); 
                             
                            if (SendMailMode) {
                            	subject = "EA: ";
   				                subject = StringConcatenate(subject,EAName," ",symbol_p," ",OrderTypetoString(ordertype_p)," pending order FAILED");
                                mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                                mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n");
                                mailstring = StringConcatenate(mailstring, "WARNING: Could not open new pending order.\n Error=",errorcode_p, "\n",ErrorDescription(errorcode_p),".\n Order Info :\nOrder Type=", OrderTypetoString(ordertype_p), ".\n Symbol=", symbol_p, ".\n Lot Size=",lotsize_p,
                                ".\n Price=",price_p, ".\n SL=",stoploss_p,".\n TP=",takeprofit_p, ".\n Expiration time=",TimeToStr(myexpiration));
                            	SendMail(subject, mailstring); 
	                        } 
	                        return (-1);
                      }
                      Sleep(SleepTime);
                  } else {
                           
                        Print("M-ERROR: Could not open new pending position. Error=",errorcode_p, " ",ErrorDescription(errorcode_p),". Order Info : Order Type=", OrderTypetoString(ordertype_p) , ". Symbol=", symbol_p, ". Lot Size=",lotsize_p,
                        ". Price=",price_p, ". SL=",stoploss_p,". TP=",takeprofit_p, ". Expiration time=",TimeToStr(myexpiration)); 
                        Alert("M-ERROR: Could not open new position. Error=",errorcode_p, " ",ErrorDescription(errorcode_p),". Order Info : Order Type=", OrderTypetoString(ordertype_p) , ". Symbol=", symbol_p, ". Lot Size=",lotsize_p,
                        ". Price=",price_p, ". SL=",stoploss_p,". TP=",takeprofit_p, ". Expiration time=",TimeToStr(myexpiration)); 
                        
                        if (errorcode_p==ERR_INVALID_STOPS) {
                           //Print("M-Possible Problem : Market moved. SL or TP too close to current price.");  
                           //Alert("M-Possible Problem : Market moved. SL or TP too close to current price.");  
                           
                          }   	
                        
                        if (SendMailMode) {
                            	subject = "EA: ";
   				                subject = StringConcatenate(subject,EAName," ",symbol_p," ",OrderTypetoString(ordertype_p)," pending order FAILED");
                                mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                                mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n");
                                mailstring = StringConcatenate(mailstring, "WARNING: Could not open new pending order.\n Error=",errorcode_p, "\n",ErrorDescription(errorcode_p),".\n Order Info :\nOrder Type=", OrderTypetoString(ordertype_p), ".\n Symbol=", symbol_p, ".\n Lot Size=",lotsize_p,
                                ".\n Price=",price_p, ".\n SL=",stoploss_p,".\n TP=",takeprofit_p, ".\n Expiration time=",TimeToStr(myexpiration));
                            	SendMail(subject, mailstring); 
	                        } 
                        return (-1);
                  }
           } 

//-     
   }//while
 return(0);
} 

//DeletePending deletes a pending order
/*
*** Generated with Molanis Strategy Builder 3.1 Beta ***
*** www.molanis.com ***
*** Released 2011-05-29 ***
*/
int DeletePending(string symbolclose, int ordertypeclose, int magicclose)
{
  int cnt;
  int err;
  int retrynumberclose=0;
  double priceclose;
  bool magiccond=true;
  //verify type is ok
  if (ordertypeclose==OP_BUYLIMIT || ordertypeclose==OP_SELLLIMIT || ordertypeclose==OP_BUYSTOP || ordertypeclose==OP_SELLSTOP) {
   //ok 
   } else {
    Print("M-Deleting pending positions failed. Order type is wrong.");
    Alert("M-Deleting pending positions failed. Order type is wrong.");
    return(-1);
  }
  
  int orderstotal=OrdersTotal();          
  bool loopcl=true;
  while (loopcl) { 
   loopcl=false;
   orderstotal=OrdersTotal();
   for(cnt=0;cnt<orderstotal;cnt++)
        {
         if (OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) //executes if gets valid order
            {
            
            if (magicclose==0) { 
                 magiccond=true; 
               } else {
                 if (OrderMagicNumber() == magicclose) {
                     magiccond=true;
                 } else {
                     magiccond=false;                
                 }
                     
               }
            if((OrderType()==ordertypeclose) && (OrderSymbol()==symbolclose) && (magiccond))  
               {
                   //get closing price
                   RefreshRates();
                   if (!isTradingPossible()) {
                       Print("M-Warning: Trading may not be possible. Trying to delete pending orders.");
                       }
                   if (OrderDelete(OrderTicket(), Violet)) // close position
                         {
                           Print("M-Pending Order Deleted. Symbol:",symbolclose,". Lots:",OrderLots(),". Ticket number:",OrderTicket());
                           if (SendMailMode) {
                 				//Prepare email
                    			   subject = "EA: ";
   				    			   subject = StringConcatenate(subject,EAName,". ",symbolclose," ",OrderTypetoString(ordertypeclose)," pending order was deleted. ","Ticket:",OrderTicket());
                    			   mailstring = "email generated by Molanis Strategy Builder v3.1 \n";
                    			   mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n"); 
                    			   mailstring = StringConcatenate(mailstring, "M-Pending Order Deleted\nOrder Info : \n Pending Order Type=", OrderTypetoString(ordertypeclose), ".\n Symbol=", symbolclose, ".\n Lot Size=",OrderLots(),
                    			   ".\n Ticket:",OrderTicket()); 
                        	   SendMail(subject, mailstring); 
     			 			      }
                            
                           loopcl=true;
                           retrynumberclose=1;
                           break; //break loop and restart again
                        
                         }else {
                           err=GetLastError();
                           Print("M-Deleting Pending Order failed. Symbol:",symbolclose,". Lots:",OrderLots(),". Ticket number:",OrderTicket(),". Error:",err," ",ErrorDescription(err));
                           Alert("M-Deleting Pending Order failed. Symbol:",symbolclose,". Lots:",OrderLots(),". Ticket number:",OrderTicket(),". Error:",err," ",ErrorDescription(err));
                           if (SendMailMode) {
                 				  //Prepare email
                    			  subject = "EA: ";
   				    			  subject = StringConcatenate(subject,EAName," WARNING:",symbolclose," ",OrderTypetoString(ordertypeclose)," pending order could NOT be deleted");
                    			  mailstring = "email generated by Molanis Strategy Builder v3.1 BETA\n";
                    		 	  mailstring = StringConcatenate(mailstring, "Server Time=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),". Terminal Time=",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),"\n"); 
                    			  mailstring = StringConcatenate(mailstring, "M-Deleting Pending Order failed.\nSymbol:",symbolclose,".\n Lots:",OrderLots(),".\n Ticket number:",OrderTicket(),".\n Error:",err,"\n",ErrorDescription(err)); 
                  			  SendMail(subject, mailstring); 
     			 			      }
                            
                           loopcl=true;
                           retrynumberclose++;
                           break; //break loop and restart again
                        }
                  
               }    
             
            }
         }//for
   if (retrynumberclose>MaxOrderRetry+10) {
      Print("M-Stopping Deleting Pending Orders. Too many errors when deleting orders. Symbol:",symbolclose);
      Print("M-URGENT:Please verify your Internet Connection and Server response.");
      Alert("M-Stopping Deleting Pending Orders. Too many errors when deleting orders. Symbol:",symbolclose);
      Alert("M-URGENT:Please verify your Internet Connection and Server response.");
      return(-1);
   }      
  }//while

return(0); // exit
}// end function

//DELETEP delete pending positions
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2011-02-01 ***
*/
int DELETEP(string symbol_c, string penType) {
 if (penType=="All") {
   DeletePending(symbol_c, OP_BUYSTOP, MagicNumberLong);
   DeletePending(symbol_c, OP_SELLSTOP, MagicNumberShort);
   DeletePending(symbol_c, OP_BUYSTOP, MagicNumberLong);
   DeletePending(symbol_c, OP_SELLSTOP, MagicNumberShort);
 } else if (penType=="BUYP") {
   DeletePending(symbol_c, OP_BUYSTOP, MagicNumberLong);
   DeletePending(symbol_c, OP_BUYSTOP, MagicNumberLong);
 } else if (penType=="SELLP") {
   DeletePending(symbol_c, OP_SELLSTOP, MagicNumberShort);
   DeletePending(symbol_c, OP_SELLSTOP, MagicNumberShort);
 } else {
   Print("M-Warning: Could not delete pending orders. Order type is wrong!");
 }
 
 return(0);
}


//BUYP creates a pending order to Buy (go long)
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2011-05-01 ***
*/
int BUYP(string symbol_p, double offset_p, double lotsize_p, double takeprofit_p, double stoploss_p, int expiration_p, string condition_p) {
   PENDINGORDER(OP_BUYSTOP, symbol_p, lotsize_p, offset_p, stoploss_p, takeprofit_p, commentlong, MagicNumberLong, BuyColor, condition_p, expiration_p);
}

//SELLP creates a pending order to Sell (go short)
/*
*** Generated with Molanis Strategy Builder 3.1 ***
*** www.molanis.com ***
*** Released 2011-05-01 ***
*/
int SELLP(string symbol_p, double offset_p, double lotsize_p, double takeprofit_p, double stoploss_p, int expiration_p, string condition_p) {
   PENDINGORDER(OP_SELLSTOP, symbol_p, lotsize_p, offset_p, stoploss_p, takeprofit_p, commentshort, MagicNumberShort, SellColor, condition_p, expiration_p);
}

//----functions end
// end molanis
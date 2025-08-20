//+------------------------------------------------------------------+
//|                                                      HedgeEA.mq4 |
//|                                 Copyright © 2006, ForexForums.org|
//+------------------------------------------------------------------+

//first v  used code from (EA's by Igorad,waltini) by kokas,cturner
//v5.0 latest greatest version by kokas
//v5.1 10-23-06 added bollinger filter, micro account by cturner
//v5.2 10-24-06 added logic to catch and fix 1 of the 2 trades not being placed due to error
//v5.3 10-24-06 correlation logic built in by Nicholishen  
//v5.4 10-24-06 bug fixes on open orders by cturner
//v5.5 10-30-06 added short/long option that was missing by cturner
//v5.6 10-30-06 added Autotrade, to stop entering automatic after exit, by kokas
//v5.7 31-10-06 MM routine corrected, by kokas (fully support of micro accounts)
//v5.8 05-11-06 AutoTakeProfit as a percentage of AccountBalance() // Abandoned
//v5.9 20-11-06 eMail Notification on close orders, UsePips including Swap, AutoProfit using Bollinger
//v6.0 06-01-06 Add in Stevensign's suggestion of calcuting ratio using Pips and Range. Modify MM. BY bodshyipmonitor@forex-tsd
//v6.1 11-01-06 Corrected AutoProfit as a Function os Risk and OrderLots1 and OrderLots2
//v6.2 15-01-07 Added IsInterbankfxMini to the input parameters
//v6.3 16-01-07 Removed IsInterbankfxMini and added alerts for missing pairs on market watch. Corrected the display of correlation
//v6.4 16-01-07 Add some brackets to correct logic errors. bodshyipmonitor@forexforums
//v6.5 17-01-07 Added Global Cycle by Nicholishen
//
//
// 
//   To do List:
//   
//   - AutoRatio Include Correlation
//   - Trailling for the hedge
//    FROM Forex-TSD. 
//    1. Modify the autoration section to utilize Stevensign's suggestions. (DONE BY bodshyipmonitor@forex-tsd)
//    2. MM - implement ratio in order to keep the hedge in balance wrt to margin requirments.
//    3. Possibly add code to allow the EA to utilyze SWAP to continually open small positions.
//    4. "Fix" BB in order to allow traders to utilize this function with different currency pairs.
//    5. Learn more about how to interpret the "net P/L" between the two pairs in order to improve success potential when new trades are opened. (i.e. do we open when correlation is high or near zero? How is correlation related to this net P/L?)
//   


#property copyright "Copyright © 2006, ForexForums.org"
#property link      "http://www.forexforums.org/"

#include <stdlib.mqh>

//---- input parameters
extern string     eaname           = "[6.3]";                       // Expert Name and first part of comment line
extern int        Magic            = 1001;                          // Magic Number ( 0 - for All positions)
extern bool       Autotrade        = true;                          // Set to false to prevent an entry after an exit
extern string     Symbol1          = "GBPJPY";
extern bool       Symbol1isLong    = true;                          // Set to true to put long orders on the second pair
extern string     Symbol2          = "CHFJPY";
extern bool       Symbol2isLong    = false;                         // Set to true to put long orders on the second pair
extern string     Lotsizes         = "Set Ratio to 1 to use equal";
extern double     Lots             = 0.1;                           // Lots for first pair if MM is turned off
extern bool       UseAutoRatio     = true;
extern double     Ratio            = 1.8;                           // Ratio between the two pairs
extern double     SMA_Value_for_Range = 200;
extern string     Data             = " Input Data ";
extern bool       StopManageAcc    = false;                         // Stop of Manage Account switch(Close All Trades)
extern double     MaxLoss          = 0;                             // Maximum total loss in pips or USD 
extern string     Data2            = "Correlation Settings";
extern bool       UseCorrelation   = true;                         // Set to true if you want to use correlation as an entry signal
extern int        cPeriod          = 20;                            // If the correlation is used to check before put new Orders 
extern double     MinCorrelation   = 0.8; 
extern double     MaxCorrelation   = 1.0;
extern string     Data3            = "Bollinger Band Settings";
extern bool       UseBollinger     = false;                         // Set to true to use Bollinger bands as an entry signal
extern string     Bollinger_Symbol = "GBPCHF";
extern double     Bollinger_Period = 20;                           // Period must be in minutes
extern double     Bollinger_TF     = 60;
extern double     Bollinger_Dev    = 2;
extern string     Data4            = "SWAP Settings";               
extern bool       UseSwap          = true;                          // Select true if you want to use swap on profit calculation
extern string     Data5            = "Money Management";
       bool       AccountIsMicro   = false;                          // Set true if you use a micro account
extern double     ProfitTarget     = 50;                            // Profit target in pips or USD   
       bool       UsePips          = false;
extern bool       MoneyManagement  = true;
extern double     Risk             = 20;                            // Risk
extern bool       AutoProfit       = true;                          // When the price of Bolliner pair passes the Upper Bollinger close all trades
extern bool       EmailReport      = false;

string comment = "";
string eBody = "";
string eSubject = "";
string TradeSymbol ="";
int totalPips=0;
double  totalProfits=0;
double BandsLower = 0;
double BandsUpper = 0;
bool CloseSignal=false;
bool signal1=true;
bool signal2=true;
double valueswap = 0;
double Correlation;
double Bands;
double OrderLots1,OrderLots2;
double AccountSize;
double Total_Lots;
int ticket1=0
   ,ticket2=0
   ,Symbol1SP
   ,Symbol2SP
   ,Symbol1Mode
   ,Symbol2Mode
   ,Order1=0
   ,Order2=0
   ,c1=0
   ,c2=0
   ,Symbol1OP
   ,Symbol2OP
   ,numords=0
   ;
 string USD = "USD"; // Added so that PipCost could handle InterbankFx Mini accounts

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 

   if(Symbol1isLong){
      Symbol1OP=OP_BUY;
      Symbol1Mode=MODE_ASK;
      } else {
      Symbol1OP=OP_SELL;
      Symbol1Mode=MODE_BID;
      }
   
   if(Symbol2isLong){
      Symbol2OP=OP_BUY;
      Symbol2Mode=MODE_ASK;
      } else {
      Symbol2OP=OP_SELL;
      Symbol2Mode=MODE_BID;
      }
  
   // Check if this is an InterbankFx Mini AccountBalance
   // If so, append an "m" to the symbols
   
   if (StringLen(Symbol())== 7 )
   {
      Symbol1 = Symbol1 + "m";
      Symbol2 = Symbol2 + "m";
      Bollinger_Symbol = Bollinger_Symbol + "m";
      USD = USD + "m";
   }
   
   if (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01)
   {
     AccountIsMicro = true;
   }
   else
   {
     AccountIsMicro = false;
   }

  return(0);
  }

// ---- Scan Open Trades
int ScanOpenTrades()
{   
           
   Order1=0;Order2=0;  
   int total = OrdersTotal();
   int numords = 0;
   for(int cnt=0; cnt<=total-1; cnt++)
   {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    //if(OrderMagicNumber()==Magic)
    if(Magic > 0) if(OrderMagicNumber() == Magic) numords++;
    {
    if(OrderType()==Symbol1OP && OrderMagicNumber() == Magic && OrderSymbol()==Symbol1)Order1  += 1;
    if(OrderType()==Symbol2OP && OrderMagicNumber() == Magic && OrderSymbol()==Symbol2)Order2  += 1;
    }    
   }
 
   return(numords);
}

//+--------- --------- --------- --------- --------- --------- ----+
//+ Calculate cost in USD of 1pip of given symbol
//+--------- --------- --------- --------- --------- --------- ----+
double PipCost (string TradeSymbol) {
double Base, Cost;
string TS_13, TS_46, TS_4L;

TS_13 = StringSubstr (TradeSymbol, 0, 3);
TS_46 = StringSubstr (TradeSymbol, 3, 3);
TS_4L = StringSubstr (TradeSymbol, 3, StringLen(TradeSymbol)-3);

Base = MarketInfo (TradeSymbol, MODE_LOTSIZE) * MarketInfo (TradeSymbol, 
MODE_POINT);
if ( TS_46 == "USD" )
Cost = Base;
else if ( TS_13 == "USD" )
Cost = Base / MarketInfo (TradeSymbol, MODE_BID);
else if ( PairExists ("USD"+TS_4L) )
Cost = Base / MarketInfo ("USD"+TS_4L, MODE_BID);
else
Cost = Base * MarketInfo (TS_46+USD , MODE_BID);

return(Cost) ;
}

//+--------- --------- --------- --------- --------- --------- ----+
//+ Returns true if given symbol exists
//+--------- --------- --------- --------- --------- --------- ----+
bool PairExists (string TradeSymbol) {
return ( MarketInfo (TradeSymbol, MODE_LOTSIZE) > 0 );
}


// Generate Comment on OrderSend 
string GenerateComment(string eaname, int Magic)
{
   return (StringConcatenate(eaname, "-", Magic));
}

// Closing of Open Orders      
void OpenOrdClose()
{
    int total=OrdersTotal();
    for (int cnt=0;cnt<total;cnt++)
    { 
    OrderSelect(cnt, SELECT_BY_POS);   
    int mode=OrderType();
    bool res = false; 
    bool condition = false;
    if ( Magic>0 && OrderMagicNumber()==Magic ) condition = true;
    else if ( Magic==0 ) condition = true;
      if (condition && ( mode==OP_BUY || mode==OP_SELL ))
      { 
         if (EmailReport) SendMail(eSubject,eBody);
// - BUY Orders         
         if(mode==OP_BUY)
         {  
         res = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,Yellow);
            if( !res )
            {
            Print(" BUY: OrderClose failed with error #",GetLastError());
            Print(" Ticket=",OrderTicket());
            Sleep(3000);
            }
         break;
         }
         else     
// - SELL Orders          
         if( mode == OP_SELL)
         {
         res = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,White);
                
            if( !res )
            {
            Print(" SELL: OrderClose failed with error #",GetLastError());
            Print(" Ticket=",OrderTicket());
            Sleep(3000);
            }
         break;    
         }  
      }                  
   }
}

void TotalProfit()
{
   int total=OrdersTotal();
   totalPips = 0;
   totalProfits = 0;
   for (int cnt=0;cnt<total;cnt++)
   { 
   OrderSelect(cnt, SELECT_BY_POS);   
   int mode=OrderType();
   bool condition = false;
   if ( Magic>0 && OrderMagicNumber()==Magic ) condition = true;
   else if ( Magic==0 ) condition = true;   
      if (condition)
      {               
         switch (mode)
         {
         case OP_BUY:
            totalPips += MathRound((MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT));
            //totalPips += MathRound((Bid-OrderOpenPrice())/Point);
            totalProfits += OrderProfit();
            break;
            
         case OP_SELL:
            totalPips += MathRound((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK))/MarketInfo(OrderSymbol(),MODE_POINT));
            //totalPips += MathRound((OrderOpenPrice()-Ask)/Point);
            totalProfits += OrderProfit();
            break;
         }
      }            
	}
}

void SwapProfit()
{
   int total=OrdersTotal();
   valueswap = 0;
   for (int cnt=0;cnt<total;cnt++)
   { 
   OrderSelect(cnt, SELECT_BY_POS);   
   int mode=OrderType();
   bool condition = false;
   if ( Magic>0 && OrderMagicNumber()==Magic ) condition = true;
   else if ( Magic==0 ) condition = true;   
      if (condition)
      {      
      if (UsePips){
      valueswap = valueswap + OrderSwap()/PipCost(OrderSymbol());
      } else {
      valueswap = valueswap + OrderSwap();      
      }   
      }            
	}
}

void ChartComment()
{
   string sComment   = "";
   string sp         = "****************************\n";
   string NL         = "\n";

   sComment = sp;
   sComment = sComment + "Open Positions      = " + ScanOpenTrades() + NL;
   sComment = sComment + "Current Ratio       = " + DoubleToStr(Ratio,2) + NL;
  //Add in by bodshyipmonitor@forex-tsd to show the lots. Will only show when there are no trades open. :)
   if (OrdersTotal()<1){
      sComment = sComment + "Total Lots :     = " + Total_Lots + NL;
      sComment = sComment + Symbol1+ " Lots :       = " + DoubleToStr(OrderLots1,AccountSize) + NL;
      sComment = sComment + Symbol2+ " Lots :       = " + DoubleToStr(OrderLots2,AccountSize) + NL;
      sComment = sComment + NL;
   }
   
   if (UsePips) {
     sComment = sComment + "Current Profit(Pip)= " + totalPips + NL;
   } else {
     sComment = sComment + "Current Profit(USD) = " + DoubleToStr(totalProfits,2) + NL + NL; 
   }
   if(UseCorrelation){sComment = sComment + "Correlation              = " + DoubleToStr(Correlation*100,2) +" %"+ NL + NL;}
   if(UseBollinger){sComment = sComment + "Bollinger Middle           = " + DoubleToStr(Bands,4) + NL;} 
   if(UseBollinger){sComment = sComment + "Bollinger Pair Price       = " + DoubleToStr(MarketInfo(Bollinger_Symbol,MODE_ASK),4) + NL + NL;}

   if(UseSwap){
     if (UsePips) {
         sComment = sComment + "SWAP Value (Pip)   = " + DoubleToStr(valueswap,2) + NL;
     } else {
         sComment = sComment + "SWAP Value (USD)   = " + DoubleToStr(valueswap,2) + NL;
     }
       }
   if (UsePips) {
     sComment = NL + sComment + "Net Value (Pip)      = " + DoubleToStr(totalPips+valueswap,2) + NL;
   } else {
     sComment = NL + sComment + "Net Value (USD)      = " + DoubleToStr(totalProfits+valueswap,2) + NL;
   }
   sComment = NL + sComment + "Profit Target         = " + DoubleToStr(ProfitTarget,0) + NL;
   //sComment = sComment + "Account Leverage 1:" + AccountLeverage() + NL;
   sComment = sComment + NL + sp;

   eSubject = "Hedge Profit:" + DoubleToStr(totalProfits+valueswap,2);
   eBody    = "HedgeEA Report" + NL + sComment;
   
   Comment(sComment);
}	  

double CorrelationIND(string Symbol1,string Symbol2,int CorrelationShift=0){
   double Correlation[],DiffBuffer1[],DiffBuffer2[],PowDiff1[],PowDiff2[];
   ArrayResize(Correlation,cPeriod*2);ArrayResize(DiffBuffer1,cPeriod*2);
   ArrayResize(DiffBuffer2,cPeriod*2);ArrayResize(PowDiff1,cPeriod*2);ArrayResize(PowDiff2,cPeriod*2);
   for( int shift=cPeriod+1; shift>=0; shift--){
      DiffBuffer1[shift]=iClose(Symbol1,0,shift)-iMA(Symbol1,0,cPeriod,0,MODE_SMA,PRICE_CLOSE,shift);
      DiffBuffer2[shift]=iClose(Symbol2,0,shift)-iMA(Symbol2,0,cPeriod,0,MODE_SMA,PRICE_CLOSE,shift);
      PowDiff1[shift]=MathPow(DiffBuffer1[shift],2);
      PowDiff2[shift]=MathPow(DiffBuffer2[shift],2);
      double u=0,l=0,s=0;
      for( int i = cPeriod-1 ;i >= 0 ;i--){
         u += DiffBuffer1[shift+i]*DiffBuffer2[shift+i];
         l += PowDiff1[shift+i];
         s += PowDiff2[shift+i];
      }
      if(l*s >0)Correlation[shift]=u/MathSqrt(l*s);
   }   
   return(Correlation[CorrelationShift]);
   return(-1); 
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
   while(true)
   {
      RefreshRates();
      MainTradingMethod();
      Sleep(200);
   }
   return(0);
 
}//int start
//+------------------------------------------------------------------+


int MainTradingMethod(){

  if (MarketInfo(Symbol1,Symbol1Mode)== 0) {
     Alert("Please enable all pairs on Market Watch Window");
     return(0);
     }
  if (MarketInfo(Symbol2,Symbol2Mode)== 0) {
     Alert("Please enable all pairs on Market Watch Window");
     return(0);
     }

    Correlation= CorrelationIND(Symbol1,Symbol2,0);

//  added Bollinger Filter

//  Bands=iCustom(Bollinger_Symbol,Bollinger_Period,"Bands",20,0,2,0,0,0);                // Old Bollinger
  
    BandsLower = iBands(Bollinger_Symbol,Bollinger_TF,Bollinger_Period,Bollinger_Dev,0,0,2,0);          // Lower  Bollinger
    BandsUpper = iBands(Bollinger_Symbol,Bollinger_TF,Bollinger_Period,Bollinger_Dev,0,0,1,0);          // Upper  Bollinger
    Bands = (BandsLower + BandsUpper) / 2;                                                              // Middle Bollinger

   if(ScanOpenTrades()==0) { CloseSignal=false; Order1=0; Order2=0; } //Add Brackets by bodshyipmonitor
   if(ScanOpenTrades()==2) { Order1=1; Order2=1; } //Add Brackets by bodshyipmonitor
   
     TotalProfit();
     SwapProfit();



if (UseAutoRatio) {

     double PipRatio = PipCost(Symbol1) / PipCost(Symbol2);
     
     //Modify by bodshyipmonitor@forex-tsd. Calculate Ratio with range as well.
     //double iMA(  	string symbol, int timeframe, int period, int ma_shift, int ma_method, int applied_price, int shift)
     double Symbol1_Range= (iMA(Symbol1,0,SMA_Value_for_Range,0,MODE_SMA,PRICE_HIGH,0)-iMA(Symbol1,0,SMA_Value_for_Range,0,MODE_SMA,PRICE_LOW,0))/MarketInfo(Symbol1,MODE_POINT);
     double Symbol2_Range= (iMA(Symbol2,0,SMA_Value_for_Range,0,MODE_SMA,PRICE_HIGH,0)-iMA(Symbol2,0,SMA_Value_for_Range,0,MODE_SMA,PRICE_LOW,0))/MarketInfo(Symbol2,MODE_POINT);
     double RangeRatio = Symbol2_Range / Symbol1_Range;
     
      Ratio = PipRatio / RangeRatio; 
     }


   ChartComment();

   if (UseSwap) {
     if (UsePips) {
         totalProfits = totalPips + valueswap;
     } else {
         totalProfits = totalProfits + valueswap;
     }
     }

   if (AutoProfit) ProfitTarget = NormalizeDouble(((OrderLots1 * PipCost(Symbol1) + OrderLots2 * PipCost(Symbol2))/2) * Risk,0);
      
    

   if (!StopManageAcc)
   {
      if(ScanOpenTrades() > 0 && !CloseSignal && (ProfitTarget>0 || MaxLoss>0))
      {
        if(ProfitTarget > 0 && totalProfits>=ProfitTarget) CloseSignal=true;
        if(MaxLoss > 0 && totalProfits <= -MaxLoss) CloseSignal=true;
 
      }   
   }
   else 
   { if (ScanOpenTrades() > 0) CloseSignal=true;}    
   
   if( CloseSignal ) OpenOrdClose();

// Prepare Comment line for the trades

     if(Symbol1isLong) {
     comment = Symbol1 + "_L/"; 
     } else {
     comment = Symbol1 + "_S/";
     }
     if(Symbol2isLong) {
     comment = comment + "L_" + Symbol2;
     } else {
     comment = comment +"S_" + Symbol2;
     }
     
     comment = comment + " " + GenerateComment(eaname, Magic);
     
// Micro or Mini



     if(AccountIsMicro)  {
     
     AccountSize=2;
     
     } else {
     
     AccountSize=1;
     
     }        

// added MM statement





     if(MoneyManagement) {

       Total_Lots=AccountFreeMargin()*Risk*0.01 *AccountLeverage()/MarketInfo(Symbol(),MODE_LOTSIZE);
       OrderLots1 = NormalizeDouble(Total_Lots/(1+Ratio),AccountSize);
       OrderLots2 = NormalizeDouble(Total_Lots/(1+Ratio)*Ratio,AccountSize); 
       
     } else {
     
     OrderLots1 = Lots;
     OrderLots2 = NormalizeDouble(Lots * Ratio,AccountSize); //change 2 to 1 for mini account
   
     }
      
     
// Added signal1 that will store correlation logic if used 
     
     if(UseCorrelation) {
        if(Correlation < MaxCorrelation && Correlation > MinCorrelation) {
            signal1 = true;
        } else {
            signal1 = false;
        }
     }
     else signal1 = true; 
     
// Added signal2 that will store bollinger logic if used 
     
     if(UseBollinger) {
        if(MarketInfo(Bollinger_Symbol,MODE_ASK) < Bands) {
            signal2 = true;
        } else {
            signal2 = false;
        }
     } 
     else signal2 = true;    
     
  
// Place Orders
     
     if(!StopManageAcc && signal1 && signal2 && Autotrade && !CloseSignal){

      CloseSignal=false;
      
      // Order1
      
      if (Order1==0) {
      OrderSend(Symbol1,Symbol1OP,OrderLots1,MarketInfo(Symbol1,Symbol1Mode),13,0,0,comment,Magic,0,Blue); 
      if(GetLastError()>1) Print("ERRO:",GetLastError());
      if (GetLastError()==0) {Order1=1;}
      }
            
      // Order2
      
      if (Order2==0) {
      OrderSend(Symbol2,Symbol2OP,OrderLots2,MarketInfo(Symbol2,Symbol2Mode),13,0,0,comment,Magic,0,Blue);
      if(GetLastError()>1) Print("ERRO:",GetLastError());
      if (GetLastError()==0) {Order2=1;}
      }
      
      }
      

 return(0);
 
}
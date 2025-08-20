//+------------------------------------------------------------------+
//|                                      SMC Autotrader Momentum.mq4 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

 extern double TakeProfit = 50;
 extern double Lots =0.5;
 extern double InitialStop = 30;
 extern double TrailingStop = 50;
 extern int MACDMA1=12;
 extern int MACDMA2=26;
 extern int MACDMA3=9;
 extern double ATR_X=1.5;
 datetime BarTime;

//#####################################################################
int init()
{
//---- 
GlobalVariableSet("Bartime",0);

//----
   return(0);
  }
//#####################################################################

int start()
  {
   int cnt,total,ticket,MinDist,tmp;
   double Spread;
   datetime OpenBarTime = 0;
   double ATR;
   double StopMA;
   double SetupHigh, SetupLow;
   
   double MACD_Value;
   double MACDSP2, MACDSP1;
   double MACDMAP2, MACDMAP1;
   double OsMAP1;
   string CurrDay;
   double Trend;
//############################################################################
  if(Bars<100){
     Print("bars less than 100");
     return(0);  
  }

//exit if not new bar
if(BarTime == Time[0]) {return(0);}

//new bar, update bartime
BarTime = Time[0];

//#########################################################################################
//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 ATR =iATR(NULL,0,10,0); // BE CAREFUL OF EFFECTING THE AUTO TRAIL STOPS
 Trend=iMA(NULL,0,24,0,MODE_SMA,PRICE_CLOSE,0);
 StopMA=iMA(NULL,0,24,0,MODE_SMA,PRICE_CLOSE,0);
 MinDist=MarketInfo(Symbol(),MODE_STOPLEVEL);
 Spread=(Ask-Bid);
 CurrDay = Day();
//#########################################################################################
 OsMAP1 = iOsMA(NULL,PERIOD_W1,10,20,7,PRICE_CLOSE,1);

 MACDSP1 = iMACD(NULL,0,MACDMA1,MACDMA2,MACDMA3,PRICE_CLOSE,MODE_SIGNAL,1);
 MACDSP2 = iMACD(NULL,0,MACDMA1,MACDMA2,MACDMA3,PRICE_CLOSE,MODE_SIGNAL,2);
 
 
// Calculate MA of Histogram not signal line
 MACD_Value=0;
 for(cnt=1;cnt<7;cnt++)
 {MACD_Value = MACD_Value + iMACD(NULL,0,MACDMA1,MACDMA2,MACDMA3,PRICE_CLOSE,MODE_MAIN,cnt);}
  MACDMAP1 = MACD_Value/6;
  
 MACD_Value=0;
 for(cnt=1;cnt<7;cnt++)
 {MACD_Value = MACD_Value + iMACD(NULL,0,MACDMA1,MACDMA2,MACDMA3,PRICE_CLOSE,MODE_MAIN,cnt+1);}
  MACDMAP2 = MACD_Value/6;
//########################################################################################
//##################     ORDER CLOSURE  ###################################################
// If Orders are in force then check for closure against Technicals LONG & SHORT
//CLOSE LONG Entries
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
   {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
     {
     if(MACDMAP2 > MACDSP2 && MACDMAP1 <  MACDSP1)
      {                                 
       OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close LONG position
     }}

//CLOSE SHORT ENTRIES: 
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
    if(OrderType()==OP_SELL && OrderSymbol()==Symbol()) // check for symbol
     {
     if(MACDMAP2 < MACDSP2 && MACDMAP1 > MACDSP1)
      {   
       OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
     }}
    }  // for loop return
    }   // close 1st if 
//##############################################################################
//##################     ORDER TRAILING STOP Adjustment  #######################
//TRAILING STOP: LONG
if(0==0)
 {
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_BUY && OrderSymbol()==Symbol()
     &&
     Bid-OrderOpenPrice()> (ATR*ATR_X)
     &&
     OrderStopLoss() < Bid-(ATR*ATR_X)
     )
     {OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(ATR*ATR_X),OrderTakeProfit(),0,White);
           return(0);}
 }}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//TRAILING STOP: SHORT
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_SELL && OrderSymbol()==Symbol()
     &&
     OrderOpenPrice()-Ask > (ATR*ATR_X)
     &&
     OrderStopLoss() > Ask+(ATR*ATR_X)   // OrderStopLoss must be > OpOrdPrice
     )
     {OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(ATR*ATR_X),OrderTakeProfit(),0,Yellow);
          return(0);}
 }}
}  // end bracket for on/off switch
//##########################################################################################
//~~~~~~~~~~~ END OF ORDER Closure routines & Stoploss changes  ~~~~~~~~~~~~~~~~~~~~~~~~~~~
//##########################################################################################
//~~~~~~~~~~~~START of NEW ORDERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#########################  NEW POSITIONS ?  ######################################
//Possibly add in timer to stop multiple entries within Period
// Check Margin available
// ONLY ONE ORDER per SYMBOL
// Loop around orders to check symbol doesn't appear more than once
// Check for elapsed time from last entry to stop multiple entries on same bar
//string OCDay = TimeDay(OrderCloseTime());if (0==0) // switch to turn ON/OFF history check
//Print("CurrDay ",CurrDay,"OCDay ",OCDay);
//if(0==1)
//{  
// total=HistoryTotal();
// if(total>0)
//  { 
///   for(cnt=0;cnt<total;cnt++)
//    {
//     OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
//           //Needs to be next day not as below
//     
//     if(OrderSymbol()==Symbol()
//        &&
//        CurrDay <= OCDay)
//      {
//       return(0);}
// }}}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 total=OrdersTotal();
  if(total>0)
   { 
    for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderSymbol()==Symbol()) return(0);
   }
   }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   if(AccountFreeMargin()<(1000*Lots))
   {Print("We have no money. Free Margin = ", AccountFreeMargin());
    return(0);}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#########################################################################################
//ENTRY RULES: LONG   SL=
 if(MACDMAP2 < MACDSP2 && MACDMAP1 > MACDSP1
    &&
    Close[0] > Trend)  
  {
   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-(ATR*2),0,"MaxMin Long",16384,0,Orange); //Bid-(Point*(MinDist+2))
   Print (OpenBarTime);
   if(ticket>0)
    {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
     }
     else Print("Error opening BUY order : ",GetLastError()); 
   } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ENTRY RULES: SHORT   SL=                                 
 if(MACDMAP2 > MACDSP2 && MACDMAP1 < MACDSP1
    && 
    Close[0] < Trend)
  {
   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+(ATR*2),0,"MaxMin Short",16384,0,Red);
   if(ticket>0)
    {
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
      }
      else Print("Error opening SELL order : ",GetLastError()); 
   }

//####################################################################################
//############               End of PROGRAM                  #########################   
   return(0);
}


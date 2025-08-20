//+------------------------------------------------------------------+
//|                                      SMC Autotrader Momentum.mq4 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+ usd / JPY
 extern double TakeProfit = 10;
 extern double Lots = 1.0;
 extern double InitialStop = 10;
 extern double TrailingStop = 65;
datetime BarTime;

//#####################################################################
int init()
{
//---- 
//----
   return(0);
  }
//#####################################################################

int start()
  {
   int cnt,total,ticket,MinDist,tmp;
   double Spread;
   double ATR;
   double StopMA;
   double SetupHigh, SetupLow;
   
 
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
 StopMA=iMA(NULL,0,24,0,MODE_SMA,PRICE_CLOSE,0);
 MinDist=MarketInfo(Symbol(),MODE_STOPLEVEL);
 Spread=(Ask-Bid);
//#########################################################################################
 double MA1P1,MA1P2,MA2P1,MA2P2;
 MA1P1= iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,1);
 MA1P2= iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,2);
 MA2P1= iMA(NULL,0,8,0,MODE_EMA,PRICE_CLOSE,1);
 MA2P2= iMA(NULL,0,8,0,MODE_EMA,PRICE_CLOSE,2);

 int MACDMA1,MACDMA2,MACDMA3;
 MACDMA1=12;
 MACDMA2=26;
 MACDMA3=9;
 double MACDP1,MACDP2,MACDSP1,MACDSP2;
 MACDP1  = iMACD(NULL,0,MACDMA1,MACDMA2,MACDMA3,PRICE_CLOSE,MODE_MAIN,1);
 MACDP2  = iMACD(NULL,0,MACDMA1,MACDMA2,MACDMA3,PRICE_CLOSE,MODE_MAIN,2);
 MACDSP1 = iMACD(NULL,0,MACDMA1,MACDMA2,MACDMA3,PRICE_CLOSE,MODE_SIGNAL,1);
 MACDSP2 = iMACD(NULL,0,MACDMA1,MACDMA2,MACDMA3,PRICE_CLOSE,MODE_SIGNAL,2);

 double RSIvalP1,RSIvalP2;
 RSIvalP1 = iRSI(NULL,0,12,PRICE_CLOSE,1);
 RSIvalP2 = iRSI(NULL,0,12,PRICE_CLOSE,2);
 
 double CCIM1,CCIM2;
 CCIM1 = iCCI(NULL,0,100,PRICE_CLOSE,1);
 CCIM2 = iCCI(NULL,0,-100,PRICE_CLOSE,2);

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
     if(MA2P1 > MA1P1)
      {                                 
       OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close LONG position
     }}

//CLOSE SHORT ENTRIES: 
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
    if(OrderType()==OP_SELL && OrderSymbol()==Symbol()) // check for symbol
     {
     if(MA1P1 > MA2P1)
      {   
       OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
     }}
    }  // for loop return
    }   // close 1st if 
//##############################################################################
//~~~~~~~~~~~ END OF ORDER Closure routines & Stoploss changes  ~~~~~~~~~~~~~~~~~~~~~~~~~~~
//##########################################################################################
//~~~~~~~~~~~~START of NEW ORDERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//TRAILING STOP: LONG
if(0==0)  //This is used to turn the trailing stop on & off
 {
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_BUY && OrderSymbol()==Symbol()
     &&
     Bid-OrderOpenPrice()> (Point*TrailingStop)
     &&
     OrderStopLoss()<Bid-(Point*TrailingStop)
     )
     {OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,White);
           return(0);}
 }}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//TRAILING STOP: SHORT
if(0==0) //this is used to urn the trailing top on & off
{  
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_SELL && OrderSymbol()==Symbol()
     &&
     OrderOpenPrice()-Ask > (Point*TrailingStop)
     &&
     OrderStopLoss() > Ask+(Point*TrailingStop) 
     )
     {OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(Point*TrailingStop),OrderTakeProfit(),0,Yellow);
          return(0);}
 }}
}  // end bracket for on/off switch
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#########################  NEW POSITIONS ?  ######################################
//Possibly add in timer to stop multiple entries within Period
// Check Margin available
// ONLY ONE ORDER per SYMBOL
// Loop around orders to check symbol doesn't appear more than once
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
//ENTRY RULES: LONG 
 if(MA1P1 > MA2P1 && MA1P2 > MA2P2 
    &&
    RSIvalP1 > 50
    &&
    MACDP1 > MACDSP1
    )
  {
   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MaxMin Long",16384,0,Orange); //Bid-(Point*(MinDist+2))
   if(ticket>0)
    {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
     }
     else Print("Error opening BUY order : ",GetLastError()); 
     return(0); 
   } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ENTRY RULES: SHORT                                     //################################
 if(MA1P1 > MA2P1 && MA1P2 > MA2P2 
    &&
    RSIvalP1 < 50
    &&
    MACDP1 < MACDSP1
    )
  {
   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"MaxMin Short",16384,0,Red);
   if(ticket>0)
    {
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
      }
      else Print("Error opening SELL order : ",GetLastError()); 
      return(0); 
   }

//####################################################################################
//############               End of PROGRAM                  #########################   
   return(0);
}}


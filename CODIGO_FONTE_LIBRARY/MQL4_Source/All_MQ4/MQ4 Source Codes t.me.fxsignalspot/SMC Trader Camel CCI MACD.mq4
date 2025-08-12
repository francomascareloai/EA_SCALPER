//+------------------------------------------------------------------+
//|                         Steve Cartwright Trader Camel CCI MACD.mq4 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

 extern double TakeProfit = 50;
 extern double Lots = 1;
 extern double InitialStop = 10;
 extern double TrailingStop = 10;
 
 int cnt,total,ticket,MinDist;
 int SigPos;
 double MACDSP1, MACDSP2;
 double MACDHP1, MACDHP2;
 double CCIP1;
 double MASP1, MASP2;
 double CAMELHIGHP1, CAMELHIGHP2, CAMELLOWP1, CAMELLOWP2;
 
 
//#####################################################################
int init()
{
//----
GlobalVariableSet("CCI_Flag",0);
GlobalVariableSet("MACD_Flag",0);
GlobalVariableSet("MAX_Flag",0);

 
//----
   return(0);
  }
//#####################################################################

int start()
  {

   int Flag;
   
   double Spread;
   double ATR;
   double StopMA;
   int cnt, tmp;
   double SetupHigh, SetupLow;
//############################################################################
  if(Bars<100){
     Print("bars less than 100");
     return(0);  
  }
  if(TakeProfit<10){
     Print("TakeProfit less than 10");
     return(0);  // check TakeProfit
  }
//#########################################################################################
//~~~~~~~~~~~~~~~~Indicator Setup~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
MASP1=iMA(NULL,0,3,0,MODE_SMA,PRICE_CLOSE,1);
MASP2=iMA(NULL,0,3,0,MODE_SMA,PRICE_CLOSE,2);

CAMELHIGHP1=iMA(NULL,0,34,0,MODE_EMA,PRICE_HIGH,1);
CAMELLOWP1=iMA(NULL,0,34,0,MODE_EMA,PRICE_LOW,1);


MACDSP1=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
MACDSP2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2);

MACDHP1=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
MACDHP2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);

CCIP1=iCCI(NULL,0,20,PRICE_CLOSE,1);



//~~~~~~~~~~~~~~~~Indicator Signal calcs~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ADD in a reset routine  what conditions will reset values to zero??

//if(GlobalVariableGet("MAX_Flag")==0
//   && MASP2 < CAMELHIGHP2
//   && MASP1 > CAMELHIGHP1)
//  {GlobalVariableSet("MAX_Flag",1);}  // Flag 1 = LONG 2 = SHORT

//if(GlobalVariableGet("CCI_Flag")==0
//   && CCIP1 >100)
//   {GlobalVariableSet("CCI_Flag",1);}  

//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//TrailingStop=iATR(NULL,0,10,0)*2; // BE CAREFUL OF EFFECTING THE AUTO TRAIL STOPS
 StopMA=iMA(NULL,0,24,0,MODE_SMA,PRICE_CLOSE,1);
 MinDist=MarketInfo(Symbol(),MODE_STOPLEVEL);
 Spread=(Ask-Bid);
//#########################################################################################
//ALWAYS TRY TO COME OUT WITH A PROFIT:  ????????
 if(0==1)
 {
 total=OrdersTotal();
 if (total>0)
  {
  for(cnt=0;cnt<total;cnt++)
   {  
//LONG
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
      {
       if(OrderStopLoss() < OrderOpenPrice())
      {
       if (OrderStopLoss() < Bid -(Point*(MinDist*2)))
       {
        OrderModify(OrderTicket(),OrderOpenPrice(),Bid -(Point*(2*MinDist)),OrderTakeProfit(),0,Lime);
        }}}
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SHORT
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
      {
       if(OrderStopLoss() > OrderOpenPrice())
        {
         if (OrderStopLoss() > Ask + (Point*(MinDist*2)))
        {
         OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(Point*(MinDist*2)),OrderTakeProfit(),0,Lime);
        }}}
    }}
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
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//##   LONG Closure Rules   ###
 {
  if(MACDHP1 < MACDSP1)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   {                                 
    OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close LONG position
    }}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//CLOSE SHORT ENTRIES: 
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol()) // check for symbol
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//##  SHORT Closure Rules  ##
 {
  if(MACDHP1 > MACDSP1)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   {   
    OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
     }}
  }  // for loop return
 }   // close 1st if 
//##############################################################################
//##################     ORDER TRAILING STOP Adjustment  #######################
//TRAILING STOP: LONG
if(0==1)
{
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
      {
       if(TrailingStop>0)  
        {                 
         if(Bid-OrderOpenPrice()>Point*TrailingStop)
          {
           if(OrderStopLoss()<Bid-Point*TrailingStop)
            {
             OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,White);
             return(0);
 }}}}}}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//TRAILING STOP: SHORT
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
      {
       if(TrailingStop>0)  
        {                 
         if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
          {
           if(OrderStopLoss()>Ask+(Point*TrailingStop)) 
            {
             OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(Point*TrailingStop),OrderTakeProfit(),0,Yellow);
             return(0);
 }}}}}}
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
if (0==0) // switch to turn ON/OFF history check
{  
  total=HistoryTotal();
  if(total>0)
   { 
    for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
       if(OrderSymbol()==Symbol()
       && CurTime()- OrderCloseTime() < (Period() * 60 )
       )
        {
        return(0);
 }}}}
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
 if(CCIP1 > 140 
    &&
    MACDHP1 > 0
    &&
    Close[1] > CAMELHIGHP1
     )                                             //High[1] > High[2] && Low[1] > Low[2])
  {
   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"MaxMin Long",16384,0,Orange); //Bid-(Point*(MinDist+2))
   Alert("Order opened for: ",Symbol());
   if(ticket>0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
        }
      else Print("Error opening BUY order : ",GetLastError()); 
      return(0); 
   } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ENTRY RULES: SHORT                                     //################################
 if(0==1&&
    CCIP1 < 100 
    &&
    MACDSP1 < 0
    &&
    Close[1] < CAMELLOWP1)                        //Low[1] < Low[2] && High[1] < High[2])
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
}


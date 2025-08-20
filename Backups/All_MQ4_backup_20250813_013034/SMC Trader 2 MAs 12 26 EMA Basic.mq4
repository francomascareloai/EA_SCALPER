//+------------------------------------------------------------------+
//|                                      SMC Autotrader Momentum.mq4 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

 extern double TakeProfit = 50;
 extern double Lots = 0.1;
 extern double InitialStop = 30;
 extern double TrailingStop = 20;
 
 datetime BarTime;

//#####################################################################
int init()
{
//----
ObjectCreate("Trend", OBJ_TREND, 0, CurTime()-(Period()*60*30), Close[10],CurTime(),Close[10]);
ObjectSet("Trend",6,Gold);
ObjectSet("Trend",7,STYLE_SOLID);
ObjectSet("Trend",10,0);
ObjectSetText("Trend","Manual Trend");
//----
   return(0);
  }
//#####################################################################

int start()
  {
   int cnt,total,ticket,MinDist,tmp;
   double Spread, SL;
   bool Buy;
   bool Sell;
   bool CloseLong;
   bool CloseShort;
//############################################################################
  if(Bars<100){
     Print("bars less than 100");
     return(0);  
  }
//exit if not new bar
// if(BarTime == Time[0]) {return(0);}
//new bar, update bartime
// BarTime = Time[0];
//######################################################################################## 
 
  double OpenTrendValm1 = ObjectGetValueByShift("Trend",1);
  double OpenTrendValm2 = ObjectGetValueByShift("Trend",2);
  if(OpenTrendValm1 != 0 && OpenTrendValm2 != 0)
  {ObjectMove("Trend",1,Time[0],OpenTrendValm1+(OpenTrendValm1-OpenTrendValm2));}
//#########################################################################################
//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 MinDist=MarketInfo(Symbol(),MODE_STOPLEVEL);
 Spread=(Ask-Bid);
//#########################################################################################
double SMAP1,SMAP2,MMAP1,MMAP2,LMA1P1,LMA1P2,LMA2P1,LMA2P2;

 int SMAVal = 12;
 int MMAVal = 26;
 int LMA1Val = 40;  //Determine Trend
 int LMA2Val = 60;

SMAP1=iMA(NULL,0,SMAVal,0,MODE_EMA,PRICE_CLOSE,1);
SMAP2=iMA(NULL,0,SMAVal,0,MODE_EMA,PRICE_CLOSE,2);
MMAP1=iMA(NULL,0,MMAVal,0,MODE_EMA,PRICE_CLOSE,1);
MMAP2=iMA(NULL,0,MMAVal,0,MODE_EMA,PRICE_CLOSE,2);
/*LMA1P1=iMA(NULL,0,LMA1Val,0,MODE_EMA,PRICE_CLOSE,1);
LMA1P2=iMA(NULL,0,LMA1Val,0,MODE_EMA,PRICE_CLOSE,2);
LMA2P1=iMA(NULL,0,LMA2Val,0,MODE_EMA,PRICE_CLOSE,1);
LMA2P2=iMA(NULL,0,LMA2Val,0,MODE_EMA,PRICE_CLOSE,2);
*/

//#######################################################################################
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~OPEN & CLOSE settings~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Buy= false;
Sell=false;
if(SMAP2 < MMAP2 && SMAP1 > MMAP1 
   ) 
   {Buy=true;}
   
if(SMAP2 > MMAP2 && SMAP1 < MMAP1 
   )
   {Sell=true;}
   
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CloseLong=false;
if(SMAP2 > MMAP2 && SMAP1 < MMAP1) CloseLong = true;

CloseShort=false;
if(SMAP2 < MMAP2 && SMAP1 > MMAP1) CloseShort = true;

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
     if(CloseLong == true)
      {SendMail("EA Message Long Order Closed ",Symbol() + " " +Bid);                                 
       OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close LONG position
     }}

//CLOSE SHORT ENTRIES: 
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
    if(OrderType()==OP_SELL && OrderSymbol()==Symbol()) // check for symbol
     {
     if(CloseShort == true)
      {SendMail("EA Message Short Order Closed ",Symbol() + " " +Ask);   
       OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
     }}
    }  // for loop return
    }   // close 1st if 
//##############################################################################
//##################     ORDER TRAILING STOP Adjustment  #######################
//TRAILING STOP: LONG
if(0==0)  //This is used to turn the trailing stop on & off
 {
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
      {
      SL = OrderStopLoss();
      if(Bid > OrderOpenPrice() + (5*Point)) SL= OrderOpenPrice();
      if(Bid > OrderOpenPrice() + (15*Point)) SL= OrderOpenPrice()+(10*Point);
      if(Bid > OrderOpenPrice() + (20*Point)) SL= OrderOpenPrice()+(15*Point);
      if(Bid > OrderOpenPrice() + (25*Point)) SL= OrderOpenPrice()+(20*Point);
      
      if(SL > OrderStopLoss())
      {OrderModify(OrderTicket(),OrderOpenPrice(),Low[2],OrderTakeProfit(),0,White);
       return(0);}
    }}}
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
     SL = OrderStopLoss();
     if(Ask < OrderOpenPrice() - (5*Point)) SL= OrderOpenPrice();
     if(Ask < OrderOpenPrice() - (15*Point)) SL= OrderOpenPrice()-(10*Point);
     if(Ask < OrderOpenPrice() - (20*Point)) SL= OrderOpenPrice()-(15*Point);
     if(Ask < OrderOpenPrice() - (25*Point)) SL= OrderOpenPrice()-(20*Point);
     
     if(SL > OrderStopLoss())
     {OrderModify(OrderTicket(),OrderOpenPrice(),High[2],OrderTakeProfit(),0,Yellow);
     return(0);}
 }}}
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
if (0==1) // switch to turn ON/OFF history check
{  
 total=HistoryTotal();
 if(total>0)
  { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);            
     if(OrderSymbol()==Symbol()&& 
        CurTime()- OrderCloseTime() + OrderCloseTime()- Time[0] > Period()*60
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
 if(Buy==true)
  {
   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"2EMA's Long",16384,0,Orange); //Bid-(Point*(MinDist+2))
   if(ticket>0)
    {SendMail("EA Message Long Order Opened ",Symbol() + " " +Ask
    Alert(" Message");
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
     }
     else Print("Error opening BUY order : ",GetLastError()); 
     return(0); 
   } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ENTRY RULES: SHORT                                     //################################
 if(Sell==true)
  {
   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"2EMA's Short",16384,0,Red);
   if(ticket>0)
    {SendMail("EA Message Short Order Opened ",Symbol() + " " +Bid);
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
      }
      else Print("Error opening SELL order : ",GetLastError()); 
      return(0); 
   }

//####################################################################################
//############               End of PROGRAM                  #########################   
   return(0);
}


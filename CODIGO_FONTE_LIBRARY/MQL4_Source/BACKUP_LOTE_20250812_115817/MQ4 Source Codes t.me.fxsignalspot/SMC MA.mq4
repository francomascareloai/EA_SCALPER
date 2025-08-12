//+------------------------------------------------------------------+
//|                                                           SMC.mq4 
//|              inspired by my own efforts
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

 extern double Lots = 0.1;
 extern double RiskPercent = 1;
 
 extern double TakeProfit = 50;
 extern double LockProfit = 2;
 extern double InitialStop = 30;
 extern double TrailingStop = 25;
 extern int    PP1=50;
 extern int    PP2=100;
 extern int    PP3=150;
 extern int    PP4=200;
 extern int    PV1=50;
 extern int    PV2=100;



 extern int TrendTimescale= 1440; // daily in minutes
 extern int TrendLongMA = 70;
 extern int TrendMediumMA = 45;
 
 extern int SignalSMA=12;
 extern int SignalMMA=45;
 extern int SignalLMA=70;
 
 datetime BarTime;
 int cnt,tmp;
//#####################################################################
int init()
{
//----
//ObjectCreate("Trend",21,1,Time[5],75);
//ObjectSetText("Trend","NONE");
//----
   return(0);
  }
//#############################################################################

int start()
  {
   double SL;
   double Spread, ATR, MinDist;
   double MaxRisk;

   double HighVal, LowVal;  //Breakout Prices

   bool   CloseLongs,CloseShorts;
   bool   Buy,Sell;
   bool   BuyZone, SellZone;

   int    total,ticket,err,tmp;
   int    NumberofPositions;
   
   string MaxRiskStr;
   datetime tmpstring;
   
//##############Alternative Strategy  MA's####################################
   double DLMAP1,DLMAP2,DMMAP1,DMMAP2;
   double LMAP1,LMAP2,MMAP1,MMAP2,SMAP1,SMAP2;
      
   
   
//############################################################################
  if(Bars<100){Print("bars less than 100"); return(0); }
//exit if not new bar
 if(BarTime == Time[0]) {return(0);}
//new bar, update bartime
 BarTime = Time[0];
//#############################################################################
//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 MinDist=(MarketInfo(Symbol(),MODE_STOPLEVEL)*Point);
 Spread=(Ask-Bid);
 MaxRisk=(AccountFreeMargin()*RiskPercent/100)*Point();
 MaxRiskStr=DoubleToStr(MaxRisk,4);

//#############################################################################
//~~~~~~~~~~~~~~~~~~INDICATOR CALCULATIONS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//DLMAP1= iMA(NULL,0,70,1440,MODE_EMA,PRICE_CLOSE,1);  //Daily = 1440 minutes
//DMMAP1= iMA(NULL,0,45,1440,MODE_EMA,PRICE_CLOSE,1);  //Daily = 1440 minutes

LMAP1= iMA(NULL,0,120,0,MODE_SMA,PRICE_CLOSE,1);
LMAP2= iMA(NULL,0,120,0,MODE_SMA,PRICE_CLOSE,2);
MMAP1= iMA(NULL,0,100,0,MODE_SMA,PRICE_CLOSE,1);
MMAP2= iMA(NULL,0,100,0,MODE_SMA,PRICE_CLOSE,2);
SMAP1= iMA(NULL,0,2,0,MODE_SMA,PRICE_CLOSE,1);
SMAP2= iMA(NULL,0,2,0,MODE_SMA,PRICE_CLOSE,2);

//####################OPENING RULES######################################
//BUY and SELL rules:
SL=0;
 if(MMAP1 > LMAP1)// Trend
  {
  if(SMAP2 < MMAP2 && SMAP1 > MMAP1) 
   {
    Buy=true;
    SL=0;//LMAP1+MinDist;
     }}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sell =false;
 if(MMAP1 < LMAP1)// Trend
  {
  if(SMAP2 > MMAP2 && SMAP1 < MMAP1)
   {  
    Sell=true;
    SL=0;//LMAP1-MinDist;
     }}

//######################CLOSING RULES###################################
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//CLOSE CloseShorts = false;
//LONG & SHORT Rules:  PROBLEM IF LINES MOVE DURING TRADE
CloseLongs = false;
CloseShorts = false;

if(Close[0]<LMAP1) CloseLongs = true;
if(Close[0]>LMAP1) CloseShorts= true;

if(0==1) // CHECK THIS IS OFF
{
CloseLongs = true;
CloseShorts = true;
}

//~~~~~~~~~~~~~~~~  ORDER CLOSURE  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//CLOSE LONG Entries
 if(CloseLongs == true)
 {                                 
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
   {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
     {CloseLongs=false;
      OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close LONG position
      SendMail(Symbol()+" BUY Order Closed @ "+Bid," ");
   }}}}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//CLOSE SHORT ENTRIES: 
 if(CloseShorts == true)
 { 
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
   {CloseShorts=false;   
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
    if(OrderType()==OP_SELL && OrderSymbol()==Symbol()) // check for symbol
     {
      OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
      SendMail(Symbol()+" SELL Order Closed @ "+ Ask," ");
   }}}}
//##############################################################################################
//~~~~~~~~~~~~~~~~~~~LOCK IN PROFIT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
      SL = OrderStopLoss();
      if(Bid > OrderOpenPrice() + (PP1*Point)) SL= OrderOpenPrice();             //PP def 15,35,55,65
      if(Bid > OrderOpenPrice() + (PP2*Point)) SL= OrderOpenPrice()+(PV1*Point); //PV def 15,45
      if(Bid > OrderOpenPrice() + (PP3*Point)) SL= OrderOpenPrice()+(PV2*Point);
      if(Bid > OrderOpenPrice() + (PP4*Point)) SL= Bid-(TrailingStop*Point);
      if(SL > OrderStopLoss())
      { 
       OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Orange);
       return(0);}
       }}}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
     {
      SL = OrderStopLoss();
      if(Ask < OrderOpenPrice() - (PP1*Point)) SL= OrderOpenPrice();
      if(Ask < OrderOpenPrice() - (PP2*Point)) SL= OrderOpenPrice()-(PV1*Point);
      if(Ask < OrderOpenPrice() - (PP3*Point)) SL= OrderOpenPrice()-(PV2*Point);
      if(Ask < OrderOpenPrice() - (PP4*Point)) SL= Ask+(TrailingStop*Point);
      if(SL < OrderStopLoss() || OrderStopLoss()==0)
      {
       OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Red);
       return(0);}
       }}}
 }
//##############################################################################

//~~~~~~~~~~~ END OF ORDER Closure routines & Stoploss changes  ~~~~~~~~~~~~~~~~~~~~
//##################################################################################
//##################################################################################
//~~~~~~~~~~~~START of NEW ORDERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if(AccountFreeMargin()<(1000*Lots))
   {Print("We have no money. Free Margin = ", AccountFreeMargin());
    return(0);}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if (0==1) // switch to turn ON/OFF history check
{  
 total=HistoryTotal();
 if(total>0)
  { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);            //Needs to be next day not as below
     if(OrderSymbol()==Symbol()&& CurTime()- OrderCloseTime() < (Period() * 60 )
        )
        {
        return(0);
 }}}}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 NumberofPositions = 0;
 total=OrdersTotal();
  if(total>0)
   { 
    for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderSymbol()==Symbol()) NumberofPositions=NumberofPositions+1;
       }
//may require extra code to determine exposure on any one pair
       if (NumberofPositions >= 1) return(0);
   }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//OPEN ORDER: LONG 
 if(Buy==true) 
  {
   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,SL,0,"System Long",16384,0,Orange); //Bid-(Point*(MinDist+2))
   if(ticket>0)
    { 
     Print("BUY order opened : ",OrderOpenPrice());
     Alert(Symbol()," Buy");
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {Print("BUY order opened : ",OrderOpenPrice());     
       //SendMail(Symbol()+" "+Period()+" BUY Order Opened @ "+Ask,"Comments: SL ="+SL+" Risk = "+DoubleToStr((Bid-SL),4)+" Max Risk "+MaxRiskStr);
       }
     }
     else Print("Error opening BUY order : ",GetLastError()); 
     return(0); 
   } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//OPEN ORDER: SHORT                                   
 if(Sell==true) 
  {
   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,SL,0,"System Short",16384,0,Red);
   if(ticket>0)
    {
      Print("SELL order opened : ",OrderOpenPrice());
      Alert(Symbol()," Sell");
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
       {Print("SELL order opened : ",OrderOpenPrice());
        //SendMail(Symbol()+" "+Period()+" SELL Order Opened @ "+Bid,"Comments: SL ="+SL+" Risk = "+DoubleToStr((SL-Ask),4)+" Max Risk "+MaxRiskStr);
        }
      }
      else Print("Error opening SELL order : ",GetLastError()); 
      return(0); 
   }

//####################################################################################
//############               End of PROGRAM                  #########################   
   return(0);
}


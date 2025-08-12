//+------------------------------------------------------------------+
//|                                      SMC Trader Manual           |
//+------------------------------------------------------------------+
//|DO NOT ENABLE THIS EA WITHOUT READING THIS FIRST....
//|
//|This EA will put 12 trendlines(TL) on the chart it is attached to.
//|3 TL's for a Simulated Buystop entry, TP & SL, 3 for SellStop, 3 
//|for Buylimit, & 3 for SellLimit.  Use the STOP TLs for pattern breakouts,
//|ie, the ea will buy(sell) on a close above(below) these TLs.  Use the LIMIT
//|TLs for Channels, ie, the ea will buy(sell) when price touches these TLs.
//|Put BuyLimit at the bottom of the channel, triangle or wedge, and
//|SellLimit at the top, to trade inside of the pattern.
//|
//|IF YOU ARE USING EA'S, YOU SHOULD BE AT LEAST FAMILIAR WITH THE CODE.
//|BROWSE THROUGH THE CODE, AND GET FAMILIAR WITH HOW THIS EA IS STRUCTURED,
//|AND HOW IT SHOULD LOGICALLY OPERATE BEFORE APPLYING TO A REAL MONEY ACCOUNT.
//|
//|IT WAS NOT STEVE'S ORIGIONAL INTENT THAT THIS BE A LIVE TRADING EA.
//+------------------------------------------------------------------+

#property copyright  "steve.cartwright@homecall.co.uk"//originator
#property copyright  "tageiger fxid10t@yahoo.com" //modifier
#property link       "http://www.metaquotes.net"
#property link       "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"
#property link       "http://www.forexnews.com"

extern double  Lots              =0.1;
extern double  MaximumRisk       =0.02;
extern double  DecreaseFactor    =3;
extern double  Slippage          =3;
extern int     UseTrailingStop   =0;//>0 enables trailing stop
extern double  TrailingStop      =20;
extern int     OneTradePerDay    =0;//>0 LIMITS(restricts) trades to ONE PER DAY
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//---- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//---- return lot size
   if(lot<0.1) lot=0.1;
   return(lot);
   }


//#####################################################################
int init()
{
//----
//######################  STOP ORDER TREND LINES  ##################### 
ObjectCreate("BuyStop", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[10],CurTime(),Low[10]);
ObjectSet("BuyStop",6,LimeGreen);
ObjectSet("BuyStop",7,STYLE_DOT);
ObjectSet("BuyStop",10,0);
ObjectSetText("BuyStop","BuyStop");

ObjectCreate("SellStop", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[10],CurTime(),High[10]);
ObjectSet("SellStop",6,HotPink);
ObjectSet("SellStop",7,STYLE_DOT);
ObjectSet("SellStop",10,0);
ObjectSetText("SellStop","SellStop");

ObjectCreate("BuyStopSL", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[10],CurTime(),Close[10]);
ObjectSet("BuyStopSL",6,Blue);
ObjectSet("BuyStopSL",7,STYLE_DOT);
ObjectSet("BuyStopSL",10,0);
ObjectSetText("BuyStopSL","BuyStopSL");

ObjectCreate("SellStopSL", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[10],CurTime(),Open[10]);
ObjectSet("SellStopSL",6,FireBrick);
ObjectSet("SellStopSL",7,STYLE_DOT);
ObjectSet("SellStopSL",10,0);
ObjectSetText("SellStopSL","SellStopSL");

ObjectCreate("BuyStopTP", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[10],CurTime(),Close[10]);
ObjectSet("BuyStopTP",6,Aqua);
ObjectSet("BuyStopTP",7,STYLE_DOT);
ObjectSet("BuyStopTP",10,0);
ObjectSetText("BuyStopTP","BuyStopTP");

ObjectCreate("SellStopTP", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[10],CurTime(),Open[10]);
ObjectSet("SellStopTP",6,Tomato);
ObjectSet("SellStopTP",7,STYLE_DOT);
ObjectSet("SellStopTP",10,0);
ObjectSetText("SellStopTP","SellStopTP");

//###########################  LIMIT ORDER TRENDLINES ######################

ObjectCreate("BuyLimit", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[10],CurTime(),High[10]);
ObjectSet("BuyLimit",6,LightCyan);
ObjectSet("BuyLimit",7,STYLE_SOLID);
ObjectSet("BuyLimit",10,0);
ObjectSetText("BuyLimit","BuyLimit");

ObjectCreate("SellLimit", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[10],CurTime(),Low[10]);
ObjectSet("SellLimit",6,MistyRose);
ObjectSet("SellLimit",7,STYLE_SOLID);
ObjectSet("SellLimit",10,0);
ObjectSetText("SellLimit","SellLimit");

ObjectCreate("BuyLimitSL", OBJ_TREND, 0, CurTime()-(Period()*60*30), Close[10],CurTime(),Close[10]);
ObjectSet("BuyLimitSL",6,Honeydew);
ObjectSet("BuyLimitSL",7,STYLE_SOLID);
ObjectSet("BuyLimitSL",10,0);
ObjectSetText("BuyLimitSL","BuyLimitSL");

ObjectCreate("SellLimitSL", OBJ_TREND, 0, CurTime()-(Period()*60*30), Open[10],CurTime(),Open[10]);
ObjectSet("SellLimitSL",6,LavenderBlush);
ObjectSet("SellLimitSL",7,STYLE_SOLID);
ObjectSet("SellLimitSL",10,0);
ObjectSetText("SellLimitSL","SellLimitSL");

ObjectCreate("BuyLimitTP", OBJ_TREND, 0, CurTime()-(Period()*60*30), Close[10],CurTime(),Close[10]);
ObjectSet("BuyLimitTP",6,BlanchedAlmond);
ObjectSet("BuyLimitTP",7,STYLE_SOLID);
ObjectSet("BuyLimitTP",10,0);
ObjectSetText("BuyLimitTP","BuyLimitTP");

ObjectCreate("SellLimitTP", OBJ_TREND, 0, CurTime()-(Period()*60*30), Open[10],CurTime(),Open[10]);
ObjectSet("SellLimitTP",6,LemonChiffon);
ObjectSet("SellLimitTP",7,STYLE_SOLID);
ObjectSet("SellLimitTP",10,0);
ObjectSetText("SellLimitTP","SellLimitTP");

Print("Initialising");

//----
   return(0);
  }
//#####################################################################

int start()
  {
   int cnt,total,ticket,MinDist,tmp;
   double Spread;
//############################################################################
  if(Bars<100){
     Print("bars less than 100");
     return(0);  
  }
//#########################################################################################
//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 MinDist=MarketInfo(Symbol(),MODE_STOPLEVEL);
 Spread=(Ask-Bid);
//#########################################################################################
// trendline point to trading variable assignment

   double BuyStop   =ObjectGetValueByShift("BuyStop",0);
   double BuyStopSL =ObjectGetValueByShift("BuyStopSL",0);
   double BuyStopTP =ObjectGetValueByShift("BuyStopTP",0);
   double SellStop  =ObjectGetValueByShift("SellStop",0);
   double SellStopSL=ObjectGetValueByShift("SellStopSL",0);
   double SellStopTP=ObjectGetValueByShift("SellStopTP",0);

   double BuyLimit   =ObjectGetValueByShift("BuyLimit",0);
   double BuyLimitSL =ObjectGetValueByShift("BuyLimitSL",0);
   double BuyLimitTP =ObjectGetValueByShift("BuyLimitTP",0);
   double SellLimit  =ObjectGetValueByShift("SellLimit",0);
   double SellLimitSL=ObjectGetValueByShift("SellLimitSL",0);
   double SellLimitTP=ObjectGetValueByShift("SellLimitTP",0);
   
   if(Minute()==0){
Print(Symbol(),"BuyStop:",BuyStop," BuyStopSL:",BuyStopSL," BuyStopTP:",BuyStopTP,
      " SellStop:",SellStop," SellStopSL:",SellStopSL," SellStopTP:",SellStopTP);}
//########################################################################################
//##################     ORDER CLOSURE  ###################################################
// If Orders are in force then check for closure against Technicals LONG & SHORT
//--------------------- STOP ORDER SL & TP MANAGEMENT -----------------------------------
//Buystop SL
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
   {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    if(OrderMagicNumber()==16384 &&
    OrderType()==OP_BUY && 
    OrderSymbol()==Symbol())
     {
     if(Close[1] < BuyStopSL)
      {                                 
       OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet); // close LONG position
     }}

//SellStop SL 
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
    if(OrderMagicNumber()==16384 &&
    OrderType()==OP_SELL &&
    OrderSymbol()==Symbol()) // check for symbol
     {
     if(Close[1] > SellStopSL)
      {   
       OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet); // close SHORT position
     }}
//BuyStop TP
    OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
    if(OrderMagicNumber()==16384 &&
    OrderType()==OP_BUY &&
    OrderSymbol()==Symbol()) //symbol check
     {
     if(Bid > BuyStopTP)
      {
      OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Yellow);
     }}
//SellStop TP
    OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
    if(OrderMagicNumber()==16384 &&
    OrderType()==OP_SELL &&
    OrderSymbol()==Symbol()) //symbol check
     {
     if(Ask > SellStopTP)
      {
      OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Yellow);
     }}   
    
    }  // for loop return
    }   // close 1st if

//--------------------- LIMIT ORDER SL & TP MANAGEMENT -----------------------------------
//BuyLimit SL
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
   {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    if(OrderMagicNumber()==222 &&
    OrderType()==OP_BUY && 
    OrderSymbol()==Symbol())
     {
     if(Close[1] < BuyLimitSL)
      {                                 
       OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet); // close LONG position
     }}

//SellLimit SL 
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
    if(OrderMagicNumber()==333 &&
    OrderType()==OP_SELL &&
    OrderSymbol()==Symbol()) // check for symbol
     {
     if(Close[1] > SellLimitSL)
      {   
       OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet); // close SHORT position
     }}
//BuyLimit TP
    OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
    if(OrderMagicNumber()==222 &&
    OrderType()==OP_BUY &&
    OrderSymbol()==Symbol()) //symbol check
     {
     if(Bid > BuyLimitTP)
      {
      OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Yellow);
     }}
//SellLimit TP
    OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
    if(OrderMagicNumber()==333 &&
    OrderType()==OP_SELL &&
    OrderSymbol()==Symbol()) //symbol check
     {
     if(Ask > SellLimitTP)
      {
      OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Yellow);
     }}   
    
    }  // for loop return
    }   // close 1st if 

//##############################################################################
//##################     ORDER TRAILING STOP Adjustment  #######################
//TRAILING STOP: LONG
if(UseTrailingStop>0)  //This is used to turn the trailing stop on & off
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
//##########################################################################################
//~~~~~~~~~~~ END OF ORDER Closure routines & Stoploss changes  ~~~~~~~~~~~~~~~~~~~~~~~~~~~
//##########################################################################################
//~~~~~~~~~~~~START of NEW ORDERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#########################  NEW POSITIONS ?  ######################################
if(OneTradePerDay>0) // switch to turn ON/OFF history check
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
//ENTRY RULES: BUYSTOP 
 if(Close[1] > BuyStop)
  {
   ticket=OrderSend( Symbol(),
                     OP_BUY,
                     LotsOptimized(),
                     Ask,
                     Slippage,//slippage
                     0,//stoploss
                     0,//takeprofit
                     "SMC BuyStop",
                     16384,0,Orange); //Bid-(Point*(MinDist+2))
   if(ticket>0)
    {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BuyStop order opened : ",OrderOpenPrice());
     }
     else Print("Error opening BuyStop order : ",GetLastError()); 
     return(0); 
   } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ENTRY RULES: SELLSTOP
 if(Close[1]< SellStop)
  {
   ticket=OrderSend( Symbol(),
                     OP_SELL,
                     LotsOptimized(),
                     Bid,
                     Slippage,//slippage
                     0,//stoploss
                     0,//takeprofit
                     "SMC SellStop",
                     16384,0,Red);
   if(ticket>0)
    {
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SellStop order opened : ",OrderOpenPrice());
      }
      else Print("Error opening SellStop order : ",GetLastError()); 
      return(0); 
   }

//#########################################################################################
//ENTRY RULES: BUYLIMIT 
 if(Ask==NormalizeDouble(BuyLimit,4))
  {
   ticket=OrderSend( Symbol(),
                     OP_BUY,
                     LotsOptimized(),
                     Ask,
                     Slippage,//slippage
                     0,//stoploss
                     0,//takeprofit
                     "SMC BuyLimit",
                     222,0,Orange); //Bid-(Point*(MinDist+2))
   if(ticket>0)
    {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BuyLimit order opened : ",OrderOpenPrice());
     }
     else Print("Error opening BuyLimit order : ",GetLastError()); 
     return(0); 
   } 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ENTRY RULES: SellLimit
 if(Bid==NormalizeDouble(SellLimit,4))
  {
   ticket=OrderSend( Symbol(),
                     OP_SELL,
                     LotsOptimized(),
                     Bid,
                     Slippage,//slippage
                     0,//stoploss
                     0,//takeprofit
                     "SMC SellLimit",
                     333,0,Red);
   if(ticket>0)
    {
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SellLimit order opened : ",OrderOpenPrice());
      }
      else Print("Error opening SellLimit order : ",GetLastError()); 
      return(0); 
   }

//####################################################################################
//############               End of PROGRAM                  #########################   
   return(0);
}


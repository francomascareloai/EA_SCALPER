//+------------------------------------------------------------------+
//|                                      SMC Trader Manual           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 extern double TakeProfit = 50;
 extern double Lots = 0.1;
 extern double InitialStop = 30;
 extern double TrailingStop = 20;
//#####################################################################
int init()
{
//---- 
ObjectCreate("OpenL", OBJ_TREND, 0, CurTime()-(Period()*60*30), High[10],CurTime(),High[10]);
ObjectSet("OpenL",6,Aqua);
ObjectSet("OpenL",7,STYLE_DOT);
ObjectSet("OpenL",10,0);
ObjectSetText("OpenL","OL");

ObjectCreate("OpenS", OBJ_TREND, 0, CurTime()-(Period()*60*30), Low[10],CurTime(),Low[10]);
ObjectSet("OpenS",6,Red);
ObjectSet("OpenS",7,STYLE_DOT);
ObjectSet("OpenS",10,0);
ObjectSetText("OpenS","OS");

ObjectCreate("CloseL", OBJ_TREND, 0, CurTime()-(Period()*60*30), Close[10],CurTime(),Close[10]);
ObjectSet("CloseL",6,Blue);
ObjectSet("CloseL",7,STYLE_DOT);
ObjectSet("CloseL",10,0);
ObjectSetText("CloseL","CL");

ObjectCreate("CloseS", OBJ_TREND, 0, CurTime()-(Period()*60*30), Open[10],CurTime(),Open[10]);
ObjectSet("CloseS",6,FireBrick);
ObjectSet("CloseS",7,STYLE_DOT);
ObjectSet("CloseS",10,0);
ObjectSetText("CloseS","CS");


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
// use an indicator for data values
   double OpenLongVal =ObjectGet("OpenL",3);
   double CloseLongVal =ObjectGet("CloseL",3);
   double OpenShortVal =ObjectGet("OpenS",3);
   double CloseShortVal =ObjectGet("CloseS",3);
//Print(Symbol()," ",OpenLongVal," ",CloseLongVal," ",OpenShortVal," ",CloseShortVal);
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
     if(Close[1] < CloseLongVal)
      {                                 
       OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close LONG position
     }}

//CLOSE SHORT ENTRIES: 
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
    if(OrderType()==OP_SELL && OrderSymbol()==Symbol()) // check for symbol
     {
     if(Close[1] > CloseShortVal)
      {   
       OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
     }}
    }  // for loop return
    }   // close 1st if 
//##############################################################################
//##################     ORDER TRAILING STOP Adjustment  #######################
//TRAILING STOP: LONG
if(0==1)  //This is used to turn the trailing stop on & off
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
 if(Close[1] > OpenLongVal)
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
 if(Close[1]< OpenShortVal)
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


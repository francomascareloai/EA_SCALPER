//+------------------------------------------------------------------+
//|                                      SMC Autotrader Momentum.mq4 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

 extern double TakeProfit = 50;
 extern double Lots = 0.1;
 extern double InitialStop = 30;
 extern double TrailingStop = 20;
 datetime BarTime;
 
  static string DirTrgS = "None";
  static string DirTrgM= "None";
  static string DirTrgL = "None";

//#####################################################################
int init()
{
//---- 
 BarTime=0;
 
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
   
//   int LSMA_Period = 25;
//   int Rperiod = 25;
   int length;
   double lsma_length;
   double sum[30];
   double wt[30];
   double lsma_ma[30];
   double lengthvar;
   double tmpTG;
   int shift,i,j;
   double lsma10, lsma25;
//############################################################################
 if(Bars<100)
  {Print("bars less than 100");
   return(0);}
//exit if not new bar
 if(BarTime == Time[0]) {return(0);}
//new bar, update bartime
 BarTime = Time[0]; 
//########################################################################################
       length = 15;          //Hourly set to 15 bars  
       lsma_length = 15;

      for(shift = 30; shift >= 0; shift--)  //  MAIN For Loop
      { 
         sum[1] = 0;                                              
         for(i = length; i >= 1  ; i--)             //LSMA loop
         {
         lengthvar = length + 1;                               //lengthvar = 21  
         lengthvar /= 3;                                       //lengthvar = 7
         tmpTG = 0;
         tmpTG = ( i - lengthvar)*Close[length-i+shift];         //tmp = 20 - 7 * close[20-i+shift]
         sum[1]+=tmpTG;
         }
         wt[shift] = sum[1]*6/(length*(length+1));  
         j = shift;
         lsma_ma[shift] = wt[j+1] + (wt[j]-wt[j+1])* 2/(lsma_length+1);
       }
         DirTrgS = "None";
         if(wt[1] > lsma_ma[1] && wt[2] > lsma_ma[2] ) DirTrgS = "Long";    //wt[2] < lsma_ma[2] && 
         if(wt[1] < lsma_ma[1] && wt[2] < lsma_ma[2] ) DirTrgS = "Short";   // wt[2] > lsma_ma[2] && 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      length = 60;          //4Hourly = 15(hourly) *4
      lsma_length = 60;

      for(shift = 30; shift >= 0; shift--)  //  MAIN For Loop
      { 
         sum[1] = 0;                                              
         for(i = length; i >= 1  ; i--)             //LSMA loop
         {
         lengthvar = length + 1;                               //lengthvar = 21  
         lengthvar /= 3;                                       //lengthvar = 7
         tmpTG = 0;
         tmpTG = ( i - lengthvar)*Close[length-i+shift];         //tmp = 20 - 7 * close[20-i+shift]
         sum[1]+=tmpTG;
         }
         wt[shift] = sum[1]*6/(length*(length+1));  
         j = shift;
         lsma_ma[shift] = wt[j+1] + (wt[j]-wt[j+1])* 2/(lsma_length+1);
       }

         DirTrgM = "None";
         if(wt[1] > lsma_ma[1] && wt[2] > lsma_ma[2]) DirTrgM = "Long";   //2 days needed to confirm trend    //wt[2] < lsma_ma[2] && 
         if(wt[1] < lsma_ma[1] && wt[2] < lsma_ma[2]) DirTrgM = "Short";      //wt[2] > lsma_ma[2] && 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      length = 100;       // = Daily  
      lsma_length = 100;

      for(shift = 30; shift >= 0; shift--)  //  MAIN For Loop
      { 
         sum[1] = 0;                                              
         for(i = length; i >= 1  ; i--)             //LSMA loop
         {
         lengthvar = length + 1;                               //lengthvar = 21  
         lengthvar /= 3;                                       //lengthvar = 7
         tmpTG = 0;
         tmpTG = ( i - lengthvar)*Close[length-i+shift];         //tmp = 20 - 7 * close[20-i+shift]
         sum[1]+=tmpTG;
         }
         wt[shift] = sum[1]*6/(length*(length+1));  
         j = shift;
         lsma_ma[shift] = wt[j+1] + (wt[j]-wt[j+1])* 2/(lsma_length+1);
       }

         DirTrgL = "None";
         if(wt[1] > lsma_ma[1] && wt[2] > lsma_ma[2]) DirTrgL = "Long";   //2 days needed to confirm trend    //wt[2] < lsma_ma[2] && 
         if(wt[1] < lsma_ma[1] && wt[2] < lsma_ma[2]) DirTrgL = "Short";      //wt[2] > lsma_ma[2] && 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#########################################################################################
//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 MinDist=MarketInfo(Symbol(),MODE_STOPLEVEL);
 Spread=(Ask-Bid);
// use an indicator for data values
// ATR =iATR(NULL,0,10,0); // BE CAREFUL OF EFFECTING THE AUTO TRAIL STOPS
 double TrendS=iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,0);
 double TrendM=iMA(NULL,0,12,0,MODE_SMA,PRICE_CLOSE,0);

//#########################################################################################
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
     if(DirTrgS == "Short")
      {                                 
       OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close LONG position
     }}

//CLOSE SHORT ENTRIES: 
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
    if(OrderType()==OP_SELL && OrderSymbol()==Symbol()) // check for symbol
     {
     if(DirTrgS == "Long")
      {   
       OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
     }}
    }  // for loop return
    }   // close 1st if 
//################################################################################
//##################  LOCK IN 50 points profit ################################### 
if(0==1)
{
  total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_BUY && OrderSymbol()==Symbol()
         //&& OrderOpen < Close[0]+50points
     
        )
     {
     OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),0,White);
     }
     }}
     
   total=OrdersTotal();
  if(total>0)
   { 
   for(cnt=0;cnt<total;cnt++)
    {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
     {
     OrderModify(OrderTicket(),OrderOpenPrice(),High[1],OrderTakeProfit(),0,White);
     }
     }}  
     
}
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
 if(DirTrgS == "Long" &&
    DirTrgM == "Long" &&
    DirTrgL == "Long" 
     )
  {Alert(Symbol()," Long");
   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"Trigger Long",16384,0,Orange); //Bid-(Point*(MinDist+2))
   if(ticket>0)
    {
    if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
     }
     else Print("Error opening BUY order : ",GetLastError()); 
     return(0); 
   } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ENTRY RULES: SHORT                                     //################################
 if(DirTrgS == "Short" &&
    DirTrgM == "Short" &&
    DirTrgL == "Short"
     )
  {Alert(Symbol()," Short");
   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"Trigger Short",16384,0,Red);
   if(ticket>0)
    {
     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
      }
      else Print("Error opening SELL order : ",GetLastError()); 
      return(0); 
   }

//#######################################################################################################


//####################################################################################
//############               End of PROGRAM                  #########################   
   return(0);
}


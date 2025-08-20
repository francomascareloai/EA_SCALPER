//+------------------------------------------------------------------+
//|                         Steve Cartwright Trader Camel CCI MACD.mq4 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
extern double Lots=0.1;

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

 double Lots;
 int TakeProfit, InitialStop, TrailingStop;
 int total,ticket,MinDist;
 double Spread;
 double ATR;
 int cnt, tmp;

//############################################################################
 //#########################################################################################
//~~~~~~~~~~~~~~~~Miscellaneous setup stuff~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 if(Bars<300)
 {
     Print("bars less than 300");
     return(0);  
  }
  
//#########################################################################################
int ArPer=20;
      double HighBar = Highest(NULL,0,MODE_HIGH,ArPer,1);        	   
      double LowBar  = Lowest (NULL,0,MODE_LOW,ArPer,1);	 

      double AroonLong = ((ArPer-HighBar+1)/ArPer)*100;    
      double AroonShort  = ((ArPer-LowBar+1)/ArPer)*100;    
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ATR=iATR(NULL,0,10,0); // BE CAREFUL OF EFFECTING THE AUTO TRAIL STOPS
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#########################################################################################
//##################     ORDER CLOSURE  ##################################################

  total=OrdersTotal();
  if(total>0)
   { 
    for(cnt=0;cnt<total;cnt++)
     {
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//CLOSE LONG Entries
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
       {
       if(AroonLong < 80)
        {OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close LONG position
         }}

//CLOSE SHORT ENTRIES: 
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol())   
       {
       if(AroonShort < 80)  
        {OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close SHORT position
         }}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    }  // for loop return
   }   // close 1st if 
//##########################################################################################
//~~~~~~~~~~~ END OF ORDER Closure routines & Stoploss changes  ~~~~~~~~~~~~~~~~~~~~~~~~~~~
//##########################################################################################
//~~~~~~~~~~~~START of NEW ORDERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#########################  NEW POSITIONS ?  ##############################################

 total=OrdersTotal();
 if(total>0)
  { 
    for(cnt=0;cnt<total;cnt++)
     {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol())
         {return(0);}
   } } 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 total=HistoryTotal();
  if(total>0)
   { 
    for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
       if(OrderSymbol()==Symbol()
          &&
          CurTime()- OrderCloseTime() < (Period() * 60 ))
          {return(0);}
    } }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   if(AccountFreeMargin()<(1000*Lots))
   {Print("We have no money. Free Margin = ", AccountFreeMargin());
    return(0);}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#########################################################################################
//ENTRY RULES: LONG 

 if(AroonLong == 100 
    &&
    Close[0] > High[1]
    )                                             
  {
   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"Camel Long",16384,0,Orange); //Bid-(Point*(MinDist+2))

   if(ticket>0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
       }
      else Print("Error opening BUY order : ",GetLastError()); 
      return(0); 
   }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//ENTRY RULES: SHORT                                     //################################

   if(AroonShort == 100
      &&
      Close[0] < Low[1]
      )                        
     {
      ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"Camel Short",16384,0,Red);

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


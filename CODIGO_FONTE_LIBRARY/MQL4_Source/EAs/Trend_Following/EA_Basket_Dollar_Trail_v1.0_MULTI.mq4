/*+------------------------------------------------------------------+
  Pips Trailing.mq4 
  Author : Aiman
  Ver 1.0 (27.10.2009)
  
  Ver 1.1 (31.10.2009)
  - Individual pair trailing stoploss added
  
  Ver 1.2 (06.11.2009)
  - No Lagging Expert
//+------------------------------------------------------------------+*/
#property copyright "Copyright © 2009, 1000 pips club"
#property link      ""

//---- input parameters
extern double     Target_Dollars       =  500;
extern double     StopLoss_Dollars     =  0;

extern bool    Dollars_Trailing     =  false;
extern double     Trailing_Start    =  200;
extern double     Trailing_Dollars     =  50;

extern string  NameFileSound     = "cash-register-05.wav";
int slippage=5;

bool CloseOP=false;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {   return(0);}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() 
{
   ObjectDelete("Totaldollars");
   ObjectDelete("Targetdollars");
   ObjectDelete("StopLossdollars");
   ObjectDelete("TrailingStop");
   ObjectDelete("eTrailing");
   
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
      bool loop=true;
      while (loop)
      {
         Sleep (700);
         if(CloseOP) CloseAll ();
         
         if(OrdersTotal()==0) CloseOP=false;         
         //- Close all is pips reached Target Dollars
         if(Target_Dollars>0 && Totaldollars()>=Target_Dollars) CloseOP=true;
      
         //- Close all is pips touched StopLoss Dollars
         if(StopLoss_Dollars>0 && Totaldollars()<(0-StopLoss_Dollars)) CloseOP=true;

         //- Pips trailing StopLoss
         if(Dollars_Trailing) DollarsTrailing();
           
         displayStatus ();
      }
      return(0);
  }
//+------------------------------------------------------------------+ 
double Totaldollars ()
{
   double pips, AccType, lots;
 
   if (MarketInfo(OrderSymbol (), MODE_LOTSIZE) == 1000.0) AccType = 0.1;
   if (MarketInfo(OrderSymbol (), MODE_LOTSIZE) == 10000.0) AccType = 1;
   if (MarketInfo(OrderSymbol (), MODE_LOTSIZE) == 100000.0) AccType = 10;
   
 double totaldollar=0;
   for(int i=0;i<OrdersTotal();i++) 
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<2)
      totaldollar+=OrderProfit()+OrderSwap()+OrderCommission();
   }
   return (totaldollar);
}
//+------------------------------------------------------------------+ 
void CloseAll ()
{
   for(int i=0;i<OrdersTotal();i++) 
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderType()==OP_BUY)
      {
         OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), slippage, CLR_NONE );
         Sleep(300);
         continue;
      }
      if (OrderType()==OP_SELL)
      {
         OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), slippage, CLR_NONE );
         Sleep(300);
      }
   }
}
//+------------------------------------------------------------------+
void DollarsTrailing ()
{
   double DollarsLocked;
  
   if (Totaldollars()>=Trailing_Start && GlobalVariableCheck("DollarsLocked")==false)
      GlobalVariableSet("DollarsLocked", Totaldollars()-Trailing_Dollars);

   if (GlobalVariableCheck("DollarsLocked"))
   {
      DollarsLocked=GlobalVariableGet("DollarsLocked");
      if(Totaldollars()>DollarsLocked+Trailing_Dollars )
         GlobalVariableSet("DollarsLocked", Totaldollars()-Trailing_Dollars);
   //add by mizee
      if (Totaldollars()>=Trailing_Start)
         PlaySound(NameFileSound);
      
      if (Totaldollars()<=DollarsLocked) CloseOP=true;
      
   }

   if (OrdersTotal()==0)
      GlobalVariableDel("DollarsLocked");
      
   
}
//+------------------------------------------------------------------+
void displayStatus ()
{
   string fontstyle="Tahoma Bold";
   string statustext;
   color textcolor;   
   int ydist=10;
   
  
   if (Dollars_Trailing)
   {
      if (!GlobalVariableCheck("DollarsLocked"))
      {
         statustext="Trailing Dollars start @ "+DoubleToStr(Trailing_Start,0); 
         textcolor=Peru;
      }
      else 
      {
         statustext= "Trailing Dollars @ : "+DoubleToStr(GlobalVariableGet("DollarsLocked"),2); 
         textcolor=LawnGreen; 
      }
      if (CloseOP) {statustext= "EA is closing all trades!"; textcolor=Red; }
      drawLabel ("TrailingStop", statustext, 9, fontstyle, textcolor, 2, 10, ydist); 
      ydist=ydist+14;
   }

   if (StopLoss_Dollars>0)
   {
      statustext="StopLoss Dollars: -"+DoubleToStr(StopLoss_Dollars,0);
      drawLabel ("StopLossdollars", statustext, 9, fontstyle, Yellow, 2, 10, ydist);
      ydist=ydist+14;
   }
   
   if (Target_Dollars>0) 
   {
      statustext="Target Dollars: "+DoubleToStr(Target_Dollars,0);
      drawLabel ("Targetdollars", statustext, 9, fontstyle, Yellow, 2, 10, ydist);
      ydist=ydist+14;
   }      

   drawLabel ("Totaldollars", "Total Dollars: "+DoubleToStr(Totaldollars(),2), 9, fontstyle, Yellow, 2, 10, ydist);
}
//+------------------------------------------------------------------+
void drawLabel (string Ln, string Lt, int th, string ts, color Lc, int cr, int xp, int yp)
{
   ObjectCreate(Ln, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Ln, Lt, th, ts, Lc);
   ObjectSet(Ln, OBJPROP_CORNER, cr);
   ObjectSet(Ln, OBJPROP_XDISTANCE, xp);
   ObjectSet(Ln, OBJPROP_YDISTANCE, yp);  
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
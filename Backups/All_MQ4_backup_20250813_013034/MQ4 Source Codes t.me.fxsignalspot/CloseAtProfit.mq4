//+------------------------------------------------------------------+
#property copyright "Copyright © 2011 Matus German www.MTexperts.net"

extern bool      useProfitToClose       = true;
extern double    profitToClose          = 20;
extern bool      useLossToClose         = false;
extern double    lossToClose            = 100;
extern bool      AllSymbols             = true;
extern bool      PendingOrders          = true;
extern double    MaxSlippage            = 3;   
extern bool      showMenu               = true;
extern color     menuColor              = Blue; 
extern color     variablesColor         = Red;
extern int       font                   = 10;

double pips2dbl, pips2point, pipValue, maxSlippage,
       profit;
             
bool   clear;

int   medzera = 8,
      trades;

double menulots;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----

   Comment("Copyright © 2011, Matus German");
   
   if (Digits == 5 || Digits == 3)    // Adjust for five (5) digit brokers.
   {            
      pips2dbl = Point*10; pips2point = 10;pipValue = (MarketInfo(Symbol(),MODE_TICKVALUE))*10;
   } 
   else 
   {    
      pips2dbl = Point;   pips2point = 1;pipValue = (MarketInfo(Symbol(),MODE_TICKVALUE))*1;
   }

   clear = true;

   if(showMenu)
   {  
      DrawMenu();
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   if(showMenu)
   {
      ObjectDelete("name");
      ObjectDelete("Openl");
      ObjectDelete("Open");
      ObjectDelete("Lotsl");
      ObjectDelete("Lots");
      ObjectDelete("Profitl");
      ObjectDelete("Profit");
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
   if(showMenu)
   {
      ReDrawMenu();
   }

   if(!clear)
   {
         if(AllSymbols)
         {
            if(PendingOrders)
                  if(CloseDeleteAll()) 
                     clear=true;
                  else
                     return;
            if(!PendingOrders)
                  if(CloseDeleteAllNonPending()) 
                     clear=true;
                  else 
                     return;
         }
         if(!AllSymbols)
         {
            if(PendingOrders)
                  if(CloseDeleteAllCurrent()) 
                     clear=true;
                  else  
                     return;
            if(!PendingOrders)
                  if(CloseDeleteAllCurrentNonPending()) 
                     clear=true;
                  else
                     return;
         }
   }
   
   profit = ProfitCheck();  
   if(useProfitToClose)
   {
      if(profit>profitToClose)
      {
         if(AllSymbols)
         {
            if(PendingOrders)
               if(!CloseDeleteAll()) 
                  clear=false;
            if(!PendingOrders)
               if(!CloseDeleteAllNonPending()) 
                  clear=false;
         }
         if(!AllSymbols)
         {
            if(PendingOrders)
               if(!CloseDeleteAllCurrent()) 
                  clear=false;
            if(!PendingOrders)
               if(!CloseDeleteAllCurrentNonPending()) 
                  clear=false;
         }
      }
   } 
   
   if(useLossToClose)
   {
      if(profit<-lossToClose)
      {
         if(AllSymbols)
         {
            if(PendingOrders)
               if(!CloseDeleteAll()) 
                  clear=false;
            if(!PendingOrders)
               if(!CloseDeleteAllNonPending()) 
                  clear=false;
         }
         if(!AllSymbols)
         {
            if(PendingOrders)
               if(!CloseDeleteAllCurrent()) 
                  clear=false;
            if(!PendingOrders)
               if(!CloseDeleteAllCurrentNonPending()) 
                  clear=false;
         }
      }     
   } 
//----
   return(0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
bool CloseDeleteAll()
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);

         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
            switch(OrderType())
            {
               case OP_BUY       :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),maxSlippage,Violet))
                     return(false);
               }break;                  
               case OP_SELL      :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),maxSlippage,Violet))
                     return(false);
               }break;
            }             
         
            
            if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
               if(!OrderDelete(OrderTicket()))
               { 
                  Print("Error deleting " + OrderType() + " order : ",GetLastError());
                  return (false);
               }
          }
      }
      return (true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// delete all on current chart
bool CloseDeleteAllCurrent()
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);

         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
            if(OrderSymbol()==Symbol())
            {
               switch(OrderType())
               {
                  case OP_BUY       :
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),maxSlippage,Violet))
                        return(false);
                  }break;
                   
                  case OP_SELL      :
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),maxSlippage,Violet))
                        return(false);
                  }break;
               }             
            
            
            if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
               if(!OrderDelete(OrderTicket()))
               { 
                  return (false);
               }
            }
         }
      }
      return (true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// left pending orders
bool CloseDeleteAllNonPending()
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);

         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
            switch(OrderType())
            {
               case OP_BUY       :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),maxSlippage,Violet))
                     return(false);
               }break;                  
               case OP_SELL      :
               {
                  if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),maxSlippage,Violet))
                     return(false);
               }break;
            }             
         }
      }
      return (true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// delete all on current chart left pending
bool CloseDeleteAllCurrentNonPending()
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);

         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
            if(OrderSymbol()==Symbol())
            {
               switch(OrderType())
               {
                  case OP_BUY       :
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),maxSlippage,Violet))
                        return(false);
                  }break;
                   
                  case OP_SELL      :
                  {
                     if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),maxSlippage,Violet))
                        return(false);
                  }break;
               }             
            }
         }
      }
      return (true);
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double ProfitCheck()
{
   double profit=0;
   int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(AllSymbols)
            profit+=OrderProfit();
         else if(OrderSymbol()==Symbol())
            profit+=OrderProfit();
      }
   return(profit);        
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
bool DrawMenu()
{
      ObjectCreate("name",OBJ_LABEL,0,0,0,0,0);
      ObjectCreate("Openl",OBJ_LABEL,0,0,0,0,0);
      ObjectCreate("Open",OBJ_LABEL,0,0,0,0,0);
      ObjectCreate("Lotsl",OBJ_LABEL,0,0,0,0,0);
      ObjectCreate("Lots",OBJ_LABEL,0,0,0,0,0);
      ObjectCreate("Profitl",OBJ_LABEL,0,0,0,0,0);
      ObjectCreate("Profit",OBJ_LABEL,0,0,0,0,0);
      
      medzera = 8;
       
      trades = Opened();
      menulots = Lots();
     
     ObjectSetText(	"name", "CloseAtProfit", font+1, "Arial",menuColor);
     ObjectSet("name",OBJPROP_XDISTANCE,medzera*font);     
     ObjectSet("name",OBJPROP_YDISTANCE,10+font);
     ObjectSet("name",OBJPROP_CORNER,1);
         
     ObjectSetText("Openl", "Opened trades: ", font, "Arial",menuColor);
     ObjectSet("Openl",OBJPROP_XDISTANCE,medzera*font);     
     ObjectSet("Openl",OBJPROP_YDISTANCE,10+2*(font+2));
     ObjectSet("Openl",OBJPROP_CORNER,1);
     
     ObjectSetText("Open", ""+trades, font, "Arial",variablesColor);
     ObjectSet("Open",OBJPROP_XDISTANCE,3*font);     
     ObjectSet("Open",OBJPROP_YDISTANCE,10+2*(font+2));
     ObjectSet("Open",OBJPROP_CORNER,1);
     
     ObjectSetText("Lotsl", "Lots of opened positions: ", font, "Arial",menuColor);
     ObjectSet("Lotsl",OBJPROP_XDISTANCE,medzera*font);     
     ObjectSet("Lotsl",OBJPROP_YDISTANCE,10+3*(font+2));
     ObjectSet("Lotsl",OBJPROP_CORNER,1);
     
     ObjectSetText("Lots", DoubleToStr(menulots,2), font, "Arial",variablesColor);
     ObjectSet("Lots",OBJPROP_XDISTANCE,3*font);     
     ObjectSet("Lots",OBJPROP_YDISTANCE,10+3*(font+2));
     ObjectSet("Lots",OBJPROP_CORNER,1);
     
     ObjectSetText("Profitl", "Profit of opened positions: ", font, "Arial",menuColor);
     ObjectSet("Profitl",OBJPROP_XDISTANCE,medzera*font);     
     ObjectSet("Profitl",OBJPROP_YDISTANCE,10+4*(font+2));
     ObjectSet("Profitl",OBJPROP_CORNER,1);
     
     ObjectSetText("Profit", DoubleToStr(profit,2), font, "Arial",variablesColor);
     ObjectSet("Profit",OBJPROP_XDISTANCE,3*font);     
     ObjectSet("Profit",OBJPROP_YDISTANCE,10+4*(font+2));
     ObjectSet("Profit",OBJPROP_CORNER,1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
bool ReDrawMenu()
{
      medzera = 8;
       
      trades = Opened();
      menulots = Lots();
     
     ObjectSetText("Open", ""+trades, font, "Arial",variablesColor); 
     ObjectSetText("Lots", DoubleToStr(menulots,2), font, "Arial",variablesColor);    
     ObjectSetText("Profit", DoubleToStr(profit,2), font, "Arial",variablesColor);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int Opened()
{
    int total  = OrdersTotal();
    int count = 0;
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(AllSymbols)
         {
            if(PendingOrders)
                  count++;
            if(!PendingOrders)
               if(OrderType()==OP_BUY || OrderType()==OP_SELL)
                  count++;
         }
         if(!AllSymbols)
         {
            if(OrderSymbol()==Symbol())
            {
               if(PendingOrders)
                     count++;
               if(!PendingOrders)
                  if(OrderType()==OP_BUY || OrderType()==OP_SELL)
                     count++;
            }
         }
      }
    return (count);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double Lots()
{
    int total  = OrdersTotal();
    double lots = 0;
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {                                   
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(AllSymbols)
         {
            if(PendingOrders)
                  lots+=OrderLots();
            if(!PendingOrders)
               if(OrderType()==OP_BUY || OrderType()==OP_SELL)
                  lots+=OrderLots();
         }
         if(!AllSymbols)
         {
            if(OrderSymbol()==Symbol())
            {
               if(PendingOrders)
                     lots+=OrderLots();
               if(!PendingOrders)
                  if(OrderType()==OP_BUY || OrderType()==OP_SELL)
                     lots+=OrderLots();
            }
         }
      }
    return (lots);
}



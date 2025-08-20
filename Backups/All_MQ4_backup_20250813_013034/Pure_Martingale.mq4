//+------------------------------------------------------------------+
#property copyright "Copyright © 2012 Matus German, www.MTexperts.net"

extern string    separator1            = "------ Martingale settings ------";
extern double    sl_tp                 = 20;                 // stop loss and take profit
extern double    lotsMultiplier        = 1.5;
extern double    distanceMultiplier    = 1.5;               
extern double    Lots                  = 0.03;               // fixed lot size
extern double    MaxSlippage           = 3;   
extern double    magicNumber           = 1212123;              

extern string  separator2              =  "------ Trading Hours ------";
extern bool    useTradingHours         = false;
extern string  StartTime               = "06:00";
extern string  StopTime                = "18:00";
extern int     GMT_Offset              = 0;

extern string  separator3              = "------ Trading Days ------";
extern bool    Monday                  = true;
extern bool    Tuesday                 = true;
extern bool    Wednesday               = true;
extern bool    Thursday                = true;
extern bool    Friday                  = true;
extern bool    Saturday                = true;
extern bool    Sunday                  = true;

extern string   separator4            = "------ Wiew settings ------";
extern bool     showMenu               = true;
extern color    menuColor              = Yellow; 
extern color    variablesColor         = Red;
extern int      font                   = 10;

double   stopLoss, takeProfit,
         minAllowedLot, lotStep, maxAllowedLot,
         pips2dbl, pips2point, pipValue, minGapStop, maxSlippage,
         menulots,
         profit,
         lots,
         ma1;

datetime barTime=0;

bool  noHistory=false,
      stopsChecked;
      
int   medzera = 8,
      trades;
      
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----

   Comment("Copyright © 2012, Matus German");
   
   if (Digits == 5 || Digits == 3)    // Adjust for five (5) digit brokers.
   {            
      pips2dbl = Point*10; pips2point = 10; pipValue = (MarketInfo(Symbol(),MODE_TICKVALUE))*10;
   } 
   else 
   {    
      pips2dbl = Point;   pips2point = 1; pipValue = (MarketInfo(Symbol(),MODE_TICKVALUE))*1;
   }
   
   maxSlippage = MaxSlippage*pips2dbl;
   stopLoss = pips2dbl*sl_tp;
   takeProfit = stopLoss;
   minGapStop = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;
   
   lots = Lots;
   minAllowedLot  =  MarketInfo(Symbol(), MODE_MINLOT);    //IBFX= 0.10
   lotStep        =  MarketInfo(Symbol(), MODE_LOTSTEP);   //IBFX= 0.01
   maxAllowedLot  =  MarketInfo(Symbol(), MODE_MAXLOT );   //IBFX=50.00
 
   if(lots < minAllowedLot)
      lots = minAllowedLot;
   if(lots > maxAllowedLot)
      lots = maxAllowedLot;
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
   if(HistoryForMNandPT(magicNumber, Symbol())<=0)
      noHistory=true;
   else
      noHistory=false;   
      
   if(showMenu)
   {
      profit=ProfitCheck();
      ReDrawMenu();
   }
     
      int day = DayOfWeek();
      if((Monday && day==1) || (Tuesday && day==2) || (Wednesday && day==3) || (Thursday && day==4) || (Friday && day==5) || (Saturday && day==6) || (Sunday && day==7))
      {
         if(useTradingHours)
         {
            if(TradingTime())
               OpenOrderCheck();
         }
         else  
         {
            OpenOrderCheck();
         }
      }   
   
   if(!stopsChecked)
      if(CheckStops())
         stopsChecked = true;
      else return;
//----
   return(0);
}
//////////////////////////////////////////////////////////////////////////////////////////////////
// calculate random number
int Random()
{   
    MathSrand(TimeLocal()+Bid);
    return(MathRand());
}   
//////////////////////////////////////////////////////////////////////////////////////////////////  
bool EnterBuyCondition()
{ 
   if(MathMod(Random(),2)==0)
      return(true);
      
   return (false);   
}

//////////////////////////////////////////////////////////////////////////////////////////////////
bool EnterSellCondition()
{ 
   if(MathMod(Random(),2)==1)
      return(true);
      
   return (false);   
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// chceck trades if they do not have set sl and tp than modify trade
bool CheckStops()
{
   double sl=0, tp=0, loss;
   double total=OrdersTotal();
   
   int ticket=-1;
   
   for(int cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(   OrderType()<=OP_SELL                      // check for opened position 
         && OrderSymbol()==Symbol()                   // check for symbol
         && OrderMagicNumber() == magicNumber)        // my magic number
      {
         if(OrderType()==OP_BUY)
         {
            if(OrderStopLoss()==0 || OrderTakeProfit()==0)
            { 
               ticket=OrderTicket(); 
               while (!IsTradeAllowed()) Sleep(500); 
               RefreshRates();
                       
               SelectLastHistoryOrder(Symbol(), magicNumber);
         
               if(!noHistory)
               {
            
                  if(OrderProfit()<0)  
                  {
                     loss=MathAbs(OrderClosePrice()-OrderOpenPrice());
                     sl=Ask-(loss)*distanceMultiplier;
                     tp=Ask+(loss)*distanceMultiplier;
                  }
                  else
                  {
                     sl = Ask-stopLoss; 
                     tp = Ask+takeProfit;
                  }
               } 
               else
               {
                  sl = Ask-stopLoss; 
                  tp = Ask+takeProfit;
               } 
         
               if(Bid-sl<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)
                  sl = Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;

               if(tp-Bid<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)
                  tp = Bid+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
               
               // last selected is from history so we have to select trade again   
               if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
                  return(false);
               
               if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,Green)) // modify position
               {
               }
               else
                  return (false);
            }
         }   
         if(OrderType()==OP_SELL)
         {
            if(OrderStopLoss()==0 && OrderTakeProfit()==0)
            {
               ticket=OrderTicket();         
               while (!IsTradeAllowed()) Sleep(500); 
               RefreshRates();  
         
               SelectLastHistoryOrder(Symbol(), magicNumber);
                  
               if(!noHistory)
               {
            
                  if(OrderProfit()<0)
                  {
                     loss=MathAbs(OrderClosePrice()-OrderOpenPrice());
                     sl=Bid+(loss)*distanceMultiplier;
                     tp=Bid-(loss)*distanceMultiplier;
                  }
                  else
                  {                            
                     sl = Bid+stopLoss;
                     tp = Bid-takeProfit;  
                  }
               }  
               else
               {                            
                  sl = Bid+stopLoss;
                  tp = Bid-takeProfit;  
               }
         
               if(sl-Ask<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)
                  sl = Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;

               if(Ask-tp<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point)
                  tp = Ask-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;                
               
               // last selected is from history so we have to select trade again    
               if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
                  return(false);
               
               if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,Green)) // modify position
               {
               }
               else
                  return (false);
            }
         } 
      }
   }
   return (true);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
bool OpenOrderCheck()
{
   double olots=lots;
   int ticket;
   int total=OpenTradesForMNandPairType(magicNumber, Symbol());
   
   if(total==0)
   {
      // check for long position (BUY) possibility     
      if(EnterBuyCondition())
      {              
               if(!noHistory)
               {
                  SelectLastHistoryOrder(Symbol(), magicNumber);
                  if(OrderProfit()<0)  
                  {
                     olots=OrderLots()*lotsMultiplier;
                  }
               } 

         while (!IsTradeAllowed()) Sleep(500); 
         RefreshRates();
         
         ticket=OrderSend(Symbol(),OP_BUY,olots,Ask,maxSlippage, 0,0,"",magicNumber,0,Green);
         if(ticket>0)
         {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
            {
               stopsChecked = false;
               Print("BUY order opened : ",OrderOpenPrice());
               return (true);
            }
         }
         else 
         {
            Print("Error opening BUY order : ",GetLastError());   
            return(false);
         }
   
      }
      
      // check for short position (SELL) possibility
      if(EnterSellCondition())     // OrderSelect() was in function EnterBuyCondition
      {  
               if(!noHistory)
               {
                  SelectLastHistoryOrder(Symbol(), magicNumber);
                  if(OrderProfit()<0)
                  {
                     olots=OrderLots()*lotsMultiplier;
                  }
               } 
               
         while (!IsTradeAllowed()) Sleep(500); 
         RefreshRates();  
         
         ticket=OrderSend(Symbol(),OP_SELL,olots,Bid,maxSlippage, 0,0,"",magicNumber,0,Red);
         if(ticket>0)
         {               
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
            { 
               stopsChecked = false;
               Print("SELL order opened : ",OrderOpenPrice());
               return (true);
            }
         }
         else 
         {
            Print("Error opening SELL order : ",GetLastError());
            return (false); 
         }
      }
   }
   return (true);   
}

//////////////////////////////////////////////////////////////////////////////////////////////////
int OpenTradesForMNandPairType(int iMN, string sOrderSymbol)
{
   int icnt, itotal, retval;

   retval=0;
   itotal=OrdersTotal();

      for(icnt=itotal-1;icnt>=0;icnt--) // for loop
      {
         OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES);
         // check for opened position, symbol & MagicNumber
         if (OrderSymbol()== sOrderSymbol)
         {
            if (OrderMagicNumber()==iMN) 
               retval++;             
         } // sOrderSymbol
      } // for loop

   return(retval);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double ProfitCheck()
{
   double profit=0;
   int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if (OrderSymbol()==Symbol() && (OrderMagicNumber() == magicNumber))
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
     
     ObjectSetText(	"name", "PURE MARTINGALE", font+1, "Arial",menuColor);
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
         if (OrderSymbol()==Symbol() && (OrderMagicNumber() == magicNumber))
             if(OrderType()==OP_BUY || OrderType()==OP_SELL)
               count++;
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
         if (OrderSymbol()==Symbol() && (OrderMagicNumber() == magicNumber))
             if(OrderType()==OP_BUY || OrderType()==OP_SELL)
               lots+=OrderLots();
      }
    return (lots);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool SelectLastHistoryOrder(string symbol, int magicNumber)
{
   int lastOrder=NULL;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
      OrderSelect(i, SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()==symbol && OrderMagicNumber()==magicNumber)
      {
         lastOrder=i;
         break;
      }
   } 
   if(lastOrder==NULL)
      return(false);
   else
      return(true); 
}

//////////////////////////////////////////////////////////////////////////////////////////////////
int HistoryForMNandPT(int iMN, string sOrderSymbol)
{
   int icnt, itotal, retval;

   retval=0;
   itotal=OrdersHistoryTotal();

      for(icnt=itotal-1;icnt>=0;icnt--) // for loop
      {
         OrderSelect(icnt, SELECT_BY_POS, MODE_HISTORY);
         // check for opened position, symbol & MagicNumber
         if (OrderSymbol()== sOrderSymbol)
         {
            if (OrderMagicNumber()==iMN) 
               retval++;             
         } // sOrderSymbol
      } // for loop

   return(retval);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool TradingTime()
{
   datetime start, stop, start1, stop1;
   
   start = StrToTime(StringConcatenate(Year(),".",Month(),".",Day()," ",StartTime))+GMT_Offset*3600;
   stop = StrToTime(StringConcatenate(Year(),".",Month(),".",Day()," ",StopTime))+GMT_Offset*3600;
   
   start1=start;
   stop1=stop;
      
   if(stop <= start) 
   {
      stop1 += 86400;
      start -= 86400;
   }
      
   if((TimeCurrent() >= start && TimeCurrent() < stop) || (TimeCurrent() >= start1 && TimeCurrent() < stop1))
   {
      return(true);
   }
   
   return(false);
}
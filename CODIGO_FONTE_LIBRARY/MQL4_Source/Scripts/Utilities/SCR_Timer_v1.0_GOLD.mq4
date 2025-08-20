//+------------------------------------------------------------------+
#property copyright "Copyright © 2013 Matus German www.MTexperts.net"

extern double    magicNumber           = 76813524;
extern string    separator1            = "------ Timer settings ------";
extern int       WaitSeconds           = 3;
extern double    PipDistance           = 0;  
extern int       AtrPeriod             = 5;
extern bool      Reverse               = False;
extern bool      Stop_Limit            = False;
 
extern string    separator2            = "------ SL TP settings ------";
extern double    StopLoss              = 20;
extern double    TakeProfit            = 150;
extern bool      UseTrailingStop       = true;
extern double    TrailingStop          = 10;

extern string    separator3            = "------ MM settings ------"; 
extern double    Lots                  = 0.1;
extern bool      UseMM                 = true;
extern double    Risk                  = 1;
extern int       MaxTrades             = 2;                    // max trades allowed for pyramiding
 double    MaxSlippage           = 5;   


extern string  separator6              =  "------ Trading Hours ------";
extern bool    UseTradingHours         = false;
extern string  StartTime               = "06:00";
extern string  StopTime                = "22:00";
 int     GMT_Offset              = 0;

extern string   separator9             = "------ Wiew settings ------";
extern bool      ShowMenu               = true;
extern int       MenuCorner             = 1;
extern color     FontColor              = White; 
extern int       FontSize               = 10;

int error;

datetime barTime, waiting=0, startTime;

double   profit, atr, 
         pipDistance, 
         stopLoss, takeProfit, trailingStop,
         pips2dbl, pips2point, pipValue, minGapStop,
         lots,
         buyLevel, sellLevel,
         LowStop, HighStop,
         minAllowedLot, lotStep, maxAllowedLot,
         maxSlippage;

bool     trade=true,
         clearBuy, clearSell,
         sellBE, buyBE, 
         exitBuy, exitSell;

int   medzera = 8,
      trades,
      lotDecimals;

double menulots;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   Comment("Copyright © 2013 Matus German www.MTexperts.net");

   if (Digits == 5 || Digits == 3)    // Adjust for five (5) digit brokers.
   {            
      pips2dbl = Point*10; pips2point = 10; pipValue = (MarketInfo(Symbol(),MODE_TICKVALUE))*10;
   } 
   else 
   {    
      pips2dbl = Point;   pips2point = 1; pipValue = (MarketInfo(Symbol(),MODE_TICKVALUE))*1;
   }
   
   lots = Lots;
   pipDistance = PipDistance*pips2dbl;
   stopLoss = StopLoss*pips2dbl;
   takeProfit = TakeProfit*pips2dbl;
   trailingStop = TrailingStop*pips2dbl;
   maxSlippage=MaxSlippage*pips2dbl;
   
   minGapStop = MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;
   
   minAllowedLot  =  MarketInfo(Symbol(), MODE_MINLOT);    //IBFX= 0.10
   lotStep        =  MarketInfo(Symbol(), MODE_LOTSTEP);   //IBFX= 0.01
   maxAllowedLot  =  MarketInfo(Symbol(), MODE_MAXLOT );   //IBFX=50.00

   lotDecimals=0;
   double lotStepS=lotStep;
   while(MathMod(lotStepS,1)>0)
   {
      lotStepS*=10;
      lotDecimals++;
   } 

   if(lots < minAllowedLot)
      lots = minAllowedLot;
   if(lots > maxAllowedLot)
      lots = maxAllowedLot;
   
   ObjectCreate("buyLevel", OBJ_HLINE, 0, TimeCurrent(), buyLevel);
   ObjectSet("buyLevel", OBJPROP_BACK, true);
   ObjectSet("buyLevel", OBJPROP_COLOR, Yellow);
   ObjectCreate("sellLevel", OBJ_HLINE, 0, TimeCurrent(), sellLevel); 
   ObjectSet("sellLevel", OBJPROP_BACK, true);
   ObjectSet("sellLevel", OBJPROP_COLOR, Yellow);
   
   if(ShowMenu)
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
   ObjectDelete("buyLevel");
   ObjectDelete("sellLevel");
   
   if(ShowMenu)
   {
      ObjectDelete("nameEMAWPR");
      ObjectDelete("OpenEMAWPRl");
      ObjectDelete("OpenEMAWPR");
      ObjectDelete("LotsEMAWPRl");
      ObjectDelete("LotsEMAWPR");
      ObjectDelete("ProfitEMAWPRl");
      ObjectDelete("ProfitEMAWPR");
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   profit = ProfitCheck(); 
   if(ShowMenu)
   {
      ReDrawMenu();
   }
   if(ObjectFind("buyLevel")==-1)
   {
      ObjectCreate("buyLevel", OBJ_HLINE, 0, TimeCurrent(), buyLevel);
      ObjectSet("buyLevel", OBJPROP_BACK, true);
      ObjectSet("buyLevel", OBJPROP_COLOR, Yellow);
      MoveLevels();
   }
   if(ObjectFind("sellLevel")==-1)
   {
      ObjectCreate("sellLevel", OBJ_HLINE, 0, TimeCurrent(), sellLevel); 
      ObjectSet("sellLevel", OBJPROP_BACK, true);
      ObjectSet("sellLevel", OBJPROP_COLOR, Yellow);
      MoveLevels();
   }
   
   if(UseTradingHours)
   {
      if(TradingTime())
      {
         trade=true;
      }
      else
      {
         trade=false;
      }    
   }
   
   if(IsNewBar())
   {
      buyBE=true;
      sellBE=true;
   }
   CalculateIndicators();
   
   if(!CheckStops())
      return;  
          
   if(UseTrailingStop)
      if(!TrailingStopCheck())
         return;
         
   CheckTime();
   
   int total=Opened();

   if(trade && total<MaxTrades)  
   {
      if(Reverse)
      {
         if(Stop_Limit)
         {
            while(clearBuy)
            {
               if(!ClosePending(Symbol(), "buy"))
                  return;
                  
               if(OpenOrder(Symbol(), OP_BUYLIMIT, sellLevel, CalculateLots()))
               {
                  Print("BUY order opened : ",OrderOpenPrice());
                  startTime = TimeCurrent();
                  buyBE=false;
                  MoveLevels();
                  clearBuy=false;
               }
               else
                  return;
            }
            while(clearSell)
            {
               if(!ClosePending(Symbol(), "sell"))
                  return;
                  
               if(OpenOrder(Symbol(), OP_SELLLIMIT, buyLevel, CalculateLots()))
               {
                  Print("BUY order opened : ",OrderOpenPrice());
                  startTime = TimeCurrent();
                  sellBE=false;
                  MoveLevels();
                  clearSell=false;
               }
               else
                  return;
            }
         }
         else
         {
            if(Ask<=sellLevel && buyBE)
               if(OpenOrder(Symbol(), OP_BUY, 0, CalculateLots()))
               {
                  Print("BUY order opened : ",OrderOpenPrice());
                  startTime = TimeCurrent();
                  buyBE=false;
                  MoveLevels();
               }
               
            if(Bid>=buyLevel && sellBE)
               if(OpenOrder(Symbol(), OP_SELL, 0, CalculateLots()))
               {
                  Print("SELL order opened : ",OrderOpenPrice());
                  startTime = TimeCurrent();
                  MoveLevels(); 
                  sellBE=false; 
               }
         }
      }
      else
      {
         if(Stop_Limit)
         {
            while(clearBuy)
            {
               if(!ClosePending(Symbol(), "buy"))
                  return;
                  
               if(OpenOrder(Symbol(), OP_BUYSTOP, buyLevel, CalculateLots()))
               {
                  Print("BUY order opened : ",OrderOpenPrice());
                  startTime = TimeCurrent();
                  buyBE=false;
                  MoveLevels();
                  clearBuy=false;
               }
               else
                  return;
            }
                  
            while(clearSell)
            {
               if(!ClosePending(Symbol(), "sell"))
                  return;
                  
               if(OpenOrder(Symbol(), OP_SELLSTOP, sellLevel, CalculateLots()))
               {
                  Print("BUY order opened : ",OrderOpenPrice());
                  startTime = TimeCurrent();
                  sellBE=false;
                  MoveLevels();
                  clearSell=false;
               }
               else
                  return;
            }
            
         }
         else
         {
            if(Ask>=buyLevel && buyBE)
               if(OpenOrder(Symbol(), OP_BUY, 0, CalculateLots()))
               {
                  Print("BUY order opened : ",OrderOpenPrice());
                  startTime = TimeCurrent();
                  buyBE=false;
                  MoveLevels();
               }
               
            if(Bid<=sellLevel && sellBE)
               if(OpenOrder(Symbol(), OP_SELL, 0, CalculateLots()))
               {
                  Print("SELL order opened : ",OrderOpenPrice());
                  startTime = TimeCurrent();
                  MoveLevels(); 
                  sellBE=false; 
               }
         }
      }
   }   
   else
   {
      ClosePending(Symbol(), magicNumber);
   }     
      
   return(0);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// calculate indicator variables
void CalculateIndicators()
{
   atr = iATR(NULL, 0, AtrPeriod, 1);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// chceck trades if they do not have set sl and tp than modify trade
bool CheckStops()
{
   double sl=0, tp=0;
   double total=OrdersTotal();
   
   int ticket=-1;
   
   for(int cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(   OrderType()<=OP_SELL                      
         && OrderSymbol()==Symbol()                  
         && OrderMagicNumber() == magicNumber)        
      {
         if(OrderType()==OP_BUY)
         {
            if((OrderStopLoss()==0 && stopLoss>0) || (OrderTakeProfit()==0 && takeProfit>0))
            {  
               while (!IsTradeAllowed()) Sleep(500); 
               RefreshRates();
               
               if(OrderStopLoss()==0 && stopLoss>0)
               {
                  sl = OrderOpenPrice()-stopLoss; 
                  if(Bid-sl<=minGapStop)
                     sl = Bid-minGapStop*2;
               }
               else
                  sl = OrderStopLoss();
               
               if(OrderTakeProfit()==0 && takeProfit>0)   
               {
                  tp = OrderOpenPrice()+takeProfit;
                  if(tp-Bid<=minGapStop)
                     tp = Bid+minGapStop*2;
               }
               else
                  tp = OrderTakeProfit();
                     
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,Green)) 
                  return (false);
            }
         }   
         if(OrderType()==OP_SELL)
         {
            if((OrderStopLoss()==0 && stopLoss>0) || (OrderTakeProfit()==0 && takeProfit>0))
            {        
               while (!IsTradeAllowed()) Sleep(500); 
               RefreshRates();  
               
               if(OrderStopLoss()==0 && stopLoss>0)    
               {        
                  sl = OrderOpenPrice()+stopLoss;         
                  if(sl-Ask<=minGapStop)
                     sl = Ask+minGapStop*2;              
               }
               else
                  sl = OrderStopLoss();
               
               if(OrderTakeProfit()==0 && takeProfit>0)
               {
                  tp = OrderOpenPrice()-takeProfit;               
                  if(Ask-tp<=minGapStop)
                     tp = Ask-minGapStop*2;
               }
               else
                  tp = OrderTakeProfit();
                       
               if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,Green)) 
                  return (false);
            }
         } 
      }
   }
   return (true);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// trailing stop function
bool TrailingStopCheck()
{  
   double newStopLoss;
   int total=OrdersTotal();
   for(int cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == magicNumber)
      {
         if(OrderType()==OP_BUY)
         {
            newStopLoss = Bid-trailingStop;                   
            if(newStopLoss>OrderOpenPrice() && newStopLoss>OrderStopLoss()+trailingStop)
            {
               while (!IsTradeAllowed()) Sleep(500);
               RefreshRates();
               if(OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),0,Green)) // modify position
               {
                   return (true);
               }
               else 
               {     
                  error = GetLastError();
                  Print("Error modify BUY order : ",ErrorDescription(error));   
                  return(false);
               } 
            } 
         }
         if(OrderType()==OP_SELL)
         {
            // should it be modified? 
            newStopLoss = Ask+trailingStop;        
            if(newStopLoss<OrderOpenPrice() && newStopLoss<OrderStopLoss()-trailingStop)
            {
               while (!IsTradeAllowed()) Sleep(500);
               RefreshRates();
               if(OrderModify(OrderTicket(),OrderOpenPrice(),newStopLoss,OrderTakeProfit(),0,Green)) // modify position
               {
                  return (true);
               }
               else 
               {     
                  error = GetLastError();
                  Print("Error modify SELL order : ",ErrorDescription(error));   
                  return(false);
               } 
            }          
         }
      }
   }
   return (true);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// checking time, after waitSeconds move levels of signals to new positions
void CheckTime()
{
   if(TimeCurrent()-WaitSeconds>waiting)
   {
      waiting = TimeCurrent();
      MoveLevels();
   } 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// moving levels for buy and sell signals
void MoveLevels()
{
   RefreshRates();
   buyLevel = Ask+pipDistance+atr;
   sellLevel = Bid-pipDistance-atr;
   ObjectSet("buyLevel", OBJPROP_PRICE1, buyLevel);
   ObjectSet("sellLevel", OBJPROP_PRICE1, sellLevel);
   if(buyBE)
      clearBuy=true;
   if(sellBE)
      clearSell=true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// calculation lots if it is set useMM=true it calculates Lot amount from the StopLoss setting
double CalculateLots()
{
   double ilo;
   double equity = AccountEquity();
   
   if(StopLoss<=0)
   {
      ilo = ((equity*(Risk/100))/(50*pipValue));
      lots = NormalizeDouble(ilo,1);
   }
   else
   {
      ilo = ((equity*(Risk/100))/(StopLoss*pipValue));
      lots = NormalizeDouble(ilo,1);
   }
   ilo=NormalizeDouble(ilo,lotDecimals);
   if(ilo < minAllowedLot)
      ilo = minAllowedLot;
   if(ilo > maxAllowedLot)
      ilo = maxAllowedLot; 
      
   return (ilo); 
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
// printing errors in Journal
string ErrorDescription(int error)
{
   string err;
   switch(error)
   {
      case	0	:err="No error returned."; break;
      case	1	:err="No error returned, but the result is unknown."; break;
      case	2	:err="Common error."; break;
      case	3	:err="Invalid trade parameters."; break;
      case	4	:err="Trade server is busy."; break;
      case	5	:err="Old version of the client terminal."; break;
      case	6	:err="No connection with trade server."; break;
      case	7	:err="Not enough rights."; break;
      case	8	:err="Too frequent requests."; break;
      case	9	:err="Malfunctional trade operation."; break;
      case	64	:err="Account disabled."; break;
      case	65	:err="Invalid account."; break;
      case	128	:err="Trade timeout."; break;
      case	129	:err="Invalid price."; break;
      case	130	:err="Invalid stops."; break;
      case	131	:err="Invalid trade volume."; break;
      case	132	:err="Market is closed."; break;
      case	133	:err="Trade is disabled."; break;
      case	134	:err="Not enough money."; break;
      case	135	:err="Price changed."; break;
      case	136	:err="Off quotes."; break;
      case	137	:err="Broker is busy."; break;
      case	138	:err="Requote."; break;
      case	139	:err="Order is locked."; break;
      case	140	:err="Long positions only allowed."; break;
      case	141	:err="Too many requests."; break;
      case	145	:err="Modification denied because order too close to market."; break;
      case	146	:err="Trade context is busy."; break;
      case	147	:err="Expirations are denied by broker."; break;
      case	148	:err="The amount of open and pending orders has reached the limit set by the broker."; break;
      case	149	:err="An attempt to open a position opposite to the existing one when hedging is disabled."; break;
      case	150	:err="An attempt to close a position contravening the FIFO rule."; break;

      case	4000	:err="No error."; break;
      case	4001	:err="Wrong function pointer."; break;
      case	4002	:err="Array index is out of range."; break;
      case	4003	:err="No memory for function call stack."; break;
      case	4004	:err="Recursive stack overflow."; break;
      case	4005	:err="Not enough stack for parameter."; break;
      case	4006	:err="No memory for parameter string."; break;
      case	4007	:err="No memory for temp string."; break;
      case	4008	:err="Not initialized string."; break;
      case	4009	:err="Not initialized string in array."; break;
      case	4010	:err="No memory for array string."; break;
      case	4011	:err="Too long string."; break;
      case	4012	:err="Remainder from zero divide."; break;
      case	4013	:err="Zero divide."; break;
      case	4014	:err="Unknown command."; break;
      case	4015	:err="Wrong jump (never generated error)."; break;
      case	4016	:err="Not initialized array."; break;
      case	4017	:err="DLL calls are not allowed."; break;
      case	4018	:err="Cannot load library."; break;
      case	4019	:err="Cannot call function."; break;
      case	4020	:err="Expert function calls are not allowed."; break;
      case	4021	:err="Not enough memory for temp string returned from function."; break;
      case	4022	:err="System is busy (never generated error)."; break;
      case	4050	:err="Invalid function parameters count."; break;
      case	4051	:err="Invalid function parameter value."; break;
      case	4052	:err="String function internal error."; break;
      case  4053	:err="Some array error."; break;
      case	4054	:err="Incorrect series array using."; break;
      case	4055	:err="Custom indicator error."; break;
      case	4056	:err="Arrays are incompatible."; break;
      case	4057	:err="Global variables processing error."; break;
      case	4058	:err="Global variable not found."; break;
      case	4059	:err="Function is not allowed in testing mode."; break;
      case	4060	:err="Function is not confirmed."; break;
      case	4061	:err="Send mail error."; break;
      case	4062	:err="String parameter expected."; break;
      case	4063	:err="Integer parameter expected."; break;
      case	4064	:err="Double parameter expected."; break;
      case	4065	:err="Array as parameter expected."; break;
      case	4066	:err="Requested history data in updating state."; break;
      case	4067	:err="Some error in trading function."; break;
      case	4099	:err="End of file."; break;
      case	4100	:err="Some file error."; break;
      case	4101	:err="Wrong file name."; break;
      case	4102	:err="Too many opened files."; break;
      case	4103	:err="Cannot open file."; break;
      case	4104	:err="Incompatible access to a file."; break;
      case	4105	:err="No order selected."; break;
      case	4106	:err="Unknown symbol."; break;
      case	4107	:err="Invalid price."; break;
      case	4108	:err="Invalid ticket."; break;
      case	4109	:err="Trade is not allowed. Enable checkbox \"Allow live trading\" in the expert properties."; break;
      case	4110	:err="Longs are not allowed. Check the expert properties."; break;
      case	4111	:err="Shorts are not allowed. Check the expert properties."; break;
      case	4200	:err="Object exists already."; break;
      case	4201	:err="Unknown object property."; break;
      case	4202	:err="Object does not exist."; break;
      case	4203	:err="Unknown object type."; break;
      case	4204	:err="No object name."; break;
      case	4205	:err="Object coordinates error."; break;
      case	4206	:err="No specified subwindow."; break;
      case	4207	:err="Some error in object function."; break;
   }
   return(err);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// returning true on first tick of new bar
bool IsNewBar()
{
   if( barTime < Time[0]) 
   {
        // we have a new bar opened
      barTime = Time[0];
      return(true);
   }
   return (false);
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
     
     ObjectSetText(	"name", "Timer", FontSize+1, "Arial",FontColor);
     ObjectSet("name",OBJPROP_XDISTANCE,medzera*FontSize);     
     ObjectSet("name",OBJPROP_YDISTANCE,10+FontSize);
     ObjectSet("name",OBJPROP_CORNER,MenuCorner);
         
     ObjectSetText("Openl", "Opened: ", FontSize, "Arial",FontColor);
     ObjectSet("Openl",OBJPROP_XDISTANCE,medzera*FontSize);     
     ObjectSet("Openl",OBJPROP_YDISTANCE,10+2*(FontSize+2));
     ObjectSet("Openl",OBJPROP_CORNER,MenuCorner);
     
     ObjectSetText("Open", ""+trades, FontSize, "Arial",FontColor);
     ObjectSet("Open",OBJPROP_XDISTANCE,3*FontSize);     
     ObjectSet("Open",OBJPROP_YDISTANCE,10+2*(FontSize+2));
     ObjectSet("Open",OBJPROP_CORNER,MenuCorner);
     
     ObjectSetText("Lotsl", "Lots: ", FontSize, "Arial",FontColor);
     ObjectSet("Lotsl",OBJPROP_XDISTANCE,medzera*FontSize);     
     ObjectSet("Lotsl",OBJPROP_YDISTANCE,10+3*(FontSize+2));
     ObjectSet("Lotsl",OBJPROP_CORNER,MenuCorner);
     
     ObjectSetText("Lots", DoubleToStr(menulots,2), FontSize, "Arial",FontColor);
     ObjectSet("Lots",OBJPROP_XDISTANCE,3*FontSize);     
     ObjectSet("Lots",OBJPROP_YDISTANCE,10+3*(FontSize+2));
     ObjectSet("Lots",OBJPROP_CORNER,MenuCorner);
     
     ObjectSetText("Profitl", "Profit: ", FontSize, "Arial",FontColor);
     ObjectSet("Profitl",OBJPROP_XDISTANCE,medzera*FontSize);     
     ObjectSet("Profitl",OBJPROP_YDISTANCE,10+4*(FontSize+2));
     ObjectSet("Profitl",OBJPROP_CORNER,MenuCorner);
     
     ObjectSetText("Profit", DoubleToStr(profit,2), FontSize, "Arial",FontColor);
     ObjectSet("Profit",OBJPROP_XDISTANCE,3*FontSize);     
     ObjectSet("Profit",OBJPROP_YDISTANCE,10+4*(FontSize+2));
     ObjectSet("Profit",OBJPROP_CORNER,MenuCorner);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
bool ReDrawMenu()
{
      medzera = 8;
       
      trades = Opened();
      menulots = Lots();
     
     ObjectSetText("Open", ""+trades, FontSize, "Arial",FontColor); 
     ObjectSetText("Lots", DoubleToStr(menulots,2), FontSize, "Arial",FontColor);    
     ObjectSetText("Profit", DoubleToStr(profit,2), FontSize, "Arial",FontColor);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int Opened()
{
    int total  = OrdersTotal();
    int count = 0;
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && (OrderMagicNumber() == magicNumber))
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

//////////////////////////////////////////////////////////////////////////////////////////////////
bool OpenOrder(string symbol, int orderType, double Price, double olots)
{
   int ticket;
   {           
         while (!IsTradeAllowed()) Sleep(300); 
         
         if(orderType==OP_BUY)
         {
            ticket=OrderSend(symbol, OP_BUY, olots, MarketInfo(symbol, MODE_ASK),maxSlippage, 0,0,"Timer",magicNumber,0,Green);
         }
         else if(orderType==OP_SELL)
         {
            ticket=OrderSend(symbol, OP_SELL, olots, MarketInfo(symbol, MODE_BID),maxSlippage, 0,0,"Timer",magicNumber,0,Red);
         }
         else if(orderType==OP_BUYSTOP || orderType==OP_BUYLIMIT)
         {
            ticket=OrderSend(symbol, orderType, olots, Price,maxSlippage, 0,0,"Timer",magicNumber,0,Green);
         }
         else if(orderType==OP_SELLSTOP || orderType==OP_SELLLIMIT)
         {
            ticket=OrderSend(symbol, orderType, olots, Price,maxSlippage, 0,0,"Timer",magicNumber,0,Red);
         }       
                
         if(ticket>0)
         {
            return(true);              
         }
         else 
         {
            return(false);
         }
   }
   return (false);   
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
bool ClosePending(string symbol, string type)
{
    int total  = OrdersTotal();
      for (int cnt = total-1 ; cnt >=0 ; cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if (OrderSymbol()==symbol && OrderMagicNumber() == magicNumber)
         {
            if(type=="buy")
               if(OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT)
                  if(!OrderDelete(OrderTicket()))
                  { 
                     Print("Error deleting " + OrderType() + " order : ",GetLastError());
                     return (false);
                  }
            if(type=="sell")
               if(OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT)
                  if(!OrderDelete(OrderTicket()))
                  { 
                     Print("Error deleting " + OrderType() + " order : ",GetLastError());
                     return (false);
                  }
         }
      }
      return (true);
}
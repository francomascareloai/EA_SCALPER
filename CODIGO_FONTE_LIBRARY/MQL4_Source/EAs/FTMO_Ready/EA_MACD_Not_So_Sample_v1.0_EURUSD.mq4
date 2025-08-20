//+------------------------------------------------------------------+
//|                                           MACD_Not_So_Sample.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#define MagicNum  10701
//-----
extern int     fast           = 47;//12;
extern int     slow           = 166;//26;
extern int     sign           = 11;//9;
extern double  TrailingStop   = 19;//30;
extern double  MATrendPeriod  = 8;//26;
extern double  MACDOpenLevel  = 1;//3;
extern double  MACDCloseLevel = 3;//2;
//-----
extern double  TakeProfit     = 550;
extern bool    UseMM          = false;
extern int     PercentMM      = 10;
extern double  Lots           = 0.1;
//+------------------------------------------------------------------+
double GetLots()
 { 
   if (UseMM)
    {
      double a;
      a = NormalizeDouble((PercentMM * AccountFreeMargin() / 100000), 1);      
      if(a > 49.9) return(49.9);
      else if(a < 0.1)
       {
         Print("Lots < 0.1");
         return(0);
       }
      else return(a);
    }    
   else return(Lots);
 }
//+------------------------------------------------------------------+ 
int CalculateCurrentOrders()
 {
   int orderT = OrdersTotal(), buys = 0, sells = 0;
   //----
   for(int i = 0; i < orderT; i++)
    {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNum)
       {
         if(OrderType() == OP_BUY)  buys++;
         if(OrderType() == OP_SELL) sells++;
       }
    }
   if(buys > 0) return(buys);
   else if(sells > 0) return(-sells);
   else return(0);
 }
//+------------------------------------------------------------------+  
int start()
 {
   if (Symbol() != "EURUSD")
    {
		Comment("Not a right Symbol: ", Symbol(), " <>  EURUSD");
		return(0);
	 }                           
   if (Period() != 240)
    {
		Comment("Not a right Period!!! It should be H4");
		return(0);	
	 }
	//==================================================
   double MacdCurrent, MacdPrevious, SignalCurrent, SignalPrevious, MaCurrent, MaPrevious;
   int cnt, ticket, total;
   //-----
   if(Bars < 100)
    {
      Print("Bars less than 100");
      return(0);  
    }
   if(TakeProfit < 10)
    {
      Print("TakeProfit less than 10");
      return(0); 
    }
   //------
   MacdCurrent = iMACD(NULL, 0, fast, slow, sign, PRICE_CLOSE, MODE_MAIN, 0);
   MacdPrevious = iMACD(NULL, 0, fast, slow, sign, PRICE_CLOSE, MODE_MAIN, 1);
   SignalCurrent = iMACD(NULL, 0, fast, slow, sign, PRICE_CLOSE, MODE_SIGNAL, 0);
   SignalPrevious = iMACD(NULL,0,fast, slow, sign, PRICE_CLOSE, MODE_SIGNAL, 1);
   MaCurrent = iMA(NULL, 0, MATrendPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   MaPrevious = iMA(NULL, 0, MATrendPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   //-----   
   if(CalculateCurrentOrders() == 0) 
    {
      if(AccountFreeMargin() < (1000 * GetLots()))
       {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
       }
      if(MacdCurrent < 0 && MacdCurrent > SignalCurrent && MacdPrevious < SignalPrevious && MathAbs(MacdCurrent) > (MACDOpenLevel*Point) && MaCurrent > MaPrevious)
       {
         ticket=OrderSend(Symbol(), OP_BUY, GetLots(), Ask, 3, 0, Ask + TakeProfit * Point, "macd not sample", MagicNum, 0, Green);
         if(ticket>0)
          {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
          }
         else Print("Error opening BUY order : ", GetLastError()); 
         return(0); 
       }
      if(MacdCurrent > 0 && MacdCurrent < SignalCurrent && MacdPrevious > SignalPrevious && MacdCurrent > (MACDOpenLevel * Point) && MaCurrent < MaPrevious)
       {
         ticket=OrderSend(Symbol(), OP_SELL, GetLots(), Bid, 3, 0, Bid - TakeProfit * Point, "macd not sample", MagicNum, 0, Red);
         if(ticket > 0)
          {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
          }
         else Print("Error opening SELL order : ", GetLastError()); 
         return(0); 
        }
      return(0);
    }
   //====================================================================================================  
   total = OrdersTotal(); 
   for(cnt = 0; cnt < total; cnt++)
    {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNum)
       {
         if(OrderType() == OP_BUY)
          {
            if(MacdCurrent > 0 && MacdCurrent < SignalCurrent && MacdPrevious > SignalPrevious && MacdCurrent > (MACDCloseLevel * Point))
             {
               OrderClose(OrderTicket(), OrderLots(), Bid, 3, Violet);
               return(0);
             }
            //------------------
            if(TrailingStop > 0)  
             {                 
               if(Bid - OrderOpenPrice() > Point * TrailingStop)
                {
                  if(OrderStopLoss() < Bid - Point * TrailingStop)
                   {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * TrailingStop, OrderTakeProfit(), 0, Green);
                     return(0);
                   }
                }
             }
          }
         else
          {
            if(MacdCurrent < 0 && MacdCurrent>SignalCurrent && MacdPrevious < SignalPrevious && MathAbs(MacdCurrent) > (MACDCloseLevel * Point))
             {
               OrderClose(OrderTicket(), OrderLots(), Ask, 3, Violet);
               return(0);
             }
            //------------------
            if(TrailingStop > 0)  
             {                 
               if((OrderOpenPrice() - Ask) > (Point * TrailingStop))
                {
                  if((OrderStopLoss() > (Ask + Point * TrailingStop)) || (OrderStopLoss() == 0))
                   {
                     OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TrailingStop, OrderTakeProfit(), 0, Red);
                     return(0);
                   }
                }
             }
          }
       }
    }
   return(0);
 }
//+------------------------------------------------------------------+
//| PZ_ParabolicSar_EA.mq4
//| Copyright © http://www.pointzero-trading.com"
//+------------------------------------------------------------------+
#property copyright "Copyright © http://www.pointzero-trading.com"
#property link      "http://www.pointzero-trading.com"

//---- Dependencies
#import "stdlib.ex4"
   string ErrorDescription(int e);
#import

//---- Constants
#define  ShortName         "PZ Parabolic Sar EA"
#define  StopDivisor       1
#define  PercentageToClose 0.50
#define  Shift             1

//---- External variables
extern string TL_Ex                    = "------- Hour settings: set to zero for no limitations";
extern int    StartHour                = 00;
extern int    StartMinute              = 30;
extern int    EndHour                  = 23;
extern int    EndMinute                = 30;
extern string PS_Ex                    = "------- Parabolic SAR Settings";
extern string PS_Ex2                   = ">> Entry strategy";
extern double TradeStep                = 0.002;
extern double TradeMax                 = 0.2;
extern string PS_Ex3                   = ">> Exit strategy";
extern double StopStep                 = 0.004;
extern double StopMax                  = 0.4;              
extern string SL_Ex                    = "------- Stop-loss Settings";
extern int    ATRPeriod                = 30;
extern double ATRMultiplier            = 2.5;
extern string TS_Ex                    = "------- Trailing-Stop Settings";
extern bool   TS_Enabled               = false;
extern double TSATRPeriod              = 30;
extern double TSATRMultiplier          = 1.75;
extern string BE_Ex2                   = "------- Partial Closing and Break Even";
extern bool   PartialClosing           = true;
extern bool   BreakEven                = true;
extern string MM_Ex                    = "------- Money management";
extern bool   MoneyManagement          = true;
extern double RiskPercent              = 2;
extern double LotSize                  = 0.1;
extern string EA_Ex                    = "------- EA Settings";
extern int    Slippage                 = 5;
extern int    MagicNumber              = 12345;

//---- Internal
double   DecimalPip;

//---- Last trade data
int      LastOrderTicket[2];
datetime LastOrderTime[2];
double   LastOrderLots[2];

//+------------------------------------------------------------------+
//| Custom EA initialization function
//+------------------------------------------------------------------+
int init()
{
   // Pips and time settings
   DecimalPip = GetDecimalPip();
   LastOrderTime[OP_BUY] = 0;
   LastOrderTime[OP_SELL] = 0;
   
   // Hi there
   Comment("Copyright © http://www.pointzero-trading.com");
   
   // Bye
   return(0);
}

//+------------------------------------------------------------------+
//| Custom EA deinit function
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom EA start function
//+------------------------------------------------------------------+
int start()
{   
   // Break even 
   if(PartialClosing) BreakEvenTrades();
   
   // Hours 
   int hour = TimeHour(TimeCurrent());
   int minute = TimeMinute(TimeCurrent());
   
   // Dont run out of time
   if(!((StartHour == 0 && EndHour == 0) || (hour >= StartHour && hour <= EndHour)) ||
      (StartMinute > 0 && hour == StartHour && minute < StartMinute) ||
      (EndMinute > 0 && hour == EndHour && minute > EndMinute)) { return(0); }
   
   // Is bar closed 
   bool barclosed = IsBarClosed(0, true);
   
   //--
   //-- Check entry
   //--
   
   // Do not continue unless the bar is closed or the entry is non strict
   if(!barclosed) return(0);
   
   // Trail stops
   if(TS_Enabled) TrailStops();
   
   // Parabolic Sar
   double trade_sar  = iSAR(Symbol(), 0, TradeStep, TradeMax, Shift);
   double trade_sar1 = iSAR(Symbol(), 0, TradeStep, TradeMax, Shift+1);
   double stop_sar   = iSAR(Symbol(), 0, StopStep, StopMax, Shift);
                        
   // Trades opened
   int l_TotalTrades_buy = GetTotalTrades(OP_BUY, MagicNumber);
   int l_TotalTrades_sell = GetTotalTrades(OP_SELL, MagicNumber);
  
   // Bars
   double CLOSE  = iClose(Symbol(),0, Shift);
   double CLOSE1 = iClose(Symbol(),0, Shift+1);
   double HIGH   = iHigh(Symbol(), 0, Shift);
   double LOW    = iLow(Symbol(), 0, Shift);
   
   // Exit longs 
   if(stop_sar > CLOSE) CloseOrder(OP_BUY);
   if(stop_sar < CLOSE) CloseOrder(OP_SELL);
 
   // Buy
   if(l_TotalTrades_buy == 0 && trade_sar < CLOSE && stop_sar < CLOSE) 
   {
      CloseOrder(OP_SELL);
      PlaceOrder(OP_BUY, GetLotSize(OP_BUY));
   }  
   
   // Sell
   if(l_TotalTrades_sell == 0 && trade_sar > CLOSE && stop_sar > CLOSE) 
   {  
      CloseOrder(OP_BUY);
      PlaceOrder(OP_SELL, GetLotSize(OP_SELL));
   }
   return (0);
}

//+------------------------------------------------------------------+
//| My functions
//+------------------------------------------------------------------+

/**
* Returns total opened trades
* @param    int   Type
* @param    int   Magic
* @return   int
*/
int GetTotalTrades(int Type, int Magic)
{
   int counter = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
        Print(ShortName +" (OrderSelect Error) "+ ErrorDescription(GetLastError()));
      } else if(OrderSymbol() == Symbol() && (OrderType() == Type || Type == EMPTY_VALUE) && OrderMagicNumber() == Magic) {
            counter++;
      }
   }
   return(counter);
}


/**
* Closes desired orders 
* @param    int   Type
*/
void CloseOrder(int Type, int Magic = EMPTY_VALUE)
{
   int l_type;
	if(Magic == EMPTY_VALUE) Magic = MagicNumber;
	for(int i = OrdersTotal()-1; i >= 0; i--)
	{
		OrderSelect(i, SELECT_BY_POS, MODE_TRADES); l_type = OrderType();
		if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && Type == l_type)
		{ 
	      if(Type == OP_BUY || Type == OP_SELL)  
	      {
            if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, Gold))
               Print(ShortName +" (OrderClose Error) "+ ErrorDescription(GetLastError()));
         }
      }
   }
}

/**
* Places an order
* @param    int      Type
* @param    double   Lotz
* @param    double   PendingPrice
*/
void PlaceOrder(int Type, double Lotz, int Magic = EMPTY_VALUE)
{
   int err;
   color  l_color;
   double l_price, l_sprice, l_stoploss = 0;
   string action;
   RefreshRates();
   
   // Magic adaptation
   if(Magic == EMPTY_VALUE) Magic = MagicNumber;
   
   // Price and color for the trade type
   if(Type == OP_BUY){ l_price = Ask;  l_color = Blue; action = "Buy"; }
   if(Type == OP_SELL){ l_price = Bid; l_color = Red; action = "Sell"; } 
   
   // Avoid collusions
   while (IsTradeContextBusy()) Sleep(1000);
   int l_datetime = TimeCurrent();
   
   // Send order
   int l_ticket = OrderSend(Symbol(), Type, Lotz, l_price, Slippage, 0, 0, "", Magic, 0, l_color);
   
   // Rety if failure
   if (l_ticket == -1)
   {
      while(l_ticket == -1 && TimeCurrent() - l_datetime < 60 && !IsTesting())
      {
         err = GetLastError();
         if (err == 148) return;
         Sleep(1000);
         while (IsTradeContextBusy()) Sleep(1000);
         RefreshRates();
         l_ticket = OrderSend(Symbol(), Type, Lotz, l_price, Slippage, 0, 0, "", Magic, 0, l_color);
      }
      if (l_ticket == -1)
         Print(ShortName +" (OrderSend Error) "+ ErrorDescription(GetLastError()));
   }
   if (l_ticket != -1)
   {        
      // Store data
      LastOrderTime[Type]     = iTime(Symbol(), PERIOD_D1, 0);
      LastOrderTicket[Type]   = l_ticket;
      LastOrderLots[Type]     = Lotz;
      
      // Update positions
      if(OrderSelect(l_ticket, SELECT_BY_TICKET, MODE_TRADES))
      {
         l_stoploss = MyNormalizeDouble(GetStopLoss(Type));
         if(!OrderModify(l_ticket, OrderOpenPrice(), l_stoploss, 0, 0, Green))
            Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError())); 
      }
   }
}

/**
* Calculates lot size according to risk and the weight of this trade
* @return   double
*/
double GetLotSize(int Type)
{
   // Lots
   double l_lotz = LotSize;
   
   // Lotsize and restrictions 
   double l_minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double l_maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double l_lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
   int vp = 0; if(l_lotstep == 0.01) vp = 2; else vp = 1;
   
   // Apply money management
   if(MoneyManagement == true)
      l_lotz = MathFloor(AccountBalance() * RiskPercent / 100.0) / 1000.0;
   
   // Are we piramyding?
   l_lotz = NormalizeDouble(l_lotz, vp);
   
   // Check max/minlot here
   if (l_lotz < l_minlot) l_lotz = l_minlot;
   if(l_lotz > l_maxlot) l_lotz = l_maxlot; 
   
   // Bye!
   return (l_lotz);
}

/**
* Returns decimal pip value
* @return   double
*/
double GetDecimalPip()
{
   switch(Digits)
   {
      case 5: return(0.0001);
      case 4: return(0.0001);
      case 3: return(0.001);
      default: return(0.01);
   }
}


/**
* Returns initial stoploss
* @return   int   Type
* @return   double
*/
double GetStopLoss(int Type)
{
   double l_sl = 0;
   double l_risk = GetStopLossRange(Type);
   if(Type == OP_BUY)  l_sl = Ask - l_risk - (Ask - Bid);
   if(Type == OP_SELL) l_sl = Bid + l_risk + (Ask - Bid);
   return (l_sl);
}

/**
* Get stoploss in range
* @return   double
*/
double GetStopLossRange(int Type)
{
   if(Type == OP_BUY) return(iATR(Symbol(), 0, ATRPeriod, Shift)*ATRMultiplier);
   if(Type == OP_SELL) return(iATR(Symbol(), 0, ATRPeriod, Shift)*ATRMultiplier);
}

/**
* Normalizes price
* @param    double   price 
* @return   double
*/
double MyNormalizeDouble(double price)
{
   return (NormalizeDouble(price, Digits));
}

/**
* Checks if the bar has closed
*/
bool IsBarClosed(int timeframe,bool reset)
{
    static datetime lastbartime;
    if(timeframe==-1)
    {
        if(reset)
            lastbartime=0;
        else
            lastbartime=iTime(NULL,timeframe,0);
        return(true);
    }
    if(iTime(NULL,timeframe,0)==lastbartime) // wait for new bar
        return(false);
    if(reset)
        lastbartime=iTime(NULL,timeframe,0);
    return(true);
}

/**
* Get baseline plus deviation
* @return   double
*/
double getStopLevelInPips()
{
   double s = MarketInfo(Symbol(), MODE_STOPLEVEL) + 1.0;
   if(Digits == 5) s = s / 10;
   return(s);
}


/**
* Breaks even all trades
*/
void BreakEvenTrades()
{  
   // Lotstep
   double l_lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
   int vp = 0; if(l_lotstep == 0.01) vp = 2; else vp = 1;
   
   // Iterate all trades
   for(int cnt=0; cnt < OrdersTotal(); cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); int l_type = OrderType();
      if((l_type == OP_BUY || l_type == OP_SELL) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
      {
         // Pips gained for now
         double PipProfit, PipStopLoss;
         
         // Calculate pips for stoploss
         if(l_type == OP_BUY)
         {
            // If this trade is losing or free
            if(Bid < OrderOpenPrice()) continue;
            
            // Profit and so forth
            PipProfit = Bid - OrderOpenPrice();
            PipStopLoss = (OrderOpenPrice() - OrderStopLoss()) / StopDivisor;
            
         } else if(l_type == OP_SELL) {
         
            // If this trade is losing or free
            if(Ask > OrderOpenPrice()) continue;
         
            // Profit and so forth
            PipProfit = OrderOpenPrice() - Ask;
            PipStopLoss = (OrderStopLoss() - OrderOpenPrice()) / StopDivisor;
         }
         
         // Read comment from trade
         string Com = OrderComment();
         double LOTS = OrderLots();
       
         // Partial close
         if(PartialClosing &&
            PipProfit > PipStopLoss && 
            StringFind(Com, "from #", 0) == -1)
         {
            // Close
            double halflots = NormalizeDouble(LOTS * PercentageToClose, vp);
            
            // Close half position
            if(halflots > MarketInfo(Symbol(), MODE_MINLOT))
            {
               if(!OrderClose(OrderTicket(), halflots, OrderClosePrice(), 6, Gold))
                  Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError()));
            }
         }
      }
   }
}


/**
* Trails the stop-loss for all trades
*/
void TrailStops()
{
   int Type;
   double TS_price; 
   double stoplevel = getStopLevelInPips();
	for(int i = OrdersTotal()-1; i >= 0; i--)
	{
		OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
		if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
         // Proceed to trailing
         Type = OrderType();
         
         if(Type == OP_BUY)
         {
            TS_price = Bid - iATR(Symbol(), 0, TSATRPeriod, Shift)*TSATRMultiplier;
            if(TS_price > OrderStopLoss()+stoplevel*DecimalPip)
            {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), TS_price, OrderTakeProfit(), 0, Pink))
                  Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError()));
            }
            
         } else if(Type == OP_SELL) {
             
             TS_price = Ask + iATR(Symbol(), 0, TSATRPeriod, Shift)*TSATRMultiplier;
             if(TS_price < OrderStopLoss()-stoplevel*DecimalPip)
            {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), TS_price, OrderTakeProfit(), 0, Pink))
                    Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError()));
            }
         }
      }
   }
}
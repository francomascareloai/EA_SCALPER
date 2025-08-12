//|$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//|              Close 
//|   Last Updated 13-12-2013 (added option to close orders in profit pips)
//|$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#define     NL    "\n" 

extern string dnch="set to false to let the EA close the orders, otherwise only reporting onscreen";
extern bool   DoNotCloseOrders=true;
extern string pth="false:Target in Money, true:in Pips";
extern bool   ProfitTargetInPips = false;//fxdaytrader
extern double ProfitTarget = 25.0;
//extern int    ProfitTarget     = 25;             // closes all orders once Float hits this $ amount
extern bool   CloseAllNow      = false;          // closes all orders now
extern bool   CloseProfitableTradesOnly = false; // closes only profitable trades
extern double ProftableTradeAmount      = 1;     // Only trades above this amount close out
extern bool   ClosePendingOnly = false;          // closes pending orders only
extern bool   UseAlerts        = false;

int Multiplier;
double pips2dbl;

//+-------------+
//| Custom init |
//|-------------+
int init()
  {

  }

//+----------------+
//| Custom DE-init |
//+----------------+
int deinit()
  {

  }

//+------------------------------------------------------------------------+
//| Closes everything
//+------------------------------------------------------------------------+
void CloseAll()
{
   int i;
   bool result = false;

   while(OrdersTotal()>0)
   {
      // Close open positions first to lock in profit/loss
      for(i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)==false) continue;

         result = false;
         if ( OrderType() == OP_BUY)  if (!DoNotCloseOrders) result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 15, Red );
         if ( OrderType() == OP_SELL) if (!DoNotCloseOrders) result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 15, Red );
         if (UseAlerts) PlaySound("alert.wav");
      }
      for(i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)==false) continue;

         result = false;
         if ( OrderType()== OP_BUYSTOP)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_BUYLIMIT)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_SELLLIMIT)  result = OrderDelete( OrderTicket() );
         if (UseAlerts) PlaySound("alert.wav");
      }
      Sleep(1000);
   }
}
   
//+------------------------------------------------------------------------+
//| cancels all orders that are in profit
//+------------------------------------------------------------------------+
void CloseAllinProfit()
{
  for(int i=OrdersTotal()-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
        if ( OrderType() == OP_BUY && OrderProfit()+OrderSwap()+OrderCommission()>ProftableTradeAmount)  if (!DoNotCloseOrders) result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
        if ( OrderType() == OP_SELL && OrderProfit()+OrderSwap()+OrderCommission()>ProftableTradeAmount) if (!DoNotCloseOrders) result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
        if (UseAlerts) PlaySound("alert.wav");
 }
  return; 
}

//+------------------------------------------------------------------------+
//| cancels all pending orders 
//+------------------------------------------------------------------------+
void ClosePendingOrdersOnly()
{
  for(int i=OrdersTotal()-1;i>=0;i--)
 {
    OrderSelect(i, SELECT_BY_POS);
    bool result = false;
        if ( OrderType()== OP_BUYSTOP)   result = OrderDelete( OrderTicket() );
        if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
  }
  return; 
  }

//+-----------+
//| Main      |
//+-----------+
int start()
  {
   int      OrdersBUY;
   int      OrdersSELL;
   double   BuyLots=0.0, SellLots=0.0, BuyProfit=0.0, SellProfit=0.0, BuyProfitPips=0.0, SellProfitPips=0.0;

//+------------------------------------------------------------------+
//  Determine last order price                                       |
//-------------------------------------------------------------------+
      for(int i=0;i<OrdersTotal();i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
         
         BrokerDigitAdjust(OrderSymbol());//fxdaytrader, for pips calculation
         
         if(OrderType()==OP_BUY)
         {
            OrdersBUY++;
            BuyLots += OrderLots();
            
            //profit target in money
            BuyProfit += OrderProfit() + OrderCommission() + OrderSwap();
            
            //profit target in pips
            BuyProfitPips += (OrderClosePrice()-OrderOpenPrice())/pips2dbl;           
            
         }
         if(OrderType()==OP_SELL) 
         {
            OrdersSELL++;
            SellLots += OrderLots();
            
            //profit target in money
            SellProfit += OrderProfit() + OrderCommission() + OrderSwap();
            
            //profit target in pips
            SellProfitPips += (OrderOpenPrice()-OrderClosePrice())/pips2dbl;
         }
      }               
   
    if(CloseAllNow) CloseAll();
    
    if(CloseProfitableTradesOnly) CloseAllinProfit();
    
    //profit target in money
    if (!ProfitTargetInPips) {
     if(BuyProfit+SellProfit >= ProfitTarget) CloseAll(); 
    }
    
    //profit target in pips
    if (ProfitTargetInPips) {
     if(BuyProfitPips+SellProfitPips >= ProfitTarget) CloseAll(); 
    }
    
    if(ClosePendingOnly) ClosePendingOrdersOnly();
       
   string sprofit=AccountCurrency()+" total Profit (current: "+DoubleToStr(BuyProfit+SellProfit,2)+" "+AccountCurrency()+")";
   if (ProfitTargetInPips) sprofit="Pips total Profit (current: "+DoubleToStr(BuyProfitPips+SellProfitPips,2)+" Pips)";
   
   Comment("           Comments Last Update 13-12-2013 *** forexBaron.net", NL,//Comments Last Update 12-12-2006 10:00pm", NL,
           "           Close Mode: at ",DoubleToStr(ProfitTarget,2)," "+sprofit, NL,
           "              Buys            ", OrdersBUY, NL,
           "              BuyLots         ", BuyLots, NL,
           "              Sells           ", OrdersSELL, NL,
           "              SellLots        ", DoubleToStr(SellLots,2), NL, NL,
           "              BuyProfitPips:  ", DoubleToStr(BuyProfitPips,2), NL,
           "              SellProfitPips: ", DoubleToStr(SellProfitPips,2), NL,
           "              Balance         ", DoubleToStr(AccountBalance(),2)," ",AccountCurrency(), NL,
           "              Equity          ", DoubleToStr(AccountEquity(),2)," ",AccountCurrency(), NL,
           "              Margin          ", DoubleToStr(AccountMargin(),2)," ",AccountCurrency(), NL,
           "              Free Margin     ", DoubleToStr(AccountFreeMargin(),2)," ",AccountCurrency(), NL,
           "              MarginPercent   ", DoubleToStr(MathRound((AccountEquity()/AccountMargin())*100),2),"%", NL,
           "              Current Time is ",TimeHour(CurTime()),":",TimeMinute(CurTime()),".",TimeSeconds(CurTime()));
 } // start()

///////////////////////////////////////////
//added fxdaytrader:

void BrokerDigitAdjust(string symbol) {
 Multiplier = 1;
 if (MarketInfo(symbol,MODE_DIGITS) == 3 || MarketInfo(symbol,MODE_DIGITS) == 5) Multiplier = 10;
 if (MarketInfo(symbol,MODE_DIGITS) == 6) Multiplier = 100;   
 if (MarketInfo(symbol,MODE_DIGITS) == 7) Multiplier = 1000;
 pips2dbl = Multiplier*MarketInfo(symbol,MODE_POINT); 
}


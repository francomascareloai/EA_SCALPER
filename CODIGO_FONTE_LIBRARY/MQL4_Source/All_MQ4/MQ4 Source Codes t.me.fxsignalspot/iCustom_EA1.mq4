//+------------------------------------------------------------------+
//|                          Strategy: iCustom Marty EA Template.mq4 |
//|                                       Created with EABuilder.com |
//|                                             http://eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "http://eabuilder.com"
#property version   "1.00"
#property description "Coded JimTang"

#include <stdlib.mqh>
#include <stderror.mqh>

extern string IndicatorShortName = "super-arrow-indicator1";
extern int MaxOpenTrades = 2;
extern int BO_Expiry = 240;
int LotDigits; //initialized in OnInit
extern int MagicNumber = 847636;
extern int NextOpenTradeAfterBars = 0; //next open trade after time
extern double TakeProfit_pips = 150;
extern double StopLoss_pips = 70;
double takeprofit=0,stoploss=0;
datetime LastTradeTime = 0;
extern int TOD_From_Hour = 00; //time of the day
extern int TOD_From_Min = 00; //time of the day
extern int TOD_To_Hour = 23; //time of the day
extern int TOD_To_Min = 59; //time of the day
extern double MM_Martingale_Start = 0.1;
double MM_Martingale_ProfitFactor = 1;
extern double MM_Martingale_LossFactor = 2;
bool MM_Martingale_RestartProfit = true;
extern bool MM_Martingale_RestartLoss = true;
extern int MM_Martingale_RestartLosses = 4;
int MaxSlippage = 3; //adjusted in OnInit
extern bool TradeMonday = true;
extern bool TradeTuesday = true;
extern bool TradeWednesday = true;
extern bool TradeThursday = true;
extern bool TradeFriday = true;
bool TradeSaturday = false;
bool TradeSunday = false;
extern bool Audible_Alerts = true;

int MaxLongTrades = 1000;
int MaxShortTrades = 1000;
int MaxPendingOrders = 1000;
bool Hedging = false;
int OrderRetry = 5; //# of retries if sending order returns error
int OrderWait = 5; //# of seconds to wait if sending order returns error
double myPoint; //initialized in OnInit

bool inTimeInterval(datetime t, int TOD_From_Hour, int TOD_From_Min, int TOD_To_Hour, int TOD_To_Min)
  {
   string TOD = TimeToString(t, TIME_MINUTES);
   string TOD_From = StringFormat("%02d", TOD_From_Hour)+":"+StringFormat("%02d", TOD_From_Min);
   string TOD_To = StringFormat("%02d", TOD_To_Hour)+":"+StringFormat("%02d", TOD_To_Min);
   return((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, TOD_To) <= 0)
     || (StringCompare(TOD_From, TOD_To) > 0
       && ((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, "23:59") <= 0)
         || (StringCompare(TOD, "00:00") >= 0 && StringCompare(TOD, TOD_To) <= 0))));
  }

bool SelectLastHistoryTrade()
  {
   int lastOrder = -1;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         lastOrder = i;
         break;
        }
     } 
   return(lastOrder >= 0);
  }

double BOProfit(int ticket) //Binary Options profit
  {
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(StringSubstr(OrderComment(), 0, 2) == "BO" && StringFind(OrderComment(), "#"+ticket+" ") >= 0)
         return OrderProfit();
     }
   return 0;
  }

bool ConsecutiveLosses(int n)
  {
   int count = 0;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
         double orderprofit = OrderProfit();
         double boprofit = BOProfit(OrderTicket());
         if(orderprofit + boprofit >= 0)
            break;
         count++;
        }
     }
   return(count >= n);
  }

double MM_Size() //martingale / anti-martingale
  {
   double lots = MM_Martingale_Start;
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   if(SelectLastHistoryTrade())
     {
      double orderprofit = OrderProfit();
      double orderlots = OrderLots();
      double boprofit = BOProfit(OrderTicket());
      if(orderprofit + boprofit > 0 && !MM_Martingale_RestartProfit)
         lots = orderlots * MM_Martingale_ProfitFactor;
      else if(orderprofit + boprofit < 0 && !MM_Martingale_RestartLoss)
         lots = orderlots * MM_Martingale_LossFactor;
      else if(orderprofit + boprofit == 0)
         lots = orderlots;
     }
   if(ConsecutiveLosses(MM_Martingale_RestartLosses))
      lots = MM_Martingale_Start;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }

bool TradeDayOfWeek()
  {
   int day = DayOfWeek();
   return((TradeMonday && day == 1)
   || (TradeTuesday && day == 2)
   || (TradeWednesday && day == 3)
   || (TradeThursday && day == 4)
   || (TradeFriday && day == 5)
   || (TradeSaturday && day == 6)
   || (TradeSunday && day == 0));
  }

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
     }
   else if(type == "order")
     {
      Print(type+" | iCustom Marty EA Template @ "+Symbol()+","+Period()+" | "+message);
      if(Audible_Alerts) Alert(type+" | iCustom Marty EA Template @ "+Symbol()+","+Period()+" | "+message);
     }
   else if(type == "modify")
     {
     }
  }

int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      result++;
     }
   return(result);
  }

int myOrderSend(int type, double price, double volume, double sl, double tp, string ordername) //send order, return ticket ("price" is irrelevant for market orders)
  {
   if(!IsTradeAllowed()) return(-1);
   int ticket = -1;
   int retries = 0;
   int err;
   int long_trades = TradesCount(OP_BUY);
   int short_trades = TradesCount(OP_SELL);
   int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
   int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   //test Hedging
   if(!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
     {
      myAlert("print", "Order"+ordername_+" not sent, hedging not allowed");
      return(-1);
     }
   //test maximum trades
   if((type % 2 == 0 && long_trades >= MaxLongTrades)
   || (type % 2 == 1 && short_trades >= MaxShortTrades)
   || (long_trades + short_trades >= MaxOpenTrades)
   || (type > 1 && long_pending + short_pending >= MaxPendingOrders))
     {
      myAlert("print", "Order"+ordername_+" not sent, maximum reached");
      return(-1);
     }
   //prepare to send order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   if(type == OP_BUY)
      price = Ask;
   else if(type == OP_SELL)
      price = Bid;
   else if(price < 0) //invalid price for pending order
     {
      myAlert("order", "Order"+ordername_+" not sent, invalid price for pending order");
	  return(-1);
     }
   int clr = (type % 2 == 1) ? clrRed : clrBlue;
   while(ticket < 0 && retries < OrderRetry+1)
     {
      ticket = OrderSend(Symbol(), type, NormalizeDouble(volume, LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, sl, tp, ordername, MagicNumber, 0, clr);
      if(ticket < 0)
        {
         err = GetLastError();
         myAlert("print", "OrderSend"+ordername_+" error #"+err+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(ticket < 0)
     {
      myAlert("error", "OrderSend"+ordername_+" failed "+(OrderRetry+1)+" times; error #"+err+" "+ErrorDescription(err));
      return(-1);
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   myAlert("order", "Order sent"+ordername_+": "+typestr[type]+" "+Symbol()+" Magic #"+MagicNumber);
   return(ticket);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {   
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
      MaxSlippage *= 10;
     }
   //initialize LotDigits
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   if(LotStep >= 1) LotDigits = 0;
   else if(LotStep >= 0.1) LotDigits = 1;
   else if(LotStep >= 0.01) LotDigits = 2;
   else LotDigits = 3;
   LastTradeTime = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int ticket = -1;
   double price;   
   takeprofit=0;
   stoploss=0;
   
   //Binary Option Call 
     if(iCustom(NULL, 0, IndicatorShortName,+0,0)!=EMPTY_VALUE) 
     {
      RefreshRates();
      price = Ask;
      if(StopLoss_pips!=0)stoploss = Bid-StopLoss_pips*Point*10;
      if(TakeProfit_pips!=0)takeprofit = Ask+TakeProfit_pips*Point*10;
      if(TimeCurrent() - LastTradeTime < NextOpenTradeAfterBars * PeriodSeconds()) return; //next open trade after time
      if(!inTimeInterval(TimeCurrent(), TOD_From_Hour, TOD_From_Min, TOD_To_Hour, TOD_To_Min)) return; //open trades only at specific times of the day
      if(!TradeDayOfWeek()) return; //open trades only on specific days of the week   
      if(IsTradeAllowed())
        {
         ticket = myOrderSend(OP_BUY, price, MM_Size(), stoploss, takeprofit, "BUY Min:"+IntegerToString(BO_Expiry * 1)); //binary option order
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      LastTradeTime = TimeCurrent();
     }
   
   //Binary Option Put
     if(iCustom(NULL, 0, IndicatorShortName,+1,1)!=EMPTY_VALUE) 
   
     {
      RefreshRates();
      price = Bid;
      if(TakeProfit_pips!=0)takeprofit = Bid-TakeProfit_pips*Point*10;
      if(StopLoss_pips!=0)stoploss = Ask+StopLoss_pips*Point*10;
      if(TimeCurrent() - LastTradeTime < NextOpenTradeAfterBars * PeriodSeconds()) return; //next open trade after time
      if(!inTimeInterval(TimeCurrent(), TOD_From_Hour, TOD_From_Min, TOD_To_Hour, TOD_To_Min)) return; //open trades only at specific times of the day
      if(!TradeDayOfWeek()) return; //open trades only on specific days of the week   
      if(IsTradeAllowed())
        {
         ticket = myOrderSend(OP_SELL, price, MM_Size(), stoploss, takeprofit, "SELL Min:"+IntegerToString(BO_Expiry * 1)); //binary option order
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      LastTradeTime = TimeCurrent();
     }
  }
//+------------------------------------------------------------------+
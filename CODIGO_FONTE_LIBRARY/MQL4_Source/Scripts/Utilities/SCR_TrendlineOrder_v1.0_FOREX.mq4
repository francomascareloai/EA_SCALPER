
//+------------------------------------------------------------------+
//|                                               TrendlineOrder.mq4 |
//|                                                         Scorpion |
//|                                              www.fxfisherman.com |
//+------------------------------------------------------------------+

/*
Because if trendline is diagonal, the order price must be constantly modified to go along with the line. 
So if order price is needed to be constantly modified, it's the job of Expert Advisor not script, because script, 
like you said, run only one-time when you double click on it.
By the time I described to you, I've coded the expert advisor for you already, so check it out in Forward Testing 
not Backtesting. You must draw a trendline and name it tx (case sensitive). Attach the expert to the same chart 
that trendline is drawn. Then you can choose to open only Long, Short, Both, or none in the settings window. When 
bid price crosses up the trendline, buy at market price. When bid price crosses down the trendline, sell at market price.
*/

#property copyright "Scorpion"
#property link      "http://www.fxfisherman.com"

//---- input parameters
extern int       Evaluate_Interval=1; // -1 chart, 0 tick, > 0 specified min

extern double    Lots=1;
extern int       TP=150;
extern int       SL=30;

extern int       TS_Trigger=15;
extern int       TS_Mode=1;       // 0 = disabled, 1 = Fixed SL, 2 = ATR, 3 = Half Volatility
extern int       TS_Sensitivity=5;
extern double    TS_DynamicFactor=0.5;   // applied only if TrailingStopMode = 2 or 3

extern bool      Enable_Alert=false;

string expert_name = "TrendlineOrder_v1";
int bars_count = 0;
int magicnum;
int open_slippage=5;
int close_slippage=10;
datetime dtNextEvaluate;
double value1;
double bid1;
bool executed;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   magicnum = 1000 + GetTimeframeConstant(Period()) + GetSymbolConstant(Symbol());
   return(0);
  }
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
 
  // control open orders
  int ticket = OrderTicketByMagicNum(magicnum);
  ControlTrailingStop(ticket);
  
  // analyse chart
  bool AnalyseNow;
  if (Evaluate_Interval==0)
  {
    AnalyseNow=true;
  }else if (CurTime() >= dtNextEvaluate) {
    AnalyseNow=true;
    if (Evaluate_Interval>0)
    {
      dtNextEvaluate=CurTime() - (CurTime() % (Evaluate_Interval*60)) + (Evaluate_Interval*60);
    } else {
      dtNextEvaluate=CurTime() - (CurTime() % (Period()*60)) + (Period()*60);
    }
  }

  bool IsBuy, IsSell, IsCloseBought, IsCloseSold;
  if(AnalyseNow)
  {
    double value0 = ObjectGetValueByShift("tx",0);
    double bid0 = Bid;
    if (executed)
    {
      Print(value0);
      IsBuy  = (bid1 <= value1 && bid0 > value0);
      IsSell = (bid1 >= value1 && bid0 < value0);
      IsCloseBought = IsSell;
      IsCloseSold = IsBuy;
    }else{
      executed=true;
    }
    
    value1=value0;
    bid1=bid0;
    
  }
  
  // check for exit
  if (ticket > 0 )
  {
    if (OrderSelectEx(ticket,SELECT_BY_TICKET,MODE_TRADES)==false) return(0);
    if (OrderType() == OP_BUY && IsCloseBought)
    {
      if (Enable_Alert) Alert(expert_name, ": Close order #", ticket," at ", Bid);
      OrderClose(ticket, OrderLots(), Bid, close_slippage, Red);
    } else if (OrderType() == OP_SELL && IsCloseSold) {
      if (Enable_Alert) Alert(expert_name, ": Close order #", ticket," at ", Ask);
      OrderClose(ticket, OrderLots(), Ask, close_slippage, Red);
    }
  }
  
  // check for entry ( enough money > safe mode off > signal given > enter) 
  if (AccountFreeMargin()<(1000*Lots))
  {
    Print("Error: We don't have enough money. Free Margin = ", AccountFreeMargin());
    return(0);
  }
  
  if (OrderTicketByMagicNum(magicnum)==0)
  {
    if (IsBuy && !IsSell) {
      EnterBuy();
      if (Enable_Alert) Alert(expert_name, ": Buy ", Symbol()," at ", Ask);
    } else if(IsSell && !IsBuy) {
      EnterSell();
      if (Enable_Alert) Alert(expert_name, ": Sell ", Symbol()," at ", Bid);
    } else if(IsSell && IsBuy) {
      Print("Error: Buy and sell signals are issued at the same time!");
    } 
  }


  return(0);
}


//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
int EnterBuy()
{
 
  // Calculate true SL/TP
  double TrueSL, TrueTP;
  if (SL > 0) TrueSL = Ask-(SL*Point);
  if (TP > 0) TrueTP = Ask+(TP*Point);
  
  int ret = OrderSendEx(Symbol(), OP_BUY, Lots, Ask, open_slippage*Point, TrueSL, TrueTP, "rsx_swinger_2p1 " + Symbol() + Period(), magicnum, 0, Yellow);
  return(ret);
}


//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
int EnterSell()
{

  // Calculate true SL/TP
  double TrueSL, TrueTP;
  if (SL > 0) TrueSL = Bid+(SL*Point);
  if (TP > 0) TrueTP = Bid-(TP*Point);
  
  // Send order
  int ret = OrderSendEx(Symbol(), OP_SELL, Lots ,Bid, open_slippage*Point, TrueSL, TrueTP, "rsx_swinger_2p1 " + Symbol() + Period(), magicnum, 0, Yellow);
  return(ret);
  
}


//+------------------------------------------------------------------+
//| Control trailing stop                                            |
//+------------------------------------------------------------------+
void ControlTrailingStop(int ticket)
{
  if (ticket == 0 || TS_Mode == 0) return;
  
  double ts;
  if (OrderSelectEx(ticket, SELECT_BY_TICKET, MODE_TRADES)==false) return;
  if (OrderType() == OP_BUY)
  {
    switch (TS_Mode)
    {
      case 1: ts = Bid-(Point*SL); break;
      case 2: ts = Low[0] - (TS_DynamicFactor * iATR(NULL,0,14,0)); break;
      case 3: ts = Low[0] - (TS_DynamicFactor *(High[0]-Low[0])); break;
    }
    if ((ts >= OrderStopLoss() + TS_Sensitivity*Point) && (Bid >= OrderOpenPrice() + TS_Trigger*Point )) 
    {
      OrderModify(ticket, OrderOpenPrice(), ts, OrderTakeProfit(), 0);
    }
    
  }else if(OrderType() == OP_SELL){
  
    switch (TS_Mode)
    {
      case 1: ts = Ask+(Point*SL); break;
      case 2: ts = High[0] + (TS_DynamicFactor * iATR(NULL,0,14,0)); break;
      case 3: ts = High[0] + (TS_DynamicFactor *(High[0]-Low[0])); break;
    }
    if ((ts <= OrderStopLoss() - TS_Sensitivity*Point) && (Ask <= OrderOpenPrice() - TS_Trigger*Point))
    {
      OrderModify(ticket, OrderOpenPrice(), ts, OrderTakeProfit(), 0);
    }
  }
  
}


//+------------------------------------------------------------------+
//| Extended OrderSend() for used in multiple pairs                  |
//+------------------------------------------------------------------+
int OrderSendEx(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment, int magic, datetime expiration=0, color arrow_color=CLR_NONE) {
   datetime OldCurTime;
   int timeout=5;
   
   if (!IsTesting()) {
      MathSrand(LocalTime());
      Sleep(MathRand()/6);
   }

   OldCurTime=CurTime();
   while (GlobalVariableCheck("InTrade") && !IsTradeAllowed()) {
      if(OldCurTime+timeout <= CurTime()) {
         Print("Error in OrderSendEx(): Timeout encountered");
         return(0); 
      }
      Sleep(1000);
   }
     
   GlobalVariableSet("InTrade", CurTime());  // set lock indicator
   int ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);
   GlobalVariableDel("InTrade");   // clear lock indicator
   return(ticket);
}


//+------------------------------------------------------------------+
//| Extended OrderSelect()                                           |
//+------------------------------------------------------------------+
bool OrderSelectEx(int index, int select, int pool = MODE_TRADES)
{
  if (OrderSelect(index,select,pool)==true)
  {
    return(true);
  }else{
    Print("Error: Order #", index ," cannot be selected.");
  }
}

//+------------------------------------------------------------------+
//| Get order ticket by magic number                                 |
//+------------------------------------------------------------------+
int OrderTicketByMagicNum(int magic_number) {

  for(int i=0;i<OrdersTotal();i++)
  {
    if (OrderSelectEx(i, SELECT_BY_POS) == false) continue;
    if (OrderMagicNumber() == magic_number) return(OrderTicket());
  }   
      
}


//+------------------------------------------------------------------+
//| Time frame interval appropriation function                       |
//+------------------------------------------------------------------+
int GetTimeframeConstant(int chart_period) {
   switch(chart_period) {
      case 1:  // M1
         return(50);
      case 5:  // M5
         return(100);
      case 15:
         return(150);
      case 30:
         return(200);
      case 60:
         return(250);
      case 240:
         return(300);
      case 1440:
         return(350);
      case 10080:
         return(400);
      case 43200:
         return(450);
   }
}


//+------------------------------------------------------------------+
//| Symbol to index                                                  |
//+------------------------------------------------------------------+
int GetSymbolConstant(string symbol) {

	if(symbol=="EURUSD") {	return(1);
	} else if(symbol=="GBPUSD") { return(2);
	} else if(symbol=="USDCHF") {	return(3);
	} else if(symbol=="USDJPY") {	return(4);
	} else if(symbol=="USDCAD") {	return(5);
	} else if(symbol=="AUDUSD") {	return(6);
	} else if(symbol=="CHFJPY") {	return(7);
	} else if(symbol=="EURAUD") {	return(8);
	} else if(symbol=="EURCAD") {	return(9);
	} else if(symbol=="EURCHF") {	return(10);
	} else if(symbol=="EURGBP") {	return(11);
	} else if(symbol=="EURJPY") {	return(12);
  } else if(symbol=="GBPCHF") {	return(13);
	} else if(symbol=="GBPJPY") {	return(14);
	} else if(symbol=="GOLD") {	return(15);
	} else {Print("Error: Unexpected symbol."); return(0);
	}
}


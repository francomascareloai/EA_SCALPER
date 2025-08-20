#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
#property description "Join Telegram Channel for daily Unlimited Source Codes @ex4tomq4decompilercom"
#property description "Find Fresh Decompiled Source Codes - https://www.ex4tomq4decompiler.com/free-mt4-robots"

//---
extern int MaxTrades = 4;
extern int Pips = 5;
extern double TakeProfit = 40;
extern double TrailingStop = 20;
double var_100 = 0;
int var_108 = 10;
int var_112 = 1;
int var_116 = 3;
int var_120 = 0;
double var_124 = 10;
double var_132 = 10;
double var_140 = 10;
double var_148 = 9.715;
int var_156 = 2005;
int var_160 = 1;
int var_164 = 2050;
int var_168 = 12;
int var_172 = 22;
int var_176 = 30;
int var_180 = 0;
int var_184 = 12;
int var_188 = 0;
int var_192 = 0;
int cnt = 0;
int slippage = 5;
double stoploss = 0;
double takeprofit = 0;
double bprice = 0;
double sprice = 0;
double var_236 = 0;
double lots = 0;
int var_252 = 0;
int var_256 = 0;
bool var_260 = true;
double var_264 = 0;
int var_272 = 0;
double var_276 = 0;
int var_284 = 0;
int var_288 = 0;
double var_292 = 0;
double var_300 = 0;
double var_308 = 0;
double var_316 = 0;
string var_324 = "";
string var_332 = "";
double Lots;

//+------------------------------------------------------------------+

double Lots()
{
Lots = NormalizeDouble(AccountFreeMargin() / 5 / 10000,1);
if (Lots < 0.1) Lots = 0.1;
if (Lots > 100.0) Lots = 100;
return(Lots);
}

//+------------------------------------------------------------------+

int init()
{

if (IsTesting())
{
ObjectCreate("text_object",OBJ_LABEL,0,0,0);
ObjectSet("text_object",OBJPROP_XDISTANCE,4);
ObjectSet("text_object",OBJPROP_YDISTANCE,15);
}
else
{
//Alert("Demo-version runs under Strategy Tester,\nnot on account - ON HISTORY ONLY !\n\nSee full version at www.tradingsb.com");
}
return(0);
}

//+------------------------------------------------------------------+

int deinit()
{
return(0);
}

//+------------------------------------------------------------------+

int start()
{
if (IsTesting())
{
if (var_188 == 1)
{
if (var_180 != 0)
var_236 = MathCeil(AccountBalance() * var_184 / 10000);
else
var_236 = Lots();
}
else
{
if (var_180 != 0)
var_236 = MathCeil(AccountBalance() * var_184 / 10000) / 10;
else
var_236 = Lots();
}
if (var_236 > 100.0) var_236 = 100;
var_192 = 0;
for (cnt = 0; cnt < OrdersTotal(); cnt++)
{
OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if ((OrderSymbol() == Symbol())) var_192++;
}
if (var_192 < 1)
{
if (TimeYear(CurTime()) < var_156) return(0);
if (TimeMonth(CurTime()) < var_160) return(0);
if (TimeYear(CurTime()) > var_164) return(0);
if (TimeMonth(CurTime()) > var_168) return(0);
}
if ((Symbol() == "EURUSD")) var_316 = var_124;
if ((Symbol() == "GBPUSD")) var_316 = var_132;
if ((Symbol() == "USDJPY")) var_316 = var_148;
if ((Symbol() == "USDCHF")) var_316 = var_140;
if (var_316 == 0.0) var_316 = 5;
if (var_272 > var_192)
{
for (cnt = OrdersTotal(); cnt >= 0; cnt--)
{
OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
var_252 = OrderType();
if ((OrderSymbol() == Symbol()))
{
if (var_252 == 0) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Blue);
if (var_252 == 1) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Red);
return(0);
}
}
}
var_272 = var_192;
if (var_192 >= MaxTrades) var_260 = false; else var_260 = true;
if (var_264 == 0.0)
{
for (cnt = 0; cnt < OrdersTotal(); cnt++)
{
OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
var_252 = OrderType();
if ((OrderSymbol() == Symbol()))
{
var_264 = OrderOpenPrice();
if (var_252 == 0) var_256 = 2;
if (var_252 == 1) var_256 = 1;
}
}
}
if (var_192 < 1)
{
var_256 = 3;
if (iMACD(NULL,0,14,26,9,PRICE_CLOSE,MODE_MAIN,0) > iMACD(NULL,0,14,26,9,PRICE_CLOSE,MODE_MAIN,1)) var_256 = 2;
if (iMACD(NULL,0,14,26,9,PRICE_CLOSE,MODE_MAIN,0) < iMACD(NULL,0,14,26,9,PRICE_CLOSE,MODE_MAIN,1)) var_256 = 1;
if (var_120 == 1)
{
if (var_256 == 1)
{
var_256 = 2;
}
else
{
if (var_256 == 2)
{
var_256 = 1;
}
}
}
}
for (cnt = OrdersTotal(); cnt >= 0; cnt--)
{
OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if ((OrderSymbol() == Symbol()))
{
if (OrderType() == OP_SELL)
{
if (TrailingStop > 0.0)
{
if (OrderOpenPrice() - Ask >= (TrailingStop + Pips) * Point)
{
if (OrderStopLoss() > Ask + Point * TrailingStop)
{
OrderModify(OrderTicket(),OrderOpenPrice(),Ask + Point * TrailingStop,OrderClosePrice() - TakeProfit * Point - TrailingStop * Point,800,Purple);
return(0);
}
}
}
}
if (OrderType() == OP_BUY)
{
if (TrailingStop > 0.0)
{
if (Bid - OrderOpenPrice() >= (TrailingStop + Pips) * Point)
{
if (OrderStopLoss() < Bid - Point * TrailingStop)
{
OrderModify(OrderTicket(),OrderOpenPrice(),Bid - Point * TrailingStop,OrderClosePrice() + TakeProfit * Point + TrailingStop * Point,800,Yellow);
return(0);
}
}
}
}
}
}
var_276 = 0;
var_284 = 0;
var_288 = 0;
var_292 = 0;
var_300 = 0;
for (cnt = 0; cnt < OrdersTotal(); cnt++)
{
OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if ((OrderSymbol() == Symbol()))
{
var_284 = OrderTicket();
if (OrderType() == OP_BUY) var_288 = 0;
if (OrderType() == OP_SELL) var_288 = 1;
var_292 = OrderClosePrice();
var_300 = OrderLots();
if (var_288 == 0)
{
if (OrderClosePrice() < OrderOpenPrice()) var_276 = var_276 - (OrderOpenPrice() - OrderClosePrice()) * OrderLots() / Point;
if (OrderClosePrice() > OrderOpenPrice()) var_276 = var_276 + (OrderClosePrice() - OrderOpenPrice()) * OrderLots() / Point;
}
if (var_288 == 1)
{
if (OrderClosePrice() > OrderOpenPrice()) var_276 = var_276 - (OrderClosePrice() - OrderOpenPrice()) * OrderLots() / Point;
if (OrderClosePrice() < OrderOpenPrice()) var_276 = var_276 + (OrderOpenPrice() - OrderClosePrice()) * OrderLots() / Point;
}
}
}
var_276 = var_276 * var_316;
var_332 = "Profit: $" + DoubleToStr(var_276,2) + " +/-";
if ((var_192 >= MaxTrades - var_116) && (var_112 == 1))
{
if (var_276 >= var_108)
{
OrderClose(var_284,var_300,var_292,slippage,Yellow );
var_260 = false;
return(0);
}
}
if (!IsTesting())
{
if (var_256 == 3)
var_324 = "No conditions to open trades";
else
var_324 = " ";
}
if ((var_256 == 1) && var_260)
{
if ((Bid - var_264 >= Pips * Point) || (var_192 < 1))
{
sprice = Bid;
var_264 = 0;
if (TakeProfit == 0.0) takeprofit = 0; else takeprofit = sprice - TakeProfit * Point;
if (var_100 == 0.0) stoploss = 0; else stoploss = sprice + var_100 * Point;
if (var_192 != 0)
{
lots = var_236;
cnt = 1;
while (cnt <= var_192)
{
if (MaxTrades > 12)
lots = NormalizeDouble(lots * 1.5,1);
else
lots = NormalizeDouble((lots + lots),1);
cnt++;
}
}
else
{
lots = var_236;
}
if (lots > 100.0) lots = 100;
OrderSend(Symbol(),OP_SELL,lots,sprice,slippage,stoploss,takeprofit,0,0,0,Red);
return(0);
}
}
if ((var_256 == 2) && var_260)
{
if ((var_264 - Ask >= Pips * Point) || (var_192 < 1))
{
bprice = Ask;
var_264 = 0;
if (TakeProfit == 0.0) takeprofit = 0; else takeprofit = bprice + TakeProfit * Point;
if (var_100 == 0.0) stoploss = 0; else stoploss = bprice - var_100 * Point;
if (var_192 != 0)
{
lots = var_236;
cnt = 1;
while (cnt <= var_192)
{
if (MaxTrades > 12)
lots = NormalizeDouble(lots * 1.5,1);
else
lots = NormalizeDouble((lots + lots),1);
cnt++;
}
}
else
{
lots = var_236;
}
if (lots > 100.0) lots = 100;
OrderSend(Symbol(),OP_BUY,lots,bprice,slippage,stoploss,takeprofit,0,0,0,Blue);
return(0);
}
}
}
return(0);
}
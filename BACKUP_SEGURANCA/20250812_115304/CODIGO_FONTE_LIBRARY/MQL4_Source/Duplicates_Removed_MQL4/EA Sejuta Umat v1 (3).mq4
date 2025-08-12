#property copyright "Copyright © 2009,Milik Bersama"
#property link      "http://www.kitacobaramerame.com&#8221"
#property show_inputs

extern string Expert_Comment = “OP Robot”;
extern double TargetEquity = 50000.0;
extern bool CloseAllNow = FALSE;
extern int MaxTrades = 20;
extern double Lots = 0.1;
extern double LotDigit = 2.0;
extern bool SwitchLot = TRUE;
extern double TakeProfit = 10.0;
extern double Pips = 7.0;
extern double Multiplier = 1.5;
extern int MaxOrderBuy = 5;
extern int MaxOrderSell = 5;
extern double TS_Buy = 3.0;
extern double TS_Sell = 3.0;
extern double Slippage = 5.0;
extern bool UseHourTrade = TRUE;
extern bool ContinueTrade = FALSE;
extern int StartHour = 0;
extern int EndHour = 24;
extern int Magic = 291179;
extern double AutoCalculate = 20.0;
bool gi_204 = FALSE;
bool gi_208 = TRUE;
double g_pips_212 = 0.0;
bool gi_220 = FALSE;
bool gi_224 = TRUE;
bool gi_228 = FALSE;
double gd_232 = 0.0;
bool gi_240 = FALSE;
double g_price_244;
double gd_252;
double gd_unused_260;
double gd_unused_268;
double g_price_276;
double g_bid_284;
double g_ask_292;
double gd_300;
double gd_308;
double gd_316;
bool gi_324;
int g_time_328 = 0;
int gi_332;
int gi_336 = 0;
double gd_340;
int g_pos_348 = 0;
int gi_352;
double gd_356 = 0.0;
bool gi_364 = FALSE;
bool gi_368 = FALSE;
bool gi_372 = FALSE;
int gi_376;
bool gi_380 = FALSE;
int g_datetime_384 = 0;
int g_datetime_388 = 0;
double gd_392;
double gd_400;
double gd_408;
int g_count_420;
int g_count_424;
int g_count_428;
color g_color_432;
double g_bid_436;

int init() {
gd_316 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
return (0);
}

int deinit() {
return (0);
}

int start() {
double l_ord_lots_0;
double l_ord_lots_8;
double l_iclose_16;
double l_iclose_24;
if (CloseAllNow == TRUE)
if (gd_408 == 0.0) CloseThisSymbolAll();
if (AccountEquity() > TargetEquity) {
CloseThisSymbolAll();
Comment(“\nTARGET TERCAPAI!”,
“\nModified by http://www.dpkforex.com&#8221;);
if (g_bid_436 > Close[0]) g_color_432 = Yellow;
else g_color_432 = Gold;
g_bid_436 = Bid;
tprofit();
return (0);
}
gd_408 = 0;
if (UseHourTrade) {
if (StartHour < EndHour) {
if (Hour() >= StartHour && Hour() <= EndHour) gd_408 = 1;
} else
if (Hour() >= StartHour || Hour() <= EndHour) gd_408 = 1;
}
g_count_420 = 0;
g_count_424 = 0;
g_count_428 = 0;
for (int l_pos_32 = 0; l_pos_32 < OrdersTotal(); l_pos_32++) {
OrderSelect(l_pos_32, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
g_count_420++;
if (OrderType() == OP_BUY) g_count_424++;
if (OrderType() == OP_SELL) g_count_428++;
}
}
if (gd_408 == 0.0) {
if (ContinueTrade && g_count_420 > 0) {
Comment(“\nTrading …. CONTINUE!”,
“\nStart Hour : “, StartHour, ”  EndHour : “, EndHour,
“\nModified by http://www.dpkforex.com&#8221;);
}
if (!ContinueTrade || (ContinueTrade && g_count_420 < 1)) {
Comment(“\nNon-Trading Hours! Im here http://www.dpkforex.com&#8221;);
return (0);
}
} else {
Comment(“\nTrading is READY!”,
“\nStart Hour : “, StartHour, ”  EndHour : “, EndHour,
“\nModified by http://www.dpkforex.com&#8221;);
}
string ls_36 = “false”;
string ls_44 = “false”;
if (gi_240 == FALSE || (gi_240 && (EndHour > StartHour && (Hour() >= StartHour && Hour() <= EndHour)) || (StartHour > EndHour && !(Hour() >= EndHour && Hour() <= StartHour)))) ls_36 = “true”;
if (gi_240 && (EndHour > StartHour && !(Hour() >= StartHour && Hour() <= EndHour)) || (StartHour > EndHour && (Hour() >= EndHour && Hour() <= StartHour))) ls_44 = “true”;
if (gi_224) TrailingAlls(TS_Buy, TS_Sell, g_price_276);
if (gi_228)
if (TimeCurrent() >= gi_332) Print(“Closed All due to TimeOut”);
if (g_time_328 == Time[0]) return (0);
g_time_328 = Time[0];
double ld_52 = CalculateProfit();
if (gi_220) {
if (ld_52 < 0.0 && MathAbs(ld_52) > AutoCalculate / 100.0 * AccountEquityHigh()) {
Print(“Closed All due to Stop Out”);
gi_380 = FALSE;
}
}
gi_352 = CountTrades();
if (gi_352 == 0) gi_324 = FALSE;
for (g_pos_348 = OrdersTotal() – 1; g_pos_348 >= 0; g_pos_348–) {
OrderSelect(g_pos_348, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
if (OrderType() == OP_BUY) {
gi_368 = TRUE;
gi_372 = FALSE;
l_ord_lots_0 = OrderLots();
break;
}
}
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
if (OrderType() == OP_SELL) {
gi_368 = FALSE;
gi_372 = TRUE;
l_ord_lots_8 = OrderLots();
break;
}
}
}
if (gi_352 > 0 && gi_352 <= MaxTrades) {
RefreshRates();
gd_300 = FindLastBuyPrice();
gd_308 = FindLastSellPrice();
if (gi_368 && gd_300 – Ask >= Pips * Point) gi_364 = TRUE;
if (gi_372 && Bid – gd_308 >= Pips * Point) gi_364 = TRUE;
}
if (gi_352 < 1) {
gi_372 = FALSE;
gi_368 = FALSE;
gi_364 = TRUE;
gd_252 = AccountEquity();
}
if (gi_364) {
gd_300 = FindLastBuyPrice();
gd_308 = FindLastSellPrice();
if (gi_372) {
if (gi_204 || ls_44 == “true”) {
fOrderCloseMarket(0, 1);
gd_340 = NormalizeDouble(Multiplier * l_ord_lots_8, LotDigit);
} else gd_340 = fGetLots(OP_SELL);
if (gi_208 && ls_36 == “true”) {
gi_336 = gi_352;
if (gd_340 > 0.0) {
RefreshRates();
gi_376 = OpenPendingOrder(1, gd_340, Bid, Slippage, Ask, 0, 0, Expert_Comment + “-” + gi_336, Magic, 0, HotPink);
if (gi_376 < 0) {
Print(“Error: “, GetLastError());
return (0);
}
gd_308 = FindLastSellPrice();
gi_364 = FALSE;
gi_380 = TRUE;
}
}
} else {
if (gi_368) {
if (gi_204 || ls_44 == “true”) {
fOrderCloseMarket(1, 0);
gd_340 = NormalizeDouble(Multiplier * l_ord_lots_0, LotDigit);
} else gd_340 = fGetLots(OP_BUY);
if (gi_208 && ls_36 == “true”) {
gi_336 = gi_352;
if (gd_340 > 0.0) {
gi_376 = OpenPendingOrder(0, gd_340, Ask, Slippage, Bid, 0, 0, Expert_Comment + “-” + gi_336, Magic, 0, Lime);
if (gi_376 < 0) {
Print(“Error: “, GetLastError());
return (0);
}
gd_300 = FindLastBuyPrice();
gi_364 = FALSE;
gi_380 = TRUE;
}
}
}
}
}
if (gi_364 && gi_352 < 1) {
l_iclose_16 = iClose(Symbol(), 0, 2);
l_iclose_24 = iClose(Symbol(), 0, 1);
g_bid_284 = Bid;
g_ask_292 = Ask;
if (!gi_372 && !gi_368 && ls_36 == “true”) {
gi_336 = gi_352;
if (l_iclose_16 > l_iclose_24) {
gd_340 = fGetLots(OP_SELL);
if (gd_340 > 0.0) {
gi_376 = OpenPendingOrder(1, gd_340, g_bid_284, Slippage, g_bid_284, 0, 0, Expert_Comment + “-” + gi_336, Magic, 0, HotPink);
if (gi_376 < 0) {
Print(gd_340, “Error: “, GetLastError());
return (0);
}
gd_300 = FindLastBuyPrice();
gi_380 = TRUE;
}
} else {
gd_340 = fGetLots(OP_BUY);
if (gd_340 > 0.0) {
gi_376 = OpenPendingOrder(0, gd_340, g_ask_292, Slippage, g_ask_292, 0, 0, Expert_Comment + “-” + gi_336, Magic, 0, Lime);
if (gi_376 < 0) {
Print(gd_340, “Error: “, GetLastError());
return (0);
}
gd_308 = FindLastSellPrice();
gi_380 = TRUE;
}
}
}
if (gi_376 > 0) gi_332 = TimeCurrent() + 60.0 * (60.0 * gd_232);
gi_364 = FALSE;
}
gi_352 = CountTrades();
g_price_276 = 0;
double ld_60 = 0;
for (g_pos_348 = OrdersTotal() – 1; g_pos_348 >= 0; g_pos_348–) {
OrderSelect(g_pos_348, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
g_price_276 += OrderOpenPrice() * OrderLots();
ld_60 += OrderLots();
}
}
}
if (gi_352 > 0) g_price_276 = NormalizeDouble(g_price_276 / ld_60, Digits);
if (gi_380) {
for (g_pos_348 = OrdersTotal() – 1; g_pos_348 >= 0; g_pos_348–) {
OrderSelect(g_pos_348, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
if (OrderType() == OP_BUY) {
g_price_244 = g_price_276 + TakeProfit * Point;
gd_unused_260 = g_price_244;
gd_356 = g_price_276 – g_pips_212 * Point;
gi_324 = TRUE;
}
}
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
if (OrderType() == OP_SELL) {
g_price_244 = g_price_276 – TakeProfit * Point;
gd_unused_268 = g_price_244;
gd_356 = g_price_276 + g_pips_212 * Point;
gi_324 = TRUE;
}
}
}
}
if (gi_380) {
if (gi_324 == TRUE) {
for (g_pos_348 = OrdersTotal() – 1; g_pos_348 >= 0; g_pos_348–) {
OrderSelect(g_pos_348, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) OrderModify(OrderTicket(), g_price_276, OrderStopLoss(), g_price_244, 0, Yellow);
gi_380 = FALSE;
}
}
}
watermark();
return (0);
}

double ND(double ad_0) {
return (NormalizeDouble(ad_0, Digits));
}

int fOrderCloseMarket(bool ai_0 = TRUE, bool ai_4 = TRUE) {
int li_ret_8 = 0;
for (int l_pos_12 = OrdersTotal() – 1; l_pos_12 >= 0; l_pos_12–) {
if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
if (OrderType() == OP_BUY && ai_0) {
RefreshRates();
if (!IsTradeContextBusy()) {
if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
Print(“Error close BUY ” + OrderTicket());
li_ret_8 = -1;
}
} else {
if (g_datetime_384 != iTime(NULL, 0, 0)) {
g_datetime_384 = iTime(NULL, 0, 0);
Print(“Need close BUY ” + OrderTicket() + “. Trade Context Busy”);
}
return (-2);
}
}
if (OrderType() == OP_SELL && ai_4) {
RefreshRates();
if (!IsTradeContextBusy()) {
if (!OrderClose(OrderTicket(), OrderLots(), ND(Ask), 5, CLR_NONE)) {
Print(“Error close SELL ” + OrderTicket());
li_ret_8 = -1;
}
} else {
if (g_datetime_388 != iTime(NULL, 0, 0)) {
g_datetime_388 = iTime(NULL, 0, 0);
Print(“Need close SELL ” + OrderTicket() + “. Trade Context Busy”);
}
return (-2);
}
}
}
}
}
return (li_ret_8);
}

double fGetLots(int a_cmd_0) {
double l_lots_4;
int l_datetime_12;
switch (SwitchLot) {
case FALSE:
l_lots_4 = Lots;
break;
case TRUE:
l_lots_4 = NormalizeDouble(Lots * MathPow(Multiplier, gi_336), LotDigit);
break;
case 2:
l_datetime_12 = 0;
l_lots_4 = Lots;
for (int l_pos_20 = OrdersHistoryTotal() – 1; l_pos_20 >= 0; l_pos_20–) {
if (OrderSelect(l_pos_20, SELECT_BY_POS, MODE_HISTORY)) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
if (l_datetime_12 < OrderCloseTime()) {
l_datetime_12 = OrderCloseTime();
if (OrderProfit() < 0.0) l_lots_4 = NormalizeDouble(OrderLots() * Multiplier, LotDigit);
else l_lots_4 = Lots;
}
}
} else return (-3);
}
}
if (AccountFreeMarginCheck(Symbol(), a_cmd_0, l_lots_4) <= 0.0) return (-1);
if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
if (l_lots_4 < 0.01) l_lots_4 = 0.01;
return (l_lots_4);
}

int CountTrades() {
int l_count_0 = 0;
for (int l_pos_4 = OrdersTotal() – 1; l_pos_4 >= 0; l_pos_4–) {
OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
}
return (l_count_0);
}

void CloseThisSymbolAll() {
for (int l_pos_0 = OrdersTotal() – 1; l_pos_0 >= 0; l_pos_0–) {
OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() == Symbol()) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Blue);
if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Red);
}
Sleep(1000);
}
}
}

int OpenPendingOrder(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_unused_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
int l_ticket_60 = 0;
int l_error_64 = 0;
int l_count_68 = 0;
int li_72 = 100;
switch (ai_0) {
case 2:
for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, g_pips_212), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
l_error_64 = GetLastError();
if (l_error_64 == 0/* NO_ERROR */) break;
if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
Sleep(1000);
}
break;
case 4:
for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, g_pips_212), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
l_error_64 = GetLastError();
if (l_error_64 == 0/* NO_ERROR */) break;
if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
Sleep(5000);
}
break;
case 0:
for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
RefreshRates();
if (g_count_424 < MaxOrderBuy) {
l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, g_pips_212), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
l_error_64 = GetLastError();
if (l_error_64 == 0/* NO_ERROR */) break;
if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
Sleep(5000);
}
}
break;
case 3:
for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, g_pips_212), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
l_error_64 = GetLastError();
if (l_error_64 == 0/* NO_ERROR */) break;
if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
Sleep(5000);
}
break;
case 5:
for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, g_pips_212), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
l_error_64 = GetLastError();
if (l_error_64 == 0/* NO_ERROR */) break;
if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
Sleep(5000);
}
break;
case 1:
for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
if (g_count_428 < MaxOrderSell) {
l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, g_pips_212), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
l_error_64 = GetLastError();
if (l_error_64 == 0/* NO_ERROR */) break;
if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
Sleep(5000);
}
}
}
return (l_ticket_60);
}

double StopLong(double ad_0, int ai_8) {
if (ai_8 == 0) return (0);
return (ad_0 – ai_8 * Point);
}

double StopShort(double ad_0, int ai_8) {
if (ai_8 == 0) return (0);
return (ad_0 + ai_8 * Point);
}

double TakeLong(double ad_0, int ai_8) {
if (ai_8 == 0) return (0);
return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
if (ai_8 == 0) return (0);
return (ad_0 – ai_8 * Point);
}

double CalculateProfit() {
double ld_ret_0 = 0;
for (g_pos_348 = OrdersTotal() – 1; g_pos_348 >= 0; g_pos_348–) {
OrderSelect(g_pos_348, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
}
return (ld_ret_0);
}

void TrailingAlls(int ai_0, int ai_4, double a_price_8) {
int li_16;
double l_ord_stoploss_20;
double l_price_28;
if (ai_4 != 0) {
for (int l_pos_36 = OrdersTotal() – 1; l_pos_36 >= 0; l_pos_36–) {
if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() || OrderMagicNumber() == Magic) {
if (OrderType() == OP_BUY) {
li_16 = NormalizeDouble((Bid – a_price_8) / Point, 0);
if (li_16 < ai_0) continue;
l_ord_stoploss_20 = OrderStopLoss();
l_price_28 = Bid – ai_4 * Point;
if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Aqua);
}
if (OrderType() == OP_SELL) {
li_16 = NormalizeDouble((a_price_8 – Ask) / Point, 0);
if (li_16 < ai_0) continue;
l_ord_stoploss_20 = OrderStopLoss();
l_price_28 = Ask + ai_4 * Point;
if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 < l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Red);
}
}
Sleep(1000);
}
}
}
}

double AccountEquityHigh() {
if (CountTrades() == 0) gd_392 = AccountEquity();
if (gd_392 < gd_400) gd_392 = gd_400;
else gd_392 = AccountEquity();
gd_400 = AccountEquity();
return (gd_392);
}

double FindLastBuyPrice() {
double l_ord_open_price_0;
int l_ticket_8;
double ld_unused_12 = 0;
int l_ticket_20 = 0;
for (int l_pos_24 = OrdersTotal() – 1; l_pos_24 >= 0; l_pos_24–) {
OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUY) {
l_ticket_8 = OrderTicket();
if (l_ticket_8 > l_ticket_20) {
l_ord_open_price_0 = OrderOpenPrice();
ld_unused_12 = l_ord_open_price_0;
l_ticket_20 = l_ticket_8;
}
}
}
return (l_ord_open_price_0);
}

double FindLastSellPrice() {
double l_ord_open_price_0;
int l_ticket_8;
double ld_unused_12 = 0;
int l_ticket_20 = 0;
for (int l_pos_24 = OrdersTotal() – 1; l_pos_24 >= 0; l_pos_24–) {
OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_SELL) {
l_ticket_8 = OrderTicket();
if (l_ticket_8 > l_ticket_20) {
l_ord_open_price_0 = OrderOpenPrice();
ld_unused_12 = l_ord_open_price_0;
l_ticket_20 = l_ticket_8;
}
}
}
return (l_ord_open_price_0);
}

void watermark() {
string l_text_0 = “www.dpkforex.com : free donation LibertyReserve : U1240603”;
ObjectCreate(“dpkfx”, OBJ_LABEL, 0, 0, 0);
ObjectSetText(“dpkfx”, l_text_0, 8, “Verdana Bold”, Silver);
ObjectSet(“dpkfx”, OBJPROP_CORNER, 2);
ObjectSet(“dpkfx”, OBJPROP_XDISTANCE, 5);
ObjectSet(“dpkfx”, OBJPROP_YDISTANCE, 10);
}

void tprofit() {
string l_text_8;
string l_text_0 = “Asik nih dah capai TARGET..!!”;
ObjectCreate(“dpkfx”, OBJ_LABEL, 0, 0, 0);
ObjectSetText(“dpkfx”, l_text_0, 15, “Verdana Bold”, White);
ObjectSet(“dpkfx”, OBJPROP_CORNER, 2);
ObjectSet(“dpkfx”, OBJPROP_XDISTANCE, 5);
ObjectSet(“dpkfx”, OBJPROP_YDISTANCE, 40);
if (!IsTesting() && !IsDemo()) {
l_text_8 = “free donation LibertyReserve : U1240603”;
ObjectCreate(“dpkfx1”, OBJ_LABEL, 0, 0, 0);
ObjectSetText(“dpkfx1”, l_text_8, 10, “Verdana Bold”, g_color_432);
ObjectSet(“dpkfx1”, OBJPROP_CORNER, 2);
ObjectSet(“dpkfx1”, OBJPROP_XDISTANCE, 5);
ObjectSet(“dpkfx1”, OBJPROP_YDISTANCE, 26);
}
}
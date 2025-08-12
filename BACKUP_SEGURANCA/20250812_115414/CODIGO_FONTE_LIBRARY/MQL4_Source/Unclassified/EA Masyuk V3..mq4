//+------------------------------------------------------------------+
//|                                                 EA Masyuk V3.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "MASYUK V3™"
#property link      "http://pipmaster.freehostia.com/forex"

extern int MagicNo = 130883;
extern double Lots = 0.01;
extern int Pips = 30;
extern double TakeProfit = 45.0;
extern double Multiplier = 1.799;
extern int MaxTrades = 10;
extern string Pengurusan_Hari = "Hari Off EA - Jumlah hari berforex";
extern int Jumlah_Hari_Trade = 5;
extern string Pengurusan_Masa = "Waktu Off EA hari terakhir - Ikut jam server";
extern int Waktu_Tamat = 23;
extern int slippage = 3;
double g_lots_140;
int g_period_148 = 7;
int gi_152 = 0;
int g_ma_method_156 = MODE_LWMA;
int g_applied_price_160 = PRICE_WEIGHTED;
int gi_unused_164 = 100;
extern double Step = 0.02;
extern double Max = 0.2;
int gi_184;

int deinit() {
   return (0);
}

int init() {
   gi_184 = MathRound((-MathLog(MarketInfo(Symbol(), MODE_LOTSTEP))) / 2.302585093);
   return (0);
}

void OpenBuy() {
   int l_ticket_0;
   if (!GlobalVariableCheck("InTrade")) {
      GlobalVariableSet("InTrade", TimeCurrent());
      l_ticket_0 = OrderSend(Symbol(), OP_BUY, g_lots_140, Ask, slippage, 0, Ask + TakeProfit * Point, "Buy™", MagicNo, 0, Blue);
      GlobalVariableDel("InTrade");
   }
}

void OpenSell() {
   int l_ticket_0;
   if (!GlobalVariableCheck("InTrade")) {
      GlobalVariableSet("InTrade", TimeCurrent());
      l_ticket_0 = OrderSend(Symbol(), OP_SELL, g_lots_140, Bid, slippage, 0, Bid - TakeProfit * Point, "Sell™", MagicNo, 0, Red);
      GlobalVariableDel("InTrade");
   }
}

void ManageBuy() {
   int l_datetime_0 = 0;
   double l_ord_open_price_4 = 0;
   double l_ord_lots_12 = 0;
   double l_ord_takeprofit_20 = 0;
   int l_cmd_28 = -1;
   int l_ticket_32 = 0;
   int l_pos_36 = 0;
   for (l_pos_36 = 0; l_pos_36 < OrdersTotal(); l_pos_36++) {
      OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() != MagicNo || OrderType() != OP_BUY) continue;
      if (OrderOpenTime() > l_datetime_0) {
         l_datetime_0 = OrderOpenTime();
         l_ord_open_price_4 = OrderOpenPrice();
         l_cmd_28 = OrderType();
         l_ticket_32 = OrderTicket();
         l_ord_takeprofit_20 = OrderTakeProfit();
      }
      if (OrderLots() > l_ord_lots_12) l_ord_lots_12 = OrderLots();
   }
   double l_isar_40 = iSAR(NULL, 0, Step, Max, 0);
   double l_ima_48 = iMA(NULL, 0, g_period_148, gi_152, g_ma_method_156, g_applied_price_160, 0);
   int li_56 = MathRound(MathLog(l_ord_lots_12 / Lots) / MathLog(Multiplier)) + 1.0;
   if (li_56 < 0) li_56 = 0;
   g_lots_140 = NormalizeDouble(Lots * MathPow(Multiplier, li_56), gi_184);
   if ((li_56 == 0 && l_isar_40 < l_ima_48 && DayOfWeek() < Jumlah_Hari_Trade) || (li_56 == 0 && l_isar_40 < l_ima_48 && DayOfWeek() == Jumlah_Hari_Trade && Hour() <= Waktu_Tamat)) OpenBuy();
   if (l_ord_open_price_4 - Ask > Pips * Point && li_56 < MaxTrades) {
      OpenBuy();
      return;
   }
   for (l_pos_36 = 0; l_pos_36 < OrdersTotal(); l_pos_36++) {
      OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() != MagicNo || OrderType() != OP_BUY || OrderTakeProfit() == l_ord_takeprofit_20 || l_ord_takeprofit_20 == 0.0) continue;
      OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), l_ord_takeprofit_20, 0, Red);
   }
}

void ManageSell() {
   int l_datetime_0 = 0;
   double l_ord_open_price_4 = 0;
   double l_ord_lots_12 = 0;
   double l_ord_takeprofit_20 = 0;
   int l_cmd_28 = -1;
   int l_ticket_32 = 0;
   int l_pos_36 = 0;
   for (l_pos_36 = 0; l_pos_36 < OrdersTotal(); l_pos_36++) {
      OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() != MagicNo || OrderType() != OP_SELL) continue;
      if (OrderOpenTime() > l_datetime_0) {
         l_datetime_0 = OrderOpenTime();
         l_ord_open_price_4 = OrderOpenPrice();
         l_cmd_28 = OrderType();
         l_ticket_32 = OrderTicket();
         l_ord_takeprofit_20 = OrderTakeProfit();
      }
      if (OrderLots() > l_ord_lots_12) l_ord_lots_12 = OrderLots();
   }
   double l_isar_40 = iSAR(NULL, 0, Step, Max, 0);
   double l_ima_48 = iMA(NULL, 0, g_period_148, gi_152, g_ma_method_156, g_applied_price_160, 0);
   int li_56 = MathRound(MathLog(l_ord_lots_12 / Lots) / MathLog(Multiplier)) + 1.0;
   if (li_56 < 0) li_56 = 0;
   g_lots_140 = NormalizeDouble(Lots * MathPow(Multiplier, li_56), gi_184);
   if ((li_56 == 0 && l_isar_40 > l_ima_48 && DayOfWeek() < Jumlah_Hari_Trade) || (li_56 == 0 && l_isar_40 > l_ima_48 && DayOfWeek() == Jumlah_Hari_Trade && Hour() <= Waktu_Tamat)) OpenSell();
   if (Bid - l_ord_open_price_4 > Pips * Point && l_ord_open_price_4 > 0.0 && li_56 < MaxTrades) {
      OpenSell();
      return;
   }
   for (l_pos_36 = 0; l_pos_36 < OrdersTotal(); l_pos_36++) {
      OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() != MagicNo || OrderType() != OP_SELL || OrderTakeProfit() == l_ord_takeprofit_20 || l_ord_takeprofit_20 == 0.0) continue;
      OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), l_ord_takeprofit_20, 0, Red);
   }
}

int start() {
   if (Check() != 0) {
      ManageBuy();
      ManageSell();
      ChartComment();
      return (0);
   }
   return (0);
}

void ChartComment() {
   string l_dbl2str_0 = DoubleToStr(balanceDeviation(2), 2);
   Comment(" \nMASYUK V3™ ", 
      "\nAccount Equity  = ", AccountEquity(), 
      "\nFree Margin     = ", AccountFreeMargin(), 
      "\nDrawdown  =  ", l_dbl2str_0, "%\n", 
   "\nTotal Profit/Loss = ", AccountProfit());
}

int Check() {
   return (1);
}

double balanceDeviation(int ai_0) {
   double ld_ret_4;
   if (ai_0 == 2) {
      ld_ret_4 = (AccountEquity() / AccountBalance() - 1.0) / (-0.01);
      if (ld_ret_4 > 0.0) return (ld_ret_4);
      return (0);
   }
   if (ai_0 == 1) {
      ld_ret_4 = 100.0 * (AccountEquity() / AccountBalance() - 1.0);
      if (ld_ret_4 > 0.0) return (ld_ret_4);
      return (0);
   }
   return (0.0);
}
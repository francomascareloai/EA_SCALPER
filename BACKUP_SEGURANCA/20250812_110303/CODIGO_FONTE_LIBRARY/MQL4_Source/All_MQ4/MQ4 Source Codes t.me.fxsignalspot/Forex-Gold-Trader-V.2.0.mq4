#property copyright "Copyright ?2010, Forex Gold Trader."
#property link      "http://www.forexgoldtrader.com"

#include <stdlib.mqh>

extern string Tittle = "ForexGoldTrader.com";
extern string reference = "1";
extern int UseFilter = 0;
extern int MaxTrades = 25;
extern double MaxRisk = -99999.0;
extern int TakeProfit = 600;
extern double minLot = 0.01;
extern double maxLot = 10.0;
extern double staticLot = 0.0;
extern double dynamicLot = 1.0;
extern bool ECNBroker = FALSE;
extern bool FifoRule = FALSE;
extern string Note = "Ignore variables below";
extern bool x1 = FALSE;
extern bool x2 = FALSE;

int init() {
   string ls_unused_0;
   string ls_8;
   string ls_16;
   string ls_24;
   string l_dbl2str_32;
   string ls_40;
   string ls_48;
   string ls_56;
/*
   if (reference == "0") {
      Comment("\n\nError!!Please fill your REFERENCE NUMBER!");
      return (0);
   }
*/
   if (IsConnected() && IsDllsAllowed() && IsExpertEnabled()) {
      if (IsTesting()) ls_8 = "1";
      else ls_8 = "0";
      ls_16 = "C:\\FGT20" + Symbol() + 60 + AccountNumber() + ls_8 + "1.txt";
      ls_24 = "C:\\FGT20" + Symbol() + 60 + AccountNumber() + ls_8 + "2.txt";
      l_dbl2str_32 = DoubleToStr(AccountNumber(), 0);
      ls_40 = AccountName();
      ls_48 = reference;
      ls_56 = ReadSN(ls_24);
      Print("License Number : " + ls_56);
      Print("Server Status : Connecting...");
      Print("Server Status : Connected...");
      Print("Server Status : " + ReadHttp(ls_48, ls_56, ls_16));
   }
   return (0);
}

int start() {
   string ls_8;
   string ls_16;
   string ls_344;
   string ls_0 = StringSubstr(Symbol(), 0, 3);
   if (IsTesting()) ls_16 = "1";
   else ls_16 = "0";
   string ls_24 = "C:\\FGT20" + Symbol() + 60 + AccountNumber() + ls_16 + "1.txt";
   string ls_32 = "C:\\FGT20" + Symbol() + 60 + AccountNumber() + ls_16 + "2.txt";
   if (IsDemo()) ls_8 = "Demo Account";
   else ls_8 = "Live Account";
   if (reference == "0") {
      Comment("\n\nError!!Please fill your REFERENCE NUMBER!");
      return (0);
   }
   if (!IsConnected()) {
      Comment("\n\nError!!You must connected with internet! Please check your connection...");
      return (0);
   }
   if (!IsDllsAllowed()) {
      Comment("\n\nError!!You must enable \'Allow DLL Import\'!");
      return (0);
   }
   if (!IsExpertEnabled()) {
      Comment("\n\nError!!You must enable \'Enable Expert Advisor\'!");
      return (0);
   }
   if (Period() != PERIOD_H1) {
      Comment("\n\nError!!You must use 1H Period!");
      return (0);
   }
   if (ls_0 == "GBP" || ls_0 == "EUR" || ls_0 == "USD" || ls_0 == "JPY" || ls_0 == "CAD" || ls_0 == "AUD" || ls_0 == "NZD" || ls_0 == "CHF") {
      Comment("\n\nError!!FGT EA support for Gold or Silver only!");
      return (0);
   }
   int li_40 = 0;
   int l_digits_44 = MarketInfo(Symbol(), MODE_DIGITS);
   if (l_digits_44 == 3) li_40 = 10 * TakeProfit;
   else li_40 = TakeProfit;
   string l_dbl2str_48 = DoubleToStr(AccountNumber(), 0);
   string ls_56 = AccountName();
   string ls_64 = reference;
   string ls_72 = ReadSN(ls_32);
   string ls_80 = ReadStatus(ls_24, ls_32);
   double l_price_88 = NormalizeDouble(MarketInfo(Symbol(), MODE_ASK), Digits);
   double ld_96 = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits);
   double l_point_104 = MarketInfo(Symbol(), MODE_POINT);
   int li_112 = CountOrders(Symbol(), OP_BUY);
   int li_116 = CountOrders(Symbol(), OP_BUYSTOP);
   int li_120 = CountOrders(Symbol(), OP_SELL);
   string l_time2str_124 = TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS);
   string ls_132 = AccountCompany();
   string ls_140 = Symbol();
   string l_dbl2str_148 = DoubleToStr(AccountNumber(), 0);
   string ls_156 = AccountName();
   string l_dbl2str_164 = DoubleToStr(li_112, 0);
   string l_dbl2str_172 = DoubleToStr(li_116, 0);
   string l_dbl2str_180 = DoubleToStr(getProfit(), 2);
   string l_dbl2str_188 = DoubleToStr(li_40, 0);
   string l_dbl2str_196 = DoubleToStr(MaxRisk, 2);
   string l_dbl2str_204 = DoubleToStr(MarketInfo(Symbol(), MODE_LOTSTEP), 2);
   string l_dbl2str_212 = DoubleToStr(AccountLeverage(), 0);
   double l_lots_220 = 0;
   if (staticLot == 0.0) {
      l_lots_220 = NormalizeDouble(GetLot(ls_64, ls_72, ls_24, ls_32, AccountBalance(), ls_0 == "GBP" || ls_0 == "EUR" || ls_0 == "USD" || ls_0 == "JPY" || ls_0 == "CAD" ||
         ls_0 == "AUD" || ls_0 == "NZD" || ls_0 == "CHF", dynamicLot, minLot, maxLot), 2);
   } else l_lots_220 = staticLot;
   string l_dbl2str_228 = DoubleToStr(l_lots_220, 2);
   int li_unused_236 = 1;
   string ls_240 = "";
   string ls_248 = "";
   if (ECNBroker) ls_240 = "Yes";
   else ls_240 = "No";
   if (FifoRule) ls_248 = "Yes";
   else ls_248 = "No";
   string ls_256 = "tes";
   if (AccountFreeMargin() < 1000.0) ls_256 = "Please use balance $1000 for the best result.";
   if (AccountFreeMargin() > 1000.0 && AccountFreeMargin() < 2000.0) ls_256 = "You can set staticlot=0.01 to trade Gold or Silver (choose one)";
   if (AccountFreeMargin() > 2000.0 && AccountFreeMargin() < 3000.0) ls_256 = "You can set staticlot=0.01 to trade Gold and Silver \n    or you can trade 0.02 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 3000.0 && AccountFreeMargin() < 4000.0) ls_256 = "You can set staticlot=0.02 to trade Gold and Silver \n    or you can trade 0.03 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 4000.0 && AccountFreeMargin() < 5000.0) ls_256 = "You can set staticlot=0.02 to trade Gold and Silver \n    or you can trade 0.04 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 5000.0 && AccountFreeMargin() < 6000.0) ls_256 = "You can set staticlot=0.03 to trade Gold and Silver \n    or you can trade 0.05 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 6000.0 && AccountFreeMargin() < 7000.0) ls_256 = "You can set staticlot=0.03 to trade Gold and Silver \n    or you can trade 0.06 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 7000.0 && AccountFreeMargin() < 8000.0) ls_256 = "You can set staticlot=0.04 to trade Gold and Silver \n    or you can trade 0.07 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 8000.0 && AccountFreeMargin() < 9000.0) ls_256 = "You can set staticlot=0.04 to trade Gold and Silver \n    or you can trade 0.08 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 9000.0 && AccountFreeMargin() < 10000.0) ls_256 = "You can set staticlot=0.05 to trade Gold and Silver \n    or you can trade 0.09 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 10000.0 && AccountFreeMargin() < 20000.0) ls_256 = "You can set staticlot=0.05 to trade Gold and Silver \n    or you can trade 0.10 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 20000.0 && AccountFreeMargin() < 30000.0) ls_256 = "You can set staticlot=0.10 to trade Gold and Silver \n    or you can trade 0.20 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 30000.0 && AccountFreeMargin() < 40000.0) ls_256 = "You can set staticlot=0.20 to trade Gold and Silver \n    or you can trade 0.30 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 40000.0 && AccountFreeMargin() < 50000.0) ls_256 = "You can set staticlot=0.20 to trade Gold and Silver \n    or you can trade 0.40 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 50000.0 && AccountFreeMargin() < 60000.0) ls_256 = "You can set staticlot=0.30 to trade Gold and Silver \n    or you can trade 0.50 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 60000.0 && AccountFreeMargin() < 70000.0) ls_256 = "You can set staticlot=0.30 to trade Gold and Silver \n    or you can trade 0.60 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 70000.0 && AccountFreeMargin() < 80000.0) ls_256 = "You can set staticlot=0.40 to trade Gold and Silver \n    or you can trade 0.70 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 80000.0 && AccountFreeMargin() < 90000.0) ls_256 = "You can set staticlot=0.40 to trade Gold and Silver \n    or you can trade 0.80 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 90000.0 && AccountFreeMargin() < 100000.0) ls_256 = "You can set staticlot=0.50 to trade Gold and Silver \n    or you can trade 0.90 lot GOLD or SILVER only.";
   if (AccountFreeMargin() > 100000.0 && AccountFreeMargin() < 200000.0) ls_256 = "You can set staticlot=0.50 to trade Gold and Silver \n    or you can trade 1.00 lot GOLD or SILVER only.";
   int l_magic_264 = StrToDouble(reference);
   double l_ima_268 = 0;
   double l_ima_276 = 0;
   double l_ima_284 = 0;
   double l_ima_292 = 0;
   double l_ima_300 = 0;
   if (UseFilter == 1) {
      l_ima_268 = iMA(Symbol(), 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
      l_ima_276 = iMA(Symbol(), 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
      l_ima_284 = iMA(Symbol(), 0, 30, 0, MODE_EMA, PRICE_CLOSE, 0);
      l_ima_292 = iMA(Symbol(), 0, 40, 0, MODE_EMA, PRICE_CLOSE, 0);
      l_ima_300 = iMA(Symbol(), 0, 50, 0, MODE_EMA, PRICE_CLOSE, 0);
   }
   double l_ord_open_price_308 = 0;
   for (int l_pos_316 = 0; l_pos_316 < OrdersTotal(); l_pos_316++) {
      OrderSelect(l_pos_316, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == StrToDouble(reference))
         if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) l_ord_open_price_308 = OrderOpenPrice();
   }
   string ls_320 = GetInstantOrder(ls_64, ls_72, ls_24, ls_32, li_112, li_116, UseFilter, l_price_88, l_ima_276, l_ima_284, l_ima_292, l_ima_300);
   string ls_328 = GetPendingOrder(ls_64, ls_72, ls_24, ls_32, li_112, li_116, l_ord_open_price_308, l_price_88, li_40, MaxTrades, l_point_104, UseFilter, l_ima_276, l_ima_284, l_ima_292, l_ima_300);
   double l_price_336 = NormalizeDouble(l_ord_open_price_308 - li_40 * Point, Digits);
   if (ls_72 == ls_80) ls_344 = "PC & Server License Matched!";
   else ls_344 = "ERROR!! PC & Server License Unmatched!";
   if (getProfit() < MaxRisk && MaxRisk < 0.0) CloseAll(Symbol());
   if (FifoRule && getProfit() > TakeProfit * l_lots_220) CloseAll(Symbol());
   if (FifoRule && x1 && getProfit() > TakeProfit * l_lots_220 / 10.0) CloseAll(Symbol());
   string ls_352 = "\n---------------------------------------------------------------------------------------------------";
   ls_352 = ls_352 
   + "\n    FOREX GOLD TRADER V.2.1 (GOLD & SILVER)";
   ls_352 = ls_352 
   + "\n    New features : Smart Entry, Reduce DD, MM Added, SL Added, FIFO Rule Added";
   ls_352 = ls_352 
   + "\n---------------------------------------------------------------------------------------------------";
   ls_352 = ls_352 
   + "\n    - Broker Time : " + l_time2str_124;
   ls_352 = ls_352 
   + "\n    - Broker Name : " + ls_132;
   ls_352 = ls_352 
   + "\n    - ECN Broker : " + ls_240;
   ls_352 = ls_352 
   + "\n    - FIFO Rule : " + ls_248;
   ls_352 = ls_352 
   + "\n    - Currency : " + Symbol();
   ls_352 = ls_352 
   + "\n    - Account Number : " + AccountNumber() + " (" + ls_8 + ")";
   ls_352 = ls_352 
   + "\n    - Account Name : " + AccountName();
   ls_352 = ls_352 
   + "\n    - PC License : " + ls_72;
   ls_352 = ls_352 
   + "\n    - Server License : " + ls_80;
   ls_352 = ls_352 
   + "\n    - License Status : " + ls_344;
   ls_352 = ls_352 
   + "\n    - Reference Number : " + ls_64;
   ls_352 = ls_352 
   + "\n---------------------------------------------------------------------------------------------------";
   ls_352 = ls_352 
   + "\n    - Current Balance : " + DoubleToStr(AccountBalance(), 2);
   ls_352 = ls_352 
   + "\n    - Current Profit " + Symbol() + " : " + DoubleToStr(getProfit(), 2);
   ls_352 = ls_352 
   + "\n    - Use Filter : " + UseFilter;
   ls_352 = ls_352 
   + "\n    - Total Buy Order : " + li_112;
   ls_352 = ls_352 
   + "\n    - Total Buy Stop Order : " + li_116;
   ls_352 = ls_352 
   + "\n    - Instant Order Status : " + ls_320;
   ls_352 = ls_352 
   + "\n    - Pending Order Status : " + ls_328;
   ls_352 = ls_352 
   + "\n    - Minimum Lot : " + DoubleToStr(minLot, 2);
   ls_352 = ls_352 
   + "\n    - Maximum Lot : " + DoubleToStr(maxLot, 2);
   ls_352 = ls_352 
   + "\n    - Lot Size : " + DoubleToStr(l_lots_220, 2);
   ls_352 = ls_352 
   + "\n    - Target Profit : " + li_40 + " pips";
   ls_352 = ls_352 
   + "\n    - Maximum Risk : " + DoubleToStr(MaxRisk, 2);
   ls_352 = ls_352 
   + "\n---------------------------------------------------------------------------------------------------";
   ls_352 = ls_352 
   + "\n    Recommendation:";
   ls_352 = ls_352 
   + "\n    " + ls_256;
   ls_352 = ls_352 
   + "\n---------------------------------------------------------------------------------------------------";
   ls_352 = ls_352 
   + "\n    If you have any problem or question, please do not hesitate to contact us";
   ls_352 = ls_352 
   + "\n    Vendor Website : http://forexgoldtrader.com";
   ls_352 = ls_352 
   + "\n    Vendor Email : support@forexgoldtrader.com";
   ls_352 = ls_352 
   + "\n";
   ls_352 = ls_352 
   + "\n    This EA protected by MQLProtector.com";
   ls_352 = ls_352 
   + "\n    (Anti Decompiler and Theft System for MT4 and MT5)";
   ls_352 = ls_352 
   + "\n---------------------------------------------------------------------------------------------------";
   Comment(ls_352);
   int l_ticket_360 = 0;
   if (!ECNBroker) {
      if (ls_320 == "OP_BUY") {
         if (!FifoRule) l_ticket_360 = OrderSend(Symbol(), OP_BUY, l_lots_220, l_price_88, (l_price_88 - ld_96) * Point, 0, l_price_88 + li_40 * Point, DoubleToStr(l_magic_264, 0), l_magic_264, 0, Blue);
         if (FifoRule) l_ticket_360 = OrderSend(Symbol(), OP_BUY, l_lots_220, l_price_88, (l_price_88 - ld_96) * Point, 0, 0, DoubleToStr(l_magic_264, 0), l_magic_264, 0, Blue);
         if (l_ticket_360 > 0) Print("Forex Gold Trader Open BUY [OK]");
         else Print("Forex Gold Trader Open BUY [Error] : " + ErrorDescription(GetLastError()));
         return (0);
      }
      if (ls_328 == "OP_BUYSTOP") {
         if (!FifoRule) l_ticket_360 = OrderSend(Symbol(), OP_BUYSTOP, l_lots_220, l_price_336, (l_price_88 - ld_96) * Point, 0, l_price_336 + li_40 * Point, DoubleToStr(l_magic_264, 0), l_magic_264, 0, Blue);
         if (FifoRule) l_ticket_360 = OrderSend(Symbol(), OP_BUYSTOP, l_lots_220, l_price_336, (l_price_88 - ld_96) * Point, 0, 0, DoubleToStr(l_magic_264, 0), l_magic_264, 0, Blue);
         if (l_ticket_360 > 0) Print("Forex Gold Trader Open BUY STOP [OK]");
         else Print("Forex Gold Trader Open BUY STOP [Error] : " + ErrorDescription(GetLastError()));
         return (0);
      }
   } else {
      if (ls_320 == "OP_BUY") {
         l_ticket_360 = OrderSend(Symbol(), OP_BUY, l_lots_220, l_price_88, (l_price_88 - ld_96) * Point, 0, 0, DoubleToStr(l_magic_264, 0), l_magic_264, 0, Blue);
         if (l_ticket_360 > 0) {
            Print("Forex Gold Trader Open BUY [OK]");
            if (!FifoRule) {
               for (l_pos_316 = 0; l_pos_316 < OrdersTotal(); l_pos_316++) {
                  OrderSelect(l_pos_316, SELECT_BY_POS, MODE_TRADES);
                  if (OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderMagicNumber() == l_magic_264 && OrderTakeProfit() == 0.0) OrderModify(OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() + li_40 * Point, 0, Blue);
               }
            }
         } else Print("Forex Gold Trader Open BUY [Error] : " + ErrorDescription(GetLastError()));
         return (0);
      }
      if (ls_328 == "OP_BUYSTOP") {
         l_ticket_360 = OrderSend(Symbol(), OP_BUYSTOP, l_lots_220, l_price_336, (l_price_88 - ld_96) * Point, 0, 0, DoubleToStr(l_magic_264, 0), l_magic_264, 0, Blue);
         if (l_ticket_360 > 0) {
            Print("Forex Gold Trader Open BUY STOP [OK]");
            if (!FifoRule) {
               for (l_pos_316 = 0; l_pos_316 < OrdersTotal(); l_pos_316++) {
                  OrderSelect(l_pos_316, SELECT_BY_POS, MODE_TRADES);
                  if (OrderSymbol() == Symbol() && OrderType() == OP_BUYSTOP && OrderMagicNumber() == l_magic_264 && OrderTakeProfit() == 0.0) OrderModify(OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() + li_40 * Point, 0, Blue);
               }
            }
         } else Print("Forex Gold Trader Open BUY STOP [Error] : " + ErrorDescription(GetLastError()));
         return (0);
      }
   }
   return (0);
}

int CountOrders(string a_symbol_0 = "", int a_cmd_8 = -1) {
   int l_count_12 = 0;
   int l_ord_total_16 = OrdersTotal();
   for (int l_pos_20 = 0; l_pos_20 < l_ord_total_16; l_pos_20++) {
      OrderSelect(l_pos_20, SELECT_BY_POS, MODE_TRADES);
      if (Symbol() == "" || OrderSymbol() == a_symbol_0 && a_cmd_8 == -1 || OrderType() == a_cmd_8 && OrderMagicNumber() == StrToDouble(reference)) l_count_12++;
   }
   return (l_count_12);
}

double getProfit() {
   double ld_ret_0 = 0;
   for (int l_ord_total_8 = OrdersTotal(); l_ord_total_8 >= 0; l_ord_total_8--) {
      if (OrderSelect(l_ord_total_8, SELECT_BY_POS, MODE_TRADES))
         if (OrderMagicNumber() == StrToDouble(reference) && OrderSymbol() == Symbol()) ld_ret_0 = ld_ret_0 + OrderProfit() + OrderSwap() + OrderCommission();
   }
   return (ld_ret_0);
}

int CloseAll(string as_0 = "") {
   int l_cmd_16;
   bool li_20;
   int l_ord_total_8 = OrdersTotal();
   for (int l_pos_12 = l_ord_total_8 - 1; l_pos_12 >= 0; l_pos_12--) {
      if (OrderSelect(l_pos_12, SELECT_BY_POS) && as_0 == Symbol() && OrderMagicNumber() == NormalizeDouble(StrToDouble(reference), 0)) {
         l_cmd_16 = OrderType();
         li_20 = FALSE;
         switch (l_cmd_16) {
         case OP_BUY:
            li_20 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
            break;
         case OP_SELL:
            li_20 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
            break;
         case OP_BUYLIMIT:
         case OP_BUYSTOP:
         case OP_SELLLIMIT:
         case OP_SELLSTOP:
            li_20 = OrderDelete(OrderTicket());
         }
         if (li_20 == FALSE) Sleep(3000);
      }
   }
   return (0);
}

   string ReadHttp(string a0, string a1, string a2)
{
	return ("OK");
}
   string ReadStatus(string a0, string a1)
{
	return ("OK");
}
   string ReadSN(string a0)
{
	return ("OK");
}
   double GetLot(string a0, string a1, string a2, string a3, double a4, double a5, double a6, double a7, double a8)
{
  double result; 
    result = a6 / 100.0 * a4 / 1000.0;
    if ( a7 > result )
      result = a7;
    if ( a8 < result )
      result = a8;
 
  return (result);

}
   string GetInstantOrder(string a0, string a1, string a2, string a3, int a4, int a5, int a6, double a7, double a8, double a9, double a10, double a11)
{
    if ( !a6 )
    {
      if ( (!a4) && (a5 == a6) )
        return ("OP_BUY");
      return ("NO_TRADE");
    }
    if ( (a6 != 1) || a4 || a5 || (a11 >= a7) )
      return ("NO_TRADE");
    return ("OP_BUY");

}
   string GetPendingOrder(string a0, string a1, string a2, string a3, int a4, int a5, double a6, double a7, int a8, int a9, double a10, int a11, double a12, double a13, double a14, double a15)
{
    if ( !a11 )
    {
      if ( a4 > 0 && a4 < a9 && (a8 + a8) * a10 <= a6 - a7 )
        return ("OP_BUYSTOP");
      return ("NO_TRADE");
    }
    if ( a11 == 1 )
    {
      if ( a4 <= 0 || a4 >= a9 || (a8 + a8) * a10 > a6 - a7 || a7 <= a15 )
        return ("NO_TRADE");
      return ("OP_BUYSTOP");
    }
    else
    {
      return ("NO_TRADE");
    }

}
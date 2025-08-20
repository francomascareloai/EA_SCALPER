#property copyright "Forexzone Ltd."
#property link      "http://www.forexzoneltd.co.uk"

#import "PipsMinerLib_SE.dll"
   int TLV(double a0, double a1, double a2, double a3, double a4, double a5, string a6, int a7, int a8);
   int TSV(double a0, double a1, double a2, double a3, double a4, double a5, string a6, int a7, int a8);
   int PLV(double a0, double a1, double a2, double a3, double a4, double a5, double a6, string a7, int a8, int a9);
   int PSV(double a0, double a1, double a2, double a3, double a4, double a5, double a6, string a7, int a8, int a9);
   double LND_Stock(double a0, double a1, double a2, double a3, double a4, string a5, int a6, int a7);
#import

extern string VersionDesc = "PipsMiner SEv1.3 M5 EURUSD";
extern double Lots = 0.1;
extern int Magic_Number = 73337;
extern int London_Time_Shift = 0;
int gi_176 = 4;
int gi_188 = 3;
int gi_196 = 30;
int gi_200 = 210;
int gi_204 = 7;
int g_count_208 = 0;
double g_y_212 = 20.0;
bool gba_224[20];
int g_ticket_228 = 0;
int g_bars_232 = 0;
int g_ticket_236 = 0;
int gia_248[200][2];
int g_index_252 = 0;
int gi_256 = 0;
int gi_260 = 0;
double gd_268 = 0.0;
int g_shift_284 = 0;
int gi_288 = 1;
double gd_296 = 0.0;

string GetCurrentDate() {
   int l_year_0 = 0;
   int l_month_4 = 0;
   int l_day_8 = 0;
   int l_hour_12 = 0;
   int l_minute_16 = 0;
   int l_second_20 = 0;
   string ls_24 = "";
   string ls_32 = "";
   string ls_40 = "";
   string ls_48 = "";
   string ls_56 = "";
   string ls_ret_64 = "";
   l_year_0 = TimeYear(TimeCurrent());
   l_month_4 = TimeMonth(TimeCurrent());
   l_day_8 = TimeDay(TimeCurrent());
   l_hour_12 = TimeHour(TimeCurrent());
   l_minute_16 = TimeMinute(TimeCurrent());
   l_second_20 = TimeSeconds(TimeCurrent());
   if (l_month_4 < 10) ls_24 = "0" + l_month_4;
   else ls_24 = "" + l_month_4;
   if (l_day_8 < 10) ls_32 = "0" + l_day_8;
   else ls_32 = "" + l_day_8;
   if (l_hour_12 < 10) ls_40 = "0" + l_hour_12;
   else ls_40 = "" + l_hour_12;
   if (l_minute_16 < 10) ls_48 = "0" + l_minute_16;
   else ls_48 = "" + l_minute_16;
   if (l_second_20 < 10) ls_56 = "0" + l_minute_16;
   else ls_56 = "" + l_second_20;
   ls_ret_64 = l_year_0 + "-" + ls_24 + "-" + ls_32 + " " + ls_40 + ":" + ls_48 + ":" + ls_56;
   return (ls_ret_64);
}

int RmLabel(string a_name_0) {
   int li_8 = 0;
   li_8 = ObjectFind(a_name_0);
   if (li_8 == -1) return (0);
   li_8 = ObjectDelete(a_name_0);
   if (li_8 == 0) return (-1);
   g_count_208--;
   g_y_212 -= 14.0;
   if (g_count_208 < 0) g_count_208 = 0;
   if (g_y_212 < 0.0) g_y_212 = 20;
   return (1);
}

int AddLabel(string a_name_0, string as_8) {
   if (ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0) == FALSE) {
      Print("[AddLabel]Object create ERROR");
      return (0);
   }
   if (ObjectSet(a_name_0, OBJPROP_XDISTANCE, 20) == FALSE) {
      Print("[AddLabel]Object set XDISTANCE ERROR");
      return (0);
   }
   if (ObjectSet(a_name_0, OBJPROP_YDISTANCE, g_y_212) == FALSE) {
      Print("[AddLabel]Object set YDISTANCE ERROR");
      return (0);
   }
   if (ObjectSet(a_name_0, OBJPROP_FONTSIZE, 10) == FALSE) {
      Print("[AddLabel] ObjectSet OBJPROP_FONTSIZE ERROR");
      return (0);
   }
   if (SetLabelText(a_name_0, as_8) == 0) {
      Print("[AddLabel]Object set text ERROR");
      return (0);
   }
   g_count_208++;
   g_y_212 += 14.0;
   return (1);
}

int SetLabelText(string a_name_0, string a_text_8) {
   if (ObjectSetText(a_name_0, a_text_8, 10, "Times New Roman", Yellow) == FALSE) return (0);
   return (1);
}

void IPO() {
   for (int l_index_0 = 0; l_index_0 < 200; l_index_0++) {
      gia_248[l_index_0][0] = 0;
      gia_248[l_index_0][1] = 0;
   }
}

void SORD(int ai_0) {
   if (g_index_252 < 200) {
      gia_248[g_index_252][0] = ai_0;
      gia_248[g_index_252][1] = 0;
   } else {
      g_index_252 = 0;
      gia_248[g_index_252][0] = ai_0;
      gia_248[g_index_252][1] = 0;
   }
   g_index_252++;
}

int UPO(int ai_0) {
   int l_index_4 = 0;
   bool li_8 = FALSE;
   while (l_index_4 < 200) {
      li_8 = gia_248[l_index_4][0];
      if (li_8 == gi_256) {
         gia_248[l_index_4][1] = ai_0;
         return (0);
      }
      l_index_4++;
   }
   return (-1);
}

double R_PRCE(int ai_0) {
   double l_price_4 = 0;
   switch (ai_0) {
   case 1:
      l_price_4 = Ask;
      break;
   case 2:
      l_price_4 = Bid;
   }
   l_price_4 = NormalizeDouble(l_price_4, Digits);
   return (l_price_4);
}

double R_PRF(int ai_0) {
   double ld_4 = 0;
   switch (ai_0) {
   case 1:
      ld_4 = Bid + gi_196 * Point;
      break;
   case 2:
      ld_4 = Ask - gi_196 * Point;
   }
   ld_4 = NormalizeDouble(ld_4, Digits);
   return (ld_4);
}

double R_LSS(int ai_0) {
   double ld_4 = 0;
   switch (ai_0) {
   case 1:
      ld_4 = Bid - gi_200 * Point;
      break;
   case 2:
      ld_4 = Ask + gi_200 * Point;
   }
   ld_4 = NormalizeDouble(ld_4, Digits);
   return (0.0);
}

int OpenOrder(int ai_0, int ai_4, int ai_8, double a_lots_12) {
   color l_color_64;
   int li_unused_68;
   string ls_20 = "";
   bool li_28 = FALSE;
   int l_cmd_32 = 0;
   int l_error_36 = 0;
   double l_price_40 = 0;
   double l_price_48 = 0;
   double l_price_56 = 0;
   string ls_72 = "";
   string l_symbol_80 = Symbol();
   string l_comment_88 = "";
   double l_stoplevel_96 = 0;
   int li_unused_104 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   l_comment_88 = "PipsMiner SEv1.3 M5 EURUSD" + " MAGIC: " + Magic_Number;
   li_28 = ai_0;
   RefreshRates();
   switch (li_28) {
   case 1:
      ls_20 = "BUY";
      l_cmd_32 = 0;
      l_price_40 = Ask;
      l_price_48 = Ask + ai_4 * Point;
      l_price_48 = NormalizeDouble(l_price_48, Digits);
      l_price_56 = Ask - ai_8 * Point;
      l_price_56 = NormalizeDouble(l_price_56, Digits);
      l_color_64 = Green;
      li_unused_68 = 16711680;
      break;
   case 2:
      ls_20 = "SELL";
      l_cmd_32 = 1;
      l_price_40 = Bid;
      l_price_48 = Bid - ai_4 * Point;
      l_price_48 = NormalizeDouble(l_price_48, Digits);
      l_price_56 = Bid + ai_8 * Point;
      l_price_56 = NormalizeDouble(l_price_56, Digits);
      l_color_64 = Red;
      li_unused_68 = 65535;
      break;
   default:
      Print("[OpenOrder][MakeTransaction] Unknow Transaction Type: " + ai_0);
      return (-1);
   }
   if (ai_4 == 0) l_price_48 = 0;
   if (ai_8 == 0) l_price_56 = 0;
   l_price_40 = NormalizeDouble(l_price_40, Digits);
   l_stoplevel_96 = MarketInfo(l_symbol_80, MODE_STOPLEVEL);
   g_ticket_228 = OrderSend(l_symbol_80, l_cmd_32, a_lots_12, l_price_40, 3, l_price_56, l_price_48, l_comment_88, Magic_Number, 0, l_color_64);
   if (g_ticket_228 == -1) {
      l_error_36 = GetLastError();
      switch (l_error_36) {
      case 129/* INVALID_PRICE */:
         RefreshRates();
         Sleep(10000);
         l_price_40 = R_PRCE(ai_0);
         l_price_56 = R_LSS(ai_0);
         l_price_48 = R_PRF(ai_0);
         g_ticket_228 = OrderSend(l_symbol_80, l_cmd_32, a_lots_12, l_price_40, 3, l_price_56, l_price_48, l_comment_88, Magic_Number, 0, l_color_64);
         l_error_36 = GetLastError();
         break;
      case 130/* INVALID_STOPS */:
         g_ticket_228 = OrderSend(l_symbol_80, l_cmd_32, a_lots_12, l_price_40, 3, 0, 0, l_comment_88, Magic_Number, 0, l_color_64);
         if (g_ticket_228 == -1) {
            l_error_36 = GetLastError();
            if (l_error_36 == 129/* INVALID_PRICE */) {
               RefreshRates();
               Sleep(10000);
               l_price_40 = R_PRCE(ai_0);
               l_price_48 = R_PRF(ai_0);
               l_price_56 = R_LSS(ai_0);
               g_ticket_228 = OrderSend(l_symbol_80, l_cmd_32, a_lots_12, l_price_40, 3, 0, 0, l_comment_88, Magic_Number, 0, l_color_64);
               l_error_36 = GetLastError();
            }
         }
         if (g_ticket_228 > 0)
            if (OrderModify(g_ticket_228, l_price_40, l_price_56, l_price_48, 0, l_color_64) == FALSE) l_error_36 = GetLastError();
      }
   }
   ls_72 = GetCurrentDate();
   if (g_ticket_228 == -1) {
      Print("Order " + ls_20 + " Error: " + l_error_36);
      return (-1);
   }
   return (0);
}

int CloseOrder(int a_ticket_0) {
   int li_unused_4 = 0;
   int l_error_8 = 0;
   int l_cmd_12 = 0;
   bool l_ord_close_16 = FALSE;
   if (a_ticket_0 > 0) {
      if (OrderSelect(a_ticket_0, SELECT_BY_TICKET) == TRUE) {
         l_cmd_12 = OrderType();
         switch (l_cmd_12) {
         case OP_BUY:
            l_ord_close_16 = OrderClose(a_ticket_0, OrderLots(), Bid, 3, Yellow);
            if (l_ord_close_16 == 0) {
               l_error_8 = GetLastError();
               if (l_error_8 == 129/* INVALID_PRICE */) {
                  RefreshRates();
                  Sleep(10000);
                  l_ord_close_16 = OrderClose(a_ticket_0, OrderLots(), Bid, 3, Yellow);
                  if (l_ord_close_16 == 0) return (-1);
               }
            }
         case OP_SELL:
            l_ord_close_16 = OrderClose(a_ticket_0, OrderLots(), Ask, 3, Blue);
            if (l_ord_close_16 == 0) {
               l_error_8 = GetLastError();
               if (l_error_8 == 129/* INVALID_PRICE */) {
                  RefreshRates();
                  Sleep(10000);
                  l_ord_close_16 = OrderClose(a_ticket_0, OrderLots(), Ask, 3, Blue);
                  if (l_ord_close_16 == 0) return (-1);
               }
            }
         }
      }
   }
   return (0);
}

double CO_PL() {
   int l_ord_total_0 = 0;
   int l_cmd_4 = 0;
   int l_magic_8 = 0;
   int l_ticket_12 = 0;
   double l_ord_takeprofit_16 = 0;
   double l_ord_stoploss_24 = 0;
   string l_symbol_32 = 0;
   int l_pos_40 = 0;
   double ld_44 = 0;
   double ld_52 = 0;
   double l_ord_open_price_60 = 0;
   double ld_68 = 0;
   l_ord_total_0 = OrdersTotal();
   if (l_ord_total_0 == 0) return (0);
   while (l_pos_40 < l_ord_total_0) {
      if (OrderSelect(l_pos_40, SELECT_BY_POS) == TRUE) {
         l_magic_8 = OrderMagicNumber();
         if (l_magic_8 == Magic_Number) {
            l_symbol_32 = OrderSymbol();
            if (l_symbol_32 == Symbol()) {
               l_ord_takeprofit_16 = OrderTakeProfit();
               l_ord_stoploss_24 = OrderStopLoss();
               if (l_ord_takeprofit_16 == 0.0 && l_ord_stoploss_24 == 0.0) {
                  l_ord_open_price_60 = OrderOpenPrice();
                  l_cmd_4 = OrderType();
                  l_ticket_12 = OrderTicket();
                  ld_68 = gd_268 * Point;
                  switch (l_cmd_4) {
                  case OP_SELL:
                     ld_44 = l_ord_open_price_60 - (Bid + ld_68);
                     break;
                  case OP_BUY:
                     ld_44 = Bid - l_ord_open_price_60;
                  }
                  ld_44 = NormalizeDouble(ld_44, Digits);
                  ld_44 *= gd_296;
                  if (ld_44 < 0.0) ld_52 = MathAbs(ld_44);
                  if (ld_44 >= gi_196) CloseOrder(l_ticket_12);
                  if (ld_52 >= gi_200) CloseOrder(l_ticket_12);
               }
            }
         }
      }
      l_pos_40++;
   }
   return (0);
}

int OT() {
   int l_ord_total_0 = 0;
   int li_unused_4 = 0;
   int l_magic_8 = 0;
   string l_symbol_12 = "";
   int l_count_20 = 0;
   int l_pos_24 = 0;
   l_ord_total_0 = OrdersTotal();
   if (l_ord_total_0 == 0) return (0);
   for (l_pos_24 = 0; l_pos_24 < l_ord_total_0; l_pos_24++) {
      if (OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES) == TRUE) {
         l_symbol_12 = OrderSymbol();
         if (l_symbol_12 == Symbol()) {
            l_magic_8 = OrderMagicNumber();
            if (l_magic_8 == Magic_Number) l_count_20++;
         }
      }
   }
   return (l_count_20);
}

int MMX() {
   double l_point_0 = 0;
   int li_unused_8 = 1;
   l_point_0 = Point;
   if (l_point_0 >= 0.0001 && l_point_0 < 0.001) return (1);
   if (l_point_0 >= 0.01) return (1);
   return (10);
}

int GLT() {
   int l_hist_total_0 = 0;
   int l_ticket_4 = 0;
   int l_magic_8 = 0;
   int l_datetime_12 = 0;
   int l_datetime_16 = 0;
   string l_symbol_20 = "";
   int l_pos_28 = 0;
   l_hist_total_0 = OrdersHistoryTotal();
   if (l_hist_total_0 == 0) return (0);
   for (l_pos_28 = 0; l_pos_28 < l_hist_total_0; l_pos_28++) {
      if (OrderSelect(l_pos_28, SELECT_BY_POS, MODE_HISTORY) == TRUE) {
         l_symbol_20 = OrderSymbol();
         if (l_symbol_20 == Symbol()) {
            l_magic_8 = OrderMagicNumber();
            if (l_magic_8 == Magic_Number) {
               l_datetime_16 = OrderCloseTime();
               if (l_datetime_16 > l_datetime_12 && l_datetime_16 > 0) {
                  l_ticket_4 = OrderTicket();
                  l_datetime_12 = l_datetime_16;
               }
            }
         }
      }
   }
   return (l_ticket_4);
}

int _GTC() {
   int l_ord_total_0 = 0;
   int li_unused_4 = 0;
   int l_ticket_8 = 0;
   int l_magic_12 = 0;
   string l_symbol_16 = "";
   int li_24 = 0;
   int l_pos_28 = 0;
   li_24 = OT();
   if (li_24 == 0) return (0);
   if (li_24 > 1) return (0);
   l_ord_total_0 = OrdersTotal();
   for (l_pos_28 = 0; l_pos_28 < l_ord_total_0; l_pos_28++) {
      if (OrderSelect(l_pos_28, SELECT_BY_POS) == TRUE) {
         l_symbol_16 = OrderSymbol();
         if (l_symbol_16 == Symbol()) {
            l_magic_12 = OrderMagicNumber();
            if (l_magic_12 == Magic_Number) {
               l_ticket_8 = OrderTicket();
               return (l_ticket_8);
            }
         }
      }
   }
   return (l_ticket_8);
}

void C_ORD() {
   int li_unused_0 = 0;
   int li_4 = 0;
   int li_unused_8 = 0;
   int li_unused_12 = 0;
   int li_unused_16 = 0;
   li_4 = OT();
   if (li_4 == 0) {
      if (g_ticket_228 > 0) {
         g_ticket_236 = g_ticket_228;
         g_ticket_228 = 0;
      }
      if (gi_288 != FALSE) return;
      gi_288 = TRUE;
      return;
   }
   if (li_4 < gi_176) gi_288 = TRUE;
}

void G_LO() {
   int li_0 = 0;
   int l_hour_4 = 0;
   int li_8 = 0;
   int li_unused_12 = 0;
   int li_16 = 0;
   l_hour_4 = Hour();
   li_8 = l_hour_4 - London_Time_Shift;
   li_16 = li_8 - 8;
   if (li_16 < 0) {
      g_shift_284 = 0;
      return;
   }
   li_0 = TimeCurrent() - 3600 * li_16;
   g_shift_284 = iBarShift(NULL, 0, li_0);
}

bool iTT() {
   int l_datetime_0 = 0;
   int l_count_4 = -1;
   int l_hour_8 = 0;
   int li_12 = 0;
   int li_16 = 0;
   l_datetime_0 = TimeCurrent();
   l_hour_8 = Hour();
   l_count_4 = TimeDayOfWeek(l_datetime_0);
   if (London_Time_Shift > 0) {
      if (London_Time_Shift > l_hour_8) {
         l_count_4--;
         if (l_count_4 < 0) l_count_4 = 6;
      }
      li_12 = l_hour_8 - London_Time_Shift;
      if (li_12 < 0) li_12 = 24 - li_12;
   }
   if (London_Time_Shift < 0) {
      li_16 = MathAbs(London_Time_Shift);
      if (li_16 + l_hour_8 >= 24) {
         l_count_4++;
         if (l_count_4 > 6) l_count_4 = 0;
      }
      li_12 = l_hour_8 + li_16;
      if (li_12 > 24) li_12 -= 24;
   }
   if (London_Time_Shift == 0) li_12 = l_hour_8;
   if (l_count_4 == 0 || l_count_4 == 6) return (FALSE);
   if (li_12 >= 8 && li_12 <= 16) return (TRUE);
   return (FALSE);
}

bool GL_CLP(double ad_0, double ad_8, double ad_16, double ad_24, double ad_32, double ad_40) {
   int li_unused_48 = 0;
   double l_iopen_52 = 0;
   double l_ima_60 = 0;
   double l_ima_68 = 0;
   double l_imacd_76 = 0;
   double l_imacd_84 = 0;
   double l_imacd_92 = 0;
   double l_imacd_100 = 0;
   double ld_108 = 0;
   l_imacd_76 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   l_imacd_84 = iMACD(NULL, 0, 7, 20, 5, PRICE_CLOSE, MODE_MAIN, 10);
   l_imacd_92 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
   l_imacd_100 = iMACD(NULL, 0, 7, 20, 5, PRICE_CLOSE, MODE_SIGNAL, 10);
   l_ima_60 = iMA(NULL, 0, 50, gi_188, MODE_SMA, PRICE_CLOSE, 0);
   l_ima_68 = iMA(NULL, 0, 50, gi_188, MODE_SMA, PRICE_CLOSE, 10);
   ld_108 = LND_Stock(ad_16, l_imacd_76, l_imacd_92, l_imacd_84, l_imacd_100, "GLIVV", AccountNumber(), gi_260);
   if (ld_108 > 0.0) {
      if (TLV(ad_0, ad_8, l_ima_60, l_ima_68, gi_204, Point, "GLIVV", AccountNumber(), gi_260) == 1) {
         l_iopen_52 = iOpen(NULL, 0, 0);
         if (PLV(l_iopen_52, ad_0, ad_8, ad_16, ad_24, ad_32, ad_40, "GLIVV", AccountNumber(), gi_260) == 1) return (TRUE);
      }
   }
   return (FALSE);
}

bool GL_CSP(double ad_0, double ad_8, double ad_16, double ad_24, double ad_32, double ad_40) {
   int li_unused_48 = 0;
   double l_iopen_52 = 0;
   double l_ima_60 = 0;
   double l_ima_68 = 0;
   double l_imacd_76 = 0;
   double l_imacd_84 = 0;
   double l_imacd_92 = 0;
   double l_imacd_100 = 0;
   double ld_108 = 0;
   l_imacd_76 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
   l_imacd_84 = iMACD(NULL, 0, 5, 22, 11, PRICE_CLOSE, MODE_MAIN, 10);
   l_imacd_92 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
   l_imacd_100 = iMACD(NULL, 0, 5, 22, 11, PRICE_CLOSE, MODE_SIGNAL, 10);
   l_ima_60 = iMA(NULL, 0, 50, gi_188, MODE_SMA, PRICE_CLOSE, 0);
   l_ima_68 = iMA(NULL, 0, 50, gi_188, MODE_SMA, PRICE_CLOSE, 10);
   ld_108 = LND_Stock(ad_24, l_imacd_76, l_imacd_92, l_imacd_84, l_imacd_100, "GLIVV", AccountNumber(), gi_260);
   if (ld_108 > 0.0) {
      if (TSV(ad_0, ad_8, l_ima_60, l_ima_68, gi_204, Point, "GLIVV", AccountNumber(), gi_260) == 1) {
         l_iopen_52 = iOpen(NULL, 0, 0);
         if (PSV(l_iopen_52, ad_0, ad_8, ad_16, ad_24, ad_32, ad_40, "GLIVV", AccountNumber(), gi_260) == 1) return (TRUE);
      }
   }
   return (FALSE);
}

int init() {
   int li_16 = 1;
   int l_hour_40 = 0;
   int l_index_44 = 0;

   IPO();
   for (l_index_44 = 0; l_index_44 < 20; l_index_44++) gba_224[l_index_44] = 0;
   g_y_212 = 20;
   AddLabel("Desc", "EA Name: " + "PipsMiner SEv1.3 M5 EURUSD");
   g_ticket_236 = GLT();
   li_16 = MMX();
   Print("MX : " + li_16);
   gi_196 = 30 * li_16;
   gi_200 = 210 * li_16;
   gi_204 = 7 * li_16;
   gd_296 = 1 / Point;
   g_ticket_228 = _GTC();
   AddLabel("License", "License: UNKNOWN");
   AddLabel("Magic", "Magic Number: " + Magic_Number);
   AddLabel("Spread", "Spread: UNKNOWN");
   AddLabel("ConnStatus", "Connnection Status: UNKNOWN");
   AddLabel("TradeStatus", "Trade Status: UNKNOWN");
   SetLabelText("License", "License: ACTIVE");

   if (!IsConnected()) {
      SetLabelText("ConnStatus", "Connection Status: DISCONECTED");
      return (0);
   }
   SetLabelText("ConnStatus", "Connection Status: ACTIVE");
   gd_268 = MarketInfo(Symbol(), MODE_SPREAD);
   SetLabelText("Spread", "Spread: " + gd_268);
   return (0);
}

int deinit() {
   ObjectsDeleteAll(0, OBJ_LABEL);
   return (0);
}

int start() {
   double l_ima_0 = 0;
   double l_ima_8 = 0;
   double l_ima_16 = 0;
   double l_irsi_24 = 0;
   double l_irsi_32 = 0;
   double l_imomentum_40 = 0;
   double l_imomentum_48 = 0;
   int li_88 = 0;
   double ld_92 = 0;

   gi_260 = 0;
   if (gba_224[1] == 0) {
      Print("CHECK 1: DONE");
      gba_224[1] = 1;
   }

   if (gba_224[2] == 0) {
      Print("CHECK 2: DONE");
      gba_224[2] = 1;
   }
   if (!IsConnected()) {
      SetLabelText("ConnStatus", "Connection Status: DISCONECTED");
      return (0);
   }
   SetLabelText("ConnStatus", "Connection Status: ACTIVE");
   if (gba_224[3] == 0) {
      Print("CHECK 3: DONE");
      gba_224[3] = 1;
   }
   SetLabelText("License", "License: ACTIVE");
   li_88 = RmLabel("InvalidLicense");
   if (li_88 == 1) g_y_212 -= 14.0;
   if (gba_224[4] == 0) {
      Print("CHECK 4: DONE");
      gba_224[4] = 1;
   }
   gd_268 = MarketInfo(Symbol(), MODE_SPREAD);
   SetLabelText("Spread", "Spread: " + gd_268);
   CO_PL();
   if (IsTradeAllowed()) {
      if (gba_224[5] == 0) {
         Print("CHECK 5: DONE");
         gba_224[5] = 1;
      }
      if (iTT()) {
         if (gba_224[6] == 0) {
            Print("CHECK 6: DONE");
            gba_224[6] = 1;
         }
         SetLabelText("TradeStatus", "Trade Status: ALLOWED");
         l_ima_0 = iMA(NULL, 0, 10, gi_188, MODE_SMA, PRICE_CLOSE, 0);
         l_ima_8 = iMA(NULL, 0, 21, gi_188, MODE_SMA, PRICE_CLOSE, 0);
         l_ima_16 = iMA(NULL, 0, 50, gi_188, MODE_SMA, PRICE_CLOSE, 0);
         l_irsi_24 = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
         l_irsi_32 = iRSI(NULL, 0, 7, PRICE_CLOSE, 0);
         l_imomentum_40 = iMomentum(NULL, 0, 10, PRICE_CLOSE, 0);
         l_imomentum_48 = iMomentum(NULL, 0, 21, PRICE_CLOSE, 0);
         G_LO();
         if (gba_224[7] == 0) {
            Print("CHECK 7: DONE");
            gba_224[7] = 1;
         }
         gi_260 = OT();
         if (gba_224[8] == 0) {
            Print("CHECK 8: DONE");
            Print("ALL CHECKS DONE.");
            gba_224[8] = 1;
         }
         if (gi_260 >= gi_176) {
            g_ticket_236 = g_ticket_228;
            gi_288 = FALSE;
         }
         switch (gi_288) {
         case 1:
            if (GL_CLP(l_ima_0, l_ima_8, l_irsi_32, l_irsi_24, l_imomentum_40, l_imomentum_48)) {
               if (Bars > g_bars_232) {
                  if (OpenOrder(1, gi_196, gi_200, Lots) == 0) {
                     if (g_ticket_228 > 0) {
                        if (ld_92 > Lots) UPO(g_ticket_228);
                        else SORD(g_ticket_228);
                     }
                     g_ticket_236 = g_ticket_228;
                     g_bars_232 = Bars;
                     break;
                  }
               }
            }
            if (GL_CSP(l_ima_0, l_ima_8, l_irsi_32, l_irsi_24, l_imomentum_40, l_imomentum_48)) {
               if (Bars > g_bars_232) {
                  if (OpenOrder(2, gi_196, gi_200, Lots) == 0) {
                     if (g_ticket_228 > 0) {
                        if (ld_92 > Lots) UPO(g_ticket_228);
                        else SORD(g_ticket_228);
                     }
                     g_bars_232 = Bars;
                     g_ticket_236 = g_ticket_228;
                  }
               }
            }
            break;
         case 0:
            C_ORD();
         }
      } else SetLabelText("TradeStatus", "Trade Status: WAITING FOR LONDON OPEN");
   } else {
      if (gba_224[5] == 0) {
         Print("CHECK INTERRUPTED!!! TRADE NOT ALLOWED OR INVALID LICENSE");
         gba_224[5] = 1;
      }
      SetLabelText("TradeStatus", "Trade Status: NOT ALLOWED!!!");
   }
   return (0);
}
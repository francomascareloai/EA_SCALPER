
#property copyright "Copyright © 2012, Rita Lasker"
#property link      "http://www.ritalasker.com"

#include <WinUser32.mqh>

extern bool _Alert = TRUE;
extern bool _SendMail = TRUE;
extern bool _Sound = TRUE;
extern int Arrow = 4;
extern int indent = 15;
int g_period_96;
int gi_100;
int g_period_104;
int g_ma_method_112;
string g_var_name_116;
string g_var_name_124;
bool gi_132 = TRUE;
int gi_148;
int gi_152;
double g_digits_156;
int g_datetime_164 = 0;

int init() {
   int li_0;
   int file_4;
   int li_8;
   g_var_name_116 = "bo_s";
   g_var_name_124 = "bo_b";
   g_var_name_116 = g_var_name_116 + Symbol() + Period();
   g_var_name_124 = g_var_name_124 + Symbol() + Period();
   g_period_96 = 20;
   gi_100 = 2;
   g_period_104 = 9;
   g_ma_method_112 = 1;

   return (0);
}

int deinit() {
   string name_8;
   int li_0 = ObjectsTotal();
   for (int objs_total_4 = li_0; objs_total_4 >= 0; objs_total_4--) {
      name_8 = ObjectName(objs_total_4);
      if (StringSubstr(name_8, 0, 4) == "sell") ObjectDelete(name_8);
   }
   li_0 = ObjectsTotal();
   for (objs_total_4 = li_0; objs_total_4 >= 0; objs_total_4--) {
      name_8 = ObjectName(objs_total_4);
      if (StringSubstr(name_8, 0, 5) == "close") ObjectDelete(name_8);
   }
   li_0 = ObjectsTotal();
   for (objs_total_4 = li_0; objs_total_4 >= 0; objs_total_4--) {
      name_8 = ObjectName(objs_total_4);
      if (StringSubstr(name_8, 0, 3) == "buy") ObjectDelete(name_8);
   }
   return (0);
}

int start() {
   if (gi_132) {
      if (gi_148 == 0) {
         g_digits_156 = MarketInfo(Symbol(), MODE_DIGITS);
         if (g_digits_156 == 5.0 || g_digits_156 == 3.0) gi_152 = 10;
         if (g_digits_156 == 4.0 || g_digits_156 == 2.0) gi_152 = 1;
         gi_148++;
         f0_0();
         f0_2();
      }
      f0_1();
      f0_3();
      if (f0_6()) {
         f0_4();
         f0_5();
      }
   }
   return (0);
}

void f0_1() {
   string ls_0;
   string ls_8;
   string ls_16;
   int li_24;
   if (GlobalVariableGet(g_var_name_124) == 1.0 && iMA(Symbol(), 0, g_period_104, 0, g_ma_method_112, PRICE_CLOSE, 0) <= High[0]) {
      GlobalVariableSet(g_var_name_124, 0);
      li_24 = Period();
      if (li_24 >= 60) {
         li_24 /= 60;
         ls_16 = " H" + li_24;
      } else ls_16 = " M" + li_24;
      ls_8 = "F50P" + " " + Symbol() + " " + ls_16 + " Close BUY";
      ls_0 = "F50P" + " " + Symbol() + " " + ls_16 + " Close BUY";
      if (_Alert) Alert(ls_0);
      if (_SendMail) SendMail("Forex50pips Indicator Alert", ls_8);
      if (_Sound) PlaySound("expert.wav");
      ObjectCreate("close" + Time[0], OBJ_ARROW, 0, Time[0], High[0] + gi_152 * indent * Point);
      ObjectSet("close" + Time[0], OBJPROP_COLOR, Green);
      ObjectSet("close" + Time[0], OBJPROP_WIDTH, Arrow);
      ObjectSet("close" + Time[0], OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
   }
}

void f0_3() {
   string ls_0;
   string ls_8;
   string ls_16;
   int li_24;
   if (GlobalVariableGet(g_var_name_116) == 1.0 && iMA(Symbol(), 0, g_period_104, 0, g_ma_method_112, PRICE_CLOSE, 0) >= Low[0]) {
      GlobalVariableSet(g_var_name_116, 0);
      li_24 = Period();
      if (li_24 >= 60) {
         li_24 /= 60;
         ls_16 = " H" + li_24;
      } else ls_16 = " M" + li_24;
      ls_8 = "F50P" + " " + Symbol() + " " + ls_16 + " Close SELL";
      ls_0 = "F50P" + " " + Symbol() + " " + ls_16 + " Close SELL";
      if (_Alert) Alert(ls_0);
      if (_SendMail) SendMail("Forex50pips Indicator Alert", ls_8);
      if (_Sound) PlaySound("expert.wav");
      ObjectCreate("close" + Time[0], OBJ_ARROW, 0, Time[0], Low[0] - gi_152 * indent * Point);
      ObjectSet("close" + Time[0], OBJPROP_COLOR, Green);
      ObjectSet("close" + Time[0], OBJPROP_WIDTH, Arrow);
      ObjectSet("close" + Time[0], OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
   }
}

void f0_4() {
   string ls_0;
   string ls_8;
   string ls_16;
   int li_24;
   if (GlobalVariableGet(g_var_name_116) != 1.0) {
      if (Low[1] > iMA(Symbol(), 0, g_period_104, 0, g_ma_method_112, PRICE_CLOSE, 1)) {
         if (High[1] >= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_UPPER, 1)) {
            if (High[2] >= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_UPPER, 2)) {
               if (High[3] >= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_UPPER, 3)) {
                  GlobalVariableSet(g_var_name_116, 1);
                  li_24 = Period();
                  if (li_24 >= 60) {
                     li_24 /= 60;
                     ls_16 = " H" + li_24;
                  } else ls_16 = " M" + li_24;
                  ls_8 = "F50P" + " " + Symbol() + " " + ls_16 + " SELL";
                  ls_0 = "F50P" + " " + Symbol() + " " + ls_16 + " SELL";
                  if (_Alert) Alert(ls_0);
                  if (_SendMail) SendMail("Forex50pips Indicator Alert", ls_8);
                  if (_Sound) PlaySound("expert.wav");
                  ObjectCreate("sell" + Time[0], OBJ_ARROW, 0, Time[0], Open[0] + gi_152 * indent * Point);
                  ObjectSet("sell" + Time[0], OBJPROP_COLOR, Red);
                  ObjectSet("sell" + Time[0], OBJPROP_WIDTH, Arrow);
                  ObjectSet("sell" + Time[0], OBJPROP_ARROWCODE, 234);
               }
            }
         }
      }
   }
}

void f0_5() {
   string ls_0;
   string ls_8;
   string ls_16;
   int li_24;
   if (GlobalVariableGet(g_var_name_124) != 1.0) {
      if (High[1] < iMA(Symbol(), 0, g_period_104, 0, g_ma_method_112, PRICE_CLOSE, 1)) {
         if (Low[1] <= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_LOWER, 1)) {
            if (Low[2] <= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_LOWER, 2)) {
               if (Low[3] <= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_LOWER, 3)) {
                  GlobalVariableSet(g_var_name_124, 1);
                  li_24 = Period();
                  if (li_24 >= 60) {
                     li_24 /= 60;
                     ls_16 = " H" + li_24;
                  } else ls_16 = " M" + li_24;
                  ls_8 = "F50P" + " " + Symbol() + " " + ls_16 + " BUY";
                  ls_0 = "F50P" + " " + Symbol() + " " + ls_16 + " BUY";
                  if (_Alert) Alert(ls_0);
                  if (_SendMail) SendMail("Forex50pips Indicator Alert", ls_8);
                  if (_Sound) PlaySound("expert.wav");
                  ObjectCreate("buy" + Time[0], OBJ_ARROW, 0, Time[0], Open[0] - gi_152 * indent * Point);
                  ObjectSet("buy" + Time[0], OBJPROP_COLOR, Blue);
                  ObjectSet("buy" + Time[0], OBJPROP_WIDTH, Arrow);
                  ObjectSet("buy" + Time[0], OBJPROP_ARROWCODE, 233);
               }
            }
         }
      }
   }
}

bool f0_6() {
   bool li_ret_0 = FALSE;
   if (g_datetime_164 != iTime(Symbol(), 0, 0)) {
      g_datetime_164 = iTime(Symbol(), 0, 0);
      li_ret_0 = TRUE;
   }
   return (li_ret_0);
}

void f0_2() {
   for (int li_0 = Bars - 4; li_0 > 0; li_0--) {
      if (Low[li_0] > iMA(Symbol(), 0, g_period_104, 0, g_ma_method_112, PRICE_CLOSE, li_0) && High[li_0] >= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_UPPER,
         li_0) && High[li_0 + 1] >= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_UPPER, li_0 + 1) && High[li_0 + 2] >= iBands(NULL, 0, g_period_96, gi_100, 0,
         PRICE_CLOSE, MODE_UPPER, li_0 + 2)) {
         ObjectCreate("sell" + ((Time[li_0 - 1])), OBJ_ARROW, 0, Time[li_0 - 1], High[li_0 - 1] + gi_152 * indent * Point);
         ObjectSet("sell" + ((Time[li_0 - 1])), OBJPROP_COLOR, Red);
         ObjectSet("sell" + ((Time[li_0 - 1])), OBJPROP_WIDTH, 5);
         ObjectSet("sell" + ((Time[li_0 - 1])), OBJPROP_ARROWCODE, 234);
         for (li_0--; li_0 >= 0; li_0--) {
            if (Low[li_0] <= iMA(Symbol(), 0, g_period_104, 0, g_ma_method_112, PRICE_CLOSE, li_0)) {
               ObjectCreate("close" + Time[li_0], OBJ_ARROW, 0, Time[li_0], Low[li_0] - gi_152 * indent * Point);
               ObjectSet("close" + Time[li_0], OBJPROP_COLOR, Red);
               ObjectSet("close" + Time[li_0], OBJPROP_WIDTH, 5);
               ObjectSet("close" + Time[li_0], OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
               break;
            }
         }
      }
   }
}

void f0_0() {
   for (int li_0 = Bars - 4; li_0 > 0; li_0--) {
      if (High[li_0] < iMA(Symbol(), 0, g_period_104, 0, g_ma_method_112, PRICE_CLOSE, li_0) && Low[li_0] <= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_LOWER,
         li_0) && Low[li_0 + 1] <= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE, MODE_LOWER, li_0 + 1) && Low[li_0 + 2] <= iBands(NULL, 0, g_period_96, gi_100, 0, PRICE_CLOSE,
         MODE_LOWER, li_0 + 2)) {
         ObjectCreate("buy" + ((Time[li_0 - 1])), OBJ_ARROW, 0, Time[li_0 - 1], Low[li_0 - 1] - gi_152 * indent * Point);
         ObjectSet("buy" + ((Time[li_0 - 1])), OBJPROP_COLOR, Blue);
         ObjectSet("buy" + ((Time[li_0 - 1])), OBJPROP_WIDTH, 5);
         ObjectSet("buy" + ((Time[li_0 - 1])), OBJPROP_ARROWCODE, 233);
         for (li_0--; li_0 >= 0; li_0--) {
            if (High[li_0] >= iMA(Symbol(), 0, g_period_104, 0, g_ma_method_112, PRICE_CLOSE, li_0)) {
               ObjectCreate("close" + Time[li_0], OBJ_ARROW, 0, Time[li_0], High[li_0] + gi_152 * indent * Point);
               ObjectSet("close" + Time[li_0], OBJPROP_COLOR, Red);
               ObjectSet("close" + Time[li_0], OBJPROP_WIDTH, 5);
               ObjectSet("close" + Time[li_0], OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
               break;
            }
         }
      }
   }
}
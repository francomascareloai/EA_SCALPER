/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: ht Tp://W w W. m Et A q Uo tes. Net
   E-mail : Sup P oRT @ me t A Q U o t ES . ne T
*/
#property copyright "pengenprofit888@gmail.com"
#property link      "pengenprofit888@gmail.com"

#property indicator_chart_window

extern int grid1 = 125;
extern int grid2 = 250;
extern int grid3 = 75;
extern color colour1 = Blue;
extern color colour2 = Red;
extern color colour3 = DarkOrange;
double Gd_100;
double Gd_108;
double Gd_116;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   start();
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   f0_0();
   ObjectDelete("hhz");
   ObjectDelete("lhz");
   ObjectDelete("txthz");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double Ld_32;
   string str_concat_40;
   double price_52;
   string name_60;
   double price_68;
   double price_76;
   f0_0();
   Gd_100 = Point;
   if (Digits == 3 || Digits == 5) Gd_100 = 10.0 * Point;
   double Ld_0 = 1000.0 * Gd_100;
   Gd_108 = MathCeil((Bid + Ld_0) / Ld_0) * Ld_0;
   Gd_116 = MathFloor((Bid - Ld_0) / Ld_0) * Ld_0;
   Ld_0 = grid2 * Gd_100;
   double Ld_8 = NormalizeDouble(Bid / Ld_0, 0) * Ld_0;
   double price_16 = Ld_8 + grid3 * Gd_100;
   double price_24 = Ld_8 - grid3 * Gd_100;
   ObjectDelete("hhz");
   ObjectDelete("lhz");
   ObjectDelete("txthz");
   if (Bid <= price_16 && Bid >= price_24) {
      ObjectCreate("hhz", OBJ_TEXT, 0, Time[20], price_16);
      ObjectSetText("hhz", "HHZ", 10, "Arial Bold", Green);
      ObjectCreate("lhz", OBJ_TEXT, 0, Time[20], price_24);
      ObjectSetText("lhz", "LHZ", 10, "Arial Bold", Red);
   }
   if (Bid <= price_16 && Bid > Ld_8) {
      Ld_32 = (price_16 - Bid) / Gd_100;
      str_concat_40 = StringConcatenate(Ld_32, " pip to hi HZ");
      f0_1(str_concat_40, Green);
   }
   if (Bid < Ld_8 && Bid >= price_24) {
      Ld_32 = (Bid - price_24) / Gd_100;
      str_concat_40 = StringConcatenate(Ld_32, " pip to low HZ");
      f0_1(str_concat_40, Red);
   }
   for (int count_48 = 0; count_48 <= 500; count_48++) {
      price_52 = Gd_116 + count_48 * grid1 * Gd_100;
      name_60 = "JHGrid" + DoubleToStr(price_52, Digits);
      ObjectCreate(name_60, OBJ_HLINE, 0, 0, price_52);
      ObjectSet(name_60, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(name_60, OBJPROP_COLOR, colour1);
      if (price_52 >= Gd_108) break;
   }
   for (count_48 = 0; count_48 <= 500; count_48++) {
      price_52 = Gd_116 + count_48 * grid2 * Gd_100;
      name_60 = "JHGrid" + DoubleToStr(price_52, Digits);
      ObjectCreate(name_60, OBJ_HLINE, 0, 0, price_52);
      ObjectSet(name_60, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(name_60, OBJPROP_COLOR, colour2);
      ObjectSet(name_60, OBJPROP_WIDTH, 2);
      price_68 = price_52 - grid3 * Gd_100;
      name_60 = "JHGrid" + DoubleToStr(price_68, Digits);
      ObjectCreate(name_60, OBJ_HLINE, 0, 0, price_68);
      ObjectSet(name_60, OBJPROP_STYLE, STYLE_DASH);
      ObjectSet(name_60, OBJPROP_COLOR, colour3);
      if (price_68 == price_24) ObjectSet(name_60, OBJPROP_COLOR, Fuchsia);
      price_76 = price_52 + grid3 * Gd_100;
      name_60 = "JHGrid" + DoubleToStr(price_76, Digits);
      ObjectCreate(name_60, OBJ_HLINE, 0, 0, price_76);
      ObjectSet(name_60, OBJPROP_STYLE, STYLE_DASH);
      ObjectSet(name_60, OBJPROP_COLOR, colour3);
      if (price_76 == price_16) ObjectSet(name_60, OBJPROP_COLOR, Green);
      if (price_52 >= Gd_108) break;
   }
   return (0);
}

// 01BC6F8EFA4202821E95F4FDF6298B30
void f0_0() {
   string name_4;
   for (int Li_0 = ObjectsTotal() - 1; Li_0 >= 0; Li_0--) {
      name_4 = ObjectName(Li_0);
      if (StringFind(name_4, "JHGrid", 0) > -1) ObjectDelete(name_4);
   }
}

// D304BA20E96D87411588EEABAC850E34
void f0_1(string A_text_0, color A_color_8) {
   string name_12 = "txthz";
   ObjectCreate(name_12, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name_12, OBJPROP_CORNER, 4);
   ObjectSet(name_12, OBJPROP_BACK, FALSE);
   ObjectSet(name_12, OBJPROP_XDISTANCE, 10);
   ObjectSet(name_12, OBJPROP_YDISTANCE, 10);
   ObjectSetText(name_12, A_text_0, 18, "Arial Bold", A_color_8);
}

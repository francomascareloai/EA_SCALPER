/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h ttp : // wwW. ME T aQUote S .nE t
   E-mail : S U P PoR T @me TAQU o TES. n eT
*/
#property copyright "x Meter System™ ©GPL"
#property link      "forex-tsd dot com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Black

//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A
#import

string Gs_xmeter3_76 = "xmeter3";
extern string C = "---Corner Position---";
extern string c0 = " 0 = Upper left";
extern string c1 = " 1 = Upper right";
extern string c2 = " 2 = Lower left";
extern string c3 = " 3 = Lower right";
extern int myCorner = 3;
extern string T = "---Text Colors---";
extern color StrengthColor = Sienna;
extern color CurrencyColor = DarkSlateBlue;
extern color LogoColor = DimGray;
extern bool AccountIsIBFXmini = FALSE;
bool Gi_152 = FALSE;
string Gsa_156[] = {"GBPJPY"};
string Gsa_160[] = {"EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDJPY", "USDCHF", "USDCAD", "EURCAD", "GBPCAD", "EURJPY", "EURGBP", "EURCHF", "EURAUD", "EURNZD", "GBPJPY", "GBPCHF", "EURJPY"};
string Gsa_164[] = {"USD", "EUR", "GBP", "CHF", "CAD", "AUD", "NZD", "JPY"};
int Gia_168[] = {150, 130, 110, 90, 70, 50, 30, 10};
string Gsa_172[2] = {"BUY ", "SELL "};
int Gia_176[19] = {0, 3, 10, 25, 40, 50, 60, 75, 90, 97, 100};
int Gi_180;
int Gi_184;
double Gda_188[];
double Gda_192[];
double Gda_196[];
double Gda_200[];
double Gda_204[];
double Gda_208[];
double Gda_212[];
double Gda_216[];
double Gda_220[];
int Gia_224[2][];

int init() {
   Gi_180 = ArrayRange(Gsa_160, 0);
   Gi_184 = ArrayRange(Gsa_164, 0);
   int Li_8 = ArrayRange(Gia_168, 0);
   if (Gi_184 != Li_8) Print("The size of array aMajor is not equals to aMajorPos");
   ArrayResize(Gda_188, Gi_184);
   ArrayResize(Gda_192, Gi_180);
   ArrayResize(Gda_196, Gi_180);
   ArrayResize(Gda_200, Gi_180);
   ArrayResize(Gda_204, Gi_180);
   ArrayResize(Gda_208, Gi_180);
   ArrayResize(Gda_212, Gi_180);
   ArrayResize(Gda_216, Gi_180);
   ArrayResize(Gda_220, Gi_180);
   init_tradepair_index();
   initGraph();
   if (Gi_152) {
      while (true) {
         if (IsConnected()) main();
         if (!IsConnected()) objectBlank();
         WindowRedraw();
         Sleep(1000);
      }
   }
   return (0);
}

int deinit() {
   DeleteExistingLabels();
   Print("shutdown error - ", ErrorDescription(GetLastError()));
   return (0);
}

int start() {
   if (!Gi_152) main();
   return (0);
}

void main() {
   double Ld_0;
   int count_16;
   string symbol_20;
   double Ld_28;
   for (int index_8 = 0; index_8 < Gi_180; index_8++) {
      RefreshRates();
      if (AccountIsIBFXmini) symbol_20 = Gsa_160[index_8] + 109;
      else symbol_20 = Gsa_160[index_8];
      Ld_0 = GetPoint(symbol_20);
      Gda_192[index_8] = MarketInfo(symbol_20, MODE_HIGH);
      Gda_196[index_8] = MarketInfo(symbol_20, MODE_LOW);
      Gda_200[index_8] = MarketInfo(symbol_20, MODE_BID);
      Gda_204[index_8] = MarketInfo(symbol_20, MODE_ASK);
      Gda_212[index_8] = MathMax((Gda_192[index_8] - Gda_196[index_8]) / Ld_0, 1);
      Gda_208[index_8] = (Gda_200[index_8] - Gda_196[index_8]) / Gda_212[index_8] / Ld_0;
      Gda_216[index_8] = iLookup(100.0 * Gda_208[index_8]);
      Gda_220[index_8] = 9.9 - Gda_216[index_8];
   }
   for (int index_12 = 0; index_12 < Gi_184; index_12++) {
      count_16 = 0;
      Ld_28 = 0;
      for (index_8 = 0; index_8 < Gi_180; index_8++) {
         if (StringSubstr(Gsa_160[index_8], 0, 3) == Gsa_164[index_12]) {
            count_16++;
            Ld_28 += Gda_216[index_8];
         }
         if (StringSubstr(Gsa_160[index_8], 3, 3) == Gsa_164[index_12]) {
            count_16++;
            Ld_28 += Gda_220[index_8];
         }
         if (count_16 > 0) Gda_188[index_12] = NormalizeDouble(Ld_28 / count_16, 1);
         else Gda_188[index_12] = -1;
      }
   }
   objectBlank();
   for (index_12 = 0; index_12 < Gi_184; index_12++) paintCurr(index_12, Gda_188[index_12]);
   paintLine();
}

void init_tradepair_index() {
   string Ls_20;
   string Ls_28;
   string Ls_36;
   int arr_size_8 = ArraySize(Gsa_156);
   for (int count_4 = 0; count_4 < arr_size_8; count_4++) {
      Ls_20 = Gsa_156[0];
      Ls_28 = StringSubstr(Ls_20, 0, 3);
      Ls_36 = StringSubstr(Ls_20, 3, 3);
      Gia_224[0][count_4] = -1;
      Gia_224[1][count_4] = -1;
      for (int index_0 = 0; index_0 < Gi_184; index_0++) {
         if (Ls_28 == Gsa_164[index_0]) Gia_224[0][count_4] = index_0;
         if (Ls_36 == Gsa_164[index_0]) Gia_224[1][count_4] = index_0;
      }
      if (Gia_224[0][count_4] == -1 || Gia_224[1][count_4] == -1) Print("Currency Pair : ", Ls_20, " is not tradeable, check array definition!");
   }
}

double GetPoint(string As_unused_0) {
   string Ls_24;
   double Ld_ret_8 = 0.0001;
   double Ld_ret_16 = 0.01;
   if (StringSubstr(Ls_24, 3, 3) == "JPY") return (Ld_ret_16);
   return (Ld_ret_8);
}

int iLookup(double Ad_0) {
   int Li_ret_8 = -1;
   if (Ad_0 <= Gia_176[0]) Li_ret_8 = 0;
   else {
      for (int Li_12 = 1; Li_12 < 19; Li_12++) {
         if (Ad_0 < Gia_176[Li_12]) {
            Li_ret_8 = Li_12 - 1;
            break;
         }
      }
      if (Li_ret_8 == -1) Li_ret_8 = 9.9;
   }
   return (Li_ret_8);
}

void initGraph() {
   DeleteExistingLabels();
   for (int index_0 = 0; index_0 < Gi_184; index_0++) {
      objectCreate(Gs_xmeter3_76 + Gsa_164[index_0] + "_1", Gia_168[index_0], 47);
      objectCreate(Gs_xmeter3_76 + Gsa_164[index_0] + "_2", Gia_168[index_0], 39);
      objectCreate(Gs_xmeter3_76 + Gsa_164[index_0] + "_3", Gia_168[index_0], 31);
      objectCreate(Gs_xmeter3_76 + Gsa_164[index_0] + "_4", Gia_168[index_0], 23);
      objectCreate(Gs_xmeter3_76 + Gsa_164[index_0] + "_5", Gia_168[index_0], 15);
      objectCreate(Gs_xmeter3_76 + Gsa_164[index_0], Gia_168[index_0] + 2, 16, Gsa_164[index_0], 7, "Arial Narrow", CurrencyColor);
      objectCreate(Gs_xmeter3_76 + Gsa_164[index_0] + "p", Gia_168[index_0] + 4, 25, DoubleToStr(9, 1), 8, "Arial Narrow", StrengthColor);
   }
   objectCreate(Gs_xmeter3_76 + "line", 15, 10, "-------------------------------------", 10, "Arial", DimGray);
   objectCreate(Gs_xmeter3_76 + "line1", 15, 31, "-------------------------------------", 10, "Arial", DimGray);
   objectCreate(Gs_xmeter3_76 + "line2", 15, 73, "-------------------------------------", 10, "Arial", DimGray);
   objectCreate(Gs_xmeter3_76 + "sign", 15, 5, "» Price Powered Meter System™ ©GPL «", 8, "Arial Narrow", LogoColor);
   WindowRedraw();
}

void objectCreate(string A_name_0, int A_x_8, int A_y_12, string A_text_16 = "-", int A_fontsize_24 = 42, string A_fontname_28 = "Arial", color A_color_36 = -1) {
   ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSet(A_name_0, OBJPROP_CORNER, myCorner);
   ObjectSet(A_name_0, OBJPROP_COLOR, A_color_36);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_8);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_12);
   ObjectSetText(A_name_0, A_text_16, A_fontsize_24, A_fontname_28, A_color_36);
}

void objectBlank() {
   for (int index_0 = 0; index_0 < Gi_184; index_0++) {
      ObjectSet(Gs_xmeter3_76 + Gsa_164[index_0] + "_1", OBJPROP_COLOR, CLR_NONE);
      ObjectSet(Gs_xmeter3_76 + Gsa_164[index_0] + "_2", OBJPROP_COLOR, CLR_NONE);
      ObjectSet(Gs_xmeter3_76 + Gsa_164[index_0] + "_3", OBJPROP_COLOR, CLR_NONE);
      ObjectSet(Gs_xmeter3_76 + Gsa_164[index_0] + "_4", OBJPROP_COLOR, CLR_NONE);
      ObjectSet(Gs_xmeter3_76 + Gsa_164[index_0] + "_5", OBJPROP_COLOR, CLR_NONE);
      ObjectSet(Gs_xmeter3_76 + Gsa_164[index_0], OBJPROP_COLOR, CLR_NONE);
      ObjectSet(Gs_xmeter3_76 + Gsa_164[index_0] + "p", OBJPROP_COLOR, CLR_NONE);
   }
   ObjectSet(Gs_xmeter3_76 + "line1", OBJPROP_COLOR, CLR_NONE);
   ObjectSet(Gs_xmeter3_76 + "line2", OBJPROP_COLOR, CLR_NONE);
}

void paintCurr(int Ai_0, double Ad_4) {
   if (Ad_4 > 0.0) ObjectSet(Gs_xmeter3_76 + Gsa_164[Ai_0] + "_5", OBJPROP_COLOR, Red);
   if (Ad_4 > 2.0) ObjectSet(Gs_xmeter3_76 + Gsa_164[Ai_0] + "_4", OBJPROP_COLOR, Orange);
   if (Ad_4 > 4.0) ObjectSet(Gs_xmeter3_76 + Gsa_164[Ai_0] + "_3", OBJPROP_COLOR, Gold);
   if (Ad_4 > 6.0) ObjectSet(Gs_xmeter3_76 + Gsa_164[Ai_0] + "_2", OBJPROP_COLOR, YellowGreen);
   if (Ad_4 > 7.0) ObjectSet(Gs_xmeter3_76 + Gsa_164[Ai_0] + "_1", OBJPROP_COLOR, Lime);
   ObjectSet(Gs_xmeter3_76 + Gsa_164[Ai_0], OBJPROP_COLOR, CurrencyColor);
   ObjectSetText(Gs_xmeter3_76 + Gsa_164[Ai_0] + "p", DoubleToStr(Ad_4, 1), 8, "Arial Narrow", StrengthColor);
}

void paintLine() {
   ObjectSet(Gs_xmeter3_76 + "line1", OBJPROP_COLOR, DimGray);
   ObjectSet(Gs_xmeter3_76 + "line2", OBJPROP_COLOR, DimGray);
}

void DeleteExistingLabels() {
   string name_4;
   int Li_0 = ObjectsTotal(OBJ_LABEL);
   if (Li_0 > 0) {
      for (int objs_total_12 = Li_0; objs_total_12 >= 0; objs_total_12--) {
         name_4 = ObjectName(objs_total_12);
         if (StringFind(name_4, Gs_xmeter3_76, 0) >= 0) ObjectDelete(name_4);
      }
   }
}

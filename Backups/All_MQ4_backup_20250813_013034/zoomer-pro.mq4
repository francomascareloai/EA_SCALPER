
#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 1.0

string gs_76 = "Zoomer Pro Љ";
int gcolor_84 = Orange;
string gfontname_88 = "Arial Bold";
int gfontsize_96 = 15;
bool gi_100 = FALSE;
string gs_104 = "M1;M5;M15;M30;H1;H4;D1;W1;MN";
string gs_112 = "1Min;5Min;15Min;30Min;1Hour;4Hour;Day;Week;Month";
int giunused_120 = 16777215;
string gs_124 = "5;8;13;21;34;55;89;144";
string gs_132 = "...1...;...2...;...3...;...4...;...5...;...6...;...7...;...8...";
int gcolor_140 = Gold;
string gstrend_144 = "Trend";
extern bool AlternateFont = FALSE;
int gi_156 = 65280;
int gi_160 = 65535;
int giunused_164 = 65535;
int gi_168 = 65535;
int gi_172 = 255;
string gs_176 = "с";
string gs_184 = "ф";
string gsunused_192 = "р";
string gs_200 = "ц";
string gs_208 = "т";
string gs_216;
int gstrlen_224;
int gi_228;
bool gi_232 = FALSE;
string gsunused_236;
string gs_244;
int garrsize_252;
int garrsize_256;
int garrsize_260;
int garrsize_264;
int garrsize_268;
string gsa_272[];
string gsa_276[];
string gsa_280[];
string gsa_284[];
string gsa_288[];
string gsaunused_292[];
string gsunused_296 = "";
string gsterminal_304 = "Terminal";
color gcolor_312;
int gi_316 = 3;
int gmamethod_320;
string gtext_324;
string gsunused_332;
string gtext_340;
color gcolor_348;
int giunused_356 = 255;
string gsunused_360 = "Font Size";
int giunused_368 = 40;
string gsunused_372 = "Font Type";
string gsunused_380 = "Verdana";
string gszoom01_388 = "ZOOM01";
string gszoom02_396 = "ZOOM02";

int init() {
   string ls_0;
   gs_244 = Symbol();
   if (AlternateFont) gsterminal_304 = "MS LineDraw";
   gs_104 = StringUpperCase(StringTrimLeft(StringTrimRight(gs_104)));
   if (StringSubstr(gs_104, StringLen(gs_104), 1) != ";") gs_104 = StringConcatenate(gs_104, ";");
   int li_8 = 0;
   for (int li_12 = StringFind(gs_104, ";", li_8); li_12 > 0; li_12 = StringFind(gs_104, ";", li_8)) {
      ls_0 = StringSubstr(gs_104, li_8, li_12 - li_8);
      ArrayResize(gsa_276, ArraySize(gsa_276) + 1);
      gsa_276[ArraySize(gsa_276) - 1] = ls_0;
      li_8 = li_12 + 1;
   }
   garrsize_256 = ArraySize(gsa_276);
   gs_112 = StringUpperCase(StringTrimLeft(StringTrimRight(gs_112)));
   if (StringSubstr(gs_112, StringLen(gs_112), 1) != ";") gs_112 = StringConcatenate(gs_112, ";");
   li_8 = 0;
   for (li_12 = StringFind(gs_112, ";", li_8); li_12 > 0; li_12 = StringFind(gs_112, ";", li_8)) {
      ls_0 = StringSubstr(gs_112, li_8, li_12 - li_8);
      ArrayResize(gsa_288, ArraySize(gsa_288) + 1);
      gsa_288[ArraySize(gsa_288) - 1] = ls_0;
      li_8 = li_12 + 1;
   }
   garrsize_268 = ArraySize(gsa_288);
   gs_124 = StringUpperCase(StringTrimLeft(StringTrimRight(gs_124)));
   if (StringSubstr(gs_124, StringLen(gs_124), 1) != ";") gs_124 = StringConcatenate(gs_124, ";");
   li_8 = 0;
   for (li_12 = StringFind(gs_124, ";", li_8); li_12 > 0; li_12 = StringFind(gs_124, ";", li_8)) {
      ls_0 = StringSubstr(gs_124, li_8, li_12 - li_8);
      ArrayResize(gsa_272, ArraySize(gsa_272) + 1);
      gsa_272[ArraySize(gsa_272) - 1] = ls_0;
      li_8 = li_12 + 1;
   }
   garrsize_252 = ArraySize(gsa_272);
   gs_132 = StringUpperCase(StringTrimLeft(StringTrimRight(gs_132)));
   if (StringSubstr(gs_132, StringLen(gs_132), 1) != ";") gs_132 = StringConcatenate(gs_132, ";");
   li_8 = 0;
   for (li_12 = StringFind(gs_132, ";", li_8); li_12 > 0; li_12 = StringFind(gs_132, ";", li_8)) {
      ls_0 = StringSubstr(gs_132, li_8, li_12 - li_8);
      ArrayResize(gsa_284, ArraySize(gsa_284) + 1);
      gsa_284[ArraySize(gsa_284) - 1] = ls_0;
      li_8 = li_12 + 1;
   }
   garrsize_264 = ArraySize(gsa_284);
   gstrend_144 = StringUpperCase(StringTrimLeft(StringTrimRight(gstrend_144)));
   if (StringSubstr(gstrend_144, StringLen(gstrend_144), 1) != ";") gstrend_144 = StringConcatenate(gstrend_144, ";");
   li_8 = 0;
   for (li_12 = StringFind(gstrend_144, ";", li_8); li_12 > 0; li_12 = StringFind(gstrend_144, ";", li_8)) {
      ls_0 = StringSubstr(gstrend_144, li_8, li_12 - li_8);
      ArrayResize(gsa_280, ArraySize(gsa_280) + 1);
      gsa_280[ArraySize(gsa_280) - 1] = ls_0;
      li_8 = li_12 + 1;
   }
   garrsize_260 = ArraySize(gsa_280);
   if (IsMini()) gsunused_296 = "m";
   gs_216 = MakeUniqueName("ZOO ", "");
   gstrlen_224 = StringLen(gs_216);
   IndicatorShortName(gs_216);
   switch (gi_316) {
   case 1:
      gsunused_332 = "EMA";
      gmamethod_320 = 1;
      break;
   case 2:
      gsunused_332 = "SMMA";
      gmamethod_320 = 2;
      break;
   case 3:
      gsunused_332 = "LWMA";
      gmamethod_320 = 3;
      break;
   case 4:
      gsunused_332 = "LSMA";
      break;
   default:
      gsunused_332 = "SMA";
      gmamethod_320 = 0;
   }
   return (0);
}

int deinit() {
   ObjectsDeleteAll(gi_228);
   return (0);
}

int start() {
   string lname_0;
   int liunused_8 = 183179428;
   ObjectDelete(gszoom01_388);
   ObjectDelete(gszoom02_396);
   int li_12 = 40;
   int li_16 = 10;
   int li_20 = 20;
   int li_24 = 15;
   int li_28 = 20;
   int li_32 = 20;
   int li_36 = garrsize_252 * li_12 + li_16;
   int li_40 = garrsize_256 * li_24 + li_28;
   gi_228 = WindowFind(gs_216);
   if (!gi_232) {
      if (garrsize_256 != garrsize_268) {
         Comment("ERROR: missing row or row label");
         return (-1);
      }
      if (garrsize_252 != garrsize_264) {
         Comment("ERROR: missing column or column label");
         return (-1);
      }
      lname_0 = gs_216 + "head" + gs_244;
      if (ObjectFind(lname_0) == -1) {
         ObjectCreate(lname_0, OBJ_LABEL, gi_228, 0, 0, 0, 0);
         ObjectSet(lname_0, OBJPROP_XDISTANCE, 60);
         ObjectSet(lname_0, OBJPROP_YDISTANCE, 1);
         ObjectSetText(lname_0, gs_76 + "     " + gs_244, 10, gfontname_88, gcolor_84);
      }
      for (int lindex_44 = 0; lindex_44 < garrsize_260; lindex_44++) {
         for (int lindex_48 = 0; lindex_48 < garrsize_252; lindex_48++) {
            lname_0 = gs_216 + "h" + lindex_44 + lindex_48;
            if (ObjectFind(lname_0) == -1) ObjectCreate(lname_0, OBJ_LABEL, gi_228, 0, 0, 0, 0);
            ObjectSet(lname_0, OBJPROP_XDISTANCE, lindex_48 * li_12 + li_32 + li_36 * lindex_44 % 2);
            ObjectSet(lname_0, OBJPROP_YDISTANCE, li_20 + li_40 * (lindex_44 / 2));
            ObjectSetText(lname_0, gsa_284[lindex_48], 10, gfontname_88, gcolor_140);
         }
      }
   }
   for (lindex_44 = 0; lindex_44 < garrsize_260; lindex_44++) {
      for (lindex_48 = 0; lindex_48 < garrsize_252; lindex_48++) {
         for (int lindex_52 = 0; lindex_52 < garrsize_256; lindex_52++) {
            DoWork(gsa_276[lindex_52], gsa_272[lindex_48], gsa_280[lindex_44]);
            lname_0 = gs_216 + "R" + lindex_52 + "C" + lindex_48 + "T" + lindex_44;
            if (ObjectFind(lname_0) == -1) ObjectCreate(lname_0, OBJ_LABEL, gi_228, 0, 0, 0, 0);
            ObjectSet(lname_0, OBJPROP_XDISTANCE, lindex_48 * li_12 + li_32 + li_36 * lindex_44 % 2);
            ObjectSet(lname_0, OBJPROP_YDISTANCE, lindex_52 * li_24 + li_20 + li_28 + li_40 * (lindex_44 / 2));
            if (gi_100) ObjectSetText(lname_0, gtext_324, gfontsize_96, "Wingdings", gcolor_312);
            else ObjectSetText(lname_0, "лллл", 10, gsterminal_304, gcolor_312);
         }
      }
   }
   DoBias();
   ObjectsRedraw();
   return (0);
}

bool IsMini() {
   return (StringFind(Symbol(), "m") > -1);
}

string MakeUniqueName(string as_0, string as_8) {
   for (string lsret_16 = as_0 + (MathRand() % 1001) + as_8; WindowFind(lsret_16) > 0; lsret_16 = as_0 + (MathRand() % 1001) + as_8) {
   }
   return (lsret_16);
}

int stringToTimeFrame(string as_0) {
   int liret_8 = 0;
   as_0 = StringTrimLeft(StringTrimRight(StringUpperCase(as_0)));
   if (as_0 == "M1" || as_0 == "1") liret_8 = 1;
   if (as_0 == "M5" || as_0 == "5") liret_8 = 5;
   if (as_0 == "M15" || as_0 == "15") liret_8 = 15;
   if (as_0 == "M30" || as_0 == "30") liret_8 = 30;
   if (as_0 == "H1" || as_0 == "60") liret_8 = 60;
   if (as_0 == "H4" || as_0 == "240") liret_8 = 240;
   if (as_0 == "D1" || as_0 == "1440") liret_8 = 1440;
   if (as_0 == "W1" || as_0 == "10080") liret_8 = 10080;
   if (as_0 == "MN" || as_0 == "43200") liret_8 = 43200;
   return (liret_8);
}

string StringUpperCase(string as_0) {
   int li_8;
   string lsret_12 = as_0;
   for (int li_20 = StringLen(as_0) - 1; li_20 >= 0; li_20--) {
      li_8 = StringGetChar(lsret_12, li_20);
      if ((li_8 > '`' && li_8 < '{') || (li_8 > 'п' && li_8 < 256)) lsret_12 = StringSetChar(lsret_12, li_20, li_8 - 32);
      else
         if (li_8 > -33 && li_8 < 0) lsret_12 = StringSetChar(lsret_12, li_20, li_8 + 224);
   }
   return (lsret_12);
}

void DoWork(string as_0, string as_8, string asunused_16) {
   int ltimeframe_24 = stringToTimeFrame(as_0);
   int lstr2int_28 = StrToInteger(as_8);
   double liclose_32 = iClose(NULL, ltimeframe_24, 0);
   double liclose_40 = iClose(NULL, ltimeframe_24, 1);
   double lima_48 = iMA(NULL, ltimeframe_24, lstr2int_28, 0, gmamethod_320, PRICE_CLOSE, 0);
   double lima_56 = iMA(NULL, ltimeframe_24, lstr2int_28, 0, gmamethod_320, PRICE_CLOSE, 1);
   if (lima_48 > lima_56 && liclose_32 > lima_48) {
      gsunused_236 = "+";
      gtext_324 = gs_176;
      gcolor_312 = gi_156;
      return;
   }
   if (lima_48 <= lima_56 && liclose_32 > lima_48) {
      gsunused_236 = "x";
      gtext_324 = gs_184;
      gcolor_312 = gi_160;
      return;
   }
   if (lima_48 >= lima_56 && liclose_32 < lima_48) {
      gsunused_236 = "x";
      gtext_324 = gs_200;
      gcolor_312 = gi_168;
      return;
   }
   if (lima_48 < lima_56 && liclose_32 < lima_48) {
      gsunused_236 = "-";
      gtext_324 = gs_208;
      gcolor_312 = gi_172;
   }
}

void DoBias() {
   double liclose_0 = iClose(NULL, 0, 0);
   double lima_8 = iMA(NULL, PERIOD_M15, 89, 0, MODE_LWMA, PRICE_CLOSE, 0);
   if (liclose_0 >= lima_8) {
      gtext_340 = "LONG";
      gcolor_348 = Lime;
   } else {
      gtext_340 = "SHORT";
      gcolor_348 = Red;
   }
   string lname_16 = gs_216 + "bias" + gs_244;
   if (ObjectFind(lname_16) == -1) {
      ObjectCreate(lname_16, OBJ_LABEL, gi_228, 0, 0, 0, 0);
      ObjectSet(lname_16, OBJPROP_XDISTANCE, 290);
      ObjectSet(lname_16, OBJPROP_YDISTANCE, 1);
      ObjectSetText(lname_16, gtext_340, 10, gfontname_88, gcolor_348);
   }
}
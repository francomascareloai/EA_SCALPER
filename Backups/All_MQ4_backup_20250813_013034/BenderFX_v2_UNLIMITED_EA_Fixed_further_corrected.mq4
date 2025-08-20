//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019 Expert Advisor BenderFX_AggressiveFibo By Jon,Luca,Ernest";
#property link "";
#property version "";

#import "stdlib.ex4"

string ErrorDescription(int);

#import

enum AVAILABLE_EXPIRATION_TIME {
   M15 = 0, // M15
   M30 = 1, // M30
   H1 = 2, // H1
   H2 = 3, // H2
   H4 = 4, // H4
   H6 = 5, // H6
   H12 = 6, // H12
   H16 = 7, // H16
   H20 = 8, // H20
   D1 = 9 // D1
};

enum AVAILABLE_TIMEFRAMES {
   Min_1 = 0, // Min_1
   Min_M5 = 1, // Min_M5
   Min_15 = 2, // Min_15
   Min_30 = 3, // Min_30
   Hour_1 = 4, // Hour_1
   Hour_4 = 5, // Hour_4
   Daily = 6, // Daily
   Weekly = 7 // Weekly
};

extern double FixedLots = 0.01;
extern double LotsExponent = 1.44;
extern bool UseTakeProfit = true;
extern int TakeProfit = 100;
extern bool UseStopLoss;
extern int StopLoss = 500;
extern int Pipstep = 120;
extern string limitTime = "Limit trading time? True for yes - Based in Local Hour";
extern bool limit_time;
extern int from = 22;
extern int to = 6;
extern string xx = "Fuzzy Settings - Optimize Using another technique - Default None";
extern int openCond = 2;
extern string note3 = "1: Highs/Lows BO, 2:None";
extern string note32 = "If BO = 1 --> Select expiration time";
extern AVAILABLE_EXPIRATION_TIME expt = H4;
extern string limitTime2 = "Daily Trading Settings: 0 for no limit in trades";
extern int dailyProfit;
extern int dailyLoss;
extern int fibo_buy;
extern int fibo_sell;
extern int MagicNumber = 2019;
extern string abc = "Period for Fibonacci - Recommended: 1 period above actual";
extern AVAILABLE_TIMEFRAMES periodForFibo = Hour_1;

int G_i_0;
long I_l_0;
long I_l_1;
long I_l_2;
int I_i_1;
int I_i_2;
int I_i_3;
int I_i_4;

double G_d_0;
double I_d_1;
double I_d_2;
int I_i_5;
int I_i_6;
double I_d_3;
double I_d_4;
int G_i_7;
double I_d_5;
double I_d_7;
double I_d_8;
int I_i_8;
double I_d_9;
double I_d_10;
double I_d_11;
double I_d_12;
double I_d_13;
int I_i_9;
double I_d_14;
bool I_b_0;
int G_i_10;
double I_d_15;
double G_d_16;
double I_d_17;
bool I_b_1;
bool I_b_2;
double I_d_18;
int G_i_11;
bool I_b_3;








double I_d_19;
double I_d_20;
double I_d_21;
double I_d_22;
double I_d_23;
double I_d_24;
double I_d_25;
long I_l_3;
long G_l_4;
double I_d_26;
int I_i_12;
double G_d_27;
int G_i_13;
int G_i_14;
bool G_b_4;
int G_i_15;
int G_i_16;
int G_i_17;
int G_i_18;
int G_i_19;
int G_i_20;
int G_i_21;
int G_i_22;
int G_i_23;
int G_i_24;
int G_i_25;
int G_i_26;
int G_i_27;
int G_i_28;
int G_i_29;
int G_i_30;
int G_i_31;
int G_i_32;
int G_i_33;
bool G_b_5;
int G_i_34;
int G_i_35;
int G_i_36;
int G_i_37;
int G_i_38;
int G_i_39;
int G_i_40;
int G_i_41;
int G_i_42;
int G_i_43;
int G_i_44;
int G_i_45;
int G_i_46;
int G_i_47;
int G_i_48;
int G_i_49;
int G_i_50;
int G_i_51;
int G_i_52;
int G_i_53;
int G_i_54;
bool G_b_6;
int G_i_55;
int G_i_56;
int G_i_57;
int G_i_58;
int G_i_59;
int G_i_60;
int G_i_61;
int G_i_62;
int G_i_63;
int G_i_64;
double G_d_28;
int G_i_65;
bool G_b_7;
bool G_b_8;
int G_i_66;
bool G_b_9;
bool G_b_10;
int G_i_67;
int G_i_68;
int G_i_69;
int G_i_70;
int G_i_71;
int G_i_72;
int G_i_73;
int G_i_74;
int G_i_75;
int G_i_76;
int G_i_77;
int I_i_78;
int G_i_79;
int I_i_80;
int G_i_81;
int I_i_82;
int G_i_83;

int G_i_84;
int G_i_86;
int G_i_87;
int G_i_88;
int G_i_89;
int G_i_90;
int G_i_91;
double I_d_29;
double I_d_30;
double I_d_31;
double I_d_32;
double I_d_33;
double I_d_34;
double I_d_35;
double I_d_36;
double I_d_37;
double I_d_38;
double G_d_39;
double G_d_40;
int G_i_92;
int I_i_93;
double G_d_41;
int G_i_95;
int G_i_96;
long G_l_6;
long G_l_7;
int G_i_97;
int I_i_98;
int I_i_99;
int G_i_100;
int I_i_101;
int I_i_102;
int G_i_103;
int G_i_104;

double G_d_46;
bool I_b_16;
double I_d_47;
double I_d_48;
double I_d_49;
long G_l_8;
long G_l_9;
double I_d_51;
string I_s_0;
int I_i_106;
int G_i_107;
int G_i_108;
double G_d_52;
int G_i_109;
double G_d_54;
int G_i_110;
long G_l_10;
long G_l_11;
double I_d_57;
long G_l_12;
int I_i_111;
bool I_b_19;
bool I_b_20;
bool I_b_21;
int I_i_112;
bool I_b_22;
double I_d_58;
double I_d_59;
bool I_b_23;
double I_d_60;
double I_d_61;
bool I_b_24;
int I_i_113;
int I_i_114;
bool I_b_25;
int I_i_115;
int I_i_116;
int I_i_117;
int I_i_118;
int I_i_119;
int I_i_120;
int I_i_121;
int I_i_122;
bool I_b_26;
int I_i_123;
int I_i_124;
int I_i_125;
bool I_b_27;
bool I_b_28;
bool I_b_29;
bool I_b_30;
bool I_b_31;
bool I_b_32;
bool I_b_33;
bool I_b_34;
bool I_b_35;
bool I_b_36;
double I_d_62;
double I_d_63;
double I_d_64;
bool I_b_37;
bool I_b_38;
int I_i_126;
int I_i_127;
int I_i_128;
int I_i_129;
int I_i_130;
int I_i_131;
int I_i_132;
int I_i_133;
int I_i_134;
int I_i_135;
int I_i_136;
int I_i_137;
int I_i_138;
int I_i_139;
int I_i_140;
int I_i_141;
int I_i_142;
int I_i_143;
int I_i_144;
int I_i_145;
int I_i_146;
double I_d_65;
double I_d_66;
double I_d_67;
double I_d_68;
int I_i_147;
double I_d_69;
bool I_b_39;
string I_s_1;
int I_i_148;
int I_i_149;
string I_s_2;
string I_s_3;
int I_i_150;
int I_i_151;
int I_i_152;
string I_s_4;
string I_s_5;
string I_s_6;
string I_s_7;
string I_s_8;
string I_s_9;
string I_s_10;
string I_s_11;
string I_s_12;
string I_s_13;
string I_s_14;
long I_l_13;




int I_i_153;
int I_i_154;

int I_i_155;
int I_i_156;
int I_i_157;
int I_i_158;
int I_i_159;
int I_i_160;
int I_i_161;
long I_l_14;
string I_s_15;
string I_s_16;
string I_s_17;
string I_s_18;
bool I_b_40;
string I_s_19;
string I_s_20;
long I_l_15;
int G_i_162;
double I_d_70;
int G_i_163;
long G_l_24;
long G_l_25;
double G_d_73;
long G_l_33;
long G_l_34;
double G_d_83;
int G_i_164;
long G_l_37;
long G_l_38;
long G_l_39;
double G_d_91;
double G_d_92;
int G_i_165;
int G_i_166;
int G_i_167;
int G_i_168;
int G_i_169;
double G_d_93;
double G_d_94;
int G_i_170;
int G_i_171;
int G_i_172;
int G_i_173;
int G_i_174;
int G_i_175;
int G_i_176;
int G_i_177;
int G_i_178;
int G_i_179;
int G_i_180;
int G_i_181;
int G_i_182;
int G_i_183;
int G_i_184;
int G_i_185;
int G_i_186;
int G_i_187;
int G_i_188;
int G_i_189;
int G_i_190;
int G_i_191;
int G_i_192;
int G_i_193;
int G_i_194;
int G_i_195;
int G_i_196;
int G_i_197;
int G_i_198;
int G_i_199;
int G_i_200;
int G_i_201;
int G_i_202;
int G_i_203;
int G_i_204;
int G_i_205;
int G_i_206;
int G_i_207;
int G_i_208;
int G_i_209;
int G_i_210;
int G_i_211;
int G_i_212;
int G_i_213;
int G_i_214;
int G_i_215;
double G_d_95;
long G_l_40;
long G_l_41;
long G_l_42;
long G_l_43;
long G_l_44;

int I_i_216[10] = { 900, 1800, 3600, 7200, 14400, 21600, 43200, 57600, 72000, 86400 };
double I_d_96[];
double I_d_97[];
double I_d_98[];
double I_d_99[];
double I_d_100[];
double I_d_101[];
double I_d_102[];
double I_d_103[];
double I_d_104[30];
int I_i_217[150];
int I_i_218[150];
string I_s_21[150];
int I_i_219[150];
int I_i_220[150];
string I_s_22[150];
int I_i_221[150];
int I_i_222[150];
string I_s_23[150];
string I_s_24[150];
string I_s_25[150];
string I_s_26[150];
string I_s_27[150];
long I_l_45[150];
int I_i_223[150];
int I_i_224[150];
int I_i_225[150];
string I_s_28[150];
string I_s_29[150];
string I_s_30[150];
string I_s_31[150];
string I_s_32[150];
string I_s_33[150];
int I_i_226[150];
int I_i_227[150];
string I_s_34[150];
int I_i_228[9] = { 1, 5, 15, 30, 60, 240, 1440, 10080, 43200 };
double returned_double;
string Global_ReturnedString;
int init() {
   I_i_111 = 2;
   I_b_16 = false;
   I_d_3 = 0.1;
   I_b_19 = false;
   I_b_20 = false;
   I_b_21 = false;
   I_i_112 = 20;
   I_b_22 = false;
   I_d_58 = 20;
   I_d_59 = 0;
   I_b_23 = false;
   I_d_60 = 0;
   I_d_61 = 0;
   I_b_24 = false;
   I_i_113 = 20;
   I_i_114 = 20;
   I_b_25 = false;
   I_i_115 = 10;
   I_i_116 = 10;
   I_i_117 = 0;
   I_i_9 = 500;
   I_i_98 = 30;
   I_i_101 = 30;
   I_i_8 = 100;
   I_i_118 = 0;
   I_i_119 = 0;
   I_i_120 = 0;
   I_i_121 = 14;
   I_i_122 = 60;
   I_d_5 = 50;
   I_d_37 = 76.4;
   I_d_30 = 23.6;
   I_i_80 = 0;
   I_i_82 = 20;
   I_b_26 = false;
   I_i_123 = 4;
   I_i_124 = 60;
   I_i_125 = 60;
   I_i_12 = 0;
   I_i_6 = 2;
   I_b_27 = true;
   I_b_28 = true;
   I_b_29 = true;
   I_b_30 = true;
   I_b_31 = true;
   I_b_32 = true;
   I_b_33 = true;
   I_b_34 = true;
   I_b_35 = true;
   I_b_36 = true;
   I_d_62 = 100;
   I_d_63 = 0;
   I_d_64 = 0;
   I_b_37 = false;
   I_b_38 = false;
   I_i_126 = 0;
   I_i_127 = 0;
   I_i_128 = 0;
   I_i_129 = 13382297;
   I_i_130 = 16711680;
   I_i_131 = 255;
   I_i_132 = 65535;
   I_i_133 = 32768;
   I_i_106 = 10;
   I_s_0 = "BenderFX_AgressiveFibo_" + (string)_Period;
   I_i_134 = 10;
   I_i_135 = 40;
   I_i_136 = 125;
   I_i_137 = 250;
   I_i_138 = 385;
   I_i_139 = 0;
   I_i_140 = 0;
   I_i_141 = 23;
   I_i_142 = 59;
   I_i_78 = 0;
   I_i_99 = 0;
   I_i_102 = 0;
   I_i_143 = 0;
   I_i_144 = 0;
   I_b_3 = true;
   I_d_19 = 0;
   I_d_25 = 1;
   I_i_145 = 16711680;
   I_i_146 = 11119017;
   I_d_20 = 0.236;
   I_d_21 = 0.382;
   I_d_22 = 0.5;
   I_d_23 = 0.618;
   I_d_24 = 0.764;
   I_d_65 = 0;
   I_d_66 = 0;
   I_i_5 = 0;
   I_d_67 = 0;
   I_d_68 = 0;
   I_d_4 = 0;
   I_d_7 = 0;
   I_d_47 = 0;
   I_d_9 = 0;
   I_d_48 = 0;
   I_d_49 = 0;
   I_d_14 = 0;
   I_d_10 = 0;
   I_d_11 = 0;
   I_b_0 = false;
   I_d_17 = 0;
   I_i_93 = 0;
   I_d_15 = 0;
   I_b_2 = true;
   I_d_26 = 240;
   I_d_18 = 0;
   I_i_147 = 0;
   I_d_29 = 0;
   I_d_69 = 0;
   I_d_12 = 0;
   I_d_13 = 0;
   I_b_39 = false;
   I_s_1 = "";
   I_i_148 = 0;
   I_i_149 = 0;
   I_i_150 = 0;
   I_i_151 = 0;
   I_i_152 = 0;
   I_s_4 = "";
   I_s_5 = "";
   I_s_6 = "";
   I_s_7 = "";
   I_s_8 = "";
   I_s_9 = "";
   I_s_10 = "";
   I_s_11 = "";
   I_s_12 = "";
   I_s_13 = "";
   I_s_14 = "";
   I_l_13 = 0;
   I_i_153 = 0;
   I_i_154 = 0;
   I_i_155 = 0;
   I_i_156 = 0;
   I_i_157 = 0;
   I_i_158 = 150;
   I_i_159 = 150;
   I_i_160 = 0;
   I_i_161 = 0;
   I_l_14 = 0;
   I_s_15 = "";
   I_s_16 = "";
   I_s_17 = "";
   I_s_18 = "";
   I_b_40 = false;
   I_s_19 = "";
   I_s_20 = "";
   I_i_1 = 0;
   I_i_2 = 0;
   I_l_0 = 0;
   I_l_2 = 0;
   I_i_3 = 0;
   I_l_3 = 0;
   I_d_51 = 0;
   I_d_57 = 0;
   I_l_15 = 0;
   I_d_31 = 0;
   I_d_32 = 0;
   I_d_33 = 0;
   I_d_34 = 0;
   I_d_35 = 0;
   I_d_36 = 0;
   I_d_38 = 0;
   string S_s_58;
   string S_s_59;
   string S_s_60;
   string S_s_61;
   string S_s_62;
   string S_s_63;
   string S_s_64;
   string S_s_65;
   string S_s_66;
   string S_s_67;
   string S_s_68;
   string S_s_69;
   string S_s_70;
   int L_i_30;
   int L_i_28;
   double L_d_40;
   L_i_30 = 0;
   L_i_28 = 0;
   L_d_40 = 0;
   G_i_0 = 0;
   I_l_0 = TimeGMT();
   I_l_2 = TimeCurrent();
   S_s_58 = TimeToString(I_l_0, 3);
   S_s_59 = StringSubstr(S_s_58, 11, 2);
   I_i_1 = StringToDouble(S_s_59);
   S_s_60 = TimeToString(I_l_0, 3);
   S_s_61 = StringSubstr(S_s_60, 14, 2);
   I_i_2 = StringToDouble(S_s_61);
   I_i_3 = TimeHour(I_l_2) - I_i_1;
   if (I_i_3 < 0) {
      I_i_3 = I_i_3 + 24;
   }
   L_i_28 = 0;
   ArrayInitialize(I_d_104, 0);
   S_s_62 = (string)_Digits;
   S_s_62 = "Digits: " + S_s_62;
   S_s_62 = S_s_62 + " Point: ";
   S_s_63 = (string)_Point;
   S_s_62 = S_s_62 + S_s_63;
   Print(S_s_62);
   L_d_40 = MarketInfo(_Symbol, MODE_LOTSTEP);
   G_d_0 = log(L_d_40);
   I_i_5 = (G_d_0 / -2.30258509299405);
   I_i_4 = I_i_6;
   if (I_i_4 == 0) I_i_12 = 1;
   if (I_i_4 == 1) I_i_12 = 2;
   if (I_i_4 == 2) I_i_12 = 3;
   I_d_4 = (I_d_3 / 100);
   I_d_7 = NormalizeDouble((I_d_5 * _Point), (_Digits + 1));
   I_d_9 = NormalizeDouble((I_i_8 * _Point), _Digits);
   I_d_10 = NormalizeDouble((StopLoss * _Point), _Digits);
   I_d_11 = NormalizeDouble((TakeProfit * _Point), _Digits);
   I_d_12 = MarketInfo(_Symbol, MODE_STOPLEVEL);
   I_d_13 = (MarketInfo(_Symbol, MODE_STOPLEVEL) * _Point);
   I_d_14 = NormalizeDouble((_Point * I_i_9), _Digits);
   I_b_0 = false;
   I_d_17 = NormalizeDouble((I_d_15 * _Point), (_Digits + 1));
   if (IsTesting() != true) {
      if (I_b_2) {
         L_i_28 = _Period;
         I_i_4 = L_i_28;
         if (I_i_4 >= 1 && I_i_4 <= 43200) {
            if (I_i_4 == 1) I_d_26 = 5;
            if (I_i_4 == 5) I_d_26 = 15;
            if (I_i_4 == 15) I_d_26 = 30;
            if (I_i_4 == 30) I_d_26 = 60;
            if (I_i_4 == 60) I_d_26 = 240;
            if (I_i_4 == 240) I_d_26 = 1440;
            if (I_i_4 == 1440) I_d_26 = 10080;
            if (I_i_4 == 10080) I_d_26 = 43200;
            if (I_i_4 == 43200) I_d_26 = 43200;
         }
      }
      I_d_18 = 0.0001;
   }
   ObjectsTotal(-1);
   G_i_11 = ObjectsTotal(-1) - 1;
   G_i_0 = G_i_11;
   if (G_i_11 >= 0) {
      do {
         if (I_b_3) {
            S_s_63 = ObjectName(G_i_0);
            if (StringFind(S_s_63, "v_u_hl", 0) > -1) {
               ObjectDelete(S_s_63);
            }
            if (StringFind(S_s_63, "v_l_hl", 0) > -1) {
               ObjectDelete(S_s_63);
            }
            if (StringFind(S_s_63, "Fibo_hl", 0) > -1) {
               ObjectDelete(S_s_63);
            }
            if (StringFind(S_s_63, "trend_hl", 0) > -1) {
               ObjectDelete(S_s_63);
            }
            WindowRedraw();
         } else {
            S_s_63 = ObjectName(G_i_0);
            if (StringFind(S_s_63, "v_u_lh", 0) > -1) {
               ObjectDelete(S_s_63);
            }
            if (StringFind(S_s_63, "v_l_lh", 0) > -1) {
               ObjectDelete(S_s_63);
            }
            if (StringFind(S_s_63, "Fibo_lh", 0) > -1) {
               ObjectDelete(S_s_63);
            }
            if (StringFind(S_s_63, "trend_lh", 0) > -1) {
               ObjectDelete(S_s_63);
            }
            WindowRedraw();
         }
         G_i_0 = G_i_0 - 1;
      } while (G_i_0 >= 0);
   }
   SetIndexBuffer(0, I_d_96);
   SetIndexBuffer(1, I_d_97);
   SetIndexBuffer(2, I_d_98);
   SetIndexBuffer(3, I_d_99);
   SetIndexBuffer(4, I_d_100);
   SetIndexBuffer(5, I_d_101);
   SetIndexBuffer(6, I_d_102);
   SetIndexBuffer(7, I_d_103);
   S_s_64 = "Fibo_" + DoubleToString(I_d_19, 4);
   SetIndexLabel(0, S_s_64);
   S_s_65 = "Fibo_" + DoubleToString(I_d_20, 4);
   SetIndexLabel(1, S_s_65);
   S_s_66 = "Fibo_" + DoubleToString(I_d_21, 4);
   SetIndexLabel(2, S_s_66);
   S_s_67 = "Fibo_" + DoubleToString(I_d_22, 4);
   SetIndexLabel(3, S_s_67);
   S_s_68 = "Fibo_" + DoubleToString(I_d_23, 4);
   SetIndexLabel(4, S_s_68);
   S_s_69 = "Fibo_" + DoubleToString(I_d_24, 4);
   SetIndexLabel(5, S_s_69);
   S_s_70 = "Fibo_" + DoubleToString(I_d_25, 4);
   SetIndexLabel(7, S_s_70);
   I_l_3 = Time[0];
   L_i_30 = 0;
   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start() {
   string S_s_58;
   string S_s_59;
   string S_s_60;
   string S_s_61;
   string S_s_62;
   double L_d_1;
   double L_d_40;
   double L_d_37;
   double L_d_4;
   int L_i_2;
   string L_s_0;
   int L_i_27;
   double L_d_5;
   double L_d_6;
   int L_i_4;
   double L_d_7;
   double L_d_8;
   double L_d_9;
   double L_d_10;
   double L_d_11;
   double L_d_12;
   double L_d_13;
   int L_i_5;
   int L_i_6;
   double L_d_14;
   double L_d_15;
   int L_i_7;
   int L_i_8;
   double L_d_16;
   double L_d_17;
   int L_i_9;
   double L_d_18;
   double L_d_19;
   int L_i_10;
   double L_d_20;
   double L_d_21;
   double L_d_22;
   double L_d_23;
   int L_i_11;
   double L_d_24;
   double L_d_25;
   int L_i_12;
   double L_d_26;
   double L_d_27;
   int L_i_13;
   int L_i_14;
   int L_i_15;
   int L_i_16;
   int L_i_17;
   int L_i_18;
   bool L_b_0;
   bool L_b_1;
   bool L_b_2;
   int L_i_19;
   double L_d_28;
   double L_d_29;
   double L_d_30;
   double L_d_31;
   double L_d_32;
   double L_d_33;
   double L_d_34;
   double L_d_35;
   int L_i_20;
   int L_i_21;
   int L_i_22;
   L_d_1 = 0;
   L_d_40 = 0;
   L_d_37 = 0;
   L_d_4 = 0;
   L_i_2 = 0;
   L_i_27 = 0;
   L_d_5 = 0;
   L_d_6 = 0;
   L_i_4 = 0;
   L_d_7 = 0;
   L_d_8 = 0;
   L_d_9 = 0;
   L_d_10 = 0;
   L_d_11 = 0;
   L_d_12 = 0;
   L_d_13 = 0;
   L_i_5 = 0;
   L_i_6 = 0;
   L_d_14 = 0;
   L_d_15 = 0;
   L_i_7 = 0;
   L_i_8 = 0;
   L_d_16 = 0;
   L_d_17 = 0;
   L_i_9 = 0;
   L_d_18 = 0;
   L_d_19 = 0;
   L_i_10 = 0;
   L_d_20 = 0;
   L_d_21 = 0;
   L_d_22 = 0;
   L_d_23 = 0;
   L_i_11 = 0;
   L_d_24 = 0;
   L_d_25 = 0;
   L_i_12 = 0;
   L_d_26 = 0;
   L_d_27 = 0;
   L_i_13 = 0;
   L_i_14 = 0;
   L_i_15 = 0;
   L_i_16 = 0;
   L_i_17 = 0;
   L_i_18 = 0;
   L_b_0 = false;
   L_b_1 = false;
   L_b_2 = false;
   L_i_19 = 0;
   L_d_28 = 0;
   L_d_29 = 0;
   L_d_30 = 0;
   L_d_31 = 0;
   L_d_32 = 0;
   L_d_33 = 0;
   L_d_34 = 0;
   L_d_35 = 0;
   L_i_20 = 0;
   L_i_21 = 0;
   L_i_22 = 0;
   G_d_27 = 0;
   G_i_7 = 0;
   G_i_10 = 0;
   G_d_16 = 0;
   G_i_13 = 0;
   G_i_14 = 0;
   G_b_4 = false;
   G_i_15 = 0;
   G_i_16 = 0;
   G_i_17 = 0;
   G_i_18 = 0;
   G_i_19 = 0;
   G_i_20 = 0;
   G_i_21 = 0;
   G_i_22 = 0;
   G_i_23 = 0;
   G_i_24 = 0;
   G_i_25 = 0;
   G_i_26 = 0;
   G_i_27 = 0;
   G_i_28 = 0;
   G_i_29 = 0;
   G_i_30 = 0;
   G_i_31 = 0;
   G_i_32 = 0;
   G_i_33 = 0;
   G_b_5 = false;
   G_i_34 = 0;
   G_i_35 = 0;
   G_i_36 = 0;
   G_i_37 = 0;
   G_i_38 = 0;
   G_i_39 = 0;
   G_i_40 = 0;
   G_i_41 = 0;
   G_i_42 = 0;
   G_i_43 = 0;
   G_i_44 = 0;
   G_i_45 = 0;
   G_i_46 = 0;
   G_i_47 = 0;
   G_i_48 = 0;
   G_i_49 = 0;
   G_i_50 = 0;
   G_i_51 = 0;
   G_i_52 = 0;
   G_i_53 = 0;
   G_i_54 = 0;
   G_b_6 = false;
   G_i_55 = 0;
   G_i_56 = 0;
   G_i_57 = 0;
   G_i_58 = 0;
   G_i_59 = 0;
   G_i_60 = 0;
   G_i_61 = 0;
   G_i_62 = 0;
   G_i_63 = 0;
   G_i_64 = 0;
   G_d_28 = 0;
   G_i_65 = 0;
   G_b_7 = false;
   G_b_8 = false;
   G_i_66 = 0;
   G_b_9 = false;
   G_b_10 = false;
   G_i_67 = 0;
   G_i_68 = 0;
   G_i_69 = 0;
   G_i_70 = 0;
   G_i_71 = 0;
   G_i_72 = 0;
   G_i_73 = 0;
   G_i_74 = 0;
   G_i_75 = 0;
   G_i_76 = 0;
   G_i_77 = 0;
   CalcFibo();
   graf();
   L_d_1 = Pipstep;
   L_d_40 = Pipstep;
   G_d_27 = 0;
   G_i_7 = 0;
   G_i_10 = 0;
   I_i_78 = OrdersTotal() - 1;
   if (I_i_78 >= 0) {
      do {
         if (OrderSelect(I_i_78, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
            G_i_7 = OrderTicket();
            if (G_i_7 > G_i_10) {
               G_d_27 = OrderOpenPrice();
               G_i_10 = G_i_7;
            }
         }
         I_i_78 = I_i_78 - 1;
      } while (I_i_78 >= 0);
   }
   L_d_37 = G_d_27;
   G_d_16 = 0;
   G_i_13 = 0;
   G_i_14 = 0;
   I_i_78 = OrdersTotal() - 1;
   if (I_i_78 >= 0) {
      do {
         if (OrderSelect(I_i_78, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
            G_i_13 = OrderTicket();
            if (G_i_13 > G_i_14) {
               G_d_16 = OrderOpenPrice();
               G_i_14 = G_i_13;
            }
         }
         I_i_78 = I_i_78 - 1;
      } while (I_i_78 >= 0);
   }
   L_d_4 = G_d_16;
   L_i_2 = 0;
   L_i_27 = 0;
   L_d_5 = 0;
   L_d_6 = 0;
   L_i_4 = 0;
   L_d_7 = 0;
   L_d_8 = 0;
   L_d_9 = 0;
   L_d_10 = 0;
   L_d_11 = 0;
   L_d_12 = 0;
   L_d_13 = 0;
   L_i_5 = 0;
   L_i_6 = 0;
   L_d_14 = 0;
   L_d_15 = 0;
   L_i_7 = iLowest(NULL, I_i_228[periodForFibo], 1, I_i_82, I_i_80);
   L_i_8 = iHighest(NULL, I_i_228[periodForFibo], 2, I_i_82, I_i_80);
   L_d_16 = 0;
   L_d_17 = 0;
   L_d_15 = iHigh(NULL, I_i_228[periodForFibo], L_i_8);
   returned_double = iLow(NULL, I_i_228[periodForFibo], L_i_7);
   L_d_14 = returned_double;
   I_d_29 = (L_d_15 - returned_double);
   if (L_i_7 > L_i_8) {
      I_d_31 = (((I_d_30 / 100) * I_d_29) + returned_double);
      I_d_32 = ((I_d_29 * 0.236) + returned_double);
      I_d_33 = ((I_d_29 * 0.382) + returned_double);
      I_d_34 = ((I_d_29 * 0.5) + returned_double);
      I_d_35 = ((I_d_29 * 0.618) + returned_double);
      I_d_36 = ((I_d_29 * 0.764) + returned_double);
      I_d_38 = (((I_d_37 / 100) * I_d_29) + returned_double);
   } else {
      G_d_39 = ((I_d_30 / 100) * I_d_29);
      I_d_31 = (L_d_15 - G_d_39);
      G_d_39 = (I_d_29 * 0.236);
      I_d_32 = (L_d_15 - G_d_39);
      G_d_39 = (I_d_29 * 0.382);
      I_d_33 = (L_d_15 - G_d_39);
      G_d_39 = (I_d_29 * 0.5);
      I_d_34 = (L_d_15 - G_d_39);
      G_d_39 = (I_d_29 * 0.618);
      I_d_35 = (L_d_15 - G_d_39);
      G_d_39 = (I_d_29 * 0.764);
      I_d_36 = (L_d_15 - G_d_39);
      G_d_39 = ((I_d_37 / 100) * I_d_29);
      I_d_38 = (L_d_15 - G_d_39);
   }
   if (I_b_0 != true) {
      L_i_9 = HistoryTotal() - 1;
      if (L_i_9 >= 0) {
         do {
            if (OrderSelect(L_i_9, 0, 1) && (OrderProfit() != 0)) {
               G_d_39 = OrderClosePrice();
               if ((G_d_39 != OrderOpenPrice()) && OrderSymbol() == _Symbol) {
                  I_b_0 = true;
                  G_d_39 = OrderProfit();
                  G_d_40 = OrderClosePrice();
                  L_d_6 = fabs((G_d_39 / (G_d_40 - OrderOpenPrice())));
                  G_d_40 = -OrderCommission();
                  I_d_17 = (G_d_40 / L_d_6);
                  break;
               }
            }
            L_i_9 = L_i_9 - 1;
         } while (L_i_9 >= 0);
      }
   }
   L_d_18 = (Ask - Bid);
   I_d_104[29] = L_d_18;
   if (I_i_93 < 30) {
      I_i_93 = I_i_93 + 1;
   }
   L_d_19 = 0;
   L_i_9 = 29;
   L_i_10 = 0;
   if (I_i_93 > 0) {
      do {
         L_d_19 = (L_d_19 + I_d_104[L_i_9]);
         L_i_9 = L_i_9 - 1;
         L_i_10 = L_i_10 + 1;
      } while (L_i_10 < I_i_93);
   }
   L_d_20 = (L_d_19 / I_i_93);
   L_d_21 = NormalizeDouble((Ask + I_d_17), _Digits);
   L_d_22 = NormalizeDouble((Bid - I_d_17), _Digits);
   L_d_23 = NormalizeDouble((L_d_20 + I_d_17), (_Digits + 1));
   if (I_l_3 < Time[0]) {
      S_s_58 = "2019.03.23 00:00";
      G_i_15 = StringToTime(S_s_58);
      G_l_6 = TimeCurrent();
      G_l_7 = G_i_15;
      if (ArrayCopy(I_d_104, I_d_104, 0, 1, 29) == 14) {
         Alert(" License ended for Bender v2! Please join @sirforex at Telegram");
         G_b_4 = true;
      } else {
         G_b_4 = false;
      }
      if (G_b_4 != true) {
         I_l_3 = Time[0];
         G_i_16 = OrdersTotal();
         G_i_17 = 0;
         G_i_18 = G_i_16;
         if (G_i_16 >= 0) {
            do {
               if (OrderSelect(G_i_18, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                  G_i_17 = G_i_17 + 1;
               }
               G_i_18 = G_i_18 - 1;
            } while (G_i_18 >= 0);
         }
         if (G_i_17 > 0) {
            G_i_19 = OrdersTotal();
            G_i_20 = 0;
            G_i_21 = G_i_19;
            do {
               if (OrderSelect(G_i_21, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                  G_i_20 = G_i_20 + 1;
               }
               G_i_21 = G_i_21 - 1;
            } while (G_i_21 >= 0);
         }
         if (G_i_19 >= 0 && G_i_20 < I_i_98 && (L_d_4 - Ask >= L_d_1 * _Point)) {
            G_i_22 = OrdersTotal();
            G_i_23 = 0;
            G_i_24 = G_i_22;
            if (G_i_22 >= 0) {
               do {
                  if (OrderSelect(G_i_24, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                     G_i_23 = G_i_23 + 1;
                  }
                  G_i_24 = G_i_24 - 1;
               } while (G_i_24 >= 0);
            }
            I_i_99 = G_i_23;
         } else {
            G_i_25 = OrdersTotal();
            G_i_26 = 0;
            G_i_27 = G_i_25;
            if (G_i_25 >= 0) {
               do {
                  if (OrderSelect(G_i_27, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                     G_i_26 = G_i_26 + 1;
                  }
                  G_i_27 = G_i_27 - 1;
               } while (G_i_27 >= 0);
            }
            I_i_99 = G_i_26 - 100;
         }
         G_i_28 = OrdersTotal();
         G_i_29 = 0;
         G_i_30 = G_i_28;
         if (G_i_28 >= 0) {
            do {
               if (OrderSelect(G_i_30, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUYSTOP) {
                  G_i_29 = G_i_29 + 1;
               }
               G_i_30 = G_i_30 - 1;
            } while (G_i_30 >= 0);
         }
         L_i_11 = G_i_29;
         L_d_24 = iLow(_Symbol, 0, 2);
         L_d_25 = iLow(_Symbol, 0, 1);
         G_i_31 = OrdersTotal();
         G_i_32 = 0;
         G_i_33 = G_i_31;
         if (G_i_31 >= 0) {
            do {
               if (OrderSelect(G_i_33, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                  G_i_32 = G_i_32 + 1;
               }
               G_i_33 = G_i_33 - 1;
            } while (G_i_33 >= 0);
         }
         G_b_5 = false;
         I_i_4 = fibo_buy;
         if (I_i_4 <= 6) {
            if (I_i_4 == 0) {
               if ((Bid < I_d_31)) G_b_5 = true;
            }
            if (I_i_4 == 1) {
               if ((Bid < I_d_32)) G_b_5 = true;
            }
            if (I_i_4 == 2) {
               if ((Bid < I_d_33)) G_b_5 = true;
            }
            if (I_i_4 == 3) {
               if ((Bid < I_d_34)) G_b_5 = true;
            }
            if (I_i_4 == 4) {
               if ((Bid < I_d_35)) G_b_5 = true;
            }
            if (I_i_4 == 5) {
               if ((Bid < I_d_36)) G_b_5 = true;
            }
            if (I_i_4 == 6) {
               if ((Bid < I_d_38)) G_b_5 = true;
            }
         }
         if (G_i_32 == 0 && L_i_11 == 0 && G_b_5 && (L_d_25 < Open[0])) {
            L_i_4 = -1;
         } else {
            G_i_34 = OrdersTotal();
            G_i_35 = 0;
            G_i_36 = G_i_34;
            if (G_i_34 >= 0) {
               do {
                  if (OrderSelect(G_i_36, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                     G_i_35 = G_i_35 + 1;
                  }
                  G_i_36 = G_i_36 - 1;
               } while (G_i_36 >= 0);
            }
            if (G_i_35 == I_i_99) {
               L_i_4 = -2;
            }
         }
         G_i_37 = OrdersTotal();
         G_i_38 = 0;
         G_i_39 = G_i_37;
         if (G_i_37 >= 0) {
            do {
               if (OrderSelect(G_i_39, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
                  G_i_38 = G_i_38 + 1;
               }
               G_i_39 = G_i_39 - 1;
            } while (G_i_39 >= 0);
         }
         G_i_40 = OrdersTotal();
         G_i_41 = 0;
         G_i_42 = G_i_40;
         if (G_i_40 >= 0) {
            do {
               if (OrderSelect(G_i_42, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
                  G_i_41 = G_i_41 + 1;
               }
               G_i_42 = G_i_42 - 1;
            } while (G_i_42 >= 0);
         }
         if (G_i_38 > 0 && G_i_41 < I_i_101 && (Bid - L_d_37 > (L_d_40 * _Point))) {
            G_i_43 = OrdersTotal();
            G_i_44 = 0;
            G_i_45 = G_i_43;
            if (G_i_43 >= 0) {
               do {
                  if (OrderSelect(G_i_45, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
                     G_i_44 = G_i_44 + 1;
                  }
                  G_i_45 = G_i_45 - 1;
               } while (G_i_45 >= 0);
            }
            I_i_102 = G_i_44;
         } else {
            G_i_46 = OrdersTotal();
            G_i_47 = 0;
            G_i_48 = G_i_46;
            if (G_i_46 >= 0) {
               do {
                  if (OrderSelect(G_i_48, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
                     G_i_47 = G_i_47 + 1;
                  }
                  G_i_48 = G_i_48 - 1;
               } while (G_i_48 >= 0);
            }
            I_i_102 = G_i_47 - 100;
         }
         G_i_49 = OrdersTotal();
         G_i_50 = 0;
         G_i_51 = G_i_49;
         if (G_i_49 >= 0) {
            do {
               if (OrderSelect(G_i_51, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELLSTOP) {
                  G_i_50 = G_i_50 + 1;
               }
               G_i_51 = G_i_51 - 1;
            } while (G_i_51 >= 0);
         }
         L_i_12 = G_i_50;
         L_d_26 = iHigh(_Symbol, 0, 2);
         L_d_27 = iHigh(_Symbol, 0, 1);
         G_i_52 = OrdersTotal();
         G_i_53 = 0;
         G_i_54 = G_i_52;
         if (G_i_52 >= 0) {
            do {
               if (OrderSelect(G_i_54, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
                  G_i_53 = G_i_53 + 1;
               }
               G_i_54 = G_i_54 - 1;
            } while (G_i_54 >= 0);
         }
         G_b_6 = false;
         I_i_4 = fibo_sell;
         if (I_i_4 <= 6) {
            if (I_i_4 == 0) {
               if ((Bid > I_d_31)) G_b_6 = true;
            }
            if (I_i_4 == 1) {
               if ((Bid > I_d_32)) G_b_6 = true;
            }
            if (I_i_4 == 2) {
               if ((Bid > I_d_33)) G_b_6 = true;
            }
            if (I_i_4 == 3) {
               if ((Bid > I_d_34)) G_b_6 = true;
            }
            if (I_i_4 == 4) {
               if ((Bid > I_d_35)) G_b_6 = true;
            }
            if (I_i_4 == 5) {
               if ((Bid > I_d_36)) G_b_6 = true;
            }
            if (I_i_4 == 6) {
               if ((Bid > I_d_38)) G_b_6 = true;
            }
         }
         if (G_i_53 == 0 && (L_d_27 > Open[0]) && G_b_6 && L_i_12 == 0) {
            L_i_4 = 1;
         } else {
            G_i_55 = OrdersTotal();
            G_i_56 = 0;
            G_i_57 = G_i_55;
            if (G_i_55 >= 0) {
               do {
                  if (OrderSelect(G_i_57, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
                     G_i_56 = G_i_56 + 1;
                  }
                  G_i_57 = G_i_57 - 1;
               } while (G_i_57 >= 0);
            }
            if (G_i_56 == I_i_102) {
               L_i_4 = 2;
            }
         }
         L_i_13 = 0;
         L_i_14 = 0;
         L_i_14 = I_i_216[expt];
         if (L_i_13 == 0 && L_i_4 != 0 && (L_d_23 <= I_d_7) && dailyProfitorStopLossReached() == false) {
            G_d_46 = AccountBalance();
            G_d_46 = ((G_d_46 * AccountLeverage()) * I_d_4);
            L_d_7 = (G_d_46 / MarketInfo(_Symbol, MODE_LOTSIZE));
            if (I_b_16 != true) {
               L_d_7 = FixedLots;
            }
            G_i_58 = OrdersTotal();
            G_i_59 = 0;
            G_i_60 = G_i_58;
            if (G_i_58 >= 0) {
               do {
                  if (OrderSelect(G_i_60, 0, 0) && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                     G_i_59 = G_i_59 + 1;
                  }
                  G_i_60 = G_i_60 - 1;
               } while (G_i_60 >= 0);
            }
            returned_double = MathPow(LotsExponent, G_i_59);
            L_d_8 = NormalizeDouble((L_d_7 * returned_double), 2);
            G_i_61 = OrdersTotal();
            G_i_62 = 0;
            G_i_63 = G_i_61;
            if (G_i_61 >= 0) {
               do {
                  if (OrderSelect(G_i_63, 0, 0) && OrderMagicNumber() == MagicNumber) {
                     if (OrderType() == 1) {
                        G_i_62 = G_i_62 + 1;
                     }
                  }
                  G_i_63 = G_i_63 - 1;
               } while (G_i_63 >= 0);
            }
            returned_double = MathPow(LotsExponent, G_i_62);
            L_d_9 = NormalizeDouble((L_d_7 * returned_double), 2);
            if (L_i_4 < 0) {
               G_i_64 = 5;
               G_d_28 = Low[0];
               G_i_65 = 1;
               if (G_i_64 >= 1) {
                  do {
                     returned_double = iHigh(_Symbol, 0, G_i_65);
                     if ((returned_double > G_d_28)) {
                        G_d_28 = returned_double;
                     }
                     G_i_65 = G_i_65 + 1;
                  } while (G_i_65 <= G_i_64);
               }
               if ((G_d_28 <= I_d_12)) {
                  I_d_47 = I_d_13;
               } else {
                  I_d_47 = I_d_9;
               }
               if ((StopLoss <= I_d_12)) {
                  I_d_48 = I_d_13;
               } else {
                  I_d_48 = I_d_10;
               }
               if ((TakeProfit <= I_d_12)) {
                  I_d_49 = I_d_13;
               } else {
                  I_d_49 = I_d_11;
               }
               L_d_5 = NormalizeDouble((Ask + I_d_47), _Digits);
               L_d_10 = NormalizeDouble((L_d_5 - I_d_48), _Digits);
               L_d_11 = NormalizeDouble((L_d_5 + I_d_49), _Digits);
               if (UseStopLoss != true) {
                  L_d_13 = 0;
               } else {
                  L_d_13 = L_d_10;
               }
               if (UseTakeProfit != true) {
                  L_d_12 = 0;
               } else {
                  L_d_12 = L_d_11;
               }
               if (L_i_4 == -1) {
                  G_b_7 = false;
                  if (limit_time != true) {
                     G_b_7 = true;
                  } else {
                     if ((from <= TimeHour(TimeLocal()) && TimeHour(TimeLocal()) <= to && from < to)
                           || (((to <= TimeHour(TimeLocal()) && TimeHour(TimeLocal()) > from) && (to > TimeHour(TimeLocal()) && TimeHour(TimeLocal()) <= from)) && from > to)) {
                        G_b_7 = true;
                     }
                  }
                  if (G_b_7) {
                     S_s_59 = "2019.03.23 00:00";
                     G_i_66 = StringToTime(S_s_59);
                     G_l_8 = TimeCurrent();
                     G_l_9 = G_i_66;
                     if (I_i_4 == 14) {
                        Alert(" License ended for Bender v2! Please join @sirforex at Telegram");
                        G_b_8 = true;
                     } else {
                        G_b_8 = false;
                     }
                     if (G_b_8 != true) {
                        I_i_4 = openCond;
                        if (I_i_4 == 1) {
                           G_l_9 = TimeCurrent();
                           G_l_10 = L_i_14;
                           L_i_27 = OrderSend(_Symbol, 4, L_d_8, L_d_5, I_i_106, L_d_13, L_d_12, I_s_0, MagicNumber, (G_l_9 + G_l_10), 16711680);
                        }
                        if (I_i_4 == 2) {
                           L_i_27 = OrderSend(_Symbol, 0, L_d_8, Ask, I_i_106, L_d_13, L_d_11, I_s_0, MagicNumber, 0, 16711680);
                        }
                     }
                  }
               }
               if (L_i_4 == -2) {
                  I_d_51 = ((TakeProfit * _Point) + Ask);
                  I_i_4 = OrderSend(_Symbol, 0, L_d_8, Ask, I_i_106, 0, I_d_51, I_s_0, MagicNumber, 0, 16711680);
                  L_i_27 = I_i_4;
               }
               if (L_i_27 <= 0) {
                  G_i_107 = GetLastError();
                  L_i_2 = G_i_107;
                  Global_ReturnedString = ErrorDescription(G_i_107);
                  L_s_0 = Global_ReturnedString;
                  S_s_60 = (string)G_i_107;
                  S_s_60 = "BUYSTOP Send Error Code: " + S_s_60;
                  S_s_60 = S_s_60 + " Message: ";
                  S_s_60 = S_s_60 + Global_ReturnedString;
                  S_s_60 = S_s_60 + " LT: ";
                  S_s_60 = S_s_60 + DoubleToString(L_d_8, _Digits);
                  S_s_60 = S_s_60 + " OP: ";
                  S_s_60 = S_s_60 + DoubleToString(L_d_5, _Digits);
                  S_s_60 = S_s_60 + " SL: ";
                  S_s_60 = S_s_60 + DoubleToString(L_d_13, _Digits);
                  S_s_60 = S_s_60 + " TP: ";
                  S_s_60 = S_s_60 + DoubleToString(L_d_12, _Digits);
                  S_s_60 = S_s_60 + " Bid: ";
                  S_s_60 = S_s_60 + DoubleToString(Bid, _Digits);
                  S_s_60 = S_s_60 + " Ask: ";
                  S_s_60 = S_s_60 + DoubleToString(Ask, _Digits);
                  Print(S_s_60);
               }
            } else {
               if ((I_i_8 <= I_d_12)) {
                  I_d_47 = I_d_13;
               } else {
                  I_d_47 = I_d_9;
               }
               if ((StopLoss <= I_d_12)) {
                  I_d_48 = I_d_13;
               } else {
                  I_d_48 = I_d_10;
               }
               if ((TakeProfit <= I_d_12)) {
                  I_d_49 = I_d_13;
               } else {
                  I_d_49 = I_d_11;
               }
               L_d_5 = NormalizeDouble((Bid - I_d_47), _Digits);
               L_d_10 = NormalizeDouble((L_d_5 + I_d_48), _Digits);
               L_d_11 = NormalizeDouble((L_d_5 - I_d_49), _Digits);
               if (UseStopLoss != true) {
                  L_d_13 = 0;
               } else {
                  L_d_13 = L_d_10;
               }
               if (UseTakeProfit != true) {
                  L_d_12 = 0;
               } else {
                  L_d_12 = L_d_11;
               }
               if (L_i_4 == 1) {
                  G_b_9 = false;
                  if (limit_time != true) {
                     G_b_9 = true;
                  } else {
                     if ((from <= TimeHour(TimeLocal()) && TimeHour(TimeLocal()) <= to && from < to)
                           || (((to <= TimeHour(TimeLocal()) && TimeHour(TimeLocal()) > from) || (to > TimeHour(TimeLocal()) && TimeHour(TimeLocal()) <= from)) && from > to)) {
                        G_b_9 = true;
                     }
                  }
                  if (G_b_9) {
                     S_s_61 = "2019.03.23 00:00";
                     G_i_67 = StringToTime(S_s_61);
                     G_l_10 = TimeCurrent();
                     G_l_11 = G_i_67;
                     if (I_i_4 == 14) {
                        Alert(" License ended for Bender v2! Please join @sirforex at Telegram");
                        G_b_10 = true;
                     } else {
                        G_b_10 = false;
                     }
                     if (G_b_10 != true) {
                        I_i_4 = openCond;
                        if (I_i_4 == 1) {
                           G_l_11 = TimeCurrent();
                           G_l_12 = L_i_14;
                           L_i_27 = OrderSend(_Symbol, 5, L_d_9, L_d_5, I_i_106, L_d_13, L_d_12, I_s_0, MagicNumber, (G_l_11 + G_l_12), 255);
                        }
                        if (I_i_4 == 2) {
                           L_i_27 = OrderSend(_Symbol, 1, L_d_9, Bid, I_i_106, L_d_13, L_d_11, I_s_0, MagicNumber, 0, 255);
                        }
                     }
                  }
               }
               if (L_i_4 == 2) {
                  G_d_52 = (TakeProfit * _Point);
                  I_d_57 = (Bid - G_d_52);
                  L_i_27 = OrderSend(_Symbol, 1, L_d_9, Bid, I_i_106, 0, I_d_57, I_s_0, MagicNumber, 0, 16711680);
               }
               if (L_i_27 <= 0) {
                  G_i_108 = GetLastError();
                  L_i_2 = G_i_108;
                  Global_ReturnedString = ErrorDescription(G_i_108);
                  L_s_0 = Global_ReturnedString;
                  S_s_62 = (string)G_i_108;
                  S_s_62 = "SELLSTOP Send Error Code: " + S_s_62;
                  S_s_62 = S_s_62 + " Message: ";
                  S_s_62 = S_s_62 + Global_ReturnedString;
                  S_s_62 = S_s_62 + " LT: ";
                  S_s_62 = S_s_62 + DoubleToString(L_d_9, _Digits);
                  S_s_62 = S_s_62 + " OP: ";
                  S_s_62 = S_s_62 + DoubleToString(L_d_5, _Digits);
                  S_s_62 = S_s_62 + " SL: ";
                  S_s_62 = S_s_62 + DoubleToString(L_d_13, _Digits);
                  S_s_62 = S_s_62 + " TP: ";
                  S_s_62 = S_s_62 + DoubleToString(L_d_12, _Digits);
                  S_s_62 = S_s_62 + " Bid: ";
                  S_s_62 = S_s_62 + DoubleToString(Bid, _Digits);
                  S_s_62 = S_s_62 + " Ask: ";
                  S_s_62 = S_s_62 + DoubleToString(Ask, _Digits);
                  Print(S_s_62);
               }
            }
         }
      }
   }
   G_i_69 = 1;
   G_i_68 = MagicNumber;
   G_i_70 = OrdersTotal();
   G_i_71 = 0;
   G_i_72 = G_i_70;
   if (G_i_70 >= 0) {
      do {
         I_i_4 = G_i_69;
         if (I_i_4 == 1) {
            if (OrderSelect(G_i_72, 0, 0) && OrderMagicNumber() == G_i_68 && OrderType() == OP_BUY) {
               G_i_71 = G_i_71 + 1;
            }
         }
         if (I_i_4 == 2) {
            if (OrderSelect(G_i_72, 0, 0) && OrderMagicNumber() == G_i_68 && OrderType() == OP_SELL) {
               G_i_71 = G_i_71 + 1;
            }
         }
         G_i_72 = G_i_72 - 1;
      } while (G_i_72 >= 0);
   }
   L_i_15 = G_i_71;
   G_i_74 = 2;
   G_i_73 = MagicNumber;
   G_i_75 = OrdersTotal();
   G_i_76 = 0;
   G_i_77 = G_i_75;
   if (G_i_75 >= 0) {
      do {
         I_i_4 = G_i_74;
         if (I_i_4 == 1) {
            if (OrderSelect(G_i_77, 0, 0) && OrderMagicNumber() == G_i_73 && OrderType() == OP_BUY) {
               G_i_76 = G_i_76 + 1;
            }
         }
         if (I_i_4 == 2) {
            if (OrderSelect(G_i_77, 0, 0) && OrderMagicNumber() == G_i_73 && OrderType() == OP_SELL) {
               G_i_76 = G_i_76 + 1;
            }
         }
         G_i_77 = G_i_77 - 1;
      } while (G_i_77 >= 0);
   }
   L_i_16 = G_i_76;
   L_i_17 = L_i_15;
   L_i_18 = G_i_76;
   L_b_0 = false;
   L_b_1 = false;
   L_b_2 = false;
   L_i_19 = 0;
   G_i_108 = L_i_15 + G_i_76;
   if (G_i_108 > 0) {
      L_b_0 = true;
   }
   L_d_28 = 40;
   L_d_29 = 0;
   L_d_30 = 0;
   L_d_31 = 0;
   L_d_32 = 0;
   L_d_33 = 0;
   L_d_34 = 0;
   L_d_35 = 0;
   L_i_20 = 0;
   L_i_20 = OrdersTotal() - 1;
   if (L_i_20 >= 0) {
      do {
         L_i_19 = OrderSelect(L_i_20, 0, 0);
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               G_d_52 = OrderOpenPrice();
               L_d_29 = ((G_d_52 * OrderLots()) + L_d_29);
               L_d_34 = (L_d_34 + OrderLots());
            }
            if (OrderType() == OP_SELL) {
               G_d_52 = OrderOpenPrice();
               L_d_33 = ((G_d_52 * OrderLots()) + L_d_33);
               L_d_35 = (L_d_35 + OrderLots());
            }
         }
         L_i_20 = L_i_20 - 1;
      } while (L_i_20 >= 0);
   }
   if (L_i_17 > 0) {

if (L_d_34 != 0) {
    L_d_29 = NormalizeDouble((L_d_29 / L_d_34), _Digits);
} else {
    Print("Division by zero detected. L_d_34 is zero.");
    L_d_29 = 0; // Or handle appropriately
}
   }
   if (L_i_18 > 0) {

if (L_d_35 != 0) {
    L_d_33 = NormalizeDouble((L_d_33 / L_d_35), _Digits);
} else {
    Print("Division by zero detected. L_d_35 is zero.");
    L_d_33 = 0; // Or handle appropriately
}
   }
   if (L_b_0) {
      L_i_20 = OrdersTotal() - 1;
      if (L_i_20 >= 0) {
         do {
            L_i_19 = OrderSelect(L_i_20, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                  L_d_30 = ((TakeProfit * _Point) + L_d_29);
                  G_d_52 = (L_d_28 * _Point);
                  L_d_31 = (L_d_29 - G_d_52);
                  L_b_1 = true;
               }
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
                  G_d_52 = (TakeProfit * _Point);
                  L_d_32 = (L_d_33 - G_d_52);
                  L_d_31 = ((L_d_28 * _Point) + L_d_33);
                  L_b_2 = true;
               }
            }
            L_i_20 = L_i_20 - 1;
         } while (L_i_20 >= 0);
      }
   }
   if (L_b_0 == false) return;
   G_i_108 = L_b_1;
   if (G_i_108 == 1) {
      L_i_20 = OrdersTotal() - 1;
      if (L_i_20 >= 0) {
         do {
            L_i_19 = OrderSelect(L_i_20, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
                  L_d_29 = NormalizeDouble(L_d_29, _Digits);
                  L_d_30 = NormalizeDouble(L_d_30, _Digits);
                  if (OrderModify(OrderTicket(), L_d_29, OrderStopLoss(), L_d_30, 0, 4294967295) != true) {
                     G_i_109 = GetLastError();
                     if (G_i_109 != 1) {
                        L_i_21 = 0;
                        Print("error: ", 0);
                     }
                  }
               }
               L_b_0 = false;
            }
            L_i_20 = L_i_20 - 1;
         } while (L_i_20 >= 0);
      }
   }
   G_i_109 = L_b_2;
   if (G_i_109 != 1) return;
   L_i_20 = OrdersTotal() - 1;
   if (L_i_20 < 0) return;
   do {
      L_i_19 = OrderSelect(L_i_20, 0, 0);
      if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
            L_d_33 = NormalizeDouble(L_d_33, _Digits);
            L_d_32 = NormalizeDouble(L_d_32, _Digits);
            if (OrderModify(OrderTicket(), L_d_33, OrderStopLoss(), L_d_32, 0, 4294967295) != true) {
               G_i_110 = GetLastError();
               if (G_i_110 != 1) {
                  L_i_22 = 0;
                  Print("error: ", 0);
               }
            }
         }
         L_b_0 = false;
      }
      L_i_20 = L_i_20 - 1;
   } while (L_i_20 >= 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   string S_s_58;
   G_i_0 = 0;
   Comment("");
   ObjectsTotal(-1);
   G_i_7 = ObjectsTotal(-1) - 1;
   G_i_0 = G_i_7;
   if (G_i_7 >= 0) {
      do {
         if (I_b_3) {
            S_s_58 = ObjectName(G_i_0);
            if (StringFind(S_s_58, "v_u_hl", 0) > -1) {
               ObjectDelete(S_s_58);
            }
            if (StringFind(S_s_58, "v_l_hl", 0) > -1) {
               ObjectDelete(S_s_58);
            }
            if (StringFind(S_s_58, "Fibo_hl", 0) > -1) {
               ObjectDelete(S_s_58);
            }
            if (StringFind(S_s_58, "trend_hl", 0) > -1) {
               ObjectDelete(S_s_58);
            }
            WindowRedraw();
         } else {
            S_s_58 = ObjectName(G_i_0);
            if (StringFind(S_s_58, "v_u_lh", 0) > -1) {
               ObjectDelete(S_s_58);
            }
            if (StringFind(S_s_58, "v_l_lh", 0) > -1) {
               ObjectDelete(S_s_58);
            }
            if (StringFind(S_s_58, "Fibo_lh", 0) > -1) {
               ObjectDelete(S_s_58);
            }
            if (StringFind(S_s_58, "trend_lh", 0) > -1) {
               ObjectDelete(S_s_58);
            }
            WindowRedraw();
         }
         G_i_0 = G_i_0 - 1;
      } while (G_i_0 >= 0);
   }
   ObjectDelete("Background");
   ObjectDelete("Background_2");
   ObjectDelete("Background_3");
   ObjectDelete("Background_4");
   ObjectDelete("Background_5");
   ObjectDelete("Info_1");
   ObjectDelete("Info_2");
   ObjectDelete("Info_3");
   ObjectDelete("Info_4");
   ObjectDelete("Info_5");
   ObjectDelete("Info_6");
   ObjectDelete("Info_7");
   ObjectDelete("Info_8");
   ObjectDelete("Info_9");
   ObjectDelete("Info_10");
   ObjectDelete("Info_11");
   ObjectDelete("Info_12");
   ObjectDelete("Info_13");
   ObjectDelete("Info_14");
   ObjectDelete("Info_15");
   ObjectDelete("Info_16");
   ObjectDelete("Info_17");
   ObjectDelete("Info_18");
   ObjectDelete("Info_19");
   ObjectDelete("Info_20");
   ObjectDelete("Info_21");
   ObjectDelete("Info_22");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalcFibo() {
   string S_s_58;
   string S_s_59;
   string S_s_60;
   string S_s_61;
   int L_i_30;
   int L_i_28;
   double L_d_40;
   double L_d_37;
   int L_i_25;
   int L_i_26;
   double L_d_41;
   double L_d_39;
   int L_i_27;
   L_i_30 = 0;
   L_i_28 = 0;
   L_d_40 = 0;
   L_d_37 = 0;
   L_i_25 = 0;
   L_i_26 = 0;
   L_d_41 = 0;
   L_d_39 = 0;
   L_i_27 = 0;
   G_i_0 = 0;
   G_i_7 = 0;
   G_i_10 = 0;
   G_i_11 = 0;
   G_i_13 = 0;
   G_i_14 = 0;
   G_i_162 = 0;
   G_i_15 = 0;
   L_i_30 = 0;
   L_i_28 = 0;
   L_d_40 = 0;
   L_d_37 = 0;
   L_i_25 = iLowest(NULL, I_i_228[periodForFibo], 1, I_i_82, I_i_80);
   L_i_26 = iHighest(NULL, I_i_228[periodForFibo], 2, I_i_82, I_i_80);
   L_d_41 = 0;
   L_d_39 = 0;
   L_d_37 = iHigh(NULL, I_i_228[periodForFibo], L_i_26);
   L_d_40 = iLow(NULL, I_i_228[periodForFibo], L_i_25);
   if (I_b_3) {
      G_i_7 = I_i_145;
      G_i_0 = L_i_26;
      S_s_58 = "v_u_hl";
      if (ObjectFind(S_s_58) == -1) {
         ObjectCreate(0, S_s_58, OBJ_VLINE, 0, Time[L_i_26], 0, 0, 0, 0, 0);
         ObjectSet(S_s_58, OBJPROP_COLOR, G_i_7);
         ObjectSet(S_s_58, OBJPROP_STYLE, 1);
         ObjectSet(S_s_58, OBJPROP_WIDTH, 1);
         WindowRedraw();
      } else {
         ObjectDelete(S_s_58);
         ObjectCreate(0, S_s_58, OBJ_VLINE, 0, Time[G_i_0], 0, 0, 0, 0, 0);
         ObjectSet(S_s_58, OBJPROP_COLOR, G_i_7);
         ObjectSet(S_s_58, OBJPROP_STYLE, 1);
         ObjectSet(S_s_58, OBJPROP_WIDTH, 1);
         WindowRedraw();
      }
      G_i_11 = I_i_145;
      G_i_10 = L_i_25;
      S_s_59 = "v_l_hl";
      if (ObjectFind(S_s_59) == -1) {
         ObjectCreate(0, S_s_59, OBJ_VLINE, 0, Time[L_i_25], 0, 0, 0, 0, 0);
         ObjectSet(S_s_59, OBJPROP_COLOR, G_i_11);
         ObjectSet(S_s_59, OBJPROP_STYLE, 1);
         ObjectSet(S_s_59, OBJPROP_WIDTH, 1);
         WindowRedraw();
      } else {
         ObjectDelete(S_s_59);
         ObjectCreate(0, S_s_59, OBJ_VLINE, 0, Time[G_i_10], 0, 0, 0, 0, 0);
         ObjectSet(S_s_59, OBJPROP_COLOR, G_i_11);
         ObjectSet(S_s_59, OBJPROP_STYLE, 1);
         ObjectSet(S_s_59, OBJPROP_WIDTH, 1);
         WindowRedraw();
      }
      if (ObjectFind("trend_hl") == -1) {
         ObjectCreate(0, "trend_hl", OBJ_TREND, 0, Time[L_i_26], L_d_37, Time[L_i_25], L_d_40, 0, 0);
      }
      G_l_24 = Time[L_i_26];
      ObjectSet("trend_hl", OBJPROP_TIME1, G_l_24);
      G_l_25 = Time[L_i_25];
      ObjectSet("trend_hl", OBJPROP_TIME2, G_l_25);
      ObjectSet("trend_hl", OBJPROP_PRICE1, L_d_37);
      ObjectSet("trend_hl", OBJPROP_PRICE2, L_d_40);
      ObjectSet("trend_hl", OBJPROP_STYLE, 2);
      ObjectSet("trend_hl", OBJPROP_RAY, 0);
      if (ObjectFind("Fibo_hl") == -1) {
         ObjectCreate(0, "Fibo_hl", OBJ_FIBO, 0, 0, L_d_37, 0, L_d_40, 0, 0);
      }
      ObjectSet("Fibo_hl", OBJPROP_PRICE1, L_d_37);
      ObjectSet("Fibo_hl", OBJPROP_PRICE2, L_d_40);
      ObjectSet("Fibo_hl", OBJPROP_LEVELCOLOR, I_i_146);
      ObjectSet("Fibo_hl", OBJPROP_FIBOLEVELS, 8);
      ObjectSet("Fibo_hl", OBJPROP_FIRSTLEVEL, I_d_19);
      ObjectSetFiboDescription("Fibo_hl", 0, "SWING LOW (0.0) - %$");
      ObjectSet("Fibo_hl", 211, I_d_20);
      ObjectSetFiboDescription("Fibo_hl", 1, "BREAKOUT AREA (23.6) -  %$");
      ObjectSet("Fibo_hl", 212, I_d_21);
      ObjectSetFiboDescription("Fibo_hl", 2, "CRITICAL AREA (38.2) -  %$");
      ObjectSet("Fibo_hl", 213, I_d_22);
      ObjectSetFiboDescription("Fibo_hl", 3, "CRITICAL AREA (50.0) -  %$");
      ObjectSet("Fibo_hl", 214, I_d_23);
      ObjectSetFiboDescription("Fibo_hl", 4, "CRITICAL AREA (61.8) -  %$");
      ObjectSet("Fibo_hl", 215, I_d_24);
      ObjectSetFiboDescription("Fibo_hl", 5, "BREAKOUT AREA (76.4) -  %$");
      ObjectSet("Fibo_hl", 217, I_d_25);
      ObjectSetFiboDescription("Fibo_hl", 7, "SWING HIGH (100.0) - %$");
      ObjectSet("Fibo_hl", OBJPROP_RAY, 1);
      WindowRedraw();
      L_i_27 = 0;
      do {
         G_d_73 = NormalizeDouble((((L_d_37 - L_d_40) * I_d_25) + L_d_40), _Digits);
         I_d_102[L_i_27] = G_d_73;
         G_d_73 = NormalizeDouble((((L_d_37 - L_d_40) * I_d_24) + L_d_40), _Digits);
         I_d_101[L_i_27] = G_d_73;
         G_d_73 = NormalizeDouble((((L_d_37 - L_d_40) * I_d_23) + L_d_40), _Digits);
         I_d_100[L_i_27] = G_d_73;
         G_d_73 = NormalizeDouble((((L_d_37 - L_d_40) * I_d_22) + L_d_40), _Digits);
         I_d_99[L_i_27] = G_d_73;
         G_d_73 = NormalizeDouble((((L_d_37 - L_d_40) * I_d_21) + L_d_40), _Digits);
         I_d_98[L_i_27] = G_d_73;
         G_d_73 = NormalizeDouble((((L_d_37 - L_d_40) * I_d_20) + L_d_40), _Digits);
         I_d_97[L_i_27] = G_d_73;
         G_d_73 = NormalizeDouble((((L_d_37 - L_d_40) * I_d_19) + L_d_40), _Digits);
         I_d_96[L_i_27] = G_d_73;
         L_i_27 = L_i_27 + 1;
      } while (L_i_27 < 100);
      return ;
   }
   G_i_14 = I_i_145;
   G_i_13 = L_i_26;
   S_s_60 = "v_u_lh";
   if (ObjectFind(S_s_60) == -1) {
      ObjectCreate(0, S_s_60, OBJ_VLINE, 0, Time[L_i_26], 0, 0, 0, 0, 0);
      ObjectSet(S_s_60, OBJPROP_COLOR, G_i_14);
      ObjectSet(S_s_60, OBJPROP_STYLE, 1);
      ObjectSet(S_s_60, OBJPROP_WIDTH, 1);
      WindowRedraw();
   } else {
      ObjectDelete(S_s_60);
      ObjectCreate(0, S_s_60, OBJ_VLINE, 0, Time[G_i_13], 0, 0, 0, 0, 0);
      ObjectSet(S_s_60, OBJPROP_COLOR, G_i_14);
      ObjectSet(S_s_60, OBJPROP_STYLE, 1);
      ObjectSet(S_s_60, OBJPROP_WIDTH, 1);
      WindowRedraw();
   }
   G_i_15 = I_i_145;
   G_i_162 = L_i_25;
   S_s_61 = "v_l_lh";
   if (ObjectFind(S_s_61) == -1) {
      ObjectCreate(0, S_s_61, OBJ_VLINE, 0, Time[L_i_25], 0, 0, 0, 0, 0);
      ObjectSet(S_s_61, OBJPROP_COLOR, G_i_15);
      ObjectSet(S_s_61, OBJPROP_STYLE, 1);
      ObjectSet(S_s_61, OBJPROP_WIDTH, 1);
      WindowRedraw();
   } else {
      ObjectDelete(S_s_61);
      ObjectCreate(0, S_s_61, OBJ_VLINE, 0, Time[G_i_162], 0, 0, 0, 0, 0);
      ObjectSet(S_s_61, OBJPROP_COLOR, G_i_15);
      ObjectSet(S_s_61, OBJPROP_STYLE, 1);
      ObjectSet(S_s_61, OBJPROP_WIDTH, 1);
      WindowRedraw();
   }
   if (ObjectFind("trend_hl") == -1) {
      ObjectCreate(0, "trend_lh", OBJ_TREND, 0, Time[L_i_25], L_d_40, Time[L_i_26], L_d_37, 0, 0);
   }
   G_l_33 = Time[L_i_25];
   ObjectSet("trend_lh", OBJPROP_TIME1, G_l_33);
   G_l_34 = Time[L_i_26];
   ObjectSet("trend_lh", OBJPROP_TIME2, G_l_34);
   ObjectSet("trend_lh", OBJPROP_PRICE1, L_d_40);
   ObjectSet("trend_lh", OBJPROP_PRICE2, L_d_37);
   ObjectSet("trend_lh", OBJPROP_STYLE, 2);
   ObjectSet("trend_lh", OBJPROP_RAY, 0);
   if (ObjectFind("Fibo_lh") == -1) {
      ObjectCreate(0, "Fibo_lh", OBJ_FIBO, 0, 0, L_d_40, 0, L_d_37, 0, 0);
   }
   ObjectSet("Fibo_lh", OBJPROP_PRICE1, L_d_40);
   ObjectSet("Fibo_lh", OBJPROP_PRICE2, L_d_37);
   ObjectSet("Fibo_lh", OBJPROP_LEVELCOLOR, I_i_146);
   ObjectSet("Fibo_lh", OBJPROP_FIBOLEVELS, 8);
   ObjectSet("Fibo_lh", OBJPROP_FIRSTLEVEL, I_d_19);
   ObjectSetFiboDescription("Fibo_lh", 0, "SWING LOW (0.0) - %$");
   ObjectSet("Fibo_lh", 211, I_d_20);
   ObjectSetFiboDescription("Fibo_lh", 1, "BREAKOUT AREA (23.6) -  %$");
   ObjectSet("Fibo_lh", 212, I_d_21);
   ObjectSetFiboDescription("Fibo_lh", 2, "CRITICAL AREA (38.2) -  %$");
   ObjectSet("Fibo_lh", 213, I_d_22);
   ObjectSetFiboDescription("Fibo_lh", 3, "CRITICAL AREA (50.0) -  %$");
   ObjectSet("Fibo_lh", 214, I_d_23);
   ObjectSetFiboDescription("Fibo_lh", 4, "CRITICAL AREA (61.8) -  %$");
   ObjectSet("Fibo_lh", 215, I_d_24);
   ObjectSetFiboDescription("Fibo_lh", 5, "BREAKOUT AREA (76.4) -  %$");
   ObjectSet("Fibo_lh", 217, I_d_25);
   ObjectSetFiboDescription("Fibo_lh", 7, "SWING HIGH (100.0) - %$");
   ObjectSet("Fibo_lh", OBJPROP_RAY, 1);
   WindowRedraw();
   L_i_27 = 0;
   do {
      G_d_83 = NormalizeDouble(L_d_37, 4);
      I_d_96[L_i_27] = G_d_83;
      G_d_83 = ((L_d_37 - L_d_40) * I_d_20);
      G_d_83 = NormalizeDouble((L_d_37 - G_d_83), _Digits);
      I_d_97[L_i_27] = G_d_83;
      G_d_83 = ((L_d_37 - L_d_40) * I_d_21);
      G_d_83 = NormalizeDouble((L_d_37 - G_d_83), _Digits);
      I_d_98[L_i_27] = G_d_83;
      G_d_83 = ((L_d_37 - L_d_40) * I_d_22);
      G_d_83 = NormalizeDouble((L_d_37 - G_d_83), _Digits);
      I_d_99[L_i_27] = G_d_83;
      G_d_83 = ((L_d_37 - L_d_40) * I_d_23);
      G_d_83 = NormalizeDouble((L_d_37 - G_d_83), _Digits);
      I_d_100[L_i_27] = G_d_83;
      G_d_83 = ((L_d_37 - L_d_40) * I_d_24);
      G_d_83 = NormalizeDouble((L_d_37 - G_d_83), _Digits);
      I_d_101[L_i_27] = G_d_83;
      G_d_83 = NormalizeDouble(L_d_40, 4);
      I_d_102[L_i_27] = G_d_83;
      L_i_27 = L_i_27 + 1;
   } while (L_i_27 < 100);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool dailyProfitorStopLossReached() {
   bool L_b_3;
   bool L_b_4;
   int L_i_28;
   int L_i_29;
   L_b_3 = false;
   L_b_4 = false;
   L_i_28 = 0;
   L_i_29 = 0;
   G_i_0 = 0;
   G_i_7 = 0;
   G_i_10 = 0;
   G_i_11 = 0;
   G_i_13 = 0;
   G_i_14 = 0;
   G_i_162 = 0;
   G_i_15 = 0;
   L_b_4 = false;
   G_i_0 = MagicNumber;
   G_i_7 = HistoryTotal();
   G_i_10 = 0;
   G_i_11 = G_i_7;
   if (G_i_7 >= 0) {
      do {
         if (OrderSelect(G_i_11, 0, 1) && OrderMagicNumber() == G_i_0 && (OrderProfit() > 0)) {
            G_l_37 = OrderCloseTime();
            if (G_l_37 >= iTime(_Symbol, 1440, 0)) {
               G_l_37 = OrderCloseTime();
               G_l_38 = iTime(_Symbol, 1440, 0) + 86400;
               if (G_l_37 < G_l_38) {
                  G_i_10 = G_i_10 + 1;
               }
            }
         }
         G_i_11 = G_i_11 - 1;
      } while (G_i_11 >= 0);
   }
   L_i_28 = G_i_10;
   G_i_13 = MagicNumber;
   G_i_14 = HistoryTotal();
   G_i_162 = 0;
   G_i_15 = G_i_14;
   if (G_i_14 >= 0) {
      do {
         if (OrderSelect(G_i_15, 0, 1) && OrderMagicNumber() == G_i_13 && (OrderProfit() <= 0)) {
            G_l_38 = OrderCloseTime();
            if (G_l_38 >= iTime(_Symbol, 1440, 0)) {
               G_l_38 = OrderCloseTime();
               G_l_39 = iTime(_Symbol, 1440, 0) + 86400;
               if (G_l_38 < G_l_39) {
                  G_i_162 = G_i_162 + 1;
               }
            }
         }
         G_i_15 = G_i_15 - 1;
      } while (G_i_15 >= 0);
   }
   L_i_29 = G_i_162;
   if ((L_i_28 >= dailyProfit && dailyProfit != 0)
         || (L_i_29 >= dailyLoss && dailyLoss != 0)) {
      L_b_4 = true;
   }
   L_b_3 = L_b_4;
   return L_b_4;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void graf() {
   string S_s_58;
   string S_s_59;
   string S_s_60;
   string S_s_61;
   string S_s_62;
   string S_s_63;
   string S_s_64;
   string S_s_65;
   string S_s_66;
   string S_s_67;
   string S_s_68;
   string S_s_69;
   string S_s_70;
   string S_s_71;
   string S_s_72;
   string S_s_73;
   string S_s_74;
   string S_s_75;
   string S_s_76;
   string S_s_77;
   string S_s_78;
   string S_s_79;
   string S_s_80;
   string S_s_81;
   string S_s_82;
   string S_s_83;
   string S_s_84;
   string S_s_85;
   string S_s_86;
   string S_s_87;
   string S_s_88;
   string S_s_89;
   string S_s_90;
   string S_s_91;
   string S_s_92;
   string S_s_93;
   string S_s_94;
   string S_s_95;
   string S_s_96;
   string S_s_97;
   string S_s_98;
   string S_s_99;
   string S_s_100;
   string S_s_101;
   string S_s_102;
   string S_s_103;
   string S_s_104;
   string S_s_105;
   string S_s_106;
   string S_s_107;
   string S_s_108;
   string S_s_109;
   string S_s_110;
   string S_s_111;
   string S_s_112;
   string S_s_113;
   string S_s_114;
   string S_s_115;
   string S_s_116;
   string S_s_117;
   string S_s_118;
   string S_s_119;
   string S_s_120;
   string S_s_121;
   string S_s_122;
   string S_s_123;
   string S_s_124;
   string S_s_125;
   string S_s_126;
   string S_s_127;
   string S_s_128;
   string S_s_129;
   string S_s_130;
   int L_i_30;
   double L_d_40;
   string L_s_1;
   double L_d_41;
   string L_s_2;
   int L_i_31;
   L_i_30 = 0;
   L_d_40 = 0;
   L_d_41 = 0;
   L_i_31 = 0;
   G_d_27 = 0;
   G_i_7 = 0;
   G_i_10 = 0;
   G_d_16 = 0;
   G_i_13 = 0;
   G_i_14 = 0;
   G_d_91 = 0;
   G_i_15 = 0;
   G_i_16 = 0;
   G_d_92 = 0;
   G_i_18 = 0;
   G_i_19 = 0;
   G_i_20 = 0;
   G_i_21 = 0;
   G_i_22 = 0;
   G_i_23 = 0;
   G_i_24 = 0;
   G_i_25 = 0;
   G_i_26 = 0;
   G_i_27 = 0;
   G_i_28 = 0;
   G_i_29 = 0;
   G_i_30 = 0;
   G_i_31 = 0;
   G_i_32 = 0;
   G_i_33 = 0;
   G_i_163 = 0;
   G_i_34 = 0;
   G_i_35 = 0;
   G_i_36 = 0;
   G_i_37 = 0;
   G_i_38 = 0;
   G_i_39 = 0;
   G_i_40 = 0;
   G_i_41 = 0;
   G_i_42 = 0;
   G_i_43 = 0;
   G_i_44 = 0;
   G_i_45 = 0;
   G_i_46 = 0;
   G_i_47 = 0;
   G_i_48 = 0;
   G_i_49 = 0;
   G_i_50 = 0;
   G_i_51 = 0;
   G_i_52 = 0;
   G_i_53 = 0;
   G_i_54 = 0;
   G_i_164 = 0;
   G_i_55 = 0;
   G_i_56 = 0;
   G_i_57 = 0;
   G_i_58 = 0;
   G_i_59 = 0;
   G_i_60 = 0;
   G_i_61 = 0;
   G_i_62 = 0;
   G_i_63 = 0;
   G_i_64 = 0;
   G_i_165 = 0;
   G_i_65 = 0;
   G_i_166 = 0;
   G_i_167 = 0;
   G_i_66 = 0;
   G_i_168 = 0;
   G_i_169 = 0;
   G_i_67 = 0;
   G_i_68 = 0;
   G_i_69 = 0;
   G_i_70 = 0;
   G_i_71 = 0;
   G_i_72 = 0;
   G_i_73 = 0;
   G_d_93 = 0;
   G_i_75 = 0;
   G_i_76 = 0;
   G_i_77 = 0;
   G_i_79 = 0;
   G_i_81 = 0;
   G_i_83 = 0;
   G_i_84 = 0;
   G_d_94 = 0;
   G_i_86 = 0;
   G_i_87 = 0;
   G_i_88 = 0;
   G_i_89 = 0;
   G_i_90 = 0;
   G_i_91 = 0;
   G_i_92 = 0;
   G_d_41 = 0;
   G_i_95 = 0;
   G_i_96 = 0;
   G_i_170 = 0;
   G_i_97 = 0;
   G_i_100 = 0;
   G_i_103 = 0;
   G_i_104 = 0;
   G_d_46 = 0;
   G_i_171 = 0;
   G_i_172 = 0;
   G_i_107 = 0;
   G_i_173 = 0;
   G_i_108 = 0;
   G_i_174 = 0;
   G_d_54 = 0;
   G_i_175 = 0;
   G_i_110 = 0;
   G_i_176 = 0;
   G_i_177 = 0;
   G_i_178 = 0;
   G_i_179 = 0;
   G_i_180 = 0;
   G_i_181 = 0;
   G_i_182 = 0;
   G_i_183 = 0;
   G_i_184 = 0;
   G_i_185 = 0;
   G_i_186 = 0;
   G_i_187 = 0;
   G_i_188 = 0;
   G_i_189 = 0;
   G_i_190 = 0;
   G_i_191 = 0;
   G_i_192 = 0;
   G_i_193 = 0;
   G_i_194 = 0;
   G_i_195 = 0;
   G_i_196 = 0;
   G_i_197 = 0;
   G_i_198 = 0;
   G_i_199 = 0;
   G_i_200 = 0;
   G_i_201 = 0;
   G_i_202 = 0;
   G_i_203 = 0;
   G_i_204 = 0;
   G_i_205 = 0;
   G_i_206 = 0;
   G_i_207 = 0;
   G_i_208 = 0;
   G_i_209 = 0;
   G_i_210 = 0;
   G_i_211 = 0;
   G_i_212 = 0;
   G_i_213 = 0;
   G_i_214 = 0;
   L_i_30 = 16777215;
   L_d_40 = 0;
   G_d_27 = 0;
   G_i_7 = OrdersTotal();
   if (G_i_7 > 0) {
      G_i_215 = G_i_7 - 1;
      G_i_10 = G_i_215;
      if (G_i_215 >= 0) {
         do {
            if (OrderSelect(G_i_10, 0, 0) && OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol) {
               G_d_95 = OrderProfit();
               G_d_95 = (G_d_95 + OrderSwap());
               G_d_27 = ((G_d_95 + OrderCommission()) + G_d_27);
            }
            G_i_10 = G_i_10 - 1;
         } while (G_i_10 >= 0);
      }
   }
   if ((G_d_27 < 0)) {
      G_d_16 = 0;
      G_i_13 = OrdersTotal();
      if (G_i_13 > 0) {
         G_i_215 = G_i_13 - 1;
         G_i_14 = G_i_215;
         if (G_i_215 >= 0) {
            do {
               if (OrderSelect(G_i_14, 0, 0) && OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol) {
                  G_d_95 = OrderProfit();
                  G_d_95 = (G_d_95 + OrderSwap());
                  G_d_16 = ((G_d_95 + OrderCommission()) + G_d_16);
               }
               G_i_14 = G_i_14 - 1;
            } while (G_i_14 >= 0);
         }
      }
      G_d_95 = -G_d_16;
      G_d_95 = (G_d_95 * 100);
      L_d_40 = (G_d_95 / AccountBalance());
   }
   L_s_1 = DoubleToString(L_d_40, 2);
   L_d_41 = 0;
   G_d_91 = 0;
   G_i_15 = OrdersTotal();
   if (G_i_15 > 0) {
      G_i_215 = G_i_15 - 1;
      G_i_16 = G_i_215;
      if (G_i_215 >= 0) {
         do {
            if (OrderSelect(G_i_16, 0, 0) && OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol) {
               G_d_95 = OrderProfit();
               G_d_95 = (G_d_95 + OrderSwap());
               G_d_91 = ((G_d_95 + OrderCommission()) + G_d_91);
            }
            G_i_16 = G_i_16 - 1;
         } while (G_i_16 >= 0);
      }
   }
   if ((G_d_91 > 0)) {
      G_d_92 = 0;
      G_i_18 = OrdersTotal();
      if (G_i_18 > 0) {
         G_i_215 = G_i_18 - 1;
         G_i_19 = G_i_215;
         if (G_i_215 >= 0) {
            do {
               if (OrderSelect(G_i_19, 0, 0) && OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol) {
                  G_d_95 = OrderProfit();
                  G_d_95 = (G_d_95 + OrderSwap());
                  G_d_92 = ((G_d_95 + OrderCommission()) + G_d_92);
               }
               G_i_19 = G_i_19 - 1;
            } while (G_i_19 >= 0);
         }
      }
      G_d_95 = (G_d_92 * 100);
      L_d_41 = (G_d_95 / AccountBalance());
   }
   L_s_2 = DoubleToString(L_d_41, 2);
   S_s_58 = OrderSymbol();
   L_i_31 = MarketInfo(S_s_58, MODE_SPREAD);
   S_s_59 = "Tahoma";
   G_i_24 = 9;
   G_i_23 = 0;
   G_i_22 = 26;
   G_i_21 = 5;
   G_i_20 = L_i_30;
   S_s_60 = "   Trading information";
   S_s_61 = "Label0";
   if (ObjectFind(S_s_61) < 0) {
      ObjectCreate(0, S_s_61, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_61, S_s_60, G_i_24, S_s_59, G_i_20);
   ObjectSet(S_s_61, OBJPROP_COLOR, G_i_20);
   ObjectSet(S_s_61, OBJPROP_XDISTANCE, G_i_21);
   ObjectSet(S_s_61, OBJPROP_YDISTANCE, G_i_22);
   ObjectSet(S_s_61, OBJPROP_CORNER, G_i_23);
   ObjectSet(S_s_61, OBJPROP_FONTSIZE, G_i_24);
   ObjectSet(S_s_61, OBJPROP_BACK, 0);
   ObjectSet(S_s_61, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_61, OBJPROP_READONLY, 0);
   S_s_62 = "Tahoma";
   G_i_29 = 9;
   G_i_28 = 0;
   G_i_27 = 32;
   G_i_26 = 5;
   G_i_25 = L_i_30;
   S_s_63 = "   ……………………………………………………";
   S_s_64 = "Label1";
   if (ObjectFind(S_s_64) < 0) {
      ObjectCreate(0, S_s_64, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_64, S_s_63, G_i_29, S_s_62, G_i_25);
   ObjectSet(S_s_64, OBJPROP_COLOR, G_i_25);
   ObjectSet(S_s_64, OBJPROP_XDISTANCE, G_i_26);
   ObjectSet(S_s_64, OBJPROP_YDISTANCE, G_i_27);
   ObjectSet(S_s_64, OBJPROP_CORNER, G_i_28);
   ObjectSet(S_s_64, OBJPROP_FONTSIZE, G_i_29);
   ObjectSet(S_s_64, OBJPROP_BACK, 0);
   ObjectSet(S_s_64, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_64, OBJPROP_READONLY, 0);
   S_s_65 = "Tahoma";
   G_i_163 = 9;
   G_i_33 = 0;
   G_i_32 = 130;
   G_i_31 = 5;
   G_i_30 = L_i_30;
   S_s_66 = "   ……………………………………………………";
   S_s_67 = "Label2";
   if (ObjectFind(S_s_67) < 0) {
      ObjectCreate(0, S_s_67, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_67, S_s_66, G_i_163, S_s_65, G_i_30);
   ObjectSet(S_s_67, OBJPROP_COLOR, G_i_30);
   ObjectSet(S_s_67, OBJPROP_XDISTANCE, G_i_31);
   ObjectSet(S_s_67, OBJPROP_YDISTANCE, G_i_32);
   ObjectSet(S_s_67, OBJPROP_CORNER, G_i_33);
   ObjectSet(S_s_67, OBJPROP_FONTSIZE, G_i_163);
   ObjectSet(S_s_67, OBJPROP_BACK, 0);
   ObjectSet(S_s_67, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_67, OBJPROP_READONLY, 0);
   S_s_68 = "Tahoma";
   G_i_38 = 9;
   G_i_37 = 0;
   G_i_36 = 46;
   G_i_35 = 5;
   G_i_34 = L_i_30;
   S_s_69 = "   Drawdown: ";
   S_s_70 = "Label3";
   if (ObjectFind(S_s_70) < 0) {
      ObjectCreate(0, S_s_70, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_70, S_s_69, G_i_38, S_s_68, G_i_34);
   ObjectSet(S_s_70, OBJPROP_COLOR, G_i_34);
   ObjectSet(S_s_70, OBJPROP_XDISTANCE, G_i_35);
   ObjectSet(S_s_70, OBJPROP_YDISTANCE, G_i_36);
   ObjectSet(S_s_70, OBJPROP_CORNER, G_i_37);
   ObjectSet(S_s_70, OBJPROP_FONTSIZE, G_i_38);
   ObjectSet(S_s_70, OBJPROP_BACK, 0);
   ObjectSet(S_s_70, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_70, OBJPROP_READONLY, 0);
   S_s_71 = "Tahoma";
   G_i_43 = 9;
   G_i_42 = 0;
   G_i_41 = 59;
   G_i_40 = 5;
   G_i_39 = L_i_30;
   S_s_72 = "   Profit: ";
   S_s_73 = "Label4";
   if (ObjectFind(S_s_73) < 0) {
      ObjectCreate(0, S_s_73, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_73, S_s_72, G_i_43, S_s_71, G_i_39);
   ObjectSet(S_s_73, OBJPROP_COLOR, G_i_39);
   ObjectSet(S_s_73, OBJPROP_XDISTANCE, G_i_40);
   ObjectSet(S_s_73, OBJPROP_YDISTANCE, G_i_41);
   ObjectSet(S_s_73, OBJPROP_CORNER, G_i_42);
   ObjectSet(S_s_73, OBJPROP_FONTSIZE, G_i_43);
   ObjectSet(S_s_73, OBJPROP_BACK, 0);
   ObjectSet(S_s_73, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_73, OBJPROP_READONLY, 0);
   S_s_74 = "Tahoma";
   G_i_48 = 9;
   G_i_47 = 0;
   G_i_46 = 72;
   G_i_45 = 5;
   G_i_44 = L_i_30;
   S_s_75 = "   Today: ";
   S_s_76 = "Label5";
   if (ObjectFind(S_s_76) < 0) {
      ObjectCreate(0, S_s_76, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_76, S_s_75, G_i_48, S_s_74, G_i_44);
   ObjectSet(S_s_76, OBJPROP_COLOR, G_i_44);
   ObjectSet(S_s_76, OBJPROP_XDISTANCE, G_i_45);
   ObjectSet(S_s_76, OBJPROP_YDISTANCE, G_i_46);
   ObjectSet(S_s_76, OBJPROP_CORNER, G_i_47);
   ObjectSet(S_s_76, OBJPROP_FONTSIZE, G_i_48);
   ObjectSet(S_s_76, OBJPROP_BACK, 0);
   ObjectSet(S_s_76, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_76, OBJPROP_READONLY, 0);
   S_s_77 = "Tahoma";
   G_i_53 = 9;
   G_i_52 = 0;
   G_i_51 = 85;
   G_i_50 = 5;
   G_i_49 = L_i_30;
   S_s_78 = "   Yesterday: ";
   S_s_79 = "Label6";
   if (ObjectFind(S_s_79) < 0) {
      ObjectCreate(0, S_s_79, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_79, S_s_78, G_i_53, S_s_77, G_i_49);
   ObjectSet(S_s_79, OBJPROP_COLOR, G_i_49);
   ObjectSet(S_s_79, OBJPROP_XDISTANCE, G_i_50);
   ObjectSet(S_s_79, OBJPROP_YDISTANCE, G_i_51);
   ObjectSet(S_s_79, OBJPROP_CORNER, G_i_52);
   ObjectSet(S_s_79, OBJPROP_FONTSIZE, G_i_53);
   ObjectSet(S_s_79, OBJPROP_BACK, 0);
   ObjectSet(S_s_79, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_79, OBJPROP_READONLY, 0);
   S_s_80 = "Tahoma";
   G_i_57 = 9;
   G_i_56 = 0;
   G_i_55 = 98;
   G_i_164 = 5;
   G_i_54 = L_i_30;
   S_s_81 = "   Current month: ";
   S_s_82 = "Label7";
   if (ObjectFind(S_s_82) < 0) {
      ObjectCreate(0, S_s_82, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_82, S_s_81, G_i_57, S_s_80, G_i_54);
   ObjectSet(S_s_82, OBJPROP_COLOR, G_i_54);
   ObjectSet(S_s_82, OBJPROP_XDISTANCE, G_i_164);
   ObjectSet(S_s_82, OBJPROP_YDISTANCE, G_i_55);
   ObjectSet(S_s_82, OBJPROP_CORNER, G_i_56);
   ObjectSet(S_s_82, OBJPROP_FONTSIZE, G_i_57);
   ObjectSet(S_s_82, OBJPROP_BACK, 0);
   ObjectSet(S_s_82, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_82, OBJPROP_READONLY, 0);
   S_s_83 = "Tahoma";
   G_i_62 = 9;
   G_i_61 = 0;
   G_i_60 = 111;
   G_i_59 = 5;
   G_i_58 = L_i_30;
   S_s_84 = "   Previous month: ";
   S_s_85 = "Label8";
   if (ObjectFind(S_s_85) < 0) {
      ObjectCreate(0, S_s_85, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_85, S_s_84, G_i_62, S_s_83, G_i_58);
   ObjectSet(S_s_85, OBJPROP_COLOR, G_i_58);
   ObjectSet(S_s_85, OBJPROP_XDISTANCE, G_i_59);
   ObjectSet(S_s_85, OBJPROP_YDISTANCE, G_i_60);
   ObjectSet(S_s_85, OBJPROP_CORNER, G_i_61);
   ObjectSet(S_s_85, OBJPROP_FONTSIZE, G_i_62);
   ObjectSet(S_s_85, OBJPROP_BACK, 0);
   ObjectSet(S_s_85, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_85, OBJPROP_READONLY, 0);
   S_s_86 = "Tahoma";
   G_i_166 = 9;
   G_i_65 = 0;
   G_i_165 = 124;
   G_i_64 = 5;
   G_i_63 = L_i_30;
   S_s_87 = "   Total profit: ";
   S_s_88 = "Label9";
   if (ObjectFind(S_s_88) < 0) {
      ObjectCreate(0, S_s_88, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_88, S_s_87, G_i_166, S_s_86, G_i_63);
   ObjectSet(S_s_88, OBJPROP_COLOR, G_i_63);
   ObjectSet(S_s_88, OBJPROP_XDISTANCE, G_i_64);
   ObjectSet(S_s_88, OBJPROP_YDISTANCE, G_i_165);
   ObjectSet(S_s_88, OBJPROP_CORNER, G_i_65);
   ObjectSet(S_s_88, OBJPROP_FONTSIZE, G_i_166);
   ObjectSet(S_s_88, OBJPROP_BACK, 0);
   ObjectSet(S_s_88, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_88, OBJPROP_READONLY, 0);
   S_s_89 = "Tahoma";
   G_i_67 = 9;
   G_i_169 = 0;
   G_i_168 = 46;
   G_i_66 = 115;
   G_i_167 = L_i_30;
   S_s_90 = L_s_1;
   S_s_91 = "Label11";
   if (ObjectFind(S_s_91) < 0) {
      ObjectCreate(0, S_s_91, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_91, S_s_90, G_i_67, S_s_89, G_i_167);
   ObjectSet(S_s_91, OBJPROP_COLOR, G_i_167);
   ObjectSet(S_s_91, OBJPROP_XDISTANCE, G_i_66);
   ObjectSet(S_s_91, OBJPROP_YDISTANCE, G_i_168);
   ObjectSet(S_s_91, OBJPROP_CORNER, G_i_169);
   ObjectSet(S_s_91, OBJPROP_FONTSIZE, G_i_67);
   ObjectSet(S_s_91, OBJPROP_BACK, 0);
   ObjectSet(S_s_91, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_91, OBJPROP_READONLY, 0);
   S_s_92 = "Tahoma";
   G_i_72 = 9;
   G_i_71 = 0;
   G_i_70 = 59;
   G_i_69 = 115;
   G_i_68 = L_i_30;
   S_s_93 = L_s_2;
   S_s_94 = "Label12";
   if (ObjectFind(S_s_94) < 0) {
      ObjectCreate(0, S_s_94, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_94, S_s_93, G_i_72, S_s_92, G_i_68);
   ObjectSet(S_s_94, OBJPROP_COLOR, G_i_68);
   ObjectSet(S_s_94, OBJPROP_XDISTANCE, G_i_69);
   ObjectSet(S_s_94, OBJPROP_YDISTANCE, G_i_70);
   ObjectSet(S_s_94, OBJPROP_CORNER, G_i_71);
   ObjectSet(S_s_94, OBJPROP_FONTSIZE, G_i_72);
   ObjectSet(S_s_94, OBJPROP_BACK, 0);
   ObjectSet(S_s_94, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_94, OBJPROP_READONLY, 0);
   S_s_95 = "Tahoma";
   G_i_83 = 9;
   G_i_81 = 0;
   G_i_79 = 72;
   G_i_77 = 115;
   G_i_76 = L_i_30;
   G_i_73 = 0;
   G_d_93 = 0;
   G_i_75 = 0;
   if (HistoryTotal() > 0) {
      do {
         if (OrderSelect(G_i_75, 0, 1)) break;
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
            G_l_40 = OrderCloseTime();
            if (G_l_40 >= iTime(_Symbol, 1440, G_i_73)) {
               G_l_40 = OrderCloseTime();
               G_l_41 = iTime(_Symbol, 1440, G_i_73) + 86400;
               if (G_l_40 < G_l_41) {
                  G_d_93 = (G_d_93 + OrderProfit());
               }
            }
         }
         G_i_75 = G_i_75 + 1;
      } while (G_i_75 < HistoryTotal());
   }
   S_s_96 = DoubleToString(G_d_93, 2);
   S_s_97 = "Label13";
   if (ObjectFind(S_s_97) < 0) {
      ObjectCreate(0, S_s_97, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_97, S_s_96, G_i_83, S_s_95, G_i_76);
   ObjectSet(S_s_97, OBJPROP_COLOR, G_i_76);
   ObjectSet(S_s_97, OBJPROP_XDISTANCE, G_i_77);
   ObjectSet(S_s_97, OBJPROP_YDISTANCE, G_i_79);
   ObjectSet(S_s_97, OBJPROP_CORNER, G_i_81);
   ObjectSet(S_s_97, OBJPROP_FONTSIZE, G_i_83);
   ObjectSet(S_s_97, OBJPROP_BACK, 0);
   ObjectSet(S_s_97, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_97, OBJPROP_READONLY, 0);
   S_s_98 = "Tahoma";
   G_i_91 = 9;
   G_i_90 = 0;
   G_i_89 = 85;
   G_i_88 = 115;
   G_i_87 = L_i_30;
   G_i_84 = 1;
   G_d_94 = 0;
   G_i_86 = 0;
   if (HistoryTotal() > 0) {
      do {
         if (OrderSelect(G_i_86, 0, 1)) break;
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
            G_l_41 = OrderCloseTime();
            if (G_l_41 >= iTime(_Symbol, 1440, G_i_84)) {
               G_l_41 = OrderCloseTime();
               G_l_42 = iTime(_Symbol, 1440, G_i_84) + 86400;
               if (G_l_41 < G_l_42) {
                  G_d_94 = (G_d_94 + OrderProfit());
               }
            }
         }
         G_i_86 = G_i_86 + 1;
      } while (G_i_86 < HistoryTotal());
   }
   S_s_99 = DoubleToString(G_d_94, 2);
   S_s_100 = "Label14";
   if (ObjectFind(S_s_100) < 0) {
      ObjectCreate(0, S_s_100, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_100, S_s_99, G_i_91, S_s_98, G_i_87);
   ObjectSet(S_s_100, OBJPROP_COLOR, G_i_87);
   ObjectSet(S_s_100, OBJPROP_XDISTANCE, G_i_88);
   ObjectSet(S_s_100, OBJPROP_YDISTANCE, G_i_89);
   ObjectSet(S_s_100, OBJPROP_CORNER, G_i_90);
   ObjectSet(S_s_100, OBJPROP_FONTSIZE, G_i_91);
   ObjectSet(S_s_100, OBJPROP_BACK, 0);
   ObjectSet(S_s_100, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_100, OBJPROP_READONLY, 0);
   S_s_101 = "Tahoma";
   G_i_103 = 9;
   G_i_100 = 0;
   G_i_97 = 98;
   G_i_170 = 115;
   G_i_96 = L_i_30;
   G_i_92 = 0;
   G_d_41 = 0;
   G_i_95 = 0;
   if (HistoryTotal() > 0) {
      do {
         if (OrderSelect(G_i_95, 0, 1)) break;
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
            G_l_42 = OrderCloseTime();
            if (G_l_42 >= iTime(_Symbol, 43200, G_i_92)) {
               G_l_42 = OrderCloseTime();
               G_l_43 = iTime(_Symbol, 43200, G_i_92) + 2592000;
               if (G_l_42 < G_l_43) {
                  G_d_41 = (G_d_41 + OrderProfit());
               }
            }
         }
         G_i_95 = G_i_95 + 1;
      } while (G_i_95 < HistoryTotal());
   }
   S_s_102 = DoubleToString(G_d_41, 2);
   S_s_103 = "Label15";
   if (ObjectFind(S_s_103) < 0) {
      ObjectCreate(0, S_s_103, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_103, S_s_102, G_i_103, S_s_101, G_i_96);
   ObjectSet(S_s_103, OBJPROP_COLOR, G_i_96);
   ObjectSet(S_s_103, OBJPROP_XDISTANCE, G_i_170);
   ObjectSet(S_s_103, OBJPROP_YDISTANCE, G_i_97);
   ObjectSet(S_s_103, OBJPROP_CORNER, G_i_100);
   ObjectSet(S_s_103, OBJPROP_FONTSIZE, G_i_103);
   ObjectSet(S_s_103, OBJPROP_BACK, 0);
   ObjectSet(S_s_103, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_103, OBJPROP_READONLY, 0);
   S_s_104 = "Tahoma";
   G_i_174 = 9;
   G_i_108 = 0;
   G_i_173 = 111;
   G_i_107 = 115;
   G_i_172 = L_i_30;
   G_i_104 = 1;
   G_d_46 = 0;
   G_i_171 = 0;
   if (HistoryTotal() > 0) {
      do {
         if (OrderSelect(G_i_171, 0, 1)) break;
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
            G_l_43 = OrderCloseTime();
            if (G_l_43 >= iTime(_Symbol, 43200, G_i_104)) {
               G_l_43 = OrderCloseTime();
               G_l_44 = iTime(_Symbol, 43200, G_i_104) + 2592000;
               if (G_l_43 < G_l_44) {
                  G_d_46 = (G_d_46 + OrderProfit());
               }
            }
         }
         G_i_171 = G_i_171 + 1;
      } while (G_i_171 < HistoryTotal());
   }
   S_s_105 = DoubleToString(G_d_46, 2);
   S_s_106 = "Label16";
   if (ObjectFind(S_s_106) < 0) {
      ObjectCreate(0, S_s_106, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_106, S_s_105, G_i_174, S_s_104, G_i_172);
   ObjectSet(S_s_106, OBJPROP_COLOR, G_i_172);
   ObjectSet(S_s_106, OBJPROP_XDISTANCE, G_i_107);
   ObjectSet(S_s_106, OBJPROP_YDISTANCE, G_i_173);
   ObjectSet(S_s_106, OBJPROP_CORNER, G_i_108);
   ObjectSet(S_s_106, OBJPROP_FONTSIZE, G_i_174);
   ObjectSet(S_s_106, OBJPROP_BACK, 0);
   ObjectSet(S_s_106, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_106, OBJPROP_READONLY, 0);
   S_s_107 = "Tahoma";
   G_i_179 = 9;
   G_i_178 = 0;
   G_i_177 = 124;
   G_i_176 = 115;
   G_i_110 = L_i_30;
   G_d_54 = 0;
   G_i_175 = 0;
   if (HistoryTotal() > 0) {
      do {
         if (!OrderSelect(G_i_175, 0, 1)) break;
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) {
            G_l_44 = OrderCloseTime();
            if (G_l_44 >= iTime(_Symbol, 43200, 1200)) {
               G_d_54 = (G_d_54 + OrderProfit());
            }
         }
         G_i_175 = G_i_175 + 1;
      } while (G_i_175 < HistoryTotal());
   }
   S_s_108 = DoubleToString(G_d_54, 2);
   S_s_109 = "Label17";
   if (ObjectFind(S_s_109) < 0) {
      ObjectCreate(0, S_s_109, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_109, S_s_108, G_i_179, S_s_107, G_i_110);
   ObjectSet(S_s_109, OBJPROP_COLOR, G_i_110);
   ObjectSet(S_s_109, OBJPROP_XDISTANCE, G_i_176);
   ObjectSet(S_s_109, OBJPROP_YDISTANCE, G_i_177);
   ObjectSet(S_s_109, OBJPROP_CORNER, G_i_178);
   ObjectSet(S_s_109, OBJPROP_FONTSIZE, G_i_179);
   ObjectSet(S_s_109, OBJPROP_BACK, 0);
   ObjectSet(S_s_109, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_109, OBJPROP_READONLY, 0);
   S_s_110 = "Tahoma";
   G_i_184 = 9;
   G_i_183 = 0;
   G_i_182 = 46;
   G_i_181 = 195;
   G_i_180 = L_i_30;
   S_s_111 = "%";
   S_s_112 = "Label19";
   if (ObjectFind(S_s_112) < 0) {
      ObjectCreate(0, S_s_112, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_112, S_s_111, G_i_184, S_s_110, G_i_180);
   ObjectSet(S_s_112, OBJPROP_COLOR, G_i_180);
   ObjectSet(S_s_112, OBJPROP_XDISTANCE, G_i_181);
   ObjectSet(S_s_112, OBJPROP_YDISTANCE, G_i_182);
   ObjectSet(S_s_112, OBJPROP_CORNER, G_i_183);
   ObjectSet(S_s_112, OBJPROP_FONTSIZE, G_i_184);
   ObjectSet(S_s_112, OBJPROP_BACK, 0);
   ObjectSet(S_s_112, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_112, OBJPROP_READONLY, 0);
   S_s_113 = "Tahoma";
   G_i_189 = 9;
   G_i_188 = 0;
   G_i_187 = 59;
   G_i_186 = 195;
   G_i_185 = L_i_30;
   S_s_114 = "%";
   S_s_115 = "Label20";
   if (ObjectFind(S_s_115) < 0) {
      ObjectCreate(0, S_s_115, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_115, S_s_114, G_i_189, S_s_113, G_i_185);
   ObjectSet(S_s_115, OBJPROP_COLOR, G_i_185);
   ObjectSet(S_s_115, OBJPROP_XDISTANCE, G_i_186);
   ObjectSet(S_s_115, OBJPROP_YDISTANCE, G_i_187);
   ObjectSet(S_s_115, OBJPROP_CORNER, G_i_188);
   ObjectSet(S_s_115, OBJPROP_FONTSIZE, G_i_189);
   ObjectSet(S_s_115, OBJPROP_BACK, 0);
   ObjectSet(S_s_115, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_115, OBJPROP_READONLY, 0);
   S_s_116 = "Tahoma";
   G_i_194 = 9;
   G_i_193 = 0;
   G_i_192 = 72;
   G_i_191 = 195;
   G_i_190 = L_i_30;
   S_s_117 = AccountCurrency();
   S_s_118 = "Label21";
   if (ObjectFind(S_s_118) < 0) {
      ObjectCreate(0, S_s_118, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_118, S_s_117, G_i_194, S_s_116, G_i_190);
   ObjectSet(S_s_118, OBJPROP_COLOR, G_i_190);
   ObjectSet(S_s_118, OBJPROP_XDISTANCE, G_i_191);
   ObjectSet(S_s_118, OBJPROP_YDISTANCE, G_i_192);
   ObjectSet(S_s_118, OBJPROP_CORNER, G_i_193);
   ObjectSet(S_s_118, OBJPROP_FONTSIZE, G_i_194);
   ObjectSet(S_s_118, OBJPROP_BACK, 0);
   ObjectSet(S_s_118, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_118, OBJPROP_READONLY, 0);
   S_s_119 = "Tahoma";
   G_i_199 = 9;
   G_i_198 = 0;
   G_i_197 = 85;
   G_i_196 = 195;
   G_i_195 = L_i_30;
   S_s_120 = AccountCurrency();
   S_s_121 = "Label22";
   if (ObjectFind(S_s_121) < 0) {
      ObjectCreate(0, S_s_121, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_121, S_s_120, G_i_199, S_s_119, G_i_195);
   ObjectSet(S_s_121, OBJPROP_COLOR, G_i_195);
   ObjectSet(S_s_121, OBJPROP_XDISTANCE, G_i_196);
   ObjectSet(S_s_121, OBJPROP_YDISTANCE, G_i_197);
   ObjectSet(S_s_121, OBJPROP_CORNER, G_i_198);
   ObjectSet(S_s_121, OBJPROP_FONTSIZE, G_i_199);
   ObjectSet(S_s_121, OBJPROP_BACK, 0);
   ObjectSet(S_s_121, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_121, OBJPROP_READONLY, 0);
   S_s_122 = "Tahoma";
   G_i_204 = 9;
   G_i_203 = 0;
   G_i_202 = 98;
   G_i_201 = 195;
   G_i_200 = L_i_30;
   S_s_123 = AccountCurrency();
   S_s_124 = "Label23";
   if (ObjectFind(S_s_124) < 0) {
      ObjectCreate(0, S_s_124, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_124, S_s_123, G_i_204, S_s_122, G_i_200);
   ObjectSet(S_s_124, OBJPROP_COLOR, G_i_200);
   ObjectSet(S_s_124, OBJPROP_XDISTANCE, G_i_201);
   ObjectSet(S_s_124, OBJPROP_YDISTANCE, G_i_202);
   ObjectSet(S_s_124, OBJPROP_CORNER, G_i_203);
   ObjectSet(S_s_124, OBJPROP_FONTSIZE, G_i_204);
   ObjectSet(S_s_124, OBJPROP_BACK, 0);
   ObjectSet(S_s_124, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_124, OBJPROP_READONLY, 0);
   S_s_125 = "Tahoma";
   G_i_209 = 9;
   G_i_208 = 0;
   G_i_207 = 111;
   G_i_206 = 195;
   G_i_205 = L_i_30;
   S_s_126 = AccountCurrency();
   S_s_127 = "Label24";
   if (ObjectFind(S_s_127) < 0) {
      ObjectCreate(0, S_s_127, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_127, S_s_126, G_i_209, S_s_125, G_i_205);
   ObjectSet(S_s_127, OBJPROP_COLOR, G_i_205);
   ObjectSet(S_s_127, OBJPROP_XDISTANCE, G_i_206);
   ObjectSet(S_s_127, OBJPROP_YDISTANCE, G_i_207);
   ObjectSet(S_s_127, OBJPROP_CORNER, G_i_208);
   ObjectSet(S_s_127, OBJPROP_FONTSIZE, G_i_209);
   ObjectSet(S_s_127, OBJPROP_BACK, 0);
   ObjectSet(S_s_127, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_127, OBJPROP_READONLY, 0);
   S_s_128 = "Tahoma";
   G_i_214 = 9;
   G_i_213 = 0;
   G_i_212 = 124;
   G_i_211 = 195;
   G_i_210 = L_i_30;
   S_s_129 = AccountCurrency();
   S_s_130 = "Label25";
   if (ObjectFind(S_s_130) < 0) {
      ObjectCreate(0, S_s_130, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   }
   ObjectSetText(S_s_130, S_s_129, G_i_214, S_s_128, G_i_210);
   ObjectSet(S_s_130, OBJPROP_COLOR, G_i_210);
   ObjectSet(S_s_130, OBJPROP_XDISTANCE, G_i_211);
   ObjectSet(S_s_130, OBJPROP_YDISTANCE, G_i_212);
   ObjectSet(S_s_130, OBJPROP_CORNER, G_i_213);
   ObjectSet(S_s_130, OBJPROP_FONTSIZE, G_i_214);
   ObjectSet(S_s_130, OBJPROP_BACK, 0);
   ObjectSet(S_s_130, OBJPROP_SELECTABLE, 0);
   ObjectSet(S_s_130, OBJPROP_READONLY, 0);
}


//+------------------------------------------------------------------+

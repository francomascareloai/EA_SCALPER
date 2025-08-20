/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  HTt p :/ /W W W.M ETA Q uO tE s. n E t
   E-mail : Su pPo rT@mETAQ uOtE s. n e t
*/
#property copyright "Forex MegaDroid Team"
#property link      "http://www.forex-megadroid.com"

#include <WinUser32.mqh>
#import "MegaDroid.dll"
   bool CheckVersion(string a0);
   int GetParams(int a0, int a1, int a2, double& a3[]);
   void Activate(int a0, string a1, string a2, string a3, int a4, string a5, int a6);
   int GetState();
   bool GetStateMessage(string a0, int a1, string a2, int a3);
   bool GetInfoMessage(string a0, int a1, string a2, int a3);
   bool GetAdvMessage(string a0, int a1, string a2, int a3);
   void GetStatus(int a0, int a1, double a2, double a3, double a4);
   int Increment(string a0, int a1, int a2, int a3);
   bool Decrement(int a0);
   bool IsTradeTime(int a0, int a1, int a2, int a3);
   bool s1_SetRules(int a0, int a1, int a2, double a3, double a4, double a5, double a6, double a7);
   bool s1_Buy(int a0, double a1);
   bool s1_Sell(int a0, double a1);
   bool s2_SetRules(int a0, int a1, int a2, double a3, double a4, double a5, double a6);
   bool s2_Buy(int a0, double a1, double a2);
   bool s2_Sell(int a0, double a1, double a2);
   bool s1_Init(int a0, double& a1[]);
   bool s2_Init(int a0, double& a1[]);
   void AddLink(int a0, int a1, int a2, int a3, int a4, string a5);
   void LinksBegin(int a0);
   void LinksEnd(int a0);
#import

extern string Ver.1.41 = "";
extern string _1 = "System Parameters";
extern bool Stealth = TRUE;
extern bool Aggressive = TRUE;
extern double GmtOffset = 0.0;
extern bool NFA = FALSE;
extern bool AutoLocalGmtOffset = TRUE;
extern bool AutoServerGmtOffset = TRUE;
extern int S1_Reference = 77777773;
extern int S2_Reference = 33333337;
extern int S1_DAReference = 55555551;
extern int S2_DAReference = 11111115;
extern string ReceiptCode = "";
extern string _2 = "Comment Position";
extern int TopPadding = 30;
extern int LeftPadding = 20;
extern color TextColor1 = Orange;
extern color TextColor2 = Orange;
extern color TextColor3 = C'0x64,0x64,0xFF';
extern string _3 = "Strategy Parameters";
extern bool RemoteSafetyMode = TRUE;
extern int Slippage = 3;
extern bool SendEmails = FALSE;
extern string OrderComments = "";
extern string _4 = "Order Management";
extern double LotSize = 0.1;
extern string _5 = "Ratio Order Management";
extern double RiskLevel = 0.2;
extern bool RecoveryMode = FALSE;
extern bool ConsiderCommission = TRUE;
extern string _6 = "Advanced Strategy";
extern bool VolatilityAware = TRUE;
extern bool DollarAveraging = TRUE;
extern bool SecureProfit = TRUE;
double Gd_260 = 2.0;
double G_pips_268 = 5.0;
double G_pips_276 = 5.0;
bool Gi_284 = TRUE;
bool Gi_288 = TRUE;
int Gi_292 = 3;
bool Gi_296 = TRUE;
int Gi_300;
int G_datetime_304;
int Gi_308;
double G_hour_312;
int Gi_320;
int Gi_unused_324;
int G_spread_328;
int G_spread_332;
int Gi_336;
double Gd_340;
double Gd_348;
bool Gi_364 = TRUE;
int Gi_368 = 0;
int Gi_372 = 0;
bool Gi_376 = FALSE;
int Gi_380;
int Gi_unused_384 = 1;
int G_global_var_388 = 0;
bool Gi_392 = FALSE;
double Gd_396 = 0.0;
string Gs_404 = "";
string Gs_412 = "";
string Gs_420 = "";
string Gs_428 = "";
string Gs_436 = "";
string Gs_444 = "";
string Gs_452;
string Gs_460;
string Gs_468;
int G_timeframe_476 = PERIOD_M15;
int Gi_480 = 10;
int Gi_484 = 50;
int Gi_488 = 200;
int Gi_492 = 20;
int Gi_496 = 0;
int Gi_500 = 16711680;
int Gi_504 = 255;
int G_period_508 = 6;
int G_period_512 = 20;
int G_period_516 = 8;
bool Gi_520 = TRUE;
bool Gi_524 = TRUE;
int Gi_528 = 12;
bool Gi_532 = TRUE;
int Gi_536 = 20;
bool Gi_540 = TRUE;
bool Gi_544 = FALSE;
double Gd_548 = 1.0;
double Gd_556 = 24.0;
bool Gi_564 = TRUE;
double Gd_568 = 1.0;
double Gd_576 = 1.0;
bool Gi_584 = FALSE;
int Gi_588 = 0;
bool Gi_592 = TRUE;
bool G_bool_596 = TRUE;
double Gd_600 = 2.0;
double Gd_608 = 1.5;
bool G_bool_616 = TRUE;
double Gd_620 = 15.0;
double Gd_628 = 1.5;
double Gd_636 = 4.0;
double Gd_644 = 10.0;
int G_timeframe_652 = PERIOD_M5;
int Gi_656 = 35;
int Gi_660 = 60;
int Gi_664 = 200;
int Gi_668 = 20;
double Gd_672 = 1.0;
int Gi_680 = 0;
int Gi_684 = 16748574;
int Gi_688 = 9639167;
int Gi_692 = 36;
int G_period_696 = 168;
int G_period_700 = 275;
bool Gi_704 = TRUE;
bool Gi_708 = FALSE;
bool Gi_712 = TRUE;
double Gd_716 = 1.0;
double Gd_724 = 12.0;
double Gd_732 = 24.0;
bool Gi_740 = FALSE;
bool Gi_744 = FALSE;
int Gi_748 = 0;
bool Gi_752 = TRUE;
bool G_bool_756 = TRUE;
double Gd_760 = 2.0;
double Gd_768 = 1.5;
bool G_bool_776 = TRUE;
double Gd_780 = 15.0;
double Gd_788 = 1.5;
double Gd_796 = 4.0;
double Gd_804 = 10.0;
int Gi_812 = 0;
int Gi_816 = 0;
int Gi_820 = 0;
int Gi_824;
int Gi_828;
int Gi_832;
int Gi_836;
bool Gi_840 = FALSE;
double Gd_844 = 0.0;
double Gd_852 = 0.0;
bool Gi_860 = FALSE;
bool Gi_864;
int G_count_868 = 0;
bool Gi_872;
int Gi_876 = 0;
int G_ticket_880 = -2;
int G_ticket_884 = -2;
double G_order_profit_888 = 0.0;
double G_order_profit_896 = 0.0;
bool Gi_904;
int Gi_908 = 0;
int G_ticket_912 = -2;
int G_ticket_916 = -2;
double G_order_profit_920 = 0.0;
double G_order_profit_928 = 0.0;
string Gsa_936[] = {".", "..", "...", "....", "....."};
int Gi_unused_940 = 0;
int Gi_unused_944 = 0;
string Gs_948 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
int Gi_unused_956 = 0;
int Gi_unused_960 = 0;
double Gda_unused_964[];
double Gd_968 = 2.0;
int Gi_976 = 0;
int Gi_980 = 0;
double G_irsi_984;
double G_irsi_992;
double G_irsi_1000;
double G_irsi_1008;
double G_icci_1016;
double G_icci_1024;
double G_icci_1032;
double G_ima_1056;
bool Gi_1064 = TRUE;
bool Gi_1068 = TRUE;
double G_ihigh_1072 = 0.0;
double G_ilow_1080 = 0.0;
bool Gi_1088 = FALSE;
int Gi_1092 = 0;
int Gi_1096 = 0;
int Gi_1100 = 0;
int Gi_1104 = 0;
int Gi_1108 = 0;
int Gi_1112 = 0;
int Gi_1116;
int G_ticket_1120 = -2;
int G_ticket_1124 = -2;
int G_datetime_1128 = 0;
int G_datetime_1132 = 0;
int G_ticket_1136 = -1;
int G_datetime_1140 = 0;
int G_ticket_1144 = -1;
int G_datetime_1148 = 0;
int G_ticket_1152 = -1;
int G_ticket_1156 = -1;
int G_ticket_1160 = 0;
int G_ticket_1164 = -1;
bool Gi_1168 = TRUE;
int G_datetime_1172 = 0;
int G_datetime_1176 = 0;
int Gi_1180 = 0;
double G_icci_1184;
double G_icci_1192;
double G_ihigh_1200;
double G_ilow_1208;
double G_ihigh_1216;
double G_ilow_1224;
bool Gi_1232 = FALSE;
int Gi_1236 = 0;
int Gi_1240 = 0;
int Gi_1244 = 0;
int Gi_1248 = 0;
int G_ticket_1252 = -2;
int G_ticket_1256 = -2;
int G_ticket_1260 = -1;
int Gi_1264;
int Gi_1268;
int G_datetime_1272;
int G_datetime_1276;
double G_order_open_price_1280;
int G_ticket_1288 = -1;
int Gi_1292;
int Gi_1296;
int G_datetime_1300;
int G_datetime_1304;
double G_order_open_price_1308;
int G_ticket_1316 = 0;
int G_ticket_1320 = -1;
int G_ticket_1324 = 0;
int G_ticket_1328 = -1;
bool Gi_1332 = TRUE;
int G_datetime_1336 = 0;
int G_datetime_1340 = 0;
bool Gi_1344 = FALSE;

// DA69CBAFF4D38B87377667EEC549DE5A
string f0_50(int Ai_0) {
   string Ls_ret_4;
   switch (Ai_0) {
   case 0:
   case 1:
      Ls_ret_4 = "no error";
      break;
   case 2:
      Ls_ret_4 = "common error";
      break;
   case 3:
      Ls_ret_4 = "invalid trade parameters";
      break;
   case 4:
      Ls_ret_4 = "trade server is busy";
      break;
   case 5:
      Ls_ret_4 = "old version of the client terminal";
      break;
   case 6:
      Ls_ret_4 = "no connection with trade server";
      break;
   case 7:
      Ls_ret_4 = "not enough rights";
      break;
   case 8:
      Ls_ret_4 = "too frequent requests";
      break;
   case 9:
      Ls_ret_4 = "malfunctional trade operation (never returned error)";
      break;
   case 64:
      Ls_ret_4 = "account disabled";
      break;
   case 65:
      Ls_ret_4 = "invalid account";
      break;
   case 128:
      Ls_ret_4 = "trade timeout";
      break;
   case 129:
      Ls_ret_4 = "invalid price";
      break;
   case 130:
      Ls_ret_4 = "invalid stops";
      break;
   case 131:
      Ls_ret_4 = "invalid trade volume";
      break;
   case 132:
      Ls_ret_4 = "market is closed";
      break;
   case 133:
      Ls_ret_4 = "trade is disabled";
      break;
   case 134:
      Ls_ret_4 = "not enough money";
      break;
   case 135:
      Ls_ret_4 = "price changed";
      break;
   case 136:
      Ls_ret_4 = "off quotes";
      break;
   case 137:
      Ls_ret_4 = "broker is busy (never returned error)";
      break;
   case 138:
      Ls_ret_4 = "requote";
      break;
   case 139:
      Ls_ret_4 = "order is locked";
      break;
   case 140:
      Ls_ret_4 = "long positions only allowed";
      break;
   case 141:
      Ls_ret_4 = "too many requests";
      break;
   case 145:
      Ls_ret_4 = "modification denied because order too close to market";
      break;
   case 146:
      Ls_ret_4 = "trade context is busy";
      break;
   case 147:
      Ls_ret_4 = "expirations are denied by broker";
      break;
   case 148:
      Ls_ret_4 = "amount of open and pending orders has reached the limit";
      break;
   case 149:
      Ls_ret_4 = "hedging is prohibited";
      break;
   case 150:
      Ls_ret_4 = "prohibited by FIFO rules";
      break;
   case 4000:
      Ls_ret_4 = "no error (never generated code)";
      break;
   case 4001:
      Ls_ret_4 = "wrong function pointer";
      break;
   case 4002:
      Ls_ret_4 = "array index is out of range";
      break;
   case 4003:
      Ls_ret_4 = "no memory for function call stack";
      break;
   case 4004:
      Ls_ret_4 = "recursive stack overflow";
      break;
   case 4005:
      Ls_ret_4 = "not enough stack for parameter";
      break;
   case 4006:
      Ls_ret_4 = "no memory for parameter string";
      break;
   case 4007:
      Ls_ret_4 = "no memory for temp string";
      break;
   case 4008:
      Ls_ret_4 = "not initialized string";
      break;
   case 4009:
      Ls_ret_4 = "not initialized string in array";
      break;
   case 4010:
      Ls_ret_4 = "no memory for array\' string";
      break;
   case 4011:
      Ls_ret_4 = "too long string";
      break;
   case 4012:
      Ls_ret_4 = "remainder from zero divide";
      break;
   case 4013:
      Ls_ret_4 = "zero divide";
      break;
   case 4014:
      Ls_ret_4 = "unknown command";
      break;
   case 4015:
      Ls_ret_4 = "wrong jump (never generated error)";
      break;
   case 4016:
      Ls_ret_4 = "not initialized array";
      break;
   case 4017:
      Ls_ret_4 = "dll calls are not allowed";
      break;
   case 4018:
      Ls_ret_4 = "cannot load library";
      break;
   case 4019:
      Ls_ret_4 = "cannot call function";
      break;
   case 4020:
      Ls_ret_4 = "expert function calls are not allowed";
      break;
   case 4021:
      Ls_ret_4 = "not enough memory for temp string returned from function";
      break;
   case 4022:
      Ls_ret_4 = "system is busy (never generated error)";
      break;
   case 4050:
      Ls_ret_4 = "invalid function parameters count";
      break;
   case 4051:
      Ls_ret_4 = "invalid function parameter value";
      break;
   case 4052:
      Ls_ret_4 = "string function internal error";
      break;
   case 4053:
      Ls_ret_4 = "some array error";
      break;
   case 4054:
      Ls_ret_4 = "incorrect series array using";
      break;
   case 4055:
      Ls_ret_4 = "custom indicator error";
      break;
   case 4056:
      Ls_ret_4 = "arrays are incompatible";
      break;
   case 4057:
      Ls_ret_4 = "global variables processing error";
      break;
   case 4058:
      Ls_ret_4 = "global variable not found";
      break;
   case 4059:
      Ls_ret_4 = "function is not allowed in testing mode";
      break;
   case 4060:
      Ls_ret_4 = "function is not confirmed";
      break;
   case 4061:
      Ls_ret_4 = "send mail error";
      break;
   case 4062:
      Ls_ret_4 = "string parameter expected";
      break;
   case 4063:
      Ls_ret_4 = "integer parameter expected";
      break;
   case 4064:
      Ls_ret_4 = "double parameter expected";
      break;
   case 4065:
      Ls_ret_4 = "array as parameter expected";
      break;
   case 4066:
      Ls_ret_4 = "requested history data in update state";
      break;
   case 4099:
      Ls_ret_4 = "end of file";
      break;
   case 4100:
      Ls_ret_4 = "some file error";
      break;
   case 4101:
      Ls_ret_4 = "wrong file name";
      break;
   case 4102:
      Ls_ret_4 = "too many opened files";
      break;
   case 4103:
      Ls_ret_4 = "cannot open file";
      break;
   case 4104:
      Ls_ret_4 = "incompatible access to a file";
      break;
   case 4105:
      Ls_ret_4 = "no order selected";
      break;
   case 4106:
      Ls_ret_4 = "unknown symbol";
      break;
   case 4107:
      Ls_ret_4 = "invalid price parameter for trade function";
      break;
   case 4108:
      Ls_ret_4 = "invalid ticket";
      break;
   case 4109:
      Ls_ret_4 = "trade is not allowed in the expert properties";
      break;
   case 4110:
      Ls_ret_4 = "longs are not allowed in the expert properties";
      break;
   case 4111:
      Ls_ret_4 = "shorts are not allowed in the expert properties";
      break;
   case 4200:
      Ls_ret_4 = "object is already exist";
      break;
   case 4201:
      Ls_ret_4 = "unknown object property";
      break;
   case 4202:
      Ls_ret_4 = "object is not exist";
      break;
   case 4203:
      Ls_ret_4 = "unknown object type";
      break;
   case 4204:
      Ls_ret_4 = "no object name";
      break;
   case 4205:
      Ls_ret_4 = "object coordinates error";
      break;
   case 4206:
      Ls_ret_4 = "no specified subwindow";
      break;
   default:
      Ls_ret_4 = "unknown error";
   }
   return (Ls_ret_4);
}

// 6F7C7CFB8D0CEFCAD98913E902F40EC6
int f0_21() {
   double Lda_0[21];
   if (s1_Init(Gi_380, Lda_0)) {
      Gi_480 = Lda_0[0];
      Gi_488 = Lda_0[1];
      Gi_492 = Lda_0[2];
      Gi_496 = Lda_0[3];
      G_period_508 = Lda_0[4];
      G_period_512 = Lda_0[5];
      G_period_516 = Lda_0[6];
      Gd_548 = Lda_0[11];
      Gd_556 = Lda_0[12];
      Gd_568 = Lda_0[13];
      Gd_576 = Lda_0[14];
      Gi_588 = Lda_0[15];
      G_timeframe_476 = Lda_0[20];
      return (1);
   }
   return (0);
}

// 5322910D4F04A8BA911EF049B1DFF1CF
int f0_16() {
   double Lda_0[17];
   if (s2_Init(Gi_380, Lda_0)) {
      Gi_656 = Lda_0[0];
      Gi_664 = Lda_0[1];
      Gi_668 = Lda_0[2];
      Gd_672 = Lda_0[3];
      Gi_680 = Lda_0[4];
      Gi_692 = Lda_0[5];
      G_period_696 = Lda_0[6];
      G_period_700 = Lda_0[7];
      Gd_716 = Lda_0[8];
      Gd_724 = Lda_0[9];
      Gd_732 = Lda_0[10];
      Gi_748 = Lda_0[11];
      G_timeframe_652 = Lda_0[16];
      return (1);
   }
   return (0);
}

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   double global_var_4;
   double Ld_12;
   Gi_828 = LeftPadding;
   Gi_824 = TopPadding;
   if (Gi_832 != LeftPadding || Gi_836 != TopPadding) {
      Gi_832 = LeftPadding;
      Gi_836 = TopPadding;
   } else f0_5(0, Gi_828, Gi_824);
   Gi_816 = 0;
   Gi_812 = 0;
   Gs_452 = "MegaDroid" + " ver: " + "1.41" + " Symbol: " + Symbol();
   f0_37(Gs_452, TextColor2);
   f0_35();
   WindowRedraw();
   Gi_840 = CheckVersion("1.41");
   if (!Gi_840) {
      f0_37("Error:");
      f0_37("Dll and Expert versions mismatch", TextColor2, Gi_816, Gi_812 - 1, 49);
      return (0);
   }
   Gi_380 = Increment(Symbol(), Digits, IsTesting(), WindowHandle(Symbol(), Period()));
   for (int count_0 = 0; !IsStopped() && StringLen(AccountName()) <= 0; count_0++) {
      f0_37("Waiting for connection" + f0_14(count_0), TextColor1, 2, 2);
      WindowRedraw();
      Sleep(150);
   }
   f0_37("Authentication...", TextColor1, 2, 2);
   WindowRedraw();
   Gi_372 = 0;
   ReceiptCode = StringTrimLeft(StringTrimRight(ReceiptCode));
   if (StringLen(ReceiptCode) <= 0) {
      if (GlobalVariableCheck("GV_MegaDroid_REC")) {
         global_var_4 = GlobalVariableGet("GV_MegaDroid_REC");
         ReceiptCode = f0_53(global_var_4);
      } else Gi_372 |= 32;
   } else {
      Ld_12 = f0_18(ReceiptCode);
      if (GlobalVariableSet("GV_MegaDroid_REC", Ld_12) == 0) Gi_372 |= 64;
   }
   Activate(AccountNumber(), AccountCurrency(), AccountCompany(), AccountServer(), IsDemo(), ReceiptCode, 1);
   Gi_368 = GetState();
   if (!IsTesting()) f0_22();
   f0_41(Gi_368 | Gi_372, 2, 2);
   LinksBegin(Gi_380);
   int str_len_20 = StringLen(Gs_404);
   int str_len_24 = StringLen(Gs_412);
   if (str_len_20 > 1) f0_37(Gs_404);
   if (str_len_24 > 0) f0_44(Gs_412, TextColor2, Gi_816, Gi_812 - 1, 7 * (str_len_20 + 1));
   f0_35();
   str_len_20 = StringLen(Gs_420);
   str_len_24 = StringLen(Gs_428);
   if (str_len_20 > 1) f0_37(Gs_420);
   if (str_len_24 > 0) f0_44(Gs_428, TextColor2, Gi_816, Gi_812 - 1, 7 * (str_len_20 + 1));
   if (str_len_20 > 1 || str_len_24 > 0) f0_35();
   if (Gi_284) Gi_284 = f0_21();
   if (Gi_288) Gi_288 = f0_16();
   if (Gi_284 && (!Aggressive)) Gi_288 = FALSE;
   G_bool_596 = G_bool_596 && VolatilityAware;
   G_bool_756 = G_bool_756 && VolatilityAware;
   G_bool_616 = G_bool_616 && DollarAveraging && (!NFA);
   G_bool_776 = G_bool_776 && DollarAveraging && (!NFA);
   if ((!Gi_284) && (!Gi_288)) {
      Gs_460 = "Error:";
      Gs_468 = "This currency is not supported!";
   } else {
      Gs_460 = "Aggressive:";
      Gs_468 = f0_12(Gi_284 && Gi_288);
      if (Aggressive && (!Gi_284 && Gi_288)) Gs_468 = Gs_468 + " (not supported)";
   }
   f0_37(Gs_460);
   f0_37(Gs_468, TextColor2, Gi_816, Gi_812 - 1, 7 * (StringLen(Gs_460) + 1));
   f0_35();
   str_len_20 = StringLen(Gs_436);
   str_len_24 = StringLen(Gs_444);
   if (str_len_20 > 1) f0_37(Gs_436);
   if (str_len_24 > 0) f0_44(Gs_444, TextColor2, Gi_816, Gi_812 - 1, 7 * (str_len_20 + 1));
   WindowRedraw();
   LinksEnd(Gi_380);
   if ((!Gi_284) && (!Gi_288)) MessageBox("You have selected the wrong currency pair!", Gs_452 + ": Warning", MB_ICONEXCLAMATION);
   Gi_376 = FALSE;
   if (IsTesting()) Gi_364 = FALSE;
   G_global_var_388 = 0;
   Gi_392 = FALSE;
   if (!IsTesting())
      if (GlobalVariableCheck("GV_MegaDroid_MKT")) G_global_var_388 = GlobalVariableGet("GV_MegaDroid_MKT");
   if (Gi_296) Gi_300 = 0;
   else Gi_300 = 1;
   return (0);
}

// 80DE7447339483E443CADB2D9C0DDDDA
void f0_22() {
   string Ls_0 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
   string Ls_8 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
   if (Gi_368 & 65536 > 0) {
      if (GetStateMessage(Ls_0, 60, Ls_8, 255)) {
         Gs_404 = StringConcatenate(Ls_0, ":");
         Gs_412 = StringTrimLeft(Ls_8);
      } else {
         Gs_404 = "";
         Gs_412 = "";
      }
   }
   if (GetInfoMessage(Ls_0, 60, Ls_8, 255)) {
      Gs_420 = StringConcatenate(Ls_0, ":");
      Gs_428 = StringTrimLeft(Ls_8);
   } else {
      Gs_420 = "";
      Gs_428 = "";
   }
   if (GetAdvMessage(Ls_0, 60, Ls_8, 255)) {
      Gs_436 = StringConcatenate(Ls_0, ":");
      Gs_444 = StringTrimLeft(Ls_8);
      return;
   }
   Gs_436 = "";
   Gs_444 = "";
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   Decrement(Gi_380);
   if (IsTesting()) {
      if (!(!IsVisualMode())) return (0);
      f0_37("GmtOffset:");
      f0_37(DoubleToStr(GmtOffset, 1), TextColor2, Gi_816, Gi_812 - 1, 77);
      f0_35();
      f0_37("Digits:");
      f0_37(Digits, TextColor2, Gi_816, Gi_812 - 1, 56);
      f0_37("Spread:");
      f0_37(StringConcatenate(DoubleToStr(G_spread_328 / Gd_340, 1), " (", G_spread_328, " pips)"), TextColor2, Gi_816, Gi_812 - 1, 56);
      f0_35();
      return (0);
   }
   GlobalVariableSet("GV_MegaDroid_MKT", G_global_var_388);
   switch (UninitializeReason()) {
   case REASON_CHARTCLOSE:
   case REASON_REMOVE:
      f0_48(0, Gi_820);
      Gi_820 = 0;
      break;
   case REASON_RECOMPILE:
   case REASON_CHARTCHANGE:
   case REASON_PARAMETERS:
   case REASON_ACCOUNT:
      f0_48(1, Gi_820);
      Gi_820 = 1;
   }
   return (0);
}

// 3BE4B59601B7B2E82D21E1C5C718B88F
double f0_11(bool Ai_0, double Ad_4, double Ad_12 = 0.0) {
   if (Ai_0) return (Ad_4);
   return (Ad_12);
}

// 42F527E1542B9BECD78B7B4C8514DEB0
string f0_12(bool Ai_0) {
   if (Ai_0) return ("True");
   return ("False");
}

// 0FFEF2F61AF2C53DC3E20BC577547C1C
string f0_2(bool Ai_0, string As_4, string As_12 = "") {
   if (Ai_0) return (As_4);
   return (As_12);
}

// AEAA03D41A3A752C422C407A2EBDF031
string f0_30(int Ai_0) {
   switch (Ai_0) {
   case 0:
      return ("Buy");
   case 1:
      return ("Sell");
   }
   return ("Order");
}

// 8C7750BBB540A7CC24802899D11224EF
string f0_25(int Ai_0) {
   switch (Ai_0) {
   case 1:
      return ("automatic: server");
   case 2:
      return ("automatic: server");
   case 4:
      return ("automatic: local");
   }
   return ("manual");
}

// C4F1A6CC963C23B07A40B6567B5FABDD
string f0_38(int Ai_0) {
   switch (Ai_0) {
   case 1:
      return ("Correction");
   case 3:
      return ("Upward Impulse");
   case 2:
      return ("Downward Impulse");
   }
   return ("");
}

// 448DAF3FF903080C09AF6828B9E0BDDF
string f0_14(int Ai_0) {
   int Li_4 = MathMod(Ai_0, 5);
   return (Gsa_936[Li_4]);
}

// C99BF3DBA1EDCC286F49D05BCA06DBB1
void f0_41(int Ai_0, int Ai_4 = -1, int Ai_8 = -1) {
   if (Ai_4 == -1) Ai_4 = Gi_816;
   if (Ai_8 == -1) Ai_8 = Gi_812;
   Gi_816 = Ai_4;
   Gi_812 = Ai_8;
   if (Ai_0 & 16384 > 0) f0_37("Authenticated", TextColor1);
   else f0_37("Authentication failed - error(" + Ai_0 + ")", TextColor1);
   if (Ai_0 & 512 > 0) f0_37("Attention: Upgrade available", TextColor1);
   if (Ai_0 & 1024 > 0) f0_37("Error: Upgrade required", TextColor1);
   if (Ai_0 & 1 > 0) f0_37("Error: Internet initialization failed", TextColor1);
   if (Ai_0 & 2 > 0) f0_37("Error: Internet connection failed", TextColor1);
   if (Ai_0 & 4 > 0) f0_37("Error: Invalid account number", TextColor1);
   if (Ai_0 & 8 > 0) f0_37("Error: Invalid account status", TextColor1);
   if (Ai_0 & 16 > 0) f0_37("Error: Dll and Expert versions mismatch", TextColor1);
   if (Ai_0 & 128 > 0) f0_37("Error: Unable to retrieve authentication code", TextColor1);
   if (Ai_0 & 256 > 0) f0_37("Error: Server response failure", TextColor1);
   if (Ai_0 & 2048 > 0) f0_37("Error: Invalid authorisation details", TextColor1);
   if (Ai_0 & 4096 > 0) f0_37("Error: Authorisation declined", TextColor1);
}

// E3EEC3F2E5BF785368EFFB4040FD4F55
string f0_54(int Ai_0) {
   return (StringConcatenate("MegaDroid", " lb: ", Ai_0));
}

// 1D75F0D638248553D80CFFB8D1DC6682
void f0_5(int Ai_0, int &Ai_4, int &Ai_8) {
   string name_12 = f0_54(Ai_0);
   if (ObjectFind(name_12) == 0) {
      Ai_4 = ObjectGet(name_12, OBJPROP_XDISTANCE);
      Ai_8 = ObjectGet(name_12, OBJPROP_YDISTANCE);
   }
}

// C3BAA9C535265F9452B54C5C75FB8004
void f0_37(string A_text_0, color A_color_8 = -1, int Ai_12 = -1, double Ad_16 = -1.0, int Ai_24 = 0) {
   if (A_color_8 == CLR_NONE) A_color_8 = TextColor1;
   if (Ai_12 == -1) Ai_12 = Gi_816;
   if (Ad_16 == -1.0) Ad_16 = Gi_812;
   string name_28 = f0_54(Ai_12);
   if (ObjectFind(name_28) != 0) {
      ObjectCreate(name_28, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_28, OBJPROP_CORNER, 0);
   }
   ObjectSetText(name_28, A_text_0, 9, "Courier New", A_color_8);
   ObjectSet(name_28, OBJPROP_XDISTANCE, Gi_828 + Ai_24);
   ObjectSet(name_28, OBJPROP_YDISTANCE, Gi_824 + 14.0 * Ad_16);
   if (Gi_812 < Ad_16 + 1.0) Gi_812 = Ad_16 + 1.0;
   if (Gi_816 < Ai_12 + 1) Gi_816 = Ai_12 + 1;
   if (Gi_820 < Ai_12) Gi_820 = Ai_12;
}

// BF5A9BC44BBE42C10E8B2D4446B20D89
void f0_35(int Ai_0 = -1, double Ad_4 = -1.0, int Ai_12 = 0) {
   if (Ai_0 == -1) Ai_0 = Gi_816;
   if (Ad_4 == -1.0) Ad_4 = Gi_812;
   f0_37("_______", TextColor2, Ai_0, Ad_4 - 0.3, Ai_12);
   if (Gi_812 < Ad_4 + 1.0) Gi_812 = Ad_4 + 1.0;
}

// D260618711A08F58FB16134F9730E9FB
int f0_44(string As_0, int Ai_8 = -1, int Ai_12 = -1, double Ad_16 = -1.0, int Ai_24 = 0) {
   string Ls_36;
   int Li_52;
   int Li_56;
   string Ls_60;
   string Ls_68;
   string Ls_76;
   string name_84;
   int Li_92;
   int Li_96;
   int Li_28 = 0;
   int Li_32 = 0;
   if (Ai_12 == -1) Ai_12 = Gi_816;
   if (Ad_16 == -1.0) Ad_16 = Gi_812;
   int Li_44 = StringLen(As_0);
   int Li_48 = 0;
   while (Li_32 < Li_44) {
      Li_48 = 0;
      Li_32 = StringFind(As_0, 
      "\n", Li_28);
      if (Li_32 == -1) Li_32 = Li_44;
      else Li_48 = 1;
      Ls_36 = StringSubstr(As_0, Li_28, Li_32 - Li_28);
      if (Ls_36 == "0") {
         f0_35(Ai_12, Ad_16, Ai_24);
         Ai_12++;
      } else {
         Li_52 = StringFind(Ls_36, "<a>");
         Li_56 = -1;
         if (Li_52 >= 0) Li_56 = StringFind(Ls_36, "</a>", Li_52 + 3);
         if (Li_52 >= 0 && Li_56 > 0) {
            if (Li_52 > 0) Ls_60 = StringSubstr(Ls_36, 0, Li_52);
            else Ls_60 = "";
            Ls_68 = StringSubstr(Ls_36, Li_52 + 3, Li_56 - Li_52 - 3);
            Ls_76 = StringSubstr(Ls_36, Li_56 + 4);
            if (StringLen(Ls_60) > 0) {
               f0_37(Ls_60, Ai_8, Ai_12, Ad_16, Ai_24);
               Ai_12++;
            }
            name_84 = f0_54(Ai_12);
            f0_37(Ls_68, TextColor3, Ai_12, Ad_16, Ai_24 + 7 * StringLen(Ls_60));
            Li_92 = ObjectGet(name_84, OBJPROP_XDISTANCE);
            Li_96 = ObjectGet(name_84, OBJPROP_YDISTANCE);
            AddLink(Gi_380, Li_92, Li_96, Li_92 + 7 * StringLen(Ls_68), Li_96 + 14, Ls_68);
            Ai_12++;
            if (StringLen(Ls_76) > 0) {
               f0_37(Ls_76, Ai_8, Ai_12, Ad_16, Ai_24 + 7 * (StringLen(Ls_60) + StringLen(Ls_68)));
               Ai_12++;
            }
         } else {
            if (Li_32 - Li_28 > 60) Li_32 = Li_28 + 60;
            Ls_36 = StringSubstr(As_0, Li_28, Li_32 - Li_28);
            f0_37(Ls_36, Ai_8, Ai_12, Ad_16, Ai_24);
            Ai_12++;
         }
      }
      Li_28 = Li_32 + Li_48;
      Ad_16++;
   }
   return (Ai_12);
}

// D61FF371629181373AAEA1B1C60EF302
void f0_48(int Ai_0, int Ai_4) {
   for (int Li_8 = Ai_0; Li_8 <= Ai_4; Li_8++) ObjectDelete(f0_54(Li_8));
}

// 57862CA56FB6CA780A1AA075901C0C7C
double f0_18(string As_0) {
   int Li_24;
   As_0 = f0_45(As_0);
   int str_len_8 = StringLen(As_0);
   double Ld_ret_12 = 0;
   for (int Li_20 = 0; Li_20 < str_len_8; Li_20++) {
      Li_24 = StringFind(Gs_948, StringSubstr(As_0, str_len_8 - Li_20 - 1, 1));
      Ld_ret_12 += Li_24 * MathPow(36, Li_20);
   }
   return (Ld_ret_12);
}

// DF423827A5F770FA7875E68553FDD0BB
string f0_53(double Ad_0) {
   string str_concat_8 = "";
   for (Ad_0 = MathAbs(Ad_0); Ad_0 >= 1.0; Ad_0 = MathFloor(Ad_0 / 36.0)) str_concat_8 = StringConcatenate(StringSubstr(Gs_948, MathMod(Ad_0, 36), 1), str_concat_8);
   return (str_concat_8);
}

// D27AF7D1516C24C3278EA8BCC56C9759
string f0_45(string As_0) {
   int Li_8;
   int Li_20;
   int str_len_16 = StringLen(As_0);
   for (int Li_12 = 0; Li_12 < str_len_16; Li_12++) {
      Li_20 = 0;
      Li_8 = StringGetChar(As_0, Li_12);
      if (Li_8 > '`' && Li_8 < '{') Li_20 = Li_8 - 32;
      if (Li_8 > 'ß' && Li_8 < 256) Li_20 = Li_8 - 32;
      if (Li_8 == '¸') Li_20 = 168;
      if (Li_20 > 0) As_0 = StringSetChar(As_0, Li_12, Li_20);
   }
   return (As_0);
}

// A1C3E4052962E3D363F2BF4323568F49
int f0_28() {
   for (int count_0 = 0; IsTradeContextBusy() && count_0 < 10; count_0++) Sleep(15);
   if (count_0 >= 10) Print("Trade context is buisy more than ", DoubleToStr(15 * count_0 / 1000, 2), " seconds");
   else
      if (count_0 > 0) Print("Trade context was buisy ", DoubleToStr(15 * count_0 / 1000, 2), " seconds");
   return (count_0);
}

// A908BF30D5A0CAE9E3CAA8BBF9AF6384
int f0_29(int A_cmd_0, double A_lots_4, double A_price_12, double A_price_20, double A_price_28, int A_magic_36, color A_color_40, bool Ai_44 = FALSE) {
   double price_48;
   double price_56;
   int error_68;
   double price_76;
   int ticket_64 = -1;
   int count_72 = 0;
   bool Li_84 = FALSE;
   double Ld_88 = Gd_968 * Gd_340 * Point;
   while (!Li_84) {
      if (!Ai_44) {
         price_48 = A_price_20;
         price_56 = A_price_28;
      } else {
         price_48 = 0;
         price_56 = 0;
      }
      if (A_cmd_0 == OP_BUY) price_76 = MarketInfo(Symbol(), MODE_ASK);
      else
         if (A_cmd_0 == OP_SELL) price_76 = MarketInfo(Symbol(), MODE_BID);
      if (count_72 > 0 && MathAbs(price_76 - A_price_12) > Ld_88) {
         Print("Price is too far");
         break;
      }
      f0_28();
      ticket_64 = OrderSend(Symbol(), A_cmd_0, A_lots_4, A_price_12, Slippage * Gd_340, price_56, price_48, OrderComments, A_magic_36, 0, A_color_40);
      if (ticket_64 >= 0) {
         Gd_396 += A_lots_4;
         break;
      }
      count_72++;
      error_68 = GetLastError();
      switch (error_68) {
      case 130/* INVALID_STOPS */:
         if (!Ai_44) G_global_var_388 = 1;
      case 0/* NO_ERROR */:
         if (!Ai_44) Ai_44 = TRUE;
         else Li_84 = TRUE;
         break;
      case 4/* SERVER_BUSY */: break;
      case 6/* NO_CONNECTION */: break;
      case 129/* INVALID_PRICE */: break;
      case 136/* OFF_QUOTES */: break;
      case 137/* BROKER_BUSY */: break;
      case 146/* TRADE_CONTEXT_BUSY */: break;
      case 135/* PRICE_CHANGED */:
      case 138/* REQUOTE */:
         RefreshRates();
         break;
      default:
         Li_84 = TRUE;
      }
      if (count_72 > 10) break;
   }
   if (ticket_64 >= 0) {
      if (Ai_44) {
         if (OrderSelect(ticket_64, SELECT_BY_TICKET)) {
            Sleep(1000);
            f0_28();
            OrderModify(ticket_64, OrderOpenPrice(), A_price_28, A_price_20, 0, A_color_40);
         }
      }
      if (count_72 > 5) Print(f0_30(A_cmd_0) + " operation attempts: ", count_72);
      if (SendEmails) SendMail(Gs_452, "Open " + f0_30(A_cmd_0) + ": [" + Symbol() + "] " + NormalizeDouble(A_price_12, Digits));
   } else Print(f0_30(A_cmd_0) + " operation failed - error(", error_68, "): ", f0_50(error_68), " attempts: ", count_72);
   return (ticket_64);
}

// D0B773F3CEA185836A86C349E30F8167
int f0_43(color A_color_0, bool Ai_4 = FALSE, double Ad_8 = 1.0) {
   double price_16;
   double order_takeprofit_24;
   double order_stoploss_32;
   int Li_40;
   double order_lots_44;
   int error_60;
   if (Ad_8 == 1.0) order_lots_44 = OrderLots();
   else order_lots_44 = f0_9(OrderLots() * Ad_8, Li_40);
   bool Li_52 = FALSE;
   if (Ai_4) {
      f0_28();
      order_takeprofit_24 = OrderTakeProfit();
      order_stoploss_32 = OrderStopLoss();
      OrderModify(OrderTicket(), OrderOpenPrice(), 0, 0, 0, A_color_0);
   }
   for (int count_56 = 0; count_56 < 10; count_56++) {
      if (f0_28() > 5) RefreshRates();
      if (OrderType() == OP_BUY) price_16 = Bid;
      else price_16 = Ask;
      if (OrderClose(OrderTicket(), order_lots_44, price_16, Slippage * Gd_340, A_color_0)) {
         Li_52 = TRUE;
         if (Ad_8 >= 1.0) return (-1);
         f0_17(OrderMagicNumber(), OrderType());
         break;
      }
      error_60 = GetLastError();
      Print("Order close operation failed - error(", error_60, "): ", f0_50(error_60));
      RefreshRates();
   }
   if ((!Li_52) && Ai_4) {
      f0_28();
      OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_32, order_takeprofit_24, 0, A_color_0);
   }
   if (!Li_52) Print("Order close operation failed");
   return (OrderTicket());
}

// DA91C8297B29714F1032A7F7B3F099AB
double f0_51(double Ad_0, double Ad_8, int &Ai_16) {
   if (AccountLeverage() < 100) return (f0_9(Ad_0 * Ad_8 / MarketInfo(Symbol(), MODE_MARGINREQUIRED), Ai_16));
   return (f0_9(Ad_0 * Ad_8 / MarketInfo(Symbol(), MODE_MARGINREQUIRED) / (AccountLeverage() / 100.0), Ai_16));
}

// 38350FE142782EF0E6BB82AC5D70CEFB
double f0_9(double Ad_0, int &Ai_8) {
   double lotstep_20 = MarketInfo(Symbol(), MODE_LOTSTEP);
   double Ld_28 = MarketInfo(Symbol(), MODE_MINLOT);
   double Ld_36 = MarketInfo(Symbol(), MODE_MAXLOT);
   double Ld_ret_12 = MathFloor(Ad_0 / lotstep_20) * lotstep_20;
   Ai_8 = 0;
   if (Ld_ret_12 < Ld_28) {
      Ld_ret_12 = Ld_28;
      Ai_8 = -1;
   }
   if (Ld_ret_12 > Ld_36) {
      Ld_ret_12 = Ld_36;
      Ai_8 = 1;
   }
   return (Ld_ret_12);
}

// B0F69BE6B6411C583E295EA1AC777C43
void f0_31(double Ad_0, double Ad_8, int Ai_16) {
   double Ld_20 = (Ad_8 - Ad_0) / (Point * Gd_340);
   if (Ai_16 == 1) Ld_20 = -Ld_20;
   Gd_844 += Ld_20;
   if (Gd_852 < Gd_844) Gd_852 = Gd_844;
}

// 1A11FBAEDF03F1688FD91CF90C155196
int f0_4() {
   if (Gd_852 > Gd_844 + Gd_260 * Gd_340 && Gi_876 > Gi_976) return (1);
   Gi_976 = Gi_876;
   return (0);
}

// BA7A9F15AD6ADAB283EDB0569430D03F
int f0_32() {
   int count_0 = 0;
   Gd_844 = 0;
   Gd_852 = 0;
   for (int pos_4 = OrdersHistoryTotal() - 1; pos_4 >= 0; pos_4--) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderMagicNumber() != S1_Reference && OrderMagicNumber() != S2_Reference) continue;
         f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
         count_0++;
      }
   }
   return (count_0);
}

// 556B050CE914D18480D6EA30308C7790
int f0_17(int A_magic_0, int A_cmd_4) {
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      if (OrderSelect(pos_8, SELECT_BY_POS)) {
         if (OrderMagicNumber() == A_magic_0) {
            if (OrderSymbol() == Symbol())
               if (OrderType() == A_cmd_4) return (OrderTicket());
         }
      }
   }
   return (-1);
}

// 35DD39B16AD1B34E1CB9653130B820B5
void f0_8() {
   G_count_868 = 0;
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      if (OrderSelect(pos_0, SELECT_BY_POS)) {
         if (OrderSymbol() == Symbol())
            if (OrderMagicNumber() != S1_Reference && OrderMagicNumber() != S2_Reference) G_count_868++;
      }
   }
}

// 43A9678DB081E54B4C6523A61F9531AF
int f0_13() {
   return (G_count_868 <= 0 && G_ticket_880 < 0 && G_ticket_884 < 0 && G_ticket_912 < 0 && G_ticket_916 < 0);
}

// BBB5AAB0A7623077720301463A120FA8
int f0_34() {
   if (G_icci_1016 >= 0.0 || G_irsi_984 >= 50.0) G_datetime_1132 = G_datetime_304;
   if (G_icci_1016 <= 0.0 || G_irsi_984 <= 50.0) G_datetime_1128 = G_datetime_304;
   if (G_datetime_1132 > 0 && G_datetime_304 - G_datetime_1132 > 3600.0 * Gd_568) return (2);
   if (G_datetime_1128 > 0 && G_datetime_304 - G_datetime_1128 > 3600.0 * Gd_568) return (3);
   if (G_datetime_1132 == 0 || G_datetime_1128 == 0) return (0);
   return (1);
}

// 103369D4ACB6D6A4C3005A10883433FB
void f0_3() {
   int shift_0;
   if (G_datetime_304 - Gi_320 < 3600.0 * Gi_528) shift_0 = iBarShift(NULL, G_timeframe_476, Gi_320 - 86400);
   else shift_0 = iBarShift(NULL, G_timeframe_476, Gi_320);
   G_ihigh_1072 = iHigh(NULL, G_timeframe_476, iHighest(NULL, G_timeframe_476, MODE_HIGH, shift_0 - Gi_300, Gi_300));
   G_ilow_1080 = iLow(NULL, G_timeframe_476, iLowest(NULL, G_timeframe_476, MODE_LOW, shift_0 - Gi_300, Gi_300));
}

// FFE8957665FD5C620AB36A50047539E3
void f0_55() {
   int Li_0;
   HideTestIndicators(TRUE);
   G_irsi_984 = iRSI(NULL, G_timeframe_476, G_period_508, PRICE_CLOSE, Gi_300);
   G_irsi_992 = iRSI(NULL, G_timeframe_476, G_period_508, PRICE_CLOSE, Gi_300 + 1);
   G_irsi_1000 = iRSI(NULL, G_timeframe_476, G_period_508, PRICE_CLOSE, Gi_300 + 2);
   if (Gi_520) G_irsi_1008 = iRSI(NULL, PERIOD_M1, G_period_512, PRICE_CLOSE, Gi_300);
   G_icci_1016 = iCCI(NULL, G_timeframe_476, G_period_516, PRICE_TYPICAL, Gi_300);
   G_icci_1024 = iCCI(NULL, G_timeframe_476, G_period_516, PRICE_TYPICAL, Gi_300 + 1);
   G_icci_1032 = iCCI(NULL, G_timeframe_476, G_period_516, PRICE_TYPICAL, Gi_300 + 2);
   G_ima_1056 = iMA(NULL, G_timeframe_476, G_period_516, 0, MODE_SMA, PRICE_MEDIAN, Gi_300);
   if (Gi_532) {
      if (G_irsi_984 >= 50 - Gi_536 / 2 && G_irsi_984 <= Gi_536 / 2 + 50) {
         Gi_1064 = TRUE;
         Gi_1068 = TRUE;
      }
   }
   if (Gi_524) f0_3();
   if (Gi_564) {
      Li_0 = Gi_1108;
      Gi_1108 = f0_34();
      if (Li_0 != Gi_1108) {
         Gi_1112 = Li_0;
         if (Gi_1108 == 1) Gi_1116 = G_datetime_304 + 3600.0 * Gd_576;
      }
   }
   if (Gi_588 > 0) {
      if (G_spread_328 > Gi_588 * Gd_340) {
         if (G_spread_332 < G_spread_328) {
            Print("Strategy1: Safe spread limit exceeded: spread = ", G_spread_328);
            if (Gi_592) Print("Strategy1: Using DayDirection filter");
         }
         Gi_1088 = TRUE;
      } else {
         if (G_spread_332 > Gi_588 * Gd_340) Print("Strategy1: Safe spread limit normalized: spread = ", G_spread_328);
         Gi_1088 = FALSE;
      }
   }
   HideTestIndicators(FALSE);
}

// 2AE7E8F8DF8B9ACC91E0476DB0EB7A9E
int f0_6() {
   double iclose_0;
   double iclose_8;
   int shift_16;
   int shift_20;
   if (!Gi_1064) return (0);
   if (Gi_564) {
      if (Gi_1108 == 2) return (0);
      if (G_datetime_304 <= Gi_1116)
         if (Gi_1112 == 2) return (0);
   }
   if (Gi_584 || Gi_1088) {
      if (G_datetime_304 - Gi_320 < 43200.0) {
         shift_16 = iBarShift(NULL, G_timeframe_476, Gi_320 - 86400);
         shift_20 = iBarShift(NULL, G_timeframe_476, Gi_320);
      } else {
         shift_16 = iBarShift(NULL, G_timeframe_476, Gi_320);
         shift_20 = Gi_300;
      }
      iclose_8 = iClose(NULL, G_timeframe_476, shift_16);
      iclose_0 = iClose(NULL, G_timeframe_476, shift_20);
      if (iclose_0 < iclose_8) return (0);
   }
   return (s1_Buy(Gi_380, Ask));
}

// DE093068E7D57EB9B205ED8E6F004AB2
int f0_52() {
   double iclose_0;
   double iclose_8;
   int shift_16;
   int shift_20;
   if (!Gi_1068) return (0);
   if (Gi_564) {
      if (Gi_1108 == 3) return (0);
      if (G_datetime_304 <= Gi_1116)
         if (Gi_1112 == 3) return (0);
   }
   if (Gi_584 || Gi_1088) {
      if (G_datetime_304 - Gi_320 < 43200.0) {
         shift_16 = iBarShift(NULL, G_timeframe_476, Gi_320 - 86400);
         shift_20 = iBarShift(NULL, G_timeframe_476, Gi_320);
      } else {
         shift_16 = iBarShift(NULL, G_timeframe_476, Gi_320);
         shift_20 = Gi_300;
      }
      iclose_8 = iClose(NULL, G_timeframe_476, shift_16);
      iclose_0 = iClose(NULL, G_timeframe_476, shift_20);
      if (iclose_0 > iclose_8) return (0);
   }
   return (s1_Sell(Gi_380, Bid));
}

// 385175AAE1E1094DD52B48C7A23B9C63
int f0_10() {
   bool Li_24;
   double Ld_28;
   if (Stealth || OrderTakeProfit() == 0.0) {
      if (Gi_480 > 0)
         if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) >= NormalizeDouble(Gi_480 * Point * Gd_340, Digits)) return (1);
   }
   if (OrderStopLoss() == 0.0) {
      if (Gi_1096 > 0)
         if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) >= NormalizeDouble(Gi_1096 * Point, Digits)) return (1);
   }
   double order_lots_0 = OrderLots();
   double Ld_8 = OrderProfit();
   double Ld_16 = OrderCommission();
   if (G_bool_616 && G_ticket_1120 >= 0) {
      Li_24 = FALSE;
      if (OrderSelect(G_ticket_1120, SELECT_BY_TICKET)) {
         Ld_8 += OrderProfit();
         Ld_16 += OrderCommission();
         if (Gd_644 > 0.0) {
            Ld_28 = Gd_644 * Gd_340 * order_lots_0 * MarketInfo(Symbol(), MODE_TICKVALUE);
            if (Ld_8 + f0_11(ConsiderCommission, Ld_16) >= Ld_28) Li_24 = TRUE;
         }
      }
      OrderSelect(G_ticket_880, SELECT_BY_TICKET);
      if (Li_24) return (1);
   }
   if (Gi_544) {
      if (G_ticket_1136 != OrderTicket()) {
         G_datetime_1140 = OrderOpenTime();
         G_ticket_1136 = OrderTicket();
      }
      if (G_icci_1016 >= 0.0 || G_irsi_984 >= 50.0) G_datetime_1140 = G_datetime_304;
      if (G_icci_1032 < G_icci_1024 && G_irsi_1000 < G_irsi_992) G_datetime_1140 = iTime(NULL, G_timeframe_476, Gi_300);
      if (G_datetime_304 - G_datetime_1140 > 3600.0 * Gd_548 && Ld_8 < 0.0) return (1);
   }
   if (Gi_540) {
      if (G_datetime_304 - OrderOpenTime() > 3600.0 * Gd_548) {
         if (G_icci_1016 > 0.0 && G_irsi_984 > 50.0 && Ld_8 + f0_11(ConsiderCommission, Ld_16) > 0.0) return (1);
         if (G_datetime_304 - OrderOpenTime() > 3600.0 * Gd_556) return (1);
      }
   }
   return (0);
}

// A08BD9EAEF05CC3612A122BEC32A5251
int f0_27() {
   bool Li_24;
   double Ld_28;
   if (Stealth || OrderTakeProfit() == 0.0) {
      if (Gi_480 > 0)
         if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) >= NormalizeDouble(Gi_480 * Point * Gd_340, Digits)) return (1);
   }
   if (OrderStopLoss() == 0.0) {
      if (Gi_1104 > 0)
         if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) >= NormalizeDouble(Gi_1104 * Point, Digits)) return (1);
   }
   double order_lots_0 = OrderLots();
   double Ld_8 = OrderProfit();
   double Ld_16 = OrderCommission();
   if (G_bool_616 && G_ticket_1124 >= 0) {
      Li_24 = FALSE;
      if (OrderSelect(G_ticket_1124, SELECT_BY_TICKET)) {
         Ld_8 += OrderProfit();
         Ld_16 += OrderCommission();
         if (Gd_644 > 0.0) {
            Ld_28 = Gd_644 * Gd_340 * order_lots_0 * MarketInfo(Symbol(), MODE_TICKVALUE);
            if (Ld_8 + f0_11(ConsiderCommission, Ld_16) >= Ld_28) Li_24 = TRUE;
         }
      }
      OrderSelect(G_ticket_884, SELECT_BY_TICKET);
      if (Li_24) return (1);
   }
   if (Gi_544) {
      if (G_ticket_1144 != OrderTicket()) {
         G_datetime_1148 = OrderOpenTime();
         G_ticket_1144 = OrderTicket();
      }
      if (G_icci_1016 <= 0.0 || G_irsi_984 <= 50.0) G_datetime_1148 = G_datetime_304;
      if (G_icci_1032 > G_icci_1024 && G_irsi_1000 > G_irsi_992) G_datetime_1148 = iTime(NULL, G_timeframe_476, Gi_300);
      if (G_datetime_304 - G_datetime_1148 > 3600.0 * Gd_548 && Ld_8 < 0.0) return (1);
   }
   if (Gi_540) {
      if (G_datetime_304 - OrderOpenTime() > 3600.0 * Gd_548) {
         if (G_icci_1016 < 0.0 && G_irsi_984 < 50.0 && Ld_8 + f0_11(ConsiderCommission, Ld_16) > 0.0) return (1);
         if (G_datetime_304 - OrderOpenTime() > 3600.0 * Gd_556) return (1);
      }
   }
   return (0);
}

// CDA405A20B8B74FAD2D7C14B6A57D9BC
int f0_42() {
   double Ld_0 = 0;
   double Ld_8 = 0;
   if (G_ilow_1080 > 0.0) {
      Gi_1096 = (Bid - G_ilow_1080 + Point * Gd_340) / Point;
      if (Gi_488 > 0 && Gi_1096 > Gi_488 * Gd_340) Gi_1096 = Gi_488 * Gd_340;
      if (Gi_1096 < Gi_492 * Gd_340) Gi_1096 = Gi_492 * Gd_340;
   } else Gi_1096 = Gi_492 * Gd_340;
   if (Gi_1096 < Gi_336) Gi_1096 = Gi_336;
   if (Stealth) Gi_1092 = Gi_484 * Gd_340;
   else Gi_1092 = Gi_480 * Gd_340;
   if (Gi_1092 < Gi_336) Gi_1092 = Gi_336;
   Ld_8 = NormalizeDouble(Bid - Gi_1096 * Point, Digits);
   Ld_0 = NormalizeDouble(Ask + Gi_1092 * Point, Digits);
   return (f0_29(OP_BUY, Gd_348, Ask, Ld_0, Ld_8, S1_Reference, Gi_500, G_global_var_388));
}

// D700C56FF5A6F5A8C2403A420D5D09BA
int f0_49() {
   double Ld_0 = 0;
   double Ld_8 = 0;
   if (G_ihigh_1072 > 0.0) {
      Gi_1104 = (G_ihigh_1072 - Ask + Point * Gd_340) / Point;
      if (Gi_488 > 0 && Gi_1104 > Gi_488 * Gd_340) Gi_1104 = Gi_488 * Gd_340;
      if (Gi_1104 < Gi_492 * Gd_340) Gi_1104 = Gi_492 * Gd_340;
   } else Gi_1104 = Gi_492 * Gd_340;
   if (Gi_1104 < Gi_336) Gi_1104 = Gi_336;
   if (Stealth) Gi_1100 = Gi_484 * Gd_340;
   else Gi_1100 = Gi_480 * Gd_340;
   if (Gi_1100 < Gi_336) Gi_1100 = Gi_336;
   Ld_8 = NormalizeDouble(Ask + Gi_1104 * Point, Digits);
   Ld_0 = NormalizeDouble(Bid - Gi_1100 * Point, Digits);
   return (f0_29(OP_SELL, Gd_348, Bid, Ld_0, Ld_8, S1_Reference, Gi_504, G_global_var_388));
}

// 00029F7D74FC0FF154CD2CA045B6059E
int f0_0() {
   double Ld_16;
   double Ld_24;
   double Ld_32;
   double Ld_40;
   int Li_48;
   double Ld_52;
   int Li_ret_60;
   double order_takeprofit_0 = OrderTakeProfit();
   double order_stoploss_8 = OrderStopLoss();
   if (order_takeprofit_0 == 0.0 || order_stoploss_8 == 0.0) {
      if (order_takeprofit_0 == 0.0) {
         if (Gi_1092 < Gi_336) Gi_1092 = Gi_336;
         order_takeprofit_0 = NormalizeDouble(Ask + Gi_1092 * Point, Digits);
      }
      if (order_stoploss_8 == 0.0) {
         if (Gi_1096 < Gi_336) Gi_1096 = Gi_336;
         order_stoploss_8 = NormalizeDouble(Bid - Gi_1096 * Point, Digits);
      }
      f0_28();
      OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_8, order_takeprofit_0, 0, Green);
   }
   if (SecureProfit && G_pips_268 > 0.0) {
      if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) >= NormalizeDouble(G_pips_268 * Point * Gd_340, Digits)) {
         if (NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), 3) <= NormalizeDouble(OrderLots() / 2.0, 3)) {
            if (G_ticket_1152 != OrderTicket()) {
               G_ticket_880 = f0_43(Yellow, G_global_var_388, 0.5);
               G_ticket_1152 = G_ticket_880;
            }
         }
      }
   }
   if (G_bool_596 && G_datetime_304 - OrderOpenTime() <= 3600.0 * Gd_600) {
      if (G_ticket_1156 != OrderTicket()) {
         Ld_16 = iHigh(NULL, PERIOD_M15, Gi_300) - iLow(NULL, PERIOD_M15, Gi_300);
         Ld_24 = iHigh(NULL, PERIOD_M15, Gi_300 + 1) - iLow(NULL, PERIOD_M15, Gi_300 + 1);
         if (Ld_16 >= 2.0 * Ld_24) {
            Ld_32 = Gi_1096 * Gd_608;
            if (Gi_488 > 0 && Ld_32 > Gi_488 * Gd_340) Ld_32 = Gi_488 * Gd_340;
            order_stoploss_8 = NormalizeDouble(order_stoploss_8 - (Ld_32 - Gi_1096) * Point, Digits);
            OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_8, order_takeprofit_0, 0, Green);
            Gi_1096 = Ld_32;
            G_ticket_1156 = OrderTicket();
         }
      }
   }
   if (G_bool_616 && G_ticket_1120 < 0) {
      Ld_40 = (OrderClosePrice() - OrderOpenPrice()) / Point;
      if (Ld_40 < (-Gd_620) * Gd_340 && G_datetime_304 - OrderOpenTime() <= 3600.0 * Gd_636) {
         Ld_52 = f0_9(OrderLots() * Gd_628, Li_48);
         Print("Opening DA order with lot: ", DoubleToStr(Ld_52, 2), " [target_profit: ", DoubleToStr(Ld_40, 1), "]");
         G_ticket_1120 = f0_29(OP_BUY, Ld_52, Ask, order_takeprofit_0, order_stoploss_8, S1_DAReference, Green, G_global_var_388);
         OrderSelect(G_ticket_880, SELECT_BY_TICKET);
      }
   }
   if (f0_10()) {
      Li_ret_60 = f0_43(Violet, G_global_var_388);
      if (Li_ret_60 < 0) {
         if (!(G_bool_616 && G_ticket_1120 >= 0)) return (Li_ret_60);
         if (OrderSelect(G_ticket_1120, SELECT_BY_TICKET)) G_ticket_1120 = f0_43(Green, G_global_var_388);
         OrderSelect(G_ticket_880, SELECT_BY_TICKET);
         return (Li_ret_60);
      }
   }
   if (Gi_496 > 0) {
      if (Bid - OrderOpenPrice() > Point * Gd_340 * Gi_496) {
         if (OrderStopLoss() < Bid - Point * Gd_340 * Gi_496 || OrderStopLoss() == 0.0) {
            f0_28();
            OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - Point * Gd_340 * Gi_496, Digits), OrderTakeProfit(), 0, Green);
         }
      }
   }
   return (OrderTicket());
}

// D4E28B06B1346B68D21CAE4C66D3C384
int f0_47() {
   double Ld_16;
   double Ld_24;
   double Ld_32;
   double Ld_40;
   int Li_48;
   double Ld_52;
   int Li_ret_60;
   double order_takeprofit_0 = OrderTakeProfit();
   double order_stoploss_8 = OrderStopLoss();
   if (order_takeprofit_0 == 0.0 || order_stoploss_8 == 0.0) {
      if (order_takeprofit_0 == 0.0) {
         if (Gi_1100 < Gi_336) Gi_1100 = Gi_336;
         order_takeprofit_0 = NormalizeDouble(Bid - Gi_1100 * Point, Digits);
      }
      if (order_stoploss_8 == 0.0) {
         if (Gi_1104 < Gi_336) Gi_1104 = Gi_336;
         order_stoploss_8 = NormalizeDouble(Ask + Gi_1104 * Point, Digits);
      }
      f0_28();
      OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_8, order_takeprofit_0, 0, Red);
   }
   if (SecureProfit && G_pips_268 > 0.0) {
      if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) >= NormalizeDouble(G_pips_268 * Point * Gd_340, Digits)) {
         if (NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), 3) <= NormalizeDouble(OrderLots() / 2.0, 3)) {
            if (G_ticket_1160 != OrderTicket()) {
               G_ticket_884 = f0_43(Yellow, G_global_var_388, 0.5);
               G_ticket_1160 = G_ticket_884;
            }
         }
      }
   }
   if (G_bool_596 && G_datetime_304 - OrderOpenTime() <= 3600.0 * Gd_600) {
      if (G_ticket_1164 != OrderTicket()) {
         Ld_16 = iHigh(NULL, PERIOD_M15, Gi_300) - iLow(NULL, PERIOD_M15, Gi_300);
         Ld_24 = iHigh(NULL, PERIOD_M15, Gi_300 + 1) - iLow(NULL, PERIOD_M15, Gi_300 + 1);
         if (Ld_16 >= 2.0 * Ld_24) {
            Ld_32 = Gi_1104 * Gd_608;
            if (Gi_488 > 0 && Ld_32 > Gi_488 * Gd_340) Ld_32 = Gi_488 * Gd_340;
            order_stoploss_8 = NormalizeDouble(order_stoploss_8 + (Ld_32 - Gi_1104) * Point, Digits);
            OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_8, order_takeprofit_0, 0, Green);
            Gi_1104 = Ld_32;
            G_ticket_1164 = OrderTicket();
         }
      }
   }
   if (G_bool_616 && G_ticket_1124 < 0) {
      Ld_40 = (OrderOpenPrice() - OrderClosePrice()) / Point;
      if (Ld_40 < (-Gd_620) * Gd_340 && G_datetime_304 - OrderOpenTime() <= 3600.0 * Gd_636) {
         Ld_52 = f0_9(OrderLots() * Gd_628, Li_48);
         Print("Opening DA order with lot: ", DoubleToStr(Ld_52, 2), " [target_profit: ", DoubleToStr(Ld_40, 1), "]");
         G_ticket_1124 = f0_29(OP_SELL, Ld_52, Bid, order_takeprofit_0, order_stoploss_8, S1_DAReference, Green, G_global_var_388);
         OrderSelect(G_ticket_884, SELECT_BY_TICKET);
      }
   }
   if (f0_27()) {
      Li_ret_60 = f0_43(Violet, G_global_var_388);
      if (Li_ret_60 < 0) {
         if (!(G_bool_616 && G_ticket_1124 >= 0)) return (Li_ret_60);
         if (OrderSelect(G_ticket_1124, SELECT_BY_TICKET)) G_ticket_1124 = f0_43(Green, G_global_var_388);
         OrderSelect(G_ticket_884, SELECT_BY_TICKET);
         return (Li_ret_60);
      }
   }
   if (Gi_496 > 0) {
      if (OrderOpenPrice() - Ask > Point * Gd_340 * Gi_496) {
         if (OrderStopLoss() > Ask + Point * Gd_340 * Gi_496 || OrderStopLoss() == 0.0) {
            f0_28();
            OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + Point * Gd_340 * Gi_496, Digits), OrderTakeProfit(), 0, Red);
         }
      }
   }
   return (OrderTicket());
}

// 08024A18CA1A9DC633799F2A519EA5B5
void f0_1() {
   if (G_ticket_880 == -2) {
      G_ticket_880 = f0_17(S1_Reference, OP_BUY);
      if (G_ticket_880 >= 0) {
         OrderSelect(G_ticket_880, SELECT_BY_TICKET);
         OrderPrint();
         Print("Strategy1: Order found:");
      }
   }
   if (G_ticket_884 == -2) {
      G_ticket_884 = f0_17(S1_Reference, OP_SELL);
      if (G_ticket_884 >= 0) {
         OrderSelect(G_ticket_884, SELECT_BY_TICKET);
         OrderPrint();
         Print("Strategy1: Order found:");
      }
   }
   if (G_bool_616) {
      if (G_ticket_1120 == -2) {
         G_ticket_1120 = f0_17(S1_DAReference, OP_BUY);
         if (G_ticket_1120 >= 0) {
            OrderSelect(G_ticket_1120, SELECT_BY_TICKET);
            OrderPrint();
            Print("Strategy1: DA Order found:");
         }
      }
      if (G_ticket_1124 == -2) {
         G_ticket_1124 = f0_17(S1_DAReference, OP_SELL);
         if (G_ticket_1124 >= 0) {
            OrderSelect(G_ticket_1124, SELECT_BY_TICKET);
            OrderPrint();
            Print("Strategy1: DA Order found:");
         }
      }
   }
   f0_55();
   Gi_872 = s1_SetRules(Gi_380, Gi_308, Gi_1088, G_icci_1016, G_irsi_984, G_irsi_1008, G_ima_1056, Point * Gd_340);
   if (Gi_1168 != Gi_872) {
      if (Gi_872) Gi_876++;
      Gi_1168 = Gi_872;
   }
   if (G_bool_616) {
      if (G_ticket_1120 >= 0) {
         if (OrderSelect(G_ticket_1120, SELECT_BY_TICKET)) {
            if (OrderCloseTime() > 0) G_ticket_1120 = -1;
            else
               if (G_ticket_880 == -1) G_ticket_1120 = f0_43(Green, G_global_var_388);
            if (G_ticket_1120 < 0) f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
         } else G_ticket_1120 = -2;
      }
      if (G_ticket_1124 >= 0) {
         if (OrderSelect(G_ticket_1124, SELECT_BY_TICKET)) {
            if (OrderCloseTime() > 0) G_ticket_1124 = -1;
            else
               if (G_ticket_884 == -1) G_ticket_1124 = f0_43(Green, G_global_var_388);
            if (G_ticket_1124 < 0) f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
         } else G_ticket_1124 = -2;
      }
   }
   if (G_ticket_880 >= 0) {
      if (OrderSelect(G_ticket_880, SELECT_BY_TICKET)) {
         if (OrderCloseTime() == 0) G_ticket_880 = f0_0();
         else G_ticket_880 = -1;
         G_order_profit_888 = OrderProfit();
         if (G_ticket_880 < 0) f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
      } else {
         G_ticket_880 = -2;
         G_order_profit_888 = 0;
      }
   }
   if (G_ticket_884 >= 0) {
      if (OrderSelect(G_ticket_884, SELECT_BY_TICKET)) {
         if (OrderCloseTime() == 0) G_ticket_884 = f0_47();
         else G_ticket_884 = -1;
         G_order_profit_896 = OrderProfit();
         if (G_ticket_884 < 0) f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
      } else {
         G_ticket_884 = -2;
         G_order_profit_896 = 0;
      }
   }
   if ((!Gi_872) || (!Gi_864) || Gi_860) return;
   if (NFA && !f0_13()) return;
   int Li_0 = f0_6();
   int Li_4 = f0_52();
   if (G_datetime_1172 != iTime(NULL, G_timeframe_476, Gi_300) && Li_0 && G_ticket_880 < 0) {
      G_ticket_880 = f0_42();
      if (G_ticket_880 < 0) return;
      G_datetime_1172 = iTime(NULL, G_timeframe_476, Gi_300);
      if (Gi_532) {
         Gi_1064 = FALSE;
         Gi_1068 = TRUE;
      }
      Gi_980++;
      return;
   }
   if (G_datetime_1176 != iTime(NULL, G_timeframe_476, Gi_300) && Li_4 && G_ticket_884 < 0) {
      G_ticket_884 = f0_49();
      if (G_ticket_884 >= 0) {
         G_datetime_1176 = iTime(NULL, G_timeframe_476, Gi_300);
         if (Gi_532) {
            Gi_1064 = TRUE;
            Gi_1068 = FALSE;
         }
         Gi_980++;
      }
   }
}

// C235AADC746022A7EF125F6D422E19B6
void f0_36() {
   HideTestIndicators(TRUE);
   if (Gi_704 || Gi_712) G_icci_1184 = iCCI(NULL, G_timeframe_652, G_period_696, PRICE_TYPICAL, Gi_300);
   if (Gi_708) G_icci_1192 = iCCI(NULL, G_timeframe_652, G_period_700, PRICE_TYPICAL, Gi_300);
   G_ihigh_1200 = iHigh(NULL, G_timeframe_652, iHighest(NULL, G_timeframe_652, MODE_HIGH, Gi_692, 1));
   G_ilow_1208 = iLow(NULL, G_timeframe_652, iLowest(NULL, G_timeframe_652, MODE_LOW, Gi_692, 1));
   if (Gi_748 > 0) {
      if (G_spread_328 > Gi_748 * Gd_340) {
         if (G_spread_332 < G_spread_328) {
            Print("Strategy2: Safe spread limit exceeded: spread = ", G_spread_328);
            if (Gi_752) Print("Strategy2: Using DayDirection filter");
         }
         Gi_1232 = TRUE;
      } else {
         if (G_spread_332 > Gi_748 * Gd_340) Print("Strategy2: Safe spread limit normalized: spread = ", G_spread_328);
         Gi_1232 = FALSE;
      }
   }
   HideTestIndicators(TRUE);
}

// 2EFD2A8CA2FD7EFCC3376034652062BB
int f0_7() {
   double iclose_0;
   double iclose_8;
   int shift_16;
   int shift_20;
   if (Gi_744 || Gi_1232) {
      if (G_datetime_304 - Gi_320 < 43200.0) {
         shift_16 = iBarShift(NULL, G_timeframe_652, Gi_320 - 86400);
         shift_20 = iBarShift(NULL, G_timeframe_652, Gi_320);
      } else {
         shift_16 = iBarShift(NULL, G_timeframe_652, Gi_320);
         shift_20 = Gi_300;
      }
      iclose_8 = iClose(NULL, G_timeframe_652, shift_16);
      iclose_0 = iClose(NULL, G_timeframe_652, shift_20);
      if (iclose_0 < iclose_8) return (0);
   }
   return (s2_Buy(Gi_380, Ask, Bid));
}

// 8262482C5DBD0014E4C469F9BD92650C
int f0_23() {
   double iclose_0;
   double iclose_8;
   int shift_16;
   int shift_20;
   if (Gi_744 || Gi_1232) {
      if (G_datetime_304 - Gi_320 < 43200.0) {
         shift_16 = iBarShift(NULL, G_timeframe_652, Gi_320 - 86400);
         shift_20 = iBarShift(NULL, G_timeframe_652, Gi_320);
      } else {
         shift_16 = iBarShift(NULL, G_timeframe_652, Gi_320);
         shift_20 = Gi_300;
      }
      iclose_8 = iClose(NULL, G_timeframe_652, shift_16);
      iclose_0 = iClose(NULL, G_timeframe_652, shift_20);
      if (iclose_0 > iclose_8) return (0);
   }
   return (s2_Sell(Gi_380, Ask, Bid));
}

// 887789993344EF86AA05B4D11B18593B
int f0_24() {
   bool Li_24;
   double Ld_28;
   double Ld_36;
   if (Stealth || OrderTakeProfit() == 0.0) {
      if (Gi_656 > 0)
         if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) >= NormalizeDouble(Gi_656 * Point * Gd_340, Digits)) return (1);
   }
   if (OrderStopLoss() == 0.0) {
      if (Gi_1240 > 0)
         if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) >= NormalizeDouble(Gi_1240 * Point, Digits)) return (1);
   }
   double order_lots_0 = OrderLots();
   double Ld_8 = OrderProfit();
   double Ld_16 = OrderCommission();
   if (G_bool_776 && G_ticket_1252 >= 0) {
      Li_24 = FALSE;
      if (OrderSelect(G_ticket_1252, SELECT_BY_TICKET)) {
         Ld_8 += OrderProfit();
         Ld_16 += OrderCommission();
         if (Gd_804 > 0.0) {
            Ld_28 = Gd_804 * Gd_340 * order_lots_0 * MarketInfo(Symbol(), MODE_TICKVALUE);
            if (Ld_8 + f0_11(ConsiderCommission, Ld_16) >= Ld_28) Li_24 = TRUE;
         }
      }
      OrderSelect(G_ticket_912, SELECT_BY_TICKET);
      if (Li_24) return (1);
   }
   if (Gi_712) {
      if (G_ticket_1260 != OrderTicket()) {
         Gi_1264 = 0;
         Gi_1268 = 0;
         G_datetime_1276 = OrderOpenTime();
         G_datetime_1272 = G_datetime_1276;
         G_ticket_1260 = OrderTicket();
         G_order_open_price_1280 = OrderOpenPrice();
      }
      if (Ask > G_order_open_price_1280) {
         Gi_1264 += G_datetime_304 - G_datetime_1272;
         G_datetime_1272 = G_datetime_304;
      } else {
         Gi_1268 += G_datetime_304 - G_datetime_1272;
         G_datetime_1272 = G_datetime_304;
      }
      Ld_36 = Ld_8 + f0_11(ConsiderCommission, Ld_16);
      if (G_datetime_304 - G_datetime_1276 > 3600.0 * Gd_716) {
         if (G_icci_1184 > 0.0 && Ld_36 > 0.0 && Gi_1264 < Gi_1268) return (1);
         if (G_icci_1184 > 100.0 && Ld_36 > 0.0) return (1);
         if (G_datetime_304 - G_datetime_1276 > 3600.0 * Gd_724 && Ld_36 > 0.0) return (1);
         if (G_datetime_304 - G_datetime_1276 > 3600.0 * Gd_732) return (1);
      }
   }
   if (Gi_740) return (Bid >= G_ihigh_1200);
   return (Bid >= G_ihigh_1216);
}

// 4B006C00F2D9CD6FABCD802D8493D595
int f0_15() {
   bool Li_24;
   double Ld_28;
   double Ld_36;
   if (Stealth || OrderTakeProfit() == 0.0) {
      if (Gi_656 > 0)
         if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) >= NormalizeDouble(Gi_656 * Point * Gd_340, Digits)) return (1);
   }
   if (OrderStopLoss() == 0.0) {
      if (Gi_1248 > 0)
         if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) >= NormalizeDouble(Gi_1248 * Point, Digits)) return (1);
   }
   double order_lots_0 = OrderLots();
   double Ld_8 = OrderProfit();
   double Ld_16 = OrderCommission();
   if (G_bool_776 && G_ticket_1256 >= 0) {
      Li_24 = FALSE;
      if (OrderSelect(G_ticket_1256, SELECT_BY_TICKET)) {
         Ld_8 += OrderProfit();
         Ld_16 += OrderCommission();
         if (Gd_804 > 0.0) {
            Ld_28 = Gd_804 * Gd_340 * order_lots_0 * MarketInfo(Symbol(), MODE_TICKVALUE);
            if (Ld_8 + f0_11(ConsiderCommission, Ld_16) >= Ld_28) Li_24 = TRUE;
         }
      }
      OrderSelect(G_ticket_916, SELECT_BY_TICKET);
      if (Li_24) return (1);
   }
   if (Gi_712) {
      if (G_ticket_1288 != OrderTicket()) {
         Gi_1292 = 0;
         Gi_1296 = 0;
         G_datetime_1304 = OrderOpenTime();
         G_datetime_1300 = G_datetime_1304;
         G_ticket_1288 = OrderTicket();
         G_order_open_price_1308 = OrderOpenPrice();
      }
      if (Bid < G_order_open_price_1308) {
         Gi_1292 += G_datetime_304 - G_datetime_1300;
         G_datetime_1300 = G_datetime_304;
      } else {
         Gi_1296 += G_datetime_304 - G_datetime_1300;
         G_datetime_1300 = G_datetime_304;
      }
      Ld_36 = Ld_8 + f0_11(ConsiderCommission, Ld_16);
      if (G_datetime_304 - G_datetime_1304 > 3600.0 * Gd_716) {
         if (G_icci_1184 < 0.0 && Ld_36 > 0.0 && Gi_1292 < Gi_1296) return (1);
         if (G_icci_1184 < -100.0 && Ld_36 > 0.0) return (1);
         if (G_datetime_304 - G_datetime_1304 > 3600.0 * Gd_724 && Ld_36 > 0.0) return (1);
         if (G_datetime_304 - G_datetime_1304 > 3600.0 * Gd_732) return (1);
      }
   }
   if (Gi_740) return (Ask <= G_ilow_1208);
   return (Ask <= G_ilow_1224);
}

// 68192AC78D91A1DD7F0DC9D19B31E322
int f0_20() {
   double Ld_0 = 0;
   double Ld_8 = 0;
   if (Gd_672 > 0.0) {
      Gi_1240 = Gd_672 * (G_ihigh_1200 - G_ilow_1208) / Point;
      if (Gi_664 > 0 && Gi_1240 > Gi_664 * Gd_340) Gi_1240 = Gi_664 * Gd_340;
      if (Gi_1240 < Gi_668 * Gd_340) Gi_1240 = Gi_668 * Gd_340;
   } else Gi_1240 = Gi_668 * Gd_340;
   if (Gi_1240 < Gi_336) Gi_1240 = Gi_336;
   if (Stealth) Gi_1236 = Gi_660 * Gd_340;
   else Gi_1236 = Gi_656 * Gd_340;
   if (Gi_1236 < Gi_336) Gi_1236 = Gi_336;
   Ld_8 = NormalizeDouble(Bid - Gi_1240 * Point, Digits);
   Ld_0 = NormalizeDouble(Ask + Gi_1236 * Point, Digits);
   return (f0_29(OP_BUY, Gd_348, Ask, Ld_0, Ld_8, S2_Reference, Gi_684, G_global_var_388));
}

// C637C3459EDBD0A93A77E10B639C4D85
int f0_40() {
   double Ld_0 = 0;
   double Ld_8 = 0;
   if (Gd_672 > 0.0) {
      Gi_1248 = Gd_672 * (G_ihigh_1200 - G_ilow_1208) / Point;
      if (Gi_664 > 0 && Gi_1248 > Gi_664 * Gd_340) Gi_1248 = Gi_664 * Gd_340;
      if (Gi_1248 < Gi_668 * Gd_340) Gi_1248 = Gi_668 * Gd_340;
   } else Gi_1248 = Gi_668 * Gd_340;
   if (Gi_1248 < Gi_336) Gi_1248 = Gi_336;
   if (Stealth) Gi_1244 = Gi_660 * Gd_340;
   else Gi_1244 = Gi_656 * Gd_340;
   if (Gi_1244 < Gi_336) Gi_1244 = Gi_336;
   Ld_8 = NormalizeDouble(Ask + Gi_1248 * Point, Digits);
   Ld_0 = NormalizeDouble(Bid - Gi_1244 * Point, Digits);
   return (f0_29(OP_SELL, Gd_348, Bid, Ld_0, Ld_8, S2_Reference, Gi_688, G_global_var_388));
}

// BB977064410CDD89829270D6666A42B4
int f0_33() {
   double Ld_16;
   double Ld_24;
   double Ld_32;
   double Ld_40;
   int Li_48;
   double Ld_52;
   int Li_ret_60;
   double order_takeprofit_0 = OrderTakeProfit();
   double order_stoploss_8 = OrderStopLoss();
   if (order_takeprofit_0 == 0.0 || order_stoploss_8 == 0.0) {
      if (order_takeprofit_0 == 0.0) {
         if (Gi_1236 < Gi_336) Gi_1236 = Gi_336;
         order_takeprofit_0 = NormalizeDouble(Ask + Gi_1236 * Point, Digits);
      }
      if (order_stoploss_8 == 0.0) {
         if (Gi_1240 < Gi_336) Gi_1240 = Gi_336;
         order_stoploss_8 = NormalizeDouble(Bid - Gi_1240 * Point, Digits);
      }
      f0_28();
      OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_8, order_takeprofit_0, 0, Green);
   }
   if (SecureProfit && G_pips_276 > 0.0) {
      if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) >= NormalizeDouble(G_pips_276 * Point * Gd_340, Digits)) {
         if (G_ticket_1316 != OrderTicket()) {
            G_ticket_912 = f0_43(Yellow, G_global_var_388, 0.5);
            G_ticket_1316 = G_ticket_912;
         }
      }
   }
   if (G_bool_756 && G_datetime_304 - OrderOpenTime() <= 3600.0 * Gd_760) {
      if (G_ticket_1320 != OrderTicket()) {
         Ld_16 = iHigh(NULL, PERIOD_M15, Gi_300) - iLow(NULL, PERIOD_M15, Gi_300);
         Ld_24 = iHigh(NULL, PERIOD_M15, Gi_300 + 1) - iLow(NULL, PERIOD_M15, Gi_300 + 1);
         if (Ld_16 >= 2.0 * Ld_24) {
            Ld_32 = Gi_1240 * Gd_768;
            if (Gi_664 > 0 && Ld_32 > Gi_664 * Gd_340) Ld_32 = Gi_664 * Gd_340;
            order_stoploss_8 = NormalizeDouble(order_stoploss_8 - (Ld_32 - Gi_1240) * Point, Digits);
            OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_8, order_takeprofit_0, 0, Green);
            Gi_1240 = Ld_32;
            G_ticket_1320 = OrderTicket();
         }
      }
   }
   if (G_bool_776 && G_ticket_1252 < 0) {
      Ld_40 = (OrderClosePrice() - OrderOpenPrice()) / Point;
      if (Ld_40 < (-Gd_780) * Gd_340 && G_datetime_304 - OrderOpenTime() <= 3600.0 * Gd_796) {
         Ld_52 = f0_9(OrderLots() * Gd_788, Li_48);
         Print("Opening DA order with lot: ", DoubleToStr(Ld_52, 2), " [target_profit: ", DoubleToStr(Ld_40, 1), "]");
         G_ticket_1252 = f0_29(OP_BUY, Ld_52, Ask, order_takeprofit_0, order_stoploss_8, S2_DAReference, Green, G_global_var_388);
         OrderSelect(G_ticket_912, SELECT_BY_TICKET);
      }
   }
   if (f0_24()) {
      Li_ret_60 = f0_43(Violet, G_global_var_388);
      if (Li_ret_60 < 0) {
         if (!(G_bool_776 && G_ticket_1252 >= 0)) return (Li_ret_60);
         if (OrderSelect(G_ticket_1252, SELECT_BY_TICKET)) G_ticket_1252 = f0_43(Green, G_global_var_388);
         OrderSelect(G_ticket_912, SELECT_BY_TICKET);
         return (Li_ret_60);
      }
   }
   if (Gi_680 > 0) {
      if (Bid - OrderOpenPrice() > Point * Gd_340 * Gi_680) {
         if (OrderStopLoss() < Bid - Point * Gd_340 * Gi_680 || OrderStopLoss() == 0.0) {
            f0_28();
            OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - Point * Gd_340 * Gi_680, Digits), OrderTakeProfit(), 0, Green);
         }
      }
   }
   return (OrderTicket());
}

// D320CE5ABDC606354499001D0A244563
int f0_46() {
   double Ld_16;
   double Ld_24;
   double Ld_32;
   double Ld_40;
   int Li_48;
   double Ld_52;
   int Li_ret_60;
   double order_takeprofit_0 = OrderTakeProfit();
   double order_stoploss_8 = OrderStopLoss();
   if (order_takeprofit_0 == 0.0 || order_stoploss_8 == 0.0) {
      if (order_takeprofit_0 == 0.0) {
         if (Gi_1244 < Gi_336) Gi_1244 = Gi_336;
         order_takeprofit_0 = NormalizeDouble(Bid - Gi_1244 * Point, Digits);
      }
      if (order_stoploss_8 == 0.0) {
         if (Gi_1248 < Gi_336) Gi_1248 = Gi_336;
         order_stoploss_8 = NormalizeDouble(Ask + Gi_1248 * Point, Digits);
      }
      f0_28();
      OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_8, order_takeprofit_0, 0, Red);
   }
   if (SecureProfit && G_pips_276 > 0.0) {
      if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) >= NormalizeDouble(G_pips_276 * Point * Gd_340, Digits)) {
         if (G_ticket_1324 != OrderTicket()) {
            G_ticket_916 = f0_43(Yellow, G_global_var_388, 0.5);
            G_ticket_1324 = G_ticket_916;
         }
      }
   }
   if (G_bool_756 && G_datetime_304 - OrderOpenTime() <= 3600.0 * Gd_760) {
      if (G_ticket_1328 != OrderTicket()) {
         Ld_16 = iHigh(NULL, PERIOD_M15, Gi_300) - iLow(NULL, PERIOD_M15, Gi_300);
         Ld_24 = iHigh(NULL, PERIOD_M15, Gi_300 + 1) - iLow(NULL, PERIOD_M15, Gi_300 + 1);
         if (Ld_16 >= 2.0 * Ld_24) {
            Ld_32 = Gi_1248 * Gd_768;
            if (Gi_664 > 0 && Ld_32 > Gi_664 * Gd_340) Ld_32 = Gi_664 * Gd_340;
            order_stoploss_8 = NormalizeDouble(order_stoploss_8 + (Ld_32 - Gi_1248) * Point, Digits);
            OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_8, order_takeprofit_0, 0, Green);
            Gi_1248 = Ld_32;
            G_ticket_1328 = OrderTicket();
         }
      }
   }
   if (G_bool_776 && G_ticket_1256 < 0) {
      Ld_40 = (OrderOpenPrice() - OrderClosePrice()) / Point;
      if (Ld_40 < (-Gd_780) * Gd_340 && G_datetime_304 - OrderOpenTime() <= 3600.0 * Gd_796) {
         Ld_52 = f0_9(OrderLots() * Gd_788, Li_48);
         Print("Opening DA order with lot: ", DoubleToStr(Ld_52, 2), " [target_profit: ", DoubleToStr(Ld_40, 1), "]");
         G_ticket_1256 = f0_29(OP_SELL, Ld_52, Bid, order_takeprofit_0, order_stoploss_8, S2_DAReference, Green, G_global_var_388);
         OrderSelect(G_ticket_916, SELECT_BY_TICKET);
      }
   }
   if (f0_15()) {
      Li_ret_60 = f0_43(Violet, G_global_var_388);
      if (Li_ret_60 < 0) {
         if (!(G_bool_776 && G_ticket_1256 >= 0)) return (Li_ret_60);
         if (OrderSelect(G_ticket_1256, SELECT_BY_TICKET)) G_ticket_1256 = f0_43(Green, G_global_var_388);
         OrderSelect(G_ticket_916, SELECT_BY_TICKET);
         return (Li_ret_60);
      }
   }
   if (Gi_680 > 0) {
      if (OrderOpenPrice() - Ask > Point * Gd_340 * Gi_680) {
         if (OrderStopLoss() > Ask + Point * Gd_340 * Gi_680 || OrderStopLoss() == 0.0) {
            f0_28();
            OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + Point * Gd_340 * Gi_680, Digits), OrderTakeProfit(), 0, Red);
         }
      }
   }
   return (OrderTicket());
}

// C55FDA774FDB0F487FE6C1A8E0FF0476
void f0_39() {
   if (G_ticket_912 == -2) {
      G_ticket_912 = f0_17(S2_Reference, OP_BUY);
      if (G_ticket_912 >= 0) {
         OrderSelect(G_ticket_912, SELECT_BY_TICKET);
         OrderPrint();
         Print("Strategy2: Order found:");
      }
   }
   if (G_ticket_916 == -2) {
      G_ticket_916 = f0_17(S2_Reference, OP_SELL);
      if (G_ticket_916 >= 0) {
         OrderSelect(G_ticket_916, SELECT_BY_TICKET);
         OrderPrint();
         Print("Strategy2: Order found:");
      }
   }
   if (G_bool_776) {
      if (G_ticket_1252 == -2) {
         G_ticket_1252 = f0_17(S2_DAReference, OP_BUY);
         if (G_ticket_1252 >= 0) {
            OrderSelect(G_ticket_1252, SELECT_BY_TICKET);
            OrderPrint();
            Print("Strategy1: DA Order found:");
         }
      }
      if (G_ticket_1256 == -2) {
         G_ticket_1256 = f0_17(S2_DAReference, OP_SELL);
         if (G_ticket_1256 >= 0) {
            OrderSelect(G_ticket_1256, SELECT_BY_TICKET);
            OrderPrint();
            Print("Strategy1: DA Order found:");
         }
      }
   }
   f0_36();
   Gi_904 = s2_SetRules(Gi_380, Gi_308, Gi_1232, G_icci_1184, G_icci_1192, G_ilow_1208, G_ihigh_1200);
   if (Gi_1332 != Gi_904) {
      if (Gi_904) {
         G_order_profit_920 = 0;
         G_order_profit_928 = 0;
         Gi_908++;
      }
      Gi_1332 = Gi_904;
   }
   if (G_bool_776) {
      if (G_ticket_1252 >= 0) {
         if (OrderSelect(G_ticket_1252, SELECT_BY_TICKET)) {
            if (OrderCloseTime() > 0) G_ticket_1252 = -1;
            else
               if (G_ticket_912 == -1) G_ticket_1252 = f0_43(Green, G_global_var_388);
            if (G_ticket_1252 < 0) f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
         } else G_ticket_1252 = -2;
      }
      if (G_ticket_1256 >= 0) {
         if (OrderSelect(G_ticket_1256, SELECT_BY_TICKET)) {
            if (OrderCloseTime() > 0) G_ticket_1256 = -1;
            else
               if (G_ticket_916 == -1) G_ticket_1256 = f0_43(Green, G_global_var_388);
            if (G_ticket_1256 < 0) f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
         } else G_ticket_1256 = -2;
      }
   }
   if (G_ticket_912 >= 0) {
      if (OrderSelect(G_ticket_912, SELECT_BY_TICKET)) {
         if (OrderCloseTime() == 0) G_ticket_912 = f0_33();
         else G_ticket_912 = -1;
         G_order_profit_920 = OrderProfit();
         if (G_ticket_912 < 0) f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
      } else {
         G_ticket_912 = -2;
         G_order_profit_920 = 0;
      }
   }
   if (G_ticket_916 >= 0) {
      if (OrderSelect(G_ticket_916, SELECT_BY_TICKET)) {
         if (OrderCloseTime() == 0) G_ticket_916 = f0_46();
         else G_ticket_916 = -1;
         G_order_profit_928 = OrderProfit();
         if (G_ticket_916 < 0) f0_31(OrderOpenPrice(), OrderClosePrice(), OrderType());
      } else {
         G_ticket_916 = -2;
         G_order_profit_928 = 0;
      }
   }
   if ((!Gi_904) || (!Gi_864) || Gi_860) return;
   if (NFA && !f0_13()) return;
   int Li_0 = f0_7();
   int Li_4 = f0_23();
   if (G_datetime_1336 != iTime(NULL, G_timeframe_652, Gi_300) && Li_0 && G_ticket_912 < 0 && G_order_profit_920 >= 0.0) {
      G_ticket_912 = f0_20();
      if (G_ticket_912 < 0) return;
      G_datetime_1336 = iTime(NULL, G_timeframe_652, Gi_300);
      G_ihigh_1216 = G_ihigh_1200;
      G_ilow_1224 = G_ilow_1208;
      G_order_profit_928 = 0;
      Gi_1180++;
      return;
   }
   if (G_datetime_1340 != iTime(NULL, G_timeframe_652, Gi_300) && Li_4 && G_ticket_916 < 0 && G_order_profit_928 >= 0.0) {
      G_ticket_916 = f0_40();
      if (G_ticket_916 >= 0) {
         G_datetime_1340 = iTime(NULL, G_timeframe_652, Gi_300);
         G_ihigh_1216 = G_ihigh_1200;
         G_ilow_1224 = G_ilow_1208;
         G_order_profit_920 = 0;
         Gi_1180++;
      }
   }
}

// 63A6A88C066880C5AC42394A22803CA6
void f0_19(bool Ai_0) {
   double Lda_4[1];
   if (Ai_0) RefreshRates();
   G_datetime_304 = TimeCurrent();
   Gi_376 = GetParams(Gi_380, G_datetime_304, AutoServerGmtOffset, Lda_4);
   switch (Gi_376) {
   case 4:
      if (!AutoLocalGmtOffset) {
         Gi_376 = FALSE;
         break;
      }
   case 1:
   case 2:
      GmtOffset = Lda_4[0];
   }
   Gi_308 = G_datetime_304 - 3600.0 * GmtOffset;
   G_hour_312 = TimeHour(Gi_308);
   Gi_320 = G_datetime_304 - 3600.0 * G_hour_312 - 60 * TimeMinute(Gi_308) - TimeSeconds(Gi_308);
   Gi_unused_324 = Gi_320 - 3600.0 * GmtOffset;
   G_spread_328 = MarketInfo(Symbol(), MODE_SPREAD);
   Gi_336 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   Gd_340 = 0.0001 / Point;
   if (Digits < 4) Gd_340 = 100.0 * Gd_340;
}

// 946D84080DA399137CD6BD078C9F227B
int f0_26() {
   int Li_ret_0;
   if (RiskLevel > 0.0) {
      Gd_348 = f0_51(RiskLevel, AccountFreeMargin(), Li_ret_0);
      if (RecoveryMode) {
         Gi_392 = f0_4();
         if (Gi_392) Gd_348 = f0_9(2.0 * Gd_348, Li_ret_0);
      }
   } else Gd_348 = f0_9(LotSize, Li_ret_0);
   return (Li_ret_0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_0;
   if (!Gi_840) {
      f0_5(0, Gi_828, Gi_824);
      Gi_816 = 0;
      Gi_812 = 0;
      f0_37(Gs_452, TextColor2);
      f0_35();
      f0_37("Error:");
      f0_37("Dll and Expert versions mismatch", TextColor2, Gi_816, Gi_812 - 1, 49);
      return (0);
   }
   if ((!Gi_284) && (!Gi_288)) return (0);
   Gi_368 = GetState();
   if (Bars < 100) {
      Print("Bars less than 100");
      return (0);
   }
   if (!IsTesting()) f0_22();
   G_spread_332 = G_spread_328;
   f0_19(0);
   if (Gi_364) {
      Gi_364 = FALSE;
      Li_0 = f0_32();
      Print("Orders in history: ", Li_0, " profit made: ", DoubleToStr(Gd_844, 0), " pips");
   }
   int Li_4 = f0_26();
   double Ld_8 = NormalizeDouble(MarketInfo(Symbol(), MODE_MARGINREQUIRED) * Gd_348, 8);
   Gi_860 = NormalizeDouble(AccountFreeMargin(), 8) < Ld_8;
   Gi_864 = IsTradeTime(Gi_380, Gi_308, Gi_292, RemoteSafetyMode);
   if (RemoteSafetyMode && (!IsTesting()) && Gi_368 & 262144 > 0) Gi_864 = FALSE;
   if (NFA) f0_8();
   if (Gi_284) f0_1();
   f0_19(1);
   Li_4 = f0_26();
   Gi_860 = NormalizeDouble(AccountFreeMargin(), 8) < Ld_8;
   if (Gi_288) f0_39();
   if (IsTesting() && (!IsVisualMode())) return (0);
   f0_5(0, Gi_828, Gi_824);
   Gi_816 = 0;
   Gi_812 = 0;
   f0_37(Gs_452, TextColor2);
   f0_35();
   f0_41(Gi_368 | Gi_372);
   LinksBegin(Gi_380);
   int str_len_16 = StringLen(Gs_404);
   int str_len_20 = StringLen(Gs_412);
   if (str_len_16 > 1) f0_37(Gs_404);
   if (str_len_20 > 0) f0_44(Gs_412, TextColor2, Gi_816, Gi_812 - 1, 7 * (str_len_16 + 1));
   f0_35();
   str_len_16 = StringLen(Gs_420);
   str_len_20 = StringLen(Gs_428);
   if (str_len_16 > 1) f0_37(Gs_420);
   if (str_len_20 > 0) f0_44(Gs_428, TextColor2, Gi_816, Gi_812 - 1, 7 * (str_len_16 + 1));
   if (str_len_16 > 1 || str_len_20 > 0) f0_35();
   f0_37(Gs_460);
   f0_37(Gs_468, TextColor2, Gi_816, Gi_812 - 1, 7 * (StringLen(Gs_460) + 1));
   f0_35();
   string Ls_24 = DoubleToStr(GmtOffset, 1);
   if (!IsTesting()) Ls_24 = StringConcatenate(Ls_24, " (", f0_25(Gi_376), ")");
   f0_37("ServerTime:");
   f0_37(TimeToStr(G_datetime_304), TextColor2, Gi_816, Gi_812 - 1, 84);
   f0_37("UtcTime:");
   f0_37(TimeToStr(Gi_308), TextColor2, Gi_816, Gi_812 - 1, 63);
   f0_37("GmtOffset:");
   f0_37(Ls_24, TextColor2, Gi_816, Gi_812 - 1, 77);
   f0_35();
   f0_37("Lot:");
   f0_37(DoubleToStr(Gd_348, 2), TextColor2, Gi_816, Gi_812 - 1, 35);
   switch (Li_4) {
   case 1:
      f0_37("Maximum Lot size exeeded!");
      break;
   case -1:
      f0_37("Minimum Lot size exeeded!");
   }
   if (Gi_392) f0_37("Recovery Mode is Active!");
   f0_37("Spread:");
   f0_37(StringConcatenate(DoubleToStr(G_spread_328 / Gd_340, 1), " (", G_spread_328, " pips)"), TextColor2, Gi_816, Gi_812 - 1, 56);
   f0_37("Leverage:");
   f0_37(AccountLeverage() + ":1", TextColor2, Gi_816, Gi_812 - 1, 70);
   if (AccountLeverage() < 100) {
      f0_37("Warning:");
      f0_37("Your account leverage is lower than 1:100,", TextColor2, Gi_816, Gi_812 - 1, 63);
      f0_37("the lot size will be reduced to prevent a loss.", TextColor2, Gi_816, Gi_812, 70);
   }
   if (Gi_1344 != Gi_860) {
      if (Gi_860) Print("Not enough money! Available margin = ", DoubleToStr(AccountFreeMargin(), 2), ", Required margin = ", DoubleToStr(Ld_8, 2));
      Gi_1344 = Gi_860;
   }
   if (Gi_860) {
      f0_35();
      f0_37("Not enough money!");
      f0_37("Available margin =");
      f0_37(DoubleToStr(AccountFreeMargin(), 2), TextColor2, Gi_816, Gi_812 - 1, 133);
      f0_37("Required margin =");
      f0_37(DoubleToStr(Ld_8, 2), TextColor2, Gi_816, Gi_812 - 1, 126);
   }
   f0_35();
   if (IsTesting()) f0_37("Backtesting");
   else {
      GetStatus(Gi_380, G_spread_328, Gd_348, Gd_396, AccountBalance());
      Gd_396 = 0;
   }
   if (Gi_284 && Gi_564) {
      if (Gi_1108 == 0) f0_37("Analyzing market");
      else f0_37(f0_38(Gi_1108) + " detected");
      if (G_datetime_304 <= Gi_1116 && Gi_1108 != Gi_1112 && Gi_1112 != 0) f0_37(f0_38(Gi_1112) + " fading: " + TimeToStr(Gi_1116 - G_datetime_304, TIME_SECONDS));
   } else f0_37(f0_2(Gi_872 || Gi_904, "Running", "Collecting Data"));
   if (NFA && G_count_868 > 0) {
      f0_35();
      f0_37("Waiting for trades to close:");
      f0_37(G_count_868, TextColor2, Gi_816, Gi_812 - 1, 203);
   }
   if (G_ticket_880 >= 0 || G_ticket_884 >= 0 || G_ticket_912 >= 0 || G_ticket_916 >= 0) {
      f0_35();
      if (G_ticket_880 >= 0) f0_37("Strategy1: Long position open");
      if (G_ticket_884 >= 0) f0_37("Strategy1: Short position open");
      if (G_ticket_912 >= 0) f0_37("Strategy2: Long position open");
      if (G_ticket_916 >= 0) f0_37("Strategy2: Short position open");
   }
   str_len_16 = StringLen(Gs_436);
   str_len_20 = StringLen(Gs_444);
   if (str_len_16 > 1 || str_len_20 > 0) f0_35();
   if (str_len_16 > 1) f0_37(Gs_436);
   if (str_len_20 > 0) f0_44(Gs_444, TextColor2, Gi_816, Gi_812 - 1, 7 * (str_len_16 + 1));
   f0_48(Gi_816, Gi_820);
   Gi_820 = Gi_816 - 1;
   WindowRedraw();
   LinksEnd(Gi_380);
   return (0);
}

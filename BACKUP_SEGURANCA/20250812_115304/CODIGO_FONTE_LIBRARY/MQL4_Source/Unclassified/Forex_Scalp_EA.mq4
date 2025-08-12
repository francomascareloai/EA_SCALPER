#property copyright "Recommended broker FOREX4YOU.COM: Spread From 0.1 pip, Leverage 1:1000";
#property link "http://bit.ly/brokercent";
#property version "";
#property strict

#import "stdlib.ex4"

string ErrorDescription(int);

#import

extern string RobotName = "Forex Scalping EA";
extern long License = 12345;
extern string BrokerSettings = "Maximum Spread & Slippage";
extern double MaxSpread = 5;
extern double MaxSlippage = 5;
extern string TradingTimes = "20-22 GMT";
extern int HourStart = 20;
extern int HourEnd = 22;
extern string MoneyManagement = "If Risk False Use Lots";
extern double Lots = 0.1;
extern bool UseRisk;
extern double MaxRisk = 2;
extern string OrderManagement = "Manage Orders";
extern int StopLoss = 50;
extern int TakeProfit = 100;

int Ii_001C;
double Id_0028;
int returned_i;
long Gl_0000;
long returned_l;
bool Ib_0008;
double Id_0000;
string Is_0010;
int Ii_0020;
int Ii_0024;
int Ii_0030;
int Ii_0034;
int Ii_0038;
int Gi_0001;
long Gl_0002;
int Gi_0003;
int Gi_0004;
int Gi_0005;
int Gi_0006;
int Gi_0007;
int Gi_0008;
int Gi_0009;
long Gl_000A;
bool Gb_000A;
double Ind_000;
double Gd_000A;
bool returned_b;
int Gi_000B;
int Gi_000A;
int Gi_000C;
int Gi_000D;
double Gd_000E;
double Gd_000F;
int Gi_0010;
bool Gb_0010;
double Gd_0010;
long Gl_0010;
int Gi_0011;
int Gi_0012;
int Gi_0013;
double Gd_0014;
double Gd_0015;
int Gi_0016;
int Gi_0000;
double Gd_0000;
double Gd_0001;
int Gi_0002;
bool Gb_0003;
double Gd_0004;
bool Gb_0004;
double Ind_004;
bool Gb_0000;
double Ind_002;
double Ind_001;
double returned_double;

int init()
{
   int Li_FFFC;
   
   Id_0000 = 1;
   Ib_0008 = false;
   Is_0010 = "\n";
   Ii_001C = 4;
   Ii_0020 = 0;
   Ii_0024 = 0;
   Id_0028 = 1;
   Ii_0030 = 0;
   Ii_0034 = 0;
   Ii_0038 = 0;
   
   Li_FFFC = 0;
   Ii_001C = _Digits;
   Id_0028 = MaxRisk;
   HideTestIndicators(true);
   Comment("");
   Li_FFFC = 0;
   return 0;
}

int start()
{
   int Li_FFFC;
   long Ll_FFF0;

   Li_FFFC = 0;
   Ll_FFF0 = 0;
   Gl_0000 = AccountInfoInteger(ACCOUNT_LOGIN) * 2;
   Ll_FFF0 = Gl_0000 + 199;
   if (returned_i == 14) { 
   Alert("Wrong license!");
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   if (Bars < 10) { 
   Comment("Not enough bars");
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   if (Ib_0008 == true) { 
   Comment("EA Terminated.");
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   OnEveryTick1();
   Li_FFFC = 0;
   
   return Li_FFFC;
}

int deinit()
{
   int Li_FFFC;

   Li_FFFC = 0;
   Li_FFFC = 0;
   return 0;
}

void OnEveryTick1()
{
   string tmp_str0000;
   string tmp_str0001;

   Gl_0000 = 0;
   Gi_0001 = 0;
   Gl_0002 = 0;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = 0;
   int Li_FF10[][2];
   Gi_0006 = 0;
   Gi_0007 = 0;
   Gi_0008 = 0;
   int Li_FDEC[][2];
   Gi_0009 = 0;
   if (Ii_001C == 3 || Ii_001C == 5) { 
   
   Id_0000 = 10;
   } 

   if ((Ask < iBands(NULL, 0, 20, 2, 0, 4, 2, 0)) && (iATR(NULL, 0, 14, 0) < ((Id_0000 * 15) * _Point))) { 
   Gl_0000 = TimeGMT();
   Gi_0001 = TimeHour(Gl_0000);
   TimeMinute(Gl_0000);
   if ((HourStart < HourEnd && Gi_0001 >= HourStart && Gi_0001 < HourEnd)
   || (HourStart > HourEnd && (Gi_0001 < HourEnd || Gi_0001 >= HourStart))) {
   
   LOOB();
   }} 
   if ((Bid > iBands(NULL, 0, 20, 2, 0, 4, 1, 0)) && (iATR(NULL, 0, 14, 0) < ((Id_0000 * 15) * _Point))) { 
   Gl_0002 = TimeGMT();
   Gi_0003 = TimeHour(Gl_0002);
   TimeMinute(Gl_0002);
   if ((HourStart < HourEnd && Gi_0003 >= HourStart && Gi_0003 < HourEnd)
   || (HourStart > HourEnd && (Gi_0003 < HourEnd || Gi_0003 >= HourStart))) {
   
   LOOS();
   }} 
   if ((Ask < iMA(NULL, 0, 20, 0, 0, 4, 0))) { 
   Gd_000A = (Ask - Bid);
   if ((Gd_000A <= ((MaxSpread * Id_0000) * _Point))) { 
   Gi_0004 = OrdersTotal();
   Gi_0005 = 0;
   ArrayFree(Li_FF10);
   ArrayResize(Li_FF10, 30);
   Gi_0006 = 0;
   if (Gi_0004 > 0) { 
   do { 
   if (OrderSelect(Gi_0006, 0, 0)) {
   if (OrderType() == OP_SELL && OrderSymbol() == _Symbol && OrderMagicNumber() == 2) {
   
   Gl_000A = OrderOpenTime();
   
   Li_FF10[Gi_0005, 0] = (int)Gl_000A;
   Gi_000A = OrderTicket();
   
   Li_FF10[Gi_0005, 1] = Gi_000A;
   Gi_0005 = Gi_0005 + 1;
   }}
   Gi_0006 = Gi_0006 + 1;
   } while (Gi_0006 < Gi_0004); 
   } 
   if (Gi_0005 > 1) { 
   ArrayResize(Li_FF10, Gi_0005, 0);
   ArraySort(Li_FF10, 0, 0, 1);
   } 
   Gi_0006 = 0;
   if (Gi_0005 > 0) { 
   do { 
   
   if (OrderSelect(Li_FF10[Gi_0006, 1], 1, 0) == true && OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), (int)MaxSlippage, 255) == 0) { 
   tmp_str0000 = ErrorDescription(GetLastError());
   Print("OrderClose() error - ", tmp_str0000);
   } 
   Gi_0006 = Gi_0006 + 1;
   } while (Gi_0006 < Gi_0005); 
   }} 
   ArrayFree(Li_FF10);
   } 
   if ((Bid <= iMA(NULL, 0, 20, 0, 0, 4, 0))) return; 
   Gd_0010 = (Ask - Bid);
   if ((Gd_0010 <= ((MaxSpread * Id_0000) * _Point))) { 
   Gi_0007 = OrdersTotal();
   Gi_0008 = 0;
   ArrayFree(Li_FDEC);
   ArrayResize(Li_FDEC, 30);
   Gi_0009 = 0;
   if (Gi_0007 > 0) { 
   do { 
   if (OrderSelect(Gi_0009, 0, 0)) {
   if (OrderType() == OP_BUY && OrderSymbol() == _Symbol && OrderMagicNumber() == 1) {
   
   Gl_0010 = OrderOpenTime();
   
   Li_FDEC[Gi_0008, 0] = (int)Gl_0010;
   Gi_0010 = OrderTicket();
   
   Li_FDEC[Gi_0008, 1] = Gi_0010;
   Gi_0008 = Gi_0008 + 1;
   }}
   Gi_0009 = Gi_0009 + 1;
   } while (Gi_0009 < Gi_0007); 
   } 
   if (Gi_0008 > 1) { 
   ArrayResize(Li_FDEC, Gi_0008, 0);
   ArraySort(Li_FDEC, 0, 0, 1);
   } 
   Gi_0009 = 0;
   if (Gi_0008 > 0) { 
   do { 
   
   if (OrderSelect(Li_FDEC[Gi_0009, 1], 1, 0) == true && OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), (int)MaxSlippage, 255) == 0) { 
   tmp_str0001 = ErrorDescription(GetLastError());
   Print("OrderClose() error - ", tmp_str0001);
   } 
   Gi_0009 = Gi_0009 + 1;
   } while (Gi_0009 < Gi_0008); 
   }} 
   ArrayFree(Li_FDEC);
   
}

void LOOB()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   int Li_FFFC;
   int Li_FFF8;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Gd_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   Gb_0003 = false;
   Li_FFFC = 0;
   Li_FFF8 = OrdersTotal() - 1;
   if (Li_FFF8 >= 0) { 
   do { 
   if (OrderSelect(Li_FFF8, 0, 0)) {
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == 1) {
   Li_FFFC = Li_FFFC + 1;
   }}
   else{
   tmp_str0000 = ErrorDescription(GetLastError());
   Print("OrderSend() error - ", tmp_str0000);
   }
   Li_FFF8 = Li_FFF8 - 1;
   } while (Li_FFF8 >= 0); 
   } 
   if (Li_FFFC >= 1) return; 
   if (UseRisk == 0) { 
   Gd_0004 = (Ask - Bid);
   if ((Gd_0004 <= ((MaxSpread * Id_0000) * _Point))) { 
   Gd_0004 = ((StopLoss * Id_0000) * _Point);
   Gd_0000 = (Ask - Gd_0004);
   if (StopLoss == 0) { 
   Gd_0000 = 0;
   } 
   Gd_0001 = (((TakeProfit * Id_0000) * _Point) + Ask);
   if (TakeProfit == 0) { 
   Gd_0001 = 0;
   } 
   Gi_0002 = -1;
   Gi_0002 = OrderSend(_Symbol, 0, Lots, Ask, (int)MaxSlippage, 0, 0, RobotName, 1, 0, 16711680);
   if (Gi_0002 > -1) {
   if (OrderSelect(Gi_0002, 1, 0)) { 
   Gb_0003 = OrderModify(OrderTicket(), OrderOpenPrice(), Gd_0000, Gd_0001, 0, 16711680);
   } 
   if (Gb_0003 == 0) {
   tmp_str0001 = ErrorDescription(GetLastError());
   Print("OrderModify() error - ", tmp_str0001);
   }}
   else{
   tmp_str0002 = ErrorDescription(GetLastError());
   Print("OrderSend() error - ", tmp_str0002);
   }}} 
   if (UseRisk != true) return; 
   BOR();
   
}

void LOOS()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   int Li_FFFC;
   int Li_FFF8;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Gd_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   Gb_0003 = false;
   Li_FFFC = 0;
   Li_FFF8 = OrdersTotal() - 1;
   if (Li_FFF8 >= 0) { 
   do { 
   if (OrderSelect(Li_FFF8, 0, 0)) {
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == 2) {
   Li_FFFC = Li_FFFC + 1;
   }}
   else{
   tmp_str0000 = ErrorDescription(GetLastError());
   Print("OrderSend() error - ", tmp_str0000);
   }
   Li_FFF8 = Li_FFF8 - 1;
   } while (Li_FFF8 >= 0); 
   } 
   if (Li_FFFC >= 1) return; 
   if (UseRisk == 0) { 
   Gd_0004 = (Ask - Bid);
   if ((Gd_0004 <= ((MaxSpread * Id_0000) * _Point))) { 
   Gd_0000 = (((StopLoss * Id_0000) * _Point) + Bid);
   if (StopLoss == 0) { 
   Gd_0000 = 0;
   } 
   Gd_0004 = ((TakeProfit * Id_0000) * _Point);
   Gd_0001 = (Bid - Gd_0004);
   if (TakeProfit == 0) { 
   Gd_0001 = 0;
   } 
   Gi_0002 = -1;
   Gi_0002 = OrderSend(_Symbol, 1, Lots, Bid, (int)MaxSlippage, 0, 0, RobotName, 2, 0, 255);
   if (Gi_0002 > -1) {
   if (OrderSelect(Gi_0002, 1, 0)) { 
   Gb_0003 = OrderModify(OrderTicket(), OrderOpenPrice(), Gd_0000, Gd_0001, 0, 255);
   } 
   if (Gb_0003 == 0) {
   tmp_str0001 = ErrorDescription(GetLastError());
   Print("OrderModify() error - ", tmp_str0001);
   }}
   else{
   tmp_str0002 = ErrorDescription(GetLastError());
   Print("OrderSend() error - ", tmp_str0002);
   }}} 
   if (UseRisk != true) return; 
   SOR();
   
}

void BOR()
{
   string tmp_str0000;
   string tmp_str0001;
   double Ld_FFF8;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
   double Ld_FFD0;
   int Li_FFCC;
   double Ld_FFC0;
   double Ld_FFB8;
   int Li_FFB4;
   bool Lb_FFB3;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Ld_FFD8 = 0;
   Ld_FFD0 = 0;
   Li_FFCC = 0;
   Ld_FFC0 = 0;
   Ld_FFB8 = 0;
   Li_FFB4 = 0;
   Lb_FFB3 = false;
   Gd_0000 = (Ask - Bid);
   if ((Gd_0000 > ((MaxSpread * Id_0000) * _Point))) return; 
   Ld_FFF8 = MarketInfo(_Symbol, MODE_LOTSIZE);
   Ld_FFF0 = 1000;
   Ld_FFE8 = ((AccountFreeMargin() / 100) * Id_0028);
   if (StopLoss == 0) { 
   Print("OrderSend() error - stoploss can not be zero");
   } 
   Gd_0000 = (Ld_FFE8 / StopLoss);
   Ld_FFE0 = (Gd_0000 / Id_0000);
   Ld_FFD8 = 0.001;
   returned_double = MarketInfo(_Symbol, MODE_MINLOT);
   Ld_FFD0 = returned_double;
   Li_FFCC = 0;
   if ((returned_double < 1)) { 
   do { 
   returned_double = MathPow(10, Li_FFCC);
   Ld_FFD0 = (Ld_FFD0 * returned_double);
   Li_FFCC = Li_FFCC + 1;
   } while (Ld_FFD0 < 1); 
   } 
   Ld_FFD8 = NormalizeDouble(Ld_FFE0, (Li_FFCC - 1));
   if ((Ld_FFD8 < MarketInfo(_Symbol, MODE_MINLOT))) { 
   Ld_FFD8 = MarketInfo(_Symbol, MODE_MINLOT);
   } 
   if ((Ld_FFD8 > MarketInfo(_Symbol, MODE_MAXLOT))) { 
   Ld_FFD8 = MarketInfo(_Symbol, MODE_MAXLOT);
   } 
   Gd_0000 = ((StopLoss * Id_0000) * _Point);
   Ld_FFC0 = (Ask - Gd_0000);
   if (StopLoss == 0) { 
   Ld_FFC0 = 0;
   } 
   Ld_FFB8 = (((TakeProfit * Id_0000) * _Point) + Ask);
   if (TakeProfit == 0) { 
   Ld_FFB8 = 0;
   } 
   Li_FFB4 = -1;
   Li_FFB4 = OrderSend(_Symbol, 0, Ld_FFD8, Ask, (int)MaxSlippage, 0, 0, RobotName, 1, 0, 16711680);
   if (Li_FFB4 > -1) { 
   if (OrderSelect(Li_FFB4, 1, 0)) { 
   Lb_FFB3 = OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFC0, Ld_FFB8, 0, 16711680);
   } 
   if (Lb_FFB3 != 0) return; 
   tmp_str0000 = ErrorDescription(GetLastError());
   Print("OrderModify() error - ", tmp_str0000);
   return ;
   } 
   tmp_str0001 = ErrorDescription(GetLastError());
   Print("OrderSend() error - ", tmp_str0001);
   
}

void SOR()
{
   string tmp_str0000;
   string tmp_str0001;
   double Ld_FFF8;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
   double Ld_FFD0;
   int Li_FFCC;
   double Ld_FFC0;
   double Ld_FFB8;
   int Li_FFB4;
   bool Lb_FFB3;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Ld_FFD8 = 0;
   Ld_FFD0 = 0;
   Li_FFCC = 0;
   Ld_FFC0 = 0;
   Ld_FFB8 = 0;
   Li_FFB4 = 0;
   Lb_FFB3 = false;
   Gd_0000 = (Ask - Bid);
   if ((Gd_0000 > ((MaxSpread * Id_0000) * _Point))) return; 
   Ld_FFF8 = MarketInfo(_Symbol, MODE_LOTSIZE);
   Ld_FFF0 = 1000;
   Ld_FFE8 = ((AccountFreeMargin() / 100) * Id_0028);
   if (StopLoss == 0) { 
   Print("OrderSend() error - stoploss can not be zero");
   } 
   Gd_0000 = (Ld_FFE8 / StopLoss);
   Ld_FFE0 = (Gd_0000 / Id_0000);
   Ld_FFD8 = 0.001;
   returned_double = MarketInfo(_Symbol, MODE_MINLOT);
   Ld_FFD0 = returned_double;
   Li_FFCC = 0;
   if ((returned_double < 1)) { 
   do { 
   returned_double = MathPow(10, Li_FFCC);
   Ld_FFD0 = (Ld_FFD0 * returned_double);
   Li_FFCC = Li_FFCC + 1;
   } while (Ld_FFD0 < 1); 
   } 
   Ld_FFD8 = NormalizeDouble(Ld_FFE0, (Li_FFCC - 1));
   if ((Ld_FFD8 < MarketInfo(_Symbol, MODE_MINLOT))) { 
   Ld_FFD8 = MarketInfo(_Symbol, MODE_MINLOT);
   } 
   if ((Ld_FFD8 > MarketInfo(_Symbol, MODE_MAXLOT))) { 
   Ld_FFD8 = MarketInfo(_Symbol, MODE_MAXLOT);
   } 
   Ld_FFC0 = (((StopLoss * Id_0000) * _Point) + Bid);
   if (StopLoss == 0) { 
   Ld_FFC0 = 0;
   } 
   Gd_0000 = ((TakeProfit * Id_0000) * _Point);
   Ld_FFB8 = (Bid - Gd_0000);
   if (TakeProfit == 0) { 
   Ld_FFB8 = 0;
   } 
   Li_FFB4 = -1;
   Li_FFB4 = OrderSend(_Symbol, 1, Ld_FFD8, Bid, (int)MaxSlippage, 0, 0, RobotName, 2, 0, 255);
   if (Li_FFB4 > -1) { 
   if (OrderSelect(Li_FFB4, 1, 0)) { 
   Lb_FFB3 = OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFC0, Ld_FFB8, 0, 255);
   } 
   if (Lb_FFB3 != 0) return; 
   tmp_str0000 = ErrorDescription(GetLastError());
   Print("OrderModify() error - ", tmp_str0000);
   return ;
   } 
   tmp_str0001 = ErrorDescription(GetLastError());
   Print("OrderSend() error - ", tmp_str0001);
   
}



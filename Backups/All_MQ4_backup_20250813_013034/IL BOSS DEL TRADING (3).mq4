//+--------------------------------------------------------------------------+
//|                                                               iTrend.mq4 |
//|                                       Copyright © 2020, FXProSystems.com |
//|                                                https://fxprosystems.com/ |
//+--------------------------------------------------------------------------+
#property copyright "Copyright © 2020, FXProSystems.com"
#property link      "https://fxprosystems.com/"

#import "stdlib.ex4"

string ErrorDescription(int);

#import

enum LotAss
{
   Fixed = 0, // FixedLots
   AutoMM = 1, // Percentage Risk
   BalanceRatio = 2 // BalanceRatio
};

extern double FixedLots = 0.01;
extern string PercentageRiskSettings = "***************************";
extern double PercentageRisk = 0.1;
extern int PercentageRiskBasedOnPointsMovement = 100;
extern string BalanceRatioSettings = "***************************";
extern double ForEvery = 1000;
extern double UseLotsForEveryBalance = 0.01;
extern string LotsSelection = "***************************";
extern LotAss LotAssignment = Fixed;
extern int TakeProfit = 30;
extern double Tral = 20;
extern double TralStart = 5;
extern double TimeStart = 2;
extern double TimeEnd = 23;
extern double MaxSpread = 40;
extern double PipsStep = 35;
extern int OpenTime = 1;
extern int Magic = 2021;
extern bool Info = true;
extern color TextColor = White;
extern color InfoDataColor = DodgerBlue;
extern color FonColor = 0;
extern int FontSizeInfo = 7;
extern int SpeedEA = 50;
extern bool CloseTradesAtPercentageDrawdown;
extern double PercentageDrawdown = 5;
extern bool CloseTradesAtFixedDrawdown;
extern double FixedDrawdown = 1000;
extern bool ResumeTradingAtNextDayAfterDrawdown;

bool Ib_00000;
int Ii_00004;
int returned_i;
string Is_00008;
bool returned_b;
bool Ib_00014;
string Is_00018;
int Ii_0003C;
double Gd_00000;
int Gi_00001;
int Gi_00002;
string Is_00030;
double Ind_000;
double Gd_00001;
bool Gb_00001;
int Gi_00003;
int Gi_00004;
double Gd_00003;
bool Gb_00003;
bool Ib_00078;
bool Ib_00024;
double Ind_002;
double Id_00068;
long Il_00050;
long returned_l;
double Id_00048;
long Gl_00003;
double Ind_004;
double Gd_00005;
int Gi_00006;
int Gi_00007;
double Gd_00006;
double Id_00070;
int Gi_00008;
int Gi_00009;
int Gi_0000A;
double Gd_0000B;
double Gd_0000C;
double Gd_0000D;
int Gi_0000E;
double Gd_0000E;
bool Gb_0000E;
double Gd_0000F;
int Ii_00040;
int Gi_00010;
int Gi_00011;
int Gi_00012;
double Gd_00013;
double Gd_00014;
double Gd_00015;
int Gi_00016;
double Gd_00016;
bool Gb_00016;
double Gd_00017;
int Gi_00018;
int Gi_00019;
int Gi_0001A;
long Gl_00019;
long Gl_0001B;
int Gi_0001B;
int Gi_0001C;
int Gi_0001D;
int Gi_0001E;
long Gl_0001D;
int Gi_0001F;
int Gi_00020;
int Gi_00021;
double Gd_00022;
double Gd_00023;
double Gd_00024;
int Gi_00025;
double Gd_00025;
bool Gb_00025;
double Gd_00026;
int Gi_00027;
int Gi_00028;
int Gi_00029;
double Gd_0002A;
double Gd_0002B;
double Gd_0002C;
int Gi_0002D;
double Gd_0002D;
bool Gb_0002D;
double Gd_0002E;
double Gd_0002F;
int Gi_00030;
int Gi_00031;
double Gd_00032;
int Gi_00033;
int Gi_00034;
double Gd_00033;
bool Gb_00033;
int Gi_00035;
int Gi_00036;
int Gi_00037;
int Gi_00038;
double Gd_00036;
double Gd_00039;
int Gi_0003A;
double Gd_0003A;
double Gd_0003B;
int Gi_0003C;
int Gi_0003D;
int Gi_0003E;
int Gi_0003F;
long Gl_0003E;
double Gd_00040;
int Gi_00041;
int Gi_00042;
double Gd_00041;
long Gl_00041;
double Gd_00043;
int Gi_00044;
int Gi_00045;
double Gd_00044;
long Gl_00044;
double Gd_00046;
int Gi_00047;
int Gi_00048;
long Gl_00047;
double Gd_00047;
double Gd_00049;
int Gi_0004A;
int Gi_0004B;
long Gl_0004A;
double Gd_0004A;
double Gd_0004C;
int Gi_0004D;
int Gi_0004E;
long Gl_0004D;
double Gd_0004D;
double Gd_0004F;
int Gi_00050;
int Gi_00051;
long Gl_00050;
double Gd_00050;
long Il_00028;
double Id_00058;
double Id_00060;
int Ii_0007C;
bool Ib_00080;
int Ii_00084;
int Ii_00088;
bool Gb_00000;
double Gd_00002;
bool Gb_00002;
double Gd_00004;
int Gi_00000;
long Gl_00006;
double returned_double;
bool order_check;
int init()
{
   Comment("   Copyright © 2020 | FXProSystems.com");
   //bool Lb_FFFFB;
   int Li_FFFFC;
   
   Ib_00000 = true;
   Ii_00004 = 18120;
   Is_00008 = "info@ilbossdeltrading.com";
   Ib_00014 = true;
   Is_00018 = "Backtest Disabled";
   Ib_00024 = false;
   Il_00028 = 0;
   Is_00030 = "IL BOSS DEL TRADING Scalper";
   Ii_0003C = 0;
   Ii_00040 = 0;
   Id_00048 = 0;
   Il_00050 = 0;
   Id_00058 = 0;
   Id_00060 = 0;
   Id_00068 = 0;
   Id_00070 = 0;
   Ib_00078 = false;
   Ii_0007C = 0;
   Ib_00080 = true;
   Ii_00084 = 7;
   Ii_00088 = 0;

   EventSetMillisecondTimer(SpeedEA);
   Ii_0003C = 1;
   if (_Digits != 5) { 
   if (_Digits != 3) return 0; 
   } 
   Ii_0003C = 10;
   
   Li_FFFFC = 0;
   
   return Li_FFFFC;
}

void OnTick()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   string tmp_str0000A;
   string tmp_str0000B;
   string tmp_str0000C;
   string tmp_str0000D;
   string tmp_str0000E;
   string tmp_str0000F;
   string tmp_str00010;
   string tmp_str00011;
   string tmp_str00012;
   string tmp_str00013;
   string tmp_str00014;
   string tmp_str00015;
   string tmp_str00016;
   string tmp_str00017;
   string tmp_str00018;
   string tmp_str00019;
   string tmp_str0001A;
   string tmp_str0001B;
   string tmp_str0001C;
   string tmp_str0001D;
   string tmp_str0001E;
   string tmp_str0001F;
   string tmp_str00020;
   string tmp_str00021;
   string tmp_str00022;
   string tmp_str00023;
   string tmp_str00024;
   string tmp_str00025;
   string tmp_str00026;
   string tmp_str00027;
   string tmp_str00028;
   string tmp_str00029;
   string tmp_str0002A;
   string tmp_str0002B;
   string tmp_str0002C;
   string tmp_str0002D;
   string tmp_str0002E;
   string tmp_str0002F;
   string tmp_str00030;
   string tmp_str00031;
   string tmp_str00032;
   string tmp_str00033;
   string tmp_str00034;
   string tmp_str00035;
   string tmp_str00036;
   string tmp_str00037;
   string tmp_str00038;
   string tmp_str00039;
   string tmp_str0003A;
   string tmp_str0003B;
   string tmp_str0003C;
   string tmp_str0003D;
   string tmp_str0003E;
   bool Lb_FFFFF;
   bool Lb_FFFFE;
   bool Lb_FFFFD;
   bool Lb_FFFFC;
   double Ld_FFFF0;

   if (CloseTradesAtPercentageDrawdown) { 
   Gd_00000 = 0;
   Gi_00001 = OrdersTotal() - 1;
   Gi_00002 = Gi_00001;
   if (Gi_00001 >= 0) { 
   do { 
   if (OrderSelect(Gi_00002, 0, 0) && OrderMagicNumber() == Magic && OrderSymbol() == _Symbol && OrderComment() == Is_00030) { 
   Gd_00001 = (Gd_00000 + OrderProfit());
   Gd_00001 = (Gd_00001 + OrderSwap());
   Gd_00000 = (Gd_00001 + OrderCommission());
   } 
   Gi_00002 = Gi_00002 - 1;
   } while (Gi_00002 >= 0); 
   } 
   Gd_00001 = -PercentageDrawdown;
   if ((Gd_00000 <= ((Gd_00001 * AccountBalance()) / 100))) { 
   tmp_str00000 = "EP Closed At Percentage Drawdown";
   func_1037(tmp_str00000);
   }} 
   if (CloseTradesAtFixedDrawdown) { 
   Gd_00001 = 0;
   Gi_00003 = OrdersTotal() - 1;
   Gi_00004 = Gi_00003;
   if (Gi_00003 >= 0) { 
   do { 
   if (OrderSelect(Gi_00004, 0, 0) && OrderMagicNumber() == Magic && OrderSymbol() == _Symbol && OrderComment() == Is_00030) { 
   Gd_00003 = (Gd_00001 + OrderProfit());
   Gd_00003 = (Gd_00003 + OrderSwap());
   Gd_00001 = (Gd_00003 + OrderCommission());
   } 
   Gi_00004 = Gi_00004 - 1;
   } while (Gi_00004 >= 0); 
   } 
   Gd_00003 = -FixedDrawdown;
   if ((Gd_00001 <= Gd_00003)) { 
   tmp_str00001 = "EP Closed At Percentage Drawdown";
   func_1037(tmp_str00001);
   }} 
   if (Ib_00078) { 
   if (IsDemo() != true) return; 
   } 
   if (Ib_00024 != true) { 
   Gd_00003 = (Ask - Bid);
   Id_00068 = (Gd_00003 / _Point);
   Lb_FFFFF = false;
   Lb_FFFFE = false;
   Lb_FFFFD = false;
   Lb_FFFFC = false;
   if (Il_00050 == 0) { 
   Il_00050 = TimeCurrent();
   } 
   if ((Id_00048 == 0)) { 
   Id_00048 = Bid;
   } 
   Gl_00003 = OpenTime;
   Gl_00003 = Il_00050 + Gl_00003;
   if (Gl_00003 < TimeCurrent()) { 
   Il_00050 = TimeCurrent();
   Id_00048 = Bid;
   } 
   Gl_00003 = OpenTime;
   Gl_00003 = Il_00050 + Gl_00003;
   if (Gl_00003 >= TimeCurrent()) { 
   Gd_00003 = (PipsStep * _Point);
   if (((Bid - Gd_00003) >= Id_00048)) { 
   Lb_FFFFF = true;
   }} 
   Gl_00003 = OpenTime;
   Gl_00003 = Il_00050 + Gl_00003;
   if (Gl_00003 >= TimeCurrent() && (((PipsStep * _Point) + Bid) <= Id_00048)) { 
   Lb_FFFFD = true;
   } 
   if ((TimeHour(TimeCurrent()) >= TimeStart) && (TimeHour(TimeCurrent()) < TimeEnd)) { 
   if (MaxSpread == 0 || (MaxSpread >= Id_00068)) {
   
   if (Lb_FFFFF) { 
   Lb_FFFFE = true;
   }} 
   if (MaxSpread == 0 || (MaxSpread >= Id_00068)) {
   
   if (Lb_FFFFD) { 
   Lb_FFFFC = true;
   }}} 
   Gi_00003 = -1;
   Gd_00005 = 0;
   Gi_00006 = OrdersTotal() - 1;
   Gi_00007 = Gi_00006;
   if (Gi_00006 >= 0) { 
   do { 
   if (OrderSelect(Gi_00007, 0, 0) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic) { 
   if (OrderType() == Gi_00003 || Gi_00003 == -1) { 
   
   Gd_00006 = OrderProfit();
   Gd_00006 = (Gd_00006 + OrderSwap());
   Gd_00005 = ((Gd_00006 + OrderCommission()) + Gd_00005);
   }} 
   Gi_00007 = Gi_00007 - 1;
   } while (Gi_00007 >= 0); 
   } 
   Id_00070 = (Gd_00005 / (AccountBalance() / 100));
   Gi_00006 = -1;
   Gi_00008 = 0;
   Gi_00009 = OrdersTotal() - 1;
   Gi_0000A = Gi_00009;
   if (Gi_00009 >= 0) { 
   do { 
   if (OrderSelect(Gi_0000A, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00006 == -1 || OrderType() == Gi_00006) { 
   
   Gi_00008 = Gi_00008 + 1;
   }} 
   Gi_0000A = Gi_0000A - 1;
   } while (Gi_0000A >= 0); 
   } 
   if (Gi_00008 == 0 && Lb_FFFFC) { 
   tmp_str00002 = _Symbol;
   Gd_0000C = FixedLots;
   if (LotAssignment == 1) { 
   Gd_0000D = (PercentageRisk * AccountBalance());
   Gi_0000E = PercentageRiskBasedOnPointsMovement * 100;
   Gd_0000E = (Gd_0000D / (Gi_0000E * MarketInfo(tmp_str00002, MODE_TICKVALUE)));
   Gd_0000C = Gd_0000E;
   if ((Gd_0000E < MarketInfo(tmp_str00002, MODE_MINLOT))) { 
   Gd_0000C = MarketInfo(tmp_str00002, MODE_MINLOT);
   }} 
   if (LotAssignment == 2) { 
   Gd_0000E = floor((AccountBalance() / ForEvery));
   Gd_0000C = (Gd_0000E * 0.01);
   } 
   Gd_0000E = floor((Gd_0000C / MarketInfo(tmp_str00002, MODE_MINLOT)));
   Gd_0000E = (Gd_0000E * MarketInfo(tmp_str00002, MODE_MINLOT));
   Gd_0000C = Gd_0000E;
   returned_double = MarketInfo(tmp_str00002, MODE_MINLOT);
   Gd_0000F = Gd_0000E;
   if (Gd_0000E <= returned_double) { 
   Gd_0000E = returned_double;
   } 
   else { 
   Gd_0000E = Gd_0000F;
   } 
   Gd_0000C = Gd_0000E;
   returned_double = MarketInfo(tmp_str00002, MODE_MAXLOT);
   Gd_0000F = Gd_0000E;
   if (Gd_0000E >= returned_double) { 
   Gd_0000E = returned_double;
   } 
   else { 
   Gd_0000E = Gd_0000F;
   } 
   Gd_0000C = Gd_0000E;
   Ii_00040 = OrderSend(_Symbol, 1, Gd_0000E, Bid, 5, 0, 0, Is_00030, Magic, 0, 255);
   } 
   Gi_0000E = -1;
   Gi_00010 = 0;
   Gi_00011 = OrdersTotal() - 1;
   Gi_00012 = Gi_00011;
   if (Gi_00011 >= 0) { 
   do { 
   if (OrderSelect(Gi_00012, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_0000E == -1 || OrderType() == Gi_0000E) { 
   
   Gi_00010 = Gi_00010 + 1;
   }} 
   Gi_00012 = Gi_00012 - 1;
   } while (Gi_00012 >= 0); 
   } 
   if (Gi_00010 == 0 && Lb_FFFFE) { 
   tmp_str00003 = _Symbol;
   Gd_00014 = FixedLots;
   if (LotAssignment == 1) { 
   Gd_00015 = (PercentageRisk * AccountBalance());
   Gi_00016 = PercentageRiskBasedOnPointsMovement * 100;
   Gd_00016 = (Gd_00015 / (Gi_00016 * MarketInfo(tmp_str00003, MODE_TICKVALUE)));
   Gd_00014 = Gd_00016;
   if ((Gd_00016 < MarketInfo(tmp_str00003, MODE_MINLOT))) { 
   Gd_00014 = MarketInfo(tmp_str00003, MODE_MINLOT);
   }} 
   if (LotAssignment == 2) { 
   Gd_00016 = floor((AccountBalance() / ForEvery));
   Gd_00014 = (Gd_00016 * 0.01);
   } 
   Gd_00016 = floor((Gd_00014 / MarketInfo(tmp_str00003, MODE_MINLOT)));
   Gd_00016 = (Gd_00016 * MarketInfo(tmp_str00003, MODE_MINLOT));
   Gd_00014 = Gd_00016;
   returned_double = MarketInfo(tmp_str00003, MODE_MINLOT);
   Gd_00017 = Gd_00016;
   if (Gd_00016 <= returned_double) { 
   Gd_00016 = returned_double;
   } 
   else { 
   Gd_00016 = Gd_00017;
   } 
   Gd_00014 = Gd_00016;
   returned_double = MarketInfo(tmp_str00003, MODE_MAXLOT);
   Gd_00017 = Gd_00016;
   if (Gd_00016 >= returned_double) { 
   Gd_00016 = returned_double;
   } 
   else { 
   Gd_00016 = Gd_00017;
   } 
   Gd_00014 = Gd_00016;
   Ii_00040 = OrderSend(_Symbol, 0, Gd_00016, Ask, 5, 0, 0, Is_00030, Magic, 0, 32768);
   } 
   Gi_00016 = -1;
   Gi_00018 = 0;
   Gi_00019 = OrdersTotal() - 1;
   Gi_0001A = Gi_00019;
   if (Gi_00019 >= 0) { 
   do { 
   if (OrderSelect(Gi_0001A, 0, 0) && OrderMagicNumber() == Magic) { 
   if (Gi_00016 == -1 || OrderType() == Gi_00016) { 
   
   Gi_00018 = Gi_00018 + 1;
   }} 
   Gi_0001A = Gi_0001A - 1;
   } while (Gi_0001A >= 0); 
   } 
   Gl_00019 = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   Gl_0001B = Gi_00018;
   if (Gl_0001B < Gl_00019 || AccountInfoInteger(ACCOUNT_LIMIT_ORDERS) == 0) { 
   
   Gi_0001B = -1;
   Gi_0001C = 0;
   Gi_0001D = OrdersTotal() - 1;
   Gi_0001E = Gi_0001D;
   if (Gi_0001D >= 0) { 
   do { 
   if (OrderSelect(Gi_0001E, 0, 0) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic) { 
   Gl_0001D = OrderOpenTime();
   if (Gl_0001D >= iTime(_Symbol, 0, 0)) { 
   if (Gi_0001B == -1 || OrderType() == Gi_0001B) { 
   
   Gi_0001C = Gi_0001C + 1;
   }}} 
   Gi_0001E = Gi_0001E - 1;
   } while (Gi_0001E >= 0); 
   } 
   if (Gi_0001C == 0) { 
   Gi_0001D = 0;
   Gi_0001F = 0;
   Gi_00020 = OrdersTotal() - 1;
   Gi_00021 = Gi_00020;
   if (Gi_00020 >= 0) { 
   do { 
   if (OrderSelect(Gi_00021, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_0001D == -1 || OrderType() == Gi_0001D) { 
   
   Gi_0001F = Gi_0001F + 1;
   }} 
   Gi_00021 = Gi_00021 - 1;
   } while (Gi_00021 >= 0); 
   } 
   if (Gi_0001F > 0 && Lb_FFFFE) { 
   tmp_str00004 = _Symbol;
   Gd_00023 = FixedLots;
   if (LotAssignment == 1) { 
   Gd_00024 = (PercentageRisk * AccountBalance());
   Gi_00025 = PercentageRiskBasedOnPointsMovement * 100;
   Gd_00025 = (Gd_00024 / (Gi_00025 * MarketInfo(tmp_str00004, MODE_TICKVALUE)));
   Gd_00023 = Gd_00025;
   if ((Gd_00025 < MarketInfo(tmp_str00004, MODE_MINLOT))) { 
   Gd_00023 = MarketInfo(tmp_str00004, MODE_MINLOT);
   }} 
   if (LotAssignment == 2) { 
   Gd_00025 = floor((AccountBalance() / ForEvery));
   Gd_00023 = (Gd_00025 * 0.01);
   } 
   Gd_00025 = floor((Gd_00023 / MarketInfo(tmp_str00004, MODE_MINLOT)));
   Gd_00025 = (Gd_00025 * MarketInfo(tmp_str00004, MODE_MINLOT));
   Gd_00023 = Gd_00025;
   returned_double = MarketInfo(tmp_str00004, MODE_MINLOT);
   Gd_00026 = Gd_00025;
   if (Gd_00025 <= returned_double) { 
   Gd_00025 = returned_double;
   } 
   else { 
   Gd_00025 = Gd_00026;
   } 
   Gd_00023 = Gd_00025;
   returned_double = MarketInfo(tmp_str00004, MODE_MAXLOT);
   Gd_00026 = Gd_00025;
   if (Gd_00025 >= returned_double) { 
   Gd_00025 = returned_double;
   } 
   else { 
   Gd_00025 = Gd_00026;
   } 
   Gd_00023 = Gd_00025;
   Ii_00040 = OrderSend(_Symbol, 0, Gd_00025, Ask, 10, 0, 0, Is_00030, Magic, 0, 32768);
   } 
   Gi_00025 = 1;
   Gi_00027 = 0;
   Gi_00028 = OrdersTotal() - 1;
   Gi_00029 = Gi_00028;
   if (Gi_00028 >= 0) { 
   do { 
   if (OrderSelect(Gi_00029, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00025 == -1 || OrderType() == Gi_00025) { 
   
   Gi_00027 = Gi_00027 + 1;
   }} 
   Gi_00029 = Gi_00029 - 1;
   } while (Gi_00029 >= 0); 
   } 
   if (Gi_00027 > 0 && Lb_FFFFC) { 
   tmp_str00005 = _Symbol;
   Gd_0002B = FixedLots;
   if (LotAssignment == 1) { 
   Gd_0002C = (PercentageRisk * AccountBalance());
   Gi_0002D = PercentageRiskBasedOnPointsMovement * 100;
   Gd_0002D = (Gd_0002C / (Gi_0002D * MarketInfo(tmp_str00005, MODE_TICKVALUE)));
   Gd_0002B = Gd_0002D;
   if ((Gd_0002D < MarketInfo(tmp_str00005, MODE_MINLOT))) { 
   Gd_0002B = MarketInfo(tmp_str00005, MODE_MINLOT);
   }} 
   if (LotAssignment == 2) { 
   Gd_0002D = floor((AccountBalance() / ForEvery));
   Gd_0002B = (Gd_0002D * 0.01);
   } 
   Gd_0002D = floor((Gd_0002B / MarketInfo(tmp_str00005, MODE_MINLOT)));
   Gd_0002D = (Gd_0002D * MarketInfo(tmp_str00005, MODE_MINLOT));
   Gd_0002B = Gd_0002D;
   returned_double = MarketInfo(tmp_str00005, MODE_MINLOT);
   Gd_0002E = Gd_0002D;
   if (Gd_0002D <= returned_double) { 
   Gd_0002D = returned_double;
   } 
   else { 
   Gd_0002D = Gd_0002E;
   } 
   Gd_0002B = Gd_0002D;
   returned_double = MarketInfo(tmp_str00005, MODE_MAXLOT);
   Gd_0002E = Gd_0002D;
   if (Gd_0002D >= returned_double) { 
   Gd_0002D = returned_double;
   } 
   else { 
   Gd_0002D = Gd_0002E;
   } 
   Gd_0002B = Gd_0002D;
   Ii_00040 = OrderSend(_Symbol, 1, Gd_0002D, Bid, 10, 0, 0, Is_00030, Magic, 0, 255);
   }}} 
   Gi_0002D = -1;
   Gd_0002F = 0;
   Gi_00030 = OrdersTotal() - 1;
   Gi_00031 = Gi_00030;
   if (Gi_00030 >= 0) { 
   do { 
   if (OrderSelect(Gi_00031, 0, 0) && OrderMagicNumber() == Magic) { 
   if (OrderType() == Gi_0002D || Gi_0002D == -1) { 
   
   Gd_0002F = (Gd_0002F + OrderLots());
   }} 
   Gi_00031 = Gi_00031 - 1;
   } while (Gi_00031 >= 0); 
   } 
   Ld_FFFF0 = (Gd_0002F * TakeProfit);
   Gi_00030 = -1;
   Gd_00032 = 0;
   Gi_00033 = OrdersTotal() - 1;
   Gi_00034 = Gi_00033;
   if (Gi_00033 >= 0) { 
   do { 
   if (OrderSelect(Gi_00034, 0, 0) && OrderMagicNumber() == Magic) { 
   if (OrderType() == Gi_00030 || Gi_00030 == -1) { 
   
   Gd_00033 = OrderProfit();
   Gd_00033 = (Gd_00033 + OrderSwap());
   Gd_00032 = ((Gd_00033 + OrderCommission()) + Gd_00032);
   }} 
   Gi_00034 = Gi_00034 - 1;
   } while (Gi_00034 >= 0); 
   } 
   if ((Gd_00032 >= Ld_FFFF0) && (Ld_FFFF0 != 0)) { 
   Gi_00033 = -1;
   Gi_00035 = 0;
   Gi_00036 = OrdersTotal() - 1;
   Gi_00037 = Gi_00036;
   if (Gi_00036 >= 0) { 
   do { 
   if (OrderSelect(Gi_00037, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00033 == -1 || OrderType() == Gi_00033) { 
   
   Gi_00035 = Gi_00035 + 1;
   }} 
   Gi_00037 = Gi_00037 - 1;
   } while (Gi_00037 >= 0); 
   } 
   if (Gi_00035 > 1) { 
   Gi_00036 = OrdersTotal() - 1;
   Gi_00038 = Gi_00036;
   if (Gi_00036 >= 0) { 
   do { 
   if (OrderSelect(Gi_00038, 0, 0) && OrderMagicNumber() == Magic) { 
   if (OrderType() == OP_BUY) { 
   RefreshRates();
   tmp_str00006 = OrderSymbol();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(MarketInfo(tmp_str00006, MODE_BID), _Digits), 10, 16777215);
   } 
   if (OrderType() == OP_SELL) { 
   RefreshRates();
   tmp_str00007 = OrderSymbol();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(MarketInfo(tmp_str00007, MODE_ASK), _Digits), 10, 16777215);
   }} 
   Gi_00038 = Gi_00038 - 1;
   } while (Gi_00038 >= 0); 
   }}} 
   Gi_0003C = -1;
   Gi_0003D = 0;
   Gi_0003E = OrdersTotal() - 1;
   Gi_0003F = Gi_0003E;
   if (Gi_0003E >= 0) { 
   do { 
   if (OrderSelect(Gi_0003F, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_0003C == -1 || OrderType() == Gi_0003C) { 
   
   Gi_0003D = Gi_0003D + 1;
   }} 
   Gi_0003F = Gi_0003F - 1;
   } while (Gi_0003F >= 0); 
   } 
   if (Gi_0003D == 1) { 
   func_1018();
   } 
   if (Info == false) return; 
   tmp_str00008 = "INFO_fon";
   if (ObjectCreate(0, tmp_str00008, OBJ_RECTANGLE_LABEL, 0, 0, 0)) { 
   ObjectSetInteger(0, tmp_str00008, 102, 220);
   ObjectSetInteger(0, tmp_str00008, 103, 20);
   ObjectSetInteger(0, tmp_str00008, 1019, 200);
   ObjectSetInteger(0, tmp_str00008, 1020, 225);
   ObjectSetInteger(0, tmp_str00008, 1025, FonColor);
   ObjectSetInteger(0, tmp_str00008, 1029, 2);
   ObjectSetInteger(0, tmp_str00008, 101, 1);
   ObjectSetInteger(0, tmp_str00008, 6, 16711680);
   ObjectSetInteger(0, tmp_str00008, 8, 1);
   ObjectSetInteger(0, tmp_str00008, 9, 0);
   ObjectSetInteger(0, tmp_str00008, 208, 0);
   } 
   tmp_str00009 = "www.ilbossdeltrading.com";
   tmp_str0000A = "INFO_LOGO";
   ObjectCreate(0, tmp_str0000A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0000A, 102, 165);
   ObjectSetInteger(0, tmp_str0000A, 103, 24);
   ObjectSetInteger(0, tmp_str0000A, 101, 1);
   ObjectSetString(0, tmp_str0000A, 999, tmp_str00009);
   ObjectSetString(0, tmp_str0000A, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0000A, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0000A, 6, TextColor);
   ObjectSetInteger(0, tmp_str0000A, 208, 0);
   ObjectSetInteger(0, tmp_str0000A, 9, 0);
   tmp_str0000B = "___________________________";
   tmp_str0000C = "INFO_Line";
   ObjectCreate(0, tmp_str0000C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0000C, 102, 215);
   ObjectSetInteger(0, tmp_str0000C, 103, 27);
   ObjectSetInteger(0, tmp_str0000C, 101, 1);
   ObjectSetString(0, tmp_str0000C, 999, tmp_str0000B);
   ObjectSetString(0, tmp_str0000C, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0000C, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0000C, 6, TextColor);
   ObjectSetInteger(0, tmp_str0000C, 208, 0);
   ObjectSetInteger(0, tmp_str0000C, 9, 0);
   tmp_str0000D = "Account information";
   tmp_str0000E = "INFO_txt1";
   ObjectCreate(0, tmp_str0000E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0000E, 102, 215);
   ObjectSetInteger(0, tmp_str0000E, 103, 45);
   ObjectSetInteger(0, tmp_str0000E, 101, 1);
   ObjectSetString(0, tmp_str0000E, 999, tmp_str0000D);
   ObjectSetString(0, tmp_str0000E, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0000E, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0000E, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str0000E, 208, 0);
   ObjectSetInteger(0, tmp_str0000E, 9, 0);
   tmp_str0000F = "___________________________";
   tmp_str00010 = "INFO_Line2";
   ObjectCreate(0, tmp_str00010, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00010, 102, 215);
   ObjectSetInteger(0, tmp_str00010, 103, 47);
   ObjectSetInteger(0, tmp_str00010, 101, 1);
   ObjectSetString(0, tmp_str00010, 999, tmp_str0000F);
   ObjectSetString(0, tmp_str00010, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00010, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00010, 6, TextColor);
   ObjectSetInteger(0, tmp_str00010, 208, 0);
   ObjectSetInteger(0, tmp_str00010, 9, 0);
   tmp_str00011 = "Minimum stop:";
   tmp_str00012 = "INFO_txt2";
   ObjectCreate(0, tmp_str00012, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00012, 102, 215);
   ObjectSetInteger(0, tmp_str00012, 103, 65);
   ObjectSetInteger(0, tmp_str00012, 101, 1);
   ObjectSetString(0, tmp_str00012, 999, tmp_str00011);
   ObjectSetString(0, tmp_str00012, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00012, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00012, 6, TextColor);
   ObjectSetInteger(0, tmp_str00012, 208, 0);
   ObjectSetInteger(0, tmp_str00012, 9, 0);
   tmp_str00013 = "Current profit percent:";
   tmp_str00014 = "INFO_txt3";
   ObjectCreate(0, tmp_str00014, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00014, 102, 215);
   ObjectSetInteger(0, tmp_str00014, 103, 80);
   ObjectSetInteger(0, tmp_str00014, 101, 1);
   ObjectSetString(0, tmp_str00014, 999, tmp_str00013);
   ObjectSetString(0, tmp_str00014, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00014, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00014, 6, TextColor);
   ObjectSetInteger(0, tmp_str00014, 208, 0);
   ObjectSetInteger(0, tmp_str00014, 9, 0);
   tmp_str00015 = "Balanse:";
   tmp_str00016 = "INFO_txt4";
   ObjectCreate(0, tmp_str00016, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00016, 102, 215);
   ObjectSetInteger(0, tmp_str00016, 103, 95);
   ObjectSetInteger(0, tmp_str00016, 101, 1);
   ObjectSetString(0, tmp_str00016, 999, tmp_str00015);
   ObjectSetString(0, tmp_str00016, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00016, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00016, 6, TextColor);
   ObjectSetInteger(0, tmp_str00016, 208, 0);
   ObjectSetInteger(0, tmp_str00016, 9, 0);
   tmp_str00017 = "Equity:";
   tmp_str00018 = "INFO_txt5";
   ObjectCreate(0, tmp_str00018, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00018, 102, 215);
   ObjectSetInteger(0, tmp_str00018, 103, 110);
   ObjectSetInteger(0, tmp_str00018, 101, 1);
   ObjectSetString(0, tmp_str00018, 999, tmp_str00017);
   ObjectSetString(0, tmp_str00018, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00018, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00018, 6, TextColor);
   ObjectSetInteger(0, tmp_str00018, 208, 0);
   ObjectSetInteger(0, tmp_str00018, 9, 0);
   tmp_str00019 = "___________________________";
   tmp_str0001A = "INFO_Line3";
   ObjectCreate(0, tmp_str0001A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0001A, 102, 215);
   ObjectSetInteger(0, tmp_str0001A, 103, 112);
   ObjectSetInteger(0, tmp_str0001A, 101, 1);
   ObjectSetString(0, tmp_str0001A, 999, tmp_str00019);
   ObjectSetString(0, tmp_str0001A, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0001A, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0001A, 6, TextColor);
   ObjectSetInteger(0, tmp_str0001A, 208, 0);
   ObjectSetInteger(0, tmp_str0001A, 9, 0);
   tmp_str0001B = "Profit on account";
   tmp_str0001C = "INFO_txt6";
   ObjectCreate(0, tmp_str0001C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0001C, 102, 215);
   ObjectSetInteger(0, tmp_str0001C, 103, 130);
   ObjectSetInteger(0, tmp_str0001C, 101, 1);
   ObjectSetString(0, tmp_str0001C, 999, tmp_str0001B);
   ObjectSetString(0, tmp_str0001C, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0001C, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0001C, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str0001C, 208, 0);
   ObjectSetInteger(0, tmp_str0001C, 9, 0);
   tmp_str0001D = "___________________________";
   tmp_str0001E = "INFO_Line4";
   ObjectCreate(0, tmp_str0001E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0001E, 102, 215);
   ObjectSetInteger(0, tmp_str0001E, 103, 132);
   ObjectSetInteger(0, tmp_str0001E, 101, 1);
   ObjectSetString(0, tmp_str0001E, 999, tmp_str0001D);
   ObjectSetString(0, tmp_str0001E, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0001E, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0001E, 6, TextColor);
   ObjectSetInteger(0, tmp_str0001E, 208, 0);
   ObjectSetInteger(0, tmp_str0001E, 9, 0);
   tmp_str0001F = "Profit on pair:";
   tmp_str00020 = "INFO_txt7";
   ObjectCreate(0, tmp_str00020, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00020, 102, 215);
   ObjectSetInteger(0, tmp_str00020, 103, 150);
   ObjectSetInteger(0, tmp_str00020, 101, 1);
   ObjectSetString(0, tmp_str00020, 999, tmp_str0001F);
   ObjectSetString(0, tmp_str00020, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00020, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00020, 6, TextColor);
   ObjectSetInteger(0, tmp_str00020, 208, 0);
   ObjectSetInteger(0, tmp_str00020, 9, 0);
   tmp_str00021 = "Total profit:";
   tmp_str00022 = "INFO_txt8";
   ObjectCreate(0, tmp_str00022, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00022, 102, 215);
   ObjectSetInteger(0, tmp_str00022, 103, 165);
   ObjectSetInteger(0, tmp_str00022, 101, 1);
   ObjectSetString(0, tmp_str00022, 999, tmp_str00021);
   ObjectSetString(0, tmp_str00022, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00022, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00022, 6, TextColor);
   ObjectSetInteger(0, tmp_str00022, 208, 0);
   ObjectSetInteger(0, tmp_str00022, 9, 0);
   tmp_str00023 = "Profit for today:";
   tmp_str00024 = "INFO_txt9";
   ObjectCreate(0, tmp_str00024, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00024, 102, 215);
   ObjectSetInteger(0, tmp_str00024, 103, 180);
   ObjectSetInteger(0, tmp_str00024, 101, 1);
   ObjectSetString(0, tmp_str00024, 999, tmp_str00023);
   ObjectSetString(0, tmp_str00024, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00024, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00024, 6, TextColor);
   ObjectSetInteger(0, tmp_str00024, 208, 0);
   ObjectSetInteger(0, tmp_str00024, 9, 0);
   tmp_str00025 = "Profit for yesterday:";
   tmp_str00026 = "INFO_txt10";
   ObjectCreate(0, tmp_str00026, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00026, 102, 215);
   ObjectSetInteger(0, tmp_str00026, 103, 195);
   ObjectSetInteger(0, tmp_str00026, 101, 1);
   ObjectSetString(0, tmp_str00026, 999, tmp_str00025);
   ObjectSetString(0, tmp_str00026, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00026, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00026, 6, TextColor);
   ObjectSetInteger(0, tmp_str00026, 208, 0);
   ObjectSetInteger(0, tmp_str00026, 9, 0);
   tmp_str00027 = "Profit for week:";
   tmp_str00028 = "INFO_txt11";
   ObjectCreate(0, tmp_str00028, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00028, 102, 215);
   ObjectSetInteger(0, tmp_str00028, 103, 210);
   ObjectSetInteger(0, tmp_str00028, 101, 1);
   ObjectSetString(0, tmp_str00028, 999, tmp_str00027);
   ObjectSetString(0, tmp_str00028, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00028, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00028, 6, TextColor);
   ObjectSetInteger(0, tmp_str00028, 208, 0);
   ObjectSetInteger(0, tmp_str00028, 9, 0);
   tmp_str00029 = "Profit for month:";
   tmp_str0002A = "INFO_txt12";
   ObjectCreate(0, tmp_str0002A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0002A, 102, 215);
   ObjectSetInteger(0, tmp_str0002A, 103, 225);
   ObjectSetInteger(0, tmp_str0002A, 101, 1);
   ObjectSetString(0, tmp_str0002A, 999, tmp_str00029);
   ObjectSetString(0, tmp_str0002A, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0002A, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0002A, 6, TextColor);
   ObjectSetInteger(0, tmp_str0002A, 208, 0);
   ObjectSetInteger(0, tmp_str0002A, 9, 0);
   tmp_str0002B = DoubleToString(MarketInfo(_Symbol, MODE_STOPLEVEL), 0);
   tmp_str0002C = "INFO_txt13";
   ObjectCreate(0, tmp_str0002C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0002C, 102, 85);
   ObjectSetInteger(0, tmp_str0002C, 103, 65);
   ObjectSetInteger(0, tmp_str0002C, 101, 1);
   ObjectSetString(0, tmp_str0002C, 999, tmp_str0002B);
   ObjectSetString(0, tmp_str0002C, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0002C, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0002C, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str0002C, 208, 0);
   ObjectSetInteger(0, tmp_str0002C, 9, 0);
   tmp_str0002D = DoubleToString(Id_00070, 2);
   tmp_str0002E = "INFO_txt14";
   ObjectCreate(0, tmp_str0002E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0002E, 102, 85);
   ObjectSetInteger(0, tmp_str0002E, 103, 80);
   ObjectSetInteger(0, tmp_str0002E, 101, 1);
   ObjectSetString(0, tmp_str0002E, 999, tmp_str0002D);
   ObjectSetString(0, tmp_str0002E, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0002E, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0002E, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str0002E, 208, 0);
   ObjectSetInteger(0, tmp_str0002E, 9, 0);
   tmp_str0002F = DoubleToString(AccountBalance(), 2);
   tmp_str00030 = "INFO_txt15";
   ObjectCreate(0, tmp_str00030, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00030, 102, 85);
   ObjectSetInteger(0, tmp_str00030, 103, 95);
   ObjectSetInteger(0, tmp_str00030, 101, 1);
   ObjectSetString(0, tmp_str00030, 999, tmp_str0002F);
   ObjectSetString(0, tmp_str00030, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00030, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00030, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str00030, 208, 0);
   ObjectSetInteger(0, tmp_str00030, 9, 0);
   tmp_str00031 = DoubleToString(AccountEquity(), 2);
   tmp_str00032 = "INFO_txt16";
   ObjectCreate(0, tmp_str00032, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00032, 102, 85);
   ObjectSetInteger(0, tmp_str00032, 103, 110);
   ObjectSetInteger(0, tmp_str00032, 101, 1);
   ObjectSetString(0, tmp_str00032, 999, tmp_str00031);
   ObjectSetString(0, tmp_str00032, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00032, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00032, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str00032, 208, 0);
   ObjectSetInteger(0, tmp_str00032, 9, 0);
   Gi_0003E = -1;
   Gd_00040 = 0;
   Gi_00041 = OrdersTotal() - 1;
   Gi_00042 = Gi_00041;
   if (Gi_00041 >= 0) { 
   do { 
   if (OrderSelect(Gi_00042, 0, 0) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic) { 
   if (OrderType() == Gi_0003E || Gi_0003E == -1) { 
   
   Gd_00041 = OrderProfit();
   Gd_00041 = (Gd_00041 + OrderSwap());
   Gd_00040 = ((Gd_00041 + OrderCommission()) + Gd_00040);
   }} 
   Gi_00042 = Gi_00042 - 1;
   } while (Gi_00042 >= 0); 
   } 
   tmp_str00033 = DoubleToString(Gd_00040, 2);
   tmp_str00034 = "INFO_txt17";
   ObjectCreate(0, tmp_str00034, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00034, 102, 85);
   ObjectSetInteger(0, tmp_str00034, 103, 150);
   ObjectSetInteger(0, tmp_str00034, 101, 1);
   ObjectSetString(0, tmp_str00034, 999, tmp_str00033);
   ObjectSetString(0, tmp_str00034, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00034, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00034, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str00034, 208, 0);
   ObjectSetInteger(0, tmp_str00034, 9, 0);
   Gi_00041 = -1;
   Gd_00043 = 0;
   Gi_00044 = OrdersTotal() - 1;
   Gi_00045 = Gi_00044;
   if (Gi_00044 >= 0) { 
   do { 
   if (OrderSelect(Gi_00045, 0, 0) && OrderMagicNumber() == Magic) { 
   if (OrderType() == Gi_00041 || Gi_00041 == -1) { 
   
   Gd_00044 = OrderProfit();
   Gd_00044 = (Gd_00044 + OrderSwap());
   Gd_00043 = ((Gd_00044 + OrderCommission()) + Gd_00043);
   }} 
   Gi_00045 = Gi_00045 - 1;
   } while (Gi_00045 >= 0); 
   } 
   tmp_str00035 = DoubleToString(Gd_00043, 2);
   tmp_str00036 = "INFO_txt18";
   ObjectCreate(0, tmp_str00036, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00036, 102, 85);
   ObjectSetInteger(0, tmp_str00036, 103, 165);
   ObjectSetInteger(0, tmp_str00036, 101, 1);
   ObjectSetString(0, tmp_str00036, 999, tmp_str00035);
   ObjectSetString(0, tmp_str00036, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00036, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00036, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str00036, 208, 0);
   ObjectSetInteger(0, tmp_str00036, 9, 0);
   Gi_00044 = -1;
   Gd_00046 = 0;
   Gi_00047 = HistoryTotal() - 1;
   Gi_00048 = Gi_00047;
   if (Gi_00047 >= 0) { 
   do { 
   if (OrderSelect(Gi_00048, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_00047 = OrderCloseTime();
   if (Gl_00047 >= iTime(_Symbol, 1440, 0)) { 
   if (OrderType() == Gi_00044 || Gi_00044 == -1) { 
   
   Gd_00047 = OrderProfit();
   Gd_00047 = (Gd_00047 + OrderSwap());
   Gd_00046 = ((Gd_00047 + OrderCommission()) + Gd_00046);
   }}} 
   Gi_00048 = Gi_00048 - 1;
   } while (Gi_00048 >= 0); 
   } 
   tmp_str00037 = DoubleToString(Gd_00046, 2);
   tmp_str00038 = "INFO_txt19";
   ObjectCreate(0, tmp_str00038, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00038, 102, 85);
   ObjectSetInteger(0, tmp_str00038, 103, 180);
   ObjectSetInteger(0, tmp_str00038, 101, 1);
   ObjectSetString(0, tmp_str00038, 999, tmp_str00037);
   ObjectSetString(0, tmp_str00038, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00038, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str00038, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str00038, 208, 0);
   ObjectSetInteger(0, tmp_str00038, 9, 0);
   Gi_00047 = -1;
   Gd_00049 = 0;
   Gi_0004A = HistoryTotal() - 1;
   Gi_0004B = Gi_0004A;
   if (Gi_0004A >= 0) { 
   do { 
   if (OrderSelect(Gi_0004B, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_0004A = OrderCloseTime();
   if (Gl_0004A >= iTime(_Symbol, 1440, 1)) { 
   Gl_0004A = OrderCloseTime();
   if (Gl_0004A < iTime(_Symbol, 1440, 0)) { 
   if (OrderType() == Gi_00047 || Gi_00047 == -1) { 
   
   Gd_0004A = OrderProfit();
   Gd_0004A = (Gd_0004A + OrderSwap());
   Gd_00049 = ((Gd_0004A + OrderCommission()) + Gd_00049);
   }}}} 
   Gi_0004B = Gi_0004B - 1;
   } while (Gi_0004B >= 0); 
   } 
   tmp_str00039 = DoubleToString(Gd_00049, 2);
   tmp_str0003A = "INFO_txt20";
   ObjectCreate(0, tmp_str0003A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0003A, 102, 85);
   ObjectSetInteger(0, tmp_str0003A, 103, 195);
   ObjectSetInteger(0, tmp_str0003A, 101, 1);
   ObjectSetString(0, tmp_str0003A, 999, tmp_str00039);
   ObjectSetString(0, tmp_str0003A, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0003A, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0003A, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str0003A, 208, 0);
   ObjectSetInteger(0, tmp_str0003A, 9, 0);
   Gi_0004A = -1;
   Gd_0004C = 0;
   Gi_0004D = HistoryTotal() - 1;
   Gi_0004E = Gi_0004D;
   if (Gi_0004D >= 0) { 
   do { 
   if (OrderSelect(Gi_0004E, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_0004D = OrderCloseTime();
   if (Gl_0004D >= iTime(_Symbol, 10080, 0)) { 
   if (OrderType() == Gi_0004A || Gi_0004A == -1) { 
   
   Gd_0004D = OrderProfit();
   Gd_0004D = (Gd_0004D + OrderSwap());
   Gd_0004C = ((Gd_0004D + OrderCommission()) + Gd_0004C);
   }}} 
   Gi_0004E = Gi_0004E - 1;
   } while (Gi_0004E >= 0); 
   } 
   tmp_str0003B = DoubleToString(Gd_0004C, 2);
   tmp_str0003C = "INFO_txt21";
   ObjectCreate(0, tmp_str0003C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0003C, 102, 85);
   ObjectSetInteger(0, tmp_str0003C, 103, 210);
   ObjectSetInteger(0, tmp_str0003C, 101, 1);
   ObjectSetString(0, tmp_str0003C, 999, tmp_str0003B);
   ObjectSetString(0, tmp_str0003C, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0003C, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0003C, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str0003C, 208, 0);
   ObjectSetInteger(0, tmp_str0003C, 9, 0);
   Gi_0004D = -1;
   Gd_0004F = 0;
   Gi_00050 = HistoryTotal() - 1;
   Gi_00051 = Gi_00050;
   if (Gi_00050 >= 0) { 
   do { 
   if (OrderSelect(Gi_00051, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_00050 = OrderCloseTime();
   if (Gl_00050 >= iTime(_Symbol, 43200, 0)) { 
   if (OrderType() == Gi_0004D || Gi_0004D == -1) { 
   
   Gd_00050 = OrderProfit();
   Gd_00050 = (Gd_00050 + OrderSwap());
   Gd_0004F = ((Gd_00050 + OrderCommission()) + Gd_0004F);
   }}} 
   Gi_00051 = Gi_00051 - 1;
   } while (Gi_00051 >= 0); 
   } 
   tmp_str0003D = DoubleToString(Gd_0004F, 2);
   tmp_str0003E = "INFO_txt22";
   ObjectCreate(0, tmp_str0003E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0003E, 102, 85);
   ObjectSetInteger(0, tmp_str0003E, 103, 225);
   ObjectSetInteger(0, tmp_str0003E, 101, 1);
   ObjectSetString(0, tmp_str0003E, 999, tmp_str0003D);
   ObjectSetString(0, tmp_str0003E, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0003E, 100, FontSizeInfo);
   ObjectSetInteger(0, tmp_str0003E, 6, InfoDataColor);
   ObjectSetInteger(0, tmp_str0003E, 208, 0);
   ObjectSetInteger(0, tmp_str0003E, 9, 0);
   return ;
   } 
   if (iTime(NULL, 1440, 0) <= Il_00028) return; 
   if (ResumeTradingAtNextDayAfterDrawdown == false) return; 
   Ib_00024 = false;
   
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, 23);
   ObjectsDeleteAll(0, 28);
}

void OnTimer()
{
   RefreshRates();
   OnTick();
}

void func_1018()
{
   int Li_FFFFC;
   double Ld_FFFF0;
   double Ld_FFFE8;
   bool Lb_FFFE7;
   int Li_FFFE0;

   Li_FFFFC = 0;
   Ld_FFFF0 = 0;
   Ld_FFFE8 = 0;
   Lb_FFFE7 = false;
   Li_FFFE0 = OrdersTotal() - 1;
   if (Li_FFFE0 < 0) return; 
   do { 
   if (OrderSelect(Li_FFFE0, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Li_FFFFC = OrderTicket();
   Ld_FFFF0 = OrderOpenPrice();
   Ld_FFFE8 = OrderStopLoss();
   if (OrderType() == OP_BUY && (Tral != 0)) { 
   if ((Ld_FFFE8 < Ld_FFFF0) || (Ld_FFFE8 == 0)) { 
   
   Gd_00000 = ((Tral + TralStart) * _Point);
   if (((Bid - Gd_00000) >= Ld_FFFF0)) { 
   Lb_FFFE7 = OrderModify(Li_FFFFC, OrderOpenPrice(), ((TralStart * _Point) + Ld_FFFF0), OrderTakeProfit(), 0, 4294967295);
   }} 
   if ((Ld_FFFE8 >= Ld_FFFF0)) { 
   Gd_00001 = (Tral * _Point);
   if (((Bid - Gd_00001) > Ld_FFFE8)) { 
   Gd_00002 = (Tral * _Point);
   Lb_FFFE7 = OrderModify(Li_FFFFC, OrderOpenPrice(), (Bid - Gd_00002), OrderTakeProfit(), 0, 4294967295);
   }}} 
   if (OrderType() == OP_SELL && (Tral != 0)) { 
   if (Ld_FFFE8 > Ld_FFFF0 || (Ld_FFFE8 == 0)) {
   
   if (((((Tral + TralStart) * _Point) + Ask) <= Ld_FFFF0)) { 
   Gd_00003 = (TralStart * _Point);
   Lb_FFFE7 = OrderModify(Li_FFFFC, OrderOpenPrice(), (Ld_FFFF0 - Gd_00003), OrderTakeProfit(), 0, 4294967295);
   }} 
   if ((Ld_FFFE8 <= Ld_FFFF0) && (((Tral * _Point) + Ask) < Ld_FFFE8)) { 
   Lb_FFFE7 = OrderModify(Li_FFFFC, OrderOpenPrice(), ((Tral * _Point) + Ask), OrderTakeProfit(), 0, 4294967295);
   }}} 
   Li_FFFE0 = Li_FFFE0 - 1;
   } while (Li_FFFE0 >= 0); 
   
}

void func_1037(string Fa_s_00)
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   string tmp_str00007;
   string tmp_str00008;
   string tmp_str00009;
   int Li_FFFFC;
   int Li_FFFF8;

   Li_FFFFC = 0;
   Li_FFFF8 = OrdersTotal() - 1;
   if (Li_FFFF8 >= 0) { 
   do { 
   if (OrderSelect(Li_FFFF8, 0, 0) && OrderMagicNumber() == Magic && OrderSymbol() == _Symbol && OrderComment() == Is_00030) { 
   if (OrderType() == OP_BUY) { 
   tmp_str00000 = OrderSymbol();
   tmp_str00001 = OrderSymbol();
   if (OrderClose(OrderTicket(), OrderLots(), MarketInfo(tmp_str00001, MODE_BID), (int)MarketInfo(tmp_str00000, MODE_SPREAD), 4294967295)) { 
   Print("Buy ticket ", OrderTicket(), " closed");
   Li_FFFFC = Li_FFFFC + 1;
   } 
   else { 
   tmp_str00002 = ErrorDescription(GetLastError());
   Print("Cannot close buy ticket ", OrderTicket(), " error: ", tmp_str00002);
   }} 
   if (OrderType() == OP_SELL) { 
   tmp_str00003 = OrderSymbol();
   tmp_str00004 = OrderSymbol();
   if (OrderClose(OrderTicket(), OrderLots(), MarketInfo(tmp_str00004, MODE_ASK), (int)MarketInfo(tmp_str00003, MODE_SPREAD), 4294967295)) { 
   Print("Sell ticket ", OrderTicket(), " closed");
   Li_FFFFC = Li_FFFFC + 1;
   } 
   else { 
   tmp_str00005 = ErrorDescription(GetLastError());
   Print("Cannot close sell ticket ", OrderTicket(), " error: ", tmp_str00005);
   }} 
   if (OrderType() == OP_BUYSTOP) { 
   if (OrderDelete(OrderTicket(), 4294967295)) { 
   Print("Buy Stop Ticket ", OrderTicket(), " deleted");
   Li_FFFFC = Li_FFFFC + 1;
   } 
   else { 
   tmp_str00006 = ErrorDescription(GetLastError());
   Print("Cannot delete buy stop ticket ", OrderTicket(), " error: ", tmp_str00006);
   }} 
   if (OrderType() == OP_SELLSTOP) { 
   if (OrderDelete(OrderTicket(), 4294967295)) { 
   Print("Sell Stop Ticket ", OrderTicket(), " deleted");
   Li_FFFFC = Li_FFFFC + 1;
   } 
   else { 
   tmp_str00007 = ErrorDescription(GetLastError());
   Print("Cannot delete sell stop ticket ", OrderTicket(), " error: ", tmp_str00007);
   }}} 
   Li_FFFF8 = Li_FFFF8 - 1;
   } while (Li_FFFF8 >= 0); 
   } 
   if (Li_FFFFC <= 0) return; 
   Ib_00024 = true;
   Il_00028 = iTime(NULL, 1440, 0);
   Print("Closed By ", Fa_s_00);
   tmp_str00008 = StringConcatenate(Is_00030, iTime(NULL, 0, 0));
   ObjectCreate(0, tmp_str00008, OBJ_VLINE, 0, iTime(NULL, 0, 0), 0, 0, 0, 0, 0);
   tmp_str00009 = StringConcatenate(Is_00030, iTime(NULL, 0, 0));
   ObjectSet(tmp_str00009, OBJPROP_COLOR, 65535);
   
}



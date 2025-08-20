#property copyright "";
#property link "";
#property version "1.0";
#property strict
#property description "Gold Rush Pro MT4 is an EA that works with Martingale, Scalping and News strategy.\n \nTimeframe : M1\nMetals : Gold (XAU / USD), But You Can Try Other Pairs.\n \nFollow Me On Telegram: https://t.me/GoldRushVN \nOpen Account On Link : https://one.exnesstrack.com/a/kw6ebqhwhl\nContact : +84906658162 / Telegram : @kanp110";

#import "stdlib.ex4"

string ErrorDescription(int);

#import

enum M
{
   x20 = 0, // x2
   x19 = 1, // x1.9
   x18 = 2, // x1.8
   x17 = 3, // x1.7
   x16 = 4, // x1.6
   x15 = 5, // x1.5
   x14 = 6, // x1.4
   x13 = 7, // x1.3
   x12 = 8, // x1.2 (Default)
   x11 = 9, // x1.1
   x10 = 10 // x1
};

enum STRATEGIES
{
   sg_1 = 1, // Buy & Sell Rotating
   sg_2 = 2, // Candlestick Charts
   sg_3 = 3 // Balance Hedging
};

enum CURRENCIES
{
   sym_1 = 1, // < All Symbols >
   sym_2 = 2, // < Current Symbol >
   sym_3 = 3, // < Current Symbol + Defined >
   sym_4 = 4 // < Only Defined >
};

enum POWERNEWS
{
   stars_1 = 1, // < 1+ Stars>
   stars_2 = 2, // < 2+ Stars>
   stars_3 = 3 // < 3 Stars>
};

enum UPDATE
{
   upd_5 = 5, // < 05 minutes >
   upd_10 = 10, // < 10 minutes >
   upd_15 = 15, // < 15 minutes >
   upd_30 = 30, // < 30 minutes >
   upd_60 = 60 // < 60 minutes >
};

enum TIMEOFFSET
{
   offset_t12 = -12, // < -12 >
   offset_t11 = -11, // < -11 >
   offset_t10 = -10, // < -10 >
   offset_t9 = -9, // < -09 >
   offset_t8 = -8, // < -08 >
   offset_t7 = -7, // < -07 >
   offset_t6 = -6, // < -06 >
   offset_t5 = -5, // < -05 >
   offset_t4 = -4, // < -04 >
   offset_t3 = -3, // < -03 >
   offset_t2 = -2, // < -02 >
   offset_t1 = -1, // < -01 >
   offset_0 = 0, // < UTC >
   offset_c1 = 1, // < +01 >
   offset_c2 = 2, // < +02 >
   offset_c3 = 3, // < +03 >
   offset_c4 = 4, // < +04 >
   offset_c5 = 5, // < +05 >
   offset_c6 = 6, // < +06 >
   offset_c7 = 7, // < +07 >
   offset_c8 = 8, // < +08 >
   offset_c9 = 9, // < +09 >
   offset_c10 = 10, // < +10 >
   offset_c11 = 11, // < +11 >
   offset_c12 = 12 // < +12 >
};

enum ENUM_HOURS
{
   hour_00 = 0, // 00
   hour_01 = 1, // 01
   hour_02 = 2, // 02
   hour_03 = 3, // 03
   hour_04 = 4, // 04
   hour_05 = 5, // 05
   hour_06 = 6, // 06
   hour_07 = 7, // 07
   hour_08 = 8, // 08
   hour_09 = 9, // 09
   hour_10 = 10, // 10
   hour_11 = 11, // 11
   hour_12 = 12, // 12
   hour_13 = 13, // 13
   hour_14 = 14, // 14
   hour_15 = 15, // 15
   hour_16 = 16, // 16
   hour_17 = 17, // 17
   hour_18 = 18, // 18
   hour_19 = 19, // 19
   hour_20 = 20, // 20
   hour_21 = 21, // 21
   hour_22 = 22, // 22
   hour_23 = 23 // 23
};

extern string InputParameter = "General Settings"; // ++++++++++
extern int Magic = 14072022; // Magic Number
extern string comment = "GoldRushPro"; // Comments
extern double Lots = 0.01; // Initial Lot
extern int MaxTrades = 13; // Max Trades (Cycle) [0 = Off]
extern double MinProfit = 0.002; // Min Profit
extern int Dist = 20; // Distance
extern int Step = 20; // Pip Steps
extern M Layer_Multiplier = x12; // Lot Exponent
extern double MaxSpread = 200; // Max Spread [0 = Off]
extern int BreakTime; // Break Time (Minutes) [0 = Off]
extern string MoneyManagement = "Money Management Settings"; // ++++++++++
extern bool SetAutoLot = true; // Use AutoLot
extern double BalanceInit = 1000; // Balance Per Initial Lot (AutoLot) [0 = Off]
extern double BalanceCycle = 200; // Balance Per Cycle (AutoLot) [0 = Off]
extern double MaximumInitLot = 0.25; // Maximum Lot (AutoLot)
extern bool SetMMPlus; // SetMM Plus (+)
extern double TargetPlus = 50; // $ Target Day (+)
extern bool SetMMMinus; // SetMM Risk Loss (-)
extern double TargetMinus = 50; // % Risk Loss (-)
extern string Strategies = "Strategies Settings"; // ++++++++++
extern STRATEGIES SetStrategies = sg_1; // Strategies
extern bool SetAverageBar = true; // Use Average Bar
extern int HowBar = 100; // How Bar
extern double ExpBar = 1; // Exp Bar
extern bool SetEMA; // Use EMA
extern int EMAFast = 5; // EMA Fast
extern int EMAMedium = 8; // EMA Medium
extern int EMALow = 13; // EMA Low
extern string NewsSetting = "News Filter Settings"; // ++++++++++
extern bool SetNews = true; // News Filter
extern CURRENCIES SetSymbol = sym_3; // Filter News By Currencies
extern string DefinedCurrencies = "USD,"; // Defined Currencies
extern POWERNEWS SetPowerNews = stars_2; // Filter By Volatility
extern UPDATE SetUpdateTime = upd_60; // Update Interval
extern int BeforeNewsTime = 2; // (Hours) Stop Trading Before And After The News
extern TIMEOFFSET SetTimeOffset = offset_0; // Server Time Offset
extern bool AllowPanelAtChartRight; // Allow Panel At Chart Right
extern string TimeLine = "Times Settings"; // ++++++++++
extern bool InpUseTime = true; // Use Time
extern ENUM_HOURS InpStartHour = hour_01; // Start Hour
extern ENUM_HOURS InpEndHour = hour_22; // End Hour
extern bool MondayOrders = true; // Monday Orders
extern bool TuesdayOrders = true; // Tuesday Orders
extern bool WednesdayOrders = true; // Wednesday Orders
extern bool ThursdayOrders = true; // Thursday Orders
extern bool FridayOrders; // Friday Orders
extern bool SaturdayOrders; // Saturday Orders
extern bool SundayOrders; // Sunday Orders
extern string Infomations = "Infomation Settings"; // ++++++++++
extern bool SetInfo = true; // Infomations

string Is_046C8;
bool Ib_00044;
bool Ib_0004C;
bool Ib_00054;
bool Ib_0005C;
int Gi_00000;
double Gd_00001;
bool returned_b;
bool Gb_00002;
double Ind_000;
double Gd_00002;
double Id_046F8;
double Ind_004;
int Ist_04710;
double Id_04708;
int Ist_04712;
double Id_04700;
int Gi_00003;
int Ii_04714;
double Gd_00004;
int Gi_00002;
int Ii_04718;
double Gd_00005;
double Gd_00006;
int Gi_00005;
int Ii_00634;
string Is_00618;
int Ii_005EC;
long Il_00090;
long Gl_00005;
long Gl_00007;
int Gi_00007;
long Gl_00008;
int returned_i;
double Gd_00008;
int Gi_00008;
long Gl_00009;
double Gd_00009;
int Gi_00009;
string Is_00628;
int Ii_003EC;
long Gl_0000A;
int Ii_00080;
bool Ib_00070;
long Gl_00002;
bool Ib_00020;
bool Gb_00000;
double Id_04720;
double Ind_002;
double Gd_00000;
double Id_04730;
bool Gb_00001;
double Id_04728;
int Gi_00006;
long Il_04778;
long returned_l;
double Id_04770;
double Id_04758;
double Id_04760;
double Id_04768;
double Gd_0000A;
bool Gb_0000A;
double Id_04748;
double Id_04750;
double Id_04740;
int Gi_0000A;
int Gi_0000B;
int Gi_0000C;
int Ii_0478C;
int Ii_005E8;
double Id_04798;
double Id_04790;
bool Gb_0000B;
double Gd_0000B;
double Gd_0000D;
double Gd_0000E;
double Gd_0000F;
double Gd_00010;
bool Ib_047C0;
double Gd_00011;
int Gi_00012;
int Gi_00013;
long Gl_00012;
double Gd_00012;
bool Gb_00012;
bool Gb_00018;
int Gi_00018;
double Gd_00019;
bool Gb_00019;
double Gd_0001A;
int Gi_0001B;
double Gd_0001B;
double Gd_0001C;
int Gi_0001D;
double Gd_0001E;
bool Gb_0001E;
double Gd_0001F;
int Gi_00020;
double Gd_00020;
double Gd_00021;
int Gi_00022;
long Il_046E0;
long Il_046D8;
int Gi_00024;
long Gl_00024;
bool Ib_046F0;
long Il_046E8;
double Gd_00025;
double Gd_00026;
double Gd_00027;
bool Gb_00027;
int Gi_00027;
double Gd_00028;
double Gd_00029;
double Gd_0002A;
bool Gb_0002A;
bool Gb_0002B;
bool Gb_0002C;
bool Gb_0002D;
bool Gb_0002E;
bool Gb_0002F;
bool Gb_00030;
bool Ib_047C1;
bool Ib_047C2;
bool Ib_047C3;
double Id_047C8;
double Id_047D0;
double Id_047D8;
double Id_047E0;
bool Gb_00031;
bool Ib_047C4;
bool Ib_047C5;
bool Ib_047C6;
bool Ib_047C7;
int Gi_00031;
int Gi_00032;
bool Gb_00033;
double Gd_00031;
double Gd_00032;
int Gi_00033;
long Gl_00034;
int Gi_00035;
int Gi_00036;
double Gd_00037;
double Gd_00038;
int Gi_00039;
int Gi_0003A;
int Gi_0003B;
bool Gb_0003A;
bool Gb_0003C;
bool Gb_0003F;
double Gd_00042;
bool Gb_00043;
int Gi_00043;
int Gi_00044;
double Gd_00044;
int Ii_04788;
double Gd_00045;
int Gi_00046;
bool Gb_00047;
double Gd_00046;
int Gi_00047;
long Gl_00048;
int Gi_00049;
int Gi_0004A;
double Gd_0004B;
double Gd_0004C;
int Gi_0004D;
int Gi_0004E;
int Gi_0004F;
bool Gb_0004E;
bool Gb_00050;
bool Gb_00053;
double Gd_00056;
bool Gb_00057;
int Gi_00057;
int Gi_00058;
double Gd_00058;
double Gd_00059;
int Gi_0005A;
bool Gb_0005B;
double Gd_0005A;
int Gi_0005B;
int Gi_0005C;
bool Gb_0005D;
double Gd_0005B;
double Gd_0005C;
int Gi_0005D;
int Gi_0005E;
bool Gb_0005F;
double Gd_0005D;
double Gd_0005E;
int Gi_0005F;
int Gi_00060;
double Gd_00061;
double Gd_00062;
int Gi_00063;
int Gi_00064;
int Gi_00065;
bool Gb_00064;
bool Gb_00066;
bool Gb_00069;
double Gd_0006C;
bool Gb_0006D;
int Gi_0006D;
int Gi_0006E;
double Gd_0006E;
double Gd_0006F;
int Gi_00070;
bool Gb_00071;
double Gd_00070;
int Gi_00071;
int Gi_00072;
bool Gb_00073;
double Gd_00071;
double Gd_00072;
int Gi_00073;
int Gi_00074;
bool Gb_00075;
double Gd_00073;
double Gd_00074;
int Gi_00075;
int Gi_00076;
double Gd_00077;
double Gd_00078;
int Gi_00079;
int Gi_0007A;
int Gi_0007B;
bool Gb_0007A;
bool Gb_0007C;
bool Gb_0007F;
double Gd_00082;
bool Gb_00083;
int Gi_00083;
int Gi_00084;
double Gd_00084;
double Gd_00085;
int Gi_00086;
bool Gb_00087;
double Gd_00086;
int Gi_00087;
long Gl_00088;
int Gi_00089;
int Gi_0008A;
double Gd_0008B;
double Gd_0008C;
int Gi_0008D;
int Gi_0008E;
int Gi_0008F;
bool Gb_0008E;
bool Gb_00090;
bool Gb_00093;
double Gd_00096;
bool Gb_00097;
int Gi_00097;
int Gi_00098;
double Gd_00098;
double Gd_00099;
int Gi_0009A;
bool Gb_0009B;
double Gd_0009A;
int Gi_0009B;
long Gl_0009C;
int Gi_0009D;
int Gi_0009E;
double Gd_0009F;
double Gd_000A0;
int Gi_000A1;
int Gi_000A2;
int Gi_000A3;
bool Gb_000A2;
bool Gb_000A4;
bool Gb_000A7;
double Gd_000AA;
bool Gb_000AB;
int Gi_000AB;
int Gi_000AC;
double Gd_000AC;
double Gd_000AD;
int Gi_000AE;
bool Gb_000AF;
double Gd_000AE;
int Gi_000AF;
int Gi_000B0;
bool Gb_000B1;
double Gd_000AF;
double Gd_000B0;
int Gi_000B1;
int Gi_000B2;
bool Gb_000B3;
double Gd_000B1;
double Gd_000B2;
int Gi_000B3;
int Gi_000B4;
double Gd_000B5;
double Gd_000B6;
int Gi_000B7;
int Gi_000B8;
int Gi_000B9;
bool Gb_000B8;
bool Gb_000BA;
bool Gb_000BD;
double Gd_000C0;
bool Gb_000C1;
int Gi_000C1;
int Gi_000C2;
double Gd_000C2;
double Gd_000C3;
int Gi_000C4;
bool Gb_000C5;
double Gd_000C4;
int Gi_000C5;
int Gi_000C6;
bool Gb_000C7;
double Gd_000C5;
double Gd_000C6;
int Gi_000C7;
int Gi_000C8;
bool Gb_000C9;
double Gd_000C7;
double Gd_000C8;
int Gi_000C9;
int Gi_000CA;
double Gd_000CB;
double Gd_000CC;
int Gi_000CD;
int Gi_000CE;
int Gi_000CF;
bool Gb_000CE;
bool Gb_000D0;
bool Gb_000D3;
double Gd_000D6;
bool Gb_000D7;
int Gi_000D7;
int Gi_000D8;
double Gd_000D8;
double Gd_000D9;
int Gi_000DA;
double Gd_000DB;
double Gd_000DC;
int Gi_000DD;
int Gi_000DE;
int Gi_000DF;
bool Gb_000DE;
bool Gb_000E0;
bool Gb_000E3;
double Gd_000E6;
bool Gb_000E7;
int Gi_000E7;
int Gi_000E8;
double Gd_000E8;
double Gd_000E9;
int Gi_000EA;
double Gd_000EB;
double Gd_000EC;
int Gi_000ED;
int Gi_000EE;
int Gi_000EF;
bool Gb_000EE;
bool Gb_000F0;
bool Gb_000F3;
double Gd_000F6;
bool Gb_000F7;
int Gi_000F7;
int Gi_000F8;
double Gd_000F8;
double Gd_000F9;
string Is_04800;
int Gi_000FA;
double Gd_000FB;
double Id_04738;
bool Gb_000FB;
int Ii_0471C;
int Gi_000FB;
int Gi_000FC;
bool Gb_000FD;
double Gd_000FC;
int Gi_000FD;
int Gi_000FE;
double Gd_000FF;
int Gi_00100;
double Gd_00101;
int Gi_00102;
int Gi_00103;
int Gi_00104;
bool Gb_00103;
double Gd_00103;
bool Gb_00105;
double Gd_00105;
double Gd_00107;
double Gd_00108;
int Gi_00109;
int Gi_0010A;
int Gi_0010B;
bool Gb_0010A;
bool Gb_0010C;
bool Gb_0010F;
double Gd_00112;
bool Gb_00113;
int Gi_00113;
int Gi_00114;
double Gd_00114;
double Gd_00115;
int Gi_00116;
bool Gb_00117;
double Gd_00116;
int Gi_00117;
int Gi_00118;
double Gd_00119;
int Gi_0011A;
double Gd_0011B;
int Gi_0011C;
int Gi_0011D;
int Gi_0011E;
bool Gb_0011D;
double Gd_0011D;
bool Gb_0011F;
double Gd_0011F;
double Gd_00121;
double Gd_00122;
int Gi_00123;
int Gi_00124;
int Gi_00125;
bool Gb_00124;
bool Gb_00126;
bool Gb_00129;
double Gd_0012C;
bool Gb_0012D;
int Gi_0012D;
int Gi_0012E;
double Gd_0012E;
double Gd_0012F;
double Gd_00130;
int Gi_00131;
int Gi_00132;
double Gd_00131;
double Id_047E8;
int Gi_00133;
bool Gb_00134;
int Gi_00134;
double Gd_00135;
bool Gb_00135;
double Gd_00136;
int Gi_00137;
double Gd_00137;
double Gd_00138;
int Gi_00139;
double Gd_0013A;
bool Gb_0013A;
double Gd_0013B;
int Gi_0013C;
double Gd_0013C;
double Gd_0013D;
int Gi_0013E;
int Gi_0013F;
bool Gb_00140;
int Gi_00140;
double Gd_00141;
bool Gb_00141;
double Gd_00142;
int Gi_00143;
double Gd_00143;
double Gd_00144;
int Gi_00145;
double Gd_00146;
bool Gb_00146;
double Gd_00147;
int Gi_00148;
double Gd_00148;
double Gd_00149;
int Gi_0014A;
long Gl_00158;
int Ii_047F8;
int Ii_047FC;
int Ii_047F0;
int Ii_047F4;
int Gi_00158;
int Gi_00159;
int Gi_0015A;
long Gl_00159;
double Gd_00159;
double Gd_0015B;
int Gi_0015C;
int Gi_0015D;
double Gd_0015C;
long Gl_0015C;
double Gd_0015E;
int Gi_0015F;
int Gi_00160;
double Gd_0015F;
long Gl_0015F;
double Gd_00161;
int Gi_00162;
int Gi_00163;
long Gl_00162;
double Gd_00162;
double Gd_00164;
int Gi_00165;
int Gi_00166;
long Gl_00165;
double Gd_00165;
double Gd_00167;
int Gi_00168;
int Gi_00169;
long Gl_00168;
double Gd_00168;
double Gd_0016A;
int Gi_0016B;
int Gi_0016C;
long Gl_0016B;
double Gd_0016B;
int Gi_0014B;
bool Gb_0014C;
int Gi_0014C;
int Gi_0014D;
bool Gb_0014E;
int Gi_0014E;
double Gd_0014F;
bool Gb_0014F;
double Gd_00150;
int Gi_00151;
double Gd_00151;
double Gd_00152;
int Gi_00153;
double Gd_00154;
bool Gb_00154;
double Gd_00155;
int Gi_00156;
double Gd_00156;
double Gd_00157;
bool Gb_0012A;
double Gd_0012A;
double Gd_0012B;
bool Gb_0012B;
bool Gb_0012C;
bool Gb_00127;
double Gd_00127;
double Gd_00128;
bool Gb_00128;
double Gd_00129;
bool Gb_00120;
double Gd_00120;
int Gi_00120;
bool Gb_00121;
bool Gb_00110;
double Gd_00110;
double Gd_00111;
bool Gb_00111;
bool Gb_00112;
bool Gb_0010D;
double Gd_0010D;
double Gd_0010E;
bool Gb_0010E;
double Gd_0010F;
bool Gb_00106;
double Gd_00106;
int Gi_00106;
bool Gb_00107;
bool Gb_000F4;
double Gd_000F4;
double Gd_000F5;
bool Gb_000F5;
bool Gb_000F6;
bool Gb_000F1;
double Gd_000F1;
double Gd_000F2;
bool Gb_000F2;
double Gd_000F3;
bool Gb_000E4;
double Gd_000E4;
double Gd_000E5;
bool Gb_000E5;
bool Gb_000E6;
bool Gb_000E1;
double Gd_000E1;
double Gd_000E2;
bool Gb_000E2;
double Gd_000E3;
bool Gb_000D4;
double Gd_000D4;
double Gd_000D5;
bool Gb_000D5;
bool Gb_000D6;
bool Gb_000D1;
double Gd_000D1;
double Gd_000D2;
bool Gb_000D2;
double Gd_000D3;
bool Gb_000BE;
double Gd_000BE;
double Gd_000BF;
bool Gb_000BF;
bool Gb_000C0;
bool Gb_000BB;
double Gd_000BB;
double Gd_000BC;
bool Gb_000BC;
double Gd_000BD;
bool Gb_000A8;
double Gd_000A8;
double Gd_000A9;
bool Gb_000A9;
bool Gb_000AA;
bool Gb_000A5;
double Gd_000A5;
double Gd_000A6;
bool Gb_000A6;
double Gd_000A7;
bool Gb_00094;
double Gd_00094;
double Gd_00095;
bool Gb_00095;
bool Gb_00096;
bool Gb_00091;
double Gd_00091;
double Gd_00092;
bool Gb_00092;
double Gd_00093;
bool Gb_00080;
double Gd_00080;
double Gd_00081;
bool Gb_00081;
bool Gb_00082;
bool Gb_0007D;
double Gd_0007D;
double Gd_0007E;
bool Gb_0007E;
double Gd_0007F;
bool Gb_0006A;
double Gd_0006A;
double Gd_0006B;
bool Gb_0006B;
bool Gb_0006C;
bool Gb_00067;
double Gd_00067;
double Gd_00068;
bool Gb_00068;
double Gd_00069;
bool Gb_00054;
double Gd_00054;
double Gd_00055;
bool Gb_00055;
bool Gb_00056;
bool Gb_00051;
double Gd_00051;
double Gd_00052;
bool Gb_00052;
double Gd_00053;
bool Gb_00040;
double Gd_00040;
double Gd_00041;
bool Gb_00041;
bool Gb_00042;
bool Gb_0003D;
double Gd_0003D;
double Gd_0003E;
bool Gb_0003E;
double Gd_0003F;
bool Gb_00022;
long Il_04780;
long Gl_00022;
int Gi_00023;
long Gl_00023;
double Gd_00014;
int Gi_00015;
int Gi_00016;
long Gl_00015;
double Gd_00015;
bool Gb_00015;
int Gi_00017;
long Gl_00017;
double Gd_00003;
bool Gb_00003;
bool Gb_00004;
bool Gb_00005;
bool Gb_00006;
bool Ib_00000;
bool Ib_00001;
string Is_00008;
bool Ib_00014;
long Il_00018;
bool Ib_00021;
int Ii_00024;
int Ii_00028;
string Is_00030;
int Ii_0003C;
int Ii_00040;
int Ii_00048;
int Ii_00050;
int Ii_00058;
int Ii_00060;
bool Ib_00064;
int Ii_00068;
int Ii_0006C;
bool Ib_00071;
bool Ib_00072;
bool Ib_00073;
bool Ib_00074;
bool Ib_00075;
bool Ib_00076;
bool Ib_00077;
bool Ib_00078;
bool Ib_00079;
int Ii_0007C;
int Ii_00084;
long Il_00088;
int Ii_003F0;
int Ii_003F4;
int Ii_003F8;
int Ii_003FC;
int Ii_00400;
int Ii_00404;
int Ii_005CC;
int Ii_005D0;
int Ii_005D4;
int Ii_005D8;
int Ii_005DC;
int Ii_005E0;
int Ii_005E4;
int Ii_005F0;
int Ii_005F4;
int Ii_005F8;
int Ii_005FC;
int Ii_00600;
int Ii_00604;
int Ii_00608;
int Ii_0060C;
int Ii_00610;
int Ii_00614;
int Ii_00638;
string Is_00640;
string Is_00650;
string Is_02760;
string Is_02770;
string Is_02780;
string Is_02790;
string Is_04608;
string Is_04618;
string Is_04628;
string Is_04638;
string Is_04648;
string Is_04658;
string Is_04668;
string Is_04678;
string Is_04688;
string Is_04698;
string Is_046A8;
string Is_046B8;
double Id_047A0;
double Id_047A8;
double Id_047B0;
double Id_047B8;
long Gl_00000;
int Gi_00004;
string Gs_00004;
string Gs_00005;
string Gs_00006;
string Gs_00007;
string Gs_00008;
string Gs_0000A;
string Gs_0000C;
int Gi_0000D;
int Gi_0000E;
string Gs_0000D;
string Gs_0000E;
int Gi_0000F;
string Gs_0000F;
int Gi_00010;
string Gs_00010;
bool Gb_00011;
int Gi_0001C;
string Gs_0001B;
string Gs_0001C;
long Gl_0001D;
int Gi_0001E;
long Gl_0001E;
string Gs_0001F;
string Gs_0001E;
string Gs_00021;
string Gs_00020;
double Gd_00022;
string Gs_00012;
string Gs_00013;
int Gi_00014;
string Gs_00014;
string Gs_00015;
string Gs_00016;
string Gs_00017;
int Gi_00019;
string Gs_00018;
string Gs_00019;
int Gi_0001A;
string Gs_0001A;
int Gi_00025;
int Gi_00026;
int Gi_00028;
string Gs_00028;
string Gs_00023;
int Gi_00029;
string Gs_00029;
string Gs_00027;
int Gi_0002A;
string Gs_0002A;
string Gs_00026;
int Gi_0002B;
string Gs_0002B;
string Gs_00025;
int Gi_0002C;
string Gs_0002C;
string Gs_00024;
int Gi_0002D;
int Gi_0002E;
double Gd_0002D;
int Gi_0002F;
int Gi_00030;
int Gi_00034;
string Gs_00034;
string Gs_0002E;
string Gs_00035;
string Gs_00033;
string Gs_00036;
string Gs_00032;
int Gi_00037;
string Gs_00037;
string Gs_00031;
int Gi_00038;
string Gs_00038;
string Gs_00030;
double Gd_00039;
int Gi_0003C;
int Gi_0003D;
int Gi_0003E;
int Gi_0003F;
int Gi_00040;
string Gs_00040;
string Gs_0003A;
int Gi_00041;
string Gs_00041;
string Gs_0003F;
int Gi_00042;
string Gs_00042;
string Gs_0003E;
string Gs_00043;
string Gs_0003D;
string Gs_00044;
string Gs_0003C;
int Gi_00045;
int Gi_00048;
int Gi_0004B;
int Gi_0004C;
string Gs_0004C;
string Gs_00046;
string Gs_0004D;
string Gs_0004B;
string Gs_0004E;
string Gs_0004A;
string Gs_0004F;
string Gs_00049;
int Gi_00050;
string Gs_00050;
string Gs_00048;
int Gi_00051;
int Gi_00052;
int Gi_00053;
int Gi_00054;
int Gi_00055;
int Gi_00056;
string Gs_00056;
string Gs_00057;
string Gs_00058;
int Gi_00059;
string Gs_00059;
string Gs_0005A;
string Gs_0005B;
string Gs_0005D;
string Gs_0005C;
string Gs_0005F;
string Gs_0005E;
int Gi_00061;
string Gs_00061;
string Gs_00060;
int Gi_00062;
string Gs_00063;
string Gs_00062;
string Gs_00065;
string Gs_00064;
int Gi_00066;
int Gi_00067;
int Gi_00090;
int Gi_00091;
int Gi_00092;
int Gi_00093;
int Gi_00094;
int Gi_00095;
string Gs_00095;
string Gs_00090;
int Gi_00096;
string Gs_00096;
string Gs_00094;
string Gs_00097;
string Gs_00093;
string Gs_00098;
string Gs_00092;
int Gi_00099;
string Gs_00099;
string Gs_00091;
int Gi_0009C;
string Gs_0009E;
int Gi_0009F;
string Gs_0009F;
int Gi_000A0;
string Gs_000A0;
string Gs_000A1;
string Gs_000A2;
string Gs_000A3;
int Gi_000A4;
int Gi_000A5;
string Gs_000A5;
string Gs_000A4;
int Gi_000A6;
int Gi_000A7;
string Gs_000A7;
string Gs_000A6;
int Gi_000A8;
int Gi_000A9;
string Gs_000A9;
string Gs_000A8;
int Gi_000AA;
string Gs_000AB;
string Gs_000AA;
int Gi_000AD;
string Gs_000AD;
string Gs_000AC;
int Gi_000C3;
string Gs_000C3;
string Gs_000C4;
string Gs_000C5;
string Gs_000C6;
string Gs_000C7;
string Gs_000C8;
string Gs_000CA;
string Gs_000C9;
int Gi_000CB;
int Gi_000CC;
string Gs_000CC;
string Gs_000CB;
string Gs_000CE;
string Gs_000CD;
int Gi_000D0;
string Gs_000D0;
string Gs_000CF;
int Gi_000D1;
int Gi_000D2;
string Gs_000D2;
string Gs_000D1;
int Gi_000D3;
int Gi_000D4;
int Gi_000E6;
string Gs_000E8;
int Gi_000E9;
string Gs_000E9;
string Gs_000EA;
int Gi_000EB;
string Gs_000EB;
int Gi_000EC;
string Gs_000EC;
string Gs_000ED;
string Gs_000EF;
string Gs_000EE;
int Gi_000F0;
int Gi_000F1;
string Gs_000F1;
string Gs_000F0;
int Gi_000F2;
int Gi_000F3;
string Gs_000F3;
string Gs_000F2;
int Gi_000F4;
int Gi_000F5;
string Gs_000F5;
string Gs_000F4;
int Gi_000F6;
string Gs_000F7;
string Gs_000F6;
int Gi_000F9;
int Gi_0010C;
int Gi_0010D;
string Gs_0010D;
int Gi_0010E;
string Gs_0010E;
int Gi_0010F;
string Gs_0010F;
int Gi_00110;
string Gs_00110;
int Gi_00111;
string Gs_00111;
int Gi_00112;
string Gs_00112;
string Gs_00114;
string Gs_00113;
int Gi_00115;
string Gs_00116;
string Gs_00115;
string Gs_00118;
string Gs_00117;
int Gi_00119;
string Gs_0011A;
string Gs_00119;
int Gi_0011B;
string Gs_0011C;
string Gs_0011B;
int Gi_0011F;
string Gs_0011F;
string Gs_00120;
int Gi_00121;
int Gi_00122;
int Gi_00126;
string Gs_00125;
string Gs_00126;
int Gi_00127;
int Gi_00128;
int Gi_00129;
int Gi_0012A;
string Gs_00128;
string Gs_0012A;
int Gi_0012B;
int Gi_0012C;
int Gi_0012F;
int Gi_00130;
string Gs_00131;
string Gs_00132;
int Gi_00135;
int Gi_00136;
string Gs_00134;
string Gs_00136;
int Gi_00138;
int Gi_0013A;
int Gi_0013B;
int Gi_0013D;
string Gs_0013F;
string Gs_00140;
int Gi_00141;
string Gs_00141;
int Gi_00142;
string Gs_00142;
int Gi_00144;
string Gs_00144;
string Gs_00143;
int Gi_00146;
string Gs_00146;
string Gs_00145;
int Gi_00147;
string Gs_00148;
string Gs_00147;
int Gi_00149;
string Gs_0014A;
string Gs_00149;
string Gs_0014C;
string Gs_0014B;
int Gi_0014F;
int Gi_00150;
string Gs_00150;
string Gs_0014F;
int Gi_00152;
string Gs_00152;
string Gs_00151;
int Gi_00154;
string Gs_00154;
string Gs_00153;
int Gi_00155;
string Gs_00156;
string Gs_00155;
int Gi_00157;
string Gs_00158;
string Gs_00157;
int Gi_0015B;
string Gs_0015C;
string Gs_0015B;
int Gi_0015E;
string Gs_0015E;
string Gs_0015D;
string Gs_00160;
string Gs_0015F;
int Gi_00161;
string Gs_00162;
string Gs_00161;
int Gi_00164;
string Gs_00164;
string Gs_00163;
int Gi_00167;
string Gs_00168;
string Gs_00167;
int Gi_0016A;
string Gs_0016A;
string Gs_00169;
string Gs_0016C;
string Gs_0016B;
int Gi_0016D;
int Gi_0016E;
string Gs_0016E;
string Gs_0016D;
int Gi_0016F;
int Gi_00170;
string Gs_00170;
string Gs_0016F;
int Gi_00171;
int Gi_00172;
string Gs_000FE;
int Gi_000FF;
string Gs_00100;
string Gs_000FF;
int Gi_00101;
string Gs_00102;
string Gs_00101;
string Gs_00104;
string Gs_00103;
int Gi_00105;
string Gs_00106;
string Gs_00105;
int Gi_00107;
int Gi_00108;
string Gs_00108;
string Gs_00107;
int Gi_000D5;
int Gi_000D6;
int Gi_000D9;
string Gs_000D9;
int Gi_000DB;
string Gs_000DB;
string Gs_000DA;
int Gi_000DC;
string Gs_000DD;
string Gs_000DC;
string Gs_000DF;
string Gs_000DE;
int Gi_000E0;
int Gi_000E1;
string Gs_000E1;
string Gs_000E0;
int Gi_000E2;
int Gi_000E3;
string Gs_000E3;
string Gs_000E2;
int Gi_000E4;
int Gi_000E5;
string Gs_000B4;
int Gi_000B5;
int Gi_000B6;
string Gs_000B6;
string Gs_000B5;
string Gs_000B8;
string Gs_000B7;
int Gi_000BA;
string Gs_000BA;
string Gs_000B9;
int Gi_000BB;
int Gi_000BC;
string Gs_000BC;
string Gs_000BB;
int Gi_000BD;
int Gi_000BE;
string Gs_000BE;
string Gs_000BD;
int Gi_000BF;
int Gi_000C0;
int Gi_00068;
int Gi_00069;
int Gi_0006A;
string Gs_0006A;
int Gi_0006B;
string Gs_0006B;
int Gi_0006C;
string Gs_0006C;
string Gs_0006D;
string Gs_0006E;
int Gi_0006F;
string Gs_0006F;
string Gs_00071;
string Gs_00070;
string Gs_00073;
string Gs_00072;
string Gs_00075;
string Gs_00074;
int Gi_00077;
string Gs_00077;
string Gs_00076;
int Gi_00078;
string Gs_00079;
string Gs_00078;
int Gi_0007C;
int Gi_0007D;
int Gi_0007E;
string Gs_0007E;
int Gi_0007F;
string Gs_0007F;
int Gi_00080;
string Gs_00080;
int Gi_00081;
string Gs_00081;
int Gi_00082;
string Gs_00082;
string Gs_00083;
int Gi_00085;
string Gs_00085;
string Gs_00084;
string Gs_00087;
string Gs_00086;
int Gi_00088;
string Gs_00089;
string Gs_00088;
int Gi_0008B;
string Gs_0008B;
string Gs_0008A;
int Gi_0008C;
string Gs_0008D;
string Gs_0008C;
int Gi_00001;
long Gl_00001;
string Gs_00002;
double Ind_003;
long Gl_00019;
long Gl_0002B;
string Gs_0003B;
long Gl_0003D;
long Gl_00043;
string Gs_00045;
string Gs_00047;
string Gs_00039;
string Gs_0002F;
long Gl_00031;
string Gs_0002D;
string Gs_0001D;
long Gl_0001F;
int Gi_0001F;
int Gi_00021;
string Gs_00022;
string Gs_0000B;
long Gl_0000D;
string Gs_00009;
int Gi_00011;
string Gs_00011;
string Gs_00003;
string Gs_00000;

string Is_045B0[7] = { "</title>", "</country>", "]]></date>", "]]></time>", "]]></impact>", "]]></forecast>", "]]></previous>" };
string Is_04528[7] = { "<title>", "<country>", "<date><![CDATA[", "<time><![CDATA[", "<impact><![CDATA[", "<forecast><![CDATA[", "<previous><![CDATA[" };
double Id_000CC[100];
int Ii_0043C[100];
string Is_00690[100][7];
string Is_027D0[100];
string Is_02CB4[100];
string Is_03198[100];
string Is_0367C[100];
string Is_03B60[100];
string Is_04044[100];
string Global_ReturnedString;
double returned_double;
bool order_check;
int init()
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
   string Ls_FFFF0;
   string Ls_FFFE0;
   int Li_FFFFC;
   Ib_00000 = true;
   Ib_00001 = false;
   Is_00008 = "52103743";
   Ib_00014 = true;
   Il_00018 = 2147483647;
   Ib_00020 = false;
   Ib_00021 = true;
   Ii_00024 = 1;
   Ii_00028 = 43200;
   Is_00030 = "1-5-15-30-60-240-1440-10080-43200";
   Ii_0003C = 16777215;
   Ii_00040 = 32768;
   Ib_00044 = false;
   Ii_00048 = 65535;
   Ib_0004C = false;
   Ii_00050 = 255;
   Ib_00054 = false;
   Ii_00058 = 14053594;
   Ib_0005C = false;
   Ii_00060 = 6908265;
   Ib_00064 = true;
   Ii_00068 = 0;
   Ii_0006C = 0;
   Ib_00070 = false;
   Ib_00071 = false;
   Ib_00072 = false;
   Ib_00073 = false;
   Ib_00074 = false;
   Ib_00075 = false;
   Ib_00076 = false;
   Ib_00077 = false;
   Ib_00078 = false;
   Ib_00079 = false;
   Ii_0007C = 0;
   Ii_00080 = 0;
   Ii_00084 = 0;
   Il_00088 = 0;
   Il_00090 = 0;
   Ii_003EC = 0;
   Ii_003F0 = 0;
   Ii_003F4 = 0;
   Ii_003F8 = 0;
   Ii_003FC = 0;
   Ii_00400 = 0;
   Ii_00404 = 0;
   Ii_005CC = 0;
   Ii_005D0 = 0;
   Ii_005D4 = 0;
   Ii_005D8 = 0;
   Ii_005DC = 0;
   Ii_005E0 = 0;
   Ii_005E4 = 0;
   Ii_005E8 = 0;
   Ii_005EC = 0;
   Ii_005F0 = 0;
   Ii_005F4 = 0;
   Ii_005F8 = 0;
   Ii_005FC = 0;
   Ii_00600 = 0;
   Ii_00604 = 0;
   Ii_00608 = 8;
   Ii_0060C = 7;
   Ii_00610 = 4;
   Ii_00614 = 9;
   Ii_00634 = 0;
   Ii_00638 = 10;
   Is_00640 = "https://nfs.faireconomy.media/ff_calendar_thisweek.xml";
   Is_04608 = "Arial";
   Is_04618 = "n[GoldRushNews] Box1";
   Is_04628 = "n[GoldRushNews] Box2";
   Is_04638 = "n[GoldRushNews] News1";
   Is_04648 = "n[GoldRushNews] News2";
   Is_04658 = "n[GoldRushNews] News3";
   Is_04668 = "n[GoldRushNews] News4";
   Is_04678 = "n[GoldRushNews] Sponsor";
   Is_04688 = "n[GoldRushNews] VLineNews 1";
   Is_04698 = "n[GoldRushNews] VLineNews 2";
   Is_046A8 = "n[GoldRushNews] VLineNews 3";
   Is_046B8 = "n[GoldRushNews] VLineNews 4";
   Il_046D8 = 0;
   Il_046E0 = 0;
   Il_046E8 = 0;
   Ib_046F0 = true;
   Id_046F8 = 0;
   Id_04700 = 0;
   Id_04708 = 0;
   Ist_04710 = 50000;
   Ist_04712 = 50000;
   Ii_04714 = 16711680;
   Ii_04718 = 255;
   Ii_0471C = 0;
   Id_04720 = 0;
   Id_04728 = 0;
   Id_04730 = 0;
   Id_04738 = 0;
   Id_04740 = 0;
   Id_04748 = 0;
   Id_04750 = 0;
   Id_04758 = 0;
   Id_04760 = 0;
   Id_04768 = 0;
   Id_04770 = 0;
   Il_04778 = 0;
   Il_04780 = 0;
   Ii_04788 = 0;
   Ii_0478C = 0;
   Id_04790 = 0;
   Id_04798 = 0;
   Id_047A0 = 0;
   Id_047A8 = 0;
   Id_047B0 = 0;
   Id_047B8 = 0;
   Ib_047C0 = true;
   Ib_047C1 = false;
   Ib_047C2 = false;
   Ib_047C3 = false;
   Ib_047C4 = false;
   Ib_047C5 = false;
   Ib_047C6 = false;
   Ib_047C7 = false;
   Id_047C8 = 0;
   Id_047D0 = 0;
   Id_047D8 = 0;
   Id_047E0 = 0;
   Id_047E8 = 0;
   Ii_047F0 = 16777215;
   Ii_047F4 = 65535;
   Ii_047F8 = 0;
   Ii_047FC = 7;
   
   //func_1062();
   Ls_FFFF0 = StringSubstr(_Symbol, 0, 3);
   Ls_FFFE0 = StringSubstr(_Symbol, 3, 3);
   if (SetSymbol == 1) { 
   Is_046C8 = "USD,GBP,EUR,CAD,AUD,CHF,JPY,CNY,NZD";
   } 
   else { 
   if (SetSymbol == 2) { 
   tmp_str00000 = Ls_FFFF0 + ",";
   tmp_str00000 = tmp_str00000 + Ls_FFFE0;
   Is_046C8 = tmp_str00000;
   } 
   else { 
   if (SetSymbol == 3) { 
   tmp_str00000 = Ls_FFFF0 + ",";
   tmp_str00000 = tmp_str00000 + Ls_FFFE0;
   tmp_str00000 = tmp_str00000 + ",";
   tmp_str00000 = tmp_str00000 + DefinedCurrencies;
   Is_046C8 = tmp_str00000;
   } 
   else { 
   if (SetSymbol == 4) { 
   Is_046C8 = DefinedCurrencies;
   }}}} 
   if (SetPowerNews == 1) { 
   Ib_00044 = true;
   Ib_0004C = true;
   Ib_00054 = true;
   Ib_0005C = true;
   } 
   else { 
   if (SetPowerNews == 2) { 
   Ib_00044 = false;
   Ib_0004C = true;
   Ib_00054 = true;
   Ib_0005C = true;
   } 
   else { 
   if (SetPowerNews == 3) { 
   Ib_00044 = false;
   Ib_0004C = false;
   Ib_00054 = true;
   Ib_0005C = true;
   }}} 
   Gi_00000 = (int)MarketInfo(_Symbol, MODE_DIGITS);
   Gd_00001 = MarketInfo(_Symbol, MODE_POINT);
   Gb_00002 = (Gi_00000 == 5);
   if (Gb_00002 != true) { 
   Gb_00002 = (Gi_00000 == 3);
   } 
   if (Gb_00002) { 
   Gd_00002 = (Gd_00001 * 10);
   } 
   else { 
   Gd_00002 = Gd_00001;
   } 
   Id_046F8 = Gd_00002;
   Id_04708 = (Ist_04710 * Gd_00002);
   Id_04700 = (Ist_04712 * Gd_00002);
   Gi_00003 = Ii_04714;
   Gd_00002 = ((Dist * Gd_00002) + Ask);
   Gd_00004 = Gd_00002;
   tmp_str00000 = "i[GoldRushNews] LineBuy";
   if (Gd_00002 == 0) { 
   Gd_00004 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectCreate(0, tmp_str00000, OBJ_HLINE, 0, 0, Gd_00004) != true) { 
   tmp_str00001 = ErrorDescription(GetLastError());
   Print("HLineCreate", ": Failed To Create A Horizontal Line! Error Code = ", tmp_str00001);
   } 
   else { 
   ObjectSetInteger(0, tmp_str00000, 6, Gi_00003);
   ObjectSetInteger(0, tmp_str00000, 7, 0);
   ObjectSetInteger(0, tmp_str00000, 8, 1);
   ObjectSetInteger(0, tmp_str00000, 9, 0);
   ObjectSetInteger(0, tmp_str00000, 1000, 1);
   ObjectSetInteger(0, tmp_str00000, 17, 1);
   ObjectSetInteger(0, tmp_str00000, 208, 0);
   ObjectSetInteger(0, tmp_str00000, 207, 0);
   } 
   Gi_00002 = Ii_04718;
   Gd_00005 = (Dist * Id_046F8);
   Gd_00005 = (Bid - Gd_00005);
   Gd_00006 = Gd_00005;
   tmp_str00002 = "i[GoldRushNews] LineSell";
   if (Gd_00005 == 0) { 
   Gd_00006 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectCreate(0, tmp_str00002, OBJ_HLINE, 0, 0, Gd_00006) != true) { 
   Global_ReturnedString = ErrorDescription(GetLastError());
   tmp_str00003 = Global_ReturnedString;
   Print("HLineCreate", ": Failed To Create A Horizontal Line! Error Code = ", tmp_str00003);
   } 
   else { 
   ObjectSetInteger(0, tmp_str00002, 6, Gi_00002);
   ObjectSetInteger(0, tmp_str00002, 7, 0);
   ObjectSetInteger(0, tmp_str00002, 8, 1);
   ObjectSetInteger(0, tmp_str00002, 9, 0);
   ObjectSetInteger(0, tmp_str00002, 1000, 1);
   ObjectSetInteger(0, tmp_str00002, 17, 1);
   ObjectSetInteger(0, tmp_str00002, 208, 0);
   ObjectSetInteger(0, tmp_str00002, 207, 0);
   } 
   Ii_00634 = _Period;
   if (IsDllsAllowed() == false && IsTesting() == false) { 
   Alert(_Symbol, " ", _Period, " ", comment, ": Allow DLL Imports");
   } 
   Global_ReturnedString = func_1019();
   Is_00618 = Global_ReturnedString;
   Ii_005EC = (int)Il_00090;
   Gl_00005 = Il_00090 - 6048000;
   Gl_00007 = Ii_005EC;
   if (Gl_00007 >= Gl_00005) { 
   do { 
   Gi_00007 = 2;
   tmp_str00004 = "0";
   tmp_str00005 = DoubleToString(TimeDay(Ii_005EC), 0);
   Gi_00008 = StringLen(tmp_str00005);
   if (Gi_00008 < 2) { 
   do { 
   tmp_str00005 = StringConcatenate(tmp_str00004, tmp_str00005);
   Gi_00008 = StringLen(tmp_str00005);
   } while (Gi_00008 < Gi_00007); 
   } 
   tmp_str00006 = tmp_str00005;
   Gi_00008 = 2;
   tmp_str00007 = "0";
   tmp_str00008 = DoubleToString(TimeMonth(Ii_005EC), 0);
   Gi_00009 = StringLen(tmp_str00008);
   if (Gi_00009 < 2) { 
   do { 
   tmp_str00008 = StringConcatenate(tmp_str00007, tmp_str00008);
   Gi_00009 = StringLen(tmp_str00008);
   } while (Gi_00009 < Gi_00008); 
   } 
   tmp_str00009 = tmp_str00008;
   Is_00628 = StringConcatenate(TimeYear(Ii_005EC), "-", tmp_str00009, "-", tmp_str00006, "-GoldRushNews", ".xml");
   Ii_003EC = FileOpen(Is_00628, 5);
   if (Ii_003EC >= 0) { 
   FileClose(Ii_003EC);
   if (Is_00628 != Is_00618) { 
   FileDelete(Is_00628, 0);
   }} 
   Ii_005EC = Ii_005EC - 604800;
   Gl_00009 = Il_00090 - 6048000;
   Gl_0000A = Ii_005EC;
   } while (Gl_0000A >= Gl_00009); 
   } 
   Ii_00080 = 2;
   if (AllowPanelAtChartRight) { 
   Ii_00080 = 3;
   } 
   Ib_00070 = false;
   Li_FFFFC = 0;
   return 0;
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
   string tmp_str0003F;
   string tmp_str00040;
   string tmp_str00041;
   string tmp_str00042;
   string tmp_str00043;
   string tmp_str00044;
   string tmp_str00045;
   string tmp_str00046;
   string tmp_str00047;
   string tmp_str00048;
   string tmp_str00049;
   string tmp_str0004A;
   string tmp_str0004B;
   string tmp_str0004C;
   string tmp_str0004D;
   string tmp_str0004E;
   string tmp_str0004F;
   string tmp_str00050;
   string tmp_str00051;
   string tmp_str00052;
   string tmp_str00053;
   string tmp_str00054;
   string tmp_str00055;
   string tmp_str00056;
   string tmp_str00057;
   string tmp_str00058;
   string tmp_str00059;
   string tmp_str0005A;
   string tmp_str0005B;
   string tmp_str0005C;
   string tmp_str0005D;
   string tmp_str0005E;
   string tmp_str0005F;
   string tmp_str00060;
   string tmp_str00061;
   string tmp_str00062;
   string tmp_str00063;
   string tmp_str00064;
   string tmp_str00065;
   string tmp_str00066;
   string tmp_str00067;
   string tmp_str00068;
   string tmp_str00069;
   string tmp_str0006A;
   string tmp_str0006B;
   string tmp_str0006C;
   string tmp_str0006D;
   string tmp_str0006E;
   string tmp_str0006F;
   string tmp_str00070;
   string tmp_str00071;
   string tmp_str00072;
   string tmp_str00073;
   string tmp_str00074;
   string tmp_str00075;
   string tmp_str00076;
   string tmp_str00077;
   string tmp_str00078;
   string tmp_str00079;
   string tmp_str0007A;
   string tmp_str0007B;
   string tmp_str0007C;
   string tmp_str0007D;
   string tmp_str0007E;
   string tmp_str0007F;
   string tmp_str00080;
   string tmp_str00081;
   string tmp_str00082;
   string tmp_str00083;
   string tmp_str00084;
   string tmp_str00085;
   string tmp_str00086;
   string tmp_str00087;
   string tmp_str00088;
   string tmp_str00089;
   string tmp_str0008A;
   string tmp_str0008B;
   string tmp_str0008C;
   string tmp_str0008D;
   string tmp_str0008E;
   string tmp_str0008F;
   string tmp_str00090;
   string tmp_str00091;
   string tmp_str00092;
   string tmp_str00093;
   string tmp_str00094;
   string tmp_str00095;
   string tmp_str00096;
   string tmp_str00097;
   string tmp_str00098;
   string tmp_str00099;
   string tmp_str0009A;
   string tmp_str0009B;
   string tmp_str0009C;
   string tmp_str0009D;
   string tmp_str0009E;
   string tmp_str0009F;
   string tmp_str000A0;
   string tmp_str000A1;
   string tmp_str000A2;
   string tmp_str000A3;
   string tmp_str000A4;
   string tmp_str000A5;
   string tmp_str000A6;
   string tmp_str000A7;
   string tmp_str000A8;
   string tmp_str000A9;
   string tmp_str000AA;
   string tmp_str000AB;
   string tmp_str000AC;
   string tmp_str000AD;
   string tmp_str000AE;
   string tmp_str000AF;
   string tmp_str000B0;
   string tmp_str000B1;
   string tmp_str000B2;
   string tmp_str000B3;
   string tmp_str000B4;
   string tmp_str000B5;
   string tmp_str000B6;
   string tmp_str000B7;
   string tmp_str000B8;
   string tmp_str000B9;
   string tmp_str000BA;
   string tmp_str000BB;
   string tmp_str000BC;
   string tmp_str000BD;
   string tmp_str000BE;
   string tmp_str000BF;
   string tmp_str000C0;
   string tmp_str000C1;
   string tmp_str000C2;
   string tmp_str000C3;
   string tmp_str000C4;
   string tmp_str000C5;
   string tmp_str000C6;
   string tmp_str000C7;
   string tmp_str000C8;
   string tmp_str000C9;
   string tmp_str000CA;
   string tmp_str000CB;
   string tmp_str000CC;
   string tmp_str000CD;
   double Ld_FFFF8;
   string Ls_FFFE8;
   string Ls_FFFC0;
   bool Lb_FFFAF;
   bool Lb_FFFAE;
   string Ls_FFFB0;
   string Ls_FFFD8;
   long Ll_FFFD0;

   Ld_FFFF8 = MarketInfo(_Symbol, MODE_SPREAD);
   if ((Ld_FFFF8 > MaxSpread) && (MaxSpread != 0)) { 
   Sleep(60000);
   return ;
   } 
   returned_i = Layer_Multiplier;
   if (returned_i <= 10) { 
   if (returned_i == 0) Id_04720 = 2;
   if (returned_i == 1) Id_04720 = 1.9;
   if (returned_i == 2) Id_04720 = 1.8;
   if (returned_i == 3) Id_04720 = 1.7;
   if (returned_i == 4) Id_04720 = 1.6;
   if (returned_i == 5) Id_04720 = 1.5;
   if (returned_i == 6) Id_04720 = 1.4;
   if (returned_i == 7) Id_04720 = 1.3;
   if (returned_i == 8) Id_04720 = 1.2;
   if (returned_i == 9) Id_04720 = 1.1;
   if (returned_i == 10) Id_04720 = 1;
   } 
   if (SetAutoLot && (BalanceInit != 0)) { 
   Gd_00000 = (Lots / BalanceInit);
   tmp_str00000 = (string)NormalizeDouble((Gd_00000 * AccountBalance()), 5);
   Id_04730 = (double)StringSubstr(tmp_str00000, 0, 4);
   if ((Id_04730 > MaximumInitLot) && (MaximumInitLot != 0)) { 
   Id_04730 = MaximumInitLot;
   } 
   Gd_00000 = Id_04730;
   returned_double = SymbolInfoDouble(NULL, 34);
   if ((Id_04730 < returned_double)) { 
   Gd_00001 = returned_double;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 35);
   if ((Gd_00000 > returned_double)) { 
   Gd_00001 = returned_double;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 36);
   Gd_00002 = round((Gd_00000 / returned_double));
   Gi_00002 = (int)Gd_00002;
   Gd_00003 = fabs(((Gi_00002 * returned_double) - Gd_00000));
   if ((Gd_00003 > 1E-07)) { 
   Gd_00001 = (Gi_00002 * returned_double);
   } 
   else { 
   Gd_00001 = Gd_00000;
   }}} 
   Id_04728 = Gd_00001;
   } 
   else { 
   Gd_00003 = Lots;
   returned_double = SymbolInfoDouble(NULL, 34);
   if ((Lots < returned_double)) { 
   Gd_00004 = returned_double;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 35);
   if ((Gd_00003 > returned_double)) { 
   Gd_00004 = returned_double;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 36);
   Gd_00005 = round((Gd_00003 / returned_double));
   Gi_00005 = (int)Gd_00005;
   Gd_00006 = fabs(((Gi_00005 * returned_double) - Gd_00003));
   if ((Gd_00006 > 1E-07)) { 
   Gd_00004 = (Gi_00005 * returned_double);
   } 
   else { 
   Gd_00004 = Gd_00003;
   }}} 
   Id_04728 = Gd_00004;
   } 
   Gi_00006 = -1;
   Gi_00007 = HistoryTotal() - 1;
   Gi_00008 = Gi_00007;
   if (Gi_00007 >= 0) { 
   do { 
   if (OrderSelect(Gi_00008, 0, 1)) { 
   if (OrderMagicNumber() == Magic && Il_04778 != Time[0] && Il_04778 <= iTime(_Symbol, 1440, 0)
   && (OrderType() == Gi_00006 || Gi_00006 == -1)) {
   
   Id_04770 = 0;
   Id_04758 = 0;
   Id_04760 = 0;
   Id_04768 = 0;
   Il_04778 = Time[0];
   }
   else{
   Gd_0000A = AccountEquity();
   if (((Gd_0000A - AccountBalance()) < Id_04760)) { 
   Gd_0000A = AccountEquity();
   Id_04760 = (Gd_0000A - AccountBalance());
   Id_04768 = (AccountBalance() + Id_04760);
   Gd_0000A = (AccountBalance() - Id_04768);
   Id_04758 = (Gd_0000A / AccountBalance());
   Id_04758 = (Id_04758 * 100);
   } 
   if ((Id_04770 < Id_04758)) { 
   Id_04770 = Id_04758;
   }}} 
   Gi_00008 = Gi_00008 - 1;
   } while (Gi_00008 >= 0); 
   } 
   Gd_0000A = AccountEquity();
   if (((Gd_0000A - AccountBalance()) < Id_04748)) { 
   Gd_0000A = AccountEquity();
   Id_04748 = (Gd_0000A - AccountBalance());
   Id_04750 = (AccountBalance() + Id_04748);
   Gd_0000A = (AccountBalance() - Id_04750);
   Id_04740 = (Gd_0000A / AccountBalance());
   Id_04740 = (Id_04740 * 100);
   } 
   Gi_0000A = 0;
   Gi_0000B = OrdersTotal() - 1;
   Gi_0000C = Gi_0000B;
   if (Gi_0000B >= 0) { 
   do { 
   if (OrderSelect(Gi_0000C, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   if (OrderType() == OP_SELL || OrderType() == OP_BUY) { 
   
   Gi_0000A = Gi_0000A + 1;
   }} 
   Gi_0000C = Gi_0000C - 1;
   } while (Gi_0000C >= 0); 
   } 
   Ii_0478C = Gi_0000A;
   func_1033();
   Ii_005E8 = ObjectsTotal(-1) - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   Id_04798 = ObjectGetDouble(0, "i[GoldRushNews] LineBuy", 20, 0);
   Id_04790 = ObjectGetDouble(0, "i[GoldRushNews] LineSell", 20, 0);
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if ((((Dist * Id_046F8) + Ask) < Id_04798)) { 
   Gd_0000B = ((Dist * Id_046F8) + Ask);
   Gd_0000D = Gd_0000B;
   tmp_str00001 = "i[GoldRushNews] LineBuy";
   if (Gd_0000B == 0) { 
   Gd_0000D = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00001, 0, 0, Gd_0000D) != true) { 
   tmp_str00002 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00002);
   }} 
   Gd_0000B = (Dist * Id_046F8);
   if (((Bid - Gd_0000B) > Id_04790)) { 
   Gd_0000B = (Dist * Id_046F8);
   Gd_0000B = (Bid - Gd_0000B);
   Gd_0000E = Gd_0000B;
   tmp_str00003 = "i[GoldRushNews] LineSell";
   if (Gd_0000B == 0) { 
   Gd_0000E = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00003, 0, 0, Gd_0000E) != true) { 
   tmp_str00004 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00004);
   }} 
   if ((Ask < Id_04790)) { 
   Gd_0000B = (Dist * Id_046F8);
   if (((Bid - Gd_0000B) > Id_04798)) { 
   Gd_0000B = ((Dist * Id_046F8) + Ask);
   Gd_0000F = Gd_0000B;
   tmp_str00005 = "i[GoldRushNews] LineBuy";
   if (Gd_0000B == 0) { 
   Gd_0000F = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00005, 0, 0, Gd_0000F) != true) { 
   tmp_str00006 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00006);
   }}} 
   if ((Bid > Id_04798) && (((Dist * Id_046F8) + Ask) < Id_04790)) { 
   Gd_0000B = (Dist * Id_046F8);
   Gd_0000B = (Bid - Gd_0000B);
   Gd_00010 = Gd_0000B;
   tmp_str00007 = "i[GoldRushNews] LineSell";
   if (Gd_0000B == 0) { 
   Gd_00010 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00007, 0, 0, Gd_00010) != true) { 
   tmp_str00008 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00008);
   }} 
   if ((SetMMPlus && Ib_047C0) || !Ib_047C0) {
   
   Gi_0000B = -1;
   Gd_00011 = 0;
   Gi_00012 = HistoryTotal() - 1;
   Gi_00013 = Gi_00012;
   if (Gi_00012 >= 0) { 
   do { 
   if (OrderSelect(Gi_00013, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_00012 = OrderCloseTime();
   if (Gl_00012 >= iTime(_Symbol, 1440, 0)) { 
   if (OrderType() == Gi_0000B || Gi_0000B == -1) { 
   
   Gd_00012 = OrderProfit();
   Gd_00012 = (Gd_00012 + OrderSwap());
   Gd_00011 = ((Gd_00012 + OrderCommission()) + Gd_00011);
   }}} 
   Gi_00013 = Gi_00013 - 1;
   } while (Gi_00013 >= 0); 
   } 
   if ((Gd_00011 >= TargetPlus)) { 
   Ib_047C0 = false;
   } 
   else { 
   Gi_00012 = -1;
   Gd_00014 = 0;
   Gi_00015 = HistoryTotal() - 1;
   Gi_00016 = Gi_00015;
   if (Gi_00015 >= 0) { 
   do { 
   if (OrderSelect(Gi_00016, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_00015 = OrderCloseTime();
   if (Gl_00015 >= iTime(_Symbol, 1440, 0)) { 
   if (OrderType() == Gi_00012 || Gi_00012 == -1) { 
   
   Gd_00015 = OrderProfit();
   Gd_00015 = (Gd_00015 + OrderSwap());
   Gd_00014 = ((Gd_00015 + OrderCommission()) + Gd_00014);
   }}} 
   Gi_00016 = Gi_00016 - 1;
   } while (Gi_00016 >= 0); 
   } 
   if ((Gd_00014 < TargetPlus) && Il_04780 != Time[0] && Il_04780 <= iTime(_Symbol, 1440, 0)) { 
   Ib_047C0 = true;
   Il_04780 = Time[0];
   }}} 
   if ((SetMMMinus && Ib_047C0) || !Ib_047C0) {
   
   if ((NormalizeDouble(Id_04770, 2) >= TargetMinus)) {
   Ib_047C0 = false;
   Gi_00018 = -1;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gd_00019 = OrderProfit();
   Gd_00019 = (Gd_00019 + OrderSwap());
   if (((Gd_00019 + OrderCommission()) < 0)) { 
   if (OrderType() == OP_BUY) { 
   if (Gi_00018 == 0 || Gi_00018 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 10, 16777215);
   }} 
   if (OrderType() == OP_SELL) { 
   if (Gi_00018 == 1 || Gi_00018 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 10, 16777215);
   }}}} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Gi_0001D = -1;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) {
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gd_0001E = OrderProfit();
   Gd_0001E = (Gd_0001E + OrderSwap());
   if (((Gd_0001E + OrderCommission()) > 0)) { 
   if (OrderType() == OP_BUY) { 
   if (Gi_0001D == 0 || Gi_0001D == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 10, 16777215);
   }} 
   if (OrderType() == OP_SELL) { 
   if (Gi_0001D == 1 || Gi_0001D == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 10, 16777215);
   }}}} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   }}
   else{
   if ((NormalizeDouble(Id_04770, 2) < TargetMinus) && Il_04780 != Time[0] && Il_04780 <= iTime(_Symbol, 1440, 0)) { 
   Ib_047C0 = true;
   Il_04780 = Time[0];
   }}} 
   func_1016();
   if (SetNews) { 
   Il_046E0 = TimeCurrent() + 604800;
   Ii_005E8 = 0;
   if (ObjectsTotal(-1) > 0) { 
   do { 
   Ls_FFFE8 = ObjectName(Ii_005E8);
   if (ObjectType(Ls_FFFE8) != 0) { 
   } 
   else { 
   tmp_str00009 = ObjectGetString(0, Ls_FFFE8, 999, 0);
   Ls_FFFD8 = StringSubstr(tmp_str00009, 0, 3);
   if (StringFind(_Symbol, Ls_FFFD8, 0) < 0) { 
   } 
   else { 
   Ll_FFFD0 = (datetime)ObjectGet(Ls_FFFE8, OBJPROP_TIME1);
   if (Ll_FFFD0 < TimeCurrent()) { 
   } 
   else { 
   if (Ll_FFFD0 < Il_046E0) { 
   Il_046E0 = Ll_FFFD0;
   }}}} 
   Ii_005E8 = Ii_005E8 + 1;
   } while (Ii_005E8 < ObjectsTotal(-1)); 
   } 
   Ii_005E8 = ObjectsTotal(-1);
   if (Ii_005E8 >= 0) { 
   do { 
   Ls_FFFC0 = ObjectName(Ii_005E8);
   if (ObjectType(Ls_FFFC0) != 0) { 
   } 
   else { 
   tmp_str0000A = ObjectGetString(0, Ls_FFFC0, 999, 0);
   Ls_FFFB0 = StringSubstr(tmp_str0000A, 0, 3);
   if (StringFind(_Symbol, Ls_FFFB0, 0) < 0) { 
   } 
   else { 
   tmp_str0000B = ObjectGetString(0, Ls_FFFC0, 999, 0);
   Il_046E8 = (datetime)StringSubstr(tmp_str0000B, 4, 16);
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   }} 
   Il_046D8 = TimeCurrent();
   Gi_00024 = BeforeNewsTime * 60;
   Gi_00024 = Gi_00024 * 60;
   Gl_00024 = Gi_00024;
   Gl_00024 = Il_046E0 - Gl_00024;
   if (Il_046D8 < Il_046E0 && Il_046D8 >= Gl_00024) {
   Ib_046F0 = false;
   if (Il_046E8 < Il_046E0) {
   Il_046E8 = Il_046E0;
   }}
   else{
   Gi_00024 = BeforeNewsTime * 60;
   Gi_00024 = Gi_00024 * 60;
   Gl_00024 = Gi_00024;
   Gl_00024 = Il_046E8 + Gl_00024;
   if (Il_046D8 > Il_046E8 && Il_046D8 <= Gl_00024) {
   Ib_046F0 = false;
   }
   else{
   Ib_046F0 = true;
   }}
   Lb_FFFAF = false;
   Lb_FFFAE = false;
   if (SetAverageBar && HowBar != 0) {
   Gi_00024 = HowBar;
   Gd_00025 = 0;
   Ii_005E8 = 1;
   if (HowBar >= 1) { 
   do { 
   Gd_00026 = iHigh(_Symbol, 0, Ii_005E8);
   Gd_00026 = (Gd_00026 - iLow(_Symbol, 0, Ii_005E8));
   Gd_00025 = ((Gd_00026 / _Point) + Gd_00025);
   Ii_005E8 = Ii_005E8 + 1;
   } while (Ii_005E8 <= Gi_00024); 
   } 
   Gd_00026 = ((Gd_00025 / Gi_00024) * ExpBar);
   Gd_00027 = iOpen(_Symbol, 0, 0);
   Gd_00027 = (Gd_00027 - iClose(_Symbol, 0, 0));
   if ((Gd_00026 < (Gd_00027 / _Point))) { 
   Lb_FFFAE = true;
   } 
   Gi_00027 = HowBar;
   Gd_00028 = 0;
   Ii_005E8 = 1;
   if (HowBar >= 1) { 
   do { 
   Gd_00029 = iHigh(_Symbol, 0, Ii_005E8);
   Gd_00029 = (Gd_00029 - iLow(_Symbol, 0, Ii_005E8));
   Gd_00028 = ((Gd_00029 / _Point) + Gd_00028);
   Ii_005E8 = Ii_005E8 + 1;
   } while (Ii_005E8 <= Gi_00027); 
   } 
   Gd_00029 = ((Gd_00028 / Gi_00027) * ExpBar);
   Gd_0002A = iClose(_Symbol, 0, 0);
   Gd_0002A = (Gd_0002A - iOpen(_Symbol, 0, 0));
   Gb_0002A = (Gd_00029 < (Gd_0002A / _Point));
   if (Gb_0002A != false) {
   Lb_FFFAF = true;
   }}
   else{
   Lb_FFFAE = true;
   Lb_FFFAF = true;
   }
   Gb_0002A = true;
   if (DayOfWeek() == 1) { 
   Gb_0002A = MondayOrders;
   } 
   if (Gb_0002A) { 
   Gb_0002B = true;
   if (DayOfWeek() == 2) { 
   Gb_0002B = TuesdayOrders;
   } 
   if (Gb_0002B) { 
   Gb_0002C = true;
   if (DayOfWeek() == 3) { 
   Gb_0002C = WednesdayOrders;
   } 
   if (Gb_0002C) { 
   Gb_0002D = true;
   if (DayOfWeek() == 4) { 
   Gb_0002D = ThursdayOrders;
   } 
   if (Gb_0002D) { 
   Gb_0002E = true;
   if (DayOfWeek() == 5) { 
   Gb_0002E = FridayOrders;
   } 
   if (Gb_0002E) { 
   Gb_0002F = true;
   if (DayOfWeek() == 6) { 
   Gb_0002F = SaturdayOrders;
   } 
   if (Gb_0002F) { 
   Gb_00030 = true;
   if (DayOfWeek() == 0) { 
   Gb_00030 = SundayOrders;
   } 
   if (Gb_00030) { 
   if (SetStrategies == 1) { 
   Ib_047C1 = true;
   Ib_047C2 = false;
   Ib_047C3 = false;
   } 
   else { 
   if (SetStrategies == 2) { 
   Ib_047C1 = false;
   Ib_047C2 = true;
   Ib_047C3 = false;
   } 
   else { 
   if (SetStrategies == 3) { 
   Ib_047C1 = false;
   Ib_047C2 = false;
   Ib_047C3 = true;
   }}} 
   if (SetEMA != false) {
   Id_047C8 = iMA(_Symbol, 0, EMAFast, 0, 1, 0, 1);
   Id_047D0 = iMA(_Symbol, 0, EMAFast, 0, 1, 0, 0);
   Id_047D8 = iMA(_Symbol, 0, EMAMedium, 0, 1, 0, 0);
   Id_047E0 = iMA(_Symbol, 0, EMALow, 0, 1, 0, 0);
   if ((Id_047C8 > Id_047D0) && (Id_047D8 > Id_047D0)) { 
   Ib_047C4 = true;
   } 
   else { 
   Ib_047C4 = false;
   } 
   if ((Id_047C8 > Id_047D0) && (Id_047E0 > Id_047D0)) { 
   Ib_047C5 = true;
   } 
   else { 
   Ib_047C5 = false;
   } 
   if ((Id_047C8 < Id_047D0) && (Id_047D8 < Id_047D0)) { 
   Ib_047C6 = true;
   } 
   else { 
   Ib_047C6 = false;
   } 
   if ((Id_047C8 < Id_047D0) && (Id_047E0 < Id_047D0)) { 
   Ib_047C7 = true;
   } 
   else { 
   Ib_047C7 = false;
   } 
   if ((InpUseTime && TimeHour(TimeCurrent()) >= InpStartHour && TimeHour(TimeCurrent()) <= InpEndHour) || !InpUseTime) {
   
   if ((Ib_047C1 && Ib_047C0) || (Ib_047C1 && SetMMMinus == false && SetMMPlus == false)) {
   
   if ((Open[0] > Close[0]) && (Ask <= Id_04790)) { 
   Gi_00033 = -1;
   Gl_00034 = 0;
   Ii_005E8 = HistoryTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 1) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic && OrderOpenTime() > Gl_00034) { 
   Gl_00034 = OrderOpenTime();
   Gi_00033 = OrderType();
   } 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_00033 != 1) { 
   Gi_00035 = -1;
   Gi_00036 = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00035 == -1 || OrderType() == Gi_00035) { 
   
   Gi_00036 = Gi_00036 + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_00036 == 0 && Ib_047C4 && Ib_047C5 && Ib_046F0 && Lb_FFFAE) { 
   Gd_00037 = Id_04700;
   Gd_00038 = Id_04708;
   Gi_00039 = 1;
   Gi_0003A = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_0003B = Gi_0003A;
   if (Gi_0003A != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_0003A, Gi_0003A);
   } 
   Gb_0003A = false;
   Gb_0003C = false;
   returned_i = Gi_00039;
   if (returned_i == 0) {
   
   Gb_0003D = (Gd_00038 > (Gi_0003B * Id_046F8));
   Gb_0003A = Gb_0003D;
   if (Gb_0003D != true) { 
   Gd_0003E = (Gi_0003B * Id_046F8);
   tmp_str0000C = EnumToString((ENUM_ORDER_TYPE) Gi_00039);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0000C, Gd_00038, (Bid - Gd_0003E), Bid, Gi_0003B);
   } 
   Gb_0003E = (Gd_00037 > (Gi_0003B * Id_046F8));
   Gb_0003C = Gb_0003E;
   if (Gb_0003E != true) { 
   tmp_str0000D = EnumToString((ENUM_ORDER_TYPE) Gi_00039);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0000D, Gd_00037, ((Gi_0003B * Id_046F8) + Bid), Bid, Gi_0003B);
   } 
   Gb_0003F = Gb_0003A;
   if (Gb_0003A) { 
   Gb_0003F = Gb_0003C;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_00040 = (Gd_00038 > (Gi_0003B * Id_046F8));
   Gb_0003A = Gb_00040;
   if (Gb_00040 != true) { 
   tmp_str0000E = EnumToString((ENUM_ORDER_TYPE) Gi_00039);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0000E, Gd_00038, ((Gi_0003B * Id_046F8) + Ask), Ask, Gi_0003B);
   } 
   Gb_00041 = (Gd_00037 > (Gi_0003B * Id_046F8));
   Gb_0003C = Gb_00041;
   if (Gb_00041 != true) { 
   Gd_00042 = (Gi_0003B * Id_046F8);
   tmp_str0000F = EnumToString((ENUM_ORDER_TYPE) Gi_00039);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0000F, Gd_00037, (Ask - Gd_00042), Ask, Gi_0003B);
   } 
   Gb_00042 = Gb_0003C;
   if (Gb_0003C) { 
   Gb_00042 = Gb_0003A;
   } 
   Gb_0003F = Gb_00042;
   }
   else{
   Gb_0003F = false;
   }
   if (Gb_0003F == false) return; 
   Gb_00043 = (AccountFreeMarginCheck(_Symbol, 1, Id_04728) < 0);
   if (Gb_00043) { 
   if (false) { 
   tmp_str00011 = "Buy";
   } 
   else { 
   tmp_str00011 = "Sell";
   } 
   tmp_str00010 = tmp_str00011;
   tmp_str00011 = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str00010, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str00011);
   Gb_00043 = false;
   } 
   else { 
   Gb_00043 = true;
   } 
   if (Gb_00043) { 
   tmp_str00012 = comment + "-BUY&SELL-";
   Gi_00044 = Ii_0478C + 1;
   tmp_str00013 = (string)Gi_00044;
   tmp_str00012 = tmp_str00012 + tmp_str00013;
   Ii_04788 = OrderSend(_Symbol, 1, NormalizeDouble(Id_04728, 2), NormalizeDouble(Bid, _Digits), 10, 0, 0, tmp_str00012, Magic, 0, 255);
   Gd_00044 = ((Dist * Id_046F8) + Ask);
   Gd_00045 = Gd_00044;
   tmp_str00013 = "i[GoldRushNews] LineBuy";
   if (Gd_00044 == 0) { 
   Gd_00045 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00013, 0, 0, Gd_00045) != true) { 
   tmp_str00014 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00014);
   } 
   if (Ii_04788 < 0) { 
   tmp_str00015 = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str00015);
   return ;
   }}}}} 
   if ((Open[0] < Close[0]) && (Bid >= Id_04798)) {
   Gi_00047 = -1;
   Gl_00048 = 0;
   Ii_005E8 = HistoryTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 1) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic && OrderOpenTime() > Gl_00048) { 
   Gl_00048 = OrderOpenTime();
   Gi_00047 = OrderType();
   } 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_00047 != 0) {
   Gi_00049 = -1;
   Gi_0004A = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00049 == -1 || OrderType() == Gi_00049) { 
   
   Gi_0004A = Gi_0004A + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_0004A == 0 && Ib_047C6 && Ib_047C7 && Ib_046F0 && Lb_FFFAF) {
   Gd_0004B = Id_04700;
   Gd_0004C = Id_04708;
   Gi_0004D = 0;
   Gi_0004E = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_0004F = Gi_0004E;
   if (Gi_0004E != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_0004E, Gi_0004E);
   } 
   Gb_0004E = false;
   Gb_00050 = false;
   returned_i = Gi_0004D;
   if (returned_i == 0) {
   
   Gb_00051 = (Gd_0004C > (Gi_0004F * Id_046F8));
   Gb_0004E = Gb_00051;
   if (Gb_00051 != true) { 
   Gd_00052 = (Gi_0004F * Id_046F8);
   tmp_str00016 = EnumToString((ENUM_ORDER_TYPE) Gi_0004D);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00016, Gd_0004C, (Bid - Gd_00052), Bid, Gi_0004F);
   } 
   Gb_00052 = (Gd_0004B > (Gi_0004F * Id_046F8));
   Gb_00050 = Gb_00052;
   if (Gb_00052 != true) { 
   tmp_str00017 = EnumToString((ENUM_ORDER_TYPE) Gi_0004D);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00017, Gd_0004B, ((Gi_0004F * Id_046F8) + Bid), Bid, Gi_0004F);
   } 
   Gb_00053 = Gb_0004E;
   if (Gb_0004E) { 
   Gb_00053 = Gb_00050;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_00054 = (Gd_0004C > (Gi_0004F * Id_046F8));
   Gb_0004E = Gb_00054;
   if (Gb_00054 != true) { 
   tmp_str00018 = EnumToString((ENUM_ORDER_TYPE) Gi_0004D);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00018, Gd_0004C, ((Gi_0004F * Id_046F8) + Ask), Ask, Gi_0004F);
   } 
   Gb_00055 = (Gd_0004B > (Gi_0004F * Id_046F8));
   Gb_00050 = Gb_00055;
   if (Gb_00055 != true) { 
   Gd_00056 = (Gi_0004F * Id_046F8);
   tmp_str00019 = EnumToString((ENUM_ORDER_TYPE) Gi_0004D);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00019, Gd_0004B, (Ask - Gd_00056), Ask, Gi_0004F);
   } 
   Gb_00056 = Gb_00050;
   if (Gb_00050) { 
   Gb_00056 = Gb_0004E;
   } 
   Gb_00053 = Gb_00056;
   }
   else{
   Gb_00053 = false;
   }
   if (Gb_00053 == false) return; 
   Gb_00057 = (AccountFreeMarginCheck(_Symbol, 0, Id_04728) < 0);
   if (Gb_00057) { 
   if (true) { 
   tmp_str0001B = "Buy";
   } 
   else { 
   tmp_str0001B = "Sell";
   } 
   tmp_str0001A = tmp_str0001B;
   tmp_str0001B = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str0001A, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str0001B);
   Gb_00057 = false;
   } 
   else { 
   Gb_00057 = true;
   } 
   if (Gb_00057 != false) {
   tmp_str0001C = comment + "-BUY&SELL-";
   Gi_00058 = Ii_0478C + 1;
   tmp_str0001D = (string)Gi_00058;
   tmp_str0001C = tmp_str0001C + tmp_str0001D;
   Ii_04788 = OrderSend(_Symbol, 0, NormalizeDouble(Id_04728, 2), NormalizeDouble(Ask, _Digits), 10, 0, 0, tmp_str0001C, Magic, 0, 32768);
   Gd_00058 = (Dist * Id_046F8);
   Gd_00058 = (Bid - Gd_00058);
   Gd_00059 = Gd_00058;
   tmp_str0001D = "i[GoldRushNews] LineSell";
   if (Gd_00058 == 0) { 
   Gd_00059 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str0001D, 0, 0, Gd_00059) != true) { 
   tmp_str0001E = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str0001E);
   } 
   if (Ii_04788 < 0) {
   tmp_str0001F = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str0001F);
   return ;
   }}}}}}
   if ((Ib_047C2 && Ib_047C0) || (Ib_047C2 && SetMMMinus == false && SetMMPlus == false)) {
   
   if ((Open[1] > Close[1]) && (Open[1] > Open[0]) && (Close[1] > Close[0]) && (Ask <= Id_04790)) { 
   Gi_0005F = -1;
   Gi_00060 = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_0005F == -1 || OrderType() == Gi_0005F) { 
   
   Gi_00060 = Gi_00060 + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_00060 == 0 && Ib_047C4 && Ib_047C5 && Ib_046F0 && Lb_FFFAE) { 
   Gd_00061 = Id_04700;
   Gd_00062 = Id_04708;
   Gi_00063 = 1;
   Gi_00064 = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_00065 = Gi_00064;
   if (Gi_00064 != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_00064, Gi_00064);
   } 
   Gb_00064 = false;
   Gb_00066 = false;
   returned_i = Gi_00063;
   if (returned_i == 0) {
   
   Gb_00067 = (Gd_00062 > (Gi_00065 * Id_046F8));
   Gb_00064 = Gb_00067;
   if (Gb_00067 != true) { 
   Gd_00068 = (Gi_00065 * Id_046F8);
   tmp_str00020 = EnumToString((ENUM_ORDER_TYPE) Gi_00063);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00020, Gd_00062, (Bid - Gd_00068), Bid, Gi_00065);
   } 
   Gb_00068 = (Gd_00061 > (Gi_00065 * Id_046F8));
   Gb_00066 = Gb_00068;
   if (Gb_00068 != true) { 
   tmp_str00021 = EnumToString((ENUM_ORDER_TYPE) Gi_00063);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00021, Gd_00061, ((Gi_00065 * Id_046F8) + Bid), Bid, Gi_00065);
   } 
   Gb_00069 = Gb_00064;
   if (Gb_00064) { 
   Gb_00069 = Gb_00066;
   } 
   }
   if (returned_i == 1) {
   
   Gb_0006A = (Gd_00062 > (Gi_00065 * Id_046F8));
   Gb_00064 = Gb_0006A;
   if (Gb_0006A != true) { 
   tmp_str00022 = EnumToString((ENUM_ORDER_TYPE) Gi_00063);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00022, Gd_00062, ((Gi_00065 * Id_046F8) + Ask), Ask, Gi_00065);
   } 
   Gb_0006B = (Gd_00061 > (Gi_00065 * Id_046F8));
   Gb_00066 = Gb_0006B;
   if (Gb_0006B != true) { 
   Gd_0006C = (Gi_00065 * Id_046F8);
   tmp_str00023 = EnumToString((ENUM_ORDER_TYPE) Gi_00063);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00023, Gd_00061, (Ask - Gd_0006C), Ask, Gi_00065);
   } 
   Gb_0006C = Gb_00066;
   if (Gb_00066) { 
   Gb_0006C = Gb_00064;
   } 
   Gb_00069 = Gb_0006C;
   }
   else{
   Gb_00069 = false;
   }
   if (Gb_00069 == false) return; 
   Gb_0006D = (AccountFreeMarginCheck(_Symbol, 1, Id_04728) < 0);
   if (Gb_0006D) { 
   if (false) { 
   tmp_str00025 = "Buy";
   } 
   else { 
   tmp_str00025 = "Sell";
   } 
   tmp_str00024 = tmp_str00025;
   tmp_str00025 = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str00024, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str00025);
   Gb_0006D = false;
   } 
   else { 
   Gb_0006D = true;
   } 
   if (Gb_0006D) { 
   tmp_str00026 = comment + "-CANDLE-";
   Gi_0006E = Ii_0478C + 1;
   tmp_str00027 = (string)Gi_0006E;
   tmp_str00026 = tmp_str00026 + tmp_str00027;
   Ii_04788 = OrderSend(_Symbol, 1, NormalizeDouble(Id_04728, 2), NormalizeDouble(Bid, _Digits), 10, 0, 0, tmp_str00026, Magic, 0, 255);
   Gd_0006E = ((Dist * Id_046F8) + Ask);
   Gd_0006F = Gd_0006E;
   tmp_str00027 = "i[GoldRushNews] LineBuy";
   if (Gd_0006E == 0) { 
   Gd_0006F = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00027, 0, 0, Gd_0006F) != true) { 
   tmp_str00028 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00028);
   } 
   if (Ii_04788 < 0) { 
   tmp_str00029 = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str00029);
   return ;
   }}}} 
   if ((Open[1] < Close[1]) && (Open[1] < Open[0]) && (Close[1] < Close[0]) && (Bid >= Id_04798)) {
   Gi_00075 = -1;
   Gi_00076 = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00075 == -1 || OrderType() == Gi_00075) { 
   
   Gi_00076 = Gi_00076 + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_00076 == 0 && Ib_047C6 && Ib_047C7 && Ib_046F0 && Lb_FFFAF) {
   Gd_00077 = Id_04700;
   Gd_00078 = Id_04708;
   Gi_00079 = 0;
   Gi_0007A = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_0007B = Gi_0007A;
   if (Gi_0007A != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_0007A, Gi_0007A);
   } 
   Gb_0007A = false;
   Gb_0007C = false;
   returned_i = Gi_00079;
   if (returned_i == 0) {
   
   Gb_0007D = (Gd_00078 > (Gi_0007B * Id_046F8));
   Gb_0007A = Gb_0007D;
   if (Gb_0007D != true) { 
   Gd_0007E = (Gi_0007B * Id_046F8);
   tmp_str0002A = EnumToString((ENUM_ORDER_TYPE) Gi_00079);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0002A, Gd_00078, (Bid - Gd_0007E), Bid, Gi_0007B);
   } 
   Gb_0007E = (Gd_00077 > (Gi_0007B * Id_046F8));
   Gb_0007C = Gb_0007E;
   if (Gb_0007E != true) { 
   tmp_str0002B = EnumToString((ENUM_ORDER_TYPE) Gi_00079);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0002B, Gd_00077, ((Gi_0007B * Id_046F8) + Bid), Bid, Gi_0007B);
   } 
   Gb_0007F = Gb_0007A;
   if (Gb_0007A) { 
   Gb_0007F = Gb_0007C;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_00080 = (Gd_00078 > (Gi_0007B * Id_046F8));
   Gb_0007A = Gb_00080;
   if (Gb_00080 != true) { 
   tmp_str0002C = EnumToString((ENUM_ORDER_TYPE) Gi_00079);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0002C, Gd_00078, ((Gi_0007B * Id_046F8) + Ask), Ask, Gi_0007B);
   } 
   Gb_00081 = (Gd_00077 > (Gi_0007B * Id_046F8));
   Gb_0007C = Gb_00081;
   if (Gb_00081 != true) { 
   Gd_00082 = (Gi_0007B * Id_046F8);
   tmp_str0002D = EnumToString((ENUM_ORDER_TYPE) Gi_00079);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0002D, Gd_00077, (Ask - Gd_00082), Ask, Gi_0007B);
   } 
   Gb_00082 = Gb_0007C;
   if (Gb_0007C) { 
   Gb_00082 = Gb_0007A;
   } 
   Gb_0007F = Gb_00082;
   }
   else{
   Gb_0007F = false;
   }
   if (Gb_0007F == false) return; 
   Gb_00083 = (AccountFreeMarginCheck(_Symbol, 0, Id_04728) < 0);
   if (Gb_00083) { 
   if (true) { 
   tmp_str0002F = "Buy";
   } 
   else { 
   tmp_str0002F = "Sell";
   } 
   tmp_str0002E = tmp_str0002F;
   tmp_str0002F = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str0002E, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str0002F);
   Gb_00083 = false;
   } 
   else { 
   Gb_00083 = true;
   } 
   if (Gb_00083 != false) {
   tmp_str00030 = comment + "-CANDLE-";
   Gi_00084 = Ii_0478C + 1;
   tmp_str00031 = (string)Gi_00084;
   tmp_str00030 = tmp_str00030 + tmp_str00031;
   Ii_04788 = OrderSend(_Symbol, 0, NormalizeDouble(Id_04728, 2), NormalizeDouble(Ask, _Digits), 10, 0, 0, tmp_str00030, Magic, 0, 32768);
   Gd_00084 = (Dist * Id_046F8);
   Gd_00084 = (Bid - Gd_00084);
   Gd_00085 = Gd_00084;
   tmp_str00031 = "i[GoldRushNews] LineSell";
   if (Gd_00084 == 0) { 
   Gd_00085 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00031, 0, 0, Gd_00085) != true) { 
   tmp_str00032 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00032);
   } 
   if (Ii_04788 < 0) {
   tmp_str00033 = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str00033);
   return ;
   }}}}}}}
   if ((InpUseTime && TimeHour(TimeCurrent()) >= InpStartHour && TimeHour(TimeCurrent()) <= InpEndHour) || !InpUseTime) {
   
   if ((Ib_047C1 && Ib_047C0) || (Ib_047C1 && SetMMMinus == false && SetMMPlus == false)) {
   
   if ((Open[0] > Close[0]) && (Ask <= Id_04790)) { 
   Gi_00087 = -1;
   Gl_00088 = 0;
   Ii_005E8 = HistoryTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 1) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic && OrderOpenTime() > Gl_00088) { 
   Gl_00088 = OrderOpenTime();
   Gi_00087 = OrderType();
   } 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_00087 != 1) { 
   Gi_00089 = -1;
   Gi_0008A = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00089 == -1 || OrderType() == Gi_00089) { 
   
   Gi_0008A = Gi_0008A + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_0008A == 0 && Ib_046F0 && Lb_FFFAE) { 
   Gd_0008B = Id_04700;
   Gd_0008C = Id_04708;
   Gi_0008D = 1;
   Gi_0008E = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_0008F = Gi_0008E;
   if (Gi_0008E != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_0008E, Gi_0008E);
   } 
   Gb_0008E = false;
   Gb_00090 = false;
   returned_i = Gi_0008D;
   if (returned_i == 0) {
   
   Gb_00091 = (Gd_0008C > (Gi_0008F * Id_046F8));
   Gb_0008E = Gb_00091;
   if (Gb_00091 != true) { 
   Gd_00092 = (Gi_0008F * Id_046F8);
   tmp_str00034 = EnumToString((ENUM_ORDER_TYPE) Gi_0008D);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00034, Gd_0008C, (Bid - Gd_00092), Bid, Gi_0008F);
   } 
   Gb_00092 = (Gd_0008B > (Gi_0008F * Id_046F8));
   Gb_00090 = Gb_00092;
   if (Gb_00092 != true) { 
   tmp_str00035 = EnumToString((ENUM_ORDER_TYPE) Gi_0008D);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00035, Gd_0008B, ((Gi_0008F * Id_046F8) + Bid), Bid, Gi_0008F);
   } 
   Gb_00093 = Gb_0008E;
   if (Gb_0008E) { 
   Gb_00093 = Gb_00090;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_00094 = (Gd_0008C > (Gi_0008F * Id_046F8));
   Gb_0008E = Gb_00094;
   if (Gb_00094 != true) { 
   tmp_str00036 = EnumToString((ENUM_ORDER_TYPE) Gi_0008D);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00036, Gd_0008C, ((Gi_0008F * Id_046F8) + Ask), Ask, Gi_0008F);
   } 
   Gb_00095 = (Gd_0008B > (Gi_0008F * Id_046F8));
   Gb_00090 = Gb_00095;
   if (Gb_00095 != true) { 
   Gd_00096 = (Gi_0008F * Id_046F8);
   tmp_str00037 = EnumToString((ENUM_ORDER_TYPE) Gi_0008D);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00037, Gd_0008B, (Ask - Gd_00096), Ask, Gi_0008F);
   } 
   Gb_00096 = Gb_00090;
   if (Gb_00090) { 
   Gb_00096 = Gb_0008E;
   } 
   Gb_00093 = Gb_00096;
   }
   else{
   Gb_00093 = false;
   }
   if (Gb_00093 == false) return; 
   Gb_00097 = (AccountFreeMarginCheck(_Symbol, 1, Id_04728) < 0);
   if (Gb_00097) { 
   if (false) { 
   tmp_str00039 = "Buy";
   } 
   else { 
   tmp_str00039 = "Sell";
   } 
   tmp_str00038 = tmp_str00039;
   tmp_str00039 = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str00038, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str00039);
   Gb_00097 = false;
   } 
   else { 
   Gb_00097 = true;
   } 
   if (Gb_00097) { 
   tmp_str0003A = comment + "-BUY&SELL-";
   Gi_00098 = Ii_0478C + 1;
   tmp_str0003B = (string)Gi_00098;
   tmp_str0003A = tmp_str0003A + tmp_str0003B;
   Ii_04788 = OrderSend(_Symbol, 1, NormalizeDouble(Id_04728, 2), NormalizeDouble(Bid, _Digits), 10, 0, 0, tmp_str0003A, Magic, 0, 255);
   Gd_00098 = ((Dist * Id_046F8) + Ask);
   Gd_00099 = Gd_00098;
   tmp_str0003B = "i[GoldRushNews] LineBuy";
   if (Gd_00098 == 0) { 
   Gd_00099 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str0003B, 0, 0, Gd_00099) != true) { 
   tmp_str0003C = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str0003C);
   } 
   if (Ii_04788 < 0) { 
   tmp_str0003D = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str0003D);
   return ;
   }}}}} 
   if ((Open[0] < Close[0]) && (Bid >= Id_04798)) {
   Gi_0009B = -1;
   Gl_0009C = 0;
   Ii_005E8 = HistoryTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 1) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic && OrderOpenTime() > Gl_0009C) { 
   Gl_0009C = OrderOpenTime();
   Gi_0009B = OrderType();
   } 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_0009B != 0) {
   Gi_0009D = -1;
   Gi_0009E = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_0009D == -1 || OrderType() == Gi_0009D) { 
   
   Gi_0009E = Gi_0009E + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_0009E == 0 && Ib_046F0 && Lb_FFFAF) {
   Gd_0009F = Id_04700;
   Gd_000A0 = Id_04708;
   Gi_000A1 = 0;
   Gi_000A2 = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_000A3 = Gi_000A2;
   if (Gi_000A2 != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_000A2, Gi_000A2);
   } 
   Gb_000A2 = false;
   Gb_000A4 = false;
   returned_i = Gi_000A1;
   if (returned_i == 0) {
   
   Gb_000A5 = (Gd_000A0 > (Gi_000A3 * Id_046F8));
   Gb_000A2 = Gb_000A5;
   if (Gb_000A5 != true) { 
   Gd_000A6 = (Gi_000A3 * Id_046F8);
   tmp_str0003E = EnumToString((ENUM_ORDER_TYPE) Gi_000A1);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0003E, Gd_000A0, (Bid - Gd_000A6), Bid, Gi_000A3);
   } 
   Gb_000A6 = (Gd_0009F > (Gi_000A3 * Id_046F8));
   Gb_000A4 = Gb_000A6;
   if (Gb_000A6 != true) { 
   tmp_str0003F = EnumToString((ENUM_ORDER_TYPE) Gi_000A1);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0003F, Gd_0009F, ((Gi_000A3 * Id_046F8) + Bid), Bid, Gi_000A3);
   } 
   Gb_000A7 = Gb_000A2;
   if (Gb_000A2) { 
   Gb_000A7 = Gb_000A4;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_000A8 = (Gd_000A0 > (Gi_000A3 * Id_046F8));
   Gb_000A2 = Gb_000A8;
   if (Gb_000A8 != true) { 
   tmp_str00040 = EnumToString((ENUM_ORDER_TYPE) Gi_000A1);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00040, Gd_000A0, ((Gi_000A3 * Id_046F8) + Ask), Ask, Gi_000A3);
   } 
   Gb_000A9 = (Gd_0009F > (Gi_000A3 * Id_046F8));
   Gb_000A4 = Gb_000A9;
   if (Gb_000A9 != true) { 
   Gd_000AA = (Gi_000A3 * Id_046F8);
   tmp_str00041 = EnumToString((ENUM_ORDER_TYPE) Gi_000A1);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00041, Gd_0009F, (Ask - Gd_000AA), Ask, Gi_000A3);
   } 
   Gb_000AA = Gb_000A4;
   if (Gb_000A4) { 
   Gb_000AA = Gb_000A2;
   } 
   Gb_000A7 = Gb_000AA;
   }
   else{
   Gb_000A7 = false;
   }
   if (Gb_000A7 == false) return; 
   Gb_000AB = (AccountFreeMarginCheck(_Symbol, 0, Id_04728) < 0);
   if (Gb_000AB) { 
   if (true) { 
   tmp_str00043 = "Buy";
   } 
   else { 
   tmp_str00043 = "Sell";
   } 
   tmp_str00042 = tmp_str00043;
   tmp_str00043 = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str00042, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str00043);
   Gb_000AB = false;
   } 
   else { 
   Gb_000AB = true;
   } 
   if (Gb_000AB != false) {
   tmp_str00044 = comment + "-BUY&SELL-";
   Gi_000AC = Ii_0478C + 1;
   tmp_str00045 = (string)Gi_000AC;
   tmp_str00044 = tmp_str00044 + tmp_str00045;
   Ii_04788 = OrderSend(_Symbol, 0, NormalizeDouble(Id_04728, 2), NormalizeDouble(Ask, _Digits), 10, 0, 0, tmp_str00044, Magic, 0, 32768);
   Gd_000AC = (Dist * Id_046F8);
   Gd_000AC = (Bid - Gd_000AC);
   Gd_000AD = Gd_000AC;
   tmp_str00045 = "i[GoldRushNews] LineSell";
   if (Gd_000AC == 0) { 
   Gd_000AD = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00045, 0, 0, Gd_000AD) != true) { 
   tmp_str00046 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00046);
   } 
   if (Ii_04788 < 0) {
   tmp_str00047 = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str00047);
   return ;
   }}}}}}
   if ((Ib_047C2 && Ib_047C0) || (Ib_047C2 && SetMMMinus == false && SetMMPlus == false)) {
   
   if ((Open[1] > Close[1]) && (Open[1] > Open[0]) && (Close[1] > Close[0]) && (Ask <= Id_04790)) { 
   Gi_000B3 = -1;
   Gi_000B4 = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_000B3 == -1 || OrderType() == Gi_000B3) { 
   
   Gi_000B4 = Gi_000B4 + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_000B4 == 0 && Ib_046F0 && Lb_FFFAE) { 
   Gd_000B5 = Id_04700;
   Gd_000B6 = Id_04708;
   Gi_000B7 = 1;
   Gi_000B8 = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_000B9 = Gi_000B8;
   if (Gi_000B8 != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_000B8, Gi_000B8);
   } 
   Gb_000B8 = false;
   Gb_000BA = false;
   returned_i = Gi_000B7;
   if (returned_i == 0) {
   
   Gb_000BB = (Gd_000B6 > (Gi_000B9 * Id_046F8));
   Gb_000B8 = Gb_000BB;
   if (Gb_000BB != true) { 
   Gd_000BC = (Gi_000B9 * Id_046F8);
   tmp_str00048 = EnumToString((ENUM_ORDER_TYPE) Gi_000B7);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00048, Gd_000B6, (Bid - Gd_000BC), Bid, Gi_000B9);
   } 
   Gb_000BC = (Gd_000B5 > (Gi_000B9 * Id_046F8));
   Gb_000BA = Gb_000BC;
   if (Gb_000BC != true) { 
   tmp_str00049 = EnumToString((ENUM_ORDER_TYPE) Gi_000B7);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00049, Gd_000B5, ((Gi_000B9 * Id_046F8) + Bid), Bid, Gi_000B9);
   } 
   Gb_000BD = Gb_000B8;
   if (Gb_000B8) { 
   Gb_000BD = Gb_000BA;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_000BE = (Gd_000B6 > (Gi_000B9 * Id_046F8));
   Gb_000B8 = Gb_000BE;
   if (Gb_000BE != true) { 
   tmp_str0004A = EnumToString((ENUM_ORDER_TYPE) Gi_000B7);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0004A, Gd_000B6, ((Gi_000B9 * Id_046F8) + Ask), Ask, Gi_000B9);
   } 
   Gb_000BF = (Gd_000B5 > (Gi_000B9 * Id_046F8));
   Gb_000BA = Gb_000BF;
   if (Gb_000BF != true) { 
   Gd_000C0 = (Gi_000B9 * Id_046F8);
   tmp_str0004B = EnumToString((ENUM_ORDER_TYPE) Gi_000B7);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0004B, Gd_000B5, (Ask - Gd_000C0), Ask, Gi_000B9);
   } 
   Gb_000C0 = Gb_000BA;
   if (Gb_000BA) { 
   Gb_000C0 = Gb_000B8;
   } 
   Gb_000BD = Gb_000C0;
   }
   else{
   Gb_000BD = false;
   }
   if (Gb_000BD == false) return; 
   Gb_000C1 = (AccountFreeMarginCheck(_Symbol, 1, Id_04728) < 0);
   if (Gb_000C1) { 
   if (false) { 
   tmp_str0004D = "Buy";
   } 
   else { 
   tmp_str0004D = "Sell";
   } 
   tmp_str0004C = tmp_str0004D;
   tmp_str0004D = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str0004C, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str0004D);
   Gb_000C1 = false;
   } 
   else { 
   Gb_000C1 = true;
   } 
   if (Gb_000C1) { 
   tmp_str0004E = comment + "-CANDLE-";
   Gi_000C2 = Ii_0478C + 1;
   tmp_str0004F = (string)Gi_000C2;
   tmp_str0004E = tmp_str0004E + tmp_str0004F;
   Ii_04788 = OrderSend(_Symbol, 1, NormalizeDouble(Id_04728, 2), NormalizeDouble(Bid, _Digits), 10, 0, 0, tmp_str0004E, Magic, 0, 255);
   Gd_000C2 = ((Dist * Id_046F8) + Ask);
   Gd_000C3 = Gd_000C2;
   tmp_str0004F = "i[GoldRushNews] LineBuy";
   if (Gd_000C2 == 0) { 
   Gd_000C3 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str0004F, 0, 0, Gd_000C3) != true) { 
   tmp_str00050 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00050);
   } 
   if (Ii_04788 < 0) { 
   tmp_str00051 = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str00051);
   return ;
   }}}} 
   if ((Open[1] < Close[1]) && (Open[1] < Open[0]) && (Close[1] < Close[0]) && (Bid >= Id_04798)) {
   Gi_000C9 = -1;
   Gi_000CA = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_000C9 == -1 || OrderType() == Gi_000C9) { 
   
   Gi_000CA = Gi_000CA + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_000CA == 0 && Ib_046F0 && Lb_FFFAF) {
   Gd_000CB = Id_04700;
   Gd_000CC = Id_04708;
   Gi_000CD = 0;
   Gi_000CE = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_000CF = Gi_000CE;
   if (Gi_000CE != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_000CE, Gi_000CE);
   } 
   Gb_000CE = false;
   Gb_000D0 = false;
   returned_i = Gi_000CD;
   if (returned_i == 0) {
   
   Gb_000D1 = (Gd_000CC > (Gi_000CF * Id_046F8));
   Gb_000CE = Gb_000D1;
   if (Gb_000D1 != true) { 
   Gd_000D2 = (Gi_000CF * Id_046F8);
   tmp_str00052 = EnumToString((ENUM_ORDER_TYPE) Gi_000CD);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00052, Gd_000CC, (Bid - Gd_000D2), Bid, Gi_000CF);
   } 
   Gb_000D2 = (Gd_000CB > (Gi_000CF * Id_046F8));
   Gb_000D0 = Gb_000D2;
   if (Gb_000D2 != true) { 
   tmp_str00053 = EnumToString((ENUM_ORDER_TYPE) Gi_000CD);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00053, Gd_000CB, ((Gi_000CF * Id_046F8) + Bid), Bid, Gi_000CF);
   } 
   Gb_000D3 = Gb_000CE;
   if (Gb_000CE) { 
   Gb_000D3 = Gb_000D0;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_000D4 = (Gd_000CC > (Gi_000CF * Id_046F8));
   Gb_000CE = Gb_000D4;
   if (Gb_000D4 != true) { 
   tmp_str00054 = EnumToString((ENUM_ORDER_TYPE) Gi_000CD);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00054, Gd_000CC, ((Gi_000CF * Id_046F8) + Ask), Ask, Gi_000CF);
   } 
   Gb_000D5 = (Gd_000CB > (Gi_000CF * Id_046F8));
   Gb_000D0 = Gb_000D5;
   if (Gb_000D5 != true) { 
   Gd_000D6 = (Gi_000CF * Id_046F8);
   tmp_str00055 = EnumToString((ENUM_ORDER_TYPE) Gi_000CD);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00055, Gd_000CB, (Ask - Gd_000D6), Ask, Gi_000CF);
   } 
   Gb_000D6 = Gb_000D0;
   if (Gb_000D0) { 
   Gb_000D6 = Gb_000CE;
   } 
   Gb_000D3 = Gb_000D6;
   }
   else{
   Gb_000D3 = false;
   }
   if (Gb_000D3 == false) return; 
   Gb_000D7 = (AccountFreeMarginCheck(_Symbol, 0, Id_04728) < 0);
   if (Gb_000D7) { 
   if (true) { 
   tmp_str00057 = "Buy";
   } 
   else { 
   tmp_str00057 = "Sell";
   } 
   tmp_str00056 = tmp_str00057;
   tmp_str00057 = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str00056, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str00057);
   Gb_000D7 = false;
   } 
   else { 
   Gb_000D7 = true;
   } 
   if (Gb_000D7 != false) {
   tmp_str00058 = comment + "-CANDLE-";
   Gi_000D8 = Ii_0478C + 1;
   tmp_str00059 = (string)Gi_000D8;
   tmp_str00058 = tmp_str00058 + tmp_str00059;
   Ii_04788 = OrderSend(_Symbol, 0, NormalizeDouble(Id_04728, 2), NormalizeDouble(Ask, _Digits), 10, 0, 0, tmp_str00058, Magic, 0, 32768);
   Gd_000D8 = (Dist * Id_046F8);
   Gd_000D8 = (Bid - Gd_000D8);
   Gd_000D9 = Gd_000D8;
   tmp_str00059 = "i[GoldRushNews] LineSell";
   if (Gd_000D8 == 0) { 
   Gd_000D9 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00059, 0, 0, Gd_000D9) != true) { 
   tmp_str0005A = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str0005A);
   } 
   if (Ii_04788 < 0) {
   tmp_str0005B = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str0005B);
   return ;
   }}}}}
   if ((InpUseTime && TimeHour(TimeCurrent()) >= InpStartHour && TimeHour(TimeCurrent()) <= InpEndHour) || !InpUseTime) {
   
   if ((Ib_047C3 && Ib_047C0) || (Ib_047C3 && SetMMMinus == false && SetMMPlus == false)) {
   
   Gi_000D8 = 1;
   Gi_000DA = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_000D8 == -1 || OrderType() == Gi_000D8) { 
   
   Gi_000DA = Gi_000DA + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_000DA == 0 && Ib_046F0 && Lb_FFFAE) { 
   Gd_000DB = Id_04700;
   Gd_000DC = Id_04708;
   Gi_000DD = 1;
   Gi_000DE = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_000DF = Gi_000DE;
   if (Gi_000DE != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_000DE, Gi_000DE);
   } 
   Gb_000DE = false;
   Gb_000E0 = false;
   returned_i = Gi_000DD;
   if (returned_i == 0) {
   
   Gb_000E1 = (Gd_000DC > (Gi_000DF * Id_046F8));
   Gb_000DE = Gb_000E1;
   if (Gb_000E1 != true) { 
   Gd_000E2 = (Gi_000DF * Id_046F8);
   tmp_str0005C = EnumToString((ENUM_ORDER_TYPE) Gi_000DD);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0005C, Gd_000DC, (Bid - Gd_000E2), Bid, Gi_000DF);
   } 
   Gb_000E2 = (Gd_000DB > (Gi_000DF * Id_046F8));
   Gb_000E0 = Gb_000E2;
   if (Gb_000E2 != true) { 
   tmp_str0005D = EnumToString((ENUM_ORDER_TYPE) Gi_000DD);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0005D, Gd_000DB, ((Gi_000DF * Id_046F8) + Bid), Bid, Gi_000DF);
   } 
   Gb_000E3 = Gb_000DE;
   if (Gb_000DE) { 
   Gb_000E3 = Gb_000E0;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_000E4 = (Gd_000DC > (Gi_000DF * Id_046F8));
   Gb_000DE = Gb_000E4;
   if (Gb_000E4 != true) { 
   tmp_str0005E = EnumToString((ENUM_ORDER_TYPE) Gi_000DD);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0005E, Gd_000DC, ((Gi_000DF * Id_046F8) + Ask), Ask, Gi_000DF);
   } 
   Gb_000E5 = (Gd_000DB > (Gi_000DF * Id_046F8));
   Gb_000E0 = Gb_000E5;
   if (Gb_000E5 != true) { 
   Gd_000E6 = (Gi_000DF * Id_046F8);
   tmp_str0005F = EnumToString((ENUM_ORDER_TYPE) Gi_000DD);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0005F, Gd_000DB, (Ask - Gd_000E6), Ask, Gi_000DF);
   } 
   Gb_000E6 = Gb_000E0;
   if (Gb_000E0) { 
   Gb_000E6 = Gb_000DE;
   } 
   Gb_000E3 = Gb_000E6;
   }
   else{
   Gb_000E3 = false;
   }
   if (Gb_000E3 == false) return; 
   Gb_000E7 = (AccountFreeMarginCheck(_Symbol, 1, Id_04728) < 0);
   if (Gb_000E7) { 
   if (false) { 
   tmp_str00061 = "Buy";
   } 
   else { 
   tmp_str00061 = "Sell";
   } 
   tmp_str00060 = tmp_str00061;
   tmp_str00061 = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str00060, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str00061);
   Gb_000E7 = false;
   } 
   else { 
   Gb_000E7 = true;
   } 
   if (Gb_000E7) { 
   tmp_str00062 = comment + "-HEDGING-";
   Gi_000E8 = Ii_0478C + 1;
   tmp_str00063 = (string)Gi_000E8;
   tmp_str00062 = tmp_str00062 + tmp_str00063;
   Ii_04788 = OrderSend(_Symbol, 1, NormalizeDouble(Id_04728, 2), NormalizeDouble(Bid, _Digits), 10, 0, 0, tmp_str00062, Magic, 0, 255);
   Gd_000E8 = ((Dist * Id_046F8) + Ask);
   Gd_000E9 = Gd_000E8;
   tmp_str00063 = "i[GoldRushNews] LineBuy";
   if (Gd_000E8 == 0) { 
   Gd_000E9 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00063, 0, 0, Gd_000E9) != true) { 
   tmp_str00064 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00064);
   } 
   if (Ii_04788 < 0) { 
   tmp_str00065 = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str00065);
   return ;
   }}} 
   Gi_000E8 = 0;
   Gi_000EA = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_000E8 == -1 || OrderType() == Gi_000E8) { 
   
   Gi_000EA = Gi_000EA + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_000EA == 0 && Ib_046F0 && Lb_FFFAF) { 
   Gd_000EB = Id_04700;
   Gd_000EC = Id_04708;
   Gi_000ED = 0;
   Gi_000EE = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_000EF = Gi_000EE;
   if (Gi_000EE != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_000EE, Gi_000EE);
   } 
   Gb_000EE = false;
   Gb_000F0 = false;
   returned_i = Gi_000ED;
   if (returned_i == 0) {
   
   Gb_000F1 = (Gd_000EC > (Gi_000EF * Id_046F8));
   Gb_000EE = Gb_000F1;
   if (Gb_000F1 != true) { 
   Gd_000F2 = (Gi_000EF * Id_046F8);
   tmp_str00066 = EnumToString((ENUM_ORDER_TYPE) Gi_000ED);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00066, Gd_000EC, (Bid - Gd_000F2), Bid, Gi_000EF);
   } 
   Gb_000F2 = (Gd_000EB > (Gi_000EF * Id_046F8));
   Gb_000F0 = Gb_000F2;
   if (Gb_000F2 != true) { 
   tmp_str00067 = EnumToString((ENUM_ORDER_TYPE) Gi_000ED);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00067, Gd_000EB, ((Gi_000EF * Id_046F8) + Bid), Bid, Gi_000EF);
   } 
   Gb_000F3 = Gb_000EE;
   if (Gb_000EE) { 
   Gb_000F3 = Gb_000F0;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_000F4 = (Gd_000EC > (Gi_000EF * Id_046F8));
   Gb_000EE = Gb_000F4;
   if (Gb_000F4 != true) { 
   tmp_str00068 = EnumToString((ENUM_ORDER_TYPE) Gi_000ED);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00068, Gd_000EC, ((Gi_000EF * Id_046F8) + Ask), Ask, Gi_000EF);
   } 
   Gb_000F5 = (Gd_000EB > (Gi_000EF * Id_046F8));
   Gb_000F0 = Gb_000F5;
   if (Gb_000F5 != true) { 
   Gd_000F6 = (Gi_000EF * Id_046F8);
   tmp_str00069 = EnumToString((ENUM_ORDER_TYPE) Gi_000ED);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00069, Gd_000EB, (Ask - Gd_000F6), Ask, Gi_000EF);
   } 
   Gb_000F6 = Gb_000F0;
   if (Gb_000F0) { 
   Gb_000F6 = Gb_000EE;
   } 
   Gb_000F3 = Gb_000F6;
   }
   else{
   Gb_000F3 = false;
   }
   if (Gb_000F3 == false) return; 
   Gb_000F7 = (AccountFreeMarginCheck(_Symbol, 0, Id_04728) < 0);
   if (Gb_000F7) { 
   if (true) { 
   tmp_str0006B = "Buy";
   } 
   else { 
   tmp_str0006B = "Sell";
   } 
   tmp_str0006A = tmp_str0006B;
   tmp_str0006B = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str0006A, " ", Id_04728, " ", _Symbol, " Error Msg = ", tmp_str0006B);
   Gb_000F7 = false;
   } 
   else { 
   Gb_000F7 = true;
   } 
   if (Gb_000F7) { 
   tmp_str0006C = comment + "-HEDGING-";
   Gi_000F8 = Ii_0478C + 1;
   tmp_str0006D = (string)Gi_000F8;
   tmp_str0006C = tmp_str0006C + tmp_str0006D;
   Ii_04788 = OrderSend(_Symbol, 0, NormalizeDouble(Id_04728, 2), NormalizeDouble(Ask, _Digits), 10, 0, 0, tmp_str0006C, Magic, 0, 32768);
   Gd_000F8 = (Dist * Id_046F8);
   Gd_000F8 = (Bid - Gd_000F8);
   Gd_000F9 = Gd_000F8;
   tmp_str0006D = "i[GoldRushNews] LineSell";
   if (Gd_000F8 == 0) { 
   Gd_000F9 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str0006D, 0, 0, Gd_000F9) != true) { 
   tmp_str0006E = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str0006E);
   } 
   if (Ii_04788 < 0) { 
   tmp_str0006F = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str0006F);
   return ;
   }}}}}}}}}}}}} 
   if (SetStrategies == 1) { 
   Is_04800 = comment + "-BUY&SELL-";
   } 
   else { 
   if (SetStrategies == 2) { 
   Is_04800 = comment + "-CANDLE-";
   } 
   else { 
   if (SetStrategies == 3) { 
   Is_04800 = comment + "-HEDGING-";
   }}} 
   Gi_000F8 = -1;
   Gi_000FA = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_000F8 == -1 || OrderType() == Gi_000F8) { 
   
   Gi_000FA = Gi_000FA + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   returned_double = MathPow(Id_04720, Gi_000FA);
   returned_double = NormalizeDouble((Id_04728 * returned_double), 2);
   Id_04738 = returned_double;
   if (SetAutoLot && (returned_double > MaximumInitLot) && (MaximumInitLot != 0)) { 
   Id_04738 = MaximumInitLot;
   } 
   Ii_0471C = MaxTrades;
   if (MaxTrades == 0 && SetAutoLot == false) { 
   Ii_0471C = 2147483647;
   } 
   else { 
   if (SetAutoLot && (BalanceCycle != 0)) { 
   Ii_0471C = (int)NormalizeDouble((AccountBalance() / BalanceCycle), 5);
   if (Ii_0471C > MaxTrades && MaxTrades != 0) { 
   Ii_0471C = MaxTrades;
   }}} 
   if ((Open[0] > Close[0]) && (Ask <= Id_04790)) { 
   Gi_000FD = 1;
   Gi_000FE = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_000FD == -1 || OrderType() == Gi_000FD) { 
   
   Gi_000FE = Gi_000FE + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_000FE > 0) { 
   Gd_000FF = (Step * Id_046F8);
   Gd_000FF = (Bid - Gd_000FF);
   Gi_00100 = 0;
   Gd_00101 = 0;
   Gi_00102 = 0;
   Gi_00103 = OrdersTotal() - 1;
   Gi_00104 = Gi_00103;
   if (Gi_00103 >= 0) { 
   do { 
   order_check = OrderSelect(Gi_00104, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderType() == OP_SELL) { 
   Gi_00100 = OrderTicket();
   if (Gi_00100 > Gi_00102) { 
   Gd_00101 = OrderOpenPrice();
   Gi_00102 = Gi_00100;
   }} 
   Gi_00104 = Gi_00104 - 1;
   } while (Gi_00104 >= 0); 
   } 
   if ((Gd_000FF > Gd_00101) && Ii_0478C < Ii_0471C && Lb_FFFAE) { 
   Gd_00103 = Id_04738;
   returned_double = SymbolInfoDouble(NULL, 34);
   if ((Id_04738 < returned_double)) { 
   Gd_00105 = returned_double;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 35);
   if ((Gd_00103 > returned_double)) { 
   Gd_00105 = returned_double;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 36);
   Gd_00106 = round((Gd_00103 / returned_double));
   Gi_00106 = (int)Gd_00106;
   Gd_00107 = fabs(((Gi_00106 * returned_double) - Gd_00103));
   if ((Gd_00107 > 1E-07)) { 
   Gd_00105 = (Gi_00106 * returned_double);
   } 
   else { 
   Gd_00105 = Gd_00103;
   }}} 
   Id_04738 = Gd_00105;
   Gd_00107 = Id_04700;
   Gd_00108 = Id_04708;
   Gi_00109 = 1;
   Gi_0010A = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_0010B = Gi_0010A;
   if (Gi_0010A != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_0010A, Gi_0010A);
   } 
   Gb_0010A = false;
   Gb_0010C = false;
   returned_i = Gi_00109;
   if (returned_i == 0) {
   
   Gb_0010D = (Gd_00108 > (Gi_0010B * Id_046F8));
   Gb_0010A = Gb_0010D;
   if (Gb_0010D != true) { 
   Gd_0010E = (Gi_0010B * Id_046F8);
   tmp_str00070 = EnumToString((ENUM_ORDER_TYPE) Gi_00109);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00070, Gd_00108, (Bid - Gd_0010E), Bid, Gi_0010B);
   } 
   Gb_0010E = (Gd_00107 > (Gi_0010B * Id_046F8));
   Gb_0010C = Gb_0010E;
   if (Gb_0010E != true) { 
   tmp_str00071 = EnumToString((ENUM_ORDER_TYPE) Gi_00109);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00071, Gd_00107, ((Gi_0010B * Id_046F8) + Bid), Bid, Gi_0010B);
   } 
   Gb_0010F = Gb_0010A;
   if (Gb_0010A) { 
   Gb_0010F = Gb_0010C;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_00110 = (Gd_00108 > (Gi_0010B * Id_046F8));
   Gb_0010A = Gb_00110;
   if (Gb_00110 != true) { 
   tmp_str00072 = EnumToString((ENUM_ORDER_TYPE) Gi_00109);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00072, Gd_00108, ((Gi_0010B * Id_046F8) + Ask), Ask, Gi_0010B);
   } 
   Gb_00111 = (Gd_00107 > (Gi_0010B * Id_046F8));
   Gb_0010C = Gb_00111;
   if (Gb_00111 != true) { 
   Gd_00112 = (Gi_0010B * Id_046F8);
   tmp_str00073 = EnumToString((ENUM_ORDER_TYPE) Gi_00109);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str00073, Gd_00107, (Ask - Gd_00112), Ask, Gi_0010B);
   } 
   Gb_00112 = Gb_0010C;
   if (Gb_0010C) { 
   Gb_00112 = Gb_0010A;
   } 
   Gb_0010F = Gb_00112;
   }
   else{
   Gb_0010F = false;
   }
   if (Gb_0010F == false) return; 
   Gb_00113 = (AccountFreeMarginCheck(_Symbol, 1, Id_04738) < 0);
   if (Gb_00113) { 
   if (false) { 
   tmp_str00075 = "Buy";
   } 
   else { 
   tmp_str00075 = "Sell";
   } 
   tmp_str00074 = tmp_str00075;
   tmp_str00075 = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str00074, " ", Id_04738, " ", _Symbol, " Error Msg = ", tmp_str00075);
   Gb_00113 = false;
   } 
   else { 
   Gb_00113 = true;
   } 
   if (Gb_00113) { 
   Gi_00114 = Ii_0478C + 1;
   tmp_str00076 = (string)Gi_00114;
   tmp_str00076 = Is_04800 + tmp_str00076;
   Ii_04788 = OrderSend(_Symbol, 1, NormalizeDouble(Id_04738, 2), NormalizeDouble(Bid, _Digits), 10, 0, 0, tmp_str00076, Magic, 0, 255);
   Gd_00114 = ((Dist * Id_046F8) + Ask);
   Gd_00115 = Gd_00114;
   tmp_str00077 = "i[GoldRushNews] LineBuy";
   if (Gd_00114 == 0) { 
   Gd_00115 = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00077, 0, 0, Gd_00115) != true) { 
   tmp_str00078 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00078);
   } 
   if (Ii_04788 < 0) { 
   tmp_str00079 = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str00079);
   return ;
   }}}}} 
   if ((Open[0] < Close[0]) && (Bid >= Id_04798)) { 
   Gi_00117 = 0;
   Gi_00118 = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00117 == -1 || OrderType() == Gi_00117) { 
   
   Gi_00118 = Gi_00118 + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_00118 > 0) { 
   Gd_00119 = ((Step * Id_046F8) + Ask);
   Gi_0011A = 0;
   Gd_0011B = 0;
   Gi_0011C = 0;
   Gi_0011D = OrdersTotal() - 1;
   Gi_0011E = Gi_0011D;
   if (Gi_0011D >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0011E, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderType() == OP_BUY) { 
   Gi_0011A = OrderTicket();
   if (Gi_0011A > Gi_0011C) { 
   Gd_0011B = OrderOpenPrice();
   Gi_0011C = Gi_0011A;
   }} 
   Gi_0011E = Gi_0011E - 1;
   } while (Gi_0011E >= 0); 
   } 
   if ((Gd_00119 < Gd_0011B) && Ii_0478C < Ii_0471C && Lb_FFFAF) { 
   Gd_0011D = Id_04738;
   returned_double = SymbolInfoDouble(NULL, 34);
   if ((Id_04738 < returned_double)) { 
   Gd_0011F = returned_double;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 35);
   if ((Gd_0011D > returned_double)) { 
   Gd_0011F = returned_double;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 36);
   Gd_00120 = round((Gd_0011D / returned_double));
   Gi_00120 = (int)Gd_00120;
   Gd_00121 = fabs(((Gi_00120 * returned_double) - Gd_0011D));
   if ((Gd_00121 > 1E-07)) { 
   Gd_0011F = (Gi_00120 * returned_double);
   } 
   else { 
   Gd_0011F = Gd_0011D;
   }}} 
   Id_04738 = Gd_0011F;
   Gd_00121 = Id_04700;
   Gd_00122 = Id_04708;
   Gi_00123 = 0;
   Gi_00124 = (int)SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
   Gi_00125 = Gi_00124;
   if (Gi_00124 != 0) { 
   PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss And TakeProfit Must Not Be Nearer Than %d Points From The Closing Price", Gi_00124, Gi_00124);
   } 
   Gb_00124 = false;
   Gb_00126 = false;
   returned_i = Gi_00123;
   if (returned_i == 0) {
   
   Gb_00127 = (Gd_00122 > (Gi_00125 * Id_046F8));
   Gb_00124 = Gb_00127;
   if (Gb_00127 != true) { 
   Gd_00128 = (Gi_00125 * Id_046F8);
   tmp_str0007A = EnumToString((ENUM_ORDER_TYPE) Gi_00123);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Less Than %.5f (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0007A, Gd_00122, (Bid - Gd_00128), Bid, Gi_00125);
   } 
   Gb_00128 = (Gd_00121 > (Gi_00125 * Id_046F8));
   Gb_00126 = Gb_00128;
   if (Gb_00128 != true) { 
   tmp_str0007B = EnumToString((ENUM_ORDER_TYPE) Gi_00123);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Greater Than %.5f (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0007B, Gd_00121, ((Gi_00125 * Id_046F8) + Bid), Bid, Gi_00125);
   } 
   Gb_00129 = Gb_00124;
   if (Gb_00124) { 
   Gb_00129 = Gb_00126;
   } 
   }
   else if (returned_i == 1) {
   
   Gb_0012A = (Gd_00122 > (Gi_00125 * Id_046F8));
   Gb_00124 = Gb_0012A;
   if (Gb_0012A != true) { 
   tmp_str0007C = EnumToString((ENUM_ORDER_TYPE) Gi_00123);
   PrintFormat("For Order %s StopLoss=%.5f Must Be Greater Than %.5f  (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0007C, Gd_00122, ((Gi_00125 * Id_046F8) + Ask), Ask, Gi_00125);
   } 
   Gb_0012B = (Gd_00121 > (Gi_00125 * Id_046F8));
   Gb_00126 = Gb_0012B;
   if (Gb_0012B != true) { 
   Gd_0012C = (Gi_00125 * Id_046F8);
   tmp_str0007D = EnumToString((ENUM_ORDER_TYPE) Gi_00123);
   PrintFormat("For Order %s TakeProfit=%.5f Must Be Less Than %.5f  (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d Points)", tmp_str0007D, Gd_00121, (Ask - Gd_0012C), Ask, Gi_00125);
   } 
   Gb_0012C = Gb_00126;
   if (Gb_00126) { 
   Gb_0012C = Gb_00124;
   } 
   Gb_00129 = Gb_0012C;
   }
   else{
   Gb_00129 = false;
   }
   if (Gb_00129 == false) return; 
   Gb_0012D = (AccountFreeMarginCheck(_Symbol, 0, Id_04738) < 0);
   if (Gb_0012D) { 
   if (true) { 
   tmp_str0007F = "Buy";
   } 
   else { 
   tmp_str0007F = "Sell";
   } 
   tmp_str0007E = tmp_str0007F;
   tmp_str0007F = ErrorDescription(GetLastError());
   Print("Not Enough Money For ", tmp_str0007E, " ", Id_04738, " ", _Symbol, " Error Msg = ", tmp_str0007F);
   Gb_0012D = false;
   } 
   else { 
   Gb_0012D = true;
   } 
   if (Gb_0012D) { 
   Gi_0012E = Ii_0478C + 1;
   tmp_str00080 = (string)Gi_0012E;
   tmp_str00080 = Is_04800 + tmp_str00080;
   Ii_04788 = OrderSend(_Symbol, 0, NormalizeDouble(Id_04738, 2), NormalizeDouble(Ask, _Digits), 10, 0, 0, tmp_str00080, Magic, 0, 32768);
   Gd_0012E = (Dist * Id_046F8);
   Gd_0012E = (Bid - Gd_0012E);
   Gd_0012F = Gd_0012E;
   tmp_str00081 = "i[GoldRushNews] LineSell";
   if (Gd_0012E == 0) { 
   Gd_0012F = SymbolInfoDouble(NULL, SYMBOL_BID);
   } 
   if (ObjectMove(0, tmp_str00081, 0, 0, Gd_0012F) != true) { 
   tmp_str00082 = ErrorDescription(GetLastError());
   Print("HLineMove", ": Failed To Move The Horizontal Line! Error Code = ", tmp_str00082);
   } 
   if (Ii_04788 < 0) { 
   tmp_str00083 = ErrorDescription(GetLastError());
   Print("Error: ", tmp_str00083);
   return ;
   }}}}} 
   Gi_0012E = -1;
   Gd_00130 = 0;
   Gi_00131 = OrdersTotal() - 1;
   Gi_00132 = Gi_00131;
   if (Gi_00131 >= 0) { 
   do { 
   if (OrderSelect(Gi_00132, 0, 0) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic) { 
   if (OrderType() == Gi_0012E || Gi_0012E == -1) { 
   
   Gd_00131 = OrderProfit();
   Gd_00131 = (Gd_00131 + OrderSwap());
   Gd_00130 = ((Gd_00131 + OrderCommission()) + Gd_00130);
   }} 
   Gi_00132 = Gi_00132 - 1;
   } while (Gi_00132 >= 0); 
   } 
   Id_047E8 = (Gd_00130 / (AccountBalance() / 100));
   if (SetStrategies == 1 || SetStrategies == 2) {
   
   Gi_00131 = 0;
   Gi_00133 = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_00131 == -1 || OrderType() == Gi_00131) { 
   
   Gi_00133 = Gi_00133 + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_00133 > 0 && (Ask <= Id_04790) && (Id_047E8 > MinProfit)) { 
   Gi_00134 = -1;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gd_00135 = OrderProfit();
   Gd_00135 = (Gd_00135 + OrderSwap());
   if (((Gd_00135 + OrderCommission()) < 0)) { 
   if (OrderType() == OP_BUY) { 
   if (Gi_00134 == 0 || Gi_00134 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 10, 16777215);
   }} 
   if (OrderType() == OP_SELL) { 
   if (Gi_00134 == 1 || Gi_00134 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 10, 16777215);
   }}}} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Gi_00139 = -1;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gd_0013A = OrderProfit();
   Gd_0013A = (Gd_0013A + OrderSwap());
   if (((Gd_0013A + OrderCommission()) > 0)) { 
   if (OrderType() == OP_BUY) { 
   if (Gi_00139 == 0 || Gi_00139 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 10, 16777215);
   }} 
   if (OrderType() == OP_SELL) { 
   if (Gi_00139 == 1 || Gi_00139 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 10, 16777215);
   }}}} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Gi_0013E = BreakTime * 60;
   Sleep((Gi_0013E * 1000));
   } 
   Gi_0013E = 1;
   Gi_0013F = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_0013E == -1 || OrderType() == Gi_0013E) { 
   
   Gi_0013F = Gi_0013F + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if (Gi_0013F > 0 && (Bid >= Id_04798) && (Id_047E8 > MinProfit)) {
   Gi_00140 = -1;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gd_00141 = OrderProfit();
   Gd_00141 = (Gd_00141 + OrderSwap());
   if (((Gd_00141 + OrderCommission()) < 0)) { 
   if (OrderType() == OP_BUY) { 
   if (Gi_00140 == 0 || Gi_00140 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 10, 16777215);
   }} 
   if (OrderType() == OP_SELL) { 
   if (Gi_00140 == 1 || Gi_00140 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 10, 16777215);
   }}}} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Gi_00145 = -1;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gd_00146 = OrderProfit();
   Gd_00146 = (Gd_00146 + OrderSwap());
   if (((Gd_00146 + OrderCommission()) > 0)) { 
   if (OrderType() == OP_BUY) { 
   if (Gi_00145 == 0 || Gi_00145 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 10, 16777215);
   }} 
   if (OrderType() == OP_SELL) { 
   if (Gi_00145 == 1 || Gi_00145 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 10, 16777215);
   }}}} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Gi_0014A = BreakTime * 60;
   Sleep((Gi_0014A * 1000));
   }}
   else{
   if (SetStrategies == 3) { 
   Gi_0014A = -1;
   Gi_0014B = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_0014A == -1 || OrderType() == Gi_0014A) { 
   
   Gi_0014B = Gi_0014B + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   
   Gi_0014C = -1;
   Gi_0014D = 0;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) { 
   if (Gi_0014C == -1 || OrderType() == Gi_0014C) { 
   
   Gi_0014D = Gi_0014D + 1;
   }} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   if ((Gi_0014B > 0 && Ask <= Id_04790 && Id_047E8 > MinProfit)
   || (Gi_0014D > 0 && Bid >= Id_04798 && Id_047E8 > MinProfit)) {
   
   Gi_0014E = -1;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gd_0014F = OrderProfit();
   Gd_0014F = (Gd_0014F + OrderSwap());
   if (((Gd_0014F + OrderCommission()) < 0)) { 
   if (OrderType() == OP_BUY) { 
   if (Gi_0014E == 0 || Gi_0014E == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 10, 16777215);
   }} 
   if (OrderType() == OP_SELL) { 
   if (Gi_0014E == 1 || Gi_0014E == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 10, 16777215);
   }}}} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Gi_00153 = -1;
   Ii_005E8 = OrdersTotal() - 1;
   if (Ii_005E8 >= 0) { 
   do { 
   if (OrderSelect(Ii_005E8, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gd_00154 = OrderProfit();
   Gd_00154 = (Gd_00154 + OrderSwap());
   if (((Gd_00154 + OrderCommission()) > 0)) { 
   if (OrderType() == OP_BUY) { 
   if (Gi_00153 == 0 || Gi_00153 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 10, 16777215);
   }} 
   if (OrderType() == OP_SELL) { 
   if (Gi_00153 == 1 || Gi_00153 == -1) { 
   
   RefreshRates();
   order_check = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 10, 16777215);
   }}}} 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Gi_00158 = BreakTime * 60;
   Sleep((Gi_00158 * 1000));
   }}} 
   if (SetInfo == false) return; 
   tmp_str00084 = "i[GoldRushNews] INFO_font";
   if (ObjectCreate(0, tmp_str00084, OBJ_RECTANGLE_LABEL, 0, 0, 0)) { 
   ObjectSetInteger(0, tmp_str00084, 102, 270);
   ObjectSetInteger(0, tmp_str00084, 103, 20);
   ObjectSetInteger(0, tmp_str00084, 1019, 250);
   ObjectSetInteger(0, tmp_str00084, 1020, 290);
   ObjectSetInteger(0, tmp_str00084, 1025, Ii_047F8);
   ObjectSetInteger(0, tmp_str00084, 1029, 2);
   ObjectSetInteger(0, tmp_str00084, 101, 1);
   ObjectSetInteger(0, tmp_str00084, 6, 16711680);
   ObjectSetInteger(0, tmp_str00084, 8, 1);
   ObjectSetInteger(0, tmp_str00084, 9, 0);
   ObjectSetInteger(0, tmp_str00084, 208, 0);
   } 
   tmp_str00085 = "GOLD RUSH PRO MT4";
   tmp_str00086 = "i[GoldRushNews] INFO_LOGO";
   ObjectCreate(0, tmp_str00086, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00086, 102, 195);
   ObjectSetInteger(0, tmp_str00086, 103, 24);
   ObjectSetInteger(0, tmp_str00086, 101, 1);
   ObjectSetString(0, tmp_str00086, 999, tmp_str00085);
   ObjectSetString(0, tmp_str00086, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00086, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str00086, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str00086, 208, 0);
   ObjectSetInteger(0, tmp_str00086, 9, 0);
   tmp_str00087 = "________________________________________________";
   tmp_str00088 = "i[GoldRushNews] INFO_Line1";
   ObjectCreate(0, tmp_str00088, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00088, 102, 265);
   ObjectSetInteger(0, tmp_str00088, 103, 27);
   ObjectSetInteger(0, tmp_str00088, 101, 1);
   ObjectSetString(0, tmp_str00088, 999, tmp_str00087);
   ObjectSetString(0, tmp_str00088, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00088, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str00088, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str00088, 208, 0);
   ObjectSetInteger(0, tmp_str00088, 9, 0);
   tmp_str00089 = "Status Information";
   tmp_str0008A = "i[GoldRushNews] INFO_txt1";
   ObjectCreate(0, tmp_str0008A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0008A, 102, 265);
   ObjectSetInteger(0, tmp_str0008A, 103, 45);
   ObjectSetInteger(0, tmp_str0008A, 101, 1);
   ObjectSetString(0, tmp_str0008A, 999, tmp_str00089);
   ObjectSetString(0, tmp_str0008A, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0008A, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str0008A, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str0008A, 208, 0);
   ObjectSetInteger(0, tmp_str0008A, 9, 0);
   tmp_str0008B = "________________________________________________";
   tmp_str0008C = "i[GoldRushNews] INFO_Line2";
   ObjectCreate(0, tmp_str0008C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0008C, 102, 265);
   ObjectSetInteger(0, tmp_str0008C, 103, 47);
   ObjectSetInteger(0, tmp_str0008C, 101, 1);
   ObjectSetString(0, tmp_str0008C, 999, tmp_str0008B);
   ObjectSetString(0, tmp_str0008C, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0008C, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str0008C, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str0008C, 208, 0);
   ObjectSetInteger(0, tmp_str0008C, 9, 0);
   tmp_str0008D = "Trend Orders:";
   tmp_str0008E = "i[GoldRushNews] INFO_txt2";
   ObjectCreate(0, tmp_str0008E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0008E, 102, 265);
   ObjectSetInteger(0, tmp_str0008E, 103, 65);
   ObjectSetInteger(0, tmp_str0008E, 101, 1);
   ObjectSetString(0, tmp_str0008E, 999, tmp_str0008D);
   ObjectSetString(0, tmp_str0008E, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0008E, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str0008E, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str0008E, 208, 0);
   ObjectSetInteger(0, tmp_str0008E, 9, 0);
   tmp_str0008F = "All Orders:";
   tmp_str00090 = "i[GoldRushNews] INFO_txt3";
   ObjectCreate(0, tmp_str00090, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00090, 102, 265);
   ObjectSetInteger(0, tmp_str00090, 103, 80);
   ObjectSetInteger(0, tmp_str00090, 101, 1);
   ObjectSetString(0, tmp_str00090, 999, tmp_str0008F);
   ObjectSetString(0, tmp_str00090, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00090, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str00090, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str00090, 208, 0);
   ObjectSetInteger(0, tmp_str00090, 9, 0);
   tmp_str00091 = "________________________________________________";
   tmp_str00092 = "i[GoldRushNews] INFO_Line3";
   ObjectCreate(0, tmp_str00092, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00092, 102, 265);
   ObjectSetInteger(0, tmp_str00092, 103, 82);
   ObjectSetInteger(0, tmp_str00092, 101, 1);
   ObjectSetString(0, tmp_str00092, 999, tmp_str00091);
   ObjectSetString(0, tmp_str00092, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00092, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str00092, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str00092, 208, 0);
   ObjectSetInteger(0, tmp_str00092, 9, 0);
   tmp_str00093 = "Account Information";
   tmp_str00094 = "i[GoldRushNews] INFO_txt4";
   ObjectCreate(0, tmp_str00094, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00094, 102, 265);
   ObjectSetInteger(0, tmp_str00094, 103, 100);
   ObjectSetInteger(0, tmp_str00094, 101, 1);
   ObjectSetString(0, tmp_str00094, 999, tmp_str00093);
   ObjectSetString(0, tmp_str00094, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00094, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str00094, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str00094, 208, 0);
   ObjectSetInteger(0, tmp_str00094, 9, 0);
   tmp_str00095 = "________________________________________________";
   tmp_str00096 = "i[GoldRushNews] INFO_Line4";
   ObjectCreate(0, tmp_str00096, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00096, 102, 265);
   ObjectSetInteger(0, tmp_str00096, 103, 102);
   ObjectSetInteger(0, tmp_str00096, 101, 1);
   ObjectSetString(0, tmp_str00096, 999, tmp_str00095);
   ObjectSetString(0, tmp_str00096, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00096, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str00096, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str00096, 208, 0);
   ObjectSetInteger(0, tmp_str00096, 9, 0);
   tmp_str00097 = "Minimum Stop:";
   tmp_str00098 = "i[GoldRushNews] INFO_txt5";
   ObjectCreate(0, tmp_str00098, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str00098, 102, 265);
   ObjectSetInteger(0, tmp_str00098, 103, 120);
   ObjectSetInteger(0, tmp_str00098, 101, 1);
   ObjectSetString(0, tmp_str00098, 999, tmp_str00097);
   ObjectSetString(0, tmp_str00098, 1001, "Arial");
   ObjectSetInteger(0, tmp_str00098, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str00098, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str00098, 208, 0);
   ObjectSetInteger(0, tmp_str00098, 9, 0);
   tmp_str00099 = "Current Profit %:";
   tmp_str0009A = "i[GoldRushNews] INFO_txt6";
   ObjectCreate(0, tmp_str0009A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0009A, 102, 265);
   ObjectSetInteger(0, tmp_str0009A, 103, 135);
   ObjectSetInteger(0, tmp_str0009A, 101, 1);
   ObjectSetString(0, tmp_str0009A, 999, tmp_str00099);
   ObjectSetString(0, tmp_str0009A, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0009A, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str0009A, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str0009A, 208, 0);
   ObjectSetInteger(0, tmp_str0009A, 9, 0);
   tmp_str0009B = "Maximal Drawdown %:";
   tmp_str0009C = "i[GoldRushNews] INFO_txt7";
   ObjectCreate(0, tmp_str0009C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0009C, 102, 265);
   ObjectSetInteger(0, tmp_str0009C, 103, 150);
   ObjectSetInteger(0, tmp_str0009C, 101, 1);
   ObjectSetString(0, tmp_str0009C, 999, tmp_str0009B);
   ObjectSetString(0, tmp_str0009C, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0009C, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str0009C, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str0009C, 208, 0);
   ObjectSetInteger(0, tmp_str0009C, 9, 0);
   tmp_str0009D = "Balanse:";
   tmp_str0009E = "i[GoldRushNews] INFO_txt8";
   ObjectCreate(0, tmp_str0009E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0009E, 102, 265);
   ObjectSetInteger(0, tmp_str0009E, 103, 165);
   ObjectSetInteger(0, tmp_str0009E, 101, 1);
   ObjectSetString(0, tmp_str0009E, 999, tmp_str0009D);
   ObjectSetString(0, tmp_str0009E, 1001, "Arial");
   ObjectSetInteger(0, tmp_str0009E, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str0009E, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str0009E, 208, 0);
   ObjectSetInteger(0, tmp_str0009E, 9, 0);
   tmp_str0009F = "Equity:";
   tmp_str000A0 = "i[GoldRushNews] INFO_txt9";
   ObjectCreate(0, tmp_str000A0, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000A0, 102, 265);
   ObjectSetInteger(0, tmp_str000A0, 103, 180);
   ObjectSetInteger(0, tmp_str000A0, 101, 1);
   ObjectSetString(0, tmp_str000A0, 999, tmp_str0009F);
   ObjectSetString(0, tmp_str000A0, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000A0, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000A0, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000A0, 208, 0);
   ObjectSetInteger(0, tmp_str000A0, 9, 0);
   tmp_str000A1 = "________________________________________________";
   tmp_str000A2 = "i[GoldRushNews] INFO_Line5";
   ObjectCreate(0, tmp_str000A2, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000A2, 102, 265);
   ObjectSetInteger(0, tmp_str000A2, 103, 182);
   ObjectSetInteger(0, tmp_str000A2, 101, 1);
   ObjectSetString(0, tmp_str000A2, 999, tmp_str000A1);
   ObjectSetString(0, tmp_str000A2, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000A2, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000A2, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000A2, 208, 0);
   ObjectSetInteger(0, tmp_str000A2, 9, 0);
   tmp_str000A3 = "Profit On Account";
   tmp_str000A4 = "i[GoldRushNews] INFO_txt10";
   ObjectCreate(0, tmp_str000A4, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000A4, 102, 265);
   ObjectSetInteger(0, tmp_str000A4, 103, 200);
   ObjectSetInteger(0, tmp_str000A4, 101, 1);
   ObjectSetString(0, tmp_str000A4, 999, tmp_str000A3);
   ObjectSetString(0, tmp_str000A4, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000A4, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000A4, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000A4, 208, 0);
   ObjectSetInteger(0, tmp_str000A4, 9, 0);
   tmp_str000A5 = "________________________________________________";
   tmp_str000A6 = "i[GoldRushNews] INFO_Line6";
   ObjectCreate(0, tmp_str000A6, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000A6, 102, 265);
   ObjectSetInteger(0, tmp_str000A6, 103, 202);
   ObjectSetInteger(0, tmp_str000A6, 101, 1);
   ObjectSetString(0, tmp_str000A6, 999, tmp_str000A5);
   ObjectSetString(0, tmp_str000A6, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000A6, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000A6, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000A6, 208, 0);
   ObjectSetInteger(0, tmp_str000A6, 9, 0);
   tmp_str000A7 = "Profit On Pair:";
   tmp_str000A8 = "i[GoldRushNews] INFO_txt11";
   ObjectCreate(0, tmp_str000A8, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000A8, 102, 265);
   ObjectSetInteger(0, tmp_str000A8, 103, 220);
   ObjectSetInteger(0, tmp_str000A8, 101, 1);
   ObjectSetString(0, tmp_str000A8, 999, tmp_str000A7);
   ObjectSetString(0, tmp_str000A8, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000A8, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000A8, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000A8, 208, 0);
   ObjectSetInteger(0, tmp_str000A8, 9, 0);
   tmp_str000A9 = "Total Profit:";
   tmp_str000AA = "i[GoldRushNews] INFO_txt12";
   ObjectCreate(0, tmp_str000AA, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000AA, 102, 265);
   ObjectSetInteger(0, tmp_str000AA, 103, 235);
   ObjectSetInteger(0, tmp_str000AA, 101, 1);
   ObjectSetString(0, tmp_str000AA, 999, tmp_str000A9);
   ObjectSetString(0, tmp_str000AA, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000AA, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000AA, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000AA, 208, 0);
   ObjectSetInteger(0, tmp_str000AA, 9, 0);
   tmp_str000AB = "Profit For Today:";
   tmp_str000AC = "i[GoldRushNews] INFO_txt13";
   ObjectCreate(0, tmp_str000AC, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000AC, 102, 265);
   ObjectSetInteger(0, tmp_str000AC, 103, 250);
   ObjectSetInteger(0, tmp_str000AC, 101, 1);
   ObjectSetString(0, tmp_str000AC, 999, tmp_str000AB);
   ObjectSetString(0, tmp_str000AC, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000AC, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000AC, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000AC, 208, 0);
   ObjectSetInteger(0, tmp_str000AC, 9, 0);
   tmp_str000AD = "Profit For Yesterday:";
   tmp_str000AE = "i[GoldRushNews] INFO_txt14";
   ObjectCreate(0, tmp_str000AE, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000AE, 102, 265);
   ObjectSetInteger(0, tmp_str000AE, 103, 265);
   ObjectSetInteger(0, tmp_str000AE, 101, 1);
   ObjectSetString(0, tmp_str000AE, 999, tmp_str000AD);
   ObjectSetString(0, tmp_str000AE, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000AE, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000AE, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000AE, 208, 0);
   ObjectSetInteger(0, tmp_str000AE, 9, 0);
   tmp_str000AF = "Profit For Week:";
   tmp_str000B0 = "i[GoldRushNews] INFO_txt15";
   ObjectCreate(0, tmp_str000B0, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000B0, 102, 265);
   ObjectSetInteger(0, tmp_str000B0, 103, 280);
   ObjectSetInteger(0, tmp_str000B0, 101, 1);
   ObjectSetString(0, tmp_str000B0, 999, tmp_str000AF);
   ObjectSetString(0, tmp_str000B0, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000B0, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000B0, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000B0, 208, 0);
   ObjectSetInteger(0, tmp_str000B0, 9, 0);
   tmp_str000B1 = "Profit For Month:";
   tmp_str000B2 = "i[GoldRushNews] INFO_txt16";
   ObjectCreate(0, tmp_str000B2, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000B2, 102, 265);
   ObjectSetInteger(0, tmp_str000B2, 103, 295);
   ObjectSetInteger(0, tmp_str000B2, 101, 1);
   ObjectSetString(0, tmp_str000B2, 999, tmp_str000B1);
   ObjectSetString(0, tmp_str000B2, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000B2, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000B2, 6, Ii_047F0);
   ObjectSetInteger(0, tmp_str000B2, 208, 0);
   ObjectSetInteger(0, tmp_str000B2, 9, 0);
   Gi_00158 = 0;
   tmp_str000B3 = "Unidentified";
   Gi_00159 = OrdersTotal() - 1;
   Gi_0015A = Gi_00159;
   if (Gi_00159 >= 0) { 
   do { 
   if (OrderSelect(Gi_0015A, 0, 0)) { 
   Gi_00158 = OrderType();
   } 
   if (Gi_00158 == 0) { 
   tmp_str000B3 = "Buy";
   } 
   else { 
   tmp_str000B3 = "Sell";
   } 
   Gi_0015A = Gi_0015A - 1;
   } while (Gi_0015A >= 0); 
   } 
   tmp_str000B4 = tmp_str000B3;
   tmp_str000B5 = "i[GoldRushNews] INFO_txt17";
   ObjectCreate(0, tmp_str000B5, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000B5, 102, 125);
   ObjectSetInteger(0, tmp_str000B5, 103, 65);
   ObjectSetInteger(0, tmp_str000B5, 101, 1);
   ObjectSetString(0, tmp_str000B5, 999, tmp_str000B4);
   ObjectSetString(0, tmp_str000B5, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000B5, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000B5, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000B5, 208, 0);
   ObjectSetInteger(0, tmp_str000B5, 9, 0);
   tmp_str000B6 = (string)Ii_0478C;
   tmp_str000B7 = "i[GoldRushNews] INFO_txt18";
   ObjectCreate(0, tmp_str000B7, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000B7, 102, 125);
   ObjectSetInteger(0, tmp_str000B7, 103, 80);
   ObjectSetInteger(0, tmp_str000B7, 101, 1);
   ObjectSetString(0, tmp_str000B7, 999, tmp_str000B6);
   ObjectSetString(0, tmp_str000B7, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000B7, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000B7, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000B7, 208, 0);
   ObjectSetInteger(0, tmp_str000B7, 9, 0);
   tmp_str000B8 = DoubleToString(MarketInfo(_Symbol, MODE_STOPLEVEL), 0);
   tmp_str000B9 = "i[GoldRushNews] INFO_txt19";
   ObjectCreate(0, tmp_str000B9, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000B9, 102, 125);
   ObjectSetInteger(0, tmp_str000B9, 103, 120);
   ObjectSetInteger(0, tmp_str000B9, 101, 1);
   ObjectSetString(0, tmp_str000B9, 999, tmp_str000B8);
   ObjectSetString(0, tmp_str000B9, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000B9, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000B9, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000B9, 208, 0);
   ObjectSetInteger(0, tmp_str000B9, 9, 0);
   tmp_str000BA = DoubleToString(Id_047E8, 2);
   tmp_str000BA = tmp_str000BA + " %";
   tmp_str000BB = "i[GoldRushNews] INFO_txt20";
   ObjectCreate(0, tmp_str000BB, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000BB, 102, 125);
   ObjectSetInteger(0, tmp_str000BB, 103, 135);
   ObjectSetInteger(0, tmp_str000BB, 101, 1);
   ObjectSetString(0, tmp_str000BB, 999, tmp_str000BA);
   ObjectSetString(0, tmp_str000BB, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000BB, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000BB, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000BB, 208, 0);
   ObjectSetInteger(0, tmp_str000BB, 9, 0);
   tmp_str000BC = DoubleToString(-Id_04748, 2);
   tmp_str000BC = tmp_str000BC + " $ ";
   tmp_str000BC = tmp_str000BC + "(";
   tmp_str000BC = tmp_str000BC + DoubleToString(Id_04740, 2);
   tmp_str000BC = tmp_str000BC + " %)";
   tmp_str000BD = "i[GoldRushNews] INFO_txt21";
   ObjectCreate(0, tmp_str000BD, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000BD, 102, 125);
   ObjectSetInteger(0, tmp_str000BD, 103, 150);
   ObjectSetInteger(0, tmp_str000BD, 101, 1);
   ObjectSetString(0, tmp_str000BD, 999, tmp_str000BC);
   ObjectSetString(0, tmp_str000BD, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000BD, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000BD, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000BD, 208, 0);
   ObjectSetInteger(0, tmp_str000BD, 9, 0);
   tmp_str000BE = DoubleToString(AccountBalance(), 2);
   tmp_str000BE = tmp_str000BE + " $";
   tmp_str000BF = "i[GoldRushNews] INFO_txt22";
   ObjectCreate(0, tmp_str000BF, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000BF, 102, 125);
   ObjectSetInteger(0, tmp_str000BF, 103, 165);
   ObjectSetInteger(0, tmp_str000BF, 101, 1);
   ObjectSetString(0, tmp_str000BF, 999, tmp_str000BE);
   ObjectSetString(0, tmp_str000BF, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000BF, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000BF, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000BF, 208, 0);
   ObjectSetInteger(0, tmp_str000BF, 9, 0);
   tmp_str000C0 = DoubleToString(AccountEquity(), 2);
   tmp_str000C0 = tmp_str000C0 + " $";
   tmp_str000C1 = "i[GoldRushNews] INFO_txt23";
   ObjectCreate(0, tmp_str000C1, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000C1, 102, 125);
   ObjectSetInteger(0, tmp_str000C1, 103, 180);
   ObjectSetInteger(0, tmp_str000C1, 101, 1);
   ObjectSetString(0, tmp_str000C1, 999, tmp_str000C0);
   ObjectSetString(0, tmp_str000C1, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000C1, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000C1, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000C1, 208, 0);
   ObjectSetInteger(0, tmp_str000C1, 9, 0);
   Gi_00159 = -1;
   Gd_0015B = 0;
   Gi_0015C = OrdersTotal() - 1;
   Gi_0015D = Gi_0015C;
   if (Gi_0015C >= 0) { 
   do { 
   if (OrderSelect(Gi_0015D, 0, 0) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic) { 
   if (OrderType() == Gi_00159 || Gi_00159 == -1) { 
   
   Gd_0015C = OrderProfit();
   Gd_0015C = (Gd_0015C + OrderSwap());
   Gd_0015B = ((Gd_0015C + OrderCommission()) + Gd_0015B);
   }} 
   Gi_0015D = Gi_0015D - 1;
   } while (Gi_0015D >= 0); 
   } 
   tmp_str000C2 = DoubleToString(Gd_0015B, 2);
   tmp_str000C2 = tmp_str000C2 + " $";
   tmp_str000C3 = "i[GoldRushNews] INFO_txt24";
   ObjectCreate(0, tmp_str000C3, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000C3, 102, 125);
   ObjectSetInteger(0, tmp_str000C3, 103, 220);
   ObjectSetInteger(0, tmp_str000C3, 101, 1);
   ObjectSetString(0, tmp_str000C3, 999, tmp_str000C2);
   ObjectSetString(0, tmp_str000C3, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000C3, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000C3, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000C3, 208, 0);
   ObjectSetInteger(0, tmp_str000C3, 9, 0);
   Gi_0015C = -1;
   Gd_0015E = 0;
   Gi_0015F = OrdersTotal() - 1;
   Gi_00160 = Gi_0015F;
   if (Gi_0015F >= 0) { 
   do { 
   if (OrderSelect(Gi_00160, 0, 0) && OrderMagicNumber() == Magic) { 
   if (OrderType() == Gi_0015C || Gi_0015C == -1) { 
   
   Gd_0015F = OrderProfit();
   Gd_0015F = (Gd_0015F + OrderSwap());
   Gd_0015E = ((Gd_0015F + OrderCommission()) + Gd_0015E);
   }} 
   Gi_00160 = Gi_00160 - 1;
   } while (Gi_00160 >= 0); 
   } 
   tmp_str000C4 = DoubleToString(Gd_0015E, 2);
   tmp_str000C4 = tmp_str000C4 + " $";
   tmp_str000C5 = "i[GoldRushNews] INFO_txt25";
   ObjectCreate(0, tmp_str000C5, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000C5, 102, 125);
   ObjectSetInteger(0, tmp_str000C5, 103, 235);
   ObjectSetInteger(0, tmp_str000C5, 101, 1);
   ObjectSetString(0, tmp_str000C5, 999, tmp_str000C4);
   ObjectSetString(0, tmp_str000C5, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000C5, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000C5, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000C5, 208, 0);
   ObjectSetInteger(0, tmp_str000C5, 9, 0);
   Gi_0015F = -1;
   Gd_00161 = 0;
   Gi_00162 = HistoryTotal() - 1;
   Gi_00163 = Gi_00162;
   if (Gi_00162 >= 0) { 
   do { 
   if (OrderSelect(Gi_00163, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_00162 = OrderCloseTime();
   if (Gl_00162 >= iTime(_Symbol, 1440, 0)) { 
   if (OrderType() == Gi_0015F || Gi_0015F == -1) { 
   
   Gd_00162 = OrderProfit();
   Gd_00162 = (Gd_00162 + OrderSwap());
   Gd_00161 = ((Gd_00162 + OrderCommission()) + Gd_00161);
   }}} 
   Gi_00163 = Gi_00163 - 1;
   } while (Gi_00163 >= 0); 
   } 
   tmp_str000C6 = DoubleToString(Gd_00161, 2);
   tmp_str000C6 = tmp_str000C6 + " $";
   tmp_str000C7 = "i[GoldRushNews] INFO_txt26";
   ObjectCreate(0, tmp_str000C7, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000C7, 102, 125);
   ObjectSetInteger(0, tmp_str000C7, 103, 250);
   ObjectSetInteger(0, tmp_str000C7, 101, 1);
   ObjectSetString(0, tmp_str000C7, 999, tmp_str000C6);
   ObjectSetString(0, tmp_str000C7, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000C7, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000C7, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000C7, 208, 0);
   ObjectSetInteger(0, tmp_str000C7, 9, 0);
   Gi_00162 = -1;
   Gd_00164 = 0;
   Gi_00165 = HistoryTotal() - 1;
   Gi_00166 = Gi_00165;
   if (Gi_00165 >= 0) { 
   do { 
   if (OrderSelect(Gi_00166, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_00165 = OrderCloseTime();
   if (Gl_00165 >= iTime(_Symbol, 1440, 1)) { 
   Gl_00165 = OrderCloseTime();
   if (Gl_00165 < iTime(_Symbol, 1440, 0)) { 
   if (OrderType() == Gi_00162 || Gi_00162 == -1) { 
   
   Gd_00165 = OrderProfit();
   Gd_00165 = (Gd_00165 + OrderSwap());
   Gd_00164 = ((Gd_00165 + OrderCommission()) + Gd_00164);
   }}}} 
   Gi_00166 = Gi_00166 - 1;
   } while (Gi_00166 >= 0); 
   } 
   tmp_str000C8 = DoubleToString(Gd_00164, 2);
   tmp_str000C8 = tmp_str000C8 + " $";
   tmp_str000C9 = "i[GoldRushNews] INFO_txt27";
   ObjectCreate(0, tmp_str000C9, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000C9, 102, 125);
   ObjectSetInteger(0, tmp_str000C9, 103, 265);
   ObjectSetInteger(0, tmp_str000C9, 101, 1);
   ObjectSetString(0, tmp_str000C9, 999, tmp_str000C8);
   ObjectSetString(0, tmp_str000C9, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000C9, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000C9, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000C9, 208, 0);
   ObjectSetInteger(0, tmp_str000C9, 9, 0);
   Gi_00165 = -1;
   Gd_00167 = 0;
   Gi_00168 = HistoryTotal() - 1;
   Gi_00169 = Gi_00168;
   if (Gi_00168 >= 0) { 
   do { 
   if (OrderSelect(Gi_00169, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_00168 = OrderCloseTime();
   if (Gl_00168 >= iTime(_Symbol, 10080, 0)) { 
   if (OrderType() == Gi_00165 || Gi_00165 == -1) { 
   
   Gd_00168 = OrderProfit();
   Gd_00168 = (Gd_00168 + OrderSwap());
   Gd_00167 = ((Gd_00168 + OrderCommission()) + Gd_00167);
   }}} 
   Gi_00169 = Gi_00169 - 1;
   } while (Gi_00169 >= 0); 
   } 
   tmp_str000CA = DoubleToString(Gd_00167, 2);
   tmp_str000CA = tmp_str000CA + " $";
   tmp_str000CB = "i[GoldRushNews] INFO_txt28";
   ObjectCreate(0, tmp_str000CB, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000CB, 102, 125);
   ObjectSetInteger(0, tmp_str000CB, 103, 280);
   ObjectSetInteger(0, tmp_str000CB, 101, 1);
   ObjectSetString(0, tmp_str000CB, 999, tmp_str000CA);
   ObjectSetString(0, tmp_str000CB, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000CB, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000CB, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000CB, 208, 0);
   ObjectSetInteger(0, tmp_str000CB, 9, 0);
   Gi_00168 = -1;
   Gd_0016A = 0;
   Gi_0016B = HistoryTotal() - 1;
   Gi_0016C = Gi_0016B;
   if (Gi_0016B >= 0) { 
   do { 
   if (OrderSelect(Gi_0016C, 0, 1) && OrderMagicNumber() == Magic) { 
   Gl_0016B = OrderCloseTime();
   if (Gl_0016B >= iTime(_Symbol, 43200, 0)) { 
   if (OrderType() == Gi_00168 || Gi_00168 == -1) { 
   
   Gd_0016B = OrderProfit();
   Gd_0016B = (Gd_0016B + OrderSwap());
   Gd_0016A = ((Gd_0016B + OrderCommission()) + Gd_0016A);
   }}} 
   Gi_0016C = Gi_0016C - 1;
   } while (Gi_0016C >= 0); 
   } 
   tmp_str000CC = DoubleToString(Gd_0016A, 2);
   tmp_str000CC = tmp_str000CC + " $";
   tmp_str000CD = "i[GoldRushNews] INFO_txt29";
   ObjectCreate(0, tmp_str000CD, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000CD, 102, 125);
   ObjectSetInteger(0, tmp_str000CD, 103, 295);
   ObjectSetInteger(0, tmp_str000CD, 101, 1);
   ObjectSetString(0, tmp_str000CD, 999, tmp_str000CC);
   ObjectSetString(0, tmp_str000CD, 1001, "Arial");
   ObjectSetInteger(0, tmp_str000CD, 100, Ii_047FC);
   ObjectSetInteger(0, tmp_str000CD, 6, Ii_047F4);
   ObjectSetInteger(0, tmp_str000CD, 208, 0);
   ObjectSetInteger(0, tmp_str000CD, 9, 0);
   
}

void OnDeinit(const int reason)
{
   string tmp_str00000;
   string tmp_str00001;

   Comment("");
   Ii_005E8 = ObjectsTotal(-1);
   if (Ii_005E8 >= 0) { 
   do { 
   tmp_str00000 = ObjectName(Ii_005E8);
   if (StringSubstr(tmp_str00000, 0, 15) == "n[GoldRushNews]") { 
   ObjectDelete(tmp_str00000);
   } 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Ii_005E8 = ObjectsTotal(-1);
   if (Ii_005E8 < 0) return; 
   do { 
   tmp_str00001 = ObjectName(Ii_005E8);
   if (StringSubstr(tmp_str00001, 0, 15) == "i[GoldRushNews]") { 
   ObjectDelete(tmp_str00001);
   } 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   
}

int func_1016()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string tmp_str00006;
   int Li_FFFFC;
   int Li_FFFF8;

   if (IsTesting() || IsDllsAllowed() == false) { 
   
   Ib_00021 = false;
   } 
   else { 
   Ib_00021 = true;
   } 
   if (!Ib_00021 || _Period < Ii_00024 || _Period > Ii_00028) {
   
   if (Ib_00070 != true) { 
   Ii_005E8 = ObjectsTotal(-1);
   if (Ii_005E8 >= 0) { 
   do { 
   tmp_str00000 = ObjectName(Ii_005E8);
   Global_ReturnedString = StringSubstr(tmp_str00000, 0, 15);
   if (Global_ReturnedString == "n[GoldRushNews]") { 
   ObjectDelete(tmp_str00000);
   } 
   Ii_005E8 = Ii_005E8 - 1;
   } while (Ii_005E8 >= 0); 
   } 
   Ib_00070 = true;
   } 
   Li_FFFFC = 0;
   return Li_FFFFC;
   }
   tmp_str00001 = Is_00640;
   Ii_003EC = 0;
   Gl_00000 = TimeCurrent();
   if (GlobalVariableCheck("Update.GoldRushNews") == 0) { 
   Gb_00001 = true;
   } 
   else { 
   Gd_00002 = (Gl_00000 - GlobalVariableGet("Update.GoldRushNews"));
   Gi_00003 = SetUpdateTime * 60;
   if ((Gd_00002 > Gi_00003)) { 
   Gb_00001 = true;
   } 
   else { 
   Global_ReturnedString = func_1019();
   Is_00618 = Global_ReturnedString;
   Ii_003EC = FileOpen(Is_00618, 5);
   if (Ii_003EC >= 0) { 
   Is_02760 = FileReadString(Ii_003EC, (int)FileSize(Ii_003EC));
   FileClose(Ii_003EC);
   Gb_00001 = false;
   } 
   else { 
   Gb_00001 = true;
   }}} 
   if (Gb_00001) { 
   tmp_str00002 = tmp_str00001;
   func_1020(tmp_str00002);
   } 
   if (Ii_00634 == _Period) { 
   returned_double = MathMod(Seconds(), Ii_00638);
   if ((returned_double == 0)) { 
   Li_FFFFC = 1;
   return Li_FFFFC;
   } 
   Ii_00634 = _Period;
   } 
   ArrayInitialize(Id_000CC, 0);
   Ii_003EC = FileOpen(Is_00618, 5);
   if (Ii_003EC >= 0) { 
   Li_FFFF8 = (int)FileSize(Ii_003EC);
   Is_02760 = FileReadString(Ii_003EC, Li_FFFF8);
   FileClose(Ii_003EC);
   } 
   Ii_0007C = 0;
   Ib_00072 = false;
   Ib_00073 = false;
   Ib_00074 = false;
   Ib_00075 = false;
   Ib_00076 = false;
   Ib_00077 = false;
   Ib_00078 = false;
   Ib_00079 = false;
   Ii_005E8 = 0;
   do { 
   Is_027D0[Ii_005E8] = "";
   Is_02CB4[Ii_005E8] = "";
   Is_03198[Ii_005E8] = "";
   Is_0367C[Ii_005E8] = "";
   Is_03B60[Ii_005E8] = "";
   Ii_0043C[Ii_005E8] = 0;
   Ii_005E8 = Ii_005E8 + 1;
   } while (Ii_005E8 <= 9); 
   Ii_005CC = 0;
   Ii_005D4 = -1;
   Ii_00400 = 10080;
   Ii_003F0 = 0;
   do { 
   Ii_003F0 = StringFind(Is_02760, "<event>", Ii_003F0);
   if (Ii_003F0 == -1) break; 
   Ii_003F0 = Ii_003F0 + 7;
   Ii_005D0 = StringFind(Is_02760, "</event>", Ii_003F0);
   if (Ii_005D0 == -1) break; 
   Is_00650 = StringSubstr(Is_02760, Ii_003F0, (Ii_005D0 - Ii_003F0));
   Ii_003F0 = Ii_005D0;
   Ii_003F8 = 0;
   Ib_00071 = false;
   Ii_005E8 = 0;
   do { 
   Is_00690[Ii_005CC, Ii_005E8] = "";
   Ii_005D0 = StringFind(Is_00650, Is_04528[Ii_005E8], Ii_003F8);
   if (Ii_005D0 != -1) { 
   Gi_0000E = StringLen(Is_04528[Ii_005E8]);
   Ii_003F8 = Ii_005D0 + Gi_0000E;
   Ii_003F4 = StringFind(Is_00650, Is_045B0[Ii_005E8], Ii_003F8);
   if (Ii_003F4 > Ii_003F8 && Ii_003F4 != -1) { 
   Is_00690[Ii_005CC, Ii_005E8] = StringSubstr(Is_00650, Ii_003F8, (Ii_003F4 - Ii_003F8));
   }} 
   Ii_005E8 = Ii_005E8 + 1;
   } while (Ii_005E8 < 7); 
   tmp_str00003 = Is_00690[Ii_005CC, 1];
   tmp_str00004 = Is_046C8;
   if (StringFind(tmp_str00004, tmp_str00003, 0) >= 0) { 
   Gb_00011 = true;
   } 
   else { 
   Gb_00011 = false;
   } 
   if (Gb_00011 != true) { 
   Ib_00071 = true;
   } 
   else { 
   if (Ib_0004C == false && Is_00690[Ii_005CC, 4] == "Medium") { 
   Ib_00071 = true;
   } 
   else { 
   if (Ib_00044 == false && Is_00690[Ii_005CC, 4] == "Low") { 
   Ib_00071 = true;
   } 
   else { 
   if (Ib_0005C == false && StringSubstr(Is_00690[Ii_005CC, 0], 0, 4) == "Bank") { 
   Ib_00071 = true;
   } 
   else { 
   if (StringSubstr(Is_00690[Ii_005CC, 0], 0, 8) == "Daylight") { 
   Ib_00071 = true;
   } 
   else { 
   if ((Is_00690[Ii_005CC, 3] == "All Day" && Is_00690[Ii_005CC, 3] == "")
   || (Is_00690[Ii_005CC, 3] == "Tentative" && Is_00690[Ii_005CC, 3] == "")
   || Is_00690[Ii_005CC, 3] == "") {
   
   Ib_00071 = true;
   }}}}}} 
   if (Ib_00071) continue; 
   tmp_str00005 = Is_00690[Ii_005CC, 3];
   tmp_str00006 = Is_00690[Ii_005CC, 2];
   Il_00088 = func_1026(tmp_str00006, tmp_str00005);
   Gl_0001D = Il_00088 - TimeCurrent();
   Gl_0001D = Gl_0001D / 60;
   Gi_0001E = SetTimeOffset * 60;
   Gl_0001E = Gi_0001E;
   Gl_0001E = Gl_0001D + Gl_0001E;
   Ii_003FC = (int)Gl_0001E;
   Gi_00020 = StringLen(Is_00690[Ii_005CC, 0]);
   if (StringFind(Is_00690[Ii_005CC, 0], "Bank Holiday", (Gi_00020 - 12)) != -1 && Ii_003FC <= 0) { 
   Ii_003FC = Ii_003FC - 2880;
   } 
   if (Ii_003FC < 0 || fabs(Ii_00400) > Ii_003FC) {
   
   Ii_00404 = Ii_005CC;
   Ii_00400 = Ii_003FC;
   }
   if (Ii_0006C != 0 && Ii_003FC == Ii_0006C) { 
   Alert(Ii_0006C, " Minutes Until News For ", Is_00690[Ii_005CC, 1], ": ", Is_00690[Ii_005CC, 0]);
   } 
   Id_000CC[Ii_005CC] = Ii_003FC;
   Ii_005CC = Ii_005CC + 1;
   } while (true); 
   
   Ii_005E8 = 0;
   if (Ii_005CC > 0) { 
   do { 
   Gi_00023 = Ii_00404 - 3;
   if (Ii_005E8 == Gi_00023) { 
   Is_027D0[6] = Is_00690[Ii_005E8, 0];
   Is_02CB4[6] = Is_00690[Ii_005E8, 1];
   Is_03198[6] = Is_00690[Ii_005E8, 4];
   Is_0367C[6] = Is_00690[Ii_005E8, 2];
   Is_03B60[6] = Is_00690[Ii_005E8, 3];
   Gi_0002E = (int)Id_000CC[Ii_005E8];
   Ii_0043C[6] = Gi_0002E;
   } 
   Gi_0002E = Ii_00404 - 2;
   if (Ii_005E8 == Gi_0002E) { 
   Is_027D0[5] = Is_00690[Ii_005E8, 0];
   Is_02CB4[5] = Is_00690[Ii_005E8, 1];
   Is_03198[5] = Is_00690[Ii_005E8, 4];
   Is_0367C[5] = Is_00690[Ii_005E8, 2];
   Is_03B60[5] = Is_00690[Ii_005E8, 3];
   Gi_0003A = (int)Id_000CC[Ii_005E8];
   Ii_0043C[5] = Gi_0003A;
   } 
   Gi_0003A = Ii_00404 - 1;
   if (Ii_005E8 == Gi_0003A) { 
   Is_027D0[4] = Is_00690[Ii_005E8, 0];
   Is_02CB4[4] = Is_00690[Ii_005E8, 1];
   Is_03198[4] = Is_00690[Ii_005E8, 4];
   Is_0367C[4] = Is_00690[Ii_005E8, 2];
   Is_03B60[4] = Is_00690[Ii_005E8, 3];
   Gi_00046 = (int)Id_000CC[Ii_005E8];
   Ii_0043C[4] = Gi_00046;
   } 
   if (Ii_005E8 == Ii_00404) { 
   Is_027D0[0] = Is_00690[Ii_005E8, 0];
   Is_02CB4[0] = Is_00690[Ii_005E8, 1];
   Is_03198[0] = Is_00690[Ii_005E8, 4];
   Is_0367C[0] = Is_00690[Ii_005E8, 2];
   Is_03B60[0] = Is_00690[Ii_005E8, 3];
   Gi_00052 = (int)Id_000CC[Ii_005E8];
   Ii_0043C[0] = Gi_00052;
   if (Ii_0043C[0] <= 0){
   if (Ii_0043C[0] == Ii_0043C[4]
   && ((Is_03198[0] == "Medium" && Is_03198[4] == "High")
   || (Is_03198[0] == "Low" && Is_03198[4] == "High")
   || (Is_03198[0] == "Low" && Is_03198[4] == "Medium"))) {
   
   Is_027D0[0] = Is_027D0[4];
   Is_02CB4[0] = Is_02CB4[4];
   Is_03198[0] = Is_03198[4];
   Is_0367C[0] = Is_0367C[4];
   Is_03B60[0] = Is_03B60[4];
   Ii_0043C[0] = Ii_0043C[4];
   }
   else{
   if (Ii_0043C[0] == Ii_0043C[5]
   && ((Is_03198[0] == "Medium" && Is_03198[5] == "High")
   || (Is_03198[0] == "Low" && Is_03198[5] == "High")
   || (Is_03198[0] == "Low" && Is_03198[5] == "Medium"))) {
   
   Is_027D0[0] = Is_027D0[5];
   Is_02CB4[0] = Is_02CB4[5];
   Is_03198[0] = Is_03198[5];
   Is_0367C[0] = Is_0367C[5];
   Is_03B60[0] = Is_03B60[5];
   Ii_0043C[0] = Ii_0043C[5];
   }
   else{
   if (Ii_0043C[0] == Ii_0043C[6]) { 
   if ((Is_03198[0] == "Medium" && Is_03198[6] == "High")
   || (Is_03198[0] == "Low" && Is_03198[6] == "High")
   || (Is_03198[0] == "Low" && Is_03198[6] == "Medium")) {
   
   Is_027D0[0] = Is_027D0[6];
   Is_02CB4[0] = Is_02CB4[6];
   Is_03198[0] = Is_03198[6];
   Is_0367C[0] = Is_0367C[6];
   Is_03B60[0] = Is_03B60[6];
   Ii_0043C[0] = Ii_0043C[6];
   }}}}}} 
   Gi_00090 = Ii_00404 + 1;
   if (Ii_005E8 >= Gi_00090) { 
   Is_027D0[6] = Is_00690[Ii_005E8, 0];
   Is_02CB4[6] = Is_00690[Ii_005E8, 1];
   Is_03198[6] = Is_00690[Ii_005E8, 4];
   Is_0367C[6] = Is_00690[Ii_005E8, 2];
   Is_03B60[6] = Is_00690[Ii_005E8, 3];
   Gi_0009B = (int)Id_000CC[Ii_005E8];
   Ii_0043C[6] = Gi_0009B;
   if (!Ib_00072) {
   if (Ii_0043C[0] == Ii_0043C[6]
   && ((Is_03198[0] == "Medium" && Is_03198[6] == "High")
   || (Is_03198[0] == "Low" && Is_03198[6] == "High")
   || (Is_03198[0] == "Low" && Is_03198[6] == "Medium"))) {
   
   Is_027D0[0] = Is_027D0[6];
   Is_02CB4[0] = Is_02CB4[6];
   Is_03198[0] = Is_03198[6];
   Is_0367C[0] = Is_0367C[6];
   Is_03B60[0] = Is_03B60[6];
   Ii_0043C[0] = Ii_0043C[6];
   }
   else{
   if (Ii_0043C[0] < Ii_0043C[6]
   || (Ii_0043C[0] == Ii_0043C[6] && Is_03198[6] == "High")) {
   
   Is_027D0[1] = Is_027D0[6];
   Is_02CB4[1] = Is_02CB4[6];
   Is_03198[1] = Is_03198[6];
   Is_0367C[1] = Is_0367C[6];
   Is_03B60[1] = Is_03B60[6];
   Ii_0043C[1] = Ii_0043C[6];
   Ib_00072 = true;
   }}}
   else{
   if (Ib_00072 && Ib_00073 == false) {
   if (Ii_0043C[1] == Ii_0043C[6]
   && ((Is_03198[1] == "Medium" && Is_03198[6] == "High")
   || (Is_03198[1] == "Low" && Is_03198[6] == "High")
   || (Is_03198[1] == "Low" && Is_03198[6] == "Medium"))) {
   
   Is_027D0[1] = Is_027D0[6];
   Is_02CB4[1] = Is_02CB4[6];
   Is_03198[1] = Is_03198[6];
   Is_0367C[1] = Is_0367C[6];
   Is_03B60[1] = Is_03B60[6];
   Ii_0043C[1] = Ii_0043C[6];
   }
   else{
   if (Ii_0043C[1] < Ii_0043C[6]
   || (Ii_0043C[1] == Ii_0043C[6] && Is_03198[6] == "High")) {
   
   Is_027D0[2] = Is_027D0[6];
   Is_02CB4[2] = Is_02CB4[6];
   Is_03198[2] = Is_03198[6];
   Is_0367C[2] = Is_0367C[6];
   Is_03B60[2] = Is_03B60[6];
   Ii_0043C[2] = Ii_0043C[6];
   Ib_00073 = true;
   
   }}}
   if (Ib_00072 && Ib_00073 && Ib_00074 == false) {
   if (Ii_0043C[2] == Ii_0043C[6]
   && ((Is_03198[2] == "Medium" && Is_03198[6] == "High")
   || (Is_03198[2] == "Low" && Is_03198[6] == "High")
   || (Is_03198[2] == "Low" && Is_03198[6] == "Medium"))) {
   
   Is_027D0[2] = Is_027D0[6];
   Is_02CB4[2] = Is_02CB4[6];
   Is_03198[2] = Is_03198[6];
   Is_0367C[2] = Is_0367C[6];
   Is_03B60[2] = Is_03B60[6];
   Ii_0043C[2] = Ii_0043C[6];
   }
   else{
   if (Ii_0043C[2] < Ii_0043C[6]
   || (Ii_0043C[2] == Ii_0043C[6] && Is_03198[6] == "High")) {
   
   Is_027D0[3] = Is_027D0[6];
   Is_02CB4[3] = Is_02CB4[6];
   Is_03198[3] = Is_03198[6];
   Is_0367C[3] = Is_0367C[6];
   Is_03B60[3] = Is_03B60[6];
   Ii_0043C[3] = Ii_0043C[6];
   Ib_00074 = true;
   }}}
   else{
   if (Ib_00072 && Ib_00073 && Ib_00074 && Ib_00075 == false) { 
   if (Ii_0043C[3] == Ii_0043C[6]
   && ((Is_03198[3] == "Medium" && Is_03198[6] == "High")
   || (Is_03198[3] == "Low" && Is_03198[6] == "High")
   || (Is_03198[3] == "Low" && Is_03198[6] == "Medium"))) {
   
   Is_027D0[3] = Is_027D0[6];
   Is_02CB4[3] = Is_02CB4[6];
   Is_03198[3] = Is_03198[6];
   Is_0367C[3] = Is_0367C[6];
   Is_03B60[3] = Is_03B60[6];
   Ii_0043C[3] = Ii_0043C[6];
   }
   else{
   Ib_00075 = true;
   }} 
   if (Ib_00072 && Ib_00073 && Ib_00074) { 
   if (Ib_00075) break; 
   }}}} 
   Ii_005E8 = Ii_005E8 + 1;
   } while (Ii_005E8 < Ii_005CC); 
   } 
   if ((Is_027D0[0] == Is_027D0[1] && Ii_0043C[0] + 1440 > Ii_0043C[1])
   || Ii_0043C[0] > Ii_0043C[1]) {
   
   Ib_00077 = true;
   }
   if ((Is_027D0[0] == Is_027D0[2] && Ii_0043C[0] + 1440 > Ii_0043C[2])
   || (Is_027D0[1] == Is_027D0[2] && Ii_0043C[1] + 1440 > Ii_0043C[2])
   || (Ii_0043C[0] > Ii_0043C[2] || Ii_0043C[1] > Ii_0043C[2])) {
   
   Ib_00078 = true;
   }
   if ((Is_027D0[0] == Is_027D0[3] && Ii_0043C[0] + 1440 > Ii_0043C[3])
   || (Is_027D0[2] == Is_027D0[3] && Ii_0043C[2] + 1440 > Ii_0043C[3])
   || (Ii_0043C[0] > Ii_0043C[3] || Ii_0043C[2] > Ii_0043C[3])) {
   
   Ib_00079 = true;
   }
   if (Ii_0043C[0] < -720 && Ii_0043C[1] == 0) { 
   Ib_00076 = true;
   } 
   if (Ib_00076) { 
   Ib_00077 = true;
   Ib_00078 = true;
   Ib_00079 = true;
   } 
   else { 
   if (Ib_00077) { 
   Ib_00078 = true;
   Ib_00079 = true;
   } 
   else { 
   if (Ib_00078) { 
   Ib_00079 = true;
   }}} 
   if (Is_02CB4[0] == "") { 
   Ib_00076 = true;
   } 
   if (Is_02CB4[1] == "") { 
   Ib_00077 = true;
   } 
   if (Is_02CB4[2] == "") { 
   Ib_00078 = true;
   } 
   if (Is_02CB4[3] == "") { 
   Ib_00079 = true;
   } 
   if (Ii_0007C == 1) { 
   Is_027D0[3] = Is_027D0[2];
   Is_02CB4[3] = Is_02CB4[2];
   Is_03198[3] = Is_03198[2];
   Is_0367C[3] = Is_0367C[2];
   Is_03B60[3] = Is_03B60[2];
   Ii_0043C[3] = Ii_0043C[2];
   Ib_00079 = Ib_00078;
   Is_027D0[2] = Is_027D0[1];
   Is_02CB4[2] = Is_02CB4[1];
   Is_03198[2] = Is_03198[1];
   Is_0367C[2] = Is_0367C[1];
   Is_03B60[2] = Is_03B60[1];
   Ii_0043C[2] = Ii_0043C[1];
   Ib_00078 = Ib_00077;
   Is_027D0[1] = Is_027D0[0];
   Is_02CB4[1] = Is_02CB4[0];
   Is_03198[1] = Is_03198[0];
   Is_0367C[1] = Is_0367C[0];
   Is_03B60[1] = Is_03B60[0];
   Ii_0043C[1] = Ii_0043C[0];
   Ib_00077 = Ib_00076;
   Is_027D0[0] = Is_027D0[7];
   Is_02CB4[0] = Is_02CB4[7];
   Is_03198[0] = Is_03198[7];
   Is_0367C[0] = Is_0367C[7];
   Is_03B60[0] = Is_03B60[7];
   Ii_0043C[0] = Ii_0043C[7];
   Ib_00076 = false;
   } 
   func_1023();
   Li_FFFFC = 0;
   
   return Li_FFFFC;
}

string func_1019()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   int Li_FFFFC;
   string Ls_FFFF0;

   Li_FFFFC = 0;
   returned_i = TimeDayOfWeek(TimeLocal());
   if (returned_i <= 6) { 
   if (returned_i == 0) Li_FFFFC = 0;
   if (returned_i == 1) Li_FFFFC = 1;
   if (returned_i == 2) Li_FFFFC = 2;
   if (returned_i == 3) Li_FFFFC = 3;
   if (returned_i == 4) Li_FFFFC = 4;
   if (returned_i == 5) Li_FFFFC = 5;
   if (returned_i == 6) Li_FFFFC = 6;
   } 
   Gl_00000 = TimeLocal();
   Gi_00001 = Li_FFFFC * 86400;
   Gl_00001 = Gi_00001;
   Il_00090 = Gl_00000 - Gl_00001;
   Gi_00001 = 2;
   tmp_str00000 = "0";
   tmp_str00001 = DoubleToString(TimeDay(Il_00090), 0);
   Gi_00002 = StringLen(tmp_str00001);
   if (Gi_00002 < 2) { 
   do { 
   tmp_str00001 = StringConcatenate(tmp_str00000, tmp_str00001);
   Gi_00002 = StringLen(tmp_str00001);
   } while (Gi_00002 < Gi_00001); 
   } 
   tmp_str00002 = tmp_str00001;
   Gi_00002 = 2;
   tmp_str00003 = "0";
   tmp_str00004 = DoubleToString(TimeMonth(Il_00090), 0);
   Gi_00003 = StringLen(tmp_str00004);
   if (Gi_00003 < 2) { 
   do { 
   tmp_str00004 = StringConcatenate(tmp_str00003, tmp_str00004);
   Gi_00003 = StringLen(tmp_str00004);
   } while (Gi_00003 < Gi_00002); 
   } 
   tmp_str00005 = tmp_str00004;
   Ls_FFFF0 = StringConcatenate(TimeYear(Il_00090), "-", tmp_str00005, "-", tmp_str00002, "-GoldRushNews", ".xml");
   return Ls_FFFF0;
}

void func_1020(string Fa_s_00)
{
   string tmp_str00000;
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   int Li_FFF54;
   int Li_FFF50;
   int Li_FFF4C;

   Ls_FFFF0 = NULL;
   Ls_FFFD0 = "";
   Ls_FFFC0 = "User-Agent: Mozilla/4.0\n";
   char Lc_FFF8C[];
   char Lc_FFF58[];
   Li_FFF54 = 5000;
   Li_FFF50 = WebRequest("GET", Fa_s_00, Ls_FFFF0, Ls_FFFC0, 5000, Lc_FFF8C, 0, Lc_FFF58, Ls_FFFE0);
   if (Li_FFF50 == -1) { 
   Global_ReturnedString = ErrorDescription(GetLastError());
   tmp_str00000 = Global_ReturnedString;
   Print("Error In WebRequest. Error Code  = ", tmp_str00000);
   MessageBox("You Must Add The Address 'https://nfs.faireconomy.media/' In The List Of Allowed URLs Tab 'Expert Advisors' ", " Error ", 64);
   } 
   else { 
   Global_ReturnedString = func_1019();
   Is_00618 = Global_ReturnedString;
   Ii_003EC = FileOpen(Is_00618, 7);
   if (Ii_003EC >= 0) { 
   FileClose(Ii_003EC);
   FileDelete(Is_00618, 0);
   } 
   Ii_003EC = FileOpen(Is_00618, 6);
   FileWriteArray(Ii_003EC, Lc_FFF58, 0, ArraySize(Lc_FFF58));
   FileClose(Ii_003EC);
   Li_FFF4C = FileOpen(Is_00618, 5);
   Ls_FFFD0 = FileReadString(Li_FFF4C, ArraySize(Lc_FFF58));
   FileClose(Li_FFF4C);
   Ii_003F4 = StringFind(Ls_FFFD0, "</weeklyevents>", 0);
   if (Ii_003F4 == -1) { 
   Alert(_Symbol, " ", _Period, ", ", comment, " Error: File Download Incomplete!");
   } 
   else { 
   GlobalVariableSet("Update.GoldRushNews", TimeCurrent());
   }} 
   ArrayFree(Lc_FFF58);
   ArrayFree(Lc_FFF8C);
}

void func_1023()
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

   Is_02770 = "Until ";
   Ii_005D8 = Ii_0043C[3] + 1;
   if (Ii_0043C[3] <= 0) { 
   Ii_005D8 = Ii_005D8 - 1;
   Is_02770 = "Since ";
   Ii_005D8 = -Ii_005D8;
   } 
   if (Ii_005D8 < 60) { 
   tmp_str00000 = (string)Ii_005D8;
   tmp_str00000 = tmp_str00000 + " Mins ";
   Is_02780 = tmp_str00000;
   } 
   else { 
   Gi_00002 = Ii_005D8 / 60;
   Gd_00002 = round(Gi_00002);
   Ii_005E0 = (int)Gd_00002;
   Ii_005E4 = Ii_005D8 % 60;
   if (Ii_005E0 < 24) { 
   tmp_str00000 = (string)Ii_005E0;
   tmp_str00000 = tmp_str00000 + " Hrs ";
   tmp_str00001 = (string)Ii_005E4;
   tmp_str00000 = tmp_str00000 + tmp_str00001;
   tmp_str00000 = tmp_str00000 + " Mins ";
   Is_02780 = tmp_str00000;
   } 
   else { 
   Gi_00002 = Ii_005E0 / 24;
   Gd_00002 = round(Gi_00002);
   Ii_005DC = (int)Gd_00002;
   Ii_005E0 = Ii_005E0 % 24;
   tmp_str00001 = (string)Ii_005DC;
   tmp_str00001 = tmp_str00001 + " Days ";
   tmp_str00002 = (string)Ii_005E0;
   tmp_str00001 = tmp_str00001 + tmp_str00002;
   tmp_str00001 = tmp_str00001 + " Hrs ";
   tmp_str00002 = (string)Ii_005E4;
   tmp_str00001 = tmp_str00001 + tmp_str00002;
   tmp_str00001 = tmp_str00001 + " Mins ";
   Is_02780 = tmp_str00001;
   }} 
   tmp_str00002 = Is_02780 + Is_02770;
   tmp_str00002 = tmp_str00002 + Is_02CB4[3];
   Ii_00604 = StringFind(tmp_str00002, "Since  Mins", 0);
   if (Is_02770 == "Since ") { 
   Ii_00084 = 3289650;
   } 
   else { 
   tmp_str00003 = Is_03198[3];
   if (tmp_str00003 == "High") { 
   Gi_00004 = Ii_00050;
   } 
   else { 
   if (tmp_str00003 == "Medium") { 
   Gi_00004 = Ii_00048;
   } 
   else { 
   if (tmp_str00003 == "Low") { 
   Gi_00004 = Ii_00040;
   } 
   else { 
   if (tmp_str00003 == "Holiday") { 
   Gi_00004 = Ii_00058;
   } 
   else { 
   Gi_00004 = Ii_00060;
   }}}} 
   Ii_00084 = Gi_00004;
   } 
   ObjectDelete(Is_046B8);
   tmp_str00004 = Is_0367C[3];
   tmp_str00005 = Is_03B60[3];
   ObjectCreate(0, Is_046B8, OBJ_VLINE, 0, func_1024(tmp_str00005, tmp_str00004), 0, 0, 0, 0, 0);
   ObjectSet(Is_046B8, OBJPROP_COLOR, Ii_00084);
   ObjectDelete(Is_04668);
   ObjectCreate(0, Is_04668, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   if (Ii_00604 != -1 || Ib_00079) { 
   
   ObjectSetText(Is_04668, "(4)  No Recent News", Ii_00608, Is_04608, Ii_00060);
   Is_04044[4] = "(4)  No Recent News";
   } 
   else { 
   Gi_00008 = Ii_00084;
   tmp_str00006 = Is_02CB4[3] + " ";
   tmp_str00007 = Is_0367C[3];
   tmp_str00008 = Is_03B60[3];
   tmp_str00006 = tmp_str00006 + TimeToString(func_1024(tmp_str00008, tmp_str00007), 3);
   tmp_str00006 = tmp_str00006 + " ";
   tmp_str00006 = tmp_str00006 + Is_027D0[3];
   ObjectSetText(Is_046B8, tmp_str00006, Ii_00608, Is_04608, Gi_00008);
   tmp_str00009 = Is_02780 + Is_02770;
   tmp_str00009 = tmp_str00009 + Is_02CB4[3];
   tmp_str00009 = tmp_str00009 + ": ";
   tmp_str00009 = tmp_str00009 + Is_027D0[3];
   ObjectSetText(Is_04668, tmp_str00009, Ii_00608, Is_04608, Ii_00084);
   tmp_str0000A = Is_02780 + Is_02770;
   tmp_str0000A = tmp_str0000A + Is_02CB4[3];
   tmp_str0000A = tmp_str0000A + ": ";
   tmp_str0000A = tmp_str0000A + Is_027D0[3];
   Is_04044[4] = tmp_str0000A;
   } 
   Is_02770 = "Until ";
   Ii_005D8 = Ii_0043C[2] + 1;
   if (Ii_0043C[2] <= 0) { 
   Ii_005D8 = Ii_005D8 - 1;
   Is_02770 = "Since ";
   Ii_005D8 = -Ii_005D8;
   } 
   if (Ii_005D8 < 60) { 
   tmp_str0000A = (string)Ii_005D8;
   tmp_str0000A = tmp_str0000A + " Mins ";
   Is_02780 = tmp_str0000A;
   } 
   else { 
   Gi_00014 = Ii_005D8 / 60;
   Gd_00014 = round(Gi_00014);
   Ii_005E0 = (int)Gd_00014;
   Ii_005E4 = Ii_005D8 % 60;
   if (Ii_005E0 < 24) { 
   tmp_str0000A = (string)Ii_005E0;
   tmp_str0000A = tmp_str0000A + " Hrs ";
   tmp_str0000B = (string)Ii_005E4;
   tmp_str0000A = tmp_str0000A + tmp_str0000B;
   tmp_str0000A = tmp_str0000A + " Mins ";
   Is_02780 = tmp_str0000A;
   } 
   else { 
   Gi_00014 = Ii_005E0 / 24;
   Gd_00014 = round(Gi_00014);
   Ii_005DC = (int)Gd_00014;
   Ii_005E0 = Ii_005E0 % 24;
   tmp_str0000B = (string)Ii_005DC;
   tmp_str0000B = tmp_str0000B + " Days ";
   tmp_str0000C = (string)Ii_005E0;
   tmp_str0000B = tmp_str0000B + tmp_str0000C;
   tmp_str0000B = tmp_str0000B + " Hrs ";
   tmp_str0000C = (string)Ii_005E4;
   tmp_str0000B = tmp_str0000B + tmp_str0000C;
   tmp_str0000B = tmp_str0000B + " Mins ";
   Is_02780 = tmp_str0000B;
   }} 
   tmp_str0000C = Is_02780 + Is_02770;
   tmp_str0000C = tmp_str0000C + Is_02CB4[2];
   Ii_00604 = StringFind(tmp_str0000C, "Since  Mins", 0);
   if (Is_02770 == "Since ") { 
   Ii_00084 = 3289650;
   } 
   else { 
   tmp_str0000D = Is_03198[2];
   if (tmp_str0000D == "High") { 
   Gi_00016 = Ii_00050;
   } 
   else { 
   if (tmp_str0000D == "Medium") { 
   Gi_00016 = Ii_00048;
   } 
   else { 
   if (tmp_str0000D == "Low") { 
   Gi_00016 = Ii_00040;
   } 
   else { 
   if (tmp_str0000D == "Holiday") { 
   Gi_00016 = Ii_00058;
   } 
   else { 
   Gi_00016 = Ii_00060;
   }}}} 
   Ii_00084 = Gi_00016;
   } 
   ObjectDelete(Is_046A8);
   tmp_str0000E = Is_0367C[2];
   tmp_str0000F = Is_03B60[2];
   ObjectCreate(0, Is_046A8, OBJ_VLINE, 0, func_1024(tmp_str0000F, tmp_str0000E), 0, 0, 0, 0, 0);
   ObjectSet(Is_046A8, OBJPROP_COLOR, Ii_00084);
   ObjectDelete(Is_04658);
   ObjectCreate(0, Is_04658, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   if (Ii_00604 != -1 || Ib_00078) { 
   
   ObjectSetText(Is_04658, "(3)  No Recent News", Ii_00608, Is_04608, Ii_00060);
   Is_04044[3] = "(3)  No Recent News";
   } 
   else { 
   Gi_0001A = Ii_00084;
   tmp_str00010 = Is_02CB4[2] + " ";
   tmp_str00011 = Is_0367C[2];
   tmp_str00012 = Is_03B60[2];
   tmp_str00010 = tmp_str00010 + TimeToString(func_1024(tmp_str00012, tmp_str00011), 3);
   tmp_str00010 = tmp_str00010 + " ";
   tmp_str00010 = tmp_str00010 + Is_027D0[2];
   ObjectSetText(Is_046A8, tmp_str00010, Ii_00608, Is_04608, Gi_0001A);
   tmp_str00013 = Is_02780 + Is_02770;
   tmp_str00013 = tmp_str00013 + Is_02CB4[2];
   tmp_str00013 = tmp_str00013 + ": ";
   tmp_str00013 = tmp_str00013 + Is_027D0[2];
   ObjectSetText(Is_04658, tmp_str00013, Ii_00608, Is_04608, Ii_00084);
   tmp_str00014 = Is_02780 + Is_02770;
   tmp_str00014 = tmp_str00014 + Is_02CB4[2];
   tmp_str00014 = tmp_str00014 + ": ";
   tmp_str00014 = tmp_str00014 + Is_027D0[2];
   Is_04044[3] = tmp_str00014;
   } 
   Is_02770 = "Until ";
   Ii_005D8 = Ii_0043C[1] + 1;
   if (Ii_0043C[1] <= 0) { 
   Ii_005D8 = Ii_005D8 - 1;
   Is_02770 = "Since ";
   Ii_005D8 = -Ii_005D8;
   } 
   if (Ii_005D8 < 60) { 
   tmp_str00014 = (string)Ii_005D8;
   tmp_str00014 = tmp_str00014 + " Mins ";
   Is_02780 = tmp_str00014;
   } 
   else { 
   Gi_00026 = Ii_005D8 / 60;
   Gd_00026 = round(Gi_00026);
   Ii_005E0 = (int)(int)Gd_00026;
   Ii_005E4 = Ii_005D8 % 60;
   if (Ii_005E0 < 24) { 
   tmp_str00014 = (string)Ii_005E0;
   tmp_str00014 = tmp_str00014 + " Hrs ";
   tmp_str00015 = (string)Ii_005E4;
   tmp_str00014 = tmp_str00014 + tmp_str00015;
   tmp_str00014 = tmp_str00014 + " Mins ";
   Is_02780 = tmp_str00014;
   } 
   else { 
   Gi_00026 = Ii_005E0 / 24;
   Gd_00026 = round(Gi_00026);
   Ii_005DC = (int)Gd_00026;
   Ii_005E0 = Ii_005E0 % 24;
   tmp_str00015 = (string)Ii_005DC;
   tmp_str00015 = tmp_str00015 + " Days ";
   tmp_str00016 = (string)Ii_005E0;
   tmp_str00015 = tmp_str00015 + tmp_str00016;
   tmp_str00015 = tmp_str00015 + " Hrs ";
   tmp_str00016 = (string)Ii_005E4;
   tmp_str00015 = tmp_str00015 + tmp_str00016;
   tmp_str00015 = tmp_str00015 + " Mins ";
   Is_02780 = tmp_str00015;
   }} 
   tmp_str00016 = Is_02780 + Is_02770;
   tmp_str00016 = tmp_str00016 + Is_02CB4[1];
   Ii_00604 = StringFind(tmp_str00016, "Since  Mins", 0);
   if (Is_02770 == "Since ") { 
   Ii_00084 = 3289650;
   } 
   else { 
   tmp_str00017 = Is_03198[1];
   if (tmp_str00017 == "High") { 
   Gi_00028 = Ii_00050;
   } 
   else { 
   if (tmp_str00017 == "Medium") { 
   Gi_00028 = Ii_00048;
   } 
   else { 
   if (tmp_str00017 == "Low") { 
   Gi_00028 = Ii_00040;
   } 
   else { 
   if (tmp_str00017 == "Holiday") { 
   Gi_00028 = Ii_00058;
   } 
   else { 
   Gi_00028 = Ii_00060;
   }}}} 
   Ii_00084 = Gi_00028;
   } 
   ObjectDelete(Is_04698);
   tmp_str00018 = Is_0367C[1];
   tmp_str00019 = Is_03B60[1];
   ObjectCreate(0, Is_04698, OBJ_VLINE, 0, func_1024(tmp_str00019, tmp_str00018), 0, 0, 0, 0, 0);
   ObjectSet(Is_04698, OBJPROP_COLOR, Ii_00084);
   ObjectDelete(Is_04648);
   ObjectCreate(0, Is_04648, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   if (Ii_00604 != -1 || Ib_00077) { 
   
   ObjectSetText(Is_04648, "(2)  No Recent News", Ii_00608, Is_04608, Ii_00060);
   Is_04044[2] = "(2)  No Recent News";
   } 
   else { 
   Gi_0002C = Ii_00084;
   tmp_str0001A = Is_02CB4[1] + " ";
   tmp_str0001B = Is_0367C[1];
   tmp_str0001C = Is_03B60[1];
   tmp_str0001A = tmp_str0001A + TimeToString(func_1024(tmp_str0001C, tmp_str0001B), 3);
   tmp_str0001A = tmp_str0001A + " ";
   tmp_str0001A = tmp_str0001A + Is_027D0[1];
   ObjectSetText(Is_04698, tmp_str0001A, Ii_00608, Is_04608, Gi_0002C);
   tmp_str0001D = Is_02780 + Is_02770;
   tmp_str0001D = tmp_str0001D + Is_02CB4[1];
   tmp_str0001D = tmp_str0001D + ": ";
   tmp_str0001D = tmp_str0001D + Is_027D0[1];
   ObjectSetText(Is_04648, tmp_str0001D, Ii_00608, Is_04608, Ii_00084);
   tmp_str0001E = Is_02780 + Is_02770;
   tmp_str0001E = tmp_str0001E + Is_02CB4[1];
   tmp_str0001E = tmp_str0001E + ": ";
   tmp_str0001E = tmp_str0001E + Is_027D0[1];
   Is_04044[2] = tmp_str0001E;
   } 
   Is_02770 = "Until ";
   Ii_005D8 = Ii_0043C[0] + 1;
   if (Ii_0043C[0] <= 0) { 
   Ii_005D8 = Ii_005D8 - 1;
   Is_02770 = "Since ";
   Ii_005D8 = -Ii_005D8;
   } 
   if (Ii_005D8 < 60) { 
   tmp_str0001E = (string)Ii_005D8;
   tmp_str0001E = tmp_str0001E + " Mins ";
   Is_02780 = tmp_str0001E;
   } 
   else { 
   Gi_00038 = Ii_005D8 / 60;
   Gd_00038 = round(Gi_00038);
   Ii_005E0 = (int)Gd_00038;
   Ii_005E4 = Ii_005D8 % 60;
   if (Ii_005E0 < 24) { 
   tmp_str0001E = (string)Ii_005E0;
   tmp_str0001E = tmp_str0001E + " Hrs ";
   tmp_str0001F = (string)Ii_005E4;
   tmp_str0001E = tmp_str0001E + tmp_str0001F;
   tmp_str0001E = tmp_str0001E + " Mins ";
   Is_02780 = tmp_str0001E;
   } 
   else { 
   Gi_00038 = Ii_005E0 / 24;
   Gd_00038 = round(Gi_00038);
   Ii_005DC = (int)Gd_00038;
   Ii_005E0 = Ii_005E0 % 24;
   tmp_str0001F = (string)Ii_005DC;
   tmp_str0001F = tmp_str0001F + " Days ";
   tmp_str00020 = (string)Ii_005E0;
   tmp_str0001F = tmp_str0001F + tmp_str00020;
   tmp_str0001F = tmp_str0001F + " Hrs ";
   tmp_str00020 = (string)Ii_005E4;
   tmp_str0001F = tmp_str0001F + tmp_str00020;
   tmp_str0001F = tmp_str0001F + " Mins ";
   Is_02780 = tmp_str0001F;
   }} 
   tmp_str00020 = Is_02780 + Is_02770;
   tmp_str00020 = tmp_str00020 + Is_02CB4[0];
   Ii_00604 = StringFind(tmp_str00020, "Since  Mins", 0);
   if (Is_02770 == "Since ") { 
   Ii_00084 = 3289650;
   } 
   else { 
   tmp_str00021 = Is_03198[0];
   if (tmp_str00021 == "High") { 
   Gi_0003A = Ii_00050;
   } 
   else { 
   if (tmp_str00021 == "Medium") { 
   Gi_0003A = Ii_00048;
   } 
   else { 
   if (tmp_str00021 == "Low") { 
   Gi_0003A = Ii_00040;
   } 
   else { 
   if (tmp_str00021 == "Holiday") { 
   Gi_0003A = Ii_00058;
   } 
   else { 
   Gi_0003A = Ii_00060;
   }}}} 
   Ii_00084 = Gi_0003A;
   } 
   ObjectDelete(Is_04688);
   tmp_str00022 = Is_0367C[0];
   tmp_str00023 = Is_03B60[0];
   ObjectCreate(0, Is_04688, OBJ_VLINE, 0, func_1024(tmp_str00023, tmp_str00022), 0, 0, 0, 0, 0);
   ObjectSet(Is_04688, OBJPROP_COLOR, Ii_00084);
   ObjectDelete(Is_04638);
   ObjectCreate(0, Is_04638, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   if (Ii_00604 != -1 || Ib_00076) { 
   
   ObjectSetText(Is_04638, "(1)  No Recent News", Ii_00608, Is_04608, Ii_00060);
   Is_04044[1] = "(1)  No Recent News";
   } 
   else { 
   Gi_0003E = Ii_00084;
   tmp_str00024 = Is_02CB4[0] + " ";
   tmp_str00025 = Is_0367C[0];
   tmp_str00026 = Is_03B60[0];
   tmp_str00024 = tmp_str00024 + TimeToString(func_1024(tmp_str00026, tmp_str00025), 3);
   tmp_str00024 = tmp_str00024 + " ";
   tmp_str00024 = tmp_str00024 + Is_027D0[0];
   ObjectSetText(Is_04688, tmp_str00024, Ii_00608, Is_04608, Gi_0003E);
   tmp_str00027 = Is_02780 + Is_02770;
   tmp_str00027 = tmp_str00027 + Is_02CB4[0];
   tmp_str00027 = tmp_str00027 + ": ";
   tmp_str00027 = tmp_str00027 + Is_027D0[0];
   ObjectSetText(Is_04638, tmp_str00027, Ii_00608, Is_04608, Ii_00084);
   tmp_str00028 = Is_02780 + Is_02770;
   tmp_str00028 = tmp_str00028 + Is_02CB4[0];
   tmp_str00028 = tmp_str00028 + ": ";
   tmp_str00028 = tmp_str00028 + Is_027D0[0];
   Is_04044[1] = tmp_str00028;
   } 
   Ii_005F8 = 0;
   Ii_005FC = 0;
   Ii_005E8 = 1;
   do { 
   if (Ii_005E8 == 0) { 
   Ii_005F8 = StringLen(Is_04044[Ii_005E8]);
   } 
   else { 
   Gi_0004A = StringLen(Is_04044[Ii_005E8]);
   if (Gi_0004A > Ii_005F8) { 
   Ii_005F8 = StringLen(Is_04044[Ii_005E8]);
   }} 
   Ii_005E8 = Ii_005E8 + 1;
   } while (Ii_005E8 <= 4); 
   if (Ii_005F8 < 120) { 
   Ii_005FC = 121;
   } 
   else { 
   Gi_0004B = Ii_005F8 - 120;
   Ii_005FC = Gi_0004B + 121;
   } 
   if (AllowPanelAtChartRight != true) { 
   Ii_005F0 = 18;
   Ii_005F4 = 64;
   Is_02790 = "gg";
   Ii_005FC = Ii_005FC + 46;
   } 
   else { 
   Ii_005F0 = 6;
   Ii_005F4 = 54;
   Is_02790 = "ggg";
   } 
   if (Ib_00064) { 
   ObjectCreate(0, Is_04618, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(Is_04618, Is_02790, Ii_005F4, "Webdings", 4294967295);
   ObjectSet(Is_04618, OBJPROP_CORNER, Ii_00080);
   ObjectSet(Is_04618, OBJPROP_XDISTANCE, 1);
   ObjectSet(Is_04618, OBJPROP_YDISTANCE, 1);
   ObjectSet(Is_04618, OBJPROP_COLOR, Ii_00068);
   ObjectSet(Is_04618, OBJPROP_BACK, 0);
   ObjectCreate(0, Is_04628, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(Is_04628, Is_02790, Ii_005F4, "Webdings", 4294967295);
   ObjectSet(Is_04628, OBJPROP_CORNER, Ii_00080);
   ObjectSet(Is_04628, OBJPROP_XDISTANCE, Ii_005FC);
   ObjectSet(Is_04628, OBJPROP_YDISTANCE, 1);
   ObjectSet(Is_04628, OBJPROP_COLOR, Ii_00068);
   ObjectSet(Is_04628, OBJPROP_BACK, 0);
   } 
   ObjectSet(Is_04668, OBJPROP_CORNER, Ii_00080);
   ObjectSet(Is_04668, OBJPROP_XDISTANCE, Ii_00614);
   ObjectSet(Is_04668, OBJPROP_YDISTANCE, Ii_005F0);
   Gi_0004B = Ii_005F0 + Ii_00608;
   Ii_005F0 = Gi_0004B + Ii_00610;
   ObjectSet(Is_04658, OBJPROP_CORNER, Ii_00080);
   ObjectSet(Is_04658, OBJPROP_XDISTANCE, Ii_00614);
   ObjectSet(Is_04658, OBJPROP_YDISTANCE, Ii_005F0);
   Gi_0004B = Ii_005F0 + Ii_00608;
   Ii_005F0 = Gi_0004B + Ii_00610;
   ObjectSet(Is_04648, OBJPROP_CORNER, Ii_00080);
   ObjectSet(Is_04648, OBJPROP_XDISTANCE, Ii_00614);
   ObjectSet(Is_04648, OBJPROP_YDISTANCE, Ii_005F0);
   Gi_0004B = Ii_005F0 + Ii_00608;
   Ii_005F0 = Gi_0004B + Ii_00610;
   ObjectSet(Is_04638, OBJPROP_CORNER, Ii_00080);
   ObjectSet(Is_04638, OBJPROP_XDISTANCE, Ii_00614);
   ObjectSet(Is_04638, OBJPROP_YDISTANCE, Ii_005F0);
   Gi_0004B = Ii_005F0 + Ii_00608;
   Ii_005F0 = Gi_0004B + Ii_0060C;
   ObjectDelete(Is_04678);
   ObjectCreate(0, Is_04678, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(Is_04678, "GOLD RUSH PRO MT4 - NEWS: ", Ii_00608, "Verdana", Ii_0003C);
   ObjectSet(Is_04678, OBJPROP_CORNER, Ii_00080);
   ObjectSet(Is_04678, OBJPROP_XDISTANCE, Ii_00614);
   ObjectSet(Is_04678, OBJPROP_YDISTANCE, Ii_005F0);
   ObjectSet(Is_04688, OBJPROP_STYLE, 2);
   ObjectSetInteger(0, Is_04688, 8, 1);
   ObjectSetInteger(0, Is_04688, 9, 1);
   ObjectSet(Is_04698, OBJPROP_STYLE, 2);
   ObjectSetInteger(0, Is_04698, 8, 1);
   ObjectSetInteger(0, Is_04698, 9, 1);
   ObjectSet(Is_046A8, OBJPROP_STYLE, 2);
   ObjectSetInteger(0, Is_046A8, 8, 1);
   ObjectSetInteger(0, Is_046A8, 9, 1);
   ObjectSet(Is_046B8, OBJPROP_STYLE, 2);
   ObjectSetInteger(0, Is_046B8, 8, 1);
   ObjectSetInteger(0, Is_046B8, 9, 1);
}

long func_1024(string Fa_s_00, string Fa_s_01)
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
   string Ls_FFFE8;
   string Ls_FFFD8;
   string Ls_FFFC8;
   string Ls_FFFB8;
   long Ll_FFFF8;

   Ls_FFFD8 = (string)StringFind(Fa_s_00, "am", 0);
   if (Ls_FFFD8 > "0") { 
   tmp_str00000 = TimeToString(StringToTime(Fa_s_00), 2);
   if (StringSubstr(tmp_str00000, 0, 2) == "12") { 
   tmp_str00001 = TimeToString(StringToTime(Fa_s_00), 2);
   tmp_str00002 = StringSubstr(tmp_str00001, 0, 2);
   Gl_00000 = StringToInteger(tmp_str00002) - 12;
   Ls_FFFE8 = (string)Gl_00000;
   } 
   else { 
   tmp_str00003 = TimeToString(StringToTime(Fa_s_00), 2);
   tmp_str00004 = StringSubstr(tmp_str00003, 0, 2);
   Ls_FFFE8 = (string)StringToInteger(tmp_str00004);
   }} 
   Ls_FFFC8 = (string)StringFind(Fa_s_00, "pm", 0);
   if (Ls_FFFC8 > "0") { 
   tmp_str00005 = TimeToString(StringToTime(Fa_s_00), 2);
   if (StringSubstr(tmp_str00005, 0, 2) == "12") { 
   tmp_str00006 = TimeToString(StringToTime(Fa_s_00), 2);
   tmp_str00007 = StringSubstr(tmp_str00006, 0, 2);
   Ls_FFFE8 = (string)StringToInteger(tmp_str00007);
   } 
   else { 
   tmp_str00008 = TimeToString(StringToTime(Fa_s_00), 2);
   tmp_str00009 = StringSubstr(tmp_str00008, 0, 2);
   Gl_00000 = StringToInteger(tmp_str00009) + 12;
   Ls_FFFE8 = (string)Gl_00000;
   }} 
   tmp_str0000A = TimeToString(StringToTime(Fa_s_00), 2);
   tmp_str0000B = StringSubstr(tmp_str0000A, 3, 2);
   tmp_str0000C = StringSubstr(Fa_s_01, 3, 2);
   tmp_str0000D = StringSubstr(Fa_s_01, 0, 2);
   tmp_str0000E = StringSubstr(Fa_s_01, 6, 4);
   Ls_FFFB8 = StringConcatenate(tmp_str0000E, ".", tmp_str0000D, ".", tmp_str0000C, " ", Ls_FFFE8, ":", tmp_str0000B);
   Gl_00000 = StringToTime(Ls_FFFB8);
   Gi_00001 = SetTimeOffset * 3600;
   Gl_00001 = Gi_00001;
   Ll_FFFF8 = Gl_00000 + Gl_00001;
   return Ll_FFFF8;
}

long func_1026(string Fa_s_00, string Fa_s_01)
{
   string tmp_str00000;
   int Li_FFFF4;
   int Li_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   int Li_FFFBC;
   string Ls_FFFB0;
   string Ls_FFFA0;
   string Ls_FFF90;
   int Li_FFF8C;
   long Ll_FFF80;
   long Ll_FFFF8;

   Li_FFFF4 = StringFind(Fa_s_00, "-", 0);
   Li_FFFF0 = StringFind(Fa_s_00, "-", (Li_FFFF4 + 1));
   Ls_FFFE0 = StringSubstr(Fa_s_00, 0, 2);
   Ls_FFFD0 = StringSubstr(Fa_s_00, 3, 2);
   Ls_FFFC0 = StringSubstr(Fa_s_00, 6, 4);
   returned_i = StringFind(Fa_s_01, ":", 0);
   Li_FFFBC = returned_i;
   Ls_FFFB0 = StringSubstr(Fa_s_01, 0, Li_FFFBC);
   Ls_FFFA0 = StringSubstr(Fa_s_01, (Li_FFFBC + 1), 2);
   Gi_00000 = StringLen(Fa_s_01);
   Ls_FFF90 = StringSubstr(Fa_s_01, (Gi_00000 - 2), 0);
   returned_i = (int)StringToInteger(Ls_FFFB0);
   Li_FFF8C = returned_i;
   if (Ls_FFF90 == "pm" || Ls_FFF90 == "PM") {
   
   if (Li_FFF8C != 12) { 
   Li_FFF8C = Li_FFF8C + 12;
   }} 
   if (Ls_FFF90 == "am" || Ls_FFF90 == "AM") {
   
   if (Li_FFF8C == 12) { 
   Li_FFF8C = 0;
   }} 
   tmp_str00000 = Ls_FFFC0 + ".";
   tmp_str00000 = tmp_str00000 + Ls_FFFE0;
   tmp_str00000 = tmp_str00000 + ".";
   tmp_str00000 = tmp_str00000 + Ls_FFFD0;
   Gl_00000 = StringToTime(tmp_str00000);
   Gi_00001 = Li_FFF8C * 3600;
   Gl_00001 = Gi_00001;
   Gl_00001 = Gl_00000 + Gl_00001;
   Gl_00002 = StringToInteger(Ls_FFFA0) * 60;
   Ll_FFF80 = Gl_00001 + Gl_00002;
   Ll_FFFF8 = Ll_FFF80;
   return Ll_FFF80;
}

void func_1033()
{
   string tmp_str00000;
   string tmp_str00001;
   string tmp_str00002;
   string tmp_str00003;
   string tmp_str00004;
   string tmp_str00005;
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   string Ls_FFFB0;

   if (SetNews && IsTesting() == false) { 
   Ls_FFFF0 = "The Next News Time: ";
   if (Is_04044[1] == "(1)  No Recent News") { 
   Ls_FFFE0 = "No Recent News";
   } 
   else { 
   Ls_FFFE0 = TimeToString(Il_046E0, 5);
   } 
   Ls_FFFD0 = "\n";
   } 
   tmp_str00000 = (string)Id_04728;
   tmp_str00000 = " with " + tmp_str00000;
   tmp_str00000 = tmp_str00000 + " cycle ";
   tmp_str00001 = (string)Ii_0471C;
   tmp_str00000 = tmp_str00000 + tmp_str00001;
   Ls_FFFC0 = tmp_str00000;
   Ls_FFFB0 = "Unidentified";
   if (Ib_046F0) { 
   Ls_FFFB0 = "Trading" + tmp_str00000;
   } 
   else { 
   Ls_FFFB0 = "Stop Trading";
   } 
   tmp_str00001 = (string)Ii_0478C;
   tmp_str00001 = "All Orders: " + tmp_str00001;
   Gi_00001 = 0;
   tmp_str00002 = "Unidentified";
   Gi_00002 = OrdersTotal() - 1;
   Gi_00003 = Gi_00002;
   if (Gi_00002 >= 0) { 
   do { 
   if (OrderSelect(Gi_00003, 0, 0)) { 
   Gi_00001 = OrderType();
   } 
   if (Gi_00001 == 0) { 
   tmp_str00002 = "Buy";
   } 
   else { 
   tmp_str00002 = "Sell";
   } 
   Gi_00003 = Gi_00003 - 1;
   } while (Gi_00003 >= 0); 
   } 
   tmp_str00003 = "Trend Orders: " + tmp_str00002;
   tmp_str00004 = TimeToString(TimeLocal(), 5);
   tmp_str00005 = TimeToString(TimeCurrent(), 5);
   Comment("\n", Ls_FFFF0, Ls_FFFE0, Ls_FFFD0, "Status: ", Ls_FFFB0, "\n\n", "Broker Time: ", tmp_str00005, "\n", "Local Time: ", tmp_str00004, "\n", "\n", tmp_str00003, "\n", tmp_str00001, "\n");
}

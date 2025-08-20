#property copyright "http://.com/";
#property link "http://.com/forum/";
#property version "";
#property strict

extern string Strategy = " Averaging 1 - OFF. 2 - ON.";
extern int MoneyManagementType = 1;
extern double Multiplikator = 1.6;
extern string InitialLot = "Volume of the first position";
extern string TypeSelection = "true - Constant, false - From the balance";
extern bool Constant_or_Balance = true;
extern double ConstantLot = 0.01;
extern double Percentage_Of_Autolot_Volume = 30;
extern double TakeProfit = 30;
extern double Step = 70;
extern int MaxOrders = 18;
extern string Riskmanagment = "Closing all positions when the specified level is reached";
extern bool Use_Restrictions;
extern double LimitSize = 20;
extern int Magic = 3579;
extern string Logo = "Demonstration of the logo";
extern bool ShowLogo = true;
extern string parameters = "(true-ON,false-OFF)";

double Ind_000;
double Id_00B8;
int Gi_0000;
bool returned_b;
double Gd_0000;
double Id_0038;
string Gs_0000;
int Gi_0001;
string Gs_0001;
int Gi_0002;
string Gs_0002;
int Gi_0003;
string Gs_0003;
int Gi_0004;
string Gs_0004;
int Gi_0005;
string Gs_0005;
int Gi_0006;
string Gs_0006;
int Gi_0007;
string Gs_0007;
int Gi_0008;
string Gs_0008;
int returned_i;
double Gd_0001;
double Gd_0008;
int Gi_0009;
int Gi_000A;
int Gi_000B;
double Gd_000C;
int Gi_000D;
int Gi_000E;
int Gi_000F;
double Gd_0010;
int Gi_0011;
int Gi_0012;
int Gi_0013;
double Gd_0014;
int Gi_0015;
int Gi_0016;
int Gi_0017;
double Gd_0018;
int Gi_0019;
double Gd_001A;
int Gi_001B;
int Gi_001C;
double Gd_001D;
int Gi_001E;
int Gi_001F;
int Gi_0020;
double Gd_0021;
int Gi_0022;
double Gd_0023;
int Gi_0024;
int Gi_0025;
double Gd_0026;
int Gi_0027;
int Gi_0028;
int Gi_0029;
double Gd_002A;
int Gi_002B;
double Gd_002C;
int Gi_002D;
int Gi_002E;
double Gd_002F;
int Gi_0030;
int Gi_0031;
int Gi_0032;
double Gd_0033;
int Gi_0034;
double Gd_0035;
int Gi_0036;
int Gi_0037;
double Gd_0038;
int Gi_0039;
int Gi_003A;
int Gi_003B;
int Gi_003C;
int Gi_003D;
long Gl_003E;
long returned_l;
bool Gb_003E;
double Id_0028;
double Id_0040;
double Id_0060;
int Ii_0084;
int Gi_003E;
bool Ib_0078;
int Ii_0080;
int Ii_007C;
bool Ib_0069;
double Id_0090;
double Id_0058;
double Id_0050;
bool Ib_006A;
long Gl_003F;
int Ii_00C8;
int Gi_003F;
double Id_0030;
double Gd_0040;
double Gd_0041;
int Gi_0042;
double Gd_0043;
double Gd_0044;
int Gi_0045;
long Gl_0046;
int Ii_00C4;
long Gl_0045;
int Gi_0046;
int Gi_0047;
bool Gb_0047;
double Gd_0047;
double Gd_0048;
int Gi_0049;
double Id_00F8;
bool Gb_0049;
double Id_0100;
double Gd_004A;
double Gd_004B;
int Gi_004C;
double Gd_004D;
double Gd_004E;
int Gi_004F;
bool Ib_00E8;
string Is_0000;
bool Ib_00C0;
bool Ib_00E1;
bool Ib_00E2;
double Id_00A8;
double Id_00B0;
double Gd_004F;
bool Gb_004F;
bool Ib_00E0;
bool Ib_0068;
double Id_0010;
double Gd_0050;
double Id_00D0;
bool Ib_0024;
int Ii_00CC;
bool Gb_0053;
int Gi_0053;
int Ii_00E4;
double Id_0098;
double Id_00A0;
bool Gb_0057;
bool Gb_005A;
int Gi_005A;
long Gl_005D;
double Id_0070;
double Gd_005E;
double Ind_004;
int Gi_005E;
double Ind_002;
double Id_0088;
double Id_0048;
double Id_00D8;
int Gi_005F;
int Gi_0058;
long Gl_0058;
long Gl_0059;
bool Gb_0059;
int Gi_0059;
double Gd_005A;
int Gi_0057;
double Gd_0058;
bool Gb_005D;
int Gi_005D;
int Gi_005B;
long Gl_005B;
long Gl_005C;
bool Gb_005C;
int Gi_005C;
double Gd_005D;
double Gd_005B;
int Gi_0051;
long Gl_0051;
long Gl_0052;
bool Gb_0052;
int Gi_0052;
double Gd_0053;
int Gi_0050;
double Gd_0051;
double Gd_0054;
int Gi_0055;
long Gl_0055;
long Gl_0056;
bool Gb_0056;
int Gi_0056;
double Gd_0057;
int Gi_0054;
double Gd_0055;
string Is_0018;
int Ii_00EC;
int Ii_00F0;
int Ii_0108;
int Ii_010C;
int Ii_0110;
int Ii_0114;
int Ii_0118;
int Ii_011C;
int Ii_0120;
int Ii_0124;
int Ii_0128;
short returned_st;
bool Gb_0003;
bool Gb_0000;
double Gd_0002;
double Gd_0004;
long Gl_0005;
long Gl_0006;
long Gl_0003;
long Gl_0004;
double Gd_0003;
double Gd_0006;
double Gd_0007;
double Gd_0009;
double Gd_000A;
double Gd_000D;
double Gd_000F;
double Gd_0012;
double Gd_0013;
int Gi_0014;
double Gd_0015;
double Gd_0016;
double Gd_0019;
int Gi_001A;
double Gd_001B;
double Gd_001C;
int Gi_001D;
double Gd_001E;
double Gd_001F;
double Gd_0022;
int Gi_0023;
int Gi_0033;
long Gl_0034;
int Gi_0035;
bool Gb_0037;
long Gl_0038;
bool Gb_003A;
double Gd_003A;
double Gd_0036;
long Gl_0029;
int Gi_002A;
bool Gb_002C;
int Gi_002C;
long Gl_002D;
int Gi_002F;
bool Gb_002F;
long Gl_0030;
bool Gb_0033;
double Gd_0032;
double Gd_002B;
long Gl_0025;
int Gi_0026;
bool Gb_0028;
double Gd_0027;
bool Gb_0001;
long Gl_0009;
long Gl_000A;
long Gl_000B;
double Gd_000B;
long Gl_000C;
string Is_0160[10];
double returned_double;
bool order_check;
int init()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   int Li_FFFC;
   
   Is_0000 = "EA Smart Machine";
   Id_0010 = 2;
   Is_0018 = "EA Smart Machine v 3.4.0";
   Ib_0024 = true;
   Id_0028 = 0;
   Id_0030 = 5;
   Id_0038 = 0;
   Id_0040 = 0;
   Id_0048 = 0;
   Id_0050 = 10;
   Id_0058 = 10;
   Id_0060 = 0;
   Ib_0068 = false;
   Ib_0069 = false;
   Ib_006A = false;
   Id_0070 = 48;
   Ib_0078 = false;
   Ii_007C = 2;
   Ii_0080 = 16;
   Ii_0084 = 0;
   Id_0088 = 0;
   Id_0090 = 0;
   Id_0098 = 0;
   Id_00A0 = 0;
   Id_00A8 = 0;
   Id_00B0 = 0;
   Id_00B8 = 0;
   Ib_00C0 = false;
   Ii_00C4 = 0;
   Ii_00C8 = 0;
   Ii_00CC = 0;
   Id_00D0 = 0;
   Id_00D8 = 0;
   Ib_00E0 = false;
   Ib_00E1 = false;
   Ib_00E2 = false;
   Ii_00E4 = 0;
   Ib_00E8 = false;
   Ii_00EC = 0;
   Ii_00F0 = 0;
   Id_00F8 = 0;
   Id_0100 = 0;
   Ii_0108 = 14;
   Ii_010C = 55295;
   Ii_0110 = 42495;
   Ii_0114 = 8421504;
   Ii_0118 = 5197615;
   Ii_011C = -1;
   Ii_0120 = 0;
   Ii_0124 = 1;
   Ii_0128 = 2;
   Li_FFFC = 0;
   Id_00B8 = (MarketInfo(_Symbol, MODE_SPREAD) * _Point);
   Gi_0000 = IsTesting();
   if (Gi_0000 == 1) { 
   tmp_str0000 = ServerAddress();
   tmp_str0001 = "            EA Smart Machine 3.4  " + _Symbol;
   tmp_str0001 = tmp_str0001 + "  Time Frame: ";
   tmp_str0002 = (string)_Period;
   tmp_str0001 = tmp_str0001 + tmp_str0002;
   Comment(tmp_str0001, "\n", "            Server: ", tmp_str0000, "\n", "            Lots:  ", Id_0038, "\n", "            Symbol: ", _Symbol, "\n", "            Price:  ", NormalizeDouble(Bid, 4), "\n");
   } 
   Gi_0000 = IsTesting();
   if (Gi_0000 == 0) { 
   tmp_str0002 = ServerAddress();
   tmp_str0003 = "            EA Smart Machine 3.4  " + _Symbol;
   tmp_str0003 = tmp_str0003 + "  Time Frame: ";
   tmp_str0004 = (string)_Period;
   tmp_str0003 = tmp_str0003 + tmp_str0004;
   Comment(tmp_str0003, "\n", "            Server: ", tmp_str0002, "\n", "            Lots:  ", Id_0038, "\n", "            Symbol: ", _Symbol, "\n", "            Price:  ", NormalizeDouble(Bid, 4), "\n");
   } 
   Is_0160[0] = "USD";
   Is_0160[1] = "EUR";
   Is_0160[2] = "GBP";
   Is_0160[3] = "JPY";
   Is_0160[4] = "CHF";
   Is_0160[5] = "CAD";
   Is_0160[6] = "NZD";
   Is_0160[7] = "AUD";
   Is_0160[8] = "RUB";
   Li_FFFC = 0;
   return 0;
}

void OnTick()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   double Ld_FFF8;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
   double Ld_FFD0;
   double Ld_FFC8;
   double Ld_FFC0;
   double Ld_FFB8;
   double Ld_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   double Ld_FF88;
   int Li_FF84;
   int Li_FF80;
   double Ld_FF78;
   int Li_FF74;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Ld_FFD8 = 0;
   Ld_FFD0 = 0;
   Ld_FFC8 = 0;
   Ld_FFC0 = 0;
   Ld_FFB8 = 0;
   Ld_FFB0 = 0;
   Ld_FF88 = 0;
   Li_FF84 = 0;
   Li_FF80 = 0;
   Ld_FF78 = 0;
   Li_FF74 = 0;
   Gi_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = 0;
   Gi_0007 = 0;
   Gd_0008 = 0;
   Gi_0009 = 0;
   Gi_000A = 0;
   Gi_000B = 0;
   Gd_000C = 0;
   Gi_000D = 0;
   Gi_000E = 0;
   Gi_000F = 0;
   Gd_0010 = 0;
   Gi_0011 = 0;
   Gi_0012 = 0;
   Gi_0013 = 0;
   Gd_0014 = 0;
   Gi_0015 = 0;
   Gi_0016 = 0;
   Gi_0017 = 0;
   Gd_0018 = 0;
   Gi_0019 = 0;
   Gd_001A = 0;
   Gi_001B = 0;
   Gi_001C = 0;
   Gd_001D = 0;
   Gi_001E = 0;
   Gi_001F = 0;
   Gi_0020 = 0;
   Gd_0021 = 0;
   Gi_0022 = 0;
   Gd_0023 = 0;
   Gi_0024 = 0;
   Gi_0025 = 0;
   Gd_0026 = 0;
   Gi_0027 = 0;
   Gi_0028 = 0;
   Gi_0029 = 0;
   Gd_002A = 0;
   Gi_002B = 0;
   Gd_002C = 0;
   Gi_002D = 0;
   Gi_002E = 0;
   Gd_002F = 0;
   Gi_0030 = 0;
   Gi_0031 = 0;
   Gi_0032 = 0;
   Gd_0033 = 0;
   Gi_0034 = 0;
   Gd_0035 = 0;
   Gi_0036 = 0;
   Gi_0037 = 0;
   Gd_0038 = 0;
   Gi_0039 = 0;
   Gi_003A = 0;
   Gi_003B = 0;
   Gi_003C = 0;
   Gi_003D = 0;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Ld_FFD8 = MarketInfo(_Symbol, MODE_POINT);
   Ld_FFD0 = MarketInfo(_Symbol, MODE_BID);
   Ld_FFC8 = MarketInfo(_Symbol, MODE_ASK);
   Ld_FFC0 = MarketInfo(_Symbol, MODE_MAXLOT);
   Ld_FFB8 = MarketInfo(_Symbol, MODE_MINLOT);
   Ld_FFB0 = MarketInfo(_Symbol, MODE_LOTSTEP);
   if ((IsOptimization() == false && IsTesting() == false && !IsVisualMode())
   || (ShowLogo && IsTesting() && IsOptimization() == false)) {
   
   f0_13();
   f0_10();
   }
   if (Constant_or_Balance) { 
   Id_0038 = ConstantLot;
   } 
   else { 
   Id_0038 = (((AccountBalance() * Percentage_Of_Autolot_Volume) / 100) / 10000);
   } 
   if ((Id_0038 < Ld_FFB8)) { 
   tmp_str0000 = (string)Id_0038;
   tmp_str0000 = "Calculated size " + tmp_str0000;
   tmp_str0000 = tmp_str0000 + " is less than allowed minimum ";
   tmp_str0001 = (string)Ld_FFB8;
   tmp_str0000 = tmp_str0000 + tmp_str0001;
   Print(tmp_str0000);
   } 
   if ((Id_0038 > Ld_FFC0)) { 
   Gb_003E = (Ld_FFC0 > 0);
   if (Gb_003E) { 
   tmp_str0001 = (string)Id_0038;
   tmp_str0001 = "Calculated size " + tmp_str0001;
   tmp_str0001 = tmp_str0001 + " exceeds allowed maximum ";
   tmp_str0002 = (string)Ld_FFC0;
   tmp_str0001 = tmp_str0001 + tmp_str0002;
   Print(tmp_str0001);
   }} 
   Id_0028 = Multiplikator;
   Id_0040 = TakeProfit;
   Id_0060 = Step;
   Ii_0084 = Magic;
   Ls_FFA0 = "false";
   Ls_FF90 = "false";
   Gi_003E = Ib_0078;
   Gb_003E = (Hour() >= Ii_0080);
   if (Gb_003E) { 
   Gb_003E = (Hour() <= Ii_007C);
   } 
   if (Ib_0078 == 0
   || (Ib_0078 && Ii_0080 > Ii_007C && Hour() >= Ii_007C && Hour() <= Ii_0080)
   || (Ii_007C > Ii_0080 && !Gb_003E)) {
   
   Ls_FFA0 = "true";
   }
   Gb_003E = (Hour() >= Ii_007C);
   if (Gb_003E) { 
   Gb_003E = (Hour() <= Ii_0080);
   } 
   if ((Ib_0078 && Ii_0080 > Ii_007C && Gb_003E == false)
   || (Ii_007C > Ii_0080 && Hour() >= Ii_0080 && Hour() <= Ii_007C)) {
   
   Ls_FF90 = "true";
   }
   if (Ib_0069) { 
   f0_18((int)Id_0050, (int)Id_0058, Id_0090);
   } 
   if (Ib_006A) { 
   Gl_003E = TimeCurrent();
   Gl_003F = Ii_00C8;
   if (Gl_003E >= Gl_003F) { 
   Gi_003F = OrdersTotal() - 1;
   Gi_0000 = Gi_003F;
   if (Gi_003F >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0000, 0, 0);
   if (OrderSymbol() == _Symbol) { 
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_BUY) { 
   order_check = OrderClose(OrderTicket(), OrderLots(), Bid, (int)Id_0030, 16711680);
   } 
   if (OrderType() == OP_SELL) { 
   order_check = OrderClose(OrderTicket(), OrderLots(), Ask, (int)Id_0030, 255);
   }} 
   Sleep(1000);
   } 
   Gi_0000 = Gi_0000 - 1;
   } while (Gi_0000 >= 0); 
   } 
   Print("Closed All due to TimeOut");
   }} 
   Gl_0046 = Ii_00C4;
   if (Gl_0046 == Time[0]) { 
   return ;
   } 
   Ii_00C4 = (int)Time[0];
   Gd_0001 = 0;
   Gi_0047 = OrdersTotal() - 1;
   Gi_0002 = Gi_0047;
   if (Gi_0047 >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0002, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Gd_0001 = (Gd_0001 + OrderProfit());
   }} 
   Gi_0002 = Gi_0002 - 1;
   } while (Gi_0002 >= 0); 
   } 
   Ld_FF88 = Gd_0001;
   if (Use_Restrictions && (Gd_0001 < 0)) { 
   Gd_0047 = fabs(Gd_0001);
   Gd_0048 = (LimitSize / 100);
   Gi_0003 = 0;
   Gi_0049 = OrdersTotal() - 1;
   Gi_0004 = Gi_0049;
   if (Gi_0049 >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0004, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_SELL || OrderType() == OP_BUY) { 
   
   Gi_0003 = Gi_0003 + 1;
   }} 
   Gi_0004 = Gi_0004 - 1;
   } while (Gi_0004 >= 0); 
   } 
   if (Gi_0003 == 0) { 
   Id_00F8 = AccountEquity();
   } 
   if ((Id_00F8 < Id_0100)) { 
   Id_00F8 = Id_0100;
   } 
   else { 
   Id_00F8 = AccountEquity();
   } 
   Id_0100 = AccountEquity();
   if ((Gd_0047 > (Gd_0048 * Id_00F8))) { 
   Gi_0049 = OrdersTotal() - 1;
   Gi_0005 = Gi_0049;
   if (Gi_0049 >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0005, 0, 0);
   if (OrderSymbol() == _Symbol) { 
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_BUY) { 
   order_check = OrderClose(OrderTicket(), OrderLots(), Bid, (int)Id_0030, 16711680);
   } 
   if (OrderType() == OP_SELL) { 
   order_check = OrderClose(OrderTicket(), OrderLots(), Ask, (int)Id_0030, 255);
   }} 
   Sleep(1000);
   } 
   Gi_0005 = Gi_0005 - 1;
   } while (Gi_0005 >= 0); 
   } 
   Print("Closed All due to Stop Out");
   Ib_00E8 = false;
   }} 
   tmp_str0002 = Is_0000;
   lookup_history_orders(Ld_FFB0, Id_0030, tmp_str0002, Ii_0084);
   Gi_0006 = 0;
   Gi_004F = OrdersTotal() - 1;
   Gi_0007 = Gi_004F;
   if (Gi_004F >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0007, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_SELL || OrderType() == OP_BUY) { 
   
   Gi_0006 = Gi_0006 + 1;
   }} 
   Gi_0007 = Gi_0007 - 1;
   } while (Gi_0007 >= 0); 
   } 
   Li_FF84 = Gi_0006;
   if (Gi_0006 == 0) { 
   Ib_00C0 = false;
   } 
   Li_FF80 = OrdersTotal() - 1;
   if (Li_FF80 >= 0) { 
   do { 
   order_check = OrderSelect(Li_FF80, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_BUY) { 
   Ib_00E1 = true;
   Ib_00E2 = false;
   Ld_FFF8 = OrderLots();
   break; 
   } 
   if (OrderType() == OP_SELL) { 
   Ib_00E1 = false;
   Ib_00E2 = true;
   Ld_FFF0 = OrderLots();
   break; 
   }} 
   Li_FF80 = Li_FF80 - 1;
   } while (Li_FF80 >= 0); 
   } 
   if (Li_FF84 > 0 && Li_FF84 <= MaxOrders) { 
   RefreshRates();
   Gd_0008 = 0;
   Gi_0009 = 0;
   Gi_000A = 0;
   Gi_004F = OrdersTotal() - 1;
   Gi_000B = Gi_004F;
   if (Gi_004F >= 0) { 
   do { 
   order_check = OrderSelect(Gi_000B, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderType() == OP_BUY) { 
   Gi_0009 = OrderTicket();
   if (Gi_0009 > Gi_000A) { 
   Gd_0008 = OrderOpenPrice();
   Gi_000A = Gi_0009;
   }} 
   Gi_000B = Gi_000B - 1;
   } while (Gi_000B >= 0); 
   } 
   Id_00A8 = Gd_0008;
   Gd_000C = 0;
   Gi_000D = 0;
   Gi_000E = 0;
   Gi_004F = OrdersTotal() - 1;
   Gi_000F = Gi_004F;
   if (Gi_004F >= 0) { 
   do { 
   order_check = OrderSelect(Gi_000F, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderType() == OP_SELL) { 
   Gi_000D = OrderTicket();
   if (Gi_000D > Gi_000E) { 
   Gd_000C = OrderOpenPrice();
   Gi_000E = Gi_000D;
   }} 
   Gi_000F = Gi_000F - 1;
   } while (Gi_000F >= 0); 
   } 
   Id_00B0 = Gd_000C;
   if (Ib_00E1) { 
   Gd_004F = (Id_00A8 - Ask);
   if ((Gd_004F >= (Id_0060 * _Point))) { 
   Ib_00E0 = true;
   }} 
   if (Ib_00E2) { 
   Gd_004F = (Bid - Id_00B0);
   if ((Gd_004F >= (Id_0060 * _Point))) { 
   Ib_00E0 = true;
   }}} 
   if (Li_FF84 < 1) { 
   Ib_00E2 = false;
   Ib_00E1 = false;
   Ib_00E0 = true;
   } 
   if (Ib_00E0) { 
   Gd_0010 = 0;
   Gi_0011 = 0;
   Gi_0012 = 0;
   Gi_004F = OrdersTotal() - 1;
   Gi_0013 = Gi_004F;
   if (Gi_004F >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0013, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderType() == OP_BUY) { 
   Gi_0011 = OrderTicket();
   if (Gi_0011 > Gi_0012) { 
   Gd_0010 = OrderOpenPrice();
   Gi_0012 = Gi_0011;
   }} 
   Gi_0013 = Gi_0013 - 1;
   } while (Gi_0013 >= 0); 
   } 
   Id_00A8 = Gd_0010;
   Gd_0014 = 0;
   Gi_0015 = 0;
   Gi_0016 = 0;
   Gi_004F = OrdersTotal() - 1;
   Gi_0017 = Gi_004F;
   if (Gi_004F >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0017, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderType() == OP_SELL) { 
   Gi_0015 = OrderTicket();
   if (Gi_0015 > Gi_0016) { 
   Gd_0014 = OrderOpenPrice();
   Gi_0016 = Gi_0015;
   }} 
   Gi_0017 = Gi_0017 - 1;
   } while (Gi_0017 >= 0); 
   } 
   Id_00B0 = Gd_0014;
   if (Ib_00E2 != false) {
   if (Ib_0068 || Ls_FF90 == "true") { 
   
   f0_1(false, true);
   Id_00D0 = NormalizeDouble((Id_0028 * Ld_FFF0), (int)Id_0010);
   } 
   else { 
   Gd_001A = 0;
   Gi_001B = 0;
   returned_i = MoneyManagementType;
   if (returned_i == 0) {
   
   Gd_001A = Id_0038;
   }
   if (returned_i == 1) {
   
   returned_double = MathPow(Id_0028, Ii_00CC);
   Gd_001A = NormalizeDouble((Id_0038 * returned_double), (int)Id_0010);
   }
   if (returned_i == 2) {
   
   Gi_001B = 0;
   Gd_001A = Id_0038;
   Gi_0051 = HistoryTotal() - 1;
   Gi_001C = Gi_0051;
   if (Gi_0051 >= 0) {
   do { 
   if (!OrderSelect(Gi_001C, 0, 1)) {
   Gd_0018 = -3;
   break;//
   }
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   Gl_0051 = OrderCloseTime();
   Gl_0052 = Gi_001B;
   if (Gl_0052 < Gl_0051) { 
   Gi_001B = (int)OrderCloseTime();
   if ((OrderProfit() < 0)) { 
   Gd_001A = NormalizeDouble((OrderLots() * Id_0028), (int)Id_0010);
   } 
   else { 
   Gd_001A = Id_0038;
   }}} 
   Gi_001C = Gi_001C - 1;
   } while (Gi_001C >= 0); 
   }}
   if ((AccountFreeMarginCheck(_Symbol, 1, Gd_001A) <= 0)) { 
   Gd_0018 = -1;
   } 
   else { 
   Gi_0053 = GetLastError();
   if (Gi_0053 == 134) { 
   Gd_0018 = -2;
   } 
   else { 
   Gd_0018 = Gd_001A;
   }} 
   Id_00D0 = Gd_0018;
   } 
   if (Ib_0024 && Ls_FFA0 == "true") {
   Ii_00CC = Li_FF84;
   if ((Id_00D0 > 0)) {
   RefreshRates();
   tmp_str0003 = Is_0000;
   Ii_00E4 = perform_order_op(1, Id_00D0, Bid, (int)Id_0030, Ask, 0, 0, tmp_str0003, Ii_0084, 0, 11823615);
   if (Ii_00E4 < 0) { 
   Print("Error: ", GetLastError());
   return ;
   } 
   Gd_001D = 0;
   Gi_001E = 0;
   Gi_001F = 0;
   Gi_0053 = OrdersTotal() - 1;
   Gi_0020 = Gi_0053;
   if (Gi_0053 >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0020, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderType() == OP_SELL) { 
   Gi_001E = OrderTicket();
   if (Gi_001E > Gi_001F) { 
   Gd_001D = OrderOpenPrice();
   Gi_001F = Gi_001E;
   }} 
   Gi_0020 = Gi_0020 - 1;
   } while (Gi_0020 >= 0); 
   } 
   Id_00B0 = Gd_001D;
   Ib_00E0 = false;
   Ib_00E8 = true;
   Sleep(1500);
   }}}
   else{
   if (Ib_00E1) { 
   if (Ib_0068 || Ls_FF90 == "true") { 
   
   f0_1(true, false);
   Id_00D0 = NormalizeDouble((Id_0028 * Ld_FFF8), (int)Id_0010);
   } 
   else { 
   Gd_0023 = 0;
   Gi_0024 = 0;
   returned_i = MoneyManagementType;
   if (returned_i == 0) {
   
   Gd_0023 = Id_0038;
   }
   if (returned_i == 1) {
   
   returned_double = MathPow(Id_0028, Ii_00CC);
   Gd_0023 = NormalizeDouble((Id_0038 * returned_double), (int)Id_0010);
   }
   if (returned_i == 2) {
   
   Gi_0024 = 0;
   Gd_0023 = Id_0038;
   Gi_0055 = HistoryTotal() - 1;
   Gi_0025 = Gi_0055;
   if (Gi_0055 >= 0) {
   do { 
   if (!OrderSelect(Gi_0025, 0, 1)) {
   Gd_0021 = -3;
   break;
   }
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   Gl_0055 = OrderCloseTime();
   Gl_0056 = Gi_0024;
   if (Gl_0056 < Gl_0055) { 
   Gi_0024 = (int)OrderCloseTime();
   if ((OrderProfit() < 0)) { 
   Gd_0023 = NormalizeDouble((OrderLots() * Id_0028), (int)Id_0010);
   } 
   else { 
   Gd_0023 = Id_0038;
   }}} 
   Gi_0025 = Gi_0025 - 1;
   } while (Gi_0025 >= 0); 
   }}
   if ((AccountFreeMarginCheck(_Symbol, 0, Gd_0023) <= 0)) { 
   Gd_0021 = -1;
   } 
   else { 
   Gi_0057 = GetLastError();
   if (Gi_0057 == 134) { 
   Gd_0021 = -2;
   } 
   else { 
   Gd_0021 = Gd_0023;
   }} 
   Id_00D0 = Gd_0021;
   } 
   if (Ib_0024 && Ls_FFA0 == "true") { 
   Ii_00CC = Li_FF84;
   if ((Id_00D0 > 0)) { 
   tmp_str0004 = Is_0000;
   Ii_00E4 = perform_order_op(0, Id_00D0, Ask, (int)Id_0030, Bid, 0, 0, tmp_str0004, Ii_0084, 0, 65280);
   if (Ii_00E4 < 0) { 
   Print("Error: ", GetLastError());
   return ;
   } 
   Gd_0026 = 0;
   Gi_0027 = 0;
   Gi_0028 = 0;
   Gi_0057 = OrdersTotal() - 1;
   Gi_0029 = Gi_0057;
   if (Gi_0057 >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0029, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderType() == OP_BUY) { 
   Gi_0027 = OrderTicket();
   if (Gi_0027 > Gi_0028) { 
   Gd_0026 = OrderOpenPrice();
   Gi_0028 = Gi_0027;
   }} 
   Gi_0029 = Gi_0029 - 1;
   } while (Gi_0029 >= 0); 
   } 
   Id_00A8 = Gd_0026;
   Ib_00E0 = false;
   Ib_00E8 = true;
   Sleep(1500);
   }}}}} 
   if (Ib_00E0 && Li_FF84 < 1) { 
   Ld_FFE8 = iClose(_Symbol, 0, 2);
   returned_double = iClose(_Symbol, 0, 1);
   Ld_FFE0 = returned_double;
   Id_0098 = Bid;
   Id_00A0 = Ask;
   if (Ib_00E2 == false && Ib_00E1 == false && Ls_FFA0 == "true") { 
   Ii_00CC = Li_FF84;
   if ((Ld_FFE8 > returned_double)) {
   Gd_002C = 0;
   Gi_002D = 0;
   returned_i = MoneyManagementType;
   if (returned_i == 0) {
   
   Gd_002C = Id_0038;
   }
   if (returned_i == 1) {
   
   returned_double = MathPow(Id_0028, Ii_00CC);
   Gd_002C = NormalizeDouble((Id_0038 * returned_double), (int)Id_0010);
   }
   if (returned_i == 2) {
   
   Gi_002D = 0;
   Gd_002C = Id_0038;
   Gi_0058 = HistoryTotal() - 1;
   Gi_002E = Gi_0058;
   if (Gi_0058 >= 0) {
   do { 
   if (!OrderSelect(Gi_002E, 0, 1)) {
   Gd_002A = -3;
   break;
   }
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   Gl_0058 = OrderCloseTime();
   Gl_0059 = Gi_002D;
   if (Gl_0059 < Gl_0058) { 
   Gi_002D = (int)OrderCloseTime();
   if ((OrderProfit() < 0)) { 
   Gd_002C = NormalizeDouble((OrderLots() * Id_0028), (int)Id_0010);
   } 
   else { 
   Gd_002C = Id_0038;
   }}} 
   Gi_002E = Gi_002E - 1;
   } while (Gi_002E >= 0); 
   }}
   if ((AccountFreeMarginCheck(_Symbol, 1, Gd_002C) <= 0)) { 
   Gd_002A = -1;
   } 
   else { 
   Gi_005A = GetLastError();
   if (Gi_005A == 134) { 
   Gd_002A = -2;
   } 
   else { 
   Gd_002A = Gd_002C;
   }} 
   Id_00D0 = Gd_002A;
   if ((Gd_002A > 0)) {
   tmp_str0005 = Is_0000;
   Ii_00E4 = perform_order_op(1, Gd_002A, Id_0098, (int)Id_0030, Id_0098, 0, 0, tmp_str0005, Ii_0084, 0, 11823615);
   if (Ii_00E4 < 0) { 
   Print(Id_00D0, "Error: ", GetLastError());
   return ;
   } 
   Gd_002F = 0;
   Gi_0030 = 0;
   Gi_0031 = 0;
   Gi_005A = OrdersTotal() - 1;
   Gi_0032 = Gi_005A;
   if (Gi_005A >= 0) { 
   do { 
   order_check = OrderSelect(Gi_0032, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderType() == OP_BUY) { 
   Gi_0030 = OrderTicket();
   if (Gi_0030 > Gi_0031) { 
   Gd_002F = OrderOpenPrice();
   Gi_0031 = Gi_0030;
   }} 
   Gi_0032 = Gi_0032 - 1;
   } while (Gi_0032 >= 0); 
   } 
   Id_00A8 = Gd_002F;
   Ib_00E8 = true;
   Sleep(1500);
   }}
   else{
   Gd_0035 = 0;
   Gi_0036 = 0;
   returned_i = MoneyManagementType;
   if (returned_i == 0) {
   
   Gd_0035 = Id_0038;
   }
   if (returned_i == 1) {
   
   returned_double = MathPow(Id_0028, Ii_00CC);
   Gd_0035 = NormalizeDouble((Id_0038 * returned_double), (int)Id_0010);
   }
   if (returned_i == 2) {
   
   Gi_0036 = 0;
   Gd_0035 = Id_0038;
   Gi_005B = HistoryTotal() - 1;
   Gi_0037 = Gi_005B;
   if (Gi_005B >= 0) {
   do { 
   if (!OrderSelect(Gi_0037, 0, 1)) {
   Gd_0033 = -3;
   break;
   }
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   Gl_005B = OrderCloseTime();
   Gl_005C = Gi_0036;
   if (Gl_005C < Gl_005B) { 
   Gi_0036 = (int)OrderCloseTime();
   if ((OrderProfit() < 0)) { 
   Gd_0035 = NormalizeDouble((OrderLots() * Id_0028), (int)Id_0010);
   } 
   else { 
   Gd_0035 = Id_0038;
   }}} 
   Gi_0037 = Gi_0037 - 1;
   } while (Gi_0037 >= 0); 
   }}
   if ((AccountFreeMarginCheck(_Symbol, 0, Gd_0035) <= 0)) { 
   Gd_0033 = -1;
   } 
   else { 
   Gi_005D = GetLastError();
   if (Gi_005D == 134) { 
   Gd_0033 = -2;
   } 
   else { 
   Gd_0033 = Gd_0035;
   }} 
   Id_00D0 = Gd_0033;
   if ((Gd_0033 > 0)) { 
   tmp_str0006 = Is_0000;
   Ii_00E4 = perform_order_op(0, Gd_0033, Id_00A0, (int)Id_0030, Id_00A0, 0, 0, tmp_str0006, Ii_0084, 0, 65280);
   if (Ii_00E4 < 0) { 
   Print(Id_00D0, "Error: ", GetLastError());
   return ;
   } 
   Gd_0038 = 0;
   Gi_0039 = 0;
   Gi_003A = 0;
   Gi_005D = OrdersTotal() - 1;
   Gi_003B = Gi_005D;
   if (Gi_005D >= 0) { 
   do { 
   order_check = OrderSelect(Gi_003B, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084 && OrderType() == OP_SELL) { 
   Gi_0039 = OrderTicket();
   if (Gi_0039 > Gi_003A) { 
   Gd_0038 = OrderOpenPrice();
   Gi_003A = Gi_0039;
   }} 
   Gi_003B = Gi_003B - 1;
   } while (Gi_003B >= 0); 
   } 
   Id_00B0 = Gd_0038;
   Ib_00E8 = true;
   Sleep(1500);
   }}} 
   if (Ii_00E4 > 0) { 
   Gl_005D = TimeCurrent();
   Gd_005E = ((Id_0070 * 60) * 60);
   Ii_00C8 = (int)(Gl_005D + Gd_005E);
   } 
   Ib_00E0 = false;
   } 
   Gi_003C = 0;
   Gi_005E = OrdersTotal() - 1;
   Gi_003D = Gi_005E;
   if (Gi_005E >= 0) { 
   do { 
   order_check = OrderSelect(Gi_003D, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_SELL || OrderType() == OP_BUY) { 
   
   Gi_003C = Gi_003C + 1;
   }} 
   Gi_003D = Gi_003D - 1;
   } while (Gi_003D >= 0); 
   } 
   Li_FF84 = Gi_003C;
   Id_0090 = 0;
   Ld_FF78 = 0;
   Li_FF74 = 0;
   Li_FF74 = OrdersTotal() - 1;
   if (Li_FF74 >= 0) { 
   do { 
   order_check = OrderSelect(Li_FF74, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Gd_005E = OrderOpenPrice();
   Id_0090 = ((Gd_005E * OrderLots()) + Id_0090);
   Ld_FF78 = (Ld_FF78 + OrderLots());
   }} 
   Li_FF74 = Li_FF74 - 1;
   } while (Li_FF74 >= 0); 
   } 
   if (Li_FF84 > 0) { 
   Id_0090 = NormalizeDouble((Id_0090 / Ld_FF78), _Digits);
   } 
   if (Ib_00E8) { 
   Li_FF74 = OrdersTotal() - 1;
   if (Li_FF74 >= 0) { 
   do { 
   order_check = OrderSelect(Li_FF74, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_BUY) { 
   Id_0088 = ((Id_0040 * _Point) + Id_0090);
   Gd_005E = (Id_0048 * _Point);
   Id_00D8 = (Id_0090 - Gd_005E);
   Ib_00C0 = true;
   } 
   if (OrderType() == OP_SELL) { 
   Gd_005E = (Id_0040 * _Point);
   Id_0088 = (Id_0090 - Gd_005E);
   Id_00D8 = ((Id_0048 * _Point) + Id_0090);
   Ib_00C0 = true;
   }} 
   Li_FF74 = Li_FF74 - 1;
   } while (Li_FF74 >= 0); 
   }} 
   if (Ib_00E8 == false) return; 
   Gi_005E = Ib_00C0;
   if (Gi_005E != 1) return; 
   Li_FF74 = OrdersTotal() - 1;
   if (Li_FF74 < 0) return; 
   do { 
   order_check = OrderSelect(Li_FF74, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   order_check = OrderModify(OrderTicket(), Id_0090, OrderStopLoss(), Id_0088, 0, 65535);
   Ib_00E8 = false;
   } 
   Li_FF74 = Li_FF74 - 1;
   } while (Li_FF74 >= 0); 
   
}

void OnDeinit(const int reason)
{
}

bool lookup_history_orders(double Fa_d_00, double Fa_d_01, string Fa_s_02, int Fa_i_03)
{
   string tmp_str0000;
   bool Lb_FFFF;
   int Li_FFF8;
   int Li_FFF4;
   string Ls_FFE8;
   int Li_FFE4;
   int Li_FFE0;
   int Li_FFDC;
   int Li_FFD8;
   int Li_FFD4;
   double Ld_FFC8;
   bool Lb_FFC7;
   string Ls_FFB8;

   Lb_FFFF = false;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Li_FFE4 = 0;
   Li_FFE0 = 0;
   Li_FFDC = 0;
   Li_FFD8 = 0;
   Li_FFD4 = 0;
   Ld_FFC8 = 0;
   Lb_FFC7 = false;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Li_FFF8 = OrdersTotal();
   Li_FFE4 = 0;
   Li_FFE0 = 0;
   Li_FFDC = -1;
   Li_FFD8 = Ii_011C;
   Li_FFD4 = -1;
   Ld_FFC8 = 0;
   if (TerminalInfoInteger(8) == 0) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   if (MQLInfoInteger(4) == 0) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Lb_FFC7 = false;
   Li_FFF4 = 0;
   if (Li_FFF8 > 0) { 
   do { 
   if (OrderSelect(Li_FFF4, 0, 0)) break; 
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Fa_i_03) { 
   Ls_FFE8 = OrderComment();
   Gi_0000 = StringLen(Ls_FFE8);
   if (Gi_0000 == 9 && StringGetCharacter(Ls_FFE8, 0) == 49 && StringGetCharacter(Ls_FFE8, 1) == 120) { 
   Gi_0000 = StringGetCharacter(Ls_FFE8, 2);
   Li_FFE4 = Gi_0000 - 48;
   Gi_0000 = StringGetCharacter(Ls_FFE8, 3);
   Li_FFE0 = Gi_0000 - 48;
   if (Li_FFE4 == 9 && Li_FFE0 == 9) { 
   Lb_FFC7 = true;
   } 
   else { 
   if (Li_FFE4 >= 0 && Li_FFE4 < 9 && Li_FFE0 >= 0 && Li_FFE0 < 9) { 
   Ls_FFB8 = StringConcatenate(Is_0160[Li_FFE4], Is_0160[Li_FFE0]);
   if (StringFind(_Symbol, Ls_FFB8, 0) == 0) { 
   Lb_FFC7 = true;
   }}} 
   if (Lb_FFC7) { 
   Gi_0002 = StringGetCharacter(Ls_FFE8, 4);
   Li_FFD8 = Gi_0002 - 48;
   Gi_0002 = StringGetCharacter(Ls_FFE8, 5);
   Li_FFD4 = Gi_0002 - 48;
   Gi_0002 = Li_FFD4 * 10;
   Gi_0003 = StringGetCharacter(Ls_FFE8, 6);
   Li_FFD4 = Gi_0003 - 48;
   Li_FFD4 = Gi_0002 + Li_FFD4;
   Gi_0003 = StringGetCharacter(Ls_FFE8, 7);
   Gi_0003 = Gi_0003 - 48;
   Ld_FFC8 = Gi_0003;
   Gi_0003 = StringGetCharacter(Ls_FFE8, 8);
   Gi_0003 = Gi_0003 - 48;
   Ld_FFC8 = ((Gi_0003 / 10) + Ld_FFC8);
   break; 
   }}} 
   Li_FFF4 = Li_FFF4 + 1;
   } while (Li_FFF4 < Li_FFF8); 
   } 
   Gb_0003 = (Li_FFD8 == Ii_0120);
   if (Gb_0003 != true) { 
   Gb_0003 = (Li_FFD8 == Ii_0124);
   } 
   if (Gb_0003 != true) { 
   Gb_0003 = (Li_FFD8 == Ii_0128);
   } 
   if (Gb_0003 != true) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   if (Li_FFD4 <= 0) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   if ((Ld_FFC8 < 1) || (Ld_FFC8 > 10)) { 
   
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   tmp_str0000 = Fa_s_02;
   Lb_FFFF = kill_bill(Li_FFD8, Li_FFD4, Ld_FFC8, Fa_d_00, Fa_d_01, tmp_str0000, Fa_i_03);
   
   return Lb_FFFF;
}

bool kill_bill(int Fa_i_00, int Fa_i_01, double Fa_d_02, double Fa_d_03, double Fa_d_04, string Fa_s_05, int Fa_i_06)
{
   bool Lb_FFFF;
   bool Lb_FFFE;
   bool Lb_FFFD;
   double Ld_FFF0;
   int Li_FFEC;
   int Li_FFE8;
   int Li_FFE4;
   int Li_FFE0;
   long Ll_FFD8;

   Lb_FFFF = false;
   Lb_FFFE = false;
   Lb_FFFD = false;
   Ld_FFF0 = 0;
   Li_FFEC = 0;
   Li_FFE8 = 0;
   Li_FFE4 = 0;
   Li_FFE0 = 0;
   Ll_FFD8 = 0;
   Lb_FFFE = false;
   Lb_FFFD = true;
   Ld_FFF0 = NormalizeDouble(Fa_i_01, 2);
   Li_FFEC = 0;
   Li_FFE8 = 0;
   Li_FFE4 = -1;
   Gb_0000 = (Fa_i_00 == Ii_0120);
   if (Gb_0000 != true) { 
   Gb_0000 = (Fa_i_00 == Ii_0124);
   } 
   if (Gb_0000 != true) { 
   Gb_0000 = (Fa_i_00 == Ii_0128);
   } 
   if (Gb_0000 != true) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Li_FFE0 = 0;
   if (Fa_i_00 == Ii_0120) { 
   Li_FFE4 = 0;
   Lb_FFFD = true;
   } 
   if (Fa_i_00 == Ii_0124) { 
   Li_FFE4 = 1;
   Lb_FFFD = true;
   } 
   if (Fa_i_00 == Ii_0128) { 
   Li_FFE4 = 1;
   Lb_FFFD = false;
   } 
   if (Lb_FFFE) return true; 
   do { 
   RefreshRates();
   if (Li_FFE4 == 1) { 
   Li_FFE8 = OrderSend(_Symbol, 1, Ld_FFF0, Bid, (int)Fa_d_04, 0, 0, Fa_s_05, Fa_i_06, 0, 11823615);
   } 
   else { 
   Li_FFE8 = OrderSend(_Symbol, 0, Ld_FFF0, Ask, (int)Fa_d_04, 0, 0, Fa_s_05, Fa_i_06, 0, 65280);
   } 
   if (Li_FFE8 > 0) { 
   Sleep(200);
   if (Fa_i_00 == Ii_0128) { 
   if (Li_FFE4 == 1) { 
   Li_FFE4 = 0;
   Lb_FFFD = false;
   } 
   else { 
   Li_FFE4 = 1;
   Lb_FFFD = true;
   }} 
   if (Lb_FFFD) { 
   Gd_0000 = (Ld_FFF0 * Fa_d_02);
   Ll_FFD8 = (long)(Gd_0000 / Fa_d_03);
   Ld_FFF0 = NormalizeDouble((Ll_FFD8 * Fa_d_03), 2);
   } 
   Li_FFE0 = 0;
   } 
   else { 
   Gi_0000 = GetLastError();
   Li_FFEC = Gi_0000;
   if (Gi_0000 == 134) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   if (Li_FFEC != 0) { 
   if (Li_FFEC == 137 || Li_FFEC == 146) { 
   
   Sleep(1000);
   } 
   else { 
   if (Li_FFEC == 136) { 
   if (Li_FFE0 > 10) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Li_FFE0 = Li_FFE0 + 1;
   Sleep(200);
   } 
   else { 
   Lb_FFFE = true;
   return true;
   }}}} 
   } while (Lb_FFFE == false); 
   
   Lb_FFFF = true;
   
   return Lb_FFFF;
}

int f0_1(bool FuncArg_Boolean_00000000, bool FuncArg_Boolean_00000001)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   int Li_FFFC;
   int Li_FFF8;
   int Li_FFF4;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Gd_0000 = 0;
   Gd_0001 = 0;
   Li_FFF8 = 0;
   Li_FFF4 = OrdersTotal() - 1;
   if (Li_FFF4 < 0) return Li_FFF8; 
   do { 
   if (OrderSelect(Li_FFF4, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderType() == OP_BUY && FuncArg_Boolean_00000000) { 
   RefreshRates();
   if (!IsTradeContextBusy()) {
   if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 5, 4294967295)) {
   tmp_str0000 = (string)OrderTicket();
   tmp_str0000 = "Error close BUY " + tmp_str0000;
   Print(tmp_str0000);
   Li_FFF8 = -1;
   }}
   else{
   Gl_0003 = iTime(NULL, 0, 0);
   Gl_0004 = Ii_00EC;
   if (Gl_0004 == Gl_0003) { 
   Li_FFFC = -2;
   return Li_FFFC;
   } 
   Ii_00EC = (int)iTime(NULL, 0, 0);
   tmp_str0001 = (string)OrderTicket();
   tmp_str0001 = "Need close BUY " + tmp_str0001;
   tmp_str0001 = tmp_str0001 + ". Trade Context Busy";
   Print(tmp_str0001);
   Li_FFFC = -2;
   return Li_FFFC;
   }} 
   if (OrderType() == OP_SELL && FuncArg_Boolean_00000001) { 
   RefreshRates();
   if (!IsTradeContextBusy()) {
   if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 5, 4294967295)) {
   tmp_str0002 = (string)OrderTicket();
   tmp_str0002 = "Error close SELL " + tmp_str0002;
   Print(tmp_str0002);
   Li_FFF8 = -1;
   }}
   else{
   Gl_0005 = iTime(NULL, 0, 0);
   Gl_0006 = Ii_00F0;
   if (Gl_0006 == Gl_0005) { 
   Li_FFFC = -2;
   return Li_FFFC;
   } 
   Ii_00F0 = (int)iTime(NULL, 0, 0);
   tmp_str0003 = (string)OrderTicket();
   tmp_str0003 = "Need close SELL " + tmp_str0003;
   tmp_str0003 = tmp_str0003 + ". Trade Context Busy";
   Print(tmp_str0003);
   Li_FFFC = -2;
   return Li_FFFC;
   }}} 
   Li_FFF4 = Li_FFF4 - 1;
   } while (Li_FFF4 >= 0); 
   
   Li_FFFC = Li_FFF8;
   
   return Li_FFFC;
}

int perform_order_op(int Fa_i_00, double Fa_d_01, double Fa_d_02, int Fa_i_03, double Fa_d_04, double Fa_d_05, int Fa_i_06, string Fa_s_07, int Fa_i_08, int Fa_i_09, int Fa_i_0A)
{
   int Li_FFFC;
   int Li_FFF8;
   int Li_FFF4;
   int Li_FFF0;
   int Li_FFEC;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Li_FFF0 = 0;
   Li_FFEC = 0;
   Gd_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   Gd_0003 = 0;
   Gd_0004 = 0;
   Gi_0005 = 0;
   Gd_0006 = 0;
   Gd_0007 = 0;
   Gi_0008 = 0;
   Gd_0009 = 0;
   Gd_000A = 0;
   Gi_000B = 0;
   Gd_000C = 0;
   Gd_000D = 0;
   Gi_000E = 0;
   Gd_000F = 0;
   Gd_0010 = 0;
   Gi_0011 = 0;
   Gd_0012 = 0;
   Gd_0013 = 0;
   Gi_0014 = 0;
   Gd_0015 = 0;
   Gd_0016 = 0;
   Gi_0017 = 0;
   Gd_0018 = 0;
   Gd_0019 = 0;
   Gi_001A = 0;
   Gd_001B = 0;
   Gd_001C = 0;
   Gi_001D = 0;
   Gd_001E = 0;
   Gd_001F = 0;
   Gi_0020 = 0;
   Gd_0021 = 0;
   Gd_0022 = 0;
   Gi_0023 = 0;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Li_FFF0 = 0;
   Li_FFEC = 100;
   returned_i = Fa_i_00;
   if (returned_i > 5) return Li_FFF8; 
   if (returned_i == 2){
   
   Li_FFF0 = 0;
   if (Li_FFEC <= 0) return Li_FFF8; 
   do { 
   Gi_0024 = Fa_i_0A;
   Gi_0005 = Fa_i_06;
   Gd_0004 = Fa_d_02;
   if (Fa_i_06 == 0) { 
   Gd_0003 = 0;
   } 
   else { 
   Gd_0003 = ((Gi_0005 * _Point) + Gd_0004);
   } 
   Gi_0002 = (int)Id_0048;
   Gd_0001 = Fa_d_04;
   if (Gi_0002 == 0) { 
   Gd_0000 = 0;
   } 
   else { 
   Gd_0027 = (Gi_0002 * _Point);
   Gd_0000 = (Gd_0001 - Gd_0027);
   } 
   Li_FFF8 = OrderSend(_Symbol, 2, Fa_d_01, Fa_d_02, Fa_i_03, Gd_0000, Gd_0003, Fa_s_07, Fa_i_08, Fa_i_09, Gi_0024);
   Gi_0027 = GetLastError();
   Li_FFF4 = Gi_0027;
   if (Gi_0027 == 0) return Li_FFF8; 
   Gb_0028 = (Gi_0027 == 4);
   if (Gb_0028 != true) { 
   Gb_0028 = (Gi_0027 == 137);
   } 
   if (Gb_0028 != true) { 
   Gb_0028 = (Li_FFF4 == 146);
   } 
   if (Gb_0028 != true) { 
   Gb_0028 = (Li_FFF4 == 136);
   } 
   if (Gb_0028 == false) return Li_FFF8; 
   Sleep(1000);
   Li_FFF0 = Li_FFF0 + 1;
   } while (Li_FFF0 < Li_FFEC); 
   return Li_FFF8;
   }
   if (returned_i == 4){
   
   Li_FFF0 = 0;
   if (Li_FFEC <= 0) return Li_FFF8; 
   do { 
   Gi_0028 = Fa_i_0A;
   Gi_000B = Fa_i_06;
   Gd_000A = Fa_d_02;
   if (Fa_i_06 == 0) { 
   Gd_0009 = 0;
   } 
   else { 
   Gd_0009 = ((Gi_000B * _Point) + Gd_000A);
   } 
   Gi_0008 = (int)Id_0048;
   Gd_0007 = Fa_d_04;
   if (Gi_0008 == 0) { 
   Gd_0006 = 0;
   } 
   else { 
   Gd_002B = (Gi_0008 * _Point);
   Gd_0006 = (Gd_0007 - Gd_002B);
   } 
   Li_FFF8 = OrderSend(_Symbol, 4, Fa_d_01, Fa_d_02, Fa_i_03, Gd_0006, Gd_0009, Fa_s_07, Fa_i_08, Fa_i_09, Gi_0028);
   Gi_002B = GetLastError();
   Li_FFF4 = Gi_002B;
   if (Gi_002B == 0) return Li_FFF8; 
   Gb_002C = (Gi_002B == 4);
   if (Gb_002C != true) { 
   Gb_002C = (Gi_002B == 137);
   } 
   if (Gb_002C != true) { 
   Gb_002C = (Li_FFF4 == 146);
   } 
   if (Gb_002C != true) { 
   Gb_002C = (Li_FFF4 == 136);
   } 
   if (Gb_002C == false) return Li_FFF8; 
   Sleep(5000);
   Li_FFF0 = Li_FFF0 + 1;
   } while (Li_FFF0 < Li_FFEC); 
   return Li_FFF8;
   }
   if (returned_i == 0){
   
   Li_FFF0 = 0;
   if (Li_FFEC <= 0) return Li_FFF8; 
   do { 
   RefreshRates();
   Gi_002C = Fa_i_0A;
   Gi_0011 = Fa_i_06;
   Gd_0010 = Ask;
   if (Fa_i_06 == 0) { 
   Gd_000F = 0;
   } 
   else { 
   Gd_000F = ((Gi_0011 * _Point) + Gd_0010);
   } 
   Gi_000E = (int)Id_0048;
   Gd_000D = Bid;
   if (Gi_000E == 0) { 
   Gd_000C = 0;
   } 
   else { 
   Gd_002F = (Gi_000E * _Point);
   Gd_000C = (Gd_000D - Gd_002F);
   } 
   Li_FFF8 = OrderSend(_Symbol, 0, Fa_d_01, Ask, Fa_i_03, Gd_000C, Gd_000F, Fa_s_07, Fa_i_08, Fa_i_09, Gi_002C);
   Gi_002F = GetLastError();
   Li_FFF4 = Gi_002F;
   if (Gi_002F == 0) { 
   Sleep(2000);
   return Li_FFF8;
   } 
   Gb_002F = (Li_FFF4 == 4);
   if (Gb_002F != true) { 
   Gb_002F = (Li_FFF4 == 137);
   } 
   if (Gb_002F != true) { 
   Gb_002F = (Li_FFF4 == 146);
   } 
   if (Gb_002F != true) { 
   Gb_002F = (Li_FFF4 == 136);
   } 
   if (Gb_002F == false) return Li_FFF8; 
   Sleep(5000);
   Li_FFF0 = Li_FFF0 + 1;
   } while (Li_FFF0 < Li_FFEC); 
   return Li_FFF8;
   }
   if (returned_i == 3){
   
   Li_FFF0 = 0;
   if (Li_FFEC <= 0) return Li_FFF8; 
   do { 
   Gi_002F = Fa_i_0A;
   Gi_0017 = Fa_i_06;
   Gd_0016 = Fa_d_02;
   if (Fa_i_06 == 0) { 
   Gd_0015 = 0;
   } 
   else { 
   Gd_0032 = (Gi_0017 * _Point);
   Gd_0015 = (Gd_0016 - Gd_0032);
   } 
   Gi_0014 = (int)Id_0048;
   Gd_0013 = Fa_d_04;
   if (Gi_0014 == 0) { 
   Gd_0012 = 0;
   } 
   else { 
   Gd_0012 = ((Gi_0014 * _Point) + Gd_0013);
   } 
   Li_FFF8 = OrderSend(_Symbol, 3, Fa_d_01, Fa_d_02, Fa_i_03, Gd_0012, Gd_0015, Fa_s_07, Fa_i_08, Fa_i_09, Gi_002F);
   Gi_0032 = GetLastError();
   Li_FFF4 = Gi_0032;
   if (Gi_0032 == 0) return Li_FFF8; 
   Gb_0033 = (Gi_0032 == 4);
   if (Gb_0033 != true) { 
   Gb_0033 = (Gi_0032 == 137);
   } 
   if (Gb_0033 != true) { 
   Gb_0033 = (Li_FFF4 == 146);
   } 
   if (Gb_0033 != true) { 
   Gb_0033 = (Li_FFF4 == 136);
   } 
   if (Gb_0033 == false) return Li_FFF8; 
   Sleep(5000);
   Li_FFF0 = Li_FFF0 + 1;
   } while (Li_FFF0 < Li_FFEC); 
   return Li_FFF8;
   }
   if (returned_i == 5){
   
   Li_FFF0 = 0;
   if (Li_FFEC <= 0) return Li_FFF8; 
   do { 
   Gi_0033 = Fa_i_0A;
   Gi_001D = Fa_i_06;
   Gd_001C = Fa_d_02;
   if (Fa_i_06 == 0) { 
   Gd_001B = 0;
   } 
   else { 
   Gd_0036 = (Gi_001D * _Point);
   Gd_001B = (Gd_001C - Gd_0036);
   } 
   Gi_001A = (int)Id_0048;
   Gd_0019 = Fa_d_04;
   if (Gi_001A == 0) { 
   Gd_0018 = 0;
   } 
   else { 
   Gd_0018 = ((Gi_001A * _Point) + Gd_0019);
   } 
   Li_FFF8 = OrderSend(_Symbol, 5, Fa_d_01, Fa_d_02, Fa_i_03, Gd_0018, Gd_001B, Fa_s_07, Fa_i_08, Fa_i_09, Gi_0033);
   Gi_0036 = GetLastError();
   Li_FFF4 = Gi_0036;
   if (Gi_0036 == 0) return Li_FFF8; 
   Gb_0037 = (Gi_0036 == 4);
   if (Gb_0037 != true) { 
   Gb_0037 = (Gi_0036 == 137);
   } 
   if (Gb_0037 != true) { 
   Gb_0037 = (Li_FFF4 == 146);
   } 
   if (Gb_0037 != true) { 
   Gb_0037 = (Li_FFF4 == 136);
   } 
   if (Gb_0037 == false) return Li_FFF8; 
   Sleep(5000);
   Li_FFF0 = Li_FFF0 + 1;
   } while (Li_FFF0 < Li_FFEC); 
   return Li_FFF8;
   }
   if (returned_i == 1){
   
   Li_FFF0 = 0;
   if (Li_FFEC <= 0) return Li_FFF8; 
   do { 
   Gi_0037 = Fa_i_0A;
   Gi_0023 = Fa_i_06;
   Gd_0022 = Bid;
   if (Fa_i_06 == 0) { 
   Gd_0021 = 0;
   } 
   else { 
   Gd_003A = (Gi_0023 * _Point);
   Gd_0021 = (Gd_0022 - Gd_003A);
   } 
   Gi_0020 = (int)Id_0048;
   Gd_001F = Ask;
   if (Gi_0020 == 0) { 
   Gd_001E = 0;
   } 
   else { 
   Gd_001E = ((Gi_0020 * _Point) + Gd_001F);
   } 
   Li_FFF8 = OrderSend(_Symbol, 1, Fa_d_01, Bid, Fa_i_03, Gd_001E, Gd_0021, Fa_s_07, Fa_i_08, Fa_i_09, Gi_0037);
   Gi_003A = GetLastError();
   Li_FFF4 = Gi_003A;
   if (Gi_003A == 0) { 
   Sleep(2000);
   return Li_FFF8;
   } 
   Gb_003A = (Li_FFF4 == 4);
   if (Gb_003A != true) { 
   Gb_003A = (Li_FFF4 == 137);
   } 
   if (Gb_003A != true) { 
   Gb_003A = (Li_FFF4 == 146);
   } 
   if (Gb_003A != true) { 
   Gb_003A = (Li_FFF4 == 136);
   } 
   if (Gb_003A == false) return Li_FFF8; 
   Sleep(5000);
   Li_FFF0 = Li_FFF0 + 1;
   } while (Li_FFF0 < Li_FFEC); 
   }
   Li_FFFC = Li_FFF8;
   return Li_FFF8;
}

void f0_18(int Fa_i_00, int Fa_i_01, double Fa_d_02)
{
   int Li_FFFC;
   double Ld_FFF0;
   double Ld_FFE8;
   int Li_FFE4;

   Li_FFFC = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Li_FFE4 = 0;
   Li_FFFC = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   if (Fa_i_01 == 0) return; 
   Li_FFE4 = OrdersTotal() - 1;
   if (Li_FFE4 < 0) return; 
   do { 
   if (OrderSelect(Li_FFE4, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0084) { 
   if (OrderSymbol() == _Symbol || OrderMagicNumber() == Ii_0084) {
   
   if (OrderType() == OP_BUY) {
   Gd_0000 = (Bid - Fa_d_02);
   Li_FFFC = (int)NormalizeDouble((Gd_0000 / _Point), 0);
   if (Li_FFFC >= Fa_i_00) {
   returned_double = OrderStopLoss();
   Ld_FFF0 = returned_double;
   Gd_0000 = (Fa_i_01 * _Point);
   Ld_FFE8 = (Bid - Gd_0000);
   if (returned_double == 0 || (returned_double != 0 && Ld_FFE8 > returned_double)) {
   
   order_check = OrderModify(OrderTicket(), Fa_d_02, Ld_FFE8, OrderTakeProfit(), 0, 16776960);
   }}}
   if (OrderType() == OP_SELL) {
   Gd_0001 = (Fa_d_02 - Ask);
   Li_FFFC = (int)NormalizeDouble((Gd_0001 / _Point), 0);
   if (Li_FFFC >= Fa_i_00) {
   returned_double = OrderStopLoss();
   Ld_FFF0 = returned_double;
   Ld_FFE8 = ((Fa_i_01 * _Point) + Ask);
   if (returned_double == 0 || (returned_double != 0 && Ld_FFE8 < returned_double)) {
   
   order_check = OrderModify(OrderTicket(), Fa_d_02, Ld_FFE8, OrderTakeProfit(), 0, 255);
   }}}}
   Sleep(1000);
   } 
   Li_FFE4 = Li_FFE4 - 1;
   } while (Li_FFE4 >= 0); 
   
}

void f0_13()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   double Ld_FFF8;
   string Ls_FFE8;

   Ld_FFF8 = 0;
   Gi_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   Gi_0003 = 0;
   Gd_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = 0;
   Gd_0007 = 0;
   Gi_0008 = 0;
   Gi_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   if (HistoryTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0002, 0, 1)) break; 
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gl_0009 = OrderCloseTime();
   if (Gl_0009 >= iTime(_Symbol, 1440, Gi_0000)) { 
   Gl_0009 = OrderCloseTime();
   Gl_000A = iTime(_Symbol, 1440, Gi_0000) + 86400;
   if (Gl_0009 < Gl_000A) { 
   Gd_000A = (Gd_0001 + OrderProfit());
   Gd_000A = (Gd_000A + OrderCommission());
   Gd_0001 = (Gd_000A + OrderSwap());
   }}} 
   Gi_0002 = Gi_0002 + 1;
   } while (Gi_0002 < HistoryTotal()); 
   } 
   Ld_FFF8 = Gd_0001;
   Ls_FFE8 = Is_0018 + "1";
   if (ObjectFind(Ls_FFE8) == -1) { 
   ObjectCreate(0, Ls_FFE8, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(Ls_FFE8, OBJPROP_CORNER, 1);
   ObjectSet(Ls_FFE8, OBJPROP_XDISTANCE, 10);
   ObjectSet(Ls_FFE8, OBJPROP_YDISTANCE, 15);
   } 
   tmp_str0000 = "Profit Today: " + DoubleToString(Ld_FFF8, 2);
   ObjectSetText(Ls_FFE8, tmp_str0000, Ii_0108, "tahoma", 8388608);
   Gi_0003 = 1;
   Gd_0004 = 0;
   Gi_0005 = 0;
   if (HistoryTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0005, 0, 1)) break; 
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gl_000A = OrderCloseTime();
   if (Gl_000A >= iTime(_Symbol, 1440, Gi_0003)) { 
   Gl_000A = OrderCloseTime();
   Gl_000B = iTime(_Symbol, 1440, Gi_0003) + 86400;
   if (Gl_000A < Gl_000B) { 
   Gd_000B = (Gd_0004 + OrderProfit());
   Gd_000B = (Gd_000B + OrderCommission());
   Gd_0004 = (Gd_000B + OrderSwap());
   }}} 
   Gi_0005 = Gi_0005 + 1;
   } while (Gi_0005 < HistoryTotal()); 
   } 
   Ld_FFF8 = Gd_0004;
   Ls_FFE8 = Is_0018 + "2";
   if (ObjectFind(Ls_FFE8) == -1) { 
   ObjectCreate(0, Ls_FFE8, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(Ls_FFE8, OBJPROP_CORNER, 1);
   ObjectSet(Ls_FFE8, OBJPROP_XDISTANCE, 10);
   ObjectSet(Ls_FFE8, OBJPROP_YDISTANCE, 33);
   } 
   tmp_str0001 = "Profit Yesterday: " + DoubleToString(Ld_FFF8, 2);
   ObjectSetText(Ls_FFE8, tmp_str0001, Ii_0108, "tahoma", 8388608);
   Gi_0006 = 2;
   Gd_0007 = 0;
   Gi_0008 = 0;
   if (HistoryTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0008, 0, 1)) break; 
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) { 
   Gl_000B = OrderCloseTime();
   if (Gl_000B >= iTime(_Symbol, 1440, Gi_0006)) { 
   Gl_000B = OrderCloseTime();
   Gl_000C = iTime(_Symbol, 1440, Gi_0006) + 86400;
   if (Gl_000B < Gl_000C) { 
   Gd_000C = (Gd_0007 + OrderProfit());
   Gd_000C = (Gd_000C + OrderCommission());
   Gd_0007 = (Gd_000C + OrderSwap());
   }}} 
   Gi_0008 = Gi_0008 + 1;
   } while (Gi_0008 < HistoryTotal()); 
   } 
   Ld_FFF8 = Gd_0007;
   Ls_FFE8 = Is_0018 + "3";
   if (ObjectFind(Ls_FFE8) == -1) { 
   ObjectCreate(0, Ls_FFE8, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(Ls_FFE8, OBJPROP_CORNER, 1);
   ObjectSet(Ls_FFE8, OBJPROP_XDISTANCE, 10);
   ObjectSet(Ls_FFE8, OBJPROP_YDISTANCE, 51);
   } 
   tmp_str0002 = "BALANCE: " + DoubleToString(AccountBalance(), 2);
   ObjectSetText(Ls_FFE8, tmp_str0002, Ii_0108, "ARIAL BLACK", 32768);
}

void f0_10()
{
   string Ls_FFF0;

   Ls_FFF0 = Is_0018 + "L_1";
   if (ObjectFind(Ls_FFF0) == -1) { 
   ObjectCreate(0, Ls_FFF0, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(Ls_FFF0, OBJPROP_CORNER, 0);
   ObjectSet(Ls_FFF0, OBJPROP_XDISTANCE, 513);
   ObjectSet(Ls_FFF0, OBJPROP_YDISTANCE, -1);
   } 
   ObjectSetText(Ls_FFF0, "TRADING TIME", 28, "ARIAL BLACK", 2263842);
   Ls_FFF0 = Is_0018 + "L_2";
   if (ObjectFind(Ls_FFF0) == -1) { 
   ObjectCreate(0, Ls_FFF0, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(Ls_FFF0, OBJPROP_CORNER, 0);
   ObjectSet(Ls_FFF0, OBJPROP_XDISTANCE, 631);
   ObjectSet(Ls_FFF0, OBJPROP_YDISTANCE, 49);
   } 
   ObjectSetText(Ls_FFF0, "INVESTMENTS", 16, "IMPACT", 255);
   Ls_FFF0 = Is_0018 + "L_3";
   if (ObjectFind(Ls_FFF0) == -1) { 
   ObjectCreate(0, Ls_FFF0, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(Ls_FFF0, OBJPROP_CORNER, 0);
   ObjectSet(Ls_FFF0, OBJPROP_XDISTANCE, 586);
   ObjectSet(Ls_FFF0, OBJPROP_YDISTANCE, 612);
   } 
   ObjectSetText(Ls_FFF0, "https://t.me/TTinvestment", 12, "Arial", 0);
   Ls_FFF0 = Is_0018 + "L_4";
   if (ObjectFind(Ls_FFF0) == -1) { 
   ObjectCreate(0, Ls_FFF0, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(Ls_FFF0, OBJPROP_CORNER, 0);
   ObjectSet(Ls_FFF0, OBJPROP_XDISTANCE, 583);
   ObjectSet(Ls_FFF0, OBJPROP_YDISTANCE, 586);
   } 
   ObjectSetText(Ls_FFF0, "_____________________", 12, "Arial", 8421504);
   Ls_FFF0 = Is_0018 + "L_5";
   if (ObjectFind(Ls_FFF0) == -1) { 
   ObjectCreate(0, Ls_FFF0, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet(Ls_FFF0, OBJPROP_CORNER, 0);
   ObjectSet(Ls_FFF0, OBJPROP_XDISTANCE, 586);
   ObjectSet(Ls_FFF0, OBJPROP_YDISTANCE, 616);
   } 
   ObjectSetText(Ls_FFF0, "_____________________", 12, "Arial", 8421504);
   ChartSetInteger(0, 2, 1);
   ChartSetInteger(0, 4, 1);
   ChartSetInteger(0, 17, 0);
   ChartSetInteger(0, 5, 3);
   ChartSetInteger(0, 14, 1);
   ChartSetInteger(0, 1, 1);
   ChartSetInteger(0, 16, 1);
   ChartSetInteger(0, 15, 1);
   ChartSetInteger(0, 19, 1);
   ChartSetInteger(0, 21, 13882323);
   ChartSetInteger(0, 22, 0);
   ChartSetInteger(0, 0, 1);
   ChartSetInteger(0, 23, 0);
   ChartSetInteger(0, 25, 0);
   ChartSetInteger(0, 26, 0);
   ChartSetInteger(0, 27, 0);
   ChartSetInteger(0, 28, 16711680);
   ChartSetInteger(0, 29, 255);
   ChartSetInteger(0, 30, 0);
   ChartSetInteger(0, 31, 255);
   ChartSetInteger(0, 32, 16711680);
   ChartSetInteger(0, 33, 255);
   ChartSetInteger(0, 24, 10526303);
}



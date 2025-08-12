//+------------------------------------------------------------------+
//|                                                AI Gen XII EA.mq4 |
//|                                                                  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.6"
#property strict
//The first Expert Advisor on the MQL5 website that uses GPT-4o and ATNet
//AI GEN XII- Next Generation of trading
//--- input parameters
input string   _="MM";
input bool      Risk=1;
input bool     automatic =true;
input double   FixedLot =0.01;
input bool     PropFirm =false;
input bool     Trailing  =false;
input double   TrailingStart =52.0;
input double   TrailingStop =17.0;
int RiskPercent=1;

//input string   _;
//input string   _="MC";
input int      MagicNumber=5005;
input string   Comment ="AI GEN XII";
//input string   _;
//input string   ="GPT";
input string   GPTModel="GPT-4o";
input string   Aggressivity ="Low Aggressivity";
input string  Function= "Advisor only";
input bool     DisableAnimation=false;
string TimeFilter="----------Time Filter";
extern int StartHour=0;
extern int StartMinute=0;
extern int EndHour=23;
extern int EndMinute=59;
int Secs;
int Stop;
int MaxDistance;
bool Delta;
double MaxSpread=0;
int MaxTrailing=0;
int returned_i;
bool Gb_0000;
double Id_0038;
double Ind_000;
double Id_0040;
double Id_0030;
int Ii_009C;
double Id_01C0;
double Id_00F0;
double Id_0068;
double Id_0100;
double Id_0070;
double Id_0110;
double Id_0060;
int Ii_00A0;
double Id_01B8;
int Ii_0098;
double Id_0140;
double Id_00B0;
double Id_00B8;
double Id_00A8;
double Id_0130;
int Ii_0084;
int Gi_0000;
double Ind_004;
double Id_0138;
int Ii_0088;
double Gd_0000;
double Id_00C8;
double Id_0120;
int Ii_0000;
int Ii_0080;
int Ii_0028;
int Gi_0021;
double Gd_0001;
double Id_0128;
bool Gb_0001;
double Ind_002;
double Id_00C0;
double Gd_0002;
double Gd_0003;
int Gi_0001;
bool returned_b;
double Id_00D0;
int Gi_0002;
int Ii_004C;
double Gd_0004;
double Gd_0005;
double Id_0108;
double Gd_0006;
double Id_00E0;
double Id_00F8;
double Id_00E8;
double Id_0170;
double Id_0178;
double Gd_0007;
double Id_00D8;
long returned_l;
int Ii_007C;
bool Gb_0007;
bool Gb_000D;
bool Gb_002F;
int Gi_002F;
int Ii_0094;
int Ii_002C;
bool Gb_0030;
double Gd_0030;
bool Gb_0032;
int Gi_0032;
double Gd_0034;
double Gd_0035;
double Id_0160;
string Is_0008;
int Ii_008C;
bool Gb_0035;
int Gi_0035;
bool Gb_0036;
double Gd_0036;
bool Gb_0038;
int Gi_0038;
double Gd_003A;
double Gd_003B;
double Id_0168;
int Ii_0090;
bool Gb_0037;
double Gd_0037;
double Gd_0038;
double Gd_0039;
bool Gb_0031;
double Gd_0031;
double Gd_0032;
double Gd_0033;
int Gi_000E;
int Ii_0024;
bool Gb_000E;
double Gd_000E;
bool Gb_000F;
int Gi_000F;
double Gd_0010;
double Gd_0011;
bool Gb_0013;
int Gi_0011;
double Gd_0012;
double Gd_0013;
int Gi_0008;
bool Gb_0008;
double Gd_0008;
bool Gb_0009;
int Gi_0009;
double Gd_000A;
double Gd_000B;
int Gi_000B;
double Gd_000C;
double Gd_000D;
double Gd_0021;
double Gd_0022;
double Gd_0023;
double Gd_0024;
double Gd_0025;
double Gd_0026;
bool Gb_0027;
double Gd_0027;
double Gd_002D;
double Id_0118;
double Gd_002F;
double Gd_0028;
double Gd_0029;
double Gd_002A;
double Gd_002B;
bool Gb_002C;
double Gd_002C;
double Gd_002E;
double Gd_0014;
double Gd_0015;
double Gd_0016;
double Gd_0017;
double Gd_0018;
bool Gb_0019;
double Gd_0019;
double Gd_001F;
bool Gb_0021;
double Gd_001A;
double Gd_001B;
double Gd_001C;
double Gd_001D;
bool Gb_001E;
double Gd_001E;
double Gd_0020;
string Is_0018;
int Ii_0048;
long Il_0050;
int Ii_0058;
bool Ib_0078;
double Id_0148;
double Id_0150;
double Id_0158;
double Id_0180[];
double returned_double;
int Slippage;
int init()
{
   int Li_FFFC;
   
   Ii_0000 = 0;
   Is_0008 = "";
   Is_0018 = "TICK SETTINGS";
   Ii_0024 = 2;
   Ii_0028 = 30;
   Ii_002C = 0;
   Id_0030 = 3;
   Id_0038 = 0.5;
   Id_0040 = 7.5;
   Ii_0048 = 1;
   Ii_004C = 0;
   Il_0050 = 7346597700;
   Ii_0058 = 0;
   Id_0060 = 0;
   Id_0068 = 0;
   Id_0070 = 0;
   Ib_0078 = true;
   Ii_007C = 0;
   Ii_0080 = 0;
   Ii_0084 = 0;
   Ii_0088 = 0;
   Ii_008C = 0;
   Ii_0090 = 0;
   Ii_0094 = 0;
   Ii_0098 = 0;
   Ii_009C = 0;
   Ii_00A0 = 0;
   Id_00A8 = 0;
   Id_00B0 = 0;
   Id_00B8 = 0;
   Id_00C0 = 0;
   Id_00C8 = 0;
   Id_00D0 = 0;
   Id_00D8 = 0;
   Id_00E0 = 0;
   Id_00E8 = 0;
   Id_00F0 = 0;
   Id_00F8 = 0;
   Id_0100 = 0;
   Id_0108 = 0;
   Id_0110 = 0;
   Id_0118 = 0;
   Id_0120 = 0;
   Id_0128 = 0;
   Id_0130 = 0;
   Id_0138 = 0;
   Id_0140 = 0;
   Id_0148 = 0;
   Id_0150 = 0;
   Id_0158 = 0;
   Id_0160 = 0;
   Id_0168 = 0;
   Id_0170 = 0;
   Id_0178 = 0;
   Id_01B8 = 0;
   Id_01C0 = 0;

   
   if ((Id_0038 > Delta)) { 
   Delta = (Id_0038 + 0.1);
   } 
   if ((MaxTrailing > Id_0040)) { 
   Id_0040 = (MaxTrailing + 0.1);
   } 
   if ((Id_0030 < 1)) { 
   Id_0030 = 1;
   } 
   Ii_009C = 0;
   Id_01C0 = 0;
   Id_00F0 = Id_0068;
   Id_0100 = Id_0070;
   Id_0110 = Id_0060;
   Ii_00A0 = _Digits;
   Id_01B8 = _Point;
   Ii_0098 = AccountLeverage();
   Id_0140 = MarketInfo(_Symbol, MODE_LOTSTEP);
   Id_00B0 = MarketInfo(_Symbol, MODE_MAXLOT);
   Id_00B8 = MarketInfo(_Symbol, MODE_MINLOT);
   Id_00A8 = (MarketInfo(_Symbol, MODE_MARGINREQUIRED) * Id_00B8);
   Id_0130 = 0;
   Ii_0084 = (int)MarketInfo(_Symbol, MODE_STOPLEVEL);
   if (Ii_0084 > 0) { 
   Gi_0000 = Ii_0084 + 1;
   Id_0130 = (Gi_0000 * _Point);
   } 
   Id_0138 = 0;
   Ii_0088 = (int)MarketInfo(_Symbol, MODE_FREEZELEVEL);
   if (Ii_0088 > 0) { 
   Gi_0000 = Ii_0088 + 1;
   Id_0138 = (Gi_0000 * _Point);
   } 
   if (Ii_0084 > 0 || Ii_0088 > 0) { 
   
   Print("WARNING! Broker is not suitable, the stoplevel is greater than zero.");
   } 
   Id_00C8 = NormalizeDouble((Ask - Bid), Ii_00A0);
   Id_0120 = Id_00C8;
   if (Ii_0000 == 0) { 
   Ii_0080 = Ii_0028;
   } 
   else { 
   Ii_0080 = 3;
   } 
   ArrayResize(Id_0180, Ii_0080, 0);
   if (Ii_0080 != 0) { 
   Gi_0000 = Ii_0080;
   } 
   Id_0128 = NormalizeDouble((MaxSpread * _Point), Ii_00A0);
   if ((FixedLot > 0)) { 
   Gd_0001 = ceil((FixedLot / Id_0140));
   Id_00C0 = (Gd_0001 * Id_0140);
   } 
   else { 
   if ((Id_00A8 > 0)) { 
   Gd_0001 = Id_00B8;
   Gd_0002 = (((RiskPercent / 100) * AccountBalance()) * Id_00B8);
   Gd_0002 = NormalizeDouble((Gd_0002 / Id_00A8), 2);
   if (Gd_0002 >= Id_00B0) { 
   Gd_0003 = Id_00B0;
   } 
   else { 
   Gd_0003 = Gd_0002;
   } 
   if (Gd_0003 <= Gd_0001) { 
   Gd_0002 = Gd_0001;
   } 
   else { 
   Gd_0002 = Gd_0003;
   } 
   Id_00C0 = Gd_0002;
   }} 
   HideTestIndicators(true);
   Li_FFFC = 0;
   
   return Li_FFFC;
}

int start()
{
   int Li_FFF8;
   int Li_FFF4;
   int Li_FFF0;
   int Li_FFEC;
   int Li_FFE8;
   int Li_FFE4;
   int Li_FFE0;
   int Li_FFDC;
   int Li_FFD8;
   double Ld_FFD0;
   double Ld_FFC8;
   double Ld_FFC0;
   double Ld_FFB8;
   double Ld_FFB0;
   double Ld_FFA8;
   double Ld_FFA0;
   double Ld_FF98;
   double Ld_FF90;
   double Ld_FF88;
   double Ld_FF80;
   double Ld_FF78;
   double Ld_FF70;
   double Ld_FF68;
   double Ld_FF60;
   double Ld_FF58;
   double Ld_FF50;
   int Li_FF4C;
   int Li_FF48;
   int Li_FFFC;

   Ii_009C = Ii_009C + 1;
   if ((Id_01C0 == 0)) { 
   Gi_0000 = HistoryTotal() - 1;
   Gi_0001 = Gi_0000;
   if (Gi_0000 >= 0) { 
   do { 
   if (OrderSelect(Gi_0001, 0, 1) && (OrderProfit() != 0)) { 
   Gd_0000 = OrderClosePrice();
   if ((Gd_0000 != OrderOpenPrice()) && OrderSymbol() == _Symbol) { 
   Gd_0000 = OrderProfit();
   Gd_0002 = OrderClosePrice();
   Gd_0002 = fabs((Gd_0002 - OrderOpenPrice()));
   Id_01C0 = fabs((Gd_0000 / Gd_0002));
   Gd_0002 = -OrderCommission();
   Id_00D0 = (Gd_0002 / Id_01C0);
   break; 
   }} 
   Gi_0001 = Gi_0001 - 1;
   } while (Gi_0001 >= 0); 
   }} 
   double Ld_FF14[];
   ArrayResize(Ld_FF14, (Ii_0080 - 1), 0);
   ArrayCopy(Ld_FF14, Id_0180, 0, 1, (Ii_0080 - 1));
   ArrayResize(Ld_FF14, Ii_0080, 0);
   Gi_0002 = Ii_0080 - 1;
   Ld_FF14[Gi_0002] = NormalizeDouble((Ask - Bid), Ii_00A0);
   ArrayCopy(Id_0180, Ld_FF14, 0, 0, 0);
   returned_double = iMAOnArray(Id_0180, Ii_0080, Ii_0080, 0, 3, 0);
   Id_00C8 = returned_double;
   Gd_0003 = (Ii_004C * Id_01B8);
   Gd_0004 = (returned_double + Id_00D0);
   if (Gd_0004 <= Gd_0003) { 
   } 
   else { 
   Gd_0003 = Gd_0004;
   } 
   Id_0120 = Gd_0003;
   Gd_0003 = (Gd_0003 * Delta);
   if (Gd_0003 <= Id_0130) { 
   Gd_0005 = Id_0130;
   } 
   else { 
   Gd_0005 = Gd_0003;
   } 
   Id_0108 = Gd_0005;
   Gd_0005 = (Id_0120 * Id_0038);
   if (Gd_0005 <= Id_0138) { 
   Gd_0006 = Id_0138;
   } 
   else { 
   Gd_0006 = Gd_0005;
   } 
   Id_00E0 = Gd_0006;
   Id_00F8 = (Id_0120 * MaxTrailing);
   Id_00E8 = (Id_0120 * Id_0040);
   Id_0170 = (Id_0120 * MaxDistance);
   Id_0178 = (Gd_0006 / Id_0030);
   Gd_0006 = (Id_0120 * Stop);
   if (Gd_0006 <= Id_0130) { 
   Gd_0007 = Id_0130;
   } 
   else { 
   Gd_0007 = Gd_0006;
   } 
   Id_00D8 = Gd_0007;
   ArrayFree(Ld_FF14);
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Li_FFF0 = (int)TimeCurrent();
   Li_FFEC = 0;
   Li_FFE8 = 0;
   Li_FFE4 = 0;
   Li_FFE0 = 0;
   Li_FFDC = 0;
   Li_FFD8 = 0;
   Ld_FFD0 = 0;
   Ld_FFC8 = 0;
   Ld_FFC0 = 0;
   Ld_FFB8 = 0;
   Ld_FFB0 = 0;
   Ld_FFA8 = 0;
   Ld_FFA0 = 0;
   Ld_FF98 = 0;
   Ld_FF90 = 0;
   Ld_FFA0 = 0;
   Ld_FF88 = 0;
   Ld_FF80 = 0;
   Ld_FF78 = 0;
   Ld_FF70 = 0;
   Ld_FF68 = 0;
   Ld_FF60 = 0;
   Ld_FF58 = 99999;
   Ld_FF50 = 0;
   Li_FF4C = OrdersTotal() - 1;
   if (Li_FF4C >= 0) { 
   do { 
   Ii_007C = OrderSelect(Li_FF4C, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) { 
   Ld_FFC8 = OrderStopLoss();
   Ld_FFB8 = OrderOpenPrice();
   Ld_FFC0 = OrderTakeProfit();
   Li_FFF4 = OrderTicket();
   Ld_FFD0 = OrderLots();
   returned_i = OrderType();
   if (returned_i <= 5) { 
   if (returned_i == 4){
   
   Li_FFEC = Li_FFEC + 1;
   Li_FFDC = Li_FFDC + 1;
   }
   if (returned_i == 5){
   
   Li_FFE8 = Li_FFE8 + 1;
   Li_FFD8 = Li_FFD8 + 1;
   }
   if (returned_i == 0){
   
   Li_FFE4 = Li_FFE4 + 1;
   if (Ld_FFC8 == 0 || (Ld_FFC8 > 0 && Ld_FFC8 < Ld_FFB8)) {
   
   Li_FFDC = Li_FFDC + 1;
   }
   Id_0160 = Ld_FFC8;
   Gd_0007 = OrderOpenPrice();
   Ld_FF88 = ((Gd_0007 * OrderLots()) + Ld_FF88);
   Ld_FF80 = (Ld_FF80 + OrderLots());
   if ((OrderOpenPrice() < Ld_FF58)) {
   Ld_FF58 = OrderOpenPrice();
   }}
   if (returned_i == 1){
   
   Li_FFE0 = Li_FFE0 + 1;
   if (Ld_FFC8 == 0 || (Ld_FFC8 > 0 && Ld_FFC8 > Ld_FFB8)) {
   
   Li_FFD8 = Li_FFD8 + 1;
   }
   Id_0168 = Ld_FFC8;
   if ((OrderOpenPrice() > Ld_FF50)) { 
   Ld_FF50 = OrderOpenPrice();
   } 
   Gd_0007 = OrderOpenPrice();
   Ld_FF78 = ((Gd_0007 * OrderLots()) + Ld_FF78);
   Ld_FF70 = (Ld_FF70 + OrderLots());
   }}} 
   Li_FF4C = Li_FF4C - 1;
   } while (Li_FF4C >= 0); 
   } 
   if ((Ld_FF80 > 0)) { 
   Ld_FF68 = NormalizeDouble((Ld_FF88 / Ld_FF80), Ii_00A0);
   } 
   if ((Ld_FF70 > 0)) { 
   Ld_FF60 = NormalizeDouble((Ld_FF78 / Ld_FF70), Ii_00A0);
   } 
   Li_FF48 = OrdersTotal() - 1;
   if (Li_FF48 >= 0) { 
   do { 
   Ii_007C = OrderSelect(Li_FF48, 0, 0);
   if (OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber) { 
   Ld_FFC8 = OrderStopLoss();
   Ld_FFB8 = OrderOpenPrice();
   Ld_FFC0 = OrderTakeProfit();
   Li_FFF4 = OrderTicket();
   returned_i = OrderType();
   if (returned_i <= 5) { 
   if (returned_i == 4){
   
   if (Ii_0000 == 0) {
   Gb_0007 = (Id_0120 > Id_0128);
   if ((Hour() > StartHour && Hour() < EndHour)
   || Hour() == StartHour || Hour() == EndHour) {
   
   Gb_0007 = true;
   }
   else{
   Gb_0007 = false;
   }
   if (Id_0120 > Id_0128 || !Gb_0007) {
   
   Ii_007C = OrderDelete(Li_FFF4, 4294967295);
   }
   else{
   Gi_0008 = Li_FFF0 - Ii_008C;
   if (Gi_0008 > Secs
   || (Ii_009C % Ii_0024 == 0 && ((Li_FFE4 < 1 && (Ld_FFB8 - Ask) < Id_00E0) || Ld_FFB8 - Ask < Id_0178 || Ld_FFB8 - Ask > Id_0170))) {
   
   if (Li_FFE4 > 0) { 
   Gd_000A = (Id_0108 / Id_0030);
   if (Gd_000A <= Id_0130) { 
   Gd_000B = Id_0130;
   } 
   else { 
   Gd_000B = Gd_000A;
   } 
   Ld_FFB0 = NormalizeDouble((Ask + Gd_000B), Ii_00A0);
   Ld_FFA8 = Id_0160;
   } 
   else { 
   Gd_000C = Id_0108;
   if (Id_0108 <= Id_0130) { 
   Gd_000D = Id_0130;
   } 
   else { 
   Gd_000D = Gd_000C;
   } 
   Ld_FFB0 = NormalizeDouble((Ask + Gd_000D), Ii_00A0);
   Ld_FFA8 = NormalizeDouble((Ld_FFB0 - Id_00D8), Ii_00A0);
   } 
   if ((Li_FFE4 > 0 && Ld_FFB0 > Ld_FF68)
   || Li_FFE4 == 0) {
   
   if ((Ld_FFB0 != Ld_FFB8) && ((Ld_FFB8 - Ask) > Id_0138)) {
   Ii_007C = OrderModify(Li_FFF4, Ld_FFB0, Ld_FFA8, Ld_FFA0, 0, 4294967295);
   if (Ii_007C != 0) {
   Ii_008C = Li_FFF0;
   }}}}}}}
   if (returned_i == 5){
   
   if (Ii_0000 == 0) {
   Gb_000D = (Id_0120 > Id_0128);
   if ((Hour() > StartHour && Hour() < EndHour)
   || Hour() == StartHour || Hour() == EndHour) {
   
   Gb_000D = true;
   }
   else{
   Gb_000D = false;
   }
   if (Id_0120 > Id_0128 || !Gb_000D) {
   
   Ii_007C = OrderDelete(Li_FFF4, 4294967295);
   }
   else{
   Gi_000E = Li_FFF0 - Ii_0090;
   if (Gi_000E > Secs || (Ii_009C % Ii_0024 == 0 && ((Li_FFE0 < 1 && (Bid - Ld_FFB8) < Id_00E0) || Bid - Ld_FFB8 < Id_0178 || Bid - Ld_FFB8 > Id_0170))) {
   
   if (Li_FFE0 > 0) { 
   Gd_0010 = (Id_0108 / Id_0030);
   if (Gd_0010 <= Id_0130) { 
   Gd_0011 = Id_0130;
   } 
   else { 
   Gd_0011 = Gd_0010;
   } 
   Ld_FFB0 = NormalizeDouble((Bid - Gd_0011), Ii_00A0);
   Ld_FFA8 = Id_0168;
   } 
   else { 
   Gd_0012 = Id_0108;
   if (Id_0108 <= Id_0130) { 
   Gd_0013 = Id_0130;
   } 
   else { 
   Gd_0013 = Gd_0012;
   } 
   Ld_FFB0 = NormalizeDouble((Bid - Gd_0013), Ii_00A0);
   Ld_FFA8 = NormalizeDouble((Ld_FFB0 + Id_00D8), Ii_00A0);
   } 
   if ((Li_FFE0 > 0 && Ld_FFB0 < Ld_FF60) || Li_FFE0 == 0) {
   
   if ((Ld_FFB0 != Ld_FFB8) && ((Bid - Ld_FFB8) > Id_0138)) {
   Ii_007C = OrderModify(Li_FFF4, Ld_FFB0, Ld_FFA8, Ld_FFA0, 0, 4294967295);
   if (Ii_007C != 0) {
   Ii_0090 = Li_FFF0;
   }}}}}}}
   if (returned_i == 0){
   
   Gd_0013 = ((Bid - Ld_FFB8) + Id_00D0);
   if (Gd_0013 <= 0) { 
   Gd_0014 = 0;
   } 
   else { 
   Gd_0014 = Gd_0013;
   } 
   Ld_FF98 = Gd_0014;
   Gd_0013 = Id_0130;
   Gd_0015 = Id_00F8;
   Gd_0016 = Id_00F0;
   Gd_0017 = Id_00E8;
   Gd_0018 = 0;
   if ((Id_00E8 == 0)) { 
   Gd_0019 = Id_00F8;
   } 
   else { 
   Gd_001A = (Gd_0014 - Gd_0018);
   Gd_001A = (Gd_001A / (Gd_0017 - Gd_0018));
   Gd_001A = (((Gd_0015 - Gd_0016) * Gd_001A) + Gd_0016);
   Gd_001B = Gd_001A;
   Gd_001C = Gd_0015;
   Gd_001D = Gd_0016;
   if (Gd_0016 <= Gd_001A) { 
   } 
   else { 
   Gd_001A = Gd_001D;
   } 
   if (Gd_001A >= Gd_001C) { 
   Gd_001D = Gd_001C;
   } 
   else { 
   Gd_001D = Gd_001A;
   } 
   if ((Gd_0016 > Gd_0015)) { 
   Gd_001E = Gd_0015;
   Gd_001F = Gd_0016;
   if (Gd_0016 >= Gd_001B) { 
   Gd_0020 = Gd_001B;
   } 
   else { 
   Gd_0020 = Gd_001F;
   } 
   if (Gd_0020 <= Gd_001E) { 
   Gd_001F = Gd_001E;
   } 
   else { 
   Gd_001F = Gd_0020;
   } 
   Gd_001D = Gd_001F;
   } 
   Gd_0019 = Gd_001D;
   } 
   if (Gd_0019 <= Gd_0013) { 
   Gd_001F = Gd_0013;
   } 
   else { 
   Gd_001F = Gd_0019;
   } 
   Id_0118 = Gd_001F;
   Ld_FFA8 = NormalizeDouble((Bid - Gd_001F), Ii_00A0);
   Ld_FF90 = ((Ld_FFB8 + Id_00D0) + Id_0100);
   if (((Bid - Ld_FF90) > Gd_001F)) {
   if (Ld_FFC8 == 0 || ((Bid - Ld_FFC8) > Gd_001F)) {
   
   if ((Ld_FFA8 != Ld_FFC8)) {
   Ii_007C = OrderModify(Li_FFF4, Ld_FFB8, Ld_FFA8, Ld_FFC0, 0, 4294967295);
   }}}}
   if (returned_i == 1){
   
   Gd_0021 = ((Ld_FFB8 - Ask) - Id_00D0);
   if (Gd_0021 <= 0) { 
   Gd_0022 = 0;
   } 
   else { 
   Gd_0022 = Gd_0021;
   } 
   Ld_FF98 = Gd_0022;
   Gd_0021 = Id_0130;
   Gd_0023 = Id_00F8;
   Gd_0024 = Id_00F0;
   Gd_0025 = Id_00E8;
   Gd_0026 = 0;
   if ((Id_00E8 == 0)) { 
   Gd_0027 = Id_00F8;
   } 
   else { 
   Gd_0028 = (Gd_0022 - Gd_0026);
   Gd_0028 = (Gd_0028 / (Gd_0025 - Gd_0026));
   Gd_0028 = (((Gd_0023 - Gd_0024) * Gd_0028) + Gd_0024);
   Gd_0029 = Gd_0028;
   Gd_002A = Gd_0023;
   Gd_002B = Gd_0024;
   if (Gd_0024 <= Gd_0028) { 
   } 
   else { 
   Gd_0028 = Gd_002B;
   } 
   if (Gd_0028 >= Gd_002A) { 
   Gd_002B = Gd_002A;
   } 
   else { 
   Gd_002B = Gd_0028;
   } 
   if ((Gd_0024 > Gd_0023)) { 
   Gd_002C = Gd_0023;
   Gd_002D = Gd_0024;
   if (Gd_0024 >= Gd_0029) { 
   Gd_002E = Gd_0029;
   } 
   else { 
   Gd_002E = Gd_002D;
   } 
   if (Gd_002E <= Gd_002C) { 
   Gd_002D = Gd_002C;
   } 
   else { 
   Gd_002D = Gd_002E;
   } 
   Gd_002B = Gd_002D;
   } 
   Gd_0027 = Gd_002B;
   } 
   if (Gd_0027 <= Gd_0021) { 
   Gd_002D = Gd_0021;
   } 
   else { 
   Gd_002D = Gd_0027;
   } 
   Id_0118 = Gd_002D;
   Ld_FFA8 = NormalizeDouble((Ask + Gd_002D), Ii_00A0);
   Ld_FF90 = ((Ld_FFB8 - Id_00D0) - Id_0100);
   if (((Ld_FF90 - Ask) > Gd_002D)) { 
   if (Ld_FFC8 == 0 || ((Ld_FFC8 - Ask) > Gd_002D)) {
   
   if ((Ld_FFA8 != Ld_FFC8)) { 
   Ii_007C = OrderModify(Li_FFF4, Ld_FFB8, Ld_FFA8, Ld_FFC0, 0, 4294967295);
   }}}}}} 
   Li_FF48 = Li_FF48 - 1;
   } while (Li_FF48 >= 0); 
   } 
   if ((Id_0030 > 1 && Li_FFDC < 1) || Li_FFE4 < 1) {
   
   if (Li_FFEC < 1) { 
   Gb_002F = (Id_0120 <= Id_0128);
   if (Gb_002F) { 
   Gi_002F = Li_FFF0 - Ii_0094;
   if (Gi_002F > Ii_002C) { 
   if ((Hour() > StartHour && Hour() < EndHour)
   || Hour() == StartHour || Hour() == EndHour) {
   
   Gb_002F = true;
   }
   else{
   Gb_002F = false;
   }
   if (Gb_002F && Ii_0000 == 0) { 
   if ((FixedLot > 0)) { 
   Gd_0030 = ceil((FixedLot / Id_0140));
   Id_00C0 = (Gd_0030 * Id_0140);
   Gd_0030 = round((Id_00C0 / Id_0140));
   Gd_0030 = (Gd_0030 * Id_0140);
   } 
   else { 
   if ((Id_00A8 > 0)) { 
   Gd_0031 = Id_00B8;
   Gd_0032 = (((RiskPercent / 100) * AccountBalance()) * Id_00B8);
   Gd_0032 = NormalizeDouble((Gd_0032 / Id_00A8), 2);
   if (Gd_0032 >= Id_00B0) { 
   Gd_0033 = Id_00B0;
   } 
   else { 
   Gd_0033 = Gd_0032;
   } 
   if (Gd_0033 <= Gd_0031) { 
   Gd_0032 = Gd_0031;
   } 
   else { 
   Gd_0032 = Gd_0033;
   } 
   Id_00C0 = Gd_0032;
   } 
   Gd_0032 = round((Id_00C0 / Id_0140));
   Gd_0030 = (Gd_0032 * Id_0140);
   } 
   if (AccountFreeMarginCheck(_Symbol, 0, Gd_0030) <= 0 || GetLastError() == 134) {
   
   Li_FFFC = 0;
   return Li_FFFC;
   }
   Gd_0034 = Id_0108;
   if (Id_0108 <= Id_0130) { 
   Gd_0035 = Id_0130;
   } 
   else { 
   Gd_0035 = Gd_0034;
   } 
   Ld_FFB0 = NormalizeDouble((Ask + Gd_0035), Ii_00A0);
   if (Li_FFE4 > 0) { 
   Ld_FFA8 = Id_0160;
   } 
   else { 
   Ld_FFA8 = NormalizeDouble((Ld_FFB0 - Id_00D8), Ii_00A0);
   } 
   Li_FFF8 = OrderSend(_Symbol, 4, Id_00C0, Ld_FFB0, Slippage, Ld_FFA8, Ld_FFA0, Is_0008, MagicNumber, 0, 4294967295);
   if (Li_FFF8 != 0) { 
   Ii_008C = Li_FFF0;
   Ii_0094 = Li_FFF0;
   }}}}}} 
   if ((Id_0030 > 1 && Li_FFD8 < 1) || Li_FFE0 < 1) {
   
   if (Li_FFE8 < 1) { 
   Gb_0035 = (Id_0120 <= Id_0128);
   if (Gb_0035) { 
   Gi_0035 = Li_FFF0 - Ii_0094;
   if (Gi_0035 > Ii_002C) { 
   if ((Hour() > StartHour && Hour() < EndHour)
   || Hour() == StartHour || Hour() == EndHour) {
   
   Gb_0035 = true;
   }
   else{
   Gb_0035 = false;
   }
   if (Gb_0035 && Ii_0000 == 0) { 
   if ((FixedLot > 0)) { 
   Gd_0036 = ceil((FixedLot / Id_0140));
   Id_00C0 = (Gd_0036 * Id_0140);
   Gd_0036 = round((Id_00C0 / Id_0140));
   Gd_0036 = (Gd_0036 * Id_0140);
   } 
   else { 
   if ((Id_00A8 > 0)) { 
   Gd_0037 = Id_00B8;
   Gd_0038 = (((RiskPercent / 100) * AccountBalance()) * Id_00B8);
   Gd_0038 = NormalizeDouble((Gd_0038 / Id_00A8), 2);
   if (Gd_0038 >= Id_00B0) { 
   Gd_0039 = Id_00B0;
   } 
   else { 
   Gd_0039 = Gd_0038;
   } 
   if (Gd_0039 <= Gd_0037) { 
   Gd_0038 = Gd_0037;
   } 
   else { 
   Gd_0038 = Gd_0039;
   } 
   Id_00C0 = Gd_0038;
   } 
   Gd_0038 = round((Id_00C0 / Id_0140));
   Gd_0036 = (Gd_0038 * Id_0140);
   } 
   if (AccountFreeMarginCheck(_Symbol, 1, Gd_0036) <= 0 || GetLastError() == 134) {
   
   Li_FFFC = 0;
   return Li_FFFC;
   }
   Gd_003A = Id_0108;
   if (Id_0108 <= Id_0130) { 
   Gd_003B = Id_0130;
   } 
   else { 
   Gd_003B = Gd_003A;
   } 
   Ld_FFB0 = NormalizeDouble((Bid - Gd_003B), Ii_00A0);
   if (Li_FFE0 > 0) { 
   Ld_FFA8 = Id_0168;
   } 
   else { 
   Ld_FFA8 = NormalizeDouble((Ld_FFB0 + Id_00D8), Ii_00A0);
   } 
   Li_FFF8 = OrderSend(_Symbol, 5, Id_00C0, Ld_FFB0, Slippage, Ld_FFA8, Ld_FFA0, Is_0008, MagicNumber, 0, 4294967295);
   if (Li_FFF8 != 0) { 
   Ii_0090 = Li_FFF0;
   Ii_0094 = Li_FFF0;
   }}}}}} 
   ObjectsDeleteAll(-1, -1);
   Li_FFFC = 0;
   
   return Li_FFFC;
}



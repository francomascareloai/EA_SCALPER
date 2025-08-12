#property copyright "Copyright 2023, Prop Firm EA / Galaxy Profit ";
#property link "www.galaxyprofit.co.uk";
#property version "VIP";
#property strict
#property description "Prop Firm EA";

#import "stdlib.ex4"

string ErrorDescription(int);
bool CompareDoubles(double,double);

#import

enum SG
{
   Trend = 1, // Prop Firm Challenge
   Trend1 = 2, // Real Prop Account
   Trend2 = 3 // Fast Scalper
};

extern SG Strategy = Trend; // Trading Strategy
extern string EAComment = "SpaceX_Prop_EA"; // Galaxy Profit
extern ENUM_TIMEFRAMES TimeFrame = PERIOD_M15;
extern string CloseAtPipsProfits = "Prop Phase Target 10%"; // Prop Firm Target
extern bool UseCloseAtPipsProfits = true; // Challenge Prop Mode
extern bool Martingale1; // Pitchfan Mode
extern double FixedLots = 0.01; // Fixed Lot Size
extern double MaxSpread = 35; // Elliott Triple Combo Wawe (WXYXZ)
extern int Delta2 = 300; // Three Drives Pattern
extern bool UseGrid = true; // Pass Prop Firm Mode
extern bool Martingale2; // Gann Square Fixed
extern string ClosePercentLoss = " Max Drawdown Limit "; // Max Drawdown
extern bool CloseAtPercentLoss; // Forced Exit Mode
extern double PercentLoss = 5; // Forced Exit %
extern int MA2Period = 89; // XABCD Pattern
extern int Slippage = 1; // Elliott Double Combo Wave (WXY)
extern string Trade_Parameters = "Pass Challenge"; // Prop Settings
extern double StopLoss; // Stop Loss
extern double TakeProfit; // Take Profit
extern double GridPips = 25; // Recovery
extern bool ECN_Acc = true; // All Broker
extern bool SpreadAlert; // Spread Alert
extern int MagicNumber = 123; // Magic Number
extern int MaxOpenOrders = 10; // Max Open Trade Allowed
extern bool ShowInfo = true; // Show info
extern int MA1Period = 49; // Fib Speed Resistance Fan
extern string TrailingStop = " Trailing Stop "; // Trailing Stop Settings
extern bool UseTrailingStop; // Use Trailing Stop
extern double TrailingStopStart = 30; // Trailing Stop Start
extern double TrailingStopStep = 15; // Trailing Stop Step
extern int PipsProfit = 50; // Prop Daily Pips
extern string MM_Parameters = " Prop Money Management "; // Prop Money Management.
extern double MultiplierLot = 2; // Lot Multiplier
extern bool LotIncrease; // Lot Increase
extern double Increase = 0.01; // Increase
extern double BalansStep = 1000; // Balance Step
extern int Delta1 = 200; // Elliot impulse Wawe
extern string Time_Filter = "Trade Time"; // Trade Time Settings
extern bool EnableTimer; // Trade Time (Server Time)
extern string TimerStart = "00:15:00"; // Time Start
extern string TimerEnd = "09:00:00"; // Time End
extern string _News = "Avoid News Time";
extern bool AvoidNews = true; // Avoid News
extern int UTimeDo = 30; // News Time Before
extern int UTimePosle = 30; // News Time After
extern int Uoffset = 3; // Offset
extern bool Vhigh = true; // High
extern bool Vmedium; // Medium
extern bool Vlow; // Low

class SMBIOS
{
   public:
};


bool returned_b;
bool Ib_002B2;
bool Ib_002B4;
int Ii_0083C;
int Ii_00840;
int Ii_00844;
int Ii_00848;
int Ii_0084C;
int Ii_00850;
int Ii_00854;
int Ii_00858;
int Ii_0085C;
int Ii_00860;
int Ii_00864;
int Ii_00868;
string Is_00870;
int Ii_0087C;
int Ii_00880;
int Ii_00884;
int Ii_00888;
int Ii_00278;
bool Ib_003B4;
string Is_00410;
int Ii_003E0;
double Id_00428;
bool Ib_0088C;
string Is_00890;
bool Ib_0089C;
int Ii_008A0;
string Is_008A8;
bool Ib_008B4;
double Id_008B8;
bool Ib_002B1;
bool Ib_002B3;
double Id_001F8;
double Id_008C0;
int Ii_001E4;
int Ii_00204;
string Is_00210;
long Il_008C8;
int Ii_008D0;
bool Ib_0023C;
string Is_00230;
string Is_00240;
long Il_008D8;
bool Ib_00198;
int Ii_000F8;
int Ii_000F4;
int Ii_00144;
int Ii_0013C;
int Ii_00140;
int Ii_0018C;
string Is_000E8;
string Is_00100;
string Is_00110;
string Is_00120;
string Is_00130;
string Is_00180;
string Is_00160;
string Is_00170;
string Is_00148;
double Id_00398;
double Id_003A8;
double Id_008E0;
bool Ib_00272;
int Ii_008E8;
int Ii_008EC;
int Ii_008F0;
int Ii_008F4;
int Ii_0019C;
int Gi_00000;
int Ii_001A4;
long Gl_00001;
int Ii_001B0;
int Ii_001B4;
int Ii_001C0;
int Ii_001C4;
int returned_i;
int Ii_001CC;
long returned_l;
long Il_001D0;
int Ii_001D8;
int Ii_001DC;
int Ii_001E0;
double Ind_004;
double Ind_000;
bool Gb_00001;
int Ii_00208;
double Gd_00001;
int Ii_001A0;
long Gl_00000;
bool Ib_00258;
long Il_00260;
bool Ib_00270;
bool Ib_00200;
bool Ib_00271;
double Gd_00003;
double Id_010A0;
bool Ib_00273;
bool Ib_00274;
double Id_00280;
double Id_00288;
bool Ib_00290;
bool Ib_00291;
double Id_00298;
bool Ib_002A1;
bool Ib_002A2;
double Id_002A8;
bool Ib_002B0;
int Ii_002B8;
double Id_002C0;
double Id_002C8;
double Id_002D0;
int Ii_002D8;
int Ii_002DC;
int Ii_002E0;
int Ii_002E4;
int Ii_002E8;
double Id_002F0;
int Ii_002F8;
double Id_00300;
double Id_00308;
double Id_00310;
int Ii_00318;
int Ii_0031C;
int Ii_00320;
int Ii_00324;
int Ii_00328;
double Id_00330;
int Ii_00338;
int Ii_0033C;
int Ii_00340;
int Ii_00344;
int Ii_00348;
int Ii_0034C;
int Ii_00350;
int Ii_00354;
int Ii_00358;
int Ii_0035C;
int Ii_00360;
bool Ib_00364;
int Ii_00368;
int Ii_0036C;
long Il_00370;
bool Ib_00378;
int Ii_0037C;
int Ii_00380;
long Il_00388;
double Id_00390;
double Id_003A0;
int Gi_00003;
bool Ib_003B5;
int Ii_003B8;
int Ii_003BC;
long Il_003C0;
bool Ib_003C8;
int Ii_003CC;
int Ii_003D0;
long Il_003D8;
double Id_003E8;
double Id_003F0;
double Id_00420;
double Id_00430;
double Id_00450;
int Ii_00460;
int Ii_00464;
int Ii_00468;
int Ii_0046C;
int Ii_00470;
int Ii_00474;
int Ii_00478;
int Ii_0047C;
int Ii_00480;
int Ii_00484;
int Ii_00488;
bool Ib_0048C;
int Ii_00490;
int Ii_00494;
long Il_00498;
bool Ib_004A0;
int Ii_004A4;
int Ii_004A8;
long Il_004B0;
double Id_004B8;
bool Ib_004C4;
int Ii_004C8;
int Ii_004CC;
long Il_004D0;
bool Ib_004D8;
int Ii_004DC;
int Ii_004E0;
long Il_004E8;
double Id_004F0;
double Id_00510;
double Id_00518;
double Id_00520;
double Id_00540;
double Id_00548;
bool Gb_00003;
int Ii_00554;
int Ii_00558;
int Ii_0055C;
int Ii_00560;
int Ii_00564;
int Ii_00568;
int Ii_0056C;
int Ii_00570;
int Ii_00574;
int Ii_00578;
bool Ib_0057C;
int Ii_00580;
int Ii_00584;
long Il_00588;
bool Ib_00590;
int Ii_00594;
int Ii_00598;
long Il_005A0;
double Id_005A8;
double Id_005B0;
bool Ib_005BC;
int Ii_005C0;
int Ii_005C4;
long Il_005C8;
bool Ib_005D0;
int Ii_005D4;
int Ii_005D8;
long Il_005E0;
double Id_005E8;
double Id_005F0;
double Id_00610;
double Id_00618;
double Id_00638;
int Ii_0064C;
int Ii_00650;
int Ii_00654;
int Ii_00658;
int Ii_0065C;
int Ii_00660;
int Ii_00664;
int Ii_0066C;
int Ii_00670;
int Ii_00674;
bool Ib_00678;
int Ii_0067C;
int Ii_00680;
long Il_00688;
bool Ib_00690;
int Ii_00694;
int Ii_00698;
long Il_006A0;
double Id_006A8;
bool Ib_006B4;
int Ii_006B8;
int Ii_006BC;
long Il_006C0;
bool Ib_006C8;
int Ii_006CC;
int Ii_006D0;
long Il_006D8;
double Id_006E0;
double Id_00700;
double Id_00708;
double Id_00710;
double Id_00730;
bool Ib_00740;
string Is_00748;
double Id_00758;
double Id_00760;
double Id_00768;
double Id_00770;
double Id_00778;
double Id_00780;
double Id_00788;
double Id_00790;
double Id_00798;
double Id_007A0;
double Id_007A8;
double Id_007B0;
double Id_007B8;
double Id_007C0;
double Id_007C8;
double Id_007D0;
double Id_007D8;
double Id_007E0;
double Id_007E8;
double Id_007F0;
double Id_007F8;
double Id_00800;
long Gl_00003;
int Gi_00001;
int Gi_00002;
long Gl_00002;
string Gs_00000;
int Ii_0015C;
string Is_00000;
string Is_00010;
string Is_00020;
long Il_00030;
short Ist_00038;
short Ist_0003A;
string Is_00088;
string Is_00098;
string Is_000A8;
string Is_000B8;
string Is_000C8;
string Is_000D8;
bool Ib_00154;
bool Ib_00155;
int Ii_00158;
long Il_00190;
bool Ib_00199;
long Il_001A8;
long Il_001B8;
int Ii_001C8;
double Id_001E8;
double Id_001F0;
double Id_00220;
long Il_00228;
long Il_00250;
long Il_00268;
bool Ib_002A0;
int Ii_003B0;
int Ii_003F8;
double Id_00400;
int Ii_00408;
int Ii_00438;
double Id_00440;
int Ii_00448;
double Id_00458;
int Ii_004C0;
int Ii_004F8;
double Id_00500;
int Ii_00508;
int Ii_00528;
double Id_00530;
int Ii_00538;
bool Ib_00550;
int Ii_005B8;
int Ii_005F8;
double Id_00600;
int Ii_00608;
int Ii_00620;
double Id_00628;
int Ii_00630;
double Id_00640;
bool Ib_00648;
bool Ib_00668;
int Ii_006B0;
int Ii_006E8;
double Id_006F0;
int Ii_006F8;
int Ii_00718;
double Id_00720;
int Ii_00728;
double Id_00738;
long Il_00808;
long Il_00810;
long Il_00818;
string Is_00820;
string Is_00830;
bool Ib_008F8;
int Ii_008FC;
int Ii_00900;
int Ii_00904;
int Ii_00908;
int Ii_0090C;
int Ii_00910;
bool Ib_00914;
int Ii_00918;
int Ii_0091C;
int Ii_00920;
int Ii_00924;
int Ii_00928;
int Ii_0092C;
int Ii_00930;
bool Ib_00934;
bool Ib_00935;
double Id_00938;
int Ii_00940;
int Ii_00944;
int Ii_00948;
bool Ib_0094C;
double Id_00950;
bool Ib_00958;
double Id_00960;
bool Ib_00968;
double Id_00970;
int Ii_00978;
double Id_00980;
int Ii_00988;
int Ii_0098C;
bool Ib_00990;
int Ii_00994;
double Id_00998;
int Ii_009A0;
double Id_009A8;
bool Ib_009B0;
int Ii_009B4;
int Ii_009B8;
int Ii_009BC;
int Ii_009C0;
int Ii_009C4;
bool Ib_009C8;
double Id_009D0;
double Id_009D8;
double Id_009E0;
bool Ib_009E8;
double Id_009F0;
double Id_009F8;
double Id_00A00;
int Ii_00A08;
int Ii_00A0C;
bool Ib_00A10;
double Id_00A18;
int Ii_00A20;
int Ii_00A24;
bool Ib_00A28;
int Ii_00A2C;
int Ii_00A30;
double Id_00A38;
double Id_00A40;
bool Ib_00A48;
int Ii_00A4C;
bool Ib_00A50;
double Id_00A58;
double Id_00A60;
double Id_00A68;
bool Ib_00A70;
double Id_00A78;
int Ii_00A80;
double Id_00A88;
int Ii_00A90;
int Ii_00A94;
int Ii_00A98;
int Ii_00A9C;
int Ii_00AA0;
int Ii_00AA4;
double Id_00AA8;
double Id_00AB0;
double Id_00AB8;
bool Ib_00AC0;
double Id_00AC8;
double Id_00AD0;
bool Ib_00AD8;
double Id_00AE0;
double Id_00AE8;
double Id_00AF0;
double Id_00AF8;
double Id_00B00;
double Id_00B08;
double Id_00B10;
double Id_00B18;
double Id_00B20;
double Id_00B28;
double Id_00B30;
double Id_00B38;
double Id_00B40;
double Id_00B48;
bool Ib_00B50;
bool Ib_00B51;
double Id_00B58;
double Id_00B60;
double Id_00B68;
double Id_00B70;
string Is_00B78;
double Id_00B88;
string Is_00B90;
string Is_00BA0;
string Is_00BB0;
string Is_00BC0;
string Is_00BD0;
string Is_00BE0;
string Is_00BF0;
string Is_00C00;
string Is_00C10;
string Is_00C20;
string Is_00C30;
string Is_00C40;
string Is_00C50;
string Is_00C60;
string Is_00C70;
string Is_00C80;
string Is_00C90;
long Il_00CA0;
string Is_00CA8;
double Id_00CB8;
long Il_00CC0;
bool Ib_00CC8;
long Il_00CD0;
long Il_00CD8;
long Il_00CE0;
bool Ib_00CE8;
bool Ib_00CE9;
char Ic_00CEA;
char Ic_00CEB;
char Ic_00CEC;
char Ic_00CED;
char Ic_00CEE;
long Il_00CF0;
long Il_00CF8;
short Ist_00D00;
short Ist_00D02;
string Is_00D08;
string Is_00D18;
bool Ib_00D24;
bool Ib_00D25;
long Il_00D28;
bool Ib_00D30;
long Il_00D38;
string Is_00D40;
string Is_00D50;
long Il_00D60;
long Il_00D68;
long Il_00D70;
char Ic_00D78;
char Ic_00D79;
char Ic_00D7A;
char Ic_00D7B;
char Ic_00D7C;
char Ic_00D7D;
char Ic_00D7E;
char Ic_00D7F;
char Ic_00D80;
char Ic_00D81;
char Ic_00D82;
char Ic_00D83;
char Ic_00D84;
char Ic_00D85;
char Ic_00D86;
char Ic_00D87;
char Ic_00D88;
char Ic_00D89;
char Ic_00D8A;
char Ic_00D8B;
char Ic_00D8C;
char Ic_00D8D;
char Ic_0108C;
string Is_010A8;
double Gd_00000;
short returned_st;
short Gst_00000;
string Gs_00001;
string Gs_00002;
string Gs_00003;
double Gd_00004;
double Gd_00005;
int Gi_00004;
string Gs_00004;
bool Gb_00000;
bool Gb_00002;
double Gd_00002;
bool Gb_00004;
double Ind_002;
int Gi_00005;
string Gs_00005;
int Gi_00006;
string Gs_00006;
int Gi_00007;
string Gs_00007;
int Gi_00008;
string Gs_00008;
int Gi_00009;
string Gs_00009;
int Gi_0000A;
string Gs_0000A;
double Gd_0000B;
int Gi_0000B;
string Gs_0000B;
int Gi_0000C;
string Gs_0000C;
int Gi_0000D;
string Gs_0000D;
int Gi_0000E;
string Gs_0000E;
int Gi_0000F;
string Gs_0000F;
int Gi_00010;
string Gs_00010;
int Gi_00011;
string Gs_00011;
long Gl_00012;
int Gi_00012;
string Gs_00012;
double Ind_003;
string Is_0003C[];
int Ii_00DC4[100];
string Is_00F54[];
double Id_00F88[];
double Id_00FBC[];
double Id_00FF0[];
double Id_01024[];
long Il_01058[];
double returned_double;

int init()
{
   int Li_FFFFC;
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   int Li_FFFBC;
   int Li_FFFB8;
   int Li_FFFB4;
   int Li_FFFB0;
   int Li_FFFAC;
   int Li_FFFA8;
   int Li_FFFA4;
   int Li_FFFA0;
   string Ls_FFF90;
   int Li_FFF8C;
   int Li_FFF88;
   int Li_FFF84;
   int Li_FFF80;
   int Li_FFF7C;
   int Li_FFF78;
   int Li_FFF74;
   string Ls_FFF68;

   
   Is_00000 = "";
   Is_00010 = "";
   Is_00020 = "";
   Il_00030 = 0;
   Ist_00038 = 0;
   Ist_0003A = 0;
   Is_00088 = "SpaceX_Prop_EA";
   Is_00098 = "4";
   Is_000A8 = "support@galaxyprofit.co.uk";
   Is_000B8 = "Activate your account number! ";
   Is_000C8 = "Expired by date: ";
   Is_000D8 = "Wrong EA file name! ";
   Ii_000F4 = 0;
   Ii_000F8 = 0;
   Ii_0013C = 0;
   Ii_00140 = 0;
   Ii_00144 = 0;
   Ib_00154 = false;
   Ib_00155 = false;
   Ii_00158 = 0;
   Ii_0015C = 0;
   Ii_0018C = 0;
   Il_00190 = 0;
   Ib_00198 = false;
   Ib_00199 = false;
   Ii_0019C = 0;
   Ii_001A0 = 0;
   Ii_001A4 = 0;
   Il_001A8 = 0;
   Ii_001B0 = 0;
   Ii_001B4 = 0;
   Il_001B8 = 0;
   Ii_001C0 = 0;
   Ii_001C4 = 0;
   Ii_001C8 = 0;
   Ii_001CC = 0;
   Il_001D0 = 0;
   Ii_001D8 = 0;
   Ii_001DC = 0;
   Ii_001E0 = 0;
   Ii_001E4 = 0;
   Id_001E8 = 0;
   Id_001F0 = 0;
   Id_001F8 = 0;
   Ib_00200 = false;
   Ii_00204 = 0;
   Ii_00208 = 0;
   Id_00220 = 0;
   Il_00228 = 0;
   Ib_0023C = false;
   Il_00250 = 0;
   Ib_00258 = false;
   Il_00260 = 0;
   Il_00268 = 0;
   Ib_00270 = false;
   Ib_00271 = false;
   Ib_00272 = false;
   Ib_00273 = false;
   Ib_00274 = false;
   Ii_00278 = 0;
   Id_00280 = 0;
   Id_00288 = 0;
   Ib_00290 = false;
   Ib_00291 = false;
   Id_00298 = 0;
   Ib_002A0 = false;
   Ib_002A1 = false;
   Ib_002A2 = false;
   Id_002A8 = 0;
   Ib_002B0 = false;
   Ib_002B1 = false;
   Ib_002B2 = false;
   Ib_002B3 = false;
   Ib_002B4 = false;
   Ii_002B8 = 0;
   Id_002C0 = 0;
   Id_002C8 = 0;
   Id_002D0 = 0;
   Ii_002D8 = 0;
   Ii_002DC = 0;
   Ii_002E0 = 0;
   Ii_002E4 = 0;
   Ii_002E8 = 0;
   Id_002F0 = 0;
   Ii_002F8 = 0;
   Id_00300 = 0;
   Id_00308 = 0;
   Id_00310 = 0;
   Ii_00318 = 0;
   Ii_0031C = 0;
   Ii_00320 = 0;
   Ii_00324 = 0;
   Ii_00328 = 0;
   Id_00330 = 0;
   Ii_00338 = 0;
   Ii_0033C = 0;
   Ii_00340 = 0;
   Ii_00344 = 0;
   Ii_00348 = 0;
   Ii_0034C = 0;
   Ii_00350 = 0;
   Ii_00354 = 0;
   Ii_00358 = 0;
   Ii_0035C = 0;
   Ii_00360 = 0;
   Ib_00364 = false;
   Ii_00368 = 0;
   Ii_0036C = 0;
   Il_00370 = 0;
   Ib_00378 = false;
   Ii_0037C = 0;
   Ii_00380 = 0;
   Il_00388 = 0;
   Id_00390 = 0;
   Id_00398 = 0;
   Id_003A0 = 0;
   Id_003A8 = 0;
   Ii_003B0 = 0;
   Ib_003B4 = false;
   Ib_003B5 = false;
   Ii_003B8 = 0;
   Ii_003BC = 0;
   Il_003C0 = 0;
   Ib_003C8 = false;
   Ii_003CC = 0;
   Ii_003D0 = 0;
   Il_003D8 = 0;
   Ii_003E0 = 0;
   Id_003E8 = 0;
   Id_003F0 = 0;
   Ii_003F8 = 0;
   Id_00400 = 0;
   Ii_00408 = 0;
   Id_00420 = 0;
   Id_00428 = 0;
   Id_00430 = 0;
   Ii_00438 = 0;
   Id_00440 = 0;
   Ii_00448 = 0;
   Id_00450 = 0;
   Id_00458 = 0;
   Ii_00460 = 0;
   Ii_00464 = 0;
   Ii_00468 = 0;
   Ii_0046C = 0;
   Ii_00470 = 0;
   Ii_00474 = 0;
   Ii_00478 = 0;
   Ii_0047C = 0;
   Ii_00480 = 0;
   Ii_00484 = 0;
   Ii_00488 = 0;
   Ib_0048C = false;
   Ii_00490 = 0;
   Ii_00494 = 0;
   Il_00498 = 0;
   Ib_004A0 = false;
   Ii_004A4 = 0;
   Ii_004A8 = 0;
   Il_004B0 = 0;
   Id_004B8 = 0;
   Ii_004C0 = 0;
   Ib_004C4 = false;
   Ii_004C8 = 0;
   Ii_004CC = 0;
   Il_004D0 = 0;
   Ib_004D8 = false;
   Ii_004DC = 0;
   Ii_004E0 = 0;
   Il_004E8 = 0;
   Id_004F0 = 0;
   Ii_004F8 = 0;
   Id_00500 = 0;
   Ii_00508 = 0;
   Id_00510 = 0;
   Id_00518 = 0;
   Id_00520 = 0;
   Ii_00528 = 0;
   Id_00530 = 0;
   Ii_00538 = 0;
   Id_00540 = 0;
   Id_00548 = 0;
   Ib_00550 = false;
   Ii_00554 = 0;
   Ii_00558 = 0;
   Ii_0055C = 0;
   Ii_00560 = 0;
   Ii_00564 = 0;
   Ii_00568 = 0;
   Ii_0056C = 0;
   Ii_00570 = 0;
   Ii_00574 = 0;
   Ii_00578 = 0;
   Ib_0057C = false;
   Ii_00580 = 0;
   Ii_00584 = 0;
   Il_00588 = 0;
   Ib_00590 = false;
   Ii_00594 = 0;
   Ii_00598 = 0;
   Il_005A0 = 0;
   Id_005A8 = 0;
   Id_005B0 = 0;
   Ii_005B8 = 0;
   Ib_005BC = false;
   Ii_005C0 = 0;
   Ii_005C4 = 0;
   Il_005C8 = 0;
   Ib_005D0 = false;
   Ii_005D4 = 0;
   Ii_005D8 = 0;
   Il_005E0 = 0;
   Id_005E8 = 0;
   Id_005F0 = 0;
   Ii_005F8 = 0;
   Id_00600 = 0;
   Ii_00608 = 0;
   Id_00610 = 0;
   Id_00618 = 0;
   Ii_00620 = 0;
   Id_00628 = 0;
   Ii_00630 = 0;
   Id_00638 = 0;
   Id_00640 = 0;
   Ib_00648 = false;
   Ii_0064C = 0;
   Ii_00650 = 0;
   Ii_00654 = 0;
   Ii_00658 = 0;
   Ii_0065C = 0;
   Ii_00660 = 0;
   Ii_00664 = 0;
   Ib_00668 = false;
   Ii_0066C = 0;
   Ii_00670 = 0;
   Ii_00674 = 0;
   Ib_00678 = false;
   Ii_0067C = 0;
   Ii_00680 = 0;
   Il_00688 = 0;
   Ib_00690 = false;
   Ii_00694 = 0;
   Ii_00698 = 0;
   Il_006A0 = 0;
   Id_006A8 = 0;
   Ii_006B0 = 0;
   Ib_006B4 = false;
   Ii_006B8 = 0;
   Ii_006BC = 0;
   Il_006C0 = 0;
   Ib_006C8 = false;
   Ii_006CC = 0;
   Ii_006D0 = 0;
   Il_006D8 = 0;
   Id_006E0 = 0;
   Ii_006E8 = 0;
   Id_006F0 = 0;
   Ii_006F8 = 0;
   Id_00700 = 0;
   Id_00708 = 0;
   Id_00710 = 0;
   Ii_00718 = 0;
   Id_00720 = 0;
   Ii_00728 = 0;
   Id_00730 = 0;
   Id_00738 = 0;
   Ib_00740 = false;
   Id_00758 = 0;
   Id_00760 = 0;
   Id_00768 = 0;
   Id_00770 = 0;
   Id_00778 = 0;
   Id_00780 = 0;
   Id_00788 = 0;
   Id_00790 = 0;
   Id_00798 = 0;
   Id_007A0 = 0;
   Id_007A8 = 0;
   Id_007B0 = 0;
   Id_007B8 = 0;
   Id_007C0 = 0;
   Id_007C8 = 0;
   Id_007D0 = 0;
   Id_007D8 = 0;
   Id_007E0 = 0;
   Id_007E8 = 0;
   Id_007F0 = 0;
   Id_007F8 = 0;
   Id_00800 = 0;
   Il_00808 = 0;
   Il_00810 = 0;
   Il_00818 = 0;
   Ii_0083C = 0;
   Ii_00840 = 0;
   Ii_00844 = 0;
   Ii_00848 = 0;
   Ii_0084C = 0;
   Ii_00850 = 0;
   Ii_00854 = 0;
   Ii_00858 = 0;
   Ii_0085C = 0;
   Ii_00860 = 0;
   Ii_00864 = 0;
   Ii_00868 = 0;
   Ii_0087C = 0;
   Ii_00880 = 0;
   Ii_00884 = 0;
   Ii_00888 = 0;
   Ib_0088C = false;
   Ib_0089C = false;
   Ii_008A0 = 0;
   Ib_008B4 = false;
   Id_008B8 = 0;
   Id_008C0 = 0;
   Il_008C8 = 0;
   Ii_008D0 = 0;
   Il_008D8 = 0;
   Id_008E0 = 0;
   Ii_008E8 = 0;
   Ii_008EC = 0;
   Ii_008F0 = 0;
   Ii_008F4 = 0;
   Ib_008F8 = false;
   Ii_008FC = 0;
   Ii_00900 = 0;
   Ii_00904 = 0;
   Ii_00908 = 0;
   Ii_0090C = 0;
   Ii_00910 = 0;
   Ib_00914 = false;
   Ii_00918 = 0;
   Ii_0091C = 0;
   Ii_00920 = 0;
   Ii_00924 = 0;
   Ii_00928 = 0;
   Ii_0092C = 0;
   Ii_00930 = 0;
   Ib_00934 = false;
   Ib_00935 = false;
   Id_00938 = 0;
   Ii_00940 = 0;
   Ii_00944 = 0;
   Ii_00948 = 0;
   Ib_0094C = false;
   Id_00950 = 0;
   Ib_00958 = false;
   Id_00960 = 0;
   Ib_00968 = false;
   Id_00970 = 0;
   Ii_00978 = 0;
   Id_00980 = 0;
   Ii_00988 = 0;
   Ii_0098C = 0;
   Ib_00990 = false;
   Ii_00994 = 0;
   Id_00998 = 0;
   Ii_009A0 = 0;
   Id_009A8 = 0;
   Ib_009B0 = false;
   Ii_009B4 = 0;
   Ii_009B8 = 0;
   Ii_009BC = 0;
   Ii_009C0 = 0;
   Ii_009C4 = 0;
   Ib_009C8 = false;
   Id_009D0 = 0;
   Id_009D8 = 0;
   Id_009E0 = 0;
   Ib_009E8 = false;
   Id_009F0 = 0;
   Id_009F8 = 0;
   Id_00A00 = 0;
   Ii_00A08 = 0;
   Ii_00A0C = 0;
   Ib_00A10 = false;
   Id_00A18 = 0;
   Ii_00A20 = 0;
   Ii_00A24 = 0;
   Ib_00A28 = false;
   Ii_00A2C = 0;
   Ii_00A30 = 0;
   Id_00A38 = 0;
   Id_00A40 = 0;
   Ib_00A48 = false;
   Ii_00A4C = 0;
   Ib_00A50 = false;
   Id_00A58 = 0;
   Id_00A60 = 0;
   Id_00A68 = 0;
   Ib_00A70 = false;
   Id_00A78 = 0;
   Ii_00A80 = 0;
   Id_00A88 = 0;
   Ii_00A90 = 0;
   Ii_00A94 = 0;
   Ii_00A98 = 0;
   Ii_00A9C = 0;
   Ii_00AA0 = 0;
   Ii_00AA4 = 0;
   Id_00AA8 = 0;
   Id_00AB0 = 0;
   Id_00AB8 = 0;
   Ib_00AC0 = false;
   Id_00AC8 = 0;
   Id_00AD0 = 0;
   Ib_00AD8 = false;
   Id_00AE0 = 0;
   Id_00AE8 = 0;
   Id_00AF0 = 0;
   Id_00AF8 = 0;
   Id_00B00 = 0;
   Id_00B08 = 0;
   Id_00B10 = 0;
   Id_00B18 = 0;
   Id_00B20 = 0;
   Id_00B28 = 0;
   Id_00B30 = 0;
   Id_00B38 = 0;
   Id_00B40 = 0;
   Id_00B48 = 0;
   Ib_00B50 = false;
   Ib_00B51 = false;
   Id_00B58 = 0;
   Id_00B60 = 0;
   Id_00B68 = 0;
   Id_00B70 = 0;
   Id_00B88 = 0;
   Il_00CA0 = 0;
   Id_00CB8 = 0;
   Il_00CC0 = 0;
   Ib_00CC8 = false;
   Il_00CD0 = 0;
   Il_00CD8 = 0;
   Il_00CE0 = 0;
   Ib_00CE8 = false;
   Ib_00CE9 = false;
   Ic_00CEA = ' ';
   Ic_00CEB = ' ';
   Ic_00CEC = ' ';
   Ic_00CED = ' ';
   Ic_00CEE = ' ';
   Il_00CF0 = 0;
   Il_00CF8 = 0;
   Ist_00D00 = 0;
   Ist_00D02 = 0;
   Ib_00D24 = false;
   Ib_00D25 = false;
   Il_00D28 = 0;
   Ib_00D30 = false;
   Il_00D38 = 0;
   Il_00D60 = 0;
   Il_00D68 = 0;
   Il_00D70 = 0;
   Ic_00D78 = ' ';
   Ic_00D79 = ' ';
   Ic_00D7A = ' ';
   Ic_00D7B = ' ';
   Ic_00D7C = ' ';
   Ic_00D7D = ' ';
   Ic_00D7E = ' ';
   Ic_00D7F = ' ';
   Ic_00D80 = ' ';
   Ic_00D81 = ' ';
   Ic_00D82 = ' ';
   Ic_00D83 = ' ';
   Ic_00D84 = ' ';
   Ic_00D85 = ' ';
   Ic_00D86 = ' ';
   Ic_00D87 = ' ';
   Ic_00D88 = ' ';
   Ic_00D89 = ' ';
   Ic_00D8A = ' ';
   Ic_00D8B = ' ';
   Ic_00D8C = ' ';
   Ic_00D8D = ' ';
   Ic_0108C = ' ';
   Id_010A0 = 0;

   Li_FFFBC = 0;
   Li_FFFB8 = 0;
   Li_FFFB4 = 0;
   Li_FFFB0 = 0;
   Li_FFFAC = 0;
   Li_FFFA8 = 0;
   Li_FFFA4 = 0;
   Li_FFFA0 = 0;
   Li_FFF8C = 0;
   Li_FFF88 = 0;
   Li_FFF84 = 0;
   Li_FFF80 = 0;
   Li_FFF7C = 0;
   Li_FFF78 = 0;
   Li_FFF74 = 0;
   Ib_002B2 = true;
   Ib_002B4 = true;
   Ii_0083C = 9;
   Ii_00840 = 9;
   Ii_00844 = 50;
   Ii_00848 = 1;
   Ii_0084C = 100;
   Ii_00850 = -100;
   Ii_00854 = 12;
   Ii_00858 = 1;
   Ii_0085C = 5;
   Ii_00860 = 3;
   Ii_00864 = 3;
   Ii_00868 = 0;
   Is_00870 = "--------------------< RMI >--------------------";
   Ii_0087C = 14;
   Ii_00880 = 5;
   Ii_00884 = 35;
   Ii_00888 = 65;
   Ii_00278 = 1;
   Ib_003B4 = false;
   Is_00410 = "EURGBP";
   Ii_003E0 = 0;
   Id_00428 = 50;
   Ib_0088C = false;
   Is_00890 = "--------------------< Close by Pips Profit in Hedge >--------------------";
   Ib_0089C = false;
   Ii_008A0 = 5;
   Is_008A8 = "--------------------< Close by $ Profit >--------------------";
   Ib_008B4 = false;
   Id_008B8 = 5;
   Ib_002B1 = false;
   Ib_002B3 = false;
   Id_001F8 = 0;
   Id_008C0 = 0;
   Ii_001E4 = 10;
   Ii_00204 = 2;
   Is_00210 = "";
   Il_008C8 = 0;
   Ii_008D0 = 0;
   Ib_0023C = false;
   Is_00230 = "";
   Is_00240 = "";
   Il_008D8 = 0;
   Ib_00198 = false;
   Ii_000F8 = 3;
   Ii_000F4 = 80;
   Ii_00144 = -1;
   Ii_0013C = 30;
   Ii_00140 = 20;
   Ii_0018C = 0;
   Is_000E8 = "";
   Is_00100 = "1.00";
   Is_00110 = "";
   Is_00120 = "";
   Is_00130 = "";
   Is_00180 = "";
   Is_00160 = "";
   Is_00170 = "";
   Is_00148 = "";
   Id_00398 = 0;
   Id_003A8 = 0;
   Id_008E0 = 0;
   Ib_00272 = false;
   Ii_008E8 = 0;
   Ii_008EC = 0;
   Ii_008F0 = 0;
   Ii_008F4 = 0;
   Is_00230 = "MINI";
   Li_FFFBC = MagicNumber;
   Ls_FFFF0 = "SpaceX_Trader_Pro";
   Is_000E8 = "mt4club.wishhost-free.net";
   Ii_000F4 = 443;
   Ii_000F8 = 3;
   Is_00100 = "1.00";
   Is_00110 = "";
   Is_00120 = "";
   Is_00130 = "EA";
   Ii_0013C = 30;
   Ii_00140 = 20;
   Ii_00144 = MagicNumber;
   Is_00148 = "abc";
   Li_FFFB4 = 200;
   Li_FFFB0 = 10;
   Li_FFFAC = 12;
   ChartSetInteger(0, 1, 0, 0);
   ChartSetInteger(0, 2, 0, 1);
   ChartSetDouble(0, 3, 30);
   Li_FFFA8 = 10;
   Li_FFFA4 = 114;
   int Li_FFF34[];
   Li_FFFA0 = 9;
   Ls_FFF90 = "Calibri";
   Li_FFF8C = 16777215;
   Li_FFF88 = 65535;
   Li_FFF84 = 6;
   Li_FFF80 = 1;
   Li_FFF7C = 120;
   Li_FFF78 = 10;
   ArrayResize(Li_FFF34, 114, 0);
   Li_FFF74 = 0;
   Ii_0019C = 113;
   do { 
   Ii_0019C = Li_FFFAC * Li_FFF74;
   Ii_0019C = Li_FFFA8 + Ii_0019C;
   Li_FFF34[Li_FFF74] = Ii_0019C;
   Li_FFF74 = Li_FFF74 + 1;
   Ii_0019C = Li_FFFA4 - 1;
   } while (Li_FFF74 < Ii_0019C); 
   EventSetTimer(60);
   Ii_0019C = Li_FFFB4 + 25;
   Ii_001A4 = Li_FFFB0 + 10;
   func_1039(Is_00F54, Li_FFF80, Ii_0019C, Ii_001A4, Ii_0019C, 260, 16711680, 14474460);
   Ii_001A4 = Li_FFFB4 + 20;
   Ii_001B0 = Li_FFFB0 + 15;
   Ii_001B4 = Li_FFFB4 + 22;
   func_1039(Is_00F54, Li_FFF80, Ii_001B4, Ii_001B0, Ii_001A4, 250, 0, 0);
   Gl_00001 = Ii_001B4;
   func_1039(Is_00F54, Li_FFF80, Gl_00001, Ii_001B0, Ii_001A4, 30, 0, 0);
   Ii_001C0 = 10;
   Ii_001C4 = FileOpenHistory("symbols.raw", 5);
   Ii_001CC = 0;
   Gl_00001 = (long)FileSize(Ii_001C4);
   Il_001D0 = Gl_00001 / 1936;
   Ii_001D8 = (int)Il_001D0;
   Ii_001DC = Ii_001D8;
   if (Ii_001D8 > 0) { 
   do { 
   Ls_FFFE0 = FileReadString(Ii_001C4, 12);
   if (StringFind(Ls_FFFE0, "EURUSD", 0) != -1) { 
   Ii_001D8 = (int)MarketInfo(Ls_FFFE0, MODE_DIGITS);
   Ii_001E0 = Ii_001D8;
   if (Ii_001D8 == 6) { 
   Ii_001D8 = 100;
   } 
   else { 
   if (Ii_001E0 == 5) { 
   Ii_00208 = 10;
   } 
   else { 
   Ii_00208 = 1;
   } 
   Ii_001D8 = Ii_00208;
   } 
   Ii_001C0 = Ii_001D8;
   break; 
   } 
   FileSeek(Ii_001C4, 1924, 1);
   Ii_001CC = Ii_001CC + 1;
   } while (Ii_001DC > Ii_001CC); 
   } 
   FileClose(Ii_001C4);
   Ii_001E4 = Ii_001C0;
   Id_001F8 = (_Point * Ii_001C0);
   if ((MarketInfo(_Symbol, MODE_LOTSTEP) >= 0.01)) { 
   Ii_00204 = 2;
   } 
   if ((MarketInfo(_Symbol, MODE_LOTSTEP) >= 0.1)) { 
   Ii_00204 = 1;
   } 
   if ((MarketInfo(_Symbol, MODE_LOTSTEP) >= 1)) { 
   Ii_00204 = 0;
   } 
   if (TimeFrame != 0) { 
   Ii_00208 = TimeFrame;
   } 
   else { 
   Ii_00208 = _Period;
   } 
   Ls_FFFD0 = (string)Ii_00208;
   Ls_FFFD0 = _Symbol + Ls_FFFD0;
   Ls_FFFC0 = (string)MagicNumber;
   Ls_FFFD0 = Ls_FFFD0 + Ls_FFFC0;
   Is_00210 = Ls_FFFD0;
   if (IsTesting()) { 
   Is_00210 = "Test" + Ls_FFFD0;
   } 
   Ls_FFF68 = NULL;
   if (IsConnected()) { 
   Ls_FFF68 = DoubleToString(AccountInfoInteger(ACCOUNT_LOGIN), 0);
   } 
   Li_FFFB8 = 0;
   ArrayFree(Li_FFF34);
   Li_FFFFC = 0;
   ArrayFree(Li_FFF34);
   
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
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   string Ls_FFFB0;
   string Ls_FFFA0;
   string Ls_FFF90;
   string Ls_FFF80;
   string Ls_FFF70;
   string Ls_FFF60;
   string Ls_FFF50;
   string Ls_FFF40;
   string Ls_FFF30;
   string Ls_FFF20;
   string Ls_FFF10;
   string Ls_FFF00;
   string Ls_FFEF0;
   string Ls_FFEE0;
   string Ls_FFED0;
   string Ls_FFEC0;
   string Ls_FFEB0;
   string Ls_FFEA0;
   string Ls_FFE90;
   string Ls_FFE80;
   string Ls_FFE70;
   string Ls_FFE60;
   string Ls_FFE50;
   string Ls_FFE40;
   string Ls_FFE30;
   string Ls_FFE20;
   string Ls_FFE10;
   string Ls_FFE00;
   string Ls_FFDF0;
   string Ls_FFDE0;
   string Ls_FFDD0;
   string Ls_FFDC0;
   string Ls_FFDB0;
   string Ls_FFDA0;
   string Ls_FFD90;
   string Ls_FFD80;
   string Ls_FFD70;
   string Ls_FFD60;
   string Ls_FFD50;
   string Ls_FFD40;
   string Ls_FFD30;
   string Ls_FFD20;
   string Ls_FFD10;
   string Ls_FFD00;
   string Ls_FFCF0;
   string Ls_FFCE0;
   string Ls_FFCD0;
   string Ls_FFCC0;
   string Ls_FFCB0;
   string Ls_FFCA0;
   string Ls_FFC90;
   string Ls_FFC80;
   string Ls_FFC70;
   string Ls_FFC60;
   string Ls_FFC50;
   string Ls_FFC40;
   string Ls_FFC30;
   string Ls_FFC20;
   string Ls_FFC10;
   string Ls_FFC00;
   string Ls_FFBF0;
   string Ls_FFBE0;
   string Ls_FFBD0;
   string Ls_FFBC0;
   string Ls_FFBB0;
   string Ls_FFBA0;
   string Ls_FFB90;
   string Ls_FFB80;
   string Ls_FFB70;
   string Ls_FFB60;
   string Ls_FFB50;
   string Ls_FFB40;
   string Ls_FFB30;
   string Ls_FFB20;
   string Ls_FFB10;
   string Ls_FFB00;
   string Ls_FFAF0;
   string Ls_FFAE0;
   string Ls_FFAD0;
   string Ls_FFAC0;
   string Ls_FFAB0;
   string Ls_FFAA0;
   string Ls_FFA90;
   string Ls_FFA80;
   string Ls_FFA70;
   string Ls_FFA60;
   string Ls_FFA50;
   string Ls_FFA40;
   string Ls_FFA30;
   string Ls_FFA20;
   string Ls_FFA10;
   string Ls_FFA00;
   string Ls_FF9F0;
   string Ls_FF9E0;
   string Ls_FF9D0;
   string Ls_FF9C0;
   double Ld_FF9B8;
   double Ld_FF9B0;
   bool Lb_FF9AF;
   bool Lb_FF9AE;
   double Ld_FF9A0;
   double Ld_FF998;
   double Ld_FF990;
   int Li_FF98C;
   double Ld_FF980;
   int Li_FF97C;
   double Ld_FF970;
   int Li_FF96C;
   double Ld_FF960;
   int Li_FF95C;

   Ld_FF9B8 = 0;
   Ld_FF9B0 = 0;
   Lb_FF9AF = false;
   Lb_FF9AE = false;
   Ld_FF9A0 = 0;
   Ld_FF998 = 0;
   Ld_FF990 = 0;
   Li_FF98C = 0;
   Ld_FF980 = 0;
   Li_FF97C = 0;
   Ld_FF970 = 0;
   Li_FF96C = 0;
   Ld_FF960 = 0;
   Li_FF95C = 0;
   if (Is_00230 == "MINI" || Is_00230 == "MAX") { 
   
   Ib_0023C = true;
   } 
   Ls_FFFB0 = "\n";
   Ls_FFFA0 = "Arial";
   Ii_001A0 = 20;
   Ii_001A4 = 5;
   Ii_001B0 = 32896;
   Ls_FFF90 = "Activated: " + Is_00240;
   Ls_FFF80 = Is_00180 + "Warning_Work_1";
   if (ObjectFind(0, Ls_FFF80) < 0) { 
   ObjectCreate(0, Ls_FFF80, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, Ls_FFF80, 101, 3);
   ObjectSetInteger(0, Ls_FFF80, 1011, 4);
   ObjectSetString(0, Ls_FFF80, 1001, Ls_FFFA0);
   ObjectSetInteger(0, Ls_FFF80, 100, 10);
   ObjectSetInteger(0, Ls_FFF80, 1000, 0);
   ObjectSetInteger(0, Ls_FFF80, 17, 0);
   ObjectSetString(0, Ls_FFF80, 206, Ls_FFFB0);
   ObjectSetInteger(0, Ls_FFF80, 9, 0);
   ObjectSetInteger(0, Ls_FFF80, 208, 0);
   } 
   ObjectSetInteger(0, Ls_FFF80, 102, Ii_001A4);
   ObjectSetInteger(0, Ls_FFF80, 103, Ii_001A0);
   ObjectSetString(0, Ls_FFF80, 999, Ls_FFF90);
   ObjectSetInteger(0, Ls_FFF80, 6, Ii_001B0);
   ChartRedraw(0);
   func_1031();
   if (UseTrailingStop) { 
   Ib_00258 = (TrailingStopStart > 0);
   if (Ib_00258) { 
   func_1032();
   }} 
   Ld_FF9B8 = 0;
   Ld_FF9B0 = 0;
   func_1033(Ld_FF9B8, Ld_FF9B0);
   Ib_00258 = false;
   Ii_001C0 = 0;
   Ls_FFF70 = _Symbol;
   Il_00260 = SeriesInfoInteger(Ls_FFF70, TimeFrame, 5);
   if (ArrayRange(Il_01058, 0) < 1) { 
   ArrayResize(Il_01058, 1, 0);
   Il_01058[0] = Il_00260;
   Ib_00270 = Ib_00258;
   } 
   else { 
   if (Il_01058[Ii_001C0] == Il_00260) { 
   Ib_00270 = false;
   } 
   else { 
   Il_01058[Ii_001C0] = Il_00260;
   Ib_00270 = true;
   }} 
   Lb_FF9AF = Ib_00270;
   Ib_00200 = IsTesting();
   if (Ib_00200 != true) { 
   Ib_00200 = IsExpertEnabled();
   if (Ib_00200) { 
   Ib_00200 = IsTradeAllowed();
   }} 
   Lb_FF9AE = Ib_00200;
   Ib_00271 = Ib_00200;
   if (Ib_00200) { 
   returned_double = NormalizeDouble((MarketInfo(_Symbol, MODE_SPREAD) / Ii_001E4), 1);
   Id_010A0 = returned_double;
   Ib_00200 = (MaxSpread <= Id_010A0);
   if (Ib_00200) { 
   if (Ib_00272) { 
   Ls_FFF60 = StringConcatenate("Spread (", returned_double, ")", " > ", "Max Spread (", MaxSpread, ")");
   Print(Ls_FFF60);
   if (SpreadAlert) { 
   Alert(Ls_FFF60);
   } 
   Ib_00272 = false;
   } 
   Ib_00200 = false;
   } 
   else { 
   Ib_00272 = true;
   Ib_00200 = true;
   } 
   Ib_00271 = Ib_00200;
   } 
   if (Ib_00271) { 
   if (EnableTimer != true) { 
   Ib_00273 = true;
   } 
   else { 
   if (EnableTimer != 0 && TimeCurrent() > StringToTime(TimerStart) && TimeCurrent() < StringToTime(TimerEnd)) {
   Ib_00273 = true;
   }
   else{
   Ib_00273 = false;
   }} 
   Ib_00271 = Ib_00273;
   } 
   Lb_FF9AE = Ib_00271;
   Ib_00274 = Ib_00271;
   if (Ib_00271) { 
   Ib_00274 = Lb_FF9AF;
   } 
   Lb_FF9AE = Ib_00274;
   HideTestIndicators(true);
   HideTestIndicators(true);
   Id_00280 = iMA(NULL, TimeFrame, MA1Period, 0, 0, 0, Ii_00278);
   Id_00288 = iMA(NULL, TimeFrame, MA2Period, 0, 0, 0, Ii_00278);
   if (AvoidNews != true) { 
   Ib_00290 = false;
   } 
   else { 
   if ((iCustom(_Symbol, 0, "urdala_news_investing.com", UTimeDo, UTimePosle, Uoffset, Vhigh, Vmedium, Vlow, 0, 0) != 0)) { 
   Ib_00290 = true;
   } 
   else { 
   Ib_00290 = false;
   }} 
   Ib_00291 = !Ib_00290;
   if (Ib_00290 != true) { 
   Id_00298 = (Id_00280 - Ask);
   Ib_00291 = (Id_00298 > (Delta1 * _Point));
   } 
   if (Ib_00291) { 
   Id_00298 = (Id_00288 - Ask);
   Ib_00291 = (Id_00298 > (Delta2 * _Point));
   } 
   if (Ib_00291) { 
   Ib_00291 = (Id_00280 < Id_00288);
   } 
   Ib_002B1 = Ib_00291;
   if (AvoidNews != true) { 
   Ib_002A1 = false;
   } 
   else { 
   if ((iCustom(_Symbol, 0, "urdala_news_investing.com", UTimeDo, UTimePosle, Uoffset, Vhigh, Vmedium, Vlow, 0, 0) != 0)) { 
   Ib_002A1 = true;
   } 
   else { 
   Ib_002A1 = false;
   }} 
   Ib_002A2 = !Ib_002A1;
   if (Ib_002A1 != true) { 
   Id_002A8 = (Bid - Id_00280);
   Ib_002A2 = (Id_002A8 > (Delta1 * _Point));
   } 
   if (Ib_002A2) { 
   Id_002A8 = (Bid - Id_00288);
   Ib_002A2 = (Id_002A8 > (Delta2 * _Point));
   } 
   if (Ib_002A2) { 
   Ib_002A2 = (Id_00280 > Id_00288);
   } 
   Ib_002B3 = Ib_002A2;
   HideTestIndicators(false);
   Ib_002B0 = Ib_002B1;
   if (Ib_002B1) { 
   Ib_002B0 = Ib_002B2;
   } 
   if (Ib_002B0) { 
   Ib_002B0 = Lb_FF9AE;
   } 
   Ib_002B1 = Ib_002B0;
   Ib_002B0 = Ib_002B3;
   if (Ib_002B3) { 
   Ib_002B0 = Ib_002B4;
   } 
   if (Ib_002B0) { 
   Ib_002B0 = Lb_FF9AE;
   } 
   Ib_002B3 = Ib_002B0;
   Ls_FFF50 = "price";
   Ii_002B8 = 0;
   Id_002C0 = 0;
   Id_002C8 = 0;
   Id_002D0 = 0;
   Ii_002D8 = 0;
   Ii_002DC = 0;
   Ii_002E0 = 0;
   Ii_002E4 = OrdersTotal() - 1;
   Ii_002E8 = Ii_002E4;
   if (Ii_002E4 >= 0) { 
   do { 
   if (OrderSelect(Ii_002E8, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == Ii_002B8 || Ii_002B8 < 0) { 
   
   Ii_002DC = OrderTicket();
   if (Ii_002D8 < Ii_002DC) { 
   Ii_002D8 = Ii_002DC;
   Id_002C0 = OrderOpenPrice();
   Ii_002E0 = OrderTicket();
   Id_002C8 = OrderLots();
   Id_002F0 = OrderProfit();
   Id_002F0 = (Id_002F0 + OrderSwap());
   Id_002D0 = (Id_002F0 + OrderCommission());
   }}}} 
   Ii_002E8 = Ii_002E8 - 1;
   } while (Ii_002E8 >= 0); 
   } 
   Id_002F0 = 0;
   if (Ls_FFF50 == "price") { 
   Id_002F0 = Id_002C0;
   } 
   else { 
   if (Ls_FFF50 == "ticket") { 
   Id_002F0 = Ii_002E0;
   } 
   else { 
   if (Ls_FFF50 == "lot") { 
   Id_002F0 = Id_002C8;
   } 
   else { 
   if (Ls_FFF50 == "profit") { 
   Id_002F0 = Id_002D0;
   }}}} 
   Ld_FF9A0 = Id_002F0;
   Ls_FFF40 = "price";
   Ii_002F8 = 1;
   Id_00300 = 0;
   Id_00308 = 0;
   Id_00310 = 0;
   Ii_00318 = 0;
   Ii_0031C = 0;
   Ii_00320 = 0;
   Ii_00324 = OrdersTotal() - 1;
   Ii_00328 = Ii_00324;
   if (Ii_00324 >= 0) { 
   do { 
   if (OrderSelect(Ii_00328, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == Ii_002F8 || Ii_002F8 < 0) { 
   
   Ii_0031C = OrderTicket();
   if (Ii_00318 < Ii_0031C) { 
   Ii_00318 = Ii_0031C;
   Id_00300 = OrderOpenPrice();
   Ii_00320 = OrderTicket();
   Id_00308 = OrderLots();
   Id_00330 = OrderProfit();
   Id_00330 = (Id_00330 + OrderSwap());
   Id_00310 = (Id_00330 + OrderCommission());
   }}}} 
   Ii_00328 = Ii_00328 - 1;
   } while (Ii_00328 >= 0); 
   } 
   Id_00330 = 0;
   if (Ls_FFF40 == "price") { 
   Id_00330 = Id_00300;
   } 
   else { 
   if (Ls_FFF40 == "ticket") { 
   Id_00330 = Ii_00320;
   } 
   else { 
   if (Ls_FFF40 == "lot") { 
   Id_00330 = Id_00308;
   } 
   else { 
   if (Ls_FFF40 == "profit") { 
   Id_00330 = Id_00310;
   }}}} 
   Ld_FF998 = Id_00330;
   if (Ib_002B1) { 
   Ii_00338 = 0;
   Ii_0033C = 0;
   Ii_00340 = OrdersTotal() - 1;
   Ii_00344 = Ii_00340;
   if (Ii_00340 >= 0) { 
   do { 
   if (OrderSelect(Ii_00344, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00338 < 0) { 
   Ii_0033C = Ii_0033C + 1;
   } 
   else { 
   if (OrderType() == Ii_00338) { 
   Ii_0033C = Ii_0033C + 1;
   }}}} 
   Ii_00344 = Ii_00344 - 1;
   } while (Ii_00344 >= 0); 
   } 
   Ii_00340 = 0;
   Ii_00348 = 0;
   Ii_0034C = OrdersTotal() - 1;
   Ii_00350 = Ii_0034C;
   if (Ii_0034C >= 0) { 
   do { 
   if (OrderSelect(Ii_00350, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00340 < 0) { 
   Ii_00348 = Ii_00348 + 1;
   } 
   else { 
   if (OrderType() == Ii_00340) { 
   Ii_00348 = Ii_00348 + 1;
   }}}} 
   Ii_00350 = Ii_00350 - 1;
   } while (Ii_00350 >= 0); 
   } 
   Ii_0034C = Ii_00348;
   Ii_00354 = 1;
   Ii_00358 = 0;
   Ii_0035C = OrdersTotal() - 1;
   Ii_00360 = Ii_0035C;
   if (Ii_0035C >= 0) { 
   do { 
   if (OrderSelect(Ii_00360, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00354 < 0) { 
   Ii_00358 = Ii_00358 + 1;
   } 
   else { 
   if (OrderType() == Ii_00354) { 
   Ii_00358 = Ii_00358 + 1;
   }}}} 
   Ii_00360 = Ii_00360 - 1;
   } while (Ii_00360 >= 0); 
   } 
   Ii_0035C = Ii_0034C + Ii_00358;
   if ((!UseGrid && MaxOpenOrders > Ii_0033C)
   || (UseGrid && Ii_0035C < 1)) {
   
   Ld_FF990 = Ld_FF9B8;
   Li_FF98C = -1;
   Ls_FFF30 = NULL;
   Ib_00364 = true;
   if (Ls_FFF30 == NULL) { 
   Ls_FFF30 = _Symbol;
   } 
   Ii_00368 = OrdersTotal() - 1;
   Ii_0036C = Ii_00368;
   if (Ii_00368 >= 0) { 
   do { 
   if (OrderSelect(Ii_0036C, 0, 0) && OrderSymbol() == Ls_FFF30) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Il_00370 = iTime(Ls_FFF30, 0, 0);
   if (Il_00370 <= OrderOpenTime()) { 
   Ib_00364 = false;
   break; 
   }}} 
   Ii_0036C = Ii_0036C - 1;
   } while (Ii_0036C >= 0); 
   } 
   if (Ib_00364) { 
   Ls_FFF20 = NULL;
   Ib_00378 = true;
   if (Ls_FFF20 == NULL) { 
   Ls_FFF20 = _Symbol;
   } 
   Ii_0037C = HistoryTotal() - 1;
   Ii_00380 = Ii_0037C;
   if (Ii_0037C >= 0) { 
   do { 
   if (OrderSelect(Ii_00380, 0, 1) && OrderSymbol() == Ls_FFF20) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Il_00388 = iTime(Ls_FFF20, 0, 0);
   if (Il_00388 <= OrderOpenTime()) { 
   Ib_00378 = false;
   break; 
   }}}} 
   Ii_00380 = Ii_00380 - 1;
   } while (Ii_00380 >= 0); 
   } 
   if (Ib_00378) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_00390 = 0;
   } 
   else { 
   Id_003A0 = (StopLoss * Id_001F8);
   Id_00390 = (Bid - Id_003A0);
   } 
   Id_00398 = Id_00390;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_003A0 = 0;
   } 
   else { 
   Id_003A0 = ((TakeProfit * Id_001F8) + Ask);
   } 
   Id_003A8 = Id_003A0;
   Ls_FFF10 = EAComment;
   Ls_FFF00 = _Symbol;
   tmp_str00000 = EAComment;
   tmp_str00001 = _Symbol;
   Li_FF98C = func_1030(tmp_str00001, 0, Ld_FF990, Ask, (Slippage * Ii_001E4), Id_00398, Id_003A0, tmp_str00000, MagicNumber, 0, 16711680);
   }} 
   if (Ib_003B4 && Li_FF98C > 0) { 
   Ls_FFEF0 = _Symbol;
   Ib_003B5 = true;
   if (Ls_FFEF0 == NULL) { 
   Ls_FFEF0 = _Symbol;
   } 
   Ii_003B8 = OrdersTotal() - 1;
   Ii_003BC = Ii_003B8;
   if (Ii_003B8 >= 0) { 
   do { 
   if (OrderSelect(Ii_003BC, 0, 0) && OrderSymbol() == Ls_FFEF0) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Il_003C0 = iTime(Ls_FFEF0, 0, 0);
   if (Il_003C0 <= OrderOpenTime()) { 
   Ib_003B5 = false;
   break; 
   }}} 
   Ii_003BC = Ii_003BC - 1;
   } while (Ii_003BC >= 0); 
   } 
   if (Ib_003B5) { 
   Ls_FFEE0 = _Symbol;
   Ib_003C8 = true;
   if (Ls_FFEE0 == NULL) { 
   Ls_FFEE0 = _Symbol;
   } 
   Ii_003CC = HistoryTotal() - 1;
   Ii_003D0 = Ii_003CC;
   if (Ii_003CC >= 0) { 
   do { 
   if (OrderSelect(Ii_003D0, 0, 1) && OrderSymbol() == Ls_FFEE0) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Il_003D8 = iTime(Ls_FFEE0, 0, 0);
   if (Il_003D8 <= OrderOpenTime()) { 
   Ib_003C8 = false;
   break; 
   }}}} 
   Ii_003D0 = Ii_003D0 - 1;
   } while (Ii_003D0 >= 0); 
   } 
   if (Ib_003C8) { 
   if (Ii_003E0 == 0) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_003E8 = 0;
   } 
   else { 
   Ls_FFED0 = Is_00410;
   Ls_FFEC0 = "bid";
   if (Ls_FFED0 == NULL) { 
   Ls_FFED0 = _Symbol;
   } 
   if (Ls_FFEC0 == "ask") { 
   Id_00800 = MarketInfo(Ls_FFED0, MODE_ASK);
   } 
   else { 
   if (Ls_FFEC0 == "bid") { 
   Id_00800 = MarketInfo(Ls_FFED0, MODE_BID);
   } 
   else { 
   if (Ls_FFEC0 == "point") { 
   Id_00800 = MarketInfo(Ls_FFED0, MODE_POINT);
   } 
   else { 
   if (Ls_FFEC0 == "digits") { 
   Id_00800 = MarketInfo(Ls_FFED0, MODE_DIGITS);
   } 
   else { 
   Id_00800 = 0;
   }}}} 
   Id_003F0 = (StopLoss * Id_001F8);
   Id_003E8 = (Id_00800 - Id_003F0);
   } 
   Id_00398 = Id_003E8;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_003F0 = 0;
   } 
   else { 
   Ls_FFEB0 = Is_00410;
   Ls_FFEA0 = "ask";
   if (Ls_FFEB0 == NULL) { 
   Ls_FFEB0 = _Symbol;
   } 
   if (Ls_FFEA0 == "ask") { 
   Id_007F8 = MarketInfo(Ls_FFEB0, MODE_ASK);
   } 
   else { 
   if (Ls_FFEA0 == "bid") { 
   Id_007F8 = MarketInfo(Ls_FFEB0, MODE_BID);
   } 
   else { 
   if (Ls_FFEA0 == "point") { 
   Id_007F8 = MarketInfo(Ls_FFEB0, MODE_POINT);
   } 
   else { 
   if (Ls_FFEA0 == "digits") { 
   Id_007F8 = MarketInfo(Ls_FFEB0, MODE_DIGITS);
   } 
   else { 
   Id_007F8 = 0;
   }}}} 
   Id_003F0 = ((TakeProfit * Id_001F8) + Id_007F8);
   } 
   Id_003A8 = Id_003F0;
   Ls_FFE90 = EAComment;
   Ls_FFE80 = Is_00410;
   Ls_FFE70 = "ask";
   if (Ls_FFE80 == NULL) { 
   Ls_FFE80 = _Symbol;
   } 
   if (Ls_FFE70 == "ask") { 
   Id_00420 = MarketInfo(Ls_FFE80, MODE_ASK);
   } 
   else { 
   if (Ls_FFE70 == "bid") { 
   Id_00420 = MarketInfo(Ls_FFE80, MODE_BID);
   } 
   else { 
   if (Ls_FFE70 == "point") { 
   Id_00420 = MarketInfo(Ls_FFE80, MODE_POINT);
   } 
   else { 
   if (Ls_FFE70 == "digits") { 
   Id_00420 = MarketInfo(Ls_FFE80, MODE_DIGITS);
   } 
   else { 
   Id_00420 = 0;
   }}}} 
   Ls_FFE60 = _Symbol;
   tmp_str00002 = Ls_FFE90;
   tmp_str00003 = _Symbol;
   Li_FF98C = func_1030(tmp_str00003, 0, ((Ld_FF990 * Id_00428) / 100), Id_00420, Slippage, Id_00398, Id_003F0, tmp_str00002, MagicNumber, 0, 16711680);
   } 
   if (Ii_003E0 == 1) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_00430 = 0;
   } 
   else { 
   Ls_FFE50 = _Symbol;
   Ls_FFE40 = "ask";
   if (Ls_FFE50 == NULL) { 
   Ls_FFE50 = _Symbol;
   } 
   if (Ls_FFE40 == "ask") { 
   Id_007F0 = MarketInfo(Ls_FFE50, MODE_ASK);
   } 
   else { 
   if (Ls_FFE40 == "bid") { 
   Id_007F0 = MarketInfo(Ls_FFE50, MODE_BID);
   } 
   else { 
   if (Ls_FFE40 == "point") { 
   Id_007F0 = MarketInfo(Ls_FFE50, MODE_POINT);
   } 
   else { 
   if (Ls_FFE40 == "digits") { 
   Id_007F0 = MarketInfo(Ls_FFE50, MODE_DIGITS);
   } 
   else { 
   Id_007F0 = 0;
   }}}} 
   Id_00430 = ((StopLoss * Id_001F8) + Id_007F0);
   } 
   Id_00398 = Id_00430;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_00430 = 0;
   } 
   else { 
   Ls_FFE30 = _Symbol;
   Ls_FFE20 = "bid";
   if (Ls_FFE30 == NULL) { 
   Ls_FFE30 = _Symbol;
   } 
   if (Ls_FFE20 == "ask") { 
   Id_007E0 = MarketInfo(Ls_FFE30, MODE_ASK);
   } 
   else { 
   if (Ls_FFE20 == "bid") { 
   Id_007E0 = MarketInfo(Ls_FFE30, MODE_BID);
   } 
   else { 
   if (Ls_FFE20 == "point") { 
   Id_007E0 = MarketInfo(Ls_FFE30, MODE_POINT);
   } 
   else { 
   if (Ls_FFE20 == "digits") { 
   Id_007E0 = MarketInfo(Ls_FFE30, MODE_DIGITS);
   } 
   else { 
   Id_007E0 = 0;
   }}}} 
   Id_007E8 = (TakeProfit * Id_001F8);
   Id_00430 = (Id_007E0 - Id_007E8);
   } 
   Id_003A8 = Id_00430;
   Ls_FFE10 = EAComment;
   Ls_FFE00 = Is_00410;
   Ls_FFDF0 = "bid";
   if (Ls_FFE00 == NULL) { 
   Ls_FFE00 = _Symbol;
   } 
   if (Ls_FFDF0 == "ask") { 
   Id_00450 = MarketInfo(Ls_FFE00, MODE_ASK);
   } 
   else { 
   if (Ls_FFDF0 == "bid") { 
   Id_00450 = MarketInfo(Ls_FFE00, MODE_BID);
   } 
   else { 
   if (Ls_FFDF0 == "point") { 
   Id_00450 = MarketInfo(Ls_FFE00, MODE_POINT);
   } 
   else { 
   if (Ls_FFDF0 == "digits") { 
   Id_00450 = MarketInfo(Ls_FFE00, MODE_DIGITS);
   } 
   else { 
   Id_00450 = 0;
   }}}} 
   Ls_FFDE0 = _Symbol;
   tmp_str00004 = Ls_FFE10;
   tmp_str00005 = _Symbol;
   Li_FF98C = func_1030(tmp_str00005, 1, ((Ld_FF990 * Id_00428) / 100), Id_00450, Slippage, Id_00398, Id_00430, tmp_str00004, MagicNumber, 0, 255);
   }}}}}} 
   if (Ib_002B3) { 
   Ii_00460 = 1;
   Ii_00464 = 0;
   Ii_00468 = OrdersTotal() - 1;
   Ii_0046C = Ii_00468;
   if (Ii_00468 >= 0) { 
   do { 
   if (OrderSelect(Ii_0046C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00460 < 0) { 
   Ii_00464 = Ii_00464 + 1;
   } 
   else { 
   if (OrderType() == Ii_00460) { 
   Ii_00464 = Ii_00464 + 1;
   }}}} 
   Ii_0046C = Ii_0046C - 1;
   } while (Ii_0046C >= 0); 
   } 
   Ii_00468 = 0;
   Ii_00470 = 0;
   Ii_00474 = OrdersTotal() - 1;
   Ii_00478 = Ii_00474;
   if (Ii_00474 >= 0) { 
   do { 
   if (OrderSelect(Ii_00478, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00468 < 0) { 
   Ii_00470 = Ii_00470 + 1;
   } 
   else { 
   if (OrderType() == Ii_00468) { 
   Ii_00470 = Ii_00470 + 1;
   }}}} 
   Ii_00478 = Ii_00478 - 1;
   } while (Ii_00478 >= 0); 
   } 
   Ii_00474 = Ii_00470;
   Ii_0047C = 1;
   Ii_00480 = 0;
   Ii_00484 = OrdersTotal() - 1;
   Ii_00488 = Ii_00484;
   if (Ii_00484 >= 0) { 
   do { 
   if (OrderSelect(Ii_00488, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_0047C < 0) { 
   Ii_00480 = Ii_00480 + 1;
   } 
   else { 
   if (OrderType() == Ii_0047C) { 
   Ii_00480 = Ii_00480 + 1;
   }}}} 
   Ii_00488 = Ii_00488 - 1;
   } while (Ii_00488 >= 0); 
   } 
   Ii_00484 = Ii_00474 + Ii_00480;
   if ((!UseGrid && MaxOpenOrders > Ii_00464)
   || (UseGrid && Ii_00484 < 1)) {
   
   Ld_FF980 = Ld_FF9B0;
   Li_FF97C = -1;
   Ls_FFDD0 = NULL;
   Ib_0048C = true;
   if (Ls_FFDD0 == NULL) { 
   Ls_FFDD0 = _Symbol;
   } 
   Ii_00490 = OrdersTotal() - 1;
   Ii_00494 = Ii_00490;
   if (Ii_00490 >= 0) { 
   do { 
   if (OrderSelect(Ii_00494, 0, 0) && OrderSymbol() == Ls_FFDD0) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Il_00498 = iTime(Ls_FFDD0, 0, 0);
   if (Il_00498 <= OrderOpenTime()) { 
   Ib_0048C = false;
   break; 
   }}} 
   Ii_00494 = Ii_00494 - 1;
   } while (Ii_00494 >= 0); 
   } 
   if (Ib_0048C) { 
   Ls_FFDC0 = NULL;
   Ib_004A0 = true;
   if (Ls_FFDC0 == NULL) { 
   Ls_FFDC0 = _Symbol;
   } 
   Ii_004A4 = HistoryTotal() - 1;
   Ii_004A8 = Ii_004A4;
   if (Ii_004A4 >= 0) { 
   do { 
   if (OrderSelect(Ii_004A8, 0, 1) && OrderSymbol() == Ls_FFDC0) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Il_004B0 = iTime(Ls_FFDC0, 0, 0);
   if (Il_004B0 <= OrderOpenTime()) { 
   Ib_004A0 = false;
   break; 
   }}}} 
   Ii_004A8 = Ii_004A8 - 1;
   } while (Ii_004A8 >= 0); 
   } 
   if (Ib_004A0) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_004B8 = 0;
   } 
   else { 
   Id_004B8 = ((StopLoss * Id_001F8) + Ask);
   } 
   Id_00398 = Id_004B8;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_004B8 = 0;
   } 
   else { 
   Id_007D8 = (TakeProfit * Id_001F8);
   Id_004B8 = (Bid - Id_007D8);
   } 
   Id_003A8 = Id_004B8;
   Ls_FFDB0 = EAComment;
   Ls_FFDA0 = _Symbol;
   tmp_str00006 = EAComment;
   tmp_str00007 = _Symbol;
   Li_FF97C = func_1030(tmp_str00007, 1, Ld_FF980, Bid, (Slippage * Ii_001E4), Id_00398, Id_004B8, tmp_str00006, MagicNumber, 0, 255);
   }} 
   if (Ib_003B4 && Li_FF97C > 0) { 
   Ls_FFD90 = _Symbol;
   Ib_004C4 = true;
   if (Ls_FFD90 == NULL) { 
   Ls_FFD90 = _Symbol;
   } 
   Ii_004C8 = OrdersTotal() - 1;
   Ii_004CC = Ii_004C8;
   if (Ii_004C8 >= 0) { 
   do { 
   if (OrderSelect(Ii_004CC, 0, 0) && OrderSymbol() == Ls_FFD90) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Il_004D0 = iTime(Ls_FFD90, 0, 0);
   if (Il_004D0 <= OrderOpenTime()) { 
   Ib_004C4 = false;
   break; 
   }}} 
   Ii_004CC = Ii_004CC - 1;
   } while (Ii_004CC >= 0); 
   } 
   if (Ib_004C4) { 
   Ls_FFD80 = Is_00410;
   Ib_004D8 = true;
   if (Ls_FFD80 == NULL) { 
   Ls_FFD80 = _Symbol;
   } 
   Ii_004DC = HistoryTotal() - 1;
   Ii_004E0 = Ii_004DC;
   if (Ii_004DC >= 0) { 
   do { 
   if (OrderSelect(Ii_004E0, 0, 1) && OrderSymbol() == Ls_FFD80) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Il_004E8 = iTime(Ls_FFD80, 0, 0);
   if (Il_004E8 <= OrderOpenTime()) { 
   Ib_004D8 = false;
   break; 
   }}}} 
   Ii_004E0 = Ii_004E0 - 1;
   } while (Ii_004E0 >= 0); 
   } 
   if (Ib_004D8) { 
   if (Ii_003E0 == 0) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_004F0 = 0;
   } 
   else { 
   Ls_FFD70 = Is_00410;
   Ls_FFD60 = "ask";
   if (Ls_FFD70 == NULL) { 
   Ls_FFD70 = _Symbol;
   } 
   if (Ls_FFD60 == "ask") { 
   Id_007D0 = MarketInfo(Ls_FFD70, MODE_ASK);
   } 
   else { 
   if (Ls_FFD60 == "bid") { 
   Id_007D0 = MarketInfo(Ls_FFD70, MODE_BID);
   } 
   else { 
   if (Ls_FFD60 == "point") { 
   Id_007D0 = MarketInfo(Ls_FFD70, MODE_POINT);
   } 
   else { 
   if (Ls_FFD60 == "digits") { 
   Id_007D0 = MarketInfo(Ls_FFD70, MODE_DIGITS);
   } 
   else { 
   Id_007D0 = 0;
   }}}} 
   Id_004F0 = ((StopLoss * Id_001F8) + Id_007D0);
   } 
   Id_00398 = Id_004F0;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_004F0 = 0;
   } 
   else { 
   Ls_FFD50 = Is_00410;
   Ls_FFD40 = "bid";
   if (Ls_FFD50 == NULL) { 
   Ls_FFD50 = _Symbol;
   } 
   if (Ls_FFD40 == "ask") { 
   Id_007C0 = MarketInfo(Ls_FFD50, MODE_ASK);
   } 
   else { 
   if (Ls_FFD40 == "bid") { 
   Id_007C0 = MarketInfo(Ls_FFD50, MODE_BID);
   } 
   else { 
   if (Ls_FFD40 == "point") { 
   Id_007C0 = MarketInfo(Ls_FFD50, MODE_POINT);
   } 
   else { 
   if (Ls_FFD40 == "digits") { 
   Id_007C0 = MarketInfo(Ls_FFD50, MODE_DIGITS);
   } 
   else { 
   Id_007C0 = 0;
   }}}} 
   Id_007C8 = (TakeProfit * Id_001F8);
   Id_004F0 = (Id_007C0 - Id_007C8);
   } 
   Id_003A8 = Id_004F0;
   Ls_FFD30 = EAComment;
   Ls_FFD20 = Is_00410;
   Ls_FFD10 = "bid";
   if (Ls_FFD20 == NULL) { 
   Ls_FFD20 = _Symbol;
   } 
   if (Ls_FFD10 == "ask") { 
   Id_00510 = MarketInfo(Ls_FFD20, MODE_ASK);
   } 
   else { 
   if (Ls_FFD10 == "bid") { 
   Id_00510 = MarketInfo(Ls_FFD20, MODE_BID);
   } 
   else { 
   if (Ls_FFD10 == "point") { 
   Id_00510 = MarketInfo(Ls_FFD20, MODE_POINT);
   } 
   else { 
   if (Ls_FFD10 == "digits") { 
   Id_00510 = MarketInfo(Ls_FFD20, MODE_DIGITS);
   } 
   else { 
   Id_00510 = 0;
   }}}} 
   Ls_FFD00 = _Symbol;
   tmp_str00008 = Ls_FFD30;
   tmp_str00009 = _Symbol;
   Li_FF97C = func_1030(tmp_str00009, 1, ((Ld_FF980 * Id_00428) / 100), Id_00510, Slippage, Id_00398, Id_004F0, tmp_str00008, MagicNumber, 0, 255);
   } 
   if (Ii_003E0 == 1) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_00518 = 0;
   } 
   else { 
   Ls_FFCF0 = Is_00410;
   Ls_FFCE0 = "bid";
   if (Ls_FFCF0 == NULL) { 
   Ls_FFCF0 = _Symbol;
   } 
   if (Ls_FFCE0 == "ask") { 
   Id_007B8 = MarketInfo(Ls_FFCF0, MODE_ASK);
   } 
   else { 
   if (Ls_FFCE0 == "bid") { 
   Id_007B8 = MarketInfo(Ls_FFCF0, MODE_BID);
   } 
   else { 
   if (Ls_FFCE0 == "point") { 
   Id_007B8 = MarketInfo(Ls_FFCF0, MODE_POINT);
   } 
   else { 
   if (Ls_FFCE0 == "digits") { 
   Id_007B8 = MarketInfo(Ls_FFCF0, MODE_DIGITS);
   } 
   else { 
   Id_007B8 = 0;
   }}}} 
   Id_00520 = (StopLoss * Id_001F8);
   Id_00518 = (Id_007B8 - Id_00520);
   } 
   Id_00398 = Id_00518;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_00520 = 0;
   } 
   else { 
   Ls_FFCD0 = Is_00410;
   Ls_FFCC0 = "ask";
   if (Ls_FFCD0 == NULL) { 
   Ls_FFCD0 = _Symbol;
   } 
   if (Ls_FFCC0 == "ask") { 
   Id_007B0 = MarketInfo(Ls_FFCD0, MODE_ASK);
   } 
   else { 
   if (Ls_FFCC0 == "bid") { 
   Id_007B0 = MarketInfo(Ls_FFCD0, MODE_BID);
   } 
   else { 
   if (Ls_FFCC0 == "point") { 
   Id_007B0 = MarketInfo(Ls_FFCD0, MODE_POINT);
   } 
   else { 
   if (Ls_FFCC0 == "digits") { 
   Id_007B0 = MarketInfo(Ls_FFCD0, MODE_DIGITS);
   } 
   else { 
   Id_007B0 = 0;
   }}}} 
   Id_00520 = ((TakeProfit * Id_001F8) + Id_007B0);
   } 
   Id_003A8 = Id_00520;
   Ls_FFCB0 = EAComment;
   Ls_FFCA0 = Is_00410;
   Ls_FFC90 = "ask";
   if (Ls_FFCA0 == NULL) { 
   Ls_FFCA0 = _Symbol;
   } 
   if (Ls_FFC90 == "ask") { 
   Id_00540 = MarketInfo(Ls_FFCA0, MODE_ASK);
   } 
   else { 
   if (Ls_FFC90 == "bid") { 
   Id_00540 = MarketInfo(Ls_FFCA0, MODE_BID);
   } 
   else { 
   if (Ls_FFC90 == "point") { 
   Id_00540 = MarketInfo(Ls_FFCA0, MODE_POINT);
   } 
   else { 
   if (Ls_FFC90 == "digits") { 
   Id_00540 = MarketInfo(Ls_FFCA0, MODE_DIGITS);
   } 
   else { 
   Id_00540 = 0;
   }}}} 
   Ls_FFC80 = _Symbol;
   tmp_str0000A = Ls_FFCB0;
   tmp_str0000B = _Symbol;
   Li_FF97C = func_1030(tmp_str0000B, 0, ((Ld_FF980 * Id_00428) / 100), Id_00540, Slippage, Id_00398, Id_00520, tmp_str0000A, MagicNumber, 0, 16711680);
   }}}}}} 
   if (Lb_FF9AE && UseGrid) { 
   Id_00548 = (GridPips * Id_001F8);
   if (((Ld_FF9A0 - Id_00548) >= Ask)) { 
   Ii_00554 = 0;
   Ii_00558 = 0;
   Ii_0055C = OrdersTotal() - 1;
   Ii_00560 = Ii_0055C;
   if (Ii_0055C >= 0) { 
   do { 
   if (OrderSelect(Ii_00560, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00554 < 0) { 
   Ii_00558 = Ii_00558 + 1;
   } 
   else { 
   if (OrderType() == Ii_00554) { 
   Ii_00558 = Ii_00558 + 1;
   }}}} 
   Ii_00560 = Ii_00560 - 1;
   } while (Ii_00560 >= 0); 
   } 
   if (Ii_00558 > 0) { 
   Ii_0055C = 1;
   Ii_00564 = 0;
   Ii_00568 = OrdersTotal() - 1;
   Ii_0056C = Ii_00568;
   if (Ii_00568 >= 0) { 
   do { 
   if (OrderSelect(Ii_0056C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_0055C < 0) { 
   Ii_00564 = Ii_00564 + 1;
   } 
   else { 
   if (OrderType() == Ii_0055C) { 
   Ii_00564 = Ii_00564 + 1;
   }}}} 
   Ii_0056C = Ii_0056C - 1;
   } while (Ii_0056C >= 0); 
   } 
   if (Ii_00564 < 1) { 
   Ii_00568 = -1;
   Ii_00570 = 0;
   Ii_00574 = OrdersTotal() - 1;
   Ii_00578 = Ii_00574;
   if (Ii_00574 >= 0) { 
   do { 
   if (OrderSelect(Ii_00578, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00568 < 0) { 
   Ii_00570 = Ii_00570 + 1;
   } 
   else { 
   if (OrderType() == Ii_00568) { 
   Ii_00570 = Ii_00570 + 1;
   }}}} 
   Ii_00578 = Ii_00578 - 1;
   } while (Ii_00578 >= 0); 
   } 
   if (MaxOpenOrders > Ii_00570) { 
   Ld_FF970 = Ld_FF9B8;
   Li_FF96C = -1;
   Ls_FFC70 = NULL;
   Ib_0057C = true;
   if (Ls_FFC70 == NULL) { 
   Ls_FFC70 = _Symbol;
   } 
   Ii_00580 = OrdersTotal() - 1;
   Ii_00584 = Ii_00580;
   if (Ii_00580 >= 0) { 
   do { 
   if (OrderSelect(Ii_00584, 0, 0) && OrderSymbol() == Ls_FFC70) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Il_00588 = iTime(Ls_FFC70, 0, 0);
   if (Il_00588 <= OrderOpenTime()) { 
   Ib_0057C = false;
   break; 
   }}} 
   Ii_00584 = Ii_00584 - 1;
   } while (Ii_00584 >= 0); 
   } 
   if (Ib_0057C) { 
   Ls_FFC60 = NULL;
   Ib_00590 = true;
   if (Ls_FFC60 == NULL) { 
   Ls_FFC60 = _Symbol;
   } 
   Ii_00594 = HistoryTotal() - 1;
   Ii_00598 = Ii_00594;
   if (Ii_00594 >= 0) { 
   do { 
   if (OrderSelect(Ii_00598, 0, 1) && OrderSymbol() == Ls_FFC60) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Il_005A0 = iTime(Ls_FFC60, 0, 0);
   if (Il_005A0 <= OrderOpenTime()) { 
   Ib_00590 = false;
   break; 
   }}}} 
   Ii_00598 = Ii_00598 - 1;
   } while (Ii_00598 >= 0); 
   } 
   if (Ib_00590) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_005A8 = 0;
   } 
   else { 
   Id_005B0 = (StopLoss * Id_001F8);
   Id_005A8 = (Bid - Id_005B0);
   } 
   Id_00398 = Id_005A8;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_005B0 = 0;
   } 
   else { 
   Id_005B0 = ((TakeProfit * Id_001F8) + Ask);
   } 
   Id_003A8 = Id_005B0;
   Ls_FFC50 = EAComment;
   Ls_FFC40 = _Symbol;
   tmp_str0000C = EAComment;
   tmp_str0000D = _Symbol;
   Li_FF96C = func_1030(tmp_str0000D, 0, Ld_FF970, Ask, (Slippage * Ii_001E4), Id_00398, Id_005B0, tmp_str0000C, MagicNumber, 0, 16711680);
   }} 
   if (Ib_003B4 && Li_FF96C > 0) { 
   Ls_FFC30 = Is_00410;
   Ib_005BC = true;
   if (Ls_FFC30 == NULL) { 
   Ls_FFC30 = _Symbol;
   } 
   Ii_005C0 = OrdersTotal() - 1;
   Ii_005C4 = Ii_005C0;
   if (Ii_005C0 >= 0) { 
   do { 
   if (OrderSelect(Ii_005C4, 0, 0) && OrderSymbol() == Ls_FFC30) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Il_005C8 = iTime(Ls_FFC30, 0, 0);
   if (Il_005C8 <= OrderOpenTime()) { 
   Ib_005BC = false;
   break; 
   }}} 
   Ii_005C4 = Ii_005C4 - 1;
   } while (Ii_005C4 >= 0); 
   } 
   if (Ib_005BC) { 
   Ls_FFC20 = Is_00410;
   Ib_005D0 = true;
   if (Ls_FFC20 == NULL) { 
   Ls_FFC20 = _Symbol;
   } 
   Ii_005D4 = HistoryTotal() - 1;
   Ii_005D8 = Ii_005D4;
   if (Ii_005D4 >= 0) { 
   do { 
   if (OrderSelect(Ii_005D8, 0, 1) && OrderSymbol() == Ls_FFC20) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Il_005E0 = iTime(Ls_FFC20, 0, 0);
   if (Il_005E0 <= OrderOpenTime()) { 
   Ib_005D0 = false;
   break; 
   }}}} 
   Ii_005D8 = Ii_005D8 - 1;
   } while (Ii_005D8 >= 0); 
   } 
   if (Ib_005D0) { 
   if (Ii_003E0 == 0) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_005E8 = 0;
   } 
   else { 
   Ls_FFC10 = Is_00410;
   Ls_FFC00 = "bid";
   if (Ls_FFC10 == NULL) { 
   Ls_FFC10 = _Symbol;
   } 
   if (Ls_FFC00 == "ask") { 
   Id_007A8 = MarketInfo(Ls_FFC10, MODE_ASK);
   } 
   else { 
   if (Ls_FFC00 == "bid") { 
   Id_007A8 = MarketInfo(Ls_FFC10, MODE_BID);
   } 
   else { 
   if (Ls_FFC00 == "point") { 
   Id_007A8 = MarketInfo(Ls_FFC10, MODE_POINT);
   } 
   else { 
   if (Ls_FFC00 == "digits") { 
   Id_007A8 = MarketInfo(Ls_FFC10, MODE_DIGITS);
   } 
   else { 
   Id_007A8 = 0;
   }}}} 
   Id_005F0 = (StopLoss * Id_001F8);
   Id_005E8 = (Id_007A8 - Id_005F0);
   } 
   Id_00398 = Id_005E8;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_005F0 = 0;
   } 
   else { 
   Ls_FFBF0 = Is_00410;
   Ls_FFBE0 = "ask";
   if (Ls_FFBF0 == NULL) { 
   Ls_FFBF0 = _Symbol;
   } 
   if (Ls_FFBE0 == "ask") { 
   Id_007A0 = MarketInfo(Ls_FFBF0, MODE_ASK);
   } 
   else { 
   if (Ls_FFBE0 == "bid") { 
   Id_007A0 = MarketInfo(Ls_FFBF0, MODE_BID);
   } 
   else { 
   if (Ls_FFBE0 == "point") { 
   Id_007A0 = MarketInfo(Ls_FFBF0, MODE_POINT);
   } 
   else { 
   if (Ls_FFBE0 == "digits") { 
   Id_007A0 = MarketInfo(Ls_FFBF0, MODE_DIGITS);
   } 
   else { 
   Id_007A0 = 0;
   }}}} 
   Id_005F0 = ((TakeProfit * Id_001F8) + Id_007A0);
   } 
   Id_003A8 = Id_005F0;
   Ls_FFBD0 = EAComment;
   Ls_FFBC0 = Is_00410;
   Ls_FFBB0 = "ask";
   if (Ls_FFBC0 == NULL) { 
   Ls_FFBC0 = _Symbol;
   } 
   if (Ls_FFBB0 == "ask") { 
   Id_00610 = MarketInfo(Ls_FFBC0, MODE_ASK);
   } 
   else { 
   if (Ls_FFBB0 == "bid") { 
   Id_00610 = MarketInfo(Ls_FFBC0, MODE_BID);
   } 
   else { 
   if (Ls_FFBB0 == "point") { 
   Id_00610 = MarketInfo(Ls_FFBC0, MODE_POINT);
   } 
   else { 
   if (Ls_FFBB0 == "digits") { 
   Id_00610 = MarketInfo(Ls_FFBC0, MODE_DIGITS);
   } 
   else { 
   Id_00610 = 0;
   }}}} 
   Ls_FFBA0 = _Symbol;
   tmp_str0000E = Ls_FFBD0;
   tmp_str0000F = _Symbol;
   Li_FF96C = func_1030(tmp_str0000F, 0, ((Ld_FF970 * Id_00428) / 100), Id_00610, Slippage, Id_00398, Id_005F0, tmp_str0000E, MagicNumber, 0, 16711680);
   } 
   if (Ii_003E0 == 1) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_00618 = 0;
   } 
   else { 
   Ls_FFB90 = Is_00410;
   Ls_FFB80 = "ask";
   if (Ls_FFB90 == NULL) { 
   Ls_FFB90 = _Symbol;
   } 
   if (Ls_FFB80 == "ask") { 
   Id_00798 = MarketInfo(Ls_FFB90, MODE_ASK);
   } 
   else { 
   if (Ls_FFB80 == "bid") { 
   Id_00798 = MarketInfo(Ls_FFB90, MODE_BID);
   } 
   else { 
   if (Ls_FFB80 == "point") { 
   Id_00798 = MarketInfo(Ls_FFB90, MODE_POINT);
   } 
   else { 
   if (Ls_FFB80 == "digits") { 
   Id_00798 = MarketInfo(Ls_FFB90, MODE_DIGITS);
   } 
   else { 
   Id_00798 = 0;
   }}}} 
   Id_00618 = ((StopLoss * Id_001F8) + Id_00798);
   } 
   Id_00398 = Id_00618;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_00618 = 0;
   } 
   else { 
   Ls_FFB70 = Is_00410;
   Ls_FFB60 = "bid";
   if (Ls_FFB70 == NULL) { 
   Ls_FFB70 = _Symbol;
   } 
   if (Ls_FFB60 == "ask") { 
   Id_00788 = MarketInfo(Ls_FFB70, MODE_ASK);
   } 
   else { 
   if (Ls_FFB60 == "bid") { 
   Id_00788 = MarketInfo(Ls_FFB70, MODE_BID);
   } 
   else { 
   if (Ls_FFB60 == "point") { 
   Id_00788 = MarketInfo(Ls_FFB70, MODE_POINT);
   } 
   else { 
   if (Ls_FFB60 == "digits") { 
   Id_00788 = MarketInfo(Ls_FFB70, MODE_DIGITS);
   } 
   else { 
   Id_00788 = 0;
   }}}} 
   Id_00790 = (TakeProfit * Id_001F8);
   Id_00618 = (Id_00788 - Id_00790);
   } 
   Id_003A8 = Id_00618;
   Ls_FFB50 = EAComment;
   Ls_FFB40 = Is_00410;
   Ls_FFB30 = "bid";
   if (Ls_FFB40 == NULL) { 
   Ls_FFB40 = _Symbol;
   } 
   if (Ls_FFB30 == "ask") { 
   Id_00638 = MarketInfo(Ls_FFB40, MODE_ASK);
   } 
   else { 
   if (Ls_FFB30 == "bid") { 
   Id_00638 = MarketInfo(Ls_FFB40, MODE_BID);
   } 
   else { 
   if (Ls_FFB30 == "point") { 
   Id_00638 = MarketInfo(Ls_FFB40, MODE_POINT);
   } 
   else { 
   if (Ls_FFB30 == "digits") { 
   Id_00638 = MarketInfo(Ls_FFB40, MODE_DIGITS);
   } 
   else { 
   Id_00638 = 0;
   }}}} 
   Ls_FFB20 = _Symbol;
   tmp_str00010 = Ls_FFB50;
   tmp_str00011 = _Symbol;
   Li_FF96C = func_1030(tmp_str00011, 1, ((Ld_FF970 * Id_00428) / 100), Id_00638, Slippage, Id_00398, Id_00618, tmp_str00010, MagicNumber, 0, 255);
   }}}}}}}}} 
   if (Lb_FF9AE && UseGrid && (((GridPips * Id_001F8) + Ld_FF998) <= Bid)) { 
   Ii_0064C = 1;
   Ii_00650 = 0;
   Ii_00654 = OrdersTotal() - 1;
   Ii_00658 = Ii_00654;
   if (Ii_00654 >= 0) { 
   do { 
   if (OrderSelect(Ii_00658, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_0064C < 0) { 
   Ii_00650 = Ii_00650 + 1;
   } 
   else { 
   if (OrderType() == Ii_0064C) { 
   Ii_00650 = Ii_00650 + 1;
   }}}} 
   Ii_00658 = Ii_00658 - 1;
   } while (Ii_00658 >= 0); 
   } 
   if (Ii_00650 > 0) { 
   Ii_00654 = 0;
   Ii_0065C = 0;
   Ii_00660 = OrdersTotal() - 1;
   Ii_00664 = Ii_00660;
   if (Ii_00660 >= 0) { 
   do { 
   if (OrderSelect(Ii_00664, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00654 < 0) { 
   Ii_0065C = Ii_0065C + 1;
   } 
   else { 
   if (OrderType() == Ii_00654) { 
   Ii_0065C = Ii_0065C + 1;
   }}}} 
   Ii_00664 = Ii_00664 - 1;
   } while (Ii_00664 >= 0); 
   } 
   if (Ii_0065C < 1 && (Ld_FF998 != 0)) { 
   Ii_00660 = -1;
   Ii_0066C = 0;
   Ii_00670 = OrdersTotal() - 1;
   Ii_00674 = Ii_00670;
   if (Ii_00670 >= 0) { 
   do { 
   if (OrderSelect(Ii_00674, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00660 < 0) { 
   Ii_0066C = Ii_0066C + 1;
   } 
   else { 
   if (OrderType() == Ii_00660) { 
   Ii_0066C = Ii_0066C + 1;
   }}}} 
   Ii_00674 = Ii_00674 - 1;
   } while (Ii_00674 >= 0); 
   } 
   if (MaxOpenOrders > Ii_0066C) { 
   Ld_FF960 = Ld_FF9B0;
   Li_FF95C = -1;
   Ls_FFB10 = NULL;
   Ib_00678 = true;
   if (Ls_FFB10 == NULL) { 
   Ls_FFB10 = _Symbol;
   } 
   Ii_0067C = OrdersTotal() - 1;
   Ii_00680 = Ii_0067C;
   if (Ii_0067C >= 0) { 
   do { 
   if (OrderSelect(Ii_00680, 0, 0) && OrderSymbol() == Ls_FFB10) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Il_00688 = iTime(Ls_FFB10, 0, 0);
   if (Il_00688 <= OrderOpenTime()) { 
   Ib_00678 = false;
   break; 
   }}} 
   Ii_00680 = Ii_00680 - 1;
   } while (Ii_00680 >= 0); 
   } 
   if (Ib_00678) { 
   Ls_FFB00 = NULL;
   Ib_00690 = true;
   if (Ls_FFB00 == NULL) { 
   Ls_FFB00 = _Symbol;
   } 
   Ii_00694 = HistoryTotal() - 1;
   Ii_00698 = Ii_00694;
   if (Ii_00694 >= 0) { 
   do { 
   if (OrderSelect(Ii_00698, 0, 1) && OrderSymbol() == Ls_FFB00) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Il_006A0 = iTime(Ls_FFB00, 0, 0);
   if (Il_006A0 <= OrderOpenTime()) { 
   Ib_00690 = false;
   break; 
   }}}} 
   Ii_00698 = Ii_00698 - 1;
   } while (Ii_00698 >= 0); 
   } 
   if (Ib_00690) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_006A8 = 0;
   } 
   else { 
   Id_006A8 = ((StopLoss * Id_001F8) + Ask);
   } 
   Id_00398 = Id_006A8;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_006A8 = 0;
   } 
   else { 
   Id_00780 = (TakeProfit * Id_001F8);
   Id_006A8 = (Bid - Id_00780);
   } 
   Id_003A8 = Id_006A8;
   Ls_FFAF0 = EAComment;
   Ls_FFAE0 = _Symbol;
   tmp_str00012 = EAComment;
   tmp_str00013 = _Symbol;
   Li_FF95C = func_1030(tmp_str00013, 1, Ld_FF960, Bid, (Slippage * Ii_001E4), Id_00398, Id_006A8, tmp_str00012, MagicNumber, 0, 255);
   }} 
   if (Ib_003B4 && Li_FF95C > 0) { 
   Ls_FFAD0 = Is_00410;
   Ib_006B4 = true;
   if (Ls_FFAD0 == NULL) { 
   Ls_FFAD0 = _Symbol;
   } 
   Ii_006B8 = OrdersTotal() - 1;
   Ii_006BC = Ii_006B8;
   if (Ii_006B8 >= 0) { 
   do { 
   if (OrderSelect(Ii_006BC, 0, 0) && OrderSymbol() == Ls_FFAD0) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Il_006C0 = iTime(Ls_FFAD0, 0, 0);
   if (Il_006C0 <= OrderOpenTime()) { 
   Ib_006B4 = false;
   break; 
   }}} 
   Ii_006BC = Ii_006BC - 1;
   } while (Ii_006BC >= 0); 
   } 
   if (Ib_006B4) { 
   Ls_FFAC0 = Is_00410;
   Ib_006C8 = true;
   if (Ls_FFAC0 == NULL) { 
   Ls_FFAC0 = _Symbol;
   } 
   Ii_006CC = HistoryTotal() - 1;
   Ii_006D0 = Ii_006CC;
   if (Ii_006CC >= 0) { 
   do { 
   if (OrderSelect(Ii_006D0, 0, 1) && OrderSymbol() == Ls_FFAC0) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Il_006D8 = iTime(Ls_FFAC0, 0, 0);
   if (Il_006D8 <= OrderOpenTime()) { 
   Ib_006C8 = false;
   break; 
   }}}} 
   Ii_006D0 = Ii_006D0 - 1;
   } while (Ii_006D0 >= 0); 
   } 
   if (Ib_006C8) { 
   if (Ii_003E0 == 0) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_006E0 = 0;
   } 
   else { 
   Ls_FFAB0 = Is_00410;
   Ls_FFAA0 = "ask";
   if (Ls_FFAB0 == NULL) { 
   Ls_FFAB0 = _Symbol;
   } 
   if (Ls_FFAA0 == "ask") { 
   Id_00778 = MarketInfo(Ls_FFAB0, MODE_ASK);
   } 
   else { 
   if (Ls_FFAA0 == "bid") { 
   Id_00778 = MarketInfo(Ls_FFAB0, MODE_BID);
   } 
   else { 
   if (Ls_FFAA0 == "point") { 
   Id_00778 = MarketInfo(Ls_FFAB0, MODE_POINT);
   } 
   else { 
   if (Ls_FFAA0 == "digits") { 
   Id_00778 = MarketInfo(Ls_FFAB0, MODE_DIGITS);
   } 
   else { 
   Id_00778 = 0;
   }}}} 
   Id_006E0 = ((StopLoss * Id_001F8) + Id_00778);
   } 
   Id_00398 = Id_006E0;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_006E0 = 0;
   } 
   else { 
   Ls_FFA90 = Is_00410;
   Ls_FFA80 = "bid";
   if (Ls_FFA90 == NULL) { 
   Ls_FFA90 = _Symbol;
   } 
   if (Ls_FFA80 == "ask") { 
   Id_00768 = MarketInfo(Ls_FFA90, MODE_ASK);
   } 
   else { 
   if (Ls_FFA80 == "bid") { 
   Id_00768 = MarketInfo(Ls_FFA90, MODE_BID);
   } 
   else { 
   if (Ls_FFA80 == "point") { 
   Id_00768 = MarketInfo(Ls_FFA90, MODE_POINT);
   } 
   else { 
   if (Ls_FFA80 == "digits") { 
   Id_00768 = MarketInfo(Ls_FFA90, MODE_DIGITS);
   } 
   else { 
   Id_00768 = 0;
   }}}} 
   Id_00770 = (TakeProfit * Id_001F8);
   Id_006E0 = (Id_00768 - Id_00770);
   } 
   Id_003A8 = Id_006E0;
   Ls_FFA70 = EAComment;
   Ls_FFA60 = Is_00410;
   Ls_FFA50 = "bid";
   if (Ls_FFA60 == NULL) { 
   Ls_FFA60 = _Symbol;
   } 
   if (Ls_FFA50 == "ask") { 
   Id_00700 = MarketInfo(Ls_FFA60, MODE_ASK);
   } 
   else { 
   if (Ls_FFA50 == "bid") { 
   Id_00700 = MarketInfo(Ls_FFA60, MODE_BID);
   } 
   else { 
   if (Ls_FFA50 == "point") { 
   Id_00700 = MarketInfo(Ls_FFA60, MODE_POINT);
   } 
   else { 
   if (Ls_FFA50 == "digits") { 
   Id_00700 = MarketInfo(Ls_FFA60, MODE_DIGITS);
   } 
   else { 
   Id_00700 = 0;
   }}}} 
   Ls_FFA40 = _Symbol;
   tmp_str00014 = Ls_FFA70;
   tmp_str00015 = _Symbol;
   Li_FF95C = func_1030(tmp_str00015, 1, ((Ld_FF960 * Id_00428) / 100), Id_00700, Slippage, Id_00398, Id_006E0, tmp_str00014, MagicNumber, 0, 255);
   } 
   if (Ii_003E0 == 1) { 
   if (CompareDoubles(0, StopLoss)) { 
   Id_00708 = 0;
   } 
   else { 
   Ls_FFA30 = Is_00410;
   Ls_FFA20 = "bid";
   if (Ls_FFA30 == NULL) { 
   Ls_FFA30 = _Symbol;
   } 
   if (Ls_FFA20 == "ask") { 
   Id_00760 = MarketInfo(Ls_FFA30, MODE_ASK);
   } 
   else { 
   if (Ls_FFA20 == "bid") { 
   Id_00760 = MarketInfo(Ls_FFA30, MODE_BID);
   } 
   else { 
   if (Ls_FFA20 == "point") { 
   Id_00760 = MarketInfo(Ls_FFA30, MODE_POINT);
   } 
   else { 
   if (Ls_FFA20 == "digits") { 
   Id_00760 = MarketInfo(Ls_FFA30, MODE_DIGITS);
   } 
   else { 
   Id_00760 = 0;
   }}}} 
   Id_00710 = (StopLoss * Id_001F8);
   Id_00708 = (Id_00760 - Id_00710);
   } 
   Id_00398 = Id_00708;
   if (CompareDoubles(0, TakeProfit)) { 
   Id_00710 = 0;
   } 
   else { 
   Ls_FFA10 = Is_00410;
   Ls_FFA00 = "ask";
   if (Ls_FFA10 == NULL) { 
   Ls_FFA10 = _Symbol;
   } 
   if (Ls_FFA00 == "ask") { 
   Id_00758 = MarketInfo(Ls_FFA10, MODE_ASK);
   } 
   else { 
   if (Ls_FFA00 == "bid") { 
   Id_00758 = MarketInfo(Ls_FFA10, MODE_BID);
   } 
   else { 
   if (Ls_FFA00 == "point") { 
   Id_00758 = MarketInfo(Ls_FFA10, MODE_POINT);
   } 
   else { 
   if (Ls_FFA00 == "digits") { 
   Id_00758 = MarketInfo(Ls_FFA10, MODE_DIGITS);
   } 
   else { 
   Id_00758 = 0;
   }}}} 
   Id_00710 = ((TakeProfit * Id_001F8) + Id_00758);
   } 
   Id_003A8 = Id_00710;
   Ls_FF9F0 = EAComment;
   Ls_FF9E0 = Is_00410;
   Ls_FF9D0 = "ask";
   if (Ls_FF9E0 == NULL) { 
   Ls_FF9E0 = _Symbol;
   } 
   if (Ls_FF9D0 == "ask") { 
   Id_00730 = MarketInfo(Ls_FF9E0, MODE_ASK);
   } 
   else { 
   if (Ls_FF9D0 == "bid") { 
   Id_00730 = MarketInfo(Ls_FF9E0, MODE_BID);
   } 
   else { 
   if (Ls_FF9D0 == "point") { 
   Id_00730 = MarketInfo(Ls_FF9E0, MODE_POINT);
   } 
   else { 
   if (Ls_FF9D0 == "digits") { 
   Id_00730 = MarketInfo(Ls_FF9E0, MODE_DIGITS);
   } 
   else { 
   Id_00730 = 0;
   }}}} 
   Ls_FF9C0 = _Symbol;
   tmp_str00016 = Ls_FF9F0;
   tmp_str00017 = _Symbol;
   Li_FF95C = func_1030(tmp_str00017, 0, ((Ld_FF960 * Id_00428) / 100), Id_00730, Slippage, Id_00398, Id_00710, tmp_str00016, MagicNumber, 0, 16711680);
   }}}}}}}} 
   if (AvoidNews != true) { 
   Ib_00740 = false;
   } 
   else { 
   if ((iCustom(_Symbol, 0, "urdala_news_investing.com", UTimeDo, UTimePosle, Uoffset, Vhigh, Vmedium, Vlow, 0, 0) != 0)) { 
   Ib_00740 = true;
   } 
   else { 
   Ib_00740 = false;
   }} 
   if (Ib_00740 != true) { 
   Is_00748 = "YES";
   } 
   else { 
   Is_00748 = "NO";
   } 
   if (ShowInfo == 0) { 
   return ;
   } 
   func_1038(Id_00398, Id_003A8);
   
}

void OnDeinit(const int reason)
{
   string Ls_FFFF0;
   string Ls_FFFE0;
   int Li_FFFDC;
   string Ls_FFFD0;

   Li_FFFDC = 0;
   Li_FFFDC = ObjectsTotal(-1);
   if (Li_FFFDC >= 0) { 
   do { 
   Ls_FFFD0 = ObjectName(Li_FFFDC);
   if (StringSubstr(Ls_FFFD0, 0, 4) == "Info") { 
   ObjectDelete(Ls_FFFD0);
   } 
   if (StringSubstr(Ls_FFFD0, 0, 4) == "Info") { 
   ObjectsDeleteAll(0, Is_00F54[Li_FFFDC], 28, -1);
   } 
   Li_FFFDC = Li_FFFDC - 1;
   } while (Li_FFFDC >= 0); 
   } 
   Ls_FFFF0 = Is_00210;
   Ii_0015C = 0;
   do { 
   Ii_0019C = GlobalVariablesTotal() - 1;
   Ii_001A0 = Ii_0019C;
   if (Ii_0019C >= 0) { 
   do { 
   Ls_FFFE0 = GlobalVariableName(Ii_001A0);
   if (StringFind(Ls_FFFE0, Ls_FFFF0, 0) > -1) { 
   GlobalVariableDel(Ls_FFFE0);
   } 
   Ii_001A0 = Ii_001A0 - 1;
   } while (Ii_001A0 >= 0); 
   } 
   Ii_0015C = Ii_0015C + 1;
   } while (Ii_0015C < 10); 
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   string Ls_FFFB0;
   string Ls_FFFA0;
   string Ls_FFF90;
   string Ls_FFF80;
   string Ls_FFF70;
   string Ls_FFF60;
   string Ls_FFF50;
   string Ls_FFF40;

   if (id != 1) { 
   return ;
   } 
   if (StringFind(sparam, "Warning_t", 0) <= 0) { 
   return ;
   } 
   Ls_FFF40 = Is_00180 + "Warning_";
   ObjectsDeleteAll(0, Ls_FFF40, -1, -1);
   ChartRedraw(0);
   
}

int func_1030(string Fa_s_00, int Fa_i_01, double Fa_d_02, double Fa_d_03, int Fa_i_04, double Fa_d_05, double Fa_d_06, string Fa_s_07, int Fa_i_08, long Fa_l_09, int Fa_i_0A)
{
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   int Li_FFFBC;
   int Li_FFFB8;
   int Li_FFFB4;
   int Li_FFFB0;
   int Li_FFFAC;
   int Li_FFFA8;
   int Li_FFFFC;

   Li_FFFBC = 0;
   Li_FFFB8 = 0;
   Li_FFFB4 = 0;
   Li_FFFB0 = 0;
   Li_FFFAC = 0;
   Li_FFFA8 = 0;
   Fa_d_02 = NormalizeDouble(Fa_d_02, Ii_00204);
   Fa_d_03 = NormalizeDouble(Fa_d_03, _Digits);
   Fa_d_05 = NormalizeDouble(Fa_d_05, _Digits);
   Fa_d_06 = NormalizeDouble(Fa_d_06, _Digits);
   Li_FFFBC = -1;
   Li_FFFB8 = 3;
   Li_FFFB4 = 0;
   do { 
   Li_FFFB0 = 0;
   if (Li_FFFB8 > 0 && IsTradeContextBusy()) { 
   do { 
   Sleep(10);
   Li_FFFB0 = Li_FFFB0 + 1;
   if (Li_FFFB0 >= Li_FFFB8) break; 
   } while (IsTradeContextBusy()); 
   } 
   RefreshRates();
   if (ECN_Acc != 0) { 
   Li_FFFBC = OrderSend(Fa_s_00, Fa_i_01, Fa_d_02, Fa_d_03, Fa_i_04, 0, 0, Fa_s_07, Fa_i_08, Fa_l_09, Fa_i_0A);
   if (Li_FFFBC > 0 && OrderSelect(Li_FFFBC, 1, 0)) { 
   Gb_00000 = (Fa_d_05 != 0);
   if (Gb_00000 != true && (Fa_d_06 == 0)) { 
   Li_FFFFC = Li_FFFBC;
   return Li_FFFFC;
   } 
   Li_FFFAC = 0;
   if (Li_FFFB8 <= 0){
   Li_FFFFC = Li_FFFBC;
   return Li_FFFFC;
   }
   do { 
   if (OrderModify(Li_FFFBC, OrderOpenPrice(), Fa_d_05, Fa_d_06, 0, 4294967295)) { 
   Li_FFFFC = Li_FFFBC;
   return Li_FFFFC;
   } 
   Sleep(10);
   Li_FFFAC = Li_FFFAC + 1;
   } while (Li_FFFAC < Li_FFFB8); 
   Li_FFFFC = Li_FFFBC;
   return Li_FFFFC;
   }} 
   Li_FFFBC = OrderSend(Fa_s_00, Fa_i_01, Fa_d_02, Fa_d_03, Fa_i_04, Fa_d_05, Fa_d_06, Fa_s_07, Fa_i_08, Fa_l_09, Fa_i_0A);
   if (Li_FFFBC > 0) { 
   Li_FFFFC = Li_FFFBC;
   return Li_FFFFC;
   } 
   Gi_00000 = GetLastError();
   Ii_00158 = Gi_00000;
   Ii_0015C = Gi_00000;
   Ii_0019C = Fa_i_01;
   if (Gi_00000 != 0) { 
   Ls_FFFF0 = "";
   if (Fa_i_01 == 0) { 
   Ls_FFFF0 = "OP_BUY";
   } 
   if (Ii_0019C == 1) { 
   Ls_FFFF0 = "OP_SELL";
   } 
   if (Ii_0019C == 2) { 
   Ls_FFFF0 = "OP_BUYLIMIT";
   } 
   if (Ii_0019C == 3) { 
   Ls_FFFF0 = "OP_SELLLIMIT";
   } 
   if (Ii_0019C == 4) { 
   Ls_FFFF0 = "OP_BUYSTOP";
   } 
   if (Ii_0019C == 5) { 
   Ls_FFFF0 = "OP_SELLSTOP";
   } 
   Ls_FFFD0 = ErrorDescription(Ii_0015C);
   Ls_FFFC0 = WindowExpertName();
   Ls_FFFE0 = StringConcatenate(_Symbol, ",", _Period, " ", Ls_FFFC0, " ", Ls_FFFF0, " order send failed with error(", Ii_0015C, "): ", Ls_FFFD0);
   Print(Ls_FFFE0);
   } 
   Li_FFFB4 = Li_FFFB4 + 1;
   } while (Li_FFFB4 < Li_FFFB8); 
   Li_FFFA8 = Li_FFFBC;
   Li_FFFFC = Li_FFFBC;
   
   return Li_FFFFC;
}

void func_1031()
{
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   string Ls_FFFB0;
   string Ls_FFFA0;
   string Ls_FFF90;
   string Ls_FFF80;
   string Ls_FFF70;
   string Ls_FFF60;
   string Ls_FFF50;
   string Ls_FFF40;
   string Ls_FFF30;
   string Ls_FFF20;
   string Ls_FFF10;
   string Ls_FFF00;
   string Ls_FFEF0;
   string Ls_FFEE0;
   string Ls_FFED0;
   string Ls_FFEC0;
   string Ls_FFEB0;
   string Ls_FFEA0;
   string Ls_FFE90;
   string Ls_FFE80;
   string Ls_FFE70;
   string Ls_FFE60;
   string Ls_FFE50;
   string Ls_FFE40;
   string Ls_FFE30;
   string Ls_FFE20;
   string Ls_FFE10;
   string Ls_FFE00;
   string Ls_FFDF0;
   string Ls_FFDE0;
   string Ls_FFDD0;
   string Ls_FFDC0;
   string Ls_FFDB0;
   string Ls_FFDA0;
   string Ls_FFD90;
   string Ls_FFD80;
   string Ls_FFD70;
   string Ls_FFD60;

   if (Ib_0088C) { 
   Ii_00158 = 0;
   Ii_0015C = 0;
   Ii_0019C = OrdersTotal() - 1;
   Ii_001A0 = Ii_0019C;
   if (Ii_0019C >= 0) { 
   do { 
   if (OrderSelect(Ii_001A0, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00158 < 0) { 
   Ii_0015C = Ii_0015C + 1;
   } 
   else { 
   if (OrderType() == Ii_00158) { 
   Ii_0015C = Ii_0015C + 1;
   }}}} 
   Ii_001A0 = Ii_001A0 - 1;
   } while (Ii_001A0 >= 0); 
   } 
   if (Ii_0015C > 0) { 
   Ls_FFFF0 = Is_00210 + "EORb";
   if ((GlobalVariableGet(Ls_FFFF0) == 0) && Ib_002B3) { 
   Ls_FFFE0 = Is_00210 + "EORb";
   GlobalVariableSet(Ls_FFFE0, 1);
   } 
   Ls_FFFD0 = Is_00210 + "EORb";
   if ((GlobalVariableGet(Ls_FFFD0) == 1)) { 
   Ii_0019C = 0;
   Ii_001A4 = 2147483647;
   Ii_001B0 = -1;
   Ii_001B4 = OrdersTotal() - 1;
   Ii_001C0 = Ii_001B4;
   if (Ii_001B4 >= 0) { 
   do { 
   if (OrderSelect(Ii_001C0, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_0019C || Ii_0019C == -1) { 
   
   Ii_001B4 = OrderTicket();
   Ii_001C4 = Ii_001A4;
   if (Ii_001A4 < Ii_001B4) { 
   Ii_001B4 = Ii_001A4;
   } 
   Ii_001A4 = Ii_001B4;
   Ii_001B0 = Ii_001B4;
   }}}} 
   Ii_001C0 = Ii_001C0 - 1;
   } while (Ii_001C0 >= 0); 
   } 
   if (func_1036(0, Ii_001B0)) { 
   Print("-> Exit with RMI!");
   }}} 
   Ii_001B4 = 1;
   Ii_001CC = 0;
   Ii_001D8 = OrdersTotal() - 1;
   Ii_001DC = Ii_001D8;
   if (Ii_001D8 >= 0) { 
   do { 
   if (OrderSelect(Ii_001DC, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_001B4 < 0) { 
   Ii_001CC = Ii_001CC + 1;
   } 
   else { 
   if (OrderType() == Ii_001B4) { 
   Ii_001CC = Ii_001CC + 1;
   }}}} 
   Ii_001DC = Ii_001DC - 1;
   } while (Ii_001DC >= 0); 
   } 
   if (Ii_001CC > 0) { 
   Ls_FFFC0 = Is_00210 + "EORs";
   if ((GlobalVariableGet(Ls_FFFC0) == 0) && Ib_002B1) { 
   Ls_FFFB0 = Is_00210 + "EORs";
   GlobalVariableSet(Ls_FFFB0, 1);
   } 
   Ls_FFFA0 = Is_00210 + "EORs";
   if ((GlobalVariableGet(Ls_FFFA0) == 1)) { 
   Ii_001D8 = 1;
   Ii_001E0 = 2147483647;
   Ii_00208 = -1;
   Ii_008FC = OrdersTotal() - 1;
   Ii_00900 = Ii_008FC;
   if (Ii_008FC >= 0) { 
   do { 
   if (OrderSelect(Ii_00900, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_001D8 || Ii_001D8 == -1) { 
   
   Ii_008FC = OrderTicket();
   Ii_00904 = Ii_001E0;
   if (Ii_001E0 < Ii_008FC) { 
   Ii_008FC = Ii_001E0;
   } 
   Ii_001E0 = Ii_008FC;
   Ii_00208 = Ii_008FC;
   }}}} 
   Ii_00900 = Ii_00900 - 1;
   } while (Ii_00900 >= 0); 
   } 
   if (func_1036(1, Ii_00208)) { 
   Print("-> Exit with RMI!");
   }}}} 
   if (UseCloseAtPipsProfits) { 
   Ii_008FC = 0;
   Ii_00908 = 0;
   Ii_0090C = OrdersTotal() - 1;
   Ii_00910 = Ii_0090C;
   if (Ii_0090C >= 0) { 
   do { 
   if (OrderSelect(Ii_00910, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_008FC < 0) { 
   Ii_00908 = Ii_00908 + 1;
   } 
   else { 
   if (OrderType() == Ii_008FC) { 
   Ii_00908 = Ii_00908 + 1;
   }}}} 
   Ii_00910 = Ii_00910 - 1;
   } while (Ii_00910 >= 0); 
   } 
   if (Ii_00908 > 0) { 
   Ls_FFF90 = Is_00210 + "EPPb";
   if ((GlobalVariableGet(Ls_FFF90) == 0)) { 
   Id_00280 = func_1034(0);
   if ((PipsProfit < Id_00280)) { 
   Ls_FFF80 = Is_00210 + "EPPb";
   GlobalVariableSet(Ls_FFF80, 1);
   }} 
   Ls_FFF70 = Is_00210 + "EPPb";
   if ((GlobalVariableGet(Ls_FFF70) == 1)) { 
   Ii_0090C = 0;
   Ii_00918 = 2147483647;
   Ii_0091C = -1;
   Ii_00920 = OrdersTotal() - 1;
   Ii_00924 = Ii_00920;
   if (Ii_00920 >= 0) { 
   do { 
   if (OrderSelect(Ii_00924, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_0090C || Ii_0090C == -1) { 
   
   Ii_00920 = OrderTicket();
   Ii_002B8 = Ii_00918;
   if (Ii_00918 < Ii_00920) { 
   Ii_00920 = Ii_00918;
   } 
   Ii_00918 = Ii_00920;
   Ii_0091C = Ii_00920;
   }}}} 
   Ii_00924 = Ii_00924 - 1;
   } while (Ii_00924 >= 0); 
   } 
   if (func_1036(0, Ii_0091C)) { 
   Print("-> Exit with pips profits!");
   }}} 
   Ii_00920 = 1;
   Ii_00928 = 0;
   Ii_0092C = OrdersTotal() - 1;
   Ii_00930 = Ii_0092C;
   if (Ii_0092C >= 0) { 
   do { 
   if (OrderSelect(Ii_00930, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00920 < 0) { 
   Ii_00928 = Ii_00928 + 1;
   } 
   else { 
   if (OrderType() == Ii_00920) { 
   Ii_00928 = Ii_00928 + 1;
   }}}} 
   Ii_00930 = Ii_00930 - 1;
   } while (Ii_00930 >= 0); 
   } 
   if (Ii_00928 > 0) { 
   Ls_FFF60 = Is_00210 + "EPPs";
   if ((GlobalVariableGet(Ls_FFF60) == 0)) { 
   Id_002C8 = func_1034(1);
   if ((PipsProfit < Id_002C8)) { 
   Ls_FFF50 = Is_00210 + "EPPs";
   GlobalVariableSet(Ls_FFF50, 1);
   }} 
   Ls_FFF40 = Is_00210 + "EPPs";
   if ((GlobalVariableGet(Ls_FFF40) == 1)) { 
   Ii_0092C = 1;
   Ii_002D8 = 2147483647;
   Ii_002DC = -1;
   Ii_002E0 = OrdersTotal() - 1;
   Ii_002E4 = Ii_002E0;
   if (Ii_002E0 >= 0) { 
   do { 
   if (OrderSelect(Ii_002E4, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_0092C || Ii_0092C == -1) { 
   
   Ii_002E0 = OrderTicket();
   Ii_002E8 = Ii_002D8;
   if (Ii_002D8 < Ii_002E0) { 
   Ii_002E0 = Ii_002D8;
   } 
   Ii_002D8 = Ii_002E0;
   Ii_002DC = Ii_002E0;
   }}}} 
   Ii_002E4 = Ii_002E4 - 1;
   } while (Ii_002E4 >= 0); 
   } 
   if (func_1036(1, Ii_002DC)) { 
   Print("-> Exit with pips profits!");
   }}}} 
   if (Ib_003B4 && Ib_0089C) { 
   Ls_FFF30 = Is_00210 + "EPPbh";
   if ((GlobalVariableGet(Ls_FFF30) == 0)) { 
   Id_00938 = func_1035(0);
   if ((Ii_008A0 < Id_00938)) { 
   Ls_FFF20 = Is_00210 + "EPPbh";
   GlobalVariableSet(Ls_FFF20, 1);
   }} 
   Ls_FFF10 = Is_00210 + "EPPbh";
   if ((GlobalVariableGet(Ls_FFF10) == 1)) { 
   Ii_002E0 = 0;
   Ii_002F8 = 2147483647;
   Ii_00940 = -1;
   Ii_00944 = OrdersTotal() - 1;
   Ii_00948 = Ii_00944;
   if (Ii_00944 >= 0) { 
   do { 
   if (OrderSelect(Ii_00948, 0, 0) && OrderSymbol() == Is_00410) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_002E0 || Ii_002E0 == -1) { 
   
   Ii_00944 = OrderTicket();
   Ii_00318 = Ii_002F8;
   if (Ii_002F8 < Ii_00944) { 
   Ii_00944 = Ii_002F8;
   } 
   Ii_002F8 = Ii_00944;
   Ii_00940 = Ii_00944;
   }}}} 
   Ii_00948 = Ii_00948 - 1;
   } while (Ii_00948 >= 0); 
   } 
   Ib_0094C = false;
   if (OrderSelect(Ii_00940, 1, 0)) { 
   if (OrderType() == OP_BUY) { 
   Ib_0094C = OrderClose(Ii_00940, OrderLots(), OrderClosePrice(), 1000, 55295);
   } 
   Ii_0031C = 0;
   do { 
   if (Ii_00DC4[Ii_0031C] == 0) { 
   Ii_00324 = OrderTicket();
   Ii_00DC4[Ii_0031C] = Ii_00324;
   break; 
   } 
   Ii_0031C = Ii_0031C + 1;
   } while (Ii_0031C < 100); 
   } 
   if (Ib_0094C) { 
   Ii_00324 = 0;
   Ii_00338 = 2147483647;
   Ii_0033C = -1;
   Ii_00340 = OrdersTotal() - 1;
   Ii_00344 = Ii_00340;
   if (Ii_00340 >= 0) { 
   do { 
   if (OrderSelect(Ii_00344, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_00324 || Ii_00324 == -1) { 
   
   Ii_00340 = OrderTicket();
   Ii_00348 = Ii_00338;
   if (Ii_00338 < Ii_00340) { 
   Ii_00340 = Ii_00338;
   } 
   Ii_00338 = Ii_00340;
   Ii_0033C = Ii_00340;
   }}}} 
   Ii_00344 = Ii_00344 - 1;
   } while (Ii_00344 >= 0); 
   } 
   if (func_1036(0, Ii_0033C)) { 
   Print("-> Exit with pips profits!");
   }}} 
   Ls_FFF00 = Is_00210 + "EPPsh";
   if ((GlobalVariableGet(Ls_FFF00) == 0)) { 
   Id_00960 = func_1035(1);
   if ((Ii_008A0 < Id_00960)) { 
   Ls_FFEF0 = Is_00210 + "EPPsh";
   GlobalVariableSet(Ls_FFEF0, 1);
   }} 
   Ls_FFEE0 = Is_00210 + "EPPsh";
   if ((GlobalVariableGet(Ls_FFEE0) == 1)) { 
   Ii_00340 = 1;
   Ii_0034C = 2147483647;
   Ii_00350 = -1;
   Ii_00354 = OrdersTotal() - 1;
   Ii_00358 = Ii_00354;
   if (Ii_00354 >= 0) { 
   do { 
   if (OrderSelect(Ii_00358, 0, 0) && OrderSymbol() == Is_00410) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_00340 || Ii_00340 == -1) { 
   
   Ii_00354 = OrderTicket();
   Ii_0035C = Ii_0034C;
   if (Ii_0034C < Ii_00354) { 
   Ii_00354 = Ii_0034C;
   } 
   Ii_0034C = Ii_00354;
   Ii_00350 = Ii_00354;
   }}}} 
   Ii_00358 = Ii_00358 - 1;
   } while (Ii_00358 >= 0); 
   } 
   Ib_00968 = false;
   if (OrderSelect(Ii_00350, 1, 0)) { 
   if (OrderType() == OP_SELL) { 
   Ib_00968 = OrderClose(Ii_00350, OrderLots(), OrderClosePrice(), 1000, 55295);
   } 
   Ii_00360 = 0;
   do { 
   if (Ii_00DC4[Ii_00360] == 0) { 
   Ii_0036C = OrderTicket();
   Ii_00DC4[Ii_00360] = Ii_0036C;
   break; 
   } 
   Ii_00360 = Ii_00360 + 1;
   } while (Ii_00360 < 100); 
   } 
   if (Ib_00968) { 
   Ii_0036C = 1;
   Ii_00380 = 2147483647;
   Ii_00978 = -1;
   Ii_003B0 = OrdersTotal() - 1;
   Ii_003B8 = Ii_003B0;
   if (Ii_003B0 >= 0) { 
   do { 
   if (OrderSelect(Ii_003B8, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_0036C || Ii_0036C == -1) { 
   
   Ii_003B0 = OrderTicket();
   Ii_003BC = Ii_00380;
   if (Ii_00380 < Ii_003B0) { 
   Ii_003B0 = Ii_00380;
   } 
   Ii_00380 = Ii_003B0;
   Ii_00978 = Ii_003B0;
   }}}} 
   Ii_003B8 = Ii_003B8 - 1;
   } while (Ii_003B8 >= 0); 
   } 
   if (func_1036(1, Ii_00978)) { 
   Print("-> Exit with pips profits!");
   }}}} 
   if (Ib_008B4) { 
   Ls_FFED0 = Is_00210 + "EPb";
   if ((GlobalVariableGet(Ls_FFED0) == 0)) { 
   Ii_003B0 = 0;
   Id_003E8 = 0;
   Id_00980 = 0;
   Ii_00988 = OrdersTotal() - 1;
   Ii_0098C = Ii_00988;
   if (Ii_00988 >= 0) { 
   do { 
   if (OrderSelect(Ii_0098C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_00800 = OrderProfit();
   Id_00800 = (Id_00800 + OrderSwap());
   Id_003E8 = ((Id_00800 + OrderCommission()) + Id_003E8);
   } 
   if (OrderType() == OP_SELL) { 
   Id_00800 = OrderProfit();
   Id_00800 = (Id_00800 + OrderSwap());
   Id_00980 = ((Id_00800 + OrderCommission()) + Id_00980);
   }}} 
   Ii_0098C = Ii_0098C - 1;
   } while (Ii_0098C >= 0); 
   } 
   Id_00800 = 0;
   if (Ii_003B0 == 0) { 
   Id_00800 = Id_003E8;
   } 
   if (Ii_003B0 == 1) { 
   Id_00800 = Id_00980;
   } 
   if (Ii_003B0 == -1) { 
   Id_00800 = (Id_003E8 + Id_00980);
   } 
   if ((Id_00800 > 0)) { 
   Ii_00994 = 0;
   Id_00998 = 0;
   Id_00400 = 0;
   Ii_00408 = OrdersTotal() - 1;
   Ii_009A0 = Ii_00408;
   if (Ii_00408 >= 0) { 
   do { 
   if (OrderSelect(Ii_009A0, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_009A8 = OrderProfit();
   Id_009A8 = (Id_009A8 + OrderSwap());
   Id_00998 = ((Id_009A8 + OrderCommission()) + Id_00998);
   } 
   if (OrderType() == OP_SELL) { 
   Id_009A8 = OrderProfit();
   Id_009A8 = (Id_009A8 + OrderSwap());
   Id_00400 = ((Id_009A8 + OrderCommission()) + Id_00400);
   }}} 
   Ii_009A0 = Ii_009A0 - 1;
   } while (Ii_009A0 >= 0); 
   } 
   Id_009A8 = 0;
   if (Ii_00994 == 0) { 
   Id_009A8 = Id_00998;
   } 
   if (Ii_00994 == 1) { 
   Id_009A8 = Id_00400;
   } 
   if (Ii_00994 == -1) { 
   Id_009A8 = (Id_00998 + Id_00400);
   } 
   if ((Id_008B8 <= Id_009A8)) { 
   Ls_FFEC0 = Is_00210 + "EPb";
   GlobalVariableSet(Ls_FFEC0, 1);
   }}} 
   Ls_FFEB0 = Is_00210 + "EPb";
   if ((GlobalVariableGet(Ls_FFEB0) == 1)) { 
   Ii_009B4 = 0;
   Ii_009B8 = 0;
   Ii_009BC = OrdersTotal() - 1;
   Ii_00438 = Ii_009BC;
   if (Ii_009BC >= 0) { 
   do { 
   if (OrderSelect(Ii_00438, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_009B4 < 0) { 
   Ii_009B8 = Ii_009B8 + 1;
   } 
   else { 
   if (OrderType() == Ii_009B4) { 
   Ii_009B8 = Ii_009B8 + 1;
   }}}} 
   Ii_00438 = Ii_00438 - 1;
   } while (Ii_00438 >= 0); 
   } 
   if (Ii_009B8 > 0) { 
   Ii_009BC = 0;
   Ii_009C0 = 2147483647;
   Ii_00448 = -1;
   Ii_009C4 = OrdersTotal() - 1;
   Ii_00460 = Ii_009C4;
   if (Ii_009C4 >= 0) { 
   do { 
   if (OrderSelect(Ii_00460, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_009BC || Ii_009BC == -1) { 
   
   Ii_009C4 = OrderTicket();
   Ii_00464 = Ii_009C0;
   if (Ii_009C0 < Ii_009C4) { 
   Ii_009C4 = Ii_009C0;
   } 
   Ii_009C0 = Ii_009C4;
   Ii_00448 = Ii_009C4;
   }}}} 
   Ii_00460 = Ii_00460 - 1;
   } while (Ii_00460 >= 0); 
   } 
   if (func_1036(0, Ii_00448)) { 
   Print("-> Exit with pips profits!");
   }}} 
   Ls_FFEA0 = Is_00210 + "EPs";
   if ((GlobalVariableGet(Ls_FFEA0) == 0)) { 
   Ii_009C4 = 1;
   Id_009D0 = 0;
   Id_009D8 = 0;
   Ii_00470 = OrdersTotal() - 1;
   Ii_00474 = Ii_00470;
   if (Ii_00470 >= 0) { 
   do { 
   if (OrderSelect(Ii_00474, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_009E0 = OrderProfit();
   Id_009E0 = (Id_009E0 + OrderSwap());
   Id_009D0 = ((Id_009E0 + OrderCommission()) + Id_009D0);
   } 
   if (OrderType() == OP_SELL) { 
   Id_009E0 = OrderProfit();
   Id_009E0 = (Id_009E0 + OrderSwap());
   Id_009D8 = ((Id_009E0 + OrderCommission()) + Id_009D8);
   }}} 
   Ii_00474 = Ii_00474 - 1;
   } while (Ii_00474 >= 0); 
   } 
   Id_009E0 = 0;
   if (Ii_009C4 == 0) { 
   Id_009E0 = Id_009D0;
   } 
   if (Ii_009C4 == 1) { 
   Id_009E0 = Id_009D8;
   } 
   if (Ii_009C4 == -1) { 
   Id_009E0 = (Id_009D0 + Id_009D8);
   } 
   if ((Id_009E0 > 0)) { 
   Ii_00478 = 1;
   Id_009F0 = 0;
   Id_009F8 = 0;
   Ii_00484 = OrdersTotal() - 1;
   Ii_00488 = Ii_00484;
   if (Ii_00484 >= 0) { 
   do { 
   if (OrderSelect(Ii_00488, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_00A00 = OrderProfit();
   Id_00A00 = (Id_00A00 + OrderSwap());
   Id_009F0 = ((Id_00A00 + OrderCommission()) + Id_009F0);
   } 
   if (OrderType() == OP_SELL) { 
   Id_00A00 = OrderProfit();
   Id_00A00 = (Id_00A00 + OrderSwap());
   Id_009F8 = ((Id_00A00 + OrderCommission()) + Id_009F8);
   }}} 
   Ii_00488 = Ii_00488 - 1;
   } while (Ii_00488 >= 0); 
   } 
   Id_00A00 = 0;
   if (Ii_00478 == 0) { 
   Id_00A00 = Id_009F0;
   } 
   if (Ii_00478 == 1) { 
   Id_00A00 = Id_009F8;
   } 
   if (Ii_00478 == -1) { 
   Id_00A00 = (Id_009F0 + Id_009F8);
   } 
   if ((Id_008B8 <= Id_00A00)) { 
   Ls_FFE90 = Is_00210 + "EPs";
   GlobalVariableSet(Ls_FFE90, 1);
   }}} 
   Ls_FFE80 = Is_00210 + "EPs";
   if ((GlobalVariableGet(Ls_FFE80) == 1)) { 
   Ii_00490 = 1;
   Ii_00494 = 0;
   Ii_004A4 = OrdersTotal() - 1;
   Ii_004A8 = Ii_004A4;
   if (Ii_004A4 >= 0) { 
   do { 
   if (OrderSelect(Ii_004A8, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00490 < 0) { 
   Ii_00494 = Ii_00494 + 1;
   } 
   else { 
   if (OrderType() == Ii_00490) { 
   Ii_00494 = Ii_00494 + 1;
   }}}} 
   Ii_004A8 = Ii_004A8 - 1;
   } while (Ii_004A8 >= 0); 
   } 
   if (Ii_00494 > 0) { 
   Ii_004A4 = 1;
   Ii_004C0 = 2147483647;
   Ii_004C8 = -1;
   Ii_004CC = OrdersTotal() - 1;
   Ii_004DC = Ii_004CC;
   if (Ii_004CC >= 0) { 
   do { 
   if (OrderSelect(Ii_004DC, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_004A4 || Ii_004A4 == -1) { 
   
   Ii_004CC = OrderTicket();
   Ii_004E0 = Ii_004C0;
   if (Ii_004C0 < Ii_004CC) { 
   Ii_004CC = Ii_004C0;
   } 
   Ii_004C0 = Ii_004CC;
   Ii_004C8 = Ii_004CC;
   }}}} 
   Ii_004DC = Ii_004DC - 1;
   } while (Ii_004DC >= 0); 
   } 
   if (func_1036(1, Ii_004C8)) { 
   Print("-> Exit with $ profits!");
   }}}} 
   if (CloseAtPercentLoss) { 
   Ii_004CC = 0;
   Ii_00A08 = 0;
   Ii_00A0C = OrdersTotal() - 1;
   Ii_004F8 = Ii_00A0C;
   if (Ii_00A0C >= 0) { 
   do { 
   if (OrderSelect(Ii_004F8, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_004CC < 0) { 
   Ii_00A08 = Ii_00A08 + 1;
   } 
   else { 
   if (OrderType() == Ii_004CC) { 
   Ii_00A08 = Ii_00A08 + 1;
   }}}} 
   Ii_004F8 = Ii_004F8 - 1;
   } while (Ii_004F8 >= 0); 
   } 
   if (Ii_00A08 > 0) { 
   Ls_FFE70 = Is_00210 + "EPlb";
   if ((GlobalVariableGet(Ls_FFE70) == 0)) { 
   Ii_00A0C = 0;
   Id_00500 = 0;
   Id_00A18 = 0;
   Ii_00A20 = OrdersTotal() - 1;
   Ii_00A24 = Ii_00A20;
   if (Ii_00A20 >= 0) { 
   do { 
   if (OrderSelect(Ii_00A24, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_00510 = OrderProfit();
   Id_00510 = (Id_00510 + OrderSwap());
   Id_00500 = ((Id_00510 + OrderCommission()) + Id_00500);
   } 
   if (OrderType() == OP_SELL) { 
   Id_00510 = OrderProfit();
   Id_00510 = (Id_00510 + OrderSwap());
   Id_00A18 = ((Id_00510 + OrderCommission()) + Id_00A18);
   }}} 
   Ii_00A24 = Ii_00A24 - 1;
   } while (Ii_00A24 >= 0); 
   } 
   Id_00510 = 0;
   if (Ii_00A0C == 0) { 
   Id_00510 = Id_00500;
   } 
   if (Ii_00A0C == 1) { 
   Id_00510 = Id_00A18;
   } 
   if (Ii_00A0C == -1) { 
   Id_00510 = (Id_00500 + Id_00A18);
   } 
   if ((Id_00510 < 0)) { 
   Ii_00A2C = 0;
   Id_00520 = 0;
   Id_007B0 = 0;
   Ii_00528 = OrdersTotal() - 1;
   Ii_00A30 = Ii_00528;
   if (Ii_00528 >= 0) { 
   do { 
   if (OrderSelect(Ii_00A30, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_00A38 = OrderProfit();
   Id_00A38 = (Id_00A38 + OrderSwap());
   Id_00520 = ((Id_00A38 + OrderCommission()) + Id_00520);
   } 
   if (OrderType() == OP_SELL) { 
   Id_00A38 = OrderProfit();
   Id_00A38 = (Id_00A38 + OrderSwap());
   Id_007B0 = ((Id_00A38 + OrderCommission()) + Id_007B0);
   }}} 
   Ii_00A30 = Ii_00A30 - 1;
   } while (Ii_00A30 >= 0); 
   } 
   Id_00A38 = 0;
   if (Ii_00A2C == 0) { 
   Id_00A38 = Id_00520;
   } 
   if (Ii_00A2C == 1) { 
   Id_00A38 = Id_007B0;
   } 
   if (Ii_00A2C == -1) { 
   Id_00A38 = (Id_00520 + Id_007B0);
   } 
   Id_00A40 = fabs(Id_00A38);
   if ((Id_00A40 > ((PercentLoss * AccountBalance()) / 100))) { 
   Ls_FFE60 = Is_00210 + "EPlb";
   GlobalVariableSet(Ls_FFE60, 1);
   }}} 
   Ls_FFE50 = Is_00210 + "EPlb";
   if ((GlobalVariableGet(Ls_FFE50) == 1)) { 
   Ii_00538 = 0;
   Ii_00A4C = 2147483647;
   Ii_00554 = -1;
   Ii_00558 = OrdersTotal() - 1;
   Ii_0055C = Ii_00558;
   if (Ii_00558 >= 0) { 
   do { 
   if (OrderSelect(Ii_0055C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_00538 || Ii_00538 == -1) { 
   
   Ii_00558 = OrderTicket();
   Ii_00560 = Ii_00A4C;
   if (Ii_00A4C < Ii_00558) { 
   Ii_00558 = Ii_00A4C;
   } 
   Ii_00A4C = Ii_00558;
   Ii_00554 = Ii_00558;
   }}}} 
   Ii_0055C = Ii_0055C - 1;
   } while (Ii_0055C >= 0); 
   } 
   if (func_1036(0, Ii_00554)) { 
   Print("-> Exit with % loss!");
   }}} 
   Ii_00558 = 1;
   Ii_00564 = 0;
   Ii_00568 = OrdersTotal() - 1;
   Ii_0056C = Ii_00568;
   if (Ii_00568 >= 0) { 
   do { 
   if (OrderSelect(Ii_0056C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00558 < 0) { 
   Ii_00564 = Ii_00564 + 1;
   } 
   else { 
   if (OrderType() == Ii_00558) { 
   Ii_00564 = Ii_00564 + 1;
   }}}} 
   Ii_0056C = Ii_0056C - 1;
   } while (Ii_0056C >= 0); 
   } 
   if (Ii_00564 > 0) { 
   Ls_FFE40 = Is_00210 + "EPls";
   if ((GlobalVariableGet(Ls_FFE40) == 0)) { 
   Ii_00568 = 1;
   Id_00A58 = 0;
   Id_00A60 = 0;
   Ii_00578 = OrdersTotal() - 1;
   Ii_00580 = Ii_00578;
   if (Ii_00578 >= 0) { 
   do { 
   if (OrderSelect(Ii_00580, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_00A68 = OrderProfit();
   Id_00A68 = (Id_00A68 + OrderSwap());
   Id_00A58 = ((Id_00A68 + OrderCommission()) + Id_00A58);
   } 
   if (OrderType() == OP_SELL) { 
   Id_00A68 = OrderProfit();
   Id_00A68 = (Id_00A68 + OrderSwap());
   Id_00A60 = ((Id_00A68 + OrderCommission()) + Id_00A60);
   }}} 
   Ii_00580 = Ii_00580 - 1;
   } while (Ii_00580 >= 0); 
   } 
   Id_00A68 = 0;
   if (Ii_00568 == 0) { 
   Id_00A68 = Id_00A58;
   } 
   if (Ii_00568 == 1) { 
   Id_00A68 = Id_00A60;
   } 
   if (Ii_00568 == -1) { 
   Id_00A68 = (Id_00A58 + Id_00A60);
   } 
   if ((Id_00A68 < 0)) { 
   Ii_00584 = 1;
   Id_005A8 = 0;
   Id_00A78 = 0;
   Ii_00A80 = OrdersTotal() - 1;
   Ii_005B8 = Ii_00A80;
   if (Ii_00A80 >= 0) { 
   do { 
   if (OrderSelect(Ii_005B8, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_005B0 = OrderProfit();
   Id_005B0 = (Id_005B0 + OrderSwap());
   Id_005A8 = ((Id_005B0 + OrderCommission()) + Id_005A8);
   } 
   if (OrderType() == OP_SELL) { 
   Id_005B0 = OrderProfit();
   Id_005B0 = (Id_005B0 + OrderSwap());
   Id_00A78 = ((Id_005B0 + OrderCommission()) + Id_00A78);
   }}} 
   Ii_005B8 = Ii_005B8 - 1;
   } while (Ii_005B8 >= 0); 
   } 
   Id_005B0 = 0;
   if (Ii_00584 == 0) { 
   Id_005B0 = Id_005A8;
   } 
   if (Ii_00584 == 1) { 
   Id_005B0 = Id_00A78;
   } 
   if (Ii_00584 == -1) { 
   Id_005B0 = (Id_005A8 + Id_00A78);
   } 
   Id_00A88 = fabs(Id_005B0);
   if ((Id_00A88 > ((PercentLoss * AccountBalance()) / 100))) { 
   Ls_FFE30 = Is_00210 + "EPls";
   GlobalVariableSet(Ls_FFE30, 1);
   }}} 
   Ls_FFE20 = Is_00210 + "EPls";
   if ((GlobalVariableGet(Ls_FFE20) == 1)) { 
   Ii_005C0 = 1;
   Ii_005C4 = 2147483647;
   Ii_005D4 = -1;
   Ii_005D8 = OrdersTotal() - 1;
   Ii_00A90 = Ii_005D8;
   if (Ii_005D8 >= 0) { 
   do { 
   if (OrderSelect(Ii_00A90, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   if (OrderType() == Ii_005C0 || Ii_005C0 == -1) { 
   
   Ii_005D8 = OrderTicket();
   Ii_00A94 = Ii_005C4;
   if (Ii_005C4 < Ii_005D8) { 
   Ii_005D8 = Ii_005C4;
   } 
   Ii_005C4 = Ii_005D8;
   Ii_005D4 = Ii_005D8;
   }}}} 
   Ii_00A90 = Ii_00A90 - 1;
   } while (Ii_00A90 >= 0); 
   } 
   if (func_1036(1, Ii_005D4)) { 
   Print("-> Exit with % loss!");
   }}}} 
   Ii_005D8 = 0;
   Ii_00A98 = 0;
   Ii_005F8 = OrdersTotal() - 1;
   Ii_00A9C = Ii_005F8;
   if (Ii_005F8 >= 0) { 
   do { 
   if (OrderSelect(Ii_00A9C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_005D8 < 0) { 
   Ii_00A98 = Ii_00A98 + 1;
   } 
   else { 
   if (OrderType() == Ii_005D8) { 
   Ii_00A98 = Ii_00A98 + 1;
   }}}} 
   Ii_00A9C = Ii_00A9C - 1;
   } while (Ii_00A9C >= 0); 
   } 
   if (Ii_00A98 < 1) { 
   Ls_FFE10 = Is_00210 + "EORb";
   GlobalVariableSet(Ls_FFE10, 0);
   Ls_FFE00 = Is_00210 + "EOSb";
   GlobalVariableSet(Ls_FFE00, 0);
   Ls_FFDF0 = Is_00210 + "EPPb";
   GlobalVariableSet(Ls_FFDF0, 0);
   Ls_FFDE0 = Is_00210 + "EPPbh";
   GlobalVariableSet(Ls_FFDE0, 0);
   Ls_FFDD0 = Is_00210 + "EPb";
   GlobalVariableSet(Ls_FFDD0, 0);
   Ls_FFDC0 = Is_00210 + "EPlb";
   GlobalVariableSet(Ls_FFDC0, 0);
   } 
   Ii_005F8 = 1;
   Ii_00608 = 0;
   Ii_00AA0 = OrdersTotal() - 1;
   Ii_00AA4 = Ii_00AA0;
   if (Ii_00AA0 >= 0) { 
   do { 
   if (OrderSelect(Ii_00AA4, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_005F8 < 0) { 
   Ii_00608 = Ii_00608 + 1;
   } 
   else { 
   if (OrderType() == Ii_005F8) { 
   Ii_00608 = Ii_00608 + 1;
   }}}} 
   Ii_00AA4 = Ii_00AA4 - 1;
   } while (Ii_00AA4 >= 0); 
   } 
   if (Ii_00608 >= 1) { 
   return ;
   } 
   Ls_FFDB0 = Is_00210 + "EORs";
   GlobalVariableSet(Ls_FFDB0, 0);
   Ls_FFDA0 = Is_00210 + "EOSs";
   GlobalVariableSet(Ls_FFDA0, 0);
   Ls_FFD90 = Is_00210 + "EPPs";
   GlobalVariableSet(Ls_FFD90, 0);
   Ls_FFD80 = Is_00210 + "EPPsh";
   GlobalVariableSet(Ls_FFD80, 0);
   Ls_FFD70 = Is_00210 + "EPs";
   GlobalVariableSet(Ls_FFD70, 0);
   Ls_FFD60 = Is_00210 + "EPls";
   GlobalVariableSet(Ls_FFD60, 0);
   
}

void func_1032()
{
   double Ld_FFFF8;
   double Ld_FFFF0;
   double Ld_FFFE8;
   double Ld_FFFE0;
   double Ld_FFFD8;
   double Ld_FFFD0;
   double Ld_FFFC8;
   double Ld_FFFC0;
   double Ld_FFFB8;
   double Ld_FFFB0;
   double Ld_FFFA8;
   double Ld_FFFA0;
   int Li_FFF9C;
   int Li_FFF98;
   bool Lb_FFF97;
   bool Lb_FFF96;

   Ld_FFFF8 = 0;
   Ld_FFFF0 = 0;
   Ld_FFFE8 = 0;
   Ld_FFFE0 = 0;
   Ld_FFFD8 = 0;
   Ld_FFFD0 = 0;
   Ld_FFFC8 = 0;
   Ld_FFFC0 = 0;
   Ld_FFFB8 = 0;
   Ld_FFFB0 = 0;
   Ld_FFFA8 = 0;
   Ld_FFFA0 = 0;
   Li_FFF9C = 0;
   Li_FFF98 = 0;
   Lb_FFF97 = false;
   Lb_FFF96 = false;
   Ld_FFFF8 = 0;
   Ld_FFFF0 = 0;
   Ld_FFFE8 = 0;
   Ld_FFFE0 = 0;
   Ld_FFFD8 = 0;
   Ld_FFFD0 = 0;
   Ld_FFFC8 = 0;
   Ld_FFFC0 = 0;
   Ld_FFFB8 = 0;
   Ld_FFFB0 = 0;
   Ld_FFFA8 = 0;
   Ld_FFFA0 = 0;
   Li_FFF9C = OrdersTotal() - 1;
   if (Li_FFF9C >= 0) { 
   do { 
   if (OrderSelect(Li_FFF9C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_00AA8 = OrderOpenPrice();
   Ld_FFFE8 = ((Id_00AA8 * OrderLots()) + Ld_FFFE8);
   Ld_FFFE0 = (Ld_FFFE0 + OrderLots());
   } 
   if (OrderType() == OP_SELL) { 
   Id_00AA8 = OrderOpenPrice();
   Ld_FFFB8 = ((Id_00AA8 * OrderLots()) + Ld_FFFB8);
   Ld_FFFB0 = (Ld_FFFB0 + OrderLots());
   }}} 
   Li_FFF9C = Li_FFF9C - 1;
   } while (Li_FFF9C >= 0); 
   } 
   Ii_00158 = 0;
   Ii_0015C = 0;
   Ii_0019C = OrdersTotal() - 1;
   Ii_001A0 = Ii_0019C;
   if (Ii_0019C >= 0) { 
   do { 
   if (OrderSelect(Ii_001A0, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00158 < 0) { 
   Ii_0015C = Ii_0015C + 1;
   } 
   else { 
   if (OrderType() == Ii_00158) { 
   Ii_0015C = Ii_0015C + 1;
   }}}} 
   Ii_001A0 = Ii_001A0 - 1;
   } while (Ii_001A0 >= 0); 
   } 
   if (Ii_0015C > 0 && (Ld_FFFE8 != 0)) { 
   Ld_FFFD0 = NormalizeDouble((Ld_FFFE8 / Ld_FFFE0), _Digits);
   } 
   Ii_0019C = 1;
   Ii_001A4 = 0;
   Ii_001B0 = OrdersTotal() - 1;
   Ii_001B4 = Ii_001B0;
   if (Ii_001B0 >= 0) { 
   do { 
   if (OrderSelect(Ii_001B4, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_0019C < 0) { 
   Ii_001A4 = Ii_001A4 + 1;
   } 
   else { 
   if (OrderType() == Ii_0019C) { 
   Ii_001A4 = Ii_001A4 + 1;
   }}}} 
   Ii_001B4 = Ii_001B4 - 1;
   } while (Ii_001B4 >= 0); 
   } 
   if (Ii_001A4 > 0 && (Ld_FFFB8 != 0)) { 
   Ld_FFFA0 = NormalizeDouble((Ld_FFFB8 / Ld_FFFB0), _Digits);
   } 
   Li_FFF98 = OrdersTotal() - 1;
   if (Li_FFF98 < 0) return; 
   do { 
   if (OrderSelect(Li_FFF98, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Id_00AC8 = (Bid - Ld_FFFD0);
   if ((TrailingStopStart < NormalizeDouble((Id_00AC8 / Id_001F8), 0))) { 
   Ld_FFFF8 = NormalizeDouble(OrderStopLoss(), _Digits);
   Id_00AC8 = (TrailingStopStep * Id_001F8);
   Ld_FFFF0 = NormalizeDouble((Bid - Id_00AC8), _Digits);
   if (CompareDoubles(0, Ld_FFFF8)
   || (CompareDoubles(0, Ld_FFFF8) == 0 && Ld_FFFF0 > Ld_FFFF8)) {
   
   Lb_FFF97 = OrderModify(OrderTicket(), Ld_FFFD0, Ld_FFFF0, OrderTakeProfit(), 0, 16776960);
   }}} 
   if (OrderType() == OP_SELL) { 
   Id_00AD0 = (Ld_FFFA0 - Ask);
   if ((TrailingStopStart < NormalizeDouble((Id_00AD0 / Id_001F8), 0))) { 
   Ld_FFFC8 = NormalizeDouble(OrderStopLoss(), _Digits);
   Ld_FFFC0 = NormalizeDouble(((TrailingStopStep * Id_001F8) + Ask), _Digits);
   if (CompareDoubles(0, Ld_FFFC8)
   || (CompareDoubles(0, Ld_FFFC8) == 0 && Ld_FFFC0 < Ld_FFFC8)) {
   
   Lb_FFF96 = OrderModify(OrderTicket(), Ld_FFFA0, Ld_FFFC0, OrderTakeProfit(), 0, 255);
   }}} 
   Sleep(1000);
   }} 
   Li_FFF98 = Li_FFF98 - 1;
   } while (Li_FFF98 >= 0); 
   
}

void func_1033(double &Fa_d_00, double &Fa_d_01)
{
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   double Ld_FFFB8;
   double Ld_FFFB0;
   double Ld_FFFA8;
   double Ld_FFFA0;
   double Ld_FFF98;
   double Ld_FFF90;
   double Ld_FFF88;

   Ld_FFFB8 = 0;
   Ld_FFFB0 = 0;
   Ld_FFFA8 = 0;
   Ld_FFFA0 = 0;
   Ld_FFF98 = 0;
   Ld_FFF90 = 0;
   Ld_FFF88 = 0;
   Fa_d_01 = FixedLots;
   Fa_d_00 = FixedLots;
   Ld_FFFB8 = 0;
   Ld_FFFB0 = 0;
   Ld_FFFA8 = 0;
   if ((AccountBalance() != 0)) { 
   Id_00AA8 = AccountBalance();
   Id_00AA8 = (Id_00AA8 - AccountEquity());
   Id_00AE0 = Id_008E0;
   if ((Id_008E0 <= Id_00AA8) != true) { 
   Id_00AA8 = Id_008E0;
   } 
   Id_008E0 = Id_00AA8;
   Id_00AA8 = (Id_00AA8 * 100);
   Id_008C0 = (Id_00AA8 / AccountBalance());
   } 
   Ls_FFFF0 = "profit";
   Id_00AA8 = 0;
   Id_00AB8 = 0;
   Id_00AE8 = 0;
   Ii_001A4 = 0;
   Ii_001B0 = 0;
   Ii_001B4 = 0;
   Ii_001C0 = HistoryTotal() - 1;
   Ii_001C4 = Ii_001C0;
   if (Ii_001C0 >= 0) { 
   do { 
   if (OrderSelect(Ii_001C4, 0, 1) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Ii_001B0 = OrderTicket();
   if (Ii_001A4 < Ii_001B0) { 
   Ii_001A4 = Ii_001B0;
   Id_00AA8 = OrderOpenPrice();
   Ii_001B4 = OrderTicket();
   Id_00AB8 = OrderLots();
   Id_00AD0 = OrderProfit();
   Id_00AD0 = (Id_00AD0 + OrderSwap());
   Id_00AE8 = (Id_00AD0 + OrderCommission());
   }}} 
   Ii_001C4 = Ii_001C4 - 1;
   } while (Ii_001C4 >= 0); 
   } 
   Id_00AD0 = 0;
   if (Ls_FFFF0 == "price") { 
   Id_00AD0 = Id_00AA8;
   } 
   else { 
   if (Ls_FFFF0 == "ticket") { 
   Id_00AD0 = Ii_001B4;
   } 
   else { 
   if (Ls_FFFF0 == "lot") { 
   Id_00AD0 = Id_00AB8;
   } 
   else { 
   if (Ls_FFFF0 == "profit") { 
   Id_00AD0 = Id_00AE8;
   }}}} 
   Ld_FFFA0 = Id_00AD0;
   if (UseGrid) { 
   Ls_FFFE0 = "lot";
   Ii_001CC = 0;
   Id_00AF0 = 0;
   Id_00AF8 = 0;
   Id_00B00 = 0;
   Ii_00208 = 0;
   Ii_008FC = 0;
   Ii_00900 = 0;
   Ii_00904 = OrdersTotal() - 1;
   Ii_00908 = Ii_00904;
   if (Ii_00904 >= 0) { 
   do { 
   if (OrderSelect(Ii_00908, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == Ii_001CC || Ii_001CC < 0) { 
   
   Ii_008FC = OrderTicket();
   if (Ii_00208 < Ii_008FC) { 
   Ii_00208 = Ii_008FC;
   Id_00AF0 = OrderOpenPrice();
   Ii_00900 = OrderTicket();
   Id_00AF8 = OrderLots();
   Id_00B08 = OrderProfit();
   Id_00B08 = (Id_00B08 + OrderSwap());
   Id_00B00 = (Id_00B08 + OrderCommission());
   }}}} 
   Ii_00908 = Ii_00908 - 1;
   } while (Ii_00908 >= 0); 
   } 
   Id_00B08 = 0;
   if (Ls_FFFE0 == "price") { 
   Id_00B08 = Id_00AF0;
   } 
   else { 
   if (Ls_FFFE0 == "ticket") { 
   Id_00B08 = Ii_00900;
   } 
   else { 
   if (Ls_FFFE0 == "lot") { 
   Id_00B08 = Id_00AF8;
   } 
   else { 
   if (Ls_FFFE0 == "profit") { 
   Id_00B08 = Id_00B00;
   }}}} 
   Ld_FFFB8 = Id_00B08;
   Ls_FFFD0 = "lot";
   Ii_0090C = 1;
   Id_00288 = 0;
   Id_00B10 = 0;
   Id_00B18 = 0;
   Ii_00920 = 0;
   Ii_00924 = 0;
   Ii_002B8 = 0;
   Ii_00928 = OrdersTotal() - 1;
   Ii_0092C = Ii_00928;
   if (Ii_00928 >= 0) { 
   do { 
   if (OrderSelect(Ii_0092C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == Ii_0090C || Ii_0090C < 0) { 
   
   Ii_00924 = OrderTicket();
   if (Ii_00920 < Ii_00924) { 
   Ii_00920 = Ii_00924;
   Id_00288 = OrderOpenPrice();
   Ii_002B8 = OrderTicket();
   Id_00B10 = OrderLots();
   Id_002C0 = OrderProfit();
   Id_002C0 = (Id_002C0 + OrderSwap());
   Id_00B18 = (Id_002C0 + OrderCommission());
   }}}} 
   Ii_0092C = Ii_0092C - 1;
   } while (Ii_0092C >= 0); 
   } 
   Id_002C0 = 0;
   if (Ls_FFFD0 == "price") { 
   Id_002C0 = Id_00288;
   } 
   else { 
   if (Ls_FFFD0 == "ticket") { 
   Id_002C0 = Ii_002B8;
   } 
   else { 
   if (Ls_FFFD0 == "lot") { 
   Id_002C0 = Id_00B10;
   } 
   else { 
   if (Ls_FFFD0 == "profit") { 
   Id_002C0 = Id_00B18;
   }}}} 
   Ld_FFFB0 = Id_002C0;
   } 
   else { 
   Ls_FFFC0 = "lot";
   Id_002D0 = 0;
   Id_00B58 = 0;
   Id_00B60 = 0;
   Ii_002E0 = 0;
   Ii_002E4 = 0;
   Ii_002E8 = 0;
   Ii_002F8 = HistoryTotal() - 1;
   Ii_00940 = Ii_002F8;
   if (Ii_002F8 >= 0) { 
   do { 
   if (OrderSelect(Ii_00940, 0, 1) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Ii_002E4 = OrderTicket();
   if (Ii_002E0 < Ii_002E4) { 
   Ii_002E0 = Ii_002E4;
   Id_002D0 = OrderOpenPrice();
   Ii_002E8 = OrderTicket();
   Id_00B58 = OrderLots();
   Id_00B68 = OrderProfit();
   Id_00B68 = (Id_00B68 + OrderSwap());
   Id_00B60 = (Id_00B68 + OrderCommission());
   }}} 
   Ii_00940 = Ii_00940 - 1;
   } while (Ii_00940 >= 0); 
   } 
   Id_00B68 = 0;
   if (Ls_FFFC0 == "price") { 
   Id_00B68 = Id_002D0;
   } 
   else { 
   if (Ls_FFFC0 == "ticket") { 
   Id_00B68 = Ii_002E8;
   } 
   else { 
   if (Ls_FFFC0 == "lot") { 
   Id_00B68 = Id_00B58;
   } 
   else { 
   if (Ls_FFFC0 == "profit") { 
   Id_00B68 = Id_00B60;
   }}}} 
   Ld_FFFA8 = Id_00B68;
   } 
   if (Martingale2) { 
   if (UseGrid != 0) {
   Ii_00944 = 1;
   Ii_00948 = 0;
   Ii_00318 = OrdersTotal() - 1;
   Ii_0031C = Ii_00318;
   if (Ii_00318 >= 0) { 
   do { 
   if (OrderSelect(Ii_0031C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00944 < 0) { 
   Ii_00948 = Ii_00948 + 1;
   } 
   else { 
   if (OrderType() == Ii_00944) { 
   Ii_00948 = Ii_00948 + 1;
   }}}} 
   Ii_0031C = Ii_0031C - 1;
   } while (Ii_0031C >= 0); 
   } 
   if (Ii_00948 > 0) { 
   Fa_d_01 = NormalizeDouble((Ld_FFFB0 * MultiplierLot), Ii_00204);
   } 
   Ii_00318 = 0;
   Ii_00320 = 0;
   Ii_00324 = OrdersTotal() - 1;
   Ii_00328 = Ii_00324;
   if (Ii_00324 >= 0) { 
   do { 
   if (OrderSelect(Ii_00328, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00318 < 0) { 
   Ii_00320 = Ii_00320 + 1;
   } 
   else { 
   if (OrderType() == Ii_00318) { 
   Ii_00320 = Ii_00320 + 1;
   }}}} 
   Ii_00328 = Ii_00328 - 1;
   } while (Ii_00328 >= 0); 
   } 
   if (Ii_00320 > 0) {
   Fa_d_00 = NormalizeDouble((Ld_FFFB8 * MultiplierLot), Ii_00204);
   }}
   else{
   if ((Ld_FFFA0 < 0)) { 
   Fa_d_01 = NormalizeDouble((Ld_FFFA8 * MultiplierLot), Ii_00204);
   Fa_d_00 = Fa_d_01;
   }}} 
   if (Martingale1) { 
   if (UseGrid) { 
   Ii_00324 = 0;
   Ii_00338 = 0;
   Ii_0033C = OrdersTotal() - 1;
   Ii_00340 = Ii_0033C;
   if (Ii_0033C >= 0) { 
   do { 
   if (OrderSelect(Ii_00340, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_00324 < 0) { 
   Ii_00338 = Ii_00338 + 1;
   } 
   else { 
   if (OrderType() == Ii_00324) { 
   Ii_00338 = Ii_00338 + 1;
   }}}} 
   Ii_00340 = Ii_00340 - 1;
   } while (Ii_00340 >= 0); 
   } 
   Ii_0033C = Ii_00338 + 1;
   Fa_d_00 = (FixedLots * Ii_0033C);
   Ii_0033C = 1;
   Ii_00344 = 0;
   Ii_00348 = OrdersTotal() - 1;
   Ii_0034C = Ii_00348;
   if (Ii_00348 >= 0) { 
   do { 
   if (OrderSelect(Ii_0034C, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (Ii_0033C < 0) { 
   Ii_00344 = Ii_00344 + 1;
   } 
   else { 
   if (OrderType() == Ii_0033C) { 
   Ii_00344 = Ii_00344 + 1;
   }}}} 
   Ii_0034C = Ii_0034C - 1;
   } while (Ii_0034C >= 0); 
   } 
   Ii_00348 = Ii_00344 + 1;
   Fa_d_01 = (FixedLots * Ii_00348);
   } 
   else { 
   if ((Ld_FFFA0 < 0)) { 
   Fa_d_01 = (Ld_FFFA8 + FixedLots);
   Fa_d_00 = Fa_d_01;
   }}} 
   if (LotIncrease) { 
   Id_00B28 = AccountBalance();
   Id_00B28 = (Id_00B28 - AccountBalance());
   Id_00B28 = floor((Id_00B28 / BalansStep));
   Ld_FFF98 = (Id_00B28 * Increase);
   Fa_d_00 = (Ld_FFF98 + Fa_d_00);
   Fa_d_01 = (Fa_d_01 + Ld_FFF98);
   } 
   Ld_FFF90 = MarketInfo(_Symbol, MODE_MINLOT);
   Ld_FFF88 = MarketInfo(_Symbol, MODE_MAXLOT);
   Id_00B28 = Ld_FFF88;
   Id_00B30 = Fa_d_00;
   if ((Id_00B30 <= Ld_FFF90)) { 
   Id_00B38 = Ld_FFF90;
   } 
   else { 
   Id_00B38 = Id_00B30;
   } 
   if ((Id_00B38 >= Id_00B28)) { 
   Id_00B30 = Id_00B28;
   } 
   else { 
   Id_00B30 = Id_00B38;
   } 
   Fa_d_00 = Id_00B30;
   Id_00B30 = Ld_FFF88;
   Id_00B40 = Fa_d_01;
   if ((Id_00B40 <= Ld_FFF90)) { 
   Id_00B48 = Ld_FFF90;
   } 
   else { 
   Id_00B48 = Id_00B40;
   } 
   if ((Id_00B48 >= Id_00B30)) { 
   Id_00B40 = Id_00B30;
   } 
   else { 
   Id_00B40 = Id_00B48;
   } 
   Fa_d_01 = Id_00B40;
}

double func_1034(int Fa_i_00)
{
   string Ls_FFFE8;
   string Ls_FFFD8;
   string Ls_FFFC8;
   string Ls_FFFB8;
   double Ld_FFFB0;
   double Ld_FFFA8;
   int Li_FFFA4;
   double Ld_FFF98;
   double Ld_FFF90;
   double Ld_FFFF8;

   Ld_FFFB0 = 0;
   Ld_FFFA8 = 0;
   Li_FFFA4 = 0;
   Ld_FFF98 = 0;
   Ld_FFF90 = 0;
   Ld_FFFB0 = 0;
   Ld_FFFA8 = 0;
   Li_FFFA4 = OrdersTotal() - 1;
   if (Li_FFFA4 >= 0) { 
   do { 
   if (OrderSelect(Li_FFFA4, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FFFE8 = NULL;
   Ls_FFFD8 = "bid";
   if (Ls_FFFE8 == NULL) { 
   Ls_FFFE8 = _Symbol;
   } 
   if (Ls_FFFD8 == "ask") { 
   Id_00AA8 = MarketInfo(Ls_FFFE8, MODE_ASK);
   } 
   else { 
   if (Ls_FFFD8 == "bid") { 
   Id_00AA8 = MarketInfo(Ls_FFFE8, MODE_BID);
   } 
   else { 
   if (Ls_FFFD8 == "point") { 
   Id_00AA8 = MarketInfo(Ls_FFFE8, MODE_POINT);
   } 
   else { 
   if (Ls_FFFD8 == "digits") { 
   Id_00AA8 = MarketInfo(Ls_FFFE8, MODE_DIGITS);
   } 
   else { 
   Id_00AA8 = 0;
   }}}} 
   Id_00AE0 = (Id_00AA8 - OrderOpenPrice());
   Ld_FFFB0 = ((Id_00AE0 / Id_001F8) + Ld_FFFB0);
   } 
   if (OrderType() == OP_SELL) { 
   Id_00AE0 = OrderOpenPrice();
   Ls_FFFC8 = NULL;
   Ls_FFFB8 = "ask";
   if (Ls_FFFC8 == NULL) { 
   Ls_FFFC8 = _Symbol;
   } 
   if (Ls_FFFB8 == "ask") { 
   Id_00AB8 = MarketInfo(Ls_FFFC8, MODE_ASK);
   } 
   else { 
   if (Ls_FFFB8 == "bid") { 
   Id_00AB8 = MarketInfo(Ls_FFFC8, MODE_BID);
   } 
   else { 
   if (Ls_FFFB8 == "point") { 
   Id_00AB8 = MarketInfo(Ls_FFFC8, MODE_POINT);
   } 
   else { 
   if (Ls_FFFB8 == "digits") { 
   Id_00AB8 = MarketInfo(Ls_FFFC8, MODE_DIGITS);
   } 
   else { 
   Id_00AB8 = 0;
   }}}} 
   Id_00AE0 = (Id_00AE0 - Id_00AB8);
   Ld_FFFA8 = ((Id_00AE0 / Id_001F8) + Ld_FFFA8);
   }}} 
   Li_FFFA4 = Li_FFFA4 - 1;
   } while (Li_FFFA4 >= 0); 
   } 
   Ld_FFF98 = 0;
   if (Fa_i_00 == 0) { 
   Ld_FFF98 = Ld_FFFB0;
   } 
   if (Fa_i_00 == 1) { 
   Ld_FFF98 = Ld_FFFA8;
   } 
   if (Fa_i_00 != -1) { 
   Ld_FFFF8 = Ld_FFF98;
   return Ld_FFFF8;
   } 
   Ld_FFF98 = (Ld_FFFB0 + Ld_FFFA8);
   Ld_FFF90 = Ld_FFF98;
   Ld_FFFF8 = Ld_FFF98;
   
   return Ld_FFFF8;
}

double func_1035(int Fa_i_00)
{
   string Ls_FFFE8;
   string Ls_FFFD8;
   string Ls_FFFC8;
   string Ls_FFFB8;
   string Ls_FFFA8;
   string Ls_FFF98;
   string Ls_FFF88;
   string Ls_FFF78;
   double Ld_FFF70;
   double Ld_FFF68;
   int Li_FFF64;
   double Ld_FFF58;
   double Ld_FFF50;
   double Ld_FFFF8;

   Ld_FFF70 = 0;
   Ld_FFF68 = 0;
   Li_FFF64 = 0;
   Ld_FFF58 = 0;
   Ld_FFF50 = 0;
   Ld_FFF70 = 0;
   Ld_FFF68 = 0;
   Li_FFF64 = OrdersTotal() - 1;
   if (Li_FFF64 >= 0) { 
   do { 
   if (OrderSelect(Li_FFF64, 0, 0)) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderSymbol() == _Symbol) { 
   if (OrderType() == OP_BUY) { 
   Ls_FFFE8 = NULL;
   Ls_FFFD8 = "bid";
   if (Ls_FFFE8 == NULL) { 
   Ls_FFFE8 = _Symbol;
   } 
   if (Ls_FFFD8 == "ask") { 
   Id_00AA8 = MarketInfo(Ls_FFFE8, MODE_ASK);
   } 
   else { 
   if (Ls_FFFD8 == "bid") { 
   Id_00AA8 = MarketInfo(Ls_FFFE8, MODE_BID);
   } 
   else { 
   if (Ls_FFFD8 == "point") { 
   Id_00AA8 = MarketInfo(Ls_FFFE8, MODE_POINT);
   } 
   else { 
   if (Ls_FFFD8 == "digits") { 
   Id_00AA8 = MarketInfo(Ls_FFFE8, MODE_DIGITS);
   } 
   else { 
   Id_00AA8 = 0;
   }}}} 
   Id_00AE0 = (Id_00AA8 - OrderOpenPrice());
   Ld_FFF70 = ((Id_00AE0 / Id_001F8) + Ld_FFF70);
   } 
   if (OrderType() == OP_SELL) { 
   Id_00AE0 = OrderOpenPrice();
   Ls_FFFC8 = NULL;
   Ls_FFFB8 = "ask";
   if (Ls_FFFC8 == NULL) { 
   Ls_FFFC8 = _Symbol;
   } 
   if (Ls_FFFB8 == "ask") { 
   Id_00AB8 = MarketInfo(Ls_FFFC8, MODE_ASK);
   } 
   else { 
   if (Ls_FFFB8 == "bid") { 
   Id_00AB8 = MarketInfo(Ls_FFFC8, MODE_BID);
   } 
   else { 
   if (Ls_FFFB8 == "point") { 
   Id_00AB8 = MarketInfo(Ls_FFFC8, MODE_POINT);
   } 
   else { 
   if (Ls_FFFB8 == "digits") { 
   Id_00AB8 = MarketInfo(Ls_FFFC8, MODE_DIGITS);
   } 
   else { 
   Id_00AB8 = 0;
   }}}} 
   Id_00AE0 = (Id_00AE0 - Id_00AB8);
   Ld_FFF68 = ((Id_00AE0 / Id_001F8) + Ld_FFF68);
   }} 
   if (OrderSymbol() == Is_00410) { 
   if (OrderType() == OP_BUY) { 
   Ls_FFFA8 = Is_00410;
   Ls_FFF98 = "bid";
   if (Ls_FFFA8 == NULL) { 
   Ls_FFFA8 = _Symbol;
   } 
   if (Ls_FFF98 == "ask") { 
   Id_00AE0 = MarketInfo(Ls_FFFA8, MODE_ASK);
   } 
   else { 
   if (Ls_FFF98 == "bid") { 
   Id_00AE0 = MarketInfo(Ls_FFFA8, MODE_BID);
   } 
   else { 
   if (Ls_FFF98 == "point") { 
   Id_00AE0 = MarketInfo(Ls_FFFA8, MODE_POINT);
   } 
   else { 
   if (Ls_FFF98 == "digits") { 
   Id_00AE0 = MarketInfo(Ls_FFFA8, MODE_DIGITS);
   } 
   else { 
   Id_00AE0 = 0;
   }}}} 
   Id_00AE8 = (Id_00AE0 - OrderOpenPrice());
   Ld_FFF70 = ((Id_00AE8 / Id_001F8) + Ld_FFF70);
   } 
   if (OrderType() == OP_SELL) { 
   Id_00AE8 = OrderOpenPrice();
   Ls_FFF88 = Is_00410;
   Ls_FFF78 = "ask";
   if (Ls_FFF88 == NULL) { 
   Ls_FFF88 = _Symbol;
   } 
   if (Ls_FFF78 == "ask") { 
   Id_00B70 = MarketInfo(Ls_FFF88, MODE_ASK);
   } 
   else { 
   if (Ls_FFF78 == "bid") { 
   Id_00B70 = MarketInfo(Ls_FFF88, MODE_BID);
   } 
   else { 
   if (Ls_FFF78 == "point") { 
   Id_00B70 = MarketInfo(Ls_FFF88, MODE_POINT);
   } 
   else { 
   if (Ls_FFF78 == "digits") { 
   Id_00B70 = MarketInfo(Ls_FFF88, MODE_DIGITS);
   } 
   else { 
   Id_00B70 = 0;
   }}}} 
   Id_00AE8 = (Id_00AE8 - Id_00B70);
   Ld_FFF68 = ((Id_00AE8 / Id_001F8) + Ld_FFF68);
   }}}} 
   Li_FFF64 = Li_FFF64 - 1;
   } while (Li_FFF64 >= 0); 
   } 
   Ld_FFF58 = 0;
   if (Fa_i_00 == 0) { 
   Ld_FFF58 = Ld_FFF70;
   } 
   if (Fa_i_00 == 1) { 
   Ld_FFF58 = Ld_FFF68;
   } 
   if (Fa_i_00 != -1) { 
   Ld_FFFF8 = Ld_FFF58;
   return Ld_FFFF8;
   } 
   Ld_FFF58 = (Ld_FFF70 + Ld_FFF68);
   Ld_FFF50 = Ld_FFF58;
   Ld_FFFF8 = Ld_FFF58;
   
   return Ld_FFFF8;
}

bool func_1036(int Fa_i_00, int Fa_i_01)
{
   bool Lb_FFFFE;
   int Li_FFFF8;
   bool Lb_FFFF7;
   bool Lb_FFFFF;

   Lb_FFFFE = false;
   Li_FFFF8 = 0;
   Lb_FFFF7 = false;
   Lb_FFFFE = false;
   if (OrderSelect(Fa_i_01, 1, 0) != true) { 
   Lb_FFFFF = false;
   return Lb_FFFFF;
   } 
   if (Fa_i_00 == -1) { 
   if (OrderType() == OP_BUY) { 
   Lb_FFFFE = OrderClose(Fa_i_01, OrderLots(), Bid, 1000, 55295);
   } 
   if (OrderType() == OP_SELL) { 
   Lb_FFFFE = OrderClose(Fa_i_01, OrderLots(), Ask, 1000, 55295);
   } 
   if (OrderType() > OP_SELL) { 
   Lb_FFFFE = OrderDelete(Fa_i_01, 4294967295);
   }} 
   if (Fa_i_00 == OrderType()) { 
   if (Fa_i_00 == 0) { 
   Lb_FFFFE = OrderClose(Fa_i_01, OrderLots(), Bid, 1000, 55295);
   } 
   if (Fa_i_00 == 1) { 
   Lb_FFFFE = OrderClose(Fa_i_01, OrderLots(), Ask, 1000, 55295);
   } 
   if (Fa_i_00 > 1) { 
   Lb_FFFFE = OrderDelete(Fa_i_01, 4294967295);
   }} 
   if (Fa_i_00 == 6) { 
   if (OrderType() == OP_BUY) { 
   Lb_FFFFE = OrderClose(Fa_i_01, OrderLots(), Bid, 1000, 55295);
   } 
   if (OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) { 
   
   Lb_FFFFE = OrderDelete(Fa_i_01, 4294967295);
   }} 
   if (Fa_i_00 == 7) { 
   if (OrderType() == OP_SELL) { 
   Lb_FFFFE = OrderClose(Fa_i_01, OrderLots(), Bid, 1000, 55295);
   } 
   if (OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) { 
   
   Lb_FFFFE = OrderDelete(Fa_i_01, 4294967295);
   }} 
   Li_FFFF8 = 0;
   do { 
   if (Ii_00DC4[Li_FFFF8] == 0) { 
   Ii_0015C = OrderTicket();
   Ii_00DC4[Li_FFFF8] = Ii_0015C;
   Lb_FFFFF = Lb_FFFFE;
   return Lb_FFFFF;
   } 
   Li_FFFF8 = Li_FFFF8 + 1;
   } while (Li_FFFF8 < 100); 
   Lb_FFFF7 = Lb_FFFFE;
   Lb_FFFFF = Lb_FFFFE;
   
   return Lb_FFFFF;
}

double func_1037(int Fa_i_00, int Fa_i_01, int Fa_i_02)
{
   int Li_FFFF4;
   int Li_FFFF0;
   int Li_FFFEC;
   int Li_FFFE8;
   double Ld_FFFE0;
   int Li_FFFDC;
   double Ld_FFFD0;
   double Ld_FFFC8;
   double Ld_FFFC0;
   double Ld_FFFB8;
   double Ld_FFFB0;
   double Ld_FFFA8;
   int Li_FFFA4;
   double Ld_FFF98;
   double Ld_FFF90;
   double Ld_FFF88;
   double Ld_FFFF8;

   Li_FFFF4 = 0;
   Li_FFFF0 = 0;
   Li_FFFEC = 0;
   Li_FFFE8 = 0;
   Ld_FFFE0 = 0;
   Li_FFFDC = 0;
   Ld_FFFD0 = 0;
   Ld_FFFC8 = 0;
   Ld_FFFC0 = 0;
   Ld_FFFB8 = 0;
   Ld_FFFB0 = 0;
   Ld_FFFA8 = 0;
   Li_FFFA4 = 0;
   Ld_FFF98 = 0;
   Ld_FFF90 = 0;
   Ld_FFF88 = 0;
   Li_FFFF4 = iBars(NULL, Fa_i_00);
   if (ArraySize(Id_01024) < Li_FFFF4) { 
   ArraySetAsSeries(Id_01024, false);
   ArrayResize(Id_01024, Li_FFFF4, 0);
   ArraySetAsSeries(Id_01024, true);
   } 
   Li_FFFF0 = Ii_008EC;
   Ii_008EC = Li_FFFF4;
   if (Li_FFFF0 == 0) { 
   Li_FFFEC = Li_FFFF4 - 1;
   Ii_00158 = Fa_i_01 + 1;
   Li_FFFE8 = Li_FFFF4 - Ii_00158;
   if (Li_FFFE8 <= Li_FFFEC) { 
   do { 
   Id_01024[Li_FFFEC] = 0;
   Li_FFFEC = Li_FFFEC - 1;
   } while (Li_FFFE8 <= Li_FFFEC); 
   }} 
   Gi_00001 = Fa_i_01 - 1;
   Id_00AE0 = Gi_00001;
   Id_00AE0 = ((Fa_i_01 * Id_00AE0) * 0.5);
   Ld_FFFE0 = (Id_00AE0 / Fa_i_01);
   if (Li_FFFF0 != 0) { 
   Ii_0015C = Li_FFFF0;
   } 
   else { 
   Ii_0019C = Fa_i_01 + 1;
   Ii_0015C = Ii_0019C;
   } 
   Li_FFFDC = Li_FFFF4 - Ii_0015C;
   if (Li_FFFDC >= 0) { 
   do { 
   Ld_FFFD0 = iMA(NULL, Fa_i_00, Fa_i_01, 0, 0, 1, Li_FFFDC);
   Ld_FFFC8 = 0;
   Ld_FFFC0 = 0;
   Ld_FFFB8 = 0;
   Ld_FFFB0 = 0;
   Ld_FFFA8 = 0;
   Li_FFFA4 = 0;
   if (Fa_i_01 > 0) { 
   do { 
   Ld_FFFC0 = (iClose(NULL, Fa_i_00, (Li_FFFDC + Li_FFFA4)) - Ld_FFFD0);
   Ld_FFFB0 = ((Ld_FFFC0 * Ld_FFFC0) + Ld_FFFB0);
   Ld_FFFC8 = (Li_FFFA4 - Ld_FFFE0);
   Ld_FFFB8 = ((Ld_FFFC8 * Ld_FFFC8) + Ld_FFFB8);
   Ld_FFFA8 = ((Ld_FFFC8 * Ld_FFFC0) + Ld_FFFA8);
   Li_FFFA4 = Li_FFFA4 + 1;
   } while (Li_FFFA4 < Fa_i_01); 
   } 
   Ld_FFF98 = sqrt((Ld_FFFB0 / Fa_i_01));
   Id_00AB8 = (Ld_FFFA8 * Ld_FFFA8);
   Id_00AB8 = (Id_00AB8 / Ld_FFFB8);
   Id_00AB8 = (Ld_FFFB0 - Id_00AB8);
   Gi_00001 = Fa_i_01 - 2;
   Ld_FFF90 = (Id_00AB8 / Gi_00001);
   if ((Ld_FFF90 > 0)) { 
   Ld_FFF90 = sqrt(Ld_FFF90);
   } 
   if ((Ld_FFF98 > 0)) { 
   Ib_008F8 = (Ld_FFF90 > 0);
   } 
   if (Ib_008F8) { 
   Id_00AB8 = (Ld_FFF98 / Ld_FFF90);
   } 
   else { 
   Id_00AB8 = 0;
   } 
   Id_01024[Li_FFFDC] = Id_00AB8;
   Li_FFFDC = Li_FFFDC - 1;
   } while (Li_FFFDC >= 0); 
   } 
   Ld_FFF88 = Id_01024[Fa_i_02];
   Ld_FFFF8 = Ld_FFF88;
   return Ld_FFF88;
}

void func_1038(double Fa_d_00, double Fa_d_01)
{
   string Ls_FFFF0;
   string Ls_FFFE0;
   string Ls_FFFD0;
   string Ls_FFFC0;
   string Ls_FFFB0;
   string Ls_FFFA0;
   string Ls_FFF90;
   string Ls_FFF80;
   string Ls_FFF70;
   string Ls_FFF60;
   string Ls_FFF50;
   string Ls_FFF40;
   string Ls_FFF30;
   string Ls_FFF20;
   string Ls_FFF10;
   int Li_FFF0C;
   double Ld_FFF00;
   double Ld_FFEF8;
   double Ld_FFEF0;
   double Ld_FFEE8;
   double Ld_FFEE0;
   double Ld_FFED8;
   double Ld_FFED0;
   int Li_FFECC;
   int Li_FFEC8;
   int Li_FFEC4;
   string Ls_FFEB8;

   Li_FFF0C = 0;
   Ld_FFF00 = 0;
   Ld_FFEF8 = 0;
   Ld_FFEF0 = 0;
   Ld_FFEE8 = 0;
   Ld_FFEE0 = 0;
   Ld_FFED8 = 0;
   Ld_FFED0 = 0;
   Li_FFECC = 0;
   Li_FFEC8 = 0;
   Li_FFEC4 = 0;
   if (IsTesting() && IsVisualMode() == false) { 
   return ;
   } 
   Li_FFF0C = 0;
   Ld_FFF00 = 0;
   Ld_FFEF8 = 0;
   Ld_FFEF0 = 0;
   Ld_FFEE8 = 0;
   Li_FFF0C = 0;
   Ld_FFF00 = 0;
   Ld_FFEF0 = 0;
   Ld_FFEF8 = 0;
   Ld_FFEE8 = 0;
   RefreshRates();
   Ii_001B0 = HistoryTotal() - 1;
   Ii_001B4 = Ii_001B0;
   if (Ii_001B0 >= 0) { 
   do { 
   if (OrderSelect(Ii_001B4, 0, 1) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) { 
   
   Ii_001B0 = TimeDayOfYear(OrderCloseTime());
   if (Ii_001B0 == DayOfYear()) { 
   Ld_FFEF8 = (Ld_FFEF8 + OrderProfit());
   } 
   Ld_FFEF0 = (Ld_FFEF0 + OrderProfit());
   }} 
   Ii_001B4 = Ii_001B4 - 1;
   } while (Ii_001B4 >= 0); 
   } 
   Ii_001B0 = OrdersTotal() - 1;
   Ii_001C0 = Ii_001B0;
   if (Ii_001B0 >= 0) { 
   do { 
   if (OrderSelect(Ii_001C0, 0, 0) && OrderSymbol() == _Symbol) { 
   if (OrderMagicNumber() == 0 || OrderMagicNumber() == MagicNumber) {
   
   if (OrderType() <= OP_SELL) { 
   Ii_001B0 = TimeDayOfYear(OrderOpenTime());
   if (Ii_001B0 == DayOfYear()) { 
   Ld_FFEF8 = (Ld_FFEF8 + OrderProfit());
   } 
   Li_FFF0C = Li_FFF0C + 1;
   Ld_FFF00 = (Ld_FFF00 + OrderProfit());
   Ld_FFEF0 = (Ld_FFEF0 + OrderProfit());
   Ld_FFEE8 = (Ld_FFEE8 + OrderLots());
   }}} 
   Ii_001C0 = Ii_001C0 - 1;
   } while (Ii_001C0 >= 0); 
   } 
   Ld_FFEE0 = 0;
   if ((AccountFreeMargin() > 0)) { 
   Id_00AC8 = AccountFreeMargin();
   Ld_FFEE0 = NormalizeDouble((Id_00AC8 / MarketInfo(_Symbol, MODE_MARGINREQUIRED)), Ii_00204);
   } 
   Ld_FFED8 = 0;
   Id_00AC8 = AccountEquity();
   if (((Id_00AC8 * AccountMargin()) > 0)) { 
   Id_00AC8 = AccountEquity();
   Ld_FFED8 = ((Id_00AC8 / AccountMargin()) * 100);
   } 
   Ld_FFED0 = func_1037(TimeFrame, (1440 / TimeFrame), 0);
   if (TimeFrame != 0) { 
   Ii_001B0 = TimeFrame;
   } 
   else { 
   Ii_001B0 = _Period;
   } 
   Li_FFECC = Ii_001B0;
   string Ls_FFDC8[20];
   Ls_FFDC8[1] = StringConcatenate(EAComment, " (", Ii_001B0, ")");
   Ls_FFFF0 = DoubleToString((MarketInfo(_Symbol, MODE_SPREAD) / Ii_001E4), 2);
   Ls_FFDC8[18] = StringConcatenate("Spread : ", Ls_FFFF0);
   Ls_FFDC8[3] = "--------------------------------------------------";
   Ls_FFFE0 = DoubleToString(Ld_FFED8, 2);
   Ls_FFFD0 = DoubleToString(AccountEquity(), 2);
   Ls_FFDC8[4] = StringConcatenate("Equity : ", Ls_FFFD0, " (", Ls_FFFE0, "%)");
   Ls_FFFC0 = DoubleToString(Id_008C0, 2);
   Id_00AF8 = AccountBalance();
   Id_00AF8 = (Id_00AF8 - AccountEquity());
   Id_00B00 = Id_008E0;
   if ((Id_008E0 <= Id_00AF8) != true) { 
   Id_00AF8 = Id_008E0;
   } 
   Id_008E0 = Id_00AF8;
   Ls_FFFB0 = DoubleToString(Id_00AF8, 2);
   Ls_FFDC8[5] = StringConcatenate("Max. Draw Down : ", Ls_FFFB0, " (", Ls_FFFC0, "%)");
   Ls_FFFA0 = DoubleToString(Ld_FFEF0, 2);
   Ls_FFDC8[6] = StringConcatenate("All Time Profit : ", Ls_FFFA0);
   Ls_FFF90 = DoubleToString(FixedLots, Ii_00204);
   Ls_FFDC8[7] = StringConcatenate("Fixed Lot Size: ", Ls_FFF90);
   Ls_FFDC8[8] = StringConcatenate("Magic Number : ", MagicNumber);
   Ls_FFDC8[9] = "--------------------------------------------------";
   Ls_FFF80 = DoubleToString(Ld_FFED0, 2);
   Ls_FFDC8[10] = StringConcatenate("Trend Intensity : ", Ls_FFF80);
   Ls_FFF70 = DoubleToString(Ld_FFF00, 2);
   Ls_FFDC8[11] = StringConcatenate("Trades Open : ", Li_FFF0C, " / Profit : ", Ls_FFF70);
   Ls_FFF60 = DoubleToString(((Ld_FFF00 / AccountBalance()) * 100), 2);
   Ls_FFF50 = DoubleToString(Ld_FFF00, 2);
   Ls_FFF40 = AccountCurrency();
   Ls_FFDC8[12] = StringConcatenate("P/L : ", Ls_FFF40, " ", Ls_FFF50, " (", Ls_FFF60, "%)");
   Ls_FFF30 = DoubleToString(Ld_FFEE0, Ii_00204);
   Ls_FFF20 = DoubleToString(Ld_FFEE8, Ii_00204);
   Ls_FFDC8[13] = StringConcatenate("Use Lots : ", Ls_FFF20, " / Free : ", Ls_FFF30);
   Ls_FFF10 = "Take Profit: " + DoubleToString(Fa_d_01, _Digits);
   Ls_FFDC8[14] = Ls_FFF10;
   Ls_FFF10 = "Stop Loss: " + DoubleToString(Fa_d_00, _Digits);
   Ls_FFDC8[15] = Ls_FFF10;
   Ls_FFDC8[16] = StringConcatenate("Server Time : ", TimeCurrent());
   Ls_FFDC8[17] = "--------------------------------------------------";
   Ls_FFF10 = "NEWS Filter : " + Is_00748;
   Ls_FFDC8[18] = Ls_FFF10;
   Li_FFEC8 = 25;
   Li_FFEC4 = 1;
   do { 
   Ls_FFEB8 = "Info" + IntegerToString(Li_FFEC4, 0, 32);
   ObjectCreate(0, Ls_FFEB8, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText(Ls_FFEB8, Ls_FFDC8[Li_FFEC4], 9, "Arial Bold", 16777215);
   ObjectSet(Ls_FFEB8, OBJPROP_CORNER, 1);
   ObjectSet(Ls_FFEB8, OBJPROP_XDISTANCE, 7);
   ObjectSet(Ls_FFEB8, OBJPROP_YDISTANCE, Li_FFEC8);
   Li_FFEC8 = Li_FFEC8 + 13;
   Li_FFEC4 = Li_FFEC4 + 1;
   } while (Li_FFEC4 <= 19); 
   ArrayFree(Ls_FFDC8);
   ArrayFree(Ls_FFDC8);
   
}

void func_1039(string &Fa_s_00[], int Fa_i_01, long Fa_l_02, long Fa_l_03, int Fa_i_04, int Fa_i_05, int Fa_i_06, int Fa_i_07)
{
   string Ls_FFFF0;
   string Ls_FFFE0;
   int Li_FFFDC;
   int Li_FFFD8;

   Li_FFFDC = 0;
   Li_FFFD8 = 0;
   Li_FFFDC = 0;
   if (Fa_i_05 <= 0){
   return ;
   }
   do { 
   Li_FFFD8 = func_1040(Fa_i_06, Fa_i_07, Fa_i_05, (Li_FFFDC + 1));
   Ib_00199 = true;
   Ib_008F8 = false;
   Ib_00CC8 = false;
   Ii_001A4 = 0;
   Ii_001B0 = 0;
   Ii_001B4 = Li_FFFD8;
   Ii_001C0 = Li_FFFD8;
   Ii_001C4 = 1;
   Ii_001CC = Fa_i_04;
   Ii_001D8 = Fa_i_01;
   Il_00810 = Li_FFFDC;
   Ii_00900 = ArraySize(Fa_s_00);
   Ii_00900 = ArrayResize(Fa_s_00, (Ii_00900 + 1), 0) - 1;
   Ii_00904 = Ii_00900;
   Ls_FFFF0 = "ipnl_" + IntegerToString(Ii_00900, 0, 32);
   Fa_s_00[Ii_00900] = Ls_FFFF0;
   Ls_FFFF0 = Fa_s_00[Ii_00904];
   Ls_FFFE0 = Ls_FFFF0;
   Il_00CD8 = 0;
   if (Ii_001B4 == -1) { 
   Ii_00918 = Ii_001C0;
   } 
   else { 
   Ii_00918 = Ii_001B4;
   } 
   if (ObjectFind(Il_00CD8, Ls_FFFE0) == -1) { 
   ObjectCreate(Il_00CD8, Ls_FFFE0, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 1029, 0);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 101, Ii_001D8);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 7, Ii_001B0);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 8, Ii_001A4);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 9, Ib_00CC8);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 1000, Ib_008F8);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 17, Ib_008F8);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 208, Ib_00199);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 207, 0);
   } 
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 1025, Ii_001C0);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 6, Ii_00918);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 1019, Ii_001CC);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 1020, Ii_001C4);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 102, Fa_l_02);
   ObjectSetInteger(Il_00CD8, Ls_FFFE0, 103, (Fa_l_03 + Il_00810));
   Li_FFFDC = Li_FFFDC + 1;
   } while (Li_FFFDC < Fa_i_05); 
   
}

int func_1040(int Fa_i_00, int Fa_i_01, int Fa_i_02, int Fa_i_03)
{
   int Li_FFFF8;
   int Li_FFFF4;
   int Li_FFFF0;
   double Ld_FFFE8;
   double Ld_FFFE0;
   double Ld_FFFD8;
   double Ld_FFFD0;
   double Ld_FFFC8;
   double Ld_FFFC0;
   int Li_FFFBC;
   int Li_FFFFC;

   Li_FFFF8 = 0;
   Li_FFFF4 = 0;
   Li_FFFF0 = 0;
   Ld_FFFE8 = 0;
   Ld_FFFE0 = 0;
   Ld_FFFD8 = 0;
   Ld_FFFD0 = 0;
   Ld_FFFC8 = 0;
   Ld_FFFC0 = 0;
   Li_FFFBC = 0;
   Li_FFFF8 = 0;
   Li_FFFF4 = 0;
   Li_FFFF0 = 0;
   Ii_00158 = Fa_i_01 & 255;
   Ld_FFFE8 = Ii_00158;
   Ii_00158 = Fa_i_01;
   Ii_0015C = Fa_i_01 >> 8;
   Ii_0015C = Ii_0015C & 255;
   Ld_FFFE0 = Ii_0015C;
   Ii_0015C = Fa_i_01;
   Ii_0019C = Fa_i_01 >> 16;
   Ii_0019C = Ii_0019C & 255;
   Ld_FFFD8 = Ii_0019C;
   Ii_0019C = Fa_i_00 & 255;
   Ld_FFFD0 = Ii_0019C;
   Ii_0019C = Fa_i_00;
   Ii_001A0 = Fa_i_00 >> 8;
   Ii_001A0 = Ii_001A0 & 255;
   Ld_FFFC8 = Ii_001A0;
   Ii_001A0 = Fa_i_00;
   Ii_001A4 = Fa_i_00 >> 16;
   Ii_001A4 = Ii_001A4 & 255;
   Ld_FFFC0 = Ii_001A4;
   if ((Ld_FFFE8 > Ld_FFFD0)) { 
   Id_00B70 = (Ld_FFFD0 - Ld_FFFE8);
   Id_00B70 = (Id_00B70 / Fa_i_02);
   Li_FFFF8 = (int)((Id_00B70 * Fa_i_03) + Ld_FFFE8);
   } 
   if ((Ld_FFFE8 < Ld_FFFD0)) { 
   Id_00B70 = (Ld_FFFE8 - Ld_FFFD0);
   Id_00B70 = (Id_00B70 / Fa_i_02);
   Id_00B70 = (Id_00B70 * Fa_i_03);
   Li_FFFF8 = (int)(Ld_FFFE8 - Id_00B70);
   } 
   if ((Ld_FFFE0 > Ld_FFFC8)) { 
   Id_00B70 = (Ld_FFFC8 - Ld_FFFE0);
   Id_00B70 = (Id_00B70 / Fa_i_02);
   Li_FFFF4 = (int)((Id_00B70 * Fa_i_03) + Ld_FFFE0);
   } 
   if ((Ld_FFFE0 < Ld_FFFC8)) { 
   Id_00B70 = (Ld_FFFE0 - Ld_FFFC8);
   Id_00B70 = (Id_00B70 / Fa_i_02);
   Id_00B70 = (Id_00B70 * Fa_i_03);
   Li_FFFF4 = (int)(Ld_FFFE0 - Id_00B70);
   } 
   if ((Ld_FFFD8 > Ld_FFFC0)) { 
   Id_00B70 = (Ld_FFFC0 - Ld_FFFD8);
   Id_00B70 = (Id_00B70 / Fa_i_02);
   Li_FFFF0 = (int)((Id_00B70 * Fa_i_03) + Ld_FFFD8);
   } 
   if ((Ld_FFFD8 < Ld_FFFC0)) { 
   Id_00B70 = (Ld_FFFD8 - Ld_FFFC0);
   Id_00B70 = (Id_00B70 / Fa_i_02);
   Id_00B70 = (Id_00B70 * Fa_i_03);
   Li_FFFF0 = (int)(Ld_FFFD8 - Id_00B70);
   } 
   Li_FFFF4 = Li_FFFF4 * 256;
   Li_FFFF0 = Li_FFFF0 << 16;
   Ii_001A4 = Li_FFFF8 + Li_FFFF4;
   Li_FFFBC = Ii_001A4 + Li_FFFF0;
   Li_FFFFC = Li_FFFBC;
   return Li_FFFBC;
}



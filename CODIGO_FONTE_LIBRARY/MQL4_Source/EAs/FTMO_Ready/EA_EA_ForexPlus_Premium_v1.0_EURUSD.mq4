#property copyright "EA REVOLUTION";
#property link "";
#property version "";
#property strict

extern int PotenzaSell = 68;
extern int PotenzaBuy = 32;
extern int ProfitTarget = 10;
extern double LotSize = 0.01;
extern int StopLossBalance = 25;
extern int UltraSell = 100;
extern int UltraBuy;
extern int MaxOrders = 5;
extern bool PowerRisk;
extern int SwapMinimo = -100;

int returned_i;
int Ii_0000;
int Ii_0004;
int Ii_0008;
int Ii_000C;
int Ii_0010;
int Ii_0014;
int Ii_0018;
int Ii_001C;
int Ii_0020;
int Ii_0024;
int Ii_0028;
int Ii_002C;
int Ii_0030;
int Ii_0034;
double Ind_004;
bool Gb_0000;
double Ind_000;
double Id_0088;
double Ind_002;
double Id_0090;
double Id_00C0;
double Gd_0000;
bool Ib_0081;
double Ind_003;
int Ii_00DC;
int Ii_00E4;
int Ii_00E0;
int Ii_00E8;
int Gi_0000;
int Gi_0001;
double Gd_0002;
int Gi_0003;
int Gi_0004;
bool Gb_0005;
int Gi_0006;
int Gi_0007;
int Gi_0008;
double Gd_0009;
double Gd_000A;
int Gi_000B;
double Gd_000C;
int Gi_000D;
double Gd_000E;
double Gd_000F;
int Gi_0010;
double Gd_0011;
int Gi_0012;
double Gd_0013;
int Gi_0014;
double Gd_0015;
double Gd_0016;
int Gi_0017;
double Gd_0018;
double Gd_0019;
int Gi_001A;
double Gd_001B;
int Gi_001C;
double Gd_001D;
int Gi_001E;
double Gd_001F;
double Gd_0020;
int Gi_0021;
double Gd_0022;
double Gd_0023;
int Gi_0024;
double Gd_0025;
int Gi_0026;
double Gd_0027;
int Gi_0028;
double Gd_0029;
double Gd_002A;
int Gi_002B;
double Gd_002C;
double Gd_002D;
int Gi_002E;
double Gd_002F;
int Gi_0030;
double Gd_0031;
int Gi_0032;
double Gd_0033;
double Gd_0034;
int Gi_0035;
double Gd_0036;
double Gd_0037;
int Gi_0038;
double Gd_0039;
int Gi_003A;
double Gd_003B;
int Gi_003C;
double Gd_003D;
double Gd_003E;
int Gi_003F;
double Gd_0040;
double Gd_0041;
int Gi_0042;
double Gd_0043;
int Gi_0044;
double Gd_0045;
int Gi_0046;
double Gd_0047;
double Gd_0048;
int Gi_0049;
double Gd_004A;
double Gd_004B;
int Gi_004C;
double Gd_004D;
bool Gb_004E;
int Gi_004F;
int Gi_0050;
int Gi_0051;
double Gd_0052;
double Gd_0053;
int Gi_0054;
double Gd_0055;
int Gi_0056;
double Gd_0057;
double Gd_0058;
int Gi_0059;
double Gd_005A;
int Gi_005B;
double Gd_005C;
int Gi_005D;
double Gd_005E;
double Gd_005F;
int Gi_0060;
double Gd_0061;
double Gd_0062;
int Gi_0063;
double Gd_0064;
int Gi_0065;
double Gd_0066;
int Gi_0067;
double Gd_0068;
double Gd_0069;
int Gi_006A;
double Gd_006B;
double Gd_006C;
int Gi_006D;
double Gd_006E;
int Gi_006F;
double Gd_0070;
int Gi_0071;
double Gd_0072;
double Gd_0073;
int Gi_0074;
double Gd_0075;
double Gd_0076;
int Gi_0077;
double Gd_0078;
int Gi_0079;
double Gd_007A;
int Gi_007B;
double Gd_007C;
double Gd_007D;
int Gi_007E;
double Gd_007F;
double Gd_0080;
int Gi_0081;
double Gd_0082;
int Gi_0083;
double Gd_0084;
int Gi_0085;
double Gd_0086;
double Gd_0087;
int Gi_0088;
double Gd_0089;
double Gd_008A;
int Gi_008B;
double Gd_008C;
int Gi_008D;
double Gd_008E;
int Gi_008F;
double Gd_0090;
double Gd_0091;
int Gi_0092;
double Gd_0093;
double Gd_0094;
int Gi_0095;
double Gd_0096;
double Gd_0097;
int Gi_0098;
double Gd_0099;
int Gi_009A;
int Gi_009B;
double Gd_009C;
int Gi_009D;
double Gd_009E;
int Gi_009F;
double Gd_00A0;
int Gi_00A1;
int Gi_00A2;
double Gd_00A3;
int Gi_00A4;
double Gd_00A5;
int Gi_00A6;
double Gd_00A7;
int Gi_00A8;
double Gd_00A9;
int Gi_00AA;
double Gd_00AB;
int Gi_00AC;
int Gi_00AD;
double Gd_00AE;
int Gi_00AF;
int Gi_00B0;
double Gd_00B1;
int Gi_00B2;
double Gd_00B3;
int Gi_00B4;
double Gd_00B5;
int Gi_00B6;
int Gi_00B7;
double Gd_00B8;
int Gi_00B9;
double Gd_00BA;
int Gi_00BB;
double Gd_00BC;
int Gi_00BD;
int Gi_00BE;
double Gd_00BF;
int Gi_00C0;
double Gd_00C1;
int Gi_00C2;
double Gd_00C3;
int Gi_00C4;
double Gd_00C5;
int Gi_00C6;
double Gd_00C7;
int Gi_00C8;
int Gi_00C9;
double Gd_00CA;
int Gi_00CB;
int Gi_00CC;
double Gd_00CD;
int Gi_00CE;
bool Ib_0082;
int Gi_00CF;
long Gl_00D0;
long Gl_00CF;
int Gi_00D0;
long Gl_00D1;
int Gi_00D1;
long Gl_00D2;
string Is_00C8;
bool Ib_00D4;
int Gi_00D2;
int Gi_00D3;
bool returned_b;
double Gd_00D3;
int Gi_00D4;
bool Gb_00D3;
double Gd_00D4;
long Gl_00D3;
long returned_l;
int Gi_00D5;
long Gl_00D5;
double Id_0040;
double Id_0048;
double Id_0050;
double Id_0058;
double Id_0060;
int Gi_00D7;
double Gd_00D7;
double Id_0070;
double Gd_00D8;
double Id_0068;
int Gi_00D8;
int Gi_00D9;
bool Gb_00D8;
double Gd_00D9;
long Gl_00D8;
int Gi_00DA;
long Gl_00DA;
int Gi_00DC;
double Gd_00DC;
double Gd_00DD;
int Gi_00DD;
bool Gb_00DD;
double Gd_00DE;
int Gi_00DE;
double Gd_00DF;
bool Gb_00DF;
int Gi_00DF;
int Gi_00E0;
double Gd_00E0;
int Gi_00E1;
double Gd_00E1;
int Gi_00E2;
double Gd_00E2;
bool Gb_00E2;
int Gi_00E3;
double Gd_00E3;
int Gi_00E4;
double Gd_00E4;
int Gi_00E5;
double Gd_00E5;
bool Gb_00E5;
int Gi_00DB;
long Gl_00DB;
int Gi_00D6;
long Gl_00D6;
double Id_0038;
int Ii_0078;
int Ii_007C;
bool Ib_0080;
int Ii_0098;
int Ii_009C;
string Is_00A0;
string Is_00B0;
int Ii_00D8;
int Ii_00EC;
double Gd_0001;
int Gi_0002;
int Gi_0005;
double Gd_0007;
int Gi_0009;
int Gi_000A;
int Gi_000C;
double Gd_000D;
int Gi_000E;
long Gl_000F;
int Gi_0011;
int Gi_0013;
double Gd_0014;
int Gi_0015;
int Gi_0016;
int Gi_0018;
int Gi_0019;
double Gd_001A;
int Gi_001B;
int Gi_001D;
int Gi_001F;
long Gl_0022;
int Gi_0023;
int Gi_0025;
int Gi_0029;
int Gi_002A;
int Gi_002C;
int Gi_002F;
int Gi_0031;
int Gi_0034;
long Gl_0035;
int Gi_0036;
int Gi_0037;
int Gi_0039;
double Gd_003A;
int Gi_003B;
int Gi_003D;
int Gi_003E;
int Gi_0041;
int Gi_0043;
int Gi_0045;
double Gd_0046;
int Gi_0047;
long Gl_0048;
int Gi_004A;
int Gi_004B;
int Gi_004E;
int Gi_0052;
int Gi_0055;
int Gi_0057;
int Gi_0058;
double Gd_0059;
int Gi_005A;
long Gl_005B;
int Gi_005C;
int Gi_005E;
int Gi_005F;
double Gd_0060;
int Gi_0061;
int Gi_0062;
int Gi_0064;
int Gi_0068;
int Gi_0069;
int Gi_006B;
long Gl_006E;
int Gi_0070;
int Gi_0072;
int Gi_0075;
int Gi_0076;
int Gi_0078;
double Gd_0079;
int Gi_007A;
int Gi_007C;
int Gi_007D;
int Gi_0080;
long Gl_0081;
int Gi_0082;
int Gi_0084;
int Gi_0087;
int Gi_0089;
int Gi_008A;
int Gi_008E;
int Gi_0090;
int Gi_0091;
double Gd_0092;
int Gi_0093;
long Gl_0094;
int Gi_0096;
int Gi_0097;
int Gi_009C;
int Gi_009E;
double Gd_009F;
int Gi_00A0;
int Gi_00A3;
long Gl_00A7;
int Gi_00A9;
int Gi_00AB;
double Gd_00AC;
int Gi_00AE;
int Gi_00B1;
double Gd_00B2;
int Gi_00B3;
int Gi_00B5;
long Gl_00BA;
int Gi_00BC;
int Gi_00C1;
int Gi_00C3;
int Gi_00C7;
int Gi_00CA;
double Gd_00CB;
long Gl_00CD;
double Gd_00D2;
long Gl_00E0;
int Gi_00E6;
int Gi_00E7;
int Gi_00E8;
int Gi_00E9;
int Gi_00EA;
double Gd_00EB;
int Gi_00EC;
int Gi_00ED;
int Gi_00EE;
int Gi_00EF;
int Gi_00F0;
double Gd_00F1;
int Gi_00F2;
long Gl_00F3;
int Gi_00F4;
int Gi_00F5;
int Gi_00F6;
int Gi_00F7;
double Gd_00F8;
int Gi_00F9;
int Gi_00FA;
int Gi_00FB;
int Gi_00FC;
int Gi_00FD;
double Gd_00FE;
int Gi_00FF;
int Gi_0100;
int Gi_0101;
int Gi_0102;
int Gi_0103;
double Gd_0104;
int Gi_0105;
long Gl_0106;
int Gi_0107;
int Gi_0108;
int Gi_0109;
double Gd_010A;
int Gi_010B;
bool Gb_010B;
long Gl_010B;
double Gd_010B;
double Gd_010C;
int Gi_010D;
long Gl_010D;
double Gd_010F;
int Gi_0110;
bool Gb_0110;
long Gl_0110;
double Gd_0110;
double Gd_0111;
int Gi_0112;
long Gl_0112;
bool Gb_0114;
int Gi_0114;
long Gl_0114;
int Gi_0115;
bool Gb_0115;
long Gl_0115;
double Gd_0115;
int Gi_0116;
bool Gb_0116;
long Gl_0116;
double Gd_0116;
double Gd_0117;
int Gi_0118;
long Gl_0118;
double Gd_011A;
int Gi_011B;
bool Gb_011B;
long Gl_011B;
double Gd_011B;
double Gd_011C;
int Gi_011D;
long Gl_011D;
bool Gb_011F;
int Gi_011F;
long Gl_011F;
int Gi_0120;
bool Gb_0120;
long Gl_0120;
double Gd_0120;
int Gi_0121;
bool Gb_0121;
long Gl_0121;
double Gd_0121;
double Gd_0122;
int Gi_0123;
long Gl_0123;
double Gd_0125;
int Gi_0126;
bool Gb_0126;
long Gl_0126;
double Gd_0126;
double Gd_0127;
int Gi_0128;
long Gl_0128;
bool Gb_012A;
int Gi_012A;
long Gl_012A;
int Gi_012B;
bool Gb_012B;
long Gl_012B;
double Gd_012B;
int Gi_012C;
bool Gb_012C;
long Gl_012C;
double Gd_012C;
double Gd_012D;
int Gi_012E;
long Gl_012E;
double Gd_0130;
int Gi_0131;
bool Gb_0131;
long Gl_0131;
double Gd_0131;
double Gd_0132;
int Gi_0133;
long Gl_0133;
bool Gb_0135;
int Gi_0135;
long Gl_0135;
int Gi_0136;
bool Gb_0136;
long Gl_0136;
double Gd_0136;
int Gi_0137;
bool Gb_0137;
long Gl_0137;
double Gd_0137;
double Gd_0138;
int Gi_0139;
long Gl_0139;
double Gd_013B;
int Gi_013C;
bool Gb_013C;
long Gl_013C;
double Gd_013C;
double Gd_013D;
int Gi_013E;
long Gl_013E;
bool Gb_0140;
int Gi_0140;
long Gl_0140;
int Gi_0141;
bool Gb_0141;
long Gl_0141;
double Gd_0141;
int Gi_0142;
bool Gb_0142;
long Gl_0142;
double Gd_0142;
double Gd_0143;
int Gi_0144;
long Gl_0144;
double Gd_0146;
int Gi_0147;
bool Gb_0147;
long Gl_0147;
double Gd_0147;
double Gd_0148;
int Gi_0149;
long Gl_0149;
bool Gb_014B;
int Gi_014B;
long Gl_014B;
int Gi_014C;
bool Gb_014C;
long Gl_014C;
double Gd_014C;
int Gi_014D;
bool Gb_014D;
long Gl_014D;
double Gd_014D;
double Gd_014E;
int Gi_014F;
long Gl_014F;
double Gd_0151;
int Gi_0152;
bool Gb_0152;
long Gl_0152;
double Gd_0152;
double Gd_0153;
int Gi_0154;
long Gl_0154;
bool Gb_0156;
int Gi_0156;
long Gl_0156;
int Gi_0157;
bool Gb_0157;
long Gl_0157;
double Gd_0157;
int Gi_0158;
bool Gb_0158;
long Gl_0158;
double Gd_0158;
double Gd_0159;
int Gi_015A;
long Gl_015A;
double Gd_015C;
int Gi_015D;
bool Gb_015D;
long Gl_015D;
double Gd_015D;
double Gd_015E;
int Gi_015F;
long Gl_015F;
bool Gb_0161;
int Gi_0161;
long Gl_0161;
int Gi_0162;
bool Gb_0162;
long Gl_0162;
double Gd_0162;
int Gi_0163;
bool Gb_0163;
long Gl_0163;
double Gd_0163;
double Gd_0164;
int Gi_0165;
long Gl_0165;
double Gd_0167;
int Gi_0168;
bool Gb_0168;
long Gl_0168;
double Gd_0168;
double Gd_0169;
int Gi_016A;
long Gl_016A;
bool Gb_016C;
int Gi_016C;
long Gl_016C;
int Gi_016D;
bool Gb_016D;
long Gl_016D;
double Gd_016D;
int Gi_016E;
bool Gb_016E;
long Gl_016E;
double Gd_016E;
double Gd_016F;
int Gi_0170;
long Gl_0170;
double Gd_0172;
int Gi_0173;
bool Gb_0173;
long Gl_0173;
double Gd_0173;
double Gd_0174;
int Gi_0175;
long Gl_0175;
bool Gb_0177;
int Gi_0177;
long Gl_0177;
int Gi_0178;
bool Gb_0178;
long Gl_0178;
double Gd_0178;
int Gi_0179;
bool Gb_0179;
long Gl_0179;
double Gd_0179;
double Gd_017A;
int Gi_017B;
long Gl_017B;
double Gd_017D;
int Gi_017E;
bool Gb_017E;
long Gl_017E;
double Gd_017E;
double Gd_017F;
int Gi_0180;
long Gl_0180;
bool Gb_0182;
int Gi_0182;
long Gl_0182;
int Gi_0183;
bool Gb_0183;
long Gl_0183;
double Gd_0183;
int Gi_0184;
bool Gb_0184;
long Gl_0184;
double Gd_0184;
double Gd_0185;
int Gi_0186;
long Gl_0186;
double Gd_0188;
int Gi_0189;
bool Gb_0189;
long Gl_0189;
double Gd_0189;
double Gd_018A;
int Gi_018B;
long Gl_018B;
bool Gb_018D;
int Gi_018D;
long Gl_018D;
int Gi_018E;
bool Gb_018E;
long Gl_018E;
double Gd_018E;
int Gi_018F;
bool Gb_018F;
long Gl_018F;
double Gd_018F;
double Gd_0190;
int Gi_0191;
long Gl_0191;
double Gd_0193;
int Gi_0194;
bool Gb_0194;
long Gl_0194;
double Gd_0194;
double Gd_0195;
int Gi_0196;
long Gl_0196;
bool Gb_0198;
int Gi_0198;
long Gl_0198;
int Gi_0199;
bool Gb_0199;
long Gl_0199;
double Gd_0199;
int Gi_019A;
bool Gb_019A;
long Gl_019A;
double Gd_019A;
double Gd_019B;
int Gi_019C;
long Gl_019C;
double Gd_019E;
int Gi_019F;
bool Gb_019F;
long Gl_019F;
double Gd_019F;
double Gd_01A0;
int Gi_01A1;
long Gl_01A1;
bool Gb_01A3;
int Gi_01A3;
long Gl_01A3;
int Gi_01A4;
bool Gb_01A4;
long Gl_01A4;
bool Gb_01A1;
double Gd_01A1;
double Gd_01A2;
bool Gb_019C;
double Gd_019C;
double Gd_019D;
int Gi_019E;
long Gl_019E;
bool Gb_0196;
double Gd_0196;
double Gd_0197;
bool Gb_0191;
double Gd_0191;
double Gd_0192;
int Gi_0193;
long Gl_0193;
bool Gb_018B;
double Gd_018B;
double Gd_018C;
bool Gb_0186;
double Gd_0186;
double Gd_0187;
int Gi_0188;
long Gl_0188;
bool Gb_0180;
double Gd_0180;
double Gd_0181;
bool Gb_017B;
double Gd_017B;
double Gd_017C;
int Gi_017D;
long Gl_017D;
bool Gb_0175;
double Gd_0175;
double Gd_0176;
bool Gb_0170;
double Gd_0170;
double Gd_0171;
int Gi_0172;
long Gl_0172;
bool Gb_016A;
double Gd_016A;
double Gd_016B;
bool Gb_0165;
double Gd_0165;
double Gd_0166;
int Gi_0167;
long Gl_0167;
bool Gb_015F;
double Gd_015F;
double Gd_0160;
bool Gb_015A;
double Gd_015A;
double Gd_015B;
int Gi_015C;
long Gl_015C;
bool Gb_0154;
double Gd_0154;
double Gd_0155;
bool Gb_014F;
double Gd_014F;
double Gd_0150;
int Gi_0151;
long Gl_0151;
bool Gb_0149;
double Gd_0149;
double Gd_014A;
bool Gb_0144;
double Gd_0144;
double Gd_0145;
int Gi_0146;
long Gl_0146;
bool Gb_013E;
double Gd_013E;
double Gd_013F;
bool Gb_0139;
double Gd_0139;
double Gd_013A;
int Gi_013B;
long Gl_013B;
bool Gb_0133;
double Gd_0133;
double Gd_0134;
bool Gb_012E;
double Gd_012E;
double Gd_012F;
int Gi_0130;
long Gl_0130;
bool Gb_0128;
double Gd_0128;
double Gd_0129;
bool Gb_0123;
double Gd_0123;
double Gd_0124;
int Gi_0125;
long Gl_0125;
bool Gb_011D;
double Gd_011D;
double Gd_011E;
bool Gb_0118;
double Gd_0118;
double Gd_0119;
int Gi_011A;
long Gl_011A;
bool Gb_0112;
double Gd_0112;
double Gd_0113;
bool Gb_010D;
double Gd_010D;
double Gd_010E;
int Gi_010F;
long Gl_010F;
long Gl_0003;
double Gd_0008;
long Gl_000A;
long Gl_0011;
long Gl_0018;
long Gl_001F;
int Gi_0020;
int Gi_0022;
double Gd_0024;
long Gl_0026;
int Gi_0027;
double Gd_002B;
long Gl_002D;
double Gd_0032;
int Gi_0033;
long Gl_0034;
long Gl_003B;
long Gl_0042;
int Gi_0048;
long Gl_0049;
int Gi_004D;
double Gd_004E;
long Gl_0050;
int Gi_0053;
long Gl_0057;
long Gl_005E;
long Gl_0062;
long Gl_0063;
long Gl_0064;
long Gl_0065;
int Gi_0066;
long Gl_0066;
long Gl_0067;
long Gl_0068;
long Gl_0069;
long Gl_006A;
long Gl_006B;
int Gi_006C;
long Gl_006C;
long Gl_006D;
int Gi_006E;
long Gl_006F;
long Gl_0070;
long Gl_0004;
long Gl_0008;
bool Gb_0004;
double Gd_0004;
long Gl_0005;
bool Gb_0002;
bool Gb_0007;
bool Gb_000B;
int Gi_000F;
double Gd_0010;
long Gl_0023;
bool Gb_0025;
long Gl_0025;
long Gl_0007;
long Gl_0001;
double Gd_0003;
double Gd_0005;
double Gd_0006;
bool Gb_0013;
double Id_0124[1000];
double returned_double;
bool order_check;
int init()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   int Li_FFFC;
   int Li_FFF8;
   int Li_FFF4;
   double Ld_FFE8;
   
   Ii_0000 = 1;
   Ii_0004 = 2;
   Ii_0008 = 3;
   Ii_000C = 4;
   Ii_0010 = 5;
   Ii_0014 = 6;
   Ii_0018 = 7;
   Ii_001C = 8;
   Ii_0020 = 9;
   Ii_0024 = 10;
   Ii_0028 = 11;
   Ii_002C = 12;
   Ii_0030 = 13;
   Ii_0034 = 14;
   Id_0038 = 0.2;
   Id_0040 = 1;
   Id_0048 = 1;
   Id_0050 = 1;
   Id_0058 = 1;
   Id_0060 = 1;
   Id_0068 = 1;
   Id_0070 = 1.7;
   Ii_0078 = 3;
   Ii_007C = 0;
   Ib_0080 = true;
   Ib_0081 = true;
   Ib_0082 = false;
   Id_0088 = 0;
   Id_0090 = 0;
   Ii_0098 = 0;
   Ii_009C = 0;
   Is_00A0 = "";
   Is_00B0 = "";
   Id_00C0 = 0;
   Ib_00D4 = false;
   Ii_00D8 = 0;
   Ii_00DC = 1;
   Ii_00E0 = 5;
   Ii_00E4 = 20;
   Ii_00E8 = 16777215;
   Ii_00EC = 0;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Ld_FFE8 = 0;
   Li_FFF8 = 20985564;

   if (_Symbol == "AUDCADm" || _Symbol == "AUDCAD") { 
   
   Ii_0000 = 20;
   Ii_0004 = 21;
   Ii_0008 = 22;
   Ii_000C = 23;
   Ii_0010 = 24;
   Ii_0014 = 25;
   Ii_0018 = 26;
   Ii_001C = 27;
   Ii_0020 = 28;
   Ii_0024 = 29;
   Ii_0028 = 30;
   Ii_002C = 31;
   Ii_0030 = 32;
   Ii_0034 = 33;
   } 
   if (_Symbol == "AUDJPYm" || _Symbol == "AUDJPY") { 
   
   Ii_0000 = 40;
   Ii_0004 = 41;
   Ii_0008 = 42;
   Ii_000C = 43;
   Ii_0010 = 44;
   Ii_0014 = 45;
   Ii_0018 = 46;
   Ii_001C = 47;
   Ii_0020 = 48;
   Ii_0024 = 49;
   Ii_0028 = 50;
   Ii_002C = 51;
   Ii_0030 = 52;
   Ii_0034 = 53;
   } 
   if (_Symbol == "AUDNZDm" || _Symbol == "AUDNZD") { 
   
   Ii_0000 = 60;
   Ii_0004 = 61;
   Ii_0008 = 62;
   Ii_000C = 63;
   Ii_0010 = 64;
   Ii_0014 = 65;
   Ii_0018 = 66;
   Ii_001C = 67;
   Ii_0020 = 68;
   Ii_0024 = 69;
   Ii_0028 = 70;
   Ii_002C = 71;
   Ii_0030 = 72;
   Ii_0034 = 73;
   } 
   if (_Symbol == "AUDUSDm" || _Symbol == "AUDUSD") { 
   
   Ii_0000 = 80;
   Ii_0004 = 81;
   Ii_0008 = 82;
   Ii_000C = 83;
   Ii_0010 = 84;
   Ii_0014 = 85;
   Ii_0018 = 86;
   Ii_001C = 87;
   Ii_0020 = 88;
   Ii_0024 = 89;
   Ii_0028 = 90;
   Ii_002C = 91;
   Ii_0030 = 92;
   Ii_0034 = 93;
   } 
   if (_Symbol == "CHFJPYm" || _Symbol == "CHFJPY") { 
   
   Ii_0000 = 100;
   Ii_0004 = 101;
   Ii_0008 = 102;
   Ii_000C = 103;
   Ii_0010 = 104;
   Ii_0014 = 105;
   Ii_0018 = 106;
   Ii_001C = 107;
   Ii_0020 = 108;
   Ii_0024 = 109;
   Ii_0028 = 110;
   Ii_002C = 111;
   Ii_0030 = 112;
   Ii_0034 = 113;
   } 
   if (_Symbol == "EURAUDm" || _Symbol == "EURAUD") { 
   
   Ii_0000 = 120;
   Ii_0004 = 121;
   Ii_0008 = 122;
   Ii_000C = 123;
   Ii_0010 = 124;
   Ii_0014 = 125;
   Ii_0018 = 126;
   Ii_001C = 127;
   Ii_0020 = 128;
   Ii_0024 = 129;
   Ii_0028 = 130;
   Ii_002C = 131;
   Ii_0030 = 132;
   Ii_0034 = 133;
   } 
   if (_Symbol == "EURCADm" || _Symbol == "EURCAD") { 
   
   Ii_0000 = 140;
   Ii_0004 = 141;
   Ii_0008 = 142;
   Ii_000C = 143;
   Ii_0010 = 144;
   Ii_0014 = 145;
   Ii_0018 = 146;
   Ii_001C = 147;
   Ii_0020 = 148;
   Ii_0024 = 149;
   Ii_0028 = 150;
   Ii_002C = 151;
   Ii_0030 = 152;
   Ii_0034 = 153;
   } 
   if (_Symbol == "EURCHFm" || _Symbol == "EURCHF") { 
   
   Ii_0000 = 160;
   Ii_0004 = 161;
   Ii_0008 = 162;
   Ii_000C = 163;
   Ii_0010 = 164;
   Ii_0014 = 165;
   Ii_0018 = 166;
   Ii_001C = 167;
   Ii_0020 = 168;
   Ii_0024 = 169;
   Ii_0028 = 170;
   Ii_002C = 171;
   Ii_0030 = 172;
   Ii_0034 = 173;
   } 
   if (_Symbol == "EURGBPm" || _Symbol == "EURGBP") { 
   
   Ii_0000 = 180;
   Ii_0004 = 181;
   Ii_0008 = 182;
   Ii_000C = 183;
   Ii_0010 = 184;
   Ii_0014 = 185;
   Ii_0018 = 186;
   Ii_001C = 187;
   Ii_0020 = 188;
   Ii_0024 = 189;
   Ii_0028 = 190;
   Ii_002C = 191;
   Ii_0030 = 192;
   Ii_0034 = 193;
   } 
   if (_Symbol == "EURJPYm" || _Symbol == "EURJPY") { 
   
   Ii_0000 = 200;
   Ii_0004 = 201;
   Ii_0008 = 202;
   Ii_000C = 203;
   Ii_0010 = 204;
   Ii_0014 = 205;
   Ii_0018 = 206;
   Ii_001C = 207;
   Ii_0020 = 208;
   Ii_0024 = 209;
   Ii_0028 = 210;
   Ii_002C = 211;
   Ii_0030 = 212;
   Ii_0034 = 213;
   } 
   if (_Symbol == "EURUSDm" || _Symbol == "EURUSD") { 
   
   Ii_0000 = 220;
   Ii_0004 = 221;
   Ii_0008 = 222;
   Ii_000C = 223;
   Ii_0010 = 224;
   Ii_0014 = 225;
   Ii_0018 = 226;
   Ii_001C = 227;
   Ii_0020 = 228;
   Ii_0024 = 229;
   Ii_0028 = 230;
   Ii_002C = 231;
   Ii_0030 = 232;
   Ii_0034 = 233;
   } 
   if (_Symbol == "GBPCHFm" || _Symbol == "GBPCHF") { 
   
   Ii_0000 = 240;
   Ii_0004 = 241;
   Ii_0008 = 242;
   Ii_000C = 243;
   Ii_0010 = 244;
   Ii_0014 = 245;
   Ii_0018 = 246;
   Ii_001C = 247;
   Ii_0020 = 248;
   Ii_0024 = 249;
   Ii_0028 = 250;
   Ii_002C = 251;
   Ii_0030 = 252;
   Ii_0034 = 253;
   } 
   if (_Symbol == "GBPJPYm" || _Symbol == "GBPJPY") { 
   
   Ii_0000 = 260;
   Ii_0004 = 261;
   Ii_0008 = 262;
   Ii_000C = 263;
   Ii_0010 = 264;
   Ii_0014 = 265;
   Ii_0018 = 266;
   Ii_001C = 267;
   Ii_0020 = 268;
   Ii_0024 = 269;
   Ii_0028 = 270;
   Ii_002C = 271;
   Ii_0030 = 272;
   Ii_0034 = 273;
   } 
   if (_Symbol == "GBPUSDm" || _Symbol == "GBPUSD") { 
   
   Ii_0000 = 280;
   Ii_0004 = 281;
   Ii_0008 = 282;
   Ii_000C = 283;
   Ii_0010 = 284;
   Ii_0014 = 285;
   Ii_0018 = 286;
   Ii_001C = 287;
   Ii_0020 = 288;
   Ii_0024 = 289;
   Ii_0028 = 290;
   Ii_002C = 291;
   Ii_0030 = 292;
   Ii_0034 = 293;
   } 
   if (_Symbol == "NZDJPYm" || _Symbol == "NZDJPY") { 
   
   Ii_0000 = 300;
   Ii_0004 = 301;
   Ii_0008 = 302;
   Ii_000C = 303;
   Ii_0010 = 304;
   Ii_0014 = 305;
   Ii_0018 = 306;
   Ii_001C = 307;
   Ii_0020 = 308;
   Ii_0024 = 309;
   Ii_0028 = 310;
   Ii_002C = 311;
   Ii_0030 = 312;
   Ii_0034 = 313;
   } 
   if (_Symbol == "NZDUSDm" || _Symbol == "NZDUSD") { 
   
   Ii_0000 = 320;
   Ii_0004 = 321;
   Ii_0008 = 322;
   Ii_000C = 323;
   Ii_0010 = 324;
   Ii_0014 = 325;
   Ii_0018 = 326;
   Ii_001C = 327;
   Ii_0020 = 328;
   Ii_0024 = 329;
   Ii_0028 = 330;
   Ii_002C = 331;
   Ii_0030 = 332;
   Ii_0034 = 333;
   } 
   if (_Symbol == "USDCHFm" || _Symbol == "USDCHF") { 
   
   Ii_0000 = 340;
   Ii_0004 = 341;
   Ii_0008 = 342;
   Ii_000C = 343;
   Ii_0010 = 344;
   Ii_0014 = 345;
   Ii_0018 = 346;
   Ii_001C = 347;
   Ii_0020 = 348;
   Ii_0024 = 349;
   Ii_0028 = 350;
   Ii_002C = 351;
   Ii_0030 = 352;
   Ii_0034 = 353;
   } 
   if (_Symbol == "USDJPYm" || _Symbol == "USDJPY") { 
   
   Ii_0000 = 360;
   Ii_0004 = 361;
   Ii_0008 = 362;
   Ii_000C = 363;
   Ii_0010 = 364;
   Ii_0014 = 365;
   Ii_0018 = 366;
   Ii_001C = 367;
   Ii_0020 = 368;
   Ii_0024 = 369;
   Ii_0028 = 370;
   Ii_002C = 371;
   Ii_0030 = 372;
   Ii_0034 = 373;
   } 
   if (_Symbol == "USDCADm" || _Symbol == "USDCAD") { 
   
   Ii_0000 = 380;
   Ii_0004 = 381;
   Ii_0008 = 382;
   Ii_000C = 383;
   Ii_0010 = 384;
   Ii_0014 = 385;
   Ii_0018 = 386;
   Ii_001C = 387;
   Ii_0020 = 388;
   Ii_0024 = 389;
   Ii_0028 = 390;
   Ii_002C = 391;
   Ii_0030 = 392;
   Ii_0034 = 393;
   } 
   if (_Symbol == "AUDCHFm" || _Symbol == "AUDCHF") { 
   
   Ii_0000 = 400;
   Ii_0004 = 401;
   Ii_0008 = 402;
   Ii_000C = 403;
   Ii_0010 = 404;
   Ii_0014 = 405;
   Ii_0018 = 406;
   Ii_001C = 407;
   Ii_0020 = 408;
   Ii_0024 = 409;
   Ii_0028 = 410;
   Ii_002C = 411;
   Ii_0030 = 412;
   Ii_0034 = 413;
   } 
   if (_Symbol == "AUDSGDm" || _Symbol == "AUDSGD") { 
   
   Ii_0000 = 420;
   Ii_0004 = 421;
   Ii_0008 = 422;
   Ii_000C = 423;
   Ii_0010 = 424;
   Ii_0014 = 425;
   Ii_0018 = 426;
   Ii_001C = 427;
   Ii_0020 = 428;
   Ii_0024 = 429;
   Ii_0028 = 430;
   Ii_002C = 431;
   Ii_0030 = 432;
   Ii_0034 = 433;
   } 
   if (_Symbol == "CHFSGDm" || _Symbol == "CHFSGD") { 
   
   Ii_0000 = 440;
   Ii_0004 = 441;
   Ii_0008 = 442;
   Ii_000C = 443;
   Ii_0010 = 444;
   Ii_0014 = 445;
   Ii_0018 = 446;
   Ii_001C = 447;
   Ii_0020 = 448;
   Ii_0024 = 449;
   Ii_0028 = 450;
   Ii_002C = 451;
   Ii_0030 = 452;
   Ii_0034 = 453;
   } 
   if (_Symbol == "CADCHFm" || _Symbol == "CADCHF") { 
   
   Ii_0000 = 460;
   Ii_0004 = 461;
   Ii_0008 = 462;
   Ii_000C = 463;
   Ii_0010 = 464;
   Ii_0014 = 465;
   Ii_0018 = 466;
   Ii_001C = 467;
   Ii_0020 = 468;
   Ii_0024 = 469;
   Ii_0028 = 470;
   Ii_002C = 471;
   Ii_0030 = 472;
   Ii_0034 = 473;
   } 
   if (_Symbol == "CADJPYm" || _Symbol == "CADJPY") { 
   
   Ii_0000 = 480;
   Ii_0004 = 481;
   Ii_0008 = 482;
   Ii_000C = 483;
   Ii_0010 = 484;
   Ii_0014 = 485;
   Ii_0018 = 486;
   Ii_001C = 487;
   Ii_0020 = 488;
   Ii_0024 = 489;
   Ii_0028 = 490;
   Ii_002C = 491;
   Ii_0030 = 492;
   Ii_0034 = 493;
   } 
   if (_Symbol == "EURNZDm" || _Symbol == "EURNZD") { 
   
   Ii_0000 = 500;
   Ii_0004 = 501;
   Ii_0008 = 502;
   Ii_000C = 503;
   Ii_0010 = 504;
   Ii_0014 = 505;
   Ii_0018 = 506;
   Ii_001C = 507;
   Ii_0020 = 508;
   Ii_0024 = 509;
   Ii_0028 = 510;
   Ii_002C = 511;
   Ii_0030 = 512;
   Ii_0034 = 513;
   } 
   if (_Symbol == "EURSGDm" || _Symbol == "EURSGD") { 
   
   Ii_0000 = 520;
   Ii_0004 = 521;
   Ii_0008 = 522;
   Ii_000C = 523;
   Ii_0010 = 524;
   Ii_0014 = 525;
   Ii_0018 = 526;
   Ii_001C = 527;
   Ii_0020 = 528;
   Ii_0024 = 529;
   Ii_0028 = 530;
   Ii_002C = 531;
   Ii_0030 = 532;
   Ii_0034 = 533;
   } 
   if (_Symbol == "EURDKKm" || _Symbol == "EURDKK") { 
   
   Ii_0000 = 540;
   Ii_0004 = 541;
   Ii_0008 = 542;
   Ii_000C = 543;
   Ii_0010 = 544;
   Ii_0014 = 545;
   Ii_0018 = 546;
   Ii_001C = 547;
   Ii_0020 = 548;
   Ii_0024 = 549;
   Ii_0028 = 550;
   Ii_002C = 551;
   Ii_0030 = 552;
   Ii_0034 = 553;
   } 
   if (_Symbol == "EURHKDm" || _Symbol == "EURHKD") { 
   
   Ii_0000 = 560;
   Ii_0004 = 561;
   Ii_0008 = 562;
   Ii_000C = 563;
   Ii_0010 = 564;
   Ii_0014 = 565;
   Ii_0018 = 566;
   Ii_001C = 567;
   Ii_0020 = 568;
   Ii_0024 = 569;
   Ii_0028 = 570;
   Ii_002C = 571;
   Ii_0030 = 572;
   Ii_0034 = 573;
   } 
   if (_Symbol == "GBPAUDm" || _Symbol == "GBPAUD") { 
   
   Ii_0000 = 580;
   Ii_0004 = 581;
   Ii_0008 = 582;
   Ii_000C = 583;
   Ii_0010 = 584;
   Ii_0014 = 585;
   Ii_0018 = 586;
   Ii_001C = 587;
   Ii_0020 = 588;
   Ii_0024 = 589;
   Ii_0028 = 590;
   Ii_002C = 591;
   Ii_0030 = 592;
   Ii_0034 = 593;
   } 
   if (_Symbol == "GBPCADm" || _Symbol == "GBPCAD") { 
   
   Ii_0000 = 600;
   Ii_0004 = 601;
   Ii_0008 = 602;
   Ii_000C = 603;
   Ii_0010 = 604;
   Ii_0014 = 605;
   Ii_0018 = 606;
   Ii_001C = 607;
   Ii_0020 = 608;
   Ii_0024 = 609;
   Ii_0028 = 610;
   Ii_002C = 611;
   Ii_0030 = 612;
   Ii_0034 = 613;
   } 
   if (_Symbol == "GBPNZDm" || _Symbol == "GBPNZD") { 
   
   Ii_0000 = 620;
   Ii_0004 = 621;
   Ii_0008 = 622;
   Ii_000C = 623;
   Ii_0010 = 624;
   Ii_0014 = 625;
   Ii_0018 = 626;
   Ii_001C = 627;
   Ii_0020 = 628;
   Ii_0024 = 629;
   Ii_0028 = 630;
   Ii_002C = 631;
   Ii_0030 = 632;
   Ii_0034 = 633;
   } 
   if (_Symbol == "GBPSGDm" || _Symbol == "GBPSGD") { 
   
   Ii_0000 = 640;
   Ii_0004 = 641;
   Ii_0008 = 642;
   Ii_000C = 643;
   Ii_0010 = 644;
   Ii_0014 = 645;
   Ii_0018 = 646;
   Ii_001C = 647;
   Ii_0020 = 648;
   Ii_0024 = 649;
   Ii_0028 = 650;
   Ii_002C = 651;
   Ii_0030 = 652;
   Ii_0034 = 653;
   } 
   if (_Symbol == "NZDCADm" || _Symbol == "NZDCHF") { 
   
   Ii_0000 = 660;
   Ii_0004 = 661;
   Ii_0008 = 662;
   Ii_000C = 663;
   Ii_0010 = 664;
   Ii_0014 = 665;
   Ii_0018 = 666;
   Ii_001C = 667;
   Ii_0020 = 668;
   Ii_0024 = 669;
   Ii_0028 = 670;
   Ii_002C = 671;
   Ii_0030 = 672;
   Ii_0034 = 673;
   } 
   if (_Symbol == "NZDCHFm" || _Symbol == "NZDCHF") { 
   
   Ii_0000 = 680;
   Ii_0004 = 681;
   Ii_0008 = 682;
   Ii_000C = 683;
   Ii_0010 = 684;
   Ii_0014 = 685;
   Ii_0018 = 686;
   Ii_001C = 687;
   Ii_0020 = 688;
   Ii_0024 = 689;
   Ii_0028 = 690;
   Ii_002C = 691;
   Ii_0030 = 692;
   Ii_0034 = 693;
   } 
   if (_Symbol == "SGDJPYm" || _Symbol == "SGDJPY") { 
   
   Ii_0000 = 700;
   Ii_0004 = 701;
   Ii_0008 = 702;
   Ii_000C = 703;
   Ii_0010 = 704;
   Ii_0014 = 705;
   Ii_0018 = 706;
   Ii_001C = 707;
   Ii_0020 = 708;
   Ii_0024 = 709;
   Ii_0028 = 710;
   Ii_002C = 711;
   Ii_0030 = 712;
   Ii_0034 = 713;
   } 
   if (_Symbol == "USDSGDm" || _Symbol == "USDSGD") { 
   
   Ii_0000 = 720;
   Ii_0004 = 721;
   Ii_0008 = 722;
   Ii_000C = 723;
   Ii_0010 = 724;
   Ii_0014 = 725;
   Ii_0018 = 726;
   Ii_001C = 727;
   Ii_0020 = 728;
   Ii_0024 = 729;
   Ii_0028 = 730;
   Ii_002C = 731;
   Ii_0030 = 732;
   Ii_0034 = 733;
   } 
   if (_Symbol == "USDDKKm" || _Symbol == "USDDKK") { 
   
   Ii_0000 = 740;
   Ii_0004 = 741;
   Ii_0008 = 742;
   Ii_000C = 743;
   Ii_0010 = 744;
   Ii_0014 = 745;
   Ii_0018 = 746;
   Ii_001C = 747;
   Ii_0020 = 748;
   Ii_0024 = 749;
   Ii_0028 = 750;
   Ii_002C = 751;
   Ii_0030 = 752;
   Ii_0034 = 753;
   } 
   if (_Symbol == "USDHKDm" || _Symbol == "USDHKD") { 
   
   Ii_0000 = 760;
   Ii_0004 = 761;
   Ii_0008 = 762;
   Ii_000C = 763;
   Ii_0010 = 764;
   Ii_0014 = 765;
   Ii_0018 = 766;
   Ii_001C = 767;
   Ii_0020 = 768;
   Ii_0024 = 769;
   Ii_0028 = 770;
   Ii_002C = 771;
   Ii_0030 = 772;
   Ii_0034 = 773;
   } 
   tmp_str0000 = "";
   tmp_str0001 = "";
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = "";
   tmp_str0008 = "";
   tmp_str0009 = "";
   tmp_str000A = "";
   tmp_str000B = "--------------------------------------------------------";
   VerboseLog(tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   tmp_str000C = "";
   tmp_str000D = "";
   tmp_str000E = "";
   tmp_str000F = "";
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = "";
   tmp_str0016 = "";
   tmp_str0017 = "Starting the EA";
   VerboseLog(tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E, tmp_str000D, tmp_str000C);
   Ld_FFE8 = _Digits;
   if ((Ld_FFE8 > 0) && (Ld_FFE8 != 2) && (Ld_FFE8 != 4)) { 
   Ld_FFE8 = (Ld_FFE8 - 1);
   } 
   returned_double = MathPow(10, Ld_FFE8);
   Id_0088 = returned_double;
   Id_0090 = (1 / returned_double);
   tmp_str0018 = "";
   tmp_str0019 = "";
   tmp_str001A = "";
   tmp_str001B = "";
   tmp_str001C = "";
   tmp_str001D = "";
   tmp_str001E = "";
   tmp_str001F = "";
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = DoubleToString((Id_00C0 * Id_0088), 2);
   tmp_str0023 = "Broker Stop Difference: ";
   VerboseLog(tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C, tmp_str001B, tmp_str001A, tmp_str0019, tmp_str0018);
   tmp_str0024 = "";
   tmp_str0025 = "";
   tmp_str0026 = "";
   tmp_str0027 = "";
   tmp_str0028 = "";
   tmp_str0029 = "";
   tmp_str002A = "";
   tmp_str002B = "";
   tmp_str002C = "";
   tmp_str002D = "";
   tmp_str002E = "";
   tmp_str002F = "--------------------------------------------------------";
   VerboseLog(tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A, tmp_str0029, tmp_str0028, tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024);
   if (Ib_0081 == false) return 0; 
   ObjectCreate(0, "line1", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("line1", OBJPROP_CORNER, Ii_00DC);
   ObjectSet("line1", OBJPROP_YDISTANCE, Ii_00E4);
   ObjectSet("line1", OBJPROP_XDISTANCE, Ii_00E0);
   ObjectSetText("line1", "EA REVOLUTION PREMIUM", 9, "Tahoma", Ii_00E8);
   
   Li_FFFC = 0;
   
   return Li_FFFC;
}

int start()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   string tmp_str0030;
   string tmp_str0031;
   string tmp_str0032;
   string tmp_str0033;
   string tmp_str0034;
   string tmp_str0035;
   string tmp_str0036;
   string tmp_str0037;
   string tmp_str0038;
   string tmp_str0039;
   string tmp_str003A;
   string tmp_str003B;
   string tmp_str003C;
   string tmp_str003D;
   string tmp_str003E;
   string tmp_str003F;
   string tmp_str0040;
   string tmp_str0041;
   string tmp_str0042;
   string tmp_str0043;
   string tmp_str0044;
   string tmp_str0045;
   string tmp_str0046;
   string tmp_str0047;
   string tmp_str0048;
   string tmp_str0049;
   string tmp_str004A;
   int Li_FFFC;
   string Ls_FFF0;

   Li_FFFC = 0;
   Gi_0000 = 0;
   Gi_0001 = 0;
   Gd_0002 = 0;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gb_0005 = false;
   Gi_0006 = 0;
   Gi_0007 = 0;
   Gi_0008 = 0;
   Gd_0009 = 0;
   Gd_000A = 0;
   Gi_000B = 0;
   Gd_000C = 0;
   Gi_000D = 0;
   Gd_000E = 0;
   Gd_000F = 0;
   Gi_0010 = 0;
   Gd_0011 = 0;
   Gi_0012 = 0;
   Gd_0013 = 0;
   Gi_0014 = 0;
   Gd_0015 = 0;
   Gd_0016 = 0;
   Gi_0017 = 0;
   Gd_0018 = 0;
   Gd_0019 = 0;
   Gi_001A = 0;
   Gd_001B = 0;
   Gi_001C = 0;
   Gd_001D = 0;
   Gi_001E = 0;
   Gd_001F = 0;
   Gd_0020 = 0;
   Gi_0021 = 0;
   Gd_0022 = 0;
   Gd_0023 = 0;
   Gi_0024 = 0;
   Gd_0025 = 0;
   Gi_0026 = 0;
   Gd_0027 = 0;
   Gi_0028 = 0;
   Gd_0029 = 0;
   Gd_002A = 0;
   Gi_002B = 0;
   Gd_002C = 0;
   Gd_002D = 0;
   Gi_002E = 0;
   Gd_002F = 0;
   Gi_0030 = 0;
   Gd_0031 = 0;
   Gi_0032 = 0;
   Gd_0033 = 0;
   Gd_0034 = 0;
   Gi_0035 = 0;
   Gd_0036 = 0;
   Gd_0037 = 0;
   Gi_0038 = 0;
   Gd_0039 = 0;
   Gi_003A = 0;
   Gd_003B = 0;
   Gi_003C = 0;
   Gd_003D = 0;
   Gd_003E = 0;
   Gi_003F = 0;
   Gd_0040 = 0;
   Gd_0041 = 0;
   Gi_0042 = 0;
   Gd_0043 = 0;
   Gi_0044 = 0;
   Gd_0045 = 0;
   Gi_0046 = 0;
   Gd_0047 = 0;
   Gd_0048 = 0;
   Gi_0049 = 0;
   Gd_004A = 0;
   Gd_004B = 0;
   Gi_004C = 0;
   Gd_004D = 0;
   Gb_004E = false;
   Gi_004F = 0;
   Gi_0050 = 0;
   Gi_0051 = 0;
   Gd_0052 = 0;
   Gd_0053 = 0;
   Gi_0054 = 0;
   Gd_0055 = 0;
   Gi_0056 = 0;
   Gd_0057 = 0;
   Gd_0058 = 0;
   Gi_0059 = 0;
   Gd_005A = 0;
   Gi_005B = 0;
   Gd_005C = 0;
   Gi_005D = 0;
   Gd_005E = 0;
   Gd_005F = 0;
   Gi_0060 = 0;
   Gd_0061 = 0;
   Gd_0062 = 0;
   Gi_0063 = 0;
   Gd_0064 = 0;
   Gi_0065 = 0;
   Gd_0066 = 0;
   Gi_0067 = 0;
   Gd_0068 = 0;
   Gd_0069 = 0;
   Gi_006A = 0;
   Gd_006B = 0;
   Gd_006C = 0;
   Gi_006D = 0;
   Gd_006E = 0;
   Gi_006F = 0;
   Gd_0070 = 0;
   Gi_0071 = 0;
   Gd_0072 = 0;
   Gd_0073 = 0;
   Gi_0074 = 0;
   Gd_0075 = 0;
   Gd_0076 = 0;
   Gi_0077 = 0;
   Gd_0078 = 0;
   Gi_0079 = 0;
   Gd_007A = 0;
   Gi_007B = 0;
   Gd_007C = 0;
   Gd_007D = 0;
   Gi_007E = 0;
   Gd_007F = 0;
   Gd_0080 = 0;
   Gi_0081 = 0;
   Gd_0082 = 0;
   Gi_0083 = 0;
   Gd_0084 = 0;
   Gi_0085 = 0;
   Gd_0086 = 0;
   Gd_0087 = 0;
   Gi_0088 = 0;
   Gd_0089 = 0;
   Gd_008A = 0;
   Gi_008B = 0;
   Gd_008C = 0;
   Gi_008D = 0;
   Gd_008E = 0;
   Gi_008F = 0;
   Gd_0090 = 0;
   Gd_0091 = 0;
   Gi_0092 = 0;
   Gd_0093 = 0;
   Gd_0094 = 0;
   Gi_0095 = 0;
   Gd_0096 = 0;
   Gd_0097 = 0;
   Gi_0098 = 0;
   Gd_0099 = 0;
   Gi_009A = 0;
   Gi_009B = 0;
   Gd_009C = 0;
   Gi_009D = 0;
   Gd_009E = 0;
   Gi_009F = 0;
   Gd_00A0 = 0;
   Gi_00A1 = 0;
   Gi_00A2 = 0;
   Gd_00A3 = 0;
   Gi_00A4 = 0;
   Gd_00A5 = 0;
   Gi_00A6 = 0;
   Gd_00A7 = 0;
   Gi_00A8 = 0;
   Gd_00A9 = 0;
   Gi_00AA = 0;
   Gd_00AB = 0;
   Gi_00AC = 0;
   Gi_00AD = 0;
   Gd_00AE = 0;
   Gi_00AF = 0;
   Gi_00B0 = 0;
   Gd_00B1 = 0;
   Gi_00B2 = 0;
   Gd_00B3 = 0;
   Gi_00B4 = 0;
   Gd_00B5 = 0;
   Gi_00B6 = 0;
   Gi_00B7 = 0;
   Gd_00B8 = 0;
   Gi_00B9 = 0;
   Gd_00BA = 0;
   Gi_00BB = 0;
   Gd_00BC = 0;
   Gi_00BD = 0;
   Gi_00BE = 0;
   Gd_00BF = 0;
   Gi_00C0 = 0;
   Gd_00C1 = 0;
   Gi_00C2 = 0;
   Gd_00C3 = 0;
   Gi_00C4 = 0;
   Gd_00C5 = 0;
   Gi_00C6 = 0;
   Gd_00C7 = 0;
   Gi_00C8 = 0;
   Gi_00C9 = 0;
   Gd_00CA = 0;
   Gi_00CB = 0;
   Gi_00CC = 0;
   Gd_00CD = 0;
   Gi_00CE = 0;
   if (Bars < 30) { 
   if (Ib_0082) { 
   Print("NOT ENOUGH DATA: Less Bars than 30");
   } 
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   tmp_str0000 = TimeToString(Time[0], 1);
   Gi_0000 = _Period;
   if (Gi_0000 == 240 || _Period == 60) { 
   
   tmp_str0001 = (string)TimeHour(Time[0]);
   tmp_str0001 = tmp_str0000 + tmp_str0001;
   tmp_str0000 = tmp_str0001;
   } 
   if (Gi_0000 == 5 || Gi_0000 == 1) { 
   
   tmp_str0001 = tmp_str0000 + " ";
   tmp_str0001 = tmp_str0001 + TimeToString(Time[0], 2);
   tmp_str0000 = tmp_str0001;
   } 
   Ls_FFF0 = tmp_str0000;
   if (tmp_str0000 == Is_00C8) { 
   Ib_00D4 = false;
   } 
   else { 
   Is_00C8 = Ls_FFF0;
   Ib_00D4 = true;
   } 
   Gi_00D2 = Ii_00E8;
   Gi_0001 = 0;
   Gd_0002 = 0;
   Gi_00D3 = OrdersTotal() - 1;
   Gi_0003 = Gi_00D3;
   if (Gi_00D3 >= 0) { 
   do { 
   if (OrderSelect(Gi_0003, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0001 == 0 || OrderMagicNumber() == Gi_0001) { 
   
   Gd_0002 = (Gd_0002 + OrderProfit());
   }}}} 
   Gi_0003 = Gi_0003 - 1;
   } while (Gi_0003 >= 0); 
   } 
   tmp_str0001 = "Open P/L: " + DoubleToString(Gd_0002, 2);
   ObjectSetText("lineopl", tmp_str0001, 8, "Tahoma", Gi_00D2);
   tmp_str0002 = "Account Balance: " + DoubleToString(AccountBalance(), 2);
   ObjectSetText("linea", tmp_str0002, 8, "Tahoma", Ii_00E8);
   if (Ib_00D4) { 
   sqTextFillTotals();
   } 
   Gi_00D3 = OrdersTotal() - 1;
   Gi_0004 = Gi_00D3;
   if (Gi_00D3 >= 0) { 
   do { 
   if (OrderSelect(Gi_0004, 0, 0) == true) { 
   manageOrder(OrderMagicNumber());
   if (Ib_00D4) { 
   manageOrderExpiration(OrderMagicNumber());
   }} 
   if (OrdersTotal() <= 0) break; 
   Gi_0004 = Gi_0004 - 1;
   } while (Gi_0004 >= 0); 
   } 
   Gd_00D3 = iMA(NULL, 240, 200, 0, 1, 0, 1);
   if ((Gd_00D3 < Close[1]) && PowerRisk == 0 && OrdersTotal() < MaxOrders) { 
   Gi_0006 = Ii_0000;
   Gi_0007 = 0;
   Gb_0005 = false;
   if (OrdersTotal() > 0) {
   do { 
   if (OrderSelect(Gi_0007, 0, 0) == true && OrderSymbol() == _Symbol) {
   if (Gi_0006 == 0 || OrderMagicNumber() == Gi_0006) {
   
   Gl_00D3 = OrderOpenTime();
   if (Gl_00D3 > Time[1]) {
   Gb_0005 = true;
   break;
   }}}
   Gi_0007 = Gi_0007 + 1;
   } while (Gi_0007 < OrdersTotal()); 
   }
   Gi_0007 = HistoryTotal();
   if (Gi_0007 >= 0) {
   do { 
   if (OrderSelect(Gi_0007, 0, 1) == true && OrderSymbol() == _Symbol) {
   if (Gi_0006 == 0 || OrderMagicNumber() == Gi_0006) {
   
   Gl_00D3 = OrderOpenTime();
   if (Gl_00D3 > Time[1]) {
   Gb_0005 = true;
   break;
   }}}
   Gi_0007 = Gi_0007 - 1;
   } while (Gi_0007 >= 0); 
   }
   else Gb_0005 = false;
   
   if (Gb_0005 == 0 && (MarketInfo(_Symbol, MODE_SWAPLONG) >= SwapMinimo)) { 
   if ((iRSI(NULL, 240, 14, 0, 1) <= PotenzaBuy) || (iStochastic(NULL, 240, 50, 3, 3, 0, 0, 0, 1) <= UltraBuy)) { 
   
   tmp_str0003 = "Go long 1";
   tmp_str0004 = "EAREVPREMIUM";
   Gi_000B = Ii_0000;
   Gd_000C = 0;
   if (Ii_0000 == Ii_0000) { 
   Gd_000C = Ask;
   } 
   if (Gi_000B == Ii_0004) { 
   Gd_000C = Ask;
   } 
   if (Gi_000B == Ii_0008) { 
   Gd_000C = Ask;
   } 
   if (Gi_000B == Ii_000C) { 
   Gd_000C = Ask;
   } 
   if (Gi_000B == Ii_0010) { 
   Gd_000C = Ask;
   } 
   if (Gi_000B == Ii_0014) { 
   Gd_000C = Ask;
   } 
   if (Gi_000B == Ii_0018) { 
   Gd_000C = Ask;
   } 
   if (Gi_000B == Ii_001C) { 
   Gd_000C = Bid;
   } 
   if (Gi_000B == Ii_0020) { 
   Gd_000C = Bid;
   } 
   if (Gi_000B == Ii_0024) { 
   Gd_000C = Bid;
   } 
   if (Gi_000B == Ii_0028) { 
   Gd_000C = Bid;
   } 
   if (Gi_000B == Ii_002C) { 
   Gd_000C = Bid;
   } 
   if (Gi_000B == Ii_0030) { 
   Gd_000C = Bid;
   } 
   if (Gi_000B == Ii_0034) { 
   Gd_000C = Bid;
   } 
   Gi_0008 = Ii_0000;
   Gd_0009 = 0;
   if (Ii_0000 == Ii_0000) { 
   Gd_0009 = LotSize;
   } 
   if (Gi_0008 == Ii_0004) { 
   Gd_0009 = Id_0040;
   } 
   if (Gi_0008 == Ii_0008) { 
   Gd_0009 = Id_0048;
   } 
   if (Gi_0008 == Ii_000C) { 
   Gd_0009 = Id_0050;
   } 
   if (Gi_0008 == Ii_0010) { 
   Gd_0009 = Id_0058;
   } 
   if (Gi_0008 == Ii_0014) { 
   Gd_0009 = Id_0060;
   } 
   if (Gi_0008 == Ii_0018) { 
   Gd_0009 = Id_0060;
   } 
   if (Gi_0008 == Ii_001C) { 
   Gd_0009 = LotSize;
   } 
   if (Gi_0008 == Ii_0020) { 
   Gd_0009 = Id_0040;
   } 
   if (Gi_0008 == Ii_0024) { 
   Gd_0009 = Id_0048;
   } 
   if (Gi_0008 == Ii_0028) { 
   Gd_0009 = Id_0050;
   } 
   if (Gi_0008 == Ii_002C) { 
   Gd_0009 = Id_0058;
   } 
   if (Gi_0008 == Ii_0030) { 
   Gd_0009 = Id_0060;
   } 
   if (Gi_0008 == Ii_0034) { 
   Gd_0009 = Id_0060;
   } 
   tmp_str0005 = "NULL";
   sqOpenOrder(tmp_str0005, 0, Gd_0009, NormalizeDouble(Gd_000C, _Digits), tmp_str0004, Ii_0000, tmp_str0003);
   }}} 
   Gd_00D3 = iMA(NULL, 240, 200, 0, 1, 0, 1);
   if ((Gd_00D3 < Close[1]) && PowerRisk == true && OrdersTotal() < MaxOrders && (MarketInfo(_Symbol, MODE_SWAPLONG) >= SwapMinimo)) { 
   if ((iRSI(NULL, 240, 14, 0, 1) <= PotenzaBuy) || (iStochastic(NULL, 240, 50, 3, 3, 0, 0, 0, 1) <= UltraBuy)) { 
   
   tmp_str0006 = "Go long 1";
   tmp_str0007 = "EAREVPREMIUM";
   Gi_0010 = Ii_0000;
   Gd_0011 = 0;
   if (Ii_0000 == Ii_0000) { 
   Gd_0011 = Ask;
   } 
   if (Gi_0010 == Ii_0004) { 
   Gd_0011 = Ask;
   } 
   if (Gi_0010 == Ii_0008) { 
   Gd_0011 = Ask;
   } 
   if (Gi_0010 == Ii_000C) { 
   Gd_0011 = Ask;
   } 
   if (Gi_0010 == Ii_0010) { 
   Gd_0011 = Ask;
   } 
   if (Gi_0010 == Ii_0014) { 
   Gd_0011 = Ask;
   } 
   if (Gi_0010 == Ii_0018) { 
   Gd_0011 = Ask;
   } 
   if (Gi_0010 == Ii_001C) { 
   Gd_0011 = Bid;
   } 
   if (Gi_0010 == Ii_0020) { 
   Gd_0011 = Bid;
   } 
   if (Gi_0010 == Ii_0024) { 
   Gd_0011 = Bid;
   } 
   if (Gi_0010 == Ii_0028) { 
   Gd_0011 = Bid;
   } 
   if (Gi_0010 == Ii_002C) { 
   Gd_0011 = Bid;
   } 
   if (Gi_0010 == Ii_0030) { 
   Gd_0011 = Bid;
   } 
   if (Gi_0010 == Ii_0034) { 
   Gd_0011 = Bid;
   } 
   Gi_000D = Ii_0000;
   Gd_000E = 0;
   if (Ii_0000 == Ii_0000) { 
   Gd_000E = LotSize;
   } 
   if (Gi_000D == Ii_0004) { 
   Gd_000E = Id_0040;
   } 
   if (Gi_000D == Ii_0008) { 
   Gd_000E = Id_0048;
   } 
   if (Gi_000D == Ii_000C) { 
   Gd_000E = Id_0050;
   } 
   if (Gi_000D == Ii_0010) { 
   Gd_000E = Id_0058;
   } 
   if (Gi_000D == Ii_0014) { 
   Gd_000E = Id_0060;
   } 
   if (Gi_000D == Ii_0018) { 
   Gd_000E = Id_0060;
   } 
   if (Gi_000D == Ii_001C) { 
   Gd_000E = LotSize;
   } 
   if (Gi_000D == Ii_0020) { 
   Gd_000E = Id_0040;
   } 
   if (Gi_000D == Ii_0024) { 
   Gd_000E = Id_0048;
   } 
   if (Gi_000D == Ii_0028) { 
   Gd_000E = Id_0050;
   } 
   if (Gi_000D == Ii_002C) { 
   Gd_000E = Id_0058;
   } 
   if (Gi_000D == Ii_0030) { 
   Gd_000E = Id_0060;
   } 
   if (Gi_000D == Ii_0034) { 
   Gd_000E = Id_0060;
   } 
   tmp_str0008 = "NULL";
   sqOpenOrder(tmp_str0008, 0, Gd_000E, NormalizeDouble(Gd_0011, _Digits), tmp_str0007, Ii_0000, tmp_str0006);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Gi_0012 = Ii_0000;
   Gd_0013 = 0;
   Gi_00D3 = OrdersTotal() - 1;
   Gi_0014 = Gi_00D3;
   if (Gi_00D3 >= 0) { 
   do { 
   if (OrderSelect(Gi_0014, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0012 == 0 || OrderMagicNumber() == Gi_0012) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str0009 = OrderSymbol();
   if (tmp_str0009 == "NULL") { 
   Gd_0015 = Bid;
   } 
   else { 
   Gd_0015 = MarketInfo(tmp_str0009, MODE_BID);
   } 
   Gd_0013 = ((Gd_0015 - OrderOpenPrice()) + Gd_0013);
   } 
   else { 
   Gd_00D3 = OrderOpenPrice();
   tmp_str000A = OrderSymbol();
   if (tmp_str000A == "NULL") { 
   Gd_0016 = Ask;
   } 
   else { 
   Gd_0016 = MarketInfo(tmp_str000A, MODE_ASK);
   } 
   Gd_0013 = ((Gd_00D3 - Gd_0016) + Gd_0013);
   }}}}} 
   Gi_0014 = Gi_0014 - 1;
   } while (Gi_0014 >= 0); 
   } 
   if (((Gd_0013 * Id_0088) <= -70)) { 
   Id_0040 = ((LotSize + 0.0018) * Id_0070);
   tmp_str000B = "Go long 2";
   tmp_str000C = "EAREVPREMIUM";
   Gi_001A = Ii_0004;
   Gd_001B = 0;
   if (Ii_0004 == Ii_0000) { 
   Gd_001B = Ask;
   } 
   if (Gi_001A == Ii_0004) { 
   Gd_001B = Ask;
   } 
   if (Gi_001A == Ii_0008) { 
   Gd_001B = Ask;
   } 
   if (Gi_001A == Ii_000C) { 
   Gd_001B = Ask;
   } 
   if (Gi_001A == Ii_0010) { 
   Gd_001B = Ask;
   } 
   if (Gi_001A == Ii_0014) { 
   Gd_001B = Ask;
   } 
   if (Gi_001A == Ii_0018) { 
   Gd_001B = Ask;
   } 
   if (Gi_001A == Ii_001C) { 
   Gd_001B = Bid;
   } 
   if (Gi_001A == Ii_0020) { 
   Gd_001B = Bid;
   } 
   if (Gi_001A == Ii_0024) { 
   Gd_001B = Bid;
   } 
   if (Gi_001A == Ii_0028) { 
   Gd_001B = Bid;
   } 
   if (Gi_001A == Ii_002C) { 
   Gd_001B = Bid;
   } 
   if (Gi_001A == Ii_0030) { 
   Gd_001B = Bid;
   } 
   if (Gi_001A == Ii_0034) { 
   Gd_001B = Bid;
   } 
   Gi_0017 = Ii_0004;
   Gd_0018 = 0;
   if (Ii_0004 == Ii_0000) { 
   Gd_0018 = LotSize;
   } 
   if (Gi_0017 == Ii_0004) { 
   Gd_0018 = Id_0040;
   } 
   if (Gi_0017 == Ii_0008) { 
   Gd_0018 = Id_0048;
   } 
   if (Gi_0017 == Ii_000C) { 
   Gd_0018 = Id_0050;
   } 
   if (Gi_0017 == Ii_0010) { 
   Gd_0018 = Id_0058;
   } 
   if (Gi_0017 == Ii_0014) { 
   Gd_0018 = Id_0060;
   } 
   if (Gi_0017 == Ii_0018) { 
   Gd_0018 = Id_0060;
   } 
   if (Gi_0017 == Ii_001C) { 
   Gd_0018 = LotSize;
   } 
   if (Gi_0017 == Ii_0020) { 
   Gd_0018 = Id_0040;
   } 
   if (Gi_0017 == Ii_0024) { 
   Gd_0018 = Id_0048;
   } 
   if (Gi_0017 == Ii_0028) { 
   Gd_0018 = Id_0050;
   } 
   if (Gi_0017 == Ii_002C) { 
   Gd_0018 = Id_0058;
   } 
   if (Gi_0017 == Ii_0030) { 
   Gd_0018 = Id_0060;
   } 
   if (Gi_0017 == Ii_0034) { 
   Gd_0018 = Id_0060;
   } 
   tmp_str000D = "NULL";
   sqOpenOrder(tmp_str000D, 0, Gd_0018, NormalizeDouble(Gd_001B, _Digits), tmp_str000C, Ii_0004, tmp_str000B);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Gi_001C = Ii_0004;
   Gd_001D = 0;
   Gi_00D3 = OrdersTotal() - 1;
   Gi_001E = Gi_00D3;
   if (Gi_00D3 >= 0) { 
   do { 
   if (OrderSelect(Gi_001E, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_001C == 0 || OrderMagicNumber() == Gi_001C) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str000E = OrderSymbol();
   if (tmp_str000E == "NULL") { 
   Gd_001F = Bid;
   } 
   else { 
   Gd_001F = MarketInfo(tmp_str000E, MODE_BID);
   } 
   Gd_001D = ((Gd_001F - OrderOpenPrice()) + Gd_001D);
   } 
   else { 
   Gd_00D3 = OrderOpenPrice();
   tmp_str000F = OrderSymbol();
   if (tmp_str000F == "NULL") { 
   Gd_0020 = Ask;
   } 
   else { 
   Gd_0020 = MarketInfo(tmp_str000F, MODE_ASK);
   } 
   Gd_001D = ((Gd_00D3 - Gd_0020) + Gd_001D);
   }}}}} 
   Gi_001E = Gi_001E - 1;
   } while (Gi_001E >= 0); 
   } 
   if (((Gd_001D * Id_0088) <= -120)) { 
   Gd_00D3 = (LotSize + 0.0018);
   Id_0048 = ((Id_0070 * Id_0070) * Gd_00D3);
   tmp_str0010 = "Go long 3";
   tmp_str0011 = "EAREVPREMIUM";
   Gi_0024 = Ii_0008;
   Gd_0025 = 0;
   if (Ii_0008 == Ii_0000) { 
   Gd_0025 = Ask;
   } 
   if (Gi_0024 == Ii_0004) { 
   Gd_0025 = Ask;
   } 
   if (Gi_0024 == Ii_0008) { 
   Gd_0025 = Ask;
   } 
   if (Gi_0024 == Ii_000C) { 
   Gd_0025 = Ask;
   } 
   if (Gi_0024 == Ii_0010) { 
   Gd_0025 = Ask;
   } 
   if (Gi_0024 == Ii_0014) { 
   Gd_0025 = Ask;
   } 
   if (Gi_0024 == Ii_0018) { 
   Gd_0025 = Ask;
   } 
   if (Gi_0024 == Ii_001C) { 
   Gd_0025 = Bid;
   } 
   if (Gi_0024 == Ii_0020) { 
   Gd_0025 = Bid;
   } 
   if (Gi_0024 == Ii_0024) { 
   Gd_0025 = Bid;
   } 
   if (Gi_0024 == Ii_0028) { 
   Gd_0025 = Bid;
   } 
   if (Gi_0024 == Ii_002C) { 
   Gd_0025 = Bid;
   } 
   if (Gi_0024 == Ii_0030) { 
   Gd_0025 = Bid;
   } 
   if (Gi_0024 == Ii_0034) { 
   Gd_0025 = Bid;
   } 
   Gi_0021 = Ii_0008;
   Gd_0022 = 0;
   if (Ii_0008 == Ii_0000) { 
   Gd_0022 = LotSize;
   } 
   if (Gi_0021 == Ii_0004) { 
   Gd_0022 = Id_0040;
   } 
   if (Gi_0021 == Ii_0008) { 
   Gd_0022 = Id_0048;
   } 
   if (Gi_0021 == Ii_000C) { 
   Gd_0022 = Id_0050;
   } 
   if (Gi_0021 == Ii_0010) { 
   Gd_0022 = Id_0058;
   } 
   if (Gi_0021 == Ii_0014) { 
   Gd_0022 = Id_0060;
   } 
   if (Gi_0021 == Ii_0018) { 
   Gd_0022 = Id_0060;
   } 
   if (Gi_0021 == Ii_001C) { 
   Gd_0022 = LotSize;
   } 
   if (Gi_0021 == Ii_0020) { 
   Gd_0022 = Id_0040;
   } 
   if (Gi_0021 == Ii_0024) { 
   Gd_0022 = Id_0048;
   } 
   if (Gi_0021 == Ii_0028) { 
   Gd_0022 = Id_0050;
   } 
   if (Gi_0021 == Ii_002C) { 
   Gd_0022 = Id_0058;
   } 
   if (Gi_0021 == Ii_0030) { 
   Gd_0022 = Id_0060;
   } 
   if (Gi_0021 == Ii_0034) { 
   Gd_0022 = Id_0060;
   } 
   tmp_str0012 = "NULL";
   sqOpenOrder(tmp_str0012, 0, Gd_0022, NormalizeDouble(Gd_0025, _Digits), tmp_str0011, Ii_0008, tmp_str0010);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Gi_0026 = Ii_0008;
   Gd_0027 = 0;
   Gi_00D3 = OrdersTotal() - 1;
   Gi_0028 = Gi_00D3;
   if (Gi_00D3 >= 0) { 
   do { 
   if (OrderSelect(Gi_0028, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0026 == 0 || OrderMagicNumber() == Gi_0026) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str0013 = OrderSymbol();
   if (tmp_str0013 == "NULL") { 
   Gd_0029 = Bid;
   } 
   else { 
   Gd_0029 = MarketInfo(tmp_str0013, MODE_BID);
   } 
   Gd_0027 = ((Gd_0029 - OrderOpenPrice()) + Gd_0027);
   } 
   else { 
   Gd_00D3 = OrderOpenPrice();
   tmp_str0014 = OrderSymbol();
   if (tmp_str0014 == "NULL") { 
   Gd_002A = Ask;
   } 
   else { 
   Gd_002A = MarketInfo(tmp_str0014, MODE_ASK);
   } 
   Gd_0027 = ((Gd_00D3 - Gd_002A) + Gd_0027);
   }}}}} 
   Gi_0028 = Gi_0028 - 1;
   } while (Gi_0028 >= 0); 
   } 
   if (((Gd_0027 * Id_0088) <= -150)) { 
   Gd_00D3 = (LotSize + 0.0018);
   Id_0050 = (((Id_0070 * Id_0070) * Id_0070) * Gd_00D3);
   tmp_str0015 = "Go long 4";
   tmp_str0016 = "EAREVPREMIUM";
   Gi_002E = Ii_000C;
   Gd_002F = 0;
   if (Ii_000C == Ii_0000) { 
   Gd_002F = Ask;
   } 
   if (Gi_002E == Ii_0004) { 
   Gd_002F = Ask;
   } 
   if (Gi_002E == Ii_0008) { 
   Gd_002F = Ask;
   } 
   if (Gi_002E == Ii_000C) { 
   Gd_002F = Ask;
   } 
   if (Gi_002E == Ii_0010) { 
   Gd_002F = Ask;
   } 
   if (Gi_002E == Ii_0014) { 
   Gd_002F = Ask;
   } 
   if (Gi_002E == Ii_0018) { 
   Gd_002F = Ask;
   } 
   if (Gi_002E == Ii_001C) { 
   Gd_002F = Bid;
   } 
   if (Gi_002E == Ii_0020) { 
   Gd_002F = Bid;
   } 
   if (Gi_002E == Ii_0024) { 
   Gd_002F = Bid;
   } 
   if (Gi_002E == Ii_0028) { 
   Gd_002F = Bid;
   } 
   if (Gi_002E == Ii_002C) { 
   Gd_002F = Bid;
   } 
   if (Gi_002E == Ii_0030) { 
   Gd_002F = Bid;
   } 
   if (Gi_002E == Ii_0034) { 
   Gd_002F = Bid;
   } 
   Gi_002B = Ii_000C;
   Gd_002C = 0;
   if (Ii_000C == Ii_0000) { 
   Gd_002C = LotSize;
   } 
   if (Gi_002B == Ii_0004) { 
   Gd_002C = Id_0040;
   } 
   if (Gi_002B == Ii_0008) { 
   Gd_002C = Id_0048;
   } 
   if (Gi_002B == Ii_000C) { 
   Gd_002C = Id_0050;
   } 
   if (Gi_002B == Ii_0010) { 
   Gd_002C = Id_0058;
   } 
   if (Gi_002B == Ii_0014) { 
   Gd_002C = Id_0060;
   } 
   if (Gi_002B == Ii_0018) { 
   Gd_002C = Id_0060;
   } 
   if (Gi_002B == Ii_001C) { 
   Gd_002C = LotSize;
   } 
   if (Gi_002B == Ii_0020) { 
   Gd_002C = Id_0040;
   } 
   if (Gi_002B == Ii_0024) { 
   Gd_002C = Id_0048;
   } 
   if (Gi_002B == Ii_0028) { 
   Gd_002C = Id_0050;
   } 
   if (Gi_002B == Ii_002C) { 
   Gd_002C = Id_0058;
   } 
   if (Gi_002B == Ii_0030) { 
   Gd_002C = Id_0060;
   } 
   if (Gi_002B == Ii_0034) { 
   Gd_002C = Id_0060;
   } 
   tmp_str0017 = "NULL";
   sqOpenOrder(tmp_str0017, 0, Gd_002C, NormalizeDouble(Gd_002F, _Digits), tmp_str0016, Ii_000C, tmp_str0015);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Gi_0030 = Ii_000C;
   Gd_0031 = 0;
   Gi_00D3 = OrdersTotal() - 1;
   Gi_0032 = Gi_00D3;
   if (Gi_00D3 >= 0) { 
   do { 
   if (OrderSelect(Gi_0032, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0030 == 0 || OrderMagicNumber() == Gi_0030) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str0018 = OrderSymbol();
   if (tmp_str0018 == "NULL") { 
   Gd_0033 = Bid;
   } 
   else { 
   Gd_0033 = MarketInfo(tmp_str0018, MODE_BID);
   } 
   Gd_0031 = ((Gd_0033 - OrderOpenPrice()) + Gd_0031);
   } 
   else { 
   Gd_00D3 = OrderOpenPrice();
   tmp_str0019 = OrderSymbol();
   if (tmp_str0019 == "NULL") { 
   Gd_0034 = Ask;
   } 
   else { 
   Gd_0034 = MarketInfo(tmp_str0019, MODE_ASK);
   } 
   Gd_0031 = ((Gd_00D3 - Gd_0034) + Gd_0031);
   }}}}} 
   Gi_0032 = Gi_0032 - 1;
   } while (Gi_0032 >= 0); 
   } 
   if (((Gd_0031 * Id_0088) <= -200)) { 
   Gd_00D3 = ((LotSize + 0.0018) * Id_0070);
   Id_0058 = (((Id_0070 * Id_0070) * Id_0070) * Gd_00D3);
   tmp_str001A = "Go long 5";
   tmp_str001B = "EAREVPREMIUM";
   Gi_0038 = Ii_0010;
   Gd_0039 = 0;
   if (Ii_0010 == Ii_0000) { 
   Gd_0039 = Ask;
   } 
   if (Gi_0038 == Ii_0004) { 
   Gd_0039 = Ask;
   } 
   if (Gi_0038 == Ii_0008) { 
   Gd_0039 = Ask;
   } 
   if (Gi_0038 == Ii_000C) { 
   Gd_0039 = Ask;
   } 
   if (Gi_0038 == Ii_0010) { 
   Gd_0039 = Ask;
   } 
   if (Gi_0038 == Ii_0014) { 
   Gd_0039 = Ask;
   } 
   if (Gi_0038 == Ii_0018) { 
   Gd_0039 = Ask;
   } 
   if (Gi_0038 == Ii_001C) { 
   Gd_0039 = Bid;
   } 
   if (Gi_0038 == Ii_0020) { 
   Gd_0039 = Bid;
   } 
   if (Gi_0038 == Ii_0024) { 
   Gd_0039 = Bid;
   } 
   if (Gi_0038 == Ii_0028) { 
   Gd_0039 = Bid;
   } 
   if (Gi_0038 == Ii_002C) { 
   Gd_0039 = Bid;
   } 
   if (Gi_0038 == Ii_0030) { 
   Gd_0039 = Bid;
   } 
   if (Gi_0038 == Ii_0034) { 
   Gd_0039 = Bid;
   } 
   Gi_0035 = Ii_0010;
   Gd_0036 = 0;
   if (Ii_0010 == Ii_0000) { 
   Gd_0036 = LotSize;
   } 
   if (Gi_0035 == Ii_0004) { 
   Gd_0036 = Id_0040;
   } 
   if (Gi_0035 == Ii_0008) { 
   Gd_0036 = Id_0048;
   } 
   if (Gi_0035 == Ii_000C) { 
   Gd_0036 = Id_0050;
   } 
   if (Gi_0035 == Ii_0010) { 
   Gd_0036 = Id_0058;
   } 
   if (Gi_0035 == Ii_0014) { 
   Gd_0036 = Id_0060;
   } 
   if (Gi_0035 == Ii_0018) { 
   Gd_0036 = Id_0060;
   } 
   if (Gi_0035 == Ii_001C) { 
   Gd_0036 = LotSize;
   } 
   if (Gi_0035 == Ii_0020) { 
   Gd_0036 = Id_0040;
   } 
   if (Gi_0035 == Ii_0024) { 
   Gd_0036 = Id_0048;
   } 
   if (Gi_0035 == Ii_0028) { 
   Gd_0036 = Id_0050;
   } 
   if (Gi_0035 == Ii_002C) { 
   Gd_0036 = Id_0058;
   } 
   if (Gi_0035 == Ii_0030) { 
   Gd_0036 = Id_0060;
   } 
   if (Gi_0035 == Ii_0034) { 
   Gd_0036 = Id_0060;
   } 
   tmp_str001C = "NULL";
   sqOpenOrder(tmp_str001C, 0, Gd_0036, NormalizeDouble(Gd_0039, _Digits), tmp_str001B, Ii_0010, tmp_str001A);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Gi_003A = Ii_0010;
   Gd_003B = 0;
   Gi_00D3 = OrdersTotal() - 1;
   Gi_003C = Gi_00D3;
   if (Gi_00D3 >= 0) { 
   do { 
   if (OrderSelect(Gi_003C, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_003A == 0 || OrderMagicNumber() == Gi_003A) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str001D = OrderSymbol();
   if (tmp_str001D == "NULL") { 
   Gd_003D = Bid;
   } 
   else { 
   Gd_003D = MarketInfo(tmp_str001D, MODE_BID);
   } 
   Gd_003B = ((Gd_003D - OrderOpenPrice()) + Gd_003B);
   } 
   else { 
   Gd_00D3 = OrderOpenPrice();
   tmp_str001E = OrderSymbol();
   if (tmp_str001E == "NULL") { 
   Gd_003E = Ask;
   } 
   else { 
   Gd_003E = MarketInfo(tmp_str001E, MODE_ASK);
   } 
   Gd_003B = ((Gd_00D3 - Gd_003E) + Gd_003B);
   }}}}} 
   Gi_003C = Gi_003C - 1;
   } while (Gi_003C >= 0); 
   } 
   if (((Gd_003B * Id_0088) <= -200)) { 
   Gd_00D3 = ((LotSize + 0.0018) * Id_0070);
   Id_0060 = ((((Id_0070 * Id_0070) * Id_0070) * Id_0070) * Gd_00D3);
   tmp_str001F = "Go long 6";
   tmp_str0020 = "EAREVPREMIUM";
   Gi_0042 = Ii_0014;
   Gd_0043 = 0;
   if (Ii_0014 == Ii_0000) { 
   Gd_0043 = Ask;
   } 
   if (Gi_0042 == Ii_0004) { 
   Gd_0043 = Ask;
   } 
   if (Gi_0042 == Ii_0008) { 
   Gd_0043 = Ask;
   } 
   if (Gi_0042 == Ii_000C) { 
   Gd_0043 = Ask;
   } 
   if (Gi_0042 == Ii_0010) { 
   Gd_0043 = Ask;
   } 
   if (Gi_0042 == Ii_0014) { 
   Gd_0043 = Ask;
   } 
   if (Gi_0042 == Ii_0018) { 
   Gd_0043 = Ask;
   } 
   if (Gi_0042 == Ii_001C) { 
   Gd_0043 = Bid;
   } 
   if (Gi_0042 == Ii_0020) { 
   Gd_0043 = Bid;
   } 
   if (Gi_0042 == Ii_0024) { 
   Gd_0043 = Bid;
   } 
   if (Gi_0042 == Ii_0028) { 
   Gd_0043 = Bid;
   } 
   if (Gi_0042 == Ii_002C) { 
   Gd_0043 = Bid;
   } 
   if (Gi_0042 == Ii_0030) { 
   Gd_0043 = Bid;
   } 
   if (Gi_0042 == Ii_0034) { 
   Gd_0043 = Bid;
   } 
   Gi_003F = Ii_0014;
   Gd_0040 = 0;
   if (Ii_0014 == Ii_0000) { 
   Gd_0040 = LotSize;
   } 
   if (Gi_003F == Ii_0004) { 
   Gd_0040 = Id_0040;
   } 
   if (Gi_003F == Ii_0008) { 
   Gd_0040 = Id_0048;
   } 
   if (Gi_003F == Ii_000C) { 
   Gd_0040 = Id_0050;
   } 
   if (Gi_003F == Ii_0010) { 
   Gd_0040 = Id_0058;
   } 
   if (Gi_003F == Ii_0014) { 
   Gd_0040 = Id_0060;
   } 
   if (Gi_003F == Ii_0018) { 
   Gd_0040 = Id_0060;
   } 
   if (Gi_003F == Ii_001C) { 
   Gd_0040 = LotSize;
   } 
   if (Gi_003F == Ii_0020) { 
   Gd_0040 = Id_0040;
   } 
   if (Gi_003F == Ii_0024) { 
   Gd_0040 = Id_0048;
   } 
   if (Gi_003F == Ii_0028) { 
   Gd_0040 = Id_0050;
   } 
   if (Gi_003F == Ii_002C) { 
   Gd_0040 = Id_0058;
   } 
   if (Gi_003F == Ii_0030) { 
   Gd_0040 = Id_0060;
   } 
   if (Gi_003F == Ii_0034) { 
   Gd_0040 = Id_0060;
   } 
   tmp_str0021 = "NULL";
   sqOpenOrder(tmp_str0021, 0, Gd_0040, NormalizeDouble(Gd_0043, _Digits), tmp_str0020, Ii_0014, tmp_str001F);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Gi_0044 = Ii_0014;
   Gd_0045 = 0;
   Gi_00D3 = OrdersTotal() - 1;
   Gi_0046 = Gi_00D3;
   if (Gi_00D3 >= 0) { 
   do { 
   if (OrderSelect(Gi_0046, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0044 == 0 || OrderMagicNumber() == Gi_0044) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str0022 = OrderSymbol();
   if (tmp_str0022 == "NULL") { 
   Gd_0047 = Bid;
   } 
   else { 
   Gd_0047 = MarketInfo(tmp_str0022, MODE_BID);
   } 
   Gd_0045 = ((Gd_0047 - OrderOpenPrice()) + Gd_0045);
   } 
   else { 
   Gd_00D3 = OrderOpenPrice();
   tmp_str0023 = OrderSymbol();
   if (tmp_str0023 == "NULL") { 
   Gd_0048 = Ask;
   } 
   else { 
   Gd_0048 = MarketInfo(tmp_str0023, MODE_ASK);
   } 
   Gd_0045 = ((Gd_00D3 - Gd_0048) + Gd_0045);
   }}}}} 
   Gi_0046 = Gi_0046 - 1;
   } while (Gi_0046 >= 0); 
   } 
   if (((Gd_0045 * Id_0088) <= -200)) { 
   Gd_00D3 = ((LotSize + 0.0018) * Id_0070);
   Gd_00D8 = (Id_0070 * Id_0070);
   Id_0068 = (((Gd_00D8 * Id_0070) * Gd_00D8) * Gd_00D3);
   tmp_str0024 = "Go long 7";
   tmp_str0025 = "EAREVPREMIUM";
   Gi_004C = Ii_0018;
   Gd_004D = 0;
   if (Ii_0018 == Ii_0000) { 
   Gd_004D = Ask;
   } 
   if (Gi_004C == Ii_0004) { 
   Gd_004D = Ask;
   } 
   if (Gi_004C == Ii_0008) { 
   Gd_004D = Ask;
   } 
   if (Gi_004C == Ii_000C) { 
   Gd_004D = Ask;
   } 
   if (Gi_004C == Ii_0010) { 
   Gd_004D = Ask;
   } 
   if (Gi_004C == Ii_0014) { 
   Gd_004D = Ask;
   } 
   if (Gi_004C == Ii_0018) { 
   Gd_004D = Ask;
   } 
   if (Gi_004C == Ii_001C) { 
   Gd_004D = Bid;
   } 
   if (Gi_004C == Ii_0020) { 
   Gd_004D = Bid;
   } 
   if (Gi_004C == Ii_0024) { 
   Gd_004D = Bid;
   } 
   if (Gi_004C == Ii_0028) { 
   Gd_004D = Bid;
   } 
   if (Gi_004C == Ii_002C) { 
   Gd_004D = Bid;
   } 
   if (Gi_004C == Ii_0030) { 
   Gd_004D = Bid;
   } 
   if (Gi_004C == Ii_0034) { 
   Gd_004D = Bid;
   } 
   Gi_0049 = Ii_0018;
   Gd_004A = 0;
   if (Ii_0018 == Ii_0000) { 
   Gd_004A = LotSize;
   } 
   if (Gi_0049 == Ii_0004) { 
   Gd_004A = Id_0040;
   } 
   if (Gi_0049 == Ii_0008) { 
   Gd_004A = Id_0048;
   } 
   if (Gi_0049 == Ii_000C) { 
   Gd_004A = Id_0050;
   } 
   if (Gi_0049 == Ii_0010) { 
   Gd_004A = Id_0058;
   } 
   if (Gi_0049 == Ii_0014) { 
   Gd_004A = Id_0060;
   } 
   if (Gi_0049 == Ii_0018) { 
   Gd_004A = Id_0060;
   } 
   if (Gi_0049 == Ii_001C) { 
   Gd_004A = LotSize;
   } 
   if (Gi_0049 == Ii_0020) { 
   Gd_004A = Id_0040;
   } 
   if (Gi_0049 == Ii_0024) { 
   Gd_004A = Id_0048;
   } 
   if (Gi_0049 == Ii_0028) { 
   Gd_004A = Id_0050;
   } 
   if (Gi_0049 == Ii_002C) { 
   Gd_004A = Id_0058;
   } 
   if (Gi_0049 == Ii_0030) { 
   Gd_004A = Id_0060;
   } 
   if (Gi_0049 == Ii_0034) { 
   Gd_004A = Id_0060;
   } 
   tmp_str0026 = "NULL";
   sqOpenOrder(tmp_str0026, 0, Gd_004A, NormalizeDouble(Gd_004D, _Digits), tmp_str0025, Ii_0018, tmp_str0024);
   }} 
   Gd_00D8 = iMA(NULL, 240, 200, 0, 1, 0, 1);
   if ((Gd_00D8 > Close[1]) && PowerRisk == 0 && OrdersTotal() < MaxOrders) { 
   Gi_004F = Ii_001C;
   Gi_0050 = 0;
   Gb_004E = false;
   if (OrdersTotal() > 0) {
   do { 
   if (OrderSelect(Gi_0050, 0, 0) == true && OrderSymbol() == _Symbol) {
   if (Gi_004F == 0 || OrderMagicNumber() == Gi_004F) {
   
   Gl_00D8 = OrderOpenTime();
   if (Gl_00D8 > Time[1]) {
   Gb_004E = true;
   break;
   }}}
   Gi_0050 = Gi_0050 + 1;
   } while (Gi_0050 < OrdersTotal()); 
   }
   Gi_0050 = HistoryTotal();
   if (Gi_0050 >= 0) {
   do { 
   if (OrderSelect(Gi_0050, 0, 1) == true && OrderSymbol() == _Symbol) {
   if (Gi_004F == 0 || OrderMagicNumber() == Gi_004F) {
   
   Gl_00D8 = OrderOpenTime();
   if (Gl_00D8 > Time[1]) {
   Gb_004E = true;
   break;
   }}}
   Gi_0050 = Gi_0050 - 1;
   } while (Gi_0050 >= 0); 
   }
   else Gb_004E = false;
   
   if (Gb_004E == 0 && (MarketInfo(_Symbol, MODE_SWAPSHORT) >= SwapMinimo)) { 
   if ((iRSI(NULL, 240, 14, 0, 1) >= PotenzaSell) || (iStochastic(NULL, 240, 50, 3, 3, 0, 0, 0, 1) >= UltraSell)) { 
   
   tmp_str0027 = "Go short 1";
   tmp_str0028 = "EAREVPREMIUM";
   Gi_0054 = Ii_001C;
   Gd_0055 = 0;
   if (Ii_001C == Ii_0000) { 
   Gd_0055 = Ask;
   } 
   if (Gi_0054 == Ii_0004) { 
   Gd_0055 = Ask;
   } 
   if (Gi_0054 == Ii_0008) { 
   Gd_0055 = Ask;
   } 
   if (Gi_0054 == Ii_000C) { 
   Gd_0055 = Ask;
   } 
   if (Gi_0054 == Ii_0010) { 
   Gd_0055 = Ask;
   } 
   if (Gi_0054 == Ii_0014) { 
   Gd_0055 = Ask;
   } 
   if (Gi_0054 == Ii_0018) { 
   Gd_0055 = Ask;
   } 
   if (Gi_0054 == Ii_001C) { 
   Gd_0055 = Bid;
   } 
   if (Gi_0054 == Ii_0020) { 
   Gd_0055 = Bid;
   } 
   if (Gi_0054 == Ii_0024) { 
   Gd_0055 = Bid;
   } 
   if (Gi_0054 == Ii_0028) { 
   Gd_0055 = Bid;
   } 
   if (Gi_0054 == Ii_002C) { 
   Gd_0055 = Bid;
   } 
   if (Gi_0054 == Ii_0030) { 
   Gd_0055 = Bid;
   } 
   if (Gi_0054 == Ii_0034) { 
   Gd_0055 = Bid;
   } 
   Gi_0051 = Ii_001C;
   Gd_0052 = 0;
   if (Ii_001C == Ii_0000) { 
   Gd_0052 = LotSize;
   } 
   if (Gi_0051 == Ii_0004) { 
   Gd_0052 = Id_0040;
   } 
   if (Gi_0051 == Ii_0008) { 
   Gd_0052 = Id_0048;
   } 
   if (Gi_0051 == Ii_000C) { 
   Gd_0052 = Id_0050;
   } 
   if (Gi_0051 == Ii_0010) { 
   Gd_0052 = Id_0058;
   } 
   if (Gi_0051 == Ii_0014) { 
   Gd_0052 = Id_0060;
   } 
   if (Gi_0051 == Ii_0018) { 
   Gd_0052 = Id_0060;
   } 
   if (Gi_0051 == Ii_001C) { 
   Gd_0052 = LotSize;
   } 
   if (Gi_0051 == Ii_0020) { 
   Gd_0052 = Id_0040;
   } 
   if (Gi_0051 == Ii_0024) { 
   Gd_0052 = Id_0048;
   } 
   if (Gi_0051 == Ii_0028) { 
   Gd_0052 = Id_0050;
   } 
   if (Gi_0051 == Ii_002C) { 
   Gd_0052 = Id_0058;
   } 
   if (Gi_0051 == Ii_0030) { 
   Gd_0052 = Id_0060;
   } 
   if (Gi_0051 == Ii_0034) { 
   Gd_0052 = Id_0060;
   } 
   tmp_str0029 = "NULL";
   sqOpenOrder(tmp_str0029, 1, Gd_0052, NormalizeDouble(Gd_0055, _Digits), tmp_str0028, Ii_001C, tmp_str0027);
   }}} 
   Gd_00D8 = iMA(NULL, 240, 200, 0, 1, 0, 1);
   if ((Gd_00D8 > Close[1]) && PowerRisk == true && OrdersTotal() < MaxOrders && (MarketInfo(_Symbol, MODE_SWAPSHORT) >= SwapMinimo)) { 
   if ((iRSI(NULL, 240, 14, 0, 1) >= PotenzaSell) || (iStochastic(NULL, 240, 50, 3, 3, 0, 0, 0, 1) >= UltraSell)) { 
   
   tmp_str002A = "Go short 1";
   tmp_str002B = "EAREVPREMIUM";
   Gi_0059 = Ii_001C;
   Gd_005A = 0;
   if (Ii_001C == Ii_0000) { 
   Gd_005A = Ask;
   } 
   if (Gi_0059 == Ii_0004) { 
   Gd_005A = Ask;
   } 
   if (Gi_0059 == Ii_0008) { 
   Gd_005A = Ask;
   } 
   if (Gi_0059 == Ii_000C) { 
   Gd_005A = Ask;
   } 
   if (Gi_0059 == Ii_0010) { 
   Gd_005A = Ask;
   } 
   if (Gi_0059 == Ii_0014) { 
   Gd_005A = Ask;
   } 
   if (Gi_0059 == Ii_0018) { 
   Gd_005A = Ask;
   } 
   if (Gi_0059 == Ii_001C) { 
   Gd_005A = Bid;
   } 
   if (Gi_0059 == Ii_0020) { 
   Gd_005A = Bid;
   } 
   if (Gi_0059 == Ii_0024) { 
   Gd_005A = Bid;
   } 
   if (Gi_0059 == Ii_0028) { 
   Gd_005A = Bid;
   } 
   if (Gi_0059 == Ii_002C) { 
   Gd_005A = Bid;
   } 
   if (Gi_0059 == Ii_0030) { 
   Gd_005A = Bid;
   } 
   if (Gi_0059 == Ii_0034) { 
   Gd_005A = Bid;
   } 
   Gi_0056 = Ii_001C;
   Gd_0057 = 0;
   if (Ii_001C == Ii_0000) { 
   Gd_0057 = LotSize;
   } 
   if (Gi_0056 == Ii_0004) { 
   Gd_0057 = Id_0040;
   } 
   if (Gi_0056 == Ii_0008) { 
   Gd_0057 = Id_0048;
   } 
   if (Gi_0056 == Ii_000C) { 
   Gd_0057 = Id_0050;
   } 
   if (Gi_0056 == Ii_0010) { 
   Gd_0057 = Id_0058;
   } 
   if (Gi_0056 == Ii_0014) { 
   Gd_0057 = Id_0060;
   } 
   if (Gi_0056 == Ii_0018) { 
   Gd_0057 = Id_0060;
   } 
   if (Gi_0056 == Ii_001C) { 
   Gd_0057 = LotSize;
   } 
   if (Gi_0056 == Ii_0020) { 
   Gd_0057 = Id_0040;
   } 
   if (Gi_0056 == Ii_0024) { 
   Gd_0057 = Id_0048;
   } 
   if (Gi_0056 == Ii_0028) { 
   Gd_0057 = Id_0050;
   } 
   if (Gi_0056 == Ii_002C) { 
   Gd_0057 = Id_0058;
   } 
   if (Gi_0056 == Ii_0030) { 
   Gd_0057 = Id_0060;
   } 
   if (Gi_0056 == Ii_0034) { 
   Gd_0057 = Id_0060;
   } 
   tmp_str002C = "NULL";
   sqOpenOrder(tmp_str002C, 1, Gd_0057, NormalizeDouble(Gd_005A, _Digits), tmp_str002B, Ii_001C, tmp_str002A);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Gi_005B = Ii_001C;
   Gd_005C = 0;
   Gi_00D8 = OrdersTotal() - 1;
   Gi_005D = Gi_00D8;
   if (Gi_00D8 >= 0) { 
   do { 
   if (OrderSelect(Gi_005D, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_005B == 0 || OrderMagicNumber() == Gi_005B) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str002D = OrderSymbol();
   if (tmp_str002D == "NULL") { 
   Gd_005E = Bid;
   } 
   else { 
   Gd_005E = MarketInfo(tmp_str002D, MODE_BID);
   } 
   Gd_005C = ((Gd_005E - OrderOpenPrice()) + Gd_005C);
   } 
   else { 
   Gd_00D8 = OrderOpenPrice();
   tmp_str002E = OrderSymbol();
   if (tmp_str002E == "NULL") { 
   Gd_005F = Ask;
   } 
   else { 
   Gd_005F = MarketInfo(tmp_str002E, MODE_ASK);
   } 
   Gd_005C = ((Gd_00D8 - Gd_005F) + Gd_005C);
   }}}}} 
   Gi_005D = Gi_005D - 1;
   } while (Gi_005D >= 0); 
   } 
   if (((Gd_005C * Id_0088) <= -70)) { 
   Id_0040 = ((LotSize + 0.0018) * Id_0070);
   tmp_str002F = "Go short 2";
   tmp_str0030 = "EAREVPREMIUM";
   Gi_0063 = Ii_0020;
   Gd_0064 = 0;
   if (Ii_0020 == Ii_0000) { 
   Gd_0064 = Ask;
   } 
   if (Gi_0063 == Ii_0004) { 
   Gd_0064 = Ask;
   } 
   if (Gi_0063 == Ii_0008) { 
   Gd_0064 = Ask;
   } 
   if (Gi_0063 == Ii_000C) { 
   Gd_0064 = Ask;
   } 
   if (Gi_0063 == Ii_0010) { 
   Gd_0064 = Ask;
   } 
   if (Gi_0063 == Ii_0014) { 
   Gd_0064 = Ask;
   } 
   if (Gi_0063 == Ii_0018) { 
   Gd_0064 = Ask;
   } 
   if (Gi_0063 == Ii_001C) { 
   Gd_0064 = Bid;
   } 
   if (Gi_0063 == Ii_0020) { 
   Gd_0064 = Bid;
   } 
   if (Gi_0063 == Ii_0024) { 
   Gd_0064 = Bid;
   } 
   if (Gi_0063 == Ii_0028) { 
   Gd_0064 = Bid;
   } 
   if (Gi_0063 == Ii_002C) { 
   Gd_0064 = Bid;
   } 
   if (Gi_0063 == Ii_0030) { 
   Gd_0064 = Bid;
   } 
   if (Gi_0063 == Ii_0034) { 
   Gd_0064 = Bid;
   } 
   Gi_0060 = Ii_0020;
   Gd_0061 = 0;
   if (Ii_0020 == Ii_0000) { 
   Gd_0061 = LotSize;
   } 
   if (Gi_0060 == Ii_0004) { 
   Gd_0061 = Id_0040;
   } 
   if (Gi_0060 == Ii_0008) { 
   Gd_0061 = Id_0048;
   } 
   if (Gi_0060 == Ii_000C) { 
   Gd_0061 = Id_0050;
   } 
   if (Gi_0060 == Ii_0010) { 
   Gd_0061 = Id_0058;
   } 
   if (Gi_0060 == Ii_0014) { 
   Gd_0061 = Id_0060;
   } 
   if (Gi_0060 == Ii_0018) { 
   Gd_0061 = Id_0060;
   } 
   if (Gi_0060 == Ii_001C) { 
   Gd_0061 = LotSize;
   } 
   if (Gi_0060 == Ii_0020) { 
   Gd_0061 = Id_0040;
   } 
   if (Gi_0060 == Ii_0024) { 
   Gd_0061 = Id_0048;
   } 
   if (Gi_0060 == Ii_0028) { 
   Gd_0061 = Id_0050;
   } 
   if (Gi_0060 == Ii_002C) { 
   Gd_0061 = Id_0058;
   } 
   if (Gi_0060 == Ii_0030) { 
   Gd_0061 = Id_0060;
   } 
   if (Gi_0060 == Ii_0034) { 
   Gd_0061 = Id_0060;
   } 
   tmp_str0031 = "NULL";
   sqOpenOrder(tmp_str0031, 1, Gd_0061, NormalizeDouble(Gd_0064, _Digits), tmp_str0030, Ii_0020, tmp_str002F);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Gi_0065 = Ii_0020;
   Gd_0066 = 0;
   Gi_00D8 = OrdersTotal() - 1;
   Gi_0067 = Gi_00D8;
   if (Gi_00D8 >= 0) { 
   do { 
   if (OrderSelect(Gi_0067, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0065 == 0 || OrderMagicNumber() == Gi_0065) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str0032 = OrderSymbol();
   if (tmp_str0032 == "NULL") { 
   Gd_0068 = Bid;
   } 
   else { 
   Gd_0068 = MarketInfo(tmp_str0032, MODE_BID);
   } 
   Gd_0066 = ((Gd_0068 - OrderOpenPrice()) + Gd_0066);
   } 
   else { 
   Gd_00D8 = OrderOpenPrice();
   tmp_str0033 = OrderSymbol();
   if (tmp_str0033 == "NULL") { 
   Gd_0069 = Ask;
   } 
   else { 
   Gd_0069 = MarketInfo(tmp_str0033, MODE_ASK);
   } 
   Gd_0066 = ((Gd_00D8 - Gd_0069) + Gd_0066);
   }}}}} 
   Gi_0067 = Gi_0067 - 1;
   } while (Gi_0067 >= 0); 
   } 
   if (((Gd_0066 * Id_0088) <= -120)) { 
   Gd_00D8 = (LotSize + 0.0018);
   Id_0048 = ((Id_0070 * Id_0070) * Gd_00D8);
   tmp_str0034 = "Go short 3";
   tmp_str0035 = "EAREVPREMIUM";
   Gi_006D = Ii_0024;
   Gd_006E = 0;
   if (Ii_0024 == Ii_0000) { 
   Gd_006E = Ask;
   } 
   if (Gi_006D == Ii_0004) { 
   Gd_006E = Ask;
   } 
   if (Gi_006D == Ii_0008) { 
   Gd_006E = Ask;
   } 
   if (Gi_006D == Ii_000C) { 
   Gd_006E = Ask;
   } 
   if (Gi_006D == Ii_0010) { 
   Gd_006E = Ask;
   } 
   if (Gi_006D == Ii_0014) { 
   Gd_006E = Ask;
   } 
   if (Gi_006D == Ii_0018) { 
   Gd_006E = Ask;
   } 
   if (Gi_006D == Ii_001C) { 
   Gd_006E = Bid;
   } 
   if (Gi_006D == Ii_0020) { 
   Gd_006E = Bid;
   } 
   if (Gi_006D == Ii_0024) { 
   Gd_006E = Bid;
   } 
   if (Gi_006D == Ii_0028) { 
   Gd_006E = Bid;
   } 
   if (Gi_006D == Ii_002C) { 
   Gd_006E = Bid;
   } 
   if (Gi_006D == Ii_0030) { 
   Gd_006E = Bid;
   } 
   if (Gi_006D == Ii_0034) { 
   Gd_006E = Bid;
   } 
   Gi_006A = Ii_0024;
   Gd_006B = 0;
   if (Ii_0024 == Ii_0000) { 
   Gd_006B = LotSize;
   } 
   if (Gi_006A == Ii_0004) { 
   Gd_006B = Id_0040;
   } 
   if (Gi_006A == Ii_0008) { 
   Gd_006B = Id_0048;
   } 
   if (Gi_006A == Ii_000C) { 
   Gd_006B = Id_0050;
   } 
   if (Gi_006A == Ii_0010) { 
   Gd_006B = Id_0058;
   } 
   if (Gi_006A == Ii_0014) { 
   Gd_006B = Id_0060;
   } 
   if (Gi_006A == Ii_0018) { 
   Gd_006B = Id_0060;
   } 
   if (Gi_006A == Ii_001C) { 
   Gd_006B = LotSize;
   } 
   if (Gi_006A == Ii_0020) { 
   Gd_006B = Id_0040;
   } 
   if (Gi_006A == Ii_0024) { 
   Gd_006B = Id_0048;
   } 
   if (Gi_006A == Ii_0028) { 
   Gd_006B = Id_0050;
   } 
   if (Gi_006A == Ii_002C) { 
   Gd_006B = Id_0058;
   } 
   if (Gi_006A == Ii_0030) { 
   Gd_006B = Id_0060;
   } 
   if (Gi_006A == Ii_0034) { 
   Gd_006B = Id_0060;
   } 
   tmp_str0036 = "NULL";
   sqOpenOrder(tmp_str0036, 1, Gd_006B, NormalizeDouble(Gd_006E, _Digits), tmp_str0035, Ii_0024, tmp_str0034);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Gi_006F = Ii_0024;
   Gd_0070 = 0;
   Gi_00D8 = OrdersTotal() - 1;
   Gi_0071 = Gi_00D8;
   if (Gi_00D8 >= 0) { 
   do { 
   if (OrderSelect(Gi_0071, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_006F == 0 || OrderMagicNumber() == Gi_006F) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str0037 = OrderSymbol();
   if (tmp_str0037 == "NULL") { 
   Gd_0072 = Bid;
   } 
   else { 
   Gd_0072 = MarketInfo(tmp_str0037, MODE_BID);
   } 
   Gd_0070 = ((Gd_0072 - OrderOpenPrice()) + Gd_0070);
   } 
   else { 
   Gd_00D8 = OrderOpenPrice();
   tmp_str0038 = OrderSymbol();
   if (tmp_str0038 == "NULL") { 
   Gd_0073 = Ask;
   } 
   else { 
   Gd_0073 = MarketInfo(tmp_str0038, MODE_ASK);
   } 
   Gd_0070 = ((Gd_00D8 - Gd_0073) + Gd_0070);
   }}}}} 
   Gi_0071 = Gi_0071 - 1;
   } while (Gi_0071 >= 0); 
   } 
   if (((Gd_0070 * Id_0088) <= -150)) { 
   Gd_00D8 = (LotSize + 0.0018);
   Id_0050 = (((Id_0070 * Id_0070) * Id_0070) * Gd_00D8);
   tmp_str0039 = "go short 4";
   tmp_str003A = "EAREVPREMIUM";
   Gi_0077 = Ii_0028;
   Gd_0078 = 0;
   if (Ii_0028 == Ii_0000) { 
   Gd_0078 = Ask;
   } 
   if (Gi_0077 == Ii_0004) { 
   Gd_0078 = Ask;
   } 
   if (Gi_0077 == Ii_0008) { 
   Gd_0078 = Ask;
   } 
   if (Gi_0077 == Ii_000C) { 
   Gd_0078 = Ask;
   } 
   if (Gi_0077 == Ii_0010) { 
   Gd_0078 = Ask;
   } 
   if (Gi_0077 == Ii_0014) { 
   Gd_0078 = Ask;
   } 
   if (Gi_0077 == Ii_0018) { 
   Gd_0078 = Ask;
   } 
   if (Gi_0077 == Ii_001C) { 
   Gd_0078 = Bid;
   } 
   if (Gi_0077 == Ii_0020) { 
   Gd_0078 = Bid;
   } 
   if (Gi_0077 == Ii_0024) { 
   Gd_0078 = Bid;
   } 
   if (Gi_0077 == Ii_0028) { 
   Gd_0078 = Bid;
   } 
   if (Gi_0077 == Ii_002C) { 
   Gd_0078 = Bid;
   } 
   if (Gi_0077 == Ii_0030) { 
   Gd_0078 = Bid;
   } 
   if (Gi_0077 == Ii_0034) { 
   Gd_0078 = Bid;
   } 
   Gi_0074 = Ii_0028;
   Gd_0075 = 0;
   if (Ii_0028 == Ii_0000) { 
   Gd_0075 = LotSize;
   } 
   if (Gi_0074 == Ii_0004) { 
   Gd_0075 = Id_0040;
   } 
   if (Gi_0074 == Ii_0008) { 
   Gd_0075 = Id_0048;
   } 
   if (Gi_0074 == Ii_000C) { 
   Gd_0075 = Id_0050;
   } 
   if (Gi_0074 == Ii_0010) { 
   Gd_0075 = Id_0058;
   } 
   if (Gi_0074 == Ii_0014) { 
   Gd_0075 = Id_0060;
   } 
   if (Gi_0074 == Ii_0018) { 
   Gd_0075 = Id_0060;
   } 
   if (Gi_0074 == Ii_001C) { 
   Gd_0075 = LotSize;
   } 
   if (Gi_0074 == Ii_0020) { 
   Gd_0075 = Id_0040;
   } 
   if (Gi_0074 == Ii_0024) { 
   Gd_0075 = Id_0048;
   } 
   if (Gi_0074 == Ii_0028) { 
   Gd_0075 = Id_0050;
   } 
   if (Gi_0074 == Ii_002C) { 
   Gd_0075 = Id_0058;
   } 
   if (Gi_0074 == Ii_0030) { 
   Gd_0075 = Id_0060;
   } 
   if (Gi_0074 == Ii_0034) { 
   Gd_0075 = Id_0060;
   } 
   tmp_str003B = "NULL";
   sqOpenOrder(tmp_str003B, 1, Gd_0075, NormalizeDouble(Gd_0078, _Digits), tmp_str003A, Ii_0028, tmp_str0039);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Gi_0079 = Ii_0028;
   Gd_007A = 0;
   Gi_00D8 = OrdersTotal() - 1;
   Gi_007B = Gi_00D8;
   if (Gi_00D8 >= 0) { 
   do { 
   if (OrderSelect(Gi_007B, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0079 == 0 || OrderMagicNumber() == Gi_0079) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str003C = OrderSymbol();
   if (tmp_str003C == "NULL") { 
   Gd_007C = Bid;
   } 
   else { 
   Gd_007C = MarketInfo(tmp_str003C, MODE_BID);
   } 
   Gd_007A = ((Gd_007C - OrderOpenPrice()) + Gd_007A);
   } 
   else { 
   Gd_00D8 = OrderOpenPrice();
   tmp_str003D = OrderSymbol();
   if (tmp_str003D == "NULL") { 
   Gd_007D = Ask;
   } 
   else { 
   Gd_007D = MarketInfo(tmp_str003D, MODE_ASK);
   } 
   Gd_007A = ((Gd_00D8 - Gd_007D) + Gd_007A);
   }}}}} 
   Gi_007B = Gi_007B - 1;
   } while (Gi_007B >= 0); 
   } 
   if (((Gd_007A * Id_0088) <= -200)) { 
   Gd_00D8 = (LotSize + 0.0018);
   Id_0058 = (((Id_0070 * Id_0070) * (Id_0070 * Id_0070)) * Gd_00D8);
   tmp_str003E = "go short 5";
   tmp_str003F = "EAREVPREMIUM";
   Gi_0081 = Ii_002C;
   Gd_0082 = 0;
   if (Ii_002C == Ii_0000) { 
   Gd_0082 = Ask;
   } 
   if (Gi_0081 == Ii_0004) { 
   Gd_0082 = Ask;
   } 
   if (Gi_0081 == Ii_0008) { 
   Gd_0082 = Ask;
   } 
   if (Gi_0081 == Ii_000C) { 
   Gd_0082 = Ask;
   } 
   if (Gi_0081 == Ii_0010) { 
   Gd_0082 = Ask;
   } 
   if (Gi_0081 == Ii_0014) { 
   Gd_0082 = Ask;
   } 
   if (Gi_0081 == Ii_0018) { 
   Gd_0082 = Ask;
   } 
   if (Gi_0081 == Ii_001C) { 
   Gd_0082 = Bid;
   } 
   if (Gi_0081 == Ii_0020) { 
   Gd_0082 = Bid;
   } 
   if (Gi_0081 == Ii_0024) { 
   Gd_0082 = Bid;
   } 
   if (Gi_0081 == Ii_0028) { 
   Gd_0082 = Bid;
   } 
   if (Gi_0081 == Ii_002C) { 
   Gd_0082 = Bid;
   } 
   if (Gi_0081 == Ii_0030) { 
   Gd_0082 = Bid;
   } 
   if (Gi_0081 == Ii_0034) { 
   Gd_0082 = Bid;
   } 
   Gi_007E = Ii_002C;
   Gd_007F = 0;
   if (Ii_002C == Ii_0000) { 
   Gd_007F = LotSize;
   } 
   if (Gi_007E == Ii_0004) { 
   Gd_007F = Id_0040;
   } 
   if (Gi_007E == Ii_0008) { 
   Gd_007F = Id_0048;
   } 
   if (Gi_007E == Ii_000C) { 
   Gd_007F = Id_0050;
   } 
   if (Gi_007E == Ii_0010) { 
   Gd_007F = Id_0058;
   } 
   if (Gi_007E == Ii_0014) { 
   Gd_007F = Id_0060;
   } 
   if (Gi_007E == Ii_0018) { 
   Gd_007F = Id_0060;
   } 
   if (Gi_007E == Ii_001C) { 
   Gd_007F = LotSize;
   } 
   if (Gi_007E == Ii_0020) { 
   Gd_007F = Id_0040;
   } 
   if (Gi_007E == Ii_0024) { 
   Gd_007F = Id_0048;
   } 
   if (Gi_007E == Ii_0028) { 
   Gd_007F = Id_0050;
   } 
   if (Gi_007E == Ii_002C) { 
   Gd_007F = Id_0058;
   } 
   if (Gi_007E == Ii_0030) { 
   Gd_007F = Id_0060;
   } 
   if (Gi_007E == Ii_0034) { 
   Gd_007F = Id_0060;
   } 
   tmp_str0040 = "NULL";
   sqOpenOrder(tmp_str0040, 1, Gd_007F, NormalizeDouble(Gd_0082, _Digits), tmp_str003F, Ii_002C, tmp_str003E);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Gi_0083 = Ii_002C;
   Gd_0084 = 0;
   Gi_00D8 = OrdersTotal() - 1;
   Gi_0085 = Gi_00D8;
   if (Gi_00D8 >= 0) { 
   do { 
   if (OrderSelect(Gi_0085, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0083 == 0 || OrderMagicNumber() == Gi_0083) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str0041 = OrderSymbol();
   if (tmp_str0041 == "NULL") { 
   Gd_0086 = Bid;
   } 
   else { 
   Gd_0086 = MarketInfo(tmp_str0041, MODE_BID);
   } 
   Gd_0084 = ((Gd_0086 - OrderOpenPrice()) + Gd_0084);
   } 
   else { 
   Gd_00D8 = OrderOpenPrice();
   tmp_str0042 = OrderSymbol();
   if (tmp_str0042 == "NULL") { 
   Gd_0087 = Ask;
   } 
   else { 
   Gd_0087 = MarketInfo(tmp_str0042, MODE_ASK);
   } 
   Gd_0084 = ((Gd_00D8 - Gd_0087) + Gd_0084);
   }}}}} 
   Gi_0085 = Gi_0085 - 1;
   } while (Gi_0085 >= 0); 
   } 
   if (((Gd_0084 * Id_0088) <= -200)) { 
   Gd_00D8 = (LotSize + 0.0018);
   Gd_00DD = (Id_0070 * Id_0070);
   Id_0060 = (((Gd_00DD * Id_0070) * Gd_00DD) * Gd_00D8);
   tmp_str0043 = "go short 6";
   tmp_str0044 = "EAREVPREMIUM";
   Gi_008B = Ii_0030;
   Gd_008C = 0;
   if (Ii_0030 == Ii_0000) { 
   Gd_008C = Ask;
   } 
   if (Gi_008B == Ii_0004) { 
   Gd_008C = Ask;
   } 
   if (Gi_008B == Ii_0008) { 
   Gd_008C = Ask;
   } 
   if (Gi_008B == Ii_000C) { 
   Gd_008C = Ask;
   } 
   if (Gi_008B == Ii_0010) { 
   Gd_008C = Ask;
   } 
   if (Gi_008B == Ii_0014) { 
   Gd_008C = Ask;
   } 
   if (Gi_008B == Ii_0018) { 
   Gd_008C = Ask;
   } 
   if (Gi_008B == Ii_001C) { 
   Gd_008C = Bid;
   } 
   if (Gi_008B == Ii_0020) { 
   Gd_008C = Bid;
   } 
   if (Gi_008B == Ii_0024) { 
   Gd_008C = Bid;
   } 
   if (Gi_008B == Ii_0028) { 
   Gd_008C = Bid;
   } 
   if (Gi_008B == Ii_002C) { 
   Gd_008C = Bid;
   } 
   if (Gi_008B == Ii_0030) { 
   Gd_008C = Bid;
   } 
   if (Gi_008B == Ii_0034) { 
   Gd_008C = Bid;
   } 
   Gi_0088 = Ii_0030;
   Gd_0089 = 0;
   if (Ii_0030 == Ii_0000) { 
   Gd_0089 = LotSize;
   } 
   if (Gi_0088 == Ii_0004) { 
   Gd_0089 = Id_0040;
   } 
   if (Gi_0088 == Ii_0008) { 
   Gd_0089 = Id_0048;
   } 
   if (Gi_0088 == Ii_000C) { 
   Gd_0089 = Id_0050;
   } 
   if (Gi_0088 == Ii_0010) { 
   Gd_0089 = Id_0058;
   } 
   if (Gi_0088 == Ii_0014) { 
   Gd_0089 = Id_0060;
   } 
   if (Gi_0088 == Ii_0018) { 
   Gd_0089 = Id_0060;
   } 
   if (Gi_0088 == Ii_001C) { 
   Gd_0089 = LotSize;
   } 
   if (Gi_0088 == Ii_0020) { 
   Gd_0089 = Id_0040;
   } 
   if (Gi_0088 == Ii_0024) { 
   Gd_0089 = Id_0048;
   } 
   if (Gi_0088 == Ii_0028) { 
   Gd_0089 = Id_0050;
   } 
   if (Gi_0088 == Ii_002C) { 
   Gd_0089 = Id_0058;
   } 
   if (Gi_0088 == Ii_0030) { 
   Gd_0089 = Id_0060;
   } 
   if (Gi_0088 == Ii_0034) { 
   Gd_0089 = Id_0060;
   } 
   tmp_str0045 = "NULL";
   sqOpenOrder(tmp_str0045, 1, Gd_0089, NormalizeDouble(Gd_008C, _Digits), tmp_str0044, Ii_0030, tmp_str0043);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Gi_008D = Ii_0030;
   Gd_008E = 0;
   Gi_00DD = OrdersTotal() - 1;
   Gi_008F = Gi_00DD;
   if (Gi_00DD >= 0) { 
   do { 
   if (OrderSelect(Gi_008F, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_008D == 0 || OrderMagicNumber() == Gi_008D) {
   
   if (OrderType() == OP_BUY) { 
   tmp_str0046 = OrderSymbol();
   if (tmp_str0046 == "NULL") { 
   Gd_0090 = Bid;
   } 
   else { 
   Gd_0090 = MarketInfo(tmp_str0046, MODE_BID);
   } 
   Gd_008E = ((Gd_0090 - OrderOpenPrice()) + Gd_008E);
   } 
   else { 
   Gd_00DD = OrderOpenPrice();
   tmp_str0047 = OrderSymbol();
   if (tmp_str0047 == "NULL") { 
   Gd_0091 = Ask;
   } 
   else { 
   Gd_0091 = MarketInfo(tmp_str0047, MODE_ASK);
   } 
   Gd_008E = ((Gd_00DD - Gd_0091) + Gd_008E);
   }}}}} 
   Gi_008F = Gi_008F - 1;
   } while (Gi_008F >= 0); 
   } 
   if (((Gd_008E * Id_0088) <= -200)) { 
   Gd_00DD = (LotSize + 0.0018);
   Gd_00DE = (Id_0070 * Id_0070);
   Id_0068 = (((Gd_00DE * Gd_00DE) * Gd_00DE) * Gd_00DD);
   tmp_str0048 = "go short 7";
   tmp_str0049 = "EAREVPREMIUM";
   Gi_0095 = Ii_0034;
   Gd_0096 = 0;
   if (Ii_0034 == Ii_0000) { 
   Gd_0096 = Ask;
   } 
   if (Gi_0095 == Ii_0004) { 
   Gd_0096 = Ask;
   } 
   if (Gi_0095 == Ii_0008) { 
   Gd_0096 = Ask;
   } 
   if (Gi_0095 == Ii_000C) { 
   Gd_0096 = Ask;
   } 
   if (Gi_0095 == Ii_0010) { 
   Gd_0096 = Ask;
   } 
   if (Gi_0095 == Ii_0014) { 
   Gd_0096 = Ask;
   } 
   if (Gi_0095 == Ii_0018) { 
   Gd_0096 = Ask;
   } 
   if (Gi_0095 == Ii_001C) { 
   Gd_0096 = Bid;
   } 
   if (Gi_0095 == Ii_0020) { 
   Gd_0096 = Bid;
   } 
   if (Gi_0095 == Ii_0024) { 
   Gd_0096 = Bid;
   } 
   if (Gi_0095 == Ii_0028) { 
   Gd_0096 = Bid;
   } 
   if (Gi_0095 == Ii_002C) { 
   Gd_0096 = Bid;
   } 
   if (Gi_0095 == Ii_0030) { 
   Gd_0096 = Bid;
   } 
   if (Gi_0095 == Ii_0034) { 
   Gd_0096 = Bid;
   } 
   Gi_0092 = Ii_0034;
   Gd_0093 = 0;
   if (Ii_0034 == Ii_0000) { 
   Gd_0093 = LotSize;
   } 
   if (Gi_0092 == Ii_0004) { 
   Gd_0093 = Id_0040;
   } 
   if (Gi_0092 == Ii_0008) { 
   Gd_0093 = Id_0048;
   } 
   if (Gi_0092 == Ii_000C) { 
   Gd_0093 = Id_0050;
   } 
   if (Gi_0092 == Ii_0010) { 
   Gd_0093 = Id_0058;
   } 
   if (Gi_0092 == Ii_0014) { 
   Gd_0093 = Id_0060;
   } 
   if (Gi_0092 == Ii_0018) { 
   Gd_0093 = Id_0060;
   } 
   if (Gi_0092 == Ii_001C) { 
   Gd_0093 = LotSize;
   } 
   if (Gi_0092 == Ii_0020) { 
   Gd_0093 = Id_0040;
   } 
   if (Gi_0092 == Ii_0024) { 
   Gd_0093 = Id_0048;
   } 
   if (Gi_0092 == Ii_0028) { 
   Gd_0093 = Id_0050;
   } 
   if (Gi_0092 == Ii_002C) { 
   Gd_0093 = Id_0058;
   } 
   if (Gi_0092 == Ii_0030) { 
   Gd_0093 = Id_0060;
   } 
   if (Gi_0092 == Ii_0034) { 
   Gd_0093 = Id_0060;
   } 
   tmp_str004A = "NULL";
   sqOpenOrder(tmp_str004A, 1, Gd_0093, NormalizeDouble(Gd_0096, _Digits), tmp_str0049, Ii_0034, tmp_str0048);
   }} 
   Gd_00DE = AccountBalance();
   Gd_00DE = (Gd_00DE - AccountEquity());
   Gd_00DF = (AccountBalance() * StopLossBalance);
   if ((Gd_00DE >= (Gd_00DF / 100))) { 
   sqCloseOrder(Ii_0000);
   sqCloseOrder(Ii_0004);
   sqCloseOrder(Ii_0008);
   sqCloseOrder(Ii_000C);
   sqCloseOrder(Ii_0010);
   sqCloseOrder(Ii_0014);
   sqCloseOrder(Ii_0018);
   sqCloseOrder(Ii_001C);
   sqCloseOrder(Ii_0020);
   sqCloseOrder(Ii_0024);
   sqCloseOrder(Ii_0028);
   sqCloseOrder(Ii_002C);
   sqCloseOrder(Ii_0030);
   sqCloseOrder(Ii_0034);
   } 
   Gi_0098 = Ii_0000;
   Gd_0099 = 0;
   Gi_00DF = OrdersTotal() - 1;
   Gi_009A = Gi_00DF;
   if (Gi_00DF >= 0) { 
   do { 
   if (OrderSelect(Gi_009A, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_0098 == 0 || OrderMagicNumber() == Gi_0098) { 
   
   Gd_0099 = (Gd_0099 + OrderProfit());
   }}}} 
   Gi_009A = Gi_009A - 1;
   } while (Gi_009A >= 0); 
   } 
   Gd_0097 = Gd_0099;
   Gi_009B = Ii_0004;
   Gd_009C = 0;
   Gi_00DF = OrdersTotal() - 1;
   Gi_009D = Gi_00DF;
   if (Gi_00DF >= 0) { 
   do { 
   if (OrderSelect(Gi_009D, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_009B == 0 || OrderMagicNumber() == Gi_009B) { 
   
   Gd_009C = (Gd_009C + OrderProfit());
   }}}} 
   Gi_009D = Gi_009D - 1;
   } while (Gi_009D >= 0); 
   } 
   Gd_00DF = (Gd_0097 + Gd_009C);
   Gi_009F = Ii_0008;
   Gd_00A0 = 0;
   Gi_00E0 = OrdersTotal() - 1;
   Gi_00A1 = Gi_00E0;
   if (Gi_00E0 >= 0) { 
   do { 
   if (OrderSelect(Gi_00A1, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_009F == 0 || OrderMagicNumber() == Gi_009F) { 
   
   Gd_00A0 = (Gd_00A0 + OrderProfit());
   }}}} 
   Gi_00A1 = Gi_00A1 - 1;
   } while (Gi_00A1 >= 0); 
   } 
   Gd_009E = Gd_00A0;
   Gi_00A2 = Ii_000C;
   Gd_00A3 = 0;
   Gi_00E0 = OrdersTotal() - 1;
   Gi_00A4 = Gi_00E0;
   if (Gi_00E0 >= 0) { 
   do { 
   if (OrderSelect(Gi_00A4, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00A2 == 0 || OrderMagicNumber() == Gi_00A2) { 
   
   Gd_00A3 = (Gd_00A3 + OrderProfit());
   }}}} 
   Gi_00A4 = Gi_00A4 - 1;
   } while (Gi_00A4 >= 0); 
   } 
   Gd_00E0 = ((Gd_009E + Gd_00A3) + Gd_00DF);
   Gi_00A6 = Ii_0010;
   Gd_00A7 = 0;
   Gi_00E1 = OrdersTotal() - 1;
   Gi_00A8 = Gi_00E1;
   if (Gi_00E1 >= 0) { 
   do { 
   if (OrderSelect(Gi_00A8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00A6 == 0 || OrderMagicNumber() == Gi_00A6) { 
   
   Gd_00A7 = (Gd_00A7 + OrderProfit());
   }}}} 
   Gi_00A8 = Gi_00A8 - 1;
   } while (Gi_00A8 >= 0); 
   } 
   Gd_00A5 = Gd_00A7;
   Gi_00AA = Ii_0014;
   Gd_00AB = 0;
   Gi_00E1 = OrdersTotal() - 1;
   Gi_00AC = Gi_00E1;
   if (Gi_00E1 >= 0) { 
   do { 
   if (OrderSelect(Gi_00AC, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00AA == 0 || OrderMagicNumber() == Gi_00AA) { 
   
   Gd_00AB = (Gd_00AB + OrderProfit());
   }}}} 
   Gi_00AC = Gi_00AC - 1;
   } while (Gi_00AC >= 0); 
   } 
   Gd_00A9 = Gd_00AB;
   Gi_00AD = Ii_0018;
   Gd_00AE = 0;
   Gi_00E1 = OrdersTotal() - 1;
   Gi_00AF = Gi_00E1;
   if (Gi_00E1 >= 0) { 
   do { 
   if (OrderSelect(Gi_00AF, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00AD == 0 || OrderMagicNumber() == Gi_00AD) { 
   
   Gd_00AE = (Gd_00AE + OrderProfit());
   }}}} 
   Gi_00AF = Gi_00AF - 1;
   } while (Gi_00AF >= 0); 
   } 
   Gd_00E1 = (((Gd_00A9 + Gd_00AE) + Gd_00A5) + Gd_00E0);
   Gi_00E2 = ProfitTarget * 1000;
   Gd_00E2 = (Gi_00E2 * LotSize);
   if ((Gd_00E1 > (Gd_00E2 / 100))) { 
   Gi_00B0 = Ii_0000;
   Gd_00B1 = 0;
   Gi_00E2 = OrdersTotal() - 1;
   Gi_00B2 = Gi_00E2;
   if (Gi_00E2 >= 0) { 
   do { 
   if (OrderSelect(Gi_00B2, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00B0 == 0 || OrderMagicNumber() == Gi_00B0) { 
   
   Gd_00B1 = (Gd_00B1 + OrderProfit());
   }}}} 
   Gi_00B2 = Gi_00B2 - 1;
   } while (Gi_00B2 >= 0); 
   } 
   if ((Gd_00B1 < 0)) { 
   sqCloseOrder(Ii_0000);
   sqCloseOrder(Ii_0004);
   sqCloseOrder(Ii_0008);
   sqCloseOrder(Ii_000C);
   sqCloseOrder(Ii_0010);
   sqCloseOrder(Ii_0014);
   sqCloseOrder(Ii_0018);
   }} 
   Gi_00B4 = Ii_001C;
   Gd_00B5 = 0;
   Gi_00E2 = OrdersTotal() - 1;
   Gi_00B6 = Gi_00E2;
   if (Gi_00E2 >= 0) { 
   do { 
   if (OrderSelect(Gi_00B6, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00B4 == 0 || OrderMagicNumber() == Gi_00B4) { 
   
   Gd_00B5 = (Gd_00B5 + OrderProfit());
   }}}} 
   Gi_00B6 = Gi_00B6 - 1;
   } while (Gi_00B6 >= 0); 
   } 
   Gd_00B3 = Gd_00B5;
   Gi_00B7 = Ii_0020;
   Gd_00B8 = 0;
   Gi_00E2 = OrdersTotal() - 1;
   Gi_00B9 = Gi_00E2;
   if (Gi_00E2 >= 0) { 
   do { 
   if (OrderSelect(Gi_00B9, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00B7 == 0 || OrderMagicNumber() == Gi_00B7) { 
   
   Gd_00B8 = (Gd_00B8 + OrderProfit());
   }}}} 
   Gi_00B9 = Gi_00B9 - 1;
   } while (Gi_00B9 >= 0); 
   } 
   Gd_00E2 = (Gd_00B3 + Gd_00B8);
   Gi_00BB = Ii_0024;
   Gd_00BC = 0;
   Gi_00E3 = OrdersTotal() - 1;
   Gi_00BD = Gi_00E3;
   if (Gi_00E3 >= 0) { 
   do { 
   if (OrderSelect(Gi_00BD, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00BB == 0 || OrderMagicNumber() == Gi_00BB) { 
   
   Gd_00BC = (Gd_00BC + OrderProfit());
   }}}} 
   Gi_00BD = Gi_00BD - 1;
   } while (Gi_00BD >= 0); 
   } 
   Gd_00BA = Gd_00BC;
   Gi_00BE = Ii_0028;
   Gd_00BF = 0;
   Gi_00E3 = OrdersTotal() - 1;
   Gi_00C0 = Gi_00E3;
   if (Gi_00E3 >= 0) { 
   do { 
   if (OrderSelect(Gi_00C0, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00BE == 0 || OrderMagicNumber() == Gi_00BE) { 
   
   Gd_00BF = (Gd_00BF + OrderProfit());
   }}}} 
   Gi_00C0 = Gi_00C0 - 1;
   } while (Gi_00C0 >= 0); 
   } 
   Gd_00E3 = ((Gd_00BA + Gd_00BF) + Gd_00E2);
   Gi_00C2 = Ii_002C;
   Gd_00C3 = 0;
   Gi_00E4 = OrdersTotal() - 1;
   Gi_00C4 = Gi_00E4;
   if (Gi_00E4 >= 0) { 
   do { 
   if (OrderSelect(Gi_00C4, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00C2 == 0 || OrderMagicNumber() == Gi_00C2) { 
   
   Gd_00C3 = (Gd_00C3 + OrderProfit());
   }}}} 
   Gi_00C4 = Gi_00C4 - 1;
   } while (Gi_00C4 >= 0); 
   } 
   Gd_00C1 = Gd_00C3;
   Gi_00C6 = Ii_0030;
   Gd_00C7 = 0;
   Gi_00E4 = OrdersTotal() - 1;
   Gi_00C8 = Gi_00E4;
   if (Gi_00E4 >= 0) { 
   do { 
   if (OrderSelect(Gi_00C8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00C6 == 0 || OrderMagicNumber() == Gi_00C6) { 
   
   Gd_00C7 = (Gd_00C7 + OrderProfit());
   }}}} 
   Gi_00C8 = Gi_00C8 - 1;
   } while (Gi_00C8 >= 0); 
   } 
   Gd_00C5 = Gd_00C7;
   Gi_00C9 = Ii_0034;
   Gd_00CA = 0;
   Gi_00E4 = OrdersTotal() - 1;
   Gi_00CB = Gi_00E4;
   if (Gi_00E4 >= 0) { 
   do { 
   if (OrderSelect(Gi_00CB, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00C9 == 0 || OrderMagicNumber() == Gi_00C9) { 
   
   Gd_00CA = (Gd_00CA + OrderProfit());
   }}}} 
   Gi_00CB = Gi_00CB - 1;
   } while (Gi_00CB >= 0); 
   } 
   Gd_00E4 = (((Gd_00C5 + Gd_00CA) + Gd_00C1) + Gd_00E3);
   Gi_00E5 = ProfitTarget * 1000;
   Gd_00E5 = (Gi_00E5 * LotSize);
   if ((Gd_00E4 <= (Gd_00E5 / 100))) return 0; 
   Gi_00CC = Ii_001C;
   Gd_00CD = 0;
   Gi_00E5 = OrdersTotal() - 1;
   Gi_00CE = Gi_00E5;
   if (Gi_00E5 >= 0) { 
   do { 
   if (OrderSelect(Gi_00CE, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Gi_00CC == 0 || OrderMagicNumber() == Gi_00CC) { 
   
   Gd_00CD = (Gd_00CD + OrderProfit());
   }}}} 
   Gi_00CE = Gi_00CE - 1;
   } while (Gi_00CE >= 0); 
   } 
   if ((Gd_00CD >= 0)) return 0; 
   sqCloseOrder(Ii_001C);
   sqCloseOrder(Ii_0020);
   sqCloseOrder(Ii_0024);
   sqCloseOrder(Ii_0028);
   sqCloseOrder(Ii_002C);
   sqCloseOrder(Ii_0030);
   sqCloseOrder(Ii_0034);
   
   Li_FFFC = 0;
   
   return Li_FFFC;
}

int deinit()
{
   int Li_FFFC;

   Li_FFFC = 0;
   ObjectDelete("line1");
   ObjectDelete("linec");
   ObjectDelete("line2");
   ObjectDelete("lines");
   ObjectDelete("lineopl");
   ObjectDelete("linea");
   ObjectDelete("lineto");
   ObjectDelete("linetp");
   Li_FFFC = 0;
   return 0;
}

void manageOrder(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   string tmp_str0030;
   string tmp_str0031;
   string tmp_str0032;
   string tmp_str0033;
   string tmp_str0034;
   string tmp_str0035;
   string tmp_str0036;
   string tmp_str0037;
   string tmp_str0038;
   string tmp_str0039;
   string tmp_str003A;
   string tmp_str003B;
   string tmp_str003C;
   string tmp_str003D;
   string tmp_str003E;
   string tmp_str003F;
   string tmp_str0040;
   string tmp_str0041;
   string tmp_str0042;
   string tmp_str0043;
   string tmp_str0044;
   string tmp_str0045;
   string tmp_str0046;
   string tmp_str0047;
   string tmp_str0048;
   string tmp_str0049;
   string tmp_str004A;
   string tmp_str004B;
   string tmp_str004C;
   string tmp_str004D;
   string tmp_str004E;
   string tmp_str004F;
   string tmp_str0050;
   string tmp_str0051;
   string tmp_str0052;
   string tmp_str0053;
   string tmp_str0054;
   string tmp_str0055;
   string tmp_str0056;
   string tmp_str0057;
   string tmp_str0058;
   string tmp_str0059;
   string tmp_str005A;
   string tmp_str005B;
   string tmp_str005C;
   string tmp_str005D;
   string tmp_str005E;
   string tmp_str005F;
   string tmp_str0060;
   string tmp_str0061;
   string tmp_str0062;
   string tmp_str0063;
   string tmp_str0064;
   string tmp_str0065;
   string tmp_str0066;
   string tmp_str0067;
   string tmp_str0068;
   string tmp_str0069;
   string tmp_str006A;
   string tmp_str006B;
   string tmp_str006C;
   string tmp_str006D;
   string tmp_str006E;
   string tmp_str006F;
   string tmp_str0070;
   string tmp_str0071;
   string tmp_str0072;
   string tmp_str0073;
   string tmp_str0074;
   string tmp_str0075;
   string tmp_str0076;
   string tmp_str0077;
   string tmp_str0078;
   string tmp_str0079;
   string tmp_str007A;
   string tmp_str007B;
   string tmp_str007C;
   string tmp_str007D;
   string tmp_str007E;
   string tmp_str007F;
   string tmp_str0080;
   string tmp_str0081;
   string tmp_str0082;
   string tmp_str0083;
   string tmp_str0084;
   string tmp_str0085;
   string tmp_str0086;
   string tmp_str0087;
   string tmp_str0088;
   string tmp_str0089;
   string tmp_str008A;
   string tmp_str008B;
   string tmp_str008C;
   string tmp_str008D;
   string tmp_str008E;
   string tmp_str008F;
   string tmp_str0090;
   string tmp_str0091;
   string tmp_str0092;
   string tmp_str0093;
   string tmp_str0094;
   string tmp_str0095;
   string tmp_str0096;
   string tmp_str0097;
   string tmp_str0098;
   string tmp_str0099;
   string tmp_str009A;
   string tmp_str009B;
   string tmp_str009C;
   string tmp_str009D;
   string tmp_str009E;
   string tmp_str009F;
   string tmp_str00A0;
   string tmp_str00A1;
   string tmp_str00A2;
   string tmp_str00A3;
   string tmp_str00A4;
   string tmp_str00A5;
   string tmp_str00A6;
   string tmp_str00A7;
   string tmp_str00A8;
   string tmp_str00A9;
   string tmp_str00AA;
   string tmp_str00AB;
   string tmp_str00AC;
   string tmp_str00AD;
   string tmp_str00AE;
   string tmp_str00AF;
   string tmp_str00B0;
   string tmp_str00B1;
   string tmp_str00B2;
   string tmp_str00B3;
   string tmp_str00B4;
   string tmp_str00B5;
   string tmp_str00B6;
   string tmp_str00B7;
   string tmp_str00B8;
   string tmp_str00B9;
   string tmp_str00BA;
   string tmp_str00BB;
   string tmp_str00BC;
   string tmp_str00BD;
   string tmp_str00BE;
   string tmp_str00BF;
   string tmp_str00C0;
   string tmp_str00C1;
   string tmp_str00C2;
   string tmp_str00C3;
   string tmp_str00C4;
   string tmp_str00C5;
   string tmp_str00C6;
   string tmp_str00C7;
   string tmp_str00C8;
   string tmp_str00C9;
   string tmp_str00CA;
   string tmp_str00CB;
   string tmp_str00CC;
   string tmp_str00CD;
   string tmp_str00CE;
   string tmp_str00CF;
   string tmp_str00D0;
   string tmp_str00D1;
   string tmp_str00D2;
   string tmp_str00D3;
   string tmp_str00D4;
   string tmp_str00D5;
   string tmp_str00D6;
   string tmp_str00D7;
   string tmp_str00D8;
   string tmp_str00D9;
   string tmp_str00DA;
   string tmp_str00DB;
   string tmp_str00DC;
   string tmp_str00DD;
   string tmp_str00DE;
   string tmp_str00DF;
   string tmp_str00E0;
   string tmp_str00E1;
   string tmp_str00E2;
   string tmp_str00E3;
   string tmp_str00E4;
   string tmp_str00E5;
   string tmp_str00E6;
   string tmp_str00E7;
   string tmp_str00E8;
   string tmp_str00E9;
   string tmp_str00EA;
   string tmp_str00EB;
   string tmp_str00EC;
   string tmp_str00ED;
   string tmp_str00EE;
   string tmp_str00EF;
   string tmp_str00F0;
   string tmp_str00F1;
   string tmp_str00F2;
   string tmp_str00F3;
   string tmp_str00F4;
   string tmp_str00F5;
   string tmp_str00F6;
   string tmp_str00F7;
   string tmp_str00F8;
   string tmp_str00F9;
   string tmp_str00FA;
   string tmp_str00FB;
   string tmp_str00FC;
   string tmp_str00FD;
   string tmp_str00FE;
   string tmp_str00FF;
   string tmp_str0100;
   string tmp_str0101;
   string tmp_str0102;
   string tmp_str0103;
   string tmp_str0104;
   string tmp_str0105;
   string tmp_str0106;
   string tmp_str0107;
   string tmp_str0108;
   string tmp_str0109;
   string tmp_str010A;
   string tmp_str010B;
   string tmp_str010C;
   string tmp_str010D;
   string tmp_str010E;
   string tmp_str010F;
   string tmp_str0110;
   string tmp_str0111;
   string tmp_str0112;
   string tmp_str0113;
   string tmp_str0114;
   string tmp_str0115;
   string tmp_str0116;
   string tmp_str0117;
   string tmp_str0118;
   string tmp_str0119;
   string tmp_str011A;
   string tmp_str011B;
   string tmp_str011C;
   string tmp_str011D;
   string tmp_str011E;
   string tmp_str011F;
   string tmp_str0120;
   string tmp_str0121;
   string tmp_str0122;
   string tmp_str0123;
   string tmp_str0124;
   string tmp_str0125;
   string tmp_str0126;
   string tmp_str0127;
   string tmp_str0128;
   string tmp_str0129;
   string tmp_str012A;
   string tmp_str012B;
   string tmp_str012C;
   string tmp_str012D;
   string tmp_str012E;
   string tmp_str012F;
   string tmp_str0130;
   string tmp_str0131;
   string tmp_str0132;
   string tmp_str0133;
   string tmp_str0134;
   string tmp_str0135;
   string tmp_str0136;
   string tmp_str0137;
   string tmp_str0138;
   string tmp_str0139;
   string tmp_str013A;
   string tmp_str013B;
   string tmp_str013C;
   string tmp_str013D;
   string tmp_str013E;
   string tmp_str013F;
   string tmp_str0140;
   string tmp_str0141;
   string tmp_str0142;
   string tmp_str0143;
   string tmp_str0144;
   string tmp_str0145;
   string tmp_str0146;
   string tmp_str0147;
   string tmp_str0148;
   string tmp_str0149;
   string tmp_str014A;
   string tmp_str014B;
   string tmp_str014C;
   string tmp_str014D;
   string tmp_str014E;
   string tmp_str014F;
   string tmp_str0150;
   string tmp_str0151;
   string tmp_str0152;
   string tmp_str0153;
   string tmp_str0154;
   string tmp_str0155;
   string tmp_str0156;
   string tmp_str0157;
   string tmp_str0158;
   string tmp_str0159;
   string tmp_str015A;
   string tmp_str015B;
   string tmp_str015C;
   string tmp_str015D;
   string tmp_str015E;
   string tmp_str015F;
   string tmp_str0160;
   string tmp_str0161;
   string tmp_str0162;
   string tmp_str0163;
   string tmp_str0164;
   string tmp_str0165;
   string tmp_str0166;
   string tmp_str0167;
   string tmp_str0168;
   string tmp_str0169;
   string tmp_str016A;
   string tmp_str016B;
   string tmp_str016C;
   string tmp_str016D;
   string tmp_str016E;
   string tmp_str016F;
   string tmp_str0170;
   string tmp_str0171;
   string tmp_str0172;
   string tmp_str0173;
   string tmp_str0174;
   string tmp_str0175;
   string tmp_str0176;
   string tmp_str0177;
   string tmp_str0178;
   string tmp_str0179;
   string tmp_str017A;
   string tmp_str017B;
   string tmp_str017C;
   string tmp_str017D;
   string tmp_str017E;
   string tmp_str017F;
   string tmp_str0180;
   string tmp_str0181;
   string tmp_str0182;
   string tmp_str0183;
   string tmp_str0184;
   string tmp_str0185;
   string tmp_str0186;
   string tmp_str0187;
   string tmp_str0188;
   string tmp_str0189;
   string tmp_str018A;
   string tmp_str018B;
   string tmp_str018C;
   string tmp_str018D;
   string tmp_str018E;
   string tmp_str018F;
   string tmp_str0190;
   string tmp_str0191;
   string tmp_str0192;
   string tmp_str0193;
   string tmp_str0194;
   string tmp_str0195;
   string tmp_str0196;
   string tmp_str0197;
   string tmp_str0198;
   string tmp_str0199;
   string tmp_str019A;
   string tmp_str019B;
   string tmp_str019C;
   string tmp_str019D;
   string tmp_str019E;
   string tmp_str019F;
   string tmp_str01A0;
   string tmp_str01A1;
   string tmp_str01A2;
   string tmp_str01A3;
   string tmp_str01A4;
   string tmp_str01A5;
   string tmp_str01A6;
   string tmp_str01A7;
   string tmp_str01A8;
   string tmp_str01A9;
   string tmp_str01AA;
   string tmp_str01AB;
   string tmp_str01AC;
   string tmp_str01AD;
   string tmp_str01AE;
   string tmp_str01AF;
   string tmp_str01B0;
   string tmp_str01B1;
   string tmp_str01B2;
   string tmp_str01B3;
   string tmp_str01B4;
   string tmp_str01B5;
   string tmp_str01B6;
   string tmp_str01B7;
   string tmp_str01B8;
   string tmp_str01B9;
   string tmp_str01BA;
   string tmp_str01BB;
   string tmp_str01BC;
   string tmp_str01BD;
   string tmp_str01BE;
   string tmp_str01BF;
   string tmp_str01C0;
   string tmp_str01C1;
   string tmp_str01C2;
   string tmp_str01C3;
   string tmp_str01C4;
   string tmp_str01C5;
   string tmp_str01C6;
   string tmp_str01C7;
   string tmp_str01C8;
   string tmp_str01C9;
   string tmp_str01CA;
   string tmp_str01CB;
   string tmp_str01CC;
   string tmp_str01CD;
   string tmp_str01CE;
   string tmp_str01CF;
   string tmp_str01D0;
   string tmp_str01D1;
   string tmp_str01D2;
   string tmp_str01D3;
   string tmp_str01D4;
   string tmp_str01D5;
   string tmp_str01D6;
   string tmp_str01D7;
   string tmp_str01D8;
   string tmp_str01D9;
   string tmp_str01DA;
   string tmp_str01DB;
   string tmp_str01DC;
   string tmp_str01DD;
   string tmp_str01DE;
   string tmp_str01DF;
   string tmp_str01E0;
   string tmp_str01E1;
   string tmp_str01E2;
   string tmp_str01E3;
   string tmp_str01E4;
   string tmp_str01E5;
   string tmp_str01E6;
   string tmp_str01E7;
   string tmp_str01E8;
   string tmp_str01E9;
   string tmp_str01EA;
   string tmp_str01EB;
   string tmp_str01EC;
   string tmp_str01ED;
   string tmp_str01EE;
   string tmp_str01EF;
   string tmp_str01F0;
   string tmp_str01F1;
   string tmp_str01F2;
   string tmp_str01F3;
   string tmp_str01F4;
   string tmp_str01F5;
   string tmp_str01F6;
   string tmp_str01F7;
   string tmp_str01F8;
   string tmp_str01F9;
   string tmp_str01FA;
   string tmp_str01FB;
   string tmp_str01FC;
   string tmp_str01FD;
   string tmp_str01FE;
   string tmp_str01FF;
   string tmp_str0200;
   string tmp_str0201;
   string tmp_str0202;
   string tmp_str0203;
   string tmp_str0204;
   string tmp_str0205;
   string tmp_str0206;
   string tmp_str0207;
   string tmp_str0208;
   string tmp_str0209;
   string tmp_str020A;
   string tmp_str020B;
   string tmp_str020C;
   string tmp_str020D;
   string tmp_str020E;
   string tmp_str020F;
   string tmp_str0210;
   string tmp_str0211;
   string tmp_str0212;
   string tmp_str0213;
   string tmp_str0214;
   string tmp_str0215;
   string tmp_str0216;
   string tmp_str0217;
   string tmp_str0218;
   string tmp_str0219;
   string tmp_str021A;
   string tmp_str021B;
   string tmp_str021C;
   string tmp_str021D;
   string tmp_str021E;
   string tmp_str021F;
   string tmp_str0220;
   string tmp_str0221;
   string tmp_str0222;
   string tmp_str0223;
   string tmp_str0224;
   string tmp_str0225;
   string tmp_str0226;
   string tmp_str0227;
   string tmp_str0228;
   string tmp_str0229;
   string tmp_str022A;
   string tmp_str022B;
   string tmp_str022C;
   string tmp_str022D;
   string tmp_str022E;
   string tmp_str022F;
   string tmp_str0230;
   string tmp_str0231;
   string tmp_str0232;
   string tmp_str0233;
   string tmp_str0234;
   string tmp_str0235;
   string tmp_str0236;
   string tmp_str0237;
   string tmp_str0238;
   string tmp_str0239;
   string tmp_str023A;
   string tmp_str023B;
   string tmp_str023C;
   string tmp_str023D;
   string tmp_str023E;
   string tmp_str023F;
   string tmp_str0240;
   string tmp_str0241;
   string tmp_str0242;
   string tmp_str0243;
   string tmp_str0244;
   string tmp_str0245;
   string tmp_str0246;
   string tmp_str0247;
   string tmp_str0248;
   string tmp_str0249;
   string tmp_str024A;
   string tmp_str024B;
   string tmp_str024C;
   string tmp_str024D;
   string tmp_str024E;
   string tmp_str024F;
   string tmp_str0250;
   string tmp_str0251;
   string tmp_str0252;
   string tmp_str0253;
   string tmp_str0254;
   string tmp_str0255;
   string tmp_str0256;
   string tmp_str0257;
   string tmp_str0258;
   string tmp_str0259;
   string tmp_str025A;
   string tmp_str025B;
   string tmp_str025C;
   string tmp_str025D;
   string tmp_str025E;
   string tmp_str025F;
   string tmp_str0260;
   string tmp_str0261;
   string tmp_str0262;
   string tmp_str0263;
   string tmp_str0264;
   string tmp_str0265;
   string tmp_str0266;
   string tmp_str0267;
   string tmp_str0268;
   string tmp_str0269;
   string tmp_str026A;
   string tmp_str026B;
   string tmp_str026C;
   string tmp_str026D;
   string tmp_str026E;
   string tmp_str026F;
   string tmp_str0270;
   string tmp_str0271;
   string tmp_str0272;
   string tmp_str0273;
   string tmp_str0274;
   string tmp_str0275;
   string tmp_str0276;
   string tmp_str0277;
   string tmp_str0278;
   string tmp_str0279;
   string tmp_str027A;
   string tmp_str027B;
   string tmp_str027C;
   string tmp_str027D;
   string tmp_str027E;
   string tmp_str027F;
   string tmp_str0280;
   string tmp_str0281;
   string tmp_str0282;
   string tmp_str0283;
   string tmp_str0284;
   string tmp_str0285;
   string tmp_str0286;
   string tmp_str0287;
   string tmp_str0288;
   string tmp_str0289;
   string tmp_str028A;
   string tmp_str028B;
   string tmp_str028C;
   string tmp_str028D;
   string tmp_str028E;
   string tmp_str028F;
   string tmp_str0290;
   string tmp_str0291;
   string tmp_str0292;
   string tmp_str0293;
   string tmp_str0294;
   string tmp_str0295;
   string tmp_str0296;
   string tmp_str0297;
   string tmp_str0298;
   string tmp_str0299;
   string tmp_str029A;
   string tmp_str029B;
   string tmp_str029C;
   string tmp_str029D;
   string tmp_str029E;
   string tmp_str029F;
   string tmp_str02A0;
   string tmp_str02A1;
   string tmp_str02A2;
   string tmp_str02A3;
   string tmp_str02A4;
   string tmp_str02A5;
   string tmp_str02A6;
   string tmp_str02A7;
   string tmp_str02A8;
   string tmp_str02A9;
   string tmp_str02AA;
   string tmp_str02AB;
   string tmp_str02AC;
   string tmp_str02AD;
   string tmp_str02AE;
   string tmp_str02AF;
   string tmp_str02B0;
   string tmp_str02B1;
   string tmp_str02B2;
   string tmp_str02B3;
   string tmp_str02B4;
   string tmp_str02B5;
   string tmp_str02B6;
   string tmp_str02B7;
   string tmp_str02B8;
   string tmp_str02B9;
   string tmp_str02BA;
   string tmp_str02BB;
   string tmp_str02BC;
   string tmp_str02BD;
   string tmp_str02BE;
   string tmp_str02BF;
   string tmp_str02C0;
   string tmp_str02C1;
   string tmp_str02C2;
   string tmp_str02C3;
   string tmp_str02C4;
   string tmp_str02C5;
   string tmp_str02C6;
   string tmp_str02C7;
   string tmp_str02C8;
   string tmp_str02C9;
   string tmp_str02CA;
   string tmp_str02CB;
   string tmp_str02CC;
   string tmp_str02CD;
   string tmp_str02CE;
   string tmp_str02CF;
   string tmp_str02D0;
   string tmp_str02D1;
   string tmp_str02D2;
   string tmp_str02D3;
   string tmp_str02D4;
   string tmp_str02D5;
   string tmp_str02D6;
   string tmp_str02D7;
   string tmp_str02D8;
   string tmp_str02D9;
   string tmp_str02DA;
   string tmp_str02DB;
   string tmp_str02DC;
   string tmp_str02DD;
   string tmp_str02DE;
   string tmp_str02DF;
   string tmp_str02E0;
   string tmp_str02E1;
   string tmp_str02E2;
   string tmp_str02E3;
   string tmp_str02E4;
   string tmp_str02E5;
   string tmp_str02E6;
   string tmp_str02E7;
   string tmp_str02E8;
   string tmp_str02E9;
   string tmp_str02EA;
   string tmp_str02EB;
   string tmp_str02EC;
   string tmp_str02ED;
   string tmp_str02EE;
   string tmp_str02EF;
   string tmp_str02F0;
   string tmp_str02F1;
   string tmp_str02F2;
   string tmp_str02F3;
   string tmp_str02F4;
   string tmp_str02F5;
   string tmp_str02F6;
   string tmp_str02F7;
   string tmp_str02F8;
   string tmp_str02F9;
   string tmp_str02FA;
   string tmp_str02FB;
   string tmp_str02FC;
   string tmp_str02FD;
   string tmp_str02FE;
   string tmp_str02FF;
   string tmp_str0300;
   string tmp_str0301;
   string tmp_str0302;
   string tmp_str0303;
   string tmp_str0304;
   string tmp_str0305;
   string tmp_str0306;
   string tmp_str0307;
   string tmp_str0308;
   string tmp_str0309;
   string tmp_str030A;
   string tmp_str030B;
   string tmp_str030C;
   string tmp_str030D;
   string tmp_str030E;
   string tmp_str030F;
   string tmp_str0310;
   string tmp_str0311;
   string tmp_str0312;
   string tmp_str0313;
   string tmp_str0314;
   string tmp_str0315;
   string tmp_str0316;
   string tmp_str0317;
   string tmp_str0318;
   string tmp_str0319;
   string tmp_str031A;
   string tmp_str031B;
   string tmp_str031C;
   string tmp_str031D;
   string tmp_str031E;
   string tmp_str031F;
   string tmp_str0320;
   string tmp_str0321;
   string tmp_str0322;
   string tmp_str0323;
   string tmp_str0324;
   string tmp_str0325;
   string tmp_str0326;
   string tmp_str0327;
   string tmp_str0328;
   string tmp_str0329;
   string tmp_str032A;
   string tmp_str032B;
   string tmp_str032C;
   string tmp_str032D;
   string tmp_str032E;
   string tmp_str032F;
   string tmp_str0330;
   string tmp_str0331;
   string tmp_str0332;
   string tmp_str0333;
   string tmp_str0334;
   string tmp_str0335;
   string tmp_str0336;
   string tmp_str0337;
   string tmp_str0338;
   string tmp_str0339;
   string tmp_str033A;
   string tmp_str033B;
   string tmp_str033C;
   string tmp_str033D;
   string tmp_str033E;
   string tmp_str033F;
   string tmp_str0340;
   string tmp_str0341;
   string tmp_str0342;
   string tmp_str0343;
   string tmp_str0344;
   string tmp_str0345;
   string tmp_str0346;
   string tmp_str0347;
   string tmp_str0348;
   string tmp_str0349;
   string tmp_str034A;
   string tmp_str034B;
   string tmp_str034C;
   string tmp_str034D;
   string tmp_str034E;
   string tmp_str034F;
   string tmp_str0350;
   string tmp_str0351;
   string tmp_str0352;
   string tmp_str0353;
   string tmp_str0354;
   string tmp_str0355;
   string tmp_str0356;
   string tmp_str0357;
   string tmp_str0358;
   string tmp_str0359;
   string tmp_str035A;
   string tmp_str035B;
   string tmp_str035C;
   string tmp_str035D;
   string tmp_str035E;
   string tmp_str035F;
   string tmp_str0360;
   string tmp_str0361;
   string tmp_str0362;
   string tmp_str0363;
   string tmp_str0364;
   string tmp_str0365;
   string tmp_str0366;
   string tmp_str0367;
   string tmp_str0368;
   string tmp_str0369;
   string tmp_str036A;
   string tmp_str036B;
   string tmp_str036C;
   string tmp_str036D;
   string tmp_str036E;
   string tmp_str036F;
   string tmp_str0370;
   string tmp_str0371;
   string tmp_str0372;
   string tmp_str0373;
   string tmp_str0374;
   string tmp_str0375;
   string tmp_str0376;
   string tmp_str0377;
   string tmp_str0378;
   string tmp_str0379;
   string tmp_str037A;
   string tmp_str037B;
   string tmp_str037C;
   string tmp_str037D;
   string tmp_str037E;
   string tmp_str037F;
   string tmp_str0380;
   string tmp_str0381;
   string tmp_str0382;
   string tmp_str0383;
   string tmp_str0384;
   string tmp_str0385;
   string tmp_str0386;
   string tmp_str0387;
   string tmp_str0388;
   string tmp_str0389;
   string tmp_str038A;
   string tmp_str038B;
   string tmp_str038C;
   string tmp_str038D;
   string tmp_str038E;
   string tmp_str038F;
   string tmp_str0390;
   string tmp_str0391;
   string tmp_str0392;
   string tmp_str0393;
   string tmp_str0394;
   string tmp_str0395;
   string tmp_str0396;
   string tmp_str0397;
   string tmp_str0398;
   string tmp_str0399;
   string tmp_str039A;
   string tmp_str039B;
   string tmp_str039C;
   string tmp_str039D;
   string tmp_str039E;
   string tmp_str039F;
   string tmp_str03A0;
   string tmp_str03A1;
   string tmp_str03A2;
   string tmp_str03A3;
   string tmp_str03A4;
   string tmp_str03A5;
   string tmp_str03A6;
   string tmp_str03A7;
   string tmp_str03A8;
   string tmp_str03A9;
   string tmp_str03AA;
   string tmp_str03AB;
   string tmp_str03AC;
   string tmp_str03AD;
   string tmp_str03AE;
   string tmp_str03AF;
   string tmp_str03B0;
   string tmp_str03B1;
   string tmp_str03B2;
   string tmp_str03B3;
   string tmp_str03B4;
   string tmp_str03B5;
   string tmp_str03B6;
   string tmp_str03B7;
   string tmp_str03B8;
   string tmp_str03B9;
   string tmp_str03BA;
   string tmp_str03BB;
   string tmp_str03BC;
   string tmp_str03BD;
   string tmp_str03BE;
   string tmp_str03BF;
   string tmp_str03C0;
   string tmp_str03C1;
   string tmp_str03C2;
   string tmp_str03C3;
   string tmp_str03C4;
   string tmp_str03C5;
   string tmp_str03C6;
   string tmp_str03C7;
   string tmp_str03C8;
   string tmp_str03C9;
   string tmp_str03CA;
   string tmp_str03CB;
   string tmp_str03CC;
   string tmp_str03CD;
   string tmp_str03CE;
   string tmp_str03CF;
   string tmp_str03D0;
   string tmp_str03D1;
   string tmp_str03D2;
   string tmp_str03D3;
   string tmp_str03D4;
   string tmp_str03D5;
   string tmp_str03D6;
   string tmp_str03D7;
   string tmp_str03D8;
   string tmp_str03D9;
   string tmp_str03DA;
   string tmp_str03DB;
   string tmp_str03DC;
   string tmp_str03DD;
   string tmp_str03DE;
   string tmp_str03DF;
   string tmp_str03E0;
   string tmp_str03E1;
   string tmp_str03E2;
   string tmp_str03E3;
   string tmp_str03E4;
   string tmp_str03E5;
   string tmp_str03E6;
   string tmp_str03E7;
   string tmp_str03E8;
   string tmp_str03E9;
   string tmp_str03EA;
   string tmp_str03EB;
   string tmp_str03EC;
   string tmp_str03ED;
   string tmp_str03EE;
   string tmp_str03EF;
   string tmp_str03F0;
   string tmp_str03F1;
   string tmp_str03F2;
   string tmp_str03F3;
   string tmp_str03F4;
   string tmp_str03F5;
   string tmp_str03F6;
   string tmp_str03F7;
   string tmp_str03F8;
   string tmp_str03F9;
   string tmp_str03FA;
   string tmp_str03FB;
   string tmp_str03FC;
   string tmp_str03FD;
   string tmp_str03FE;
   string tmp_str03FF;
   string tmp_str0400;
   string tmp_str0401;
   string tmp_str0402;
   string tmp_str0403;
   string tmp_str0404;
   string tmp_str0405;
   string tmp_str0406;
   string tmp_str0407;
   string tmp_str0408;
   string tmp_str0409;
   string tmp_str040A;
   string tmp_str040B;
   string tmp_str040C;
   string tmp_str040D;
   string tmp_str040E;
   string tmp_str040F;
   string tmp_str0410;
   string tmp_str0411;
   string tmp_str0412;
   string tmp_str0413;
   string tmp_str0414;
   string tmp_str0415;
   string tmp_str0416;
   string tmp_str0417;
   string tmp_str0418;
   string tmp_str0419;
   string tmp_str041A;
   string tmp_str041B;
   string tmp_str041C;
   string tmp_str041D;
   string tmp_str041E;
   string tmp_str041F;
   string tmp_str0420;
   string tmp_str0421;
   string tmp_str0422;
   string tmp_str0423;
   string tmp_str0424;
   string tmp_str0425;
   string tmp_str0426;
   string tmp_str0427;
   string tmp_str0428;
   string tmp_str0429;
   string tmp_str042A;
   string tmp_str042B;
   string tmp_str042C;
   string tmp_str042D;
   string tmp_str042E;
   string tmp_str042F;
   string tmp_str0430;
   string tmp_str0431;
   string tmp_str0432;
   string tmp_str0433;
   string tmp_str0434;
   string tmp_str0435;
   string tmp_str0436;
   string tmp_str0437;
   string tmp_str0438;
   string tmp_str0439;
   string tmp_str043A;
   string tmp_str043B;
   string tmp_str043C;
   string tmp_str043D;
   string tmp_str043E;
   string tmp_str043F;
   string tmp_str0440;
   string tmp_str0441;
   string tmp_str0442;
   string tmp_str0443;
   string tmp_str0444;
   string tmp_str0445;
   string tmp_str0446;
   string tmp_str0447;
   string tmp_str0448;
   string tmp_str0449;
   string tmp_str044A;
   string tmp_str044B;
   string tmp_str044C;
   string tmp_str044D;
   string tmp_str044E;
   string tmp_str044F;
   string tmp_str0450;
   string tmp_str0451;
   string tmp_str0452;
   string tmp_str0453;
   string tmp_str0454;
   string tmp_str0455;
   string tmp_str0456;
   string tmp_str0457;
   string tmp_str0458;
   string tmp_str0459;
   string tmp_str045A;
   string tmp_str045B;
   string tmp_str045C;
   string tmp_str045D;
   string tmp_str045E;
   string tmp_str045F;
   string tmp_str0460;
   string tmp_str0461;
   string tmp_str0462;
   string tmp_str0463;
   string tmp_str0464;
   string tmp_str0465;
   string tmp_str0466;
   string tmp_str0467;
   string tmp_str0468;
   string tmp_str0469;
   string tmp_str046A;
   string tmp_str046B;
   string tmp_str046C;
   string tmp_str046D;
   string tmp_str046E;
   string tmp_str046F;
   string tmp_str0470;
   string tmp_str0471;
   string tmp_str0472;
   string tmp_str0473;
   string tmp_str0474;
   string tmp_str0475;
   string tmp_str0476;
   string tmp_str0477;
   string tmp_str0478;
   string tmp_str0479;
   string tmp_str047A;
   string tmp_str047B;
   string tmp_str047C;
   string tmp_str047D;
   string tmp_str047E;
   string tmp_str047F;
   string tmp_str0480;
   string tmp_str0481;
   string tmp_str0482;
   string tmp_str0483;
   string tmp_str0484;
   string tmp_str0485;
   string tmp_str0486;
   string tmp_str0487;
   string tmp_str0488;
   string tmp_str0489;
   string tmp_str048A;
   string tmp_str048B;
   string tmp_str048C;
   string tmp_str048D;
   string tmp_str048E;
   string tmp_str048F;
   string tmp_str0490;
   string tmp_str0491;
   string tmp_str0492;
   string tmp_str0493;
   string tmp_str0494;
   string tmp_str0495;
   string tmp_str0496;
   string tmp_str0497;
   string tmp_str0498;
   string tmp_str0499;
   string tmp_str049A;
   string tmp_str049B;
   string tmp_str049C;
   string tmp_str049D;
   string tmp_str049E;
   string tmp_str049F;
   string tmp_str04A0;
   string tmp_str04A1;
   string tmp_str04A2;
   string tmp_str04A3;
   string tmp_str04A4;
   string tmp_str04A5;
   string tmp_str04A6;
   string tmp_str04A7;
   string tmp_str04A8;
   string tmp_str04A9;
   string tmp_str04AA;
   string tmp_str04AB;
   string tmp_str04AC;
   string tmp_str04AD;
   string tmp_str04AE;
   string tmp_str04AF;
   string tmp_str04B0;
   string tmp_str04B1;
   string tmp_str04B2;
   string tmp_str04B3;
   string tmp_str04B4;
   string tmp_str04B5;
   string tmp_str04B6;
   string tmp_str04B7;
   string tmp_str04B8;
   string tmp_str04B9;
   string tmp_str04BA;
   string tmp_str04BB;
   string tmp_str04BC;
   string tmp_str04BD;
   string tmp_str04BE;
   string tmp_str04BF;
   string tmp_str04C0;
   string tmp_str04C1;
   string tmp_str04C2;
   string tmp_str04C3;
   string tmp_str04C4;
   string tmp_str04C5;
   string tmp_str04C6;
   string tmp_str04C7;
   string tmp_str04C8;
   string tmp_str04C9;
   string tmp_str04CA;
   string tmp_str04CB;
   string tmp_str04CC;
   string tmp_str04CD;
   string tmp_str04CE;
   string tmp_str04CF;
   string tmp_str04D0;
   string tmp_str04D1;
   string tmp_str04D2;
   string tmp_str04D3;
   string tmp_str04D4;
   string tmp_str04D5;
   string tmp_str04D6;
   string tmp_str04D7;
   string tmp_str04D8;
   string tmp_str04D9;
   string tmp_str04DA;
   string tmp_str04DB;
   string tmp_str04DC;
   string tmp_str04DD;
   string tmp_str04DE;
   string tmp_str04DF;
   string tmp_str04E0;
   string tmp_str04E1;
   string tmp_str04E2;
   string tmp_str04E3;
   string tmp_str04E4;
   string tmp_str04E5;
   string tmp_str04E6;
   string tmp_str04E7;
   string tmp_str04E8;
   string tmp_str04E9;
   string tmp_str04EA;
   string tmp_str04EB;
   string tmp_str04EC;
   string tmp_str04ED;
   string tmp_str04EE;
   string tmp_str04EF;
   string tmp_str04F0;
   string tmp_str04F1;
   string tmp_str04F2;
   string tmp_str04F3;
   string tmp_str04F4;
   string tmp_str04F5;
   string tmp_str04F6;
   string tmp_str04F7;
   string tmp_str04F8;
   string tmp_str04F9;
   string tmp_str04FA;
   string tmp_str04FB;
   string tmp_str04FC;
   string tmp_str04FD;
   string tmp_str04FE;
   string tmp_str04FF;
   string tmp_str0500;
   string tmp_str0501;
   string tmp_str0502;
   string tmp_str0503;
   string tmp_str0504;
   string tmp_str0505;
   string tmp_str0506;
   string tmp_str0507;
   string tmp_str0508;
   string tmp_str0509;
   string tmp_str050A;
   string tmp_str050B;
   string tmp_str050C;
   string tmp_str050D;
   string tmp_str050E;
   string tmp_str050F;
   string tmp_str0510;
   string tmp_str0511;
   string tmp_str0512;
   string tmp_str0513;
   string tmp_str0514;
   string tmp_str0515;
   string tmp_str0516;
   string tmp_str0517;
   string tmp_str0518;
   string tmp_str0519;
   string tmp_str051A;
   string tmp_str051B;
   string tmp_str051C;
   string tmp_str051D;
   string tmp_str051E;
   string tmp_str051F;
   string tmp_str0520;
   string tmp_str0521;
   string tmp_str0522;
   string tmp_str0523;
   string tmp_str0524;
   string tmp_str0525;
   string tmp_str0526;
   string tmp_str0527;
   string tmp_str0528;
   string tmp_str0529;
   string tmp_str052A;
   string tmp_str052B;
   string tmp_str052C;
   string tmp_str052D;
   string tmp_str052E;
   string tmp_str052F;
   string tmp_str0530;
   string tmp_str0531;
   string tmp_str0532;
   string tmp_str0533;
   string tmp_str0534;
   string tmp_str0535;
   string tmp_str0536;
   string tmp_str0537;
   string tmp_str0538;
   string tmp_str0539;
   string tmp_str053A;
   string tmp_str053B;
   string tmp_str053C;
   string tmp_str053D;
   string tmp_str053E;
   string tmp_str053F;
   string tmp_str0540;
   string tmp_str0541;
   string tmp_str0542;
   string tmp_str0543;
   string tmp_str0544;
   string tmp_str0545;
   string tmp_str0546;
   string tmp_str0547;
   string tmp_str0548;
   string tmp_str0549;
   string tmp_str054A;
   string tmp_str054B;
   string tmp_str054C;
   string tmp_str054D;
   string tmp_str054E;
   string tmp_str054F;
   string tmp_str0550;
   string tmp_str0551;
   string tmp_str0552;
   string tmp_str0553;
   string tmp_str0554;
   string tmp_str0555;
   string tmp_str0556;
   string tmp_str0557;
   string tmp_str0558;
   string tmp_str0559;
   string tmp_str055A;
   string tmp_str055B;
   string tmp_str055C;
   string tmp_str055D;
   string tmp_str055E;
   string tmp_str055F;
   string tmp_str0560;
   string tmp_str0561;
   string tmp_str0562;
   string tmp_str0563;
   string tmp_str0564;
   string tmp_str0565;
   string tmp_str0566;
   string tmp_str0567;
   string tmp_str0568;
   string tmp_str0569;
   string tmp_str056A;
   string tmp_str056B;
   string tmp_str056C;
   string tmp_str056D;
   string tmp_str056E;
   string tmp_str056F;
   string tmp_str0570;
   string tmp_str0571;
   string tmp_str0572;
   string tmp_str0573;
   string tmp_str0574;
   string tmp_str0575;
   string tmp_str0576;
   string tmp_str0577;
   string tmp_str0578;
   string tmp_str0579;
   string tmp_str057A;
   string tmp_str057B;
   string tmp_str057C;
   string tmp_str057D;
   string tmp_str057E;
   string tmp_str057F;
   string tmp_str0580;
   string tmp_str0581;
   string tmp_str0582;
   string tmp_str0583;
   string tmp_str0584;
   string tmp_str0585;
   string tmp_str0586;
   string tmp_str0587;
   string tmp_str0588;
   string tmp_str0589;
   string tmp_str058A;
   string tmp_str058B;
   string tmp_str058C;
   string tmp_str058D;
   string tmp_str058E;
   string tmp_str058F;
   string tmp_str0590;
   string tmp_str0591;
   string tmp_str0592;
   string tmp_str0593;
   string tmp_str0594;
   string tmp_str0595;
   string tmp_str0596;
   string tmp_str0597;
   string tmp_str0598;
   string tmp_str0599;
   string tmp_str059A;
   string tmp_str059B;
   string tmp_str059C;
   string tmp_str059D;
   string tmp_str059E;
   string tmp_str059F;
   string tmp_str05A0;
   string tmp_str05A1;
   string tmp_str05A2;
   string tmp_str05A3;
   string tmp_str05A4;
   string tmp_str05A5;
   string tmp_str05A6;
   string tmp_str05A7;
   string tmp_str05A8;
   string tmp_str05A9;
   string tmp_str05AA;
   string tmp_str05AB;
   string tmp_str05AC;
   string tmp_str05AD;
   string tmp_str05AE;
   string tmp_str05AF;
   string tmp_str05B0;
   string tmp_str05B1;
   string tmp_str05B2;
   string tmp_str05B3;
   string tmp_str05B4;
   string tmp_str05B5;
   string tmp_str05B6;
   string tmp_str05B7;
   string tmp_str05B8;
   string tmp_str05B9;
   string tmp_str05BA;
   string tmp_str05BB;
   string tmp_str05BC;
   string tmp_str05BD;
   string tmp_str05BE;
   string tmp_str05BF;
   string tmp_str05C0;
   string tmp_str05C1;
   string tmp_str05C2;
   string tmp_str05C3;
   string tmp_str05C4;
   string tmp_str05C5;
   string tmp_str05C6;
   string tmp_str05C7;
   string tmp_str05C8;
   string tmp_str05C9;
   string tmp_str05CA;
   string tmp_str05CB;
   string tmp_str05CC;
   string tmp_str05CD;
   string tmp_str05CE;
   string tmp_str05CF;
   string tmp_str05D0;
   string tmp_str05D1;
   string tmp_str05D2;
   string tmp_str05D3;
   string tmp_str05D4;
   string tmp_str05D5;
   string tmp_str05D6;
   string tmp_str05D7;
   string tmp_str05D8;
   string tmp_str05D9;
   string tmp_str05DA;
   string tmp_str05DB;
   string tmp_str05DC;
   string tmp_str05DD;
   string tmp_str05DE;
   string tmp_str05DF;
   string tmp_str05E0;
   string tmp_str05E1;
   string tmp_str05E2;
   string tmp_str05E3;
   string tmp_str05E4;
   string tmp_str05E5;
   string tmp_str05E6;
   string tmp_str05E7;
   string tmp_str05E8;
   string tmp_str05E9;
   string tmp_str05EA;
   string tmp_str05EB;
   string tmp_str05EC;
   string tmp_str05ED;
   string tmp_str05EE;
   string tmp_str05EF;
   string tmp_str05F0;
   string tmp_str05F1;
   string tmp_str05F2;
   string tmp_str05F3;
   string tmp_str05F4;
   string tmp_str05F5;
   string tmp_str05F6;
   string tmp_str05F7;
   string tmp_str05F8;
   string tmp_str05F9;
   string tmp_str05FA;
   string tmp_str05FB;
   string tmp_str05FC;
   string tmp_str05FD;
   string tmp_str05FE;
   string tmp_str05FF;
   string tmp_str0600;
   string tmp_str0601;
   string tmp_str0602;
   string tmp_str0603;
   string tmp_str0604;
   string tmp_str0605;
   string tmp_str0606;
   string tmp_str0607;
   string tmp_str0608;
   string tmp_str0609;
   string tmp_str060A;
   string tmp_str060B;
   string tmp_str060C;
   string tmp_str060D;
   string tmp_str060E;
   string tmp_str060F;
   string tmp_str0610;
   string tmp_str0611;
   string tmp_str0612;
   string tmp_str0613;
   string tmp_str0614;
   string tmp_str0615;
   string tmp_str0616;
   string tmp_str0617;
   string tmp_str0618;
   string tmp_str0619;
   string tmp_str061A;
   string tmp_str061B;
   string tmp_str061C;
   string tmp_str061D;
   string tmp_str061E;
   string tmp_str061F;
   string tmp_str0620;
   string tmp_str0621;
   string tmp_str0622;
   string tmp_str0623;
   string tmp_str0624;
   string tmp_str0625;
   string tmp_str0626;
   string tmp_str0627;
   string tmp_str0628;
   string tmp_str0629;
   string tmp_str062A;
   string tmp_str062B;
   string tmp_str062C;
   string tmp_str062D;
   string tmp_str062E;
   string tmp_str062F;
   string tmp_str0630;
   string tmp_str0631;
   string tmp_str0632;
   string tmp_str0633;
   string tmp_str0634;
   string tmp_str0635;
   string tmp_str0636;
   string tmp_str0637;
   string tmp_str0638;
   string tmp_str0639;
   string tmp_str063A;
   string tmp_str063B;
   string tmp_str063C;
   string tmp_str063D;
   string tmp_str063E;
   string tmp_str063F;
   string tmp_str0640;
   string tmp_str0641;
   string tmp_str0642;
   string tmp_str0643;
   string tmp_str0644;
   string tmp_str0645;
   string tmp_str0646;
   string tmp_str0647;
   string tmp_str0648;
   string tmp_str0649;
   string tmp_str064A;
   string tmp_str064B;
   string tmp_str064C;
   string tmp_str064D;
   string tmp_str064E;
   string tmp_str064F;
   string tmp_str0650;
   string tmp_str0651;
   string tmp_str0652;
   string tmp_str0653;
   string tmp_str0654;
   string tmp_str0655;
   string tmp_str0656;
   string tmp_str0657;
   string tmp_str0658;
   string tmp_str0659;
   string tmp_str065A;
   string tmp_str065B;
   string tmp_str065C;
   string tmp_str065D;
   string tmp_str065E;
   string tmp_str065F;
   string tmp_str0660;
   string tmp_str0661;
   string tmp_str0662;
   string tmp_str0663;
   string tmp_str0664;
   string tmp_str0665;
   string tmp_str0666;
   string tmp_str0667;
   string tmp_str0668;
   string tmp_str0669;
   string tmp_str066A;
   string tmp_str066B;
   string tmp_str066C;
   string tmp_str066D;
   string tmp_str066E;
   string tmp_str066F;
   string tmp_str0670;
   string tmp_str0671;
   string tmp_str0672;
   string tmp_str0673;
   string tmp_str0674;
   string tmp_str0675;
   string tmp_str0676;
   string tmp_str0677;
   string tmp_str0678;
   string tmp_str0679;
   string tmp_str067A;
   string tmp_str067B;
   string tmp_str067C;
   string tmp_str067D;
   string tmp_str067E;
   string tmp_str067F;
   string tmp_str0680;
   string tmp_str0681;
   string tmp_str0682;
   string tmp_str0683;
   string tmp_str0684;
   string tmp_str0685;
   string tmp_str0686;
   string tmp_str0687;
   string tmp_str0688;
   string tmp_str0689;
   string tmp_str068A;
   string tmp_str068B;
   string tmp_str068C;
   string tmp_str068D;
   string tmp_str068E;
   string tmp_str068F;
   string tmp_str0690;
   string tmp_str0691;
   string tmp_str0692;
   string tmp_str0693;
   string tmp_str0694;
   string tmp_str0695;
   string tmp_str0696;
   string tmp_str0697;
   string tmp_str0698;
   string tmp_str0699;
   string tmp_str069A;
   string tmp_str069B;
   string tmp_str069C;
   string tmp_str069D;
   string tmp_str069E;
   string tmp_str069F;
   string tmp_str06A0;
   string tmp_str06A1;
   string tmp_str06A2;
   string tmp_str06A3;
   string tmp_str06A4;
   string tmp_str06A5;
   string tmp_str06A6;
   string tmp_str06A7;
   string tmp_str06A8;
   string tmp_str06A9;
   string tmp_str06AA;
   string tmp_str06AB;
   string tmp_str06AC;
   string tmp_str06AD;
   string tmp_str06AE;
   string tmp_str06AF;
   string tmp_str06B0;
   string tmp_str06B1;
   string tmp_str06B2;
   string tmp_str06B3;
   string tmp_str06B4;
   string tmp_str06B5;
   string tmp_str06B6;
   string tmp_str06B7;
   string tmp_str06B8;
   string tmp_str06B9;
   string tmp_str06BA;
   string tmp_str06BB;
   string tmp_str06BC;
   string tmp_str06BD;
   string tmp_str06BE;
   string tmp_str06BF;
   string tmp_str06C0;
   string tmp_str06C1;
   string tmp_str06C2;
   string tmp_str06C3;
   string tmp_str06C4;
   string tmp_str06C5;
   string tmp_str06C6;
   string tmp_str06C7;
   string tmp_str06C8;
   string tmp_str06C9;
   string tmp_str06CA;
   string tmp_str06CB;
   string tmp_str06CC;
   string tmp_str06CD;
   string tmp_str06CE;
   string tmp_str06CF;
   string tmp_str06D0;
   string tmp_str06D1;
   string tmp_str06D2;
   string tmp_str06D3;
   string tmp_str06D4;
   string tmp_str06D5;
   string tmp_str06D6;
   string tmp_str06D7;
   string tmp_str06D8;
   string tmp_str06D9;
   string tmp_str06DA;
   string tmp_str06DB;
   string tmp_str06DC;
   string tmp_str06DD;
   string tmp_str06DE;
   string tmp_str06DF;
   string tmp_str06E0;
   string tmp_str06E1;
   string tmp_str06E2;
   string tmp_str06E3;
   string tmp_str06E4;
   string tmp_str06E5;
   string tmp_str06E6;
   string tmp_str06E7;
   string tmp_str06E8;
   string tmp_str06E9;
   string tmp_str06EA;
   string tmp_str06EB;
   string tmp_str06EC;
   string tmp_str06ED;
   string tmp_str06EE;
   string tmp_str06EF;
   string tmp_str06F0;
   string tmp_str06F1;
   string tmp_str06F2;
   string tmp_str06F3;
   string tmp_str06F4;
   string tmp_str06F5;
   string tmp_str06F6;
   string tmp_str06F7;
   string tmp_str06F8;
   string tmp_str06F9;
   string tmp_str06FA;
   string tmp_str06FB;
   string tmp_str06FC;
   string tmp_str06FD;
   string tmp_str06FE;
   string tmp_str06FF;
   string tmp_str0700;
   string tmp_str0701;
   string tmp_str0702;
   string tmp_str0703;
   string tmp_str0704;
   string tmp_str0705;
   string tmp_str0706;
   string tmp_str0707;
   string tmp_str0708;
   string tmp_str0709;
   string tmp_str070A;
   string tmp_str070B;
   string tmp_str070C;
   string tmp_str070D;
   string tmp_str070E;
   string tmp_str070F;
   string tmp_str0710;
   string tmp_str0711;
   string tmp_str0712;
   string tmp_str0713;
   string tmp_str0714;
   string tmp_str0715;
   string tmp_str0716;
   string tmp_str0717;
   string tmp_str0718;
   string tmp_str0719;
   string tmp_str071A;
   string tmp_str071B;
   string tmp_str071C;
   string tmp_str071D;
   string tmp_str071E;
   string tmp_str071F;
   string tmp_str0720;
   string tmp_str0721;
   string tmp_str0722;
   string tmp_str0723;
   string tmp_str0724;
   string tmp_str0725;
   string tmp_str0726;
   string tmp_str0727;
   string tmp_str0728;
   string tmp_str0729;
   string tmp_str072A;
   string tmp_str072B;
   string tmp_str072C;
   string tmp_str072D;
   string tmp_str072E;
   string tmp_str072F;
   string tmp_str0730;
   string tmp_str0731;
   string tmp_str0732;
   string tmp_str0733;
   string tmp_str0734;
   string tmp_str0735;
   string tmp_str0736;
   string tmp_str0737;
   string tmp_str0738;
   string tmp_str0739;
   string tmp_str073A;
   string tmp_str073B;
   string tmp_str073C;
   string tmp_str073D;
   string tmp_str073E;
   string tmp_str073F;
   string tmp_str0740;
   string tmp_str0741;
   string tmp_str0742;
   string tmp_str0743;
   string tmp_str0744;
   string tmp_str0745;
   string tmp_str0746;
   string tmp_str0747;
   string tmp_str0748;
   string tmp_str0749;
   string tmp_str074A;
   string tmp_str074B;
   string tmp_str074C;
   string tmp_str074D;
   string tmp_str074E;
   string tmp_str074F;
   string tmp_str0750;
   string tmp_str0751;
   string tmp_str0752;
   string tmp_str0753;
   double Ld_FFF8;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   int Li_FFDC;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Li_FFDC = 0;
   Gi_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = 0;
   Gd_0007 = 0;
   Gi_0008 = 0;
   Gi_0009 = 0;
   Gi_000A = 0;
   Gi_000B = 0;
   Gi_000C = 0;
   Gd_000D = 0;
   Gi_000E = 0;
   Gl_000F = 0;
   Gi_0010 = 0;
   Gi_0011 = 0;
   Gi_0012 = 0;
   Gi_0013 = 0;
   Gd_0014 = 0;
   Gi_0015 = 0;
   Gi_0016 = 0;
   Gi_0017 = 0;
   Gi_0018 = 0;
   Gi_0019 = 0;
   Gd_001A = 0;
   Gi_001B = 0;
   Gi_001C = 0;
   Gi_001D = 0;
   Gi_001E = 0;
   Gi_001F = 0;
   Gd_0020 = 0;
   Gi_0021 = 0;
   Gl_0022 = 0;
   Gi_0023 = 0;
   Gi_0024 = 0;
   Gi_0025 = 0;
   Gi_0026 = 0;
   Gd_0027 = 0;
   Gi_0028 = 0;
   Gi_0029 = 0;
   Gi_002A = 0;
   Gi_002B = 0;
   Gi_002C = 0;
   Gd_002D = 0;
   Gi_002E = 0;
   Gi_002F = 0;
   Gi_0030 = 0;
   Gi_0031 = 0;
   Gi_0032 = 0;
   Gd_0033 = 0;
   Gi_0034 = 0;
   Gl_0035 = 0;
   Gi_0036 = 0;
   Gi_0037 = 0;
   Gi_0038 = 0;
   Gi_0039 = 0;
   Gd_003A = 0;
   Gi_003B = 0;
   Gi_003C = 0;
   Gi_003D = 0;
   Gi_003E = 0;
   Gi_003F = 0;
   Gd_0040 = 0;
   Gi_0041 = 0;
   Gi_0042 = 0;
   Gi_0043 = 0;
   Gi_0044 = 0;
   Gi_0045 = 0;
   Gd_0046 = 0;
   Gi_0047 = 0;
   Gl_0048 = 0;
   Gi_0049 = 0;
   Gi_004A = 0;
   Gi_004B = 0;
   Gi_004C = 0;
   Gd_004D = 0;
   Gi_004E = 0;
   Gi_004F = 0;
   Gi_0050 = 0;
   Gi_0051 = 0;
   Gi_0052 = 0;
   Gd_0053 = 0;
   Gi_0054 = 0;
   Gi_0055 = 0;
   Gi_0056 = 0;
   Gi_0057 = 0;
   Gi_0058 = 0;
   Gd_0059 = 0;
   Gi_005A = 0;
   Gl_005B = 0;
   Gi_005C = 0;
   Gi_005D = 0;
   Gi_005E = 0;
   Gi_005F = 0;
   Gd_0060 = 0;
   Gi_0061 = 0;
   Gi_0062 = 0;
   Gi_0063 = 0;
   Gi_0064 = 0;
   Gi_0065 = 0;
   Gd_0066 = 0;
   Gi_0067 = 0;
   Gi_0068 = 0;
   Gi_0069 = 0;
   Gi_006A = 0;
   Gi_006B = 0;
   Gd_006C = 0;
   Gi_006D = 0;
   Gl_006E = 0;
   Gi_006F = 0;
   Gi_0070 = 0;
   Gi_0071 = 0;
   Gi_0072 = 0;
   Gd_0073 = 0;
   Gi_0074 = 0;
   Gi_0075 = 0;
   Gi_0076 = 0;
   Gi_0077 = 0;
   Gi_0078 = 0;
   Gd_0079 = 0;
   Gi_007A = 0;
   Gi_007B = 0;
   Gi_007C = 0;
   Gi_007D = 0;
   Gi_007E = 0;
   Gd_007F = 0;
   Gi_0080 = 0;
   Gl_0081 = 0;
   Gi_0082 = 0;
   Gi_0083 = 0;
   Gi_0084 = 0;
   Gi_0085 = 0;
   Gd_0086 = 0;
   Gi_0087 = 0;
   Gi_0088 = 0;
   Gi_0089 = 0;
   Gi_008A = 0;
   Gi_008B = 0;
   Gd_008C = 0;
   Gi_008D = 0;
   Gi_008E = 0;
   Gi_008F = 0;
   Gi_0090 = 0;
   Gi_0091 = 0;
   Gd_0092 = 0;
   Gi_0093 = 0;
   Gl_0094 = 0;
   Gi_0095 = 0;
   Gi_0096 = 0;
   Gi_0097 = 0;
   Gi_0098 = 0;
   Gd_0099 = 0;
   Gi_009A = 0;
   Gi_009B = 0;
   Gi_009C = 0;
   Gi_009D = 0;
   Gi_009E = 0;
   Gd_009F = 0;
   Gi_00A0 = 0;
   Gi_00A1 = 0;
   Gi_00A2 = 0;
   Gi_00A3 = 0;
   Gi_00A4 = 0;
   Gd_00A5 = 0;
   Gi_00A6 = 0;
   Gl_00A7 = 0;
   Gi_00A8 = 0;
   Gi_00A9 = 0;
   Gi_00AA = 0;
   Gi_00AB = 0;
   Gd_00AC = 0;
   Gi_00AD = 0;
   Gi_00AE = 0;
   Gi_00AF = 0;
   Gi_00B0 = 0;
   Gi_00B1 = 0;
   Gd_00B2 = 0;
   Gi_00B3 = 0;
   Gi_00B4 = 0;
   Gi_00B5 = 0;
   Gi_00B6 = 0;
   Gi_00B7 = 0;
   Gd_00B8 = 0;
   Gi_00B9 = 0;
   Gl_00BA = 0;
   Gi_00BB = 0;
   Gi_00BC = 0;
   Gi_00BD = 0;
   Gi_00BE = 0;
   Gd_00BF = 0;
   Gi_00C0 = 0;
   Gi_00C1 = 0;
   Gi_00C2 = 0;
   Gi_00C3 = 0;
   Gi_00C4 = 0;
   Gd_00C5 = 0;
   Gi_00C6 = 0;
   Gi_00C7 = 0;
   Gi_00C8 = 0;
   Gi_00C9 = 0;
   Gi_00CA = 0;
   Gd_00CB = 0;
   Gi_00CC = 0;
   Gl_00CD = 0;
   Gi_00CE = 0;
   Gi_00CF = 0;
   Gi_00D0 = 0;
   Gi_00D1 = 0;
   Gd_00D2 = 0;
   Gi_00D3 = 0;
   Gi_00D4 = 0;
   Gi_00D5 = 0;
   Gi_00D6 = 0;
   Gi_00D7 = 0;
   Gd_00D8 = 0;
   Gi_00D9 = 0;
   Gi_00DA = 0;
   Gi_00DB = 0;
   Gi_00DC = 0;
   Gi_00DD = 0;
   Gd_00DE = 0;
   Gi_00DF = 0;
   Gl_00E0 = 0;
   Gi_00E1 = 0;
   Gi_00E2 = 0;
   Gi_00E3 = 0;
   Gi_00E4 = 0;
   Gd_00E5 = 0;
   Gi_00E6 = 0;
   Gi_00E7 = 0;
   Gi_00E8 = 0;
   Gi_00E9 = 0;
   Gi_00EA = 0;
   Gd_00EB = 0;
   Gi_00EC = 0;
   Gi_00ED = 0;
   Gi_00EE = 0;
   Gi_00EF = 0;
   Gi_00F0 = 0;
   Gd_00F1 = 0;
   Gi_00F2 = 0;
   Gl_00F3 = 0;
   Gi_00F4 = 0;
   Gi_00F5 = 0;
   Gi_00F6 = 0;
   Gi_00F7 = 0;
   Gd_00F8 = 0;
   Gi_00F9 = 0;
   Gi_00FA = 0;
   Gi_00FB = 0;
   Gi_00FC = 0;
   Gi_00FD = 0;
   Gd_00FE = 0;
   Gi_00FF = 0;
   Gi_0100 = 0;
   Gi_0101 = 0;
   Gi_0102 = 0;
   Gi_0103 = 0;
   Gd_0104 = 0;
   Gi_0105 = 0;
   Gl_0106 = 0;
   Gi_0107 = 0;
   Gi_0108 = 0;
   Gi_0109 = 0;
   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Li_FFDC = 0;
   if (Fa_i_00 == Ii_0000) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0000, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_0000 = Ii_0000;
   Gd_0001 = 0;
   if (Ii_0000 == Ii_0000) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0004) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0008) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_000C) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0010) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0014) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0018) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_001C) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0020) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0024) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0028) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_002C) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0030) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   if (Gi_0000 == Ii_0034) { 
   Gd_0001 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0001, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str0000 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0000 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = "";
   tmp_str0008 = (string)Ld_FFE8;
   tmp_str0009 = " to :";
   tmp_str000A = (string)Fa_i_00;
   tmp_str000B = ", Magic Number: ";
   tmp_str000C = (string)OrderTicket();
   tmp_str000D = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str000E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str000E, " ", tmp_str000D, tmp_str000C, tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0002 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0002 > 0) { 
   FileSeek(Gi_0002, 0, 2);
   tmp_str000F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0002, tmp_str000F, " VERBOSE: ", tmp_str000D, tmp_str000C, tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002);
   FileClose(Gi_0002);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_010D = GetLastError();
   Li_FFDC = Gi_010D;
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = "";
   tmp_str0016 = "";
   tmp_str0017 = "";
   tmp_str0018 = ErrorDescription(Gi_010D);
   tmp_str0019 = " - ";
   tmp_str001A = (string)Gi_010D;
   tmp_str001B = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str001C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str001C, " ", tmp_str001B, tmp_str001A, tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0003 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0003 > 0) {
   FileSeek(Gi_0003, 0, 2);
   tmp_str001D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0003, tmp_str001D, " VERBOSE: ", tmp_str001B, tmp_str001A, tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010);
   FileClose(Gi_0003);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str001E = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str001E != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = "";
   tmp_str0023 = "";
   tmp_str0024 = "";
   tmp_str0025 = "";
   tmp_str0026 = (string)Ld_FFE8;
   tmp_str0027 = " to :";
   tmp_str0028 = (string)Fa_i_00;
   tmp_str0029 = ", Magic Number: ";
   tmp_str002A = (string)OrderTicket();
   tmp_str002B = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str002C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str002C, " ", tmp_str002B, tmp_str002A, tmp_str0029, tmp_str0028, tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0004 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0004 > 0) { 
   FileSeek(Gi_0004, 0, 2);
   tmp_str002D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0004, tmp_str002D, " VERBOSE: ", tmp_str002B, tmp_str002A, tmp_str0029, tmp_str0028, tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020);
   FileClose(Gi_0004);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_010F = GetLastError();
   Li_FFDC = Gi_010F;
   tmp_str002E = "";
   tmp_str002F = "";
   tmp_str0030 = (string)OrderStopLoss();
   tmp_str0031 = " Current SL: ";
   tmp_str0032 = (string)Bid;
   tmp_str0033 = ", Bid: ";
   tmp_str0034 = (string)Ask;
   tmp_str0035 = ", Ask: ";
   tmp_str0036 = ErrorDescription(Gi_010F);
   tmp_str0037 = " - ";
   tmp_str0038 = (string)Gi_010F;
   tmp_str0039 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str003A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str003A, " ", tmp_str0039, tmp_str0038, tmp_str0037, tmp_str0036, tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0005 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0005 > 0) { 
   FileSeek(Gi_0005, 0, 2);
   tmp_str003B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0005, tmp_str003B, " VERBOSE: ", tmp_str0039, tmp_str0038, tmp_str0037, tmp_str0036, tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E);
   FileClose(Gi_0005);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0000, OrderType(), OrderOpenPrice());
   Gi_0006 = Ii_0000;
   Gd_0007 = 0;
   if (Ii_0000 == Ii_0000) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0004) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0008) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_000C) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0010) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0014) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0018) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_001C) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0020) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0024) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0028) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_002C) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0030) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   if (Gi_0006 == Ii_0034) { 
   Gd_0007 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0007, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str003C = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str003C != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str003E = "";
   tmp_str003F = "";
   tmp_str0040 = "";
   tmp_str0041 = "";
   tmp_str0042 = "";
   tmp_str0043 = "";
   tmp_str0044 = (string)Ld_FFE8;
   tmp_str0045 = " to :";
   tmp_str0046 = (string)Fa_i_00;
   tmp_str0047 = ", Magic Number: ";
   tmp_str0048 = (string)(string)OrderTicket();
   tmp_str0049 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str004A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str004A, " ", tmp_str0049, tmp_str0048, tmp_str0047, tmp_str0046, tmp_str0045, tmp_str0044, tmp_str0043, tmp_str0042, tmp_str0041, tmp_str0040, tmp_str003F, tmp_str003E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0008 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0008 > 0) { 
   FileSeek(Gi_0008, 0, 2);
   tmp_str004B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0008, tmp_str004B, " VERBOSE: ", tmp_str0049, tmp_str0048, tmp_str0047, tmp_str0046, tmp_str0045, tmp_str0044, tmp_str0043, tmp_str0042, tmp_str0041, tmp_str0040, tmp_str003F, tmp_str003E);
   FileClose(Gi_0008);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0112 = GetLastError();
   Li_FFDC = Gi_0112;
   tmp_str004C = "";
   tmp_str004D = "";
   tmp_str004E = (string)OrderStopLoss();
   tmp_str004F = " Current SL: ";
   tmp_str0050 = (string)Bid;
   tmp_str0051 = ", Bid: ";
   tmp_str0052 = (string)Ask;
   tmp_str0053 = ", Ask: ";
   tmp_str0054 = ErrorDescription(Gi_0112);
   tmp_str0055 = " - ";
   tmp_str0056 = (string)Gi_0112;
   tmp_str0057 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0058 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0058, " ", tmp_str0057, tmp_str0056, tmp_str0055, tmp_str0054, tmp_str0053, tmp_str0052, tmp_str0051, tmp_str0050, tmp_str004F, tmp_str004E, tmp_str004D, tmp_str004C);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0009 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0009 > 0) {
   FileSeek(Gi_0009, 0, 2);
   tmp_str0059 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0009, tmp_str0059, " VERBOSE: ", tmp_str0057, tmp_str0056, tmp_str0055, tmp_str0054, tmp_str0053, tmp_str0052, tmp_str0051, tmp_str0050, tmp_str004F, tmp_str004E, tmp_str004D, tmp_str004C);
   FileClose(Gi_0009);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str005A = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str005A != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str005C = "";
   tmp_str005D = "";
   tmp_str005E = "";
   tmp_str005F = "";
   tmp_str0060 = "";
   tmp_str0061 = "";
   tmp_str0062 = (string)Ld_FFE8;
   tmp_str0063 = " to :";
   tmp_str0064 = (string)Fa_i_00;
   tmp_str0065 = ", Magic Number: ";
   tmp_str0066 = (string)OrderTicket();
   tmp_str0067 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0068 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0068, " ", tmp_str0067, tmp_str0066, tmp_str0065, tmp_str0064, tmp_str0063, tmp_str0062, tmp_str0061, tmp_str0060, tmp_str005F, tmp_str005E, tmp_str005D, tmp_str005C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_000A = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_000A > 0) { 
   FileSeek(Gi_000A, 0, 2);
   tmp_str0069 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_000A, tmp_str0069, " VERBOSE: ", tmp_str0067, tmp_str0066, tmp_str0065, tmp_str0064, tmp_str0063, tmp_str0062, tmp_str0061, tmp_str0060, tmp_str005F, tmp_str005E, tmp_str005D, tmp_str005C);
   FileClose(Gi_000A);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0114 = GetLastError();
   Li_FFDC = Gi_0114;
   tmp_str006A = "";
   tmp_str006B = "";
   tmp_str006C = (string)OrderStopLoss();
   tmp_str006D = " Current SL: ";
   tmp_str006E = (string)Bid;
   tmp_str006F = ", Bid: ";
   tmp_str0070 = (string)Ask;
   tmp_str0071 = ", Ask: ";
   tmp_str0072 = ErrorDescription(Gi_0114);
   tmp_str0073 = " - ";
   tmp_str0074 = (string)Gi_0114;
   tmp_str0075 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0076 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0076, " ", tmp_str0075, tmp_str0074, tmp_str0073, tmp_str0072, tmp_str0071, tmp_str0070, tmp_str006F, tmp_str006E, tmp_str006D, tmp_str006C, tmp_str006B, tmp_str006A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_000B = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_000B > 0) { 
   FileSeek(Gi_000B, 0, 2);
   tmp_str0077 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_000B, tmp_str0077, " VERBOSE: ", tmp_str0075, tmp_str0074, tmp_str0073, tmp_str0072, tmp_str0071, tmp_str0070, tmp_str006F, tmp_str006E, tmp_str006D, tmp_str006C, tmp_str006B, tmp_str006A);
   FileClose(Gi_000B);
   }}}}}}}}} 
   Gi_000C = Ii_0000;
   Gd_000D = 0;
   if (Ii_0000 == Ii_0000) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0004) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0008) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_000C) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0010) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0014) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0018) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_001C) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0020) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0024) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0028) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_002C) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0030) { 
   Gd_000D = 0;
   } 
   if (Gi_000C == Ii_0034) { 
   Gd_000D = 0;
   } 
   returned_double = NormalizeDouble(Gd_000D, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_000E = (int)(returned_double + 10);
   Gl_000F = OrderOpenTime();
   Gi_0010 = 0;
   Gi_0011 = 0;
   Gi_0114 = Gi_000E + 10;
   if (Gi_0114 > 0) { 
   do { 
   if (Gl_000F < Time[Gi_0011]) { 
   Gi_0010 = Gi_0010 + 1;
   } 
   Gi_0011 = Gi_0011 + 1;
   Gi_0115 = Gi_000E + 10;
   } while (Gi_0011 < Gi_0115); 
   } 
   if ((Gi_0010 >= Ld_FFF8)) { 
   tmp_str0078 = "";
   tmp_str0079 = "";
   tmp_str007A = "";
   tmp_str007B = "";
   tmp_str007C = "";
   tmp_str007D = "";
   tmp_str007E = (string)Fa_i_00;
   tmp_str007F = ", Magic Number: ";
   tmp_str0080 = (string)OrderTicket();
   tmp_str0081 = "bars - closing order with ticket: ";
   tmp_str0082 = (string)Ld_FFF8;
   tmp_str0083 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str0084 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0084, " ", tmp_str0083, tmp_str0082, tmp_str0081, tmp_str0080, tmp_str007F, tmp_str007E, tmp_str007D, tmp_str007C, tmp_str007B, tmp_str007A, tmp_str0079, tmp_str0078);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0012 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0012 > 0) { 
   FileSeek(Gi_0012, 0, 2);
   tmp_str0085 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0012, tmp_str0085, " VERBOSE: ", tmp_str0083, tmp_str0082, tmp_str0081, tmp_str0080, tmp_str007F, tmp_str007E, tmp_str007D, tmp_str007C, tmp_str007B, tmp_str007A, tmp_str0079, tmp_str0078);
   FileClose(Gi_0012);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0004) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0004, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_0013 = Ii_0004;
   Gd_0014 = 0;
   if (Ii_0004 == Ii_0000) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0004) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0008) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_000C) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0010) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0014) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0018) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_001C) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0020) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0024) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0028) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_002C) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0030) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   if (Gi_0013 == Ii_0034) { 
   Gd_0014 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0014, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str0086 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0086 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0088 = "";
   tmp_str0089 = "";
   tmp_str008A = "";
   tmp_str008B = "";
   tmp_str008C = "";
   tmp_str008D = "";
   tmp_str008E = (string)Ld_FFE8;
   tmp_str008F = " to :";
   tmp_str0090 = (string)Fa_i_00;
   tmp_str0091 = ", Magic Number: ";
   tmp_str0092 = (string)OrderTicket();
   tmp_str0093 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0094 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0094, " ", tmp_str0093, tmp_str0092, tmp_str0091, tmp_str0090, tmp_str008F, tmp_str008E, tmp_str008D, tmp_str008C, tmp_str008B, tmp_str008A, tmp_str0089, tmp_str0088);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0015 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0015 > 0) { 
   FileSeek(Gi_0015, 0, 2);
   tmp_str0095 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0015, tmp_str0095, " VERBOSE: ", tmp_str0093, tmp_str0092, tmp_str0091, tmp_str0090, tmp_str008F, tmp_str008E, tmp_str008D, tmp_str008C, tmp_str008B, tmp_str008A, tmp_str0089, tmp_str0088);
   FileClose(Gi_0015);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0118 = GetLastError();
   Li_FFDC = Gi_0118;
   tmp_str0096 = "";
   tmp_str0097 = "";
   tmp_str0098 = "";
   tmp_str0099 = "";
   tmp_str009A = "";
   tmp_str009B = "";
   tmp_str009C = "";
   tmp_str009D = "";
   tmp_str009E = ErrorDescription(Gi_0118);
   tmp_str009F = " - ";
   tmp_str00A0 = (string)Gi_0118;
   tmp_str00A1 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str00A2 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00A2, " ", tmp_str00A1, tmp_str00A0, tmp_str009F, tmp_str009E, tmp_str009D, tmp_str009C, tmp_str009B, tmp_str009A, tmp_str0099, tmp_str0098, tmp_str0097, tmp_str0096);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0016 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0016 > 0) {
   FileSeek(Gi_0016, 0, 2);
   tmp_str00A3 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0016, tmp_str00A3, " VERBOSE: ", tmp_str00A1, tmp_str00A0, tmp_str009F, tmp_str009E, tmp_str009D, tmp_str009C, tmp_str009B, tmp_str009A, tmp_str0099, tmp_str0098, tmp_str0097, tmp_str0096);
   FileClose(Gi_0016);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str00A4 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str00A4 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str00A6 = "";
   tmp_str00A7 = "";
   tmp_str00A8 = "";
   tmp_str00A9 = "";
   tmp_str00AA = "";
   tmp_str00AB = "";
   tmp_str00AC = (string)Ld_FFE8;
   tmp_str00AD = " to :";
   tmp_str00AE = (string)Fa_i_00;
   tmp_str00AF = ", Magic Number: ";
   tmp_str00B0 = (string)OrderTicket();
   tmp_str00B1 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str00B2 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00B2, " ", tmp_str00B1, tmp_str00B0, tmp_str00AF, tmp_str00AE, tmp_str00AD, tmp_str00AC, tmp_str00AB, tmp_str00AA, tmp_str00A9, tmp_str00A8, tmp_str00A7, tmp_str00A6);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0017 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0017 > 0) { 
   FileSeek(Gi_0017, 0, 2);
   tmp_str00B3 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0017, tmp_str00B3, " VERBOSE: ", tmp_str00B1, tmp_str00B0, tmp_str00AF, tmp_str00AE, tmp_str00AD, tmp_str00AC, tmp_str00AB, tmp_str00AA, tmp_str00A9, tmp_str00A8, tmp_str00A7, tmp_str00A6);
   FileClose(Gi_0017);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_011A = GetLastError();
   Li_FFDC = Gi_011A;
   tmp_str00B4 = "";
   tmp_str00B5 = "";
   tmp_str00B6 = (string)OrderStopLoss();
   tmp_str00B7 = " Current SL: ";
   tmp_str00B8 = (string)Bid;
   tmp_str00B9 = ", Bid: ";
   tmp_str00BA = (string)Ask;
   tmp_str00BB = ", Ask: ";
   tmp_str00BC = ErrorDescription(Gi_011A);
   tmp_str00BD = " - ";
   tmp_str00BE = (string)Gi_011A;
   tmp_str00BF = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str00C0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00C0, " ", tmp_str00BF, tmp_str00BE, tmp_str00BD, tmp_str00BC, tmp_str00BB, tmp_str00BA, tmp_str00B9, tmp_str00B8, tmp_str00B7, tmp_str00B6, tmp_str00B5, tmp_str00B4);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0018 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0018 > 0) { 
   FileSeek(Gi_0018, 0, 2);
   tmp_str00C1 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0018, tmp_str00C1, " VERBOSE: ", tmp_str00BF, tmp_str00BE, tmp_str00BD, tmp_str00BC, tmp_str00BB, tmp_str00BA, tmp_str00B9, tmp_str00B8, tmp_str00B7, tmp_str00B6, tmp_str00B5, tmp_str00B4);
   FileClose(Gi_0018);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0004, OrderType(), OrderOpenPrice());
   Gi_0019 = Ii_0004;
   Gd_001A = 0;
   if (Ii_0004 == Ii_0000) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0004) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0008) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_000C) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0010) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0014) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0018) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_001C) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0020) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0024) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0028) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_002C) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0030) { 
   Gd_001A = (Id_0090 * 0);
   } 
   if (Gi_0019 == Ii_0034) { 
   Gd_001A = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_001A, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str00C2 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str00C2 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str00C4 = "";
   tmp_str00C5 = "";
   tmp_str00C6 = "";
   tmp_str00C7 = "";
   tmp_str00C8 = "";
   tmp_str00C9 = "";
   tmp_str00CA = (string)Ld_FFE8;
   tmp_str00CB = " to :";
   tmp_str00CC = (string)Fa_i_00;
   tmp_str00CD = ", Magic Number: ";
   tmp_str00CE = (string)OrderTicket();
   tmp_str00CF = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str00D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00D0, " ", tmp_str00CF, tmp_str00CE, tmp_str00CD, tmp_str00CC, tmp_str00CB, tmp_str00CA, tmp_str00C9, tmp_str00C8, tmp_str00C7, tmp_str00C6, tmp_str00C5, tmp_str00C4);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_001B = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_001B > 0) { 
   FileSeek(Gi_001B, 0, 2);
   tmp_str00D1 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_001B, tmp_str00D1, " VERBOSE: ", tmp_str00CF, tmp_str00CE, tmp_str00CD, tmp_str00CC, tmp_str00CB, tmp_str00CA, tmp_str00C9, tmp_str00C8, tmp_str00C7, tmp_str00C6, tmp_str00C5, tmp_str00C4);
   FileClose(Gi_001B);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_011D = GetLastError();
   Li_FFDC = Gi_011D;
   tmp_str00D2 = "";
   tmp_str00D3 = "";
   tmp_str00D4 = (string)OrderStopLoss();
   tmp_str00D5 = " Current SL: ";
   tmp_str00D6 = (string)Bid;
   tmp_str00D7 = ", Bid: ";
   tmp_str00D8 = (string)Ask;
   tmp_str00D9 = ", Ask: ";
   tmp_str00DA = ErrorDescription(Gi_011D);
   tmp_str00DB = " - ";
   tmp_str00DC = (string)Gi_011D;
   tmp_str00DD = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str00DE = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00DE, " ", tmp_str00DD, tmp_str00DC, tmp_str00DB, tmp_str00DA, tmp_str00D9, tmp_str00D8, tmp_str00D7, tmp_str00D6, tmp_str00D5, tmp_str00D4, tmp_str00D3, tmp_str00D2);
   }
   else{
   if (Ii_007C == 2) {
   Gi_001C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_001C > 0) {
   FileSeek(Gi_001C, 0, 2);
   tmp_str00DF = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_001C, tmp_str00DF, " VERBOSE: ", tmp_str00DD, tmp_str00DC, tmp_str00DB, tmp_str00DA, tmp_str00D9, tmp_str00D8, tmp_str00D7, tmp_str00D6, tmp_str00D5, tmp_str00D4, tmp_str00D3, tmp_str00D2);
   FileClose(Gi_001C);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str00E0 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str00E0 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str00E2 = "";
   tmp_str00E3 = "";
   tmp_str00E4 = "";
   tmp_str00E5 = "";
   tmp_str00E6 = "";
   tmp_str00E7 = "";
   tmp_str00E8 = (string)Ld_FFE8;
   tmp_str00E9 = " to :";
   tmp_str00EA = (string)Fa_i_00;
   tmp_str00EB = ", Magic Number: ";
   tmp_str00EC = (string)OrderTicket();
   tmp_str00ED = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str00EE = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00EE, " ", tmp_str00ED, tmp_str00EC, tmp_str00EB, tmp_str00EA, tmp_str00E9, tmp_str00E8, tmp_str00E7, tmp_str00E6, tmp_str00E5, tmp_str00E4, tmp_str00E3, tmp_str00E2);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_001D = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_001D > 0) { 
   FileSeek(Gi_001D, 0, 2);
   tmp_str00EF = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_001D, tmp_str00EF, " VERBOSE: ", tmp_str00ED, tmp_str00EC, tmp_str00EB, tmp_str00EA, tmp_str00E9, tmp_str00E8, tmp_str00E7, tmp_str00E6, tmp_str00E5, tmp_str00E4, tmp_str00E3, tmp_str00E2);
   FileClose(Gi_001D);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_011F = GetLastError();
   Li_FFDC = Gi_011F;
   tmp_str00F0 = "";
   tmp_str00F1 = "";
   tmp_str00F2 = (string)OrderStopLoss();
   tmp_str00F3 = " Current SL: ";
   tmp_str00F4 = (string)Bid;
   tmp_str00F5 = ", Bid: ";
   tmp_str00F6 = (string)Ask;
   tmp_str00F7 = ", Ask: ";
   tmp_str00F8 = ErrorDescription(Gi_011F);
   tmp_str00F9 = " - ";
   tmp_str00FA = (string)Gi_011F;
   tmp_str00FB = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str00FC = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00FC, " ", tmp_str00FB, tmp_str00FA, tmp_str00F9, tmp_str00F8, tmp_str00F7, tmp_str00F6, tmp_str00F5, tmp_str00F4, tmp_str00F3, tmp_str00F2, tmp_str00F1, tmp_str00F0);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_001E = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_001E > 0) { 
   FileSeek(Gi_001E, 0, 2);
   tmp_str00FD = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_001E, tmp_str00FD, " VERBOSE: ", tmp_str00FB, tmp_str00FA, tmp_str00F9, tmp_str00F8, tmp_str00F7, tmp_str00F6, tmp_str00F5, tmp_str00F4, tmp_str00F3, tmp_str00F2, tmp_str00F1, tmp_str00F0);
   FileClose(Gi_001E);
   }}}}}}}}} 
   Gi_001F = Ii_0004;
   Gd_0020 = 0;
   if (Ii_0004 == Ii_0000) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0004) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0008) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_000C) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0010) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0014) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0018) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_001C) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0020) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0024) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0028) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_002C) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0030) { 
   Gd_0020 = 0;
   } 
   if (Gi_001F == Ii_0034) { 
   Gd_0020 = 0;
   } 
   returned_double = NormalizeDouble(Gd_0020, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_0021 = (int)(returned_double + 10);
   Gl_0022 = OrderOpenTime();
   Gi_0023 = 0;
   Gi_0024 = 0;
   Gi_011F = Gi_0021 + 10;
   if (Gi_011F > 0) { 
   do { 
   if (Gl_0022 < Time[Gi_0024]) { 
   Gi_0023 = Gi_0023 + 1;
   } 
   Gi_0024 = Gi_0024 + 1;
   Gi_0120 = Gi_0021 + 10;
   } while (Gi_0024 < Gi_0120); 
   } 
   if ((Gi_0023 >= Ld_FFF8)) { 
   tmp_str00FE = "";
   tmp_str00FF = "";
   tmp_str0100 = "";
   tmp_str0101 = "";
   tmp_str0102 = "";
   tmp_str0103 = "";
   tmp_str0104 = (string)Fa_i_00;
   tmp_str0105 = ", Magic Number: ";
   tmp_str0106 = (string)OrderTicket();
   tmp_str0107 = "bars - closing order with ticket: ";
   tmp_str0108 = (string)Ld_FFF8;
   tmp_str0109 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str010A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str010A, " ", tmp_str0109, tmp_str0108, tmp_str0107, tmp_str0106, tmp_str0105, tmp_str0104, tmp_str0103, tmp_str0102, tmp_str0101, tmp_str0100, tmp_str00FF, tmp_str00FE);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0025 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0025 > 0) { 
   FileSeek(Gi_0025, 0, 2);
   tmp_str010B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0025, tmp_str010B, " VERBOSE: ", tmp_str0109, tmp_str0108, tmp_str0107, tmp_str0106, tmp_str0105, tmp_str0104, tmp_str0103, tmp_str0102, tmp_str0101, tmp_str0100, tmp_str00FF, tmp_str00FE);
   FileClose(Gi_0025);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0008) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0008, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_0026 = Ii_0008;
   Gd_0027 = 0;
   if (Ii_0008 == Ii_0000) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0004) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0008) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_000C) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0010) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0014) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0018) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_001C) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0020) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0024) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0028) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_002C) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0030) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   if (Gi_0026 == Ii_0034) { 
   Gd_0027 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0027, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str010C = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str010C != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str010E = "";
   tmp_str010F = "";
   tmp_str0110 = "";
   tmp_str0111 = "";
   tmp_str0112 = "";
   tmp_str0113 = "";
   tmp_str0114 = (string)Ld_FFE8;
   tmp_str0115 = " to :";
   tmp_str0116 = (string)Fa_i_00;
   tmp_str0117 = ", Magic Number: ";
   tmp_str0118 = (string)OrderTicket();
   tmp_str0119 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str011A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str011A, " ", tmp_str0119, tmp_str0118, tmp_str0117, tmp_str0116, tmp_str0115, tmp_str0114, tmp_str0113, tmp_str0112, tmp_str0111, tmp_str0110, tmp_str010F, tmp_str010E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0028 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0028 > 0) { 
   FileSeek(Gi_0028, 0, 2);
   tmp_str011B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0028, tmp_str011B, " VERBOSE: ", tmp_str0119, tmp_str0118, tmp_str0117, tmp_str0116, tmp_str0115, tmp_str0114, tmp_str0113, tmp_str0112, tmp_str0111, tmp_str0110, tmp_str010F, tmp_str010E);
   FileClose(Gi_0028);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0123 = GetLastError();
   Li_FFDC = Gi_0123;
   tmp_str011C = "";
   tmp_str011D = "";
   tmp_str011E = "";
   tmp_str011F = "";
   tmp_str0120 = "";
   tmp_str0121 = "";
   tmp_str0122 = "";
   tmp_str0123 = "";
   tmp_str0124 = ErrorDescription(Gi_0123);
   tmp_str0125 = " - ";
   tmp_str0126 = (string)Gi_0123;
   tmp_str0127 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0128 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0128, " ", tmp_str0127, tmp_str0126, tmp_str0125, tmp_str0124, tmp_str0123, tmp_str0122, tmp_str0121, tmp_str0120, tmp_str011F, tmp_str011E, tmp_str011D, tmp_str011C);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0029 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0029 > 0) {
   FileSeek(Gi_0029, 0, 2);
   tmp_str0129 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0029, tmp_str0129, " VERBOSE: ", tmp_str0127, tmp_str0126, tmp_str0125, tmp_str0124, tmp_str0123, tmp_str0122, tmp_str0121, tmp_str0120, tmp_str011F, tmp_str011E, tmp_str011D, tmp_str011C);
   FileClose(Gi_0029);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str012A = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str012A != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str012C = "";
   tmp_str012D = "";
   tmp_str012E = "";
   tmp_str012F = "";
   tmp_str0130 = "";
   tmp_str0131 = "";
   tmp_str0132 = (string)Ld_FFE8;
   tmp_str0133 = " to :";
   tmp_str0134 = (string)Fa_i_00;
   tmp_str0135 = ", Magic Number: ";
   tmp_str0136 = (string)OrderTicket();
   tmp_str0137 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0138 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0138, " ", tmp_str0137, tmp_str0136, tmp_str0135, tmp_str0134, tmp_str0133, tmp_str0132, tmp_str0131, tmp_str0130, tmp_str012F, tmp_str012E, tmp_str012D, tmp_str012C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_002A = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_002A > 0) { 
   FileSeek(Gi_002A, 0, 2);
   tmp_str0139 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_002A, tmp_str0139, " VERBOSE: ", tmp_str0137, tmp_str0136, tmp_str0135, tmp_str0134, tmp_str0133, tmp_str0132, tmp_str0131, tmp_str0130, tmp_str012F, tmp_str012E, tmp_str012D, tmp_str012C);
   FileClose(Gi_002A);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0125 = GetLastError();
   Li_FFDC = Gi_0125;
   tmp_str013A = "";
   tmp_str013B = "";
   tmp_str013C = (string)OrderStopLoss();
   tmp_str013D = " Current SL: ";
   tmp_str013E = (string)Bid;
   tmp_str013F = ", Bid: ";
   tmp_str0140 = (string)Ask;
   tmp_str0141 = ", Ask: ";
   tmp_str0142 = ErrorDescription(Gi_0125);
   tmp_str0143 = " - ";
   tmp_str0144 = (string)Gi_0125;
   tmp_str0145 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0146 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0146, " ", tmp_str0145, tmp_str0144, tmp_str0143, tmp_str0142, tmp_str0141, tmp_str0140, tmp_str013F, tmp_str013E, tmp_str013D, tmp_str013C, tmp_str013B, tmp_str013A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_002B = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_002B > 0) { 
   FileSeek(Gi_002B, 0, 2);
   tmp_str0147 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_002B, tmp_str0147, " VERBOSE: ", tmp_str0145, tmp_str0144, tmp_str0143, tmp_str0142, tmp_str0141, tmp_str0140, tmp_str013F, tmp_str013E, tmp_str013D, tmp_str013C, tmp_str013B, tmp_str013A);
   FileClose(Gi_002B);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0008, OrderType(), OrderOpenPrice());
   Gi_002C = Ii_0008;
   Gd_002D = 0;
   if (Ii_0008 == Ii_0000) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0004) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0008) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_000C) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0010) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0014) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0018) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_001C) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0020) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0024) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0028) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_002C) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0030) { 
   Gd_002D = (Id_0090 * 0);
   } 
   if (Gi_002C == Ii_0034) { 
   Gd_002D = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_002D, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str0148 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0148 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str014A = "";
   tmp_str014B = "";
   tmp_str014C = "";
   tmp_str014D = "";
   tmp_str014E = "";
   tmp_str014F = "";
   tmp_str0150 = (string)Ld_FFE8;
   tmp_str0151 = " to :";
   tmp_str0152 = (string)Fa_i_00;
   tmp_str0153 = ", Magic Number: ";
   tmp_str0154 = (string)OrderTicket();
   tmp_str0155 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0156 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0156, " ", tmp_str0155, tmp_str0154, tmp_str0153, tmp_str0152, tmp_str0151, tmp_str0150, tmp_str014F, tmp_str014E, tmp_str014D, tmp_str014C, tmp_str014B, tmp_str014A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_002E = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_002E > 0) { 
   FileSeek(Gi_002E, 0, 2);
   tmp_str0157 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_002E, tmp_str0157, " VERBOSE: ", tmp_str0155, tmp_str0154, tmp_str0153, tmp_str0152, tmp_str0151, tmp_str0150, tmp_str014F, tmp_str014E, tmp_str014D, tmp_str014C, tmp_str014B, tmp_str014A);
   FileClose(Gi_002E);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0128 = GetLastError();
   Li_FFDC = Gi_0128;
   tmp_str0158 = "";
   tmp_str0159 = "";
   tmp_str015A = (string)OrderStopLoss();
   tmp_str015B = " Current SL: ";
   tmp_str015C = (string)Bid;
   tmp_str015D = ", Bid: ";
   tmp_str015E = (string)Ask;
   tmp_str015F = ", Ask: ";
   tmp_str0160 = ErrorDescription(Gi_0128);
   tmp_str0161 = " - ";
   tmp_str0162 = (string)Gi_0128;
   tmp_str0163 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0164 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0164, " ", tmp_str0163, tmp_str0162, tmp_str0161, tmp_str0160, tmp_str015F, tmp_str015E, tmp_str015D, tmp_str015C, tmp_str015B, tmp_str015A, tmp_str0159, tmp_str0158);
   }
   else{
   if (Ii_007C == 2) {
   Gi_002F = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_002F > 0) {
   FileSeek(Gi_002F, 0, 2);
   tmp_str0165 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_002F, tmp_str0165, " VERBOSE: ", tmp_str0163, tmp_str0162, tmp_str0161, tmp_str0160, tmp_str015F, tmp_str015E, tmp_str015D, tmp_str015C, tmp_str015B, tmp_str015A, tmp_str0159, tmp_str0158);
   FileClose(Gi_002F);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str0166 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0166 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0168 = "";
   tmp_str0169 = "";
   tmp_str016A = "";
   tmp_str016B = "";
   tmp_str016C = "";
   tmp_str016D = "";
   tmp_str016E = (string)Ld_FFE8;
   tmp_str016F = " to :";
   tmp_str0170 = (string)Fa_i_00;
   tmp_str0171 = ", Magic Number: ";
   tmp_str0172 = (string)OrderTicket();
   tmp_str0173 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0174 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0174, " ", tmp_str0173, tmp_str0172, tmp_str0171, tmp_str0170, tmp_str016F, tmp_str016E, tmp_str016D, tmp_str016C, tmp_str016B, tmp_str016A, tmp_str0169, tmp_str0168);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0030 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0030 > 0) { 
   FileSeek(Gi_0030, 0, 2);
   tmp_str0175 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0030, tmp_str0175, " VERBOSE: ", tmp_str0173, tmp_str0172, tmp_str0171, tmp_str0170, tmp_str016F, tmp_str016E, tmp_str016D, tmp_str016C, tmp_str016B, tmp_str016A, tmp_str0169, tmp_str0168);
   FileClose(Gi_0030);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_012A = GetLastError();
   Li_FFDC = Gi_012A;
   tmp_str0176 = "";
   tmp_str0177 = "";
   tmp_str0178 = (string)OrderStopLoss();
   tmp_str0179 = " Current SL: ";
   tmp_str017A = (string)Bid;
   tmp_str017B = ", Bid: ";
   tmp_str017C = (string)Ask;
   tmp_str017D = ", Ask: ";
   tmp_str017E = ErrorDescription(Gi_012A);
   tmp_str017F = " - ";
   tmp_str0180 = (string)Gi_012A;
   tmp_str0181 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0182 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0182, " ", tmp_str0181, tmp_str0180, tmp_str017F, tmp_str017E, tmp_str017D, tmp_str017C, tmp_str017B, tmp_str017A, tmp_str0179, tmp_str0178, tmp_str0177, tmp_str0176);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0031 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0031 > 0) { 
   FileSeek(Gi_0031, 0, 2);
   tmp_str0183 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0031, tmp_str0183, " VERBOSE: ", tmp_str0181, tmp_str0180, tmp_str017F, tmp_str017E, tmp_str017D, tmp_str017C, tmp_str017B, tmp_str017A, tmp_str0179, tmp_str0178, tmp_str0177, tmp_str0176);
   FileClose(Gi_0031);
   }}}}}}}}} 
   Gi_0032 = Ii_0008;
   Gd_0033 = 0;
   if (Ii_0008 == Ii_0000) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0004) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0008) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_000C) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0010) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0014) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0018) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_001C) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0020) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0024) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0028) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_002C) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0030) { 
   Gd_0033 = 0;
   } 
   if (Gi_0032 == Ii_0034) { 
   Gd_0033 = 0;
   } 
   returned_double = NormalizeDouble(Gd_0033, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_0034 = (int)(returned_double + 10);
   Gl_0035 = OrderOpenTime();
   Gi_0036 = 0;
   Gi_0037 = 0;
   Gi_012A = Gi_0034 + 10;
   if (Gi_012A > 0) { 
   do { 
   if (Gl_0035 < Time[Gi_0037]) { 
   Gi_0036 = Gi_0036 + 1;
   } 
   Gi_0037 = Gi_0037 + 1;
   Gi_012B = Gi_0034 + 10;
   } while (Gi_0037 < Gi_012B); 
   } 
   if ((Gi_0036 >= Ld_FFF8)) { 
   tmp_str0184 = "";
   tmp_str0185 = "";
   tmp_str0186 = "";
   tmp_str0187 = "";
   tmp_str0188 = "";
   tmp_str0189 = "";
   tmp_str018A = (string)Fa_i_00;
   tmp_str018B = ", Magic Number: ";
   tmp_str018C = (string)OrderTicket();
   tmp_str018D = "bars - closing order with ticket: ";
   tmp_str018E = (string)Ld_FFF8;
   tmp_str018F = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str0190 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0190, " ", tmp_str018F, tmp_str018E, tmp_str018D, tmp_str018C, tmp_str018B, tmp_str018A, tmp_str0189, tmp_str0188, tmp_str0187, tmp_str0186, tmp_str0185, tmp_str0184);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0038 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0038 > 0) { 
   FileSeek(Gi_0038, 0, 2);
   tmp_str0191 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0038, tmp_str0191, " VERBOSE: ", tmp_str018F, tmp_str018E, tmp_str018D, tmp_str018C, tmp_str018B, tmp_str018A, tmp_str0189, tmp_str0188, tmp_str0187, tmp_str0186, tmp_str0185, tmp_str0184);
   FileClose(Gi_0038);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_000C) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_000C, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_0039 = Ii_000C;
   Gd_003A = 0;
   if (Ii_000C == Ii_0000) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0004) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0008) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_000C) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0010) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0014) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0018) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_001C) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0020) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0024) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0028) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_002C) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0030) { 
   Gd_003A = (Id_0090 * 0);
   } 
   if (Gi_0039 == Ii_0034) { 
   Gd_003A = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_003A, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str0192 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0192 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0194 = "";
   tmp_str0195 = "";
   tmp_str0196 = "";
   tmp_str0197 = "";
   tmp_str0198 = "";
   tmp_str0199 = "";
   tmp_str019A = (string)Ld_FFE8;
   tmp_str019B = " to :";
   tmp_str019C = (string)Fa_i_00;
   tmp_str019D = ", Magic Number: ";
   tmp_str019E = (string)OrderTicket();
   tmp_str019F = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str01A0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str01A0, " ", tmp_str019F, tmp_str019E, tmp_str019D, tmp_str019C, tmp_str019B, tmp_str019A, tmp_str0199, tmp_str0198, tmp_str0197, tmp_str0196, tmp_str0195, tmp_str0194);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_003B = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_003B > 0) { 
   FileSeek(Gi_003B, 0, 2);
   tmp_str01A1 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_003B, tmp_str01A1, " VERBOSE: ", tmp_str019F, tmp_str019E, tmp_str019D, tmp_str019C, tmp_str019B, tmp_str019A, tmp_str0199, tmp_str0198, tmp_str0197, tmp_str0196, tmp_str0195, tmp_str0194);
   FileClose(Gi_003B);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_012E = GetLastError();
   Li_FFDC = Gi_012E;
   tmp_str01A2 = "";
   tmp_str01A3 = "";
   tmp_str01A4 = "";
   tmp_str01A5 = "";
   tmp_str01A6 = "";
   tmp_str01A7 = "";
   tmp_str01A8 = "";
   tmp_str01A9 = "";
   tmp_str01AA = ErrorDescription(Gi_012E);
   tmp_str01AB = " - ";
   tmp_str01AC = (string)Gi_012E;
   tmp_str01AD = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str01AE = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str01AE, " ", tmp_str01AD, tmp_str01AC, tmp_str01AB, tmp_str01AA, tmp_str01A9, tmp_str01A8, tmp_str01A7, tmp_str01A6, tmp_str01A5, tmp_str01A4, tmp_str01A3, tmp_str01A2);
   }
   else{
   if (Ii_007C == 2) {
   Gi_003C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_003C > 0) {
   FileSeek(Gi_003C, 0, 2);
   tmp_str01AF = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_003C, tmp_str01AF, " VERBOSE: ", tmp_str01AD, tmp_str01AC, tmp_str01AB, tmp_str01AA, tmp_str01A9, tmp_str01A8, tmp_str01A7, tmp_str01A6, tmp_str01A5, tmp_str01A4, tmp_str01A3, tmp_str01A2);
   FileClose(Gi_003C);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str01B0 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str01B0 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str01B2 = "";
   tmp_str01B3 = "";
   tmp_str01B4 = "";
   tmp_str01B5 = "";
   tmp_str01B6 = "";
   tmp_str01B7 = "";
   tmp_str01B8 = (string)Ld_FFE8;
   tmp_str01B9 = " to :";
   tmp_str01BA = (string)Fa_i_00;
   tmp_str01BB = ", Magic Number: ";
   tmp_str01BC = (string)OrderTicket();
   tmp_str01BD = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str01BE = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str01BE, " ", tmp_str01BD, tmp_str01BC, tmp_str01BB, tmp_str01BA, tmp_str01B9, tmp_str01B8, tmp_str01B7, tmp_str01B6, tmp_str01B5, tmp_str01B4, tmp_str01B3, tmp_str01B2);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_003D = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_003D > 0) { 
   FileSeek(Gi_003D, 0, 2);
   tmp_str01BF = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_003D, tmp_str01BF, " VERBOSE: ", tmp_str01BD, tmp_str01BC, tmp_str01BB, tmp_str01BA, tmp_str01B9, tmp_str01B8, tmp_str01B7, tmp_str01B6, tmp_str01B5, tmp_str01B4, tmp_str01B3, tmp_str01B2);
   FileClose(Gi_003D);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0130 = GetLastError();
   Li_FFDC = Gi_0130;
   tmp_str01C0 = "";
   tmp_str01C1 = "";
   tmp_str01C2 = (string)OrderStopLoss();
   tmp_str01C3 = " Current SL: ";
   tmp_str01C4 = (string)Bid;
   tmp_str01C5 = ", Bid: ";
   tmp_str01C6 = (string)Ask;
   tmp_str01C7 = ", Ask: ";
   tmp_str01C8 = ErrorDescription(Gi_0130);
   tmp_str01C9 = " - ";
   tmp_str01CA = (string)Gi_0130;
   tmp_str01CB = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str01CC = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str01CC, " ", tmp_str01CB, tmp_str01CA, tmp_str01C9, tmp_str01C8, tmp_str01C7, tmp_str01C6, tmp_str01C5, tmp_str01C4, tmp_str01C3, tmp_str01C2, tmp_str01C1, tmp_str01C0);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_003E = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_003E > 0) { 
   FileSeek(Gi_003E, 0, 2);
   tmp_str01CD = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_003E, tmp_str01CD, " VERBOSE: ", tmp_str01CB, tmp_str01CA, tmp_str01C9, tmp_str01C8, tmp_str01C7, tmp_str01C6, tmp_str01C5, tmp_str01C4, tmp_str01C3, tmp_str01C2, tmp_str01C1, tmp_str01C0);
   FileClose(Gi_003E);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_000C, OrderType(), OrderOpenPrice());
   Gi_003F = Ii_000C;
   Gd_0040 = 0;
   if (Ii_000C == Ii_0000) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0004) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0008) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_000C) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0010) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0014) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0018) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_001C) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0020) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0024) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0028) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_002C) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0030) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   if (Gi_003F == Ii_0034) { 
   Gd_0040 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0040, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str01CE = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str01CE != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str01D0 = "";
   tmp_str01D1 = "";
   tmp_str01D2 = "";
   tmp_str01D3 = "";
   tmp_str01D4 = "";
   tmp_str01D5 = "";
   tmp_str01D6 = (string)Ld_FFE8;
   tmp_str01D7 = " to :";
   tmp_str01D8 = (string)Fa_i_00;
   tmp_str01D9 = ", Magic Number: ";
   tmp_str01DA = (string)OrderTicket();
   tmp_str01DB = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str01DC = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str01DC, " ", tmp_str01DB, tmp_str01DA, tmp_str01D9, tmp_str01D8, tmp_str01D7, tmp_str01D6, tmp_str01D5, tmp_str01D4, tmp_str01D3, tmp_str01D2, tmp_str01D1, tmp_str01D0);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0041 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0041 > 0) { 
   FileSeek(Gi_0041, 0, 2);
   tmp_str01DD = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0041, tmp_str01DD, " VERBOSE: ", tmp_str01DB, tmp_str01DA, tmp_str01D9, tmp_str01D8, tmp_str01D7, tmp_str01D6, tmp_str01D5, tmp_str01D4, tmp_str01D3, tmp_str01D2, tmp_str01D1, tmp_str01D0);
   FileClose(Gi_0041);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0133 = GetLastError();
   Li_FFDC = Gi_0133;
   tmp_str01DE = "";
   tmp_str01DF = "";
   tmp_str01E0 = (string)OrderStopLoss();
   tmp_str01E1 = " Current SL: ";
   tmp_str01E2 = (string)Bid;
   tmp_str01E3 = ", Bid: ";
   tmp_str01E4 = (string)Ask;
   tmp_str01E5 = ", Ask: ";
   tmp_str01E6 = ErrorDescription(Gi_0133);
   tmp_str01E7 = " - ";
   tmp_str01E8 = (string)Gi_0133;
   tmp_str01E9 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str01EA = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str01EA, " ", tmp_str01E9, tmp_str01E8, tmp_str01E7, tmp_str01E6, tmp_str01E5, tmp_str01E4, tmp_str01E3, tmp_str01E2, tmp_str01E1, tmp_str01E0, tmp_str01DF, tmp_str01DE);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0042 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0042 > 0) {
   FileSeek(Gi_0042, 0, 2);
   tmp_str01EB = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0042, tmp_str01EB, " VERBOSE: ", tmp_str01E9, tmp_str01E8, tmp_str01E7, tmp_str01E6, tmp_str01E5, tmp_str01E4, tmp_str01E3, tmp_str01E2, tmp_str01E1, tmp_str01E0, tmp_str01DF, tmp_str01DE);
   FileClose(Gi_0042);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str01EC = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str01EC != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str01EE = "";
   tmp_str01EF = "";
   tmp_str01F0 = "";
   tmp_str01F1 = "";
   tmp_str01F2 = "";
   tmp_str01F3 = "";
   tmp_str01F4 = (string)Ld_FFE8;
   tmp_str01F5 = " to :";
   tmp_str01F6 = (string)Fa_i_00;
   tmp_str01F7 = ", Magic Number: ";
   tmp_str01F8 = (string)OrderTicket();
   tmp_str01F9 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str01FA = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str01FA, " ", tmp_str01F9, tmp_str01F8, tmp_str01F7, tmp_str01F6, tmp_str01F5, tmp_str01F4, tmp_str01F3, tmp_str01F2, tmp_str01F1, tmp_str01F0, tmp_str01EF, tmp_str01EE);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0043 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0043 > 0) { 
   FileSeek(Gi_0043, 0, 2);
   tmp_str01FB = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0043, tmp_str01FB, " VERBOSE: ", tmp_str01F9, tmp_str01F8, tmp_str01F7, tmp_str01F6, tmp_str01F5, tmp_str01F4, tmp_str01F3, tmp_str01F2, tmp_str01F1, tmp_str01F0, tmp_str01EF, tmp_str01EE);
   FileClose(Gi_0043);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0135 = GetLastError();
   Li_FFDC = Gi_0135;
   tmp_str01FC = "";
   tmp_str01FD = "";
   tmp_str01FE = (string)OrderStopLoss();
   tmp_str01FF = " Current SL: ";
   tmp_str0200 = (string)Bid;
   tmp_str0201 = ", Bid: ";
   tmp_str0202 = (string)Ask;
   tmp_str0203 = ", Ask: ";
   tmp_str0204 = ErrorDescription(Gi_0135);
   tmp_str0205 = " - ";
   tmp_str0206 = (string)Gi_0135;
   tmp_str0207 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0208 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0208, " ", tmp_str0207, tmp_str0206, tmp_str0205, tmp_str0204, tmp_str0203, tmp_str0202, tmp_str0201, tmp_str0200, tmp_str01FF, tmp_str01FE, tmp_str01FD, tmp_str01FC);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0044 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0044 > 0) { 
   FileSeek(Gi_0044, 0, 2);
   tmp_str0209 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0044, tmp_str0209, " VERBOSE: ", tmp_str0207, tmp_str0206, tmp_str0205, tmp_str0204, tmp_str0203, tmp_str0202, tmp_str0201, tmp_str0200, tmp_str01FF, tmp_str01FE, tmp_str01FD, tmp_str01FC);
   FileClose(Gi_0044);
   }}}}}}}}} 
   Gi_0045 = Ii_000C;
   Gd_0046 = 0;
   if (Ii_000C == Ii_0000) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0004) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0008) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_000C) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0010) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0014) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0018) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_001C) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0020) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0024) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0028) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_002C) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0030) { 
   Gd_0046 = 0;
   } 
   if (Gi_0045 == Ii_0034) { 
   Gd_0046 = 0;
   } 
   returned_double = NormalizeDouble(Gd_0046, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_0047 = (int)(returned_double + 10);
   Gl_0048 = OrderOpenTime();
   Gi_0049 = 0;
   Gi_004A = 0;
   Gi_0135 = Gi_0047 + 10;
   if (Gi_0135 > 0) { 
   do { 
   if (Gl_0048 < Time[Gi_004A]) { 
   Gi_0049 = Gi_0049 + 1;
   } 
   Gi_004A = Gi_004A + 1;
   Gi_0136 = Gi_0047 + 10;
   } while (Gi_004A < Gi_0136); 
   } 
   if ((Gi_0049 >= Ld_FFF8)) { 
   tmp_str020A = "";
   tmp_str020B = "";
   tmp_str020C = "";
   tmp_str020D = "";
   tmp_str020E = "";
   tmp_str020F = "";
   tmp_str0210 = (string)Fa_i_00;
   tmp_str0211 = ", Magic Number: ";
   tmp_str0212 = (string)OrderTicket();
   tmp_str0213 = "bars - closing order with ticket: ";
   tmp_str0214 = (string)Ld_FFF8;
   tmp_str0215 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str0216 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0216, " ", tmp_str0215, tmp_str0214, tmp_str0213, tmp_str0212, tmp_str0211, tmp_str0210, tmp_str020F, tmp_str020E, tmp_str020D, tmp_str020C, tmp_str020B, tmp_str020A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_004B = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_004B > 0) { 
   FileSeek(Gi_004B, 0, 2);
   tmp_str0217 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_004B, tmp_str0217, " VERBOSE: ", tmp_str0215, tmp_str0214, tmp_str0213, tmp_str0212, tmp_str0211, tmp_str0210, tmp_str020F, tmp_str020E, tmp_str020D, tmp_str020C, tmp_str020B, tmp_str020A);
   FileClose(Gi_004B);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0010) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0010, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_004C = Ii_0010;
   Gd_004D = 0;
   if (Ii_0010 == Ii_0000) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0004) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0008) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_000C) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0010) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0014) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0018) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_001C) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0020) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0024) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0028) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_002C) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0030) { 
   Gd_004D = (Id_0090 * 0);
   } 
   if (Gi_004C == Ii_0034) { 
   Gd_004D = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_004D, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str0218 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0218 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str021A = "";
   tmp_str021B = "";
   tmp_str021C = "";
   tmp_str021D = "";
   tmp_str021E = "";
   tmp_str021F = "";
   tmp_str0220 = (string)Ld_FFE8;
   tmp_str0221 = " to :";
   tmp_str0222 = (string)Fa_i_00;
   tmp_str0223 = ", Magic Number: ";
   tmp_str0224 = (string)OrderTicket();
   tmp_str0225 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0226 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0226, " ", tmp_str0225, tmp_str0224, tmp_str0223, tmp_str0222, tmp_str0221, tmp_str0220, tmp_str021F, tmp_str021E, tmp_str021D, tmp_str021C, tmp_str021B, tmp_str021A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_004E = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_004E > 0) { 
   FileSeek(Gi_004E, 0, 2);
   tmp_str0227 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_004E, tmp_str0227, " VERBOSE: ", tmp_str0225, tmp_str0224, tmp_str0223, tmp_str0222, tmp_str0221, tmp_str0220, tmp_str021F, tmp_str021E, tmp_str021D, tmp_str021C, tmp_str021B, tmp_str021A);
   FileClose(Gi_004E);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0139 = GetLastError();
   Li_FFDC = Gi_0139;
   tmp_str0228 = "";
   tmp_str0229 = "";
   tmp_str022A = "";
   tmp_str022B = "";
   tmp_str022C = "";
   tmp_str022D = "";
   tmp_str022E = "";
   tmp_str022F = "";
   tmp_str0230 = ErrorDescription(Gi_0139);
   tmp_str0231 = " - ";
   tmp_str0232 = (string)Gi_0139;
   tmp_str0233 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0234 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0234, " ", tmp_str0233, tmp_str0232, tmp_str0231, tmp_str0230, tmp_str022F, tmp_str022E, tmp_str022D, tmp_str022C, tmp_str022B, tmp_str022A, tmp_str0229, tmp_str0228);
   }
   else{
   if (Ii_007C == 2) {
   Gi_004F = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_004F > 0) {
   FileSeek(Gi_004F, 0, 2);
   tmp_str0235 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_004F, tmp_str0235, " VERBOSE: ", tmp_str0233, tmp_str0232, tmp_str0231, tmp_str0230, tmp_str022F, tmp_str022E, tmp_str022D, tmp_str022C, tmp_str022B, tmp_str022A, tmp_str0229, tmp_str0228);
   FileClose(Gi_004F);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str0236 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0236 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0238 = "";
   tmp_str0239 = "";
   tmp_str023A = "";
   tmp_str023B = "";
   tmp_str023C = "";
   tmp_str023D = "";
   tmp_str023E = (string)Ld_FFE8;
   tmp_str023F = " to :";
   tmp_str0240 = (string)Fa_i_00;
   tmp_str0241 = ", Magic Number: ";
   tmp_str0242 = (string)OrderTicket();
   tmp_str0243 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0244 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0244, " ", tmp_str0243, tmp_str0242, tmp_str0241, tmp_str0240, tmp_str023F, tmp_str023E, tmp_str023D, tmp_str023C, tmp_str023B, tmp_str023A, tmp_str0239, tmp_str0238);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0050 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0050 > 0) { 
   FileSeek(Gi_0050, 0, 2);
   tmp_str0245 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0050, tmp_str0245, " VERBOSE: ", tmp_str0243, tmp_str0242, tmp_str0241, tmp_str0240, tmp_str023F, tmp_str023E, tmp_str023D, tmp_str023C, tmp_str023B, tmp_str023A, tmp_str0239, tmp_str0238);
   FileClose(Gi_0050);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_013B = GetLastError();
   Li_FFDC = Gi_013B;
   tmp_str0246 = "";
   tmp_str0247 = "";
   tmp_str0248 = (string)OrderStopLoss();
   tmp_str0249 = " Current SL: ";
   tmp_str024A = (string)Bid;
   tmp_str024B = ", Bid: ";
   tmp_str024C = (string)Ask;
   tmp_str024D = ", Ask: ";
   tmp_str024E = ErrorDescription(Gi_013B);
   tmp_str024F = " - ";
   tmp_str0250 = (string)Gi_013B;
   tmp_str0251 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0252 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0252, " ", tmp_str0251, tmp_str0250, tmp_str024F, tmp_str024E, tmp_str024D, tmp_str024C, tmp_str024B, tmp_str024A, tmp_str0249, tmp_str0248, tmp_str0247, tmp_str0246);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0051 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0051 > 0) { 
   FileSeek(Gi_0051, 0, 2);
   tmp_str0253 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0051, tmp_str0253, " VERBOSE: ", tmp_str0251, tmp_str0250, tmp_str024F, tmp_str024E, tmp_str024D, tmp_str024C, tmp_str024B, tmp_str024A, tmp_str0249, tmp_str0248, tmp_str0247, tmp_str0246);
   FileClose(Gi_0051);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0010, OrderType(), OrderOpenPrice());
   Gi_0052 = Ii_0010;
   Gd_0053 = 0;
   if (Ii_0010 == Ii_0000) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0004) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0008) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_000C) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0010) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0014) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0018) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_001C) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0020) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0024) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0028) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_002C) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0030) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   if (Gi_0052 == Ii_0034) { 
   Gd_0053 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0053, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str0254 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0254 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0256 = "";
   tmp_str0257 = "";
   tmp_str0258 = "";
   tmp_str0259 = "";
   tmp_str025A = "";
   tmp_str025B = "";
   tmp_str025C = (string)Ld_FFE8;
   tmp_str025D = " to :";
   tmp_str025E = (string)Fa_i_00;
   tmp_str025F = ", Magic Number: ";
   tmp_str0260 = (string)OrderTicket();
   tmp_str0261 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0262 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0262, " ", tmp_str0261, tmp_str0260, tmp_str025F, tmp_str025E, tmp_str025D, tmp_str025C, tmp_str025B, tmp_str025A, tmp_str0259, tmp_str0258, tmp_str0257, tmp_str0256);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0054 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0054 > 0) { 
   FileSeek(Gi_0054, 0, 2);
   tmp_str0263 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0054, tmp_str0263, " VERBOSE: ", tmp_str0261, tmp_str0260, tmp_str025F, tmp_str025E, tmp_str025D, tmp_str025C, tmp_str025B, tmp_str025A, tmp_str0259, tmp_str0258, tmp_str0257, tmp_str0256);
   FileClose(Gi_0054);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_013E = GetLastError();
   Li_FFDC = Gi_013E;
   tmp_str0264 = "";
   tmp_str0265 = "";
   tmp_str0266 = (string)OrderStopLoss();
   tmp_str0267 = " Current SL: ";
   tmp_str0268 = (string)Bid;
   tmp_str0269 = ", Bid: ";
   tmp_str026A = (string)Ask;
   tmp_str026B = ", Ask: ";
   tmp_str026C = ErrorDescription(Gi_013E);
   tmp_str026D = " - ";
   tmp_str026E = (string)Gi_013E;
   tmp_str026F = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0270 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0270, " ", tmp_str026F, tmp_str026E, tmp_str026D, tmp_str026C, tmp_str026B, tmp_str026A, tmp_str0269, tmp_str0268, tmp_str0267, tmp_str0266, tmp_str0265, tmp_str0264);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0055 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0055 > 0) {
   FileSeek(Gi_0055, 0, 2);
   tmp_str0271 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0055, tmp_str0271, " VERBOSE: ", tmp_str026F, tmp_str026E, tmp_str026D, tmp_str026C, tmp_str026B, tmp_str026A, tmp_str0269, tmp_str0268, tmp_str0267, tmp_str0266, tmp_str0265, tmp_str0264);
   FileClose(Gi_0055);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str0272 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0272 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0274 = "";
   tmp_str0275 = "";
   tmp_str0276 = "";
   tmp_str0277 = "";
   tmp_str0278 = "";
   tmp_str0279 = "";
   tmp_str027A = (string)Ld_FFE8;
   tmp_str027B = " to :";
   tmp_str027C = (string)Fa_i_00;
   tmp_str027D = ", Magic Number: ";
   tmp_str027E = (string)(string)(string)OrderTicket();
   tmp_str027F = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0280 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0280, " ", tmp_str027F, tmp_str027E, tmp_str027D, tmp_str027C, tmp_str027B, tmp_str027A, tmp_str0279, tmp_str0278, tmp_str0277, tmp_str0276, tmp_str0275, tmp_str0274);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0056 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0056 > 0) { 
   FileSeek(Gi_0056, 0, 2);
   tmp_str0281 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0056, tmp_str0281, " VERBOSE: ", tmp_str027F, tmp_str027E, tmp_str027D, tmp_str027C, tmp_str027B, tmp_str027A, tmp_str0279, tmp_str0278, tmp_str0277, tmp_str0276, tmp_str0275, tmp_str0274);
   FileClose(Gi_0056);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0140 = GetLastError();
   Li_FFDC = Gi_0140;
   tmp_str0282 = "";
   tmp_str0283 = "";
   tmp_str0284 = (string)OrderStopLoss();
   tmp_str0285 = " Current SL: ";
   tmp_str0286 = (string)Bid;
   tmp_str0287 = ", Bid: ";
   tmp_str0288 = (string)Ask;
   tmp_str0289 = ", Ask: ";
   tmp_str028A = ErrorDescription(Gi_0140);
   tmp_str028B = " - ";
   tmp_str028C = (string)Gi_0140;
   tmp_str028D = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str028E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str028E, " ", tmp_str028D, tmp_str028C, tmp_str028B, tmp_str028A, tmp_str0289, tmp_str0288, tmp_str0287, tmp_str0286, tmp_str0285, tmp_str0284, tmp_str0283, tmp_str0282);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0057 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0057 > 0) { 
   FileSeek(Gi_0057, 0, 2);
   tmp_str028F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0057, tmp_str028F, " VERBOSE: ", tmp_str028D, tmp_str028C, tmp_str028B, tmp_str028A, tmp_str0289, tmp_str0288, tmp_str0287, tmp_str0286, tmp_str0285, tmp_str0284, tmp_str0283, tmp_str0282);
   FileClose(Gi_0057);
   }}}}}}}}} 
   Gi_0058 = Ii_0010;
   Gd_0059 = 0;
   if (Ii_0010 == Ii_0000) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0004) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0008) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_000C) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0010) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0014) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0018) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_001C) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0020) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0024) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0028) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_002C) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0030) { 
   Gd_0059 = 0;
   } 
   if (Gi_0058 == Ii_0034) { 
   Gd_0059 = 0;
   } 
   returned_double = NormalizeDouble(Gd_0059, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_005A = (int)(returned_double + 10);
   Gl_005B = OrderOpenTime();
   Gi_005C = 0;
   Gi_005D = 0;
   Gi_0140 = Gi_005A + 10;
   if (Gi_0140 > 0) { 
   do { 
   if (Gl_005B < Time[Gi_005D]) { 
   Gi_005C = Gi_005C + 1;
   } 
   Gi_005D = Gi_005D + 1;
   Gi_0141 = Gi_005A + 10;
   } while (Gi_005D < Gi_0141); 
   } 
   if ((Gi_005C >= Ld_FFF8)) { 
   tmp_str0290 = "";
   tmp_str0291 = "";
   tmp_str0292 = "";
   tmp_str0293 = "";
   tmp_str0294 = "";
   tmp_str0295 = "";
   tmp_str0296 = (string)Fa_i_00;
   tmp_str0297 = ", Magic Number: ";
   tmp_str0298 = (string)OrderTicket();
   tmp_str0299 = "bars - closing order with ticket: ";
   tmp_str029A = (string)Ld_FFF8;
   tmp_str029B = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str029C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str029C, " ", tmp_str029B, tmp_str029A, tmp_str0299, tmp_str0298, tmp_str0297, tmp_str0296, tmp_str0295, tmp_str0294, tmp_str0293, tmp_str0292, tmp_str0291, tmp_str0290);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_005E = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_005E > 0) { 
   FileSeek(Gi_005E, 0, 2);
   tmp_str029D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_005E, tmp_str029D, " VERBOSE: ", tmp_str029B, tmp_str029A, tmp_str0299, tmp_str0298, tmp_str0297, tmp_str0296, tmp_str0295, tmp_str0294, tmp_str0293, tmp_str0292, tmp_str0291, tmp_str0290);
   FileClose(Gi_005E);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0014) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0014, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_005F = Ii_0014;
   Gd_0060 = 0;
   if (Ii_0014 == Ii_0000) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0004) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0008) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_000C) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0010) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0014) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0018) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_001C) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0020) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0024) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0028) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_002C) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0030) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   if (Gi_005F == Ii_0034) { 
   Gd_0060 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0060, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str029E = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str029E != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str02A0 = "";
   tmp_str02A1 = "";
   tmp_str02A2 = "";
   tmp_str02A3 = "";
   tmp_str02A4 = "";
   tmp_str02A5 = "";
   tmp_str02A6 = (string)Ld_FFE8;
   tmp_str02A7 = " to :";
   tmp_str02A8 = (string)Fa_i_00;
   tmp_str02A9 = ", Magic Number: ";
   tmp_str02AA = (string)OrderTicket();
   tmp_str02AB = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str02AC = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str02AC, " ", tmp_str02AB, tmp_str02AA, tmp_str02A9, tmp_str02A8, tmp_str02A7, tmp_str02A6, tmp_str02A5, tmp_str02A4, tmp_str02A3, tmp_str02A2, tmp_str02A1, tmp_str02A0);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0061 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0061 > 0) { 
   FileSeek(Gi_0061, 0, 2);
   tmp_str02AD = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0061, tmp_str02AD, " VERBOSE: ", tmp_str02AB, tmp_str02AA, tmp_str02A9, tmp_str02A8, tmp_str02A7, tmp_str02A6, tmp_str02A5, tmp_str02A4, tmp_str02A3, tmp_str02A2, tmp_str02A1, tmp_str02A0);
   FileClose(Gi_0061);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0144 = GetLastError();
   Li_FFDC = Gi_0144;
   tmp_str02AE = "";
   tmp_str02AF = "";
   tmp_str02B0 = "";
   tmp_str02B1 = "";
   tmp_str02B2 = "";
   tmp_str02B3 = "";
   tmp_str02B4 = "";
   tmp_str02B5 = "";
   tmp_str02B6 = ErrorDescription(Gi_0144);
   tmp_str02B7 = " - ";
   tmp_str02B8 = (string)(string)Gi_0144;
   tmp_str02B9 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str02BA = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str02BA, " ", tmp_str02B9, tmp_str02B8, tmp_str02B7, tmp_str02B6, tmp_str02B5, tmp_str02B4, tmp_str02B3, tmp_str02B2, tmp_str02B1, tmp_str02B0, tmp_str02AF, tmp_str02AE);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0062 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0062 > 0) {
   FileSeek(Gi_0062, 0, 2);
   tmp_str02BB = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0062, tmp_str02BB, " VERBOSE: ", tmp_str02B9, tmp_str02B8, tmp_str02B7, tmp_str02B6, tmp_str02B5, tmp_str02B4, tmp_str02B3, tmp_str02B2, tmp_str02B1, tmp_str02B0, tmp_str02AF, tmp_str02AE);
   FileClose(Gi_0062);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str02BC = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str02BC != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str02BE = "";
   tmp_str02BF = "";
   tmp_str02C0 = "";
   tmp_str02C1 = "";
   tmp_str02C2 = "";
   tmp_str02C3 = "";
   tmp_str02C4 = (string)Ld_FFE8;
   tmp_str02C5 = " to :";
   tmp_str02C6 = (string)Fa_i_00;
   tmp_str02C7 = ", Magic Number: ";
   tmp_str02C8 = (string)OrderTicket();
   tmp_str02C9 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str02CA = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str02CA, " ", tmp_str02C9, tmp_str02C8, tmp_str02C7, tmp_str02C6, tmp_str02C5, tmp_str02C4, tmp_str02C3, tmp_str02C2, tmp_str02C1, tmp_str02C0, tmp_str02BF, tmp_str02BE);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0063 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0063 > 0) { 
   FileSeek(Gi_0063, 0, 2);
   tmp_str02CB = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0063, tmp_str02CB, " VERBOSE: ", tmp_str02C9, tmp_str02C8, tmp_str02C7, tmp_str02C6, tmp_str02C5, tmp_str02C4, tmp_str02C3, tmp_str02C2, tmp_str02C1, tmp_str02C0, tmp_str02BF, tmp_str02BE);
   FileClose(Gi_0063);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0146 = GetLastError();
   Li_FFDC = Gi_0146;
   tmp_str02CC = "";
   tmp_str02CD = "";
   tmp_str02CE = (string)OrderStopLoss();
   tmp_str02CF = " Current SL: ";
   tmp_str02D0 = (string)Bid;
   tmp_str02D1 = ", Bid: ";
   tmp_str02D2 = (string)Ask;
   tmp_str02D3 = ", Ask: ";
   tmp_str02D4 = ErrorDescription(Gi_0146);
   tmp_str02D5 = " - ";
   tmp_str02D6 = (string)Gi_0146;
   tmp_str02D7 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str02D8 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str02D8, " ", tmp_str02D7, tmp_str02D6, tmp_str02D5, tmp_str02D4, tmp_str02D3, tmp_str02D2, tmp_str02D1, tmp_str02D0, tmp_str02CF, tmp_str02CE, tmp_str02CD, tmp_str02CC);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0064 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0064 > 0) { 
   FileSeek(Gi_0064, 0, 2);
   tmp_str02D9 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0064, tmp_str02D9, " VERBOSE: ", tmp_str02D7, tmp_str02D6, tmp_str02D5, tmp_str02D4, tmp_str02D3, tmp_str02D2, tmp_str02D1, tmp_str02D0, tmp_str02CF, tmp_str02CE, tmp_str02CD, tmp_str02CC);
   FileClose(Gi_0064);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0014, OrderType(), OrderOpenPrice());
   Gi_0065 = Ii_0014;
   Gd_0066 = 0;
   if (Ii_0014 == Ii_0000) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0004) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0008) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_000C) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0010) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0014) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0018) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_001C) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0020) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0024) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0028) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_002C) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0030) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   if (Gi_0065 == Ii_0034) { 
   Gd_0066 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0066, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str02DA = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str02DA != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str02DC = "";
   tmp_str02DD = "";
   tmp_str02DE = "";
   tmp_str02DF = "";
   tmp_str02E0 = "";
   tmp_str02E1 = "";
   tmp_str02E2 = (string)Ld_FFE8;
   tmp_str02E3 = " to :";
   tmp_str02E4 = (string)Fa_i_00;
   tmp_str02E5 = ", Magic Number: ";
   tmp_str02E6 = (string)OrderTicket();
   tmp_str02E7 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str02E8 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str02E8, " ", tmp_str02E7, tmp_str02E6, tmp_str02E5, tmp_str02E4, tmp_str02E3, tmp_str02E2, tmp_str02E1, tmp_str02E0, tmp_str02DF, tmp_str02DE, tmp_str02DD, tmp_str02DC);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0067 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0067 > 0) { 
   FileSeek(Gi_0067, 0, 2);
   tmp_str02E9 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0067, tmp_str02E9, " VERBOSE: ", tmp_str02E7, tmp_str02E6, tmp_str02E5, tmp_str02E4, tmp_str02E3, tmp_str02E2, tmp_str02E1, tmp_str02E0, tmp_str02DF, tmp_str02DE, tmp_str02DD, tmp_str02DC);
   FileClose(Gi_0067);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0149 = GetLastError();
   Li_FFDC = Gi_0149;
   tmp_str02EA = "";
   tmp_str02EB = "";
   tmp_str02EC = (string)OrderStopLoss();
   tmp_str02ED = " Current SL: ";
   tmp_str02EE = (string)Bid;
   tmp_str02EF = ", Bid: ";
   tmp_str02F0 = (string)Ask;
   tmp_str02F1 = ", Ask: ";
   tmp_str02F2 = ErrorDescription(Gi_0149);
   tmp_str02F3 = " - ";
   tmp_str02F4 = (string)Gi_0149;
   tmp_str02F5 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str02F6 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str02F6, " ", tmp_str02F5, tmp_str02F4, tmp_str02F3, tmp_str02F2, tmp_str02F1, tmp_str02F0, tmp_str02EF, tmp_str02EE, tmp_str02ED, tmp_str02EC, tmp_str02EB, tmp_str02EA);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0068 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0068 > 0) {
   FileSeek(Gi_0068, 0, 2);
   tmp_str02F7 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0068, tmp_str02F7, " VERBOSE: ", tmp_str02F5, tmp_str02F4, tmp_str02F3, tmp_str02F2, tmp_str02F1, tmp_str02F0, tmp_str02EF, tmp_str02EE, tmp_str02ED, tmp_str02EC, tmp_str02EB, tmp_str02EA);
   FileClose(Gi_0068);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str02F8 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str02F8 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str02FA = "";
   tmp_str02FB = "";
   tmp_str02FC = "";
   tmp_str02FD = "";
   tmp_str02FE = "";
   tmp_str02FF = "";
   tmp_str0300 = (string)Ld_FFE8;
   tmp_str0301 = " to :";
   tmp_str0302 = (string)Fa_i_00;
   tmp_str0303 = ", Magic Number: ";
   tmp_str0304 = (string)OrderTicket();
   tmp_str0305 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0306 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0306, " ", tmp_str0305, tmp_str0304, tmp_str0303, tmp_str0302, tmp_str0301, tmp_str0300, tmp_str02FF, tmp_str02FE, tmp_str02FD, tmp_str02FC, tmp_str02FB, tmp_str02FA);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0069 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0069 > 0) { 
   FileSeek(Gi_0069, 0, 2);
   tmp_str0307 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0069, tmp_str0307, " VERBOSE: ", tmp_str0305, tmp_str0304, tmp_str0303, tmp_str0302, tmp_str0301, tmp_str0300, tmp_str02FF, tmp_str02FE, tmp_str02FD, tmp_str02FC, tmp_str02FB, tmp_str02FA);
   FileClose(Gi_0069);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_014B = GetLastError();
   Li_FFDC = Gi_014B;
   tmp_str0308 = "";
   tmp_str0309 = "";
   tmp_str030A = (string)OrderStopLoss();
   tmp_str030B = " Current SL: ";
   tmp_str030C = (string)Bid;
   tmp_str030D = ", Bid: ";
   tmp_str030E = (string)Ask;
   tmp_str030F = ", Ask: ";
   tmp_str0310 = ErrorDescription(Gi_014B);
   tmp_str0311 = " - ";
   tmp_str0312 = (string)Gi_014B;
   tmp_str0313 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0314 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0314, " ", tmp_str0313, tmp_str0312, tmp_str0311, tmp_str0310, tmp_str030F, tmp_str030E, tmp_str030D, tmp_str030C, tmp_str030B, tmp_str030A, tmp_str0309, tmp_str0308);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_006A = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_006A > 0) { 
   FileSeek(Gi_006A, 0, 2);
   tmp_str0315 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_006A, tmp_str0315, " VERBOSE: ", tmp_str0313, tmp_str0312, tmp_str0311, tmp_str0310, tmp_str030F, tmp_str030E, tmp_str030D, tmp_str030C, tmp_str030B, tmp_str030A, tmp_str0309, tmp_str0308);
   FileClose(Gi_006A);
   }}}}}}}}} 
   Gi_006B = Ii_0014;
   Gd_006C = 0;
   if (Ii_0014 == Ii_0000) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0004) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0008) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_000C) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0010) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0014) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0018) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_001C) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0020) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0024) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0028) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_002C) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0030) { 
   Gd_006C = 0;
   } 
   if (Gi_006B == Ii_0034) { 
   Gd_006C = 0;
   } 
   returned_double = NormalizeDouble(Gd_006C, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_006D = (int)(returned_double + 10);
   Gl_006E = OrderOpenTime();
   Gi_006F = 0;
   Gi_0070 = 0;
   Gi_014B = Gi_006D + 10;
   if (Gi_014B > 0) { 
   do { 
   if (Gl_006E < Time[Gi_0070]) { 
   Gi_006F = Gi_006F + 1;
   } 
   Gi_0070 = Gi_0070 + 1;
   Gi_014C = Gi_006D + 10;
   } while (Gi_0070 < Gi_014C); 
   } 
   if ((Gi_006F >= Ld_FFF8)) { 
   tmp_str0316 = "";
   tmp_str0317 = "";
   tmp_str0318 = "";
   tmp_str0319 = "";
   tmp_str031A = "";
   tmp_str031B = "";
   tmp_str031C = (string)Fa_i_00;
   tmp_str031D = ", Magic Number: ";
   tmp_str031E = (string)OrderTicket();
   tmp_str031F = "bars - closing order with ticket: ";
   tmp_str0320 = (string)Ld_FFF8;
   tmp_str0321 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str0322 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0322, " ", tmp_str0321, tmp_str0320, tmp_str031F, tmp_str031E, tmp_str031D, tmp_str031C, tmp_str031B, tmp_str031A, tmp_str0319, tmp_str0318, tmp_str0317, tmp_str0316);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0071 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0071 > 0) { 
   FileSeek(Gi_0071, 0, 2);
   tmp_str0323 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0071, tmp_str0323, " VERBOSE: ", tmp_str0321, tmp_str0320, tmp_str031F, tmp_str031E, tmp_str031D, tmp_str031C, tmp_str031B, tmp_str031A, tmp_str0319, tmp_str0318, tmp_str0317, tmp_str0316);
   FileClose(Gi_0071);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0018) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0018, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_0072 = Ii_0018;
   Gd_0073 = 0;
   if (Ii_0018 == Ii_0000) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0004) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0008) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_000C) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0010) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0014) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0018) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_001C) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0020) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0024) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0028) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_002C) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0030) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   if (Gi_0072 == Ii_0034) { 
   Gd_0073 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0073, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str0324 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0324 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0326 = "";
   tmp_str0327 = "";
   tmp_str0328 = "";
   tmp_str0329 = "";
   tmp_str032A = "";
   tmp_str032B = "";
   tmp_str032C = (string)Ld_FFE8;
   tmp_str032D = " to :";
   tmp_str032E = (string)Fa_i_00;
   tmp_str032F = ", Magic Number: ";
   tmp_str0330 = (string)OrderTicket();
   tmp_str0331 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0332 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0332, " ", tmp_str0331, tmp_str0330, tmp_str032F, tmp_str032E, tmp_str032D, tmp_str032C, tmp_str032B, tmp_str032A, tmp_str0329, tmp_str0328, tmp_str0327, tmp_str0326);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0074 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0074 > 0) { 
   FileSeek(Gi_0074, 0, 2);
   tmp_str0333 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0074, tmp_str0333, " VERBOSE: ", tmp_str0331, tmp_str0330, tmp_str032F, tmp_str032E, tmp_str032D, tmp_str032C, tmp_str032B, tmp_str032A, tmp_str0329, tmp_str0328, tmp_str0327, tmp_str0326);
   FileClose(Gi_0074);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_014F = GetLastError();
   Li_FFDC = Gi_014F;
   tmp_str0334 = "";
   tmp_str0335 = "";
   tmp_str0336 = "";
   tmp_str0337 = "";
   tmp_str0338 = "";
   tmp_str0339 = "";
   tmp_str033A = "";
   tmp_str033B = "";
   tmp_str033C = ErrorDescription(Gi_014F);
   tmp_str033D = " - ";
   tmp_str033E = (string)Gi_014F;
   tmp_str033F = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0340 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0340, " ", tmp_str033F, tmp_str033E, tmp_str033D, tmp_str033C, tmp_str033B, tmp_str033A, tmp_str0339, tmp_str0338, tmp_str0337, tmp_str0336, tmp_str0335, tmp_str0334);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0075 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0075 > 0) {
   FileSeek(Gi_0075, 0, 2);
   tmp_str0341 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0075, tmp_str0341, " VERBOSE: ", tmp_str033F, tmp_str033E, tmp_str033D, tmp_str033C, tmp_str033B, tmp_str033A, tmp_str0339, tmp_str0338, tmp_str0337, tmp_str0336, tmp_str0335, tmp_str0334);
   FileClose(Gi_0075);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str0342 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0342 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0344 = "";
   tmp_str0345 = "";
   tmp_str0346 = "";
   tmp_str0347 = "";
   tmp_str0348 = "";
   tmp_str0349 = "";
   tmp_str034A = (string)Ld_FFE8;
   tmp_str034B = " to :";
   tmp_str034C = (string)(string)Fa_i_00;
   tmp_str034D = ", Magic Number: ";
   tmp_str034E = (string)OrderTicket();
   tmp_str034F = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0350 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0350, " ", tmp_str034F, tmp_str034E, tmp_str034D, tmp_str034C, tmp_str034B, tmp_str034A, tmp_str0349, tmp_str0348, tmp_str0347, tmp_str0346, tmp_str0345, tmp_str0344);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0076 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0076 > 0) { 
   FileSeek(Gi_0076, 0, 2);
   tmp_str0351 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0076, tmp_str0351, " VERBOSE: ", tmp_str034F, tmp_str034E, tmp_str034D, tmp_str034C, tmp_str034B, tmp_str034A, tmp_str0349, tmp_str0348, tmp_str0347, tmp_str0346, tmp_str0345, tmp_str0344);
   FileClose(Gi_0076);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0151 = GetLastError();
   Li_FFDC = Gi_0151;
   tmp_str0352 = "";
   tmp_str0353 = "";
   tmp_str0354 = (string)OrderStopLoss();
   tmp_str0355 = " Current SL: ";
   tmp_str0356 = (string)Bid;
   tmp_str0357 = ", Bid: ";
   tmp_str0358 = (string)Ask;
   tmp_str0359 = ", Ask: ";
   tmp_str035A = ErrorDescription(Gi_0151);
   tmp_str035B = " - ";
   tmp_str035C = (string)Gi_0151;
   tmp_str035D = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str035E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str035E, " ", tmp_str035D, tmp_str035C, tmp_str035B, tmp_str035A, tmp_str0359, tmp_str0358, tmp_str0357, tmp_str0356, tmp_str0355, tmp_str0354, tmp_str0353, tmp_str0352);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0077 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0077 > 0) { 
   FileSeek(Gi_0077, 0, 2);
   tmp_str035F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0077, tmp_str035F, " VERBOSE: ", tmp_str035D, tmp_str035C, tmp_str035B, tmp_str035A, tmp_str0359, tmp_str0358, tmp_str0357, tmp_str0356, tmp_str0355, tmp_str0354, tmp_str0353, tmp_str0352);
   FileClose(Gi_0077);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0018, OrderType(), OrderOpenPrice());
   Gi_0078 = Ii_0018;
   Gd_0079 = 0;
   if (Ii_0018 == Ii_0000) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0004) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0008) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_000C) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0010) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0014) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0018) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_001C) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0020) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0024) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0028) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_002C) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0030) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   if (Gi_0078 == Ii_0034) { 
   Gd_0079 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0079, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str0360 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0360 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0362 = "";
   tmp_str0363 = "";
   tmp_str0364 = "";
   tmp_str0365 = "";
   tmp_str0366 = "";
   tmp_str0367 = "";
   tmp_str0368 = (string)Ld_FFE8;
   tmp_str0369 = " to :";
   tmp_str036A = (string)Fa_i_00;
   tmp_str036B = ", Magic Number: ";
   tmp_str036C = (string)OrderTicket();
   tmp_str036D = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str036E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str036E, " ", tmp_str036D, tmp_str036C, tmp_str036B, tmp_str036A, tmp_str0369, tmp_str0368, tmp_str0367, tmp_str0366, tmp_str0365, tmp_str0364, tmp_str0363, tmp_str0362);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_007A = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_007A > 0) { 
   FileSeek(Gi_007A, 0, 2);
   tmp_str036F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_007A, tmp_str036F, " VERBOSE: ", tmp_str036D, tmp_str036C, tmp_str036B, tmp_str036A, tmp_str0369, tmp_str0368, tmp_str0367, tmp_str0366, tmp_str0365, tmp_str0364, tmp_str0363, tmp_str0362);
   FileClose(Gi_007A);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0154 = GetLastError();
   Li_FFDC = Gi_0154;
   tmp_str0370 = "";
   tmp_str0371 = "";
   tmp_str0372 = (string)OrderStopLoss();
   tmp_str0373 = " Current SL: ";
   tmp_str0374 = (string)Bid;
   tmp_str0375 = ", Bid: ";
   tmp_str0376 = (string)Ask;
   tmp_str0377 = ", Ask: ";
   tmp_str0378 = ErrorDescription(Gi_0154);
   tmp_str0379 = " - ";
   tmp_str037A = (string)Gi_0154;
   tmp_str037B = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str037C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str037C, " ", tmp_str037B, tmp_str037A, tmp_str0379, tmp_str0378, tmp_str0377, tmp_str0376, tmp_str0375, tmp_str0374, tmp_str0373, tmp_str0372, tmp_str0371, tmp_str0370);
   }
   else{
   if (Ii_007C == 2) {
   Gi_007B = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_007B > 0) {
   FileSeek(Gi_007B, 0, 2);
   tmp_str037D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_007B, tmp_str037D, " VERBOSE: ", tmp_str037B, tmp_str037A, tmp_str0379, tmp_str0378, tmp_str0377, tmp_str0376, tmp_str0375, tmp_str0374, tmp_str0373, tmp_str0372, tmp_str0371, tmp_str0370);
   FileClose(Gi_007B);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str037E = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str037E != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0380 = "";
   tmp_str0381 = "";
   tmp_str0382 = "";
   tmp_str0383 = "";
   tmp_str0384 = "";
   tmp_str0385 = "";
   tmp_str0386 = (string)Ld_FFE8;
   tmp_str0387 = " to :";
   tmp_str0388 = (string)Fa_i_00;
   tmp_str0389 = ", Magic Number: ";
   tmp_str038A = (string)OrderTicket();
   tmp_str038B = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str038C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str038C, " ", tmp_str038B, tmp_str038A, tmp_str0389, tmp_str0388, tmp_str0387, tmp_str0386, tmp_str0385, tmp_str0384, tmp_str0383, tmp_str0382, tmp_str0381, tmp_str0380);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_007C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_007C > 0) { 
   FileSeek(Gi_007C, 0, 2);
   tmp_str038D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_007C, tmp_str038D, " VERBOSE: ", tmp_str038B, tmp_str038A, tmp_str0389, tmp_str0388, tmp_str0387, tmp_str0386, tmp_str0385, tmp_str0384, tmp_str0383, tmp_str0382, tmp_str0381, tmp_str0380);
   FileClose(Gi_007C);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0156 = GetLastError();
   Li_FFDC = Gi_0156;
   tmp_str038E = "";
   tmp_str038F = "";
   tmp_str0390 = (string)(string)(string)OrderStopLoss();
   tmp_str0391 = " Current SL: ";
   tmp_str0392 = (string)Bid;
   tmp_str0393 = ", Bid: ";
   tmp_str0394 = (string)Ask;
   tmp_str0395 = ", Ask: ";
   tmp_str0396 = ErrorDescription(Gi_0156);
   tmp_str0397 = " - ";
   tmp_str0398 = (string)Gi_0156;
   tmp_str0399 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str039A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str039A, " ", tmp_str0399, tmp_str0398, tmp_str0397, tmp_str0396, tmp_str0395, tmp_str0394, tmp_str0393, tmp_str0392, tmp_str0391, tmp_str0390, tmp_str038F, tmp_str038E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_007D = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_007D > 0) { 
   FileSeek(Gi_007D, 0, 2);
   tmp_str039B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_007D, tmp_str039B, " VERBOSE: ", tmp_str0399, tmp_str0398, tmp_str0397, tmp_str0396, tmp_str0395, tmp_str0394, tmp_str0393, tmp_str0392, tmp_str0391, tmp_str0390, tmp_str038F, tmp_str038E);
   FileClose(Gi_007D);
   }}}}}}}}} 
   Gi_007E = Ii_0018;
   Gd_007F = 0;
   if (Ii_0018 == Ii_0000) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0004) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0008) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_000C) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0010) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0014) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0018) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_001C) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0020) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0024) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0028) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_002C) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0030) { 
   Gd_007F = 0;
   } 
   if (Gi_007E == Ii_0034) { 
   Gd_007F = 0;
   } 
   returned_double = NormalizeDouble(Gd_007F, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_0080 = (int)(returned_double + 10);
   Gl_0081 = OrderOpenTime();
   Gi_0082 = 0;
   Gi_0083 = 0;
   Gi_0156 = Gi_0080 + 10;
   if (Gi_0156 > 0) { 
   do { 
   if (Gl_0081 < Time[Gi_0083]) { 
   Gi_0082 = Gi_0082 + 1;
   } 
   Gi_0083 = Gi_0083 + 1;
   Gi_0157 = Gi_0080 + 10;
   } while (Gi_0083 < Gi_0157); 
   } 
   if ((Gi_0082 >= Ld_FFF8)) { 
   tmp_str039C = "";
   tmp_str039D = "";
   tmp_str039E = "";
   tmp_str039F = "";
   tmp_str03A0 = "";
   tmp_str03A1 = "";
   tmp_str03A2 = (string)(string)Fa_i_00;
   tmp_str03A3 = ", Magic Number: ";
   tmp_str03A4 = (string)OrderTicket();
   tmp_str03A5 = "bars - closing order with ticket: ";
   tmp_str03A6 = (string)Ld_FFF8;
   tmp_str03A7 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str03A8 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str03A8, " ", tmp_str03A7, tmp_str03A6, tmp_str03A5, tmp_str03A4, tmp_str03A3, tmp_str03A2, tmp_str03A1, tmp_str03A0, tmp_str039F, tmp_str039E, tmp_str039D, tmp_str039C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0084 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0084 > 0) { 
   FileSeek(Gi_0084, 0, 2);
   tmp_str03A9 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0084, tmp_str03A9, " VERBOSE: ", tmp_str03A7, tmp_str03A6, tmp_str03A5, tmp_str03A4, tmp_str03A3, tmp_str03A2, tmp_str03A1, tmp_str03A0, tmp_str039F, tmp_str039E, tmp_str039D, tmp_str039C);
   FileClose(Gi_0084);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_001C) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_001C, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_0085 = Ii_001C;
   Gd_0086 = 0;
   if (Ii_001C == Ii_0000) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0004) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0008) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_000C) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0010) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0014) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0018) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_001C) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0020) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0024) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0028) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_002C) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0030) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   if (Gi_0085 == Ii_0034) { 
   Gd_0086 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0086, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str03AA = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str03AA != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str03AC = "";
   tmp_str03AD = "";
   tmp_str03AE = "";
   tmp_str03AF = "";
   tmp_str03B0 = "";
   tmp_str03B1 = "";
   tmp_str03B2 = (string)Ld_FFE8;
   tmp_str03B3 = " to :";
   tmp_str03B4 = (string)Fa_i_00;
   tmp_str03B5 = ", Magic Number: ";
   tmp_str03B6 = (string)OrderTicket();
   tmp_str03B7 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str03B8 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str03B8, " ", tmp_str03B7, tmp_str03B6, tmp_str03B5, tmp_str03B4, tmp_str03B3, tmp_str03B2, tmp_str03B1, tmp_str03B0, tmp_str03AF, tmp_str03AE, tmp_str03AD, tmp_str03AC);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0087 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0087 > 0) { 
   FileSeek(Gi_0087, 0, 2);
   tmp_str03B9 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0087, tmp_str03B9, " VERBOSE: ", tmp_str03B7, tmp_str03B6, tmp_str03B5, tmp_str03B4, tmp_str03B3, tmp_str03B2, tmp_str03B1, tmp_str03B0, tmp_str03AF, tmp_str03AE, tmp_str03AD, tmp_str03AC);
   FileClose(Gi_0087);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_015A = GetLastError();
   Li_FFDC = Gi_015A;
   tmp_str03BA = "";
   tmp_str03BB = "";
   tmp_str03BC = "";
   tmp_str03BD = "";
   tmp_str03BE = "";
   tmp_str03BF = "";
   tmp_str03C0 = "";
   tmp_str03C1 = "";
   tmp_str03C2 = ErrorDescription(Gi_015A);
   tmp_str03C3 = " - ";
   tmp_str03C4 = (string)Gi_015A;
   tmp_str03C5 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str03C6 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str03C6, " ", tmp_str03C5, tmp_str03C4, tmp_str03C3, tmp_str03C2, tmp_str03C1, tmp_str03C0, tmp_str03BF, tmp_str03BE, tmp_str03BD, tmp_str03BC, tmp_str03BB, tmp_str03BA);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0088 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0088 > 0) {
   FileSeek(Gi_0088, 0, 2);
   tmp_str03C7 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0088, tmp_str03C7, " VERBOSE: ", tmp_str03C5, tmp_str03C4, tmp_str03C3, tmp_str03C2, tmp_str03C1, tmp_str03C0, tmp_str03BF, tmp_str03BE, tmp_str03BD, tmp_str03BC, tmp_str03BB, tmp_str03BA);
   FileClose(Gi_0088);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str03C8 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str03C8 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str03CA = "";
   tmp_str03CB = "";
   tmp_str03CC = "";
   tmp_str03CD = "";
   tmp_str03CE = "";
   tmp_str03CF = "";
   tmp_str03D0 = (string)Ld_FFE8;
   tmp_str03D1 = " to :";
   tmp_str03D2 = (string)Fa_i_00;
   tmp_str03D3 = ", Magic Number: ";
   tmp_str03D4 = (string)OrderTicket();
   tmp_str03D5 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str03D6 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str03D6, " ", tmp_str03D5, tmp_str03D4, tmp_str03D3, tmp_str03D2, tmp_str03D1, tmp_str03D0, tmp_str03CF, tmp_str03CE, tmp_str03CD, tmp_str03CC, tmp_str03CB, tmp_str03CA);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0089 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0089 > 0) { 
   FileSeek(Gi_0089, 0, 2);
   tmp_str03D7 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0089, tmp_str03D7, " VERBOSE: ", tmp_str03D5, tmp_str03D4, tmp_str03D3, tmp_str03D2, tmp_str03D1, tmp_str03D0, tmp_str03CF, tmp_str03CE, tmp_str03CD, tmp_str03CC, tmp_str03CB, tmp_str03CA);
   FileClose(Gi_0089);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_015C = GetLastError();
   Li_FFDC = Gi_015C;
   tmp_str03D8 = "";
   tmp_str03D9 = "";
   tmp_str03DA = (string)OrderStopLoss();
   tmp_str03DB = " Current SL: ";
   tmp_str03DC = (string)Bid;
   tmp_str03DD = ", Bid: ";
   tmp_str03DE = (string)Ask;
   tmp_str03DF = ", Ask: ";
   tmp_str03E0 = ErrorDescription(Gi_015C);
   tmp_str03E1 = " - ";
   tmp_str03E2 = (string)Gi_015C;
   tmp_str03E3 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str03E4 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str03E4, " ", tmp_str03E3, tmp_str03E2, tmp_str03E1, tmp_str03E0, tmp_str03DF, tmp_str03DE, tmp_str03DD, tmp_str03DC, tmp_str03DB, tmp_str03DA, tmp_str03D9, tmp_str03D8);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_008A = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_008A > 0) { 
   FileSeek(Gi_008A, 0, 2);
   tmp_str03E5 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_008A, tmp_str03E5, " VERBOSE: ", tmp_str03E3, tmp_str03E2, tmp_str03E1, tmp_str03E0, tmp_str03DF, tmp_str03DE, tmp_str03DD, tmp_str03DC, tmp_str03DB, tmp_str03DA, tmp_str03D9, tmp_str03D8);
   FileClose(Gi_008A);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_001C, OrderType(), OrderOpenPrice());
   Gi_008B = Ii_001C;
   Gd_008C = 0;
   if (Ii_001C == Ii_0000) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0004) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0008) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_000C) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0010) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0014) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0018) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_001C) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0020) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0024) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0028) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_002C) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0030) { 
   Gd_008C = (Id_0090 * 0);
   } 
   if (Gi_008B == Ii_0034) { 
   Gd_008C = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_008C, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str03E6 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str03E6 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str03E8 = "";
   tmp_str03E9 = "";
   tmp_str03EA = "";
   tmp_str03EB = "";
   tmp_str03EC = "";
   tmp_str03ED = "";
   tmp_str03EE = (string)Ld_FFE8;
   tmp_str03EF = " to :";
   tmp_str03F0 = (string)Fa_i_00;
   tmp_str03F1 = ", Magic Number: ";
   tmp_str03F2 = (string)OrderTicket();
   tmp_str03F3 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str03F4 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str03F4, " ", tmp_str03F3, tmp_str03F2, tmp_str03F1, tmp_str03F0, tmp_str03EF, tmp_str03EE, tmp_str03ED, tmp_str03EC, tmp_str03EB, tmp_str03EA, tmp_str03E9, tmp_str03E8);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_008D = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_008D > 0) { 
   FileSeek(Gi_008D, 0, 2);
   tmp_str03F5 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_008D, tmp_str03F5, " VERBOSE: ", tmp_str03F3, tmp_str03F2, tmp_str03F1, tmp_str03F0, tmp_str03EF, tmp_str03EE, tmp_str03ED, tmp_str03EC, tmp_str03EB, tmp_str03EA, tmp_str03E9, tmp_str03E8);
   FileClose(Gi_008D);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_015F = GetLastError();
   Li_FFDC = Gi_015F;
   tmp_str03F6 = "";
   tmp_str03F7 = "";
   tmp_str03F8 = (string)OrderStopLoss();
   tmp_str03F9 = " Current SL: ";
   tmp_str03FA = (string)Bid;
   tmp_str03FB = ", Bid: ";
   tmp_str03FC = (string)Ask;
   tmp_str03FD = ", Ask: ";
   tmp_str03FE = ErrorDescription(Gi_015F);
   tmp_str03FF = " - ";
   tmp_str0400 = (string)Gi_015F;
   tmp_str0401 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0402 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0402, " ", tmp_str0401, tmp_str0400, tmp_str03FF, tmp_str03FE, tmp_str03FD, tmp_str03FC, tmp_str03FB, tmp_str03FA, tmp_str03F9, tmp_str03F8, tmp_str03F7, tmp_str03F6);
   }
   else{
   if (Ii_007C == 2) {
   Gi_008E = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_008E > 0) {
   FileSeek(Gi_008E, 0, 2);
   tmp_str0403 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_008E, tmp_str0403, " VERBOSE: ", tmp_str0401, tmp_str0400, tmp_str03FF, tmp_str03FE, tmp_str03FD, tmp_str03FC, tmp_str03FB, tmp_str03FA, tmp_str03F9, tmp_str03F8, tmp_str03F7, tmp_str03F6);
   FileClose(Gi_008E);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str0404 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0404 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0406 = "";
   tmp_str0407 = "";
   tmp_str0408 = "";
   tmp_str0409 = "";
   tmp_str040A = "";
   tmp_str040B = "";
   tmp_str040C = (string)Ld_FFE8;
   tmp_str040D = " to :";
   tmp_str040E = (string)Fa_i_00;
   tmp_str040F = ", Magic Number: ";
   tmp_str0410 = (string)OrderTicket();
   tmp_str0411 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0412 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0412, " ", tmp_str0411, tmp_str0410, tmp_str040F, tmp_str040E, tmp_str040D, tmp_str040C, tmp_str040B, tmp_str040A, tmp_str0409, tmp_str0408, tmp_str0407, tmp_str0406);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_008F = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_008F > 0) { 
   FileSeek(Gi_008F, 0, 2);
   tmp_str0413 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_008F, tmp_str0413, " VERBOSE: ", tmp_str0411, tmp_str0410, tmp_str040F, tmp_str040E, tmp_str040D, tmp_str040C, tmp_str040B, tmp_str040A, tmp_str0409, tmp_str0408, tmp_str0407, tmp_str0406);
   FileClose(Gi_008F);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0161 = GetLastError();
   Li_FFDC = Gi_0161;
   tmp_str0414 = "";
   tmp_str0415 = "";
   tmp_str0416 = (string)OrderStopLoss();
   tmp_str0417 = " Current SL: ";
   tmp_str0418 = (string)Bid;
   tmp_str0419 = ", Bid: ";
   tmp_str041A = (string)(string)Ask;
   tmp_str041B = ", Ask: ";
   tmp_str041C = ErrorDescription(Gi_0161);
   tmp_str041D = " - ";
   tmp_str041E = (string)Gi_0161;
   tmp_str041F = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0420 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0420, " ", tmp_str041F, tmp_str041E, tmp_str041D, tmp_str041C, tmp_str041B, tmp_str041A, tmp_str0419, tmp_str0418, tmp_str0417, tmp_str0416, tmp_str0415, tmp_str0414);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0090 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0090 > 0) { 
   FileSeek(Gi_0090, 0, 2);
   tmp_str0421 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0090, tmp_str0421, " VERBOSE: ", tmp_str041F, tmp_str041E, tmp_str041D, tmp_str041C, tmp_str041B, tmp_str041A, tmp_str0419, tmp_str0418, tmp_str0417, tmp_str0416, tmp_str0415, tmp_str0414);
   FileClose(Gi_0090);
   }}}}}}}}} 
   Gi_0091 = Ii_001C;
   Gd_0092 = 0;
   if (Ii_001C == Ii_0000) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0004) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0008) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_000C) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0010) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0014) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0018) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_001C) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0020) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0024) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0028) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_002C) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0030) { 
   Gd_0092 = 0;
   } 
   if (Gi_0091 == Ii_0034) { 
   Gd_0092 = 0;
   } 
   returned_double = NormalizeDouble(Gd_0092, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_0093 = (int)(returned_double + 10);
   Gl_0094 = OrderOpenTime();
   Gi_0095 = 0;
   Gi_0096 = 0;
   Gi_0161 = Gi_0093 + 10;
   if (Gi_0161 > 0) { 
   do { 
   if (Gl_0094 < Time[Gi_0096]) { 
   Gi_0095 = Gi_0095 + 1;
   } 
   Gi_0096 = Gi_0096 + 1;
   Gi_0162 = Gi_0093 + 10;
   } while (Gi_0096 < Gi_0162); 
   } 
   if ((Gi_0095 >= Ld_FFF8)) { 
   tmp_str0422 = "";
   tmp_str0423 = "";
   tmp_str0424 = "";
   tmp_str0425 = "";
   tmp_str0426 = "";
   tmp_str0427 = "";
   tmp_str0428 = (string)Fa_i_00;
   tmp_str0429 = ", Magic Number: ";
   tmp_str042A = (string)OrderTicket();
   tmp_str042B = "bars - closing order with ticket: ";
   tmp_str042C = (string)Ld_FFF8;
   tmp_str042D = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str042E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str042E, " ", tmp_str042D, tmp_str042C, tmp_str042B, tmp_str042A, tmp_str0429, tmp_str0428, tmp_str0427, tmp_str0426, tmp_str0425, tmp_str0424, tmp_str0423, tmp_str0422);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0097 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0097 > 0) { 
   FileSeek(Gi_0097, 0, 2);
   tmp_str042F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0097, tmp_str042F, " VERBOSE: ", tmp_str042D, tmp_str042C, tmp_str042B, tmp_str042A, tmp_str0429, tmp_str0428, tmp_str0427, tmp_str0426, tmp_str0425, tmp_str0424, tmp_str0423, tmp_str0422);
   FileClose(Gi_0097);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0020) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0020, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_0098 = Ii_0020;
   Gd_0099 = 0;
   if (Ii_0020 == Ii_0000) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0004) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0008) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_000C) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0010) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0014) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0018) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_001C) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0020) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0024) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0028) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_002C) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0030) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   if (Gi_0098 == Ii_0034) { 
   Gd_0099 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_0099, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str0430 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0430 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0432 = "";
   tmp_str0433 = "";
   tmp_str0434 = "";
   tmp_str0435 = "";
   tmp_str0436 = "";
   tmp_str0437 = "";
   tmp_str0438 = (string)Ld_FFE8;
   tmp_str0439 = " to :";
   tmp_str043A = (string)Fa_i_00;
   tmp_str043B = ", Magic Number: ";
   tmp_str043C = (string)OrderTicket();
   tmp_str043D = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str043E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str043E, " ", tmp_str043D, tmp_str043C, tmp_str043B, tmp_str043A, tmp_str0439, tmp_str0438, tmp_str0437, tmp_str0436, tmp_str0435, tmp_str0434, tmp_str0433, tmp_str0432);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_009A = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_009A > 0) { 
   FileSeek(Gi_009A, 0, 2);
   tmp_str043F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_009A, tmp_str043F, " VERBOSE: ", tmp_str043D, tmp_str043C, tmp_str043B, tmp_str043A, tmp_str0439, tmp_str0438, tmp_str0437, tmp_str0436, tmp_str0435, tmp_str0434, tmp_str0433, tmp_str0432);
   FileClose(Gi_009A);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0165 = GetLastError();
   Li_FFDC = Gi_0165;
   tmp_str0440 = "";
   tmp_str0441 = "";
   tmp_str0442 = "";
   tmp_str0443 = "";
   tmp_str0444 = "";
   tmp_str0445 = "";
   tmp_str0446 = "";
   tmp_str0447 = "";
   tmp_str0448 = ErrorDescription(Gi_0165);
   tmp_str0449 = " - ";
   tmp_str044A = (string)Gi_0165;
   tmp_str044B = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str044C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str044C, " ", tmp_str044B, tmp_str044A, tmp_str0449, tmp_str0448, tmp_str0447, tmp_str0446, tmp_str0445, tmp_str0444, tmp_str0443, tmp_str0442, tmp_str0441, tmp_str0440);
   }
   else{
   if (Ii_007C == 2) {
   Gi_009B = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_009B > 0) {
   FileSeek(Gi_009B, 0, 2);
   tmp_str044D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_009B, tmp_str044D, " VERBOSE: ", tmp_str044B, tmp_str044A, tmp_str0449, tmp_str0448, tmp_str0447, tmp_str0446, tmp_str0445, tmp_str0444, tmp_str0443, tmp_str0442, tmp_str0441, tmp_str0440);
   FileClose(Gi_009B);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str044E = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str044E != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0450 = "";
   tmp_str0451 = "";
   tmp_str0452 = "";
   tmp_str0453 = "";
   tmp_str0454 = "";
   tmp_str0455 = "";
   tmp_str0456 = (string)Ld_FFE8;
   tmp_str0457 = " to :";
   tmp_str0458 = (string)Fa_i_00;
   tmp_str0459 = ", Magic Number: ";
   tmp_str045A = (string)OrderTicket();
   tmp_str045B = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str045C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str045C, " ", tmp_str045B, tmp_str045A, tmp_str0459, tmp_str0458, tmp_str0457, tmp_str0456, tmp_str0455, tmp_str0454, tmp_str0453, tmp_str0452, tmp_str0451, tmp_str0450);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_009C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_009C > 0) { 
   FileSeek(Gi_009C, 0, 2);
   tmp_str045D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_009C, tmp_str045D, " VERBOSE: ", tmp_str045B, tmp_str045A, tmp_str0459, tmp_str0458, tmp_str0457, tmp_str0456, tmp_str0455, tmp_str0454, tmp_str0453, tmp_str0452, tmp_str0451, tmp_str0450);
   FileClose(Gi_009C);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0167 = GetLastError();
   Li_FFDC = Gi_0167;
   tmp_str045E = "";
   tmp_str045F = "";
   tmp_str0460 = (string)OrderStopLoss();
   tmp_str0461 = " Current SL: ";
   tmp_str0462 = (string)Bid;
   tmp_str0463 = ", Bid: ";
   tmp_str0464 = (string)(string)Ask;
   tmp_str0465 = ", Ask: ";
   tmp_str0466 = ErrorDescription(Gi_0167);
   tmp_str0467 = " - ";
   tmp_str0468 = (string)Gi_0167;
   tmp_str0469 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str046A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str046A, " ", tmp_str0469, tmp_str0468, tmp_str0467, tmp_str0466, tmp_str0465, tmp_str0464, tmp_str0463, tmp_str0462, tmp_str0461, tmp_str0460, tmp_str045F, tmp_str045E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_009D = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_009D > 0) { 
   FileSeek(Gi_009D, 0, 2);
   tmp_str046B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_009D, tmp_str046B, " VERBOSE: ", tmp_str0469, tmp_str0468, tmp_str0467, tmp_str0466, tmp_str0465, tmp_str0464, tmp_str0463, tmp_str0462, tmp_str0461, tmp_str0460, tmp_str045F, tmp_str045E);
   FileClose(Gi_009D);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0020, OrderType(), OrderOpenPrice());
   Gi_009E = Ii_0020;
   Gd_009F = 0;
   if (Ii_0020 == Ii_0000) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0004) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0008) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_000C) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0010) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0014) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0018) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_001C) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0020) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0024) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0028) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_002C) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0030) { 
   Gd_009F = (Id_0090 * 0);
   } 
   if (Gi_009E == Ii_0034) { 
   Gd_009F = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_009F, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str046C = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str046C != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str046E = "";
   tmp_str046F = "";
   tmp_str0470 = "";
   tmp_str0471 = "";
   tmp_str0472 = "";
   tmp_str0473 = "";
   tmp_str0474 = (string)Ld_FFE8;
   tmp_str0475 = " to :";
   tmp_str0476 = (string)Fa_i_00;
   tmp_str0477 = ", Magic Number: ";
   tmp_str0478 = (string)OrderTicket();
   tmp_str0479 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str047A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str047A, " ", tmp_str0479, tmp_str0478, tmp_str0477, tmp_str0476, tmp_str0475, tmp_str0474, tmp_str0473, tmp_str0472, tmp_str0471, tmp_str0470, tmp_str046F, tmp_str046E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00A0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00A0 > 0) { 
   FileSeek(Gi_00A0, 0, 2);
   tmp_str047B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00A0, tmp_str047B, " VERBOSE: ", tmp_str0479, tmp_str0478, tmp_str0477, tmp_str0476, tmp_str0475, tmp_str0474, tmp_str0473, tmp_str0472, tmp_str0471, tmp_str0470, tmp_str046F, tmp_str046E);
   FileClose(Gi_00A0);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_016A = GetLastError();
   Li_FFDC = Gi_016A;
   tmp_str047C = "";
   tmp_str047D = "";
   tmp_str047E = (string)OrderStopLoss();
   tmp_str047F = " Current SL: ";
   tmp_str0480 = (string)Bid;
   tmp_str0481 = ", Bid: ";
   tmp_str0482 = (string)(string)Ask;
   tmp_str0483 = ", Ask: ";
   tmp_str0484 = ErrorDescription(Gi_016A);
   tmp_str0485 = " - ";
   tmp_str0486 = (string)Gi_016A;
   tmp_str0487 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0488 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0488, " ", tmp_str0487, tmp_str0486, tmp_str0485, tmp_str0484, tmp_str0483, tmp_str0482, tmp_str0481, tmp_str0480, tmp_str047F, tmp_str047E, tmp_str047D, tmp_str047C);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00A1 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00A1 > 0) {
   FileSeek(Gi_00A1, 0, 2);
   tmp_str0489 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00A1, tmp_str0489, " VERBOSE: ", tmp_str0487, tmp_str0486, tmp_str0485, tmp_str0484, tmp_str0483, tmp_str0482, tmp_str0481, tmp_str0480, tmp_str047F, tmp_str047E, tmp_str047D, tmp_str047C);
   FileClose(Gi_00A1);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str048A = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str048A != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str048C = "";
   tmp_str048D = "";
   tmp_str048E = "";
   tmp_str048F = "";
   tmp_str0490 = "";
   tmp_str0491 = "";
   tmp_str0492 = (string)(string)Ld_FFE8;
   tmp_str0493 = " to :";
   tmp_str0494 = (string)Fa_i_00;
   tmp_str0495 = ", Magic Number: ";
   tmp_str0496 = (string)OrderTicket();
   tmp_str0497 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0498 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0498, " ", tmp_str0497, tmp_str0496, tmp_str0495, tmp_str0494, tmp_str0493, tmp_str0492, tmp_str0491, tmp_str0490, tmp_str048F, tmp_str048E, tmp_str048D, tmp_str048C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00A2 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00A2 > 0) { 
   FileSeek(Gi_00A2, 0, 2);
   tmp_str0499 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00A2, tmp_str0499, " VERBOSE: ", tmp_str0497, tmp_str0496, tmp_str0495, tmp_str0494, tmp_str0493, tmp_str0492, tmp_str0491, tmp_str0490, tmp_str048F, tmp_str048E, tmp_str048D, tmp_str048C);
   FileClose(Gi_00A2);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_016C = GetLastError();
   Li_FFDC = Gi_016C;
   tmp_str049A = "";
   tmp_str049B = "";
   tmp_str049C = (string)OrderStopLoss();
   tmp_str049D = " Current SL: ";
   tmp_str049E = (string)Bid;
   tmp_str049F = ", Bid: ";
   tmp_str04A0 = (string)Ask;
   tmp_str04A1 = ", Ask: ";
   tmp_str04A2 = ErrorDescription(Gi_016C);
   tmp_str04A3 = " - ";
   tmp_str04A4 = (string)Gi_016C;
   tmp_str04A5 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str04A6 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str04A6, " ", tmp_str04A5, tmp_str04A4, tmp_str04A3, tmp_str04A2, tmp_str04A1, tmp_str04A0, tmp_str049F, tmp_str049E, tmp_str049D, tmp_str049C, tmp_str049B, tmp_str049A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00A3 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00A3 > 0) { 
   FileSeek(Gi_00A3, 0, 2);
   tmp_str04A7 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00A3, tmp_str04A7, " VERBOSE: ", tmp_str04A5, tmp_str04A4, tmp_str04A3, tmp_str04A2, tmp_str04A1, tmp_str04A0, tmp_str049F, tmp_str049E, tmp_str049D, tmp_str049C, tmp_str049B, tmp_str049A);
   FileClose(Gi_00A3);
   }}}}}}}}} 
   Gi_00A4 = Ii_0020;
   Gd_00A5 = 0;
   if (Ii_0020 == Ii_0000) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0004) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0008) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_000C) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0010) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0014) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0018) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_001C) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0020) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0024) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0028) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_002C) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0030) { 
   Gd_00A5 = 0;
   } 
   if (Gi_00A4 == Ii_0034) { 
   Gd_00A5 = 0;
   } 
   returned_double = NormalizeDouble(Gd_00A5, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_00A6 = (int)(returned_double + 10);
   Gl_00A7 = OrderOpenTime();
   Gi_00A8 = 0;
   Gi_00A9 = 0;
   Gi_016C = Gi_00A6 + 10;
   if (Gi_016C > 0) { 
   do { 
   if (Gl_00A7 < Time[Gi_00A9]) { 
   Gi_00A8 = Gi_00A8 + 1;
   } 
   Gi_00A9 = Gi_00A9 + 1;
   Gi_016D = Gi_00A6 + 10;
   } while (Gi_00A9 < Gi_016D); 
   } 
   if ((Gi_00A8 >= Ld_FFF8)) { 
   tmp_str04A8 = "";
   tmp_str04A9 = "";
   tmp_str04AA = "";
   tmp_str04AB = "";
   tmp_str04AC = "";
   tmp_str04AD = "";
   tmp_str04AE = (string)Fa_i_00;
   tmp_str04AF = ", Magic Number: ";
   tmp_str04B0 = (string)OrderTicket();
   tmp_str04B1 = "bars - closing order with ticket: ";
   tmp_str04B2 = (string)Ld_FFF8;
   tmp_str04B3 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str04B4 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str04B4, " ", tmp_str04B3, tmp_str04B2, tmp_str04B1, tmp_str04B0, tmp_str04AF, tmp_str04AE, tmp_str04AD, tmp_str04AC, tmp_str04AB, tmp_str04AA, tmp_str04A9, tmp_str04A8);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00AA = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00AA > 0) { 
   FileSeek(Gi_00AA, 0, 2);
   tmp_str04B5 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00AA, tmp_str04B5, " VERBOSE: ", tmp_str04B3, tmp_str04B2, tmp_str04B1, tmp_str04B0, tmp_str04AF, tmp_str04AE, tmp_str04AD, tmp_str04AC, tmp_str04AB, tmp_str04AA, tmp_str04A9, tmp_str04A8);
   FileClose(Gi_00AA);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0024) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0024, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_00AB = Ii_0024;
   Gd_00AC = 0;
   if (Ii_0024 == Ii_0000) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0004) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0008) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_000C) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0010) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0014) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0018) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_001C) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0020) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0024) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0028) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_002C) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0030) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   if (Gi_00AB == Ii_0034) { 
   Gd_00AC = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00AC, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str04B6 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str04B6 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str04B8 = "";
   tmp_str04B9 = "";
   tmp_str04BA = "";
   tmp_str04BB = "";
   tmp_str04BC = "";
   tmp_str04BD = "";
   tmp_str04BE = (string)Ld_FFE8;
   tmp_str04BF = " to :";
   tmp_str04C0 = (string)Fa_i_00;
   tmp_str04C1 = ", Magic Number: ";
   tmp_str04C2 = (string)OrderTicket();
   tmp_str04C3 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str04C4 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str04C4, " ", tmp_str04C3, tmp_str04C2, tmp_str04C1, tmp_str04C0, tmp_str04BF, tmp_str04BE, tmp_str04BD, tmp_str04BC, tmp_str04BB, tmp_str04BA, tmp_str04B9, tmp_str04B8);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00AD = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00AD > 0) { 
   FileSeek(Gi_00AD, 0, 2);
   tmp_str04C5 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00AD, tmp_str04C5, " VERBOSE: ", tmp_str04C3, tmp_str04C2, tmp_str04C1, tmp_str04C0, tmp_str04BF, tmp_str04BE, tmp_str04BD, tmp_str04BC, tmp_str04BB, tmp_str04BA, tmp_str04B9, tmp_str04B8);
   FileClose(Gi_00AD);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0170 = GetLastError();
   Li_FFDC = Gi_0170;
   tmp_str04C6 = "";
   tmp_str04C7 = "";
   tmp_str04C8 = "";
   tmp_str04C9 = "";
   tmp_str04CA = "";
   tmp_str04CB = "";
   tmp_str04CC = "";
   tmp_str04CD = "";
   tmp_str04CE = ErrorDescription(Gi_0170);
   tmp_str04CF = " - ";
   tmp_str04D0 = (string)Gi_0170;
   tmp_str04D1 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str04D2 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str04D2, " ", tmp_str04D1, tmp_str04D0, tmp_str04CF, tmp_str04CE, tmp_str04CD, tmp_str04CC, tmp_str04CB, tmp_str04CA, tmp_str04C9, tmp_str04C8, tmp_str04C7, tmp_str04C6);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00AE = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00AE > 0) {
   FileSeek(Gi_00AE, 0, 2);
   tmp_str04D3 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00AE, tmp_str04D3, " VERBOSE: ", tmp_str04D1, tmp_str04D0, tmp_str04CF, tmp_str04CE, tmp_str04CD, tmp_str04CC, tmp_str04CB, tmp_str04CA, tmp_str04C9, tmp_str04C8, tmp_str04C7, tmp_str04C6);
   FileClose(Gi_00AE);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str04D4 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str04D4 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str04D6 = "";
   tmp_str04D7 = "";
   tmp_str04D8 = "";
   tmp_str04D9 = "";
   tmp_str04DA = "";
   tmp_str04DB = "";
   tmp_str04DC = (string)Ld_FFE8;
   tmp_str04DD = " to :";
   tmp_str04DE = (string)Fa_i_00;
   tmp_str04DF = ", Magic Number: ";
   tmp_str04E0 = (string)OrderTicket();
   tmp_str04E1 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str04E2 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str04E2, " ", tmp_str04E1, tmp_str04E0, tmp_str04DF, tmp_str04DE, tmp_str04DD, tmp_str04DC, tmp_str04DB, tmp_str04DA, tmp_str04D9, tmp_str04D8, tmp_str04D7, tmp_str04D6);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00AF = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00AF > 0) { 
   FileSeek(Gi_00AF, 0, 2);
   tmp_str04E3 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00AF, tmp_str04E3, " VERBOSE: ", tmp_str04E1, tmp_str04E0, tmp_str04DF, tmp_str04DE, tmp_str04DD, tmp_str04DC, tmp_str04DB, tmp_str04DA, tmp_str04D9, tmp_str04D8, tmp_str04D7, tmp_str04D6);
   FileClose(Gi_00AF);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0172 = GetLastError();
   Li_FFDC = Gi_0172;
   tmp_str04E4 = "";
   tmp_str04E5 = "";
   tmp_str04E6 = (string)OrderStopLoss();
   tmp_str04E7 = " Current SL: ";
   tmp_str04E8 = (string)Bid;
   tmp_str04E9 = ", Bid: ";
   tmp_str04EA = (string)Ask;
   tmp_str04EB = ", Ask: ";
   tmp_str04EC = ErrorDescription(Gi_0172);
   tmp_str04ED = " - ";
   tmp_str04EE = (string)Gi_0172;
   tmp_str04EF = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str04F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str04F0, " ", tmp_str04EF, tmp_str04EE, tmp_str04ED, tmp_str04EC, tmp_str04EB, tmp_str04EA, tmp_str04E9, tmp_str04E8, tmp_str04E7, tmp_str04E6, tmp_str04E5, tmp_str04E4);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00B0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00B0 > 0) { 
   FileSeek(Gi_00B0, 0, 2);
   tmp_str04F1 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00B0, tmp_str04F1, " VERBOSE: ", tmp_str04EF, tmp_str04EE, tmp_str04ED, tmp_str04EC, tmp_str04EB, tmp_str04EA, tmp_str04E9, tmp_str04E8, tmp_str04E7, tmp_str04E6, tmp_str04E5, tmp_str04E4);
   FileClose(Gi_00B0);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0024, OrderType(), OrderOpenPrice());
   Gi_00B1 = Ii_0024;
   Gd_00B2 = 0;
   if (Ii_0024 == Ii_0000) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0004) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0008) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_000C) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0010) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0014) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0018) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_001C) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0020) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0024) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0028) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_002C) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0030) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   if (Gi_00B1 == Ii_0034) { 
   Gd_00B2 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00B2, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {//oto 00000F9A;
   
   tmp_str04F2 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str04F2 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str04F4 = "";
   tmp_str04F5 = "";
   tmp_str04F6 = "";
   tmp_str04F7 = "";
   tmp_str04F8 = "";
   tmp_str04F9 = "";
   tmp_str04FA = (string)Ld_FFE8;
   tmp_str04FB = " to :";
   tmp_str04FC = (string)Fa_i_00;
   tmp_str04FD = ", Magic Number: ";
   tmp_str04FE = (string)OrderTicket();
   tmp_str04FF = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0500 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0500, " ", tmp_str04FF, tmp_str04FE, tmp_str04FD, tmp_str04FC, tmp_str04FB, tmp_str04FA, tmp_str04F9, tmp_str04F8, tmp_str04F7, tmp_str04F6, tmp_str04F5, tmp_str04F4);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00B3 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00B3 > 0) { 
   FileSeek(Gi_00B3, 0, 2);
   tmp_str0501 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00B3, tmp_str0501, " VERBOSE: ", tmp_str04FF, tmp_str04FE, tmp_str04FD, tmp_str04FC, tmp_str04FB, tmp_str04FA, tmp_str04F9, tmp_str04F8, tmp_str04F7, tmp_str04F6, tmp_str04F5, tmp_str04F4);
   FileClose(Gi_00B3);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0175 = GetLastError();
   Li_FFDC = Gi_0175;
   tmp_str0502 = "";
   tmp_str0503 = "";
   tmp_str0504 = (string)OrderStopLoss();
   tmp_str0505 = " Current SL: ";
   tmp_str0506 = (string)Bid;
   tmp_str0507 = ", Bid: ";
   tmp_str0508 = (string)Ask;
   tmp_str0509 = ", Ask: ";
   tmp_str050A = ErrorDescription(Gi_0175);
   tmp_str050B = " - ";
   tmp_str050C = (string)Gi_0175;
   tmp_str050D = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str050E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str050E, " ", tmp_str050D, tmp_str050C, tmp_str050B, tmp_str050A, tmp_str0509, tmp_str0508, tmp_str0507, tmp_str0506, tmp_str0505, tmp_str0504, tmp_str0503, tmp_str0502);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00B4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00B4 > 0) {
   FileSeek(Gi_00B4, 0, 2);
   tmp_str050F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00B4, tmp_str050F, " VERBOSE: ", tmp_str050D, tmp_str050C, tmp_str050B, tmp_str050A, tmp_str0509, tmp_str0508, tmp_str0507, tmp_str0506, tmp_str0505, tmp_str0504, tmp_str0503, tmp_str0502);
   FileClose(Gi_00B4);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str0510 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0510 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0512 = "";
   tmp_str0513 = "";
   tmp_str0514 = "";
   tmp_str0515 = "";
   tmp_str0516 = "";
   tmp_str0517 = "";
   tmp_str0518 = (string)Ld_FFE8;
   tmp_str0519 = " to :";
   tmp_str051A = (string)Fa_i_00;
   tmp_str051B = ", Magic Number: ";
   tmp_str051C = (string)OrderTicket();
   tmp_str051D = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str051E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str051E, " ", tmp_str051D, tmp_str051C, tmp_str051B, tmp_str051A, tmp_str0519, tmp_str0518, tmp_str0517, tmp_str0516, tmp_str0515, tmp_str0514, tmp_str0513, tmp_str0512);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00B5 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00B5 > 0) { 
   FileSeek(Gi_00B5, 0, 2);
   tmp_str051F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00B5, tmp_str051F, " VERBOSE: ", tmp_str051D, tmp_str051C, tmp_str051B, tmp_str051A, tmp_str0519, tmp_str0518, tmp_str0517, tmp_str0516, tmp_str0515, tmp_str0514, tmp_str0513, tmp_str0512);
   FileClose(Gi_00B5);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0177 = GetLastError();
   Li_FFDC = Gi_0177;
   tmp_str0520 = "";
   tmp_str0521 = "";
   tmp_str0522 = (string)OrderStopLoss();
   tmp_str0523 = " Current SL: ";
   tmp_str0524 = (string)Bid;
   tmp_str0525 = ", Bid: ";
   tmp_str0526 = (string)Ask;
   tmp_str0527 = ", Ask: ";
   tmp_str0528 = ErrorDescription(Gi_0177);
   tmp_str0529 = " - ";
   tmp_str052A = (string)Gi_0177;
   tmp_str052B = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str052C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str052C, " ", tmp_str052B, tmp_str052A, tmp_str0529, tmp_str0528, tmp_str0527, tmp_str0526, tmp_str0525, tmp_str0524, tmp_str0523, tmp_str0522, tmp_str0521, tmp_str0520);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00B6 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00B6 > 0) { 
   FileSeek(Gi_00B6, 0, 2);
   tmp_str052D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00B6, tmp_str052D, " VERBOSE: ", tmp_str052B, tmp_str052A, tmp_str0529, tmp_str0528, tmp_str0527, tmp_str0526, tmp_str0525, tmp_str0524, tmp_str0523, tmp_str0522, tmp_str0521, tmp_str0520);
   FileClose(Gi_00B6);
   }}}}}}}}} 
   Gi_00B7 = Ii_0024;
   Gd_00B8 = 0;
   if (Ii_0024 == Ii_0000) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0004) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0008) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_000C) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0010) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0014) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0018) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_001C) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0020) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0024) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0028) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_002C) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0030) { 
   Gd_00B8 = 0;
   } 
   if (Gi_00B7 == Ii_0034) { 
   Gd_00B8 = 0;
   } 
   returned_double = NormalizeDouble(Gd_00B8, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_00B9 = (int)(returned_double + 10);
   Gl_00BA = OrderOpenTime();
   Gi_00BB = 0;
   Gi_00BC = 0;
   Gi_0177 = Gi_00B9 + 10;
   if (Gi_0177 > 0) { 
   do { 
   if (Gl_00BA < Time[Gi_00BC]) { 
   Gi_00BB = Gi_00BB + 1;
   } 
   Gi_00BC = Gi_00BC + 1;
   Gi_0178 = Gi_00B9 + 10;
   } while (Gi_00BC < Gi_0178); 
   } 
   if ((Gi_00BB >= Ld_FFF8)) { 
   tmp_str052E = "";
   tmp_str052F = "";
   tmp_str0530 = "";
   tmp_str0531 = "";
   tmp_str0532 = "";
   tmp_str0533 = "";
   tmp_str0534 = (string)Fa_i_00;
   tmp_str0535 = ", Magic Number: ";
   tmp_str0536 = (string)OrderTicket();
   tmp_str0537 = "bars - closing order with ticket: ";
   tmp_str0538 = (string)Ld_FFF8;
   tmp_str0539 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str053A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str053A, " ", tmp_str0539, tmp_str0538, tmp_str0537, tmp_str0536, tmp_str0535, tmp_str0534, tmp_str0533, tmp_str0532, tmp_str0531, tmp_str0530, tmp_str052F, tmp_str052E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00BD = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00BD > 0) { 
   FileSeek(Gi_00BD, 0, 2);
   tmp_str053B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00BD, tmp_str053B, " VERBOSE: ", tmp_str0539, tmp_str0538, tmp_str0537, tmp_str0536, tmp_str0535, tmp_str0534, tmp_str0533, tmp_str0532, tmp_str0531, tmp_str0530, tmp_str052F, tmp_str052E);
   FileClose(Gi_00BD);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0028) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0028, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_00BE = Ii_0028;
   Gd_00BF = 0;
   if (Ii_0028 == Ii_0000) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0004) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0008) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_000C) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0010) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0014) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0018) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_001C) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0020) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0024) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0028) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_002C) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0030) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   if (Gi_00BE == Ii_0034) { 
   Gd_00BF = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00BF, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str053C = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str053C != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str053E = "";
   tmp_str053F = "";
   tmp_str0540 = "";
   tmp_str0541 = "";
   tmp_str0542 = "";
   tmp_str0543 = "";
   tmp_str0544 = (string)Ld_FFE8;
   tmp_str0545 = " to :";
   tmp_str0546 = (string)Fa_i_00;
   tmp_str0547 = ", Magic Number: ";
   tmp_str0548 = (string)OrderTicket();
   tmp_str0549 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str054A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str054A, " ", tmp_str0549, tmp_str0548, tmp_str0547, tmp_str0546, tmp_str0545, tmp_str0544, tmp_str0543, tmp_str0542, tmp_str0541, tmp_str0540, tmp_str053F, tmp_str053E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00C0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00C0 > 0) { 
   FileSeek(Gi_00C0, 0, 2);
   tmp_str054B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00C0, tmp_str054B, " VERBOSE: ", tmp_str0549, tmp_str0548, tmp_str0547, tmp_str0546, tmp_str0545, tmp_str0544, tmp_str0543, tmp_str0542, tmp_str0541, tmp_str0540, tmp_str053F, tmp_str053E);
   FileClose(Gi_00C0);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_017B = GetLastError();
   Li_FFDC = Gi_017B;
   tmp_str054C = "";
   tmp_str054D = "";
   tmp_str054E = "";
   tmp_str054F = "";
   tmp_str0550 = "";
   tmp_str0551 = "";
   tmp_str0552 = "";
   tmp_str0553 = "";
   tmp_str0554 = ErrorDescription(Gi_017B);
   tmp_str0555 = " - ";
   tmp_str0556 = (string)Gi_017B;
   tmp_str0557 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0558 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0558, " ", tmp_str0557, tmp_str0556, tmp_str0555, tmp_str0554, tmp_str0553, tmp_str0552, tmp_str0551, tmp_str0550, tmp_str054F, tmp_str054E, tmp_str054D, tmp_str054C);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00C1 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00C1 > 0) {
   FileSeek(Gi_00C1, 0, 2);
   tmp_str0559 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00C1, tmp_str0559, " VERBOSE: ", tmp_str0557, tmp_str0556, tmp_str0555, tmp_str0554, tmp_str0553, tmp_str0552, tmp_str0551, tmp_str0550, tmp_str054F, tmp_str054E, tmp_str054D, tmp_str054C);
   FileClose(Gi_00C1);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str055A = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str055A != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str055C = "";
   tmp_str055D = "";
   tmp_str055E = "";
   tmp_str055F = "";
   tmp_str0560 = "";
   tmp_str0561 = "";
   tmp_str0562 = (string)Ld_FFE8;
   tmp_str0563 = " to :";
   tmp_str0564 = (string)Fa_i_00;
   tmp_str0565 = ", Magic Number: ";
   tmp_str0566 = (string)OrderTicket();
   tmp_str0567 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0568 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0568, " ", tmp_str0567, tmp_str0566, tmp_str0565, tmp_str0564, tmp_str0563, tmp_str0562, tmp_str0561, tmp_str0560, tmp_str055F, tmp_str055E, tmp_str055D, tmp_str055C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00C2 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00C2 > 0) { 
   FileSeek(Gi_00C2, 0, 2);
   tmp_str0569 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00C2, tmp_str0569, " VERBOSE: ", tmp_str0567, tmp_str0566, tmp_str0565, tmp_str0564, tmp_str0563, tmp_str0562, tmp_str0561, tmp_str0560, tmp_str055F, tmp_str055E, tmp_str055D, tmp_str055C);
   FileClose(Gi_00C2);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_017D = GetLastError();
   Li_FFDC = Gi_017D;
   tmp_str056A = "";
   tmp_str056B = "";
   tmp_str056C = (string)OrderStopLoss();
   tmp_str056D = " Current SL: ";
   tmp_str056E = (string)Bid;
   tmp_str056F = ", Bid: ";
   tmp_str0570 = (string)Ask;
   tmp_str0571 = ", Ask: ";
   tmp_str0572 = ErrorDescription(Gi_017D);
   tmp_str0573 = " - ";
   tmp_str0574 = (string)Gi_017D;
   tmp_str0575 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0576 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0576, " ", tmp_str0575, tmp_str0574, tmp_str0573, tmp_str0572, tmp_str0571, tmp_str0570, tmp_str056F, tmp_str056E, tmp_str056D, tmp_str056C, tmp_str056B, tmp_str056A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00C3 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00C3 > 0) { 
   FileSeek(Gi_00C3, 0, 2);
   tmp_str0577 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00C3, tmp_str0577, " VERBOSE: ", tmp_str0575, tmp_str0574, tmp_str0573, tmp_str0572, tmp_str0571, tmp_str0570, tmp_str056F, tmp_str056E, tmp_str056D, tmp_str056C, tmp_str056B, tmp_str056A);
   FileClose(Gi_00C3);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0028, OrderType(), OrderOpenPrice());
   Gi_00C4 = Ii_0028;
   Gd_00C5 = 0;
   if (Ii_0028 == Ii_0000) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0004) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0008) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_000C) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0010) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0014) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0018) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_001C) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0020) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0024) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0028) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_002C) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0030) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   if (Gi_00C4 == Ii_0034) { 
   Gd_00C5 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00C5, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str0578 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0578 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str057A = "";
   tmp_str057B = "";
   tmp_str057C = "";
   tmp_str057D = "";
   tmp_str057E = "";
   tmp_str057F = "";
   tmp_str0580 = (string)Ld_FFE8;
   tmp_str0581 = " to :";
   tmp_str0582 = (string)Fa_i_00;
   tmp_str0583 = ", Magic Number: ";
   tmp_str0584 = (string)OrderTicket();
   tmp_str0585 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0586 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0586, " ", tmp_str0585, tmp_str0584, tmp_str0583, tmp_str0582, tmp_str0581, tmp_str0580, tmp_str057F, tmp_str057E, tmp_str057D, tmp_str057C, tmp_str057B, tmp_str057A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00C6 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00C6 > 0) { 
   FileSeek(Gi_00C6, 0, 2);
   tmp_str0587 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00C6, tmp_str0587, " VERBOSE: ", tmp_str0585, tmp_str0584, tmp_str0583, tmp_str0582, tmp_str0581, tmp_str0580, tmp_str057F, tmp_str057E, tmp_str057D, tmp_str057C, tmp_str057B, tmp_str057A);
   FileClose(Gi_00C6);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0180 = GetLastError();
   Li_FFDC = Gi_0180;
   tmp_str0588 = "";
   tmp_str0589 = "";
   tmp_str058A = (string)(string)(string)(string)OrderStopLoss();
   tmp_str058B = " Current SL: ";
   tmp_str058C = (string)Bid;
   tmp_str058D = ", Bid: ";
   tmp_str058E = (string)Ask;
   tmp_str058F = ", Ask: ";
   tmp_str0590 = ErrorDescription(Gi_0180);
   tmp_str0591 = " - ";
   tmp_str0592 = (string)Gi_0180;
   tmp_str0593 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0594 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0594, " ", tmp_str0593, tmp_str0592, tmp_str0591, tmp_str0590, tmp_str058F, tmp_str058E, tmp_str058D, tmp_str058C, tmp_str058B, tmp_str058A, tmp_str0589, tmp_str0588);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00C7 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00C7 > 0) {
   FileSeek(Gi_00C7, 0, 2);
   tmp_str0595 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00C7, tmp_str0595, " VERBOSE: ", tmp_str0593, tmp_str0592, tmp_str0591, tmp_str0590, tmp_str058F, tmp_str058E, tmp_str058D, tmp_str058C, tmp_str058B, tmp_str058A, tmp_str0589, tmp_str0588);
   FileClose(Gi_00C7);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str0596 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0596 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0598 = "";
   tmp_str0599 = "";
   tmp_str059A = "";
   tmp_str059B = "";
   tmp_str059C = "";
   tmp_str059D = "";
   tmp_str059E = (string)Ld_FFE8;
   tmp_str059F = " to :";
   tmp_str05A0 = (string)Fa_i_00;
   tmp_str05A1 = ", Magic Number: ";
   tmp_str05A2 = (string)OrderTicket();
   tmp_str05A3 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str05A4 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str05A4, " ", tmp_str05A3, tmp_str05A2, tmp_str05A1, tmp_str05A0, tmp_str059F, tmp_str059E, tmp_str059D, tmp_str059C, tmp_str059B, tmp_str059A, tmp_str0599, tmp_str0598);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00C8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00C8 > 0) { 
   FileSeek(Gi_00C8, 0, 2);
   tmp_str05A5 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00C8, tmp_str05A5, " VERBOSE: ", tmp_str05A3, tmp_str05A2, tmp_str05A1, tmp_str05A0, tmp_str059F, tmp_str059E, tmp_str059D, tmp_str059C, tmp_str059B, tmp_str059A, tmp_str0599, tmp_str0598);
   FileClose(Gi_00C8);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0182 = GetLastError();
   Li_FFDC = Gi_0182;
   tmp_str05A6 = "";
   tmp_str05A7 = "";
   tmp_str05A8 = (string)OrderStopLoss();
   tmp_str05A9 = " Current SL: ";
   tmp_str05AA = (string)Bid;
   tmp_str05AB = ", Bid: ";
   tmp_str05AC = (string)Ask;
   tmp_str05AD = ", Ask: ";
   tmp_str05AE = ErrorDescription(Gi_0182);
   tmp_str05AF = " - ";
   tmp_str05B0 = (string)Gi_0182;
   tmp_str05B1 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str05B2 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str05B2, " ", tmp_str05B1, tmp_str05B0, tmp_str05AF, tmp_str05AE, tmp_str05AD, tmp_str05AC, tmp_str05AB, tmp_str05AA, tmp_str05A9, tmp_str05A8, tmp_str05A7, tmp_str05A6);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00C9 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00C9 > 0) { 
   FileSeek(Gi_00C9, 0, 2);
   tmp_str05B3 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00C9, tmp_str05B3, " VERBOSE: ", tmp_str05B1, tmp_str05B0, tmp_str05AF, tmp_str05AE, tmp_str05AD, tmp_str05AC, tmp_str05AB, tmp_str05AA, tmp_str05A9, tmp_str05A8, tmp_str05A7, tmp_str05A6);
   FileClose(Gi_00C9);
   }}}}}}}}} 
   Gi_00CA = Ii_0028;
   Gd_00CB = 0;
   if (Ii_0028 == Ii_0000) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0004) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0008) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_000C) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0010) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0014) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0018) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_001C) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0020) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0024) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0028) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_002C) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0030) { 
   Gd_00CB = 0;
   } 
   if (Gi_00CA == Ii_0034) { 
   Gd_00CB = 0;
   } 
   returned_double = NormalizeDouble(Gd_00CB, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_00CC = (int)(returned_double + 10);
   Gl_00CD = OrderOpenTime();
   Gi_00CE = 0;
   Gi_00CF = 0;
   Gi_0182 = Gi_00CC + 10;
   if (Gi_0182 > 0) { 
   do { 
   if (Gl_00CD < Time[Gi_00CF]) { 
   Gi_00CE = Gi_00CE + 1;
   } 
   Gi_00CF = Gi_00CF + 1;
   Gi_0183 = Gi_00CC + 10;
   } while (Gi_00CF < Gi_0183); 
   } 
   if ((Gi_00CE >= Ld_FFF8)) { 
   tmp_str05B4 = "";
   tmp_str05B5 = "";
   tmp_str05B6 = "";
   tmp_str05B7 = "";
   tmp_str05B8 = "";
   tmp_str05B9 = "";
   tmp_str05BA = (string)Fa_i_00;
   tmp_str05BB = ", Magic Number: ";
   tmp_str05BC = (string)OrderTicket();
   tmp_str05BD = "bars - closing order with ticket: ";
   tmp_str05BE = (string)Ld_FFF8;
   tmp_str05BF = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str05C0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str05C0, " ", tmp_str05BF, tmp_str05BE, tmp_str05BD, tmp_str05BC, tmp_str05BB, tmp_str05BA, tmp_str05B9, tmp_str05B8, tmp_str05B7, tmp_str05B6, tmp_str05B5, tmp_str05B4);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00D0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00D0 > 0) { 
   FileSeek(Gi_00D0, 0, 2);
   tmp_str05C1 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00D0, tmp_str05C1, " VERBOSE: ", tmp_str05BF, tmp_str05BE, tmp_str05BD, tmp_str05BC, tmp_str05BB, tmp_str05BA, tmp_str05B9, tmp_str05B8, tmp_str05B7, tmp_str05B6, tmp_str05B5, tmp_str05B4);
   FileClose(Gi_00D0);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_002C) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_002C, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_00D1 = Ii_002C;
   Gd_00D2 = 0;
   if (Ii_002C == Ii_0000) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0004) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0008) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_000C) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0010) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0014) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0018) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_001C) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0020) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0024) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0028) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_002C) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0030) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   if (Gi_00D1 == Ii_0034) { 
   Gd_00D2 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00D2, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str05C2 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str05C2 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str05C4 = "";
   tmp_str05C5 = "";
   tmp_str05C6 = "";
   tmp_str05C7 = "";
   tmp_str05C8 = "";
   tmp_str05C9 = "";
   tmp_str05CA = (string)Ld_FFE8;
   tmp_str05CB = " to :";
   tmp_str05CC = (string)Fa_i_00;
   tmp_str05CD = ", Magic Number: ";
   tmp_str05CE = (string)OrderTicket();
   tmp_str05CF = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str05D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str05D0, " ", tmp_str05CF, tmp_str05CE, tmp_str05CD, tmp_str05CC, tmp_str05CB, tmp_str05CA, tmp_str05C9, tmp_str05C8, tmp_str05C7, tmp_str05C6, tmp_str05C5, tmp_str05C4);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00D3 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00D3 > 0) { 
   FileSeek(Gi_00D3, 0, 2);
   tmp_str05D1 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00D3, tmp_str05D1, " VERBOSE: ", tmp_str05CF, tmp_str05CE, tmp_str05CD, tmp_str05CC, tmp_str05CB, tmp_str05CA, tmp_str05C9, tmp_str05C8, tmp_str05C7, tmp_str05C6, tmp_str05C5, tmp_str05C4);
   FileClose(Gi_00D3);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0186 = GetLastError();
   Li_FFDC = Gi_0186;
   tmp_str05D2 = "";
   tmp_str05D3 = "";
   tmp_str05D4 = "";
   tmp_str05D5 = "";
   tmp_str05D6 = "";
   tmp_str05D7 = "";
   tmp_str05D8 = "";
   tmp_str05D9 = "";
   tmp_str05DA = ErrorDescription(Gi_0186);
   tmp_str05DB = " - ";
   tmp_str05DC = (string)Gi_0186;
   tmp_str05DD = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str05DE = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str05DE, " ", tmp_str05DD, tmp_str05DC, tmp_str05DB, tmp_str05DA, tmp_str05D9, tmp_str05D8, tmp_str05D7, tmp_str05D6, tmp_str05D5, tmp_str05D4, tmp_str05D3, tmp_str05D2);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00D4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00D4 > 0) {
   FileSeek(Gi_00D4, 0, 2);
   tmp_str05DF = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00D4, tmp_str05DF, " VERBOSE: ", tmp_str05DD, tmp_str05DC, tmp_str05DB, tmp_str05DA, tmp_str05D9, tmp_str05D8, tmp_str05D7, tmp_str05D6, tmp_str05D5, tmp_str05D4, tmp_str05D3, tmp_str05D2);
   FileClose(Gi_00D4);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str05E0 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str05E0 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str05E2 = "";
   tmp_str05E3 = "";
   tmp_str05E4 = "";
   tmp_str05E5 = "";
   tmp_str05E6 = "";
   tmp_str05E7 = "";
   tmp_str05E8 = (string)Ld_FFE8;
   tmp_str05E9 = " to :";
   tmp_str05EA = (string)Fa_i_00;
   tmp_str05EB = ", Magic Number: ";
   tmp_str05EC = (string)OrderTicket();
   tmp_str05ED = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str05EE = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str05EE, " ", tmp_str05ED, tmp_str05EC, tmp_str05EB, tmp_str05EA, tmp_str05E9, tmp_str05E8, tmp_str05E7, tmp_str05E6, tmp_str05E5, tmp_str05E4, tmp_str05E3, tmp_str05E2);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00D5 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00D5 > 0) { 
   FileSeek(Gi_00D5, 0, 2);
   tmp_str05EF = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00D5, tmp_str05EF, " VERBOSE: ", tmp_str05ED, tmp_str05EC, tmp_str05EB, tmp_str05EA, tmp_str05E9, tmp_str05E8, tmp_str05E7, tmp_str05E6, tmp_str05E5, tmp_str05E4, tmp_str05E3, tmp_str05E2);
   FileClose(Gi_00D5);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0188 = GetLastError();
   Li_FFDC = Gi_0188;
   tmp_str05F0 = "";
   tmp_str05F1 = "";
   tmp_str05F2 = (string)OrderStopLoss();
   tmp_str05F3 = " Current SL: ";
   tmp_str05F4 = (string)Bid;
   tmp_str05F5 = ", Bid: ";
   tmp_str05F6 = (string)Ask;
   tmp_str05F7 = ", Ask: ";
   tmp_str05F8 = ErrorDescription(Gi_0188);
   tmp_str05F9 = " - ";
   tmp_str05FA = (string)Gi_0188;
   tmp_str05FB = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str05FC = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str05FC, " ", tmp_str05FB, tmp_str05FA, tmp_str05F9, tmp_str05F8, tmp_str05F7, tmp_str05F6, tmp_str05F5, tmp_str05F4, tmp_str05F3, tmp_str05F2, tmp_str05F1, tmp_str05F0);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00D6 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00D6 > 0) { 
   FileSeek(Gi_00D6, 0, 2);
   tmp_str05FD = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00D6, tmp_str05FD, " VERBOSE: ", tmp_str05FB, tmp_str05FA, tmp_str05F9, tmp_str05F8, tmp_str05F7, tmp_str05F6, tmp_str05F5, tmp_str05F4, tmp_str05F3, tmp_str05F2, tmp_str05F1, tmp_str05F0);
   FileClose(Gi_00D6);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_002C, OrderType(), OrderOpenPrice());
   Gi_00D7 = Ii_002C;
   Gd_00D8 = 0;
   if (Ii_002C == Ii_0000) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0004) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0008) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_000C) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0010) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0014) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0018) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_001C) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0020) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0024) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0028) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_002C) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0030) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   if (Gi_00D7 == Ii_0034) { 
   Gd_00D8 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00D8, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str05FE = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str05FE != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0600 = "";
   tmp_str0601 = "";
   tmp_str0602 = "";
   tmp_str0603 = "";
   tmp_str0604 = "";
   tmp_str0605 = "";
   tmp_str0606 = (string)Ld_FFE8;
   tmp_str0607 = " to :";
   tmp_str0608 = (string)Fa_i_00;
   tmp_str0609 = ", Magic Number: ";
   tmp_str060A = (string)OrderTicket();
   tmp_str060B = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str060C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str060C, " ", tmp_str060B, tmp_str060A, tmp_str0609, tmp_str0608, tmp_str0607, tmp_str0606, tmp_str0605, tmp_str0604, tmp_str0603, tmp_str0602, tmp_str0601, tmp_str0600);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00D9 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00D9 > 0) { 
   FileSeek(Gi_00D9, 0, 2);
   tmp_str060D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00D9, tmp_str060D, " VERBOSE: ", tmp_str060B, tmp_str060A, tmp_str0609, tmp_str0608, tmp_str0607, tmp_str0606, tmp_str0605, tmp_str0604, tmp_str0603, tmp_str0602, tmp_str0601, tmp_str0600);
   FileClose(Gi_00D9);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_018B = GetLastError();
   Li_FFDC = Gi_018B;
   tmp_str060E = "";
   tmp_str060F = "";
   tmp_str0610 = (string)OrderStopLoss();
   tmp_str0611 = " Current SL: ";
   tmp_str0612 = (string)Bid;
   tmp_str0613 = ", Bid: ";
   tmp_str0614 = (string)Ask;
   tmp_str0615 = ", Ask: ";
   tmp_str0616 = ErrorDescription(Gi_018B);
   tmp_str0617 = " - ";
   tmp_str0618 = (string)Gi_018B;
   tmp_str0619 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str061A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str061A, " ", tmp_str0619, tmp_str0618, tmp_str0617, tmp_str0616, tmp_str0615, tmp_str0614, tmp_str0613, tmp_str0612, tmp_str0611, tmp_str0610, tmp_str060F, tmp_str060E);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00DA = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00DA > 0) {
   FileSeek(Gi_00DA, 0, 2);
   tmp_str061B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00DA, tmp_str061B, " VERBOSE: ", tmp_str0619, tmp_str0618, tmp_str0617, tmp_str0616, tmp_str0615, tmp_str0614, tmp_str0613, tmp_str0612, tmp_str0611, tmp_str0610, tmp_str060F, tmp_str060E);
   FileClose(Gi_00DA);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str061C = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str061C != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str061E = "";
   tmp_str061F = "";
   tmp_str0620 = "";
   tmp_str0621 = "";
   tmp_str0622 = "";
   tmp_str0623 = "";
   tmp_str0624 = (string)Ld_FFE8;
   tmp_str0625 = " to :";
   tmp_str0626 = (string)Fa_i_00;
   tmp_str0627 = ", Magic Number: ";
   tmp_str0628 = (string)OrderTicket();
   tmp_str0629 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str062A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str062A, " ", tmp_str0629, tmp_str0628, tmp_str0627, tmp_str0626, tmp_str0625, tmp_str0624, tmp_str0623, tmp_str0622, tmp_str0621, tmp_str0620, tmp_str061F, tmp_str061E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00DB = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00DB > 0) { 
   FileSeek(Gi_00DB, 0, 2);
   tmp_str062B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00DB, tmp_str062B, " VERBOSE: ", tmp_str0629, tmp_str0628, tmp_str0627, tmp_str0626, tmp_str0625, tmp_str0624, tmp_str0623, tmp_str0622, tmp_str0621, tmp_str0620, tmp_str061F, tmp_str061E);
   FileClose(Gi_00DB);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_018D = GetLastError();
   Li_FFDC = Gi_018D;
   tmp_str062C = "";
   tmp_str062D = "";
   tmp_str062E = (string)OrderStopLoss();
   tmp_str062F = " Current SL: ";
   tmp_str0630 = (string)Bid;
   tmp_str0631 = ", Bid: ";
   tmp_str0632 = (string)Ask;
   tmp_str0633 = ", Ask: ";
   tmp_str0634 = ErrorDescription(Gi_018D);
   tmp_str0635 = " - ";
   tmp_str0636 = (string)Gi_018D;
   tmp_str0637 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0638 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0638, " ", tmp_str0637, tmp_str0636, tmp_str0635, tmp_str0634, tmp_str0633, tmp_str0632, tmp_str0631, tmp_str0630, tmp_str062F, tmp_str062E, tmp_str062D, tmp_str062C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00DC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00DC > 0) { 
   FileSeek(Gi_00DC, 0, 2);
   tmp_str0639 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00DC, tmp_str0639, " VERBOSE: ", tmp_str0637, tmp_str0636, tmp_str0635, tmp_str0634, tmp_str0633, tmp_str0632, tmp_str0631, tmp_str0630, tmp_str062F, tmp_str062E, tmp_str062D, tmp_str062C);
   FileClose(Gi_00DC);
   }}}}}}}}} 
   Gi_00DD = Ii_002C;
   Gd_00DE = 0;
   if (Ii_002C == Ii_0000) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0004) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0008) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_000C) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0010) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0014) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0018) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_001C) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0020) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0024) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0028) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_002C) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0030) { 
   Gd_00DE = 0;
   } 
   if (Gi_00DD == Ii_0034) { 
   Gd_00DE = 0;
   } 
   returned_double = NormalizeDouble(Gd_00DE, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_00DF = (int)(returned_double + 10);
   Gl_00E0 = OrderOpenTime();
   Gi_00E1 = 0;
   Gi_00E2 = 0;
   Gi_018D = Gi_00DF + 10;
   if (Gi_018D > 0) { 
   do { 
   if (Gl_00E0 < Time[Gi_00E2]) { 
   Gi_00E1 = Gi_00E1 + 1;
   } 
   Gi_00E2 = Gi_00E2 + 1;
   Gi_018E = Gi_00DF + 10;
   } while (Gi_00E2 < Gi_018E); 
   } 
   if ((Gi_00E1 >= Ld_FFF8)) { 
   tmp_str063A = "";
   tmp_str063B = "";
   tmp_str063C = "";
   tmp_str063D = "";
   tmp_str063E = "";
   tmp_str063F = "";
   tmp_str0640 = (string)Fa_i_00;
   tmp_str0641 = ", Magic Number: ";
   tmp_str0642 = (string)OrderTicket();
   tmp_str0643 = "bars - closing order with ticket: ";
   tmp_str0644 = (string)Ld_FFF8;
   tmp_str0645 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str0646 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0646, " ", tmp_str0645, tmp_str0644, tmp_str0643, tmp_str0642, tmp_str0641, tmp_str0640, tmp_str063F, tmp_str063E, tmp_str063D, tmp_str063C, tmp_str063B, tmp_str063A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00E3 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00E3 > 0) { 
   FileSeek(Gi_00E3, 0, 2);
   tmp_str0647 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00E3, tmp_str0647, " VERBOSE: ", tmp_str0645, tmp_str0644, tmp_str0643, tmp_str0642, tmp_str0641, tmp_str0640, tmp_str063F, tmp_str063E, tmp_str063D, tmp_str063C, tmp_str063B, tmp_str063A);
   FileClose(Gi_00E3);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 == Ii_0030) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_FFF8 = getOrderTrailingStop(Ii_0030, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_00E4 = Ii_0030;
   Gd_00E5 = 0;
   if (Ii_0030 == Ii_0000) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0004) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0008) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_000C) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0010) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0014) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0018) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_001C) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0020) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0024) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0028) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_002C) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0030) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   if (Gi_00E4 == Ii_0034) { 
   Gd_00E5 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00E5, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str0648 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0648 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str064A = "";
   tmp_str064B = "";
   tmp_str064C = "";
   tmp_str064D = "";
   tmp_str064E = "";
   tmp_str064F = "";
   tmp_str0650 = (string)Ld_FFE8;
   tmp_str0651 = " to :";
   tmp_str0652 = (string)Fa_i_00;
   tmp_str0653 = ", Magic Number: ";
   tmp_str0654 = (string)OrderTicket();
   tmp_str0655 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0656 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0656, " ", tmp_str0655, tmp_str0654, tmp_str0653, tmp_str0652, tmp_str0651, tmp_str0650, tmp_str064F, tmp_str064E, tmp_str064D, tmp_str064C, tmp_str064B, tmp_str064A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00E6 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00E6 > 0) { 
   FileSeek(Gi_00E6, 0, 2);
   tmp_str0657 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00E6, tmp_str0657, " VERBOSE: ", tmp_str0655, tmp_str0654, tmp_str0653, tmp_str0652, tmp_str0651, tmp_str0650, tmp_str064F, tmp_str064E, tmp_str064D, tmp_str064C, tmp_str064B, tmp_str064A);
   FileClose(Gi_00E6);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0191 = GetLastError();
   Li_FFDC = Gi_0191;
   tmp_str0658 = "";
   tmp_str0659 = "";
   tmp_str065A = "";
   tmp_str065B = "";
   tmp_str065C = "";
   tmp_str065D = "";
   tmp_str065E = "";
   tmp_str065F = "";
   tmp_str0660 = ErrorDescription(Gi_0191);
   tmp_str0661 = " - ";
   tmp_str0662 = (string)Gi_0191;
   tmp_str0663 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0664 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0664, " ", tmp_str0663, tmp_str0662, tmp_str0661, tmp_str0660, tmp_str065F, tmp_str065E, tmp_str065D, tmp_str065C, tmp_str065B, tmp_str065A, tmp_str0659, tmp_str0658);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00E7 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00E7 > 0) {
   FileSeek(Gi_00E7, 0, 2);
   tmp_str0665 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00E7, tmp_str0665, " VERBOSE: ", tmp_str0663, tmp_str0662, tmp_str0661, tmp_str0660, tmp_str065F, tmp_str065E, tmp_str065D, tmp_str065C, tmp_str065B, tmp_str065A, tmp_str0659, tmp_str0658);
   FileClose(Gi_00E7);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str0666 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0666 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str0668 = "";
   tmp_str0669 = "";
   tmp_str066A = "";
   tmp_str066B = "";
   tmp_str066C = "";
   tmp_str066D = "";
   tmp_str066E = (string)Ld_FFE8;
   tmp_str066F = " to :";
   tmp_str0670 = (string)Fa_i_00;
   tmp_str0671 = ", Magic Number: ";
   tmp_str0672 = (string)OrderTicket();
   tmp_str0673 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0674 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0674, " ", tmp_str0673, tmp_str0672, tmp_str0671, tmp_str0670, tmp_str066F, tmp_str066E, tmp_str066D, tmp_str066C, tmp_str066B, tmp_str066A, tmp_str0669, tmp_str0668);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00E8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00E8 > 0) { 
   FileSeek(Gi_00E8, 0, 2);
   tmp_str0675 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00E8, tmp_str0675, " VERBOSE: ", tmp_str0673, tmp_str0672, tmp_str0671, tmp_str0670, tmp_str066F, tmp_str066E, tmp_str066D, tmp_str066C, tmp_str066B, tmp_str066A, tmp_str0669, tmp_str0668);
   FileClose(Gi_00E8);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0193 = GetLastError();
   Li_FFDC = Gi_0193;
   tmp_str0676 = "";
   tmp_str0677 = "";
   tmp_str0678 = (string)OrderStopLoss();
   tmp_str0679 = " Current SL: ";
   tmp_str067A = (string)(string)Bid;
   tmp_str067B = ", Bid: ";
   tmp_str067C = (string)Ask;
   tmp_str067D = ", Ask: ";
   tmp_str067E = ErrorDescription(Gi_0193);
   tmp_str067F = " - ";
   tmp_str0680 = (string)Gi_0193;
   tmp_str0681 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0682 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0682, " ", tmp_str0681, tmp_str0680, tmp_str067F, tmp_str067E, tmp_str067D, tmp_str067C, tmp_str067B, tmp_str067A, tmp_str0679, tmp_str0678, tmp_str0677, tmp_str0676);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00E9 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00E9 > 0) { 
   FileSeek(Gi_00E9, 0, 2);
   tmp_str0683 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00E9, tmp_str0683, " VERBOSE: ", tmp_str0681, tmp_str0680, tmp_str067F, tmp_str067E, tmp_str067D, tmp_str067C, tmp_str067B, tmp_str067A, tmp_str0679, tmp_str0678, tmp_str0677, tmp_str0676);
   FileClose(Gi_00E9);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0030, OrderType(), OrderOpenPrice());
   Gi_00EA = Ii_0030;
   Gd_00EB = 0;
   if (Ii_0030 == Ii_0000) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0004) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0008) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_000C) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0010) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0014) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0018) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_001C) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0020) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0024) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0028) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_002C) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0030) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   if (Gi_00EA == Ii_0034) { 
   Gd_00EB = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00EB, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str0684 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0684 != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str0686 = "";
   tmp_str0687 = "";
   tmp_str0688 = "";
   tmp_str0689 = "";
   tmp_str068A = "";
   tmp_str068B = "";
   tmp_str068C = (string)Ld_FFE8;
   tmp_str068D = " to :";
   tmp_str068E = (string)Fa_i_00;
   tmp_str068F = ", Magic Number: ";
   tmp_str0690 = (string)OrderTicket();
   tmp_str0691 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0692 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0692, " ", tmp_str0691, tmp_str0690, tmp_str068F, tmp_str068E, tmp_str068D, tmp_str068C, tmp_str068B, tmp_str068A, tmp_str0689, tmp_str0688, tmp_str0687, tmp_str0686);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00EC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00EC > 0) { 
   FileSeek(Gi_00EC, 0, 2);
   tmp_str0693 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00EC, tmp_str0693, " VERBOSE: ", tmp_str0691, tmp_str0690, tmp_str068F, tmp_str068E, tmp_str068D, tmp_str068C, tmp_str068B, tmp_str068A, tmp_str0689, tmp_str0688, tmp_str0687, tmp_str0686);
   FileClose(Gi_00EC);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0196 = GetLastError();
   Li_FFDC = Gi_0196;
   tmp_str0694 = "";
   tmp_str0695 = "";
   tmp_str0696 = (string)OrderStopLoss();
   tmp_str0697 = " Current SL: ";
   tmp_str0698 = (string)Bid;
   tmp_str0699 = ", Bid: ";
   tmp_str069A = (string)Ask;
   tmp_str069B = ", Ask: ";
   tmp_str069C = ErrorDescription(Gi_0196);
   tmp_str069D = " - ";
   tmp_str069E = (string)Gi_0196;
   tmp_str069F = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str06A0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str06A0, " ", tmp_str069F, tmp_str069E, tmp_str069D, tmp_str069C, tmp_str069B, tmp_str069A, tmp_str0699, tmp_str0698, tmp_str0697, tmp_str0696, tmp_str0695, tmp_str0694);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00ED = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00ED > 0) {
   FileSeek(Gi_00ED, 0, 2);
   tmp_str06A1 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00ED, tmp_str06A1, " VERBOSE: ", tmp_str069F, tmp_str069E, tmp_str069D, tmp_str069C, tmp_str069B, tmp_str069A, tmp_str0699, tmp_str0698, tmp_str0697, tmp_str0696, tmp_str0695, tmp_str0694);
   FileClose(Gi_00ED);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str06A2 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str06A2 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str06A4 = "";
   tmp_str06A5 = "";
   tmp_str06A6 = "";
   tmp_str06A7 = "";
   tmp_str06A8 = "";
   tmp_str06A9 = "";
   tmp_str06AA = (string)Ld_FFE8;
   tmp_str06AB = " to :";
   tmp_str06AC = (string)Fa_i_00;
   tmp_str06AD = ", Magic Number: ";
   tmp_str06AE = (string)OrderTicket();
   tmp_str06AF = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str06B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str06B0, " ", tmp_str06AF, tmp_str06AE, tmp_str06AD, tmp_str06AC, tmp_str06AB, tmp_str06AA, tmp_str06A9, tmp_str06A8, tmp_str06A7, tmp_str06A6, tmp_str06A5, tmp_str06A4);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00EE = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00EE > 0) { 
   FileSeek(Gi_00EE, 0, 2);
   tmp_str06B1 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00EE, tmp_str06B1, " VERBOSE: ", tmp_str06AF, tmp_str06AE, tmp_str06AD, tmp_str06AC, tmp_str06AB, tmp_str06AA, tmp_str06A9, tmp_str06A8, tmp_str06A7, tmp_str06A6, tmp_str06A5, tmp_str06A4);
   FileClose(Gi_00EE);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0198 = GetLastError();
   Li_FFDC = Gi_0198;
   tmp_str06B2 = "";
   tmp_str06B3 = "";
   tmp_str06B4 = (string)OrderStopLoss();
   tmp_str06B5 = " Current SL: ";
   tmp_str06B6 = (string)Bid;
   tmp_str06B7 = ", Bid: ";
   tmp_str06B8 = (string)Ask;
   tmp_str06B9 = ", Ask: ";
   tmp_str06BA = ErrorDescription(Gi_0198);
   tmp_str06BB = " - ";
   tmp_str06BC = (string)Gi_0198;
   tmp_str06BD = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str06BE = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str06BE, " ", tmp_str06BD, tmp_str06BC, tmp_str06BB, tmp_str06BA, tmp_str06B9, tmp_str06B8, tmp_str06B7, tmp_str06B6, tmp_str06B5, tmp_str06B4, tmp_str06B3, tmp_str06B2);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00EF = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00EF > 0) { 
   FileSeek(Gi_00EF, 0, 2);
   tmp_str06BF = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00EF, tmp_str06BF, " VERBOSE: ", tmp_str06BD, tmp_str06BC, tmp_str06BB, tmp_str06BA, tmp_str06B9, tmp_str06B8, tmp_str06B7, tmp_str06B6, tmp_str06B5, tmp_str06B4, tmp_str06B3, tmp_str06B2);
   FileClose(Gi_00EF);
   }}}}}}}}} 
   Gi_00F0 = Ii_0030;
   Gd_00F1 = 0;
   if (Ii_0030 == Ii_0000) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0004) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0008) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_000C) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0010) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0014) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0018) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_001C) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0020) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0024) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0028) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_002C) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0030) { 
   Gd_00F1 = 0;
   } 
   if (Gi_00F0 == Ii_0034) { 
   Gd_00F1 = 0;
   } 
   returned_double = NormalizeDouble(Gd_00F1, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 > 0)) { 
   Gi_00F2 = (int)(returned_double + 10);
   Gl_00F3 = OrderOpenTime();
   Gi_00F4 = 0;
   Gi_00F5 = 0;
   Gi_0198 = Gi_00F2 + 10;
   if (Gi_0198 > 0) { 
   do { 
   if (Gl_00F3 < Time[Gi_00F5]) { 
   Gi_00F4 = Gi_00F4 + 1;
   } 
   Gi_00F5 = Gi_00F5 + 1;
   Gi_0199 = Gi_00F2 + 10;
   } while (Gi_00F5 < Gi_0199); 
   } 
   if ((Gi_00F4 >= Ld_FFF8)) { 
   tmp_str06C0 = "";
   tmp_str06C1 = "";
   tmp_str06C2 = "";
   tmp_str06C3 = "";
   tmp_str06C4 = "";
   tmp_str06C5 = "";
   tmp_str06C6 = (string)Fa_i_00;
   tmp_str06C7 = ", Magic Number: ";
   tmp_str06C8 = (string)OrderTicket();
   tmp_str06C9 = "bars - closing order with ticket: ";
   tmp_str06CA = (string)Ld_FFF8;
   tmp_str06CB = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str06CC = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str06CC, " ", tmp_str06CB, tmp_str06CA, tmp_str06C9, tmp_str06C8, tmp_str06C7, tmp_str06C6, tmp_str06C5, tmp_str06C4, tmp_str06C3, tmp_str06C2, tmp_str06C1, tmp_str06C0);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00F6 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00F6 > 0) { 
   FileSeek(Gi_00F6, 0, 2);
   tmp_str06CD = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00F6, tmp_str06CD, " VERBOSE: ", tmp_str06CB, tmp_str06CA, tmp_str06C9, tmp_str06C8, tmp_str06C7, tmp_str06C6, tmp_str06C5, tmp_str06C4, tmp_str06C3, tmp_str06C2, tmp_str06C1, tmp_str06C0);
   FileClose(Gi_00F6);
   }}} 
   sqClosePositionAtMarket(-1);
   }}}} 
   if (Fa_i_00 != Ii_0034) return; 
   if (OrderType() != OP_BUY) { 
   if (OrderType() != OP_SELL) return; 
   } 
   Ld_FFF8 = getOrderTrailingStop(Ii_0034, OrderType(), OrderOpenPrice());
   if ((Ld_FFF8 > 0)) { 
   Gi_00F7 = Ii_0034;
   Gd_00F8 = 0;
   if (Ii_0034 == Ii_0000) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0004) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0008) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_000C) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0010) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0014) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0018) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_001C) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0020) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0024) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0028) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_002C) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0030) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   if (Gi_00F7 == Ii_0034) { 
   Gd_00F8 = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00F8, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_FFE0 = (Bid - OrderOpenPrice());
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFF8)) {
   
   tmp_str06CE = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str06CE != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str06D0 = "";
   tmp_str06D1 = "";
   tmp_str06D2 = "";
   tmp_str06D3 = "";
   tmp_str06D4 = "";
   tmp_str06D5 = "";
   tmp_str06D6 = (string)Ld_FFE8;
   tmp_str06D7 = " to :";
   tmp_str06D8 = (string)Fa_i_00;
   tmp_str06D9 = ", Magic Number: ";
   tmp_str06DA = (string)OrderTicket();
   tmp_str06DB = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str06DC = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str06DC, " ", tmp_str06DB, tmp_str06DA, tmp_str06D9, tmp_str06D8, tmp_str06D7, tmp_str06D6, tmp_str06D5, tmp_str06D4, tmp_str06D3, tmp_str06D2, tmp_str06D1, tmp_str06D0);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00F9 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00F9 > 0) { 
   FileSeek(Gi_00F9, 0, 2);
   tmp_str06DD = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00F9, tmp_str06DD, " VERBOSE: ", tmp_str06DB, tmp_str06DA, tmp_str06D9, tmp_str06D8, tmp_str06D7, tmp_str06D6, tmp_str06D5, tmp_str06D4, tmp_str06D3, tmp_str06D2, tmp_str06D1, tmp_str06D0);
   FileClose(Gi_00F9);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_019C = GetLastError();
   Li_FFDC = Gi_019C;
   tmp_str06DE = "";
   tmp_str06DF = "";
   tmp_str06E0 = "";
   tmp_str06E1 = "";
   tmp_str06E2 = "";
   tmp_str06E3 = "";
   tmp_str06E4 = "";
   tmp_str06E5 = "";
   tmp_str06E6 = ErrorDescription(Gi_019C);
   tmp_str06E7 = " - ";
   tmp_str06E8 = (string)Gi_019C;
   tmp_str06E9 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str06EA = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str06EA, " ", tmp_str06E9, tmp_str06E8, tmp_str06E7, tmp_str06E6, tmp_str06E5, tmp_str06E4, tmp_str06E3, tmp_str06E2, tmp_str06E1, tmp_str06E0, tmp_str06DF, tmp_str06DE);
   }
   else{
   if (Ii_007C == 2) {
   Gi_00FA = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00FA > 0) {
   FileSeek(Gi_00FA, 0, 2);
   tmp_str06EB = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00FA, tmp_str06EB, " VERBOSE: ", tmp_str06E9, tmp_str06E8, tmp_str06E7, tmp_str06E6, tmp_str06E5, tmp_str06E4, tmp_str06E3, tmp_str06E2, tmp_str06E1, tmp_str06E0, tmp_str06DF, tmp_str06DE);
   FileClose(Gi_00FA);
   }}}}}}}}
   else{
   Ld_FFE0 = (OrderOpenPrice() - Ask);
   Ld_FFE8 = Ld_FFF8;
   if ((Ld_FFE0 >= Ld_FFF0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFF8)) { 
   
   tmp_str06EC = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str06EC != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str06EE = "";
   tmp_str06EF = "";
   tmp_str06F0 = "";
   tmp_str06F1 = "";
   tmp_str06F2 = "";
   tmp_str06F3 = "";
   tmp_str06F4 = (string)Ld_FFE8;
   tmp_str06F5 = " to :";
   tmp_str06F6 = (string)Fa_i_00;
   tmp_str06F7 = ", Magic Number: ";
   tmp_str06F8 = (string)OrderTicket();
   tmp_str06F9 = "Moving trailing stop for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str06FA = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str06FA, " ", tmp_str06F9, tmp_str06F8, tmp_str06F7, tmp_str06F6, tmp_str06F5, tmp_str06F4, tmp_str06F3, tmp_str06F2, tmp_str06F1, tmp_str06F0, tmp_str06EF, tmp_str06EE);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00FB = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00FB > 0) { 
   FileSeek(Gi_00FB, 0, 2);
   tmp_str06FB = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00FB, tmp_str06FB, " VERBOSE: ", tmp_str06F9, tmp_str06F8, tmp_str06F7, tmp_str06F6, tmp_str06F5, tmp_str06F4, tmp_str06F3, tmp_str06F2, tmp_str06F1, tmp_str06F0, tmp_str06EF, tmp_str06EE);
   FileClose(Gi_00FB);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_019E = GetLastError();
   Li_FFDC = Gi_019E;
   tmp_str06FC = "";
   tmp_str06FD = "";
   tmp_str06FE = (string)OrderStopLoss();
   tmp_str06FF = " Current SL: ";
   tmp_str0700 = (string)Bid;
   tmp_str0701 = ", Bid: ";
   tmp_str0702 = (string)Ask;
   tmp_str0703 = ", Ask: ";
   tmp_str0704 = ErrorDescription(Gi_019E);
   tmp_str0705 = " - ";
   tmp_str0706 = (string)Gi_019E;
   tmp_str0707 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0708 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0708, " ", tmp_str0707, tmp_str0706, tmp_str0705, tmp_str0704, tmp_str0703, tmp_str0702, tmp_str0701, tmp_str0700, tmp_str06FF, tmp_str06FE, tmp_str06FD, tmp_str06FC);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00FC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00FC > 0) { 
   FileSeek(Gi_00FC, 0, 2);
   tmp_str0709 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00FC, tmp_str0709, " VERBOSE: ", tmp_str0707, tmp_str0706, tmp_str0705, tmp_str0704, tmp_str0703, tmp_str0702, tmp_str0701, tmp_str0700, tmp_str06FF, tmp_str06FE, tmp_str06FD, tmp_str06FC);
   FileClose(Gi_00FC);
   }}}}}}}}} 
   Ld_FFF8 = getOrderBreakEven(Ii_0034, OrderType(), OrderOpenPrice());
   Gi_00FD = Ii_0034;
   Gd_00FE = 0;
   if (Ii_0034 == Ii_0000) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0004) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0008) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_000C) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0010) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0014) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0018) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_001C) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0020) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0024) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0028) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_002C) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0030) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   if (Gi_00FD == Ii_0034) { 
   Gd_00FE = (Id_0090 * 0);
   } 
   Ld_FFF0 = NormalizeDouble(Gd_00FE, _Digits);
   if ((Ld_FFF8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_FFE8 = (OrderOpenPrice() + Ld_FFF0);
   if ((OrderOpenPrice() <= Ld_FFF8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_FFE8)) {
   
   tmp_str070A = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str070A != DoubleToString(Ld_FFE8, _Digits)) {
   tmp_str070C = "";
   tmp_str070D = "";
   tmp_str070E = "";
   tmp_str070F = "";
   tmp_str0710 = "";
   tmp_str0711 = "";
   tmp_str0712 = (string)Ld_FFE8;
   tmp_str0713 = " to :";
   tmp_str0714 = (string)Fa_i_00;
   tmp_str0715 = ", Magic Number: ";
   tmp_str0716 = (string)OrderTicket();
   tmp_str0717 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0718 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0718, " ", tmp_str0717, tmp_str0716, tmp_str0715, tmp_str0714, tmp_str0713, tmp_str0712, tmp_str0711, tmp_str0710, tmp_str070F, tmp_str070E, tmp_str070D, tmp_str070C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_00FF = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_00FF > 0) { 
   FileSeek(Gi_00FF, 0, 2);
   tmp_str0719 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_00FF, tmp_str0719, " VERBOSE: ", tmp_str0717, tmp_str0716, tmp_str0715, tmp_str0714, tmp_str0713, tmp_str0712, tmp_str0711, tmp_str0710, tmp_str070F, tmp_str070E, tmp_str070D, tmp_str070C);
   FileClose(Gi_00FF);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_01A1 = GetLastError();
   Li_FFDC = Gi_01A1;
   tmp_str071A = "";
   tmp_str071B = "";
   tmp_str071C = (string)OrderStopLoss();
   tmp_str071D = " Current SL: ";
   tmp_str071E = (string)Bid;
   tmp_str071F = ", Bid: ";
   tmp_str0720 = (string)Ask;
   tmp_str0721 = ", Ask: ";
   tmp_str0722 = ErrorDescription(Gi_01A1);
   tmp_str0723 = " - ";
   tmp_str0724 = (string)Gi_01A1;
   tmp_str0725 = "Failed, error: ";
   if (Ii_007C == 1) {
   tmp_str0726 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0726, " ", tmp_str0725, tmp_str0724, tmp_str0723, tmp_str0722, tmp_str0721, tmp_str0720, tmp_str071F, tmp_str071E, tmp_str071D, tmp_str071C, tmp_str071B, tmp_str071A);
   }
   else{
   if (Ii_007C == 2) {
   Gi_0100 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0100 > 0) {
   FileSeek(Gi_0100, 0, 2);
   tmp_str0727 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0100, tmp_str0727, " VERBOSE: ", tmp_str0725, tmp_str0724, tmp_str0723, tmp_str0722, tmp_str0721, tmp_str0720, tmp_str071F, tmp_str071E, tmp_str071D, tmp_str071C, tmp_str071B, tmp_str071A);
   FileClose(Gi_0100);
   }}}}}}}}
   else{
   Ld_FFE8 = (OrderOpenPrice() - Ld_FFF0);
   if ((OrderOpenPrice() >= Ld_FFF8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_FFE8)) { 
   
   tmp_str0728 = DoubleToString(OrderStopLoss(), _Digits);
   if (tmp_str0728 != DoubleToString(Ld_FFE8, _Digits)) { 
   tmp_str072A = "";
   tmp_str072B = "";
   tmp_str072C = "";
   tmp_str072D = "";
   tmp_str072E = "";
   tmp_str072F = "";
   tmp_str0730 = (string)Ld_FFE8;
   tmp_str0731 = " to :";
   tmp_str0732 = (string)Fa_i_00;
   tmp_str0733 = ", Magic Number: ";
   tmp_str0734 = (string)OrderTicket();
   tmp_str0735 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0736 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0736, " ", tmp_str0735, tmp_str0734, tmp_str0733, tmp_str0732, tmp_str0731, tmp_str0730, tmp_str072F, tmp_str072E, tmp_str072D, tmp_str072C, tmp_str072B, tmp_str072A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0101 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0101 > 0) { 
   FileSeek(Gi_0101, 0, 2);
   tmp_str0737 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0101, tmp_str0737, " VERBOSE: ", tmp_str0735, tmp_str0734, tmp_str0733, tmp_str0732, tmp_str0731, tmp_str0730, tmp_str072F, tmp_str072E, tmp_str072D, tmp_str072C, tmp_str072B, tmp_str072A);
   FileClose(Gi_0101);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_FFE8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_01A3 = GetLastError();
   Li_FFDC = Gi_01A3;
   tmp_str0738 = "";
   tmp_str0739 = "";
   tmp_str073A = (string)OrderStopLoss();
   tmp_str073B = " Current SL: ";
   tmp_str073C = (string)Bid;
   tmp_str073D = ", Bid: ";
   tmp_str073E = (string)Ask;
   tmp_str073F = ", Ask: ";
   tmp_str0740 = ErrorDescription(Gi_01A3);
   tmp_str0741 = " - ";
   tmp_str0742 = (string)Gi_01A3;
   tmp_str0743 = "Failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0744 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0744, " ", tmp_str0743, tmp_str0742, tmp_str0741, tmp_str0740, tmp_str073F, tmp_str073E, tmp_str073D, tmp_str073C, tmp_str073B, tmp_str073A, tmp_str0739, tmp_str0738);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0102 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0102 > 0) { 
   FileSeek(Gi_0102, 0, 2);
   tmp_str0745 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0102, tmp_str0745, " VERBOSE: ", tmp_str0743, tmp_str0742, tmp_str0741, tmp_str0740, tmp_str073F, tmp_str073E, tmp_str073D, tmp_str073C, tmp_str073B, tmp_str073A, tmp_str0739, tmp_str0738);
   FileClose(Gi_0102);
   }}}}}}}}} 
   Gi_0103 = Ii_0034;
   Gd_0104 = 0;
   if (Ii_0034 == Ii_0000) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0004) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0008) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_000C) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0010) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0014) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0018) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_001C) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0020) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0024) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0028) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_002C) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0030) { 
   Gd_0104 = 0;
   } 
   if (Gi_0103 == Ii_0034) { 
   Gd_0104 = 0;
   } 
   returned_double = NormalizeDouble(Gd_0104, _Digits);
   Ld_FFF8 = returned_double;
   if ((Ld_FFF8 <= 0)) return; 
   Gi_0105 = (int)(returned_double + 10);
   Gl_0106 = OrderOpenTime();
   Gi_0107 = 0;
   Gi_0108 = 0;
   Gi_01A3 = Gi_0105 + 10;
   if (Gi_01A3 > 0) { 
   do { 
   if (Gl_0106 < Time[Gi_0108]) { 
   Gi_0107 = Gi_0107 + 1;
   } 
   Gi_0108 = Gi_0108 + 1;
   Gi_01A4 = Gi_0105 + 10;
   } while (Gi_0108 < Gi_01A4); 
   } 
   if ((Gi_0107 < Ld_FFF8)) return; 
   tmp_str0746 = "";
   tmp_str0747 = "";
   tmp_str0748 = "";
   tmp_str0749 = "";
   tmp_str074A = "";
   tmp_str074B = "";
   tmp_str074C = (string)Fa_i_00;
   tmp_str074D = ", Magic Number: ";
   tmp_str074E = (string)OrderTicket();
   tmp_str074F = "bars - closing order with ticket: ";
   tmp_str0750 = (string)Ld_FFF8;
   tmp_str0751 = "Exit After ";
   if (Ii_007C == 1) { 
   tmp_str0752 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0752, " ", tmp_str0751, tmp_str0750, tmp_str074F, tmp_str074E, tmp_str074D, tmp_str074C, tmp_str074B, tmp_str074A, tmp_str0749, tmp_str0748, tmp_str0747, tmp_str0746);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0109 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0109 > 0) { 
   FileSeek(Gi_0109, 0, 2);
   tmp_str0753 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0109, tmp_str0753, " VERBOSE: ", tmp_str0751, tmp_str0750, tmp_str074F, tmp_str074E, tmp_str074D, tmp_str074C, tmp_str074B, tmp_str074A, tmp_str0749, tmp_str0748, tmp_str0747, tmp_str0746);
   FileClose(Gi_0109);
   }}} 
   sqClosePositionAtMarket(-1);
   
}

void manageOrderExpiration(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   string tmp_str0030;
   string tmp_str0031;
   string tmp_str0032;
   string tmp_str0033;
   string tmp_str0034;
   string tmp_str0035;
   string tmp_str0036;
   string tmp_str0037;
   string tmp_str0038;
   string tmp_str0039;
   string tmp_str003A;
   string tmp_str003B;
   string tmp_str003C;
   string tmp_str003D;
   string tmp_str003E;
   string tmp_str003F;
   string tmp_str0040;
   string tmp_str0041;
   string tmp_str0042;
   string tmp_str0043;
   string tmp_str0044;
   string tmp_str0045;
   string tmp_str0046;
   string tmp_str0047;
   string tmp_str0048;
   string tmp_str0049;
   string tmp_str004A;
   string tmp_str004B;
   string tmp_str004C;
   string tmp_str004D;
   string tmp_str004E;
   string tmp_str004F;
   string tmp_str0050;
   string tmp_str0051;
   string tmp_str0052;
   string tmp_str0053;
   string tmp_str0054;
   string tmp_str0055;
   string tmp_str0056;
   string tmp_str0057;
   string tmp_str0058;
   string tmp_str0059;
   string tmp_str005A;
   string tmp_str005B;
   string tmp_str005C;
   string tmp_str005D;
   string tmp_str005E;
   string tmp_str005F;
   string tmp_str0060;
   string tmp_str0061;
   string tmp_str0062;
   string tmp_str0063;
   string tmp_str0064;
   string tmp_str0065;
   string tmp_str0066;
   string tmp_str0067;
   string tmp_str0068;
   string tmp_str0069;
   string tmp_str006A;
   string tmp_str006B;
   string tmp_str006C;
   string tmp_str006D;
   string tmp_str006E;
   string tmp_str006F;
   string tmp_str0070;
   string tmp_str0071;
   string tmp_str0072;
   string tmp_str0073;
   string tmp_str0074;
   string tmp_str0075;
   string tmp_str0076;
   string tmp_str0077;
   string tmp_str0078;
   string tmp_str0079;
   string tmp_str007A;
   string tmp_str007B;
   string tmp_str007C;
   string tmp_str007D;
   string tmp_str007E;
   string tmp_str007F;
   string tmp_str0080;
   string tmp_str0081;
   string tmp_str0082;
   string tmp_str0083;
   string tmp_str0084;
   string tmp_str0085;
   string tmp_str0086;
   string tmp_str0087;
   string tmp_str0088;
   string tmp_str0089;
   string tmp_str008A;
   string tmp_str008B;
   string tmp_str008C;
   string tmp_str008D;
   string tmp_str008E;
   string tmp_str008F;
   string tmp_str0090;
   string tmp_str0091;
   string tmp_str0092;
   string tmp_str0093;
   string tmp_str0094;
   string tmp_str0095;
   string tmp_str0096;
   string tmp_str0097;
   string tmp_str0098;
   string tmp_str0099;
   string tmp_str009A;
   string tmp_str009B;
   string tmp_str009C;
   string tmp_str009D;
   string tmp_str009E;
   string tmp_str009F;
   string tmp_str00A0;
   string tmp_str00A1;
   string tmp_str00A2;
   string tmp_str00A3;
   string tmp_str00A4;
   string tmp_str00A5;
   string tmp_str00A6;
   string tmp_str00A7;
   string tmp_str00A8;
   string tmp_str00A9;
   string tmp_str00AA;
   string tmp_str00AB;
   string tmp_str00AC;
   string tmp_str00AD;
   string tmp_str00AE;
   string tmp_str00AF;
   string tmp_str00B0;
   string tmp_str00B1;
   string tmp_str00B2;
   string tmp_str00B3;
   string tmp_str00B4;
   string tmp_str00B5;
   string tmp_str00B6;
   string tmp_str00B7;
   string tmp_str00B8;
   string tmp_str00B9;
   string tmp_str00BA;
   string tmp_str00BB;
   string tmp_str00BC;
   string tmp_str00BD;
   string tmp_str00BE;
   string tmp_str00BF;
   string tmp_str00C0;
   string tmp_str00C1;
   string tmp_str00C2;
   string tmp_str00C3;
   int Li_FFFC;
   int Li_FFF8;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Gi_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   Gl_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = 0;
   Gi_0007 = 0;
   Gd_0008 = 0;
   Gi_0009 = 0;
   Gl_000A = 0;
   Gi_000B = 0;
   Gi_000C = 0;
   Gi_000D = 0;
   Gi_000E = 0;
   Gd_000F = 0;
   Gi_0010 = 0;
   Gl_0011 = 0;
   Gi_0012 = 0;
   Gi_0013 = 0;
   Gi_0014 = 0;
   Gi_0015 = 0;
   Gd_0016 = 0;
   Gi_0017 = 0;
   Gl_0018 = 0;
   Gi_0019 = 0;
   Gi_001A = 0;
   Gi_001B = 0;
   Gi_001C = 0;
   Gd_001D = 0;
   Gi_001E = 0;
   Gl_001F = 0;
   Gi_0020 = 0;
   Gi_0021 = 0;
   Gi_0022 = 0;
   Gi_0023 = 0;
   Gd_0024 = 0;
   Gi_0025 = 0;
   Gl_0026 = 0;
   Gi_0027 = 0;
   Gi_0028 = 0;
   Gi_0029 = 0;
   Gi_002A = 0;
   Gd_002B = 0;
   Gi_002C = 0;
   Gl_002D = 0;
   Gi_002E = 0;
   Gi_002F = 0;
   Gi_0030 = 0;
   Gi_0031 = 0;
   Gd_0032 = 0;
   Gi_0033 = 0;
   Gl_0034 = 0;
   Gi_0035 = 0;
   Gi_0036 = 0;
   Gi_0037 = 0;
   Gi_0038 = 0;
   Gd_0039 = 0;
   Gi_003A = 0;
   Gl_003B = 0;
   Gi_003C = 0;
   Gi_003D = 0;
   Gi_003E = 0;
   Gi_003F = 0;
   Gd_0040 = 0;
   Gi_0041 = 0;
   Gl_0042 = 0;
   Gi_0043 = 0;
   Gi_0044 = 0;
   Gi_0045 = 0;
   Gi_0046 = 0;
   Gd_0047 = 0;
   Gi_0048 = 0;
   Gl_0049 = 0;
   Gi_004A = 0;
   Gi_004B = 0;
   Gi_004C = 0;
   Gi_004D = 0;
   Gd_004E = 0;
   Gi_004F = 0;
   Gl_0050 = 0;
   Gi_0051 = 0;
   Gi_0052 = 0;
   Gi_0053 = 0;
   Gi_0054 = 0;
   Gd_0055 = 0;
   Gi_0056 = 0;
   Gl_0057 = 0;
   Gi_0058 = 0;
   Gi_0059 = 0;
   Gi_005A = 0;
   Gi_005B = 0;
   Gd_005C = 0;
   Gi_005D = 0;
   Gl_005E = 0;
   Gi_005F = 0;
   Gi_0060 = 0;
   Gi_0061 = 0;
   Li_FFFC = 0;
   Li_FFF8 = 0;
   if (Fa_i_00 == Ii_0000 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_0000 = Ii_0000;
   Gd_0001 = 0;
   if (Ii_0000 == Ii_0000) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0004) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0008) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_000C) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0010) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0014) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0018) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_001C) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0020) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0024) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0028) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_002C) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0030) { 
   Gd_0001 = 0;
   } 
   if (Gi_0000 == Ii_0034) { 
   Gd_0001 = 0;
   } 
   Li_FFFC =(int) NormalizeDouble(Gd_0001, _Digits);
   if (Li_FFFC > 0) { 
   Gi_0062 = Li_FFFC + 10;
   Gi_0002 = Gi_0062;
   Gl_0003 = OrderOpenTime();
   Gi_0004 = 0;
   Gi_0005 = 0;
   Gi_0062 = Gi_0062 + 10;
   if (Gi_0062 > 0) { 
   do { 
   if (Gl_0003 < Time[Gi_0005]) { 
   Gi_0004 = Gi_0004 + 1;
   } 
   Gi_0005 = Gi_0005 + 1;
   Gi_0063 = Gi_0002 + 10;
   } while (Gi_0005 < Gi_0063); 
   } 
   Li_FFF8 = Gi_0004;
   if (Gi_0004 >= Li_FFFC) { 
   tmp_str0000 = "";
   tmp_str0001 = "";
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = " expired";
   tmp_str0008 = (string)Fa_i_00;
   tmp_str0009 = ", Magic Number: ";
   tmp_str000A = (string)OrderTicket();
   tmp_str000B = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str000C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str000C, " ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0006 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0006 > 0) { 
   FileSeek(Gi_0006, 0, 2);
   tmp_str000D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0006, tmp_str000D, " VERBOSE: ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   FileClose(Gi_0006);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0004 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_0007 = Ii_0004;
   Gd_0008 = 0;
   if (Ii_0004 == Ii_0000) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0004) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0008) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_000C) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0010) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0014) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0018) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_001C) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0020) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0024) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0028) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_002C) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0030) { 
   Gd_0008 = 0;
   } 
   if (Gi_0007 == Ii_0034) { 
   Gd_0008 = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_0008, _Digits);
   if (Li_FFFC > 0) { 
   Gi_0063 = Li_FFFC + 10;
   Gi_0009 = Gi_0063;
   Gl_000A = OrderOpenTime();
   Gi_000B = 0;
   Gi_000C = 0;
   Gi_0063 = Gi_0063 + 10;
   if (Gi_0063 > 0) { 
   do { 
   if (Gl_000A < Time[Gi_000C]) { 
   Gi_000B = Gi_000B + 1;
   } 
   Gi_000C = Gi_000C + 1;
   Gi_0064 = Gi_0009 + 10;
   } while (Gi_000C < Gi_0064); 
   } 
   Li_FFF8 = Gi_000B;
   if (Gi_000B >= Li_FFFC) { 
   tmp_str000E = "";
   tmp_str000F = "";
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = " expired";
   tmp_str0016 = (string)Fa_i_00;
   tmp_str0017 = ", Magic Number: ";
   tmp_str0018 = (string)OrderTicket();
   tmp_str0019 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str001A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str001A, " ", tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_000D = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_000D > 0) { 
   FileSeek(Gi_000D, 0, 2);
   tmp_str001B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_000D, tmp_str001B, " VERBOSE: ", tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   FileClose(Gi_000D);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0008 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_000E = Ii_0008;
   Gd_000F = 0;
   if (Ii_0008 == Ii_0000) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0004) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0008) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_000C) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0010) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0014) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0018) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_001C) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0020) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0024) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0028) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_002C) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0030) { 
   Gd_000F = 0;
   } 
   if (Gi_000E == Ii_0034) { 
   Gd_000F = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_000F, _Digits);
   if (Li_FFFC > 0) { 
   Gi_0064 = Li_FFFC + 10;
   Gi_0010 = Gi_0064;
   Gl_0011 = OrderOpenTime();
   Gi_0012 = 0;
   Gi_0013 = 0;
   Gi_0064 = Gi_0064 + 10;
   if (Gi_0064 > 0) { 
   do { 
   if (Gl_0011 < Time[Gi_0013]) { 
   Gi_0012 = Gi_0012 + 1;
   } 
   Gi_0013 = Gi_0013 + 1;
   Gi_0065 = Gi_0010 + 10;
   } while (Gi_0013 < Gi_0065); 
   } 
   Li_FFF8 = Gi_0012;
   if (Gi_0012 >= Li_FFFC) { 
   tmp_str001C = "";
   tmp_str001D = "";
   tmp_str001E = "";
   tmp_str001F = "";
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = "";
   tmp_str0023 = " expired";
   tmp_str0024 = (string)Fa_i_00;
   tmp_str0025 = ", Magic Number: ";
   tmp_str0026 = (string)OrderTicket();
   tmp_str0027 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0028 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0028, " ", tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0014 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0014 > 0) { 
   FileSeek(Gi_0014, 0, 2);
   tmp_str0029 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0014, tmp_str0029, " VERBOSE: ", tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C);
   FileClose(Gi_0014);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_000C && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_0015 = Ii_000C;
   Gd_0016 = 0;
   if (Ii_000C == Ii_0000) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0004) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0008) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_000C) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0010) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0014) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0018) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_001C) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0020) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0024) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0028) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_002C) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0030) { 
   Gd_0016 = 0;
   } 
   if (Gi_0015 == Ii_0034) { 
   Gd_0016 = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_0016, _Digits);
   if (Li_FFFC > 0) { 
   Gi_0065 = Li_FFFC + 10;
   Gi_0017 = Gi_0065;
   Gl_0018 = OrderOpenTime();
   Gi_0019 = 0;
   Gi_001A = 0;
   Gi_0065 = Gi_0065 + 10;
   if (Gi_0065 > 0) { 
   do { 
   if (Gl_0018 < Time[Gi_001A]) { 
   Gi_0019 = Gi_0019 + 1;
   } 
   Gi_001A = Gi_001A + 1;
   Gi_0066 = Gi_0017 + 10;
   } while (Gi_001A < Gi_0066); 
   } 
   Li_FFF8 = Gi_0019;
   if (Gi_0019 >= Li_FFFC) { 
   tmp_str002A = "";
   tmp_str002B = "";
   tmp_str002C = "";
   tmp_str002D = "";
   tmp_str002E = "";
   tmp_str002F = "";
   tmp_str0030 = "";
   tmp_str0031 = " expired";
   tmp_str0032 = (string)Fa_i_00;
   tmp_str0033 = ", Magic Number: ";
   tmp_str0034 = (string)OrderTicket();
   tmp_str0035 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0036 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0036, " ", tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_001B = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_001B > 0) { 
   FileSeek(Gi_001B, 0, 2);
   tmp_str0037 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_001B, tmp_str0037, " VERBOSE: ", tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A);
   FileClose(Gi_001B);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0010 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_001C = Ii_0010;
   Gd_001D = 0;
   if (Ii_0010 == Ii_0000) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0004) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0008) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_000C) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0010) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0014) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0018) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_001C) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0020) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0024) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0028) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_002C) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0030) { 
   Gd_001D = 0;
   } 
   if (Gi_001C == Ii_0034) { 
   Gd_001D = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_001D, _Digits);
   if (Li_FFFC > 0) { 
   Gi_0066 = Li_FFFC + 10;
   Gi_001E = Gi_0066;
   Gl_001F = OrderOpenTime();
   Gi_0020 = 0;
   Gi_0021 = 0;
   Gi_0066 = Gi_0066 + 10;
   if (Gi_0066 > 0) { 
   do { 
   if (Gl_001F < Time[Gi_0021]) { 
   Gi_0020 = Gi_0020 + 1;
   } 
   Gi_0021 = Gi_0021 + 1;
   Gi_0067 = Gi_001E + 10;
   } while (Gi_0021 < Gi_0067); 
   } 
   Li_FFF8 = Gi_0020;
   if (Gi_0020 >= Li_FFFC) { 
   tmp_str0038 = "";
   tmp_str0039 = "";
   tmp_str003A = "";
   tmp_str003B = "";
   tmp_str003C = "";
   tmp_str003D = "";
   tmp_str003E = "";
   tmp_str003F = " expired";
   tmp_str0040 = (string)Fa_i_00;
   tmp_str0041 = ", Magic Number: ";
   tmp_str0042 = (string)OrderTicket();
   tmp_str0043 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0044 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0044, " ", tmp_str0043, tmp_str0042, tmp_str0041, tmp_str0040, tmp_str003F, tmp_str003E, tmp_str003D, tmp_str003C, tmp_str003B, tmp_str003A, tmp_str0039, tmp_str0038);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0022 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0022 > 0) { 
   FileSeek(Gi_0022, 0, 2);
   tmp_str0045 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0022, tmp_str0045, " VERBOSE: ", tmp_str0043, tmp_str0042, tmp_str0041, tmp_str0040, tmp_str003F, tmp_str003E, tmp_str003D, tmp_str003C, tmp_str003B, tmp_str003A, tmp_str0039, tmp_str0038);
   FileClose(Gi_0022);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0014 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_0023 = Ii_0014;
   Gd_0024 = 0;
   if (Ii_0014 == Ii_0000) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0004) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0008) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_000C) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0010) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0014) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0018) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_001C) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0020) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0024) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0028) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_002C) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0030) { 
   Gd_0024 = 0;
   } 
   if (Gi_0023 == Ii_0034) { 
   Gd_0024 = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_0024, _Digits);
   if (Li_FFFC > 0) { 
   Gi_0067 = Li_FFFC + 10;
   Gi_0025 = Gi_0067;
   Gl_0026 = OrderOpenTime();
   Gi_0027 = 0;
   Gi_0028 = 0;
   Gi_0067 = Gi_0067 + 10;
   if (Gi_0067 > 0) { 
   do { 
   if (Gl_0026 < Time[Gi_0028]) { 
   Gi_0027 = Gi_0027 + 1;
   } 
   Gi_0028 = Gi_0028 + 1;
   Gi_0068 = Gi_0025 + 10;
   } while (Gi_0028 < Gi_0068); 
   } 
   Li_FFF8 = Gi_0027;
   if (Gi_0027 >= Li_FFFC) { 
   tmp_str0046 = "";
   tmp_str0047 = "";
   tmp_str0048 = "";
   tmp_str0049 = "";
   tmp_str004A = "";
   tmp_str004B = "";
   tmp_str004C = "";
   tmp_str004D = " expired";
   tmp_str004E = (string)Fa_i_00;
   tmp_str004F = ", Magic Number: ";
   tmp_str0050 = (string)OrderTicket();
   tmp_str0051 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0052 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0052, " ", tmp_str0051, tmp_str0050, tmp_str004F, tmp_str004E, tmp_str004D, tmp_str004C, tmp_str004B, tmp_str004A, tmp_str0049, tmp_str0048, tmp_str0047, tmp_str0046);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0029 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0029 > 0) { 
   FileSeek(Gi_0029, 0, 2);
   tmp_str0053 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0029, tmp_str0053, " VERBOSE: ", tmp_str0051, tmp_str0050, tmp_str004F, tmp_str004E, tmp_str004D, tmp_str004C, tmp_str004B, tmp_str004A, tmp_str0049, tmp_str0048, tmp_str0047, tmp_str0046);
   FileClose(Gi_0029);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0018 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_002A = Ii_0018;
   Gd_002B = 0;
   if (Ii_0018 == Ii_0000) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0004) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0008) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_000C) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0010) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0014) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0018) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_001C) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0020) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0024) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0028) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_002C) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0030) { 
   Gd_002B = 0;
   } 
   if (Gi_002A == Ii_0034) { 
   Gd_002B = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_002B, _Digits);
   if (Li_FFFC > 0) { 
   Gi_0068 = Li_FFFC + 10;
   Gi_002C = Gi_0068;
   Gl_002D = OrderOpenTime();
   Gi_002E = 0;
   Gi_002F = 0;
   Gi_0068 = Gi_0068 + 10;
   if (Gi_0068 > 0) { 
   do { 
   if (Gl_002D < Time[Gi_002F]) { 
   Gi_002E = Gi_002E + 1;
   } 
   Gi_002F = Gi_002F + 1;
   Gi_0069 = Gi_002C + 10;
   } while (Gi_002F < Gi_0069); 
   } 
   Li_FFF8 = Gi_002E;
   if (Gi_002E >= Li_FFFC) { 
   tmp_str0054 = "";
   tmp_str0055 = "";
   tmp_str0056 = "";
   tmp_str0057 = "";
   tmp_str0058 = "";
   tmp_str0059 = "";
   tmp_str005A = "";
   tmp_str005B = " expired";
   tmp_str005C = (string)Fa_i_00;
   tmp_str005D = ", Magic Number: ";
   tmp_str005E = (string)OrderTicket();
   tmp_str005F = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0060 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0060, " ", tmp_str005F, tmp_str005E, tmp_str005D, tmp_str005C, tmp_str005B, tmp_str005A, tmp_str0059, tmp_str0058, tmp_str0057, tmp_str0056, tmp_str0055, tmp_str0054);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0030 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0030 > 0) { 
   FileSeek(Gi_0030, 0, 2);
   tmp_str0061 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0030, tmp_str0061, " VERBOSE: ", tmp_str005F, tmp_str005E, tmp_str005D, tmp_str005C, tmp_str005B, tmp_str005A, tmp_str0059, tmp_str0058, tmp_str0057, tmp_str0056, tmp_str0055, tmp_str0054);
   FileClose(Gi_0030);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_001C && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_0031 = Ii_001C;
   Gd_0032 = 0;
   if (Ii_001C == Ii_0000) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0004) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0008) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_000C) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0010) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0014) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0018) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_001C) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0020) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0024) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0028) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_002C) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0030) { 
   Gd_0032 = 0;
   } 
   if (Gi_0031 == Ii_0034) { 
   Gd_0032 = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_0032, _Digits);
   if (Li_FFFC > 0) { 
   Gi_0069 = Li_FFFC + 10;
   Gi_0033 = Gi_0069;
   Gl_0034 = OrderOpenTime();
   Gi_0035 = 0;
   Gi_0036 = 0;
   Gi_0069 = Gi_0069 + 10;
   if (Gi_0069 > 0) { 
   do { 
   if (Gl_0034 < Time[Gi_0036]) { 
   Gi_0035 = Gi_0035 + 1;
   } 
   Gi_0036 = Gi_0036 + 1;
   Gi_006A = Gi_0033 + 10;
   } while (Gi_0036 < Gi_006A); 
   } 
   Li_FFF8 = Gi_0035;
   if (Gi_0035 >= Li_FFFC) { 
   tmp_str0062 = "";
   tmp_str0063 = "";
   tmp_str0064 = "";
   tmp_str0065 = "";
   tmp_str0066 = "";
   tmp_str0067 = "";
   tmp_str0068 = "";
   tmp_str0069 = " expired";
   tmp_str006A = (string)Fa_i_00;
   tmp_str006B = ", Magic Number: ";
   tmp_str006C = (string)OrderTicket();
   tmp_str006D = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str006E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str006E, " ", tmp_str006D, tmp_str006C, tmp_str006B, tmp_str006A, tmp_str0069, tmp_str0068, tmp_str0067, tmp_str0066, tmp_str0065, tmp_str0064, tmp_str0063, tmp_str0062);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0037 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0037 > 0) { 
   FileSeek(Gi_0037, 0, 2);
   tmp_str006F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0037, tmp_str006F, " VERBOSE: ", tmp_str006D, tmp_str006C, tmp_str006B, tmp_str006A, tmp_str0069, tmp_str0068, tmp_str0067, tmp_str0066, tmp_str0065, tmp_str0064, tmp_str0063, tmp_str0062);
   FileClose(Gi_0037);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0020 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_0038 = Ii_0020;
   Gd_0039 = 0;
   if (Ii_0020 == Ii_0000) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0004) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0008) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_000C) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0010) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0014) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0018) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_001C) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0020) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0024) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0028) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_002C) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0030) { 
   Gd_0039 = 0;
   } 
   if (Gi_0038 == Ii_0034) { 
   Gd_0039 = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_0039, _Digits);
   if (Li_FFFC > 0) { 
   Gi_006A = Li_FFFC + 10;
   Gi_003A = Gi_006A;
   Gl_003B = OrderOpenTime();
   Gi_003C = 0;
   Gi_003D = 0;
   Gi_006A = Gi_006A + 10;
   if (Gi_006A > 0) { 
   do { 
   if (Gl_003B < Time[Gi_003D]) { 
   Gi_003C = Gi_003C + 1;
   } 
   Gi_003D = Gi_003D + 1;
   Gi_006B = Gi_003A + 10;
   } while (Gi_003D < Gi_006B); 
   } 
   Li_FFF8 = Gi_003C;
   if (Gi_003C >= Li_FFFC) { 
   tmp_str0070 = "";
   tmp_str0071 = "";
   tmp_str0072 = "";
   tmp_str0073 = "";
   tmp_str0074 = "";
   tmp_str0075 = "";
   tmp_str0076 = "";
   tmp_str0077 = " expired";
   tmp_str0078 = (string)Fa_i_00;
   tmp_str0079 = ", Magic Number: ";
   tmp_str007A = (string)OrderTicket();
   tmp_str007B = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str007C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str007C, " ", tmp_str007B, tmp_str007A, tmp_str0079, tmp_str0078, tmp_str0077, tmp_str0076, tmp_str0075, tmp_str0074, tmp_str0073, tmp_str0072, tmp_str0071, tmp_str0070);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_003E = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_003E > 0) { 
   FileSeek(Gi_003E, 0, 2);
   tmp_str007D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_003E, tmp_str007D, " VERBOSE: ", tmp_str007B, tmp_str007A, tmp_str0079, tmp_str0078, tmp_str0077, tmp_str0076, tmp_str0075, tmp_str0074, tmp_str0073, tmp_str0072, tmp_str0071, tmp_str0070);
   FileClose(Gi_003E);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0024 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_003F = Ii_0024;
   Gd_0040 = 0;
   if (Ii_0024 == Ii_0000) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0004) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0008) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_000C) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0010) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0014) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0018) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_001C) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0020) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0024) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0028) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_002C) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0030) { 
   Gd_0040 = 0;
   } 
   if (Gi_003F == Ii_0034) { 
   Gd_0040 = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_0040, _Digits);
   if (Li_FFFC > 0) { 
   Gi_006B = Li_FFFC + 10;
   Gi_0041 = Gi_006B;
   Gl_0042 = OrderOpenTime();
   Gi_0043 = 0;
   Gi_0044 = 0;
   Gi_006B = Gi_006B + 10;
   if (Gi_006B > 0) { 
   do { 
   if (Gl_0042 < Time[Gi_0044]) { 
   Gi_0043 = Gi_0043 + 1;
   } 
   Gi_0044 = Gi_0044 + 1;
   Gi_006C = Gi_0041 + 10;
   } while (Gi_0044 < Gi_006C); 
   } 
   Li_FFF8 = Gi_0043;
   if (Gi_0043 >= Li_FFFC) { 
   tmp_str007E = "";
   tmp_str007F = "";
   tmp_str0080 = "";
   tmp_str0081 = "";
   tmp_str0082 = "";
   tmp_str0083 = "";
   tmp_str0084 = "";
   tmp_str0085 = " expired";
   tmp_str0086 = (string)Fa_i_00;
   tmp_str0087 = ", Magic Number: ";
   tmp_str0088 = (string)OrderTicket();
   tmp_str0089 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str008A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str008A, " ", tmp_str0089, tmp_str0088, tmp_str0087, tmp_str0086, tmp_str0085, tmp_str0084, tmp_str0083, tmp_str0082, tmp_str0081, tmp_str0080, tmp_str007F, tmp_str007E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0045 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0045 > 0) { 
   FileSeek(Gi_0045, 0, 2);
   tmp_str008B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0045, tmp_str008B, " VERBOSE: ", tmp_str0089, tmp_str0088, tmp_str0087, tmp_str0086, tmp_str0085, tmp_str0084, tmp_str0083, tmp_str0082, tmp_str0081, tmp_str0080, tmp_str007F, tmp_str007E);
   FileClose(Gi_0045);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0028 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_0046 = Ii_0028;
   Gd_0047 = 0;
   if (Ii_0028 == Ii_0000) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0004) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0008) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_000C) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0010) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0014) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0018) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_001C) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0020) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0024) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0028) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_002C) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0030) { 
   Gd_0047 = 0;
   } 
   if (Gi_0046 == Ii_0034) { 
   Gd_0047 = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_0047, _Digits);
   if (Li_FFFC > 0) { 
   Gi_006C = Li_FFFC + 10;
   Gi_0048 = Gi_006C;
   Gl_0049 = OrderOpenTime();
   Gi_004A = 0;
   Gi_004B = 0;
   Gi_006C = Gi_006C + 10;
   if (Gi_006C > 0) { 
   do { 
   if (Gl_0049 < Time[Gi_004B]) { 
   Gi_004A = Gi_004A + 1;
   } 
   Gi_004B = Gi_004B + 1;
   Gi_006D = Gi_0048 + 10;
   } while (Gi_004B < Gi_006D); 
   } 
   Li_FFF8 = Gi_004A;
   if (Gi_004A >= Li_FFFC) { 
   tmp_str008C = "";
   tmp_str008D = "";
   tmp_str008E = "";
   tmp_str008F = "";
   tmp_str0090 = "";
   tmp_str0091 = "";
   tmp_str0092 = "";
   tmp_str0093 = " expired";
   tmp_str0094 = (string)Fa_i_00;
   tmp_str0095 = ", Magic Number: ";
   tmp_str0096 = (string)OrderTicket();
   tmp_str0097 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str0098 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0098, " ", tmp_str0097, tmp_str0096, tmp_str0095, tmp_str0094, tmp_str0093, tmp_str0092, tmp_str0091, tmp_str0090, tmp_str008F, tmp_str008E, tmp_str008D, tmp_str008C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_004C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_004C > 0) { 
   FileSeek(Gi_004C, 0, 2);
   tmp_str0099 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_004C, tmp_str0099, " VERBOSE: ", tmp_str0097, tmp_str0096, tmp_str0095, tmp_str0094, tmp_str0093, tmp_str0092, tmp_str0091, tmp_str0090, tmp_str008F, tmp_str008E, tmp_str008D, tmp_str008C);
   FileClose(Gi_004C);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_002C && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_004D = Ii_002C;
   Gd_004E = 0;
   if (Ii_002C == Ii_0000) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0004) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0008) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_000C) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0010) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0014) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0018) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_001C) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0020) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0024) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0028) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_002C) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0030) { 
   Gd_004E = 0;
   } 
   if (Gi_004D == Ii_0034) { 
   Gd_004E = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_004E, _Digits);
   if (Li_FFFC > 0) { 
   Gi_006D = Li_FFFC + 10;
   Gi_004F = Gi_006D;
   Gl_0050 = OrderOpenTime();
   Gi_0051 = 0;
   Gi_0052 = 0;
   Gi_006D = Gi_006D + 10;
   if (Gi_006D > 0) { 
   do { 
   if (Gl_0050 < Time[Gi_0052]) { 
   Gi_0051 = Gi_0051 + 1;
   } 
   Gi_0052 = Gi_0052 + 1;
   Gi_006E = Gi_004F + 10;
   } while (Gi_0052 < Gi_006E); 
   } 
   Li_FFF8 = Gi_0051;
   if (Gi_0051 >= Li_FFFC) { 
   tmp_str009A = "";
   tmp_str009B = "";
   tmp_str009C = "";
   tmp_str009D = "";
   tmp_str009E = "";
   tmp_str009F = "";
   tmp_str00A0 = "";
   tmp_str00A1 = " expired";
   tmp_str00A2 = (string)Fa_i_00;
   tmp_str00A3 = ", Magic Number: ";
   tmp_str00A4 = (string)OrderTicket();
   tmp_str00A5 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str00A6 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00A6, " ", tmp_str00A5, tmp_str00A4, tmp_str00A3, tmp_str00A2, tmp_str00A1, tmp_str00A0, tmp_str009F, tmp_str009E, tmp_str009D, tmp_str009C, tmp_str009B, tmp_str009A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0053 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0053 > 0) { 
   FileSeek(Gi_0053, 0, 2);
   tmp_str00A7 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0053, tmp_str00A7, " VERBOSE: ", tmp_str00A5, tmp_str00A4, tmp_str00A3, tmp_str00A2, tmp_str00A1, tmp_str00A0, tmp_str009F, tmp_str009E, tmp_str009D, tmp_str009C, tmp_str009B, tmp_str009A);
   FileClose(Gi_0053);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0030 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Gi_0054 = Ii_0030;
   Gd_0055 = 0;
   if (Ii_0030 == Ii_0000) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0004) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0008) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_000C) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0010) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0014) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0018) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_001C) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0020) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0024) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0028) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_002C) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0030) { 
   Gd_0055 = 0;
   } 
   if (Gi_0054 == Ii_0034) { 
   Gd_0055 = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_0055, _Digits);
   if (Li_FFFC > 0) { 
   Gi_006E = Li_FFFC + 10;
   Gi_0056 = Gi_006E;
   Gl_0057 = OrderOpenTime();
   Gi_0058 = 0;
   Gi_0059 = 0;
   Gi_006E = Gi_006E + 10;
   if (Gi_006E > 0) { 
   do { 
   if (Gl_0057 < Time[Gi_0059]) { 
   Gi_0058 = Gi_0058 + 1;
   } 
   Gi_0059 = Gi_0059 + 1;
   Gi_006F = Gi_0056 + 10;
   } while (Gi_0059 < Gi_006F); 
   } 
   Li_FFF8 = Gi_0058;
   if (Gi_0058 >= Li_FFFC) { 
   tmp_str00A8 = "";
   tmp_str00A9 = "";
   tmp_str00AA = "";
   tmp_str00AB = "";
   tmp_str00AC = "";
   tmp_str00AD = "";
   tmp_str00AE = "";
   tmp_str00AF = " expired";
   tmp_str00B0 = (string)Fa_i_00;
   tmp_str00B1 = ", Magic Number: ";
   tmp_str00B2 = (string)OrderTicket();
   tmp_str00B3 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str00B4 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00B4, " ", tmp_str00B3, tmp_str00B2, tmp_str00B1, tmp_str00B0, tmp_str00AF, tmp_str00AE, tmp_str00AD, tmp_str00AC, tmp_str00AB, tmp_str00AA, tmp_str00A9, tmp_str00A8);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_005A = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_005A > 0) { 
   FileSeek(Gi_005A, 0, 2);
   tmp_str00B5 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_005A, tmp_str00B5, " VERBOSE: ", tmp_str00B3, tmp_str00B2, tmp_str00B1, tmp_str00B0, tmp_str00AF, tmp_str00AE, tmp_str00AD, tmp_str00AC, tmp_str00AB, tmp_str00AA, tmp_str00A9, tmp_str00A8);
   FileClose(Gi_005A);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 != Ii_0034) return; 
   if (OrderType() == 0) return; 
   if (OrderType() == OP_SELL) return; 
   Gi_005B = Ii_0034;
   Gd_005C = 0;
   if (Ii_0034 == Ii_0000) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0004) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0008) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_000C) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0010) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0014) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0018) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_001C) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0020) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0024) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0028) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_002C) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0030) { 
   Gd_005C = 0;
   } 
   if (Gi_005B == Ii_0034) { 
   Gd_005C = 0;
   } 
   Li_FFFC = (int)NormalizeDouble(Gd_005C, _Digits);
   if (Li_FFFC <= 0) return; 
   Gi_006F = Li_FFFC + 10;
   Gi_005D = Gi_006F;
   Gl_005E = OrderOpenTime();
   Gi_005F = 0;
   Gi_0060 = 0;
   Gi_006F = Gi_006F + 10;
   if (Gi_006F > 0) { 
   do { 
   if (Gl_005E < Time[Gi_0060]) { 
   Gi_005F = Gi_005F + 1;
   } 
   Gi_0060 = Gi_0060 + 1;
   Gi_0070 = Gi_005D + 10;
   } while (Gi_0060 < Gi_0070); 
   } 
   Li_FFF8 = Gi_005F;
   if (Gi_005F < Li_FFFC) return; 
   tmp_str00B6 = "";
   tmp_str00B7 = "";
   tmp_str00B8 = "";
   tmp_str00B9 = "";
   tmp_str00BA = "";
   tmp_str00BB = "";
   tmp_str00BC = "";
   tmp_str00BD = " expired";
   tmp_str00BE = (string)Fa_i_00;
   tmp_str00BF = ", Magic Number: ";
   tmp_str00C0 = (string)OrderTicket();
   tmp_str00C1 = "Order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str00C2 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00C2, " ", tmp_str00C1, tmp_str00C0, tmp_str00BF, tmp_str00BE, tmp_str00BD, tmp_str00BC, tmp_str00BB, tmp_str00BA, tmp_str00B9, tmp_str00B8, tmp_str00B7, tmp_str00B6);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0061 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0061 > 0) { 
   FileSeek(Gi_0061, 0, 2);
   tmp_str00C3 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0061, tmp_str00C3, " VERBOSE: ", tmp_str00C1, tmp_str00C0, tmp_str00BF, tmp_str00BE, tmp_str00BD, tmp_str00BC, tmp_str00BB, tmp_str00BA, tmp_str00B9, tmp_str00B8, tmp_str00B7, tmp_str00B6);
   FileClose(Gi_0061);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   
}

double getOrderStopLoss(int Fa_i_00, int Fa_i_01, double Fa_d_02)
{
   double Ld_FFF8;
   double Ld_FFF0;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFF0 = 0;
   if (Fa_i_00 == Ii_0000) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0004) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0008) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_000C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0010) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0014) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0018) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_001C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0020) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0024) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0028) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_002C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0030) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0034) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   }}} 
   Ld_FFF8 = NormalizeDouble(Ld_FFF0, _Digits);
   return Ld_FFF8;
}

double getOrderProfitTarget(int Fa_i_00, int Fa_i_01, double Fa_d_02)
{
   double Ld_FFF8;
   double Ld_FFF0;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFF0 = 0;
   if (Fa_i_00 == Ii_0000) { 
   Ld_FFF0 = (ProfitTarget * Id_0090);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0004) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0008) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_000C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0010) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0014) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0018) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_001C) { 
   Ld_FFF0 = (ProfitTarget * Id_0090);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0020) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0024) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0028) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_002C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0030) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0034) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Fa_d_02 + Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Fa_d_02 - Ld_FFF0);
   }}} 
   Ld_FFF8 = NormalizeDouble(Ld_FFF0, _Digits);
   return Ld_FFF8;
}

double getOrderTrailingStop(int Fa_i_00, int Fa_i_01, double Fa_d_02)
{
   double Ld_FFF8;
   double Ld_FFF0;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFF0 = 0;
   if (Fa_i_00 == Ii_0000) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0004) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0008) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_000C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0010) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0014) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0018) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_001C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0020) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0024) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0028) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_002C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0030) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0034) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   Ld_FFF8 = NormalizeDouble(Ld_FFF0, _Digits);
   return Ld_FFF8;
}

double getOrderBreakEven(int Fa_i_00, int Fa_i_01, double Fa_d_02)
{
   double Ld_FFF8;
   double Ld_FFF0;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFF0 = 0;
   if (Fa_i_00 == Ii_0000) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0004) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0008) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_000C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0010) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0014) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0018) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_001C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0020) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0024) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0028) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_002C) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0030) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   if (Fa_i_00 == Ii_0034) { 
   Ld_FFF0 = (Id_0090 * 0);
   if ((Ld_FFF0 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFF0 = (Bid - Ld_FFF0);
   } 
   else { 
   Ld_FFF0 = (Ask + Ld_FFF0);
   }}} 
   Ld_FFF8 = NormalizeDouble(Ld_FFF0, _Digits);
   return Ld_FFF8;
}

void sqCloseOrder(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   string tmp_str0030;
   string tmp_str0031;
   string tmp_str0032;
   string tmp_str0033;
   string tmp_str0034;
   string tmp_str0035;
   string tmp_str0036;
   string tmp_str0037;
   bool Lb_FFFF;
   int Li_FFF8;

   Lb_FFFF = false;
   Li_FFF8 = 0;
   Gi_0000 = 0;
   Gi_0001 = 0;
   Gi_0002 = 0;
   Gi_0003 = 0;
   Lb_FFFF = false;
   tmp_str0000 = "";
   tmp_str0001 = "";
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = "";
   tmp_str0008 = "";
   tmp_str0009 = " ----------------";
   tmp_str000A = (string)Fa_i_00;
   tmp_str000B = "Closing order with Magic Number: ";
   if (Ii_007C == 1) { 
   tmp_str000C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str000C, " ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0000 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0000 > 0) { 
   FileSeek(Gi_0000, 0, 2);
   tmp_str000D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0000, tmp_str000D, " VERBOSE: ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   FileClose(Gi_0000);
   }}} 
   Li_FFF8 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Li_FFF8, 0, 0) == true && OrderMagicNumber() == Fa_i_00) { 
   Lb_FFFF = true;
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   sqClosePositionAtMarket(-1);
   } 
   else { 
   tmp_str000E = "";
   tmp_str000F = "";
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = "";
   tmp_str0016 = "";
   tmp_str0017 = "";
   tmp_str0018 = (string)OrderTicket();
   tmp_str0019 = "Deleting pending order with ticket: ";
   if (Ii_007C == 1) { 
   tmp_str001A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str001A, " ", tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0001 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0001 > 0) { 
   FileSeek(Gi_0001, 0, 2);
   tmp_str001B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0001, tmp_str001B, " VERBOSE: ", tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   FileClose(Gi_0001);
   }}} 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   }} 
   Li_FFF8 = Li_FFF8 + 1;
   } while (Li_FFF8 < OrdersTotal()); 
   } 
   if (Lb_FFFF != true) { 
   tmp_str001C = "";
   tmp_str001D = "";
   tmp_str001E = "";
   tmp_str001F = "";
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = "";
   tmp_str0023 = "";
   tmp_str0024 = "";
   tmp_str0025 = "";
   tmp_str0026 = "";
   tmp_str0027 = "Order cannot be found";
   if (Ii_007C == 1) { 
   tmp_str0028 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0028, " ", tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0002 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0002 > 0) { 
   FileSeek(Gi_0002, 0, 2);
   tmp_str0029 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0002, tmp_str0029, " VERBOSE: ", tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C);
   FileClose(Gi_0002);
   }}}} 
   tmp_str002A = "";
   tmp_str002B = "";
   tmp_str002C = "";
   tmp_str002D = "";
   tmp_str002E = "";
   tmp_str002F = "";
   tmp_str0030 = "";
   tmp_str0031 = "";
   tmp_str0032 = "";
   tmp_str0033 = "";
   tmp_str0034 = "";
   tmp_str0035 = "Closing order finished ----------------";
   if (Ii_007C == 1) { 
   tmp_str0036 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0036, " ", tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A);
   return ;
   } 
   if (Ii_007C != 2) return; 
   Gi_0003 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0003 <= 0) return; 
   FileSeek(Gi_0003, 0, 2);
   tmp_str0037 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0003, tmp_str0037, " VERBOSE: ", tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A);
   FileClose(Gi_0003);
   
}

bool sqClosePositionAtMarket(double Fa_d_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   string tmp_str0030;
   string tmp_str0031;
   string tmp_str0032;
   string tmp_str0033;
   string tmp_str0034;
   string tmp_str0035;
   string tmp_str0036;
   string tmp_str0037;
   string tmp_str0038;
   bool Lb_FFFF;
   int Li_FFF8;
   int Li_FFF4;

   Lb_FFFF = false;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Gi_0000 = 0;
   Gi_0001 = 0;
   Gi_0002 = 0;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = 0;
   Gi_0007 = 0;
   tmp_str0000 = "";
   tmp_str0001 = "";
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = " at market price";
   tmp_str0008 = (string)OrderTicket();
   tmp_str0009 = ", ticket: ";
   tmp_str000A = (string)OrderMagicNumber();
   tmp_str000B = "Closing order with Magic Number: ";
   if (Ii_007C == 1) { 
   tmp_str000C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str000C, " ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0000 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0000 > 0) { 
   FileSeek(Gi_0000, 0, 2);
   tmp_str000D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0000, tmp_str000D, " VERBOSE: ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   FileClose(Gi_0000);
   }}} 
   Li_FFF8 = 0;
   Li_FFF4 = 3;
   do { 
   Li_FFF4 = Li_FFF4 - 1;
   if (Li_FFF4 < 0) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Gi_0002 = 30;
   Gi_0001 = 1;
   if (!IsTradeAllowed()) {
   Gi_0003 = (int)GetTickCount();
   Print("Trade context is busy! Wait until it is free...");
   do { 
   if (_StopFlag != 0) {
   Print("The expert was terminated by the user!");
   Gi_0001 = -1;
   break;
   }
   Gi_0008 = (int)GetTickCount() - Gi_0003;
   Gi_0004 = Gi_0008;
   Gi_0008 = Gi_0002 * 1000;
   if (Gi_0004 > Gi_0008) {
   tmp_str000E = (string)Gi_0002;
   tmp_str000E = "The waiting limit exceeded (" + tmp_str000E;
   tmp_str000E = tmp_str000E + " ???.)!";
   Print(tmp_str000E);
   Gi_0001 = -2;
   break;
   }
   if (IsTradeAllowed()) {
   Print("Trade context has become free!");
   RefreshRates();
   Gi_0001 = 1;
   break;
   }
   Sleep(100);
   } while (true); 
   }
   else Gi_0001 = 1;
   
   if (Gi_0001 == 1) { 
   tmp_str000F = "";
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = "";
   tmp_str0016 = "";
   tmp_str0017 = "";
   tmp_str0018 = "";
   Gi_0008 = 3 - Li_FFF4;
   tmp_str0019 = (string)Gi_0008;
   tmp_str001A = "Closing retry #";
   if (Ii_007C == 1) { 
   tmp_str001B = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str001B, " ", tmp_str001A, tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0005 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0005 > 0) { 
   FileSeek(Gi_0005, 0, 2);
   tmp_str001C = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0005, tmp_str001C, " VERBOSE: ", tmp_str001A, tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F);
   FileClose(Gi_0005);
   }}} 
   if (sqClosePositionWithHandling(Fa_d_00)) { 
   tmp_str001D = "";
   tmp_str001E = "";
   tmp_str001F = "";
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = "";
   tmp_str0023 = "";
   tmp_str0024 = " successfuly closed";
   tmp_str0025 = (string)OrderTicket();
   tmp_str0026 = ", ticket: ";
   tmp_str0027 = (string)OrderMagicNumber();
   tmp_str0028 = "Order with Magic Number: ";
   if (Ii_007C == 1) { 
   tmp_str0029 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0029, " ", tmp_str0028, tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0006 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0006 > 0) { 
   FileSeek(Gi_0006, 0, 2);
   tmp_str002A = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0006, tmp_str002A, " VERBOSE: ", tmp_str0028, tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D);
   FileClose(Gi_0006);
   }}} 
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   Gi_0008 = GetLastError();
   Li_FFF8 = Gi_0008;
   tmp_str002B = "";
   tmp_str002C = "";
   tmp_str002D = "";
   tmp_str002E = "";
   tmp_str002F = "";
   tmp_str0030 = "";
   tmp_str0031 = "";
   tmp_str0032 = "";
   tmp_str0033 = ErrorDescription(Gi_0008);
   tmp_str0034 = " - ";
   tmp_str0035 = (string)Gi_0008;
   tmp_str0036 = "Closing order failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str0037 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0037, " ", tmp_str0036, tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0007 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0007 > 0) { 
   FileSeek(Gi_0007, 0, 2);
   tmp_str0038 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0007, tmp_str0038, " VERBOSE: ", tmp_str0036, tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B);
   FileClose(Gi_0007);
   }}}} 
   Sleep(500);
   } while (true); 
}

bool sqClosePositionWithHandling(double Fa_d_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   bool Lb_FFFF;
   double Ld_FFF0;

   Lb_FFFF = false;
   Ld_FFF0 = 0;
   Gd_0000 = 0;
   Gd_0001 = 0;
   Gi_0002 = 0;
   Gi_0003 = 0;
   RefreshRates();
   Ld_FFF0 = 0;
   if (OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   if (OrderType() == OP_BUY) { 
   tmp_str0000 = OrderSymbol();
   if (tmp_str0000 == "NULL") { 
   Gd_0000 = Bid;
   } 
   else { 
   Gd_0000 = MarketInfo(tmp_str0000, MODE_BID);
   } 
   Ld_FFF0 = Gd_0000;
   } 
   else { 
   tmp_str0001 = OrderSymbol();
   if (tmp_str0001 == "NULL") { 
   Gd_0001 = Ask;
   } 
   else { 
   Gd_0001 = MarketInfo(tmp_str0001, MODE_ASK);
   } 
   Ld_FFF0 = Gd_0001;
   } 
   if ((Fa_d_00 <= 0)) { 
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = "";
   tmp_str0008 = "";
   tmp_str0009 = "";
   tmp_str000A = (string)OrderLots();
   tmp_str000B = ", closing size: ";
   tmp_str000C = (string)Ld_FFF0;
   tmp_str000D = "Closing Market price: ";
   if (Ii_007C == 1) { 
   tmp_str000E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str000E, " ", tmp_str000D, tmp_str000C, tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0002 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0002 > 0) { 
   FileSeek(Gi_0002, 0, 2);
   tmp_str000F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0002, tmp_str000F, " VERBOSE: ", tmp_str000D, tmp_str000C, tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002);
   FileClose(Gi_0002);
   }}} 
   Lb_FFFF = OrderClose(OrderTicket(), OrderLots(), Ld_FFF0, Ii_0078, 4294967295);
   return Lb_FFFF;
   } 
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = "";
   tmp_str0016 = "";
   tmp_str0017 = "";
   tmp_str0018 = (string)Fa_d_00;
   tmp_str0019 = ", closing size: ";
   tmp_str001A = (string)Ld_FFF0;
   tmp_str001B = "Closing Market price: ";
   if (Ii_007C == 1) { 
   tmp_str001C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str001C, " ", tmp_str001B, tmp_str001A, tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0003 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0003 > 0) { 
   FileSeek(Gi_0003, 0, 2);
   tmp_str001D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0003, tmp_str001D, " VERBOSE: ", tmp_str001B, tmp_str001A, tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010);
   FileClose(Gi_0003);
   }}} 
   Lb_FFFF = OrderClose(OrderTicket(), Fa_d_00, Ld_FFF0, Ii_0078, 4294967295);
   
   return Lb_FFFF;
}

bool sqOpenOrder(string Fa_s_00, int Fa_i_01, double Fa_d_02, double Fa_d_03, string Fa_s_04, int Fa_i_05, string Fa_s_06)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   string tmp_str0030;
   string tmp_str0031;
   string tmp_str0032;
   string tmp_str0033;
   string tmp_str0034;
   string tmp_str0035;
   string tmp_str0036;
   string tmp_str0037;
   string tmp_str0038;
   string tmp_str0039;
   string tmp_str003A;
   string tmp_str003B;
   string tmp_str003C;
   string tmp_str003D;
   string tmp_str003E;
   string tmp_str003F;
   string tmp_str0040;
   string tmp_str0041;
   string tmp_str0042;
   string tmp_str0043;
   string tmp_str0044;
   string tmp_str0045;
   string tmp_str0046;
   string tmp_str0047;
   string tmp_str0048;
   string tmp_str0049;
   string tmp_str004A;
   string tmp_str004B;
   string tmp_str004C;
   string tmp_str004D;
   string tmp_str004E;
   string tmp_str004F;
   string tmp_str0050;
   string tmp_str0051;
   string tmp_str0052;
   string tmp_str0053;
   string tmp_str0054;
   string tmp_str0055;
   string tmp_str0056;
   string tmp_str0057;
   string tmp_str0058;
   string tmp_str0059;
   string tmp_str005A;
   string tmp_str005B;
   string tmp_str005C;
   string tmp_str005D;
   string tmp_str005E;
   string tmp_str005F;
   string tmp_str0060;
   string tmp_str0061;
   string tmp_str0062;
   string tmp_str0063;
   string tmp_str0064;
   string tmp_str0065;
   string tmp_str0066;
   string tmp_str0067;
   string tmp_str0068;
   string tmp_str0069;
   string tmp_str006A;
   string tmp_str006B;
   string tmp_str006C;
   string tmp_str006D;
   string tmp_str006E;
   string tmp_str006F;
   string tmp_str0070;
   string tmp_str0071;
   string tmp_str0072;
   string tmp_str0073;
   string tmp_str0074;
   string tmp_str0075;
   string tmp_str0076;
   string tmp_str0077;
   string tmp_str0078;
   string tmp_str0079;
   string tmp_str007A;
   string tmp_str007B;
   string tmp_str007C;
   string tmp_str007D;
   string tmp_str007E;
   string tmp_str007F;
   string tmp_str0080;
   string tmp_str0081;
   string tmp_str0082;
   string tmp_str0083;
   string tmp_str0084;
   string tmp_str0085;
   string tmp_str0086;
   string tmp_str0087;
   string tmp_str0088;
   string tmp_str0089;
   string tmp_str008A;
   string tmp_str008B;
   string tmp_str008C;
   string tmp_str008D;
   string tmp_str008E;
   string tmp_str008F;
   string tmp_str0090;
   string tmp_str0091;
   string tmp_str0092;
   string tmp_str0093;
   string tmp_str0094;
   string tmp_str0095;
   string tmp_str0096;
   string tmp_str0097;
   string tmp_str0098;
   string tmp_str0099;
   string tmp_str009A;
   string tmp_str009B;
   string tmp_str009C;
   string tmp_str009D;
   string tmp_str009E;
   string tmp_str009F;
   string tmp_str00A0;
   string tmp_str00A1;
   string tmp_str00A2;
   string tmp_str00A3;
   string tmp_str00A4;
   string tmp_str00A5;
   string tmp_str00A6;
   string tmp_str00A7;
   string tmp_str00A8;
   string tmp_str00A9;
   string tmp_str00AA;
   string tmp_str00AB;
   string tmp_str00AC;
   string tmp_str00AD;
   string tmp_str00AE;
   string tmp_str00AF;
   string tmp_str00B0;
   string tmp_str00B1;
   string tmp_str00B2;
   string tmp_str00B3;
   string tmp_str00B4;
   string tmp_str00B5;
   string tmp_str00B6;
   string tmp_str00B7;
   string tmp_str00B8;
   string tmp_str00B9;
   string tmp_str00BA;
   string tmp_str00BB;
   bool Lb_FFFF;
   int Li_FFF8;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   int Li_FFDC;

   Lb_FFFF = false;
   Li_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Li_FFDC = 0;
   Gi_0000 = 0;
   Gi_0001 = 0;
   Gb_0002 = false;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = 0;
   Gb_0007 = false;
   Gi_0008 = 0;
   Gi_0009 = 0;
   Gi_000A = 0;
   Gb_000B = false;
   Gi_000C = 0;
   Gi_000D = 0;
   Gi_000E = 0;
   Gi_000F = 0;
   Gd_0010 = 0;
   Gd_0011 = 0;
   Gi_0012 = 0;
   Gd_0013 = 0;
   Gi_0014 = 0;
   Gd_0015 = 0;
   Gi_0016 = 0;
   Gi_0017 = 0;
   Gi_0018 = 0;
   Gi_0019 = 0;
   Gi_001A = 0;
   Gi_001B = 0;
   Gi_001C = 0;
   Gi_001D = 0;
   Gi_001E = 0;
   Gi_001F = 0;
   Gi_0020 = 0;
   Gi_0021 = 0;
   Li_FFF8 = 0;
   tmp_str0000 = "";
   tmp_str0001 = " ----------------";
   tmp_str0002 = Fa_s_04;
   tmp_str0003 = ", comment: ";
   tmp_str0004 = (string)Fa_d_02;
   tmp_str0005 = ", lots: ";
   tmp_str0006 = (string)Fa_d_03;
   tmp_str0007 = ", price: ";
   tmp_str0008 = sqGetOrderTypeAsString(Fa_i_01);
   tmp_str0009 = ", type: ";
   tmp_str000A = (string)Fa_i_05;
   tmp_str000B = "Opening order with MagicNumber: ";
   if (Ii_007C == 1) { 
   tmp_str000C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str000C, " ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0000 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0000 > 0) { 
   FileSeek(Gi_0000, 0, 2);
   tmp_str000D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0000, tmp_str000D, " VERBOSE: ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   FileClose(Gi_0000);
   }}} 
   tmp_str000E = "";
   tmp_str000F = "";
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = "";
   tmp_str0016 = (string)Bid;
   tmp_str0017 = ", Bid: ";
   tmp_str0018 = (string)Ask;
   tmp_str0019 = "Current Ask: ";
   if (Ii_007C == 1) { 
   tmp_str001A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str001A, " ", tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0001 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0001 > 0) { 
   FileSeek(Gi_0001, 0, 2);
   tmp_str001B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0001, tmp_str001B, " VERBOSE: ", tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   FileClose(Gi_0001);
   }}} 
   Gl_0022 = TimeCurrent();
   Gl_0023 = Ii_00EC;
   Gl_0023 = Gl_0022 - Gl_0023;
   if (Gl_0023 < 600) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Gi_0003 = Fa_i_05;
   Gi_0023 = OrdersTotal() - 1;
   Gi_0004 = Gi_0023;
   Gb_0002 = false;
   if (Gi_0023 >= 0) {
   do { 
   if (OrderSelect(Gi_0004, 0, 0) && OrderMagicNumber() == Gi_0003 && OrderSymbol() == _Symbol) {
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   Gb_0002 = true;
   break;
   }}
   Gi_0004 = Gi_0004 - 1;
   } while (Gi_0004 >= 0); 
   }
   else Gb_0002 = false;
   
   if (Gb_0002) { 
   tmp_str001C = "";
   tmp_str001D = "";
   tmp_str001E = "";
   tmp_str001F = "";
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = "";
   tmp_str0023 = "";
   tmp_str0024 = "";
   tmp_str0025 = " already exists, cannot open another one!";
   tmp_str0026 = (string)Fa_i_05;
   tmp_str0027 = "Order with magic number: ";
   if (Ii_007C == 1) { 
   tmp_str0028 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0028, " ", tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0005 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0005 > 0) { 
   FileSeek(Gi_0005, 0, 2);
   tmp_str0029 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0005, tmp_str0029, " VERBOSE: ", tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C);
   FileClose(Gi_0005);
   }}} 
   tmp_str002A = "";
   tmp_str002B = "";
   tmp_str002C = "";
   tmp_str002D = "";
   tmp_str002E = "";
   tmp_str002F = "";
   tmp_str0030 = "";
   tmp_str0031 = "";
   tmp_str0032 = "";
   tmp_str0033 = "";
   tmp_str0034 = "";
   tmp_str0035 = "----------------------------------";
   if (Ii_007C == 1) { 
   tmp_str0036 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0036, " ", tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0006 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0006 > 0) { 
   FileSeek(Gi_0006, 0, 2);
   tmp_str0037 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0006, tmp_str0037, " VERBOSE: ", tmp_str0035, tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A);
   FileClose(Gi_0006);
   }}} 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Gi_0008 = Fa_i_05;
   Gi_0023 = OrdersTotal() - 1;
   Gi_0009 = Gi_0023;
   Gb_0007 = false;
   if (Gi_0023 >= 0) {
   do { 
   if (OrderSelect(Gi_0009, 0, 0) && OrderMagicNumber() == Gi_0008 
   && OrderSymbol() == _Symbol && OrderType() != OP_BUY && OrderType() != OP_SELL) {
   Gb_0007 = true;
   break;
   }
   Gi_0009 = Gi_0009 - 1;
   } while (Gi_0009 >= 0); 
   }
   else Gb_0007 = false;
   
   if (Gb_0007) { 
   Gi_000A = Fa_i_05;
   Gb_000B = false;
   if (Fa_i_05 == Ii_0000) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0004) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0008) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_000C) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0010) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0014) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0018) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_001C) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0020) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0024) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0028) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_002C) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0030) { 
   Gb_000B = false;
   } 
   if (Gi_000A == Ii_0034) { 
   Gb_000B = false;
   } 
   if (Gb_000B != true) { 
   tmp_str0038 = "";
   tmp_str0039 = "";
   tmp_str003A = "";
   tmp_str003B = "";
   tmp_str003C = "";
   tmp_str003D = "";
   tmp_str003E = "";
   tmp_str003F = "";
   tmp_str0040 = " ----------------";
   tmp_str0041 = " already exists, and replace is not allowed!";
   tmp_str0042 = (string)Fa_i_05;
   tmp_str0043 = "Pending Order with magic number: ";
   if (Ii_007C == 1) { 
   tmp_str0044 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0044, " ", tmp_str0043, tmp_str0042, tmp_str0041, tmp_str0040, tmp_str003F, tmp_str003E, tmp_str003D, tmp_str003C, tmp_str003B, tmp_str003A, tmp_str0039, tmp_str0038);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_000C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_000C > 0) { 
   FileSeek(Gi_000C, 0, 2);
   tmp_str0045 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_000C, tmp_str0045, " VERBOSE: ", tmp_str0043, tmp_str0042, tmp_str0041, tmp_str0040, tmp_str003F, tmp_str003E, tmp_str003D, tmp_str003C, tmp_str003B, tmp_str003A, tmp_str0039, tmp_str0038);
   FileClose(Gi_000C);
   }}} 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   tmp_str0046 = "";
   tmp_str0047 = "";
   tmp_str0048 = "";
   tmp_str0049 = "";
   tmp_str004A = "";
   tmp_str004B = "";
   tmp_str004C = "";
   tmp_str004D = "";
   tmp_str004E = "";
   tmp_str004F = "";
   tmp_str0050 = "";
   tmp_str0051 = "Deleting previous pending order";
   if (Ii_007C == 1) { 
   tmp_str0052 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0052, " ", tmp_str0051, tmp_str0050, tmp_str004F, tmp_str004E, tmp_str004D, tmp_str004C, tmp_str004B, tmp_str004A, tmp_str0049, tmp_str0048, tmp_str0047, tmp_str0046);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_000D = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_000D > 0) { 
   FileSeek(Gi_000D, 0, 2);
   tmp_str0053 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_000D, tmp_str0053, " VERBOSE: ", tmp_str0051, tmp_str0050, tmp_str004F, tmp_str004E, tmp_str004D, tmp_str004C, tmp_str004B, tmp_str004A, tmp_str0049, tmp_str0048, tmp_str0047, tmp_str0046);
   FileClose(Gi_000D);
   }}} 
   Gi_000E = Fa_i_05;
   Gi_000F = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000F, 0, 0) == true && OrderMagicNumber() == Gi_000E && OrderSymbol() == _Symbol) { 
   order_check = OrderDelete(OrderTicket(), 4294967295);
   break; 
   } 
   Gi_000F = Gi_000F + 1;
   } while (Gi_000F < OrdersTotal()); 
   }} 
   RefreshRates();
   if (Fa_i_01 == 4 || Fa_i_01 == 5) { 
   
   Ld_FFF0 = 0;
   if (Fa_i_01 == 4) { 
   tmp_str0054 = Fa_s_00;
   if (tmp_str0054 == "NULL") { 
   Gd_0010 = Ask;
   } 
   else { 
   Gd_0010 = MarketInfo(tmp_str0054, MODE_ASK);
   } 
   Ld_FFF0 = Gd_0010;
   } 
   else { 
   tmp_str0055 = Fa_s_00;
   if (tmp_str0055 == "NULL") { 
   Gd_0011 = Bid;
   } 
   else { 
   Gd_0011 = MarketInfo(tmp_str0055, MODE_BID);
   } 
   Ld_FFF0 = Gd_0011;
   } 
   Gd_0023 = NormalizeDouble(fabs((Fa_d_03 - Ld_FFF0)), _Digits);
   Gi_0012 = Fa_i_05;
   Gd_0013 = 0;
   if (Fa_i_05 == Ii_0000) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0004) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0008) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_000C) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0010) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0014) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0018) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_001C) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0020) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0024) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0028) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_002C) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0030) { 
   Gd_0013 = 0;
   } 
   if (Gi_0012 == Ii_0034) { 
   Gd_0013 = 0;
   } 
   if ((Gd_0023 <= NormalizeDouble((NormalizeDouble(Gd_0013, _Digits) / Id_0088), _Digits))) { 
   tmp_str0056 = "";
   tmp_str0057 = "";
   tmp_str0058 = "";
   tmp_str0059 = "";
   tmp_str005A = "";
   tmp_str005B = "";
   tmp_str005C = "";
   tmp_str005D = "";
   tmp_str005E = "";
   tmp_str005F = "";
   tmp_str0060 = " ----------------";
   tmp_str0061 = "Stop/limit order is too close to actual price";
   if (Ii_007C == 1) { 
   tmp_str0062 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0062, " ", tmp_str0061, tmp_str0060, tmp_str005F, tmp_str005E, tmp_str005D, tmp_str005C, tmp_str005B, tmp_str005A, tmp_str0059, tmp_str0058, tmp_str0057, tmp_str0056);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0014 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0014 > 0) { 
   FileSeek(Gi_0014, 0, 2);
   tmp_str0063 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0014, tmp_str0063, " VERBOSE: ", tmp_str0061, tmp_str0060, tmp_str005F, tmp_str005E, tmp_str005D, tmp_str005C, tmp_str005B, tmp_str005A, tmp_str0059, tmp_str0058, tmp_str0057, tmp_str0056);
   FileClose(Gi_0014);
   }}} 
   Lb_FFFF = false;
   return Lb_FFFF;
   }} 
   Ld_FFE8 = getOrderStopLoss(Fa_i_05, Fa_i_01, Fa_d_03);
   Ld_FFE0 = getOrderProfitTarget(Fa_i_05, Fa_i_01, Fa_d_03);
   Li_FFDC = 3;
   do { 
   Li_FFDC = Li_FFDC - 1;
   if (Li_FFDC < 0) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Gi_0016 = Fa_i_05;
   Gi_0025 = OrdersTotal() - 1;
   Gi_0017 = Gi_0025;
   Gd_0015 = 0;
   if (Gi_0025 >= 0) {
   do { 
   if (OrderSelect(Gi_0017, 0, 0)) {
   if ((Gi_0016 == 0 && OrderSymbol() == _Symbol) || OrderMagicNumber() == Gi_0016) {
   
   if (OrderType() == OP_BUY) {
   Gd_0015 = 1;
   break;
   }
   if (OrderType() == OP_SELL) {
   Gd_0015 = -1;
   break;
   }}}
   Gi_0017 = Gi_0017 - 1;
   } while (Gi_0017 >= 0); 
   }
   else Gd_0015 = 0;
   
   if ((Gd_0015 != 0)) { 
   tmp_str0064 = "";
   tmp_str0065 = "";
   tmp_str0066 = "";
   tmp_str0067 = "";
   tmp_str0068 = "";
   tmp_str0069 = "";
   tmp_str006A = "";
   tmp_str006B = "";
   tmp_str006C = "";
   tmp_str006D = "";
   tmp_str006E = " ----------------";
   tmp_str006F = "Order already opened";
   if (Ii_007C == 1) { 
   tmp_str0070 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0070, " ", tmp_str006F, tmp_str006E, tmp_str006D, tmp_str006C, tmp_str006B, tmp_str006A, tmp_str0069, tmp_str0068, tmp_str0067, tmp_str0066, tmp_str0065, tmp_str0064);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0018 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0018 > 0) { 
   FileSeek(Gi_0018, 0, 2);
   tmp_str0071 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0018, tmp_str0071, " VERBOSE: ", tmp_str006F, tmp_str006E, tmp_str006D, tmp_str006C, tmp_str006B, tmp_str006A, tmp_str0069, tmp_str0068, tmp_str0067, tmp_str0066, tmp_str0065, tmp_str0064);
   FileClose(Gi_0018);
   }}} 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Gi_001A = 30;
   Gi_0019 = 1;
   if (!IsTradeAllowed()) {
   Gi_001B = (int)GetTickCount();
   Print("Trade context is busy! Wait until it is free...");
   do { 
   if (_StopFlag != 0) {
   Print("The expert was terminated by the user!");
   Gi_0019 = -1;
   break;
   }
   Gi_0025 = (int)GetTickCount() - Gi_001B;
   Gi_001C = Gi_0025;
   Gi_0025 = Gi_001A * 1000;
   if (Gi_001C > Gi_0025) {
   tmp_str0072 = (string)Gi_001A;
   tmp_str0072 = "The waiting limit exceeded (" + tmp_str0072;
   tmp_str0072 = tmp_str0072 + " ???.)!";
   Print(tmp_str0072);
   Gi_0019 = -2;
   break;
   }
   if (IsTradeAllowed()) {
   Print("Trade context has become free!");
   RefreshRates();
   Gi_0019 = 1;
   break;
   }
   Sleep(100);
   } while (true); 
   }
   else Gi_0019 = 1;
   
   if (Gi_0019 == 1) { 
   tmp_str0073 = "";
   tmp_str0074 = "";
   tmp_str0075 = "";
   tmp_str0076 = "";
   tmp_str0077 = "";
   tmp_str0078 = "";
   tmp_str0079 = "";
   tmp_str007A = "";
   tmp_str007B = "";
   tmp_str007C = "";
   Gi_0025 = 3 - Li_FFDC;
   tmp_str007D = (string)Gi_0025;
   tmp_str007E = "Opening, try #";
   if (Ii_007C == 1) { 
   tmp_str007F = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str007F, " ", tmp_str007E, tmp_str007D, tmp_str007C, tmp_str007B, tmp_str007A, tmp_str0079, tmp_str0078, tmp_str0077, tmp_str0076, tmp_str0075, tmp_str0074, tmp_str0073);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_001D = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_001D > 0) { 
   FileSeek(Gi_001D, 0, 2);
   tmp_str0080 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_001D, tmp_str0080, " VERBOSE: ", tmp_str007E, tmp_str007D, tmp_str007C, tmp_str007B, tmp_str007A, tmp_str0079, tmp_str0078, tmp_str0077, tmp_str0076, tmp_str0075, tmp_str0074, tmp_str0073);
   FileClose(Gi_001D);
   }}} 
   tmp_str0081 = Fa_s_04;
   tmp_str0082 = Fa_s_00;
   Li_FFF8 = sqOpenOrderWithErrorHandling(tmp_str0082, Fa_i_01, Fa_d_02, Fa_d_03, Ld_FFE8, Ld_FFE0, tmp_str0081, Fa_i_05);
   if (Li_FFF8 > 0) { 
   tmp_str0083 = "";
   tmp_str0084 = "";
   tmp_str0085 = "";
   tmp_str0086 = "";
   tmp_str0087 = "";
   tmp_str0088 = "";
   tmp_str0089 = "";
   tmp_str008A = "";
   tmp_str008B = "";
   tmp_str008C = "";
   tmp_str008D = " ----------------";
   tmp_str008E = "Trade successfuly opened";
   if (Ii_007C == 1) { 
   tmp_str008F = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str008F, " ", tmp_str008E, tmp_str008D, tmp_str008C, tmp_str008B, tmp_str008A, tmp_str0089, tmp_str0088, tmp_str0087, tmp_str0086, tmp_str0085, tmp_str0084, tmp_str0083);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_001E = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_001E > 0) { 
   FileSeek(Gi_001E, 0, 2);
   tmp_str0090 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_001E, tmp_str0090, " VERBOSE: ", tmp_str008E, tmp_str008D, tmp_str008C, tmp_str008B, tmp_str008A, tmp_str0089, tmp_str0088, tmp_str0087, tmp_str0086, tmp_str0085, tmp_str0084, tmp_str0083);
   FileClose(Gi_001E);
   }}} 
   tmp_str0091 = "Last Signal: " + Fa_s_06;
   ObjectSetText("lines", tmp_str0091, 8, "Tahoma", Ii_00E8);
   Lb_FFFF = true;
   return Lb_FFFF;
   }} 
   if (Li_FFF8 == -130) { 
   tmp_str0092 = "";
   tmp_str0093 = "";
   tmp_str0094 = "";
   tmp_str0095 = "";
   tmp_str0096 = "";
   tmp_str0097 = "";
   tmp_str0098 = "";
   tmp_str0099 = "";
   tmp_str009A = "";
   tmp_str009B = "";
   tmp_str009C = " ----------------";
   tmp_str009D = "Invalid stops, cannot open the trade";
   if (Ii_007C == 1) { 
   tmp_str009E = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str009E, " ", tmp_str009D, tmp_str009C, tmp_str009B, tmp_str009A, tmp_str0099, tmp_str0098, tmp_str0097, tmp_str0096, tmp_str0095, tmp_str0094, tmp_str0093, tmp_str0092);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_001F = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_001F > 0) { 
   FileSeek(Gi_001F, 0, 2);
   tmp_str009F = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_001F, tmp_str009F, " VERBOSE: ", tmp_str009D, tmp_str009C, tmp_str009B, tmp_str009A, tmp_str0099, tmp_str0098, tmp_str0097, tmp_str0096, tmp_str0095, tmp_str0094, tmp_str0093, tmp_str0092);
   FileClose(Gi_001F);
   }}} 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   if (Li_FFF8 == -131) { 
   tmp_str00A0 = "";
   tmp_str00A1 = "";
   tmp_str00A2 = "";
   tmp_str00A3 = "";
   tmp_str00A4 = "";
   tmp_str00A5 = "";
   tmp_str00A6 = "";
   tmp_str00A7 = "";
   tmp_str00A8 = "";
   tmp_str00A9 = "";
   tmp_str00AA = " ----------------";
   tmp_str00AB = "Invalid volume, cannot open the trade";
   if (Ii_007C == 1) { 
   tmp_str00AC = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00AC, " ", tmp_str00AB, tmp_str00AA, tmp_str00A9, tmp_str00A8, tmp_str00A7, tmp_str00A6, tmp_str00A5, tmp_str00A4, tmp_str00A3, tmp_str00A2, tmp_str00A1, tmp_str00A0);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0020 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0020 > 0) { 
   FileSeek(Gi_0020, 0, 2);
   tmp_str00AD = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0020, tmp_str00AD, " VERBOSE: ", tmp_str00AB, tmp_str00AA, tmp_str00A9, tmp_str00A8, tmp_str00A7, tmp_str00A6, tmp_str00A5, tmp_str00A4, tmp_str00A3, tmp_str00A2, tmp_str00A1, tmp_str00A0);
   FileClose(Gi_0020);
   }}} 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   if (Li_FFF8 == -11111) { 
   tmp_str00AE = "";
   tmp_str00AF = "";
   tmp_str00B0 = "";
   tmp_str00B1 = "";
   tmp_str00B2 = "";
   tmp_str00B3 = "";
   tmp_str00B4 = "";
   tmp_str00B5 = "";
   tmp_str00B6 = "";
   tmp_str00B7 = "";
   tmp_str00B8 = " ----------------";
   tmp_str00B9 = "Trade opened, but cannot set SL/PT, closing trade";
   if (Ii_007C == 1) { 
   tmp_str00BA = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str00BA, " ", tmp_str00B9, tmp_str00B8, tmp_str00B7, tmp_str00B6, tmp_str00B5, tmp_str00B4, tmp_str00B3, tmp_str00B2, tmp_str00B1, tmp_str00B0, tmp_str00AF, tmp_str00AE);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0021 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0021 > 0) { 
   FileSeek(Gi_0021, 0, 2);
   tmp_str00BB = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0021, tmp_str00BB, " VERBOSE: ", tmp_str00B9, tmp_str00B8, tmp_str00B7, tmp_str00B6, tmp_str00B5, tmp_str00B4, tmp_str00B3, tmp_str00B2, tmp_str00B1, tmp_str00B0, tmp_str00AF, tmp_str00AE);
   FileClose(Gi_0021);
   }}} 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Sleep(1000);
   } while (true); 
}

int sqOpenOrderWithErrorHandling(string Fa_s_00, int Fa_i_01, double Fa_d_02, double Fa_d_03, double Fa_d_04, double Fa_d_05, string Fa_s_06, int Fa_i_07)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   string tmp_str0030;
   string tmp_str0031;
   string tmp_str0032;
   string tmp_str0033;
   string tmp_str0034;
   string tmp_str0035;
   string tmp_str0036;
   string tmp_str0037;
   string tmp_str0038;
   string tmp_str0039;
   string tmp_str003A;
   string tmp_str003B;
   string tmp_str003C;
   string tmp_str003D;
   string tmp_str003E;
   string tmp_str003F;
   string tmp_str0040;
   string tmp_str0041;
   string tmp_str0042;
   string tmp_str0043;
   string tmp_str0044;
   int Li_FFFC;
   int Li_FFF8;
   int Li_FFF4;
   double Ld_FFE8;
   double Ld_FFE0;
   int Li_FFDC;

   Li_FFFC = 0;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Li_FFDC = 0;
   Gi_0000 = 0;
   Gi_0001 = 0;
   Gi_0002 = 0;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = 0;
   Li_FFF8 = 0;
   Li_FFF4 = 0;
   tmp_str0000 = "";
   tmp_str0001 = "";
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = "";
   tmp_str0008 = "";
   tmp_str0009 = "";
   tmp_str000A = "";
   tmp_str000B = "Sending order...";
   if (Ii_007C == 1) { 
   tmp_str000C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str000C, " ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0000 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0000 > 0) { 
   FileSeek(Gi_0000, 0, 2);
   tmp_str000D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0000, tmp_str000D, " VERBOSE: ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   FileClose(Gi_0000);
   }}} 
   Ld_FFE8 = Fa_d_04;
   Ld_FFE0 = Fa_d_05;
   if (Ib_0080) { 
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   } 
   if (Fa_s_00 == "NULL") { 
   Li_FFF8 = OrderSend(_Symbol, Fa_i_01, Fa_d_02, Fa_d_03, Ii_0078, Ld_FFE8, Ld_FFE0, Fa_s_06, Fa_i_07, 0, 4294967295);
   } 
   else { 
   Li_FFF8 = OrderSend(Fa_s_00, Fa_i_01, Fa_d_02, Fa_d_03, Ii_0078, Ld_FFE8, Ld_FFE0, Fa_s_06, Fa_i_07, 0, 4294967295);
   } 
   if (Li_FFF8 < 0) { 
   Gi_0007 = GetLastError();
   Li_FFF4 = Gi_0007;
   tmp_str000E = "";
   tmp_str000F = "";
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = "";
   tmp_str0016 = "";
   tmp_str0017 = "";
   tmp_str0018 = (string)Gi_0007;
   tmp_str0019 = "Order failed, error: ";
   if (Ii_007C == 1) { 
   tmp_str001A = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str001A, " ", tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0001 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0001 > 0) { 
   FileSeek(Gi_0001, 0, 2);
   tmp_str001B = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0001, tmp_str001B, " VERBOSE: ", tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   FileClose(Gi_0001);
   }}} 
   Li_FFFC = -Li_FFF4;
   return Li_FFFC;
   } 
   order_check = OrderSelect(Li_FFF8, 1, 0);
   tmp_str001C = "";
   tmp_str001D = "";
   tmp_str001E = "";
   tmp_str001F = "";
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = "";
   tmp_str0023 = "";
   tmp_str0024 = (string)OrderOpenPrice();
   tmp_str0025 = " at price:";
   tmp_str0026 = (string)OrderTicket();
   tmp_str0027 = "Order opened with ticket: ";
   tmp_str0028 = TimeToString(TimeCurrent(), 3);
   Print(tmp_str0028, " ", tmp_str0027, tmp_str0026, tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C);
   tmp_str0029 = "";
   tmp_str002A = "";
   tmp_str002B = "";
   tmp_str002C = "";
   tmp_str002D = "";
   tmp_str002E = "";
   tmp_str002F = (string)OrderOpenPrice();
   tmp_str0030 = " at price:";
   tmp_str0031 = (string)OrderTicket();
   tmp_str0032 = " opened with ticket: ";
   tmp_str0033 = (string)Fa_i_07;
   tmp_str0034 = "Order with Magic Number: ";
   VerboseLog(tmp_str0034, tmp_str0033, tmp_str0032, tmp_str0031, tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A, tmp_str0029);
   if (Ib_0080 == false) return Li_FFF8; 
   Li_FFDC = 3;
   do { 
   Li_FFDC = Li_FFDC - 1;
   if (Li_FFDC < 0) { 
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   if ((Fa_d_04 == 0 && Fa_d_05 == 0)
   || (OrderStopLoss() == Fa_d_04 && OrderTakeProfit() == Fa_d_05)) {
   
   Li_FFFC = Li_FFF8;
   return Li_FFFC;
   }
   Gi_0003 = 30;
   Gi_0002 = 1;
   if (!IsTradeAllowed()) {
   Gi_0004 = (int)GetTickCount();
   Print("Trade context is busy! Wait until it is free...");
   do { 
   if (_StopFlag != 0) {
   Print("The expert was terminated by the user!");
   Gi_0002 = -1;
   break;
   }
   Gi_0007 = (int)GetTickCount() - Gi_0004;
   Gi_0005 = Gi_0007;
   Gi_0007 = Gi_0003 * 1000;
   if (Gi_0005 > Gi_0007) {
   tmp_str0035 = (string)Gi_0003;
   tmp_str0035 = "The waiting limit exceeded (" + tmp_str0035;
   tmp_str0035 = tmp_str0035 + " ???.)!";
   Print(tmp_str0035);
   Gi_0002 = -2;
   break;
   }
   if (IsTradeAllowed()) {
   Print("Trade context has become free!");
   RefreshRates();
   Gi_0002 = 1;
   break;
   }
   Sleep(100);
   } while (true); 
   }
   else Gi_0002 = 1;
   
   if (Gi_0002 == 1) { 
   tmp_str0036 = "";
   tmp_str0037 = "";
   tmp_str0038 = "";
   tmp_str0039 = "";
   tmp_str003A = "";
   tmp_str003B = "";
   tmp_str003C = "";
   tmp_str003D = "";
   tmp_str003E = "";
   tmp_str003F = "";
   Gi_0007 = 3 - Li_FFDC;
   tmp_str0040 = (string)Gi_0007;
   tmp_str0041 = "Setting SL/PT, try #";
   if (Ii_007C == 1) { 
   tmp_str0042 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0042, " ", tmp_str0041, tmp_str0040, tmp_str003F, tmp_str003E, tmp_str003D, tmp_str003C, tmp_str003B, tmp_str003A, tmp_str0039, tmp_str0038, tmp_str0037, tmp_str0036);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0006 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0006 > 0) { 
   FileSeek(Gi_0006, 0, 2);
   tmp_str0043 = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0006, tmp_str0043, " VERBOSE: ", tmp_str0041, tmp_str0040, tmp_str003F, tmp_str003E, tmp_str003D, tmp_str003C, tmp_str003B, tmp_str003A, tmp_str0039, tmp_str0038, tmp_str0037, tmp_str0036);
   FileClose(Gi_0006);
   }}} 
   tmp_str0044 = Fa_s_00;
   if (sqSetSLPTForOrder(Li_FFF8, Fa_d_04, Fa_d_05, Fa_i_07, Fa_i_01, (int)Fa_d_03, tmp_str0044, Li_FFDC)) { 
   Li_FFFC = Li_FFF8;
   return Li_FFFC;
   } 
   if (Li_FFDC == 0) { 
   Li_FFFC = -11111;
   return Li_FFFC;
   }} 
   Sleep(1000);
   } while (true); 
}

bool sqSetSLPTForOrder(int Fa_i_00, double Fa_d_01, double Fa_d_02, int Fa_i_03, int Fa_i_04, int Fa_i_05, string Fa_s_06, int Fa_i_07)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   bool Lb_FFFF;
   int Li_FFF8;

   Lb_FFFF = false;
   Li_FFF8 = 0;
   Gi_0000 = 0;
   tmp_str0000 = "";
   tmp_str0001 = "";
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = " for order";
   tmp_str0008 = (string)Fa_d_02;
   tmp_str0009 = " and PT: ";
   tmp_str000A = (string)Fa_d_01;
   tmp_str000B = "Setting SL: ";
   if (Ii_007C == 1) { 
   tmp_str000C = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str000C, " ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   } 
   else { 
   if (Ii_007C == 2) { 
   Gi_0000 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0000 > 0) { 
   FileSeek(Gi_0000, 0, 2);
   tmp_str000D = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0000, tmp_str000D, " VERBOSE: ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   FileClose(Gi_0000);
   }}} 
   if (OrderModify(Fa_i_00, OrderOpenPrice(), Fa_d_01, Fa_d_02, 0, 0)) { 
   tmp_str000E = "";
   tmp_str000F = "";
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = "";
   tmp_str0015 = "";
   tmp_str0016 = (string)Fa_d_02;
   tmp_str0017 = ", Profit Target: ";
   tmp_str0018 = (string)Fa_d_01;
   tmp_str0019 = "Order updates, StopLoss: ";
   VerboseLog(tmp_str0019, tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E);
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   Gi_0001 = GetLastError();
   Li_FFF8 = Gi_0001;
   tmp_str001A = "";
   tmp_str001B = "";
   tmp_str001C = "";
   tmp_str001D = "";
   tmp_str001E = "";
   tmp_str001F = "";
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = ErrorDescription(Gi_0001);
   tmp_str0023 = " : ";
   tmp_str0024 = (string)Gi_0001;
   tmp_str0025 = "Error modifying order: ";
   VerboseLog(tmp_str0025, tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C, tmp_str001B, tmp_str001A);
   if (Fa_i_07 != 0) return false; 
   RefreshRates();
   sqClosePositionAtMarket(-1);
   Ii_00EC = (int)TimeCurrent();
   
   Lb_FFFF = false;
   
   return Lb_FFFF;
}

bool sqCandlePatternHammer(int Fa_i_00)
{
   bool Lb_FFFF;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
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

   Lb_FFFF = false;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Ld_FFD8 = 0;
   Ld_FFD0 = 0;
   Ld_FFC8 = 0;
   Ld_FFC0 = 0;
   Ld_FFB8 = 0;
   Ld_FFB0 = 0;
   Ld_FFA8 = 0;
   Ld_FFA0 = 0;
   Ld_FF98 = 0;
   Ld_FF90 = 0;
   Ld_FF88 = 0;
   Ld_FF80 = 0;
   Ld_FF78 = 0;
   Ld_FF70 = 0;
   Ld_FFF0 = High[Fa_i_00];
   Ld_FFE8 = Low[Fa_i_00];
   Gi_0002 = Fa_i_00 + 1;
   Ld_FFE0 = Low[Gi_0002];
   Gi_0003 = Fa_i_00 + 2;
   Ld_FFD8 = Low[Gi_0003];
   Gi_0004 = Fa_i_00 + 3;
   Ld_FFD0 = Low[Gi_0004];
   Ld_FFC8 = Open[Fa_i_00];
   Ld_FFC0 = Close[Fa_i_00];
   Ld_FFB8 = (Ld_FFF0 - Ld_FFE8);
   Ld_FFB0 = 0;
   Ld_FFA8 = 0;
   Ld_FFA0 = 0.9;
   Ld_FF98 = 12;
   if ((Ld_FFC8 > Ld_FFC0)) { 
   Ld_FFA8 = Ld_FFC8;
   Ld_FFB0 = Ld_FFC0;
   } 
   else { 
   Ld_FFA8 = Ld_FFC0;
   Ld_FFB0 = Ld_FFC8;
   } 
   Ld_FF90 = (Ld_FFB0 - Ld_FFE8);
   Ld_FF88 = (Ld_FFF0 - Ld_FFA8);
   Ld_FF80 = fabs((Ld_FFC8 - Ld_FFC0));
   Ld_FF78 = (Ld_FF80 * Ld_FFA0);
   Ld_FF70 = Id_0090;
   if ((Ld_FFE8 > Ld_FFE0)) return false; 
   if ((Ld_FFE8 >= Ld_FFD8)) return false; 
   if ((Ld_FFE8 >= Ld_FFD0)) return false; 
   if (((Ld_FF90 / 2) > Ld_FF88) && (Ld_FF90 > Ld_FF78) && (Ld_FFB8 >= (Ld_FF98 * Id_0090)) && (Ld_FFC8 != Ld_FFC0) && ((Ld_FF90 / 3) <= Ld_FF88) && ((Ld_FF90 / 4) <= Ld_FF88)) { 
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   if (((Ld_FF90 / 3) > Ld_FF88) && (Ld_FF90 > Ld_FF78) && (Ld_FFB8 >= (Ld_FF98 * Ld_FF70)) && (Ld_FFC8 != Ld_FFC0) && ((Ld_FF90 / 4) <= Ld_FF88)) { 
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   if (((Ld_FF90 / 4) <= Ld_FF88)) return false; 
   if ((Ld_FF90 <= Ld_FF78)) return false; 
   if ((Ld_FFB8 < (Ld_FF98 * Ld_FF70))) return false; 
   if ((Ld_FFC8 == Ld_FFC0)) return false; 
   Lb_FFFF = true;
   return Lb_FFFF;
   
   Lb_FFFF = false;
   
   return Lb_FFFF;
}

bool sqCandlePatternShootingStar(int Fa_i_00)
{
   bool Lb_FFFF;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
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

   Lb_FFFF = false;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Ld_FFD8 = 0;
   Ld_FFD0 = 0;
   Ld_FFC8 = 0;
   Ld_FFC0 = 0;
   Ld_FFB8 = 0;
   Ld_FFB0 = 0;
   Ld_FFA8 = 0;
   Ld_FFA0 = 0;
   Ld_FF98 = 0;
   Ld_FF90 = 0;
   Ld_FF88 = 0;
   Ld_FF80 = 0;
   Ld_FF78 = 0;
   Ld_FF70 = 0;
   Ld_FFF0 = Low[Fa_i_00];
   Ld_FFE8 = High[Fa_i_00];
   Gi_0002 = Fa_i_00 + 1;
   Ld_FFE0 = High[Gi_0002];
   Gi_0003 = Fa_i_00 + 2;
   Ld_FFD8 = High[Gi_0003];
   Gi_0004 = Fa_i_00 + 3;
   Ld_FFD0 = High[Gi_0004];
   Ld_FFC8 = Open[Fa_i_00];
   Ld_FFC0 = Close[Fa_i_00];
   Ld_FFB8 = (Ld_FFE8 - Ld_FFF0);
   Ld_FFB0 = 0;
   Ld_FFA8 = 0;
   Ld_FFA0 = 0.9;
   Ld_FF98 = 12;
   if ((Ld_FFC8 > Ld_FFC0)) { 
   Ld_FFA8 = Ld_FFC8;
   Ld_FFB0 = Ld_FFC0;
   } 
   else { 
   Ld_FFA8 = Ld_FFC0;
   Ld_FFB0 = Ld_FFC8;
   } 
   Ld_FF90 = (Ld_FFB0 - Ld_FFF0);
   Ld_FF88 = (Ld_FFE8 - Ld_FFA8);
   Ld_FF80 = fabs((Ld_FFC8 - Ld_FFC0));
   Ld_FF78 = (Ld_FF80 * Ld_FFA0);
   Ld_FF70 = Id_0090;
   if ((Ld_FFE8 < Ld_FFE0)) return false; 
   if ((Ld_FFE8 <= Ld_FFD8)) return false; 
   if ((Ld_FFE8 <= Ld_FFD0)) return false; 
   if (((Ld_FF88 / 2) > Ld_FF90) && (Ld_FF88 > (Ld_FF78 * 2)) && (Ld_FFB8 >= (Ld_FF98 * Id_0090)) && (Ld_FFC8 != Ld_FFC0) && ((Ld_FF88 / 3) <= Ld_FF90) && ((Ld_FF88 / 4) <= Ld_FF90)) { 
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   if (((Ld_FF88 / 3) > Ld_FF90) && (Ld_FF88 > (Ld_FF78 * 2)) && (Ld_FFB8 >= (Ld_FF98 * Ld_FF70)) && (Ld_FFC8 != Ld_FFC0) && ((Ld_FF88 / 4) <= Ld_FF90)) { 
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   if (((Ld_FF88 / 4) <= Ld_FF90)) return false; 
   if ((Ld_FF88 <= (Ld_FF78 * 2))) return false; 
   if ((Ld_FFB8 < (Ld_FF98 * Ld_FF70))) return false; 
   if ((Ld_FFC8 == Ld_FFC0)) return false; 
   Lb_FFFF = true;
   return Lb_FFFF;
   
   Lb_FFFF = false;
   
   return Lb_FFFF;
}

void sqTextFillTotals()
{
   string tmp_str0000;
   string tmp_str0001;

   Gi_0000 = 0;
   Gi_0001 = 0;
   Gd_0002 = 0;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = 0;
   Gi_0007 = 0;
   Gd_0008 = 0;
   Gi_0009 = 0;
   Gi_000A = 0;
   Gi_000B = 0;
   Gi_000C = 0;
   Gi_000D = 0;
   Gi_000E = 0;
   Gd_000F = 0;
   Gi_0010 = 0;
   Gi_0011 = 0;
   Gi_0012 = Ii_00E8;
   Gi_0001 = 100;
   Gi_0000 = 0;
   Gd_0002 = 0;
   Gi_0003 = 0;
   Gi_0004 = 0;
   Gi_0005 = HistoryTotal();
   if (Gi_0005 >= 0) { 
   do { 
   if (OrderSelect(Gi_0005, 0, 1) == true && OrderSymbol() == _Symbol) { 
   if (Gi_0000 == 0 || OrderMagicNumber() == Gi_0000) { 
   
   Gi_0003 = Gi_0003 + 1;
   if (OrderType() == OP_BUY) { 
   Gd_0013 = OrderClosePrice();
   Gd_0002 = (Gd_0013 - OrderOpenPrice());
   } 
   else { 
   Gd_0013 = OrderOpenPrice();
   Gd_0002 = (Gd_0013 - OrderClosePrice());
   } 
   if ((Gd_0002 > 0)) { 
   Gi_0004 = Gi_0004 + 1;
   } 
   if (Gi_0003 >= Gi_0001) break; 
   }} 
   Gi_0005 = Gi_0005 - 1;
   } while (Gi_0005 >= 0); 
   } 
   tmp_str0000 = (string)Gi_0004;
   tmp_str0000 = "Total profits/losses so far: " + tmp_str0000;
   tmp_str0000 = tmp_str0000 + "/";
   Gi_0007 = 100;
   Gi_0006 = 0;
   Gd_0008 = 0;
   Gi_0009 = 0;
   Gi_000A = 0;
   Gi_000B = HistoryTotal();
   if (Gi_000B >= 0) { 
   do { 
   if (OrderSelect(Gi_000B, 0, 1) == true && OrderSymbol() == _Symbol) { 
   if (Gi_0006 == 0 || OrderMagicNumber() == Gi_0006) { 
   
   Gi_0009 = Gi_0009 + 1;
   if (OrderType() == OP_BUY) { 
   Gd_0013 = OrderClosePrice();
   Gd_0008 = (Gd_0013 - OrderOpenPrice());
   } 
   else { 
   Gd_0013 = OrderOpenPrice();
   Gd_0008 = (Gd_0013 - OrderClosePrice());
   } 
   if ((Gd_0008 < 0)) { 
   Gi_000A = Gi_000A + 1;
   } 
   if (Gi_0009 >= Gi_0007) break; 
   }} 
   Gi_000B = Gi_000B - 1;
   } while (Gi_000B >= 0); 
   } 
   tmp_str0001 = (string)Gi_000A;
   tmp_str0000 = tmp_str0000 + tmp_str0001;
   ObjectSetText("lineto", tmp_str0000, 8, "Tahoma", Gi_0012);
   Gi_0013 = Ii_00E8;
   Gi_000E = 1000;
   Gi_000D = 0;
   Gd_000F = 0;
   Gi_0010 = 0;
   Gi_0011 = HistoryTotal();
   if (Gi_0011 >= 0) { 
   do { 
   if (OrderSelect(Gi_0011, 0, 1) == true && OrderSymbol() == _Symbol) { 
   if (Gi_000D == 0 || OrderMagicNumber() == Gi_000D) { 
   
   Gi_0010 = Gi_0010 + 1;
   Gd_000F = (Gd_000F + OrderProfit());
   if (Gi_0010 >= Gi_000E) break; 
   }} 
   Gi_0011 = Gi_0011 - 1;
   } while (Gi_0011 >= 0); 
   } 
   Gi_000C = (int)Gd_000F;
   tmp_str0001 = "Total P/L so far: " + DoubleToString(Gi_000C, 2);
   ObjectSetText("linetp", tmp_str0001, 8, "Tahoma", Gi_0013);
}

string sqGetOrderTypeAsString(int Fa_i_00)
{
   string tmp_str0000;

   returned_i = Fa_i_00;
   if (returned_i > 5) return "Unknown"; 
   if (returned_i == 0) return "Buy";
   if (returned_i == 1) return "Sell";
   if (returned_i == 2) return "Buy Limit";
   if (returned_i == 4) return "Buy Stop";
   if (returned_i == 3) return "Sell Limit";
   if (returned_i == 5) return "Sell Stop";
   return "Unknown";
}

void VerboseLog(string Fa_s_00, string Fa_s_01, string Fa_s_02, string Fa_s_03, string Fa_s_04, string Fa_s_05, string Fa_s_06, string Fa_s_07, string Fa_s_08, string Fa_s_09, string Fa_s_0A, string Fa_s_0B)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;

   Gi_0000 = 0;
   if (Ii_007C != 1) { 
   tmp_str0000 = Fa_s_0B;
   tmp_str0001 = Fa_s_0A;
   tmp_str0002 = Fa_s_09;
   tmp_str0003 = Fa_s_08;
   tmp_str0004 = Fa_s_07;
   tmp_str0005 = Fa_s_06;
   tmp_str0006 = Fa_s_05;
   tmp_str0007 = Fa_s_04;
   tmp_str0008 = Fa_s_03;
   tmp_str0009 = Fa_s_02;
   tmp_str000A = Fa_s_01;
   tmp_str000B = Fa_s_00;
   tmp_str000C = TimeToString(TimeCurrent(), 3);
   Print(tmp_str000C, " ", tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   } 
   tmp_str000D = Fa_s_0B;
   tmp_str000E = Fa_s_0A;
   tmp_str000F = Fa_s_09;
   tmp_str0010 = Fa_s_08;
   tmp_str0011 = Fa_s_07;
   tmp_str0012 = Fa_s_06;
   tmp_str0013 = Fa_s_05;
   tmp_str0014 = Fa_s_04;
   tmp_str0015 = Fa_s_03;
   tmp_str0016 = Fa_s_02;
   tmp_str0017 = Fa_s_01;
   tmp_str0018 = Fa_s_00;
   if (Ii_007C == 1) { 
   tmp_str0019 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", tmp_str0019, " ", tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E, tmp_str000D);
   return ;
   } 
   if (Ii_007C != 2) return; 
   Gi_0000 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Gi_0000 <= 0) return; 
   FileSeek(Gi_0000, 0, 2);
   tmp_str001A = TimeToString(TimeCurrent(), 3);
   FileWrite(Gi_0000, tmp_str001A, " VERBOSE: ", tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E, tmp_str000D);
   FileClose(Gi_0000);
   
}

string ErrorDescription(int error_code)
{
      string error_string;
//---
   switch(error_code)
     {
      //--- codes returned from trade server
      case 0:   error_string="no error";                                                   break;
      case 1:   error_string="no error, trade conditions not changed";                     break;
      case 2:   error_string="common error";                                               break;
      case 3:   error_string="invalid trade parameters";                                   break;
      case 4:   error_string="trade server is busy";                                       break;
      case 5:   error_string="old version of the client terminal";                         break;
      case 6:   error_string="no connection with trade server";                            break;
      case 7:   error_string="not enough rights";                                          break;
      case 8:   error_string="too frequent requests";                                      break;
      case 9:   error_string="malfunctional trade operation (never returned error)";       break;
      case 64:  error_string="account disabled";                                           break;
      case 65:  error_string="invalid account";                                            break;
      case 128: error_string="trade timeout";                                              break;
      case 129: error_string="invalid price";                                              break;
      case 130: error_string="invalid stops";                                              break;
      case 131: error_string="invalid trade volume";                                       break;
      case 132: error_string="market is closed";                                           break;
      case 133: error_string="trade is disabled";                                          break;
      case 134: error_string="not enough money";                                           break;
      case 135: error_string="price changed";                                              break;
      case 136: error_string="off quotes";                                                 break;
      case 137: error_string="broker is busy (never returned error)";                      break;
      case 138: error_string="requote";                                                    break;
      case 139: error_string="order is locked";                                            break;
      case 140: error_string="long positions only allowed";                                break;
      case 141: error_string="too many requests";                                          break;
      case 145: error_string="modification denied because order is too close to market";   break;
      case 146: error_string="trade context is busy";                                      break;
      case 147: error_string="expirations are denied by broker";                           break;
      case 148: error_string="amount of open and pending orders has reached the limit";    break;
      case 149: error_string="hedging is prohibited";                                      break;
      case 150: error_string="prohibited by FIFO rules";                                   break;
      //--- mql4 errors
      case 4000: error_string="no error (never generated code)";                           break;
      case 4001: error_string="wrong function pointer";                                    break;
      case 4002: error_string="array index is out of range";                               break;
      case 4003: error_string="no memory for function call stack";                         break;
      case 4004: error_string="recursive stack overflow";                                  break;
      case 4005: error_string="not enough stack for parameter";                            break;
      case 4006: error_string="no memory for parameter string";                            break;
      case 4007: error_string="no memory for temp string";                                 break;
      case 4008: error_string="non-initialized string";                                    break;
      case 4009: error_string="non-initialized string in array";                           break;
      case 4010: error_string="no memory for array\' string";                              break;
      case 4011: error_string="too long string";                                           break;
      case 4012: error_string="remainder from zero divide";                                break;
      case 4013: error_string="zero divide";                                               break;
      case 4014: error_string="unknown command";                                           break;
      case 4015: error_string="wrong jump (never generated error)";                        break;
      case 4016: error_string="non-initialized array";                                     break;
      case 4017: error_string="dll calls are not allowed";                                 break;
      case 4018: error_string="cannot load library";                                       break;
      case 4019: error_string="cannot call function";                                      break;
      case 4020: error_string="expert function calls are not allowed";                     break;
      case 4021: error_string="not enough memory for temp string returned from function";  break;
      case 4022: error_string="system is busy (never generated error)";                    break;
      case 4023: error_string="dll-function call critical error";                          break;
      case 4024: error_string="internal error";                                            break;
      case 4025: error_string="out of memory";                                             break;
      case 4026: error_string="invalid pointer";                                           break;
      case 4027: error_string="too many formatters in the format function";                break;
      case 4028: error_string="parameters count is more than formatters count";            break;
      case 4029: error_string="invalid array";                                             break;
      case 4030: error_string="no reply from chart";                                       break;
      case 4050: error_string="invalid function parameters count";                         break;
      case 4051: error_string="invalid function parameter value";                          break;
      case 4052: error_string="string function internal error";                            break;
      case 4053: error_string="some array error";                                          break;
      case 4054: error_string="incorrect series array usage";                              break;
      case 4055: error_string="custom indicator error";                                    break;
      case 4056: error_string="arrays are incompatible";                                   break;
      case 4057: error_string="global variables processing error";                         break;
      case 4058: error_string="global variable not found";                                 break;
      case 4059: error_string="function is not allowed in testing mode";                   break;
      case 4060: error_string="function is not confirmed";                                 break;
      case 4061: error_string="send mail error";                                           break;
      case 4062: error_string="string parameter expected";                                 break;
      case 4063: error_string="integer parameter expected";                                break;
      case 4064: error_string="double parameter expected";                                 break;
      case 4065: error_string="array as parameter expected";                               break;
      case 4066: error_string="requested history data is in update state";                 break;
      case 4067: error_string="internal trade error";                                      break;
      case 4068: error_string="resource not found";                                        break;
      case 4069: error_string="resource not supported";                                    break;
      case 4070: error_string="duplicate resource";                                        break;
      case 4071: error_string="cannot initialize custom indicator";                        break;
      case 4072: error_string="cannot load custom indicator";                              break;
      case 4073: error_string="no history data";                                           break;
      case 4074: error_string="not enough memory for history data";                        break;
      case 4075: error_string="not enough memory for indicator";                           break;
      case 4099: error_string="end of file";                                               break;
      case 4100: error_string="some file error";                                           break;
      case 4101: error_string="wrong file name";                                           break;
      case 4102: error_string="too many opened files";                                     break;
      case 4103: error_string="cannot open file";                                          break;
      case 4104: error_string="incompatible access to a file";                             break;
      case 4105: error_string="no order selected";                                         break;
      case 4106: error_string="unknown symbol";                                            break;
      case 4107: error_string="invalid price parameter for trade function";                break;
      case 4108: error_string="invalid ticket";                                            break;
      case 4109: error_string="trade is not allowed in the expert properties";             break;
      case 4110: error_string="longs are not allowed in the expert properties";            break;
      case 4111: error_string="shorts are not allowed in the expert properties";           break;
      case 4200: error_string="object already exists";                                     break;
      case 4201: error_string="unknown object property";                                   break;
      case 4202: error_string="object does not exist";                                     break;
      case 4203: error_string="unknown object type";                                       break;
      case 4204: error_string="no object name";                                            break;
      case 4205: error_string="object coordinates error";                                  break;
      case 4206: error_string="no specified subwindow";                                    break;
      case 4207: error_string="graphical object error";                                    break;
      case 4210: error_string="unknown chart property";                                    break;
      case 4211: error_string="chart not found";                                           break;
      case 4212: error_string="chart subwindow not found";                                 break;
      case 4213: error_string="chart indicator not found";                                 break;
      case 4220: error_string="symbol select error";                                       break;
      case 4250: error_string="notification error";                                        break;
      case 4251: error_string="notification parameter error";                              break;
      case 4252: error_string="notifications disabled";                                    break;
      case 4253: error_string="notification send too frequent";                            break;
      case 4260: error_string="ftp server is not specified";                               break;
      case 4261: error_string="ftp login is not specified";                                break;
      case 4262: error_string="ftp connect failed";                                        break;
      case 4263: error_string="ftp connect closed";                                        break;
      case 4264: error_string="ftp change path error";                                     break;
      case 4265: error_string="ftp file error";                                            break;
      case 4266: error_string="ftp error";                                                 break;
      case 5001: error_string="too many opened files";                                     break;
      case 5002: error_string="wrong file name";                                           break;
      case 5003: error_string="too long file name";                                        break;
      case 5004: error_string="cannot open file";                                          break;
      case 5005: error_string="text file buffer allocation error";                         break;
      case 5006: error_string="cannot delete file";                                        break;
      case 5007: error_string="invalid file handle (file closed or was not opened)";       break;
      case 5008: error_string="wrong file handle (handle index is out of handle table)";   break;
      case 5009: error_string="file must be opened with FILE_WRITE flag";                  break;
      case 5010: error_string="file must be opened with FILE_READ flag";                   break;
      case 5011: error_string="file must be opened with FILE_BIN flag";                    break;
      case 5012: error_string="file must be opened with FILE_TXT flag";                    break;
      case 5013: error_string="file must be opened with FILE_TXT or FILE_CSV flag";        break;
      case 5014: error_string="file must be opened with FILE_CSV flag";                    break;
      case 5015: error_string="file read error";                                           break;
      case 5016: error_string="file write error";                                          break;
      case 5017: error_string="string size must be specified for binary file";             break;
      case 5018: error_string="incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: error_string="file is directory, not file";                               break;
      case 5020: error_string="file does not exist";                                       break;
      case 5021: error_string="file cannot be rewritten";                                  break;
      case 5022: error_string="wrong directory name";                                      break;
      case 5023: error_string="directory does not exist";                                  break;
      case 5024: error_string="specified file is not directory";                           break;
      case 5025: error_string="cannot delete directory";                                   break;
      case 5026: error_string="cannot clean directory";                                    break;
      case 5027: error_string="array resize error";                                        break;
      case 5028: error_string="string resize error";                                       break;
      case 5029: error_string="structure contains strings or dynamic arrays";              break;
      default:   error_string="unknown error";
     }
//---
   return(error_string);
  }
  
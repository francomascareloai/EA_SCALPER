#property copyright "The Money Tree Robot by LeapFX";
#property link "https://www.leapfx.com";
#property version "4.0";
#property strict

#import "wininet.dll"

int InternetOpenW(string,int,string,string,int);
int InternetOpenUrlW(int,string,string,int,int,int);
int InternetReadFile(int,uchar&[],int,int&[]);
int InternetCloseHandle(int);

#import

extern string Receipt = "Enter Your Receipt Here";
extern string Email = "Enter Your Email Here";
extern double LotSize = 0.01;

string Is_0000;
string Is_0038;
string Is_0028;
long Gl_0000;
int returned_i;
int Ii_006C;
int Ii_0070;
int Ii_0074;
int Ii_0078;
int Ii_007C;
int Ii_0080;
int Ii_0084;
int Ii_0088;
int Ii_008C;
int Ii_0090;
int Ii_0094;
int Ii_0098;
int Ii_009C;
int Ii_00A0;
double Id_08E0;
double Id_07A0;
double Id_07A8;
double Id_07B0;
double Id_07B8;
double Id_07C0;
double Id_07E8;
double Id_07D8;
int Ii_08E8;
int Ii_08EC;
bool Ib_08F0;
bool Ib_00E8;
bool Ib_070C;
double Id_00C0;
double Id_00D0;
int Ii_08F4;
int Ii_08F8;
string Is_0900;
string Is_0910;
double Id_00D8;
bool Ib_0754;
int Ii_091C;
int Ii_00F8;
int Ii_0100;
int Ii_00FC;
int Ii_0104;
int Ii_0920;
double Ind_004;
bool Gb_0000;
double Ind_000;
double Id_38F0;
double Ind_002;
double Gd_0000;
double Ind_003;
int Ii_0108;
int Ii_010C;
double Id_0110;
int Ii_0118;
int Ii_011C;
bool Ib_0120;
int Ii_0124;
int Ii_0128;
int Ii_012C;
double Id_0130;
double Id_0138;
int Ii_0140;
double Id_0148;
int Ii_0150;
double Id_0158;
double Id_0160;
int Ii_0168;
double Id_0170;
int Ii_0178;
double Id_0180;
int Ii_0188;
double Id_0190;
double Id_0198;
int Ii_01A0;
double Id_01A8;
double Id_01B0;
int Ii_01B8;
double Id_01C0;
int Ii_01C8;
double Id_01D0;
int Ii_01D8;
double Id_01E0;
double Id_01E8;
int Ii_01F0;
double Id_01F8;
double Id_0200;
int Ii_0208;
double Id_0210;
int Ii_0218;
double Id_0220;
int Ii_0228;
double Id_0230;
double Id_0238;
int Ii_0240;
double Id_0248;
double Id_0250;
int Ii_0258;
double Id_0260;
int Ii_0268;
double Id_0270;
int Ii_0278;
double Id_0280;
double Id_0288;
int Ii_0290;
double Id_0298;
double Id_02A0;
int Ii_02A8;
double Id_02B0;
int Ii_02B8;
double Id_02C0;
int Ii_02C8;
double Id_02D0;
double Id_02D8;
int Ii_02E0;
double Id_02E8;
double Id_02F0;
int Ii_02F8;
double Id_0300;
int Ii_0308;
double Id_0310;
int Ii_0318;
double Id_0320;
double Id_0328;
int Ii_0330;
double Id_0338;
double Id_0340;
int Ii_0348;
double Id_0350;
bool Ib_0358;
int Ii_035C;
int Ii_0360;
int Ii_0364;
double Id_0368;
double Id_0370;
int Ii_0378;
double Id_0380;
int Ii_0388;
double Id_0390;
double Id_0398;
int Ii_03A0;
double Id_03A8;
int Ii_03B0;
double Id_03B8;
int Ii_03C0;
double Id_03C8;
double Id_03D0;
int Ii_03D8;
double Id_03E0;
double Id_03E8;
int Ii_03F0;
double Id_03F8;
int Ii_0400;
double Id_0408;
int Ii_0410;
double Id_0418;
double Id_0420;
int Ii_0428;
double Id_0430;
double Id_0438;
int Ii_0440;
double Id_0448;
int Ii_0450;
double Id_0458;
int Ii_0460;
double Id_0468;
double Id_0470;
int Ii_0478;
double Id_0480;
double Id_0488;
int Ii_0490;
double Id_0498;
int Ii_04A0;
double Id_04A8;
int Ii_04B0;
double Id_04B8;
double Id_04C0;
int Ii_04C8;
double Id_04D0;
double Id_04D8;
int Ii_04E0;
double Id_04E8;
int Ii_04F0;
double Id_04F8;
int Ii_0500;
double Id_0508;
double Id_0510;
int Ii_0518;
double Id_0520;
double Id_0528;
int Ii_0530;
double Id_0538;
int Ii_0540;
double Id_0548;
int Ii_0550;
double Id_0558;
double Id_0560;
int Ii_0568;
double Id_0570;
double Id_0578;
int Ii_0580;
double Id_0588;
double Id_0590;
int Ii_0598;
double Id_05A0;
int Ii_05A8;
int Ii_05AC;
double Id_05B0;
int Ii_05B8;
double Id_05C0;
int Ii_05C8;
double Id_05D0;
int Ii_05D8;
int Ii_05DC;
double Id_05E0;
int Ii_05E8;
double Id_05F0;
int Ii_05F8;
double Id_0600;
int Ii_0608;
double Id_0610;
int Ii_0618;
double Id_0620;
int Ii_0628;
int Ii_062C;
double Id_0630;
int Ii_0638;
int Ii_063C;
double Id_0640;
int Ii_0648;
double Id_0650;
int Ii_0658;
double Id_0660;
int Ii_0668;
int Ii_066C;
double Id_0670;
int Ii_0678;
double Id_0680;
int Ii_0688;
double Id_0690;
int Ii_0698;
int Ii_069C;
double Id_06A0;
int Ii_06A8;
double Id_06B0;
int Ii_06B8;
double Id_06C0;
int Ii_06C8;
double Id_06D0;
int Ii_06D8;
double Id_06E0;
int Ii_06E8;
int Ii_06EC;
double Id_06F0;
int Ii_06F8;
int Ii_06FC;
double Id_0700;
int Ii_0708;
int Gi_0000;
long Gl_0001;
int Gi_0001;
long Gl_0002;
int Gi_0002;
long Gl_0003;
string Is_0748;
int Ii_0758;
int Ii_075C;
bool returned_b;
double Id_0768;
int Gi_0003;
bool Gb_0004;
double Gd_0003;
int Gi_0004;
bool Ib_0060;
int Ii_005C;
long Il_0780;
long returned_l;
long Gl_0004;
int Gi_0005;
long Gl_0005;
int Gi_0006;
int Ii_0064;
bool Gb_0006;
int Ii_0048;
int Ii_0058;
bool Gb_0007;
double Gd_0006;
double Id_07E0;
int Gi_0007;
bool Gb_0008;
double Gd_0007;
int Gi_0008;
long Il_0808;
long Gl_0008;
int Gi_0009;
long Gl_0009;
int Gi_000A;
bool Gb_000A;
int Ii_0044;
int Ii_0054;
bool Gb_000B;
double Gd_000A;
int Ii_07F0;
double Id_0830;
int Ii_0838;
double Id_0840;
int Ii_0050;
double Id_0850;
int Ii_085C;
int Ii_0860;
double Id_0868;
int Ii_0870;
double Id_0878;
int Ii_0880;
int Ii_004C;
double Id_0888;
int Ii_0894;
double Id_0898;
int Ii_08A0;
double Id_08A8;
int Ii_08B0;
double Id_08B8;
bool Ib_000C;
int Ii_0010;
int Ii_0014;
int Ii_0018;
int Ii_001C;
int Ii_0020;
int Ii_0024;
int Ii_0068;
double Id_00A8;
bool Ib_00B0;
double Id_00B8;
double Id_00C8;
double Id_00E0;
double Id_00F0;
int Ii_0710;
long Il_0718;
long Il_0720;
int Ii_0728;
long Il_0730;
int Ii_0738;
long Il_0740;
bool Ib_0760;
int Ii_0770;
bool Ib_0774;
double Id_0778;
long Il_0788;
int Ii_0790;
long Il_0798;
int Ii_07C8;
double Id_07D0;
int Ii_07F4;
bool Ib_07F8;
double Id_0800;
int Ii_0810;
long Il_0818;
int Ii_0820;
double Id_0828;
bool Ib_083C;
int Ii_0848;
bool Ib_0858;
bool Ib_0890;
bool Ib_08C0;
int Ii_08C4;
long Il_08C8;
int Ii_08D0;
long Il_08D8;
double Id_0928;
int Ii_0930;
int Ii_0934;
double Id_0938;
int Ii_0940;
int Ii_0944;
int Ii_0948;
double Id_0950;
int Ii_0958;
long Il_0960;
int Ii_0968;
int Ii_096C;
double Id_0970;
int Ii_0978;
int Ii_097C;
int Ii_0980;
int Ii_0984;
double Id_0988;
int Ii_0990;
int Ii_0994;
int Ii_0998;
long Il_09A0;
int Ii_09A8;
int Ii_09AC;
int Ii_09B0;
int Ii_09B4;
int Ii_09B8;
int Ii_09BC;
int Ii_09C0;
int Ii_09C4;
long Il_09C8;
int Ii_09D0;
int Ii_09D4;
int Ii_09D8;
double Id_09E0;
int Ii_09E8;
int Ii_09EC;
int Ii_09F0;
int Ii_09F4;
int Ii_09F8;
int Ii_09FC;
double Id_0A00;
int Ii_0A08;
long Il_0A10;
int Ii_0A18;
int Ii_0A1C;
int Ii_0A20;
int Ii_0A24;
int Ii_0A28;
int Ii_0A2C;
int Ii_0A30;
double Id_0A38;
int Ii_0A40;
long Il_0A48;
int Ii_0A50;
int Ii_0A54;
int Ii_0A58;
double Id_0A60;
int Ii_0A68;
int Ii_0A6C;
int Ii_0A70;
int Ii_0A74;
int Ii_0A78;
int Ii_0A7C;
long Il_0A80;
int Ii_0A88;
int Ii_0A8C;
int Ii_0A90;
int Ii_0A94;
int Ii_0A98;
double Id_0AA0;
int Ii_0AA8;
int Ii_0AAC;
int Ii_0AB0;
int Ii_0AB4;
long Il_0AB8;
int Ii_0AC0;
int Ii_0AC4;
int Ii_0AC8;
int Ii_0ACC;
int Ii_0AD0;
int Ii_0AD4;
int Ii_0AD8;
int Ii_0ADC;
double Id_0AE0;
int Ii_0AE8;
long Il_0AF0;
int Ii_0AF8;
int Ii_0AFC;
int Ii_0B00;
int Ii_0B04;
double Id_0B08;
int Ii_0B10;
int Ii_0B14;
long Il_0B18;
int Ii_0B20;
int Ii_0B24;
double Id_0B28;
int Ii_0B30;
int Ii_0B34;
double Id_0B38;
int Ii_0B40;
int Ii_0B44;
long Il_0B48;
int Ii_0B50;
int Ii_0B54;
int Ii_0B58;
int Ii_0B5C;
int Ii_0B60;
double Id_0B68;
long Il_0B70;
double Id_0B78;
long Il_0B80;
int Ii_0B88;
int Ii_0B8C;
int Ii_0B90;
int Ii_0B94;
int Ii_0B98;
double Id_0BA0;
int Ii_0BA8;
int Ii_0BAC;
int Ii_0BB0;
int Ii_0BB4;
int Ii_0BB8;
double Id_0BC0;
int Ii_0BC8;
long Il_0BD0;
int Ii_0BD8;
int Ii_0BDC;
int Ii_0BE0;
int Ii_0BE4;
double Id_0BE8;
int Ii_0BF0;
int Ii_0BF4;
int Ii_0BF8;
int Ii_0BFC;
int Ii_0C00;
double Id_0C08;
int Ii_0C10;
int Ii_0C14;
int Ii_0C18;
int Ii_0C1C;
int Ii_0C20;
double Id_0C28;
int Ii_0C30;
long Il_0C38;
int Ii_0C40;
int Ii_0C44;
int Ii_0C48;
double Id_0C50;
int Ii_0C58;
bool Ib_0C5C;
long Il_0C60;
double Id_0C68;
double Id_0C70;
int Ii_0C78;
long Il_0C80;
double Id_0C88;
int Ii_0C90;
bool Ib_0C94;
long Il_0C98;
double Id_0CA0;
double Id_0CA8;
int Ii_0CB0;
long Il_0CB8;
bool Ib_0CC0;
int Ii_0CC4;
long Il_0CC8;
int Ii_0CD0;
bool Ib_0CD4;
long Il_0CD8;
double Id_0CE0;
int Ii_0CE8;
bool Ib_0CEC;
long Il_0CF0;
double Id_0CF8;
double Id_0D00;
int Ii_0D08;
long Il_0D10;
double Id_0D18;
int Ii_0D20;
bool Ib_0D24;
long Il_0D28;
double Id_0D30;
double Id_0D38;
int Ii_0D40;
long Il_0D48;
bool Ib_0D50;
int Ii_0D54;
long Il_0D58;
int Ii_0D60;
bool Ib_0D64;
long Il_0D68;
double Id_0D70;
int Ii_0D78;
bool Ib_0D7C;
long Il_0D80;
double Id_0D88;
double Id_0D90;
int Ii_0D98;
long Il_0DA0;
double Id_0DA8;
int Ii_0DB0;
bool Ib_0DB4;
long Il_0DB8;
double Id_0DC0;
double Id_0DC8;
int Ii_0DD0;
long Il_0DD8;
bool Ib_0DE0;
int Ii_0DE4;
long Il_0DE8;
int Ii_0DF0;
bool Ib_0DF4;
long Il_0DF8;
double Id_0E00;
int Ii_0E08;
bool Ib_0E0C;
long Il_0E10;
double Id_0E18;
double Id_0E20;
int Ii_0E28;
long Il_0E30;
double Id_0E38;
int Ii_0E40;
bool Ib_0E44;
long Il_0E48;
double Id_0E50;
double Id_0E58;
int Ii_0E60;
long Il_0E68;
bool Ib_0E70;
int Ii_0E74;
long Il_0E78;
int Ii_0E80;
bool Ib_0E84;
long Il_0E88;
double Id_0E90;
int Ii_0E98;
bool Ib_0E9C;
long Il_0EA0;
double Id_0EA8;
double Id_0EB0;
int Ii_0EB8;
long Il_0EC0;
double Id_0EC8;
int Ii_0ED0;
bool Ib_0ED4;
long Il_0ED8;
double Id_0EE0;
double Id_0EE8;
int Ii_0EF0;
long Il_0EF8;
bool Ib_0F00;
int Ii_0F04;
long Il_0F08;
int Ii_0F10;
bool Ib_0F14;
long Il_0F18;
double Id_0F20;
int Ii_0F28;
bool Ib_0F2C;
long Il_0F30;
double Id_0F38;
double Id_0F40;
int Ii_0F48;
long Il_0F50;
double Id_0F58;
int Ii_0F60;
bool Ib_0F64;
long Il_0F68;
double Id_0F70;
double Id_0F78;
int Ii_0F80;
long Il_0F88;
bool Ib_0F90;
int Ii_0F94;
long Il_0F98;
int Ii_0FA0;
bool Ib_0FA4;
long Il_0FA8;
double Id_0FB0;
int Ii_0FB8;
bool Ib_0FBC;
long Il_0FC0;
double Id_0FC8;
double Id_0FD0;
int Ii_0FD8;
long Il_0FE0;
double Id_0FE8;
int Ii_0FF0;
bool Ib_0FF4;
long Il_0FF8;
double Id_1000;
double Id_1008;
int Ii_1010;
long Il_1018;
bool Ib_1020;
int Ii_1024;
long Il_1028;
int Ii_1030;
bool Ib_1034;
long Il_1038;
double Id_1040;
int Ii_1048;
bool Ib_104C;
long Il_1050;
double Id_1058;
double Id_1060;
int Ii_1068;
long Il_1070;
double Id_1078;
int Ii_1080;
bool Ib_1084;
long Il_1088;
double Id_1090;
double Id_1098;
int Ii_10A0;
long Il_10A8;
bool Ib_10B0;
int Ii_10B4;
long Il_10B8;
int Ii_10C0;
bool Ib_10C4;
long Il_10C8;
double Id_10D0;
int Ii_10D8;
bool Ib_10DC;
long Il_10E0;
double Id_10E8;
double Id_10F0;
int Ii_10F8;
long Il_1100;
double Id_1108;
int Ii_1110;
bool Ib_1114;
long Il_1118;
double Id_1120;
double Id_1128;
int Ii_1130;
long Il_1138;
bool Ib_1140;
int Ii_1144;
long Il_1148;
int Ii_1150;
bool Ib_1154;
long Il_1158;
double Id_1160;
int Ii_1168;
bool Ib_116C;
long Il_1170;
double Id_1178;
double Id_1180;
int Ii_1188;
long Il_1190;
double Id_1198;
int Ii_11A0;
bool Ib_11A4;
long Il_11A8;
double Id_11B0;
double Id_11B8;
int Ii_11C0;
long Il_11C8;
bool Ib_11D0;
int Ii_11D4;
long Il_11D8;
int Ii_11E0;
bool Ib_11E4;
long Il_11E8;
double Id_11F0;
int Ii_11F8;
bool Ib_11FC;
long Il_1200;
double Id_1208;
double Id_1210;
int Ii_1218;
long Il_1220;
double Id_1228;
int Ii_1230;
bool Ib_1234;
long Il_1238;
double Id_1240;
double Id_1248;
int Ii_1250;
long Il_1258;
bool Ib_1260;
int Ii_1264;
long Il_1268;
int Ii_1270;
bool Ib_1274;
long Il_1278;
double Id_1280;
int Ii_1288;
bool Ib_128C;
long Il_1290;
double Id_1298;
double Id_12A0;
int Ii_12A8;
long Il_12B0;
double Id_12B8;
int Ii_12C0;
bool Ib_12C4;
long Il_12C8;
double Id_12D0;
double Id_12D8;
int Ii_12E0;
long Il_12E8;
bool Ib_12F0;
int Ii_12F4;
long Il_12F8;
int Ii_1300;
bool Ib_1304;
long Il_1308;
double Id_1310;
int Ii_1318;
bool Ib_131C;
long Il_1320;
double Id_1328;
double Id_1330;
int Ii_1338;
long Il_1340;
double Id_1348;
int Ii_1350;
bool Ib_1354;
long Il_1358;
double Id_1360;
double Id_1368;
int Ii_1370;
long Il_1378;
bool Ib_1380;
int Ii_1384;
long Il_1388;
int Ii_1390;
bool Ib_1394;
long Il_1398;
double Id_13A0;
int Ii_13A8;
bool Ib_13AC;
long Il_13B0;
double Id_13B8;
double Id_13C0;
int Ii_13C8;
long Il_13D0;
double Id_13D8;
int Ii_13E0;
bool Ib_13E4;
long Il_13E8;
double Id_13F0;
double Id_13F8;
int Ii_1400;
long Il_1408;
bool Ib_1410;
int Ii_1414;
long Il_1418;
int Ii_1420;
bool Ib_1424;
long Il_1428;
bool Ib_1430;
double Id_1438;
double Id_1440;
bool Ib_1448;
double Id_1450;
double Id_1458;
int Ii_1460;
long Il_1468;
bool Ib_1470;
double Id_1478;
double Id_1480;
bool Ib_1488;
double Id_1490;
double Id_1498;
int Ii_14A0;
long Il_14A8;
bool Ib_14B0;
double Id_14B8;
double Id_14C0;
bool Ib_14C8;
double Id_14D0;
double Id_14D8;
int Ii_14E0;
long Il_14E8;
bool Ib_14F0;
double Id_14F8;
double Id_1500;
bool Ib_1508;
double Id_1510;
double Id_1518;
int Ii_1520;
long Il_1528;
bool Ib_1530;
double Id_1538;
double Id_1540;
bool Ib_1548;
double Id_1550;
double Id_1558;
int Ii_1560;
long Il_1568;
bool Ib_1570;
double Id_1578;
double Id_1580;
bool Ib_1588;
double Id_1590;
double Id_1598;
int Ii_15A0;
long Il_15A8;
bool Ib_15B0;
double Id_15B8;
double Id_15C0;
bool Ib_15C8;
double Id_15D0;
double Id_15D8;
int Ii_15E0;
long Il_15E8;
bool Ib_15F0;
double Id_15F8;
double Id_1600;
bool Ib_1608;
double Id_1610;
double Id_1618;
int Ii_1620;
long Il_1628;
bool Ib_1630;
double Id_1638;
double Id_1640;
bool Ib_1648;
double Id_1650;
double Id_1658;
int Ii_1660;
long Il_1668;
bool Ib_1670;
double Id_1678;
double Id_1680;
bool Ib_1688;
double Id_1690;
double Id_1698;
int Ii_16A0;
long Il_16A8;
bool Ib_16B0;
double Id_16B8;
double Id_16C0;
bool Ib_16C8;
double Id_16D0;
double Id_16D8;
int Ii_16E0;
long Il_16E8;
bool Ib_16F0;
double Id_16F8;
double Id_1700;
bool Ib_1708;
double Id_1710;
double Id_1718;
int Ii_1720;
long Il_1728;
bool Ib_1730;
double Id_1738;
double Id_1740;
bool Ib_1748;
double Id_1750;
double Id_1758;
int Ii_1760;
long Il_1768;
bool Ib_1770;
double Id_1778;
double Id_1780;
bool Ib_1788;
double Id_1790;
double Id_1798;
int Ii_17A0;
long Il_17A8;
long Il_17B0;
double Id_17B8;
long Il_17C0;
long Il_17C8;
long Il_17D0;
long Il_17D8;
int Ii_17E0;
int Ii_17E4;
double Id_17E8;
long Il_17F0;
int Ii_17F8;
double Id_1800;
long Il_1808;
double Id_1810;
int Ii_1818;
long Il_1820;
long Il_1828;
long Il_1830;
int Ii_1838;
long Il_1840;
int Ii_1848;
double Id_1850;
long Il_1858;
int Ii_1860;
long Il_1868;
long Il_1870;
long Il_1878;
long Il_1880;
long Il_1888;
long Il_1890;
int Ii_1898;
long Il_18A0;
long Il_18A8;
long Il_18B0;
long Il_18B8;
long Il_18C0;
long Il_18C8;
int Ii_18D0;
long Il_18D8;
long Il_18E0;
int Ii_18E8;
long Il_18F0;
long Il_18F8;
long Il_1900;
long Il_1908;
bool Ib_1910;
double Id_1918;
long Il_1920;
bool Ib_1928;
bool Ib_1929;
bool Ib_192A;
int Ii_192C;
double Id_1930;
long Il_1938;
bool Ib_1940;
long Il_1948;
long Il_1950;
long Il_1958;
double Id_1960;
double Id_1968;
double Id_1970;
bool Ib_1978;
bool Ib_38F8;
bool Gb_0001;
double Gd_0001;
double Gd_0002;
double Gd_0005;
long Gl_0006;
long Gl_000A;
long Gl_000B;
double Gd_000B;
int Gi_000C;
bool Gb_000C;
long Gl_000C;
double Gd_000C;
double Gd_000D;
int Gi_000E;
long Gl_000E;
double Gd_0010;
int Gi_0011;
bool Gb_0011;
long Gl_0011;
double Gd_0011;
double Gd_0012;
int Gi_0013;
long Gl_0013;
bool Gb_0015;
int Gi_0015;
long Gl_0015;
bool Gb_0016;
long Gl_0016;
double Gd_0016;
int Gi_0017;
bool Gb_0017;
long Gl_0017;
double Gd_0017;
double Gd_0018;
int Gi_0019;
long Gl_0019;
double Gd_001B;
int Gi_001C;
bool Gb_001C;
long Gl_001C;
double Gd_001C;
double Gd_001D;
int Gi_001E;
long Gl_001E;
bool Gb_0020;
int Gi_0020;
long Gl_0020;
bool Gb_0021;
long Gl_0021;
double Gd_0021;
int Gi_0022;
bool Gb_0022;
long Gl_0022;
double Gd_0022;
double Gd_0023;
int Gi_0024;
long Gl_0024;
double Gd_0026;
int Gi_0027;
bool Gb_0027;
long Gl_0027;
double Gd_0027;
double Gd_0028;
int Gi_0029;
long Gl_0029;
bool Gb_002B;
int Gi_002B;
long Gl_002B;
bool Gb_002C;
long Gl_002C;
double Gd_002C;
int Gi_002D;
bool Gb_002D;
long Gl_002D;
double Gd_002D;
double Gd_002E;
int Gi_002F;
long Gl_002F;
double Gd_0031;
int Gi_0032;
bool Gb_0032;
long Gl_0032;
double Gd_0032;
double Gd_0033;
int Gi_0034;
long Gl_0034;
bool Gb_0036;
int Gi_0036;
long Gl_0036;
bool Gb_0037;
long Gl_0037;
double Gd_0037;
int Gi_0038;
bool Gb_0038;
long Gl_0038;
double Gd_0038;
double Gd_0039;
int Gi_003A;
long Gl_003A;
double Gd_003C;
int Gi_003D;
bool Gb_003D;
long Gl_003D;
double Gd_003D;
double Gd_003E;
int Gi_003F;
long Gl_003F;
bool Gb_0041;
int Gi_0041;
long Gl_0041;
bool Gb_0042;
long Gl_0042;
double Gd_0042;
int Gi_0043;
bool Gb_0043;
long Gl_0043;
double Gd_0043;
double Gd_0044;
int Gi_0045;
long Gl_0045;
double Gd_0047;
int Gi_0048;
bool Gb_0048;
long Gl_0048;
double Gd_0048;
double Gd_0049;
int Gi_004A;
long Gl_004A;
bool Gb_004C;
int Gi_004C;
long Gl_004C;
bool Gb_004D;
long Gl_004D;
double Gd_004D;
int Gi_004E;
bool Gb_004E;
long Gl_004E;
double Gd_004E;
double Gd_004F;
int Gi_0050;
long Gl_0050;
double Gd_0052;
int Gi_0053;
bool Gb_0053;
long Gl_0053;
double Gd_0053;
double Gd_0054;
int Gi_0055;
long Gl_0055;
bool Gb_0057;
int Gi_0057;
long Gl_0057;
bool Gb_0058;
long Gl_0058;
double Gd_0058;
int Gi_0059;
bool Gb_0059;
long Gl_0059;
double Gd_0059;
double Gd_005A;
int Gi_005B;
long Gl_005B;
double Gd_005D;
int Gi_005E;
bool Gb_005E;
long Gl_005E;
double Gd_005E;
double Gd_005F;
int Gi_0060;
long Gl_0060;
bool Gb_0062;
int Gi_0062;
long Gl_0062;
bool Gb_0063;
long Gl_0063;
double Gd_0063;
int Gi_0064;
bool Gb_0064;
long Gl_0064;
double Gd_0064;
double Gd_0065;
int Gi_0066;
long Gl_0066;
double Gd_0068;
int Gi_0069;
bool Gb_0069;
long Gl_0069;
double Gd_0069;
double Gd_006A;
int Gi_006B;
long Gl_006B;
bool Gb_006D;
int Gi_006D;
long Gl_006D;
bool Gb_006E;
long Gl_006E;
double Gd_006E;
int Gi_006F;
bool Gb_006F;
long Gl_006F;
double Gd_006F;
double Gd_0070;
int Gi_0071;
long Gl_0071;
double Gd_0073;
int Gi_0074;
bool Gb_0074;
long Gl_0074;
double Gd_0074;
double Gd_0075;
int Gi_0076;
long Gl_0076;
bool Gb_0078;
int Gi_0078;
long Gl_0078;
bool Gb_0079;
long Gl_0079;
double Gd_0079;
int Gi_007A;
bool Gb_007A;
long Gl_007A;
double Gd_007A;
double Gd_007B;
int Gi_007C;
long Gl_007C;
double Gd_007E;
int Gi_007F;
bool Gb_007F;
long Gl_007F;
double Gd_007F;
double Gd_0080;
int Gi_0081;
long Gl_0081;
bool Gb_0083;
int Gi_0083;
long Gl_0083;
bool Gb_0084;
long Gl_0084;
double Gd_0084;
int Gi_0085;
bool Gb_0085;
long Gl_0085;
double Gd_0085;
double Gd_0086;
int Gi_0087;
long Gl_0087;
double Gd_0089;
int Gi_008A;
bool Gb_008A;
long Gl_008A;
double Gd_008A;
double Gd_008B;
int Gi_008C;
long Gl_008C;
bool Gb_008E;
int Gi_008E;
long Gl_008E;
bool Gb_008F;
long Gl_008F;
double Gd_008F;
int Gi_0090;
bool Gb_0090;
long Gl_0090;
double Gd_0090;
double Gd_0091;
int Gi_0092;
long Gl_0092;
double Gd_0094;
int Gi_0095;
bool Gb_0095;
long Gl_0095;
double Gd_0095;
double Gd_0096;
int Gi_0097;
long Gl_0097;
bool Gb_0099;
int Gi_0099;
long Gl_0099;
bool Gb_009A;
long Gl_009A;
bool Gb_0097;
double Gd_0097;
double Gd_0098;
bool Gb_0092;
double Gd_0092;
double Gd_0093;
int Gi_0094;
long Gl_0094;
bool Gb_008C;
double Gd_008C;
double Gd_008D;
bool Gb_0087;
double Gd_0087;
double Gd_0088;
int Gi_0089;
long Gl_0089;
bool Gb_0081;
double Gd_0081;
double Gd_0082;
bool Gb_007C;
double Gd_007C;
double Gd_007D;
int Gi_007E;
long Gl_007E;
bool Gb_0076;
double Gd_0076;
double Gd_0077;
bool Gb_0071;
double Gd_0071;
double Gd_0072;
int Gi_0073;
long Gl_0073;
bool Gb_006B;
double Gd_006B;
double Gd_006C;
bool Gb_0066;
double Gd_0066;
double Gd_0067;
int Gi_0068;
long Gl_0068;
bool Gb_0060;
double Gd_0060;
double Gd_0061;
bool Gb_005B;
double Gd_005B;
double Gd_005C;
int Gi_005D;
long Gl_005D;
bool Gb_0055;
double Gd_0055;
double Gd_0056;
bool Gb_0050;
double Gd_0050;
double Gd_0051;
int Gi_0052;
long Gl_0052;
bool Gb_004A;
double Gd_004A;
double Gd_004B;
bool Gb_0045;
double Gd_0045;
double Gd_0046;
int Gi_0047;
long Gl_0047;
bool Gb_003F;
double Gd_003F;
double Gd_0040;
bool Gb_003A;
double Gd_003A;
double Gd_003B;
int Gi_003C;
long Gl_003C;
bool Gb_0034;
double Gd_0034;
double Gd_0035;
bool Gb_002F;
double Gd_002F;
double Gd_0030;
int Gi_0031;
long Gl_0031;
bool Gb_0029;
double Gd_0029;
double Gd_002A;
bool Gb_0024;
double Gd_0024;
double Gd_0025;
int Gi_0026;
long Gl_0026;
bool Gb_001E;
double Gd_001E;
double Gd_001F;
bool Gb_0019;
double Gd_0019;
double Gd_001A;
int Gi_001B;
long Gl_001B;
bool Gb_0013;
double Gd_0013;
double Gd_0014;
bool Gb_000E;
double Gd_000E;
double Gd_000F;
int Gi_0010;
long Gl_0010;
double Gd_0008;
double Gd_0009;
bool Gb_0003;
double Gd_0004;
long Gl_0007;
int Gi_000B;
long Gl_000D;
int Gi_000D;
double Id_19B0[1000];
double returned_double;
string Global_ReturnedString;
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
   string tmp_str0030;
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   string Ls_FD90;
   string Ls_FD80;
   string Ls_FD70;
   string Ls_FD60;
   string Ls_FD50;
   string Ls_FD40;
   string Ls_FD30;
   string Ls_FD20;
   string Ls_FD10;
   string Ls_FD00;
   int Li_FCFC;
   int Li_FCF8;
   int Li_FCF4;
   double Ld_FCE8;
   int Li_FFFC;
   
   Is_0000 = "https://www.fxphantom.com/moneytree/check.php";
   Ib_000C = false;
   Ii_0010 = 0;
   Ii_0014 = 0;
   Ii_0018 = 0;
   Ii_001C = 1;
   Ii_0020 = 3;
   Ii_0024 = 80;
   Ii_0044 = 68;
   Ii_0048 = 32;
   Ii_004C = 10;
   Ii_0050 = 25;
   Ii_0054 = 100;
   Ii_0058 = 0;
   Ii_005C = 5;
   Ib_0060 = false;
   Ii_0064 = -100;
   Ii_0068 = 0;
   Ii_006C = 0;
   Ii_0070 = 0;
   Ii_0074 = 0;
   Ii_0078 = 0;
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
   Ib_00B0 = false;
   Id_00B8 = 0;
   Id_00C0 = 0;
   Id_00C8 = 0;
   Id_00D0 = 0;
   Id_00D8 = 0;
   Id_00E0 = 0;
   Ib_00E8 = false;
   Id_00F0 = 0;
   Ii_00F8 = 0;
   Ii_00FC = 0;
   Ii_0100 = 0;
   Ii_0104 = 0;
   Ii_0108 = 0;
   Ii_010C = 0;
   Id_0110 = 0;
   Ii_0118 = 0;
   Ii_011C = 0;
   Ib_0120 = false;
   Ii_0124 = 0;
   Ii_0128 = 0;
   Ii_012C = 0;
   Id_0130 = 0;
   Id_0138 = 0;
   Ii_0140 = 0;
   Id_0148 = 0;
   Ii_0150 = 0;
   Id_0158 = 0;
   Id_0160 = 0;
   Ii_0168 = 0;
   Id_0170 = 0;
   Ii_0178 = 0;
   Id_0180 = 0;
   Ii_0188 = 0;
   Id_0190 = 0;
   Id_0198 = 0;
   Ii_01A0 = 0;
   Id_01A8 = 0;
   Id_01B0 = 0;
   Ii_01B8 = 0;
   Id_01C0 = 0;
   Ii_01C8 = 0;
   Id_01D0 = 0;
   Ii_01D8 = 0;
   Id_01E0 = 0;
   Id_01E8 = 0;
   Ii_01F0 = 0;
   Id_01F8 = 0;
   Id_0200 = 0;
   Ii_0208 = 0;
   Id_0210 = 0;
   Ii_0218 = 0;
   Id_0220 = 0;
   Ii_0228 = 0;
   Id_0230 = 0;
   Id_0238 = 0;
   Ii_0240 = 0;
   Id_0248 = 0;
   Id_0250 = 0;
   Ii_0258 = 0;
   Id_0260 = 0;
   Ii_0268 = 0;
   Id_0270 = 0;
   Ii_0278 = 0;
   Id_0280 = 0;
   Id_0288 = 0;
   Ii_0290 = 0;
   Id_0298 = 0;
   Id_02A0 = 0;
   Ii_02A8 = 0;
   Id_02B0 = 0;
   Ii_02B8 = 0;
   Id_02C0 = 0;
   Ii_02C8 = 0;
   Id_02D0 = 0;
   Id_02D8 = 0;
   Ii_02E0 = 0;
   Id_02E8 = 0;
   Id_02F0 = 0;
   Ii_02F8 = 0;
   Id_0300 = 0;
   Ii_0308 = 0;
   Id_0310 = 0;
   Ii_0318 = 0;
   Id_0320 = 0;
   Id_0328 = 0;
   Ii_0330 = 0;
   Id_0338 = 0;
   Id_0340 = 0;
   Ii_0348 = 0;
   Id_0350 = 0;
   Ib_0358 = false;
   Ii_035C = 0;
   Ii_0360 = 0;
   Ii_0364 = 0;
   Id_0368 = 0;
   Id_0370 = 0;
   Ii_0378 = 0;
   Id_0380 = 0;
   Ii_0388 = 0;
   Id_0390 = 0;
   Id_0398 = 0;
   Ii_03A0 = 0;
   Id_03A8 = 0;
   Ii_03B0 = 0;
   Id_03B8 = 0;
   Ii_03C0 = 0;
   Id_03C8 = 0;
   Id_03D0 = 0;
   Ii_03D8 = 0;
   Id_03E0 = 0;
   Id_03E8 = 0;
   Ii_03F0 = 0;
   Id_03F8 = 0;
   Ii_0400 = 0;
   Id_0408 = 0;
   Ii_0410 = 0;
   Id_0418 = 0;
   Id_0420 = 0;
   Ii_0428 = 0;
   Id_0430 = 0;
   Id_0438 = 0;
   Ii_0440 = 0;
   Id_0448 = 0;
   Ii_0450 = 0;
   Id_0458 = 0;
   Ii_0460 = 0;
   Id_0468 = 0;
   Id_0470 = 0;
   Ii_0478 = 0;
   Id_0480 = 0;
   Id_0488 = 0;
   Ii_0490 = 0;
   Id_0498 = 0;
   Ii_04A0 = 0;
   Id_04A8 = 0;
   Ii_04B0 = 0;
   Id_04B8 = 0;
   Id_04C0 = 0;
   Ii_04C8 = 0;
   Id_04D0 = 0;
   Id_04D8 = 0;
   Ii_04E0 = 0;
   Id_04E8 = 0;
   Ii_04F0 = 0;
   Id_04F8 = 0;
   Ii_0500 = 0;
   Id_0508 = 0;
   Id_0510 = 0;
   Ii_0518 = 0;
   Id_0520 = 0;
   Id_0528 = 0;
   Ii_0530 = 0;
   Id_0538 = 0;
   Ii_0540 = 0;
   Id_0548 = 0;
   Ii_0550 = 0;
   Id_0558 = 0;
   Id_0560 = 0;
   Ii_0568 = 0;
   Id_0570 = 0;
   Id_0578 = 0;
   Ii_0580 = 0;
   Id_0588 = 0;
   Id_0590 = 0;
   Ii_0598 = 0;
   Id_05A0 = 0;
   Ii_05A8 = 0;
   Ii_05AC = 0;
   Id_05B0 = 0;
   Ii_05B8 = 0;
   Id_05C0 = 0;
   Ii_05C8 = 0;
   Id_05D0 = 0;
   Ii_05D8 = 0;
   Ii_05DC = 0;
   Id_05E0 = 0;
   Ii_05E8 = 0;
   Id_05F0 = 0;
   Ii_05F8 = 0;
   Id_0600 = 0;
   Ii_0608 = 0;
   Id_0610 = 0;
   Ii_0618 = 0;
   Id_0620 = 0;
   Ii_0628 = 0;
   Ii_062C = 0;
   Id_0630 = 0;
   Ii_0638 = 0;
   Ii_063C = 0;
   Id_0640 = 0;
   Ii_0648 = 0;
   Id_0650 = 0;
   Ii_0658 = 0;
   Id_0660 = 0;
   Ii_0668 = 0;
   Ii_066C = 0;
   Id_0670 = 0;
   Ii_0678 = 0;
   Id_0680 = 0;
   Ii_0688 = 0;
   Id_0690 = 0;
   Ii_0698 = 0;
   Ii_069C = 0;
   Id_06A0 = 0;
   Ii_06A8 = 0;
   Id_06B0 = 0;
   Ii_06B8 = 0;
   Id_06C0 = 0;
   Ii_06C8 = 0;
   Id_06D0 = 0;
   Ii_06D8 = 0;
   Id_06E0 = 0;
   Ii_06E8 = 0;
   Ii_06EC = 0;
   Id_06F0 = 0;
   Ii_06F8 = 0;
   Ii_06FC = 0;
   Id_0700 = 0;
   Ii_0708 = 0;
   Ib_070C = false;
   Ii_0710 = 0;
   Il_0718 = 0;
   Il_0720 = 0;
   Ii_0728 = 0;
   Il_0730 = 0;
   Ii_0738 = 0;
   Il_0740 = 0;
   Ib_0754 = false;
   Ii_0758 = 0;
   Ii_075C = 0;
   Ib_0760 = false;
   Id_0768 = 0;
   Ii_0770 = 0;
   Ib_0774 = false;
   Id_0778 = 0;
   Il_0780 = 0;
   Il_0788 = 0;
   Ii_0790 = 0;
   Il_0798 = 0;
   Id_07A0 = 0;
   Id_07A8 = 0;
   Id_07B0 = 0;
   Id_07B8 = 0;
   Id_07C0 = 0;
   Ii_07C8 = 0;
   Id_07D0 = 0;
   Id_07D8 = 0;
   Id_07E0 = 0;
   Id_07E8 = 0;
   Ii_07F0 = 0;
   Ii_07F4 = 0;
   Ib_07F8 = false;
   Id_0800 = 0;
   Il_0808 = 0;
   Ii_0810 = 0;
   Il_0818 = 0;
   Ii_0820 = 0;
   Id_0828 = 0;
   Id_0830 = 0;
   Ii_0838 = 0;
   Ib_083C = false;
   Id_0840 = 0;
   Ii_0848 = 0;
   Id_0850 = 0;
   Ib_0858 = false;
   Ii_085C = 0;
   Ii_0860 = 0;
   Id_0868 = 0;
   Ii_0870 = 0;
   Id_0878 = 0;
   Ii_0880 = 0;
   Id_0888 = 0;
   Ib_0890 = false;
   Ii_0894 = 0;
   Id_0898 = 0;
   Ii_08A0 = 0;
   Id_08A8 = 0;
   Ii_08B0 = 0;
   Id_08B8 = 0;
   Ib_08C0 = false;
   Ii_08C4 = 0;
   Il_08C8 = 0;
   Ii_08D0 = 0;
   Il_08D8 = 0;
   Id_08E0 = 0;
   Ii_08E8 = 0;
   Ii_08EC = 0;
   Ib_08F0 = false;
   Ii_08F4 = 0;
   Ii_08F8 = 0;
   Ii_091C = 0;
   Ii_0920 = 0;
   Id_0928 = 0;
   Ii_0930 = 0;
   Ii_0934 = 0;
   Id_0938 = 0;
   Ii_0940 = 0;
   Ii_0944 = 0;
   Ii_0948 = 0;
   Id_0950 = 0;
   Ii_0958 = 0;
   Il_0960 = 0;
   Ii_0968 = 0;
   Ii_096C = 0;
   Id_0970 = 0;
   Ii_0978 = 0;
   Ii_097C = 0;
   Ii_0980 = 0;
   Ii_0984 = 0;
   Id_0988 = 0;
   Ii_0990 = 0;
   Ii_0994 = 0;
   Ii_0998 = 0;
   Il_09A0 = 0;
   Ii_09A8 = 0;
   Ii_09AC = 0;
   Ii_09B0 = 0;
   Ii_09B4 = 0;
   Ii_09B8 = 0;
   Ii_09BC = 0;
   Ii_09C0 = 0;
   Ii_09C4 = 0;
   Il_09C8 = 0;
   Ii_09D0 = 0;
   Ii_09D4 = 0;
   Ii_09D8 = 0;
   Id_09E0 = 0;
   Ii_09E8 = 0;
   Ii_09EC = 0;
   Ii_09F0 = 0;
   Ii_09F4 = 0;
   Ii_09F8 = 0;
   Ii_09FC = 0;
   Id_0A00 = 0;
   Ii_0A08 = 0;
   Il_0A10 = 0;
   Ii_0A18 = 0;
   Ii_0A1C = 0;
   Ii_0A20 = 0;
   Ii_0A24 = 0;
   Ii_0A28 = 0;
   Ii_0A2C = 0;
   Ii_0A30 = 0;
   Id_0A38 = 0;
   Ii_0A40 = 0;
   Il_0A48 = 0;
   Ii_0A50 = 0;
   Ii_0A54 = 0;
   Ii_0A58 = 0;
   Id_0A60 = 0;
   Ii_0A68 = 0;
   Ii_0A6C = 0;
   Ii_0A70 = 0;
   Ii_0A74 = 0;
   Ii_0A78 = 0;
   Ii_0A7C = 0;
   Il_0A80 = 0;
   Ii_0A88 = 0;
   Ii_0A8C = 0;
   Ii_0A90 = 0;
   Ii_0A94 = 0;
   Ii_0A98 = 0;
   Id_0AA0 = 0;
   Ii_0AA8 = 0;
   Ii_0AAC = 0;
   Ii_0AB0 = 0;
   Ii_0AB4 = 0;
   Il_0AB8 = 0;
   Ii_0AC0 = 0;
   Ii_0AC4 = 0;
   Ii_0AC8 = 0;
   Ii_0ACC = 0;
   Ii_0AD0 = 0;
   Ii_0AD4 = 0;
   Ii_0AD8 = 0;
   Ii_0ADC = 0;
   Id_0AE0 = 0;
   Ii_0AE8 = 0;
   Il_0AF0 = 0;
   Ii_0AF8 = 0;
   Ii_0AFC = 0;
   Ii_0B00 = 0;
   Ii_0B04 = 0;
   Id_0B08 = 0;
   Ii_0B10 = 0;
   Ii_0B14 = 0;
   Il_0B18 = 0;
   Ii_0B20 = 0;
   Ii_0B24 = 0;
   Id_0B28 = 0;
   Ii_0B30 = 0;
   Ii_0B34 = 0;
   Id_0B38 = 0;
   Ii_0B40 = 0;
   Ii_0B44 = 0;
   Il_0B48 = 0;
   Ii_0B50 = 0;
   Ii_0B54 = 0;
   Ii_0B58 = 0;
   Ii_0B5C = 0;
   Ii_0B60 = 0;
   Id_0B68 = 0;
   Il_0B70 = 0;
   Id_0B78 = 0;
   Il_0B80 = 0;
   Ii_0B88 = 0;
   Ii_0B8C = 0;
   Ii_0B90 = 0;
   Ii_0B94 = 0;
   Ii_0B98 = 0;
   Id_0BA0 = 0;
   Ii_0BA8 = 0;
   Ii_0BAC = 0;
   Ii_0BB0 = 0;
   Ii_0BB4 = 0;
   Ii_0BB8 = 0;
   Id_0BC0 = 0;
   Ii_0BC8 = 0;
   Il_0BD0 = 0;
   Ii_0BD8 = 0;
   Ii_0BDC = 0;
   Ii_0BE0 = 0;
   Ii_0BE4 = 0;
   Id_0BE8 = 0;
   Ii_0BF0 = 0;
   Ii_0BF4 = 0;
   Ii_0BF8 = 0;
   Ii_0BFC = 0;
   Ii_0C00 = 0;
   Id_0C08 = 0;
   Ii_0C10 = 0;
   Ii_0C14 = 0;
   Ii_0C18 = 0;
   Ii_0C1C = 0;
   Ii_0C20 = 0;
   Id_0C28 = 0;
   Ii_0C30 = 0;
   Il_0C38 = 0;
   Ii_0C40 = 0;
   Ii_0C44 = 0;
   Ii_0C48 = 0;
   Id_0C50 = 0;
   Ii_0C58 = 0;
   Ib_0C5C = false;
   Il_0C60 = 0;
   Id_0C68 = 0;
   Id_0C70 = 0;
   Ii_0C78 = 0;
   Il_0C80 = 0;
   Id_0C88 = 0;
   Ii_0C90 = 0;
   Ib_0C94 = false;
   Il_0C98 = 0;
   Id_0CA0 = 0;
   Id_0CA8 = 0;
   Ii_0CB0 = 0;
   Il_0CB8 = 0;
   Ib_0CC0 = false;
   Ii_0CC4 = 0;
   Il_0CC8 = 0;
   Ii_0CD0 = 0;
   Ib_0CD4 = false;
   Il_0CD8 = 0;
   Id_0CE0 = 0;
   Ii_0CE8 = 0;
   Ib_0CEC = false;
   Il_0CF0 = 0;
   Id_0CF8 = 0;
   Id_0D00 = 0;
   Ii_0D08 = 0;
   Il_0D10 = 0;
   Id_0D18 = 0;
   Ii_0D20 = 0;
   Ib_0D24 = false;
   Il_0D28 = 0;
   Id_0D30 = 0;
   Id_0D38 = 0;
   Ii_0D40 = 0;
   Il_0D48 = 0;
   Ib_0D50 = false;
   Ii_0D54 = 0;
   Il_0D58 = 0;
   Ii_0D60 = 0;
   Ib_0D64 = false;
   Il_0D68 = 0;
   Id_0D70 = 0;
   Ii_0D78 = 0;
   Ib_0D7C = false;
   Il_0D80 = 0;
   Id_0D88 = 0;
   Id_0D90 = 0;
   Ii_0D98 = 0;
   Il_0DA0 = 0;
   Id_0DA8 = 0;
   Ii_0DB0 = 0;
   Ib_0DB4 = false;
   Il_0DB8 = 0;
   Id_0DC0 = 0;
   Id_0DC8 = 0;
   Ii_0DD0 = 0;
   Il_0DD8 = 0;
   Ib_0DE0 = false;
   Ii_0DE4 = 0;
   Il_0DE8 = 0;
   Ii_0DF0 = 0;
   Ib_0DF4 = false;
   Il_0DF8 = 0;
   Id_0E00 = 0;
   Ii_0E08 = 0;
   Ib_0E0C = false;
   Il_0E10 = 0;
   Id_0E18 = 0;
   Id_0E20 = 0;
   Ii_0E28 = 0;
   Il_0E30 = 0;
   Id_0E38 = 0;
   Ii_0E40 = 0;
   Ib_0E44 = false;
   Il_0E48 = 0;
   Id_0E50 = 0;
   Id_0E58 = 0;
   Ii_0E60 = 0;
   Il_0E68 = 0;
   Ib_0E70 = false;
   Ii_0E74 = 0;
   Il_0E78 = 0;
   Ii_0E80 = 0;
   Ib_0E84 = false;
   Il_0E88 = 0;
   Id_0E90 = 0;
   Ii_0E98 = 0;
   Ib_0E9C = false;
   Il_0EA0 = 0;
   Id_0EA8 = 0;
   Id_0EB0 = 0;
   Ii_0EB8 = 0;
   Il_0EC0 = 0;
   Id_0EC8 = 0;
   Ii_0ED0 = 0;
   Ib_0ED4 = false;
   Il_0ED8 = 0;
   Id_0EE0 = 0;
   Id_0EE8 = 0;
   Ii_0EF0 = 0;
   Il_0EF8 = 0;
   Ib_0F00 = false;
   Ii_0F04 = 0;
   Il_0F08 = 0;
   Ii_0F10 = 0;
   Ib_0F14 = false;
   Il_0F18 = 0;
   Id_0F20 = 0;
   Ii_0F28 = 0;
   Ib_0F2C = false;
   Il_0F30 = 0;
   Id_0F38 = 0;
   Id_0F40 = 0;
   Ii_0F48 = 0;
   Il_0F50 = 0;
   Id_0F58 = 0;
   Ii_0F60 = 0;
   Ib_0F64 = false;
   Il_0F68 = 0;
   Id_0F70 = 0;
   Id_0F78 = 0;
   Ii_0F80 = 0;
   Il_0F88 = 0;
   Ib_0F90 = false;
   Ii_0F94 = 0;
   Il_0F98 = 0;
   Ii_0FA0 = 0;
   Ib_0FA4 = false;
   Il_0FA8 = 0;
   Id_0FB0 = 0;
   Ii_0FB8 = 0;
   Ib_0FBC = false;
   Il_0FC0 = 0;
   Id_0FC8 = 0;
   Id_0FD0 = 0;
   Ii_0FD8 = 0;
   Il_0FE0 = 0;
   Id_0FE8 = 0;
   Ii_0FF0 = 0;
   Ib_0FF4 = false;
   Il_0FF8 = 0;
   Id_1000 = 0;
   Id_1008 = 0;
   Ii_1010 = 0;
   Il_1018 = 0;
   Ib_1020 = false;
   Ii_1024 = 0;
   Il_1028 = 0;
   Ii_1030 = 0;
   Ib_1034 = false;
   Il_1038 = 0;
   Id_1040 = 0;
   Ii_1048 = 0;
   Ib_104C = false;
   Il_1050 = 0;
   Id_1058 = 0;
   Id_1060 = 0;
   Ii_1068 = 0;
   Il_1070 = 0;
   Id_1078 = 0;
   Ii_1080 = 0;
   Ib_1084 = false;
   Il_1088 = 0;
   Id_1090 = 0;
   Id_1098 = 0;
   Ii_10A0 = 0;
   Il_10A8 = 0;
   Ib_10B0 = false;
   Ii_10B4 = 0;
   Il_10B8 = 0;
   Ii_10C0 = 0;
   Ib_10C4 = false;
   Il_10C8 = 0;
   Id_10D0 = 0;
   Ii_10D8 = 0;
   Ib_10DC = false;
   Il_10E0 = 0;
   Id_10E8 = 0;
   Id_10F0 = 0;
   Ii_10F8 = 0;
   Il_1100 = 0;
   Id_1108 = 0;
   Ii_1110 = 0;
   Ib_1114 = false;
   Il_1118 = 0;
   Id_1120 = 0;
   Id_1128 = 0;
   Ii_1130 = 0;
   Il_1138 = 0;
   Ib_1140 = false;
   Ii_1144 = 0;
   Il_1148 = 0;
   Ii_1150 = 0;
   Ib_1154 = false;
   Il_1158 = 0;
   Id_1160 = 0;
   Ii_1168 = 0;
   Ib_116C = false;
   Il_1170 = 0;
   Id_1178 = 0;
   Id_1180 = 0;
   Ii_1188 = 0;
   Il_1190 = 0;
   Id_1198 = 0;
   Ii_11A0 = 0;
   Ib_11A4 = false;
   Il_11A8 = 0;
   Id_11B0 = 0;
   Id_11B8 = 0;
   Ii_11C0 = 0;
   Il_11C8 = 0;
   Ib_11D0 = false;
   Ii_11D4 = 0;
   Il_11D8 = 0;
   Ii_11E0 = 0;
   Ib_11E4 = false;
   Il_11E8 = 0;
   Id_11F0 = 0;
   Ii_11F8 = 0;
   Ib_11FC = false;
   Il_1200 = 0;
   Id_1208 = 0;
   Id_1210 = 0;
   Ii_1218 = 0;
   Il_1220 = 0;
   Id_1228 = 0;
   Ii_1230 = 0;
   Ib_1234 = false;
   Il_1238 = 0;
   Id_1240 = 0;
   Id_1248 = 0;
   Ii_1250 = 0;
   Il_1258 = 0;
   Ib_1260 = false;
   Ii_1264 = 0;
   Il_1268 = 0;
   Ii_1270 = 0;
   Ib_1274 = false;
   Il_1278 = 0;
   Id_1280 = 0;
   Ii_1288 = 0;
   Ib_128C = false;
   Il_1290 = 0;
   Id_1298 = 0;
   Id_12A0 = 0;
   Ii_12A8 = 0;
   Il_12B0 = 0;
   Id_12B8 = 0;
   Ii_12C0 = 0;
   Ib_12C4 = false;
   Il_12C8 = 0;
   Id_12D0 = 0;
   Id_12D8 = 0;
   Ii_12E0 = 0;
   Il_12E8 = 0;
   Ib_12F0 = false;
   Ii_12F4 = 0;
   Il_12F8 = 0;
   Ii_1300 = 0;
   Ib_1304 = false;
   Il_1308 = 0;
   Id_1310 = 0;
   Ii_1318 = 0;
   Ib_131C = false;
   Il_1320 = 0;
   Id_1328 = 0;
   Id_1330 = 0;
   Ii_1338 = 0;
   Il_1340 = 0;
   Id_1348 = 0;
   Ii_1350 = 0;
   Ib_1354 = false;
   Il_1358 = 0;
   Id_1360 = 0;
   Id_1368 = 0;
   Ii_1370 = 0;
   Il_1378 = 0;
   Ib_1380 = false;
   Ii_1384 = 0;
   Il_1388 = 0;
   Ii_1390 = 0;
   Ib_1394 = false;
   Il_1398 = 0;
   Id_13A0 = 0;
   Ii_13A8 = 0;
   Ib_13AC = false;
   Il_13B0 = 0;
   Id_13B8 = 0;
   Id_13C0 = 0;
   Ii_13C8 = 0;
   Il_13D0 = 0;
   Id_13D8 = 0;
   Ii_13E0 = 0;
   Ib_13E4 = false;
   Il_13E8 = 0;
   Id_13F0 = 0;
   Id_13F8 = 0;
   Ii_1400 = 0;
   Il_1408 = 0;
   Ib_1410 = false;
   Ii_1414 = 0;
   Il_1418 = 0;
   Ii_1420 = 0;
   Ib_1424 = false;
   Il_1428 = 0;
   Ib_1430 = false;
   Id_1438 = 0;
   Id_1440 = 0;
   Ib_1448 = false;
   Id_1450 = 0;
   Id_1458 = 0;
   Ii_1460 = 0;
   Il_1468 = 0;
   Ib_1470 = false;
   Id_1478 = 0;
   Id_1480 = 0;
   Ib_1488 = false;
   Id_1490 = 0;
   Id_1498 = 0;
   Ii_14A0 = 0;
   Il_14A8 = 0;
   Ib_14B0 = false;
   Id_14B8 = 0;
   Id_14C0 = 0;
   Ib_14C8 = false;
   Id_14D0 = 0;
   Id_14D8 = 0;
   Ii_14E0 = 0;
   Il_14E8 = 0;
   Ib_14F0 = false;
   Id_14F8 = 0;
   Id_1500 = 0;
   Ib_1508 = false;
   Id_1510 = 0;
   Id_1518 = 0;
   Ii_1520 = 0;
   Il_1528 = 0;
   Ib_1530 = false;
   Id_1538 = 0;
   Id_1540 = 0;
   Ib_1548 = false;
   Id_1550 = 0;
   Id_1558 = 0;
   Ii_1560 = 0;
   Il_1568 = 0;
   Ib_1570 = false;
   Id_1578 = 0;
   Id_1580 = 0;
   Ib_1588 = false;
   Id_1590 = 0;
   Id_1598 = 0;
   Ii_15A0 = 0;
   Il_15A8 = 0;
   Ib_15B0 = false;
   Id_15B8 = 0;
   Id_15C0 = 0;
   Ib_15C8 = false;
   Id_15D0 = 0;
   Id_15D8 = 0;
   Ii_15E0 = 0;
   Il_15E8 = 0;
   Ib_15F0 = false;
   Id_15F8 = 0;
   Id_1600 = 0;
   Ib_1608 = false;
   Id_1610 = 0;
   Id_1618 = 0;
   Ii_1620 = 0;
   Il_1628 = 0;
   Ib_1630 = false;
   Id_1638 = 0;
   Id_1640 = 0;
   Ib_1648 = false;
   Id_1650 = 0;
   Id_1658 = 0;
   Ii_1660 = 0;
   Il_1668 = 0;
   Ib_1670 = false;
   Id_1678 = 0;
   Id_1680 = 0;
   Ib_1688 = false;
   Id_1690 = 0;
   Id_1698 = 0;
   Ii_16A0 = 0;
   Il_16A8 = 0;
   Ib_16B0 = false;
   Id_16B8 = 0;
   Id_16C0 = 0;
   Ib_16C8 = false;
   Id_16D0 = 0;
   Id_16D8 = 0;
   Ii_16E0 = 0;
   Il_16E8 = 0;
   Ib_16F0 = false;
   Id_16F8 = 0;
   Id_1700 = 0;
   Ib_1708 = false;
   Id_1710 = 0;
   Id_1718 = 0;
   Ii_1720 = 0;
   Il_1728 = 0;
   Ib_1730 = false;
   Id_1738 = 0;
   Id_1740 = 0;
   Ib_1748 = false;
   Id_1750 = 0;
   Id_1758 = 0;
   Ii_1760 = 0;
   Il_1768 = 0;
   Ib_1770 = false;
   Id_1778 = 0;
   Id_1780 = 0;
   Ib_1788 = false;
   Id_1790 = 0;
   Id_1798 = 0;
   Ii_17A0 = 0;
   Il_17A8 = 0;
   Il_17B0 = 0;
   Id_17B8 = 0;
   Il_17C0 = 0;
   Il_17C8 = 0;
   Il_17D0 = 0;
   Il_17D8 = 0;
   Ii_17E0 = 0;
   Ii_17E4 = 0;
   Id_17E8 = 0;
   Il_17F0 = 0;
   Ii_17F8 = 0;
   Id_1800 = 0;
   Il_1808 = 0;
   Id_1810 = 0;
   Ii_1818 = 0;
   Il_1820 = 0;
   Il_1828 = 0;
   Il_1830 = 0;
   Ii_1838 = 0;
   Il_1840 = 0;
   Ii_1848 = 0;
   Id_1850 = 0;
   Il_1858 = 0;
   Ii_1860 = 0;
   Il_1868 = 0;
   Il_1870 = 0;
   Il_1878 = 0;
   Il_1880 = 0;
   Il_1888 = 0;
   Il_1890 = 0;
   Ii_1898 = 0;
   Il_18A0 = 0;
   Il_18A8 = 0;
   Il_18B0 = 0;
   Il_18B8 = 0;
   Il_18C0 = 0;
   Il_18C8 = 0;
   Ii_18D0 = 0;
   Il_18D8 = 0;
   Il_18E0 = 0;
   Ii_18E8 = 0;
   Il_18F0 = 0;
   Il_18F8 = 0;
   Il_1900 = 0;
   Il_1908 = 0;
   Ib_1910 = false;
   Id_1918 = 0;
   Il_1920 = 0;
   Ib_1928 = false;
   Ib_1929 = false;
   Ib_192A = false;
   Ii_192C = 0;
   Id_1930 = 0;
   Il_1938 = 0;
   Ib_1940 = false;
   Il_1948 = 0;
   Il_1950 = 0;
   Il_1958 = 0;
   Id_1960 = 0;
   Id_1968 = 0;
   Id_1970 = 0;
   Ib_1978 = false;
   Id_38F0 = 0;
   Ib_38F8 = false;
   /*
   tmp_str0000 = Is_0000 + "?receipt=";
   tmp_str0000 = tmp_str0000 + Receipt;
   tmp_str0000 = tmp_str0000 + "&email=";
   tmp_str0000 = tmp_str0000 + Email;
   Is_0038 = tmp_str0000;
   func_1014(tmp_str0000, Is_0028);
   Print(Is_0028);
   AccountNumber();
   IntegerToString(returned_i, 0, 32);
   if (returned_i != 238) { 
   Comment("License is Valid");
   } 
   else { 
   Comment("Invalid License");
   ExpertRemove();
   } 
   */
   Li_FCFC = 0;
   Li_FCF8 = 0;
   Li_FCF4 = 0;
   Ld_FCE8 = 0;
   Ii_006C = 1;
   Ii_0070 = 2;
   Ii_0074 = 3;
   Ii_0078 = 4;
   Ii_007C = 5;
   Ii_0080 = 6;
   Ii_0084 = 7;
   Ii_0088 = 8;
   Ii_008C = 9;
   Ii_0090 = 10;
   Ii_0094 = 11;
   Ii_0098 = 12;
   Ii_009C = 13;
   Ii_00A0 = 14;
   Id_08E0 = 0.2;
   Id_07A0 = 1;
   Id_07A8 = 1;
   Id_07B0 = 1;
   Id_07B8 = 1;
   Id_07C0 = 1;
   Id_07E8 = 1;
   Id_07D8 = 1.7;
   Ii_08E8 = 3;
   Ii_08EC = 0;
   Ib_08F0 = true;
   Ib_00E8 = true;
   Ib_070C = false;
   Id_00C0 = 0;
   Id_00D0 = 0;
   Ii_08F4 = 0;
   Ii_08F8 = 0;
   Is_0900 = "";
   Is_0910 = "";
   Id_00D8 = 0;
   Ib_0754 = false;
   Ii_091C = 0;
   Ii_00F8 = 1;
   Ii_0100 = 5;
   Ii_00FC = 20;
   Ii_0104 = 16777215;
   Ii_0920 = 0;
   Li_FCFC = 0;
   Li_FCF8 = 0;
   Li_FCF4 = 0;
   Ld_FCE8 = 0;
   Li_FCF8 = 20985564;
   if (_Symbol == "AUDCADm" || _Symbol == "AUDCAD") { 
   
   Ii_006C = 20;
   Ii_0070 = 21;
   Ii_0074 = 22;
   Ii_0078 = 23;
   Ii_007C = 24;
   Ii_0080 = 25;
   Ii_0084 = 26;
   Ii_0088 = 27;
   Ii_008C = 28;
   Ii_0090 = 29;
   Ii_0094 = 30;
   Ii_0098 = 31;
   Ii_009C = 32;
   Ii_00A0 = 33;
   } 
   if (_Symbol == "AUDJPYm" || _Symbol == "AUDJPY") { 
   
   Ii_006C = 40;
   Ii_0070 = 41;
   Ii_0074 = 42;
   Ii_0078 = 43;
   Ii_007C = 44;
   Ii_0080 = 45;
   Ii_0084 = 46;
   Ii_0088 = 47;
   Ii_008C = 48;
   Ii_0090 = 49;
   Ii_0094 = 50;
   Ii_0098 = 51;
   Ii_009C = 52;
   Ii_00A0 = 53;
   } 
   if (_Symbol == "AUDNZDm" || _Symbol == "AUDNZD") { 
   
   Ii_006C = 60;
   Ii_0070 = 61;
   Ii_0074 = 62;
   Ii_0078 = 63;
   Ii_007C = 64;
   Ii_0080 = 65;
   Ii_0084 = 66;
   Ii_0088 = 67;
   Ii_008C = 68;
   Ii_0090 = 69;
   Ii_0094 = 70;
   Ii_0098 = 71;
   Ii_009C = 72;
   Ii_00A0 = 73;
   } 
   if (_Symbol == "AUDUSDm" || _Symbol == "AUDUSD") { 
   
   Ii_006C = 80;
   Ii_0070 = 81;
   Ii_0074 = 82;
   Ii_0078 = 83;
   Ii_007C = 84;
   Ii_0080 = 85;
   Ii_0084 = 86;
   Ii_0088 = 87;
   Ii_008C = 88;
   Ii_0090 = 89;
   Ii_0094 = 90;
   Ii_0098 = 91;
   Ii_009C = 92;
   Ii_00A0 = 93;
   } 
   if (_Symbol == "CHFJPYm" || _Symbol == "CHFJPY") { 
   
   Ii_006C = 100;
   Ii_0070 = 101;
   Ii_0074 = 102;
   Ii_0078 = 103;
   Ii_007C = 104;
   Ii_0080 = 105;
   Ii_0084 = 106;
   Ii_0088 = 107;
   Ii_008C = 108;
   Ii_0090 = 109;
   Ii_0094 = 110;
   Ii_0098 = 111;
   Ii_009C = 112;
   Ii_00A0 = 113;
   } 
   if (_Symbol == "EURAUDm" || _Symbol == "EURAUD") { 
   
   Ii_006C = 120;
   Ii_0070 = 121;
   Ii_0074 = 122;
   Ii_0078 = 123;
   Ii_007C = 124;
   Ii_0080 = 125;
   Ii_0084 = 126;
   Ii_0088 = 127;
   Ii_008C = 128;
   Ii_0090 = 129;
   Ii_0094 = 130;
   Ii_0098 = 131;
   Ii_009C = 132;
   Ii_00A0 = 133;
   } 
   if (_Symbol == "EURCADm" || _Symbol == "EURCAD") { 
   
   Ii_006C = 140;
   Ii_0070 = 141;
   Ii_0074 = 142;
   Ii_0078 = 143;
   Ii_007C = 144;
   Ii_0080 = 145;
   Ii_0084 = 146;
   Ii_0088 = 147;
   Ii_008C = 148;
   Ii_0090 = 149;
   Ii_0094 = 150;
   Ii_0098 = 151;
   Ii_009C = 152;
   Ii_00A0 = 153;
   } 
   if (_Symbol == "EURCHFm" || _Symbol == "EURCHF") { 
   
   Ii_006C = 160;
   Ii_0070 = 161;
   Ii_0074 = 162;
   Ii_0078 = 163;
   Ii_007C = 164;
   Ii_0080 = 165;
   Ii_0084 = 166;
   Ii_0088 = 167;
   Ii_008C = 168;
   Ii_0090 = 169;
   Ii_0094 = 170;
   Ii_0098 = 171;
   Ii_009C = 172;
   Ii_00A0 = 173;
   } 
   if (_Symbol == "EURGBPm" || _Symbol == "EURGBP") { 
   
   Ii_006C = 180;
   Ii_0070 = 181;
   Ii_0074 = 182;
   Ii_0078 = 183;
   Ii_007C = 184;
   Ii_0080 = 185;
   Ii_0084 = 186;
   Ii_0088 = 187;
   Ii_008C = 188;
   Ii_0090 = 189;
   Ii_0094 = 190;
   Ii_0098 = 191;
   Ii_009C = 192;
   Ii_00A0 = 193;
   } 
   if (_Symbol == "EURJPYm" || _Symbol == "EURJPY") { 
   
   Ii_006C = 200;
   Ii_0070 = 201;
   Ii_0074 = 202;
   Ii_0078 = 203;
   Ii_007C = 204;
   Ii_0080 = 205;
   Ii_0084 = 206;
   Ii_0088 = 207;
   Ii_008C = 208;
   Ii_0090 = 209;
   Ii_0094 = 210;
   Ii_0098 = 211;
   Ii_009C = 212;
   Ii_00A0 = 213;
   } 
   if (_Symbol == "EURUSDm" || _Symbol == "EURUSD") { 
   
   Ii_006C = 220;
   Ii_0070 = 221;
   Ii_0074 = 222;
   Ii_0078 = 223;
   Ii_007C = 224;
   Ii_0080 = 225;
   Ii_0084 = 226;
   Ii_0088 = 227;
   Ii_008C = 228;
   Ii_0090 = 229;
   Ii_0094 = 230;
   Ii_0098 = 231;
   Ii_009C = 232;
   Ii_00A0 = 233;
   } 
   if (_Symbol == "GBPCHFm" || _Symbol == "GBPCHF") { 
   
   Ii_006C = 240;
   Ii_0070 = 241;
   Ii_0074 = 242;
   Ii_0078 = 243;
   Ii_007C = 244;
   Ii_0080 = 245;
   Ii_0084 = 246;
   Ii_0088 = 247;
   Ii_008C = 248;
   Ii_0090 = 249;
   Ii_0094 = 250;
   Ii_0098 = 251;
   Ii_009C = 252;
   Ii_00A0 = 253;
   } 
   if (_Symbol == "GBPJPYm" || _Symbol == "GBPJPY") { 
   
   Ii_006C = 260;
   Ii_0070 = 261;
   Ii_0074 = 262;
   Ii_0078 = 263;
   Ii_007C = 264;
   Ii_0080 = 265;
   Ii_0084 = 266;
   Ii_0088 = 267;
   Ii_008C = 268;
   Ii_0090 = 269;
   Ii_0094 = 270;
   Ii_0098 = 271;
   Ii_009C = 272;
   Ii_00A0 = 273;
   } 
   if (_Symbol == "GBPUSDm" || _Symbol == "GBPUSD") { 
   
   Ii_006C = 280;
   Ii_0070 = 281;
   Ii_0074 = 282;
   Ii_0078 = 283;
   Ii_007C = 284;
   Ii_0080 = 285;
   Ii_0084 = 286;
   Ii_0088 = 287;
   Ii_008C = 288;
   Ii_0090 = 289;
   Ii_0094 = 290;
   Ii_0098 = 291;
   Ii_009C = 292;
   Ii_00A0 = 293;
   } 
   if (_Symbol == "NZDJPYm" || _Symbol == "NZDJPY") { 
   
   Ii_006C = 300;
   Ii_0070 = 301;
   Ii_0074 = 302;
   Ii_0078 = 303;
   Ii_007C = 304;
   Ii_0080 = 305;
   Ii_0084 = 306;
   Ii_0088 = 307;
   Ii_008C = 308;
   Ii_0090 = 309;
   Ii_0094 = 310;
   Ii_0098 = 311;
   Ii_009C = 312;
   Ii_00A0 = 313;
   } 
   if (_Symbol == "NZDUSDm" || _Symbol == "NZDUSD") { 
   
   Ii_006C = 320;
   Ii_0070 = 321;
   Ii_0074 = 322;
   Ii_0078 = 323;
   Ii_007C = 324;
   Ii_0080 = 325;
   Ii_0084 = 326;
   Ii_0088 = 327;
   Ii_008C = 328;
   Ii_0090 = 329;
   Ii_0094 = 330;
   Ii_0098 = 331;
   Ii_009C = 332;
   Ii_00A0 = 333;
   } 
   if (_Symbol == "USDCHFm" || _Symbol == "USDCHF") { 
   
   Ii_006C = 340;
   Ii_0070 = 341;
   Ii_0074 = 342;
   Ii_0078 = 343;
   Ii_007C = 344;
   Ii_0080 = 345;
   Ii_0084 = 346;
   Ii_0088 = 347;
   Ii_008C = 348;
   Ii_0090 = 349;
   Ii_0094 = 350;
   Ii_0098 = 351;
   Ii_009C = 352;
   Ii_00A0 = 353;
   } 
   if (_Symbol == "USDJPYm" || _Symbol == "USDJPY") { 
   
   Ii_006C = 360;
   Ii_0070 = 361;
   Ii_0074 = 362;
   Ii_0078 = 363;
   Ii_007C = 364;
   Ii_0080 = 365;
   Ii_0084 = 366;
   Ii_0088 = 367;
   Ii_008C = 368;
   Ii_0090 = 369;
   Ii_0094 = 370;
   Ii_0098 = 371;
   Ii_009C = 372;
   Ii_00A0 = 373;
   } 
   if (_Symbol == "USDCADm" || _Symbol == "USDCAD") { 
   
   Ii_006C = 380;
   Ii_0070 = 381;
   Ii_0074 = 382;
   Ii_0078 = 383;
   Ii_007C = 384;
   Ii_0080 = 385;
   Ii_0084 = 386;
   Ii_0088 = 387;
   Ii_008C = 388;
   Ii_0090 = 389;
   Ii_0094 = 390;
   Ii_0098 = 391;
   Ii_009C = 392;
   Ii_00A0 = 393;
   } 
   if (_Symbol == "AUDCHFm" || _Symbol == "AUDCHF") { 
   
   Ii_006C = 400;
   Ii_0070 = 401;
   Ii_0074 = 402;
   Ii_0078 = 403;
   Ii_007C = 404;
   Ii_0080 = 405;
   Ii_0084 = 406;
   Ii_0088 = 407;
   Ii_008C = 408;
   Ii_0090 = 409;
   Ii_0094 = 410;
   Ii_0098 = 411;
   Ii_009C = 412;
   Ii_00A0 = 413;
   } 
   if (_Symbol == "AUDSGDm" || _Symbol == "AUDSGD") { 
   
   Ii_006C = 420;
   Ii_0070 = 421;
   Ii_0074 = 422;
   Ii_0078 = 423;
   Ii_007C = 424;
   Ii_0080 = 425;
   Ii_0084 = 426;
   Ii_0088 = 427;
   Ii_008C = 428;
   Ii_0090 = 429;
   Ii_0094 = 430;
   Ii_0098 = 431;
   Ii_009C = 432;
   Ii_00A0 = 433;
   } 
   if (_Symbol == "CHFSGDm" || _Symbol == "CHFSGD") { 
   
   Ii_006C = 440;
   Ii_0070 = 441;
   Ii_0074 = 442;
   Ii_0078 = 443;
   Ii_007C = 444;
   Ii_0080 = 445;
   Ii_0084 = 446;
   Ii_0088 = 447;
   Ii_008C = 448;
   Ii_0090 = 449;
   Ii_0094 = 450;
   Ii_0098 = 451;
   Ii_009C = 452;
   Ii_00A0 = 453;
   } 
   if (_Symbol == "CADCHFm" || _Symbol == "CADCHF") { 
   
   Ii_006C = 460;
   Ii_0070 = 461;
   Ii_0074 = 462;
   Ii_0078 = 463;
   Ii_007C = 464;
   Ii_0080 = 465;
   Ii_0084 = 466;
   Ii_0088 = 467;
   Ii_008C = 468;
   Ii_0090 = 469;
   Ii_0094 = 470;
   Ii_0098 = 471;
   Ii_009C = 472;
   Ii_00A0 = 473;
   } 
   if (_Symbol == "CADJPYm" || _Symbol == "CADJPY") { 
   
   Ii_006C = 480;
   Ii_0070 = 481;
   Ii_0074 = 482;
   Ii_0078 = 483;
   Ii_007C = 484;
   Ii_0080 = 485;
   Ii_0084 = 486;
   Ii_0088 = 487;
   Ii_008C = 488;
   Ii_0090 = 489;
   Ii_0094 = 490;
   Ii_0098 = 491;
   Ii_009C = 492;
   Ii_00A0 = 493;
   } 
   if (_Symbol == "EURNZDm" || _Symbol == "EURNZD") { 
   
   Ii_006C = 500;
   Ii_0070 = 501;
   Ii_0074 = 502;
   Ii_0078 = 503;
   Ii_007C = 504;
   Ii_0080 = 505;
   Ii_0084 = 506;
   Ii_0088 = 507;
   Ii_008C = 508;
   Ii_0090 = 509;
   Ii_0094 = 510;
   Ii_0098 = 511;
   Ii_009C = 512;
   Ii_00A0 = 513;
   } 
   if (_Symbol == "EURSGDm" || _Symbol == "EURSGD") { 
   
   Ii_006C = 520;
   Ii_0070 = 521;
   Ii_0074 = 522;
   Ii_0078 = 523;
   Ii_007C = 524;
   Ii_0080 = 525;
   Ii_0084 = 526;
   Ii_0088 = 527;
   Ii_008C = 528;
   Ii_0090 = 529;
   Ii_0094 = 530;
   Ii_0098 = 531;
   Ii_009C = 532;
   Ii_00A0 = 533;
   } 
   if (_Symbol == "EURDKKm" || _Symbol == "EURDKK") { 
   
   Ii_006C = 540;
   Ii_0070 = 541;
   Ii_0074 = 542;
   Ii_0078 = 543;
   Ii_007C = 544;
   Ii_0080 = 545;
   Ii_0084 = 546;
   Ii_0088 = 547;
   Ii_008C = 548;
   Ii_0090 = 549;
   Ii_0094 = 550;
   Ii_0098 = 551;
   Ii_009C = 552;
   Ii_00A0 = 553;
   } 
   if (_Symbol == "EURHKDm" || _Symbol == "EURHKD") { 
   
   Ii_006C = 560;
   Ii_0070 = 561;
   Ii_0074 = 562;
   Ii_0078 = 563;
   Ii_007C = 564;
   Ii_0080 = 565;
   Ii_0084 = 566;
   Ii_0088 = 567;
   Ii_008C = 568;
   Ii_0090 = 569;
   Ii_0094 = 570;
   Ii_0098 = 571;
   Ii_009C = 572;
   Ii_00A0 = 573;
   } 
   if (_Symbol == "GBPAUDm" || _Symbol == "GBPAUD") { 
   
   Ii_006C = 580;
   Ii_0070 = 581;
   Ii_0074 = 582;
   Ii_0078 = 583;
   Ii_007C = 584;
   Ii_0080 = 585;
   Ii_0084 = 586;
   Ii_0088 = 587;
   Ii_008C = 588;
   Ii_0090 = 589;
   Ii_0094 = 590;
   Ii_0098 = 591;
   Ii_009C = 592;
   Ii_00A0 = 593;
   } 
   if (_Symbol == "GBPCADm" || _Symbol == "GBPCAD") { 
   
   Ii_006C = 600;
   Ii_0070 = 601;
   Ii_0074 = 602;
   Ii_0078 = 603;
   Ii_007C = 604;
   Ii_0080 = 605;
   Ii_0084 = 606;
   Ii_0088 = 607;
   Ii_008C = 608;
   Ii_0090 = 609;
   Ii_0094 = 610;
   Ii_0098 = 611;
   Ii_009C = 612;
   Ii_00A0 = 613;
   } 
   if (_Symbol == "GBPNZDm" || _Symbol == "GBPNZD") { 
   
   Ii_006C = 620;
   Ii_0070 = 621;
   Ii_0074 = 622;
   Ii_0078 = 623;
   Ii_007C = 624;
   Ii_0080 = 625;
   Ii_0084 = 626;
   Ii_0088 = 627;
   Ii_008C = 628;
   Ii_0090 = 629;
   Ii_0094 = 630;
   Ii_0098 = 631;
   Ii_009C = 632;
   Ii_00A0 = 633;
   } 
   if (_Symbol == "GBPSGDm" || _Symbol == "GBPSGD") { 
   
   Ii_006C = 640;
   Ii_0070 = 641;
   Ii_0074 = 642;
   Ii_0078 = 643;
   Ii_007C = 644;
   Ii_0080 = 645;
   Ii_0084 = 646;
   Ii_0088 = 647;
   Ii_008C = 648;
   Ii_0090 = 649;
   Ii_0094 = 650;
   Ii_0098 = 651;
   Ii_009C = 652;
   Ii_00A0 = 653;
   } 
   if (_Symbol == "NZDCADm" || _Symbol == "NZDCHF") { 
   
   Ii_006C = 660;
   Ii_0070 = 661;
   Ii_0074 = 662;
   Ii_0078 = 663;
   Ii_007C = 664;
   Ii_0080 = 665;
   Ii_0084 = 666;
   Ii_0088 = 667;
   Ii_008C = 668;
   Ii_0090 = 669;
   Ii_0094 = 670;
   Ii_0098 = 671;
   Ii_009C = 672;
   Ii_00A0 = 673;
   } 
   if (_Symbol == "NZDCHFm" || _Symbol == "NZDCHF") { 
   
   Ii_006C = 680;
   Ii_0070 = 681;
   Ii_0074 = 682;
   Ii_0078 = 683;
   Ii_007C = 684;
   Ii_0080 = 685;
   Ii_0084 = 686;
   Ii_0088 = 687;
   Ii_008C = 688;
   Ii_0090 = 689;
   Ii_0094 = 690;
   Ii_0098 = 691;
   Ii_009C = 692;
   Ii_00A0 = 693;
   } 
   if (_Symbol == "SGDJPYm" || _Symbol == "SGDJPY") { 
   
   Ii_006C = 700;
   Ii_0070 = 701;
   Ii_0074 = 702;
   Ii_0078 = 703;
   Ii_007C = 704;
   Ii_0080 = 705;
   Ii_0084 = 706;
   Ii_0088 = 707;
   Ii_008C = 708;
   Ii_0090 = 709;
   Ii_0094 = 710;
   Ii_0098 = 711;
   Ii_009C = 712;
   Ii_00A0 = 713;
   } 
   if (_Symbol == "USDSGDm" || _Symbol == "USDSGD") { 
   
   Ii_006C = 720;
   Ii_0070 = 721;
   Ii_0074 = 722;
   Ii_0078 = 723;
   Ii_007C = 724;
   Ii_0080 = 725;
   Ii_0084 = 726;
   Ii_0088 = 727;
   Ii_008C = 728;
   Ii_0090 = 729;
   Ii_0094 = 730;
   Ii_0098 = 731;
   Ii_009C = 732;
   Ii_00A0 = 733;
   } 
   if (_Symbol == "USDDKKm" || _Symbol == "USDDKK") { 
   
   Ii_006C = 740;
   Ii_0070 = 741;
   Ii_0074 = 742;
   Ii_0078 = 743;
   Ii_007C = 744;
   Ii_0080 = 745;
   Ii_0084 = 746;
   Ii_0088 = 747;
   Ii_008C = 748;
   Ii_0090 = 749;
   Ii_0094 = 750;
   Ii_0098 = 751;
   Ii_009C = 752;
   Ii_00A0 = 753;
   } 
   if (_Symbol == "USDHKDm" || _Symbol == "USDHKD") { 
   
   Ii_006C = 760;
   Ii_0070 = 761;
   Ii_0074 = 762;
   Ii_0078 = 763;
   Ii_007C = 764;
   Ii_0080 = 765;
   Ii_0084 = 766;
   Ii_0088 = 767;
   Ii_008C = 768;
   Ii_0090 = 769;
   Ii_0094 = 770;
   Ii_0098 = 771;
   Ii_009C = 772;
   Ii_00A0 = 773;
   } 
   Ls_FFF0 = "";
   Ls_FFE0 = "";
   Ls_FFD0 = "";
   Ls_FFC0 = "";
   Ls_FFB0 = "";
   Ls_FFA0 = "";
   Ls_FF90 = "";
   Ls_FF80 = "";
   Ls_FF70 = "";
   Ls_FF60 = "";
   Ls_FF50 = "";
   Ls_FF40 = "--------------------------------------------------------";
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
   tmp_str000B = "";
   tmp_str000C = "--------------------------------------------------------";
   func_1031(tmp_str000C, tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001);
   Ls_FF30 = "";
   Ls_FF20 = "";
   Ls_FF10 = "";
   Ls_FF00 = "";
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = "";
   Ls_FE90 = "";
   Ls_FE80 = "Starting the EA";
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
   tmp_str0017 = "";
   tmp_str0018 = "Starting the EA";
   func_1031(tmp_str0018, tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E, tmp_str000D);
   Ld_FCE8 = _Digits;
   if ((Ld_FCE8 > 0) && (Ld_FCE8 != 2) && (Ld_FCE8 != 4)) { 
   Ld_FCE8 = (Ld_FCE8 - 1);
   } 
   returned_double = MathPow(10, Ld_FCE8);
   Id_38F0 = returned_double;
   Id_00C0 = Id_38F0;
   Id_00D0 = ((double)1 / Id_38F0);
   Ls_FE70 = "";
   Ls_FE60 = "";
   Ls_FE50 = "";
   Ls_FE40 = "";
   Ls_FE30 = "";
   Ls_FE20 = "";
   Ls_FE10 = "";
   Ls_FE00 = "";
   Ls_FDF0 = "";
   Ls_FDE0 = "";
   Global_ReturnedString = DoubleToString((Id_00D8 * Id_00C0), 2);
   Ls_FDD0 = Global_ReturnedString;
   Ls_FDC0 = "Broker Stop Difference: ";
   tmp_str0019 = "";
   tmp_str001A = "";
   tmp_str001B = "";
   tmp_str001C = "";
   tmp_str001D = "";
   tmp_str001E = "";
   tmp_str001F = "";
   tmp_str0020 = "";
   tmp_str0021 = "";
   tmp_str0022 = "";
   tmp_str0023 = Global_ReturnedString;
   tmp_str0024 = "Broker Stop Difference: ";
   func_1031(tmp_str0024, tmp_str0023, tmp_str0022, tmp_str0021, tmp_str0020, tmp_str001F, tmp_str001E, tmp_str001D, tmp_str001C, tmp_str001B, tmp_str001A, tmp_str0019);
   Ls_FDB0 = "";
   Ls_FDA0 = "";
   Ls_FD90 = "";
   Ls_FD80 = "";
   Ls_FD70 = "";
   Ls_FD60 = "";
   Ls_FD50 = "";
   Ls_FD40 = "";
   Ls_FD30 = "";
   Ls_FD20 = "";
   Ls_FD10 = "";
   Ls_FD00 = "--------------------------------------------------------";
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
   tmp_str002F = "";
   tmp_str0030 = "--------------------------------------------------------";
   func_1031(tmp_str0030, tmp_str002F, tmp_str002E, tmp_str002D, tmp_str002C, tmp_str002B, tmp_str002A, tmp_str0029, tmp_str0028, tmp_str0027, tmp_str0026, tmp_str0025);
   if (Ib_00E8 == 0) { 
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   ObjectCreate(0, "line1", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("line1", OBJPROP_CORNER, Ii_00F8);
   ObjectSet("line1", OBJPROP_YDISTANCE, Ii_00FC);
   ObjectSet("line1", OBJPROP_XDISTANCE, Ii_0100);
   ObjectSetText("line1", "The Money Tree Robot", 9, "Tahoma", Ii_0104);
   Li_FCFC = 0;
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
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   string Ls_FD90;
   string Ls_FD80;
   string Ls_FD70;
   string Ls_FD60;
   string Ls_FD50;
   string Ls_FD40;
   string Ls_FD30;
   string Ls_FD20;
   string Ls_FD10;
   string Ls_FD00;
   string Ls_FCF0;
   string Ls_FCE0;
   string Ls_FCD0;
   string Ls_FCC0;
   string Ls_FCB0;
   string Ls_FCA0;
   string Ls_FC90;
   string Ls_FC80;
   string Ls_FC70;
   string Ls_FC60;
   string Ls_FC50;
   string Ls_FC40;
   string Ls_FC30;
   string Ls_FC20;
   string Ls_FC10;
   string Ls_FC00;
   string Ls_FBF0;
   string Ls_FBE0;
   string Ls_FBD0;
   string Ls_FBC0;
   string Ls_FBB0;
   string Ls_FBA0;
   string Ls_FB90;
   string Ls_FB80;
   string Ls_FB70;
   string Ls_FB60;
   string Ls_FB50;
   int Li_FB4C;
   string Ls_FB40;
   int Li_FFFC;

   Li_FB4C = 0;
   Li_FB4C = 0;
   Ii_0108 = 0;
   Ii_010C = 0;
   Id_0110 = 0;
   Ii_0118 = 0;
   Ii_011C = 0;
   Ib_0120 = false;
   Ii_0124 = 0;
   Ii_0128 = 0;
   Ii_012C = 0;
   Id_0130 = 0;
   Id_0138 = 0;
   Ii_0140 = 0;
   Id_0148 = 0;
   Ii_0150 = 0;
   Id_0158 = 0;
   Id_0160 = 0;
   Ii_0168 = 0;
   Id_0170 = 0;
   Ii_0178 = 0;
   Id_0180 = 0;
   Ii_0188 = 0;
   Id_0190 = 0;
   Id_0198 = 0;
   Ii_01A0 = 0;
   Id_01A8 = 0;
   Id_01B0 = 0;
   Ii_01B8 = 0;
   Id_01C0 = 0;
   Ii_01C8 = 0;
   Id_01D0 = 0;
   Ii_01D8 = 0;
   Id_01E0 = 0;
   Id_01E8 = 0;
   Ii_01F0 = 0;
   Id_01F8 = 0;
   Id_0200 = 0;
   Ii_0208 = 0;
   Id_0210 = 0;
   Ii_0218 = 0;
   Id_0220 = 0;
   Ii_0228 = 0;
   Id_0230 = 0;
   Id_0238 = 0;
   Ii_0240 = 0;
   Id_0248 = 0;
   Id_0250 = 0;
   Ii_0258 = 0;
   Id_0260 = 0;
   Ii_0268 = 0;
   Id_0270 = 0;
   Ii_0278 = 0;
   Id_0280 = 0;
   Id_0288 = 0;
   Ii_0290 = 0;
   Id_0298 = 0;
   Id_02A0 = 0;
   Ii_02A8 = 0;
   Id_02B0 = 0;
   Ii_02B8 = 0;
   Id_02C0 = 0;
   Ii_02C8 = 0;
   Id_02D0 = 0;
   Id_02D8 = 0;
   Ii_02E0 = 0;
   Id_02E8 = 0;
   Id_02F0 = 0;
   Ii_02F8 = 0;
   Id_0300 = 0;
   Ii_0308 = 0;
   Id_0310 = 0;
   Ii_0318 = 0;
   Id_0320 = 0;
   Id_0328 = 0;
   Ii_0330 = 0;
   Id_0338 = 0;
   Id_0340 = 0;
   Ii_0348 = 0;
   Id_0350 = 0;
   Ib_0358 = false;
   Ii_035C = 0;
   Ii_0360 = 0;
   Ii_0364 = 0;
   Id_0368 = 0;
   Id_0370 = 0;
   Ii_0378 = 0;
   Id_0380 = 0;
   Ii_0388 = 0;
   Id_0390 = 0;
   Id_0398 = 0;
   Ii_03A0 = 0;
   Id_03A8 = 0;
   Ii_03B0 = 0;
   Id_03B8 = 0;
   Ii_03C0 = 0;
   Id_03C8 = 0;
   Id_03D0 = 0;
   Ii_03D8 = 0;
   Id_03E0 = 0;
   Id_03E8 = 0;
   Ii_03F0 = 0;
   Id_03F8 = 0;
   Ii_0400 = 0;
   Id_0408 = 0;
   Ii_0410 = 0;
   Id_0418 = 0;
   Id_0420 = 0;
   Ii_0428 = 0;
   Id_0430 = 0;
   Id_0438 = 0;
   Ii_0440 = 0;
   Id_0448 = 0;
   Ii_0450 = 0;
   Id_0458 = 0;
   Ii_0460 = 0;
   Id_0468 = 0;
   Id_0470 = 0;
   Ii_0478 = 0;
   Id_0480 = 0;
   Id_0488 = 0;
   Ii_0490 = 0;
   Id_0498 = 0;
   Ii_04A0 = 0;
   Id_04A8 = 0;
   Ii_04B0 = 0;
   Id_04B8 = 0;
   Id_04C0 = 0;
   Ii_04C8 = 0;
   Id_04D0 = 0;
   Id_04D8 = 0;
   Ii_04E0 = 0;
   Id_04E8 = 0;
   Ii_04F0 = 0;
   Id_04F8 = 0;
   Ii_0500 = 0;
   Id_0508 = 0;
   Id_0510 = 0;
   Ii_0518 = 0;
   Id_0520 = 0;
   Id_0528 = 0;
   Ii_0530 = 0;
   Id_0538 = 0;
   Ii_0540 = 0;
   Id_0548 = 0;
   Ii_0550 = 0;
   Id_0558 = 0;
   Id_0560 = 0;
   Ii_0568 = 0;
   Id_0570 = 0;
   Id_0578 = 0;
   Ii_0580 = 0;
   Id_0588 = 0;
   Id_0590 = 0;
   Ii_0598 = 0;
   Id_05A0 = 0;
   Ii_05A8 = 0;
   Ii_05AC = 0;
   Id_05B0 = 0;
   Ii_05B8 = 0;
   Id_05C0 = 0;
   Ii_05C8 = 0;
   Id_05D0 = 0;
   Ii_05D8 = 0;
   Ii_05DC = 0;
   Id_05E0 = 0;
   Ii_05E8 = 0;
   Id_05F0 = 0;
   Ii_05F8 = 0;
   Id_0600 = 0;
   Ii_0608 = 0;
   Id_0610 = 0;
   Ii_0618 = 0;
   Id_0620 = 0;
   Ii_0628 = 0;
   Ii_062C = 0;
   Id_0630 = 0;
   Ii_0638 = 0;
   Ii_063C = 0;
   Id_0640 = 0;
   Ii_0648 = 0;
   Id_0650 = 0;
   Ii_0658 = 0;
   Id_0660 = 0;
   Ii_0668 = 0;
   Ii_066C = 0;
   Id_0670 = 0;
   Ii_0678 = 0;
   Id_0680 = 0;
   Ii_0688 = 0;
   Id_0690 = 0;
   Ii_0698 = 0;
   Ii_069C = 0;
   Id_06A0 = 0;
   Ii_06A8 = 0;
   Id_06B0 = 0;
   Ii_06B8 = 0;
   Id_06C0 = 0;
   Ii_06C8 = 0;
   Id_06D0 = 0;
   Ii_06D8 = 0;
   Id_06E0 = 0;
   Ii_06E8 = 0;
   Ii_06EC = 0;
   Id_06F0 = 0;
   Ii_06F8 = 0;
   Ii_06FC = 0;
   Id_0700 = 0;
   Ii_0708 = 0;
   if (Bars < 30) { 
   if (Ib_070C) { 
   Print("NOT ENOUGH DATA: Less Bars than 30");
   } 
   Li_FB4C = 0;
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   Ls_FFF0 = TimeToString(Time[0], 1);
   Ii_0108 = _Period;
   if (Ii_0108 == 240 || _Period == 60) { 
   
   Ls_FFE0 = (string)TimeHour(Time[0]);
   Ls_FFE0 = Ls_FFF0 + Ls_FFE0;
   Ls_FFF0 = Ls_FFE0;
   } 
   if (Ii_0108 == 5 || Ii_0108 == 1) { 
   
   Ls_FFE0 = Ls_FFF0 + " ";
   Ls_FFE0 = Ls_FFE0 + TimeToString(Time[0], 2);
   Ls_FFF0 = Ls_FFE0;
   } 
   Ls_FB40 = Ls_FFF0;
   if (Ls_FFF0 == Is_0748) { 
   Ib_0754 = false;
   } 
   else { 
   Is_0748 = Ls_FB40;
   Ib_0754 = true;
   } 
   Ii_0758 = Ii_0104;
   Ii_010C = 0;
   Id_0110 = 0;
   Ii_075C = OrdersTotal() - 1;
   Ii_0118 = Ii_075C;
   if (Ii_075C >= 0) { 
   do { 
   if (OrderSelect(Ii_0118, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_010C == 0 || OrderMagicNumber() == Ii_010C) { 
   
   Id_0110 = (Id_0110 + OrderProfit());
   }}}} 
   Ii_0118 = Ii_0118 - 1;
   } while (Ii_0118 >= 0); 
   } 
   Ls_FFE0 = "Open P/L: " + DoubleToString(Id_0110, 2);
   ObjectSetText("lineopl", Ls_FFE0, 8, "Tahoma", Ii_0758);
   Ls_FFD0 = "Account Balance: " + DoubleToString(AccountBalance(), 2);
   ObjectSetText("linea", Ls_FFD0, 8, "Tahoma", Ii_0104);
   if (Ib_0754) { 
   func_1029();
   } 
   Ii_075C = OrdersTotal() - 1;
   Ii_011C = Ii_075C;
   if (Ii_075C >= 0) { 
   do { 
   if (OrderSelect(Ii_011C, 0, 0) == true) { 
   func_1015(OrderMagicNumber());
   if (Ib_0754) { 
   func_1016(OrderMagicNumber());
   }} 
   if (OrdersTotal() <= 0) break; 
   Ii_011C = Ii_011C - 1;
   } while (Ii_011C >= 0); 
   } 
   returned_double = iMA(NULL, 240, 200, 0, 1, 0, 1);
   Id_0768 = returned_double;
   if ((returned_double < Close[1])) { 
   Gi_0004 = Ib_0060;
   if (Gi_0004 == 0 && OrdersTotal() < Ii_005C) { 
   Ii_0124 = Ii_006C;
   Ii_0128 = 0;
   Ib_0120 = false;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Ii_0128, 0, 0) == true && OrderSymbol() == _Symbol) { 
   if (Ii_0124 == 0 || OrderMagicNumber() == Ii_0124) { 
   
   Il_0780 = OrderOpenTime();
   if (Il_0780 > Time[1]) { 
   Ib_0120 = true;
   break; 
   }}} 
   Ii_0128 = Ii_0128 + 1;
   } while (Ii_0128 < OrdersTotal()); 
   } 
   Ii_0128 = HistoryTotal();
   if (Ii_0128 >= 0) {
   do { 
   if (OrderSelect(Ii_0128, 0, 1) == true && OrderSymbol() == _Symbol) {
   if (Ii_0124 == 0 || OrderMagicNumber() == Ii_0124) {
   
   Il_0780 = OrderOpenTime();
   if (Il_0780 > Time[1]) {
   Ib_0120 = true;
   break;
   }}}
   Ii_0128 = Ii_0128 - 1;
   } while (Ii_0128 >= 0); 
   }
   else{
   Ib_0120 = false;
   }
   Gi_0006 = Ib_0120;
   if (Gi_0006 == 0 && (MarketInfo(_Symbol, MODE_SWAPLONG) >= Ii_0064)) { 
   if ((iRSI(NULL, 240, 14, 0, 1) <= Ii_0048) || (iStochastic(NULL, 240, 50, 3, 3, 0, 0, 0, 1) <= Ii_0058)) { 
   
   Ls_FFC0 = "Go long 1";
   Ls_FFB0 = "MONEYTREE";
   Ii_0140 = Ii_006C;
   Id_0148 = 0;
   if (Ii_006C == Ii_006C) { 
   Id_0148 = Ask;
   } 
   if (Ii_0140 == Ii_0070) { 
   Id_0148 = Ask;
   } 
   if (Ii_0140 == Ii_0074) { 
   Id_0148 = Ask;
   } 
   if (Ii_0140 == Ii_0078) { 
   Id_0148 = Ask;
   } 
   if (Ii_0140 == Ii_007C) { 
   Id_0148 = Ask;
   } 
   if (Ii_0140 == Ii_0080) { 
   Id_0148 = Ask;
   } 
   if (Ii_0140 == Ii_0084) { 
   Id_0148 = Ask;
   } 
   if (Ii_0140 == Ii_0088) { 
   Id_0148 = Bid;
   } 
   if (Ii_0140 == Ii_008C) { 
   Id_0148 = Bid;
   } 
   if (Ii_0140 == Ii_0090) { 
   Id_0148 = Bid;
   } 
   if (Ii_0140 == Ii_0094) { 
   Id_0148 = Bid;
   } 
   if (Ii_0140 == Ii_0098) { 
   Id_0148 = Bid;
   } 
   if (Ii_0140 == Ii_009C) { 
   Id_0148 = Bid;
   } 
   if (Ii_0140 == Ii_00A0) { 
   Id_0148 = Bid;
   } 
   Ii_012C = Ii_006C;
   Id_0130 = 0;
   if (Ii_006C == Ii_006C) { 
   Id_0130 = LotSize;
   } 
   if (Ii_012C == Ii_0070) { 
   Id_0130 = Id_07A0;
   } 
   if (Ii_012C == Ii_0074) { 
   Id_0130 = Id_07A8;
   } 
   if (Ii_012C == Ii_0078) { 
   Id_0130 = Id_07B0;
   } 
   if (Ii_012C == Ii_007C) { 
   Id_0130 = Id_07B8;
   } 
   if (Ii_012C == Ii_0080) { 
   Id_0130 = Id_07C0;
   } 
   if (Ii_012C == Ii_0084) { 
   Id_0130 = Id_07C0;
   } 
   if (Ii_012C == Ii_0088) { 
   Id_0130 = LotSize;
   } 
   if (Ii_012C == Ii_008C) { 
   Id_0130 = Id_07A0;
   } 
   if (Ii_012C == Ii_0090) { 
   Id_0130 = Id_07A8;
   } 
   if (Ii_012C == Ii_0094) { 
   Id_0130 = Id_07B0;
   } 
   if (Ii_012C == Ii_0098) { 
   Id_0130 = Id_07B8;
   } 
   if (Ii_012C == Ii_009C) { 
   Id_0130 = Id_07C0;
   } 
   if (Ii_012C == Ii_00A0) { 
   Id_0130 = Id_07C0;
   } 
   Ls_FFA0 = "NULL";
   tmp_str0000 = Ls_FFC0;
   tmp_str0001 = Ls_FFB0;
   tmp_str0002 = "NULL";
   func_1024(tmp_str0002, 0, Id_0130, NormalizeDouble(Id_0148, _Digits), tmp_str0001, Ii_006C, tmp_str0000);
   }}}} 
   returned_double = iMA(NULL, 240, 200, 0, 1, 0, 1);
   Id_0768 = returned_double;
   if ((returned_double < Close[1]) && Ib_0060 == true && OrdersTotal() < Ii_005C && (MarketInfo(_Symbol, MODE_SWAPLONG) >= Ii_0064)) { 
   if ((iRSI(NULL, 240, 14, 0, 1) <= Ii_0048) || (iStochastic(NULL, 240, 50, 3, 3, 0, 0, 0, 1) <= Ii_0058)) { 
   
   Ls_FF90 = "Go long 1";
   Ls_FF80 = "MONEYTREE";
   Ii_0168 = Ii_006C;
   Id_0170 = 0;
   if (Ii_006C == Ii_006C) { 
   Id_0170 = Ask;
   } 
   if (Ii_0168 == Ii_0070) { 
   Id_0170 = Ask;
   } 
   if (Ii_0168 == Ii_0074) { 
   Id_0170 = Ask;
   } 
   if (Ii_0168 == Ii_0078) { 
   Id_0170 = Ask;
   } 
   if (Ii_0168 == Ii_007C) { 
   Id_0170 = Ask;
   } 
   if (Ii_0168 == Ii_0080) { 
   Id_0170 = Ask;
   } 
   if (Ii_0168 == Ii_0084) { 
   Id_0170 = Ask;
   } 
   if (Ii_0168 == Ii_0088) { 
   Id_0170 = Bid;
   } 
   if (Ii_0168 == Ii_008C) { 
   Id_0170 = Bid;
   } 
   if (Ii_0168 == Ii_0090) { 
   Id_0170 = Bid;
   } 
   if (Ii_0168 == Ii_0094) { 
   Id_0170 = Bid;
   } 
   if (Ii_0168 == Ii_0098) { 
   Id_0170 = Bid;
   } 
   if (Ii_0168 == Ii_009C) { 
   Id_0170 = Bid;
   } 
   if (Ii_0168 == Ii_00A0) { 
   Id_0170 = Bid;
   } 
   Ii_0150 = Ii_006C;
   Id_0158 = 0;
   if (Ii_006C == Ii_006C) { 
   Id_0158 = LotSize;
   } 
   if (Ii_0150 == Ii_0070) { 
   Id_0158 = Id_07A0;
   } 
   if (Ii_0150 == Ii_0074) { 
   Id_0158 = Id_07A8;
   } 
   if (Ii_0150 == Ii_0078) { 
   Id_0158 = Id_07B0;
   } 
   if (Ii_0150 == Ii_007C) { 
   Id_0158 = Id_07B8;
   } 
   if (Ii_0150 == Ii_0080) { 
   Id_0158 = Id_07C0;
   } 
   if (Ii_0150 == Ii_0084) { 
   Id_0158 = Id_07C0;
   } 
   if (Ii_0150 == Ii_0088) { 
   Id_0158 = LotSize;
   } 
   if (Ii_0150 == Ii_008C) { 
   Id_0158 = Id_07A0;
   } 
   if (Ii_0150 == Ii_0090) { 
   Id_0158 = Id_07A8;
   } 
   if (Ii_0150 == Ii_0094) { 
   Id_0158 = Id_07B0;
   } 
   if (Ii_0150 == Ii_0098) { 
   Id_0158 = Id_07B8;
   } 
   if (Ii_0150 == Ii_009C) { 
   Id_0158 = Id_07C0;
   } 
   if (Ii_0150 == Ii_00A0) { 
   Id_0158 = Id_07C0;
   } 
   Ls_FF70 = "NULL";
   tmp_str0003 = Ls_FF90;
   tmp_str0004 = Ls_FF80;
   tmp_str0005 = "NULL";
   func_1024(tmp_str0005, 0, Id_0158, NormalizeDouble(Id_0170, _Digits), tmp_str0004, Ii_006C, tmp_str0003);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Ii_0178 = Ii_006C;
   Id_0180 = 0;
   Ii_075C = OrdersTotal() - 1;
   Ii_0188 = Ii_075C;
   if (Ii_075C >= 0) { 
   do { 
   if (OrderSelect(Ii_0188, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0178 == 0 || OrderMagicNumber() == Ii_0178) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FF60 = OrderSymbol();
   if (Ls_FF60 == "NULL") { 
   Id_0190 = Bid;
   } 
   else { 
   Id_0190 = MarketInfo(Ls_FF60, MODE_BID);
   } 
   Id_0180 = ((Id_0190 - OrderOpenPrice()) + Id_0180);
   } 
   else { 
   Id_0768 = OrderOpenPrice();
   Ls_FF50 = OrderSymbol();
   if (Ls_FF50 == "NULL") { 
   Id_0198 = Ask;
   } 
   else { 
   Id_0198 = MarketInfo(Ls_FF50, MODE_ASK);
   } 
   Id_0180 = ((Id_0768 - Id_0198) + Id_0180);
   }}}}} 
   Ii_0188 = Ii_0188 - 1;
   } while (Ii_0188 >= 0); 
   } 
   if (((Id_0180 * Id_00C0) <= -70)) { 
   Id_07A0 = ((LotSize + 0.0018) * Id_07D8);
   Ls_FF40 = "Go long 2";
   Ls_FF30 = "MONEYTREE";
   Ii_01B8 = Ii_0070;
   Id_01C0 = 0;
   if (Ii_0070 == Ii_006C) { 
   Id_01C0 = Ask;
   } 
   if (Ii_01B8 == Ii_0070) { 
   Id_01C0 = Ask;
   } 
   if (Ii_01B8 == Ii_0074) { 
   Id_01C0 = Ask;
   } 
   if (Ii_01B8 == Ii_0078) { 
   Id_01C0 = Ask;
   } 
   if (Ii_01B8 == Ii_007C) { 
   Id_01C0 = Ask;
   } 
   if (Ii_01B8 == Ii_0080) { 
   Id_01C0 = Ask;
   } 
   if (Ii_01B8 == Ii_0084) { 
   Id_01C0 = Ask;
   } 
   if (Ii_01B8 == Ii_0088) { 
   Id_01C0 = Bid;
   } 
   if (Ii_01B8 == Ii_008C) { 
   Id_01C0 = Bid;
   } 
   if (Ii_01B8 == Ii_0090) { 
   Id_01C0 = Bid;
   } 
   if (Ii_01B8 == Ii_0094) { 
   Id_01C0 = Bid;
   } 
   if (Ii_01B8 == Ii_0098) { 
   Id_01C0 = Bid;
   } 
   if (Ii_01B8 == Ii_009C) { 
   Id_01C0 = Bid;
   } 
   if (Ii_01B8 == Ii_00A0) { 
   Id_01C0 = Bid;
   } 
   Ii_01A0 = Ii_0070;
   Id_01A8 = 0;
   if (Ii_0070 == Ii_006C) { 
   Id_01A8 = LotSize;
   } 
   if (Ii_01A0 == Ii_0070) { 
   Id_01A8 = Id_07A0;
   } 
   if (Ii_01A0 == Ii_0074) { 
   Id_01A8 = Id_07A8;
   } 
   if (Ii_01A0 == Ii_0078) { 
   Id_01A8 = Id_07B0;
   } 
   if (Ii_01A0 == Ii_007C) { 
   Id_01A8 = Id_07B8;
   } 
   if (Ii_01A0 == Ii_0080) { 
   Id_01A8 = Id_07C0;
   } 
   if (Ii_01A0 == Ii_0084) { 
   Id_01A8 = Id_07C0;
   } 
   if (Ii_01A0 == Ii_0088) { 
   Id_01A8 = LotSize;
   } 
   if (Ii_01A0 == Ii_008C) { 
   Id_01A8 = Id_07A0;
   } 
   if (Ii_01A0 == Ii_0090) { 
   Id_01A8 = Id_07A8;
   } 
   if (Ii_01A0 == Ii_0094) { 
   Id_01A8 = Id_07B0;
   } 
   if (Ii_01A0 == Ii_0098) { 
   Id_01A8 = Id_07B8;
   } 
   if (Ii_01A0 == Ii_009C) { 
   Id_01A8 = Id_07C0;
   } 
   if (Ii_01A0 == Ii_00A0) { 
   Id_01A8 = Id_07C0;
   } 
   Ls_FF20 = "NULL";
   tmp_str0006 = Ls_FF40;
   tmp_str0007 = Ls_FF30;
   tmp_str0008 = "NULL";
   func_1024(tmp_str0008, 0, Id_01A8, NormalizeDouble(Id_01C0, _Digits), tmp_str0007, Ii_0070, tmp_str0006);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Ii_01C8 = Ii_0070;
   Id_01D0 = 0;
   Ii_075C = OrdersTotal() - 1;
   Ii_01D8 = Ii_075C;
   if (Ii_075C >= 0) { 
   do { 
   if (OrderSelect(Ii_01D8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_01C8 == 0 || OrderMagicNumber() == Ii_01C8) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FF10 = OrderSymbol();
   if (Ls_FF10 == "NULL") { 
   Id_01E0 = Bid;
   } 
   else { 
   Id_01E0 = MarketInfo(Ls_FF10, MODE_BID);
   } 
   Id_01D0 = ((Id_01E0 - OrderOpenPrice()) + Id_01D0);
   } 
   else { 
   Id_0768 = OrderOpenPrice();
   Ls_FF00 = OrderSymbol();
   if (Ls_FF00 == "NULL") { 
   Id_01E8 = Ask;
   } 
   else { 
   Id_01E8 = MarketInfo(Ls_FF00, MODE_ASK);
   } 
   Id_01D0 = ((Id_0768 - Id_01E8) + Id_01D0);
   }}}}} 
   Ii_01D8 = Ii_01D8 - 1;
   } while (Ii_01D8 >= 0); 
   } 
   if (((Id_01D0 * Id_00C0) <= -120)) { 
   Id_0768 = (LotSize + 0.0018);
   Id_07A8 = ((Id_07D8 * Id_07D8) * Id_0768);
   Ls_FEF0 = "Go long 3";
   Ls_FEE0 = "MONEYTREE";
   Ii_0208 = Ii_0074;
   Id_0210 = 0;
   if (Ii_0074 == Ii_006C) { 
   Id_0210 = Ask;
   } 
   if (Ii_0208 == Ii_0070) { 
   Id_0210 = Ask;
   } 
   if (Ii_0208 == Ii_0074) { 
   Id_0210 = Ask;
   } 
   if (Ii_0208 == Ii_0078) { 
   Id_0210 = Ask;
   } 
   if (Ii_0208 == Ii_007C) { 
   Id_0210 = Ask;
   } 
   if (Ii_0208 == Ii_0080) { 
   Id_0210 = Ask;
   } 
   if (Ii_0208 == Ii_0084) { 
   Id_0210 = Ask;
   } 
   if (Ii_0208 == Ii_0088) { 
   Id_0210 = Bid;
   } 
   if (Ii_0208 == Ii_008C) { 
   Id_0210 = Bid;
   } 
   if (Ii_0208 == Ii_0090) { 
   Id_0210 = Bid;
   } 
   if (Ii_0208 == Ii_0094) { 
   Id_0210 = Bid;
   } 
   if (Ii_0208 == Ii_0098) { 
   Id_0210 = Bid;
   } 
   if (Ii_0208 == Ii_009C) { 
   Id_0210 = Bid;
   } 
   if (Ii_0208 == Ii_00A0) { 
   Id_0210 = Bid;
   } 
   Ii_01F0 = Ii_0074;
   Id_01F8 = 0;
   if (Ii_0074 == Ii_006C) { 
   Id_01F8 = LotSize;
   } 
   if (Ii_01F0 == Ii_0070) { 
   Id_01F8 = Id_07A0;
   } 
   if (Ii_01F0 == Ii_0074) { 
   Id_01F8 = Id_07A8;
   } 
   if (Ii_01F0 == Ii_0078) { 
   Id_01F8 = Id_07B0;
   } 
   if (Ii_01F0 == Ii_007C) { 
   Id_01F8 = Id_07B8;
   } 
   if (Ii_01F0 == Ii_0080) { 
   Id_01F8 = Id_07C0;
   } 
   if (Ii_01F0 == Ii_0084) { 
   Id_01F8 = Id_07C0;
   } 
   if (Ii_01F0 == Ii_0088) { 
   Id_01F8 = LotSize;
   } 
   if (Ii_01F0 == Ii_008C) { 
   Id_01F8 = Id_07A0;
   } 
   if (Ii_01F0 == Ii_0090) { 
   Id_01F8 = Id_07A8;
   } 
   if (Ii_01F0 == Ii_0094) { 
   Id_01F8 = Id_07B0;
   } 
   if (Ii_01F0 == Ii_0098) { 
   Id_01F8 = Id_07B8;
   } 
   if (Ii_01F0 == Ii_009C) { 
   Id_01F8 = Id_07C0;
   } 
   if (Ii_01F0 == Ii_00A0) { 
   Id_01F8 = Id_07C0;
   } 
   Ls_FED0 = "NULL";
   tmp_str0009 = Ls_FEF0;
   tmp_str000A = Ls_FEE0;
   tmp_str000B = "NULL";
   func_1024(tmp_str000B, 0, Id_01F8, NormalizeDouble(Id_0210, _Digits), tmp_str000A, Ii_0074, tmp_str0009);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Ii_0218 = Ii_0074;
   Id_0220 = 0;
   Ii_075C = OrdersTotal() - 1;
   Ii_0228 = Ii_075C;
   if (Ii_075C >= 0) { 
   do { 
   if (OrderSelect(Ii_0228, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0218 == 0 || OrderMagicNumber() == Ii_0218) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FEC0 = OrderSymbol();
   if (Ls_FEC0 == "NULL") { 
   Id_0230 = Bid;
   } 
   else { 
   Id_0230 = MarketInfo(Ls_FEC0, MODE_BID);
   } 
   Id_0220 = ((Id_0230 - OrderOpenPrice()) + Id_0220);
   } 
   else { 
   Id_0768 = OrderOpenPrice();
   Ls_FEB0 = OrderSymbol();
   if (Ls_FEB0 == "NULL") { 
   Id_0238 = Ask;
   } 
   else { 
   Id_0238 = MarketInfo(Ls_FEB0, MODE_ASK);
   } 
   Id_0220 = ((Id_0768 - Id_0238) + Id_0220);
   }}}}} 
   Ii_0228 = Ii_0228 - 1;
   } while (Ii_0228 >= 0); 
   } 
   if (((Id_0220 * Id_00C0) <= -150)) { 
   Id_0768 = (LotSize + 0.0018);
   Id_07B0 = (((Id_07D8 * Id_07D8) * Id_07D8) * Id_0768);
   Ls_FEA0 = "Go long 4";
   Ls_FE90 = "MONEYTREE";
   Ii_0258 = Ii_0078;
   Id_0260 = 0;
   if (Ii_0078 == Ii_006C) { 
   Id_0260 = Ask;
   } 
   if (Ii_0258 == Ii_0070) { 
   Id_0260 = Ask;
   } 
   if (Ii_0258 == Ii_0074) { 
   Id_0260 = Ask;
   } 
   if (Ii_0258 == Ii_0078) { 
   Id_0260 = Ask;
   } 
   if (Ii_0258 == Ii_007C) { 
   Id_0260 = Ask;
   } 
   if (Ii_0258 == Ii_0080) { 
   Id_0260 = Ask;
   } 
   if (Ii_0258 == Ii_0084) { 
   Id_0260 = Ask;
   } 
   if (Ii_0258 == Ii_0088) { 
   Id_0260 = Bid;
   } 
   if (Ii_0258 == Ii_008C) { 
   Id_0260 = Bid;
   } 
   if (Ii_0258 == Ii_0090) { 
   Id_0260 = Bid;
   } 
   if (Ii_0258 == Ii_0094) { 
   Id_0260 = Bid;
   } 
   if (Ii_0258 == Ii_0098) { 
   Id_0260 = Bid;
   } 
   if (Ii_0258 == Ii_009C) { 
   Id_0260 = Bid;
   } 
   if (Ii_0258 == Ii_00A0) { 
   Id_0260 = Bid;
   } 
   Ii_0240 = Ii_0078;
   Id_0248 = 0;
   if (Ii_0078 == Ii_006C) { 
   Id_0248 = LotSize;
   } 
   if (Ii_0240 == Ii_0070) { 
   Id_0248 = Id_07A0;
   } 
   if (Ii_0240 == Ii_0074) { 
   Id_0248 = Id_07A8;
   } 
   if (Ii_0240 == Ii_0078) { 
   Id_0248 = Id_07B0;
   } 
   if (Ii_0240 == Ii_007C) { 
   Id_0248 = Id_07B8;
   } 
   if (Ii_0240 == Ii_0080) { 
   Id_0248 = Id_07C0;
   } 
   if (Ii_0240 == Ii_0084) { 
   Id_0248 = Id_07C0;
   } 
   if (Ii_0240 == Ii_0088) { 
   Id_0248 = LotSize;
   } 
   if (Ii_0240 == Ii_008C) { 
   Id_0248 = Id_07A0;
   } 
   if (Ii_0240 == Ii_0090) { 
   Id_0248 = Id_07A8;
   } 
   if (Ii_0240 == Ii_0094) { 
   Id_0248 = Id_07B0;
   } 
   if (Ii_0240 == Ii_0098) { 
   Id_0248 = Id_07B8;
   } 
   if (Ii_0240 == Ii_009C) { 
   Id_0248 = Id_07C0;
   } 
   if (Ii_0240 == Ii_00A0) { 
   Id_0248 = Id_07C0;
   } 
   Ls_FE80 = "NULL";
   tmp_str000C = Ls_FEA0;
   tmp_str000D = Ls_FE90;
   tmp_str000E = "NULL";
   func_1024(tmp_str000E, 0, Id_0248, NormalizeDouble(Id_0260, _Digits), tmp_str000D, Ii_0078, tmp_str000C);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Ii_0268 = Ii_0078;
   Id_0270 = 0;
   Ii_075C = OrdersTotal() - 1;
   Ii_0278 = Ii_075C;
   if (Ii_075C >= 0) { 
   do { 
   if (OrderSelect(Ii_0278, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0268 == 0 || OrderMagicNumber() == Ii_0268) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FE70 = OrderSymbol();
   if (Ls_FE70 == "NULL") { 
   Id_0280 = Bid;
   } 
   else { 
   Id_0280 = MarketInfo(Ls_FE70, MODE_BID);
   } 
   Id_0270 = ((Id_0280 - OrderOpenPrice()) + Id_0270);
   } 
   else { 
   Id_0768 = OrderOpenPrice();
   Ls_FE60 = OrderSymbol();
   if (Ls_FE60 == "NULL") { 
   Id_0288 = Ask;
   } 
   else { 
   Id_0288 = MarketInfo(Ls_FE60, MODE_ASK);
   } 
   Id_0270 = ((Id_0768 - Id_0288) + Id_0270);
   }}}}} 
   Ii_0278 = Ii_0278 - 1;
   } while (Ii_0278 >= 0); 
   } 
   if (((Id_0270 * Id_00C0) <= -200)) { 
   Id_0768 = ((LotSize + 0.0018) * Id_07D8);
   Id_07B8 = (((Id_07D8 * Id_07D8) * Id_07D8) * Id_0768);
   Ls_FE50 = "Go long 5";
   Ls_FE40 = "MONEYTREE";
   Ii_02A8 = Ii_007C;
   Id_02B0 = 0;
   if (Ii_007C == Ii_006C) { 
   Id_02B0 = Ask;
   } 
   if (Ii_02A8 == Ii_0070) { 
   Id_02B0 = Ask;
   } 
   if (Ii_02A8 == Ii_0074) { 
   Id_02B0 = Ask;
   } 
   if (Ii_02A8 == Ii_0078) { 
   Id_02B0 = Ask;
   } 
   if (Ii_02A8 == Ii_007C) { 
   Id_02B0 = Ask;
   } 
   if (Ii_02A8 == Ii_0080) { 
   Id_02B0 = Ask;
   } 
   if (Ii_02A8 == Ii_0084) { 
   Id_02B0 = Ask;
   } 
   if (Ii_02A8 == Ii_0088) { 
   Id_02B0 = Bid;
   } 
   if (Ii_02A8 == Ii_008C) { 
   Id_02B0 = Bid;
   } 
   if (Ii_02A8 == Ii_0090) { 
   Id_02B0 = Bid;
   } 
   if (Ii_02A8 == Ii_0094) { 
   Id_02B0 = Bid;
   } 
   if (Ii_02A8 == Ii_0098) { 
   Id_02B0 = Bid;
   } 
   if (Ii_02A8 == Ii_009C) { 
   Id_02B0 = Bid;
   } 
   if (Ii_02A8 == Ii_00A0) { 
   Id_02B0 = Bid;
   } 
   Ii_0290 = Ii_007C;
   Id_0298 = 0;
   if (Ii_007C == Ii_006C) { 
   Id_0298 = LotSize;
   } 
   if (Ii_0290 == Ii_0070) { 
   Id_0298 = Id_07A0;
   } 
   if (Ii_0290 == Ii_0074) { 
   Id_0298 = Id_07A8;
   } 
   if (Ii_0290 == Ii_0078) { 
   Id_0298 = Id_07B0;
   } 
   if (Ii_0290 == Ii_007C) { 
   Id_0298 = Id_07B8;
   } 
   if (Ii_0290 == Ii_0080) { 
   Id_0298 = Id_07C0;
   } 
   if (Ii_0290 == Ii_0084) { 
   Id_0298 = Id_07C0;
   } 
   if (Ii_0290 == Ii_0088) { 
   Id_0298 = LotSize;
   } 
   if (Ii_0290 == Ii_008C) { 
   Id_0298 = Id_07A0;
   } 
   if (Ii_0290 == Ii_0090) { 
   Id_0298 = Id_07A8;
   } 
   if (Ii_0290 == Ii_0094) { 
   Id_0298 = Id_07B0;
   } 
   if (Ii_0290 == Ii_0098) { 
   Id_0298 = Id_07B8;
   } 
   if (Ii_0290 == Ii_009C) { 
   Id_0298 = Id_07C0;
   } 
   if (Ii_0290 == Ii_00A0) { 
   Id_0298 = Id_07C0;
   } 
   Ls_FE30 = "NULL";
   tmp_str000F = Ls_FE50;
   tmp_str0010 = Ls_FE40;
   tmp_str0011 = "NULL";
   func_1024(tmp_str0011, 0, Id_0298, NormalizeDouble(Id_02B0, _Digits), tmp_str0010, Ii_007C, tmp_str000F);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Ii_02B8 = Ii_007C;
   Id_02C0 = 0;
   Ii_075C = OrdersTotal() - 1;
   Ii_02C8 = Ii_075C;
   if (Ii_075C >= 0) { 
   do { 
   if (OrderSelect(Ii_02C8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_02B8 == 0 || OrderMagicNumber() == Ii_02B8) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FE20 = OrderSymbol();
   if (Ls_FE20 == "NULL") { 
   Id_02D0 = Bid;
   } 
   else { 
   Id_02D0 = MarketInfo(Ls_FE20, MODE_BID);
   } 
   Id_02C0 = ((Id_02D0 - OrderOpenPrice()) + Id_02C0);
   } 
   else { 
   Id_0768 = OrderOpenPrice();
   Ls_FE10 = OrderSymbol();
   if (Ls_FE10 == "NULL") { 
   Id_02D8 = Ask;
   } 
   else { 
   Id_02D8 = MarketInfo(Ls_FE10, MODE_ASK);
   } 
   Id_02C0 = ((Id_0768 - Id_02D8) + Id_02C0);
   }}}}} 
   Ii_02C8 = Ii_02C8 - 1;
   } while (Ii_02C8 >= 0); 
   } 
   if (((Id_02C0 * Id_00C0) <= -200)) { 
   Id_0768 = ((LotSize + 0.0018) * Id_07D8);
   Id_07C0 = ((((Id_07D8 * Id_07D8) * Id_07D8) * Id_07D8) * Id_0768);
   Ls_FE00 = "Go long 6";
   Ls_FDF0 = "MONEYTREE";
   Ii_02F8 = Ii_0080;
   Id_0300 = 0;
   if (Ii_0080 == Ii_006C) { 
   Id_0300 = Ask;
   } 
   if (Ii_02F8 == Ii_0070) { 
   Id_0300 = Ask;
   } 
   if (Ii_02F8 == Ii_0074) { 
   Id_0300 = Ask;
   } 
   if (Ii_02F8 == Ii_0078) { 
   Id_0300 = Ask;
   } 
   if (Ii_02F8 == Ii_007C) { 
   Id_0300 = Ask;
   } 
   if (Ii_02F8 == Ii_0080) { 
   Id_0300 = Ask;
   } 
   if (Ii_02F8 == Ii_0084) { 
   Id_0300 = Ask;
   } 
   if (Ii_02F8 == Ii_0088) { 
   Id_0300 = Bid;
   } 
   if (Ii_02F8 == Ii_008C) { 
   Id_0300 = Bid;
   } 
   if (Ii_02F8 == Ii_0090) { 
   Id_0300 = Bid;
   } 
   if (Ii_02F8 == Ii_0094) { 
   Id_0300 = Bid;
   } 
   if (Ii_02F8 == Ii_0098) { 
   Id_0300 = Bid;
   } 
   if (Ii_02F8 == Ii_009C) { 
   Id_0300 = Bid;
   } 
   if (Ii_02F8 == Ii_00A0) { 
   Id_0300 = Bid;
   } 
   Ii_02E0 = Ii_0080;
   Id_02E8 = 0;
   if (Ii_0080 == Ii_006C) { 
   Id_02E8 = LotSize;
   } 
   if (Ii_02E0 == Ii_0070) { 
   Id_02E8 = Id_07A0;
   } 
   if (Ii_02E0 == Ii_0074) { 
   Id_02E8 = Id_07A8;
   } 
   if (Ii_02E0 == Ii_0078) { 
   Id_02E8 = Id_07B0;
   } 
   if (Ii_02E0 == Ii_007C) { 
   Id_02E8 = Id_07B8;
   } 
   if (Ii_02E0 == Ii_0080) { 
   Id_02E8 = Id_07C0;
   } 
   if (Ii_02E0 == Ii_0084) { 
   Id_02E8 = Id_07C0;
   } 
   if (Ii_02E0 == Ii_0088) { 
   Id_02E8 = LotSize;
   } 
   if (Ii_02E0 == Ii_008C) { 
   Id_02E8 = Id_07A0;
   } 
   if (Ii_02E0 == Ii_0090) { 
   Id_02E8 = Id_07A8;
   } 
   if (Ii_02E0 == Ii_0094) { 
   Id_02E8 = Id_07B0;
   } 
   if (Ii_02E0 == Ii_0098) { 
   Id_02E8 = Id_07B8;
   } 
   if (Ii_02E0 == Ii_009C) { 
   Id_02E8 = Id_07C0;
   } 
   if (Ii_02E0 == Ii_00A0) { 
   Id_02E8 = Id_07C0;
   } 
   Ls_FDE0 = "NULL";
   tmp_str0012 = Ls_FE00;
   tmp_str0013 = Ls_FDF0;
   tmp_str0014 = "NULL";
   func_1024(tmp_str0014, 0, Id_02E8, NormalizeDouble(Id_0300, _Digits), tmp_str0013, Ii_0080, tmp_str0012);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) <= 30)) { 
   Ii_0308 = Ii_0080;
   Id_0310 = 0;
   Ii_075C = OrdersTotal() - 1;
   Ii_0318 = Ii_075C;
   if (Ii_075C >= 0) { 
   do { 
   if (OrderSelect(Ii_0318, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0308 == 0 || OrderMagicNumber() == Ii_0308) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FDD0 = OrderSymbol();
   if (Ls_FDD0 == "NULL") { 
   Id_0320 = Bid;
   } 
   else { 
   Id_0320 = MarketInfo(Ls_FDD0, MODE_BID);
   } 
   Id_0310 = ((Id_0320 - OrderOpenPrice()) + Id_0310);
   } 
   else { 
   Id_0768 = OrderOpenPrice();
   Ls_FDC0 = OrderSymbol();
   if (Ls_FDC0 == "NULL") { 
   Id_0328 = Ask;
   } 
   else { 
   Id_0328 = MarketInfo(Ls_FDC0, MODE_ASK);
   } 
   Id_0310 = ((Id_0768 - Id_0328) + Id_0310);
   }}}}} 
   Ii_0318 = Ii_0318 - 1;
   } while (Ii_0318 >= 0); 
   } 
   if (((Id_0310 * Id_00C0) <= -200)) { 
   Id_0768 = ((LotSize + 0.0018) * Id_07D8);
   Id_07E0 = (Id_07D8 * Id_07D8);
   Id_07E8 = (((Id_07E0 * Id_07D8) * Id_07E0) * Id_0768);
   Ls_FDB0 = "Go long 7";
   Ls_FDA0 = "MONEYTREE";
   Ii_0348 = Ii_0084;
   Id_0350 = 0;
   if (Ii_0084 == Ii_006C) { 
   Id_0350 = Ask;
   } 
   if (Ii_0348 == Ii_0070) { 
   Id_0350 = Ask;
   } 
   if (Ii_0348 == Ii_0074) { 
   Id_0350 = Ask;
   } 
   if (Ii_0348 == Ii_0078) { 
   Id_0350 = Ask;
   } 
   if (Ii_0348 == Ii_007C) { 
   Id_0350 = Ask;
   } 
   if (Ii_0348 == Ii_0080) { 
   Id_0350 = Ask;
   } 
   if (Ii_0348 == Ii_0084) { 
   Id_0350 = Ask;
   } 
   if (Ii_0348 == Ii_0088) { 
   Id_0350 = Bid;
   } 
   if (Ii_0348 == Ii_008C) { 
   Id_0350 = Bid;
   } 
   if (Ii_0348 == Ii_0090) { 
   Id_0350 = Bid;
   } 
   if (Ii_0348 == Ii_0094) { 
   Id_0350 = Bid;
   } 
   if (Ii_0348 == Ii_0098) { 
   Id_0350 = Bid;
   } 
   if (Ii_0348 == Ii_009C) { 
   Id_0350 = Bid;
   } 
   if (Ii_0348 == Ii_00A0) { 
   Id_0350 = Bid;
   } 
   Ii_0330 = Ii_0084;
   Id_0338 = 0;
   if (Ii_0084 == Ii_006C) { 
   Id_0338 = LotSize;
   } 
   if (Ii_0330 == Ii_0070) { 
   Id_0338 = Id_07A0;
   } 
   if (Ii_0330 == Ii_0074) { 
   Id_0338 = Id_07A8;
   } 
   if (Ii_0330 == Ii_0078) { 
   Id_0338 = Id_07B0;
   } 
   if (Ii_0330 == Ii_007C) { 
   Id_0338 = Id_07B8;
   } 
   if (Ii_0330 == Ii_0080) { 
   Id_0338 = Id_07C0;
   } 
   if (Ii_0330 == Ii_0084) { 
   Id_0338 = Id_07C0;
   } 
   if (Ii_0330 == Ii_0088) { 
   Id_0338 = LotSize;
   } 
   if (Ii_0330 == Ii_008C) { 
   Id_0338 = Id_07A0;
   } 
   if (Ii_0330 == Ii_0090) { 
   Id_0338 = Id_07A8;
   } 
   if (Ii_0330 == Ii_0094) { 
   Id_0338 = Id_07B0;
   } 
   if (Ii_0330 == Ii_0098) { 
   Id_0338 = Id_07B8;
   } 
   if (Ii_0330 == Ii_009C) { 
   Id_0338 = Id_07C0;
   } 
   if (Ii_0330 == Ii_00A0) { 
   Id_0338 = Id_07C0;
   } 
   Ls_FD90 = "NULL";
   tmp_str0015 = Ls_FDB0;
   tmp_str0016 = Ls_FDA0;
   tmp_str0017 = "NULL";
   func_1024(tmp_str0017, 0, Id_0338, NormalizeDouble(Id_0350, _Digits), tmp_str0016, Ii_0084, tmp_str0015);
   }} 
   returned_double = iMA(NULL, 240, 200, 0, 1, 0, 1);
   Id_07E0 = returned_double;
   if ((returned_double > Close[1])) { 
   Gi_0008 = Ib_0060;
   if (Gi_0008 == 0 && OrdersTotal() < Ii_005C) { 
   Ii_035C = Ii_0088;
   Ii_0360 = 0;
   Ib_0358 = false;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Ii_0360, 0, 0) == true && OrderSymbol() == _Symbol) { 
   if (Ii_035C == 0 || OrderMagicNumber() == Ii_035C) { 
   
   Il_0808 = OrderOpenTime();
   if (Il_0808 > Time[1]) { 
   Ib_0358 = true;
   break; 
   }}} 
   Ii_0360 = Ii_0360 + 1;
   } while (Ii_0360 < OrdersTotal()); 
   } 
   Ii_0360 = HistoryTotal();
   if (Ii_0360 >= 0) {
   do { 
   if (OrderSelect(Ii_0360, 0, 1) == true && OrderSymbol() == _Symbol) {
   if (Ii_035C == 0 || OrderMagicNumber() == Ii_035C) {
   
   Il_0808 = OrderOpenTime();
   if (Il_0808 > Time[1]) {
   Ib_0358 = true;
   break;
   }}}
   Ii_0360 = Ii_0360 - 1;
   } while (Ii_0360 >= 0); 
   }
   else{
   Ib_0358 = false;
   }
   Gi_000A = Ib_0358;
   if (Gi_000A == 0 && (MarketInfo(_Symbol, MODE_SWAPSHORT) >= Ii_0064)) { 
   if ((iRSI(NULL, 240, 14, 0, 1) >= Ii_0044) || (iStochastic(NULL, 240, 50, 3, 3, 0, 0, 0, 1) >= Ii_0054)) { 
   
   Ls_FD80 = "Go short 1";
   Ls_FD70 = "MONEYTREE";
   Ii_0378 = Ii_0088;
   Id_0380 = 0;
   if (Ii_0088 == Ii_006C) { 
   Id_0380 = Ask;
   } 
   if (Ii_0378 == Ii_0070) { 
   Id_0380 = Ask;
   } 
   if (Ii_0378 == Ii_0074) { 
   Id_0380 = Ask;
   } 
   if (Ii_0378 == Ii_0078) { 
   Id_0380 = Ask;
   } 
   if (Ii_0378 == Ii_007C) { 
   Id_0380 = Ask;
   } 
   if (Ii_0378 == Ii_0080) { 
   Id_0380 = Ask;
   } 
   if (Ii_0378 == Ii_0084) { 
   Id_0380 = Ask;
   } 
   if (Ii_0378 == Ii_0088) { 
   Id_0380 = Bid;
   } 
   if (Ii_0378 == Ii_008C) { 
   Id_0380 = Bid;
   } 
   if (Ii_0378 == Ii_0090) { 
   Id_0380 = Bid;
   } 
   if (Ii_0378 == Ii_0094) { 
   Id_0380 = Bid;
   } 
   if (Ii_0378 == Ii_0098) { 
   Id_0380 = Bid;
   } 
   if (Ii_0378 == Ii_009C) { 
   Id_0380 = Bid;
   } 
   if (Ii_0378 == Ii_00A0) { 
   Id_0380 = Bid;
   } 
   Ii_0364 = Ii_0088;
   Id_0368 = 0;
   if (Ii_0088 == Ii_006C) { 
   Id_0368 = LotSize;
   } 
   if (Ii_0364 == Ii_0070) { 
   Id_0368 = Id_07A0;
   } 
   if (Ii_0364 == Ii_0074) { 
   Id_0368 = Id_07A8;
   } 
   if (Ii_0364 == Ii_0078) { 
   Id_0368 = Id_07B0;
   } 
   if (Ii_0364 == Ii_007C) { 
   Id_0368 = Id_07B8;
   } 
   if (Ii_0364 == Ii_0080) { 
   Id_0368 = Id_07C0;
   } 
   if (Ii_0364 == Ii_0084) { 
   Id_0368 = Id_07C0;
   } 
   if (Ii_0364 == Ii_0088) { 
   Id_0368 = LotSize;
   } 
   if (Ii_0364 == Ii_008C) { 
   Id_0368 = Id_07A0;
   } 
   if (Ii_0364 == Ii_0090) { 
   Id_0368 = Id_07A8;
   } 
   if (Ii_0364 == Ii_0094) { 
   Id_0368 = Id_07B0;
   } 
   if (Ii_0364 == Ii_0098) { 
   Id_0368 = Id_07B8;
   } 
   if (Ii_0364 == Ii_009C) { 
   Id_0368 = Id_07C0;
   } 
   if (Ii_0364 == Ii_00A0) { 
   Id_0368 = Id_07C0;
   } 
   Ls_FD60 = "NULL";
   tmp_str0018 = Ls_FD80;
   tmp_str0019 = Ls_FD70;
   tmp_str001A = "NULL";
   func_1024(tmp_str001A, 1, Id_0368, NormalizeDouble(Id_0380, _Digits), tmp_str0019, Ii_0088, tmp_str0018);
   }}}} 
   returned_double = iMA(NULL, 240, 200, 0, 1, 0, 1);
   Id_07E0 = returned_double;
   if ((returned_double > Close[1]) && Ib_0060 == true && OrdersTotal() < Ii_005C && (MarketInfo(_Symbol, MODE_SWAPSHORT) >= Ii_0064)) { 
   if ((iRSI(NULL, 240, 14, 0, 1) >= Ii_0044) || (iStochastic(NULL, 240, 50, 3, 3, 0, 0, 0, 1) >= Ii_0054)) { 
   
   Ls_FD50 = "Go short 1";
   Ls_FD40 = "MONEYTREE";
   Ii_03A0 = Ii_0088;
   Id_03A8 = 0;
   if (Ii_0088 == Ii_006C) { 
   Id_03A8 = Ask;
   } 
   if (Ii_03A0 == Ii_0070) { 
   Id_03A8 = Ask;
   } 
   if (Ii_03A0 == Ii_0074) { 
   Id_03A8 = Ask;
   } 
   if (Ii_03A0 == Ii_0078) { 
   Id_03A8 = Ask;
   } 
   if (Ii_03A0 == Ii_007C) { 
   Id_03A8 = Ask;
   } 
   if (Ii_03A0 == Ii_0080) { 
   Id_03A8 = Ask;
   } 
   if (Ii_03A0 == Ii_0084) { 
   Id_03A8 = Ask;
   } 
   if (Ii_03A0 == Ii_0088) { 
   Id_03A8 = Bid;
   } 
   if (Ii_03A0 == Ii_008C) { 
   Id_03A8 = Bid;
   } 
   if (Ii_03A0 == Ii_0090) { 
   Id_03A8 = Bid;
   } 
   if (Ii_03A0 == Ii_0094) { 
   Id_03A8 = Bid;
   } 
   if (Ii_03A0 == Ii_0098) { 
   Id_03A8 = Bid;
   } 
   if (Ii_03A0 == Ii_009C) { 
   Id_03A8 = Bid;
   } 
   if (Ii_03A0 == Ii_00A0) { 
   Id_03A8 = Bid;
   } 
   Ii_0388 = Ii_0088;
   Id_0390 = 0;
   if (Ii_0088 == Ii_006C) { 
   Id_0390 = LotSize;
   } 
   if (Ii_0388 == Ii_0070) { 
   Id_0390 = Id_07A0;
   } 
   if (Ii_0388 == Ii_0074) { 
   Id_0390 = Id_07A8;
   } 
   if (Ii_0388 == Ii_0078) { 
   Id_0390 = Id_07B0;
   } 
   if (Ii_0388 == Ii_007C) { 
   Id_0390 = Id_07B8;
   } 
   if (Ii_0388 == Ii_0080) { 
   Id_0390 = Id_07C0;
   } 
   if (Ii_0388 == Ii_0084) { 
   Id_0390 = Id_07C0;
   } 
   if (Ii_0388 == Ii_0088) { 
   Id_0390 = LotSize;
   } 
   if (Ii_0388 == Ii_008C) { 
   Id_0390 = Id_07A0;
   } 
   if (Ii_0388 == Ii_0090) { 
   Id_0390 = Id_07A8;
   } 
   if (Ii_0388 == Ii_0094) { 
   Id_0390 = Id_07B0;
   } 
   if (Ii_0388 == Ii_0098) { 
   Id_0390 = Id_07B8;
   } 
   if (Ii_0388 == Ii_009C) { 
   Id_0390 = Id_07C0;
   } 
   if (Ii_0388 == Ii_00A0) { 
   Id_0390 = Id_07C0;
   } 
   Ls_FD30 = "NULL";
   tmp_str001B = Ls_FD50;
   tmp_str001C = Ls_FD40;
   tmp_str001D = "NULL";
   func_1024(tmp_str001D, 1, Id_0390, NormalizeDouble(Id_03A8, _Digits), tmp_str001C, Ii_0088, tmp_str001B);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Ii_03B0 = Ii_0088;
   Id_03B8 = 0;
   Ii_07F0 = OrdersTotal() - 1;
   Ii_03C0 = Ii_07F0;
   if (Ii_07F0 >= 0) { 
   do { 
   if (OrderSelect(Ii_03C0, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_03B0 == 0 || OrderMagicNumber() == Ii_03B0) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FD20 = OrderSymbol();
   if (Ls_FD20 == "NULL") { 
   Id_03C8 = Bid;
   } 
   else { 
   Id_03C8 = MarketInfo(Ls_FD20, MODE_BID);
   } 
   Id_03B8 = ((Id_03C8 - OrderOpenPrice()) + Id_03B8);
   } 
   else { 
   Id_07E0 = OrderOpenPrice();
   Ls_FD10 = OrderSymbol();
   if (Ls_FD10 == "NULL") { 
   Id_03D0 = Ask;
   } 
   else { 
   Id_03D0 = MarketInfo(Ls_FD10, MODE_ASK);
   } 
   Id_03B8 = ((Id_07E0 - Id_03D0) + Id_03B8);
   }}}}} 
   Ii_03C0 = Ii_03C0 - 1;
   } while (Ii_03C0 >= 0); 
   } 
   if (((Id_03B8 * Id_00C0) <= -70)) { 
   Id_07A0 = ((LotSize + 0.0018) * Id_07D8);
   Ls_FD00 = "Go short 2";
   Ls_FCF0 = "MONEYTREE";
   Ii_03F0 = Ii_008C;
   Id_03F8 = 0;
   if (Ii_008C == Ii_006C) { 
   Id_03F8 = Ask;
   } 
   if (Ii_03F0 == Ii_0070) { 
   Id_03F8 = Ask;
   } 
   if (Ii_03F0 == Ii_0074) { 
   Id_03F8 = Ask;
   } 
   if (Ii_03F0 == Ii_0078) { 
   Id_03F8 = Ask;
   } 
   if (Ii_03F0 == Ii_007C) { 
   Id_03F8 = Ask;
   } 
   if (Ii_03F0 == Ii_0080) { 
   Id_03F8 = Ask;
   } 
   if (Ii_03F0 == Ii_0084) { 
   Id_03F8 = Ask;
   } 
   if (Ii_03F0 == Ii_0088) { 
   Id_03F8 = Bid;
   } 
   if (Ii_03F0 == Ii_008C) { 
   Id_03F8 = Bid;
   } 
   if (Ii_03F0 == Ii_0090) { 
   Id_03F8 = Bid;
   } 
   if (Ii_03F0 == Ii_0094) { 
   Id_03F8 = Bid;
   } 
   if (Ii_03F0 == Ii_0098) { 
   Id_03F8 = Bid;
   } 
   if (Ii_03F0 == Ii_009C) { 
   Id_03F8 = Bid;
   } 
   if (Ii_03F0 == Ii_00A0) { 
   Id_03F8 = Bid;
   } 
   Ii_03D8 = Ii_008C;
   Id_03E0 = 0;
   if (Ii_008C == Ii_006C) { 
   Id_03E0 = LotSize;
   } 
   if (Ii_03D8 == Ii_0070) { 
   Id_03E0 = Id_07A0;
   } 
   if (Ii_03D8 == Ii_0074) { 
   Id_03E0 = Id_07A8;
   } 
   if (Ii_03D8 == Ii_0078) { 
   Id_03E0 = Id_07B0;
   } 
   if (Ii_03D8 == Ii_007C) { 
   Id_03E0 = Id_07B8;
   } 
   if (Ii_03D8 == Ii_0080) { 
   Id_03E0 = Id_07C0;
   } 
   if (Ii_03D8 == Ii_0084) { 
   Id_03E0 = Id_07C0;
   } 
   if (Ii_03D8 == Ii_0088) { 
   Id_03E0 = LotSize;
   } 
   if (Ii_03D8 == Ii_008C) { 
   Id_03E0 = Id_07A0;
   } 
   if (Ii_03D8 == Ii_0090) { 
   Id_03E0 = Id_07A8;
   } 
   if (Ii_03D8 == Ii_0094) { 
   Id_03E0 = Id_07B0;
   } 
   if (Ii_03D8 == Ii_0098) { 
   Id_03E0 = Id_07B8;
   } 
   if (Ii_03D8 == Ii_009C) { 
   Id_03E0 = Id_07C0;
   } 
   if (Ii_03D8 == Ii_00A0) { 
   Id_03E0 = Id_07C0;
   } 
   Ls_FCE0 = "NULL";
   tmp_str001E = Ls_FD00;
   tmp_str001F = Ls_FCF0;
   tmp_str0020 = "NULL";
   func_1024(tmp_str0020, 1, Id_03E0, NormalizeDouble(Id_03F8, _Digits), tmp_str001F, Ii_008C, tmp_str001E);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Ii_0400 = Ii_008C;
   Id_0408 = 0;
   Ii_07F0 = OrdersTotal() - 1;
   Ii_0410 = Ii_07F0;
   if (Ii_07F0 >= 0) { 
   do { 
   if (OrderSelect(Ii_0410, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0400 == 0 || OrderMagicNumber() == Ii_0400) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FCD0 = OrderSymbol();
   if (Ls_FCD0 == "NULL") { 
   Id_0418 = Bid;
   } 
   else { 
   Id_0418 = MarketInfo(Ls_FCD0, MODE_BID);
   } 
   Id_0408 = ((Id_0418 - OrderOpenPrice()) + Id_0408);
   } 
   else { 
   Id_07E0 = OrderOpenPrice();
   Ls_FCC0 = OrderSymbol();
   if (Ls_FCC0 == "NULL") { 
   Id_0420 = Ask;
   } 
   else { 
   Id_0420 = MarketInfo(Ls_FCC0, MODE_ASK);
   } 
   Id_0408 = ((Id_07E0 - Id_0420) + Id_0408);
   }}}}} 
   Ii_0410 = Ii_0410 - 1;
   } while (Ii_0410 >= 0); 
   } 
   if (((Id_0408 * Id_00C0) <= -120)) { 
   Id_07E0 = (LotSize + 0.0018);
   Id_07A8 = ((Id_07D8 * Id_07D8) * Id_07E0);
   Ls_FCB0 = "Go short 3";
   Ls_FCA0 = "MONEYTREE";
   Ii_0440 = Ii_0090;
   Id_0448 = 0;
   if (Ii_0090 == Ii_006C) { 
   Id_0448 = Ask;
   } 
   if (Ii_0440 == Ii_0070) { 
   Id_0448 = Ask;
   } 
   if (Ii_0440 == Ii_0074) { 
   Id_0448 = Ask;
   } 
   if (Ii_0440 == Ii_0078) { 
   Id_0448 = Ask;
   } 
   if (Ii_0440 == Ii_007C) { 
   Id_0448 = Ask;
   } 
   if (Ii_0440 == Ii_0080) { 
   Id_0448 = Ask;
   } 
   if (Ii_0440 == Ii_0084) { 
   Id_0448 = Ask;
   } 
   if (Ii_0440 == Ii_0088) { 
   Id_0448 = Bid;
   } 
   if (Ii_0440 == Ii_008C) { 
   Id_0448 = Bid;
   } 
   if (Ii_0440 == Ii_0090) { 
   Id_0448 = Bid;
   } 
   if (Ii_0440 == Ii_0094) { 
   Id_0448 = Bid;
   } 
   if (Ii_0440 == Ii_0098) { 
   Id_0448 = Bid;
   } 
   if (Ii_0440 == Ii_009C) { 
   Id_0448 = Bid;
   } 
   if (Ii_0440 == Ii_00A0) { 
   Id_0448 = Bid;
   } 
   Ii_0428 = Ii_0090;
   Id_0430 = 0;
   if (Ii_0090 == Ii_006C) { 
   Id_0430 = LotSize;
   } 
   if (Ii_0428 == Ii_0070) { 
   Id_0430 = Id_07A0;
   } 
   if (Ii_0428 == Ii_0074) { 
   Id_0430 = Id_07A8;
   } 
   if (Ii_0428 == Ii_0078) { 
   Id_0430 = Id_07B0;
   } 
   if (Ii_0428 == Ii_007C) { 
   Id_0430 = Id_07B8;
   } 
   if (Ii_0428 == Ii_0080) { 
   Id_0430 = Id_07C0;
   } 
   if (Ii_0428 == Ii_0084) { 
   Id_0430 = Id_07C0;
   } 
   if (Ii_0428 == Ii_0088) { 
   Id_0430 = LotSize;
   } 
   if (Ii_0428 == Ii_008C) { 
   Id_0430 = Id_07A0;
   } 
   if (Ii_0428 == Ii_0090) { 
   Id_0430 = Id_07A8;
   } 
   if (Ii_0428 == Ii_0094) { 
   Id_0430 = Id_07B0;
   } 
   if (Ii_0428 == Ii_0098) { 
   Id_0430 = Id_07B8;
   } 
   if (Ii_0428 == Ii_009C) { 
   Id_0430 = Id_07C0;
   } 
   if (Ii_0428 == Ii_00A0) { 
   Id_0430 = Id_07C0;
   } 
   Ls_FC90 = "NULL";
   tmp_str0021 = Ls_FCB0;
   tmp_str0022 = Ls_FCA0;
   tmp_str0023 = "NULL";
   func_1024(tmp_str0023, 1, Id_0430, NormalizeDouble(Id_0448, _Digits), tmp_str0022, Ii_0090, tmp_str0021);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Ii_0450 = Ii_0090;
   Id_0458 = 0;
   Ii_07F0 = OrdersTotal() - 1;
   Ii_0460 = Ii_07F0;
   if (Ii_07F0 >= 0) { 
   do { 
   if (OrderSelect(Ii_0460, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0450 == 0 || OrderMagicNumber() == Ii_0450) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FC80 = OrderSymbol();
   if (Ls_FC80 == "NULL") { 
   Id_0468 = Bid;
   } 
   else { 
   Id_0468 = MarketInfo(Ls_FC80, MODE_BID);
   } 
   Id_0458 = ((Id_0468 - OrderOpenPrice()) + Id_0458);
   } 
   else { 
   Id_07E0 = OrderOpenPrice();
   Ls_FC70 = OrderSymbol();
   if (Ls_FC70 == "NULL") { 
   Id_0470 = Ask;
   } 
   else { 
   Id_0470 = MarketInfo(Ls_FC70, MODE_ASK);
   } 
   Id_0458 = ((Id_07E0 - Id_0470) + Id_0458);
   }}}}} 
   Ii_0460 = Ii_0460 - 1;
   } while (Ii_0460 >= 0); 
   } 
   if (((Id_0458 * Id_00C0) <= -150)) { 
   Id_07E0 = (LotSize + 0.0018);
   Id_07B0 = (((Id_07D8 * Id_07D8) * Id_07D8) * Id_07E0);
   Ls_FC60 = "go short 4";
   Ls_FC50 = "MONEYTREE";
   Ii_0490 = Ii_0094;
   Id_0498 = 0;
   if (Ii_0094 == Ii_006C) { 
   Id_0498 = Ask;
   } 
   if (Ii_0490 == Ii_0070) { 
   Id_0498 = Ask;
   } 
   if (Ii_0490 == Ii_0074) { 
   Id_0498 = Ask;
   } 
   if (Ii_0490 == Ii_0078) { 
   Id_0498 = Ask;
   } 
   if (Ii_0490 == Ii_007C) { 
   Id_0498 = Ask;
   } 
   if (Ii_0490 == Ii_0080) { 
   Id_0498 = Ask;
   } 
   if (Ii_0490 == Ii_0084) { 
   Id_0498 = Ask;
   } 
   if (Ii_0490 == Ii_0088) { 
   Id_0498 = Bid;
   } 
   if (Ii_0490 == Ii_008C) { 
   Id_0498 = Bid;
   } 
   if (Ii_0490 == Ii_0090) { 
   Id_0498 = Bid;
   } 
   if (Ii_0490 == Ii_0094) { 
   Id_0498 = Bid;
   } 
   if (Ii_0490 == Ii_0098) { 
   Id_0498 = Bid;
   } 
   if (Ii_0490 == Ii_009C) { 
   Id_0498 = Bid;
   } 
   if (Ii_0490 == Ii_00A0) { 
   Id_0498 = Bid;
   } 
   Ii_0478 = Ii_0094;
   Id_0480 = 0;
   if (Ii_0094 == Ii_006C) { 
   Id_0480 = LotSize;
   } 
   if (Ii_0478 == Ii_0070) { 
   Id_0480 = Id_07A0;
   } 
   if (Ii_0478 == Ii_0074) { 
   Id_0480 = Id_07A8;
   } 
   if (Ii_0478 == Ii_0078) { 
   Id_0480 = Id_07B0;
   } 
   if (Ii_0478 == Ii_007C) { 
   Id_0480 = Id_07B8;
   } 
   if (Ii_0478 == Ii_0080) { 
   Id_0480 = Id_07C0;
   } 
   if (Ii_0478 == Ii_0084) { 
   Id_0480 = Id_07C0;
   } 
   if (Ii_0478 == Ii_0088) { 
   Id_0480 = LotSize;
   } 
   if (Ii_0478 == Ii_008C) { 
   Id_0480 = Id_07A0;
   } 
   if (Ii_0478 == Ii_0090) { 
   Id_0480 = Id_07A8;
   } 
   if (Ii_0478 == Ii_0094) { 
   Id_0480 = Id_07B0;
   } 
   if (Ii_0478 == Ii_0098) { 
   Id_0480 = Id_07B8;
   } 
   if (Ii_0478 == Ii_009C) { 
   Id_0480 = Id_07C0;
   } 
   if (Ii_0478 == Ii_00A0) { 
   Id_0480 = Id_07C0;
   } 
   Ls_FC40 = "NULL";
   tmp_str0024 = Ls_FC60;
   tmp_str0025 = Ls_FC50;
   tmp_str0026 = "NULL";
   func_1024(tmp_str0026, 1, Id_0480, NormalizeDouble(Id_0498, _Digits), tmp_str0025, Ii_0094, tmp_str0024);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Ii_04A0 = Ii_0094;
   Id_04A8 = 0;
   Ii_07F0 = OrdersTotal() - 1;
   Ii_04B0 = Ii_07F0;
   if (Ii_07F0 >= 0) { 
   do { 
   if (OrderSelect(Ii_04B0, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_04A0 == 0 || OrderMagicNumber() == Ii_04A0) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FC30 = OrderSymbol();
   if (Ls_FC30 == "NULL") { 
   Id_04B8 = Bid;
   } 
   else { 
   Id_04B8 = MarketInfo(Ls_FC30, MODE_BID);
   } 
   Id_04A8 = ((Id_04B8 - OrderOpenPrice()) + Id_04A8);
   } 
   else { 
   Id_07E0 = OrderOpenPrice();
   Ls_FC20 = OrderSymbol();
   if (Ls_FC20 == "NULL") { 
   Id_04C0 = Ask;
   } 
   else { 
   Id_04C0 = MarketInfo(Ls_FC20, MODE_ASK);
   } 
   Id_04A8 = ((Id_07E0 - Id_04C0) + Id_04A8);
   }}}}} 
   Ii_04B0 = Ii_04B0 - 1;
   } while (Ii_04B0 >= 0); 
   } 
   if (((Id_04A8 * Id_00C0) <= -200)) { 
   Id_07E0 = (LotSize + 0.0018);
   Id_07B8 = (((Id_07D8 * Id_07D8) * (Id_07D8 * Id_07D8)) * Id_07E0);
   Ls_FC10 = "go short 5";
   Ls_FC00 = "MONEYTREE";
   Ii_04E0 = Ii_0098;
   Id_04E8 = 0;
   if (Ii_0098 == Ii_006C) { 
   Id_04E8 = Ask;
   } 
   if (Ii_04E0 == Ii_0070) { 
   Id_04E8 = Ask;
   } 
   if (Ii_04E0 == Ii_0074) { 
   Id_04E8 = Ask;
   } 
   if (Ii_04E0 == Ii_0078) { 
   Id_04E8 = Ask;
   } 
   if (Ii_04E0 == Ii_007C) { 
   Id_04E8 = Ask;
   } 
   if (Ii_04E0 == Ii_0080) { 
   Id_04E8 = Ask;
   } 
   if (Ii_04E0 == Ii_0084) { 
   Id_04E8 = Ask;
   } 
   if (Ii_04E0 == Ii_0088) { 
   Id_04E8 = Bid;
   } 
   if (Ii_04E0 == Ii_008C) { 
   Id_04E8 = Bid;
   } 
   if (Ii_04E0 == Ii_0090) { 
   Id_04E8 = Bid;
   } 
   if (Ii_04E0 == Ii_0094) { 
   Id_04E8 = Bid;
   } 
   if (Ii_04E0 == Ii_0098) { 
   Id_04E8 = Bid;
   } 
   if (Ii_04E0 == Ii_009C) { 
   Id_04E8 = Bid;
   } 
   if (Ii_04E0 == Ii_00A0) { 
   Id_04E8 = Bid;
   } 
   Ii_04C8 = Ii_0098;
   Id_04D0 = 0;
   if (Ii_0098 == Ii_006C) { 
   Id_04D0 = LotSize;
   } 
   if (Ii_04C8 == Ii_0070) { 
   Id_04D0 = Id_07A0;
   } 
   if (Ii_04C8 == Ii_0074) { 
   Id_04D0 = Id_07A8;
   } 
   if (Ii_04C8 == Ii_0078) { 
   Id_04D0 = Id_07B0;
   } 
   if (Ii_04C8 == Ii_007C) { 
   Id_04D0 = Id_07B8;
   } 
   if (Ii_04C8 == Ii_0080) { 
   Id_04D0 = Id_07C0;
   } 
   if (Ii_04C8 == Ii_0084) { 
   Id_04D0 = Id_07C0;
   } 
   if (Ii_04C8 == Ii_0088) { 
   Id_04D0 = LotSize;
   } 
   if (Ii_04C8 == Ii_008C) { 
   Id_04D0 = Id_07A0;
   } 
   if (Ii_04C8 == Ii_0090) { 
   Id_04D0 = Id_07A8;
   } 
   if (Ii_04C8 == Ii_0094) { 
   Id_04D0 = Id_07B0;
   } 
   if (Ii_04C8 == Ii_0098) { 
   Id_04D0 = Id_07B8;
   } 
   if (Ii_04C8 == Ii_009C) { 
   Id_04D0 = Id_07C0;
   } 
   if (Ii_04C8 == Ii_00A0) { 
   Id_04D0 = Id_07C0;
   } 
   Ls_FBF0 = "NULL";
   tmp_str0027 = Ls_FC10;
   tmp_str0028 = Ls_FC00;
   tmp_str0029 = "NULL";
   func_1024(tmp_str0029, 1, Id_04D0, NormalizeDouble(Id_04E8, _Digits), tmp_str0028, Ii_0098, tmp_str0027);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Ii_04F0 = Ii_0098;
   Id_04F8 = 0;
   Ii_07F0 = OrdersTotal() - 1;
   Ii_0500 = Ii_07F0;
   if (Ii_07F0 >= 0) { 
   do { 
   if (OrderSelect(Ii_0500, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_04F0 == 0 || OrderMagicNumber() == Ii_04F0) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FBE0 = OrderSymbol();
   if (Ls_FBE0 == "NULL") { 
   Id_0508 = Bid;
   } 
   else { 
   Id_0508 = MarketInfo(Ls_FBE0, MODE_BID);
   } 
   Id_04F8 = ((Id_0508 - OrderOpenPrice()) + Id_04F8);
   } 
   else { 
   Id_07E0 = OrderOpenPrice();
   Ls_FBD0 = OrderSymbol();
   if (Ls_FBD0 == "NULL") { 
   Id_0510 = Ask;
   } 
   else { 
   Id_0510 = MarketInfo(Ls_FBD0, MODE_ASK);
   } 
   Id_04F8 = ((Id_07E0 - Id_0510) + Id_04F8);
   }}}}} 
   Ii_0500 = Ii_0500 - 1;
   } while (Ii_0500 >= 0); 
   } 
   if (((Id_04F8 * Id_00C0) <= -200)) { 
   Id_07E0 = (LotSize + 0.0018);
   Id_0830 = (Id_07D8 * Id_07D8);
   Id_07C0 = (((Id_0830 * Id_07D8) * Id_0830) * Id_07E0);
   Ls_FBC0 = "go short 6";
   Ls_FBB0 = "MONEYTREE";
   Ii_0530 = Ii_009C;
   Id_0538 = 0;
   if (Ii_009C == Ii_006C) { 
   Id_0538 = Ask;
   } 
   if (Ii_0530 == Ii_0070) { 
   Id_0538 = Ask;
   } 
   if (Ii_0530 == Ii_0074) { 
   Id_0538 = Ask;
   } 
   if (Ii_0530 == Ii_0078) { 
   Id_0538 = Ask;
   } 
   if (Ii_0530 == Ii_007C) { 
   Id_0538 = Ask;
   } 
   if (Ii_0530 == Ii_0080) { 
   Id_0538 = Ask;
   } 
   if (Ii_0530 == Ii_0084) { 
   Id_0538 = Ask;
   } 
   if (Ii_0530 == Ii_0088) { 
   Id_0538 = Bid;
   } 
   if (Ii_0530 == Ii_008C) { 
   Id_0538 = Bid;
   } 
   if (Ii_0530 == Ii_0090) { 
   Id_0538 = Bid;
   } 
   if (Ii_0530 == Ii_0094) { 
   Id_0538 = Bid;
   } 
   if (Ii_0530 == Ii_0098) { 
   Id_0538 = Bid;
   } 
   if (Ii_0530 == Ii_009C) { 
   Id_0538 = Bid;
   } 
   if (Ii_0530 == Ii_00A0) { 
   Id_0538 = Bid;
   } 
   Ii_0518 = Ii_009C;
   Id_0520 = 0;
   if (Ii_009C == Ii_006C) { 
   Id_0520 = LotSize;
   } 
   if (Ii_0518 == Ii_0070) { 
   Id_0520 = Id_07A0;
   } 
   if (Ii_0518 == Ii_0074) { 
   Id_0520 = Id_07A8;
   } 
   if (Ii_0518 == Ii_0078) { 
   Id_0520 = Id_07B0;
   } 
   if (Ii_0518 == Ii_007C) { 
   Id_0520 = Id_07B8;
   } 
   if (Ii_0518 == Ii_0080) { 
   Id_0520 = Id_07C0;
   } 
   if (Ii_0518 == Ii_0084) { 
   Id_0520 = Id_07C0;
   } 
   if (Ii_0518 == Ii_0088) { 
   Id_0520 = LotSize;
   } 
   if (Ii_0518 == Ii_008C) { 
   Id_0520 = Id_07A0;
   } 
   if (Ii_0518 == Ii_0090) { 
   Id_0520 = Id_07A8;
   } 
   if (Ii_0518 == Ii_0094) { 
   Id_0520 = Id_07B0;
   } 
   if (Ii_0518 == Ii_0098) { 
   Id_0520 = Id_07B8;
   } 
   if (Ii_0518 == Ii_009C) { 
   Id_0520 = Id_07C0;
   } 
   if (Ii_0518 == Ii_00A0) { 
   Id_0520 = Id_07C0;
   } 
   Ls_FBA0 = "NULL";
   tmp_str002A = Ls_FBC0;
   tmp_str002B = Ls_FBB0;
   tmp_str002C = "NULL";
   func_1024(tmp_str002C, 1, Id_0520, NormalizeDouble(Id_0538, _Digits), tmp_str002B, Ii_009C, tmp_str002A);
   }} 
   if ((iRSI(NULL, 240, 14, 0, 1) >= 70)) { 
   Ii_0540 = Ii_009C;
   Id_0548 = 0;
   Ii_0838 = OrdersTotal() - 1;
   Ii_0550 = Ii_0838;
   if (Ii_0838 >= 0) { 
   do { 
   if (OrderSelect(Ii_0550, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0540 == 0 || OrderMagicNumber() == Ii_0540) {
   
   if (OrderType() == OP_BUY) { 
   Ls_FB90 = OrderSymbol();
   if (Ls_FB90 == "NULL") { 
   Id_0558 = Bid;
   } 
   else { 
   Id_0558 = MarketInfo(Ls_FB90, MODE_BID);
   } 
   Id_0548 = ((Id_0558 - OrderOpenPrice()) + Id_0548);
   } 
   else { 
   Id_0830 = OrderOpenPrice();
   Ls_FB80 = OrderSymbol();
   if (Ls_FB80 == "NULL") { 
   Id_0560 = Ask;
   } 
   else { 
   Id_0560 = MarketInfo(Ls_FB80, MODE_ASK);
   } 
   Id_0548 = ((Id_0830 - Id_0560) + Id_0548);
   }}}}} 
   Ii_0550 = Ii_0550 - 1;
   } while (Ii_0550 >= 0); 
   } 
   if (((Id_0548 * Id_00C0) <= -200)) { 
   Id_0830 = (LotSize + 0.0018);
   Id_0840 = (Id_07D8 * Id_07D8);
   Id_07E8 = (((Id_0840 * Id_0840) * Id_0840) * Id_0830);
   Ls_FB70 = "go short 7";
   Ls_FB60 = "MONEYTREE";
   Ii_0580 = Ii_00A0;
   Id_0588 = 0;
   if (Ii_00A0 == Ii_006C) { 
   Id_0588 = Ask;
   } 
   if (Ii_0580 == Ii_0070) { 
   Id_0588 = Ask;
   } 
   if (Ii_0580 == Ii_0074) { 
   Id_0588 = Ask;
   } 
   if (Ii_0580 == Ii_0078) { 
   Id_0588 = Ask;
   } 
   if (Ii_0580 == Ii_007C) { 
   Id_0588 = Ask;
   } 
   if (Ii_0580 == Ii_0080) { 
   Id_0588 = Ask;
   } 
   if (Ii_0580 == Ii_0084) { 
   Id_0588 = Ask;
   } 
   if (Ii_0580 == Ii_0088) { 
   Id_0588 = Bid;
   } 
   if (Ii_0580 == Ii_008C) { 
   Id_0588 = Bid;
   } 
   if (Ii_0580 == Ii_0090) { 
   Id_0588 = Bid;
   } 
   if (Ii_0580 == Ii_0094) { 
   Id_0588 = Bid;
   } 
   if (Ii_0580 == Ii_0098) { 
   Id_0588 = Bid;
   } 
   if (Ii_0580 == Ii_009C) { 
   Id_0588 = Bid;
   } 
   if (Ii_0580 == Ii_00A0) { 
   Id_0588 = Bid;
   } 
   Ii_0568 = Ii_00A0;
   Id_0570 = 0;
   if (Ii_00A0 == Ii_006C) { 
   Id_0570 = LotSize;
   } 
   if (Ii_0568 == Ii_0070) { 
   Id_0570 = Id_07A0;
   } 
   if (Ii_0568 == Ii_0074) { 
   Id_0570 = Id_07A8;
   } 
   if (Ii_0568 == Ii_0078) { 
   Id_0570 = Id_07B0;
   } 
   if (Ii_0568 == Ii_007C) { 
   Id_0570 = Id_07B8;
   } 
   if (Ii_0568 == Ii_0080) { 
   Id_0570 = Id_07C0;
   } 
   if (Ii_0568 == Ii_0084) { 
   Id_0570 = Id_07C0;
   } 
   if (Ii_0568 == Ii_0088) { 
   Id_0570 = LotSize;
   } 
   if (Ii_0568 == Ii_008C) { 
   Id_0570 = Id_07A0;
   } 
   if (Ii_0568 == Ii_0090) { 
   Id_0570 = Id_07A8;
   } 
   if (Ii_0568 == Ii_0094) { 
   Id_0570 = Id_07B0;
   } 
   if (Ii_0568 == Ii_0098) { 
   Id_0570 = Id_07B8;
   } 
   if (Ii_0568 == Ii_009C) { 
   Id_0570 = Id_07C0;
   } 
   if (Ii_0568 == Ii_00A0) { 
   Id_0570 = Id_07C0;
   } 
   Ls_FB50 = "NULL";
   tmp_str002D = Ls_FB70;
   tmp_str002E = Ls_FB60;
   tmp_str002F = "NULL";
   func_1024(tmp_str002F, 1, Id_0570, NormalizeDouble(Id_0588, _Digits), tmp_str002E, Ii_00A0, tmp_str002D);
   }} 
   Id_0840 = AccountBalance();
   Id_0840 = (Id_0840 - AccountEquity());
   Id_0850 = (AccountBalance() * Ii_0050);
   if ((Id_0840 >= (Id_0850 / 100))) { 
   func_1021(Ii_006C);
   func_1021(Ii_0070);
   func_1021(Ii_0074);
   func_1021(Ii_0078);
   func_1021(Ii_007C);
   func_1021(Ii_0080);
   func_1021(Ii_0084);
   func_1021(Ii_0088);
   func_1021(Ii_008C);
   func_1021(Ii_0090);
   func_1021(Ii_0094);
   func_1021(Ii_0098);
   func_1021(Ii_009C);
   func_1021(Ii_00A0);
   } 
   Ii_0598 = Ii_006C;
   Id_05A0 = 0;
   Ii_085C = OrdersTotal() - 1;
   Ii_05A8 = Ii_085C;
   if (Ii_085C >= 0) { 
   do { 
   if (OrderSelect(Ii_05A8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0598 == 0 || OrderMagicNumber() == Ii_0598) { 
   
   Id_05A0 = (Id_05A0 + OrderProfit());
   }}}} 
   Ii_05A8 = Ii_05A8 - 1;
   } while (Ii_05A8 >= 0); 
   } 
   Id_0590 = Id_05A0;
   Ii_05AC = Ii_0070;
   Id_05B0 = 0;
   Ii_085C = OrdersTotal() - 1;
   Ii_05B8 = Ii_085C;
   if (Ii_085C >= 0) { 
   do { 
   if (OrderSelect(Ii_05B8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_05AC == 0 || OrderMagicNumber() == Ii_05AC) { 
   
   Id_05B0 = (Id_05B0 + OrderProfit());
   }}}} 
   Ii_05B8 = Ii_05B8 - 1;
   } while (Ii_05B8 >= 0); 
   } 
   Id_0850 = (Id_0590 + Id_05B0);
   Ii_05C8 = Ii_0074;
   Id_05D0 = 0;
   Ii_0860 = OrdersTotal() - 1;
   Ii_05D8 = Ii_0860;
   if (Ii_0860 >= 0) { 
   do { 
   if (OrderSelect(Ii_05D8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_05C8 == 0 || OrderMagicNumber() == Ii_05C8) { 
   
   Id_05D0 = (Id_05D0 + OrderProfit());
   }}}} 
   Ii_05D8 = Ii_05D8 - 1;
   } while (Ii_05D8 >= 0); 
   } 
   Id_05C0 = Id_05D0;
   Ii_05DC = Ii_0078;
   Id_05E0 = 0;
   Ii_0860 = OrdersTotal() - 1;
   Ii_05E8 = Ii_0860;
   if (Ii_0860 >= 0) { 
   do { 
   if (OrderSelect(Ii_05E8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_05DC == 0 || OrderMagicNumber() == Ii_05DC) { 
   
   Id_05E0 = (Id_05E0 + OrderProfit());
   }}}} 
   Ii_05E8 = Ii_05E8 - 1;
   } while (Ii_05E8 >= 0); 
   } 
   Id_0868 = ((Id_05C0 + Id_05E0) + Id_0850);
   Ii_05F8 = Ii_007C;
   Id_0600 = 0;
   Ii_0870 = OrdersTotal() - 1;
   Ii_0608 = Ii_0870;
   if (Ii_0870 >= 0) { 
   do { 
   if (OrderSelect(Ii_0608, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_05F8 == 0 || OrderMagicNumber() == Ii_05F8) { 
   
   Id_0600 = (Id_0600 + OrderProfit());
   }}}} 
   Ii_0608 = Ii_0608 - 1;
   } while (Ii_0608 >= 0); 
   } 
   Id_05F0 = Id_0600;
   Ii_0618 = Ii_0080;
   Id_0620 = 0;
   Ii_0870 = OrdersTotal() - 1;
   Ii_0628 = Ii_0870;
   if (Ii_0870 >= 0) { 
   do { 
   if (OrderSelect(Ii_0628, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0618 == 0 || OrderMagicNumber() == Ii_0618) { 
   
   Id_0620 = (Id_0620 + OrderProfit());
   }}}} 
   Ii_0628 = Ii_0628 - 1;
   } while (Ii_0628 >= 0); 
   } 
   Id_0610 = Id_0620;
   Ii_062C = Ii_0084;
   Id_0630 = 0;
   Ii_0870 = OrdersTotal() - 1;
   Ii_0638 = Ii_0870;
   if (Ii_0870 >= 0) { 
   do { 
   if (OrderSelect(Ii_0638, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_062C == 0 || OrderMagicNumber() == Ii_062C) { 
   
   Id_0630 = (Id_0630 + OrderProfit());
   }}}} 
   Ii_0638 = Ii_0638 - 1;
   } while (Ii_0638 >= 0); 
   } 
   Id_0878 = (((Id_0610 + Id_0630) + Id_05F0) + Id_0868);
   Ii_0880 = Ii_004C * 1000;
   Id_0888 = (Ii_0880 * LotSize);
   if ((Id_0878 > (Id_0888 / 100))) { 
   Ii_063C = Ii_006C;
   Id_0640 = 0;
   Ii_0880 = OrdersTotal() - 1;
   Ii_0648 = Ii_0880;
   if (Ii_0880 >= 0) { 
   do { 
   if (OrderSelect(Ii_0648, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_063C == 0 || OrderMagicNumber() == Ii_063C) { 
   
   Id_0640 = (Id_0640 + OrderProfit());
   }}}} 
   Ii_0648 = Ii_0648 - 1;
   } while (Ii_0648 >= 0); 
   } 
   if ((Id_0640 < 0)) { 
   func_1021(Ii_006C);
   func_1021(Ii_0070);
   func_1021(Ii_0074);
   func_1021(Ii_0078);
   func_1021(Ii_007C);
   func_1021(Ii_0080);
   func_1021(Ii_0084);
   }} 
   Ii_0658 = Ii_0088;
   Id_0660 = 0;
   Ii_0880 = OrdersTotal() - 1;
   Ii_0668 = Ii_0880;
   if (Ii_0880 >= 0) { 
   do { 
   if (OrderSelect(Ii_0668, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0658 == 0 || OrderMagicNumber() == Ii_0658) { 
   
   Id_0660 = (Id_0660 + OrderProfit());
   }}}} 
   Ii_0668 = Ii_0668 - 1;
   } while (Ii_0668 >= 0); 
   } 
   Id_0650 = Id_0660;
   Ii_066C = Ii_008C;
   Id_0670 = 0;
   Ii_0880 = OrdersTotal() - 1;
   Ii_0678 = Ii_0880;
   if (Ii_0880 >= 0) { 
   do { 
   if (OrderSelect(Ii_0678, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_066C == 0 || OrderMagicNumber() == Ii_066C) { 
   
   Id_0670 = (Id_0670 + OrderProfit());
   }}}} 
   Ii_0678 = Ii_0678 - 1;
   } while (Ii_0678 >= 0); 
   } 
   Id_0888 = (Id_0650 + Id_0670);
   Ii_0688 = Ii_0090;
   Id_0690 = 0;
   Ii_0894 = OrdersTotal() - 1;
   Ii_0698 = Ii_0894;
   if (Ii_0894 >= 0) { 
   do { 
   if (OrderSelect(Ii_0698, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_0688 == 0 || OrderMagicNumber() == Ii_0688) { 
   
   Id_0690 = (Id_0690 + OrderProfit());
   }}}} 
   Ii_0698 = Ii_0698 - 1;
   } while (Ii_0698 >= 0); 
   } 
   Id_0680 = Id_0690;
   Ii_069C = Ii_0094;
   Id_06A0 = 0;
   Ii_0894 = OrdersTotal() - 1;
   Ii_06A8 = Ii_0894;
   if (Ii_0894 >= 0) { 
   do { 
   if (OrderSelect(Ii_06A8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_069C == 0 || OrderMagicNumber() == Ii_069C) { 
   
   Id_06A0 = (Id_06A0 + OrderProfit());
   }}}} 
   Ii_06A8 = Ii_06A8 - 1;
   } while (Ii_06A8 >= 0); 
   } 
   Id_0898 = ((Id_0680 + Id_06A0) + Id_0888);
   Ii_06B8 = Ii_0098;
   Id_06C0 = 0;
   Ii_08A0 = OrdersTotal() - 1;
   Ii_06C8 = Ii_08A0;
   if (Ii_08A0 >= 0) { 
   do { 
   if (OrderSelect(Ii_06C8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_06B8 == 0 || OrderMagicNumber() == Ii_06B8) { 
   
   Id_06C0 = (Id_06C0 + OrderProfit());
   }}}} 
   Ii_06C8 = Ii_06C8 - 1;
   } while (Ii_06C8 >= 0); 
   } 
   Id_06B0 = Id_06C0;
   Ii_06D8 = Ii_009C;
   Id_06E0 = 0;
   Ii_08A0 = OrdersTotal() - 1;
   Ii_06E8 = Ii_08A0;
   if (Ii_08A0 >= 0) { 
   do { 
   if (OrderSelect(Ii_06E8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_06D8 == 0 || OrderMagicNumber() == Ii_06D8) { 
   
   Id_06E0 = (Id_06E0 + OrderProfit());
   }}}} 
   Ii_06E8 = Ii_06E8 - 1;
   } while (Ii_06E8 >= 0); 
   } 
   Id_06D0 = Id_06E0;
   Ii_06EC = Ii_00A0;
   Id_06F0 = 0;
   Ii_08A0 = OrdersTotal() - 1;
   Ii_06F8 = Ii_08A0;
   if (Ii_08A0 >= 0) { 
   do { 
   if (OrderSelect(Ii_06F8, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_06EC == 0 || OrderMagicNumber() == Ii_06EC) { 
   
   Id_06F0 = (Id_06F0 + OrderProfit());
   }}}} 
   Ii_06F8 = Ii_06F8 - 1;
   } while (Ii_06F8 >= 0); 
   } 
   Id_08A8 = (((Id_06D0 + Id_06F0) + Id_06B0) + Id_0898);
   Ii_08B0 = Ii_004C * 1000;
   Id_08B8 = (Ii_08B0 * LotSize);
   if ((Id_08A8 <= (Id_08B8 / 100))) { 
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   Ii_06FC = Ii_0088;
   Id_0700 = 0;
   Ii_08B0 = OrdersTotal() - 1;
   Ii_0708 = Ii_08B0;
   if (Ii_08B0 >= 0) { 
   do { 
   if (OrderSelect(Ii_0708, 0, 0)) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   if (OrderSymbol() == _Symbol) { 
   if (Ii_06FC == 0 || OrderMagicNumber() == Ii_06FC) { 
   
   Id_0700 = (Id_0700 + OrderProfit());
   }}}} 
   Ii_0708 = Ii_0708 - 1;
   } while (Ii_0708 >= 0); 
   } 
   if ((Id_0700 >= 0)) { 
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   func_1021(Ii_0088);
   func_1021(Ii_008C);
   func_1021(Ii_0090);
   func_1021(Ii_0094);
   func_1021(Ii_0098);
   func_1021(Ii_009C);
   func_1021(Ii_00A0);
   Li_FB4C = 0;
   Li_FFFC = 0;
   
   return Li_FFFC;
}

int deinit()
{
   int Li_FFF8;
   int Li_FFFC;

   Li_FFF8 = 0;
   Li_FFF8 = 0;
   ObjectDelete("line1");
   ObjectDelete("linec");
   ObjectDelete("line2");
   ObjectDelete("lines");
   ObjectDelete("lineopl");
   ObjectDelete("linea");
   ObjectDelete("lineto");
   ObjectDelete("linetp");
   Li_FFF8 = 0;
   Li_FFFC = 0;
   return 0;
}

bool func_1014(string Fa_s_00, string Fa_s_01)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   int Li_FFF8;
   int Li_FFF4;
   int Li_FB84;
   int Li_FB80;
   bool Lb_FFFF;

   Li_FFF8 = 0;
   Li_FFF4 = 0;
   int Li_FFF0[1] = { 1 };
   char Lc_FBBC[1024];
   Li_FB84 = 0;
   Li_FB80 = (int)2214592768;
   Gi_0000 = (int)2214592768;
   tmp_str0000 = NULL;
   tmp_str0001 = Fa_s_00;
   Gb_0001 = false;
   if (Ii_0010 == 0) { 
   tmp_str0003 = "0";
   tmp_str0004 = "0";
   tmp_str0005 = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
   Gi_0002 = InternetOpenW(tmp_str0005, Ii_0018, tmp_str0004, tmp_str0003, 0);
   Ii_0010 = Gi_0002;
   tmp_str0005 = "0";
   tmp_str0006 = "0";
   tmp_str0007 = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
   Gi_0002 = InternetOpenW(tmp_str0007, Ii_001C, tmp_str0006, tmp_str0005, 0);
   Ii_0014 = Gi_0002;
   } 
   if (Gb_0001) { 
   Gi_0002 = Ii_0014;
   } 
   else { 
   Gi_0002 = Ii_0010;
   } 
   Gi_0000 = InternetOpenUrlW(Gi_0002, tmp_str0001, tmp_str0000, 0, Gi_0000, 0);
   Li_FFF8 = Gi_0000;
   if (Gi_0000 == 0) { 
   Lb_FFFF = false;
   ArrayFree(Lc_FBBC);
   ArrayFree(Li_FFF0);
   return Lb_FFFF;
   } 
   Print("Reading URL");
   Li_FFF4 = InternetReadFile(Li_FFF8, Lc_FBBC, Ii_0024, Li_FFF0);
   if (Li_FFF4 == 0) { 
   Lb_FFFF = false;
   ArrayFree(Lc_FBBC);
   ArrayFree(Li_FFF0);
   return Lb_FFFF;
   } 
   Li_FB84 = Li_FFF0[0];
   Fa_s_01 = CharArrayToString(Lc_FBBC, 0, Li_FFF0[0], 0);
   if (Li_FFF0[0] != 0) { 
   do { 
   Li_FFF4 = InternetReadFile(Li_FFF8, Lc_FBBC, Ii_0024, Li_FFF0);
   if (Li_FFF0[0]) break; 
   Li_FB84 = Li_FB84 + Li_FFF0[0];
   tmp_str0007 = Fa_s_01 + CharArrayToString(Lc_FBBC, 0, Li_FFF0[0], 0);
   Fa_s_01 = tmp_str0007;
   } while (Li_FFF0[0] != 0); 
   } 
   Print("Closing URL web connection");
   Li_FFF4 = InternetCloseHandle(Li_FFF8);
   if (Li_FFF4 == 0) { 
   Lb_FFFF = false;
   ArrayFree(Lc_FBBC);
   ArrayFree(Li_FFF0);
   return Lb_FFFF;
   } 
   Lb_FFFF = true;
   ArrayFree(Lc_FBBC);
   ArrayFree(Li_FFF0);
   
   return Lb_FFFF;
}

void func_1015(int Fa_i_00)
{
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   string Ls_FD90;
   string Ls_FD80;
   string Ls_FD70;
   string Ls_FD60;
   string Ls_FD50;
   string Ls_FD40;
   string Ls_FD30;
   string Ls_FD20;
   string Ls_FD10;
   string Ls_FD00;
   string Ls_FCF0;
   string Ls_FCE0;
   string Ls_FCD0;
   string Ls_FCC0;
   string Ls_FCB0;
   string Ls_FCA0;
   string Ls_FC90;
   string Ls_FC80;
   string Ls_FC70;
   string Ls_FC60;
   string Ls_FC50;
   string Ls_FC40;
   string Ls_FC30;
   string Ls_FC20;
   string Ls_FC10;
   string Ls_FC00;
   string Ls_FBF0;
   string Ls_FBE0;
   string Ls_FBD0;
   string Ls_FBC0;
   string Ls_FBB0;
   string Ls_FBA0;
   string Ls_FB90;
   string Ls_FB80;
   string Ls_FB70;
   string Ls_FB60;
   string Ls_FB50;
   string Ls_FB40;
   string Ls_FB30;
   string Ls_FB20;
   string Ls_FB10;
   string Ls_FB00;
   string Ls_FAF0;
   string Ls_FAE0;
   string Ls_FAD0;
   string Ls_FAC0;
   string Ls_FAB0;
   string Ls_FAA0;
   string Ls_FA90;
   string Ls_FA80;
   string Ls_FA70;
   string Ls_FA60;
   string Ls_FA50;
   string Ls_FA40;
   string Ls_FA30;
   string Ls_FA20;
   string Ls_FA10;
   string Ls_FA00;
   string Ls_F9F0;
   string Ls_F9E0;
   string Ls_F9D0;
   string Ls_F9C0;
   string Ls_F9B0;
   string Ls_F9A0;
   string Ls_F990;
   string Ls_F980;
   string Ls_F970;
   string Ls_F960;
   string Ls_F950;
   string Ls_F940;
   string Ls_F930;
   string Ls_F920;
   string Ls_F910;
   string Ls_F900;
   string Ls_F8F0;
   string Ls_F8E0;
   string Ls_F8D0;
   string Ls_F8C0;
   string Ls_F8B0;
   string Ls_F8A0;
   string Ls_F890;
   string Ls_F880;
   string Ls_F870;
   string Ls_F860;
   string Ls_F850;
   string Ls_F840;
   string Ls_F830;
   string Ls_F820;
   string Ls_F810;
   string Ls_F800;
   string Ls_F7F0;
   string Ls_F7E0;
   string Ls_F7D0;
   string Ls_F7C0;
   string Ls_F7B0;
   string Ls_F7A0;
   string Ls_F790;
   string Ls_F780;
   string Ls_F770;
   string Ls_F760;
   string Ls_F750;
   string Ls_F740;
   string Ls_F730;
   string Ls_F720;
   string Ls_F710;
   string Ls_F700;
   string Ls_F6F0;
   string Ls_F6E0;
   string Ls_F6D0;
   string Ls_F6C0;
   string Ls_F6B0;
   string Ls_F6A0;
   string Ls_F690;
   string Ls_F680;
   string Ls_F670;
   string Ls_F660;
   string Ls_F650;
   string Ls_F640;
   string Ls_F630;
   string Ls_F620;
   string Ls_F610;
   string Ls_F600;
   string Ls_F5F0;
   string Ls_F5E0;
   string Ls_F5D0;
   string Ls_F5C0;
   string Ls_F5B0;
   string Ls_F5A0;
   string Ls_F590;
   string Ls_F580;
   string Ls_F570;
   string Ls_F560;
   string Ls_F550;
   string Ls_F540;
   string Ls_F530;
   string Ls_F520;
   string Ls_F510;
   string Ls_F500;
   string Ls_F4F0;
   string Ls_F4E0;
   string Ls_F4D0;
   string Ls_F4C0;
   string Ls_F4B0;
   string Ls_F4A0;
   string Ls_F490;
   string Ls_F480;
   string Ls_F470;
   string Ls_F460;
   string Ls_F450;
   string Ls_F440;
   string Ls_F430;
   string Ls_F420;
   string Ls_F410;
   string Ls_F400;
   string Ls_F3F0;
   string Ls_F3E0;
   string Ls_F3D0;
   string Ls_F3C0;
   string Ls_F3B0;
   string Ls_F3A0;
   string Ls_F390;
   string Ls_F380;
   string Ls_F370;
   string Ls_F360;
   string Ls_F350;
   string Ls_F340;
   string Ls_F330;
   string Ls_F320;
   string Ls_F310;
   string Ls_F300;
   string Ls_F2F0;
   string Ls_F2E0;
   string Ls_F2D0;
   string Ls_F2C0;
   string Ls_F2B0;
   string Ls_F2A0;
   string Ls_F290;
   string Ls_F280;
   string Ls_F270;
   string Ls_F260;
   string Ls_F250;
   string Ls_F240;
   string Ls_F230;
   string Ls_F220;
   string Ls_F210;
   string Ls_F200;
   string Ls_F1F0;
   string Ls_F1E0;
   string Ls_F1D0;
   string Ls_F1C0;
   string Ls_F1B0;
   string Ls_F1A0;
   string Ls_F190;
   string Ls_F180;
   string Ls_F170;
   string Ls_F160;
   string Ls_F150;
   string Ls_F140;
   string Ls_F130;
   string Ls_F120;
   string Ls_F110;
   string Ls_F100;
   string Ls_F0F0;
   string Ls_F0E0;
   string Ls_F0D0;
   string Ls_F0C0;
   string Ls_F0B0;
   string Ls_F0A0;
   string Ls_F090;
   string Ls_F080;
   string Ls_F070;
   string Ls_F060;
   string Ls_F050;
   string Ls_F040;
   string Ls_F030;
   string Ls_F020;
   string Ls_F010;
   string Ls_F000;
   string Ls_EFF0;
   string Ls_EFE0;
   string Ls_EFD0;
   string Ls_EFC0;
   string Ls_EFB0;
   string Ls_EFA0;
   string Ls_EF90;
   string Ls_EF80;
   string Ls_EF70;
   string Ls_EF60;
   string Ls_EF50;
   string Ls_EF40;
   string Ls_EF30;
   string Ls_EF20;
   string Ls_EF10;
   string Ls_EF00;
   string Ls_EEF0;
   string Ls_EEE0;
   string Ls_EED0;
   string Ls_EEC0;
   string Ls_EEB0;
   string Ls_EEA0;
   string Ls_EE90;
   string Ls_EE80;
   string Ls_EE70;
   string Ls_EE60;
   string Ls_EE50;
   string Ls_EE40;
   string Ls_EE30;
   string Ls_EE20;
   string Ls_EE10;
   string Ls_EE00;
   string Ls_EDF0;
   string Ls_EDE0;
   string Ls_EDD0;
   string Ls_EDC0;
   string Ls_EDB0;
   string Ls_EDA0;
   string Ls_ED90;
   string Ls_ED80;
   string Ls_ED70;
   string Ls_ED60;
   string Ls_ED50;
   string Ls_ED40;
   string Ls_ED30;
   string Ls_ED20;
   string Ls_ED10;
   string Ls_ED00;
   string Ls_ECF0;
   string Ls_ECE0;
   string Ls_ECD0;
   string Ls_ECC0;
   string Ls_ECB0;
   string Ls_ECA0;
   string Ls_EC90;
   string Ls_EC80;
   string Ls_EC70;
   string Ls_EC60;
   string Ls_EC50;
   string Ls_EC40;
   string Ls_EC30;
   string Ls_EC20;
   string Ls_EC10;
   string Ls_EC00;
   string Ls_EBF0;
   string Ls_EBE0;
   string Ls_EBD0;
   string Ls_EBC0;
   string Ls_EBB0;
   string Ls_EBA0;
   string Ls_EB90;
   string Ls_EB80;
   string Ls_EB70;
   string Ls_EB60;
   string Ls_EB50;
   string Ls_EB40;
   string Ls_EB30;
   string Ls_EB20;
   string Ls_EB10;
   string Ls_EB00;
   string Ls_EAF0;
   string Ls_EAE0;
   string Ls_EAD0;
   string Ls_EAC0;
   string Ls_EAB0;
   string Ls_EAA0;
   string Ls_EA90;
   string Ls_EA80;
   string Ls_EA70;
   string Ls_EA60;
   string Ls_EA50;
   string Ls_EA40;
   string Ls_EA30;
   string Ls_EA20;
   string Ls_EA10;
   string Ls_EA00;
   string Ls_E9F0;
   string Ls_E9E0;
   string Ls_E9D0;
   string Ls_E9C0;
   string Ls_E9B0;
   string Ls_E9A0;
   string Ls_E990;
   string Ls_E980;
   string Ls_E970;
   string Ls_E960;
   string Ls_E950;
   string Ls_E940;
   string Ls_E930;
   string Ls_E920;
   string Ls_E910;
   string Ls_E900;
   string Ls_E8F0;
   string Ls_E8E0;
   string Ls_E8D0;
   string Ls_E8C0;
   string Ls_E8B0;
   string Ls_E8A0;
   string Ls_E890;
   string Ls_E880;
   string Ls_E870;
   string Ls_E860;
   string Ls_E850;
   string Ls_E840;
   string Ls_E830;
   string Ls_E820;
   string Ls_E810;
   string Ls_E800;
   string Ls_E7F0;
   string Ls_E7E0;
   string Ls_E7D0;
   string Ls_E7C0;
   string Ls_E7B0;
   string Ls_E7A0;
   string Ls_E790;
   string Ls_E780;
   string Ls_E770;
   string Ls_E760;
   string Ls_E750;
   string Ls_E740;
   string Ls_E730;
   string Ls_E720;
   string Ls_E710;
   string Ls_E700;
   string Ls_E6F0;
   string Ls_E6E0;
   string Ls_E6D0;
   string Ls_E6C0;
   string Ls_E6B0;
   string Ls_E6A0;
   string Ls_E690;
   string Ls_E680;
   string Ls_E670;
   string Ls_E660;
   string Ls_E650;
   string Ls_E640;
   string Ls_E630;
   string Ls_E620;
   string Ls_E610;
   string Ls_E600;
   string Ls_E5F0;
   string Ls_E5E0;
   string Ls_E5D0;
   string Ls_E5C0;
   string Ls_E5B0;
   string Ls_E5A0;
   string Ls_E590;
   string Ls_E580;
   string Ls_E570;
   string Ls_E560;
   string Ls_E550;
   string Ls_E540;
   string Ls_E530;
   string Ls_E520;
   string Ls_E510;
   string Ls_E500;
   string Ls_E4F0;
   string Ls_E4E0;
   string Ls_E4D0;
   string Ls_E4C0;
   string Ls_E4B0;
   string Ls_E4A0;
   string Ls_E490;
   string Ls_E480;
   string Ls_E470;
   string Ls_E460;
   string Ls_E450;
   string Ls_E440;
   string Ls_E430;
   string Ls_E420;
   string Ls_E410;
   string Ls_E400;
   string Ls_E3F0;
   string Ls_E3E0;
   string Ls_E3D0;
   string Ls_E3C0;
   string Ls_E3B0;
   string Ls_E3A0;
   string Ls_E390;
   string Ls_E380;
   string Ls_E370;
   string Ls_E360;
   string Ls_E350;
   string Ls_E340;
   string Ls_E330;
   string Ls_E320;
   string Ls_E310;
   string Ls_E300;
   string Ls_E2F0;
   string Ls_E2E0;
   string Ls_E2D0;
   string Ls_E2C0;
   string Ls_E2B0;
   string Ls_E2A0;
   string Ls_E290;
   string Ls_E280;
   string Ls_E270;
   string Ls_E260;
   string Ls_E250;
   string Ls_E240;
   string Ls_E230;
   string Ls_E220;
   string Ls_E210;
   string Ls_E200;
   string Ls_E1F0;
   string Ls_E1E0;
   string Ls_E1D0;
   string Ls_E1C0;
   string Ls_E1B0;
   string Ls_E1A0;
   string Ls_E190;
   string Ls_E180;
   string Ls_E170;
   string Ls_E160;
   string Ls_E150;
   string Ls_E140;
   string Ls_E130;
   string Ls_E120;
   string Ls_E110;
   string Ls_E100;
   string Ls_E0F0;
   string Ls_E0E0;
   string Ls_E0D0;
   string Ls_E0C0;
   string Ls_E0B0;
   string Ls_E0A0;
   string Ls_E090;
   string Ls_E080;
   string Ls_E070;
   string Ls_E060;
   string Ls_E050;
   string Ls_E040;
   string Ls_E030;
   string Ls_E020;
   string Ls_E010;
   string Ls_E000;
   string Ls_DFF0;
   string Ls_DFE0;
   string Ls_DFD0;
   string Ls_DFC0;
   string Ls_DFB0;
   string Ls_DFA0;
   string Ls_DF90;
   string Ls_DF80;
   string Ls_DF70;
   string Ls_DF60;
   string Ls_DF50;
   string Ls_DF40;
   string Ls_DF30;
   string Ls_DF20;
   string Ls_DF10;
   string Ls_DF00;
   string Ls_DEF0;
   string Ls_DEE0;
   string Ls_DED0;
   string Ls_DEC0;
   string Ls_DEB0;
   string Ls_DEA0;
   string Ls_DE90;
   string Ls_DE80;
   string Ls_DE70;
   string Ls_DE60;
   string Ls_DE50;
   string Ls_DE40;
   string Ls_DE30;
   string Ls_DE20;
   string Ls_DE10;
   string Ls_DE00;
   string Ls_DDF0;
   string Ls_DDE0;
   string Ls_DDD0;
   string Ls_DDC0;
   string Ls_DDB0;
   string Ls_DDA0;
   string Ls_DD90;
   string Ls_DD80;
   string Ls_DD70;
   string Ls_DD60;
   string Ls_DD50;
   string Ls_DD40;
   string Ls_DD30;
   string Ls_DD20;
   string Ls_DD10;
   string Ls_DD00;
   string Ls_DCF0;
   string Ls_DCE0;
   string Ls_DCD0;
   string Ls_DCC0;
   string Ls_DCB0;
   string Ls_DCA0;
   string Ls_DC90;
   string Ls_DC80;
   string Ls_DC70;
   string Ls_DC60;
   string Ls_DC50;
   string Ls_DC40;
   string Ls_DC30;
   string Ls_DC20;
   string Ls_DC10;
   string Ls_DC00;
   string Ls_DBF0;
   string Ls_DBE0;
   string Ls_DBD0;
   string Ls_DBC0;
   string Ls_DBB0;
   string Ls_DBA0;
   string Ls_DB90;
   string Ls_DB80;
   string Ls_DB70;
   string Ls_DB60;
   string Ls_DB50;
   string Ls_DB40;
   string Ls_DB30;
   string Ls_DB20;
   string Ls_DB10;
   string Ls_DB00;
   string Ls_DAF0;
   string Ls_DAE0;
   string Ls_DAD0;
   string Ls_DAC0;
   string Ls_DAB0;
   string Ls_DAA0;
   string Ls_DA90;
   string Ls_DA80;
   string Ls_DA70;
   string Ls_DA60;
   string Ls_DA50;
   string Ls_DA40;
   string Ls_DA30;
   string Ls_DA20;
   string Ls_DA10;
   string Ls_DA00;
   string Ls_D9F0;
   string Ls_D9E0;
   string Ls_D9D0;
   string Ls_D9C0;
   string Ls_D9B0;
   string Ls_D9A0;
   string Ls_D990;
   string Ls_D980;
   string Ls_D970;
   string Ls_D960;
   string Ls_D950;
   string Ls_D940;
   string Ls_D930;
   string Ls_D920;
   string Ls_D910;
   string Ls_D900;
   string Ls_D8F0;
   string Ls_D8E0;
   string Ls_D8D0;
   string Ls_D8C0;
   string Ls_D8B0;
   string Ls_D8A0;
   string Ls_D890;
   string Ls_D880;
   string Ls_D870;
   string Ls_D860;
   string Ls_D850;
   string Ls_D840;
   string Ls_D830;
   string Ls_D820;
   string Ls_D810;
   string Ls_D800;
   string Ls_D7F0;
   string Ls_D7E0;
   string Ls_D7D0;
   string Ls_D7C0;
   string Ls_D7B0;
   string Ls_D7A0;
   string Ls_D790;
   string Ls_D780;
   string Ls_D770;
   string Ls_D760;
   string Ls_D750;
   string Ls_D740;
   string Ls_D730;
   string Ls_D720;
   string Ls_D710;
   string Ls_D700;
   string Ls_D6F0;
   string Ls_D6E0;
   string Ls_D6D0;
   string Ls_D6C0;
   string Ls_D6B0;
   string Ls_D6A0;
   string Ls_D690;
   string Ls_D680;
   string Ls_D670;
   string Ls_D660;
   string Ls_D650;
   string Ls_D640;
   string Ls_D630;
   string Ls_D620;
   string Ls_D610;
   string Ls_D600;
   string Ls_D5F0;
   string Ls_D5E0;
   string Ls_D5D0;
   string Ls_D5C0;
   string Ls_D5B0;
   string Ls_D5A0;
   string Ls_D590;
   string Ls_D580;
   string Ls_D570;
   string Ls_D560;
   string Ls_D550;
   string Ls_D540;
   string Ls_D530;
   string Ls_D520;
   string Ls_D510;
   string Ls_D500;
   string Ls_D4F0;
   string Ls_D4E0;
   string Ls_D4D0;
   string Ls_D4C0;
   string Ls_D4B0;
   string Ls_D4A0;
   string Ls_D490;
   string Ls_D480;
   string Ls_D470;
   string Ls_D460;
   string Ls_D450;
   string Ls_D440;
   string Ls_D430;
   string Ls_D420;
   string Ls_D410;
   string Ls_D400;
   string Ls_D3F0;
   string Ls_D3E0;
   string Ls_D3D0;
   string Ls_D3C0;
   string Ls_D3B0;
   string Ls_D3A0;
   string Ls_D390;
   string Ls_D380;
   string Ls_D370;
   string Ls_D360;
   string Ls_D350;
   string Ls_D340;
   string Ls_D330;
   string Ls_D320;
   string Ls_D310;
   string Ls_D300;
   string Ls_D2F0;
   string Ls_D2E0;
   string Ls_D2D0;
   string Ls_D2C0;
   string Ls_D2B0;
   string Ls_D2A0;
   string Ls_D290;
   string Ls_D280;
   string Ls_D270;
   string Ls_D260;
   string Ls_D250;
   string Ls_D240;
   string Ls_D230;
   string Ls_D220;
   string Ls_D210;
   string Ls_D200;
   string Ls_D1F0;
   string Ls_D1E0;
   string Ls_D1D0;
   string Ls_D1C0;
   string Ls_D1B0;
   string Ls_D1A0;
   string Ls_D190;
   string Ls_D180;
   string Ls_D170;
   string Ls_D160;
   string Ls_D150;
   string Ls_D140;
   string Ls_D130;
   string Ls_D120;
   string Ls_D110;
   string Ls_D100;
   string Ls_D0F0;
   string Ls_D0E0;
   string Ls_D0D0;
   string Ls_D0C0;
   string Ls_D0B0;
   string Ls_D0A0;
   string Ls_D090;
   string Ls_D080;
   string Ls_D070;
   string Ls_D060;
   string Ls_D050;
   string Ls_D040;
   string Ls_D030;
   string Ls_D020;
   string Ls_D010;
   string Ls_D000;
   string Ls_CFF0;
   string Ls_CFE0;
   string Ls_CFD0;
   string Ls_CFC0;
   string Ls_CFB0;
   string Ls_CFA0;
   string Ls_CF90;
   string Ls_CF80;
   string Ls_CF70;
   string Ls_CF60;
   string Ls_CF50;
   string Ls_CF40;
   string Ls_CF30;
   string Ls_CF20;
   string Ls_CF10;
   string Ls_CF00;
   string Ls_CEF0;
   string Ls_CEE0;
   string Ls_CED0;
   string Ls_CEC0;
   string Ls_CEB0;
   string Ls_CEA0;
   string Ls_CE90;
   string Ls_CE80;
   string Ls_CE70;
   string Ls_CE60;
   string Ls_CE50;
   string Ls_CE40;
   string Ls_CE30;
   string Ls_CE20;
   string Ls_CE10;
   string Ls_CE00;
   string Ls_CDF0;
   string Ls_CDE0;
   string Ls_CDD0;
   string Ls_CDC0;
   string Ls_CDB0;
   string Ls_CDA0;
   string Ls_CD90;
   string Ls_CD80;
   string Ls_CD70;
   string Ls_CD60;
   string Ls_CD50;
   string Ls_CD40;
   string Ls_CD30;
   string Ls_CD20;
   string Ls_CD10;
   string Ls_CD00;
   string Ls_CCF0;
   string Ls_CCE0;
   string Ls_CCD0;
   string Ls_CCC0;
   string Ls_CCB0;
   string Ls_CCA0;
   string Ls_CC90;
   string Ls_CC80;
   string Ls_CC70;
   string Ls_CC60;
   string Ls_CC50;
   string Ls_CC40;
   string Ls_CC30;
   string Ls_CC20;
   string Ls_CC10;
   string Ls_CC00;
   string Ls_CBF0;
   string Ls_CBE0;
   string Ls_CBD0;
   string Ls_CBC0;
   string Ls_CBB0;
   string Ls_CBA0;
   string Ls_CB90;
   string Ls_CB80;
   string Ls_CB70;
   string Ls_CB60;
   string Ls_CB50;
   string Ls_CB40;
   string Ls_CB30;
   string Ls_CB20;
   string Ls_CB10;
   string Ls_CB00;
   string Ls_CAF0;
   string Ls_CAE0;
   string Ls_CAD0;
   string Ls_CAC0;
   string Ls_CAB0;
   string Ls_CAA0;
   string Ls_CA90;
   string Ls_CA80;
   string Ls_CA70;
   string Ls_CA60;
   string Ls_CA50;
   string Ls_CA40;
   string Ls_CA30;
   string Ls_CA20;
   string Ls_CA10;
   string Ls_CA00;
   string Ls_C9F0;
   string Ls_C9E0;
   string Ls_C9D0;
   string Ls_C9C0;
   string Ls_C9B0;
   string Ls_C9A0;
   string Ls_C990;
   string Ls_C980;
   string Ls_C970;
   string Ls_C960;
   string Ls_C950;
   string Ls_C940;
   string Ls_C930;
   string Ls_C920;
   string Ls_C910;
   string Ls_C900;
   string Ls_C8F0;
   string Ls_C8E0;
   string Ls_C8D0;
   string Ls_C8C0;
   string Ls_C8B0;
   string Ls_C8A0;
   string Ls_C890;
   string Ls_C880;
   string Ls_C870;
   string Ls_C860;
   string Ls_C850;
   string Ls_C840;
   string Ls_C830;
   string Ls_C820;
   string Ls_C810;
   string Ls_C800;
   string Ls_C7F0;
   string Ls_C7E0;
   string Ls_C7D0;
   string Ls_C7C0;
   string Ls_C7B0;
   string Ls_C7A0;
   string Ls_C790;
   string Ls_C780;
   string Ls_C770;
   string Ls_C760;
   string Ls_C750;
   string Ls_C740;
   string Ls_C730;
   string Ls_C720;
   string Ls_C710;
   string Ls_C700;
   string Ls_C6F0;
   string Ls_C6E0;
   string Ls_C6D0;
   string Ls_C6C0;
   string Ls_C6B0;
   string Ls_C6A0;
   string Ls_C690;
   string Ls_C680;
   string Ls_C670;
   string Ls_C660;
   string Ls_C650;
   string Ls_C640;
   string Ls_C630;
   string Ls_C620;
   string Ls_C610;
   string Ls_C600;
   string Ls_C5F0;
   string Ls_C5E0;
   string Ls_C5D0;
   string Ls_C5C0;
   string Ls_C5B0;
   string Ls_C5A0;
   string Ls_C590;
   string Ls_C580;
   string Ls_C570;
   string Ls_C560;
   string Ls_C550;
   string Ls_C540;
   string Ls_C530;
   string Ls_C520;
   string Ls_C510;
   string Ls_C500;
   string Ls_C4F0;
   string Ls_C4E0;
   string Ls_C4D0;
   string Ls_C4C0;
   string Ls_C4B0;
   string Ls_C4A0;
   string Ls_C490;
   string Ls_C480;
   string Ls_C470;
   string Ls_C460;
   string Ls_C450;
   string Ls_C440;
   string Ls_C430;
   string Ls_C420;
   string Ls_C410;
   string Ls_C400;
   string Ls_C3F0;
   string Ls_C3E0;
   string Ls_C3D0;
   string Ls_C3C0;
   string Ls_C3B0;
   string Ls_C3A0;
   string Ls_C390;
   string Ls_C380;
   string Ls_C370;
   string Ls_C360;
   string Ls_C350;
   string Ls_C340;
   string Ls_C330;
   string Ls_C320;
   string Ls_C310;
   string Ls_C300;
   string Ls_C2F0;
   string Ls_C2E0;
   string Ls_C2D0;
   string Ls_C2C0;
   string Ls_C2B0;
   string Ls_C2A0;
   string Ls_C290;
   string Ls_C280;
   string Ls_C270;
   string Ls_C260;
   string Ls_C250;
   string Ls_C240;
   string Ls_C230;
   string Ls_C220;
   string Ls_C210;
   string Ls_C200;
   string Ls_C1F0;
   string Ls_C1E0;
   string Ls_C1D0;
   string Ls_C1C0;
   string Ls_C1B0;
   string Ls_C1A0;
   string Ls_C190;
   string Ls_C180;
   string Ls_C170;
   string Ls_C160;
   string Ls_C150;
   string Ls_C140;
   string Ls_C130;
   string Ls_C120;
   string Ls_C110;
   string Ls_C100;
   string Ls_C0F0;
   string Ls_C0E0;
   string Ls_C0D0;
   string Ls_C0C0;
   string Ls_C0B0;
   string Ls_C0A0;
   string Ls_C090;
   string Ls_C080;
   string Ls_C070;
   string Ls_C060;
   string Ls_C050;
   string Ls_C040;
   string Ls_C030;
   string Ls_C020;
   string Ls_C010;
   string Ls_C000;
   string Ls_BFF0;
   string Ls_BFE0;
   string Ls_BFD0;
   string Ls_BFC0;
   string Ls_BFB0;
   string Ls_BFA0;
   string Ls_BF90;
   string Ls_BF80;
   string Ls_BF70;
   string Ls_BF60;
   string Ls_BF50;
   string Ls_BF40;
   string Ls_BF30;
   string Ls_BF20;
   string Ls_BF10;
   string Ls_BF00;
   string Ls_BEF0;
   string Ls_BEE0;
   string Ls_BED0;
   string Ls_BEC0;
   string Ls_BEB0;
   string Ls_BEA0;
   string Ls_BE90;
   string Ls_BE80;
   string Ls_BE70;
   string Ls_BE60;
   string Ls_BE50;
   string Ls_BE40;
   string Ls_BE30;
   string Ls_BE20;
   string Ls_BE10;
   string Ls_BE00;
   string Ls_BDF0;
   string Ls_BDE0;
   string Ls_BDD0;
   string Ls_BDC0;
   string Ls_BDB0;
   string Ls_BDA0;
   string Ls_BD90;
   string Ls_BD80;
   string Ls_BD70;
   string Ls_BD60;
   string Ls_BD50;
   string Ls_BD40;
   string Ls_BD30;
   string Ls_BD20;
   string Ls_BD10;
   string Ls_BD00;
   string Ls_BCF0;
   string Ls_BCE0;
   string Ls_BCD0;
   string Ls_BCC0;
   string Ls_BCB0;
   string Ls_BCA0;
   string Ls_BC90;
   string Ls_BC80;
   string Ls_BC70;
   string Ls_BC60;
   string Ls_BC50;
   string Ls_BC40;
   string Ls_BC30;
   string Ls_BC20;
   string Ls_BC10;
   string Ls_BC00;
   string Ls_BBF0;
   string Ls_BBE0;
   string Ls_BBD0;
   string Ls_BBC0;
   string Ls_BBB0;
   string Ls_BBA0;
   string Ls_BB90;
   string Ls_BB80;
   string Ls_BB70;
   string Ls_BB60;
   string Ls_BB50;
   string Ls_BB40;
   string Ls_BB30;
   string Ls_BB20;
   string Ls_BB10;
   string Ls_BB00;
   string Ls_BAF0;
   string Ls_BAE0;
   string Ls_BAD0;
   string Ls_BAC0;
   string Ls_BAB0;
   string Ls_BAA0;
   string Ls_BA90;
   string Ls_BA80;
   string Ls_BA70;
   string Ls_BA60;
   string Ls_BA50;
   string Ls_BA40;
   string Ls_BA30;
   string Ls_BA20;
   string Ls_BA10;
   string Ls_BA00;
   string Ls_B9F0;
   string Ls_B9E0;
   string Ls_B9D0;
   string Ls_B9C0;
   string Ls_B9B0;
   string Ls_B9A0;
   string Ls_B990;
   string Ls_B980;
   string Ls_B970;
   string Ls_B960;
   string Ls_B950;
   string Ls_B940;
   string Ls_B930;
   string Ls_B920;
   string Ls_B910;
   string Ls_B900;
   string Ls_B8F0;
   string Ls_B8E0;
   string Ls_B8D0;
   string Ls_B8C0;
   string Ls_B8B0;
   string Ls_B8A0;
   string Ls_B890;
   string Ls_B880;
   string Ls_B870;
   string Ls_B860;
   string Ls_B850;
   string Ls_B840;
   string Ls_B830;
   string Ls_B820;
   string Ls_B810;
   string Ls_B800;
   string Ls_B7F0;
   string Ls_B7E0;
   string Ls_B7D0;
   string Ls_B7C0;
   string Ls_B7B0;
   string Ls_B7A0;
   string Ls_B790;
   string Ls_B780;
   string Ls_B770;
   string Ls_B760;
   string Ls_B750;
   string Ls_B740;
   string Ls_B730;
   string Ls_B720;
   string Ls_B710;
   string Ls_B700;
   string Ls_B6F0;
   string Ls_B6E0;
   string Ls_B6D0;
   string Ls_B6C0;
   string Ls_B6B0;
   string Ls_B6A0;
   string Ls_B690;
   string Ls_B680;
   string Ls_B670;
   string Ls_B660;
   string Ls_B650;
   string Ls_B640;
   string Ls_B630;
   string Ls_B620;
   string Ls_B610;
   string Ls_B600;
   string Ls_B5F0;
   string Ls_B5E0;
   string Ls_B5D0;
   string Ls_B5C0;
   string Ls_B5B0;
   string Ls_B5A0;
   string Ls_B590;
   string Ls_B580;
   string Ls_B570;
   string Ls_B560;
   string Ls_B550;
   string Ls_B540;
   string Ls_B530;
   string Ls_B520;
   string Ls_B510;
   string Ls_B500;
   string Ls_B4F0;
   string Ls_B4E0;
   string Ls_B4D0;
   string Ls_B4C0;
   string Ls_B4B0;
   string Ls_B4A0;
   string Ls_B490;
   string Ls_B480;
   string Ls_B470;
   string Ls_B460;
   string Ls_B450;
   string Ls_B440;
   string Ls_B430;
   string Ls_B420;
   string Ls_B410;
   string Ls_B400;
   string Ls_B3F0;
   string Ls_B3E0;
   string Ls_B3D0;
   string Ls_B3C0;
   string Ls_B3B0;
   string Ls_B3A0;
   string Ls_B390;
   string Ls_B380;
   string Ls_B370;
   string Ls_B360;
   string Ls_B350;
   string Ls_B340;
   string Ls_B330;
   string Ls_B320;
   string Ls_B310;
   string Ls_B300;
   string Ls_B2F0;
   string Ls_B2E0;
   string Ls_B2D0;
   string Ls_B2C0;
   string Ls_B2B0;
   string Ls_B2A0;
   string Ls_B290;
   string Ls_B280;
   string Ls_B270;
   string Ls_B260;
   string Ls_B250;
   string Ls_B240;
   string Ls_B230;
   string Ls_B220;
   string Ls_B210;
   string Ls_B200;
   string Ls_B1F0;
   string Ls_B1E0;
   string Ls_B1D0;
   string Ls_B1C0;
   string Ls_B1B0;
   string Ls_B1A0;
   string Ls_B190;
   string Ls_B180;
   string Ls_B170;
   string Ls_B160;
   string Ls_B150;
   string Ls_B140;
   string Ls_B130;
   string Ls_B120;
   string Ls_B110;
   string Ls_B100;
   string Ls_B0F0;
   string Ls_B0E0;
   string Ls_B0D0;
   string Ls_B0C0;
   string Ls_B0B0;
   string Ls_B0A0;
   string Ls_B090;
   string Ls_B080;
   string Ls_B070;
   string Ls_B060;
   string Ls_B050;
   string Ls_B040;
   string Ls_B030;
   string Ls_B020;
   string Ls_B010;
   string Ls_B000;
   string Ls_AFF0;
   string Ls_AFE0;
   string Ls_AFD0;
   string Ls_AFC0;
   string Ls_AFB0;
   string Ls_AFA0;
   string Ls_AF90;
   string Ls_AF80;
   string Ls_AF70;
   string Ls_AF60;
   string Ls_AF50;
   string Ls_AF40;
   string Ls_AF30;
   string Ls_AF20;
   string Ls_AF10;
   string Ls_AF00;
   string Ls_AEF0;
   string Ls_AEE0;
   string Ls_AED0;
   string Ls_AEC0;
   string Ls_AEB0;
   string Ls_AEA0;
   string Ls_AE90;
   string Ls_AE80;
   string Ls_AE70;
   string Ls_AE60;
   string Ls_AE50;
   string Ls_AE40;
   string Ls_AE30;
   string Ls_AE20;
   string Ls_AE10;
   string Ls_AE00;
   string Ls_ADF0;
   string Ls_ADE0;
   string Ls_ADD0;
   string Ls_ADC0;
   string Ls_ADB0;
   string Ls_ADA0;
   string Ls_AD90;
   string Ls_AD80;
   string Ls_AD70;
   string Ls_AD60;
   string Ls_AD50;
   string Ls_AD40;
   string Ls_AD30;
   string Ls_AD20;
   string Ls_AD10;
   string Ls_AD00;
   string Ls_ACF0;
   string Ls_ACE0;
   string Ls_ACD0;
   string Ls_ACC0;
   string Ls_ACB0;
   string Ls_ACA0;
   string Ls_AC90;
   string Ls_AC80;
   string Ls_AC70;
   string Ls_AC60;
   string Ls_AC50;
   string Ls_AC40;
   string Ls_AC30;
   string Ls_AC20;
   string Ls_AC10;
   string Ls_AC00;
   string Ls_ABF0;
   string Ls_ABE0;
   string Ls_ABD0;
   string Ls_ABC0;
   string Ls_ABB0;
   string Ls_ABA0;
   string Ls_AB90;
   string Ls_AB80;
   string Ls_AB70;
   string Ls_AB60;
   string Ls_AB50;
   string Ls_AB40;
   string Ls_AB30;
   string Ls_AB20;
   string Ls_AB10;
   string Ls_AB00;
   string Ls_AAF0;
   string Ls_AAE0;
   string Ls_AAD0;
   string Ls_AAC0;
   string Ls_AAB0;
   string Ls_AAA0;
   string Ls_AA90;
   string Ls_AA80;
   string Ls_AA70;
   string Ls_AA60;
   string Ls_AA50;
   string Ls_AA40;
   string Ls_AA30;
   string Ls_AA20;
   string Ls_AA10;
   string Ls_AA00;
   string Ls_A9F0;
   string Ls_A9E0;
   string Ls_A9D0;
   string Ls_A9C0;
   string Ls_A9B0;
   string Ls_A9A0;
   string Ls_A990;
   string Ls_A980;
   string Ls_A970;
   string Ls_A960;
   string Ls_A950;
   string Ls_A940;
   string Ls_A930;
   string Ls_A920;
   string Ls_A910;
   string Ls_A900;
   string Ls_A8F0;
   string Ls_A8E0;
   string Ls_A8D0;
   string Ls_A8C0;
   string Ls_A8B0;
   string Ls_A8A0;
   string Ls_A890;
   string Ls_A880;
   string Ls_A870;
   string Ls_A860;
   string Ls_A850;
   string Ls_A840;
   string Ls_A830;
   string Ls_A820;
   string Ls_A810;
   string Ls_A800;
   string Ls_A7F0;
   string Ls_A7E0;
   string Ls_A7D0;
   string Ls_A7C0;
   string Ls_A7B0;
   string Ls_A7A0;
   string Ls_A790;
   string Ls_A780;
   string Ls_A770;
   string Ls_A760;
   string Ls_A750;
   string Ls_A740;
   string Ls_A730;
   string Ls_A720;
   string Ls_A710;
   string Ls_A700;
   string Ls_A6F0;
   string Ls_A6E0;
   string Ls_A6D0;
   string Ls_A6C0;
   string Ls_A6B0;
   string Ls_A6A0;
   string Ls_A690;
   string Ls_A680;
   string Ls_A670;
   string Ls_A660;
   string Ls_A650;
   string Ls_A640;
   string Ls_A630;
   string Ls_A620;
   string Ls_A610;
   string Ls_A600;
   string Ls_A5F0;
   string Ls_A5E0;
   string Ls_A5D0;
   string Ls_A5C0;
   string Ls_A5B0;
   string Ls_A5A0;
   string Ls_A590;
   string Ls_A580;
   string Ls_A570;
   string Ls_A560;
   string Ls_A550;
   string Ls_A540;
   string Ls_A530;
   string Ls_A520;
   string Ls_A510;
   string Ls_A500;
   string Ls_A4F0;
   string Ls_A4E0;
   string Ls_A4D0;
   string Ls_A4C0;
   string Ls_A4B0;
   string Ls_A4A0;
   string Ls_A490;
   string Ls_A480;
   string Ls_A470;
   string Ls_A460;
   string Ls_A450;
   string Ls_A440;
   string Ls_A430;
   string Ls_A420;
   string Ls_A410;
   string Ls_A400;
   string Ls_A3F0;
   string Ls_A3E0;
   string Ls_A3D0;
   string Ls_A3C0;
   string Ls_A3B0;
   string Ls_A3A0;
   string Ls_A390;
   string Ls_A380;
   string Ls_A370;
   string Ls_A360;
   string Ls_A350;
   string Ls_A340;
   string Ls_A330;
   string Ls_A320;
   string Ls_A310;
   string Ls_A300;
   string Ls_A2F0;
   string Ls_A2E0;
   string Ls_A2D0;
   string Ls_A2C0;
   string Ls_A2B0;
   string Ls_A2A0;
   string Ls_A290;
   string Ls_A280;
   string Ls_A270;
   string Ls_A260;
   string Ls_A250;
   string Ls_A240;
   string Ls_A230;
   string Ls_A220;
   string Ls_A210;
   string Ls_A200;
   string Ls_A1F0;
   string Ls_A1E0;
   string Ls_A1D0;
   string Ls_A1C0;
   string Ls_A1B0;
   string Ls_A1A0;
   string Ls_A190;
   string Ls_A180;
   string Ls_A170;
   string Ls_A160;
   string Ls_A150;
   string Ls_A140;
   string Ls_A130;
   string Ls_A120;
   string Ls_A110;
   string Ls_A100;
   string Ls_A0F0;
   string Ls_A0E0;
   string Ls_A0D0;
   string Ls_A0C0;
   string Ls_A0B0;
   string Ls_A0A0;
   string Ls_A090;
   string Ls_A080;
   string Ls_A070;
   string Ls_A060;
   string Ls_A050;
   string Ls_A040;
   string Ls_A030;
   string Ls_A020;
   string Ls_A010;
   string Ls_A000;
   string Ls_9FF0;
   string Ls_9FE0;
   string Ls_9FD0;
   string Ls_9FC0;
   string Ls_9FB0;
   string Ls_9FA0;
   string Ls_9F90;
   string Ls_9F80;
   string Ls_9F70;
   string Ls_9F60;
   string Ls_9F50;
   string Ls_9F40;
   string Ls_9F30;
   string Ls_9F20;
   string Ls_9F10;
   string Ls_9F00;
   string Ls_9EF0;
   string Ls_9EE0;
   string Ls_9ED0;
   string Ls_9EC0;
   string Ls_9EB0;
   string Ls_9EA0;
   string Ls_9E90;
   string Ls_9E80;
   string Ls_9E70;
   string Ls_9E60;
   string Ls_9E50;
   string Ls_9E40;
   string Ls_9E30;
   string Ls_9E20;
   string Ls_9E10;
   string Ls_9E00;
   string Ls_9DF0;
   string Ls_9DE0;
   string Ls_9DD0;
   string Ls_9DC0;
   string Ls_9DB0;
   string Ls_9DA0;
   string Ls_9D90;
   string Ls_9D80;
   string Ls_9D70;
   string Ls_9D60;
   string Ls_9D50;
   string Ls_9D40;
   string Ls_9D30;
   string Ls_9D20;
   string Ls_9D10;
   string Ls_9D00;
   string Ls_9CF0;
   string Ls_9CE0;
   string Ls_9CD0;
   string Ls_9CC0;
   string Ls_9CB0;
   string Ls_9CA0;
   string Ls_9C90;
   string Ls_9C80;
   string Ls_9C70;
   string Ls_9C60;
   string Ls_9C50;
   string Ls_9C40;
   string Ls_9C30;
   string Ls_9C20;
   string Ls_9C10;
   string Ls_9C00;
   string Ls_9BF0;
   string Ls_9BE0;
   string Ls_9BD0;
   string Ls_9BC0;
   string Ls_9BB0;
   string Ls_9BA0;
   string Ls_9B90;
   string Ls_9B80;
   string Ls_9B70;
   string Ls_9B60;
   string Ls_9B50;
   string Ls_9B40;
   string Ls_9B30;
   string Ls_9B20;
   string Ls_9B10;
   string Ls_9B00;
   string Ls_9AF0;
   string Ls_9AE0;
   string Ls_9AD0;
   string Ls_9AC0;
   string Ls_9AB0;
   string Ls_9AA0;
   string Ls_9A90;
   string Ls_9A80;
   string Ls_9A70;
   string Ls_9A60;
   string Ls_9A50;
   string Ls_9A40;
   string Ls_9A30;
   string Ls_9A20;
   string Ls_9A10;
   string Ls_9A00;
   string Ls_99F0;
   string Ls_99E0;
   string Ls_99D0;
   string Ls_99C0;
   string Ls_99B0;
   string Ls_99A0;
   string Ls_9990;
   string Ls_9980;
   string Ls_9970;
   string Ls_9960;
   string Ls_9950;
   string Ls_9940;
   string Ls_9930;
   string Ls_9920;
   string Ls_9910;
   string Ls_9900;
   string Ls_98F0;
   string Ls_98E0;
   string Ls_98D0;
   string Ls_98C0;
   string Ls_98B0;
   string Ls_98A0;
   string Ls_9890;
   string Ls_9880;
   string Ls_9870;
   string Ls_9860;
   string Ls_9850;
   string Ls_9840;
   string Ls_9830;
   string Ls_9820;
   string Ls_9810;
   string Ls_9800;
   string Ls_97F0;
   string Ls_97E0;
   string Ls_97D0;
   string Ls_97C0;
   string Ls_97B0;
   string Ls_97A0;
   string Ls_9790;
   string Ls_9780;
   string Ls_9770;
   string Ls_9760;
   string Ls_9750;
   string Ls_9740;
   string Ls_9730;
   string Ls_9720;
   string Ls_9710;
   string Ls_9700;
   string Ls_96F0;
   string Ls_96E0;
   string Ls_96D0;
   string Ls_96C0;
   string Ls_96B0;
   string Ls_96A0;
   string Ls_9690;
   string Ls_9680;
   string Ls_9670;
   string Ls_9660;
   string Ls_9650;
   string Ls_9640;
   string Ls_9630;
   string Ls_9620;
   string Ls_9610;
   string Ls_9600;
   string Ls_95F0;
   string Ls_95E0;
   string Ls_95D0;
   string Ls_95C0;
   string Ls_95B0;
   string Ls_95A0;
   string Ls_9590;
   string Ls_9580;
   string Ls_9570;
   string Ls_9560;
   string Ls_9550;
   string Ls_9540;
   string Ls_9530;
   string Ls_9520;
   string Ls_9510;
   string Ls_9500;
   string Ls_94F0;
   string Ls_94E0;
   string Ls_94D0;
   string Ls_94C0;
   string Ls_94B0;
   string Ls_94A0;
   string Ls_9490;
   string Ls_9480;
   string Ls_9470;
   string Ls_9460;
   string Ls_9450;
   string Ls_9440;
   string Ls_9430;
   string Ls_9420;
   string Ls_9410;
   string Ls_9400;
   string Ls_93F0;
   string Ls_93E0;
   string Ls_93D0;
   string Ls_93C0;
   string Ls_93B0;
   string Ls_93A0;
   string Ls_9390;
   string Ls_9380;
   string Ls_9370;
   string Ls_9360;
   string Ls_9350;
   string Ls_9340;
   string Ls_9330;
   string Ls_9320;
   string Ls_9310;
   string Ls_9300;
   string Ls_92F0;
   string Ls_92E0;
   string Ls_92D0;
   string Ls_92C0;
   string Ls_92B0;
   string Ls_92A0;
   string Ls_9290;
   string Ls_9280;
   string Ls_9270;
   string Ls_9260;
   string Ls_9250;
   string Ls_9240;
   string Ls_9230;
   string Ls_9220;
   string Ls_9210;
   string Ls_9200;
   string Ls_91F0;
   string Ls_91E0;
   string Ls_91D0;
   string Ls_91C0;
   string Ls_91B0;
   string Ls_91A0;
   string Ls_9190;
   string Ls_9180;
   string Ls_9170;
   string Ls_9160;
   string Ls_9150;
   string Ls_9140;
   string Ls_9130;
   string Ls_9120;
   string Ls_9110;
   string Ls_9100;
   string Ls_90F0;
   string Ls_90E0;
   string Ls_90D0;
   string Ls_90C0;
   string Ls_90B0;
   string Ls_90A0;
   string Ls_9090;
   string Ls_9080;
   string Ls_9070;
   string Ls_9060;
   string Ls_9050;
   string Ls_9040;
   string Ls_9030;
   string Ls_9020;
   string Ls_9010;
   string Ls_9000;
   string Ls_8FF0;
   string Ls_8FE0;
   string Ls_8FD0;
   string Ls_8FC0;
   string Ls_8FB0;
   string Ls_8FA0;
   string Ls_8F90;
   string Ls_8F80;
   string Ls_8F70;
   string Ls_8F60;
   string Ls_8F50;
   string Ls_8F40;
   string Ls_8F30;
   string Ls_8F20;
   string Ls_8F10;
   string Ls_8F00;
   string Ls_8EF0;
   string Ls_8EE0;
   string Ls_8ED0;
   string Ls_8EC0;
   string Ls_8EB0;
   string Ls_8EA0;
   string Ls_8E90;
   string Ls_8E80;
   string Ls_8E70;
   string Ls_8E60;
   string Ls_8E50;
   string Ls_8E40;
   string Ls_8E30;
   string Ls_8E20;
   string Ls_8E10;
   string Ls_8E00;
   string Ls_8DF0;
   string Ls_8DE0;
   string Ls_8DD0;
   string Ls_8DC0;
   string Ls_8DB0;
   string Ls_8DA0;
   string Ls_8D90;
   string Ls_8D80;
   string Ls_8D70;
   string Ls_8D60;
   string Ls_8D50;
   string Ls_8D40;
   string Ls_8D30;
   string Ls_8D20;
   string Ls_8D10;
   string Ls_8D00;
   string Ls_8CF0;
   string Ls_8CE0;
   string Ls_8CD0;
   string Ls_8CC0;
   string Ls_8CB0;
   string Ls_8CA0;
   string Ls_8C90;
   string Ls_8C80;
   string Ls_8C70;
   string Ls_8C60;
   string Ls_8C50;
   string Ls_8C40;
   string Ls_8C30;
   string Ls_8C20;
   string Ls_8C10;
   string Ls_8C00;
   string Ls_8BF0;
   string Ls_8BE0;
   string Ls_8BD0;
   string Ls_8BC0;
   string Ls_8BB0;
   string Ls_8BA0;
   string Ls_8B90;
   string Ls_8B80;
   string Ls_8B70;
   string Ls_8B60;
   string Ls_8B50;
   string Ls_8B40;
   string Ls_8B30;
   string Ls_8B20;
   string Ls_8B10;
   string Ls_8B00;
   string Ls_8AF0;
   string Ls_8AE0;
   string Ls_8AD0;
   string Ls_8AC0;
   double Ld_8AB8;
   double Ld_8AB0;
   double Ld_8AA8;
   double Ld_8AA0;
   int Li_8A9C;

   Ld_8AB8 = 0;
   Ld_8AB0 = 0;
   Ld_8AA8 = 0;
   Ld_8AA0 = 0;
   Li_8A9C = 0;
   Ld_8AB8 = 0;
   Ld_8AB0 = 0;
   Ld_8AA8 = 0;
   Ld_8AA0 = 0;
   Li_8A9C = 0;
   Ii_0108 = 0;
   Id_0928 = 0;
   Ii_0930 = 0;
   Ii_0118 = 0;
   Ii_011C = 0;
   Ii_0934 = 0;
   Ii_0124 = 0;
   Id_0938 = 0;
   Ii_012C = 0;
   Ii_0940 = 0;
   Ii_0944 = 0;
   Ii_0140 = 0;
   Ii_0948 = 0;
   Id_0950 = 0;
   Ii_0958 = 0;
   Il_0960 = 0;
   Ii_0168 = 0;
   Ii_0968 = 0;
   Ii_0178 = 0;
   Ii_096C = 0;
   Id_0970 = 0;
   Ii_0978 = 0;
   Ii_097C = 0;
   Ii_01A0 = 0;
   Ii_0980 = 0;
   Ii_0984 = 0;
   Id_0988 = 0;
   Ii_0990 = 0;
   Ii_01C8 = 0;
   Ii_0994 = 0;
   Ii_01D8 = 0;
   Ii_0998 = 0;
   Id_01E8 = 0;
   Ii_01F0 = 0;
   Il_09A0 = 0;
   Ii_09A8 = 0;
   Ii_0208 = 0;
   Ii_09AC = 0;
   Ii_0218 = 0;
   Id_0220 = 0;
   Ii_0228 = 0;
   Ii_09B0 = 0;
   Ii_09B4 = 0;
   Ii_0240 = 0;
   Ii_09B8 = 0;
   Id_0250 = 0;
   Ii_0258 = 0;
   Ii_09BC = 0;
   Ii_0268 = 0;
   Ii_09C0 = 0;
   Ii_0278 = 0;
   Id_0280 = 0;
   Ii_09C4 = 0;
   Il_09C8 = 0;
   Ii_09D0 = 0;
   Ii_09D4 = 0;
   Ii_02A8 = 0;
   Ii_09D8 = 0;
   Id_09E0 = 0;
   Ii_09E8 = 0;
   Ii_02C8 = 0;
   Ii_09EC = 0;
   Ii_09F0 = 0;
   Ii_02E0 = 0;
   Id_02E8 = 0;
   Ii_09F4 = 0;
   Ii_02F8 = 0;
   Ii_09F8 = 0;
   Ii_0308 = 0;
   Ii_09FC = 0;
   Id_0A00 = 0;
   Ii_0A08 = 0;
   Il_0A10 = 0;
   Ii_0330 = 0;
   Ii_0A18 = 0;
   Ii_0A1C = 0;
   Ii_0348 = 0;
   Id_0350 = 0;
   Ii_0A20 = 0;
   Ii_035C = 0;
   Ii_0360 = 0;
   Ii_0364 = 0;
   Ii_0A24 = 0;
   Id_0370 = 0;
   Ii_0378 = 0;
   Ii_0A28 = 0;
   Ii_0388 = 0;
   Ii_0A2C = 0;
   Ii_0A30 = 0;
   Id_0A38 = 0;
   Ii_0A40 = 0;
   Il_0A48 = 0;
   Ii_0A50 = 0;
   Ii_03C0 = 0;
   Ii_0A54 = 0;
   Ii_0A58 = 0;
   Id_0A60 = 0;
   Ii_0A68 = 0;
   Ii_0A6C = 0;
   Ii_03F0 = 0;
   Ii_0A70 = 0;
   Ii_0400 = 0;
   Id_0408 = 0;
   Ii_0410 = 0;
   Ii_0A74 = 0;
   Ii_0A78 = 0;
   Ii_0428 = 0;
   Ii_0A7C = 0;
   Id_0438 = 0;
   Ii_0440 = 0;
   Il_0A80 = 0;
   Ii_0450 = 0;
   Ii_0A88 = 0;
   Ii_0460 = 0;
   Ii_0A8C = 0;
   Id_0470 = 0;
   Ii_0478 = 0;
   Ii_0A90 = 0;
   Ii_0A94 = 0;
   Ii_0490 = 0;
   Ii_0A98 = 0;
   Id_0AA0 = 0;
   Ii_0AA8 = 0;
   Ii_04B0 = 0;
   Ii_0AAC = 0;
   Ii_0AB0 = 0;
   Ii_04C8 = 0;
   Id_04D0 = 0;
   Ii_0AB4 = 0;
   Il_0AB8 = 0;
   Ii_0AC0 = 0;
   Ii_04F0 = 0;
   Ii_0AC4 = 0;
   Ii_0500 = 0;
   Id_0508 = 0;
   Ii_0AC8 = 0;
   Ii_0518 = 0;
   Ii_0ACC = 0;
   Ii_0AD0 = 0;
   Ii_0530 = 0;
   Id_0538 = 0;
   Ii_0540 = 0;
   Ii_0AD4 = 0;
   Ii_0550 = 0;
   Ii_0AD8 = 0;
   Ii_0ADC = 0;
   Id_0AE0 = 0;
   Ii_0AE8 = 0;
   Il_0AF0 = 0;
   Ii_0580 = 0;
   Ii_0AF8 = 0;
   Ii_0AFC = 0;
   Ii_0598 = 0;
   Id_05A0 = 0;
   Ii_05A8 = 0;
   Ii_05AC = 0;
   Ii_0B00 = 0;
   Ii_05B8 = 0;
   Ii_0B04 = 0;
   Id_0B08 = 0;
   Ii_0B10 = 0;
   Ii_05D8 = 0;
   Ii_05DC = 0;
   Ii_0B14 = 0;
   Ii_05E8 = 0;
   Id_05F0 = 0;
   Ii_05F8 = 0;
   Il_0B18 = 0;
   Ii_0608 = 0;
   Ii_0B20 = 0;
   Ii_0618 = 0;
   Ii_0B24 = 0;
   Id_0B28 = 0;
   Ii_062C = 0;
   Ii_0B30 = 0;
   Ii_0638 = 0;
   Ii_063C = 0;
   Ii_0B34 = 0;
   Id_0B38 = 0;
   Ii_0B40 = 0;
   Ii_0658 = 0;
   Ii_0B44 = 0;
   Ii_0668 = 0;
   Ii_066C = 0;
   Id_0670 = 0;
   Ii_0678 = 0;
   Il_0B48 = 0;
   Ii_0688 = 0;
   Ii_0B50 = 0;
   Ii_0698 = 0;
   Ii_069C = 0;
   Id_06A0 = 0;
   Ii_06A8 = 0;
   Ii_0B54 = 0;
   Ii_06B8 = 0;
   Ii_0B58 = 0;
   Ii_06C8 = 0;
   Id_06D0 = 0;
   Ii_06D8 = 0;
   Ii_0B5C = 0;
   Ii_06E8 = 0;
   Ii_06EC = 0;
   Ii_0B60 = 0;
   Id_0B68 = 0;
   Ii_06FC = 0;
   Il_0B70 = 0;
   Ii_0708 = 0;
   Ii_0710 = 0;
   Ii_0728 = 0;
   Ii_0738 = 0;
   Id_0B78 = 0;
   Ii_075C = 0;
   Ii_0770 = 0;
   Ii_0790 = 0;
   Ii_08D0 = 0;
   Ii_07C8 = 0;
   Id_07E0 = 0;
   Ii_07F4 = 0;
   Ii_0810 = 0;
   Ii_08C4 = 0;
   Ii_0820 = 0;
   Ii_0838 = 0;
   Id_0840 = 0;
   Ii_085C = 0;
   Il_0B80 = 0;
   Ii_0870 = 0;
   Ii_0880 = 0;
   Ii_0894 = 0;
   Ii_08A0 = 0;
   Id_08B8 = 0;
   Ii_0B88 = 0;
   Ii_0B8C = 0;
   Ii_0B90 = 0;
   Ii_0B94 = 0;
   Ii_0B98 = 0;
   Id_0BA0 = 0;
   Ii_0BA8 = 0;
   Ii_0BAC = 0;
   Ii_0BB0 = 0;
   Ii_0BB4 = 0;
   Ii_0BB8 = 0;
   Id_0BC0 = 0;
   Ii_0BC8 = 0;
   Il_0BD0 = 0;
   Ii_0BD8 = 0;
   Ii_0BDC = 0;
   Ii_0BE0 = 0;
   Ii_0BE4 = 0;
   Id_0BE8 = 0;
   Ii_0BF0 = 0;
   Ii_0BF4 = 0;
   Ii_0BF8 = 0;
   Ii_0BFC = 0;
   Ii_0C00 = 0;
   Id_0C08 = 0;
   Ii_0C10 = 0;
   Ii_0C14 = 0;
   Ii_0C18 = 0;
   Ii_0C1C = 0;
   Ii_0C20 = 0;
   Id_0C28 = 0;
   Ii_0C30 = 0;
   Il_0C38 = 0;
   Ii_0C40 = 0;
   Ii_0C44 = 0;
   Ii_0C48 = 0;
   Ld_8AB8 = 0;
   Ld_8AB0 = 0;
   Ld_8AA8 = 0;
   Ld_8AA0 = 0;
   Li_8A9C = 0;
   if (Fa_i_00 == Ii_006C) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_006C, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0108 = Ii_006C;
   Id_0928 = 0;
   if (Ii_006C == Ii_006C) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0070) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0074) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0078) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_007C) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0080) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0084) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0088) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_008C) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0090) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0094) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_0098) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_009C) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   if (Ii_0108 == Ii_00A0) { 
   Id_0928 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0928, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_FFF0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_FFF0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_FFD0 = "";
   Ls_FFC0 = "";
   Ls_FFB0 = "";
   Ls_FFA0 = "";
   Ls_FF90 = "";
   Ls_FF80 = "";
   Ls_FF70 = (string)Ld_8AA8;
   Ls_FF60 = " to :";
   Ls_FF50 = (string)Fa_i_00;
   Ls_FF40 = ", Magic Number: ";
   Ls_FF30 = (string)OrderTicket();
   Ls_FF20 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FF10 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FF10, " ", Ls_FF20, Ls_FF30, Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0930 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0930 > 0) { 
   FileSeek(Ii_0930, 0, 2);
   Ls_FF00 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0930, Ls_FF00, " VERBOSE: ", Ls_FF20, Ls_FF30, Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0);
   FileClose(Ii_0930);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0003 = GetLastError();
   Ii_0C78 = Gi_0003;
   Li_8A9C = Gi_0003;
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = "";
   Ls_FE90 = "";
   Ls_FE80 = "";
   Ls_FE70 = func_1032(Gi_0003);
   Ls_FE60 = " - ";
   Ls_FE50 = (string)Ii_0C78;
   Ls_FE40 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_FE30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FE30, " ", Ls_FE40, Ls_FE50, Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0118 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0118 > 0) {
   FileSeek(Ii_0118, 0, 2);
   Ls_FE20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0118, Ls_FE20, " VERBOSE: ", Ls_FE40, Ls_FE50, Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0);
   FileClose(Ii_0118);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_FE10 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_FE10 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_FDF0 = "";
   Ls_FDE0 = "";
   Ls_FDD0 = "";
   Ls_FDC0 = "";
   Ls_FDB0 = "";
   Ls_FDA0 = "";
   Ls_FD90 = (string)Ld_8AA8;
   Ls_FD80 = " to :";
   Ls_FD70 = (string)Fa_i_00;
   Ls_FD60 = ", Magic Number: ";
   Ls_FD50 = (string)OrderTicket();
   Ls_FD40 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FD30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FD30, " ", Ls_FD40, Ls_FD50, Ls_FD60, Ls_FD70, Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_011C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_011C > 0) { 
   FileSeek(Ii_011C, 0, 2);
   Ls_FD20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_011C, Ls_FD20, " VERBOSE: ", Ls_FD40, Ls_FD50, Ls_FD60, Ls_FD70, Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0);
   FileClose(Ii_011C);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0005 = GetLastError();
   Ii_17A0 = Gi_0005;
   Li_8A9C = Gi_0005;
   Ls_FD10 = "";
   Ls_FD00 = "";
   Ls_FCF0 = (string)OrderStopLoss();
   Ls_FCE0 = " Current SL: ";
   Ls_FCD0 = (string)Bid;
   Ls_FCC0 = ", Bid: ";
   Ls_FCB0 = (string)Ask;
   Ls_FCA0 = ", Ask: ";
   Ls_FC90 = func_1032(Gi_0005);
   Ls_FC80 = " - ";
   Ls_FC70 = (string)Ii_17A0;
   Ls_FC60 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_FC50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FC50, " ", Ls_FC60, Ls_FC70, Ls_FC80, Ls_FC90, Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0934 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0934 > 0) { 
   FileSeek(Ii_0934, 0, 2);
   Ls_FC40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0934, Ls_FC40, " VERBOSE: ", Ls_FC60, Ls_FC70, Ls_FC80, Ls_FC90, Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10);
   FileClose(Ii_0934);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_006C, OrderType(), OrderOpenPrice());
   Ii_0124 = Ii_006C;
   Id_0938 = 0;
   if (Ii_006C == Ii_006C) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0070) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0074) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0078) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_007C) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0080) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0084) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0088) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_008C) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0090) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0094) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_0098) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_009C) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   if (Ii_0124 == Ii_00A0) { 
   Id_0938 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0938, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_FC30 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_FC30 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_FC10 = "";
   Ls_FC00 = "";
   Ls_FBF0 = "";
   Ls_FBE0 = "";
   Ls_FBD0 = "";
   Ls_FBC0 = "";
   Ls_FBB0 = (string)Ld_8AA8;
   Ls_FBA0 = " to :";
   Ls_FB90 = (string)Fa_i_00;
   Ls_FB80 = ", Magic Number: ";
   Ls_FB70 = (string)OrderTicket();
   Ls_FB60 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FB50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FB50, " ", Ls_FB60, Ls_FB70, Ls_FB80, Ls_FB90, Ls_FBA0, Ls_FBB0, Ls_FBC0, Ls_FBD0, Ls_FBE0, Ls_FBF0, Ls_FC00, Ls_FC10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_012C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_012C > 0) { 
   FileSeek(Ii_012C, 0, 2);
   Ls_FB40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_012C, Ls_FB40, " VERBOSE: ", Ls_FB60, Ls_FB70, Ls_FB80, Ls_FB90, Ls_FBA0, Ls_FBB0, Ls_FBC0, Ls_FBD0, Ls_FBE0, Ls_FBF0, Ls_FC00, Ls_FC10);
   FileClose(Ii_012C);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0008 = GetLastError();
   Ii_0CB0 = Gi_0008;
   Li_8A9C = Gi_0008;
   Ls_FB30 = "";
   Ls_FB20 = "";
   Ls_FB10 = (string)OrderStopLoss();
   Ls_FB00 = " Current SL: ";
   Ls_FAF0 = (string)Bid;
   Ls_FAE0 = ", Bid: ";
   Ls_FAD0 = (string)Ask;
   Ls_FAC0 = ", Ask: ";
   Ls_FAB0 = func_1032(Gi_0008);
   Ls_FAA0 = " - ";
   Ls_FA90 = (string)Ii_0CB0;
   Ls_FA80 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_FA70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FA70, " ", Ls_FA80, Ls_FA90, Ls_FAA0, Ls_FAB0, Ls_FAC0, Ls_FAD0, Ls_FAE0, Ls_FAF0, Ls_FB00, Ls_FB10, Ls_FB20, Ls_FB30);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0940 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0940 > 0) {
   FileSeek(Ii_0940, 0, 2);
   Ls_FA60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0940, Ls_FA60, " VERBOSE: ", Ls_FA80, Ls_FA90, Ls_FAA0, Ls_FAB0, Ls_FAC0, Ls_FAD0, Ls_FAE0, Ls_FAF0, Ls_FB00, Ls_FB10, Ls_FB20, Ls_FB30);
   FileClose(Ii_0940);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_FA50 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_FA50 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_FA30 = "";
   Ls_FA20 = "";
   Ls_FA10 = "";
   Ls_FA00 = "";
   Ls_F9F0 = "";
   Ls_F9E0 = "";
   Ls_F9D0 = (string)Ld_8AA8;
   Ls_F9C0 = " to :";
   Ls_F9B0 = (string)Fa_i_00;
   Ls_F9A0 = ", Magic Number: ";
   Ls_F990 = (string)OrderTicket();
   Ls_F980 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F970 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F970, " ", Ls_F980, Ls_F990, Ls_F9A0, Ls_F9B0, Ls_F9C0, Ls_F9D0, Ls_F9E0, Ls_F9F0, Ls_FA00, Ls_FA10, Ls_FA20, Ls_FA30);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0944 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0944 > 0) { 
   FileSeek(Ii_0944, 0, 2);
   Ls_F960 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0944, Ls_F960, " VERBOSE: ", Ls_F980, Ls_F990, Ls_F9A0, Ls_F9B0, Ls_F9C0, Ls_F9D0, Ls_F9E0, Ls_F9F0, Ls_FA00, Ls_FA10, Ls_FA20, Ls_FA30);
   FileClose(Ii_0944);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_000A = GetLastError();
   Ii_0CC4 = Gi_000A;
   Li_8A9C = Gi_000A;
   Ls_F950 = "";
   Ls_F940 = "";
   Ls_F930 = (string)OrderStopLoss();
   Ls_F920 = " Current SL: ";
   Ls_F910 = (string)Bid;
   Ls_F900 = ", Bid: ";
   Ls_F8F0 = (string)Ask;
   Ls_F8E0 = ", Ask: ";
   Ls_F8D0 = func_1032(Gi_000A);
   Ls_F8C0 = " - ";
   Ls_F8B0 = (string)Ii_0CC4;
   Ls_F8A0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_F890 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F890, " ", Ls_F8A0, Ls_F8B0, Ls_F8C0, Ls_F8D0, Ls_F8E0, Ls_F8F0, Ls_F900, Ls_F910, Ls_F920, Ls_F930, Ls_F940, Ls_F950);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0140 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0140 > 0) { 
   FileSeek(Ii_0140, 0, 2);
   Ls_F880 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0140, Ls_F880, " VERBOSE: ", Ls_F8A0, Ls_F8B0, Ls_F8C0, Ls_F8D0, Ls_F8E0, Ls_F8F0, Ls_F900, Ls_F910, Ls_F920, Ls_F930, Ls_F940, Ls_F950);
   FileClose(Ii_0140);
   }}}}}}}}} 
   Ii_0948 = Ii_006C;
   Id_0950 = 0;
   if (Ii_006C == Ii_006C) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0070) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0074) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0078) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_007C) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0080) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0084) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0088) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_008C) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0090) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0094) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_0098) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_009C) { 
   Id_0950 = 0;
   } 
   if (Ii_0948 == Ii_00A0) { 
   Id_0950 = 0;
   } 
   returned_double = NormalizeDouble(Id_0950, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_0958 = (int)(returned_double + 10);
   Il_0960 = OrderOpenTime();
   Ii_0168 = 0;
   Ii_0968 = 0;
   Ii_0CC4 = Ii_0958 + 10;
   if (Ii_0CC4 > 0) { 
   do { 
   if (Il_0960 < Time[Ii_0968]) { 
   Ii_0168 = Ii_0168 + 1;
   } 
   Ii_0968 = Ii_0968 + 1;
   Ii_0CD0 = Ii_0958 + 10;
   } while (Ii_0968 < Ii_0CD0); 
   } 
   if ((Ii_0168 >= Ld_8AB8)) { 
   Ls_F870 = "";
   Ls_F860 = "";
   Ls_F850 = "";
   Ls_F840 = "";
   Ls_F830 = "";
   Ls_F820 = "";
   Ls_F810 = (string)Fa_i_00;
   Ls_F800 = ", Magic Number: ";
   Ls_F7F0 = (string)OrderTicket();
   Ls_F7E0 = "bars - closing order with ticket: ";
   Ls_F7D0 = (string)Ld_8AB8;
   Ls_F7C0 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_F7B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F7B0, " ", Ls_F7C0, Ls_F7D0, Ls_F7E0, Ls_F7F0, Ls_F800, Ls_F810, Ls_F820, Ls_F830, Ls_F840, Ls_F850, Ls_F860, Ls_F870);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0178 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0178 > 0) { 
   FileSeek(Ii_0178, 0, 2);
   Ls_F7A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0178, Ls_F7A0, " VERBOSE: ", Ls_F7C0, Ls_F7D0, Ls_F7E0, Ls_F7F0, Ls_F800, Ls_F810, Ls_F820, Ls_F830, Ls_F840, Ls_F850, Ls_F860, Ls_F870);
   FileClose(Ii_0178);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0070) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0070, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_096C = Ii_0070;
   Id_0970 = 0;
   if (Ii_0070 == Ii_006C) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0070) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0074) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0078) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_007C) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0080) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0084) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0088) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_008C) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0090) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0094) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_0098) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_009C) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   if (Ii_096C == Ii_00A0) { 
   Id_0970 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0970, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_F790 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_F790 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_F770 = "";
   Ls_F760 = "";
   Ls_F750 = "";
   Ls_F740 = "";
   Ls_F730 = "";
   Ls_F720 = "";
   Ls_F710 = (string)Ld_8AA8;
   Ls_F700 = " to :";
   Ls_F6F0 = (string)Fa_i_00;
   Ls_F6E0 = ", Magic Number: ";
   Ls_F6D0 = (string)OrderTicket();
   Ls_F6C0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F6B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F6B0, " ", Ls_F6C0, Ls_F6D0, Ls_F6E0, Ls_F6F0, Ls_F700, Ls_F710, Ls_F720, Ls_F730, Ls_F740, Ls_F750, Ls_F760, Ls_F770);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0978 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0978 > 0) { 
   FileSeek(Ii_0978, 0, 2);
   Ls_F6A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0978, Ls_F6A0, " VERBOSE: ", Ls_F6C0, Ls_F6D0, Ls_F6E0, Ls_F6F0, Ls_F700, Ls_F710, Ls_F720, Ls_F730, Ls_F740, Ls_F750, Ls_F760, Ls_F770);
   FileClose(Ii_0978);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_000E = GetLastError();
   Ii_0D08 = Gi_000E;
   Li_8A9C = Gi_000E;
   Ls_F690 = "";
   Ls_F680 = "";
   Ls_F670 = "";
   Ls_F660 = "";
   Ls_F650 = "";
   Ls_F640 = "";
   Ls_F630 = "";
   Ls_F620 = "";
   Ls_F610 = func_1032(Gi_000E);
   Ls_F600 = " - ";
   Ls_F5F0 = (string)Ii_0D08;
   Ls_F5E0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_F5D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F5D0, " ", Ls_F5E0, Ls_F5F0, Ls_F600, Ls_F610, Ls_F620, Ls_F630, Ls_F640, Ls_F650, Ls_F660, Ls_F670, Ls_F680, Ls_F690);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_097C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_097C > 0) {
   FileSeek(Ii_097C, 0, 2);
   Ls_F5C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_097C, Ls_F5C0, " VERBOSE: ", Ls_F5E0, Ls_F5F0, Ls_F600, Ls_F610, Ls_F620, Ls_F630, Ls_F640, Ls_F650, Ls_F660, Ls_F670, Ls_F680, Ls_F690);
   FileClose(Ii_097C);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_F5B0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_F5B0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_F590 = "";
   Ls_F580 = "";
   Ls_F570 = "";
   Ls_F560 = "";
   Ls_F550 = "";
   Ls_F540 = "";
   Ls_F530 = (string)Ld_8AA8;
   Ls_F520 = " to :";
   Ls_F510 = (string)Fa_i_00;
   Ls_F500 = ", Magic Number: ";
   Ls_F4F0 = (string)OrderTicket();
   Ls_F4E0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F4D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F4D0, " ", Ls_F4E0, Ls_F4F0, Ls_F500, Ls_F510, Ls_F520, Ls_F530, Ls_F540, Ls_F550, Ls_F560, Ls_F570, Ls_F580, Ls_F590);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_01A0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_01A0 > 0) { 
   FileSeek(Ii_01A0, 0, 2);
   Ls_F4C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_01A0, Ls_F4C0, " VERBOSE: ", Ls_F4E0, Ls_F4F0, Ls_F500, Ls_F510, Ls_F520, Ls_F530, Ls_F540, Ls_F550, Ls_F560, Ls_F570, Ls_F580, Ls_F590);
   FileClose(Ii_01A0);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0010 = GetLastError();
   Ii_1760 = Gi_0010;
   Li_8A9C = Gi_0010;
   Ls_F4B0 = "";
   Ls_F4A0 = "";
   Ls_F490 = (string)OrderStopLoss();
   Ls_F480 = " Current SL: ";
   Ls_F470 = (string)Bid;
   Ls_F460 = ", Bid: ";
   Ls_F450 = (string)Ask;
   Ls_F440 = ", Ask: ";
   Ls_F430 = func_1032(Gi_0010);
   Ls_F420 = " - ";
   Ls_F410 = (string)Ii_1760;
   Ls_F400 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_F3F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F3F0, " ", Ls_F400, Ls_F410, Ls_F420, Ls_F430, Ls_F440, Ls_F450, Ls_F460, Ls_F470, Ls_F480, Ls_F490, Ls_F4A0, Ls_F4B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0980 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0980 > 0) { 
   FileSeek(Ii_0980, 0, 2);
   Ls_F3E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0980, Ls_F3E0, " VERBOSE: ", Ls_F400, Ls_F410, Ls_F420, Ls_F430, Ls_F440, Ls_F450, Ls_F460, Ls_F470, Ls_F480, Ls_F490, Ls_F4A0, Ls_F4B0);
   FileClose(Ii_0980);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0070, OrderType(), OrderOpenPrice());
   Ii_0984 = Ii_0070;
   Id_0988 = 0;
   if (Ii_0070 == Ii_006C) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0070) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0074) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0078) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_007C) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0080) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0084) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0088) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_008C) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0090) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0094) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_0098) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_009C) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   if (Ii_0984 == Ii_00A0) { 
   Id_0988 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0988, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_F3D0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_F3D0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_F3B0 = "";
   Ls_F3A0 = "";
   Ls_F390 = "";
   Ls_F380 = "";
   Ls_F370 = "";
   Ls_F360 = "";
   Ls_F350 = (string)Ld_8AA8;
   Ls_F340 = " to :";
   Ls_F330 = (string)Fa_i_00;
   Ls_F320 = ", Magic Number: ";
   Ls_F310 = (string)OrderTicket();
   Ls_F300 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F2F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F2F0, " ", Ls_F300, Ls_F310, Ls_F320, Ls_F330, Ls_F340, Ls_F350, Ls_F360, Ls_F370, Ls_F380, Ls_F390, Ls_F3A0, Ls_F3B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0990 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0990 > 0) { 
   FileSeek(Ii_0990, 0, 2);
   Ls_F2E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0990, Ls_F2E0, " VERBOSE: ", Ls_F300, Ls_F310, Ls_F320, Ls_F330, Ls_F340, Ls_F350, Ls_F360, Ls_F370, Ls_F380, Ls_F390, Ls_F3A0, Ls_F3B0);
   FileClose(Ii_0990);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0013 = GetLastError();
   Ii_0D40 = Gi_0013;
   Li_8A9C = Gi_0013;
   Ls_F2D0 = "";
   Ls_F2C0 = "";
   Ls_F2B0 = (string)OrderStopLoss();
   Ls_F2A0 = " Current SL: ";
   Ls_F290 = (string)Bid;
   Ls_F280 = ", Bid: ";
   Ls_F270 = (string)Ask;
   Ls_F260 = ", Ask: ";
   Ls_F250 = func_1032(Gi_0013);
   Ls_F240 = " - ";
   Ls_F230 = (string)Ii_0D40;
   Ls_F220 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_F210 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F210, " ", Ls_F220, Ls_F230, Ls_F240, Ls_F250, Ls_F260, Ls_F270, Ls_F280, Ls_F290, Ls_F2A0, Ls_F2B0, Ls_F2C0, Ls_F2D0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_01C8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_01C8 > 0) {
   FileSeek(Ii_01C8, 0, 2);
   Ls_F200 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_01C8, Ls_F200, " VERBOSE: ", Ls_F220, Ls_F230, Ls_F240, Ls_F250, Ls_F260, Ls_F270, Ls_F280, Ls_F290, Ls_F2A0, Ls_F2B0, Ls_F2C0, Ls_F2D0);
   FileClose(Ii_01C8);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_F1F0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_F1F0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_F1D0 = "";
   Ls_F1C0 = "";
   Ls_F1B0 = "";
   Ls_F1A0 = "";
   Ls_F190 = "";
   Ls_F180 = "";
   Ls_F170 = (string)Ld_8AA8;
   Ls_F160 = " to :";
   Ls_F150 = (string)Fa_i_00;
   Ls_F140 = ", Magic Number: ";
   Ls_F130 = (string)OrderTicket();
   Ls_F120 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F110 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F110, " ", Ls_F120, Ls_F130, Ls_F140, Ls_F150, Ls_F160, Ls_F170, Ls_F180, Ls_F190, Ls_F1A0, Ls_F1B0, Ls_F1C0, Ls_F1D0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0994 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0994 > 0) { 
   FileSeek(Ii_0994, 0, 2);
   Ls_F100 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0994, Ls_F100, " VERBOSE: ", Ls_F120, Ls_F130, Ls_F140, Ls_F150, Ls_F160, Ls_F170, Ls_F180, Ls_F190, Ls_F1A0, Ls_F1B0, Ls_F1C0, Ls_F1D0);
   FileClose(Ii_0994);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0015 = GetLastError();
   Ii_0D54 = Gi_0015;
   Li_8A9C = Gi_0015;
   Ls_F0F0 = "";
   Ls_F0E0 = "";
   Ls_F0D0 = (string)OrderStopLoss();
   Ls_F0C0 = " Current SL: ";
   Ls_F0B0 = (string)Bid;
   Ls_F0A0 = ", Bid: ";
   Ls_F090 = (string)Ask;
   Ls_F080 = ", Ask: ";
   Ls_F070 = func_1032(Gi_0015);
   Ls_F060 = " - ";
   Ls_F050 = (string)Ii_0D54;
   Ls_F040 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_F030 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F030, " ", Ls_F040, Ls_F050, Ls_F060, Ls_F070, Ls_F080, Ls_F090, Ls_F0A0, Ls_F0B0, Ls_F0C0, Ls_F0D0, Ls_F0E0, Ls_F0F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_01D8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_01D8 > 0) { 
   FileSeek(Ii_01D8, 0, 2);
   Ls_F020 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_01D8, Ls_F020, " VERBOSE: ", Ls_F040, Ls_F050, Ls_F060, Ls_F070, Ls_F080, Ls_F090, Ls_F0A0, Ls_F0B0, Ls_F0C0, Ls_F0D0, Ls_F0E0, Ls_F0F0);
   FileClose(Ii_01D8);
   }}}}}}}}} 
   Ii_0998 = Ii_0070;
   Id_01E8 = 0;
   if (Ii_0070 == Ii_006C) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0070) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0074) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0078) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_007C) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0080) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0084) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0088) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_008C) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0090) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0094) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_0098) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_009C) { 
   Id_01E8 = 0;
   } 
   if (Ii_0998 == Ii_00A0) { 
   Id_01E8 = 0;
   } 
   returned_double = NormalizeDouble(Id_01E8, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_01F0 = (int)(returned_double + 10);
   Il_09A0 = OrderOpenTime();
   Ii_09A8 = 0;
   Ii_0208 = 0;
   Ii_0D54 = Ii_01F0 + 10;
   if (Ii_0D54 > 0) { 
   do { 
   if (Il_09A0 < Time[Ii_0208]) { 
   Ii_09A8 = Ii_09A8 + 1;
   } 
   Ii_0208 = Ii_0208 + 1;
   Ii_0D60 = Ii_01F0 + 10;
   } while (Ii_0208 < Ii_0D60); 
   } 
   if ((Ii_09A8 >= Ld_8AB8)) { 
   Ls_F010 = "";
   Ls_F000 = "";
   Ls_EFF0 = "";
   Ls_EFE0 = "";
   Ls_EFD0 = "";
   Ls_EFC0 = "";
   Ls_EFB0 = (string)Fa_i_00;
   Ls_EFA0 = ", Magic Number: ";
   Ls_EF90 = (string)OrderTicket();
   Ls_EF80 = "bars - closing order with ticket: ";
   Ls_EF70 = (string)Ld_8AB8;
   Ls_EF60 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_EF50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_EF50, " ", Ls_EF60, Ls_EF70, Ls_EF80, Ls_EF90, Ls_EFA0, Ls_EFB0, Ls_EFC0, Ls_EFD0, Ls_EFE0, Ls_EFF0, Ls_F000, Ls_F010);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09AC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09AC > 0) { 
   FileSeek(Ii_09AC, 0, 2);
   Ls_EF40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09AC, Ls_EF40, " VERBOSE: ", Ls_EF60, Ls_EF70, Ls_EF80, Ls_EF90, Ls_EFA0, Ls_EFB0, Ls_EFC0, Ls_EFD0, Ls_EFE0, Ls_EFF0, Ls_F000, Ls_F010);
   FileClose(Ii_09AC);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0074) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0074, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0218 = Ii_0074;
   Id_0220 = 0;
   if (Ii_0074 == Ii_006C) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0070) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0074) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0078) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_007C) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0080) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0084) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0088) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_008C) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0090) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0094) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_0098) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_009C) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   if (Ii_0218 == Ii_00A0) { 
   Id_0220 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0220, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_EF30 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_EF30 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_EF10 = "";
   Ls_EF00 = "";
   Ls_EEF0 = "";
   Ls_EEE0 = "";
   Ls_EED0 = "";
   Ls_EEC0 = "";
   Ls_EEB0 = (string)Ld_8AA8;
   Ls_EEA0 = " to :";
   Ls_EE90 = (string)Fa_i_00;
   Ls_EE80 = ", Magic Number: ";
   Ls_EE70 = (string)OrderTicket();
   Ls_EE60 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_EE50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_EE50, " ", Ls_EE60, Ls_EE70, Ls_EE80, Ls_EE90, Ls_EEA0, Ls_EEB0, Ls_EEC0, Ls_EED0, Ls_EEE0, Ls_EEF0, Ls_EF00, Ls_EF10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0228 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0228 > 0) { 
   FileSeek(Ii_0228, 0, 2);
   Ls_EE40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0228, Ls_EE40, " VERBOSE: ", Ls_EE60, Ls_EE70, Ls_EE80, Ls_EE90, Ls_EEA0, Ls_EEB0, Ls_EEC0, Ls_EED0, Ls_EEE0, Ls_EEF0, Ls_EF00, Ls_EF10);
   FileClose(Ii_0228);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0019 = GetLastError();
   Ii_0D98 = Gi_0019;
   Li_8A9C = Gi_0019;
   Ls_EE30 = "";
   Ls_EE20 = "";
   Ls_EE10 = "";
   Ls_EE00 = "";
   Ls_EDF0 = "";
   Ls_EDE0 = "";
   Ls_EDD0 = "";
   Ls_EDC0 = "";
   Ls_EDB0 = func_1032(Gi_0019);
   Ls_EDA0 = " - ";
   Ls_ED90 = (string)Ii_0D98;
   Ls_ED80 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_ED70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_ED70, " ", Ls_ED80, Ls_ED90, Ls_EDA0, Ls_EDB0, Ls_EDC0, Ls_EDD0, Ls_EDE0, Ls_EDF0, Ls_EE00, Ls_EE10, Ls_EE20, Ls_EE30);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_09B0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09B0 > 0) {
   FileSeek(Ii_09B0, 0, 2);
   Ls_ED60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09B0, Ls_ED60, " VERBOSE: ", Ls_ED80, Ls_ED90, Ls_EDA0, Ls_EDB0, Ls_EDC0, Ls_EDD0, Ls_EDE0, Ls_EDF0, Ls_EE00, Ls_EE10, Ls_EE20, Ls_EE30);
   FileClose(Ii_09B0);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_ED50 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_ED50 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_ED30 = "";
   Ls_ED20 = "";
   Ls_ED10 = "";
   Ls_ED00 = "";
   Ls_ECF0 = "";
   Ls_ECE0 = "";
   Ls_ECD0 = (string)Ld_8AA8;
   Ls_ECC0 = " to :";
   Ls_ECB0 = (string)Fa_i_00;
   Ls_ECA0 = ", Magic Number: ";
   Ls_EC90 = (string)OrderTicket();
   Ls_EC80 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_EC70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_EC70, " ", Ls_EC80, Ls_EC90, Ls_ECA0, Ls_ECB0, Ls_ECC0, Ls_ECD0, Ls_ECE0, Ls_ECF0, Ls_ED00, Ls_ED10, Ls_ED20, Ls_ED30);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09B4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09B4 > 0) { 
   FileSeek(Ii_09B4, 0, 2);
   Ls_EC60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09B4, Ls_EC60, " VERBOSE: ", Ls_EC80, Ls_EC90, Ls_ECA0, Ls_ECB0, Ls_ECC0, Ls_ECD0, Ls_ECE0, Ls_ECF0, Ls_ED00, Ls_ED10, Ls_ED20, Ls_ED30);
   FileClose(Ii_09B4);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_001B = GetLastError();
   Ii_1720 = Gi_001B;
   Li_8A9C = Gi_001B;
   Ls_EC50 = "";
   Ls_EC40 = "";
   Ls_EC30 = (string)OrderStopLoss();
   Ls_EC20 = " Current SL: ";
   Ls_EC10 = (string)Bid;
   Ls_EC00 = ", Bid: ";
   Ls_EBF0 = (string)Ask;
   Ls_EBE0 = ", Ask: ";
   Ls_EBD0 = func_1032(Gi_001B);
   Ls_EBC0 = " - ";
   Ls_EBB0 = (string)Ii_1720;
   Ls_EBA0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_EB90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_EB90, " ", Ls_EBA0, Ls_EBB0, Ls_EBC0, Ls_EBD0, Ls_EBE0, Ls_EBF0, Ls_EC00, Ls_EC10, Ls_EC20, Ls_EC30, Ls_EC40, Ls_EC50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0240 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0240 > 0) { 
   FileSeek(Ii_0240, 0, 2);
   Ls_EB80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0240, Ls_EB80, " VERBOSE: ", Ls_EBA0, Ls_EBB0, Ls_EBC0, Ls_EBD0, Ls_EBE0, Ls_EBF0, Ls_EC00, Ls_EC10, Ls_EC20, Ls_EC30, Ls_EC40, Ls_EC50);
   FileClose(Ii_0240);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0074, OrderType(), OrderOpenPrice());
   Ii_09B8 = Ii_0074;
   Id_0250 = 0;
   if (Ii_0074 == Ii_006C) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0070) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0074) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0078) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_007C) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0080) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0084) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0088) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_008C) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0090) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0094) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_0098) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_009C) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   if (Ii_09B8 == Ii_00A0) { 
   Id_0250 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0250, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_EB70 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_EB70 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_EB50 = "";
   Ls_EB40 = "";
   Ls_EB30 = "";
   Ls_EB20 = "";
   Ls_EB10 = "";
   Ls_EB00 = "";
   Ls_EAF0 = (string)Ld_8AA8;
   Ls_EAE0 = " to :";
   Ls_EAD0 = (string)Fa_i_00;
   Ls_EAC0 = ", Magic Number: ";
   Ls_EAB0 = (string)OrderTicket();
   Ls_EAA0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_EA90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_EA90, " ", Ls_EAA0, Ls_EAB0, Ls_EAC0, Ls_EAD0, Ls_EAE0, Ls_EAF0, Ls_EB00, Ls_EB10, Ls_EB20, Ls_EB30, Ls_EB40, Ls_EB50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0258 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0258 > 0) { 
   FileSeek(Ii_0258, 0, 2);
   Ls_EA80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0258, Ls_EA80, " VERBOSE: ", Ls_EAA0, Ls_EAB0, Ls_EAC0, Ls_EAD0, Ls_EAE0, Ls_EAF0, Ls_EB00, Ls_EB10, Ls_EB20, Ls_EB30, Ls_EB40, Ls_EB50);
   FileClose(Ii_0258);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_001E = GetLastError();
   Ii_0DD0 = Gi_001E;
   Li_8A9C = Gi_001E;
   Ls_EA70 = "";
   Ls_EA60 = "";
   Ls_EA50 = (string)OrderStopLoss();
   Ls_EA40 = " Current SL: ";
   Ls_EA30 = (string)Bid;
   Ls_EA20 = ", Bid: ";
   Ls_EA10 = (string)Ask;
   Ls_EA00 = ", Ask: ";
   Ls_E9F0 = func_1032(Gi_001E);
   Ls_E9E0 = " - ";
   Ls_E9D0 = (string)Ii_0DD0;
   Ls_E9C0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_E9B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E9B0, " ", Ls_E9C0, Ls_E9D0, Ls_E9E0, Ls_E9F0, Ls_EA00, Ls_EA10, Ls_EA20, Ls_EA30, Ls_EA40, Ls_EA50, Ls_EA60, Ls_EA70);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_09BC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09BC > 0) {
   FileSeek(Ii_09BC, 0, 2);
   Ls_E9A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09BC, Ls_E9A0, " VERBOSE: ", Ls_E9C0, Ls_E9D0, Ls_E9E0, Ls_E9F0, Ls_EA00, Ls_EA10, Ls_EA20, Ls_EA30, Ls_EA40, Ls_EA50, Ls_EA60, Ls_EA70);
   FileClose(Ii_09BC);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_E990 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_E990 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_E970 = "";
   Ls_E960 = "";
   Ls_E950 = "";
   Ls_E940 = "";
   Ls_E930 = "";
   Ls_E920 = "";
   Ls_E910 = (string)Ld_8AA8;
   Ls_E900 = " to :";
   Ls_E8F0 = (string)Fa_i_00;
   Ls_E8E0 = ", Magic Number: ";
   Ls_E8D0 = (string)OrderTicket();
   Ls_E8C0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_E8B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E8B0, " ", Ls_E8C0, Ls_E8D0, Ls_E8E0, Ls_E8F0, Ls_E900, Ls_E910, Ls_E920, Ls_E930, Ls_E940, Ls_E950, Ls_E960, Ls_E970);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0268 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0268 > 0) { 
   FileSeek(Ii_0268, 0, 2);
   Ls_E8A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0268, Ls_E8A0, " VERBOSE: ", Ls_E8C0, Ls_E8D0, Ls_E8E0, Ls_E8F0, Ls_E900, Ls_E910, Ls_E920, Ls_E930, Ls_E940, Ls_E950, Ls_E960, Ls_E970);
   FileClose(Ii_0268);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0020 = GetLastError();
   Ii_0DE4 = Gi_0020;
   Li_8A9C = Gi_0020;
   Ls_E890 = "";
   Ls_E880 = "";
   Ls_E870 = (string)OrderStopLoss();
   Ls_E860 = " Current SL: ";
   Ls_E850 = (string)Bid;
   Ls_E840 = ", Bid: ";
   Ls_E830 = (string)Ask;
   Ls_E820 = ", Ask: ";
   Ls_E810 = func_1032(Gi_0020);
   Ls_E800 = " - ";
   Ls_E7F0 = (string)Ii_0DE4;
   Ls_E7E0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_E7D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E7D0, " ", Ls_E7E0, Ls_E7F0, Ls_E800, Ls_E810, Ls_E820, Ls_E830, Ls_E840, Ls_E850, Ls_E860, Ls_E870, Ls_E880, Ls_E890);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09C0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09C0 > 0) { 
   FileSeek(Ii_09C0, 0, 2);
   Ls_E7C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09C0, Ls_E7C0, " VERBOSE: ", Ls_E7E0, Ls_E7F0, Ls_E800, Ls_E810, Ls_E820, Ls_E830, Ls_E840, Ls_E850, Ls_E860, Ls_E870, Ls_E880, Ls_E890);
   FileClose(Ii_09C0);
   }}}}}}}}} 
   Ii_0278 = Ii_0074;
   Id_0280 = 0;
   if (Ii_0074 == Ii_006C) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0070) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0074) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0078) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_007C) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0080) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0084) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0088) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_008C) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0090) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0094) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_0098) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_009C) { 
   Id_0280 = 0;
   } 
   if (Ii_0278 == Ii_00A0) { 
   Id_0280 = 0;
   } 
   returned_double = NormalizeDouble(Id_0280, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_09C4 = (int)(returned_double + 10);
   Il_09C8 = OrderOpenTime();
   Ii_09D0 = 0;
   Ii_09D4 = 0;
   Ii_0DE4 = Ii_09C4 + 10;
   if (Ii_0DE4 > 0) { 
   do { 
   if (Il_09C8 < Time[Ii_09D4]) { 
   Ii_09D0 = Ii_09D0 + 1;
   } 
   Ii_09D4 = Ii_09D4 + 1;
   Ii_0DF0 = Ii_09C4 + 10;
   } while (Ii_09D4 < Ii_0DF0); 
   } 
   if ((Ii_09D0 >= Ld_8AB8)) { 
   Ls_E7B0 = "";
   Ls_E7A0 = "";
   Ls_E790 = "";
   Ls_E780 = "";
   Ls_E770 = "";
   Ls_E760 = "";
   Ls_E750 = (string)Fa_i_00;
   Ls_E740 = ", Magic Number: ";
   Ls_E730 = (string)OrderTicket();
   Ls_E720 = "bars - closing order with ticket: ";
   Ls_E710 = (string)Ld_8AB8;
   Ls_E700 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_E6F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E6F0, " ", Ls_E700, Ls_E710, Ls_E720, Ls_E730, Ls_E740, Ls_E750, Ls_E760, Ls_E770, Ls_E780, Ls_E790, Ls_E7A0, Ls_E7B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_02A8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_02A8 > 0) { 
   FileSeek(Ii_02A8, 0, 2);
   Ls_E6E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_02A8, Ls_E6E0, " VERBOSE: ", Ls_E700, Ls_E710, Ls_E720, Ls_E730, Ls_E740, Ls_E750, Ls_E760, Ls_E770, Ls_E780, Ls_E790, Ls_E7A0, Ls_E7B0);
   FileClose(Ii_02A8);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0078) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0078, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_09D8 = Ii_0078;
   Id_09E0 = 0;
   if (Ii_0078 == Ii_006C) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0070) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0074) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0078) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_007C) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0080) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0084) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0088) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_008C) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0090) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0094) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_0098) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_009C) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   if (Ii_09D8 == Ii_00A0) { 
   Id_09E0 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_09E0, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_E6D0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_E6D0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_E6B0 = "";
   Ls_E6A0 = "";
   Ls_E690 = "";
   Ls_E680 = "";
   Ls_E670 = "";
   Ls_E660 = "";
   Ls_E650 = (string)Ld_8AA8;
   Ls_E640 = " to :";
   Ls_E630 = (string)Fa_i_00;
   Ls_E620 = ", Magic Number: ";
   Ls_E610 = (string)OrderTicket();
   Ls_E600 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_E5F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E5F0, " ", Ls_E600, Ls_E610, Ls_E620, Ls_E630, Ls_E640, Ls_E650, Ls_E660, Ls_E670, Ls_E680, Ls_E690, Ls_E6A0, Ls_E6B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09E8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09E8 > 0) { 
   FileSeek(Ii_09E8, 0, 2);
   Ls_E5E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09E8, Ls_E5E0, " VERBOSE: ", Ls_E600, Ls_E610, Ls_E620, Ls_E630, Ls_E640, Ls_E650, Ls_E660, Ls_E670, Ls_E680, Ls_E690, Ls_E6A0, Ls_E6B0);
   FileClose(Ii_09E8);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0024 = GetLastError();
   Ii_0E28 = Gi_0024;
   Li_8A9C = Gi_0024;
   Ls_E5D0 = "";
   Ls_E5C0 = "";
   Ls_E5B0 = "";
   Ls_E5A0 = "";
   Ls_E590 = "";
   Ls_E580 = "";
   Ls_E570 = "";
   Ls_E560 = "";
   Ls_E550 = func_1032(Gi_0024);
   Ls_E540 = " - ";
   Ls_E530 = (string)Ii_0E28;
   Ls_E520 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_E510 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E510, " ", Ls_E520, Ls_E530, Ls_E540, Ls_E550, Ls_E560, Ls_E570, Ls_E580, Ls_E590, Ls_E5A0, Ls_E5B0, Ls_E5C0, Ls_E5D0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_02C8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_02C8 > 0) {
   FileSeek(Ii_02C8, 0, 2);
   Ls_E500 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_02C8, Ls_E500, " VERBOSE: ", Ls_E520, Ls_E530, Ls_E540, Ls_E550, Ls_E560, Ls_E570, Ls_E580, Ls_E590, Ls_E5A0, Ls_E5B0, Ls_E5C0, Ls_E5D0);
   FileClose(Ii_02C8);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_E4F0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_E4F0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_E4D0 = "";
   Ls_E4C0 = "";
   Ls_E4B0 = "";
   Ls_E4A0 = "";
   Ls_E490 = "";
   Ls_E480 = "";
   Ls_E470 = (string)Ld_8AA8;
   Ls_E460 = " to :";
   Ls_E450 = (string)Fa_i_00;
   Ls_E440 = ", Magic Number: ";
   Ls_E430 = (string)OrderTicket();
   Ls_E420 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_E410 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E410, " ", Ls_E420, Ls_E430, Ls_E440, Ls_E450, Ls_E460, Ls_E470, Ls_E480, Ls_E490, Ls_E4A0, Ls_E4B0, Ls_E4C0, Ls_E4D0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09EC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09EC > 0) { 
   FileSeek(Ii_09EC, 0, 2);
   Ls_E400 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09EC, Ls_E400, " VERBOSE: ", Ls_E420, Ls_E430, Ls_E440, Ls_E450, Ls_E460, Ls_E470, Ls_E480, Ls_E490, Ls_E4A0, Ls_E4B0, Ls_E4C0, Ls_E4D0);
   FileClose(Ii_09EC);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0026 = GetLastError();
   Ii_16E0 = Gi_0026;
   Li_8A9C = Gi_0026;
   Ls_E3F0 = "";
   Ls_E3E0 = "";
   Ls_E3D0 = (string)OrderStopLoss();
   Ls_E3C0 = " Current SL: ";
   Ls_E3B0 = (string)Bid;
   Ls_E3A0 = ", Bid: ";
   Ls_E390 = (string)Ask;
   Ls_E380 = ", Ask: ";
   Ls_E370 = func_1032(Gi_0026);
   Ls_E360 = " - ";
   Ls_E350 = (string)Ii_16E0;
   Ls_E340 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_E330 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E330, " ", Ls_E340, Ls_E350, Ls_E360, Ls_E370, Ls_E380, Ls_E390, Ls_E3A0, Ls_E3B0, Ls_E3C0, Ls_E3D0, Ls_E3E0, Ls_E3F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09F0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09F0 > 0) { 
   FileSeek(Ii_09F0, 0, 2);
   Ls_E320 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09F0, Ls_E320, " VERBOSE: ", Ls_E340, Ls_E350, Ls_E360, Ls_E370, Ls_E380, Ls_E390, Ls_E3A0, Ls_E3B0, Ls_E3C0, Ls_E3D0, Ls_E3E0, Ls_E3F0);
   FileClose(Ii_09F0);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0078, OrderType(), OrderOpenPrice());
   Ii_02E0 = Ii_0078;
   Id_02E8 = 0;
   if (Ii_0078 == Ii_006C) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0070) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0074) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0078) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_007C) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0080) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0084) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0088) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_008C) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0090) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0094) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_0098) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_009C) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   if (Ii_02E0 == Ii_00A0) { 
   Id_02E8 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_02E8, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_E310 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_E310 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_E2F0 = "";
   Ls_E2E0 = "";
   Ls_E2D0 = "";
   Ls_E2C0 = "";
   Ls_E2B0 = "";
   Ls_E2A0 = "";
   Ls_E290 = (string)Ld_8AA8;
   Ls_E280 = " to :";
   Ls_E270 = (string)Fa_i_00;
   Ls_E260 = ", Magic Number: ";
   Ls_E250 = (string)OrderTicket();
   Ls_E240 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_E230 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E230, " ", Ls_E240, Ls_E250, Ls_E260, Ls_E270, Ls_E280, Ls_E290, Ls_E2A0, Ls_E2B0, Ls_E2C0, Ls_E2D0, Ls_E2E0, Ls_E2F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09F4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09F4 > 0) { 
   FileSeek(Ii_09F4, 0, 2);
   Ls_E220 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09F4, Ls_E220, " VERBOSE: ", Ls_E240, Ls_E250, Ls_E260, Ls_E270, Ls_E280, Ls_E290, Ls_E2A0, Ls_E2B0, Ls_E2C0, Ls_E2D0, Ls_E2E0, Ls_E2F0);
   FileClose(Ii_09F4);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0029 = GetLastError();
   Ii_0E60 = Gi_0029;
   Li_8A9C = Gi_0029;
   Ls_E210 = "";
   Ls_E200 = "";
   Ls_E1F0 = (string)OrderStopLoss();
   Ls_E1E0 = " Current SL: ";
   Ls_E1D0 = (string)Bid;
   Ls_E1C0 = ", Bid: ";
   Ls_E1B0 = (string)Ask;
   Ls_E1A0 = ", Ask: ";
   Ls_E190 = func_1032(Gi_0029);
   Ls_E180 = " - ";
   Ls_E170 = (string)Ii_0E60;
   Ls_E160 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_E150 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E150, " ", Ls_E160, Ls_E170, Ls_E180, Ls_E190, Ls_E1A0, Ls_E1B0, Ls_E1C0, Ls_E1D0, Ls_E1E0, Ls_E1F0, Ls_E200, Ls_E210);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_02F8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_02F8 > 0) {
   FileSeek(Ii_02F8, 0, 2);
   Ls_E140 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_02F8, Ls_E140, " VERBOSE: ", Ls_E160, Ls_E170, Ls_E180, Ls_E190, Ls_E1A0, Ls_E1B0, Ls_E1C0, Ls_E1D0, Ls_E1E0, Ls_E1F0, Ls_E200, Ls_E210);
   FileClose(Ii_02F8);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_E130 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_E130 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_E110 = "";
   Ls_E100 = "";
   Ls_E0F0 = "";
   Ls_E0E0 = "";
   Ls_E0D0 = "";
   Ls_E0C0 = "";
   Ls_E0B0 = (string)Ld_8AA8;
   Ls_E0A0 = " to :";
   Ls_E090 = (string)Fa_i_00;
   Ls_E080 = ", Magic Number: ";
   Ls_E070 = (string)OrderTicket();
   Ls_E060 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_E050 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_E050, " ", Ls_E060, Ls_E070, Ls_E080, Ls_E090, Ls_E0A0, Ls_E0B0, Ls_E0C0, Ls_E0D0, Ls_E0E0, Ls_E0F0, Ls_E100, Ls_E110);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09F8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09F8 > 0) { 
   FileSeek(Ii_09F8, 0, 2);
   Ls_E040 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09F8, Ls_E040, " VERBOSE: ", Ls_E060, Ls_E070, Ls_E080, Ls_E090, Ls_E0A0, Ls_E0B0, Ls_E0C0, Ls_E0D0, Ls_E0E0, Ls_E0F0, Ls_E100, Ls_E110);
   FileClose(Ii_09F8);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_002B = GetLastError();
   Ii_0E74 = Gi_002B;
   Li_8A9C = Gi_002B;
   Ls_E030 = "";
   Ls_E020 = "";
   Ls_E010 = (string)OrderStopLoss();
   Ls_E000 = " Current SL: ";
   Ls_DFF0 = (string)Bid;
   Ls_DFE0 = ", Bid: ";
   Ls_DFD0 = (string)Ask;
   Ls_DFC0 = ", Ask: ";
   Ls_DFB0 = func_1032(Gi_002B);
   Ls_DFA0 = " - ";
   Ls_DF90 = (string)Ii_0E74;
   Ls_DF80 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_DF70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_DF70, " ", Ls_DF80, Ls_DF90, Ls_DFA0, Ls_DFB0, Ls_DFC0, Ls_DFD0, Ls_DFE0, Ls_DFF0, Ls_E000, Ls_E010, Ls_E020, Ls_E030);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0308 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0308 > 0) { 
   FileSeek(Ii_0308, 0, 2);
   Ls_DF60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0308, Ls_DF60, " VERBOSE: ", Ls_DF80, Ls_DF90, Ls_DFA0, Ls_DFB0, Ls_DFC0, Ls_DFD0, Ls_DFE0, Ls_DFF0, Ls_E000, Ls_E010, Ls_E020, Ls_E030);
   FileClose(Ii_0308);
   }}}}}}}}} 
   Ii_09FC = Ii_0078;
   Id_0A00 = 0;
   if (Ii_0078 == Ii_006C) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0070) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0074) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0078) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_007C) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0080) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0084) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0088) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_008C) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0090) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0094) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_0098) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_009C) { 
   Id_0A00 = 0;
   } 
   if (Ii_09FC == Ii_00A0) { 
   Id_0A00 = 0;
   } 
   returned_double = NormalizeDouble(Id_0A00, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_0A08 = (int)(returned_double + 10);
   Il_0A10 = OrderOpenTime();
   Ii_0330 = 0;
   Ii_0A18 = 0;
   Ii_0E74 = Ii_0A08 + 10;
   if (Ii_0E74 > 0) { 
   do { 
   if (Il_0A10 < Time[Ii_0A18]) { 
   Ii_0330 = Ii_0330 + 1;
   } 
   Ii_0A18 = Ii_0A18 + 1;
   Ii_0E80 = Ii_0A08 + 10;
   } while (Ii_0A18 < Ii_0E80); 
   } 
   if ((Ii_0330 >= Ld_8AB8)) { 
   Ls_DF50 = "";
   Ls_DF40 = "";
   Ls_DF30 = "";
   Ls_DF20 = "";
   Ls_DF10 = "";
   Ls_DF00 = "";
   Ls_DEF0 = (string)Fa_i_00;
   Ls_DEE0 = ", Magic Number: ";
   Ls_DED0 = (string)OrderTicket();
   Ls_DEC0 = "bars - closing order with ticket: ";
   Ls_DEB0 = (string)Ld_8AB8;
   Ls_DEA0 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_DE90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_DE90, " ", Ls_DEA0, Ls_DEB0, Ls_DEC0, Ls_DED0, Ls_DEE0, Ls_DEF0, Ls_DF00, Ls_DF10, Ls_DF20, Ls_DF30, Ls_DF40, Ls_DF50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A1C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A1C > 0) { 
   FileSeek(Ii_0A1C, 0, 2);
   Ls_DE80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A1C, Ls_DE80, " VERBOSE: ", Ls_DEA0, Ls_DEB0, Ls_DEC0, Ls_DED0, Ls_DEE0, Ls_DEF0, Ls_DF00, Ls_DF10, Ls_DF20, Ls_DF30, Ls_DF40, Ls_DF50);
   FileClose(Ii_0A1C);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_007C) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_007C, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0348 = Ii_007C;
   Id_0350 = 0;
   if (Ii_007C == Ii_006C) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0070) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0074) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0078) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_007C) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0080) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0084) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0088) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_008C) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0090) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0094) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_0098) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_009C) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   if (Ii_0348 == Ii_00A0) { 
   Id_0350 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0350, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_DE70 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_DE70 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_DE50 = "";
   Ls_DE40 = "";
   Ls_DE30 = "";
   Ls_DE20 = "";
   Ls_DE10 = "";
   Ls_DE00 = "";
   Ls_DDF0 = (string)Ld_8AA8;
   Ls_DDE0 = " to :";
   Ls_DDD0 = (string)Fa_i_00;
   Ls_DDC0 = ", Magic Number: ";
   Ls_DDB0 = (string)OrderTicket();
   Ls_DDA0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_DD90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_DD90, " ", Ls_DDA0, Ls_DDB0, Ls_DDC0, Ls_DDD0, Ls_DDE0, Ls_DDF0, Ls_DE00, Ls_DE10, Ls_DE20, Ls_DE30, Ls_DE40, Ls_DE50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A20 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A20 > 0) { 
   FileSeek(Ii_0A20, 0, 2);
   Ls_DD80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A20, Ls_DD80, " VERBOSE: ", Ls_DDA0, Ls_DDB0, Ls_DDC0, Ls_DDD0, Ls_DDE0, Ls_DDF0, Ls_DE00, Ls_DE10, Ls_DE20, Ls_DE30, Ls_DE40, Ls_DE50);
   FileClose(Ii_0A20);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_002F = GetLastError();
   Ii_0EB8 = Gi_002F;
   Li_8A9C = Gi_002F;
   Ls_DD70 = "";
   Ls_DD60 = "";
   Ls_DD50 = "";
   Ls_DD40 = "";
   Ls_DD30 = "";
   Ls_DD20 = "";
   Ls_DD10 = "";
   Ls_DD00 = "";
   Ls_DCF0 = func_1032(Gi_002F);
   Ls_DCE0 = " - ";
   Ls_DCD0 = (string)Ii_0EB8;
   Ls_DCC0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_DCB0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_DCB0, " ", Ls_DCC0, Ls_DCD0, Ls_DCE0, Ls_DCF0, Ls_DD00, Ls_DD10, Ls_DD20, Ls_DD30, Ls_DD40, Ls_DD50, Ls_DD60, Ls_DD70);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_035C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_035C > 0) {
   FileSeek(Ii_035C, 0, 2);
   Ls_DCA0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_035C, Ls_DCA0, " VERBOSE: ", Ls_DCC0, Ls_DCD0, Ls_DCE0, Ls_DCF0, Ls_DD00, Ls_DD10, Ls_DD20, Ls_DD30, Ls_DD40, Ls_DD50, Ls_DD60, Ls_DD70);
   FileClose(Ii_035C);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_DC90 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_DC90 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_DC70 = "";
   Ls_DC60 = "";
   Ls_DC50 = "";
   Ls_DC40 = "";
   Ls_DC30 = "";
   Ls_DC20 = "";
   Ls_DC10 = (string)Ld_8AA8;
   Ls_DC00 = " to :";
   Ls_DBF0 = (string)Fa_i_00;
   Ls_DBE0 = ", Magic Number: ";
   Ls_DBD0 = (string)OrderTicket();
   Ls_DBC0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_DBB0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_DBB0, " ", Ls_DBC0, Ls_DBD0, Ls_DBE0, Ls_DBF0, Ls_DC00, Ls_DC10, Ls_DC20, Ls_DC30, Ls_DC40, Ls_DC50, Ls_DC60, Ls_DC70);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0360 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0360 > 0) { 
   FileSeek(Ii_0360, 0, 2);
   Ls_DBA0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0360, Ls_DBA0, " VERBOSE: ", Ls_DBC0, Ls_DBD0, Ls_DBE0, Ls_DBF0, Ls_DC00, Ls_DC10, Ls_DC20, Ls_DC30, Ls_DC40, Ls_DC50, Ls_DC60, Ls_DC70);
   FileClose(Ii_0360);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0031 = GetLastError();
   Ii_16A0 = Gi_0031;
   Li_8A9C = Gi_0031;
   Ls_DB90 = "";
   Ls_DB80 = "";
   Ls_DB70 = (string)OrderStopLoss();
   Ls_DB60 = " Current SL: ";
   Ls_DB50 = (string)Bid;
   Ls_DB40 = ", Bid: ";
   Ls_DB30 = (string)Ask;
   Ls_DB20 = ", Ask: ";
   Ls_DB10 = func_1032(Gi_0031);
   Ls_DB00 = " - ";
   Ls_DAF0 = (string)Ii_16A0;
   Ls_DAE0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_DAD0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_DAD0, " ", Ls_DAE0, Ls_DAF0, Ls_DB00, Ls_DB10, Ls_DB20, Ls_DB30, Ls_DB40, Ls_DB50, Ls_DB60, Ls_DB70, Ls_DB80, Ls_DB90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0364 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0364 > 0) { 
   FileSeek(Ii_0364, 0, 2);
   Ls_DAC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0364, Ls_DAC0, " VERBOSE: ", Ls_DAE0, Ls_DAF0, Ls_DB00, Ls_DB10, Ls_DB20, Ls_DB30, Ls_DB40, Ls_DB50, Ls_DB60, Ls_DB70, Ls_DB80, Ls_DB90);
   FileClose(Ii_0364);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_007C, OrderType(), OrderOpenPrice());
   Ii_0A24 = Ii_007C;
   Id_0370 = 0;
   if (Ii_007C == Ii_006C) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0070) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0074) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0078) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_007C) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0080) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0084) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0088) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_008C) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0090) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0094) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_0098) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_009C) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   if (Ii_0A24 == Ii_00A0) { 
   Id_0370 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0370, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_DAB0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_DAB0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_DA90 = "";
   Ls_DA80 = "";
   Ls_DA70 = "";
   Ls_DA60 = "";
   Ls_DA50 = "";
   Ls_DA40 = "";
   Ls_DA30 = (string)Ld_8AA8;
   Ls_DA20 = " to :";
   Ls_DA10 = (string)Fa_i_00;
   Ls_DA00 = ", Magic Number: ";
   Ls_D9F0 = (string)OrderTicket();
   Ls_D9E0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_D9D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D9D0, " ", Ls_D9E0, Ls_D9F0, Ls_DA00, Ls_DA10, Ls_DA20, Ls_DA30, Ls_DA40, Ls_DA50, Ls_DA60, Ls_DA70, Ls_DA80, Ls_DA90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0378 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0378 > 0) { 
   FileSeek(Ii_0378, 0, 2);
   Ls_D9C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0378, Ls_D9C0, " VERBOSE: ", Ls_D9E0, Ls_D9F0, Ls_DA00, Ls_DA10, Ls_DA20, Ls_DA30, Ls_DA40, Ls_DA50, Ls_DA60, Ls_DA70, Ls_DA80, Ls_DA90);
   FileClose(Ii_0378);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0034 = GetLastError();
   Ii_0EF0 = Gi_0034;
   Li_8A9C = Gi_0034;
   Ls_D9B0 = "";
   Ls_D9A0 = "";
   Ls_D990 = (string)OrderStopLoss();
   Ls_D980 = " Current SL: ";
   Ls_D970 = (string)Bid;
   Ls_D960 = ", Bid: ";
   Ls_D950 = (string)Ask;
   Ls_D940 = ", Ask: ";
   Ls_D930 = func_1032(Gi_0034);
   Ls_D920 = " - ";
   Ls_D910 = (string)Ii_0EF0;
   Ls_D900 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_D8F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D8F0, " ", Ls_D900, Ls_D910, Ls_D920, Ls_D930, Ls_D940, Ls_D950, Ls_D960, Ls_D970, Ls_D980, Ls_D990, Ls_D9A0, Ls_D9B0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0A28 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A28 > 0) {
   FileSeek(Ii_0A28, 0, 2);
   Ls_D8E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A28, Ls_D8E0, " VERBOSE: ", Ls_D900, Ls_D910, Ls_D920, Ls_D930, Ls_D940, Ls_D950, Ls_D960, Ls_D970, Ls_D980, Ls_D990, Ls_D9A0, Ls_D9B0);
   FileClose(Ii_0A28);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_D8D0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_D8D0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_D8B0 = "";
   Ls_D8A0 = "";
   Ls_D890 = "";
   Ls_D880 = "";
   Ls_D870 = "";
   Ls_D860 = "";
   Ls_D850 = (string)Ld_8AA8;
   Ls_D840 = " to :";
   Ls_D830 = (string)Fa_i_00;
   Ls_D820 = ", Magic Number: ";
   Ls_D810 = (string)OrderTicket();
   Ls_D800 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_D7F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D7F0, " ", Ls_D800, Ls_D810, Ls_D820, Ls_D830, Ls_D840, Ls_D850, Ls_D860, Ls_D870, Ls_D880, Ls_D890, Ls_D8A0, Ls_D8B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0388 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0388 > 0) { 
   FileSeek(Ii_0388, 0, 2);
   Ls_D7E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0388, Ls_D7E0, " VERBOSE: ", Ls_D800, Ls_D810, Ls_D820, Ls_D830, Ls_D840, Ls_D850, Ls_D860, Ls_D870, Ls_D880, Ls_D890, Ls_D8A0, Ls_D8B0);
   FileClose(Ii_0388);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0036 = GetLastError();
   Ii_0F04 = Gi_0036;
   Li_8A9C = Gi_0036;
   Ls_D7D0 = "";
   Ls_D7C0 = "";
   Ls_D7B0 = (string)OrderStopLoss();
   Ls_D7A0 = " Current SL: ";
   Ls_D790 = (string)Bid;
   Ls_D780 = ", Bid: ";
   Ls_D770 = (string)Ask;
   Ls_D760 = ", Ask: ";
   Ls_D750 = func_1032(Gi_0036);
   Ls_D740 = " - ";
   Ls_D730 = (string)Ii_0F04;
   Ls_D720 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_D710 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D710, " ", Ls_D720, Ls_D730, Ls_D740, Ls_D750, Ls_D760, Ls_D770, Ls_D780, Ls_D790, Ls_D7A0, Ls_D7B0, Ls_D7C0, Ls_D7D0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A2C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A2C > 0) { 
   FileSeek(Ii_0A2C, 0, 2);
   Ls_D700 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A2C, Ls_D700, " VERBOSE: ", Ls_D720, Ls_D730, Ls_D740, Ls_D750, Ls_D760, Ls_D770, Ls_D780, Ls_D790, Ls_D7A0, Ls_D7B0, Ls_D7C0, Ls_D7D0);
   FileClose(Ii_0A2C);
   }}}}}}}}} 
   Ii_0A30 = Ii_007C;
   Id_0A38 = 0;
   if (Ii_007C == Ii_006C) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0070) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0074) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0078) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_007C) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0080) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0084) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0088) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_008C) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0090) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0094) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_0098) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_009C) { 
   Id_0A38 = 0;
   } 
   if (Ii_0A30 == Ii_00A0) { 
   Id_0A38 = 0;
   } 
   returned_double = NormalizeDouble(Id_0A38, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_0A40 = (int)(returned_double + 10);
   Il_0A48 = OrderOpenTime();
   Ii_0A50 = 0;
   Ii_03C0 = 0;
   Ii_0F04 = Ii_0A40 + 10;
   if (Ii_0F04 > 0) { 
   do { 
   if (Il_0A48 < Time[Ii_03C0]) { 
   Ii_0A50 = Ii_0A50 + 1;
   } 
   Ii_03C0 = Ii_03C0 + 1;
   Ii_0F10 = Ii_0A40 + 10;
   } while (Ii_03C0 < Ii_0F10); 
   } 
   if ((Ii_0A50 >= Ld_8AB8)) { 
   Ls_D6F0 = "";
   Ls_D6E0 = "";
   Ls_D6D0 = "";
   Ls_D6C0 = "";
   Ls_D6B0 = "";
   Ls_D6A0 = "";
   Ls_D690 = (string)Fa_i_00;
   Ls_D680 = ", Magic Number: ";
   Ls_D670 = (string)OrderTicket();
   Ls_D660 = "bars - closing order with ticket: ";
   Ls_D650 = (string)Ld_8AB8;
   Ls_D640 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_D630 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D630, " ", Ls_D640, Ls_D650, Ls_D660, Ls_D670, Ls_D680, Ls_D690, Ls_D6A0, Ls_D6B0, Ls_D6C0, Ls_D6D0, Ls_D6E0, Ls_D6F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A54 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A54 > 0) { 
   FileSeek(Ii_0A54, 0, 2);
   Ls_D620 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A54, Ls_D620, " VERBOSE: ", Ls_D640, Ls_D650, Ls_D660, Ls_D670, Ls_D680, Ls_D690, Ls_D6A0, Ls_D6B0, Ls_D6C0, Ls_D6D0, Ls_D6E0, Ls_D6F0);
   FileClose(Ii_0A54);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0080) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0080, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0A58 = Ii_0080;
   Id_0A60 = 0;
   if (Ii_0080 == Ii_006C) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0070) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0074) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0078) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_007C) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0080) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0084) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0088) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_008C) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0090) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0094) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_0098) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_009C) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   if (Ii_0A58 == Ii_00A0) { 
   Id_0A60 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0A60, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_D610 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_D610 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_D5F0 = "";
   Ls_D5E0 = "";
   Ls_D5D0 = "";
   Ls_D5C0 = "";
   Ls_D5B0 = "";
   Ls_D5A0 = "";
   Ls_D590 = (string)Ld_8AA8;
   Ls_D580 = " to :";
   Ls_D570 = (string)Fa_i_00;
   Ls_D560 = ", Magic Number: ";
   Ls_D550 = (string)OrderTicket();
   Ls_D540 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_D530 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D530, " ", Ls_D540, Ls_D550, Ls_D560, Ls_D570, Ls_D580, Ls_D590, Ls_D5A0, Ls_D5B0, Ls_D5C0, Ls_D5D0, Ls_D5E0, Ls_D5F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A68 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A68 > 0) { 
   FileSeek(Ii_0A68, 0, 2);
   Ls_D520 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A68, Ls_D520, " VERBOSE: ", Ls_D540, Ls_D550, Ls_D560, Ls_D570, Ls_D580, Ls_D590, Ls_D5A0, Ls_D5B0, Ls_D5C0, Ls_D5D0, Ls_D5E0, Ls_D5F0);
   FileClose(Ii_0A68);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_003A = GetLastError();
   Ii_0F48 = Gi_003A;
   Li_8A9C = Gi_003A;
   Ls_D510 = "";
   Ls_D500 = "";
   Ls_D4F0 = "";
   Ls_D4E0 = "";
   Ls_D4D0 = "";
   Ls_D4C0 = "";
   Ls_D4B0 = "";
   Ls_D4A0 = "";
   Ls_D490 = func_1032(Gi_003A);
   Ls_D480 = " - ";
   Ls_D470 = (string)Ii_0F48;
   Ls_D460 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_D450 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D450, " ", Ls_D460, Ls_D470, Ls_D480, Ls_D490, Ls_D4A0, Ls_D4B0, Ls_D4C0, Ls_D4D0, Ls_D4E0, Ls_D4F0, Ls_D500, Ls_D510);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0A6C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A6C > 0) {
   FileSeek(Ii_0A6C, 0, 2);
   Ls_D440 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A6C, Ls_D440, " VERBOSE: ", Ls_D460, Ls_D470, Ls_D480, Ls_D490, Ls_D4A0, Ls_D4B0, Ls_D4C0, Ls_D4D0, Ls_D4E0, Ls_D4F0, Ls_D500, Ls_D510);
   FileClose(Ii_0A6C);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_D430 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_D430 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_D410 = "";
   Ls_D400 = "";
   Ls_D3F0 = "";
   Ls_D3E0 = "";
   Ls_D3D0 = "";
   Ls_D3C0 = "";
   Ls_D3B0 = (string)Ld_8AA8;
   Ls_D3A0 = " to :";
   Ls_D390 = (string)Fa_i_00;
   Ls_D380 = ", Magic Number: ";
   Ls_D370 = (string)OrderTicket();
   Ls_D360 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_D350 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D350, " ", Ls_D360, Ls_D370, Ls_D380, Ls_D390, Ls_D3A0, Ls_D3B0, Ls_D3C0, Ls_D3D0, Ls_D3E0, Ls_D3F0, Ls_D400, Ls_D410);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_03F0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_03F0 > 0) { 
   FileSeek(Ii_03F0, 0, 2);
   Ls_D340 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_03F0, Ls_D340, " VERBOSE: ", Ls_D360, Ls_D370, Ls_D380, Ls_D390, Ls_D3A0, Ls_D3B0, Ls_D3C0, Ls_D3D0, Ls_D3E0, Ls_D3F0, Ls_D400, Ls_D410);
   FileClose(Ii_03F0);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_003C = GetLastError();
   Ii_1660 = Gi_003C;
   Li_8A9C = Gi_003C;
   Ls_D330 = "";
   Ls_D320 = "";
   Ls_D310 = (string)OrderStopLoss();
   Ls_D300 = " Current SL: ";
   Ls_D2F0 = (string)Bid;
   Ls_D2E0 = ", Bid: ";
   Ls_D2D0 = (string)Ask;
   Ls_D2C0 = ", Ask: ";
   Ls_D2B0 = func_1032(Gi_003C);
   Ls_D2A0 = " - ";
   Ls_D290 = (string)Ii_1660;
   Ls_D280 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_D270 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D270, " ", Ls_D280, Ls_D290, Ls_D2A0, Ls_D2B0, Ls_D2C0, Ls_D2D0, Ls_D2E0, Ls_D2F0, Ls_D300, Ls_D310, Ls_D320, Ls_D330);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A70 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A70 > 0) { 
   FileSeek(Ii_0A70, 0, 2);
   Ls_D260 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A70, Ls_D260, " VERBOSE: ", Ls_D280, Ls_D290, Ls_D2A0, Ls_D2B0, Ls_D2C0, Ls_D2D0, Ls_D2E0, Ls_D2F0, Ls_D300, Ls_D310, Ls_D320, Ls_D330);
   FileClose(Ii_0A70);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0080, OrderType(), OrderOpenPrice());
   Ii_0400 = Ii_0080;
   Id_0408 = 0;
   if (Ii_0080 == Ii_006C) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0070) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0074) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0078) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_007C) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0080) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0084) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0088) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_008C) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0090) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0094) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_0098) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_009C) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   if (Ii_0400 == Ii_00A0) { 
   Id_0408 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0408, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_D250 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_D250 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_D230 = "";
   Ls_D220 = "";
   Ls_D210 = "";
   Ls_D200 = "";
   Ls_D1F0 = "";
   Ls_D1E0 = "";
   Ls_D1D0 = (string)Ld_8AA8;
   Ls_D1C0 = " to :";
   Ls_D1B0 = (string)Fa_i_00;
   Ls_D1A0 = ", Magic Number: ";
   Ls_D190 = (string)OrderTicket();
   Ls_D180 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_D170 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D170, " ", Ls_D180, Ls_D190, Ls_D1A0, Ls_D1B0, Ls_D1C0, Ls_D1D0, Ls_D1E0, Ls_D1F0, Ls_D200, Ls_D210, Ls_D220, Ls_D230);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0410 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0410 > 0) { 
   FileSeek(Ii_0410, 0, 2);
   Ls_D160 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0410, Ls_D160, " VERBOSE: ", Ls_D180, Ls_D190, Ls_D1A0, Ls_D1B0, Ls_D1C0, Ls_D1D0, Ls_D1E0, Ls_D1F0, Ls_D200, Ls_D210, Ls_D220, Ls_D230);
   FileClose(Ii_0410);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_003F = GetLastError();
   Ii_0F80 = Gi_003F;
   Li_8A9C = Gi_003F;
   Ls_D150 = "";
   Ls_D140 = "";
   Ls_D130 = (string)OrderStopLoss();
   Ls_D120 = " Current SL: ";
   Ls_D110 = (string)Bid;
   Ls_D100 = ", Bid: ";
   Ls_D0F0 = (string)Ask;
   Ls_D0E0 = ", Ask: ";
   Ls_D0D0 = func_1032(Gi_003F);
   Ls_D0C0 = " - ";
   Ls_D0B0 = (string)Ii_0F80;
   Ls_D0A0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_D090 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_D090, " ", Ls_D0A0, Ls_D0B0, Ls_D0C0, Ls_D0D0, Ls_D0E0, Ls_D0F0, Ls_D100, Ls_D110, Ls_D120, Ls_D130, Ls_D140, Ls_D150);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0A74 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A74 > 0) {
   FileSeek(Ii_0A74, 0, 2);
   Ls_D080 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A74, Ls_D080, " VERBOSE: ", Ls_D0A0, Ls_D0B0, Ls_D0C0, Ls_D0D0, Ls_D0E0, Ls_D0F0, Ls_D100, Ls_D110, Ls_D120, Ls_D130, Ls_D140, Ls_D150);
   FileClose(Ii_0A74);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_D070 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_D070 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_D050 = "";
   Ls_D040 = "";
   Ls_D030 = "";
   Ls_D020 = "";
   Ls_D010 = "";
   Ls_D000 = "";
   Ls_CFF0 = (string)Ld_8AA8;
   Ls_CFE0 = " to :";
   Ls_CFD0 = (string)Fa_i_00;
   Ls_CFC0 = ", Magic Number: ";
   Ls_CFB0 = (string)OrderTicket();
   Ls_CFA0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_CF90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_CF90, " ", Ls_CFA0, Ls_CFB0, Ls_CFC0, Ls_CFD0, Ls_CFE0, Ls_CFF0, Ls_D000, Ls_D010, Ls_D020, Ls_D030, Ls_D040, Ls_D050);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A78 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A78 > 0) { 
   FileSeek(Ii_0A78, 0, 2);
   Ls_CF80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A78, Ls_CF80, " VERBOSE: ", Ls_CFA0, Ls_CFB0, Ls_CFC0, Ls_CFD0, Ls_CFE0, Ls_CFF0, Ls_D000, Ls_D010, Ls_D020, Ls_D030, Ls_D040, Ls_D050);
   FileClose(Ii_0A78);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0041 = GetLastError();
   Ii_0F94 = Gi_0041;
   Li_8A9C = Gi_0041;
   Ls_CF70 = "";
   Ls_CF60 = "";
   Ls_CF50 = (string)OrderStopLoss();
   Ls_CF40 = " Current SL: ";
   Ls_CF30 = (string)Bid;
   Ls_CF20 = ", Bid: ";
   Ls_CF10 = (string)Ask;
   Ls_CF00 = ", Ask: ";
   Ls_CEF0 = func_1032(Gi_0041);
   Ls_CEE0 = " - ";
   Ls_CED0 = (string)Ii_0F94;
   Ls_CEC0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_CEB0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_CEB0, " ", Ls_CEC0, Ls_CED0, Ls_CEE0, Ls_CEF0, Ls_CF00, Ls_CF10, Ls_CF20, Ls_CF30, Ls_CF40, Ls_CF50, Ls_CF60, Ls_CF70);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0428 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0428 > 0) { 
   FileSeek(Ii_0428, 0, 2);
   Ls_CEA0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0428, Ls_CEA0, " VERBOSE: ", Ls_CEC0, Ls_CED0, Ls_CEE0, Ls_CEF0, Ls_CF00, Ls_CF10, Ls_CF20, Ls_CF30, Ls_CF40, Ls_CF50, Ls_CF60, Ls_CF70);
   FileClose(Ii_0428);
   }}}}}}}}} 
   Ii_0A7C = Ii_0080;
   Id_0438 = 0;
   if (Ii_0080 == Ii_006C) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0070) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0074) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0078) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_007C) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0080) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0084) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0088) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_008C) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0090) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0094) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_0098) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_009C) { 
   Id_0438 = 0;
   } 
   if (Ii_0A7C == Ii_00A0) { 
   Id_0438 = 0;
   } 
   returned_double = NormalizeDouble(Id_0438, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_0440 = (int)(returned_double + 10);
   Il_0A80 = OrderOpenTime();
   Ii_0450 = 0;
   Ii_0A88 = 0;
   Ii_0F94 = Ii_0440 + 10;
   if (Ii_0F94 > 0) { 
   do { 
   if (Il_0A80 < Time[Ii_0A88]) { 
   Ii_0450 = Ii_0450 + 1;
   } 
   Ii_0A88 = Ii_0A88 + 1;
   Ii_0FA0 = Ii_0440 + 10;
   } while (Ii_0A88 < Ii_0FA0); 
   } 
   if ((Ii_0450 >= Ld_8AB8)) { 
   Ls_CE90 = "";
   Ls_CE80 = "";
   Ls_CE70 = "";
   Ls_CE60 = "";
   Ls_CE50 = "";
   Ls_CE40 = "";
   Ls_CE30 = (string)Fa_i_00;
   Ls_CE20 = ", Magic Number: ";
   Ls_CE10 = (string)OrderTicket();
   Ls_CE00 = "bars - closing order with ticket: ";
   Ls_CDF0 = (string)Ld_8AB8;
   Ls_CDE0 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_CDD0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_CDD0, " ", Ls_CDE0, Ls_CDF0, Ls_CE00, Ls_CE10, Ls_CE20, Ls_CE30, Ls_CE40, Ls_CE50, Ls_CE60, Ls_CE70, Ls_CE80, Ls_CE90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0460 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0460 > 0) { 
   FileSeek(Ii_0460, 0, 2);
   Ls_CDC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0460, Ls_CDC0, " VERBOSE: ", Ls_CDE0, Ls_CDF0, Ls_CE00, Ls_CE10, Ls_CE20, Ls_CE30, Ls_CE40, Ls_CE50, Ls_CE60, Ls_CE70, Ls_CE80, Ls_CE90);
   FileClose(Ii_0460);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0084) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0084, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0A8C = Ii_0084;
   Id_0470 = 0;
   if (Ii_0084 == Ii_006C) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0070) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0074) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0078) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_007C) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0080) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0084) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0088) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_008C) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0090) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0094) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_0098) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_009C) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   if (Ii_0A8C == Ii_00A0) { 
   Id_0470 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0470, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_CDB0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_CDB0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_CD90 = "";
   Ls_CD80 = "";
   Ls_CD70 = "";
   Ls_CD60 = "";
   Ls_CD50 = "";
   Ls_CD40 = "";
   Ls_CD30 = (string)Ld_8AA8;
   Ls_CD20 = " to :";
   Ls_CD10 = (string)Fa_i_00;
   Ls_CD00 = ", Magic Number: ";
   Ls_CCF0 = (string)OrderTicket();
   Ls_CCE0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_CCD0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_CCD0, " ", Ls_CCE0, Ls_CCF0, Ls_CD00, Ls_CD10, Ls_CD20, Ls_CD30, Ls_CD40, Ls_CD50, Ls_CD60, Ls_CD70, Ls_CD80, Ls_CD90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0478 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0478 > 0) { 
   FileSeek(Ii_0478, 0, 2);
   Ls_CCC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0478, Ls_CCC0, " VERBOSE: ", Ls_CCE0, Ls_CCF0, Ls_CD00, Ls_CD10, Ls_CD20, Ls_CD30, Ls_CD40, Ls_CD50, Ls_CD60, Ls_CD70, Ls_CD80, Ls_CD90);
   FileClose(Ii_0478);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0045 = GetLastError();
   Ii_0FD8 = Gi_0045;
   Li_8A9C = Gi_0045;
   Ls_CCB0 = "";
   Ls_CCA0 = "";
   Ls_CC90 = "";
   Ls_CC80 = "";
   Ls_CC70 = "";
   Ls_CC60 = "";
   Ls_CC50 = "";
   Ls_CC40 = "";
   Ls_CC30 = func_1032(Gi_0045);
   Ls_CC20 = " - ";
   Ls_CC10 = (string)Ii_0FD8;
   Ls_CC00 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_CBF0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_CBF0, " ", Ls_CC00, Ls_CC10, Ls_CC20, Ls_CC30, Ls_CC40, Ls_CC50, Ls_CC60, Ls_CC70, Ls_CC80, Ls_CC90, Ls_CCA0, Ls_CCB0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0A90 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A90 > 0) {
   FileSeek(Ii_0A90, 0, 2);
   Ls_CBE0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A90, Ls_CBE0, " VERBOSE: ", Ls_CC00, Ls_CC10, Ls_CC20, Ls_CC30, Ls_CC40, Ls_CC50, Ls_CC60, Ls_CC70, Ls_CC80, Ls_CC90, Ls_CCA0, Ls_CCB0);
   FileClose(Ii_0A90);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_CBD0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_CBD0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_CBB0 = "";
   Ls_CBA0 = "";
   Ls_CB90 = "";
   Ls_CB80 = "";
   Ls_CB70 = "";
   Ls_CB60 = "";
   Ls_CB50 = (string)Ld_8AA8;
   Ls_CB40 = " to :";
   Ls_CB30 = (string)Fa_i_00;
   Ls_CB20 = ", Magic Number: ";
   Ls_CB10 = (string)OrderTicket();
   Ls_CB00 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_CAF0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_CAF0, " ", Ls_CB00, Ls_CB10, Ls_CB20, Ls_CB30, Ls_CB40, Ls_CB50, Ls_CB60, Ls_CB70, Ls_CB80, Ls_CB90, Ls_CBA0, Ls_CBB0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A94 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A94 > 0) { 
   FileSeek(Ii_0A94, 0, 2);
   Ls_CAE0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A94, Ls_CAE0, " VERBOSE: ", Ls_CB00, Ls_CB10, Ls_CB20, Ls_CB30, Ls_CB40, Ls_CB50, Ls_CB60, Ls_CB70, Ls_CB80, Ls_CB90, Ls_CBA0, Ls_CBB0);
   FileClose(Ii_0A94);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0047 = GetLastError();
   Ii_1620 = Gi_0047;
   Li_8A9C = Gi_0047;
   Ls_CAD0 = "";
   Ls_CAC0 = "";
   Ls_CAB0 = (string)OrderStopLoss();
   Ls_CAA0 = " Current SL: ";
   Ls_CA90 = (string)Bid;
   Ls_CA80 = ", Bid: ";
   Ls_CA70 = (string)Ask;
   Ls_CA60 = ", Ask: ";
   Ls_CA50 = func_1032(Gi_0047);
   Ls_CA40 = " - ";
   Ls_CA30 = (string)Ii_1620;
   Ls_CA20 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_CA10 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_CA10, " ", Ls_CA20, Ls_CA30, Ls_CA40, Ls_CA50, Ls_CA60, Ls_CA70, Ls_CA80, Ls_CA90, Ls_CAA0, Ls_CAB0, Ls_CAC0, Ls_CAD0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0490 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0490 > 0) { 
   FileSeek(Ii_0490, 0, 2);
   Ls_CA00 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0490, Ls_CA00, " VERBOSE: ", Ls_CA20, Ls_CA30, Ls_CA40, Ls_CA50, Ls_CA60, Ls_CA70, Ls_CA80, Ls_CA90, Ls_CAA0, Ls_CAB0, Ls_CAC0, Ls_CAD0);
   FileClose(Ii_0490);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0084, OrderType(), OrderOpenPrice());
   Ii_0A98 = Ii_0084;
   Id_0AA0 = 0;
   if (Ii_0084 == Ii_006C) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0070) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0074) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0078) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_007C) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0080) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0084) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0088) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_008C) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0090) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0094) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_0098) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_009C) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   if (Ii_0A98 == Ii_00A0) { 
   Id_0AA0 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0AA0, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_C9F0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_C9F0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_C9D0 = "";
   Ls_C9C0 = "";
   Ls_C9B0 = "";
   Ls_C9A0 = "";
   Ls_C990 = "";
   Ls_C980 = "";
   Ls_C970 = (string)Ld_8AA8;
   Ls_C960 = " to :";
   Ls_C950 = (string)Fa_i_00;
   Ls_C940 = ", Magic Number: ";
   Ls_C930 = (string)OrderTicket();
   Ls_C920 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_C910 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C910, " ", Ls_C920, Ls_C930, Ls_C940, Ls_C950, Ls_C960, Ls_C970, Ls_C980, Ls_C990, Ls_C9A0, Ls_C9B0, Ls_C9C0, Ls_C9D0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0AA8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AA8 > 0) { 
   FileSeek(Ii_0AA8, 0, 2);
   Ls_C900 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AA8, Ls_C900, " VERBOSE: ", Ls_C920, Ls_C930, Ls_C940, Ls_C950, Ls_C960, Ls_C970, Ls_C980, Ls_C990, Ls_C9A0, Ls_C9B0, Ls_C9C0, Ls_C9D0);
   FileClose(Ii_0AA8);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_004A = GetLastError();
   Ii_1010 = Gi_004A;
   Li_8A9C = Gi_004A;
   Ls_C8F0 = "";
   Ls_C8E0 = "";
   Ls_C8D0 = (string)OrderStopLoss();
   Ls_C8C0 = " Current SL: ";
   Ls_C8B0 = (string)Bid;
   Ls_C8A0 = ", Bid: ";
   Ls_C890 = (string)Ask;
   Ls_C880 = ", Ask: ";
   Ls_C870 = func_1032(Gi_004A);
   Ls_C860 = " - ";
   Ls_C850 = (string)Ii_1010;
   Ls_C840 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_C830 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C830, " ", Ls_C840, Ls_C850, Ls_C860, Ls_C870, Ls_C880, Ls_C890, Ls_C8A0, Ls_C8B0, Ls_C8C0, Ls_C8D0, Ls_C8E0, Ls_C8F0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_04B0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_04B0 > 0) {
   FileSeek(Ii_04B0, 0, 2);
   Ls_C820 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_04B0, Ls_C820, " VERBOSE: ", Ls_C840, Ls_C850, Ls_C860, Ls_C870, Ls_C880, Ls_C890, Ls_C8A0, Ls_C8B0, Ls_C8C0, Ls_C8D0, Ls_C8E0, Ls_C8F0);
   FileClose(Ii_04B0);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_C810 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_C810 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_C7F0 = "";
   Ls_C7E0 = "";
   Ls_C7D0 = "";
   Ls_C7C0 = "";
   Ls_C7B0 = "";
   Ls_C7A0 = "";
   Ls_C790 = (string)Ld_8AA8;
   Ls_C780 = " to :";
   Ls_C770 = (string)Fa_i_00;
   Ls_C760 = ", Magic Number: ";
   Ls_C750 = (string)OrderTicket();
   Ls_C740 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_C730 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C730, " ", Ls_C740, Ls_C750, Ls_C760, Ls_C770, Ls_C780, Ls_C790, Ls_C7A0, Ls_C7B0, Ls_C7C0, Ls_C7D0, Ls_C7E0, Ls_C7F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0AAC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AAC > 0) { 
   FileSeek(Ii_0AAC, 0, 2);
   Ls_C720 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AAC, Ls_C720, " VERBOSE: ", Ls_C740, Ls_C750, Ls_C760, Ls_C770, Ls_C780, Ls_C790, Ls_C7A0, Ls_C7B0, Ls_C7C0, Ls_C7D0, Ls_C7E0, Ls_C7F0);
   FileClose(Ii_0AAC);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_004C = GetLastError();
   Ii_1024 = Gi_004C;
   Li_8A9C = Gi_004C;
   Ls_C710 = "";
   Ls_C700 = "";
   Ls_C6F0 = (string)OrderStopLoss();
   Ls_C6E0 = " Current SL: ";
   Ls_C6D0 = (string)Bid;
   Ls_C6C0 = ", Bid: ";
   Ls_C6B0 = (string)Ask;
   Ls_C6A0 = ", Ask: ";
   Ls_C690 = func_1032(Gi_004C);
   Ls_C680 = " - ";
   Ls_C670 = (string)Ii_1024;
   Ls_C660 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_C650 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C650, " ", Ls_C660, Ls_C670, Ls_C680, Ls_C690, Ls_C6A0, Ls_C6B0, Ls_C6C0, Ls_C6D0, Ls_C6E0, Ls_C6F0, Ls_C700, Ls_C710);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0AB0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AB0 > 0) { 
   FileSeek(Ii_0AB0, 0, 2);
   Ls_C640 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AB0, Ls_C640, " VERBOSE: ", Ls_C660, Ls_C670, Ls_C680, Ls_C690, Ls_C6A0, Ls_C6B0, Ls_C6C0, Ls_C6D0, Ls_C6E0, Ls_C6F0, Ls_C700, Ls_C710);
   FileClose(Ii_0AB0);
   }}}}}}}}} 
   Ii_04C8 = Ii_0084;
   Id_04D0 = 0;
   if (Ii_0084 == Ii_006C) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0070) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0074) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0078) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_007C) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0080) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0084) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0088) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_008C) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0090) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0094) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_0098) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_009C) { 
   Id_04D0 = 0;
   } 
   if (Ii_04C8 == Ii_00A0) { 
   Id_04D0 = 0;
   } 
   returned_double = NormalizeDouble(Id_04D0, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_0AB4 = (int)(returned_double + 10);
   Il_0AB8 = OrderOpenTime();
   Ii_0AC0 = 0;
   Ii_04F0 = 0;
   Ii_1024 = Ii_0AB4 + 10;
   if (Ii_1024 > 0) { 
   do { 
   if (Il_0AB8 < Time[Ii_04F0]) { 
   Ii_0AC0 = Ii_0AC0 + 1;
   } 
   Ii_04F0 = Ii_04F0 + 1;
   Ii_1030 = Ii_0AB4 + 10;
   } while (Ii_04F0 < Ii_1030); 
   } 
   if ((Ii_0AC0 >= Ld_8AB8)) { 
   Ls_C630 = "";
   Ls_C620 = "";
   Ls_C610 = "";
   Ls_C600 = "";
   Ls_C5F0 = "";
   Ls_C5E0 = "";
   Ls_C5D0 = (string)Fa_i_00;
   Ls_C5C0 = ", Magic Number: ";
   Ls_C5B0 = (string)OrderTicket();
   Ls_C5A0 = "bars - closing order with ticket: ";
   Ls_C590 = (string)Ld_8AB8;
   Ls_C580 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_C570 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C570, " ", Ls_C580, Ls_C590, Ls_C5A0, Ls_C5B0, Ls_C5C0, Ls_C5D0, Ls_C5E0, Ls_C5F0, Ls_C600, Ls_C610, Ls_C620, Ls_C630);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0AC4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AC4 > 0) { 
   FileSeek(Ii_0AC4, 0, 2);
   Ls_C560 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AC4, Ls_C560, " VERBOSE: ", Ls_C580, Ls_C590, Ls_C5A0, Ls_C5B0, Ls_C5C0, Ls_C5D0, Ls_C5E0, Ls_C5F0, Ls_C600, Ls_C610, Ls_C620, Ls_C630);
   FileClose(Ii_0AC4);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0088) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0088, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0500 = Ii_0088;
   Id_0508 = 0;
   if (Ii_0088 == Ii_006C) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0070) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0074) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0078) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_007C) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0080) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0084) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0088) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_008C) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0090) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0094) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_0098) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_009C) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   if (Ii_0500 == Ii_00A0) { 
   Id_0508 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0508, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_C550 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_C550 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_C530 = "";
   Ls_C520 = "";
   Ls_C510 = "";
   Ls_C500 = "";
   Ls_C4F0 = "";
   Ls_C4E0 = "";
   Ls_C4D0 = (string)Ld_8AA8;
   Ls_C4C0 = " to :";
   Ls_C4B0 = (string)Fa_i_00;
   Ls_C4A0 = ", Magic Number: ";
   Ls_C490 = (string)OrderTicket();
   Ls_C480 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_C470 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C470, " ", Ls_C480, Ls_C490, Ls_C4A0, Ls_C4B0, Ls_C4C0, Ls_C4D0, Ls_C4E0, Ls_C4F0, Ls_C500, Ls_C510, Ls_C520, Ls_C530);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0AC8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AC8 > 0) { 
   FileSeek(Ii_0AC8, 0, 2);
   Ls_C460 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AC8, Ls_C460, " VERBOSE: ", Ls_C480, Ls_C490, Ls_C4A0, Ls_C4B0, Ls_C4C0, Ls_C4D0, Ls_C4E0, Ls_C4F0, Ls_C500, Ls_C510, Ls_C520, Ls_C530);
   FileClose(Ii_0AC8);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0050 = GetLastError();
   Ii_1068 = Gi_0050;
   Li_8A9C = Gi_0050;
   Ls_C450 = "";
   Ls_C440 = "";
   Ls_C430 = "";
   Ls_C420 = "";
   Ls_C410 = "";
   Ls_C400 = "";
   Ls_C3F0 = "";
   Ls_C3E0 = "";
   Ls_C3D0 = func_1032(Gi_0050);
   Ls_C3C0 = " - ";
   Ls_C3B0 = (string)Ii_1068;
   Ls_C3A0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_C390 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C390, " ", Ls_C3A0, Ls_C3B0, Ls_C3C0, Ls_C3D0, Ls_C3E0, Ls_C3F0, Ls_C400, Ls_C410, Ls_C420, Ls_C430, Ls_C440, Ls_C450);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0518 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0518 > 0) {
   FileSeek(Ii_0518, 0, 2);
   Ls_C380 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0518, Ls_C380, " VERBOSE: ", Ls_C3A0, Ls_C3B0, Ls_C3C0, Ls_C3D0, Ls_C3E0, Ls_C3F0, Ls_C400, Ls_C410, Ls_C420, Ls_C430, Ls_C440, Ls_C450);
   FileClose(Ii_0518);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_C370 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_C370 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_C350 = "";
   Ls_C340 = "";
   Ls_C330 = "";
   Ls_C320 = "";
   Ls_C310 = "";
   Ls_C300 = "";
   Ls_C2F0 = (string)Ld_8AA8;
   Ls_C2E0 = " to :";
   Ls_C2D0 = (string)Fa_i_00;
   Ls_C2C0 = ", Magic Number: ";
   Ls_C2B0 = (string)OrderTicket();
   Ls_C2A0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_C290 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C290, " ", Ls_C2A0, Ls_C2B0, Ls_C2C0, Ls_C2D0, Ls_C2E0, Ls_C2F0, Ls_C300, Ls_C310, Ls_C320, Ls_C330, Ls_C340, Ls_C350);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0ACC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0ACC > 0) { 
   FileSeek(Ii_0ACC, 0, 2);
   Ls_C280 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0ACC, Ls_C280, " VERBOSE: ", Ls_C2A0, Ls_C2B0, Ls_C2C0, Ls_C2D0, Ls_C2E0, Ls_C2F0, Ls_C300, Ls_C310, Ls_C320, Ls_C330, Ls_C340, Ls_C350);
   FileClose(Ii_0ACC);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0052 = GetLastError();
   Ii_15E0 = Gi_0052;
   Li_8A9C = Gi_0052;
   Ls_C270 = "";
   Ls_C260 = "";
   Ls_C250 = (string)OrderStopLoss();
   Ls_C240 = " Current SL: ";
   Ls_C230 = (string)Bid;
   Ls_C220 = ", Bid: ";
   Ls_C210 = (string)Ask;
   Ls_C200 = ", Ask: ";
   Ls_C1F0 = func_1032(Gi_0052);
   Ls_C1E0 = " - ";
   Ls_C1D0 = (string)Ii_15E0;
   Ls_C1C0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_C1B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C1B0, " ", Ls_C1C0, Ls_C1D0, Ls_C1E0, Ls_C1F0, Ls_C200, Ls_C210, Ls_C220, Ls_C230, Ls_C240, Ls_C250, Ls_C260, Ls_C270);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0AD0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AD0 > 0) { 
   FileSeek(Ii_0AD0, 0, 2);
   Ls_C1A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AD0, Ls_C1A0, " VERBOSE: ", Ls_C1C0, Ls_C1D0, Ls_C1E0, Ls_C1F0, Ls_C200, Ls_C210, Ls_C220, Ls_C230, Ls_C240, Ls_C250, Ls_C260, Ls_C270);
   FileClose(Ii_0AD0);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0088, OrderType(), OrderOpenPrice());
   Ii_0530 = Ii_0088;
   Id_0538 = 0;
   if (Ii_0088 == Ii_006C) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0070) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0074) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0078) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_007C) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0080) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0084) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0088) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_008C) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0090) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0094) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_0098) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_009C) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   if (Ii_0530 == Ii_00A0) { 
   Id_0538 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0538, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_C190 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_C190 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_C170 = "";
   Ls_C160 = "";
   Ls_C150 = "";
   Ls_C140 = "";
   Ls_C130 = "";
   Ls_C120 = "";
   Ls_C110 = (string)Ld_8AA8;
   Ls_C100 = " to :";
   Ls_C0F0 = (string)Fa_i_00;
   Ls_C0E0 = ", Magic Number: ";
   Ls_C0D0 = (string)OrderTicket();
   Ls_C0C0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_C0B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_C0B0, " ", Ls_C0C0, Ls_C0D0, Ls_C0E0, Ls_C0F0, Ls_C100, Ls_C110, Ls_C120, Ls_C130, Ls_C140, Ls_C150, Ls_C160, Ls_C170);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0540 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0540 > 0) { 
   FileSeek(Ii_0540, 0, 2);
   Ls_C0A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0540, Ls_C0A0, " VERBOSE: ", Ls_C0C0, Ls_C0D0, Ls_C0E0, Ls_C0F0, Ls_C100, Ls_C110, Ls_C120, Ls_C130, Ls_C140, Ls_C150, Ls_C160, Ls_C170);
   FileClose(Ii_0540);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0055 = GetLastError();
   Ii_10A0 = Gi_0055;
   Li_8A9C = Gi_0055;
   Ls_C090 = "";
   Ls_C080 = "";
   Ls_C070 = (string)OrderStopLoss();
   Ls_C060 = " Current SL: ";
   Ls_C050 = (string)Bid;
   Ls_C040 = ", Bid: ";
   Ls_C030 = (string)Ask;
   Ls_C020 = ", Ask: ";
   Ls_C010 = func_1032(Gi_0055);
   Ls_C000 = " - ";
   Ls_BFF0 = (string)Ii_10A0;
   Ls_BFE0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_BFD0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_BFD0, " ", Ls_BFE0, Ls_BFF0, Ls_C000, Ls_C010, Ls_C020, Ls_C030, Ls_C040, Ls_C050, Ls_C060, Ls_C070, Ls_C080, Ls_C090);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0AD4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AD4 > 0) {
   FileSeek(Ii_0AD4, 0, 2);
   Ls_BFC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AD4, Ls_BFC0, " VERBOSE: ", Ls_BFE0, Ls_BFF0, Ls_C000, Ls_C010, Ls_C020, Ls_C030, Ls_C040, Ls_C050, Ls_C060, Ls_C070, Ls_C080, Ls_C090);
   FileClose(Ii_0AD4);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_BFB0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_BFB0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_BF90 = "";
   Ls_BF80 = "";
   Ls_BF70 = "";
   Ls_BF60 = "";
   Ls_BF50 = "";
   Ls_BF40 = "";
   Ls_BF30 = (string)Ld_8AA8;
   Ls_BF20 = " to :";
   Ls_BF10 = (string)Fa_i_00;
   Ls_BF00 = ", Magic Number: ";
   Ls_BEF0 = (string)OrderTicket();
   Ls_BEE0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_BED0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_BED0, " ", Ls_BEE0, Ls_BEF0, Ls_BF00, Ls_BF10, Ls_BF20, Ls_BF30, Ls_BF40, Ls_BF50, Ls_BF60, Ls_BF70, Ls_BF80, Ls_BF90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0550 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0550 > 0) { 
   FileSeek(Ii_0550, 0, 2);
   Ls_BEC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0550, Ls_BEC0, " VERBOSE: ", Ls_BEE0, Ls_BEF0, Ls_BF00, Ls_BF10, Ls_BF20, Ls_BF30, Ls_BF40, Ls_BF50, Ls_BF60, Ls_BF70, Ls_BF80, Ls_BF90);
   FileClose(Ii_0550);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0057 = GetLastError();
   Ii_10B4 = Gi_0057;
   Li_8A9C = Gi_0057;
   Ls_BEB0 = "";
   Ls_BEA0 = "";
   Ls_BE90 = (string)OrderStopLoss();
   Ls_BE80 = " Current SL: ";
   Ls_BE70 = (string)Bid;
   Ls_BE60 = ", Bid: ";
   Ls_BE50 = (string)Ask;
   Ls_BE40 = ", Ask: ";
   Ls_BE30 = func_1032(Gi_0057);
   Ls_BE20 = " - ";
   Ls_BE10 = (string)Ii_10B4;
   Ls_BE00 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_BDF0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_BDF0, " ", Ls_BE00, Ls_BE10, Ls_BE20, Ls_BE30, Ls_BE40, Ls_BE50, Ls_BE60, Ls_BE70, Ls_BE80, Ls_BE90, Ls_BEA0, Ls_BEB0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0AD8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AD8 > 0) { 
   FileSeek(Ii_0AD8, 0, 2);
   Ls_BDE0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AD8, Ls_BDE0, " VERBOSE: ", Ls_BE00, Ls_BE10, Ls_BE20, Ls_BE30, Ls_BE40, Ls_BE50, Ls_BE60, Ls_BE70, Ls_BE80, Ls_BE90, Ls_BEA0, Ls_BEB0);
   FileClose(Ii_0AD8);
   }}}}}}}}} 
   Ii_0ADC = Ii_0088;
   Id_0AE0 = 0;
   if (Ii_0088 == Ii_006C) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0070) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0074) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0078) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_007C) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0080) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0084) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0088) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_008C) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0090) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0094) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_0098) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_009C) { 
   Id_0AE0 = 0;
   } 
   if (Ii_0ADC == Ii_00A0) { 
   Id_0AE0 = 0;
   } 
   returned_double = NormalizeDouble(Id_0AE0, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_0AE8 = (int)(returned_double + 10);
   Il_0AF0 = OrderOpenTime();
   Ii_0580 = 0;
   Ii_0AF8 = 0;
   Ii_10B4 = Ii_0AE8 + 10;
   if (Ii_10B4 > 0) { 
   do { 
   if (Il_0AF0 < Time[Ii_0AF8]) { 
   Ii_0580 = Ii_0580 + 1;
   } 
   Ii_0AF8 = Ii_0AF8 + 1;
   Ii_10C0 = Ii_0AE8 + 10;
   } while (Ii_0AF8 < Ii_10C0); 
   } 
   if ((Ii_0580 >= Ld_8AB8)) { 
   Ls_BDD0 = "";
   Ls_BDC0 = "";
   Ls_BDB0 = "";
   Ls_BDA0 = "";
   Ls_BD90 = "";
   Ls_BD80 = "";
   Ls_BD70 = (string)Fa_i_00;
   Ls_BD60 = ", Magic Number: ";
   Ls_BD50 = (string)OrderTicket();
   Ls_BD40 = "bars - closing order with ticket: ";
   Ls_BD30 = (string)Ld_8AB8;
   Ls_BD20 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_BD10 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_BD10, " ", Ls_BD20, Ls_BD30, Ls_BD40, Ls_BD50, Ls_BD60, Ls_BD70, Ls_BD80, Ls_BD90, Ls_BDA0, Ls_BDB0, Ls_BDC0, Ls_BDD0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0AFC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0AFC > 0) { 
   FileSeek(Ii_0AFC, 0, 2);
   Ls_BD00 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0AFC, Ls_BD00, " VERBOSE: ", Ls_BD20, Ls_BD30, Ls_BD40, Ls_BD50, Ls_BD60, Ls_BD70, Ls_BD80, Ls_BD90, Ls_BDA0, Ls_BDB0, Ls_BDC0, Ls_BDD0);
   FileClose(Ii_0AFC);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_008C) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_008C, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0598 = Ii_008C;
   Id_05A0 = 0;
   if (Ii_008C == Ii_006C) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0070) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0074) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0078) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_007C) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0080) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0084) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0088) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_008C) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0090) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0094) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_0098) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_009C) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   if (Ii_0598 == Ii_00A0) { 
   Id_05A0 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_05A0, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_BCF0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_BCF0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_BCD0 = "";
   Ls_BCC0 = "";
   Ls_BCB0 = "";
   Ls_BCA0 = "";
   Ls_BC90 = "";
   Ls_BC80 = "";
   Ls_BC70 = (string)Ld_8AA8;
   Ls_BC60 = " to :";
   Ls_BC50 = (string)Fa_i_00;
   Ls_BC40 = ", Magic Number: ";
   Ls_BC30 = (string)OrderTicket();
   Ls_BC20 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_BC10 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_BC10, " ", Ls_BC20, Ls_BC30, Ls_BC40, Ls_BC50, Ls_BC60, Ls_BC70, Ls_BC80, Ls_BC90, Ls_BCA0, Ls_BCB0, Ls_BCC0, Ls_BCD0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_05A8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_05A8 > 0) { 
   FileSeek(Ii_05A8, 0, 2);
   Ls_BC00 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_05A8, Ls_BC00, " VERBOSE: ", Ls_BC20, Ls_BC30, Ls_BC40, Ls_BC50, Ls_BC60, Ls_BC70, Ls_BC80, Ls_BC90, Ls_BCA0, Ls_BCB0, Ls_BCC0, Ls_BCD0);
   FileClose(Ii_05A8);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_005B = GetLastError();
   Ii_10F8 = Gi_005B;
   Li_8A9C = Gi_005B;
   Ls_BBF0 = "";
   Ls_BBE0 = "";
   Ls_BBD0 = "";
   Ls_BBC0 = "";
   Ls_BBB0 = "";
   Ls_BBA0 = "";
   Ls_BB90 = "";
   Ls_BB80 = "";
   Ls_BB70 = func_1032(Gi_005B);
   Ls_BB60 = " - ";
   Ls_BB50 = (string)Ii_10F8;
   Ls_BB40 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_BB30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_BB30, " ", Ls_BB40, Ls_BB50, Ls_BB60, Ls_BB70, Ls_BB80, Ls_BB90, Ls_BBA0, Ls_BBB0, Ls_BBC0, Ls_BBD0, Ls_BBE0, Ls_BBF0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_05AC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_05AC > 0) {
   FileSeek(Ii_05AC, 0, 2);
   Ls_BB20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_05AC, Ls_BB20, " VERBOSE: ", Ls_BB40, Ls_BB50, Ls_BB60, Ls_BB70, Ls_BB80, Ls_BB90, Ls_BBA0, Ls_BBB0, Ls_BBC0, Ls_BBD0, Ls_BBE0, Ls_BBF0);
   FileClose(Ii_05AC);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_BB10 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_BB10 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_BAF0 = "";
   Ls_BAE0 = "";
   Ls_BAD0 = "";
   Ls_BAC0 = "";
   Ls_BAB0 = "";
   Ls_BAA0 = "";
   Ls_BA90 = (string)Ld_8AA8;
   Ls_BA80 = " to :";
   Ls_BA70 = (string)Fa_i_00;
   Ls_BA60 = ", Magic Number: ";
   Ls_BA50 = (string)OrderTicket();
   Ls_BA40 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_BA30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_BA30, " ", Ls_BA40, Ls_BA50, Ls_BA60, Ls_BA70, Ls_BA80, Ls_BA90, Ls_BAA0, Ls_BAB0, Ls_BAC0, Ls_BAD0, Ls_BAE0, Ls_BAF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B00 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B00 > 0) { 
   FileSeek(Ii_0B00, 0, 2);
   Ls_BA20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B00, Ls_BA20, " VERBOSE: ", Ls_BA40, Ls_BA50, Ls_BA60, Ls_BA70, Ls_BA80, Ls_BA90, Ls_BAA0, Ls_BAB0, Ls_BAC0, Ls_BAD0, Ls_BAE0, Ls_BAF0);
   FileClose(Ii_0B00);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_005D = GetLastError();
   Ii_15A0 = Gi_005D;
   Li_8A9C = Gi_005D;
   Ls_BA10 = "";
   Ls_BA00 = "";
   Ls_B9F0 = (string)OrderStopLoss();
   Ls_B9E0 = " Current SL: ";
   Ls_B9D0 = (string)Bid;
   Ls_B9C0 = ", Bid: ";
   Ls_B9B0 = (string)Ask;
   Ls_B9A0 = ", Ask: ";
   Ls_B990 = func_1032(Gi_005D);
   Ls_B980 = " - ";
   Ls_B970 = (string)Ii_15A0;
   Ls_B960 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_B950 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B950, " ", Ls_B960, Ls_B970, Ls_B980, Ls_B990, Ls_B9A0, Ls_B9B0, Ls_B9C0, Ls_B9D0, Ls_B9E0, Ls_B9F0, Ls_BA00, Ls_BA10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_05B8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_05B8 > 0) { 
   FileSeek(Ii_05B8, 0, 2);
   Ls_B940 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_05B8, Ls_B940, " VERBOSE: ", Ls_B960, Ls_B970, Ls_B980, Ls_B990, Ls_B9A0, Ls_B9B0, Ls_B9C0, Ls_B9D0, Ls_B9E0, Ls_B9F0, Ls_BA00, Ls_BA10);
   FileClose(Ii_05B8);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_008C, OrderType(), OrderOpenPrice());
   Ii_0B04 = Ii_008C;
   Id_0B08 = 0;
   if (Ii_008C == Ii_006C) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0070) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0074) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0078) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_007C) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0080) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0084) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0088) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_008C) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0090) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0094) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_0098) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_009C) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   if (Ii_0B04 == Ii_00A0) { 
   Id_0B08 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0B08, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_B930 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_B930 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_B910 = "";
   Ls_B900 = "";
   Ls_B8F0 = "";
   Ls_B8E0 = "";
   Ls_B8D0 = "";
   Ls_B8C0 = "";
   Ls_B8B0 = (string)Ld_8AA8;
   Ls_B8A0 = " to :";
   Ls_B890 = (string)Fa_i_00;
   Ls_B880 = ", Magic Number: ";
   Ls_B870 = (string)OrderTicket();
   Ls_B860 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_B850 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B850, " ", Ls_B860, Ls_B870, Ls_B880, Ls_B890, Ls_B8A0, Ls_B8B0, Ls_B8C0, Ls_B8D0, Ls_B8E0, Ls_B8F0, Ls_B900, Ls_B910);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B10 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B10 > 0) { 
   FileSeek(Ii_0B10, 0, 2);
   Ls_B840 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B10, Ls_B840, " VERBOSE: ", Ls_B860, Ls_B870, Ls_B880, Ls_B890, Ls_B8A0, Ls_B8B0, Ls_B8C0, Ls_B8D0, Ls_B8E0, Ls_B8F0, Ls_B900, Ls_B910);
   FileClose(Ii_0B10);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0060 = GetLastError();
   Ii_1130 = Gi_0060;
   Li_8A9C = Gi_0060;
   Ls_B830 = "";
   Ls_B820 = "";
   Ls_B810 = (string)OrderStopLoss();
   Ls_B800 = " Current SL: ";
   Ls_B7F0 = (string)Bid;
   Ls_B7E0 = ", Bid: ";
   Ls_B7D0 = (string)Ask;
   Ls_B7C0 = ", Ask: ";
   Ls_B7B0 = func_1032(Gi_0060);
   Ls_B7A0 = " - ";
   Ls_B790 = (string)Ii_1130;
   Ls_B780 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_B770 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B770, " ", Ls_B780, Ls_B790, Ls_B7A0, Ls_B7B0, Ls_B7C0, Ls_B7D0, Ls_B7E0, Ls_B7F0, Ls_B800, Ls_B810, Ls_B820, Ls_B830);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_05D8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_05D8 > 0) {
   FileSeek(Ii_05D8, 0, 2);
   Ls_B760 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_05D8, Ls_B760, " VERBOSE: ", Ls_B780, Ls_B790, Ls_B7A0, Ls_B7B0, Ls_B7C0, Ls_B7D0, Ls_B7E0, Ls_B7F0, Ls_B800, Ls_B810, Ls_B820, Ls_B830);
   FileClose(Ii_05D8);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_B750 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_B750 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_B730 = "";
   Ls_B720 = "";
   Ls_B710 = "";
   Ls_B700 = "";
   Ls_B6F0 = "";
   Ls_B6E0 = "";
   Ls_B6D0 = (string)Ld_8AA8;
   Ls_B6C0 = " to :";
   Ls_B6B0 = (string)Fa_i_00;
   Ls_B6A0 = ", Magic Number: ";
   Ls_B690 = (string)OrderTicket();
   Ls_B680 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_B670 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B670, " ", Ls_B680, Ls_B690, Ls_B6A0, Ls_B6B0, Ls_B6C0, Ls_B6D0, Ls_B6E0, Ls_B6F0, Ls_B700, Ls_B710, Ls_B720, Ls_B730);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_05DC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_05DC > 0) { 
   FileSeek(Ii_05DC, 0, 2);
   Ls_B660 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_05DC, Ls_B660, " VERBOSE: ", Ls_B680, Ls_B690, Ls_B6A0, Ls_B6B0, Ls_B6C0, Ls_B6D0, Ls_B6E0, Ls_B6F0, Ls_B700, Ls_B710, Ls_B720, Ls_B730);
   FileClose(Ii_05DC);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0062 = GetLastError();
   Ii_1144 = Gi_0062;
   Li_8A9C = Gi_0062;
   Ls_B650 = "";
   Ls_B640 = "";
   Ls_B630 = (string)OrderStopLoss();
   Ls_B620 = " Current SL: ";
   Ls_B610 = (string)Bid;
   Ls_B600 = ", Bid: ";
   Ls_B5F0 = (string)Ask;
   Ls_B5E0 = ", Ask: ";
   Ls_B5D0 = func_1032(Gi_0062);
   Ls_B5C0 = " - ";
   Ls_B5B0 = (string)Ii_1144;
   Ls_B5A0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_B590 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B590, " ", Ls_B5A0, Ls_B5B0, Ls_B5C0, Ls_B5D0, Ls_B5E0, Ls_B5F0, Ls_B600, Ls_B610, Ls_B620, Ls_B630, Ls_B640, Ls_B650);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B14 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B14 > 0) { 
   FileSeek(Ii_0B14, 0, 2);
   Ls_B580 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B14, Ls_B580, " VERBOSE: ", Ls_B5A0, Ls_B5B0, Ls_B5C0, Ls_B5D0, Ls_B5E0, Ls_B5F0, Ls_B600, Ls_B610, Ls_B620, Ls_B630, Ls_B640, Ls_B650);
   FileClose(Ii_0B14);
   }}}}}}}}} 
   Ii_05E8 = Ii_008C;
   Id_05F0 = 0;
   if (Ii_008C == Ii_006C) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0070) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0074) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0078) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_007C) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0080) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0084) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0088) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_008C) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0090) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0094) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_0098) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_009C) { 
   Id_05F0 = 0;
   } 
   if (Ii_05E8 == Ii_00A0) { 
   Id_05F0 = 0;
   } 
   returned_double = NormalizeDouble(Id_05F0, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_05F8 = (int)(returned_double + 10);
   Il_0B18 = OrderOpenTime();
   Ii_0608 = 0;
   Ii_0B20 = 0;
   Ii_1144 = Ii_05F8 + 10;
   if (Ii_1144 > 0) { 
   do { 
   if (Il_0B18 < Time[Ii_0B20]) { 
   Ii_0608 = Ii_0608 + 1;
   } 
   Ii_0B20 = Ii_0B20 + 1;
   Ii_1150 = Ii_05F8 + 10;
   } while (Ii_0B20 < Ii_1150); 
   } 
   if ((Ii_0608 >= Ld_8AB8)) { 
   Ls_B570 = "";
   Ls_B560 = "";
   Ls_B550 = "";
   Ls_B540 = "";
   Ls_B530 = "";
   Ls_B520 = "";
   Ls_B510 = (string)Fa_i_00;
   Ls_B500 = ", Magic Number: ";
   Ls_B4F0 = (string)OrderTicket();
   Ls_B4E0 = "bars - closing order with ticket: ";
   Ls_B4D0 = (string)Ld_8AB8;
   Ls_B4C0 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_B4B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B4B0, " ", Ls_B4C0, Ls_B4D0, Ls_B4E0, Ls_B4F0, Ls_B500, Ls_B510, Ls_B520, Ls_B530, Ls_B540, Ls_B550, Ls_B560, Ls_B570);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0618 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0618 > 0) { 
   FileSeek(Ii_0618, 0, 2);
   Ls_B4A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0618, Ls_B4A0, " VERBOSE: ", Ls_B4C0, Ls_B4D0, Ls_B4E0, Ls_B4F0, Ls_B500, Ls_B510, Ls_B520, Ls_B530, Ls_B540, Ls_B550, Ls_B560, Ls_B570);
   FileClose(Ii_0618);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0090) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0090, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0B24 = Ii_0090;
   Id_0B28 = 0;
   if (Ii_0090 == Ii_006C) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0070) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0074) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0078) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_007C) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0080) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0084) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0088) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_008C) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0090) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0094) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_0098) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_009C) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   if (Ii_0B24 == Ii_00A0) { 
   Id_0B28 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0B28, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_B490 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_B490 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_B470 = "";
   Ls_B460 = "";
   Ls_B450 = "";
   Ls_B440 = "";
   Ls_B430 = "";
   Ls_B420 = "";
   Ls_B410 = (string)Ld_8AA8;
   Ls_B400 = " to :";
   Ls_B3F0 = (string)Fa_i_00;
   Ls_B3E0 = ", Magic Number: ";
   Ls_B3D0 = (string)OrderTicket();
   Ls_B3C0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_B3B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B3B0, " ", Ls_B3C0, Ls_B3D0, Ls_B3E0, Ls_B3F0, Ls_B400, Ls_B410, Ls_B420, Ls_B430, Ls_B440, Ls_B450, Ls_B460, Ls_B470);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_062C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_062C > 0) { 
   FileSeek(Ii_062C, 0, 2);
   Ls_B3A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_062C, Ls_B3A0, " VERBOSE: ", Ls_B3C0, Ls_B3D0, Ls_B3E0, Ls_B3F0, Ls_B400, Ls_B410, Ls_B420, Ls_B430, Ls_B440, Ls_B450, Ls_B460, Ls_B470);
   FileClose(Ii_062C);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0066 = GetLastError();
   Ii_1188 = Gi_0066;
   Li_8A9C = Gi_0066;
   Ls_B390 = "";
   Ls_B380 = "";
   Ls_B370 = "";
   Ls_B360 = "";
   Ls_B350 = "";
   Ls_B340 = "";
   Ls_B330 = "";
   Ls_B320 = "";
   Ls_B310 = func_1032(Gi_0066);
   Ls_B300 = " - ";
   Ls_B2F0 = (string)Ii_1188;
   Ls_B2E0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_B2D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B2D0, " ", Ls_B2E0, Ls_B2F0, Ls_B300, Ls_B310, Ls_B320, Ls_B330, Ls_B340, Ls_B350, Ls_B360, Ls_B370, Ls_B380, Ls_B390);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0B30 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B30 > 0) {
   FileSeek(Ii_0B30, 0, 2);
   Ls_B2C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B30, Ls_B2C0, " VERBOSE: ", Ls_B2E0, Ls_B2F0, Ls_B300, Ls_B310, Ls_B320, Ls_B330, Ls_B340, Ls_B350, Ls_B360, Ls_B370, Ls_B380, Ls_B390);
   FileClose(Ii_0B30);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_B2B0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_B2B0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_B290 = "";
   Ls_B280 = "";
   Ls_B270 = "";
   Ls_B260 = "";
   Ls_B250 = "";
   Ls_B240 = "";
   Ls_B230 = (string)Ld_8AA8;
   Ls_B220 = " to :";
   Ls_B210 = (string)Fa_i_00;
   Ls_B200 = ", Magic Number: ";
   Ls_B1F0 = (string)OrderTicket();
   Ls_B1E0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_B1D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B1D0, " ", Ls_B1E0, Ls_B1F0, Ls_B200, Ls_B210, Ls_B220, Ls_B230, Ls_B240, Ls_B250, Ls_B260, Ls_B270, Ls_B280, Ls_B290);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0638 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0638 > 0) { 
   FileSeek(Ii_0638, 0, 2);
   Ls_B1C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0638, Ls_B1C0, " VERBOSE: ", Ls_B1E0, Ls_B1F0, Ls_B200, Ls_B210, Ls_B220, Ls_B230, Ls_B240, Ls_B250, Ls_B260, Ls_B270, Ls_B280, Ls_B290);
   FileClose(Ii_0638);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0068 = GetLastError();
   Ii_1560 = Gi_0068;
   Li_8A9C = Gi_0068;
   Ls_B1B0 = "";
   Ls_B1A0 = "";
   Ls_B190 = (string)OrderStopLoss();
   Ls_B180 = " Current SL: ";
   Ls_B170 = (string)Bid;
   Ls_B160 = ", Bid: ";
   Ls_B150 = (string)Ask;
   Ls_B140 = ", Ask: ";
   Ls_B130 = func_1032(Gi_0068);
   Ls_B120 = " - ";
   Ls_B110 = (string)Ii_1560;
   Ls_B100 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_B0F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_B0F0, " ", Ls_B100, Ls_B110, Ls_B120, Ls_B130, Ls_B140, Ls_B150, Ls_B160, Ls_B170, Ls_B180, Ls_B190, Ls_B1A0, Ls_B1B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_063C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_063C > 0) { 
   FileSeek(Ii_063C, 0, 2);
   Ls_B0E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_063C, Ls_B0E0, " VERBOSE: ", Ls_B100, Ls_B110, Ls_B120, Ls_B130, Ls_B140, Ls_B150, Ls_B160, Ls_B170, Ls_B180, Ls_B190, Ls_B1A0, Ls_B1B0);
   FileClose(Ii_063C);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0090, OrderType(), OrderOpenPrice());
   Ii_0B34 = Ii_0090;
   Id_0B38 = 0;
   if (Ii_0090 == Ii_006C) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0070) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0074) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0078) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_007C) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0080) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0084) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0088) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_008C) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0090) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0094) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_0098) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_009C) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   if (Ii_0B34 == Ii_00A0) { 
   Id_0B38 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0B38, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_B0D0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_B0D0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_B0B0 = "";
   Ls_B0A0 = "";
   Ls_B090 = "";
   Ls_B080 = "";
   Ls_B070 = "";
   Ls_B060 = "";
   Ls_B050 = (string)Ld_8AA8;
   Ls_B040 = " to :";
   Ls_B030 = (string)Fa_i_00;
   Ls_B020 = ", Magic Number: ";
   Ls_B010 = (string)OrderTicket();
   Ls_B000 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_AFF0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_AFF0, " ", Ls_B000, Ls_B010, Ls_B020, Ls_B030, Ls_B040, Ls_B050, Ls_B060, Ls_B070, Ls_B080, Ls_B090, Ls_B0A0, Ls_B0B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B40 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B40 > 0) { 
   FileSeek(Ii_0B40, 0, 2);
   Ls_AFE0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B40, Ls_AFE0, " VERBOSE: ", Ls_B000, Ls_B010, Ls_B020, Ls_B030, Ls_B040, Ls_B050, Ls_B060, Ls_B070, Ls_B080, Ls_B090, Ls_B0A0, Ls_B0B0);
   FileClose(Ii_0B40);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_006B = GetLastError();
   Ii_11C0 = Gi_006B;
   Li_8A9C = Gi_006B;
   Ls_AFD0 = "";
   Ls_AFC0 = "";
   Ls_AFB0 = (string)OrderStopLoss();
   Ls_AFA0 = " Current SL: ";
   Ls_AF90 = (string)Bid;
   Ls_AF80 = ", Bid: ";
   Ls_AF70 = (string)Ask;
   Ls_AF60 = ", Ask: ";
   Ls_AF50 = func_1032(Gi_006B);
   Ls_AF40 = " - ";
   Ls_AF30 = (string)Ii_11C0;
   Ls_AF20 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_AF10 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_AF10, " ", Ls_AF20, Ls_AF30, Ls_AF40, Ls_AF50, Ls_AF60, Ls_AF70, Ls_AF80, Ls_AF90, Ls_AFA0, Ls_AFB0, Ls_AFC0, Ls_AFD0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0658 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0658 > 0) {
   FileSeek(Ii_0658, 0, 2);
   Ls_AF00 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0658, Ls_AF00, " VERBOSE: ", Ls_AF20, Ls_AF30, Ls_AF40, Ls_AF50, Ls_AF60, Ls_AF70, Ls_AF80, Ls_AF90, Ls_AFA0, Ls_AFB0, Ls_AFC0, Ls_AFD0);
   FileClose(Ii_0658);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_AEF0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_AEF0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_AED0 = "";
   Ls_AEC0 = "";
   Ls_AEB0 = "";
   Ls_AEA0 = "";
   Ls_AE90 = "";
   Ls_AE80 = "";
   Ls_AE70 = (string)Ld_8AA8;
   Ls_AE60 = " to :";
   Ls_AE50 = (string)Fa_i_00;
   Ls_AE40 = ", Magic Number: ";
   Ls_AE30 = (string)OrderTicket();
   Ls_AE20 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_AE10 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_AE10, " ", Ls_AE20, Ls_AE30, Ls_AE40, Ls_AE50, Ls_AE60, Ls_AE70, Ls_AE80, Ls_AE90, Ls_AEA0, Ls_AEB0, Ls_AEC0, Ls_AED0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B44 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B44 > 0) { 
   FileSeek(Ii_0B44, 0, 2);
   Ls_AE00 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B44, Ls_AE00, " VERBOSE: ", Ls_AE20, Ls_AE30, Ls_AE40, Ls_AE50, Ls_AE60, Ls_AE70, Ls_AE80, Ls_AE90, Ls_AEA0, Ls_AEB0, Ls_AEC0, Ls_AED0);
   FileClose(Ii_0B44);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_006D = GetLastError();
   Ii_11D4 = Gi_006D;
   Li_8A9C = Gi_006D;
   Ls_ADF0 = "";
   Ls_ADE0 = "";
   Ls_ADD0 = (string)OrderStopLoss();
   Ls_ADC0 = " Current SL: ";
   Ls_ADB0 = (string)Bid;
   Ls_ADA0 = ", Bid: ";
   Ls_AD90 = (string)Ask;
   Ls_AD80 = ", Ask: ";
   Ls_AD70 = func_1032(Gi_006D);
   Ls_AD60 = " - ";
   Ls_AD50 = (string)Ii_11D4;
   Ls_AD40 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_AD30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_AD30, " ", Ls_AD40, Ls_AD50, Ls_AD60, Ls_AD70, Ls_AD80, Ls_AD90, Ls_ADA0, Ls_ADB0, Ls_ADC0, Ls_ADD0, Ls_ADE0, Ls_ADF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0668 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0668 > 0) { 
   FileSeek(Ii_0668, 0, 2);
   Ls_AD20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0668, Ls_AD20, " VERBOSE: ", Ls_AD40, Ls_AD50, Ls_AD60, Ls_AD70, Ls_AD80, Ls_AD90, Ls_ADA0, Ls_ADB0, Ls_ADC0, Ls_ADD0, Ls_ADE0, Ls_ADF0);
   FileClose(Ii_0668);
   }}}}}}}}} 
   Ii_066C = Ii_0090;
   Id_0670 = 0;
   if (Ii_0090 == Ii_006C) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0070) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0074) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0078) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_007C) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0080) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0084) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0088) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_008C) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0090) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0094) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_0098) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_009C) { 
   Id_0670 = 0;
   } 
   if (Ii_066C == Ii_00A0) { 
   Id_0670 = 0;
   } 
   returned_double = NormalizeDouble(Id_0670, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_0678 = (int)(returned_double + 10);
   Il_0B48 = OrderOpenTime();
   Ii_0688 = 0;
   Ii_0B50 = 0;
   Ii_11D4 = Ii_0678 + 10;
   if (Ii_11D4 > 0) { 
   do { 
   if (Il_0B48 < Time[Ii_0B50]) { 
   Ii_0688 = Ii_0688 + 1;
   } 
   Ii_0B50 = Ii_0B50 + 1;
   Ii_11E0 = Ii_0678 + 10;
   } while (Ii_0B50 < Ii_11E0); 
   } 
   if ((Ii_0688 >= Ld_8AB8)) { 
   Ls_AD10 = "";
   Ls_AD00 = "";
   Ls_ACF0 = "";
   Ls_ACE0 = "";
   Ls_ACD0 = "";
   Ls_ACC0 = "";
   Ls_ACB0 = (string)Fa_i_00;
   Ls_ACA0 = ", Magic Number: ";
   Ls_AC90 = (string)OrderTicket();
   Ls_AC80 = "bars - closing order with ticket: ";
   Ls_AC70 = (string)Ld_8AB8;
   Ls_AC60 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_AC50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_AC50, " ", Ls_AC60, Ls_AC70, Ls_AC80, Ls_AC90, Ls_ACA0, Ls_ACB0, Ls_ACC0, Ls_ACD0, Ls_ACE0, Ls_ACF0, Ls_AD00, Ls_AD10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0698 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0698 > 0) { 
   FileSeek(Ii_0698, 0, 2);
   Ls_AC40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0698, Ls_AC40, " VERBOSE: ", Ls_AC60, Ls_AC70, Ls_AC80, Ls_AC90, Ls_ACA0, Ls_ACB0, Ls_ACC0, Ls_ACD0, Ls_ACE0, Ls_ACF0, Ls_AD00, Ls_AD10);
   FileClose(Ii_0698);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0094) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0094, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_069C = Ii_0094;
   Id_06A0 = 0;
   if (Ii_0094 == Ii_006C) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0070) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0074) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0078) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_007C) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0080) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0084) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0088) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_008C) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0090) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0094) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_0098) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_009C) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   if (Ii_069C == Ii_00A0) { 
   Id_06A0 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_06A0, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_AC30 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_AC30 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_AC10 = "";
   Ls_AC00 = "";
   Ls_ABF0 = "";
   Ls_ABE0 = "";
   Ls_ABD0 = "";
   Ls_ABC0 = "";
   Ls_ABB0 = (string)Ld_8AA8;
   Ls_ABA0 = " to :";
   Ls_AB90 = (string)Fa_i_00;
   Ls_AB80 = ", Magic Number: ";
   Ls_AB70 = (string)OrderTicket();
   Ls_AB60 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_AB50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_AB50, " ", Ls_AB60, Ls_AB70, Ls_AB80, Ls_AB90, Ls_ABA0, Ls_ABB0, Ls_ABC0, Ls_ABD0, Ls_ABE0, Ls_ABF0, Ls_AC00, Ls_AC10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_06A8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_06A8 > 0) { 
   FileSeek(Ii_06A8, 0, 2);
   Ls_AB40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_06A8, Ls_AB40, " VERBOSE: ", Ls_AB60, Ls_AB70, Ls_AB80, Ls_AB90, Ls_ABA0, Ls_ABB0, Ls_ABC0, Ls_ABD0, Ls_ABE0, Ls_ABF0, Ls_AC00, Ls_AC10);
   FileClose(Ii_06A8);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0071 = GetLastError();
   Ii_1218 = Gi_0071;
   Li_8A9C = Gi_0071;
   Ls_AB30 = "";
   Ls_AB20 = "";
   Ls_AB10 = "";
   Ls_AB00 = "";
   Ls_AAF0 = "";
   Ls_AAE0 = "";
   Ls_AAD0 = "";
   Ls_AAC0 = "";
   Ls_AAB0 = func_1032(Gi_0071);
   Ls_AAA0 = " - ";
   Ls_AA90 = (string)Ii_1218;
   Ls_AA80 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_AA70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_AA70, " ", Ls_AA80, Ls_AA90, Ls_AAA0, Ls_AAB0, Ls_AAC0, Ls_AAD0, Ls_AAE0, Ls_AAF0, Ls_AB00, Ls_AB10, Ls_AB20, Ls_AB30);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0B54 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B54 > 0) {
   FileSeek(Ii_0B54, 0, 2);
   Ls_AA60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B54, Ls_AA60, " VERBOSE: ", Ls_AA80, Ls_AA90, Ls_AAA0, Ls_AAB0, Ls_AAC0, Ls_AAD0, Ls_AAE0, Ls_AAF0, Ls_AB00, Ls_AB10, Ls_AB20, Ls_AB30);
   FileClose(Ii_0B54);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_AA50 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_AA50 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_AA30 = "";
   Ls_AA20 = "";
   Ls_AA10 = "";
   Ls_AA00 = "";
   Ls_A9F0 = "";
   Ls_A9E0 = "";
   Ls_A9D0 = (string)Ld_8AA8;
   Ls_A9C0 = " to :";
   Ls_A9B0 = (string)Fa_i_00;
   Ls_A9A0 = ", Magic Number: ";
   Ls_A990 = (string)OrderTicket();
   Ls_A980 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_A970 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A970, " ", Ls_A980, Ls_A990, Ls_A9A0, Ls_A9B0, Ls_A9C0, Ls_A9D0, Ls_A9E0, Ls_A9F0, Ls_AA00, Ls_AA10, Ls_AA20, Ls_AA30);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_06B8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_06B8 > 0) { 
   FileSeek(Ii_06B8, 0, 2);
   Ls_A960 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_06B8, Ls_A960, " VERBOSE: ", Ls_A980, Ls_A990, Ls_A9A0, Ls_A9B0, Ls_A9C0, Ls_A9D0, Ls_A9E0, Ls_A9F0, Ls_AA00, Ls_AA10, Ls_AA20, Ls_AA30);
   FileClose(Ii_06B8);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0073 = GetLastError();
   Ii_1520 = Gi_0073;
   Li_8A9C = Gi_0073;
   Ls_A950 = "";
   Ls_A940 = "";
   Ls_A930 = (string)OrderStopLoss();
   Ls_A920 = " Current SL: ";
   Ls_A910 = (string)Bid;
   Ls_A900 = ", Bid: ";
   Ls_A8F0 = (string)Ask;
   Ls_A8E0 = ", Ask: ";
   Ls_A8D0 = func_1032(Gi_0073);
   Ls_A8C0 = " - ";
   Ls_A8B0 = (string)Ii_1520;
   Ls_A8A0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_A890 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A890, " ", Ls_A8A0, Ls_A8B0, Ls_A8C0, Ls_A8D0, Ls_A8E0, Ls_A8F0, Ls_A900, Ls_A910, Ls_A920, Ls_A930, Ls_A940, Ls_A950);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B58 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B58 > 0) { 
   FileSeek(Ii_0B58, 0, 2);
   Ls_A880 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B58, Ls_A880, " VERBOSE: ", Ls_A8A0, Ls_A8B0, Ls_A8C0, Ls_A8D0, Ls_A8E0, Ls_A8F0, Ls_A900, Ls_A910, Ls_A920, Ls_A930, Ls_A940, Ls_A950);
   FileClose(Ii_0B58);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0094, OrderType(), OrderOpenPrice());
   Ii_06C8 = Ii_0094;
   Id_06D0 = 0;
   if (Ii_0094 == Ii_006C) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0070) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0074) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0078) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_007C) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0080) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0084) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0088) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_008C) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0090) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0094) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_0098) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_009C) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   if (Ii_06C8 == Ii_00A0) { 
   Id_06D0 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_06D0, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_A870 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_A870 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_A850 = "";
   Ls_A840 = "";
   Ls_A830 = "";
   Ls_A820 = "";
   Ls_A810 = "";
   Ls_A800 = "";
   Ls_A7F0 = (string)Ld_8AA8;
   Ls_A7E0 = " to :";
   Ls_A7D0 = (string)Fa_i_00;
   Ls_A7C0 = ", Magic Number: ";
   Ls_A7B0 = (string)OrderTicket();
   Ls_A7A0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_A790 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A790, " ", Ls_A7A0, Ls_A7B0, Ls_A7C0, Ls_A7D0, Ls_A7E0, Ls_A7F0, Ls_A800, Ls_A810, Ls_A820, Ls_A830, Ls_A840, Ls_A850);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_06D8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_06D8 > 0) { 
   FileSeek(Ii_06D8, 0, 2);
   Ls_A780 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_06D8, Ls_A780, " VERBOSE: ", Ls_A7A0, Ls_A7B0, Ls_A7C0, Ls_A7D0, Ls_A7E0, Ls_A7F0, Ls_A800, Ls_A810, Ls_A820, Ls_A830, Ls_A840, Ls_A850);
   FileClose(Ii_06D8);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0076 = GetLastError();
   Ii_1250 = Gi_0076;
   Li_8A9C = Gi_0076;
   Ls_A770 = "";
   Ls_A760 = "";
   Ls_A750 = (string)OrderStopLoss();
   Ls_A740 = " Current SL: ";
   Ls_A730 = (string)Bid;
   Ls_A720 = ", Bid: ";
   Ls_A710 = (string)Ask;
   Ls_A700 = ", Ask: ";
   Ls_A6F0 = func_1032(Gi_0076);
   Ls_A6E0 = " - ";
   Ls_A6D0 = (string)Ii_1250;
   Ls_A6C0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_A6B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A6B0, " ", Ls_A6C0, Ls_A6D0, Ls_A6E0, Ls_A6F0, Ls_A700, Ls_A710, Ls_A720, Ls_A730, Ls_A740, Ls_A750, Ls_A760, Ls_A770);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0B5C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B5C > 0) {
   FileSeek(Ii_0B5C, 0, 2);
   Ls_A6A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B5C, Ls_A6A0, " VERBOSE: ", Ls_A6C0, Ls_A6D0, Ls_A6E0, Ls_A6F0, Ls_A700, Ls_A710, Ls_A720, Ls_A730, Ls_A740, Ls_A750, Ls_A760, Ls_A770);
   FileClose(Ii_0B5C);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_A690 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_A690 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_A670 = "";
   Ls_A660 = "";
   Ls_A650 = "";
   Ls_A640 = "";
   Ls_A630 = "";
   Ls_A620 = "";
   Ls_A610 = (string)Ld_8AA8;
   Ls_A600 = " to :";
   Ls_A5F0 = (string)Fa_i_00;
   Ls_A5E0 = ", Magic Number: ";
   Ls_A5D0 = (string)OrderTicket();
   Ls_A5C0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_A5B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A5B0, " ", Ls_A5C0, Ls_A5D0, Ls_A5E0, Ls_A5F0, Ls_A600, Ls_A610, Ls_A620, Ls_A630, Ls_A640, Ls_A650, Ls_A660, Ls_A670);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_06E8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_06E8 > 0) { 
   FileSeek(Ii_06E8, 0, 2);
   Ls_A5A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_06E8, Ls_A5A0, " VERBOSE: ", Ls_A5C0, Ls_A5D0, Ls_A5E0, Ls_A5F0, Ls_A600, Ls_A610, Ls_A620, Ls_A630, Ls_A640, Ls_A650, Ls_A660, Ls_A670);
   FileClose(Ii_06E8);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0078 = GetLastError();
   Ii_1264 = Gi_0078;
   Li_8A9C = Gi_0078;
   Ls_A590 = "";
   Ls_A580 = "";
   Ls_A570 = (string)OrderStopLoss();
   Ls_A560 = " Current SL: ";
   Ls_A550 = (string)Bid;
   Ls_A540 = ", Bid: ";
   Ls_A530 = (string)Ask;
   Ls_A520 = ", Ask: ";
   Ls_A510 = func_1032(Gi_0078);
   Ls_A500 = " - ";
   Ls_A4F0 = (string)Ii_1264;
   Ls_A4E0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_A4D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A4D0, " ", Ls_A4E0, Ls_A4F0, Ls_A500, Ls_A510, Ls_A520, Ls_A530, Ls_A540, Ls_A550, Ls_A560, Ls_A570, Ls_A580, Ls_A590);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_06EC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_06EC > 0) { 
   FileSeek(Ii_06EC, 0, 2);
   Ls_A4C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_06EC, Ls_A4C0, " VERBOSE: ", Ls_A4E0, Ls_A4F0, Ls_A500, Ls_A510, Ls_A520, Ls_A530, Ls_A540, Ls_A550, Ls_A560, Ls_A570, Ls_A580, Ls_A590);
   FileClose(Ii_06EC);
   }}}}}}}}} 
   Ii_0B60 = Ii_0094;
   Id_0B68 = 0;
   if (Ii_0094 == Ii_006C) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0070) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0074) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0078) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_007C) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0080) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0084) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0088) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_008C) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0090) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0094) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_0098) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_009C) { 
   Id_0B68 = 0;
   } 
   if (Ii_0B60 == Ii_00A0) { 
   Id_0B68 = 0;
   } 
   returned_double = NormalizeDouble(Id_0B68, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_06FC = (int)(returned_double + 10);
   Il_0B70 = OrderOpenTime();
   Ii_0708 = 0;
   Ii_0710 = 0;
   Ii_1264 = Ii_06FC + 10;
   if (Ii_1264 > 0) { 
   do { 
   if (Il_0B70 < Time[Ii_0710]) { 
   Ii_0708 = Ii_0708 + 1;
   } 
   Ii_0710 = Ii_0710 + 1;
   Ii_1270 = Ii_06FC + 10;
   } while (Ii_0710 < Ii_1270); 
   } 
   if ((Ii_0708 >= Ld_8AB8)) { 
   Ls_A4B0 = "";
   Ls_A4A0 = "";
   Ls_A490 = "";
   Ls_A480 = "";
   Ls_A470 = "";
   Ls_A460 = "";
   Ls_A450 = (string)Fa_i_00;
   Ls_A440 = ", Magic Number: ";
   Ls_A430 = (string)OrderTicket();
   Ls_A420 = "bars - closing order with ticket: ";
   Ls_A410 = (string)Ld_8AB8;
   Ls_A400 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_A3F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A3F0, " ", Ls_A400, Ls_A410, Ls_A420, Ls_A430, Ls_A440, Ls_A450, Ls_A460, Ls_A470, Ls_A480, Ls_A490, Ls_A4A0, Ls_A4B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0728 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0728 > 0) { 
   FileSeek(Ii_0728, 0, 2);
   Ls_A3E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0728, Ls_A3E0, " VERBOSE: ", Ls_A400, Ls_A410, Ls_A420, Ls_A430, Ls_A440, Ls_A450, Ls_A460, Ls_A470, Ls_A480, Ls_A490, Ls_A4A0, Ls_A4B0);
   FileClose(Ii_0728);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_0098) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_0098, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0738 = Ii_0098;
   Id_0B78 = 0;
   if (Ii_0098 == Ii_006C) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0070) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0074) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0078) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_007C) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0080) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0084) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0088) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_008C) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0090) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0094) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_0098) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_009C) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   if (Ii_0738 == Ii_00A0) { 
   Id_0B78 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0B78, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_A3D0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_A3D0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_A3B0 = "";
   Ls_A3A0 = "";
   Ls_A390 = "";
   Ls_A380 = "";
   Ls_A370 = "";
   Ls_A360 = "";
   Ls_A350 = (string)Ld_8AA8;
   Ls_A340 = " to :";
   Ls_A330 = (string)Fa_i_00;
   Ls_A320 = ", Magic Number: ";
   Ls_A310 = (string)OrderTicket();
   Ls_A300 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_A2F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A2F0, " ", Ls_A300, Ls_A310, Ls_A320, Ls_A330, Ls_A340, Ls_A350, Ls_A360, Ls_A370, Ls_A380, Ls_A390, Ls_A3A0, Ls_A3B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_075C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_075C > 0) { 
   FileSeek(Ii_075C, 0, 2);
   Ls_A2E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_075C, Ls_A2E0, " VERBOSE: ", Ls_A300, Ls_A310, Ls_A320, Ls_A330, Ls_A340, Ls_A350, Ls_A360, Ls_A370, Ls_A380, Ls_A390, Ls_A3A0, Ls_A3B0);
   FileClose(Ii_075C);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_007C = GetLastError();
   Ii_12A8 = Gi_007C;
   Li_8A9C = Gi_007C;
   Ls_A2D0 = "";
   Ls_A2C0 = "";
   Ls_A2B0 = "";
   Ls_A2A0 = "";
   Ls_A290 = "";
   Ls_A280 = "";
   Ls_A270 = "";
   Ls_A260 = "";
   Ls_A250 = func_1032(Gi_007C);
   Ls_A240 = " - ";
   Ls_A230 = (string)Ii_12A8;
   Ls_A220 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_A210 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A210, " ", Ls_A220, Ls_A230, Ls_A240, Ls_A250, Ls_A260, Ls_A270, Ls_A280, Ls_A290, Ls_A2A0, Ls_A2B0, Ls_A2C0, Ls_A2D0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0770 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0770 > 0) {
   FileSeek(Ii_0770, 0, 2);
   Ls_A200 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0770, Ls_A200, " VERBOSE: ", Ls_A220, Ls_A230, Ls_A240, Ls_A250, Ls_A260, Ls_A270, Ls_A280, Ls_A290, Ls_A2A0, Ls_A2B0, Ls_A2C0, Ls_A2D0);
   FileClose(Ii_0770);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_A1F0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_A1F0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_A1D0 = "";
   Ls_A1C0 = "";
   Ls_A1B0 = "";
   Ls_A1A0 = "";
   Ls_A190 = "";
   Ls_A180 = "";
   Ls_A170 = (string)Ld_8AA8;
   Ls_A160 = " to :";
   Ls_A150 = (string)Fa_i_00;
   Ls_A140 = ", Magic Number: ";
   Ls_A130 = (string)OrderTicket();
   Ls_A120 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_A110 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A110, " ", Ls_A120, Ls_A130, Ls_A140, Ls_A150, Ls_A160, Ls_A170, Ls_A180, Ls_A190, Ls_A1A0, Ls_A1B0, Ls_A1C0, Ls_A1D0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0790 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0790 > 0) { 
   FileSeek(Ii_0790, 0, 2);
   Ls_A100 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0790, Ls_A100, " VERBOSE: ", Ls_A120, Ls_A130, Ls_A140, Ls_A150, Ls_A160, Ls_A170, Ls_A180, Ls_A190, Ls_A1A0, Ls_A1B0, Ls_A1C0, Ls_A1D0);
   FileClose(Ii_0790);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_007E = GetLastError();
   Ii_14E0 = Gi_007E;
   Li_8A9C = Gi_007E;
   Ls_A0F0 = "";
   Ls_A0E0 = "";
   Ls_A0D0 = (string)OrderStopLoss();
   Ls_A0C0 = " Current SL: ";
   Ls_A0B0 = (string)Bid;
   Ls_A0A0 = ", Bid: ";
   Ls_A090 = (string)Ask;
   Ls_A080 = ", Ask: ";
   Ls_A070 = func_1032(Gi_007E);
   Ls_A060 = " - ";
   Ls_A050 = (string)Ii_14E0;
   Ls_A040 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_A030 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_A030, " ", Ls_A040, Ls_A050, Ls_A060, Ls_A070, Ls_A080, Ls_A090, Ls_A0A0, Ls_A0B0, Ls_A0C0, Ls_A0D0, Ls_A0E0, Ls_A0F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_08D0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_08D0 > 0) { 
   FileSeek(Ii_08D0, 0, 2);
   Ls_A020 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_08D0, Ls_A020, " VERBOSE: ", Ls_A040, Ls_A050, Ls_A060, Ls_A070, Ls_A080, Ls_A090, Ls_A0A0, Ls_A0B0, Ls_A0C0, Ls_A0D0, Ls_A0E0, Ls_A0F0);
   FileClose(Ii_08D0);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_0098, OrderType(), OrderOpenPrice());
   Ii_07C8 = Ii_0098;
   Id_07E0 = 0;
   if (Ii_0098 == Ii_006C) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0070) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0074) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0078) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_007C) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0080) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0084) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0088) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_008C) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0090) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0094) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_0098) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_009C) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   if (Ii_07C8 == Ii_00A0) { 
   Id_07E0 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_07E0, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_A010 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_A010 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_9FF0 = "";
   Ls_9FE0 = "";
   Ls_9FD0 = "";
   Ls_9FC0 = "";
   Ls_9FB0 = "";
   Ls_9FA0 = "";
   Ls_9F90 = (string)Ld_8AA8;
   Ls_9F80 = " to :";
   Ls_9F70 = (string)Fa_i_00;
   Ls_9F60 = ", Magic Number: ";
   Ls_9F50 = (string)OrderTicket();
   Ls_9F40 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_9F30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9F30, " ", Ls_9F40, Ls_9F50, Ls_9F60, Ls_9F70, Ls_9F80, Ls_9F90, Ls_9FA0, Ls_9FB0, Ls_9FC0, Ls_9FD0, Ls_9FE0, Ls_9FF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_07F4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_07F4 > 0) { 
   FileSeek(Ii_07F4, 0, 2);
   Ls_9F20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_07F4, Ls_9F20, " VERBOSE: ", Ls_9F40, Ls_9F50, Ls_9F60, Ls_9F70, Ls_9F80, Ls_9F90, Ls_9FA0, Ls_9FB0, Ls_9FC0, Ls_9FD0, Ls_9FE0, Ls_9FF0);
   FileClose(Ii_07F4);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0081 = GetLastError();
   Ii_12E0 = Gi_0081;
   Li_8A9C = Gi_0081;
   Ls_9F10 = "";
   Ls_9F00 = "";
   Ls_9EF0 = (string)OrderStopLoss();
   Ls_9EE0 = " Current SL: ";
   Ls_9ED0 = (string)Bid;
   Ls_9EC0 = ", Bid: ";
   Ls_9EB0 = (string)Ask;
   Ls_9EA0 = ", Ask: ";
   Ls_9E90 = func_1032(Gi_0081);
   Ls_9E80 = " - ";
   Ls_9E70 = (string)Ii_12E0;
   Ls_9E60 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_9E50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9E50, " ", Ls_9E60, Ls_9E70, Ls_9E80, Ls_9E90, Ls_9EA0, Ls_9EB0, Ls_9EC0, Ls_9ED0, Ls_9EE0, Ls_9EF0, Ls_9F00, Ls_9F10);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0810 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0810 > 0) {
   FileSeek(Ii_0810, 0, 2);
   Ls_9E40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0810, Ls_9E40, " VERBOSE: ", Ls_9E60, Ls_9E70, Ls_9E80, Ls_9E90, Ls_9EA0, Ls_9EB0, Ls_9EC0, Ls_9ED0, Ls_9EE0, Ls_9EF0, Ls_9F00, Ls_9F10);
   FileClose(Ii_0810);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_9E30 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_9E30 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_9E10 = "";
   Ls_9E00 = "";
   Ls_9DF0 = "";
   Ls_9DE0 = "";
   Ls_9DD0 = "";
   Ls_9DC0 = "";
   Ls_9DB0 = (string)Ld_8AA8;
   Ls_9DA0 = " to :";
   Ls_9D90 = (string)Fa_i_00;
   Ls_9D80 = ", Magic Number: ";
   Ls_9D70 = (string)OrderTicket();
   Ls_9D60 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_9D50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9D50, " ", Ls_9D60, Ls_9D70, Ls_9D80, Ls_9D90, Ls_9DA0, Ls_9DB0, Ls_9DC0, Ls_9DD0, Ls_9DE0, Ls_9DF0, Ls_9E00, Ls_9E10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_08C4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_08C4 > 0) { 
   FileSeek(Ii_08C4, 0, 2);
   Ls_9D40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_08C4, Ls_9D40, " VERBOSE: ", Ls_9D60, Ls_9D70, Ls_9D80, Ls_9D90, Ls_9DA0, Ls_9DB0, Ls_9DC0, Ls_9DD0, Ls_9DE0, Ls_9DF0, Ls_9E00, Ls_9E10);
   FileClose(Ii_08C4);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0083 = GetLastError();
   Ii_12F4 = Gi_0083;
   Li_8A9C = Gi_0083;
   Ls_9D30 = "";
   Ls_9D20 = "";
   Ls_9D10 = (string)OrderStopLoss();
   Ls_9D00 = " Current SL: ";
   Ls_9CF0 = (string)Bid;
   Ls_9CE0 = ", Bid: ";
   Ls_9CD0 = (string)Ask;
   Ls_9CC0 = ", Ask: ";
   Ls_9CB0 = func_1032(Gi_0083);
   Ls_9CA0 = " - ";
   Ls_9C90 = (string)Ii_12F4;
   Ls_9C80 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_9C70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9C70, " ", Ls_9C80, Ls_9C90, Ls_9CA0, Ls_9CB0, Ls_9CC0, Ls_9CD0, Ls_9CE0, Ls_9CF0, Ls_9D00, Ls_9D10, Ls_9D20, Ls_9D30);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0820 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0820 > 0) { 
   FileSeek(Ii_0820, 0, 2);
   Ls_9C60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0820, Ls_9C60, " VERBOSE: ", Ls_9C80, Ls_9C90, Ls_9CA0, Ls_9CB0, Ls_9CC0, Ls_9CD0, Ls_9CE0, Ls_9CF0, Ls_9D00, Ls_9D10, Ls_9D20, Ls_9D30);
   FileClose(Ii_0820);
   }}}}}}}}} 
   Ii_0838 = Ii_0098;
   Id_0840 = 0;
   if (Ii_0098 == Ii_006C) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0070) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0074) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0078) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_007C) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0080) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0084) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0088) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_008C) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0090) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0094) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_0098) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_009C) { 
   Id_0840 = 0;
   } 
   if (Ii_0838 == Ii_00A0) { 
   Id_0840 = 0;
   } 
   returned_double = NormalizeDouble(Id_0840, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_085C = (int)(returned_double + 10);
   Il_0B80 = OrderOpenTime();
   Ii_0870 = 0;
   Ii_0880 = 0;
   Ii_12F4 = Ii_085C + 10;
   if (Ii_12F4 > 0) { 
   do { 
   if (Il_0B80 < Time[Ii_0880]) { 
   Ii_0870 = Ii_0870 + 1;
   } 
   Ii_0880 = Ii_0880 + 1;
   Ii_1300 = Ii_085C + 10;
   } while (Ii_0880 < Ii_1300); 
   } 
   if ((Ii_0870 >= Ld_8AB8)) { 
   Ls_9C50 = "";
   Ls_9C40 = "";
   Ls_9C30 = "";
   Ls_9C20 = "";
   Ls_9C10 = "";
   Ls_9C00 = "";
   Ls_9BF0 = (string)Fa_i_00;
   Ls_9BE0 = ", Magic Number: ";
   Ls_9BD0 = (string)OrderTicket();
   Ls_9BC0 = "bars - closing order with ticket: ";
   Ls_9BB0 = (string)Ld_8AB8;
   Ls_9BA0 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_9B90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9B90, " ", Ls_9BA0, Ls_9BB0, Ls_9BC0, Ls_9BD0, Ls_9BE0, Ls_9BF0, Ls_9C00, Ls_9C10, Ls_9C20, Ls_9C30, Ls_9C40, Ls_9C50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0894 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0894 > 0) { 
   FileSeek(Ii_0894, 0, 2);
   Ls_9B80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0894, Ls_9B80, " VERBOSE: ", Ls_9BA0, Ls_9BB0, Ls_9BC0, Ls_9BD0, Ls_9BE0, Ls_9BF0, Ls_9C00, Ls_9C10, Ls_9C20, Ls_9C30, Ls_9C40, Ls_9C50);
   FileClose(Ii_0894);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 == Ii_009C) { 
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   Ld_8AB8 = func_1019(Ii_009C, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_08A0 = Ii_009C;
   Id_08B8 = 0;
   if (Ii_009C == Ii_006C) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0070) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0074) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0078) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_007C) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0080) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0084) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0088) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_008C) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0090) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0094) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_0098) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_009C) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   if (Ii_08A0 == Ii_00A0) { 
   Id_08B8 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_08B8, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_9B70 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_9B70 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_9B50 = "";
   Ls_9B40 = "";
   Ls_9B30 = "";
   Ls_9B20 = "";
   Ls_9B10 = "";
   Ls_9B00 = "";
   Ls_9AF0 = (string)Ld_8AA8;
   Ls_9AE0 = " to :";
   Ls_9AD0 = (string)Fa_i_00;
   Ls_9AC0 = ", Magic Number: ";
   Ls_9AB0 = (string)OrderTicket();
   Ls_9AA0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_9A90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9A90, " ", Ls_9AA0, Ls_9AB0, Ls_9AC0, Ls_9AD0, Ls_9AE0, Ls_9AF0, Ls_9B00, Ls_9B10, Ls_9B20, Ls_9B30, Ls_9B40, Ls_9B50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B88 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B88 > 0) { 
   FileSeek(Ii_0B88, 0, 2);
   Ls_9A80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B88, Ls_9A80, " VERBOSE: ", Ls_9AA0, Ls_9AB0, Ls_9AC0, Ls_9AD0, Ls_9AE0, Ls_9AF0, Ls_9B00, Ls_9B10, Ls_9B20, Ls_9B30, Ls_9B40, Ls_9B50);
   FileClose(Ii_0B88);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0087 = GetLastError();
   Ii_1338 = Gi_0087;
   Li_8A9C = Gi_0087;
   Ls_9A70 = "";
   Ls_9A60 = "";
   Ls_9A50 = "";
   Ls_9A40 = "";
   Ls_9A30 = "";
   Ls_9A20 = "";
   Ls_9A10 = "";
   Ls_9A00 = "";
   Ls_99F0 = func_1032(Gi_0087);
   Ls_99E0 = " - ";
   Ls_99D0 = (string)Ii_1338;
   Ls_99C0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_99B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_99B0, " ", Ls_99C0, Ls_99D0, Ls_99E0, Ls_99F0, Ls_9A00, Ls_9A10, Ls_9A20, Ls_9A30, Ls_9A40, Ls_9A50, Ls_9A60, Ls_9A70);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0B8C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B8C > 0) {
   FileSeek(Ii_0B8C, 0, 2);
   Ls_99A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B8C, Ls_99A0, " VERBOSE: ", Ls_99C0, Ls_99D0, Ls_99E0, Ls_99F0, Ls_9A00, Ls_9A10, Ls_9A20, Ls_9A30, Ls_9A40, Ls_9A50, Ls_9A60, Ls_9A70);
   FileClose(Ii_0B8C);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_9990 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_9990 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_9970 = "";
   Ls_9960 = "";
   Ls_9950 = "";
   Ls_9940 = "";
   Ls_9930 = "";
   Ls_9920 = "";
   Ls_9910 = (string)Ld_8AA8;
   Ls_9900 = " to :";
   Ls_98F0 = (string)Fa_i_00;
   Ls_98E0 = ", Magic Number: ";
   Ls_98D0 = (string)OrderTicket();
   Ls_98C0 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_98B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_98B0, " ", Ls_98C0, Ls_98D0, Ls_98E0, Ls_98F0, Ls_9900, Ls_9910, Ls_9920, Ls_9930, Ls_9940, Ls_9950, Ls_9960, Ls_9970);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B90 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B90 > 0) { 
   FileSeek(Ii_0B90, 0, 2);
   Ls_98A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B90, Ls_98A0, " VERBOSE: ", Ls_98C0, Ls_98D0, Ls_98E0, Ls_98F0, Ls_9900, Ls_9910, Ls_9920, Ls_9930, Ls_9940, Ls_9950, Ls_9960, Ls_9970);
   FileClose(Ii_0B90);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0089 = GetLastError();
   Ii_14A0 = Gi_0089;
   Li_8A9C = Gi_0089;
   Ls_9890 = "";
   Ls_9880 = "";
   Ls_9870 = (string)OrderStopLoss();
   Ls_9860 = " Current SL: ";
   Ls_9850 = (string)Bid;
   Ls_9840 = ", Bid: ";
   Ls_9830 = (string)Ask;
   Ls_9820 = ", Ask: ";
   Ls_9810 = func_1032(Gi_0089);
   Ls_9800 = " - ";
   Ls_97F0 = (string)Ii_14A0;
   Ls_97E0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_97D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_97D0, " ", Ls_97E0, Ls_97F0, Ls_9800, Ls_9810, Ls_9820, Ls_9830, Ls_9840, Ls_9850, Ls_9860, Ls_9870, Ls_9880, Ls_9890);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0B94 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0B94 > 0) { 
   FileSeek(Ii_0B94, 0, 2);
   Ls_97C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0B94, Ls_97C0, " VERBOSE: ", Ls_97E0, Ls_97F0, Ls_9800, Ls_9810, Ls_9820, Ls_9830, Ls_9840, Ls_9850, Ls_9860, Ls_9870, Ls_9880, Ls_9890);
   FileClose(Ii_0B94);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_009C, OrderType(), OrderOpenPrice());
   Ii_0B98 = Ii_009C;
   Id_0BA0 = 0;
   if (Ii_009C == Ii_006C) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0070) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0074) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0078) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_007C) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0080) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0084) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0088) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_008C) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0090) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0094) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_0098) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_009C) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   if (Ii_0B98 == Ii_00A0) { 
   Id_0BA0 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0BA0, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_97B0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_97B0 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_9790 = "";
   Ls_9780 = "";
   Ls_9770 = "";
   Ls_9760 = "";
   Ls_9750 = "";
   Ls_9740 = "";
   Ls_9730 = (string)Ld_8AA8;
   Ls_9720 = " to :";
   Ls_9710 = (string)Fa_i_00;
   Ls_9700 = ", Magic Number: ";
   Ls_96F0 = (string)OrderTicket();
   Ls_96E0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_96D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_96D0, " ", Ls_96E0, Ls_96F0, Ls_9700, Ls_9710, Ls_9720, Ls_9730, Ls_9740, Ls_9750, Ls_9760, Ls_9770, Ls_9780, Ls_9790);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0BA8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BA8 > 0) { 
   FileSeek(Ii_0BA8, 0, 2);
   Ls_96C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BA8, Ls_96C0, " VERBOSE: ", Ls_96E0, Ls_96F0, Ls_9700, Ls_9710, Ls_9720, Ls_9730, Ls_9740, Ls_9750, Ls_9760, Ls_9770, Ls_9780, Ls_9790);
   FileClose(Ii_0BA8);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_008C = GetLastError();
   Ii_1370 = Gi_008C;
   Li_8A9C = Gi_008C;
   Ls_96B0 = "";
   Ls_96A0 = "";
   Ls_9690 = (string)OrderStopLoss();
   Ls_9680 = " Current SL: ";
   Ls_9670 = (string)Bid;
   Ls_9660 = ", Bid: ";
   Ls_9650 = (string)Ask;
   Ls_9640 = ", Ask: ";
   Ls_9630 = func_1032(Gi_008C);
   Ls_9620 = " - ";
   Ls_9610 = (string)Ii_1370;
   Ls_9600 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_95F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_95F0, " ", Ls_9600, Ls_9610, Ls_9620, Ls_9630, Ls_9640, Ls_9650, Ls_9660, Ls_9670, Ls_9680, Ls_9690, Ls_96A0, Ls_96B0);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0BAC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BAC > 0) {
   FileSeek(Ii_0BAC, 0, 2);
   Ls_95E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BAC, Ls_95E0, " VERBOSE: ", Ls_9600, Ls_9610, Ls_9620, Ls_9630, Ls_9640, Ls_9650, Ls_9660, Ls_9670, Ls_9680, Ls_9690, Ls_96A0, Ls_96B0);
   FileClose(Ii_0BAC);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_95D0 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_95D0 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_95B0 = "";
   Ls_95A0 = "";
   Ls_9590 = "";
   Ls_9580 = "";
   Ls_9570 = "";
   Ls_9560 = "";
   Ls_9550 = (string)Ld_8AA8;
   Ls_9540 = " to :";
   Ls_9530 = (string)Fa_i_00;
   Ls_9520 = ", Magic Number: ";
   Ls_9510 = (string)OrderTicket();
   Ls_9500 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_94F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_94F0, " ", Ls_9500, Ls_9510, Ls_9520, Ls_9530, Ls_9540, Ls_9550, Ls_9560, Ls_9570, Ls_9580, Ls_9590, Ls_95A0, Ls_95B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0BB0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BB0 > 0) { 
   FileSeek(Ii_0BB0, 0, 2);
   Ls_94E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BB0, Ls_94E0, " VERBOSE: ", Ls_9500, Ls_9510, Ls_9520, Ls_9530, Ls_9540, Ls_9550, Ls_9560, Ls_9570, Ls_9580, Ls_9590, Ls_95A0, Ls_95B0);
   FileClose(Ii_0BB0);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_008E = GetLastError();
   Ii_1384 = Gi_008E;
   Li_8A9C = Gi_008E;
   Ls_94D0 = "";
   Ls_94C0 = "";
   Ls_94B0 = (string)OrderStopLoss();
   Ls_94A0 = " Current SL: ";
   Ls_9490 = (string)Bid;
   Ls_9480 = ", Bid: ";
   Ls_9470 = (string)Ask;
   Ls_9460 = ", Ask: ";
   Ls_9450 = func_1032(Gi_008E);
   Ls_9440 = " - ";
   Ls_9430 = (string)Ii_1384;
   Ls_9420 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_9410 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9410, " ", Ls_9420, Ls_9430, Ls_9440, Ls_9450, Ls_9460, Ls_9470, Ls_9480, Ls_9490, Ls_94A0, Ls_94B0, Ls_94C0, Ls_94D0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0BB4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BB4 > 0) { 
   FileSeek(Ii_0BB4, 0, 2);
   Ls_9400 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BB4, Ls_9400, " VERBOSE: ", Ls_9420, Ls_9430, Ls_9440, Ls_9450, Ls_9460, Ls_9470, Ls_9480, Ls_9490, Ls_94A0, Ls_94B0, Ls_94C0, Ls_94D0);
   FileClose(Ii_0BB4);
   }}}}}}}}} 
   Ii_0BB8 = Ii_009C;
   Id_0BC0 = 0;
   if (Ii_009C == Ii_006C) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0070) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0074) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0078) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_007C) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0080) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0084) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0088) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_008C) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0090) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0094) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_0098) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_009C) { 
   Id_0BC0 = 0;
   } 
   if (Ii_0BB8 == Ii_00A0) { 
   Id_0BC0 = 0;
   } 
   returned_double = NormalizeDouble(Id_0BC0, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double > 0)) { 
   Ii_0BC8 = (int)(returned_double + 10);
   Il_0BD0 = OrderOpenTime();
   Ii_0BD8 = 0;
   Ii_0BDC = 0;
   Ii_1384 = Ii_0BC8 + 10;
   if (Ii_1384 > 0) { 
   do { 
   if (Il_0BD0 < Time[Ii_0BDC]) { 
   Ii_0BD8 = Ii_0BD8 + 1;
   } 
   Ii_0BDC = Ii_0BDC + 1;
   Ii_1390 = Ii_0BC8 + 10;
   } while (Ii_0BDC < Ii_1390); 
   } 
   if ((Ii_0BD8 >= Ld_8AB8)) { 
   Ls_93F0 = "";
   Ls_93E0 = "";
   Ls_93D0 = "";
   Ls_93C0 = "";
   Ls_93B0 = "";
   Ls_93A0 = "";
   Ls_9390 = (string)Fa_i_00;
   Ls_9380 = ", Magic Number: ";
   Ls_9370 = (string)OrderTicket();
   Ls_9360 = "bars - closing order with ticket: ";
   Ls_9350 = (string)Ld_8AB8;
   Ls_9340 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_9330 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9330, " ", Ls_9340, Ls_9350, Ls_9360, Ls_9370, Ls_9380, Ls_9390, Ls_93A0, Ls_93B0, Ls_93C0, Ls_93D0, Ls_93E0, Ls_93F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0BE0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BE0 > 0) { 
   FileSeek(Ii_0BE0, 0, 2);
   Ls_9320 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BE0, Ls_9320, " VERBOSE: ", Ls_9340, Ls_9350, Ls_9360, Ls_9370, Ls_9380, Ls_9390, Ls_93A0, Ls_93B0, Ls_93C0, Ls_93D0, Ls_93E0, Ls_93F0);
   FileClose(Ii_0BE0);
   }}} 
   func_1022(-1);
   }}}} 
   if (Fa_i_00 != Ii_00A0) { 
   return ;
   } 
   if (OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   return ;
   } 
   Ld_8AB8 = func_1019(Ii_00A0, OrderType(), OrderOpenPrice());
   if ((Ld_8AB8 > 0)) { 
   Ii_0BE4 = Ii_00A0;
   Id_0BE8 = 0;
   if (Ii_00A0 == Ii_006C) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0070) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0074) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0078) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_007C) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0080) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0084) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0088) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_008C) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0090) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0094) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_0098) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_009C) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   if (Ii_0BE4 == Ii_00A0) { 
   Id_0BE8 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0BE8, _Digits);
   if (OrderType() == OP_BUY) {
   Ld_8AA0 = (Bid - OrderOpenPrice());
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AB8)) {
   
   Ls_9310 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_9310 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_92F0 = "";
   Ls_92E0 = "";
   Ls_92D0 = "";
   Ls_92C0 = "";
   Ls_92B0 = "";
   Ls_92A0 = "";
   Ls_9290 = (string)Ld_8AA8;
   Ls_9280 = " to :";
   Ls_9270 = (string)Fa_i_00;
   Ls_9260 = ", Magic Number: ";
   Ls_9250 = (string)OrderTicket();
   Ls_9240 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_9230 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9230, " ", Ls_9240, Ls_9250, Ls_9260, Ls_9270, Ls_9280, Ls_9290, Ls_92A0, Ls_92B0, Ls_92C0, Ls_92D0, Ls_92E0, Ls_92F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0BF0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BF0 > 0) { 
   FileSeek(Ii_0BF0, 0, 2);
   Ls_9220 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BF0, Ls_9220, " VERBOSE: ", Ls_9240, Ls_9250, Ls_9260, Ls_9270, Ls_9280, Ls_9290, Ls_92A0, Ls_92B0, Ls_92C0, Ls_92D0, Ls_92E0, Ls_92F0);
   FileClose(Ii_0BF0);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0092 = GetLastError();
   Ii_13C8 = Gi_0092;
   Li_8A9C = Gi_0092;
   Ls_9210 = "";
   Ls_9200 = "";
   Ls_91F0 = "";
   Ls_91E0 = "";
   Ls_91D0 = "";
   Ls_91C0 = "";
   Ls_91B0 = "";
   Ls_91A0 = "";
   Ls_9190 = func_1032(Gi_0092);
   Ls_9180 = " - ";
   Ls_9170 = (string)Ii_13C8;
   Ls_9160 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_9150 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9150, " ", Ls_9160, Ls_9170, Ls_9180, Ls_9190, Ls_91A0, Ls_91B0, Ls_91C0, Ls_91D0, Ls_91E0, Ls_91F0, Ls_9200, Ls_9210);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0BF4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BF4 > 0) {
   FileSeek(Ii_0BF4, 0, 2);
   Ls_9140 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BF4, Ls_9140, " VERBOSE: ", Ls_9160, Ls_9170, Ls_9180, Ls_9190, Ls_91A0, Ls_91B0, Ls_91C0, Ls_91D0, Ls_91E0, Ls_91F0, Ls_9200, Ls_9210);
   FileClose(Ii_0BF4);
   }}}}}}}}
   else{
   Ld_8AA0 = (OrderOpenPrice() - Ask);
   Ld_8AA8 = Ld_8AB8;
   if ((Ld_8AA0 >= Ld_8AB0)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AB8)) { 
   
   Ls_9130 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_9130 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_9110 = "";
   Ls_9100 = "";
   Ls_90F0 = "";
   Ls_90E0 = "";
   Ls_90D0 = "";
   Ls_90C0 = "";
   Ls_90B0 = (string)Ld_8AA8;
   Ls_90A0 = " to :";
   Ls_9090 = (string)Fa_i_00;
   Ls_9080 = ", Magic Number: ";
   Ls_9070 = (string)OrderTicket();
   Ls_9060 = "Moving trailing stop for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_9050 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_9050, " ", Ls_9060, Ls_9070, Ls_9080, Ls_9090, Ls_90A0, Ls_90B0, Ls_90C0, Ls_90D0, Ls_90E0, Ls_90F0, Ls_9100, Ls_9110);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0BF8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BF8 > 0) { 
   FileSeek(Ii_0BF8, 0, 2);
   Ls_9040 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BF8, Ls_9040, " VERBOSE: ", Ls_9060, Ls_9070, Ls_9080, Ls_9090, Ls_90A0, Ls_90B0, Ls_90C0, Ls_90D0, Ls_90E0, Ls_90F0, Ls_9100, Ls_9110);
   FileClose(Ii_0BF8);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0094 = GetLastError();
   Ii_1460 = Gi_0094;
   Li_8A9C = Gi_0094;
   Ls_9030 = "";
   Ls_9020 = "";
   Ls_9010 = (string)OrderStopLoss();
   Ls_9000 = " Current SL: ";
   Ls_8FF0 = (string)Bid;
   Ls_8FE0 = ", Bid: ";
   Ls_8FD0 = (string)Ask;
   Ls_8FC0 = ", Ask: ";
   Ls_8FB0 = func_1032(Gi_0094);
   Ls_8FA0 = " - ";
   Ls_8F90 = (string)Ii_1460;
   Ls_8F80 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_8F70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_8F70, " ", Ls_8F80, Ls_8F90, Ls_8FA0, Ls_8FB0, Ls_8FC0, Ls_8FD0, Ls_8FE0, Ls_8FF0, Ls_9000, Ls_9010, Ls_9020, Ls_9030);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0BFC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0BFC > 0) { 
   FileSeek(Ii_0BFC, 0, 2);
   Ls_8F60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0BFC, Ls_8F60, " VERBOSE: ", Ls_8F80, Ls_8F90, Ls_8FA0, Ls_8FB0, Ls_8FC0, Ls_8FD0, Ls_8FE0, Ls_8FF0, Ls_9000, Ls_9010, Ls_9020, Ls_9030);
   FileClose(Ii_0BFC);
   }}}}}}}}} 
   Ld_8AB8 = func_1020(Ii_00A0, OrderType(), OrderOpenPrice());
   Ii_0C00 = Ii_00A0;
   Id_0C08 = 0;
   if (Ii_00A0 == Ii_006C) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0070) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0074) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0078) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_007C) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0080) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0084) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0088) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_008C) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0090) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0094) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_0098) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_009C) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   if (Ii_0C00 == Ii_00A0) { 
   Id_0C08 = (Id_00D0 * 0);
   } 
   Ld_8AB0 = NormalizeDouble(Id_0C08, _Digits);
   if ((Ld_8AB8 > 0)) { 
   if (OrderType() == OP_BUY) {
   Ld_8AA8 = (OrderOpenPrice() + Ld_8AB0);
   if ((OrderOpenPrice() <= Ld_8AB8)) {
   if ((OrderStopLoss() == 0) || (OrderStopLoss() < Ld_8AA8)) {
   
   Ls_8F50 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_8F50 != DoubleToString(Ld_8AA8, _Digits)) {
   Ls_8F30 = "";
   Ls_8F20 = "";
   Ls_8F10 = "";
   Ls_8F00 = "";
   Ls_8EF0 = "";
   Ls_8EE0 = "";
   Ls_8ED0 = (string)Ld_8AA8;
   Ls_8EC0 = " to :";
   Ls_8EB0 = (string)Fa_i_00;
   Ls_8EA0 = ", Magic Number: ";
   Ls_8E90 = (string)OrderTicket();
   Ls_8E80 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_8E70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_8E70, " ", Ls_8E80, Ls_8E90, Ls_8EA0, Ls_8EB0, Ls_8EC0, Ls_8ED0, Ls_8EE0, Ls_8EF0, Ls_8F00, Ls_8F10, Ls_8F20, Ls_8F30);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0C10 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0C10 > 0) { 
   FileSeek(Ii_0C10, 0, 2);
   Ls_8E60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0C10, Ls_8E60, " VERBOSE: ", Ls_8E80, Ls_8E90, Ls_8EA0, Ls_8EB0, Ls_8EC0, Ls_8ED0, Ls_8EE0, Ls_8EF0, Ls_8F00, Ls_8F10, Ls_8F20, Ls_8F30);
   FileClose(Ii_0C10);
   }}} 
   if (!OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295)) {
   Gi_0097 = GetLastError();
   Ii_1400 = Gi_0097;
   Li_8A9C = Gi_0097;
   Ls_8E50 = "";
   Ls_8E40 = "";
   Ls_8E30 = (string)OrderStopLoss();
   Ls_8E20 = " Current SL: ";
   Ls_8E10 = (string)Bid;
   Ls_8E00 = ", Bid: ";
   Ls_8DF0 = (string)Ask;
   Ls_8DE0 = ", Ask: ";
   Ls_8DD0 = func_1032(Gi_0097);
   Ls_8DC0 = " - ";
   Ls_8DB0 = (string)Ii_1400;
   Ls_8DA0 = "Failed, error: ";
   if (Ii_08EC == 1) {
   Ls_8D90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_8D90, " ", Ls_8DA0, Ls_8DB0, Ls_8DC0, Ls_8DD0, Ls_8DE0, Ls_8DF0, Ls_8E00, Ls_8E10, Ls_8E20, Ls_8E30, Ls_8E40, Ls_8E50);
   }
   else{
   if (Ii_08EC == 2) {
   Ii_0C14 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0C14 > 0) {
   FileSeek(Ii_0C14, 0, 2);
   Ls_8D80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0C14, Ls_8D80, " VERBOSE: ", Ls_8DA0, Ls_8DB0, Ls_8DC0, Ls_8DD0, Ls_8DE0, Ls_8DF0, Ls_8E00, Ls_8E10, Ls_8E20, Ls_8E30, Ls_8E40, Ls_8E50);
   FileClose(Ii_0C14);
   }}}}}}}}
   else{
   Ld_8AA8 = (OrderOpenPrice() - Ld_8AB0);
   if ((OrderOpenPrice() >= Ld_8AB8)) { 
   if ((OrderStopLoss() == 0) || (OrderStopLoss() > Ld_8AA8)) { 
   
   Ls_8D70 = DoubleToString(OrderStopLoss(), _Digits);
   if (Ls_8D70 != DoubleToString(Ld_8AA8, _Digits)) { 
   Ls_8D50 = "";
   Ls_8D40 = "";
   Ls_8D30 = "";
   Ls_8D20 = "";
   Ls_8D10 = "";
   Ls_8D00 = "";
   Ls_8CF0 = (string)Ld_8AA8;
   Ls_8CE0 = " to :";
   Ls_8CD0 = (string)Fa_i_00;
   Ls_8CC0 = ", Magic Number: ";
   Ls_8CB0 = (string)OrderTicket();
   Ls_8CA0 = "Moving SL 2 BE for order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_8C90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_8C90, " ", Ls_8CA0, Ls_8CB0, Ls_8CC0, Ls_8CD0, Ls_8CE0, Ls_8CF0, Ls_8D00, Ls_8D10, Ls_8D20, Ls_8D30, Ls_8D40, Ls_8D50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0C18 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0C18 > 0) { 
   FileSeek(Ii_0C18, 0, 2);
   Ls_8C80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0C18, Ls_8C80, " VERBOSE: ", Ls_8CA0, Ls_8CB0, Ls_8CC0, Ls_8CD0, Ls_8CE0, Ls_8CF0, Ls_8D00, Ls_8D10, Ls_8D20, Ls_8D30, Ls_8D40, Ls_8D50);
   FileClose(Ii_0C18);
   }}} 
   if (OrderModify(OrderTicket(), OrderOpenPrice(), Ld_8AA8, OrderTakeProfit(), 0, 4294967295) != true) { 
   Gi_0099 = GetLastError();
   Ii_1414 = Gi_0099;
   Li_8A9C = Gi_0099;
   Ls_8C70 = "";
   Ls_8C60 = "";
   Ls_8C50 = (string)OrderStopLoss();
   Ls_8C40 = " Current SL: ";
   Ls_8C30 = (string)Bid;
   Ls_8C20 = ", Bid: ";
   Ls_8C10 = (string)Ask;
   Ls_8C00 = ", Ask: ";
   Ls_8BF0 = func_1032(Gi_0099);
   Ls_8BE0 = " - ";
   Ls_8BD0 = (string)Ii_1414;
   Ls_8BC0 = "Failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_8BB0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_8BB0, " ", Ls_8BC0, Ls_8BD0, Ls_8BE0, Ls_8BF0, Ls_8C00, Ls_8C10, Ls_8C20, Ls_8C30, Ls_8C40, Ls_8C50, Ls_8C60, Ls_8C70);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0C1C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0C1C > 0) { 
   FileSeek(Ii_0C1C, 0, 2);
   Ls_8BA0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0C1C, Ls_8BA0, " VERBOSE: ", Ls_8BC0, Ls_8BD0, Ls_8BE0, Ls_8BF0, Ls_8C00, Ls_8C10, Ls_8C20, Ls_8C30, Ls_8C40, Ls_8C50, Ls_8C60, Ls_8C70);
   FileClose(Ii_0C1C);
   }}}}}}}}} 
   Ii_0C20 = Ii_00A0;
   Id_0C28 = 0;
   if (Ii_00A0 == Ii_006C) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0070) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0074) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0078) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_007C) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0080) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0084) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0088) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_008C) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0090) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0094) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_0098) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_009C) { 
   Id_0C28 = 0;
   } 
   if (Ii_0C20 == Ii_00A0) { 
   Id_0C28 = 0;
   } 
   returned_double = NormalizeDouble(Id_0C28, _Digits);
   Id_38F0 = returned_double;
   Ld_8AB8 = Id_38F0;
   if ((returned_double <= 0)) { 
   return ;
   } 
   Ii_0C30 = (int)(Id_38F0 + 10);
   Il_0C38 = OrderOpenTime();
   Ii_0C40 = 0;
   Ii_0C44 = 0;
   Ii_1414 = Ii_0C30 + 10;
   if (Ii_1414 > 0) { 
   do { 
   if (Il_0C38 < Time[Ii_0C44]) { 
   Ii_0C40 = Ii_0C40 + 1;
   } 
   Ii_0C44 = Ii_0C44 + 1;
   Ii_1420 = Ii_0C30 + 10;
   } while (Ii_0C44 < Ii_1420); 
   } 
   if ((Ii_0C40 < Ld_8AB8)) { 
   return ;
   } 
   Ls_8B90 = "";
   Ls_8B80 = "";
   Ls_8B70 = "";
   Ls_8B60 = "";
   Ls_8B50 = "";
   Ls_8B40 = "";
   Ls_8B30 = (string)Fa_i_00;
   Ls_8B20 = ", Magic Number: ";
   Ls_8B10 = (string)OrderTicket();
   Ls_8B00 = "bars - closing order with ticket: ";
   Ls_8AF0 = (string)Ld_8AB8;
   Ls_8AE0 = "Exit After ";
   if (Ii_08EC == 1) { 
   Ls_8AD0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_8AD0, " ", Ls_8AE0, Ls_8AF0, Ls_8B00, Ls_8B10, Ls_8B20, Ls_8B30, Ls_8B40, Ls_8B50, Ls_8B60, Ls_8B70, Ls_8B80, Ls_8B90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0C48 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0C48 > 0) { 
   FileSeek(Ii_0C48, 0, 2);
   Ls_8AC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0C48, Ls_8AC0, " VERBOSE: ", Ls_8AE0, Ls_8AF0, Ls_8B00, Ls_8B10, Ls_8B20, Ls_8B30, Ls_8B40, Ls_8B50, Ls_8B60, Ls_8B70, Ls_8B80, Ls_8B90);
   FileClose(Ii_0C48);
   }}} 
   func_1022(-1);
   
}

void func_1016(int Fa_i_00)
{
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   string Ls_FD90;
   string Ls_FD80;
   string Ls_FD70;
   string Ls_FD60;
   string Ls_FD50;
   string Ls_FD40;
   string Ls_FD30;
   string Ls_FD20;
   string Ls_FD10;
   string Ls_FD00;
   string Ls_FCF0;
   string Ls_FCE0;
   string Ls_FCD0;
   string Ls_FCC0;
   string Ls_FCB0;
   string Ls_FCA0;
   string Ls_FC90;
   string Ls_FC80;
   string Ls_FC70;
   string Ls_FC60;
   string Ls_FC50;
   string Ls_FC40;
   string Ls_FC30;
   string Ls_FC20;
   string Ls_FC10;
   string Ls_FC00;
   string Ls_FBF0;
   string Ls_FBE0;
   string Ls_FBD0;
   string Ls_FBC0;
   string Ls_FBB0;
   string Ls_FBA0;
   string Ls_FB90;
   string Ls_FB80;
   string Ls_FB70;
   string Ls_FB60;
   string Ls_FB50;
   string Ls_FB40;
   string Ls_FB30;
   string Ls_FB20;
   string Ls_FB10;
   string Ls_FB00;
   string Ls_FAF0;
   string Ls_FAE0;
   string Ls_FAD0;
   string Ls_FAC0;
   string Ls_FAB0;
   string Ls_FAA0;
   string Ls_FA90;
   string Ls_FA80;
   string Ls_FA70;
   string Ls_FA60;
   string Ls_FA50;
   string Ls_FA40;
   string Ls_FA30;
   string Ls_FA20;
   string Ls_FA10;
   string Ls_FA00;
   string Ls_F9F0;
   string Ls_F9E0;
   string Ls_F9D0;
   string Ls_F9C0;
   string Ls_F9B0;
   string Ls_F9A0;
   string Ls_F990;
   string Ls_F980;
   string Ls_F970;
   string Ls_F960;
   string Ls_F950;
   string Ls_F940;
   string Ls_F930;
   string Ls_F920;
   string Ls_F910;
   string Ls_F900;
   string Ls_F8F0;
   string Ls_F8E0;
   string Ls_F8D0;
   string Ls_F8C0;
   string Ls_F8B0;
   string Ls_F8A0;
   string Ls_F890;
   string Ls_F880;
   string Ls_F870;
   string Ls_F860;
   string Ls_F850;
   string Ls_F840;
   string Ls_F830;
   string Ls_F820;
   string Ls_F810;
   string Ls_F800;
   string Ls_F7F0;
   string Ls_F7E0;
   string Ls_F7D0;
   string Ls_F7C0;
   string Ls_F7B0;
   string Ls_F7A0;
   string Ls_F790;
   string Ls_F780;
   string Ls_F770;
   string Ls_F760;
   string Ls_F750;
   string Ls_F740;
   string Ls_F730;
   string Ls_F720;
   string Ls_F710;
   string Ls_F700;
   string Ls_F6F0;
   string Ls_F6E0;
   string Ls_F6D0;
   string Ls_F6C0;
   string Ls_F6B0;
   string Ls_F6A0;
   string Ls_F690;
   string Ls_F680;
   string Ls_F670;
   string Ls_F660;
   string Ls_F650;
   string Ls_F640;
   string Ls_F630;
   string Ls_F620;
   string Ls_F610;
   string Ls_F600;
   string Ls_F5F0;
   string Ls_F5E0;
   string Ls_F5D0;
   string Ls_F5C0;
   string Ls_F5B0;
   string Ls_F5A0;
   string Ls_F590;
   string Ls_F580;
   string Ls_F570;
   string Ls_F560;
   string Ls_F550;
   string Ls_F540;
   string Ls_F530;
   string Ls_F520;
   string Ls_F510;
   string Ls_F500;
   string Ls_F4F0;
   string Ls_F4E0;
   string Ls_F4D0;
   string Ls_F4C0;
   string Ls_F4B0;
   string Ls_F4A0;
   string Ls_F490;
   string Ls_F480;
   string Ls_F470;
   string Ls_F460;
   string Ls_F450;
   string Ls_F440;
   string Ls_F430;
   string Ls_F420;
   string Ls_F410;
   string Ls_F400;
   string Ls_F3F0;
   string Ls_F3E0;
   string Ls_F3D0;
   string Ls_F3C0;
   int Li_F3BC;
   int Li_F3B8;

   Li_F3BC = 0;
   Li_F3B8 = 0;
   Li_F3BC = 0;
   Li_F3B8 = 0;
   Ii_0108 = 0;
   Id_0928 = 0;
   Ii_0930 = 0;
   Il_17B0 = 0;
   Ii_011C = 0;
   Ii_0934 = 0;
   Ii_0124 = 0;
   Ii_0128 = 0;
   Id_17B8 = 0;
   Ii_0940 = 0;
   Il_17C0 = 0;
   Ii_0140 = 0;
   Ii_0948 = 0;
   Ii_0150 = 0;
   Ii_0958 = 0;
   Id_0160 = 0;
   Ii_0168 = 0;
   Il_17C8 = 0;
   Ii_0178 = 0;
   Ii_096C = 0;
   Ii_0188 = 0;
   Ii_0978 = 0;
   Id_0198 = 0;
   Ii_01A0 = 0;
   Il_17D0 = 0;
   Ii_0984 = 0;
   Ii_01B8 = 0;
   Ii_0990 = 0;
   Ii_01C8 = 0;
   Id_01D0 = 0;
   Ii_01D8 = 0;
   Il_17D8 = 0;
   Ii_17E0 = 0;
   Ii_01F0 = 0;
   Ii_17E4 = 0;
   Ii_09A8 = 0;
   Id_17E8 = 0;
   Ii_09AC = 0;
   Il_17F0 = 0;
   Ii_17F8 = 0;
   Ii_0228 = 0;
   Ii_09B0 = 0;
   Ii_09B4 = 0;
   Id_1800 = 0;
   Ii_09B8 = 0;
   Il_1808 = 0;
   Ii_0258 = 0;
   Ii_09BC = 0;
   Ii_0268 = 0;
   Ii_09C0 = 0;
   Id_1810 = 0;
   Ii_1818 = 0;
   Il_1820 = 0;
   Ii_0290 = 0;
   Ii_09D0 = 0;
   Ii_09D4 = 0;
   Ii_02A8 = 0;
   Id_02B0 = 0;
   Ii_02B8 = 0;
   Il_1828 = 0;
   Ii_02C8 = 0;
   Ii_09EC = 0;
   Ii_09F0 = 0;
   Ii_02E0 = 0;
   Id_02E8 = 0;
   Ii_09F4 = 0;
   Il_1830 = 0;
   Ii_09F8 = 0;
   Ii_0308 = 0;
   Ii_09FC = 0;
   Ii_0318 = 0;
   Id_0320 = 0;
   Ii_1838 = 0;
   Il_1840 = 0;
   Ii_0A18 = 0;
   Ii_0A1C = 0;
   Ii_0348 = 0;
   Ii_1848 = 0;
   Id_1850 = 0;
   Ii_035C = 0;
   Il_1858 = 0;
   Ii_0364 = 0;
   Ii_0A24 = 0;
   Ii_1860 = 0;
   Ii_0378 = 0;
   Id_0380 = 0;
   Ii_0388 = 0;
   Il_1868 = 0;
   Ii_0A30 = 0;
   Ii_03A0 = 0;
   Ii_0A40 = 0;
   Ii_03B0 = 0;
   Id_03B8 = 0;
   Ii_03C0 = 0;
   Il_1870 = 0;
   Ii_0A58 = 0;
   Ii_03D8 = 0;
   Ii_0A68 = 0;
   Li_F3BC = 0;
   Li_F3B8 = 0;
   if (Fa_i_00 == Ii_006C && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_0108 = Ii_006C;
   Id_0928 = 0;
   if (Ii_006C == Ii_006C) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0070) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0074) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0078) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_007C) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0080) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0084) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0088) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_008C) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0090) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0094) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_0098) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_009C) { 
   Id_0928 = 0;
   } 
   if (Ii_0108 == Ii_00A0) { 
   Id_0928 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_0928, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0A6C = Li_F3BC + 10;
   Ii_0930 = Ii_0A6C;
   Il_17B0 = OrderOpenTime();
   Ii_011C = 0;
   Ii_0934 = 0;
   Ii_0A6C = Ii_0A6C + 10;
   if (Ii_0A6C > 0) { 
   do { 
   if (Il_17B0 < Time[Ii_0934]) { 
   Ii_011C = Ii_011C + 1;
   } 
   Ii_0934 = Ii_0934 + 1;
   Ii_03F0 = Ii_0930 + 10;
   } while (Ii_0934 < Ii_03F0); 
   } 
   Li_F3B8 = Ii_011C;
   if (Ii_011C >= Li_F3BC) { 
   Ls_FFF0 = "";
   Ls_FFE0 = "";
   Ls_FFD0 = "";
   Ls_FFC0 = "";
   Ls_FFB0 = "";
   Ls_FFA0 = "";
   Ls_FF90 = "";
   Ls_FF80 = " expired";
   Ls_FF70 = (string)Fa_i_00;
   Ls_FF60 = ", Magic Number: ";
   Ls_FF50 = (string)OrderTicket();
   Ls_FF40 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FF30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FF30, " ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0124 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0124 > 0) { 
   FileSeek(Ii_0124, 0, 2);
   Ls_FF20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0124, Ls_FF20, " VERBOSE: ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   FileClose(Ii_0124);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0070 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_0128 = Ii_0070;
   Id_17B8 = 0;
   if (Ii_0070 == Ii_006C) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0070) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0074) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0078) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_007C) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0080) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0084) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0088) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_008C) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0090) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0094) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_0098) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_009C) { 
   Id_17B8 = 0;
   } 
   if (Ii_0128 == Ii_00A0) { 
   Id_17B8 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_17B8, _Digits);
   if (Li_F3BC > 0) { 
   Ii_03F0 = Li_F3BC + 10;
   Ii_0940 = Ii_03F0;
   Il_17C0 = OrderOpenTime();
   Ii_0140 = 0;
   Ii_0948 = 0;
   Ii_03F0 = Ii_03F0 + 10;
   if (Ii_03F0 > 0) { 
   do { 
   if (Il_17C0 < Time[Ii_0948]) { 
   Ii_0140 = Ii_0140 + 1;
   } 
   Ii_0948 = Ii_0948 + 1;
   Ii_0A70 = Ii_0940 + 10;
   } while (Ii_0948 < Ii_0A70); 
   } 
   Li_F3B8 = Ii_0140;
   if (Ii_0140 >= Li_F3BC) { 
   Ls_FF10 = "";
   Ls_FF00 = "";
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = " expired";
   Ls_FE90 = (string)Fa_i_00;
   Ls_FE80 = ", Magic Number: ";
   Ls_FE70 = (string)OrderTicket();
   Ls_FE60 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FE50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FE50, " ", Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0150 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0150 > 0) { 
   FileSeek(Ii_0150, 0, 2);
   Ls_FE40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0150, Ls_FE40, " VERBOSE: ", Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10);
   FileClose(Ii_0150);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0074 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_0958 = Ii_0074;
   Id_0160 = 0;
   if (Ii_0074 == Ii_006C) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0070) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0074) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0078) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_007C) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0080) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0084) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0088) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_008C) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0090) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0094) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_0098) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_009C) { 
   Id_0160 = 0;
   } 
   if (Ii_0958 == Ii_00A0) { 
   Id_0160 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_0160, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0A70 = Li_F3BC + 10;
   Ii_0168 = Ii_0A70;
   Il_17C8 = OrderOpenTime();
   Ii_0178 = 0;
   Ii_096C = 0;
   Ii_0A70 = Ii_0A70 + 10;
   if (Ii_0A70 > 0) { 
   do { 
   if (Il_17C8 < Time[Ii_096C]) { 
   Ii_0178 = Ii_0178 + 1;
   } 
   Ii_096C = Ii_096C + 1;
   Ii_0400 = Ii_0168 + 10;
   } while (Ii_096C < Ii_0400); 
   } 
   Li_F3B8 = Ii_0178;
   if (Ii_0178 >= Li_F3BC) { 
   Ls_FE30 = "";
   Ls_FE20 = "";
   Ls_FE10 = "";
   Ls_FE00 = "";
   Ls_FDF0 = "";
   Ls_FDE0 = "";
   Ls_FDD0 = "";
   Ls_FDC0 = " expired";
   Ls_FDB0 = (string)Fa_i_00;
   Ls_FDA0 = ", Magic Number: ";
   Ls_FD90 = (string)OrderTicket();
   Ls_FD80 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FD70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FD70, " ", Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20, Ls_FE30);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0188 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0188 > 0) { 
   FileSeek(Ii_0188, 0, 2);
   Ls_FD60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0188, Ls_FD60, " VERBOSE: ", Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20, Ls_FE30);
   FileClose(Ii_0188);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0078 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_0978 = Ii_0078;
   Id_0198 = 0;
   if (Ii_0078 == Ii_006C) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0070) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0074) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0078) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_007C) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0080) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0084) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0088) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_008C) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0090) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0094) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_0098) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_009C) { 
   Id_0198 = 0;
   } 
   if (Ii_0978 == Ii_00A0) { 
   Id_0198 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_0198, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0400 = Li_F3BC + 10;
   Ii_01A0 = Ii_0400;
   Il_17D0 = OrderOpenTime();
   Ii_0984 = 0;
   Ii_01B8 = 0;
   Ii_0400 = Ii_0400 + 10;
   if (Ii_0400 > 0) { 
   do { 
   if (Il_17D0 < Time[Ii_01B8]) { 
   Ii_0984 = Ii_0984 + 1;
   } 
   Ii_01B8 = Ii_01B8 + 1;
   Ii_1898 = Ii_01A0 + 10;
   } while (Ii_01B8 < Ii_1898); 
   } 
   Li_F3B8 = Ii_0984;
   if (Ii_0984 >= Li_F3BC) { 
   Ls_FD50 = "";
   Ls_FD40 = "";
   Ls_FD30 = "";
   Ls_FD20 = "";
   Ls_FD10 = "";
   Ls_FD00 = "";
   Ls_FCF0 = "";
   Ls_FCE0 = " expired";
   Ls_FCD0 = (string)Fa_i_00;
   Ls_FCC0 = ", Magic Number: ";
   Ls_FCB0 = (string)OrderTicket();
   Ls_FCA0 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FC90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FC90, " ", Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10, Ls_FD20, Ls_FD30, Ls_FD40, Ls_FD50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0990 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0990 > 0) { 
   FileSeek(Ii_0990, 0, 2);
   Ls_FC80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0990, Ls_FC80, " VERBOSE: ", Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10, Ls_FD20, Ls_FD30, Ls_FD40, Ls_FD50);
   FileClose(Ii_0990);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_007C && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_01C8 = Ii_007C;
   Id_01D0 = 0;
   if (Ii_007C == Ii_006C) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0070) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0074) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0078) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_007C) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0080) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0084) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0088) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_008C) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0090) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0094) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_0098) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_009C) { 
   Id_01D0 = 0;
   } 
   if (Ii_01C8 == Ii_00A0) { 
   Id_01D0 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_01D0, _Digits);
   if (Li_F3BC > 0) { 
   Ii_1898 = Li_F3BC + 10;
   Ii_01D8 = Ii_1898;
   Il_17D8 = OrderOpenTime();
   Ii_17E0 = 0;
   Ii_01F0 = 0;
   Ii_1898 = Ii_1898 + 10;
   if (Ii_1898 > 0) { 
   do { 
   if (Il_17D8 < Time[Ii_01F0]) { 
   Ii_17E0 = Ii_17E0 + 1;
   } 
   Ii_01F0 = Ii_01F0 + 1;
   Ii_0410 = Ii_01D8 + 10;
   } while (Ii_01F0 < Ii_0410); 
   } 
   Li_F3B8 = Ii_17E0;
   if (Ii_17E0 >= Li_F3BC) { 
   Ls_FC70 = "";
   Ls_FC60 = "";
   Ls_FC50 = "";
   Ls_FC40 = "";
   Ls_FC30 = "";
   Ls_FC20 = "";
   Ls_FC10 = "";
   Ls_FC00 = " expired";
   Ls_FBF0 = (string)Fa_i_00;
   Ls_FBE0 = ", Magic Number: ";
   Ls_FBD0 = (string)OrderTicket();
   Ls_FBC0 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FBB0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FBB0, " ", Ls_FBC0, Ls_FBD0, Ls_FBE0, Ls_FBF0, Ls_FC00, Ls_FC10, Ls_FC20, Ls_FC30, Ls_FC40, Ls_FC50, Ls_FC60, Ls_FC70);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_17E4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_17E4 > 0) { 
   FileSeek(Ii_17E4, 0, 2);
   Ls_FBA0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_17E4, Ls_FBA0, " VERBOSE: ", Ls_FBC0, Ls_FBD0, Ls_FBE0, Ls_FBF0, Ls_FC00, Ls_FC10, Ls_FC20, Ls_FC30, Ls_FC40, Ls_FC50, Ls_FC60, Ls_FC70);
   FileClose(Ii_17E4);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0080 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_09A8 = Ii_0080;
   Id_17E8 = 0;
   if (Ii_0080 == Ii_006C) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0070) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0074) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0078) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_007C) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0080) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0084) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0088) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_008C) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0090) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0094) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_0098) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_009C) { 
   Id_17E8 = 0;
   } 
   if (Ii_09A8 == Ii_00A0) { 
   Id_17E8 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_17E8, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0410 = Li_F3BC + 10;
   Ii_09AC = Ii_0410;
   Il_17F0 = OrderOpenTime();
   Ii_17F8 = 0;
   Ii_0228 = 0;
   Ii_0410 = Ii_0410 + 10;
   if (Ii_0410 > 0) { 
   do { 
   if (Il_17F0 < Time[Ii_0228]) { 
   Ii_17F8 = Ii_17F8 + 1;
   } 
   Ii_0228 = Ii_0228 + 1;
   Ii_0A74 = Ii_09AC + 10;
   } while (Ii_0228 < Ii_0A74); 
   } 
   Li_F3B8 = Ii_17F8;
   if (Ii_17F8 >= Li_F3BC) { 
   Ls_FB90 = "";
   Ls_FB80 = "";
   Ls_FB70 = "";
   Ls_FB60 = "";
   Ls_FB50 = "";
   Ls_FB40 = "";
   Ls_FB30 = "";
   Ls_FB20 = " expired";
   Ls_FB10 = (string)Fa_i_00;
   Ls_FB00 = ", Magic Number: ";
   Ls_FAF0 = (string)OrderTicket();
   Ls_FAE0 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FAD0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FAD0, " ", Ls_FAE0, Ls_FAF0, Ls_FB00, Ls_FB10, Ls_FB20, Ls_FB30, Ls_FB40, Ls_FB50, Ls_FB60, Ls_FB70, Ls_FB80, Ls_FB90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09B0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09B0 > 0) { 
   FileSeek(Ii_09B0, 0, 2);
   Ls_FAC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09B0, Ls_FAC0, " VERBOSE: ", Ls_FAE0, Ls_FAF0, Ls_FB00, Ls_FB10, Ls_FB20, Ls_FB30, Ls_FB40, Ls_FB50, Ls_FB60, Ls_FB70, Ls_FB80, Ls_FB90);
   FileClose(Ii_09B0);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0084 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_09B4 = Ii_0084;
   Id_1800 = 0;
   if (Ii_0084 == Ii_006C) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0070) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0074) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0078) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_007C) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0080) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0084) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0088) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_008C) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0090) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0094) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_0098) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_009C) { 
   Id_1800 = 0;
   } 
   if (Ii_09B4 == Ii_00A0) { 
   Id_1800 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_1800, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0A74 = Li_F3BC + 10;
   Ii_09B8 = Ii_0A74;
   Il_1808 = OrderOpenTime();
   Ii_0258 = 0;
   Ii_09BC = 0;
   Ii_0A74 = Ii_0A74 + 10;
   if (Ii_0A74 > 0) { 
   do { 
   if (Il_1808 < Time[Ii_09BC]) { 
   Ii_0258 = Ii_0258 + 1;
   } 
   Ii_09BC = Ii_09BC + 1;
   Ii_0A78 = Ii_09B8 + 10;
   } while (Ii_09BC < Ii_0A78); 
   } 
   Li_F3B8 = Ii_0258;
   if (Ii_0258 >= Li_F3BC) { 
   Ls_FAB0 = "";
   Ls_FAA0 = "";
   Ls_FA90 = "";
   Ls_FA80 = "";
   Ls_FA70 = "";
   Ls_FA60 = "";
   Ls_FA50 = "";
   Ls_FA40 = " expired";
   Ls_FA30 = (string)Fa_i_00;
   Ls_FA20 = ", Magic Number: ";
   Ls_FA10 = (string)OrderTicket();
   Ls_FA00 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F9F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F9F0, " ", Ls_FA00, Ls_FA10, Ls_FA20, Ls_FA30, Ls_FA40, Ls_FA50, Ls_FA60, Ls_FA70, Ls_FA80, Ls_FA90, Ls_FAA0, Ls_FAB0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0268 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0268 > 0) { 
   FileSeek(Ii_0268, 0, 2);
   Ls_F9E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0268, Ls_F9E0, " VERBOSE: ", Ls_FA00, Ls_FA10, Ls_FA20, Ls_FA30, Ls_FA40, Ls_FA50, Ls_FA60, Ls_FA70, Ls_FA80, Ls_FA90, Ls_FAA0, Ls_FAB0);
   FileClose(Ii_0268);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0088 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_09C0 = Ii_0088;
   Id_1810 = 0;
   if (Ii_0088 == Ii_006C) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0070) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0074) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0078) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_007C) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0080) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0084) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0088) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_008C) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0090) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0094) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_0098) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_009C) { 
   Id_1810 = 0;
   } 
   if (Ii_09C0 == Ii_00A0) { 
   Id_1810 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_1810, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0A78 = Li_F3BC + 10;
   Ii_1818 = Ii_0A78;
   Il_1820 = OrderOpenTime();
   Ii_0290 = 0;
   Ii_09D0 = 0;
   Ii_0A78 = Ii_0A78 + 10;
   if (Ii_0A78 > 0) { 
   do { 
   if (Il_1820 < Time[Ii_09D0]) { 
   Ii_0290 = Ii_0290 + 1;
   } 
   Ii_09D0 = Ii_09D0 + 1;
   Ii_0428 = Ii_1818 + 10;
   } while (Ii_09D0 < Ii_0428); 
   } 
   Li_F3B8 = Ii_0290;
   if (Ii_0290 >= Li_F3BC) { 
   Ls_F9D0 = "";
   Ls_F9C0 = "";
   Ls_F9B0 = "";
   Ls_F9A0 = "";
   Ls_F990 = "";
   Ls_F980 = "";
   Ls_F970 = "";
   Ls_F960 = " expired";
   Ls_F950 = (string)Fa_i_00;
   Ls_F940 = ", Magic Number: ";
   Ls_F930 = (string)OrderTicket();
   Ls_F920 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F910 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F910, " ", Ls_F920, Ls_F930, Ls_F940, Ls_F950, Ls_F960, Ls_F970, Ls_F980, Ls_F990, Ls_F9A0, Ls_F9B0, Ls_F9C0, Ls_F9D0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09D4 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09D4 > 0) { 
   FileSeek(Ii_09D4, 0, 2);
   Ls_F900 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09D4, Ls_F900, " VERBOSE: ", Ls_F920, Ls_F930, Ls_F940, Ls_F950, Ls_F960, Ls_F970, Ls_F980, Ls_F990, Ls_F9A0, Ls_F9B0, Ls_F9C0, Ls_F9D0);
   FileClose(Ii_09D4);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_008C && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_02A8 = Ii_008C;
   Id_02B0 = 0;
   if (Ii_008C == Ii_006C) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0070) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0074) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0078) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_007C) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0080) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0084) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0088) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_008C) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0090) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0094) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_0098) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_009C) { 
   Id_02B0 = 0;
   } 
   if (Ii_02A8 == Ii_00A0) { 
   Id_02B0 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_02B0, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0428 = Li_F3BC + 10;
   Ii_02B8 = Ii_0428;
   Il_1828 = OrderOpenTime();
   Ii_02C8 = 0;
   Ii_09EC = 0;
   Ii_0428 = Ii_0428 + 10;
   if (Ii_0428 > 0) { 
   do { 
   if (Il_1828 < Time[Ii_09EC]) { 
   Ii_02C8 = Ii_02C8 + 1;
   } 
   Ii_09EC = Ii_09EC + 1;
   Ii_0A7C = Ii_02B8 + 10;
   } while (Ii_09EC < Ii_0A7C); 
   } 
   Li_F3B8 = Ii_02C8;
   if (Ii_02C8 >= Li_F3BC) { 
   Ls_F8F0 = "";
   Ls_F8E0 = "";
   Ls_F8D0 = "";
   Ls_F8C0 = "";
   Ls_F8B0 = "";
   Ls_F8A0 = "";
   Ls_F890 = "";
   Ls_F880 = " expired";
   Ls_F870 = (string)Fa_i_00;
   Ls_F860 = ", Magic Number: ";
   Ls_F850 = (string)OrderTicket();
   Ls_F840 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F830 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F830, " ", Ls_F840, Ls_F850, Ls_F860, Ls_F870, Ls_F880, Ls_F890, Ls_F8A0, Ls_F8B0, Ls_F8C0, Ls_F8D0, Ls_F8E0, Ls_F8F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09F0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09F0 > 0) { 
   FileSeek(Ii_09F0, 0, 2);
   Ls_F820 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09F0, Ls_F820, " VERBOSE: ", Ls_F840, Ls_F850, Ls_F860, Ls_F870, Ls_F880, Ls_F890, Ls_F8A0, Ls_F8B0, Ls_F8C0, Ls_F8D0, Ls_F8E0, Ls_F8F0);
   FileClose(Ii_09F0);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0090 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_02E0 = Ii_0090;
   Id_02E8 = 0;
   if (Ii_0090 == Ii_006C) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0070) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0074) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0078) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_007C) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0080) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0084) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0088) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_008C) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0090) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0094) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_0098) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_009C) { 
   Id_02E8 = 0;
   } 
   if (Ii_02E0 == Ii_00A0) { 
   Id_02E8 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_02E8, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0A7C = Li_F3BC + 10;
   Ii_09F4 = Ii_0A7C;
   Il_1830 = OrderOpenTime();
   Ii_09F8 = 0;
   Ii_0308 = 0;
   Ii_0A7C = Ii_0A7C + 10;
   if (Ii_0A7C > 0) { 
   do { 
   if (Il_1830 < Time[Ii_0308]) { 
   Ii_09F8 = Ii_09F8 + 1;
   } 
   Ii_0308 = Ii_0308 + 1;
   Ii_18D0 = Ii_09F4 + 10;
   } while (Ii_0308 < Ii_18D0); 
   } 
   Li_F3B8 = Ii_09F8;
   if (Ii_09F8 >= Li_F3BC) { 
   Ls_F810 = "";
   Ls_F800 = "";
   Ls_F7F0 = "";
   Ls_F7E0 = "";
   Ls_F7D0 = "";
   Ls_F7C0 = "";
   Ls_F7B0 = "";
   Ls_F7A0 = " expired";
   Ls_F790 = (string)Fa_i_00;
   Ls_F780 = ", Magic Number: ";
   Ls_F770 = (string)OrderTicket();
   Ls_F760 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F750 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F750, " ", Ls_F760, Ls_F770, Ls_F780, Ls_F790, Ls_F7A0, Ls_F7B0, Ls_F7C0, Ls_F7D0, Ls_F7E0, Ls_F7F0, Ls_F800, Ls_F810);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_09FC = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_09FC > 0) { 
   FileSeek(Ii_09FC, 0, 2);
   Ls_F740 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_09FC, Ls_F740, " VERBOSE: ", Ls_F760, Ls_F770, Ls_F780, Ls_F790, Ls_F7A0, Ls_F7B0, Ls_F7C0, Ls_F7D0, Ls_F7E0, Ls_F7F0, Ls_F800, Ls_F810);
   FileClose(Ii_09FC);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0094 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_0318 = Ii_0094;
   Id_0320 = 0;
   if (Ii_0094 == Ii_006C) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0070) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0074) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0078) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_007C) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0080) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0084) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0088) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_008C) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0090) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0094) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_0098) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_009C) { 
   Id_0320 = 0;
   } 
   if (Ii_0318 == Ii_00A0) { 
   Id_0320 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_0320, _Digits);
   if (Li_F3BC > 0) { 
   Ii_18D0 = Li_F3BC + 10;
   Ii_1838 = Ii_18D0;
   Il_1840 = OrderOpenTime();
   Ii_0A18 = 0;
   Ii_0A1C = 0;
   Ii_18D0 = Ii_18D0 + 10;
   if (Ii_18D0 > 0) { 
   do { 
   if (Il_1840 < Time[Ii_0A1C]) { 
   Ii_0A18 = Ii_0A18 + 1;
   } 
   Ii_0A1C = Ii_0A1C + 1;
   Ii_0440 = Ii_1838 + 10;
   } while (Ii_0A1C < Ii_0440); 
   } 
   Li_F3B8 = Ii_0A18;
   if (Ii_0A18 >= Li_F3BC) { 
   Ls_F730 = "";
   Ls_F720 = "";
   Ls_F710 = "";
   Ls_F700 = "";
   Ls_F6F0 = "";
   Ls_F6E0 = "";
   Ls_F6D0 = "";
   Ls_F6C0 = " expired";
   Ls_F6B0 = (string)Fa_i_00;
   Ls_F6A0 = ", Magic Number: ";
   Ls_F690 = (string)OrderTicket();
   Ls_F680 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F670 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F670, " ", Ls_F680, Ls_F690, Ls_F6A0, Ls_F6B0, Ls_F6C0, Ls_F6D0, Ls_F6E0, Ls_F6F0, Ls_F700, Ls_F710, Ls_F720, Ls_F730);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0348 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0348 > 0) { 
   FileSeek(Ii_0348, 0, 2);
   Ls_F660 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0348, Ls_F660, " VERBOSE: ", Ls_F680, Ls_F690, Ls_F6A0, Ls_F6B0, Ls_F6C0, Ls_F6D0, Ls_F6E0, Ls_F6F0, Ls_F700, Ls_F710, Ls_F720, Ls_F730);
   FileClose(Ii_0348);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_0098 && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_1848 = Ii_0098;
   Id_1850 = 0;
   if (Ii_0098 == Ii_006C) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0070) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0074) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0078) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_007C) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0080) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0084) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0088) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_008C) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0090) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0094) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_0098) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_009C) { 
   Id_1850 = 0;
   } 
   if (Ii_1848 == Ii_00A0) { 
   Id_1850 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_1850, _Digits);
   if (Li_F3BC > 0) { 
   Ii_0440 = Li_F3BC + 10;
   Ii_035C = Ii_0440;
   Il_1858 = OrderOpenTime();
   Ii_0364 = 0;
   Ii_0A24 = 0;
   Ii_0440 = Ii_0440 + 10;
   if (Ii_0440 > 0) { 
   do { 
   if (Il_1858 < Time[Ii_0A24]) { 
   Ii_0364 = Ii_0364 + 1;
   } 
   Ii_0A24 = Ii_0A24 + 1;
   Ii_18E8 = Ii_035C + 10;
   } while (Ii_0A24 < Ii_18E8); 
   } 
   Li_F3B8 = Ii_0364;
   if (Ii_0364 >= Li_F3BC) { 
   Ls_F650 = "";
   Ls_F640 = "";
   Ls_F630 = "";
   Ls_F620 = "";
   Ls_F610 = "";
   Ls_F600 = "";
   Ls_F5F0 = "";
   Ls_F5E0 = " expired";
   Ls_F5D0 = (string)Fa_i_00;
   Ls_F5C0 = ", Magic Number: ";
   Ls_F5B0 = (string)OrderTicket();
   Ls_F5A0 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F590 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F590, " ", Ls_F5A0, Ls_F5B0, Ls_F5C0, Ls_F5D0, Ls_F5E0, Ls_F5F0, Ls_F600, Ls_F610, Ls_F620, Ls_F630, Ls_F640, Ls_F650);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_1860 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_1860 > 0) { 
   FileSeek(Ii_1860, 0, 2);
   Ls_F580 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_1860, Ls_F580, " VERBOSE: ", Ls_F5A0, Ls_F5B0, Ls_F5C0, Ls_F5D0, Ls_F5E0, Ls_F5F0, Ls_F600, Ls_F610, Ls_F620, Ls_F630, Ls_F640, Ls_F650);
   FileClose(Ii_1860);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 == Ii_009C && OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Ii_0378 = Ii_009C;
   Id_0380 = 0;
   if (Ii_009C == Ii_006C) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0070) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0074) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0078) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_007C) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0080) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0084) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0088) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_008C) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0090) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0094) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_0098) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_009C) { 
   Id_0380 = 0;
   } 
   if (Ii_0378 == Ii_00A0) { 
   Id_0380 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_0380, _Digits);
   if (Li_F3BC > 0) { 
   Ii_18E8 = Li_F3BC + 10;
   Ii_0388 = Ii_18E8;
   Il_1868 = OrderOpenTime();
   Ii_0A30 = 0;
   Ii_03A0 = 0;
   Ii_18E8 = Ii_18E8 + 10;
   if (Ii_18E8 > 0) { 
   do { 
   if (Il_1868 < Time[Ii_03A0]) { 
   Ii_0A30 = Ii_0A30 + 1;
   } 
   Ii_03A0 = Ii_03A0 + 1;
   Ii_0450 = Ii_0388 + 10;
   } while (Ii_03A0 < Ii_0450); 
   } 
   Li_F3B8 = Ii_0A30;
   if (Ii_0A30 >= Li_F3BC) { 
   Ls_F570 = "";
   Ls_F560 = "";
   Ls_F550 = "";
   Ls_F540 = "";
   Ls_F530 = "";
   Ls_F520 = "";
   Ls_F510 = "";
   Ls_F500 = " expired";
   Ls_F4F0 = (string)Fa_i_00;
   Ls_F4E0 = ", Magic Number: ";
   Ls_F4D0 = (string)OrderTicket();
   Ls_F4C0 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F4B0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F4B0, " ", Ls_F4C0, Ls_F4D0, Ls_F4E0, Ls_F4F0, Ls_F500, Ls_F510, Ls_F520, Ls_F530, Ls_F540, Ls_F550, Ls_F560, Ls_F570);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A40 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A40 > 0) { 
   FileSeek(Ii_0A40, 0, 2);
   Ls_F4A0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A40, Ls_F4A0, " VERBOSE: ", Ls_F4C0, Ls_F4D0, Ls_F4E0, Ls_F4F0, Ls_F500, Ls_F510, Ls_F520, Ls_F530, Ls_F540, Ls_F550, Ls_F560, Ls_F570);
   FileClose(Ii_0A40);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }}} 
   if (Fa_i_00 != Ii_00A0) { 
   return ;
   } 
   if (OrderType() == OP_BUY) { 
   return ;
   } 
   if (OrderType() == OP_SELL) { 
   return ;
   } 
   Ii_03B0 = Ii_00A0;
   Id_03B8 = 0;
   if (Ii_00A0 == Ii_006C) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0070) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0074) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0078) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_007C) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0080) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0084) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0088) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_008C) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0090) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0094) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_0098) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_009C) { 
   Id_03B8 = 0;
   } 
   if (Ii_03B0 == Ii_00A0) { 
   Id_03B8 = 0;
   } 
   Li_F3BC = (int)NormalizeDouble(Id_03B8, _Digits);
   if (Li_F3BC <= 0) { 
   return ;
   } 
   Ii_0450 = Li_F3BC + 10;
   Ii_03C0 = Ii_0450;
   Il_1870 = OrderOpenTime();
   Ii_0A58 = 0;
   Ii_03D8 = 0;
   Ii_0450 = Ii_0450 + 10;
   if (Ii_0450 > 0) { 
   do { 
   if (Il_1870 < Time[Ii_03D8]) { 
   Ii_0A58 = Ii_0A58 + 1;
   } 
   Ii_03D8 = Ii_03D8 + 1;
   Ii_0A88 = Ii_03C0 + 10;
   } while (Ii_03D8 < Ii_0A88); 
   } 
   Li_F3B8 = Ii_0A58;
   if (Ii_0A58 < Li_F3BC) { 
   return ;
   } 
   Ls_F490 = "";
   Ls_F480 = "";
   Ls_F470 = "";
   Ls_F460 = "";
   Ls_F450 = "";
   Ls_F440 = "";
   Ls_F430 = "";
   Ls_F420 = " expired";
   Ls_F410 = (string)Fa_i_00;
   Ls_F400 = ", Magic Number: ";
   Ls_F3F0 = (string)OrderTicket();
   Ls_F3E0 = "Order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_F3D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F3D0, " ", Ls_F3E0, Ls_F3F0, Ls_F400, Ls_F410, Ls_F420, Ls_F430, Ls_F440, Ls_F450, Ls_F460, Ls_F470, Ls_F480, Ls_F490);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0A68 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0A68 > 0) { 
   FileSeek(Ii_0A68, 0, 2);
   Ls_F3C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0A68, Ls_F3C0, " VERBOSE: ", Ls_F3E0, Ls_F3F0, Ls_F400, Ls_F410, Ls_F420, Ls_F430, Ls_F440, Ls_F450, Ls_F460, Ls_F470, Ls_F480, Ls_F490);
   FileClose(Ii_0A68);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   
}

double func_1017(int Fa_i_00, int Fa_i_01, double Fa_d_02)
{
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFF8;

   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE8 = 0;
   if (Fa_i_00 == Ii_006C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0070) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0074) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0078) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_007C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0080) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0084) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0088) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_008C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0090) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0094) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0098) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_009C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_00A0) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   }}} 
   returned_double = NormalizeDouble(Ld_FFE8, _Digits);
   Ld_FFF0 = returned_double;
   Ld_FFF8 = Ld_FFF0;
   return returned_double;
}

double func_1018(int Fa_i_00, int Fa_i_01, double Fa_d_02)
{
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFF8;

   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE8 = 0;
   if (Fa_i_00 == Ii_006C) { 
   Ld_FFE8 = (Ii_004C * Id_00D0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0070) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0074) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0078) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_007C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0080) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0084) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0088) { 
   Ld_FFE8 = (Ii_004C * Id_00D0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_008C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0090) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0094) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0098) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_009C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_00A0) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Fa_d_02 + Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Fa_d_02 - Ld_FFE8);
   }}} 
   returned_double = NormalizeDouble(Ld_FFE8, _Digits);
   Ld_FFF0 = returned_double;
   Ld_FFF8 = Ld_FFF0;
   return returned_double;
}

double func_1019(int Fa_i_00, int Fa_i_01, double arg)
{
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFF8;

   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE8 = 0;
   if (Fa_i_00 == Ii_006C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0070) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0074) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0078) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_007C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0080) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0084) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0088) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_008C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0090) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0094) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0098) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_009C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_00A0) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   returned_double = NormalizeDouble(Ld_FFE8, _Digits);
   Ld_FFF0 = returned_double;
   Ld_FFF8 = Ld_FFF0;
   return returned_double;
}

double func_1020(int Fa_i_00, int Fa_i_01, double arg)
{
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFF8;

   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE8 = 0;
   if (Fa_i_00 == Ii_006C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0070) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0074) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0078) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_007C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0080) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0084) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0088) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_008C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0090) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0094) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_0098) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_009C) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   if (Fa_i_00 == Ii_00A0) { 
   Ld_FFE8 = (Id_00D0 * 0);
   if ((Ld_FFE8 > 0)) { 
   if (Fa_i_01 == 0 || Fa_i_01 == 4 || Fa_i_01 == 2) { 
   
   Ld_FFE8 = (Bid - Ld_FFE8);
   } 
   else { 
   Ld_FFE8 = (Ask + Ld_FFE8);
   }}} 
   returned_double = NormalizeDouble(Ld_FFE8, _Digits);
   Ld_FFF0 = returned_double;
   Ld_FFF8 = Ld_FFF0;
   return returned_double;
}

void func_1021(int Fa_i_00)
{
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   string Ls_FD90;
   string Ls_FD80;
   string Ls_FD70;
   string Ls_FD60;
   string Ls_FD50;
   string Ls_FD40;
   string Ls_FD30;
   string Ls_FD20;
   string Ls_FD10;
   string Ls_FD00;
   string Ls_FCF0;
   string Ls_FCE0;
   string Ls_FCD0;
   string Ls_FCC0;
   string Ls_FCB0;
   string Ls_FCA0;
   string Ls_FC90;
   string Ls_FC80;
   bool Lb_FC7F;
   int Li_FC78;

   Lb_FC7F = false;
   Li_FC78 = 0;
   Lb_FC7F = false;
   Li_FC78 = 0;
   Ii_0108 = 0;
   Ii_010C = 0;
   Ii_0930 = 0;
   Ii_0118 = 0;
   Lb_FC7F = false;
   Ls_FFF0 = "";
   Ls_FFE0 = "";
   Ls_FFD0 = "";
   Ls_FFC0 = "";
   Ls_FFB0 = "";
   Ls_FFA0 = "";
   Ls_FF90 = "";
   Ls_FF80 = "";
   Ls_FF70 = "";
   Ls_FF60 = " ----------------";
   Ls_FF50 = (string)Fa_i_00;
   Ls_FF40 = "Closing order with Magic Number: ";
   if (Ii_08EC == 1) { 
   Ls_FF30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FF30, " ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0108 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0108 > 0) { 
   FileSeek(Ii_0108, 0, 2);
   Ls_FF20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0108, Ls_FF20, " VERBOSE: ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   FileClose(Ii_0108);
   }}} 
   Li_FC78 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Li_FC78, 0, 0) == true && OrderMagicNumber() == Fa_i_00) { 
   Lb_FC7F = true;
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) { 
   
   func_1022(-1);
   } 
   else { 
   Ls_FF10 = "";
   Ls_FF00 = "";
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = "";
   Ls_FE90 = "";
   Ls_FE80 = "";
   Ls_FE70 = (string)OrderTicket();
   Ls_FE60 = "Deleting pending order with ticket: ";
   if (Ii_08EC == 1) { 
   Ls_FE50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FE50, " ", Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_010C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_010C > 0) { 
   FileSeek(Ii_010C, 0, 2);
   Ls_FE40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_010C, Ls_FE40, " VERBOSE: ", Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10);
   FileClose(Ii_010C);
   }}} 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   }} 
   Li_FC78 = Li_FC78 + 1;
   } while (Li_FC78 < OrdersTotal()); 
   } 
   if (Lb_FC7F != true) { 
   Ls_FE30 = "";
   Ls_FE20 = "";
   Ls_FE10 = "";
   Ls_FE00 = "";
   Ls_FDF0 = "";
   Ls_FDE0 = "";
   Ls_FDD0 = "";
   Ls_FDC0 = "";
   Ls_FDB0 = "";
   Ls_FDA0 = "";
   Ls_FD90 = "";
   Ls_FD80 = "Order cannot be found";
   if (Ii_08EC == 1) { 
   Ls_FD70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FD70, " ", Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20, Ls_FE30);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0930 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0930 > 0) { 
   FileSeek(Ii_0930, 0, 2);
   Ls_FD60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0930, Ls_FD60, " VERBOSE: ", Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20, Ls_FE30);
   FileClose(Ii_0930);
   }}}} 
   Ls_FD50 = "";
   Ls_FD40 = "";
   Ls_FD30 = "";
   Ls_FD20 = "";
   Ls_FD10 = "";
   Ls_FD00 = "";
   Ls_FCF0 = "";
   Ls_FCE0 = "";
   Ls_FCD0 = "";
   Ls_FCC0 = "";
   Ls_FCB0 = "";
   Ls_FCA0 = "Closing order finished ----------------";
   if (Ii_08EC == 1) { 
   Ls_FC90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FC90, " ", Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10, Ls_FD20, Ls_FD30, Ls_FD40, Ls_FD50);
   return ;
   } 
   if (Ii_08EC != 2) { 
   return ;
   } 
   Ii_0118 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0118 <= 0) { 
   return ;
   } 
   FileSeek(Ii_0118, 0, 2);
   Ls_FC80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0118, Ls_FC80, " VERBOSE: ", Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10, Ls_FD20, Ls_FD30, Ls_FD40, Ls_FD50);
   FileClose(Ii_0118);
   
}

bool func_1022(double Fa_d_00)
{
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   string Ls_FD90;
   string Ls_FD80;
   string Ls_FD70;
   string Ls_FD60;
   string Ls_FD50;
   string Ls_FD40;
   string Ls_FD30;
   string Ls_FD20;
   string Ls_FD10;
   string Ls_FD00;
   string Ls_FCF0;
   string Ls_FCE0;
   string Ls_FCD0;
   string Ls_FCC0;
   string Ls_FCB0;
   string Ls_FCA0;
   string Ls_FC90;
   string Ls_FC80;
   string Ls_FC70;
   bool Lb_FC6F;
   int Li_FC68;
   int Li_FC64;
   bool Lb_FFFF;

   Lb_FC6F = false;
   Li_FC68 = 0;
   Li_FC64 = 0;
   Lb_FC6F = false;
   Li_FC68 = 0;
   Li_FC64 = 0;
   Ii_0108 = 0;
   Ii_010C = 0;
   Ii_0930 = 0;
   Ii_0118 = 0;
   Ii_011C = 0;
   Ii_0934 = 0;
   Ii_0124 = 0;
   Ii_0128 = 0;
   Ls_FFF0 = "";
   Ls_FFE0 = "";
   Ls_FFD0 = "";
   Ls_FFC0 = "";
   Ls_FFB0 = "";
   Ls_FFA0 = "";
   Ls_FF90 = "";
   Ls_FF80 = " at market price";
   Ls_FF70 = (string)OrderTicket();
   Ls_FF60 = ", ticket: ";
   Ls_FF50 = (string)OrderMagicNumber();
   Ls_FF40 = "Closing order with Magic Number: ";
   if (Ii_08EC == 1) { 
   Ls_FF30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FF30, " ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0108 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0108 > 0) { 
   FileSeek(Ii_0108, 0, 2);
   Ls_FF20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0108, Ls_FF20, " VERBOSE: ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   FileClose(Ii_0108);
   }}} 
   Li_FC68 = 0;
   Li_FC64 = 3;
   do { 
   Li_FC64 = Li_FC64 - 1;
   if (Li_FC64 < 0) { 
   Lb_FC6F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Ii_0930 = 30;
   Ii_010C = 1;
   if (!IsTradeAllowed()) {
   Gi_0000 = (int)GetTickCount();
   Ii_0118 = Gi_0000;
   Print("Trade context is busy! Wait until it is free...");
   do { 
   if (_StopFlag != 0) {
   Print("The expert was terminated by the user!");
   Ii_010C = -1;
   break;
   }
   Gi_0000 = (int)GetTickCount();
   Ii_012C = Gi_0000 - Ii_0118;
   Ii_011C = Ii_012C;
   Ii_012C = Ii_0930 * 1000;
   if (Ii_011C > Ii_012C) {
   Ls_FF10 = (string)Ii_0930;
   Ls_FF10 = "The waiting limit exceeded (" + Ls_FF10;
   Ls_FF10 = Ls_FF10 + " ???.)!";
   Print(Ls_FF10);
   Ii_010C = -2;
   break;
   }
   if (IsTradeAllowed()) {
   Print("Trade context has become free!");
   RefreshRates();
   Ii_010C = 1;
   break;
   }
   Sleep(100);
   } while (true); 
   }
   else Ii_010C = 1;
   
   if (Ii_010C == 1) { 
   Ls_FF00 = "";
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = "";
   Ls_FE90 = "";
   Ls_FE80 = "";
   Ls_FE70 = "";
   Ii_012C = 3 - Li_FC64;
   Ls_FE60 = (string)Ii_012C;
   Ls_FE50 = "Closing retry #";
   if (Ii_08EC == 1) { 
   Ls_FE40 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FE40, " ", Ls_FE50, Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0934 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0934 > 0) { 
   FileSeek(Ii_0934, 0, 2);
   Ls_FE30 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0934, Ls_FE30, " VERBOSE: ", Ls_FE50, Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00);
   FileClose(Ii_0934);
   }}} 
   if (func_1023(Fa_d_00)) { 
   Ls_FE20 = "";
   Ls_FE10 = "";
   Ls_FE00 = "";
   Ls_FDF0 = "";
   Ls_FDE0 = "";
   Ls_FDD0 = "";
   Ls_FDC0 = "";
   Ls_FDB0 = " successfuly closed";
   Ls_FDA0 = (string)OrderTicket();
   Ls_FD90 = ", ticket: ";
   Ls_FD80 = (string)OrderMagicNumber();
   Ls_FD70 = "Order with Magic Number: ";
   if (Ii_08EC == 1) { 
   Ls_FD60 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FD60, " ", Ls_FD70, Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0124 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0124 > 0) { 
   FileSeek(Ii_0124, 0, 2);
   Ls_FD50 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0124, Ls_FD50, " VERBOSE: ", Ls_FD70, Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20);
   FileClose(Ii_0124);
   }}} 
   Lb_FC6F = true;
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   Gi_0000 = GetLastError();
   Ii_012C = Gi_0000;
   Li_FC68 = Gi_0000;
   Ls_FD40 = "";
   Ls_FD30 = "";
   Ls_FD20 = "";
   Ls_FD10 = "";
   Ls_FD00 = "";
   Ls_FCF0 = "";
   Ls_FCE0 = "";
   Ls_FCD0 = "";
   Ls_FCC0 = func_1032(Gi_0000);
   Ls_FCB0 = " - ";
   Ls_FCA0 = (string)Ii_012C;
   Ls_FC90 = "Closing order failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_FC80 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FC80, " ", Ls_FC90, Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10, Ls_FD20, Ls_FD30, Ls_FD40);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0128 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0128 > 0) { 
   FileSeek(Ii_0128, 0, 2);
   Ls_FC70 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0128, Ls_FC70, " VERBOSE: ", Ls_FC90, Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10, Ls_FD20, Ls_FD30, Ls_FD40);
   FileClose(Ii_0128);
   }}}} 
   Sleep(500);
   } while (true); 
}

bool func_1023(double Fa_d_00)
{
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   bool Lb_FE1F;
   double Ld_FE10;
   bool Lb_FFFF;

   Lb_FE1F = false;
   Ld_FE10 = 0;
   Lb_FE1F = false;
   Ld_FE10 = 0;
   Id_00E0 = 0;
   Id_0928 = 0;
   Ii_0930 = 0;
   Ii_0118 = 0;
   RefreshRates();
   Ld_FE10 = 0;
   if (OrderType() != OP_BUY && OrderType() != OP_SELL) { 
   Lb_FE1F = true;
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   if (OrderType() == OP_BUY) { 
   Ls_FFF0 = OrderSymbol();
   if (Ls_FFF0 == "NULL") { 
   Id_00E0 = Bid;
   } 
   else { 
   Id_00E0 = MarketInfo(Ls_FFF0, MODE_BID);
   } 
   Ld_FE10 = Id_00E0;
   } 
   else { 
   Ls_FFE0 = OrderSymbol();
   if (Ls_FFE0 == "NULL") { 
   Id_0928 = Ask;
   } 
   else { 
   Id_0928 = MarketInfo(Ls_FFE0, MODE_ASK);
   } 
   Ld_FE10 = Id_0928;
   } 
   if ((Fa_d_00 <= 0)) { 
   Ls_FFD0 = "";
   Ls_FFC0 = "";
   Ls_FFB0 = "";
   Ls_FFA0 = "";
   Ls_FF90 = "";
   Ls_FF80 = "";
   Ls_FF70 = "";
   Ls_FF60 = "";
   Ls_FF50 = (string)OrderLots();
   Ls_FF40 = ", closing size: ";
   Ls_FF30 = (string)Ld_FE10;
   Ls_FF20 = "Closing Market price: ";
   if (Ii_08EC == 1) { 
   Ls_FF10 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FF10, " ", Ls_FF20, Ls_FF30, Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0930 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0930 > 0) { 
   FileSeek(Ii_0930, 0, 2);
   Ls_FF00 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0930, Ls_FF00, " VERBOSE: ", Ls_FF20, Ls_FF30, Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0);
   FileClose(Ii_0930);
   }}} 
   Lb_FE1F = OrderClose(OrderTicket(), OrderLots(), Ld_FE10, Ii_08E8, 4294967295);
   Lb_FFFF = Lb_FE1F;
   return Lb_FFFF;
   } 
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = "";
   Ls_FE90 = "";
   Ls_FE80 = "";
   Ls_FE70 = (string)Fa_d_00;
   Ls_FE60 = ", closing size: ";
   Ls_FE50 = (string)Ld_FE10;
   Ls_FE40 = "Closing Market price: ";
   if (Ii_08EC == 1) { 
   Ls_FE30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FE30, " ", Ls_FE40, Ls_FE50, Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0118 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0118 > 0) { 
   FileSeek(Ii_0118, 0, 2);
   Ls_FE20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0118, Ls_FE20, " VERBOSE: ", Ls_FE40, Ls_FE50, Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0);
   FileClose(Ii_0118);
   }}} 
   Lb_FE1F = OrderClose(OrderTicket(), Fa_d_00, Ld_FE10, Ii_08E8, 4294967295);
   Lb_FFFF = Lb_FE1F;
   
   return Lb_FFFF;
}

bool func_1024(string Fa_s_00, int Fa_i_01, double Fa_d_02, double Fa_d_03, string Fa_s_04, int Fa_i_05, string Fa_s_06)
{
   string tmp_str0000;
   string tmp_str0001;
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   string Ls_FD90;
   string Ls_FD80;
   string Ls_FD70;
   string Ls_FD60;
   string Ls_FD50;
   string Ls_FD40;
   string Ls_FD30;
   string Ls_FD20;
   string Ls_FD10;
   string Ls_FD00;
   string Ls_FCF0;
   string Ls_FCE0;
   string Ls_FCD0;
   string Ls_FCC0;
   string Ls_FCB0;
   string Ls_FCA0;
   string Ls_FC90;
   string Ls_FC80;
   string Ls_FC70;
   string Ls_FC60;
   string Ls_FC50;
   string Ls_FC40;
   string Ls_FC30;
   string Ls_FC20;
   string Ls_FC10;
   string Ls_FC00;
   string Ls_FBF0;
   string Ls_FBE0;
   string Ls_FBD0;
   string Ls_FBC0;
   string Ls_FBB0;
   string Ls_FBA0;
   string Ls_FB90;
   string Ls_FB80;
   string Ls_FB70;
   string Ls_FB60;
   string Ls_FB50;
   string Ls_FB40;
   string Ls_FB30;
   string Ls_FB20;
   string Ls_FB10;
   string Ls_FB00;
   string Ls_FAF0;
   string Ls_FAE0;
   string Ls_FAD0;
   string Ls_FAC0;
   string Ls_FAB0;
   string Ls_FAA0;
   string Ls_FA90;
   string Ls_FA80;
   string Ls_FA70;
   string Ls_FA60;
   string Ls_FA50;
   string Ls_FA40;
   string Ls_FA30;
   string Ls_FA20;
   string Ls_FA10;
   string Ls_FA00;
   string Ls_F9F0;
   string Ls_F9E0;
   string Ls_F9D0;
   string Ls_F9C0;
   string Ls_F9B0;
   string Ls_F9A0;
   string Ls_F990;
   string Ls_F980;
   string Ls_F970;
   string Ls_F960;
   string Ls_F950;
   string Ls_F940;
   string Ls_F930;
   string Ls_F920;
   string Ls_F910;
   string Ls_F900;
   string Ls_F8F0;
   string Ls_F8E0;
   string Ls_F8D0;
   string Ls_F8C0;
   string Ls_F8B0;
   string Ls_F8A0;
   string Ls_F890;
   string Ls_F880;
   string Ls_F870;
   string Ls_F860;
   string Ls_F850;
   string Ls_F840;
   string Ls_F830;
   string Ls_F820;
   string Ls_F810;
   string Ls_F800;
   string Ls_F7F0;
   string Ls_F7E0;
   string Ls_F7D0;
   string Ls_F7C0;
   string Ls_F7B0;
   string Ls_F7A0;
   string Ls_F790;
   string Ls_F780;
   string Ls_F770;
   string Ls_F760;
   string Ls_F750;
   string Ls_F740;
   string Ls_F730;
   string Ls_F720;
   string Ls_F710;
   string Ls_F700;
   string Ls_F6F0;
   string Ls_F6E0;
   string Ls_F6D0;
   string Ls_F6C0;
   string Ls_F6B0;
   string Ls_F6A0;
   string Ls_F690;
   string Ls_F680;
   string Ls_F670;
   string Ls_F660;
   string Ls_F650;
   string Ls_F640;
   string Ls_F630;
   string Ls_F620;
   string Ls_F610;
   string Ls_F600;
   string Ls_F5F0;
   string Ls_F5E0;
   string Ls_F5D0;
   string Ls_F5C0;
   string Ls_F5B0;
   string Ls_F5A0;
   string Ls_F590;
   string Ls_F580;
   string Ls_F570;
   string Ls_F560;
   string Ls_F550;
   string Ls_F540;
   string Ls_F530;
   string Ls_F520;
   string Ls_F510;
   string Ls_F500;
   string Ls_F4F0;
   string Ls_F4E0;
   string Ls_F4D0;
   string Ls_F4C0;
   string Ls_F4B0;
   string Ls_F4A0;
   string Ls_F490;
   string Ls_F480;
   string Ls_F470;
   string Ls_F460;
   string Ls_F450;
   string Ls_F440;
   bool Lb_F43F;
   int Li_F438;
   double Ld_F430;
   double Ld_F428;
   double Ld_F420;
   int Li_F41C;
   bool Lb_FFFF;

   Lb_F43F = false;
   Li_F438 = 0;
   Ld_F430 = 0;
   Ld_F428 = 0;
   Ld_F420 = 0;
   Li_F41C = 0;
   Lb_F43F = false;
   Li_F438 = 0;
   Ld_F430 = 0;
   Ld_F428 = 0;
   Ld_F420 = 0;
   Li_F41C = 0;
   Ii_0108 = 0;
   Ii_010C = 0;
   Ib_1928 = false;
   Ii_0118 = 0;
   Ii_011C = 0;
   Ii_0934 = 0;
   Ii_0124 = 0;
   Ib_1929 = false;
   Ii_012C = 0;
   Ii_0940 = 0;
   Ii_0944 = 0;
   Ib_192A = false;
   Ii_0948 = 0;
   Ii_0150 = 0;
   Ii_0958 = 0;
   Ii_192C = 0;
   Id_1930 = 0;
   Id_0170 = 0;
   Ii_0178 = 0;
   Id_0180 = 0;
   Ii_0188 = 0;
   Id_0190 = 0;
   Ii_097C = 0;
   Ii_01A0 = 0;
   Ii_0980 = 0;
   Ii_0984 = 0;
   Ii_01B8 = 0;
   Ii_0990 = 0;
   Ii_01C8 = 0;
   Ii_0994 = 0;
   Ii_01D8 = 0;
   Ii_0998 = 0;
   Ii_17E0 = 0;
   Ii_01F0 = 0;
   Li_F438 = 0;
   Ls_FFF0 = "";
   Ls_FFE0 = " ----------------";
   Ls_FFD0 = Fa_s_04;
   Ls_FFC0 = ", comment: ";
   Ls_FFB0 = (string)Fa_d_02;
   Ls_FFA0 = ", lots: ";
   Ls_FF90 = (string)Fa_d_03;
   Ls_FF80 = ", price: ";
   Ls_FF70 = func_1030(Fa_i_01);
   Ls_FF60 = ", type: ";
   Ls_FF50 = (string)Fa_i_05;
   Ls_FF40 = "Opening order with MagicNumber: ";
   if (Ii_08EC == 1) { 
   Ls_FF30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FF30, " ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0108 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0108 > 0) { 
   FileSeek(Ii_0108, 0, 2);
   Ls_FF20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0108, Ls_FF20, " VERBOSE: ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   FileClose(Ii_0108);
   }}} 
   Ls_FF10 = "";
   Ls_FF00 = "";
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = "";
   Ls_FE90 = (string)Bid;
   Ls_FE80 = ", Bid: ";
   Ls_FE70 = (string)Ask;
   Ls_FE60 = "Current Ask: ";
   if (Ii_08EC == 1) { 
   Ls_FE50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FE50, " ", Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_010C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_010C > 0) { 
   FileSeek(Ii_010C, 0, 2);
   Ls_FE40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_010C, Ls_FE40, " VERBOSE: ", Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10);
   FileClose(Ii_010C);
   }}} 
   Il_09A0 = TimeCurrent();
   Il_1938 = Ii_0920;
   Il_1938 = Il_09A0 - Il_1938;
   if (Il_1938 < 600) { 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Ii_0118 = Fa_i_05;
   Ii_09A8 = OrdersTotal() - 1;
   Ii_011C = Ii_09A8;
   Ib_1928 = false;
   if (Ii_09A8 >= 0) {
   do { 
   if (OrderSelect(Ii_011C, 0, 0) && OrderMagicNumber() == Ii_0118 && OrderSymbol() == _Symbol) {
   if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
   
   Ib_1928 = true;
   break;
   }}
   Ii_011C = Ii_011C - 1;
   } while (Ii_011C >= 0); 
   }
   else{
   Ib_1928 = false;
   }
   if (Ib_1928) { 
   Ls_FE30 = "";
   Ls_FE20 = "";
   Ls_FE10 = "";
   Ls_FE00 = "";
   Ls_FDF0 = "";
   Ls_FDE0 = "";
   Ls_FDD0 = "";
   Ls_FDC0 = "";
   Ls_FDB0 = "";
   Ls_FDA0 = " already exists, cannot open another one!";
   Ls_FD90 = (string)Fa_i_05;
   Ls_FD80 = "Order with magic number: ";
   if (Ii_08EC == 1) { 
   Ls_FD70 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FD70, " ", Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20, Ls_FE30);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0934 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0934 > 0) { 
   FileSeek(Ii_0934, 0, 2);
   Ls_FD60 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0934, Ls_FD60, " VERBOSE: ", Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20, Ls_FE30);
   FileClose(Ii_0934);
   }}} 
   Ls_FD50 = "";
   Ls_FD40 = "";
   Ls_FD30 = "";
   Ls_FD20 = "";
   Ls_FD10 = "";
   Ls_FD00 = "";
   Ls_FCF0 = "";
   Ls_FCE0 = "";
   Ls_FCD0 = "";
   Ls_FCC0 = "";
   Ls_FCB0 = "";
   Ls_FCA0 = "----------------------------------";
   if (Ii_08EC == 1) { 
   Ls_FC90 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FC90, " ", Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10, Ls_FD20, Ls_FD30, Ls_FD40, Ls_FD50);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0124 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0124 > 0) { 
   FileSeek(Ii_0124, 0, 2);
   Ls_FC80 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0124, Ls_FC80, " VERBOSE: ", Ls_FCA0, Ls_FCB0, Ls_FCC0, Ls_FCD0, Ls_FCE0, Ls_FCF0, Ls_FD00, Ls_FD10, Ls_FD20, Ls_FD30, Ls_FD40, Ls_FD50);
   FileClose(Ii_0124);
   }}} 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Ii_012C = Fa_i_05;
   Ii_09A8 = OrdersTotal() - 1;
   Ii_0940 = Ii_09A8;
   Ib_1929 = false;
   if (Ii_09A8 >= 0) {
   do { 
   if (OrderSelect(Ii_0940, 0, 0) && OrderMagicNumber() == Ii_012C 
   && OrderSymbol() == _Symbol && OrderType() != OP_BUY && OrderType() != OP_SELL) {
   Ib_1929 = true;
   break;
   }
   Ii_0940 = Ii_0940 - 1;
   } while (Ii_0940 >= 0); 
   }
   else{
   Ib_1929 = false;
   }
   if (Ib_1929) { 
   Ii_0944 = Fa_i_05;
   Ib_192A = false;
   if (Fa_i_05 == Ii_006C) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0070) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0074) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0078) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_007C) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0080) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0084) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0088) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_008C) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0090) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0094) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_0098) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_009C) { 
   Ib_192A = false;
   } 
   if (Ii_0944 == Ii_00A0) { 
   Ib_192A = false;
   } 
   if (Ib_192A != true) { 
   Ls_FC70 = "";
   Ls_FC60 = "";
   Ls_FC50 = "";
   Ls_FC40 = "";
   Ls_FC30 = "";
   Ls_FC20 = "";
   Ls_FC10 = "";
   Ls_FC00 = "";
   Ls_FBF0 = " ----------------";
   Ls_FBE0 = " already exists, and replace is not allowed!";
   Ls_FBD0 = (string)Fa_i_05;
   Ls_FBC0 = "Pending Order with magic number: ";
   if (Ii_08EC == 1) { 
   Ls_FBB0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FBB0, " ", Ls_FBC0, Ls_FBD0, Ls_FBE0, Ls_FBF0, Ls_FC00, Ls_FC10, Ls_FC20, Ls_FC30, Ls_FC40, Ls_FC50, Ls_FC60, Ls_FC70);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0948 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0948 > 0) { 
   FileSeek(Ii_0948, 0, 2);
   Ls_FBA0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0948, Ls_FBA0, " VERBOSE: ", Ls_FBC0, Ls_FBD0, Ls_FBE0, Ls_FBF0, Ls_FC00, Ls_FC10, Ls_FC20, Ls_FC30, Ls_FC40, Ls_FC50, Ls_FC60, Ls_FC70);
   FileClose(Ii_0948);
   }}} 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Ls_FB90 = "";
   Ls_FB80 = "";
   Ls_FB70 = "";
   Ls_FB60 = "";
   Ls_FB50 = "";
   Ls_FB40 = "";
   Ls_FB30 = "";
   Ls_FB20 = "";
   Ls_FB10 = "";
   Ls_FB00 = "";
   Ls_FAF0 = "";
   Ls_FAE0 = "Deleting previous pending order";
   if (Ii_08EC == 1) { 
   Ls_FAD0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FAD0, " ", Ls_FAE0, Ls_FAF0, Ls_FB00, Ls_FB10, Ls_FB20, Ls_FB30, Ls_FB40, Ls_FB50, Ls_FB60, Ls_FB70, Ls_FB80, Ls_FB90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0150 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0150 > 0) { 
   FileSeek(Ii_0150, 0, 2);
   Ls_FAC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0150, Ls_FAC0, " VERBOSE: ", Ls_FAE0, Ls_FAF0, Ls_FB00, Ls_FB10, Ls_FB20, Ls_FB30, Ls_FB40, Ls_FB50, Ls_FB60, Ls_FB70, Ls_FB80, Ls_FB90);
   FileClose(Ii_0150);
   }}} 
   Ii_0958 = Fa_i_05;
   Ii_192C = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Ii_192C, 0, 0) == true && OrderMagicNumber() == Ii_0958 && OrderSymbol() == _Symbol) { 
   Ib_38F8 = OrderDelete(OrderTicket(), 4294967295);
   break; 
   } 
   Ii_192C = Ii_192C + 1;
   } while (Ii_192C < OrdersTotal()); 
   }} 
   RefreshRates();
   if (Fa_i_01 == 4 || Fa_i_01 == 5) { 
   
   Ld_F430 = 0;
   if (Fa_i_01 == 4) { 
   Ls_FAB0 = Fa_s_00;
   if (Ls_FAB0 == "NULL") { 
   Id_1930 = Ask;
   } 
   else { 
   Id_1930 = MarketInfo(Ls_FAB0, MODE_ASK);
   } 
   Ld_F430 = Id_1930;
   } 
   else { 
   Ls_FAA0 = Fa_s_00;
   if (Ls_FAA0 == "NULL") { 
   Id_0170 = Bid;
   } 
   else { 
   Id_0170 = MarketInfo(Ls_FAA0, MODE_BID);
   } 
   Ld_F430 = Id_0170;
   } 
   Id_0200 = NormalizeDouble(fabs((Fa_d_03 - Ld_F430)), _Digits);
   Ii_0178 = Fa_i_05;
   Id_0180 = 0;
   if (Fa_i_05 == Ii_006C) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0070) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0074) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0078) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_007C) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0080) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0084) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0088) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_008C) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0090) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0094) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_0098) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_009C) { 
   Id_0180 = 0;
   } 
   if (Ii_0178 == Ii_00A0) { 
   Id_0180 = 0;
   } 
   Gi_0000 = _Digits;
   if ((Id_0200 <= NormalizeDouble((NormalizeDouble(Id_0180, Gi_0000) / Id_00C0), Gi_0000))) { 
   Ls_FA90 = "";
   Ls_FA80 = "";
   Ls_FA70 = "";
   Ls_FA60 = "";
   Ls_FA50 = "";
   Ls_FA40 = "";
   Ls_FA30 = "";
   Ls_FA20 = "";
   Ls_FA10 = "";
   Ls_FA00 = "";
   Ls_F9F0 = " ----------------";
   Ls_F9E0 = "Stop/limit order is too close to actual price";
   if (Ii_08EC == 1) { 
   Ls_F9D0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F9D0, " ", Ls_F9E0, Ls_F9F0, Ls_FA00, Ls_FA10, Ls_FA20, Ls_FA30, Ls_FA40, Ls_FA50, Ls_FA60, Ls_FA70, Ls_FA80, Ls_FA90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0188 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0188 > 0) { 
   FileSeek(Ii_0188, 0, 2);
   Ls_F9C0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0188, Ls_F9C0, " VERBOSE: ", Ls_F9E0, Ls_F9F0, Ls_FA00, Ls_FA10, Ls_FA20, Ls_FA30, Ls_FA40, Ls_FA50, Ls_FA60, Ls_FA70, Ls_FA80, Ls_FA90);
   FileClose(Ii_0188);
   }}} 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   }} 
   Ld_F428 = func_1017(Fa_i_05, Fa_i_01, Fa_d_03);
   Ld_F420 = func_1018(Fa_i_05, Fa_i_01, Fa_d_03);
   Li_F41C = 3;
   do { 
   Li_F41C = Li_F41C - 1;
   if (Li_F41C < 0) { 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Ii_097C = Fa_i_05;
   Ii_09AC = OrdersTotal() - 1;
   Ii_01A0 = Ii_09AC;
   Id_0190 = 0;
   if (Ii_09AC >= 0) {
   do { 
   if (OrderSelect(Ii_01A0, 0, 0)) {
   if ((Ii_097C == 0 && OrderSymbol() == _Symbol)
   || OrderMagicNumber() == Ii_097C) {
   
   if (OrderType() == OP_BUY) {
   Id_0190 = 1;
   break;
   }
   if (OrderType() == OP_SELL) {
   Id_0190 = -1;
   break;
   }}}
   Ii_01A0 = Ii_01A0 - 1;
   } while (Ii_01A0 >= 0); 
   }
   else{
   Id_0190 = 0;
   }
   if ((Id_0190 != 0)) { 
   Ls_F9B0 = "";
   Ls_F9A0 = "";
   Ls_F990 = "";
   Ls_F980 = "";
   Ls_F970 = "";
   Ls_F960 = "";
   Ls_F950 = "";
   Ls_F940 = "";
   Ls_F930 = "";
   Ls_F920 = "";
   Ls_F910 = " ----------------";
   Ls_F900 = "Order already opened";
   if (Ii_08EC == 1) { 
   Ls_F8F0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F8F0, " ", Ls_F900, Ls_F910, Ls_F920, Ls_F930, Ls_F940, Ls_F950, Ls_F960, Ls_F970, Ls_F980, Ls_F990, Ls_F9A0, Ls_F9B0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0980 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0980 > 0) { 
   FileSeek(Ii_0980, 0, 2);
   Ls_F8E0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0980, Ls_F8E0, " VERBOSE: ", Ls_F900, Ls_F910, Ls_F920, Ls_F930, Ls_F940, Ls_F950, Ls_F960, Ls_F970, Ls_F980, Ls_F990, Ls_F9A0, Ls_F9B0);
   FileClose(Ii_0980);
   }}} 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Ii_01B8 = 30;
   Ii_0984 = 1;
   if (!IsTradeAllowed()) {
   GetTickCount();
   Gi_0001 = returned_i;
   Ii_0990 = Gi_0001;
   Print("Trade context is busy! Wait until it is free...");
   do { 
   if (_StopFlag != 0) {
   Print("The expert was terminated by the user!");
   Ii_0984 = -1;
   break;
   }
   Gi_0001 = (int)GetTickCount();
   Ii_09AC = Gi_0001 - Ii_0990;
   Ii_01C8 = Ii_09AC;
   Ii_09AC = Ii_01B8 * 1000;
   if (Ii_01C8 > Ii_09AC) {
   Ls_F8D0 = (string)Ii_01B8;
   Ls_F8D0 = "The waiting limit exceeded (" + Ls_F8D0;
   Ls_F8D0 = Ls_F8D0 + " ???.)!";
   Print(Ls_F8D0);
   Ii_0984 = -2;
   break;
   }
   if (IsTradeAllowed()) {
   Print("Trade context has become free!");
   RefreshRates();
   Ii_0984 = 1;
   break;
   }
   Sleep(100);
   } while (true); 
   }
   else Ii_0984 = 1;
   
   if (Ii_0984 == 1) { 
   Ls_F8C0 = "";
   Ls_F8B0 = "";
   Ls_F8A0 = "";
   Ls_F890 = "";
   Ls_F880 = "";
   Ls_F870 = "";
   Ls_F860 = "";
   Ls_F850 = "";
   Ls_F840 = "";
   Ls_F830 = "";
   Ii_09AC = 3 - Li_F41C;
   Ls_F820 = (string)Ii_09AC;
   Ls_F810 = "Opening, try #";
   if (Ii_08EC == 1) { 
   Ls_F800 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F800, " ", Ls_F810, Ls_F820, Ls_F830, Ls_F840, Ls_F850, Ls_F860, Ls_F870, Ls_F880, Ls_F890, Ls_F8A0, Ls_F8B0, Ls_F8C0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0994 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0994 > 0) { 
   FileSeek(Ii_0994, 0, 2);
   Ls_F7F0 = TimeToString(TimeCurrent(), 3);
   FileClose(Ii_0994);
   }}} 
   Ls_F7E0 = Fa_s_04;
   Ls_F7D0 = Fa_s_00;
   tmp_str0000 = Ls_F7E0;
   tmp_str0001 = Ls_F7D0;
   func_1025(tmp_str0001, Fa_i_01, Fa_d_02, Fa_d_03, Ld_F428, Ld_F420, tmp_str0000, Fa_i_05);
   Li_F438 = (int)FileWrite(Ii_0994, Ls_F7F0, " VERBOSE: ", Ls_F810, Ls_F820, Ls_F830, Ls_F840, Ls_F850, Ls_F860, Ls_F870, Ls_F880, Ls_F890, Ls_F8A0, Ls_F8B0, Ls_F8C0);
   if (Li_F438 > 0) { 
   Ls_F7C0 = "";
   Ls_F7B0 = "";
   Ls_F7A0 = "";
   Ls_F790 = "";
   Ls_F780 = "";
   Ls_F770 = "";
   Ls_F760 = "";
   Ls_F750 = "";
   Ls_F740 = "";
   Ls_F730 = "";
   Ls_F720 = " ----------------";
   Ls_F710 = "Trade successfuly opened";
   if (Ii_08EC == 1) { 
   Ls_F700 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F700, " ", Ls_F710, Ls_F720, Ls_F730, Ls_F740, Ls_F750, Ls_F760, Ls_F770, Ls_F780, Ls_F790, Ls_F7A0, Ls_F7B0, Ls_F7C0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_01D8 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_01D8 > 0) { 
   FileSeek(Ii_01D8, 0, 2);
   Ls_F6F0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_01D8, Ls_F6F0, " VERBOSE: ", Ls_F710, Ls_F720, Ls_F730, Ls_F740, Ls_F750, Ls_F760, Ls_F770, Ls_F780, Ls_F790, Ls_F7A0, Ls_F7B0, Ls_F7C0);
   FileClose(Ii_01D8);
   }}} 
   Ls_F6E0 = "Last Signal: " + Fa_s_06;
   ObjectSetText("lines", Ls_F6E0, 8, "Tahoma", Ii_0104);
   Lb_F43F = true;
   Lb_FFFF = true;
   return Lb_FFFF;
   }} 
   if (Li_F438 == -130) { 
   Ls_F6D0 = "";
   Ls_F6C0 = "";
   Ls_F6B0 = "";
   Ls_F6A0 = "";
   Ls_F690 = "";
   Ls_F680 = "";
   Ls_F670 = "";
   Ls_F660 = "";
   Ls_F650 = "";
   Ls_F640 = "";
   Ls_F630 = " ----------------";
   Ls_F620 = "Invalid stops, cannot open the trade";
   if (Ii_08EC == 1) { 
   Ls_F610 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F610, " ", Ls_F620, Ls_F630, Ls_F640, Ls_F650, Ls_F660, Ls_F670, Ls_F680, Ls_F690, Ls_F6A0, Ls_F6B0, Ls_F6C0, Ls_F6D0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0998 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0998 > 0) { 
   FileSeek(Ii_0998, 0, 2);
   Ls_F600 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0998, Ls_F600, " VERBOSE: ", Ls_F620, Ls_F630, Ls_F640, Ls_F650, Ls_F660, Ls_F670, Ls_F680, Ls_F690, Ls_F6A0, Ls_F6B0, Ls_F6C0, Ls_F6D0);
   FileClose(Ii_0998);
   }}} 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   if (Li_F438 == -131) { 
   Ls_F5F0 = "";
   Ls_F5E0 = "";
   Ls_F5D0 = "";
   Ls_F5C0 = "";
   Ls_F5B0 = "";
   Ls_F5A0 = "";
   Ls_F590 = "";
   Ls_F580 = "";
   Ls_F570 = "";
   Ls_F560 = "";
   Ls_F550 = " ----------------";
   Ls_F540 = "Invalid volume, cannot open the trade";
   if (Ii_08EC == 1) { 
   Ls_F530 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F530, " ", Ls_F540, Ls_F550, Ls_F560, Ls_F570, Ls_F580, Ls_F590, Ls_F5A0, Ls_F5B0, Ls_F5C0, Ls_F5D0, Ls_F5E0, Ls_F5F0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_17E0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_17E0 > 0) { 
   FileSeek(Ii_17E0, 0, 2);
   Ls_F520 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_17E0, Ls_F520, " VERBOSE: ", Ls_F540, Ls_F550, Ls_F560, Ls_F570, Ls_F580, Ls_F590, Ls_F5A0, Ls_F5B0, Ls_F5C0, Ls_F5D0, Ls_F5E0, Ls_F5F0);
   FileClose(Ii_17E0);
   }}} 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   if (Li_F438 == -11111) { 
   Ls_F510 = "";
   Ls_F500 = "";
   Ls_F4F0 = "";
   Ls_F4E0 = "";
   Ls_F4D0 = "";
   Ls_F4C0 = "";
   Ls_F4B0 = "";
   Ls_F4A0 = "";
   Ls_F490 = "";
   Ls_F480 = "";
   Ls_F470 = " ----------------";
   Ls_F460 = "Trade opened, but cannot set SL/PT, closing trade";
   if (Ii_08EC == 1) { 
   Ls_F450 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_F450, " ", Ls_F460, Ls_F470, Ls_F480, Ls_F490, Ls_F4A0, Ls_F4B0, Ls_F4C0, Ls_F4D0, Ls_F4E0, Ls_F4F0, Ls_F500, Ls_F510);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_01F0 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_01F0 > 0) { 
   FileSeek(Ii_01F0, 0, 2);
   Ls_F440 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_01F0, Ls_F440, " VERBOSE: ", Ls_F460, Ls_F470, Ls_F480, Ls_F490, Ls_F4A0, Ls_F4B0, Ls_F4C0, Ls_F4D0, Ls_F4E0, Ls_F4F0, Ls_F500, Ls_F510);
   FileClose(Ii_01F0);
   }}} 
   Lb_F43F = false;
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   Sleep(1000);
   } while (true); 
}

int func_1025(string Fa_s_00, int Fa_i_01, double Fa_d_02, double Fa_d_03, double Fa_d_04, double Fa_d_05, string Fa_s_06, int Fa_i_07)
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
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   string Ls_FD90;
   string Ls_FD80;
   string Ls_FD70;
   string Ls_FD60;
   string Ls_FD50;
   string Ls_FD40;
   string Ls_FD30;
   string Ls_FD20;
   string Ls_FD10;
   string Ls_FD00;
   string Ls_FCF0;
   string Ls_FCE0;
   string Ls_FCD0;
   string Ls_FCC0;
   string Ls_FCB0;
   string Ls_FCA0;
   string Ls_FC90;
   string Ls_FC80;
   string Ls_FC70;
   string Ls_FC60;
   string Ls_FC50;
   string Ls_FC40;
   string Ls_FC30;
   string Ls_FC20;
   string Ls_FC10;
   string Ls_FC00;
   string Ls_FBF0;
   string Ls_FBE0;
   string Ls_FBD0;
   string Ls_FBC0;
   string Ls_FBB0;
   int Li_FBAC;
   int Li_FBA8;
   int Li_FBA4;
   double Ld_FB98;
   double Ld_FB90;
   int Li_FB8C;
   int Li_FFFC;

   Li_FBAC = 0;
   Li_FBA8 = 0;
   Li_FBA4 = 0;
   Ld_FB98 = 0;
   Ld_FB90 = 0;
   Li_FB8C = 0;
   Li_FBAC = 0;
   Li_FBA8 = 0;
   Li_FBA4 = 0;
   Ld_FB98 = 0;
   Ld_FB90 = 0;
   Li_FB8C = 0;
   Ii_0108 = 0;
   Ii_010C = 0;
   Ii_0930 = 0;
   Ii_0118 = 0;
   Ii_011C = 0;
   Ii_0934 = 0;
   Ii_0124 = 0;
   Li_FBA8 = 0;
   Li_FBA4 = 0;
   Ls_FFF0 = "";
   Ls_FFE0 = "";
   Ls_FFD0 = "";
   Ls_FFC0 = "";
   Ls_FFB0 = "";
   Ls_FFA0 = "";
   Ls_FF90 = "";
   Ls_FF80 = "";
   Ls_FF70 = "";
   Ls_FF60 = "";
   Ls_FF50 = "";
   Ls_FF40 = "Sending order...";
   if (Ii_08EC == 1) { 
   Ls_FF30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FF30, " ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0108 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0108 > 0) { 
   FileSeek(Ii_0108, 0, 2);
   Ls_FF20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0108, Ls_FF20, " VERBOSE: ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   FileClose(Ii_0108);
   }}} 
   Ld_FB98 = Fa_d_04;
   Ld_FB90 = Fa_d_05;
   if (Ib_08F0) { 
   Ld_FB98 = 0;
   Ld_FB90 = 0;
   } 
   if (Fa_s_00 == "NULL") { 
   Li_FBA8 = OrderSend(_Symbol, Fa_i_01, Fa_d_02, Fa_d_03, Ii_08E8, Ld_FB98, Ld_FB90, Fa_s_06, Fa_i_07, 0, 4294967295);
   } 
   else { 
   Li_FBA8 = OrderSend(Fa_s_00, Fa_i_01, Fa_d_02, Fa_d_03, Ii_08E8, Ld_FB98, Ld_FB90, Fa_s_06, Fa_i_07, 0, 4294967295);
   } 
   if (Li_FBA8 < 0) { 
   Gi_0000 = GetLastError();
   Ii_0128 = Gi_0000;
   Li_FBA4 = Gi_0000;
   Ls_FF10 = "";
   Ls_FF00 = "";
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = "";
   Ls_FE90 = "";
   Ls_FE80 = "";
   Ls_FE70 = (string)Gi_0000;
   Ls_FE60 = "Order failed, error: ";
   if (Ii_08EC == 1) { 
   Ls_FE50 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FE50, " ", Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_010C = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_010C > 0) { 
   FileSeek(Ii_010C, 0, 2);
   Ls_FE40 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_010C, Ls_FE40, " VERBOSE: ", Ls_FE60, Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10);
   FileClose(Ii_010C);
   }}} 
   Li_FBAC = -Li_FBA4;
   Li_FFFC = Li_FBAC;
   return Li_FFFC;
   } 
   Ib_38F8 = OrderSelect(Li_FBA8, 1, 0);
   Ls_FE30 = "";
   Ls_FE20 = "";
   Ls_FE10 = "";
   Ls_FE00 = "";
   Ls_FDF0 = "";
   Ls_FDE0 = "";
   Ls_FDD0 = "";
   Ls_FDC0 = "";
   Ls_FDB0 = (string)OrderOpenPrice();
   Ls_FDA0 = " at price:";
   Ls_FD90 = (string)OrderTicket();
   Ls_FD80 = "Order opened with ticket: ";
   Ls_FD70 = TimeToString(TimeCurrent(), 3);
   Print(Ls_FD70, " ", Ls_FD80, Ls_FD90, Ls_FDA0, Ls_FDB0, Ls_FDC0, Ls_FDD0, Ls_FDE0, Ls_FDF0, Ls_FE00, Ls_FE10, Ls_FE20, Ls_FE30);
   Ls_FD60 = "";
   Ls_FD50 = "";
   Ls_FD40 = "";
   Ls_FD30 = "";
   Ls_FD20 = "";
   Ls_FD10 = "";
   Ls_FD00 = (string)OrderOpenPrice();
   Ls_FCF0 = " at price:";
   Ls_FCE0 = (string)OrderTicket();
   Ls_FCD0 = " opened with ticket: ";
   Ls_FCC0 = (string)Fa_i_07;
   Ls_FCB0 = "Order with Magic Number: ";
   tmp_str0000 = "";
   tmp_str0001 = "";
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = Ls_FD00;
   tmp_str0007 = " at price:";
   tmp_str0008 = Ls_FCE0;
   tmp_str0009 = " opened with ticket: ";
   tmp_str000A = Ls_FCC0;
   tmp_str000B = "Order with Magic Number: ";
   func_1031(tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   if (Ib_08F0 == 0) { 
   Li_FFFC = Li_FBA8;
   return Li_FFFC;
   } 
   Li_FB8C = 3;
   do { 
   Li_FB8C = Li_FB8C - 1;
   if (Li_FB8C < 0) { 
   Li_FBAC = 0;
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   if ((Fa_d_04 == 0 && Fa_d_05 == 0) 
   || (OrderStopLoss() == Fa_d_04 && OrderTakeProfit() == Fa_d_05)) {
   
   Li_FBAC = Li_FBA8;
   Li_FFFC = Li_FBA8;
   return Li_FFFC;
   }
   Ii_0118 = 30;
   Ii_0930 = 1;
   if (!IsTradeAllowed()) {
   Gi_0000 = (int)GetTickCount();
   Ii_011C = Gi_0000;
   Print("Trade context is busy! Wait until it is free...");
   do { 
   if (_StopFlag != 0) {
   Print("The expert was terminated by the user!");
   Ii_0930 = -1;
   break;
   }
   Gi_0000 = (int)GetTickCount();
   Ii_0128 = Gi_0000 - Ii_011C;
   Ii_0934 = Ii_0128;
   Ii_0128 = Ii_0118 * 1000;
   if (Ii_0934 > Ii_0128) {
   Ls_FCA0 = (string)Ii_0118;
   Ls_FCA0 = "The waiting limit exceeded (" + Ls_FCA0;
   Ls_FCA0 = Ls_FCA0 + " ???.)!";
   Print(Ls_FCA0);
   Ii_0930 = -2;
   break;
   }
   if (IsTradeAllowed()) {
   Print("Trade context has become free!");
   RefreshRates();
   Ii_0930 = 1;
   break;
   }
   Sleep(100);
   } while (true); 
   }
   else Ii_0930 = 1;
   
   if (Ii_0930 == 1) { 
   Ls_FC90 = "";
   Ls_FC80 = "";
   Ls_FC70 = "";
   Ls_FC60 = "";
   Ls_FC50 = "";
   Ls_FC40 = "";
   Ls_FC30 = "";
   Ls_FC20 = "";
   Ls_FC10 = "";
   Ls_FC00 = "";
   Ii_0128 = 3 - Li_FB8C;
   Ls_FBF0 = (string)Ii_0128;
   Ls_FBE0 = "Setting SL/PT, try #";
   if (Ii_08EC == 1) { 
   Ls_FBD0 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FBD0, " ", Ls_FBE0, Ls_FBF0, Ls_FC00, Ls_FC10, Ls_FC20, Ls_FC30, Ls_FC40, Ls_FC50, Ls_FC60, Ls_FC70, Ls_FC80, Ls_FC90);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0124 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0124 > 0) { 
   FileSeek(Ii_0124, 0, 2);
   Ls_FBC0 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0124, Ls_FBC0, " VERBOSE: ", Ls_FBE0, Ls_FBF0, Ls_FC00, Ls_FC10, Ls_FC20, Ls_FC30, Ls_FC40, Ls_FC50, Ls_FC60, Ls_FC70, Ls_FC80, Ls_FC90);
   FileClose(Ii_0124);
   }}} 
   Ls_FBB0 = Fa_s_00;
   tmp_str000C = Ls_FBB0;
   if (func_1026(Li_FBA8, Fa_d_04, Fa_d_05, Fa_i_07, Fa_i_01, Fa_d_03, tmp_str000C, Li_FB8C)) { 
   Li_FBAC = Li_FBA8;
   Li_FFFC = Li_FBA8;
   return Li_FFFC;
   } 
   if (Li_FB8C == 0) { 
   Li_FBAC = -11111;
   Li_FFFC = -11111;
   return Li_FFFC;
   }} 
   Sleep(1000);
   } while (true); 
}

bool func_1026(int Fa_i_00, double Fa_d_01, double Fa_d_02, int Fa_i_03, int Fa_i_04, double Fa_d_05, string arg, int Fa_i_07)
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
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;
   string Ls_FE40;
   string Ls_FE30;
   string Ls_FE20;
   string Ls_FE10;
   string Ls_FE00;
   string Ls_FDF0;
   string Ls_FDE0;
   string Ls_FDD0;
   string Ls_FDC0;
   string Ls_FDB0;
   string Ls_FDA0;
   bool Lb_FD9F;
   int Li_FD98;
   bool Lb_FFFF;

   Lb_FD9F = false;
   Li_FD98 = 0;
   Lb_FD9F = false;
   Li_FD98 = 0;
   Ii_0108 = 0;
   Ls_FFF0 = "";
   Ls_FFE0 = "";
   Ls_FFD0 = "";
   Ls_FFC0 = "";
   Ls_FFB0 = "";
   Ls_FFA0 = "";
   Ls_FF90 = "";
   Ls_FF80 = " for order";
   Ls_FF70 = (string)Fa_d_02;
   Ls_FF60 = " and PT: ";
   Ls_FF50 = (string)Fa_d_01;
   Ls_FF40 = "Setting SL: ";
   if (Ii_08EC == 1) { 
   Ls_FF30 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FF30, " ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   } 
   else { 
   if (Ii_08EC == 2) { 
   Ii_0108 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0108 > 0) { 
   FileSeek(Ii_0108, 0, 2);
   Ls_FF20 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0108, Ls_FF20, " VERBOSE: ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   FileClose(Ii_0108);
   }}} 
   if (OrderModify(Fa_i_00, OrderOpenPrice(), Fa_d_01, Fa_d_02, 0, 0)) { 
   Ls_FF10 = "";
   Ls_FF00 = "";
   Ls_FEF0 = "";
   Ls_FEE0 = "";
   Ls_FED0 = "";
   Ls_FEC0 = "";
   Ls_FEB0 = "";
   Ls_FEA0 = "";
   Ls_FE90 = (string)Fa_d_02;
   Ls_FE80 = ", Profit Target: ";
   Ls_FE70 = (string)Fa_d_01;
   Ls_FE60 = "Order updates, StopLoss: ";
   tmp_str0000 = "";
   tmp_str0001 = "";
   tmp_str0002 = "";
   tmp_str0003 = "";
   tmp_str0004 = "";
   tmp_str0005 = "";
   tmp_str0006 = "";
   tmp_str0007 = "";
   tmp_str0008 = Ls_FE90;
   tmp_str0009 = ", Profit Target: ";
   tmp_str000A = Ls_FE70;
   tmp_str000B = "Order updates, StopLoss: ";
   func_1031(tmp_str000B, tmp_str000A, tmp_str0009, tmp_str0008, tmp_str0007, tmp_str0006, tmp_str0005, tmp_str0004, tmp_str0003, tmp_str0002, tmp_str0001, tmp_str0000);
   Lb_FD9F = true;
   Lb_FFFF = true;
   return Lb_FFFF;
   } 
   Gi_0000 = GetLastError();
   Ii_010C = Gi_0000;
   Li_FD98 = Gi_0000;
   Ls_FE50 = "";
   Ls_FE40 = "";
   Ls_FE30 = "";
   Ls_FE20 = "";
   Ls_FE10 = "";
   Ls_FE00 = "";
   Ls_FDF0 = "";
   Ls_FDE0 = "";
   Global_ReturnedString = func_1032(Gi_0000);
   Ls_FDD0 = Global_ReturnedString;
   Ls_FDC0 = " : ";
   Ls_FDB0 = (string)Ii_010C;
   Ls_FDA0 = "Error modifying order: ";
   tmp_str000C = "";
   tmp_str000D = "";
   tmp_str000E = "";
   tmp_str000F = "";
   tmp_str0010 = "";
   tmp_str0011 = "";
   tmp_str0012 = "";
   tmp_str0013 = "";
   tmp_str0014 = Global_ReturnedString;
   tmp_str0015 = " : ";
   tmp_str0016 = Ls_FDB0;
   tmp_str0017 = "Error modifying order: ";
   func_1031(tmp_str0017, tmp_str0016, tmp_str0015, tmp_str0014, tmp_str0013, tmp_str0012, tmp_str0011, tmp_str0010, tmp_str000F, tmp_str000E, tmp_str000D, tmp_str000C);
   if (Fa_i_07 != 0) { 
   Lb_FFFF = false;
   return Lb_FFFF;
   } 
   RefreshRates();
   func_1022(-1);
   Ii_0920 = (int)TimeCurrent();
   Lb_FD9F = false;
   Lb_FFFF = false;
   
   return Lb_FFFF;
}

void func_1029()
{
   string Ls_FFF0;
   string Ls_FFE0;

   Ii_0108 = 0;
   Ii_010C = 0;
   Id_0110 = 0;
   Ii_0118 = 0;
   Ii_011C = 0;
   Ii_0934 = 0;
   Ii_0124 = 0;
   Ii_0128 = 0;
   Id_17B8 = 0;
   Ii_0940 = 0;
   Ii_0944 = 0;
   Ii_0140 = 0;
   Ii_0948 = 0;
   Ii_0150 = 0;
   Ii_0958 = 0;
   Id_0160 = 0;
   Ii_0168 = 0;
   Ii_0968 = 0;
   Ii_0178 = Ii_0104;
   Ii_010C = 100;
   Ii_0108 = 0;
   Id_0110 = 0;
   Ii_0118 = 0;
   Ii_011C = 0;
   Ii_0934 = HistoryTotal();
   if (Ii_0934 >= 0) { 
   do { 
   if (OrderSelect(Ii_0934, 0, 1) == true && OrderSymbol() == _Symbol) { 
   if (Ii_0108 == 0 || OrderMagicNumber() == Ii_0108) { 
   
   Ii_0118 = Ii_0118 + 1;
   if (OrderType() == OP_BUY) { 
   Id_0180 = OrderClosePrice();
   Id_0110 = (Id_0180 - OrderOpenPrice());
   } 
   else { 
   Id_0180 = OrderOpenPrice();
   Id_0110 = (Id_0180 - OrderClosePrice());
   } 
   if ((Id_0110 > 0)) { 
   Ii_011C = Ii_011C + 1;
   } 
   if (Ii_0118 >= Ii_010C) break; 
   }} 
   Ii_0934 = Ii_0934 - 1;
   } while (Ii_0934 >= 0); 
   } 
   Ls_FFF0 = (string)Ii_011C;
   Ls_FFF0 = "Total profits/losses so far: " + Ls_FFF0;
   Ls_FFF0 = Ls_FFF0 + "/";
   Ii_0128 = 100;
   Ii_0124 = 0;
   Id_17B8 = 0;
   Ii_0940 = 0;
   Ii_0944 = 0;
   Ii_0140 = HistoryTotal();
   if (Ii_0140 >= 0) { 
   do { 
   if (OrderSelect(Ii_0140, 0, 1) == true && OrderSymbol() == _Symbol) { 
   if (Ii_0124 == 0 || OrderMagicNumber() == Ii_0124) { 
   
   Ii_0940 = Ii_0940 + 1;
   if (OrderType() == OP_BUY) { 
   Id_0180 = OrderClosePrice();
   Id_17B8 = (Id_0180 - OrderOpenPrice());
   } 
   else { 
   Id_0180 = OrderOpenPrice();
   Id_17B8 = (Id_0180 - OrderClosePrice());
   } 
   if ((Id_17B8 < 0)) { 
   Ii_0944 = Ii_0944 + 1;
   } 
   if (Ii_0940 >= Ii_0128) break; 
   }} 
   Ii_0140 = Ii_0140 - 1;
   } while (Ii_0140 >= 0); 
   } 
   Ls_FFE0 = (string)Ii_0944;
   Ls_FFF0 = Ls_FFF0 + Ls_FFE0;
   ObjectSetText("lineto", Ls_FFF0, 8, "Tahoma", Ii_0178);
   Ii_096C = Ii_0104;
   Ii_0958 = 1000;
   Ii_0150 = 0;
   Id_0160 = 0;
   Ii_0168 = 0;
   Ii_0968 = HistoryTotal();
   if (Ii_0968 >= 0) { 
   do { 
   if (OrderSelect(Ii_0968, 0, 1) == true && OrderSymbol() == _Symbol) { 
   if (Ii_0150 == 0 || OrderMagicNumber() == Ii_0150) { 
   
   Ii_0168 = Ii_0168 + 1;
   Id_0160 = (Id_0160 + OrderProfit());
   if (Ii_0168 >= Ii_0958) break; 
   }} 
   Ii_0968 = Ii_0968 - 1;
   } while (Ii_0968 >= 0); 
   } 
   Ii_0948 = (int)Id_0160;
   Ls_FFE0 = "Total P/L so far: " + DoubleToString(Ii_0948, 2);
   ObjectSetText("linetp", Ls_FFE0, 8, "Tahoma", Ii_096C);
}

string func_1030(int Fa_i_00)
{
   string tmp_str0000;
   string Ls_FFF0;

   Ii_0068 = Fa_i_00;
   if (Fa_i_00 > 5) { 
   tmp_str0000 = "Unknown";
   return tmp_str0000;
   } 
   if (Ii_0068 == 0) { 
   tmp_str0000 = "Buy";
   return tmp_str0000;
   } 
   if (Ii_0068 == 1) { 
   tmp_str0000 = "Sell";
   return tmp_str0000;
   } 
   if (Ii_0068 == 2) { 
   tmp_str0000 = "Buy Limit";
   return tmp_str0000;
   } 
   if (Ii_0068 == 4) { 
   tmp_str0000 = "Buy Stop";
   return tmp_str0000;
   } 
   if (Ii_0068 == 3) { 
   tmp_str0000 = "Sell Limit";
   return tmp_str0000;
   } 
   if (Ii_0068 != 5) return "Unknown"; 
   tmp_str0000 = "Sell Stop";
   return tmp_str0000;
   
   tmp_str0000 = "Unknown";
   
   return tmp_str0000;
}

void func_1031(string Fa_s_00, string Fa_s_01, string Fa_s_02, string Fa_s_03, string Fa_s_04, string Fa_s_05, string Fa_s_06, string Fa_s_07, string Fa_s_08, string Fa_s_09, string Fa_s_0A, string Fa_s_0B)
{
   string Ls_FFF0;
   string Ls_FFE0;
   string Ls_FFD0;
   string Ls_FFC0;
   string Ls_FFB0;
   string Ls_FFA0;
   string Ls_FF90;
   string Ls_FF80;
   string Ls_FF70;
   string Ls_FF60;
   string Ls_FF50;
   string Ls_FF40;
   string Ls_FF30;
   string Ls_FF20;
   string Ls_FF10;
   string Ls_FF00;
   string Ls_FEF0;
   string Ls_FEE0;
   string Ls_FED0;
   string Ls_FEC0;
   string Ls_FEB0;
   string Ls_FEA0;
   string Ls_FE90;
   string Ls_FE80;
   string Ls_FE70;
   string Ls_FE60;
   string Ls_FE50;

   Ii_0108 = 0;
   if (Ii_08EC != 1) { 
   Ls_FFF0 = Fa_s_0B;
   Ls_FFE0 = Fa_s_0A;
   Ls_FFD0 = Fa_s_09;
   Ls_FFC0 = Fa_s_08;
   Ls_FFB0 = Fa_s_07;
   Ls_FFA0 = Fa_s_06;
   Ls_FF90 = Fa_s_05;
   Ls_FF80 = Fa_s_04;
   Ls_FF70 = Fa_s_03;
   Ls_FF60 = Fa_s_02;
   Ls_FF50 = Fa_s_01;
   Ls_FF40 = Fa_s_00;
   Ls_FF30 = TimeToString(TimeCurrent(), 3);
   Print(Ls_FF30, " ", Ls_FF40, Ls_FF50, Ls_FF60, Ls_FF70, Ls_FF80, Ls_FF90, Ls_FFA0, Ls_FFB0, Ls_FFC0, Ls_FFD0, Ls_FFE0, Ls_FFF0);
   } 
   Ls_FF20 = Fa_s_0B;
   Ls_FF10 = Fa_s_0A;
   Ls_FF00 = Fa_s_09;
   Ls_FEF0 = Fa_s_08;
   Ls_FEE0 = Fa_s_07;
   Ls_FED0 = Fa_s_06;
   Ls_FEC0 = Fa_s_05;
   Ls_FEB0 = Fa_s_04;
   Ls_FEA0 = Fa_s_03;
   Ls_FE90 = Fa_s_02;
   Ls_FE80 = Fa_s_01;
   Ls_FE70 = Fa_s_00;
   if (Ii_08EC == 1) { 
   Ls_FE60 = TimeToString(TimeCurrent(), 3);
   Print("---VERBOSE--- ", Ls_FE60, " ", Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10, Ls_FF20);
   return ;
   } 
   if (Ii_08EC != 2) { 
   return ;
   } 
   Ii_0108 = FileOpen("EAW_VerboseLog.txt", 3);
   if (Ii_0108 <= 0) { 
   return ;
   } 
   FileSeek(Ii_0108, 0, 2);
   Ls_FE50 = TimeToString(TimeCurrent(), 3);
   FileWrite(Ii_0108, Ls_FE50, " VERBOSE: ", Ls_FE70, Ls_FE80, Ls_FE90, Ls_FEA0, Ls_FEB0, Ls_FEC0, Ls_FED0, Ls_FEE0, Ls_FEF0, Ls_FF00, Ls_FF10, Ls_FF20);
   FileClose(Ii_0108);
   
}

string func_1032(int error_code)
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
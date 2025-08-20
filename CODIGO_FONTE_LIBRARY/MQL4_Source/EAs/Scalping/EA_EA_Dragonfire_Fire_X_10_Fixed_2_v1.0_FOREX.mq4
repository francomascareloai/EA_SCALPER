//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021 - IM-Team Fx";
#property link "";
#property version "";
#property strict
#property description ">>>Default Setting<<<\nCapital = 100USD / 10K Cent\nAccount Type = Cent\nTimeframe = M5\nPair = EURUSD & GBPUSD\nMax Pair = 2 pair per 100USD\n___________________________";

extern string EA = "--------------------- EA Dragon Fire X.10 ---------------------";
extern double Lots = 0.01;
extern double TakeProfit = 40;
extern int MaxTrades = 20;
extern double Multiplier = 1.5;
extern double PipStep = 50;

string Is_0108;
int returned_i;
int Gi_0000;
double Gd_0001;
int Gi_0002;
int Gi_0003;
int Gi_0004;
int Gi_0005;
int Gi_0006;
double Gd_0007;
int Gi_0008;
int Gi_0009;
int Gi_000A;
double Gd_000B;
int Gi_000C;
int Gi_000D;
int Gi_000E;
double Gd_000F;
int Gi_0010;
int Gi_0011;
int Gi_0012;
double Gd_0013;
int Gi_0014;
int Gi_0015;
int Gi_0016;
double Gd_0017;
int Gi_0018;
double Gd_0019;
int Gi_001A;
int Gi_001B;
double Gd_001C;
int Gi_001D;
int Gi_001E;
int Gi_001F;
double Gd_0020;
int Gi_0021;
double Gd_0022;
int Gi_0023;
int Gi_0024;
double Gd_0025;
int Gi_0026;
int Gi_0027;
int Gi_0028;
double Gd_0029;
int Gi_002A;
double Gd_002B;
int Gi_002C;
int Gi_002D;
double Gd_002E;
int Gi_002F;
int Gi_0030;
int Gi_0031;
double Gd_0032;
int Gi_0033;
double Gd_0034;
int Gi_0035;
int Gi_0036;
double Gd_0037;
int Gi_0038;
int Gi_0039;
int Gi_003A;
int Gi_003B;
int Gi_003C;
long returned_l;
long Il_0118;
bool returned_b;
double Gd_003D;
double Ind_000;
double Ind_004;
bool Ib_0040;
double Id_0078;
int Gi_003D;
double Id_0028;
double Id_0020;
bool Ib_0041;
long Il_00D0;
int Ii_0050;
double Id_0008;
double Gd_003E;
double Gd_003F;
int Gi_0040;
double Gd_0041;
double Gd_0042;
int Gi_0043;
long Il_00C8;
long Gl_0043;
int Gi_0044;
long Gl_0044;
int Ii_00E8;
bool Ib_0030;
bool Gb_0045;
double Gd_0045;
double Id_0038;
double Gd_0046;
int Gi_0047;
double Id_0128;
bool Gb_0047;
double Id_0130;
double Gd_0048;
double Gd_0049;
int Gi_004A;
double Gd_004B;
double Gd_004C;
int Gi_004D;
bool Ib_0100;
int Ii_00EC;
int Ii_00B0;
bool Ib_00F9;
bool Ib_00FA;
double Id_0090;
double Id_0098;
double Gd_004D;
bool Gb_004D;
bool Ib_00F8;
double Id_0060;
bool Ib_0004;
double Id_0010;
double Gd_004E;
double Id_00E0;
bool Ib_0005;
int Ii_00D8;
bool Gb_0051;
string Is_00B8;
int Gi_0051;
int Ii_00FC;
double Id_0080;
double Id_0088;
bool Gb_0055;
int Ii_0000;
bool Gb_0058;
int Gi_0058;
bool Gb_005B;
int Gi_005B;
long Gl_005B;
double Id_0048;
double Gd_005C;
int Gi_005C;
double Ind_002;
double Id_0058;
double Id_0068;
double Id_0018;
double Id_00F0;
double Id_0070;
int Gi_005D;
int Gi_0059;
long Gl_0059;
long Gl_005A;
bool Gb_005A;
int Gi_005A;
double Gd_005B;
double Gd_0059;
int Gi_0056;
long Gl_0056;
long Gl_0057;
bool Gb_0057;
int Gi_0057;
double Gd_0058;
int Gi_0055;
double Gd_0056;
int Gi_004F;
long Gl_004F;
long Gl_0050;
bool Gb_0050;
int Gi_0050;
double Gd_0051;
int Gi_004E;
double Gd_004F;
double Gd_0052;
int Gi_0053;
long Gl_0053;
long Gl_0054;
bool Gb_0054;
int Gi_0054;
double Gd_0055;
int Gi_0052;
double Gd_0053;
double Id_00A0;
double Id_00A8;
int Ii_0120;
int Ii_0124;
double Gd_0000;
double Gd_0002;
double Gd_0004;
long Gl_0005;
long Gl_0006;
long Gl_0003;
long Gl_0004;
double Gd_0003;
double Gd_0006;
double Gd_0009;
double Gd_000A;
int Gi_000B;
double Gd_000C;
double Gd_000D;
double Gd_0010;
double Gd_0012;
double Gd_0015;
double Gd_0016;
int Gi_0017;
double Gd_0018;
double Gd_001B;
double Gd_001E;
double Gd_001F;
int Gi_0020;
double Gd_0021;
long Gl_0031;
int Gi_0032;
long Gl_0034;
double Gd_0036;
double Gd_0033;
long Gl_0028;
int Gi_0029;
long Gl_002B;
long Gl_002E;
double Gd_0030;
double Gd_002D;
double Gd_002A;
long Gl_0025;
double Gd_0027;
bool Gb_0000;
int Gi_0001;
bool Gb_0001;
double returned_double;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   int Li_FFFC;

   Ii_0000 = 1;
   Ib_0004 = false;
   Ib_0005 = true;
   Id_0008 = 3;
   Id_0010 = 2;
   Id_0018 = 0;
   Id_0020 = 20;
   Id_0028 = 25;
   Ib_0030 = false;
   Id_0038 = 20;
   Ib_0040 = false;
   Ib_0041 = false;
   Id_0048 = 48;
   Ii_0050 = 132679;
   Id_0058 = 0;
   Id_0060 = 0;
   Id_0068 = 0;
   Id_0070 = 0;
   Id_0078 = 0;
   Id_0080 = 0;
   Id_0088 = 0;
   Id_0090 = 0;
   Id_0098 = 0;
   Id_00A0 = 0;
   Id_00A8 = 0;
   Ii_00B0 = 0;
   Is_00B8 = "EA Dragon Fire X.10";
   Il_00C8 = 0;
   Il_00D0 = 0;
   Ii_00D8 = 0;
   Id_00E0 = 0;
   Ii_00E8 = 0;
   Ii_00EC = 0;
   Id_00F0 = 0;
   Ib_00F8 = false;
   Ib_00F9 = false;
   Ib_00FA = false;
   Ii_00FC = 0;
   Ib_0100 = false;
   Is_0108 = "EADragonfireVIP";
   Il_0118 = 1730246400;
   Ii_0120 = 0;
   Ii_0124 = 0;
   Id_0128 = 0;
   Id_0130 = 0;

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
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
   double Ld_FFF8;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
   double Ld_FFD0;
   double Ld_FFC8;
   double Ld_FFC0;
   double String_Double_00000000;

   Ld_FFF8 = 0;
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ld_FFE0 = 0;
   Ld_FFD8 = 0;
   Ld_FFD0 = 0;
   Ld_FFC8 = 0;
   Ld_FFC0 = 0;
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
   Gd_000B = 0;
   Gi_000C = 0;
   Gi_000D = 0;
   Gi_000E = 0;
   Gd_000F = 0;
   Gi_0010 = 0;
   Gi_0011 = 0;
   Gi_0012 = 0;
   Gd_0013 = 0;
   Gi_0014 = 0;
   Gi_0015 = 0;
   Gi_0016 = 0;
   Gd_0017 = 0;
   Gi_0018 = 0;
   Gd_0019 = 0;
   Gi_001A = 0;
   Gi_001B = 0;
   Gd_001C = 0;
   Gi_001D = 0;
   Gi_001E = 0;
   Gi_001F = 0;
   Gd_0020 = 0;
   Gi_0021 = 0;
   Gd_0022 = 0;
   Gi_0023 = 0;
   Gi_0024 = 0;
   Gd_0025 = 0;
   Gi_0026 = 0;
   Gi_0027 = 0;
   Gi_0028 = 0;
   Gd_0029 = 0;
   Gi_002A = 0;
   Gd_002B = 0;
   Gi_002C = 0;
   Gi_002D = 0;
   Gd_002E = 0;
   Gi_002F = 0;
   Gi_0030 = 0;
   Gi_0031 = 0;
   Gd_0032 = 0;
   Gi_0033 = 0;
   Gd_0034 = 0;
   Gi_0035 = 0;
   Gi_0036 = 0;
   Gd_0037 = 0;
   Gi_0038 = 0;
   Gi_0039 = 0;
   Gi_003A = 0;
   Gi_003B = 0;
   Gi_003C = 0;


   ObjectCreate(0, "accequity", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("accequity", OBJPROP_CORNER, 3);
   ObjectSet("accequity", OBJPROP_XDISTANCE, 1480);
   ObjectSet("accequity", OBJPROP_YDISTANCE, 420);
   tmp_str0000 = "Account Equity :" + DoubleToString(AccountEquity(), 2);
   ObjectSetText("accequity", tmp_str0000, 10, "Arial", 65535);
   ObjectCreate(0, "profitloss", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("profitloss", OBJPROP_CORNER, 3);
   ObjectSet("profitloss", OBJPROP_XDISTANCE, 1490);
   ObjectSet("profitloss", OBJPROP_YDISTANCE, 400);
   Gd_003D = AccountEquity();
   tmp_str0001 = "Total Profit/Loss :" + DoubleToString((Gd_003D - AccountBalance()), 2);
   ObjectSetText("profitloss", tmp_str0001, 10, "Arial", 65535);
   ObjectCreate(0, "ordtotal", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("ordtotal", OBJPROP_CORNER, 3);
   ObjectSet("ordtotal", OBJPROP_XDISTANCE, 1550);
   ObjectSet("ordtotal", OBJPROP_YDISTANCE, 380);
   tmp_str0002 = "Total Order :" + DoubleToString(OrdersTotal(), 0);
   ObjectSetText("ordtotal", tmp_str0002, 10, "Arial", 65535);
   ObjectCreate(0, "expdate", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("expdate", OBJPROP_CORNER, 3);
   ObjectSet("expdate", OBJPROP_XDISTANCE, 10);
   ObjectSet("expdate", OBJPROP_YDISTANCE, 10);
   tmp_str0003 = "Expired Date :" + TimeToString(Il_0118, 1);
   ObjectSetText("expdate", tmp_str0003, 10, "Arial", 16777215);
   ObjectCreate(0, "title", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("title", OBJPROP_CORNER, 3);
   ObjectSet("title", OBJPROP_XDISTANCE, 700);
   ObjectSet("title", OBJPROP_YDISTANCE, 490);
   ObjectSetText("title", "EA Dragon Fire X.10 ", 20, "Lucida Console", 255);
   ObjectCreate(0, "copyrightname", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSetText("copyrightname", "Copyright ©2021 IM-Team FX", 12, "Lucida Console", 255);
   ObjectSet("copyrightname", OBJPROP_CORNER, 3);
   ObjectSet("copyrightname", OBJPROP_XDISTANCE, 750);
   ObjectSet("copyrightname", OBJPROP_YDISTANCE, 470);
   if(Ib_0040)
     {
      TrailingAlls(Id_0020, Id_0028, Id_0078);
     }
   if(Ib_0041 && TimeCurrent() >= Il_00D0)
     {
      Gi_0000 = 0;
      Gi_003D = OrdersTotal() - 1;
      Gi_0000 = Gi_003D;
      if(Gi_003D >= 0)
        {
         do
           {
            OrderSelect(Gi_0000, 0, 0);
            if(OrderSymbol() == _Symbol)
              {
               if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
                 {
                  if(OrderType() == OP_BUY)
                    {
                     OrderClose(OrderTicket(), OrderLots(), Bid, Id_0008, 16711680);
                    }
                  if(OrderType() == OP_SELL)
                    {
                     OrderClose(OrderTicket(), OrderLots(), Ask, Id_0008, 255);
                    }
                 }
               Sleep(1000);
              }
            Gi_0000 = Gi_0000 - 1;
           }
         while(Gi_0000 >= 0);
        }
      Print("Closed All due to TimeOut");
     }
   if(Il_00C8 == Time[0])
      return;
   Il_00C8 = Time[0];
   Gd_0001 = 0;
   Ii_00E8 = OrdersTotal() - 1;
   if(Ii_00E8 >= 0)
     {
      do
        {
         OrderSelect(Ii_00E8, 0, 0);
         if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
           {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
              {

               Gd_0001 = (Gd_0001 + OrderProfit());
              }
           }
         Ii_00E8 = Ii_00E8 - 1;
        }
      while(Ii_00E8 >= 0);
     }
   Ld_FFF8 = Gd_0001;
   if(Ib_0030 && (Gd_0001 < 0))
     {
      Gd_0045 = fabs(Gd_0001);
      Gd_0046 = (Id_0038 / 100);
      Gi_0002 = 0;
      Gi_0003 = 0;
      Gi_0047 = OrdersTotal() - 1;
      Gi_0003 = Gi_0047;
      if(Gi_0047 >= 0)
        {
         do
           {
            OrderSelect(Gi_0003, 0, 0);
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
              {
               if(OrderType() == OP_SELL || OrderType() == OP_BUY)
                 {

                  Gi_0002 = Gi_0002 + 1;
                 }
              }
            Gi_0003 = Gi_0003 - 1;
           }
         while(Gi_0003 >= 0);
        }
      if(Gi_0002 == 0)
        {
         Id_0128 = AccountEquity();
        }
      if((Id_0128 < Id_0130))
        {
         Id_0128 = Id_0130;
        }
      else
        {
         Id_0128 = AccountEquity();
        }
      Id_0130 = AccountEquity();
      if((Gd_0045 > (Gd_0046 * Id_0128)))
        {
         Gi_0004 = 0;
         Gi_0047 = OrdersTotal() - 1;
         Gi_0004 = Gi_0047;
         if(Gi_0047 >= 0)
           {
            do
              {
               OrderSelect(Gi_0004, 0, 0);
               if(OrderSymbol() == _Symbol)
                 {
                  if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
                    {
                     if(OrderType() == OP_BUY)
                       {
                        OrderClose(OrderTicket(), OrderLots(), Bid, Id_0008, 16711680);
                       }
                     if(OrderType() == OP_SELL)
                       {
                        OrderClose(OrderTicket(), OrderLots(), Ask, Id_0008, 255);
                       }
                    }
                  Sleep(1000);
                 }
               Gi_0004 = Gi_0004 - 1;
              }
            while(Gi_0004 >= 0);
           }
         Print("Closed All due to Stop Out");
         Ib_0100 = false;
        }
     }
   Gi_0005 = 0;
   Gi_0006 = 0;
   Gi_004D = OrdersTotal() - 1;
   Gi_0006 = Gi_004D;
   if(Gi_004D >= 0)
     {
      do
        {
         OrderSelect(Gi_0006, 0, 0);
         if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
           {
            if(OrderType() == OP_SELL || OrderType() == OP_BUY)
              {

               Gi_0005 = Gi_0005 + 1;
              }
           }
         Gi_0006 = Gi_0006 - 1;
        }
      while(Gi_0006 >= 0);
     }
   Ii_00EC = Gi_0005;
   if(Gi_0005 == 0)
     {
      Ii_00B0 = 0;
     }
   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Ii_00E8 = OrdersTotal() - 1;
   if(Ii_00E8 >= 0)
     {
      do
        {
         OrderSelect(Ii_00E8, 0, 0);
         if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
           {
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_BUY)
              {
               Ib_00F9 = true;
               Ib_00FA = false;
               Ld_FFF0 = OrderLots();
               break;
              }
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_SELL)
              {
               Ib_00F9 = false;
               Ib_00FA = true;
               Ld_FFE8 = OrderLots();
               break;
              }
           }
         Ii_00E8 = Ii_00E8 - 1;
        }
      while(Ii_00E8 >= 0);
     }
   if(Ii_00EC > 0 && Ii_00EC <= MaxTrades)
     {
      RefreshRates();
      Gd_0007 = 0;
      Gi_0008 = 0;
      Gi_0009 = 0;
      Gi_000A = 0;
      Gi_004D = OrdersTotal() - 1;
      Gi_0008 = Gi_004D;
      if(Gi_004D >= 0)
        {
         do
           {
            OrderSelect(Gi_0008, 0, 0);
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_BUY)
              {
               Gi_000A = OrderTicket();
               if(Gi_000A > Gi_0009)
                 {
                  Gd_0007 = OrderOpenPrice();
                  Gi_0009 = Gi_000A;
                 }
              }
            Gi_0008 = Gi_0008 - 1;
           }
         while(Gi_0008 >= 0);
        }
      Id_0090 = Gd_0007;
      Gd_000B = 0;
      Gi_000C = 0;
      Gi_000D = 0;
      Gi_000E = 0;
      Gi_004D = OrdersTotal() - 1;
      Gi_000C = Gi_004D;
      if(Gi_004D >= 0)
        {
         do
           {
            OrderSelect(Gi_000C, 0, 0);
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_SELL)
              {
               Gi_000E = OrderTicket();
               if(Gi_000E > Gi_000D)
                 {
                  Gd_000B = OrderOpenPrice();
                  Gi_000D = Gi_000E;
                 }
              }
            Gi_000C = Gi_000C - 1;
           }
         while(Gi_000C >= 0);
        }
      Id_0098 = Gd_000B;
      if(Ib_00F9)
        {
         Gd_004D = (Id_0090 - Ask);
         if((Gd_004D >= (PipStep * _Point)))
           {
            Ib_00F8 = true;
           }
        }
      if(Ib_00FA)
        {
         Gd_004D = (Bid - Id_0098);
         if((Gd_004D >= (PipStep * _Point)))
           {
            Ib_00F8 = true;
           }
        }
     }
   if(Ii_00EC < 1)
     {
      Ib_00FA = false;
      Ib_00F9 = false;
      Ib_00F8 = true;
      Id_0060 = AccountEquity();
     }
   if(Ib_00F8)
     {
      Gd_000F = 0;
      Gi_0010 = 0;
      Gi_0011 = 0;
      Gi_0012 = 0;
      Gi_004D = OrdersTotal() - 1;
      Gi_0010 = Gi_004D;
      if(Gi_004D >= 0)
        {
         do
           {
            OrderSelect(Gi_0010, 0, 0);
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_BUY)
              {
               Gi_0012 = OrderTicket();
               if(Gi_0012 > Gi_0011)
                 {
                  Gd_000F = OrderOpenPrice();
                  Gi_0011 = Gi_0012;
                 }
              }
            Gi_0010 = Gi_0010 - 1;
           }
         while(Gi_0010 >= 0);
        }
      Id_0090 = Gd_000F;
      Gd_0013 = 0;
      Gi_0014 = 0;
      Gi_0015 = 0;
      Gi_0016 = 0;
      Gi_004D = OrdersTotal() - 1;
      Gi_0014 = Gi_004D;
      if(Gi_004D >= 0)
        {
         do
           {
            OrderSelect(Gi_0014, 0, 0);
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_SELL)
              {
               Gi_0016 = OrderTicket();
               if(Gi_0016 > Gi_0015)
                 {
                  Gd_0013 = OrderOpenPrice();
                  Gi_0015 = Gi_0016;
                 }
              }
            Gi_0014 = Gi_0014 - 1;
           }
         while(Gi_0014 >= 0);
        }
      Id_0098 = Gd_0013;
      if(Ib_00FA != false)
        {
         if(Ib_0004)
           {
            fOrderCloseMarket(false, true);
            Id_00E0 = NormalizeDouble((Multiplier * Ld_FFE8), Id_0010);
           }
         else
           {
            Gd_0019 = 0;
            returned_i = Ii_0000;
            if(returned_i == 0)
              {

               Gd_0019 = Lots;
              }
            if(returned_i == 1)
              {

               returned_double = MathPow(Multiplier, Ii_00D8);
               Gd_0019 = NormalizeDouble((Lots * returned_double), Id_0010);
              }
            if(returned_i == 2)
              {

               Gi_001A = 0;
               Gd_0019 = Lots;
               Gi_004F = HistoryTotal() - 1;
               Gi_001B = Gi_004F;
               if(Gi_004F >= 0)
                 {
                  do
                    {
                     if(OrderSelect(Gi_001B, 0, 1))
                       {
                        if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
                          {
                           Gl_004F = OrderCloseTime();
                           Gl_0050 = Gi_001A;
                           if(Gl_0050 < Gl_004F)
                             {
                              Gi_001A = OrderCloseTime();
                              if((OrderProfit() < 0))
                                {
                                 Gd_0019 = NormalizeDouble((OrderLots() * Multiplier), Id_0010);
                                }
                              else
                                {
                                 Gd_0019 = Lots;
                                }
                             }
                          }
                       }
                     else
                       {
                        Gd_0017 = -3;
                        break;
                       }
                     Gi_001B = Gi_001B - 1;
                    }
                  while(Gi_001B >= 0);
                 }
              }
            if((AccountFreeMarginCheck(_Symbol, 1, Gd_0019) <= 0))
              {
               Gd_0017 = -1;
              }
            else
              {
               Gi_0051 = GetLastError();
               if(Gi_0051 == 134)
                 {
                  Gd_0017 = -2;
                 }
               else
                 {
                  Gd_0017 = Gd_0019;
                 }
              }
            Id_00E0 = Gd_0017;
           }
         if(Ib_0005 != false)
           {
            Ii_00D8 = Ii_00EC;
            if((Id_00E0 > 0))
              {
               RefreshRates();
               tmp_str0004 = Is_00B8 + "-";
               tmp_str0005 = (string)Ii_00EC;
               tmp_str0004 = tmp_str0004 + tmp_str0005;
               Ii_00FC = OpenPendingOrder(1, Id_00E0, Bid, Id_0008, Ask, 0, 0, tmp_str0004, Ii_0050, 0, 42495);
               if(Ii_00FC < 0)
                 {
                  Print("Error: ", GetLastError());
                  return ;
                 }
               Gd_001C = 0;
               Gi_001D = 0;
               Gi_001E = 0;
               Gi_001F = 0;
               Gi_0051 = OrdersTotal() - 1;
               Gi_001D = Gi_0051;
               if(Gi_0051 >= 0)
                 {
                  do
                    {
                     OrderSelect(Gi_001D, 0, 0);
                     if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_SELL)
                       {
                        Gi_001F = OrderTicket();
                        if(Gi_001F > Gi_001E)
                          {
                           Gd_001C = OrderOpenPrice();
                           Gi_001E = Gi_001F;
                          }
                       }
                     Gi_001D = Gi_001D - 1;
                    }
                  while(Gi_001D >= 0);
                 }
               Id_0098 = Gd_001C;
               Ib_00F8 = false;
               Ib_0100 = true;
              }
           }
        }
      else
        {
         if(Ib_00F9)
           {
            if(Ib_0004)
              {
               fOrderCloseMarket(true, false);
               Id_00E0 = NormalizeDouble((Multiplier * Ld_FFF0), Id_0010);
              }
            else
              {
               Gd_0022 = 0;
               returned_i = Ii_0000;
               if(returned_i == 0)
                 {

                  Gd_0022 = Lots;
                 }
               if(returned_i == 1)
                 {

                  returned_double = MathPow(Multiplier, Ii_00D8);
                  Gd_0022 = NormalizeDouble((Lots * returned_double), Id_0010);
                 }
               if(returned_i == 2)
                 {

                  Gi_0023 = 0;
                  Gd_0022 = Lots;
                  Gi_0053 = HistoryTotal() - 1;
                  Gi_0024 = Gi_0053;
                  if(Gi_0053 >= 0)
                    {
                     do
                       {
                        if(OrderSelect(Gi_0024, 0, 1))
                          {
                           if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
                             {
                              Gl_0053 = OrderCloseTime();
                              Gl_0054 = Gi_0023;
                              if(Gl_0054 < Gl_0053)
                                {
                                 Gi_0023 = OrderCloseTime();
                                 if((OrderProfit() < 0))
                                   {
                                    Gd_0022 = NormalizeDouble((OrderLots() * Multiplier), Id_0010);
                                   }
                                 else
                                   {
                                    Gd_0022 = Lots;
                                   }
                                }
                             }
                          }
                        else
                          {
                           Gd_0020 = -3;
                           break;
                          }
                        Gi_0024 = Gi_0024 - 1;
                       }
                     while(Gi_0024 >= 0);
                    }
                 }
               if((AccountFreeMarginCheck(_Symbol, 0, Gd_0022) <= 0))
                 {
                  Gd_0020 = -1;
                 }
               else
                 {
                  Gi_0055 = GetLastError();
                  if(Gi_0055 == 134)
                    {
                     Gd_0020 = -2;
                    }
                  else
                    {
                     Gd_0020 = Gd_0022;
                    }
                 }
               Id_00E0 = Gd_0020;
              }
            if(Ib_0005)
              {
               Ii_00D8 = Ii_00EC;
               if((Id_00E0 > 0))
                 {
                  tmp_str0005 = Is_00B8 + "-";
                  tmp_str0006 = (string)Ii_00EC;
                  tmp_str0005 = tmp_str0005 + tmp_str0006;
                  Ii_00FC = OpenPendingOrder(0, Id_00E0, Ask, Id_0008, Bid, 0, 0, tmp_str0005, Ii_0050, 0, 16711680);
                  if(Ii_00FC < 0)
                    {
                     Print("Error: ", GetLastError());
                     return ;
                    }
                  Gd_0025 = 0;
                  Gi_0026 = 0;
                  Gi_0027 = 0;
                  Gi_0028 = 0;
                  Gi_0055 = OrdersTotal() - 1;
                  Gi_0026 = Gi_0055;
                  if(Gi_0055 >= 0)
                    {
                     do
                       {
                        OrderSelect(Gi_0026, 0, 0);
                        if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_BUY)
                          {
                           Gi_0028 = OrderTicket();
                           if(Gi_0028 > Gi_0027)
                             {
                              Gd_0025 = OrderOpenPrice();
                              Gi_0027 = Gi_0028;
                             }
                          }
                        Gi_0026 = Gi_0026 - 1;
                       }
                     while(Gi_0026 >= 0);
                    }
                  Id_0090 = Gd_0025;
                  Ib_00F8 = false;
                  Ib_0100 = true;
                 }
              }
           }
        }
     }
   if(Ib_00F8 && Ii_00EC < 1)
     {
      Ld_FFE0 = iClose(_Symbol, 0, 4);
      Ld_FFD8 = iClose(_Symbol, 0, 3);
      Ld_FFD0 = iClose(_Symbol, 0, 2);
      returned_double = iClose(_Symbol, 0, 1);
      Ld_FFC8 = returned_double;
      Id_0080 = Bid;
      Id_0088 = Ask;
      if(Ib_00FA != true)
        {
         Ii_00D8 = Ii_00EC;
         if((returned_double > Ld_FFD0) && (Ld_FFD0 > Ld_FFD8) && (Ld_FFD8 > Ld_FFE0))
           {
            Gd_002B = 0;
            returned_i = Ii_0000;
            if(returned_i == 0)
              {

               Gd_002B = Lots;
              }
            if(returned_i == 1)
              {

               returned_double = MathPow(Multiplier, Ii_00D8);
               Gd_002B = NormalizeDouble((Lots * returned_double), Id_0010);
              }
            if(returned_i == 2)
              {

               Gi_002C = 0;
               Gd_002B = Lots;
               Gi_0056 = HistoryTotal() - 1;
               Gi_002D = Gi_0056;
               if(Gi_0056 >= 0)
                 {
                  do
                    {
                     if(OrderSelect(Gi_002D, 0, 1))
                       {
                        if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
                          {
                           Gl_0056 = OrderCloseTime();
                           Gl_0057 = Gi_002C;
                           if(Gl_0057 < Gl_0056)
                             {
                              Gi_002C = OrderCloseTime();
                              if((OrderProfit() < 0))
                                {
                                 Gd_002B = NormalizeDouble((OrderLots() * Multiplier), Id_0010);
                                }
                              else
                                {
                                 Gd_002B = Lots;
                                }
                             }
                          }
                       }
                     else
                       {
                        Gd_0029 = -3;
                        break;
                       }
                     Gi_002D = Gi_002D - 1;
                    }
                  while(Gi_002D >= 0);
                 }
              }
            if((AccountFreeMarginCheck(_Symbol, 1, Gd_002B) <= 0))
              {
               Gd_0029 = -1;
              }
            else
              {
               Gi_0058 = GetLastError();
               if(Gi_0058 == 134)
                 {
                  Gd_0029 = -2;
                 }
               else
                 {
                  Gd_0029 = Gd_002B;
                 }
              }
            Id_00E0 = Gd_0029;
            if((Gd_0029 > 0))
              {
               tmp_str0006 = Is_00B8 + "-";
               tmp_str0007 = (string)Ii_00D8;
               tmp_str0006 = tmp_str0006 + tmp_str0007;
               Ii_00FC = OpenPendingOrder(1, Gd_0029, Id_0080, Id_0008, Id_0080, 0, 0, tmp_str0006, Ii_0050, 0, 255);
               if(Ii_00FC < 0)
                 {
                  Print(Id_00E0, "Error: ", GetLastError());
                  return ;
                 }
               Gd_002E = 0;
               Gi_002F = 0;
               Gi_0030 = 0;
               Gi_0031 = 0;
               Gi_0058 = OrdersTotal() - 1;
               Gi_002F = Gi_0058;
               if(Gi_0058 >= 0)
                 {
                  do
                    {
                     OrderSelect(Gi_002F, 0, 0);
                     if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_BUY)
                       {
                        Gi_0031 = OrderTicket();
                        if(Gi_0031 > Gi_0030)
                          {
                           Gd_002E = OrderOpenPrice();
                           Gi_0030 = Gi_0031;
                          }
                       }
                     Gi_002F = Gi_002F - 1;
                    }
                  while(Gi_002F >= 0);
                 }
               Id_0090 = Gd_002E;
               Ib_0100 = true;
              }
           }
         if(Ib_00F9 != true)
           {
            Ii_00D8 = Ii_00EC;
           }
         if((Ld_FFC8 < Ld_FFD0) && (Ld_FFD0 < Ld_FFD8) && (Ld_FFD8 < Ld_FFE0))
           {
            Gd_0034 = 0;
            returned_i = Ii_0000;
            if(returned_i == 0)
              {

               Gd_0034 = Lots;
              }
            if(returned_i == 1)
              {

               returned_double = MathPow(Multiplier, Ii_00D8);
               Gd_0034 = NormalizeDouble((Lots * returned_double), Id_0010);
              }
            if(returned_i == 2)
              {

               Gi_0035 = 0;
               Gd_0034 = Lots;
               Gi_0059 = HistoryTotal() - 1;
               Gi_0036 = Gi_0059;
               if(Gi_0059 >= 0)
                 {
                  do
                    {
                     if(OrderSelect(Gi_0036, 0, 1))
                       {
                        if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
                          {
                           Gl_0059 = OrderCloseTime();
                           Gl_005A = Gi_0035;
                           if(Gl_005A < Gl_0059)
                             {
                              Gi_0035 = OrderCloseTime();
                              if((OrderProfit() < 0))
                                {
                                 Gd_0034 = NormalizeDouble((OrderLots() * Multiplier), Id_0010);
                                }
                              else
                                {
                                 Gd_0034 = Lots;
                                }
                             }
                          }
                       }
                     else
                       {
                        Gd_0032 = -3;
                        break;
                       }
                     Gi_0036 = Gi_0036 - 1;
                    }
                  while(Gi_0036 >= 0);
                 }
              }
            if((AccountFreeMarginCheck(_Symbol, 0, Gd_0034) <= 0))
              {
               Gd_0032 = -1;
              }
            else
              {
               Gi_005B = GetLastError();
               if(Gi_005B == 134)
                 {
                  Gd_0032 = -2;
                 }
               else
                 {
                  Gd_0032 = Gd_0034;
                 }
              }
            Id_00E0 = Gd_0032;
            if((Gd_0032 > 0))
              {
               tmp_str0007 = Is_00B8 + "-";
               tmp_str0008 = (string)Ii_00D8;
               tmp_str0007 = tmp_str0007 + tmp_str0008;
               Ii_00FC = OpenPendingOrder(0, Gd_0032, Id_0088, Id_0008, Id_0088, 0, 0, tmp_str0007, Ii_0050, 0, 65280);
               if(Ii_00FC < 0)
                 {
                  Print(Id_00E0, "Error: ", GetLastError());
                  return ;
                 }
               Gd_0037 = 0;
               Gi_0038 = 0;
               Gi_0039 = 0;
               Gi_003A = 0;
               Gi_005B = OrdersTotal() - 1;
               Gi_0038 = Gi_005B;
               if(Gi_005B >= 0)
                 {
                  do
                    {
                     OrderSelect(Gi_0038, 0, 0);
                     if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_SELL)
                       {
                        Gi_003A = OrderTicket();
                        if(Gi_003A > Gi_0039)
                          {
                           Gd_0037 = OrderOpenPrice();
                           Gi_0039 = Gi_003A;
                          }
                       }
                     Gi_0038 = Gi_0038 - 1;
                    }
                  while(Gi_0038 >= 0);
                 }
               Id_0098 = Gd_0037;
               Ib_0100 = true;
              }
           }
        }
      if(Ii_00FC > 0)
        {
         Gl_005B = TimeCurrent();
         Gd_005C = ((Id_0048 * 60) * 60);
         Il_00D0 = (Gl_005B + Gd_005C);
        }
      Ib_00F8 = false;
     }
   Gi_003B = 0;
   Gi_003C = 0;
   Gi_005C = OrdersTotal() - 1;
   Gi_003C = Gi_005C;
   if(Gi_005C >= 0)
     {
      do
        {
         OrderSelect(Gi_003C, 0, 0);
         if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
           {
            if(OrderType() == OP_SELL || OrderType() == OP_BUY)
              {

               Gi_003B = Gi_003B + 1;
              }
           }
         Gi_003C = Gi_003C - 1;
        }
      while(Gi_003C >= 0);
     }
   Ii_00EC = Gi_003B;
   Id_0078 = 0;
   Ld_FFC0 = 0;
   Ii_00E8 = OrdersTotal() - 1;
   if(Ii_00E8 >= 0)
     {
      do
        {
         OrderSelect(Ii_00E8, 0, 0);
         if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
           {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
              {

               Gd_005C = OrderOpenPrice();
               Id_0078 = ((Gd_005C * OrderLots()) + Id_0078);
               Ld_FFC0 = (Ld_FFC0 + OrderLots());
              }
           }
         Ii_00E8 = Ii_00E8 - 1;
        }
      while(Ii_00E8 >= 0);
     }
   if(Ii_00EC > 0)
     {
      Id_0078 = NormalizeDouble((Id_0078 / Ld_FFC0), _Digits);
     }
   if(Ib_0100)
     {
      Ii_00E8 = OrdersTotal() - 1;
      if(Ii_00E8 >= 0)
        {
         do
           {
            OrderSelect(Ii_00E8, 0, 0);
            if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
              {
               if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_BUY)
                 {
                  Id_0058 = ((TakeProfit * _Point) + Id_0078);
                  Id_0068 = Id_0058;
                  Gd_005C = (Id_0018 * _Point);
                  Id_00F0 = (Id_0078 - Gd_005C);
                  Ii_00B0 = 1;
                 }
               if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050 && OrderType() == OP_SELL)
                 {
                  Gd_005C = (TakeProfit * _Point);
                  Id_0058 = (Id_0078 - Gd_005C);
                  Id_0070 = Id_0058;
                  Id_00F0 = ((Id_0018 * _Point) + Id_0078);
                  Ii_00B0 = 1;
                 }
              }
            Ii_00E8 = Ii_00E8 - 1;
           }
         while(Ii_00E8 >= 0);
        }
     }
   if(Ib_0100 == false)
      return;
   if(Ii_00B0 != 1)
      return;
   Ii_00E8 = OrdersTotal() - 1;
   if(Ii_00E8 < 0)
      return;
   do
     {
      OrderSelect(Ii_00E8, 0, 0);
      if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
        {
         if(OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
           {
            OrderModify(OrderTicket(), Id_0078, OrderStopLoss(), Id_0058, 0, 65535);
           }
         Ib_0100 = false;
        }
      Ii_00E8 = Ii_00E8 - 1;
     }
   while(Ii_00E8 >= 0);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fOrderCloseMarket(bool FuncArg_Boolean_00000000, bool FuncArg_Boolean_00000001)
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
   if(Li_FFF4 < 0)
      return Li_FFF8;
   do
     {
      if(OrderSelect(Li_FFF4, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
        {
         if(OrderType() == OP_BUY && FuncArg_Boolean_00000000)
           {
            RefreshRates();
            if(!IsTradeContextBusy())
              {
               if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 5, 4294967295))
                 {
                  tmp_str0000 = (string)OrderTicket();
                  tmp_str0000 = "Error close BUY " + tmp_str0000;
                  Print(tmp_str0000);
                  Li_FFF8 = -1;
                 }
              }
            else
              {
               Gl_0003 = iTime(NULL, 0, 0);
               Gl_0004 = Ii_0120;
               if(Gl_0004 != Gl_0003)
                 {
                  Ii_0120 = iTime(NULL, 0, 0);
                  tmp_str0001 = (string)OrderTicket();
                  tmp_str0001 = "Need close BUY " + tmp_str0001;
                  tmp_str0001 = tmp_str0001 + ". Trade Context Busy";
                  Print(tmp_str0001);
                 }
               Li_FFFC = -2;
               return Li_FFFC;
              }
           }
         if(OrderType() == OP_SELL && FuncArg_Boolean_00000001)
           {
            RefreshRates();
            if(!IsTradeContextBusy())
              {
               if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 5, 4294967295))
                 {
                  tmp_str0002 = (string)OrderTicket();
                  tmp_str0002 = "Error close SELL " + tmp_str0002;
                  Print(tmp_str0002);
                  Li_FFF8 = -1;
                 }
              }
            else
              {
               Gl_0005 = iTime(NULL, 0, 0);
               Gl_0006 = Ii_0124;
               if(Gl_0006 != Gl_0005)
                 {
                  Ii_0124 = iTime(NULL, 0, 0);
                  tmp_str0003 = (string)OrderTicket();
                  tmp_str0003 = "Need close SELL " + tmp_str0003;
                  tmp_str0003 = tmp_str0003 + ". Trade Context Busy";
                  Print(tmp_str0003);
                 }
               Li_FFFC = -2;
               return Li_FFFC;
              }
           }
        }
      Li_FFF4 = Li_FFF4 - 1;
     }
   while(Li_FFF4 >= 0);

   Li_FFFC = Li_FFF8;

   return Li_FFFC;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenPendingOrder(int Fa_i_00, double Fa_d_01, double Fa_d_02, int Fa_i_03, double Fa_d_04, int Fa_i_05, int Fa_i_06, string Fa_s_07, int Fa_i_08, long Fa_l_09, int Fa_i_0A)
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
   if(returned_i > 5)
      return Li_FFF8;
   if(returned_i == 2)
     {

      Li_FFF0 = 0;
      if(Li_FFEC <= 0)
         return Li_FFF8;
      do
        {
         Gi_0024 = Fa_i_0A;
         Gi_0005 = Fa_i_06;
         Gd_0004 = Fa_d_02;
         if(Fa_i_06 == 0)
           {
            Gd_0003 = 0;
           }
         else
           {
            Gd_0003 = ((Gi_0005 * _Point) + Gd_0004);
           }
         Gi_0002 = Fa_i_05;
         Gd_0001 = Fa_d_04;
         if(Fa_i_05 == 0)
           {
            Gd_0000 = 0;
           }
         else
           {
            Gd_0027 = (Gi_0002 * _Point);
            Gd_0000 = (Gd_0001 - Gd_0027);
           }
         Li_FFF8 = OrderSend(_Symbol, 2, Fa_d_01, Fa_d_02, Fa_i_03, Gd_0000, Gd_0003, Fa_s_07, Fa_i_08, Fa_l_09, Gi_0024);
         Gi_0027 = GetLastError();
         Li_FFF4 = Gi_0027;
         if(Gi_0027 == 0)
            return Li_FFF8;
         if(Gi_0027 != 4 && Gi_0027 != 137 && Gi_0027 != 146)
           {
            if(Gi_0027 != 136)
               return Li_FFF8;
           }
         Sleep(1000);
         Li_FFF0 = Li_FFF0 + 1;
        }
      while(Li_FFF0 < Li_FFEC);
      return Li_FFF8;
     }
   if(returned_i == 4)
     {

      Li_FFF0 = 0;
      if(Li_FFEC <= 0)
         return Li_FFF8;
      do
        {
         Gi_0027 = Fa_i_0A;
         Gi_000B = Fa_i_06;
         Gd_000A = Fa_d_02;
         if(Fa_i_06 == 0)
           {
            Gd_0009 = 0;
           }
         else
           {
            Gd_0009 = ((Gi_000B * _Point) + Gd_000A);
           }
         Gi_0008 = Fa_i_05;
         Gd_0007 = Fa_d_04;
         if(Fa_i_05 == 0)
           {
            Gd_0006 = 0;
           }
         else
           {
            Gd_002A = (Gi_0008 * _Point);
            Gd_0006 = (Gd_0007 - Gd_002A);
           }
         Li_FFF8 = OrderSend(_Symbol, 4, Fa_d_01, Fa_d_02, Fa_i_03, Gd_0006, Gd_0009, Fa_s_07, Fa_i_08, Fa_l_09, Gi_0027);
         Gi_002A = GetLastError();
         Li_FFF4 = Gi_002A;
         if(Gi_002A == 0)
            return Li_FFF8;
         if(Gi_002A != 4 && Gi_002A != 137 && Gi_002A != 146)
           {
            if(Gi_002A != 136)
               return Li_FFF8;
           }
         Sleep(5000);
         Li_FFF0 = Li_FFF0 + 1;
        }
      while(Li_FFF0 < Li_FFEC);
      return Li_FFF8;
     }
   if(returned_i == 0)
     {

      Li_FFF0 = 0;
      if(Li_FFEC <= 0)
         return Li_FFF8;
      do
        {
         RefreshRates();
         Gi_002A = Fa_i_0A;
         Gi_0011 = Fa_i_06;
         Gd_0010 = Ask;
         if(Fa_i_06 == 0)
           {
            Gd_000F = 0;
           }
         else
           {
            Gd_000F = ((Gi_0011 * _Point) + Gd_0010);
           }
         Gi_000E = Fa_i_05;
         Gd_000D = Bid;
         if(Fa_i_05 == 0)
           {
            Gd_000C = 0;
           }
         else
           {
            Gd_002D = (Gi_000E * _Point);
            Gd_000C = (Gd_000D - Gd_002D);
           }
         Li_FFF8 = OrderSend(_Symbol, 0, Fa_d_01, Ask, Fa_i_03, Gd_000C, Gd_000F, Fa_s_07, Fa_i_08, Fa_l_09, Gi_002A);
         Gi_002D = GetLastError();
         Li_FFF4 = Gi_002D;
         if(Gi_002D == 0)
            return Li_FFF8;
         if(Gi_002D != 4 && Gi_002D != 137 && Gi_002D != 146)
           {
            if(Gi_002D != 136)
               return Li_FFF8;
           }
         Sleep(5000);
         Li_FFF0 = Li_FFF0 + 1;
        }
      while(Li_FFF0 < Li_FFEC);
      return Li_FFF8;
     }
   if(returned_i == 3)
     {

      Li_FFF0 = 0;
      if(Li_FFEC <= 0)
         return Li_FFF8;
      do
        {
         Gi_002D = Fa_i_0A;
         Gi_0017 = Fa_i_06;
         Gd_0016 = Fa_d_02;
         if(Fa_i_06 == 0)
           {
            Gd_0015 = 0;
           }
         else
           {
            Gd_0030 = (Gi_0017 * _Point);
            Gd_0015 = (Gd_0016 - Gd_0030);
           }
         Gi_0014 = Fa_i_05;
         Gd_0013 = Fa_d_04;
         if(Fa_i_05 == 0)
           {
            Gd_0012 = 0;
           }
         else
           {
            Gd_0012 = ((Gi_0014 * _Point) + Gd_0013);
           }
         Li_FFF8 = OrderSend(_Symbol, 3, Fa_d_01, Fa_d_02, Fa_i_03, Gd_0012, Gd_0015, Fa_s_07, Fa_i_08, Fa_l_09, Gi_002D);
         Gi_0030 = GetLastError();
         Li_FFF4 = Gi_0030;
         if(Gi_0030 == 0)
            return Li_FFF8;
         if(Gi_0030 != 4 && Gi_0030 != 137 && Gi_0030 != 146)
           {
            if(Gi_0030 != 136)
               return Li_FFF8;
           }
         Sleep(5000);
         Li_FFF0 = Li_FFF0 + 1;
        }
      while(Li_FFF0 < Li_FFEC);
      return Li_FFF8;
     }
   if(returned_i == 5)
     {

      Li_FFF0 = 0;
      if(Li_FFEC <= 0)
         return Li_FFF8;
      do
        {
         Gi_0030 = Fa_i_0A;
         Gi_001D = Fa_i_06;
         Gd_001C = Fa_d_02;
         if(Fa_i_06 == 0)
           {
            Gd_001B = 0;
           }
         else
           {
            Gd_0033 = (Gi_001D * _Point);
            Gd_001B = (Gd_001C - Gd_0033);
           }
         Gi_001A = Fa_i_05;
         Gd_0019 = Fa_d_04;
         if(Fa_i_05 == 0)
           {
            Gd_0018 = 0;
           }
         else
           {
            Gd_0018 = ((Gi_001A * _Point) + Gd_0019);
           }
         Li_FFF8 = OrderSend(_Symbol, 5, Fa_d_01, Fa_d_02, Fa_i_03, Gd_0018, Gd_001B, Fa_s_07, Fa_i_08, Fa_l_09, Gi_0030);
         Gi_0033 = GetLastError();
         Li_FFF4 = Gi_0033;
         if(Gi_0033 == 0)
            return Li_FFF8;
         if(Gi_0033 != 4 && Gi_0033 != 137 && Gi_0033 != 146)
           {
            if(Gi_0033 != 136)
               return Li_FFF8;
           }
         Sleep(5000);
         Li_FFF0 = Li_FFF0 + 1;
        }
      while(Li_FFF0 < Li_FFEC);
      return Li_FFF8;
     }
   if(returned_i == 1)
     {

      Li_FFF0 = 0;
      if(Li_FFEC <= 0)
         return Li_FFF8;
      do
        {
         Gi_0033 = Fa_i_0A;
         Gi_0023 = Fa_i_06;
         Gd_0022 = Bid;
         if(Fa_i_06 == 0)
           {
            Gd_0021 = 0;
           }
         else
           {
            Gd_0036 = (Gi_0023 * _Point);
            Gd_0021 = (Gd_0022 - Gd_0036);
           }
         Gi_0020 = Fa_i_05;
         Gd_001F = Ask;
         if(Fa_i_05 == 0)
           {
            Gd_001E = 0;
           }
         else
           {
            Gd_001E = ((Gi_0020 * _Point) + Gd_001F);
           }
         Li_FFF8 = OrderSend(_Symbol, 1, Fa_d_01, Bid, Fa_i_03, Gd_001E, Gd_0021, Fa_s_07, Fa_i_08, Fa_l_09, Gi_0033);
         Gi_0036 = GetLastError();
         Li_FFF4 = Gi_0036;
         if(Gi_0036 == 0)
            return Li_FFF8;
         if(Gi_0036 != 4 && Gi_0036 != 137 && Gi_0036 != 146)
           {
            if(Gi_0036 != 136)
               return Li_FFF8;
           }
         Sleep(5000);
         Li_FFF0 = Li_FFF0 + 1;
        }
      while(Li_FFF0 < Li_FFEC);
     }
   Li_FFFC = Li_FFF8;
   return Li_FFF8;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls(int Fa_i_00, int Fa_i_01, double Fa_d_02)
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
   if(Fa_i_01 == 0)
      return;
   Li_FFE4 = 0;
   Li_FFE4 = OrdersTotal() - 1;
   if(Li_FFE4 < 0)
      return;
   do
     {
      if(OrderSelect(Li_FFE4, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Ii_0050)
        {
         if(OrderSymbol() == _Symbol || OrderMagicNumber() == Ii_0050)
           {

            if(OrderType() == OP_BUY)
              {
               Gd_0000 = (Bid - Fa_d_02);
               Li_FFFC = NormalizeDouble((Gd_0000 / _Point), 0);
               if(Li_FFFC >= Fa_i_00)
                 {
                  returned_double = OrderStopLoss();
                  Ld_FFF0 = returned_double;
                  Gd_0000 = (Fa_i_01 * _Point);
                  Ld_FFE8 = (Bid - Gd_0000);
                  if(returned_double == 0 || (returned_double != 0 && Ld_FFE8 > returned_double))
                    {

                     OrderModify(OrderTicket(), Fa_d_02, Ld_FFE8, OrderTakeProfit(), 0, 16776960);
                    }
                 }
              }
            if(OrderType() == OP_SELL)
              {
               Gd_0001 = (Fa_d_02 - Ask);
               Li_FFFC = NormalizeDouble((Gd_0001 / _Point), 0);
               if(Li_FFFC >= Fa_i_00)
                 {
                  returned_double = OrderStopLoss();
                  Ld_FFF0 = returned_double;
                  Ld_FFE8 = ((Fa_i_01 * _Point) + Ask);
                  if(returned_double == 0 || (returned_double != 0 && Ld_FFE8 < returned_double))
                    {

                     OrderModify(OrderTicket(), Fa_d_02, Ld_FFE8, OrderTakeProfit(), 0, 255);
                    }
                 }
              }
           }
         Sleep(1000);
        }
      Li_FFE4 = Li_FFE4 - 1;
     }
   while(Li_FFE4 >= 0);

  }


//+------------------------------------------------------------------+

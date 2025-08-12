//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Telegram @VibrixEA";
#property link "";
#property version "";
#property strict
#property description "Web site: hrrps://vibrix-ea.tech\nTelegram @VibrixEA\nE-mail: vibrixgroup@gmail.com\nVibrix Group EA intraday scalper on timeframe M15-H1.\nThe input parameters are optimized for XAUUSD";

extern string id = "Vibrix Group EA, Telegram @VibrixEA";
extern int magic = 2023;
extern int StartTime; // StartTime (00-23)
extern int EndTime = 24; // EndTime (00-23)
extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Time frame
extern bool tracking_News = true;
extern bool Low_Risk_mode = true;
extern bool Standard_trade_mode;
extern bool Agressive_trade_mode;
extern bool BUY_market_lowRisk = true;
extern bool SELL_market_lowRisk = true;
extern bool BUY_market;
extern bool SELL_market;
extern bool BUY_stop;
extern bool SELL_stop;
extern bool BUY_limit;
extern bool SELL_limit;
extern double Lots = 0.01;
extern double AutoLot;
extern double TakeProfitPercent = 2;
extern double All_Prof = 4; // TakeProfit in Money
extern int All_Loss = 500; // Stop- Loss in Money
extern int Stop_Loss_Percentage = 5;
extern int Stop_Loss_on_ATR = 47;
extern string tp_sl = "The EA uses a take profit equal to the stop";
extern int FixTP = 25;
extern int MaxStopLoss = 40; // MaxStopLoss (15-150)
extern int Minsl = 100; // Minsl (5-150)
extern int DeltaStop = 40;
extern int DeltaLimit = 20;
extern int Ma_period = 10; // initialization1 (2-100)
extern int Bb_period = 17; // initialization2 (5-100)
extern int Fast_emaperiod = 10; // Fast (5-100)
extern int Slow_emaperiod = 19; // Slow (5-150)
extern int Signal_smaperiod = 13; // Signal (5-150)
extern int Rsi_period = 12; // initialization3 (5-50)
extern int slipage = 5;
extern bool use_closed_candle = true;

string Is_00060;
int Ii_0005C;
int Ii_00034;
int Ii_00038;
int Ii_0003C;
int Ii_00040;
int Ii_00044;
int Ii_00048;
int Ii_0004C;
int Ii_00050;
int Ii_00054;
int Ii_00058;
int returned_i;
bool returned_b;
long Gl_00000;
long returned_l;
double Gd_00000;
double Gd_00001;
double Gd_00002;
double Gd_00003;
double Gd_00004;
bool Gb_00005;
double Ind_000;
double Gd_00005;
double Gd_00006;
bool Gb_00006;
int Gi_00006;
int Gi_00007;
double Gd_00008;
int Gi_00009;
double Gd_00009;
double Gd_0000A;
int Gi_0000B;
bool Gb_0000B;
double Gd_0000B;
double Ind_003;
int Gi_0000C;
int Gi_0000D;
int Gi_0000E;
int Gi_0000F;
double Id_00000;
int Gi_00010;
double Id_00008;
int Gi_00011;
int Gi_00012;
double Ind_004;
int Ii_0006C;
bool Gb_00013;
int Gi_00013;
int Gi_00014;
double Gd_00015;
int Gi_00015;
int Gi_00016;
int Gi_00017;
int Gi_00018;
int Gi_00019;
int Gi_0001A;
double Gd_0001C;
bool Gb_0001D;
string Gs_0001B;
int Gi_0001F;
int Gi_00020;
int Gi_00021;
int Gi_00022;
int Gi_00023;
int Gi_00024;
int Gi_00025;
int Gi_00026;
int Gi_00027;
double Gd_00026;
double Id_00020;
int Gi_00028;
int Ii_00014;
int Gi_00029;
bool Gb_0002A;
double Gd_0002A;
double Id_00018;
int Gi_0002B;
int Gi_0002C;
bool Gb_0002D;
double Gd_0002D;
double Ind_002;
int Gi_0002E;
int Gi_0002F;
double Gd_0002E;
bool Gb_0002E;
int Gi_00030;
double Gd_00031;
int Gi_00032;
double Gd_00032;
double Gd_00033;
int Gi_00034;
double Gd_00034;
int Gi_00035;
int Gi_00036;
double Gd_00035;
bool Gb_00035;
int Gi_00037;
double Gd_00038;
int Gi_00039;
double Gd_00039;
double Gd_0003A;
int Gi_0003B;
int Ii_00070;
bool Gb_0003B;
int Ii_00074;
double Gd_0003B;
string Is_00028;
int Ii_00010;
bool Gb_0001E;
double Gd_0001E;
int Gi_0001E;
double Gd_0001F;
bool Gb_0001F;
double returned_double;
bool order_check;
int init()
  {
   int Li_FFFFC;
   Id_00000 = 0;
   Id_00008 = 0;
   Ii_00010 = 0;
   Ii_00014 = 10;
   Id_00018 = 999999;
   Id_00020 = -999999;
   Is_00028 = "Vibrix Group EA";
   Ii_00034 = 0;
   Ii_00038 = 0;
   Ii_0003C = 0;
   Ii_00040 = 0;
   Ii_00044 = 0;
   Ii_00048 = 0;
   Ii_0004C = 0;
   Ii_00050 = 0;
   Ii_00054 = 0;
   Ii_00058 = 0;
   Ii_0005C = 0;
   Ii_0006C = (int)AccountBalance();
   Ii_00070 = 0;
   Ii_00074 = 0;


   Is_00060 = " " + AccountCurrency();
   ChartSetInteger(0, 35, 1);
   ChartSetInteger(0, 14, 1);
   ChartSetInteger(0, 13, 1);
   ChartSetInteger(0, 1, 0);
   ChartSetInteger(0, 2, 1);
   ChartSetInteger(0, 4, 1);
   ChartSetInteger(0, 15, 1);
   ChartSetInteger(0, 17, 0);
   Ii_0005C = Bars;
   Ii_00034 = MaxStopLoss;
   if(MaxStopLoss < 15)
     {
      Ii_00034 = 15;
     }
   if(Ii_00034 > 200)
     {
      Ii_00034 = 200;
     }
   Ii_00038 = StartTime;
   if(StartTime < 0)
     {
      Ii_00038 = 0;
     }
   if(Ii_00038 > 23)
     {
      Ii_00038 = 23;
     }
   Ii_0003C = EndTime;
   if(EndTime < 0)
     {
      Ii_0003C = 0;
     }
   if(Ii_0003C > 23)
     {
      Ii_0003C = 23;
     }
   Ii_00040 = Ma_period;
   if(Ma_period < 2)
     {
      Ii_00040 = 2;
     }
   if(Ii_00040 > 100)
     {
      Ii_00040 = 100;
     }
   Ii_00044 = Bb_period;
   if(Bb_period < 5)
     {
      Ii_00044 = 5;
     }
   if(Ii_00044 > 100)
     {
      Ii_00044 = 100;
     }
   Ii_00048 = Fast_emaperiod;
   if(Fast_emaperiod < 5)
     {
      Ii_00048 = 5;
     }
   if(Ii_00048 > 100)
     {
      Ii_00048 = 100;
     }
   Ii_0004C = Slow_emaperiod;
   if(Slow_emaperiod < 5)
     {
      Ii_0004C = 5;
     }
   if(Ii_0004C > 150)
     {
      Ii_0004C = 150;
     }
   Ii_00050 = Signal_smaperiod;
   if(Signal_smaperiod < 5)
     {
      Ii_00050 = 5;
     }
   if(Ii_00050 > 150)
     {
      Ii_00050 = 150;
     }
   Ii_00054 = Rsi_period;
   if(Rsi_period < 5)
     {
      Ii_00054 = 5;
     }
   if(Ii_00054 > 50)
     {
      Ii_00054 = 50;
     }
   Ii_00058 = Minsl;
   if(Minsl < 5)
     {
      Ii_00058 = 5;
     }
   if(Ii_00058 > 100)
     {
      Ii_00058 = 100;
     }
   if(_Digits != 3)
     {
      if(_Digits != 5)
         return 0;
     }
   Ii_00034 = Ii_00034 * 10;
   Ii_00058 = Ii_00058 * 10;
   DeltaStop = DeltaStop * 10;
   DeltaLimit = DeltaLimit * 10;
   FixTP = FixTP * 10;

   Li_FFFFC = 0;
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   double Ld_FFFF8;
   double Ld_FFFF0;
   string Ls_FFFE0;
   bool Lb_FFFDF;
   double Ld_FFFD0;
   double Ld_FFFC8;
   double Ld_FFFC0;
   double Ld_FFFB8;
   double Ld_FFFB0;
   double Ld_FFFA8;
   double Ld_FFFA0;
   double Ld_FFF98;
   int Li_FFF94;
   int Li_FFF90;
   double Ld_FFF88;
   double Ld_FFF80;
   long Ll_FFF78;


   if(use_closed_candle)
     {
      if(Bars == Ii_0005C)
         return;
      Ii_0005C = Bars;
     }
   if(DayOfWeek() == 0)
      return;
   if(DayOfWeek() == 6)
      return;
   if(!IsTradeAllowed())
      return;
   Ld_FFFF8 = 0;
   Gd_00000 = Lots;
   Gd_00001 = AccountFreeMargin();
   Gd_00002 = MarketInfo(_Symbol, MODE_MARGINREQUIRED);
   Gd_00003 = MarketInfo(_Symbol, MODE_MINLOT);
   Gd_00004 = MarketInfo(_Symbol, MODE_MAXLOT);
   if((Lots < Gd_00003))
     {
      Gd_00000 = Gd_00003;
     }
   if((Gd_00000 > Gd_00004))
     {
      Gd_00000 = Gd_00004;
     }
   if(((Gd_00000 * Gd_00002) > Gd_00001))
     {
      Gd_00005 = 0;
     }
   else
     {
      Gd_00005 = Gd_00000;
     }
   Ld_FFFF8 = Gd_00005;
   Gd_00006 = AccountEquity();
   Ld_FFFF0 = (Gd_00006 - AccountBalance());
   if((Ld_FFFF0 >= ((AccountEquity() * TakeProfitPercent) / 100)))
     {
      tmp_str00000 = "Profit";
      Gi_00006 = OrdersTotal() - 1;
      Gi_00007 = Gi_00006;
      if(Gi_00006 >= 0)
        {
         do
           {
            if(OrderSelect(Gi_00007, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == magic)
              {
               if(OrderType() == OP_BUY)
                 {
                  if(OrderClose(OrderTicket(), OrderLots(), Bid, 0, 16711680))
                    {
                     Print("Close Buy: ", _Symbol, "/", tmp_str00000);
                    }
                  else
                    {
                     Print("Error Close Buy: ", _Symbol, "/", tmp_str00000, " / ", GetLastError());
                    }
                 }
               if(OrderType() == OP_SELL)
                 {
                  if(OrderClose(OrderTicket(), OrderLots(), Ask, 0, 255))
                    {
                     Print("Close Sell: ", _Symbol, "/", tmp_str00000);
                    }
                  else
                    {
                     Print("Error Close Sell: ", _Symbol, "/", tmp_str00000, " / ", GetLastError());
                    }
                 }
              }
            Gi_00007 = Gi_00007 - 1;
           }
         while(Gi_00007 >= 0);
        }
     }
   if((AutoLot != 0))
     {
      Lots = NormalizeDouble(((AccountFreeMargin() * AutoLot) / 10000), 2);
     }
   if(IsTradeAllowed() != true)
     {
      Gi_0000B = 255;
      tmp_str00001 = "Autotrading disabled";
      tmp_str00002 = "IsTradeAllowed";
      if(ObjectFind(tmp_str00002) == -1)
        {
         ObjectCreate(0, tmp_str00002, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
         ObjectSet(tmp_str00002, OBJPROP_CORNER, 1);
         ObjectSet(tmp_str00002, OBJPROP_XDISTANCE, 5);
         ObjectSet(tmp_str00002, OBJPROP_YDISTANCE, 15);
        }
      ObjectSetText(tmp_str00002, tmp_str00001, 15, "Arial", Gi_0000B);
      return ;
     }
   Gi_0000C = 32768;
   tmp_str00003 = "Autotrading Enabled";
   tmp_str00004 = "IsTradeAllowed";
   if(ObjectFind(tmp_str00004) == -1)
     {
      ObjectCreate(0, tmp_str00004, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str00004, OBJPROP_CORNER, 1);
      ObjectSet(tmp_str00004, OBJPROP_XDISTANCE, 5);
      ObjectSet(tmp_str00004, OBJPROP_YDISTANCE, 15);
     }
   ObjectSetText(tmp_str00004, tmp_str00003, 15, "Arial", Gi_0000C);
   Gi_0000D = 16777215;
   tmp_str00005 = DoubleToString(AccountBalance(), 2);
   tmp_str00006 = StringConcatenate("Balance ", tmp_str00005, Is_00060);
   tmp_str00007 = "Balance";
   if(ObjectFind(tmp_str00007) == -1)
     {
      ObjectCreate(0, tmp_str00007, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str00007, OBJPROP_CORNER, 1);
      ObjectSet(tmp_str00007, OBJPROP_XDISTANCE, 5);
      ObjectSet(tmp_str00007, OBJPROP_YDISTANCE, 35);
     }
   ObjectSetText(tmp_str00007, tmp_str00006, 15, "Arial", Gi_0000D);
   Gi_0000E = 42495;
   tmp_str00008 = DoubleToString(AccountEquity(), 2);
   tmp_str00009 = StringConcatenate("Equity ", tmp_str00008, Is_00060);
   tmp_str0000A = "Equity";
   if(ObjectFind(tmp_str0000A) == -1)
     {
      ObjectCreate(0, tmp_str0000A, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str0000A, OBJPROP_CORNER, 1);
      ObjectSet(tmp_str0000A, OBJPROP_XDISTANCE, 5);
      ObjectSet(tmp_str0000A, OBJPROP_YDISTANCE, 55);
     }
   ObjectSetText(tmp_str0000A, tmp_str00009, 15, "Arial", Gi_0000E);
   Gi_0000F = 255;
   tmp_str0000B = DoubleToString(Id_00000, 2);
   tmp_str0000C = StringConcatenate("Stop-Loss ", tmp_str0000B, Is_00060);
   tmp_str0000D = "Stop-Loss";
   if(ObjectFind(tmp_str0000D) == -1)
     {
      ObjectCreate(0, tmp_str0000D, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str0000D, OBJPROP_CORNER, 1);
      ObjectSet(tmp_str0000D, OBJPROP_XDISTANCE, 5);
      ObjectSet(tmp_str0000D, OBJPROP_YDISTANCE, 80);
     }
   ObjectSetText(tmp_str0000D, tmp_str0000C, 15, "Arial", Gi_0000F);
   Gi_00010 = 32768;
   tmp_str0000E = DoubleToString(Id_00008, 2);
   tmp_str0000F = StringConcatenate("Take-Profit ", tmp_str0000E, Is_00060);
   tmp_str00010 = "Take-Profit";
   if(ObjectFind(tmp_str00010) == -1)
     {
      ObjectCreate(0, tmp_str00010, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str00010, OBJPROP_CORNER, 1);
      ObjectSet(tmp_str00010, OBJPROP_XDISTANCE, 5);
      ObjectSet(tmp_str00010, OBJPROP_YDISTANCE, 105);
     }
   ObjectSetText(tmp_str00010, tmp_str0000F, 15, "Arial", Gi_00010);
   Gi_00011 = 1;
   Gi_00012 = 255;
   if(((AccountBalance() - Ii_0006C) >= 0))
     {
      Gi_00013 = 16119285;
     }
   else
     {
      Gi_00013 = Gi_00012;
     }
   Gi_00014 = Gi_00013;
   tmp_str00011 = DoubleToString((AccountBalance() - Ii_0006C), 2);
   tmp_str00012 = StringConcatenate("Profit ", tmp_str00011, Is_00060);
   tmp_str00013 = "Profit";
   if(ObjectFind(tmp_str00013) == -1)
     {
      ObjectCreate(0, tmp_str00013, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str00013, OBJPROP_CORNER, Gi_00011);
      ObjectSet(tmp_str00013, OBJPROP_XDISTANCE, 5);
      ObjectSet(tmp_str00013, OBJPROP_YDISTANCE, 128);
     }
   ObjectSetText(tmp_str00013, tmp_str00012, 15, "Arial", Gi_00014);
   Gi_00015 = 16711680;
   tmp_str00014 = "Vibrix Group EA";
   tmp_str00015 = "Vibrix Group EA";
   if(ObjectFind(tmp_str00015) == -1)
     {
      ObjectCreate(0, tmp_str00015, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str00015, OBJPROP_CORNER, 8);
      ObjectSet(tmp_str00015, OBJPROP_XDISTANCE, 10);
      ObjectSet(tmp_str00015, OBJPROP_YDISTANCE, 25);
     }
   ObjectSetText(tmp_str00015, tmp_str00014, 15, "Arial", Gi_00015);
   Gi_00016 = 16711680;
   tmp_str00016 = "https://vibrix-ea.tech/";
   tmp_str00017 = "https://vibrix-ea.tech/";
   if(ObjectFind(tmp_str00017) == -1)
     {
      ObjectCreate(0, tmp_str00017, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str00017, OBJPROP_CORNER, 8);
      ObjectSet(tmp_str00017, OBJPROP_XDISTANCE, 10);
      ObjectSet(tmp_str00017, OBJPROP_YDISTANCE, 45);
     }
   ObjectSetText(tmp_str00017, tmp_str00016, 15, "Arial", Gi_00016);
   Gi_00017 = 16777215;
   tmp_str00018 = "Live trading";
   tmp_str00019 = "Live trading";
   if(ObjectFind(tmp_str00019) == -1)
     {
      ObjectCreate(0, tmp_str00019, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str00019, OBJPROP_CORNER, 8);
      ObjectSet(tmp_str00019, OBJPROP_XDISTANCE, 10);
      ObjectSet(tmp_str00019, OBJPROP_YDISTANCE, 65);
     }
   ObjectSetText(tmp_str00019, tmp_str00018, 15, "Arial", Gi_00017);
   Gi_00018 = 16777215;
   tmp_str0001A = "Initial balance USD";
   tmp_str0001B = "Initial balance USD";
   if(ObjectFind(tmp_str0001B) == -1)
     {
      ObjectCreate(0, tmp_str0001B, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str0001B, OBJPROP_CORNER, 8);
      ObjectSet(tmp_str0001B, OBJPROP_XDISTANCE, 10);
      ObjectSet(tmp_str0001B, OBJPROP_YDISTANCE, 85);
     }
   ObjectSetText(tmp_str0001B, tmp_str0001A, 15, "Arial", Gi_00018);
   Gi_00019 = 16777215;
   tmp_str0001C = "Low Risk trading mode";
   tmp_str0001D = "Low Risk trading mode ";
   if(ObjectFind(tmp_str0001D) == -1)
     {
      ObjectCreate(0, tmp_str0001D, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str0001D, OBJPROP_CORNER, 8);
      ObjectSet(tmp_str0001D, OBJPROP_XDISTANCE, 10);
      ObjectSet(tmp_str0001D, OBJPROP_YDISTANCE, 105);
     }
   ObjectSetText(tmp_str0001D, tmp_str0001C, 15, "Arial", Gi_00019);
   Gi_0001A = 16777215;
   tmp_str0001E = "News control Enabled";
   tmp_str0001F = "News control Enabled ";
   if(ObjectFind(tmp_str0001F) == -1)
     {
      ObjectCreate(0, tmp_str0001F, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
      ObjectSet(tmp_str0001F, OBJPROP_CORNER, 8);
      ObjectSet(tmp_str0001F, OBJPROP_XDISTANCE, 10);
      ObjectSet(tmp_str0001F, OBJPROP_YDISTANCE, 125);
     }
   ObjectSetText(tmp_str0001F, tmp_str0001E, 15, "Arial", Gi_0001A);
   Gd_0001C = Ld_FFFF8;
   returned_double = SymbolInfoDouble(NULL, 34);
   Gb_0001D = (Ld_FFFF8 < returned_double);
   if(Gb_0001D)
     {
      Ls_FFFE0 = StringFormat("Volume is less than the minimum allowable SYMBOL_VOLUME_MIN=%.2f", returned_double);
      Gb_0001D = false;
     }
   else
     {
      returned_double = SymbolInfoDouble(NULL, 35);
      if((Gd_0001C > returned_double))
        {
         Ls_FFFE0 = StringFormat("Volume is more than the maximum allowable SYMBOL_VOLUME_MAX=%.2f", returned_double);
         Gb_0001D = false;
        }
      else
        {
         returned_double = SymbolInfoDouble(NULL, 36);
         Gd_0001E = round((Gd_0001C / returned_double));
         Gi_0001E = (int)Gd_0001E;
         Gd_0001F = fabs(((Gi_0001E * returned_double) - Gd_0001C));
         if((Gd_0001F > 1E-07))
           {
            Ls_FFFE0 = StringFormat("The volume is not a multiple of the minimum gradation SYMBOL_VOLUME_STEP=%.2f, closest correct volume %.2f", returned_double, (Gi_0001E * returned_double));
            Gb_0001D = false;
           }
         else
           {
            Ls_FFFE0 = "Correct value of volume";
            Gb_0001D = true;
           }
        }
     }
   Lb_FFFDF = Gb_0001D;
   if(Gb_0001D == 0)
     {
      return ;
     }
   Ld_FFFD0 = iMA(NULL, TimeFrame, Ii_00040, 0, 1, 0, 1);
   Ld_FFFC8 = iMA(NULL, TimeFrame, Ii_00040, 0, 1, 0, 3);
   Ld_FFFC0 = iBands(NULL, TimeFrame, Ii_00044, 2, 0, 0, 0, 1);
   Ld_FFFB8 = iMACD(_Symbol, TimeFrame, Ii_00048, Ii_0004C, Ii_00050, 0, 0, 0);
   Ld_FFFB0 = iMACD(_Symbol, TimeFrame, Ii_00048, Ii_0004C, Ii_00050, 0, 1, 0);
   Ld_FFFA8 = iMACD(_Symbol, TimeFrame, Ii_00048, Ii_0004C, Ii_00050, 0, 0, 1);
   Ld_FFFA0 = iMACD(_Symbol, TimeFrame, Ii_00048, Ii_0004C, Ii_00050, 0, 1, 1);
   Ld_FFF98 = iRSI(NULL, TimeFrame, Ii_00054, 0, 1);
   Gi_0001F = magic;
   Gi_00020 = 0;
   Gi_00021 = 0;
   Gi_00022 = OrdersTotal() - 1;
   Gi_00023 = Gi_00022;
   if(Gi_00022 >= 0)
     {
      do
        {
         if(OrderSelect(Gi_00023, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_0001F && OrderType() == Gi_00020)
           {
            Gi_00021 = Gi_00021 + 1;
           }
         Gi_00023 = Gi_00023 - 1;
        }
      while(Gi_00023 >= 0);
     }
   Li_FFF94 = Gi_00021;
   Gi_00022 = magic;
   Gi_00024 = 1;
   Gi_00025 = 0;
   Gi_00026 = OrdersTotal() - 1;
   Gi_00027 = Gi_00026;
   if(Gi_00026 >= 0)
     {
      do
        {
         if(OrderSelect(Gi_00027, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Gi_00022 && OrderType() == Gi_00024)
           {
            Gi_00025 = Gi_00025 + 1;
           }
         Gi_00027 = Gi_00027 - 1;
        }
      while(Gi_00027 >= 0);
     }
   Li_FFF90 = Gi_00025;
   Gd_00026 = Id_00020;
   Gi_00028 = Ii_00014;
   Gi_00029 = 1;
   if(Ii_00014 >= 1)
     {
      do
        {
         returned_double = iHigh(NULL, 0, Gi_00029);
         if((returned_double > Gd_00026))
           {
            Gd_00026 = returned_double;
           }
         Gi_00029 = Gi_00029 + 1;
        }
      while(Gi_00029 <= Gi_00028);
     }
   Id_00020 = Gd_00026;
   Gd_0002A = Id_00018;
   Gi_0002B = Ii_00014;
   Gi_0002C = 1;
   if(Ii_00014 >= 1)
     {
      do
        {
         returned_double = iLow(NULL, 0, Gi_0002C);
         if((returned_double < Gd_0002A))
           {
            Gd_0002A = returned_double;
           }
         Gi_0002C = Gi_0002C + 1;
        }
      while(Gi_0002C <= Gi_0002B);
     }
   Id_00018 = Gd_0002A;
   Gd_0002D = (Ask - Gd_0002A);
   Ld_FFF88 = (Gd_0002D / _Point);
   Gd_0002D = (Id_00020 - Bid);
   Ld_FFF80 = (Gd_0002D / _Point);
   if((All_Prof > 0))
     {
      Gd_0002D = 0;
      Gi_0002E = OrdersTotal() - 1;
      Gi_0002F = Gi_0002E;
      if(Gi_0002E >= 0)
        {
         do
           {
            if(OrderSelect(Gi_0002F, 0, 0) == true && OrderSymbol() == _Symbol && OrderMagicNumber() == magic)
              {
               if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                 {

                  Gd_0002E = OrderProfit();
                  Gd_0002E = (Gd_0002E + OrderSwap());
                  Gd_0002D = ((Gd_0002E + OrderCommission()) + Gd_0002D);
                 }
              }
            Gi_0002F = Gi_0002F - 1;
           }
         while(Gi_0002F >= 0);
        }
      if((Gd_0002D >= All_Prof))
        {
         tmp_str00020 = "Profit";
         Gi_0002E = OrdersTotal() - 1;
         Gi_00030 = Gi_0002E;
         if(Gi_0002E >= 0)
           {
            do
              {
               if(OrderSelect(Gi_00030, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == magic)
                 {
                  if(OrderType() == OP_BUY)
                    {
                     if(OrderClose(OrderTicket(), OrderLots(), Bid, 0, 16711680))
                       {
                        Print("Close Buy: ", _Symbol, "/", tmp_str00020);
                       }
                     else
                       {
                        Print("Error Close Buy: ", _Symbol, "/", tmp_str00020, " / ", GetLastError());
                       }
                    }
                  if(OrderType() == OP_SELL)
                    {
                     if(OrderClose(OrderTicket(), OrderLots(), Ask, 0, 255))
                       {
                        Print("Close Sell: ", _Symbol, "/", tmp_str00020);
                       }
                     else
                       {
                        Print("Error Close Sell: ", _Symbol, "/", tmp_str00020, " / ", GetLastError());
                       }
                    }
                 }
               Gi_00030 = Gi_00030 - 1;
              }
            while(Gi_00030 >= 0);
           }
        }
     }
   if(All_Loss > 0)
     {
      Gd_00034 = 0;
      Gi_00035 = OrdersTotal() - 1;
      Gi_00036 = Gi_00035;
      if(Gi_00035 >= 0)
        {
         do
           {
            if(OrderSelect(Gi_00036, 0, 0) == true && OrderSymbol() == _Symbol && OrderMagicNumber() == magic)
              {
               if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                 {

                  Gd_00035 = OrderProfit();
                  Gd_00035 = (Gd_00035 + OrderSwap());
                  Gd_00034 = ((Gd_00035 + OrderCommission()) + Gd_00034);
                 }
              }
            Gi_00036 = Gi_00036 - 1;
           }
         while(Gi_00036 >= 0);
        }
      Gi_00035 = -All_Loss;
      if((Gd_00034 <= Gi_00035))
        {
         tmp_str00021 = "Loss";
         Gi_00035 = OrdersTotal() - 1;
         Gi_00037 = Gi_00035;
         if(Gi_00035 >= 0)
           {
            do
              {
               if(OrderSelect(Gi_00037, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == magic)
                 {
                  if(OrderType() == OP_BUY)
                    {
                     if(OrderClose(OrderTicket(), OrderLots(), Bid, 0, 16711680))
                       {
                        Print("Close Buy: ", _Symbol, "/", tmp_str00021);
                       }
                     else
                       {
                        Print("Error Close Buy: ", _Symbol, "/", tmp_str00021, " / ", GetLastError());
                       }
                    }
                  if(OrderType() == OP_SELL)
                    {
                     if(OrderClose(OrderTicket(), OrderLots(), Ask, 0, 255))
                       {
                        Print("Close Sell: ", _Symbol, "/", tmp_str00021);
                       }
                     else
                       {
                        Print("Error Close Sell: ", _Symbol, "/", tmp_str00021, " / ", GetLastError());
                       }
                    }
                 }
               Gi_00037 = Gi_00037 - 1;
              }
            while(Gi_00037 >= 0);
           }
        }
     }
   Ll_FFF78 = TimeCurrent();
   if(TimeHour(Ll_FFF78) < Ii_00038)
      return;
   if(TimeHour(Ll_FFF78) > Ii_0003C)
      return;
   if(BUY_market_lowRisk != 0 && Ii_00070 == 0 && (Ld_FFFD0 > Ld_FFFC0) && (Ld_FFFC8 < Ld_FFFC0) && (Ld_FFFB8 > Ld_FFFB0) && (Ld_FFF98 > 20) && (Ld_FFF98 < 80))
     {
      Ii_00074 = 0;
      Ii_00010 = OrderSend(_Symbol, 0, Ld_FFFF8, Ask, slipage, 0, ((FixTP * _Point) + Ask), Is_00028, magic, 0, 32768);
      if(Ii_00010 > 0)
        {
         Id_00000 = Id_00018;
         Gd_0003B = (Bid - Id_00018);
         if((Gd_0003B > (Ii_00034 * _Point)))
           {
            Gd_0003B = (Ii_00034 * _Point);
            Id_00000 = (Bid - Gd_0003B);
           }
         order_check = OrderSelect(Ii_00010, 1, 0);
         Ii_00070 = 1;
        }
     }
   if(BUY_market != 0 && (Ld_FFFD0 > Ld_FFFC0) && (Ld_FFFC8 < Ld_FFFC0) && (Ld_FFFB8 > Ld_FFFB0) && (Ld_FFF98 > 20) && (Ld_FFF98 < 80))
     {
      Ii_00010 = OrderSend(_Symbol, 0, Ld_FFFF8, Ask, slipage, 0, ((FixTP * _Point) + Ask), Is_00028, magic, 0, 32768);
      if(Ii_00010 > 0)
        {
         Id_00000 = Id_00018;
         Gd_0003B = (Bid - Id_00018);
         if((Gd_0003B > (Ii_00034 * _Point)))
           {
            Gd_0003B = (Ii_00034 * _Point);
            Id_00000 = (Bid - Gd_0003B);
           }
         order_check = OrderSelect(Ii_00010, 1, 0);
        }
     }
   if(BUY_stop != 0 && (Ld_FFFD0 > Ld_FFFC0) && (Ld_FFFC8 < Ld_FFFC0) && (Ld_FFFB8 > Ld_FFFB0) && (Ld_FFF98 > 20) && (Ld_FFF98 < 80))
     {
      Ii_00010 = OrderSend(_Symbol, 4, Ld_FFFF8, ((DeltaStop * _Point) + Ask), slipage, 0, 0, Is_00028, magic, 0, 32768);
      if(Ii_00010 > 0)
        {
         Id_00000 = Id_00018;
         Gd_0003B = (Bid - Id_00018);
         if((Gd_0003B > (Ii_00034 * _Point)))
           {
            Gd_0003B = (Ii_00034 * _Point);
            Id_00000 = (Bid - Gd_0003B);
           }
         Id_00008 = ((Bid - Id_00018) + Bid);
         order_check = OrderSelect(Ii_00010, 1, 0);
        }
     }
   if(BUY_limit != 0 && (Ld_FFFD0 < Ld_FFFC0) && (Ld_FFFC8 > Ld_FFFC0) && (Ld_FFFA8 < Ld_FFFA0) && (Ld_FFF98 < 80) && (Ld_FFF98 > 20))
     {
      Gd_0003B = (DeltaLimit * _Point);
      Ii_00010 = OrderSend(_Symbol, 2, Ld_FFFF8, (Bid - Gd_0003B), slipage, 0, 0, Is_00028, magic, 0, 32768);
      if(Ii_00010 > 0)
        {
         Id_00000 = Id_00018;
         Gd_0003B = (Bid - Id_00018);
         if((Gd_0003B > (Ii_00034 * _Point)))
           {
            Gd_0003B = (Ii_00034 * _Point);
            Id_00000 = (Bid - Gd_0003B);
           }
         Id_00008 = ((Bid - Id_00018) + Bid);
         if(OrderSelect(Ii_00010, 1, 0))
           {
            order_check = OrderModify(Ii_00010, OrderOpenPrice(), Id_00000, Id_00008, 0, 4294967295);
           }
        }
     }
   if(SELL_market_lowRisk != 0 && Ii_00074 == 0 && (Ld_FFFD0 < Ld_FFFC0) && (Ld_FFFC8 > Ld_FFFC0) && (Ld_FFFA8 < Ld_FFFA0) && (Ld_FFF98 < 80) && (Ld_FFF98 > 20))
     {
      Ii_00070 = 0;
      Gd_0003B = (Id_00008 * _Point);
      Ii_00010 = OrderSend(_Symbol, 1, Ld_FFFF8, Bid, slipage, 0, (Bid - (FixTP * _Point)), Is_00028, magic, 0, 255);
      if(Ii_00010 > 0)
        {
         Id_00000 = Id_00020;
         Gd_0003B = (Ask + Id_00020);
         if((Gd_0003B > (Ii_00034 * _Point)))
           {
            Id_00000 = ((Ii_00034 * _Point) + Ask);
           }
         order_check = OrderSelect(Ii_00010, 1, 0);
         Ii_00074 = 1;
        }
     }
   if(SELL_market != 0 && (Ld_FFFD0 < Ld_FFFC0) && (Ld_FFFC8 > Ld_FFFC0) && (Ld_FFFA8 < Ld_FFFA0) && (Ld_FFF98 < 80) && (Ld_FFF98 > 20))
     {
      Gd_0003B = (Id_00008 * _Point);
      Ii_00010 = OrderSend(_Symbol, 1, Ld_FFFF8, Bid, slipage, 0, (Bid - (FixTP * _Point)), Is_00028, magic, 0, 255);
      if(Ii_00010 > 0)
        {
         Id_00000 = Id_00020;
         Gd_0003B = (Ask + Id_00020);
         if((Gd_0003B > (Ii_00034 * _Point)))
           {
            Id_00000 = ((Ii_00034 * _Point) + Ask);
           }
         order_check = OrderSelect(Ii_00010, 1, 0);
        }
     }
   if(SELL_stop != 0 && (Ld_FFFD0 < Ld_FFFC0) && (Ld_FFFC8 > Ld_FFFC0) && (Ld_FFFA8 < Ld_FFFA0) && (Ld_FFF98 < 80) && (Ld_FFF98 > 20))
     {
      Gd_0003B = (DeltaStop * _Point);
      Ii_00010 = OrderSend(_Symbol, 5, Ld_FFFF8, (Bid - Gd_0003B), slipage, 0, 0, Is_00028, magic, 0, 255);
      if(Ii_00010 > 0)
        {
         Id_00000 = Id_00020;
         Gd_0003B = (Ask + Id_00020);
         if((Gd_0003B > (Ii_00034 * _Point)))
           {
            Id_00000 = ((Ii_00034 * _Point) + Ask);
           }
         Gd_0003B = (Id_00020 - Ask);
         Id_00008 = (Ask - Gd_0003B);
         order_check = OrderSelect(Ii_00010, 1, 0);
        }
     }
   if(SELL_limit == 0)
      return;
   if((Ld_FFFD0 <= Ld_FFFC0))
      return;
   if((Ld_FFFC8 >= Ld_FFFC0))
      return;
   if((Ld_FFFB8 <= Ld_FFFB0))
      return;
   if((Ld_FFF98 <= 20))
      return;
   if((Ld_FFF98 >= 80))
      return;
   if((Ld_FFF88 < Ii_00058))
      return;
   Gi_0003B = Ii_00058 * 5;
   if((Ld_FFF88 > Gi_0003B))
      return;
   Ii_00010 = OrderSend(_Symbol, 3, Ld_FFFF8, ((DeltaLimit * _Point) + Ask), slipage, 0, 0, Is_00028, magic, 0, 255);
   if(Ii_00010 <= 0)
      return;
   Id_00000 = Id_00020;
   Gd_0003B = (Ask + Id_00020);
   if((Gd_0003B > (Ii_00034 * _Point)))
     {
      Id_00000 = ((Ii_00034 * _Point) + Ask);
     }
   Gd_0003B = (Id_00020 - Ask);
   Id_00008 = (Ask - Gd_0003B);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }


//+------------------------------------------------------------------+

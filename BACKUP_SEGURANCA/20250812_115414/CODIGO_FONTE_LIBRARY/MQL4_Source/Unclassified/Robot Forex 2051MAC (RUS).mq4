//+==========================================================================+
//|                          Robot Forex 2051 Bay Long (RUS) (GBPUSD M1).mq4 |
//|                                            Copyright � 2009, Eracash.com |
//|                                                   http://www.eracash.com |
//|           �������������� � ��������������� ��������� LogicMansLaboratory |
//|                                        http://logicmanslaboratory.0pk.ru |
//|                                                              Moscow 2011 |
//+==========================================================================+
#property copyright "Copyright � 2009, Eracash.com"
#property link      "http://www.eracash.com"
//==================================================================================================================================
#property show_inputs
//==================================================================================================================================
#include <stderror.mqh>
#include <stdlib.mqh>
//==================================================================================================================================
extern string ���������_���������    =  "��������� ���������";   // Init Parameters
extern int    �����                  = 12345; // g_magic_208     Magic             (����������������� ����� ������������� ������� ����� ������ - ��� �� �� ������� �� �������� ������ �������)
extern int    ���_����_0_1_2         =     2; // gd_112          Lotdecimal        (0=���������� ���� 1.0;  1=�������� 0.1;  2=��������� 0.01)
extern double ���������������        =   5.0; // g_slippage_96   Slippage          (�������� ���������� ������ ��� ������)
//-----------------------------------------------------------------------------------------
extern string ���������_����         =  "��������� ����";        // Parameters Lot
extern double ���                    =  0.01; // Lots            Lots              (������ ���� ��� ������� ������)
extern bool   ���������_����         =  TRUE; // gi_84           UseAdd            (�������� ��������� ����)
extern double ���������_����_����    =  1.08; // gd_88           LotExponent       (�����������, �� ������� ���������� ��������� ���)
extern int    ���_��������_0_1_2     =     1; // gi_76           MMType            (������� ������ ��������: 0=��������; 1=������; 2=��������-�� ������������ � ������ ������)
//-----------------------------------------------------------------------------------------
extern string ���������_�����        =  "��������� �����";       // Input Parameters
extern int    ��������_������        =   100; // MaxTrades       MaxTrades         (���������� ���������� ���������� ����������� ������)
extern double ���_������_������      =  10.0; // g_pips_152      PipStep           (���� ���������� ����� ���� � ����� �� 10 �������, �� �������� ��������� ��������� ����� �������� ������)
//-----------------------------------------------------------------------------------------
extern string ���������_������       =  "��������� ������";      // Output Parameters
extern double ����_����              =   0.0; // g_pips_128      Stoploss          (�������� ������ �� ������ ������ � �������)
extern double ����_������            =  10.0; // g_pips_120      TakeProfit        (�������� ������ �� ������ ������� � �������)
extern bool   ��������_����          = FALSE; // gi_176  TRUE    UseTrailingStop   (��������� ��������� ��������� �������)
extern double C����_���������        =  10.0; // gd_136          StartTrailingPips (����� ��������� � �������)
extern double ���_���������          =  10.0; // gd_144          StepTrailingPips  (��� ��������� � �������)
//-----------------------------------------------------------------------------------------
extern string �������_�����          =  "������� �����";         // Input Filters
extern bool   ���������_������       = FALSE; // gi_192          TimeFilter        (��� ������������� ������� ����������� ������� ������� - ���� ������ ������������ ���� ��� ���� ��� � ������� ������������� �������,- ������: ��� �������� ������� ������� ����� �������������, ����� ����� ��� ��� ������ ���������� ���� ����������� ������ �������������)
extern bool   ��������_��_�����      = FALSE; // UseHourTrade    UseHourTrade      (��������� �������� �� �����)
extern int    ������_��������        =     0; // StartHour       StartHour         (������ �������� ������ �� �����)
extern int    ������_��������        =     8; // EndHour         EndHour           (���������� �������� ������ �� �����)
//-----------------------------------------------------------------------------------------
extern string �������_������         =  "������� ������";        // Output Filters
extern bool   ���������_��_��������  = FALSE; // gi_80           UseClose          (��������� �������� ������ �� �������� ����-��� � ������)
extern bool   ����_��_������         = FALSE; // gi_164          UseEquityStop     (��������� �������� �� ��������� ������� �� ������)
extern double ����_��_������_������� =  20.0; // gd_168          TotalEquityRisk   (�������� �� ������ � %, ��� �������� ���� ������)
extern bool   ����_��_��������       = FALSE; // gi_180          UseTimeOut        (������������ �������: ��������� ������ ���� ��� "�����" ������� �����)
extern double ����_��_��������_����  =   0.0; // gd_184          MaxTradeOpenHours (����� �������� � �����: ����� ������� ��������� �������� ������)

//==================================================================================================================================


extern double MACDOpenLevel=3;
extern double MACDCloseLevel=3;
extern double MATrendPeriod=13;


// extern double DecreaseFactor     = 3;
// extern double MovingPeriod       = 12;
// extern double MovingShift        = 6;



//==================================================================================================================================
double g_price_212;
double gd_220;
double gd_unused_228;
double gd_unused_236;
double g_price_244;
double g_bid_252;
double g_ask_260;
double gd_268;
double gd_276;
double gd_284;
bool   gi_292;
string gs_296         = "Robot Forex 2051 Bay ";
int    g_time_304     =     0;
int    gi_308;
int    gi_312         =     0;
double gd_316;
int    g_pos_324      =     0;
int    gi_328;
double gd_332         =   0.0;
bool   gi_340         = FALSE;
bool   gi_344         = FALSE;
bool   gi_348         = FALSE;
int    gi_352;
bool   gi_356         = FALSE;
int    g_datetime_360 =     0;
int    g_datetime_364 =     0;
double gd_368;
double gd_376;
//-----------------------------
int    gi_222 = 1;
double gi_1000;
//==================================================================================================================================
int init() {
   gd_284 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   if (IsTesting() ==  TRUE) Display_Info(); //  TRUE
   if (IsTesting() == FALSE) Display_Info(); // FALSE
   double step = MarketInfo(Symbol(), MODE_LOTSTEP);
   switch(step) {
      case 0.01 : ���_����_0_1_2 = 2; break;
      case  0.1 : ���_����_0_1_2 = 1; break;
      case    1 : ���_����_0_1_2 = 0; break;
   }
      if (Digits == 5 || Digits == 3) gi_222 = 10;
         return (0);
         
         
         

}
//==================================================================================================================================
int deinit() {
   return (0);
}
//==================================================================================================================================
int start() {
   Display_Info();
//----------------------------------------------------------------------------------------------
//  
 double ma;
double MacdCurrent, MacdPrevious, SignalCurrent;
   double SignalPrevious, MaCurrent, MaPrevious;

 ObjectCreate ("klc14", OBJ_LABEL, 0, 0, 0);
//   ObjectSetText("klc14", "��������������:  LogicMansLaboratory.0pk.ru", 3, "System", DimGray);
//   ObjectSet    ("klc14", OBJPROP_CORNER, 2);
//   ObjectSet    ("klc14", OBJPROP_XDISTANCE, 93); // 105
//   ObjectSet    ("klc14", OBJPROP_YDISTANCE, 5);

 //  ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);

   MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);





//----------------------------------------------------------------------------------------------
   double l_ord_lots_0;
   double l_ord_lots_8;
   double l_iclose_16;
   double l_iclose_24;
   if (��������_��_�����) {
      if (!(Hour() >= ������_�������� && Hour() <= ������_��������)) {
         CloseThisSymbolAll();
         Comment("����� ��� �������� ��� �� ������!");
         return (0);
      }
   }
   string ls_36 = "false"; // ls_32
   string ls_44 = "false"; // ls_40
   if (���������_������ == FALSE || (���������_������ && (������_�������� > ������_�������� && (Hour() >= ������_�������� && Hour() <= ������_��������)) || (������_�������� > ������_�������� && !(Hour() >= ������_�������� && Hour() <= ������_��������)))) ls_36 = "true";
   if (���������_������ && (������_�������� > ������_�������� && !(Hour() >= ������_�������� && Hour() <= ������_��������)) || (������_�������� > ������_�������� && (Hour() >= ������_�������� && Hour() <= ������_��������))) ls_44 = "true";
   if (��������_����) TrailingAlls(C����_��������� * gi_222, ���_��������� * gi_222, g_price_244); // !
   if (����_��_��������) {
      if (TimeCurrent() >= gi_308) {
         CloseThisSymbolAll();
         Print("B�� ������ ����� ������� ��-�� ����-����");
      }
   }
   if (g_time_304 == Time[0]) return (0);
   g_time_304 = Time[0];
   double ld_52 = CalculateProfit(); // ld_48
   if (����_��_������) {
      if (ld_52 < 0.0 && MathAbs(ld_52) > ����_��_������_������� / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("B�� ������ ����� ������� ��-�� ���������� ������");
         gi_356 = FALSE;
      }
   }
   gi_328 = CountTrades();
   if (gi_328 == 0) gi_292 = FALSE;
   for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
      OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) {
         if (OrderType() == OP_BUY) {
            gi_344 = TRUE;
            gi_348 = FALSE;
            l_ord_lots_0 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) {
         if (OrderType() == OP_SELL) {
            gi_344 = FALSE;
            gi_348 = TRUE;
            l_ord_lots_8 = OrderLots();
            break;
         }
      }
   }
   if (gi_328 > 0 && gi_328 <= ��������_������) {
      RefreshRates();
      gd_268 = FindLastBuyPrice();
      gd_276 = FindLastSellPrice();
      if (gi_344 && gd_268 - Ask >= ���_������_������ * gi_222 * Point) gi_340 = TRUE;
      if (gi_348 && Bid - gd_276 >= ���_������_������ * gi_222 * Point) gi_340 = TRUE;
   }
   if (gi_328 < 1) {
      gi_348 = FALSE;
      gi_344 = FALSE;
      gi_340 = TRUE;
      gd_220 = AccountEquity();
   }
   if (gi_340) {
      gd_268 = FindLastBuyPrice();
      gd_276 = FindLastSellPrice();
      if (gi_348) {
         if (���������_��_�������� || ls_44 == "true"
         
     
         
         ) {
            fOrderCloseMarket(0, 1);
            gd_316 = NormalizeDouble(���������_����_���� * l_ord_lots_8, ���_����_0_1_2);
         } else gd_316 = fGetLots(OP_SELL);
         if (���������_���� && ls_36 == "true") {
            gi_312 = gi_328;
            if (gd_316 > 0.0) {
               RefreshRates();
               gi_352 = OpenPendingOrder(1, gd_316, Bid, ��������������� * gi_222, Ask, 0, 0, gs_296 + "- " + gi_312, �����, 0, HotPink);
               if (gi_352 < 0) {
                  Print(" ����������� ������: ", ErrorDescription(GetLastError())); // GetLastError()
                  return (0);
               }
               gd_276 = FindLastSellPrice();
               gi_340 = FALSE;
               gi_356 = TRUE;
            }
         }
      } else {
         if (gi_344) {
            if (���������_��_�������� || ls_44 == "true" 
        
            
            ) {
               fOrderCloseMarket(1, 0);
               gd_316 = NormalizeDouble(���������_����_���� * l_ord_lots_0, ���_����_0_1_2);
            } else gd_316 = fGetLots(OP_BUY);
            if (���������_���� && ls_36 == "true") {
               gi_312 = gi_328;
               if (gd_316 > 0.0) {
                  gi_352 = OpenPendingOrder(0, gd_316, Ask, ��������������� * gi_222, Bid, 0, 0, gs_296 + "- " + gi_312, �����, 0, Lime);
                  if (gi_352 < 0) {
                     Print(" ����������� ������: ", ErrorDescription(GetLastError())); // GetLastError()
                     return (0);
                  }
                  gd_268 = FindLastBuyPrice();
                  gi_340 = FALSE;
                  gi_356 = TRUE;
               }
            }
         }
      }
   }
   if (gi_340 && gi_328 < 1) {
      l_iclose_16 = iClose(Symbol(), 0, 2);
      l_iclose_24 = iClose(Symbol(), 0, 1);
      g_bid_252 = Bid;
      g_ask_260 = Ask;
      if (!gi_348 && !gi_344 && ls_36 == "true") {
         gi_312 = gi_328;
         if (l_iclose_16 > l_iclose_24) {
            gd_316 = fGetLots
            
      //      (OP_BUY)
            
            (OP_SELL)
            ;
            if (gd_316 > 0.0
            
             &&   MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
         MacdCurrent>(MACDOpenLevel*Point) && MaCurrent<MaPrevious
            
            
    //      && Open[1]>ma && Close[1]<ma
            
            ) {
               gi_352 = OpenPendingOrder(1, gd_316, g_bid_252, ��������������� * gi_222, g_bid_252, 0, 0, gs_296 + "- " + gi_312, �����, 0, HotPink);
               if (gi_352 < 0) {
                  Print(gd_316, " ����������� ������: ", ErrorDescription(GetLastError())); // GetLastError()
                  return (0);
               }
               gd_268 = FindLastBuyPrice();
               gi_356 = TRUE;
            }
         } else {
            gd_316 = fGetLots 
            
      //      (OP_SELL)
 
            (OP_BUY)
            ;
            if (gd_316 > 0.0
            
            
             &&   MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious &&
         MathAbs(MacdCurrent)>(MACDOpenLevel*Point) && MaCurrent>MaPrevious
            
   //      &&    Open[1]<ma && Close[1]>ma
            
            
            ) {
               gi_352 = OpenPendingOrder(0, gd_316, g_ask_260, ��������������� * gi_222, g_ask_260, 0, 0, gs_296 + "- " + gi_312, �����, 0, Lime);
               if (gi_352 < 0) {
                  Print(gd_316, " ����������� ������: ", ErrorDescription(GetLastError())); // GetLastError()
                  return (0);
               }
               gd_276 = FindLastSellPrice();
               gi_356 = TRUE;
            }
         }
      }
      if (gi_352 > 0) gi_308 = TimeCurrent() + 60.0 * (60.0 * ����_��_��������_����);
      gi_340 = FALSE;
   }
   gi_328 = CountTrades();
   g_price_244 = 0;
   double ld_60 = 0; // ld_56
   for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
      OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_244 += OrderOpenPrice() * OrderLots();
            ld_60 += OrderLots();
         }
      }
   }
   if (gi_328 > 0) g_price_244 = NormalizeDouble(g_price_244 / ld_60, Digits);
   if (gi_356) {
      for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
         OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) {
            if (OrderType() == OP_BUY) {
               g_price_212 = g_price_244 + ����_������ * gi_222 * Point;
               gd_unused_228 = g_price_212;
               gd_332 = g_price_244 - ����_���� * gi_222 * Point;
               gi_292 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) {
            if (OrderType() == OP_SELL) {
               g_price_212 = g_price_244 - ����_������ * gi_222 * Point;
               gd_unused_236 = g_price_212;
               gd_332 = g_price_244 + ����_���� * gi_222 * Point;
               gi_292 = TRUE;
            }
         }
      }
   }
   if (gi_356) {
      if (gi_292 == TRUE) {
         for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
            OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) OrderModify(OrderTicket(), g_price_244, OrderStopLoss(), g_price_212, 0, Yellow);
            gi_356 = FALSE;
         }
      }
   }
   return (0);
}
//==================================================================================================================================
double ND(double ad_0) { // ���������� ����� � ��������� ������� �� ��������� ��������

   return (NormalizeDouble(ad_0, Digits));
}
//==================================================================================================================================
int fOrderCloseMarket(bool ai_0 = TRUE, bool ai_4 = TRUE) {
   int li_ret_8 = 0;
   for (int l_pos_12 = OrdersTotal() - 1; l_pos_12 >= 0; l_pos_12--) {
      if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) {
            if (OrderType() == OP_BUY && ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
                     Print("������ �������� ������ BUY " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_360 != iTime(NULL, 0, 0)) {
                     g_datetime_360 = iTime(NULL, 0, 0);
                     Print("������� �������� ������ BUY " + OrderTicket() + ". �������� ����� �����");
                  }
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Ask), 5, CLR_NONE)) {
                     Print("������ �������� ������ SELL " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_364 != iTime(NULL, 0, 0)) {
                     g_datetime_364 = iTime(NULL, 0, 0);
                     Print("������� �������� ������ SELL " + OrderTicket() + ". �������� ����� �����");
                  }
                  return (-2);
               }
            }
         }
      }
   }
   return (li_ret_8);
}
//==================================================================================================================================
double fGetLots(int a_cmd_0) { // ��������� ����
   double  l_lots_4;
   int     l_datetime_12;
   switch (���_��������_0_1_2) {
   case 0:
      l_lots_4 = ���;
      break;
   case 1:
      l_lots_4 = NormalizeDouble(��� * MathPow(���������_����_����, gi_312), ���_����_0_1_2);
      break;
   case 2:
      l_datetime_12 = 0;
      l_lots_4 = ���;
      for (int l_pos_20 = OrdersHistoryTotal() - 1; l_pos_20 >= 0; l_pos_20--) {
         if (OrderSelect(l_pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) {
               if (l_datetime_12 < OrderCloseTime()) {
                  l_datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) l_lots_4 = NormalizeDouble(OrderLots() * ���������_����_����, ���_����_0_1_2);
                  else l_lots_4 = ���;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0, l_lots_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2); // GetLastError()   ������������ ������� ��� �������� ������
   return (l_lots_4);
}
//==================================================================================================================================
int CountTrades() { // ���� ���������� �������� ������
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}
//==================================================================================================================================
void CloseThisSymbolAll() { // �������� ���� ������ �� ���� ����
   for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����) {
            if (OrderType() ==  OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, ��������������� * gi_222, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, ��������������� * gi_222, Red);
         }
         Sleep(1000);
      }
   }
}
//=========== ��������� ���������� ������� =======================================================================================================================
int OpenPendingOrder(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_unused_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 =   0;
   int l_error_64  =   0;
   int l_count_68  =   0;
   int li_72       = 100;
   switch (ai_0) {
   case 2: // 2
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ����_���� * gi_222), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4: // 4
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ����_���� * gi_222), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0: // 0
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ����_���� * gi_222), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3: // 3
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ����_���� * gi_222), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5: // 5
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ����_���� * gi_222), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1: // 1
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ����_���� * gi_222), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
}
//==================================================================================================================================
double StopLong(double ad_0, int ai_8) { 
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}
//==================================================================================================================================
double StopShort(double ad_0, int ai_8) { 
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}
//==================================================================================================================================
double TakeLong(double ad_0, int ai_8) { 
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}
//==================================================================================================================================
double TakeShort(double ad_0, int ai_8) { 
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}
//==================================================================================================================================
double CalculateProfit() { // ������� �������
   double ld_ret_0 = 0;
   for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
      OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == �����)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}
//==================================================================================================================================
void TrailingAlls(int ai_0, int ai_4, double a_price_8) { // ����� ��������
   int li_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == �����) {
               if (OrderType() == OP_BUY) {
                  li_16 = NormalizeDouble((Bid - a_price_8) / Point, 0);
                  if (li_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Bid - ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16 = NormalizeDouble((a_price_8 - Ask) / Point, 0);
                  if (li_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Ask + ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 < l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}
//==================================================================================================================================
double AccountEquityHigh() { // ����������� ��������� ��������� ������� 
   if (CountTrades() == 0) gd_368 = AccountEquity();
   if (gd_368 < gd_376) gd_368 = gd_376;
   else gd_368 = AccountEquity();
   gd_376 = AccountEquity();
   return (gd_368);
}
//==================================================================================================================================
double FindLastBuyPrice() { // ����� ��������� ���� �������
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == ����� && OrderType() == OP_BUY) {
         l_ticket_8 = OrderTicket();
         if (l_ticket_8 > l_ticket_20) {
            l_ord_open_price_0 = OrderOpenPrice();
            ld_unused_12 = l_ord_open_price_0;
            l_ticket_20 = l_ticket_8;
         }
      }
   }
   return (l_ord_open_price_0);
}
//==================================================================================================================================
double FindLastSellPrice() { // ����� ��������� ���� �������
   double l_ord_open_price_0;
   int    l_ticket_8;
   double ld_unused_12 = 0;
   int    l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != �����) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == ����� && OrderType() == OP_SELL) {
         l_ticket_8 = OrderTicket();
         if (l_ticket_8 > l_ticket_20) {
            l_ord_open_price_0 = OrderOpenPrice();
            ld_unused_12 = l_ord_open_price_0;
            l_ticket_20 = l_ticket_8;
         }
      }
   }
   return (l_ord_open_price_0);
}
//==================================================================================================================================
void Display_Info() { // ����� ���������� � ���� ����
    gi_1000 = NormalizeDouble((Ask - Bid) / Point, 0);
    Comment("                              Robot Forex 2051 Bay Long\n", 
            "                              ������:  ", AccountServer(), 
      "\n", "                              ����� �������:  ", TimeToStr(TimeCurrent() - 7200, TIME_MINUTES|TIME_SECONDS), // 3600
      "\n", "                              ����� C������:  ", TimeToStr(TimeCurrent(), TIME_MINUTES|TIME_SECONDS),
      "\n", "                              �����:  ",  "1:" + DoubleToStr(AccountLeverage(), 0),
      "\n", "                              �����:  ", DoubleToStr(gi_1000 / 1, 1), 
      "\n", "                              ���:     ", ���,
      "\n");
}
//==================================================================================================================================
//==================================================================================================================================
//==================================================================================================================================
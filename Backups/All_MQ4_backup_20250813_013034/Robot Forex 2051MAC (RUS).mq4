//+==========================================================================+
//|                          Robot Forex 2051 Bay Long (RUS) (GBPUSD M1).mq4 |
//|                                            Copyright © 2009, Eracash.com |
//|                                                   http://www.eracash.com |
//|           Русифицировано и модернизировано компанией LogicMansLaboratory |
//|                                        http://logicmanslaboratory.0pk.ru |
//|                                                              Moscow 2011 |
//+==========================================================================+
#property copyright "Copyright © 2009, Eracash.com"
#property link      "http://www.eracash.com"
//==================================================================================================================================
#property show_inputs
//==================================================================================================================================
#include <stderror.mqh>
#include <stdlib.mqh>
//==================================================================================================================================
extern string НАЧАЛЬНЫЕ_ПАРАМЕТРЫ    =  "НАЧАЛЬНЫЕ ПАРАМЕТРЫ";   // Init Parameters
extern int    Магик                  = 12345; // g_magic_208     Magic             (идентификационный номер присваиваемый сделкам этого робота - что бы не путался со сделками других роботов)
extern int    Тип_Лота_0_1_2         =     2; // gd_112          Lotdecimal        (0=нормальные лоты 1.0;  1=минилоты 0.1;  2=микролоты 0.01)
extern double Проскальзывание        =   5.0; // g_slippage_96   Slippage          (задержка исполнения ордера для реквот)
//-----------------------------------------------------------------------------------------
extern string ПАРАМЕТРЫ_ЛОТА         =  "ПАРАМЕТРЫ ЛОТА";        // Parameters Lot
extern double Лот                    =  0.01; // Lots            Lots              (размер лота для первого ордера)
extern bool   Умножение_Лота         =  TRUE; // gi_84           UseAdd            (включить умножение лота)
extern double Умножение_Лота_коэф    =  1.08; // gd_88           LotExponent       (коэффициент, на который умножается следующий лот)
extern int    Тип_Автолота_0_1_2     =     1; // gi_76           MMType            (вариант работы автолота: 0=отключён; 1=нормал; 2=агрессив-не задействован в данной версии)
//-----------------------------------------------------------------------------------------
extern string ПАРАМЕТРЫ_ВХОДА        =  "ПАРАМЕТРЫ ВХОДА";       // Input Parameters
extern int    Максимум_Сделок        =   100; // MaxTrades       MaxTrades         (максимаьно допустимое количество открываемых сделок)
extern double Шаг_Сделок_пункты      =  10.0; // g_pips_152      PipStep           (если предыдущий ордер ушёл в минус на 10 пунктов, то советник открывает следующий ордер большего объёма)
//-----------------------------------------------------------------------------------------
extern string ПАРАМЕТРЫ_ВЫХОДА       =  "ПАРАМЕТРЫ ВЫХОДА";      // Output Parameters
extern double Стоп_Лосс              =   0.0; // g_pips_128      Stoploss          (закрытие сделок по общему убытку в пунктах)
extern double Тейк_Профит            =  10.0; // g_pips_120      TakeProfit        (закрытие сделок по общему профиту в пунктах)
extern bool   Трейлинг_Стоп          = FALSE; // gi_176  TRUE    UseTrailingStop   (включение трейлинга профитной позиции)
extern double Cтарт_Трейлинга        =  10.0; // gd_136          StartTrailingPips (старт трейлинга в пунктах)
extern double Шаг_Трейлинга          =  10.0; // gd_144          StepTrailingPips  (шаг трейлинга в пунктах)
//-----------------------------------------------------------------------------------------
extern string ФИЛЬТРЫ_ВХОДА          =  "ФИЛЬТРЫ ВХОДА";         // Input Filters
extern bool   Временной_Фильтр       = FALSE; // gi_192          TimeFilter        (для подтверждения прорыва технической ценовой области - цены должны продержаться выше или ниже нее в течение определенного времени,- пример: для открытия длинной позиции может потребоваться, чтобы рынок два дня подряд закрывался выше прорванного уровня сопротивления)
extern bool   Торговля_по_часам      = FALSE; // UseHourTrade    UseHourTrade      (включение торговли по часам)
extern int    Начало_Торговли        =     0; // StartHour       StartHour         (начало открытия сделок по часам)
extern int    Заверш_Торговли        =     8; // EndHour         EndHour           (завершение открытия сделок по часам)
//-----------------------------------------------------------------------------------------
extern string ФИЛЬТРЫ_ВЫХОДА         =  "ФИЛЬТРЫ ВЫХОДА";        // Output Filters
extern bool   Закрывать_по_Фильтрам  = FALSE; // gi_80           UseClose          (разрешить закрытие сделок по фильтрам Тайм-Аут и Эквити)
extern bool   Стоп_по_Эквити         = FALSE; // gi_164          UseEquityStop     (включение слежения за суммарным убытком по эквити)
extern double Стоп_по_Эквити_процент =  20.0; // gd_168          TotalEquityRisk   (просадка по эквити в %, для закрытия всех сделок)
extern bool   Стоп_по_ТаймАуту       = FALSE; // gi_180          UseTimeOut        (использовать таймаут: закрывать сделки если они "висят" слишком долго)
extern double Стоп_по_ТаймАуту_часы  =   0.0; // gd_184          MaxTradeOpenHours (время таймаута в часах: через сколько закрывать зависшие сделки)

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
      case 0.01 : Тип_Лота_0_1_2 = 2; break;
      case  0.1 : Тип_Лота_0_1_2 = 1; break;
      case    1 : Тип_Лота_0_1_2 = 0; break;
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
//   ObjectSetText("klc14", "Русифицировано:  LogicMansLaboratory.0pk.ru", 3, "System", DimGray);
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
   if (Торговля_по_часам) {
      if (!(Hour() >= Начало_Торговли && Hour() <= Заверш_Торговли)) {
         CloseThisSymbolAll();
         Comment("Время для торговли ещё не пришло!");
         return (0);
      }
   }
   string ls_36 = "false"; // ls_32
   string ls_44 = "false"; // ls_40
   if (Временной_Фильтр == FALSE || (Временной_Фильтр && (Заверш_Торговли > Начало_Торговли && (Hour() >= Начало_Торговли && Hour() <= Заверш_Торговли)) || (Начало_Торговли > Заверш_Торговли && !(Hour() >= Заверш_Торговли && Hour() <= Начало_Торговли)))) ls_36 = "true";
   if (Временной_Фильтр && (Заверш_Торговли > Начало_Торговли && !(Hour() >= Начало_Торговли && Hour() <= Заверш_Торговли)) || (Начало_Торговли > Заверш_Торговли && (Hour() >= Заверш_Торговли && Hour() <= Начало_Торговли))) ls_44 = "true";
   if (Трейлинг_Стоп) TrailingAlls(Cтарт_Трейлинга * gi_222, Шаг_Трейлинга * gi_222, g_price_244); // !
   if (Стоп_по_ТаймАуту) {
      if (TimeCurrent() >= gi_308) {
         CloseThisSymbolAll();
         Print("Bсе сделки будут закрыты из-за Тайм-Аута");
      }
   }
   if (g_time_304 == Time[0]) return (0);
   g_time_304 = Time[0];
   double ld_52 = CalculateProfit(); // ld_48
   if (Стоп_по_Эквити) {
      if (ld_52 < 0.0 && MathAbs(ld_52) > Стоп_по_Эквити_процент / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Bсе сделки будут закрыты из-за превышения Эквити");
         gi_356 = FALSE;
      }
   }
   gi_328 = CountTrades();
   if (gi_328 == 0) gi_292 = FALSE;
   for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
      OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) {
         if (OrderType() == OP_BUY) {
            gi_344 = TRUE;
            gi_348 = FALSE;
            l_ord_lots_0 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) {
         if (OrderType() == OP_SELL) {
            gi_344 = FALSE;
            gi_348 = TRUE;
            l_ord_lots_8 = OrderLots();
            break;
         }
      }
   }
   if (gi_328 > 0 && gi_328 <= Максимум_Сделок) {
      RefreshRates();
      gd_268 = FindLastBuyPrice();
      gd_276 = FindLastSellPrice();
      if (gi_344 && gd_268 - Ask >= Шаг_Сделок_пункты * gi_222 * Point) gi_340 = TRUE;
      if (gi_348 && Bid - gd_276 >= Шаг_Сделок_пункты * gi_222 * Point) gi_340 = TRUE;
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
         if (Закрывать_по_Фильтрам || ls_44 == "true"
         
     
         
         ) {
            fOrderCloseMarket(0, 1);
            gd_316 = NormalizeDouble(Умножение_Лота_коэф * l_ord_lots_8, Тип_Лота_0_1_2);
         } else gd_316 = fGetLots(OP_SELL);
         if (Умножение_Лота && ls_36 == "true") {
            gi_312 = gi_328;
            if (gd_316 > 0.0) {
               RefreshRates();
               gi_352 = OpenPendingOrder(1, gd_316, Bid, Проскальзывание * gi_222, Ask, 0, 0, gs_296 + "- " + gi_312, Магик, 0, HotPink);
               if (gi_352 < 0) {
                  Print(" Исправление ошибки: ", ErrorDescription(GetLastError())); // GetLastError()
                  return (0);
               }
               gd_276 = FindLastSellPrice();
               gi_340 = FALSE;
               gi_356 = TRUE;
            }
         }
      } else {
         if (gi_344) {
            if (Закрывать_по_Фильтрам || ls_44 == "true" 
        
            
            ) {
               fOrderCloseMarket(1, 0);
               gd_316 = NormalizeDouble(Умножение_Лота_коэф * l_ord_lots_0, Тип_Лота_0_1_2);
            } else gd_316 = fGetLots(OP_BUY);
            if (Умножение_Лота && ls_36 == "true") {
               gi_312 = gi_328;
               if (gd_316 > 0.0) {
                  gi_352 = OpenPendingOrder(0, gd_316, Ask, Проскальзывание * gi_222, Bid, 0, 0, gs_296 + "- " + gi_312, Магик, 0, Lime);
                  if (gi_352 < 0) {
                     Print(" Исправление ошибки: ", ErrorDescription(GetLastError())); // GetLastError()
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
               gi_352 = OpenPendingOrder(1, gd_316, g_bid_252, Проскальзывание * gi_222, g_bid_252, 0, 0, gs_296 + "- " + gi_312, Магик, 0, HotPink);
               if (gi_352 < 0) {
                  Print(gd_316, " Исправление ошибки: ", ErrorDescription(GetLastError())); // GetLastError()
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
               gi_352 = OpenPendingOrder(0, gd_316, g_ask_260, Проскальзывание * gi_222, g_ask_260, 0, 0, gs_296 + "- " + gi_312, Магик, 0, Lime);
               if (gi_352 < 0) {
                  Print(gd_316, " Исправление ошибки: ", ErrorDescription(GetLastError())); // GetLastError()
                  return (0);
               }
               gd_276 = FindLastSellPrice();
               gi_356 = TRUE;
            }
         }
      }
      if (gi_352 > 0) gi_308 = TimeCurrent() + 60.0 * (60.0 * Стоп_по_ТаймАуту_часы);
      gi_340 = FALSE;
   }
   gi_328 = CountTrades();
   g_price_244 = 0;
   double ld_60 = 0; // ld_56
   for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
      OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) {
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
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) {
            if (OrderType() == OP_BUY) {
               g_price_212 = g_price_244 + Тейк_Профит * gi_222 * Point;
               gd_unused_228 = g_price_212;
               gd_332 = g_price_244 - Стоп_Лосс * gi_222 * Point;
               gi_292 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) {
            if (OrderType() == OP_SELL) {
               g_price_212 = g_price_244 - Тейк_Профит * gi_222 * Point;
               gd_unused_236 = g_price_212;
               gd_332 = g_price_244 + Стоп_Лосс * gi_222 * Point;
               gi_292 = TRUE;
            }
         }
      }
   }
   if (gi_356) {
      if (gi_292 == TRUE) {
         for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
            OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) OrderModify(OrderTicket(), g_price_244, OrderStopLoss(), g_price_212, 0, Yellow);
            gi_356 = FALSE;
         }
      }
   }
   return (0);
}
//==================================================================================================================================
double ND(double ad_0) { // Округление числа с плавающей запятой до указанной точности

   return (NormalizeDouble(ad_0, Digits));
}
//==================================================================================================================================
int fOrderCloseMarket(bool ai_0 = TRUE, bool ai_4 = TRUE) {
   int li_ret_8 = 0;
   for (int l_pos_12 = OrdersTotal() - 1; l_pos_12 >= 0; l_pos_12--) {
      if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) {
            if (OrderType() == OP_BUY && ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
                     Print("Ошибка закрытия сделки BUY " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_360 != iTime(NULL, 0, 0)) {
                     g_datetime_360 = iTime(NULL, 0, 0);
                     Print("Попытка закрытия сделки BUY " + OrderTicket() + ". Торговый поток занят");
                  }
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Ask), 5, CLR_NONE)) {
                     Print("Ошибка закрытия сделки SELL " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_364 != iTime(NULL, 0, 0)) {
                     g_datetime_364 = iTime(NULL, 0, 0);
                     Print("Попытка закрытия сделки SELL " + OrderTicket() + ". Торговый поток занят");
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
double fGetLots(int a_cmd_0) { // Умножение лота
   double  l_lots_4;
   int     l_datetime_12;
   switch (Тип_Автолота_0_1_2) {
   case 0:
      l_lots_4 = Лот;
      break;
   case 1:
      l_lots_4 = NormalizeDouble(Лот * MathPow(Умножение_Лота_коэф, gi_312), Тип_Лота_0_1_2);
      break;
   case 2:
      l_datetime_12 = 0;
      l_lots_4 = Лот;
      for (int l_pos_20 = OrdersHistoryTotal() - 1; l_pos_20 >= 0; l_pos_20--) {
         if (OrderSelect(l_pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) {
               if (l_datetime_12 < OrderCloseTime()) {
                  l_datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) l_lots_4 = NormalizeDouble(OrderLots() * Умножение_Лота_коэф, Тип_Лота_0_1_2);
                  else l_lots_4 = Лот;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0, l_lots_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2); // GetLastError()   Недостаточно средств для открытия сделки
   return (l_lots_4);
}
//==================================================================================================================================
int CountTrades() { // Учёт количества открытых сделок
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}
//==================================================================================================================================
void CloseThisSymbolAll() { // Закрытие всех сделок по этой паре
   for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик) {
            if (OrderType() ==  OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, Проскальзывание * gi_222, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, Проскальзывание * gi_222, Red);
         }
         Sleep(1000);
      }
   }
}
//=========== Установка отложенных ордеров =======================================================================================================================
int OpenPendingOrder(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_unused_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 =   0;
   int l_error_64  =   0;
   int l_count_68  =   0;
   int li_72       = 100;
   switch (ai_0) {
   case 2: // 2
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, Стоп_Лосс * gi_222), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4: // 4
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, Стоп_Лосс * gi_222), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0: // 0
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, Стоп_Лосс * gi_222), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3: // 3
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, Стоп_Лосс * gi_222), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5: // 5
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, Стоп_Лосс * gi_222), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError(); // GetLastError()
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1: // 1
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, Стоп_Лосс * gi_222), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
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
double CalculateProfit() { // Рассчёт прибыли
   double ld_ret_0 = 0;
   for (g_pos_324 = OrdersTotal() - 1; g_pos_324 >= 0; g_pos_324--) {
      OrderSelect(g_pos_324, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}
//==================================================================================================================================
void TrailingAlls(int ai_0, int ai_4, double a_price_8) { // Общий трейлинг
   int li_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == Магик) {
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
double AccountEquityHigh() { // Определение максимума свободных средств 
   if (CountTrades() == 0) gd_368 = AccountEquity();
   if (gd_368 < gd_376) gd_368 = gd_376;
   else gd_368 = AccountEquity();
   gd_376 = AccountEquity();
   return (gd_368);
}
//==================================================================================================================================
double FindLastBuyPrice() { // Поиск последней цены покупки
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик && OrderType() == OP_BUY) {
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
double FindLastSellPrice() { // Поиск последней цены продажи
   double l_ord_open_price_0;
   int    l_ticket_8;
   double ld_unused_12 = 0;
   int    l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Магик) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Магик && OrderType() == OP_SELL) {
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
void Display_Info() { // Вывод информации в углу окна
    gi_1000 = NormalizeDouble((Ask - Bid) / Point, 0);
    Comment("                              Robot Forex 2051 Bay Long\n", 
            "                              Сервер:  ", AccountServer(), 
      "\n", "                              Время Гринвич:  ", TimeToStr(TimeCurrent() - 7200, TIME_MINUTES|TIME_SECONDS), // 3600
      "\n", "                              Время Cервера:  ", TimeToStr(TimeCurrent(), TIME_MINUTES|TIME_SECONDS),
      "\n", "                              Плечо:  ",  "1:" + DoubleToStr(AccountLeverage(), 0),
      "\n", "                              Спред:  ", DoubleToStr(gi_1000 / 1, 1), 
      "\n", "                              Лот:     ", Лот,
      "\n");
}
//==================================================================================================================================
//==================================================================================================================================
//==================================================================================================================================
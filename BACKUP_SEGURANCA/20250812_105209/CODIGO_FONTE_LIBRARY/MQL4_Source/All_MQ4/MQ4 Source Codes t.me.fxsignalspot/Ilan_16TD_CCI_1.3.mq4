//+------------------------------------------------------------------+
//|                                            Ilan_16TD_CCI_1.2.mq4 |
//|                                                      Night© 2010 |
//|                                    http://www.alfonius@yandex.ru |
//+------------------------------------------------------------------+
//  Добавлена автоматическая настройка на 5 знаков
//  Добавлен режим "NewCycle" отмены выставления новых ордеров. Открытые серии продолжают работать
//  заменён индикатор RSI на CCI, причём для расчёта смотрим периоды на 2-х старших ТФ
//  Введён режим "Turbo": первое колено=1/3 пипстепа,второе =2/3 пипстепа для повышения прибыльности во флете
//  Введён режим "Dynamic": растяжка пипстепа при сильном движении, начинается с колена, = StartDynamic
//  добавлена нормализация цен при расчёте OrderSend, чем избавились от ошибок при расчёте ордеров
//  убраны неиспользуемые ф-ции
//  добавлена проверка расчёта ТР, для исключения открытия ордеров с невыставленым ТР , спасибо за содействие neame


#property copyright "Night© 2010"
#property link      "http://www.alfonius@yandex.ru"

extern string t1 = "Режим Turbo";
extern bool   Turbo = true;          // режим Турбо 
extern string t2 = "Режим Dynamic";
extern bool   Dynamic = true;        // режим Dynamic
extern string t3 = "№ ордера для начала работы Dynamic (не < 4)";
extern int    StartDynamic = 4;      // ордер, с которого начинает работать режим Dynamic 
extern string t4 = "NewCycle режим  отмены выставления новых ордеров";
extern bool   NewCycle = true;       // Режим отмены выставления новых ордеров
extern string t5 = "Период MA";
extern int    PerMA = 20;
extern string t6 = "уровень CCI для входов";
extern double Drop1 = 100;           // уровень CCI для входов
extern double Drop2 = 105;            // уровень CCI для входов
string t7 = "Таймфреймы CCI";
int timefr1 = 1;              // ТФ CCI
int timefr2 = 5;              // ТФ CCI
extern string t8 = "Периоды CCI";
extern double Per1 = 95;             // период CCI
extern double Per2 = 70;             // период CCI
extern int applied_price = 6;        //способ расчёта цены внутри бара. Для расчёта ССИ. не больше 6!!!!!!!!!!!   
extern string t9 = "Общие настройки";
extern double LotExponent = 1.95;
extern double slip = 5.0;
extern double Lots = 0.01;
extern int lotdecimal = 2;
extern double TakeProfit_ = 10.0;
extern double PipStep__ = 30.0;
double TakeProfit,PipStep_;
double PipStep,PipS ;
extern int MaxTrades = 10;
bool UseEquityStop = FALSE;
double TotalEquityRisk = 20.0;
bool UseTrailingStop = FALSE;
double TrailStart = 10.0;
double TrailStop = 10.0;
double Stoploss = 500.0;
bool UseTimeOut = FALSE;
double MaxTradeOpenHours = 48.0;
extern int g_magic_176 = 12324;
extern string t_ = "Удачной торговли!";
double g_price_180, Balans, Sredstva ;
double gd_188;
double gd_unused_196;
double gd_unused_204;
double g_price_212;
double g_bid_220;
double g_ask_228;
double gd_236;
double gd_244;
double gd_260;
bool gi_268;
string gs_ilan_272 = "Ilan_16TD_CCI_1.2";
int g_time_280 = 0;
int gi_284,ord_16,ord_N ;
int gi_288 = 0;
double gd_292;
int g_pos_300 = 0;
int gi_304;
double gd_308 = 0.0;
bool gi_316 = FALSE;
bool gi_320 = FALSE;
bool gi_324 = FALSE;
int gi_328;
bool gi_332 = FALSE;
double gd_336;
double gd_344;

//==============================
string    txt,txt1;
string    txt2="";
string    txt3="";
color col = ForestGreen;
//==============================

int init() {
   gd_260 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
//------------------------   
   ObjectCreate("Lable1",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable1", OBJPROP_CORNER, 2);
   ObjectSet("Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSet("Lable1", OBJPROP_YDISTANCE, 11);
   txt1="Ilan_16TD_CCI_1.2"+CharToStr(174)+"Night ";
   ObjectSetText("Lable1",txt1,15,"Times New Roman",DodgerBlue);
//-------------------------

   return (0);
}

int deinit() {
//----
 ObjectDelete("Lable");
 ObjectDelete("Lable1");
 ObjectDelete("Lable2");
 ObjectDelete("Lable3"); 
//----
   return (0);
}

int start() {
   double l_iclose_8;
   double l_iclose_16;
   if (UseTrailingStop) TrailingAlls(TrailStart, TrailStop, g_price_212);
   if (UseTimeOut) {
      if (TimeCurrent() >= gi_284) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   //***// если после запятой пять знаков - коррекция
       TakeProfit = TakeProfit_;    
    
    if (Digits == 5 || Digits == 3)
      {
        TakeProfit = TakeProfit_ * 10;
        PipStep_ = PipStep__ * 10;
      }

   //***
       {
    Comment("" 
         + "\n" 
         + "Ilan_16TD_CCI_1.2" 
         + "\n" 
         + "________________________________"  
         + "\n" 
         + "Брокер:         " + AccountCompany()
         + "\n"
         + "Время брокера:  " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS)
         + "\n"        
         + "________________________________"  
         + "\n" 
         + "Счёт:             " + AccountName() 
         + "\n" 
         + "Номер счёт        " + AccountNumber()
         + "\n" 
         + "_______________________________"
         + "\n"
         + "Открыто ордеров Ilan_16TD_CCI :" + CountTrades()
         + "\n"
         + "_______________________________"
         + "\n"           
         + "Баланс:                       " + DoubleToStr(AccountBalance(), 2)          
         + "\n" 
         + "Свободные средства:   " + DoubleToStr(AccountEquity(), 2)
         + "\n"      
         + "_______________________________");
   }

   //*****************// Турбо-режим *********
   //=========
   ord_16 = CountTrades();  
   if (Turbo)
   {   
   if (ord_16 == 1) PipStep = PipStep_/3;
   if (ord_16 == 2) PipStep = PipStep_/3*2;
   if (ord_16 >= 3) PipStep = PipStep_;
   }
   else PipStep = PipStep_;
   //=========
   //*****************************************
{  //=================Dynamic-режим
  ord_N = CountTrades();
 {if (ord_N >= StartDynamic)
   if (Dynamic)  
   { double hival=High[iHighest(NULL,0,MODE_HIGH,36,1)];    // вычисление наибольшей цены за последние 36 бара
     double loval=Low[iLowest(NULL,0,MODE_LOW,36,1)];       // вычисление наименьшей цены за последние 36 бара//chart used for symbol and time period
     PipS=NormalizeDouble((hival-loval)/3/Point,0);         // расчёт PipStep
     //if (PipStep<DefaultPips/2) PipStep = DefaultPips/2;
     if (PipS>PipStep_*2) PipStep = PipStep_*2;    // if dynamic pips fail, assign pips extreme value
   } else PipStep = PipStep_;
  }
}
   //=================    
   //================= 
   //=================
{   //ForestGreen' YellowGreen' Yellow' OrangeRed' Red
  Balans = NormalizeDouble( AccountBalance(),2);
  Sredstva = NormalizeDouble(AccountEquity(),2);  
    if (Sredstva >= Balans/6*5) col = DodgerBlue; 
    if (Sredstva >= Balans/6*4 && Sredstva < Balans/6*5)col = DeepSkyBlue;
    if (Sredstva >= Balans/6*3 && Sredstva < Balans/6*4)col = Gold;
    if (Sredstva >= Balans/6*2 && Sredstva < Balans/6*3)col = OrangeRed;
    if (Sredstva >= Balans/6   && Sredstva < Balans/6*2)col = Crimson;
    if (Sredstva <  Balans/5                           )col = Red;
   //------------------------- 
ObjectDelete("Lable2");
ObjectCreate("Lable2",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable2", OBJPROP_CORNER, 3);
   ObjectSet("Lable2", OBJPROP_XDISTANCE, 33);
   ObjectSet("Lable2", OBJPROP_YDISTANCE, 31);
   txt2=(DoubleToStr(AccountBalance(), 2));
   ObjectSetText("Lable2","БАЛАНС     "+txt2+"",16,"Times New Roman",DodgerBlue);
   //-------------------------   
ObjectDelete("Lable3");
ObjectCreate("Lable3",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable3", OBJPROP_CORNER, 3);
   ObjectSet("Lable3", OBJPROP_XDISTANCE, 33);
   ObjectSet("Lable3", OBJPROP_YDISTANCE, 11);
   txt3=(DoubleToStr(AccountEquity(), 2));
   ObjectSetText("Lable3","СРЕДСТВА     "+txt3+"",16,"Times New Roman",col);
}
//-------------------------
   //==================
   //==================

   if (g_time_280 == Time[0]) return (0);
   g_time_280 = Time[0];
   double ld_0 = CalculateProfit();
   if (UseEquityStop) {
      if (ld_0 < 0.0 && MathAbs(ld_0) > TotalEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         gi_332 = FALSE;
      }
   }
   gi_304 = CountTrades();
   if (gi_304 == 0) gi_268 = FALSE;
   for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
      OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
         if (OrderType() == OP_BUY) {
            gi_320 = TRUE;
            gi_324 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
         if (OrderType() == OP_SELL) {
            gi_320 = FALSE;
            gi_324 = TRUE;
            break;
         }
      }
   }
   if (gi_304 > 0 && gi_304 <= MaxTrades) {
      RefreshRates();
      gd_236 = FindLastBuyPrice();
      gd_244 = FindLastSellPrice();
      if (gi_320 && gd_236 - Ask >= PipStep * Point) gi_316 = TRUE;
      if (gi_324 && Bid - gd_244 >= PipStep * Point) gi_316 = TRUE;
   }
   if (gi_304 < 1) {
      gi_324 = FALSE;
      gi_320 = FALSE;
      gi_316 = TRUE;
      gd_188 = AccountEquity();
   }
   if (gi_316) {
      gd_236 = FindLastBuyPrice();
      gd_244 = FindLastSellPrice();
      if (gi_324) {
         gi_288 = gi_304;
         gd_292 = NormalizeDouble(Lots * MathPow(LotExponent, gi_288), lotdecimal);
         RefreshRates();
         gi_328 = OpenPendingOrder(1, gd_292, NormalizeDouble(Bid,Digits), slip, NormalizeDouble(Ask,Digits), 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, HotPink);
         if (gi_328 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_244 = FindLastSellPrice();
         gi_316 = FALSE;
         gi_332 = TRUE;
      } else {
         if (gi_320) {
            gi_288 = gi_304;
            gd_292 = NormalizeDouble(Lots * MathPow(LotExponent, gi_288), lotdecimal);
            gi_328 = OpenPendingOrder(0, gd_292, NormalizeDouble(Ask,Digits), slip, NormalizeDouble(Bid,Digits), 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, Lime);
            if (gi_328 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236 = FindLastBuyPrice();
            gi_316 = FALSE;
            gi_332 = TRUE;
         }
      }
   }
   if (NewCycle) {
   if (gi_316 && gi_304 < 1) {
      l_iclose_8 =  iMA(NULL,0,PerMA,0,MODE_LWMA,PRICE_WEIGHTED,3);//первичное определение.. 
      l_iclose_16 = iMA(NULL,0,PerMA,0,MODE_LWMA,PRICE_WEIGHTED,1);//..направления тренда
      g_bid_220 = NormalizeDouble(Bid,Digits);
      g_ask_228 = NormalizeDouble(Ask,Digits);
      if (!gi_324 && !gi_320) {
         gi_288 = gi_304;
         gd_292 = NormalizeDouble(Lots * MathPow(LotExponent, gi_288), lotdecimal);
         if (l_iclose_8 != l_iclose_16) // не входим, если нет движения цены
          {
           if (l_iclose_8 > l_iclose_16)// если есть движение, определяем направление...  
            {
             if ((iCCI(NULL,timefr1,Per1,applied_price,0)<(-Drop1))&&(iCCI(NULL,timefr2,Per2,applied_price,0)<(-Drop2)))//...и ждём подтверждение на 2-х ТФ по уровням ССИ 
              {
               gi_328 = OpenPendingOrder(1, gd_292, g_bid_220, slip, g_bid_220, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, HotPink);
               if (gi_328 < 0) 
                {
                  Print("Error: ", GetLastError());
                  return (0);
                }
               gd_236 = FindLastBuyPrice();
               gi_332 = TRUE;
              }
            } else 
            {if ((iCCI(NULL,timefr1,Per1,applied_price,0)>(Drop1))&&(iCCI(NULL,timefr2,Per2,applied_price,0)>(Drop2))) 
             { gi_328 = OpenPendingOrder(0, gd_292, g_ask_228, slip, g_ask_228, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, Lime);
               if (gi_328 < 0) 
               {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_244 = FindLastSellPrice();
               gi_332 = TRUE;
             }
            }
           }
         if (gi_328 > 0) gi_284 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
         gi_316 = FALSE;
      }
   }
   }
   gi_304 = CountTrades();
   g_price_212 = 0;
   double ld_24 = 0;
   for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
      OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_212 += OrderOpenPrice() * OrderLots();
            ld_24 += OrderLots();
         }
      }
   }
   if (gi_304 > 0) g_price_212 = NormalizeDouble(g_price_212 / ld_24, Digits);
   if (gi_332) {
      for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
         OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
            if (OrderType() == OP_BUY) {
               g_price_180 = g_price_212 + TakeProfit * Point;
               gd_unused_196 = g_price_180;
               gd_308 = g_price_212 - Stoploss * Point;
               gi_268 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
            if (OrderType() == OP_SELL) {
               g_price_180 = g_price_212 - TakeProfit * Point;
               gd_unused_204 = g_price_180;
               gd_308 = g_price_212 + Stoploss * Point;
               gi_268 = TRUE;
            }
         }
      }
   }
   if (gi_332) {
      if (gi_268 == TRUE) {
         for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
            OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176)
             //OrderModify(OrderTicket(), g_price_212, OrderStopLoss(), g_price_180, 0, Yellow);
            //===
            while(!OrderModify(OrderTicket(), g_price_212, OrderStopLoss(), g_price_180, 0, Yellow))// модифицируем все открытые ордера...
            {Sleep(1000);RefreshRates();}                           //..причём здесь добавлена проверка, котрая должна по идее исключить.. 
            //===                                                   //..открытие ордеров без ТР
            gi_332 = FALSE;
         }
      }
   }
   return (0);
}

int CountTrades() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

void CloseThisSymbolAll() {
   for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 = 0;
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, NormalizeDouble(Ask,Digits), a_slippage_20, NormalizeDouble(StopLong(Bid, ai_32),Digits), NormalizeDouble(TakeLong(Ask,ai_36),Digits ), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, NormalizeDouble(Bid,Digits), a_slippage_20, NormalizeDouble(StopShort(Ask, ai_32),Digits), NormalizeDouble(TakeShort(Bid, ai_36),Digits ), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
}

double StopLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double StopShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double CalculateProfit() {
   double ld_ret_0 = 0;
   for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
      OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

void TrailingAlls(int ai_0, int ai_4, double a_price_8) {
   int li_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176) {
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

double AccountEquityHigh() {
   if (CountTrades() == 0) gd_336 = AccountEquity();
   if (gd_336 < gd_344) gd_336 = gd_344;
   else gd_336 = AccountEquity();
   gd_344 = AccountEquity();
   return (gd_336);
}

double FindLastBuyPrice() {
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176 && OrderType() == OP_BUY) {
         l_ticket_24 = OrderTicket();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            ld_unused_0 = l_ord_open_price_8;
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}

double FindLastSellPrice() {
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176 && OrderType() == OP_SELL) {
         l_ticket_24 = OrderTicket();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            ld_unused_0 = l_ord_open_price_8;
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}
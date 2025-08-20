//+------------------------------------------------------------------+
//|                                           Ilan-Combi_Dinamic.mq4 |
//|                                                            Night |
//|                                               alfonius@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Night"
#property link      "alfonius@yandex.ru"

//+------------------------------------------------------------------+
//=====================
//=====================
extern string _= "Общие_Настройки";
extern double MinLots = 0.01;       // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.16
extern bool MM =false;              // ММ - манименеджмент
extern int PeriodDeM = 15;          //таймфрейм DeMarker для расчёта лота
//================Dynamic
extern bool   DynamicPips = true;   // расчёт пипстепа
extern int    DefaultPips = 22;     // начальный пипстеп
extern int    Bar = 36;             //количество баров для расчёта волотильности
int PipStep_H;//=0;
//================

//=====================
//First
//=====================
extern string __= "Настройки First";
bool UseTrailingStop_H = FALSE;// использовать трейлинг стоп
extern double LotExponent_H = 1.69;  // умножение лотов в серии по експоненте для вывода в безубыток. первый лот 0.1, серия: 0.15, 0.26, 0.43 ...
//=====================
double Lots_H;                      // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.16
int lotdecimal_H = 2;               // 2 - микролоты 0.01, 1 - мини лоты 0.1, 0 - нормальные лоты 1.0
extern double TakeProfit_H = 10.0;  // тейк профит
//extern double PipStep_H = 30.0;     // шаг колена
extern double slip_H = 3.0;         // проскальзывание
extern int MaxTrades_H = 10;        // максимально количество одновременно открытых ордеров
int MagicNumber_H = 111;            // магик
//======================
bool UseEquityStop_H = FALSE;       // использовать риск в процентах
double TotalEquityRisk_H = 20.0;    // риск в процентах от депозита
bool UseTimeOut_H = FALSE;          // использовать анулирование ордеров по времени
double MaxTradeOpenHours_H = 48.0;  // через колько часов анулировать висячие ордера
double Stoploss_H = 500.0;          
double TrailStart_H = 15.0;
double TrailStop_H = 5.0;
//======================
double PriceTarget_H, StartEquity_H, BuyTarget_H, SellTarget_H ;
double AveragePrice_H, SellLimit_H, BuyLimit_H ;
double LastBuyPrice_H, LastSellPrice_H, Spread_H;
bool flag_H;
string EAName_H = "First";
int timeprev_H = 0, expiration_H;
int NumOfTrades_H = 0;
double iLots_H;
int cnt_H = 0, total_H;
double Stopper_H = 0.0;
bool TradeNow_H = FALSE, LongTrade_H = FALSE, ShortTrade_H = FALSE;
int ticket_H;
bool NewOrdersPlaced_H = FALSE;
double AccountEquityHighAmt_H, PrevEquity_H;
//=======================
//Second
//=======================
extern string ___= "Настройки Second";
bool UseTrailing_G = FALSE;
extern double MultiLotsFactor_G = 1.69;
extern double TakeProfit_G = 10.0;
int StepLots_G;
//extern double StepLots_G = 30.0;
double TrailStart_G = 15.0;
double TrailStop_G = 5.0;
extern int MaxCountOrders_G = 10;
bool SafeEquity_G = FALSE;
double SafeEquityRisk_G = 20.0;
extern double slippage_G = 3.0;
int MagicNumber_G = 13579;
//==========
double Step_H;
double Step_G;
double Step_HLot;
double Step_GLot;
//==========
bool gi_220_G = FALSE;
double gd_224_G = 48.0;
double g_pips_232_G = 500.0;
double gd_240_G = 0.0;
bool gi_248_G = TRUE;
bool gi_252_G = FALSE;
int gi_256_G = 1;
double g_price_260_G;
double gd_268_G;
double gd_unused_276_G;
double gd_unused_284_G;
double g_price_292_G;
double g_bid_300_G;
double g_ask_308_G;
double gd_316_G;
double gd_324_G;
double gd_340_G;
bool gi_348_G;
string gs_352_G = "Second";
int g_time_360_G = 0;
int gi_364_G;
int gi_368_G = 0;    // № ордера
double gd_372_G;
int g_pos_380_G = 0; //cnt_H
int gi_384_G;
double gd_388_G = 0.0;
bool gi_396_G = FALSE;
bool gi_400_G = FALSE;
bool gi_404_G = FALSE;
int gi_408_G;
bool gi_412_G = FALSE;
int g_datetime_416_G = 0;
int g_datetime_420_G = 0;
double gd_424_G;
double gd_432_G;
//=======================
string    txt,txt1;
//=======================
int init()
{
//------------------------   
   ObjectCreate("Lable1",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable1", OBJPROP_CORNER, 2);
   ObjectSet("Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSet("Lable1", OBJPROP_YDISTANCE, 21);
   txt1="Ilan-Combi 1.21";
   ObjectSetText("Lable1",txt1,16,"Times New Roman",DeepSkyBlue);
//-------------------------
ObjectCreate("Lable",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable", OBJPROP_CORNER, 2);
   ObjectSet("Lable", OBJPROP_XDISTANCE, 3);
   ObjectSet("Lable", OBJPROP_YDISTANCE, 1);
   txt="Night "+CharToStr(174)+" alfonius@yandex.ru";
   ObjectSetText("Lable",txt,16,"Times New Roman",DeepSkyBlue);
//-------------------------   
//----First
Spread_H = MarketInfo(Symbol(), MODE_SPREAD) * Point; 
//----Second
gd_340_G = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   switch (MarketInfo(Symbol(), MODE_MINLOT)) {
   case 0.001:
      gd_240_G = 3;
      break;
   case 0.01:
      gd_240_G = 2;
      break;
   case 0.1:
      gd_240_G = 1;
      break;
   case 1.0:
      gd_240_G = 0;

   return(0);
}
}
//===================
//===================
int deinit()
  {
//----
 ObjectDelete("Lable");
 ObjectDelete("Lable1"); 
//----
return(0);
}
//===================
//===================
int start() 
{
//===================
//if (Lots > 10) Lots = 10; //ограничение лотов
//===================
{
    Comment(""            //коментарии
         + "\n" 
         + "Ilan-Combi_Dinamic" 
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
         + "Валюта счёта:   " + AccountCurrency()   
         + "\n"
         + "Плечо:              1:" + DoubleToStr(AccountLeverage(), 0)
         + "\n"          
         + "_______________________________"
         + "\n"
         + "Всего ордеров                  :" + OrdersTotal()
         + "\n"
         + "_______________________________"
         + "\n"           
         + "Баланс:                       " + DoubleToStr(AccountBalance(), 2)          
         + "\n" 
         + "Свободные средства:   " + DoubleToStr(AccountEquity(), 2)
         + "\n"      
         + "_______________________________");
   }
   //=================
   //=================Dynamic_First
 {
 if (DynamicPips)  {
     double hival=High[iHighest(NULL,0,MODE_HIGH,Bar,1)];        // вычисление наибольшей цены за последние 36 бара
     double loval=Low[iLowest(NULL,0,MODE_LOW,Bar,1)];           // вычисление наименьшей цены за последние 36 бара//chart used for symbol and time period
     PipStep_H=NormalizeDouble((hival-loval)/3/Point,2);        // расчёт PipStep
     if (PipStep_H<DefaultPips/2) PipStep_H = DefaultPips/2;
     if (PipStep_H>DefaultPips*2) PipStep_H = DefaultPips*2;    // if dynamic pips fail, assign pips extreme value
   } else PipStep_H = DefaultPips;
  }
   //================= 
   //=================Dynamic_Second
 {
 if (DynamicPips)  {
     double hival_G=High[iHighest(NULL,0,MODE_HIGH,Bar,1)];      // вычисление наибольшей цены за последние 36 бара
     double loval_G=Low[iLowest(NULL,0,MODE_LOW,Bar,1)];         // вычисление наименьшей цены за последние 36 бара//chart used for symbol and time period
     StepLots_G=NormalizeDouble((hival_G-loval_G)/3/Point,2);   // расчёт PipStep
     if (StepLots_G<DefaultPips/2) StepLots_G = DefaultPips/2;
     if (StepLots_G>DefaultPips*2) StepLots_G = DefaultPips*2;  // if dynamic pips fail, assign pips extreme value
   } else StepLots_G = DefaultPips;
  }
   //=================  
 
   //=================== First 
   double PrevCl_H;
   double CurrCl_H;
   //=======================
   //=======================
    double Step_HLot = NormalizeDouble((iDeMarker(NULL, 0, PeriodDeM, 1)),2)/3;
//=======================
     if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000)  // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
    {Lots_H = MinLots *100* Step_HLot;
     }  
     else
     {Lots_H = NormalizeDouble(0.00001 * MathCeil(AccountBalance ()) * Step_HLot,2);
     }
    }
     else Lots_H = MinLots *100* Step_HLot;
//=================== Second
   double l_ord_lots_8_G;
   double l_ord_lots_16_G;
   double l_iclose_24_G;
   double l_iclose_32_G;
//=================== First
   if (UseTrailingStop_H) TrailingAlls_H(TrailStart_H, TrailStop_H, AveragePrice_H);
   if (UseTimeOut_H) {
      if (TimeCurrent() >= expiration_H) {
         CloseThisSymbolAll_H();
         Print("Closed All due to TimeOut");
      }
   }
   if (timeprev_H == Time[0]) return (0);
   timeprev_H = Time[0];
   double CurrentPairProfit_H = CalculateProfit_H();
   if (UseEquityStop_H) {
      if (CurrentPairProfit_H < 0.0 && MathAbs(CurrentPairProfit_H) > TotalEquityRisk_H / 100.0 * AccountEquityHigh_H()) {
         CloseThisSymbolAll_H();
         Print("Closed All due to Stop Out");
         NewOrdersPlaced_H = FALSE;
      }
   }
   total_H = CountTrades_H();
   if (total_H == 0) flag_H = FALSE;
   for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
      OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
         if (OrderType() == OP_BUY) {
            LongTrade_H = TRUE;
            ShortTrade_H = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
         if (OrderType() == OP_SELL) {
            LongTrade_H = FALSE;
            ShortTrade_H = TRUE;
            break;
         }
      }
   }
   if (total_H > 0 && total_H <= MaxTrades_H) {
      RefreshRates();
      LastBuyPrice_H = FindLastBuyPrice_H();
      LastSellPrice_H = FindLastSellPrice_H();
      if (LongTrade_H && LastBuyPrice_H - Ask >= PipStep_H * Point) TradeNow_H = TRUE;
      if (ShortTrade_H && Bid - LastSellPrice_H >= PipStep_H * Point) TradeNow_H = TRUE;
   }
   if (total_H < 1) {
      ShortTrade_H = FALSE;
      LongTrade_H = FALSE;
      TradeNow_H = TRUE;
      StartEquity_H = AccountEquity();
   }
   if (TradeNow_H) {
      LastBuyPrice_H = FindLastBuyPrice_H();
      LastSellPrice_H = FindLastSellPrice_H();
      if (ShortTrade_H) {
         NumOfTrades_H = total_H;
         iLots_H = NormalizeDouble(Lots_H * MathPow(LotExponent_H, NumOfTrades_H), lotdecimal_H);
         RefreshRates();
         ticket_H = OpenPendingOrder_H(1, iLots_H, Bid, slip_H, Ask, 0, 0, EAName_H + "-" + NumOfTrades_H, MagicNumber_H, 0, HotPink);
         if (ticket_H < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         LastSellPrice_H = FindLastSellPrice_H();
         TradeNow_H = FALSE;
         NewOrdersPlaced_H = TRUE;
      } else {
         if (LongTrade_H) {
            NumOfTrades_H = total_H;
            iLots_H = NormalizeDouble(Lots_H * MathPow(LotExponent_H, NumOfTrades_H), lotdecimal_H);
            ticket_H = OpenPendingOrder_H(0, iLots_H, Ask, slip_H, Bid, 0, 0, EAName_H + "-" + NumOfTrades_H, MagicNumber_H, 0, Lime);
            if (ticket_H < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            LastBuyPrice_H = FindLastBuyPrice_H();
            TradeNow_H = FALSE;
            NewOrdersPlaced_H = TRUE;
         }
      }
   }
   if (TradeNow_H && total_H < 1) {
      PrevCl_H = iHigh(Symbol(), 0, 1);
      CurrCl_H =  iLow(Symbol(), 0, 2);
      SellLimit_H = Bid;
      BuyLimit_H = Ask;
      if (!ShortTrade_H && !LongTrade_H) {
         NumOfTrades_H = total_H;
         iLots_H = NormalizeDouble(Lots_H * MathPow(LotExponent_H, NumOfTrades_H), lotdecimal_H);
         if (PrevCl_H > CurrCl_H) {

//HHHHHHHH~~~~~~~~~~~~~ Индюк RSI ~~~~~~~~~~HHHHHHHHH~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               ticket_H = OpenPendingOrder_H(1, iLots_H, SellLimit_H, slip_H, SellLimit_H, 0, 0, EAName_H + "-" + NumOfTrades_H, MagicNumber_H, 0, HotPink);
               if (ticket_H < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastBuyPrice_H = FindLastBuyPrice_H();
               NewOrdersPlaced_H = TRUE;
            }
         } else {

//HHHHHHHH~~~~~~~~~~~~~ Индюк RSI ~~~~~~~~~HHHHHHHHHH~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               ticket_H = OpenPendingOrder_H(0, iLots_H, BuyLimit_H, slip_H, BuyLimit_H, 0, 0, EAName_H + "-" + NumOfTrades_H, MagicNumber_H, 0, Lime);
               if (ticket_H < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastSellPrice_H = FindLastSellPrice_H();
               NewOrdersPlaced_H = TRUE;
            }
         }
//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
if (ticket_H > 0) expiration_H = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_H);
TradeNow_H = FALSE;
}
}
total_H = CountTrades_H();
AveragePrice_H = 0;
double Count_H = 0;
for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
AveragePrice_H += OrderOpenPrice() * OrderLots();
Count_H += OrderLots();
}
}
}
if (total_H > 0) AveragePrice_H = NormalizeDouble(AveragePrice_H / Count_H, Digits);
if (NewOrdersPlaced_H) {
for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_BUY) {
PriceTarget_H = AveragePrice_H + TakeProfit_H * Point;
BuyTarget_H = PriceTarget_H;
Stopper_H = AveragePrice_H - Stoploss_H * Point;
flag_H = TRUE;
}
}
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_SELL) {
PriceTarget_H = AveragePrice_H - TakeProfit_H * Point;
SellTarget_H = PriceTarget_H;
Stopper_H = AveragePrice_H + Stoploss_H * Point;
flag_H = TRUE;
}
}
}
}
if (NewOrdersPlaced_H) {
if (flag_H == TRUE) {
for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) OrderModify(OrderTicket(), AveragePrice_H, OrderStopLoss(), PriceTarget_H, 0, Yellow);
NewOrdersPlaced_H = FALSE;
}
}
}
   //=========Second

   if (UseTrailing_G) TrailingAlls_G(TrailStart_G, TrailStop_G, g_price_292_G);
   
   if (gi_220_G) {
      if (TimeCurrent() >= gi_364_G) {
         CloseThisSymbolAll_G();
         Print("Closed All due to TimeOut");
      }
   }
   if (g_time_360_G == Time[0]) return (0);
   g_time_360_G = Time[0];
   double ld_0_G = CalculateProfit_G();
   if (SafeEquity_G) {
      if (ld_0_G < 0.0 && MathAbs(ld_0_G) > SafeEquityRisk_G / 100.0 * AccountEquityHigh_G()) {
         CloseThisSymbolAll_G();
         Print("Closed All due to Stop Out");
         gi_412_G = FALSE;
      }
   }
   gi_384_G = CountTrades_G();
   if (gi_384_G == 0) gi_348_G = FALSE;
   for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
      OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
         if (OrderType() == OP_BUY) {
            gi_400_G = TRUE;
            gi_404_G = FALSE;
            l_ord_lots_8_G = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
         if (OrderType() == OP_SELL) {
            gi_400_G = FALSE;
            gi_404_G = TRUE;
            l_ord_lots_16_G = OrderLots();
            break;
         }
      }
   }
   if (gi_384_G > 0 && gi_384_G <= MaxCountOrders_G) {
      RefreshRates();
      gd_316_G = FindLastBuyPrice_G();
      gd_324_G = FindLastSellPrice_G();
      if (gi_400_G && gd_316_G - Ask >= StepLots_G * Point) gi_396_G = TRUE;
      if (gi_404_G && Bid - gd_324_G >= StepLots_G * Point) gi_396_G = TRUE;
   }
   if (gi_384_G < 1) {
      gi_404_G = FALSE;
      gi_400_G = FALSE;
      gi_396_G = TRUE;
      gd_268_G = AccountEquity();
   }
   if (gi_396_G) {
      gd_316_G = FindLastBuyPrice_G();
      gd_324_G = FindLastSellPrice_G();
      if (gi_404_G) {
         if (gi_252_G) {
            fOrderCloseMarket_G(0, 1);
            gd_372_G = NormalizeDouble(MultiLotsFactor_G * l_ord_lots_16_G, gd_240_G);
         } else gd_372_G = fGetLots_G(OP_SELL);
         if (gi_248_G) {
            gi_368_G = gi_384_G;
            if (gd_372_G > 0.0) {
               RefreshRates();
               gi_408_G = OpenPendingOrder_G(1, gd_372_G, Bid, slippage_G, Ask, 0, 0, gs_352_G + "-" + gi_368_G, MagicNumber_G, 0, HotPink);
               if (gi_408_G < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_324_G = FindLastSellPrice_G();
               gi_396_G = FALSE;
               gi_412_G = TRUE;
            }
         }
      } else {
         if (gi_400_G) {
            if (gi_252_G) {
               fOrderCloseMarket_G(1, 0);
               gd_372_G = NormalizeDouble(MultiLotsFactor_G * l_ord_lots_8_G, gd_240_G);
            } else gd_372_G = fGetLots_G(OP_BUY);
            if (gi_248_G) {
               gi_368_G = gi_384_G;
               if (gd_372_G > 0.0) {
                  gi_408_G = OpenPendingOrder_G(0, gd_372_G, Ask, slippage_G, Bid, 0, 0, gs_352_G + "-" + gi_368_G, MagicNumber_G, 0, Lime);
                  if (gi_408_G < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  gd_316_G = FindLastBuyPrice_G();
                  gi_396_G = FALSE;
                  gi_412_G = TRUE;
               }
            }
         }
      }
   }
   if (gi_396_G && gi_384_G < 1) {
      l_iclose_24_G = iClose(Symbol(), 0, 2);
      l_iclose_32_G = iClose(Symbol(), 0, 1);
      g_bid_300_G = Bid;
      g_ask_308_G = Ask;
      if (!gi_404_G && !gi_400_G) {
         gi_368_G = gi_384_G;
         if (l_iclose_24_G > l_iclose_32_G) {
            gd_372_G = fGetLots_G(OP_SELL);
            if (gd_372_G > 0.0) {
               gi_408_G = OpenPendingOrder_G(1, gd_372_G, g_bid_300_G, slippage_G, g_bid_300_G, 0, 0, gs_352_G + " " + MagicNumber_G + "-" + gi_368_G, MagicNumber_G, 0, HotPink);
               if (gi_408_G < 0) {
                  Print(gd_372_G, "Error: ", GetLastError());
                  return (0);
               }
               gd_316_G = FindLastBuyPrice_G();
               gi_412_G = TRUE;
            }
         } else {
            gd_372_G = fGetLots_G(OP_BUY);
            if (gd_372_G > 0.0) {
               gi_408_G = OpenPendingOrder_G(0, gd_372_G, g_ask_308_G, slippage_G, g_ask_308_G, 0, 0, gs_352_G + " " + MagicNumber_G + "-" + gi_368_G, MagicNumber_G, 0, Lime);
               if (gi_408_G < 0) {
                  Print(gd_372_G, "Error: ", GetLastError());
                  return (0);
               }
               gd_324_G = FindLastSellPrice_G();
               gi_412_G = TRUE;
            }
         }
      }
      if (gi_408_G > 0) gi_364_G = TimeCurrent() + 60.0 * (60.0 * gd_224_G);
      gi_396_G = FALSE;
   }
   gi_384_G = CountTrades_G();
   g_price_292_G = 0;
   double ld_40_G = 0;
   for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
      OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_292_G += OrderOpenPrice() * OrderLots();
            ld_40_G += OrderLots();
         }
      }
}
   if (gi_384_G > 0) g_price_292_G = NormalizeDouble(g_price_292_G / ld_40_G, Digits);
   if (gi_412_G) {
      for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
         OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
            if (OrderType() == OP_BUY) {
               g_price_260_G = g_price_292_G + TakeProfit_G * Point;
               gd_unused_276_G = g_price_260_G;
               gd_388_G = g_price_292_G - g_pips_232_G * Point;
               gi_348_G = TRUE;
}
}
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
            if (OrderType() == OP_SELL) {
               g_price_260_G = g_price_292_G - TakeProfit_G * Point;
               gd_unused_284_G = g_price_260_G;
               gd_388_G = g_price_292_G + g_pips_232_G * Point;
               gi_348_G = TRUE;
}
}
}
}
   if (gi_412_G) {
      if (gi_348_G == TRUE) {
         for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
            OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) OrderModify(OrderTicket(), g_price_292_G, OrderStopLoss(), g_price_260_G, 0, Yellow);
            gi_412_G = FALSE;
}
}
}
return (0);
}

//===================
//пользовательские ф-ции First
//===================

int CountTrades_H() {
int count_H = 0;
for (int trade_H = OrdersTotal() - 1; trade_H >= 0; trade_H--) {
OrderSelect(trade_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H)
if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_H++;
}
return (count_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

void CloseThisSymbolAll_H() {
for (int trade_H = OrdersTotal() - 1; trade_H >= 0; trade_H--) {
OrderSelect(trade_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() == Symbol()) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_H, Blue);
if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_H, Red);
}
Sleep(1000);
}
}
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

int OpenPendingOrder_H(int pType_H, double pLots_H, double pPrice_H, int pSlippage_H, double pr_H, int sl_H, int tp_H, string pComment_H, int pMagic_H, int pDatetime_H, color pColor_H) {
int ticket_H = 0;
int err_H = 0;
int c_H = 0;
int NumberOfTries_H = 100;
switch (pType_H) {
case 2:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_BUYLIMIT, pLots_H, pPrice_H, pSlippage_H, StopLong_H(pr_H, sl_H), TakeLong_H(pPrice_H, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(1000);
}
break;
case 4:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_BUYSTOP, pLots_H, pPrice_H, pSlippage_H, StopLong_H(pr_H, sl_H), TakeLong_H(pPrice_H, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H== 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 0:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
RefreshRates();
ticket_H = OrderSend(Symbol(), OP_BUY, pLots_H, Ask, pSlippage_H, StopLong_H(Bid, sl_H), TakeLong_H(Ask, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 3:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_SELLLIMIT, pLots_H, pPrice_H, pSlippage_H, StopShort_H(pr_H, sl_H), TakeShort_H(pPrice_H, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 5:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_SELLSTOP, pLots_H, pPrice_H, pSlippage_H, StopShort_H(pr_H, sl_H), TakeShort_H(pPrice_H, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 1:
for (c_H = 0; c_H < NumberOfTries_H; c_H++) {
ticket_H = OrderSend(Symbol(), OP_SELL, pLots_H, Bid, pSlippage_H, StopShort_H(Ask, sl_H), TakeShort_H(Bid, tp_H), pComment_H, pMagic_H, pDatetime_H, pColor_H);
err_H = GetLastError();
if (err_H == 0/* NO_ERROR */) break;
if (!(err_H == 4/* SERVER_BUSY */ || err_H == 137/* BROKER_BUSY */ || err_H == 146/* TRADE_CONTEXT_BUSY */ || err_H == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
}
return (ticket_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
double StopLong_H(double price_H, int stop_H) {
if (stop_H == 0) return (0);
else return (price_H - stop_H * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double StopShort_H(double price_H, int stop_H) {
if (stop_H == 0) return (0);
else return (price_H + stop_H * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double TakeLong_H(double price_H, int stop_H) {
if (stop_H == 0) return (0);
else return (price_H + stop_H * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double TakeShort_H(double price_H, int stop_H) {
if (stop_H == 0) return (0);
else return (price_H - stop_H * Point);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

double CalculateProfit_H() {
double Profit_H = 0;
for (cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H)
if (OrderType() == OP_BUY || OrderType() == OP_SELL) Profit_H += OrderProfit();
}
return (Profit_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

void TrailingAlls_H(int pType_H, int stop_H, double AvgPrice_H) {
int profit_H;
double stoptrade_H;
double stopcal_H;
if (stop_H != 0) {
for (int trade_H = OrdersTotal() - 1; trade_H >= 0; trade_H--) {
if (OrderSelect(trade_H, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_H) {
if (OrderType() == OP_BUY) {
profit_H = NormalizeDouble((Bid - AvgPrice_H) / Point, 0);
if (profit_H < pType_H) continue;
stoptrade_H = OrderStopLoss();
stopcal_H = Bid - stop_H * Point;
if (stoptrade_H == 0.0 || (stoptrade_H != 0.0 && stopcal_H > stoptrade_H)) OrderModify(OrderTicket(), AvgPrice_H, stopcal_H, OrderTakeProfit(), 0, Aqua);
}
if (OrderType() == OP_SELL) {
profit_H = NormalizeDouble((AvgPrice_H - Ask) / Point, 0);
if (profit_H < pType_H) continue;
stoptrade_H = OrderStopLoss();
stopcal_H = Ask + stop_H * Point;
if (stoptrade_H == 0.0 || (stoptrade_H != 0.0 && stopcal_H < stoptrade_H)) OrderModify(OrderTicket(), AvgPrice_H, stopcal_H, OrderTakeProfit(), 0, Red);
}
}
Sleep(1000);
}
}
}
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

double AccountEquityHigh_H() {
if (CountTrades_H() == 0) AccountEquityHighAmt_H = AccountEquity();
if (AccountEquityHighAmt_H < PrevEquity_H) AccountEquityHighAmt_H = PrevEquity_H;
else AccountEquityHighAmt_H = AccountEquity();
PrevEquity_H = AccountEquity();
return (AccountEquityHighAmt_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

double FindLastBuyPrice_H() {
double oldorderopenprice_H;
int oldticketnumber_H;
double unused_H = 0;
int ticketnumber_H = 0;
for (int cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H && OrderType() == OP_BUY) {
oldticketnumber_H = OrderTicket();
if (oldticketnumber_H > ticketnumber_H) {
oldorderopenprice_H = OrderOpenPrice();
unused_H = oldorderopenprice_H;
ticketnumber_H = oldticketnumber_H;
}
}
}
return (oldorderopenprice_H);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

double FindLastSellPrice_H() {
double oldorderopenprice_H;
int oldticketnumber_H;
double unused_H = 0;
int ticketnumber_H = 0;
for (int cnt_H = OrdersTotal() - 1; cnt_H >= 0; cnt_H--) {
OrderSelect(cnt_H, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_H) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_H && OrderType() == OP_SELL) {
oldticketnumber_H = OrderTicket();
if (oldticketnumber_H > ticketnumber_H) {
oldorderopenprice_H = OrderOpenPrice();
unused_H = oldorderopenprice_H;
ticketnumber_H = oldticketnumber_H;
}
}
}
return (oldorderopenprice_H);
}

//=====================================================
//==========Second
//=====================================================
double ND_G(double ad_0_G) {
return (NormalizeDouble(ad_0_G, Digits));
}

int fOrderCloseMarket_G(bool ai_0_G = TRUE, bool ai_4_G = TRUE) {
   int li_ret_8_G = 0;
   for (int l_pos_12_G = OrdersTotal() - 1; l_pos_12_G >= 0; l_pos_12_G--) {
      if (OrderSelect(l_pos_12_G, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
            if (OrderType() == OP_BUY && ai_0_G) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND_G(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     li_ret_8_G = -1;
                  }
               } else {
                  if (g_datetime_416_G != iTime(NULL, 0, 0)) {
                     g_datetime_416_G = iTime(NULL, 0, 0);
                     Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && ai_4_G) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND_G(Ask), 5, CLR_NONE)) {
                     Print("Error close SELL " + OrderTicket());
                     li_ret_8_G = -1;
                  }
               } else {
                  if (g_datetime_420_G != iTime(NULL, 0, 0)) {
                     g_datetime_420_G = iTime(NULL, 0, 0);
                     Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
         }
      }
   }
   return (li_ret_8_G);
}
   //=======================
   
   //=======================
   double fGetLots_G(int a_cmd_0_G) {
   double l_lots_4_G;
   double l_lots_MM_G;
   int l_datetime_16_G;
    //=======================
   double Step_GLot = NormalizeDouble((iDeMarker(NULL, 0, PeriodDeM, 1)),2)/3;
    //=======================
    // ММ - манименеджмент
    //=======================
   if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000)         // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
    {l_lots_MM_G = MinLots *100* Step_GLot;
     }  
     else
     {l_lots_MM_G = NormalizeDouble(0.00001 * MathCeil(AccountBalance ()) * Step_GLot,2);
     }
    }
     else l_lots_MM_G = MinLots *100* Step_GLot;
   //=======================
   
   switch (gi_256_G) {
   case 0:
      l_lots_4_G = l_lots_MM_G;
      break;
   case 1:
      l_lots_4_G = NormalizeDouble(l_lots_MM_G * MathPow(MultiLotsFactor_G, gi_368_G), gd_240_G);
      break;
   case 2:
      l_datetime_16_G = 0;
      l_lots_4_G = l_lots_MM_G;
      for (int l_pos_20_G = OrdersHistoryTotal() - 1; l_pos_20_G >= 0; l_pos_20_G--) {
         if (OrderSelect(l_pos_20_G, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
               if (l_datetime_16_G < OrderCloseTime()) {
                  l_datetime_16_G = OrderCloseTime();
                  if (OrderProfit() < 0.0) l_lots_4_G = NormalizeDouble(OrderLots() * MultiLotsFactor_G, gd_240_G);
                  else l_lots_4_G = l_lots_MM_G;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0_G, l_lots_4_G) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (l_lots_4_G);
}

int CountTrades_G() {
   int l_count_0_G = 0;
   for (int l_pos_4_G = OrdersTotal() - 1; l_pos_4_G >= 0; l_pos_4_G--) {
      OrderSelect(l_pos_4_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0_G++;
   }
   return (l_count_0_G);
}

void CloseThisSymbolAll_G() {
   for (int l_pos_0_G = OrdersTotal() - 1; l_pos_0_G >= 0; l_pos_0_G--) {
      OrderSelect(l_pos_0_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slippage_G, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slippage_G, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder_G(int ai_0_G, double a_lots_4_G, double a_price_12_G, int a_slippage_20_G, double ad_24_G, int ai_32_G, int ai_36_G, string a_comment_40_G, int a_magic_48_G, int a_datetime_52_G, color a_color_56_G) {
   int l_ticket_60_G = 0;
   int l_error_64_G = 0;
   int l_count_68_G = 0;
   int li_72_G = 100;
   switch (ai_0_G) {
   case 2:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4_G, a_price_12_G, a_slippage_20_G, StopLong_G(ad_24_G, ai_32_G), TakeLong_G(a_price_12_G, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4_G, a_price_12_G, a_slippage_20_G, StopLong_G(ad_24_G, ai_32_G), TakeLong_G(a_price_12_G, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         RefreshRates();
         l_ticket_60_G = OrderSend(Symbol(), OP_BUY, a_lots_4_G, Ask, a_slippage_20_G, StopLong_G(Bid, ai_32_G), TakeLong_G(Ask, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4_G, a_price_12_G, a_slippage_20_G, StopShort_G(ad_24_G, ai_32_G), TakeShort_G(a_price_12_G, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4_G, a_price_12_G, a_slippage_20_G, StopShort_G(ad_24_G, ai_32_G), TakeShort_G(a_price_12_G, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68_G = 0; l_count_68_G < li_72_G; l_count_68_G++) {
         l_ticket_60_G = OrderSend(Symbol(), OP_SELL, a_lots_4_G, Bid, a_slippage_20_G, StopShort_G(Ask, ai_32_G), TakeShort_G(Bid, ai_36_G), a_comment_40_G, a_magic_48_G, a_datetime_52_G, a_color_56_G);
         l_error_64_G = GetLastError();
         if (l_error_64_G == 0/* NO_ERROR */) break;
         if (!(l_error_64_G == 4/* SERVER_BUSY */ || l_error_64_G == 137/* BROKER_BUSY */ || l_error_64_G == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_G == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60_G);
}

double StopLong_G(double ad_0_G, int ai_8_G) {
   if (ai_8_G == 0) return (0);
   return (ad_0_G - ai_8_G * Point);
}

double StopShort_G(double ad_0_G, int ai_8_G) {
   if (ai_8_G == 0) return (0);
   return (ad_0_G + ai_8_G * Point);
}

double TakeLong_G(double ad_0_G, int ai_8_G) {
   if (ai_8_G == 0) return (0);
   return (ad_0_G + ai_8_G * Point);
}

double TakeShort_G(double ad_0_G, int ai_8_G) {
   if (ai_8_G == 0) return (0);
   return (ad_0_G - ai_8_G * Point);
}

double CalculateProfit_G() {
   double ld_ret_0_G = 0;
   for (g_pos_380_G = OrdersTotal() - 1; g_pos_380_G >= 0; g_pos_380_G--) {
      OrderSelect(g_pos_380_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0_G += OrderProfit();
   }
   return (ld_ret_0_G);
}

void TrailingAlls_G(int ai_0_G, int ai_4_G, double a_price_8_G) {
   int li_16_G;
   double l_ord_stoploss_20_G;
   double l_price_28_G;
   if (ai_4_G != 0) {
      for (int l_pos_36_G = OrdersTotal() - 1; l_pos_36_G >= 0; l_pos_36_G--) {
         if (OrderSelect(l_pos_36_G, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_G) {
               if (OrderType() == OP_BUY) {
                  li_16_G = NormalizeDouble((Bid - a_price_8_G) / Point, 0);
                  if (li_16_G < ai_0_G) continue;
                  l_ord_stoploss_20_G = OrderStopLoss();
                  l_price_28_G = Bid - ai_4_G * Point;
                  if (l_ord_stoploss_20_G == 0.0 || (l_ord_stoploss_20_G != 0.0 && l_price_28_G > l_ord_stoploss_20_G)) OrderModify(OrderTicket(), a_price_8_G, l_price_28_G, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16_G = NormalizeDouble((a_price_8_G - Ask) / Point, 0);
                  if (li_16_G < ai_0_G) continue;
                  l_ord_stoploss_20_G = OrderStopLoss();
                  l_price_28_G = Ask + ai_4_G * Point;
                  if (l_ord_stoploss_20_G == 0.0 || (l_ord_stoploss_20_G != 0.0 && l_price_28_G < l_ord_stoploss_20_G)) OrderModify(OrderTicket(), a_price_8_G, l_price_28_G, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh_G() {
   if (CountTrades_G() == 0) gd_424_G = AccountEquity();
   if (gd_424_G < gd_432_G) gd_424_G = gd_432_G;
   else gd_424_G = AccountEquity();
   gd_432_G = AccountEquity();
   return (gd_424_G);
}

double FindLastBuyPrice_G() {
   double l_ord_open_price_8_G;
   int l_ticket_24_G;
   double ld_unused_0_G = 0;
   int l_ticket_20_G = 0;
   for (int l_pos_16_G = OrdersTotal() - 1; l_pos_16_G >= 0; l_pos_16_G--) {
      OrderSelect(l_pos_16_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G && OrderType() == OP_BUY) {
         l_ticket_24_G = OrderTicket();
         if (l_ticket_24_G > l_ticket_20_G) {
            l_ord_open_price_8_G = OrderOpenPrice();
            ld_unused_0_G = l_ord_open_price_8_G;
            l_ticket_20_G = l_ticket_24_G;
         }
      }
   }
   return (l_ord_open_price_8_G);
}

double FindLastSellPrice_G() {
   double l_ord_open_price_8_G;
   int l_ticket_24_G;
   double ld_unused_0_G = 0;
   int l_ticket_20_G = 0;
   for (int l_pos_16_G = OrdersTotal() - 1; l_pos_16_G >= 0; l_pos_16_G--) {
      OrderSelect(l_pos_16_G, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_G) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_G && OrderType() == OP_SELL) {
         l_ticket_24_G = OrderTicket();
         if (l_ticket_24_G > l_ticket_20_G) {
            l_ord_open_price_8_G = OrderOpenPrice();
            ld_unused_0_G = l_ord_open_price_8_G;
            l_ticket_20_G = l_ticket_24_G;
         }
      }
   }
   return (l_ord_open_price_8_G);
}
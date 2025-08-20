//+------------------------------------------------------------------+
//|                                              Ilan-Trio V1.33.mq4 |
//|                                                            Night |
//|                                          http://alfonius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Night"
#property link      "http://alfonius@mail.ru"

//===================================================================
//-------------------Hilo_RSI--------------------------------------//
//===================================================================
extern string t1 = "Общие настройки";
extern double Lots = 0.01;              // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.16
extern double LotExponent = 1.59;       // умножение лотов в серии по експоненте для вывода в безубыток. первый лот 0.1, серия: 0.15, 0.26, 0.43 ...
int    lotdecimal = 2;                  // 2 - микролоты 0.01, 1 - мини лоты 0.1, 0 - нормальные лоты 1.0
extern double MaxLots = 5;              // ограничение макс лота
extern bool   MM =true;                 // ММ - манименеджмент
extern double TakeProfit = 10.0;        // тейк профит
extern bool UseEquityStop = FALSE;      // использовать риск в процентах
extern double TotalEquityRisk = 20.0;   // риск в процентах от депозита
//===================================================================
extern string t2 = "Настройки эксперта Ilan_Hilo";
double Lots_Hilo;                       // задание всех лотов через 1 переменную
double LotExponent_Hilo;       
int lotdecimal_Hilo;            
double TakeProfit_Hilo;                 // тейк профит
extern int MaxTrades_Hilo = 10;         // максимально количество одновременно открытых ордеров
bool UseEquityStop_Hilo;                // использовать риск в процентах
double TotalEquityRisk_Hilo;            // риск в процентах от депозита
//===================================================================
extern double PipStep_Hilo = 30.0;      // шаг колена- был 30
double slip_Hilo = 3.0;                 // проскальзывание
extern int MagicNumber_Hilo = 11111;           // магик
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool UseTimeOut_Hilo = FALSE;           // использовать анулирование ордеров по времени
double MaxTradeOpenHours_Hilo = 48.0;   // через колько часов анулировать висячие ордера
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool UseTrailingStop_Hilo = FALSE;      // использовать трейлинг стоп
double Stoploss_Hilo = 500.0;           // Эти параметра не работают
double TrailStart_Hilo = 10.0;
double TrailStop_Hilo = 10.0;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double PriceTarget_Hilo, StartEquity_Hilo, BuyTarget_Hilo, SellTarget_Hilo ;
double AveragePrice_Hilo, SellLimit_Hilo, BuyLimit_Hilo ;
double LastBuyPrice_Hilo, LastSellPrice_Hilo, Spread_Hilo;
bool flag_Hilo;
string EAName_Hilo = "Ilan_HiLo_RSI";
int timeprev_Hilo = 0, expiration_Hilo;
int NumOfTrades_Hilo = 0;
double iLots_Hilo;
int cnt_Hilo = 0, total_Hilo;
double Stopper_Hilo = 0.0;
bool TradeNow_Hilo = FALSE, LongTrade_Hilo = FALSE, ShortTrade_Hilo = FALSE;
int ticket_Hilo;
bool NewOrdersPlaced_Hilo = FALSE;
double AccountEquityHighAmt_Hilo, PrevEquity_Hilo;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//            ILAN 1.5                       //
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
extern string t3 = "Настройки эксперта Ilan 1.5";
double LotExponent_15;
double Lots_15;
int lotdecimal_15;
double TakeProfit_15;
bool UseEquityStop_15;                   // использовать риск в процентах
double TotalEquityRisk_15;               // риск в процентах от депозита
extern int MaxTrades_15 = 10;
int OpenNewTF_15 = 60;
int gi_unused_88_15;
//===============================================
bool UseTrailingStop_15 = FALSE;         // использовать трейлинг стоп
double Stoploss_15 = 500.0;              // Эти параметры не работают
double TrailStart_15 = 10.0;
double TrailStop_15 = 10.0;
//==============================================
bool UseTimeOut_15 = FALSE;              // использовать анулирование ордеров по времени
double MaxTradeOpenHours_15 = 48.0;      // через колько часов анулировать висячие ордера
//===============================================
double slip_15 = 3.0;
extern double PipStep_15 = 30.0; //30
extern int g_magic_176_15 = 12324;
//===============================================
double g_price_180_15;
double gd_188_15;
double gd_unused_196_15;
double gd_unused_204_15;
double g_price_212_15;
double g_bid_220_15;
double g_ask_228_15;
double gd_236_15;
double gd_244_15;
double gd_260_15;
bool gi_268_15;
string gs_ilan_272_15 = "Ilan 1.5";
int gi_280_15 = 0;
int gi_284_15;
int gi_288_15 = 0;
double gd_292_15;
int g_pos_300_15 = 0;
int gi_304_15;
double gd_308_15 = 0.0;
bool gi_316_15 = FALSE;
bool gi_320_15 = FALSE;
bool gi_324_15 = FALSE;
int gi_328_15;
bool gi_332_15 = FALSE;
double gd_336_15;
double gd_344_15;
datetime time_15=1;
//========================================================================
//                 ILAN 1.6                                             //
//========================================================================
extern string t4 = "Настройки эксперта Ilan 1.6";
double LotExponent_16;
double Lots_16;
int lotdecimal_16;
double TakeProfit_16;
extern int MaxTrades_16 = 10;
bool UseEquityStop_16;      // использовать риск в процентах
double TotalEquityRisk_16;  // риск в процентах от депозита
int OpenNewTF_16 = 1;
//=========================================================
bool UseTrailingStop_16 = FALSE;
double Stoploss_16 = 500.0;               // Эти три параметра не работают
double TrailStart_16 = 10.0;
double TrailStop_16 = 10.0;
//=========================================================
bool UseTimeOut_16 = FALSE;
double MaxTradeOpenHours_16 = 48.0;
//=========================================================
double slip_16 = 3.0;
extern double PipStep_16 = 30.0;//30
extern int g_magic_176_16 = 16794;
//=========================================================
double g_price_180_16;
double gd_188_16;
double gd_unused_196_16;
double gd_unused_204_16;
double g_price_212_16;
double g_bid_220_16;
double g_ask_228_16;
double gd_236_16;
double gd_244_16;
double gd_260_16;
bool gi_268_16;
string gs_ilan_272_16 = "Ilan 1.6";
int gi_280_16 = 0;
int gi_284_16;
int gi_288_16 = 0;
double gd_292_16;
int g_pos_300_16 = 0;
int gi_304_16;
double gd_308_16 = 0.0;
bool gi_316_16 = FALSE;
bool gi_320_16 = FALSE;
bool gi_324_16 = FALSE;
int gi_328_16;
bool gi_332_16 = FALSE;
double gd_336_16;
double gd_344_16;
datetime time_16=1;


//=======================================================================
string    txt,txt1;

//=======================================================================
int init() {
   Spread_Hilo = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   gd_260_15 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   gd_260_16 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
//------------------------   
   ObjectCreate("Lable1",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable1", OBJPROP_CORNER, 2);
   ObjectSet("Lable1", OBJPROP_XDISTANCE, 23);
   ObjectSet("Lable1", OBJPROP_YDISTANCE, 21);
   txt1="Ilan-Trio 1.3";
   ObjectSetText("Lable1",txt1,16,"Times New Roman",Aqua);
//-------------------------
ObjectCreate("Lable",OBJ_LABEL,0,0,1.0);
   ObjectSet("Lable", OBJPROP_CORNER, 2);
   ObjectSet("Lable", OBJPROP_XDISTANCE, 3);
   ObjectSet("Lable", OBJPROP_YDISTANCE, 1);
   txt="Night "+CharToStr(174)+" alfonius@yandex.ru";
   ObjectSetText("Lable",txt,16,"Times New Roman",DeepSkyBlue);
//-------------------------   
return (0); 
}
int deinit() {
   return (0);
}
//========================================================================
//========================================================================
int start()
 {

  if (Lots > MaxLots) Lots = MaxLots; //ограничение лотов
    {
    Comment("" 
         + "\n" 
         + "Ilan-Trio V 1.33" 
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
         + "_______________________________"
         + "\n"
         //+ "Открыто ордеров Ilan_Hilo:" + OrdersTotal()???
         //+ "\n"
         //+ "Открыто ордеров Ilan_1.5 :" + OrdersTotal()???
         //+ "\n"
         //+ "Открыто ордеров Ilan_1.6 :" + OrdersTotal()???
         //+ "\n"
         + "Всего ордеров                  :" + OrdersTotal()
         + "\n"
         + "_______________________________"
         + "\n"           
         + "Баланс:                    " + DoubleToStr(AccountBalance(), 2)          
         + "\n" 
         + "Свободные средства:   " + DoubleToStr(AccountEquity(), 2)
         + "\n"      
         + "_______________________________");
   }
//=======================================================================//
//                 Программный код Ilan_Hilo_RSI                         //
//=======================================================================//
  {double PrevCl_Hilo; //глоб переменная Hilo
   double CurrCl_Hilo; //глоб переменная Hilo
   double l_iclose_8;  //глоб переменная Ilan_1.5
   double l_iclose_16; //глоб переменная Ilan_1.6
   //=======================
   double LotExponent_Hilo = LotExponent;
   int lotdecimal_Hilo = lotdecimal;
   double TakeProfit_Hilo = TakeProfit;
   bool UseEquityStop_Hilo = UseEquityStop;        
   double TotalEquityRisk_Hilo = TotalEquityRisk;   // риск в процентах от депозита

   //=======================
   if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000)         // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
    { double Lots_Hilo = Lots;
     }  
     else
     {Lots_Hilo = Lots * 0.001* MathCeil(AccountBalance ());
     }
    }
     else Lots_Hilo = Lots;
   //=======================
  
   if (UseTrailingStop_Hilo) TrailingAlls_Hilo(TrailStart_Hilo, TrailStop_Hilo, AveragePrice_Hilo);
   if (UseTimeOut_Hilo) {
      if (TimeCurrent() >= expiration_Hilo) {
         CloseThisSymbolAll_Hilo();
         Print("Closed All due_Hilo to TimeOut");
      }
   }
   if (timeprev_Hilo == Time[0]) return (0);
   timeprev_Hilo = Time[0];
   double CurrentPairProfit_Hilo = CalculateProfit_Hilo();
   if (UseEquityStop_Hilo) {
      if (CurrentPairProfit_Hilo < 0.0 && MathAbs(CurrentPairProfit_Hilo) > TotalEquityRisk_Hilo / 100.0 * AccountEquityHigh_Hilo()) {
         CloseThisSymbolAll_Hilo();
         Print("Closed All due_Hilo to Stop Out");
         NewOrdersPlaced_Hilo = FALSE;
      }
   }
   total_Hilo = CountTrades_Hilo();
   if (total_Hilo == 0) flag_Hilo = FALSE;
   for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
      OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
         if (OrderType() == OP_BUY) {
            LongTrade_Hilo = TRUE;
            ShortTrade_Hilo = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
         if (OrderType() == OP_SELL) {
            LongTrade_Hilo = FALSE;
            ShortTrade_Hilo = TRUE;
            break;
         }
      }
   }
   if (total_Hilo > 0 && total_Hilo <= MaxTrades_Hilo) {
      RefreshRates();
      LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
      LastSellPrice_Hilo = FindLastSellPrice_Hilo();
      if (LongTrade_Hilo && LastBuyPrice_Hilo - Ask >= PipStep_Hilo * Point) TradeNow_Hilo = TRUE;
      if (ShortTrade_Hilo && Bid - LastSellPrice_Hilo >= PipStep_Hilo * Point) TradeNow_Hilo = TRUE;
   }
   if (total_Hilo < 1) {
      ShortTrade_Hilo = FALSE;
      LongTrade_Hilo = FALSE;
      TradeNow_Hilo = TRUE;
      StartEquity_Hilo = AccountEquity();
   }
   if (TradeNow_Hilo) {
      LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
      LastSellPrice_Hilo = FindLastSellPrice_Hilo();
      if (ShortTrade_Hilo) {
         NumOfTrades_Hilo = total_Hilo;
         iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
         RefreshRates();
         ticket_Hilo = OpenPendingOrder_Hilo(1, iLots_Hilo, Bid, slip_Hilo, Ask, 0, 0, EAName_Hilo + "-" + NumOfTrades_Hilo, MagicNumber_Hilo, 0, HotPink);
         if (ticket_Hilo < 0) 
         {
            Print("Error: ", GetLastError());
            return (0);
         }
         LastSellPrice_Hilo = FindLastSellPrice_Hilo();
         TradeNow_Hilo = FALSE;
         NewOrdersPlaced_Hilo = TRUE;
      } else {
         if (LongTrade_Hilo) {
            NumOfTrades_Hilo = total_Hilo;
            iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
            ticket_Hilo = OpenPendingOrder_Hilo(0, iLots_Hilo, Ask, slip_Hilo, Bid, 0, 0, EAName_Hilo + "-" + NumOfTrades_Hilo, MagicNumber_Hilo, 0, Lime);
            if (ticket_Hilo < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
            TradeNow_Hilo = FALSE;
            NewOrdersPlaced_Hilo = TRUE;
         }
      }
   }
   if (TradeNow_Hilo && total_Hilo < 1) {
      PrevCl_Hilo = iHigh(Symbol(), 0, 1);
      CurrCl_Hilo =  iLow(Symbol(), 0, 2);
      SellLimit_Hilo = Bid;
      BuyLimit_Hilo = Ask;
      if (!ShortTrade_Hilo && !LongTrade_Hilo) {
         NumOfTrades_Hilo = total_Hilo;
         iLots_Hilo = NormalizeDouble(Lots_Hilo * MathPow(LotExponent_Hilo, NumOfTrades_Hilo), lotdecimal_Hilo);
         if (PrevCl_Hilo > CurrCl_Hilo) {

//HHHHHHHH~~~~~~~~~~~~~ Индюк RSI ~~~~~~~~~~HHHHHHHHH~~~~~~~~~~~~~~~//       
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               ticket_Hilo = OpenPendingOrder_Hilo(1, iLots_Hilo, SellLimit_Hilo, slip_Hilo, SellLimit_Hilo, 0, 0, EAName_Hilo + "-" + NumOfTrades_Hilo, MagicNumber_Hilo, 0, HotPink);
               if (ticket_Hilo < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastBuyPrice_Hilo = FindLastBuyPrice_Hilo();
               NewOrdersPlaced_Hilo = TRUE;
            }
         } else {

//HHHHHHHH~~~~~~~~~~~~~ Индюк RSI ~~~~~~~~~HHHHHHHHHH~~~~~~~~~~~~~~~~~
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               ticket_Hilo = OpenPendingOrder_Hilo(0, iLots_Hilo, BuyLimit_Hilo, slip_Hilo, BuyLimit_Hilo, 0, 0, EAName_Hilo + "-" + NumOfTrades_Hilo, MagicNumber_Hilo, 0, Lime);
               if (ticket_Hilo < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastSellPrice_Hilo = FindLastSellPrice_Hilo();
               NewOrdersPlaced_Hilo = TRUE;
            }
         }
//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
if (ticket_Hilo > 0) expiration_Hilo = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_Hilo);
TradeNow_Hilo = FALSE;
}
}
total_Hilo = CountTrades_Hilo();
AveragePrice_Hilo = 0;
double Count_Hilo = 0;
for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
AveragePrice_Hilo += OrderOpenPrice() * OrderLots();
Count_Hilo += OrderLots();
}
}
}
if (total_Hilo > 0) AveragePrice_Hilo = NormalizeDouble(AveragePrice_Hilo / Count_Hilo, Digits);
if (NewOrdersPlaced_Hilo) {
for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_BUY) {
PriceTarget_Hilo = AveragePrice_Hilo + TakeProfit_Hilo * Point;
BuyTarget_Hilo = PriceTarget_Hilo;
Stopper_Hilo = AveragePrice_Hilo - Stoploss_Hilo * Point;
flag_Hilo = TRUE;
}
}
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_SELL) {
PriceTarget_Hilo = AveragePrice_Hilo - TakeProfit_Hilo * Point;
SellTarget_Hilo = PriceTarget_Hilo;
Stopper_Hilo = AveragePrice_Hilo + Stoploss_Hilo * Point;
flag_Hilo = TRUE;
}
}
}
}
if (NewOrdersPlaced_Hilo) {
if (flag_Hilo == TRUE) {
for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) OrderModify(OrderTicket(), AveragePrice_Hilo, OrderStopLoss(), PriceTarget_Hilo, 0, Yellow);
NewOrdersPlaced_Hilo = FALSE;
}
}
}

//========================================================================//
//                       ПРОГРАМНЫЙ КОД Ilan 1.5                          //
//========================================================================//
   //double l_iclose_8;
   //double l_iclose_16;
   //=======================
   double LotExponent_15 = LotExponent;
   int lotdecimal_15 = lotdecimal;
   double TakeProfit_15 = TakeProfit;
   bool UseEquityStop_15 = UseEquityStop;        
   double TotalEquityRisk_15 = TotalEquityRisk;            // риск в процентах от депозита
   //=======================
   if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000) // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
     { double Lots_15 = Lots;
     }  
     else
     {Lots_15 = Lots * 0.001 * MathCeil(AccountBalance ());
     }
    }
     else Lots_15 = Lots;
   //=======================
   if (UseTrailingStop_15) TrailingAlls_15(TrailStart_15, TrailStop_15, g_price_212_15);
   if (UseTimeOut_15) {
      if (TimeCurrent() >= gi_284_15) {
         CloseThisSymbolAll_15();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_280_15 != Time[0])
   {
   gi_280_15 = Time[0];
   double ld_0_15 = CalculateProfit_15();
   if (UseEquityStop_15) {
      if (ld_0_15 < 0.0 && MathAbs(ld_0_15) > TotalEquityRisk_15 / 100.0 * AccountEquityHigh_15()) {
         CloseThisSymbolAll_15();
         Print("Closed All due to Stop Out");
         gi_332_15 = FALSE;
      }
   }
   gi_304_15 = CountTrades_15();
   if (gi_304_15 == 0) gi_268_15 = FALSE;
   for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
      OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
         if (OrderType() == OP_BUY) {
            gi_320_15 = TRUE;
            gi_324_15 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
         if (OrderType() == OP_SELL) {
            gi_320_15 = FALSE;
            gi_324_15 = TRUE;
            break;
         }
      }
   }
   if (gi_304_15 > 0 && gi_304_15 <= MaxTrades_15) {
      RefreshRates();
      gd_236_15 = FindLastBuyPrice_15();
      gd_244_15 = FindLastSellPrice_15();
      if (gi_320_15 && gd_236_15 - Ask >= PipStep_15 * Point) gi_316_15 = TRUE;
      if (gi_324_15 && Bid - gd_244_15 >= PipStep_15 * Point) gi_316_15 = TRUE;
   }
   if (gi_304_15 < 1) {
      gi_324_15 = FALSE;
      gi_320_15 = FALSE;
      gi_316_15 = TRUE;
      gd_188_15 = AccountEquity();
   }
   if (gi_316_15) {
      gd_236_15 = FindLastBuyPrice_15();
      gd_244_15 = FindLastSellPrice_15();
      if (gi_324_15) {
         gi_288_15 = gi_304_15;
         gd_292_15 = NormalizeDouble(Lots_15 * MathPow(LotExponent_15, gi_288_15), lotdecimal_15);
         RefreshRates();
         gi_328_15 = OpenPendingOrder_15(1, gd_292_15, Bid, slip_15, Ask, 0, 0, gs_ilan_272_15 + "-" + gi_288_15, g_magic_176_15, 0, HotPink);
         if (gi_328_15 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_244_15 = FindLastSellPrice_15();
         gi_316_15 = FALSE;
         gi_332_15 = TRUE;
      } else {
         if (gi_320_15) {
            gi_288_15 = gi_304_15;
            gd_292_15 = NormalizeDouble(Lots_15 * MathPow(LotExponent_15, gi_288_15), lotdecimal_15);
            gi_328_15 = OpenPendingOrder_15(0, gd_292_15, Ask, slip_15, Bid, 0, 0, gs_ilan_272_15 + "-" + gi_288_15, g_magic_176_15, 0, Lime);
            if (gi_328_15 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236_15 = FindLastBuyPrice_15();
            gi_316_15 = FALSE;
            gi_332_15 = TRUE;
         }
      }
   }
   }
   if(time_15!=iTime(NULL,OpenNewTF_15,0))
   {
   int totals_15=OrdersTotal();
   int orders_15=0;
   for(int total_15=totals_15; total_15>=1; total_15--)
   {
   OrderSelect(total_15-1,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
   if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
     orders_15++;
   }
   }
          
   if (totals_15==0 || orders_15 < 1) {
      l_iclose_8 = iClose(Symbol(), 0, 2);
      l_iclose_16 = iClose(Symbol(), 0, 1);
      g_bid_220_15 = Bid;
      g_ask_228_15 = Ask;
//      if (!gi_324 && !gi_320) {
         gi_288_15 = gi_304_15;
         gd_292_15 = /*NormalizeDouble(*/Lots_15/* * MathPow(LotExponent, gi_288), lotdecimal)*/;
         if (l_iclose_8 > l_iclose_16) {
            gi_328_15 = OpenPendingOrder_15(1, gd_292_15, g_bid_220_15, slip_15, g_bid_220_15, 0, 0, gs_ilan_272_15 + "-" + gi_288_15, g_magic_176_15, 0, HotPink);
            if (gi_328_15 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236_15 = FindLastBuyPrice_15();
            gi_332_15 = TRUE;
         } else {
            gi_328_15 = OpenPendingOrder_15(0, gd_292_15, g_ask_228_15, slip_15, g_ask_228_15, 0, 0, gs_ilan_272_15 + "-" + gi_288_15, g_magic_176_15, 0, Lime);
            if (gi_328_15 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_244_15 = FindLastSellPrice_15();
            gi_332_15 = TRUE;
         }
         if (gi_328_15 > 0) gi_284_15 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_15);
         gi_316_15 = FALSE;
//      }
   }
   time_15=iTime(NULL,OpenNewTF_15,0);
   }
   gi_304_15 = CountTrades_15();
   g_price_212_15 = 0;
   double ld_24_15 = 0;
   for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
      OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_212_15 += OrderOpenPrice() * OrderLots();
            ld_24_15 += OrderLots();
         }
      }
   }
   if (gi_304_15 > 0) g_price_212_15 = NormalizeDouble(g_price_212_15 / ld_24_15, Digits);
   if (gi_332_15) {
      for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
         OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_BUY) {
               g_price_180_15 = g_price_212_15 + TakeProfit_15 * Point;
               gd_unused_196_15 = g_price_180_15;
               gd_308_15 = g_price_212_15 - Stoploss_15 * Point;
               gi_268_15 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_SELL) {
               g_price_180_15 = g_price_212_15 - TakeProfit_15 * Point;
               gd_unused_204_15 = g_price_180_15;
               gd_308_15 = g_price_212_15 + Stoploss_15 * Point;
               gi_268_15 = TRUE;
            }
         }
      }
   }
   if (gi_332_15) {
      if (gi_268_15 == TRUE) {
         for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
            OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) OrderModify(OrderTicket(), g_price_212_15, OrderStopLoss(), g_price_180_15, 0, Yellow);
            gi_332_15 = FALSE;
         }
      }
   }
//========================================================================//
//                       ПРОГРАМНЫЙ КОД Ilan 1.6                          //
//========================================================================//
//   double l_iclose_8;
//   double l_iclose_16;
   //=======================
   double LotExponent_16 = LotExponent;
   int lotdecimal_16 = lotdecimal;
   double TakeProfit_16 = TakeProfit;
   bool UseEquityStop_16 = UseEquityStop;
   double TotalEquityRisk_16 = TotalEquityRisk;            // риск в процентах от депозита
   //=======================
   // манименеджмент      //
   //=======================
   if(MM==true)
   {if (MathCeil(AccountBalance ()) < 2000) // MM = если депо меньше 2000, то лот = Lots (0.01), иначе- % от депо
     { double Lots_16 = Lots;
     }  
     else
     {Lots_16 = Lots * 0.001 * MathCeil(AccountBalance ());
     }
    }
     else Lots_Hilo = Lots;

   //=======================
   if (UseTrailingStop_16) TrailingAlls_16(TrailStart_16, TrailStop_16, g_price_212_16);
   if (UseTimeOut_16) {
      if (TimeCurrent() >= gi_284_16) {
         CloseThisSymbolAll_16();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_280_16 != Time[0])
   {
   gi_280_16 = Time[0];
   double ld_0_16 = CalculateProfit_16();
   if (UseEquityStop_16) {
      if (ld_0_16 < 0.0 && MathAbs(ld_0_16) > TotalEquityRisk_16 / 100.0 * AccountEquityHigh_16()) {
         CloseThisSymbolAll_16();
         Print("Closed All due to Stop Out");
         gi_332_16 = FALSE;
      }
   }
   gi_304_16 = CountTrades_16();
   if (gi_304_16 == 0) gi_268_16 = FALSE;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_BUY) {
            gi_320_16 = TRUE;
            gi_324_16 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_SELL) {
            gi_320_16 = FALSE;
            gi_324_16 = TRUE;
            break;
         }
      }
   }
   if (gi_304_16 > 0 && gi_304_16 <= MaxTrades_16) {
      RefreshRates();
      gd_236_16 = FindLastBuyPrice_16();
      gd_244_16 = FindLastSellPrice_16();
      if (gi_320_16 && gd_236_16 - Ask >= PipStep_16 * Point) gi_316_16 = TRUE;
      if (gi_324_16 && Bid - gd_244_16 >= PipStep_16 * Point) gi_316_16 = TRUE;
   }
   if (gi_304_16 < 1) {
      gi_324_16 = FALSE;
      gi_320_16 = FALSE;
//      gi_316_16 = TRUE;
      gd_188_16 = AccountEquity();
   }
   if (gi_316_16) {
      gd_236_16 = FindLastBuyPrice_16();
      gd_244_16 = FindLastSellPrice_16();
      if (gi_324_16) {
         gi_288_16 = gi_304_16;
         gd_292_16 = NormalizeDouble(Lots_16 * MathPow(LotExponent_16, gi_288_16), lotdecimal_16);
         RefreshRates();
         gi_328_16 = OpenPendingOrder_16(1, gd_292_16, Bid, slip_16, Ask, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, HotPink);
         if (gi_328_16 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_244_16 = FindLastSellPrice_16();
         gi_316_16 = FALSE;
         gi_332_16 = TRUE;
      } else {
         if (gi_320_16) {
            gi_288_16 = gi_304_16;
            gd_292_16 = NormalizeDouble(Lots_16 * MathPow(LotExponent_16, gi_288_16), lotdecimal_16);
            gi_328_16 = OpenPendingOrder_16(0, gd_292_16, Ask, slip_16, Bid, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, Lime);
            if (gi_328_16 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236_16 = FindLastBuyPrice_16();
            gi_316_16 = FALSE;
            gi_332_16 = TRUE;
         }
      }
   }
   }
   if(time_16!=iTime(NULL,OpenNewTF_16,0))
   {
   int totals_16=OrdersTotal();
   int orders_16=0;
   for(int total_16=totals_16; total_16>=1; total_16--)
   {
   OrderSelect(total_16-1,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
   if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
     orders_16++;
   }
   }
   if (totals_16==0 || orders_16 < 1) {
      l_iclose_8/*_16*/ = iClose(Symbol(), 0, 2);
      l_iclose_16/*_16*/ = iClose(Symbol(), 0, 1);
      g_bid_220_16 = Bid;
      g_ask_228_16 = Ask;
//      if (!gi_324_16 && !gi_320_16) {
         gi_288_16 = gi_304_16;
         gd_292_16 =/* NormalizeDouble(*/Lots_16/* * MathPow(LotExponent_16, gi_288_16), lotdecimal_16)*/;
         if (l_iclose_8/*_16*/ > l_iclose_16/*_16*/) {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               gi_328_16 = OpenPendingOrder_16(1, gd_292_16, g_bid_220_16, slip_16, g_bid_220_16, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, HotPink);
               if (gi_328_16 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_236_16 = FindLastBuyPrice_16();
               gi_332_16 = TRUE;
            }
         } else {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               gi_328_16 = OpenPendingOrder_16(0, gd_292_16, g_ask_228_16, slip_16, g_ask_228_16, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, Lime);
               if (gi_328_16 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_244_16 = FindLastSellPrice_16();
               gi_332_16 = TRUE;
            }
         }
         if (gi_328_16 > 0) gi_284_16 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_16);
         gi_316_16 = FALSE;
//      }
   }
   time_16=iTime(NULL,OpenNewTF_16,0);
   }
   gi_304_16 = CountTrades_16();
   g_price_212_16 = 0;
   double ld_24_16 = 0;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_212_16 += OrderOpenPrice() * OrderLots();
            ld_24_16 += OrderLots();
         }
      }
   }
   if (gi_304_16 > 0) g_price_212_16 = NormalizeDouble(g_price_212_16 / ld_24_16, Digits);
   if (gi_332_16) {
      for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
         OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) {
               g_price_180_16 = g_price_212_16 + TakeProfit_16 * Point;
               gd_unused_196_16 = g_price_180_16;
               gd_308_16 = g_price_212_16 - Stoploss_16 * Point;
               gi_268_16 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_SELL) {
               g_price_180_16 = g_price_212_16 - TakeProfit_16 * Point;
               gd_unused_204_16 = g_price_180_16;
               gd_308_16 = g_price_212_16 + Stoploss_16 * Point;
               gi_268_16 = TRUE;
            }
         }
      }
   }
   if (gi_332_16) {
      if (gi_268_16 == TRUE) {
         for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
            OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) OrderModify(OrderTicket(), g_price_212_16, OrderStopLoss(), g_price_180_16, 0, Yellow);
            gi_332_16 = FALSE;
         }
      }
   }
}

return (0);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

int CountTrades_Hilo() {
int count_Hilo = 0;
for (int trade_Hilo = OrdersTotal() - 1; trade_Hilo >= 0; trade_Hilo--) {
OrderSelect(trade_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_Hilo++;
}
return (count_Hilo);
}

//ппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

void CloseThisSymbolAll_Hilo() {
for (int trade_Hilo = OrdersTotal() - 1; trade_Hilo >= 0; trade_Hilo--) {
OrderSelect(trade_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() == Symbol()) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_Hilo, Blue);
if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_Hilo, Red);
}
Sleep(1000);
}
}
}

//пппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
int OpenPendingOrder_Hilo(int pType_Hilo, double pLots_Hilo, double pPrice_Hilo, int pSlippage_Hilo, double pr_Hilo, int sl_Hilo, int tp_Hilo, string pComment_Hilo, int pMagic_Hilo, int pDatetime_Hilo, color pColor_Hilo) {
int ticket_Hilo = 0;
int err_Hilo = 0;
int c_Hilo = 0;
int NumberOfTries_Hilo = 100;
switch (pType_Hilo) {
case 2:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_BUYLIMIT, pLots_Hilo, pPrice_Hilo, pSlippage_Hilo, StopLong_Hilo(pr_Hilo, sl_Hilo), TakeLong_Hilo(pPrice_Hilo, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(1000);
}
break;
case 4:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_BUYSTOP, pLots_Hilo, pPrice_Hilo, pSlippage_Hilo, StopLong_Hilo(pr_Hilo, sl_Hilo), TakeLong_Hilo(pPrice_Hilo, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 0:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
RefreshRates();
ticket_Hilo = OrderSend(Symbol(), OP_BUY, pLots_Hilo, Ask, pSlippage_Hilo, StopLong_Hilo(Bid, sl_Hilo), TakeLong_Hilo(Ask, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 3:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_SELLLIMIT, pLots_Hilo, pPrice_Hilo, pSlippage_Hilo, StopShort_Hilo(pr_Hilo, sl_Hilo), TakeShort_Hilo(pPrice_Hilo, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 5:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_SELLSTOP, pLots_Hilo, pPrice_Hilo, pSlippage_Hilo, StopShort_Hilo(pr_Hilo, sl_Hilo), TakeShort_Hilo(pPrice_Hilo, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 1:
for (c_Hilo = 0; c_Hilo < NumberOfTries_Hilo; c_Hilo++) {
ticket_Hilo = OrderSend(Symbol(), OP_SELL, pLots_Hilo, Bid, pSlippage_Hilo, StopShort_Hilo(Ask, sl_Hilo), TakeShort_Hilo(Bid, tp_Hilo), pComment_Hilo, pMagic_Hilo, pDatetime_Hilo, pColor_Hilo);
err_Hilo = GetLastError();
if (err_Hilo == 0/* NO_ERROR */) break;
if (!(err_Hilo == 4/* SERVER_BUSY */ || err_Hilo == 137/* BROKER_BUSY */ || err_Hilo == 146/* TRADE_CONTEXT_BUSY */ || err_Hilo == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
}
return (ticket_Hilo);
}

//пппппппппппппппппппппппппппппппппппппппппппп
double StopLong_Hilo(double price_Hilo, int stop_Hilo) {
if (stop_Hilo == 0) return (0);
else return (price_Hilo - stop_Hilo * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double StopShort_Hilo(double price_Hilo, int stop_Hilo) {
if (stop_Hilo == 0) return (0);
else return (price_Hilo + stop_Hilo * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double TakeLong_Hilo(double price_Hilo, int stop_Hilo) {
if (stop_Hilo == 0) return (0);
else return (price_Hilo + stop_Hilo * Point);
}
//пппппппппппппппппппппппппппппппппппппппппппп
double TakeShort_Hilo(double price_Hilo, int stop_Hilo) {
if (stop_Hilo == 0) return (0);
else return (price_Hilo - stop_Hilo * Point);
}

//пппппппппппппппппппппппппппппппппппппппппппп
double CalculateProfit_Hilo() {
double Profit_Hilo = 0;
for (cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo)
if (OrderType() == OP_BUY || OrderType() == OP_SELL) Profit_Hilo += OrderProfit();
}
return (Profit_Hilo);
}

//ппппппппппппппппппппппппппппппппппппппппппппп

void TrailingAlls_Hilo(int pType_Hilo, int stop_Hilo, double AvgPrice_Hilo) {
int profit_Hilo;
double stoptrade_Hilo;
double stopcal_Hilo;
if (stop_Hilo != 0) {
for (int trade_Hilo = OrdersTotal() - 1; trade_Hilo >= 0; trade_Hilo--) {
if (OrderSelect(trade_Hilo, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_Hilo) {
if (OrderType() == OP_BUY) {
profit_Hilo = NormalizeDouble((Bid - AvgPrice_Hilo) / Point, 0);
if (profit_Hilo < pType_Hilo) continue;
stoptrade_Hilo = OrderStopLoss();
stopcal_Hilo = Bid - stop_Hilo * Point;
if (stoptrade_Hilo == 0.0 || (stoptrade_Hilo != 0.0 && stopcal_Hilo > stoptrade_Hilo)) OrderModify(OrderTicket(), AvgPrice_Hilo, stopcal_Hilo, OrderTakeProfit(), 0, Aqua);
}
if (OrderType() == OP_SELL) {
profit_Hilo = NormalizeDouble((AvgPrice_Hilo - Ask) / Point, 0);
if (profit_Hilo < pType_Hilo) continue;
stoptrade_Hilo = OrderStopLoss();
stopcal_Hilo = Ask + stop_Hilo * Point;
if (stoptrade_Hilo == 0.0 || (stoptrade_Hilo != 0.0 && stopcal_Hilo < stoptrade_Hilo)) OrderModify(OrderTicket(), AvgPrice_Hilo, stopcal_Hilo, OrderTakeProfit(), 0, Red);
}
}
Sleep(1000);
}
}
}
}

//ппппппппппппппппппппппппппппппппппппппппппппппппп
double AccountEquityHigh_Hilo() {
if (CountTrades_Hilo() == 0) AccountEquityHighAmt_Hilo = AccountEquity();
if (AccountEquityHighAmt_Hilo < PrevEquity_Hilo) AccountEquityHighAmt_Hilo = PrevEquity_Hilo;
else AccountEquityHighAmt_Hilo = AccountEquity();
PrevEquity_Hilo = AccountEquity();
return (AccountEquityHighAmt_Hilo);
}

//пппппппппппппппппппппппппппппппппппппппппппппппппп

double FindLastBuyPrice_Hilo() {
double oldorderopenprice_Hilo;
int oldticketnumber_Hilo;
double unused_Hilo = 0;
int ticketnumber_Hilo = 0;
for (int cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo && OrderType() == OP_BUY) {
oldticketnumber_Hilo = OrderTicket();
if (oldticketnumber_Hilo > ticketnumber_Hilo) {
oldorderopenprice_Hilo = OrderOpenPrice();
unused_Hilo = oldorderopenprice_Hilo;
ticketnumber_Hilo = oldticketnumber_Hilo;
}
}
}
return (oldorderopenprice_Hilo);
}

//ппппппппппппппппппппппппппппппппппппппппппппппппппп

double FindLastSellPrice_Hilo() {
double oldorderopenprice_Hilo;
int oldticketnumber_Hilo;
double unused_Hilo = 0;
int ticketnumber_Hilo = 0;
for (int cnt_Hilo = OrdersTotal() - 1; cnt_Hilo >= 0; cnt_Hilo--) {
OrderSelect(cnt_Hilo, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_Hilo) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_Hilo && OrderType() == OP_SELL) {
oldticketnumber_Hilo = OrderTicket();
if (oldticketnumber_Hilo > ticketnumber_Hilo) {
oldorderopenprice_Hilo = OrderOpenPrice();
unused_Hilo = oldorderopenprice_Hilo;
ticketnumber_Hilo = oldticketnumber_Hilo;
}
}
}
return (oldorderopenprice_Hilo);
}

//==========================================================================
//                   пользовательские ф-ции 1.5_1.6                       //
//==========================================================================

//========================================================================//
//=========================CountTrades_15=================================//
//========================================================================//
int CountTrades_15() {
   int l_count_0_15 = 0;
   for (int l_pos_4_15 = OrdersTotal() - 1; l_pos_4_15 >= 0; l_pos_4_15--) {
      OrderSelect(l_pos_4_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0_15++;
   }
   return (l_count_0_15);
}

void CloseThisSymbolAll_15() {
   for (int l_pos_0_15 = OrdersTotal() - 1; l_pos_0_15 >= 0; l_pos_0_15--) {
      OrderSelect(l_pos_0_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_15, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_15, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder_15(int ai_0_15, double a_lots_4_15, double a_price_12_15, int a_slippage_20_15, double ad_24_15, int ai_32_15, int ai_36_15, string a_comment_40_15, int a_magic_48_15, int a_datetime_52_15, color a_color_56_15) {
   int l_ticket_60_15 = 0;
   int l_error_64_15 = 0;
   int l_count_68_15 = 0;
   int li_72_15 = 100;
   switch (ai_0_15) {
   case 2:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4_15, a_price_12_15, a_slippage_20_15, StopLong_15(ad_24_15, ai_32_15), TakeLong_15(a_price_12_15, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4_15, a_price_12_15, a_slippage_20_15, StopLong_15(ad_24_15, ai_32_15), TakeLong_15(a_price_12_15, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         RefreshRates();
         l_ticket_60_15 = OrderSend(Symbol(), OP_BUY, a_lots_4_15, Ask, a_slippage_20_15, StopLong_15(Bid, ai_32_15), TakeLong_15(Ask, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4_15, a_price_12_15, a_slippage_20_15, StopShort_15(ad_24_15, ai_32_15), TakeShort_15(a_price_12_15, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4_15, a_price_12_15, a_slippage_20_15, StopShort_15(ad_24_15, ai_32_15), TakeShort_15(a_price_12_15, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68_15 = 0; l_count_68_15 < li_72_15; l_count_68_15++) {
         l_ticket_60_15 = OrderSend(Symbol(), OP_SELL, a_lots_4_15, Bid, a_slippage_20_15, StopShort_15(Ask, ai_32_15), TakeShort_15(Bid, ai_36_15), a_comment_40_15, a_magic_48_15, a_datetime_52_15, a_color_56_15);
         l_error_64_15 = GetLastError();
         if (l_error_64_15 == 0/* NO_ERROR */) break;
         if (!(l_error_64_15 == 4/* SERVER_BUSY */ || l_error_64_15 == 137/* BROKER_BUSY */ || l_error_64_15 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_15 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60_15);
}

double StopLong_15(double ad_0_15, int ai_8_15) {
   if (ai_8_15 == 0) return (0);
   else return (ad_0_15 - ai_8_15 * Point);
}

double StopShort_15(double ad_0_15, int ai_8_15) {
   if (ai_8_15 == 0) return (0);
   else return (ad_0_15 + ai_8_15 * Point);
}

double TakeLong_15(double ad_0_15, int ai_8_15) {
   if (ai_8_15 == 0) return (0);
   else return (ad_0_15 + ai_8_15 * Point);
}

double TakeShort_15(double ad_0_15, int ai_8_15) {
   if (ai_8_15 == 0) return (0);
   else return (ad_0_15 - ai_8_15 * Point);
}

double CalculateProfit_15() {
   double ld_ret_0_15 = 0;
   for (g_pos_300_15 = OrdersTotal() - 1; g_pos_300_15 >= 0; g_pos_300_15--) {
      OrderSelect(g_pos_300_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0_15 += OrderProfit();
   }
   return (ld_ret_0_15);
}

void TrailingAlls_15(int ai_0_15, int ai_4_15, double a_price_8_15) {
   int l_ticket_16_15;
   double l_ord_stoploss_20_15;
   double l_price_28_15;
   if (ai_4_15 != 0) {
      for (int l_pos_36_15 = OrdersTotal() - 1; l_pos_36_15 >= 0; l_pos_36_15--) {
         if (OrderSelect(l_pos_36_15, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176_15) {
               if (OrderType() == OP_BUY) {
                  l_ticket_16_15 = NormalizeDouble((Bid - a_price_8_15) / Point, 0);
                  if (l_ticket_16_15 < ai_0_15) continue;
                  l_ord_stoploss_20_15 = OrderStopLoss();
                  l_price_28_15 = Bid - ai_4_15 * Point;
                  if (l_ord_stoploss_20_15 == 0.0 || (l_ord_stoploss_20_15 != 0.0 && l_price_28_15 > l_ord_stoploss_20_15)) OrderModify(OrderTicket(), a_price_8_15, l_price_28_15, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  l_ticket_16_15 = NormalizeDouble((a_price_8_15 - Ask) / Point, 0);
                  if (l_ticket_16_15 < ai_0_15) continue;
                  l_ord_stoploss_20_15 = OrderStopLoss();
                  l_price_28_15 = Ask + ai_4_15 * Point;
                  if (l_ord_stoploss_20_15 == 0.0 || (l_ord_stoploss_20_15 != 0.0 && l_price_28_15 < l_ord_stoploss_20_15)) OrderModify(OrderTicket(), a_price_8_15, l_price_28_15, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh_15() {
   if (CountTrades_15() == 0) gd_336_15 = AccountEquity();
   if (gd_336_15 < gd_344_15) gd_336_15 = gd_344_15;
   else gd_336_15 = AccountEquity();
   gd_344_15 = AccountEquity();
   return (gd_336_15);
}

double FindLastBuyPrice_15() {
   double l_ord_open_price_8_15;
   int l_ticket_24_15;
   double ld_unused_0_15 = 0;
   int l_ticket_20_15 = 0;
   for (int l_pos_16_15 = OrdersTotal() - 1; l_pos_16_15 >= 0; l_pos_16_15--) {
      OrderSelect(l_pos_16_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15 && OrderType() == OP_BUY) {
         l_ticket_24_15 = OrderTicket();
         if (l_ticket_24_15 > l_ticket_20_15) {
            l_ord_open_price_8_15 = OrderOpenPrice();
            ld_unused_0_15 = l_ord_open_price_8_15;
            l_ticket_20_15 = l_ticket_24_15;
         }
      }
   }
   return (l_ord_open_price_8_15);
}

double FindLastSellPrice_15() {
   double l_ord_open_price_8_15;
   int l_ticket_24_15;
   double ld_unused_0_15 = 0;
   int l_ticket_20_15 = 0;
   for (int l_pos_16_15 = OrdersTotal() - 1; l_pos_16_15 >= 0; l_pos_16_15--) {
      OrderSelect(l_pos_16_15, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_15) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_15 && OrderType() == OP_SELL) {
         l_ticket_24_15 = OrderTicket();
         if (l_ticket_24_15 > l_ticket_20_15) {
            l_ord_open_price_8_15 = OrderOpenPrice();
            ld_unused_0_15 = l_ord_open_price_8_15;
            l_ticket_20_15 = l_ticket_24_15;
         }
      }
   }
   return (l_ord_open_price_8_15);
}
//============================================================//
//======================CountTrades_16========================//
//============================================================//
int CountTrades_16() {
   int l_count_0_16 = 0;
   for (int l_pos_4_16 = OrdersTotal() - 1; l_pos_4_16 >= 0; l_pos_4_16--) {
      OrderSelect(l_pos_4_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0_16++;
   }
   return (l_count_0_16);
}

void CloseThisSymbolAll_16() {
   for (int l_pos_0_16 = OrdersTotal() - 1; l_pos_0_16 >= 0; l_pos_0_16--) {
      OrderSelect(l_pos_0_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_16, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_16, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder_16(int ai_0_16, double a_lots_4_16, double a_price_12_16, int a_slippage_20_16, double ad_24_16, int ai_32_16, int ai_36_16, string a_comment_40_16, int a_magic_48_16, int a_datetime_52_16, color a_color_56_16) {
   int l_ticket_60_16 = 0;
   int l_error_64_16 = 0;
   int l_count_68_16 = 0;
   int li_72_16 = 100;
   switch (ai_0_16) {
   case 2:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopLong_16(ad_24_16, ai_32_16), TakeLong_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopLong_16(ad_24_16, ai_32_16), TakeLong_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         RefreshRates();
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUY, a_lots_4_16, Ask, a_slippage_20_16, StopLong_16(Bid, ai_32_16), TakeLong_16(Ask, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopShort_16(ad_24_16, ai_32_16), TakeShort_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopShort_16(ad_24_16, ai_32_16), TakeShort_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELL, a_lots_4_16, Bid, a_slippage_20_16, StopShort_16(Ask, ai_32_16), TakeShort_16(Bid, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60_16);
}

double StopLong_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 - ai_8_16 * Point);
}

double StopShort_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 + ai_8_16 * Point);
}

double TakeLong_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 + ai_8_16 * Point);
}

double TakeShort_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 - ai_8_16 * Point);
}

double CalculateProfit_16() {
   double ld_ret_0_16 = 0;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0_16 += OrderProfit();
   }
   return (ld_ret_0_16);
}

void TrailingAlls_16(int ai_0_16, int ai_4_16, double a_price_8_16) {
   int l_ticket_16_16;
   double l_ord_stoploss_20_16;
   double l_price_28_16;
   if (ai_4_16 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176_16) {
               if (OrderType() == OP_BUY) {
                  l_ticket_16_16 = NormalizeDouble((Bid - a_price_8_16) / Point, 0);
                  if (l_ticket_16_16 < ai_0_16) continue;
                  l_ord_stoploss_20_16 = OrderStopLoss();
                  l_price_28_16 = Bid - ai_4_16 * Point;
                  if (l_ord_stoploss_20_16 == 0.0 || (l_ord_stoploss_20_16 != 0.0 && l_price_28_16 > l_ord_stoploss_20_16)) OrderModify(OrderTicket(), a_price_8_16, l_price_28_16, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  l_ticket_16_16 = NormalizeDouble((a_price_8_16 - Ask) / Point, 0);
                  if (l_ticket_16_16 < ai_0_16) continue;
                  l_ord_stoploss_20_16 = OrderStopLoss();
                  l_price_28_16 = Ask + ai_4_16 * Point;
                  if (l_ord_stoploss_20_16 == 0.0 || (l_ord_stoploss_20_16 != 0.0 && l_price_28_16 < l_ord_stoploss_20_16)) OrderModify(OrderTicket(), a_price_8_16, l_price_28_16, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh_16() {
   if (CountTrades_16() == 0) gd_336_16 = AccountEquity();
   if (gd_336_16 < gd_344_16) gd_336_16 = gd_344_16;
   else gd_336_16 = AccountEquity();
   gd_344_16 = AccountEquity();
   return (gd_336_16);
}

double FindLastBuyPrice_16() {
   double l_ord_open_price_8_16;
   int l_ticket_24_16;
   double ld_unused_0_16 = 0;
   int l_ticket_20_16 = 0;
   for (int l_pos_16_16 = OrdersTotal() - 1; l_pos_16_16 >= 0; l_pos_16_16--) {
      OrderSelect(l_pos_16_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16 && OrderType() == OP_BUY) {
         l_ticket_24_16 = OrderTicket();
         if (l_ticket_24_16 > l_ticket_20_16) {
            l_ord_open_price_8_16 = OrderOpenPrice();
            ld_unused_0_16 = l_ord_open_price_8_16;
            l_ticket_20_16 = l_ticket_24_16;
         }
      }
   }
   return (l_ord_open_price_8_16);
}

double FindLastSellPrice_16() {
   double l_ord_open_price_8_16;
   int l_ticket_24_16;
   double ld_unused_0_16 = 0;
   int l_ticket_20_16 = 0;
   for (int l_pos_16_16 = OrdersTotal() - 1; l_pos_16_16 >= 0; l_pos_16_16--) {
      OrderSelect(l_pos_16_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16 && OrderType() == OP_SELL) {
         l_ticket_24_16 = OrderTicket();
         if (l_ticket_24_16 > l_ticket_20_16) {
            l_ord_open_price_8_16 = OrderOpenPrice();
            ld_unused_0_16 = l_ord_open_price_8_16;
            l_ticket_20_16 = l_ticket_24_16;
         }
      }
   }
   return (l_ord_open_price_8_16);
}

#property copyright "fx.09@mail.ru"
#property link      ""
int    PauseMin=10;              // пауза между серией ордеров
extern double LotExponent = 1.59;       // увеличение лота ордеров колен
extern double slip = 3.0;               // проскальзывание

extern double risk = 0.3;               // если ноль не работает, если больше 0 итд то идет увеличение в зависимости от депа
extern double Percent_Risk = 100;       // процент при увеличении депозита, увеличивается лот риска 



double Lot = 0.01;               // лот
extern int lotdecimal = 2;              // 0-лоты 1 итд, 1-лоты 0.1-0.9, 2-лоты 0.01-0.09
extern double TakeProfit = 10.0;        
double Stoploss = 500.0;
double TrailStart = 10.0;
double TrailStop = 10.0;
extern double PipStep = 12.0;            // шаг колен
extern int MaxTrades = 10;              // количество колен
extern int PerHMA = 14;
bool UseEquityStop = FALSE;      // использовать ограничение риска от депозита
double TotalEquityRisk = 20.0;   // сколько процентов от депозита для риска
bool UseTrailingStop = FALSE;    // использование трейлинг стопа
bool UseTimeOut = FALSE;         // ограничение для ордеров в рынке
double MaxTradeOpenHours = 48.0; // время в часах после чего ордера которые были в рынке по времени анулируются
extern int g_magic_176 = 123;           // магическое число при изменении можно вешать на разные пары

extern string a = "работа советника в пятницу до";
extern bool CloseFriday=true;            // использовать ограничение по времени в пятницу true, не использовать false
extern int CloseFridayHour=19;           // время в пятницу после которого не выставляется первый ордер

double g_price_180;
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
string gs_ilan_272 = "fx.09@mail.ru";
int gi_280 = 0;
int gi_284;
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

int init() {
   gd_260 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   return (0);
}

int deinit() {
   return (0);
}

bool TradeTime(){
static int OrdHisCount;int time;double profit;
if(OrdHisCount==OrdersHistoryTotal())return(false);
for(int i=OrdersHistoryTotal()+1;i>=0;i--){
  if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
    if(OrderSymbol()==Symbol()){
      if(OrderCloseTime()>time){
        time=OrderCloseTime();
        profit=OrderProfit();
      }
    }
  }
}
if(profit>0){if(TimeCurrent()-time>=PauseMin*60){OrdHisCount=OrdersHistoryTotal();return(true);}else{return(false);}}
return(false);
}
int indHMA1open_val;
int start() {
   if(!TradeTime()){if (gi_280 == Time[0]) return (0);}
   gi_280 = Time[0];

   double indHMA1open_Yellow = iCustom(Symbol(), 60, "VininI_HMA", PerHMA, 3, 0, 0, 0, 1);
	double indHMA1open_Green = iCustom(Symbol(), 60, "VininI_HMA", PerHMA, 3, 0, 0, 1, 1);
	double indHMA1open_Red = iCustom(Symbol(), 60, "VininI_HMA", PerHMA, 3, 0, 0, 2, 1);
	if (indHMA1open_Green != EMPTY_VALUE)    indHMA1open_val = 1;
	else    if (indHMA1open_Red != EMPTY_VALUE)    indHMA1open_val = -1;
			  else    if (indHMA1open_Yellow != EMPTY_VALUE)    indHMA1open_val = 0; 
	
   
   double l_iclose_8;
   double l_iclose_14;
   if (UseTrailingStop) TrailingAlls(TrailStart, TrailStop, g_price_212);
   if (UseTimeOut) {
      if (TimeCurrent() >= gi_284) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
 //  if(!TradeTime()){if (gi_280 == Time[0]) return (0);}
 //  gi_280 = Time[0];
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
      if (gi_320 && gd_236 - Ask >= PipStep * Point && indHMA1open_val>0) gi_316 = TRUE;
      if (gi_324 && Bid - gd_244 >= PipStep * Point && indHMA1open_val<0) gi_316 = TRUE;
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
         gd_292 = NormalizeDouble(GetLots() * MathPow(LotExponent, gi_288), lotdecimal);
         RefreshRates();
         gi_328 = OpenPendingOrder(1, gd_292, Bid, slip, Ask, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, HotPink);
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
            gd_292 = NormalizeDouble(GetLots() * MathPow(LotExponent, gi_288), lotdecimal);
            gi_328 = OpenPendingOrder(0, gd_292, Ask, slip, Bid, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, Lime);
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
   if (gi_316 && gi_304 < 1) {
      l_iclose_8 = iClose(Symbol(), 0, 2);
      l_iclose_14 = iClose(Symbol(), 0, 1);
      g_bid_220 = Bid;
      g_ask_228 = Ask;
      if (!gi_324 && !gi_320) {
         gi_288 = gi_304;
         gd_292 = NormalizeDouble(GetLots() * MathPow(LotExponent, gi_288), lotdecimal);

       if(CloseFriday==true&&DayOfWeek()==5&&TimeCurrent()>=StrToTime(CloseFridayHour+":00"))return(0);

       if (l_iclose_8 > l_iclose_14 && indHMA1open_val < 0) 
         {
          if (iHigh(Symbol(), PERIOD_H1, 1)>Bid)
           {
           gi_328 = OpenPendingOrder(1, gd_292, g_bid_220, slip, g_bid_220, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, HotPink);
            if (gi_328 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236 = FindLastBuyPrice();
            gi_332 = TRUE;
            } 
            }
            if (iLow(Symbol(), PERIOD_H1, 1)<Ask)
            {
            if (l_iclose_8 < l_iclose_14 && indHMA1open_val > 0) 
            {
            gi_328 = OpenPendingOrder(0, gd_292, g_ask_228, slip, g_ask_228, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, Lime);
            if (gi_328 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_244 = FindLastSellPrice();
            gi_332 = TRUE;
         }
         }
         if (gi_328 > 0) gi_284 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
         gi_316 = FALSE;
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
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) OrderModify(OrderTicket(), NormalizeDouble(g_price_212,Digits), NormalizeDouble(OrderStopLoss(),Digits), NormalizeDouble(g_price_180,Digits), 0, Yellow);
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
   case 2:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ai_32), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ai_32), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, NormalizeDouble(Ask,Digits), a_slippage_20, NormalizeDouble(StopLong(Bid, ai_32),Digits), NormalizeDouble(TakeLong(Ask, ai_36),Digits), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ai_32), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ai_32), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, NormalizeDouble(Bid,Digits), a_slippage_20, NormalizeDouble(StopShort(Ask, ai_32),Digits), NormalizeDouble(TakeShort(Bid, ai_36),Digits), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
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
   else return (ad_0 - ai_8 * Point);
}

double StopShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 + ai_8 * Point);
}

double TakeLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 - ai_8 * Point);
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
   int l_ticket_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176) {
               if (OrderType() == OP_BUY) {
                  l_ticket_16 = NormalizeDouble((Bid - a_price_8) / Point, 0);
                  if (l_ticket_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Bid - ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20)) OrderModify(OrderTicket(), NormalizeDouble(a_price_8,Digits), NormalizeDouble(l_price_28,Digits), NormalizeDouble(OrderTakeProfit(),Digits), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  l_ticket_16 = NormalizeDouble((a_price_8 - Ask) / Point, 0);
                  if (l_ticket_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Ask + ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 < l_ord_stoploss_20)) OrderModify(OrderTicket(), NormalizeDouble(a_price_8,Digits), NormalizeDouble(l_price_28,Digits), NormalizeDouble(OrderTakeProfit(),Digits), 0, Red);
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
double GetLots() 
{
double minlot = MarketInfo(Symbol(), MODE_MINLOT);
if(risk!=0)
 {
   double lot = NormalizeDouble(AccountBalance() * risk/Percent_Risk / 1000.0, 2);
   if(lot < minlot) lot = minlot;
  }
  else lot=Lot; 
   return(lot);
} 
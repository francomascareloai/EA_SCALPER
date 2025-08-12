//==========================================================================================================================
#property copyright "MT-4"
#property link  "fx.09@mail.ru"   // "Ìàğòèíãåéë"
//==========================================================================================================================
extern double LotExponent = 3.1;  // óìíîæåíèå ëîòîâ â ñåğèè ïî åêñïîíåíòå äëÿ âûâîäà â áåçóáûòîê. ïåğâûé ëîò 0.1, ñåğèÿ: 0.15, 0.26, 0.43 ...
extern double Lots = 0.01;        // òåïåğü ìîæíî è ìèêğîëîòû 0.01 ïğè ıòîì åñëè ñòîèò 0.1 òî ñëåäóşùèé ëîò â ñåğèè áóäåò 0.16
extern int lotdecimal = 2;        // 2 - ìèêğîëîòû 0.01, 1 - ìèíè ëîòû 0.1, 0 - íîğìàëüíûå ëîòû 1.0
extern double TakeProfit = 10.0;  // òåéê ïğîôèò
extern double PipStep = 30.0;     // øàã êîëåíà
extern double slip = 3.0;         // ïğîñêàëüçûâàíèå
extern int MaxTrades = 4;         // ìàêñèìàëüíî êîëè÷åñòâî îäíîâğåìåííî îòêğûòûõ îğäåğîâ
extern int MagicNumber = 111;     // ìàãèê
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool UseEquityStop = FALSE;       // èñïîëüçîâàòü ğèñê â ïğîöåíòàõ
double TotalEquityRisk = 20.0;    // ğèñê â ïğîöåíòàõ îò äåïîçèòà
bool UseTrailingStop = FALSE;     // èñïîëüçîâàòü òğåéëèíã ñòîï
bool UseTimeOut = FALSE;          // èñïîëüçîâàòü àíóëèğîâàíèå îğäåğîâ ïî âğåìåíè
double MaxTradeOpenHours = 48.0;  // ÷åğåç êîëüêî ÷àñîâ àíóëèğîâàòü âèñÿ÷èå îğäåğà
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double Stoploss = 5000.0;         // İòè òğè ïàğàìåòğà íå ğàáîòàşò
double TrailStart = 100.0;
double TrailStop = 100.0;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double PriceTarget, StartEquity, BuyTarget, SellTarget ;
double AveragePrice, SellLimit, BuyLimit ;
double LastBuyPrice, LastSellPrice, Spread;
bool flag;
string EAName = "Ilan_HiLo_RSI";
int timeprev = 0, expiration;
int NumOfTrades = 0;
double iLots;
int cnt = 0, total;
double Stopper = 0.0;
bool TradeNow = FALSE, LongTrade = FALSE, ShortTrade = FALSE;
int ticket;
bool NewOrdersPlaced = FALSE;
double AccountEquityHighAmt, PrevEquity;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int init() {
   Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   return (0);
}

int deinit() {
   return (0);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int start() {
   double PrevCl;
   double CurrCl;
   if (UseTrailingStop) TrailingAlls(TrailStart, TrailStop, AveragePrice);
   if (UseTimeOut) {
      if (TimeCurrent() >= expiration) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   if (timeprev == Time[0]) return (0);
   timeprev = Time[0];
   double CurrentPairProfit = CalculateProfit();
   if (UseEquityStop) {
      if (CurrentPairProfit < 0.0 && MathAbs(CurrentPairProfit) > TotalEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         NewOrdersPlaced = FALSE;
      }
   }
   total = CountTrades();
   if (total == 0) flag = FALSE;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY) {
            LongTrade = TRUE;
            ShortTrade = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_SELL) {
            LongTrade = FALSE;
            ShortTrade = TRUE;
            break;
         }
      }
   }
   if (total > 0 && total <= MaxTrades) {
      RefreshRates();
      LastBuyPrice = FindLastBuyPrice();
      LastSellPrice = FindLastSellPrice();
      if (LongTrade && LastBuyPrice - Ask >= PipStep * Point) TradeNow = TRUE;
      if (ShortTrade && Bid - LastSellPrice >= PipStep * Point) TradeNow = TRUE;
   }
   if (total < 1) {
      ShortTrade = FALSE;
      LongTrade = FALSE;
      TradeNow = TRUE;
      StartEquity = AccountEquity();
   }
   if (TradeNow) {
      LastBuyPrice = FindLastBuyPrice();
      LastSellPrice = FindLastSellPrice();
      if (ShortTrade) {
         NumOfTrades = total;
         iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
         RefreshRates();
         ticket = OpenPendingOrder(1, iLots, Bid, slip, Ask, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, HotPink);
         if (ticket < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         LastSellPrice = FindLastSellPrice();
         TradeNow = FALSE;
         NewOrdersPlaced = TRUE;
      } else {
         if (LongTrade) {
            NumOfTrades = total;
            iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
            ticket = OpenPendingOrder(0, iLots, Ask, slip, Bid, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, Lime);
            if (ticket < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            LastBuyPrice = FindLastBuyPrice();
            TradeNow = FALSE;
            NewOrdersPlaced = TRUE;
         }
      }
   }
   if (TradeNow && total < 1) {
      PrevCl = iHigh(Symbol(), 0, 1);
      CurrCl =  iLow(Symbol(), 0, 2);
      SellLimit = Bid;
      BuyLimit = Ask;
      if (!ShortTrade && !LongTrade) {
         NumOfTrades = total;
         iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
         if (PrevCl > CurrCl) {

//HHHHHHHH~~~~~~~~~~~~~ Èíäşê RSI ~~~~~~~~~~HHHHHHHHH~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               ticket = OpenPendingOrder(1, iLots, SellLimit, slip, SellLimit, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, HotPink);
               if (ticket < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastBuyPrice = FindLastBuyPrice();
               NewOrdersPlaced = TRUE;
            }
         } else {

//HHHHHHHH~~~~~~~~~~~~~ Èíäşê RSI ~~~~~~~~~HHHHHHHHHH~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               ticket = OpenPendingOrder(0, iLots, BuyLimit, slip, BuyLimit, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, Lime);
               if (ticket < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastSellPrice = FindLastSellPrice();
               NewOrdersPlaced = TRUE;
            }
         }
//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï
if (ticket > 0) expiration = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
TradeNow = FALSE;
}
}
total = CountTrades();
AveragePrice = 0;
double Count = 0;
for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
AveragePrice += OrderOpenPrice() * OrderLots();
Count += OrderLots();
}
}
}
if (total > 0) AveragePrice = NormalizeDouble(AveragePrice / Count, Digits);
if (NewOrdersPlaced) {
for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
if (OrderType() == OP_BUY) {
PriceTarget = AveragePrice + TakeProfit * Point;
BuyTarget = PriceTarget;
Stopper = AveragePrice - Stoploss * Point;
flag = TRUE;
}
}
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
if (OrderType() == OP_SELL) {
PriceTarget = AveragePrice - TakeProfit * Point;
SellTarget = PriceTarget;
Stopper = AveragePrice + Stoploss * Point;
flag = TRUE;
}
}
}
}
if (NewOrdersPlaced) {
if (flag == TRUE) {
for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) OrderModify(OrderTicket(), AveragePrice, OrderStopLoss(), PriceTarget, 0, Yellow);
NewOrdersPlaced = FALSE;
}
}
}
return (0);
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï

int CountTrades() {
int count = 0;
for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
}
return (count);
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï

void CloseThisSymbolAll() {
for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() == Symbol()) {
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip, Blue);
if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip, Red);
}
Sleep(1000);
}
}
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï

int OpenPendingOrder(int pType, double pLots, double pPrice, int pSlippage, double pr, int sl, int tp, string pComment, int pMagic, int pDatetime, color pColor) {
int ticket = 0;
int err = 0;
int c = 0;
int NumberOfTries = 100;
switch (pType) {
case 2:
for (c = 0; c < NumberOfTries; c++) {
ticket = OrderSend(Symbol(), OP_BUYLIMIT, pLots, pPrice, pSlippage, StopLong(pr, sl), TakeLong(pPrice, tp), pComment, pMagic, pDatetime, pColor);
err = GetLastError();
if (err == 0/* NO_ERROR */) break;
if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
Sleep(1000);
}
break;
case 4:
for (c = 0; c < NumberOfTries; c++) {
ticket = OrderSend(Symbol(), OP_BUYSTOP, pLots, pPrice, pSlippage, StopLong(pr, sl), TakeLong(pPrice, tp), pComment, pMagic, pDatetime, pColor);
err = GetLastError();
if (err == 0/* NO_ERROR */) break;
if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 0:
for (c = 0; c < NumberOfTries; c++) {
RefreshRates();
ticket = OrderSend(Symbol(), OP_BUY, pLots, Ask, pSlippage, StopLong(Bid, sl), TakeLong(Ask, tp), pComment, pMagic, pDatetime, pColor);
err = GetLastError();
if (err == 0/* NO_ERROR */) break;
if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 3:
for (c = 0; c < NumberOfTries; c++) {
ticket = OrderSend(Symbol(), OP_SELLLIMIT, pLots, pPrice, pSlippage, StopShort(pr, sl), TakeShort(pPrice, tp), pComment, pMagic, pDatetime, pColor);
err = GetLastError();
if (err == 0/* NO_ERROR */) break;
if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 5:
for (c = 0; c < NumberOfTries; c++) {
ticket = OrderSend(Symbol(), OP_SELLSTOP, pLots, pPrice, pSlippage, StopShort(pr, sl), TakeShort(pPrice, tp), pComment, pMagic, pDatetime, pColor);
err = GetLastError();
if (err == 0/* NO_ERROR */) break;
if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
break;
case 1:
for (c = 0; c < NumberOfTries; c++) {
ticket = OrderSend(Symbol(), OP_SELL, pLots, Bid, pSlippage, StopShort(Ask, sl), TakeShort(Bid, tp), pComment, pMagic, pDatetime, pColor);
err = GetLastError();
if (err == 0/* NO_ERROR */) break;
if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
Sleep(5000);
}
}
return (ticket);
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï
double StopLong(double price, int stop) {
if (stop == 0) return (0);
else return (price - stop * Point);
}
//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï
double StopShort(double price, int stop) {
if (stop == 0) return (0);
else return (price + stop * Point);
}
//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï
double TakeLong(double price, int stop) {
if (stop == 0) return (0);
else return (price + stop * Point);
}
//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï
double TakeShort(double price, int stop) {
if (stop == 0) return (0);
else return (price - stop * Point);
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï

double CalculateProfit() {
double Profit = 0;
for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
if (OrderType() == OP_BUY || OrderType() == OP_SELL) Profit += OrderProfit();
}
return (Profit);
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï

void TrailingAlls(int pType, int stop, double AvgPrice) {
int profit;
double stoptrade;
double stopcal;
if (stop != 0) {
for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES)) {
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
if (OrderType() == OP_BUY) {
profit = NormalizeDouble((Bid - AvgPrice) / Point, 0);
if (profit < pType) continue;
stoptrade = OrderStopLoss();
stopcal = Bid - stop * Point;
if (stoptrade == 0.0 || (stoptrade != 0.0 && stopcal > stoptrade)) OrderModify(OrderTicket(), AvgPrice, stopcal, OrderTakeProfit(), 0, Aqua);
}
if (OrderType() == OP_SELL) {
profit = NormalizeDouble((AvgPrice - Ask) / Point, 0);
if (profit < pType) continue;
stoptrade = OrderStopLoss();
stopcal = Ask + stop * Point;
if (stoptrade == 0.0 || (stoptrade != 0.0 && stopcal < stoptrade)) OrderModify(OrderTicket(), AvgPrice, stopcal, OrderTakeProfit(), 0, Red);
}
}
Sleep(1000);
}
}
}
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï

double AccountEquityHigh() {
if (CountTrades() == 0) AccountEquityHighAmt = AccountEquity();
if (AccountEquityHighAmt < PrevEquity) AccountEquityHighAmt = PrevEquity;
else AccountEquityHighAmt = AccountEquity();
PrevEquity = AccountEquity();
return (AccountEquityHighAmt);
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï

double FindLastBuyPrice() {
double oldorderopenprice;
int oldticketnumber;
double unused = 0;
int ticketnumber = 0;
for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
oldticketnumber = OrderTicket();
if (oldticketnumber > ticketnumber) {
oldorderopenprice = OrderOpenPrice();
unused = oldorderopenprice;
ticketnumber = oldticketnumber;
}
}
}
return (oldorderopenprice);
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï

double FindLastSellPrice() {
double oldorderopenprice;
int oldticketnumber;
double unused = 0;
int ticketnumber = 0;
for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
oldticketnumber = OrderTicket();
if (oldticketnumber > ticketnumber) {
oldorderopenprice = OrderOpenPrice();
unused = oldorderopenprice;
ticketnumber = oldticketnumber;
}
}
}
return (oldorderopenprice);
}

//ïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïïï





//+------------------------------------------------------------------+
//|                                                       shakka.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define _Balance         AccountInfoDouble(ACCOUNT_BALANCE)
#define _Equity          AccountInfoDouble(ACCOUNT_EQUITY)
#define _MarginRequired  (double)MarketInfo(_Symbol, MODE_MARGINREQUIRED)
#define _LotStep         SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)
#define _LotMin          SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)
#define _LotMax          SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)
#define _TickValue       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE)
#define _TickSize        SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)
#define _Pip             (double)((_Digits==3 || _Digits==5) ? _Point*10 : _Point)
#define _DigitsPip       (int)log10(1/_Pip)
#define _Digitslot       (int)log10(1/_LotStep)
#define _PointValue      (double)_Point/_TickSize*_TickValue
#define _PipValue        (double)((_TickValue*_Pip)/_TickSize)
#define _Ask             SymbolInfoDouble(_Symbol, SYMBOL_ASK)
#define _Bid             SymbolInfoDouble(_Symbol, SYMBOL_BID)
#define _BrokerSpread    (double)(_Ask-_Bid)
//define
#define  EA_NAME    "Exp_Slingshot"
#define  EA_VERSION "Rev_1.00 [2022.03.04]"
string   EA_COMMENT="";

enum ENUM_MONEY_MANAGEMENT {None, FixedLot, ByRisk, ByMargin};

input ENUM_MONEY_MANAGEMENT   InpMMType         = None;     // Select MM Type
input string                  InpStartTime      = "04:15";      // Start Time
input string                  InpEndTime        = "08:30";      // End Time
input double                  InpLotPercent     = 1.5;      // Lot % for Risk or Margin
input double                  InpLots           = 0.1;      // Fixed Lot
input double                  InpRRRatio1       = 1;        // RR First TP
input double                  InpRRRatio2       = 2;        // RR Second TP
input double                  InpRRRatio3       = 3;        // RR Third TP
//input double                  InpTakeProfit     = 100.0;    // Take Profit
input double                  InpStopLoss       = 30.0;    // Stop Loss in Pips
input double                  InpDistancePips   = 20;       // Distance pips to pending level
input int                     InpSlippage       = 10;       // Slippage
input double                  InpMaxSpread      = 6.0;      // Max Spread we allowed
input int                     InpMagic          = 234;      // magic number

// V A R I A B L E S
//ulong m_InpSlippage=10;
double   ExtDistancePips=0.0;
double   ExtTakeProfit=0.0;
double   ExtStopLoss=0.0;
int      count_buy, count_sell, count_buystop, count_sellstop, count_all_orders ;
double   buy_op, sell_op, buystop_op, sellstop_op;
double   buy_sl, sell_sl, buystop_sl, sellstop_sl;
double   buy_tp, sell_tp, buystop_tp, sellstop_tp;
double   buy_lot, sell_lot, buystop_lot, sellstop_lot;
double   buy_profit, sell_profit;
int      buy_ticket=-1, buystop_ticket=-1;
int      sell_ticket=-1, sellstop_ticket=-1;
double   NextLot=0, InitialLot=0;
bool     opThisBar = false;
double   LongPrice=0, LongStop=0, LongTake1=0, LongTake2=0, LongTake3=0;
double   ShortPrice=0, ShortStop=0, ShortTake1=0, ShortTake2=0, ShortTake3=0;
datetime signal_time=0;
int      bar_index=0;
double   openCandle=0;
string   ObjPrefix  = _Symbol+"_";
string   VLineStart = ObjPrefix+"StartTime";
string   VLineEnd   = ObjPrefix+"EndTime";
string   TLineEntry = ObjPrefix+"Entry";
double   closeStart=0,  closeEnd=0, closeNow=0;
datetime ExtStartTime=0, ExtEndTime=0, ExtStartTrade=0;
bool     opAllowed=false;
datetime t0=0;
datetime tRight=0;;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   ExtDistancePips = InpDistancePips * _Pip;
   //ExtTakeProfit   = InpTakeProfit   * _Pip;
   ExtStopLoss     = InpStopLoss   * _Pip;

   OnInitSetChartVisual();
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   OrdersInformation();
   UpdateParams();

   if (IsNewBar(PERIOD_CURRENT)) opThisBar = false;
   if (opThisBar) return;

   ManageOrder();
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---

}
//+------------------------------------------------------------------+
void ManageOrder()
{
   if(InpMaxSpread < _BrokerSpread/_Pip) {
      Print("Spread is too wide");
      return;
   }
   if(Time[1]!=ExtEndTime)return;

   EA_COMMENT = EA_NAME+"_"+_Symbol+"_"+(string)InpMagic;

   LongStop  = NormalizePrice(closeEnd-ExtStopLoss);
   LongTake1  = NormalizePrice(closeEnd+(ExtStopLoss*InpRRRatio1));
   LongTake2  = NormalizePrice(closeEnd+(ExtStopLoss*InpRRRatio2));
   LongTake3  = NormalizePrice(closeEnd+(ExtStopLoss*InpRRRatio3));
   ShortStop  = NormalizePrice(closeEnd+ExtStopLoss+_BrokerSpread);
   ShortTake1  = NormalizePrice(closeEnd-(ExtStopLoss*InpRRRatio1));
   ShortTake2  = NormalizePrice(closeEnd-(ExtStopLoss*InpRRRatio2));
   ShortTake3  = NormalizePrice(closeEnd-(ExtStopLoss*InpRRRatio3));

   if(count_buy==0 && closeEnd<closeStart) {
      if (OpenOrder(OrderSend(_Symbol, OP_BUY, RecalculateLot(_Ask, LongStop), _Ask, InpSlippage, LongStop, LongTake1, EA_COMMENT, InpMagic, 0, clrNONE))) {
         if (OpenOrder(OrderSend(_Symbol, OP_BUY, RecalculateLot(_Ask, LongStop), _Ask, InpSlippage, LongStop, LongTake2, EA_COMMENT, InpMagic, 0, clrNONE))) {
            if (OpenOrder(OrderSend(_Symbol, OP_BUY, RecalculateLot(_Ask, LongStop), _Ask, InpSlippage, LongStop, LongTake3, EA_COMMENT, InpMagic, 0, clrNONE))) {
               opThisBar=true;
               return;
            }
         }
      }
   }
   if(count_sell==0 && closeEnd>closeStart) {
      if (OpenOrder(OrderSend(_Symbol, OP_SELL, RecalculateLot(_Bid, ShortStop), _Bid, InpSlippage, ShortStop, ShortTake1, EA_COMMENT, InpMagic, 0, clrNONE))) {
         if (OpenOrder(OrderSend(_Symbol, OP_SELL, RecalculateLot(_Bid, ShortStop), _Bid, InpSlippage, ShortStop, ShortTake2, EA_COMMENT, InpMagic, 0, clrNONE))) {
            if (OpenOrder(OrderSend(_Symbol, OP_SELL, RecalculateLot(_Bid, ShortStop), _Bid, InpSlippage, ShortStop, ShortTake3, EA_COMMENT, InpMagic, 0, clrNONE))) {
               opThisBar=true;
               return;
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrdersInformation()
{
   /*
   count_all_orders=0;
   count_buy=0;      count_sell=0;     count_buystop=0;     count_sellstop=0;
   buy_lot=0.0;      sell_lot=0.0;     buystop_lot=0.0;     sellstop_lot=0.0;
   buy_op=0.0;       sell_op=0.0;      buystop_op=0.0;      sellstop_op=0.0;
   buy_sl=0.0;       sell_sl=0.0;      buystop_sl=0.0;      sellstop_sl=0.0;
   buy_tp=0.0;       sell_tp=0.0;      buystop_tp=0.0;      sellstop_tp=0.0;

   buy_profit=0.0;   sell_profit=0.0;

   buy_ticket=-1;    buystop_ticket=-1;
   sell_ticket=-1;   sellstop_ticket=-1;

   */
   count_all_orders=0;
   count_buy=0;
   count_sell=0;
   count_buystop=0;
   count_sellstop=0;
   buy_lot=0.0;
   sell_lot=0.0;
   buystop_lot=0.0;
   sellstop_lot=0.0;
   buy_op=0.0;
   sell_op=0.0;
   buystop_op=0.0;
   sellstop_op=0.0;
   buy_sl=0.0;
   sell_sl=0.0;
   buystop_sl=0.0;
   sellstop_sl=0.0;
   buy_tp=0.0;
   sell_tp=0.0;
   buystop_tp=0.0;
   sellstop_tp=0.0;

   buy_profit=0.0;
   sell_profit=0.0;

   buy_ticket=-1;
   buystop_ticket=-1;
   sell_ticket=-1;
   sellstop_ticket=-1;

   for (int c=0; c < OrdersTotal(); c++ ) {
      if (OrderSelect(c, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() != Symbol())continue;
         if (OrderMagicNumber() != InpMagic)continue;
         switch (OrderType()) {
         case OP_BUY :
            count_buy++;
            buy_ticket=OrderTicket();
            buy_lot=OrderLots();
            buy_sl = OrderStopLoss();
            buy_op = OrderOpenPrice();
            buy_tp = OrderTakeProfit();
            buy_profit = OrderProfit();
            break;
         case OP_SELL :
            count_sell++;
            sell_ticket=OrderTicket();
            sell_lot=OrderLots();
            sell_op = OrderOpenPrice();
            sell_sl = OrderStopLoss();
            sell_tp = OrderTakeProfit();
            sell_profit = OrderProfit();
            break;
         case OP_BUYSTOP :
            count_buystop++;
            buystop_ticket=OrderTicket();
            buystop_lot=OrderLots();
            buystop_tp = OrderTakeProfit();
            buystop_sl = OrderStopLoss();
            buystop_op = OrderOpenPrice();
            break;
         case OP_SELLSTOP:
            count_sellstop++;
            sellstop_ticket=OrderTicket();
            sellstop_lot=OrderLots();
            sellstop_op = OrderOpenPrice();
            sellstop_sl = OrderStopLoss();
            sellstop_tp = OrderTakeProfit();
            break;
         }
         count_all_orders++;
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RecalculateLot(double p, double sl)
{
   double volume = 0.0, price=0, stop=0, range=0,
          riskFactor=0, riskForTrade=0,
          risk=0, riskPerLot=0,
          lotByRisk=0, lotByMargin=0;

   riskFactor  = InpLotPercent/100;
   riskForTrade = riskFactor*_Balance;
   range = MathAbs(p-sl);

   riskPerLot = range * (1 / _Point) * _PointValue;

   lotByRisk = riskForTrade / riskPerLot;
   lotByMargin = riskForTrade/_MarginRequired;

   volume = (InpMMType==ByRisk) ? MathFloor(lotByRisk/_LotStep)*_LotStep :
            (InpMMType==ByMargin) ? MathFloor(lotByMargin/_LotStep)*_LotStep : InpLots ;

   return NormalizeLot(volume);
}
//+------------------------------------------------------------------+
bool OpenOrder(int tiket)
{
   int c = 10;
   while (!OrderSelect(tiket,SELECT_BY_TICKET)) {
      if (tiket < 1) return(false);
      Sleep(1000);
      c--;
      if (c == 0) return(false);
   }
   return(OrderTicket() == tiket);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar(const ENUM_TIMEFRAMES tf = PERIOD_CURRENT)
{
   datetime bar_time=0;

   if (bar_time < iTime(Symbol(), tf, 0)) {
      bar_time = iTime(Symbol(), tf, 0);
      return (true);
   }
   return (false);
}

//+------------------------------------------------------------------+
double NormalizePrice(double price)
{
   return(MathRound(price/_TickSize) * _TickSize );
}
//+------------------------------------------------------------------+
double NormalizeLot(double lots)
{
   ResetLastError();
   lots = MathMax(MathMin(_LotMax, lots), _LotMin);
   return(MathRound(lots/_LotStep) * _LotStep );
}
//+------------------------------------------------------------------+
void UpdateParams()
{
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   if(CopyRates(Symbol(),0,0,100,rates)<0) {
      return;
   }
   ExtStartTime  = StrToTime(InpStartTime);
   ExtEndTime    = StrToTime(InpEndTime);
   ExtStartTrade = (datetime)long ((StrToTime(InpEndTime)) + Period()*60);
   ObjVLine(VLineStart, ExtStartTime);
   ObjVLine(VLineEnd, ExtEndTime);
   int barShiftStart = iBarShift(_Symbol,PERIOD_CURRENT, ExtStartTime);
   int barShiftEnd   = iBarShift(_Symbol,PERIOD_CURRENT, ExtEndTime);
   int barShiftStop  = iBarShift(_Symbol,PERIOD_CURRENT, ExtStartTrade);
   t0         = rates[0].time;
   tRight     = ExtEndTime + Period()*60;
   closeStart = t0>ExtStartTime?rates[barShiftStart].close:0;
   closeEnd   = t0>ExtStartTime?rates[barShiftEnd].close:0;


   if(t0<=ExtEndTime && t0>=ExtStartTime) {
      ObjCMTLine(TLineEntry, clrAqua, STYLE_SOLID, 2, ExtStartTime, closeStart, t0<ExtEndTime?t0:ExtEndTime, closeEnd);
   }
   else if(t0<ExtStartTime) {
      if(IsPresentObjects(ObjPrefix)) {
         ObjectsDeleteAll(0, ObjPrefix, 0, OBJ_TREND);
         ObjectsDeleteAll(0, ObjPrefix, 0, OBJ_TEXT);
      }
   }
   if(t0>ExtEndTime) {
      if(LT(closeEnd, closeStart)) {
         longGraphics(ExtEndTime, tRight);
      }
      else if(GT(closeEnd, closeStart)) {
         shortGraphics(ExtEndTime, tRight);
      }
   }
   Comment (
      "~~~~~~~~~~~~~~","\n",
      "Slingshot_EA","\n",
      " ","\n",
      "Balance :  ", DoubleToString(_Balance, 2),"\n",
      "Equity :  ", DoubleToString(_Equity, 2),"\n",
      "~~~~~~~~~~~~~~","\n",
      "Start Close :  ", DoubleToString(closeStart, _Digits),"\n",
      "End Close  :  ", DoubleToString(closeEnd, _Digits),"\n",
      "~~~~~~~~~~~~~~"
   );
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void longGraphics(datetime tNow, datetime tR)
{
   ObjCMTLine(ObjPrefix+"BuySL", clrPink, STYLE_DASHDOTDOT, 1, ExtStartTime, closeEnd-ExtStopLoss, tNow, closeEnd-ExtStopLoss);
   ObjCMTLine(ObjPrefix+"BuyTP1", clrAqua, STYLE_DASHDOTDOT, 1, ExtStartTime, closeEnd+(ExtStopLoss*InpRRRatio1), tNow, closeEnd+(ExtStopLoss*InpRRRatio1));
   ObjCMTLine(ObjPrefix+"BuyTP2", clrAqua, STYLE_DASHDOTDOT, 1, ExtStartTime, closeEnd+(ExtStopLoss*InpRRRatio2), tNow, closeEnd+(ExtStopLoss*InpRRRatio2));
   ObjCMTLine(ObjPrefix+"BuyTP3", clrAqua, STYLE_DASHDOTDOT, 1, ExtStartTime, closeEnd+(ExtStopLoss*InpRRRatio3), tNow, closeEnd+(ExtStopLoss*InpRRRatio3));
   ObjCMText(ObjPrefix+"BuySLText", clrPink, "Buy SL ["+DoubleToString(closeEnd-ExtStopLoss,_Digits)+"]", tR, closeEnd-ExtStopLoss, ANCHOR_LEFT);
   ObjCMText(ObjPrefix+"BuyTP1Text", clrAqua, "Buy TP1 ["+DoubleToString(closeEnd+(ExtStopLoss*InpRRRatio1),_Digits)+"]", tR, closeEnd+(ExtStopLoss*InpRRRatio1), ANCHOR_LEFT);
   ObjCMText(ObjPrefix+"BuyTP2Text", clrAqua, "Buy TP2 ["+DoubleToString(closeEnd+(ExtStopLoss*InpRRRatio2),_Digits)+"]", tR, closeEnd+(ExtStopLoss*InpRRRatio2), ANCHOR_LEFT);
   ObjCMText(ObjPrefix+"BuyTP3Text", clrAqua, "Buy TP3 ["+DoubleToString(closeEnd+(ExtStopLoss*InpRRRatio3),_Digits)+"]", tR, closeEnd+(ExtStopLoss*InpRRRatio3), ANCHOR_LEFT);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void shortGraphics(datetime tNow, datetime tR)
{
   ObjCMTLine(ObjPrefix+"SellSL", clrAqua, STYLE_DASHDOTDOT, 1, ExtStartTime, closeEnd+ExtStopLoss+_BrokerSpread, tNow, closeEnd+ExtStopLoss+_BrokerSpread);
   ObjCMTLine(ObjPrefix+"SellTP1", clrPink, STYLE_DASHDOTDOT, 1, ExtStartTime, closeEnd-(ExtStopLoss*InpRRRatio1), tNow, closeEnd-(ExtStopLoss*InpRRRatio1));
   ObjCMTLine(ObjPrefix+"SellTP2", clrPink, STYLE_DASHDOTDOT, 1, ExtStartTime, closeEnd-(ExtStopLoss*InpRRRatio2), tNow, closeEnd-(ExtStopLoss*InpRRRatio2));
   ObjCMTLine(ObjPrefix+"SellTP3", clrPink, STYLE_DASHDOTDOT, 1, ExtStartTime, closeEnd-(ExtStopLoss*InpRRRatio3), tNow, closeEnd-(ExtStopLoss*InpRRRatio3));
   ObjCMText(ObjPrefix+"SellSLText", clrAqua, "Sell SL ["+DoubleToString(closeEnd+ExtStopLoss,_Digits)+"]", tR, closeEnd+ExtStopLoss+_BrokerSpread, ANCHOR_LEFT);
   ObjCMText(ObjPrefix+"SellTP1Text", clrPink, "Sell TP1 ["+DoubleToString(closeEnd-(ExtStopLoss*InpRRRatio1),_Digits)+"]", tR, closeEnd-(ExtStopLoss*InpRRRatio1), ANCHOR_LEFT);
   ObjCMText(ObjPrefix+"SellTP2Text", clrPink, "Sell TP2 ["+DoubleToString(closeEnd-(ExtStopLoss*InpRRRatio2),_Digits)+"]", tR, closeEnd-(ExtStopLoss*InpRRRatio2), ANCHOR_LEFT);
   ObjCMText(ObjPrefix+"SellTP3Text", clrPink, "Sell TP3 ["+DoubleToString(closeEnd-(ExtStopLoss*InpRRRatio3),_Digits)+"]", tR, closeEnd-(ExtStopLoss*InpRRRatio3), ANCHOR_LEFT);

}
//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool ObjVLine (const string   name=" ",datetime time=0)
{
   if(ObjectFind(0, name) == -1) {
      if(!ObjectCreate(ChartID(), name, OBJ_VLINE, 0, time, 0)) {
         Print(__FUNCTION__, ": failed to create a vertical line! Error code = ", GetLastError());
         return(false);
      }
   }
   else if(!ObjectMove(ChartID(), name, 0, time, 0)) {
      Print(__FUNCTION__, ": failed to move vertical! Error code = ", GetLastError());
      return(false);
   }
   ObjectSetInteger(ChartID(),name,OBJPROP_COLOR, clrPink);
   ObjectSetInteger(ChartID(),name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(ChartID(),name,OBJPROP_WIDTH,1);
   ObjectSetInteger(ChartID(),name,OBJPROP_BACK,false);
   ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(ChartID(),name,OBJPROP_SELECTED,false);
   ObjectSetInteger(ChartID(),name,OBJPROP_RAY,true);
   ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(ChartID(),name,OBJPROP_ZORDER,0);
   return(true);
}
//+------------------------------------------------------------------+
// TrendLine Handling                                                |
//+------------------------------------------------------------------+
bool ObjCMTLine(string    name,   // line name
                color     clr,
                ENUM_LINE_STYLE  style,
                int       width,
                datetime  time1,
                double    price1,
                datetime  time2,
                double    price2
               )
{
   if(ObjectFind(0, name) == -1) {
      if(!ObjectCreate(0, name, OBJ_TREND, 0, time1, price1, time2, price2)) {
         Print(__FUNCTION__, ": failed to create a trend line! Error code = ", GetLastError());
         return(false);
      }
   }
   else if(!ObjectMove(0, name, 0, time1, price1) || !ObjectMove(0, name, 1, time2, price2)) {
      Print(__FUNCTION__, ": failed to move trendline! Error code = ", GetLastError());
      return(false);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   return(true);
}
//+------------------------------------------------------------------+
void OnInitSetChartVisual()
{
   ChartSetInteger(ChartID(),CHART_SHIFT,true);
   ChartSetDouble(ChartID(),CHART_SHIFT_SIZE,30);
   ChartSetInteger(ChartID(),CHART_MODE,CHART_CANDLES);
   ChartSetInteger(ChartID(),CHART_SHOW_PERIOD_SEP, false);
   ChartSetInteger(ChartID(),CHART_SHOW_OHLC, true);
   ChartSetInteger(ChartID(),CHART_SHOW_GRID, false);
   ChartSetInteger(ChartID(),CHART_FOREGROUND, true);
   ChartSetInteger(ChartID(),CHART_BRING_TO_TOP,true);
   ChartSetInteger(ChartID(),CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(ChartID(),CHART_AUTOSCROLL,true);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Return the flag of a prefixed object presence                    |
//+------------------------------------------------------------------+
bool IsPresentObjects(const string object_prefix)
{
   for(int i=ObjectsTotal(0, 0)-1; i>=0; i--)
      if(StringFind(ObjectName(i), object_prefix)>WRONG_VALUE)
         return true;
   return false;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
bool ObjCMText(const string            name="Text",              // object name
               const color             clr=clrRed,               // color
               const string            text="Text",              // the text itself
               datetime                time=0,                   // anchor point time
               double                  price=0,                  // anchor point price
               const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER // anchor type
              )                // priority for mouse click
{
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(ObjectFind(0, name) == -1) {
      if(!ObjectCreate(ChartID(),name,OBJ_TEXT,0,time,price)) {
         Print(__FUNCTION__,
               ": failed to create \"Text\" object! Error code = ",GetLastError());
         return(false);
      }
   }
   else if(!ObjectMove(ChartID(),name,0,time,price)) {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
   }
   ObjectSetString(ChartID(),name,OBJPROP_TEXT,text);
   ObjectSetString(ChartID(),name,OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(ChartID(),name,OBJPROP_FONTSIZE,9);
   ObjectSetDouble(ChartID(),name,OBJPROP_ANGLE,0.0);
   ObjectSetInteger(ChartID(),name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(ChartID(),name,OBJPROP_COLOR,clr);
   ObjectSetInteger(ChartID(),name,OBJPROP_BACK,false);
   ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(ChartID(),name,OBJPROP_SELECTED,false);
   ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(ChartID(),name,OBJPROP_ZORDER,0);
   return(true);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Compares two doubles and returns a value indicating whether one  |
//| is nearly equal to, less than, or greater than the other.        |
//+------------------------------------------------------------------+
int Compare(double a, double b, int digits)
{
// bool res = MathAbs(a - b) < 0.5 * MathPow(10, -digits);
   bool res = NormalizeDouble(a - b, digits) == 0;
//---
   if(res)
      return 0;
   else
      return (a > b) ? 1 : -1;
}
//+------------------------------------------------------------------+
//| Is Equal.                                                        |
//+------------------------------------------------------------------+
bool EQ(double a, double b, int digits = 8)
{
   return Compare(a, b, digits) == 0;
}
//+------------------------------------------------------------------+
//| Is Not Equal.                                                    |
//+------------------------------------------------------------------+
bool NE(double a, double b, int digits = 8)
{
   return Compare(a, b, digits) != 0;
}
//+------------------------------------------------------------------+
//| Is Greater Than.                                                 |
//+------------------------------------------------------------------+
bool GT(double a, double b, int digits = 8)
{
   return Compare(a, b, digits) > 0;
}
//+------------------------------------------------------------------+
//| Is Less Than.                                                    |
//+------------------------------------------------------------------+
bool LT(double a, double b, int digits = 8)
{
   return Compare(a, b, digits) < 0;
}
//+------------------------------------------------------------------+
//| Greater Than or Equal.                                           |
//+------------------------------------------------------------------+
bool GTE(double a, double b, int digits = 8)
{
   return Compare(a, b, digits) >= 0;
}
//+------------------------------------------------------------------+
//| Is Less Than or Equal.                                           |
//+------------------------------------------------------------------+
bool LTE(double a, double b, int digits = 8)
{
   return Compare(a, b, digits) <= 0;
}
//+------------------------------------------------------------------+

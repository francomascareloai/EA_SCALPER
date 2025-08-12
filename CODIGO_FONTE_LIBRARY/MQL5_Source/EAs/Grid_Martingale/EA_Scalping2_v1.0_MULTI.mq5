#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link         "https://www.mql5.com"
#property version        "1.00"
#include <Trade\Trade.mqh>
CTrade         trade;
CPositionInfo pos;
COrderInfo     ord;
//+------------------------------------------------------------------+

input group "=== Trading Profiles ===";

enum SystemType{Forex=0, Bitcoin=1, _Gold=2, US_Indices=3};
input SystemType SType=0; //Trading System applied (Forex, Crypto, Gold, Indices)
int SysChoice;

input group "=== Comman Trading Inputs ==="
input double RiskPercent          = 3;          // Risk as % of Trading Capital
input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Time frame to run
input int    InpMagic             = 298347;     // EA identification no
input string TradeComment         = "Scalping Robot";
double Tppoints, Slpoints, TslTriggerPoints, TslPoints;
enum StartHour {Inactive=0, _0100=1, _0300=3, _0400=4, _0500=5, _0600=6, _0700=7, _0800=8, _0900=9, _1000=10, _1100=11,
                 _1200=12, _1300=13, _1400=14, _1500=15, _1600=16, _1700=17, _1800=18, _1900=19, _2000=20, _2100=21,
                 _2200=22, _2300=23};
input StartHour SHInput=8;       // Start Hour
enum EndHour {Inactive=0, _0100=1, _0300=3, _0400=4, _0500=5, _0600=6, _0700=7, _0800=8, _0900=9, _1000=10, _1100=11,
               _1200=12, _1300=13, _1400=14, _1500=15, _1600=16, _1700=17, _1800=18, _1900=19, _2000=20, _2100=21,
               _2200=22, _2300=23};
input EndHour EHInput=21;       // End Hour


input group "=== Forex Trading Inputs ==="
input int    TpPoints             = 200;        // Take Profit (10 points = 1 pip)
input int    SlPoints             = 200;        // Stoploss Points (10 points = 1 pip)
input int    TslTriggerPointsInputs     = 15;         // Points in profit before Trailing SL is activated (10 points = 1 pip)
input int    TslPointsInputs         = 10;         // Trailing Stop Loss (10 points = 1 pip)


input group "===Crypto Related Input===(effective only under Bitcoin profile)";

input double TPasPct = 0.4;     // TP as % of Price
input double SLasPct = 0.4;     // SL as % of Price
input double TSLasPctofTP = 5;  // Trail SL as % of TP
input double TSLTrgasPctofTP = 7; // Trigger of Trail SL % of TP

input group "===Gold Related Input===(effective only under Gold profile)";

input double TPasPctGold = 0.2;     // TP as % of Price
input double SLasPctGold = 0.2;     // SL as % of Price
input double TSLasPctofTPGold = 5;  // Trail SL as % of TP
input double TSLTrgasPctofTPGold = 7; // Trigger of Trail SL % of TP

input group "===Indices Related Input===(effective only under Indices profile)";

input double TPasPctIndices = 0.2;     // TP as % of Price
input double SLasPctIndices = 0.2;     // SL as % of Price
input double TSLasPctofTPIndices = 5;  // Trail SL as % of TP
input double TSLTrgasPctofTPIndices = 7; // Trigger of Trail SL % of TP





int SHChoice;
int EHChoice;

int BarsN           = 5;
int ExpirationBars  = 100;
double OrderDistPoints = 100;

int OnInit() {
  trade.SetExpertMagicNumber(InpMagic);
  ChartSetInteger(0, CHART_SHOW_GRID, false);

  SHChoice = SHInput;
  EHChoice = EHInput;


  if(SType==SystemType::Forex) SysChoice=0;
  if(SType==SystemType::Bitcoin) SysChoice=1;
  if(SType==SystemType::_Gold) SysChoice=2;
  if(SType==SystemType::US_Indices) SysChoice=3;


  // Use the input variables directly
  Tppoints = TpPoints;
  Slpoints = SlPoints;
  TslTriggerPoints = TslTriggerPointsInputs;
  TslPoints = TslPointsInputs;
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
}

void OnTick() {
  TrailStop();

  if (!IsNewBar()) return;

  MqlDateTime time;
  TimeToStruct(TimeCurrent(), time);
  int HourNow = time.hour;



  if (HourNow < SHChoice) {
    CloseAllOrders();
    return;
  }
  if (HourNow >= EHChoice && EHChoice != 0) {
    CloseAllOrders();
    return;
  }

  if (SysChoice==1){
    double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    Tppoints = ask * TPasPct;
    Slpoints = ask * SLasPct;
    OrderDistPoints = Tppoints/2.0; // Use 2.0 for double division
    TslPoints = Tppoints * TSLasPctofTP /100.0;
    TslTriggerPoints = Tppoints * TSLTrgasPctofTP/100.0;
  }
  if (SysChoice==2){
    double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    Tppoints = ask * TPasPctGold;
    Slpoints = ask * SLasPctGold;
    OrderDistPoints = Tppoints/2.0; // Use 2.0 for double division
    TslPoints = Tppoints * TSLasPctofTPGold/100.0;
    TslTriggerPoints = Tppoints * TSLTrgasPctofTPGold/100.0;
  }

  if (SysChoice==3){
    double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    Tppoints = ask * TPasPctIndices;
    Slpoints = ask * SLasPctIndices;
    OrderDistPoints = Tppoints/2.0; // Use 2.0 for double division
    TslPoints = Tppoints * TSLasPctofTPIndices/100.0;
    TslTriggerPoints = Tppoints * TSLTrgasPctofTPIndices/100.0;
  }


  int BuyTotal = 0;
  int SellTotal = 0;

  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    pos.SelectByIndex(i);
    if (pos.PositionType() == POSITION_TYPE_BUY && pos.Symbol() == _Symbol && pos.Magic() == InpMagic) BuyTotal++;
    if (pos.PositionType() == POSITION_TYPE_SELL && pos.Symbol() == _Symbol && pos.Magic() == InpMagic) SellTotal++;
  }

  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    ord.SelectByIndex(i);
    if (ord.OrderType() == ORDER_TYPE_BUY_STOP && ord.Symbol() == _Symbol && ord.Magic() == InpMagic) BuyTotal++;
    if (ord.OrderType() == ORDER_TYPE_SELL_STOP && ord.Symbol() == _Symbol && ord.Magic() == InpMagic) SellTotal++;
  }

   if (BuyTotal <= 0) {
    double high = findHigh();
    if (high > 0) {
      SendBuyOrder(high);
    }
  }

  if (SellTotal <= 0) {
    double low = findLow();
    if (low > 0) {
      SendSellOrder(low);
    }
  }
}
double findHigh() {
  double highestHigh = 0;
  for (int i = 0; i < 200; i++) {
    double high = iHigh(_Symbol,TimeFrame, i);
    if (i > BarsN && iHighest(_Symbol,TimeFrame, MODE_HIGH, BarsN * 2 + 1, i - BarsN) == i) {
      if (high > highestHigh) {
        return high;
      }
    }
    highestHigh = MathMax(high, highestHigh);
  }
  return -1;
}
double findLow() {
  double lowestLow = DBL_MAX;
  for (int i = 0; i < 200; i++) {
    double low = iLow(_Symbol,TimeFrame, i);
    if (i > BarsN && iLowest(_Symbol,TimeFrame, MODE_LOW, BarsN * 2 + 1, i - BarsN) == i) {
      if (low < lowestLow) {
        return low;
      }
    }
    lowestLow = MathMin(low, lowestLow);
  }
  return -1;
}
bool IsNewBar() {
  static datetime previousTime = 0;
  datetime currentTime = iTime(_Symbol, TimeFrame, 0);
  if (previousTime != currentTime) {
    previousTime = currentTime;
    return true;
  }
  return false;
}

void SendBuyOrder(double entry) {
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  if (ask > entry - OrderDistPoints * _Point) return;

  double tp = entry + Tppoints * _Point; // Use the global Tppoints
  double sl = entry - Slpoints * _Point; // Use the global Slpoints

  double lots = 0.01;
  if (RiskPercent > 0) lots = calcLots(entry - sl);

  datetime expiration = iTime(_Symbol, TimeFrame, 0) + ExpirationBars * PeriodSeconds(TimeFrame);
  trade.BuyStop(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration);
}

void SendSellOrder(double entry) {
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  if (bid < entry + OrderDistPoints * _Point) return;

  double tp = entry - Tppoints * _Point; // Use the global Tppoints
  double sl = entry + Slpoints * _Point; // Use the global Slpoints

  double lots = 0.01;
  if (RiskPercent > 0) lots = calcLots(sl - entry);

  datetime expiration = iTime(_Symbol,TimeFrame, 0) + ExpirationBars * PeriodSeconds(TimeFrame);
  trade.SellStop(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration);
}
double calcLots(double slPoints) {
  double risk = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100;
  double ticksize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
  double tickvalue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
  double minvolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  double maxvolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
  double volumelimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  double moneyPerLotStep = slPoints / ticksize * tickvalue * lotstep;
  double lots = MathFloor(risk / moneyPerLotStep) * lotstep;

  if (volumelimit != 0) lots = MathMin(lots, volumelimit);
  if (maxvolume != 0) lots = MathMin(lots, maxvolume);
  if (minvolume != 0) lots = MathMax(lots, minvolume);
  lots = NormalizeDouble(lots, 2);
  return lots;
}
void CloseAllOrders() {
  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    ord.SelectByIndex(i);
    ulong ticket = ord.Ticket();
    if (ord.Symbol() == _Symbol && ord.Magic() == InpMagic) {
      trade.OrderDelete(ticket);
    }
  }
}

void TrailStop() {
  double sl = 0;
  double tp = 0;
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong ticket = pos.Ticket();
    if (pos.SelectByIndex(i)) {
      if (pos.Magic() == InpMagic && pos.Symbol() == _Symbol) {
        if (pos.PositionType() == POSITION_TYPE_BUY) {
          if (bid - pos.PriceOpen() > TslTriggerPoints * _Point) {
            tp = pos.TakeProfit();
            sl = bid - (TslPoints * _Point);
            if (sl > pos.StopLoss() && sl != 0) {
              trade.PositionModify(ticket, sl, tp);
            }
          }
        } else if (pos.PositionType() == POSITION_TYPE_SELL) {
          if (ask - pos.PriceOpen() < -(TslTriggerPoints * _Point)) {
            tp = pos.TakeProfit();
            sl = ask + (TslPoints * _Point);
            if (sl < pos.StopLoss() && sl != 0) {
              trade.PositionModify(ticket, sl, tp);
            }
          }
        }
      }
    }
  }
}
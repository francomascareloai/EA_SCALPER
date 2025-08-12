#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link         "https://www.mql5.com"
#property version        "1.00"
#include <Trade\Trade.mqh>
CTrade         trade;
CPositionInfo pos;
COrderInfo     ord;
//+------------------------------------------------------------------+


enum SystemType{Forex=0, Bitcoin=1, _Gold=2, US_Indices=3};
enum StartHour {Inactive=0, _0100=1, _0300=3, _0400=4, _0500=5, _0600=6, _0700=7, _0800=8, _0900=9, _1000=10, _1100=11,
                 _1200=12, _1300=13, _1400=14, _1500=15, _1600=16, _1700=17, _1800=18, _1900=19, _2000=20, _2100=21,
                 _2200=22, _2300=23};
enum EndHour {Inactive=0, _0100=1, _0300=3, _0400=4, _0500=5, _0600=6, _0700=7, _0800=8, _0900=9, _1000=10, _1100=11,
               _1200=12, _1300=13, _1400=14, _1500=15, _1600=16, _1700=17, _1800=18, _1900=19, _2000=20, _2100=21,
               _2200=22, _2300=23};
enum enumLotType {Fixed_Lots=0, Pct_of_Balance=1, Pct_of_Equity=2, Pct_of_Free_Margin=3};


input group "=== Trading Profiles ===";




input SystemType SType=0; //Trading System applied (Forex, Crypto, Gold, Indices)
int SysChoice;

input group "=== Comman Trading Inputs ==="

input enumLotType LotType = 1; // Type of Lotsize (Fixed or % Risk)
input double Fixedlots = 0.01; // Fixed Lots (if selected)
input double RiskPercent          = 3;          // Risk as % of Trading Capital
input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Time frame to run
input int    InpMagic             = 298347;     // EA identification no
input string TradeComment         = "Scalping Robot";
double Tppoints, Slpoints, TslTriggerPoints, TslPoints;

input StartHour SHInput=8;       // Start Hour

input EndHour EHInput=21;       // End Hour

int               handleRSI, handleMovAvg;
input color       ChartColorTradingOff = clrPink;    // Chart color when EA is Inactive
input color       ChartColorTradingOn  = clrBlack;   // Chart color when EA is active
bool              Tradingenabled       = true;
input bool        HideIndicators       = true;       // Hide Indicators on Chart?
string            TradingEnabledComm   = "";





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

int BarsN           = 100;
int ExpirationBars  = 100;
double OrderDistPoints = 100;





input group "=== News Filter ==="
input bool      NewsFilterOn      = true;  //Filter for Level 3 News?
enum sep_dropdown{comma=0,semicolon=1};
input sep_dropdown separator         = 0;     //Separator to separate news keywords
input string    KeyNews           = "BCB,NFP,JOLTS,Nonfarm,PMI,Retail,GDP,Confidence,Interest Rate"; // News Keywords
input string    NewsCurrencies    = "USD,GBP,EUR,JPY"; //Currencies for News LookUp
input int       DaysNewsLookup    = 100;   // No of Days to look up news
input int       StopBeforeMin     = 15;    // Stop Trading before (in minutes)
input int       StartTradingMin   = 15;    // Start Trading after (in minutes)
bool            TrDisabledNews    = false; // variable to store if trading disabled due to news

ushort          sep_code;
string          Newstoavoid[];
datetime        LastNewsAvoided;

input group "=== RSI Filter ==="
input bool           RSIFilterOn    = false;      // Filter for RSI extremes?
input ENUM_TIMEFRAMES RSITimeframe   = PERIOD_H1;  // Timeframe for RSI filter
input int            RSIlowerlvl    = 20;         // RSI Lower level to filter
input int            RSIupperlvl    = 80;         // RSI Upper level to filter
input int            RSI_MA         = 14;         // RSI Period
input ENUM_APPLIED_PRICE RSI_AppPrice = PRICE_MEDIAN; // RSI Applied Price

input group "=== Moving Average Filter ==="
input bool           MAFilterOn     = false;      // Filter for Moving Average extremes?
input ENUM_TIMEFRAMES MATimeframe    = PERIOD_H4;  // Timeframe for Moving Average Filter
input double         PctPricefromMA = 3;          // % Price is away from Mov Avg to be extreme
input int            MA_Period      = 200;        // Moving Average Period
input ENUM_MA_METHOD   MA_Mode        = MODE_EMA;   // Moving Average Mode/Method
input ENUM_APPLIED_PRICE MA_AppPrice  = PRICE_MEDIAN; // Moving Avg Applied Price


input group "=== Trading Allowed by Days ==="
input bool AllowedMonday    = true;  // Trading Allowed on Monday?
input bool AllowedTuesday   = true;  // Trading Allowed on Tuesday?
input bool AllowedWednesday = true;  // Trading Allowed on Wednesday?
input bool AllowedThursday  = true;  // Trading Allowed on Thursday?
input bool AllowedFriday    = true;  // Trading Allowed on Friday?
input bool AllowedSaturday  = true;  // Trading Allowed on Saturday?
input bool AllowedSunday    = true;  // Trading Allowed on Sunday?
bool       DayFilterOn    = true;






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
  
  if (HideIndicators == true) TesterHideIndicators(true);
  
  handleRSI = iRSI(_Symbol, RSITimeframe, RSI_MA, RSI_AppPrice);
  handleMovAvg = iMA(_Symbol, MATimeframe, MA_Period, 0, MA_Mode, MA_AppPrice);
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
}

void OnTick() {
  TrailStop();
  if (!IsNewBar()) return;
  
  if (IsRSIFilter() || IsUpcomingNews() || IsMAFilter() || !IsTradingAllowedbyDay()) {
    CloseAllOrders();
    Tradingenabled = false;
    ChartSetInteger(0, CHART_COLOR_BACKGROUND, ChartColorTradingOff);
    if (TradingEnabledComm != "Printed") {
      Print(TradingEnabledComm);
      TradingEnabledComm = "Printed";
      }
      return;
    }
    
    Tradingenabled = true;
    if (TradingEnabledComm != "") {
      Print("Trading is enabled again");
      TradingEnabledComm = "";
     }
     
     ChartSetInteger(0, CHART_COLOR_BACKGROUND, ChartColorTradingOn);

  

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
  double lots = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  
  double AccountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  double EquityBalance = AccountInfoDouble(ACCOUNT_EQUITY);
  double FreeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

  double risk = 0;
  switch (LotType) {
  case 0: lots = Fixedlots; return lots;
  case 1: risk = AccountBalance * RiskPercent / 100; break;
  case 2: risk = EquityBalance * RiskPercent / 100; break;
  case 3: risk = FreeMargin * RiskPercent / 100; break;
  }
  
  
  
  
  
  //double risk = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100;
  double ticksize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
  double tickvalue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
  double minvolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  double maxvolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
  double volumelimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  double moneyPerLotStep = slPoints / ticksize * tickvalue * lotstep;
  lots = MathFloor(risk / moneyPerLotStep) * lotstep;

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
bool IsUpcomingNews() {
  if (NewsFilterOn == false) return false;

  if (TrDisabledNews && TimeCurrent() - LastNewsAvoided < StartTradingMin * PeriodSeconds(PERIOD_M1)) return true;
  TrDisabledNews = false;

  string sep;
  switch (separator) {
    case 0: sep = ","; break;
    case 1: sep = ";"; break;
  }

  sep_code = StringGetCharacter(sep, 0);
  int k = StringSplit(KeyNews, sep_code, Newstoavoid);

  MqlCalendarValue values[];
  datetime starttime = TimeCurrent(); //iTime(_Symbol,PERIOD_D1,0);
  datetime endtime = starttime + PeriodSeconds(PERIOD_D1) * DaysNewsLookup;

  CalendarValueHistory(values, starttime, endtime, NULL, NULL);

  for (int i = 0; i < ArraySize(values); i++) {
    MqlCalendarEvent event;
    CalendarEventById(values[i].event_id, event);
    MqlCalendarCountry country;
    CalendarCountryById(event.country_id, country);


    if (StringFind(NewsCurrencies, country.currency) < 0) continue;

    for (int j = 0; j < k; j++) {
      string currentevent = Newstoavoid[j];
      string currentnews = event.name;
      if (StringFind(currentnews, currentevent) < 0) continue;

      Comment("Next News: ", country.currency, ": ", event.name, " -> ", values[i].time);
      if (values[i].time - TimeCurrent() < StopBeforeMin * PeriodSeconds(PERIOD_M1)) {
        LastNewsAvoided = values[i].time;
        TrDisabledNews = true;
        if (TradingEnabledComm == "" || TradingEnabledComm != "Printed") {
          TradingEnabledComm = "Trading is disabled due to upcoming news: " + event.name;
        }
        return true;
      }
      
    }
    return false;
  }
  return false;
}

bool IsRSIFilter() {
  if (RSIFilterOn == false) return (false);

  double RSI[];
  CopyBuffer(handleRSI, MAIN_LINE, 0, 1, RSI);
  ArraySetAsSeries(RSI, true);

  double RSInow = RSI[0];

   

  if (RSInow > RSIupperlvl || RSInow < RSIlowerlvl) {
    if (TradingEnabledComm == "" || TradingEnabledComm != "Printed") {
      TradingEnabledComm = "Trading is disabled due to RSI filter";
    }
    return (true);
  }

  return false;
}

bool IsMAFilter() {
  if (MAFilterOn == false) return (false);

  double MovAvg[];
  CopyBuffer(handleMovAvg, MAIN_LINE, 0, 1, MovAvg);
  ArraySetAsSeries(MovAvg, true);

  double MAnow = MovAvg[0];
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  if (ask > MAnow * (1 + PctPricefromMA / 100) ||
      ask < MAnow * (1 - PctPricefromMA / 100)) {
    if (TradingEnabledComm == "" || TradingEnabledComm != "Printed") {
      TradingEnabledComm = "Trading is disabled due to Mov Avg Filter";
    }
    return true;
  }

  return false;
}

bool IsTradingAllowedbyDay() {
  MqlDateTime today;
  TimeCurrent(today);
  string Daytoday = EnumToString((ENUM_DAY_OF_WEEK)today.day_of_week);

  if (AllowedMonday == true && Daytoday == "MONDAY") return true;
  if (AllowedTuesday == true && Daytoday == "TUESDAY") return true;
  if (AllowedWednesday == true && Daytoday == "WEDNESDAY") return true;
  if (AllowedThursday == true && Daytoday == "THURSDAY") return true;
  if (AllowedFriday == true && Daytoday == "FRIDAY") return true;
  if (AllowedSaturday == true && Daytoday == "SATURDAY") return true;
  if (AllowedSunday == true && Daytoday == "SUNDAY") return true;
  
  if (TradingEnabledComm == "" || TradingEnabledComm != "Printed") {
  TradingEnabledComm = "Trading is not allowed on " + Daytoday;
}
return false;
}

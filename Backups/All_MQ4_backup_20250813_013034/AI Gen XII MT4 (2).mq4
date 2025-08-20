#include <stdlib.mqh>


extern string _Desc2 = " MM ";
extern int _exPositionsTp = 2;
extern int _exeTPSLType = 1;
extern double _dxTakeProfit = 70.0;
extern double _dxStopLoss = 320.0;
extern int _ixRisk = 180;
extern double _dxRiskDecreaser = 1.0;
extern bool _bxRecovery = FALSE;
extern int _ixRecoveryTrades = 2;
extern double _dxRecoveryFactor = 3.0;
extern bool _bxCloseOnFriday = FALSE;
extern int _ixCloseHour = 21;
extern bool _ixAutoLotSize = TRUE;
extern double _dxLotSize = 0.01;
extern bool _bxUsePropFirm = FALSE;
extern double _dxUsesBalance = 0.0;
extern double _dxMaxDrawdownBalance = 0.0;
extern double _dxMaxDrawdown = 4.3;
extern bool _bxUseTrailing = FALSE;
extern double _dxTrailingStart = 52.0;
extern double _dxTrailingStep = 17.0;
extern string _sxTradingDays = "1,2,3,4,5";
extern int _ixMaxSpread = 0;
extern string _sxParamDesc1 = " ";
extern string _sxParamDesc11 = " MC ";
extern int _ixExpertMagic = 5005;
extern string _sxExpertComment = "AI GEN XII";
extern string _sxParamDesc10 = " ";
extern string _sxParamDesc101 = " GPT ";
extern int _ixGPTModel = 3;
extern bool _bxGPTBoost = FALSE;
extern int _eixAggrsTrading = 1;
extern int _iexGPTFunc = 0;
extern bool bxApplyNewsFilterToAllPairs = TRUE;
extern int _ixNewsMinutesBefore = 120;
extern int _ixNewsMinutesAfter = 60;
extern bool _ebxDisAnimation = FALSE;
extern bool _bxDrawMenu = TRUE;




 double    Lots         = 0.1;
 int       StartTimeGMT = 400;       // Start trading at 4:00 GMT
 int       StopTimeGMT  = 900;       // Stop trading at  9:00 GMT
 int       Hi_Timeframe = PERIOD_H4; // Higher timeframe to test
 int       Lo_Timeframe = PERIOD_H1; // Lower timeframe to test
 int       NoBars       = 3;         // Number of bars
 int       Pips_offset  = 1;         // Offset for entry above 3 Bars
 int       DaysExit     = 1;         // Exit the same day close (2-next day close, etc).
 int       StopLoss     = 30;   // 0 deactivates Stop Loss
 int       TrailingStop = 0;    // 0 deactivates Trailing Stop
 int       TakeProfit   = 0;    // 0 deactivates Take Profit
 int       GainForBE    = 0;    // How many pips will trigger Break Even
 int       PipsBE       = 0;    // Level at which Break Even will be put
 int       Slippage     = 3;

#define MAGIC 200707012

int init()
{
  Comment("Waiting for the first tick...");
  return(0);
}

int deinit()
{
  Comment(WindowExpertName()," finished.");
  return(0);
}

int start()
{
  if(Bars<100)
  {
    Comment("Waiting for bars...");
    return(0);
  }

  int _gmt_offset = MathRound(TimeZoneServer());
  datetime _StartTime = StartTimeGMT + _gmt_offset;
  datetime _StopTime  = StopTimeGMT  + _gmt_offset;
  return(_3barHiLo(Symbol(), Period(), MAGIC, Lots, StopLoss, TrailingStop, TakeProfit, GainForBE, PipsBE, Slippage,
                   _StartTime, _StopTime, Hi_Timeframe, Lo_Timeframe, NoBars, Pips_offset, DaysExit));
}

int _3barHiLo(string symbol, int period, int magic, double lots, int stoploss, int trailingstop, int takeprofit, 
              int gainforbe, int pipsbe, int slippage, int starttime, int stoptime,
              int hi_timeframe=PERIOD_H4, int lo_timeframe=PERIOD_H1, int nobars=3, int pips_offset=1, int daysexit=0)
{
  // Internals
  int _Digits = MarketInfo(symbol, MODE_DIGITS), i;
  if(_Digits == 0) _Digits = 4;
  double _Point = MarketInfo(symbol, MODE_POINT);
  if(NormalizeDouble(_Point, _Digits) == 0.0) _Point = Point;
  double _Bid = MarketInfo(symbol, MODE_BID);
  double _Ask = MarketInfo(symbol, MODE_ASK);
  int   _iBid = MathRound(_Bid/_Point);
  string _cm = "Time GMT: " ;
  bool _can_open = true;

  // TRADING TIMES If not in trading times close all positions and exit
  datetime _now = TimeCurrent();
  datetime _st = MathFloor(_now/86400)*86400 + MathRound(starttime/100)*3600+MathMod(starttime, 100)*60;
  datetime _en = MathFloor(_now/86400)*86400 + MathRound(stoptime/100)*3600+MathMod(stoptime, 100)*60;
  while(_st <= _now) _st += 86400;
  while(_en <= _now) _en += 86400;
  if(_st<_en) _can_open = false;
  // END OF TRADING TIMES

  // Signals
  static bool _long  = false;
  static bool _short = false;
  if(_iBid > MathRound(iHigh(symbol, hi_timeframe, iHighest(symbol, hi_timeframe, MODE_HIGH, nobars, 1))/_Point))
    if(_iBid >= MathRound(iHigh(symbol, lo_timeframe, iHighest(symbol, lo_timeframe, MODE_HIGH, nobars,1))/_Point)+pips_offset)
      _long = _can_open;
  if(_iBid < MathRound(iLow(symbol, hi_timeframe, iLowest(symbol, hi_timeframe, MODE_LOW, nobars, 1))/_Point))
    if(_iBid >= MathRound(iLow(symbol, lo_timeframe, iLowest(symbol, lo_timeframe, MODE_LOW, nobars,1))/_Point)+pips_offset)
      _short = _can_open;
  if(!_ip(OP_BUY, symbol, magic))
  if(_long) Print("Bid: ", _iBid,"; H4: ",MathRound(iHigh(symbol, hi_timeframe, iHighest(symbol, hi_timeframe, MODE_HIGH, nobars, 1))/_Point),"; H1: ",
                  MathRound(iHigh(symbol, lo_timeframe, iHighest(symbol, lo_timeframe, MODE_HIGH, nobars,1))/_Point));
  if(!_ip(OP_SELL, symbol, magic))
  if(_short) Print("Bid: ",_iBid,"; H4: ",MathRound(iLow(symbol, hi_timeframe, iLowest(symbol, hi_timeframe, MODE_LOW, nobars, 1))/_Point),"; H1: ",
                   MathRound(iLow(symbol, lo_timeframe, iLowest(symbol, lo_timeframe, MODE_LOW, nobars,1))/_Point));
  // Signals

  // S&R
  bool _send_ok = true;
  if(_long){
    if(_ip(OP_SELL, symbol, magic))
      _OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, Red);
    if(!_ip(OP_BUY, symbol, magic))
      _send_ok = _OrderSend(symbol, OP_BUY, _nv(symbol, lots), _Ask, slippage, _sl(OP_BUY, symbol, _Bid, stoploss), _tp(OP_BUY, symbol, _Bid, takeprofit),
                            WindowExpertName(), magic, 0, Blue) > 0;
  }
  if(_short){
    if(_ip(OP_BUY, symbol, magic))
      _OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, Blue);
    if(!_ip(OP_SELL, symbol, magic))
      _send_ok = _OrderSend(symbol, OP_SELL, _nv(symbol, lots), _Bid, slippage, _sl(OP_SELL, symbol, _Ask, stoploss), _tp(OP_SELL, symbol, _Ask, takeprofit),
                            WindowExpertName(), magic, 0, Red) > 0;
  }
  // S&R
  
  if(_ip(OP_BUY, symbol, magic))
  {
    int diff = MathFloor((TimeCurrent()-OrderOpenTime())/86400.0);
    if(TimeDayOfYear(OrderOpenTime())!=DayOfYear()) diff++; 
    if(diff>=daysexit) _fa(symbol, magic);
  }
  if(_ip(OP_SELL, symbol, magic))
  {
    diff = MathFloor((TimeCurrent()-OrderOpenTime())/86400.0);
    if(TimeDayOfYear(OrderOpenTime())!=DayOfYear()) diff++; 
    if(diff>=daysexit) _fa(symbol, magic);
  }

  // TrailingStop
  if(trailingstop > 0)
    for(i=0; i < OrdersTotal(); i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
        if(OrderSymbol() == symbol)
          if(OrderMagicNumber() == magic)
            if(OrderType() == OP_BUY){
              if(MathRound((OrderClosePrice()-OrderStopLoss())/_Point) > trailingstop)
                if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderClosePrice()-trailingstop*_Point, OrderTakeProfit(),
                                OrderExpiration(), Blue))
                  Print("OrderModify(OP_BUY) error - ", ErrorDescription(GetLastError()));    
            }else if(OrderType() == OP_SELL){
              if((MathRound((OrderStopLoss()-OrderClosePrice())/_Point) > trailingstop)||(OrderStopLoss()<_Bid))
                if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderClosePrice()+trailingstop*_Point, OrderTakeProfit(),
                                OrderExpiration(), Red))
                  Print("OrderModify(OP_SELL) error - ", ErrorDescription(GetLastError()));    
            }
      }else
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
  // TrailingStop

  // BreakEven
  if(gainforbe > 0)
    for(i=0; i < OrdersTotal(); i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
        if(OrderSymbol() == symbol)
          if(OrderMagicNumber() == magic)
            if(OrderType() == OP_BUY){
              if(MathRound((OrderClosePrice()-OrderOpenPrice())/_Point) >= gainforbe)
              if(MathRound((OrderStopLoss()-OrderOpenPrice())/_Point) < pipsbe)
                if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()+pipsbe*_Point, OrderTakeProfit(),
                                OrderExpiration(), Blue))
                  Print("OrderModify(OP_BUY) error - ", ErrorDescription(GetLastError()));    
            }else if(OrderType() == OP_SELL){
              if(MathRound((OrderOpenPrice()-OrderClosePrice())/_Point) >= gainforbe)
              if(MathRound((OrderOpenPrice()-OrderStopLoss())/_Point) < pipsbe)
                if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-pipsbe*_Point, OrderTakeProfit(),
                                OrderExpiration(), Red))
                  Print("OrderModify(OP_SELL) error - ", ErrorDescription(GetLastError()));    
            }
      }else
        Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
  // BreakEven

  if(_send_ok){
    _long = false;
    _short = false;
  }
  Comment(_cm);
  return(0);
}

bool _ip(int type, string symbol, int magic)
{
  for(int i=OrdersTotal()-1; i >= 0; i--)
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
    if(OrderType() == type)
    if(OrderSymbol() == symbol)
    if(OrderMagicNumber() == magic)
      return(true);
    }else
      Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
  return(false);
}

void _fa(string symbol, int magic, bool manualmode=false) // Flat all
{
  for(int i=OrdersTotal()-1; i >= 0; i--)
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
    if(OrderSymbol() == symbol)
    if(OrderMagicNumber() == magic||manualmode)
      if(OrderType() <= OP_SELL)
        _OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, Gray);
      else
        _OrderDelete(OrderTicket());
    }else
      Print("OrderSelect() error - ", ErrorDescription(GetLastError()));
}

double _sl(int type, string symbol, double price, int stoploss, int offset=0)
{
  if(type == OP_BUY||type == OP_BUYSTOP||type == OP_BUYLIMIT)
    if(stoploss > 0)
      return(price-(stoploss+offset)*MarketInfo(symbol, MODE_POINT));
    else
      return(0.0);
  else if(type == OP_SELL||type == OP_SELLSTOP||type == OP_SELLLIMIT)
    if(stoploss > 0)
      return(price+(stoploss+offset)*MarketInfo(symbol, MODE_POINT));
    else
      return(0.0);    
  return(0.0);
}

double _tp(int type, string symbol, double price, int takeprofit, int offset=0)
{
  if(type == OP_BUY)
    if(takeprofit > 0||type == OP_BUYSTOP||type == OP_BUYLIMIT)
      return(price+(takeprofit+offset)*MarketInfo(symbol, MODE_POINT));
    else
      return(0.0);
  else if(type == OP_SELL||type == OP_SELLSTOP||type == OP_SELLLIMIT)
    if(takeprofit > 0)
      return(price-(takeprofit+offset)*MarketInfo(symbol, MODE_POINT));
    else
      return(0.0);
  return(0.0);
}

double _nv(string symbol, double lots, bool return_zero=false){
  // Adjust trade volume to broker. Take into account minimum & maximum position size.
  double step   = MarketInfo(symbol, MODE_LOTSTEP);
  double min    = MarketInfo(symbol, MODE_MINLOT);
  double max    = MarketInfo(symbol, MODE_MAXLOT);
  if(step > 0)
  if(max  > 0)
    if(return_zero)
      return(MathMin(MathRound(lots/step)*step, max));
    else if(min > 0) // When you don't want return 0 lots (default)
      return(MathMax(MathMin(MathRound(lots/step)*step, max), min));    
  return(lots);
}

#include <stderror.mqh>

int _OrderSend(string symbol, int cmd, double lots, double price, int slippage, double stoploss, double takeprofit,
               string comment, int magic, datetime expiration, color cl)
{
  int ticket = OrderSend(symbol, cmd, lots, price, slippage, stoploss, takeprofit, comment, magic, expiration, cl);
  if(ticket < 0){
    int err = GetLastError();
    Print("ERROR OrderSend #",err,": ", ErrorDescription(err),_strcmd(cmd, symbol, price));
  }
  return(ticket);
}

string _strcmd(int cmd, string symbol, double price)
{
  int _mode;
  int _d = MarketInfo(symbol, Digits);
  string _str = "";
  switch(cmd)
  {
    case OP_BUY: 
      _mode = MODE_ASK;
      _str  = "; BUY @"+DoubleToStr(price, _d);
      break;
    case OP_SELL:
      _mode = MODE_BID;
      _str  = "; BUY @"+DoubleToStr(price, _d);
      break;
    default:
      break;
  }
    
  _str = _str +"; market @" + DoubleToStr(MarketInfo(symbol, _mode), _d);
  return(_str);
}

bool _OrderClose(int ticket, double lots, double price, int slippage, color cl=CLR_NONE)
{
  bool result = OrderClose(ticket, lots, price, slippage, cl);
  if(!result){
    int err = GetLastError();
    Print("ERROR OrderClose #",err,": ", ErrorDescription(err));
  }
  return(result);
}

bool _OrderDelete(int ticket)
{
  bool result = OrderDelete(ticket);
  if(!result){
    int err = GetLastError();
    Print("ERROR OrderDelete #",err,": ", ErrorDescription(err));
  }
  return(result);
}

#import "kernel32.dll"
int  GetTimeZoneInformation(int& TZInfoArray[]);
#import

#define TIME_ZONE_ID_UNKNOWN   0
#define TIME_ZONE_ID_STANDARD  1
#define TIME_ZONE_ID_DAYLIGHT  2

// Local timezone in hours, adjusting for daylight saving
double TimeZoneLocal()
{
	int TZInfoArray[43];

	switch(GetTimeZoneInformation(TZInfoArray))
	{
	case TIME_ZONE_ID_UNKNOWN: 
		Print("Error obtaining PC timezone from GetTimeZoneInformation in kernel32.dll. Returning 0");
		return(0);

	case TIME_ZONE_ID_STANDARD:
		return(TZInfoArray[0]/(-60.0));
	
	case TIME_ZONE_ID_DAYLIGHT:
		return((TZInfoArray[0]+TZInfoArray[42])/(-60.0));
		
	default:
		Print("Unkown return value from GetTimeZoneInformation in kernel32.dll. Returning 0");
		return(0);
	}
}

// Server timezone in hours
double TimeZoneServer()
{
	int ServerToLocalDiffMinutes = (TimeCurrent()-TimeLocal())/60;
	
	// round to nearest 30 minutes to allow for inaccurate PC clock
	int nHalfHourDiff = MathRound(ServerToLocalDiffMinutes/30.0);
	ServerToLocalDiffMinutes = nHalfHourDiff*30;
	return(TimeZoneLocal() + ServerToLocalDiffMinutes/60.0);
}

// Uses local PC time, local PC timezone, and server time to calculate GMT time at arrival of last tick
datetime TimeGMT()
{
	// two ways of calculating
	// 1. From PC time, which may not be accurate
	// 2. From server time. Most accurate except when server is down on weekend
	datetime dtGmtFromLocal = TimeLocal() - TimeZoneLocal()*3600;
	datetime dtGmtFromServer = TimeCurrent() - TimeZoneServer()*3600;

	// return local-derived value if server value is out by more than 5 minutes, eg during weekend
	if (dtGmtFromLocal > dtGmtFromServer + 300)
	{
		return(dtGmtFromLocal);
	}
	else
	{
		return(dtGmtFromServer);
	}	
}
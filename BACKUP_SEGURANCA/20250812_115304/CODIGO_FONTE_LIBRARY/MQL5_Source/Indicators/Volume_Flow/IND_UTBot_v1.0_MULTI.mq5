#define MODE_POINT 11
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73431

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright � 2023, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright � 2023, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window#property indicator_buffers 3
#property indicator_plots 3
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type2 DRAW_NONE
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double xATRTrailingStop[];

//--- variables
double nLoss, xATR;

// ------------------------------------------------------------------
input double m          = 2;      // Key value:
input double atrPeriods = 1;     // ATR periods:
input bool   h          = false;  // Signals From Heinken Ashi Candles

input string T1                    = "== Notifications ==";  // 
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // 
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrDodgerBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
// ------------------------------------------------------------------
class CCandle
{
  int    _timeFrame;
  string _symbol;
  double _open;
  double _high;
  double _low;
  double _close;
  float  _size;
  string _type;
  string _direction;
  float  _bodySize;
  float  _shadowSup;
  float  _shadowInf;

 public:
  CCandle() { ; }
  CCandle(string sym, int tf) : _symbol(sym), _timeFrame(tf) {}
  ~CCandle() { ; }

  // Getters
  float Size(void) { return _size; 
 return NULL;
}
  string Type(void) { return _type; 
 return NULL;
}
  double Open(void) { return _open; 
 return NULL;
}
  double High(void) { return _high; 
 return NULL;
}
  double Low(void) { return _low; 
 return NULL;
}
  double Close(void) { return _close; 
 return NULL;
}
  string Direction(void) { return _direction; 
 return NULL;
}
  float BodySize(void) { return _bodySize; 
 return NULL;
}
  float ShadowSup(void) { return _shadowSup; 
 return NULL;
}
  float ShadowInf(void) { return _shadowInf; 
 return NULL;
}

  void setCandle(int shift = 1)
  {
    _open  = DFAF::iOpen(_symbol, _timeFrame, shift);
    _high  = DFAF::iHigh(_symbol, _timeFrame, shift);
    _low   = DFAF::iLow(_symbol, _timeFrame, shift);
    _close = DFAF::iClose(_symbol, _timeFrame, shift);

    setDirection();
    setSize();
    setBodySize();
    setShadows();
  }
  void setSize()
  {
    _size = 1;
    if (Distance(_high, _low, _symbol) > 0)
    {
      _size = Distance(_high, _low, _symbol);
    }
  }
  void setBodySize()
  {
    _bodySize = 1;
    if (Distance(_open, _close, _symbol) > 0)
    {
      _bodySize = Distance(_open, _close, _symbol);
    }
  }
  void setDirection()
  {
    if (_open < _close)
    {
      _direction = "up";
    }
    if (_open > _close)
    {
      _direction = "down";
    }
    if (_open == _close)
    {
      _direction = "null";
    }
  }
  void PrintCandle()
  {
    Print(__FUNCTION__, " ", "symbol", " ", _symbol);
    Print(__FUNCTION__, " ", "open", " ", _open);
    Print(__FUNCTION__, " ", "high", " ", _high);
    Print(__FUNCTION__, " ", "low", " ", _low);
    Print(__FUNCTION__, " ", "close", " ", _close);
    Print(__FUNCTION__, " ", "_size;", " ", _size);
    Print(__FUNCTION__, " ", "_type;", " ", _type);
    Print(__FUNCTION__, " ", "_direction;", " ", _direction);
    Print(__FUNCTION__, " ", "_bodySize;", " ", _bodySize);
    Print(__FUNCTION__, " ", "_shadowSup;", " ", _shadowSup);
    Print(__FUNCTION__, " ", "_shadowInf;", " ", _shadowInf);
  }
  void setShadows()
  {
    if (Direction() == "up")
    {
      _shadowInf = Distance(_open, _low, _symbol);
      _shadowSup = Distance(_close, _high, _symbol);
    }
    if (Direction() == "down")
    {
      _shadowInf = Distance(_close, _low, _symbol);
      _shadowSup = Distance(_open, _high, _symbol);
    }
    if (Direction() == "null")
    {
      _shadowInf = Distance(_close, _low, _symbol);
      _shadowSup = Distance(_open, _high, _symbol);
    }
  }
  float Distance(double precioA, double precioB, string par)
  {
    double mPoint     = DFAF::MarketInfo(par, MODE_POINT);
    double dist       = fabs(precioA - precioB);
    double distReturn = 0;
    if (mPoint > 0) distReturn = dist / mPoint;
    return distReturn;
  }
};
CCandle candle1();
CCandle candle2();

class CNewCandle
{
 private:
  int    _initialCandles;
  string _symbol;
  int    _tf;

 public:
  CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(DFAF::iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = DFAF::iBars(Symbol(), Period());
    _symbol         = Symbol();
    _tf             = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = DFAF::iBars(_symbol, _tf);
    if (_currentCandles > _initialCandles)
    {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();

// ------------------------------------------------------------------
void OnInit()
{
  //--- indicator buffers mapping
  DFAF::SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
  DFAF::SetIndexArrow(0, 221);
  DFAF::SetIndexStyle(0, DRAW_ARROW, -1, 1, ArrowUpClr);
  DFAF::SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
  DFAF::SetIndexArrow(1, 222);
  DFAF::SetIndexStyle(1, DRAW_ARROW, -1, 1, ArrowDnClr);
  DFAF::SetIndexBuffer(2, xATRTrailingStop);
  DFAF::SetIndexStyle(2, DRAW_NONE);

  if (!ArrowsOn)
  {
    DFAF::SetIndexStyle(0, DRAW_NONE);
    DFAF::SetIndexStyle(1, DRAW_NONE);
  }
  //---
  return;
}
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

int __OnCalculate__(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  int i = 1000;
  if (i >= rates_total) i = rates_total - 1;
  for (; i > 0; i--)
  {
    xATR  = DFAF::iATR(NULL, 0, atrPeriods, i);
    nLoss = m * xATR;

    double cl  = close[i];
    double cl1 = close[i + 1];
	
		// clang-format off
    xATRTrailingStop[i] = cl > xATRTrailingStop[i + 1] && cl1 > xATRTrailingStop[i + 1] ? fmax(xATRTrailingStop[i + 1], cl - nLoss) : 
		   									  cl < xATRTrailingStop[i + 1] && cl1 < xATRTrailingStop[i + 1] ? fmin(xATRTrailingStop[i + 1], cl + nLoss) : 
													cl > xATRTrailingStop[i + 1] ? cl - nLoss : cl + nLoss;
    
		
		
		bool crossUp = cl > xATRTrailingStop[i] && cl1 < xATRTrailingStop[i+1];
		bool crossDn = cl < xATRTrailingStop[i] && cl1 > xATRTrailingStop[i+1];

		if (cl > xATRTrailingStop[i] && crossUp==true)
    {
      ArrowUp[i] = low[i] - xATR/2;

      if (newCandle.IsNewCandle()) { Notifications(0); }
    }

    if (cl < xATRTrailingStop[i] && crossDn == true)
    {
      ArrowDn[i] = high[i] + xATR/2;

      if (newCandle.IsNewCandle()) { Notifications(1); }
    }
  }

  return (rates_total);
}

// ------------------------------------------------------------------
void setCandles(int i, int shift)
{
  candle1.setCandle(i + shift);
  candle2.setCandle(i);
}

// clang-format off
bool haveSignalUp(int i) 
{
  // TODO: signal up
	
	// double cl =  iClose(NULL,0,i);
	
	// if(cl > xATRTrailingStop[i] )
  // {
  //   return true;
  // }

  return false;
}

bool haveSignalDown(int i)
{
  // TODO: signal down
  
	// double cl =  iClose(NULL,0,i);

	// if(cl  < xATRTrailingStop[i] )
  // {
  //   return true;
  // }

  return false;
}

void Notifications(int type)
{
  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

  text += " ";

  if (!notifications)
    return;
  if (desktop_notifications)
    Alert(text);
  if (push_notifications)
    SendNotification(text);
  if (email_notifications)
    SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
  switch (lPeriod)
  {
    case PERIOD_M1:
      return ("M1");
    case PERIOD_M5:
      return ("M5");
    case PERIOD_M15:
      return ("M15");
    case PERIOD_M30:
      return ("M30");
    case PERIOD_H1:
      return ("H1");
    case PERIOD_H4:
      return ("H4");
    case PERIOD_D1:
      return ("D1");
    case PERIOD_W1:
      return ("W1");
    case PERIOD_MN1:
      return ("MN1");
  }
  return IntegerToString(lPeriod);
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+

//== fxDreema MQL4 to MQL5 Converter ==//

//-- Global Variables
int FXD_SELECTED_TYPE = 0;// Indicates what is selected by OrderSelect, 1 for trade, 2 for pending order, 3 for history trade
ulong FXD_SELECTED_TICKET = 0;// The ticket number selected by OrderSelect
int FXD_INDICATOR_COUNTED_MEMORY = 0;// Used as a memory for IndicatorCounted() function. It needs to be outside of the function, because when OnCalculate needs to be reset, this memory must be reset as well.

// Set the missing predefined variables, which are controlled by RefreshRates
int Bars     = Bars(_Symbol, PERIOD_CURRENT);
int Digits   = _Digits;
double Point = _Point;
double Ask, Bid, Close[], High[], Low[], Open[];
long Volume[];
datetime Time[];

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
	// In MQL4 the following arrays have AS_SERIES by default
	// Not only that, but they are unset from AS_SERIES on each OnCalculate,
	// so they must be set as series every time
	ArraySetAsSeries(time, true);
	ArraySetAsSeries(open, true);
	ArraySetAsSeries(high, true);
	ArraySetAsSeries(low, true);
	ArraySetAsSeries(close, true);
	ArraySetAsSeries(tick_volume, true);
	ArraySetAsSeries(volume, true);
	ArraySetAsSeries(spread, true);

	DFAF::RefreshRates();

	DFAF::_IndicatorProblem_(false);
	int output = __OnCalculate__(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);

	// Some custom indicators have 0 as a return value. In MQL4 this works, but not in MQL5
	if (output == 0) output = rates_total;

	if (DFAF::_IndicatorProblem_() == true)
	{
		// Returning 0 means that the next time prev_calculated will be 0,
		// which is the state for OnCalculate when all the calculations needs to be made.
		output = 0;
	}

	return output;
}



class DFAF
{
private:
	/**
	* _LastError is used to set custom errors that could be returned by the custom GetLastError method
	* The initial value should be -1 and everything >= 0 should be valid error code
	* When setting an error code in it, it should be the MQL5 value,
	* because then in GetLastError it will be converted to MQL4 value
	*/
	static int _LastError;
public:
	DFAF() {
		
	};
	
	static double MarketInfo(string symbol, int type) {
		// For most cases below this is not needed, but OrderCalcMargin() returns error 5040 (Damaged parameter of string type) if the symbol is NULL
		if (symbol == NULL) symbol = ::Symbol();
	
		switch(type) {
			case 1 /* MODE_LOW                */ : return ::SymbolInfoDouble(symbol, SYMBOL_LASTLOW);
			case 2 /* MODE_HIGH               */ : return ::SymbolInfoDouble(symbol, SYMBOL_LASTHIGH);
			case 5 /* MODE_TIME               */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_TIME);
			case 9 /* MODE_BID                */ : return ::SymbolInfoDouble(symbol, SYMBOL_BID);
			case 10 /* MODE_ASK               */ : return ::SymbolInfoDouble(symbol, SYMBOL_ASK);
			case 11 /* MODE_POINT             */ : return ::SymbolInfoDouble(symbol, SYMBOL_POINT);
			case 12 /* MODE_DIGITS            */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_DIGITS);
			case 13 /* MODE_SPREAD            */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_SPREAD);
			case 14 /* MODE_STOPLEVEL         */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
			case 15 /* MODE_LOTSIZE           */ : return ::SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
			case 16 /* MODE_TICKVALUE         */ : return ::SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
			case 17 /* MODE_TICKSIZE          */ : return ::SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
			case 18 /* MODE_SWAPLONG          */ : return ::SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG);
			case 19 /* MODE_SWAPSHORT         */ : return ::SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT);
			case 20 /* MODE_STARTING          */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_START_TIME);
			case 21 /* MODE_EXPIRATION        */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_EXPIRATION_TIME);
			case 22 /* MODE_TRADEALLOWED      */ : return (::SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED);
			case 23 /* MODE_MINLOT            */ : return ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
			case 24 /* MODE_LOTSTEP           */ : return ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
			case 25 /* MODE_MAXLOT            */ : return ::SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
			case 26 /* MODE_SWAPTYPE          */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_SWAP_MODE);
			case 27 /* MODE_PROFITCALCMODE    */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE);
			case 28 /* MODE_MARGINCALCMODE    */ : return (double)::SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE);
			case 29 /* MODE_MARGININIT        */ : return (double)::SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL);
			case 30 /* MODE_MARGINMAINTENANCE */ : return (double)::SymbolInfoDouble(symbol, SYMBOL_MARGIN_MAINTENANCE);
			case 31 /* MODE_MARGINHEDGED      */ : return (double)::SymbolInfoDouble(symbol, SYMBOL_MARGIN_HEDGED);
			case 32 /* MODE_MARGINREQUIRED    */ :	{
				// Free margin required to open 1 lot for buying
			   double margin = 0.0;
	
				if (::OrderCalcMargin(ORDER_TYPE_BUY, symbol, 1, ::SymbolInfoDouble(symbol, SYMBOL_ASK), margin))
					return margin;
				else
					return 0.0;
			}
			case 33 /* MODE_FREEZELEVEL */     : return (double)::SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);
			case 34 /* MODE_CLOSEBY_ALLOWED */ : return 0.0;
		}
	
		return 0.0;
	}
	
	/**
	* Refresh the data in the predefined variables and series arrays
	* In MQL5 this function should run on every tick or calculate
	*
	* Note that when Symbol or Timeframe is changed,
	* the global arrays (Ask, Bid...) are reset to size 0,
	* and also the static variables are reset to initial values.
	*/
	static bool RefreshRates() {
		static bool initialized = false;
		static double prevAsk   = 0.0;
		static double prevBid   = 0.0;
		static int prevBars     = 0;
		static MqlRates ratesArray[1];
	
		bool isDataUpdated = false;
	
		if (initialized == false) {
			::ArraySetAsSeries(::Close, true);
			::ArraySetAsSeries(::High, true);
			::ArraySetAsSeries(::Low, true);
			::ArraySetAsSeries(::Open, true);
			::ArraySetAsSeries(::Volume, true);
	
			initialized = true;
		}
	
		// For Bars below, if the symbol parameter is provided through a string variable, the function returns 0 immediately when the terminal is started
		::Bars = ::Bars(::_Symbol, PERIOD_CURRENT);
		::Ask  = ::SymbolInfoDouble(::_Symbol, SYMBOL_ASK);
		::Bid  = ::SymbolInfoDouble(::_Symbol, SYMBOL_BID);
	
		if ((::Bars > 0) && (::Bars > prevBars)) {
			// Tried to resize these arrays below on every successful single result, but turns out that this is veeeery slow
			::ArrayResize(::Time, ::Bars);
			::ArrayResize(::Open, ::Bars);
			::ArrayResize(::High, ::Bars);
			::ArrayResize(::Low, ::Bars);
			::ArrayResize(::Close, ::Bars);
			::ArrayResize(::Volume, ::Bars);
	
			// Fill the missing data
			for (int i = prevBars; i < ::Bars; i++) {
				int success = ::CopyRates(::_Symbol, PERIOD_CURRENT, i, 1, ratesArray);
	
				if (success == 1) {
					::Time[i]   = ratesArray[0].time;
					::Open[i]   = ratesArray[0].open;
					::High[i]   = ratesArray[0].high;
					::Low[i]    = ratesArray[0].low;
					::Close[i]  = ratesArray[0].close;
					::Volume[i] = ratesArray[0].tick_volume;
				}
			}
		}
		else {
			// Update the current bar only
			int success = ::CopyRates(::_Symbol, PERIOD_CURRENT, 0, 1, ratesArray);
	
			if (success == 1) {
				::Time[0]   = ratesArray[0].time;
				::Open[0]   = ratesArray[0].open;
				::High[0]   = ratesArray[0].high;
				::Low[0]    = ratesArray[0].low;
				::Close[0]  = ratesArray[0].close;
				::Volume[0] = ratesArray[0].tick_volume;
			}
		}
	
		if (::Bars != prevBars || ::Ask != prevAsk || ::Bid != prevBid) {
			isDataUpdated = true;
		}
	
		prevBars = ::Bars;
		prevAsk  = ::Ask;
		prevBid  = ::Bid;
	
		return isDataUpdated;
	}
	
	static void SetIndexArrow(int index, int code) {
		::PlotIndexSetInteger(index, PLOT_ARROW, code);
	}
	
	/**
	* In MQL4 SetIndexBuffer makes the array as series and also fills it with as many elements as many bars they are, each element equals to EMPTY_VALUE.
	*
	* In MQL5 SetIndexBuffer does not make the array as series and that's why these overloads here exists.
	* The array is not resized and even if ArrayResize is applied, it appears as if its size is still 0. But magically the array appears resized in OnCalculate
	* 
	* EDIT: Later I discovered that the size doesn't change magically, at least not for all buffers, and resizing them in this function works.
	*/
	static bool SetIndexBuffer(int index, double &buffer[], ENUM_INDEXBUFFER_TYPE data_type) {
		bool success = ::SetIndexBuffer(index, buffer, data_type);
	
		if (success) {
			::ArraySetAsSeries(buffer, true);
		}
		
		ArrayResize(buffer, Bars(Symbol(), PERIOD_CURRENT));
	
		return success;
	}
	static bool SetIndexBuffer(int index, double &buffer[]) {
		return DFAF::SetIndexBuffer(index, buffer, INDICATOR_DATA);
	}
	
	static void SetIndexStyle(int index, int type, int style = -1, int width = -1, color clr = clrNONE) {
		if (width > -1) ::PlotIndexSetInteger(index, PLOT_LINE_WIDTH, width);
	
		if (clr != clrNONE) ::PlotIndexSetInteger(index, PLOT_LINE_COLOR, clr);
	
		switch (type) {
			case 0: ::PlotIndexSetInteger(index, PLOT_DRAW_TYPE, DRAW_LINE); break;
			case 1: ::PlotIndexSetInteger(index, PLOT_DRAW_TYPE, DRAW_SECTION); break;
			case 2: ::PlotIndexSetInteger(index, PLOT_DRAW_TYPE, DRAW_HISTOGRAM); break;
			case 3: ::PlotIndexSetInteger(index, PLOT_DRAW_TYPE, DRAW_ARROW); break;
			case 4: ::PlotIndexSetInteger(index, PLOT_DRAW_TYPE, DRAW_ZIGZAG); break;
			case 12: ::PlotIndexSetInteger(index, PLOT_DRAW_TYPE, DRAW_NONE); break;
	
			default: ::PlotIndexSetInteger(index, PLOT_DRAW_TYPE, DRAW_LINE);
		}
	
		switch (style) {
			case 0: ::PlotIndexSetInteger(index, PLOT_LINE_STYLE, STYLE_SOLID); break;
			case 1: ::PlotIndexSetInteger(index, PLOT_LINE_STYLE, STYLE_DASH); break;
			case 2: ::PlotIndexSetInteger(index, PLOT_LINE_STYLE, STYLE_DOT); break;
			case 3: ::PlotIndexSetInteger(index, PLOT_LINE_STYLE, STYLE_DASHDOT); break;
			case 4: ::PlotIndexSetInteger(index, PLOT_LINE_STYLE, STYLE_DASHDOTDOT); break;
	
			default: ::PlotIndexSetInteger(index, PLOT_LINE_STYLE, STYLE_SOLID);
		}
	}
	
	/**
	* In MQL4 the values are the number of minutes in the period
	* In MQL5 the values are the minutes up to M30, then it's the number of seconds in the period
	* This function converts all values that exist in MQL4, but not in MQL5
	* There are no conflict values otherwise
	*/
	static ENUM_TIMEFRAMES _ConvertTimeframe_(int timeframe) {
		switch (timeframe) {
			case 60    : return PERIOD_H1;
			case 120   : return PERIOD_H2;
			case 180   : return PERIOD_H3;
			case 240   : return PERIOD_H4;
			case 360   : return PERIOD_H6;
			case 480   : return PERIOD_H8;
			case 720   : return PERIOD_H12;
			case 1440  : return PERIOD_D1;
			case 10080 : return PERIOD_W1;
			case 43200 : return PERIOD_MN1;
		}
	
		return (ENUM_TIMEFRAMES)timeframe;
	}
	static ENUM_TIMEFRAMES _ConvertTimeframe_(ENUM_TIMEFRAMES timeframe) {
		return timeframe;
	}
	
	static double _GetIndicatorValue_(int handle, int mode = 0, int shift = 0, bool isCustom = false) {
		static double buffer[1];
	
		double valueOnError = (isCustom) ? EMPTY_VALUE : 0.0;
	
		::ResetLastError(); 
	
		if (handle < 0) {
			::Print("Error: Indicator not loaded (handle=", handle, " | error code=", ::_LastError, ")");
	
			return valueOnError;
		}
		
		int barsCalculated = 0;
	
		for (int i = 0; i < 100; i++) {
			barsCalculated = ::BarsCalculated(handle);
	
			if (barsCalculated > 0) break;
	
			::Sleep(50); // doesn't work when in custom indicators
		}
	
		int copied = ::CopyBuffer(handle, mode, shift, 1, buffer);
	
		// Some indicators like MA could be working fine for most candles, but not for the few oldest candles where MA cannot be calculated.
		// In this case the amount of copied idems is 0. That's why don't rely on that value and use BarsCalculated instead.
		if (barsCalculated > 0) {
			double value = (copied > 0) ? buffer[0] : EMPTY_VALUE;
			
			// In MQL4 all built-in indicators return 0.0 when they have nothing to return, for example when asked for value from non existent bar.
			// In MQL5 they return EMPTY_VALUE in this case. That's why here this fix is needed.
			if (value == EMPTY_VALUE && isCustom == false) value = 0.0;
			
			return value;
		}
	
		DFAF::_IndicatorProblem_(true);
	
		return valueOnError;
	}
	
	/**
	* _IndicatorProblem_() to get the state
	* _IndicatorProblem_(true) or _IndicatorProblem_(false) to set the state
	*/
	static bool _IndicatorProblem_(int setState = -1) {
		static bool memory = false;
	
		if (setState > -1) memory = setState;
	
		if (memory == 1) FXD_INDICATOR_COUNTED_MEMORY = 0; // Resets the IndicatorCount() function
	
		return memory;
	}
	
	static double iATR( 
		string symbol,
		int timeframe,
		int ma_period,
		int shift
	) {
		return DFAF::_GetIndicatorValue_(
			::iATR(
				symbol,
				DFAF::_ConvertTimeframe_(timeframe),
				ma_period),
			0,
			shift
		);
	}
	
	/**
	* Overload for the case when numeric value is used for timeframe
	*/
	static long iBars(const string symbol, int timeframe) {
		return ::iBars(symbol, DFAF::_ConvertTimeframe_(timeframe));
	}
	
	/**
	* Overload for the case when numeric value is used for timeframe
	*/
	static double iClose(const string symbol, int timeframe, int shift) {
		return ::iClose(symbol, DFAF::_ConvertTimeframe_(timeframe), shift);
	}
	
	/**
	* Overload for the case when numeric value is used for timeframe
	*/
	static double iHigh(const string symbol, int timeframe, int shift) {
		return ::iHigh(symbol, DFAF::_ConvertTimeframe_(timeframe), shift);
	}
	
	/**
	* Overload for the case when numeric value is used for timeframe
	*/
	static double iLow(const string symbol, int timeframe, int shift) {
		return ::iLow(symbol, DFAF::_ConvertTimeframe_(timeframe), shift);
	}
	
	/**
	* Overload for the case when numeric value is used for timeframe
	*/
	static double iOpen(const string symbol, int timeframe, int shift) {
		return ::iOpen(symbol, DFAF::_ConvertTimeframe_(timeframe), shift);
	}
};
int DFAF::_LastError = -1;
bool ___RefreshRates___ = DFAF::RefreshRates();

//== fxDreema MQL4 to MQL5 Converter ==//
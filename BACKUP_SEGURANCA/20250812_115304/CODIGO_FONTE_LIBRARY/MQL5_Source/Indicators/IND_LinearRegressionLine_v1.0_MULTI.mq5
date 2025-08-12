#define MODE_DIGITS 12
//+------------------------------------------------------------------+
//|                                       Linear Regression Line.mq4 |
//|                                                      MQL Service |
//|                                           scripts@mqlservice.com |
//+------------------------------------------------------------------+
#property copyright "MQL Service"
#property link      "www.mqlservice.com"

#property indicator_chart_window#property indicator_buffers 1
#property indicator_plots 1
#property indicator_color1 Orange
#property indicator_width1 2
//---- input parameters
input int __LRLPeriod__=14;//LRLPeriod
int LRLPeriod = __LRLPeriod__;
//---- buffers
double LRLBuffer[];

int shift=0;
int n=0;
double sumx=0, sumy=0, sumxy=0, sumx2=0, sumy2=0;
double m=0, yint=0, r=0;
//+------------------------------------------------------------------+
//|                    INITIALIZATION FUNCTION                       |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicators
   EAEB::SetIndexStyle(0,DRAW_LINE);
   EAEB::SetIndexBuffer(0,LRLBuffer);
   EAEB::IndicatorDigits(Digits);
   if(LRLPeriod < 2) LRLPeriod = 2;
   EAEB::IndicatorShortName("Linear Regression Line ("+LRLPeriod+")");
   EAEB::SetIndexDrawBegin(0,LRLPeriod+2);
   EAEB::IndicatorDigits(EAEB::MarketInfo(Symbol(),MODE_DIGITS)+4);
//----
   return;
  }
//+------------------------------------------------------------------+
//|                   DEINITIALIZATION FUNCTION                      |
//+------------------------------------------------------------------+
void OnDeinit()
  {
   return;
  }
//+------------------------------------------------------------------+
//|                      ITERATION FUNCTION                          |
//+------------------------------------------------------------------+
int __OnCalculate__(
	const int       rates_total,
	const int       prev_calculated,
	const datetime& time[],
	const double&   open[],
	const double&   high[],
	const double&   low[],
	const double&   close[],
	const long&     tick_volume[],
	const long&     volume[],
	const int&      spread[]
)
  {
   int limit;
   int counted_bars=EAEB::IndicatorCounted();
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int shift=limit-1; shift>=0; shift--)
      {
         sumx = 0;
         sumy = 0;
         sumxy = 0;
         sumx2 = 0;
         sumy2 = 0;
         for(n = 0; n <= LRLPeriod-1; n++)
             { 
               sumx = sumx + n;
               sumy = sumy + Close[shift + n];
               sumxy = sumxy + n * Close[shift + n];
               sumx2 = sumx2 + n * n;
               sumy2 = sumy2 + Close[shift + n] * Close[shift + n]; 
             }                      
         m=(LRLPeriod*sumxy-sumx*sumy)/(LRLPeriod*sumx2-sumx*sumx); 
         yint=(sumy+m*sumx)/LRLPeriod;
         r=(LRLPeriod*sumxy-sumx*sumy)/MathSqrt((LRLPeriod*sumx2-sumx*sumx)*(LRLPeriod*sumy2-sumy*sumy)); 
         LRLBuffer[shift]=yint-m*LRLPeriod;
         //Print (" "+shift+" "+LRLBuffer[shift]);
      }
   return(0);
  }
//+------------------------------------------------------------------+

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

	EAEB::RefreshRates();

	EAEB::_IndicatorProblem_(false);
	int output = __OnCalculate__(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);

	// Some custom indicators have 0 as a return value. In MQL4 this works, but not in MQL5
	if (output == 0) output = rates_total;

	if (EAEB::_IndicatorProblem_() == true)
	{
		// Returning 0 means that the next time prev_calculated will be 0,
		// which is the state for OnCalculate when all the calculations needs to be made.
		output = 0;
	}

	return output;
}



class EAEB
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
	EAEB() {
		
	};
	
	static int IndicatorCounted() {
		/*
		"he number of bars could be growing when they are dinamically printed.
		"he reaction of IndicatorCounted() in MQL4 is like this:
			bars = 100, output = 0
			bars = 110, output = 0
			bars = 120, output = 0
			bars = 120, output = 119
			bars = 120, output = 119
			bars = 121, output = 119
			bars = 121, output = 120
			bars = 121, output = 120
		*/
	
		// static int counted = 0; // I used this static variable before deciding to use FXD_INDICATOR_COUNTED_MEMORY
	
		int output = 0;
		int bars   = ::Bars(::Symbol(), PERIOD_CURRENT);
		int diff   = bars - FXD_INDICATOR_COUNTED_MEMORY;
	
		if (diff == 1 || diff == 2) {
			output = FXD_INDICATOR_COUNTED_MEMORY;
		}
	
		FXD_INDICATOR_COUNTED_MEMORY = bars - 1;
	
		return output;
	}
	
	static void IndicatorDigits(int digits) {
		::IndicatorSetInteger(INDICATOR_DIGITS, digits);
	}
	
	static void IndicatorShortName(string name) {
		::IndicatorSetString(INDICATOR_SHORTNAME, name);
	}
	
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
		return EAEB::SetIndexBuffer(index, buffer, INDICATOR_DATA);
	}
	
	static void SetIndexDrawBegin(int index, int begin) {
		::PlotIndexSetInteger(index, PLOT_DRAW_BEGIN, begin);
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
	* _IndicatorProblem_() to get the state
	* _IndicatorProblem_(true) or _IndicatorProblem_(false) to set the state
	*/
	static bool _IndicatorProblem_(int setState = -1) {
		static bool memory = false;
	
		if (setState > -1) memory = setState;
	
		if (memory == 1) FXD_INDICATOR_COUNTED_MEMORY = 0; // Resets the IndicatorCount() function
	
		return memory;
	}
};
int EAEB::_LastError = -1;
bool ___RefreshRates___ = EAEB::RefreshRates();

//== fxDreema MQL4 to MQL5 Converter ==//
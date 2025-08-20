#property copyright "saf"
#property link      ""

/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |                       INPUT PARAMETERS, GLOBAL VARIABLES, CONSTANTS, IMPORTS and INCLUDES                        | //
// |                      System and Custom variables and other definitions used in the project                       | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// System constants (project settings) //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
#define PROJECT_ID           "mt4-1526"
#define VIRTUAL_STOPS_ENABLED    false // true or false
#define VIRTUAL_STOPS_TIMEOUT 0//--
#define USE_EMERGENCY_STOPS  "no"   // "yes" to use emergency (hard stops) when virtual stops are in use. "always" to use EMERGENCY_STOPS_ADD as emergency stops when there is no virtual stop.
#define EMERGENCY_STOPS_REL  0       // Use 0 to disable hard stops when virtual stops are enabled. Use a value >=0 to automatically set hard stops with virtual. Example: if 2 is used, then hard stops will be 2 times bigger than virtual ones.
#define EMERGENCY_STOPS_ADD  0       // Add pips to relative size of emergency stops (hard stops)
//--
#define ON_TRADE_REALTIME    0 //
#define ON_TIMER_PERIOD   60        // Timer event period (in seconds)
//--
#define ENABLE_EVENT_TICK  1 // "Tick"  event: 1 - enable, 0 - disable
#define ENABLE_EVENT_TRADE 0 // "Trade" event: 1 - enable, 0 - disable
#define ENABLE_EVENT_TIMER 0 // "Timer" event: 1 - enable, 0 - disable
///////

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// System constants (predefined constants) //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
#define TLOBJPROP_TIME1 801
#define OBJPROP_TL_PRICE_BY_SHIFT 802
#define OBJPROP_TL_SHIFT_BY_PRICE 803
#define OBJPROP_FIBOVALUE 804
#define OBJPROP_FIBOPRICEVALUE 805
#define OBJPROP_BARSHIFT1 807
#define OBJPROP_BARSHIFT2 808
#define OBJPROP_BARSHIFT3 809
#define SEL_CURRENT 0
#define SEL_INITIAL 1

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// Project global variables, includes, imports //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
//       EA Constants
extern string _____EngulfingFilters_____ = "------------------------"; // ____Engulfing Filters_____
extern bool _UseMATrendFilter = false; // Use MA Trend Filter
extern int _MA1Period = 200; // MA1 Period
extern int _MA2Period = 50; // MA2 Period
extern bool _UsePrevCandlesBearishBullishFilter = true; // Use Prev Candles Bearish/Bullish Filter
extern string _____OrderSettings_____ = "------------------------"; // ____Order Settings_____
extern double _FixedLotSizePips = 0.01; // Fixed Lot Size Pips
extern double _PendingOrderOffsetPips = 0.2; // Pending Order Offset Pips
extern double _AddPipsToSL = 0.2; // Add Pips To SL
extern double _TPFactorBasedOnCandle1Length = 1.0; // TP Factor Based On Candle1 Length
extern int _PendingOrderExpirationMinutes = 0; // Pending Order Expiration Minutes
extern int _PendingOrderExpirationHours = 0; // Pending Order Expiration Hours
extern int _PendingOrderExpirationDays = 0; // Pending Order Expiration Days
extern string _____SpreadHandling_____ = "------------------------"; // ____Spread Handling_____
extern bool _TakeSpreadsIntoAccountTheCorrectWay = true; // Take Spreads Into Account The Correct Way
extern bool _TakeSpreadsIntoAccountTheMax_PipsWay = false; // Take Spreads Into Account The Max_Pips Way
extern string _____Notifications_____ = "------------------------"; // ____Notifications_____
extern bool _SendNotificationInsteadOfTrade = false; // Send Notification Instead Of Trade
extern bool __SendMT4Alerts = false; // _Send MT4 Alerts
extern bool __SendEmailAlerts = false; // _Send Email Alerts
extern bool __SendPushAlerts = false; // _Send Push Alerts
extern string _____ForTradingActivityAlertsCheckTheBoxInMT4Options______ = "------------------------"; // ____For Trading Activity Alerts, Check The Box In MT4 Options______
// Formula Results
double Result11;
double Result12;
double Result13;
double Result14;
double Result15;
double Result16;
double Result17;
double Result18;
double Result19;
double Result26;
double Result27;
double Result28;
double Result29;
double Result58;
double Result59;
double Result60;
double Result61;
extern int MagicStart=1526; // Magic Start (MagicNumber=MagicStart+Group#)

//VVVVVVVVVVVVVVVVVVVVVVVVV//
// System global variables //
//^^^^^^^^^^^^^^^^^^^^^^^^^//
int FXD_CURRENT_FUNCTION_ID=0;
double FXD_MILS_INIT_END=0;
bool FXD_FIRST_TICK_PASSED=false;
bool FXD_BREAK=false;
bool FXD_CONTINUE=false;
bool FXD_CHART_IS_OFFLINE = false;
bool FXD_ONTIMER_TAKEN = false;
bool FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
double FXD_ONTIMER_TAKEN_TIME = 0;
bool USE_VIRTUAL_STOPS = VIRTUAL_STOPS_ENABLED;

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// Global variables used as On-Off property for       EA blocks //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
bool block1=true; // Pass
bool block2=true; // Condition&nbsp;
bool block3=true; // Condition&nbsp;
bool block4=true; // Condition&nbsp;
bool block5=true; // Condition&nbsp;
bool block6=true; // Condition&nbsp;
bool block7=true; // Condition&nbsp;
bool block8=true; // Condition&nbsp;
bool block9=false; // Buy pending order&nbsp;
bool block10=false; // Sell pending order
bool block11=true; // Formula
bool block12=true; // Formula
bool block13=true; // Formula&nbsp;
bool block14=true; // Formula
bool block15=true; // Formula
bool block16=true; // Formula&nbsp;
bool block17=true; // Formula
bool block18=true; // Formula
bool block19=true; // Formula
bool block21=false; // Pass
bool block22=false; // Pass
bool block23=false; // Pass
bool block24=false; // Buy pending order
bool block25=false; // Sell pending order
bool block26=true; // Formula
bool block27=false; // Formula
bool block28=true; // Formula
bool block29=false; // Formula
bool block30=true; // Pass
bool block31=true; // Once a day
bool block32=true; // Pass
bool block33=true; // spreads correct
bool block34=true; // Turn ON blocks
bool block35=true; // spreads max
bool block36=true; // Turn ON blocks
bool block37=true; // Turn OFF blocks
bool block38=true; // bullbear
bool block39=true; // Turn ON blocks
bool block40=true; // Turn OFF blocks
bool block41=false; // Condition&nbsp;
bool block42=true; // Pass
bool block43=true; // Pass
bool block44=true; // ma
bool block45=true; // Turn ON blocks
bool block46=true; // Turn OFF blocks
bool block47=true; // Condition&nbsp;
bool block48=true; // Condition&nbsp;
bool block49=false; // Condition&nbsp;
bool block55=true; // Condition&nbsp;
bool block57=true; // Pass
bool block58=true; // Formula
bool block59=true; // Formula
bool block60=true; // Formula
bool block61=true; // Formula
bool block62=true; // Once per bar
bool block63=true; // Once per bar
bool block64=true; // Once per bar
bool block65=true; // Once per bar
bool block66=true; // Once per bar
bool block1666538=false; // Custom Alert MQL4 code
bool block1666570=false; // Custom Alert MQL4 code
bool block1666571=false; // Custom Alert MQL4 code
bool block1666573=false; // Custom Alert MQL4 code
bool block1666605=false; // Custom Alert MQL4 code
bool block1666606=false; // Custom Alert MQL4 code
bool block1666607=true; // Pass
bool block1666608=true; // Pass
bool block1666609=true; // Pass
bool block1666610=true; // Pass
bool block1666611=true; // Pass
bool block1666612=true; // Pass
bool block1666613=true; // mt4 alert
bool block1666614=true; // Turn ON blocks
bool block1666615=true; // email alert
bool block1666616=true; // Turn ON blocks
bool block1666617=true; // push alert
bool block1666618=true; // Turn ON blocks
bool block1666619=true; // alert only
bool block1666621=true; // Turn OFF blocks

/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |                                                 EVENT FUNCTIONS                                                  | //
// |                           These are the main functions that controls the whole project                           | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed once when the program starts //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
int OnInit()
{
	Comment("");
	for (int i=ObjectsTotal(ChartID()); i>=0; i--)
	{
	   string name = ObjectName(ChartID(), i);
	   if (StringSubstr(name,0,8) == "fxd_cmnt") {ObjectDelete(ChartID(), name);}
	}
	ChartRedraw();

	if (IsOptimization()) {
		// According to http://docs.mql4.com/runtime/testing: During optimization, working with graphical objects is not supported.
		USE_VIRTUAL_STOPS = false;
	}
	TimeAtStart("set"); // Set local and server time at start
	AccountBalanceAtStart(); // Set balance at start
	DrawSpreadInfo();
	DrawStatus("waiting for tick...");

	if (MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_EXPERT)
	{
		FXD_CHART_IS_OFFLINE = ChartGetInteger(0, CHART_IS_OFFLINE);
	}

	if (MQLInfoInteger(MQL_PROGRAM_TYPE) != PROGRAM_SCRIPT)
	{
		if (FXD_CHART_IS_OFFLINE == true || (ENABLE_EVENT_TRADE == 1 && ON_TRADE_REALTIME == 1))
		{
			FXD_ONTIMER_TAKEN = true;
			EventSetMillisecondTimer(1);
		}
		if (ENABLE_EVENT_TIMER) {
			OnTimerSet(ON_TIMER_PERIOD);
		}
	}

	FXD_MILS_INIT_END = GetTickCount();
	FXD_FIRST_TICK_PASSED = false; // reset is needed when changing inputs

	return(INIT_SUCCEEDED);
}

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed on every incoming tick //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
// This is the native MQL4 on-tick function
void OnTick()
{
	if (FXD_FIRST_TICK_PASSED==false)
	{
		FXD_FIRST_TICK_PASSED=true;
		DrawStatus("working");
	}

	//-- special system actions
	DrawSpreadInfo();
	TicksData(""); // Collect ticks (if needed)
	TicksPerSecond(false, true); // Collect ticks per second
	if (USE_VIRTUAL_STOPS) {VirtualStopsDriver();}
	ExpirationDriver();
	OCODriver(); // Check and close OCO orders
	if (ENABLE_EVENT_TRADE) {OnTradeListener();}

	// Blocks on top level
	block1();
	block57();



	TicksFromStart(true);
	return;
}

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed on trade events - open, close, modify //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
void EventTrade()
{

	OnTradeQueue(-1);
}

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed on a period basis //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
void OnTimer()
{
	//-- to simulate ticks in offline charts, Timer is used instead of infinite loop
	//-- the next function checks for changes in price and calls OnTick() manually
	if (FXD_CHART_IS_OFFLINE && RefreshRates()) {
		OnTick();
	}
	if (ON_TRADE_REALTIME == 1) {
		OnTradeListener();
	}

	static int t0 = 0;
	int t = 0;
	bool ok = false;

	if (FXD_ONTIMER_TAKEN)
	{
		if (FXD_ONTIMER_TAKEN_TIME > 0)
		{
			if (FXD_ONTIMER_TAKEN_IN_MILLISECONDS == true)
			{
				t = GetTickCount();
			}
			else
			{
				t = TimeLocal();
			}
			if ((t - t0) >= FXD_ONTIMER_TAKEN_TIME)
			{
				t0 = t;
				ok = true;
			}
		}

		if (ok == false) {
			return;
		}
	}


}

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// This function is executed once when the program ends //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
void OnDeinit(const int reason)
{
	//-- if Timer was set, kill it here
	EventKillTimer();

	if (MQLInfoInteger(MQL_TESTER)) {
		Print("Backtested in "+DoubleToStr((GetTickCount()-FXD_MILS_INIT_END)/1000, 2)+" seconds");
		Print("Average ticks per second: "+DoubleToStr(TicksFromStart()/(GetTickCount()-FXD_MILS_INIT_END),0));
	}

	DrawStatus("stopped");
	if (MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_EXPERT)
	{
		switch(UninitializeReason())
		{
			case REASON_PROGRAM		: Print("Expert Advisor self terminated"); break;
			case REASON_REMOVE		: Print("Expert Advisor removed from the chart"); break;
			case REASON_RECOMPILE	: Print("Expert Advisorhas been recompiled"); break;
			case REASON_CHARTCHANGE	: Print("Symbol or chart period has been changed"); break;
    		case REASON_CHARTCLOSE	: Print("Chart has been closed"); break;
    		case REASON_PARAMETERS	: Print("Input parameters have been changed by a user"); break;
    		case REASON_ACCOUNT		: Print("Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings"); break;
			case REASON_TEMPLATE	: Print("A new template has been applied"); break;
			case REASON_INITFAILED	: Print("OnInit() handler has returned a nonzero value"); break;
			case REASON_CLOSE		: Print("Terminal has been closed"); break;
		}
	}
}

/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |                                   FUNCTIONS THAT REPRESENTS BLOCKS IN       EA                                   | //
// |                                    Each block is represented as function here                                    | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

//~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1 (Pass) //
void block1(int _parent_=0)
{
	if (block1==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1;

	block31(1);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #2 (Condition&nbsp;) //
void block2(int _parent_=0)
{
	if (block2==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=2;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_candles("iHigh", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_candles("iHigh", "id", 2, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo>=Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro>=Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block3(2);} else if (o2==true) {/* Yellow output */}
}
double _candles(string iOHLC, string ModeCandleFindBy, int CandleID, string TimeStamp, string SYMBOL, int TIMEFRAME) {
	double retval=0;
	double cOpen=0;
	double cHigh=0;
	double cLow=0;
	double cClose=0;
	
	if (ModeCandleFindBy == "time")
	{
	   CandleID = iCandleID(SYMBOL, TIMEFRAME, StrToTime(TimeStamp));
	}
	
	CandleID=CandleID+IndicatorMoreShift();
	
	if (iOHLC=="iOpen")        {retval=iOpen(SYMBOL, TIMEFRAME, CandleID);}
	else if (iOHLC=="iHigh")   {retval=iHigh(SYMBOL, TIMEFRAME, CandleID);}
	else if (iOHLC=="iLow")    {retval=iLow(SYMBOL, TIMEFRAME, CandleID);}
	else if (iOHLC=="iClose")  {retval=iClose(SYMBOL, TIMEFRAME, CandleID);}
	else if (iOHLC=="iVolume") {retval=iVolume(SYMBOL, TIMEFRAME, CandleID);}
	else if (iOHLC=="iTime")   {retval=iTime(SYMBOL, TIMEFRAME, CandleID);}
	else
	{
	   if (iOHLC=="iMedian") {
	      cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	      cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	retval=((cLow+cHigh)/2);
	   }
	   else if (iOHLC=="iTypical") {
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=((cLow+cHigh+cClose)/3);
	   }
	   else if (iOHLC=="iAverage") {
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=((cLow+cHigh+cClose+cClose)/4);
	   }
	   else if (iOHLC=="iTotal") {
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips(MathAbs(cHigh-cLow),SYMBOL);
	   }
	   else if (iOHLC=="iBody") {
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips(MathAbs(cClose-cOpen),SYMBOL);
	   }
	   else if (iOHLC=="iUpperWick") {
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	retval=0;
	   	if (cClose>cOpen) {
	   	   retval=toPips(MathAbs(cHigh-cClose),SYMBOL);
	   	} else {
	   	   retval=toPips(MathAbs(cHigh-cOpen),SYMBOL);
	   	}
	   }
	   else if (iOHLC=="iBottomWick") {
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	retval=0;
	   	if (cClose>cOpen) {
	   	   retval=toPips(MathAbs(cOpen-cLow),SYMBOL);
	   	} else {
	   	   retval=toPips(MathAbs(cClose-cLow),SYMBOL);
	   	}
	   }
	   else if (iOHLC=="iBullTotal") {
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips((cHigh-cLow),SYMBOL);
	   	if (cClose<cOpen) {return(EMPTY_VALUE);}
	   }
	   else if (iOHLC=="iBullBody") {
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips((cClose-cOpen),SYMBOL);
	   	if (cClose<cOpen) {return(EMPTY_VALUE);}
	   }
	   else if (iOHLC=="iBullUpperWick") {
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips((cHigh-cClose),SYMBOL);
	   	if (cClose<cOpen) {return(EMPTY_VALUE);}
	   }
	   else if (iOHLC=="iBullBottomWick") {
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips((cOpen-cLow),SYMBOL);
	   	if (cClose<cOpen) {return(EMPTY_VALUE);}
	   }
	   else if (iOHLC=="iBearTotal") {
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips((cHigh-cLow),SYMBOL);
	   	if (cOpen<cClose) {return(EMPTY_VALUE);}
	   }
	   else if (iOHLC=="iBearBody") {
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips((cOpen-cClose),SYMBOL);
	   	if (cOpen<cClose) {return(EMPTY_VALUE);}
	   }
	   else if (iOHLC=="iBearUpperWick") {
	   	cHigh=iHigh(SYMBOL,TIMEFRAME,CandleID);
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips((cHigh-cOpen),SYMBOL);
	   	if (cOpen<cClose) {return(EMPTY_VALUE);}
	   }
	   else if (iOHLC=="iBearBottomWick") {
	   	cLow=iLow(SYMBOL,TIMEFRAME,CandleID);
	   	cOpen=iOpen(SYMBOL,TIMEFRAME,CandleID);
	   	cClose=iClose(SYMBOL,TIMEFRAME,CandleID);
	   	retval=toPips((cClose-cLow),SYMBOL);
	   	if (cOpen<cClose) {return(EMPTY_VALUE);}
	   }
	}
	return(retval);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #3 (Condition&nbsp;) //
void block3(int _parent_=0)
{
	if (block3==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=3;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_candles("iLow", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_candles("iLow", "id", 2, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo<=Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro<=Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block11(3);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #4 (Condition&nbsp;) //
void block4(int _parent_=0)
{
	if (block4==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=4;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_candles("iClose", "id", 2, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_candles("iOpen", "id", 2, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo<Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro<Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block5(4);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #5 (Condition&nbsp;) //
void block5(int _parent_=0)
{
	if (block5==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=5;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_candles("iClose", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_candles("iOpen", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo>Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro>Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block2(5);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #6 (Condition&nbsp;) //
void block6(int _parent_=0)
{
	if (block6==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=6;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_candles("iClose", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_candles("iOpen", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo<Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro<Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block7(6);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #7 (Condition&nbsp;) //
void block7(int _parent_=0)
{
	if (block7==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=7;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_candles("iHigh", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_candles("iHigh", "id", 2, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo>=Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro>=Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block8(7);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #8 (Condition&nbsp;) //
void block8(int _parent_=0)
{
	if (block8==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=8;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_candles("iLow", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_candles("iLow", "id", 2, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo<=Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro<=Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block12(8);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #9 (Buy pending order&nbsp;) //
void block9(int _parent_=0)
{
	if (block9==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=9;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersGroup=""; // Group # (empty=Default)
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string Price="dynamic"; // Open at price
	double PriceOffset=0; // Price offset
	string VolumeMode="fixed"; // Money management
	double VolumeSize=_FixedLotSizePips; // Lot size
	double VolumeSizeRisk=50; // Risk fixed amount of money
	double VolumeRisk=2.5; // Risk percent
	double VolumePercent=100; // Volume size
	double VolumeBlockPercent=3; // Block % of Balance
	double FixedRatioUnitSize=0.01; // Fixed Ratio: Unit size
	double FixedRatioDelta=20; // Fixed Ratio: Delta parameter
	string StopLossMode="dynamicLevel"; // Stop-Loss mode
	double StopLossPips=100; // in pips...
	double StopLossPercentTP=100; // % of Take-Profit
	string TakeProfitMode="dynamicLevel"; // Take-Profit mode
	double TakeProfitPips=100; // in pips...
	double TakeProfitPercentSL=100; // % of Stop-Loss
	string ExpMode="specified"; // Expiration mode
	int ExpDays=_PendingOrderExpirationDays; // Days
	int ExpHours=_PendingOrderExpirationHours; // Hours
	int ExpMinutes=_PendingOrderExpirationMinutes; // Minutes
	int CreateOCO=0; // Create OCO order
	double Slippage=4; // Slippage
	string MyComment="Long pending order"; // Comment
	color ArrowColorBuy=Blue; // Arrow color
	
	///////////////
	// Main code //
	///////////////
	
	SetSymbol(SYMBOL);
	
	//-- open price -------------------------------------------------------------
	double op=0;
	     if (Price=="ask") {op=SymbolAsk();}
	else if (Price=="bid") {op=SymbolBid();}
	else if (Price=="mid") {op=(SymbolAsk()+SymbolBid())/2;}
	else if (Price=="dynamic") {op=_fResults(Result11);}
	op=op+toDigits(PriceOffset);
	
	//-- stops ------------------------------------------------------------------
	double sll=0, slp=0, tpl=0, tpp=0;
	
	     if (StopLossMode=="fixed")        {slp=StopLossPips;}
	else if (StopLossMode=="dynamicPips")  {slp=_value(100);}
	else if (StopLossMode=="dynamicDigits"){slp=toPips(_value(0.0100),SYMBOL);}
	else if (StopLossMode=="dynamicLevel") {sll=_fResults(Result29);}
	
	     if (TakeProfitMode=="fixed")         {tpp=TakeProfitPips;}
	else if (TakeProfitMode=="dynamicPips")   {tpp=_fResults(Result26);}
	else if (TakeProfitMode=="dynamicDigits") {tpp=toPips(_value(0.0100),SYMBOL);}
	else if (TakeProfitMode=="dynamicLevel")  {tpl=_fResults(Result61);}
	
	if (StopLossMode == "percentTP") {
	   if (tpp > 0) {slp = tpp*StopLossPercentTP/100;}
	   if (tpl > 0) {slp = toPips(MathAbs(SymbolAsk(SYMBOL) - tpl), SYMBOL)*StopLossPercentTP/100;}
	}
	if (TakeProfitMode == "percentSL") {
	   if (slp > 0) {tpp = slp*TakeProfitPercentSL/100;}
	   if (sll > 0) {tpp = toPips(MathAbs(SymbolAsk(SYMBOL) - sll), SYMBOL)*TakeProfitPercentSL/100;}
	}
	
	//-- lots -------------------------------------------------------------------
	double lots=0;
	double pre_sll=sll; if (pre_sll==0) {pre_sll=op;}
	double pre_sl_pips=toPips(op-(pre_sll-toDigits(slp,SYMBOL)));
	
	     if (VolumeMode=="fixed")             {lots=DynamicLots(VolumeMode, VolumeSize);}
	else if (VolumeMode=="block-equity")      {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="block-balance")     {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="block-freemargin")  {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="equity")            {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="balance")           {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="freemargin")        {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="equityRisk")        {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="balanceRisk")       {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="freemarginRisk")    {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="fixedRisk")         {lots=DynamicLots(VolumeMode, VolumeSizeRisk, pre_sl_pips);}
	else if (VolumeMode=="fixedRatio")        {lots=DynamicLots(VolumeMode, FixedRatioUnitSize, FixedRatioDelta);}
	else if (VolumeMode=="dynamic")           {lots=AlignLots(_value(0.1));}
	
	//-- expiration -------------------------------------------------------------
	datetime exp=ExpirationTime(ExpMode,ExpDays,ExpHours,ExpMinutes,_time(0, 0, "00:00", 1, "", 0, 0, 0, 0, 12, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, true));
	
	//-- send -------------------------------------------------------------------
	int ticket=BuyLater(SYMBOL,lots,op,sll,tpl,slp,tpp,Slippage,exp,(MagicStart+(int)OrdersGroup),MyComment,ArrowColorBuy,CreateOCO);
	
	if (ticket>0) {/* Orange output */} else {/* Gray output */}
}
double _fResults(double fResult) {
	return(fResult);
}
double _value(double Value) {
	return(Value);
}
datetime _time(int ModeTime, int TimeSource, string TimeStamp, int TimeCandleID, string TimeMarket, int TimeCandleTimeframe, int TimeComponentYear, int TimeComponentMonth, int TimeComponentDay, int TimeComponentHour, int TimeComponentMinute, int TimeComponentSecond, int ModeTimeShift, int TimeShiftYears, int TimeShiftMonths, int TimeShiftWeeks, int TimeShiftDays, int TimeShiftHours, int TimeShiftMinutes, int TimeShiftSeconds, bool TimeSkipWeekdays) {
	static datetime retval=0, retval0=0;
	static int ModeTime0=0;
	static int smodeshift=0;
	
	if(ModeTime==0) {
	   if (TimeSource==1) {retval=TimeLocal();} else {retval=TimeCurrent();}
	}
	else if(ModeTime==1) {
	      retval=StringToTime(TimeStamp);
	      retval0=retval;
	}
	else if(ModeTime==2) {
	   retval = TimeFromComponents(TimeSource == 1, TimeComponentYear, TimeComponentMonth, TimeComponentDay, TimeComponentHour, TimeComponentMinute, TimeComponentSecond);
	}
	else if(ModeTime==3) {
	   if (TimeMarket=="") {TimeMarket=Symbol();}
	   retval=iTime(TimeMarket,TimeCandleTimeframe,TimeCandleID);
	}
	
	if (ModeTimeShift>0) {
	   int sh=1;
	   if (ModeTimeShift==1) {sh=-1;}
	   
	   static int years0=0,months0=0;
	   
	   if (
	      ModeTimeShift!=smodeshift
	      || TimeShiftYears!=years0 || TimeShiftMonths!=months0
	   )
	   {
	      years0=TimeShiftYears; months0=TimeShiftMonths;
	      
	      if (TimeShiftYears>0 || TimeShiftMonths>0) {
	         int year=0,month=0,week=0,day=0,hour=0,minute=0,second=0;
	         if (ModeTime==3) {
	            year=TimeComponentYear; month=TimeComponentYear;    day=TimeComponentDay;
	            hour=TimeComponentHour; minute=TimeComponentMinute; second=TimeComponentSecond;
	         }
	         else {
	            year=TimeYear(retval); month=TimeMonth(retval);   day=TimeDay(retval);
	            hour=TimeHour(retval); minute=TimeMinute(retval); second=TimeSeconds(retval);
	         }
	         
	         year  =year+TimeShiftYears*sh;
	         month =month+TimeShiftMonths*sh;
	         if (month<0) {month=12-month;}
	         else if (month>12) {month=month-12;}
	         retval=StrToTime(year+"."+month+"."+day+" "+hour+":"+minute+":"+second);
	      }
	   }
	
	   retval=retval+TimeShiftWeeks*604800*sh+TimeShiftDays*86400*sh+TimeShiftHours*3600*sh+TimeShiftMinutes*60*sh+TimeShiftSeconds*sh;
	      
	   if (TimeSkipWeekdays==true) {
	      int weekday=TimeDayOfWeek(retval);
	      
	      if (sh>0) { // forward
	         if (weekday==0) {retval=retval+86400;}
	         else if (weekday==6) {retval=retval+172800;}
	      }
	      else if (sh<0) { // back
	         if (weekday==0) {retval=retval-172800;}
	         else if (weekday==6) {retval=retval-86400;}
	      }
	   }
	}
	smodeshift=ModeTimeShift;
	ModeTime0=ModeTime;
	
	return(retval);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #10 (Sell pending order) //
void block10(int _parent_=0)
{
	if (block10==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=10;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersGroup=""; // Group # (empty=Default)
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string Price="dynamic"; // Open at price
	double PriceOffset=0; // Price offset
	string VolumeMode="fixed"; // Money management
	double VolumeSize=_FixedLotSizePips; // Lot size
	double VolumeSizeRisk=50; // Risk fixed amount of money
	double VolumeRisk=2.5; // Risk percent
	double VolumePercent=100; // Volume size
	double VolumeBlockPercent=3; // Block % of Balance
	double FixedRatioUnitSize=0.01; // Fixed Ratio: Unit size
	double FixedRatioDelta=20; // Fixed Ratio: Delta parameter
	string StopLossMode="dynamicLevel"; // Stop-Loss mode
	double StopLossPips=100; // in pips...
	double StopLossPercentTP=100; // % of Take-Profit
	string TakeProfitMode="dynamicLevel"; // Take-Profit mode
	double TakeProfitPips=100; // in pips...
	double TakeProfitPercentSL=100; // % of Stop-Loss
	string ExpMode="specified"; // Expiration mode
	int ExpDays=_PendingOrderExpirationDays; // Days
	int ExpHours=_PendingOrderExpirationHours; // Hours
	int ExpMinutes=_PendingOrderExpirationMinutes; // Minutes
	int CreateOCO=0; // Create OCO order
	double Slippage=4; // Slippage
	string MyComment="Short pending order"; // Comment
	color ArrowColorSell=Red; // Arrow color
	
	///////////////
	// Main code //
	///////////////
	
	SetSymbol(SYMBOL);
	
	//-- open price -------------------------------------------------------------
	double op=0;
	     if (Price=="ask") {op=SymbolAsk();}
	else if (Price=="bid") {op=SymbolBid();}
	else if (Price=="mid") {op=(SymbolAsk()+SymbolBid())/2;}
	else if (Price=="dynamic") {op=_fResults(Result12);}
	op=op-toDigits(PriceOffset);
	
	//-- stops ------------------------------------------------------------------
	double sll=0, slp=0, tpl=0, tpp=0;
	
	     if (StopLossMode=="fixed")        {slp=StopLossPips;}
	else if (StopLossMode=="dynamicPips")  {slp=_value(100);}
	else if (StopLossMode=="dynamicDigits"){slp=toPips(_value(0.0100),SYMBOL);}
	else if (StopLossMode=="dynamicLevel") {sll=_fResults(Result16);}
	
	     if (TakeProfitMode=="fixed")         {tpp=TakeProfitPips;}
	else if (TakeProfitMode=="dynamicPips")   {tpp=_fResults(Result27);}
	else if (TakeProfitMode=="dynamicDigits") {tpp=toPips(_value(0.0100),SYMBOL);}
	else if (TakeProfitMode=="dynamicLevel")  {tpl=_fResults(Result59);}
	
	if (StopLossMode == "percentTP") {
	   if (tpp > 0) {slp = tpp*StopLossPercentTP/100;}
	   if (tpl > 0) {slp = toPips(MathAbs(SymbolAsk(SYMBOL) - tpl), SYMBOL)*StopLossPercentTP/100;}
	}
	if (TakeProfitMode == "percentSL") {
	   if (slp > 0) {tpp = slp*TakeProfitPercentSL/100;}
	   if (sll > 0) {tpp = toPips(MathAbs(SymbolAsk(SYMBOL) - sll), SYMBOL)*TakeProfitPercentSL/100;}
	}
	
	//-- lots -------------------------------------------------------------------
	double lots=0;
	double pre_sll=sll; if (pre_sll==0) {pre_sll=op;}
	double pre_sl_pips=toPips((pre_sll+toDigits(slp,SYMBOL))-op);
	
	     if (VolumeMode=="fixed")             {lots=DynamicLots(VolumeMode, VolumeSize);}
	else if (VolumeMode=="block-equity")      {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="block-balance")     {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="block-freemargin")  {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="equity")            {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="balance")           {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="freemargin")        {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="equityRisk")        {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="balanceRisk")       {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="freemarginRisk")    {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="fixedRisk")         {lots=DynamicLots(VolumeMode, VolumeSizeRisk, pre_sl_pips);}
	else if (VolumeMode=="fixedRatio")        {lots=DynamicLots(VolumeMode, FixedRatioUnitSize, FixedRatioDelta);}
	else if (VolumeMode=="dynamic")           {lots=AlignLots(_value(0.1));}
	
	//-- expiration -------------------------------------------------------------
	datetime exp=ExpirationTime(ExpMode,ExpDays,ExpHours,ExpMinutes,_time(0, 0, "00:00", 1, "", 0, 0, 0, 0, 12, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, true));
	
	//-- send -------------------------------------------------------------------
	int ticket=SellLater(SYMBOL,lots,op,sll,tpl,slp,tpp,Slippage,exp,(MagicStart+(int)OrdersGroup),MyComment,ArrowColorSell,CreateOCO);
	
	if (ticket>0) {/* Orange output */} else {/* Gray output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #11 (Formula) //
void block11(int _parent_=0)
{
	if (block11==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=11;

	double Lo=_candles("iHigh", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_points(_PendingOrderOffsetPips, 1, CurrentSymbol());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result11=(Lo + Ro);
	
	block13(11); block21(11);
}
double _points(double Value, int ModeValue, string SYMBOL) {
	double retval=0;
	     if (ModeValue==0) {retval=Value;}
	else if (ModeValue==1) {retval=Value*MarketInfo(SYMBOL,MODE_POINT)*PipValue(SYMBOL);}
	
	return(retval);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #12 (Formula) //
void block12(int _parent_=0)
{
	if (block12==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=12;

	double Lo=_candles("iLow", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_points(_PendingOrderOffsetPips, 1, CurrentSymbol());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result12=(Lo - Ro);
	
	block15(12);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #13 (Formula&nbsp;) //
void block13(int _parent_=0)
{
	if (block13==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=13;

	double Lo=_fResults(Result11);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_Spread(CurrentSymbol());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result13=(Lo + Ro);
	
	block14(13);
}
double _Spread(string SYMBOL) {
	double retval=(MarketInfo(SYMBOL,MODE_ASK)-MarketInfo(SYMBOL,MODE_BID));
	retval=NormalizeDouble(retval,MarketInfo(SYMBOL,MODE_DIGITS));
	return(retval);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #14 (Formula) //
void block14(int _parent_=0)
{
	if (block14==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=14;

	double Lo=_candles("iLow", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_points(_AddPipsToSL, 1, CurrentSymbol());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result14=(Lo - Ro);
	
	block29(14); block32(14);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #15 (Formula) //
void block15(int _parent_=0)
{
	if (block15==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=15;

	double Lo=_candles("iHigh", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_points(_AddPipsToSL, 1, CurrentSymbol());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result15=(Lo + Ro);
	
	block16(15);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #16 (Formula&nbsp;) //
void block16(int _parent_=0)
{
	if (block16==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=16;

	double Lo=_fResults(Result15);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_Spread(CurrentSymbol());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result16=(Lo + Ro);
	
	block18(16);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #17 (Formula) //
void block17(int _parent_=0)
{
	if (block17==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=17;

	double Lo=_candles("iHigh", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_candles("iLow", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result17=(Lo - Ro);
	
	block26(17);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #18 (Formula) //
void block18(int _parent_=0)
{
	if (block18==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=18;

	double Lo=_candles("iHigh", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_candles("iLow", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result18=(Lo - Ro);
	
	block22(18); block28(18);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #19 (Formula) //
void block19(int _parent_=0)
{
	if (block19==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=19;

	double Lo=_fResults(Result28);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_Spread(CurrentSymbol());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result19=(Lo + Ro);
	
	block60(19);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #21 (Pass) //
void block21(int _parent_=0)
{
	if (block21==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=21;

	block14(21);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #22 (Pass) //
void block22(int _parent_=0)
{
	if (block22==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=22;

	block27(22);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #23 (Pass) //
void block23(int _parent_=0)
{
	if (block23==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=23;

	block2(23); block7(23);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #24 (Buy pending order) //
void block24(int _parent_=0)
{
	if (block24==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=24;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersGroup=""; // Group # (empty=Default)
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string Price="dynamic"; // Open at price
	double PriceOffset=0; // Price offset
	string VolumeMode="fixed"; // Money management
	double VolumeSize=_FixedLotSizePips; // Lot size
	double VolumeSizeRisk=50; // Risk fixed amount of money
	double VolumeRisk=2.5; // Risk percent
	double VolumePercent=100; // Volume size
	double VolumeBlockPercent=3; // Block % of Balance
	double FixedRatioUnitSize=0.01; // Fixed Ratio: Unit size
	double FixedRatioDelta=20; // Fixed Ratio: Delta parameter
	string StopLossMode="dynamicLevel"; // Stop-Loss mode
	double StopLossPips=100; // in pips...
	double StopLossPercentTP=100; // % of Take-Profit
	string TakeProfitMode="dynamicLevel"; // Take-Profit mode
	double TakeProfitPips=100; // in pips...
	double TakeProfitPercentSL=100; // % of Stop-Loss
	string ExpMode="specified"; // Expiration mode
	int ExpDays=_PendingOrderExpirationDays; // Days
	int ExpHours=_PendingOrderExpirationHours; // Hours
	int ExpMinutes=_PendingOrderExpirationMinutes; // Minutes
	int CreateOCO=0; // Create OCO order
	double Slippage=4; // Slippage
	string MyComment="Long pending order"; // Comment
	color ArrowColorBuy=Blue; // Arrow color
	
	///////////////
	// Main code //
	///////////////
	
	SetSymbol(SYMBOL);
	
	//-- open price -------------------------------------------------------------
	double op=0;
	     if (Price=="ask") {op=SymbolAsk();}
	else if (Price=="bid") {op=SymbolBid();}
	else if (Price=="mid") {op=(SymbolAsk()+SymbolBid())/2;}
	else if (Price=="dynamic") {op=_fResults(Result13);}
	op=op+toDigits(PriceOffset);
	
	//-- stops ------------------------------------------------------------------
	double sll=0, slp=0, tpl=0, tpp=0;
	
	     if (StopLossMode=="fixed")        {slp=StopLossPips;}
	else if (StopLossMode=="dynamicPips")  {slp=_value(100);}
	else if (StopLossMode=="dynamicDigits"){slp=toPips(_value(0.0100),SYMBOL);}
	else if (StopLossMode=="dynamicLevel") {sll=_fResults(Result14);}
	
	     if (TakeProfitMode=="fixed")         {tpp=TakeProfitPips;}
	else if (TakeProfitMode=="dynamicPips")   {tpp=_fResults(Result58);}
	else if (TakeProfitMode=="dynamicDigits") {tpp=toPips(_value(0.0100),SYMBOL);}
	else if (TakeProfitMode=="dynamicLevel")  {tpl=_fResults(Result58);}
	
	if (StopLossMode == "percentTP") {
	   if (tpp > 0) {slp = tpp*StopLossPercentTP/100;}
	   if (tpl > 0) {slp = toPips(MathAbs(SymbolAsk(SYMBOL) - tpl), SYMBOL)*StopLossPercentTP/100;}
	}
	if (TakeProfitMode == "percentSL") {
	   if (slp > 0) {tpp = slp*TakeProfitPercentSL/100;}
	   if (sll > 0) {tpp = toPips(MathAbs(SymbolAsk(SYMBOL) - sll), SYMBOL)*TakeProfitPercentSL/100;}
	}
	
	//-- lots -------------------------------------------------------------------
	double lots=0;
	double pre_sll=sll; if (pre_sll==0) {pre_sll=op;}
	double pre_sl_pips=toPips(op-(pre_sll-toDigits(slp,SYMBOL)));
	
	     if (VolumeMode=="fixed")             {lots=DynamicLots(VolumeMode, VolumeSize);}
	else if (VolumeMode=="block-equity")      {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="block-balance")     {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="block-freemargin")  {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="equity")            {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="balance")           {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="freemargin")        {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="equityRisk")        {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="balanceRisk")       {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="freemarginRisk")    {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="fixedRisk")         {lots=DynamicLots(VolumeMode, VolumeSizeRisk, pre_sl_pips);}
	else if (VolumeMode=="fixedRatio")        {lots=DynamicLots(VolumeMode, FixedRatioUnitSize, FixedRatioDelta);}
	else if (VolumeMode=="dynamic")           {lots=AlignLots(_value(0.1));}
	
	//-- expiration -------------------------------------------------------------
	datetime exp=ExpirationTime(ExpMode,ExpDays,ExpHours,ExpMinutes,_time(0, 0, "00:00", 1, "", 0, 0, 0, 0, 12, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, true));
	
	//-- send -------------------------------------------------------------------
	int ticket=BuyLater(SYMBOL,lots,op,sll,tpl,slp,tpp,Slippage,exp,(MagicStart+(int)OrdersGroup),MyComment,ArrowColorBuy,CreateOCO);
	
	if (ticket>0) {/* Orange output */} else {/* Gray output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #25 (Sell pending order) //
void block25(int _parent_=0)
{
	if (block25==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=25;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersGroup=""; // Group # (empty=Default)
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string Price="dynamic"; // Open at price
	double PriceOffset=0; // Price offset
	string VolumeMode="fixed"; // Money management
	double VolumeSize=_FixedLotSizePips; // Lot size
	double VolumeSizeRisk=50; // Risk fixed amount of money
	double VolumeRisk=2.5; // Risk percent
	double VolumePercent=100; // Volume size
	double VolumeBlockPercent=3; // Block % of Balance
	double FixedRatioUnitSize=0.01; // Fixed Ratio: Unit size
	double FixedRatioDelta=20; // Fixed Ratio: Delta parameter
	string StopLossMode="dynamicLevel"; // Stop-Loss mode
	double StopLossPips=100; // in pips...
	double StopLossPercentTP=100; // % of Take-Profit
	string TakeProfitMode="dynamicLevel"; // Take-Profit mode
	double TakeProfitPips=100; // in pips...
	double TakeProfitPercentSL=100; // % of Stop-Loss
	string ExpMode="specified"; // Expiration mode
	int ExpDays=_PendingOrderExpirationDays; // Days
	int ExpHours=_PendingOrderExpirationHours; // Hours
	int ExpMinutes=_PendingOrderExpirationMinutes; // Minutes
	int CreateOCO=0; // Create OCO order
	double Slippage=4; // Slippage
	string MyComment="Short pending order"; // Comment
	color ArrowColorSell=Red; // Arrow color
	
	///////////////
	// Main code //
	///////////////
	
	SetSymbol(SYMBOL);
	
	//-- open price -------------------------------------------------------------
	double op=0;
	     if (Price=="ask") {op=SymbolAsk();}
	else if (Price=="bid") {op=SymbolBid();}
	else if (Price=="mid") {op=(SymbolAsk()+SymbolBid())/2;}
	else if (Price=="dynamic") {op=_fResults(Result12);}
	op=op-toDigits(PriceOffset);
	
	//-- stops ------------------------------------------------------------------
	double sll=0, slp=0, tpl=0, tpp=0;
	
	     if (StopLossMode=="fixed")        {slp=StopLossPips;}
	else if (StopLossMode=="dynamicPips")  {slp=_value(100);}
	else if (StopLossMode=="dynamicDigits"){slp=toPips(_value(0.0100),SYMBOL);}
	else if (StopLossMode=="dynamicLevel") {sll=_fResults(Result16);}
	
	     if (TakeProfitMode=="fixed")         {tpp=TakeProfitPips;}
	else if (TakeProfitMode=="dynamicPips")   {tpp=_fResults(Result19);}
	else if (TakeProfitMode=="dynamicDigits") {tpp=toPips(_value(0.0100),SYMBOL);}
	else if (TakeProfitMode=="dynamicLevel")  {tpl=_fResults(Result60);}
	
	if (StopLossMode == "percentTP") {
	   if (tpp > 0) {slp = tpp*StopLossPercentTP/100;}
	   if (tpl > 0) {slp = toPips(MathAbs(SymbolAsk(SYMBOL) - tpl), SYMBOL)*StopLossPercentTP/100;}
	}
	if (TakeProfitMode == "percentSL") {
	   if (slp > 0) {tpp = slp*TakeProfitPercentSL/100;}
	   if (sll > 0) {tpp = toPips(MathAbs(SymbolAsk(SYMBOL) - sll), SYMBOL)*TakeProfitPercentSL/100;}
	}
	
	//-- lots -------------------------------------------------------------------
	double lots=0;
	double pre_sll=sll; if (pre_sll==0) {pre_sll=op;}
	double pre_sl_pips=toPips((pre_sll+toDigits(slp,SYMBOL))-op);
	
	     if (VolumeMode=="fixed")             {lots=DynamicLots(VolumeMode, VolumeSize);}
	else if (VolumeMode=="block-equity")      {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="block-balance")     {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="block-freemargin")  {lots=DynamicLots(VolumeMode, VolumeBlockPercent);}
	else if (VolumeMode=="equity")            {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="balance")           {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="freemargin")        {lots=DynamicLots(VolumeMode, VolumePercent);}
	else if (VolumeMode=="equityRisk")        {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="balanceRisk")       {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="freemarginRisk")    {lots=DynamicLots(VolumeMode, VolumeRisk, pre_sl_pips);}
	else if (VolumeMode=="fixedRisk")         {lots=DynamicLots(VolumeMode, VolumeSizeRisk, pre_sl_pips);}
	else if (VolumeMode=="fixedRatio")        {lots=DynamicLots(VolumeMode, FixedRatioUnitSize, FixedRatioDelta);}
	else if (VolumeMode=="dynamic")           {lots=AlignLots(_value(0.1));}
	
	//-- expiration -------------------------------------------------------------
	datetime exp=ExpirationTime(ExpMode,ExpDays,ExpHours,ExpMinutes,_time(0, 0, "00:00", 1, "", 0, 0, 0, 0, 12, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, true));
	
	//-- send -------------------------------------------------------------------
	int ticket=SellLater(SYMBOL,lots,op,sll,tpl,slp,tpp,Slippage,exp,(MagicStart+(int)OrdersGroup),MyComment,ArrowColorSell,CreateOCO);
	
	if (ticket>0) {/* Orange output */} else {/* Gray output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #26 (Formula) //
void block26(int _parent_=0)
{
	if (block26==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=26;

	double Lo=_fResults(Result17);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_value(_TPFactorBasedOnCandle1Length);
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result26=(Lo * Ro);
	
	block58(26); block61(26);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #27 (Formula) //
void block27(int _parent_=0)
{
	if (block27==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=27;

	double Lo=_fResults(Result18);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_value(_TPFactorBasedOnCandle1Length);
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result27=(Lo * Ro);
	
	block59(27);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #28 (Formula) //
void block28(int _parent_=0)
{
	if (block28==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=28;

	double Lo=_fResults(Result18);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_value(_TPFactorBasedOnCandle1Length);
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result28=(Lo * Ro);
	
	block19(28);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #29 (Formula) //
void block29(int _parent_=0)
{
	if (block29==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=29;

	double Lo=_fResults(Result14);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_Spread(CurrentSymbol());
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result29=(Lo - Ro);
	
	block17(29);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #30 (Pass) //
void block30(int _parent_=0)
{
	if (block30==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=30;

	block4(30); block23(30); block48(30);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #31 (Once a day) //
void block31(int _parent_=0)
{
	if (block31==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=31;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string ServerOrLocalTime="server"; // Server or local time
	string HoursFilter="disabled"; // Hours filter
	string CertainHour="09:15"; // Certain hour
	string StartHour="01:00"; // Start hour (from)
	string EndHour="08:00"; // End hour (to)
	
	///////////////
	// Main code //
	///////////////
	
	static int day0=0;
	int day=0;
	static datetime time1;
	datetime time;
	bool next=false;
	bool local_time = false;
	
	if (ServerOrLocalTime=="local") {local_time = true; time=TimeLocal();}
	else if (ServerOrLocalTime=="server") {time=TimeCurrent();}
	day=TimeDay(time);
	
	if (day!=day0 || time>time1)
	{
	   if (HoursFilter=="disabled") {next=true;}
	   else {
	      if (HoursFilter=="hour") {
	         if (time>=TimeFromString(local_time, CertainHour) && time<TimeFromString(local_time, CertainHour)+60) {next=true;}
	      }
	      else
	      if (HoursFilter=="period") {
	         if (time>=TimeFromString(local_time, StartHour) && time<TimeFromString(local_time, EndHour)) {next=true;}
	      }
	   }
	}
	if (next==true) {
	   time1=time+86400;
	   day0=day;
	   block33(31); block35(31); block38(31); block44(31); block1666613(31); block1666615(31); block1666617(31); block1666619(31);
	} else {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #32 (Pass) //
void block32(int _parent_=0)
{
	if (block32==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=32;

	block17(32);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #33 (spreads correct<br>) //
void block33(int _parent_=0)
{
	if (block33==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=33;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_value(_TakeSpreadsIntoAccountTheCorrectWay);
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   bool Ro=_boolean(true);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo==Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro==Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block34(33);} else if (o2==true) {/* Yellow output */}
}
bool _boolean(bool Boolean) {
	return(Boolean);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #34 (Turn ON blocks) //
void block34(int _parent_=0)
{
	if (block34==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=34;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="24,25"; // Block IDs to turn ON
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn ON all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes ON");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],true);
	}
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #35 (spreads max<br>) //
void block35(int _parent_=0)
{
	if (block35==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=35;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_value(_TakeSpreadsIntoAccountTheMax_PipsWay);
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   bool Ro=_boolean(true);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo==Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro==Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block36(35);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #36 (Turn ON blocks) //
void block36(int _parent_=0)
{
	if (block36==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=36;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="9,10,21,29,22,27"; // Block IDs to turn ON
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn ON all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes ON");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],true);
	}
	block37(36);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #37 (Turn OFF blocks) //
void block37(int _parent_=0)
{
	if (block37==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=37;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="13,32"; // Block ID to turn OFF
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn OFF all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes OFF");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],false);
	}
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #38 (bullbear<br>) //
void block38(int _parent_=0)
{
	if (block38==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=38;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_value(_UsePrevCandlesBearishBullishFilter);
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   bool Ro=_boolean(false);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo==Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro==Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block39(38);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #39 (Turn ON blocks) //
void block39(int _parent_=0)
{
	if (block39==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=39;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="23"; // Block IDs to turn ON
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn ON all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes ON");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],true);
	}
	block40(39);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #40 (Turn OFF blocks) //
void block40(int _parent_=0)
{
	if (block40==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=40;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="4,48"; // Block ID to turn OFF
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn OFF all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes OFF");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],false);
	}
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #41 (Condition&nbsp;) //
void block41(int _parent_=0)
{
	if (block41==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=41;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_prices("BID", 0, CurrentSymbol());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_iMA(_MA1Period, 0, MODE_SMA, PRICE_CLOSE, CurrentSymbol(), CurrentTimeframe(), 0);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo>Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro>Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block47(41);} else if (o2==true) {/* Yellow output */}
}
double _prices(string Price, int TickID, string SYMBOL) {
	double retval=0;
	TickID=TickID+IndicatorMoreShift();
	if (Price=="ASK")       {retval=TicksData(SYMBOL,MODE_ASK,TickID);}
	else if (Price=="BID")  {retval=TicksData(SYMBOL,MODE_BID,TickID);}
	else if (Price=="MID")  {retval=((TicksData(SYMBOL,MODE_ASK,TickID)+TicksData(SYMBOL,MODE_BID,TickID))/2);}
	return(retval);
}
double _iMA(int MAperiod, int MAshift, int MAmethod, int AppliedPrice, string SYMBOL, int TIMEFRAME, int SHIFT) {
	SHIFT=SHIFT+IndicatorMoreShift();
	double retval=iMA(SYMBOL,TIMEFRAME,MAperiod,MAshift,MAmethod,AppliedPrice,SHIFT);
	SetLastIndicatorData(retval,SYMBOL,TIMEFRAME,SHIFT);
	return(retval);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #42 (Pass) //
void block42(int _parent_=0)
{
	if (block42==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=42;

	block41(42); block43(42); block49(42);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #43 (Pass) //
void block43(int _parent_=0)
{
	if (block43==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=43;

	block30(43);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #44 (ma) //
void block44(int _parent_=0)
{
	if (block44==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=44;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_value(_UseMATrendFilter);
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   bool Ro=_boolean(true);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo==Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro==Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block45(44);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #45 (Turn ON blocks) //
void block45(int _parent_=0)
{
	if (block45==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=45;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="41,49"; // Block IDs to turn ON
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn ON all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes ON");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],true);
	}
	block46(45);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #46 (Turn OFF blocks) //
void block46(int _parent_=0)
{
	if (block46==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=46;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="43"; // Block ID to turn OFF
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn OFF all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes OFF");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],false);
	}
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #47 (Condition&nbsp;) //
void block47(int _parent_=0)
{
	if (block47==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=47;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_prices("BID", 0, CurrentSymbol());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_iMA(_MA2Period, 0, MODE_SMA, PRICE_CLOSE, CurrentSymbol(), CurrentTimeframe(), 0);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo>Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro>Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block4(47);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #48 (Condition&nbsp;) //
void block48(int _parent_=0)
{
	if (block48==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=48;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_candles("iClose", "id", 2, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_candles("iOpen", "id", 2, "00:00", CurrentSymbol(), CurrentTimeframe());
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo<Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro<Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {/* Orange output */} else if (o2==true) {block6(48);}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #49 (Condition&nbsp;) //
void block49(int _parent_=0)
{
	if (block49==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=49;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_prices("ASK", 0, CurrentSymbol());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_iMA(_MA1Period, 0, MODE_SMA, PRICE_CLOSE, CurrentSymbol(), CurrentTimeframe(), 0);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo<Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro<Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block55(49);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #55 (Condition&nbsp;) //
void block55(int _parent_=0)
{
	if (block55==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=55;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_prices("ASK", 0, CurrentSymbol());
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Ro=_iMA(_MA2Period, 0, MODE_SMA, PRICE_CLOSE, CurrentSymbol(), CurrentTimeframe(), 0);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo<Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro<Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block48(55);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #57 (Pass) //
void block57(int _parent_=0)
{
	if (block57==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=57;

	block62(57);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #58 (Formula) //
void block58(int _parent_=0)
{
	if (block58==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=58;

	double Lo=_fResults(Result13);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_fResults(Result26);
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result58=(Lo + Ro);
	
	block63(58);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #59 (Formula) //
void block59(int _parent_=0)
{
	if (block59==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=59;

	double Lo=_fResults(Result12);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_fResults(Result27);
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result59=(Lo - Ro);
	
	block66(59);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #60 (Formula) //
void block60(int _parent_=0)
{
	if (block60==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=60;

	double Lo=_fResults(Result12);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_fResults(Result19);
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result60=(Lo - Ro);
	
	block64(60);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #61 (Formula) //
void block61(int _parent_=0)
{
	if (block61==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=61;

	double Lo=_fResults(Result11);
	if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	
	double Ro=_fResults(Result26);
	if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	
	Result61=(Lo + Ro);
	
	block65(61);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #62 (Once per bar) //
void block62(int _parent_=0)
{
	if (block62==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=62;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	int TIMEFRAME=CurrentTimeframe(); // Timeframe
	int PassMaxTimes=1; // Max. times to pass
	
	///////////////
	// Main code //
	///////////////
	
	static int times = 0;
	static datetime time0;
	datetime time=iTime(SYMBOL,TIMEFRAME,0);
	if (time0<time)
	{
	   times++;
	   if (times >= PassMaxTimes)
	   {
	      time0=time;
	      times=0;
	   }
	   
	   block42(62);
	}
	else {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #63 (Once per bar) //
void block63(int _parent_=0)
{
	if (block63==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=63;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	int TIMEFRAME=CurrentTimeframe(); // Timeframe
	int PassMaxTimes=1; // Max. times to pass
	
	///////////////
	// Main code //
	///////////////
	
	static int times = 0;
	static datetime time0;
	datetime time=iTime(SYMBOL,TIMEFRAME,0);
	if (time0<time)
	{
	   times++;
	   if (times >= PassMaxTimes)
	   {
	      time0=time;
	      times=0;
	   }
	   
	   block1666607(63); block1666609(63);
	}
	else {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #64 (Once per bar) //
void block64(int _parent_=0)
{
	if (block64==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=64;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	int TIMEFRAME=CurrentTimeframe(); // Timeframe
	int PassMaxTimes=1; // Max. times to pass
	
	///////////////
	// Main code //
	///////////////
	
	static int times = 0;
	static datetime time0;
	datetime time=iTime(SYMBOL,TIMEFRAME,0);
	if (time0<time)
	{
	   times++;
	   if (times >= PassMaxTimes)
	   {
	      time0=time;
	      times=0;
	   }
	   
	   block1666608(64); block1666612(64);
	}
	else {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #65 (Once per bar) //
void block65(int _parent_=0)
{
	if (block65==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=65;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	int TIMEFRAME=CurrentTimeframe(); // Timeframe
	int PassMaxTimes=1; // Max. times to pass
	
	///////////////
	// Main code //
	///////////////
	
	static int times = 0;
	static datetime time0;
	datetime time=iTime(SYMBOL,TIMEFRAME,0);
	if (time0<time)
	{
	   times++;
	   if (times >= PassMaxTimes)
	   {
	      time0=time;
	      times=0;
	   }
	   
	   block1666607(65); block1666610(65);
	}
	else {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #66 (Once per bar) //
void block66(int _parent_=0)
{
	if (block66==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=66;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	int TIMEFRAME=CurrentTimeframe(); // Timeframe
	int PassMaxTimes=1; // Max. times to pass
	
	///////////////
	// Main code //
	///////////////
	
	static int times = 0;
	static datetime time0;
	datetime time=iTime(SYMBOL,TIMEFRAME,0);
	if (time0<time)
	{
	   times++;
	   if (times >= PassMaxTimes)
	   {
	      time0=time;
	      times=0;
	   }
	   
	   block1666608(66); block1666611(66);
	}
	else {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666538 (Custom Alert MQL4 code <br>) //
void block1666538(int _parent_=0)
{
	if (block1666538==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666538;

	Alert (Symbol()+": Sell Alert!");
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666570 (Custom Alert MQL4 code <br>) //
void block1666570(int _parent_=0)
{
	if (block1666570==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666570;

	SendNotification(Symbol()+": Sell Alert!");
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666571 (Custom Alert MQL4 code) //
void block1666571(int _parent_=0)
{
	if (block1666571==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666571;

	SendMail(Symbol()+": Sell Alert!",Symbol()+": Sell Alert!");
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666573 (Custom Alert MQL4 code <br>) //
void block1666573(int _parent_=0)
{
	if (block1666573==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666573;

	Alert (Symbol()+": Buy Alert!");
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666605 (Custom Alert MQL4 code <br>) //
void block1666605(int _parent_=0)
{
	if (block1666605==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666605;

	SendNotification(Symbol()+": Buy Alert!");
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666606 (Custom Alert MQL4 code) //
void block1666606(int _parent_=0)
{
	if (block1666606==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666606;

	SendMail(Symbol()+": Buy Alert!",Symbol()+": Buy Alert!");
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666607 (Pass) //
void block1666607(int _parent_=0)
{
	if (block1666607==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666607;

	block1666573(1666607); block1666605(1666607); block1666606(1666607);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666608 (Pass) //
void block1666608(int _parent_=0)
{
	if (block1666608==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666608;

	block1666538(1666608); block1666570(1666608); block1666571(1666608);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666609 (Pass) //
void block1666609(int _parent_=0)
{
	if (block1666609==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666609;

	block24(1666609);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666610 (Pass) //
void block1666610(int _parent_=0)
{
	if (block1666610==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666610;

	block9(1666610);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666611 (Pass) //
void block1666611(int _parent_=0)
{
	if (block1666611==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666611;

	block10(1666611);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666612 (Pass) //
void block1666612(int _parent_=0)
{
	if (block1666612==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666612;

	block25(1666612);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666613 (mt4 alert<br>) //
void block1666613(int _parent_=0)
{
	if (block1666613==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666613;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_value(__SendMT4Alerts);
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   bool Ro=_boolean(true);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo==Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro==Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block1666614(1666613);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666614 (Turn ON blocks) //
void block1666614(int _parent_=0)
{
	if (block1666614==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666614;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="1666573,1666538"; // Block IDs to turn ON
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn ON all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes ON");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],true);
	}
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666615 (email alert<br>) //
void block1666615(int _parent_=0)
{
	if (block1666615==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666615;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_value(__SendEmailAlerts);
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   bool Ro=_boolean(true);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo==Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro==Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block1666616(1666615);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666616 (Turn ON blocks) //
void block1666616(int _parent_=0)
{
	if (block1666616==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666616;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="1666606,1666571"; // Block IDs to turn ON
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn ON all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes ON");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],true);
	}
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666617 (push alert<br>) //
void block1666617(int _parent_=0)
{
	if (block1666617==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666617;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_value(__SendPushAlerts);
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   bool Ro=_boolean(true);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo==Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro==Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block1666618(1666617);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666618 (Turn ON blocks) //
void block1666618(int _parent_=0)
{
	if (block1666618==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666618;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="1666605,1666570"; // Block IDs to turn ON
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn ON all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes ON");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],true);
	}
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666619 (alert only<br>) //
void block1666619(int _parent_=0)
{
	if (block1666619==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666619;

	int crossover=0;
	int crosswidth=1;
	bool o1=false, o2=false;
	
	for (int i=0; i<=crossover; i++)
	{
	   // i=0 - normal pass, i=1 - crossover pass
	   
	   // Left operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   double Lo=_value(_SendNotificationInsteadOfTrade);
	   if (MathAbs(Lo) == EMPTY_VALUE) {return;}
	   
	   // Right operand of the condition
	   IndicatorMoreShift(true,i*crosswidth);
	   bool Ro=_boolean(true);
	   if (MathAbs(Ro) == EMPTY_VALUE) {return;}
	   
	   // Conditions
	   if (Lo==Ro) {if(i==0){o1=true;}}else{if(i==0){o2=true;}else{o2=false;}}
	   if (crossover==1) {if (Ro==Lo) {if(i==0){o2=true;}}else{if(i==1){o1=false;}}}
	}
	IndicatorMoreShift(true,0); // reset
	// Outputs
	if (o1==true) {block1666621(1666619);} else if (o2==true) {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//       EA block #1666621 (Turn OFF blocks) //
void block1666621(int _parent_=0)
{
	if (block1666621==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1666621;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string BlockID="1666609,1666610,1666611,1666612"; // Block ID to turn OFF
	
	///////////////
	// Main code //
	///////////////
	
	static string blocks_raw="";
	static string blocks[];
	static bool turns[];
	static int count=0;
	int i=0;
	
	//-- initially decode the data and put it to the memory, and also in case the data is modified ------------
	if (blocks_raw!=BlockID) {
	   blocks_raw=BlockID;
	   StringExplode(",",BlockID,blocks);
	   count=ArraySize(blocks);
	   ArrayResize(turns,count);
	   ArrayInitialize(turns,false);
	   for (i=0; i<count; i++) {
	      blocks[i]=StringTrimLeft(blocks[i]);
	      blocks[i]=StringTrimRight(blocks[i]);
	   }
	}
	
	//-- actually turn OFF all the blocks in the list ----------------------------------------------------------
	for (i=0; i<count; i++) {
	   if (turns[i]==false) {
	      Print("      EA: Block \""+blocks[i]+"\" goes OFF");
	      turns[i]=true;
	   }
	   fxD_BlocksLookupTable(1,blocks[i],false);
	}
	/* Orange output */
}


/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |                                                  API FUNCTIONS                                                   | //
// |                                 System and Custom functions used in the program                                  | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

// System functions
double AccountBalanceAtStart()
{
   // This function MUST be run once at pogram's start
	static double memory=0;
   if (memory==0) {memory=AccountBalance();}
   return(memory);
}
double AlignLots(double lots, double lowerlots=0, double upperlots=0)
{
	string symbol=GetSymbol();

   double LotStep=MarketInfo(symbol,MODE_LOTSTEP);
   double LotSize=MarketInfo(symbol,MODE_LOTSIZE);
   double MinLots=MarketInfo(symbol,MODE_MINLOT);
   double MaxLots=MarketInfo(symbol,MODE_MAXLOT);
   double margin_required=MarketInfo(symbol,MODE_MARGINREQUIRED);
   
   //if (lots>MaxLots) {lots=lots/LotSize;}
   
   //double stepsize=0;
   //while(lots+0.000000001>stepsize){stepsize+=LotStep;}
   //lots=stepsize-LotStep;
   lots=MathRound(lots/LotStep)*LotStep;
   
   if (lots<MinLots) {lots=MinLots;}
   if (lots>MaxLots) {lots=MaxLots;}

   if (lowerlots > 0)
   {
      lowerlots = MathRound(lowerlots/LotStep)*LotStep;
      if (lots < lowerlots) {lots = lowerlots;}
   }
   if (upperlots > 0)
   {
      upperlots = MathRound(upperlots/LotStep)*LotStep;
      if (lots > upperlots) {lots = upperlots;}
   }
   
   return (lots);
}
double AlignStopLoss(
   string symbol,
   int type,
   double price,
   double sll=0,
   double slp=0,
   bool consider_freezelevel=false
   )
{
   double sl=0;

   if (MathAbs(sll)==EMPTY_VALUE) {sll=0;}
   if (MathAbs(slp)==EMPTY_VALUE) {slp=0;}
   if (sll==0 && slp==0) {return(0);} // no sl - return 0
   if (price<=0) {Print("AlignStopLoss() error: No price entered");return(-1);}
   
   double point   =MarketInfo(symbol,MODE_POINT);
   double digits  =MarketInfo(symbol,MODE_DIGITS);
   slp=slp*PipValue(symbol)*point;
   
   //-- buy-sell identifier ---------------------------------------------
   int bs=1;
   if (
      type==OP_BUY
      || type==OP_BUYSTOP
      || type==OP_BUYLIMIT
      )
   {
      bs=1;
   }
   else if (
      type==OP_SELL
      || type==OP_SELLSTOP
      || type==OP_SELLLIMIT
      )
   {
      bs=-1;
   }
   
   //-- prices that will be used ----------------------------------------
   double askbid=price;
   double bidask=price;
   
   if (type==OP_BUY || type==OP_SELL)
   {
      double ask =MarketInfo(symbol,MODE_ASK);
      double bid =MarketInfo(symbol,MODE_BID);
      
      askbid=ask;
      bidask=bid;
      if (bs<0) {
        askbid=bid;
        bidask=ask;
      }
   }
   
   //-- build sl level -------------------------------------------------- 
   if (sll==0 && slp!=0) {sll=price;}

   if (sll>0) {sl=sll-slp*bs;}
   
   if (sl<0) {return(-1);}
      
   sl=NormalizeDouble(sl,digits);
   
   //-- build limit levels ----------------------------------------------
   double minstops=MarketInfo(symbol,MODE_STOPLEVEL);
   if (consider_freezelevel==true) {
      int freezelevel=MarketInfo(symbol,MODE_FREEZELEVEL);
      if (freezelevel>minstops) {minstops=freezelevel;}
   }
   minstops=NormalizeDouble(minstops*point,digits);
      
   double sllimit=bidask-minstops*bs; // SL min price level
   
   //-- check and align sl, print errors --------------------------------
   if (sl>0) {
      /*if (sl==askbid)
      {
         sl=0;
      }
      else */
      if ((bs>0 && sl>askbid) || (bs<0 && sl<askbid))
      {
         string abstr="";
         if (bs>0) {abstr="Ask";} else {abstr="Bid";}
         Print(
            "Error: Invalid SL requested (",
            DoubleToStr(sl,digits),
            " for ",abstr," price ",
            askbid,
            ")"
         );
         return(-1);
      }
      else if ((bs>0 && sl>sllimit) || (bs<0 && sl<sllimit))
      {
         if (USE_VIRTUAL_STOPS) {
            return(sl);
         }

         Print(
            "Warning: Too short SL requested (",
            DoubleToStr(sl,digits),
            " or ",
            DoubleToStr(MathAbs(sl-askbid)/point,0),
            " points), minimum will be taken (",
            DoubleToStr(sllimit,digits),
            " or ",
            DoubleToStr(MathAbs(askbid-sllimit)/point,0),
            " points)"
         );
         sl=sllimit;

         return(sl);
      }
   }
   return(sl);
}
double AlignTakeProfit(
   string symbol,
   int type,
   double price,
   double tpl=0,
   double tpp=0,
   bool consider_freezelevel=false
   )
{
   double tp=0;
   
   if (MathAbs(tpl)==EMPTY_VALUE) {tpl=0;}
   if (MathAbs(tpp)==EMPTY_VALUE) {tpp=0;}
   if (tpl==0 && tpp==0) {return(0);} // no tp - return 0
   if (price<=0) {Print("AlignTakeProfit() error: No price entered");return(-1);}

   double point   =MarketInfo(symbol,MODE_POINT);
   double digits  =MarketInfo(symbol,MODE_DIGITS);
   tpp=tpp*PipValue(symbol)*point;
   
   //-- buy-sell identifier ---------------------------------------------
   int bs=1;
   if (
      type==OP_BUY
      || type==OP_BUYSTOP
      || type==OP_BUYLIMIT
      )
   {
      bs=1;
   }
   else if (
      type==OP_SELL
      || type==OP_SELLSTOP
      || type==OP_SELLLIMIT
      )
   {
      bs=-1;
   }
   
   //-- prices that will be used ----------------------------------------
   double askbid=price;
   double bidask=price;
   
   if (type==OP_BUY || type==OP_SELL)
   {
      double ask =MarketInfo(symbol,MODE_ASK);
      double bid =MarketInfo(symbol,MODE_BID);
      
      askbid=ask;
      bidask=bid;
      if (bs<0) {
        askbid=bid;
        bidask=ask;
      }
   }
   
   //-- build tp level --------------------------------------------------- 
   if (tpl==0 && tpp!=0) {tpl=price;}

   if (tpl>0) {tp=tpl+tpp*bs;}
   
   if (tp<0) {return(-1);}

   tp=NormalizeDouble(tp,digits);
   
   //-- build limit levels ----------------------------------------------
   double minstops=MarketInfo(symbol,MODE_STOPLEVEL);
   if (consider_freezelevel==true) {
      int freezelevel=MarketInfo(symbol,MODE_FREEZELEVEL);
      if (freezelevel>minstops) {minstops=freezelevel;}
   }
   minstops=NormalizeDouble(minstops*point,digits);
   
   double tplimit=bidask+minstops*bs; // TP min price level
   
   //-- check and align tp, print errors --------------------------------
   if (tp>0) {
      /*if (tp==askbid)
      {
         tp=0;
      }
      else */
      if ((bs>0 && tp<askbid) || (bs<0 && tp>askbid))
      {
         string abstr="";
         if (bs>0) {abstr="Ask";} else {abstr="Bid";}
         Print(
            "Error: Invalid TP requested (",
            DoubleToStr(tp,digits),
            " for ",abstr," price ",
            askbid,
            ")"
            );
         return(-1);
      }
      else if ((bs>0 && tp<tplimit) || (bs<0 && tp>tplimit))
      {
         if (USE_VIRTUAL_STOPS) {
            return(tp);
         }

         Print(
            "Warning: Too short TP requested (",
            DoubleToStr(tp,digits),
            " or ",
            DoubleToStr(MathAbs(tp-askbid)/point,0),
            " points), minimum will be taken (",
            DoubleToStr(tplimit,digits),
            " or ",
            DoubleToStr(MathAbs(askbid-tplimit)/point,0),
            " points)"
         );
         tp=tplimit;
         return(tp);
      }
   }
   return(tp);
}
int ArraySearch(double &array[], double value)
{
   static bool founded; founded=false;
   static int index;    index=0;
   static int size;
   size=ArraySize(array);
   
   if (size>0)
   {
   	for (int i=0; i<size; i++)
      {
         if (array[i]==value)
         {
            founded=true;
            index=i;
            break;
         }  
   	}
   }

   if (founded==true) {return (index);} else {return (-1);}
}
int ArraySearch(int &array[], int value)
{
   static bool founded; founded=false;
   static int index;    index=0;
   static int size;
   size=ArraySize(array);
   
   if (size>0)
   {
      for (int i=0; i<size; i++)
      {
         if (array[i]==value)
         {
            founded=true;
            index=i;
            break;
         }  
   	}
   }

   if (founded==true) {return (index);} else {return (-1);}
}
int ArraySearch(string &array[], string value)
{
   static bool founded; founded=false;
   static int index;    index=0;
   static int size;
   size=ArraySize(array);
   
   if (size>0)
   {
      for (int i=0; i<size; i++)
      {
         if (array[i]==value)
         {
            founded=true;
            index=i;
            break;
         }  
   	}
   }

   if (founded==true) {return (index);} else {return (-1);}
}
bool ArrayStrip(double &array[], double value)
{
   bool stripped=false;
   int size=ArraySize(array);
   if (size>0)
   {
      int i=0; int x=0;
      for (i=0; i<size; i++)
      {
         if (array[i]!=value)
         {
            array[x]=array[i];
            x++;
         } else {
            stripped=true;  
         }
      }
      ArrayResize(array,x);
   }
   return (stripped);
}
bool ArrayStripKey(double &array[], double key)
{
   static bool stripped; stripped=false;
   static int size;
   size = ArraySize(array);
   if (size>0)
   {
      int i=0; int x=0;
      for (i=0; i<size; i++)
      {
         if (i!=key)
         {
            array[x]=array[i];
            x++;
         } else {
            stripped=true;  
         }
      }
      ArrayResize(array,x);
   }
   return (stripped);
}
bool ArrayStripKey(int &array[], int key)
{
   static bool stripped; stripped=false;
   static int size;
   size = ArraySize(array);
   if (size>0)
   {
      int i=0; int x=0;
      for (i=0; i<size; i++)
      {
         if (i!=key)
         {
            array[x]=array[i];
            x++;
         } else {
            stripped=true;  
         }
      }
      ArrayResize(array,x);
   }
   return (stripped);
}
bool ArrayStripKey(string &array[], string key)
{
   static bool stripped; stripped=false;
   static int size;
   size = ArraySize(array);
   if (size>0)
   {
      int i=0; int x=0;
      for (i=0; i<size; i++)
      {
         if (i!=key)
         {
            array[x]=array[i];
            x++;
         } else {
            stripped=true;  
         }
      }
      ArrayResize(array,x);
   }
   return (stripped);
}
bool ArrayValue(double &array[], double value)
{
   bool founded=false;
   int size=ArraySize(array);
   for (int i=0; i<size; i++) {
      if (array[i]==value) {founded=true; break;}
   }
   if (founded==false) {
      ArrayResize(array,size+1);
      array[size]=value;
      return (true);
   } else {
      return (false);
   }
}
bool ArrayValue(int &array[], int value)
{
   bool founded=false;
   int size=ArraySize(array);
   for (int i=0; i<size; i++) {
      if (array[i]==value) {founded=true; break;}
   }
   if (founded==false) {
      ArrayResize(array,size+1);
      array[size]=value;
      return (true);
   } else {
      return (false);
   }
}
bool ArrayValue(string &array[], string value)
{
   bool founded=false;
   int size=ArraySize(array);
   for (int i=0; i<size; i++) {
      if (array[i]==value) {founded=true; break;}
   }
   if (founded==false) {
      ArrayResize(array,size+1);
      array[size]=value;
      return (true);
   } else {
      return (false);  
   }
}
double attrClosePrice(string sel="")
{
   return(OrderClosePrice());
}
datetime attrCloseTime(string sel="")
{
   return(OrderCloseTime());
}
string attrComment(string sel="")
{
   return(OrderComment());
}
double attrCommission(string sel="")
{
   if (sel=="e" || sel=="event") {return(e_attrCommission());}
   return(OrderCommission());
}
datetime attrExpiration(string sel="")
{
   return(OrderExpiration());
}
double attrLots(string sel="")
{
   return(OrderLots());
}
int attrMagicNumber(string sel="")
{
   return(OrderMagicNumber());
}
double attrOpenPrice(string sel="")
{
   return(OrderOpenPrice());
}
datetime attrOpenTime(string sel="")
{
   return(OrderOpenTime());
}
double attrProfit(string sel="")
{
   return(OrderProfit());
}
double attrStopLoss()
{
   if (USE_VIRTUAL_STOPS) {return(VirtualStopsDriver("get sl",OrderTicket()));}
   return(OrderStopLoss());
}
double attrSwap(string sel="")
{
   return(OrderSwap());
}
string attrSymbol(string sel="")
{
   return(OrderSymbol());
}
double attrTakeProfit()
{
   if (USE_VIRTUAL_STOPS) {return(VirtualStopsDriver("get tp",OrderTicket()));}
   return(OrderTakeProfit());
}
int attrTicket()
{
   return(OrderTicket());
}
double attrType(string sel="")
{
   return(OrderType());
}
int BuyLater(
   string symbol,
   double lots,
   double price,
   double sll=0, // SL level
   double tpl=0, // TO level
   double slp=0, // SL adjust in points
   double tpp=0, // TP adjust in points
   double slippage=0,
   datetime expiration=0,
   int magic=0,
   string comment="",
   color arrowcolor=CLR_NONE,
   bool oco = false
   )
{
   double ask=MarketInfo(symbol,MODE_ASK);
   int type;
        if (price==ask){type=OP_BUY;}
   else if (price<ask) {type=OP_BUYLIMIT;}
   else if (price>ask) {type=OP_BUYSTOP;}
   
   int ticket=OrderCreate(
      symbol,
      type,
      lots,
      price,
      sll,
      tpl,
      slp,
      tpp,
      slippage,
      magic,
      comment,
      arrowcolor,
      expiration,
      oco
      );
   return(ticket);
}
double ChartEventParameterDouble(int cmd=0,double inp=-1) {static double mem=-1; if(cmd==1){mem=inp;} return(mem);}
double ChartEventParameterLong(int cmd=0,double inp=-1) {static double mem=-1; if(cmd==1){mem=inp;} return(mem);}
string ChartEventParameterString(int cmd=0,string inp="") {static string mem=""; if(cmd==1){mem=inp;} return(mem);}
int ChartEventType(int cmd=0,int inp=-1) {static int mem=-1; if(cmd==1){mem=inp;} return(mem);}
int CheckForTradingError(int error_code=-1, string msg_prefix="")
{
   // return 0 -> no error
   // return 1 -> overcomable error
   // return 2 -> fatal error
   
   if (error_code<0) {
      error_code=GetLastError();  
   }
   
   int retval=0;
   static int tryouts=0;
   
   //-- error check -----------------------------------------------------
   switch(error_code)
   {
      //-- no error
      case 0:
         retval=0;
         break;
      //-- overcomable errors
      case 1: // No error returned
         RefreshRates();
         retval=1;
         break;
      case 4: //ERR_SERVER_BUSY
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         Sleep(1000);
         RefreshRates();
         retval=1;
         break;
      case 6: //ERR_NO_CONNECTION
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         while(!IsConnected()) {Sleep(100);}
         while(IsTradeContextBusy()) {Sleep(50);}
         RefreshRates();
         retval=1;
         break;
      case 128: //ERR_TRADE_TIMEOUT
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         RefreshRates();
         retval=1;
         break;
      case 129: //ERR_INVALID_PRICE
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 130: //ERR_INVALID_STOPS
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 135: //ERR_PRICE_CHANGED
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 136: //ERR_OFF_QUOTES
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 137: //ERR_BROKER_BUSY
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         Sleep(1000);
         retval=1;
         break;
      case 138: //ERR_REQUOTE
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         if (!IsTesting()) {while(RefreshRates()==false) {Sleep(1);}}
         retval=1;
         break;
      case 142: //This code should be processed in the same way as error 128.
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         RefreshRates();
         retval=1;
         break;
      case 143: //This code should be processed in the same way as error 128.
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         RefreshRates();
         retval=1;
         break;
      /*case 145: //ERR_TRADE_MODIFY_DENIED
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Waiting for a new tick to retry.."));}
         while(RefreshRates()==false) {Sleep(1);}
         return(1);
      */
      case 146: //ERR_TRADE_CONTEXT_BUSY
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code),". Retrying.."));}
         while(IsTradeContextBusy()) {Sleep(50);}
         RefreshRates();
         retval=1;
         break;
      //-- critical errors
      default:
         if (msg_prefix!="") {Print(StringConcatenate(msg_prefix,": ",ErrorMessage(error_code)));}
         retval=2;
         break;
   }

   if (retval==0) {tryouts=0;}
   else if (retval==1) {
      tryouts++;
      if (tryouts>=10) {
         tryouts=0;
         retval=2;
      } else {
         Print("retry #"+tryouts+" of 10");
      }
   }
   
   return(retval);
}
bool CloseTrade(int ticket, double slippage=0, color arrowcolor=CLR_NONE)
{
   bool success=false;
   if (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {return(false);}
   
   while(true)
   {
      //-- wait if needed -----------------------------------------------
      WaitTradeContextIfBusy();
      //-- close --------------------------------------------------------
      success=OrderClose(ticket,attrLots(),attrClosePrice(),slippage*PipValue(attrSymbol()),arrowcolor);
      if (success==true) {
         if (USE_VIRTUAL_STOPS) {
            VirtualStopsDriver("clear",ticket);
         }
         RegisterEvent("trade");
         return(true);
      }
      //-- errors -------------------------------------------------------
      int erraction=CheckForTradingError(GetLastError(), "Closing trade #"+ticket+" error");
      switch(erraction)
      {
         case 0: break;    // no error
         case 1: continue; // overcomable error
         case 2: break;    // fatal error
      }
      break;
   }
   return(false);
}
string CurrentSymbol(string symbol="")
{
   static string memory="";
   if (symbol!="") {memory=symbol;} else
   if (memory=="") {memory=Symbol();}
   return(memory);
}
int CurrentTimeframe(int tf=-1)
{
	static int memory=0;
   if (tf>=0) {memory=tf;}
   return(memory);
}
bool DeleteOrder(int ticket, color arrowcolor)
{
   bool success=false;
   if (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {return(false);}
   
   while(true)
   {
      //-- wait if needed -----------------------------------------------
      WaitTradeContextIfBusy();
      //-- delete -------------------------------------------------------
      success=OrderDelete(ticket,arrowcolor);
      if (success==true) {
         if (USE_VIRTUAL_STOPS) {
            VirtualStopsDriver("clear",ticket);
         }
         RegisterEvent("trade");
         return(true);
      }
      //-- error check --------------------------------------------------
      int erraction=CheckForTradingError(GetLastError(), "Deleting order #"+ticket+" error");
      switch(erraction)
      {
         case 0: break;    // no error
         case 1: continue; // overcomable error
         case 2: break;    // fatal error
      }
      break;
   }
   return(false);
}
void DrawSpreadInfo()
{
   static bool allow_draw = true;
   if (allow_draw==false) {return;}
   if (MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) {allow_draw=false;} // Allowed to draw only once in testing mode

   static bool passed         = false;
   static double max_spread   = 0;
   static double min_spread   = EMPTY_VALUE;
   static double avg_spread   = 0;
   static double avg_add      = 0;
   static double avg_cnt      = 0;

   double current_spread = (SymbolInfoDouble(Symbol(),SYMBOL_ASK)-SymbolInfoDouble(Symbol(),SYMBOL_BID))/(CustomPoint(Symbol()));
   if (current_spread > max_spread) {max_spread = current_spread;}
   if (current_spread < min_spread) {min_spread = current_spread;}
   
   avg_cnt++;
   avg_add     = avg_add + current_spread;
   avg_spread  = avg_add / avg_cnt;

   int x=0; int y=0;
   string name;

   // create objects
   if (passed == false)
   {
      passed=true;
      
      name="fxd_spread_current_label";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+1);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 18);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "Spread:");
      }
      name="fxd_spread_max_label";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+17);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrOrangeRed);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "max:");
      }
      name="fxd_spread_avg_label";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+9);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "avg:");
      }
      name="fxd_spread_min_label";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+148);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrGold);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "min:");
      }
      name="fxd_spread_current";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+93);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 18);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "0");
      }
      name="fxd_spread_max";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+17);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrOrangeRed);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "0");
      }
      name="fxd_spread_avg";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+9);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkOrange);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "0");
      }
      name="fxd_spread_min";
      if (ObjectFind(0, name)==-1) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x+173);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y+1);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrGold);
         ObjectSetString(0, name, OBJPROP_FONT, "Arial");
         ObjectSetString(0, name, OBJPROP_TEXT, "min:");
      }
   }
   
   ObjectSetString(0, "fxd_spread_current", OBJPROP_TEXT, DoubleToStr(current_spread,2));
   ObjectSetString(0, "fxd_spread_max", OBJPROP_TEXT, DoubleToStr(max_spread,2));
   ObjectSetString(0, "fxd_spread_avg", OBJPROP_TEXT, DoubleToStr(avg_spread,2));
   ObjectSetString(0, "fxd_spread_min", OBJPROP_TEXT, DoubleToStr(min_spread,2));
}
string DrawStatus(string text="")
{
   static string memory;
   if (text=="") {
      return(memory);
   }
   
   static bool passed = false;
   int x=210; int y=0;
   string name;

   //-- draw the objects once
   if (passed == false)
   {
      passed = true;
      name="fxd_status_title";
      ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0,name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0,name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0,name, OBJPROP_YDISTANCE, y+17);
      ObjectSetString(0,name, OBJPROP_TEXT, "Status");
      ObjectSetString(0,name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0,name, OBJPROP_FONTSIZE, 7);
      ObjectSetInteger(0,name, OBJPROP_COLOR, clrGray);
      
      name="fxd_status_text";
      ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0,name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0,name, OBJPROP_XDISTANCE, x+2);
      ObjectSetInteger(0,name, OBJPROP_YDISTANCE, y+1);
      ObjectSetString(0,name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0,name, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0,name, OBJPROP_COLOR, clrAqua);
   }

   //-- update the text when needed
   if (text != memory) {
      memory=text;
      ObjectSetString(0,"fxd_status_text", OBJPROP_TEXT, text);
   }
   
   return(text);
}
double DynamicLots(string mode="balance", double value=0, double sl=0, string align="align", double RJFR_initial_lots=0)
{
   double size=0;
   string symbol=GetSymbol();
   double LotStep=MarketInfo(symbol,MODE_LOTSTEP);
   double LotSize=MarketInfo(symbol,MODE_LOTSIZE);
   double MinLots=MarketInfo(symbol,MODE_MINLOT);
   double MaxLots=MarketInfo(symbol,MODE_MAXLOT);
   double TickValue=MarketInfo(symbol,MODE_TICKVALUE);
   double point=MarketInfo(symbol,MODE_POINT);
   double ticksize=MarketInfo(symbol,MODE_TICKSIZE);
   double margin_required=MarketInfo(symbol,MODE_MARGINREQUIRED);
   
   if (mode=="fixed" || mode=="lots")     {size=value;}
   else if (mode=="block-equity")      {size=(value/100)*AccountEquity()/margin_required;}
   else if (mode=="block-balance")     {size=(value/100)*AccountBalance()/margin_required;}
   else if (mode=="block-freemargin")  {size=(value/100)*AccountFreeMargin()/margin_required;}
   else if (mode=="equity")      {size=(value/100)*AccountEquity()/(LotSize*TickValue);}
   else if (mode=="balance")     {size=(value/100)*AccountBalance()/(LotSize*TickValue);}
   else if (mode=="freemargin")  {size=(value/100)*AccountFreeMargin()/(LotSize*TickValue);}
   else if (mode=="equityRisk")     {size=((value/100)*AccountEquity())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
   else if (mode=="balanceRisk")    {size=((value/100)*AccountBalance())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
   else if (mode=="freemarginRisk") {size=((value/100)*AccountFreeMargin())/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
   else if (mode=="fixedRisk")   {size=(value)/(sl*((TickValue/ticksize)*point)*PipValue(symbol));}
   else if (mode=="fixedRatio" || mode=="RJFR") {
      
      /////
      // Ryan Jones Fixed Ratio MM static data
      static double RJFR_start_lots=0;
      static double RJFR_delta=0;
      static double RJFR_units=1;
      static double RJFR_target_lower=0;
      static double RJFR_target_upper=0;
      /////
      
      if (RJFR_start_lots<=0) {RJFR_start_lots=value;}
      if (RJFR_start_lots<MinLots) {RJFR_start_lots=MinLots;}
      if (RJFR_delta<=0) {RJFR_delta=sl;}
      if (RJFR_target_upper<=0) {
         RJFR_target_upper=AccountEquity()+(RJFR_units*RJFR_delta);
         Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Upper Target Equity=>",RJFR_target_upper);
      }
      if (AccountEquity()>=RJFR_target_upper)
      {
         while(true) {
            Print("Fixed Ratio MM going up to ",(RJFR_start_lots*(RJFR_units+1))," lots: Equity is above Upper Target Equity (",AccountEquity(),">=",RJFR_target_upper,")");
            RJFR_units++;
            RJFR_target_lower=RJFR_target_upper;
            RJFR_target_upper=RJFR_target_upper+(RJFR_units*RJFR_delta);
            Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Lower Target Equity=>",RJFR_target_lower,"; Upper Target Equity=>",RJFR_target_upper);
            if (AccountEquity()<RJFR_target_upper) {break;}
         }
      }
      else if (AccountEquity()<=RJFR_target_lower)
      {
         while(true) {
         if (AccountEquity()>RJFR_target_lower) {break;}
            if (RJFR_units>1) {         
               Print("Fixed Ratio MM going down to ",(RJFR_start_lots*(RJFR_units-1))," lots: Equity is below Lower Target Equity | ", AccountEquity()," <= ",RJFR_target_lower,")");
               RJFR_target_upper=RJFR_target_lower;
               RJFR_target_lower=RJFR_target_lower-((RJFR_units-1)*RJFR_delta);
               RJFR_units--;
               Print("Fixed Ratio MM: Units=>",RJFR_units,"; Delta=",RJFR_delta,"; Lower Target Equity=>",RJFR_target_lower,"; Upper Target Equity=>",RJFR_target_upper);
            } else {break;}
         }
      }
      size=RJFR_start_lots*RJFR_units;
   }
   
   size=MathRound(size/LotStep)*LotStep;
   
   static bool alert_min_lots=false;
   if (size<MinLots && alert_min_lots==false) {
      alert_min_lots=true;
      Alert("You want to trade ",size," lot, but your broker's minimum is ",MinLots," lot. The trade/order will continue with ",MinLots," lot instead of ",size," lot. The same rule will be applied for next trades/orders with desired lot size lower than the minimum. You will not see this message again until you restart the program.");
   }
   
   if (align=="align") {
      if (size<MinLots) {size=MinLots;}
      if (size>MaxLots) {size=MaxLots;}
   }
   
   return (size);
}
double e_attrClosePrice(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
datetime e_attrCloseTime(bool set=false, datetime inp=-1) {static datetime mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
string e_attrComment(bool set=false, string inp="") {static string mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
double e_attrCommission(bool set=false, double inp=0) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
datetime e_attrExpiration(bool set=false, datetime inp=0) {static datetime mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
double e_attrLots(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
int e_attrMagicNumber(bool set=false, int inp=-1) {static int mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
double e_attrOpenPrice(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
datetime e_attrOpenTime(bool set=false, datetime inp=-1) {static datetime mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
double e_attrProfit(bool set=false, double inp=0) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
double e_attrStopLoss(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
double e_attrSwap(bool set=false, double inp=0) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
string e_attrSymbol(bool set=false, string inp="") {static string mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
double e_attrTakeProfit(bool set=false, double inp=-1) {static double mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
int e_attrTicket(bool set=false, int inp=-1) {static int mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
int e_attrType(bool set=false, int inp=-1) {static int mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
string e_Reason(bool set=false, string inp="") {
   static string mem[];
   int queue=OnTradeQueue()-1;
   if(set==true){
      ArrayResize(mem,queue+1);
      mem[queue]=inp;
   }
   return(mem[queue]);
}
string e_ReasonDetail(bool set=false, string inp="") {static string mem[];int queue=OnTradeQueue()-1;if(set==true){ArrayResize(mem,queue+1);mem[queue]=inp;}return(mem[queue]);}
string ErrorMessage(int error_code=-1)
{
   if (error_code<0) {error_code=GetLastError();}
   string error_string="";

   switch(error_code)
     {
      //-- codes returned from trade server
      case 0:   return("");
      case 1:   error_string="No error returned"; break;
      case 2:   error_string="Common error"; break;
      case 3:   error_string="Invalid trade parameters"; break;
      case 4:   error_string="Trade server is busy"; break;
      case 5:   error_string="Old version of the client terminal"; break;
      case 6:   error_string="No connection with trade server"; break;
      case 7:   error_string="Not enough rights"; break;
      case 8:   error_string="Too frequent requests"; break;
      case 9:   error_string="Malfunctional trade operation (never returned error)"; break;
      case 64:  error_string="Account disabled"; break;
      case 65:  error_string="Invalid account"; break;
      case 128: error_string="Trade timeout"; break;
      case 129: error_string="Invalid price"; break;
      case 130: error_string="Invalid Sl or TP"; break;
      case 131: error_string="Invalid trade volume"; break;
      case 132: error_string="Market is closed"; break;
      case 133: error_string="Trade is disabled"; break;
      case 134: error_string="Not enough money"; break;
      case 135: error_string="Price changed"; break;
      case 136: error_string="Off quotes"; break;
      case 137: error_string="Broker is busy (never returned error)"; break;
      case 138: error_string="Requote"; break;
      case 139: error_string="Order is locked"; break;
      case 140: error_string="Only long trades allowed"; break;
      case 141: error_string="Too many requests"; break;
      case 145: error_string="Modification denied because order too close to market"; break;
      case 146: error_string="Trade context is busy"; break;
      case 147: error_string="Expirations are denied by broker"; break;
      case 148: error_string="Amount of open and pending orders has reached the limit"; break;
      case 149: error_string="Hedging is prohibited"; break;
      case 150: error_string="Prohibited by FIFO rules"; break;
      //-- mql4 errors
      case 4000: error_string="No error"; break;
      case 4001: error_string="Wrong function pointer"; break;
      case 4002: error_string="Array index is out of range"; break;
      case 4003: error_string="No memory for function call stack"; break;
      case 4004: error_string="Recursive stack overflow"; break;
      case 4005: error_string="Not enough stack for parameter"; break;
      case 4006: error_string="No memory for parameter string"; break;
      case 4007: error_string="No memory for temp string"; break;
      case 4008: error_string="Not initialized string"; break;
      case 4009: error_string="Not initialized string in array"; break;
      case 4010: error_string="No memory for array string"; break;
      case 4011: error_string="Too long string"; break;
      case 4012: error_string="Remainder from zero divide"; break;
      case 4013: error_string="Zero divide"; break;
      case 4014: error_string="Unknown command"; break;
      case 4015: error_string="Wrong jump"; break;
      case 4016: error_string="Not initialized array"; break;
      case 4017: error_string="dll calls are not allowed"; break;
      case 4018: error_string="Cannot load library"; break;
      case 4019: error_string="Cannot call function"; break;
      case 4020: error_string="Expert function calls are not allowed"; break;
      case 4021: error_string="Not enough memory for temp string returned from function"; break;
      case 4022: error_string="System is busy"; break;
      case 4050: error_string="Invalid function parameters count"; break;
      case 4051: error_string="Invalid function parameter value"; break;
      case 4052: error_string="String function internal error"; break;
      case 4053: error_string="Some array error"; break;
      case 4054: error_string="Incorrect series array using"; break;
      case 4055: error_string="Custom indicator error"; break;
      case 4056: error_string="Arrays are incompatible"; break;
      case 4057: error_string="Global variables processing error"; break;
      case 4058: error_string="Global variable not found"; break;
      case 4059: error_string="Function is not allowed in testing mode"; break;
      case 4060: error_string="Function is not confirmed"; break;
      case 4061: error_string="Send mail error"; break;
      case 4062: error_string="String parameter expected"; break;
      case 4063: error_string="Integer parameter expected"; break;
      case 4064: error_string="Double parameter expected"; break;
      case 4065: error_string="Array as parameter expected"; break;
      case 4066: error_string="Requested history data in update state"; break;
      case 4099: error_string="End of file"; break;
      case 4100: error_string="Some file error"; break;
      case 4101: error_string="Wrong file name"; break;
      case 4102: error_string="Too many opened files"; break;
      case 4103: error_string="Cannot open file"; break;
      case 4104: error_string="Incompatible access to a file"; break;
      case 4105: error_string="No order selected"; break;
      case 4106: error_string="Unknown symbol"; break;
      case 4107: error_string="Invalid price parameter for trade function"; break;
      case 4108: error_string="Invalid ticket"; break;
      case 4109: error_string="Trade is not allowed in the expert properties"; break;
      case 4110: error_string="Longs are not allowed in the expert properties"; break;
      case 4111: error_string="Shorts are not allowed in the expert properties"; break;
      case 4200: error_string="Object is already exist"; break;
      case 4201: error_string="Unknown object property"; break;
      case 4202: error_string="Object is not exist"; break;
      case 4203: error_string="Unknown object type"; break;
      case 4204: error_string="No object name"; break;
      case 4205: error_string="Object coordinates error"; break;
      case 4206: error_string="No specified subwindow"; break;
      case 4207: error_string="Some error in object function"; break;
      default:   error_string="Unknown error";
     }

   //if (error_code>0) {Print("("+error_code+") "+error_string);}
   error_string=StringConcatenate(error_string," ("+error_code+")");
   return(error_string);
}
void ExpirationDriver()
{
   static int last_checked_ticket;
   static int db_tickets[];
   static int db_expirations[];

   static int total; total   = OrdersTotal();
   static int size;  size    = 0;
   static int do_reset; do_reset=false;
   static string print;
   static int i;
   
   //-- check expirations and close trades
   size = ArraySize(db_tickets);
   if (size>0)
   {
      if (total==0) {
         ArrayResize(db_tickets, 0);
         ArrayResize(db_expirations, 0);
      }
      else
      {
         for (i=0; i<size; i++)
         {
            WaitTradeContextIfBusy();
            if (!OrderSelect(db_tickets[i],SELECT_BY_TICKET, MODE_TRADES)) {continue;}
            if (OrderSymbol() != Symbol()) {continue;}
            
            if (TimeCurrent() >= OrderOpenTime()+db_expirations[i]) {
               
               //-- trying to skip conflicts with the same functionality running from neighbour EA
               WaitTradeContextIfBusy();
               if (!OrderSelect(db_tickets[i],SELECT_BY_TICKET, MODE_TRADES)) {continue;}
               if (OrderCloseTime()>0) {continue;}
               
               //-- closing the trade
               if (CloseTrade(OrderTicket())) 
               {
                  print = "#"+(string)OrderTicket()+" was closed due to expiration";
                  Print(print);
                  last_checked_ticket=0;
                  do_reset = true;
                  total    = OrdersTotal();
               }
            }
         }
      }
   }
   
   //-- check the ticket of the newest trade
   if (do_reset==false && total>0)
   {
      if (OrderSelect(total-1,SELECT_BY_POS)) {
         if (OrderTicket()!=last_checked_ticket) {
            do_reset = true;
         }
      }
   }

   //-- rebuild the database of trades with expirations
   if (do_reset==true)
   {
      static string comment;
      ArrayResize(db_tickets, 0);
      ArrayResize(db_expirations, 0);
      for (int pos=0; pos<total; pos++)
      {
         if (!OrderSelect(pos,SELECT_BY_POS)) {continue;}
         last_checked_ticket = OrderTicket();

         comment = OrderComment();
         int exp_pos_begin = StringFind(comment, "[exp:");
         if (exp_pos_begin >= 0)
         {
            exp_pos_begin = exp_pos_begin+5;
            int exp_pos_end = StringFind(comment, "]", exp_pos_begin);
            if (exp_pos_end == -1) {continue;}
            
            size = ArraySize(db_tickets);
            ArrayResize(db_tickets, size+1);
            ArrayResize(db_expirations, size+1);
            db_tickets[size]     = OrderTicket();
            db_expirations[size] = StringToInteger(StringSubstr(comment, exp_pos_begin, exp_pos_end));
         }
      }
   }
}
datetime ExpirationTime(string mode="GTC",int days=0, int hours=0, int minutes=0, datetime custom=0)
{
	datetime expiration=TimeCurrent();
   if (mode=="GTC" || mode=="")   {expiration=0;}
   else if (mode=="today") {expiration=StrToTime(TimeYear(TimeCurrent())+"."+TimeMonth(TimeCurrent())+"."+TimeDay(TimeCurrent()))+86400;}
   else if (mode=="specified") {
      expiration=0;
      if ((days + hours + minutes)>0) {
         expiration=TimeCurrent()+(86400*days)+(3600*hours)+(60*minutes);
      }
   }
   else
   {
      if (custom <= TimeCurrent()) {
         if (custom < 31557600) {
            custom = TimeCurrent()+custom;
         }
         else {
            custom=0;
         }
      }
      expiration = custom;
   }
   return(expiration);
}
string GetSymbol(string symbol="")
{
   static string memory="";
   if (symbol=="") {
      if (memory=="") {memory=Symbol();}
   }
   else {memory=symbol;}
   return(memory);
}
int iCandleID(string SYMBOL, int TIMEFRAME, datetime time_stamp)
{
   bool TimeStampPrevDayShift = true;
   int CandleID = 0;
   //== calculate candle ID
   //-- get the time resolution of the desired period, in minutes
   int mins_tf = TIMEFRAME;
   int mins_tf0 = 0;
   if (TIMEFRAME == PERIOD_CURRENT)
   {
      //-- calculate the current period minutes
      //-- we need to calculate the difference in time between 2 candles
      // but because we have holidays, we will compare 2 neighbour candles until we get the same time difference
      int i=0;   
      while(true)
      {
         mins_tf = (int)(iTime(SYMBOL, TIMEFRAME, i) - iTime(SYMBOL, TIMEFRAME, i+1));
   
         if (mins_tf0 == mins_tf) {break;}
         mins_tf0 = mins_tf;
         i++;
      }
      mins_tf = mins_tf / 60;
   }
   
   //-- get the difference between now and the time we want, in minutes
   //int time_stamp = StrToTime(TimeStamp);
   int days_adjust = 0;
   if (TimeStampPrevDayShift)
   {
      //-- automatically shift to the previous day
      if (time_stamp > TimeCurrent())
      {
         time_stamp = time_stamp - 86400;
      }
      //-- also shift weekdays
      while (true)
      {
         int dow = TimeDayOfWeek(time_stamp);
         
         if (dow > 0 && dow < 6) {break;}
         time_stamp = time_stamp - 86400;
         days_adjust++;
      }
   }
   
   int mins_diff = (int)(TimeCurrent() - time_stamp);
   mins_diff = mins_diff - days_adjust*86400;
   mins_diff = mins_diff / 60;
   
   //-- the difference is negative => quit here
   if (mins_diff < 0) {return (int)EMPTY_VALUE;}
   
   //-- now calculate the candle ID, it is relative to the current time
   CandleID = (int)MathCeil((double)mins_diff/(double)mins_tf);
   
   //Print(TimeToStr(TimeCurrent())+" "+TimeToStr(time_stamp) +" ::: " + mins_tf + " " + days_adjust + " " + (days_adjust*1440/mins_tf) + " " + CandleID);
   
   
   //-- now, after all the shifting and in case of missing candles, the calculated candle id can be few candles early
   // so we will search for the right candle
   while(true)
   {
      if (iTime(SYMBOL, TIMEFRAME, CandleID) >= time_stamp) {break;}
      
      CandleID--;
   }
   
   return CandleID;
   
   /*
   // this method does the same, but it is slower
   
   if (0)
   {
      CandleID = 0;
      datetime t = StrToTime(TimeStamp);
      datetime now = TimeCurrent();
      datetime ctime;
      while(true)
      {
         ctime = iTime(SYMBOL, TIMEFRAME, CandleID);
         //
         if (ctime < t)
         {
            //-- if the time is still in the future, we will shift to a previous day
            if (t > now)
            {
               if (TimeStampPrevDayShift)
               {
                  //-- shift to the last day that is not sat/sun
                  while(true)
                  {
                     t = t - 86400;
                     int dow = TimeDayOfWeek(t);
                     if (dow > 0 && dow < 6) {break;}
                  }
                  continue;
               }
               return EMPTY_VALUE;
            }
            break;
         }
         CandleID++;
      }
   }
   
   */
}
bool InArray(double &array[], double value)
{
   bool founded=false;
   int size=ArraySize(array);
   for (int i=0; i<size; i++) {
      if (array[i]==value) {founded=true; break;}  
   }
   return (founded);
}
bool InArray(int &array[], int value)
{
   bool founded=false;
   int size=ArraySize(array);
   for (int i=0; i<size; i++) {
      if (array[i]==value) {founded=true; break;}  
   }
   return (founded);
}
bool InArray(string &array[], string value)
{
   bool founded=false;
   int size=ArraySize(array);
   for (int i=0; i<size; i++) {
      if (array[i]==value) {founded=true; break;}  
   }
   return (founded);
}
int IndicatorMoreShift(bool set=false, int shift=0)
{
	static int mem;
   if (set==true) {mem=shift;}
   else {
      int return_val=mem; mem=0; // reset
      return(return_val);
   }
   return(mem);
}
int LastIndicatorShift(bool set=false, int shift=0)
{
   static int mem;
   if (set==true) {mem=shift;}
   return(mem);
}
string LastIndicatorSymbol(bool set=false, string symbol="")
{
	static string mem;
   if (set==true) {mem=symbol;}
   return(mem);
}
int LastIndicatorTimeframe(bool set=false, int timeframe=0)
{
   static int mem;
   if (set==true) {mem=timeframe;}
   return(mem);
}
double LastIndicatorValue(bool set=false, double value=0)
{
   static double mem;
   if (set==true) {mem=value;}
   return(mem);
}
bool ModifyOrder(
   int ticket,
   double op,
   double sll=0,
   double tpl=0,
   double slp=0,
   double tpp=0,
   datetime exp=0,
   color clr=CLR_NONE,
   bool ontrade_event=true)
{
//-----------------------------------------------------------------------
   int bs=1;
   if (
         OrderType()==OP_SELL
      || OrderType()==OP_SELLSTOP
      || OrderType()==OP_SELLLIMIT
      )
   {bs=-1;} // Positive when Buy, negative when Sell

   while(true)
   {
      int time0=GetTickCount();
      
      WaitTradeContextIfBusy();
      
      if (!OrderSelect(ticket,SELECT_BY_TICKET)) {
         return(false);
      }
      
      string symbol     =OrderSymbol();
      int type          =OrderType();
      double ask        =MarketInfo(symbol,MODE_ASK);
      double bid        =MarketInfo(symbol,MODE_BID);
      double digits     =MarketInfo(symbol,MODE_DIGITS);
      double point      =MarketInfo(symbol,MODE_POINT);
      
      if (OrderType()<2) {op=OrderOpenPrice();} else {op=NormalizeDouble(op,digits);}
      sll=NormalizeDouble(sll,digits);
      tpl=NormalizeDouble(tpl,digits);
      if (op<0 || op>=EMPTY_VALUE)  {break;}
      if (sll<0) {break;}
      if (slp<0) {break;}
      if (tpl<0) {break;}
      if (tpp<0) {break;}
      
      //-- SL and TP ----------------------------------------------------
      double sl=0, tp=0, vsl=0, vtp=0;
      sl=AlignStopLoss(symbol, type, op, sll, slp);
      if (sl<0) {break;}
      tp=AlignTakeProfit(symbol, type, op, tpl, tpp);
      if (tp<0) {break;}
      
      if (USE_VIRTUAL_STOPS)
      {
         //-- virtual SL and TP --------------------------------------------
         vsl=sl;
         vtp=tp;
         sl=0; tp=0;
      
         double askbid=ask;
         if (bs<0) {askbid=bid;}
         
         if (vsl>0 || USE_EMERGENCY_STOPS=="always") {
            if (EMERGENCY_STOPS_REL>0 || EMERGENCY_STOPS_ADD>0)
            {
               sl=vsl-EMERGENCY_STOPS_REL*MathAbs(askbid-vsl)*bs;
               if (sl<=0) {sl=askbid;}
               sl=sl-toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
            }
         }
         if (vtp>0 || USE_EMERGENCY_STOPS=="always") {
            if (EMERGENCY_STOPS_REL>0 || EMERGENCY_STOPS_ADD>0)
            {
               tp=vtp+EMERGENCY_STOPS_REL*MathAbs(vtp-askbid)*bs;
               if (tp<=0) {tp=askbid;}
               tp=tp+toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
            }
         }
         vsl=NormalizeDouble(vsl,digits);
         vtp=NormalizeDouble(vtp,digits);
      }
      sl=NormalizeDouble(sl,digits);
      tp=NormalizeDouble(tp,digits);

      //-- modify -------------------------------------------------------
      if (USE_VIRTUAL_STOPS) {
         if (vsl!=attrStopLoss() || vtp!=attrTakeProfit()) {
            VirtualStopsDriver("set", ticket, vsl, vtp, toPips(MathAbs(op-vsl), symbol), toPips(MathAbs(vtp-op), symbol));
         }
         int error=GetLastError();
      }
      bool success=false;
      //Print(op+"!=+"+NormalizeDouble(OrderOpenPrice(),digits));
      if (
            (OrderType()>1 && op!=NormalizeDouble(OrderOpenPrice(),digits))
         || sl!=NormalizeDouble(OrderStopLoss(),digits)
         || tp!=NormalizeDouble(OrderTakeProfit(),digits)
         || exp!=OrderExpiration()
      ) {
         success=OrderModify(ticket,op,sl,tp,exp,clr);
      }
         
      //-- error check --------------------------------------------------
      int erraction=CheckForTradingError(GetLastError(), "Modify error");
      switch(erraction)
      {
         case 0: break;    // no error
         case 1: continue; // overcomable error
         case 2: break;    // fatal error
      }
      
      //-- finish work --------------------------------------------------
      if (success==true) {
         if (!IsTesting() && !IsVisualMode()) Print("Operation details: Speed "+(GetTickCount()-time0)+" ms");
         if (ontrade_event == true)
         {
            OrderModified(ticket);
            RegisterEvent("trade");
         }
         if (OrderSelect(ticket,SELECT_BY_TICKET)) {}
         return(true);
      }
      
      break;
   }

   return(false);
}
int OCODriver()
{
	static int last_known_ticket = 0;
   static int orders1[];
   static int orders2[];
   int i, size;
   
   int total = OrdersTotal();
   
   for (int pos=total-1; pos>=0; pos--)
   {
      if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
      {
         int ticket = OrderTicket();
         
         //-- end here if we reach the last known ticket
         if (ticket == last_known_ticket) {break;}
         
         //-- set the last known ticket, only if this is the first iteration
         if (pos == total-1) {
            last_known_ticket = ticket;
         }
         
         //-- we are searching for pending orders, skip trades
         if (OrderType() <= OP_SELL) {continue;}
         
         //--
         if (StringSubstr(OrderComment(), 0, 5) == "[oco:")
         {
            int ticket_oco = StrToInteger(StringSubstr(OrderComment(), 5, StringLen(OrderComment())-1)); 
            
            bool found = false;
            size = ArraySize(orders2);
            for (i=0; i<size; i++)
            {
               if (orders2[i] == ticket_oco) {
                  found = true;
                  break;
               }
            }
            
            if (found == false) {
               ArrayResize(orders1, size+1);
               ArrayResize(orders2, size+1);
               orders1[size] = ticket_oco;
               orders2[size] = ticket;
            }
         }
      }
   }
   
   size = ArraySize(orders1);
   int dbremove = false;
   for (i=0; i<size; i++)
   {
      if (OrderSelect(orders1[i], SELECT_BY_TICKET, MODE_TRADES) == false || OrderType() <= OP_SELL)
      {
         if (OrderSelect(orders2[i], SELECT_BY_TICKET, MODE_TRADES)) {
            if (DeleteOrder(orders2[i],clrWhite))
            {
               dbremove = true;
            }
         }
         else {
            dbremove = true;
         }
         
         if (dbremove == true)
         {
            ArrayStripKey(orders1, i);
            ArrayStripKey(orders2, i);
         }
      }
   }
   
   size = ArraySize(orders2);
   dbremove = false;
   for (i=0; i<size; i++)
   {
      if (OrderSelect(orders2[i], SELECT_BY_TICKET, MODE_TRADES) == false || OrderType() <= OP_SELL)
      {
         if (OrderSelect(orders1[i], SELECT_BY_TICKET, MODE_TRADES)) {
            if (DeleteOrder(orders1[i],clrWhite))
            {
               dbremove = true;
            }
         }
         else {
            dbremove = true;
         }
         
         if (dbremove == true)
         {
            ArrayStripKey(orders1, i);
            ArrayStripKey(orders2, i);
         }
      }
   }
   
   return true;
}
bool OnTimerSet(double seconds)
{
   if (FXD_ONTIMER_TAKEN)
   {
      if (seconds<=0) {
         FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
         FXD_ONTIMER_TAKEN_TIME = 0;
      }
      else if (seconds < 1) {
         FXD_ONTIMER_TAKEN_IN_MILLISECONDS = true;
         FXD_ONTIMER_TAKEN_TIME = seconds*1000; 
      }
      else {
         FXD_ONTIMER_TAKEN_IN_MILLISECONDS = false;
         FXD_ONTIMER_TAKEN_TIME = seconds;
      }
      
      return true;
   }

   if (seconds<=0) {
      EventKillTimer();
   }
   else if (seconds < 1) {
      return (EventSetMillisecondTimer((int)(seconds*1000)));  
   }
   else {
      return (EventSetTimer((int)seconds));
   }
   
   return true;
}
void OnTradeListener()
{
   if (!ENABLE_EVENT_TRADE) {return;}

   int i=-1, j=-1, k=-1; int ti=-1; int ty=-1;
   int size=-1;
   static int start_time=-1;
  
   int pos=0;
   
   if (start_time==-1) {start_time=TimeCurrent();}

   string e_reason="";
   string e_detail="";
   
   ///////
   // TRADES AND ORDERS
   int tickets_now[]; ArrayResize(tickets_now,0);
   int tn=0;
   static int    memory_ti[];
   static int    memory_ty[];
   static double memory_sl[];
   static double memory_tp[];
   static double memory_vl[];
   static bool loaded=false;
   
   int total=OrdersTotal();
   
   // initial fill of the local DB
   if (loaded==false)
   {
      loaded=true;
      for (pos=total-1; pos>=0; pos--)
      {
         if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
         {
            ArrayResize(memory_ti,tn+1);
            ArrayResize(memory_ty,tn+1);
            ArrayResize(memory_sl,tn+1);
            ArrayResize(memory_tp,tn+1);
            ArrayResize(memory_vl,tn+1);
            memory_ti[tn]=OrderTicket();
            memory_ty[tn]=OrderType();
            memory_sl[tn]=attrStopLoss();
            memory_tp[tn]=attrTakeProfit();
            memory_vl[tn]=OrderLots();
            tn++;
         }
      }
      return;
   }
   tn=0;
   
   bool pending_opens=false;
   
   for (pos=total-1; pos>=0; pos--)
   {
      if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
      {
         ArrayResize(tickets_now,tn+1);
         tickets_now[tn]=OrderTicket();
         tn++;
         
         // Trades and Orders
         i=-1; ti=-1; ty=-1; size=ArraySize(memory_ti);
         
         if (size>0)
         {
           for (i=0; i<size; i++)
           {
              if (memory_ti[i]==OrderTicket())
              {
                 if (memory_ty[i]==OrderType()) {
                    ty=OrderType();
                  }
                  else {
                     pending_opens=true;
                  }
                  ti=OrderTicket(); break;
              }
           }
         }

         // Order become a trade
         if (ti>0 && ty<0)
         {
            memory_ti[i]=OrderTicket();
            memory_ty[i]=OrderType();
           
            memory_sl[i]=attrStopLoss();
            memory_tp[i]=attrTakeProfit();
            memory_vl[i]=OrderLots();
            e_reason="new";
            e_detail="";
            break;
         }

         // New trade/order opened
         else if (ti<0 && ty<0)
         {
            ArrayResize(memory_ti,size+1); memory_ti[size]=OrderTicket();
            ArrayResize(memory_ty,size+1); memory_ty[size]=OrderType();
            ArrayResize(memory_sl,size+1); memory_sl[size]=attrStopLoss();
            ArrayResize(memory_tp,size+1); memory_tp[size]=attrTakeProfit();
            ArrayResize(memory_vl,size+1); memory_vl[size]=OrderLots();
            e_reason="new";
            e_detail="";
            break;
         }
         
         // Check for Lots, SL or TP modification
         else if (ty>=0 && i>-1) {
            if (memory_vl[i]!=OrderLots())
            {
               memory_vl[i]=OrderLots();
               e_reason="modify";
               e_detail="lots";
               break;
            }
            else {
               if (memory_sl[i]!=attrStopLoss())   {memory_sl[i]=attrStopLoss(); e_reason="modify"; e_detail="sl"; break;}
               if (memory_tp[i]!=attrTakeProfit()) {memory_tp[i]=attrTakeProfit(); e_reason="modify"; if (e_detail=="sl") {e_detail="sltp";} else {e_detail="tp";} break;}
            }
         }
      }
   }
   
   // Check for closed orders/trades
   bool missing=true;
   if (e_reason=="" && pending_opens==false && ArraySize(tickets_now)<ArraySize(memory_ti))
   {
      for(i=ArraySize(memory_ti)-1; i>=0; i--) { // for each ticket in the memory...
         for(j=0; j<=ArraySize(tickets_now); j++) { // check if trade exists now
            if (memory_ti[i]==tickets_now[j]) {missing=false; break;}
         }
         if (missing==true) {
            if (OrderSelect(memory_ti[i],SELECT_BY_TICKET))
            {
               // This can happen more than once
               ArrayStripKey(memory_ti,i);
               ArrayStripKey(memory_ty,i);
               ArrayStripKey(memory_sl,i);
               ArrayStripKey(memory_tp,i);
               ArrayStripKey(memory_vl,i);
               
               e_reason="closed";
               e_detail="";
               break;
            }
         }
         missing=true;
      }
   }
   // TRADES AND ORDERS
   ///////
   
   if (e_reason!="") {
      UpdateEventValues(e_reason,e_detail);
      EventTrade();
      OnTradeListener();
      if (USE_VIRTUAL_STOPS && e_reason=="closed") {
         ObjectDelete("#"+OrderTicket()+" sl");
         ObjectDelete("#"+OrderTicket()+" tp");
      }
      return;
   }
}
int OnTradeQueue(int queue=0)
{
   static int mem=0;
   mem=mem+queue;
   return(mem);
}
int OrderCreate(
   string symbol="",
   int    type=OP_BUY,
   double lots=0,
   double op=0,
   double sll=0, // SL level
   double tpl=0, // TO level
   double slp=0, // SL adjust in points
   double tpp=0, // TP adjust in points
   double slippage=0,
   int    magic=0,
   string comment="",
   color  arrowcolor=CLR_NONE,
   datetime expiration=0,
   bool oco = false
   )
{
   int time0=GetTickCount();
   
   int ticket=-1;
   int bs=1;
   if (
         type==OP_SELL
      || type==OP_SELLSTOP
      || type==OP_SELLLIMIT
      ) {bs=-1;} // Positive when Buy, negative when Sell
   
   if (symbol=="") {symbol=Symbol();}

   lots=AlignLots(lots);
   
   int digits = 0;
   double ask=0, bid=0, point=0;
   double sl=0, tp=0;

   //-- attempt to send trade/order -------------------------------------
   while(true)
   {
      //Print(sll+" "+tpl+" "+slp+" "+tpp);
      WaitTradeContextIfBusy();
      
      static bool not_allowed_message = false;
      if (!MQLInfoInteger(MQL_TESTER) && !MarketInfo(symbol, MODE_TRADEALLOWED)) {
         if (not_allowed_message == false) {
            Print("Market ("+symbol+") is closed");
         }
         not_allowed_message = true;
         return(false);
      }
      not_allowed_message = false;
      
      digits     = MarketInfo(symbol,MODE_DIGITS);
      ask     = MarketInfo(symbol,MODE_ASK);
      bid     = MarketInfo(symbol,MODE_BID);
      point   = MarketInfo(symbol,MODE_POINT);
      
      //- not enough money check: fix maximum possible lot by margin required, or quit
      if (type==OP_BUY || type==OP_SELL)
      {
         double LotStep          = MarketInfo(symbol,MODE_LOTSTEP);
         double MinLots          = MarketInfo(symbol,MODE_MINLOT);
         double margin_required  = MarketInfo(symbol,MODE_MARGINREQUIRED);
         static bool not_enough_message = false;
         
         if (margin_required != 0)
         {
            double max_size_by_margin = AccountFreeMargin()/margin_required;
         
            if (lots > max_size_by_margin) {
               double size_old = lots;
               lots = max_size_by_margin;
               if (lots<MinLots)
               {
                  if (not_enough_message==false) {
                     Print("Not enough money to trade :( The robot is still working, waiting for some funds to appear...");
                  }
                  not_enough_message = true;
                  return(false);
               }
               else
               {
                  lots = MathFloor(lots/LotStep)*LotStep;
                  Print("Not enough money to trade "+DoubleToString(size_old, 2)+", the volume to trade will be the maximum possible of "+DoubleToString(lots, 2));
               }
            }
         }
         not_enough_message = false;
      }
      
      //- expiration for trades
      if (type==OP_BUY || type==OP_SELL)
      {
         if (expiration > 0)
         {
            //- convert UNIX to seconds
            if (expiration > TimeCurrent()-100) {
               expiration = expiration - TimeCurrent();
            }
            
            //- bo broker?
            if (StringLen(symbol)>6 && StringSubstr(symbol, StringLen(symbol)-2=="bo")) {
               comment = "BO exp:"+expiration;
            }
            else {
               string expiration_str   = "[exp:"+IntegerToString(expiration)+"]";
               int expiration_len      = StringLen(expiration_str);
               int comment_len         = StringLen(comment);
               if (comment_len > (27-expiration_len))
               {
                  comment = StringSubstr(comment, 0, (27-expiration_len));
               }
               comment = comment + expiration_str;
            }
         }
      }

      if (type==OP_BUY || type==OP_SELL)
      {
         op=ask;
         if (bs<0) {
           op=bid;
         }
      }
      
      op    = NormalizeDouble(op, digits);
      sll   = NormalizeDouble(sll,digits);
      tpl   = NormalizeDouble(tpl,digits);
      if (op<0 || op>=EMPTY_VALUE)  {break;}
      if (sll<0 || slp<0 || tpl<0 || tpp<0) {break;}

      //-- SL and TP ----------------------------------------------------
      double vsl=0, vtp=0;
      
      sl=AlignStopLoss(symbol, type, op, NormalizeDouble(sll,digits), slp);
      if (sl<0) {break;}
      tp=AlignTakeProfit(symbol, type, op, NormalizeDouble(tpl,digits), tpp);
      if (tp<0) {break;}
      
      if (USE_VIRTUAL_STOPS)
      {
         //-- virtual SL and TP --------------------------------------------
         vsl=sl;
         vtp=tp;
         sl=0; tp=0;
         
         double askbid=ask;
         if (bs<0) {askbid=bid;}
         
         if (vsl>0 || USE_EMERGENCY_STOPS=="always") {
            if (EMERGENCY_STOPS_REL>0 || EMERGENCY_STOPS_ADD>0)
            {
               sl=vsl-EMERGENCY_STOPS_REL*MathAbs(askbid-vsl)*bs;
               if (sl<=0) {sl=askbid;}
               sl=sl-toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
            }
         }
         if (vtp>0 || USE_EMERGENCY_STOPS=="always") {
            if (EMERGENCY_STOPS_REL>0 || EMERGENCY_STOPS_ADD>0)
            {
               tp=vtp+EMERGENCY_STOPS_REL*MathAbs(vtp-askbid)*bs;
               if (tp<=0) {tp=askbid;}
               tp=tp+toDigits(EMERGENCY_STOPS_ADD,symbol)*bs;
            }
         }
         vsl=NormalizeDouble(vsl,digits);
         vtp=NormalizeDouble(vtp,digits);
      }
      
      sl=NormalizeDouble(sl,digits);
      tp=NormalizeDouble(tp,digits);

      //-- fix expiration for pending orders ----------------------------
      if (expiration>0 && type>OP_SELL) {
         if ((expiration-TimeCurrent())<(11*60)) {
            Print("Expiration time cannot be less than 11 minutes, so it was automatically modified to 11 minutes.");
            expiration=TimeCurrent()+(11*60);
         }
      }

      //-- send ---------------------------------------------------------
      ResetLastError();
      ticket = OrderSend(symbol,type,lots,op,slippage*PipValue(symbol),sl,tp,comment,magic,expiration,arrowcolor);

      //-- error check --------------------------------------------------
      string msg_prefix="New trade error";
      if (type>OP_SELL) {msg_prefix="New order error";}
      int erraction=CheckForTradingError(GetLastError(), msg_prefix);
      switch(erraction)
      {
         case 0: break;    // no error
         case 1: continue; // overcomable error
         case 2: break;    // fatal error
      }
      
      //-- finish work --------------------------------------------------
      if (ticket>0) {
         if (USE_VIRTUAL_STOPS) {
            VirtualStopsDriver("set", ticket, vsl, vtp, toPips(MathAbs(op-vsl), symbol), toPips(MathAbs(vtp-op), symbol));
         }
         
         //-- show some info
         double slip=0;
         if (OrderSelect(ticket,SELECT_BY_TICKET)) {
            if (!IsTesting() && !IsVisualMode() &&!IsOptimization()) {
               slip=OrderOpenPrice()-op;
               Print(StringConcatenate(
                  "Operation details: Speed ",
                  (GetTickCount()-time0),
                  " ms | Slippage ",
                  DoubleToStr(toPips(slip, symbol),1),
                  " pips"
               ));
            }
         }
         
         //-- fix stops in case of slippage
         if (!IsTesting() && !IsVisualMode() &&!IsOptimization())
         {
            slip = NormalizeDouble(OrderOpenPrice(), digits) - NormalizeDouble(op, digits);
            if (slip != 0 && (OrderStopLoss()!=0 || OrderTakeProfit()!=0))
            {
               Print("Correcting stops because of slippage...");
               sl = OrderStopLoss();
               tp = OrderTakeProfit();
               if (sl != 0 || tp != 0)
               {
                  if (sl != 0) {sl = NormalizeDouble(OrderStopLoss()+slip, digits);}
                  if (tp != 0) {tp = NormalizeDouble(OrderTakeProfit()+slip, digits);}
                  ModifyOrder(ticket, OrderOpenPrice(), sl, tp, 0, 0, 0, CLR_NONE, false);
               }
            }
         }
         
         RegisterEvent("trade");
         break;
      }
      
      break;
   }
   
   if (oco == true && ticket > 0)
   {
      if (USE_VIRTUAL_STOPS) {
         sl = vsl;
         tp = vtp;
      }
      
      sl = NormalizeDouble(MathAbs(op-sl), digits);
      tp = NormalizeDouble(MathAbs(op-tp), digits);
      
      int typeoco = type;
      if (typeoco == OP_BUYSTOP) {
         typeoco = OP_SELLSTOP;
         op = bid - MathAbs(op-ask);
      }
      else if (typeoco == OP_BUYLIMIT) {
         typeoco = OP_SELLLIMIT;
         op = bid + MathAbs(op-ask);
      }
      else if (typeoco == OP_SELLSTOP) {
         typeoco = OP_BUYSTOP;
         op = ask + MathAbs(op-bid);
      }
      else if (typeoco == OP_SELLLIMIT) {
         typeoco = OP_BUYLIMIT;
         op = ask - MathAbs(op-bid);
      }
      
      if (typeoco == OP_BUYSTOP || typeoco == OP_BUYLIMIT)
      {
         sl = op - sl;
         tp = op + tp;
         arrowcolor = clrBlue;
      }
      else {
         sl = op + sl;
         tp = op - tp;
         arrowcolor = clrRed;
      }
         
      comment = "[oco:"+(string)ticket+"]";
      
      OrderCreate(symbol,typeoco,lots,op,sl,tp,0,0,slippage,magic,comment,arrowcolor,expiration,false);
   }
   
   return(ticket);
}
bool OrderModified(double id=-1, string action="set")
{
   static double memory[];
   
   if (id==-1) {
      id=OrderTicket();
      action="get";
   }
   else if (id>-1 && action!="clear") {
      action="set";
   }
   
   bool modified_status=InArray(memory,id);
   
   if (action=="set") {
   //- Set Trade ID
      ArrayValue(memory,id);
      return(true);
   }
   else if (action=="clear") {
   //- Unset Trade ID
      ArrayStrip(memory,id);
      return(true);
   }
   else if (action=="get") {
   //- Get State
      return(modified_status);
   }
   
   Print("Error: The second parameter of the function \"OrderModified\" should be \"set\", \"get\" or \"clear\"");
   return (false);
}
double PipValue(string symbol="")
{
   if (symbol=="") {symbol=GetSymbol();}
   return(CustomPoint(symbol)/MarketInfo(symbol,MODE_POINT));
   /*
   if (symbol=="") {symbol=GetSymbol();}
   int digits=MarketInfo(symbol,MODE_DIGITS);
   if ((digits==2 || digits==4)) {return(POINT_FORMAT/0.0001);}
   if ((digits==3 || digits==5)) {return(POINT_FORMAT/0.00001);}
   if ((digits==6))              {return(POINT_FORMAT/0.000001);}
   return(1);
   */
}
// Collect events, if any
void RegisterEvent(string command="")
{
   int ticket=OrderTicket();
	OnTradeListener();
   ticket=OrderSelect(ticket,SELECT_BY_TICKET);
   return;
}
int SellLater(
   string symbol,
   double lots,
   double price,
   double sll=0, // SL level
   double tpl=0, // TO level
   double slp=0, // SL adjust in points
   double tpp=0, // TP adjust in points
   double slippage=0,
   datetime expiration=0,
   int magic=0,
   string comment="",
   color arrowcolor=CLR_NONE,
   bool oco = false
   )
{
   double bid=MarketInfo(symbol,MODE_BID);
   int type;
        if (price==bid){type=OP_SELL;}
   else if (price<bid) {type=OP_SELLSTOP;}
   else if (price>bid) {type=OP_SELLLIMIT;}
   
   int ticket=OrderCreate(
      symbol,
      type,
      lots,
      price,
      sll,
      tpl,
      slp,
      tpp,
      slippage,
      magic,
      comment,
      arrowcolor,
      expiration,
      oco
      );
   return(ticket);
}
void SetLastIndicatorData(double value=0, string symbol="", int timeframe=0, int shift=0)
{
   LastIndicatorValue(true,value);
   LastIndicatorSymbol(true,symbol);
   LastIndicatorTimeframe(true,timeframe);
   LastIndicatorShift(true,shift);
   IndicatorMoreShift(true,0); // reset
   return;
}
string SetSymbol(string symbol="")
{
	if (symbol=="") {symbol=Symbol();}
   GetSymbol(symbol); return(symbol);
}
void StringExplode(string delimiter, string explode, string &sReturn[])
{
   static int ilBegin; ilBegin = -1;
   static int ilEnd; ilEnd = 0;
   static int ilElement; ilElement = 0;
   
   static string sDelimiter; sDelimiter = delimiter;
   static string sExplode; sExplode = explode;
   
   while (ilEnd != -1)
   {
      ilEnd = StringFind(sExplode, sDelimiter, ilBegin+1);
      ArrayResize(sReturn,ilElement+1);
      sReturn[ilElement] = "";     
      if (ilEnd == -1){
         if (ilBegin+1 != StringLen(sExplode)){
            sReturn[ilElement] = StringSubstr(sExplode, ilBegin+1, StringLen(sExplode));
         }
      } else { 
         if (ilBegin+1 != ilEnd){
            sReturn[ilElement] = StringSubstr(sExplode, ilBegin+1, ilEnd-ilBegin-1);
         }
      }      
      ilBegin = StringFind(sExplode, sDelimiter,ilEnd);  
      ilElement++;    
   }
}

void StringExplode(string delimiter, string explode, int &sReturn[])
{
   static int ilBegin; ilBegin = -1;
   static int ilEnd; ilEnd = 0;
   static int ilElement; ilElement = 0;
   
   static string sDelimiter; sDelimiter = delimiter;
   static string sExplode; sExplode = explode;
   
   while (ilEnd != -1)
   {
      ilEnd = StringFind(sExplode, sDelimiter, ilBegin+1);
      ArrayResize(sReturn,ilElement+1);
      sReturn[ilElement] = 0;     
      if (ilEnd == -1){
         if (ilBegin+1 != StringLen(sExplode)){
            sReturn[ilElement] = StrToInteger(StringSubstr(sExplode, ilBegin+1, StringLen(sExplode)));
         }
      } else { 
         if (ilBegin+1 != ilEnd){
            sReturn[ilElement] = StrToInteger(StringSubstr(sExplode, ilBegin+1, ilEnd-ilBegin-1));
         }
      }      
      ilBegin = StringFind(sExplode, sDelimiter,ilEnd);  
      ilElement++;    
   }
}
double SymbolAsk(string symbol="")
{
   if (symbol=="") {symbol=GetSymbol();}
   return(MarketInfo(symbol,MODE_ASK));
}
double SymbolBid(string symbol="")
{
   if (symbol=="") {symbol=GetSymbol();}
   return(MarketInfo(symbol,MODE_BID));
}
double TicksData(string symbol="", int type=0, int shift=0)
{
   
   //return(MarketInfo(symbol,type));
   static bool collecting_ticks=false;
   //static string feeded_symbols[];
   static string symbols[1];
   static int zero_sid[1];
   static double memoryASK[1][100];
   static double memoryBID[1][100];
   int sid; int size; int i; int id;
   double ask, bid, retval;
   bool exists=false;
   
   if (symbols[0]!=Symbol()) {symbols[0]=Symbol();}
   
   if (symbol=="") {symbol=Symbol();}
	
   if (type>0 && shift>0) {collecting_ticks=true;}
   if (collecting_ticks==false) {
      if (type>0 && shift==0) {
         // going to get ticks
      } else {return(0);}
   }
   
	if (type==0)
	{
      //StringExplode(",",symbol,feeded_symbols);
	   //for (s=0; s<ArraySize(feeded_symbols); s++)
	   //{
	      //symbol=feeded_symbols[s];
         //if (symbol=="") {symbol=Symbol();}
	      exists=false;
         size=ArraySize(symbols);
	      for (i=0; i<size; i++) {
	         if (symbols[i]==symbol) {exists=true; sid=i; break;}
	      }
         if (exists==false) {
            int newsize=ArraySize(symbols)+1;
            ArrayResize(symbols,newsize); symbols[newsize-1]=symbol;
            ArrayResize(zero_sid,newsize);
            ArrayResize(memoryASK,newsize);
            ArrayResize(memoryBID,newsize);
            sid=newsize;
         }
         if (sid>=0) {
            ask=MarketInfo(symbol,MODE_ASK);
            bid=MarketInfo(symbol,MODE_BID);
            if (bid==0 && MQLInfoInteger(MQL_TESTER)) {
               Print("Ticks data collector error: "+symbol+" cannot be backtested. Only the current symbol can be backtested. The EA will be terminated.");
               ExpertRemove();
            }
            if (symbol==Symbol() || ask!=memoryASK[sid][0] || bid!=memoryBID[sid][0])
            {
               memoryASK[sid][zero_sid[sid]]=ask;
               memoryBID[sid][zero_sid[sid]]=bid;
               zero_sid[sid]=zero_sid[sid]+1;
               if (zero_sid[sid]==100) {zero_sid[sid]=0;}
	         }
   	   }
      //}
   }
   else {
      if (shift<=0) {
         if (type==MODE_ASK) {
            return(MarketInfo(symbol, MODE_ASK));
         }
         else if (type==MODE_BID) {
            return(MarketInfo(symbol, MODE_BID)); 
         }
         else {
            double mid=((MarketInfo(symbol, MODE_ASK)+MarketInfo(symbol, MODE_BID))/2);
            return(mid);
         }
      }
      else {
         size=ArraySize(symbols);
         for (i=0; i<size; i++) {
            if (symbols[i]==symbol) {sid=i;}
         }
         if (shift<100) {
            id=zero_sid[sid]-shift-1; if(id<0) {id=id+100;}
            
            if (type==MODE_ASK) {
               retval=(memoryASK[sid][id]);
               if (retval==0) {retval=MarketInfo(symbol,MODE_ASK);}
            }
            else if (type==MODE_BID) {
               retval=(memoryBID[sid][id]);
               if (retval==0) {retval=MarketInfo(symbol,MODE_BID);}
            }
            //Print(shift+" "+id+" "+retval);
         }
      }
   }
   return(retval);
}
int TicksFromStart(bool upd=false)
{
   static int ticks=1;
   if (upd==true) {ticks++; if (ticks<0) ticks=0;}
   return(ticks);
}
int TicksPerSecond(bool get_max = false, bool set = false)
{
   static datetime time0 = 0;
   datetime time1 = TimeLocal();
   static int ticks, tps, tpsmax;
   
   if (set == true)
   {
      if (time1 > time0)
      {
         if (time1-time0 > 1)
         {
            tps = 0;
         }
         else
         {
            tps = ticks;
         }
         time0 = time1;
         ticks = 0;
      }
      
      ticks++;
      
      if (tps > tpsmax) {tpsmax = tps;}
   }
   
   if (get_max)
   {
      return tpsmax;
   }
   
   return tps;
}
datetime TimeAtStart(string cmd="server")
{
   static datetime local=0;
   static datetime server=0;
	
   if (cmd=="local") {return(local);}
   else if (cmd=="server") {return(server);}
   else if (cmd=="set") {
      local=TimeLocal();
      server=TimeCurrent();
   }
   return(0);
}
datetime TimeFromComponents(bool local_time=false, int y=0, int m=0, int d=0, int h=0, int i=0, int s=0)
{
   MqlDateTime tm;
   if (local_time) {TimeLocal(tm);} else {TimeCurrent(tm);}

   if (y>0) {
      if (y<100) {y=2000+y;}
      tm.year = y;
   }
   if (m>0) {tm.mon = m;}
   if (d>0) {tm.day = d;}

   tm.hour  = h;
   tm.min   = i;
   tm.sec   = s;
   
   return StructToTime(tm);
}
datetime TimeFromString(bool local_time, string stamp)
{
   // server time: there is a built-in function
   if (local_time == false)
   {
      return StringToTime(stamp);  
   }
   
   // local time
   datetime time  = StringToTime(stamp);
   
   datetime now_server  = TimeCurrent();
   datetime now_local   = TimeLocal();
   int day_server = TimeDay(now_server);
   int day_local  = TimeDay(now_local);
   if (day_local != day_server)
   {
      if (now_local > now_server) {time = time+86400;}
      else {time = time - 86400;}
   }

   return(time);
}
double toDigits(double pips,string symbol="")
{
	if (symbol=="") {symbol=GetSymbol();}
   return(
      NormalizeDouble(
         pips*PipValue(symbol)*MarketInfo(symbol,MODE_POINT),
         MarketInfo(symbol,MODE_DIGITS)
      )
   );
}
double toPips(double digits,string symbol="")
{
   if (symbol=="") {symbol=GetSymbol();}
   return(digits/(PipValue(symbol)*MarketInfo(symbol,MODE_POINT)));
}
void UpdateEventValues(string e_reason="",string e_detail="")
{
   OnTradeQueue(1);
   e_Reason(true,e_reason);
   e_ReasonDetail(true,e_detail);
   e_attrClosePrice (true,attrClosePrice());
   e_attrComment    (true,attrComment());
   e_attrCommission (true,attrCommission());
   e_attrExpiration (true,attrExpiration());
   e_attrLots       (true,attrLots());
   e_attrMagicNumber(true,attrMagicNumber());
   e_attrOpenPrice  (true,attrOpenPrice());
   e_attrProfit     (true,attrProfit());
   e_attrStopLoss   (true,attrStopLoss());
   e_attrSymbol     (true,attrSymbol());
   e_attrTakeProfit (true,attrTakeProfit());
   e_attrTicket     (true,attrTicket());
   e_attrType       (true,attrType());
   e_attrOpenTime(true,attrOpenTime());
   e_attrCloseTime(true,attrCloseTime());
   e_attrSwap(true,attrSwap());
}
double VirtualStopsDriver(string _command="", int _ti=-1, double _sl=0, double _tp=0, double _slp=0, double _tpp=0)
{
   if (!USE_VIRTUAL_STOPS) {return(0);} // Virtual stops are not enabled => stop here
   
   static int mem_to_ti[]; // tickets
   static int mem_to[];    // timeouts
   static int last_checked_ticket=0;
   
   static string command;  command=_command;
   static int ti;          ti=_ti;
   static double sl;       sl=_sl;
   static double tp;       tp=_tp;
   static double slp;      slp=_slp;
   static double tpp;      tpp=_tpp;
   
   static int i; i=0;
   static int ii; ii=-1;
   static int size; size=0;
   static int error; error=0;
   static int pos;
   static int total;
   static string name;
   static double ask, bid;
   static string print;
   
   // Listen trades/orders
   if (command=="" || command=="listen")
   {
      //-- delete lines of virtual stops of manually closed trades ------
      total = OrdersHistoryTotal();
      if (total>0)
      {
         static int prev_ticket; prev_ticket=0;
         for (pos=total-1; pos>=0; pos--)
         {
            if (OrderSelect(pos,SELECT_BY_POS,MODE_HISTORY))
            {
               if (OrderTicket()==last_checked_ticket) {break;}
               prev_ticket=OrderTicket();
               static bool clear; clear=true;
               
               name = "#"+OrderTicket()+" sl";
               if (ObjectFind(name)<0) {
                  error=GetLastError();
               }
               else {
                  clear=false;
                  ObjectDelete(name);
               }
               
               name = "#"+OrderTicket()+" tp";
               if (ObjectFind(name)<0) {
                  clear=true;
                  error=GetLastError();
               }
               else {
                  clear=false;
                  ObjectDelete(name);
               }
            }
         }
      
         if (prev_ticket==0) {prev_ticket=OrderTicket();}
         last_checked_ticket = prev_ticket;
      }
      
      //-- parse trades -------------------------------------------------
      total = OrdersTotal();
      for (pos=0; pos<total; pos++)
      {
         if (OrderSelect(pos,SELECT_BY_POS))
         {
            static int ticket;
            static string symbol;
            static double lots;
            static double cp;
            ticket   = OrderTicket();
            symbol   = OrderSymbol();
            lots     = OrderLots();
            cp       = OrderClosePrice();
            
            // check SL and TP
            static double sl_lvl;
            static double tp_lvl;
            
            name = "#"+ticket+" sl";
            sl_lvl = ObjectGet(name,OBJPROP_PRICE1);
            name = "#"+ticket+" tp";
            tp_lvl = ObjectGet(name,OBJPROP_PRICE1);
            
            // close trade/order
            if (OrderType()==OP_BUY)
            {
               bid = MarketInfo(symbol,MODE_BID);
               if ((sl_lvl>0 && bid<=sl_lvl) || (tp_lvl>0 && bid>=tp_lvl))
               {
                  if (VIRTUAL_STOPS_TIMEOUT>0 && (sl_lvl>0 && bid<=sl_lvl))
                  {
                     i=ArraySearch(mem_to_ti, ticket);
                     if (i<0)
                     { // start timeout
                        size = ArraySize(mem_to_ti);
                        ArrayResize(mem_to_ti, size+1);
                        ArrayResize(mem_to, size+1);
                        mem_to_ti[size]   = ticket;
                        mem_to[size]      = TimeLocal();
                        print = StringConcatenate("#",ticket," timeout of ",VIRTUAL_STOPS_TIMEOUT," seconds started");
                        Print(print);
                        return(0);
                     }
                     else {
                        if (TimeLocal()-mem_to[i] <= VIRTUAL_STOPS_TIMEOUT) {return(0);}
                     }
                  }
                  if (OrderClose(ticket, lots, cp, 0, clrNONE))
                  {
                     OnTradeListener(); // check this before deleting the lines
                     name = "#"+OrderTicket()+" sl";
                     ObjectDelete(name);
                     name = "#"+OrderTicket()+" tp";
                     ObjectDelete(name);
                  }
                  return(0);
               }
               else
               {
                  if (VIRTUAL_STOPS_TIMEOUT>0) {
                     i=ArraySearch(mem_to_ti,ticket);
                     if (i>=0) {
                        ArrayStripKey(mem_to_ti,i);
                        ArrayStripKey(mem_to,i);
                     }
                  }
               }
            }
            else if (OrderType()==OP_SELL)
            {
               ask = MarketInfo(symbol,MODE_ASK);
               if ((sl_lvl>0 && ask>=sl_lvl) || (tp_lvl>0 && ask<=tp_lvl))
               {
                  if (VIRTUAL_STOPS_TIMEOUT>0 && (sl_lvl>0 && ask>=sl_lvl))
                  {
                     i=ArraySearch(mem_to_ti, ticket);
                     if (i<0)
                     { // start timeout
                        size = ArraySize(mem_to_ti);
                        ArrayResize(mem_to_ti, size+1);
                        ArrayResize(mem_to, size+1);
                        mem_to_ti[size]   = ticket;
                        mem_to[size]      = TimeLocal();
                        print = StringConcatenate("#",ticket," timeout of ",VIRTUAL_STOPS_TIMEOUT," seconds started");
                        Print(print);
                        return(0);
                     }
                     else {
                        if (TimeLocal()-mem_to[i] <= VIRTUAL_STOPS_TIMEOUT) {return(0);}
                     }
                  }
                  if (OrderClose(ticket, lots, cp, 0, clrNONE))
                  {
                     OnTradeListener(); // check this before deleting the lines
                     name = "#"+OrderTicket()+" sl";
                     ObjectDelete(name);
                     name = "#"+OrderTicket()+" tp";
                     ObjectDelete(name);
                  }
                  return(0);
               }
               else
               {
                  if (VIRTUAL_STOPS_TIMEOUT>0)
                  {
                     i=ArraySearch(mem_to_ti,ticket);
                     if (i>=0) {
                        ArrayStripKey(mem_to_ti,i);
                        ArrayStripKey(mem_to,i);
                     }
                  }
               }
            }
         }
      }
   }
   // Set SL and TP
   else if ((command=="set" || command=="modify" || command=="clear" || command=="partial") && ti>-1)
   {
      static string settext;
      // update record (add/modify)
      name = "#"+ti+" sl";
      if (sl>0) {
         if (ObjectFind(name)==-1)
         {
            ObjectCreate(name,OBJ_HLINE,0,0,sl);
            ObjectSet(name,OBJPROP_WIDTH,1);
            ObjectSet(name,OBJPROP_COLOR,DeepPink);
            ObjectSet(name,OBJPROP_STYLE,STYLE_DOT);
            settext = name+" (virtual)";
            ObjectSetText(name, settext);
            error=GetLastError();
         }
         else {
            ObjectSet(name,OBJPROP_PRICE1,sl);
         }
      } else {ObjectDelete(name);}
      
      name="#"+ti+" tp";
      if (tp>0)
      {
         if (ObjectFind(name)==-1) {
            ObjectCreate(name,OBJ_HLINE,0,0,tp);
            ObjectSet(name,OBJPROP_WIDTH,1);
            ObjectSet(name,OBJPROP_COLOR,DodgerBlue);
            ObjectSet(name,OBJPROP_STYLE,STYLE_DOT);
            settext = name+" (virtual)";
            ObjectSetText(name, settext);
            error=GetLastError();
         }
         else {
            ObjectSet(name, OBJPROP_PRICE1, tp);
         }
      }
      else {
         ObjectDelete(name);
      }
      
      // print message
      if (command=="set" || command=="modify") {
         print = command+" #"+ti+": virtual sl "+DoubleToStr(sl,Digits)+" tp "+DoubleToStr(tp,Digits);
         Print(print);
      }
      return(1);
   }
   
   // Get SL or TP
   else if ((command=="get sl" || command=="get tp") && ti>0)
   {
      if (command=="get sl")
      {
         name = "#"+ti+" sl";
         if (ObjectFind(name) == -1) {error=GetLastError();return(0);} 
         return(ObjectGet(name, OBJPROP_PRICE1));
      }
      else if (command=="get tp")
      {
         name = "#"+ti+" tp";
         if (ObjectFind(name) == -1) {error=GetLastError();return(0);}
         return(ObjectGet(name, OBJPROP_PRICE1));
      }
      return(0);
   }
   
   return(1);
}
void WaitTradeContextIfBusy()
{
	if(IsTradeContextBusy()) {
      while(true)
      {
         Sleep(1);
         if(!IsTradeContextBusy()) {
            RefreshRates();
            break;
         }
      }
   }
   return;
}
int CustomDigits(string symbol="") {
	if (symbol=="") {symbol=GetSymbol();}
	double point=CustomPoint(symbol);
	if (point==0) {return(0);}
	int digits=0;
	while(true) {
		if (point>=1) {break;}
		point=point*10;
		digits++;
	}
	return(digits);
}
double CustomPoint(string symbol="") {
	static string symbols[];
	static double points[];
	static string last_symbol="-";
	static double last_point=0;
	static int last_i=0;
	static int size=0;

	if (symbol=="") {symbol=GetSymbol();}
	if (symbol==last_symbol) {return(last_point);}

	int i=last_i;
	int start_i=i;
	bool found=false;
	if (size>0) {
		while(true) {
			if (symbols[i]==symbol) {
				last_symbol=symbol;
				last_point=points[i];
				last_i=i;
				return(last_point);
				break;
			}
			i++;
			if (i>=size) {i=0;}
			if (i==start_i) {break;}
		}
	}

	//if (MarketInfo(symbol, MODE_DIGITS)<=0) {Print("Market "+symbol+" does not exists!"); return(0);} // commented because for indices digits = 0

	i=size;
	size=size+1;
	ArrayResize(symbols, size);
	ArrayResize(points, size);
	symbols[i]=symbol;
	points[i]=0;
	last_symbol=symbol;
	last_i=i;

	if (MarketInfo(symbol, MODE_POINT)==0.001) {points[i]=0.01;}
	if (MarketInfo(symbol, MODE_POINT)==0.00001) {points[i]=0.0001;}
	if (MarketInfo(symbol, MODE_POINT)==0.000001) {points[i]=0.0001;}
	if (points[i]==0) {points[i]=MarketInfo(symbol, MODE_POINT);}
	last_point=points[i];
	return(last_point);
}

string fxD_BlocksLookupTable(int cmd=0, string id="", bool onoff=false, bool toggle=false)
{
	int intID=0;
	bool notfound=false;

	while(true)
	{
		intID=StrToInteger(id);
		break;
	}
	switch(intID)
	{
		case 1: if(!cmd){block1();}else if(cmd==1){block1=onoff;}else if(cmd==2){block1=!(block1);}break;
		case 2: if(!cmd){block2();}else if(cmd==1){block2=onoff;}else if(cmd==2){block2=!(block2);}else if(cmd==3){return("5,23");}break;
		case 3: if(!cmd){block3();}else if(cmd==1){block3=onoff;}else if(cmd==2){block3=!(block3);}else if(cmd==3){return("2");}break;
		case 4: if(!cmd){block4();}else if(cmd==1){block4=onoff;}else if(cmd==2){block4=!(block4);}else if(cmd==3){return("30,47");}break;
		case 5: if(!cmd){block5();}else if(cmd==1){block5=onoff;}else if(cmd==2){block5=!(block5);}else if(cmd==3){return("4");}break;
		case 6: if(!cmd){block6();}else if(cmd==1){block6=onoff;}else if(cmd==2){block6=!(block6);}else if(cmd==3){return("48");}break;
		case 7: if(!cmd){block7();}else if(cmd==1){block7=onoff;}else if(cmd==2){block7=!(block7);}else if(cmd==3){return("6,23");}break;
		case 8: if(!cmd){block8();}else if(cmd==1){block8=onoff;}else if(cmd==2){block8=!(block8);}else if(cmd==3){return("7");}break;
		case 9: if(!cmd){block9();}else if(cmd==1){block9=onoff;}else if(cmd==2){block9=!(block9);}else if(cmd==3){return("1666610");}break;
		case 10: if(!cmd){block10();}else if(cmd==1){block10=onoff;}else if(cmd==2){block10=!(block10);}else if(cmd==3){return("1666611");}break;
		case 11: if(!cmd){block11();}else if(cmd==1){block11=onoff;}else if(cmd==2){block11=!(block11);}else if(cmd==3){return("3");}break;
		case 12: if(!cmd){block12();}else if(cmd==1){block12=onoff;}else if(cmd==2){block12=!(block12);}else if(cmd==3){return("8");}break;
		case 13: if(!cmd){block13();}else if(cmd==1){block13=onoff;}else if(cmd==2){block13=!(block13);}else if(cmd==3){return("11");}break;
		case 14: if(!cmd){block14();}else if(cmd==1){block14=onoff;}else if(cmd==2){block14=!(block14);}else if(cmd==3){return("13,21");}break;
		case 15: if(!cmd){block15();}else if(cmd==1){block15=onoff;}else if(cmd==2){block15=!(block15);}else if(cmd==3){return("12");}break;
		case 16: if(!cmd){block16();}else if(cmd==1){block16=onoff;}else if(cmd==2){block16=!(block16);}else if(cmd==3){return("15");}break;
		case 17: if(!cmd){block17();}else if(cmd==1){block17=onoff;}else if(cmd==2){block17=!(block17);}else if(cmd==3){return("29,32");}break;
		case 18: if(!cmd){block18();}else if(cmd==1){block18=onoff;}else if(cmd==2){block18=!(block18);}else if(cmd==3){return("16");}break;
		case 19: if(!cmd){block19();}else if(cmd==1){block19=onoff;}else if(cmd==2){block19=!(block19);}else if(cmd==3){return("28");}break;
		case 21: if(!cmd){block21();}else if(cmd==1){block21=onoff;}else if(cmd==2){block21=!(block21);}else if(cmd==3){return("11");}break;
		case 22: if(!cmd){block22();}else if(cmd==1){block22=onoff;}else if(cmd==2){block22=!(block22);}else if(cmd==3){return("18");}break;
		case 23: if(!cmd){block23();}else if(cmd==1){block23=onoff;}else if(cmd==2){block23=!(block23);}else if(cmd==3){return("30");}break;
		case 24: if(!cmd){block24();}else if(cmd==1){block24=onoff;}else if(cmd==2){block24=!(block24);}else if(cmd==3){return("1666609");}break;
		case 25: if(!cmd){block25();}else if(cmd==1){block25=onoff;}else if(cmd==2){block25=!(block25);}else if(cmd==3){return("1666612");}break;
		case 26: if(!cmd){block26();}else if(cmd==1){block26=onoff;}else if(cmd==2){block26=!(block26);}else if(cmd==3){return("17");}break;
		case 27: if(!cmd){block27();}else if(cmd==1){block27=onoff;}else if(cmd==2){block27=!(block27);}else if(cmd==3){return("22");}break;
		case 28: if(!cmd){block28();}else if(cmd==1){block28=onoff;}else if(cmd==2){block28=!(block28);}else if(cmd==3){return("18");}break;
		case 29: if(!cmd){block29();}else if(cmd==1){block29=onoff;}else if(cmd==2){block29=!(block29);}else if(cmd==3){return("14");}break;
		case 30: if(!cmd){block30();}else if(cmd==1){block30=onoff;}else if(cmd==2){block30=!(block30);}else if(cmd==3){return("43");}break;
		case 31: if(!cmd){block31();}else if(cmd==1){block31=onoff;}else if(cmd==2){block31=!(block31);}else if(cmd==3){return("1");}break;
		case 32: if(!cmd){block32();}else if(cmd==1){block32=onoff;}else if(cmd==2){block32=!(block32);}else if(cmd==3){return("14");}break;
		case 33: if(!cmd){block33();}else if(cmd==1){block33=onoff;}else if(cmd==2){block33=!(block33);}else if(cmd==3){return("31");}break;
		case 34: if(!cmd){block34();}else if(cmd==1){block34=onoff;}else if(cmd==2){block34=!(block34);}else if(cmd==3){return("33");}break;
		case 35: if(!cmd){block35();}else if(cmd==1){block35=onoff;}else if(cmd==2){block35=!(block35);}else if(cmd==3){return("31");}break;
		case 36: if(!cmd){block36();}else if(cmd==1){block36=onoff;}else if(cmd==2){block36=!(block36);}else if(cmd==3){return("35");}break;
		case 37: if(!cmd){block37();}else if(cmd==1){block37=onoff;}else if(cmd==2){block37=!(block37);}else if(cmd==3){return("36");}break;
		case 38: if(!cmd){block38();}else if(cmd==1){block38=onoff;}else if(cmd==2){block38=!(block38);}else if(cmd==3){return("31");}break;
		case 39: if(!cmd){block39();}else if(cmd==1){block39=onoff;}else if(cmd==2){block39=!(block39);}else if(cmd==3){return("38");}break;
		case 40: if(!cmd){block40();}else if(cmd==1){block40=onoff;}else if(cmd==2){block40=!(block40);}else if(cmd==3){return("39");}break;
		case 41: if(!cmd){block41();}else if(cmd==1){block41=onoff;}else if(cmd==2){block41=!(block41);}else if(cmd==3){return("42");}break;
		case 42: if(!cmd){block42();}else if(cmd==1){block42=onoff;}else if(cmd==2){block42=!(block42);}else if(cmd==3){return("62");}break;
		case 43: if(!cmd){block43();}else if(cmd==1){block43=onoff;}else if(cmd==2){block43=!(block43);}else if(cmd==3){return("42");}break;
		case 44: if(!cmd){block44();}else if(cmd==1){block44=onoff;}else if(cmd==2){block44=!(block44);}else if(cmd==3){return("31");}break;
		case 45: if(!cmd){block45();}else if(cmd==1){block45=onoff;}else if(cmd==2){block45=!(block45);}else if(cmd==3){return("44");}break;
		case 46: if(!cmd){block46();}else if(cmd==1){block46=onoff;}else if(cmd==2){block46=!(block46);}else if(cmd==3){return("45");}break;
		case 47: if(!cmd){block47();}else if(cmd==1){block47=onoff;}else if(cmd==2){block47=!(block47);}else if(cmd==3){return("41");}break;
		case 48: if(!cmd){block48();}else if(cmd==1){block48=onoff;}else if(cmd==2){block48=!(block48);}else if(cmd==3){return("30,55");}break;
		case 49: if(!cmd){block49();}else if(cmd==1){block49=onoff;}else if(cmd==2){block49=!(block49);}else if(cmd==3){return("42");}break;
		case 55: if(!cmd){block55();}else if(cmd==1){block55=onoff;}else if(cmd==2){block55=!(block55);}else if(cmd==3){return("49");}break;
		case 57: if(!cmd){block57();}else if(cmd==1){block57=onoff;}else if(cmd==2){block57=!(block57);}break;
		case 58: if(!cmd){block58();}else if(cmd==1){block58=onoff;}else if(cmd==2){block58=!(block58);}else if(cmd==3){return("26");}break;
		case 59: if(!cmd){block59();}else if(cmd==1){block59=onoff;}else if(cmd==2){block59=!(block59);}else if(cmd==3){return("27");}break;
		case 60: if(!cmd){block60();}else if(cmd==1){block60=onoff;}else if(cmd==2){block60=!(block60);}else if(cmd==3){return("19");}break;
		case 61: if(!cmd){block61();}else if(cmd==1){block61=onoff;}else if(cmd==2){block61=!(block61);}else if(cmd==3){return("26");}break;
		case 62: if(!cmd){block62();}else if(cmd==1){block62=onoff;}else if(cmd==2){block62=!(block62);}else if(cmd==3){return("57");}break;
		case 63: if(!cmd){block63();}else if(cmd==1){block63=onoff;}else if(cmd==2){block63=!(block63);}else if(cmd==3){return("58");}break;
		case 64: if(!cmd){block64();}else if(cmd==1){block64=onoff;}else if(cmd==2){block64=!(block64);}else if(cmd==3){return("60");}break;
		case 65: if(!cmd){block65();}else if(cmd==1){block65=onoff;}else if(cmd==2){block65=!(block65);}else if(cmd==3){return("61");}break;
		case 66: if(!cmd){block66();}else if(cmd==1){block66=onoff;}else if(cmd==2){block66=!(block66);}else if(cmd==3){return("59");}break;
		case 1666538: if(!cmd){block1666538();}else if(cmd==1){block1666538=onoff;}else if(cmd==2){block1666538=!(block1666538);}else if(cmd==3){return("1666608");}break;
		case 1666570: if(!cmd){block1666570();}else if(cmd==1){block1666570=onoff;}else if(cmd==2){block1666570=!(block1666570);}else if(cmd==3){return("1666608");}break;
		case 1666571: if(!cmd){block1666571();}else if(cmd==1){block1666571=onoff;}else if(cmd==2){block1666571=!(block1666571);}else if(cmd==3){return("1666608");}break;
		case 1666573: if(!cmd){block1666573();}else if(cmd==1){block1666573=onoff;}else if(cmd==2){block1666573=!(block1666573);}else if(cmd==3){return("1666607");}break;
		case 1666605: if(!cmd){block1666605();}else if(cmd==1){block1666605=onoff;}else if(cmd==2){block1666605=!(block1666605);}else if(cmd==3){return("1666607");}break;
		case 1666606: if(!cmd){block1666606();}else if(cmd==1){block1666606=onoff;}else if(cmd==2){block1666606=!(block1666606);}else if(cmd==3){return("1666607");}break;
		case 1666607: if(!cmd){block1666607();}else if(cmd==1){block1666607=onoff;}else if(cmd==2){block1666607=!(block1666607);}else if(cmd==3){return("63,65");}break;
		case 1666608: if(!cmd){block1666608();}else if(cmd==1){block1666608=onoff;}else if(cmd==2){block1666608=!(block1666608);}else if(cmd==3){return("64,66");}break;
		case 1666609: if(!cmd){block1666609();}else if(cmd==1){block1666609=onoff;}else if(cmd==2){block1666609=!(block1666609);}else if(cmd==3){return("63");}break;
		case 1666610: if(!cmd){block1666610();}else if(cmd==1){block1666610=onoff;}else if(cmd==2){block1666610=!(block1666610);}else if(cmd==3){return("65");}break;
		case 1666611: if(!cmd){block1666611();}else if(cmd==1){block1666611=onoff;}else if(cmd==2){block1666611=!(block1666611);}else if(cmd==3){return("66");}break;
		case 1666612: if(!cmd){block1666612();}else if(cmd==1){block1666612=onoff;}else if(cmd==2){block1666612=!(block1666612);}else if(cmd==3){return("64");}break;
		case 1666613: if(!cmd){block1666613();}else if(cmd==1){block1666613=onoff;}else if(cmd==2){block1666613=!(block1666613);}else if(cmd==3){return("31");}break;
		case 1666614: if(!cmd){block1666614();}else if(cmd==1){block1666614=onoff;}else if(cmd==2){block1666614=!(block1666614);}else if(cmd==3){return("1666613");}break;
		case 1666615: if(!cmd){block1666615();}else if(cmd==1){block1666615=onoff;}else if(cmd==2){block1666615=!(block1666615);}else if(cmd==3){return("31");}break;
		case 1666616: if(!cmd){block1666616();}else if(cmd==1){block1666616=onoff;}else if(cmd==2){block1666616=!(block1666616);}else if(cmd==3){return("1666615");}break;
		case 1666617: if(!cmd){block1666617();}else if(cmd==1){block1666617=onoff;}else if(cmd==2){block1666617=!(block1666617);}else if(cmd==3){return("31");}break;
		case 1666618: if(!cmd){block1666618();}else if(cmd==1){block1666618=onoff;}else if(cmd==2){block1666618=!(block1666618);}else if(cmd==3){return("1666617");}break;
		case 1666619: if(!cmd){block1666619();}else if(cmd==1){block1666619=onoff;}else if(cmd==2){block1666619=!(block1666619);}else if(cmd==3){return("31");}break;
		case 1666621: if(!cmd){block1666621();}else if(cmd==1){block1666621=onoff;}else if(cmd==2){block1666621=!(block1666621);}else if(cmd==3){return("1666619");}break;
		default:notfound=true;
	}
	if (notfound==true) {
		string attempt="";
		if (cmd==0) {attempt=" (attempt to run block)";}
		else if (cmd==1) {
			if (onoff==true) {attempt=" (attempt to turn block ON)";}
			else {attempt=" (attempt to turn block OFF)";}
		}
		else if (cmd==2) {
			attempt=" (attempt to toggle block)";
		}
		else if (cmd==3) {
			attempt=" (attempt to get connections information for block)";
		}
		Alert("      EA Error: Block "+id+" was not found for this project!"+attempt);
	}
	return("");
}

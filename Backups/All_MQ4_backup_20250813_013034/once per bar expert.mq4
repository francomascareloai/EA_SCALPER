//+------------------------------------------------------------------------------+//
//)   ____  _  _  ____  ____  ____  ____  __  __    __      ___  _____  __  __   (//
//)  ( ___)( \/ )(  _ \(  _ \( ___)( ___)(  \/  )  /__\    / __)(  _  )(  \/  )  (//
//)   )__)  )  (  )(_) ))   / )__)  )__)  )    (  /(__)\  ( (__  )(_)(  )    (   (//
//)  (__)  (_/\_)(____/(_)\_)(____)(____)(_/\/\_)(__)(__)()\___)(_____)(_/\/\_)  (//
//)   http://fxdreema.com                              Copyright 2015, fxDreema  (//
//+------------------------------------------------------------------------------+//
#property copyright ""
#property link      "https://fxdreema.com"

/************************************************************************************************************************/
// +------------------------------------------------------------------------------------------------------------------+ //
// |                       INPUT PARAMETERS, GLOBAL VARIABLES, CONSTANTS, IMPORTS and INCLUDES                        | //
// |                      System and Custom variables and other definitions used in the project                       | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//
// System constants (project settings) //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
#define PROJECT_ID           "mt4-2955"
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
// fxDreema Variables
extern double Priceoffset = 13.0; // Price offset

extern string inp2="(2) Once per bar";
extern int inp2_TIMEFRAME=PERIOD_H4; // 
extern int inp2_PassMaxTimes=1; // 

extern string inp3="(3) Close trades";
extern string inp3_OrdersScope="group"; // 
extern string inp3_SymbolScope="symbol"; // 
extern string inp3_BuysOrSells="both"; // 

extern string inp4="(4) Delete pending orders";
extern string inp4_OrdersScope="group"; // 
extern string inp4_SymbolScope="symbol"; // 
extern string inp4_BuysOrSells="both"; // 
extern string inp4_LimitsOrStops="both"; // 

extern string inp5="(5) Buy pending order&nbsp;";
extern string inp5_OrdersGroup=""; // 
extern int inp5_dPrice_CandleID=1; // 
extern int inp5_dPrice_TIMEFRAME=0; // 
extern double inp5_PriceOffset=10; // 
extern double inp5_VolumeSize=0.01; // 
extern int inp5_dlStopLoss_CandleID=1; // 
extern double inp5_TakeProfitPips=100; // 

extern string inp6="(6) Sell pending order";
extern string inp6_OrdersGroup=""; // 
extern int inp6_dPrice_CandleID=1; // 
extern int inp6_dPrice_TIMEFRAME=0; // 
extern double inp6_PriceOffset=10; // 
extern double inp6_VolumeSize=0.01; // 
extern int inp6_dlStopLoss_CandleID=1; // 
extern double inp6_TakeProfitPips=100; // 

extern string inp7="(7) Break even point (each trade)&nbsp;";
extern double inp7_OnProfitPips=40; // 
extern double inp7_BEPoffsetPips=5; // 
extern string inp7_OrdersScope="group"; // 
extern string inp7_SymbolScope="symbol"; // 
extern string inp7_BuysOrSells="both"; // 

extern string inp8="(8) If trade is running&nbsp;";
extern string inp8_OrdersScope="group"; // 
extern string inp8_SymbolScope="symbol"; // 
extern string inp8_BuysOrSells="both"; // 

extern string inp9="(9) Delete pending orders&nbsp;";
extern string inp9_OrdersScope="group"; // 
extern string inp9_SymbolScope="symbol"; // 
extern string inp9_BuysOrSells="both"; // 
extern string inp9_LimitsOrStops="stops"; // 
extern int MagicStart=9903; // Magic Start (MagicNumber=MagicStart+Group#)

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
// Global variables used as On-Off property for fxDreema blocks //
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^//
bool block1=true; // Pass
bool block2=true; // Once per bar
bool block3=true; // Close trades
bool block4=true; // Delete pending orders
bool block5=true; // Buy pending order&nbsp;
bool block6=true; // Sell pending order
bool block7=true; // Break even point (each trade)&nbsp;
bool block8=true; // If trade is running&nbsp;
bool block9=true; // Delete pending orders&nbsp;

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

	// Main beginning on the graph
	block1();



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
// |                                   FUNCTIONS THAT REPRESENTS BLOCKS IN FXDREEMA                                   | //
// |                                    Each block is represented as function here                                    | //
// +------------------------------------------------------------------------------------------------------------------+ //
/************************************************************************************************************************/

//~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #1 (Pass) //
void block1(int _parent_=0)
{
	if (block1==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=1;

	block2(1); block7(1); block8(1);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #2 (Once per bar) //
void block2(int _parent_=0)
{
	if (block2==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=2;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	int TIMEFRAME=inp2_TIMEFRAME; // Timeframe
	int PassMaxTimes=inp2_PassMaxTimes; // Max. times to pass
	
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
	   
	   block3(2);
	}
	else {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #3 (Close trades) //
void block3(int _parent_=0)
{
	if (block3==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=3;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersScope=inp3_OrdersScope; // Group mode
	string OrdersGroup=""; // Group # (empty=Default)
	string SymbolScope=inp3_SymbolScope; // Market mode
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string BuysOrSells=inp3_BuysOrSells; // Filter by type
	int OrderMinutes=0; // Only older than
	double Slippage=4; // Slippage
	color ArrowColor=DeepPink; // Arrow color
	
	///////////////
	// Main code //
	///////////////
	
	int closed_count=0;
	bool finished=false;
	while (finished==false) {
	   int count=0;
	   for (int pos=OrdersTotal()-1; pos>=0; pos--) {
	      if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) {
	         if (FilterOrderBy(OrdersScope,OrdersGroup, SymbolScope,SYMBOL, BuysOrSells)) {
	            datetime time_diff = TimeCurrent()-attrOpenTime();
	            if (time_diff < 0) {time_diff = 0;} // this actually happens sometimes
	            if (time_diff >= 60*OrderMinutes)
	            {
	               if (CloseTrade(attrTicket(),Slippage,ArrowColor)) {closed_count++;}
	               count++;
	            }
	         }
	      }
	   }
	   if (count==0) {finished=true;}
	}
	
	block4(3);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #4 (Delete pending orders) //
void block4(int _parent_=0)
{
	if (block4==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=4;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersScope=inp4_OrdersScope; // Group mode
	string OrdersGroup=""; // Group # (empty=Default)
	string SymbolScope=inp4_SymbolScope; // Market mode
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string BuysOrSells=inp4_BuysOrSells; // Filter by type
	string LimitsOrStops=inp4_LimitsOrStops; // Filter by pending type
	double Slippage=4; // Slippage
	color ArrowColor=DeepPink; // Arrow color
	
	///////////////
	// Main code //
	///////////////
	
	for (int pos=OrdersTotal()-1; pos>=0; pos--) {
	   if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) {
	      if (FilterOrderBy(OrdersScope,OrdersGroup, SymbolScope,SYMBOL, BuysOrSells, LimitsOrStops, 1)) {
	         DeleteOrder(attrTicket(),ArrowColor);
	      }
	   }
	}
	
	block5(4);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #5 (Buy pending order&nbsp;) //
void block5(int _parent_=0)
{
	if (block5==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=5;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersGroup=inp5_OrdersGroup; // Group # (empty=Default)
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string Price="dynamic"; // Open at price
	double PriceOffset=inp5_PriceOffset; // Price offset
	string VolumeMode="fixed"; // Money management
	double VolumeSize=inp5_VolumeSize; // Lot size
	double VolumeSizeRisk=50; // Risk fixed amount of money
	double VolumeRisk=2.5; // Risk percent
	double VolumePercent=100; // Volume size
	double VolumeBlockPercent=3; // Block % of Balance
	double FixedRatioUnitSize=0.01; // Fixed Ratio: Unit size
	double FixedRatioDelta=20; // Fixed Ratio: Delta parameter
	string StopLossMode="dynamicLevel"; // Stop-Loss mode
	double StopLossPips=100; // in pips...
	double StopLossPercentTP=100; // % of Take-Profit
	string TakeProfitMode="fixed"; // Take-Profit mode
	double TakeProfitPips=inp5_TakeProfitPips; // in pips...
	double TakeProfitPercentSL=100; // % of Stop-Loss
	string ExpMode="GTC"; // Expiration mode
	int ExpDays=0; // Days
	int ExpHours=40; // Hours
	int ExpMinutes=0; // Minutes
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
	else if (Price=="dynamic") {op=_candles("iHigh", "id", inp5_dPrice_CandleID, "00:00", CurrentSymbol(), inp5_dPrice_TIMEFRAME);}
	op=op+toDigits(PriceOffset);
	
	//-- stops ------------------------------------------------------------------
	double sll=0, slp=0, tpl=0, tpp=0;
	
	     if (StopLossMode=="fixed")        {slp=StopLossPips;}
	else if (StopLossMode=="dynamicPips")  {slp=_candles("iLow", "id", 1, "00:00", CurrentSymbol(), CurrentTimeframe());}
	else if (StopLossMode=="dynamicDigits"){slp=toPips(_candles("iClose", "id", 0, "00:00", CurrentSymbol(), CurrentTimeframe()),SYMBOL);}
	else if (StopLossMode=="dynamicLevel") {sll=_candles("iLow", "id", inp5_dlStopLoss_CandleID, "00:00", CurrentSymbol(), CurrentTimeframe());}
	
	     if (TakeProfitMode=="fixed")         {tpp=TakeProfitPips;}
	else if (TakeProfitMode=="dynamicPips")   {tpp=_value(100);}
	else if (TakeProfitMode=="dynamicDigits") {tpp=toPips(_value(0.0100),SYMBOL);}
	else if (TakeProfitMode=="dynamicLevel")  {tpl=_value(1);}
	
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
	
	if (ticket>0) {block6(5);} else {/* Gray output */}
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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #6 (Sell pending order) //
void block6(int _parent_=0)
{
	if (block6==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=6;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersGroup=inp6_OrdersGroup; // Group # (empty=Default)
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string Price="dynamic"; // Open at price
	double PriceOffset=inp6_PriceOffset; // Price offset
	string VolumeMode="fixed"; // Money management
	double VolumeSize=inp6_VolumeSize; // Lot size
	double VolumeSizeRisk=50; // Risk fixed amount of money
	double VolumeRisk=2.5; // Risk percent
	double VolumePercent=100; // Volume size
	double VolumeBlockPercent=3; // Block % of Balance
	double FixedRatioUnitSize=0.01; // Fixed Ratio: Unit size
	double FixedRatioDelta=20; // Fixed Ratio: Delta parameter
	string StopLossMode="dynamicLevel"; // Stop-Loss mode
	double StopLossPips=100; // in pips...
	double StopLossPercentTP=100; // % of Take-Profit
	string TakeProfitMode="fixed"; // Take-Profit mode
	double TakeProfitPips=inp6_TakeProfitPips; // in pips...
	double TakeProfitPercentSL=100; // % of Stop-Loss
	string ExpMode="GTC"; // Expiration mode
	int ExpDays=0; // Days
	int ExpHours=1; // Hours
	int ExpMinutes=0; // Minutes
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
	else if (Price=="dynamic") {op=_candles("iLow", "id", inp6_dPrice_CandleID, "00:00", CurrentSymbol(), inp6_dPrice_TIMEFRAME);}
	op=op-toDigits(PriceOffset);
	
	//-- stops ------------------------------------------------------------------
	double sll=0, slp=0, tpl=0, tpp=0;
	
	     if (StopLossMode=="fixed")        {slp=StopLossPips;}
	else if (StopLossMode=="dynamicPips")  {slp=_value(100);}
	else if (StopLossMode=="dynamicDigits"){slp=toPips(_value(0.0100),SYMBOL);}
	else if (StopLossMode=="dynamicLevel") {sll=_candles("iHigh", "id", inp6_dlStopLoss_CandleID, "00:00", CurrentSymbol(), CurrentTimeframe());}
	
	     if (TakeProfitMode=="fixed")         {tpp=TakeProfitPips;}
	else if (TakeProfitMode=="dynamicPips")   {tpp=_value(100);}
	else if (TakeProfitMode=="dynamicDigits") {tpp=toPips(_value(0.0100),SYMBOL);}
	else if (TakeProfitMode=="dynamicLevel")  {tpl=_value(1);}
	
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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #7 (Break even point (each trade)&nbsp;) //
void block7(int _parent_=0)
{
	if (block7==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=7;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OnProfitMode="fixed"; // On profit mode
	double OnProfitPips=inp7_OnProfitPips; // Pips on profit
	double OnProfitPercentSL=50; // Pips on profit (% of SL)
	double OnProfitPercentTP=50; // Pips on profit (% of TP)
	string BEoffsetMode="pips"; // BEP offset mode
	double BEPoffsetPips=inp7_BEPoffsetPips; // Break even point offset
	string OrdersScope=inp7_OrdersScope; // Group mode
	string OrdersGroup=""; // Group # (empty=Default)
	string SymbolScope=inp7_SymbolScope; // Market mode
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string BuysOrSells=inp7_BuysOrSells; // Filter by type
	
	///////////////
	// Main code //
	///////////////
	
	for (int pos=OrdersTotal()-1; pos>=0; pos--) {
	   if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) {
	      if (FilterOrderBy(OrdersScope,OrdersGroup, SymbolScope,SYMBOL, BuysOrSells)) {
	         SetSymbol(attrSymbol());
	         double PipsToSet;
	
	         if (OnProfitMode=="fixed")     {PipsToSet=OnProfitPips;}
	         else if (OnProfitMode=="percentSL") {PipsToSet=toPips(MathAbs(attrOpenPrice()-attrStopLoss()))*OnProfitPercentSL/100;}
	         else if (OnProfitMode=="percentTP") {PipsToSet=toPips(MathAbs(attrOpenPrice()-attrTakeProfit()))*OnProfitPercentTP/100;}
	         
	         if (
	            (attrType()==OP_BUY && (SymbolAsk()-attrOpenPrice() > toDigits(PipsToSet)) && (attrStopLoss() < attrOpenPrice()))
	            ||
	            (attrType()==OP_SELL && (attrOpenPrice()-SymbolBid() > toDigits(PipsToSet)) && ((attrStopLoss() > attrOpenPrice()) || attrStopLoss()==0))
	            )
	         {
	            double be_offset=0;
	            if (BEoffsetMode=="pips") {
	               be_offset=toDigits(BEPoffsetPips);
	               if (attrType()==OP_SELL ) {be_offset=be_offset*(-1);}
	            }
	            ModifyStops(attrTicket(),attrOpenPrice()+be_offset,attrTakeProfit());
	         }
	      }
	   }
	}
	
	/* Orange output */
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #8 (If trade is running&nbsp;) //
void block8(int _parent_=0)
{
	if (block8==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=8;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersScope=inp8_OrdersScope; // Group mode
	string OrdersGroup=""; // Group # (empty=Default)
	string SymbolScope=inp8_SymbolScope; // Market mode
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string BuysOrSells=inp8_BuysOrSells; // Filter by type
	
	///////////////
	// Main code //
	///////////////
	
	bool exist=false;
	for (int pos=OrdersTotal()-1; pos>=0; pos--) {
	   if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) {
	      if (FilterOrderBy(OrdersScope,OrdersGroup, SymbolScope,SYMBOL, BuysOrSells)) {
	         exist=true; break;
	      }
	   }
	}
	
	if (exist==true) {block9(8);} else {/* Yellow output */}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
// fxDreema block #9 (Delete pending orders&nbsp;) //
void block9(int _parent_=0)
{
	if (block9==false || FXD_BREAK==true) {return;}
	FXD_CURRENT_FUNCTION_ID=9;

	//////////////////////
	// Input parameters //
	//////////////////////
	
	string OrdersScope=inp9_OrdersScope; // Group mode
	string OrdersGroup=""; // Group # (empty=Default)
	string SymbolScope=inp9_SymbolScope; // Market mode
	string SYMBOL=CurrentSymbol(); // Market (empty=Current)
	string BuysOrSells=inp9_BuysOrSells; // Filter by type
	string LimitsOrStops=inp9_LimitsOrStops; // Filter by pending type
	double Slippage=4; // Slippage
	color ArrowColor=DeepPink; // Arrow color
	
	///////////////
	// Main code //
	///////////////
	
	for (int pos=OrdersTotal()-1; pos>=0; pos--) {
	   if (OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) {
	      if (FilterOrderBy(OrdersScope,OrdersGroup, SymbolScope,SYMBOL, BuysOrSells, LimitsOrStops, 1)) {
	         DeleteOrder(attrTicket(),ArrowColor);
	      }
	   }
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
bool FilterOrderBy(string _group_mode="all", string _group="0", string _market_mode="all", string _market="", string _BuysOrSells="both", string _LimitsOrStops="both", int _TradesOrders=0)
{
   // TradesOrders=0 - trades only
   // TradesOrders=1 - orders only
   // TradesOrders=2 - trades and orders

   //-- db
   static string market0="-";
   static string markets[];
   static int markets_size=0;
   
   static string group0="-";
   static string groups[];
   static int groups_size=0;
   
   //-- local variables
   static bool type_pass; type_pass = false;
   static bool market_pass; market_pass = false;
   static bool group_pass; group_pass = false;
   
   static int i;
   static int type;
   
   //-- get
   static string group_mode;     group_mode = _group_mode;
   static string group;          group = _group;
   static string market_mode;    market_mode = _market_mode;
   static string market;         market = _market;
   static string BuysOrSells;    BuysOrSells = _BuysOrSells;
   static string LimitsOrStops;  LimitsOrStops = _LimitsOrStops;
   static int TradesOrders;      TradesOrders = _TradesOrders;
   
   // Trades
   type=OrderType();
   if (TradesOrders==0)
   {
      if (
            (BuysOrSells=="both"  && (type==OP_BUY || type==OP_SELL))
         || (BuysOrSells=="buys"  && type==OP_BUY)
         || (BuysOrSells=="sells" && type==OP_SELL)
         
         )
      {
         type_pass = true;
      }
   }
   // Pending orders
   else if (TradesOrders==1)
   {
      if (
            ((BuysOrSells=="buys" || BuysOrSells=="both") && (type==OP_BUYLIMIT || type==OP_BUYSTOP))
         || ((BuysOrSells=="sells" || BuysOrSells=="both") && (type==OP_SELLLIMIT || type==OP_SELLSTOP))
         )
      {
         if (
               ((LimitsOrStops=="stops" || LimitsOrStops=="both") && (type==OP_BUYSTOP || type==OP_SELLSTOP))
            || ((LimitsOrStops=="limits" || LimitsOrStops=="both") && (type==OP_BUYLIMIT || type==OP_SELLLIMIT))               
            )
         {
            type_pass = true;
         }
      }
   }
   //-- Trades and orders --------------------------------------------
   else
   {
      if (
            (BuysOrSells=="both")
         || (BuysOrSells=="buys"  && (type==OP_BUY || type==OP_BUYLIMIT || type==OP_BUYSTOP))
         || (BuysOrSells=="sells" && (type==OP_SELL || type==OP_SELLLIMIT || type==OP_SELLSTOP))
         )
      {
         type_pass = true;
      }
   }
   if (type_pass == false) {return false;}

   //-- check group
   if (group_mode=="group")
   {
      if (group0!=group)
      {
         group0=group;
         StringExplode(",",group,groups);
         groups_size = ArraySize(groups);
         for(i=0; i<groups_size; i++)
         {
            groups[i]=StringTrimRight(groups[i]);
            groups[i]=StringTrimLeft(groups[i]);
            if (groups[i]=="") {groups[i]="0";}
         }
      }
      for(i=0; i<groups_size; i++)
      {
         if (OrderMagicNumber()==(MagicStart+(int)groups[i]))
         {
            group_pass=true;
            break;
         }
      }
   }
   else if (group_mode=="all" || (group_mode=="manual" && OrderMagicNumber()==0)) {
      group_pass = true;  
   }
   if (group_pass == false) {return false;}
   
   // check market
   if (market_mode=="all") {
      market_pass=true;
      
   }
   else {
      if (market0!=market)
      {
         market0=market;
         if (market=="")
         {
            markets_size = 1;
            ArrayResize(markets,1);
            markets[0]=Symbol();
         }
         else
         {
            StringExplode(",", market,markets);
            markets_size = ArraySize(markets);
            for(i=0; i<markets_size; i++)
            {
               markets[i]=StringTrimRight(markets[i]);
               markets[i]=StringTrimLeft(markets[i]);
               if (markets[i]=="") {markets[i]=Symbol();}
            }
         }
      }
      for(i=0; i<markets_size; i++) {
         if (OrderSymbol()==markets[i]) {
            market_pass = true;
            break;
         }
      }
   }
   if (market_pass == false) {return false;}
   
   return true;
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
   if (mins_diff > 0) {
      CandleID = (int)MathCeil((double)mins_diff/(double)mins_tf);
   }
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
bool ModifyStops(int ticket, double sl=-1, double tp=-1, color clr=CLR_NONE)
{
   return(ModifyOrder(ticket,attrOpenPrice(),sl,tp,0,0,attrExpiration(),clr));
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


//+------------------------------------------------------------------+
//| END                                                              |
//| Created with fxDreema EA Builder           https://fxdreema.com/ |
//+------------------------------------------------------------------+
/*<fxdreema:eNrtW1lz4zgO/isuP2ztvnTp9NVPbcd9VNljb+yerXlyKRKdcCOLKklO4pnKf1+Ah0RddjrjTDo7eYkdAgSBDyAJkLQ3Goz+SOFPNyVZRqPrtPvRG1kWNprWqBsn7L/EzzaRtyPdj9A2HHVZ5JNOTJLOlZd0yAN8yzhJY88OMWfvjbplBp8FJPSi6713zRmcUXf+75nDyeaoG3gZ2fgJgY/uRzoyHWs4HPZcu6fTdyyg24Og29awbxiOKek775r6mzTzxIggfTg0bCX9KmT+bYr9hS2jrsE/+6PudeLFNxuWUBJlXkZZpPqsWbxmY5ZlbMebwCLPz+gdqMmAlUYkkSOtqX+LXy3odUdTehWSTUivEi85bK4Tto8lIOkhzchOgak4uW5tfPaom9EdSTYpgVGDFG3vGVLDmNEo2yT7kHDf2aM/6MhAJ6IPQa9tIlR3wdwPhmFyHUEgk3pDI7Q9ApoNnfqiU7VbTzaLjlZDx4HqeKTno8B+n5LNHU2yvReC61icyg4RK+DUqBuEgu0zBMGQKKIIAgBdk8g/NAhBngp9k5CwFAUNLF4QlFjgC7mDCCliyEHPCL9zAYLqH3xwKcQ9ZQGPUyQDa0p3+xBDGPukumi0skzd7LzklmQSs+n3y++rC8CMu+SeRgG75+4eIu55k4lNpiGntGj7diEdmbOk0AvcES+225RwHE2TI2mMuiHZZkV7z3EFd2uwj7o0kNE13cXZQUqnAMI+5ZPminsJ1Alo6kGoB6oJfR97CawsGUmAn7Ek4KCAGlJk6nuhWkgiluy8UMqXE0vYVoytw2OdxsJqwsKy3UYsHNt4IhbYdwGL5JIkYy95DUSqGui42KdxsZtwsY0WXJwn4wJBPglZShYxiUjwKsBUVdCRcU4j4zQiM2iePY75ZGRghb8gIVi3JFEA2/CrYFNXQkfHPY2O24SO47bEjfUj82m8P7wmNBUNdFx6p3HpNeHiOn8aFwjmFQnD1wSmqoKOTP80Mv3G3WjYjIw7eDIy0DiGNPJ2ChvyEhOkVwGnQQsdn8FpfAaN+LTMqEHf/QF8vm3FGrhIAjDztfCpaqHjMzyNz7BxB2/Dp+e+9fX4UdhVyG/JAV1sgv6N2R+YeT+rJm3Y+IvEY+mlqeo2KdmLXEscALzyWMu2ei2jWqVR6+lRPjaWiAutvDyhhI3jAYar3+bjxUzDGKBcf5tPP19+mk/l/8vp5bfFxearo8ZBI+fewxqqCZWKm3n8raAK3ItaGMdwsepl262esju8HPXyUR9rSVa/BQ67DEc9KyrhwWmdLPECcsopvJZHeWI2rXwmynAXC1xZWRbkL6pJgsbX8sPuioV5R16GYov8pwY09oGNMV0kuAukEpcrlt3k7sSx5jTaZ6RU8cDMWYU0juVBADQ7Kjg+JQm7n7CQJZLxgpB4SaNb7h4c8n5FcApkTEwAHu0wVmoWjhQNVrXBrjY4pTIMGtyi4UzB4BwLBqccDE0LTx4OWCUKKkwQTu6wfPV+S3EBVs7ojmZIV8W6Rj9nbNg/Hhvn87x7zPNubVUsJ7mF221OKvv8H9FVGn88tUC6Zc9XXdvkOjBymVCfSNHBIfJ21JfcgSRJQIoNE3r5XhSEBHY88amMKu9VfYkjXXydTeRw9Cu9vlGna3MWkAmX8BlQGh9K+zL4W9DkDimdh8s9LOPgrV2sjrqMkWG0mVjdHvIDHqBPFpeX08n62+KXkksRQ267Sie4Vmbe7VcW7ndkLo+FQIEtfSBBmbqiv5PSoZtIgQriJU1VHuJWJCsShIL1wVWTSNBgI/WJSHFt1El0HSjyGI8WNR6wJD8SDXTNak7Fozcv3JMN/9vsUDUxflUsNlpnnoITtPuMCF3iaev3iGZN4Lg6Eyx8YpqBfpahthdcPmYMdnJ1qGvlITsjd/KIT+NbUrHaaED1NapAab2ssIDeQaiYzhn9YC2dsfufPfjR/vhvbn/wEvaDgpQneM9EwPirEMAq
ybsly4Rtada4zJU4GqbZsEQXE201qzDh7A0LtnOtSSpWjlmIQwfnH1pceGgLybHx4/OPX17FWgaHJXD6ECu3Qpcv64nc/6H9wjtUU3do/cr2ibplcfIBUEw92cckCSgNNhnKJrzVaTHJlCcAqN9asWkxy4MftPHJU2cFgo3EpvVESZzn9y8qpx3qnfDbNvF2tatEzsJ2MYsgwH8joohVIgYV+pxFIuVVDL0KA2Cvk6vy0QkqF7FKSuYjcG9Ub7pKLCt+q1hisQu0Vzd0q/IGK5/pioAG6qcbuBTmRG5diap3/Q8htyWirRG1mDNrPfPQq6AmBi3Cr4m8UleodfItjVGnQA6Nd3sJTiKcIYDZhN9LLyaLJ5SxwD4/AMA7lXMB34xB7l7K4ZXVRVEDab4cesznb3NN0z9DvWs21LuioVdt6J+9Luodq4t6teORyiF3cTwyELQ6qm+7JnojWdF7SfReEp0/JX4rBwKnaqKXy9ZOliMvm6i+lwLvpUBLKaCD+14JvFcC75VAvRKAhtUNS7KGUsDRSwFMbOUUvJQvlf4fS4H+sVKgXy4FGl915NUAJPaC3MFnmB3+LrbzT+L5N+L29F9PujIxTfX2eREd2eI0utrginOQvkbUd7ciia1ziASr4IBv4ynjmfW8eGway7FwhoynS0FXCgDebvkq75Vv+s52I3e+i/nBsXAb1MKt/kimuJVzkSxCq0PTTrKPIpjOTwoy96e6kP0J3TQ85qbhj1yZ91uuzJ/kpzdxcY4PitT3t31zLvWAbTkiPv4KI82dgL8dMXKt+FJMwkC672L6+dP32VoBnCeA5UcWQMq85Fpkcvot/KMQbz5bvNkuvp+Lt15C/CAXbz9b/KBd/DAX7zxbvNsuvpeLd18CHCsX33u2eKtdvJ2L7z9bvN0u3smXRPIABZA2F8qP7lQZRYymkwwkmM1P3mpPlJySpIZlrxBWX9mQZrWsYEizW9av2nOZXosWX7TfRtWPXIVeleOgXKcyKo+6Ro2HmMRpPqasn3qZany3Nr4cptd2JFI7EP9bWj7Qt5ozR14to3j1CO/rzxWJcaSUkGo05fklRRoMsI8Y4JwEyn5Jhzyq99dp5kVZql4S89Y7L6H4kroUXXdmUZQVZ0Uy9YDQyn+Yaslo7rA8nF15oiRZTfuDKtQx79B+oxqw/VVY/GAVV1tMBU3RECcE6j4tRwOoEu/+2MgDztE0OM4jPyRe0kQcSlouWk3RkmSFUyMHIgx2e1AH5+g+/g/LoCAY
:fxdreema>*/
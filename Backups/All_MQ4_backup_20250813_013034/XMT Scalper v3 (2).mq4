// -------------------------------------------------------------------------------------------------
//                                        XMT-Scalper V3.0 
//
//                       				  	
//                            
//
//
// -------------------------------------------------------------------------------------------------

#property copyright ""
#property link      ""
//#property show_inputs
#include <stdlib.mqh>

//----------------------- Externals ----------------------------------------------------------------
// All inputals here have their name starting with a CAPITAL character

input string Configuration = "==== Configuration ====";
input int Magic = -1;								
input string OrderCmt = "";						
input bool ECN_Mode = FALSE;						
input bool Debug = FALSE;					
input bool Verbose = FALSE;						
input bool VirtualPendingOrders = true;
input bool VirtualStops = true;

input string TradingSettings = "==== Trade settings ====";
input double MaxSpread = 30.0;           	
input int MaxExecution = 0;						
input int MaxExecutionMinutes = 5;				
input double TakeProfit = 10.0;					
input double StopLoss = 60.0;					
input double TrailingStart = 0;					
input double Commission = 0;						
input int Slippage = 3;							
input bool UseDynamicVolatilityLimit = TRUE;
input double VolatilityMultiplier = 125;    
input double VolatilityLimit = 180;			
input bool UseVolatilityPercentage = TRUE;	
input double VolatilityPercentageLimit = 60;
input bool UseMovingAverage = TRUE;  			
input bool UseBollingerBands = TRUE;  		
input double Deviation = 1.50; 					
input int OrderExpireSeconds = 3600;			
input string Money_Management = "==== Money Management ====";
input bool MoneyManagement = TRUE;				
input double MinLots = 0.01;						
input double MaxLots = 100.0;					
input double Risk = 2.0;							
input double ManualLotsize = 0.1;				
input string Screen_Shooter = "==== Screen Shooter ====";
input bool TakeShots = FALSE;					
input int DelayTicks = 1; 						
input int ShotsPerBar = 1; 						


input string _tmp50_ = " --- Virtual Orders: graphic ---";
input ENUM_BASE_CORNER VOrdText_corner = CORNER_RIGHT_UPPER;
input int    VOrdText_x = 25;
input int    VOrdText_dx = 60;
input int    VOrdText_y = 20;
input int    VOrdText_dy = 14;
input string VOrdText_font = "Arial";
input int    VOrdText_font_size = 8;
input color  VOrdText_font_color = clrGold;


//--------------------------- Globals --------------------------------------------------------------
// All globals have their name written in lower case characters

string ea_version = "XMT-Scalper V3.0";

int indicatorperiod = 3;	
int brokerdigits = 0;		
int globalerror = 0;			
int lasttime = 0;				
int tickcounter = 0;			
int upto30counter = 0;		
int execution = -1;			
int avg_execution = 0;		
int execution_samples = 0;	
int starttime;					
int leverage;					
int lotbase;					
int err_busyserver;
int err_lostconnection;
int err_toomanyrequest;
int err_invalidprice;
int err_invalidstops;
int err_invalidtradevolume;
int err_pricechange;
int err_brokerbuzy;
int err_requotes;
int err_toomanyrequests;
int err_trademodifydenied;
int err_tradecontextbuzy;	

double array_spread[30];	
double lotsize;				
double highest;				
double lowest;					
double stoplevel;				
double stopout;				
double lotstep;				
double marginforonelot;		

int skipedticks=0;
int ticks_samples=0;
double avg_tickspermin=0;

double vStopLoss;
double vTakeProfit;
double vManualLotsize;
double vRisk;
double vMinLots;
double vMaxLots;
double vVolatilityPercentageLimit;
double vVolatilityLimit;
double vVolatilityMultiplier;
double vCommission;
double vTrailingStart;
int vMaxExecutionMinutes;
int vMagic;


#define VO_MAX   1000

int a_N = 0;
int a_tickets[VO_MAX];
int a_type[VO_MAX];
string a_symbol[VO_MAX];
double a_volume[VO_MAX];
double a_open_price[VO_MAX];
double a_sl[VO_MAX];
double a_tp[VO_MAX];
int a_magic[VO_MAX];
string a_comment[VO_MAX];
color a_color[VO_MAX];

int vo_sel_ind;

string vo_prefix;


//======================= Program initialization ===================================================

void OnInit()
{
  string prefix = WindowExpertName() + "_";
  vo_prefix = prefix + "vo_";
  
  //-----
  
  if (IsTesting())
  {
    a_N = 0;
  }
  else
  {
    if (a_N == 0) LoadStops();
  }
  
  
	// Print short message at the start of initalization
	Print ("====== Initialization of ", ea_version, " ======");
	
	// Reset time for execution control
	starttime = TimeLocal();
	
	// Reset error variable
	globalerror = -1;
	
	// Get the broker decimals
	brokerdigits = Digits; 
	
	// Get leverage
	leverage = AccountLeverage();

	// Calculate stoplevel as max of either STOPLEVEL or FREEZELEVEL
	stoplevel = MathMax(MarketInfo(Symbol(), MODE_FREEZELEVEL), MarketInfo(Symbol(), MODE_STOPLEVEL));
	
	// Get stoput level and re-calculate as fraction
	stopout = AccountStopoutLevel();
		
	// Calculate lotstep
	lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);

  vStopLoss = StopLoss;
  vTakeProfit = TakeProfit;
  vManualLotsize = ManualLotsize;
  vRisk = Risk;
  vMinLots = MinLots;
  vMaxLots = MaxLots;
  vVolatilityPercentageLimit = VolatilityPercentageLimit;
  vVolatilityLimit = VolatilityLimit;
  vVolatilityMultiplier = VolatilityMultiplier;
  vCommission = Commission;
  vTrailingStart = TrailingStart;
  vMaxExecutionMinutes = MaxExecutionMinutes;
  vMagic = Magic;
		
	// Adjust SL and TP to broker stoplevel if they are less than this stoplevel
	if (vStopLoss < stoplevel)
		vStopLoss = stoplevel;
	if (vTakeProfit < stoplevel)
		vTakeProfit = stoplevel;
	
	// Re-calculate variables 
	vVolatilityPercentageLimit = vVolatilityPercentageLimit / 100.0 + 1.0;
   vVolatilityMultiplier = vVolatilityMultiplier / 10.0;
   ArrayInitialize(array_spread, 0);
	vVolatilityLimit = vVolatilityLimit * Point;
	vCommission = sub_normalizebrokerdigits(vCommission * Point);
	vTrailingStart = vTrailingStart * Point;
	stoplevel = stoplevel * Point;
		
	// If we have set MaxLot and/or MinLots to more/less than what the broker allows, then adjust it accordingly
	if (vMinLots < MarketInfo(Symbol(), MODE_MINLOT))
		vMinLots = MarketInfo(Symbol(), MODE_MINLOT);
	if (vMaxLots > MarketInfo(Symbol(), MODE_MAXLOT))
		vMaxLots = MarketInfo(Symbol(), MODE_MAXLOT);
	if (vMaxLots < vMinLots)
		vMaxLots = vMinLots;

	// Calculate margin required for 1 lot
	marginforonelot = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
	
	// Amount of money in base currency for 1 lot
	lotbase = MarketInfo(Symbol(), MODE_LOTSIZE);
	
	// Also make sure that if the risk-percentage is too low or too high, that it's adjusted accordingly
	sub_recalculatewrongrisk();
	
	// Calculate intitial lotsize 
	lotsize = sub_calculatelotsize();	
	
	// If magic number is set to a value less than 0, then calculate MagicNumber automatically
	if (vMagic < 0)
	  sub_magicnumber();
	
	// If execution speed should be measured, then adjust maxexecution from minutes to seconds	 
	if (MaxExecution > 0) 
		vMaxExecutionMinutes = MaxExecution * 60;
	
	// Print initial info 
	sub_printdetails();
		
	// Print short message at the end of initialization
	Print ("========== Initialization complete! ===========\n");
	
	// Finally call the main trading subroutine
  OnTick();
}

//======================= Program deinitialization =================================================

void OnDeinit(const int reason)
{
	// Print summarize of broker errors
	sub_printsumofbrokererrors();

	// Print short message when EA has been deinitialized
	Print (ea_version, " has been deinitialized!");
}

//==================================== Program start ===============================================

void OnTick() 
{
  //-----

  bool bDraw = true;
  if (IsTesting() && !IsVisualMode()) bDraw = false;
  if (IsOptimization()) bDraw = false;

  if (VirtualPendingOrders)
  {
    VO_CheckPendingOrders();
  }

  VO_UpdatePOType();

  if (VirtualStops)
  {  
    VO_CheckStops();
    VO_ClearStops();
  }
  
  //-----
  
	// We must wait til we have enough of bar data before we call trading routine
	//Print("bars= ", iBars(Symbol(),PERIOD_M1));
	if (iBars(Symbol(),PERIOD_M1) > indicatorperiod)
		sub_trade();
	else
		Print ("Please wait until enough of bar data has been gathered!");
		  
  //-----

  if (VirtualPendingOrders || VirtualStops)
  {
    if (bDraw)
    {
      VO_DrawStops();
    }
  }

  //-----
}


//================================ Subroutines starts here =========================================
// All subs have their names starting with sub_
// Exception are the standard routines init() and start()
//
// Notation:
// All actual and formal parameters in subs have their names starting with par_
// All local variables in subs have thewir names starting with local_

// This is the main trading subroutine
void sub_trade() 
{
   string local_textstring;
	string local_pair;
	
   bool local_wasordermodified;
	bool local_ordersenderror;	
	bool local_isbidgreaterthanima;	  
	bool local_isbidgreaterthanibands;
	bool local_isbidgreaterthanindy; 

   int local_orderticket;
   int local_orderexpiretime;
   //int local_lotstep;
	int local_loopcount2;	
	int local_loopcount1;	
	int local_pricedirection;	
   int local_counter1;
   int local_counter2;	
	//int local_paircounter;
	int local_askpart;
	int local_bidpart;

	double local_ask;
	double local_bid;		
   double local_askplusdistance;
   double local_bidminusdistance;
	double local_volatilitypercentage;
   //double local_trailingdistance;
   double local_orderstoploss;
   double local_ordertakeprofit;
   double local_tpadjust;
	double local_ihigh;	
   double local_ilow;	
	double local_imalow;	
   double local_imahigh;
   double local_imadiff;	
   double local_ibandsupper;
   double local_ibandslower;	
   double local_ibandsdiff;
   double local_volatility;
   double local_spread;
   double local_avgspread;	
   double local_realavgspread;
	double local_fakeprice;
	double local_sumofspreads;	
	double local_askpluscommission;
   double local_bidminuscommission;	
   double local_skipticks;
   
   bool bRC;
	
	// Count tics
	if (lasttime < Time[0]) 
	{
		// Consider only 10 samples at most.
		if (ticks_samples < 10) 
         		ticks_samples++; 
		avg_tickspermin = avg_tickspermin + (tickcounter - avg_tickspermin) / ticks_samples;
		lasttime = Time[0];
		tickcounter = 0;
	} 
	else 
		tickcounter++;
 		
	// if testing and MaxExecution is set let's skip a proportional number of ticks them in order to 
	// reproduce the effect of latency on this EA
	if (IsTesting() && MaxExecution!=0 && execution!=-1) {
		local_skipticks=MathRound(avg_tickspermin * MaxExecution/(60*1000));
		if (skipedticks>=local_skipticks) {
			execution=-1;
			skipedticks=0;
		}
		else {
			skipedticks++;
			// Print("Skip tick " + skipticks);
			return;
		}
	}

	// Get Ask and Bid for the currency
	local_ask = MarketInfo(Symbol(), MODE_ASK);
	local_bid = MarketInfo(Symbol(), MODE_BID);

	// Calculate the channel of Volatility based on the difference of iHigh and iLow during current bar
	local_ihigh = iHigh(Symbol(), PERIOD_M1, 0);
	local_ilow = iLow(Symbol(), PERIOD_M1, 0);
	local_volatility = local_ihigh - local_ilow;  
	
	// Calculate a channel on MovingAverage, and check if the price is outside of this channel
	local_imalow = iMA(Symbol(), PERIOD_M1, indicatorperiod, 0, MODE_LWMA, PRICE_LOW, 0);
	local_imahigh = iMA(Symbol(), PERIOD_M1, indicatorperiod, 0, MODE_LWMA, PRICE_HIGH, 0);
	local_imadiff = local_imahigh - local_imalow;
	local_isbidgreaterthanima = local_bid >= local_imalow + local_imadiff / 2.0;  
   
	// Calculate a channel on BollingerBands, and check if the prcice is outside of this channel
	local_ibandsupper = iBands(Symbol(), PERIOD_M1, indicatorperiod, Deviation, 0, PRICE_OPEN, MODE_UPPER, 0);
	local_ibandslower = iBands(Symbol(), PERIOD_M1, indicatorperiod, Deviation, 0, PRICE_OPEN, MODE_LOWER, 0);
	local_ibandsdiff = local_ibandsupper - local_ibandslower;
	local_isbidgreaterthanibands = local_bid >= local_ibandslower + local_ibandsdiff / 2.0;
   
	// Calculate the highest and lowest values depending on which indicators to be used
	local_isbidgreaterthanindy = FALSE;	
	if (UseMovingAverage == FALSE && UseBollingerBands == TRUE && local_isbidgreaterthanibands == TRUE)
	{
		local_isbidgreaterthanindy = TRUE;
		highest = local_ibandsupper;
		lowest = local_ibandslower; 
	}
	else if (UseMovingAverage == TRUE && UseBollingerBands == FALSE && local_isbidgreaterthanima == TRUE)
	{
		local_isbidgreaterthanindy = TRUE; 
		highest = local_imahigh;
		lowest = local_imalow;
	}
	else if (UseMovingAverage == TRUE && UseBollingerBands == TRUE && local_isbidgreaterthanima == TRUE && local_isbidgreaterthanibands == TRUE)
	{
		local_isbidgreaterthanindy = TRUE;
		highest = MathMax(local_ibandsupper, local_imahigh);
		lowest = MathMin(local_ibandslower, local_imalow);
	}	

	// Calculate spread, adjuststoplevel, orderexpiretime and lotsize	
	local_spread = local_ask - local_bid;	
	local_orderexpiretime = TimeCurrent() + OrderExpireSeconds;		
	local_orderexpiretime = TimeCurrent() + OrderExpireSeconds;
	lotsize = sub_calculatelotsize();

	// Calculate average true spread, which is the average of the spread for the last 30 tics
	ArrayCopy(array_spread, array_spread, 0, 1, 29);
	array_spread[29] = local_spread;
	if (upto30counter < 30) 
		upto30counter++;
	local_sumofspreads = 0;
	local_loopcount2 = 29;
	for (local_loopcount1 = 0; local_loopcount1 < upto30counter; local_loopcount1++) 
	{
		local_sumofspreads += array_spread[local_loopcount2];
		local_loopcount2--;
	}
	
	// Calculate an average of spreads based on the spread from the last 30 tics
	local_avgspread = local_sumofspreads / upto30counter;
   
	// Calculate price and spread considering commission
	local_askpluscommission = sub_normalizebrokerdigits(local_ask + vCommission);
	local_bidminuscommission = sub_normalizebrokerdigits(local_bid - vCommission);
	local_realavgspread = local_avgspread + vCommission;
	
	// Recalculate the VolatilityLimit if it's set to dynamic. It's based on the average of spreads + commission
	if (UseDynamicVolatilityLimit == TRUE)
		vVolatilityLimit = local_realavgspread * vVolatilityMultiplier;
			
	// Reset pricedirection to for no indication of trading direction 
	local_pricedirection = 0;

	//	// If the variables below have values it means that we have enough of data from broker server
	if (local_volatility && vVolatilityLimit && lowest && highest)
	{ 
		// The Volatility is outside of the VolatilityLimit, so we can now open a trade
		if (local_volatility > vVolatilityLimit)
		{
			// Calculate how much it differs
			local_volatilitypercentage = local_volatility / vVolatilityLimit;
			// In case of UseVolatilityPercentage == TRUE then also check if it differ enough of percentage
			if ((UseVolatilityPercentage == FALSE) || (UseVolatilityPercentage == TRUE && local_volatilitypercentage > vVolatilityPercentageLimit))
			{
				if (local_bid < lowest)            	
					local_pricedirection = -1; // BUY or BUYSTOP
				else if (local_bid > highest)    	
					local_pricedirection = 1;  // SELL or SELLSTOP
			}
		}
		else
			local_volatilitypercentage = 0;
	}    
   	
  	// Out of money 
	if (AccountBalance() <= 0.0) 
	{
		Comment("ERROR -- Account Balance is " + DoubleToStr(MathRound(AccountBalance()), 0));
		return;
	}

	// Reset execution time	
	execution = -1; 
	
	// Reset counters
	local_counter1 = 0;
	local_counter2 = 0;
		
	// Loop through all open orders (if any) to either modify them or delete them
	for (local_loopcount2 = 0; local_loopcount2 < OrdersTotalEx(); local_loopcount2++) 
	{
		bRC = OrderSelectEx(local_loopcount2, SELECT_BY_POS, MODE_TRADES);
		// We've found an that matches the magic number and is open
		if (OrderMagicNumberEx() == vMagic /*&& OrderCloseTime() == 0*/) 
		{
			// If the order doesn't match the currency pair from the chart then check next open order
			if (OrderSymbolEx() != Symbol())
			{
				local_counter2++;
				continue;
			}

			// Select order by type of order
			switch (OrderTypeEx()) 
			{
			// We've found a matching BUY-order
			case OP_BUY:
				// Start endless loop
				while (true) 
				{
					local_orderstoploss = OrderStopLossEx();
					local_ordertakeprofit = OrderTakeProfitEx();	
					//	Ok to modify the order if its TP is less than the price+commission+stoplevel AND price+SL-TP is greater than trailingStart			
					if (local_ordertakeprofit < sub_normalizebrokerdigits(local_askpluscommission + stoplevel) && local_askpluscommission + stoplevel - local_ordertakeprofit > vTrailingStart) 
					{
						local_orderstoploss = sub_normalizebrokerdigits(local_bid - stoplevel);
						local_ordertakeprofit = sub_normalizebrokerdigits(local_askpluscommission + stoplevel);
						execution = GetTickCount();
						local_wasordermodified = OrderModifyEx(OrderTicketEx(), 0, local_orderstoploss, local_ordertakeprofit, local_orderexpiretime, Lime);
						// Order was modified with new SL and TP
						if (local_wasordermodified > 0) 
						{ 
							// Calculate execution speed
							execution = GetTickCount() - execution;
							// If we have choosen to take snapshots and we're not backtesting, then do so
							if (TakeShots && !IsTesting()) 
								sub_takesnapshot();
						}
						// Order was not modified
						else 
						{
							// Reset execution counter
							execution = -1;
							// Add to errors
							sub_errormessages();
						}
					}	
					// Break out from endless loop
					break;
				}
				// count 1 more up
				local_counter1++;
				// Break out from switch
				break;
				
			// We've found a matching SELL-order	
			case OP_SELL:
				// Start endless loop
				while (true) 
				{
					local_orderstoploss = OrderStopLossEx();
					local_ordertakeprofit = OrderTakeProfitEx();
					// Ok to modify the order if its TP is greater than price-commission-SL AND TP-price-commission+stoplevel is greater than trailingstart
					if (local_ordertakeprofit > sub_normalizebrokerdigits(local_bidminuscommission - stoplevel) && local_ordertakeprofit - local_bidminuscommission + stoplevel > vTrailingStart) 
					{					
						local_orderstoploss = sub_normalizebrokerdigits(local_ask + stoplevel);
						local_ordertakeprofit = sub_normalizebrokerdigits(local_bidminuscommission - stoplevel);
						execution = GetTickCount(); 
						local_wasordermodified = OrderModifyEx(OrderTicketEx(), 0, local_orderstoploss, local_ordertakeprofit, local_orderexpiretime, Orange);
						// Order was modiified with new SL and TP
						if (local_wasordermodified > 0) 
						{ 
							// Calculate execution speed
							execution = GetTickCount() - execution;
							// If we have choosen to take snapshots and we're not backtesting, then do so							
							if (TakeShots && !IsTesting()) 
								sub_takesnapshot();
						}
						// Order was not modified
						else 
						{
							// Reset execution counter
							execution = -1;
							// Add to errors
							sub_errormessages();
						}
					}	
					// Break out from endless loop
					break;
				}
				// count 1 more up
				local_counter1++;
				// Break out from switch
				break;

			// We've found a matching BUYSTOP-order					
			case OP_BUYSTOP:
				// Price must NOT be larger than indicator in order to modify the order, otherwise the order will be deleted
				if (local_isbidgreaterthanindy == FALSE) 
				{
					// Beside stoplevel, this is how much the SL and TP are changed 
					local_tpadjust = OrderTakeProfitEx() - OrderOpenPriceEx() - vCommission;
					// Start endless loop
					while (true) 
					{
						// Ok to modify the order if price+stoplevel is less than orderprice AND orderprice-price-stoplevel is greater than trailingstart
						if (sub_normalizebrokerdigits(local_ask + stoplevel) < OrderOpenPriceEx() && OrderOpenPriceEx() - local_ask - stoplevel > vTrailingStart) 
						{
							execution = GetTickCount();
							local_wasordermodified = OrderModifyEx(OrderTicketEx(), sub_normalizebrokerdigits(local_ask + stoplevel), sub_normalizebrokerdigits(local_bid + stoplevel - local_tpadjust), sub_normalizebrokerdigits(local_askpluscommission + stoplevel + local_tpadjust), 0, Lime);							
							// Order was modified
							if (local_wasordermodified > 0) 
							{
								// Calculate execution speed
								execution = GetTickCount() - execution;
								if (Debug || Verbose) 
									Print ("Order executed in " + execution + " ms");
							}
							// Order was not modified
							else 
							{
								// Reset execution counter
								execution = -1;
								// Add to errors
								sub_errormessages();
							}
						}
						// Break out from endless loop
						break;
					}
					// count 1 more up
					local_counter1++;
				} 
				// Price was larger than the indicator, so delete the order
				else 
					bRC = OrderDeleteEx(OrderTicketEx());
				// Break out from switch
				break;
				
			// We've found a matching SELLSTOP-order				
			case OP_SELLSTOP:
				// Price must be larger than the indicator in order to modify the order, otherwise the order will be deleted
				if (local_isbidgreaterthanindy == TRUE) 
				{
					// Beside stoplevel, this is how much the SL and TP are changed 
					local_tpadjust = OrderOpenPriceEx() - OrderTakeProfitEx() - vCommission;
					// Endless loop
					while (true) 
					{
						// Ok to modify order if price-stoplevel is greater than orderprice AND price-stoplevel-orderprice is greater than trailingstart
						if (sub_normalizebrokerdigits(local_bid - stoplevel) > OrderOpenPriceEx() && local_bid - stoplevel - OrderOpenPriceEx() > vTrailingStart) 
						{
							execution = GetTickCount(); 
							local_wasordermodified = OrderModifyEx(OrderTicketEx(), sub_normalizebrokerdigits(local_bid - stoplevel), sub_normalizebrokerdigits(local_ask - stoplevel + local_tpadjust), sub_normalizebrokerdigits(local_bidminuscommission - stoplevel - local_tpadjust), 0, Orange);
							// Order was modified
							if (local_wasordermodified > 0)
							{
								// Calculate execution speed
								execution = GetTickCount() - execution;
								if (Debug || Verbose) 
									Print ("Order executed in " + execution + " ms");
							}
							// Order was not modified
							else 
							{
								// Reset execution counter
								execution = -1;
								// Add to errors
								sub_errormessages();
							}
						}
						// Break out from endless loop
						break;
					}
					// count 1 more up
					local_counter1++;
				} 
				// Price was NOT larger than the indicator, so delete the order
				else 
					bRC = OrderDeleteEx(OrderTicketEx());
			} // end of switch
		}  // end if OrderMagicNumber
	} // end for loopcount2 - end of loop through open orders
		
	// Calculate and keep track on global error number 
	if (globalerror >= 0 || globalerror == -2) 
	{
		local_bidpart = NormalizeDouble(local_bid / Point, 0);
		local_askpart = NormalizeDouble(local_ask / Point, 0);
		if (local_bidpart % 10 != 0 || local_askpart % 10 != 0) 
			globalerror = -1;
		else 
		{
			if (globalerror >= 0 && globalerror < 10) 
				globalerror++;
			else 
				globalerror = -2;
		}
	}
		
	// Reset error-variable
	local_ordersenderror = FALSE;
	
	// Before executing new orders, lets check the average execution time.
	if (local_pricedirection != 0 && MaxExecution > 0 && avg_execution > MaxExecution) 
	{   
		local_pricedirection = 0; // Ignore the order opening triger
		if (Debug || Verbose)
			Print("Server is too Slow. Average Execution: " + avg_execution);
	}

	// If we have no open orders AND a price breakout AND average spread is less or equal to max allowed spread AND we have no errors THEN proceed
	if (local_counter1 == 0 && local_pricedirection != 0 && sub_normalizebrokerdigits(local_realavgspread) <= sub_normalizebrokerdigits(MaxSpread * Point) && globalerror == -1) 
	{
		// If we have a price breakout downwards (Bearish) then send a SELLSTOP order
		if (local_pricedirection < 0) // Send a BUYSTOP
		{			
			execution = GetTickCount(); 
			local_askplusdistance = local_ask + stoplevel;
			// SL and TP is not sent with order, but added afterwords in a OrderModify command
			if (ECN_Mode == TRUE) 
			{
				// Send BUYSTOP order without SL and TP
				local_orderticket = OrderSendEx(Symbol(), OP_BUYSTOP, lotsize, local_askplusdistance, Slippage, 0, 0, OrderCmt, vMagic, 0, Lime);             
				// OrderSend was executed successfully
				if (local_orderticket > 0) 
				{
					// Calculate execution speed
					execution = GetTickCount() - execution;
					if (Debug || Verbose) 
						Print ("Order executed in " + execution + " ms");
					PlaySound("news.wav");
					Print("BUYSTOP: " + sub_dbl2strbrokerdigits(local_ask + stoplevel) + " SL: " + sub_dbl2strbrokerdigits(local_bid + stoplevel) + " TP: " + sub_dbl2strbrokerdigits(local_askpluscommission + stoplevel));
					// If we have choosen to take snapshots and we're not backtesting, then do so			
					if (TakeShots && !IsTesting()) 
						sub_takesnapshot();
				}  // end if ordersend
				// OrderSend was NOT executed
				else
				{
					local_ordersenderror = TRUE;
					Print("ERROR OrderSend BUYSTOP : " + sub_dbl2strbrokerdigits(local_ask + stoplevel) + " SL:" + sub_dbl2strbrokerdigits(local_bid + stoplevel) + " TP:" + sub_dbl2strbrokerdigits(local_askpluscommission + stoplevel));
					execution = -1;
					// Add to errors
					sub_errormessages();
				} 
				// OrderSend was executed successfully, so now modify it with SDL and TP				
				if (OrderSelectEx(local_orderticket, SELECT_BY_TICKET))  
				{					
					local_wasordermodified = OrderModifyEx(OrderTicketEx(), OrderOpenPriceEx(), local_askplusdistance - vStopLoss * Point, local_askplusdistance + vTakeProfit * Point, local_orderexpiretime, Lime);
					// OrderModify was executed successfully
					if (local_wasordermodified > 0) 				
					{
						// Calculate execution speed
						execution = GetTickCount() - execution;
						if (Debug || Verbose) 
							Print ("Order executed in " + execution + " ms");
						PlaySound("news.wav");
						Print("BUYSTOP: " + sub_dbl2strbrokerdigits(local_ask + stoplevel) + " SL: " + sub_dbl2strbrokerdigits(local_bid + stoplevel) + " TP: " + sub_dbl2strbrokerdigits(local_askpluscommission + stoplevel));
						// If we have choosen to take snapshots and we're not backtesting, then do so			
						if (TakeShots && !IsTesting()) 
							sub_takesnapshot();
					} // end successful ordermodiify
					// Order was NOT modified
					else
					{
						local_ordersenderror = TRUE;
						Print("ERROR OrderModify BUYSTOP: " + sub_dbl2strbrokerdigits(local_ask + stoplevel) + " SL: " + sub_dbl2strbrokerdigits(local_bid + stoplevel) + " TP: " + sub_dbl2strbrokerdigits(local_askpluscommission + stoplevel));
						execution = -1;
						// Add to errors
						sub_errormessages();
					} // end if-else					
				}  // end if ordermodify					
			} // end if ECN_Mode
			
			// No ECN-mode, SL and TP can be sent directly
			else 
			{
				// Send BUYSTOP order with SL and TP 
/*				
				Print(
				  "vStopLoss= ", vStopLoss, 
				  ", vTakeProfit= ", vTakeProfit, 
				  ", Ask= ", DoubleToStr(Ask, Digits),
				  ", local_askplusdistance= ", DoubleToStr(local_askplusdistance, Digits), 
				  ", sl= ", DoubleToStr(local_askplusdistance - vStopLoss * Point, Digits), 
				  ", tp= ", DoubleToStr(local_askplusdistance + vTakeProfit * Point, Digits), 
				  ", point= ", DoubleToStr(Point(), Digits));
*/				  
				local_orderticket = OrderSendEx(Symbol(), OP_BUYSTOP, lotsize, local_askplusdistance, Slippage, local_askplusdistance - vStopLoss * Point, local_askplusdistance + vTakeProfit * Point, OrderCmt, vMagic, local_orderexpiretime, Lime);
				if (local_orderticket > 0) // OrderSend was executed suxxessfully
				{
					// Calculate execution speed
					execution = GetTickCount() - execution;
					if (Debug || Verbose) 
						Print ("Order executed in " + execution + " ms");
					PlaySound("news.wav");
					Print("BUYSTOP: " + sub_dbl2strbrokerdigits(local_ask + stoplevel) + " SL: " + sub_dbl2strbrokerdigits(local_bid + stoplevel) + " TP: " + sub_dbl2strbrokerdigits(local_askpluscommission + stoplevel));
					// If we have choosen to take snapshots and we're not backtesting, then do so			
					if (TakeShots && !IsTesting()) 
						sub_takesnapshot();
				} // end successful ordersend
				// Order was NOT sent
				else
				{
					local_ordersenderror = TRUE;
					Print("ERROR BUYSTOP : " + sub_dbl2strbrokerdigits(local_ask + stoplevel) + " SL:" + sub_dbl2strbrokerdigits(local_bid + stoplevel) + " TP:" + sub_dbl2strbrokerdigits(local_askpluscommission + stoplevel));
					execution = -1;
					// Add to errors
					sub_errormessages();
				} // end if-else
			} // end no ECN-mode
		} // end local_pricedirection < 0
		
		// If we have a price breakout upwards (Bullish) then send a SELLSTOP order
		else if (local_pricedirection > 0) 
		{
			local_bidminusdistance = local_bid - stoplevel;
			execution = GetTickCount();
			// SL and TP cannot be sent with order, but must be sent afterwords in a modify command
			if (ECN_Mode) 
			{
				// Send SELLSTOP without SL and TP 
				local_orderticket = OrderSendEx(Symbol(), OP_SELLSTOP, lotsize, local_bidminusdistance, Slippage, 0, 0, OrderCmt, vMagic, 0, Orange);                
				if (OrderSelectEx(local_orderticket, SELECT_BY_TICKET)) 
					local_wasordermodified = OrderModifyEx(OrderTicketEx(), OrderOpenPriceEx(), local_bidminusdistance + vStopLoss * Point, local_bidminusdistance - vTakeProfit * Point, local_orderexpiretime, Orange);
				// OrderModify was executed successfully
				if (local_wasordermodified > 0)  
				{	
					// Calculate execution speed
					execution = GetTickCount() - execution;
					if (Debug || Verbose) 
						Print ("Order executed in " + execution + " ms");
					PlaySound("news.wav");
					Print("SELLSTOP: " + sub_dbl2strbrokerdigits(local_bid - stoplevel) + " SL: " + sub_dbl2strbrokerdigits(local_ask - stoplevel) + " TP: " + sub_dbl2strbrokerdigits(local_bidminuscommission - stoplevel));
					// If we have choosen to take snapshots and we're not backtesting, then do so	
					if (TakeShots && !IsTesting()) 
						sub_takesnapshot();
				} // end if ordermodify was executed successfully
				// Order was NOT executed
				else
				{
					local_ordersenderror = TRUE;
					Print("SELLSTOP : " + sub_dbl2strbrokerdigits(local_bid - stoplevel) + " SL: " + sub_dbl2strbrokerdigits(local_ask - stoplevel) + " TP: " + sub_dbl2strbrokerdigits(local_bidminuscommission - stoplevel));
					execution = -1;
					// Add to errors
					sub_errormessages();
				}	
			}
			else // No ECN-mode, SL and TP can be sent directly
			{			
				// Send SELLSTOP order
				local_orderticket = OrderSendEx(Symbol(), OP_SELLSTOP, lotsize, local_bidminusdistance, Slippage, local_bidminusdistance + vStopLoss * Point, local_bidminusdistance - vTakeProfit * Point, OrderCmt, vMagic, local_orderexpiretime, Orange);
				// OrderSend was executed successfully
				if (local_orderticket > 0) 
				{
					execution = GetTickCount() - execution;	
					if (Debug || Verbose) 
						Print ("Order executed in " + execution + " ms");
					if (TakeShots && !IsTesting()) 
						sub_takesnapshot();
					PlaySound("news.wav");
					Print("SELLSTOP : " + sub_dbl2strbrokerdigits(local_bid - stoplevel) + " SL: " + sub_dbl2strbrokerdigits(local_ask - stoplevel) + " TP: " + sub_dbl2strbrokerdigits(local_bidminuscommission - stoplevel));
				} // end successful ordersend
				// OrderSend was executed successfully
				else
				{
					local_ordersenderror = TRUE;
					Print("ERROR SELLSTOP: " + sub_dbl2strbrokerdigits(local_bid - stoplevel) + " SL: " + sub_dbl2strbrokerdigits(local_ask - stoplevel) + " TP: " + sub_dbl2strbrokerdigits(local_bidminuscommission - stoplevel));
					execution = -1;
					// Add to errors
					sub_errormessages();
				} // end if-else
			} // end no ECN-mode
		} // end local_pricedirection > 0			
	} // end if execute new orders
	
	// If we have no samples, every MaxExecutionMinutes a new OrderModify execution test is done
	if (MaxExecution && execution == -1 && (TimeLocal() - starttime) % vMaxExecutionMinutes == 0) 
	{
		// When backtesting, simulate random execution time based on the setting
		if (IsTesting() && MaxExecution) 
		{ 
			MathSrand(TimeLocal());
			execution = MathRand() / (32767 / MaxExecution);
	   }
	   else 
		{
	      // Unless backtesting, lets send a fake order to check the OrderModify execution time, 
			if (!IsTesting()) 
			{
				// To be sure that the fake order never is executed, st the price to twice the current price
				local_fakeprice = local_ask * 2.0;
				// Send a BUYSTOP order
				local_orderticket = OrderSendEx(Symbol(), OP_BUYSTOP, lotsize, local_fakeprice, Slippage, 0, 0, OrderCmt, vMagic, 0, Lime);             
				execution = GetTickCount(); 
				// Send a modify command where we adjust the price with +1 pip
				local_wasordermodified = OrderModifyEx(local_orderticket, local_fakeprice + 10 * Point, 0, 0, 0, Lime);	
				// Calculate execution speed
				execution = GetTickCount() - execution;
				// Delete the order
				bRC = OrderDeleteEx(local_orderticket);
			}
	   } 
	}
      
   // Do we have a valid execution sample? Update the average execution time.
	if (execution >= 0) 
	{
		// Consider only 10 samples at most.
	   if (execution_samples < 10) 
			execution_samples++; 
		// Calculate average execution speed
	   avg_execution = avg_execution + (execution - avg_execution) / execution_samples;
	}		
		
	// Check initialization 
	if (globalerror >= 0) 
		Comment("Robot is initializing...");
	else 
	{
		// Error
		if (globalerror == -2) 
			Comment("ERROR -- Instrument " + Symbol() + " prices should have " + brokerdigits + " fraction digits on broker account");
		// No errors, ready to print 
		else 
		{
			local_textstring = TimeToStr(TimeCurrent()) + " Tick: " + sub_adjust00instring(tickcounter) + " Ticks/min:" + avg_tickspermin;
			// Only show / print this if Debug OR Verbose are set to TRUE
			if (Debug || Verbose) 
			{
				local_textstring = local_textstring + "\n*** DEBUG MODE *** \nCurrency pair: " + Symbol() + ", Volatility: " + sub_dbl2strbrokerdigits(local_volatility) + ", vVolatilityLimit: " + sub_dbl2strbrokerdigits(vVolatilityLimit) + ", VolatilityPercentage: " + sub_dbl2strbrokerdigits(local_volatilitypercentage);
				local_textstring = local_textstring + "\nPriceDirection: " + StringSubstr("BUY NULLSELL", 4 * local_pricedirection + 4, 4) + ", ImaHigh: " + sub_dbl2strbrokerdigits(local_imahigh) + ", ImaLow: " + sub_dbl2strbrokerdigits(local_imalow) + ", BBandUpper: " + sub_dbl2strbrokerdigits(local_ibandsupper);
				local_textstring = local_textstring + ", BBandLower: " + sub_dbl2strbrokerdigits(local_ibandslower) + ", Expire: " + TimeToStr(local_orderexpiretime, TIME_MINUTES) + ", NumOrders: " + local_counter1;
				local_textstring = local_textstring + "\nTrailingLimit: " + sub_dbl2strbrokerdigits(stoplevel) + ", Stoplevel: " + sub_dbl2strbrokerdigits(stoplevel) + "; TrailingStart: " + sub_dbl2strbrokerdigits(vTrailingStart);
			}
			local_textstring = local_textstring + "\nBid: " + sub_dbl2strbrokerdigits(local_bid) + ", ASK: " + sub_dbl2strbrokerdigits(local_ask) + ", AvgSpread: " + sub_dbl2strbrokerdigits(local_avgspread) + ", Commission: " + sub_dbl2strbrokerdigits(vCommission) + ", RealAvgSpread: " + sub_dbl2strbrokerdigits(local_realavgspread) + ", Lots: " + DoubleToStr(lotsize, 5) + ", MinLots: " + DoubleToStr(vMinLots,5) + ", Execution: " + execution + " ms";         
			if (sub_normalizebrokerdigits(local_realavgspread) > sub_normalizebrokerdigits(MaxSpread * Point)) 
			{
				local_textstring = local_textstring + "\n" + "The current spread (" + sub_dbl2strbrokerdigits(local_realavgspread) +") is higher than what has been set as MaxSpread (" + sub_dbl2strbrokerdigits(MaxSpread * Point) + ") so no trading is allowed right now on this currency pair!";
			}
			if (MaxExecution > 0 && avg_execution > MaxExecution) 
			{
				local_textstring = local_textstring + "\n" + "The current Avg Execution (" + avg_execution +") is higher than what has been set as MaxExecution (" + MaxExecution+ " ms), so no trading is allowed right now on this currency pair!";
			}
			Comment(local_textstring);
			// Only print this if we have a any orders  OR have a price breakout OR Verbode mode is set to TRUE
			if (local_counter1 != 0 || local_pricedirection != 0 || Verbose) 
				sub_printformattedstring(local_textstring);
		} // end if-else
	} // end check initialization
} // end sub

// Convert a decimal number to a text string
string sub_dbl2strbrokerdigits(double par_a) 
{
   return (DoubleToStr(par_a, brokerdigits));
}

// Adjust numbers with as many decimals as the broker uses
double sub_normalizebrokerdigits(double par_a) 
{
   return (NormalizeDouble(par_a, brokerdigits));
}

// Adjust textstring with zeros at the end
string sub_adjust00instring(int par_a) 
{
   if (par_a < 10) 
		return ("00" + par_a);
   if (par_a < 100) 
		return ("0" + par_a);
   return ("" + par_a);
}

// Print out formatted textstring 
void sub_printformattedstring(string par_a) 
{
   int local_difference;
   int local_a = -1;

   while (local_a < StringLen(par_a)) 
	{
      local_difference = local_a + 1;
      local_a = StringFind(par_a, "\n", local_difference);
      if (local_a == -1) 
		{
         Print(StringSubstr(par_a, local_difference));
         return;
      }
      Print(StringSubstr(par_a, local_difference, local_a - local_difference));
   }
}

//  Magic Number - calculated from a sum of account number and ASCII-codes from currency pair                                                                           
void sub_magicnumber()
{
     string local_currpair = Symbol();
     int local_length = StringLen (local_currpair);
     int local_asciisum = 0;
     int local_counter;

     for (local_counter = 0; local_counter < local_length -1; local_counter++)
        local_asciisum += StringGetChar (local_currpair, local_counter);
     vMagic = AccountNumber() + local_asciisum;   
}

// Main routine for making a screenshoot / printscreen
void sub_takesnapshot()
{
	static datetime local_lastbar;
	static int local_doshot = -1;
	static int local_oldphase = 3000000;	
	int local_shotinterval;
	int local_phase;

	if (ShotsPerBar > 0)
		local_shotinterval = MathRound((60 * Period()) / ShotsPerBar);
	else
		local_shotinterval = 60 * Period();
	local_phase = MathFloor((CurTime() - Time[0]) / local_shotinterval);

	if (Time[0] != local_lastbar)
	{
		local_lastbar = Time[0];
		local_doshot = DelayTicks;
	}
	else if (local_phase > local_oldphase)
		sub_makescreenshot("i");

	local_oldphase = local_phase;

	if(local_doshot == 0) 
		sub_makescreenshot("");
	if(local_doshot >= 0) 
		local_doshot -= 1;

	return;
}

// add leading zeros that the resulting string has 'digits' length.
string sub_maketimestring(int par_number, int par_digits)
{
	string local_result;

	local_result = DoubleToStr(par_number, 0);
	while (StringLen(local_result) < par_digits) 
		local_result = "0" + local_result;
	
	return (local_result);
}

// Make a screenshoot / printscreen
void sub_makescreenshot(string par_sx = "")
{
	static int local_no = 0;

	local_no++;
	string fn = "SnapShot"+Symbol()+Period()+"\\"+Year()+"-"+sub_maketimestring(Month(),2)+"-"+sub_maketimestring(Day(),2)+" "+sub_maketimestring(Hour(),2)+"_"+sub_maketimestring(Minute(),2)+"_"+sub_maketimestring(Seconds( ),2)+" "+local_no+par_sx+".gif";
	if (!ScreenShot(fn,640,480)) 
		Print("ScreenShot error: ", ErrorDescription(GetLastError()));
}

// Calculate lotsize based on Equity, Risk (in %) and vStopLoss in points
double sub_calculatelotsize()
{
	string local_textstring;
   double local_availablemoney;
	double local_lotsize;
	double local_maxlot;
	double local_minlot;
	
	// Get available money as Equity
	local_availablemoney = AccountEquity();
	// Maximum allowed Lot by the broker according to Equity. And we don't use 100% but 98%
	local_maxlot = MathFloor(local_availablemoney * 0.98 / marginforonelot / lotstep) * lotstep;
	// Minimum allowed Lot by the broker
	local_minlot = vMinLots;
	// Lot according to Risk. Dont use 100% but 98% (= 102) to avoid 
	local_lotsize = MathFloor(vRisk / 102 * local_availablemoney / vStopLoss / lotstep) * lotstep;
	// Empty textstring
	local_textstring = "";	
	
	// Use manual fix lotsize, but if necessary adjust to within limits
	if (MoneyManagement == FALSE)
	{
		// Set lotsize to manual lotsize
		local_lotsize = vManualLotsize;
		// Check if vManualLotsize is greater than allowed lotsize
		if (vManualLotsize > local_maxlot)
		{
			local_lotsize = local_maxlot;
			local_textstring = "Note: Manual lotsize is too high. It has been recalculated to maximum allowed " + DoubleToStr(local_maxlot,2);
			Print (local_textstring);
			Comment (local_textstring);
			vManualLotsize = local_maxlot;
		}
		else if (vManualLotsize < local_minlot)
			local_lotsize = local_minlot;
	}
	
	return (local_lotsize);
}

// Re-calculate a new Risk if the current one is too low or too high
void sub_recalculatewrongrisk()
{
	string local_textstring;
	double local_availablemoney;
	double local_maxlot;
	double local_minlot;
	//double local_lotsize;
	double local_maxrisk;
	double local_minrisk;
   		
	// Get available amount of money as Equity
	local_availablemoney = AccountEquity();
	// Maximum allowed Lot by the broker according to Equity
	local_maxlot = MathFloor(local_availablemoney / marginforonelot / lotstep) * lotstep;
	// Maximum allowed Risk by the broker according to maximul allowed Lot and Equity
	local_maxrisk = MathFloor(local_maxlot * vStopLoss / local_availablemoney * 100 / 0.1) * 0.1;
	// Minimum allowed Lot by the broker
	local_minlot = vMinLots;
	// Minimum allowed Risk by the broker according to minlots_broker
	local_minrisk = MathRound(local_minlot * vStopLoss / local_availablemoney * 100 / 0.1) * 0.1;
	// Empty textstring
	local_textstring = "";
	

	if (MoneyManagement == TRUE)
	{
		// If Risk% is greater than the maximum risklevel the broker accept, then adjust Risk accordingly and print out changes
		if (vRisk > local_maxrisk)
		{
			local_textstring = local_textstring + "Note: Risk has manually been set to " + DoubleToStr(vRisk,1) + " but cannot be higher than " + DoubleToStr(local_maxrisk,1) + " according to ";
			local_textstring = local_textstring + "the broker, vStopLoss and Equity. It has now been adjusted accordingly to " + DoubleToStr(local_maxrisk,1) + "%";
			vRisk = local_maxrisk;
			sub_printandcomment(local_textstring);
		}
		// If Risk% is less than the minimum risklevel the broker accept, then adjust Risk accordingly and print out changes
		if (vRisk < local_minrisk)
		{
			local_textstring = local_textstring + "Note: Risk has manually been set to " + DoubleToStr(vRisk,1) + " but cannot be lower than " + DoubleToStr(local_minrisk,1) + " according to ";
			local_textstring = local_textstring + "the broker, vStopLoss and Equity. It has now been adjusted accordingly to " + DoubleToStr(local_minrisk,1) + "%";	
			vRisk = local_minrisk;
			sub_printandcomment(local_textstring);
		}	
	}
	// Don't use MoneyManagement, use fixed manual lotsize
	else // MoneyManagement == FALSE
	{
		// Check and if necessary adjust manual lotsize to inputal limits
		if (vManualLotsize < vMinLots)
		{
			local_textstring = "Manual lotsize " + DoubleToStr(vManualLotsize,2) + " cannot be less than " + DoubleToStr(vMinLots,2) + ". It has now been adjusted to " + DoubleToStr(vMinLots,2);
			vManualLotsize = vMinLots;			
			sub_printandcomment(local_textstring);
		}
		if (vManualLotsize > vMaxLots)
		{
			local_textstring = "Manual lotsize " + DoubleToStr(vManualLotsize,2) + " cannot be greater than " + DoubleToStr(vMaxLots,2) + ". It has now been adjusted to " + DoubleToStr(vMinLots,2);
			vManualLotsize = vMaxLots;
			sub_printandcomment(local_textstring);
		}	
		// Check to see that manual lotsize does not exceeds maximum allowed lotsize	
		if (vManualLotsize > local_maxlot)
		{
			local_textstring = "Manual lotsize " + DoubleToStr(vManualLotsize,2) + " cannot be greater than maximum allowed lotsize. It has now been adjusted to " + DoubleToStr(local_maxlot,2);
			vManualLotsize = local_maxlot;
			sub_printandcomment(local_textstring);
		}		
	}
		
}

// Print out broker details and other info
void sub_printdetails()
{
	string local_margintext;
	string local_stopouttext;
	string local_fixedlots;
	int local_type;
	int local_freemarginmode;
	int local_stopoutmode;
	
	local_type = IsDemo() + IsTesting();
	local_freemarginmode = AccountFreeMarginMode();
	local_stopoutmode = AccountStopoutMode();
	
	if (local_freemarginmode == 0)
		local_margintext = "that floating profit/loss is not used for calculation.";
	else if (local_freemarginmode == 1)
		local_margintext = "both floating profit and loss on open positions.";
	else if (local_freemarginmode == 2)
		local_margintext = "only profitable values, where current loss on open positions are not included.";
	else if (local_freemarginmode == 3)
		local_margintext = "only loss values are used for calculation, where current profitable open positions are not included.";
		
	if (local_stopoutmode == 0)
		local_stopouttext = "percentage ratio between margin and equity.";
	else if (local_stopoutmode == 1)
		local_stopouttext = "comparison of the free margin level to the absolute value.";
	
	if (MoneyManagement == TRUE)
		local_fixedlots = " (automatically calculated lots).";
	if (MoneyManagement == FALSE)
		local_fixedlots = " (fixed manual lots).";
	
	Print ("Broker name: ", AccountCompany());
	Print ("Broker server: ", AccountServer());
	Print ("Account type: ", StringSubstr("RealDemoTest", 4 * local_type, 4));
	Print ("Initial account balance: ", AccountBalance()," ", AccountCurrency());
	Print ("Broker digits: ", brokerdigits);	
	Print ("Broker stoplevel / freezelevel (max): ", stoplevel / Point," pip (= ", DoubleToStr(stoplevel,5),")");	
	Print ("Broker stopout level: ", stopout,"%");	
	Print ("Broker Point: ", DoubleToStr (Point, brokerdigits)," on ", AccountCurrency());	
	Print ("Broker account leverage in percentage: ", leverage);	
	Print ("Broker credit value on the account: ", AccountCredit());
	Print ("Broker account margin: ", AccountMargin());
	Print ("Broker calculation of free margin allowed to open positions considers " + local_margintext);
	Print ("Broker calculates stopout level as " + local_stopouttext);
	Print ("Broker requires at least ", marginforonelot," ", AccountCurrency()," in margin for 1 lot.");	
	Print ("Broker set 1 lot to trade ", lotbase," ", AccountCurrency());
	Print ("Broker minimum allowed lotsize: ", vMinLots);
	Print ("Broker maximum allowed lotsize: ", vMaxLots);
	Print ("Broker allow lots to be resized in ", lotstep, " steps.");
	Print ("Risk: ", vRisk,"%");	
	Print ("Risk adjusted lotsize: ", DoubleToStr(lotsize,2) + local_fixedlots);
}

// Print and show comment of text
void sub_printandcomment(string par_text)
{
	Print (par_text);
	Comment (par_text);
}

// Summarize error messages that comes from the broker server
void sub_errormessages()
{		
	switch (GetLastError()) 
	{
		// Trade server is busy
		case 4: // ERR_SERVER_BUSY:
			err_busyserver++;
		case 6: // ERR_NO_CONNECTION:
			err_lostconnection++;
		case 8: // ERR_TOO_FREQUENT_REQUESTS:
			err_toomanyrequest++;
		case 129: // ERR_INVALID_PRICE:
			err_invalidprice++;
		case 130: // ERR_INVALID_STOPS:
			err_invalidstops++;
		case 131: // ERR_INVALID_TRADE_VOLUME:
			err_invalidtradevolume++;
		case 135: // ERR_PRICE_CHANGED:
			err_pricechange++;
		case 137: // ERR_BROKER_BUSY:
			err_brokerbuzy++;
		case 138: // ERR_REQUOTE:
			err_requotes++;
		case 141: // ERR_TOO_MANY_REQUESTS:
			err_toomanyrequests++;
		case 145: // ERR_TRADE_MODIFY_DENIED:
			err_trademodifydenied++;
		case 146: // ERR_TRADE_CONTEXT_BUSY:
			err_tradecontextbuzy++;	
	}
}

// Print out and comment summarized messages from the broker
void sub_printsumofbrokererrors()
{
	string local_txt;
	
	local_txt = "Number of times the brokers server reported that ";
	if (err_busyserver > 0)
		sub_printandcomment(local_txt + "it is buzy: " + DoubleToStr(err_busyserver,0));
	if (err_lostconnection > 0)
		sub_printandcomment(local_txt + "the connection is lost: " + DoubleToStr(err_lostconnection,0));
	if (err_toomanyrequest > 0)
		sub_printandcomment(local_txt + "there was too many requests: " + DoubleToStr(err_toomanyrequest,0));
	if (err_invalidprice > 0)
		sub_printandcomment(local_txt + "the price was invalid: " + DoubleToStr(err_invalidprice,0));
	if (err_invalidstops > 0)
		sub_printandcomment(local_txt + "invalid SL and/or TP: " + DoubleToStr(err_invalidstops,0));
	if (err_invalidtradevolume > 0)
		sub_printandcomment(local_txt + "invalid lot size: " + DoubleToStr(err_invalidtradevolume,0));
	if (err_pricechange > 0)
		sub_printandcomment(local_txt + "the price has changed: " + DoubleToStr(err_pricechange,0));
	if (err_brokerbuzy > 0)
		sub_printandcomment(local_txt + "the broker is buzy: " + DoubleToStr(err_brokerbuzy,0));
	if (err_requotes > 0)
		sub_printandcomment(local_txt + "requotes " + DoubleToStr(err_requotes,0));
	if (err_toomanyrequests > 0)
		sub_printandcomment(local_txt + "too many requests " + DoubleToStr(err_toomanyrequests,0));
	if (err_trademodifydenied > 0)
		sub_printandcomment(local_txt + "modifying orders is denied " + DoubleToStr(err_trademodifydenied,0));
	if (err_tradecontextbuzy > 0)
		sub_printandcomment(local_txt + "trade context is buzy: " + DoubleToStr(err_tradecontextbuzy,0));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int GetSAInd(int ticket)
{
  int size = a_N;
  for (int i=0; i<size; i++)
  {
    if (a_tickets[i] == ticket) return (i);
  }
  
  return (-1);
}

int OrdersTotalEx()
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrdersTotal());
  }
  
  return (a_N);
}

bool OrderSelectEx(int index, int select, int pool = MODE_TRADES)
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderSelect(index, select, pool));
  }
  
  if (pool == MODE_TRADES)
  {
    if (select == SELECT_BY_POS)
    {
      vo_sel_ind = index;
      return (true);
    }
    
    if (select == SELECT_BY_TICKET)
    {
      vo_sel_ind = GetSAInd(index);
      return (vo_sel_ind >= 0);
    }
  }
  
  return (false);
}

bool OrderDeleteEx(int ticket)
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderDelete(ticket));
  }
  
  int ind = GetSAInd(ticket);
  if (ind >= 0)
  {
    VOrderRemove(ind);
  }
  
  return (true);
}

int OrderTicketEx()
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderTicket());
  }
  
  return (a_tickets[vo_sel_ind]);
}

int OrderTypeEx()
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderType());
  }
  
  return (a_type[vo_sel_ind]);
}

string OrderSymbolEx()
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderSymbol());
  }
  
  return (a_symbol[vo_sel_ind]);
}

double OrderOpenPriceEx()
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderOpenPrice());
  }
  
  return (a_open_price[vo_sel_ind]);
}

double OrderStopLossEx()
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderStopLoss());
  }
  
  return (a_sl[vo_sel_ind]);
}

double OrderTakeProfitEx()
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderTakeProfit());
  }

  return (a_tp[vo_sel_ind]);
}

int OrderMagicNumberEx()
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    return (OrderMagicNumber());
  }

  return (a_magic[vo_sel_ind]);
}

void LoadStops()
{
  string obj_name, txt;
  
  int size = ArraySize(a_tickets);
  for (int i=0; i<size; i++)
  {
    obj_name = vo_prefix + "ord" + string(i);
    if (ObjectFind(obj_name) == -1) continue;
    
    txt = ObjectDescription(obj_name);
    a_tickets[a_N] = StrToInteger(txt);
    a_type[a_N] = -1;
    a_volume[a_N] = 0.0;
    a_symbol[a_N] = "";
    a_open_price[a_N] = 0.0;
    a_sl[a_N] = 0.0;
    a_tp[a_N] = 0.0;
    a_magic[a_N] = 0;
    a_comment[a_N] = "";
    a_color[a_N] = clrNONE;

    obj_name = vo_prefix + "ord" + string(i) + "_type";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_type[a_N] = Str2OrdType(txt);
    }

    obj_name = vo_prefix + "ord" + string(i) + "_volume";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_volume[a_N] = StringToDouble(txt);
    }

    obj_name = vo_prefix + "ord" + string(i) + "_symbol";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_symbol[a_N] = txt;
    }

    obj_name = vo_prefix + "ord" + string(i) + "_open_price";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_open_price[a_N] = StrToDouble(txt); 
    }

    obj_name = vo_prefix + "ord" + string(i) + "_sl";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_sl[a_N] = StrToDouble(txt); 
    }

    obj_name = vo_prefix + "ord" + string(i) + "_tp";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_tp[a_N] = StrToDouble(txt);
    }

    obj_name = vo_prefix + "ord" + string(i) + "_magic";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_magic[a_N] = StrToInteger(txt);
    }

    obj_name = vo_prefix + "ord" + string(i) + "_comment";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_comment[a_N] = txt;
    }

    obj_name = vo_prefix + "ord" + string(i) + "_color";
    if (ObjectFind(obj_name) != -1)
    {
      txt = ObjectDescription(obj_name);
      a_color[a_N] = StringToColor(txt);
    }
    
    a_N++;
  }
}

int OrderSendEx(string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment="", int magic=0, datetime expiration=0, color arrow_color=CLR_NONE)
{
  int ticket = -1;
  
  if (!VirtualPendingOrders && !VirtualStops)
  {
    ticket = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);
    return (ticket);
  }
  
  if (VirtualPendingOrders)
  {
    if (cmd == OP_BUYSTOP || cmd == OP_SELLSTOP || cmd == OP_BUYLIMIT || cmd == OP_SELLLIMIT)
    {
      ticket = (cmd+1);
      
      a_tickets[a_N] = ticket;
      a_type[a_N] = cmd;
      a_symbol[a_N] = symbol;
      a_volume[a_N] = volume;
      a_open_price[a_N] = price;
      a_sl[a_N] = stoploss;
      a_tp[a_N] = takeprofit;
      a_magic[a_N] = magic;
      a_comment[a_N] = comment;
      a_color[a_N] = arrow_color;
      a_N++;
    
      return (ticket);
    }
  }
  
  if (VirtualStops)
  {
    ticket = OrderSend(symbol, cmd, volume, price, slippage, 0, 0, comment, magic, expiration, arrow_color);
    
    a_tickets[a_N] = ticket;
    a_type[a_N] = cmd;
    a_symbol[a_N] = symbol;
    a_volume[a_N] = volume;
    a_open_price[a_N] = price;
    a_sl[a_N] = stoploss;
    a_tp[a_N] = takeprofit;
    a_magic[a_N] = magic;
    a_comment[a_N] = comment;
    a_color[a_N] = arrow_color;
    a_N++;
    
    return (ticket);
  }  
  
  return (-1);
}

bool OrderModifyEx(int ticket, double price, double stoploss, double takeprofit, datetime expiration, color arrow_color=CLR_NONE)
{
  if (!VirtualPendingOrders && !VirtualStops)
  {
    bool bRC = OrderModify(ticket, price, stoploss, takeprofit, expiration, arrow_color);
    return (bRC);
  }

  int ind = GetSAInd(ticket);
  if (ind == -1) return (false);
  
  int digits = MarketInfo(a_symbol[ind], MODE_DIGITS);

  if (VirtualPendingOrders && VirtualStops)
  {
    if (a_type[ind] == OP_BUY || a_type[ind] == OP_SELL)
    {
      Print("OrderModifyEx: ", ticket, ", ", DoubleToStr(stoploss, digits), ", ", DoubleToStr(takeprofit, digits));
      
      a_sl[ind] = stoploss;
      a_tp[ind] = takeprofit;
    
      return (true);
    }
  
    if (a_type[ind] == OP_BUYSTOP || a_type[ind] == OP_SELLSTOP || a_type[ind] == OP_BUYLIMIT || a_type[ind] == OP_SELLLIMIT)
    {
      Print("OrderModifyEx: ", a_tickets[ind], ", ", DoubleToStr(price, digits), ", ", DoubleToStr(stoploss, digits), ", ", DoubleToStr(takeprofit, digits));
      
      a_open_price[ind] = price;
      a_sl[ind] = stoploss;
      a_tp[ind] = takeprofit;
      
      return (true);
    }
  }
  
  else if (VirtualPendingOrders)
  {
    if (a_type[ind] == OP_BUY || a_type[ind] == OP_SELL)
    {
      bRC = OrderModify(ticket, price, stoploss, takeprofit, expiration, arrow_color);
      return (bRC);    
    }
    
    if (a_type[ind] == OP_BUYSTOP || a_type[ind] == OP_SELLSTOP || a_type[ind] == OP_BUYLIMIT || a_type[ind] == OP_SELLLIMIT)
    {
      Print("OrderModifyEx: ", a_tickets[ind], ", ", DoubleToStr(price, digits), ", ", DoubleToStr(stoploss, digits), ", ", DoubleToStr(takeprofit, digits));
      
      a_open_price[ind] = price;
      a_sl[ind] = stoploss;
      a_tp[ind] = takeprofit;
      
      return (true);
    }
  }
  
  else if (VirtualStops)
  {
    if (a_type[ind] == OP_BUY || a_type[ind] == OP_SELL)
    {
      Print("OrderModifyEx: ", ticket, ", ", DoubleToStr(stoploss, digits), ", ", DoubleToStr(takeprofit, digits));
      
      a_sl[ind] = stoploss;
      a_tp[ind] = takeprofit;
    
      return (true);
    }
  
    if (a_type[ind] == OP_BUYSTOP || a_type[ind] == OP_SELLSTOP || a_type[ind] == OP_BUYLIMIT || a_type[ind] == OP_SELLLIMIT)
    {
      bRC = OrderModify(ticket, price, 0, 0, expiration, arrow_color);
      if (!bRC) return (bRC);
        
      Print("OrderModifyEx: ", a_tickets[ind], ", ", DoubleToStr(price, digits), ", ", DoubleToStr(stoploss, digits), ", ", DoubleToStr(takeprofit, digits));
      
      a_open_price[ind] = price;
      a_sl[ind] = stoploss;
      a_tp[ind] = takeprofit;
      
      return (true);
    }  
  }
  
  return (false);
}

void VO_CheckPendingOrders()
{
  //bool bRC;
  
  double sl, tp;
  
  int size = a_N;
  for (int i=0; i<size; i++)
  {
    int ticket = a_tickets[i];
    
    sl = 0.0;
    tp = 0.0;
    if (!VirtualStops)
    {
      sl = a_sl[i];
      tp = a_tp[i];
    }
    
    //-----
    
    if (a_type[i] == OP_BUYSTOP)
    {
      if (NormalizeDouble(Ask, Digits) >= NormalizeDouble(a_open_price[i], Digits))
      {        
        ticket = OrderSend(Symbol(), OP_BUY, a_volume[i], Ask, Slippage, sl, tp, a_comment[i], a_magic[i], 0, a_color[i]);
        if (ticket >= 0)
        {
          a_tickets[i] = ticket;
          a_type[i] = OP_BUY;
        }
      }
    }

    else if (a_type[i] == OP_BUYLIMIT)
    {
      if (NormalizeDouble(Ask, Digits) <= NormalizeDouble(a_open_price[i], Digits))
      {
        ticket = OrderSend(Symbol(), OP_BUY, a_volume[i], Ask, Slippage, sl, tp, a_comment[i], a_magic[i], 0, a_color[i]);
        if (ticket >= 0)
        {
          a_tickets[i] = ticket;
          a_type[i] = OP_BUY;
        }        
      }
    }

    else if (a_type[i] == OP_SELLSTOP)
    {
      if (NormalizeDouble(Bid, Digits) <= NormalizeDouble(a_open_price[i], Digits))
      {
        ticket = OrderSend(Symbol(), OP_SELL, a_volume[i], Bid, Slippage, sl, tp, a_comment[i], a_magic[i], 0, a_color[i]);
        if (ticket >= 0)
        {
          a_tickets[i] = ticket;
          a_type[i] = OP_SELL;
        }        
      }
    }
    
    else if (a_type[i] == OP_SELLLIMIT)
    {
      if (NormalizeDouble(Bid, Digits) >= NormalizeDouble(a_open_price[i], Digits))
      {
        ticket = OrderSend(Symbol(), OP_SELL, a_volume[i], Bid, Slippage, sl, tp, a_comment[i], a_magic[i], 0, a_color[i]);
        if (ticket >= 0)
        {
          a_tickets[i] = ticket;
          a_type[i] = OP_SELL;
        }        
      }
    }
  }
}

void VO_UpdatePOType()
{
  int size = a_N;
  for (int i=size-1; i>=0; i--)
  {
    int ticket = a_tickets[i];

    if (!OrderSelect(ticket, SELECT_BY_TICKET)) continue;
    if (OrderCloseTime() > 0)
    {
      VOrderRemove(i);
      continue;
    }
    
    //-----
    
    if (OrderType() == OP_BUY)
    {
      if (a_type[i] == OP_BUYSTOP || a_type[i] == OP_BUYLIMIT) a_type[i] = OP_BUY;
      continue;
    }
    
    if (OrderType() == OP_SELL)
    {
      if (a_type[i] == OP_SELLSTOP || a_type[i] == OP_SELLLIMIT) a_type[i] = OP_SELL;
      continue;
    }
  }
}

void VO_CheckStops()
{
  bool bRC;
  
  int size = a_N;
  for (int i=0; i<size; i++)
  {
    if (a_type[i] != OP_BUY && a_type[i] != OP_SELL) continue;

    int ticket = a_tickets[i];
    if (!OrderSelect(ticket, SELECT_BY_TICKET)) continue;
    if (OrderCloseTime() > 0) continue;
    
    //-----
    
    RefreshRates();
    int StopLevel = MarketInfo(OrderSymbol(), MODE_STOPLEVEL) + 1;
    double bid = MarketInfo(OrderSymbol(), MODE_BID);
    double ask = MarketInfo(OrderSymbol(), MODE_ASK);
    int digits = MarketInfo(OrderSymbol(), MODE_DIGITS);
    double point = MarketInfo(OrderSymbol(), MODE_POINT);
    
  
    double sl = a_sl[i];
    double tp = a_tp[i];

    int type = OrderType();    
    if (type == OP_BUY)
    {   
      if (NormalizeDouble(bid, digits) > NormalizeDouble(tp, digits) && tp > 0)
      {
        Print("[CheckStops] Close BUY by VirtualTP ", DoubleToStr(tp, digits));
        
        bRC = OrderClose(ticket, OrderLots(), bid, Slippage*fpc());
        if (bRC)
        {
          //bRC = OrderSelect(ticket, SELECT_BY_TICKET);
          //AddStopsHist(ticket, OrderStopLossEx(), OrderTakeProfitEx(), "[tp]");
        }
        
        continue;
      }

      if (NormalizeDouble(bid, digits) < NormalizeDouble(sl, digits) && sl > 0)
      {
        Print("[CheckStops] Close BUY by VirtualSL ", DoubleToStr(sl, digits));
        
        bRC = OrderClose(ticket, OrderLots(), bid, Slippage*fpc());
        if (bRC)
        {
          //bRC = OrderSelect(ticket, SELECT_BY_TICKET);
          //AddStopsHist(ticket, OrderStopLossEx(), OrderTakeProfitEx(), "[sl]");
        }
        
        continue;
      }
    }

    if (type == OP_SELL)
    {
      if (NormalizeDouble(ask, digits) < NormalizeDouble(tp, digits) && tp > 0)
      {
        Print("[CheckStops] Close SELL by VirtualTP ", DoubleToStr(tp, digits));
        
        bRC = OrderClose(ticket, OrderLots(), ask, Slippage*fpc());
        if (bRC)
        {
          //bRC = OrderSelect(ticket, SELECT_BY_TICKET);
          //AddStopsHist(ticket, OrderStopLossEx(), OrderTakeProfitEx(), "[tp]");
        }
                
        continue;
      }

      if (NormalizeDouble(ask, digits) > NormalizeDouble(sl, digits) && sl > 0)
      {
        Print("[CheckStops] Close SELL by VirtualSL ", DoubleToStr(sl, digits));
        
        bRC = OrderClose(ticket, OrderLots(), ask, Slippage*fpc());
        if (bRC)
        {
          //bRC = OrderSelect(ticket, SELECT_BY_TICKET);
          //AddStopsHist(ticket, OrderStopLossEx(), OrderTakeProfitEx(), "[sl]");
        }
        
        continue;
      }
    }
  }  
}

void VO_ClearStops()
{
  int size = a_N;
  for (int i=size-1; i>=0; i--)
  {
    if (a_type[i] != OP_BUY && a_type[i] != OP_SELL) continue;

    int ticket = a_tickets[i];
    bool bRemove = false;
    
    if (!OrderSelect(ticket, SELECT_BY_TICKET)) bRemove = true;
    if (OrderCloseTime() > 0) bRemove = true;
    
    if (bRemove)
    {
      VOrderRemove(i);
    }
  }  
}


void VOrderRemove(int ind)
{
  for (int j=ind; j < a_N-1; j++)
  {
    a_tickets[j] = a_tickets[j+1];
    a_type[j] = a_type[j+1];
    a_symbol[j] = a_symbol[j+1];
    a_volume[j] = a_volume[j+1];
    a_open_price[j] = a_open_price[j+1];
    a_sl[j] = a_sl[j+1];
    a_tp[j] = a_tp[j+1];
    a_magic[j] = a_magic[j+1];
    a_comment[j] = a_comment[j+1];
    a_color[j] = a_color[j+1];
  }
  
  a_N--;
}

void VO_DrawStops()
{
  string obj_name, txt;
  
  
  obj_name = vo_prefix + "Legend";

  if (ObjectFind(obj_name) == -1)
  {
    ObjectCreate(obj_name, OBJ_LABEL, 0, 0, 0);
  }
  
  txt = "Virtual Orders Storage";

  ObjectSetText(obj_name, txt, VOrdText_font_size, VOrdText_font, VOrdText_font_color);
  ObjectSet(obj_name, OBJPROP_CORNER, VOrdText_corner);
  ObjectSet(obj_name, OBJPROP_XDISTANCE, VOrdText_x);
  ObjectSet(obj_name, OBJPROP_YDISTANCE, VOrdText_y);

  //-----
  
  string VOTable_ColPref[10] = {"ticket", "type", "volume", "symbol", "open_price", "sl", "tp", "magic", "comment", "color"};
  string VOTableText[][10];
  ArrayResize(VOTableText, a_N);
  
  int i, j;
    
  int size = a_N;
  for (i=0; i<size; i++)
  {
    //if (!OrderSelect(a_tickets[i], SELECT_BY_TICKET)) continue;
    
    string order_symbol = a_symbol[i];
    
    int digits = MarketInfo(order_symbol, MODE_DIGITS);
    double point = MarketInfo(order_symbol, MODE_POINT);
    
    VOTableText[i][0] = (string)a_tickets[i];
    VOTableText[i][1] = OrdType2Str(a_type[i]);
    VOTableText[i][2] = DoubleToStr(a_volume[i], 2);
    VOTableText[i][3] = a_symbol[i];
    VOTableText[i][4] = DoubleToStr(a_open_price[i], digits);
    VOTableText[i][5] = DoubleToStr(a_sl[i], digits);
    VOTableText[i][6] = DoubleToStr(a_tp[i], digits);
    VOTableText[i][7] = (string)a_magic[i];
    VOTableText[i][8] = a_comment[i];
    VOTableText[i][9] = ColorToString(a_color[i]);
  }
  
  
  int size1 = ArrayRange(VOTableText, 0);
  int size2 = ArrayRange(VOTableText, 1);
  for (i=0; i<size1; i++)
  {
    int dx = VOrdText_x;
    
    for (j=size2-1; j>=0; j--)
    {
      obj_name = vo_prefix + "ord" + string(i) + "_" + VOTable_ColPref[j];
    
      if (ObjectFind(obj_name) == -1)
      {
        ObjectCreate(obj_name, OBJ_LABEL, 0, 0, 0);
      }
      
      txt = VOTableText[i][j];
    
      ObjectSetText(obj_name, txt, VOrdText_font_size, VOrdText_font, VOrdText_font_color);
      ObjectSet(obj_name, OBJPROP_CORNER, VOrdText_corner);
      
      if (j >= 7)
        ObjectSet(obj_name, OBJPROP_XDISTANCE, 10000);
      else
        ObjectSet(obj_name, OBJPROP_XDISTANCE, dx);
        
      ObjectSet(obj_name, OBJPROP_YDISTANCE, VOrdText_y + (i+1)*VOrdText_dy);
      
      if (j < 7)
      {
        dx += VOrdText_dx;
      }
    }
  }
  
  //-----
  
  for (; i<1000; i++)
  {
    obj_name = vo_prefix + "ord" + string(i);
    if (ObjectFind(obj_name) != -1) ObjectDelete(obj_name);
  }
}

string OrdType2Str(int type)
{
  switch (type)
  {
    case OP_BUY:        return ("Buy"); 
    case OP_SELL:       return ("Sell");
    case OP_BUYLIMIT:   return ("BuyLimit");
    case OP_SELLLIMIT:  return ("SellLimit");
    case OP_BUYSTOP:    return ("BuyStop");
    case OP_SELLSTOP:   return ("SellStop");
  }
  
  return (""+type);
}

int Str2OrdType(string sType)
{
  if (sType == "Buy") return (OP_BUY); 
  if (sType == "Sell") return (OP_SELL); 
  if (sType == "BuyLimit") return (OP_BUYLIMIT); 
  if (sType == "SellLimit") return (OP_SELLLIMIT); 
  if (sType == "BuyStop") return (OP_BUYSTOP); 
  if (sType == "SellStop") return (OP_SELLSTOP); 
  
  return (-1);
}

int fpc()
{
  if (Digits == 3 || Digits == 5) return (10);
  return (1); 
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
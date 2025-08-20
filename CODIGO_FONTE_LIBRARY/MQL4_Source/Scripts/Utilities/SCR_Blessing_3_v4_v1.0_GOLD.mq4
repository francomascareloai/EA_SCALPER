//+---------------------------------------------------------------------+
//|                                                Blessing 3 v3.9.6.09 |
//|                                                   February 09, 2014 |
//|                     Copyright © 2007-2011, J Talon LLC/FiFtHeLeMeNt |
//|     In no event will authors be liable for any damages whatsoever.  |
//|                         Use at your own risk.                       |
//|                                                                     |
//|  This EA is dedicated to Mike McKeough, a member of the Blessing    |
//|  Development Group, who passed away on Saturday, 31st July 2010.    |
//|  His contributions to the development of this EA have helped make   |
//|  it what it is today, and we will miss his enthusiasm, dedication   |
//|  and desire to make this the best EA possible.                      |
//|  Rest In Peace.                                                     |
//+---------------------------------------------------------------------+

#property copyright "Copyright © 2007-2014, J Talon LLC/FiFtHeLeMeNt"
#property link      "http://www.jtatoday.com"

#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>

#define A 1 //All (Basket + Hedge)
#define B 2 //Basket
#define H 3 //Hedge
#define T 4 //Ticket
#define P 5 //Pending

//+-----------------------------------------------------------------+
//| External Parameters Set                                         |
//+-----------------------------------------------------------------+

extern string   Version_3_9_6       = "EA Settings:";
extern string   TradeComment        = "Blessing 3.9.6.09";
// Enter a unique number to identify this EA
extern int      EANumber            = 1;
// Setting this to true will close all open orders immediately
extern bool     EmergencyCloseAll   = false;

extern string   LabelAcc            = "Account Trading Settings:";
// Setting this to true will stop the EA trading after any open trades have been closed
extern bool     ShutDown            = false;
// percent of account balance lost before trading stops
extern double   StopTradePercent    = 10;
// set to true for nano "penny a pip" account (contract size is $10,000)
extern bool     NanoAccount         = false;
// Percentage of account you want to trade on this pair
extern double   PortionPC           = 100;
// If Basket open: 0=no Portion change;1=allow portion to increase; -1=allow increase and decrease 
extern int		PortionChange		= 1;		      
// Percent of portion for max drawdown level.
extern double   MaxDDPercent        = 50;
// Maximum allowed spread while placing trades
extern double   MaxSpread           = 5;
// Will shutdown over holiday period 
extern bool     UseHolidayShutdown  = true;
// List of holidays, each seperated by a comma, [day]/[mth]-[day]/[mth], dates inclusive
extern string   Holidays            = "18/12-01/01";
// will sound alarms
extern bool     PlaySounds          = false;
// Alarm sound to be played
extern string   AlertSound          = "Alert.wav";

extern string   LabelIES            = "Indicator / Entry Settings:";
// Stop/Limits for entry if true, Buys/Sells if false
extern bool     B3Traditional       = true;
// Market condition 0=uptrend 1=downtrend 2=range 3=off
extern int      ForceMarketCond     = 3;
// true = ANY entry can be used to open orders, false = ALL entries used to open orders
extern bool     UseAnyEntry         = false;
// 0 = Off, 1 = will base entry on MA channel, 2 = will trade in reverse
extern int      MAEntry             = 1;
// 0 = Off, 1 = will base entry on CCI indicator, 2 = will trade in reverse
extern int      CCIEntry            = 0;
// 0 = Off, 1 = will base entry on BB, 2 = will trade in reverse
extern int      BollingerEntry      = 0;
// 0 = Off, 1 = will base entry on Stoch, 2 = will trade in reverse
extern int      StochEntry          = 0;
// 0 = Off, 1 = will base entry on MACD, 2 = will trade in reverse
extern int      MACDEntry           = 0;

extern string   LabelLS             = "Lot Size Settings:";
// Money Management
extern bool     UseMM               = true;
// Adjusts MM base lot for large accounts
extern double   LAF                 = 0.5;
// Starting lots if Money Management is off
extern double   Lot                 = 0.01;
// Multiplier on each level
extern double   Multiplier          = 1.4;

extern string   LabelGS             = "Grid Settings:";
// Auto calculation of TakeProfit and Grid size;
extern bool     AutoCal             = false;
extern string   LabelATRTFr         = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
// TimeFrame for ATR calculation
extern int      ATRTF               = 0;
// Number of periods for the ATR calculation
extern int      ATRPeriods          = 21;
// Widens/Squishes Grid on increments/decrements of .1
extern double   GAF                 = 1.0;
// Time Grid in seconds, to avoid opening of lots of levels in fast market
extern int      EntryDelay          = 2400;
// In pips, used in conjunction with logic to offset first trade entry
extern double   EntryOffset         = 5;
// True = use RSI/MA calculation for next grid order
extern bool     UseSmartGrid        = true;

extern string   LabelTS             = "Trading Settings:";
// Maximum number of trades to place (stops placing orders when reaches MaxTrades)
extern int      MaxTrades           = 15;
// Close All level, when reaches this level, doesn't wait for TP to be hit
extern int      BreakEvenTrade      = 12;
// Pips added to Break Even Point before BE closure
extern double   BEPlusPips          = 2;
// True = will close the oldest open trade after CloseTradesLevel is reached
extern bool     UseCloseOldest      = false;
// will start closing oldest open trade at this level
extern int      CloseTradesLevel    = 5;
// Will close the oldest trade whether it has potential profit or not
extern bool     ForceCloseOldest    = true;
// Maximum number of oldest trades to close
extern int      MaxCloseTrades      = 4;
// After Oldest Trades have closed, Forces Take Profit to BE +/- xx Pips
extern double   CloseTPPips         = 10;
// Force Take Profit to BE +/- xx Pips
extern double   ForceTPPips         = 0;
// Ensure Take Profit is at least BE +/- xx Pips
extern double   MinTPPips           = 0;

extern string   LabelHS             = "Hedge Settings:";
// Enter the Symbol of the same/correlated pair EXACTLY as used by your broker.
extern string   HedgeSymbol         = "";
// Number of days for checking Hedge Correlation
extern int      CorrPeriod          = 30;
// Turns DD hedge on/off
extern bool     UseHedge            = false;
// DD = start hedge at set DD;Level = Start at set level
extern string   DDorLevel           = "DD";
// DD Percent or Level at which Hedge starts
extern double   HedgeStart          = 20;
// Hedge Lots = Open Lots * hLotMult
extern double   hLotMult            = 0.8;
// DD Hedge maximum pip loss - also hedge trailing stop
extern double   hMaxLossPips        = 30;
// true = fixed SL at hMaxLossPips
extern bool     hFixedSL            = false;
// Hedge Take Profit
extern double   hTakeProfit         = 30;
// Increase to HedgeStart to stop early re-entry of the hedge
extern double   hReEntryPC          = 5;
// True = Trailing Stop will stop at BE;False = Hedge will continue into profit
extern bool     StopTrailAtBE       = true;
// False = Trailing Stop is Fixed;True = Trailing Stop will reduce after BE is reached
extern bool     ReduceTrailStop     = true;

extern string   LabelES             = "Exit Settings:";
// Turns on TP move and Profit Trailing Stop Feature
extern bool     MaximizeProfit      = false;
// Locks in Profit at this percent of Total Profit Potential
extern double   ProfitSet           = 70;
// Moves TP this amount in pips
extern double   MoveTP              = 30;
// Number of times you want TP to move before stopping movement
extern int      TotalMoves          = 2;
// Use Stop Loss and/or Trailing Stop Loss
extern bool     UseStopLoss         = false;
// Pips for fixed StopLoss from BE, 0=off
extern double   SLPips              = 30;
// Pips for trailing stop loss from BE + TSLPips: +ve = fixed trail; -ve = reducing trail; 0=off
extern double   TSLPips             = 10;
// Minimum trailing stop pips if using reducing TS
extern double   TSLPipsMin          = 3;
// Transmits a SL in case of internet loss
extern bool     UsePowerOutSL       = false;
// Power Out Stop Loss in pips
extern double   POSLPips            = 600;
// Close trades in FIFO order
extern bool     UseFIFO             = false;

extern string   LabelEE             = "Early Exit Settings:";
// Reduces ProfitTarget by a percentage over time and number of levels open
extern bool     UseEarlyExit        = false;
// Number of Hours to wait before EE over time starts
extern double   EEStartHours        = 3;
// true = StartHours from FIRST trade: false = StartHours from LAST trade
extern bool     EEFirstTrade        = true;
// Percentage reduction per hour (0 = OFF)
extern double   EEHoursPC           = 0.5;
// Number of Open Trades before EE over levels starts
extern int      EEStartLevel        = 5;
// Percentage reduction at each level (0 = OFF)
extern double   EELevelPC           = 10;
// true = Will allow the basket to close at a loss : false = Minimum profit is Break Even
extern bool     EEAllowLoss         = false;

extern string   LabelAdv            = "Advanced Settings Change sparingly";

extern string   LabelGrid           = "Grid Size Settings:";
// Specifies number of open trades in each block (separated by a comma)
extern string   SetCountArray       = "4,4";
// Specifies number of pips away to issue limit order (separated by a comma)
extern string   GridSetArray        = "25,50,100";
// Take profit for each block (separated by a comma)
extern string   TP_SetArray         = "50,100,200";

extern string   LabelMA             = "MA Entry Settings:";
// Period of MA (H4 = 100, H1 = 400)
extern int      MAPeriod            = 100;
// Distance from MA to be treated as Ranging Market
extern double   MADistance          = 10;

extern string   LabelCCI            = "CCI Entry Settings:";
// Period for CCI calculation
extern int      CCIPeriod           = 14;

extern string   LabelBBS            = "Bollinger Bands Entry Settings:";
// Period for Bollinger
extern int      BollPeriod          = 10;
// Up/Down spread
extern double   BollDistance        = 10;
// Standard deviation multiplier for channel
extern double   BollDeviation       = 2.0;

extern string   LabelSto            = "Stochastic Entry Settings:";
// Determines Overbought and Oversold Zones
extern int      BuySellStochZone    = 20;
// Stochastic KPeriod
extern int      KPeriod             = 10;
// Stochastic DPeriod
extern int      DPeriod             = 2;
// Stochastic Slowing
extern int      Slowing             = 2;

extern string   LabelMACD           = "MACD Entry Settings:";
extern string   LabelMACDTF         = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
// Time frame for MACD calculation
extern int      MACD_TF             = 0;
// MACD EMA Fast Period
extern int      FastPeriod          = 12;
// MACD EMA Slow Period
extern int      SlowPeriod          = 26;
// MACD EMA Signal Period
extern int      SignalPeriod        = 9;
// 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4
extern int      MACDPrice           = 0;

extern string   LabelSG             = "Smart Grid Settings:";
extern string   LabelSGTF           = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
// Timeframe for RSI calculation - should be less than chart TF.
extern int      RSI_TF              = 3;
// Period for RSI calculation
extern int      RSI_Period          = 14;
// 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4
extern int      RSI_Price           = 0;
// Period for MA of RSI calculation
extern int      RSI_MA_Period       = 10;
// 0=Simple MA, 1=Exponential MA, 2=Smoothed MA, 3=Linear Weighted MA
extern int      RSI_MA_Method       = 0;

extern string   LabelOS             = "Other Settings:";
// true = Recoup any Hedge/CloseOldest losses: false = Use original profit target.
extern bool     RecoupClosedLoss    = true;
// Largest Assumed Basket size.  Lower number = higher start lots
extern int      Level               = 7;
// Adjusts opening and closing orders by "slipping" this amount
extern int      slip                = 99;
// true = will save equity statistics
extern bool     SaveStats           = false;
// seconds between stats entries - off by default
extern int      StatsPeriod         = 3600;
// true for backtest - false for forward/live to ACCUMULATE equity traces
extern bool     StatsInitialise     = true;

extern string   LabelUE             = "Email Settings:";
extern bool     UseEmail            = false;
extern string   LabelEDD            = "At what DD% would you like Email warnings (Max: 49, Disable: 0)?";
extern double   EmailDD1            = 20;
extern double   EmailDD2            = 30;
extern double   EmailDD3            = 40;
extern string   LabelEH             = "Number of hours before DD timer resets";
// Minimum number of hours between emails
extern double   EmailHours          = 24;

extern string   LabelDisplay        = "Used to Adjust Overlay";
// Turns the display on and off
extern bool     displayOverlay      = true;
// Turns off copyright and icon
extern bool     displayLogo         = true;
// Turns off the CCI display
extern bool     displayCCI          = true;
// Show BE, TP and TS lines
extern bool     displayLines        = true;
// Moves display left and right
extern int      displayXcord        = 100;
// Moves display up and down
extern int      displayYcord        = 22;
// Moves CCI display left and right
extern int      displayCCIxCord     = 10;
//Display font
extern string   displayFont         = "Arial Bold";
// Changes size of display characters
extern int      displayFontSize     = 9;
// Changes space between lines
extern int      displaySpacing      = 14;
// Ratio to increase label width spacing
extern double   displayRatio        = 1;
// default color of display characters
extern color    displayColor        = DeepSkyBlue;
// default color of profit display characters
extern color    displayColorProfit  = Green;
// default color of loss display characters
extern color    displayColorLoss    = Red;
// default color of ForeGround Text display characters
extern color    displayColorFGnd    = White;

extern bool     Debug               = false;

extern string   LabelOpt            = "These values can only be used while optimizing";
// Set to true if you want to be able to optimize the grid settings.
extern bool     UseGridOpt          = false;
// These values will replace the normal SetCountArray,
// GridSetArray and TP_SetArray during optimization.
// The default values are the same as the normal array defaults
// REMEMBER:
// There must be one more value for GridArray and TPArray
// than there is for SetArray
extern int      SetArray1           = 4;
extern int      SetArray2           = 4;
extern int      SetArray3           = 0;
extern int      SetArray4           = 0;
extern int      GridArray1          = 25;
extern int      GridArray2          = 50;
extern int      GridArray3          = 100;
extern int      GridArray4          = 0;
extern int      GridArray5          = 0;
extern int      TPArray1            = 50;
extern int      TPArray2            = 100;
extern int      TPArray3            = 200;
extern int      TPArray4            = 0;
extern int      TPArray5            = 0;

//+-----------------------------------------------------------------+
//| Internal Parameters Set                                         |
//+-----------------------------------------------------------------+
int         ca;
int         Magic,hMagic;
int         CbT,CpT,ChT;
double      Pip,hPip;
int         POSLCount;
double      SLbL;
int         Moves;
double      MaxDD;
double      SLb;
int         AccountType;
double      StopTradeBalance;
double      InitialAB;
bool        Testing,Visual;
bool        AllowTrading;
bool        EmergencyWarning;
double      MaxDDPer;
int         Error,y;
int         Set1Level,Set2Level,Set3Level,Set4Level;
int         EmailCount;
string      sTF;
datetime    EmailSent;
int         GridArray[,2];
double      Lots[],MinLotSize,LotStep,LotDecimal;
int         LotMult,MinMult;
bool        PendLot;
string      CS,UAE;
int         HolShutDown;
datetime    HolArray[,4];
datetime    HolFirst,HolLast,NextStats,OTbF;
double      RSI[];
int         Digit[,2],TF[10]={0,1,5,15,30,60,240,1440,10080,43200};

double      Email[3];
double      EETime,PbC,PhC,hDDStart,PbMax,PbMin,PhMax,PhMin,LastClosedPL,ClosedPips,SLh,hLvlStart,StatLowEquity,StatHighEquity;
int         hActive,EECount,TbF,CbC,CaL,FileHandle;
bool        TradesOpen,FileClosed,HedgeTypeDD,hThisChart,hPosCorr,dLabels,FirstRun;
string      FileName,ID,StatFile;
double      TPb,StopLevel,TargetPips,LbF,bTS,PortionBalance;

//+-----------------------------------------------------------------+
//| expert initialization function                                  |
//+-----------------------------------------------------------------+
int init()
{	CS="Waiting for next tick .";     // To display comments while testing, simply use CS = .... and
	Comment(CS);                        // it will be displayed by the line at the end of the start() block.
	CS="";
	Testing=IsTesting();
	Visual=IsVisualMode();
	FirstRun=true;
	AllowTrading=true;
	if(EANumber<1)EANumber=1;
	if(Testing)EANumber=0;
	Magic=GenerateMagicNumber();
	hMagic=JenkinsHash(Magic);
	FileName="B3_"+Magic+".dat";
	if(Debug)
	{	Print("Magic Number: "+DTS(Magic,0));
		Print("Hedge Number: "+DTS(hMagic,0));
		Print("FileName: "+FileName);
	}
	Pip=Point;
	if(Digits%2==1)Pip*=10;
	if(NanoAccount)AccountType=10;
	else AccountType=1;

	MoveTP=ND(MoveTP*Pip,Digits);
	EntryOffset=ND(EntryOffset*Pip,Digits);
	MADistance=ND(MADistance*Pip,Digits);
	BollDistance=ND(BollDistance*Pip,Digits);
	POSLPips=ND(POSLPips*Pip,Digits);
	hMaxLossPips=ND(hMaxLossPips*Pip,Digits);
	hTakeProfit=ND(hTakeProfit*Pip,Digits);
	CloseTPPips=ND(CloseTPPips*Pip,Digits);
	ForceTPPips=ND(ForceTPPips*Pip,Digits);
	MinTPPips=ND(MinTPPips*Pip,Digits);
	BEPlusPips=ND(BEPlusPips*Pip,Digits);
	SLPips=ND(SLPips*Pip,Digits);
	TSLPips=ND(TSLPips*Pip,Digits);
	TSLPipsMin=ND(TSLPipsMin*Pip,Digits);
	slip*=Pip/Point;

	if(UseHedge)
	{	if(HedgeSymbol=="")HedgeSymbol=Symbol();
		if(HedgeSymbol==Symbol())hThisChart=true;
		else hThisChart=false;
		hPip=MarketInfo(HedgeSymbol,MODE_POINT);
		int hDigits=MarketInfo(HedgeSymbol,MODE_DIGITS);
		if(hDigits%2==1)hPip*=10;
		if(CheckCorr()>0.9||hThisChart)hPosCorr=true;
		else if(CheckCorr()<-0.9)hPosCorr=false;
		else
		{	AllowTrading=false;
			UseHedge=false;
			Print("The Hedge Symbol you have entered ("+HedgeSymbol+") is not closely correlated to "+Symbol());
		}
		if(StringSubstr(DDorLevel,0,1)=="D"||StringSubstr(DDorLevel,0,1)=="d")HedgeTypeDD=true;
		else if(StringSubstr(DDorLevel,0,1)=="L"||StringSubstr(DDorLevel,0,1)=="l")HedgeTypeDD=false;
		else UseHedge=false;
		if(HedgeTypeDD)
		{	HedgeStart/=100;
			hDDStart=HedgeStart;
		}
	}
	StopTradePercent/=100;
	ProfitSet/=100;
	EEHoursPC/=100;
	EELevelPC/=100;
	hReEntryPC/=100;
	PortionPC/=100;

	InitialAB=AccountBalance();
	StopTradeBalance=InitialAB*(1-StopTradePercent);
	if(Testing)ID="B3Test.";
	else ID=DTS(Magic,0)+".";
	HideTestIndicators(true);

	MinLotSize=MarketInfo(Symbol(),MODE_MINLOT);
	if(MinLotSize>Lot)
	{	Print("Lot is less than your brokers minimum lot size");
		AllowTrading=false;
	}
	LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
	double MinLot=MathMin(MinLotSize,LotStep);
	LotMult=ND(MathMax(Lot,MinLotSize)/MinLot,0);
	MinMult=LotMult;
	Lot=MinLot;
	if(MinLot<0.01)LotDecimal=3;
	else if(MinLot<0.1)LotDecimal=2;
	else if(MinLot<1)LotDecimal=1;
	else LotDecimal=0;
	FileHandle=FileOpen(FileName,FILE_BIN|FILE_READ);
	if(FileHandle!=-1)
	{	TbF=FileReadInteger(FileHandle,LONG_VALUE);
		FileClose(FileHandle);
		Error=GetLastError();
		if(OrderSelect(TbF,SELECT_BY_TICKET))
		{	OTbF=OrderOpenTime();
			LbF=OrderLots();
			LotMult=MathMax(1,LbF/MinLot);
			PbC=FindClosedPL(B);
			PhC=FindClosedPL(H);
			TradesOpen=true;
			if(Debug)Print(FileName+" File Read: "+TbF+" Lots: "+DTS(LbF,LotDecimal));
		}
		else
		{	FileDelete(FileName);
			TbF=0;
			OTbF=0;
			LbF=0;
			Error=GetLastError();
			if(Error==ERR_NO_ERROR)
			{	if(Debug)Print(FileName+" File Deleted");
			}
			else Print("Error deleting file: "+FileName+" "+Error+" "+ErrorDescription(Error));
		}
	}
	GlobalVariableSet(ID+"LotMult",LotMult);
	if(Debug)Print("MinLotSize: "+DTS(MinLotSize,2)+" LotStep: "+DTS(LotStep,2)+" MinLot: "+DTS(MinLot,2)+" StartLot: "+DTS(Lot,2)+
		" LotMult: "+DTS(LotMult,0)+" Lot Decimal: "+DTS(LotDecimal,0));
	EmergencyWarning=EmergencyCloseAll;

	if(IsOptimization())Debug=false;
	if(UseAnyEntry)UAE="||";
	else UAE="&&";
	if(ForceMarketCond<0||ForceMarketCond>3)ForceMarketCond=3;
	if(MAEntry<0||MAEntry>2)MAEntry=0;
	if(CCIEntry<0||CCIEntry>2)CCIEntry=0;
	if(BollingerEntry<0||BollingerEntry>2)BollingerEntry=0;
	if(StochEntry<0||StochEntry>2)StochEntry=0;
	if(MACDEntry<0||MACDEntry>2)MACDEntry=0;
	if(MaxCloseTrades==0)MaxCloseTrades=MaxTrades;

	ArrayResize(Digit,6);
	for(y=0;y<ArrayRange(Digit,0);y++)
	{	if(y>0)Digit[y,0]=MathPow(10,y);
		Digit[y,1]=y;
		if(Debug)Print("Digit: "+y+" ["+Digit[y,0]+","+Digit[y,1]+"]");
	}
	LabelCreate();
	dLabels=false;

	//+-----------------------------------------------------------------+
	//| Set Lot Array                                                   |
	//+-----------------------------------------------------------------+
	ArrayResize(Lots,MaxTrades);
	for(y=0;y<MaxTrades;y++)
	{	if(y==0||Multiplier<1)Lots[y]=Lot;
		else Lots[y]=ND(MathMax(Lots[y-1]*Multiplier,Lots[y-1]+LotStep),LotDecimal);
		if(Debug)Print("Lot Size for level "+DTS(y+1,0)+" : "+DTS(Lots[y]*MathMax(LotMult,1),LotDecimal));
	}
	if(Multiplier<1)Multiplier=1;

	//+-----------------------------------------------------------------+
	//| Set Grid and TP array                                           |
	//+-----------------------------------------------------------------+
	if(!AutoCal)
	{	int GridSet,GridTemp,GridTP,GridIndex,GridLevel,GridError;
		ArrayResize(GridArray,MaxTrades);
		if(IsOptimization()&&UseGridOpt)
		{	if(SetArray1>0)
			{	SetCountArray=DTS(SetArray1,0);
				GridSetArray=DTS(GridArray1,0);
				TP_SetArray=DTS(TPArray1,0);
			}
			if(SetArray2>0||(SetArray1>0&&GridArray2>0))
			{	if(SetArray2>0)SetCountArray=SetCountArray+","+DTS(SetArray2,0);
				GridSetArray=GridSetArray+","+DTS(GridArray2,0);
				TP_SetArray=TP_SetArray+","+DTS(TPArray2,0);
			}
			if(SetArray3>0||(SetArray2>0&&GridArray3>0))
			{	if(SetArray3>0)SetCountArray=SetCountArray+","+DTS(SetArray3,0);
				GridSetArray=GridSetArray+","+DTS(GridArray3,0);
				TP_SetArray=TP_SetArray+","+DTS(TPArray3,0);
			}
			if(SetArray4>0||(SetArray3>0&&GridArray4>0))
			{	if(SetArray4>0)SetCountArray=SetCountArray+","+DTS(SetArray4,0);
				GridSetArray=GridSetArray+","+DTS(GridArray4,0);
				TP_SetArray=TP_SetArray+","+DTS(TPArray4,0);
			}
			if(SetArray4>0&&GridArray5>0)
			{	GridSetArray=GridSetArray+","+DTS(GridArray5,0);
				TP_SetArray=TP_SetArray+","+DTS(TPArray5,0);
			}
		}
		while(GridIndex<MaxTrades)
		{	if(StringFind(SetCountArray,",")==-1&&GridIndex==0)
			{	GridError=1;
				break;
			}
			else GridSet=StrToInteger(StringSubstr(SetCountArray,0,StringFind(SetCountArray,",")));
			if(GridSet>0)
			{	SetCountArray=StringSubstr(SetCountArray,StringFind(SetCountArray,",")+1);
				GridTemp=StrToInteger(StringSubstr(GridSetArray,0,StringFind(GridSetArray,",")));
				GridSetArray=StringSubstr(GridSetArray,StringFind(GridSetArray,",")+1);
				GridTP=StrToInteger(StringSubstr(TP_SetArray,0,StringFind(TP_SetArray,",")));
				TP_SetArray=StringSubstr(TP_SetArray,StringFind(TP_SetArray,",")+1);
			}
			else GridSet=MaxTrades;
			if(GridTemp==0||GridTP==0)
			{	GridError=2;
				break;
			}
			for(GridLevel=GridIndex;GridLevel<=MathMin(GridIndex+GridSet-1,MaxTrades-1);GridLevel++)
			{	GridArray[GridLevel,0]=GridTemp;
				GridArray[GridLevel,1]=GridTP;
				if(Debug)Print("GridArray "+(GridLevel+1)+"  : ["+GridArray[GridLevel,0]+","+GridArray[GridLevel,1]+"]");
			}
			GridIndex=GridLevel;
		}
		if(GridError>0||GridArray[0,0]==0||GridArray[0,1]==0)
		{	if(GridError==1)Print("Grid Array Error. Each value should be separated by a comma.");
			else Print("Grid Array Error. Check that there is one more 'Grid' and 'TP' number than there are 'Set' numbers, separated by commas.");
			AllowTrading=false;
		}
	}
	else
	{	while(GridIndex<4)
		{	GridSet=StrToInteger(StringSubstr(SetCountArray,0,StringFind(SetCountArray,",")));
			SetCountArray=StringSubstr(SetCountArray,StringFind(SetCountArray,DTS(GridSet,0))+2);
			if(GridIndex==0&&GridSet<1)
			{	GridError=1;
				break;
			}
			if(GridSet>0)GridLevel+=GridSet;
			else if(GridLevel<MaxTrades)GridLevel=MaxTrades;
			else GridLevel=MaxTrades+1;
			if(GridIndex==0)Set1Level=GridLevel;
			else if(GridIndex==1&&GridLevel<=MaxTrades)Set2Level=GridLevel;
			else if(GridIndex==2&&GridLevel<=MaxTrades)Set3Level=GridLevel;
			else if(GridIndex==3&&GridLevel<=MaxTrades)Set4Level=GridLevel;
			GridIndex++;
		}
		if(GridError==1||Set1Level==0)
		{	Print("Error setting up the Grid Levels. Check that the SetCountArray has valid numbers, separated by a comma.");
			AllowTrading=false;
		}
	}

	//+-----------------------------------------------------------------+
	//| Set holidays array                                              |
	//+-----------------------------------------------------------------+
	if(UseHolidayShutdown)
	{	int HolTemp,NumHols,NumBS,HolCounter;
		string HolTempStr;
		if(StringFind(Holidays,",",0)==-1)NumHols=1;
		else
		{	NumHols=1;
			while(HolTemp!=-1)
			{	HolTemp=StringFind(Holidays,",",HolTemp+1);
				if(HolTemp!=-1)NumHols+=1;
			}
		}
		HolTemp=0;
		while(HolTemp!=-1)
		{	HolTemp=StringFind(Holidays,"/",HolTemp+1);
			if(HolTemp!=-1)NumBS+=1;
		}
		if(NumBS!=NumHols*2)
		{	Print("Holidays Error, number of back-slashes ("+NumBS+") should be equal to 2* number of Holidays ("+NumHols+
					", and separators should be a comma.");
			AllowTrading=false;
		}
		else
		{	HolTemp=0;
			ArrayResize(HolArray,NumHols);
			while(HolTemp!=-1)
			{	if(HolTemp==0)HolTempStr=StringTrimLeft(StringTrimRight(StringSubstr(Holidays,0,StringFind(Holidays,",",HolTemp))));
				else HolTempStr=StringTrimLeft(StringTrimRight(StringSubstr(Holidays,HolTemp+1,
					StringFind(Holidays,",",HolTemp+1)-StringFind(Holidays,",",HolTemp)-1)));
				HolTemp=StringFind(Holidays,",",HolTemp+1);
				HolArray[HolCounter,0]=StrToInteger(StringSubstr(StringSubstr(HolTempStr,0,StringFind(HolTempStr,"-",0)),
					StringFind(StringSubstr(HolTempStr,0,StringFind(HolTempStr,"-",0)),"/")+1));
				HolArray[HolCounter,1]=StrToInteger(StringSubstr(StringSubstr(HolTempStr,0,StringFind(HolTempStr,"-",0)),0,
					StringFind(StringSubstr(HolTempStr,0,StringFind(HolTempStr,"-",0)),"/")));
				HolArray[HolCounter,2]=StrToInteger(StringSubstr(StringSubstr(HolTempStr,StringFind(HolTempStr,"-",0)+1),
					StringFind(StringSubstr(HolTempStr,StringFind(HolTempStr,"-",0)+1),"/")+1));
				HolArray[HolCounter,3]=StrToInteger(StringSubstr(StringSubstr(HolTempStr,StringFind(HolTempStr,"-",0)+1),0,
					StringFind(StringSubstr(HolTempStr,StringFind(HolTempStr,"-",0)+1),"/")));
				HolCounter+=1;
			}
		}
		for(HolTemp=0;HolTemp<HolCounter;HolTemp++)
		{	int Start1,Start2,Temp0,Temp1,Temp2,Temp3;
			for(int Item1=HolTemp+1;Item1<HolCounter;Item1++)
			{	Start1=HolArray[HolTemp,0]*100+HolArray[HolTemp,1];
				Start2=HolArray[Item1,0]*100+HolArray[Item1,1];
				if(Start1>Start2)
				{	Temp0=HolArray[Item1,0];
					Temp1=HolArray[Item1,1];
					Temp2=HolArray[Item1,2];
					Temp3=HolArray[Item1,3];
					HolArray[Item1,0]=HolArray[HolTemp,0];
					HolArray[Item1,1]=HolArray[HolTemp,1];
					HolArray[Item1,2]=HolArray[HolTemp,2];
					HolArray[Item1,3]=HolArray[HolTemp,3];
					HolArray[HolTemp,0]=Temp0;
					HolArray[HolTemp,1]=Temp1;
					HolArray[HolTemp,2]=Temp2;
					HolArray[HolTemp,3]=Temp3;
				}
			}
		}
		if(Debug)
		{	for(HolTemp=0;HolTemp<HolCounter;HolTemp++)
				Print("Holidays - From: ",HolArray[HolTemp,1],"/",HolArray[HolTemp,0]," - ",HolArray[HolTemp,3],"/",HolArray[HolTemp,2]);
		}
	}

	//+-----------------------------------------------------------------+
	//| Set email parameters                                            |
	//+-----------------------------------------------------------------+
	if(UseEmail)
	{	if(Period()==43200)sTF="MN1";
		else if(Period()==10800)sTF="W1";
		else if(Period()==1440)sTF="D1";
		else if(Period()==240)sTF="H4";
		else if(Period()==60)sTF="H1";
		else if(Period()==30)sTF="M30";
		else if(Period()==15)sTF="M15";
		else if(Period()==5)sTF="M5";
		else if(Period()==1)sTF="M1";
		Email[0]=MathMax(MathMin(EmailDD1,MaxDDPercent-1),0)/100;
		Email[1]=MathMax(MathMin(EmailDD2,MaxDDPercent-1),0)/100;
		Email[2]=MathMax(MathMin(EmailDD3,MaxDDPercent-1),0)/100;
		ArraySort(Email,WHOLE_ARRAY,0,MODE_ASCEND);
		for(int z=0;z<=2;z++)
		{	for(y=0;y<=2;y++)
			{	if(Email[y]==0)
				{	Email[y]=Email[y+1];
					Email[y+1]=0;
				}
			}
			if(Debug)Print("Email ["+(z+1)+"] : "+Email[z]);
		}
	}

	//+-----------------------------------------------------------------+
	//| Set SmartGrid parameters                                        |
	//+-----------------------------------------------------------------+
	if(UseSmartGrid)
	{	ArrayResize(RSI,RSI_Period+RSI_MA_Period);
		ArraySetAsSeries(RSI,true);
	}

	//+---------------------------------------------------------------+
	//| Initialize Statistics                                         |
	//+---------------------------------------------------------------+
	if(SaveStats)
	{	StatFile="B3"+Symbol()+"_"+Period()+"_"+EANumber+".csv";
		NextStats=TimeCurrent();
		Stats(StatsInitialise,false,AccountBalance()*PortionPC,0);
	}
	return(0);
}

//+-----------------------------------------------------------------+
//| expert deinitialization function                                |
//+-----------------------------------------------------------------+
int deinit()
{	switch(UninitializeReason())
	{	case REASON_REMOVE:
		case REASON_CHARTCLOSE:
		case REASON_CHARTCHANGE:
			if(CpT>0)while(CpT>0)CpT-=ExitTrades(P,displayColorLoss,"Blessing Removed");
			GlobalVariablesDeleteAll(ID);
		case REASON_RECOMPILE:
		case REASON_PARAMETERS:
		case REASON_ACCOUNT:
			if(!Testing)LabelDelete();
			Comment("");
	}
	return(0);
}

//+-----------------------------------------------------------------+
//| expert start function                                           |
//+-----------------------------------------------------------------+
int start()
{	int     CbB          =0;     // Count buy
	int     CbS          =0;     // Count sell
	int     CpBL         =0;     // Count buy limit
	int     CpSL         =0;     // Count sell limit
	int     CpBS         =0;     // Count buy stop
	int     CpSS         =0;     // Count sell stop
	double  LbB          =0;     // Count buy lots
	double  LbS          =0;     // Count sell lots
	double  LbT          =0;     // total lots out
	double  OPpBL        =0;     // Buy limit open price
	double  OPpSL        =0;     // Sell limit open price
	double  SLbB         =0;     // stop losses are set to zero if POSL off
	double  SLbS         =0;     // stop losses are set to zero if POSL off
	double  BCb,BCh,BCa;         // Broker costs (swap + commission)
	double  ProfitPot    =0;     // The Potential Profit of a basket of Trades
	double  PipValue,PipVal2,ASK,BID;
	double  OrderLot;
	double  OPbL,OPhO;           // last open price
	int     OTbL;                // last open time
	double  g2,tp2,Entry,RSI_MA,LhB,LhS,LhT,OPbO,OTbO,OThO,TbO,ThO;
	int     Ticket,ChB,ChS,IndEntry;
	double  Pb,Ph,PaC,PbPips,PbTarget,DrawDownPC,BEb,BEh,BEa;
	bool    BuyMe,SellMe,Success,SetPOSL;
	string  IndicatorUsed;

	//+-----------------------------------------------------------------+
	//| Count Open Orders, Lots and Totals                              |
	//+-----------------------------------------------------------------+
	PipVal2=MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE);
	PipValue=PipVal2*Pip;
	StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
	ASK=ND(MarketInfo(Symbol(),MODE_ASK),MarketInfo(Symbol(),MODE_DIGITS));
	BID=ND(MarketInfo(Symbol(),MODE_BID),MarketInfo(Symbol(),MODE_DIGITS));
	if(ASK==0||BID==0)return(0);
	for(y=0;y<OrdersTotal();y++)
	{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
		int Type=OrderType();
		if(OrderMagicNumber()==hMagic)
		{	Ph+=OrderProfit();
			BCh+=OrderSwap()+OrderCommission();
			BEh+=OrderLots()*OrderOpenPrice();
			if(OrderOpenTime()<OThO||OThO==0)
			{	OThO=OrderOpenTime();
				ThO=OrderTicket();
				OPhO=OrderOpenPrice();
			}
			if(Type==OP_BUY)
			{	ChB++;
				LhB+=OrderLots();
			}
			else if(Type==OP_SELL)
			{	ChS++;
				LhS+=OrderLots();
			}
			continue;
		}
		if(OrderMagicNumber()!=Magic||OrderSymbol()!=Symbol())continue;
		if(OrderTakeProfit()>0)ModifyOrder(OrderOpenPrice(),OrderStopLoss());
		if(Type<=OP_SELL)
		{	Pb+=OrderProfit();
			BCb+=OrderSwap()+OrderCommission();
			BEb+=OrderLots()*OrderOpenPrice();
			if(OrderOpenTime()>=OTbL)
			{	OTbL=OrderOpenTime();
				OPbL=OrderOpenPrice();
			}
			if(OrderOpenTime()<OTbF||TbF==0)
			{	OTbF=OrderOpenTime();
				TbF=OrderTicket();
				LbF=OrderLots();
			}
			if(OrderOpenTime()<OTbO||OTbO==0)
			{	OTbO=OrderOpenTime();
				TbO=OrderTicket();
				OPbO=OrderOpenPrice();
			}
			if(UsePowerOutSL&&((POSLPips>0&&OrderStopLoss()==0)||(POSLPips==0&&OrderStopLoss()>0)))SetPOSL=true;
			if(Type==OP_BUY)
			{	CbB++;
				LbB+=OrderLots();
				continue;
			}
			else
			{	CbS++;
				LbS+=OrderLots();
				continue;
			}
		}
		else
		{	if(Type==OP_BUYLIMIT)
			{	CpBL++;
				OPpBL=OrderOpenPrice();
				continue;
			}
			else if(Type==OP_SELLLIMIT)
			{	CpSL++;
				OPpSL=OrderOpenPrice();
				continue;
			}
			else if(Type==OP_BUYSTOP)CpBS++;
			else CpSS++;
		}
	}
	CbT=CbB+CbS;
	LbT=LbB+LbS;
	Pb=ND(Pb+BCb,2);
	ChT=ChB+ChS;
	LhT=LhB+LhS;
	Ph=ND(Ph+BCh,2);
	CpT=CpBL+CpSL+CpBS+CpSS;
	BCa=BCb+BCh;

	//+-----------------------------------------------------------------+
	//| Calculate Min/Max Profit and Break Even Points                  |
	//+-----------------------------------------------------------------+
	if(LbT>0)
	{	BEb=ND(BEb/LbT,Digits);
		if(BCa<0)BEb-=ND(BCa/PipVal2/(LbB-LbS),Digits);
		if(Pb>PbMax||PbMax==0)PbMax=Pb;
		if(Pb<PbMin||PbMin==0)PbMin=Pb;
		if(!TradesOpen)
		{	FileHandle=FileOpen(FileName,FILE_BIN|FILE_WRITE);
			if(FileHandle>-1)
			{	FileWriteInteger(FileHandle,TbF);
				FileClose(FileHandle);
				TradesOpen=true;
				if(Debug)Print(FileName+" File Written: "+TbF);
			}
		}
	}
	else if(TradesOpen)
	{	TPb=0;
		PbMax=0;
		PbMin=0;
		OTbF=0;
		TbF=0;
		LbF=0;
		PbC=0;
		PhC=0;
		PaC=0;
		ClosedPips=0;
		CbC=0;
		CaL=0;
		bTS=0;
		if(HedgeTypeDD)hDDStart=HedgeStart;
		else hLvlStart=HedgeStart;
		EmailCount=0;
		EmailSent=0;
		FileHandle=FileOpen(FileName,FILE_BIN|FILE_READ);
		if(FileHandle>-1)
		{	FileClose(FileHandle);
			Error=GetLastError();
			FileDelete(FileName);
			Error=GetLastError();
			if(Error==ERR_NO_ERROR)
			{	if(Debug)Print(FileName+" File Deleted");
				TradesOpen=false;
			}
			else Print("Error deleting file: "+FileName+" "+Error+" "+ErrorDescription(Error));
		}
		else TradesOpen=false;
	}
	if(LhT>0)
	{	BEh=ND(BEh/LhT,Digits);
		if(Ph>PhMax||PhMax==0)PhMax=Ph;
		if(Ph<PhMin||PhMin==0)PhMin=Ph;
	}
	else
	{	PhMax=0;
		PhMin=0;
		SLh=0;
	}

	//+-----------------------------------------------------------------+
	//| Check if trading is allowed                                     |
	//+-----------------------------------------------------------------+
	if(CbT==0&&ChT==0&&ShutDown)
	{	if(CpT>0)
		{	ExitTrades(P,displayColorLoss,"Blessing is shutting down");
			return(0);
		}
		if(AllowTrading)
		{	Print("Blessing has ShutDown. Set ShutDown = 'false' to continue trading");
			if(PlaySounds)PlaySound(AlertSound);
			AllowTrading=false;
		}
		if(UseEmail&&EmailCount<4&&!Testing)
		{	SendMail("Blessing EA","Blessing has shut down on "+Symbol()+" "+sTF+
					". Trading has been suspended. To resume trading, set ShutDown to false.");
			Error=GetLastError();
			if(Error>0)Print("Error sending Email: "+Error+" "+ErrorDescription(Error));
			else EmailCount=4;
		}
	}
	if(!AllowTrading)
	{	static bool LDelete;
		if(!LDelete)
		{	LDelete=true;
			LabelDelete();
			if(ObjectFind("B3LStop")==-1)CreateLabel("B3LStop","Trading has been stopped on this pair.",10,0,0,3,displayColorLoss);
			if(Testing)string Tab="Tester Journal";
			else Tab="Terminal Experts";
			if(ObjectFind("B3LExpt")==-1)CreateLabel("B3LExpt","Check the "+Tab+" tab for the reason why.",10,0,0,6,displayColorLoss);
			if(ObjectFind("B3LResm")==-1)CreateLabel("B3LResm","Reset Blessing to resume trading.",10,0,0,9,displayColorLoss);
		}
		return(0);
	}
	else
	{	LDelete=false;
		ObjDel("B3LStop");
		ObjDel("B3LExpt");
		ObjDel("B3LResm");
	}

	//+-----------------------------------------------------------------+
	//| Calculate Drawdown and Equity Protection                        |
	//+-----------------------------------------------------------------+
	double NewPortionBalance=ND(AccountBalance()*PortionPC,2);
	if(CbT==0||PortionChange<0||(PortionChange>0&&NewPortionBalance>PortionBalance))PortionBalance=NewPortionBalance;
	if(Pb+Ph<0)DrawDownPC=-(Pb+Ph)/PortionBalance;
	if(!FirstRun&&DrawDownPC>=MaxDDPercent/100)
	{	ExitTrades(A,displayColorLoss,"Equity Stop Loss Reached");
		if(PlaySounds)PlaySound(AlertSound);
		return(0);
	}
	if(-(Pb+Ph)>MaxDD)MaxDD=-(Pb+Ph);
	MaxDDPer=MathMax(MaxDDPer,DrawDownPC*100);
	if(SaveStats)Stats(false,TimeCurrent()<NextStats,PortionBalance,Pb+Ph);

	//+-----------------------------------------------------------------+
	//| Calculate  Stop Trade Percent                                   |
	//+-----------------------------------------------------------------+
	double StepAB=InitialAB*(1+StopTradePercent);
	double StepSTB=AccountBalance()*(1-StopTradePercent);
	double NextISTB=StepAB*(1-StopTradePercent);
	if(StepSTB>NextISTB)
	{	InitialAB=StepAB;
		StopTradeBalance=StepSTB;
	}
	double InitialAccountMultiPortion=StopTradeBalance*PortionPC;
	if(PortionBalance<InitialAccountMultiPortion)
	{	if(CbT==0)
		{	AllowTrading=false;
			if(PlaySounds)PlaySound(AlertSound);
			Print("Portion Balance dropped below stop trade percent");
			MessageBox("Reset Blessing, account balance dropped below stop trade percent on "+Symbol()+Period(),"Blessing 3: Warning",48);
			return(0);
		}
		else if(!ShutDown&&!RecoupClosedLoss)
		{	ShutDown=true;
			if(PlaySounds)PlaySound(AlertSound);
			Print("Portion Balance dropped below stop trade percent");
			return(0);
		}
	}

	//+-----------------------------------------------------------------+
	//| Calculation of Trend Direction                                  |
	//+-----------------------------------------------------------------+
	int Trend;
	string ATrend;
	double ima_0=iMA(Symbol(),0,MAPeriod,0,MODE_EMA,PRICE_CLOSE,0);
	if(ForceMarketCond==3)
	{	if(BID>ima_0+MADistance)Trend=0;
		else if(ASK<ima_0-MADistance)Trend=1;
		else Trend=2;
	}
	else
	{	Trend=ForceMarketCond;
		if(Trend!=0&&BID>ima_0+MADistance)ATrend="U";
		if(Trend!=1&&ASK<ima_0-MADistance)ATrend="D";
		if(Trend!=2&&(BID<ima_0+MADistance&&ASK>ima_0-MADistance))ATrend="R";
	}
	//+-----------------------------------------------------------------+
	//| Hedge/Basket/ClosedTrades Profit Management                     |
	//+-----------------------------------------------------------------+
	double Pa=Pb;
	PaC=PbC+PhC;
	if(hActive==1&&ChT==0)
	{	PhC=FindClosedPL(H);
		hActive=0;
		return(0);
	}
	else if(hActive==0&&ChT>0)hActive=1;
	if(LbT>0)
	{	if(PbC>0||(PbC<0&&RecoupClosedLoss))
		{	Pa+=PbC;
			BEb-=ND(PbC/PipVal2/(LbB-LbS),Digits);
		}
		if(PhC>0||(PhC<0&&RecoupClosedLoss))
		{	Pa+=PhC;
			BEb-=ND(PhC/PipVal2/(LbB-LbS),Digits);
		}
		if(Ph>0||(Ph<0&&RecoupClosedLoss))Pa+=Ph;
	}

	//+-----------------------------------------------------------------+
	//| Close oldest open trade after CloseTradesLevel reached          |
	//+-----------------------------------------------------------------+
	if(UseCloseOldest&&CbT>=CloseTradesLevel&&CbC<MaxCloseTrades)
	{	if(!FirstRun&&TPb>0&&(ForceCloseOldest||(CbB>0&&OPbO>TPb)||(CbS>0&&OPbO<TPb)))
		{	y=ExitTrades(T,DarkViolet,"Close Oldest Trade",TbO);
			if(y==1)
			{	OrderSelect(TbO,SELECT_BY_TICKET);
				PbC+=OrderProfit()+OrderSwap()+OrderCommission();
				ca=0;
				CbC++;
				return(0);
			}
		}
	}

	//+-----------------------------------------------------------------+
	//| ATR for Auto Grid Calculation and Grid Set Block                |
	//+-----------------------------------------------------------------+
	if(AutoCal)
	{	double GridTP;
		double GridATR=iATR(NULL,TF[ATRTF],ATRPeriods,0)/Pip;
		if((CbT+CbC>Set4Level)&&Set4Level>0)
		{	g2=GridATR*12;    //GS*2*2*2*1.5
			tp2=GridATR*18;   //GS*2*2*2*1.5*1.5
		}
		else if((CbT+CbC>Set3Level)&&Set3Level>0)
		{	g2=GridATR*8;     //GS*2*2*2
			tp2=GridATR*12;   //GS*2*2*2*1.5
		}
		else if((CbT+CbC>Set2Level)&&Set2Level>0)
		{	g2=GridATR*4;     //GS*2*2
			tp2=GridATR*8;    //GS*2*2*2
		}
		else if((CbT+CbC>Set1Level)&&Set1Level>0)
		{	g2=GridATR*2;     //GS*2
			tp2=GridATR*4;    //GS*2*2
		}
		else
		{	g2=GridATR;
			tp2=GridATR*2;
		}
		GridTP=GridATR*2;
	}
	else
	{	y=MathMax(MathMin(CbT+CbC,MaxTrades)-1,0);
		g2=GridArray[y,0];
		tp2=GridArray[y,1];
		GridTP=GridArray[0,1];
	}
	g2=ND(MathMax(g2*GAF*Pip,Pip),Digits);
	tp2=ND(tp2*GAF*Pip,Digits);
	GridTP=ND(GridTP*GAF*Pip,Digits);


	//+-----------------------------------------------------------------+
	//| Money Management and Lot size coding                            |
	//+-----------------------------------------------------------------+
	if(UseMM)
	{	if(CbT>0)
		{	if(GlobalVariableCheck(ID+"LotMult"))LotMult=GlobalVariableGet(ID+"LotMult");
			if(LbF!=LotSize(Lots[0]*LotMult))
			{	LotMult=LbF/Lots[0];
				GlobalVariableSet(ID+"LotMult",LotMult);
				Print("LotMult reset to "+DTS(LotMult,0));
			}
		}
		if(CbT==0)
		{	double Contracts,Factor,Lotsize;
			Contracts=PortionBalance/10000;
			if(Multiplier<=1)Factor=Level;
			else Factor=(MathPow(Multiplier,Level)-Multiplier)/(Multiplier-1);
			Lotsize=LAF*AccountType*Contracts/(1+Factor);
			LotMult=MathMax(MathFloor(Lotsize/Lot),MinMult);
			GlobalVariableSet(ID+"LotMult",LotMult);
		}
	}
	else if(CbT==0)LotMult=MinMult;
	//+-----------------------------------------------------------------+
	//| Calculate Take Profit                                           |
	//+-----------------------------------------------------------------+
	static double BCaL,BEbL;
	double nLots=LbB-LbS;
	if(CbT>0&&(TPb==0||CbT+ChT!=CaL||BEbL!=BEb||BCa!=BCaL||FirstRun))
	{	string sCalcTP="Set New TP:  BE: "+DTS(BEb,Digits);
		double NewTP,BasePips;
		CaL=CbT+ChT;
		BCaL=BCa;
		BEbL=BEb;
		BasePips=ND(Lot*LotMult*GridTP*(CbT+CbC)/nLots,Digits);
		if(CbB>0)
		{	if(ForceTPPips>0)
			{	NewTP=BEb+ForceTPPips;
				sCalcTP=sCalcTP+" +Force TP ("+DTS(ForceTPPips,Digits)+") ";
			}
			else if(CbC>0&&CloseTPPips>0)
			{	NewTP=BEb+CloseTPPips;
				sCalcTP=sCalcTP+" +Close TP ("+DTS(CloseTPPips,Digits)+") ";
			}
			else if(BEb+BasePips>OPbL+tp2)
			{	NewTP=BEb+BasePips;
				sCalcTP=sCalcTP+" +Base TP: ("+DTS(BasePips,Digits)+") ";
			}
			else
			{	NewTP=OPbL+tp2;
				sCalcTP=sCalcTP+" +Grid TP: ("+DTS(tp2,Digits)+") ";
			}
			if(MinTPPips>0)
			{	NewTP=MathMax(NewTP,BEb+MinTPPips);
				sCalcTP=sCalcTP+" >Minimum TP: ";
			}
			NewTP+=MoveTP*Moves;
			if(BreakEvenTrade>0&&CbT+CbC>=BreakEvenTrade)
			{	NewTP=BEb+BEPlusPips;
				sCalcTP=sCalcTP+" >BreakEven: ("+DTS(BEPlusPips,Digits)+") ";
			}
			sCalcTP=(sCalcTP+"Buy: TakeProfit: ");
		}
		else if(CbS>0)
		{	if(ForceTPPips>0)
			{	NewTP=BEb-ForceTPPips;
				sCalcTP=sCalcTP+" -Force TP ("+DTS(ForceTPPips,Digits)+") ";
			}
			else if(CbC>0&&CloseTPPips>0)
			{	NewTP=BEb-CloseTPPips;
				sCalcTP=sCalcTP+" -Close TP ("+DTS(CloseTPPips,Digits)+") ";
			}
			else if(BEb+BasePips<OPbL-tp2)
			{	NewTP=BEb+BasePips;
				sCalcTP=sCalcTP+" -Base TP: ("+DTS(BasePips,Digits)+") ";
			}
			else
			{	NewTP=OPbL-tp2;
				sCalcTP=sCalcTP+" -Grid TP: ("+DTS(tp2,Digits)+") ";
			}
			if(MinTPPips>0)
			{	NewTP=MathMin(NewTP,BEb-MinTPPips);
				sCalcTP=sCalcTP+" >Minimum TP: ";
			}
			NewTP-=MoveTP*Moves;
			if(BreakEvenTrade>0&&CbT+CbC>=BreakEvenTrade)
			{	NewTP=BEb-BEPlusPips;
				sCalcTP=sCalcTP+" >BreakEven: ("+DTS(BEPlusPips,Digits)+") ";
			}
			sCalcTP=(sCalcTP+"Sell: TakeProfit: ");
		}
		if(TPb!=NewTP)
		{	TPb=NewTP;
			if(nLots>0)TargetPips=ND(TPb-BEb,Digits);
			else TargetPips=ND(BEb-TPb,Digits);
			Print(sCalcTP+DTS(NewTP,Digits));
			return(0);
		}
	}
	PbTarget=TargetPips/Pip;
	ProfitPot=ND(TargetPips*PipVal2*MathAbs(nLots),2);
	if(CbB>0)PbPips=ND((BID-BEb)/Pip,1);
	if(CbS>0)PbPips=ND((BEb-ASK)/Pip,1);

	//+-----------------------------------------------------------------+
	//| Adjust BEb/TakeProfit if Hedge is active                        |
	//+-----------------------------------------------------------------+
	double hAsk=MarketInfo(HedgeSymbol,MODE_ASK);
	double hBid=MarketInfo(HedgeSymbol,MODE_BID);
	double hSpread=hAsk-hBid;
	if(hThisChart)nLots+=LhB-LhS;
	if(hActive==1)
	{	double TPa,PhPips;
		if(nLots==0)
		{	BEa=0;
			TPa=0;
		}
		else if(hThisChart)
		{	if(nLots>0)
			{	if(CbB>0)BEa=ND((BEb*LbT-(BEh-hSpread)*LhT)/(LbT-LhT),Digits);
				else BEa=ND(((BEb-(ASK-BID))*LbT-BEh*LhT)/(LbT-LhT),Digits);
				TPa=ND(BEa+TargetPips,Digits);
			}
			else
			{	if(CbS>0)BEa=ND((BEb*LbT-(BEh+hSpread)*LhT)/(LbT-LhT),Digits);
				else BEa=ND(((BEb+ASK-BID)*LbT-BEh*LhT)/(LbT-LhT),Digits);
				TPa=ND(BEa-TargetPips,Digits);
			}
		}
		else
		{
		}
		if(ChB>0)PhPips=ND((hBid-BEh)/hPip,1);
		if(ChS>0)PhPips=ND((BEh-hAsk)/hPip,1);
	}
	else
	{	BEa=BEb;
		TPa=TPb;
	}
	//+-----------------------------------------------------------------+
	//| Calculate Early Exit Percentage                                 |
	//+-----------------------------------------------------------------+
	if(UseEarlyExit&&CbT>0)
	{	double EEpc,EEopt,EEStartTime,TPaF;
		if(EEFirstTrade)EEopt=OTbF;
		else EEopt=OTbL;
		if(DayOfWeek()<TimeDayOfWeek(EEopt))EEStartTime=2*24*3600;
		EEStartTime+=EEopt+EEStartHours*3600;
		if(EEHoursPC>0&&TimeCurrent()>=EEStartTime)EEpc=EEHoursPC*(TimeCurrent()-EEStartTime)/3600;
		if(EELevelPC>0&&(CbT+CbC)>=EEStartLevel)EEpc+=EELevelPC*(CbT+CbC-EEStartLevel+1);
		EEpc=1-EEpc;
		if(!EEAllowLoss&&EEpc<0)EEpc=0;
		PbTarget*=EEpc;
		TPaF=ND((TPa-BEa)*EEpc+BEa,Digits);
		if(displayOverlay&&displayLines&&(hActive!=1||(hActive==1&&hThisChart))&&(!Testing||(Testing&&Visual))&&EEpc<1
			&&(CbT+CbC+ChT>EECount||EETime!=Time[0])&&((EEHoursPC>0&&EEopt+EEStartHours*3600<Time[0])||(EELevelPC>0&&CbT+CbC>=EEStartLevel)))
		{	EETime=Time[0];
			EECount=CbT+CbC+ChT;
			if(ObjectFind("B3LEELn")<0)
			{	ObjectCreate("B3LEELn",OBJ_TREND,0,0,0);
				ObjectSet("B3LEELn",OBJPROP_COLOR,Yellow);
				ObjectSet("B3LEELn",OBJPROP_WIDTH,1);
				ObjectSet("B3LEELn",OBJPROP_STYLE,0);
				ObjectSet("B3LEELn",OBJPROP_RAY,false);
			}
			if(EEHoursPC>0)ObjectMove("B3LEELn",0,MathFloor(EEopt/3600+EEStartHours)*3600,TPa);
			else ObjectMove("B3LEELn",0,MathFloor(EEopt/3600)*3600,TPaF);
			ObjectMove("B3LEELn",1,Time[1],TPaF);
			if(ObjectFind("B3VEELn")<0)
			{	ObjectCreate("B3VEELn",OBJ_TEXT,0,0,0);
				ObjectSet("B3VEELn",OBJPROP_COLOR,Yellow);
				ObjectSet("B3VEELn",OBJPROP_WIDTH,1);
				ObjectSet("B3VEELn",OBJPROP_STYLE,0);
			}
			ObjSetTxt("B3VEELn","              "+DTS(TPaF,Digits),-1,Yellow);
			ObjectSet("B3VEELn",OBJPROP_PRICE1,TPaF+2*Pip);
			ObjectSet("B3VEELn",OBJPROP_TIME1,Time[1]);
		}
		else if((!displayLines||EEpc==1||(!EEAllowLoss&&EEpc==0)||(EEHoursPC>0&&EEopt+EEStartHours*3600>=Time[0])))
		{	ObjDel("B3LEELn");
			ObjDel("B3VEELn");
		}
	}
	else
	{	TPaF=TPa;
		EETime=0;
		EECount=0;
		ObjDel("B3LEELn");
		ObjDel("B3VEELn");
	}

	//+-----------------------------------------------------------------+
	//| Maximize Profit with Moving TP and setting Trailing Profit Stop |
	//+-----------------------------------------------------------------+
	if(MaximizeProfit)
	{	if(CbT==0)
		{	SLbL=0;
			Moves=0;
			SLb=0;
		}
		if(!FirstRun&&CbT>0)
		{	if(Pb+Ph<0&&SLb>0)SLb=0;
			if(SLb>0&&((nLots>0&&BID<SLb)||(nLots<0&&ASK>SLb)))
			{	ExitTrades(A,displayColorProfit,"Profit Trailing Stop Reached ("+DTS(ProfitSet*100,2)+"%)");
				return(0);
			}
			if(PbTarget>0)
			{	double TPbMP=ND(BEa+(TPa-BEa)*ProfitSet,Digits);
				if((nLots>0&&BID>TPbMP)||(nLots<0&&ASK<TPbMP))SLb=TPbMP;
			}
			if(SLb>0&&SLb!=SLbL&&MoveTP>0&&TotalMoves>Moves)
			{	TPb=0;
				Moves++;
				if(Debug)Print("MoveTP");
				SLbL=SLb;
				if(PlaySounds)PlaySound(AlertSound);
				return(0);
			}
		}
	}
	if(!FirstRun&&TPaF>0)
	{	if((nLots>0&&BID>=TPaF)||(nLots<0&&ASK<=TPaF))
		{	ExitTrades(A,displayColorProfit,"Profit Target Reached @ "+DTS(TPaF,Digits));
			return(0);
		}
	}
	if(!FirstRun&&UseStopLoss)
	{	double bSL;
		if(SLPips>0)
		{	if(nLots>0)
			{	bSL=BEa-SLPips;
				if(BID<=bSL)
				{	ExitTrades(A,displayColorProfit,"Stop Loss Reached");
					return(0);
				}
			}
			else if(nLots<0)
			{	bSL=BEa+SLPips;
				if(ASK>=bSL)
				{	ExitTrades(A,displayColorProfit,"Stop Loss Reached");
					return(0);
				}
			}
		}
		if(TSLPips!=0)
		{	if(nLots>0)
			{	if(TSLPips>0&&BID>BEa+TSLPips)bTS=MathMax(bTS,BID-TSLPips);
				if(TSLPips<0&&BID>BEa-TSLPips)bTS=MathMax(bTS,BID-MathMax(TSLPipsMin,-TSLPips*(1-(BID-BEa+TSLPips)/(-TSLPips*2))));
				if(bTS>0&&BID<=bTS)
				{	ExitTrades(A,displayColorProfit,"Trailing Stop Reached");
					return(0);
				}
			}
			else if(nLots<0)
			{	if(TSLPips>0&&ASK<BEa-TSLPips)
				{	if(bTS>0)bTS=MathMin(bTS,ASK+TSLPips);
				   else bTS=ASK+TSLPips;
				}
				if(TSLPips<0&&ASK<BEa+TSLPips)bTS=MathMin(bTS,ASK+MathMax(TSLPipsMin,-TSLPips*(1-(BEa-ASK+TSLPips)/(-TSLPips*2))));
				if(bTS>0&&ASK>=bTS)
				{	ExitTrades(A,displayColorProfit,"Trailing Stop Reached");
					return(0);
				}
			}
		}
	}

	//+-----------------------------------------------------------------+
	//| Check for and Delete hanging pending orders                     |
	//+-----------------------------------------------------------------+
	if(CbT==0&&!PendLot)
	{	PendLot=true;
		for(y=OrdersTotal()-1;y>=0;y--)
		{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
			if(OrderMagicNumber()!=Magic||OrderType()<=OP_SELL)continue;
			if(ND(OrderLots(),LotDecimal)>ND(Lots[0]*LotMult,LotDecimal))
			{	PendLot=false;
				while(IsTradeContextBusy())Sleep(100);
				if(IsStopped())return(-1);
				Success=OrderDelete(OrderTicket());
				if(Success)
				{	PendLot=true;
					if(Debug)Print("Delete pending > Lot");
				}
			}
		}
		return(0);
	}
	else if((CbT>0||(CbT==0&&CpT>0&&!B3Traditional))&&PendLot)
	{	PendLot=false;
		for(y=OrdersTotal()-1;y>=0;y--)
		{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
			if(OrderMagicNumber()!=Magic||OrderType()<=OP_SELL)continue;
			if(ND(OrderLots(),LotDecimal)==ND(Lots[0]*LotMult,LotDecimal))
			{	PendLot=true;
				while(IsTradeContextBusy())Sleep(100);
				if(IsStopped())return(-1);
				Success=OrderDelete(OrderTicket());
				if(Success)
				{	PendLot=false;
					if(Debug)Print("Delete pending = Lot");
				}
			}
		}
		return(0);
	}

	//+-----------------------------------------------------------------+
	//| Check ca, Breakeven Trades and Emergency Close All              |
	//+-----------------------------------------------------------------+
	switch(ca)
	{	case B:  if(CbT==0&&CpT==0)ca=0;break;
		case H:  if(ChT==0)ca=0;break;
		case A:  if(CbT==0&&CpT==0&&ChT==0)ca=0;break;
		case P:  if(CpT==0)ca=0;break;
		case T:  break;
		default: break;
	}
	if(ca>0)
	{	ExitTrades(ca,displayColorLoss,"Close All ("+DTS(ca,0)+")");
		return(0);
	}
	if(CbT==0&&ChT>0)
	{	ExitTrades(H,displayColorLoss,"Basket Closed");
		return(0);
	}
	if(EmergencyCloseAll)
	{	ExitTrades(A,displayColorLoss,"Emergency Close All Trades");
		EmergencyCloseAll=false;
		return(0);
	}

	//+-----------------------------------------------------------------+
	//| Check Holiday Shutdown                                          |
	//+-----------------------------------------------------------------+
	if(UseHolidayShutdown)
	{	if(HolShutDown>0&&TimeCurrent()>=HolLast&&HolLast>0)
		{	Print("Blessing has resumed after the holidays. From: "+TimeToStr(HolFirst,TIME_DATE)+" To: "+TimeToStr(HolLast,TIME_DATE));
			HolShutDown=0;
			LabelDelete();
			LabelCreate();
			if(PlaySounds)PlaySound(AlertSound);
		}
		if(HolShutDown==3)
		{	if(ObjectFind("B3LStop")==-1)
				CreateLabel("B3LStop","Trading has been stopped on this pair for the holidays.",10,0,0,3,displayColorLoss);
			if(ObjectFind("B3LResm")==-1)
				CreateLabel("B3LResm","Blessing will resume trading after "+TimeToStr(HolLast,TIME_DATE)+".",10,0,0,9,displayColorLoss);
			return(0);
		}
		else if((HolShutDown==0&&TimeCurrent()>=HolLast)||HolFirst==0)
		{	for(y=0;y<ArraySize(HolArray);y++)
			{	HolFirst=StrToTime(Year()+"."+HolArray[y,0]+"."+HolArray[y,1]);
				HolLast=StrToTime(Year()+"."+HolArray[y,2]+"."+HolArray[y,3]+" 23:59:59");
				if(TimeCurrent()<HolFirst)
				{	if(HolFirst>HolLast)HolLast=StrToTime(DTS(Year()+1,0)+"."+HolArray[y,2]+"."+HolArray[y,3]+" 23:59:59");
					break;
				}
				if(TimeCurrent()<HolLast)
				{	if(HolFirst>HolLast)HolFirst=StrToTime(DTS(Year()-1,0)+"."+HolArray[y,0]+"."+HolArray[y,1]);
					break;
				}
				if(TimeCurrent()>HolFirst&&HolFirst>HolLast)
				{	HolLast=StrToTime(DTS(Year()+1,0)+"."+HolArray[y,2]+"."+HolArray[y,3]+" 23:59:59");
					if(TimeCurrent()<HolLast)break;
				}
			}
			if(TimeCurrent()>=HolFirst&&TimeCurrent()<=HolLast)
			{	Comment("");
				HolShutDown=1;
			}
		}
		else if(HolShutDown==0&&TimeCurrent()>=HolFirst&&TimeCurrent()<HolLast)HolShutDown=1;
		if(HolShutDown==1&&CbT==0)
		{	Print("Blessing has shut down for the holidays. From: "+TimeToStr(HolFirst,TIME_DATE)+
					" To: "+TimeToStr(HolLast,TIME_DATE));
			if(CpT>0)
			{	y=ExitTrades(P,displayColorLoss,"Holiday Shutdown");
				if(y==CpT)ca=0;
			}
			HolShutDown=2;
			ObjDel("B3LClos");
		}
		else if(HolShutDown==1)
		{	if(ObjectFind("B3LClos")==-1)CreateLabel("B3LClos","",5,0,0,23,displayColorLoss);
			ObjSetTxt("B3LClos","Blessing will shutdown for the holidays when this basket closes",5);
		}
		if(HolShutDown==2)
		{	LabelDelete();
			if(PlaySounds)PlaySound(AlertSound);
			HolShutDown=3;
		}
		if(HolShutDown==3)
		{	if(ObjectFind("B3LStop")==-1)
				CreateLabel("B3LStop","Trading has been stopped on this pair for the holidays.",10,0,0,3,displayColorLoss);
			if(ObjectFind("B3LResm")==-1)
				CreateLabel("B3LResm","Blessing will resume trading after "+TimeToStr(HolLast,TIME_DATE)+".",10,0,0,9,displayColorLoss);
			Comment("");
			return(0);
		}
	}

	//+-----------------------------------------------------------------+
	//| Power Out Stop Loss Protection                                  |
	//+-----------------------------------------------------------------+
	if(SetPOSL)
	{	if(UsePowerOutSL&&POSLPips>0)
		{	double POSL=MathMin(PortionBalance*(MaxDDPercent+1)/100/PipVal2/LbT,POSLPips);
			SLbB=ND(BEb-POSL,Digits);
			SLbS=ND(BEb+POSL,Digits);
		}
		else
		{	SLbB=0;
			SLbS=0;
		}
		for(y=0;y<OrdersTotal();y++)
		{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
			if(OrderMagicNumber()!=Magic||OrderSymbol()!=Symbol()||OrderType()>OP_SELL)continue;
			if(OrderType()==OP_BUY&&OrderStopLoss()!=SLbB)
			{	Success=ModifyOrder(OrderOpenPrice(),SLbB,Purple);
				if(Debug&&Success)Print("Order: "+OrderTicket()+" Sync POSL Buy");
			}
			else if(OrderType()==OP_SELL&&OrderStopLoss()!=SLbS)
			{	Success=ModifyOrder(OrderOpenPrice(),SLbS,Purple);
				if(Debug&&Success)Print("Order: "+OrderTicket()+" Sync POSL Sell");
			}
		}
	}

	//+-----------------------------------------------------------------+  << This must be the first Entry check.
	//| Moving Average Indicator for Order Entry                        |  << Add your own Indicator Entry checks
	//+-----------------------------------------------------------------+  << after the Moving Average Entry.
	if(MAEntry>0&&CbT==0&&CpT<2)
	{	if(BID>ima_0+MADistance&&(!B3Traditional||(B3Traditional&&Trend!=2)))
		{	if(MAEntry==1)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
			else if(MAEntry==2)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
		}
		else if(ASK<ima_0-MADistance&&(!B3Traditional||(B3Traditional&&Trend!=2)))
		{	if(MAEntry==1)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
			else if(MAEntry==2)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
		}
		else if(B3Traditional&&Trend==2)
		{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
			if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
		}
		else
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" MA ";
	}

	//+----------------------------------------------------------------+
	//| CCI of 5M,15M,30M,1H for Market Condition and Order Entry      |
	//+----------------------------------------------------------------+
	if(CCIEntry>0)
	{	double cci_01=iCCI(Symbol(),PERIOD_M5,CCIPeriod,PRICE_CLOSE,0);
		double cci_02=iCCI(Symbol(),PERIOD_M15,CCIPeriod,PRICE_CLOSE,0);
		double cci_03=iCCI(Symbol(),PERIOD_M30,CCIPeriod,PRICE_CLOSE,0);
		double cci_04=iCCI(Symbol(),PERIOD_H1,CCIPeriod,PRICE_CLOSE,0);
		double cci_11=iCCI(Symbol(),PERIOD_M5,CCIPeriod,PRICE_CLOSE,1);
		double cci_12=iCCI(Symbol(),PERIOD_M15,CCIPeriod,PRICE_CLOSE,1);
		double cci_13=iCCI(Symbol(),PERIOD_M30,CCIPeriod,PRICE_CLOSE,1);
		double cci_14=iCCI(Symbol(),PERIOD_H1,CCIPeriod,PRICE_CLOSE,1);
	}
	if(CCIEntry>0&&CbT==0&&CpT<2)
	{	if(cci_11>0&&cci_12>0&&cci_13>0&&cci_14>0&&cci_01>0&&cci_02>0&&cci_03>0&&cci_04>0)
		{	if(ForceMarketCond==3)Trend=0;
			if(CCIEntry==1)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
			else if(CCIEntry==2)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
		}
		else if(cci_11<0&&cci_12<0&&cci_13<0&&cci_14<0&&cci_01<0&&cci_02<0&&cci_03<0&&cci_04<0)
		{	if(ForceMarketCond==3)Trend=1;
			if(CCIEntry==1)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
			else if(CCIEntry==2)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
		}
		else if(!UseAnyEntry&&IndEntry>0)
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" CCI ";
	}

	//+----------------------------------------------------------------+
	//| Bollinger Band Indicator for Order Entry                       |
	//+----------------------------------------------------------------+
	if(BollingerEntry>0&&CbT==0&&CpT<2)
	{	double ma=iMA(Symbol(),0,BollPeriod,0,MODE_SMA,PRICE_OPEN,0);
		double stddev=iStdDev(Symbol(),0,BollPeriod,0,MODE_SMA,PRICE_OPEN,0);
		double bup=ma+(BollDeviation*stddev);
		double bdn=ma-(BollDeviation*stddev);
		double bux=bup+BollDistance;
		double bdx=bdn-BollDistance;
		if(ASK<bdx)
		{	if(BollingerEntry==1)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
			else if(BollingerEntry==2)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
		}
		else if(BID>bux)
		{	if(BollingerEntry==1)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
			else if(BollingerEntry==2)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
		}
		else if(!UseAnyEntry&&IndEntry>0)
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" BBands ";
	}

	//+----------------------------------------------------------------+
	//| Stochastic Indicator for Order Entry                           |
	//+----------------------------------------------------------------+
	if(StochEntry>0&&CbT==0&&CpT<2)
	{	int zoneBUY=BuySellStochZone;
		int zoneSELL=100-BuySellStochZone;
		double stoc_0=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MODE_LWMA,1,0,1);
		double stoc_1=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MODE_LWMA,1,1,1);
		if(stoc_0<zoneBUY&&stoc_1<zoneBUY)
		{	if(StochEntry==1)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
			else if(StochEntry==2)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
		}
		else if(stoc_0>zoneSELL&&stoc_1>zoneSELL)
		{	if(StochEntry==1)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
			else if(StochEntry==2)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
		}
		else if(!UseAnyEntry&&IndEntry>0)
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" Stoch ";
	}

	//+----------------------------------------------------------------+
	//| MACD Indicator for Order Entry                                 |
	//+----------------------------------------------------------------+
	if(MACDEntry>0&&CbT==0&&CpT<2)
	{	double MACDm=iMACD(NULL,TF[MACD_TF],FastPeriod,SlowPeriod,SignalPeriod,MACDPrice,0,0);
		double MACDs=iMACD(NULL,TF[MACD_TF],FastPeriod,SlowPeriod,SignalPeriod,MACDPrice,1,0);
		if(MACDm>MACDs)
		{	if(MACDEntry==1)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
			else if(MACDEntry==2)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
		}
		else if(MACDm<MACDs)
		{	if(MACDEntry==1)
			{	if(ForceMarketCond!=0&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))BuyMe=false;
			}
			else if(MACDEntry==2)
			{	if(ForceMarketCond!=1&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=2)))SellMe=false;
			}
		}
		else if(!UseAnyEntry&&IndEntry>0)
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" MACD ";
	}

	//+-----------------------------------------------------------------+  << This must be the last Entry check before
	//| UseAnyEntry Check && Force Market Condition Buy/Sell Entry      |  << the Trade Selection Logic. Add checks for
	//+-----------------------------------------------------------------+  << additional indicators before this block.
	if((!UseAnyEntry&&IndEntry>1&&BuyMe&&SellMe)||FirstRun)
	{	BuyMe=false;
		SellMe=false;
	}
	if(ForceMarketCond<2&&IndEntry==0&&CbT==0&&!FirstRun)
	{	if(ForceMarketCond==0)BuyMe=true;
		if(ForceMarketCond==1)SellMe=true;
		IndicatorUsed=" FMC ";
	}

	//+-----------------------------------------------------------------+
	//| Trade Selection Logic                                           |
	//+-----------------------------------------------------------------+
	OrderLot=LotSize(Lots[StrToInteger(DTS(MathMin(CbT+CbC,MaxTrades-1),0))]*LotMult);
	if(CbT==0&&CpT<2&&!FirstRun)
	{	if(B3Traditional)
		{	if(BuyMe)
			{	if(CpBS==0&&CpSL==0&&((Trend!=2||MAEntry==0)||(Trend==2&&MAEntry==1)))
				{	Entry=g2-MathMod(ASK,g2)+EntryOffset;
					if(Entry>StopLevel)
					{	Ticket=SendOrder(Symbol(),OP_BUYSTOP,OrderLot,Entry,0,Magic,CLR_NONE);
						if(Ticket>0)
						{	if(Debug)Print("Indicator Entry - ("+IndicatorUsed+") BuyStop MC = "+Trend);
							CpBS++;
						}
					}
				}
				if(CpBL==0&&CpSS==0&&((Trend!=2||MAEntry==0)||(Trend==2&&MAEntry==2)))
				{	Entry=MathMod(ASK,g2)+EntryOffset;
					if(Entry>StopLevel)
					{	Ticket=SendOrder(Symbol(),OP_BUYLIMIT,OrderLot,-Entry,0,Magic,CLR_NONE);
						if(Ticket>0)
						{	if(Debug)Print("Indicator Entry - ("+IndicatorUsed+") BuyLimit MC = "+Trend);
							CpBL++;
						}
					}
				}
			}
			if(SellMe)
			{	if(CpSL==0&&CpBS==0&&((Trend!=2||MAEntry==0)||(Trend==2&&MAEntry==2)))
				{	Entry=g2-MathMod(BID,g2)+EntryOffset;
					if(Entry>StopLevel)
					{	Ticket=SendOrder(Symbol(),OP_SELLLIMIT,OrderLot,Entry,0,Magic,CLR_NONE);
						if(Ticket>0&&Debug)Print("Indicator Entry - ("+IndicatorUsed+") SellLimit MC = "+Trend);
					}
				}
				if(CpSS==0&&CpBL==0&&((Trend!=2||MAEntry==0)||(Trend==2&&MAEntry==1)))
				{	Entry=MathMod(BID,g2)+EntryOffset;
					if(Entry>StopLevel)
					{	Ticket=SendOrder(Symbol(),OP_SELLSTOP,OrderLot,-Entry,0,Magic,CLR_NONE);
						if(Ticket>0&&Debug)Print("Indicator Entry - ("+IndicatorUsed+") SellStop MC = "+Trend);
					}
				}
			}
		}
		else
		{	if(BuyMe)
			{	Ticket=SendOrder(Symbol(),OP_BUY,OrderLot,0,slip,Magic,Blue);
				if(Ticket>0&&Debug)Print("Indicator Entry - ("+IndicatorUsed+") Buy");
			}
			else if(SellMe)
			{	Ticket=SendOrder(Symbol(),OP_SELL,OrderLot,0,slip,Magic,displayColorLoss);
				if(Ticket>0&&Debug)Print("Indicator Entry - ("+IndicatorUsed+") Sell");
			}
		}
		if(Ticket>0)return(0);
	}
	else if(TimeCurrent()-EntryDelay>OTbL&&CbT+CbC<MaxTrades&&!FirstRun)
	{	if(UseSmartGrid)
		{	if(RSI[1]!=iRSI(NULL,TF[RSI_TF],RSI_Period,RSI_Price,1))
				for(y=0;y<RSI_Period+RSI_MA_Period;y++)RSI[y]=iRSI(NULL,TF[RSI_TF],RSI_Period,RSI_Price,y);
			else RSI[0]=iRSI(NULL,TF[RSI_TF],RSI_Period,RSI_Price,0);
			RSI_MA=iMAOnArray(RSI,0,RSI_MA_Period,0,RSI_MA_Method,0);
		}
		if(CbB>0)
		{	if(OPbL>ASK)Entry=OPbL-(MathRound((OPbL-ASK)/g2)+1)*g2;
			else Entry=OPbL-g2;
			double OPbN;
			if(UseSmartGrid)
			{	if(ASK<OPbL-g2)
				{	if(RSI[0]>RSI_MA)
					{	Ticket=SendOrder(Symbol(),OP_BUY,OrderLot,0,slip,Magic,Blue);
						if(Ticket>0&&Debug)Print("SmartGrid Buy RSI: "+RSI[0]+" > MA: "+RSI_MA);
					}
					OPbN=0;
				}
				else OPbN=OPbL-g2;
			}
			else if(CpBL==0)
			{	if(ASK-Entry<=StopLevel)Entry=OPbL-(MathFloor((OPbL-ASK+StopLevel)/g2)+1)*g2;
				Ticket=SendOrder(Symbol(),OP_BUYLIMIT,OrderLot,Entry-ASK,0,Magic,SkyBlue);
				if(Ticket>0&&Debug)Print("BuyLimit grid");
			}
			else if(CpBL==1&&Entry-OPpBL>g2/2&&ASK-Entry>StopLevel)
			{	for(y=OrdersTotal();y>=0;y--)
				{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
					if(OrderMagicNumber()!=Magic||OrderSymbol()!=Symbol()||OrderType()!=OP_BUYLIMIT)continue;
					Success=ModifyOrder(Entry,0,SkyBlue);
					if(Success&&Debug)Print("Mod BuyLimit Entry");
				}
			}
		}
		else if(CbS>0)
		{	if(BID>OPbL)Entry=OPbL+(MathRound((-OPbL+BID)/g2)+1)*g2;
			else Entry=OPbL+g2;
			if(UseSmartGrid)
			{	if(BID>OPbL+g2)
				{	if(RSI[0]<RSI_MA)
					{	Ticket=SendOrder(Symbol(),OP_SELL,OrderLot,0,slip,Magic,displayColorLoss);
						if(Ticket>0&&Debug)Print("SmartGrid Sell RSI: "+RSI[0]+" < MA: "+RSI_MA);
					}
					OPbN=0;
				}
				else OPbN=OPbL+g2;
			}
			else if(CpSL==0)
			{	if(Entry-BID<=StopLevel)Entry=OPbL+(MathFloor((-OPbL+BID+StopLevel)/g2)+1)*g2;
				Ticket=SendOrder(Symbol(),OP_SELLLIMIT,OrderLot,Entry-BID,0,Magic,Coral);
				if(Ticket>0&&Debug)Print("SellLimit grid");
			}
			else if(CpSL==1&&OPpSL-Entry>g2/2&&Entry-BID>StopLevel)
			{	for(y=OrdersTotal()-1;y>=0;y--)
				{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
					if(OrderMagicNumber()!=Magic||OrderSymbol()!=Symbol()||OrderType()!=OP_SELLLIMIT)continue;
					Success=ModifyOrder(Entry,0,Coral);
					if(Success&&Debug)Print("Mod SellLimit Entry");
				}
			}
		}
		if(Ticket>0)return(0);
	}

	//+-----------------------------------------------------------------+
	//| Hedge Trades Set-Up and Monitoring                              |
	//+-----------------------------------------------------------------+
	if((UseHedge&&CbT>0)||ChT>0)
	{	int hLevel=CbT+CbC;
		if(HedgeTypeDD)
		{	if(hDDStart==0&&ChT>0)hDDStart=MathMax(HedgeStart,DrawDownPC+hReEntryPC);
			if(hDDStart>HedgeStart&&hDDStart>DrawDownPC+hReEntryPC)hDDStart=DrawDownPC+hReEntryPC;
			if(hActive==2)
			{	hActive=0;
				hDDStart=MathMax(HedgeStart,DrawDownPC+hReEntryPC);
			}
		}
		if(hActive==0)
		{	if(!hThisChart&&((hPosCorr&&CheckCorr()<0.9)||(!hPosCorr&&CheckCorr()>-0.9)))
			{	if(ObjectFind("B3LhCor")==-1)
					CreateLabel("B3LhCor","The correlation with the hedge pair has dropped below 90%.",0,0,190,10,displayColorLoss);
			}
			else ObjDel("B3LhCor");
			if(hLvlStart>hLevel+1||(!HedgeTypeDD&&hLvlStart==0))hLvlStart=MathMax(HedgeStart,hLevel+1);
			if((HedgeTypeDD&&DrawDownPC>hDDStart)||(!HedgeTypeDD&&hLevel>=hLvlStart))
			{	OrderLot=LotSize(LbT*hLotMult);
				if((CbB>0&&!hPosCorr)||(CbS>0&&hPosCorr))
				{	Ticket=SendOrder(HedgeSymbol,OP_BUY,OrderLot,0,slip,hMagic,MidnightBlue);
					if(Ticket>0)
					{	if(hMaxLossPips>0)SLh=hAsk-hMaxLossPips;
						if(Debug)Print("Hedge Buy : Stoploss @ "+DTS(SLh,Digits));
					}
				}
				if((CbB>0&&hPosCorr)||(CbS>0&&!hPosCorr))
				{	Ticket=SendOrder(HedgeSymbol,OP_SELL,OrderLot,0,slip,hMagic,Maroon);
					if(Ticket>0)
					{	if(hMaxLossPips>0)SLh=hBid+hMaxLossPips;
						if(Debug)Print("Hedge Sell : Stoploss @ "+DTS(SLh,Digits));
					}
				}
				if(Ticket>0)
				{	hActive=1;
					if(HedgeTypeDD)hDDStart+=hReEntryPC;
					hLvlStart=hLevel+1;
					return(0);
				}
			}
		}
		else if(hActive==1)
		{	if(HedgeTypeDD&&hDDStart>HedgeStart&&hDDStart<DrawDownPC+hReEntryPC)hDDStart=DrawDownPC+hReEntryPC;
			if(hLvlStart==0)
			{	if(HedgeTypeDD)hLvlStart=hLevel+1;
				else hLvlStart=MathMax(HedgeStart,hLevel+1);
			}
			if(hLevel>=hLvlStart)
			{	OrderLot=LotSize(Lots[CbT+CbC-1]*LotMult*hLotMult);
				if(OrderLot>0&&((CbB>0&&!hPosCorr)||(CbS>0&&hPosCorr)))
				{	Ticket=SendOrder(HedgeSymbol,OP_BUY,OrderLot,0,slip,hMagic,MidnightBlue);
					if(Ticket>0&&Debug)Print("Hedge Buy");
				}
				if(OrderLot>0&&((CbB>0&&hPosCorr)||(CbS>0&&!hPosCorr)))
				{	Ticket=SendOrder(HedgeSymbol,OP_SELL,OrderLot,0,slip,hMagic,Maroon);
					if(Ticket>0&&Debug)Print("Hedge Sell");
				}
				if(Ticket>0)
				{	hLvlStart=hLevel+1;
					return(0);
				}
			}
			y=0;
			if(!FirstRun&&hMaxLossPips>0)
			{	if(ChB>0)
				{	if(hFixedSL)
					{	if(SLh==0)SLh=hBid-hMaxLossPips;
					}
					else
					{	if(SLh==0||(SLh<BEh&&SLh<hBid-hMaxLossPips))SLh=hBid-hMaxLossPips;
						else if(StopTrailAtBE&&hBid-hMaxLossPips>=BEh)SLh=BEh;
						else if(SLh>=BEh&&!StopTrailAtBE)
						{	if(!ReduceTrailStop)SLh=MathMax(SLh,hBid-hMaxLossPips);
							else SLh=MathMax(SLh,hBid-MathMax(StopLevel,hMaxLossPips*(1-(hBid-hMaxLossPips-BEh)/(hMaxLossPips*2))));
						}
					}
					if(hBid<=SLh)y=ExitTrades(H,DarkViolet,"Hedge Stop Loss");
				}
				else if(ChS>0)
				{	if(hFixedSL)
					{	if(SLh==0)SLh=hAsk+hMaxLossPips;
					}
					else
					{	if(SLh==0||(SLh>BEh&&SLh>hAsk+hMaxLossPips))SLh=hAsk+hMaxLossPips;
						else if(StopTrailAtBE&&hAsk+hMaxLossPips<=BEh)SLh=BEh;
						else if(SLh<=BEh&&!StopTrailAtBE)
						{	if(!ReduceTrailStop)SLh=MathMin(SLh,hAsk+hMaxLossPips);
							else SLh=MathMin(SLh,hAsk+MathMax(StopLevel,hMaxLossPips*(1-(BEh-hAsk-hMaxLossPips)/(hMaxLossPips*2))));
						}
					}
					if(hAsk>=SLh)y=ExitTrades(H,DarkViolet,"Hedge Stop Loss");
				}
			}
			if(y==0&&hTakeProfit>0)
			{	if(ChB>0&&hBid>OPhO+hTakeProfit)y=ExitTrades(T,DarkViolet,"Hedge Take Profit reached",ThO);
				if(ChS>0&&hAsk<OPhO-hTakeProfit)y=ExitTrades(T,DarkViolet,"Hedge Take Profit reached",ThO);
			}
			if(y>0)
			{	PhC=FindClosedPL(H);
				if(y==ChT)
				{	if(HedgeTypeDD)hActive=2;
					else hActive=0;
				}
				return(0);
			}
		}
	}

	//+-----------------------------------------------------------------+
	//| Check DD% and send Email                                        |
	//+-----------------------------------------------------------------+
	if((UseEmail||PlaySounds)&&!Testing)
	{	if(EmailCount<2&&Email[EmailCount]>0&&DrawDownPC>Email[EmailCount])
		{	GetLastError();
			if(UseEmail)
			{	SendMail("Blessing EA","Blessing has exceeded a drawdown of "+Email[EmailCount]*100+"% on "+Symbol()+" "+sTF);
				Error=GetLastError();
				if(Error>0)Print("Email DD: "+DTS(DrawDownPC*100,2)+" Error: "+Error+" "+ErrorDescription(Error));
				else if(Debug)Print("DrawDown Email sent on "+Symbol()+" "+sTF+ " DD: "+DTS(DrawDownPC*100,2));
				EmailSent=TimeCurrent();
				EmailCount++;
			}
			if(PlaySounds)PlaySound(AlertSound);
		}
		else if(EmailCount>0&&EmailCount<3&&DrawDownPC<Email[EmailCount]&&TimeCurrent()>EmailSent+EmailHours*3600)EmailCount--;
	}

	//+-----------------------------------------------------------------+
	//| Display Overlay Code                                            |
	//+-----------------------------------------------------------------+
	if((Testing&&Visual)||!Testing)
	{	if(displayOverlay)
		{	color Colour;
			int dDigits;
			ObjSetTxt("B3VTime",TimeToStr(TimeCurrent(),TIME_SECONDS));
			DrawLabel("B3VSTAm",InitialAccountMultiPortion,167,2,displayColorLoss);
			if(UseHolidayShutdown)
			{	ObjSetTxt("B3VHolF",TimeToStr(HolFirst,TIME_DATE));
				ObjSetTxt("B3VHolT",TimeToStr(HolLast,TIME_DATE));
			}
			DrawLabel("B3VPBal",PortionBalance,167);
			if(DrawDownPC>0.4)Colour=displayColorLoss;
			else if(DrawDownPC>0.3)Colour=Orange;
			else if(DrawDownPC>0.2)Colour=Yellow;
			else if(DrawDownPC>0.1)Colour=displayColorProfit;
			else Colour=displayColor;
			DrawLabel("B3VDrDn",DrawDownPC*100,315,2,Colour);
			if(UseHedge&&HedgeTypeDD)ObjSetTxt("B3VhDDm",DTS(hDDStart*100,2));
			else if(UseHedge&&!HedgeTypeDD)
			{	DrawLabel("B3VhLvl",CbT+CbC,318,0);
				ObjSetTxt("B3VhLvT",DTS(hLvlStart,0));
			}
			ObjSetTxt("B3VSLot",DTS(Lot*LotMult,2));
			if(ProfitPot>=0)DrawLabel("B3VPPot",ProfitPot,190);
			else
			{	ObjSetTxt("B3VPPot",DTS(ProfitPot,2),0,displayColorLoss);
				dDigits=Digit[ArrayBsearch(Digit,-ProfitPot,WHOLE_ARRAY,0,MODE_ASCEND),1];
				ObjSet("B3VPPot",186-dDigits*7);
			}
			if(UseEarlyExit&&EEpc<1)
			{	if(ObjectFind("B3SEEPr")==-1)CreateLabel("B3SEEPr","/",0,0,220,12);
				if(ObjectFind("B3VEEPr")==-1)CreateLabel("B3VEEPr","",0,0,229,12);
				ObjSetTxt("B3VEEPr",DTS(PbTarget*PipValue*MathAbs(LbB-LbS),2));
			}
			else
			{	ObjDel("B3SEEPr");
				ObjDel("B3VEEPr");
			}
			if(SLb>0)DrawLabel("B3VPrSL",SLb,190,Digits);
			else if(bSL>0)DrawLabel("B3VPrSL",bSL,190,Digits);
			else if(bTS>0)DrawLabel("B3VPrSL",bTS,190,Digits);
			else DrawLabel("B3VPrSL",0,190,2);
			if(Pb>=0)
			{	DrawLabel("B3VPnPL",Pb,190,2,displayColorProfit);
				ObjSetTxt("B3VPPip",DTS(PbPips,1),0,displayColorProfit);
				ObjSet("B3VPPip",229);
			}
			else
			{	ObjSetTxt("B3VPnPL",DTS(Pb,2),0,displayColorLoss);
				dDigits=Digit[ArrayBsearch(Digit,-Pb,WHOLE_ARRAY,0,MODE_ASCEND),1];
				ObjSet("B3VPnPL",186-dDigits*7);
				ObjSetTxt("B3VPPip",DTS(PbPips,1),0,displayColorLoss);
				ObjSet("B3VPPip",225);
			}
			if(PbMax>=0)DrawLabel("B3VPLMx",PbMax,190,2,displayColorProfit);
			else
			{	ObjSetTxt("B3VPLMx",DTS(PbMax,2),0,displayColorLoss);
				dDigits=Digit[ArrayBsearch(Digit,-PbMax,WHOLE_ARRAY,0,MODE_ASCEND),1];
				ObjSet("B3VPLMx",186-dDigits*7);
			}
			if(PbMin<0)ObjSet("B3VPLMn",225);
			else ObjSet("B3VPLMn",229);
			ObjSetTxt("B3VPLMn",DTS(PbMin,2),0,displayColorLoss);
			if(CbT+CbC<BreakEvenTrade&&CbT+CbC<MaxTrades)Colour=displayColor;
			else if(CbT+CbC<MaxTrades)Colour=Orange;
			else Colour=displayColorLoss;
			if(CbB>0)
			{	ObjSetTxt("B3LType","Buy:");
				DrawLabel("B3VOpen",CbB,207,0,Colour);
			}
			else if(CbS>0)
			{	ObjSetTxt("B3LType","Sell:");
				DrawLabel("B3VOpen",CbS,207,0,Colour);
			}
			else
			{	ObjSetTxt("B3LType","");
				ObjSetTxt("B3VOpen",DTS(0,0),0,Colour);
				ObjSet("B3VOpen",207);
			}
			ObjSetTxt("B3VLots",DTS(LbT,2));
			ObjSetTxt("B3VMove",DTS(Moves,0));
			DrawLabel("B3VMxDD",MaxDD,107);
			DrawLabel("B3VDDPC",MaxDDPer,229);
			if(Trend==0)
			{	ObjSetTxt("B3LTrnd","Trend is UP",10,displayColorProfit);
				if(ObjectFind("B3ATrnd")==-1)CreateLabel("B3ATrnd","",0,0,160,20,displayColorProfit,"Wingdings");
				ObjectSetText("B3ATrnd","é",displayFontSize+9,"Wingdings",displayColorProfit);
				ObjSet("B3ATrnd",160);
				ObjectSet("B3ATrnd",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
				if(StringLen(ATrend)>0)
				{	if(ObjectFind("B3AATrn")==-1)CreateLabel("B3AATrn","",0,0,200,20,displayColorProfit,"Wingdings");
					if(ATrend=="D")
					{	ObjectSetText("B3AATrn","ê",displayFontSize+9,"Wingdings",displayColorLoss);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20+5);
					}
					else if(ATrend=="R")
					{	ObjSetTxt("B3AATrn","R",10,Orange);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
					}
				}
				else ObjDel("B3AATrn");
			}
			else if(Trend==1)
			{	ObjSetTxt("B3LTrnd","Trend is DOWN",10,displayColorLoss);
				if(ObjectFind("B3ATrnd")==-1)CreateLabel("B3ATrnd","",0,0,210,20,displayColorLoss,"WingDings");
				ObjectSetText("B3ATrnd","ê",displayFontSize+9,"Wingdings",displayColorLoss);
				ObjSet("B3ATrnd",210);
				ObjectSet("B3ATrnd",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20+5);
				if(StringLen(ATrend)>0)
				{	if(ObjectFind("B3AATrn")==-1)CreateLabel("B3AATrn","",0,0,250,20,displayColorProfit,"Wingdings");
					if(ATrend=="U")
					{	ObjectSetText("B3AATrn","é",displayFontSize+9,"Wingdings",displayColorProfit);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
					}
					else if(ATrend=="R")
					{	ObjSetTxt("B3AATrn","R",10,Orange);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
					}
				}
				else ObjDel("B3AATrn");
			}
			else if(Trend==2)
			{	ObjSetTxt("B3LTrnd","Trend is Ranging",10,Orange);
				ObjDel("B3ATrnd");
				if(StringLen(ATrend)>0)
				{	if(ObjectFind("B3AATrn")==-1)CreateLabel("B3AATrn","",0,0,220,20,displayColorProfit,"Wingdings");
					if(ATrend=="U")
					{	ObjectSetText("B3AATrn","é",displayFontSize+9,"Wingdings",displayColorProfit);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
					}
					else if(ATrend=="D")
					{	ObjectSetText("B3AATrn","ê",displayFontSize+8,"Wingdings",displayColorLoss);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20+5);
					}
				}
				else ObjDel("B3AATrn");
			}
			if(PaC!=0)
			{	if(ObjectFind("B3LClPL")==-1)CreateLabel("B3LClPL","Closed P/L",0,0,312,11);
				if(ObjectFind("B3VClPL")==-1)CreateLabel("B3VClPL","",0,0,327,12);
				if(PaC>=0)DrawLabel("B3VClPL",PaC,327,2,displayColorProfit);
				else
				{	ObjSetTxt("B3VClPL",DTS(PaC,2),0,displayColorLoss);
					dDigits=Digit[ArrayBsearch(Digit,-PaC,WHOLE_ARRAY,0,MODE_ASCEND),1];
					ObjSet("B3VClPL",323-dDigits*7);
				}
			}
			else
			{	ObjDel("B3LClPL");
				ObjDel("B3VClPL");
			}
			if(hActive==1)
			{	if(ObjectFind("B3LHdge")==-1)CreateLabel("B3LHdge","Hedge",0,0,323,13);
				if(ObjectFind("B3VhPro")==-1)CreateLabel("B3VhPro","",0,0,312,14);
				if(Ph>=0)DrawLabel("B3VhPro",Ph,312,2,displayColorProfit);
				else
				{	ObjSetTxt("B3VhPro",DTS(Ph,2),0,displayColorLoss);
					dDigits=Digit[ArrayBsearch(Digit,-Ph,WHOLE_ARRAY,0,MODE_ASCEND),1];
					ObjSet("B3VhPro",308-dDigits*7);
				}
				if(ObjectFind("B3VhPMx")==-1)CreateLabel("B3VhPMx","",0,0,312,15);
				if(PhMax>=0)DrawLabel("B3VhPMx",PhMax,312,2,displayColorProfit);
				else
				{	ObjSetTxt("B3VhPMx",DTS(PhMax,2),0,displayColorLoss);
					dDigits=Digit[ArrayBsearch(Digit,-PhMax,WHOLE_ARRAY,0,MODE_ASCEND),1];
					ObjSet("B3VhPMx",308-dDigits*7);
				}
				if(ObjectFind("B3ShPro")==-1)CreateLabel("B3ShPro","/",0,0,342,15);
				if(ObjectFind("B3VhPMn")==-1)CreateLabel("B3VhPMn","",0,0,351,15,displayColorLoss);
				if(PhMin<0)ObjSet("B3VhPMn",347);
				else ObjSet("B3VhPMn",351);
				ObjSetTxt("B3VhPMn",DTS(PhMin,2),0,displayColorLoss);
				if(ObjectFind("B3LhTyp")==-1)CreateLabel("B3LhTyp","",0,0,292,16);
				if(ObjectFind("B3VhOpn")==-1)CreateLabel("B3VhOpn","",0,0,329,16);
				if(ChB>0)
				{	ObjSetTxt("B3LhTyp","Buy:");
					DrawLabel("B3VhOpn",ChB,329,0);
				}
				else if(ChS>0)
				{	ObjSetTxt("B3LhTyp","Sell:");
					DrawLabel("B3VhOpn",ChS,329,0);
				}
				else
				{	ObjSetTxt("B3LhTyp","");
					ObjSetTxt("B3VhOpn",DTS(0,0));
					ObjSet("B3VhOpn",329);
				}
				if(ObjectFind("B3ShOpn")==-1)CreateLabel("B3ShOpn","/",0,0,342,16);
				if(ObjectFind("B3VhLot")==-1)CreateLabel("B3VhLot","",0,0,351,16);
				ObjSetTxt("B3VhLot",DTS(LhT,2));
			}
			else
			{	ObjDel("B3LHdge");
				ObjDel("B3VhPro");
				ObjDel("B3VhPMx");
				ObjDel("B3ShPro");
				ObjDel("B3VhPMn");
				ObjDel("B3LhTyp");
				ObjDel("B3VhOpn");
				ObjDel("B3ShOpn");
				ObjDel("B3VhLot");
			}
		}
		if(displayLines)
		{	if(BEb>0)
			{	if(ObjectFind("B3LBELn")==-1)CreateLine("B3LBELn",DodgerBlue,1,0);
				ObjectMove("B3LBELn",0,Time[1],BEb);
			}
			else ObjDel("B3LBELn");
			if(TPa>0)
			{	if(ObjectFind("B3LTPLn")==-1)CreateLine("B3LTPLn",Gold,1,0);
				ObjectMove("B3LTPLn",0,Time[1],TPa);
			}
			else if(TPb>0&&nLots!=0)
			{	if(ObjectFind("B3LTPLn")==-1)CreateLine("B3LTPLn",Gold,1,0);
				ObjectMove("B3LTPLn",0,Time[1],TPb);
			}
			else ObjDel("B3LTPLn");
			if(OPbN>0)
			{	if(ObjectFind("B3LOPLn")==-1)CreateLine("B3LOPLn",Red,1,4);
				ObjectMove("B3LOPLn",0,Time[1],OPbN);
			}
			else ObjDel("B3LOPLn");
			if(bSL>0)
			{	if(ObjectFind("B3LSLbT")==-1)CreateLine("B3LSLbT",Red,1,3);
				ObjectMove("B3LSLbT",0,Time[1],bSL);
			}
			else ObjDel("B3LSLbT");
			if(bTS>0)
			{	if(ObjectFind("B3LTSbT")==-1)CreateLine("B3LTSbT",Gold,1,3);
				ObjectMove("B3LTSbT",0,Time[1],bTS);
			}
			else ObjDel("B3LTSbT");
			if(hActive==1&&BEa>0)
			{	if(ObjectFind("B3LNBEL")==-1)CreateLine("B3LNBEL",Crimson,1,0);
				ObjectMove("B3LNBEL",0,Time[1],BEa);
			}
			else ObjDel("B3LNBEL");
			if(TPbMP>0)
			{	if(ObjectFind("B3LMPLn")==-1)CreateLine("B3LMPLn",Gold,1,4);
				ObjectMove("B3LMPLn",0,Time[1],TPbMP);
			}
			else ObjDel("B3LMPLn");
			if(SLb>0)
			{	if(ObjectFind("B3LTSLn")==-1)CreateLine("B3LTSLn",Gold,1,2);
				ObjectMove("B3LTSLn",0,Time[1],SLb);
			}
			else ObjDel("B3LTSLn");
			if(hThisChart&&BEh>0)
			{	if(ObjectFind("B3LhBEL")==-1)CreateLine("B3LhBEL",SlateBlue,1,0);
				ObjectMove("B3LhBEL",0,Time[1],BEh);
			}
			else ObjDel("B3LhBEL");
			if(hThisChart&&SLh>0)
			{	if(ObjectFind("B3LhSLL")==-1)CreateLine("B3LhSLL",SlateBlue,1,3);
				ObjectMove("B3LhSLL",0,Time[1],SLh);
			}
			else ObjDel("B3LhSLL");
		}
		else
		{	ObjDel("B3LBELn");
			ObjDel("B3LTPLn");
			ObjDel("B3LOPLn");
			ObjDel("B3LSLbT");
			ObjDel("B3LTSbT");
			ObjDel("B3LNBEL");
			ObjDel("B3LMPLn");
			ObjDel("B3LTSLn");
			ObjDel("B3LhBEL");
			ObjDel("B3LhSLL");
		}
		if(CCIEntry&&displayCCI)
		{	if(cci_01>0&&cci_11>0)ObjectSetText("B3VCm05","Ù",displayFontSize+6,"Wingdings",displayColorProfit);
			else if(cci_01<0&&cci_11<0)ObjectSetText("B3VCm05","Ú",displayFontSize+6,"Wingdings",displayColorLoss);
			else ObjectSetText("B3VCm05","Ø",displayFontSize+6,"Wingdings",Orange);
			if(cci_02>0&&cci_12>0)ObjectSetText("B3VCm15","Ù",displayFontSize+6,"Wingdings",displayColorProfit);
			else if(cci_02<0&&cci_12<0)ObjectSetText("B3VCm15","Ú",displayFontSize+6,"Wingdings",displayColorLoss);
			else ObjectSetText("B3VCm15","Ø",displayFontSize+6,"Wingdings",Orange);
			if(cci_03>0&&cci_13>0)ObjectSetText("B3VCm30","Ù",displayFontSize+6,"Wingdings",displayColorProfit);
			else if(cci_03<0&&cci_13<0)ObjectSetText("B3VCm30","Ú",displayFontSize+6,"Wingdings",displayColorLoss);
			else ObjectSetText("B3VCm30","Ø",displayFontSize+6,"Wingdings",Orange);
			if(cci_04>0&&cci_14>0)ObjectSetText("B3VCm60","Ù",displayFontSize+6,"Wingdings",displayColorProfit);
			else if(cci_04<0&&cci_14<0)ObjectSetText("B3VCm60","Ú",displayFontSize+6,"Wingdings",displayColorLoss);
			else ObjectSetText("B3VCm60","Ø",displayFontSize+6,"Wingdings",Orange);
		}
		if(Debug)
		{	string dSpace;
			for(y=0;y<=175;y++)dSpace=dSpace+" ";
			string dMess="\n\n"+dSpace+"Ticket   Magic     Type Lots OpenPrice  Costs  Profit  Potential";
			for(y=0;y<OrdersTotal();y++)
			{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
				if(OrderMagicNumber()!=Magic&&OrderMagicNumber()!=hMagic)continue;
				dMess=(dMess+"\n"+dSpace+" "+OrderTicket()+"  "+DTS(OrderMagicNumber(),0)+"   "+OrderType());
				dMess=(dMess+"   "+DTS(OrderLots(),LotDecimal)+"  "+DTS(OrderOpenPrice(),Digits));
				dMess=(dMess+"     "+DTS(OrderSwap()+OrderCommission(),2));
				dMess=(dMess+"    "+DTS(OrderProfit()+OrderSwap()+OrderCommission(),2));
				if(OrderMagicNumber()!=Magic)continue;
				if(OrderType()==OP_BUY)dMess=(dMess+"      "+DTS(OrderLots()*(TPb-OrderOpenPrice())*PipVal2+OrderSwap()+OrderCommission(),2));
				if(OrderType()==OP_SELL)dMess=(dMess+"      "+DTS(OrderLots()*(OrderOpenPrice()-TPb)*PipVal2+OrderSwap()+OrderCommission(),2));
			}
			if(!dLabels)
			{	dLabels=true;
				CreateLabel("B3LPipV","Pip Value",0,2,0,0);
				CreateLabel("B3VPipV","",0,2,100,0);
				CreateLabel("B3LDigi","Digits Value",0,2,0,1);
				CreateLabel("B3VDigi","",0,2,100,1);
				ObjSetTxt("B3VDigi",DTS(Digits,0));
				CreateLabel("B3LPoin","Point Value",0,2,0,2);
				CreateLabel("B3VPoin","",0,2,100,2);
				ObjSetTxt("B3VPoin",DTS(Point,Digits));
				CreateLabel("B3LSprd","Spread Value",0,2,0,3);
				CreateLabel("B3VSprd","",0,2,100,3);
				CreateLabel("B3LBid","Bid Value",0,2,0,4);
				CreateLabel("B3VBid","",0,2,100,4);
				CreateLabel("B3LAsk","Ask Value",0,2,0,5);
				CreateLabel("B3VAsk","",0,2,100,5);
				CreateLabel("B3LLotP","Lot Step",0,2,200,0);
				CreateLabel("B3VLotP","",0,2,300,0);
				ObjSetTxt("B3VLotP",DTS(MarketInfo(Symbol(),MODE_LOTSTEP),LotDecimal));
				CreateLabel("B3LLotX","Lot Max",0,2,200,1);
				CreateLabel("B3VLotX","",0,2,300,1);
				ObjSetTxt("B3VLotX",DTS(MarketInfo(Symbol(),MODE_MAXLOT),0));
				CreateLabel("B3LLotN","Lot Min",0,2,200,2);
				CreateLabel("B3VLotN","",0,2,300,2);
				ObjSetTxt("B3VLotN",DTS(MarketInfo(Symbol(),MODE_MINLOT),LotDecimal));
				CreateLabel("B3LLotD","Lot Decimal",0,2,200,3);
				CreateLabel("B3VLotD","",0,2,300,3);
				ObjSetTxt("B3VLotD",DTS(LotDecimal,0));
				CreateLabel("B3LAccT","Account Type",0,2,200,4);
				CreateLabel("B3VAccT","",0,2,300,4);
				ObjSetTxt("B3VAccT",DTS(AccountType,0));
				CreateLabel("B3LPnts","Pip",0,2,200,5);
				CreateLabel("B3VPnts","",0,2,300,5);
				ObjSetTxt("B3VPnts",DTS(Pip,Digits));
				CreateLabel("B3LTicV","Tick Value",0,2,400,0);
				CreateLabel("B3VTicV","",0,2,500,0);
				CreateLabel("B3LTicS","Tick Size",0,2,400,1);
				CreateLabel("B3VTicS","",0,2,500,1);
				ObjSetTxt("B3VTicS",DTS(MarketInfo(Symbol(),MODE_TICKSIZE),Digits));
				CreateLabel("B3LLev","Leverage",0,2,400,2);
				CreateLabel("B3VLev","",0,2,500,2);
				ObjSetTxt("B3VLev",DTS(AccountLeverage(),0)+":1");
				CreateLabel("B3LSGTF","SmartGrid",0,2,400,3);
				if(UseSmartGrid)CreateLabel("B3VSGTF","True",0,2,500,3);
				else CreateLabel("B3VSGTF","False",0,2,500,3);
				CreateLabel("B3LCOTF","Close Oldest",0,2,400,4);
				if(UseCloseOldest)CreateLabel("B3VCOTF","True",0,2,500,4);
				else CreateLabel("B3VCOTF","False",0,2,500,4);
				CreateLabel("B3LUHTF","Hedge",0,2,400,5);
				if(UseHedge&&HedgeTypeDD)CreateLabel("B3VUHTF","DrawDown",0,2,500,5);
				else if(UseHedge&&!HedgeTypeDD)CreateLabel("B3VUHTF","Level",0,2,500,5);
				else CreateLabel("B3VUHTF","False",0,2,500,5);
			}
			ObjSetTxt("B3VPipV",DTS(PipValue,2));
			ObjSetTxt("B3VSprd",DTS(ASK-BID,Digits));
			ObjSetTxt("B3VBid",DTS(BID,Digits));
			ObjSetTxt("B3VAsk",DTS(ASK,Digits));
			ObjSetTxt("B3VTicV",DTS(MarketInfo(Symbol(),MODE_TICKVALUE),Digits));
		}
		if(EmergencyWarning)
		{	if(ObjectFind("B3LClos")==-1)CreateLabel("B3LClos","",5,0,0,23,displayColorLoss);
			ObjSetTxt("B3LClos","WARNING: EmergencyCloseAll is set to TRUE",5,displayColorLoss);
		}
		else if(ShutDown)
		{	if(ObjectFind("B3LClos")==-1)CreateLabel("B3LClos","",5,0,0,23,displayColorLoss);
			ObjSetTxt("B3LClos","Blessing will stop trading when this basket closes.",5,displayColorLoss);
		}
		else if(HolShutDown!=1)ObjDel("B3LClos");
	}
	WindowRedraw();
	FirstRun=false;
	Comment(CS,dMess);
	return(0);
}

//+-----------------------------------------------------------------+
//| Check Lot Size Funtion                                          |
//+-----------------------------------------------------------------+
double LotSize(double NewLot)
{	NewLot=ND(NewLot,LotDecimal);
	NewLot=MathMin(NewLot,MarketInfo(Symbol(),MODE_MAXLOT));
	NewLot=MathMax(NewLot,MinLotSize);
	return(NewLot);
}

//+-----------------------------------------------------------------+
//| Open Order Funtion                                              |
//+-----------------------------------------------------------------+
int SendOrder(string OSymbol,int OCmd,double OLot,double OPrice,double OSlip,int OMagic,color OColor=CLR_NONE)
{	if(FirstRun)return(-1);
	int Ticket;
	int retryTimes=5,i=0;
	int OType=MathMod(OCmd,2);
	double OrderPrice;
	if(AccountFreeMarginCheck(OSymbol,OType,OLot)<=0)return(-1);
	if(MaxSpread>0&&MarketInfo(OSymbol,MODE_SPREAD)*Point/Pip>MaxSpread)return(-1);
	while(i<5)
	{	i+=1;
		while(IsTradeContextBusy())Sleep(100);
		if(IsStopped())return(-1);
		if(OType==0)OrderPrice=ND(MarketInfo(OSymbol,MODE_ASK)+OPrice,MarketInfo(OSymbol,MODE_DIGITS));
		else OrderPrice=ND(MarketInfo(OSymbol,MODE_BID)+OPrice,MarketInfo(OSymbol,MODE_DIGITS));
		Ticket=OrderSend(OSymbol,OCmd,OLot,OrderPrice,OSlip,0,0,TradeComment,OMagic,0,OColor);
		if(Ticket<0)
		{	Error=GetLastError();
			if(Error!=0)Print("Error opening order: "+Error+" "+ErrorDescription(Error)
				+" Symbol: "+OSymbol
				+" TradeOP: "+OCmd
				+" OType: "+OType
				+" Ask: "+DTS(MarketInfo(OSymbol,MODE_ASK),Digits)
				+" Bid: "+DTS(MarketInfo(OSymbol,MODE_BID),Digits)
				+" OPrice: "+DTS(OPrice,Digits)
				+" Price: "+DTS(OrderPrice,Digits)
				+" Lots: "+DTS(OLot,2)
				);
			switch(Error)
			{	case ERR_TRADE_DISABLED:
					AllowTrading=false;
					Print("Your broker has not allowed EAs on this account");
					i=retryTimes;
					break;
				case ERR_OFF_QUOTES:
				case ERR_INVALID_PRICE:
					Sleep(5000);
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY:
					i++;
					break;
				case 149://ERR_TRADE_HEDGE_PROHIBITED:
					UseHedge=false;
					if(Debug)Print("Hedge trades are not allowed on this pair");
					i=retryTimes;
					break;
				default:
					i=retryTimes;
			}
		}
		else
		{	if(PlaySounds)PlaySound(AlertSound);
			break;
		}
	}
	return(Ticket);
}

//+-----------------------------------------------------------------+
//| Modify Order Function                                           |
//+-----------------------------------------------------------------+
bool ModifyOrder(double OrderOP,double OrderSL,color Color=CLR_NONE)
{	bool Success=false;
	int retryTimes=5,i=0;
	while(i<5&&!Success)
	{	i++;
		while(IsTradeContextBusy())Sleep(100);
		if(IsStopped())return(-1);
		Success=OrderModify(OrderTicket(),OrderOP,OrderSL,0,0,Color);
		if(!Success)
		{	Error=GetLastError();
			if(Error>1)
			{	Print(" Error Modifying Order:",OrderTicket(),", ",Error," :" +ErrorDescription(Error),", Ask:",Ask,
					", Bid:",Bid," OrderPrice: ",OrderOP," StopLevel: ",StopLevel,", SL: ",OrderSL,", OSL: ",OrderStopLoss());
				switch(Error)
				{	case ERR_TRADE_MODIFY_DENIED:
						Sleep(10000);
					case ERR_OFF_QUOTES:
					case ERR_INVALID_PRICE:
						Sleep(5000);
					case ERR_PRICE_CHANGED:
					case ERR_REQUOTE:
						RefreshRates();
					case ERR_SERVER_BUSY:
					case ERR_NO_CONNECTION:
					case ERR_BROKER_BUSY:
					case ERR_TRADE_CONTEXT_BUSY:
					case ERR_TRADE_TIMEOUT:
						i+=1;
						break;
					default:
						i=retryTimes;
						break;
				}
			}
			else Success=true;
		}
		else break;
	}
	return(Success);
}

//+-------------------------------------------------------------------------+
//| Exit Trade Function - Type: All Basket Hedge Ticket Pending             |
//+-------------------------------------------------------------------------+
int ExitTrades(int Type,color Color,string Reason,int OTicket=0)
{	static int OTicketNo;
	bool Success;
	int Tries,Closed,CloseCount;
	int CloseTrades[,2];
	double OPrice;
	string s;
	ca=Type;
	if(Type==T)
	{	if(OTicket==0)OTicket=OTicketNo;
		else OTicketNo=OTicket;
	}
	for(y=OrdersTotal()-1;y>=0;y--)
	{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
		if(Type==B&&OrderMagicNumber()!=Magic)continue;
		else if(Type==H&&OrderMagicNumber()!=hMagic)continue;
		else if(Type==A&&OrderMagicNumber()!=Magic&&OrderMagicNumber()!=hMagic)continue;
		else if(Type==T&&OrderTicket()!=OTicket)continue;
		else if(Type==P&&(OrderMagicNumber()!=Magic||OrderType()<=OP_SELL))continue;
		ArrayResize(CloseTrades,CloseCount+1);
		CloseTrades[CloseCount,0]=OrderOpenTime();
		CloseTrades[CloseCount,1]=OrderTicket();
		CloseCount++;
	}
	if(CloseCount>0)
	{	if(!UseFIFO)ArraySort(CloseTrades,WHOLE_ARRAY,0,MODE_DESCEND);
		else if(CloseCount!=ArraySort(CloseTrades))Print("Error sorting CloseTrades Array");
		for(y=0;y<CloseCount;y++)
		{	if(!OrderSelect(CloseTrades[y,1],SELECT_BY_TICKET))continue;
			while(IsTradeContextBusy())Sleep(100);
			if(IsStopped())return(-1);
			if(OrderType()>OP_SELL)Success=OrderDelete(OrderTicket(),Color);
			else
			{	if(OrderType()==OP_BUY)OPrice=ND(MarketInfo(OrderSymbol(),MODE_BID),MarketInfo(OrderSymbol(),MODE_DIGITS));
				else OPrice=ND(MarketInfo(OrderSymbol(),MODE_ASK),MarketInfo(OrderSymbol(),MODE_DIGITS));
				Success=OrderClose(OrderTicket(),OrderLots(),OPrice,slip,Color);
			}
			if(Success)Closed++;
			else
			{	Error=GetLastError();Print("Order ",OrderTicket()," failed to close. Error:",ErrorDescription(Error));
				switch(Error)
				{	case ERR_NO_ERROR:
					case ERR_NO_RESULT:
						Success=true;
						break;
					case ERR_OFF_QUOTES:
					case ERR_INVALID_PRICE:
						Sleep(5000);
					case ERR_PRICE_CHANGED:
					case ERR_REQUOTE:
						RefreshRates();
					case ERR_SERVER_BUSY:
					case ERR_NO_CONNECTION:
					case ERR_BROKER_BUSY:
					case ERR_TRADE_CONTEXT_BUSY:
						Print("Try: "+(Tries+1)+" of 5: Order ",OrderTicket()," failed to close. Error:",ErrorDescription(Error));
						Tries++;
						break;
					case ERR_TRADE_TIMEOUT:
					default:
						Print("Try: "+(Tries+1)+" of 5: Order ",OrderTicket()," failed to close. Fatal Error:",ErrorDescription(Error));
						Tries=5;
						ca=0;
						break;
				}
			}
		}
		if(Closed==CloseCount||Closed==0)ca=0;
	}
	else ca=0;
	if(Closed>0)
	{	if(Closed!=1)s="s";
		Print("Closed "+Closed+" position"+s+" because ",Reason);
		if(PlaySounds)PlaySound(AlertSound);
	}
	return(Closed);
}

//+-----------------------------------------------------------------+
//| Find Hedge Profit                                               |
//+-----------------------------------------------------------------+
double FindClosedPL(int Type)
{	double ClosedProfit;
	if(Type==B&&UseCloseOldest)CbC=0;
	if(OTbF>0)
	{	for(y=OrdersHistoryTotal()-1;y>=0;y--)
		{	if(!OrderSelect(y,SELECT_BY_POS,MODE_HISTORY))continue;
			if(OrderOpenTime()<OTbF)continue;
			if(Type==B&&OrderMagicNumber()==Magic&&OrderType()<=OP_SELL)
			{	ClosedProfit+=OrderProfit()+OrderSwap()+OrderCommission();
				if(UseCloseOldest)CbC++;
			}
			if(Type==H&&OrderMagicNumber()==hMagic)ClosedProfit+=OrderProfit()+OrderSwap()+OrderCommission();
		}
	}
	return(ClosedProfit);
}

//+-----------------------------------------------------------------+
//| Check Correlation                                               |
//+-----------------------------------------------------------------+
double CheckCorr()
{	double BaseDiff,HedgeDiff,BasePow,HedgePow,Mult;
	for(y=CorrPeriod-1;y>=0;y--)
	{	BaseDiff=iClose(Symbol(),1440,y)-iMA(Symbol(),1440,CorrPeriod,0,MODE_SMA,PRICE_CLOSE,y);
		HedgeDiff=iClose(HedgeSymbol,1440,y)-iMA(HedgeSymbol,1440,CorrPeriod,0,MODE_SMA,PRICE_CLOSE,y);
		Mult+=BaseDiff*HedgeDiff;
		BasePow+=MathPow(BaseDiff,2);
		HedgePow+=MathPow(HedgeDiff,2);
	}
	if(BasePow*HedgePow>0)return(Mult/MathSqrt(BasePow*HedgePow));
	else return(0);
}

//+------------------------------------------------------------------+
//|  Save Equity / Balance Statistics                                |
//+------------------------------------------------------------------+
void Stats(bool NewFile,bool IsTick,double Balance,double DrawDown)
{	double Equity=Balance+DrawDown;
	datetime TimeNow=TimeCurrent();
	if(IsTick)
	{	if(Equity<StatLowEquity)StatLowEquity=Equity;
		if(Equity>StatHighEquity)StatHighEquity=Equity;
	}
	else
	{	while(TimeNow>=NextStats)NextStats+=StatsPeriod;
		int StatHandle;
		if(NewFile)
		{	StatHandle=FileOpen(StatFile,FILE_WRITE|FILE_CSV,',');
			Print("Stats "+StatFile+" "+StatHandle);
			FileWrite(StatHandle,"Date","Time","Balance","Equity Low","Equity High",TradeComment);
		}
		else
		{	StatHandle=FileOpen(StatFile,FILE_READ|FILE_WRITE|FILE_CSV,',');
			FileSeek(StatHandle,0,SEEK_END);
		}
		if(StatLowEquity==0)
		{	StatLowEquity=Equity;
			StatHighEquity=Equity;
		}
		FileWrite(StatHandle,TimeToStr(TimeNow,TIME_DATE),TimeToStr(TimeNow,TIME_SECONDS),DTS(Balance,0),DTS(StatLowEquity,0),DTS(StatHighEquity,0));
		FileClose(StatHandle);
		StatLowEquity=Equity;
		StatHighEquity=Equity;
	}
}

//+-----------------------------------------------------------------+
//| Magic Number Generator                                          |
//+-----------------------------------------------------------------+
int GenerateMagicNumber()
{	if(EANumber>99)return(EANumber);
	return(JenkinsHash(EANumber+"_"+Symbol()+"__"+Period()));
}

int JenkinsHash(string Input)
{	int MagicNo;
	for(y=0;y<StringLen(Input);y++)
	{	MagicNo+=StringGetChar(Input,y);
		MagicNo+=(MagicNo<<10);
		MagicNo^=(MagicNo>>6);
	}
	MagicNo+=(MagicNo<<3);
	MagicNo^=(MagicNo>>11);
	MagicNo+=(MagicNo<<15);
	MagicNo=MathAbs(MagicNo);
	return(MagicNo);
}

//+-----------------------------------------------------------------+
//| Normalize Double                                                |
//+-----------------------------------------------------------------+
double ND(double Value,int Precision){return(NormalizeDouble(Value,Precision));}

//+-----------------------------------------------------------------+
//| Double To String                                                |
//+-----------------------------------------------------------------+
string DTS(double Value,int Precision){return(DoubleToStr(Value,Precision));}

//+-----------------------------------------------------------------+
//| Create Label Function (OBJ_LABEL ONLY)                          |
//+-----------------------------------------------------------------+
void CreateLabel(string Name,string Text,int FontSize,int Corner,int XOffset,double YLine,color Colour=CLR_NONE,string Font="")
{	int XDistance,YDistance;
	if(Font=="")Font=displayFont;
	FontSize+=displayFontSize;
	YDistance=displayYcord+displaySpacing*YLine;
	if(Corner==0)XDistance=displayXcord+(XOffset*displayFontSize/9*displayRatio);
	else if(Corner==1)XDistance=displayCCIxCord+XOffset*displayRatio;
	else if(Corner==2)XDistance=displayXcord+(XOffset*displayFontSize/9*displayRatio);
	else if(Corner==3)
	{	XDistance=XOffset*displayRatio;
		YDistance=YLine;
	}
	else if(Corner==5)
	{	XDistance=XOffset*displayRatio;
		YDistance=14*YLine;
		Corner=1;
	}
	if(Colour==CLR_NONE)Colour=displayColor;
	ObjectCreate(Name,OBJ_LABEL,0,0,0);
	ObjectSetText(Name,Text,FontSize,Font,Colour);
	ObjectSet(Name,OBJPROP_CORNER,Corner);
	ObjectSet(Name,OBJPROP_XDISTANCE,XDistance);
	ObjectSet(Name,OBJPROP_YDISTANCE,YDistance);
}

//+-----------------------------------------------------------------+
//| Create Line Function (OBJ_HLINE ONLY)                           |
//+-----------------------------------------------------------------+
void CreateLine(string Name,color Colour,int Width,int Style)
{	ObjectCreate(Name,OBJ_HLINE,0,0,0);
	ObjectSet(Name,OBJPROP_COLOR,Colour);
	ObjectSet(Name,OBJPROP_WIDTH,Width);
	ObjectSet(Name,OBJPROP_STYLE,Style);
}

//+------------------------------------------------------------------+
//| Draw Label Function (OBJ_LABEL ONLY)                             |
//+------------------------------------------------------------------+
void DrawLabel(string Name,double Value,int XOffset,int Decimal=2,color Colour=CLR_NONE)
{	int dDigits;
	dDigits=Digit[ArrayBsearch(Digit,Value,WHOLE_ARRAY,0,MODE_ASCEND),1];
	ObjectSet(Name,OBJPROP_XDISTANCE,displayXcord+(XOffset-7*dDigits)*displayFontSize/9*displayRatio);
	ObjSetTxt(Name,DTS(Value,Decimal),0,Colour);
}

//+-----------------------------------------------------------------+
//| Object Set Function                                             |
//+-----------------------------------------------------------------+
void ObjSet(string Name,int XCoord){ObjectSet(Name,OBJPROP_XDISTANCE,displayXcord+XCoord*displayFontSize/9*displayRatio);}

//+-----------------------------------------------------------------+
//| Object Set Text Function                                        |
//+-----------------------------------------------------------------+
void ObjSetTxt(string Name,string Text,int FontSize=0,color Colour=CLR_NONE,string Font="")
{	FontSize+=displayFontSize;
	if(Font=="")Font=displayFont;
	if(Colour==CLR_NONE)Colour=displayColor;
	ObjectSetText(Name,Text,FontSize,Font,Colour);
}

//+------------------------------------------------------------------+
//| Delete Overlay Label Function                                    |
//+------------------------------------------------------------------+
void LabelDelete(){for(y=ObjectsTotal();y>=0;y--){if(StringSubstr(ObjectName(y),0,2)=="B3")ObjectDelete(ObjectName(y));}}

//+------------------------------------------------------------------+
//| Delete Object Function                                           |
//+------------------------------------------------------------------+
void ObjDel(string Name){if(ObjectFind(Name)!=-1)ObjectDelete(Name);}

//+-----------------------------------------------------------------+
//| Create Object List Function                                     |
//+-----------------------------------------------------------------+
void LabelCreate()
{	if(displayOverlay&&((Testing&&Visual)||!Testing))
	{	int dDigits;
		string ObjText;
		color ObjClr;
		CreateLabel("B3LMNum","Magic: ",8-displayFontSize,5,59,1,displayColorFGnd,"Tahoma");
		CreateLabel("B3VMNum",DTS(Magic,0),8-displayFontSize,5,5,1,displayColorFGnd,"Tahoma");
		CreateLabel("B3LComm","Trade Comment: "+TradeComment,8-displayFontSize,5,5,1.8,displayColorFGnd,"Tahoma");
		if(displayLogo)
		{	CreateLabel("B3LLogo","Q",27,3,10,10,Crimson,"Wingdings");
			CreateLabel("B3LCopy","© "+DTS(Year(),0)+", J Talon LLC/FiFtHeLeMeNt",10-displayFontSize,3,5,3,Silver,"Arial");
		}
		CreateLabel("B3LTime","Broker Time is:",0,0,0,0);
		CreateLabel("B3VTime","",0,0,125,0);
		CreateLabel("B3Line1","=========================",0,0,0,1);
		CreateLabel("B3LEPPC","Equity Protection % Set:",0,0,0,2);
		dDigits=Digit[ArrayBsearch(Digit,MaxDDPercent,WHOLE_ARRAY,0,MODE_ASCEND),1];
		CreateLabel("B3VEPPC",DTS(MaxDDPercent,2),0,0,167-7*dDigits,2);
		CreateLabel("B3PEPPC","%",0,0,193,2);
		CreateLabel("B3LSTPC","Stop Trade % Set:",0,0,0,3);
		dDigits=Digit[ArrayBsearch(Digit,StopTradePercent*100,WHOLE_ARRAY,0,MODE_ASCEND),1];
		CreateLabel("B3VSTPC",DTS(StopTradePercent*100,2),0,0,167-7*dDigits,3);
		CreateLabel("B3PSTPC","%",0,0,193,3);
		CreateLabel("B3LSTAm","Stop Trade Amount:",0,0,0,4);
		CreateLabel("B3VSTAm","",0,0,167,4,displayColorLoss);
		CreateLabel("B3LAPPC","Account Portion:",0,0,0,5);
		dDigits=Digit[ArrayBsearch(Digit,PortionPC*100,WHOLE_ARRAY,0,MODE_ASCEND),1];
		CreateLabel("B3VAPPC",DTS(PortionPC*100,2),0,0,167-7*dDigits,5);
		CreateLabel("B3PAPPC","%",0,0,193,5);
		CreateLabel("B3LPBal","Portion Balance:",0,0,0,6);
		CreateLabel("B3VPBal","",0,0,167,6);
		CreateLabel("B3LAPCR","Account % Risked:",0,0,228,6);
		CreateLabel("B3VAPCR",DTS(MaxDDPercent*PortionPC,2),0,0,347,6);
		CreateLabel("B3PAPCR","%",0,0,380,6);
		if(UseMM)
		{	ObjText="Money Management is On";
			ObjClr=displayColorProfit;
		}
		else
		{	ObjText="Money Management is Off";
			ObjClr=displayColorLoss;
		}
		CreateLabel("B3LMMOO",ObjText,0,0,0,7,ObjClr);
		if(UsePowerOutSL)
		{	ObjText="Power Off Stop Loss is On";
			ObjClr=displayColorProfit;
		}
		else
		{	ObjText="Power Off Stop Loss is Off";
			ObjClr=displayColorLoss;
		}
		CreateLabel("B3LPOSL",ObjText,0,0,0,8,ObjClr);
		CreateLabel("B3LDrDn","Draw Down %:",0,0,228,8);
		CreateLabel("B3VDrDn","",0,0,315,8);
		if(UseHedge)
		{	if(HedgeTypeDD)
			{	CreateLabel("B3LhDDn","Hedge",0,0,190,8);
				CreateLabel("B3ShDDn","/",0,0,342,8);
				CreateLabel("B3VhDDm","",0,0,347,8);
			}
			else
			{	CreateLabel("B3LhLvl","Hedge Level:",0,0,228,9);
				CreateLabel("B3VhLvl","",0,0,318,9);
				CreateLabel("B3ShLvl","/",0,0,328,9);
				CreateLabel("B3VhLvT","",0,0,333,9);
			}
		}
		CreateLabel("B3Line2","======================",0,0,0,9);
		CreateLabel("B3LSLot","Starting Lot Size:",0,0,0,10);
		CreateLabel("B3VSLot","",0,0,130,10);
		if(MaximizeProfit)
		{	ObjText="Profit Maximizer is On";
			ObjClr=displayColorProfit;
		}
		else
		{	ObjText="Profit Maximizer is Off";
			ObjClr=displayColorLoss;
		}
		CreateLabel("B3LPrMx",ObjText,0,0,0,11,ObjClr);
		CreateLabel("B3LBask","Basket",0,0,200,11);
		CreateLabel("B3LPPot","Profit Potential:",0,0,30,12);
		CreateLabel("B3VPPot","",0,0,190,12);
		CreateLabel("B3LPrSL","Profit Trailing Stop:",0,0,30,13);
		CreateLabel("B3VPrSL","",0,0,190,13);
		CreateLabel("B3LPnPL","Portion P/L / Pips:",0,0,30,14);
		CreateLabel("B3VPnPL","",0,0,190,14);
		CreateLabel("B3SPnPL","/",0,0,220,14);
		CreateLabel("B3VPPip","",0,0,229,14);
		CreateLabel("B3LPLMM","Profit/Loss Max/Min:",0,0,30,15);
		CreateLabel("B3VPLMx","",0,0,190,15);
		CreateLabel("B3SPLMM","/",0,0,220,15);
		CreateLabel("B3VPLMn","",0,0,225,15);
		CreateLabel("B3LOpen","Open Trades / Lots:",0,0,30,16);
		CreateLabel("B3LType","",0,0,170,16);
		CreateLabel("B3VOpen","",0,0,207,16);
		CreateLabel("B3SOpen","/",0,0,220,16);
		CreateLabel("B3VLots","",0,0,229,16);
		CreateLabel("B3LMvTP","Move TP by:",0,0,0,17);
		CreateLabel("B3VMvTP",DTS(MoveTP/Pip,0),0,0,100,17);
		CreateLabel("B3LMves","# Moves:",0,0,150,17);
		CreateLabel("B3VMove","",0,0,229,17);
		CreateLabel("B3SMves","/",0,0,242,17);
		CreateLabel("B3VMves",DTS(TotalMoves,0),0,0,249,17);
		CreateLabel("B3LMxDD","Max DD:",0,0,0,18);
		CreateLabel("B3VMxDD","",0,0,107,18);
		CreateLabel("B3LDDPC","Max DD %:",0,0,150,18);
		CreateLabel("B3VDDPC","",0,0,229,18);
		CreateLabel("B3PDDPC","%",0,0,257,18);
		if(ForceMarketCond<3)CreateLabel("B3LFMCn","Market trend is forced",0,0,0,19);
		CreateLabel("B3LTrnd","",0,0,0,20);
		if(CCIEntry>0&&displayCCI)
		{	CreateLabel("B3LCCIi","CCI",2,1,12,1);
			CreateLabel("B3LCm05","m5",2,1,25,2.2);
			CreateLabel("B3VCm05","Ø",6,1,0,2,Orange,"Wingdings");
			CreateLabel("B3LCm15","m15",2,1,25,3.4);
			CreateLabel("B3VCm15","Ø",6,1,0,3.2,Orange,"Wingdings");
			CreateLabel("B3LCm30","m30",2,1,25,4.6);
			CreateLabel("B3VCm30","Ø",6,1,0,4.4,Orange,"Wingdings");
			CreateLabel("B3LCm60","h1",2,1,25,5.8);
			CreateLabel("B3VCm60","Ø",6,1,0,5.6,Orange,"Wingdings");
		}
		if(UseHolidayShutdown)
		{	CreateLabel("B3LHols","Next Holiday Period",0,0,240,2);
			CreateLabel("B3LHolD","From: (yyyy.mm.dd) To:",0,0,232,3);
			CreateLabel("B3VHolF","",0,0,232,4);
			CreateLabel("B3VHolT","",0,0,300,4);
		}
	}
}

//+-----------------------------------------------------------------+
//| expert end function                                             |
//+-----------------------------------------------------------------+
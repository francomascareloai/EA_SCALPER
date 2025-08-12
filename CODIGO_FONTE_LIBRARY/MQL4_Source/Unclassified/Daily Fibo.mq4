//+------------------------------------------------------------------+
//|   #SpudFibo.mq4
//+------------------------------------------------------------------+
#property link "http://www.forexfactory.com/showthread.php?t=30109"
#property indicator_chart_window

//+==================================================================+
//| input parameters																	|
//+==================================================================+
extern string	ColorNote		= "--- Fibonacci colors ---";
extern color	UpperFiboColor	= DimGray;
extern color	MainFiboColor	= DimGray;
extern color	LowerFiboColor = DimGray;
extern string	TimeFrameNote	= "--- Timeframe for the high and low ---";
extern string	TimeFrameNot2	= "{1=M1, 5=M5, 15=M15, ..., 1440=D1, 10080=W1, 43200=MN1}";
extern int		TimeFrame		= PERIOD_D1;
extern string	OpenTimeNote2	= "--- Open hour for daily timeframe ---";
extern int		OpenTime			= 0;
extern string	TimeZoneNote	= "{0=ServerTime, 1=GMT, 2=LocalTime}";
extern int		TimeZone			= 0;

//+------------------------------------------------------------------+
//| state variables that are used for drawing the fibs.					|
//+------------------------------------------------------------------+
double HiPrice, LoPrice, Range;
datetime StartTime, EndTime;

//+------------------------------------------------------------------+
//| global constants; get initialized in the init function				|
//+------------------------------------------------------------------+
string	TimeFrameStr;						// Used to label High and Low
int		FirstHour,							// First hour that is used for the range calculation in server time
			LastHour;							// Last hour that is included in the range calculation in server time
//+------------------------------------------------------------------+
#import "kernel32.dll"
int		GetTimeZoneInformation(int& TZInfoArray[]);
#import
//+------------------------------------------------------------------+
int init()
{
//---- name for DataWindow and indicator subwindow label
	switch(TimeFrame)
	{
		case 1:		TimeFrameStr="Minute";		break;
		case 5:		TimeFrameStr="5 Minute";	break;
		case 15:		TimeFrameStr="15 Minute";	break;
		case 30:		TimeFrameStr="30 Minute";	break;
		case 60:		TimeFrameStr="Hourly";		break;
		case 240:	TimeFrameStr="4 Hourly";	break;
		case 1440:	TimeFrameStr="Daily";		break;
		case 10080:	TimeFrameStr="Weekly";		break;
		case 43200:	TimeFrameStr="Monthly";		break;
		default:		TimeFrameStr="Unknown Timeframe";
	}

//---- Calculate timeshift
	int timeShift = 0;
	int ServerLocalOffset = RoundClosest(TimeCurrent()-TimeLocal(),3600) / 60;

	if(TimeZone==2)
		timeShift = ServerLocalOffset/60;						// local time -> server time

	if(TimeZone==1)
	{
		if(IsDllsAllowed())
		{
			int GmtLocalOffset,
			 	ServerGmtOffset,
			 	TZInfoArray[43],
			 	result = GetTimeZoneInformation(TZInfoArray);
			if(result!=0) GmtLocalOffset=TZInfoArray[0];		//	Difference between your local time and GMT in minutes (winter time)
			if(result==2) GmtLocalOffset+=TZInfoArray[42];	//	Current difference between your local time and GMT in minutes
			ServerGmtOffset = ServerLocalOffset-GmtLocalOffset;
			timeShift = ServerGmtOffset/60;						// GMT -> server time
		}
		else Alert("For GMT to work, DLLs must be enabled.");
	}

//----
	FirstHour = OpenTime%24;
	if(FirstHour>0)	LastHour = FirstHour-1;
	else					LastHour = 23;
	LastHour += 24+timeShift;	LastHour %=24;
	FirstHour+= 24+timeShift;	FirstHour%=24;
	Print("FirstHour (server time) = "+FirstHour);
	Print("LastHour (server time) = "+LastHour);
	return(0);
}

//+------------------------------------------------------------------+
int RoundClosest(int n, int step)
{
	if(n > 0)	n += step/2;
	else			n -= step/2;
	return(n - n%step);
}

//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete("FiboUp");
   ObjectDelete("FiboDn");
   ObjectDelete("FiboIn");
   return(0);
}


//+------------------------------------------------------------------+
//| Draw Fibo
//+------------------------------------------------------------------+
int DrawFibo()
{
//----
	if(ObjectFind("FiboUp") == -1)
		ObjectCreate("FiboUp",OBJ_FIBO,0,StartTime,HiPrice+Range,StartTime,HiPrice);
	else
	{
		ObjectSet("FiboUp",OBJPROP_TIME2, StartTime);
		ObjectSet("FiboUp",OBJPROP_TIME1, StartTime);
		ObjectSet("FiboUp",OBJPROP_PRICE1,HiPrice+Range);
		ObjectSet("FiboUp",OBJPROP_PRICE2,HiPrice);
	}
   ObjectSet("FiboUp",OBJPROP_LEVELCOLOR,UpperFiboColor);
   ObjectSet("FiboUp",OBJPROP_FIBOLEVELS,7);
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+0,0.0);	ObjectSetFiboDescription("FiboUp",0,TimeFrameStr+" HIGH (100.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+1,0.236);	ObjectSetFiboDescription("FiboUp",1,"(123.6%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("FiboUp",2,"(138.2%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("FiboUp",3,"(150.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("FiboUp",4,"(161.8%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+5,0.764);	ObjectSetFiboDescription("FiboUp",5,"(176.4%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+6,1.000);	ObjectSetFiboDescription("FiboUp",6,"(200.0%) -  %$"); 
   ObjectSet("FiboUp",OBJPROP_RAY,true);
   ObjectSet("FiboUp",OBJPROP_BACK,true);

//----
	if(ObjectFind("FiboDn") == -1)
		ObjectCreate("FiboDn",OBJ_FIBO,0,StartTime,LoPrice-Range,StartTime,LoPrice);
	else
	{
		ObjectSet("FiboDn",OBJPROP_TIME2, StartTime);
		ObjectSet("FiboDn",OBJPROP_TIME1, StartTime);
		ObjectSet("FiboDn",OBJPROP_PRICE1,LoPrice-Range);
		ObjectSet("FiboDn",OBJPROP_PRICE2,LoPrice);
	}
   ObjectSet("FiboDn",OBJPROP_LEVELCOLOR,LowerFiboColor); 
   ObjectSet("FiboDn",OBJPROP_FIBOLEVELS,7);
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+0,0.0);	ObjectSetFiboDescription("FiboDn",0,TimeFrameStr+" LOW (0.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+1,0.236);	ObjectSetFiboDescription("FiboDn",1,"(-23.6%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+2,0.382);	ObjectSetFiboDescription("FiboDn",2,"(-38.2%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+3,0.500);	ObjectSetFiboDescription("FiboDn",3,"(-50.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+4,0.618);	ObjectSetFiboDescription("FiboDn",4,"(-61.8%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+5,0.764);	ObjectSetFiboDescription("FiboDn",5,"(-76.4%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+6,1.000);	ObjectSetFiboDescription("FiboDn",6,"(-100.0%) -  %$"); 
   ObjectSet("FiboDn",OBJPROP_RAY,true);
   ObjectSet("FiboDn",OBJPROP_BACK,true);

//----
	if(ObjectFind("FiboIn") == -1)
		ObjectCreate("FiboIn",OBJ_FIBO,0,StartTime,HiPrice,EndTime,LoPrice);
	else
	{
		ObjectSet("FiboIn",OBJPROP_TIME1, StartTime);
		ObjectSet("FiboIn",OBJPROP_TIME2, StartTime+TimeFrame*60);
		ObjectSet("FiboIn",OBJPROP_PRICE1,HiPrice);
		ObjectSet("FiboIn",OBJPROP_PRICE2,LoPrice);
	}
  	ObjectSet("FiboIn",OBJPROP_LEVELCOLOR,MainFiboColor); 
  	ObjectSet("FiboIn",OBJPROP_FIBOLEVELS,5);
  	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+0,0.236);	ObjectSetFiboDescription("FiboIn",0,"(23.6"+"\x25"+") -  %$"); 
  	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+1,0.382);	ObjectSetFiboDescription("FiboIn",1,"(38.2) -  %$"); 
  	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+2,0.500);	ObjectSetFiboDescription("FiboIn",2,"(50.0) -  %$"); 
  	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+3,0.618);	ObjectSetFiboDescription("FiboIn",3,"(61.8) -  %$"); 
  	ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+4,0.764);	ObjectSetFiboDescription("FiboIn",4,"(76.4) -  %$"); 
  	ObjectSet("FiboIn",OBJPROP_RAY,true);
  	ObjectSet("FiboIn",OBJPROP_BACK,true);
}

//+------------------------------------------------------------------+
//| Indicator start function
//+------------------------------------------------------------------+

int start()
{
	if(TimeFrame!=PERIOD_D1 || (OpenTime==0 && TimeZone==0))
//	Use daily, weekly, whatever candles
	{
		int shift	= iBarShift(NULL,TimeFrame,Time[0]) + 1;	// yesterday
		HiPrice		= iHigh(NULL,TimeFrame,shift);
		LoPrice		= iLow (NULL,TimeFrame,shift);
		StartTime	= iTime(NULL,TimeFrame,shift);
		EndTime		= StartTime+TimeFrame*60;

		if(TimeFrame==PERIOD_D1 && TimeDayOfWeek(StartTime)==0/*Sunday*/)
		{//Add fridays high and low
			HiPrice = MathMax(HiPrice,iHigh(NULL,PERIOD_D1,shift+1));
			LoPrice = MathMin(LoPrice,iLow(NULL,PERIOD_D1,shift+1));
			StartTime = iTime(NULL,PERIOD_D1,shift+1);
		}
	}
	else
//	Use hourly candles
	{
	//----
	//	find last candle of the period
		shift = 1;
		while(TimeHour(iTime(NULL,PERIOD_H1,shift)) != LastHour)
			shift++;
	//----
	//	find first candle of the period
		int startShift = shift;
		while(TimeHour(iTime(NULL,PERIOD_H1,startShift)) != FirstHour
		||TimeDayOfWeek(iTime(NULL,PERIOD_H1,startShift))==0/*Sunday*/)
			startShift++;
		while(TimeHour(iTime(NULL,PERIOD_H1,startShift)) == FirstHour)
			startShift++;
		startShift--;

	//----
	//	get the highest high and lowest low of the period
		HiPrice		= iHigh(NULL,PERIOD_H1,iHighest(NULL,PERIOD_H1,MODE_HIGH,startShift-shift+1,shift));
		LoPrice		= iLow (NULL,PERIOD_H1,iLowest (NULL,PERIOD_H1,MODE_LOW, startShift-shift+1,shift));
		StartTime	= iTime(NULL,PERIOD_H1,startShift);
		EndTime		= iTime(NULL,PERIOD_H1,shift);
	}

	Range = HiPrice-LoPrice;
	DrawFibo();

	return(0);
}
//+------------------------------------------------------------------+


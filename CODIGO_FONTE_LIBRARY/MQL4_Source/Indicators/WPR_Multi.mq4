//+------------------------------------------------------------------+
//|                                                    WPR_Multi.mq4 |
//|                                                     собрал ag_ch |
//|                                                       иде€ vsmark|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
//----
#property indicator_separate_window
#property indicator_minimum -100
#property indicator_maximum 0
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 DeepSkyBlue
#property indicator_color4 Blue
#property indicator_color5 Black
#property indicator_color6 DarkViolet
#property  indicator_width1  1
#property  indicator_width2  1
#property  indicator_width3  1
#property  indicator_width4  1
#property  indicator_width5  2
#property  indicator_width6  1
#property indicator_level1 -11.8
#property indicator_level2 -38.2
#property indicator_level3 -61.8
#property indicator_level4 -88.2
#property indicator_levelcolor Black
#property indicator_levelwidth 1
#property indicator_levelstyle 0

//---- input parameters
extern bool enableWPR1 = true;
extern int ExtWPRPeriod1 = 11;
extern bool enableWPR2 = true;
extern int ExtWPRPeriod2 = 21;
extern bool enableWPR3 = true;
extern int ExtWPRPeriod3 = 55;
extern bool enableWPR4 = true;
extern int ExtWPRPeriod4 = 77;
extern bool enableWPR5 = true;
extern int ExtWPRPeriod5 = 283;
extern bool enableWPR6 = false;
extern int ExtWPRPeriod6 = 283;
extern double zona = 11.8;
extern bool enableAlerts = false;
static int pos;
//---- buffers
double ExtWPRBuffer1[];
double ExtWPRBuffer2[];
double ExtWPRBuffer3[];
double ExtWPRBuffer4[];
double ExtWPRBuffer5[];
double ExtWPRBuffer6[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	string sShortName;
//---- indicator buffer mapping
	SetIndexBuffer(0, ExtWPRBuffer1);
	SetIndexBuffer(1, ExtWPRBuffer2);
	SetIndexBuffer(2, ExtWPRBuffer3);
	SetIndexBuffer(3, ExtWPRBuffer4);
	SetIndexBuffer(4, ExtWPRBuffer5);
	SetIndexBuffer(5, ExtWPRBuffer6);
//---- indicator line
	SetIndexStyle(0, DRAW_LINE);
	SetIndexStyle(1, DRAW_LINE);
	SetIndexStyle(2, DRAW_LINE);   
	SetIndexStyle(3, DRAW_LINE);
	SetIndexStyle(4, DRAW_LINE);
	SetIndexStyle(5, DRAW_LINE);
//---- name for DataWindow and indicator subwindow label
	sShortName = "%R_Multi(";
	if (enableWPR1 == true)
		sShortName = sShortName + ExtWPRPeriod1;

	if (enableWPR2 == true)
		sShortName = sShortName + "|" + ExtWPRPeriod2;

	if (enableWPR3 == true)
		sShortName = sShortName + "|" + ExtWPRPeriod3;

	if (enableWPR4 == true)
		sShortName = sShortName + "|" + ExtWPRPeriod4;

	if (enableWPR5 == true)
		sShortName = sShortName + "|" + ExtWPRPeriod5;
			
	if (enableWPR6 == true)
		sShortName = sShortName + "|" + ExtWPRPeriod6;

	sShortName = sShortName + ")";
	//   sShortName="%R_Multi(" + ExtWPRPeriod1 + "|" + ExtWPRPeriod2 + "|" + ExtWPRPeriod3 + "|" + ExtWPRPeriod4 +")";
	IndicatorShortName(sShortName);
	SetIndexLabel(0, sShortName);
//---- first values aren't drawn
	SetIndexDrawBegin(0, ExtWPRPeriod1);
	SetIndexDrawBegin(0, ExtWPRPeriod2);
	SetIndexDrawBegin(0, ExtWPRPeriod3);
	SetIndexDrawBegin(0, ExtWPRPeriod4);
	SetIndexDrawBegin(0, ExtWPRPeriod5);
	SetIndexDrawBegin(0, ExtWPRPeriod6);
	//----
	pos = 0;
	return(0);
}
//+------------------------------------------------------------------+
//| WilliamsТ Percent Range                                          |
//+------------------------------------------------------------------+
int start()
{
	int i, ii, iii, iiii, iv, v, vi, nLimit, nCountedBars; 
	double dMaxHigh, dMinLow; 
//---- insufficient data
	if(Bars <= ExtWPRPeriod3) 
   	return(0);
//---- bars count that does not changed after last indicator launch.
	nCountedBars = IndicatorCounted();
//----WilliamsТ Percent Range calculation 1

	if (enableWPR1 == true)
	{
		i = Bars - ExtWPRPeriod1 - 1;
		if(nCountedBars > ExtWPRPeriod1) 
   		i = Bars - nCountedBars - 1;  
		while(i >= 0)
 		{
   		dMaxHigh = High[Highest(NULL, 0, MODE_HIGH, ExtWPRPeriod1, i)];
   		dMinLow = Low[Lowest(NULL, 0, MODE_LOW, ExtWPRPeriod1, i)];      
   		if(!CompareDouble((dMaxHigh - dMinLow), 0.0))
       		ExtWPRBuffer1[i] = -100*(dMaxHigh - Close[i]) / (dMaxHigh - dMinLow);
   		i--;       
 		}
 	}
     
//----WilliamsТ Percent Range calculation 2
	if (enableWPR2 == true)
	{
		ii = Bars - ExtWPRPeriod2 - 1;
		if(nCountedBars > ExtWPRPeriod2) 
   		ii = Bars - nCountedBars - 1;  
		while(ii >= 0)
 		{
   		dMaxHigh = High[Highest(NULL, 0, MODE_HIGH, ExtWPRPeriod2, ii)];
   		dMinLow = Low[Lowest(NULL, 0, MODE_LOW, ExtWPRPeriod2, ii)];      
   		if(!CompareDouble((dMaxHigh - dMinLow), 0.0))
       		ExtWPRBuffer2[ii] = -100*(dMaxHigh - Close[ii]) / (dMaxHigh - dMinLow);
   		ii--;       
 		}
 	}
 	
//----WilliamsТ Percent Range calculation 3
	if (enableWPR3 == true)
	{
		iii = Bars - ExtWPRPeriod3 - 1;
		if(nCountedBars > ExtWPRPeriod3) 
   		iii = Bars - nCountedBars - 1;  
		while(iii >= 0)
 		{
   		dMaxHigh = High[Highest(NULL, 0, MODE_HIGH, ExtWPRPeriod3, iii)];
   		dMinLow = Low[Lowest(NULL, 0, MODE_LOW, ExtWPRPeriod3, iii)];      
   		if(!CompareDouble((dMaxHigh - dMinLow), 0.0))
       		ExtWPRBuffer3[iii] = -100*(dMaxHigh - Close[iii]) / (dMaxHigh - dMinLow);
   		iii--;       
 		}
 	}
 	
//----WilliamsТ Percent Range calculation 4
	if (enableWPR4 == true)
	{
		iv = Bars - ExtWPRPeriod4 - 1;
		if(nCountedBars > ExtWPRPeriod4) 
   		iv = Bars - nCountedBars - 1;  
		while(iv >= 0)
 		{
   		dMaxHigh = High[Highest(NULL, 0, MODE_HIGH, ExtWPRPeriod4, iv)];
   		dMinLow = Low[Lowest(NULL, 0, MODE_LOW, ExtWPRPeriod4, iv)];      
   		if(!CompareDouble((dMaxHigh - dMinLow), 0.0))
       		ExtWPRBuffer4[iv] = -100*(dMaxHigh - Close[iv]) / (dMaxHigh - dMinLow);
   		iv--;       
 		}
 	}
//----WilliamsТ Percent Range calculation 5
	if (enableWPR5 == true)
	{
		v = Bars - ExtWPRPeriod5 - 1;
		if(nCountedBars > ExtWPRPeriod5) 
   		v = Bars - nCountedBars - 1;  
		while(v >= 0)
 		{
   		dMaxHigh = High[Highest(NULL, 0, MODE_HIGH, ExtWPRPeriod5, v)];
   		dMinLow = Low[Lowest(NULL, 0, MODE_LOW, ExtWPRPeriod5, v)];      
   		if(!CompareDouble((dMaxHigh - dMinLow), 0.0))
       		ExtWPRBuffer5[v] = -100*(dMaxHigh - Close[v]) / (dMaxHigh - dMinLow);
   		v--;       
 		}
 	}
 //----WilliamsТ Percent Range calculation 6
	if (enableWPR6 == true)
	{
		vi = Bars - ExtWPRPeriod6 - 1;
		if(nCountedBars > ExtWPRPeriod6) 
   		vi = Bars - nCountedBars - 1;  
		while(vi >= 0)
 		{
   		dMaxHigh = High[Highest(NULL, 0, MODE_HIGH, ExtWPRPeriod6, vi)];
   		dMinLow = Low[Lowest(NULL, 0, MODE_LOW, ExtWPRPeriod6, vi)];      
   		if(!CompareDouble((dMaxHigh - dMinLow), 0.0))
       		ExtWPRBuffer6[vi] = -100*(dMaxHigh - Close[vi]) / (dMaxHigh - dMinLow);
   		vi--;       
 		}
 	}
//----
	if (enableAlerts == true)
	{
		if (pos == 0 && ExtWPRBuffer1[1] < -100 + zona)
		{
			pos = -1;
			Alert(Symbol(), ": BUY!  ÷ена вошла в перепроданность!   ", DoubleToStr(ExtWPRBuffer1[1], 1));
		}
		else if (pos == -1 && ExtWPRBuffer1[1] > -100 + zona)
		{
			pos = 0;
			Alert(Symbol(), ": BUY!  ÷ена вышла из перепроданности!   ", DoubleToStr(ExtWPRBuffer1[1], 1));
		}
		else if (pos == 0 && ExtWPRBuffer1[1] > -zona)
		{
			pos = 1;
			Alert(Symbol(), ": SELL!  ÷ена вошла в перекупленность!   ", DoubleToStr(ExtWPRBuffer1[1], 1));
		}
		else if (pos == 1 && ExtWPRBuffer1[1] < -zona)
		{
			pos = 0;
			Alert(Symbol(), ": SELL!  ÷ена вышла из перекупленности!   ", DoubleToStr(ExtWPRBuffer1[1], 1));
		}
	}
	
	return(0);
}
//+------------------------------------------------------------------+
//| ‘ункци€ сранени€ двух вещественных чисел.                        |
//+------------------------------------------------------------------+
bool CompareDouble(double Number1, double Number2)
{
  bool Compare = NormalizeDouble(Number1 - Number2, 8) == 0;
  return(Compare);
} 
//+------------------------------------------------------------------+ 
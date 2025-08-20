//+------------------------------------------------------------------+
//|                                                          ADX.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 LightSeaGreen
#property indicator_color2 YellowGreen
#property indicator_color3 Wheat

//---- input parameters
extern int ADXPeriod=14;
extern int SMAfast=5;
extern int SMAslow=55;
double LoTrigger=-0.125,HiTrigger=0.125;
int shift=0, MAType=1, cnt=0,  prevbars=0,loopbegin=0;
double sum=0, smconst=0, prev=0, weight=0, linear=0,IFish=0;
double  MAValue=0;
double signal=0,noise=0,efRatio=0,i=0, Fastest=0.6667, Slowest=0.0645;
bool first=true;
//---- buffers
double TrendBuffer[];
double LoBuffer[];
double HiBuffer[];
double PlusSdiBuffer[];
double MinusSdiBuffer[];
double TempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- indicator buffers
   SetIndexBuffer(0,TrendBuffer);
   SetIndexBuffer(1,LoBuffer);
   SetIndexBuffer(2,HiBuffer);
    SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,Red);
    IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("TrendPower("+SMAfast+")");
   
   SetIndexDrawBegin(0,TrendBuffer);
   SetIndexDrawBegin(1,ADXPeriod);
   SetIndexDrawBegin(2,ADXPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average Directional Movement Index                               |
//+------------------------------------------------------------------+
int start()
  {
  // initial checkings
// check for additional bars loading or total reloading
if (Bars < prevbars )  first = true;
if (Bars-prevbars>1) first = true;
prevbars = Bars;
if (first) 
{
	// loopbegin prevent couning of counted bars exclude current
	loopbegin = Bars-SMAslow-1;
	if (loopbegin < 0) return(0);      // not enough bars for counting
	if (Period() > 70 ) 
	{
	LoTrigger=-0.15;
	HiTrigger=0.15;
	}
	else 
	   {
	LoTrigger=-0.07;
	HiTrigger=0.07;
		};
	first = False;
   }
  
 
  loopbegin = loopbegin+1; 
 // Comment( loopbegin);            // current bar is to be recounted too
  for (shift = loopbegin; shift>= 0 ;shift--)
	{
	MAValue = 100 * (iMA(NULL,0,SMAfast,0,MODE_EMA,PRICE_CLOSE,shift)
	 - iMA(NULL,0,SMAslow,0,MODE_EMA,PRICE_CLOSE,shift))
	 *iATR(NULL,0,SMAfast,shift)
	 /iMA(NULL,0,SMAslow,0,MODE_EMA,PRICE_CLOSE,shift)
	 /iATR(NULL,0,SMAslow,shift);
	IFish=(MathExp(2*MAValue)-1)/(MathExp(2*MAValue)+1);
//	SetIndexValue(shift,IFish);
//Comment(IFish);
	TrendBuffer[shift]=IFish;
	loopbegin = loopbegin-1;     
	}}
	return(0);


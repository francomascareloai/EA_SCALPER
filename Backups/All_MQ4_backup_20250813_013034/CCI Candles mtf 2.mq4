//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green//wick
#property indicator_color2 Red//wick
#property indicator_color3 Green//candle
#property indicator_color4 Red//candle
#property indicator_color5 DarkGray//wick
#property indicator_color6 DarkGray//wick
#property indicator_color7 DarkGray//candle
#property indicator_color8 DarkGray//candle
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 3
#property indicator_width8 3


//---- stoch settings
extern string TimeFrame   = "current time frame";
extern int	  CCI_Period  = 25;
extern int    CCI_Price   = 0;
extern int	  Overbought  = 150;
extern int	  Oversold    = -150;
extern int	  WickWidth	  = 1;
extern int	  BodyWidth   = 2;

//---- buffers
double bup1[];
double bdn1[];
double wup1[];
double wdn1[];
double bup2[];
double bdn2[];
double wup2[];
double wdn2[];

string indicatorFileName;
bool   returnBars;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
//---- indicators
	IndicatorShortName("CCI Candles:("+	CCI_Period+")");
	SetIndexBuffer(0,wup1); SetIndexStyle(0,DRAW_HISTOGRAM,0,WickWidth);
	SetIndexBuffer(1,wdn1);	SetIndexStyle(1,DRAW_HISTOGRAM,0,WickWidth);
	SetIndexBuffer(2,bup1); SetIndexStyle(2,DRAW_HISTOGRAM,0,BodyWidth);
	SetIndexBuffer(3,bdn1); SetIndexStyle(3,DRAW_HISTOGRAM,0,BodyWidth);
	SetIndexBuffer(4,wup2); SetIndexStyle(4,DRAW_HISTOGRAM,0,WickWidth);
	SetIndexBuffer(5,wdn2);	SetIndexStyle(5,DRAW_HISTOGRAM,0,WickWidth);
	SetIndexBuffer(6,bup2); SetIndexStyle(6,DRAW_HISTOGRAM,0,BodyWidth);
	SetIndexBuffer(7,bdn2); SetIndexStyle(7,DRAW_HISTOGRAM,0,BodyWidth);
         indicatorFileName = WindowExpertName();
         returnBars        = (TimeFrame=="returnBars"); 
         timeFrame         = stringToTimeFrame(TimeFrame);
	return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-2);
         if (returnBars) { wup1[0] = limit; return(0); }
         if (timeFrame!=Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));

   //
   //
   //
   //
   //
   
	for(int i = limit; i>=0; i--)
	{
      int y = iBarShift(NULL,timeFrame,Time[i]);	
		   double cci   = iCCI(NULL,timeFrame,CCI_Period,CCI_Price,y);
		   int    state = 0;
				if(cci > Overbought)	state = 1;
				if(cci < Oversold)	state =-1;
				
				wup1[i] = EMPTY_VALUE; wdn1[i] = EMPTY_VALUE; bup1[i] = EMPTY_VALUE; bdn1[i] = EMPTY_VALUE;
				wup2[i] = EMPTY_VALUE; wdn2[i] = EMPTY_VALUE; bup2[i] = EMPTY_VALUE; bdn2[i] = EMPTY_VALUE;
				if (state== 1) { wup1[i] = High[i]; wdn1[i] = Low[i]; bup1[i] = MathMax(Open[i],Close[i]); bdn1[i] = MathMin(Open[i],Close[i]); }
				if (state==-1) { wdn1[i] = High[i]; wup1[i] = Low[i]; bdn1[i] = MathMax(Open[i],Close[i]); bup1[i] = MathMin(Open[i],Close[i]); }
				if (state== 0) { wup2[i] = High[i]; wdn2[i] = Low[i]; bup2[i] = Open[i]; bdn2[i] = Close[i]; }
	}
	return(0);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}
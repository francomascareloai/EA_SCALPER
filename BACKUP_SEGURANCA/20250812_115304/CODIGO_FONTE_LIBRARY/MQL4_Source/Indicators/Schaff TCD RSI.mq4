//+------------------------------------------------------------------+
//|                                             Schaff Trend RSI.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    1
#property indicator_color1     DeepSkyBlue
#property indicator_width1     2
#property indicator_minimum    -5
#property indicator_maximum    105
#property indicator_level1     20
#property indicator_level2     80
#property indicator_levelcolor DimGray


//
//
//
//
//

extern string TimeFrame      = "current time frame";
extern int    FastMAPeriod   = 23;
extern int    SlowMAPeriod   = 50;
extern int    PeriodLength   = 25;
extern int    MacdPrice      = PRICE_CLOSE;
extern int    RsiPeriod      = 9;
extern bool   Interpolate    = true;

//
//
//
//
//

double strBuffer[];
double macdBuffer[];
double signBuffer[];

//
//
//
//
//

string IndicatorFileName;
bool   calculating=false;
bool   returnBars =false;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,strBuffer);
   
   //
   //
   //
   //
   //
   
   if (TimeFrame == "calculateSCHAF")
   {
      calculating = true;
         IndicatorBuffers(3);
            SetIndexBuffer(1,macdBuffer);
            SetIndexBuffer(2,signBuffer);
      return(0);
   }
   if (TimeFrame == "getBarsCount")
   {
      returnBars=true;
      return(0);
   }   

   //
   //
   //
   //
   //

      timeFrame = stringToTimeFrame(TimeFrame);   
      string TimeFrameStr;
         switch(timeFrame)
         {
            case PERIOD_M1:  TimeFrameStr="(M1)";      break;
            case PERIOD_M5:  TimeFrameStr="(M5)";      break;
            case PERIOD_M15: TimeFrameStr="(M15)";     break;
            case PERIOD_M30: TimeFrameStr="(M30)";     break;
            case PERIOD_H1:  TimeFrameStr="(H1)";      break;
            case PERIOD_H4:  TimeFrameStr="(H4)";      break;
            case PERIOD_D1:  TimeFrameStr="(Dayly)";   break;
            case PERIOD_W1:  TimeFrameStr="(Weekly)";  break;
            case PERIOD_MN1: TimeFrameStr="(Monthly)"; break;
            default :        TimeFrameStr="";
         }   

   IndicatorShortName("Schaff TCD RSI "+TimeFrameStr+"("+FastMAPeriod+","+SlowMAPeriod+","+PeriodLength+","+RsiPeriod+")");
   IndicatorFileName = WindowExpertName();
   return(0);
}

int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int limit,i;

   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   if (returnBars) { strBuffer[0] = limit; return(0); }
   if (calculating)   
   {
      double alpha = 2.0 / (1.0 + PeriodLength);
      for(i = limit; i >= 0; i--)
      {
          macdBuffer[i] = iMA(NULL,0,FastMAPeriod,0,MODE_EMA,MacdPrice,i)-iMA(NULL,0,SlowMAPeriod,0,MODE_EMA,MacdPrice,i);
          signBuffer[i] = signBuffer[i+1]+alpha*(macdBuffer[i]-signBuffer[i+1]);
      }          
      for(i = limit; i >= 0; i--) strBuffer[i] = iRSIOnArray(signBuffer,0,RsiPeriod,i);
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,IndicatorFileName,"getBarsCount",0,0)*timeFrame/Period()));
      for(i = limit; i >= 0; i--)
      {
         int y = iBarShift(NULL,timeFrame,Time[i]);

         strBuffer[i] = iCustom(NULL,timeFrame,IndicatorFileName,"calculateSCHAF",FastMAPeriod,SlowMAPeriod,PeriodLength,MacdPrice,RsiPeriod,0,y); 

         if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
         if (!Interpolate)                                                    continue;
            
         //
         //
         //
         //
         //
		 
	      datetime	time  = iTime(NULL,timeFrame,y);
 	         for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
      	   double factor = 1.0 / n;
               for(int k = 1; k < n; k++)
			         strBuffer[i+k] = k*factor*strBuffer[i+n] + (1.0-k*factor)*strBuffer[i];
      }
   return(0);      
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   for(int l = StringLen(tfs)-1; l >= 0; l--)
   {
      int tchar = StringGetChar(tfs,l);
          if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
               tfs = StringSetChar(tfs, l, tchar - 32);
          else 
              if(tchar > -33 && tchar < 0)
                  tfs = StringSetChar(tfs, l, tchar + 224);
   }

   //
   //
   //
   //
   //
   
   int tf=0;
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf<Period())               tf=Period();
   return(tf);
}
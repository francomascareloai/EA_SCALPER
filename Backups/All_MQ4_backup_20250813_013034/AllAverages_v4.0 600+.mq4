//+------------------------------------------------------------------+
//|                                        AllAverages_v4.0 600+.mq4 |
//|                             Copyright © 2007-15, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007-15, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrTomato
#property indicator_width1  2  
#property indicator_color2  clrDeepSkyBlue
#property indicator_width2  2  
#property indicator_color3  clrDeepSkyBlue
#property indicator_width3  2  

enum ENUM_MA_MODE
{
   SMA,                 // Simple Moving Average
   EMA,                 // Exponential Moving Average
   Wilder,              // Wilder Exponential Moving Average
   LWMA,                // Linear Weighted Moving Average
   SineWMA,             // Sine Weighted Moving Average
   TriMA,               // Triangular Moving Average
   LSMA,                // Least Square Moving Average (or EPMA, Linear Regression Line)
   SMMA,                // Smoothed Moving Average
   HMA,                 // Hull Moving Average by Alan Hull
   ZeroLagEMA,          // Zero-Lag Exponential Moving Average
   DEMA,                // Double Exponential Moving Average by Patrick Mulloy
   T3_basic,            // T3 by T.Tillson (original version)
   ITrend,              // Instantaneous Trendline by J.Ehlers
   Median,              // Moving Median
   GeoMean,             // Geometric Mean
   REMA,                // Regularized EMA by Chris Satchwell
   ILRS,                // Integral of Linear Regression Slope
   IE_2,                // Combination of LSMA and ILRS
   TriMAgen,            // Triangular Moving Average generalized by J.Ehlers
   VWMA,                // Volume Weighted Moving Average
   JSmooth,             // Smoothing by Mark Jurik
   SMA_eq,              // Simplified SMA
   ALMA,                // Arnaud Legoux Moving Average
   TEMA,                // Triple Exponential Moving Average by Patrick Mulloy
   T3,                  // T3 by T.Tillson (correct version)
   Laguerre,            // Laguerre filter by J.Ehlers
   MD,                  // McGinley Dynamic
   BF2P,                // Two-pole modified Butterworth filter by J.Ehlers
   BF3P,                // Three-pole modified Butterworth filter by J.Ehlers
   SuperSmu             // SuperSmoother by J.Ehlers
};   

enum ENUM_PRICE
{
   close,               // Close
   open,                // Open
   high,                // High
   low,                 // Low
   median,              // Median
   typical,             // Typical
   weightedClose,       // Weighted Close
   heikenAshiClose,     // Heiken Ashi Close
   heikenAshiOpen,      // Heiken Ashi Open
   heikenAshiHigh,      // Heiken Ashi High   
   heikenAshiLow,       // Heiken Ashi Low
   heikenAshiMedian,    // Heiken Ashi Median
   heikenAshiTypical,   // Heiken Ashi Typical
   heikenAshiWeighted   // Heiken Ashi Weighted Close   
};

#define pi 3.14159265358979323846

//---- 
input ENUM_TIMEFRAMES   TimeFrame         =     0;    
input ENUM_PRICE        Price             =     0;    
input int               MA_Period         =    14;
input int               MA_Shift          =     0;
input ENUM_MA_MODE      MA_Method         =  LWMA;
input bool              ShowInColor       =  true;
input int               CountBars         =     0;    // Number of bars counted: 0-all bars 

input string            Alerts               = "=== Alerts & Emails ===";
input bool              AlertOn           = false;
input int               AlertShift        =     1;      // Alert Shift:0-current bar,1-previous bar
input int               SoundsNumber      =     5;      // Number of sounds after Signal
input int               SoundsPause       =     5;      // Pause in sec between sounds 
input string            UpSound           = "alert.wav";
input string            DnSound           = "alert2.wav";
input bool              EmailOn           = false;       
input int               EmailsNumber      =     1;          


double allAvg[];
double Up1[];
double Up2[];
double iPrice[];
double trend[];

//----
double   tmp[][1][2], ma[1][4];
double   haClose[2], haOpen[2], haHigh[2], haLow[2];
int      cBars, timeframe, draw_begin, masize; 
string   IndicatorName, TF, maname;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   timeframe = TimeFrame;
   if(timeframe <= Period()) timeframe = Period(); 
   TF = EnumToString(TimeFrame);
   TF = StringSubstr(TF,7,StringLen(TF));
   
   IndicatorDigits(Digits);
//----
   IndicatorBuffers(5); 
   
   SetIndexBuffer(0,allAvg); SetIndexStyle(0,DRAW_LINE); SetIndexShift(0,MA_Shift*TimeFrame/Period());
   SetIndexBuffer(1,   Up1); SetIndexStyle(1,DRAW_LINE); SetIndexShift(1,MA_Shift*TimeFrame/Period());
   SetIndexBuffer(2,   Up2); SetIndexStyle(2,DRAW_LINE); SetIndexShift(2,MA_Shift*TimeFrame/Period());
   SetIndexBuffer(3,iPrice);
   SetIndexBuffer(4, trend);
   
   if(CountBars == 0) cBars = timeframe/Period()*(iBars(NULL,TimeFrame) - MA_Period); else cBars = CountBars*timeframe/Period();
   
   draw_begin = Bars - cBars;
   SetIndexDrawBegin(0,draw_begin);   
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
//---- 
   maname = EnumToString(MA_Method);
   masize = averageSize(MA_Method);
      
   IndicatorName = WindowExpertName(); 
   
   IndicatorShortName(maname + "(" + MA_Period+")" + " " + TF);
   
   SetIndexLabel(0,maname + "(" + MA_Period + ")" + " " + TF);
      
//----   
   if(masize > 0) ArrayResize(tmp,masize);
      
   return(0);
}
//+------------------------------------------------------------------+
//| AllAverages_v4.0 600+                                            |
//+------------------------------------------------------------------+
int start()
{
   int limit, y, shift, cnt_bars = IndicatorCounted(); 
   
   if(cnt_bars > 0) limit = Bars - cnt_bars - 1;
   if(cnt_bars < 0) return(0);    
   if(cnt_bars < 1)
   {
   if(CountBars > 0) limit = CountBars + MA_Period; else limit = Bars - 1;
   }
   
   
//---- 
   if(timeframe != Period())
	{
   limit = MathMax(limit,timeframe/Period());   
      
      for(shift=0;shift<limit;shift++) 
      {	
      y = iBarShift(NULL,TimeFrame,Time[shift]);
            
      allAvg[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,Price,MA_Period,MA_Shift,MA_Method,ShowInColor,CountBars,
                              "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpSound,DnSound,EmailOn,EmailsNumber,0,y);    
         
         if(ShowInColor)
         {
         trend[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,Price,MA_Period,MA_Shift,MA_Method,ShowInColor,CountBars,
                                "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpSound,DnSound,EmailOn,EmailsNumber,4,y);    
         
      
         Up1[shift] = EMPTY_VALUE;
         if(trend[shift] > 0) Up1[shift] = allAvg[shift];  
         }
      }
      
      if(ShowInColor)
      {
         for(shift=limit;shift>=0;shift--) 
         {	
         Up2[shift] = EMPTY_VALUE;   
            if(allAvg[shift] > allAvg[shift+1]) 
            {
            Up2[shift]   = allAvg[shift];
            Up2[shift+1] = allAvg[shift+1];
            }	
         }
      }
      
      if(CountBars > 0)
      {
      SetIndexDrawBegin(0,Bars - cBars);   
      SetIndexDrawBegin(1,Bars - cBars);
      SetIndexDrawBegin(2,Bars - cBars);
      }   
   
	return(0);
	}
   else
   {
      for(shift=limit;shift>=0;shift--) 
      {
         if((int)Price <= 6) iPrice[shift] = iMA(NULL,0,1,0,0,(int)Price,shift);   
         else
         if((int)Price > 6 && (int)Price <= 13) iPrice[shift] = HeikenAshi((int)Price-7,cBars + MA_Period,shift);

      allAvg[shift] = allAveragesOnArray(0,iPrice,MA_Period,(int)MA_Method,masize,cBars + MA_Period,shift);   
              
      trend[shift] = trend[shift+1];
      if(allAvg[shift] > allAvg[shift+1]) trend[shift] = 1;
      if(allAvg[shift] < allAvg[shift+1]) trend[shift] =-1;       
         
         if(ShowInColor)
         {
         Up1[shift] = EMPTY_VALUE; 
         Up2[shift] = EMPTY_VALUE;
          
            if(trend[shift] > 0)
            {
               if(Up1[shift+1] == EMPTY_VALUE)
               {
                  if(Up1[shift+2] == EMPTY_VALUE) 
                  {
                  Up1[shift]   = allAvg[shift];
                  Up1[shift+1] = allAvg[shift+1];
                  Up2[shift]   = EMPTY_VALUE;
                  }
                  else 
                  {
                  Up2[shift]   = allAvg[shift];
                  Up2[shift+1] = allAvg[shift+1];
                  Up1[shift]   = EMPTY_VALUE;
                  }
               }
               else
               {
               Up1[shift]  = allAvg[shift];
               Up2[shift]  = EMPTY_VALUE;
               }
            }
         }
      }
      
      if(AlertOn)
      {
      bool uptrend = trend[AlertShift] > 0 && trend[AlertShift+1] <= 0;                  
      bool dntrend = trend[AlertShift] < 0 && trend[AlertShift+1] >= 0;
        
         if(uptrend || dntrend)
         {
            if(isNewBar(timeframe))
            {
            BoxAlert(uptrend," : " + maname + "(" + MA_Period + ") is going Up @ " + DoubleToStr(Close[AlertShift],Digits));   
            BoxAlert(dntrend," : " + maname + "(" + MA_Period + ") is going Down @ " + DoubleToStr(Close[AlertShift],Digits)); 
            }
      
         WarningSound(uptrend,SoundsNumber,SoundsPause,UpSound,Time[AlertShift]);
         WarningSound(dntrend,SoundsNumber,SoundsPause,DnSound,Time[AlertShift]);
         
            if(EmailOn)
            {
            EmailAlert(uptrend,"BUY" ," : " + maname + "(" + MA_Period + ") is going Up @ " + DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
            EmailAlert(dntrend,"SELL"," : " + maname + "(" + MA_Period + ") is going Down @ " + DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
            }
         }
      }  
   
      if(CountBars > 0)
      {
      SetIndexDrawBegin(0,Bars - cBars);   
      SetIndexDrawBegin(1,Bars - cBars);
      SetIndexDrawBegin(2,Bars - cBars);
      }   
   }

//---- 
   return(0);
}

int averageSize(int mode)
{   
   int arraysize;
   
   switch(mode)
   {
   case 10: arraysize = 2; break;
   case 11: arraysize = 6; break;
   case 20: arraysize = 5; break;
   case 23: arraysize = 4; break;
   case 24: arraysize = 6; break;
   case 25: arraysize = 4; break;
   default: arraysize = 0; break;
   }
   
   return(arraysize);
}

datetime prevtime[1];  

double allAveragesOnArray(int index,double& price[],int period,int mode,int arraysize,int cbars,int bar)
{
   double MA[4];  
        
   if(mode == 1 || mode == 2 || mode == 7 || mode == 9 || mode == 10 || mode == 11 || mode == 12 || mode == 15 || mode == 20 || mode == 21 || (mode > 22 && mode < 30))  
   {
      if(prevtime[index] != Time[bar])
      {
      ma[index][3] = ma[index][2]; 
      ma[index][2] = ma[index][1]; 
      ma[index][1] = ma[index][0]; 
   
      if(arraysize > 0) for(int i=0;i<arraysize;i++) tmp[i][index][1] = tmp[i][index][0];
    
      prevtime[index] = Time[bar]; 
      }
   
      if(mode == 12 || mode == 15 || mode == 21 || (mode > 26 && mode < 30)) for(i=0;i<4;i++) MA[i] = ma[index][i]; 
   }
   
   switch(mode)
   {
   case 1 : ma[index][0] = EMAOnArray(price[bar],ma[index][1],period,cbars,bar); break;
   case 2 : ma[index][0] = WilderOnArray(price[bar],ma[index][1],period,cbars,bar); break;  
   case 3 : ma[index][0] = LWMAOnArray(price,period,bar); break;
   case 4 : ma[index][0] = SineWMAOnArray(price,period,bar); break;
   case 5 : ma[index][0] = TriMAOnArray(price,period,bar); break;
   case 6 : ma[index][0] = LSMAOnArray(price,period,bar); break;
   case 7 : ma[index][0] = SMMAOnArray(price,ma[index][1],period,cbars,bar); break;
   case 8 : ma[index][0] = HMAOnArray(price,period,cbars,bar); break;
   case 9 : ma[index][0] = ZeroLagEMAOnArray(price,ma[index][1],period,cbars,bar); break;
   case 10: ma[index][0] = DEMAOnArray(index,0,price[bar],period,1,cbars,bar); break;
   case 11: ma[index][0] = T3_basicOnArray(index,0,price[bar],period,0.7,cbars,bar); break;
   case 12: ma[index][0] = ITrendOnArray(price,MA,period,cbars,bar); break;
   case 13: ma[index][0] = MedianOnArray(price,period,bar); break;
   case 14: ma[index][0] = GeoMeanOnArray(price,period,cbars,bar); break;
   case 15: ma[index][0] = REMAOnArray(price[bar],MA,period,0.5,cbars,bar); break;
   case 16: ma[index][0] = ILRSOnArray(price,period,bar); break;
   case 17: ma[index][0] = IE2OnArray(price,period,bar); break;
   case 18: ma[index][0] = TriMA_genOnArray(price,period,bar); break;
   case 19: ma[index][0] = VWMAOnArray(price,period,bar); break;
   case 20: ma[index][0] = JSmoothOnArray(index,0,price[bar],period,1,cbars,bar); break;
   case 21: ma[index][0] = SMA_eqOnArray(price,MA,period,cbars,bar); break;
   case 22: ma[index][0] = ALMAOnArray(price,period,0.85,8,bar); break;
   case 23: ma[index][0] = TEMAOnArray(index,price[bar],period,1,cbars,bar); break;
   case 24: ma[index][0] = T3OnArray(index,0,price[bar],period,0.7,cbars,bar); break;
   case 25: ma[index][0] = LaguerreOnArray(index,price[bar],period,4,cbars,bar); break;
   case 26: ma[index][0] = McGinleyOnArray(price[bar],ma[index][1],period,cbars,bar); break;
   case 27: ma[index][0] = BF2POnArray(price,MA,period,cbars,bar); break;
   case 28: ma[index][0] = BF3POnArray(price,MA,period,cbars,bar); break;
   case 29: ma[index][0] = SuperSmuOnArray(price,MA,period,cbars,bar); break;
   default: ma[index][0] = SMAOnArray(price,period,bar); break;
   }
   
   return(ma[index][0]);
}

// MA_Method=0: SMA - Simple Moving Average
double SMAOnArray(double& array[],int per,int bar)
{
   double sum = 0;
   for(int i=0;i<per;i++) sum += array[bar+i];
   
   return(sum/per);
}                
// MA_Method=1: EMA - Exponential Moving Average
double EMAOnArray(double price,double prev,int per,int cbars,int bar)
{
   if(bar >= cbars - 2) double ema = price;
   else 
   ema = prev + 2.0/(1 + per)*(price - prev); 
   
   return(ema);
}
// MA_Method=2: Wilder - Wilder Exponential Moving Average
double WilderOnArray(double price,double prev,int per,int cbars,int bar)
{
   if(bar >= cbars - 2) double wilder = price; 
   else 
   wilder = prev + (price - prev)/per; 
   
   return(wilder);
}

// MA_Method=3: LWMA - Linear Weighted Moving Average 
double LWMAOnArray(double& array[],int per,int bar)
{
   double sum = 0, weight = 0;
   
      for(int i=0;i<per;i++)
      { 
      weight += (per - i);
      sum    += array[bar+i]*(per - i);
      }
   
   if(weight > 0) return(sum/weight); else return(0); 
} 

// MA_Method=4: SineWMA - Sine Weighted Moving Average
double SineWMAOnArray(double& array[],int per,int bar)
{
   double sum = 0, weight = 0;
  
      for(int i=0;i<per;i++)
      { 
      weight += MathSin(pi*(i + 1)/(per + 1));
      sum    += array[bar+i]*MathSin(pi*(i + 1)/(per + 1)); 
      }
   
   if(weight > 0) return(sum/weight); else return(0); 
}

// MA_Method=5: TriMA - Triangular Moving Average
double TriMAOnArray(double& array[],int per,int bar)
{
   int len = MathCeil((per + 1)*0.5);
   double sum = 0;
   
   for(int i=0;i<len;i++) sum += SMAOnArray(array,len,bar+i);
         
   return(sum/len);
}

// MA_Method=6: LSMA - Least Square Moving Average (or EPMA, Linear Regression Line)
double LSMAOnArray(double& array[],int per,int bar)
{   
   double sum = 0;
   
   for(int i=per;i>=1;i--) sum += (i - (per + 1)/3.0)*array[bar+per-i];
   
   return(sum*6/(per*(per + 1)));
}

// MA_Method=7: SMMA - Smoothed Moving Average
double SMMAOnArray(double& array[],double prev,int per,int cbars,int bar)
{
   if(bar == cbars - per) double smma = SMAOnArray(array,per,bar);
   else 
   if(bar  < cbars - per)
   {
   double sum = 0;
   for(int i=0;i<per;i++) sum += array[bar+i+1];
   smma = (sum - prev + array[bar])/per;
   }
   
   return(smma);
}                

// MA_Method=8: HMA - Hull Moving Average by Alan Hull
double HMAOnArray(double& array[],int per,int cbars,int bar)
{
   double _tmp[];
   int len = MathSqrt(per);
   
   ArrayResize(_tmp,len);
   
   if(bar == cbars - per) double hma = array[bar]; 
   else
   if(bar < cbars - per)
   {
   for(int i=0;i<len;i++) _tmp[i] = 2*LWMAOnArray(array,per/2,bar+i) - LWMAOnArray(array,per,bar+i);  
   hma = LWMAOnArray(_tmp,len,0); 
   }  

   return(hma);
}

// MA_Method=9: ZeroLagEMA - Zero-Lag Exponential Moving Average
double ZeroLagEMAOnArray(double& price[],double prev,int per,int cbars,int bar)
{
   int lag = 0.5*(per - 1); 
   double alpha = 2.0/(1 + per); 
      
   if(bar >= cbars - lag) double zema = price[bar];
   else 
   zema = alpha*(2*price[bar] - price[bar+lag]) + (1 - alpha)*prev;
   
   return(zema);
}

// MA_Method=10: DEMA - Double Exponential Moving Average by Patrick Mulloy
double DEMAOnArray(int index,int num,double price,double per,double v,int cbars,int bar)
{
   double alpha = 2.0/(1 + per);
   
   if(bar == cbars - 2) {double dema = price; tmp[num][index][0] = dema; tmp[num+1][index][0] = dema;}
   else 
   if(bar <  cbars - 2) 
   {
   tmp[num  ][index][0] = tmp[num  ][index][1] + alpha*(price              - tmp[num  ][index][1]); 
   tmp[num+1][index][0] = tmp[num+1][index][1] + alpha*(tmp[num][index][0] - tmp[num+1][index][1]); 
   dema                 = tmp[num  ][index][0]*(1+v) - tmp[num+1][index][0]*v;
   }
   
   return(dema);
}

// MA_Method=11: T3 by T.Tillson
double T3_basicOnArray(int index,int num,double price,int per,double v,int cbars,int bar)
{
   double dema1, dema2;
   
   if(bar == cbars - 2) 
   {
   double T3 = price; 
   for(int k=0;k<6;k++) tmp[num+k][index][0] = price;
   }
   else 
   if(bar < cbars - 2) 
   {
   dema1 = DEMAOnArray(index,num  ,price,per,v,cbars,bar); 
   dema2 = DEMAOnArray(index,num+2,dema1,per,v,cbars,bar); 
   T3    = DEMAOnArray(index,num+4,dema2,per,v,cbars,bar);
   }
   
   return(T3);
}

// MA_Method=12: ITrend - Instantaneous Trendline by J.Ehlers
double ITrendOnArray(double& price[],double& array[],int per,int cbars,int bar)
{
   double alpha = 2.0/(per + 1);
   if(bar < cbars - 7) double it = (alpha - 0.25*alpha*alpha)*price[bar] + 0.5*alpha*alpha*price[bar+1] 
                                 - (alpha - 0.75*alpha*alpha)*price[bar+2] + 2*(1 - alpha)*array[1] 
                                 - (1 - alpha)*(1 - alpha)*array[2];
   else it = (price[bar] + 2*price[bar+1] + price[bar+2])/4;
   
   return(it);
}
// MA_Method=13: Median - Moving Median
double MedianOnArray(double& price[],int per,int bar)
{
   double array[];
   ArrayResize(array,per);
   
   for(int i=0;i<per;i++) array[i] = price[bar+i];
   ArraySort(array,WHOLE_ARRAY,0,MODE_DESCEND);
   
   int num = MathRound((per - 1)*0.5); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num] + array[num+1]);
    
   return(median); 
}

// MA_Method=14: GeoMean - Geometric Mean
double GeoMeanOnArray(double& price[],int per,int cbars,int bar)
{
   if(bar < cbars - per)
   { 
   double gmean = MathPow(price[bar],1.0/per); 
   for(int i=1;i<per;i++) gmean *= MathPow(price[bar+i],1.0/per); 
   }
   else gmean = SMAOnArray(price,per,bar);
   
   return(gmean);
}

// MA_Method=15: REMA - Regularized EMA by Chris Satchwell 
double REMAOnArray(double price,double& array[],int per,double lambda,int cbars,int bar)
{
   double alpha =  2.0/(per + 1);
   
   if(bar >= cbars - 3) double rema = price;
   else 
   rema = (array[1]*(1 + 2*lambda) + alpha*(price - array[1]) - lambda*array[2])/(1 + lambda); 
   
   return(rema);
}
// MA_Method=16: ILRS - Integral of Linear Regression Slope 
double ILRSOnArray(double& price[],int per,int bar)
{
   double sum  = per*(per - 1)*0.5;
   double sum2 = (per - 1)*per*(2*per - 1)/6.0;
     
   double sum1 = 0;
   double sumy = 0;
      for(int i=0;i<per;i++)
      { 
      sum1 += i*price[bar+i];
      sumy += price[bar+i];
      }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMAOnArray(price,per,bar);
   
   return(ilrs);
}
// MA_Method=17: IE/2 - Combination of LSMA and ILRS 
double IE2OnArray(double& price[],int per,int bar)
{
   double ie = 0.5*(ILRSOnArray(price,per,bar) + LSMAOnArray(price,per,bar));
      
   return(ie); 
}
 
// MA_Method=18: TriMAgen - Triangular Moving Average Generalized by J.Ehlers
double TriMA_genOnArray(double& array[],int per,int bar)
{
   int len1 = MathFloor((per + 1)*0.5);
   int len2 = MathCeil ((per + 1)*0.5);
   double sum = 0;
   
   for(int i = 0;i < len2;i++) sum += SMAOnArray(array,len1,bar+i);
   
   return(sum/len2);
}

// MA_Method=19: VWMA - Volume Weighted Moving Average 
double VWMAOnArray(double& array[],int per,int bar)
{
   double sum = 0, weight = 0;
   
      for(int i=0;i<per;i++)
      { 
      weight += Volume[bar+i];
      sum    += array[bar+i]*Volume[bar+i];
      }
   
   if(weight > 0) return(sum/weight); else return(0); 
} 

// MA_Method=20: JSmooth - Smoothing by Mark Jurik
double JSmoothOnArray(int index,int num,double price,int per,double power,int cbars,int bar)
{
   double beta  = 0.45*(per - 1)/(0.45*(per - 1) + 2);
	double alpha = MathPow(beta,power);
	
	if(bar == cbars - 2) {tmp[num+4][index][0] = price; tmp[num+0][index][0] = price; tmp[num+2][index][0] = price;}
	else 
   if(bar <  cbars - 2) 
   {
	tmp[num+0][index][0] = (1 - alpha)*price + alpha*tmp[num+0][index][1];
	tmp[num+1][index][0] = (price - tmp[num+0][index][0])*(1-beta) + beta*tmp[num+1][index][1];
	tmp[num+2][index][0] = tmp[num+0][index][0] + tmp[num+1][index][0];
	tmp[num+3][index][0] = (tmp[num+2][index][0] - tmp[num+4][index][1])*MathPow((1-alpha),2) + MathPow(alpha,2)*tmp[num+3][index][1];
	tmp[num+4][index][0] = tmp[num+4][index][1] + tmp[num+3][index][0]; 
   }
   return(tmp[num+4][index][0]);
}

// MA_Method=21: SMA_eq     - Simplified SMA
double SMA_eqOnArray(double& price[],double& array[],int per,int cbars,int bar)
{
   if(bar == cbars - per) double sma = SMAOnArray(price,per,bar);
   else 
   if(bar <  cbars - per) sma = (price[bar] - price[bar+per])/per + array[1]; 
   
   return(sma);
}                        		

// MA_Method=22: ALMA by Arnaud Legoux / Dimitris Kouzis-Loukas / Anthony Cascino
double ALMAOnArray(double& price[],int per,double offset,double sigma,int bar)
{
   double m = MathFloor(offset*(per - 1)), s = per/sigma, w, sum = 0, wsum = 0;		
	
	for (int i=0;i<per;i++) 
	{
	w     = MathExp(-((i - m)*(i - m))/(2*s*s));
   wsum += w;
   sum  += price[bar+(per-1-i)]*w; 
   }
   
   if(wsum != 0) return(sum/wsum); else return(0);
}   

// MA_Method=23: TEMA - Triple Exponential Moving Average by Patrick Mulloy
double TEMAOnArray(int index,double price,int per,double v,int cbars,int bar)
{
   double alpha = 2.0/(per+1);
	
	if(bar == cbars - 2) {tmp[0][index][0] = price; tmp[1][index][0] = price; tmp[2][index][0] = price;}
	else 
   if(bar <  cbars - 2) 
   {
	tmp[0][index][0] = tmp[0][index][1] + alpha *(price            - tmp[0][index][1]);
	tmp[1][index][0] = tmp[1][index][1] + alpha *(tmp[0][index][0] - tmp[1][index][1]);
	tmp[2][index][0] = tmp[2][index][1] + alpha *(tmp[1][index][0] - tmp[2][index][1]);
	tmp[3][index][0] = tmp[0][index][0] + v*(tmp[0][index][0] + v*(tmp[0][index][0]-tmp[1][index][0]) - tmp[1][index][0] - v*(tmp[1][index][0] - tmp[2][index][0])); 
	}
   
   return(tmp[3][index][0]);
}

// MA_Method=24: T3 by T.Tillson (correct version) 
double T3OnArray(int index,int num,double price,int per,double v,int cbars,int bar)
{
   double len = MathMax((per + 5.0)/3.0 - 1,1), dema1, dema2;
   
   if(bar == cbars - 2) 
   {
   double T3 = price; 
   for(int k=0;k<6;k++) tmp[num+k][index][0] = T3;
   }
   else 
   if(bar < cbars - 2) 
   {
   dema1 = DEMAOnArray(index,num  ,price,len,v,cbars,bar); 
   dema2 = DEMAOnArray(index,num+2,dema1,len,v,cbars,bar); 
   T3    = DEMAOnArray(index,num+4,dema2,len,v,cbars,bar);
   }
      
   return(T3);
}

// MA_Method=25: Laguerre filter by J.Ehlers
double LaguerreOnArray(int index,double price,int per,int order,int cbars,int bar)
{
   double gamma = 1 - 10.0/(per + 9);
   double aPrice[];
   
   ArrayResize(aPrice,order);
   
   for(int i=0;i<order;i++)
   {
      if(bar >= cbars - order) tmp[i][index][0] = price;
      else
      {
         if(i == 0) tmp[i][index][0] = (1 - gamma)*price + gamma*tmp[i][index][1];
         else
         tmp[i][index][0] = -gamma * tmp[i-1][index][0] + tmp[i-1][index][1] + gamma * tmp[i][index][1];
      
      aPrice[i] = tmp[i][index][0];
      }
   }
   double laguerre = TriMA_genOnArray(aPrice,order,0);  

   return(laguerre);
}

// MA_Method=26:  MD - McGinley Dynamic
double McGinleyOnArray(double price,double prev,int per,int cbars,int bar)
{
   if(bar == cbars - 2) double md = price;
   else 
   if(bar <  cbars - 2) 
      if(prev != 0) md = prev + (price - prev)/(per*MathPow(price/prev,4)/2); 
      else md = price;

   return(md);
}

// MA_Method=27: BF2P - Two-pole modified Butterworth filter
double BF2POnArray(double& price[],double& array[],int per,int cbars,int bar)
{
   double a  = MathExp(-1.414*pi/per);
   double b  = 2*a*MathCos(1.414*1.25*pi/per);
   double c2 = b;
   double c3 = -a*a;
   double c1 = 1 - c2 - c3;
   
   if(bar < cbars - 7) double bf2p = c1*(price[bar] + 2*price[bar+1] + price[bar+2])/4 + c2*array[1] + c3*array[2];
   else bf2p = (price[bar] + 2*price[bar+1] + price[bar+2])/4;
   
   return(bf2p);
}

// MA_Method=28: BF3P - Three-pole modified Butterworth filter
double BF3POnArray(double& price[],double& array[],int per,int cbars,int bar)
{
   double a  = MathExp(-pi/per);
   double b  = 2*a*MathCos(1.738*pi/per);
   double c  = a*a;
   double d2 = b + c;
   double d3 = -(c + b*c);
   double d4 = c*c;
   double d1 = 1 - d2 - d3 - d4;
   
   if(bar < cbars - 7) double bf3p = d1*(price[bar] + 3*price[bar+1] + 3*price[bar+2] + price[bar+3])/8 + d2*array[1] + d3*array[2] + d4*array[3];
   else bf3p = (price[bar] + 3*price[bar+1] + 3*price[bar+2] + price[bar+3])/8;
   
   return(bf3p);
}

// MA_Method=29: SuperSmu - SuperSmoother filter
double SuperSmuOnArray(double& price[],double& array[],int per,int cbars,int bar)
{
   double a  = MathExp(-1.414*pi/per);
   double b  = 2*a*MathCos(1.414*pi/per);
   double c2 = b;
   double c3 = -a*a;
   double c1 = 1 - c2 - c3;
   
   if(bar < cbars - 7) double supsm = c1*(price[bar] + price[bar+1])/2 + c2*array[1] + c3*array[2];
   else supsm = (price[bar] + price[bar+1])/2;
   
   return(supsm);
}

// HeikenAshi Price
datetime prevhatime;  

double HeikenAshi(int price,int cbars,int bar)
{ 
   if(prevhatime != Time[bar])
   {
   haClose[1] = haClose[0];
   haOpen [1] = haOpen [0];
   haHigh [1] = haHigh [0];
   haLow  [1] = haLow  [0];
   prevhatime = Time[bar];
   }
   
   if(bar == cbars - 1) 
   {
   haClose[0] = Close[bar];
   haOpen [0] = Open [bar];
   haHigh [0] = High [bar];
   haLow  [0] = Low  [bar];
   }
   else
   {
   haClose[0] = (Open[bar] + High[bar] + Low[bar] + Close[bar])/4;
   haOpen [0] = (haOpen[1] + haClose[1])/2;
   haHigh [0] = MathMax(High[bar],MathMax(haOpen[0],haClose[0]));
   haLow  [0] = MathMin(Low [bar],MathMin(haOpen[0],haClose[0]));
   }
   
   switch(price)
   {
   case  0: return(haClose[0]); break;
   case  1: return(haOpen [0]); break;
   case  2: return(haHigh [0]); break;
   case  3: return(haLow  [0]); break;
   case  4: return((haHigh[0] + haLow[0])/2); break;
   case  5: return((haHigh[0] + haLow[0] +   haClose[0])/3); break;
   case  6: return((haHigh[0] + haLow[0] + 2*haClose[0])/4); break;
   default: return(haClose[0]); break;
   }
}

datetime prevnbtime;

bool isNewBar(int tf)
{
   bool res = false;
   
   if(tf >= 0)
   {
      if(iTime(NULL,tf,0) != prevnbtime)
      {
      res   = true;
      prevnbtime = iTime(NULL,tf,0);
      }   
   }
   else res = true;
   
   return(res);
}

string prevmess;
 
bool BoxAlert(bool cond,string text)   
{      
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text;
   
   if (cond && mess != prevmess)
	{
	Alert (mess);
	prevmess = mess; 
	return(true);
	} 
  
   return(false);  
}

datetime pausetime;

bool Pause(int sec)
{
   if(TimeCurrent() >= pausetime + sec) {pausetime = TimeCurrent(); return(true);}
   
   return(false);
}

datetime warningtime;

void WarningSound(bool cond,int num,int sec,string sound,datetime curtime)
{
   static int i;
   
   if(cond)
   {
   if(curtime != warningtime) i = 0; 
   if(i < num && Pause(sec)) {PlaySound(sound); warningtime = curtime; i++;}       	
   }
}

string prevemail;

bool EmailAlert(bool cond,string text1,string text2,int num)   
{      
   string subj = "New " + text1 +" Signal from " + IndicatorName + "!!!";    
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text2;
   
   if (cond && mess != prevemail)
	{
	if(subj != "" && mess != "") for(int i=0;i<num;i++) SendMail(subj, mess);  
	prevemail = mess; 
	return(true);
	} 
  
   return(false);  
}



//+------------------------------------------------------------------+
//|                                             AllAverages_v2.2.mq4 |
//|                             Copyright © 2007-08, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
// List of MAs:
// MA_Method= 0: SMA        - Simple Moving Average
// MA_Method= 1: EMA        - Exponential Moving Average
// MA_Method= 2: Wilder     - Wilder Exponential Moving Average
// MA_Method= 3: LWMA       - Linear Weighted Moving Average 
// MA_Method= 4: SineWMA    - Sine Weighted Moving Average
// MA_Method= 5: TriMA      - Triangular Moving Average
// MA_Method= 6: LSMA       - Least Square Moving Average (or EPMA, Linear Regression Line)
// MA_Method= 7: SMMA       - Smoothed Moving Average
// MA_Method= 8: HMA        - Hull Moving Average by Alan Hull
// MA_Method= 9: ZeroLagEMA - Zero-Lag Exponential Moving Average
// MA_Method=10: DEMA       - Double Exponential Moving Average by Patrick Mulloy
// MA_Method=11: T3         - T3 by T.Tillson
// MA_Method=12: ITrend     - Instantaneous Trendline by J.Ehlers
// MA_Method=13: Median     - Moving Median
// MA_Method=14: GeoMean    - Geometric Mean
// MA_Method=15: REMA       - Regularized EMA by Chris Satchwell
// MA_Method=16: ILRS       - Integral of Linear Regression Slope 
// MA_Method=17: IE/2       - Combination of LSMA and ILRS 
// MA_Method=18: TriMAgen   - Triangular Moving Average generalized by J.Ehlers
// MA_Method=19: VWMA       - Volume Weighted Moving Average 
// List of Prices:
// Price    = 0 - Close  
// Price    = 1 - Open  
// Price    = 2 - High  
// Price    = 3 - Low  
// Price    = 4 - Median Price   = (High+Low)/2  
// Price    = 5 - Typical Price  = (High+Low+Close)/3  
// Price    = 6 - Weighted Close = (High+Low+Close*2)/4
// Price    = 7 - Heiken Ashi Close  
// Price    = 8 - Heiken Ashi Open
// Price    = 9 - Heiken Ashi High
// Price    =10 - Heiken Ashi Low
 
#property copyright "Copyright © 2007-08, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

//#property indicator_chart_window
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  Yellow
#property indicator_width1  2  
#property indicator_color2  DeepSkyBlue
#property indicator_width2  2  
#property indicator_color3  Tomato
#property indicator_width3  2  
//---- 
extern int TimeFrame    =  0;
extern int Price        =  0;
extern int MA_Period    = 14;
extern int MA_Shift     =  0;
extern int MA_Method    =  0;
extern int Color_Mode   =  0;
//---- 
double MA[];
double Up[];
double Dn[];
//----
double tmp[][6];
double haClose[], haOpen[], haHigh[], haLow[];
int    draw_begin, mBars, pBars, mcnt_bars; 
string short_name;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- 
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   if(TimeFrame == 0 || TimeFrame < Period()) TimeFrame = Period();
   SetIndexShift(0,MA_Shift*TimeFrame/Period());
   SetIndexShift(1,MA_Shift*TimeFrame/Period());
   SetIndexShift(2,MA_Shift*TimeFrame/Period());
   draw_begin=MA_Period*TimeFrame/Period();
//---- 
   switch(MA_Method)
   {
   case 1 : short_name="EMA(";  break;
   case 2 : short_name="Wilder("; break;
   case 3 : short_name="LWMA("; break;
   case 4 : short_name="SineWMA("; break;
   case 5 : short_name="TriMA("; break;
   case 6 : short_name="LSMA("; break;
   case 7 : short_name="SMMA("; break;
   case 8 : short_name="HMA("; break;
   case 9 : short_name="ZeroLagEMA("; break;
   case 10: short_name="DEMA(";  break;
   case 11: short_name="T3(";  break;
   case 12: short_name="InstTrend(";  break;
   case 13: short_name="Median(";  break;
   case 14: short_name="GeometricMean("; break;
   case 15: short_name="REMA(";  break;
   case 16: short_name="ILRS(";  break;
   case 17: short_name="IE/2(";  break;
   case 18: short_name="TriMA_gen("; break;
   case 19: short_name="VWMA("; break;
   default: MA_Method=0; short_name="SMA(";
   }
   
   switch(TimeFrame)
   {
   case 1     : string TF = "M1"; break;
   case 5     : TF = "M5"; break;
   case 15    : TF = "M15"; break;
   case 30    : TF = "M30"; break;
   case 60    : TF = "H1"; break;
   case 240   : TF ="H4"; break;
   case 1440  : TF="D1"; break;
   case 10080 : TF="W1"; break;
   case 43200 : TF="MN1"; break;
   default    : TF="Current";
   } 
   
   IndicatorShortName(short_name+MA_Period+")"+" "+TF);
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexLabel(0,short_name+MA_Period+")"+" "+TF);
   SetIndexLabel(1,short_name+MA_Period+")"+" "+TF+" UpTrend");
   SetIndexLabel(2,short_name+MA_Period+")"+" "+TF+" DnTrend");
//---- 
   SetIndexBuffer(0,MA);
   SetIndexBuffer(1,Up);
   SetIndexBuffer(2,Dn);
//---- 
   return(0);
}
//+------------------------------------------------------------------+
//| AllAverages_v2.2                                                 |
//+------------------------------------------------------------------+
int start()
{
   int limit, y, i, shift, cnt_bars=IndicatorCounted(); 
   double aPrice[], mMA[], mUp[], mDn[];
  
   if(TimeFrame!=Period()) mBars = iBars(NULL,TimeFrame); else mBars = Bars;   
   
   if(mBars != pBars)
   {
   ArrayResize(aPrice,mBars);
   ArrayResize(mMA,mBars);
   if(MA_Method==10 || MA_Method==11) ArrayResize(tmp,mBars);
      if(Color_Mode ==1)
      {
      ArrayResize(mUp,mBars);
      ArrayResize(mDn,mBars);
      }
      if(Price > 6 && Price <= 10)
      {
      ArrayResize(haClose,mBars);
      ArrayResize(haOpen,mBars);
      ArrayResize(haHigh,mBars);
      ArrayResize(haLow,mBars);
      }
   pBars = mBars;
   }  
   
   if(cnt_bars<1)
   {
      for(i=1;i<=draw_begin;i++)
      { 
      MA[Bars-i]=iMA(NULL,TimeFrame,1,0,0,Price,Bars-i); 
      Up[Bars-i]=EMPTY_VALUE;
      Dn[Bars-i]=EMPTY_VALUE;
      }
   mcnt_bars = 0;
   
   }
//---- 
   if(mcnt_bars > 0) mcnt_bars--;
   
   for(y=mcnt_bars;y<mBars;y++)
   {
      if(Price <= 6) aPrice[y] = iMA(NULL,TimeFrame,1,0,0,Price,mBars-y-1);   
      else
      if(Price > 6 && Price <= 10) aPrice[y] = HeikenAshi(TimeFrame,Price-7,mBars-y-1);
      
      switch(MA_Method)
      {
      case 1 : mMA[y] = EMA(aPrice[y],mMA,MA_Period,y); break;
      case 2 : mMA[y] = Wilder(aPrice,mMA,MA_Period,y); break;  
      case 3 : mMA[y] = LWMA(aPrice,MA_Period,y); break;
      case 4 : mMA[y] = SineWMA(aPrice,MA_Period,y); break;
      case 5 : mMA[y] = TriMA(aPrice,MA_Period,y); break;
      case 6 : mMA[y] = LSMA(aPrice,MA_Period,y); break;
      case 7 : mMA[y] = SMMA(aPrice,mMA,MA_Period,y); break;
      case 8 : mMA[y] = HMA(aPrice,MA_Period,y); break;
      case 9 : mMA[y] = ZeroLagEMA(aPrice,mMA,MA_Period,y); break;
      case 10: mMA[y] = DEMA(0,aPrice[y],MA_Period,1,y); break;
      case 11: mMA[y] = T3(aPrice[y],MA_Period,0.7,y); break;
      case 12: mMA[y] = ITrend(aPrice,mMA,MA_Period,y); break;
      case 13: mMA[y] = Median(aPrice,MA_Period,y); break;
      case 14: mMA[y] = GeoMean(aPrice,MA_Period,y); break;
      case 15: mMA[y] = REMA(aPrice[y],mMA,MA_Period,0.5,y); break;
      case 16: mMA[y] = ILRS(aPrice,MA_Period,y); break;
      case 17: mMA[y] = IE2(aPrice,MA_Period,y); break;
      case 18: mMA[y] = TriMA_gen(aPrice,MA_Period,y); break;
      case 19: mMA[y] = VWMA(aPrice,MA_Period,y); break;
      default: mMA[y] = SMA(aPrice,MA_Period,y); break;
      }
   
      if(Color_Mode == 1)
      {
         if(mMA[y] > mMA[y-1]) {mUp[y] = mMA[y]; mDn[y] = EMPTY_VALUE;}
         else
         if(mMA[y] < mMA[y-1]) {mUp[y] = EMPTY_VALUE; mDn[y] = mMA[y];}
         else
         {mUp[y] = EMPTY_VALUE; mDn[y] = EMPTY_VALUE;}
      }
   
      if(TimeFrame == Period()) 
      {
      MA[mBars-y-1] = mMA[y];
         if(Color_Mode == 1)
         {  
         Up[mBars-y-1] = mUp[y];
         Dn[mBars-y-1] = mDn[y];
         }
      }
      
   }
   mcnt_bars = mBars-1;
   
   if(TimeFrame > Period())
   { 
      if(cnt_bars>0) cnt_bars--;
      limit = Bars-cnt_bars+TimeFrame/Period()-1;
      
      for(shift=0,y=0;shift<limit;shift++)
      {
      if (Time[shift] < iTime(NULL,TimeFrame,y)) y++; 
      MA[shift] = mMA[mBars-y-1];
         if(Color_Mode == 1)
         {
         Up[shift] = mUp[mBars-y-1];
         Dn[shift] = mDn[mBars-y-1];
         }
      }
   }
   
//---- 
   return(0);
}

// MA_Method=0: SMA - Simple Moving Average
double SMA(double array[],int per,int bar)
{
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar-i];
   
   return(Sum/per);
}                
// MA_Method=1: EMA - Exponential Moving Average
double EMA(double price,double array[],int per,int bar)
{
   if(bar == 2) double ema = price;
   else 
   if(bar > 2) ema = array[bar-1] + 2.0/(1+per)*(price - array[bar-1]); 
   
   return(ema);
}
// MA_Method=2: Wilder - Wilder Exponential Moving Average
double Wilder(double array1[],double array2[],int per,int bar)
{
   if(bar == per) double wilder = SMA(array1,per,bar);
   else 
   if(bar > per) wilder = array2[bar-1] + (array1[bar] - array2[bar-1])/per; 
   
   return(wilder);
}
// MA_Method=3: LWMA - Linear Weighted Moving Average 
double LWMA(double array[],int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= (per - i);
      Sum += array[bar-i]*(per - i);
      }
   if(Weight>0) double lwma = Sum/Weight;
   else lwma = 0; 
   return(lwma);
} 
// MA_Method=4: SineWMA - Sine Weighted Moving Average
double SineWMA(double array[],int per,int bar)
{
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
  
      for(int i = 0;i < per-1;i++)
      { 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar-i]*MathSin(pi*(i+1)/(per+1)); 
      }
   if(Weight>0) double swma = Sum/Weight;
   else swma = 0; 
   return(swma);
}
// MA_Method=5: TriMA - Triangular Moving Average
double TriMA(double array[],int per,int bar)
{
   double sma;
   int len = MathCeil((per+1)*0.5);
   
   double sum=0;
   for(int i = 0;i < len;i++) 
   {
   sma = SMA(array,len,bar-i);
   sum += sma;
   } 
   double trima = sum/len;
   
   return(trima);
}
// MA_Method=6: LSMA - Least Square Moving Average (or EPMA, Linear Regression Line)
double LSMA(double array[],int per,int bar)
{   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar-per+i];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}
// MA_Method=7: SMMA - Smoothed Moving Average
double SMMA(double array1[],double array2[],int per,int bar)
{
   if(bar == per) double smma = SMA(array1,per,bar);
   else 
   if(bar > per)
   {
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array1[bar-i-1];
   smma = (Sum - array2[bar-1] + array1[bar])/per;
   }
   return(smma);
}                
// MA_Method=8: HMA - Hull Moving Average by Alan Hull
double HMA(double array[],int per,int bar)
{
   double tmp[];
   int len =  MathSqrt(per);
   ArrayResize(tmp,len);
   
   if(bar == per) double hma = array[bar]; 
   else
   if(bar > per)
   {
   for(int i = 0; i < len;i++) tmp[len-i-1] = 2*LWMA(array,per/2,bar-i) - LWMA(array,per,bar-i);  
   hma = LWMA(tmp,len,len-1); 
   }  

   return(hma);
}
// MA_Method=9: ZeroLagEMA - Zero-Lag Exponential Moving Average
double ZeroLagEMA(double array1[],double array2[],int per,int bar)
{
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   
   if(bar == lag) double zema = array1[bar];
   else 
   if(bar > lag) zema = alfa*(2*array1[bar] - array1[bar-lag]) + (1-alfa)*array2[bar-1];
   
   return(zema);
}
// MA_Method=10: DEMA - Double Exponential Moving Average by Patrick Mulloy
double DEMA(int num,double price,int per,double v,int bar)
{
   if(bar == 2) {double dema = price; tmp[bar][num] = dema; tmp[bar][num+1] = dema;}
   else 
   if(bar > 2) 
   {
   tmp[bar][num] = tmp[bar-1][num] + 2.0/(1+per)*(price - tmp[bar-1][num]); 
   tmp[bar][num+1] = tmp[bar-1][num+1] + 2.0/(1+per)*(tmp[bar][num] - tmp[bar-1][num+1]); 
   dema = (1+v)*tmp[bar][num] - v*tmp[bar][num+1];
   }
   return(dema);
}
// MA_Method=11: T3 by T.Tillson
double T3(double price,int per,double v,int bar)
{
   if(bar == 2) 
   {
   double T3 = price; 
   for(int k=0;k<=5;k++) tmp[bar][k] = T3;
   }
   else 
   if(bar > 2) 
   {
   double dema1 = DEMA(0,price,per,v,bar); 
   double dema2 = DEMA(2,dema1,per,v,bar); 
   T3 = DEMA(4,dema2,per,v,bar);
   }
   return(T3);
}
// MA_Method=12: ITrend - Instantaneous Trendline by J.Ehlers
double ITrend(double price[],double array[],int per,int bar)
{
   double alfa = 2.0/(per+1);
   if(bar > 7)
   double it = (alfa - alfa*alfa/4)*price[bar]+ 0.5*alfa*alfa*price[bar-1]-(alfa - 0.75*alfa*alfa)*price[bar-2]+
   2*(1-alfa)*array[bar-1] - (1-alfa)*(1-alfa)*array[bar-2];
   else
   it = (price[bar] + 2*price[bar-1]+ price[bar-2])/4;
   
   return(it);
}
// MA_Method=13: Median - Moving Median
double Median(double price[],int per,int bar)
{
   double array[];
   ArrayResize(array,per);
   
   for(int i = 0; i < per;i++) array[i] = price[bar-i];
   ArraySort(array);
   
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2)>0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
   
   return(median); 
}
// MA_Method=14: GeoMean - Geometric Mean
double GeoMean(double price[],int per,int bar)
{
   double gmean = MathPow(price[bar],1.0/per); 
   for(int i = 1; i < per;i++) gmean *= MathPow(price[bar-i],1.0/per); 
   
   return(gmean);
}
// MA_Method=15: REMA - Regularized EMA by Chris Satchwell 
double REMA(double price,double array[],int per,double lambda,int bar)
{
   double alpha =  2.0/(per + 1);
   if(bar <= 3) double rema = price;
   else 
   if(bar > 3) 
   rema = (array[bar-1]*(1+2*lambda) + alpha*(price - array[bar-1]) - lambda*array[bar-2])/(1+lambda); 
   
   return(rema);
}
// MA_Method=16: ILRS - Integral of Linear Regression Slope 
double ILRS(double price[],int per,int bar)
{
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
     
   double sum1 = 0;
   double sumy = 0;
      for(int i=0;i<per;i++)
      { 
      sum1 += i*price[bar-i];
      sumy += price[bar-i];
      }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMA(price,per,bar);
   
   return(ilrs);
}
// MA_Method=17: IE/2 - Combination of LSMA and ILRS 
double IE2(double price[],int per,int bar)
{
   double ie = 0.5*(ILRS(price,per,bar) + LSMA(price,per,bar));
      
   return(ie); 
}
 
// MA_Method=18: TriMAgen - Triangular Moving Average Generalized by J.Ehlers
double TriMA_gen(double array[],int per,int bar)
{
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(array,len1,bar-i);
   double trimagen = sum/len2;
   
   return(trimagen);
}

// MA_Method=19: VWMA - Volume Weighted Moving Average 
double VWMA(double array[],int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= Volume[mBars-bar-1+i];
      Sum += array[bar-i]*Volume[mBars-bar-1+i];
      }
   if(Weight>0) double vwma = Sum/Weight;
   else vwma = 0; 
   return(vwma);
} 


double HeikenAshi(int tf,int price,int bar)
{ 
   if(bar == iBars(NULL,TimeFrame)- 1) 
   {
   haClose[bar] = iClose(NULL,tf,bar);
   haOpen[bar]  = iOpen(NULL,tf,bar);
   haHigh[bar]  = iHigh(NULL,tf,bar);
   haLow[bar]   = iLow(NULL,tf,bar);
   }
   else
   {
   haClose[bar] = (iOpen(NULL,tf,bar)+iHigh(NULL,tf,bar)+iLow(NULL,tf,bar)+iClose(NULL,tf,bar))/4;
   haOpen[bar]  = (haOpen[bar+1]+haClose[bar+1])/2;
   haHigh[bar]  = MathMax(iHigh(NULL,tf,bar),MathMax(haOpen[bar], haClose[bar]));
   haLow[bar]   = MathMin(iLow(NULL,tf,bar),MathMin(haOpen[bar], haClose[bar]));
   }
   
   switch(price)
   {
   case 0: return(haClose[bar]);break;
   case 1: return(haOpen[bar]);break;
   case 2: return(haHigh[bar]);break;
   case 3: return(haLow[bar]);break;
   }
}     
   
        		
//+------------------------------------------------------------------+
//|                                                                  |
//|                                                                  |
//|                                                                  |
//|                                                                  |
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
// MA_Method=11: T3_basic   - T3 by T.Tillson (original version)
// MA_Method=12: ITrend     - Instantaneous Trendline by J.Ehlers
// MA_Method=13: Median     - Moving Median
// MA_Method=14: GeoMean    - Geometric Mean
// MA_Method=15: REMA       - Regularized EMA by Chris Satchwell
// MA_Method=16: ILRS       - Integral of Linear Regression Slope 
// MA_Method=17: IE/2       - Combination of LSMA and ILRS 
// MA_Method=18: TriMAgen   - Triangular Moving Average generalized by J.Ehlers
// MA_Method=19: VWMA       - Volume Weighted Moving Average 
// MA_Method=20: JSmooth    - Smoothing by Mark Jurik
// MA_Method=21: SMA_eq     - Simplified SMA
// MA_Method=22: ALMA       - Arnaud Legoux Moving Average
// MA_Method=23: TEMA       - Triple Exponential Moving Average by Patrick Mulloy
// MA_Method=24: T3         - T3 by T.Tillson (correct version)
// MA_Method=25: Laguerre   - Laguerre filter by J.Ehlers

// List of Prices:
// Price    = 0 - Close  
// Price    = 1 - Open  
// Price    = 2 - High  
// Price    = 3 - Low  
// Price    = 4 - Median Price   = (High+Low)/2  
// Price    = 5 - Typical Price  = (High+Low+Close)/3  
// Price    = 6 - Weighted Close = (High+Low+Close*2)/4

 
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers   4
#property indicator_color1 RoyalBlue
#property indicator_color2 Coral
#property indicator_width1 1
#property indicator_width2 1
#property indicator_color3 RoyalBlue
#property indicator_color4 Coral
#property indicator_width3 3
#property indicator_width4 3




//---- indicator parameters

extern int     TimeFrame         =     0;    // TimeFrame in min
extern int     MathMode          =     1;    // Math method: 0-RSI;1-Stoch;2-DMI;3-MACD 
extern int     Price             =     0;    // Price = 0...10 (see List of Prices)
extern int     Length            =     9;    // Period of evaluation
extern int     PreSmooth         =     1;    // Period of PreSmoothing
extern int     Smooth            =     1;    // Period of smoothing
extern int     MA_Method         =     0;    // See list above
extern int     LevelsMode        =     0;    // Levels Mode: 0-Standard OverBought/OverSold 
                                             //              1-StdDev Bands
                                             //              2-High/Low Channel
extern double  StrengthLevel     =    70;    // Strength Level (ex.70)
extern double  WeaknessLevel     =    30;    // Weakness Level (ex.30)
extern int     LookBackPeriod    =    20;    // LookBack Period for LevelsMode=1,2 
extern double  UpperMultiplier   =     1;    // Upper Band Multiplier for LevelsMode=1 
extern double  LowerMultiplier   =     1;    // Lower Band Multiplier for LevelsMode=1 

extern string  alerts            = "--- Alerts & Emails ---";
extern int     AlertMode         =     0;
extern int     SoundsNumber      =     5;    // Number of sounds after Signal
extern int     SoundsPause       =     5;    // Pause in sec between sounds 
extern string  UpSound           = "alert.wav";
extern string  DnSound           = "alert2.wav";
extern int     EmailMode         =     0;    // 0-on,1-off   
extern int     EmailsNumber      =     1;    // 0-on,1-off
                                          

//---- indicator buffers
double upSignal[];
double dnSignal[];
double upTrend[];
double dnTrend[];
double Bulls[];
double Bears[];
double lbulls[];
double lbears[];
//----
double tmp[][8][2], ma[8][3], bulls[], bears[], mMA[2], mLo[2], smin[2], smax[2], HiArray[], LoArray[];
int    draw_begin, masize, trend[3];

string TF, IndicatorName, short_name, math_name, price_name, maname, zone_name, prevmess, prevemail;

double upsum, dnsum, _point;
datetime prevtime[8], ptime, preTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if(TimeFrame <= Period()) TimeFrame = Period();
   TF = tf(TimeFrame);
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));

//---- indicator buffers mapping
   IndicatorBuffers(8);
   SetIndexBuffer(0,upSignal); SetIndexStyle(0,    DRAW_ARROW); SetIndexArrow(0,108);
   SetIndexBuffer(1,dnSignal); SetIndexStyle(1,    DRAW_ARROW); SetIndexArrow(1,108);
   SetIndexBuffer(2, upTrend); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3, dnTrend); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,   Bulls);
   SetIndexBuffer(5,   Bears); 
   SetIndexBuffer(6,  lbulls);
   SetIndexBuffer(7,  lbears);   
        
//---- indicator name
   switch(Price)
   {
   case 0 : price_name = "Close";   break;
   case 1 : price_name = "Open";    break;
   case 2 : price_name = "High";    break;
   case 3 : price_name = "Low";     break;
   case 4 : price_name = "Median";  break;
   case 5 : price_name = "Typical"; break;
   case 6 : price_name = "Weighted Close"; break;
   }
   
   
   switch(MathMode)
   {
   case 0 : math_name = "RSI";  break;
   case 1 : math_name = "Stoch"; break;
   case 2 : math_name = "DMI"; break;
   }
     
   
   maname = averageName(MA_Method, masize);
   
   IndicatorName = WindowExpertName(); 
   
   short_name =  "[" + TF + "]("+ math_name + "," + price_name + "," + Length + "," + PreSmooth + "," + Smooth + "," + maname + "," + LevelsMode+")";
   
   IndicatorShortName(IndicatorName + short_name);
           
   SetIndexLabel(0,"upSignal");
   SetIndexLabel(1,"dnSignal");
   SetIndexLabel(2,"upTrend");
   SetIndexLabel(3,"dnTrend");     
   
   draw_begin = Bars - iBars(NULL,TimeFrame)*TimeFrame/Period() + Length + PreSmooth + Smooth + LookBackPeriod;
   
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
//----
    ArrayResize(tmp    ,       masize);
   ArrayResize(HiArray,LookBackPeriod);
   ArrayResize(LoArray,LookBackPeriod);
   
   _point   = MarketInfo(Symbol(),MODE_POINT)*MathPow(10,Digits%2);
//---- initialization done
   
   return(0);
}

int deinit() {Comment(""); return(0);}

//+------------------------------------------------------------------+
//| AllAbsoluteStrengthTrend_v1                                      |
//+------------------------------------------------------------------+
int start()
{
   int    limit, i, shift, counted_bars = IndicatorCounted(); 
   
   
   if (counted_bars > 0)  limit=Bars-counted_bars-1;
   if (counted_bars < 0)  return(0);
   if (counted_bars < 1)
   { 
   limit = Bars-1;   
      for(i=limit;i>=0;i--) 
      {
      upSignal[i] = EMPTY_VALUE; 
      dnSignal[i] = EMPTY_VALUE; 
      upTrend[i]  = EMPTY_VALUE; 
      dnTrend[i]  = EMPTY_VALUE;
      }
   }   
   
   if(TimeFrame != Period())
	{
   limit = MathMax(limit,TimeFrame/Period());   
      
      for(shift = 0;shift < limit;shift++) 
      {	
      int y = iBarShift(NULL,TimeFrame,Time[shift]);
      
      
      upSignal[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,MathMode,Price,Length,PreSmooth,Smooth,MA_Method,LevelsMode,StrengthLevel,WeaknessLevel,LookBackPeriod,UpperMultiplier,LowerMultiplier,
                                "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,0,y);      
      dnSignal[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,MathMode,Price,Length,PreSmooth,Smooth,MA_Method,LevelsMode,StrengthLevel,WeaknessLevel,LookBackPeriod,UpperMultiplier,LowerMultiplier,
                                "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,1,y);      
               
      upTrend[shift]  = iCustom(NULL,TimeFrame,IndicatorName,0,MathMode,Price,Length,PreSmooth,Smooth,MA_Method,LevelsMode,StrengthLevel,WeaknessLevel,LookBackPeriod,UpperMultiplier,LowerMultiplier,
                                "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,2,y);      
      dnTrend[shift]  = iCustom(NULL,TimeFrame,IndicatorName,0,MathMode,Price,Length,PreSmooth,Smooth,MA_Method,LevelsMode,StrengthLevel,WeaknessLevel,LookBackPeriod,UpperMultiplier,LowerMultiplier,
                                "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,3,y);      
     
      }  
	
	return(0);
	}
	else _AllAbsStrength(limit);

   return(0);
}


//-----
void _AllAbsStrength(int limit)
{   
   double   upPivot, dnPivot;
   
   if(ArraySize(bulls) != Bars) 
   {
   ArraySetAsSeries(bulls,false); ArraySetAsSeries(bears,false);
   ArrayResize(bulls,Bars); ArrayResize(bears,Bars); 
   ArraySetAsSeries(bulls,true); ArraySetAsSeries(bears,true);
   }
      
   for(int shift=limit;shift>=0;shift--) 
   {
      if(ptime != Time[shift])
      {
      mMA[1]   = mMA[0]; 
      mLo[1]   = mLo[0]; 
      smin[1]  = smin[0]; 
      smax[1]  = smax[0]; 
      trend[2] = trend[1];
      trend[1] = trend[0];
      ptime    = Time[shift];
      }
   
   if(MathMode < 2) int price = Price; else price = 2;
         
   mMA[0] = allAverages(0,price,PreSmooth,MA_Method,masize,shift);       
      
      if(shift < Bars-2)
      {
         if (MathMode == 0)
         {
         bulls[shift] = 0.5*(MathAbs(mMA[0] - mMA[1]) + (mMA[0] - mMA[1]));
         bears[shift] = 0.5*(MathAbs(mMA[0] - mMA[1]) - (mMA[0] - mMA[1]));
         }
         else  
         if (MathMode == 1)
         {
         double up = 0;      
         double dn = 10000000000;
            for(int i=0;i<Length;i++)
            {   
            up = MathMax(up,High[shift+i]);
            dn = MathMin(dn,Low [shift+i]);
            }
         bulls[shift] = mMA[0] - dn;
         bears[shift] = up - mMA[0];
         }
         else   
         if (MathMode == 2)
         {
         mLo[0] = allAverages(1,3,PreSmooth,MA_Method,masize,shift);          
               
         bulls[shift] = MathMax(0,0.5*(MathAbs(mMA[0]-mMA[1])+(mMA[0]-mMA[1])));
         bears[shift] = MathMax(0,0.5*(MathAbs(mLo[1]-mLo[0])+(mLo[1]-mLo[0])));
      
            if (bulls[shift] > bears[shift]) bears[shift] = 0;
            else 
            if (bulls[shift] < bears[shift]) bulls[shift] = 0;
            else
            if (bulls[shift] == bears[shift]) {bulls[shift] = 0; bears[shift] = 0;}
         }
         
         
      if(MathMode == 1) int len = 1; else len = Length; 
      
      lbulls[shift] = allAveragesOnArray(2,bulls,len,MA_Method,masize,shift);
      lbears[shift] = allAveragesOnArray(3,bears,len,MA_Method,masize,shift);
   
      Bulls[shift] = allAveragesOnArray(4,lbulls,Smooth,MA_Method,masize,shift)/_point;      
      Bears[shift] = allAveragesOnArray(5,lbears,Smooth,MA_Method,masize,shift)/_point;  
      
         
         
         if(LevelsMode == 0)
         {
         if(StrengthLevel > 0) double strength = StrengthLevel/100*(Bulls[shift] + Bears[shift]);
         if(WeaknessLevel > 0) double weakness = WeaknessLevel/100*(Bulls[shift] + Bears[shift]);
         }
         else
         if(LevelsMode == 1 && shift < Bars - (LookBackPeriod+Length))
         {
            for(int j = 0; j < LookBackPeriod; j++)
            { 
            HiArray[j] = MathMax(Bulls[shift+j],Bears[shift+j]);  
            LoArray[j] = MathMin(Bulls[shift+j],Bears[shift+j]); 
            }      
         
         if(UpperMultiplier > 0) strength = SMAOnArray(HiArray,LookBackPeriod,0) + UpperMultiplier*stdDev(HiArray,LookBackPeriod); 
         if(LowerMultiplier > 0) weakness = SMAOnArray(LoArray,LookBackPeriod,0) - LowerMultiplier*stdDev(LoArray,LookBackPeriod);
         }
         else
         if(LevelsMode == 2 && shift < Bars -(LookBackPeriod + Length))
         {
            for(j = 0; j < LookBackPeriod; j++)
            { 
            HiArray[j] = MathMax(Bulls[shift+j],Bears[shift+j]);  
            LoArray[j] = MathMin(Bulls[shift+j],Bears[shift+j]); 
            }   
                  
         upPivot = getPivots(2,HiArray,LookBackPeriod,0);
         dnPivot = getPivots(3,LoArray,LookBackPeriod,0);
               
         smax[0] = upPivot;
         smin[0] = dnPivot;
         
         strength = smax[0] - (smax[0] - smin[0])*(1 - StrengthLevel/100);
         weakness = smin[0] + (smax[0] - smin[0])*WeaknessLevel/100;
         }
         
         
      trend[0] = trend[1];
      if(Bulls[shift] > strength && Bulls[shift] > Bears[shift]) trend[0] = 1;
      if(Bears[shift] > strength && Bulls[shift] < Bears[shift]) trend[0] =-1;
      
      upSignal[shift] = EMPTY_VALUE;
      dnSignal[shift] = EMPTY_VALUE;
      upTrend[shift]  = EMPTY_VALUE;
      dnTrend[shift]  = EMPTY_VALUE;
      
      double delta  = 0.5*iATR(NULL,0,10,shift);
      
          
         if(trend[0] > 0)
         {
         if(trend[1] < 0) upSignal[shift] = Low[shift] - delta;
            if(Bulls[shift] > Bears[shift]) 
            {
            upTrend[shift] = MathMax(Open[shift],Close[shift]);
            dnTrend[shift] = MathMin(Open[shift],Close[shift]);
            }    
         }   
         else
         if(trend[0] < 0)
         {
         if(trend[1] > 0) dnSignal[shift] = High[shift] + delta;
            if(Bears[shift] > Bulls[shift]) 
            {
            upTrend[shift] = MathMin(Open[shift],Close[shift]);
            dnTrend[shift] = MathMax(Open[shift],Close[shift]);
            }    
         }   
      }   
   }
   
   if(AlertMode > 0)
   {
   bool uptrend = trend[1] > 0 && trend[2] <= 0;                  
   bool dntrend = trend[1] < 0 && trend[2] >= 0;
        
      if(uptrend || dntrend)
      {
         if(isNewBar(TimeFrame))
         {
         BoxAlert(uptrend," : BUY Signal at " +DoubleToStr(Close[1],Digits)+", StopLoss at "+DoubleToStr(upSignal[1],Digits));   
         BoxAlert(dntrend," : SELL Signal at "+DoubleToStr(Close[1],Digits)+", StopLoss at "+DoubleToStr(dnSignal[1],Digits)); 
         }
      
      WarningSound(uptrend,SoundsNumber,SoundsPause,UpSound,Time[1]);
      WarningSound(dntrend,SoundsNumber,SoundsPause,DnSound,Time[1]);
         
         if(EmailMode > 0)
         {
         EmailAlert(uptrend,"BUY" ," : BUY Signal at " +DoubleToStr(Close[1],Digits)+", StopLoss at "+DoubleToStr(upSignal[1],Digits),EmailsNumber); 
         EmailAlert(dntrend,"SELL"," : SELL Signal at "+DoubleToStr(Close[1],Digits)+", StopLoss at "+DoubleToStr(dnSignal[1],Digits),EmailsNumber); 
         }
      }
   }
   
}


//-----
string averageName(int mode,int& arraysize)
{   
   string ma_name = "";
   
   switch(mode)
   {
   case 1 : ma_name="EMA"       ; break;
   case 2 : ma_name="Wilder"    ; break;
   case 3 : ma_name="LWMA"      ; break;
   case 4 : ma_name="SineWMA"   ; break;
   case 5 : ma_name="TriMA"     ; break;
   case 6 : ma_name="LSMA"      ; break;
   case 7 : ma_name="SMMA"      ; break;
   case 8 : ma_name="HMA"       ; break;
   case 9 : ma_name="ZeroLagEMA"; break;
   case 10: ma_name="DEMA"      ; arraysize = 2; break;
   case 11: ma_name="T3 basic"  ; arraysize = 6; break;
   case 12: ma_name="InstTrend" ; break;
   case 13: ma_name="Median"    ; break;
   case 14: ma_name="GeoMean"   ; break;
   case 15: ma_name="REMA"      ; break;
   case 16: ma_name="ILRS"      ; break;
   case 17: ma_name="IE/2"      ; break;
   case 18: ma_name="TriMA_gen" ; break;
   case 19: ma_name="VWMA"      ; break;
   case 20: ma_name="JSmooth"   ; arraysize = 5; break;
   case 21: ma_name="SMA_eq"    ; break;
   case 22: ma_name="ALMA"      ; break;
   case 23: ma_name="TEMA"      ; arraysize = 4; break;
   case 24: ma_name="T3"        ; arraysize = 6; break;
   case 25: ma_name="Laguerre"  ; arraysize = 4; break;
   default: ma_name="SMA";
   }
   
   return(ma_name);
   
}

double allAverages(int index,int price,int period,int mode,int arraysize,int bar)
{
   double MA[3];  
        
    if(prevtime[index] != Time[bar])
    {
    ma[index][2]  = ma[index][1]; 
    ma[index][1]  = ma[index][0]; 
    for(int i=0;i<arraysize;i++) tmp[i][index][1] = tmp[i][index][0];
    
    prevtime[index] = Time[bar]; 
    }
   
   for(i=0;i<3;i++) MA[i] = ma[index][i];   
   
   switch(mode)
   {
   case 1 : ma[index][0] = EMA(price,ma[index][1],period,bar); break;
   case 2 : ma[index][0] = Wilder(price,ma[index][1],period,bar); break;  
   case 3 : ma[index][0] = LWMA(price,period,bar); break;
   case 4 : ma[index][0] = SineWMA(price,period,bar); break;
   case 5 : ma[index][0] = TriMA(price,period,bar); break;
   case 6 : ma[index][0] = LSMA(price,period,bar); break;
   case 7 : ma[index][0] = SMMA(price,ma[index][1],period,bar); break;
   case 8 : ma[index][0] = HMA(price,period,bar); break;
   case 9 : ma[index][0] = ZeroLagEMA(price,ma[index][1],period,bar); break;
   case 10: ma[index][0] = DEMA(index,0,price,period,1,bar); break;
   case 11: ma[index][0] = T3_basic(index,0,price,period,0.7,bar); break;
   case 12: ma[index][0] = ITrend(price,MA,period,bar); break;
   case 13: ma[index][0] = Median(price,period,bar); break;
   case 14: ma[index][0] = GeoMean(price,period,bar); break;
   case 15: ma[index][0] = REMA(price,MA,period,0.5,bar); break;
   case 16: ma[index][0] = ILRS(price,period,bar); break;
   case 17: ma[index][0] = IE2(price,period,bar); break;
   case 18: ma[index][0] = TriMA_gen(price,period,bar); break;
   case 19: ma[index][0] = VWMA(price,period,bar); break;
   case 20: ma[index][0] = JSmooth(index,0,price,period,1,bar); break;
   case 21: ma[index][0] = SMA_eq(price,MA,period,bar); break;
   case 22: ma[index][0] = ALMA(price,period,0.85,8,bar); break;
   case 23: ma[index][0] = TEMA(index,price,period,1,bar); break;
   case 24: ma[index][0] = T3(index,0,price,period,0.7,bar); break;
   case 25: ma[index][0] = Laguerre(index,price,period,4,bar); break;
   default: ma[index][0] = SMA(price,period,bar); break;
   }
   
   return(ma[index][0]);
}

double allAveragesOnArray(int index,double& price[],int period,int mode,int arraysize,int bar)
{
   double MA[3];  
        
    if(prevtime[index] != Time[bar])
    {
    ma[index][2]  = ma[index][1]; 
    ma[index][1]  = ma[index][0]; 
    for(int i=0;i<arraysize;i++) tmp[i][index][1] = tmp[i][index][0];
    
    prevtime[index] = Time[bar]; 
    }
   
   for(i=0;i<3;i++) MA[i] = ma[index][i];   
   
   switch(mode)
   {
   case 1 : ma[index][0] = EMAOnArray(price[bar],ma[index][1],period,bar); break;
   case 2 : ma[index][0] = WilderOnArray(price[bar],ma[index][1],period,bar); break;  
   case 3 : ma[index][0] = LWMAOnArray(price,period,bar); break;
   case 4 : ma[index][0] = SineWMAOnArray(price,period,bar); break;
   case 5 : ma[index][0] = TriMAOnArray(price,period,bar); break;
   case 6 : ma[index][0] = LSMAOnArray(price,period,bar); break;
   case 7 : ma[index][0] = SMMAOnArray(price,ma[index][1],period,bar); break;
   case 8 : ma[index][0] = HMAOnArray(price,period,bar); break;
   case 9 : ma[index][0] = ZeroLagEMAOnArray(price,ma[index][1],period,bar); break;
   case 10: ma[index][0] = DEMAOnArray(index,0,price[bar],period,1,bar); break;
   case 11: ma[index][0] = T3_basicOnArray(index,0,price[bar],period,0.7,bar); break;
   case 12: ma[index][0] = ITrendOnArray(price,MA,period,bar); break;
   case 13: ma[index][0] = MedianOnArray(price,period,bar); break;
   case 14: ma[index][0] = GeoMeanOnArray(price,period,bar); break;
   case 15: ma[index][0] = REMAOnArray(price[bar],MA,period,0.5,bar); break;
   case 16: ma[index][0] = ILRSOnArray(price,period,bar); break;
   case 17: ma[index][0] = IE2OnArray(price,period,bar); break;
   case 18: ma[index][0] = TriMA_genOnArray(price,period,bar); break;
   case 19: ma[index][0] = VWMAOnArray(price,period,bar); break;
   case 20: ma[index][0] = JSmoothOnArray(index,0,price[bar],period,1,bar); break;
   case 21: ma[index][0] = SMA_eqOnArray(price,MA,period,bar); break;
   case 22: ma[index][0] = ALMAOnArray(price,period,0.85,8,bar); break;
   case 23: ma[index][0] = TEMAOnArray(index,price[bar],period,1,bar); break;
   case 24: ma[index][0] = T3OnArray(index,0,price[bar],period,0.7,bar); break;
   case 25: ma[index][0] = LaguerreOnArray(index,price[bar],period,4,bar); break;
   default: ma[index][0] = SMAOnArray(price,period,bar); break;
   }
   
   return(ma[index][0]);
}



// MA_Method=0: SMA - Simple Moving Average
double SMA(int price,int per,int bar)
{
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += iMA(NULL,0,1,0,0,price,bar+i);
   
   return(Sum/per);
}

double SMAOnArray(double& array[],int per,int bar)
{
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+i];
   
   return(Sum/per);
}
                           
// MA_Method=1: EMA - Exponential Moving Average
double EMA(int price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double ema = iMA(NULL,0,1,0,0,price,bar);
   else 
   ema = prev + 2.0/(1+per)*(iMA(NULL,0,1,0,0,price,bar) - prev); 
   
   return(ema);
}

double EMAOnArray(double price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double ema = price;
   else 
   ema = prev + 2.0/(1+per)*(price - prev); 
   
   return(ema);
}

// MA_Method=2: Wilder - Wilder Exponential Moving Average
double Wilder(int price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double wilder = iMA(NULL,0,1,0,0,price,bar); //SMA(array1,per,bar);
   else 
   wilder = prev + (iMA(NULL,0,1,0,0,price,bar) - prev)/per; 
   
   return(wilder);
}

double WilderOnArray(double price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double wilder = price; //SMA(array1,per,bar);
   else 
   wilder = prev + (price - prev)/per; 
   
   return(wilder);
}

// MA_Method=3: LWMA - Linear Weighted Moving Average 
double LWMA(int price,int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= (per - i);
      Sum += iMA(NULL,0,1,0,0,price,bar+i)*(per - i);
      }
   if(Weight>0) double lwma = Sum/Weight;
   else lwma = 0; 
   return(lwma);
} 

double LWMAOnArray(double& array[],int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= (per - i);
      Sum += array[bar+i]*(per - i);
      }
   if(Weight>0) double lwma = Sum/Weight;
   else lwma = 0; 
   return(lwma);
}

 
// MA_Method=4: SineWMA - Sine Weighted Moving Average
double SineWMA(int price,int per,int bar)
{
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
  
      for(int i = 0;i < per;i++)
      { 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += iMA(NULL,0,1,0,0,price,bar+i)*MathSin(pi*(i+1)/(per+1)); 
      }
   if(Weight>0) double swma = Sum/Weight;
   else swma = 0; 
   return(swma);
}

double SineWMAOnArray(double& array[],int per,int bar)
{
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
  
      for(int i = 0;i < per;i++)
      { 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+i]*MathSin(pi*(i+1)/(per+1)); 
      }
   if(Weight>0) double swma = Sum/Weight;
   else swma = 0; 
   return(swma);
}

// MA_Method=5: TriMA - Triangular Moving Average
double TriMA(int price,int per,int bar)
{
   double sma;
   int len = MathCeil((per+1)*0.5);
   
   double sum=0;
   for(int i = 0;i < len;i++) 
   {
   sma = SMA(price,len,bar+i);
   sum += sma;
   } 
   double trima = sum/len;
   
   return(trima);
}

double TriMAOnArray(double& array[],int per,int bar)
{
   double sma;
   int len = MathCeil((per+1)*0.5);
   
   double sum=0;
   for(int i = 0;i < len;i++) 
   {
   sma = SMAOnArray(array,len,bar+i);
   sum += sma;
   } 
   double trima = sum/len;
   
   return(trima);
}

// MA_Method=6: LSMA - Least Square Moving Average (or EPMA, Linear Regression Line)
double LSMA(int price,int per,int bar)
{   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*iMA(NULL,0,1,0,0,price,bar+per-i);
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

double LSMAOnArray(double& array[],int per,int bar)
{   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+per-i];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

// MA_Method=7: SMMA - Smoothed Moving Average
double SMMA(int price,double prev,int per,int bar)
{
   if(bar == Bars - per) double smma = SMA(price,per,bar);
   else 
   if(bar < Bars - per)
   {
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += iMA(NULL,0,1,0,0,price,bar+i+1);
   smma = (Sum - prev + iMA(NULL,0,1,0,0,price,bar))/per;
   }
   
   return(smma);
}

double SMMAOnArray(double& array[],double prev,int per,int bar)
{
   if(bar == Bars - per) double smma = SMAOnArray(array,per,bar);
   else 
   if(bar < Bars - per)
   {
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+i+1];
   smma = (Sum - prev + array[bar])/per;
   }
   
   return(smma);
}
                                
// MA_Method=8: HMA - Hull Moving Average by Alan Hull
double HMA(int price,int per,int bar)
{
   double hma_tmp[];
   int len = MathSqrt(per);
   
   ArrayResize(tmp,len);
   
   if(bar == Bars - per) double hma = iMA(NULL,0,1,0,0,price,bar); 
   else
   if(bar < Bars - per)
   {
   for(int i=0;i<len;i++) hma_tmp[i] = 2*LWMA(price,per/2,bar+i) - LWMA(price,per,bar+i);  
   hma = LWMAOnArray(hma_tmp,len,0); 
   }  

   return(hma);
}

double HMAOnArray(double& array[],int per,int bar)
{
   double hma_tmp[];
   int len = MathSqrt(per);
   
   ArrayResize(tmp,len);
   
   if(bar == Bars - per) double hma = array[bar]; 
   else
   if(bar < Bars - per)
   {
   for(int i=0;i<len;i++) hma_tmp[i] = 2*LWMAOnArray(array,per/2,bar+i) - LWMAOnArray(array,per,bar+i);  
   hma = LWMAOnArray(hma_tmp,len,0); 
   }  

   return(hma);
}

// MA_Method=9: ZeroLagEMA - Zero-Lag Exponential Moving Average
double ZeroLagEMA(int price,double prev,int per,int bar)
{
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   
   if(bar >= Bars - lag) double zema = iMA(NULL,0,1,0,0,price,bar);
   else 
   zema = alfa*(2*iMA(NULL,0,1,0,0,price,bar) - iMA(NULL,0,1,0,0,price,bar+lag)) + (1-alfa)*prev;
   
   return(zema);
}


double ZeroLagEMAOnArray(double& price[],double prev,int per,int bar)
{
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   
   if(bar >= Bars - lag) double zema = price[bar];
   else 
   zema = alfa*(2*price[bar] - price[bar+lag]) + (1-alfa)*prev;
   
   return(zema);
}

// MA_Method=10: DEMA - Double Exponential Moving Average by Patrick Mulloy
double DEMA(int index,int num,int price,double per,double v,int bar)
{
   double alpha = 2.0/(1+per);
   if(bar == Bars - 2) {double dema = iMA(NULL,0,1,0,0,price,bar); tmp[num][index][0] = dema; tmp[num+1][index][0] = dema;}
   else 
   if(bar <  Bars - 2) 
   {
   tmp[num  ][index][0] = tmp[num  ][index][1] + alpha*(iMA(NULL,0,1,0,0,price,bar) - tmp[num  ][index][1]); 
   tmp[num+1][index][0] = tmp[num+1][index][1] + alpha*(tmp[num][index][0]          - tmp[num+1][index][1]); 
   dema                 = tmp[num  ][index][0]*(1+v) - tmp[num+1][index][0]*v;
   }
   
   return(dema);
}

double DEMAOnArray(int index,int num,double price,double per,double v,int bar)
{
   double alpha = 2.0/(1+per);
   if(bar == Bars - 2) {double dema = price; tmp[num][index][0] = dema; tmp[num+1][index][0] = dema;}
   else 
   if(bar <  Bars - 2) 
   {
   tmp[num  ][index][0] = tmp[num  ][index][1] + alpha*(price              - tmp[num  ][index][1]); 
   tmp[num+1][index][0] = tmp[num+1][index][1] + alpha*(tmp[num][index][0] - tmp[num+1][index][1]); 
   dema                 = tmp[num  ][index][0]*(1+v) - tmp[num+1][index][0]*v;
   }
   
   return(dema);
}

// MA_Method=11: T3 by T.Tillson
double T3_basic(int index,int num,int price,int per,double v,int bar)
{
   double dema1, dema2;
   
   if(bar == Bars - 2) 
   {
   double T3 = iMA(NULL,0,1,0,0,price,bar); 
   for(int k=0;k<6;k++) tmp[num+k][index][0] = T3;
   }
   else 
   if(bar < Bars - 2) 
   {
   T3    = iMA(NULL,0,1,0,0,price,bar); 
   dema1 = DEMAOnArray(index,num  ,T3   ,per,v,bar); 
   dema2 = DEMAOnArray(index,num+2,dema1,per,v,bar); 
   T3    = DEMAOnArray(index,num+4,dema2,per,v,bar);
   }
   
   return(T3);
}

double T3_basicOnArray(int index,int num,double price,int per,double v,int bar)
{
   double dema1, dema2;
   
   if(bar == Bars - 2) 
   {
   double T3 = price; 
   for(int k=0;k<6;k++) tmp[num+k][index][0] = price;
   }
   else 
   if(bar < Bars - 2) 
   {
   dema1 = DEMAOnArray(index,num  ,price,per,v,bar); 
   dema2 = DEMAOnArray(index,num+2,dema1,per,v,bar); 
   T3    = DEMAOnArray(index,num+4,dema2,per,v,bar);
   }
   
   return(T3);
}

// MA_Method=12: ITrend - Instantaneous Trendline by J.Ehlers
double ITrend(int price,double& array[],int per,int bar)
{
   double alfa = 2.0/(per + 1);
   if(bar < Bars - 7)
   double it = (alfa - 0.25*alfa*alfa)*iMA(NULL,0,1,0,0,price,bar) + 0.5*alfa*alfa*iMA(NULL,0,1,0,0,price,bar+1) 
             - (alfa - 0.75*alfa*alfa)*iMA(NULL,0,1,0,0,price,bar+2) + 2*(1-alfa)*array[1] - (1-alfa)*(1-alfa)*array[2];
   else
   it = (iMA(NULL,0,1,0,0,price,bar) + 2*iMA(NULL,0,1,0,0,price,bar+1) + iMA(NULL,0,1,0,0,price,bar)+2)/4;
   
   return(it);
}

double ITrendOnArray(double& price[],double& array[],int per,int bar)
{
   double alfa = 2.0/(per+1);
   if(bar < Bars - 7)
   double it = (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+1] - (alfa - 0.75*alfa*alfa)*price[bar+2] +
   2*(1-alfa)*array[1] - (1-alfa)*(1-alfa)*array[2];
   else
   it = (price[bar] + 2*price[bar+1] + price[bar+2])/4;
   
   return(it);
}
// MA_Method=13: Median - Moving Median
double Median(int price,int per,int bar)
{
   double array[];
   ArrayResize(array,per);
   
   for(int i = 0; i < per;i++) array[i] = iMA(NULL,0,1,0,0,price,bar+i);
   ArraySort(array);
   
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
    
   return(median); 
}

double MedianOnArray(double& price[],int per,int bar)
{
   double array[];
   ArrayResize(array,per);
   
   for(int i = 0; i < per;i++) array[i] = price[bar+i];
   ArraySort(array);
   
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
    
   return(median); 
}
// MA_Method=14: GeoMean - Geometric Mean
double GeoMean(int price,int per,int bar)
{
   if(bar < Bars - per)
   { 
   double gmean = MathPow(iMA(NULL,0,1,0,0,price,bar),1.0/per); 
   for(int i = 1; i < per;i++) gmean *= MathPow(iMA(NULL,0,1,0,0,price,bar+i),1.0/per); 
   }
   
   return(gmean);
}

double GeoMeanOnArray(double& price[],int per,int bar)
{
   if(bar < Bars - per)
   { 
   double gmean = MathPow(price[bar],1.0/per); 
   for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+i],1.0/per); 
   }
   
   return(gmean);
}
// MA_Method=15: REMA - Regularized EMA by Chris Satchwell 
double REMA(int price,double& array[],int per,double lambda,int bar)
{
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3) double rema = iMA(NULL,0,1,0,0,price,bar);
   else 
   rema = (array[1]*(1+2*lambda) + alpha*(iMA(NULL,0,1,0,0,price,bar) - array[1]) - lambda*array[2])/(1+lambda); 
   
   return(rema);
}

double REMAOnArray(double price,double& array[],int per,double lambda,int bar)
{
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3) double rema = price;
   else 
   rema = (array[1]*(1+2*lambda) + alpha*(price - array[1]) - lambda*array[2])/(1+lambda); 
   
   return(rema);
}
// MA_Method=16: ILRS - Integral of Linear Regression Slope 
double ILRS(int price,int per,int bar)
{
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
     
   double sum1 = 0;
   double sumy = 0;
      for(int i=0;i<per;i++)
      { 
      sum1 += i*iMA(NULL,0,1,0,0,price,bar+i);
      sumy += iMA(NULL,0,1,0,0,price,bar+i);
      }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMA(price,per,bar);
   
   return(ilrs);
}

double ILRSOnArray(double& price[],int per,int bar)
{
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
     
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
double IE2(int price,int per,int bar)
{
   double ie = 0.5*(ILRS(price,per,bar) + LSMA(price,per,bar));
      
   return(ie); 
}
 
double IE2OnArray(double& price[],int per,int bar)
{
   double ie = 0.5*(ILRSOnArray(price,per,bar) + LSMAOnArray(price,per,bar));
      
   return(ie); 
}

// MA_Method=18: TriMAgen - Triangular Moving Average Generalized by J.Ehlers
double TriMA_gen(int price,int per,int bar)
{
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(price,len1,bar+i);
   double trimagen = sum/len2;
   
   return(trimagen);
}

double TriMA_genOnArray(double& array[],int per,int bar)
{
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMAOnArray(array,len1,bar+i);
   double trimagen = sum/len2;
   
   return(trimagen);
}

// MA_Method=19: VWMA - Volume Weighted Moving Average 
double VWMA(int price,int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= Volume[bar+i];
      Sum += iMA(NULL,0,1,0,0,price,bar+i)*Volume[bar+i];
      }
   if(Weight>0) double vwma = Sum/Weight;
   else vwma = 0; 
   return(vwma);
} 

double VWMAOnArray(double& array[],int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= Volume[bar+i];
      Sum += array[bar+i]*Volume[bar+i];
      }
   if(Weight>0) double vwma = Sum/Weight;
   else vwma = 0; 
   return(vwma);
} 
// MA_Method=20: JSmooth - Smoothing by Mark Jurik
double JSmooth(int index,int num,int price,int per,double pow,int bar)
{
   double beta  = 0.45*(per-1)/(0.45*(per-1)+2);
	double alpha = MathPow(beta,pow);
	double ima   = iMA(NULL,0,1,0,0,price,bar); 
	
	if(bar == Bars - 2) 
	{
	tmp[num+4][index][0] = ima; 
	tmp[num+0][index][0] = ima; 
	tmp[num+2][index][0] = ima;
	}
	else 
   if(bar <  Bars - 2) 
   {
	tmp[num+0][index][0] = (1-alpha)*ima + alpha*tmp[num+0][index][1];
	tmp[num+1][index][0] = (ima - tmp[num+0][index][0])*(1-beta) + beta*tmp[num+1][index][1];
	tmp[num+2][index][0] = tmp[num+0][index][0] + tmp[num+1][index][0];
	tmp[num+3][index][0] = (tmp[num+2][index][0] - tmp[num+4][index][1])*MathPow((1-alpha),2) + MathPow(alpha,2)*tmp[num+3][index][1];
	tmp[num+4][index][0] = tmp[num+4][index][1] + tmp[num+3][index][0]; 
   }
   
   return(tmp[num+4][index][0]);
}

double JSmoothOnArray(int index,int num,double price,int per,double pow,int bar)
{
   double beta = 0.45*(per-1)/(0.45*(per-1)+2);
	double alpha = MathPow(beta,pow);
	
	if(bar == Bars - 2) {tmp[num+4][index][0] = price; tmp[num+0][index][0] = price; tmp[num+2][index][0] = price;}
	else 
   if(bar <  Bars - 2) 
   {
	tmp[num+0][index][0] = (1-alpha)*price + alpha*tmp[num+0][index][1];
	tmp[num+1][index][0] = (price - tmp[num+0][index][0])*(1-beta) + beta*tmp[num+1][index][1];
	tmp[num+2][index][0] = tmp[num+0][index][0] + tmp[num+1][index][0];
	tmp[num+3][index][0] = (tmp[num+2][index][0] - tmp[num+4][index][1])*MathPow((1-alpha),2) + MathPow(alpha,2)*tmp[num+3][index][1];
	tmp[num+4][index][0] = tmp[num+4][index][1] + tmp[num+3][index][0]; 
   }
   return(tmp[num+4][index][0]);
}

// MA_Method=21: SMA_eq     - Simplified SMA
double SMA_eq(int price,double& array[],int per,int bar)
{
   if(bar == Bars - per) double sma = SMA(price,per,bar);
   else 
   if(bar <  Bars - per) sma = (iMA(NULL,0,1,0,0,price,bar) - iMA(NULL,0,1,0,0,price,bar+per))/per + array[1]; 
   
   return(sma);
}                        		

double SMA_eqOnArray(double& price[],double& array[],int per,int bar)
{
   if(bar == Bars - per) double sma = SMAOnArray(price,per,bar);
   else 
   if(bar <  Bars - per) sma = (price[bar] - price[bar+per])/per + array[1]; 
   
   return(sma);
}                 
// MA_Method=22: ALMA by Arnaud Legoux / Dimitris Kouzis-Loukas / Anthony Cascino
double ALMA(int price,int per,double offset,double sigma,int bar)
{
   double m = MathFloor(offset * (per - 1));
	double s = per/sigma;
		
	double w, sum =0, wsum = 0;		
	for (int i=0;i < per;i++) 
	{
	w = MathExp(-((i - m)*(i - m))/(2*s*s));
   wsum += w;
   sum += iMA(NULL,0,1,0,0,price,bar+(per-1-i))*w; 
   }
   
   if(wsum != 0) double alma = sum/wsum; 
   
   return(alma);
}   

double ALMAOnArray(double& price[],int per,double offset,double sigma,int bar)
{
   double m = MathFloor(offset * (per - 1));
	double s = per/sigma;
		
	double w, sum =0, wsum = 0;		
	for (int i=0;i < per;i++) 
	{
	w = MathExp(-((i - m)*(i - m))/(2*s*s));
   wsum += w;
   sum += price[bar+(per-1-i)]*w; 
   }
   
   if(wsum != 0) double alma = sum/wsum; 
   
   return(alma);
}
  
// MA_Method=23: TEMA - Triple Exponential Moving Average by Patrick Mulloy
double TEMA(int index,int price,int per,double v,int bar)
{
   double alpha = 2.0/(per+1);
	double ima   = iMA(NULL,0,1,0,0,price,bar);
	if(bar == Bars - 2) {tmp[0][index][0] = ima; tmp[1][index][0] = ima; tmp[2][index][0] = ima;}
	else 
   if(bar <  Bars - 2) 
   {
	tmp[0][index][0] = tmp[0][index][1] + alpha *(ima              - tmp[0][index][1]);
	tmp[1][index][0] = tmp[1][index][1] + alpha *(tmp[0][index][0] - tmp[1][index][1]);
	tmp[2][index][0] = tmp[2][index][1] + alpha *(tmp[1][index][0] - tmp[2][index][1]);
	tmp[3][index][0] = tmp[0][index][0] + v*(tmp[0][index][0] + v*(tmp[0][index][0]-tmp[1][index][0]) - tmp[1][index][0] - v*(tmp[1][index][0] - tmp[2][index][0])); 
	}
   
   return(tmp[3][index][0]);
}

double TEMAOnArray(int index,double price,int per,double v,int bar)
{
   double alpha = 2.0/(per+1);
	
	if(bar == Bars - 2) {tmp[0][index][0] = price; tmp[1][index][0] = price; tmp[2][index][0] = price;}
	else 
   if(bar <  Bars - 2) 
   {
	tmp[0][index][0] = tmp[0][index][1] + alpha *(price     - tmp[0][index][1]);
	tmp[1][index][0] = tmp[1][index][1] + alpha *(tmp[0][index][0] - tmp[1][index][1]);
	tmp[2][index][0] = tmp[2][index][1] + alpha *(tmp[1][index][0] - tmp[2][index][1]);
	tmp[3][index][0] = tmp[0][index][0] + v*(tmp[0][index][0] + v*(tmp[0][index][0]-tmp[1][index][0]) - tmp[1][index][0] - v*(tmp[1][index][0] - tmp[2][index][0])); 
	}
   
   return(tmp[3][index][0]);
}
// MA_Method=24: T3 by T.Tillson (correct version) 
double T3(int index,int num,double price,int per,double v,int bar)
{
   double len = MathMax((per + 5.0)/3.0-1,1), dema1, dema2;
   double T3, ima = iMA(NULL,0,1,0,0,price,bar); 
   
   if(bar == Bars - 2) for(int k=0;k<6;k++) tmp[num+k][index][0] = ima;
   else 
   if(bar < Bars - 2) 
   {
   dema1 = DEMAOnArray(index,num  ,ima  ,len,v,bar); 
   dema2 = DEMAOnArray(index,num+2,dema1,len,v,bar); 
   T3    = DEMAOnArray(index,num+4,dema2,len,v,bar);
   }
   
   return(T3);
}

double T3OnArray(int index,int num,double price,int per,double v,int bar)
{
   double len = MathMax((per + 5.0)/3.0-1,1), dema1, dema2;
   
   if(bar == Bars - 2) 
   {
   double T3 = price; 
   for(int k=0;k<6;k++) tmp[num+k][index][0] = T3;
   }
   else 
   if(bar < Bars - 2) 
   {
   dema1 = DEMAOnArray(index,num  ,price,len,v,bar); 
   dema2 = DEMAOnArray(index,num+2,dema1,len,v,bar); 
   T3    = DEMAOnArray(index,num+4,dema2,len,v,bar);
   }
      
   return(T3);
}

// MA_Method=25: Laguerre filter by J.Ehlers
double Laguerre(int index,int price,int per,int order,int bar)
{
   double gamma = 1-10.0/(per+9);
   double ima   = iMA(NULL,0,1,0,0,price,bar);
   double aPrice[];
   
   ArrayResize(aPrice,order);
   
   for(int i=0;i<order;i++)
   {
      if(bar >= Bars - order) tmp[i][index][0] = ima;
      else
      {
         if(i == 0) tmp[i][index][0] = (1 - gamma)*ima + gamma*tmp[i][index][1];
         else
         tmp[i][index][0] = -gamma * tmp[i-1][index][0] + tmp[i-1][index][1] + gamma * tmp[i][index][1];
      
      aPrice[i] = tmp[i][index][0];
      }
   }
   double laguerre = TriMA_genOnArray(aPrice,order,0);  

   return(laguerre);
}

double LaguerreOnArray(int index,double price,int per,int order,int bar)
{
   double gamma = 1-10.0/(per+9);
   double aPrice[];
   
   ArrayResize(aPrice,order);
   
   for(int i=0;i<order;i++)
   {
      if(bar >= Bars - order) tmp[i][index][0] = price;
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



double getPivots(int type,double& price[],int size,double height)
{
   if(type < 2) int len = 2*MathMax(1,size) + 1; else len = size;
      
   int imax = 0, imin = 0;
   double max = 0, min = 100000000;
       
   for(int i=0;i<len;i++)
   { 
      if((type == 0 || type == 2) && price[i] > max && price[i] < 1000000) {max = price[i]; imax = i;}  
      if((type == 1 || type == 3) && price[i] < min ) {min = price[i]; imin = i;}  
   }
   
   if(type < 2) 
   {
   if(imax == size && max - price[0] > height && max - price[len-1] > height) return(max); 
   if(imin == size && price[0] - min > height && price[len-1] - min > height) return(min);
   }
   else 
   {
   if(type == 2) return(max); 
   if(type == 3) return(min); 
   }
   
   return(0);  
}   


double stdDev(double& array[],int length)
{
   double avg = 0;
   for (int i=0;i<length;i++) avg += array[i]/length;
        
   double sum = 0;
   for (i=0;i<length;i++) sum += MathPow(array[i] - avg,2);
   return(MathSqrt(sum/length));
}

bool isNewBar(int tf)
{
   static datetime pTime;
   bool res=false;
   
   if(tf >= 0)
   {
      if (iTime(NULL,tf,0)!= pTime)
      {
      res=true;
      pTime=iTime(NULL,tf,0);
      }   
   }
   else res = true;
   
   return(res);
}

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

bool Pause(int sec)
{
   if(TimeCurrent() >= preTime + sec) {preTime = TimeCurrent(); return(true);}
   
   return(false);
}

void WarningSound(bool cond,int num,int sec,string sound,datetime ctime)
{
   static int i;
   
   if(cond)
   {
   if(ctime != ptime) i = 0; 
   if(i < num && Pause(sec)) {PlaySound(sound); ptime = ctime; i++;}       	
   }
}

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
 
string tf(int timeframe)
{
   switch(timeframe)
   {
   case PERIOD_M1:   return("M1");
   case PERIOD_M5:   return("M5");
   case PERIOD_M15:  return("M15");
   case PERIOD_M30:  return("M30");
   case PERIOD_H1:   return("H1");
   case PERIOD_H4:   return("H4");
   case PERIOD_D1:   return("D1");
   case PERIOD_W1:   return("W1");
   case PERIOD_MN1:  return("MN1");
   default:          return("Unknown timeframe");
   }
}                  
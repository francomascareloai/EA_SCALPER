//+------------------------------------------------------------------+
//|                                           DeltaTrend_v1 600+.mq4 |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red


//---- indicator parameters
extern int  TimeFrame         =    0;    //TimeFrame in min
extern int  MainFilterFast    =    8;
extern int  MainFilterSlow    =   16;
extern int  SmallFilterFast   =    3;
extern int  SmallFilterSlow   =   12;
extern bool FirstSignalOnly   = true;
extern bool AlertMode         = true;

double signal_UP[];
double signal_DN[];


int  trend[2], barnumber;
double mom[], smom[];
datetime prevtime;
bool DnTrend = FALSE, UpTrend = FALSE;
string TF, IndicatorName, short_name;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() 
{
   if(TimeFrame <= Period()) TimeFrame = Period();
   TF = tf(TimeFrame);
   if(TF  == "N/A") TimeFrame = Period();
   
   IndicatorDigits(Digits);
     
   SetIndexBuffer(0,signal_UP); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,233);
   SetIndexBuffer(1,signal_DN); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,234);
   
   IndicatorName = WindowExpertName(); 
   short_name = IndicatorName+"["+TF+"]("+MainFilterFast+","+MainFilterSlow+","+SmallFilterFast+","+SmallFilterSlow+")";
   
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"LongSignal" );
   SetIndexLabel(1,"ShortSignal");
   
   return (0);
}

void deinit() { return; }

int start() 
{
   int i, shift, limit, counted_bars=IndicatorCounted();
        
   if(counted_bars > 0) limit = Bars - counted_bars - 1;
   if(counted_bars < 0) return(0);
   if(counted_bars < 1)
   { 
   limit = Bars - 1;   
      for(i=limit;i>=0;i--) 
      {
      signal_UP[i]  = EMPTY_VALUE;
      signal_DN[i]  = EMPTY_VALUE;
      }
   }
         
   if(TimeFrame != Period())
	{
   limit = MathMax(limit,TimeFrame/Period());   
      
      for(shift = 0;shift < limit;shift++) 
      {	
      int y = iBarShift(NULL,TimeFrame,Time[shift]);
      
      signal_UP[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,MainFilterFast,MainFilterSlow,SmallFilterFast,SmallFilterSlow,FirstSignalOnly,AlertMode,0,y);
      signal_DN[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,MainFilterFast,MainFilterSlow,SmallFilterFast,SmallFilterSlow,FirstSignalOnly,AlertMode,1,y);;
      }
      
   return(0);
   }   
   else
   for(shift = limit; shift>=0; shift--)
   {
      if(prevtime != Time[shift])
      {
      trend[1] = trend[0];
      prevtime = Time[shift];
      }
   
      trend[0] = trend[1];
         
      if(ROC(1,MainFilterFast,shift) > ROC(1,MainFilterSlow,shift))
      {
      double  roc  = ROC(0,SmallFilterFast,shift);
      double  aroc = ROC(1,SmallFilterSlow,shift);
            
         if(roc >  aroc) trend[0] = 1;
         else 
         if(roc < -aroc) trend[0] =-1;
      }
      
    signal_UP[shift] = EMPTY_VALUE;
    signal_DN[shift] = EMPTY_VALUE;  
      
      if (trend[0] == 1)
      {
      if(!FirstSignalOnly || trend[1] < 0) signal_UP[shift] = Low[shift] - iATR(NULL,0,10,shift);
      }
      
      if(trend[0] == -1)
      {
      if(!FirstSignalOnly || trend[1] > 0) signal_DN[shift] = High[shift] + iATR(NULL,0,10,shift);
      }
   }
   
   if(signal_UP[0] != EMPTY_VALUE && signal_UP[0] != 0.0 && DnTrend && Bars>barnumber)
   {
      barnumber = Bars;
      DnTrend   = FALSE;
      Alert("DeltaTrend going Up on ", Symbol(), " ", TF);
   }
   
   if (!DnTrend && (signal_UP[0] == EMPTY_VALUE || signal_UP[0] == 0.0)) DnTrend = TRUE;
   
   if (signal_DN[0] != EMPTY_VALUE && signal_DN[0] != 0.0 && UpTrend && Bars > barnumber)
   {
      barnumber=Bars;
      UpTrend = FALSE;
      Alert("DeltaTrend going Down on ", Symbol(), " ", TF);
   }
   
   if ((!UpTrend) && (signal_DN[0] == EMPTY_VALUE || signal_DN[0] == 0.0)) UpTrend = TRUE;
   
   return (0);
}

double ROC(int mode,int length, int bar) // 
{
   if(iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,length+bar+1) == 0.0) return (0);
   
   ArrayResize(mom ,length);
   ArrayResize(smom,length);
   
   for(int i=0;i<length;i++) 
   {
   if(mode == 0) mom[length-1-i] = iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,bar+i) - iMA(NULL,0,1,0,MODE_SMA,PRICE_OPEN,bar+i);
   else mom[length-1-i] = MathAbs(iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,bar+i) - iMA(NULL,0,1,0,MODE_SMA,PRICE_OPEN,bar+i)); 
   }
   
   double alpha = 2.0/(length + 1);
   smom[0] = mom[0];
   for (i=1;i<length;i++) smom[i] = mom[i]*alpha + smom[i-1]*(1 - alpha);
   
   return (smom[length - 1]);
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

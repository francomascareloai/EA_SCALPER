#property  copyright "whoever"
#property  link      "whatever"

#property  indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   5
#property  indicator_color1  clrLimeGreen
#property  indicator_color2  clrRed
#property  indicator_color3  clrGold
#property  indicator_color4  clrLimeGreen
#property  indicator_color5  clrRed
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2
#property  indicator_width4  2
#property  indicator_width5  2
 
input int period=35;
input int smooth=10; 
input bool DoAlert=false;
input bool alertMail=false;
input bool alertsPushNotif=true;   
datetime lastAlertTime;


double         ExtBuffer0[];
double         ExtBuffer1[];
double         ExtBuffer2[];
double         ExtBuffer3[];
double         ExtBuffer4[];
double         ExtBuffer5[];
double         ExtBufferh1[];
double         ExtBufferh2[];


int OnInit()
{
   SetIndexBuffer(0,ExtBufferh1); 
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   
   SetIndexBuffer(1,ExtBufferh2); 
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   
   SetIndexBuffer(2,ExtBuffer3);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
   
   SetIndexBuffer(3,ExtBuffer4);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);
   
   SetIndexBuffer(4,ExtBuffer5);
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_LINE);   
   
   SetIndexBuffer(5,ExtBuffer0);
   SetIndexBuffer(6,ExtBuffer1);
   SetIndexBuffer(7,ExtBuffer2);

   lastAlertTime = iTime(Symbol(),PERIOD_CURRENT,1);

   IndicatorSetString(INDICATOR_SHORTNAME,"Solar wind joy :)");
   ArraySetAsSeries(ExtBuffer0,true);      
   ArraySetAsSeries(ExtBuffer1,true);     
   ArraySetAsSeries(ExtBuffer2,true);     
   ArraySetAsSeries(ExtBuffer3,true);     
   ArraySetAsSeries(ExtBuffer4,true);     
   ArraySetAsSeries(ExtBuffer5,true);     
   ArraySetAsSeries(ExtBufferh1,true);     
   ArraySetAsSeries(ExtBufferh2,true);    
    
   return INIT_SUCCEEDED;
}



int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //int     period=10;
   int    limit;
   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   double price;
   double MinL=0;
   double MaxH=0;  
   
   int counted_bars=prev_calculated;
   if(counted_bars<0) return 0;
   if(counted_bars>0) counted_bars--;
   limit=rates_total-counted_bars;
   if(limit>(rates_total-1)) limit=rates_total-1;
   string sAlertMsg;
   
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(time,true);
      
   //limit=Bars-1;


   for(int i=0; i<limit; i++)
    {  MaxH = high[iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,period,i)];
       MinL = low[iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,period,i)];
      price = (high[i]+low[i])/2.0;
      Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;     
      Value=MathMin(MathMax(Value,-0.999),0.999); 
      ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      Value1=Value;
      Fish1=ExtBuffer0[i];
         if (ExtBuffer0[i]>0) ExtBuffer1[i]=10; else ExtBuffer1[i]=-10;      
    }

   for(int i=limit; i>=0; i--)
   {
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<smooth && (i+k)<rates_total; k++)
      {
         double weight = smooth-k;
                sumw  += weight;
                sum   += weight*ExtBuffer1[i+k];  
      }             
      if (sumw!=0)
            ExtBuffer2[i] = sum/sumw;
      else  ExtBuffer2[i] = 0;
   }      
   for(int i=0; i<=limit; i++)
   {
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<smooth && (i-k)>=0; k++)
      {
         double weight = smooth-k;
                sumw  += weight;
                sum   += weight*ExtBuffer2[i-k];
      }             
      if (sumw!=0)
            ExtBuffer3[i] = sum/sumw;
      else  ExtBuffer3[i] = 0;
   }      
   for(int i=limit; i>=0; i--)
   {
      ExtBuffer4[i]=EMPTY_VALUE;
      ExtBuffer5[i]=EMPTY_VALUE;
      ExtBufferh1[i]=EMPTY_VALUE;
      ExtBufferh2[i]=EMPTY_VALUE;
      if (ExtBuffer3[i]>0) { ExtBuffer4[i]=ExtBuffer3[i]; ExtBufferh1[i]=ExtBuffer3[i]; }
      if (ExtBuffer3[i]<0) { ExtBuffer5[i]=ExtBuffer3[i]; ExtBufferh2[i]=ExtBuffer3[i]; }
      
      if((i+1)<=limit)
      {
         if (ExtBuffer3[i+1] < 0 && ExtBuffer3[i] > 0)
         {
            if (DoAlert && i<5 && lastAlertTime!=time[0])
            {
               sAlertMsg="Solar Wind - "+Symbol()+" "+HumanCompressionShort(Period())+": cross UP";
               if (DoAlert)     Alert(sAlertMsg);
               lastAlertTime = time[0];  
               if (alertMail)   SendMail(sAlertMsg, "MT4 Alert!\n" + TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS )+"\n"+sAlertMsg);
               if (alertsPushNotif)  SendNotification (sAlertMsg);     
            }
         }
         else if( ExtBuffer3[i+1] > 0 && ExtBuffer3[i] < 0)
         {
            if (i<5 && lastAlertTime!=time[0])
            {
               sAlertMsg="Solar Wind - "+Symbol()+" "+HumanCompressionShort(Period())+": cross DOWN";
               if (DoAlert)     Alert(sAlertMsg);
               lastAlertTime = time[0];  
               if (alertMail)   SendMail(sAlertMsg, "MT4 Alert!\n" + TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS )+"\n"+sAlertMsg); 
               if (alertsPushNotif)   SendNotification(sAlertMsg);  
            }
                        
         }
      }
   }
   return rates_total;
}


string HumanCompressionShort(ENUM_TIMEFRAMES tf)
{
   if(tf==PERIOD_CURRENT) tf=Period();
   int tf_min=PeriodSeconds(tf)/60;
   if(tf==PERIOD_MN1)
   {
      return "MN1";
   }
   else if(tf==PERIOD_W1)
   {
      return "W1";
   }
   else if(tf==PERIOD_D1)
   {
      return "D1";
   }
   else if(tf_min<1440 && tf_min>=60)
   {
      return "H"+IntegerToString(tf_min/60);
   }
   else //tf_min<60
   {
      return "M"+IntegerToString(tf_min);
   }
}

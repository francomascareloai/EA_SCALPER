#property  copyright "whoever"
#property  link      "whatever"

#property  indicator_separate_window
#property  indicator_buffers 5
#property  indicator_color1  LimeGreen
#property  indicator_color2  Red
#property  indicator_color3  Gold
#property  indicator_color4  LimeGreen
#property  indicator_color5  Red
#property  indicator_width3  2
#property  indicator_width4  2
#property  indicator_width5  2
 
extern int period=35;
extern int smooth=10; 
extern bool DoAlert=true;
extern bool alertMail=false;
datetime lastAlertTime;


double         ExtBuffer0[];
double         ExtBuffer1[];
double         ExtBuffer2[];
double         ExtBuffer3[];
double         ExtBuffer4[];
double         ExtBuffer5[];
double         ExtBufferh1[];
double         ExtBufferh2[];

#define LinesIdentifier "signalLines"
int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,ExtBufferh1); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtBufferh2); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtBuffer3);
   SetIndexBuffer(3,ExtBuffer4);
   SetIndexBuffer(4,ExtBuffer5);
   SetIndexBuffer(5,ExtBuffer0);
   SetIndexBuffer(6,ExtBuffer1);
   SetIndexBuffer(7,ExtBuffer2);

   lastAlertTime = Time[1];

   IndicatorShortName("Solar wind joy :)");
   return(0);
}
int deinit()
{
   int lookForLength = StringLen(LinesIdentifier);
   for (int i=ObjectsTotal(); i>=0; i--)
      {
         string name = ObjectName(i);
         if (StringSubstr(name,0,lookForLength)==LinesIdentifier) ObjectDelete(name);
      }
   return(0);
}


int start()
{
   //int     period=10;
   int    limit;
   double prev,current,old;
   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   double price;
   double MinL=0;
   double MaxH=0;  
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   string sAlertMsg;
      
   //limit=Bars-1;


   for(int i=0; i<limit; i++)
    {  MaxH = High[Highest(NULL,0,MODE_HIGH,period,i)];
       MinL = Low[Lowest(NULL,0,MODE_LOW,period,i)];
      price = (High[i]+Low[i])/2;
      Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;     
      Value=MathMin(MathMax(Value,-0.999),0.999); 
      ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      Value1=Value;
      Fish1=ExtBuffer0[i];
         if (ExtBuffer0[i]>0) ExtBuffer1[i]=10; else ExtBuffer1[i]=-10;      
    }

   for(i=limit; i>=0; i--)
   {
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<smooth && (i+k)<Bars; k++)
      {
         double weight = smooth-k;
                sumw  += weight;
                sum   += weight*ExtBuffer1[i+k];  
      }             
      if (sumw!=0)
            ExtBuffer2[i] = sum/sumw;
      else  ExtBuffer2[i] = 0;
   }      
   for(i=0; i<=limit; i++)
   {
      sum  = 0;
      sumw = 0;

      for(k=0; k<smooth && (i-k)>=0; k++)
      {
         weight = smooth-k;
                sumw  += weight;
                sum   += weight*ExtBuffer2[i-k];
      }             
      if (sumw!=0)
            ExtBuffer3[i] = sum/sumw;
      else  ExtBuffer3[i] = 0;
   }      
   for(i=limit; i>=0; i--)
   {
      ExtBuffer4[i]=EMPTY_VALUE;
      ExtBuffer5[i]=EMPTY_VALUE;
      ExtBufferh1[i]=EMPTY_VALUE;
      ExtBufferh2[i]=EMPTY_VALUE;
      if (ExtBuffer3[i]>0) { ExtBuffer4[i]=ExtBuffer3[i]; ExtBufferh1[i]=ExtBuffer3[i]; }
      if (ExtBuffer3[i]<0) { ExtBuffer5[i]=ExtBuffer3[i]; ExtBufferh2[i]=ExtBuffer3[i]; }
      
      if (ExtBuffer3[i+1] < 0 && ExtBuffer3[i] > 0)
      {
         if (DoAlert && i<5 && lastAlertTime!=Time[0])
         {
            sAlertMsg="Solar Wind - "+Symbol()+" "+TF2Str(Period())+": cross UP";
            if (DoAlert)     Alert(sAlertMsg);
            lastAlertTime = Time[0];  
            if (alertMail)   SendMail(sAlertMsg, "MT4 Alert!\n" + TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS )+"\n"+sAlertMsg);   
         }
      }
      else if( ExtBuffer3[i+1] > 0 && ExtBuffer3[i] < 0)
      {
         if (i<5 && lastAlertTime!=Time[0])
         {
            sAlertMsg="Solar Wind - "+Symbol()+" "+TF2Str(Period())+": cross DOWN";
            if (DoAlert)     Alert(sAlertMsg);
            lastAlertTime = Time[0];  
            if (alertMail)   SendMail(sAlertMsg, "MT4 Alert!\n" + TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS )+"\n"+sAlertMsg);   
         }
                     
      }
      
      
   }
   return(0);
}
// function: TF2Str()
// Description: Convert time-frame to a string
//-----------------------------------------------------------------------------
string TF2Str(int iPeriod) {
  switch(iPeriod) {
    case PERIOD_M1: return("M1");
    case PERIOD_M5: return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M30");
    case PERIOD_H1: return("H1");
    case PERIOD_H4: return("H4");
    case PERIOD_D1: return("D1");
    case PERIOD_W1: return("W1");
    case PERIOD_MN1: return("MN1");
    default: return("M"+iPeriod);
  }
}
//+------------------------------------------------------------------+
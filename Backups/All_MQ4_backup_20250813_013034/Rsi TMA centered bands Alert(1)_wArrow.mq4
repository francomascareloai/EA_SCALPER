//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
//modified 9 aug 2020
// - request for arrows

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Orange
#property indicator_color2 DarkGray
#property indicator_color3 Orange
#property indicator_color4 LimeGreen
#property indicator_color5 RoyalBlue
#property indicator_color6 OrangeRed
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
//
//
//
//
//

extern int    RsiLength  = 14;
extern int    RsiPrice   = PRICE_CLOSE;
extern int    HalfLength = 12;
extern int    DevPeriod  = 100;
extern double Deviations = 1.5;
extern bool   AlertOn    = true;
extern bool   ArrowShow  = false;

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];
datetime AlertLast;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int init()
{
   HalfLength=MathMax(HalfLength,1);
         SetIndexBuffer(0,buffer1); 
         SetIndexBuffer(1,buffer2);
         SetIndexBuffer(2,buffer3); 
         SetIndexBuffer(3,buffer4);
         SetIndexBuffer(4,buffer5);
         SetIndexStyle(4,DRAW_ARROW);
         SetIndexArrow(4,233);
         SetIndexBuffer(5,buffer6);
         SetIndexStyle(5,DRAW_ARROW);
         SetIndexArrow(5,234);
   return(0);
}
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i,j,k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-1,Bars-counted_bars+HalfLength);

   //
   //
   //
   //
   //
   
   for (i=limit; i>=0; i--) buffer1[i] = iRSI(NULL,0,RsiLength,RsiPrice,i);
   for (i=limit; i>=0; i--)
   {
      double dev  = iStdDevOnArray(buffer1,0,DevPeriod,0,MODE_SMA,i);
      double sum  = (HalfLength+1)*buffer1[i];
      double sumw = (HalfLength+1);
      for(j=1, k=HalfLength; j<=HalfLength; j++, k--)
      {
         sum  += k*buffer1[i+j];
         sumw += k;
         if (j<=i)
         {
            sum  += k*buffer1[i-j];
            sumw += k;
         }
      }
      buffer2[i] = sum/sumw;
      buffer3[i] = buffer2[i]+dev*Deviations;
      buffer4[i] = buffer2[i]-dev*Deviations;
      buffer5[i]=EMPTY_VALUE;
      buffer6[i]=EMPTY_VALUE;
      if(buffer1[i]>=buffer2[i]&&buffer1[i+1]<buffer2[i+1]){buffer5[i]=buffer2[i];buffer6[i]=EMPTY_VALUE;}
      if(buffer1[i]<buffer2[i]&&buffer1[i+1]>=buffer2[i+1]){buffer6[i]=buffer2[i];buffer5[i]=EMPTY_VALUE;}
   }
   
   //---
   
   if (AlertOn && AlertLast != Time[0]) {
       if (buffer1[0] > buffer3[0] && buffer1[1] < buffer3[1]) {
            AlertLast = Time[0];
            Alert("RSI-TMA :: ", _Symbol, " :: ", eGetPeriodString(), "  >  Touch TOP Band");
       } else if (buffer1[0] < buffer4[0] && buffer1[1] > buffer4[1]) {
            AlertLast = Time[0];
            Alert("RSI-TMA :: ", _Symbol, " :: ", eGetPeriodString(), "  >  Touch BOTTOM Band");
       }
    }   
   
   //---
   
   return(0);
}

string eGetPeriodString()
{
    string periodStr = "??";
    if      (_Period == PERIOD_M1)  { periodStr = "M1";  }
    else if (_Period == PERIOD_M5)  { periodStr = "M5";  }
    else if (_Period == PERIOD_M15) { periodStr = "M15"; }
    else if (_Period == PERIOD_M30) { periodStr = "M30"; }
    else if (_Period == PERIOD_H1)  { periodStr = "H1";  }
    else if (_Period == PERIOD_H4)  { periodStr = "H4";  }
    else if (_Period == PERIOD_D1)  { periodStr = "D1";  }
    else if (_Period == PERIOD_W1)  { periodStr = "W1";  }
    else if (_Period == PERIOD_MN1) { periodStr = "MN1"; }
    //---
    return(periodStr);
}

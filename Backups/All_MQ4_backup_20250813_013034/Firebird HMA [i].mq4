
#property  copyright "Copyright © 2005 TraderSeven"
//---- indicator settings
#property  indicator_chart_window

#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Red
SetIndexStyle( 1,0,0, 1, Blue); 
SetIndexStyle( 2,0,0, 1, Red); 

//---- indicator parameters
extern int HMA_Period=20;
extern double Percentage=2.0;
//---- indicator buffers
double     ind_buffer0[];
double     ind_buffer1[];

int        draw_begin0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   IndicatorBuffers(2);
   if(!SetIndexBuffer(0,ind_buffer0) && !SetIndexBuffer(1,ind_buffer1))
      Print("cannot set indicator buffers!");
//   ArraySetAsSeries(ind_buffer1,true);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   draw_begin0=HMA_Period+MathFloor(MathSqrt(HMA_Period));
   SetIndexDrawBegin(0,draw_begin0);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("HMA("+HMA_Period+")");
   SetIndexLabel(0,"Hull Moving Average");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<1)
     {
      for(i=1;i<=draw_begin0;i++) ind_buffer0[Bars-i]=0;
      for(i=1;i<=HMA_Period;i++) ind_buffer1[Bars-i]=0;
     }
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- MA difference counted in the 1-st buffer
   for(i=1; i<limit+1; i++)
      {
      ind_buffer0[i]=(1+Percentage/100)*iMA(NULL,0,MathFloor(HMA_Period/2),0,MODE_LWMA,PRICE_HIGH,i)*2-
                     iMA(NULL,0,HMA_Period,0,MODE_LWMA,PRICE_HIGH,i);
      ind_buffer1[i]=(1-Percentage/100)*iMA(NULL,0,MathFloor(HMA_Period/2),0,MODE_LWMA,PRICE_HIGH,i)*2-
                     iMA(NULL,0,HMA_Period,0,MODE_LWMA,PRICE_HIGH,i);                     
      }
//---- done
   return(0);
  }
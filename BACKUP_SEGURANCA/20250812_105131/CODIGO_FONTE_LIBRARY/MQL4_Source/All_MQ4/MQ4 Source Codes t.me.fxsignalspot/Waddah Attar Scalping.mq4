#property copyright "Copyright © 2009, Waddah Attar"
#property link      "waddahattar@hotmail.com"
//----
extern int IPeriod=180;
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_level1 0

extern int P1=1;
extern int P2=5;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexStyle(0, DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1, DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(1, ExtMapBuffer2);
  return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
{
  return(0);
}
//+------------------------------------------------------------------+
//| Float Pivot                                                      |
//+------------------------------------------------------------------+
int start()
  {
//----
   int i,j;
   double max,min,pivot,A,B;
   
   i=1000;
   while(i>=0)
   {
     j=iBarShift(Symbol(),P1,Time[i],false);
     max=iHigh(Symbol(),P1,iHighest(Symbol(),P1,MODE_HIGH,IPeriod,j));
     min=iLow(Symbol(),P1,iLowest(Symbol(),P1,MODE_LOW,IPeriod,j));
     pivot=(iClose(Symbol(),P1,j+1)+iClose(Symbol(),P1,j+2)+iClose(Symbol(),P1,j+3))/3;
     A=(Close[i]-((max + min + pivot)/3))/Point;

     j=iBarShift(Symbol(),P2,Time[i],false);
     max=iHigh(Symbol(),P2,iHighest(Symbol(),P2,MODE_HIGH,IPeriod,j));
     min=iLow(Symbol(),P2,iLowest(Symbol(),P2,MODE_LOW,IPeriod,j));
     pivot=(iClose(Symbol(),P2,j+1)+iClose(Symbol(),P2,j+2)+iClose(Symbol(),P2,j+3))/3;
     B=(Close[i]-((max + min + pivot)/3))/Point;


     ExtMapBuffer1[i]=0;
     ExtMapBuffer2[i]=0;
     
     if(A>0 && B>0)
     {
       ExtMapBuffer1[i]=(A+B);
     }

     if(A<0 && B<0)
     {
       ExtMapBuffer2[i]=(A+B);
     }

     i--;
   }
   
   return(0);
  }

#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Yellow
#property  indicator_color2  Green
#property  indicator_color3  Red

#property indicator_level1 0.0

extern int FastLsma =  5; 
extern int SlowLsma = 34; 
extern int MaArray  =  5; 

double     ExtBuffer0[];
double     ExtBuffer1[];
double     ExtBuffer2[];
double     ExtBuffer3[];
double     ExtBuffer4[];

int init()
  {

   IndicatorBuffers(5);

   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);
   IndicatorDigits(Digits+2);
   SetIndexDrawBegin(0,38);
   SetIndexDrawBegin(1,38);
   SetIndexDrawBegin(2,38);

   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
   SetIndexBuffer(3,ExtBuffer3);
   SetIndexBuffer(4,ExtBuffer4);

   IndicatorShortName("ABC");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   return(0);
  }

double LSMA(int Rperiod, int shift)
{
   int i;
   double sum;
   int length;
   double lengthvar;
   double tmp;
   double wt;

   length = Rperiod;
 
   sum = 0;
   for(i = length; i >= 1  ; i--)
   {
     lengthvar = length + 1;
     lengthvar /= 3;
     tmp = 0;
     tmp = ( i - lengthvar)*Close[length-i+shift];
     sum+=tmp;
    }
    wt = sum*6/(length*(length+1));
    
    return(wt);
}


int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;

   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int i=0; i<limit; i++)
      ExtBuffer3[i]=LSMA(FastLsma,i)-LSMA(SlowLsma,i);

   for(i=0; i<limit; i++)
      ExtBuffer4[i]=iMAOnArray(ExtBuffer3,Bars,MaArray,0,MODE_SMA,i);

   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ExtBuffer3[i]-ExtBuffer4[i];
      prev=ExtBuffer3[i+1]-ExtBuffer4[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {
         ExtBuffer2[i]=current*100;
         ExtBuffer1[i]=0.0;
        }
      else
        {
         ExtBuffer1[i]=current*100;
         ExtBuffer2[i]=0.0;
        }
       ExtBuffer0[i]=current*100;
     }
   return(0);
  }
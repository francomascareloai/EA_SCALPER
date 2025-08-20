#property copyright "Copyright © 2008, Borys Chekmasov"
#property link      "http://uatrader.blogspot.com"

#property indicator_separate_window
#property indicator_buffers 2          //Original=2
#property indicator_color1 Gold
#property indicator_color2 Lime

extern string simbol_name1 = "EURUSD";
extern int bars_for_autoscale1 = 200;
extern bool inverse1 = false;
extern bool MA1 = true;
extern int MAPeriod1 = 1;
extern bool MAOnly1 = true;



double simbolBuffer1[];
double MABuffer1[];

// инициализация
int init()
  {
   SetIndexBuffer(0,simbolBuffer1);       
   SetIndexStyle (0,DRAW_LINE);
   SetIndexBuffer(1,MABuffer1);       
   
  
   return (0);
  }
     
//основной цикл                              

int start()
  {
double simbol_scale1 = 1;
double simbol_offset1 = 0;
 int i1,k1;
int cb1=IndicatorCounted();
i1 = Bars-cb1-1;
k1 = bars_for_autoscale1;
if (bars_for_autoscale1==0) k1=Bars;
double max_scale1=iClose(simbol_name1,0,1);
double min_scale1=iClose(simbol_name1,0,1);
double max_scale2=Close[1];
double min_scale2=Close[1];
while(k1>=0) 
      {
      
      if (max_scale1<iClose(simbol_name1,0,k1)) max_scale1=iClose(simbol_name1,0,k1);
      if (min_scale1>iClose(simbol_name1,0,k1)) min_scale1=iClose(simbol_name1,0,k1);
      if (max_scale1<Close[k1])max_scale1=Close[k1];
      if (min_scale1>Close[k1])min_scale1=Close[k1];
    
    
      k1--;
      }

simbol_scale1 = (max_scale1 - min_scale1)/(max_scale1-min_scale1);
      if(!inverse1) 
      {
 simbol_offset1 = max_scale1 - simbol_scale1*max_scale1;
 }
 else
 {
 simbol_offset1 = max_scale1 + simbol_scale1*min_scale1;
 }

while(i1>=0) 
      {
      
        if(!inverse1) 
        {
         if (!MAOnly1) simbolBuffer1[i1]=simbol_scale1*(iClose(simbol_name1,0,i1))+simbol_offset1;
         if (MA1)MABuffer1[i1]=(iMA(simbol_name1,0,MAPeriod1,0,0,PRICE_CLOSE,i1))*simbol_scale1+simbol_offset1;
         }
        else 
        {
        if (!MAOnly1) simbolBuffer1[i1]=simbol_offset1 - simbol_scale1*(iClose(simbol_name1,0,i1));
        if (MA1)MABuffer1[i1]=simbol_offset1 - simbol_scale1*(iMA(simbol_name1,0,MAPeriod1,0,0,PRICE_CLOSE,i1));
        }
          i1--;
      }

   
   return(0);
  }


// Trend Manager.mq4
// Based on indicator sold at traderstradingsystem.com

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int TM_Period = 7;
extern int TM_Shift = 2;

double SpanA_Buffer[];
double SpanB_Buffer[];
int a_begin;

int init()
{
   a_begin=TM_Shift;
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(0,SpanB_Buffer);
   SetIndexDrawBegin(0,TM_Period+a_begin-1);
   SetIndexLabel(0,"TM_Period+");
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(1,SpanA_Buffer);
   SetIndexDrawBegin(1,TM_Period+a_begin-1);
   SetIndexLabel(1,"TM_Period");

   return(0);
}

int start()
{
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double high,low,price;

   if(Bars<=TM_Period) return(0);
   if(counted_bars<1)
   {
      for(i=1;i<=TM_Period;i++) 
      {
         SpanA_Buffer[Bars-i]=0;
         SpanB_Buffer[Bars-i]=0;
      }
   }

   i=Bars-TM_Period;
   if(counted_bars>TM_Period) i=Bars-counted_bars-1;
   while(i>=0)
   {
      high=High[i]; low=Low[i]; k=i-1+TM_Period;
      while(k>=i)
      {
         price=High[k];
         if(high<price) high=price;
         price=Low[k];
         if(low>price)  low=price;
         k--;
      }
      SpanA_Buffer[i]  = (high+low)/2.0;
      SpanB_Buffer[i]  = SpanA_Buffer[i+TM_Shift];
      i--;
   }

   return(0);
}
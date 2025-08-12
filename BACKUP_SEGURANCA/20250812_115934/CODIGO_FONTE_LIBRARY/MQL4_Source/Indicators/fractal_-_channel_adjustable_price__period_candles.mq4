//+------------------------------------------------------------------+
//|                                     Fractals - adjustable period |
//+------------------------------------------------------------------+
#property link      "www.forex-tsd.com"
#property copyright "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property indicator_color3  clrBlue
#property indicator_color4  clrRed
#property indicator_color5  clrYellow
#property indicator_color6  clrYellow
#property indicator_color7  clrYellow
#property indicator_color8  clrYellow
#property indicator_color9  clrDeepSkyBlue
#property indicator_color10 clrPaleVioletRed
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  2
#property indicator_width8  2

//
//
//
//
//

extern int                FractalPeriod   = 25;
extern ENUM_APPLIED_PRICE PriceHigh       = PRICE_HIGH;
extern ENUM_APPLIED_PRICE PriceLow        = PRICE_LOW;
extern bool               ShowChannel     = true;



double frhu[];
double frhd[];
double frhbu[];
double frhbd[];
double frnu[];
double frnd[];
double frnbu[];
double frnbd[];
double UpperBuffer[];
double LowerBuffer[];
double trend[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{ 
   IndicatorBuffers(11);
   SetIndexBuffer(0,frhu);  SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,frhd);  SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,frhbu); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,frhbd); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,frnu);  SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(5,frnd);  SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexBuffer(6,frnbu); SetIndexStyle(6,DRAW_HISTOGRAM);
   SetIndexBuffer(7,frnbd); SetIndexStyle(7,DRAW_HISTOGRAM);
   SetIndexBuffer(8,UpperBuffer); 
   SetIndexBuffer(9,LowerBuffer);
   SetIndexBuffer(10,trend);
   if (ShowChannel)
   {
     SetIndexStyle(8,DRAW_LINE);
     SetIndexStyle(9,DRAW_LINE);
   }
   else
   {
     SetIndexStyle(8,DRAW_NONE);
     SetIndexStyle(9,DRAW_NONE);
   }          
return(0);
}
int deinit() {  return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(MathMax(Bars-counted_bars,FractalPeriod),Bars-1);

   //
   //
   //
   //
   //

     int half = FractalPeriod/2;
     for(i=limit; i>=0; i--)
     {
         bool   found     = true;
         double compareTo = iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i);
         for (int k=1;k<=half;k++)
            {
               if ((i+k)<Bars && iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i+k)> compareTo) { found=false; break; }
               if ((i-k)>=0   && iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i-k)>=compareTo) { found=false; break; }
            }
         if (found) UpperBuffer[i]=iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i);
         else       UpperBuffer[i]=UpperBuffer[i+1];

         //
         //
         //
         //
         //
      
         found     = true;
         compareTo = iMA(NULL,0,1,0,MODE_SMA,PriceLow,i);
         for (k=1;k<=half;k++)
            {
               if ((i+k)<Bars && iMA(NULL,0,1,0,MODE_SMA,PriceLow,i+k)< compareTo) { found=false; break; }
               if ((i-k)>=0   && iMA(NULL,0,1,0,MODE_SMA,PriceLow,i-k)<=compareTo) { found=false; break; }
            }
         if (found) LowerBuffer[i]=iMA(NULL,0,1,0,MODE_SMA,PriceLow,i);  
         else       LowerBuffer[i]=LowerBuffer[i+1];
         
         //
         //
         //
         //
         //
         
         frhu[i]  = EMPTY_VALUE;
         frhd[i]  = EMPTY_VALUE;
         frhbu[i] = EMPTY_VALUE;
         frhbd[i] = EMPTY_VALUE;
         frnu[i]  = EMPTY_VALUE;
         frnd[i]  = EMPTY_VALUE;
         frnbu[i] = EMPTY_VALUE;
         frnbd[i] = EMPTY_VALUE;
         trend[i] = trend[i+1];;
         if (Close[i]>UpperBuffer[i])                          trend[i] = 1;
         if (Close[i]<LowerBuffer[i])                          trend[i] =-1;
         if (Close[i]<UpperBuffer[i]&&Close[i]>LowerBuffer[i]) trend[i] = 0;
         if (trend[i] == 1)
         {
            frhu[i]  = High[i]; 
            frhd[i]  = Low[i];
            frhbu[i] = MathMax(Open[i],Close[i]);
            frhbd[i] = MathMin(Open[i],Close[i]);
          }               
          if (trend[i] == -1)
          {
             frhu[i]  = Low[i];
             frhd[i]  = High[i];
             frhbu[i] = MathMin(Open[i],Close[i]);
             frhbd[i] = MathMax(Open[i],Close[i]);
           }
           if (trend[i] == 0)
           {
             frnu[i]  = Low[i];
             frnd[i]  = High[i];
             frnbu[i] = MathMin(Open[i],Close[i]);
             frnbd[i] = MathMax(Open[i],Close[i]);
            }                     
   }
return(0);
}
   
   
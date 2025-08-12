//+------------------------------------------------------------------+
//|                                     2 Bar Reversal indicator.mq4 |
//|                         Copyright © 2008-2010, TradingSytemForex |
//|                                http://www.tradingsystemforex.com |
//+------------------------------------------------------------------+

#property copyright ""
#property link ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 OrangeRed

double CrossUp[];
double CrossDown[];
double prevtime;
double Range,AvgRange;
double LimeRmonow,LimeRmoprevious;
double GoldRmonow,GoldRmoprevious;
/*
extern int MALength=2;
extern int Depth=10;
extern int SignalsSmooth=30;
extern int Smooth=81;
extern int Price=PRICE_CLOSE;
*/
double pt,mt;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+

int init()
{
   if(Digits==3 || Digits==5){
      pt=Point*10;
      mt=10;
   }else{
      pt=Point;
      mt=1;
   }
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,EMPTY,2);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,CrossUp);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,2);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,CrossDown);
//----
   return(0);
}
  
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+

int deinit()
{
//---- 

//----
   return(0);
}

//+------------------------------------------------------------------+
//| Iteration                                                        |
//+------------------------------------------------------------------+

int start()
{
   int limit,i,counter;
   int counted_bars=IndicatorCounted();

   if(counted_bars<0)return(-1);
   if(counted_bars>0)counted_bars--;
   
   limit=Bars-counted_bars;
   
   for(i=0;i<=limit;i++){
      counter=i;
      Range=0;
      AvgRange=0;
      for(counter=i;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      
      if(Close[i+3]>Open[i+3] && Close[i+2]<Open[i+2] && Close[i+1]<Open[i+1] && Close[i]>Open[i] && Close[i+1]<Low[i+2] && Close[i]>High[i+1]+1*pt){
         CrossUp[i]=Low[i]-Range*0.5;
      }
      if(!(Close[i+3]>Open[i+3] && Close[i+2]<Open[i+2] && Close[i+1]<Open[i+1] && Close[i]>Open[i] && Close[i+1]<Low[i+2] && Close[i]>High[i+1]+1*pt)){
         CrossUp[i]=EMPTY_VALUE;
      }
      if(Close[i+3]<Open[i+3] && Close[i+2]>Open[i+2] && Close[i+1]>Open[i+1] && Close[i]<Open[i] && Close[i+1]>High[i+2] && Close[i]<Low[i+1]-1*pt){
         CrossDown[i]=High[i]+Range*0.5;
      }
      if(!(Close[i+3]<Open[i+3] && Close[i+2]>Open[i+2] && Close[i+1]>Open[i+1] && Close[i]<Open[i] && Close[i+1]>High[i+2] && Close[i]<Low[i+1]-1*pt)){
         CrossDown[i]=EMPTY_VALUE;
      }
   }
   if((CrossUp[0]>2000) && (CrossDown[0]>2000)){prevtime=0;}
   if((CrossUp[0]==Low[0]-Range*0.5) && (prevtime!=Time[0])){
      prevtime=Time[0];
      Alert(Symbol()," 2 Bar Reversal Up @  Hour ",Hour(),"  Minute ",Minute());
   } 
   if((CrossDown[0]==High[0]+Range*0.5) && (prevtime!=Time[0])){
      prevtime=Time[0];
      Alert(Symbol()," 2 Bar Reversal Down @  Hour ",Hour(),"  Minute ",Minute());
   }
   return(0);
 }


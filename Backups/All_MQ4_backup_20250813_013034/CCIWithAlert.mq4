//+------------------------------------------------------------------+
//|                                                          CCI.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 LightSeaGreen
//---- input parameters
extern int CCIPeriod=14;
extern int CCIHigh=100;
extern int CCILow=-100;
int PlayedSoundH = False;

int PlayedSoundL = False;
//---- buffers
double CCIBuffer[];
double RelBuffer[];
double DevBuffer[];
double MovBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(4);
   SetIndexBuffer(1, RelBuffer);
   SetIndexBuffer(2, DevBuffer);
   SetIndexBuffer(3, MovBuffer);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,CCIBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="CCI("+CCIPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,CCIPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Commodity Channel Index                                          |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k,counted_bars=IndicatorCounted();
   double price,sum,mul;
   if(Bars<=CCIPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=CCIPeriod;i++) CCIBuffer[Bars-i]=0.0;
      for(i=1;i<=CCIPeriod;i++) DevBuffer[Bars-i]=0.0;
      for(i=1;i<=CCIPeriod;i++) MovBuffer[Bars-i]=0.0;
     }
//---- last counted bar will be recounted
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++;
//---- moving average
   for(i=0; i<limit; i++)
      MovBuffer[i]=iMA(NULL,0,CCIPeriod,0,MODE_SMA,PRICE_TYPICAL,i);
//---- standard deviations
   i=Bars-CCIPeriod+1;
   if(counted_bars>CCIPeriod-1) i=Bars-counted_bars-1;
   mul=0.015/CCIPeriod;
   while(i>=0)
     {
      sum=0.0;
      k=i+CCIPeriod-1;
      while(k>=i)
       {
         price=(High[k]+Low[k]+Close[k])/3;
         sum+=MathAbs(price-MovBuffer[i]);
         k--;
       }
      DevBuffer[i]=sum*mul;
      i--;
     }
   i=Bars-CCIPeriod+1;
   if(counted_bars>CCIPeriod-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      price=(High[i]+Low[i]+Close[i])/3;
      RelBuffer[i]=price-MovBuffer[i];
      i--;
     }
//---- cci counting
   i=Bars-CCIPeriod+1;
   if(counted_bars>CCIPeriod-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      if(DevBuffer[i]==0.0) CCIBuffer[i]=0.0;
      else CCIBuffer[i]=RelBuffer[i]/DevBuffer[i];
      i--;
     }
   if(CCIBuffer[0]<CCIHigh){PlayedSoundH = False;}
   
   if(CCIBuffer[0]>CCILow){PlayedSoundL = False;}  
   
   if(CCIBuffer[0]>=CCIHigh && PlayedSoundH == False){
    PlaySound("alert.wav");
    PlayedSoundH = True;}
    
   if(CCIBuffer[0]<=CCILow && PlayedSoundL == False){
    PlaySound("alert.wav");
    PlayedSoundL = True;}
//----
   return(0);
  }
//+------------------------------------------------------------------+
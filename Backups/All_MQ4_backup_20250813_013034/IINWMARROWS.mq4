//+------------------------------------------------------------------+
//|                                                  IINWMARROWS.mq4 |
//|                                           Based on EMA_CROSS.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                           Last little modified by Iin Zulkarnain |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 0
#property indicator_width2 0
//----
double CrossUp[];
double CrossDown[];
extern int FasterMA=  5;
extern int SlowerMA=  8;
extern string note1 = "Faster/Slower Mode Option",
note2 = "0=sma, 1=ema, 2=smma, 3=lwma";
extern int FasterMode=1; //0=sma, 1=ema, 2=smma, 3=lwma
extern int SlowerMode=1; //0=sma, 1=ema, 2=smma, 3=lwma
extern string note3 = "Your Alert Options",
note4 = "true using your wav file",
note5 = "false using default alert";
extern bool YourAlert=false;

double alertTag;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,EMPTY);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,CrossUp);
   SetIndexStyle(1,DRAW_ARROW,EMPTY);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,CrossDown);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i,counter;
   double fasterMAnow,slowerMAnow,fasterMAprevious,slowerMAprevious,fasterMAafter,slowerMAafter;
   double Range,AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
//----
   limit=Bars-counted_bars;
   for(i=0; i<=limit; i++)
     {
      counter=i;
      Range=0;
      AvgRange=0;
      for(counter=i;counter<=i+9;counter++)
        {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
        }
      Range=AvgRange/10;
      fasterMAnow=iMA(NULL,0,FasterMA,0,FasterMode,PRICE_CLOSE,i);
      fasterMAprevious=iMA(NULL,0,FasterMA,0,FasterMode,PRICE_CLOSE,i+1);
      fasterMAafter=iMA(NULL,0,FasterMA,0,FasterMode,PRICE_CLOSE,i-1);
      //----
      slowerMAnow=iMA(NULL,0,SlowerMA,0,SlowerMode,PRICE_OPEN,i);
      slowerMAprevious=iMA(NULL,0,SlowerMA,0,SlowerMode,PRICE_OPEN,i+1);
      slowerMAafter=iMA(NULL,0,SlowerMA,0,SlowerMode,PRICE_OPEN,i-1);
      if((fasterMAnow>slowerMAnow) && (fasterMAprevious<
         slowerMAprevious) && (fasterMAafter>slowerMAafter)) 
        {
         CrossUp[i]=Low[i]-Range*0.5;
         if(alertTag!=Time[0])
           {
            if(YourAlert==false)
              {
               Alert(Symbol(),"  M",Period()," IINWMARROWS BUY");
              }
            else
              {
               PlaySound("alert1.wav");// buy wav
              }
           }
         alertTag=Time[0];
        }
      else
        {
         CrossUp[i]=0;
         if((fasterMAnow<slowerMAnow) && (fasterMAprevious>
            slowerMAprevious) && (fasterMAafter<slowerMAafter)) 
           {
            CrossDown[i] = High[i] + Range*0.5;
            if( alertTag!=Time[0])
              {
               if(YourAlert==false)
                 {
                  Alert(Symbol(),"  M",Period()," IINWMARROWS SELL");
                 }
               else
                 {
                  PlaySound("alert2.wav"); //sell wav
                 }
              }
            alertTag=Time[0];
           }
         else
           {
            CrossDown[i]=0;
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------+
//|                                           MTF_MA_Channel.mq4                 |
//|                                      Copyright © 2010, Wildhorse Enterprises |
//|                                                                              |
//+------------------------------------------------------------------------------+
#property copyright "Copyright © 2010, Wildhorse Enterprises"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

//#property indicator_color3 MediumSeaGreen

extern int TimeFrame=0;
extern int TrixPeriod=4;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
//double ExtMapBuffer3[];
int init() {
   switch(TimeFrame) {
      case 1 : string TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr="Period "+Period();
      } 
   string short_name="MTF Trix Trend Cycle v2a";
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexLabel(0,TimeFrameStr+" Long");
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexLabel(1,TimeFrameStr+" Short");
   /*SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(2,DRAW_LINE,STYLE_DASH);
   SetIndexLabel(2,TimeFrameStr+" Median");*/
   IndicatorShortName(short_name+"("+TrixPeriod+") "+TimeFrameStr);  
   return(0);
}
 
int start() {
   datetime TimeArray[];
   int i,shift,limit,y=0,counted_bars=IndicatorCounted();
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   limit=Bars-counted_bars+TimeFrame/Period();
   for(i=0,y=0;i<limit;i++) {
      if (Time[i]<TimeArray[y]) y++; 
      ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"Trix Trend Cycle v2a",TrixPeriod,1,y);
      ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"Trix Trend Cycle v2a",TrixPeriod,2,y);
      //ExtMapBuffer3[i]=(ExtMapBuffer1[i]+ExtMapBuffer2[i])/2.0;
      }  
   return(0);
}


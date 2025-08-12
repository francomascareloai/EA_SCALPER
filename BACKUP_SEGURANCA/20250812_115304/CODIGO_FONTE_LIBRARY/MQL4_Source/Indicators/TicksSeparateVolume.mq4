//+------------------------------------------------------------------+
//|                                          TicksSeparateVolume.mq4 |
//|                                    Copyright © 2008, FOREXflash. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, FOREXflash Software Corp."
#property link      "http://www.metaquotes.net"
//-----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_minimum 0

#property indicator_color1 Lime
#property indicator_color2 Red

double UpTicks[];
double DownTicks[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("TicksSeparateVolume("+Symbol()+")");
  
   SetIndexBuffer(0,UpTicks);
   SetIndexBuffer(1,DownTicks);
  
   SetIndexStyle(0,DRAW_HISTOGRAM,0,3);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,2);
   
   SetIndexLabel(0,"UpTicks");
   SetIndexLabel(1,"DownTicks");
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
  
   ObjectDelete("UpTicks1");
   ObjectDelete("DownTicks1");
   ObjectDelete("UpTicks2");
   ObjectDelete("DownTicks2");
  
  Comment("");
  
  return(0);
  }
//+------------------------------------------------------------------+
//| Ticks Volume Indicator                                           |
//+------------------------------------------------------------------+
int start()
  {
  
   ObjectDelete("UpTicks1");
   ObjectDelete("DownTicks1");
   ObjectDelete("UpTicks2");
   ObjectDelete("DownTicks2");
   
   int i,counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   

//----
   for(i=0; i<limit; i++)
     {
      UpTicks[i]=(Volume[i]+(Close[i]-Open[i])/Point)/2;
      DownTicks[i]=Volume[i]-UpTicks[i];
     }
     
string BV="BUYERS VOLUME: "+DoubleToStr(UpTicks[0],0)+"";
string SV="SELLERS VOLUME: "+DoubleToStr(DownTicks[0],0)+"";
     
   
   ObjectCreate("UpTicks2", OBJ_LABEL, WindowFind("TicksSeparateVolume("+Symbol()+")"), 0, 0);
   ObjectSetText("UpTicks2",StringSubstr((BV),0), 10, "Tahoma Bold" ,White);
   ObjectSet("UpTicks2", OBJPROP_CORNER, 0);
   ObjectSet("UpTicks2", OBJPROP_XDISTANCE, 5);
   ObjectSet("UpTicks2", OBJPROP_YDISTANCE, 16);
   
   ObjectCreate("DownTicks2", OBJ_LABEL, WindowFind("TicksSeparateVolume("+Symbol()+")"), 0, 0);
   ObjectSetText("DownTicks2",StringSubstr((SV),0), 10, "Tahoma Bold" ,White);
   ObjectSet("DownTicks2", OBJPROP_CORNER, 0);
   ObjectSet("DownTicks2", OBJPROP_XDISTANCE, 5);
   ObjectSet("DownTicks2", OBJPROP_YDISTANCE, 30);

//----
   return(0);
  }
//+------------------------------------------------------------------+
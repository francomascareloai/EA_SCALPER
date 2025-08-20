//+------------------------------------------------------------------+
//|                                               ZigZag Pointer.mq4 |
//|                                    zigzag modified by Dr. Gaines |
//|                                      dr_richard_gaines@yahoo.com |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "dr_richard_gaines"
#property link      "http://www.metaquotes.net/"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 1
//---- indicator parameters
extern int ExtDepth=100;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
//---- drawing settings
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1, 234);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
//---- indicator short name
   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
//----
   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
     ExtMapBuffer[shift]= 0;
     ExtMapBuffer2[shift]=0;
     
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else
        {
         lastlow=val;
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0;
              }
           }
        }
      ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0;
              }
           }
        }
      ExtMapBuffer2[shift]=val;
     }
   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;
//----
   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0)
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           }
         lasthigh=-1;
        }
     }
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         if(res!=0.0) ExtMapBuffer2[shift]=res;
        }
     }
  }
//+------------------------------------------------------------------+
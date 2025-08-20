//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 1999-2008, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 4
//----
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
//---- indicator parameters
extern int TargetPeriod=34;
extern int FiboPeriod=17;
extern bool ShowTarget=true;
extern bool ShowFiboLines=false;
extern bool ShowHighLow=false;
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double zzL[];
double zzH[];
double zz[];
double target1=0,target2=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(3,ExtMapBuffer4);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int deinit()
  {
//----
   ObjectDelete("Target1=");
   ObjectDelete("Target2=");
   ObjectDelete("TargetUp");
   ObjectDelete("TargetDown");
   ObjectDelete("TP1");
   ObjectDelete("TP2");
   ObjectDelete("R0");
   ObjectDelete("R1");
   ObjectDelete("R2");
   ObjectDelete("R3");
   ObjectDelete("R4");
   ObjectDelete("R5");
   ObjectDelete("LH");
   ObjectDelete("LL");
   ObjectDelete("Low");
   ObjectDelete("High");
   ObjectDelete("1.0");
   ObjectDelete("0.618");
   ObjectDelete("0.5");
   ObjectDelete("0.382");
   ObjectDelete("0.236");
   ObjectDelete("0.0");
   Comment(" ");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    i,shift,pos,lasthighpos,lastlowpos,curhighpos,curlowpos;
   int    targethighpos,targetlowpos;
   double curlow,curhigh,lasthigh,lastlow,targethigh,targetlow;
   double min, max;
//----
   lasthighpos=Bars; lastlowpos=Bars;
   lastlow=Low[Bars];lasthigh=High[Bars];
   targethighpos=Bars; targetlowpos=Bars;
   targetlow=Low[Bars];targethigh=High[Bars];
//----
   for(shift=Bars-FiboPeriod; shift>=0; shift--)
     {
      curlowpos=Lowest(NULL,0,MODE_LOW,FiboPeriod,shift);
      curlow=Low[curlowpos];
      curhighpos=Highest(NULL,0,MODE_HIGH,FiboPeriod,shift);
      curhigh=High[curhighpos];
        if(shift<Bars-TargetPeriod)
        {
         targetlowpos=Lowest(NULL,0,MODE_LOW,TargetPeriod,shift);
         targetlow=Low[targetlowpos];
         targethighpos=Highest(NULL,0,MODE_HIGH,TargetPeriod,shift);
         targethigh=High[targethighpos];
        }
      //------------------------------------------------
      if(curlow>=lastlow){ lastlow=curlow; }
      else
        {
         if(lasthighpos>curlowpos )
           {
            zzL[curlowpos]=curlow;
            min=100000; pos=lasthighpos;
            for(i=lasthighpos; i>=curlowpos; i--)
              {
               if (zzL[i]==0.0) continue;
               if (zzL[i]<min) { min=zzL[i]; pos=i; }
               zz[i]=0.0;
              }
            zz[pos]=min;
           }
         lastlowpos=curlowpos;
         lastlow=curlow;
        }
      //--- high
      if(curhigh<=lasthigh) { lasthigh=curhigh;}
      else
        {
         if(lastlowpos>curhighpos)
           {
            zzH[curhighpos]=curhigh;
            max=-100000; pos=lastlowpos;
            for(i=lastlowpos; i>=curhighpos; i--)
              {
               if (zzH[i]==0.0) continue;
               if (zzH[i]>max) { max=zzH[i]; pos=i; }
               zz[i]=0.0;
              }
            zz[pos]=max;
           }
         lasthighpos=curhighpos;
         lasthigh=curhigh;
        }
      double p, r5,r4,r3,r2,r1,r0;
      double R2= targethigh - targetlow;
      double R1= lasthigh - lastlow;
      double R= High[lasthighpos] - Low[lastlowpos];
      int div=10000;
      color Line_color=Green;
      color Target_color=Red;
      if(Digits==2)div=100;
      if(Digits==4)div=10000;
//----
      ExtMapBuffer1[shift]=0;
      ExtMapBuffer2[shift]=0;
      ExtMapBuffer3[shift]=0;
      ExtMapBuffer4[shift]=0;
//----
        if(lastlowpos<lasthighpos) 
        {
         p=curlow;
         r5=p + (R * 1);
         r4=p + (R * 0.618);
         r3=p + (R * 0.5);
         r2=p + (R * 0.382);
         r1=p + (R * 0.236);
         r0=p + (R * 0);
         if(Close[0]>(targetlow+(R2*0.618)) )target1= targethigh + (R2 * 0.618);
         if(Close[0]>target1)target1= 0;
         if(Close[shift]>(curlow+(R1*0.382)))ExtMapBuffer4[shift]=((Close[shift]-curlow)-R1)*div;
         else  ExtMapBuffer3[shift]=((Close[shift]-curlow)-R1)*div;
        }
        if(lasthighpos<lastlowpos) 
        {
         p=curhigh;
         r5=p - (R * 1);
         r4=p - (R * 0.618);
         r3=p - (R * 0.5);
         r2=p - (R * 0.382);
         r1=p - (R * 0.236);
         r0=p - (R * 0);
         if(Close[0]<(targethigh-(R2*0.618)) )target2= targetlow - (R2 * 0.618);
         if(Close[0]<target2 )target2= 0;
         if(Close[shift]<(curhigh-(R1*0.382)))ExtMapBuffer2[shift]=(R1-(curhigh-Close[shift]))*div;
         else  ExtMapBuffer1[shift]=(R1-(curhigh-Close[shift]))*div;
        }
        if(ShowHighLow==true)
        {
         drawLine(High[lasthighpos],"LH", Line_color,1);
         drawLabel("High",High[lasthighpos],Line_color,13);
         drawLine(Low[lastlowpos],"LL", Line_color,1);
         drawLabel("Low",Low[lastlowpos],Line_color,13);
        }
        if(ShowHighLow==false && ShowFiboLines==true)
        {
         drawLine(r5,"R5", Yellow,2);
         drawLabel("1.0",r5,Yellow,13);
         drawLine(r0,"R0", Yellow,2);
         drawLabel("0.0",r0,Yellow,13);
        }
        if(ShowFiboLines==true)
        {
         drawLine(r4,"R4", Yellow,2);
         drawLabel("0.618",r4,Yellow,13);
         drawLine(r3,"R3", Yellow,2);
         drawLabel("0.5",r3,Yellow,13);
         drawLine(r2,"R2", Yellow,2);
         drawLabel("0.382",r2,Yellow,13);
         drawLine(r1,"R1", Yellow,2);
         drawLabel("0.236",r1,Yellow,13);
        }
        if(target1>0 && ShowTarget==true)
        {
         drawLine(target1,"TP1", Target_color,2);
         drawLabel("TargetUp",target1,Target_color,7);
         drawTarget("Target1=",target1,Target_color,1);
        }
        if(target2>0 && ShowTarget==true)
        {
         drawLine(target2,"TP2", Target_color,2);
         drawLabel("TargetDown",target2,Target_color,7);
         drawTarget("Target2=",target2,Target_color,2);
        }
     }
  
  return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void drawTarget(string name,double lvl,color Color,int num)
  {
   string target=DoubleToStr(lvl, Digits);
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
     if(num==1)
     {
      ObjectSet(name, OBJPROP_XDISTANCE, 340);
      ObjectSet(name, OBJPROP_YDISTANCE, 2);
      ObjectSetText(name, "Target UP = "+target, 9, "Arial", Lime);
     }
     if(num==2)
     {
      ObjectSet(name, OBJPROP_XDISTANCE, 470);
      ObjectSet(name, OBJPROP_YDISTANCE, 2);
      ObjectSetText(name, "Target DOWN = "+target, 9, "Arial", Lime);
     }
  }
//+------------------------------------------------------------------+
void drawLabel(string name,double lvl,color Color,int time)
  {
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(name, OBJ_TEXT, 0, Time[time], lvl);
      ObjectSetText(name, name, 8, "Arial", EMPTY);
      ObjectSet(name, OBJPROP_COLOR, Color);
     }
   else
     {
      ObjectMove(name, 0, Time[time], lvl);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawLine(double lvl,string name, color Col,int type)
  {
   if(ObjectFind(name)!=0)
     {
        if(type==1)
        {
         ObjectCreate(name, OBJ_HLINE, 0, Time[0], lvl,Time[0],lvl);
         ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);

        }
        else 
        {
         ObjectCreate(name, OBJ_GANNLINE, 0, Time[15], lvl,Time[0],lvl);
         ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        }
      ObjectSet(name, OBJPROP_COLOR, Col);
      ObjectSet(name,OBJPROP_WIDTH,1);
     }
   else
     {
      ObjectDelete(name);
        if(type==1)
        {
         ObjectCreate(name, OBJ_HLINE, 0, Time[0], lvl,Time[0],lvl);
         ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        }
        else 
        {
         ObjectCreate(name, OBJ_GANNLINE, 0, Time[15], lvl,Time[0],lvl);
         ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        }
      ObjectSet(name, OBJPROP_COLOR, Col);
      ObjectSet(name,OBJPROP_WIDTH,1);
     }
  }
//+------------------------------------------------------------------+
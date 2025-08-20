//+------------------------------------------------------------------+
//|                                       Louw Coetzer aka FX Sniper |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, Fx Sniper."
#property  link      "http://www.dunno.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Red


// Ergo Variables

extern int pq =2;
extern int pr = 10;
extern int ps = 5;
extern int trigger =3;

//---- indicator buffers

string signal;
double mtm[];
double absmtm[];
double ErgoCCI[];
double MainCCI[];
double var1[];
double var2[];
double var2a[];
double var2b[];
//double valor1[];
//double valor2[];
//double extvar[];
//double cciSignal[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(8);
   
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,Blue);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,Red);
   
   SetIndexBuffer(0,ErgoCCI);
   SetIndexLabel(0,"Egodic CCI");
   SetIndexBuffer(1,MainCCI);
   SetIndexLabel(1,"Trigger Line");
   SetIndexBuffer(2,mtm);
   SetIndexBuffer(3,var1);
   SetIndexBuffer(4,var2);
   SetIndexBuffer(5,absmtm);
   SetIndexBuffer(6,var2a);
   SetIndexBuffer(7,var2b);
      
//---- name for DataWindow and indicator subwindow label

   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculations                                    |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int i;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
 
//---- main loop
   
//---- done

   for(i=0; i <= Bars; i++) 
   {
   mtm[i]= Close[i]- Close[i +1];
   }
   for(i=0; i <= Bars-1; i++) 
   { 
    absmtm[i] =  MathAbs(mtm[i]);
   }
   for(i=0; i <= Bars-1; i++) 
   {   
    var1[i]= iMAOnArray(mtm,0,pq,0,MODE_EMA,i);
   }
   for(i=0; i <= Bars-1; i++) 
   {
   var2[i]= iMAOnArray(var1,Bars,pr,0,MODE_EMA,i);
   }
   for(i=0; i <= Bars-1; i++) 
   {
   var2a[i]= iMAOnArray(absmtm,0,pq,0,MODE_EMA,i);
   }
   for(i=0; i <= Bars-1; i++) 
   {
   var2b[i]= iMAOnArray(var2a,0,pr,0,MODE_EMA,i);
   }
    for(i=0; i <= Bars-1; i++) 
   {   
   ErgoCCI[i] = (500 * iMAOnArray(var2,0,ps,0,MODE_EMA,i))/(iMAOnArray(var2b,0,ps,0,MODE_EMA,i)); //var2a[i]/var2b[i];
   
   }
   for(i=0; i<=Bars; i++)
   {
     MainCCI[i]=iMAOnArray(ErgoCCI,0,trigger,0,MODE_EMA,i);
   }
   
   for(i=0; i<=Bars; i++)
   {
      if(MainCCI[i] > ErgoCCI[i])
      {signal = "SHORT";}
      if (MainCCI[i] < ErgoCCI[i])
      {signal = "LONG";}
      if (MainCCI[i] == ErgoCCI[i])
      {signal = "NEUTRAL";}
 
    IndicatorShortName("FX Sniper's Ergodic CCI & Trigger: "+signal);
   return(0); }
  }
//+------------------------------------------------------------------+


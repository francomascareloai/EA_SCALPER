//+------------------------------------------------------------------+
//|                                                   WoodiesCCI.mq4 |
//|                                                            thorr |
//|                                modded by Forex-Ausbilder.de      |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Forex-Ausbilder"
#property link      "http://www.forex-ausbilder.de"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Black
#property indicator_width1 2
#property indicator_color2 Black
#property indicator_width2 2
#property indicator_color3 Yellow
#property indicator_width3 3
#property indicator_color4 Red
#property indicator_width4 3
#property indicator_color5 Lime
#property indicator_width5 3
//---- input parameters
extern double       A_period=10;
 int       B_period=8;
 int       neutral = 0;
extern int       num_bars=1000;
extern bool UseAlert = true;
extern bool UseEmail = false;
extern bool UseStochFilter = true;
extern string xs_0001 = "Stoch settings";
extern int xi_TF.1 = 60;
extern int xi_KPeriod.1 = 14;
extern int xi_DPeriod.1 = 3;
extern int xi_Slowing.1 = 3;
extern int xi_MA.1 = 3;
extern int xi_PF.1 = 1;

extern int xi_TF.2 = 240;
extern int xi_KPeriod.2 = 10;
extern int xi_DPeriod.2 = 3;
extern int xi_Slowing.2 = 3;
extern int xi_MA.2 = 3;
extern int xi_PF.2 = 1;

extern int StochShift = 0;
// parameters
int i=0;
bool initDone=true;
int bar=0;
int prevbars=0;
int startpar=0;
int cs=0;
int prevcs=0;
string commodt="nonono";
int frame=0;
int bars=0;

int count = 0, thisbar = 0;
double now, prev;
bool flag;

//---- buffers
double FastWoodieCCI[];
double SlowWoodieCCI[];
double HistoWoodieCCI[];
double HistoRed[];
double HistoBlue[];
datetime dt;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(0,FastWoodieCCI);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(1,SlowWoodieCCI);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(2,HistoWoodieCCI);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(3,HistoRed);
   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(4,HistoBlue);
   IndicatorShortName("RF");
//----
   return(0);
 
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();

   cs = A_period + B_period + num_bars; //checksum used to see if parameters have been changed

   if ((cs==prevcs) && (commodt == Symbol()) && 
      (frame == (Time[4] - Time[5])) &&
      ((Bars - prevbars) < 2))
      startpar = Bars - prevbars; 
   else 
      startpar = -1;  //params haven't changed only need to calculate new bar

   commodt = Symbol();
   frame= Time[4] - Time[5];
   prevbars = Bars;
   prevcs = cs;

   if (startpar == 1 | startpar == 0)  
      bar = startpar;
   else 
      initDone = true;

   if (initDone) {
      //FastWoodieCCI[num_bars-1]=0;
      SlowWoodieCCI[num_bars-1]=0;
      HistoWoodieCCI[num_bars-1]=0;
      HistoBlue[num_bars-1]=0;
      HistoRed[num_bars-1]=0;
      bar=num_bars-2;
      initDone=false;
   }

   for (i = bar; i >= 0; i--) {
      //FastWoodieCCI[i]=iCCI(NULL,0,B_period,PRICE_TYPICAL,i);
      //SlowWoodieCCI[i]=iCCI(NULL,0,A_period,PRICE_TYPICAL,i);
      
      now = iCCI(NULL,0,A_period,PRICE_TYPICAL,i);

      if ((prev >= 0 && now < 0) || (prev < 0 && now >= 0))
      { // change of sign detected
         
         
         HistoWoodieCCI[i] = now;
         HistoBlue[i] = EMPTY_VALUE;
         HistoRed[i] = EMPTY_VALUE;
         prev = now;
        
      } else
      {
      
      // Colour it!
         if (now > 0)
         {
            HistoBlue[i] = now;
            HistoWoodieCCI[i] = EMPTY_VALUE;
         }
         if (now < 0)
         {
            HistoRed[i] = now;
            HistoWoodieCCI[i] = EMPTY_VALUE;
         }
         prev = now;
      }

   }
   if(dt==Time[0]) return(0);
   dt = Time[0];
   if(HistoWoodieCCI[1] != EMPTY_VALUE)
   {
      if(UseAlert) 
      {
         
         if(UseStochFilter)
         {
//            double prevStoch = iStochastic(Symbol(),60,14,3,3,MODE_EMA,0,0,StochShift+1);
//            double currStoch = iStochastic(Symbol(),60,14,3,3,MODE_EMA,0,0,StochShift);
            double prvStoch.1 = iStochastic(NULL,xi_TF.1,xi_KPeriod.1,xi_DPeriod.1,xi_Slowing.1,xi_MA.1,xi_PF.1,0,StochShift+1);
            double prvStoch.2 = iStochastic(NULL,xi_TF.2,xi_KPeriod.2,xi_DPeriod.2,xi_Slowing.2,xi_MA.2,xi_PF.2,0,StochShift+1);
            double curStoch.1 = iStochastic(NULL,xi_TF.1,xi_KPeriod.1,xi_DPeriod.1,xi_Slowing.1,xi_MA.1,xi_PF.1,0,StochShift);
            double curStoch.2 = iStochastic(NULL,xi_TF.2,xi_KPeriod.2,xi_DPeriod.2,xi_Slowing.2,xi_MA.2,xi_PF.2,0,StochShift);
            
         //   if(HistoWoodieCCI[1] > 0 && (currStoch > prevStoch))
         if(HistoWoodieCCI[1] > 0 && (curStoch.1 > prvStoch.1 || curStoch.2 > prvStoch.2))
            {
               Alert("Retrace Found BUY @"+Symbol() + " : "+Period());
               if(UseEmail) SendMail("Retrace Found","BUY Retrace was found with Symbol "+Symbol()+" at Timeframe "+Period());
            }
        //    if(HistoWoodieCCI[1] < 0 && (currStoch < prevStoch))
         if(HistoWoodieCCI[1] < 0 && (curStoch.1 < prvStoch.1 || curStoch.2 < prvStoch.2))
            {
               Alert("Retrace Found SELL @"+Symbol() + " : "+Period());
               if(UseEmail) SendMail("Retrace Found","SELL Retrace was found with Symbol "+Symbol()+" at Timeframe "+Period());
            }
         } else
         {
            Alert("Retrace Found @"+Symbol() + " : "+Period());
            
         }
      }
      if(UseEmail) SendMail("Retrace Found","A Retrace was found with Symbol "+Symbol()+" at Timeframe "+Period());
   }
   return(0);
  }


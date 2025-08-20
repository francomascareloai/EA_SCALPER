
//+------------------------------------------------------------------+
//|  TZ-Breaktout-Z2.mq4                                             |
//|  Shimodax                                                        |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright Shimodax"
#property link      "http://www.strategybuilderfx.com/forums/showthread.php?t=15439"


/* Introduction:

   Draw ranges for "Simple Combined Breakout System for EUR/USD and GBP/USD" thread
   (see http://www.strategybuilderfx.com/forums/showthread.php?t=15439)

   TimeZoneOfData: TimeZone for which MT4 shows your local time, 
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight 
                  savings time).  Use zero for no adjustment.
                  
                  The MetaQuotes demo server uses GMT +2.   
   Enjoy  :-)
   
   Markus

*/


#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Blue
#property indicator_color2 Purple
#property indicator_color3 Blue
#property indicator_color4 Purple
#property indicator_color5 Blue
#property indicator_color6 Purple
#property indicator_color7 Yellow


extern bool DoEntryAlerts= false;
extern int TimeZoneOfData= 3;  // time zone of metatrader charts
extern int PipsForEntry= 5;
extern int PipsTarget = 80;
extern int PipsStop= 50;
extern int ShowTarget= 1;
extern int ShowStop= 1;

int DestTimeZone= 0;   // dest time zone for time computation (leave as zero (GMT))




double Zone2Upper[];
double Zone2Lower[];
double Zone2UpperTarget[];
double Zone2LowerTarget[];
double Zone2UpperStop[];
double Zone2LowerStop[];
double EntrySignalsBuffer[];
bool Zone2UpperBreakout=False;
bool Zone2LowerBreakout=False;
       



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Zone2Upper);
   SetIndexEmptyValue(0, 0.0);
   SetIndexLabel(0, "Z2 Upper");

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Zone2Lower);
   SetIndexEmptyValue(1, 0.0);
   SetIndexLabel(1, "Z2 Lower");

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Zone2UpperTarget);
   SetIndexEmptyValue(2, 0.0);
   SetIndexLabel(2, "Z2 Upper Target");

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Zone2LowerTarget);
   SetIndexEmptyValue(3, 0.0);
   SetIndexLabel(3, "Z2 Lower Target");

   SetIndexStyle(2,DRAW_LINE, STYLE_DASH, 1);
   SetIndexBuffer(2,Zone2UpperTarget);
   SetIndexEmptyValue(2, 0.0);
	SetIndexLabel(2, "Z2 Upper Target");

   SetIndexStyle(3,DRAW_LINE, STYLE_DASH, 1);
   SetIndexBuffer(3,Zone2LowerTarget);
   SetIndexEmptyValue(3, 0.0);
   SetIndexLabel(3, "Z2 Lower Target");

   SetIndexStyle(4,DRAW_LINE, STYLE_DASHDOTDOT, 1);
   SetIndexBuffer(4,Zone2UpperStop);
   SetIndexEmptyValue(4, 0.0);
	SetIndexLabel(4, "Z2 Upper Stop");

   SetIndexStyle(5,DRAW_LINE, STYLE_DASHDOTDOT, 1);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Zone2LowerStop);
   SetIndexEmptyValue(5, 0.0);
   SetIndexLabel(5, "Z2 Lower Stop");

   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6, 162);
   SetIndexBuffer(6, EntrySignalsBuffer);
   SetIndexEmptyValue(6, 0.0);
   SetIndexLabel(6, "Z2 Breakout Signal");

   return(0);
}

int deinit()
{

   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars= IndicatorCounted(),
         lastbar, result;

   if (Bars<=100) 
      return(0);
      
   if (counted_bars>0)
      counted_bars--;
      
   lastbar= Bars - counted_bars;
   
   
   //
   // compute ranges
   //
   BreakoutRanges(0, lastbar, TimeZoneOfData, DestTimeZone);
   
   
   //
   // check alerts   
   //
   static datetime lastalerttime;
   static double lastalertprice;

   if (DoEntryAlerts && lastalerttime!=Time[0] && EntrySignalsBuffer[0]!=0 && EntrySignalsBuffer[0]!=lastalertprice) {
      Alert("ZoneBreakout signals entry!");
      lastalerttime= Time[0];
      lastalertprice= EntrySignalsBuffer[0];
   } 
   else {
      lastalerttime= 0;
      lastalertprice= 0.0;
   }


   return(0);
}

 
//+------------------------------------------------------------------+
//| Compute Breakout ranges for daily time periods                   |
//+------------------------------------------------------------------+
int BreakoutRanges(int offset, int lastbar, int tzlocal, int tzdest)
{     
   int i, j, k,
       tzdiff= tzlocal - tzdest,
       tzdiffsec= tzdiff*3600, 
       tidxstart[2]= { 0, 0}, 
       tidxend[2]= { 0, 0 };
   double thigh[2]= { 0.0, 0.0 }, 
           tlow[2]= { 99999.9, 99999.9 };
   string tfrom[3]= { "04:00", "08:00" ,  /*rest of day: */ "12:00"},
          tto[3]=   { "08:00", "12:00",   /*rest of day: */ "24:00" },
          tday;
   bool inperiod= -1;
   datetime timet;
   

   //
   // search back for the beginning of the day
   //
   tday= TimeToStr(Time[lastbar]-tzdiffsec, TIME_DATE);   
   for (  ; lastbar<Bars; lastbar++) {
      if (TimeToStr(Time[lastbar] - tzdiffsec, TIME_DATE)!=tday) {
         lastbar--;
         break;      
      }
   }   



   //
   // find the high/low for the two periods and carry them forward through the day
   //
   tday= "XXX";
   for (i= lastbar; i>=offset; i--) {
   
      timet= Time[i] - tzdiffsec;   // time of this bar
      
      string timestr= TimeToStr(timet, TIME_MINUTES),    // current time HH:MM
             thisday= TimeToStr(timet, TIME_DATE);       // current date
          
      EntrySignalsBuffer[i]= 0;   
          
      //
      // for all three periods (first period, second period, rest of day)
      //
      for (j= 0; j<3; j++) {
      
         if (tfrom[j]<=timestr && timestr<tto[j]) {   // Bar[i] in this period
      
            if (inperiod!=j) { // entered new period, so last one is completed
                                 
               if (j>0) {      // now draw high/low back over the recently completed period
               
                  for (k= tidxstart[j-1]; k>=tidxend[j-1]; k--) {
                     if (j-1==1) {
                        Zone2Upper[k]= thigh[j-1];
                        Zone2Lower[k]= tlow[j-1];
                     }
                  }
               }
               
               inperiod= j;   // remember current period
            }
            
            if (inperiod==2)   // inperiod==2 (end of day) is just to check completion of zone 2
               break;


            // for the current period find idxstart, idxend and compute high/low
            if (tidxstart[j]==0) {
               tidxstart[j]= i;
               tday= thisday;
            }
         
            tidxend[j]= i;
      
            thigh[j]= MathMax(thigh[j], High[i]);
            tlow[j]= MathMin(tlow[j], Low[i]);
         }
      }
      
      
      // 
      // carry forward the periods for which we have definite high/lows
      //
      if (inperiod>=1 && tday==thisday) { // first time period completed
         if (inperiod>=2) {   // second period completed
            Zone2Upper[i]= thigh[1] + PipsForEntry*Point;
            Zone2Lower[i]= tlow[1] - PipsForEntry*Point;
            if (ShowTarget==1)
              {
               Zone2UpperTarget[i]= thigh[1] + PipsForEntry*Point+PipsTarget*Point;
               Zone2LowerTarget[i]= tlow[1] - PipsForEntry*Point-PipsTarget*Point;
              }
            if (ShowStop==1)
              {
               if(Zone2Upper[i]-Zone2Lower[i]>PipsStop*Point)
                 {
                  Zone2UpperStop[i]= Zone2Upper[i]-PipsStop*Point;  
                  Zone2LowerStop[i]= Zone2Lower[i]+PipsStop*Point;  
                 }
               else
                 {
                  Zone2UpperStop[i]= 0;  
                  Zone2LowerStop[i]= 0;  
                 }
             }
         }
         
         CheckSignal(i, Zone2Upper[i], OP_BUY, EntrySignalsBuffer);
         CheckSignal(i, Zone2Lower[i], OP_SELL, EntrySignalsBuffer);
      }
      else {   // none yet to carry forward (zero to clear old values, e.g. from switching timeframe)
         Zone2Upper[i]= 0;
         Zone2Lower[i]= 0;
         Zone2UpperTarget[i]= 0;
         Zone2LowerTarget[i]= 0;
         Zone2UpperStop[i]= 0;
         Zone2LowerStop[i]= 0;
      }
     

      //
      // at the beginning of a new day reset everything
      //
      if (tday!="XXX" && tday!=thisday || TimeToStr(timet, TIME_MINUTES)>=tto[2]) {
         // Print("#", i, "new day ", thisday, "/", tday);
      
         tday= "XXX";
         
         Zone2UpperBreakout = False;
         Zone2LowerBreakout = False;        

         inperiod= -1;
         
         for (j= 0; j<2; j++) {
            tidxstart[j]= 0;
            tidxend[j]= 0;
         
            thigh[j]= 0;
            tlow[j]= 99999;
         }
      }
   }

   return (0);       
}




//+------------------------------------------------------------------+
//| Check price break                                                |
//+------------------------------------------------------------------+
bool CheckSignal(int shift, double price, int type, double &signalbuffer[]) 
{
   bool signal= false;

   if (Zone2UpperBreakout==False && type==OP_BUY && ((Open[shift]<price && High[shift]>price) || (Close[shift+1]<price && Open[shift]>price)) ) {
      signalbuffer[shift]= price;
      signal= true;
      Zone2UpperBreakout=True;
  }

   if (Zone2LowerBreakout==False && type==OP_SELL && (Open[shift]>price && Low[shift]<price) || (Close[shift+1]>price && Open[shift]<price)) {
      signalbuffer[shift]= price;
      signal= true;
      Zone2LowerBreakout=True;
  }
  
  return (signal);
}


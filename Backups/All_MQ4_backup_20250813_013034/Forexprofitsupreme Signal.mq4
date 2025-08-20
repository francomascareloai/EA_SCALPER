#property copyright "Copyright 2013 © Forexprofitsupreme"
#property link      "www.Forexprofitsupreme.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Red

extern int    FastMa          = 5;
extern int    FastMaShift     = 0;
extern int    FastMAMethod    = MODE_LWMA;
extern int    FastMAPrice     = PRICE_CLOSE;
extern int    SlowMa          = 13;
extern int    SlowMaShift     = 0;
extern int    SlowMAMethod    = MODE_LWMA;
extern int    SlowMAPrice     = PRICE_CLOSE;


extern string note             = "turn on Alert = true; turn off = false";
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = true;
extern bool   alertsEmail      = false;
extern string soundfile        = "alert2.wav";

extern string note7            = "Arrow Type";
extern string note8            = "0=default,1=Thick,2=Thin,3=Hollow";
extern string note9            = "4=Round,5=Fractal,6=Diagonal Thin";
extern string note10           = "7=Diagonal Thick,8=Diagonal Hollow";
extern string note11           = "9=Thumb,10=Finger";
extern int    ArrowType        = 2;
extern int    arrowthickness   = 2;


//
//
//
//
//

double CrossUp[];
double CrossDn[];
double trend[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(3);   
   
   if (ArrowType == 0) {
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0,DRAW_ARROW,0,arrowthickness); SetIndexArrow(0,119);
   SetIndexBuffer(1, CrossDn );  SetIndexStyle(1,DRAW_ARROW,0,arrowthickness); SetIndexArrow(1,119);
   }
   if (ArrowType == 1) {
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 233);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 234);
   }
   else if (ArrowType == 2) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 225);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 226);
   }
   else if (ArrowType == 3) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 241);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 242);
   }
   else if (ArrowType == 4) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 221);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 222);
   }
   else if (ArrowType == 5) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 217);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 218);
   }
   else if (ArrowType == 6) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 228);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 230);
   }
   else if (ArrowType == 7) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 236);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 238);
   }
   else if (ArrowType == 8) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 246);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 248);
   }
   else if (ArrowType == 9) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 67);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 68);
   }
   else if (ArrowType == 10) { 
   SetIndexBuffer(0, CrossUp);  SetIndexStyle(0, DRAW_ARROW,0,arrowthickness); SetIndexArrow(0, 71);
   SetIndexBuffer(1, CrossDn);  SetIndexStyle(1, DRAW_ARROW,0,arrowthickness); SetIndexArrow(1, 72);
   }

   SetIndexBuffer(2, trend);
   return(0);
}
int deinit() {  return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int start() {
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         
   //
   //
   //
   //
   //
            
   for(i=limit; i>=0; i--)
   {
      double fastMA = iMA(NULL,0,FastMa,FastMaShift,FastMAMethod,FastMAPrice,i);
      double slowMA = iMA(NULL,0,SlowMa,SlowMaShift,SlowMAMethod,SlowMAPrice,i);
      
      trend[i] = trend[i+1];
         if (fastMA>slowMA) trend[i] = 1;
         if (fastMA<slowMA) trend[i] =-1;

         //
         //
         //
         //
         //
      
         CrossUp[i] = EMPTY_VALUE;
         CrossDn[i] = EMPTY_VALUE;
         if (trend[i] !=trend[i+1])
         if (trend[i] == 1)
               CrossUp[i] = Low[i] - iATR(NULL,0,20,i)/2.0;
         else  CrossDn[i] = High[i]+ iATR(NULL,0,20,i)/2.0;
         }
         
         if (alertsOn)
      {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;

         //
         //
         //
         //
         //
         
         if (trend[whichBar] != trend[whichBar+1])
         if (trend[whichBar] == 1)
               doAlert("uptrend");
         else  doAlert("downtrend");       
   }
   
   return(0);
}
//+------------------------------------------------------------------+


void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ma cross ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," ma cross "),message);
             if (alertsSound)   PlaySound(soundfile);
      }
}


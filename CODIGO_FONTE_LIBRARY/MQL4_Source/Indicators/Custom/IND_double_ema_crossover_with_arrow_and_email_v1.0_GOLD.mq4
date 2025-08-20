//+------------------------------------------------------------------+
//|                                  2MA Crossover.mq4 modified from |
//|                                         EMA-Crossover_Signal.mq4 |
//|         Copyright © 2005-07, Jason Robinson (jnrtrading)         |
//|                   http://www.jnrtading.co.uk                     |
//+------------------------------------------------------------------+

/*
  +------------------------------------------------------------------+
  | Allows you to enter two ema periods and it will then show you at |
  | Which point they crossed over. It is more usful on the shorter   |
  | periods that get obscured by the bars / candlesticks and when    |
  | the zoom level is out. Also allows you then to remove the emas   |
  | from the chart. (emas are initially set at 5 and 6)              |
  +------------------------------------------------------------------+
*/   
#property copyright "Copyright © 2005-07, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 1

extern string note1 = "First Moving Average";
extern int MA1 =   8;
extern string note2 = "0=sma, 1=ema, 2=smma, 3=lwma";
extern int MA1Mode = 1; //0=sma, 1=ema, 2=smma, 3=lwma
extern string note3 = "--------------------------------------------";
extern string note4 = "Second Moving Average";
extern int MA2 =   13;
extern string note5 = "0=sma, 1=ema, 2=smma, 3=lwma";
extern int MA2Mode = 1; //0=sma, 1=ema, 2=smma, 3=lwma
extern string note6 = "--------------------------------------------";
extern string note7 = "Arrow Type";
extern string note8 = "0=Thick, 1=Thin, 2=Hollow, 3=Round";
extern string note9 = "4=Fractal, 5=Diagonal Thin";
extern string note10 = "6=Diagonal Thick, 7=Diagonal Hollow";
extern string note11 = "8=Thumb, 9=Finger";
extern int ArrowType=2;
extern string note12 = "--------------------------------------------";
extern string note13 = "turn on Alert = true; turn off = false";
extern bool AlertOn = true;
extern string note14 = "--------------------------------------------";
extern string note15 = "send Email Alert = true; turn off = false";
extern bool SendAnEmail=true;

double CrossUp[];
double CrossDown[];
string AlertPrefix, MA1short_name, MA2short_name;
string GetTimeFrameStr() {
   switch(Period())
   {
      case 1 : string TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr=Period();
   } 
   return (TimeFrameStr);
   }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   if (ArrowType == 0) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 233);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 234);
   }
   else if (ArrowType == 1) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 225);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 226);
   }
   else if (ArrowType == 2) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 241);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 242);
   }
   else if (ArrowType == 3) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 221);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 222);
   }
   else if (ArrowType == 4) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 217);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 218);
   }
   else if (ArrowType == 5) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 228);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 230);
   }
   else if (ArrowType == 6) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 236);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 238);
   }
   else if (ArrowType == 7) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 246);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 248);
   }
   else if (ArrowType == 8) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 67);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 68);
   }
   else if (ArrowType == 9) {
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0, 71);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1, 72);
   }

   SetIndexBuffer(0, CrossUp);
   SetIndexBuffer(1, CrossDown);

//---- indicator short name
   switch(MA1Mode)
     {
      case 1 : MA1short_name="EMA";  break;
      case 2 : MA1short_name="SMMA"; break;
      case 3 : MA1short_name="LWMA"; break;
      default :
         MA1Mode=0;
         MA1short_name="SMA";
     }
   switch(MA2Mode)
     {
      case 1 : MA2short_name="EMA";  break;
      case 2 : MA2short_name="SMMA"; break;
      case 3 : MA2short_name="LWMA"; break;
      default :
         MA2Mode=0;
         MA2short_name="SMA";
     }

   AlertPrefix=Symbol()+" ("+GetTimeFrameStr()+"):  ";
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
bool NewBar()
{
   static datetime lastbar;
   datetime curbar = Time[0];
   if(lastbar!=curbar)
   {
      lastbar=curbar;
      return (true);
   }
   else
   {
      return(false);
   }
}   
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int limit, i, counter;
   double MA1now, MA2now, MA1previous, MA2previous, MA1after, MA2after;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      MA1now = iMA(NULL, 0, MA1, 0, MA1Mode, PRICE_CLOSE, i);
      MA1previous = iMA(NULL, 0, MA1, 0, MA1Mode, PRICE_CLOSE, i+1);
      MA1after = iMA(NULL, 0, MA1, 0, MA1Mode, PRICE_CLOSE, i-1);

      MA2now = iMA(NULL, 0, MA2, 0, MA2Mode, PRICE_CLOSE, i);
      MA2previous = iMA(NULL, 0, MA2, 0, MA2Mode, PRICE_CLOSE, i+1);
      MA2after = iMA(NULL, 0, MA2, 0, MA2Mode, PRICE_CLOSE, i-1);
      
      if ((MA1now > MA2now) && (MA1previous < MA2previous) && (MA1after > MA2after)) {
                   CrossUp[i] = Low[i] - Range*1.5;
                   if (AlertOn && NewBar()) {
                      Alert(AlertPrefix+MA1short_name+" ("+MA1+") "+"crosses UP " + MA2short_name+" ("+MA2+")");
                   }   
              	    if (SendAnEmail && NewBar()) {
                      SendMail("Price closed above MA"," Price closed above moving average");
              	    }
      }
      else if ((MA1now < MA2now) && (MA1previous > MA2previous) && (MA1after < MA2after)) {
                   CrossDown[i] = High[i] + Range*1.5;
                   if (AlertOn && NewBar()) {
                      Alert(AlertPrefix+MA1short_name+" ("+MA1+") "+"crosses DOWN " + MA2short_name+" ("+MA2+")");
                   }   
              	    if (SendAnEmail && NewBar()) {
                      SendMail("Price closed below MA"," Price closed below moving average");
              	    } 
      }
   }
   return(0);
}


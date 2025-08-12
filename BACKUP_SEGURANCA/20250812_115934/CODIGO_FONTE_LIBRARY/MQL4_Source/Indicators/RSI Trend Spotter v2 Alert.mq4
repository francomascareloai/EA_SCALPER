//+------------------------------------------------------------------+
//|                                         EMA-Crossover_Signal.mq4 |
//|         Copyright © 2005, Jason Robinson (jnrtrading)            |
//|                   http://www.jnrtading.co.uk                     |
//+------------------------------------------------------------------+ RSI_Trend_Spotter2

/*
  +------------------------------------------------------------------+
  | Allows you to enter two ema periods and it will then show you at |
  | Which point they crossed over. It is more usful on the shorter   |
  | periods that get obscured by the bars / candlesticks and when    |
  | the zoom level is out. Also allows you then to remove the emas   |
  | from the chart. (emas are initially set at 5 and 6)              |
  +------------------------------------------------------------------+
*/   
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Aqua

#property indicator_width1 1
#property indicator_width2 1

double CrossUp[];
double CrossDown[];
extern int FasterEMA = 5;
extern int SlowerEMA = 12;
extern int RSIPeriod = 21;
extern bool UseSound=true;
extern bool AlertSound=true;
extern string SoundFileBuy ="alert2.wav";
extern string SoundFileSell="email.wav";
extern bool SendMailPossible = false;
extern int SIGNAL_BAR = 1;
bool SoundBuy  = False;
bool SoundSell = False;

bool EMACrossedUp = false;
bool RSICrossedUp = false;
bool EMACrossedDown = false;
bool RSICrossedDown = false;
int SignalLabeled = 0; // 0: initial state; 1: up; 2: down.
int upalert=false,downalert=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 241);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 242);
   SetIndexBuffer(1, CrossDown);
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
int start() {
   int limit, i, counter;
   double fasterEMAnow, slowerEMAnow, fasterEMAprevious, slowerEMAprevious, fasterEMAafter, slowerEMAafter;
   double RSInow, RSIprevious, RSIafter;
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
       
      fasterEMAnow = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_CLOSE, i);
      fasterEMAprevious = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_CLOSE, i+1);
      fasterEMAafter = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_CLOSE, i-1);

      slowerEMAnow = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_CLOSE, i);
      slowerEMAprevious = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_CLOSE, i+1);
      slowerEMAafter = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_CLOSE, i-1);
      
      RSInow=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i);
      RSIprevious=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i+1);
      RSIafter=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i-1);
      
      if ((RSInow > 50) && (RSIprevious < 50) && (RSIafter > 50)) {
         RSICrossedUp = true;
         RSICrossedDown = false;
      }
      
      if ((RSInow < 50) && (RSIprevious > 50) && (RSIafter < 50)) {
         RSICrossedUp = false;
         RSICrossedDown = true;
      }
      
      if ((fasterEMAnow > slowerEMAnow) && (fasterEMAprevious < slowerEMAprevious) && (fasterEMAafter > slowerEMAafter)) {
         EMACrossedUp = true;
         EMACrossedDown = false;
      }

      if ((fasterEMAnow < slowerEMAnow) && (fasterEMAprevious > slowerEMAprevious) && (fasterEMAafter < slowerEMAafter)) {
         EMACrossedUp = false;
         EMACrossedDown = true;
      }

      if ((EMACrossedUp == true) && (RSICrossedUp == true) && (SignalLabeled != 1)) {
         CrossUp[i] = Low[i] - Range*1.3;
        
         SignalLabeled = 1;
      }

      else if ((EMACrossedDown == true) && (RSICrossedDown == true) && (SignalLabeled != 2)) {
         CrossDown[i] = High[i] + Range*1.3;
       
         SignalLabeled = 2;
      }
   }
//+------------------------------------------------------------------+ 
 string  message  =  StringConcatenate("RSI_Trend_Spotter2"," -"," ","сигнал на покупку!!!"," -"," ",Symbol()," -"," ",Period()," ","-"," " ,TimeToStr(TimeLocal(),TIME_SECONDS)); 
 string  message2 =  StringConcatenate("RSI_Trend_Spotter2"," -"," ","сигнал на продажу!!!"," -"," ",Symbol()," -"," ",Period()," ","-"," " ,TimeToStr(TimeLocal(),TIME_SECONDS)); 
        if (CrossUp[SIGNAL_BAR] != EMPTY_VALUE && CrossUp[SIGNAL_BAR] != 0 && SoundBuy)
         {
         SoundBuy = False;
            if (UseSound) PlaySound (SoundFileBuy);
               if(AlertSound){         
               Alert(message);                             
               if (SendMailPossible) SendMail(Symbol(),message); 
            }              
         } 
      if (!SoundBuy && (CrossUp[SIGNAL_BAR] == EMPTY_VALUE || CrossUp[SIGNAL_BAR] == 0)) SoundBuy = True;  
            
  
     if (CrossDown[SIGNAL_BAR] != EMPTY_VALUE && CrossDown[SIGNAL_BAR] != 0 && SoundSell)
         {
         SoundSell = False;
            if (UseSound) PlaySound (SoundFileSell); 
             if(AlertSound){                    
             Alert(message2);             
             if (SendMailPossible) SendMail(Symbol(),message2); 
             }            
         } 
      if (!SoundSell && (CrossDown[SIGNAL_BAR] == EMPTY_VALUE || CrossDown[SIGNAL_BAR] == 0)) SoundSell = True; 
      
       //+------------------------------------------------------------------+ 
   return(0);
}


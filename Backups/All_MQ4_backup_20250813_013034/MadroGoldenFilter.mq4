//+------------------------------------------------------------------+
//|                                              GoldenFilter_v1.mq4 |
//|                                         Copyright © 2007, madro  |
//|                                               madrofx@yahoo.com  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2007, madro"
#property  link      "madrofx@yahoo.com"
//----
#property indicator_separate_window    
#property indicator_buffers  8
#property indicator_minimum  0
#property indicator_maximum  1
#property indicator_color1 RoyalBlue
#property indicator_color2 OrangeRed
#property indicator_color3 Goldenrod
#property indicator_color4 DarkGray
#property indicator_color5 Goldenrod
#property indicator_color6 DarkGray
#property indicator_color7 Goldenrod
#property indicator_color8 Gray
//----
extern int FasterMA = 5;
extern int SlowerMA = 15;
extern int MA1_Type = 1;
extern int MA2_Type = 1;
extern int MACD_Fast = 8;
extern int MACD_Slow = 17;
extern int MACD_Signal = 9; 
extern int RSI = 21;
extern int Momentum = 14;
extern int DeMarker = 14;
extern int ADX = 14;
extern int ForceIndex = 14;
extern bool SoundAlert = true;
//---- indicator buffers
double Up[];
double Down[];
double CrossUp[];
double CrossDown[];
double TrendUp[];
double TrendDown[];
double MAUp[];
double MADown[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
//---- indicator line
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0,120);
   SetIndexBuffer(0, Up);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1,120);
   SetIndexBuffer(1, Down);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 251);
   SetIndexBuffer(2, CrossUp);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 251);
   SetIndexBuffer(3, CrossDown);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 110);
   SetIndexBuffer(4, TrendUp);
   SetIndexStyle(5, DRAW_ARROW);
   SetIndexArrow(5, 110);
   SetIndexBuffer(5, TrendDown);
   SetIndexStyle(6, DRAW_ARROW,0,1);
   SetIndexArrow(6, 241);
   SetIndexBuffer(6, MAUp);
   SetIndexStyle(7, DRAW_ARROW,0,1);
   SetIndexArrow(7, 242);
   SetIndexBuffer(7, MADown);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("madro-9");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|  GoldenFilter_v1                                                 |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   int i;
   int limit;
//---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars;
//----   
   for(i = limit - 1; i >= 0; i--)
     {	
	      double  fasterMAnow = iMA(NULL, 0, FasterMA, 0, MA1_Type, 
	                                PRICE_CLOSE, i);
       double  fasterMAprevious = iMA(NULL, 0, FasterMA, 0, MA1_Type, 
                                      PRICE_CLOSE, i + 1);
       double  fasterMAafter = iMA(NULL, 0, FasterMA, 0, MA1_Type, 
                                   PRICE_CLOSE, i - 1);
       double  slowerMAnow = iMA(NULL, 0, SlowerMA, 0, MA2_Type, 
                                 PRICE_CLOSE, i);
       double  slowerMAprevious = iMA(NULL, 0, SlowerMA, 0, 
                                      MA2_Type, PRICE_CLOSE, i + 1);
       double  slowerMAafter = iMA(NULL, 0, SlowerMA, 0, MA2_Type, 
                                   PRICE_CLOSE, i - 1);
       //---- 
       double  MACD = iMACD(Symbol(), Period(), MACD_Fast, MACD_Slow, 
                            MACD_Signal, PRICE_CLOSE, MODE_MAIN, i);
       double  MACD_Sig = iMACD(Symbol(), Period(), MACD_Fast, MACD_Slow,
                                MACD_Signal, PRICE_CLOSE, MODE_SIGNAL, i);
       //---- 
       double  ADX1 = iADX(NULL, 0, ADX, PRICE_CLOSE, MODE_PLUSDI, i);
       double  ADX2 = iADX(NULL, 0, ADX, PRICE_CLOSE, MODE_MINUSDI, i);
       //----
       double  RSIV = iRSI(NULL, 0, RSI, 0, i);
       double  DEM = iDeMarker(NULL, 0, DeMarker, i); 
       double  MOM = iMomentum( NULL,0, Momentum, PRICE_CLOSE, i); 
       double  FI = iForce(NULL, 0, ForceIndex, 1, PRICE_CLOSE, i);
	 	    if(MOM > 100) 
           Up[i] = 0.05;
       if(MOM <= 100) 
           Down[i] = 0.05;
       if(DEM > 0.5 && FI >0)
           TrendUp[i] = 0.22;
       if(DEM < 0.5 < 50 && FI < 0)
           TrendDown[i] = 0.22;         
       if(RSIV > 50 && MACD > MACD_Sig && ADX1 > ADX2)
           CrossUp[i] = 0.47;
       if(RSIV < 50 && MACD < MACD_Sig && ADX1 < ADX2)
           CrossDown[i] = 0.47; 
       if((fasterMAnow > slowerMAnow) && 
          (fasterMAprevious < slowerMAprevious) && 
          (fasterMAafter > slowerMAafter))
         {
           MAUp[i] = 0.8;
           if(SoundAlert == true)
             {
               Alert("GoldenMadro Up " + Symbol() + " on the " + 
                     Period() + " minute chart.");
             }
         }
       if((fasterMAnow < (slowerMAnow)) && 
          (fasterMAprevious > (slowerMAprevious)) && 
          (fasterMAafter < slowerMAafter))  
         {
           MADown[i] = 0.8;
           if(SoundAlert == true)
               Alert("GoldenMadro Up " + Symbol() + " on the " + 
                     Period() + " minute chart.");
         } 
       
     }  
   return(0);	
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|                                                  i_TDI_MA_01.mq4 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                    Traders Dynamic Index.mq4     |
//|                                    Copyright © 2006, Dean Malone |
//|                                    www.compassfx.com             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//|                     Traders Dynamic Index                        |
//|                                                                  |
//|  This hybrid indicator is developed to assist traders in their   |
//|  ability to decipher and monitor market conditions related to    |
//|  trend direction, market strength, and market volatility.        |
//|                                                                  | 
//|  Even though comprehensive, the T.D.I. is easy to read and use.  |
//|                                                                  |
//|  Green line = RSI Price line                                     |
//|  Red line = Trade Signal line                                    |
//|  Blue lines = Volatility Band                                    | 
//|  Yellow line = Market Base Line                                  |  
//|                                                                  |
//|  Trend Direction - Immediate and Overall                         |
//|   Immediate = Green over Red...price action is moving up.        |
//|               Red over Green...price action is moving down.      |
//|                                                                  |   
//|   Overall = Yellow line trends up and down generally between the |
//|             lines 32 & 68. Watch for Yellow line to bounces off  |
//|             these lines for market reversal. Trade long when     |
//|             price is above the Yellow line, and trade short when |
//|             price is below.                                      |        
//|                                                                  |
//|  Market Strength & Volatility - Immediate and Overall            |
//|   Immediate = Green Line - Strong = Steep slope up or down.      | 
//|                            Weak = Moderate to Flat slope.        |
//|                                                                  |               
//|   Overall = Blue Lines - When expanding, market is strong and    |
//|             trending. When constricting, market is weak and      |
//|             in a range. When the Blue lines are extremely tight  |                                                       
//|             in a narrow range, expect an economic announcement   | 
//|             or other market condition to spike the market.       |
//|                                                                  |               
//|                                                                  |
//|  Entry conditions                                                |
//|   Scalping  - Long = Green over Red, Short = Red over Green      |
//|   Active - Long = Green over Red & Yellow lines                  |
//|            Short = Red over Green & Yellow lines                 |    
//|   Moderate - Long = Green over Red, Yellow, & 50 lines           |
//|              Short= Red over Green, Green below Yellow & 50 line |
//|                                                                  |
//|  Exit conditions*                                                |   
//|   Long = Green crosses below Red                                 |
//|   Short = Green crosses above Red                                |
//|   * If Green crosses either Blue lines, consider exiting when    |
//|     when the Green line crosses back over the Blue line.         |
//|                                                                  |
//|                                                                  |
//|  IMPORTANT: The default settings are well tested and proven.     |
//|             But, you can change the settings to fit your         |
//|             trading style.                                       |
//|                                                                  |
//|                                                                  |
//|  Price & Line Type settings:                           |                
//|   RSI Price settings                                             |               
//|   0 = Close price     [DEFAULT]                                  |               
//|   1 = Open price.                                                |               
//|   2 = High price.                                                |               
//|   3 = Low price.                                                 |               
//|   4 = Median price, (high+low)/2.                                |               
//|   5 = Typical price, (high+low+close)/3.                         |               
//|   6 = Weighted close price, (high+low+close+close)/4.            |               
//|                                                                  |               
//|   RSI Price Line & Signal Line Type settings                                   |               
//|   0 = Simple moving average       [DEFAULT]                      |               
//|   1 = Exponential moving average                                 |               
//|   2 = Smoothed moving average                                    |               
//|   3 = Linear weighted moving average                             |               
//|                                                                  |
//|   Good trading,                                                  |   
//|                                                                  |
//|   Dean                                                           |                              
//+------------------------------------------------------------------+



#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 Lime
#property indicator_color3 Tomato

#property indicator_separate_window
      
extern bool   AlertOn = false;// added by raymie69
extern int SimpleTP = 5;
extern int RSI_Period = 13;         //8-25
extern int RSI_Price = 0;           //0-6
extern int Volatility_Band = 34;    //20-40
extern int RSI_Price_Line = 2;      
extern int RSI_Price_Type = 0;      //0-3
extern int Trade_Signal_Line = 7;   
extern int Trade_Signal_Type = 0;   //0-3
extern int SlowPeriod = 16;

double RSIBuf[],MaBuf[],MbBuf[],Spread,SimpleMA;
#define SIGNAL_BAR 0 // added by raymie69
int init()
  {
   IndicatorShortName("TDI_MA");
   SetIndexBuffer(0,RSIBuf);
   SetIndexBuffer(1,MaBuf);
   SetIndexBuffer(2,MbBuf);
   
   SetIndexStyle(0,DRAW_NONE); 
   SetIndexStyle(1,DRAW_LINE,0,1);   //,0,2
   SetIndexStyle(2,DRAW_LINE,0,2);   //,0,2
  
   SetIndexLabel(0,NULL); 
   SetIndexLabel(1,"Trade Signal fast");
   SetIndexLabel(2,"Trade Signal slow");
  
   
   SetLevelValue(0,50);
   SetLevelValue(1,68);
   SetLevelValue(2,32);
   SetLevelStyle(STYLE_DOT,1,DimGray);
   return(0);
  }
void deinit()// added by raymie69 
{
  ObjectsDeleteAll (0,OBJ_LABEL);// added by raymie69
  ObjectsDeleteAll (0,OBJ_RECTANGLE);// added by raymie69
  ObjectsDeleteAll (0,OBJ_TEXT);// added by raymie69
  ObjectsDeleteAll (1,OBJ_LABEL);// added by raymie69
  Comment("");// added by raymie69
}   
int start()
  {
   double MA,RSI[];
   ArrayResize(RSI,Volatility_Band);
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   for(int i=limit; i>=0; i--)
   {
      RSIBuf[i] = (iRSI(NULL,0,RSI_Period,RSI_Price,i)); 
      MA = 0;
      for(int x=i; x<i+Volatility_Band; x++) {
         RSI[x-i] = RSIBuf[x];
         MA += RSIBuf[x]/Volatility_Band;
   }}
  
   for (i=limit-1;i>=0;i--)  
       MaBuf[i] = (iMAOnArray(RSIBuf,0,Trade_Signal_Line,0,Trade_Signal_Type,i));   
     
   
   for (i=limit-1;i>=0;i--)  
       MbBuf[i] = iMAOnArray(MaBuf,0,SlowPeriod,0,0,i);   
     
//----
      Spread = NormalizeDouble((Ask-Bid)/Point,0);// added by raymie69
      ObjectDelete("Name");// added by raymie69
      ObjectCreate ("Name",OBJ_LABEL, 0,0,0);// added by raymie69
      ObjectSetText("Name", "Спред : "+ DoubleToStr(Spread,Point) + " pips.", 14,"Georgia", DodgerBlue);// added by raymie69
      ObjectSet("Name", OBJPROP_CORNER, 0);// added by raymie69
      ObjectSet("Name", OBJPROP_XDISTANCE, 5);// added by raymie69
      ObjectSet("Name", OBJPROP_YDISTANCE, 20);// added by raymie69
  static int PrevSignal = 0, PrevTime = 0;// added by raymie69
  if(SIGNAL_BAR > 0 && Time[0] <= PrevTime ) // added by raymie69
  return(0);// added by raymie69
  PrevTime = Time[0];// added by raymie69
//if(Open[SIGNAL_BAR] > SimpleMA && Close[SIGNAL_BAR] > SimpleMA && AlertOn == true)// added by raymie69
//if(Open[SIGNAL_BAR] < SimpleMA && Close[SIGNAL_BAR] < SimpleMA && AlertOn == true)// added by raymie69
//
   double stoch1 = iStochastic(NULL,0,8,3,3,MODE_EMA,0,MODE_MAIN,0);// added by raymie69             
   double stoch2 = iStochastic(NULL,0,8,3,3,MODE_EMA,0,MODE_MAIN,1);// added by raymie69             
   if(PrevSignal <= 0)// added by raymie69
      {
         //if(MaBuf[SIGNAL_BAR] > MbBuf[SIGNAL_BAR] && Close[SIGNAL_BAR] > SimpleMA && AlertOn == true)// added by raymie69      
         if(MaBuf[SIGNAL_BAR] > MbBuf[SIGNAL_BAR] && stoch1 > stoch2  && AlertOn == true)// added by raymie69             
          {
            PrevSignal = 1;// added by raymie69
            Alert("", Symbol(), " ", Period(), "  -  BUY!!!");// added by raymie69
          }
      }
  if(PrevSignal >= 0)// added by raymie69
      {
         //if(MaBuf[SIGNAL_BAR] < MbBuf[SIGNAL_BAR] && Close[SIGNAL_BAR] < SimpleMA && AlertOn == true)// added by raymie69      
         if(MaBuf[SIGNAL_BAR] < MbBuf[SIGNAL_BAR] && stoch1 < stoch2 && AlertOn == true)// added by raymie69      
          {
            PrevSignal = -1;// added by raymie69
            Alert("", Symbol(), " ", Period(), "  -  SELL!!!");// added by raymie69
          }
      }
  return(0);
  }

//+------------------------------------------------------------------+
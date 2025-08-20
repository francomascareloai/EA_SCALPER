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



#property indicator_buffers 8
#property indicator_color1 Black
#property indicator_color2 0XFFFFFFFF  // MediumBlue
#property indicator_color3 0xFFFFFFFF  // Yellow
#property indicator_color4 0XFFFFFFFF  // MediumBlue
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_separate_window

//--- plot Label1
#property indicator_label2  "Down"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  4
//--- plot Label1
#property indicator_label3  "Buy"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  4

extern int RSI_Period = 13;         //8-25
extern int RSI_Price = 0;           //0-6   
extern int RSI_Price_Line = 2;      
extern int RSI_Price_Type = 0;      //0-3
extern int Trade_Signal_Line = 7;   
extern int Trade_Signal_Type = 0;   //0-3

double RSIBuf[],UpZone[],MdZone[],DnZone[],MaBuf[],MbBuf[];

int init()
  {
   IndicatorShortName("TDI");
   SetIndexBuffer(0,RSIBuf);
   SetIndexBuffer(1,DnZone);
   SetIndexBuffer(2,UpZone);
   SetIndexBuffer(4,MaBuf);
   SetIndexBuffer(5,MbBuf);
   SetIndexStyle(0,DRAW_NONE); 
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);   //,0,2
   SetIndexStyle(5,DRAW_LINE);   //,0,2
   
   SetIndexLabel(0,NULL); 
   SetIndexLabel(1,"Sell"); 
   SetIndexLabel(2,"Buy"); 
   SetIndexLabel(3,"VB Low"); 
   SetIndexLabel(4,"RSI Price Line");
   SetIndexLabel(5,"Trade Signal Line");
 
   SetLevelValue(0,50);
   SetLevelValue(1,68);
   SetLevelValue(2,32);
   SetLevelStyle(STYLE_DOT,1,DimGray);
   
   return(0);
  }

int start()
  {
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   for(int i=limit; i>=0; i--)
      {
         RSIBuf[i] = (iRSI(NULL,0,RSI_Period,RSI_Price,i)); 
      }
   for (i=limit-1;i>=0;i--)  
      {
          MaBuf[i] = (iMAOnArray(RSIBuf,0,RSI_Price_Line,0,RSI_Price_Type,i));
          MbBuf[i] = (iMAOnArray(RSIBuf,0,Trade_Signal_Line,0,Trade_Signal_Type,i));   
      }
  for (i=limit-1;i>=0;i--)
      {
         UpZone[i]=0;DnZone[i]=0;
         if(MbBuf[i]>68 && MaBuf[i]<MbBuf[i] && MaBuf[i+1]>MbBuf[i+1]) DnZone[i]=20;
         if(MbBuf[i]<32 && MaBuf[i]>MbBuf[i] && MaBuf[i+1]<MbBuf[i+1]) UpZone[i]=20;
      }     
//----
   return(0);
  }
//+------------------------------------------------------------------+
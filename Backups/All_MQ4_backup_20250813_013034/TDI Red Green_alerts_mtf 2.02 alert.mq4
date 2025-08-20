
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
//|  Price & Line Type settings:                                     |                  
//|   RSI Price settings                                             |               
//|   0 = Close price     [DEFAULT]                                  |               
//|   1 = Open price.                                                |               
//|   2 = High price.                                                |               
//|   3 = Low price.                                                 |               
//|   4 = Median price, (high+low)/2.                                |               
//|   5 = Typical price, (high+low+close)/3.                         |               
//|   6 = Weighted close price, (high+low+close+close)/4.            |               
//|                                                                  |               
//|   RSI Price Line & Signal Line Type settings                     |               
//|   0 = Simple moving average       [DEFAULT]                      |               
//|   1 = Exponential moving average                                 |               
//|   2 = Smoothed moving average                                    |               
//|   3 = Linear weighted moving average                             |               
//|                                                                  |
//|   Good trading,                                                  |   
//|                                                                  |
//|   Dean                                                           |                              
//+------------------------------------------------------------------+


#property copyright " "
#property link      " "

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  MediumBlue
#property indicator_color2  Yellow
#property indicator_color3  MediumBlue
#property indicator_color4  Green
#property indicator_color5  Red
#property indicator_width2  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_levelcolor DimGray

//
//
//
//
//

extern string TimeFrame                = "Current time frame";
extern int    RsiPeriod                = 13;
extern int    RsiPrice                 = PRICE_CLOSE;
extern int    RsiPriceLinePeriod       = 2;
extern int    RsiPriceLineMAMode       = MODE_SMA;
extern int    RsiSignalLinePeriod      = 7;
extern int    RsiSignalLineMAMode      = MODE_SMA;
extern int    VolatilityBandPeriod     = 34;
extern int    VolatilityBandMAMode     = MODE_SMA;
extern double VolatilityBandMultiplier = 1.6185;
extern double LevelDown                = 32;
extern double LevelMiddle              = 50;
extern double LevelUp                  = 68;

extern string Alert;
extern bool   alertsAndArrowsOnMiddleCross = false;
extern string note                     = "turn on Alert = true; turn off = false";
extern bool   alertsOn                 = true;
extern bool   alertsOnCurrent          = false;
extern bool   alertsMessage            = true;
extern bool   alertsSound              = true;
extern bool   alertsEmail              = false;
extern string soundfile                = "alert2.wav";

extern string Arrow;
extern int _High_ = 226;
extern int _Low_ = 225;
extern string  __                      = "arrows settings";
extern bool   ShowArrows               = true; 
extern string ArrowsIdentifier         = "tdiarrows";
extern color  ArrowUpColor             = Aqua;
extern color  ArrowDownColor           = Red; 
extern int    ArrowUpWidth             = 1; 
extern int    ArrowDownWidth           = 1; 

//
//
//
//
//

double rsi[];
double rsiPriceLine[];
double rsiSignalLine[];
double bandUp[];
double bandMiddle[];
double bandDown[];
double trend[];
double atrend[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init() 
{
   IndicatorBuffers(7);
   SetIndexBuffer(0,bandUp);
   SetIndexBuffer(1,bandMiddle);
   SetIndexBuffer(2,bandDown);
   SetIndexBuffer(3,rsiPriceLine);
   SetIndexBuffer(4,rsiSignalLine);
   SetIndexBuffer(5,rsi);
   SetIndexBuffer(6,trend);

      //
      //
      //
      //
      //

      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);

      //
      //
      //
      //
      //
      
   SetLevelValue(0,LevelUp);
   SetLevelValue(1,LevelMiddle);
   SetLevelValue(2,LevelDown);
   IndicatorShortName(timeFrameToString(timeFrame)+ " Traders dynamic index");
   return (0);
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int deinit()
{
   if (ShowArrows)
   {
      int compareLength = StringLen(ArrowsIdentifier);
      for (int i=ObjectsTotal(); i>= 0; i--)
      {
         string name = ObjectName(i);
            if (StringSubstr(name,0,compareLength) == ArrowsIdentifier)
                ObjectDelete(name);  
      }
   }
   return(0);
}

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { bandUp[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      for(i=limit; i>=0; i--) rsi[i] = iRSI(NULL,0,RsiPeriod,RsiPrice,i);
      for(i=limit; i>=0; i--)
      {
         rsiPriceLine[i]  = iMAOnArray(rsi,0,RsiPriceLinePeriod,0,RsiPriceLineMAMode,i);
         rsiSignalLine[i] = iMAOnArray(rsi,0,RsiSignalLinePeriod,0,RsiSignalLineMAMode,i);
             double deviation = iStdDevOnArray(rsi,0,VolatilityBandPeriod,0,VolatilityBandMAMode,i);
             double average   = iMAOnArray(rsi,0,VolatilityBandPeriod,0,VolatilityBandMAMode,i);
                bandUp[i]     = average+VolatilityBandMultiplier*deviation;
                bandDown[i]   = average-VolatilityBandMultiplier*deviation;
                bandMiddle[i] = average;
                trend[i]      = 0;

            if (alertsAndArrowsOnMiddleCross)
            {       
               if (rsiPriceLine[i] > bandMiddle[i]) trend[i] =  1;
               if (rsiPriceLine[i] < bandMiddle[i]) trend[i] = -1; 
            }
            else
            {
               if (rsiPriceLine[i] > rsiSignalLine[i]) trend[i] =  1;
               if (rsiPriceLine[i] < rsiSignalLine[i]) trend[i] = -1; 
            }               
            if (!calculateValue)manageArrow(i);
        
       } 
      if (!calculateValue) manageAlerts(); 
   return (0);
   }      

   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         bandUp[i]        = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,0,y);
         bandMiddle[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,1,y);
         bandDown[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,2,y);
         rsiPriceLine[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,3,y);
         rsiSignalLine[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,4,y);
         trend[i]         = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,VolatilityBandMultiplier,6,y);
         
         if (alertsAndArrowsOnMiddleCross)
         {       
            if (rsiPriceLine[i] > bandMiddle[i]) trend[i] =  1;
            if (rsiPriceLine[i] < bandMiddle[i]) trend[i] = -1; 
         }
         else
         {
            if (rsiPriceLine[i] > rsiSignalLine[i]) trend[i] =  1;
            if (rsiPriceLine[i] < rsiSignalLine[i]) trend[i] = -1; 
         }               
         manageArrow(i);
        
   }
   manageAlerts(); 
return(0);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//


void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," TDI changed direction to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," TDI  "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageArrow(int i)
{
   if (ShowArrows)
   {
      double dist = iATR(NULL,0,20,i)/2.0;
      ObjectDelete(ArrowsIdentifier+Time[0]);         
            
      //
      //
      //
      //
      //
           
         if (trend[i] !=trend[i+1])
         {
            string name = ArrowsIdentifier+Time[i];
            if (trend[i] == 1)
            {
               ObjectCreate(name,OBJ_ARROW,0, Time[i],Low[i]-dist );
                  ObjectSet(name,OBJPROP_ARROWCODE,_Low_);
                  ObjectSet(name,OBJPROP_COLOR,ArrowUpColor);
                  ObjectSet(name,OBJPROP_WIDTH,ArrowUpWidth);
            }
            else
            {
               ObjectCreate(name,OBJ_ARROW,0, Time[i],High[i]+dist );
                  ObjectSet(name,OBJPROP_ARROWCODE,_High_);
                  ObjectSet(name,OBJPROP_COLOR,ArrowDownColor);
                  ObjectSet(name,OBJPROP_WIDTH,ArrowDownWidth);
            }
         }
   }
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int ichar = StringGetChar(s, length);
         if((ichar > 96 && ichar < 123) || (ichar > 223 && ichar < 256))
                     s = StringSetChar(s, length, ichar - 32);
         else if(ichar > -33 && ichar < 0)
                     s = StringSetChar(s, length, ichar + 224);
   }
   return(s);
}


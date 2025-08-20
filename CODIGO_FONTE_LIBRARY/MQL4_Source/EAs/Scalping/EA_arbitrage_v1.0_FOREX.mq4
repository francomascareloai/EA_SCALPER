//+------------------------------------------------------------------+
//|                                                    Arbitrage.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright  "Copyright 2015, MetaQuotes Software Corp."
#property link       "https://www.mql5.com"
#property description"Arbitrage by pipPod"
#property version    "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Base
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Quote
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrFireBrick
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
ushort indicator_width3;
//--- indicator levels
#property indicator_levelcolor clrLightSlateGray
//---
double indicator_level1=   0;
double indicator_level2=  .2;
double indicator_level3= -.2;
double indicator_level4=  20;
double indicator_level5= -20;
double indicator_level6=  30;
double indicator_level7= -30;
double indicator_level8= 100;
double indicator_level9=-100;
//---
enum indicators
  {
   INDICATOR_MACD,         //Moving Average Convergence/Divergence
   INDICATOR_STOCHASTIC,   //Stochastic Oscillator
   INDICATOR_RSI,          //Relative Strength Index
   INDICATOR_CCI,          //Commodity Channel Index
   INDICATOR_RVI,          //Relative Vigor Index
   INDICATOR_DEMARK,       //DeMarker Oscillator
  };
//--- indicator to show
input indicators  Indicator=INDICATOR_MACD;
//--- index timeframe
input ENUM_TIMEFRAMES TimeFrame=0;
//--- indicator parameters
input string MACD;
input int FastEMA=12;                           //Fast EMA Period
input int SlowEMA=26;                           //Slow EMA Period
input int SignalSMA=9;                          //Signal SMA Period
input ENUM_APPLIED_PRICE MACDPrice=PRICE_CLOSE; //MACD Price
//---
input string Stochastic;
input int Kperiod=7;                            //K Period
input int Dperiod=3;                            //D Period
input int Slowing=3;    
input ENUM_STO_PRICE PriceField=STO_LOWHIGH;    //Price Field
//---
input string RSI;
input int  RSIPeriod=14;                        //RSI Period
input ENUM_APPLIED_PRICE RSIPrice=PRICE_CLOSE;  //RSI Price
//---
input string CCI;
input int  CCIPeriod=14;                        //CCI Period
input ENUM_APPLIED_PRICE CCIPrice=PRICE_CLOSE;  //CCI Price
//---
input string RVI;
input int  RVIPeriod=14;                        //RVI Period
//---
input string DeMarker;
input int  DeMarkerPeriod=14;                   //DeMarker Period
input string _;//---
input bool ColorBars=true;    //Color Bars
input bool FillBuffers=true;  //Fill Buffers
input string __;//---
input bool AlertsOn=false;
//---index buffers for drawing
double   BaseBuffer[];
double   QoteBuffer[];
//---currency variables for calculation
#define  USDJPY   "USDJPY"
//---
string   base,
         quote,
         symbol1,
         symbol2,
         symbol3;
//---
double   index1,
         index2,
         index3,
         baseIndex,
         qoteIndex;
//---
bool     baseUSD=false,
         quoteUSD=false,
         quoteJPY=false,
         quoteJPY1=false,
         quoteJPY2=false,
         quoteJPY3=false;
//---set index colors
color    color1 = indicator_color1,
         color2 = indicator_color2,
         colorFill;
//---
string   shortName;
long     chartID=ChartID();
short    window;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---currencies to show
   base = StringSubstr(_Symbol,0,3);  //Base currency name
   quote= StringSubstr(_Symbol,3,3);  //Quote currency name
   if(_Symbol=="EURUSD")  
     {
      color1 = clrRoyalBlue;
      color2 = clrLimeGreen;
      quoteUSD = true;
      symbol1 = _Symbol;
      symbol2 = "EURJPY";
      quoteJPY2 = true;
      symbol3 = USDJPY;
      quoteJPY3 = true;
     }
   if(_Symbol=="EURJPY")  
     {
      color1 = clrRoyalBlue;
      color2 = clrYellow;
      quoteJPY = true;
      symbol1 = _Symbol;
      quoteJPY1 = true;
      symbol2 = "EURUSD";
      symbol3 = USDJPY;
      quoteJPY3 = true;
     }
   if(_Symbol=="GBPUSD")  
     {
      color1 = clrSilver;
      color2 = clrLimeGreen;
      quoteUSD = true;
      symbol1 = _Symbol;
      symbol2 = "GBPJPY";
      quoteJPY2 = true;
      symbol3 = USDJPY;
      quoteJPY3 = true;
     }
   if(_Symbol=="GBPJPY")  
     {
      color1 = clrSilver;
      color2 = clrYellow;
      quoteJPY = true;
      symbol1 = _Symbol;
      quoteJPY1 = true;
      symbol2 = "GBPUSD";
      symbol3 = USDJPY;
      quoteJPY3 = true;
     }
   if(_Symbol=="AUDUSD")  
     {
      color1 = clrDarkOrange;
      color2 = clrLimeGreen;
      quoteUSD = true;
      symbol1 = _Symbol;
      symbol2 = "AUDJPY";
      quoteJPY2 = true;
      symbol3 = USDJPY;
      quoteJPY3 = true;
     }
   if(_Symbol=="USDCAD")
     {
      color1 = clrLimeGreen;
      color2 = clrWhiteSmoke;
      baseUSD = true;
      symbol1 = _Symbol;
      symbol2 = "CADJPY";
      quoteJPY2 = true;
      symbol3 = USDJPY;
      quoteJPY3 = true;
     }
   if(_Symbol=="USDCHF")
     {
      color1 = clrLimeGreen;
      color2 = clrFireBrick;
      baseUSD = true;
      symbol1 = _Symbol;
      symbol2 = "CHFJPY";
      quoteJPY2 = true;
      symbol3 = USDJPY;
      quoteJPY3 = true;
     }
   if(_Symbol==USDJPY)  
     {
      color1 = clrLimeGreen;
      color2 = clrYellow;
      quoteJPY = true;
      symbol1 = _Symbol;
      quoteJPY1 = true;
      symbol2 = "EURUSD";
      symbol3 = "EURJPY";
      quoteJPY3 = true;
     }
//---set timeframes
   string timeFrame = StringSubstr(EnumToString(TimeFrame),7);
   if(timeFrame=="CURRENT")
      timeFrame = "";
//---
   switch(Indicator)
     {
      case INDICATOR_MACD:
         shortName=StringFormat("Arbitrage MACD %s(%d,%d,%d)",
                                timeFrame,FastEMA,SlowEMA,SignalSMA);
         IndicatorSetInteger(INDICATOR_DIGITS,5);
         IndicatorSetInteger(INDICATOR_LEVELS,1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         break;
      case INDICATOR_STOCHASTIC:
         shortName=StringFormat("Arbitrage Stochastic %s(%d,%d,%d)",
                                timeFrame,Kperiod,Dperiod,Slowing);
         IndicatorSetInteger(INDICATOR_DIGITS,0);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level6);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,indicator_level7);
         break;
      case INDICATOR_RSI:
         shortName=StringFormat("Arbitrage RSI %s(%d)",
                                timeFrame,RSIPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,0);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level4);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,indicator_level5);
         break;
      case INDICATOR_CCI:
         shortName=StringFormat("Arbitrage CCI %s(%d)",
                                timeFrame,CCIPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,0);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level8);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,indicator_level9);
         break;
      case INDICATOR_RVI:
         shortName=StringFormat("Arbitrage RVI %s(%d)",
                                timeFrame,RVIPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,3);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level2);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,indicator_level3);
         break;
      case INDICATOR_DEMARK:
         shortName=StringFormat("Arbitrage DeMarker %s(%d)",
                                timeFrame,DeMarkerPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,3);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level2);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,indicator_level3);
     }  
   IndicatorSetString(INDICATOR_SHORTNAME,shortName);
   window = ChartWindowFind(chartID,shortName);
   int xStart = 4;       //label coordinates
   int xIncrement = 25;
   int yStart = 16;
   ObjectCreate(base,xStart,yStart,color1);
   xStart += xIncrement;
   ObjectCreate(quote,xStart,yStart,color2);
//---index buffers
   SetIndexBuffer(0,BaseBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,QoteBuffer,INDICATOR_DATA);
   SetIndexStyle(0,EMPTY,EMPTY,EMPTY,color1);
   SetIndexStyle(1,EMPTY,EMPTY,EMPTY,color2);
   SetIndexLabel(0,base);
   SetIndexLabel(1,quote);
//---color bars
   if(ColorBars)
     {
      if(ChartGetInteger(0,CHART_COLOR_CANDLE_BULL)!=color1)
        {
         ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,color1);
         ChartSetInteger(0,CHART_COLOR_CHART_UP,color1);
        }
      if(ChartGetInteger(0,CHART_COLOR_CANDLE_BEAR)!=color2)
        {
         ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,color2);
         ChartSetInteger(0,CHART_COLOR_CHART_DOWN,color2);
        }
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
#define INVERT -1
#define BUY "BUY"
#define SELL "SELL"
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit = rates_total-prev_calculated;
   if(prev_calculated>rates_total || prev_calculated<=0)  
     {
      int barsWindow = (int)ChartGetInteger(chartID,CHART_VISIBLE_BARS)+100;
      if(iBars(symbol1,TimeFrame)<=barsWindow ||
         iBars(symbol2,TimeFrame)<=barsWindow ||
         iBars(symbol3,TimeFrame)<=barsWindow)
         return(0);
      SetIndexDrawBegin(0,rates_total-barsWindow);
      SetIndexDrawBegin(1,rates_total-barsWindow);
      limit = barsWindow;
//---
      if(FillBuffers)
        {
         ushort scale = ChartGetInteger(chartID,CHART_SCALE);
         switch(scale)
           {
            case 5:  indicator_width3 = 24;  break;
            case 4:  indicator_width3 = 12;  break;
            case 3:  indicator_width3 = 6;   break;
            case 2:  indicator_width3 = 3;   break;
            default: indicator_width3 = 1;  
           }
        }
     }  
   if(prev_calculated>0 && NewBar(time[0]))
      limit++;
//---
   for(int i=limit;i>=0 && !IsStopped();i--)
     {
      int shift = iBarShift(NULL,TimeFrame,time[i]);
      switch(Indicator)
        {
         case INDICATOR_MACD:
            index1 = iMACD(symbol1,TimeFrame,FastEMA,SlowEMA,SignalSMA,MACDPrice,MODE_MAIN,shift);
            index2 = iMACD(symbol2,TimeFrame,FastEMA,SlowEMA,SignalSMA,MACDPrice,MODE_MAIN,shift);
            index3 = iMACD(symbol3,TimeFrame,FastEMA,SlowEMA,SignalSMA,MACDPrice,MODE_MAIN,shift);
            if(quoteJPY1)
               index1 /= 100;
            if(quoteJPY2)
               index2 /= 100;
            if(quoteJPY3)
               index3 /= 100;
            break;
         case INDICATOR_STOCHASTIC:
            index1 = iStochastic(symbol1,TimeFrame,Kperiod,Dperiod,Slowing,MODE_SMA,PriceField,MODE_MAIN,shift)-50;
            index2 = iStochastic(symbol2,TimeFrame,Kperiod,Dperiod,Slowing,MODE_SMA,PriceField,MODE_MAIN,shift)-50;
            index3 = iStochastic(symbol3,TimeFrame,Kperiod,Dperiod,Slowing,MODE_SMA,PriceField,MODE_MAIN,shift)-50;
            break;
         case INDICATOR_RSI:
            index1 = iRSI(symbol1,TimeFrame,RSIPeriod,RSIPrice,shift)-50;
            index2 = iRSI(symbol2,TimeFrame,RSIPeriod,RSIPrice,shift)-50;
            index3 = iRSI(symbol3,TimeFrame,RSIPeriod,RSIPrice,shift)-50;
            break;
         case INDICATOR_CCI:
            index1 = iCCI(symbol1,TimeFrame,CCIPeriod,CCIPrice,shift);
            index2 = iCCI(symbol2,TimeFrame,CCIPeriod,CCIPrice,shift);
            index3 = iCCI(symbol3,TimeFrame,CCIPeriod,CCIPrice,shift);
            break;
         case INDICATOR_RVI:
            index1 = iRVI(symbol1,TimeFrame,RVIPeriod,MODE_MAIN,shift);
            index2 = iRVI(symbol2,TimeFrame,RVIPeriod,MODE_MAIN,shift);
            index3 = iRVI(symbol3,TimeFrame,RVIPeriod,MODE_MAIN,shift);
            break;
         case INDICATOR_DEMARK:
            index1 = iDeMarker(symbol1,TimeFrame,DeMarkerPeriod,shift)-.5;
            index2 = iDeMarker(symbol2,TimeFrame,DeMarkerPeriod,shift)-.5;
            index3 = iDeMarker(symbol3,TimeFrame,DeMarkerPeriod,shift)-.5;
        }
//---
      if(quoteUSD)
        {
         baseIndex = (index1+index2)/2;
         index1 *= INVERT;
         qoteIndex = (index1+index3)/2;          
        }
      if(quoteJPY)
        {
         if(_Symbol==USDJPY)  
            index2 *= INVERT;
         baseIndex = (index1+index2)/2;
         index1 *= INVERT;
         index3 *= INVERT;
         qoteIndex = (index1+index3)/2;          
        }
      if(baseUSD)
        {
         baseIndex = (index1+index3)/2;
         index1 *= INVERT;
         qoteIndex = (index1+index2)/2;          
        }
//---
      BaseBuffer[i] = baseIndex;
      QoteBuffer[i] = qoteIndex;
//---
      if(FillBuffers)
        {
         colorFill = (baseIndex>qoteIndex)?color1:color2;
         ObjectCreate((string)(uint)time[i],time[i],BaseBuffer[i],QoteBuffer[i]);
        }  
//---
      if(AlertsOn && prev_calculated>0)
        {
         static datetime timePrev;
         if(BaseBuffer[i]>QoteBuffer[i] &&
            BaseBuffer[i+1]<QoteBuffer[i+1] &&
            timePrev!=time[0])
           {
            Alert(BUY+_Symbol);
            timePrev = time[0];
           }
         if(BaseBuffer[i]<QoteBuffer[i] &&
            BaseBuffer[i+1]>QoteBuffer[i+1] &&
            timePrev!=time[0])
           {
            Alert(SELL+_Symbol);
            timePrev = time[0];
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // delete labels
   ObjectDelete(chartID,base);
   ObjectDelete(chartID,quote);
   ObjectsDeleteAll(chartID,window,OBJ_TREND);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectCreate(string currency,
                  int x,
                  int y,
                  color clr)
  {
   if(!ObjectCreate(chartID,currency,OBJ_LABEL,window,0,0))
     {
      Print(__FUNCTION__,": error ",GetLastError());
      return;
     }
   ObjectSetString(chartID,currency,OBJPROP_TEXT,currency);
   ObjectSetString(chartID,currency,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(chartID,currency,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(chartID,currency,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,currency,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartID,currency,OBJPROP_YDISTANCE,y);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OBJ_NONE -1
void ObjectCreate(string object_name,
                  const datetime &time,
                  const double &high,
                  const double &low)
  {
   if(ObjectFind(chartID,object_name)!=OBJ_NONE)
      ObjectDelete(chartID,object_name);
   if(!ObjectCreate(chartID,object_name,OBJ_TREND,window,time,high,time,low))
     {
      Print(__FUNCTION__,": error ",GetLastError());
      return;
     }
   ObjectSetInteger(chartID,object_name,OBJPROP_WIDTH,indicator_width3);
   ObjectSetInteger(chartID,object_name,OBJPROP_COLOR,colorFill);
   ObjectSetInteger(chartID,object_name,OBJPROP_RAY,false);
   ObjectSetInteger(chartID,object_name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartID,object_name,OBJPROP_SELECTABLE,false);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar(const datetime &time)
  {
   static datetime currTime1[1],
                   currTime2[1],
                   currTime3[1],
                   prevTime;
   if(CopyTime(symbol1,TimeFrame,time,1,currTime1)!=1 ||
      CopyTime(symbol2,TimeFrame,time,1,currTime2)!=1 ||
      CopyTime(symbol3,TimeFrame,time,1,currTime3)!=1)
      return(false);
   if(prevTime!=currTime1[0] &&
      prevTime!=currTime2[0] &&
      prevTime!=currTime3[0])
     {
      prevTime = currTime1[0];
      return(true);
     }
   return(false);
  }
//-------------------------------------------------------------------+
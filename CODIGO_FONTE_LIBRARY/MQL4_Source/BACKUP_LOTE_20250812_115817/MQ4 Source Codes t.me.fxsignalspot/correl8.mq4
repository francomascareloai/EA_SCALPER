//+------------------------------------------------------------------+
//|                                                      Correl8.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 8
//#property indicator_minimum -70
//#property indicator_maximum  70
#property indicator_color1 clrRoyalBlue
#property indicator_color2 clrSilver
#property indicator_color3 clrDarkOrange
#property indicator_color4 clrDarkViolet
#property indicator_color5 clrFireBrick
#property indicator_color6 clrMagenta
#property indicator_color7 clrYellow
#property indicator_color8 clrLimeGreen

#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  3

#define      LEVELS         7 

#define      HIGH_LOW       0
#define      CLOSE_CLOSE    1
#define      HIGH_LOW_CLOSE 2
// Indicator parameters
extern int   PRIPeriod  = 14;
input string _          = "0=Close 4=Median 5=Typical 6=Weighted";
input int    Price      = PRICE_CLOSE;
input string __         = "0=High/Low 1=Close/Close 2=High/Low/Close";
input int    PRIMode    = HIGH_LOW;
input int    TimeFrame  = 0;
// Show currencies on chart
input bool   ShowAuto = true;
// Show all currencies
extern bool  ShowAll = false;
extern bool  ShowEUR = false;
extern bool  ShowGBP = false;
extern bool  ShowAUD = false;
extern bool  ShowNZD = false;
extern bool  ShowCHF = false;
extern bool  ShowCAD = false;
extern bool  ShowJPY = false;
extern bool  ShowUSD = false;
//---index buffers for drawing
double Idx1[],Idx2[],Idx3[],Idx4[],Idx5[],Idx6[],Idx7[],Idx8[];
//---indicator levels
int BufferLevel[LEVELS] = {-50,-26,-12,  0, 12, 26, 50};
//---currency variables for calculation
int EUR,GBP,AUD,NZD,CHF,CAD,JPY,USD;
//---currency names and colors
string Currencies[indicator_buffers] = {"EUR","GBP","AUD","NZD",
                                        "CHF","CAD","JPY","USD"};
int Colors[indicator_buffers] = {indicator_color1,indicator_color2,
                                 indicator_color3,indicator_color4,
                                 indicator_color5,indicator_color6,
                                 indicator_color7,indicator_color8};
string ShortName;
int    BarsWindow;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   IndicatorDigits(0);
   IndicatorBuffers(indicator_buffers);
//---set timeframes
   if(TimeFrame==0)
     {
      switch(Period())
        {
         case PERIOD_M30: PRIPeriod*=2;break;
         case PERIOD_M15: PRIPeriod*=4;break;
         case PERIOD_M5:  PRIPeriod*=12;break;
         case PERIOD_M1:  PRIPeriod*=60;break;
        }
     }
   if(TimeFrame>0)
     {
      switch(TimeFrame)
        {
         case PERIOD_M30: PRIPeriod*=2;break;
         case PERIOD_M15: PRIPeriod*=4;break;
         case PERIOD_M5:  PRIPeriod*=12;break;
         case PERIOD_M1:  PRIPeriod*=60;break;
        }
     }
   string sTimeFrame;
   switch(TimeFrame)
      {
       case PERIOD_MN1: sTimeFrame = "MN1 ";break;
       case PERIOD_W1:  sTimeFrame = "W1 "; break;
       case PERIOD_D1:  sTimeFrame = "D1 "; break;
       case PERIOD_H4:  sTimeFrame = "H4 "; break;
       case PERIOD_H1:  sTimeFrame = "H1 "; break;
       case PERIOD_M30: sTimeFrame = "M30 ";break;
       case PERIOD_M15: sTimeFrame = "M15 ";break;
       case PERIOD_M5:  sTimeFrame = "M5 "; break;
       case PERIOD_M1:  sTimeFrame = "M1 "; break;
       default:         sTimeFrame = "";    break;
      }
   ShortName="iCorrel8 "+sTimeFrame+"("+PRIPeriod+") ";
   IndicatorShortName(ShortName);
   BarsWindow=WindowBarsPerChart()+PRIPeriod;
//---set indicator levels
   for(int l=0;l<LEVELS;l++)
      SetLevelValue(l,BufferLevel[l]);
      SetLevelStyle(STYLE_DOT,1,LightSlateGray);
//---currencies to show
   if(ShowAuto)
     {
      string Quote= StringSubstr(Symbol(),3,3);  //Quote currency name
      string Base = StringSubstr(Symbol(),0,3);  //Base currency name
      if(Quote == "EUR" || Base == "EUR")  ShowEUR = true;
      if(Quote == "GBP" || Base == "GBP")  ShowGBP = true;
      if(Quote == "AUD" || Base == "AUD")  ShowAUD = true;
      if(Quote == "NZD" || Base == "NZD")  ShowNZD = true;
      if(Quote == "CHF" || Base == "CHF")  ShowCHF = true;
      if(Quote == "CAD" || Base == "CAD")  ShowCAD = true;
      if(Quote == "JPY" || Base == "JPY")  ShowJPY = true;
      if(Quote == "USD" || Base == "USD")  ShowUSD = true;
      ShowAll=false;
     }

   if(ShowAll)
     {
      ShowEUR = true;
      ShowGBP = true;
      ShowAUD = true;
      ShowNZD = true;
      ShowCHF = true;
      ShowCAD = true;
      ShowJPY = true;
      ShowUSD = true;
     }
   
   int window=WindowFind(ShortName);
   int xStart=4;       //label coordinates
   int xIncrement=25;
   int yStart=16;
//---set buffer properties
   if(ShowEUR)
     {
      SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,indicator_width1);
      SetIndexLabel(0,Currencies[0]);
      SetIndexDrawBegin(0,Bars-BarsWindow);
      CreateLabel(Currencies[0],window,xStart,yStart,indicator_color1);
      xStart+=xIncrement;
     }
   if(ShowGBP)
     {
      SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,indicator_width2);
      SetIndexLabel(1,Currencies[1]);
      SetIndexDrawBegin(1,Bars-BarsWindow);
      CreateLabel(Currencies[1],window,xStart,yStart,indicator_color2);
      xStart+=xIncrement;
     }
   if(ShowAUD)
     {
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,indicator_width3);
      SetIndexLabel(2,Currencies[2]);
      SetIndexDrawBegin(2,Bars-BarsWindow);
      CreateLabel(Currencies[2],window,xStart,yStart,indicator_color3);
      xStart+=xIncrement;
     }
   if(ShowNZD)
     {
      SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,indicator_width4);
      SetIndexDrawBegin(3,Bars-BarsWindow);
      SetIndexLabel(3,Currencies[3]);
      CreateLabel(Currencies[3],window,xStart,yStart,indicator_color4);
      xStart+=xIncrement;
     }
   if(ShowCHF)
     {
      SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,indicator_width5);
      SetIndexLabel(4,Currencies[4]);
      SetIndexDrawBegin(4,Bars-BarsWindow);
      CreateLabel(Currencies[4],window,xStart,yStart,indicator_color5);
      xStart+=xIncrement;
     }
   if(ShowCAD)
     {
      SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,indicator_width6);
      SetIndexLabel(5,Currencies[5]);
      SetIndexDrawBegin(5,Bars-BarsWindow);
      CreateLabel(Currencies[5],window,xStart,yStart,indicator_color6);
      xStart+=xIncrement;
     }
   if(ShowJPY)
     {
      SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,indicator_width7);
      SetIndexLabel(6,Currencies[6]);
      SetIndexDrawBegin(6,Bars-BarsWindow);
      CreateLabel(Currencies[6],window,xStart,yStart,indicator_color7);
      xStart+=xIncrement;
     }
   if(ShowUSD)
     {
      SetIndexStyle(7,DRAW_LINE,STYLE_SOLID,indicator_width8);
      SetIndexLabel(7,Currencies[7]);
      SetIndexDrawBegin(7,Bars-BarsWindow);
      CreateLabel(Currencies[7],window,xStart,yStart,indicator_color8);
      xStart+=xIncrement;
     }
//---index buffers
   SetIndexBuffer(0,Idx1);
   SetIndexBuffer(1,Idx2);
   SetIndexBuffer(2,Idx3);
   SetIndexBuffer(3,Idx4);
   SetIndexBuffer(4,Idx5);
   SetIndexBuffer(5,Idx6);
   SetIndexBuffer(6,Idx7);
   SetIndexBuffer(7,Idx8);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // delete labels
   //int window=WindowFind(ShortName);
   for(int i=0;i<indicator_buffers;i++)
       ObjectDelete(Currencies[i]);
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   int shift;
   int limit=rates_total-prev_calculated;
   if(prev_calculated==0)  limit = BarsWindow;
   if(prev_calculated>0 && NewBar())   limit = 1;
   for(int i=limit; i>=0; i--)
     {
      shift=iBarShift(NULL,TimeFrame,time[i]);

      EUR = iPRI("EURUSD",TimeFrame,PRIPeriod,Price,shift);
      GBP = iPRI("GBPUSD",TimeFrame,PRIPeriod,Price,shift);
      AUD = iPRI("AUDUSD",TimeFrame,PRIPeriod,Price,shift);
      NZD = iPRI("NZDUSD",TimeFrame,PRIPeriod,Price,shift);
      CHF = iPRI("USDCHF",TimeFrame,PRIPeriod,Price,shift);
      CAD = iPRI("USDCAD",TimeFrame,PRIPeriod,Price,shift);
      JPY = iPRI("USDJPY",TimeFrame,PRIPeriod,Price,shift);

      EUR *= 1/iClose("EURUSD",TimeFrame,shift);   //Get USD ratio      
      GBP *= 1/iClose("GBPUSD",TimeFrame,shift);
      AUD *= 1/iClose("AUDUSD",TimeFrame,shift);
      NZD *= 1/iClose("NZDUSD",TimeFrame,shift);
      CHF *= (-1); //1/iClose("USDCHF",TimeFrame,shift);
      CAD *= (-1); //1/iClose("USDCAD",TimeFrame,shift);
      JPY *= (-1); //1/(iClose("USDJPY",TimeFrame,shift)/100);

      USD =  (EUR + GBP + AUD + NZD + CHF + CAD + JPY)/(-7);   //USD relative to other 
    /*EUR += (GBP + AUD + NZD + CHF + CAD + JPY)/(-6);         //Currency relative to USD
      GBP += (EUR + AUD + NZD + CHF + CAD + JPY)/(-6);
      AUD += (EUR + GBP + NZD + CHF + CAD + JPY)/(-6);
      NZD += (EUR + GBP + AUD + CHF + CAD + JPY)/(-6);
      CHF += (EUR + GBP + AUD + NZD + CAD + JPY)/(-6);
      CAD += (EUR + GBP + AUD + NZD + CHF + JPY)/(-6);
      JPY += (EUR + GBP + AUD + NZD + CHF + CAD)/(-6);
    */
      if(ShowEUR)
         Idx1[i] = EUR;
      if(ShowGBP)
         Idx2[i] = GBP;
      if(ShowAUD)
         Idx3[i] = AUD;
      if(ShowNZD)
         Idx4[i] = NZD;
      if(ShowCHF)
         Idx5[i] = CHF;
      if(ShowCAD)
         Idx6[i] = CAD;
      if(ShowJPY)
         Idx7[i] = JPY;
      if(ShowUSD)
         Idx8[i] = USD;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string currency,int window,int x,int y,int colour)
  {
   int label=ObjectCreate(currency,OBJ_LABEL,window,0,0);
   ObjectSetText(currency,currency,8);
   ObjectSet(currency,OBJPROP_COLOR,colour);
   ObjectSet(currency,OBJPROP_XDISTANCE,x);
   ObjectSet(currency,OBJPROP_YDISTANCE,y);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime time_prev;
   if(iTime("EURUSD",TimeFrame,0) != time_prev &&
      iTime("GBPUSD",TimeFrame,0) != time_prev &&
      iTime("AUDUSD",TimeFrame,0) != time_prev &&
      iTime("NZDUSD",TimeFrame,0) != time_prev &&
      iTime("USDCHF",TimeFrame,0) != time_prev &&
      iTime("USDCAD",TimeFrame,0) != time_prev &&
      iTime("USDJPY",TimeFrame,0) != time_prev)
     {
      time_prev = iTime("EURUSD",TimeFrame,0);
      time_prev = iTime("GBPUSD",TimeFrame,0);
      time_prev = iTime("AUDUSD",TimeFrame,0);
      time_prev = iTime("NZDUSD",TimeFrame,0);
      time_prev = iTime("USDCHF",TimeFrame,0);
      time_prev = iTime("USDCAD",TimeFrame,0);
      time_prev = iTime("USDJPY",TimeFrame,0);
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Percent Range Index Function                                     |
//+------------------------------------------------------------------+
int iPRI(string symbol,int timeframe,int period,int price,int idx)
  {
   int PRI;
   double iPrice;
   double Range;
   double MaxHigh;
   double MinLow;
   double HighHigh;
   double HighClose;
   double HighLow;
   double LowHigh;
   double LowClose;
   double LowLow;

   switch(PRIMode)
     {
      case HIGH_LOW:
        {
         MaxHigh = iHigh(symbol,timeframe,
                   iHighest(symbol,timeframe,MODE_HIGH,period,idx));
         MinLow = iLow(symbol,timeframe,
                  iLowest(symbol,timeframe,MODE_LOW,period,idx));
         break;
        }
      case CLOSE_CLOSE:
        {
         MaxHigh = iClose(symbol,timeframe,
                   iHighest(symbol,timeframe,MODE_CLOSE,period,idx));
         MinLow = iClose(symbol,timeframe,
                  iLowest(symbol,timeframe,MODE_CLOSE,period,idx));
         break;
        }
      case HIGH_LOW_CLOSE:
        {
         HighHigh = iHigh(symbol,timeframe,
                    iHighest(symbol,timeframe,MODE_HIGH,period,idx));
         HighClose = iClose(symbol,timeframe,
                     iHighest(symbol,timeframe,MODE_CLOSE,period,idx));
         HighLow = iLow(symbol,timeframe,
                   iHighest(symbol,timeframe,MODE_LOW,period,idx));
         LowHigh = iHigh(symbol,timeframe,
                   iLowest(symbol,timeframe,MODE_HIGH,period,idx));
         LowClose = iClose(symbol,timeframe,
                    iLowest(symbol,timeframe,MODE_CLOSE,period,idx));
         LowLow = iLow(symbol,timeframe,
                  iLowest(symbol,timeframe,MODE_LOW,period,idx));
         MaxHigh = (HighHigh+HighClose+HighLow)/3;
         MinLow = (LowHigh+LowClose+LowLow)/3;
         break;
        }
     }
   
   switch(price)
     {
      case PRICE_CLOSE:    iPrice =  iClose(symbol,timeframe,idx); break;
      case PRICE_HIGH:     iPrice =  iHigh(symbol,timeframe,idx); break;
      case PRICE_LOW:      iPrice =  iLow(symbol,timeframe,idx); break;
      case PRICE_MEDIAN:   iPrice = (iHigh(symbol,timeframe,idx)+
                                     iLow(symbol,timeframe,idx))/2; break;
      case PRICE_TYPICAL:  iPrice = (iHigh(symbol,timeframe,idx)+
                                     iLow(symbol,timeframe,idx)+
                                     iClose(symbol,timeframe,idx))/3; break;
      case PRICE_WEIGHTED: iPrice = (iHigh(symbol,timeframe,idx)+
                                     iLow(symbol,timeframe,idx)+
                                     iClose(symbol,timeframe,idx)+
                                     iClose(symbol,timeframe,idx))/4; break;
      default:             iPrice =  iClose(symbol,timeframe,idx); break;
     }
   
   Range=MaxHigh-MinLow;

   if(NormalizeDouble(Range,3)!=0.0)
     {
      PRI = 100*(iPrice-MinLow)/Range;
      PRI -= 50;
     }
   else PRI=0;
   //if(PRI >  50)   PRI =  50;
   //if(PRI < -50)   PRI = -50;
   return(PRI);
  }
//+------------------------------------------------------------------+

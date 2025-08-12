//+------------------------------------------------------------------+
//|                                                AdaptiveRenko.mq5 |
//|                                    Copyright � 2010,   Svinozavr | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright � 2010,   Svinozavr"
#property link ""
#property description "Adaptive Renko"
//---- indicator version number
#property version   "1.10"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----four buffers are used for calculation of drawing of the indicator
#property indicator_buffers 4
//---- four plots are used in total
#property indicator_plots   4
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- DodgerBlue color is used for the indicator
#property indicator_color1  DodgerBlue
//---- Indicator line is a solid one
#property indicator_style1 STYLE_DASHDOTDOT
//---- indicator 1 width is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Lower AdaptiveRenko"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- Magenta color is used for the indicator
#property indicator_color2  Magenta
//---- Indicator line is a solid one
#property indicator_style2 STYLE_DASHDOTDOT
//---- indicator 2 width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2 "Upper AdaptiveRenko"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 3 as line
#property indicator_type3   DRAW_LINE
//---- lime color is used for the indicator
#property indicator_color3  Lime
//---- Indicator line is a solid one
#property indicator_style3 STYLE_SOLID
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying of the bullish label of the indicator
#property indicator_label3  "AdaptiveRenko Support"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 4 as line
#property indicator_type4   DRAW_LINE
//---- Red color is used for the indicator
#property indicator_color4  Red
//---- Indicator line is a solid one
#property indicator_style4 STYLE_SOLID
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying of the bearish label of the indicator
#property indicator_label4 "AdaptiveRenko Resistance"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  declaration of enumeration                  |
//+----------------------------------------------+
enum IndMode //Type of constant
  {
   ATR,     //ATR indicator
   StDev    //StDev indicator
  };
//+----------------------------------------------+
//|  declaration of enumeration                  |
//+----------------------------------------------+
enum PriceMode //Type of constant
  {
   HighLow_, //High/Low
   Close_    //Close
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input double K=1; //multiplier
input IndMode Indicator=ATR; //indicator to calculate
input uint VltPeriod=10; // period of volatility
input PriceMode Price=Close_; //price calculation method
input uint WideMin=2; // the minimum thickness of a brick in points
//+----------------------------------------------+
double sens;
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double DnBuffer[],UpBuffer[];
double UpTrendBuffer[],DnTrendBuffer[];
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//----Declaration of variables for storing the indicators handles
int Ind_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables    
   min_rates_total=int(VltPeriod);
   sens=WideMin*_Point;

   if(Indicator==ATR) Ind_Handle=iATR(NULL,0,VltPeriod);
   else  Ind_Handle=iStdDev(NULL,0,VltPeriod,0,MODE_SMA,PRICE_CLOSE);
   if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of the indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,UpTrendBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpTrendBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,DnTrendBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnTrendBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="AdaptiveRenko";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate
(const int rates_total,
 const int prev_calculated,
 const datetime &Time[],
 const double &Open[],
 const double &High[],
 const double &Low[],
 const double &Close[],
 const long &Tick_Volume[],
 const long &Volume[],
 const int &Spread[]
 )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,trend;
   double Hi,Lo,vlt,Brick,Up,Dn;
   double IndArray[];
   static double Brick_,Up_,Dn_;
   static int trend_;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(IndArray,true);

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      if(Price==Close_) {Hi=Close[limit]; Lo=Hi;}
      else {Hi=High[limit]; Lo=Low[limit];}
      Brick_=MathMax(K*(Hi-Lo),sens);
      Up_=Hi;
      Dn_=Lo;
      trend_=0;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
//----   
   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(Ind_Handle,0,0,to_copy,IndArray)<=0) return(RESET);
   
//---- restoring the values of the variables
   Up=Up_;
   Dn=Dn_;
   Brick=Brick_;
   trend=trend_;

//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Price==Close_) {Hi=Close[bar]; Lo=Hi;}
      else {Hi=High[bar]; Lo=Low[bar];}

      vlt=MathMax(K*IndArray[bar],sens);

      if(Hi>Up+Brick)
        {
         if(Brick) Up+=MathFloor((Hi-Up)/Brick)*Brick;
         Brick=vlt;
         Dn=Up-Brick;
        }

      if(Lo<Dn-Brick)
        {
         if(Brick) Dn-=MathFloor((Dn-Lo)/Brick)*Brick;
         Brick=vlt;
         Up=Dn+Brick;
        }

      UpBuffer[bar]=Up;
      DnBuffer[bar]=Dn;
      UpTrendBuffer[bar]=0.0;
      DnTrendBuffer[bar]=0.0;

      if(UpBuffer[bar+1]<UpBuffer[bar]) trend=+1;
      if(DnBuffer[bar+1]>DnBuffer[bar]) trend=-1;

      if(trend>0) UpTrendBuffer[bar]=DnBuffer[bar]-Brick;
      if(trend<0) DnTrendBuffer[bar]=UpBuffer[bar]+Brick;

      //---- memorize values of the variables before the multiple running at the current bar
      if(bar)
        {
         Up_=Up;
         Dn_=Dn;
         Brick_=Brick;
         trend_=trend;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

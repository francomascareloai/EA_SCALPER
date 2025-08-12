//+------------------------------------------------------------------+ 
//|                                                ZerolagStochs.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Parameters of indicator drawing   |
//+-----------------------------------+
//---- drawing of the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used as the color of the indicator line
#property indicator_color1 Blue
//---- indicator line is a solid curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying of the indicator label
#property indicator_label1 "FastTrendLine"

//---- drawing of the indicator as a line
#property indicator_type2   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color2 Red
//---- indicator line is a solid curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying of the indicator label
#property indicator_label2 "SlowTrendLine"
//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR     |
//+-----------------------------------+
input int    Slowing=3;
input int    smoothing = 15;
input ENUM_MA_METHOD MA_Method = MODE_SMA;
input ENUM_STO_PRICE Price_field=STO_LOWHIGH;
//Signal_filling
//----
input double Factor1=0.05;
input int    Kperiod1 = 8;
input int    Dperiod1 = 3;
//----
input double Factor2=0.10;
input int    Kperiod2 = 21;
input int    Dperiod2 = 5;
//----
input double Factor3=0.16;
input int    Kperiod3 = 34;
input int    Dperiod3 = 8;
//----
input double Factor4=0.26;
input int    Kperiod4 = 55;
input int    Dperiod4 = 13;
//----
input double Factor5=0.43;
input int    Kperiod5 = 89;
input int    Dperiod5 = 21;
//+-----------------------------------+

//---- Declaration of the integer variables for the start of data calculation
int StartBar;
//---- Declaration of variables with a floating point
double smoothConst;
//---- indicator buffers
double FastBuffer[];
double SlowBuffer[];
//----Declaration of variables for storing indicators handles
int STO1_Handle,STO2_Handle,STO3_Handle,STO4_Handle,STO5_Handle;
//+------------------------------------------------------------------+    
//| ZerolagStochs indicator initialization function                  | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of constants
   smoothConst=(smoothing-1.0)/smoothing;
//---- 
   int PeriodBuffer[5];
//---- Calculation of an initial bar
   PeriodBuffer[0] = Kperiod1 + Dperiod1;
   PeriodBuffer[1] = Kperiod2 + Dperiod2;
   PeriodBuffer[2] = Kperiod3 + Dperiod3;
   PeriodBuffer[3] = Kperiod4 + Dperiod4;
   PeriodBuffer[4] = Kperiod5 + Dperiod5;
//----
   StartBar=PeriodBuffer[ArrayMaximum(PeriodBuffer,0,WHOLE_ARRAY)]+1;

//---- getting handle of the iStochastic1 indicator
   STO1_Handle=iStochastic(NULL,0,Kperiod1,Dperiod1,Slowing,MA_Method,Price_field);
   if(STO1_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic1 indicator");
//---- getting handle of the iStochastic2 indicator
   STO2_Handle=iStochastic(NULL,0,Kperiod2,Dperiod2,Slowing,MA_Method,Price_field);
   if(STO2_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic2 indicator");
//---- getting handle of the iStochastic3 indicator
   STO3_Handle=iStochastic(NULL,0,Kperiod3,Dperiod3,Slowing,MA_Method,Price_field);
   if(STO3_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic3 indicator");
//---- getting handle of the iStochastic4 indicator
   STO4_Handle=iStochastic(NULL,0,Kperiod4,Dperiod4,Slowing,MA_Method,Price_field);
   if(STO4_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic4 indicator");
//----  getting handle of the iStochastic5 indicator
   STO5_Handle=iStochastic(NULL,0,Kperiod5,Dperiod5,Slowing,MA_Method,Price_field);
   if(STO5_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStochastic5 indicator");

//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(0,FastBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar);
//--- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"FastTrendLine");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(FastBuffer,true);

//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(1,SlowBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBar);
//--- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"SlowTrendLine");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SlowBuffer,true);

//---- initializations of variable for indicator short name
   string shortname="ZerolagStochs";
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| ZerolagStochs iteration function                                 | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(STO1_Handle)<rates_total
      || BarsCalculated(STO2_Handle)<rates_total
      || BarsCalculated(STO3_Handle)<rates_total
      || BarsCalculated(STO4_Handle)<rates_total
      || BarsCalculated(STO5_Handle)<rates_total
      || rates_total<StartBar)
      return(0);

//---- Declaration of variables with a floating point  
   double Sto1,Sto2,Sto3,Sto4,Sto5,FastTrend,SlowTrend;
   double Stoch1[],Stoch2[],Stoch3[],Stoch4[],Stoch5[];

//---- Declaration of integer variables
   int limit,to_copy,bar;

//---- calculation of the 'limit' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-StartBar-2; // starting number for calculation of all bars
      to_copy=rates_total; // calculated number of all bars
     }
   else // starting number for calculation of new bars
     {
      limit=rates_total-prev_calculated; // starting number for calculation of only new bars
      to_copy=rates_total-prev_calculated+1;
     }

//---- indexing elements in arrays, as in timeseries  
   ArraySetAsSeries(Stoch1,true);
   ArraySetAsSeries(Stoch2,true);
   ArraySetAsSeries(Stoch3,true);
   ArraySetAsSeries(Stoch4,true);
   ArraySetAsSeries(Stoch5,true);
   
//--- copy newly appeared data in the arrays
   if(CopyBuffer(STO1_Handle,0,0,to_copy,Stoch1)<=0) return(0);
   if(CopyBuffer(STO2_Handle,0,0,to_copy,Stoch2)<=0) return(0);
   if(CopyBuffer(STO3_Handle,0,0,to_copy,Stoch3)<=0) return(0);
   if(CopyBuffer(STO4_Handle,0,0,to_copy,Stoch4)<=0) return(0);
   if(CopyBuffer(STO5_Handle,0,0,to_copy,Stoch5)<=0) return(0);

//--- calculations of the necessary amount of data to be copied
//---- the limit starting number for loop of bars recalculation
//---- and variables start initialization
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      Sto1 = Factor1 * Stoch1[limit+1];
      Sto2 = Factor2 * Stoch2[limit+1];
      Sto3 = Factor2 * Stoch3[limit+1];
      Sto4 = Factor4 * Stoch4[limit+1];
      Sto5 = Factor5 * Stoch5[limit+1];

      FastTrend = Sto1 + Sto2 + Sto3 + Sto4 + Sto5;
      FastBuffer[limit+1]=FastTrend;
      SlowBuffer[limit+1] = FastTrend / smoothing;
     }

//---- main loop of calculation of the indicator
   for(bar=limit; bar>=0; bar--)
     {
      Sto1 = Factor1 * Stoch1[bar];
      Sto2 = Factor2 * Stoch2[bar];
      Sto3 = Factor2 * Stoch3[bar];
      Sto4 = Factor4 * Stoch4[bar];
      Sto5 = Factor5 * Stoch5[bar];

      FastTrend = Sto1 + Sto2 + Sto3 + Sto4 + Sto5;
      SlowTrend = FastTrend / smoothing + SlowBuffer[bar + 1] * smoothConst;

      SlowBuffer[bar]=SlowTrend;
      FastBuffer[bar]=FastTrend;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
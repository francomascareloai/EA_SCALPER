//+------------------------------------------------------------------+
//|                                             Indicator: spike.mq5 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "https://www.eabuilder.com"
#property version   "1.00"
#property description ""

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

#property indicator_type1 DRAW_ARROW
#property indicator_width1 5
#property indicator_color1 0x0000FF
#property indicator_label1 "SELL"

//--- indicator buffers
double Buffer1[];

input int Shift = -2;
double myPoint; //initialized in OnInit
int Fractals_handle;
double Fractals_Lower[];
double Fractals_Upper[];
double High[];
int ATR_handle;
double ATR[];

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | spike @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 242);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   Fractals_handle = iFractals(NULL, PERIOD_CURRENT);
   if(Fractals_handle < 0)
     {
      Print("The creation of iFractals has failed: Fractals_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   ATR_handle = iATR(NULL, PERIOD_CURRENT, 14);
   if(ATR_handle < 0)
     {
      Print("The creation of iATR has failed: ATR_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
     }
   else
      limit++;
   
   if(BarsCalculated(Fractals_handle) <= 0) 
      return(0);
   if(CopyBuffer(Fractals_handle, LOWER_LINE, 0, rates_total, Fractals_Lower) <= 0) return(rates_total);
   ArraySetAsSeries(Fractals_Lower, true);
   if(BarsCalculated(Fractals_handle) <= 0) 
      return(0);
   if(CopyBuffer(Fractals_handle, UPPER_LINE, 0, rates_total, Fractals_Upper) <= 0) return(rates_total);
   ArraySetAsSeries(Fractals_Upper, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0) return(rates_total);
   ArraySetAsSeries(High, true);
   if(BarsCalculated(ATR_handle) <= 0) 
      return(0);
   if(CopyBuffer(ATR_handle, 0, 0, rates_total, ATR) <= 0) return(rates_total);
   ArraySetAsSeries(ATR, true);
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(Fractals_Lower[i] > Fractals_Upper[Shift+i] //Fractals > Fractals
      )
        {
         Buffer1[i] = High[i] + ATR[i]; //Set indicator value at Candlestick High + Average True Range
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ReversalFractals.mq4
//| Copyright © Pointzero-indicator.com
//+------------------------------------------------------------------+
#property copyright "Copyright © Pointzero-indicator.com"
#property link      "http://www.pointzero-indicator.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue                
#property indicator_color2 Red                 
#define IName              "ReversalFractals"

//-------------------------------
// Input parameters
//-------------------------------
extern bool CalculateOnBarClose    = false;

//-------------------------------
// Buffers
//-------------------------------
double ExtMapBuffer1[];                         
double ExtMapBuffer2[];                         

//-------------------------------
// Internal variables
//-------------------------------

double last_signal = 0;
double last_action = OP_BUY;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    // ZigZag signals
    SetIndexStyle(0, DRAW_ARROW, STYLE_DOT, 1);
    SetIndexArrow(0, 233);
    SetIndexBuffer(0, ExtMapBuffer1);
    SetIndexStyle(1, DRAW_ARROW, STYLE_DOT, 1);
    SetIndexArrow(1, 234);
    SetIndexBuffer(1, ExtMapBuffer2);
   
    // Data window
    IndicatorShortName("Reversal Fractals");
    SetIndexLabel(0, "Bullish reversal");
    SetIndexLabel(1, "Bearish reversal"); 
    
    // Copyright
    Comment("Copyright © http://www.pointzero-indicator.com");
    return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
    return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    // Start, limit, etc..
    int start = 0;
    int limit;
    int counted_bars = IndicatorCounted();

    // nothing else to do?
    if(counted_bars < 0) 
        return(-1);

    // do not check repeated bars
    limit = Bars - 1 - counted_bars;
    
    // Check if ignore bar 0
    if(CalculateOnBarClose == true) start = 1;
    
    // Check the signal foreach bar from past to present
    for(int i = limit; i >= start; i--)
    {
        // Grab all fractals
        double upper_fractal_5b = upper_fractal_5b(i, true);
        double upper_fractal_7b = upper_fractal_7b(i, true);
        double lower_fractal_5b = lower_fractal_5b(i, true);
        double lower_fractal_7b = lower_fractal_7b(i, true);
            
        // Long 5bar reversal
        if(lower_fractal_5b != 0 && lower_fractal_5b != last_signal && last_action == OP_SELL)
        {
            ExtMapBuffer1[i+2] = lower_fractal_5b;
            last_signal = lower_fractal_5b;
            last_action = OP_BUY;
        } else 
        
        // Long 7bar reversal
        if(lower_fractal_7b != 0&& lower_fractal_7b != last_signal && last_action == OP_SELL)
        {
            ExtMapBuffer1[i+3] = lower_fractal_7b;
            last_signal = lower_fractal_7b;
            last_action = OP_BUY;
        } else 
         
        // Short 5bar reversal
        if(upper_fractal_5b != 0 && upper_fractal_5b != last_signal && last_action == OP_BUY)
        {
            ExtMapBuffer2[i+2] = upper_fractal_5b;
            last_signal = upper_fractal_5b;
            last_action = OP_SELL;
        } else 
        
        // Short 7bar reversal
        if(upper_fractal_7b != 0&& upper_fractal_7b != last_signal && last_action == OP_BUY)
        {
            ExtMapBuffer2[i+3] = upper_fractal_7b;
            last_signal = upper_fractal_7b;
            last_action = OP_SELL;
        }
        // Is in only a slow zigzag signal?
        // ExtMapBuffer2[i+2] = fr_t;
    
    }
    return(0);
}

//+------------------------------------------------------------------+
//| Custom code ahead
//+------------------------------------------------------------------+

/**
* Returns fractal resistance
* @param int shift
*/
double upper_fractal_7b(int shift = 1, bool bk = false)
{
   double middle = iHigh(Symbol(), 0, shift + 3);
   double v1 = iHigh(Symbol(), 0, shift);
   double v2 = iHigh(Symbol(), 0, shift+1);
   double v3 = iHigh(Symbol(), 0, shift+2);
   double v5 = iHigh(Symbol(), 0, shift + 4);
   double v6 = iHigh(Symbol(), 0, shift + 5);
   double v7 = iHigh(Symbol(), 0, shift + 6);
   double v1_c = iLow(Symbol(), 0, shift);
   double v7_c = iLow(Symbol(), 0, shift + 5);
   if((middle > v1 && 
      middle > v2 &&
      middle > v3 &&
      middle > v5 &&
      middle > v6 &&
      middle > v7) && (bk == false || v1_c < v7_c))
   {
      return(middle);
   } else {
      return(0);
   }
}

/**
* Returns fractal support and stores wether it has changed or not
* @param int shift
*/
double lower_fractal_7b(int shift = 1, bool bk = false)
{
   double middle = iLow(Symbol(), 0, shift + 3);
   double v1 = iLow(Symbol(), 0, shift);
   double v2 = iLow(Symbol(), 0, shift+1);
   double v3 = iLow(Symbol(), 0, shift+2);
   double v5 = iLow(Symbol(), 0, shift + 4);
   double v6 = iLow(Symbol(), 0, shift + 5);
   double v7 = iLow(Symbol(), 0, shift + 6);
   double v1_c = iHigh(Symbol(), 0, shift);
   double v7_c = iHigh(Symbol(), 0, shift + 5);
   if((middle < v1 && 
      middle < v2 &&
      middle < v3 &&
      middle < v5 &&
      middle < v6 &&
      middle < v7) && (bk == false || v1_c > v7_c))
   {
      return(middle);
   } else {
      return(0);
   }
}


/**
* Returns fractal resistance
* @param int shift
*/
double upper_fractal_5b(int shift = 1, bool bk = false)
{
   double middle = iHigh(Symbol(), 0, shift + 2);
   double v1 = iHigh(Symbol(), 0, shift);
   double v2 = iHigh(Symbol(), 0, shift+1);
   double v3 = iHigh(Symbol(), 0, shift + 3);
   double v4 = iHigh(Symbol(), 0, shift + 4);
   double v1_c = iLow(Symbol(), 0, shift);
   double v4_c = iLow(Symbol(), 0, shift + 3);
   if((middle > v1 && middle > v2 && middle > v3 && middle > v4) && (bk == false || v1_c < v4_c))
   {
      return(middle);
   } else {
      return(0);
   }
}

/**
* Returns fractal support and stores wether it has changed or not
* @param int shift
*/
double lower_fractal_5b(int shift = 1, bool bk = false)
{
   double middle = iLow(Symbol(), 0, shift + 2);
   double v1 = iLow(Symbol(), 0, shift);
   double v2 = iLow(Symbol(), 0, shift+1);
   double v3 = iLow(Symbol(), 0, shift + 3);
   double v4 = iLow(Symbol(), 0, shift + 4);
   double v1_c = iHigh(Symbol(), 0, shift);
   double v4_c = iHigh(Symbol(), 0, shift + 3);
   if((middle < v1 && middle < v2 && middle < v3 && middle < v4)  && (bk == false || v1_c > v4_c))
   {
      return(middle);
   } else {
      return(0);
   }
}
//+------------------------------------------------------------------+


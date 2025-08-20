//+------------------------------------------------------------------+
//| ASCTrend1i.mq4 
//| Ramdass - Conversion only
//| Updates:
//|  2013-04-15, v1.1, X
//|    - Bug fix. Check array bounds in loops
//|    - Bug fix. Set correct nr of counted bars on first run
//|  2012-10-23, X, Performance enhancements. About 500x improvement.
//|    - Removed redundant code and variables
//|    - Cleaned up and modified code for improved performance
//|    - Update only the new bars instead of the full buffer.
//|    - Commented code
//|    - Option to use full buffer size.
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Magenta
#property indicator_color2 Yellow
#property  indicator_width1  1 
#property  indicator_width2  1

#define VERSION "1.1"

#define RANGE_FACTOR 4.6
#define ALT_PERIOD 4
#define HIGH_LEVEL 67
#define LOW_LEVEL 33

//---- input parameters
extern int Risk=6;       // Risk level. WPR_Period=3+Risk*2 or WPR_Period=ALT_PERIOD for a large move 
extern int BarCount=0;   // 0 for full chart buffer

//---- buffers
double dn_sig[];
double up_sig[];
double signal[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //Init buffers
  IndicatorBuffers(4);
  SetIndexStyle(0,DRAW_ARROW);
  SetIndexArrow(0,234); 
  SetIndexStyle(1,DRAW_ARROW);
  SetIndexArrow(1,233); 
  SetIndexStyle(2,DRAW_NONE);
  
  SetIndexBuffer(0,dn_sig);
  SetIndexBuffer(1,up_sig);
  SetIndexBuffer(2,signal);
   
  SetIndexLabel(0, "Down");
  SetIndexLabel(1, "Up");
  SetIndexLabel(2, "Signal");

  SetIndexDrawBegin(0,3+Risk*2+1); 
  SetIndexDrawBegin(1,3+Risk*2+1);
   
  // Set max bars to draw
  if (BarCount<1 || BarCount>Bars) 
    BarCount=Bars-12;

  return(0);
}
  
  
//+------------------------------------------------------------------+
//| ASCTrend1sig                                                     |
//+------------------------------------------------------------------+
int start() {
  int i,shift,counted_bars, min_bars, wpr_period;
  double wpr_value, avg_range, high_level,low_level;
  
  // Set levels 
  high_level=HIGH_LEVEL+Risk;
  low_level=LOW_LEVEL-Risk;
   
  // Check for enough bars
  min_bars=3+Risk*2+1;
  if(Bars<=min_bars) 
    return(0);
    
  // Get new bars
  counted_bars=IndicatorCounted();
  if(counted_bars<0) 
    return (-1); 
  if(counted_bars>0) 
    counted_bars--;
  shift=Bars-counted_bars;
  if (BarCount>0 && shift>BarCount)
    shift=BarCount;
  if (shift>Bars-min_bars)
    shift=Bars-min_bars;  
     
  while(shift>=0) { 
    // Calc Avg range for 10 bars
    i=shift;
    avg_range=0.0;
    for (i=shift; i<shift+10; i++) {
      if (i>=Bars) break;
      avg_range=avg_range+MathAbs(High[i]-Low[i]);
    }
    avg_range=avg_range/10.0;
 
    // Set period for WPR calculation.
    wpr_period=3+Risk*2;
    
    // Use alternative period if there has been a large move.
    i=shift;
    while (i<shift+6) {
      if (i>=Bars-3) break;
      if (MathAbs(Close[i+3]-Close[i])>=avg_range*RANGE_FACTOR) {
        wpr_period=ALT_PERIOD;
        break;
      }
      i++;
    }      
	 
    // Calc WPR 
    wpr_value=100-MathAbs(iWPR(NULL,0,wpr_period,shift)); 
    
    // Set current signal
    if (wpr_value>=high_level) 
      signal[shift] = 1;
    else if (wpr_value<=low_level) 
      signal[shift] = -1;  
    else if (wpr_value>low_level && signal[shift+1]==1) 
      signal[shift] = 1;
    else if (wpr_value<high_level && signal[shift+1]==-1) 
      signal[shift] = -1;      
    else
      signal[shift]=0;
      
    // Draw arrows
    dn_sig[shift]=0;
    up_sig[shift]=0;
    if (signal[shift]==-1 && signal[shift+1]==1)
      dn_sig[shift]=High[shift]+avg_range*0.5;
    if (signal[shift]==1 && signal[shift+1]==-1)
      up_sig[shift]=Low[shift]-avg_range*0.5;
    
    shift--;
  }

  return(0);
}
//+------------------------------------------------------------------+



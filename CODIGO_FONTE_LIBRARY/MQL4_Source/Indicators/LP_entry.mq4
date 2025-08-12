//+------------------------------------------------------------------+
//| LP_entry 
//+------------------------------------------------------------------+
#property copyright "Copyright 2022 LP"
#property indicator_chart_window
#property strict
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Aqua
#property  indicator_width1  0 
#property  indicator_width2  0

#define VERSION "1.0"

#define RANGE_FACTOR 4.6
#define ALT_PERIOD 4
#define HIGH_LEVEL 67
#define LOW_LEVEL 33

int Risk, BarCount;
//---- buffers
double dn_sig[];
double up_sig[];
double signal[];

//+------------------------------------------------------------------+
//| Initialization function                         |
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
  BarCount = 0;
  Risk = -1;  

  // Set max bars to draw
  if (BarCount<1 || BarCount>Bars) 
    BarCount=Bars-12;

  return(0);
}
  
  
//+------------------------------------------------------------------+
//| RSI+WPR_signal                                               |
//+------------------------------------------------------------------+
int start() {
  int i,shift,counted_bars, min_bars, wpr_period;
  double wpr_value, avg_range, high_level,low_level,filter;
  
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
	 
    // Calc WPR and RSI
    wpr_value=100-MathAbs(iWPR(NULL,0,wpr_period,shift)); 
    filter = (iWPR(NULL,0,4,shift)+100 + iRSI(Symbol(),0,2,0,shift))/2;
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
// if (signal[shift]==-1 && signal[shift+1]==1 && filter < 50)
    if (filter < 50)
      dn_sig[shift]=High[shift]+avg_range*0.2;
//    if (signal[shift]==1 && signal[shift+1]==-1 && filter > 50)
      if (filter > 50)
      up_sig[shift]=Low[shift]-avg_range*0.2;
    
    shift--;
//----------------------------------------------------------
// Draw Power and OBOS
//----------------------------------------------------------
   double wprlevel1=iWPR(NULL,0,4,0)+100;
   double rsilevel1=iRSI(Symbol(),0,2,0,0);
   double wprlevel2=iWPR(NULL,0,14,0)+100;
   double rsilevel2=iRSI(Symbol(),0,2,0,0);
   
   double UPDN = (wprlevel1 + rsilevel1)/2;
   double OBOS = (wprlevel2 + rsilevel2)/2;
   double D = (UPDN - 50)*2;
   
   //------------------------------------------------------- UP/DN
   ObjectCreate("textUPDN",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textUPDN",OBJPROP_CORNER,1);
   ObjectSet("textUPDN",OBJPROP_XDISTANCE,5);
   ObjectSet("textUPDN",OBJPROP_YDISTANCE,85);
 
   { ObjectSetText("textUPDN","      ",12,"Times New Roman",clrBlack); }
   if (UPDN > 50)
   { ObjectSetText("textUPDN","Power %",12,"Times New Roman",clrLime); }
   if (UPDN < 50)
   { ObjectSetText("textUPDN","Power %",12,"Times New Roman",clrRed); }
   
// ----------------------------------------------------------- distance
   
   ObjectCreate("textD",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textD",OBJPROP_CORNER,1);
   ObjectSet("textD",OBJPROP_XDISTANCE,5);
   ObjectSet("textD",OBJPROP_YDISTANCE,110);
 
   if (D > 0)
   { ObjectSetText("textD"," "+DoubleToStr(D,0),20,"Times New Roman",clrLime); }
   if (D < 0)
   { ObjectSetText("textD"," "+DoubleToStr(D,0),20,"Times New Roman",clrRed); }

//----------------------------------------------------------- OBOS

   ObjectCreate("textOBOS",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textOBOS",OBJPROP_CORNER,1);
   ObjectSet("textOBOS",OBJPROP_XDISTANCE,5);
   ObjectSet("textOBOS",OBJPROP_YDISTANCE,65);
 
   { ObjectSetText("textOBOS","       ",12,"Times New Roman",clrBlack); }
   if (OBOS > 85)
   { ObjectSetText("textOBOS","PEAK  ",12,"Times New Roman",clrLime); }
   if (OBOS > 95)
   { ObjectSetText("textOBOS","EXTREM",12,"Times New Roman",clrLime); }
   if (OBOS < 15)
   { ObjectSetText("textOBOS","PEAK  ",12,"Times New Roman",clrRed); }
   if (OBOS < 5)
   { ObjectSetText("textOBOS","EXTREM",12,"Times New Roman",clrRed); }
// -----------------------------------------------------------------------


  }

  return(0);
}
//+------------------------------------------------------------------+



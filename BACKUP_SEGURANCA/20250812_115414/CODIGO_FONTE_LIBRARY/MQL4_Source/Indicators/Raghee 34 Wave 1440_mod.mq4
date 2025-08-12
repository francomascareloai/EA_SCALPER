//+------------------------------------------------------------------+
//|                                               Raghee 34 Wave.mq4 |  see http://www.forexfactory.com/showthread.php?p=7569145
//|                                                           .....h |
//|                                                    hayseedfx.com | or google Raghee Horner
//+------------------------------------------------------------------+   
//Modified, 24/jul/2022, by jeanlouie, www.forexfactory.com/jeanlouie
// - color styling as input

#property copyright ".....h"
#property link      "hayseedfx.com"
//----

//---- input parameters 
#property indicator_chart_window
#property indicator_buffers  7

#property indicator_color1 clrRed
#property indicator_color2 clrRed
#property indicator_color3 clrRed
#property indicator_color4 clrRed
#property indicator_color5 clrMagenta
#property indicator_color6 clrMagenta
#property indicator_color7 clrMagenta

extern bool   showlabels = false;
extern bool   alerts     = false;

       bool   upalert    = false;
       bool   dnalert    = false;
       int    zoom;
       int    bars;
       int    width;
       double above[];
       double below[];
       double high[];
       double low[];
       double close[];
       double smootha[];
       double smoothb[];

       


//+-------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                  |                                                        
//+-------------------------------------------------------------------------------------------+      
int init()
  {
 
  
  zoom = ChartScaleGet();
                                
  if(zoom == 0) {width = 1;}           
  if(zoom == 1) {width = 2;}      
  if(zoom == 2) {width = 3;}
  if(zoom == 3) {width = 5;}
  if(zoom == 4) {width = 9;}
  if(zoom == 5) {width = 17;}   
       
              
  SetIndexBuffer(0,above);
  SetIndexStyle(0,DRAW_HISTOGRAM,0,width);//,clrRed);   
  SetIndexEmptyValue(0,0);
  
  SetIndexBuffer(1,below);
  SetIndexStyle(1,DRAW_HISTOGRAM,0,width);//,clrRed);
  SetIndexEmptyValue(1,0);   
 
  SetIndexBuffer(2,smootha);
  SetIndexStyle(2,DRAW_LINE,0,width);//,clrRed);
  SetIndexEmptyValue(2,0);  
      
  SetIndexBuffer(3,smoothb); 
  SetIndexStyle(3,DRAW_LINE,0,width);//,clrRed);
  SetIndexEmptyValue(3,0);
  
  SetIndexBuffer(4,close); 
  SetIndexStyle(4,DRAW_LINE,0,1);//,clrMagenta);
  SetIndexEmptyValue(4,0); 
    
  SetIndexBuffer(5,high);
  SetIndexStyle(5,DRAW_LINE,0,2);//,clrMagenta); 
  SetIndexEmptyValue(5,0);
   
  SetIndexBuffer(6,low);
  SetIndexStyle(6,DRAW_LINE,0,2);//,clrMagenta);
  SetIndexEmptyValue(6,0);  
       

          
  IndicatorShortName ("Raghee 34 Wave 1440");
                                                                                             
  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                |                                                        
//+-------------------------------------------------------------------------------------------+      
int deinit()
  {

              
  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                       |                                                        
//+-------------------------------------------------------------------------------------------+     
int start()
  {
   
  if(bars != Bars) {upalert = false; dnalert = false;}// bars = Bars;}
  
  int i,counted_bars,limit;
  counted_bars = IndicatorCounted();
  if(counted_bars < 0)  return(-1);     
  //last counted bar will be recounted
  if(counted_bars > 0) counted_bars--;    
  limit = Bars - counted_bars;
  
  for(i = limit - 1; i >= 0; i--)   
    {  
    
      int bar10080        = iBarShift(NULL,10080,Time[i]);
      int bar1440         = iBarShift(NULL,1440,Time[i]); 
      int bar240          = iBarShift(NULL,240,Time[i]);
      int bar60           = iBarShift(NULL,60,Time[i]);    
    
      
    above[i]   = iMA(Symbol(),1440,34,0,1,PRICE_HIGH,bar1440);   
    below[i]   = iMA(Symbol(),1440,34,0,1,PRICE_LOW,bar1440);  
                      
    high[i]    = iMA(Symbol(),1440,34,0,1,PRICE_HIGH,bar1440);                           
    low[i]     = iMA(Symbol(),1440,34,0,1,PRICE_LOW,bar1440);   
     
    close[i]   = iMA(Symbol(),1440,34,0,1,PRICE_CLOSE,bar1440);     
    smootha[i] = iMA(Symbol(),1440,34,0,1,PRICE_HIGH,bar1440);                           
    smoothb[i] = iMA(Symbol(),1440,34,0,1,PRICE_LOW,bar1440);   
     
    }
 
 

                                                                                                          
  return(0);
  }

//-----
//-----

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)    // https://www.mql5.com/en/docs/standardlibrary/expertclasses/expertbaseclasses/cexpert/cexpertonchartevent                                                
  {
  zoom = ChartScaleGet();
  init();  
  }

//-----
//-----

int ChartScaleGet()                                                                           // http://docs.mql4.com/constants/chartconstants/charts_samples
  {
  long result = -1;
  ChartGetInteger(0,CHART_SCALE,0,result);
  return((int)result);
  }
    
//-----
//-----



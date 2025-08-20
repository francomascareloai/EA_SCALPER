//+------------------------------------------------------------------+
//|                                  Custom Aroon Oscillator_v1.mq4  |
//|                                                       rafcamara  | 
//|                                         Has corrected - Ramdass  |
//+------------------------------------------------------------------+
#property  copyright "rafcamara"
#property  link      "rafcamara@yahoo.com"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  DodgerBlue
#property  indicator_color2  Red
#property  indicator_color3  Snow
#property  indicator_color4  Green
//---- indicator parameters
extern int AroonPeriod = 10;
extern int Filter = 50;
extern int CountBars = 300;
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
double     ind_buffer3[];
double     HighBarBuffer[];
double     LowBarBuffer[];
double     ArOscBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
    //---- additional buffers are used for counting.
    IndicatorBuffers(6);
    SetIndexBuffer(4, HighBarBuffer);
    SetIndexBuffer(5, LowBarBuffer);
    SetIndexBuffer(3, ArOscBuffer);
    SetIndexBuffer(0, ind_buffer1);
    SetIndexBuffer(1, ind_buffer2);
    SetIndexBuffer(2, ind_buffer3);
    //---- drawing settings
    SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 1);
    SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 1);
    SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 1);
    SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1);
//----
    IndicatorDigits(0);
    //-- indicator buffers mapping
    if(!SetIndexBuffer(0, ind_buffer1) && !SetIndexBuffer(1, ind_buffer2)
    && !SetIndexBuffer(2, ind_buffer3))
        Print("cannot set indicator buffers!");
    //---- name for DataWindow and indicator subwindow label
    IndicatorShortName("AroonOsc_v1 (" + AroonPeriod + ", " + Filter + ")");
    //---- initialization done
    return(0);
  }
//+------------------------------------------------------------------+
//| Aroon Oscilator                                                  |
//+------------------------------------------------------------------+
int start()
  {
    if(CountBars >= Bars) 
        CountBars=Bars;
    SetIndexDrawBegin(0, Bars - CountBars + AroonPeriod + 1);
    SetIndexDrawBegin(1, Bars - CountBars + AroonPeriod + 1);
    SetIndexDrawBegin(2, Bars - CountBars + AroonPeriod + 1);
    SetIndexDrawBegin(3, Bars - CountBars + AroonPeriod + 1);
    double   ArOsc, HighBar = 0, LowBar = 0;
    int      ArPer; 
    int      limit, i;
    // bool     up,dn;
    int counted_bars = IndicatorCounted();
    //----
    ArPer = AroonPeriod;
    //---- check for possible errors
    if(counted_bars < 0) 
        return(-1);
    //---- initial zero
    if(counted_bars < 1)
      {
        for(i = 1; i <= ArPer; i++) 
            HighBarBuffer[CountBars-i] = 0.0;
        for(i = 1; i <= ArPer; i++) 
            LowBarBuffer[CountBars-i] = 0.0;
        for(i = 1; i <= ArPer; i++) 
            ArOscBuffer[CountBars-i] = 0.0;
        for(i = 1; i <= ArPer; i++) 
            ind_buffer1[CountBars-i] = 0.0;
        for(i = 1; i <= ArPer; i++) 
            ind_buffer2[CountBars-i] = 0.0;
        for(i = 1; i <= ArPer; i++) 
            ind_buffer3[CountBars-i] = 0.0;
      } 
    //---- last counted bar will be recounted
    //if(counted_bars>0) counted_bars--;
    limit = CountBars - AroonPeriod;
    //----Calculation---------------------------
    for(i = 0; i < limit; i++)
      {
  	     HighBarBuffer[i] = Highest(NULL, 0, MODE_HIGH, ArPer, i); 	//Periods from HH  	   
  	     LowBarBuffer[i] = Lowest(NULL, 0, MODE_LOW, ArPer, i);		//Periods from LL
  	     ArOscBuffer[i] = 100*(LowBarBuffer[i] - HighBarBuffer[i]) / ArPer;		//Short formulation
      }
    //---- dispatch values between 2 buffers
    for(i = limit - 1; i >= 0; i--)
      {
        ArOsc=ArOscBuffer[i];
        if(ArOsc > Filter)
          {
            ind_buffer1[i] = ArOsc;
            ind_buffer2[i] = 0.0;
            ind_buffer3[i] = 0.0;      
          }       
        if(ArOsc < -Filter)
          {
            ind_buffer1[i] = 0.0;
            ind_buffer2[i] = ArOsc;
            ind_buffer3[i] = 0.0;
          }
        if(ArOsc <= Filter && ArOsc >= -Filter)
          {
            ind_buffer1[i] = 0.0;
            ind_buffer2[i] = 0.0;
            ind_buffer3[i] = ArOsc;
          }  
      }
    //---- done
    return(0);
  }
//+------------------------------------------------------------------+
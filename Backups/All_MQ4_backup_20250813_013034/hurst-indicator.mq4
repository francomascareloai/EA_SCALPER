//+------------------------------------------------------------------+
//|                                              Hurst Indicator.mq4 |
//|                                   Copyright © 2009, Serega Lykov |
//|                                       http://mtexperts.narod.ru/ |
//+------------------------------------------------------------------+

#property copyright ""
#property link      ""

/*
{coded for WDGIGI, 03 June 2008}
{copyright 2008, Scott Bunny}

D:=Input("Day of month",1,31,1);
M:=Input("Month",1,12,1);
Y:=Input("Year",1900,2100,2008);
WA2:=Input("wave2",0,10,3);
wavelength:=Input("Wavelength (bars)",1,9999,243);

{bars}
start:=Cum((DayOfMonth()>=D AND Month()=M AND Year()=Y) OR(Month()>M AND Year()=Y) OR Year()>Y)=1;
start:=LastValue(ValueWhen(1,start,Cum(1)));

{x axis values}
x:=360/wavelength * (Cum(1)-start);

{sine waves}
phase:=-90;
w1:=Sin(8*x+phase);
w2:=2*Sin(4*x+phase);
w3:=wa2*Sin(2*x+phase);
w4:=4*Sin(x+phase);

{hurst cycle}

CYCLE:= (W1+W2+W3+W4);
Grc:=(Highest(cycle)-Lowest(cycle))/486;
TR:=Input("trend",-1,1,1);
STR:=1;
HurstCycle:=Cycle+((cycle+(Grc*tr*str)+Ref(cycle+(Grc*tr*str),-1)));

{plot}
w1;w2;w3;w4;CYCLE;
*/

//---- property of indicator ----------------------------------------+
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Gold
#property indicator_color3 Blue
#property indicator_color4 Green
#property indicator_color5 Brown
#property indicator_color6 White

//---- external parameters ------------------------------------------+
extern datetime StartTime      = D'2008.01.01 00:00:00'; // D:=Input("Day of month",1,31,1); M:=Input("Month",1,12,1); Y:=Input("Year",1900,2100,2008);
extern double   wave2          = 3;     // WA2:=Input("wave2",0,10,3);
extern double   wave_length    = 243;   // wavelength:=Input("Wavelength (bars)",1,9999,243);
extern double   trend          = 1;     // TR:=Input("trend",-1,1,1);

//---- internal parameters ------------------------------------------+
static double   phase          = -90;   // phase:=-90;
static double   str            = 1;     // STR:=1;
static double   koef           = 486;   // Grc:=(Highest(cycle)-Lowest(cycle))/486;
static int      DigitsAfterDot = 4;     // number of digits after dot (maximum 8)

//---- buffers ------------------------------------------------------+
static double HurstCycle[];
static double Cycle[];
static double w1[];
static double w2[];
static double w3[];
static double w4[];
static double buffer1[];

//---- global variables ---------------------------------------------+
static double pi = 3.1415926535;
static double pi2;
static double step;
static double rad_phase;

//-------------------------------------------------------------------+
//---- initialization of indicator ----------------------------------+
//-------------------------------------------------------------------+
int init()
  {
   //---- set a "short" name of the indicator -----------------------+
   IndicatorShortName("Hurst");
   //---- the 1 additional buffer -----------------------------------+
   IndicatorBuffers(7);
   //---- set a accuracy of values of the indicator -----------------+
   if(DigitsAfterDot > 8) DigitsAfterDot = 8;
   IndicatorDigits(DigitsAfterDot);
   //---- set a style for line --------------------------------------+
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,1);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT,1);
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT,1);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1);
   //---- set a arrays for line -------------------------------------+
   SetIndexBuffer(0,Cycle);
   SetIndexBuffer(1,w1);
   SetIndexBuffer(2,w2);
   SetIndexBuffer(3,w3);
   SetIndexBuffer(4,w4);
   SetIndexBuffer(5,HurstCycle);
   SetIndexBuffer(6,buffer1);
   //---- set a names for lines -------------------------------------+
   SetIndexLabel(0,"Cycle");
   SetIndexLabel(1,"w1");
   SetIndexLabel(2,"w2");
   SetIndexLabel(3,"w3");
   SetIndexLabel(4,"w4");
   SetIndexLabel(5,"HurstCycle");
   SetIndexLabel(6,NULL);
   //---- initialization values of constants ------------------------+
   pi2 = pi * 2;
   step = pi2 / wave_length;
   rad_phase = (pi2 / 360) * phase;
   //---- finish of initialization ----------------------------------+
   return(0);
  }

//-------------------------------------------------------------------+
//---- deinitialization of indicator --------------------------------+
//-------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }

//-------------------------------------------------------------------+
//---- Hurst --------------------------------------------------------+
//-------------------------------------------------------------------+
int start()
  {
   //---- amount not changed bars after last call of the indicator --+
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   //---- last counted bar will be counted --------------------------+
   if(counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   int start_barshift = iBarShift(NULL,0,StartTime); // start:=LastValue(ValueWhen(1,start,Cum(1)));
   for(int i=limit; i>=0; i--)
     {
      if(i > start_barshift)
        {
         HurstCycle[i] = EMPTY_VALUE;
         Cycle[i]      = EMPTY_VALUE;
         w1[i]         = EMPTY_VALUE;
         w2[i]         = EMPTY_VALUE;
         w3[i]         = EMPTY_VALUE;
         w4[i]         = EMPTY_VALUE;
         buffer1[i]    = EMPTY_VALUE;
        }
      else
        {
         double x = step * (start_barshift - i);        // x:=360/wavelength * (Cum(1)-start);
         w1[i] = MathSin(8 * x + rad_phase);            // w1:=Sin(8*x+phase);
         w2[i] = 2 * MathSin(4 * x + rad_phase);        // w2:=2*Sin(4*x+phase);
         w3[i] = wave2 * MathSin(2 * x + rad_phase);    // w3:=wa2*Sin(2*x+phase);
         w4[i] = 4 * MathSin(x + rad_phase);            // w4:=4*Sin(x+phase);
         Cycle[i] = w1[i] + w2[i] + w3[i] + w4[i];      // CYCLE:= (W1+W2+W3+W4);
         double grc = (GetArrayMaximum(Cycle) - GetArrayMinimum(Cycle))/ koef; // Grc:=(Highest(cycle)-Lowest(cycle))/koef;
         buffer1[i] = Cycle[i] + grc*trend*str;         // cycle+(Grc*tr*str)
         if(buffer1[i - 1] == EMPTY_VALUE) double prev_buffer1 = 0;
         else prev_buffer1 = buffer1[i - 1];
         HurstCycle[i] = Cycle[i] + buffer1[i] + prev_buffer1; // HurstCycle:=Cycle+((cycle+(Grc*tr*str)+Ref(cycle+(Grc*tr*str),-1)));
        }
     }
   //---- finish of iteration ---------------------------------------+
   return(0);
  }

//-------------------------------------------------------------------+
//---- GetArrayMaximum ----------------------------------------------+
//-------------------------------------------------------------------+
double GetArrayMaximum(double& array[])
  {
   double max_value = 0;
   for(int i=0; i>Bars; i++)
     {
      if(array[i] == EMPTY_VALUE) break;
      if(array[i] > max_value) max_value = array[i];
     }
   return(max_value);
  }

//-------------------------------------------------------------------+
//---- GetArrayMinimum ----------------------------------------------+
//-------------------------------------------------------------------+
double GetArrayMinimum(double& array[])
  {
   double min_value = 0;
   for(int i=0; i>Bars; i++)
     {
      if(array[i] == EMPTY_VALUE) break;
      if(array[i] < min_value) min_value = array[i];
     }
   return(min_value);
  }

//-------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                    Volume Divergence Markers.mq4 |
//|                                                   Vitaliy Samara |
//|                          https://www.mql5.com/en/users/samaridze |
//+------------------------------------------------------------------+
#property copyright "Vitaliy Samara"
#property link      "https://www.mql5.com/en/users/samaridze"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
//------
enum mode
  {
   Convergence = 0,
   Divergence  = 1,
  };
//------
input bool     ThisBar        = 0;              //Is current bar counted?
input mode     Mode           = 0;              //Marker display mode
extern int     VolGlobal      = 2;              //Continuous change in volume (in bars)
extern int     SizeGlobal     = 2;              //Continuous change in barsize (in bars)
input color    main=clrRoyalBlue;               //Marker colour
//------
double BufferMarker[];
//------
int OnInit()
  {
   SetIndexBuffer(0,BufferMarker);
//------
   SetIndexStyle(0,DRAW_ARROW,EMPTY,4,main);
//------
   SetIndexArrow(0,119);
//------
   SetIndexEmptyValue(0,0);
//------
   IndicatorShortName("VDM "+VolGlobal+","+SizeGlobal);
//------ Values above 4 are pointless because it never happens on a market
   if(VolGlobal>4) VolGlobal=4;
   if(SizeGlobal>4) SizeGlobal=4;
   return(INIT_SUCCEEDED);
  }
//------
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
//------ Reversing timeseries to make Series[0] the earliest
   ArraySetAsSeries(BufferMarker,false);
   ArraySetAsSeries(High,false);
   ArraySetAsSeries(Low,false);
   ArraySetAsSeries(Open,false);
   ArraySetAsSeries(Close,false);
   ArraySetAsSeries(Volume,false);
//------ Initializing variables 
   int bar;
   int vol,barsize;
   bool dir;
   vol=barsize=dir=0;
//------ Checking for sufficient bars in history
   if(rates_total<MathMax(VolGlobal*2,SizeGlobal*2))
     {
      return (0);
     }
//------ Setting the starting bar to calculate from     
   if(prev_calculated==0)
      bar=MathMax(VolGlobal*2,SizeGlobal*2);
   else
      bar=prev_calculated-1;
//------ Main program cycle for each bar
   while(bar<rates_total-!ThisBar)
     {
      BarSizeDynamics(bar,dir,barsize);
      if(barsize>=SizeGlobal && VolumeDynamics(bar,dir)==true)
         BufferMarker[bar]=Close[bar];
      bar++;
     }
//------
   return(rates_total);
  }
//------ Function that counts continuous increase or decrease of barsize (in bars)
//------ Need to return two values, so variables are passed by reference
void BarSizeDynamics(int bar,bool &dir,int &barsize)
  {
   int i=bar;
   int up=0,down=0;
//------ Counting continuous increase in barsize
   while(MathAbs(Open[i]-Close[i])>MathAbs(Open[i-1]-Close[i-1]))
     {
      up++;
      i--;
     }
//------ Counting continuous decrease in barsize
   i=bar;
   while(MathAbs(Open[i]-Close[i])<MathAbs(Open[i-1]-Close[i-1]))
     {
      down++;
      i--;
     }
//------ Selecting the correct movement and setting the value of direction variable (0 = increase, 1 = decrease)
   barsize=MathMax(up,down);
   if(up==0)
      dir=Mode;
   else
      dir=!Mode;
  }
//------ Function that counts continuous increase or decrease of volume (in bars)
bool VolumeDynamics(int bar,bool dir)
  {
   int i=bar;
   int counter=0;
//------
   if(dir==0)
      while(Volume[i]<Volume[i-1])
        {
         counter++;
         i--;
        }
   else
   while(Volume[i]>Volume[i-1])
     {
      counter++;
      i--;
     }
//------ Both variables (barsize, vol) derived from these functions have to match user input globals         
//------ Returning values as a boolean (to draw a marker or not) because no further calculations are required
   if(counter==VolGlobal)
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+

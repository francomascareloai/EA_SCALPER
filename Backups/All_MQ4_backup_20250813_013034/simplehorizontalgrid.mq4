#property strict
#property indicator_chart_window
#define VERSION "201.003"
#property version VERSION
#property copyright "Ovo © 2009-2016, ver. " VERSION
#property link      "http://ovo.cz/"

#property description "Indicator plots a 2-colour dynamic grid at round number levels."
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum LineType 
  {
   None = 0, //   None     
   Two = 2,  //   500       
   Four = 4,  //  250 500 750  
   Five = 5,  //  200 400 600 800
   Eight = 8, //  125 250 .. 750 875
   Ten=10  //   100 200 .. 800 900  

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum YesNoType 
  {
   TYPE_YES =1, // Yes
   TYPE_NO = 0  // No
  };

YesNoType SHOW_FINE_GRID=TYPE_YES; // Secondary lines count
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum DistanceEnum 
  {
   D_5=5,//  05 - 050 pixels
   D_10 = 10, //  10 - 100 pixels
   D_20 = 20, //  20 - 200 pixels
   D_30 = 30, //  30 - 300 pixels
   D_40 = 40, //  40 - 400 pixels
   D_50 = 50  //  50 - 500 pixels
  };

input DistanceEnum minDistance=D_20; // Lines density
input LineType SEC_LEVELS=Five; // Secondary lines definition
input YesNoType reverseColour=TYPE_NO; // Reverse line colours
input YesNoType DISPLAY_IN_BACKGROUND=TYPE_YES; // Hide price labels

color MAIN_LINE_COLOR;
color FINE_COLOR;
int LINE_STYLE=STYLE_DOT;

#define INDI_PREFIX "SHG_"

double high= 0.0;
double low = 0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int OnInit() 
  {
   if(SEC_LEVELS<Two) SHOW_FINE_GRID=TYPE_NO;
   if(reverseColour==TYPE_YES) 
     {
      FINE_COLOR=(color)ChartGetInteger(ChartID(),CHART_COLOR_VOLUME);
      MAIN_LINE_COLOR=(color)ChartGetInteger(ChartID(),CHART_COLOR_GRID);
     }
   else 
     {
      FINE_COLOR=(color)ChartGetInteger(ChartID(),CHART_COLOR_GRID);
      MAIN_LINE_COLOR=(color)ChartGetInteger(ChartID(),CHART_COLOR_VOLUME);
     }
   draw();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) 
  {
   deleteLines();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,// size of input time series
                const int prev_calculated,  // bars handled in previous call
                const datetime& time[],     // Time
                const double& open[],       // Open
                const double& xhigh[],       // High
                const double& xlow[],        // Low
                const double &close[],// Close
                const long &tickVolume[],// Tick Volume
                const long& volume[],       // Real Volume
                const int& spread[]) 
  {      // Spread
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string &sparam) 
  {  // Parameter of type string events

   if(chartChanged()) 
     {
      draw();
     }
  }
int pixelHeight=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool chartChanged() 
  {
   double newHigh= ChartGetDouble(0,CHART_PRICE_MAX);
   double newLow = ChartGetDouble(0,CHART_PRICE_MIN);
   int newPixelHeight=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);

   if(newHigh!=high || newLow!=low || newPixelHeight!=pixelHeight) 
     {
      high= newHigh;
      low = newLow;
      pixelHeight=newPixelHeight;
      return true;
     }
   return false;
  }

int previousPrecission=-999;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw() 
  {

   if(high==low) 
     {
      return;
     }

   int numberOfLines=pixelHeight/minDistance;
   if(numberOfLines==0) 
     {
      return;
     }
   double minPriceDistance=(high-low)/numberOfLines;
   if(SHOW_FINE_GRID==TYPE_YES) 
     {
      minPriceDistance*=SEC_LEVELS;
     }

   double factor=MathPow(10,MathCeil(MathLog(minPriceDistance)/MathLog(10)));
   int pricePrecision=2 -(int)MathRound(MathLog(factor)/MathLog(10));
   if(previousPrecission!=pricePrecision) 
     {
      deleteLines();
      previousPrecission=pricePrecision;
     }
   double highGridPoint= MathCeil(high/factor) * factor;
   double lowGridPoint = MathFloor(low/factor) * factor;
   double pointStep;
   int maxlines=1000; // to protect the thread
   if(SHOW_FINE_GRID==TYPE_YES) 
     {
      pointStep=factor/(SEC_LEVELS);

      for(double linePoint=lowGridPoint; linePoint<=highGridPoint && maxlines>0; linePoint+=pointStep) 
        {
         if(linePoint<high && linePoint>low) 
           {
            maxlines--;
            double linePrice= linePoint;
            string lineName = INDI_PREFIX+DoubleToStr(linePrice,Digits);
            if(ObjectCreate(lineName,OBJ_HLINE,0,0,linePrice)) 
              {
               ObjectSet(lineName,OBJPROP_COLOR,FINE_COLOR);
               ObjectSet(lineName,OBJPROP_STYLE,LINE_STYLE);
               ObjectSet(lineName,OBJPROP_BACK,TYPE_YES);
               ObjectSetString(0,lineName,OBJPROP_TOOLTIP,DoubleToStr(linePrice,pricePrecision));
               ObjectSetInteger(0,lineName,OBJPROP_SELECTABLE,false);
               ObjectSetInteger(0,lineName,OBJPROP_HIDDEN,true);
              }
           }
        }
     }

   pointStep=factor;

   maxlines=1000; // protecting the thread resources
   for(double linePoint=lowGridPoint; linePoint<=highGridPoint && maxlines>0; linePoint+=pointStep) 
     {
      if(linePoint<high && linePoint>low) 
        {
         maxlines--;
         double linePrice= linePoint;
         string lineName = INDI_PREFIX+DoubleToStr(linePrice,Digits);
         ObjectCreate(lineName,OBJ_HLINE,0,0,linePrice);
         ObjectSet(lineName,OBJPROP_COLOR,MAIN_LINE_COLOR);
         ObjectSet(lineName,OBJPROP_STYLE,LINE_STYLE);
         ObjectSet(lineName,OBJPROP_BACK,DISPLAY_IN_BACKGROUND);
         ObjectSetString(0,lineName,OBJPROP_TOOLTIP,DoubleToStr(linePrice,pricePrecision));
         ObjectSetText(lineName,DoubleToStr(linePrice,pricePrecision));
         ObjectSetInteger(0,lineName,OBJPROP_SELECTABLE,false);
        }
     }
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteLines() 
  {
   int counter=ObjectsTotal()-1;
   for(int i=counter; i>=0; i --) 
     {
      if(StringFind(ObjectName(i),INDI_PREFIX)>=0) ObjectDelete(ObjectName(i));
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                               FX5_FiboSpiral.mq4 |
//|                                                              FX5 |
//|                                                    hazem@uk2.net |
//+------------------------------------------------------------------+
#property copyright "FX5"
#property link      ""//"hazem@uk2.net"
//----
#property indicator_chart_window
//----
#define pi 3.14159265
#define phi 1.61803399
#define FX5_Square "FX5_Square"
#define FX5_Spiral "FX5_Spiral:#"
//---- input parameters
extern string note1="What candle do you want to draw the center?";
extern int CandleCenter = 75;
extern double radius = 11.8;
extern double goldenSpiralCycle = 1.5;
extern bool   clockWiseSpiral = true;
extern color  spiralColor1 = clrMagenta;
extern color  spiralColor2 = clrPaleGreen;
double accurity = 0.25;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(VerifyParams() == -1)
       return(-1); 
   CreateSquare();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   DeleteSpiral();
   ObjectDelete(FX5_Square);
   Comment(" ");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//   Comment(" ");
   DeleteSpiral();
   DrawSpiral();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSpiral()
  {
   double squareTime_1 = ObjectGet(FX5_Square, OBJPROP_TIME1);
   double squareTime_2 = ObjectGet(FX5_Square, OBJPROP_TIME2);
   double squarePrice_1 = ObjectGet(FX5_Square, OBJPROP_PRICE1);
//----        
   int squareShift_1 = iBarShift(NULL, 0, squareTime_1, false);
   int squareShift_2 = iBarShift(NULL, 0, squareTime_2, false);
//----  
   double r0 = MathAbs(squareShift_2 - squareShift_1);
   double a = 0;
   double x0 = squareShift_1;
   double y0 = squarePrice_1;
//----   
   double cotAlpha = (1/(2 * goldenSpiralCycle *pi)) * MathLog(phi);
   double x1 = 0;
   double y1 = 0;
   for(int i = 0; i < 500; i++)
     {
       double Theta = a * pi / 4;
       double r = r0 * MathExp(Theta * cotAlpha);
       //----
       if (clockWiseSpiral == false)
          Theta = -Theta;
       //----      
       double x2 = r * MathCos(Theta);
       double y2 = r * MathSin(Theta);
       a += accurity;
       //----     
       string label = FX5_Spiral + i;
       DrawLine(x1, y1, x2, y2, label);
       //----              
       x1 = x2;
       y1 = y2;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(double x1, double y1, double x2, double y2, string label)
  {
   double squareTime_1 = ObjectGet(FX5_Square, OBJPROP_TIME1);
   double squareTime_2 = ObjectGet(FX5_Square, OBJPROP_TIME2);      
   double squarePrice_1 = ObjectGet(FX5_Square, OBJPROP_PRICE1);   
   double squarePrice_2 = ObjectGet(FX5_Square, OBJPROP_PRICE2);
//----   
   int squareShift_1 = iBarShift(NULL, 0, squareTime_1, false);
   int squareShift_2 = iBarShift(NULL, 0, squareTime_2, false);
   
   double scale = ((squarePrice_2 - squarePrice_1) / Point) / 
                   (squareShift_2 - squareShift_1);
   scale = MathAbs(scale);
//----   
   int timeShift1 = squareShift_1 + MathRound(x1);
   int timeShift2 = squareShift_1 + MathRound(x2);
//----   
   double price1 = squarePrice_1 + NormalizeDouble(y1* scale * Point, 
                   Digits);
   double price2 = squarePrice_1 + NormalizeDouble(y2* scale * Point, 
                   Digits);
//----   
   if((x2 >= 0 && y2 >= 0) || (x2 <= 0 && y2 <= 0))
       color lineColor = spiralColor1;
   else
       lineColor = spiralColor2;
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, GetTime(timeShift1), price1, 
                GetTime(timeShift2), price2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetTime(int timeShift)
  {
   if(timeShift >= 0)
      return(Time[timeShift]);
   datetime timeFrame = Time[0] - Time[1];
   datetime time = Time[0] - timeFrame * timeShift;
   return(time);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateSquare()
  {
   double priceRange = WindowPriceMax(0) - WindowPriceMin(0);
   double barsCount = WindowBarsPerChart();
   double chartScale = (priceRange / Point) / barsCount;
//----   
	int shift	= iBarShift(NULL,PERIOD_D1,Time[0]) + 1;	// yesterday
	double HiPrice		= iHigh(NULL,PERIOD_D1,shift);
   int x1 = CandleCenter;
   int x2 = 50 + radius;
   double y1 = High[x1];
   double y2 = y1 + 20 * Point * chartScale;
//----        
   string label = FX5_Square;
   ObjectDelete(label);
   ObjectCreate(label, OBJ_CYCLES, 0, Time[x1], y1, Time[x2], y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, 0XFFFFFFFF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteSpiral()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 12) != FX5_Spiral)
           continue;
       ObjectDelete(label);   
     }
  }
int VerifyParams()
  {
   if(radius <= 0)
     {
       radius = 5;
       Alert("Incorrect radius value!");
       return(-1);
     }
   if(goldenSpiralCycle <= 0)
     {
       goldenSpiralCycle = 1;
       Alert("Incorrect goldenSpiralCycle value!");
       return(-1);
     }
   if(accurity <= 0)
     {
       accurity = 0.2;
       Alert("Incorrect accurity value!");
       return(-1);
     }
//----      
   return(0);
  }
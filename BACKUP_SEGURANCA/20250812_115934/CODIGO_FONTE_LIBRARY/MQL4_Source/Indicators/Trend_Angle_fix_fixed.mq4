// Id: 11896
//+------------------------------------------------------------------+
//|                                                  Trend_Angle.mq4 |
//|                               Copyright � 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//Modified, 9/April/2021, by jeanlouie, www.forexfactory.com/jeanlouie
// - fixed zero divide errors
// - shortened angle calculations

#property copyright "Copyright � 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

#define Pi 3.1415926

extern int Length=14;
extern int Method=1;  // 0 - SMA
// 1 - EMA
// 2 - SMMA
// 3 - LWMA
extern int Price=0;    // Applied price
// 0 - Close
// 1 - Open
// 2 - High
// 3 - Low
// 4 - Median
// 5 - Typical
// 6 - Weighted
extern color TrendColor = DarkOrange ; // Yellow;
extern int Font_Size=10;
input bool  ShowANGL  = true;           // ShowANGL true/false?

double TA[];
double ANGL[];

string ObjName;

string IndicatorName;
string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
  {
   string name = target;
   int try
         = 2;
   while(WindowFind(name) != -1)
     {
      name = target + " #" + IntegerToString(try
                                                ++);
     }
   return name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorName = GenerateIndicatorName("Trend Angle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TA);

   SetIndexBuffer(1,ANGL);
   SetIndexLabel(1,"ANGL");

   ObjName=IndicatorObjPrefix + "Trend_Angle"+Length+Method+Price;

   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=3)
      return(0);
   int ExtCountedBars=IndicatorCounted();
   if(ExtCountedBars<0)
      return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2)
      limit=Bars-ExtCountedBars-1;
   int pos;
   pos=limit;
   while(pos>=0)
     {
      TA[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);

      pos--;
     }

   double Price1, Price2;
   datetime Time1, Time2;
   Price1=TA[1];
   Price2=TA[0];
   Time1=Time[1];
   Time2=Time[0];
   if(ObjectFind(0, ObjName)==-1)
     {
      ObjectCreate(0, ObjName, OBJ_TREND, 0, Time1, Price1, Time2, Price2);
     }
   else
     {
      if(ObjectGet(ObjName, OBJPROP_TIME1)!=Time1)
        {
         ObjectSet(ObjName, OBJPROP_TIME1, Time1);
        }
      if(ObjectGet(ObjName, OBJPROP_TIME2)!=Time2)
        {
         ObjectSet(ObjName, OBJPROP_TIME2, Time2);
        }
      if(ObjectGet(ObjName, OBJPROP_PRICE1)!=Price1)
        {
         ObjectSet(ObjName, OBJPROP_PRICE1, Price1);
        }
      if(ObjectGet(ObjName, OBJPROP_PRICE2)!=Price2)
        {
         ObjectSet(ObjName, OBJPROP_PRICE2, Price2);
        }
     }
   if(ObjectGet(ObjName, OBJPROP_COLOR)!=TrendColor)
     {
      ObjectSet(ObjName, OBJPROP_COLOR, TrendColor);
     }

   double Angle;
   string AngleStr;
   /*   int x1, x2, y1, y2;
      ChartTimePriceToXY(0, 0, Time[10], 10.*Price1-9.*Price2, x1, y1);
      ChartTimePriceToXY(0, 0, Time2, Price2, x2, y2);
      Angle=90-MathArctan((0.+x1-x2)/(0.+y2-y1))*180./Pi;
      AngleStr=DoubleToString(Angle, 2);*/
   int x1, x2, y1, y2;
   ChartTimePriceToXY(0, 0, Time[10], 10.*Price1-9.*Price2, x1, y1);
   ChartTimePriceToXY(0, 0, Time2, Price2, x2, y2);
   
   if((0.+y2-y1) == 0)return(0);
   
   Angle = 90-MathArctan((0.+x1-x2)/(0.+y2-y1))*180./Pi;// for upper cyclus
   
   if(Angle > 90){
      Angle=180-Angle;// for lower cyclus
      Angle*=-1;
   }
   
//   if((90-MathArctan((0.+x1-x2)/(0.+y2-y1))*180./Pi)<= 90)
//      Angle=90-MathArctan((0.+x1-x2)/(0.+y2-y1))*180./Pi;// for upper cyclus
//
//   if((90-MathArctan((0.+x1-x2)/(0.+y2-y1))*180./Pi)> 90)
//      Angle=-90-MathArctan((0.+x1-x2)/(0.+y2-y1))*180./Pi;// for lower cyclus

   AngleStr=DoubleToString(Angle, 2);


   for(pos=limit; pos>=0; pos--)
     {
      ANGL[pos] = Angle;

     }

   if(ShowANGL)
     {
      ObjectCreate("Angle", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Angle", "#Angle: " + DoubleToString(Angle, 2),  20, "Arial Black", DarkOrange);
      ObjectSet("Angle", OBJPROP_CORNER, 1);
      ObjectSet("Angle", OBJPROP_XDISTANCE, 10);
      ObjectSet("Angle", OBJPROP_YDISTANCE, 260);
     }

   if(ObjectFind(0, ObjName+"T")==-1)
     {
      ObjectCreate(0, ObjName+"T", OBJ_TEXT, 0, Time2, Price2);
     }
   else
     {
      if(ObjectGet(ObjName+"T", OBJPROP_TIME1)!=Time2)
        {
         ObjectSet(ObjName+"T", OBJPROP_TIME1, Time2);
        }
      if(ObjectGet(ObjName+"T", OBJPROP_PRICE1)!=Price2)
        {
         ObjectSet(ObjName+"T", OBJPROP_PRICE1, Price2);
        }
     }
   ObjectSetText(ObjName+"T", AngleStr, Font_Size, NULL, TrendColor);

   return(0);
  }

//+------------------------------------------------------------------+

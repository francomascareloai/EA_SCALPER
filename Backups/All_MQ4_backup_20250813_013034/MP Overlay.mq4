//+------------------------------------------------------------------+
//|                                                 Level Sensor.mq4 |
//|                                          Copyright © 2005, Sfen. |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Sfen"
#property indicator_chart_window
//---- input parameters
extern int       MAX_HISTORY=500;
extern int       STEP = 1;
int init()
  {
   return(0);
  }
double CSH(int shift)
{
 return (MathMax(Open[shift],Close[shift]));
}
double CSL(int shift)
{
 return (MathMin(Open[shift],Close[shift]));
}
string OBJECT_PREFIX = "LEVELS";
int ObjectId = 0;
string IntToStr(int X)
{
 return (DoubleToStr(X,0));
}
string ObGetUniqueName(string Prefix)
{
 ObjectId++;
 return (Prefix+" "+IntToStr(ObjectId));
}
void   ObDeleteObjectsByPrefix(string Prefix)
{
 int L = StringLen(Prefix);
 int i=0; 
 while (i<ObjectsTotal())
 {
  string ObjName = ObjectName(i);
  if (StringSubstr(ObjName,0,L)!=Prefix) { i++; continue;}
  ObjectDelete(ObjName);
 }
}
int deinit()
  {
   ObDeleteObjectsByPrefix(OBJECT_PREFIX);
   return(0);
  }
int start()
  {
   string S;
   ObDeleteObjectsByPrefix(OBJECT_PREFIX);
   double HH = 0;
   double LL = 1000000;
   int History = MathMin(Bars,MAX_HISTORY);
   
   int i, j, k;
   for (i=1; i<History; i++)
   {
    HH = MathMax(HH,CSH(i));
    LL = MathMin(LL,CSL(i));
   }
   int NumberOfPoints = (HH-LL)/(1.0*Point*STEP)+1;
   int Count[];
   ArrayResize(Count,NumberOfPoints);
   
   for (i=0; i<NumberOfPoints; i++) Count[i]=0;
   for (i=1; i<History; i++)
   {
    double C = CSL(i);
    while (C<CSH(i))
    {
     int Index = (C-LL)/(1.0*Point*STEP);
     Count[Index]++;    
     C += 1.0*Point*STEP;
    }
   }
   
   for (i=0; i<NumberOfPoints; i++)
   {
    double StartX = Time[5];
    double StartY = LL + 1.0*Point*STEP*i;
    double EndX   = Time[5+Count[i]];
    double EndY   = StartY;
      
    string ObjName = ObGetUniqueName(OBJECT_PREFIX);
    ObjectDelete(ObjName);
    ObjectCreate(ObjName,OBJ_TREND,0,StartX,StartY,EndX,EndY);
    ObjectSet(ObjName,OBJPROP_RAY,0);
    ObjectSet(ObjName,OBJPROP_COLOR,Red);
    
   }
   return(0);
  }
//+------------------------------------------------------------------+



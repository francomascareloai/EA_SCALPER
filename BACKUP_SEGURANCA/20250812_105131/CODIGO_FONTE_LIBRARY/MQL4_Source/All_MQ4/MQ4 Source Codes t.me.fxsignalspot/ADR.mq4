//+------------------------------------------------------------------+
//|                                           ADR.mq4 |
//+------------------------------------------------------------------+



#property indicator_chart_window

extern int      NumOfDays             = 14;
extern string   FontName              = "Verdana";
extern int      FontSize              = 8;
extern color    FontColor             = LightGray;
extern int      Window                = 0;
extern int      Window_Corner          = 0;
extern int      HorizPos1              = 5;
extern int      VertPos1               = 12;

double pnt;
int    dig;
string objname1 = "adr_info";

//+------------------------------------------------------------------+
int init()  {
//+------------------------------------------------------------------+
  pnt = MarketInfo(Symbol(),MODE_POINT);
  dig = MarketInfo(Symbol(),MODE_DIGITS);
  if (dig == 3 || dig == 5) {
    pnt *= 10;
  }  
  ObjectCreate(objname1,OBJ_LABEL,Window,0,0);

  return(0);
}

//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
  ObjectDelete(objname1);

  return(0);
}

//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
  int c=0;
  double sum=0;
  
 //Symbol and Time Frame
      	 	         
 // if (Period()== 1)     string TF =  ", M1 ";
 //  else {if (Period()== 5)     TF = ", M5 ";
 //  else {if (Period()== 15)    TF = ", M15 ";
 //  else {if (Period()== 30)    TF = ", M30 ";
 //  else {if (Period()== 60)    TF = ", H1 ";
 //  else {if (Period()== 240)   TF = ", H4 ";
 //  else {if (Period()== 1440)  TF = ", Daily ";
 //  else {if (Period()== 10080) TF = ", Weekly ";
 //  else {if (Period()== 43200) TF = ", Monthly "; }}}}}}}} 
 
  
  
  for (int i=1; i<Bars-1; i++)  {
    double hi = iHigh(NULL,PERIOD_D1,i);
    double lo = iLow(NULL,PERIOD_D1,i);
    datetime dt = iTime(NULL,PERIOD_D1,i);
    if (TimeDayOfWeek(dt) > 0 && TimeDayOfWeek(dt) < 6)  {
      sum += hi - lo;
      c++;
      if (c>=NumOfDays) break;
  } }
  hi = iHigh(NULL,PERIOD_D1,0);
  lo = iLow(NULL,PERIOD_D1,0);
  if (i>0 && pnt>0 && c>0)  {
    string objtext1 = "ADR: " + DoubleToStr(sum/c/pnt,1) + " (" + c + " days), Today: " + DoubleToStr((hi-lo)/pnt,1);
    ObjectSet(objname1,OBJPROP_CORNER,Window_Corner);
    ObjectSet(objname1,OBJPROP_XDISTANCE,HorizPos1);
    ObjectSet(objname1,OBJPROP_YDISTANCE,VertPos1);
    ObjectSetText(objname1,objtext1,FontSize,FontName,FontColor);
   
   
  }  
  return(0);
}


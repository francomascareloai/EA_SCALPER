//+------------------------------------------------------------------+
//|                                                   MTF_HI_LOW.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property link      " modified by cja "
//+------------------------------------------------------------------+
//|                                                 AllPivots_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_chart_window

extern int  CountDays=10;

extern bool Show_CurrDaily = true;
extern int Shift_CurrDaily_LABEL = 0;
extern bool Show_CurrWeekly = true;
extern int Shift_CurrWeekly_LABEL = 0;
extern bool Show_CurrMonthly = true;
extern int Shift_CurrMonthly_LABEL = 0;
extern color line_color_CurrDailyUPPER = Lime;
extern color line_color_CurrDailyLOWER = Magenta;
extern color line_color_CurrWeeklyUPPER = YellowGreen;
extern color line_color_CurrWeeklyLOWER = Pink;
extern color line_color_CurrMonthlyUPPER = Green;
extern color line_color_CurrMonthyLOWER = Red;
extern int CurrDaily_LineStyle = 2;
extern int CurrWeekly_LineStyle = 3;
extern int CurrMonthly_LineStyle = 4;


extern bool Show_PreviousDaily = true;
extern bool Xtend_Prev_DailyLine = false;
extern bool Show_PreviousWeekly = true;
extern bool Xtend_Prev_WeeklyLine = false;
extern bool Show_PreviousMonthly = true;
extern bool Xtend_Prev_MonthlyLine = false;
extern color line_color_PreviousDaily = Aqua;
extern color line_color_PreviousWeekly = Yellow;
extern color line_color_PreviousMonthly = Orange;
extern int PreviousLine_Style = 2;
extern int Shift_Prev_LABEL = 10;

extern bool Show_CurrRectangles_Display = false;
extern bool Show_Rectangles = true;
extern bool Rectangle_Curr_DayPeriod_only = false;
extern bool Show_Daily_Rectangle = true;
extern color Daily_Rectangle_color = Navy;
extern bool Show_Weekly_Rectangle = true;
extern color Weekly_Rectangle_color = Blue;
extern bool Show_Monthly_Rectangle = true;
extern color Monthly_Rectangle_color = Maroon;

extern bool Show_Daily_Pivots = false;
extern color Daily_Pivot_color = Aqua;
extern int Daily_Pivot_LineWidth = 1;  
extern bool Show_Weekly_Pivots = false;
extern color Weekly_Pivot_color = Yellow;
extern int Weekly_Pivot_LineWidth = 1; 
extern bool Show_Monthly_Pivots = false;
extern color Monthly_Pivot_color = Orange;
extern int Monthly_Pivot_LineWidth = 1; 


#define Curr_DG "Curr_DG"

#define Curr_WG "Curr_WG"

#define Curr_MG "Curr_MG"

   datetime time1;
   datetime time2;
   
   datetime time3;
   datetime time4;
   
   datetime time5;
   datetime time6;
   //******************************
   //currTimes
   
   datetime time7;
   datetime time8;
   datetime time9;
   datetime time10;
   datetime time11;
   datetime time12;
   //********************************
   //Pivot
   datetime time13;
   datetime time14;
   datetime time15;
   datetime time16;
   datetime time17;
   datetime time18;
 
   double DHi,DLo,WHi,WLo,MHi,MLo;
   double DHigh,DLow,WHigh,WLow,MHigh,MLow;
   double highD,lowD,closeD,highW,lowW,closeW,highM,lowM,closeM;
   double PD,PW,PM;
   
   int shift, num;
     
   void ObjDel()
   {
      for (;num<=CountDays;num++)
      {
      ObjectDelete("Previous_DailyHi["+num+"]");
      ObjectDelete("Previous_DailyLo["+num+"]");
      ObjectDelete("Previous_WeeklyHi["+num+"]");
      ObjectDelete("Previous_WeeklyLo["+num+"]");
      ObjectDelete("Previous_MonthlyHi["+num+"]");
      ObjectDelete("Previous_MonthlyLo["+num+"]");
    
      ObjectDelete("CurrentDailyHi["+num+"]");
      ObjectDelete("CurrentDailyLo["+num+"]");
      ObjectDelete("CurrentWeeklyHi["+num+"]");
      ObjectDelete("CurrentWeeklyLo["+num+"]");
      ObjectDelete("CurrentMonthlyHi["+num+"]");
      ObjectDelete("CurrentMonthlyLo["+num+"]");
      //*****************
      //Pivot
       ObjectDelete("CurrentPivot["+num+"]");
       ObjectDelete("CurrentWeeklylyPivot["+num+"]");
       ObjectDelete("CurrentMonthlyPivot["+num+"]");
     } 
      
   }

   void PlotLineD(string dname,double value,double line_color_Daily,double style)
   {
   ObjectCreate(dname,OBJ_TREND,0,time1,value,time2,value);
   ObjectSet(dname, OBJPROP_WIDTH, 1);
   ObjectSet(dname, OBJPROP_STYLE, PreviousLine_Style);
   ObjectSet(dname, OBJPROP_RAY, Xtend_Prev_DailyLine);
   ObjectSet(dname, OBJPROP_BACK, true);
   ObjectSet(dname, OBJPROP_COLOR, line_color_Daily);
    }        
    
     void PlotLineW(string wname,double value,double line_color_Weekly,double style)
   {
   ObjectCreate(wname,OBJ_TREND,0,time3,value,time4,value);
   ObjectSet(wname, OBJPROP_WIDTH, 1);
   ObjectSet(wname, OBJPROP_STYLE, PreviousLine_Style);
   ObjectSet(wname, OBJPROP_RAY, Xtend_Prev_WeeklyLine);
   ObjectSet(wname, OBJPROP_BACK, true);
   ObjectSet(wname, OBJPROP_COLOR, line_color_Weekly);
    }        
       void PlotLineM(string mname,double value,double line_color_Monthly,double style)
   {
   ObjectCreate(mname,OBJ_TREND,0,time5,value,time6,value);
   ObjectSet(mname, OBJPROP_WIDTH, 1);
   ObjectSet(mname, OBJPROP_STYLE, PreviousLine_Style);
   ObjectSet(mname, OBJPROP_RAY, Xtend_Prev_MonthlyLine);
   ObjectSet(mname, OBJPROP_BACK, true);
   ObjectSet(mname, OBJPROP_COLOR, line_color_Monthly);
    }
   //****************************************************************************************
   // CurrDaily levels 
         void PlotLineDLY(string dayname,double value,double col,double style)
   {
   ObjectCreate(dayname,OBJ_TREND,0,time7,value,time8,value);
   ObjectSet(dayname, OBJPROP_WIDTH, 1);
   ObjectSet(dayname, OBJPROP_STYLE, CurrDaily_LineStyle );
   ObjectSet(dayname, OBJPROP_RAY, false);
   ObjectSet(dayname, OBJPROP_BACK, true);
   ObjectSet(dayname, OBJPROP_COLOR, col);
    }
  
           void PlotLineWLY(string weekname,double value,double col,double style)
   {
   ObjectCreate(weekname,OBJ_TREND,0,time9,value,time10,value);
   ObjectSet(weekname, OBJPROP_WIDTH, 1);
   ObjectSet(weekname, OBJPROP_STYLE, CurrWeekly_LineStyle );
   ObjectSet(weekname, OBJPROP_RAY, false);
   ObjectSet(weekname, OBJPROP_BACK, true);
   ObjectSet(weekname, OBJPROP_COLOR, col);
    }
            void PlotLineMLY(string monthname,double value,double col,double style)
   {
   ObjectCreate(monthname,OBJ_TREND,0,time11,value,time12,value);
   ObjectSet(monthname, OBJPROP_WIDTH, 1);
   ObjectSet(monthname, OBJPROP_STYLE, CurrMonthly_LineStyle );
   ObjectSet(monthname, OBJPROP_RAY, false);
   ObjectSet(monthname, OBJPROP_BACK, true);
   ObjectSet(monthname, OBJPROP_COLOR, col);
    }    
    
              void PlotLinePVT(string pname,double value,double col,double style)
   {
   ObjectCreate(pname,OBJ_TREND,0,time13,value,time14,value);
   ObjectSet(pname, OBJPROP_WIDTH, Daily_Pivot_LineWidth);
   ObjectSet(pname, OBJPROP_STYLE, 0 );
   ObjectSet(pname, OBJPROP_RAY, false);
   ObjectSet(pname, OBJPROP_BACK, true);
   ObjectSet(pname, OBJPROP_COLOR, col);
    }   
                  void PlotLinePVTW(string wpname,double value,double col,double style)
   {
   ObjectCreate(wpname,OBJ_TREND,0,time15,value,time16,value);
   ObjectSet(wpname, OBJPROP_WIDTH, Weekly_Pivot_LineWidth);
   ObjectSet(wpname, OBJPROP_STYLE, 0 );
   ObjectSet(wpname, OBJPROP_RAY, false);
   ObjectSet(wpname, OBJPROP_BACK, true);
   ObjectSet(wpname, OBJPROP_COLOR, col);
    }   
                 void PlotLinePVTM(string mpname,double value,double col,double style)
   {
   ObjectCreate(mpname,OBJ_TREND,0,time17,value,time18,value);
   ObjectSet(mpname, OBJPROP_WIDTH, Monthly_Pivot_LineWidth);
   ObjectSet(mpname, OBJPROP_STYLE, 0 );
   ObjectSet(mpname, OBJPROP_RAY, false);
   ObjectSet(mpname, OBJPROP_BACK, true);
   ObjectSet(mpname, OBJPROP_COLOR, col);
    }   
int init()
  {
 IndicatorShortName("MTF_HI_LOW");  
  return(0);
  }
   
   
int deinit()
  {
  ObjectsDeleteAll(0,OBJ_RECTANGLE);
  ObjectsDeleteAll(0,OBJ_TRENDBYANGLE);
  ObjectsDeleteAll(0,OBJ_TEXT);
   ObjDel();
   Comment("");
   return(0);
  }

int start()
//*******************************************************************************************
  {
 
     CreateDHI();
}

void Create_DailyLineHI(string dLine, double start, double end,double w, double s,color clr)
  {
   ObjectCreate(dLine, OBJ_RECTANGLE, 0, iTime(NULL,1440,0), start, Time[0], end);
   ObjectSet(dLine, OBJPROP_COLOR, clr);
   ObjectSet(dLine,OBJPROP_RAY,false);
   ObjectSet(dLine,OBJPROP_BACK,Show_Rectangles);
   ObjectSet(dLine,OBJPROP_WIDTH,w);
    ObjectSet(dLine,OBJPROP_STYLE,s);

  }
   void DeleteCreate_DailyLineHI()
   {
   ObjectDelete( Curr_DG);ObjectDelete( Curr_WG);ObjectDelete( Curr_MG);  
   }
   void CreateDHI()
   {
   DeleteCreate_DailyLineHI();
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
   
    
     CreateWHI();
}

void Create_DailyLineWHI(string WLine, double start, double end,double w, double s,color clr)
  {
   ObjectCreate(WLine, OBJ_RECTANGLE, 0, iTime(NULL,10080,0), start, Time[0], end);
   ObjectSet(WLine, OBJPROP_COLOR, clr);
   ObjectSet(WLine,OBJPROP_RAY,false);
   ObjectSet(WLine,OBJPROP_BACK,Show_Rectangles);
   ObjectSet(WLine,OBJPROP_WIDTH,w);
    ObjectSet(WLine,OBJPROP_STYLE,s);

  }
   void DeleteCreate_DailyLineWHI()
   {
   ObjectDelete( Curr_WG); 
   }
   void CreateWHI()
   {
   DeleteCreate_DailyLineWHI();
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
    
     CreateMHI();
}

void Create_DailyLineMHI(string MLine, double start, double end,double w, double s,color clr)
  {
   ObjectCreate(MLine, OBJ_RECTANGLE, 0, iTime(NULL,43200,0), start, Time[0], end);
   ObjectSet(MLine, OBJPROP_COLOR, clr);
   ObjectSet(MLine,OBJPROP_RAY,false);
   ObjectSet(MLine,OBJPROP_BACK,Show_Rectangles);
   ObjectSet(MLine,OBJPROP_WIDTH,w);
    ObjectSet(MLine,OBJPROP_STYLE,s);

  }
   void DeleteCreate_DailyLineMHI()
   {
   ObjectDelete( Curr_MG); 
   }
   void CreateMHI()
   {
   DeleteCreate_DailyLineMHI();
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
   
   double Dailyhigh = iHigh(NULL,1440,0);
   double Dailylow = iLow(NULL,1440,0);
   double Weeklyhigh = iHigh(NULL,10080,0);
   double Weeklylow = iLow(NULL,10080,0);
   double Monthlyhigh = iHigh(NULL,43200,0);
   double Monthlylow = iLow(NULL,43200,0);
   
   if (  Rectangle_Curr_DayPeriod_only == false )
   {
   if (Show_CurrRectangles_Display == true )
   { 
   if (Show_Daily_Rectangle == true )
   {
   Create_DailyLineHI( Curr_DG, Dailyhigh , Dailylow ,2,2,Daily_Rectangle_color);
   }
    if (Show_Weekly_Rectangle == true )
   {
   Create_DailyLineWHI( Curr_WG, Weeklyhigh , Weeklylow ,2,2,Weekly_Rectangle_color);
   }
    if (Show_Monthly_Rectangle == true )
   {
   Create_DailyLineMHI( Curr_MG, Monthlyhigh , Monthlylow ,2,2,Monthly_Rectangle_color);
   }}}
   
    if ( Rectangle_Curr_DayPeriod_only == true )
   {
   if (Show_CurrRectangles_Display == true )
   { 
   if (Show_Daily_Rectangle == true )
   {
   Create_DailyLineHI( Curr_DG, Dailyhigh , Dailylow ,2,2,Daily_Rectangle_color);
   }
    if (Show_Weekly_Rectangle == true )
   {
   Create_DailyLineHI( Curr_WG, Weeklyhigh , Weeklylow ,2,2,Weekly_Rectangle_color);
   }
    if (Show_Monthly_Rectangle == true )
   {
   Create_DailyLineHI( Curr_MG, Monthlyhigh , Monthlylow ,2,2,Monthly_Rectangle_color);
   }}}
   //*******************************************************************************
  int i;
     
  ObjDel();
  num=0;
  
  for (shift=CountDays-1;shift>=0;shift--)
  {
  time1=iTime(NULL,PERIOD_D1,shift);
  time3=iTime(NULL,PERIOD_W1,shift);
  time5=iTime(NULL,PERIOD_MN1,shift);
  //**************************************************
  //CurrDaily levels
  time7=iTime(NULL,PERIOD_D1,0);
  time9=iTime(NULL,PERIOD_W1,0);
  time11=iTime(NULL,PERIOD_MN1,0);
  //**********************************************
  //Pivot
  time13=iTime(NULL,PERIOD_D1,shift);
  time15=iTime(NULL,PERIOD_W1,shift);
  time17=iTime(NULL,PERIOD_MN1,shift);
  
 
  i=shift-1;
  if (i<0) 
  time2=Time[0];
  else
  time2=iTime(NULL,PERIOD_D1,i)-Period()*60;
  if (i<0)
  time4=Time[0];
  else
  time4=iTime(NULL,PERIOD_W1,i)-Period()*60;
  if (i<0)
  time6=Time[0];
  else
  time6=iTime(NULL,PERIOD_MN1,i)-Period()*60; 
  if (i<0)
  //***********************************************************
  //CurrDaily levels
  time8=iTime(NULL,PERIOD_D1,0)-Period()*60; 
  time10=iTime(NULL,PERIOD_W1,0)-Period()*60; 
  time12=iTime(NULL,PERIOD_MN1,0)-Period()*60; 
  //*********************************************************
  //Pivot
  if (i<0) 
  time14=Time[0];
  else
  time14=iTime(NULL,PERIOD_D1,i)-Period()*60;
  if (i<0)
  time16=Time[0];
  else
  time16=iTime(NULL,PERIOD_W1,i)-Period()*60;
  if (i<0)
  time18=Time[0];
  else
  time18=iTime(NULL,PERIOD_MN1,i)-Period()*60; 
  
  highD  = iHigh(NULL,PERIOD_D1,shift+1);
  lowD   = iLow(NULL,PERIOD_D1,shift+1);
  closeD = iClose(NULL,PERIOD_D1,shift+1);
  highW  = iHigh(NULL,PERIOD_W1,shift+1);
  lowW   = iLow(NULL,PERIOD_W1,shift+1);
  closeW = iClose(NULL,PERIOD_W1,shift+1);
  highM  = iHigh(NULL,PERIOD_MN1,shift+1);
  lowM   = iLow(NULL,PERIOD_MN1,shift+1);
  closeM = iClose(NULL,PERIOD_MN1,shift+1);
 
       
  PD  = (highD+lowD+closeD)/3.0;
  PW  = (highW+lowW+closeW)/3.0;
  PM  = (highM+lowM+closeM)/3.0;
  

      
  DHi  = iHigh(NULL,PERIOD_D1,shift+1);
  DLo   = iLow(NULL,PERIOD_D1,shift+1);
  
  WHi  = iHigh(NULL,PERIOD_W1,shift+1);
  WLo   = iLow(NULL,PERIOD_W1,shift+1);
 
  MHi  = iHigh(NULL,PERIOD_MN1,shift+1);
  MLo   = iLow(NULL,PERIOD_MN1,shift+1);
  //***************************
  //CurrDaily levels
  DHigh  = iHigh(NULL,PERIOD_D1,0);
  DLow   = iLow(NULL,PERIOD_D1,0);
  
  WHigh  = iHigh(NULL,PERIOD_W1,0);
  WLow   = iLow(NULL,PERIOD_W1,0);
  
  MHigh  = iHigh(NULL,PERIOD_MN1,0);
  MLow   = iLow(NULL,PERIOD_MN1,0);
 
  time2=time1+PERIOD_D1*60;
  time4=time3+PERIOD_W1*60;
  time6=time5+PERIOD_MN1*60;
  //******************************************
  // CurrDaily levels
  time8=time7+PERIOD_D1*60;
  time10=time9+PERIOD_W1*60;
  time12=time11+PERIOD_MN1*60;
  //******************************************
  //Pivot
  time14=time13+PERIOD_D1*60;
  time16=time15+PERIOD_W1*60;
  time18=time17+PERIOD_MN1*60;

 
         
 
  num=shift;
   if (Show_PreviousDaily == true)
    {       
  PlotLineD("Previous_DailyHi["+num+"]",DHi,line_color_PreviousDaily,0);
  PlotLineD("Previous_DailyLo["+num+"]",DLo,line_color_PreviousDaily,0);
  }
   if (Show_PreviousWeekly == true)
    {  
  PlotLineW("Previous_WeeklyHi["+num+"]",WHi,line_color_PreviousWeekly,0);
  PlotLineW("Previous_WeeklyLo["+num+"]",WLo,line_color_PreviousWeekly,0);
  }
   if (Show_PreviousMonthly == true)
    {  
  PlotLineM("Previous_MonthlyHi["+num+"]",MHi,line_color_PreviousMonthly,0);
  PlotLineM("Previous_MonthlyLo["+num+"]",MLo,line_color_PreviousMonthly,0);
 }
 //***************************************************************************************************
 //CurrDaily levels
  if (Show_CurrDaily == true)
    {    
  PlotLineDLY("CurrentDailyHi["+num+"]",DHigh,line_color_CurrDailyUPPER ,0);
  PlotLineDLY("CurrentDailyLo["+num+"]",DLow,line_color_CurrDailyLOWER,0);
  }
   if (Show_CurrWeekly == true)
    { 
  PlotLineWLY("CurrentWeeklyHi["+num+"]",WHigh,line_color_CurrWeeklyUPPER,0);
  PlotLineWLY("CurrentWeeklyLo["+num+"]",WLow,line_color_CurrWeeklyLOWER,0);
  }
   if (Show_CurrMonthly == true)
    { 
  PlotLineMLY("CurrentMonthlyHi["+num+"]",MHigh,line_color_CurrMonthlyUPPER ,0);
  PlotLineMLY("CurrentMonthlyLo["+num+"]",MLow,line_color_CurrMonthyLOWER,0);
  }}
  //*****************************************
  if (Show_Daily_Pivots == true)
  {
  PlotLinePVT("CurrentPivot["+num+"]",PD,Daily_Pivot_color,0);
  }
  if (Show_Weekly_Pivots == true)
  {
  PlotLinePVTW("CurrentWeeklylyPivot["+num+"]",PW,Weekly_Pivot_color,0);
  }
  if (Show_Monthly_Pivots == true)
  {
  PlotLinePVTM("CurrentMonthlyPivot["+num+"]",PM,Monthly_Pivot_color ,0);
  }
   
   
  if(ObjectFind("HILO") != 0){
  ObjectCreate("HILO", OBJ_TEXT, 0, Time[Shift_CurrDaily_LABEL], DHigh);
  ObjectSetText("HILO", "                                   Daily High "+DoubleToStr(DHigh,Digits)+"", 8, "Arial", line_color_CurrDailyUPPER);
  }else{  ObjectMove("HILO", 0, Time[Shift_CurrDaily_LABEL], DHigh);}
  
  if(ObjectFind("HILO1") != 0){
  ObjectCreate("HILO1", OBJ_TEXT, 0, Time[Shift_CurrDaily_LABEL], DLow);
  ObjectSetText("HILO1", "                                  Daily Low "+DoubleToStr(DLow,Digits)+" ", 8, "Arial", line_color_CurrDailyLOWER);
  }else{  ObjectMove("HILO1", 0, Time[Shift_CurrDaily_LABEL], DLow);}
  
   if(ObjectFind("HILO2") != 0){
  ObjectCreate("HILO2", OBJ_TEXT, 0, Time[Shift_CurrWeekly_LABEL], WHigh);
  ObjectSetText("HILO2", "                                  Weekly High "+DoubleToStr(WHigh,Digits)+" ", 8, "Arial", line_color_CurrWeeklyUPPER);
  }else{  ObjectMove("HILO2", 0, Time[Shift_CurrWeekly_LABEL], WHigh);}
  
  if(ObjectFind("HILO3") != 0){
  ObjectCreate("HILO3", OBJ_TEXT, 0, Time[Shift_CurrWeekly_LABEL], WLow);
  ObjectSetText("HILO3", "                                  Weekly Low "+DoubleToStr(WLow,Digits)+" ", 8, "Arial", line_color_CurrWeeklyLOWER);
  }else{  ObjectMove("HILO3", 0, Time[Shift_CurrWeekly_LABEL], WLow);}
  
   if(ObjectFind("HILO4") != 0){
  ObjectCreate("HILO4", OBJ_TEXT, 0, Time[Shift_CurrMonthly_LABEL], MHigh);
  ObjectSetText("HILO4", "                                  Monthly High "+DoubleToStr(MHigh,Digits)+" ", 8, "Arial", line_color_CurrMonthlyUPPER);
  }else{  ObjectMove("HILO4", 0, Time[Shift_CurrMonthly_LABEL], MHigh);}
  
   if(ObjectFind("HILO5") != 0){
  ObjectCreate("HILO5", OBJ_TEXT, 0, Time[Shift_CurrMonthly_LABEL], MLow);
  ObjectSetText("HILO5", "                                  Monthly Low "+DoubleToStr(MLow,Digits)+" ", 8, "Arial", line_color_CurrMonthyLOWER);
  }else{  ObjectMove("HILO5", 0, Time[Shift_CurrMonthly_LABEL], MLow);}
           
   //Previous Levels
   
   if(ObjectFind("HILOP") != 0){
  ObjectCreate("HILOP", OBJ_TEXT, 0, Time[Shift_Prev_LABEL+10], DHi);
  ObjectSetText("HILOP", "Prev / Daily High "+DoubleToStr(DHi,Digits)+" ", 8, "Arial", line_color_PreviousDaily);
  }else{  ObjectMove("HILOP", 0, Time[Shift_Prev_LABEL+10], DHi);}
  
  if(ObjectFind("HILO1P") != 0){
  ObjectCreate("HILO1P", OBJ_TEXT, 0, Time[Shift_Prev_LABEL+10], DLo);
  ObjectSetText("HILO1P", "Prev / Daily Low "+DoubleToStr(DLo,Digits)+" ", 8, "Arial", line_color_PreviousDaily);
  }else{  ObjectMove("HILO1P", 0, Time[Shift_Prev_LABEL+10], DLo);}
  
   if(ObjectFind("HILO2P") != 0){
  ObjectCreate("HILO2P", OBJ_TEXT, 0, Time[Shift_Prev_LABEL+10], WHi);
  ObjectSetText("HILO2P", "Prev / Weekly High "+DoubleToStr(WHi,Digits)+" ", 8, "Arial", line_color_PreviousWeekly);
  }else{  ObjectMove("HILO2P", 0, Time[Shift_Prev_LABEL+10], WHi);}
  
  if(ObjectFind("HILO3P") != 0){
  ObjectCreate("HILO3P", OBJ_TEXT, 0, Time[Shift_Prev_LABEL+10], WLo);
  ObjectSetText("HILO3P", "Prev / Weekly Low "+DoubleToStr(WLo,Digits)+" ", 8, "Arial", line_color_PreviousWeekly);
  }else{  ObjectMove("HILO3P", 0, Time[Shift_Prev_LABEL+10], WLo);}
  
   if(ObjectFind("HILO4P") != 0){
  ObjectCreate("HILO4P", OBJ_TEXT, 0, Time[Shift_Prev_LABEL+10], MHi);
  ObjectSetText("HILO4P", "Prev / Monthly High "+DoubleToStr(MHi,Digits)+" ", 8, "Arial", line_color_PreviousMonthly);
  }else{  ObjectMove("HILO4P", 0, Time[Shift_Prev_LABEL+10], MHi);}
  
   if(ObjectFind("HILO5P") != 0){
  ObjectCreate("HILO5P", OBJ_TEXT, 0, Time[Shift_Prev_LABEL+10], MLo);
  ObjectSetText("HILO5P", "Prev / Monthly Low "+DoubleToStr(MLo,Digits)+" ", 8, "Arial", line_color_PreviousMonthly);
  }else{  ObjectMove("HILO5P", 0, Time[Shift_Prev_LABEL+10], MLo);}
              
       
       
         
   return(0);
  }
//+------------------------------------------------------------------+
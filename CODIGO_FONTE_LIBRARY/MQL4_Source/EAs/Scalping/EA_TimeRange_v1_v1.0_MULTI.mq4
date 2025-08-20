//+------------------------------------------------------------------+
//|                                                 TimeRange_v1.mq4 |
//|                                Copyright © 2013, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window

//---- input parameters
extern string     set1              = "--- Main settings ---";
extern string     UniqueName        =  "timeRange";
extern string     RangeStartTime    =  "00:00";       // Range Start Hour
extern string     RangeEndTime      =  "07:00";       // Range End Hour 
extern int        RangeLength       =  12;            // Range Length in bars
extern int        RangeMode         =  0;             // 0-HH/LL;1-Close/Close
extern int        NumberOfDays      =  5;

extern string     set2              = "--- Visual settings ---";
extern color      RangeBoxColor     =  Yellow;
extern int        BoxLineStyle      =  STYLE_SOLID;
extern int        BoxLineWidth      =  1;

extern color      UpperColor        =  DeepSkyBlue;
extern color      LowerColor        =  OrangeRed;
extern int        LineStyle         =  STYLE_SOLID;
extern int        LineWidth         =  1;

extern bool       ShowRangeValues   =  true;
extern string     FontName          =  "Arial";
extern int        FontSize          =  8;


int      pBars;
bool     fTime;
datetime prevTime;  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   fTime = true;
   
return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+   
int deinit()
{
   deleteObj(UniqueName);
   Comment("");
   return(0);
}
//+------------------------------------------------------------------+
//| TimeRange_v1                                                     |
//+------------------------------------------------------------------+
int start()
{
   datetime curTime = TimeCurrent();
      
   if(StrToTime(TimeToStr(TimeCurrent(),TIME_DATE)) != prevTime || fTime)  
   {
   deleteObj(UniqueName);
      
      for(int shift=0;shift<NumberOfDays;shift++)
      {
      datetime RangeStart = StrToTime(TimeToStr(curTime,TIME_DATE) + " " + RangeStartTime);
      datetime RangeEnd   = StrToTime(TimeToStr(curTime,TIME_DATE) + " " + RangeEndTime  );
      
      if(RangeStart > RangeEnd) 
      {
      if(TimeDayOfWeek(curTime) != 1) RangeStart -= 1440*60; else RangeStart -= 3*1440*60; 
      }
      
      int Length   = iBarShift(Symbol(),0,RangeStart,FALSE) - iBarShift(Symbol(),0,RangeEnd,FALSE);
      int duration = RangeLength*Period(); 
      
         if(RangeMode == 0)
         {
         double Hi  = High[iHighest(Symbol(),0,MODE_HIGH,Length,iBarShift(Symbol(),0,RangeEnd,FALSE))];
         double Lo  = Low [iLowest (Symbol(),0,MODE_LOW ,Length,iBarShift(Symbol(),0,RangeEnd,FALSE))];
         }
         else
         {
         Hi  = iOpen(Symbol(),0,iBarShift(Symbol(),0,RangeStart,FALSE));
         Lo  = iOpen(Symbol(),0,iBarShift(Symbol(),0,RangeEnd  ,FALSE));
         }
      
      double textDelta = 0.5*MathCeil(iATR(NULL,0,50,1)/Point);
         
      double timeDelta = (Time[0] - Time[1])*3;    
     
      PlotText(UniqueName+" Hi"+TimeToStr(RangeEnd),DoubleToStr(Hi,Digits),RangeStart + timeDelta,Hi + 3*textDelta*Point,FontSize,FontName,true,UpperColor);         
      PlotText(UniqueName+" Lo"+TimeToStr(RangeEnd),DoubleToStr(Lo,Digits),RangeStart + timeDelta,Lo -   textDelta*Point,FontSize,FontName,true,LowerColor);         
        
      PlotBox(UniqueName+TimeToStr(RangeEnd),RangeEnd,Hi,RangeStart,Lo,BoxLineStyle,RangeBoxColor,BoxLineWidth,0);
      PlotBox(UniqueName+TimeToStr(RangeEnd),RangeEnd,Hi,RangeStart,Lo,BoxLineStyle,RangeBoxColor,BoxLineWidth,1);
   
      PlotLine(UniqueName+" Hi5"+TimeToStr(RangeEnd),Hi,RangeEnd,RangeEnd + duration*60,LineStyle,UpperColor,LineWidth);
      PlotLine(UniqueName+" Lo5"+TimeToStr(RangeEnd),Lo,RangeEnd,RangeEnd + duration*60,LineStyle,LowerColor,LineWidth);
      
      curTime = decDateTradeDay(curTime);
      while(TimeDayOfWeek(curTime) > 5 || TimeDayOfWeek(curTime) == 0) curTime = decDateTradeDay(curTime);
      }      
   
   fTime    = false;
   prevTime = StrToTime(TimeToStr(TimeCurrent(),TIME_DATE));
   }     
   
   return(0);
}

//+------------------------------------------------------------------+


void PlotLine(string name,double value,datetime time1,datetime time2,int style,color clr,int width)
{
   bool res = ObjectCreate(name,OBJ_TREND,0,time1,value,time2,value);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_RAY  , false);
   ObjectSet(name, OBJPROP_BACK , true);
   ObjectSet(name, OBJPROP_COLOR, clr);
}        

void PlotText(string name,string text,datetime time,double price,int size,string font,bool back,color clr)
{
   ObjectCreate(name,OBJ_TEXT,0,time,price);
   ObjectSetText(name,text,size,font,clr);
   ObjectSet(name,OBJPROP_BACK,back);
}

void PlotBox(string name,datetime time1,double value1, datetime time2,double value2,int style,color clr,double width,int mode)
{   
   
   if(mode == 0)
   {
   ObjectCreate(name+" 1H",OBJ_TREND,0,time1,value1,time2,value1);
   ObjectSet(name+" 1H",OBJPROP_COLOR,clr);
   ObjectSet(name+" 1H",OBJPROP_STYLE,style);
   ObjectSet(name+" 1H",OBJPROP_RAY,false);
   ObjectSet(name+" 1H",OBJPROP_BACK,true);
   ObjectSet(name+" 1H",OBJPROP_WIDTH,width);
 
   ObjectCreate(name+" 1V",OBJ_TREND,0,time1,value1,time1,value2);
   ObjectSet(name+" 1V",OBJPROP_COLOR,clr);
   ObjectSet(name+" 1V",OBJPROP_STYLE,style);
   ObjectSet(name+" 1V",OBJPROP_RAY,false);
   ObjectSet(name+" 1V",OBJPROP_BACK,true);
   ObjectSet(name+" 1V",OBJPROP_WIDTH,width);
  
   ObjectCreate(name+" 2H",OBJ_TREND,0,time1,value2,time2,value2);
   ObjectSet(name+" 2H",OBJPROP_COLOR,clr);
   ObjectSet(name+" 2H",OBJPROP_STYLE,style);
   ObjectSet(name+" 2H",OBJPROP_RAY,false);
   ObjectSet(name+" 2H",OBJPROP_BACK,true);
   ObjectSet(name+" 2H",OBJPROP_WIDTH,width);
   }
  
   if(mode == 1)
   {
   ObjectCreate(name+" 2V",OBJ_TREND,0,time2,value1,time2,value2);
   ObjectSet(name+" 2V",OBJPROP_COLOR,clr);
   ObjectSet(name+" 2V",OBJPROP_STYLE,style);
   ObjectSet(name+" 2V",OBJPROP_RAY,false);
   ObjectSet(name+" 2V",OBJPROP_BACK,true);
   ObjectSet(name+" 2V",OBJPROP_WIDTH,width);
   }
   
   if(mode == 2)
   {
   ObjectCreate(name+" 3H",OBJ_TREND,0,time1,value1,time2,value1);
   ObjectSet(name+" 3H",OBJPROP_COLOR,clr);
   ObjectSet(name+" 3H",OBJPROP_STYLE,style);
   ObjectSet(name+" 3H",OBJPROP_RAY,false);
   ObjectSet(name+" 3H",OBJPROP_BACK,true);
   ObjectSet(name+" 3H",OBJPROP_WIDTH,width);
   
   ObjectCreate(name+" 4H",OBJ_TREND,0,time1,value2,time2,value2);
   ObjectSet(name+" 4H",OBJPROP_COLOR,clr);
   ObjectSet(name+" 4H",OBJPROP_STYLE,style);
   ObjectSet(name+" 4H",OBJPROP_RAY,false);
   ObjectSet(name+" 4H",OBJPROP_BACK,true);
   ObjectSet(name+" 4H",OBJPROP_WIDTH,width);
   }
   
   if(mode == 3)
   {
   ObjectCreate(name+" 3V",OBJ_TREND,0,time2,value1,time2,value2);
   ObjectSet(name+" 3V",OBJPROP_COLOR,clr);
   ObjectSet(name+" 3V",OBJPROP_STYLE,style);
   ObjectSet(name+" 3V",OBJPROP_RAY,false);
   ObjectSet(name+" 3V",OBJPROP_BACK,true);
   ObjectSet(name+" 3V",OBJPROP_WIDTH,width);
   }
   
   if(mode == 4)
   {
   ObjectCreate(name+" 5H",OBJ_TREND,0,time1,value1,time2,value1);
   ObjectSet(name+" 5H",OBJPROP_COLOR,clr);
   ObjectSet(name+" 5H",OBJPROP_STYLE,style);
   ObjectSet(name+" 5H",OBJPROP_RAY,false);
   ObjectSet(name+" 5H",OBJPROP_BACK,true);
   ObjectSet(name+" 5H",OBJPROP_WIDTH,width);
   
   ObjectCreate(name+" 6H",OBJ_TREND,0,time1,value2,time2,value2);
   ObjectSet(name+" 6H",OBJPROP_COLOR,clr);
   ObjectSet(name+" 6H",OBJPROP_STYLE,style);
   ObjectSet(name+" 6H",OBJPROP_RAY,false);
   ObjectSet(name+" 6H",OBJPROP_BACK,true);
   ObjectSet(name+" 6H",OBJPROP_WIDTH,width);
   }
}	

bool deleteObj(string name)
{
   bool result = false;
   
   int length = StringLen(name);
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
   string objName = ObjectName(i); 
   if(StringSubstr(objName,0,length) == name) {ObjectDelete(objName); result = true;}
   }
   
   return(result);
}

datetime decDateTradeDay(datetime dt) 
{
   int ty=TimeYear(dt);
   int tm=TimeMonth(dt);
   int td=TimeDay(dt);
   int th=TimeHour(dt);
   int ti=TimeMinute(dt);
//----
   td--;
   if(td == 0) 
   {
   tm--;
      if(tm == 0) 
      {
      ty--;
      tm = 12;
      }
   if(tm == 1 || tm == 3 || tm == 5 || tm == 7 || tm == 8 || tm == 10 || tm == 12) td = 31;
   if(tm == 2) if(MathMod(ty,4) == 0) td = 29; else td = 28;
   if(tm == 4 || tm == 6 || tm == 9 || tm == 11) td = 30;
   }
   
   return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}
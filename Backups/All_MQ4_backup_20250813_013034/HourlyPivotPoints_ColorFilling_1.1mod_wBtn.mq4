//+------------------------------------------------------------------+
//|                               HourlyPivotPoints_ColorFilling.mq4 |
//|                                     Copyright 2018, by Dean Feng |
//|                                              ayhomer@outlook.com |
//+------------------------------------------------------------------+
//--- 5/4/2018 update:
//--- fixed a mistake in calculating S/R points by Fibo.
//--- fixed a bug in drawing objects
//--- 22/09/2018 mod by jeanlouie, forexfactory.com
//--- request for show/hide btn

#property copyright "Copyright 2018, by Dean Feng"
#property link      "ayhomer@outlook.com"
#property version   "1.10"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Define the ways of calculating Pivot Points                      |
//+------------------------------------------------------------------+
enum ENUM_PIVOT_MODE
  {
   Normal=0,
   Fibonacci=1
  };
//--- inputs
input string            short_name        ="HourlyPivot";
input ENUM_PIVOT_MODE   PivotMode         =Normal;
input bool              CurrentHourOnly   =true;
input int               CountBars         =500;
input string            Pivot_Lines       ="===== Pivot Lines =====";
input bool              ShowPivotLines    =true;
input int               LineWidth         =1;
input ENUM_LINE_STYLE   LineStyle         =STYLE_SOLID;
input color             RColor            =clrFireBrick;
input color             PColor            =clrDodgerBlue;
input color             SColor            =clrGreen;
input string            Pivot_Areas       ="===== Pivot Areas =====";
input bool              AreasFilling      =true;
input color             R1AreaColor       =clrMaroon;
input color             R2AreaColor       =clrMaroon;
input color             R3AreaColor       =clrMaroon;
input color             S1AreaColor       =clrDarkGreen;
input color             S2AreaColor       =clrDarkGreen;
input color             S3AreaColor       =clrDarkGreen;
input string            Pivot_Labels      ="===== Pivot Labels =====";
input bool              ShowLabels        =true;

input string note_10 = "";                         //Button
input bool btn_show = false;                       //__ show
input string btn_text = "1H Pivots";               //__  text
input int btn_offset_x = 10;                       //__ x
input int btn_offset_y = 20;                       //__ y
input int btn_width = 70;                          //__ width
input int btn_height = 20;                         //__ height
input int btn_font_size = 10;                      //__ font size
input color btn_font_clr = clrBlack;               //__ font color
input color btn_bg_color = clrGray;                //__ bg color
input color btn_border_clr = clrWhiteSmoke;        //__ border color


//--- global variables
int                     last_hour=-1;                       // last integral hour
int                     period=(int)MathCeil(60/Period());  // bar range in 1 hour
const long              chart_ID=ChartID();
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(chart_ID,short_name);
//--- indicator digits
   IndicatorDigits(_Digits);
//--- indicator short name
   IndicatorShortName(short_name);
//---
   if(btn_show){CreateButton();}
   else if(!btn_show){ObjectDelete(NULL,short_name+" btn");}
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator uninitalization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(chart_ID,short_name,0,-1);
   Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//--- do not calculate if period > 1 hour
   if(Period()>PERIOD_H1)  return(0);
//--- check rates_total
   if(rates_total<0)       return(-1);
//--- set calculation ending point
   int limit;
   if(CountBars>WindowBarsPerChart())  limit=WindowBarsPerChart();
   else                                limit=CountBars;
   if(prev_calculated>0)   limit=rates_total-IndicatorCounted()-1;
//--- calculate pivot point
   CalculateHourlyPivotPoints(limit);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate hourly Pivot Points                                    |
//+------------------------------------------------------------------+
bool CalculateHourlyPivotPoints(int bars_count)
  {
//---
   double   pre_high,pre_low,pre_close;   // high/low/close in last hour
   double   R1,R2,R3,PP,S1,S2,S3;         // pivot points
//---
   for(int i=bars_count; i>=0 && !IsStopped(); i--)
     {
      bool is_target=false;
      if(CurrentHourOnly)
        {
         if(TimeHour    (iTime(NULL,0,i)) == TimeHour    (TimeCurrent()) &&
            TimeDay     (iTime(NULL,0,i)) == TimeDay     (TimeCurrent()) &&
            TimeMonth   (iTime(NULL,0,i)) == TimeMonth   (TimeCurrent()) &&
            TimeYear    (iTime(NULL,0,i)) == TimeYear    (TimeCurrent()) &&
            TimeMinute  (iTime(NULL,0,i)) == 0)
            is_target=true;
        }
      else
        {
         if(TimeMinute(iTime(NULL,0,i))==0)
            is_target=true;
        }
      //---   
      if(is_target && last_hour!=TimeHour(iTime(NULL,0,i)) && FindExistingObj(iTime(NULL,0,i))==false)
        {
         last_hour   =TimeHour(iTime(NULL,0,i));
         pre_high    =High[iHighest(NULL,0,MODE_HIGH,period,i+1)];
         pre_low     =Low[iLowest(NULL,0,MODE_LOW, period,i+1)];
         pre_close   =Close[i+1];
         //---
         PP=NormalizeDouble((pre_high+pre_low+pre_close)/3,_Digits);
         R1=NormalizeDouble((2*PP)-pre_low,_Digits);
         S1=NormalizeDouble((2*PP)-pre_high,_Digits);
         R2=NormalizeDouble(PP+(R1-S1),_Digits);
         S2=NormalizeDouble(PP-(R1-S1),_Digits);
         R3=NormalizeDouble(pre_high+(2*(PP-pre_low)),_Digits);
         S3=NormalizeDouble(pre_low-(2*(pre_high-PP)),_Digits);
         //---
         if(PivotMode==Fibonacci)
           {
            double R=NormalizeDouble(pre_high-pre_low,_Digits);
            R3=NormalizeDouble(PP+(R*1.000),_Digits);
            R2=NormalizeDouble(PP+(R*0.618),_Digits);
            R1=NormalizeDouble(PP+(R*0.382),_Digits);
            S1=NormalizeDouble(PP-(R*0.382),_Digits);
            S2=NormalizeDouble(PP-(R*0.618),_Digits);
            S3=NormalizeDouble(PP-(R*1.000),_Digits);
           }
         //---
         datetime    time1=iTime(NULL,0,i);
         datetime    time2=time1+60*60;
         string      obj_time="_"+TimeToStr(time1);
         //--- create rectangle
         if(AreasFilling)
           {
            RectangleCreate(short_name+"_R1_Area"+obj_time,time1,PP,time2,R1,R1AreaColor);
            RectangleCreate(short_name+"_R2_Area"+obj_time,time1,R1,time2,R2,R2AreaColor);
            RectangleCreate(short_name+"_R3_Area"+obj_time,time1,R2,time2,R3,R3AreaColor);
            RectangleCreate(short_name+"_S1_Area"+obj_time,time1,PP,time2,S1,S1AreaColor);
            RectangleCreate(short_name+"_S2_Area"+obj_time,time1,S1,time2,S2,S2AreaColor);
            RectangleCreate(short_name+"_S3_Area"+obj_time,time1,S2,time2,S3,S3AreaColor);
           }
         //--- create level lines
         if(ShowPivotLines)
           {
            TrendCreate(short_name+"_PP"+obj_time,time1,PP,time2,PP,PColor);
            TrendCreate(short_name+"_R1"+obj_time,time1,R1,time2,R1,RColor);
            TrendCreate(short_name+"_R2"+obj_time,time1,R2,time2,R2,RColor);
            TrendCreate(short_name+"_R3"+obj_time,time1,R3,time2,R3,RColor);
            TrendCreate(short_name+"_S1"+obj_time,time1,S1,time2,S1,SColor);
            TrendCreate(short_name+"_S2"+obj_time,time1,S2,time2,S2,SColor);
            TrendCreate(short_name+"_S3"+obj_time,time1,S3,time2,S3,SColor);
           }
         //--- create labels for the level lines
         if(ShowLabels)
           {
            if(PivotMode==Fibonacci)
              {
               TextCreate(short_name+"_PP_Label"+obj_time,time2,PP,"H1 PP",PColor);
               TextCreate(short_name+"_R1_Label"+obj_time,time2,R1,"H1 R1 Fibo",RColor);
               TextCreate(short_name+"_R2_Label"+obj_time,time2,R2,"H1 R2 Fibo",RColor);
               TextCreate(short_name+"_R3_Label"+obj_time,time2,R3,"H1 R3 Fibo",RColor);
               TextCreate(short_name+"_S1_Label"+obj_time,time2,S1,"H1 S1 Fibo",SColor);
               TextCreate(short_name+"_S2_Label"+obj_time,time2,S2,"H1 S2 Fibo",SColor);
               TextCreate(short_name+"_S3_Label"+obj_time,time2,S3,"H1 S3 Fibo",SColor);
              }
            else
              {
               TextCreate(short_name+"_PP_Label"+obj_time,time2,PP,"H1 PP",PColor);
               TextCreate(short_name+"_R1_Label"+obj_time,time2,R1,"H1 R1",RColor);
               TextCreate(short_name+"_R2_Label"+obj_time,time2,R2,"H1 R2",RColor);
               TextCreate(short_name+"_R3_Label"+obj_time,time2,R3,"H1 R3",RColor);
               TextCreate(short_name+"_S1_Label"+obj_time,time2,S1,"H1 S1",SColor);
               TextCreate(short_name+"_S2_Label"+obj_time,time2,S2,"H1 S2",SColor);
               TextCreate(short_name+"_S3_Label"+obj_time,time2,S3,"H1 S3",SColor);
              }
           }
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculate object numbers                                         |
//+------------------------------------------------------------------+
bool FindExistingObj(datetime obj_time)
  {
   string time_str=TimeToStr(obj_time);
   string name;
   if(ObjectsTotal(chart_ID,0,-1)>0)
     {
      for(int i=0; i<ObjectsTotal(); i++)
        {
         name=ObjectName(i);
         if(StringFind(name,short_name,0)<0) continue;
         if(StringFind(name,time_str,0)>=0) return(true);
        }
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+ 
//| Create a trend line by the given coordinates                     | 
//+------------------------------------------------------------------+ 
bool TrendCreate(const string          name="TrendLine",  // line name 
                 datetime              time1=0,           // first point time 
                 double                price1=0,          // first point price 
                 datetime              time2=0,           // second point time 
                 double                price2=0,          // second point price 
                 const color           clr=clrRed)        // line color
  {
//--- set anchor points' coordinates if they are not set 
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- create a trend line by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,0,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   color use_color = clr;
   if(ObjectGetInteger(0,short_name+" btn",OBJPROP_STATE)){
      use_color = clrNONE;
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,use_color);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,LineStyle);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,LineWidth);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Check the values of trend line's anchor points and set default   | 
//| values for empty ones                                            | 
//+------------------------------------------------------------------+ 
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value 
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one 
      time2=temp[0];
     }
//--- if the second point's price is not set, it is equal to the first point's one 
   if(!price2)
      price2=price1;
  }
//+------------------------------------------------------------------+ 
//| Creating Text object                                             | 
//+------------------------------------------------------------------+ 
bool TextCreate(const string            name="Text",              // object name 
                datetime                time=0,                   // anchor point time 
                double                  price=0,                  // anchor point price 
                const string            text="Text",              // the text itself 
                const color             clr=clrRed)               // color 
  {
//--- set anchor point coordinates if they are not set 
   ChangeTextEmptyPoint(time,price);
//--- reset the error value 
   ResetLastError();
//--- create Text object 
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   color use_color = clr;
   if(ObjectGetInteger(0,short_name+" btn",OBJPROP_STATE)){
      use_color = clrNONE;
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,use_color);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,7);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,0.0);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Check anchor point values and set default values                 | 
//| for empty ones                                                   | 
//+------------------------------------------------------------------+ 
void ChangeTextEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar 
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+ 
//| Create rectangle by the given coordinates                        | 
//+------------------------------------------------------------------+ 
bool RectangleCreate(const string          name="Rectangle",  // rectangle name 
                     datetime              time1=0,           // first point time 
                     double                price1=0,          // first point price 
                     datetime              time2=0,           // second point time 
                     double                price2=0,          // second point price 
                     const color           clr=clrRed)        // rectangle color 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- create a rectangle by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,0,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color 
   color use_color = clr;
   if(ObjectGetInteger(0,short_name+" btn",OBJPROP_STATE)){
      use_color = clrNONE;
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,use_color);
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Check the values of rectangle's anchor points and set default    | 
//| values for empty ones                                            | 
//+------------------------------------------------------------------+ 
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value 
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one 
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one 
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+ 
//| Creating Button object                                           | 
//+------------------------------------------------------------------+ 
void CreateButton()
{
   ButtonCreate(NULL,short_name+" btn",0,btn_offset_x,btn_offset_y,btn_width,btn_height,CORNER_LEFT_UPPER,btn_text,"Arial",btn_font_size,btn_font_clr,btn_bg_color,btn_border_clr,false,true,false,false,0);
}
//---
bool ButtonCreate(const long              chart_ID2=0,              // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selectable=true,          //object can be selected        
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=false,             // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
   ResetLastError();
   ObjectCreate(chart_ID2,name,OBJ_BUTTON,sub_window,0,0);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//| Button Event                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if (id == CHARTEVENT_OBJECT_CLICK && sparam==short_name+" btn") 
   { 
      if(ObjectGetInteger(0,short_name+" btn",OBJPROP_STATE))
      {
         show_hide("hide");
      }
      else if(!ObjectGetInteger(0,short_name+" btn",OBJPROP_STATE))
      {
         show_hide("show");
      }
   }
}
//+------------------------------------------------------------------+
//| Show/hide                                                        |
//+------------------------------------------------------------------+
void show_hide(string which)
{
   if(which=="hide"){
      for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
      {
         string objname = ObjectName(iObj);
         if(StringFind(objname,short_name)!=-1)
         {  
            ObjectSet(objname,OBJPROP_COLOR,clrNONE);
         }
      }
   }
   else if(which=="show"){
      for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
      {
         string objname = ObjectName(iObj);
         if(StringFind(objname,short_name)!=-1 && ObjectType(objname)==OBJ_RECTANGLE){
            if(StringFind(objname,"R1_Area")!=-1){ObjectSet(objname,OBJPROP_COLOR,R1AreaColor);}
            if(StringFind(objname,"R2_Area")!=-1){ObjectSet(objname,OBJPROP_COLOR,R2AreaColor);}
            if(StringFind(objname,"R3_Area")!=-1){ObjectSet(objname,OBJPROP_COLOR,R3AreaColor);}
            if(StringFind(objname,"S1_Area")!=-1){ObjectSet(objname,OBJPROP_COLOR,S1AreaColor);}
            if(StringFind(objname,"S2_Area")!=-1){ObjectSet(objname,OBJPROP_COLOR,S2AreaColor);}
            if(StringFind(objname,"S3_Area")!=-1){ObjectSet(objname,OBJPROP_COLOR,S3AreaColor);}
         }
         if(StringFind(objname,short_name)!=-1 && (ObjectType(objname)==OBJ_TREND || ObjectType(objname)==OBJ_TEXT)){
            if(StringFind(objname,"PP")!=-1){ObjectSet(objname,OBJPROP_COLOR,PColor);}
            if(StringFind(objname,"R1")!=-1){ObjectSet(objname,OBJPROP_COLOR,RColor);}
            if(StringFind(objname,"R2")!=-1){ObjectSet(objname,OBJPROP_COLOR,RColor);}
            if(StringFind(objname,"R3")!=-1){ObjectSet(objname,OBJPROP_COLOR,RColor);}
            if(StringFind(objname,"S1")!=-1){ObjectSet(objname,OBJPROP_COLOR,SColor);}
            if(StringFind(objname,"S2")!=-1){ObjectSet(objname,OBJPROP_COLOR,SColor);}
            if(StringFind(objname,"S3")!=-1){ObjectSet(objname,OBJPROP_COLOR,SColor);}
         }
      }
   }
}


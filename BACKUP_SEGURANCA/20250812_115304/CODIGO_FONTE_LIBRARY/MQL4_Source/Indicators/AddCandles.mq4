//+------------------------------------------------------------------+
//|                                                   AddCandles.mq4 |
//|                                         Copyright 2014, RasoulFX |
//|                                     http://rasoulfx.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, RasoulFX"
#property link      "http://rasoulfx.blogspot.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//--- input parameters
input string   ValidTimeFrames="H1(60),H2(120),H3(180),H4(240),H6(360),H8(480),H12(720)";
input int      TimeFrameInMinutes=480;
input color    UpCandleColor=clrGreen;
input color    DownCandleColor=clrRed;
input color    DojiCandleColor=clrBlue;
input int      BrokerHourDiffGMT=0;
input int      NumCandlesToRedraw=200;
input int      Width=3;
//--- global parameters
int obj_counter = 0;
int groups[];
int numGroups = 0;
int numHoursInGroup = 0;
int maxBarsToCheck = 0;
bool newCandle = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   if(Period() != PERIOD_H1)
      {Comment("This indicator works in H1 Time Frame!");return(INIT_FAILED);}
   if(MathMod(TimeFrameInMinutes,Period())!=0)
      {Comment("Valid Time Frames are "+ValidTimeFrames);return(INIT_FAILED);}
   numHoursInGroup = TimeFrameInMinutes/Period();
   numGroups = 24/numHoursInGroup;
   ArrayResize(groups, numGroups);
   for(int i=0; i<numGroups; i++)
   {
      int hGMT0 = i*numHoursInGroup;
      int hBroker = hGMT0+BrokerHourDiffGMT;
      if(hBroker >= 24) hBroker -= 24;
      else if(hBroker < 0) hBroker += 24;
      groups[i]=hBroker;
   }
   maxBarsToCheck=(NumCandlesToRedraw+1)*numHoursInGroup;
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- indicator buffers mapping
   for(int i=0; i<obj_counter; i++)
      ObjectDelete("obj"+IntegerToString(i));
   Comment("");
//---   
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
//---
   static bool firstTick = true;
   if(firstTick)
   {
      for(int i=maxBarsToCheck; i>=0; i--)
      {
         int h = TimeHour(Time[i]);
         for(int g=0; g<numGroups; g++)
            if(h == groups[g])
            {
               DrawClosedCandle(i, g);            
               break;
            }
      }   
      newCandle = true;   
      firstTick = false;
   }
   
   for(int i=0; i<numHoursInGroup; i++)
   {
      int h = TimeHour(Time[i]);
      for(int g=0; g<numGroups; g++)
         if(h == groups[g])
         {
            if(i == 0) newCandle = true;            
            DrawCurrentCandle(i, g);            
            break;
         }      
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Custom indicator Candle Draw function                            |
//+------------------------------------------------------------------+
void DrawClosedCandle(int i, int g)
{
   if(i-numHoursInGroup+1 < 0) return;
   double highest = -1e20;
   double lowest  = +1e20;
   double open    = Open[i];
   double close   = Close[i-numHoursInGroup+1];
   color clr = DojiCandleColor;
   double highStart = open;
   double lowStart = close;
   if(open > close){clr = DownCandleColor;}
   if(close > open){clr = UpCandleColor; highStart = close; lowStart = open;}
   
   for(int c=0; c<numHoursInGroup; c++)
   {
      if(High[i-c] > highest) highest = High[i-c];
      if(Low[i-c] < lowest) lowest = Low[i-c];      
   }
   //Comment("highest="+DoubleToStr(highest)+" lowest="+DoubleToStr(lowest));
   string boxName = "obj"+IntegerToString(obj_counter); obj_counter++;
   ObjectCreate(boxName,OBJ_RECTANGLE,0,Time[i],open,Time[i-numHoursInGroup+1],close); 
   ObjectSet(boxName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(boxName,OBJPROP_COLOR,clr);
   ObjectSet(boxName,OBJPROP_BACK,false);
   ObjectSet(boxName,OBJPROP_WIDTH,Width);
   
   datetime meanTime = (Time[i]+Time[i-numHoursInGroup+1])/2;   
   string highStickName = "obj"+IntegerToString(obj_counter); obj_counter++;
   string lowStickName = "obj"+IntegerToString(obj_counter); obj_counter++;
      
   ObjectCreate(highStickName,OBJ_TREND,0,meanTime,highStart,meanTime,highest);
   ObjectSet(highStickName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(highStickName,OBJPROP_RAY,false);
   ObjectSet(highStickName,OBJPROP_COLOR,clr);
   ObjectSet(highStickName,OBJPROP_WIDTH,Width);
   ObjectCreate(lowStickName,OBJ_TREND,0,meanTime,lowStart,meanTime,lowest);
   ObjectSet(lowStickName,OBJPROP_STYLE,STYLE_SOLID);      
   ObjectSet(lowStickName,OBJPROP_COLOR,clr);
   ObjectSet(lowStickName,OBJPROP_RAY,false);
   ObjectSet(lowStickName,OBJPROP_WIDTH,Width);   
}

//+------------------------------------------------------------------+
//| Custom indicator Candle Draw function                            |
//+------------------------------------------------------------------+
void DrawCurrentCandle(int i, int g)
{   
   double highest = -1e20;
   double lowest  = +1e20;
   double open    = Open[i];
   double close   = Close[0];
   color clr = DojiCandleColor;
   double highStart = open;
   double lowStart = close;
   if(open > close){clr = DownCandleColor;}
   if(close > open){clr = UpCandleColor; highStart = close; lowStart = open;}
   
   for(int c=0; c<numHoursInGroup; c++)
   {
      if(i-c < 0) break;
      if(High[i-c] > highest) highest = High[i-c];
      if(Low[i-c] < lowest) lowest = Low[i-c];      
   }
   
   if(!newCandle)
   {
      ObjectDelete("obj"+IntegerToString(obj_counter-1));
      ObjectDelete("obj"+IntegerToString(obj_counter-2));
      ObjectDelete("obj"+IntegerToString(obj_counter-3));
      obj_counter -= 3;
      WindowRedraw();
   }
   string boxName = "obj"+IntegerToString(obj_counter); obj_counter++;
   string highStickName = "obj"+IntegerToString(obj_counter); obj_counter++;
   string lowStickName = "obj"+IntegerToString(obj_counter); obj_counter++;
   
   int nextTime = int(Time[i]+(numHoursInGroup-1)*60*60);
   ObjectCreate(boxName,OBJ_RECTANGLE,0,Time[i],open,nextTime,close); 
   ObjectSet(boxName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(boxName,OBJPROP_COLOR,clr);
   ObjectSet(boxName,OBJPROP_BACK,false);
   ObjectSet(boxName,OBJPROP_WIDTH,Width);
    
   //Comment("nextTime="+TimeToString(nextTime));
   int meanTime = int(MathRound((Time[i] + nextTime)/2));
   ObjectCreate(highStickName,OBJ_TREND,0,meanTime,highStart,meanTime,highest);
   ObjectSet(highStickName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(highStickName,OBJPROP_RAY,false);
   ObjectSet(highStickName,OBJPROP_COLOR,clr);
   ObjectSet(highStickName,OBJPROP_WIDTH,Width);
   ObjectCreate(lowStickName,OBJ_TREND,0,meanTime,lowStart,meanTime,lowest);
   ObjectSet(lowStickName,OBJPROP_STYLE,STYLE_SOLID);      
   ObjectSet(lowStickName,OBJPROP_COLOR,clr);
   ObjectSet(lowStickName,OBJPROP_RAY,false);
   ObjectSet(lowStickName,OBJPROP_WIDTH,Width);   
   
   newCandle = false;
}

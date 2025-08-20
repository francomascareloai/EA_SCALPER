//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+
// modified by banzai from Mario Jemic template @
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69820
// July 10th, 2020
// not for sale, rent, auction, nor lease

#property link "http://www.fxtools.info"
#property  indicator_chart_window
#property  indicator_buffers  2
#property  indicator_color1  clrMidnightBlue
#property  indicator_color2  clrFireBrick
 
extern int                Fib_Period            = 120; 
extern bool               Show_StartLine        = false;
extern bool               Show_EndLine          = false;
extern bool               Show_Channel          = false;
extern int                Fib_Style             = 5;
extern color              Fib_Color             = clrDarkGoldenrod;
extern color              StartLine_Color       = clrRoyalBlue; 
extern color              EndLine_Color         = clrFireBrick; 
extern color              BuyZone_Color         = clrMidnightBlue;
extern color              SellZone_Color        = clrFireBrick;
//+------------------------------------------------------------------------------------------------------------------+
//template code start1
//button_note1,btn_corner,btn_text,btn_Font,btn_FontSize,btn_text_color,btn_background_color,btn_border_color,button_x,button_y,btn_Width,btn_Height,button_note2,
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text              = "Fibo";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                             //btn__font size
extern color              btn_text_color        = clrWhite;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 20;                                     //btn__x
extern int                button_y              = 13;                                     //btn__y
extern int                btn_Width             = 60;                                 //btn__width
extern int                btn_Height            = 20;                                //btn__height
extern string             button_note2          = "------------------------------";
bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
int WorkTime=0,Periods=0;
//template code end1
double WWBuffer1[];
double WWBuffer2[];
 
double level_array[10]={0,0.236,0.382,0.5,0.618,0.764,1,1.618,2.618,4.236};
string leveldesc_array[13]={"0","23.6%","38.2%","50%","61.8%","76.4%","100%","161.8%","261.80%","423.6%"};
int level_count;
string level_name;
string StartLine = "Start Line";
string EndLine = "End Line";
//+------------------------------------------------------------------+
//template code start2
string GenerateIndicatorName(const string target) //don't change anything here
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//+------------------------------------------------------------------+
class VisibilityCotroller //don't change anything here
{
   string buttonId, visibilityId;
   bool show_data, recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y) //don't change anything here
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
      ObjectSetInteger(0,buttonId,OBJPROP_YDISTANCE, button_y);
      ObjectSetInteger(0,buttonId,OBJPROP_XDISTANCE, button_x);

// put init() here
   IndicatorBuffers(2);
   if (Show_Channel)
   {
     SetIndexStyle(0,DRAW_LINE,1);
     SetIndexStyle(1,DRAW_LINE,1);
   
     SetIndexLabel(0, "High");
     SetIndexLabel(1, "Low");
   
     SetIndexBuffer(0, WWBuffer1);
     SetIndexBuffer(1, WWBuffer2);
   }
   IndicatorDigits(Digits+2);
   
   IndicatorShortName("AutoFib TradeZones");
   
   ObjectCreate("FibLevels", OBJ_FIBO, 0, Time[0],High[0],Time[0],Low[0]);
   ObjectCreate("BuyZone",   OBJ_RECTANGLE, 0,0,0,0);
   ObjectCreate("SellZone",  OBJ_RECTANGLE, 0,0,0,0);
   
   if (Show_StartLine)
        {if (ObjectFind(StartLine)==-1)
           {
            ObjectCreate(StartLine,OBJ_VLINE,0,Time[Fib_Period],Close[0]);
            ObjectSet   (StartLine,OBJPROP_COLOR,StartLine_Color);
           }
        } 
    if (Show_EndLine)
        {if (ObjectFind(EndLine)==-1)
           {
            ObjectCreate(EndLine,OBJ_VLINE,0,Time[0],Close[0]);
            ObjectSet(EndLine,OBJPROP_COLOR,EndLine_Color);
           }
        } 
   } //void Init
//+------------------------------------------------------------------+
   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
      
      //put deinit () here
      ObjectDelete("FibLevels");
      ObjectDelete("BuyZone");
      ObjectDelete("SellZone");
   }
//+------------------------------------------------------------------+
   bool HandleButtonClicks() //don't change anything here
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }
//+------------------------------------------------------------------+
   bool IsRecalcNeeded() //don't change anything here
   {
      return recalc;
   }
//+------------------------------------------------------------------+
   void ResetRecalc() //don't change anything here
   {
      recalc = false;
   }
//+------------------------------------------------------------------+
   bool IsVisible() //don't change anything here
   {
      return show_data;
   }
//+------------------------------------------------------------------+
private: //don't change anything here much
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};
VisibilityCotroller visibility;
//+------------------------------------------------------------------+
int init()
  {
   IndicatorName = GenerateIndicatorName("AutoFibu"); //don't forget to change the name here
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
// Enter another different name below
   visibility.Init("show_hide_AutoFibu", IndicatorName, btn_text, button_x, button_y);

//DON'T put the init function here

   return 0;
};
//+------------------------------------------------------------------+
int deinit()  
  {
   visibility.DeInit();
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    
    //put the deinit function here
           ObjectDelete("FibLevels");
           ObjectDelete("BuyZone");
           ObjectDelete("SellZone");
    
   return(0);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
      start();
}
//+------------------------------------------------------------------+
//template end2
int init2() {
   IndicatorBuffers(2);
if (Show_Channel)
   {
   SetIndexStyle(0,DRAW_LINE,1);
   SetIndexStyle(1,DRAW_LINE,1);
   
   SetIndexLabel(0, "High");
   SetIndexLabel(1, "Low");
   
   SetIndexBuffer(0, WWBuffer1);
   SetIndexBuffer(1, WWBuffer2);
   }
   IndicatorDigits(Digits+2);
   
   IndicatorShortName("AutoFib TradeZones");
   
   ObjectCreate("FibLevels", OBJ_FIBO, 0, Time[0],High[0],Time[0],Low[0]);
   ObjectCreate("BuyZone", OBJ_RECTANGLE, 0,0,0,0);
   ObjectCreate("SellZone", OBJ_RECTANGLE, 0,0,0,0);
   
   if (Show_StartLine)
        {if (ObjectFind(StartLine)==-1)
           {
            ObjectCreate(StartLine,OBJ_VLINE,0,Time[Fib_Period],Close[0]);
            ObjectSet(StartLine,OBJPROP_COLOR,StartLine_Color);
           }
        } 
    if (Show_EndLine)
        {if (ObjectFind(EndLine)==-1)
           {
            ObjectCreate(EndLine,OBJ_VLINE,0,Time[0],Close[0]);
            ObjectSet(EndLine,OBJPROP_COLOR,EndLine_Color);
           }
        } 
   return(0);
}
//+------------------------------------------------------------------+
int start2() {
 
 //Start Line -------------------------------------------
   int BarShift;
  if (Show_StartLine)
  {   
   datetime HLineTime=ObjectGet(StartLine,OBJPROP_TIME1);

   if (HLineTime>=Time[0]) {BarShift=0;}
     BarShift=iBarShift(NULL,0,HLineTime);
  }   
   else if (!Show_StartLine){BarShift=0;}
   if (ObjectFind(StartLine)==-1) {BarShift=0;}
   
 //End Line -------------------------------------------
   int BarShift2;
  if (Show_EndLine)
  {   
   datetime HLine2Time=ObjectGet(EndLine,OBJPROP_TIME1);

   if (HLine2Time>=Time[0]) {BarShift2=0;}
     BarShift2=iBarShift(NULL,0,HLine2Time);
  }   
   else if (!Show_EndLine){BarShift2=0;}
   if (ObjectFind(EndLine)==-1) {BarShift2=0;}   
//----------------------------------------------------------
 
   double SellZoneHigh,BuyZoneLow;
   if (Show_StartLine)
    {
    SellZoneHigh = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,BarShift-BarShift2,BarShift2+1));
    BuyZoneLow = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,BarShift-BarShift2,BarShift2+1));
    }
      if (!Show_StartLine)
    {
    SellZoneHigh = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,Fib_Period,1));
    BuyZoneLow = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,Fib_Period,1));
    } 
   double PriceRange = SellZoneHigh - BuyZoneLow; 
   double BuyZoneHigh = BuyZoneLow + (0.236*PriceRange);
   double SellZoneLow = SellZoneHigh - (0.236*PriceRange);
   datetime StartZoneTime =Time[Fib_Period];
   datetime EndZoneTime =Time[0]+Time[0];
   
   level_count=ArraySize(level_array);
   
   int    counted_bars=IndicatorCounted();
   int    limit,i;
   
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=limit-1; i>=0; i--) {
 
      WWBuffer1[i] = getPeriodHigh(Fib_Period,i);
      WWBuffer2[i] = getPeriodLow(Fib_Period,i);
      
      if (Show_StartLine)
      {ObjectSet("FibLevels", OBJPROP_TIME1, Time[BarShift]);
       ObjectSet("FibLevels", OBJPROP_TIME2, Time[BarShift2]);}
      if (!Show_StartLine)
      {ObjectSet("FibLevels", OBJPROP_TIME1, StartZoneTime);}
      ObjectSet("FibLevels", OBJPROP_TIME2, Time[0]);
      if (Open[Fib_Period] < Open[0]) // Up
      { 
        if (Show_StartLine)
         {
         ObjectSet("FibLevels", OBJPROP_PRICE1, SellZoneHigh);
         ObjectSet("FibLevels", OBJPROP_PRICE2, BuyZoneLow);
         }
        if (!Show_StartLine)
         {
         ObjectSet("FibLevels", OBJPROP_PRICE1, getPeriodHigh(Fib_Period,i));
         ObjectSet("FibLevels", OBJPROP_PRICE2, getPeriodLow(Fib_Period,i));
         } 
      } else {
        if (Show_StartLine)
         {
         ObjectSet("FibLevels", OBJPROP_PRICE1, BuyZoneLow);
         ObjectSet("FibLevels", OBJPROP_PRICE2, SellZoneHigh);
         }
        if (!Show_StartLine)
         {
         ObjectSet("FibLevels", OBJPROP_PRICE1, getPeriodLow(Fib_Period,i));
         ObjectSet("FibLevels", OBJPROP_PRICE2, getPeriodHigh(Fib_Period,i));
         }
      }
      ObjectSet("FibLevels", OBJPROP_LEVELCOLOR, Fib_Color);
      ObjectSet("FibLevels", OBJPROP_STYLE, Fib_Style);
      ObjectSet("FibLevels", OBJPROP_FIBOLEVELS, level_count);
         for(int j=0; j<level_count; j++)
      {
      ObjectSet("FibLevels", OBJPROP_FIRSTLEVEL+j, level_array[j]);
      ObjectSetFiboDescription("FibLevels",j,leveldesc_array[j]);
      }
   
      if (Show_StartLine)
      {ObjectSet("BuyZone", OBJPROP_TIME2, Time[BarShift]);
       ObjectSet("BuyZone", OBJPROP_TIME1, Time[BarShift2]);}
      if (!Show_StartLine)
      {ObjectSet("BuyZone", OBJPROP_TIME2, StartZoneTime);}
      ObjectSet("BuyZone", OBJPROP_TIME1, EndZoneTime);
      ObjectSet("BuyZone", OBJPROP_PRICE1, BuyZoneLow);
      ObjectSet("BuyZone", OBJPROP_PRICE2, BuyZoneHigh);
      ObjectSet("BuyZone", OBJPROP_COLOR, BuyZone_Color);
      
      if (Show_StartLine)
      {ObjectSet("SellZone", OBJPROP_TIME2, Time[BarShift]);
      ObjectSet("SellZone", OBJPROP_TIME1, Time[BarShift2]);}
      if (!Show_StartLine)
      {ObjectSet("SellZone", OBJPROP_TIME2, StartZoneTime);}
      ObjectSet("SellZone", OBJPROP_TIME1, EndZoneTime);
      ObjectSet("SellZone", OBJPROP_PRICE1, SellZoneLow);
      ObjectSet("SellZone", OBJPROP_PRICE2, SellZoneHigh);
      ObjectSet("SellZone", OBJPROP_COLOR, SellZone_Color);
   }
   return(0);
}
//+---------------------------------------------------------------------+
int start()
{
//template start3
   visibility.HandleButtonClicks();
   visibility.ResetRecalc();
   
   if (visibility.IsVisible())
   {
//template end3

//now, put the start() here
      start2();
//template start4
      if( (WorkTime != Time[0]) || (Periods != Period()) ) 
      {
         if (show_data) // on button
         {
           init2();
           start2();
         }
         else //off button
         {
           ObjectDelete("FibLevels");
           ObjectDelete("BuyZone");
           ObjectDelete("SellZone");
         } // else off button
      } //if( (WorkTime != Time[0]) || (Periods != Period()) )
   } //if (visibility.IsVisible())
   else //again, copy the off button function here
   {
           ObjectDelete("FibLevels");
           ObjectDelete("BuyZone");
           ObjectDelete("SellZone");
   } //else
//template end4  
   return(0);
}
//+---------------------------------------------------------------------+
double getPeriodHigh(int period, int pos) 
{
   int i;
   double buffer = 0;
   for (i=pos;i<=pos+period;i++) 
   {
       if (High[i] > buffer) 
         {
            buffer = High[i];
         }
       else {
         if (Open[i] > Close[i]) // Down
         { 
            if (Open[i] > buffer) 
            {
               buffer = Open[i];
            }
         } 
      }
   }
   return (buffer);
}
//+---------------------------------------------------------------------+
double getPeriodLow(int period, int pos) {
   int i;
   double buffer = 100000;
   for (i=pos;i<=pos+period;i++) 
   {
         if (Low[i] < buffer) 
         {
            buffer = Low[i];
         }
       else {
         if (Open[i] > Close[i]) // Down
         {
            if (Close[i] < buffer) 
            {
               buffer = Close[i];
            }
         } else {
            if (Open[i] < buffer) {
               buffer = Open[i];
            }
         }
      }
   }
   return (buffer);
}
//+---------------------------------------------------------------------+

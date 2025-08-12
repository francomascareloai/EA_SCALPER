// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68338
// ma_with_button.mq4
//+------------------------------------------------------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------------------------------------------------------+
// modified by banzai from Mario Jemic template 
// July 29th, 2020
// not for sale, rent, auction, nor lease
//+------------------------------------------------------------------+
//|                                                    Renko nmc.mq4 |
//+------------------------------------------------------------------+

#property indicator_chart_window
//#property strict 
#property indicator_buffers 2
#property indicator_color1 clrRoyalBlue
#property indicator_color2 clrMaroon
#property indicator_width1 0
#property indicator_width2 0

extern double BoxSize = 10.0;
//template code start1
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text              = "Renko";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                             //btn__font size
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = clrRed;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 20;                                     //btn__x
extern int                button_y              = 13;                                     //btn__y
extern int                btn_Width             = 60;                                 //btn__width
extern int                btn_Height            = 20;                                //btn__height
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];

//+------------------------------------------------------------------------------------------------------------------+
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
//+------------------------------------------------------------------------------------------------------------------+
string buttonId;

int OnInit()
{
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "Renko2020";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);

// put init() here
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, Buffer1);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, Buffer2);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, Buffer3);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, Buffer4);
   SetIndexLabel(0, "Up");
   SetIndexLabel(1, "Dn");

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
//don't change anything here
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (ChartID(),buttonID);
      ObjectCreate    (ChartID(),buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (ChartID(),buttonID,OBJPROP_FONT,font);
      ObjectSetString (ChartID(),buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YDISTANCE,9999);
}
//+------------------------------------------------------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

//put deinit() here

	return(0);
}
//+------------------------------------------------------------------------------------------------------------------+
//don't change anything here
bool recalc = true;

void handleButtonClicks()
{
   if (ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
}
//+------------------------------------------------------------------------------------------------------------------+
int start()
{
   handleButtonClicks();
   recalc = false;
   //put start () here
  double Hi;
   double Lo;
   double result;
   double barsize;
   double digits;
   int i,counted_bars=IndicatorCounted();
//   for(i = MathMax(rates_total-1-prev_calculated,2); i>=0; i--)
   for(i = MathMax(Bars-counted_bars,Bars-1); i>=0; i--)
  
   Buffer1[Bars] = Close[Bars];
   Buffer2[Bars] = Close[Bars];
   Buffer3[Bars] = Close[Bars];
   Buffer4[Bars] = Close[Bars];
   if (Digits == 5 || Digits == 3) digits = NormalizeDouble(10.0 * BoxSize, Digits);
   else digits = NormalizeDouble(BoxSize, Digits);
   double box = NormalizeDouble(Point * digits, Digits);
   int bars = Bars - i;
   for (int k = bars; k >= 0; k--) {
      Hi = NormalizeDouble(High[k] - (Buffer3[k + 1]) - box, Digits);
      Lo = NormalizeDouble(Low[k] - (Buffer4[k + 1]) + box, Digits);
      if (Hi >= 0.0) {
         barsize = NormalizeDouble((High[k] - (Buffer3[k + 1])) / box, Digits);
         result = NormalizeDouble(MathFloor(barsize), Digits);
         Buffer3[k] = Buffer3[k + 1] + box * result;
         Buffer4[k] = Buffer3[k] - box * result;
         Buffer1[k] = Buffer3[k];
         Buffer2[k] = Buffer4[k];
         Buffer4[k] = Buffer3[k] - box;
      } else {
         if (Lo <= 0.0) {
            barsize = NormalizeDouble((Buffer4[k + 1] - Low[k]) / box, Digits);
            result = NormalizeDouble(MathFloor(barsize), Digits);
            Buffer4[k] = Buffer4[k + 1] - box * result;
            Buffer3[k] = Buffer4[k] + box * result;
            Buffer2[k] = Buffer3[k];
            Buffer1[k] = Buffer4[k];
            Buffer3[k] = Buffer4[k] + box;
         } else {
            Buffer3[k] = Buffer3[k + 1];
            Buffer4[k] = Buffer4[k + 1];
            if (Buffer1[k + 1] > Buffer2[k + 1]) {
               Buffer1[k] = Buffer1[k + 1];
               Buffer2[k] = Buffer1[k] - box;
            }
            if (Buffer2[k + 1] > Buffer1[k + 1]) {
               Buffer1[k] = Buffer1[k + 1];
               Buffer2[k] = Buffer1[k] + box;
            }
         }
      }
   }
   
      if (show_data)
         {
         ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_ON_color);
       for (int banzai=0; banzai<2; banzai++)
           SetIndexStyle(banzai,DRAW_HISTOGRAM);
         }
      else
      {
       ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_OFF_color);
       for (int banzai=0; banzai<2; banzai++)
           SetIndexStyle(banzai,DRAW_NONE);
      }
   return(0);
}
//+------------------------------------------------------------------------------------------------------------------+

// https://forex-station.com/viewtopic.php?p=1295478806#p1295478806 //button code1
// https://forex-station.com/viewtopic.php?p=1295478883#p1295478883 //button code2
// ZigZag Indicator by ChatGPT
// not for sale, rent, nor auction

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrRed
#property indicator_color2 clrBlue

 // Awesome Oscillator Indicator
#property indicator_color3 clrLime
#property indicator_color4 clrRed

extern int ExtDepth = 12;
extern int ExtDeviation = 5;
extern int ExtBackstep = 3;
extern int nBars = 150;
extern int fast_ma_period = 5;
extern int slow_ma_period = 34;

//Forex-Station button template start41; copy and paste
extern string             button_note1_         = "------------------------------";
extern int                btn_Subwindow         = 0;                               // What window to put the button on.  If <0, the button will use the same sub-window as the indicator.
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER;               // button corner on chart for anchoring
extern string             btn_text              = "ZigZag AO";                     // a button name
extern string             btn_Font              = "Arial";                         // button font name
extern int                btn_FontSize          = 9;                               // button font size               
extern color              btn_text_ON_color     = clrLime;                         // ON color when the button is turned on
extern color              btn_text_OFF_color    = clrRed;                          // OFF color when the button is turned off
extern color              btn_background_color  = clrDimGray;                      // background color of the button
extern color              btn_border_color      = clrBlack;                        // border color the button
extern int                button_x              = 20;                              // x coordinate of the button     
extern int                button_y              = 25;                              // y coordinate of the button     
extern int                btn_Width             = 80;                              // button width
extern int                btn_Height            = 20;                              // button height
extern string             UniqueButtonID        = "ZigZagAO";                      // Unique ID for each button        
extern string             button_note2          = "------------------------------";
bool show_data, recalc=false;
string IndicatorObjPrefix, buttonId;
//Forex-Station button template end41; copy and paste

double ExtMapBuffer[], ExtMapBuffer2[], fast_ma[], slow_ma[], ao[];
//+------------------------------------------------------------------------------------------------------------------+
//Forex-Station button template start42; copy and paste
int OnInit()
{
   IndicatorDigits(Digits);
   IndicatorObjPrefix = "_" + btn_text + "_";
      
   // The leading "_" gives buttonId a *unique* prefix.  Furthermore, prepending the swin is usually unique unless >2+ of THIS indy are displayed in the SAME sub-window. (But, if >2 used, be sure to shift the buttonId position)
   buttonId = "_" + UniqueButtonID + IndicatorObjPrefix + "_BT_";
   if (ObjectFind(buttonId)<0) 
      createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);

   init2();

   show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
   
   if (show_data) ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color); 
   else ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
void createButton(string buttonID,string buttonText,int width2,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,btn_Subwindow,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width2);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      // Upon creation, set the initial state to "true" which is "on", so one will see the indicator by default
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, true);
}
//+------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason) 
{
   // If just changing a TF', the button need not be deleted, therefore the 'OBJPROP_STATE' is also preserved.
   if(reason != REASON_CHARTCHANGE) ObjectDelete(buttonId);
}
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // If another indy on the same chart has enabled events for create/delete/mouse-move, just skip this events up front because they aren't
   //    needed, AND in the worst case, this indy might cause MT4 to hang!!  Skipping the events seems to help, along with other (major) changes to the code below.
   if(id==CHARTEVENT_OBJECT_CREATE || id==CHARTEVENT_OBJECT_DELETE) return; // This appears to make this indy compatible with other programs that enabled CHART_EVENT_OBJECT_CREATE and/or CHART_EVENT_OBJECT_DELETE
   if(id==CHARTEVENT_MOUSE_MOVE    || id==CHARTEVENT_MOUSE_WHEEL)   return; // If this, or another program, enabled mouse-events, these are not needed below, so skip it unless actually needed. 

   if (id==CHARTEVENT_OBJECT_CLICK && sparam == buttonId)
   {
      show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
      
      if (show_data)
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color); 
         SetIndexStyle(0, DRAW_SECTION);
         SetIndexStyle(1, DRAW_SECTION);
         SetIndexStyle(2, DRAW_HISTOGRAM); // Draw style for AO
         SetIndexStyle(3, DRAW_HISTOGRAM); // Draw style for AO
         // Is it a problem to call 'start()' ??  Possibly it makes no difference, but now calling "mystart()" instead of "start()"; and "start()" simply runs "mystart()", so should be same as before.
         recalc=true;
         mystart();
      }
      else
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
         for (int ForexStation2=0; ForexStation2<indicator_buffers; ForexStation2++)
              SetIndexStyle(ForexStation2,DRAW_NONE);
      }
   }
}
//Forex-Station button template end42; copy and paste
//+------------------------------------------------------------------------------------------------------------------+
int init2() {
    // ZigZag Indicator
    IndicatorBuffers(4);  // change here to 4
    SetIndexStyle(0, DRAW_SECTION);
    SetIndexStyle(1, DRAW_SECTION);
    SetIndexBuffer(0, ExtMapBuffer);
    SetIndexBuffer(1, ExtMapBuffer2);
    SetIndexEmptyValue(0, 0.0);
    SetIndexEmptyValue(1, 0.0);
    ArraySetAsSeries(ExtMapBuffer, true);
    ArraySetAsSeries(ExtMapBuffer2, true);
    IndicatorShortName("ZigZag(" + ExtDepth + "," + ExtDeviation + "," + ExtBackstep + ")");
     // Awesome Oscillator Indicator
    SetIndexStyle(2, DRAW_HISTOGRAM); // Draw style for AO
    SetIndexStyle(3, DRAW_HISTOGRAM); // Draw style for AO
    SetIndexBuffer(2, fast_ma);
    SetIndexBuffer(3, slow_ma);
     IndicatorDigits(MarketInfo(_Symbol, MODE_DIGITS) + 1);
    return (0);
}
//+------------------------------------------------------------------------------------------------------------------+
int start() {return(mystart()); }
//+------------------------------------------------------------------------------------------------------------------+
int mystart()
  {
   if (show_data)
      {
        int limit, counted_bars=IndicatorCounted();
        if(recalc) 
        {
           // If a button goes from off-to-on, everything must be recalculated.  The 'recalc' variable is used as a trigger to do this.
           counted_bars = 0;
           recalc=false;
        }
        // ZigZag
        ZigZag(counted_bars, limit);
        // Awesome Oscillator
        AwesomeOscillator(counted_bars, limit);
      } //if (show_data)  
     return(0);
}
//+------------------------------------------------------------------------------------------------------------------+
 void ZigZag(int counted_bars, int &limit) {
    // ZigZag code
  int shift, back, lasthighpos, lastlowpos, LoopBegin, k;
  double val, res;
  double curlow, curhigh, lasthigh, lastlow;
   if (nBars == 0)
    LoopBegin = Bars - ExtDepth;
  else
    LoopBegin = nBars;
  LoopBegin = MathMin(Bars - ExtDepth, LoopBegin);
   for (shift = LoopBegin; shift >= 0; shift--) {
    val = Low[Lowest(NULL, 0, MODE_LOW, ExtDepth, shift)];
    if (val == lastlow)
      val = 0.0;
    else {
      lastlow = val;
      if ((Low[shift] - val) > (ExtDeviation * Point))
        val = 0.0;
      else {
        for (back = 1; back <= ExtBackstep; back++) {
          res = ExtMapBuffer[shift + back];
          if ((res != 0) && (res > val))
            ExtMapBuffer[shift + back] = 0.0;
        }
      }
    }
    ExtMapBuffer[shift] = val;
    val = High[Highest(NULL, 0, MODE_HIGH, ExtDepth, shift)];
    if (val == lasthigh)
      val = 0.0;
    else {
      lasthigh = val;
      if ((val - High[shift]) > (ExtDeviation * Point))
        val = 0.0;
      else {
        for (back = 1; back <= ExtBackstep; back++) {
          res = ExtMapBuffer2[shift + back];
          if ((res != 0) && (res < val))
            ExtMapBuffer2[shift + back] = 0.0;
        }
      }
    }
    ExtMapBuffer2[shift] = val;
  }
  lasthigh = -1;
  lasthighpos = -1;
  lastlow = -1;
  lastlowpos = -1;
   for (shift = Bars - ExtDepth; shift >= 0; shift--) {
    curlow = ExtMapBuffer[shift];
    curhigh = ExtMapBuffer2[shift];
    if ((curlow == 0) && (curhigh == 0))
      continue;
     if (curhigh != 0) {
      if (lasthigh > 0) {
        if (lasthigh < curhigh)
          ExtMapBuffer2[lasthighpos] = 0;
        else
          ExtMapBuffer2[shift] = 0;
      }
      if (lasthigh < curhigh || lasthigh < 0) {
        lasthigh = curhigh;
        lasthighpos = shift;
      }
      lastlow = -1;
    }
    if (curlow != 0) {
      if (lastlow > 0) {
        if (lastlow > curlow)
          ExtMapBuffer[lastlowpos] = 0;
        else
          ExtMapBuffer[shift] = 0;
      }
      if ((curlow < lastlow) || (lastlow < 0)) {
        lastlow = curlow;
        lastlowpos = shift;
      }
      lasthigh = -1;
    }
  }
   for (shift = Bars - 1; shift >= 0; shift--) {
    if (shift >= Bars - ExtDepth) {
      ExtMapBuffer[shift] = 0.0;
      k = 0;
    } else {
      res = ExtMapBuffer2[shift];
      if (res != 0.0)
        ExtMapBuffer[shift] = res;
    }
  }
}
//+------------------------------------------------------------------------------------------------------------------+
 void AwesomeOscillator(int counted_bars, int &limit) {
  if (counted_bars < 0) return;
  if (counted_bars > 0) counted_bars--;
  limit = Bars - counted_bars;
   for (int i = limit; i >= 0; i--)
  {
      fast_ma[i] = iMA(NULL, 0, fast_ma_period, 0, MODE_SMMA, PRICE_MEDIAN, i);
      slow_ma[i] = iMA(NULL, 0, slow_ma_period, 0, MODE_SMMA, PRICE_MEDIAN, i);
      ao[i] = fast_ma[i] - slow_ma[i];
  }
}
//+------------------------------------------------------------------------------------------------------------------+

// https://forex-station.com/viewtopic.php?p=1295478806#p1295478806 button code
// https://forex-station.com/viewtopic.php?p=1295478883#p1295478883 button code
//+------------------------------------------------------------------+
//|                                3 Tier London Breakout V.3.3.mq4  |
//+------------------------------------------------------------------+


#property copyright "by Squalou and mer071898"
#property link      "http://www.forexfactory.com/showthread.php?t=247220"
#property description "not for sale, rent, nor auction"

#property indicator_chart_window
#property indicator_buffers 12
#property indicator_color1 clrBlue      // Buy Entry cross arrow
#property indicator_color2 clrRed       // Sell Entry cross arrow
#property indicator_color3 clrLimeGreen // Buy TP1 cross arrow  
#property indicator_color4 clrMagenta   // Sell TP1 cross arrow
#property indicator_color5 clrLimeGreen // Buy TP2 cross arrow
#property indicator_color6 clrMagenta   // Sell TP2 cross arrow
#property indicator_color7 clrLimeGreen // Buy TP3 cross arrow
#property indicator_color8 clrMagenta   // Sell TP3 cross arrow
#property indicator_color9 clrLimeGreen // Buy TP4 cross arrow
#property indicator_color10 clrMagenta  // Sell TP4 cross arrow
#property indicator_color11 clrLimeGreen // Buy TP5 cross arrow
#property indicator_color12 clrMagenta   // Sell TP5 cross arrow

#define VERSION "3 Tier London Breakout Indicator V.3.3"


/*+------------------------------------------------------------------+
 *
 * Version history:
 *
 * V.3.3:
 *     - added arrow indicators when price crosses entry and TP lines
 *
 * V.3.2b:
 *     - added "StickBoxOusideSRlevels" input; inspired by JohnnyBSmart posts; for experimentation+improvement purpose only;
 *       when true, the latest extreme (reversal) within the box is used as a S/R level;
 *       the box is sticking BEYOND that extreme level;
 *       If the reversal point was a "major" reversal, then price will fly away from the box towards the TP zone.
 *       We yet have to determine if the reversal will persist (hitting more TP levels),
 *       or if it was only a minor retracement (and will come back to us)...
 *
 * V.3.2a:
 *     - fixed "StickBoxToLatestExtreme" option... box was always sticking to the highest price;
 *
 * V.3.2: Added "StickBoxToLatestExtreme" input (false);
 *        when true, the box will "stick" to the box high or low, whichever comes last;
 *        when false(default), the box will be centered on the EMA(box_time_range) value, as in previous versions;
 *        This extension is targeted at exploring and optimizing the box POSITION in PRICE, as suggested by JohnnyBSmart;
 *        Applies only with "LimitBoxToMaxSize" and "StickBoxToLatestExtreme" are true;
 *
 * V.3.1: setting TP5Factor to 0 will disable TP4 and TP5 levels,
 *        giving an equivalent of the V.2 indicator.
 *
 * V.3: added TP5Factor input: displays 5 TP levels instead of the 3 levels of V.2
 *
 * V.2: original version by Squalou, posted on forexfactory.com
 *       (thread: http://www.forexfactory.com/showthread.php?t=247220)
 *     - "3 Tier London Breakout.mq4" indicator can be used for visual help;
 *
 *+------------------------------------------------------------------+
 */


extern string Info                    = VERSION; // version number information
extern string StartTime               = "06:00";    // time for start of price establishment window
extern string EndTime                 = "09:14";    // time for end of price establishment window
extern string SessionEndTime          = "04:30";   // end of daily session; tomorrow is another day!
extern color  SessionColor            = clrLinen; // show Session periods with a different background color
extern int    NumDays                 = 200;         // days back
extern int    MinBoxSizeInPips        = 15;     // min tradable box size; when box is smaller than that, you should at least reduce your usual lot-size if you decide to trade it;
extern int    MaxBoxSizeInPips        = 80;     // max tradable box size; don't trade when box is larger than that value
extern bool   LimitBoxToMaxSize       = true; // when true, a box larger than MaxBoxSizeInPips will be limited to MaxBoxSizeInPips, and centered on the EMA(box_time_range) value.
extern bool   StickBoxToLatestExtreme = false;  // (applies when "LimitBoxToMaxSize" is true) when true, the box will "stick" to the box high or low, whichever comes last; else it will be centered on the EMA(box_time_range) value;
extern bool   StickBoxOusideSRlevels  = false;  // when true, we'll use the latest highest/lowest PA as S/R level, and "stick" the box to outside of it;
extern double TP1Factor               = 1.000;
       double TP2Factor; // set to half-way between TP1Factor and TP3Factor;
extern double TP3Factor               = 2.618;
       double TP4Factor; // set to half-way between TP3Factor and TP5Factor;
extern double TP5Factor               = 4.236;// TP4 and TP5 targets are OPTIONAL: set TP5Factor=0 to allow only up to TP3 target;
extern string TP2_help                = "TP2 is half-way between TP1 and TP3";
extern string TP4_help                = "TP4 is half-way between TP3 and TP5";
       double SLFactor                = 1.000;
extern double LevelsResizeFactor      = 1.0;
extern color  BoxColorOK              = clrLightBlue;
extern color  BoxColorNOK             = clrRed;
extern color  BoxColorMAX             = clrOrange;
extern color  LevelColor              = clrBlack;
extern int    FibLength               = 14;
extern bool   showProfitZone          = true;
extern color  ProfitColor             = C'176,255,176';  //clrLightGreen;
extern int    ArrowSize               = 3;               // Size of the arrow indicators

extern string objPrefix               = "LB2-";  // all objects drawn by this indicator will be prefixed with this

//Forex-Station button template start41; copy and paste
extern string             button_note1          = "------------------------------";
extern int                btn_Subwindow         = 0;                               // What window to put the button on.  If <0, the button will use the same sub-window as the indicator.
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER;               // button corner on chart for anchoring
extern string             btn_text              = "LONDON";                        // a button name
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
extern string             UniqueButtonID        = "LondonBreakOut";                // Unique ID for each button        
extern string             button_note2          = "------------------------------";

bool show_data, recalc=false;
string IndicatorObjPrefix, buttonId;
//Forex-Station button template end41; copy and paste

//--------------------------------------------------------

// GLOBAL variables

double pip;
int digits;
int BarsBack;

// Arrow Buffers
double BuyEntryArrows[];
double SellEntryArrows[];
double BuyTP1Arrows[];
double SellTP1Arrows[];
double BuyTP2Arrows[];
double SellTP2Arrows[];
double BuyTP3Arrows[];
double SellTP3Arrows[];
double BuyTP4Arrows[];
double SellTP4Arrows[];
double BuyTP5Arrows[];
double SellTP5Arrows[];

//breakout levels
//Entry, stop and tp
double BuyEntry,BuyTP1,BuyTP2,BuyTP3,BuyTP4,BuyTP5,BuySL;
double SellEntry,SellTP1,SellTP2,SellTP3,SellTP4,SellTP5,SellSL;
int SL_pips,TP1_pips,TP2_pips,TP3_pips,TP4_pips,TP5_pips;
double TP1FactorInput,TP2FactorInput,TP3FactorInput,TP4FactorInput,TP5FactorInput,SLFactorInput;
//box and session
datetime tBoxStart,tBoxEnd,tSessionStart,tSessionEnd,tLastComputedSessionStart,tLastComputedSessionEnd;
double boxHigh,boxLow,boxExtent,boxMedianPrice;


int StartShift;
int EndShift;
datetime alreadyDrawn;

// Variables to track previous price levels
double prevBuyEntry = 0;
double prevSellEntry = 0;
double prevBuyTP1 = 0, prevBuyTP2 = 0, prevBuyTP3 = 0, prevBuyTP4 = 0, prevBuyTP5 = 0;
double prevSellTP1 = 0, prevSellTP2 = 0, prevSellTP3 = 0, prevSellTP4 = 0, prevSellTP5 = 0;

//+------------------------------------------------------------------------------------------------------------------+
//Forex-Station button template start42; copy and paste
int OnInit()
{
   IndicatorDigits(Digits);
   IndicatorObjPrefix = "_" + btn_text + "_";
   
   // Set up indicator buffers
   SetIndexBuffer(0, BuyEntryArrows);
   SetIndexBuffer(1, SellEntryArrows);
   SetIndexBuffer(2, BuyTP1Arrows);
   SetIndexBuffer(3, SellTP1Arrows);
   SetIndexBuffer(4, BuyTP2Arrows);
   SetIndexBuffer(5, SellTP2Arrows);
   SetIndexBuffer(6, BuyTP3Arrows);
   SetIndexBuffer(7, SellTP3Arrows);
   SetIndexBuffer(8, BuyTP4Arrows);
   SetIndexBuffer(9, SellTP4Arrows);
   SetIndexBuffer(10, BuyTP5Arrows);
   SetIndexBuffer(11, SellTP5Arrows);
   
   // Set up arrow styles
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(8, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(9, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(10, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   SetIndexStyle(11, DRAW_ARROW, STYLE_SOLID, ArrowSize);
   
   // Set arrow codes
   SetIndexArrow(0, 233);  // Up arrow for buy entry
   SetIndexArrow(1, 234);  // Down arrow for sell entry
   SetIndexArrow(2, 252);  // Target symbol for buy TP1
   SetIndexArrow(3, 252);  // Target symbol for sell TP1
   SetIndexArrow(4, 252);  // Target symbol for buy TP2
   SetIndexArrow(5, 252);  // Target symbol for sell TP2
   SetIndexArrow(6, 252);  // Target symbol for buy TP3
   SetIndexArrow(7, 252);  // Target symbol for sell TP3
   SetIndexArrow(8, 252);  // Target symbol for buy TP4
   SetIndexArrow(9, 252);  // Target symbol for sell TP4
   SetIndexArrow(10, 252); // Target symbol for buy TP5
   SetIndexArrow(11, 252); // Target symbol for sell TP5
   
   // Set index labels
   SetIndexLabel(0, "Buy Entry");
   SetIndexLabel(1, "Sell Entry");
   SetIndexLabel(2, "Buy TP1");
   SetIndexLabel(3, "Sell TP1");
   SetIndexLabel(4, "Buy TP2");
   SetIndexLabel(5, "Sell TP2");
   SetIndexLabel(6, "Buy TP3");
   SetIndexLabel(7, "Sell TP3");
   SetIndexLabel(8, "Buy TP4");
   SetIndexLabel(9, "Sell TP4");
   SetIndexLabel(10, "Buy TP5");
   SetIndexLabel(11, "Sell TP5");
   
   // The leading "_" gives buttonId a *unique* prefix.  Furthermore, prepending the swin is usually unique unless >2+ of THIS indy are displayed in the SAME sub-window. (But, if >2 used, be sure to shift the buttonId position)
   buttonId = "_" + IndicatorObjPrefix + UniqueButtonID + "_BT_";
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
         deinit2();
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
         init2();
         // Is it a problem to call 'start()' ??  Possibly it makes no difference, but now calling "mystart()" instead of "start()"; and "start()" simply runs "mystart()", so should be same as before.
         recalc=true;
         mystart();
      }
      else
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
         deinit2();
      }
   }
}
//Forex-Station button template end42; copy and paste
//+------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------+
int init2()  {
//+------------------------------------------------------------------+

  Comment (Info+" ["+StartTime+"-"+EndTime+"] end "+SessionEndTime+" min "+DoubleToStr(MinBoxSizeInPips,0)+"p,"+" max "+DoubleToStr(MaxBoxSizeInPips,0)+"p,"
           +DoubleToStr(TP1Factor,1)+"/"+DoubleToStr(TP3Factor,1)+"/"+DoubleToStr(TP5Factor,1));

  RemoveObjects(objPrefix);	
  getpip();	

  BarsBack = NumDays*(PERIOD_D1/Period());
  alreadyDrawn = 0;

  //save input Factors;
  TP1FactorInput = TP1Factor;
  TP3FactorInput = TP3Factor;
  TP5FactorInput = TP5Factor;
  SLFactorInput  = SLFactor;

  TP2Factor = (TP1Factor+TP3Factor)/2;
  TP4Factor = (TP3Factor+TP5Factor)/2;

  // StickBoxOusideSRlevels mode requires LimitBoxToMaxSize and StickBoxToLatestExtreme options true
  if (StickBoxOusideSRlevels==true) {
    LimitBoxToMaxSize = true;
    StickBoxToLatestExtreme = true;
  }

  return(0);
}/*init*/

//+------------------------------------------------------------------+
int deinit2()  {
//+------------------------------------------------------------------+

  RemoveObjects(objPrefix);	

  return(0);
}/*deinit*/


//+------------------------------------------------------------------------------------------------------------------+
int start() {return(mystart()); }
//+------------------------------------------------------------------------------------------------------------------+
int mystart()
  {
   int i, limit, counted_bars=IndicatorCounted();
   if (show_data)
      {
        if(recalc) 
        {
           // If a button goes from off-to-on, everything must be recalculated.  The 'recalc' variable is used as a trigger to do this.
           counted_bars = 0;
           recalc=false;
           
           // Reset previous values when recalculating
           prevBuyEntry = 0;
           prevSellEntry = 0;
           prevBuyTP1 = prevBuyTP2 = prevBuyTP3 = prevBuyTP4 = prevBuyTP5 = 0;
           prevSellTP1 = prevSellTP2 = prevSellTP3 = prevSellTP4 = prevSellTP5 = 0;
        }


        limit = MathMin(BarsBack,Bars-counted_bars-1);

        for (i=limit; i>=0; i--) {
             new_tick(i);
        } // limit loop
      } //if (show_data)  
  return(0);
}/*start*/
//+------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------+
void new_tick(int i) // i = bar number: 0=current(last) bar
//+------------------------------------------------------------------+
{
  datetime now = Time[i];
  double highPrice = High[i];
  double lowPrice = Low[i];

  // compute LEVELS values:
  compute_LB_Indi_LEVELS(now);

  show_boxes(now);
  
  // Check for price crossing entry and target levels
  if (i > 0) { // Skip first bar to avoid false signals
    // Check buy entry crosses
    if (lowPrice <= BuyEntry && High[i] > BuyEntry && BuyEntry != prevBuyEntry) {
      BuyEntryArrows[i] = Low[i] - 10*pip; // Position arrow below the bar
      prevBuyEntry = BuyEntry;
    }
    
    // Check sell entry crosses
    if (highPrice >= SellEntry && Low[i] < SellEntry && SellEntry != prevSellEntry) {
      SellEntryArrows[i] = High[i] + 10*pip; // Position arrow above the bar
      prevSellEntry = SellEntry;
    }
    
    // Check Buy TP crosses
    if (highPrice >= BuyTP1 && Low[i] < BuyTP1 && BuyTP1 != prevBuyTP1) {
      BuyTP1Arrows[i] = High[i] + 5*pip; // Position arrow above the bar
      prevBuyTP1 = BuyTP1;
    }
    
    if (highPrice >= BuyTP2 && Low[i] < BuyTP2 && BuyTP2 != prevBuyTP2) {
      BuyTP2Arrows[i] = High[i] + 5*pip;
      prevBuyTP2 = BuyTP2;
    }
    
    if (highPrice >= BuyTP3 && Low[i] < BuyTP3 && BuyTP3 != prevBuyTP3) {
      BuyTP3Arrows[i] = High[i] + 5*pip;
      prevBuyTP3 = BuyTP3;
    }
    
    if (highPrice >= BuyTP4 && Low[i] < BuyTP4 && BuyTP4 != prevBuyTP4 && TP5Factor > 0) {
      BuyTP4Arrows[i] = High[i] + 5*pip;
      prevBuyTP4 = BuyTP4;
    }
    
    if (highPrice >= BuyTP5 && Low[i] < BuyTP5 && BuyTP5 != prevBuyTP5 && TP5Factor > 0) {
      BuyTP5Arrows[i] = High[i] + 5*pip;
      prevBuyTP5 = BuyTP5;
    }
    
    // Check Sell TP crosses
    if (lowPrice <= SellTP1 && High[i] > SellTP1 && SellTP1 != prevSellTP1) {
      SellTP1Arrows[i] = Low[i] - 5*pip; // Position arrow below the bar
      prevSellTP1 = SellTP1;
    }
    
    if (lowPrice <= SellTP2 && High[i] > SellTP2 && SellTP2 != prevSellTP2) {
      SellTP2Arrows[i] = Low[i] - 5*pip;
      prevSellTP2 = SellTP2;
    }
    
    if (lowPrice <= SellTP3 && High[i] > SellTP3 && SellTP3 != prevSellTP3) {
      SellTP3Arrows[i] = Low[i] - 5*pip;
      prevSellTP3 = SellTP3;
    }
    
    if (lowPrice <= SellTP4 && High[i] > SellTP4 && SellTP4 != prevSellTP4 && TP5Factor > 0) {
      SellTP4Arrows[i] = Low[i] - 5*pip;
      prevSellTP4 = SellTP4;
    }
    
    if (lowPrice <= SellTP5 && High[i] > SellTP5 && SellTP5 != prevSellTP5 && TP5Factor > 0) {
      SellTP5Arrows[i] = Low[i] - 5*pip;
      prevSellTP5 = SellTP5;
    }
  }

}//new_tick()
//+------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------+
void compute_LB_Indi_LEVELS(datetime now)
//+------------------------------------------------------------------+
{
  int boxStartShift,boxEndShift;

  if (now >= tSessionStart && now <= tSessionEnd) return; // box already up-to-date, no need to recompute

  //determine box and session times 
  tBoxStart = StrToTime(TimeToStr(now,TIME_DATE) + " "  + StartTime);
  tBoxEnd   = StrToTime(TimeToStr(now,TIME_DATE) + " "  + EndTime);
  if (tBoxStart > tBoxEnd) tBoxStart -= 86400; // midnight wrap fix
  if (now < tBoxEnd) { // consider the last PAST box
    tBoxStart -= 86400;
    tBoxEnd   -= 86400;
    while ((TimeDayOfWeek(tBoxStart)==0 || TimeDayOfWeek(tBoxStart)==6)
        && (TimeDayOfWeek(tBoxEnd)==0 || TimeDayOfWeek(tBoxEnd)==6) ) {
      // box on saturday or sunday: move back 24hours again
      tBoxStart -= 86400;
      tBoxEnd   -= 86400;
    }
  }

  tSessionStart = tBoxEnd;
  tSessionEnd = StrToTime(TimeToStr(tSessionStart,TIME_DATE) + " "  + SessionEndTime);
  if (tSessionStart > tSessionEnd) tSessionEnd = tSessionEnd + 86400; // midnight wrap fix
  //if session ends on saturday or sunday, then extend it to monday so it includes the monday morning candles
  if (TimeDayOfWeek(tSessionEnd)==6/*saturday*/) tSessionEnd += 2*86400;
  if (TimeDayOfWeek(tSessionEnd)==0/*sunday*/) tSessionEnd += 86400;
  // save the computed session start&end times to avoid recomputing them for each handled trade;
  tLastComputedSessionStart = tSessionStart;
  tLastComputedSessionEnd   = tSessionEnd;

  //determine hi/lo
  boxStartShift = iBarShift(NULL,0,tBoxStart);
  boxEndShift   = iBarShift(NULL,0,tBoxEnd);
  boxHigh = High[iHighest(NULL,0,MODE_HIGH,(boxStartShift-boxEndShift+1),boxEndShift)];
  boxLow  = Low[iLowest(NULL,0,MODE_LOW,(boxStartShift-boxEndShift+1),boxEndShift)];
  boxMedianPrice = (boxHigh+boxLow)/2;
  boxExtent = boxHigh - boxLow;

  if (boxExtent >= MaxBoxSizeInPips * pip && LimitBoxToMaxSize==true) { // box too large, but we allow to trade it at its max acceptable value
    if (StickBoxToLatestExtreme==true) {
      // adjust box parameters to "stick" it to the box high or box low, whichever comes last;
      // use M1 bars to maximize price precision
      int boxStartShiftM1 = iBarShift(NULL,PERIOD_M1,tBoxStart);
      int boxEndShiftM1   = iBarShift(NULL,PERIOD_M1,tBoxEnd);
      int boxHighShift    = iHighest(NULL,PERIOD_M1,MODE_HIGH,(boxStartShiftM1-boxEndShiftM1+1),boxEndShiftM1);
      int boxLowShift     = iLowest(NULL,PERIOD_M1,MODE_LOW,(boxStartShiftM1-boxEndShiftM1+1),boxEndShiftM1);
      boxExtent = MaxBoxSizeInPips * pip;
      if (boxHighShift <= boxLowShift) {
        // box high is more recent than box low: stick box to highest price
        if (StickBoxOusideSRlevels==true) {
          boxMedianPrice = boxHigh + boxExtent/2;
        } else {
          boxMedianPrice = boxHigh - boxExtent/2;
        }
      } else {
        // box low is more recent than box high: stick box to lowest price
        if (StickBoxOusideSRlevels==true) {
          boxMedianPrice = boxLow - boxExtent/2;
        } else {
          boxMedianPrice = boxLow + boxExtent/2;
        }
      }
    } else {
      // adjust box parameters to recenter it on the EMA(box_time_range) value
      boxExtent      = MaxBoxSizeInPips * pip;
      boxMedianPrice = iMA(NULL,0,boxStartShift-boxEndShift,0,MODE_EMA,PRICE_MEDIAN,boxEndShift);
    }
  }
  
  //apply LevelsResizeFactor to the box extent
  boxExtent *= LevelsResizeFactor;
  //recompute box hi/lo prices based on adjusted median price and extent
  boxHigh = NormalizeDouble(boxMedianPrice + boxExtent/2,Digits);
  boxLow  = NormalizeDouble(boxMedianPrice - boxExtent/2,Digits);

  //restore input Factors;
  TP1Factor = TP1FactorInput;
  TP3Factor = TP3FactorInput;
  TP5Factor = TP5FactorInput;
  SLFactor  = SLFactorInput;

  //compute breakout levels
  BuyEntry  = boxHigh;
  SellEntry = boxLow;

  // when a Factor is >=10, it is considered as FIXED PIPs rather than a Factor of the box size;
  if (TP1Factor < 10) TP1_pips = boxExtent*TP1Factor/pip;
  else { TP1_pips = TP1Factor; TP1Factor = TP1_pips*pip/boxExtent; }
  BuyTP1  = NormalizeDouble(BuyEntry  + TP1_pips*pip,Digits);
  SellTP1 = NormalizeDouble(SellEntry - TP1_pips*pip,Digits);

  if (TP3Factor < 10) TP3_pips = boxExtent*TP3Factor/pip;
  else { TP3_pips = TP3Factor; TP3Factor = TP3_pips*pip/boxExtent; }
  BuyTP3  = NormalizeDouble(BuyEntry  + TP3_pips*pip,Digits);
  SellTP3 = NormalizeDouble(SellEntry - TP3_pips*pip,Digits);

  TP2Factor = (TP1Factor+TP3Factor)/2;
  if (TP2Factor < 10) TP2_pips = boxExtent*TP2Factor/pip;
  else { TP2_pips = TP2Factor; TP2Factor = TP2_pips*pip/boxExtent; }
  BuyTP2  = NormalizeDouble(BuyEntry  + TP2_pips*pip,Digits);
  SellTP2 = NormalizeDouble(SellEntry - TP2_pips*pip,Digits);

  if (TP5Factor < 10) TP5_pips = boxExtent*TP5Factor/pip;
  else { TP5_pips = TP5Factor; TP5Factor = TP5_pips*pip/boxExtent; }
  BuyTP5  = NormalizeDouble(BuyEntry  + TP5_pips*pip,Digits);
  SellTP5 = NormalizeDouble(SellEntry - TP5_pips*pip,Digits);

  TP4Factor = (TP3Factor+TP5Factor)/2;
  if (TP4Factor < 10) TP4_pips = boxExtent*TP4Factor/pip;
  else { TP4_pips = TP4Factor; TP4Factor = TP4_pips*pip/boxExtent; }
  BuyTP4  = NormalizeDouble(BuyEntry  + TP4_pips*pip,Digits);
  SellTP4 = NormalizeDouble(SellEntry - TP4_pips*pip,Digits);

  if (SLFactor < 10) SL_pips = boxExtent*SLFactor/pip;
  else { SL_pips = SLFactor; SLFactor = SL_pips*pip/boxExtent; }
  BuySL  = NormalizeDouble(BuyEntry  - SL_pips*pip,Digits);
  SellSL = NormalizeDouble(SellEntry + SL_pips*pip,Digits);

}//compute_LB_Indi_LEVELS
//+------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------+
void show_boxes(datetime now)
//+------------------------------------------------------------------+
{
  static datetime alreadyDrawn2=0;

  // show session period with a different "background" color
  drawBoxOnce (objPrefix+"Session-"+TimeToStr(tSessionStart,TIME_DATE | TIME_SECONDS),tSessionStart,0,tSessionEnd,BuyEntry*2,SessionColor,1, STYLE_SOLID, true);

  // draw pre-breakout box blue/red once per Session:
  if (alreadyDrawn2 != tBoxEnd) {
    alreadyDrawn2 = tBoxEnd; // won't redraw until next box
  
    // draw pre-breakout box blue/red:
    string boxName = objPrefix+"Box-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime;
    if (boxExtent >= MaxBoxSizeInPips * pip) { // box too large: DON'T TRADE !
      if (LimitBoxToMaxSize==false) { // box too large, but we allow to trade it at its max acceptable value
        drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorNOK,1, STYLE_SOLID, true);
        DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "NO TRADE! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
      } else {
        drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorMAX,1, STYLE_SOLID, true);
        DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "MAX LIMIT! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
      }
    } else if (boxExtent >= MinBoxSizeInPips * pip) { // box OK
      drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorOK,1, STYLE_SOLID, true);
      DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, DoubleToStr(boxExtent/pip,0)+"p", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
    } else { // "Caution!" box
      drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorNOK,1, STYLE_SOLID, true);
      DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "Caution! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", BoxColorNOK, 3);
    }
    DrawLbl(objPrefix+"Lbl2-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime,"BO", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow-6*pip, 24, "Arial Black", LevelColor, 2);

    // draw profit/loss boxes for the session
    if (showProfitZone) {
      double UpperTP,LowerTP;
      if (TP5Factor>0) {// draw TP4 and TP5 optional targets
        UpperTP = BuyTP5;
        LowerTP = SellTP5;
      } else {// draw only up to TP3
        UpperTP = BuyTP3;
        LowerTP = SellTP3;
      }
      drawBox (objPrefix+"BuyProfitZone-" +TimeToStr(tSessionStart,TIME_DATE),tSessionStart,BuyTP1,tSessionEnd,UpperTP,ProfitColor,1, STYLE_SOLID, true);
      drawBox (objPrefix+"SellProfitZone-"+TimeToStr(tSessionStart,TIME_DATE),tSessionStart,SellTP1,tSessionEnd,LowerTP,ProfitColor,1, STYLE_SOLID, true);
    }

    // draw "fib" lines for entry+stop+TP levels:
    string objname = objPrefix+"Fibo-" + tBoxEnd;
    ObjectCreate(objname,OBJ_FIBO,0,tBoxStart,SellEntry,tBoxStart+FibLength*60*10,BuyEntry);
    ObjectSet(objname,OBJPROP_RAY,false);
    ObjectSet(objname,OBJPROP_LEVELCOLOR,LevelColor); 
    ObjectSet(objname,OBJPROP_FIBOLEVELS,12);
    ObjectSet(objname,OBJPROP_LEVELSTYLE,STYLE_SOLID);
    _SetFibLevel(objname,0,0.0,"Entry Buy= %$");  
    _SetFibLevel(objname,1,1.0,"Entry Sell= %$");
    _SetFibLevel(objname,2,-TP1Factor, "Buy Target 1= %$  (+"+DoubleToStr(TP1_pips,0)+"p)");
    _SetFibLevel(objname,3,1+TP1Factor,"Sell Target 1= %$  (+"+DoubleToStr(TP1_pips,0)+"p)");
    _SetFibLevel(objname,4,-TP2Factor, "Buy Target 2= %$  (+"+DoubleToStr(TP2_pips,0)+"p)");
    _SetFibLevel(objname,5,1+TP2Factor,"Sell Target 2= %$  (+"+DoubleToStr(TP2_pips,0)+"p)");
    _SetFibLevel(objname,6,-TP3Factor, "Buy Target 3= %$  (+"+DoubleToStr(TP3_pips,0)+"p)");
    _SetFibLevel(objname,7,1+TP3Factor,"Sell Target 3= %$  (+"+DoubleToStr(TP3_pips,0)+"p)");
    if (TP5Factor>0) {// draw TP4 and TP5 optional targets
      _SetFibLevel(objname,8,-TP4Factor, "Buy Target 4= %$  (+"+DoubleToStr(TP4_pips,0)+"p)");
      _SetFibLevel(objname,9,1+TP4Factor,"Sell Target 4= %$  (+"+DoubleToStr(TP4_pips,0)+"p)");
      _SetFibLevel(objname,10,-TP5Factor, "Buy Target 5= %$  (+"+DoubleToStr(TP5_pips,0)+"p)");
      _SetFibLevel(objname,11,1+TP5Factor,"Sell Target 5= %$  (+"+DoubleToStr(TP5_pips,0)+"p)");
    }
  }

}//show_boxes()
//+------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------+
void _SetFibLevel(string objname, int level, double value, string description)
//+------------------------------------------------------------------+
{
    ObjectSet(objname,OBJPROP_FIRSTLEVEL+level,value);
    ObjectSetFiboDescription(objname,level,description);
}
//+------------------------------------------------------------------------------------------------------------------+
//--------------------------------------------------------------------------------------
// getpip
//--------------------------------------------------------------------------------------

void getpip()
{
   if(Digits==2 || Digits==4) pip = Point;
   else if(Digits==3 || Digits==5) pip = 10*Point;
   else if(Digits==6) pip = 100*Point;
      
	if (Digits == 3 || Digits == 2) digits = 2;
	else digits = 4;
} /* getpip*/
//+------------------------------------------------------------------------------------------------------------------+
//--------------------------------------------------------------------------------------
// RemoveObjects
//--------------------------------------------------------------------------------------

void RemoveObjects(string Pref)
{   
   int i;
   string objname = "";

   for (i = ObjectsTotal(); i >= 0; i--) {
      objname = ObjectName(i);
      if (StringFind(objname, Pref, 0) > -1) ObjectDelete(objname);
   }
} /* RemoveObjects*/
//+------------------------------------------------------------------------------------------------------------------+
//--------------------------------------------------------------------------------------
// drawBox
//--------------------------------------------------------------------------------------

void drawBox (
  string objname,
  datetime tStart, double vStart, 
  datetime tEnd,   double vEnd,
  color c, int width, int style, bool bg
)
{
  if (ObjectFind(objname) == -1) {
    ObjectCreate(objname, OBJ_RECTANGLE, 0, tStart,vStart,tEnd,vEnd);
  } else {
    ObjectSet(objname, OBJPROP_TIME1, tStart);
    ObjectSet(objname, OBJPROP_TIME2, tEnd);
    ObjectSet(objname, OBJPROP_PRICE1, vStart);
    ObjectSet(objname, OBJPROP_PRICE2, vEnd);
  }

  ObjectSet(objname,OBJPROP_COLOR, c);
  ObjectSet(objname, OBJPROP_BACK, bg);
  ObjectSet(objname, OBJPROP_WIDTH, width);
  ObjectSet(objname, OBJPROP_STYLE, style);
} /* drawBox */
//+------------------------------------------------------------------------------------------------------------------+
//--------------------------------------------------------------------------------------
// drawBoxOnce: draw a Box only once; if it already exists, do nothing
//--------------------------------------------------------------------------------------

void drawBoxOnce (
  string objname,
  datetime tStart, double vStart, 
  datetime tEnd,   double vEnd,
  color c, int width, int style, bool bg
)
{
  if (ObjectFind(objname) != -1) return;
  
  ObjectCreate(objname, OBJ_RECTANGLE, 0, tStart,vStart,tEnd,vEnd);
  ObjectSet(objname,OBJPROP_COLOR, c);
  ObjectSet(objname, OBJPROP_BACK, bg);
  ObjectSet(objname, OBJPROP_WIDTH, width);
  ObjectSet(objname, OBJPROP_STYLE, style);
} /* drawBoxOnce */
//+------------------------------------------------------------------------------------------------------------------+
//--------------------------------------------------------------------------------------
// DrawLbl
//--------------------------------------------------------------------------------------

void DrawLbl(string objname, string s, int LTime, double LPrice, int FSize, string Font, color c, int width)
{
  if (ObjectFind(objname) < 0) {
    ObjectCreate(objname, OBJ_TEXT, 0, LTime, LPrice);
  } else {
    if (ObjectType(objname) == OBJ_TEXT) {
      ObjectSet(objname, OBJPROP_TIME1, LTime);
      ObjectSet(objname, OBJPROP_PRICE1, LPrice);
    }
  }

  ObjectSet(objname, OBJPROP_FONTSIZE, FSize);
  ObjectSetText(objname, s, FSize, Font, c);
} /* DrawLbl*/
//+------------------------------------------------------------------------------------------------------------------+
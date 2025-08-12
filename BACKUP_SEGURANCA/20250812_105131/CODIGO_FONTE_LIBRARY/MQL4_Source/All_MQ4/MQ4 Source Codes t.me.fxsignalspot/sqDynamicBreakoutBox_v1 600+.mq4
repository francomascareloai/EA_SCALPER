//+------------------------------------------------------------------+
//| sqDynamicBreakoutBox.mq4
//| by Squalou, 2011.07.05
//+------------------------------------------------------------------+

#property copyright "by Squalou, 2011.07.05"
#property link      "http://www.forexfactory.com/showthread.php?t=302007"

#define VERSION "v1.12"
#define DATE    "2011.09.09"

/*+------------------------------------------------------------------+
 * sqDynamicBreakoutBox.mq4, by Squalou, 2011.07.05:
 * - draws Dynamic Breakout Boxes based on consolidation areas;
 * - consolidation areas are defined by a minimum period of time during which
 *   the Range of PA remained below a minimum Range value;
 * - Inputs:
 *   - BoxLength and BoxTimeFrame: define the minimum duration of the congestion areas
 *     Better than specifying a number of bars, because this will not independ
 *     on the chart's timeframe;
 *   - BoxRange: the Box Range in pips;
 *   - AutoBoxRange (true/false), AutoBoxRangeDailyATRperiod(=30) and AutoBoxRangeDailyATRfactor(=0.25):
 *     to automatically determine a the Box size based on Daily ATR, rather than a fixed size.
 *   - BoxBufferPips: draws the Yellow and Magenta "breakout" lines at this distance from the actual Box;
 *
 * This indicator was inspired by a thread opened by "forexhard" on ForexFactory.
 * http://www.forexfactory.com/showthread.php?t=302007
 * Thank you forexhard for this!
 *
 * - History:
 *
 * - v1.12 (2011.09.09):
 *   Now that the CZ Box stretches until the breakout occurs, it will also stretch until it reaches its maximum allowed height;
 *   Therefore the box edges and TP levels will CHANGE in these conditions.
 *   Buy/sell signals could wrongly trigger when the previous 2 candles would close on OPPOSITE sides of the box (consecutive up and down long candles);
 *   Fixed possible zero devide error when BoxBufferPips=0;
 *   Cosmetic changes:
 *    the signal arrows are now placed at the left of the entry candle, and point to the exact entry price;
 *    BO and BOCont lines adjusted to where they should be starting/ending;
 * 
 * - v1.11 (2011.09.08): 
 *   CZ boxes now stretch until PA breaks out of the BO; the Box size label now also shows the length of the Box (e.g "36p x 26" for 26 bars);
 *   Buy/Sell signal arrows are printed when MinBarsClosedOutsideBO bars have closed outside the BO levels;
 *   added "ShowTPLevelsOnLastBoxOnly" input;
 *   last Fibs now extend beyond the current last candle
 *   price labels on last box made bigger; controled by "BreakoutPriceWidth" input;
 *   added "ShowDisplayPanel" input;
 *   fixed DaysBack=0 case (was limiting to about 578 days max)
 *   changed default colors to a "blueish" palette;
 *
 * - v1.10 (2011.08.25): 
 *   added "MinBarsClosedOutsideBO" input: number of bars to close outside the BO levels to signal trades; 0 means "enter immediately on Breakout"
 *   added email and alarm options: "SignalMail" and "SignalAlert";
 *   added cosmetic inputs: "TP_is_pips_above", "BreakoutBoxFontSize", "SwingLabelsFontSize", "BreakoutPriceColor", "BreakoutBoxContPriceColor";
 *   change: TP levels should be calculated based on the Box itself, NOT counting the bufferpips;
 *   CAUTION: FIXED TP pips are counted based on the BUY/SELL ENTRY LEVELS,
 *            whereas TPs based on FACTORS are calculated from the BOX EDGE LEVELS independently from the BoxBufferPips input;
 *            Therefore, changing BoxBufferPips will only affect FIXED PIPS TP levels.
 *   fix: TP9 was not showing;
 *
 * - v1.9 (2011.08.22): 
 *   added "ShowTPLevels" input to allow hiding them;
 *   changed the display panel a bit;
 *   changed default settings:
 *      DaysBack is set to 100(days) to limit the cpu load;
 *      all TP levels are now set to the last fib factors proposed by Mer;
 *      the minimum value for a TP level to be taken as a pip number is 20 (was 10);
 *   optimized cpu load;
 *
 * - v1.8 (2011.07.25): 
 *   added drawing of "Fib levels" for up to 9 TP targets on each side of the CZ Breakout areas;
 *   new inputs: TP1..TP9 values: when <10, they are taken as a factor of the "Breakout Extent" (=Box extent + BufferPips), else they are in pips;
 *
 * - v1.7c (2011.07.22): more cosmetics... new inputs: "SwingLabelsColor","Fonts";
 * - v1.7b (2011.07.21):
 *   more cosmetics... added a "box continuation rectangle" on each Box (selectable color with BreakoutBoxContColor),
 *   and price labels at the right of the last box continuation rectangle;
 *
 * - v1.7a (2011.07.20):
 *   - added various cosmetic inputs (StatsColor,StatsBGColor,StatsCorner,BoxVerticalLineDelimiter,BoxVerticalLineColor);
 *     added a "background" to the Stats area;
 *
 * - v1.6 (2011.07.20):
 *   - Display each Box size in pips;
 *
 * - v1.5 (2011.07.12):
 *   - added "AutoBoxRange" (true/false), "AutoBoxRangeDailyATRperiod"(=30) and "AutoBoxRangeDailyATRfactor"(=0.25) inputs:
 *     when true, will use AutoBoxRangeDailyATRfactor*daily_ATR_value as the BoxRange value;
 *
 * - v1.4 (2011.07.11):
 *   - added saving of statistical data into a CSV file saved in (mt4)/experts/files folder;
 *     the CSV file name is on the typical model "EURUSD-sqDynamicBreakoutBox(4x60min,30p).csv"
 *     Controlled by "CreateStatisticsFile"(true/false) input;
 *
 * - v1.3 (2011.07.08):
 *   - added statistical data on maximum Buy/Sell expenctancy for each "Session";
 *     max Buys and Sells for each Session are indicated on the chart itself,
 *     the total and average maximum pips are displayed in the upper right corner;
 *
 * - v1.2 (2011.07.07):
 *   - added drawing of vertical lines marking the bar on which the Box initially formed;
 *     This helps locate the Boxes compared on other indicator windows.
 *
 * - v1.1 (2011.07.06):
 *   - added "BoxBufferPips" input, draws the Yellow and Magenta lines at this buffer away from the formed Box;
 *     These are your real breakout lines;
 *
 * - v1.0 (2011.07.05): initial version;
 *
//+------------------------------------------------------------------+
*/


#property indicator_chart_window

#property indicator_buffers 6

#property indicator_color1 C'0,200,200' // Breakout Box High Line
#property indicator_width1 2
#property indicator_color2 C'0,200,200' // Breakout Box Low Line
#property indicator_width2 2

#property indicator_color3 C'0,200,200' // Breakout Box High Line Continuation
#property indicator_color4 C'0,200,200' // Breakout Box Low Line Continuation

#property indicator_color5 clrLime      // BUY Arrow
#property indicator_color6 clrOrangeRed // SELL Arrow
#property indicator_width5 2
#property indicator_width6 2

//+------------------------------------------------------------------+
//---- input parameters
extern int    BoxLength                   = 22;
extern int    BoxTimeFrame                = 15;
extern int    BoxRange                    = 30; // fixed box range, when AutoBoxRange is false
extern bool   AutoBoxRange                = true;// when true, will use AutoBoxRangeDailyATRfactor*daily_ATR_value as the BoxRange value;
extern int    AutoBoxRangeDailyATRperiod  = 30;
extern double AutoBoxRangeDailyATRfactor  = 0.20;
extern int    BoxBufferPips               = 5; // add this amount to the Box Yellow and Magenta lines
extern int    DaysBack                    = 100; // calendar days back; 0=full history
// CAUTION when setting DaysBack to 0: with large history data, this is likely to lock-up MT4 for a few dozen seconds per chart!

extern int    MinBarsClosedOutsideBO      = 2; // number of bars to close outside the BO levels to signal trades; 0 means "enter immediately on Breakout"

extern bool   ShowDisplayPanel            = true; // false will hide the display panel

// TPs and SL levels "fib lines" settings:
// when a TP is >=20, it is considered as FIXED PIPs, <20 is a factor of the box size (EXCLUDING bufferpips);
extern bool   ShowTPLevels                = true; // false will hide the TP levels
extern bool   ShowTPLevelsOnLastBoxOnly   = true; // to limit the TP levels to the last Box only

extern double TP1                         = 0.618;
extern double TP2                         = 1.382;
extern double TP3                         = 2.618;
extern double TP4                         = 4.236;
extern double TP5                         = 5.854;
extern double TP6                         = 7.472;
extern double TP7                         = 9.090;
extern double TP8                         = 11.708;
extern double TP9                         = 14.326;
extern color  TPFiboColor                 = clrNONE;
extern color  TPLevelColor                = clrGray;
extern int    TPFiboBars                  = 5;      
extern double TP_is_pips_above            = 20; // any TP input above this value is considered as a FIXED PIP value, below is a FACTOR of the box size (including bufferpips);

extern int    BuySignalArrowCode          = 2;
extern color  BuySignalArrowColor         = clrYellow;
extern int    SellSignalArrowCode         = 2;
extern color  SellSignalArrowColor        = clrRed;

extern bool   SignalMail                  = false;
extern bool   SignalAlert                 = false;
extern bool   SignalNotification          = false;

extern bool   CreateStatisticsFile        = false;
extern int    BreakoutBoxFontSize         = 12;
extern color  BreakoutBoxColor            = C'0,170,170';
extern color  BreakoutBoxContColor        = clrDarkSlateGray;
extern bool   BreakoutBoxContFullColored  = true; // true will draw a full rectangle rather than an "empty" rectangle
extern color  BreakoutBoxContPriceColor   = clrDarkSlateGray;
extern color  BreakoutPriceColor          = C'0,170,170';
extern int    BreakoutPriceWidth          = 2;
extern color  StatsColor                  = C'0,220,220';
extern color  StatsBGColor                = clrTeal;
extern int    StatsCorner                 = 1; // 0=upper-left, 1=upper-right, 2=lower-left, 3=lower-right
extern bool   BoxVerticalLineDelimiter    = false; // false to remove vertival Box delimiter lines;
extern color  BoxVerticalLineColor        = clrDarkSlateGray;
extern int    SwingLabelsFontSize         = 12;
extern color  SwingLabelsColor            = clrDarkOrange;
extern string Fonts                       = "Arial";

extern int    debug                       = 0;

//+------------------------------------------------------------------+


//---- buffers
double highBO[],lowBO[];
double highBOcont[],lowBOcont[];
double periodForMinRange[];
double BuySignal[],SellSignal[];

int _period,_minP,_maxP,_prevP;
double _Range;

datetime current_box_forming_time,current_box_1st_bar_time;

string prefix;
string strBoxRange;

int BarsBack,lasttime;
bool force_full_redraw;

double pip;
int pipMult,pipMultTab[]={1,10,1,10,1,10,100}; // multiplier to convert pips to Points;


double TP[10],TPInput[10],TP_pips[10],BuyTP[10],SellTP[10];
double BoxHighValue,BoxLowValue,BoxExtent,highBOvalue,lowBOvalue,BOExtent;
double SL,SLInput;

//+------------------------------------------------------------------+
int init()
//+------------------------------------------------------------------+
{
  pipMult = pipMultTab[Digits];
  pip = Point * pipMult;
  
  prefix = "sqDynBO"+BoxLength+" "+BoxTimeFrame+" "+BoxRange;
  
  RemoveObjects(prefix);

  strBoxRange = "FIXED "+DoubleToStr(BoxRange,0)+"p";
  if (AutoBoxRange == true) strBoxRange = "ADR"+DoubleToStr(AutoBoxRangeDailyATRperiod,0)+"x"+DoubleToStr(AutoBoxRangeDailyATRfactor,2);
  
  _Range = BoxRange * pip; // convert pips to price range

  if (BoxTimeFrame==0) BoxTimeFrame=Period();
  _period = BoxLength * BoxTimeFrame/Period();
  _minP   = _period;
  _prevP  = _period;

  IndicatorShortName(WindowExpertName()+" "+VERSION+"("+BoxLength+"x"+BoxTimeFrame+"min,"+strBoxRange+")");

  IndicatorBuffers(7);
  int b=-1;
  b++;SetIndexBuffer(b,highBO); SetIndexLabel(b,"Breakout Box High");
  b++;SetIndexBuffer(b,lowBO);  SetIndexLabel(b,"Breakout Box Low");
  b++;SetIndexBuffer(b,highBOcont); SetIndexLabel(b,"Breakout Box High Continued");
  b++;SetIndexBuffer(b,lowBOcont);  SetIndexLabel(b,"Breakout Box Low Continued");
  b++;SetIndexBuffer(b,BuySignal); SetIndexLabel(b,"Buy Signal"); SetIndexStyle(b,DRAW_ARROW); SetIndexArrow(b,232);
  b++;SetIndexBuffer(b,SellSignal); SetIndexLabel(b,"Sell Signal"); SetIndexStyle(b,DRAW_ARROW); SetIndexArrow(b,232);
  b++;SetIndexBuffer(b,periodForMinRange); SetIndexLabel(b,"periodForMinRange");

  current_box_forming_time = 0;
  current_box_1st_bar_time = 0;
  
  if (DaysBack==0) DaysBack=9999;
  BarsBack = iBarShift(NULL,0,iTime(NULL,PERIOD_D1,0) - DaysBack*PERIOD_D1*60);

  lasttime=0;

  if (CreateStatisticsFile) delete_CSV();
  force_full_redraw=true;
  
  //save input Factors;
  TPInput[1] = TP1;
  TPInput[2] = TP2;
  TPInput[3] = TP3;
  TPInput[4] = TP4;
  TPInput[5] = TP5;
  TPInput[6] = TP6;
  TPInput[7] = TP7;
  TPInput[8] = TP8;
  TPInput[9] = TP9;
  SLInput   = SL;

  return(0);
}

//+------------------------------------------------------------------+
int deinit()
//+------------------------------------------------------------------+
{
  RemoveObjects(prefix);
  force_full_redraw=true;
  return(0);
}


//+------------------------------------------------------------------+
int start()
//+------------------------------------------------------------------+
{
  double upper,lower,best_buy,best_sell;
  int jj;
  int i, limit, counted_bars=IndicatorCounted();

  if (force_full_redraw) {
    force_full_redraw=false;
    lasttime=0;
    counted_bars=0;
    ArrayInitialize(highBO,EMPTY_VALUE);
    ArrayInitialize(lowBO,EMPTY_VALUE);
    ArrayInitialize(highBOcont,EMPTY_VALUE);
    ArrayInitialize(lowBOcont,EMPTY_VALUE);
    ArrayInitialize(BuySignal,EMPTY_VALUE);
    ArrayInitialize(SellSignal,EMPTY_VALUE);
  }

  if (lasttime==Time[0]) return(0); //once per Bar
  lasttime=Time[0];

  limit = MathMax(MathMin(BarsBack,Bars-counted_bars-1),1);

  for (i=limit; i>0; i--)
  {
    if (AutoBoxRange == true) {// determine the BoxRange dynamically using the Daily ATR;
      _Range = AutoBoxRangeDailyATRfactor  * iATR(NULL,PERIOD_D1,AutoBoxRangeDailyATRperiod,iBarShift(NULL,PERIOD_D1,iTime(NULL,0,i),true)+1);
    }
    // get the period over which PA Range remained below BoxRange
    _period = GetPeriodForMinRange(i, _minP, 999, _Range, periodForMinRange[i+1]);
    periodForMinRange[i] = _period;
    upper = High[iHighest(NULL, 0, MODE_HIGH, _period, i)];
    lower = Low [iLowest (NULL, 0, MODE_LOW,  _period, i)];

    // continue the previous Box high/low lines
    highBOcont[i] = highBOcont[i+1];
    lowBOcont[i]  = lowBOcont[i+1];
    
    //draw a Dynamic Breakout Box when Price Range remains below BoxRange during more than BoxLength
    if (_period > _minP) { // Price range remained below BoxRange longer than BoxLength:
      // draw a new Breakout Box, or extend the Box if one is already drawing
      if (highBO[i+1]==EMPTY_VALUE && lowBO[i+1]==EMPTY_VALUE) { // no Box was forming:
        // start a new Box ONLY if a the previous Box is older than BoxLength
        if (highBO[i+_minP]==EMPTY_VALUE && lowBO[i+_minP]==EMPTY_VALUE) {
          // we can draw a new Box now
          // save some stats about the potential win/loss during the last "Box Session"
          get_session_swing_hi_and_lo(Time[i+1], current_box_forming_time, highBOvalue, lowBOvalue, best_buy, best_sell);
          // save the best result in the database
          if (CreateStatisticsFile) save_stats_in_CSV(Time[i+1], current_box_forming_time, best_buy, best_sell, (highBOvalue-lowBOvalue)/pip);
          // limit the Box Range to BoxRange;
          // snap the Box to the extreme that is opposite of the first(oldest) candle of the Box
          if (High[i+_period-1]==upper) upper = lower+_Range;
          if (Low[i+_period-1]==lower)  lower = upper-_Range;
          // draw High and Low Yellow lines starting from the beginning of the Box
          for (jj = i+_minP-1; jj>=i; jj--) {
            highBO[jj] = upper + BoxBufferPips * pip;
            lowBO[jj]  = lower - BoxBufferPips * pip;
          }
          // make the "Box Continuation lines" look discontinued
          highBOcont[i+1] = EMPTY_VALUE;
          lowBOcont[i+1]  = EMPTY_VALUE;
          highBOcont[i] = upper + BoxBufferPips * pip;
          lowBOcont[i]  = lower - BoxBufferPips * pip;
          current_box_forming_time = Time[i]; // remember Box starting candle;
          current_box_1st_bar_time = Time[i+_minP-1]; // remember time of Box 1st bar;
          // draw a Box where it started to form:
          drawBox(prefix+"trueBox"+TimeToStr(current_box_1st_bar_time), current_box_1st_bar_time, upper, current_box_forming_time, lower, BreakoutBoxColor, 0, STYLE_SOLID, true, "");
          drawLbl(prefix+"infoBox"+TimeToStr(current_box_1st_bar_time), DoubleToStr((upper-lower)/pip,0)+"p x "+DoubleToStr(iBarShift(NULL,0,current_box_1st_bar_time)-iBarShift(NULL,0,current_box_forming_time)+1,0), current_box_1st_bar_time+(current_box_forming_time-current_box_1st_bar_time)/2, lower - BoxBufferPips * pip, BreakoutBoxFontSize, Fonts, BreakoutBoxColor, 3);
          if (BoxVerticalLineDelimiter) drawVLine(prefix+"V"+TimeToStr(current_box_1st_bar_time), current_box_forming_time, BoxVerticalLineColor);
        }
      } else { // a Box was already forming:
        // extend it ONLY IF price did not break out already
        if (Low[i] >= lowBO[i+1] && High[i] <= highBO[i+1]) {
          // price is still inside the Box limits: extend the forming Box
          // snap the Box to the extreme that is opposite of the first(oldest) candle of the Box
          if (High[i+_period-1]==upper) upper = lower+_Range;
          if (Low[i+_period-1]==lower)  lower = upper-_Range;
          // draw High and Low Yellow lines starting from the beginning of the Box
          for (jj = iBarShift(NULL,0,current_box_1st_bar_time); jj>=i; jj--) {
            highBO[jj] = upper + BoxBufferPips * pip;
            lowBO[jj]  = lower - BoxBufferPips * pip;
          }
          // make the "Box Continuation lines" look discontinued
          highBOcont[i+1] = EMPTY_VALUE;
          lowBOcont[i+1]  = EMPTY_VALUE;
          highBOcont[i] = upper + BoxBufferPips * pip;
          lowBOcont[i]  = lower - BoxBufferPips * pip;
          current_box_forming_time = Time[i]; // update Box "forming" candle;
          // extend the Box:
          drawBox(prefix+"trueBox"+TimeToStr(current_box_1st_bar_time), current_box_1st_bar_time, upper, current_box_forming_time, lower, BreakoutBoxColor, 0, STYLE_SOLID, true, "");
          drawLbl(prefix+"infoBox"+TimeToStr(current_box_1st_bar_time), DoubleToStr((upper-lower)/pip,0)+"p x "+DoubleToStr(iBarShift(NULL,0,current_box_1st_bar_time)-iBarShift(NULL,0,current_box_forming_time)+1,0), current_box_1st_bar_time+(current_box_forming_time-current_box_1st_bar_time)/2, lower - BoxBufferPips * pip, BreakoutBoxFontSize, Fonts, BreakoutBoxColor, 3);
          if (BoxVerticalLineDelimiter) drawVLine(prefix+"V"+TimeToStr(current_box_1st_bar_time), current_box_forming_time, BoxVerticalLineColor);
        } else {
          // Price has broken out of the forming Box: stop the forming Box
          highBO[i] = EMPTY_VALUE;
          lowBO[i]  = EMPTY_VALUE;
        }
      }
    }

    // draw a "box continuation rectangle" to show the Box limits during the whole "Session"
    highBOvalue  = highBO[iBarShift(NULL,0,current_box_forming_time)];
    lowBOvalue   = lowBO[iBarShift(NULL,0,current_box_forming_time)];
    BOExtent     = highBOvalue-lowBOvalue;
    BoxHighValue = highBOvalue - BoxBufferPips * pip;
    BoxLowValue  = lowBOvalue + BoxBufferPips * pip;
    BoxExtent    = BoxHighValue-BoxLowValue;
    drawBox(prefix+"BoxCont"+TimeToStr(current_box_1st_bar_time), current_box_forming_time, BoxHighValue, Time[i], BoxLowValue, BreakoutBoxContColor, 0, STYLE_SOLID, BreakoutBoxContFullColored, "");
    if (ShowTPLevels && !ShowTPLevelsOnLastBoxOnly) {
      calc_TP_levels();
      draw_fibs(ShowTPLevelsOnLastBoxOnly,current_box_1st_bar_time,current_box_forming_time,Time[i]);
    }
    manage_signals(i);
  }

  if (ShowTPLevels && ShowTPLevelsOnLastBoxOnly) {
    calc_TP_levels();
    draw_fibs(ShowTPLevelsOnLastBoxOnly,current_box_1st_bar_time,current_box_forming_time,Time[0]);
  }

  // put price labels at the right of the LAST Box and Breakout levels: (won't "pollute" the chart too much...)
  drawOrderArrow(prefix+"BoxHLbl", Time[0], highBOvalue, SYMBOL_RIGHTPRICE, BreakoutPriceColor, BreakoutPriceWidth);
  drawOrderArrow(prefix+"BoxLLbl", Time[0], lowBOvalue,  SYMBOL_RIGHTPRICE, BreakoutPriceColor, BreakoutPriceWidth);
  if (BoxBufferPips!=0) { // put price labels at Box edges levels
    drawOrderArrow(prefix+"BoxContHLbl", Time[0], BoxHighValue, SYMBOL_RIGHTPRICE, BreakoutBoxContPriceColor, BreakoutPriceWidth);
    drawOrderArrow(prefix+"BoxContLLbl", Time[0], BoxLowValue,  SYMBOL_RIGHTPRICE, BreakoutBoxContPriceColor, BreakoutPriceWidth);
  }

  // update stats for the last "session"
  get_session_swing_hi_and_lo(Time[i+1], current_box_forming_time, highBOvalue, lowBOvalue, best_buy, best_sell);
  if (CreateStatisticsFile) CreateStatisticsFile = false; // do only once;
  display_stats();

  manage_signals(0);

  return(0);
}


//--------------------------------------------------------------------------------------
void calc_TP_levels()
//--------------------------------------------------------------------------------------
{
  int i;
  //restore input Factors;
  for (i=1; i<ArraySize(TPInput); i++) TP[i] = TPInput[i];
  for (i=1; i<ArraySize(TPInput); i++) calc_TP(i);
}

//--------------------------------------------------------------------------------------
void calc_TP(int i)
//--------------------------------------------------------------------------------------
{
  if(BoxExtent==0) return;

  double low,high;

  // when a Factor is >=TP_is_pips_above, it is considered as FIXED PIPs rather than a Factor of the box size;
  // FIXED TP pips are counted based on the BUY/SELL ENTRY LEVELS,
  // whereas TPs based on FACTORS are calculated from the BOX EDGE LEVELS independently from the BoxBufferPips input;
  if (TP[i] < TP_is_pips_above) { // TP level is a FACTOR of the Box size
    low  = BoxLowValue;
    high = low + BoxExtent;
    TP_pips[i] = BoxExtent/pip*TP[i] - BoxBufferPips;
  } else { // TP is a FIXED amount of pips from the the BUY/SELL ENTRY level
    low  = lowBOvalue;
    high = low + BOExtent;
    TP_pips[i] = TP[i]; TP[i] = (TP_pips[i]+BoxBufferPips)*pip/BoxExtent;
  }
  BuyTP[i]  = NormalizeDouble(high + TP_pips[i]*pip,Digits);
  SellTP[i] = NormalizeDouble(low  - TP_pips[i]*pip,Digits);
}

//--------------------------------------------------------------------------------------
void draw_fibs(bool on_current,datetime id, datetime box_forming_time, datetime current_time)
//--------------------------------------------------------------------------------------
{
  if(BoxExtent==0) return;

  if(on_current) datetime fib_time2 = iTime(NULL,0,TPFiboBars);//iBarShift(NULL,0,current_time)+(iBarShift(NULL,0,box_forming_time) - iBarShift(NULL,0,current_time))/10); // Fibs extend to 10*(time2-time1)
  else fib_time2 = fib_time2 = iTime(NULL,0,iBarShift(NULL,0,box_forming_time)+(iBarShift(NULL,0,current_time)-iBarShift(NULL,0,box_forming_time))/10); // Fibs extend to 10*(time2-time1)
    
  if (current_time >= Time[0]) fib_time2 += Period()*60; // allow last Fibs to extend beyond the current last candle
  
  
  // draw "fib" lines for entry+stop+TP levels:
  string objname = prefix+"Fibo-" + id;
  ObjectDelete(objname);
  {
    if(on_current) ObjectCreate(objname,OBJ_FIBO,0,fib_time2,BoxLowValue,current_time,BoxHighValue);
    else ObjectCreate(objname,OBJ_FIBO,0,box_forming_time,BoxLowValue,fib_time2,BoxHighValue);
    ObjectSet(objname,OBJPROP_RAY,false);
    ObjectSet(objname,OBJPROP_LEVELCOLOR,TPLevelColor); 
    ObjectSet(objname,OBJPROP_COLOR,TPFiboColor); 
    ObjectSet(objname,OBJPROP_FIBOLEVELS,32);
    ObjectSet(objname,OBJPROP_LEVELSTYLE,STYLE_SOLID);

    TP[0] = BoxBufferPips*pip/BoxExtent; // this is the Buy/Sell entry level
    _SetFibLevel(objname,0,-TP[0],"Buy @ %$");  
    _SetFibLevel(objname,1,1+TP[0],"Sell @ %$");
  
    for (int i=1; i<=9; i++)
    {
      if (TP[i]!=0) {
        _SetFibLevel(objname,2*i,  -TP[i], "%$(+"+DoubleToStr(TP_pips[i],0)+"p)");
        _SetFibLevel(objname,2*i+1,1+TP[i],"%$(+"+DoubleToStr(TP_pips[i],0)+"p)");
      }
    }
  }
  /*
  else { // already exists: just move the right end to the "current_time" position
    ObjectMove(objname, 1, fib_time2,BoxHighValue);
  }
  */
}

//+------------------------------------------------------------------+
void _SetFibLevel(string objname, int level, double value, string description)
//+------------------------------------------------------------------+
{
    ObjectSet(objname,OBJPROP_FIRSTLEVEL+level,value);
    ObjectSetFiboDescription(objname,level,description);
}

//+------------------------------------------------------------------+
int GetPeriodForMinRange(int shift, int MinP, int MaxP, double MinRange, int prevP)
//+------------------------------------------------------------------+
{
  int P;
  
  
  // calc P so that the Price Range (=Hi-Lo) remains in a "reasonably large value" over the P
  P=prevP; // start with previous P
  if (P<MinP) P=MinP;
  if (P>MaxP) P=MaxP;
  if (_get_range(P,shift) > MinRange) {//range is OK for this P value: try shorter P values
    for (; P>=MinP; P--) {
      if (_get_range(P,shift) <= MinRange) return(P+1);//previous P value was the limit
    }
    return(P);
  }
  //try higher P values
  for (P=prevP+1; P<MaxP; P++) {
    if (_get_range(P,shift) > MinRange) return(P);
  }
  return(MaxP);
}

  double _get_range(int period, int shift)
  {
    return(High[iHighest(NULL,0,MODE_HIGH,period,shift)] - Low[iLowest(NULL,0,MODE_LOW,period,shift)]);
  }

//--------------------------------------------------------------------------------------
void get_session_swing_hi_and_lo(datetime current_time, datetime box_forming_time, double high_breakout_value, double low_breakout_value, double &best_buy, double &best_sell)
//--------------------------------------------------------------------------------------
{ // save some stats about the potential win/loss during the last "Box Session"
  int highest_bar,lowest_bar,period;
  double highest_price,lowest_price;

  if (box_forming_time == 0) return; // no box formed yet: no statistics

  int box_forming_shift = iBarShift(NULL,0,box_forming_time);
  int current_shift     = iBarShift(NULL,0,current_time);

  period = box_forming_shift - current_shift + 1;

  highest_bar = iHighest(NULL,0,MODE_HIGH,period,current_shift);
  highest_price = High[highest_bar];
  best_buy = 0;
  if (highest_price > high_breakout_value) {
    // PA did breakout the top of the box: BUY was triggered
    best_buy = (highest_price - high_breakout_value) / pip;
    // mark the absolute best Buy extension on the chart
    //drawOrderArrow(prefix+TimeToStr(Time[highest_bar])+"SwingHigh:"+DoubleToStr(best_buy,0)+"p", Time[highest_bar], highest_price, SYMBOL_CHECKSIGN, SwingLabelsColor);
    drawLbl(prefix+"SwingHigh"+TimeToStr(box_forming_time), DoubleToStr(best_buy,0)+"p", Time[highest_bar], highest_price+10*pip, SwingLabelsFontSize, Fonts, SwingLabelsColor, 3);
  }
  
  lowest_bar   = iLowest(NULL,0,MODE_LOW,period,current_shift);
  lowest_price = Low[lowest_bar];
  best_sell = 0;
  if (lowest_price < low_breakout_value) {
    // PA did breakout the bottom of the box: SELL was triggered
    best_sell = (low_breakout_value - lowest_price) / pip;
    // mark the absolute best Sell extension on the chart
    //drawOrderArrow(prefix+TimeToStr(Time[lowest_bar])+"SwingLow:"+DoubleToStr(best_sell,0)+"p", Time[lowest_bar], lowest_price, SYMBOL_CHECKSIGN, SwingLabelsColor);
    drawLbl(prefix+"SwingLow"+TimeToStr(box_forming_time), DoubleToStr(best_sell,0)+"p", Time[lowest_bar], lowest_price, SwingLabelsFontSize, Fonts, SwingLabelsColor, 3);
  }

}

//--------------------------------------------------------------------------------------
void display_stats()
//--------------------------------------------------------------------------------------
{
  // Compute the average BestBuy and BestSell expectation per Session
  double sum_buy=0,sum_sell=0,result;
  int i,num_buy=0,num_sell=0,num_boxes=0;
  string o;
  for (i = ObjectsTotal(EMPTY); i >= 0; i--) {
    o = ObjectName(i);
    //Print(o);
    if (StringFind(o, prefix+"SwingHigh", 0) > -1) {
      result = StrToInteger(StringSubstr(ObjectDescription(o),0,StringLen(ObjectDescription(o))-1));
      if (result>0) {
        sum_buy += result;
        num_buy++;
      }
    }
    if (StringFind(o, prefix+"SwingLow", 0) > -1) {
      result = StrToInteger(StringSubstr(ObjectDescription(o),0,StringLen(ObjectDescription(o))-1));
      if (result>0) {
        sum_sell +=result;
        num_sell++;
      }
    }
    if (StringFind(o, prefix+"trueBox", 0) > -1) {
      num_boxes++;
      //Print(num_boxes,":",o);
    }
  }
  
  double num_weeks = (Time[0]-Time[BarsBack]) / (3600*24*7);
  
  // Display the total number of Buys and Sells, total maximum pips, and average pips per session
if (ShowDisplayPanel == true) {
  int y=0,dy=20,x=10;
  y+=dy;drawFixedLbl(prefix+"infoBox", "Box="+BoxLength+"x"+tf_to_string(BoxTimeFrame)+"/"+strBoxRange, StatsCorner, x, y, 10, "Arial", StatsColor, false);
    drawFixedLbl(prefix+"numBoxbg"+y, "gggggggg", StatsCorner, x-5, y-5, 16, "Webdings", StatsBGColor, true);
  y+=dy;drawFixedLbl(prefix+"numBox", DoubleToStr(num_boxes,0)+" Boxes ("+DoubleToStr(num_boxes/num_weeks,1)+" per Week)", StatsCorner, x, y, 10, "Arial", StatsColor, false);
    drawFixedLbl(prefix+"numBoxbg"+y, "gggggggg", StatsCorner, x-5, y-5, 16, "Webdings", StatsBGColor, true);
  y+=dy;drawFixedLbl(prefix+"ttB", "Total:"+DoubleToStr(num_buy,0)+" Buys="+DoubleToStr(sum_buy,0)+"p", StatsCorner, x, y, 10, "Arial", StatsColor, false);
    drawFixedLbl(prefix+"numBoxbg"+y, "gggggggg", StatsCorner, x-5, y-5, 16, "Webdings", StatsBGColor, true);
  y+=dy;if(num_buy!=0)drawFixedLbl(prefix+"ttAvgB", "Avg Buys="+DoubleToStr(sum_buy/num_buy,0)+"p", StatsCorner, x, y, 10, "Arial", StatsColor, false);
    drawFixedLbl(prefix+"numBoxbg"+y, "gggggggg", StatsCorner, x-5, y-5, 16, "Webdings", StatsBGColor, true);
  y+=dy;drawFixedLbl(prefix+"ttS", "Total:"+DoubleToStr(num_sell,0)+" Sells="+DoubleToStr(sum_sell,0)+"p", StatsCorner, x, y, 10, "Arial", StatsColor, false);
    drawFixedLbl(prefix+"numBoxbg"+y, "gggggggg", StatsCorner, x-5, y-5, 16, "Webdings", StatsBGColor, true);
  y+=dy;if(num_sell!=0)drawFixedLbl(prefix+"ttAvgS", "Avg Sells="+DoubleToStr(sum_sell/num_sell,0)+"p", StatsCorner, x, y, 10, "Arial", StatsColor, false);
    drawFixedLbl(prefix+"numBoxbg"+y, "gggggggg", StatsCorner, x-5, y-5, 16, "Webdings", StatsBGColor, true);
	}  
}

//--------------------------------------------------------------------------------------
void save_stats_in_CSV(datetime current_time, datetime box_forming_time, double best_buy, double best_sell, int box_range)
//--------------------------------------------------------------------------------------
{
  // save the best results in a CSV file
  string filename = Symbol()+"-"+WindowExpertName()+"-"+AccountServer()+"-"+Period()+"("+BoxLength+"x"+BoxTimeFrame+"min,"+strBoxRange+"p)"+".CSV";
  int f;
  f=FileOpen(filename, FILE_CSV|FILE_READ|FILE_WRITE, ";");
  FileSeek(f, 0, SEEK_END);

  if(f>0)
  {
    FileWrite(f
        ,WindowExpertName()
        ,BoxLength
        ,BoxTimeFrame
        ,box_range
        ,"BO session="
        ,TimeToStr(box_forming_time)
        ,TimeToStr(current_time)
        ,"BestBuy="
        ,DoubleToStr(best_buy,0)
        ,"p"
        ,"BestSell="
        ,DoubleToStr(best_sell,0)
        ,"p"
        );
    FileClose(f);
  }
}

//--------------------------------------------------------------------------------------
void delete_CSV()
//--------------------------------------------------------------------------------------
{
  string filename = Symbol()+"-"+WindowExpertName()+"-"+AccountServer()+"-"+Period()+"("+BoxLength+"x"+BoxTimeFrame+"min,"+strBoxRange+"p)"+".CSV";
  int f;
  f=FileOpen(filename, FILE_CSV|FILE_WRITE, ";");
  FileClose(f);
}

//--------------------------------------------------------------------------------------
void manage_signals(int shift)
//--------------------------------------------------------------------------------------
{
  int trigger_direction=-1;
  double trigger_price;
  // Trading Signal Alerts: a minimum number of bars should have closed outside of the BO area 
  // MinBarsClosedOutsideBO set to 0 means we can start the sequence as soon as the breakout occurs
  if (MinBarsClosedOutsideBO==0) {
    // special case: we want to trigger the trade as soon as price break out of the CZ Box
    if (High[shift+1] < highBOvalue && High[shift] >= highBOvalue) {
      trigger_direction = OP_BUY;
      trigger_price = highBOvalue;
    }
    if (Low[shift+1]  > lowBOvalue  && Low[shift] <= lowBOvalue) {
      trigger_direction = OP_SELL;
      trigger_price = lowBOvalue;
    }
  }
  else if (bars_closed_outside_BO(shift) == MinBarsClosedOutsideBO) {
    if (Open[shift] >= highBOvalue) {
      trigger_direction = OP_BUY;
      trigger_price = Open[shift];
    }
    if (Open[shift] <= lowBOvalue) {
      trigger_direction = OP_SELL;
      trigger_price = Open[shift];
    }
  }

  string id;
  if (trigger_direction == OP_BUY) {
    //BuySignal[shift+1] = Close[shift+1]; // make the arrow point to the close price of the latest closed bar
    id = prefix+"BUY"+TimeToStr(Time[shift]);
    if (ObjectFind(id)==-1) { // no trigger yet on this candle
      drawOrderArrow(id, Time[shift], trigger_price, BuySignalArrowCode, BuySignalArrowColor, 2);
      if (shift==0) send_trading_signal(OP_BUY,Ask);
    }
  }
  if (trigger_direction == OP_SELL) {
    //SellSignal[shift+1] = Close[shift+1]; // make the arrow point to the close price of the latest closed bar
    id = prefix+"SELL"+TimeToStr(Time[shift]);
    if (ObjectFind(id)==-1) { // no trigger yet on this candle
      drawOrderArrow(id, Time[shift], trigger_price, SellSignalArrowCode, SellSignalArrowColor, 2);
      if (shift==0) send_trading_signal(OP_SELL,Bid);
    }
  }

}

string op_str[6] = { "BUY","SELL","BUYLIMIT","SELLLIMIT","BUYSTOP","SELLSTOP"};

//+------------------------------------------------------------------+
void send_trading_signal(int type, double price)
//+------------------------------------------------------------------+
{
  string message = WindowExpertName()+":"+Symbol()+" "+op_str[type]+" Signal";
  if (SignalMail)  SendMail(message, Symbol()+":"+op_str[type]+" @ "+DoubleToStr(price,Digits));
  if (SignalAlert) Alert(message);
  if (SignalNotification) SendNotification(message);
}

//+------------------------------------------------------------------+
int bars_closed_outside_BO(int shift)
//+------------------------------------------------------------------+
{
  int cnt=0,side=-1;
  // count past bars until finding the one on which the breakout occured
  for (int i=shift+1; i<shift+MinBarsClosedOutsideBO+3; cnt++,i++) {
    if (Close[i] >= highBOvalue && side!=OP_SELL) {
      side = OP_BUY;
      continue; // this bar closed outside the BO area: try previous bars
    }
    if (Close[i] <= lowBOvalue && side!=OP_BUY) {
      side = OP_SELL;
      continue; // this bar closed outside the BO area: try previous bars
    }
    // this bar closed either INSIDE the BO area, or on the OTHER SIDE: return the counted number of successive bars that closed outside the BO area
    return(cnt);
  }
  return(cnt);
}



//--------------------------------------------------------------------------------------
void drawFixedLbl(string objname, string s, int Corner, int DX, int DY, int FSize, string Font, color c, bool bg)
//--------------------------------------------------------------------------------------
{
   if (ObjectFind(objname) < 0) ObjectCreate(objname, OBJ_LABEL, 0, 0, 0);
   
   ObjectSet(objname, OBJPROP_CORNER, Corner);
   ObjectSet(objname, OBJPROP_XDISTANCE, DX);
   ObjectSet(objname, OBJPROP_YDISTANCE, DY);
   ObjectSet(objname,OBJPROP_BACK, bg);      
   ObjectSetText(objname, s, FSize, Font, c);
} // drawFixedLbl

//--------------------------------------------------------------------------------------
void drawLbl(string objname, string s, int LTime, double LPrice, int FSize, string Font, color c, int width)
//--------------------------------------------------------------------------------------
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
} /* drawLbl*/

//+------------------------------------------------------------------
void drawOrderArrow(string name, datetime t, double price, int arrowcode, color c, int width=1)
//+------------------------------------------------------------------
{
  if (ObjectFind(name) < 0) ObjectCreate(name, OBJ_ARROW, 0, t, price);
  else ObjectMove(name, 0, t, price);
  ObjectSet(name, OBJPROP_ARROWCODE,  arrowcode);
  ObjectSet(name, OBJPROP_COLOR, c);
  ObjectSet(name, OBJPROP_WIDTH, width);
}

//--------------------------------------------------------------------------------------
void drawBox (string objname, datetime tStart, double vStart, datetime tEnd, double vEnd, color c, int width, int style, bool bg, string comment)
//--------------------------------------------------------------------------------------
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
  //ObjectSetText(objname, comment);
} /* drawBox */

//+------------------------------------------------------------------
void drawVLine(string objname, int time, color c, int style=STYLE_SOLID, int width=0, int win=0)
//+------------------------------------------------------------------
{
  if (ObjectFind(objname) == -1) {
    ObjectCreate(objname, OBJ_VLINE, win, time, 0);
  } else {
    ObjectSet(objname, OBJPROP_TIME1, time);
  }
  ObjectSet(objname, OBJPROP_COLOR, c);
  ObjectSet(objname, OBJPROP_STYLE, style);
  ObjectSet(objname, OBJPROP_WIDTH, width);
}

//+-------------------------------------------------------------------
string tf_to_string(int tf)
//+-------------------------------------------------------------------
{
  switch(tf) {
    case PERIOD_M1:  return("M1");
    case PERIOD_M5:  return("M5");
    case PERIOD_M15: return("M15");
    case PERIOD_M30: return("M3");
    case PERIOD_H1:  return("H1");
    case PERIOD_H4:  return("H4");
    case PERIOD_D1:  return("D1");
    case PERIOD_W1:  return("W1");
    case PERIOD_MN1: return("MN1");
    default: return("?");
  }
}

//--------------------------------------------------------------------------------------
void RemoveObjects(string iprefix)
//--------------------------------------------------------------------------------------
{   
   int i;
   string objname;

   for (i = ObjectsTotal(); i >= 0; i--) {
      objname = ObjectName(i);
      if (StringFind(objname, iprefix, 0) > -1) ObjectDelete(objname);
   }
} /* RemoveObjects*/

//+------------------------------------------------------------------+


//unofficial adition
// - toggle button to show/hide all objects (excl. btn)

//--------------------------------------------------------------------
// Program Name: WyattsPivots.mq4
// Description: This program will plot pivot levels on the chart and
//       may send push notifications on levels reached. This
//       program may be called multiple times on a chart to plot 
//       multiple time periods.
//
//--------------------------------------------------------------------
// Rev   Date     Programmer  Changes
// 2.0   06/14/18 L. Garcia   - Started out with program called WyattsPivots_erikmod.mq4
//                            - Added minor comments and code style (minimized global variable use)
//                            - Removed fibo pivots functionality
//                            - Removed previous OHLC functionality
//                            - Added chart digits instead of hardcoding to 4 decimal places on pivot price plots
//                            - Added period string to pivot label plots
//                            - Added '_' to shift on object names
//                            - Updated weekly trendline to stop on Friday instead of Saturday
//                            - Added push notifications to be sent by terminal
//       06/15/18 L. Garcia   - Added "Not supported" alert if iTimePeriod parameter is set to Current
//                            - Added error checking to critical functions
//                            - Added notifications when price touches any pivot and/or midpoint levels
// 2.1   09/07/18 L. Garcia   - Added time shift functionality for server GMT offset
//                            - Removed "Alert!" word from push notification string
//                            - Allow plot borders on future pivots if enabled
//                            - Allow re-send of push notification on failure
//                            - Renamed some input parameters for grouping/readability purposes
//                            - Added input parameter descriptions within code 
//--------------------------------------------------------------------
// List of acronyms used within expert logs and push notifications.
//
// R3: 3rd Resistance
// R2: 2nd Resistance
// R1: 1st Resistance
// PP: Pivot Point
// S1: 1st Support
// S2: 2nd Support
// S3: 3rd Support
// M5: Midpoint 5
// M4: Midpoint 4
// M3: Midpoint 3
// M2: Midpoint 2
// M1: Midpoint 1
// M0: Midpoint 0
// M1XX: Minute pivot levels
// M5XX: 5 minute pivot levels
// M15XX: 15 minute pivot levels
// M30XX: 30 minute pivot levels
// H1XX: 1 hour pivot levels
// H4XX: 4 hour pivot levels
// D1XX: Daily pivot levels
// W1XX: Weely pivot levels
// MN1XX: Montly pivot levels
// FXXXX: Future pivot levels
//--------------------------------------------------------------------
// Input parameter descriptions.
//
// iCountPeriods:
//    The number of pivot periods to plot on the chart. Valid values
//    include anything greater than 0.
// iTimePeriod:
//    The time period used to plot pivot levels. Most common values
//    include PERIOD_D1, PERIOD_W1, and PERIOD_MN1.
// iShiftHours:
//    Specifies the GMT hour shift from the broker's daily close. This 
//    value is used in case the day needs to be shifted by a certain 
//    number of hours. Only daily pivots are affected by this value. Set
//    the value to 0 if this feature is not desired. Valid values are
//    between -14 and 12.
//
// iPlotPivots:
//    Plots the current and history pivots to the chart.
// iPlotPivotFutures:
//    Plots future pivots to the chart. Future pivots are calculated
//    using price open/high/low for the current time period and are
//    updated at every tick.
// iPlotPivotLabels:
//    Plots the pivot level labels on the right side of the pivot line. 
//    Labels start with the specified time period and then the pivot name
//    such as S1, M4, etc. An "F" in front of the label indicates a 
//    future pivot label.
// iPlotPivotPrices:
//    Plots the pivot level price on the left side of the pivot line.
//    Prices are shown to as many digits there are for the selected
//    symbol.
// iPlotPivotStyles:
//    Specifies the line style for the pivot level plots.
// iPlotPivotWidths:
//    Specifies the line width for the pivot level plots.
// iPlotPivotColorRes:
//    Specifies the line color for the resistance 1-3 pivot levels.
// iPlotPivotColorPP:
//    Specifies the line color for the central pivot level.
// iPlotPivotColorSup:
//    Specifies the line color for the support 1-3 pivot levels.
//
// iPlotMidpoints:
//    Plots the current and history midpoint levels to the chart.
// iPlotMidpointStyles:
//    Specifies the line style for the midpoint level plots.
// iPlotMidpointWidths:
//    Specifies the line width for the midpoint level plots.
// iPlotMidpointColorM35:
//    Specifies the line color for the midpoint 3-5 levels.
// iPlotMidpointColorM02:
//    Specifies the line color for the midpoint 0-2 levels.
//
// iPlotZones:
//    Plots the current and history buy/sell zones to the chart.
//    The buy zone is plotted between M1 and S2. The sell zone is
//    plotted between M4 and R2.
// iPlotBuyZoneColor:
//    Specifies the buy zone color.
// iPlotSellZoneColor:
//    Specifies the sell zone color.
//
// iPlotBorders:
//    Plots the current and history left/right borders to the chart.
//    Borders identify the start/end bars for the time period. 
// iPlotBorderStyles:
//    Specifies the line style for the border plots.
// iPlotBorderWidths:
//    Specifies the line width for the border plots.
// iPlotBorderColors:
//    Specifies the line color for the border plots.
//
// iPushNotifications_AllPivotsMidpoints:
//    Sends all pivot and midpoint calculations to mobile terminal
//    whenever they are available.
// iPushNotifications_TouchPP:
//    Sends notification whenever price touches the central pivot point.
// iPushNotifications_TouchR1S1:
//    Sends notification whenever price touches the R1 or S1 pivot levels.
// iPushNotifications_TouchR2S2:
//    Sends notification whenever price touches the R2 or S2 pivot levels.
// iPushNotifications_TouchR3S3:
//    Sends notification whenever price touches the R3 or S3 pivot levels.
// iPushNotifications_TouchM2M3:
//    Sends notification whenever price touches the M2 or M3 pivot levels.
// iPushNotifications_TouchM1M4:
//    Sends notification whenever price touches the M1 or M4 pivot levels.
// iPushNotifications_TouchM0M5:
//    Sends notification whenever price touches the M0 or M5 pivot levels.
// iPushNotifications_TouchToleranceInDigits:
//    Specifies the tolerance in chart digits for the above price touches.
//    The notification will be sent when price gets close to the pivot
//    level. This value is in positive chart digits. For example, if the 
//    symbol is a 5 digit chart and you want to specify a 2 pip tolerance, 
//    then this value needs to be set to 20 because of the extra digit of 
//    the terminal. This value may be set to zero, if desired. Once the 
//    price alert is sent, the program will not send another notification 
//    until price touches a different level or the program is reloaded.
//
// NOTE on push notifications: The system only allows for 2 notifications
//    to be sent every second and a max of 10 notifications per minute.
//    In case the notification fails to be sent then the program will
//    try again a few seconds later. This feature may be disabled by MT4 if
//    abused.
//--------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers   0

// external inputs
extern int              iCountPeriods         = 2;
extern ENUM_TIMEFRAMES  iTimePeriod           = PERIOD_D1;
extern int              iShiftHours           = 0;

extern bool             iPlotPivots           = true;
extern bool             iPlotPivotFutures     = true;
extern bool             iPlotPivotLabels      = true;
extern bool             iPlotPivotPrices      = true;
extern ENUM_LINE_STYLE  iPlotPivotStyles      = STYLE_SOLID;
extern int              iPlotPivotWidths      = 2;
extern color            iPlotPivotColorRes    = clrRed;
extern color            iPlotPivotColorPP     = clrBlack;
extern color            iPlotPivotColorSup    = clrGreen;

extern bool             iPlotMidpoints        = true;
extern ENUM_LINE_STYLE  iPlotMidpointStyles   = STYLE_DASH;
extern int              iPlotMidpointWidths   = 1;
extern color            iPlotMidpointColorM35 = clrRed;
extern color            iPlotMidpointColorM02 = clrGreen;

extern bool             iPlotZones            = true;
extern color            iPlotBuyZoneColor     = clrLightSeaGreen;
extern color            iPlotSellZoneColor    = clrLightSalmon;

extern bool             iPlotBorders          = false;
extern ENUM_LINE_STYLE  iPlotBorderStyles     = STYLE_SOLID;
extern int              iPlotBorderWidths     = 1;
extern color            iPlotBorderColors     = clrBlack;

extern bool             iPushNotifications_AllPivotsMidpoints     = False;
extern bool             iPushNotifications_TouchPP                = False;
extern bool             iPushNotifications_TouchR1S1              = False;
extern bool             iPushNotifications_TouchR2S2              = False;
extern bool             iPushNotifications_TouchR3S3              = False;
extern bool             iPushNotifications_TouchM2M3              = False;
extern bool             iPushNotifications_TouchM1M4              = False;
extern bool             iPushNotifications_TouchM0M5              = False;
extern int              iPushNotifications_TouchToleranceInDigits = 20;

extern string Toggle_Button = "";
extern bool btn_show = 0;
extern string btn_pressed = "WP Show";
extern string btn_unpressed = "WP Hide";
extern int btn_offset_x = 10;
extern int btn_offset_y = 20;
extern int btn_font_size = 10;
extern int btn_width = 65;
extern int btn_height = 20;
extern color btn_font_clr = clrBlack;
extern color btn_bg_color = clrGray;
extern color btn_border_clr = clrWhiteSmoke;


// constants
#define  MAX_NUM_NOTIFICATION_QUEUE       10
#define  MAX_TIMER_EVENT_ELAPSED_IN_SECS  10

// global variables
string   gPeriod = "";
int      gRealTimePeriod = 0;
datetime gPrevTimePivot = 0;
double   gPrevTouchPrice = 0.0;
double   gTouchToleranceDecimal = 0.0;
int      gNumNotificationQueue = 0;
string   gNotificationQueue[MAX_NUM_NOTIFICATION_QUEUE] = {NULL};

//+------------------------------------------------------------------+
// init - This function will set the period string and real time. The
//    period string is used on label plots and object names. The real
//    time period is used to plot correct time lenghts on higher 
//    timeframes. 
//+------------------------------------------------------------------+
int init()
{
   int error = 0;
   int timerVal = 0;
   
   // calculate decimal prices according to digits
   gTouchToleranceDecimal = iPushNotifications_TouchToleranceInDigits / MathPow(10, Digits);
   
   // go through each timeframe and assign period string and real time period minutes
   // NOTE: real minutes are used to calculate end times and future times
   switch (iTimePeriod)
   {
      case PERIOD_M1:
         gPeriod = "M1";
         gRealTimePeriod = PERIOD_M1;  // 1 minute
         break;
      case PERIOD_M5:
         gPeriod = "M5";
         gRealTimePeriod = PERIOD_M5;  // 5 minutes
         break;
      case PERIOD_M15:
         gPeriod = "M15";
         gRealTimePeriod = PERIOD_M15; // 15 minutes
         break;
      case PERIOD_M30:
         gPeriod = "M30";
         gRealTimePeriod = PERIOD_M30; // 30 minutes
         break;
      case PERIOD_H1:
         gPeriod = "H1";
         gRealTimePeriod = PERIOD_H1;  // 60 minutes
         break;
      case PERIOD_H4:
         gPeriod = "H4";
         gRealTimePeriod = PERIOD_H4;  // 240 minutes
         break;
      case PERIOD_D1:
         gPeriod = "D1";
         gRealTimePeriod = PERIOD_D1;  // 1440 minutes
         break;
      case PERIOD_W1:
         gPeriod = "W1";
         gRealTimePeriod = 8640;       // 8640 minutes (update to draw weekly line for 6 days only)
         break;
      case PERIOD_MN1:
         gPeriod = "MN1";
         gRealTimePeriod = PERIOD_MN1; // 43200 minutes (30 days)
         break;
      default:
         gPeriod = "";
         Alert("iTimePeriod param specified is not supported.");
         break;
   }
   
   // check if shift hours is used and within GMT range (GMT-12 through GMT+14)
   if (iShiftHours > 12 || iShiftHours < -14)
   {
      Alert("iShiftHours param specified is out-of-range. Valid values are between -14 and 12. Re-setting to 0.");
      iShiftHours = 0;
   }
   
   // create random timer value between 1 and MAX defined
   MathSrand(GetTickCount()); 
   timerVal = MathRand() % MAX_TIMER_EVENT_ELAPSED_IN_SECS;
   if (timerVal <= 0)
   {
      timerVal = MAX_TIMER_EVENT_ELAPSED_IN_SECS;
   }
   
   // troubleshooting log
   //Print("timerVal: ", IntegerToString(timerVal));
      
   // start timer event handler
   if (EventSetTimer(timerVal) == false)
   {
      // print error to log
      error = GetLastError();
      Print("<= Error starting timer event handler => ", error);
   }
   
   if(btn_show){CreateButton();}
   if(!btn_show){ObjectDelete("WP_btn");}
   return(0);
}

//+------------------------------------------------------------------+
// deinit - This function will delete all objects on the chart. 
//+------------------------------------------------------------------+
int deinit()
{
   // delete all objects and remove timer event handler
   DeleteAllObjects();
   ObjectDelete("WP_btn");
   EventKillTimer();
   return(0);
}

//+------------------------------------------------------------------+
// OnTimer - This timer event handler will resend push notifications
//    in case of a frequency violation. According to MT4, no more than
//    2 notifications per second or 10 notifications per minute. This
//    function will try sending again on every second elapsed.
//    In the event that the queue gets maxed out this function will
//    flush all queued notifications.
//+------------------------------------------------------------------+
void OnTimer()
{
   int error = 0;
   int i = 0;
   
   // check if notification queue is not empty
   if (gNumNotificationQueue > 0 && gNumNotificationQueue < MAX_NUM_NOTIFICATION_QUEUE)
   {
      // loop through all queued notifications and try to send them
      for (i = 0; i < gNumNotificationQueue; i++)
      {
         // check if string queue is not empty
         if (StringLen(gNotificationQueue[i]) > 0)
         {
            // send notification and check for error
            if (SendNotification(gNotificationQueue[i]) == false)
            {
               // print error to log and exit (possibly too frequent)
               error = GetLastError();
               Print("<= Error sending notification => ", error);
               return;
            }
            else
            {
               // notification was sent successfully... clear string buffer and exit
               // NOTE: will send the next notification on the next timer elapsed
               gNotificationQueue[i] = "";
               return;
            }
         }
      }  // end of notification queue (for loop)
      
      // check if sending all notifications was a success and reset queue num
      if (error == 0)
      {
         gNumNotificationQueue = 0;
      }
   }  // end of notification buffer check (if statement)
   else if (gNumNotificationQueue >= MAX_NUM_NOTIFICATION_QUEUE)
   {
      // queue buffer is maxed out and terminal cannot keep up... flush buffer to start over
      for (i = 0; i < gNumNotificationQueue; i++)
      {
         gNotificationQueue[i] = "";
      }
      gNumNotificationQueue = 0;
   }
   
   return;
}

//+------------------------------------------------------------------+
// start - This function will calculate the start/end times for the
//    objects on the specified timeframe and draw the pivots for all 
//    history counts and future pivots. 
//+------------------------------------------------------------------+
int start()
{
   int error = 0;
   int shift = 0;
   int startBarShift = 0;
   int endBarShift = 0;
   datetime timeStartObj;
   datetime timeEndObj;
   
   // remove all objects upon entry
   DeleteAllObjects();
   
   if(ObjectGetInteger(0,"WP_btn",OBJPROP_STATE)){return(0);}
   else if(!ObjectGetInteger(0,"WP_btn",OBJPROP_STATE) || !btn_show)
   {
   // draw current and history pivots/midpoints
   if (iPlotPivots && iTimePeriod != 0)
   {
      for (shift = 0; shift < iCountPeriods; shift++)
      {
         // clear loop variables
         error = 0;
         
         // calculate start/end times for current/previous objects
         // NOTE: check if daily period was selected and hour shift is used
         if (iTimePeriod == PERIOD_D1 && iShiftHours != 0)
         {            
            // NOTE: start/end shift times for objects are used only
            error = GetShiftInfo(shift, startBarShift, endBarShift, timeStartObj, timeEndObj);
         }
         else
         {
            timeStartObj = iTime(NULL, iTimePeriod, shift);
            timeEndObj   = iTime(NULL, iTimePeriod, shift) + (gRealTimePeriod * 60); 
         }
         
         // check for valid values and draw levels
         if (error == 0)
         {
            // NOTE: increment function shift since previous bar is used to calculate current bar's pivots
            LevelsDraw(shift + 1, timeStartObj, timeEndObj, gPeriod, false);    
         }            
      }
   }
   
   // draw future pivots/midpoints
   if (iPlotPivotFutures && iTimePeriod != 0)
   {
      // calculate start/end times for future objects
      // NOTE: check if daily period was selected and hour shift is used
      if (iTimePeriod == PERIOD_D1 && iShiftHours != 0)
      {
         // NOTE: start/end shift times for objects are used only
         error = GetShiftInfo(0, startBarShift, endBarShift, timeStartObj, timeEndObj);
         
         // add another day (shift) to calculate both start/end shifted times for future calculations
         timeStartObj = timeEndObj; 
         timeEndObj = timeStartObj + (gRealTimePeriod * 60);
      }
      else
      {
         timeStartObj = iTime(NULL, iTimePeriod, 0) + (gRealTimePeriod * 60);
         timeEndObj   = iTime(NULL, iTimePeriod, 0) + (gRealTimePeriod * 120);
      }
      
      // troubleshooting log
      //Print(" timeStartObj: ", IntegerToString(timeStartObj), " timeEndObj: ", IntegerToString(timeEndObj));
         
      // NOTE: current bar (shift = 0) is used to calculate future pivots
      LevelsDraw(0, timeStartObj, timeEndObj, "F" + gPeriod, true);      
   }
   
   // send push notifications to terminal
   if (iTimePeriod != 0)
   {         
      SendPushNotifications();
   }
   
   }//end btn show status
   return(0);
}

//+------------------------------------------------------------------+
// SendPushNotifications - This function will calculate the current
//    period's pivot points and send them as push notifications to the
//    terminal.
//+------------------------------------------------------------------+
int SendPushNotifications(void)
{
   int error = 0;
   double pivP = 0.0;
   double res1 = 0.0;
   double res2 = 0.0;
   double res3 = 0.0;
   double sup1 = 0.0;
   double sup2 = 0.0;
   double sup3 = 0.0;
   double mid0 = 0.0;
   double mid1 = 0.0;
   double mid2 = 0.0;
   double mid3 = 0.0;
   double mid4 = 0.0;
   double mid5 = 0.0;
   string msg = "";
   string pivMsg = "";
   string midMsg = "";
   int startBarShift = 0;
   int endBarShift = 0;
   datetime currBarTime = 0;
   datetime endTimeShift = 0;
   double currBarPrice = 0.0;
   
   if (iTimePeriod == PERIOD_D1 && iShiftHours != 0)
   {   
      // NOTE: only the start time shift is used in this function
      error = GetShiftInfo(0, startBarShift, endBarShift, currBarTime, endTimeShift);
   }
   else
   {
      // get the current bar time and check for error
      currBarTime = iTime(NULL, iTimePeriod, 0);
      if (currBarTime == 0)
      {
         // print error to log and exit function
         error = GetLastError();
         Print("<= Error getting current bar time => ", error);
         return error;
      }
   }
   
   // get the current bid price and check for error
   currBarPrice = Bid;
   if (currBarPrice == 0)
   {
      // print error to log and exit function
      error = GetLastError();
      Print("<= Error getting current bid price => ", error);
      return error;
   }
   
   // get pivot points and midpoint levels for current period (shift = 1)
   error = GetPivotPoints(iTimePeriod, 1, pivP, res1, res2, res3, sup1, sup2, sup3, mid0, mid1, mid2, mid3, mid4, mid5);
   if (error != 0)
   {
      return error;
   }
   
   // create pivots message if enabled
   if (iPlotPivots)
   {
      pivMsg = StringConcatenate(
               ", ", gPeriod, "R3: ", DoubleToStr(res3, Digits), 
               ", ", gPeriod, "R2: ", DoubleToStr(res2, Digits), 
               ", ", gPeriod, "R1: ", DoubleToStr(res1, Digits), 
               ", ", gPeriod, "PP: ", DoubleToStr(pivP, Digits), 
               ", ", gPeriod, "S1: ", DoubleToStr(sup1, Digits), 
               ", ", gPeriod, "S2: ", DoubleToStr(sup2, Digits), 
               ", ", gPeriod, "S3: ", DoubleToStr(sup3, Digits));
   }
   
   // create midpoints message if enabled
   if (iPlotMidpoints)
   {     
      midMsg = StringConcatenate(
               ", ", gPeriod, "M5: ", DoubleToStr(mid5, Digits), 
               ", ", gPeriod, "M4: ", DoubleToStr(mid4, Digits), 
               ", ", gPeriod, "M3: ", DoubleToStr(mid3, Digits), 
               ", ", gPeriod, "M2: ", DoubleToStr(mid2, Digits), 
               ", ", gPeriod, "M1: ", DoubleToStr(mid1, Digits), 
               ", ", gPeriod, "M0: ", DoubleToStr(mid0, Digits));
   }
   
   // check for push notifications enabled
   if (iPushNotifications_AllPivotsMidpoints == True &&
         (gPrevTimePivot == 0 || gPrevTimePivot != currBarTime))   // initial program start or a new time period has begun
   {
	   // update prev time global to current period so we wont enter here again
      gPrevTimePivot = currBarTime;
      
      // add push notification to queue and print msg to log
      Print(Symbol() + pivMsg + midMsg);
      if (gNumNotificationQueue < MAX_NUM_NOTIFICATION_QUEUE)
      {
         gNotificationQueue[gNumNotificationQueue] = StringConcatenate(Symbol() + pivMsg + midMsg);
         gNumNotificationQueue++;
      }
   }
   
   // check/send pivot point touches
   SendPushNotifications_Touch(iPushNotifications_TouchPP, "PP", pivP, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR1S1, "R1", res1, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR1S1, "S1", sup1, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR2S2, "R2", res2, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR2S2, "S2", sup2, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR3S3, "R3", res3, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR3S3, "S3", sup3, currBarPrice);
   
   // check/send midpoint touches
   SendPushNotifications_Touch(iPushNotifications_TouchM2M3, "M2", mid2, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM2M3, "M3", mid3, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM1M4, "M1", mid1, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM1M4, "M4", mid4, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM0M5, "M0", mid0, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM0M5, "M5", mid5, currBarPrice);

   return error;
}

//+------------------------------------------------------------------+
// SendPushNotifications_Touch - This function will check if the touch
//    feature is enabled and calculate if the current price is near
//    the target price in order to send a price alert as a push 
//    notification to the terminal. The function will also check if 
//    the notification has already been sent to avoid multiple sends.
//
// Returns: 0 = not sent; 1 = was sent.
//+------------------------------------------------------------------+
int SendPushNotifications_Touch( bool FeatureEnabled,
                                 string LevelStr,
                                 double TargetPrice,
                                 double CurrBarPrice)
{
   int sent = 0;
   string msg = "";
   
   // check if previous touch price has been initialized
   // NOTE: happens during initial program load or system reset
   if (gPrevTouchPrice < 0.0000001)
   {
      gPrevTouchPrice = CurrBarPrice;
   }
   
   // check if feature is enabled and at target price
   if (FeatureEnabled == True &&
       MathAbs(TargetPrice - gPrevTouchPrice) > 0.0000001 &&                 // price has not already touched before (double compare)
         (MathAbs(TargetPrice - CurrBarPrice) <= gTouchToleranceDecimal ||   // current price is close to target price -or-
          (gPrevTouchPrice < TargetPrice && TargetPrice < CurrBarPrice) ||   // target price is between last touch and current price (gaps)
          (gPrevTouchPrice > TargetPrice && TargetPrice > CurrBarPrice)))
   {
      // update prev touch price global to target price so we wont enter here again
      gPrevTouchPrice = TargetPrice;
      
      // add push notification to queue and print msg to log
      msg = StringConcatenate(Symbol(), ", Price touched ", gPeriod, LevelStr, " at ", DoubleToStr(TargetPrice, Digits));
      Print(msg);
      if (gNumNotificationQueue < MAX_NUM_NOTIFICATION_QUEUE)
      {
         gNotificationQueue[gNumNotificationQueue] = StringConcatenate(msg);
         gNumNotificationQueue++;
      }
      
      // set notification sent return variable
      sent = 1;
   }
   
   return sent;
}


//+------------------------------------------------------------------+
// LevelsDraw - This function will get the pivot levels for the
//    specified timeframe and plot them to the chart using the 
//    specified start/end times for all chart objects. 
//+------------------------------------------------------------------+
int LevelsDraw(   int      Shift,
                  datetime TimeStartObj, 
                  datetime TimeEndObj, 
                  string   PeriodStr,
                  bool     IsFuture)
{
   int error = 0;
   double pivP = 0.0;         // Pivot Levels
   double res1 = 0.0;
   double res2 = 0.0;
   double res3 = 0.0;
   double sup1 = 0.0;
   double sup2 = 0.0;
   double sup3 = 0.0;
   double mid0 = 0.0;
   double mid1 = 0.0;
   double mid2 = 0.0;
   double mid3 = 0.0;
   double mid4 = 0.0;
   double mid5 = 0.0;
   
   // get pivot points and midpoint levels
   error = GetPivotPoints(iTimePeriod, Shift, pivP, res1, res2, res3, sup1, sup2, sup3, mid0, mid1, mid2, mid3, mid4, mid5);
   if (error != 0)
   {
      return error;
   }
   
   // plot zones if enabled
   if (iPlotZones)
   {
      PlotRectangle(0, PeriodStr + "BZ_" + Shift, 0, TimeStartObj, mid1, TimeEndObj, sup2, iPlotBuyZoneColor);    
      PlotRectangle(0, PeriodStr + "SZ_" + Shift, 0, TimeStartObj, mid4, TimeEndObj, res2, iPlotSellZoneColor);
   }
   
   // plot pivots if enabled
   if (iPlotPivots)
   {                                 
      // plot trendline for pivot levels
      PlotTrend(0, PeriodStr + "R3_T" + Shift, 0, TimeStartObj, res3, TimeEndObj, res3, iPlotPivotColorRes, iPlotPivotStyles, iPlotPivotWidths);     
      PlotTrend(0, PeriodStr + "R2_T" + Shift, 0, TimeStartObj, res2, TimeEndObj, res2, iPlotPivotColorRes, iPlotPivotStyles, iPlotPivotWidths);     
      PlotTrend(0, PeriodStr + "R1_T" + Shift, 0, TimeStartObj, res1, TimeEndObj, res1, iPlotPivotColorRes, iPlotPivotStyles, iPlotPivotWidths);     
      PlotTrend(0, PeriodStr + "PP_T" + Shift, 0, TimeStartObj, pivP, TimeEndObj, pivP, iPlotPivotColorPP, iPlotPivotStyles, iPlotPivotWidths);     
      PlotTrend(0, PeriodStr + "S1_T" + Shift, 0, TimeStartObj, sup1, TimeEndObj, sup1, iPlotPivotColorSup, iPlotPivotStyles, iPlotPivotWidths);     
      PlotTrend(0, PeriodStr + "S2_T" + Shift, 0, TimeStartObj, sup2, TimeEndObj, sup2, iPlotPivotColorSup, iPlotPivotStyles, iPlotPivotWidths);     
      PlotTrend(0, PeriodStr + "S3_T" + Shift, 0, TimeStartObj, sup3, TimeEndObj, sup3, iPlotPivotColorSup, iPlotPivotStyles, iPlotPivotWidths);
      
      if (iPlotPivotLabels)
      {
         PlotText(0, PeriodStr + "R3_L" + Shift, 0, TimeEndObj, res3, PeriodStr + "R3", "Arial", 8, iPlotPivotColorRes, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "R2_L" + Shift, 0, TimeEndObj, res2, PeriodStr + "R2", "Arial", 8, iPlotPivotColorRes, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "R1_L" + Shift, 0, TimeEndObj, res1, PeriodStr + "R1", "Arial", 8, iPlotPivotColorRes, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "PP_L" + Shift, 0, TimeEndObj, pivP, PeriodStr + "PP", "Arial", 8, iPlotPivotColorPP, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "S1_L" + Shift, 0, TimeEndObj, sup1, PeriodStr + "S1", "Arial", 8, iPlotPivotColorSup, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "S2_L" + Shift, 0, TimeEndObj, sup2, PeriodStr + "S2", "Arial", 8, iPlotPivotColorSup, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "S3_L" + Shift, 0, TimeEndObj, sup3, PeriodStr + "S3", "Arial", 8, iPlotPivotColorSup, ANCHOR_RIGHT_UPPER);
      }    
      
      if (iPlotPivotPrices)
      {
         PlotText(0, PeriodStr + "R3_P" + Shift, 0, TimeStartObj, res3, DoubleToString(res3, Digits), "Arial", 8, iPlotPivotColorRes, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "R2_P" + Shift, 0, TimeStartObj, res2, DoubleToString(res2, Digits), "Arial", 8, iPlotPivotColorRes, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "R1_P" + Shift, 0, TimeStartObj, res1, DoubleToString(res1, Digits), "Arial", 8, iPlotPivotColorRes, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "PP_P" + Shift, 0, TimeStartObj, pivP, DoubleToString(pivP, Digits), "Arial", 8, iPlotPivotColorPP, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "S1_P" + Shift, 0, TimeStartObj, sup1, DoubleToString(sup1, Digits), "Arial", 8, iPlotPivotColorSup, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "S2_P" + Shift, 0, TimeStartObj, sup2, DoubleToString(sup2, Digits), "Arial", 8, iPlotPivotColorSup, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "S3_P" + Shift, 0, TimeStartObj, sup3, DoubleToString(sup3, Digits), "Arial", 8, iPlotPivotColorSup, ANCHOR_LEFT_UPPER);
      }
   }    
   
   // plot midpoints if enabled
   if (iPlotMidpoints)
   {
      // plot trendline for midpoint levels
      PlotTrend(0, PeriodStr + "M0_T" + Shift, 0, TimeStartObj, mid0, TimeEndObj, mid0, iPlotMidpointColorM02, iPlotMidpointStyles, iPlotMidpointWidths);     
      PlotTrend(0, PeriodStr + "M1_T" + Shift, 0, TimeStartObj, mid1, TimeEndObj, mid1, iPlotMidpointColorM02, iPlotMidpointStyles, iPlotMidpointWidths);     
      PlotTrend(0, PeriodStr + "M2_T" + Shift, 0, TimeStartObj, mid2, TimeEndObj, mid2, iPlotMidpointColorM02, iPlotMidpointStyles, iPlotMidpointWidths);     
      PlotTrend(0, PeriodStr + "M3_T" + Shift, 0, TimeStartObj, mid3, TimeEndObj, mid3, iPlotMidpointColorM35, iPlotMidpointStyles, iPlotMidpointWidths);     
      PlotTrend(0, PeriodStr + "M4_T" + Shift, 0, TimeStartObj, mid4, TimeEndObj, mid4, iPlotMidpointColorM35, iPlotMidpointStyles, iPlotMidpointWidths);     
      PlotTrend(0, PeriodStr + "M5_T" + Shift, 0, TimeStartObj, mid5, TimeEndObj, mid5, iPlotMidpointColorM35, iPlotMidpointStyles, iPlotMidpointWidths);

      if (iPlotPivotLabels)
      {
         PlotText(0, PeriodStr + "M0_L" + Shift, 0, TimeEndObj, mid0, PeriodStr + "M0", "Arial", 8, iPlotMidpointColorM02, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "M1_L" + Shift, 0, TimeEndObj, mid1, PeriodStr + "M1", "Arial", 8, iPlotMidpointColorM02, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "M2_L" + Shift, 0, TimeEndObj, mid2, PeriodStr + "M2", "Arial", 8, iPlotMidpointColorM02, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "M3_L" + Shift, 0, TimeEndObj, mid3, PeriodStr + "M3", "Arial", 8, iPlotMidpointColorM35, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "M4_L" + Shift, 0, TimeEndObj, mid4, PeriodStr + "M4", "Arial", 8, iPlotMidpointColorM35, ANCHOR_RIGHT_UPPER);
         PlotText(0, PeriodStr + "M5_L" + Shift, 0, TimeEndObj, mid5, PeriodStr + "M5", "Arial", 8, iPlotMidpointColorM35, ANCHOR_RIGHT_UPPER);
      }
      
      if (iPlotPivotPrices)
      {
         PlotText(0, PeriodStr + "M0_P" + Shift, 0, TimeStartObj, mid0, DoubleToString(mid0, Digits), "Arial", 8, iPlotMidpointColorM02, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "M1_P" + Shift, 0, TimeStartObj, mid1, DoubleToString(mid1, Digits), "Arial", 8, iPlotMidpointColorM02, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "M2_P" + Shift, 0, TimeStartObj, mid2, DoubleToString(mid2, Digits), "Arial", 8, iPlotMidpointColorM02, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "M3_P" + Shift, 0, TimeStartObj, mid3, DoubleToString(mid3, Digits), "Arial", 8, iPlotMidpointColorM35, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "M4_P" + Shift, 0, TimeStartObj, mid4, DoubleToString(mid4, Digits), "Arial", 8, iPlotMidpointColorM35, ANCHOR_LEFT_UPPER);
         PlotText(0, PeriodStr + "M5_P" + Shift, 0, TimeStartObj, mid5, DoubleToString(mid5, Digits), "Arial", 8, iPlotMidpointColorM35, ANCHOR_LEFT_UPPER);
      }
   }   
   
   // plot left/right borders if enabled
   if (iPlotBorders)
   {
      PlotTrend(0, PeriodStr + "BDL_" + Shift, 0, TimeStartObj, res3, TimeStartObj, sup3, iPlotBorderColors, iPlotBorderStyles, iPlotBorderWidths);
      PlotTrend(0, PeriodStr + "BDR_" + Shift, 0, TimeEndObj, res3, TimeEndObj, sup3, iPlotBorderColors, iPlotBorderStyles, iPlotBorderWidths);
   }
   
   return error;
}

//+------------------------------------------------------------------+
// GetShiftInfo - This function will calculate the start and end 
//    hourly bar and time shifts.
//+------------------------------------------------------------------+
int GetShiftInfo( int Shift,
                  int &StartBarShift,
                  int &EndBarShift,
                  datetime &StartTimeShift,
                  datetime &EndTimeShift)
{
   int error = 0;
   int ShiftedFlag = 0;
   int tempBarShift = 0;
   int DailyShift = Shift;    // in case if modified
   
   // reset params on entry
   StartBarShift = -1;
   EndBarShift = -1;
   StartTimeShift = 0;
   EndTimeShift = 0;
   
   // first, calculate hourly shift for current day overlaps
   tempBarShift = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, 0), False);
   tempBarShift += iShiftHours;
   
   // check if hourly shift is negative
   // NOTE: this may happen on iShiftHours < 0 and day open is near
   if (tempBarShift < 0)
   {
      // add a day shift for accurate pivot calculations and set shifted flag
      DailyShift++;
      ShiftedFlag = 1;
   }
   // check if hourly shift is over a day (24 hours)
   // NOTE: this may happen on iShiftHours > 0 and day close is near
   else if (/*iShiftHours > 0 && */tempBarShift > 24)
   {
      // subtract a day shift for accurate pivot calculations and set shifted flag
      // NOTE: shift cannot be negative
      if (DailyShift > 0)
      {
         DailyShift--;
      }
      ShiftedFlag = -1;
   }
   
   // get the shift for the start bar (shift in hours for the start of day)
   StartBarShift = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, DailyShift), False);
   StartBarShift += iShiftHours;
   
   // check for valid start hourly bar shift (non-negative)
   if (StartBarShift >= 0)
   {
      // get shifted start time and check if valid (greater than zero)
      StartTimeShift = iTime(NULL, PERIOD_H1, StartBarShift);
      if (StartTimeShift > 0)
      {
         // check for current/future shift calculation
         if (DailyShift > 0)
         {
            // get the shift for the end bar (shift in hours for the end of day)
            // NOTE: end bar shift should be 1 hour before the end of day for accurate pivot calculations (day close = last hour close)
            EndBarShift = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, DailyShift - 1), False);
            EndBarShift += iShiftHours + 1;
         }
         else
         {            
            // get the shift for the end bar (shift in hours for the end of day)
            // NOTE: end bar shift should be 1 hour before the end of day for accurate pivot calculations (day close = last hour close)
            // NOTE: use the current daily shift instead (= 0, same as start) and shift hours right
            EndBarShift = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, DailyShift), False);
            EndBarShift -= 24 - iShiftHours - 1;
         }
         
         // check for valid end hourly bar shift (non-negative)
         if (EndBarShift > 0)
         {
            // get shifted end time
            // NOTE: add another hourly bar (1 less shift) so that there won't be any gaps in the lines
            EndTimeShift = iTime(NULL, PERIOD_H1, EndBarShift - 1);
         }
         else
         {
            // use current bar for end shift and calculate end time by adding a day to the shifted start time
            // NOTE: use the latest bar's time in case of weekend gaps, then add whatever hours are left
            EndBarShift = 0;
            EndTimeShift = iTime(NULL, PERIOD_H1, 0) + (MathAbs(StartBarShift - 24) * 60 * 60);
         }
         
         // check for accurate start/end calculations
         // NOTE: this may happen on initial day and if day was shifted
         if (Shift == 0 && ShiftedFlag == -1)
         {
            // update start/end params
            StartTimeShift = EndTimeShift;
            StartBarShift = iBarShift(NULL, PERIOD_H1, StartTimeShift, False);
            
            EndBarShift = 0;
            EndTimeShift = iTime(NULL, PERIOD_H1, 0) + (MathAbs(StartBarShift - 24) * 60 * 60);
         }
      }
   }
   
   // check for valid params on exit
   if (StartBarShift < 0 || EndBarShift < 0 ||
       StartTimeShift <= 0 || EndTimeShift <= 0)
   {
      error = -1;
   }
   
   // troubleshooting log
   //Print("Shift: ", IntegerToString(Shift), " DailyShift: ", IntegerToString(DailyShift), 
   //      " ShiftedFlag: ", IntegerToString(ShiftedFlag), " error: ", IntegerToString(error),
   //      " SBS: ", IntegerToString(StartBarShift), " EBS: ", IntegerToString(EndBarShift), 
   //      " Range (inclusive): ", IntegerToString(StartBarShift - EndBarShift + 1),
   //      " STS: ", IntegerToString(StartTimeShift), " ETS: ", IntegerToString(EndTimeShift));
   
   return error;
}

//+------------------------------------------------------------------+
// GetPivotPoints - This function will calculate the pivot points and
//    midpoint levels for the timeframe and shift specified. This 
//    function also checks if there is a GMT offset on the daily time
//    frame and adjust the pivot calculations accordingly.
//+------------------------------------------------------------------+
int GetPivotPoints(  int TimeFrame,
                     int Shift,
                     double &PP,
                     double &R1, double &R2, double &R3,
                     double &S1, double &S2, double &S3,
                     double &M0, double &M1, double &M2, double &M3, double &M4, double &M5)
{
   int error = 0;
   double barOpen = 0.0;
   double barHigh = 0.0;
   double barLow = 0.0;
   double barClose = 0.0;
   int startBarShift = 0;
   int endBarShift = 0;
   datetime startTimeShift = 0;
   datetime endTimeShift = 0;
   
   // clear output params on entry
   PP = 0.0;
   R1 = 0.0; R2 = 0.0; R3 = 0.0;
   S1 = 0.0; S2 = 0.0; S3 = 0.0;
   M0 = 0.0; M1 = 0.0; M2 = 0.0; M3 = 0.0; M4 = 0.0; M5 = 0.0;

   // calculate daily bar start/end hourly shift for shifted hours
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
   {
      // get start/end bar shift info
      // NOTE: time shift is not used in this function
      GetShiftInfo(Shift, startBarShift, endBarShift, startTimeShift, endTimeShift);
   }
   
   // get bar open price and check for error
   // NOTE: check for daily period and shift hours enabled
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
   {
      barOpen = iOpen(NULL, PERIOD_H1, startBarShift);
   }
   else
   {
      barOpen = iOpen(NULL, TimeFrame, Shift);
   }
   if (barOpen == 0)
   {
      // print error to log and exit function
      error = GetLastError();
      Print("<= Error getting current bar open => ", error);
      return error;
   }
   
   // get bar close price and check for error
   // NOTE: check for daily period and shift hours enabled
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
   {
      barClose = iClose(NULL, PERIOD_H1, endBarShift);
   }
   else
   {
      // NOTE: if shift = 0 then function returns current bar price
      barClose = iClose(NULL, TimeFrame, Shift);
   }
   if (barClose == 0)
   {
      // print error to log and exit function
      error = GetLastError();
      Print("<= Error getting current bar close => ", error);
      return error;
   } 
   
   // get bar high price and check for error
   // NOTE: check for daily period and shift hours enabled
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
   {
      // NOTE: iHighest function has an inclusive count
      barHigh = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, startBarShift - endBarShift + 1, endBarShift));
   }
   else
   {
      barHigh = iHigh(NULL, TimeFrame, Shift);
   }
   if (barHigh == 0)
   {
      // print error to log and exit function
      error = GetLastError();
      Print("<= Error getting current bar high => ", error);
      return error;
   }
   
   // get bar low price and check for error
   // NOTE: check for daily period and shift hours enabled
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
   {
      // NOTE: iLowest function has an inclusive count
      barLow = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, startBarShift - endBarShift + 1, endBarShift));
   }
   else
   {
      barLow = iLow(NULL, TimeFrame, Shift);
   }
   if (barLow == 0)
   {
      // print error to log and exit function
      error = GetLastError();
      Print("<= Error getting current bar low => ", error);
      return error;
   }
   
   // calculate pivot point, resistance, and support prices
   PP = (barHigh + barLow + barClose) / 3;
   R1 = (2 * PP) - barLow;
   S1 = (2 * PP) - barHigh;
   R2 = PP + (barHigh - barLow);
   S2 = PP - (barHigh - barLow);
   R3 = barHigh + (2 * (PP - barLow));
   S3 = barLow - (2 * (barHigh - PP));
   
   // calculate midpoint prices
   M0 = 0.5 * (S2 + S3);
   M1 = 0.5 * (S1 + S2);
   M2 = 0.5 * (PP + S1);
   M3 = 0.5 * (PP + R1);
   M4 = 0.5 * (R1 + R2);
   M5 = 0.5 * (R2 + R3);
   
   return error;
}

//+------------------------------------------------------------------+
// DeleteAllObjects - This function will delete all objects from the
//    chart for all history counts and future counts. 
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   int shift = 0;
   
   // loop through all periods and remove objects
   for (shift = 0; shift <= iCountPeriods; shift++)
   {
      LevelsDelete(gPeriod, shift);
   }
   LevelsDelete("F" + gPeriod, 0);
   return;
}

//+------------------------------------------------------------------+
// LevelsDelete - This function will delete all objects that were 
//    created by this program. 
//+------------------------------------------------------------------+
void LevelsDelete(string PeriodStr,
                  int    Shift)
{
   ObjectDelete(PeriodStr + "R3_T" + Shift);
   ObjectDelete(PeriodStr + "R2_T" + Shift);
   ObjectDelete(PeriodStr + "R1_T" + Shift);
   ObjectDelete(PeriodStr + "PP_T" + Shift);
   ObjectDelete(PeriodStr + "S1_T" + Shift);
   ObjectDelete(PeriodStr + "S2_T" + Shift);
   ObjectDelete(PeriodStr + "S3_T" + Shift);

   ObjectDelete(PeriodStr + "R3_P" + Shift);     
   ObjectDelete(PeriodStr + "R2_P" + Shift);     
   ObjectDelete(PeriodStr + "R1_P" + Shift);     
   ObjectDelete(PeriodStr + "PP_P" + Shift);     
   ObjectDelete(PeriodStr + "S1_P" + Shift);     
   ObjectDelete(PeriodStr + "S2_P" + Shift);     
   ObjectDelete(PeriodStr + "S3_P" + Shift);     
           
   ObjectDelete(PeriodStr + "R3_L" + Shift);     
   ObjectDelete(PeriodStr + "R2_L" + Shift);     
   ObjectDelete(PeriodStr + "R1_L" + Shift);     
   ObjectDelete(PeriodStr + "PP_L" + Shift);     
   ObjectDelete(PeriodStr + "S1_L" + Shift);     
   ObjectDelete(PeriodStr + "S2_L" + Shift);     
   ObjectDelete(PeriodStr + "S3_L" + Shift);     

   ObjectDelete(PeriodStr + "M0_T" + Shift);
   ObjectDelete(PeriodStr + "M1_T" + Shift);
   ObjectDelete(PeriodStr + "M2_T" + Shift);
   ObjectDelete(PeriodStr + "M3_T" + Shift);
   ObjectDelete(PeriodStr + "M4_T" + Shift);
   ObjectDelete(PeriodStr + "M5_T" + Shift);
                 
   ObjectDelete(PeriodStr + "M0_P" + Shift);     
   ObjectDelete(PeriodStr + "M1_P" + Shift);     
   ObjectDelete(PeriodStr + "M2_P" + Shift);     
   ObjectDelete(PeriodStr + "M3_P" + Shift);     
   ObjectDelete(PeriodStr + "M4_P" + Shift);     
   ObjectDelete(PeriodStr + "M5_P" + Shift);     

   ObjectDelete(PeriodStr + "M0_L" + Shift);     
   ObjectDelete(PeriodStr + "M1_L" + Shift);     
   ObjectDelete(PeriodStr + "M2_L" + Shift);     
   ObjectDelete(PeriodStr + "M3_L" + Shift);     
   ObjectDelete(PeriodStr + "M4_L" + Shift);     
   ObjectDelete(PeriodStr + "M5_L" + Shift);     

   ObjectDelete(PeriodStr + "BZ_" + Shift);     
   ObjectDelete(PeriodStr + "SZ_" + Shift);     
       
   ObjectDelete(PeriodStr + "BDL_" + Shift);     
   ObjectDelete(PeriodStr + "BDR_" + Shift);
   
}

//+------------------------------------------------------------------+
// PlotTrend - This function will plot a pivot level to the chart. 
//+------------------------------------------------------------------+
bool PlotTrend(const long              Chart_ID = 0,
               string                  Name = "trendline",
               const int               Subwindow = 0,
               datetime                Time1 = 0,
               double                  Price1 = 0,
               datetime                Time2 = 0,
               double                  Price2 = 0,             
               const color             Clr = clrBlack,
               const int               Style = STYLE_SOLID,
               const int               Width = 2,
               const bool              Back = true,
               const bool              Selection = false,
               const bool              Ray = false,
               const bool              Hidden = true)
{
   ResetLastError();
   if(!ObjectCreate(Chart_ID, Name, OBJ_TREND, Subwindow, Time1, Price1, Time2, Price2))
   {
      Print(__FUNCTION__, ": failed to create trendline = ", GetLastError());
      return(false);
   }
   ObjectSetInteger(Chart_ID, Name, OBJPROP_COLOR, Clr);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_STYLE, Style);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_WIDTH, Width);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_BACK, Back);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTABLE, Selection);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTED, Selection);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_RAY, Ray);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_HIDDEN, Hidden);
   return(true);
}

//+------------------------------------------------------------------+
// PlotRectangle - This function will plot a take profit zone to the chart. 
//+------------------------------------------------------------------+
bool PlotRectangle(  const long        Chart_ID = 0,
                     string            Name = "rectangle", 
                     const int         Subwindow = 0,
                     datetime          Time1 = 0,
                     double            Price1 = 1,
                     datetime          Time2 = 0, 
                     double            Price2 = 0, 
                     const color       Clr = clrGray,
                     const bool        Back = true,
                     const bool        Selection = false,
                     const bool        Hidden = true)
{
   if(!ObjectCreate(Chart_ID, Name, OBJ_RECTANGLE, Subwindow, Time1, Price1, Time2, Price2))
   {
      Print(__FUNCTION__, ": failed to create rectangle = ", GetLastError());
      return(false);
   }
   
   ObjectSetInteger(Chart_ID, Name, OBJPROP_COLOR, Clr);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_BACK, Back);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTABLE, Selection);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_HIDDEN, Hidden);
   return(true);
}

//+------------------------------------------------------------------+
// PlotText - This function will plot a text box to the chart. Used to
//    plot pivot labels and prices. 
//+------------------------------------------------------------------+
bool PlotText(       const long        Chart_ID = 0,
                     string            Name = "text", 
                     const int         Subwindow = 0,
                     datetime          Time1 = 0, 
                     double            Price1 = 0, 
                     const string      Text = "text",
                     const string      Font = "Arial",
                     const int         Font_size = 10,
                     const color       Clr = clrGray,
                     const int         Anchor = ANCHOR_RIGHT_UPPER,
                     const bool        Back = true,
                     const bool        Selection = false,
                     const bool        Hidden = true)
{
   ResetLastError();
   if(!ObjectCreate(Chart_ID, Name, OBJ_TEXT, Subwindow, Time1, Price1))
   {
      Print(__FUNCTION__,": failed to create text = ",GetLastError());
      return(false);
   }
   ObjectSetString(Chart_ID, Name, OBJPROP_TEXT, Text);
   ObjectSetString(Chart_ID, Name, OBJPROP_FONT, Font);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_FONTSIZE, Font_size);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_COLOR, Clr);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_ANCHOR, Anchor);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTABLE, Selection);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTED, Selection);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_HIDDEN, Hidden);
   return(true);
} 

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if (id == CHARTEVENT_OBJECT_CLICK && sparam=="WP_btn") 
   { 
      if(ObjectGetInteger(0,"WP_btn",OBJPROP_STATE)){
         ObjectSetString(0,"WP_btn",OBJPROP_TEXT,btn_pressed);
         DeleteAllObjects();}
      if(!ObjectGetInteger(0,"WP_btn",OBJPROP_STATE)){
         ObjectSetString(0,"WP_btn",OBJPROP_TEXT,btn_unpressed);}
   }
}

void CreateButton()
{
   if(btn_show){ButtonCreate(NULL,"WP_btn",0,btn_offset_x,btn_offset_y,btn_width,btn_height,CORNER_LEFT_UPPER,btn_unpressed,"Arial",btn_font_size,btn_font_clr,btn_bg_color,btn_border_clr,false,true,false,false,0);}
}


bool ButtonCreate(const long              chart_ID=0,               // chart's ID
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
                  const bool              selectable=true,      //object can be selected        
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=false,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
   ResetLastError();
   ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
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

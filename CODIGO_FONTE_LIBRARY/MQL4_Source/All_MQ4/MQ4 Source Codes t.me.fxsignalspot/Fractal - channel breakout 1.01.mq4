//+------------------------------------------------------------------+
//|                                     Fractals - adjustable period |
//+------------------------------------------------------------------+
#property link      "www.forex-station.com"
#property copyright "www.forex-station.com"
#property indicator_chart_window
#property indicator_buffers 8
#property strict

//
//
//
//
//

enum enDisplay
{
   en_lin,  // Display channel
   en_his,  // Display colored candles
   en_all,  // Display channel and candles
   en_lid,  // Display channel with dots
   en_hid,  // Display colored candles with dots
   en_ald,  // Display channel and candles with dots
   en_dot   // Display dots
};
enum enTimeFrames
{
   tf_cu  = 0,              // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mb1 = PERIOD_MN1,     // Monthly
   tf_cus = 12345678        // Custom time frame
};

extern enTimeFrames       TimeFrame       = tf_cu;             // Time frame
extern int                TimeFrameCustom = 0;                 // Custom time frame to use (if custom time frame used)
extern int                FractalPeriod   = 5;                 // Fractal period 5 = std mt4 fractal
extern ENUM_APPLIED_PRICE PriceHigh       = PRICE_HIGH;        // Upper fractal price
extern ENUM_APPLIED_PRICE PriceLow        = PRICE_LOW;         // Lower fractal price
extern enDisplay          DisplayType     = en_lid;            // Display type
extern int                BarsWidth       = 1;                 // Bars width (when candles are included in display)
extern int                WickWidth       = 2;                 // Wicks width (when candles are included in display)
extern int                LinesWidth      = 2;                 // Lines width (when lines are included in display)
extern color              UpChannelColor  = clrTeal;           // Upper channel color
extern color              DnChannelColor  = clrOrange;         // Lower channel color
extern color              UpBarsColor     = clrTeal;           // Up candle color
extern color              DnBarsColor     = clrOrange;         // Down candle color
extern color              UpWickColor     = clrTeal;           // Up wick color
extern color              DnWickColor     = clrOrange;         // Down wick color
extern int                UpArrowSize     = 2;                 // Up arrow size
extern int                DnArrowSize     = 2;                 // Down arrow size
extern int                UpArrowCode     = 159;               // Up arrow code
extern int                DnArrowCode     = 159;               // Down arrow code
extern double             UpArrowGap      = 0.5;               // Up arrow gap       
extern double             DnArrowGap      = 0.5;               // Down arrow gap
extern color              UpArrowColor    = clrDodgerBlue;     // Up Arrow color
extern color              DnArrowColor    = clrMagenta;        // Down Arrow color
extern bool               ArrowOnFirst    = true;              // Arrow on first bars?
extern bool               alertsOn        = true;              // Turn alerts on?
extern bool               alertsOnCurrent = false;             // Alerts on still opened bar?
extern bool               alertsMessage   = true;              // Alerts should show popup message?
extern bool               alertsSound     = false;             // Alerts should play a sound?
extern bool               alertsEmail     = false;             // Alerts should send email?
extern bool               alertsNotify    = false;             // Alerts should send notification?
input bool                showAllBreakOut = true;              // Show all breakouts true/false;
extern bool               Interpolate     = true;              // Interpolate in multi timeframe mode?
 

double histou[];
double histod[];
double wickou[];
double wickod[];
double upper[];
double lower[];
double arrowu[];
double arrowd[];
double trend[];
string indicatorFileName;
bool   returnBars;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{ 
    IndicatorBuffers(9);
    int lstyle = DRAW_LINE;      if (DisplayType==en_his || DisplayType==en_hid || DisplayType==en_dot) lstyle = DRAW_NONE;
    int hstyle = DRAW_HISTOGRAM; if (DisplayType==en_lin || DisplayType==en_lid || DisplayType==en_dot) hstyle = DRAW_NONE;
    int astyle = DRAW_ARROW;     if (DisplayType<en_lid)                                                astyle = DRAW_NONE;
    SetIndexBuffer(0, histou);   SetIndexStyle(0, hstyle,EMPTY,BarsWidth,UpBarsColor);  
    SetIndexBuffer(1, histod);   SetIndexStyle(1, hstyle,EMPTY,BarsWidth,DnBarsColor);  
    SetIndexBuffer(2, wickou);   SetIndexStyle(2, hstyle,EMPTY,WickWidth,UpWickColor);  
    SetIndexBuffer(3, wickod);   SetIndexStyle(3, hstyle,EMPTY,WickWidth,DnWickColor);  
    SetIndexBuffer(4, upper);    SetIndexStyle(4, lstyle,EMPTY,LinesWidth,UpChannelColor);  
    SetIndexBuffer(5, lower);    SetIndexStyle(5, lstyle,EMPTY,LinesWidth,DnChannelColor);   
    SetIndexBuffer(6, arrowu);   SetIndexStyle(6, astyle,0,UpArrowSize,UpArrowColor); SetIndexArrow(6,UpArrowCode);
    SetIndexBuffer(7, arrowd);   SetIndexStyle(7, astyle,0,DnArrowSize,DnArrowColor); SetIndexArrow(7,DnArrowCode);
    SetIndexBuffer(8, trend); 
    
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99; 
         if (TimeFrameCustom==0) TimeFrameCustom = MathMax(TimeFrameCustom,_Period);
         if (TimeFrame!=tf_cus)
               TimeFrame = MathMax(TimeFrame,_Period);
         else  TimeFrame = (enTimeFrames)TimeFrameCustom;
      
return(0);
}
int deinit() {  return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
    int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
            int limit = fmin(Bars-counted_bars,Bars-1);
            if (returnBars) { histou[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
     int half = FractalPeriod/2;
     for(i=limit; i>=0; i--)
     {
        if (i<Bars-1)
        {
          int r;
          bool   found     = true;
          double compareTo = iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i);
          for (r=1;r<=half;r++)
            {
               if ((i+r)<Bars && iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i+r)> compareTo) { found=false; break; }
               if ((i-r)>=0   && iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i-r)>=compareTo) { found=false; break; }
            }
          if (found) upper[i] = iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i);
          else       upper[i] = upper[i+1];

          //
          //
          //
          //
          //
      
         found     = true;
         compareTo = iMA(NULL,0,1,0,MODE_SMA,PriceLow,i);
         for (r=1;r<=half;r++)
            {
               if ((i+r)<Bars && iMA(NULL,0,1,0,MODE_SMA,PriceLow,i+r)< compareTo) { found=false; break; }
               if ((i-r)>=0   && iMA(NULL,0,1,0,MODE_SMA,PriceLow,i-r)<=compareTo) { found=false; break; }
            }
         if (found) lower[i] = iMA(NULL,0,1,0,MODE_SMA,PriceLow,i);  
         else       lower[i] = lower[i+1];
         
             histou[i] = EMPTY_VALUE;
             histod[i] = EMPTY_VALUE;
             wickou[i] = EMPTY_VALUE;
             wickod[i] = EMPTY_VALUE;
             arrowu[i] = EMPTY_VALUE;
             arrowd[i] = EMPTY_VALUE;
             trend[i] = (i<Bars-1 && !showAllBreakOut) ? trend[i+1] : 0;
             if (Close[i]>upper[i]) trend[i] = 1; 
             if (Close[i]<lower[i]) trend[i] =-1;
            
             if (trend[i]== 1) { histod[i] = Low[i]; histou[i] = High[i]; wickou[i] = fmax(Open[i],Close[i]);wickod[i] = fmin(Open[i],Close[i]);}
             if (trend[i]==-1) { histou[i] = Low[i]; histod[i] = High[i]; wickou[i] = fmin(Open[i],Close[i]);wickod[i] = fmax(Open[i],Close[i]);}
          }
         
          //
          //
          //
          //
          //
      
          if (i<Bars-1 && trend[i]!=trend[i+1])
          {
            if (trend[i] ==  1) arrowu[i] = fmin(upper[i],Low[i] )-iATR(NULL,0,15,i)*UpArrowGap;
            if (trend[i] == -1) arrowd[i] = fmax(lower[i],High[i])+iATR(NULL,0,15,i)*DnArrowGap;
          } 
   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"breaking up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"breaking down");
      }         
   }
   return(0);
   }
   
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
      int x = y;
      if (ArrowOnFirst)
            {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);          }
      else  {  if (i>0) x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
         upper[i]  = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,FractalPeriod,PriceHigh,PriceLow,DisplayType,0,0,0,UpChannelColor,DnChannelColor,UpBarsColor,DnBarsColor,UpWickColor,DnWickColor,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,false,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,showAllBreakOut,4,y);
         lower[i]  = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,FractalPeriod,PriceHigh,PriceLow,DisplayType,0,0,0,UpChannelColor,DnChannelColor,UpBarsColor,DnBarsColor,UpWickColor,DnWickColor,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,false,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,showAllBreakOut,5,y);
         trend[i]  = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,FractalPeriod,PriceHigh,PriceLow,DisplayType,0,0,0,UpChannelColor,DnChannelColor,UpBarsColor,DnBarsColor,UpWickColor,DnWickColor,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,false,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,showAllBreakOut,8,y);
         histou[i] = EMPTY_VALUE;
         histod[i] = EMPTY_VALUE;
         wickou[i] = EMPTY_VALUE;
         wickod[i] = EMPTY_VALUE;
         arrowu[i] = EMPTY_VALUE;
         arrowd[i] = EMPTY_VALUE;
      if (x!=y)
      {
         arrowu[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,FractalPeriod,PriceHigh,PriceLow,DisplayType,0,0,0,UpChannelColor,DnChannelColor,UpBarsColor,DnBarsColor,UpWickColor,DnWickColor,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,false,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,showAllBreakOut,6,y);
         arrowd[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,FractalPeriod,PriceHigh,PriceLow,DisplayType,0,0,0,UpChannelColor,DnChannelColor,UpBarsColor,DnBarsColor,UpWickColor,DnWickColor,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,false,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,showAllBreakOut,7,y);
      }
      
       if (trend[i]== 1) 
         { 
            histod[i] = Low[i]; 
            histou[i] = High[i]; 
            wickou[i] = fmax(Open[i],Close[i]);
            wickod[i] = fmin(Open[i],Close[i]);
          }
          if (trend[i]==-1) 
          { 
            histou[i] = Low[i]; 
            histod[i] = High[i]; 
            wickou[i] = fmin(Open[i],Close[i]);
            wickod[i] = fmax(Open[i],Close[i]);
          }

          if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;

          //
          //
          //
          //
          //

          int n,k; datetime time = iTime(NULL,TimeFrame,y);
             for(n = 1; i+n<Bars && Time[i+n] >= time; n++) continue;	
             for(k = 1; i+n<Bars && i+k<Bars && k<n; k++)
             {
               upper[i+k] = upper[i] + (upper[i+n] - upper[i]) * k/n;  
               lower[i+k] = lower[i] + (lower[i+n] - lower[i]) * k/n;        
             }          
   }
return(0);
}
     
//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Fractal Channel ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Fractal Channel "),message);
          if (alertsNotify)  SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}
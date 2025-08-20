//https://www.tradingview.com/script/admGhVz7-3-Line-Strike-TTF/
#property copyright "Bugscoder Studio"
#property link      "https://www.bugscoder.com/"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_type1   DRAW_ARROW
#property indicator_width1  0
#property indicator_color1  clrDarkSeaGreen
#property indicator_type2   DRAW_ARROW
#property indicator_width2  0
#property indicator_color2  clrTomato

enum enTimeFrames
{
         tf_cu  = 0,                                            // Current time frame
         tf_m1  = PERIOD_M1,                                    // 1 minute
         tf_m5  = PERIOD_M5,                                    // 5 minutes
         tf_m15 = PERIOD_M15,                                   // 15 minutes
         tf_m30 = PERIOD_M30,                                   // 30 minutes
         tf_h1  = PERIOD_H1,                                    // 1 hour
         tf_h4  = PERIOD_H4,                                    // 4 hours
         tf_d1  = PERIOD_D1,                                    // Daily
         tf_w1  = PERIOD_W1,                                    // Weekly
         tf_mn1 = PERIOD_MN1,                                   // Monthly
         tf_n1  = -1,                                           // First higher time frame
         tf_n2  = -2,                                           // Second higher time frame
         tf_n3  = -3                                            // Third higher time frame
      };
input enTimeFrames       inpTimeFrame    = tf_cu;               // Time frame to use 
input bool               showBear3LS     = true;                // Show Bearish 3 Line Strike
input bool               showBull3LS     = true;                // Show Bullish 3 Line Strike
input double             ArrowsGap       = 0.25;                // Arrow gap
input bool               ArrowsOnFirst    = true;               // Arrow on first mtf bar
input bool               alertsOn        = false;
input bool               alertsOnCurrent = true;
input bool               alertsMessage   = true;
input bool               alertsSound     = false;
input bool               alertsEmail     = false;
input bool               alertsNotify    = false;

double up[],dn[],count[];
string obj_prefix = "3LS_";
struct sGlobalStruct
{
   int    perMa;
   int    perBb;
   double rng;
   string indiFileName;
   int    indiTimeFrame;
};
sGlobalStruct glo;
#define _mtfCall(_buff,_ind) iCustom(_Symbol,glo.indiTimeFrame,glo.indiFileName,tf_cu,showBear3LS,showBull3LS,ArrowsGap,ArrowsOnFirst,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,_buff,_ind)

int OnInit() {
   IndicatorDigits(_Digits);
   IndicatorBuffers(3);
   SetIndexBuffer(0, up,INDICATOR_DATA); SetIndexArrow(0, 233); SetIndexLabel(0, "up");
   SetIndexBuffer(1, dn,INDICATOR_DATA); SetIndexArrow(1, 234); SetIndexLabel(1, "dn");
   SetIndexBuffer(2, count,INDICATOR_CALCULATIONS);
   
   glo.indiFileName  = WindowExpertName();
   glo.indiTimeFrame = (enTimeFrames)timeFrameValue(inpTimeFrame);

   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {ObjectsDeleteAll(0, obj_prefix);}

//
//
//

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {

   int i,limit=fmin(rates_total-prev_calculated+1,rates_total-1); count[0] = limit;
      if (glo.indiTimeFrame!=_Period)
      {
         limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(2,0)*glo.indiTimeFrame/_Period));
         for(i=limit; i>=0 && !_StopFlag; i--)
         {
            int y = iBarShift(_Symbol,glo.indiTimeFrame,time[i]);
            int x = y;
            if (ArrowsOnFirst)
                  {  if (i<rates_total-1) x = iBarShift(_Symbol,glo.indiTimeFrame,time[i+1]);               }
            else  {  if (i>0)             x = iBarShift(_Symbol,glo.indiTimeFrame,time[i-1]); else x = -1;  }
               up[i] = dn[i] = EMPTY_VALUE; 
               if (x!=y)
               {
                  up[i] = _mtfCall(0,y);
                  dn[i] = _mtfCall(1,y);
               }
         }
   return(rates_total);
   }  
   
   //
   //
   //
   
   int startPos = rates_total-prev_calculated-4;
   if (startPos <= 1) { startPos = 1; }
   for(i=startPos; i>=1; i--) 
   {
      glo.rng  = 0; for (int k = 0; k<10 && (i+k)<rates_total; k++) glo.rng += high[i+k] - low[i+k]; glo.rng/= 10.0;
      up[i] = (is3LSBull(i) && Close[i]>Open[i]) ?  low[i]-glo.rng*ArrowsGap : EMPTY_VALUE;
      dn[i] = (is3LSBear(i) && Close[i]<Open[i]) ? high[i]+glo.rng*ArrowsGap : EMPTY_VALUE;
   }
   manageAlerts();
return(rates_total);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------

void manageAlerts()
{
   if (alertsOn)
   {
      //if (alertsOnCurrent)
      //     int whichBar = 0;
      //else     whichBar = 1;
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (dn[whichBar] != EMPTY_VALUE || up[whichBar] != EMPTY_VALUE)
      {
         if (up[whichBar] != EMPTY_VALUE && up[whichBar+1] == EMPTY_VALUE) doAlert(whichBar,"up");
         if (dn[whichBar] != EMPTY_VALUE && dn[whichBar+1] == EMPTY_VALUE) doAlert(whichBar,"down");
      }
   }
}

//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       string message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" 3LS "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" 3LS",message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}


int price_diff(double price1, double price2, string _pair = "", bool abs = true) {
   if (_pair == "") { _pair = Symbol(); }
   double _point = MarketInfo(_pair, MODE_POINT);
   
   double p = price1-price2;
   if (abs == true) { p = MathAbs(p); }
   p = NormalizeDouble(p/_point, 0);
   string s = DoubleToStr(p, 0);
   int diff = (int) StringToInteger(s);
   
   return diff;
}

int getCandleColorIndex(int pos) {
   return (Close[pos]>Open[pos]) ? 1 : (Close[pos]<Open[pos]) ? -1 : 0;
}

bool isEngulfing(int pos, bool checkBearish) {
   bool ret = false;
   int sizePrevCandle = price_diff(Close[pos+1], Open[pos+1]);
   int sizeCurrentCandle = price_diff(Close[pos], Open[pos]);
   bool isCurrentLagerThanPrevious = sizeCurrentCandle > sizePrevCandle ? true : false;
   
   if (checkBearish == true) {
      bool isGreenToRed = getCandleColorIndex(pos) < 0 && getCandleColorIndex(pos+1) > 0 ? true : false;
      ret = isCurrentLagerThanPrevious == true && isGreenToRed == true ? true : false;
   }
   else {
      bool isRedToGreen = getCandleColorIndex(pos) > 0 && getCandleColorIndex(pos+1) < 0 ? true : false;
      ret = isCurrentLagerThanPrevious == true && isRedToGreen == true ? true : false;
   }
   
   return ret;
}

bool isBearishEngulfuing(int pos) {
   return isEngulfing(pos, true);
}

bool isBullishEngulfuing(int pos) {
   return isEngulfing(pos, false);
}

bool is3LSBear(int pos) {
   bool ret = false;
   
   bool is3LineSetup = ((getCandleColorIndex(pos+1) > 0) && (getCandleColorIndex(pos+2) > 0) && (getCandleColorIndex(pos+3) > 0)) ? true : false;
   ret = (is3LineSetup == true) ? true : false;
   
   return ret;
}

bool is3LSBull(int pos) {
   bool ret = false;
   
   bool is3LineSetup = ((getCandleColorIndex(pos+1) < 0) && (getCandleColorIndex(pos+2) < 0) && (getCandleColorIndex(pos+3) < 0)) ? true : false;
   ret = (is3LineSetup == true) ? true : false;
   
   return ret;
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : fabs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)fmin(i+add,size-1)]);
}
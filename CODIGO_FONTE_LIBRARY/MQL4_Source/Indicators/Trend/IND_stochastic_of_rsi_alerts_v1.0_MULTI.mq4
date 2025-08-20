//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "mladen"
#property link "www.forex-station.com"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrGold
#property indicator_width1  2
#property indicator_style2  STYLE_DOT
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1  20
#property indicator_level2  80
#property strict

//
//
//
//
//

extern int                RsiPeriod                  = 13;               // Rsi period
extern ENUM_APPLIED_PRICE RsiPrice                   = PRICE_CLOSE;      // Rsi price to use
extern int                StoPeriod                  = 13;               // Stochastic period
extern int                StoSlowing                 = 8;                // Stochastic slowing period
extern int                StoSignal                  = 8;                // Stochastic signal
extern ENUM_MA_METHOD     StoSignalMethod            = MODE_EMA;         // Stochastic ma method
extern bool               alertsOn                   = false;            // Turn alerts on?
extern bool               alertsOnCurrent            = false;            // Alerts on still opened bar?
extern bool               alertsMessage              = true;             // Alerts should display message?
extern bool               alertsOnLevelCross         = true;             // Alerts on level cross?
extern bool               alertsOnSignalCross        = true;             // Alerts on signal cross?
extern bool               alertsSound                = false;            // Alerts should play a sound?
extern bool               alertsNotify               = false;            // Alerts should send a notification?
extern bool               alertsEmail                = false;            // Alerts should send an email?
extern string             soundFile                  = "alert2.wav";     // Sound file
extern double             levUp                      = 80;               // Upper level or overbought
extern double             levDn                      = 20;               // Lower level or oversold

double sto[],sig[],value[],trend[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,sto);  SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,sig);  SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,value);  
   SetIndexBuffer(3,trend);  
   SetLevelValue(0,levUp);
   SetLevelValue(1,levDn);
   IndicatorShortName("Stochastic RSI ("+(string)RsiPeriod+","+(string)StoPeriod+","+(string)StoSlowing+","+(string)StoSignal+")");
return(INIT_SUCCEEDED);
}  
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//`
//
//

int start()
{
   int i,counted_bars=IndicatorCounted();
      if (counted_bars<0) return(-1);
      if (counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   for (i=limit; i>=0; i--)
   {
      double rsi = iRSI(NULL,0,RsiPeriod,RsiPrice,i); 
      sto[i] = iStoch(rsi,rsi,rsi,StoPeriod,StoSlowing,i,Bars);
   }         
   for (i=limit; i>=0; i--) 
   {
      sig[i] = iMAOnArray(sto,0,StoSignal,0,StoSignalMethod,i);
      trend[i] = (i<Bars-1) ? (sto[i]>levUp)  ? 1 : (sto[i]<levDn)  ? -1 : trend[i+1] : 0;
      value[i] = (i<Bars-1) ? (sto[i]>sig[i]) ? 1 : (sto[i]<sig[i]) ? -1 : value[i+1] : 0;
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnLevelCross && trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(time1,mess1,whichBar,"crossing upper level up");
         if (trend[whichBar] == -1) doAlert(time1,mess1,whichBar,"crossing lower level down");
      }
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnSignalCross && value[whichBar] != value[whichBar+1])
      {
         if (value[whichBar] ==  1) doAlert(time2,mess2,whichBar,"crossing signal up");
         if (value[whichBar] == -1) doAlert(time2,mess2,whichBar,"crossing signal down");
      }                  
    }         
return(0);
} 

//
//
//
//
//

#define _stochInstances     1
#define _stochInstancesSize 5
double  workSto[][_stochInstances+_stochInstancesSize];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
double iStoch(double priceR, double priceH, double priceL, int period, int slowing, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workSto,0)!=bars) ArrayResize(workSto,bars); i = bars-i-1; instanceNo *= _stochInstancesSize;
   
   //
   //
   //
   //
   //
   
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
      for (int k=1; k<period && (i-k)>=0; k++)
      {
         workSto[i][_mi+instanceNo] = fmin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
         workSto[i][_ma+instanceNo] = fmax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
      }                   
      double sumlow  = 0.0;
      double sumhigh = 0.0;
      for(int k=0; k<fmax(slowing,1) && (i-k)>=0; k++)
      {
         sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
         sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
      }

   //
   //
   //
   //
   //
   
   if(sumhigh!=0.0) 
         return(100.0*sumlow/sumhigh);
   else  return(0);    
}

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

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];
       
       //
       //
       //
       //
       //

       message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Stochastic Rsi "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" Stochastic Rsi ",message);
          if (alertsSound)   PlaySound(soundFile);
      }
}


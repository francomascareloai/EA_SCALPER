//------------------------------------------------------------------
// original idea by Alexander Kirilyuk M.
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

//
//
//
//
//

enum enMaTypes
{
   ma_sma,     // sma (simple moving average)
   ma_ema,     // ema (exponential moving average)
   ma_smma,    // smma (smoothed moving average)
   ma_lwma     // lwma (liner weighted moving average)
};

extern string    TimeFrame          = "Current time frame";
extern int       RsiPeriod          = 14;
extern int       MaPeriod           = 10;
extern enMaTypes MaType             = ma_smma;
extern bool      alertsOn           = false;
extern bool      alertsOnCurrent    = false;
extern bool      alertsSound        = false;
extern bool      alertsMessage      = true;
extern bool      alertsNotification = false;
extern bool      alertsEmail        = false;

//
//
//
//
//

double ARSI[]; 
double ARSI1[]; 
double buffer2[];
double buffer3[];
double trend[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{ 
   IndicatorBuffers(5);
	SetIndexBuffer(0,ARSI); 
	SetIndexBuffer(1,buffer2);
   SetIndexBuffer(2,buffer3);
	SetIndexBuffer(3,ARSI1); 
   SetIndexBuffer(4,trend); 
	
	   //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
               
   IndicatorShortName(timeFrameToString(timeFrame)+" RSI adaptive EMA nrp (" + RsiPeriod+")");
	return(0); 
} 

int start() 
{ 
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { ARSI[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (trend[limit]==-1) CleanPoint(limit,buffer2,buffer3);
      for(int i=limit; i >= 0; i--)
      {
		   double sc = MathAbs(iRSI(NULL, 0, RsiPeriod, PRICE_CLOSE, i)/100.0 - 0.5) * 2.0;
		   if( Bars - i <= RsiPeriod)
   			   ARSI1[i] = Close[i];
		   else	ARSI1[i] = ARSI1[i+1] + sc * (Close[i] - ARSI1[i+1]);
	   }
      for(i = limit; i >= 0; i--) 
      {
         ARSI[i] = iMAOnArray(ARSI1,0,MaPeriod,0,(int)MaType,i);
         buffer2[i] = EMPTY_VALUE;
         buffer3[i] = EMPTY_VALUE;
         trend[i]   = trend[i+1];
            if (ARSI[i]>ARSI[i+1]) trend[i] = 1;
            if (ARSI[i]<ARSI[i+1]) trend[i] =-1;
            if (trend[i]==-1) PlotPoint(i,buffer2,buffer3,ARSI);
      }
      manageAlerts();
	   return(0); 
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,buffer2,buffer3);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         trend[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,MaPeriod,MaType,alertsOn,alertsOnCurrent,alertsSound,alertsMessage,alertsNotification,alertsEmail,4,y);
         ARSI[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,MaPeriod,MaType,alertsOn,alertsOnCurrent,alertsSound,alertsMessage,alertsNotification,alertsEmail,0,y);
         buffer2[i] = EMPTY_VALUE;
         buffer3[i] = EMPTY_VALUE;
         if (trend[i]==-1) PlotPoint(i,buffer2,buffer3,ARSI);
   }
return(0);
}


//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      
      //
      //
      //
      //
      //
      
      static string   alertType1 = "";
      static datetime alertTime1 = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(alertType1,alertTime1,"rsi adaptive ema slope changed to up");
         if (trend[whichBar] == -1) doAlert(alertType1,alertTime1,"rsi adaptive ema slope changed to down");
      }
   }
}

//
//
//
//
//

void doAlert(string& previousAlert, datetime& previousTime, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message = timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+"  "+doWhat;
          if (alertsMessage)      Alert(message);
          if (alertsEmail)        SendMail(StringConcatenate(Symbol(),"rsi adaptive ema"),message);
          if (alertsNotification) SendNotification(StringConcatenate(Symbol(),"rsi adaptive ema "+message));
          if (alertsSound)        PlaySound("alert2.wav");
   }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>Bars-2) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>Bars-3) return;
   if (first[i+1] == EMPTY_VALUE)
         if (first[i+2] == EMPTY_VALUE) 
               { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
         else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else        { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs)
{
   StringToUpper(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
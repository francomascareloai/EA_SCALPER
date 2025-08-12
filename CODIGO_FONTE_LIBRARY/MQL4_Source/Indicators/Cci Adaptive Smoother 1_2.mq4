//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers    4
#property indicator_color1     clrDodgerBlue
#property indicator_color2     clrSandyBrown
#property indicator_color3     clrSilver
#property indicator_color4     clrDarkSlateGray
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_width4     2
#property strict

//
//
//
//
//

extern int                CciPeriod       = 14;            // CCI period
extern ENUM_APPLIED_PRICE CciPrice        = PRICE_TYPICAL; // Price to use
extern int                AdaptPeriod     = 25;            // Adapting period
extern int                CciMaPeriod     = 7;             // Average period
extern ENUM_MA_METHOD     CciMaMethod     = MODE_LWMA;     // Average method 
extern bool               ShowHistogram   = true;          // Display histogram?
extern bool               ShowCciMa       = true;          // Display CCI average?
extern double             OverSold        = -150;          // Over sold level
extern double             OverBought      = 150;           // Over bought level
extern bool               alertsOn        = false;         // Turn alerts on?
extern bool               alertsOnCurrent = false;         // Alerts on current (still opened) bar?
extern bool               alertsMessage   = false;         // Alerts should display pop-up message?
extern bool               alertsEmail     = false;         // Alerts should send an email?
extern bool               alertsSound     = false;         // Alerts should play an alert sound?
extern string             soundFile       = "alert2.wav";  // Sound file to use when playing alerts sounds







double cci[];
double cciU[];
double cciD[];
double cciMa[];
double prices[];
double trend[];

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
      IndicatorBuffers(6);
      SetIndexBuffer(0,cciU);  
      SetIndexBuffer(1,cciD);  
      SetIndexBuffer(2,cci);  
      SetIndexBuffer(3,cciMa); 
      SetIndexBuffer(4,prices);
      SetIndexBuffer(5,trend); 
      
      if (ShowHistogram)
            {
              SetIndexBuffer(0,cciU);  SetIndexStyle(0,DRAW_HISTOGRAM);
              SetIndexBuffer(1,cciD);  SetIndexStyle(1,DRAW_HISTOGRAM); 
            }
      else  { SetIndexStyle(0,DRAW_NONE);  SetIndexStyle(1,DRAW_NONE); }
      if (ShowCciMa)
            { SetIndexStyle(3,DRAW_LINE); }
      else  { SetIndexStyle(3,DRAW_NONE); }
     SetLevelValue(0,OverBought);
     SetLevelValue(1,OverSold); 
     SetLevelValue(2,0); 
     IndicatorShortName("Cci Adaptive Smoother(" +(string)CciPeriod+ ", " +(string)AdaptPeriod+")");
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--)
   {
      double dev    = iStdDev(NULL,0,AdaptPeriod,0,MODE_SMA,PRICE_CLOSE,i);
      double avg    = iSma(dev,AdaptPeriod,i,0);
      double period = CciPeriod; 
         if (dev!=0) period = CciPeriod*avg/dev;
                     period = MathMax(period,3);
      
      //
      //
      //
      //
      //
      
      prices[i]   = iMA(NULL,0,1,0,MODE_SMA,CciPrice,i);
      double avgs = 0; for(k=0; k<CciPeriod && (i+k)<Bars; k++) avgs +=         prices[i+k];       avgs /= CciPeriod;
      double devs = 0; for(k=0; k<CciPeriod && (i+k)<Bars; k++) devs += MathAbs(prices[i+k]-avgs); devs /= CciPeriod;
         if (devs!=0)
               cci[i] = iSmooth((prices[i]-avgs)/(0.015*devs),period,i,0);
         else  cci[i] = iSmooth(0,                            period,i,0); 
               cciU[i] = EMPTY_VALUE;
               cciD[i] = EMPTY_VALUE;
               if (i<Bars-1)
               {
                  trend[i]= trend[i+1];
                     if (cci[i]>0) trend[i]=  1; 
                     if (cci[i]<0) trend[i]= -1;
                     if (trend[i] == 1) cciU[i] = cci[i];  
                     if (trend[i] ==-1) cciD[i] = cci[i]; 
               }                     
   }
   for (i=limit; i>=0; i--) cciMa[i] = iMAOnArray(cci,0,CciMaPeriod,0,CciMaMethod,i);

   //
   //
   //
   //
   //

   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("uptrend");
      else  doAlert("downtrend");       
   }
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workSmooth[][5];
double iSmooth(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(workSmooth,0)!=Bars) ArrayResize(workSmooth,Bars); instanceNo *= 5; r = Bars-r-1;
 	if(r<=2) { workSmooth[r][instanceNo] = price; workSmooth[r][instanceNo+2] = price; workSmooth[r][instanceNo+4] = price; return(price); }
   
   //
   //
   //
   //
   //
   
	double alpha = 0.45*(length-1.0)/(0.45*(length-1.0)+2.0);
   	  workSmooth[r][instanceNo+0] =  price+alpha*(workSmooth[r-1][instanceNo]-price);
	     workSmooth[r][instanceNo+1] = (price - workSmooth[r][instanceNo])*(1-alpha)+alpha*workSmooth[r-1][instanceNo+1];
	     workSmooth[r][instanceNo+2] =  workSmooth[r][instanceNo+0] + workSmooth[r][instanceNo+1];
	     workSmooth[r][instanceNo+3] = (workSmooth[r][instanceNo+2] - workSmooth[r-1][instanceNo+4])*MathPow(1.0-alpha,2) + MathPow(alpha,2)*workSmooth[r-1][instanceNo+3];
	     workSmooth[r][instanceNo+4] =  workSmooth[r][instanceNo+3] + workSmooth[r-1][instanceNo+4]; 
   return(workSmooth[r][instanceNo+4]);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

double workSma[][2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2; r = Bars-r-1; int k=1;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Cci Adaptive Smoother ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Cci Adaptive Smoother "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}
 


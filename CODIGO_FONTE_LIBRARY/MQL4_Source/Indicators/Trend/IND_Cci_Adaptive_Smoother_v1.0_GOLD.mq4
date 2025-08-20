
#property indicator_separate_window
#property indicator_buffers    4
#property indicator_color1     Gold
#property indicator_color2     LimeGreen
#property indicator_color3     Red
#property indicator_color4     DarkSlateGray
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_width4     2
#property indicator_levelcolor DarkOrchid

//
//
//
//
//

extern int    CciPeriod       = 14;
extern int    CciPrice        = PRICE_TYPICAL;
extern int    AdaptPeriod     = 21;
extern int    CciMaPeriod     = 7;
extern int    CciMaMethod     = MODE_LWMA;
extern bool   ShowHistogram   = true;
extern bool   ShowCciMa       = true;
extern double OverSold        = -150;
extern double OverBought      = 150;
           
extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;
extern string soundFile       = "alert2.wav";







double cci[];
double cciU[];
double cciD[];
double cciMa[];
double prices[];
double trend[];

//
//
//
//
//

int init()
{
      IndicatorBuffers(6);
      SetIndexBuffer(0,cci);  
      SetIndexBuffer(1,cciU);  
      SetIndexBuffer(2,cciD);  
      SetIndexBuffer(3,cciMa); 
      SetIndexBuffer(4,prices);
      SetIndexBuffer(5,trend); 
      
      if (ShowHistogram)
      {
        SetIndexBuffer(1,cciU);  SetIndexStyle(1,DRAW_HISTOGRAM);
        SetIndexBuffer(2,cciD);  SetIndexStyle(2,DRAW_HISTOGRAM); 
      }
      else
      {
        SetIndexStyle(1,DRAW_NONE); 
        SetIndexStyle(2,DRAW_NONE); 
      }
      if (ShowCciMa)
      {
        SetIndexBuffer(3,cciMa);  SetIndexStyle(3,DRAW_LINE);
      }
      else
      {
        SetIndexStyle(3,DRAW_NONE); 
      }
      
     SetLevelValue(0,OverBought);
     SetLevelValue(1,OverSold); 
     SetLevelValue(2,0); 
     IndicatorShortName("Cci Adaptive Smoother(" +CciPeriod+ ", " +AdaptPeriod+")");
   return(0);
}

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
      double dev = iStdDev(NULL,0,AdaptPeriod,0,MODE_SMA,PRICE_CLOSE,i);
      double avg = iSma(dev,AdaptPeriod,i,0);
         if (dev!=0) 
                double period = CciPeriod*avg/dev;
         else          period = CciPeriod; 
         if (period<3) period = 3;
      
      //
      //
      //
      //
      //
      
      prices[i]   = iMA(NULL,0,1,0,MODE_SMA,CciPrice,i);
      double avgs = 0; for(k=0; k<CciPeriod; k++) avgs +=         prices[i+k];       avgs /= CciPeriod;
      double devs = 0; for(k=0; k<CciPeriod; k++) devs += MathAbs(prices[i+k]-avgs); devs /= CciPeriod;
         if (devs!=0)
               cci[i] = iSmooth((prices[i]-avgs)/(0.015*devs),period,i,0);
         else  cci[i] = iSmooth(0,                            period,i,0); 
         
         
           cciU[i] = EMPTY_VALUE;
           cciD[i] = EMPTY_VALUE;
           trend[i]= trend[i+1];
         
             if (cci[i]>0) trend[i]=  1; 
             if (cci[i]<0) trend[i]= -1;
             if (trend[i] == 1) cciU[i] = cci[i];  
             if (trend[i] ==-1) cciD[i] = cci[i]; 
      }
      
      //
      //
      //
      //
      //
   
      if (alertsOn)
      {
        if (alertsOnCurrent)
             int whichBar = 0;
        else     whichBar = 1;
         
        if (trend[whichBar] != trend[whichBar+1])
        if (trend[whichBar] == 1)
              doAlert("uptrend");
        else  doAlert("downtrend");       
   }
   for (i=limit; i>=0; i--) cciMa[i] = iMAOnArray(cci,0,CciMaPeriod,0,CciMaMethod,i);
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
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2; r = Bars-r-1;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(int k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
}

//+------------------------------------------------------------------+
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
 


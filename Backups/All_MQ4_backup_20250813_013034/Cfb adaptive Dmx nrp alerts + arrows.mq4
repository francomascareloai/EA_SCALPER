//+------------------------------------------------------------------+
//|                                                          dmx.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     LimeGreen
#property indicator_color2     Red
#property indicator_color3     DodgerBlue
#property indicator_color4     Magenta
#property indicator_color5     Magenta
#property indicator_width1     1
#property indicator_width2     1
#property indicator_width3     2
#property indicator_width4     2
#property indicator_width5     2
#property indicator_levelcolor DarkSlateGray

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame                = PERIOD_CURRENT;
extern int                ShortLimit               = 10;
extern int                LongLimit                = 20;
extern int                CfbNormLength            = 50;
extern int                CfbDepth                 = 6;
extern ENUM_APPLIED_PRICE CfbPrice                 = PRICE_WEIGHTED;
extern int                CfbSmooth                = 8;
extern double             CfbSmoothLength          = 1.5;
extern double             CfbSmoothPhase           = 0.0;
extern bool               CfbSmoothDouble          = false;
extern double             DmxPhase                 = 0;
extern bool               DmxSmoothDouble          = true;
extern double             Smooth                   = 10.0;
extern double             SmoothPhase              = 0;
extern bool               SmoothDouble             = true;
extern bool               alertsOn                 = true;
extern bool               alertsOnZeroCross        = true;
extern bool               alertsOnSlope            = true;
extern bool               alertsOnCurrent          = false;
extern bool               alertsMessage            = true;
extern bool               alertsSound              = true;
extern bool               alertsNotify             = false;
extern bool               alertsEmail              = false;
extern string             soundFile                = "alert2.wav"; 
extern bool               arrowsVisible            = true;
extern string             arrowsIdentifier         = "cfbdmx Arrows1";
extern double             arrowsUpperGap           = 0.5;
extern double             arrowsLowerGap           = 0.5;
extern bool               arrowsOnZeroCross        = false;
extern color              arrowsOnZeroCrossUpColor = DeepSkyBlue;
extern color              arrowsOnZeroCrossDnColor = Red;
extern int                arrowsOnZeroCrossUpCode  = 233;
extern int                arrowsOnZeroCrossDnCode  = 234;
extern int                arrowsOnZeroCrossUpSize  = 1;
extern int                arrowsOnZeroCrossDnSize  = 1;
extern bool               arrowsOnSlope            = false;
extern color              arrowsOnSlopeUpColor     = DeepSkyBlue;
extern color              arrowsOnSlopeDnColor     = Red;
extern int                arrowsOnSlopeUpCode      = 233;
extern int                arrowsOnSlopeDnCode      = 234;
extern int                arrowsOnSlopeUpSize      = 1;
extern int                arrowsOnSlopeDnSize      = 1;
extern bool               Interpolate              = true;

extern bool               MultiColor            = true;
extern bool               ShowHistogram         = true;
extern double             upperLevel            = 100;
extern double             lowerLevel            = -100;



//
//
//
//
//

double dmxUp[];
double dmxDn[];
double dmx[];
double dmxUa[];
double dmxUb[];
double cfb[];
double trend1[];
double trend2[];

//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;


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
   for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   IndicatorBuffers(8);
   SetIndexBuffer(0,dmxUp); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,dmxDn); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,dmx); 
   SetIndexBuffer(3,dmxUa);
   SetIndexBuffer(4,dmxUb);
   SetIndexBuffer(5,cfb);
   SetIndexBuffer(6,trend1); 
   SetIndexBuffer(7,trend2); 
   SetLevelValue(0,0);
   SetLevelValue(1,upperLevel);
   SetLevelValue(2,lowerLevel);

   
   if (ShowHistogram)
   {
      SetIndexStyle(0,DRAW_HISTOGRAM); 
      SetIndexStyle(1,DRAW_HISTOGRAM); 
   }
   else
   {
      SetIndexStyle(0,DRAW_NONE); 
      SetIndexStyle(1,DRAW_NONE);
   }
    

      //
      //
      //
      //
      //
   
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame==-99;
      TimeFrame         = MathMax(TimeFrame,_Period);
      
      //
      //
      //
      //
      //
   
      IndicatorShortName(timeFrameToString(TimeFrame)+ " Cfb adaptive Dmx ("+ShortLimit+","+LongLimit+")");
return(0);
}
int deinit() 
{ 
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
      if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
return (0);
}


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
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { dmxUp[0] = limit+1; return(0); }
           
   //
   //
   //
   //
   //
           
   if (TimeFrame == Period())
   {
      if (MultiColor && trend1[limit]==-1) CleanPoint(limit,dmxUa,dmxUb);
      for (i=limit; i>=0; i--)
      {
         cfb[i] = iDSmooth(iCfb(getPrice(CfbPrice,i),CfbDepth,CfbSmooth,i),CfbSmoothLength,CfbSmoothPhase,CfbSmoothDouble,i,0);
    
         //
         //
         //
         //
         //
         
         double cfbMax = cfb[i];
         double cfbMin = cfb[i];
         for (int k=1; k<CfbNormLength && (i+k)<Bars; k++ )
            {
               cfbMax = MathMax(cfb[i+k],cfbMax);
               cfbMin = MathMin(cfb[i+k],cfbMin);
            }
            double denominator = cfbMax-cfbMin;
               if (denominator> 0)
                  double ratio = (cfb[i]-cfbMin)/denominator;
               else      ratio = 0.5;                 
      //
      //
      //
      //
      //

      double DmxLength  = MathCeil(ShortLimit+ratio*(LongLimit-ShortLimit));
      double currTR     = iDSmooth(MathMax(High[i],Close[i+1])-MathMin(Low[i],Close[i+1]),DmxLength,DmxPhase,DmxSmoothDouble,i,20);
      double DeltaHi    = High[i] - High[i+1];
      double DeltaLo    = Low[i+1] - Low[i];
      double plusDM     = 0.00;
      double minusDM    = 0.00;

         if ((DeltaHi > DeltaLo) && (DeltaHi > 0)) plusDM  = DeltaHi;
         if ((DeltaLo > DeltaHi) && (DeltaLo > 0)) minusDM = DeltaLo;      
         
      //
      //
      //
      //
      //

         double DIp = 0.00;
         double DIm = 0.00;

            if (currTR > 0.00)
            {
               DIp = 100.0*iDSmooth(plusDM ,DmxLength,DmxPhase,DmxSmoothDouble,i,40)/currTR;
               DIm = 100.0*iDSmooth(minusDM,DmxLength,DmxPhase,DmxSmoothDouble,i,60)/currTR;
            }
            if ((DIp+DIm) != 0)
                  dmx[i]   = 100.00*iDSmooth((DIp-DIm)/(DIp+DIm),Smooth,SmoothPhase,SmoothDouble,i,80);
            else  dmx[i]   = 100.00*iDSmooth(0                  ,Smooth,SmoothPhase,SmoothDouble,i,80);
                  dmxUa[i]  = EMPTY_VALUE;
                  dmxUb[i]  = EMPTY_VALUE;
                  dmxUp[i]  = EMPTY_VALUE;
                  dmxDn[i]  = EMPTY_VALUE;
                  trend1[i] = trend1[i+1];
                  trend2[i] = trend2[i+1];
 
                  if (dmx[i]>dmx[i+1]) trend1[i]= 1;
                  if (dmx[i]<dmx[i+1]) trend1[i]=-1;
                  if (dmx[i]>0)        trend2[i]= 1;
                  if (dmx[i]<0)        trend2[i]=-1;
                  if (trend2[i] == 1)  dmxUp[i] = dmx[i];
                  if (trend2[i] ==-1)  dmxDn[i] = dmx[i];
                  if (MultiColor && trend1[i]==-1) PlotPoint(i,dmxUa,dmxUb,dmx);
                  
                  //
                  //
                  //
                  //
                  //
               
                  if (arrowsVisible)
                  {
                    ObjectDelete(arrowsIdentifier+":1:"+Time[i]);
                    ObjectDelete(arrowsIdentifier+":2:"+Time[i]);
                    string lookFor = arrowsIdentifier+":"+Time[i]; ObjectDelete(lookFor);
                    if (arrowsOnZeroCross && trend2[i] != trend2[i+1])
                    {
                      if (trend2[i] == 1) drawArrow("1",0.5,i,arrowsOnZeroCrossUpColor,arrowsOnZeroCrossUpCode,arrowsOnZeroCrossUpSize,false);
                      if (trend2[i] ==-1) drawArrow("1",0.5,i,arrowsOnZeroCrossDnColor,arrowsOnZeroCrossDnCode,arrowsOnZeroCrossDnSize,true);
                    } 
                    if (arrowsOnSlope && trend1[i] != trend1[i+1]) 
                    { 
                      if (trend1[i] == 1) drawArrow("2",1.0,i,arrowsOnSlopeUpColor,arrowsOnSlopeUpCode,arrowsOnSlopeUpSize,false);
                      if (trend1[i] ==-1) drawArrow("2",1.0,i,arrowsOnSlopeDnColor,arrowsOnSlopeDnCode,arrowsOnSlopeDnSize,true);
                                                           
                    }         
                  }                   
         
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

         //
         //
         //
         //
         //
            
         static datetime time1 = 0;
         static string   mess1 = "";
         if (alertsOnZeroCross && trend2[whichBar] != trend2[whichBar+1])
         {
            if (trend2[whichBar] ==  1) doAlert(time1,mess1,whichBar,"Crossed zero line up");
            if (trend2[whichBar] == -1) doAlert(time1,mess1,whichBar,"Crossed zero line down");
         }
      
         static datetime time2 = 0;
         static string   mess2 = "";
         if (alertsOnSlope && trend1[whichBar] != trend1[whichBar+1])
         {
            if (trend1[whichBar] ==  1) doAlert(time2,mess2,whichBar,"sloping up");
            if (trend1[whichBar] == -1) doAlert(time2,mess2,whichBar,"sloping down");
         }
      
      }
      return(0);
      }
      
      //
      //
      //
      //
      //
      
      limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
      if (MultiColor && trend1[limit]==-1) CleanPoint(limit,dmxUa,dmxUb);
        for (i=limit;i>=0; i--)
        {
           int y = iBarShift(NULL,TimeFrame,Time[i]);
              dmx[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,ShortLimit,LongLimit,CfbNormLength,CfbDepth,CfbPrice,CfbSmooth,CfbSmoothLength,CfbSmoothPhase,CfbSmoothDouble,DmxPhase,DmxSmoothDouble,Smooth,SmoothPhase,SmoothDouble,alertsOn,alertsOnZeroCross,alertsOnSlope,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,
                          arrowsVisible,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsOnZeroCross,arrowsOnZeroCrossUpColor,arrowsOnZeroCrossDnColor,arrowsOnZeroCrossUpCode,arrowsOnZeroCrossDnCode,arrowsOnZeroCrossUpSize,arrowsOnZeroCrossDnSize,arrowsOnSlope,arrowsOnSlopeUpColor,arrowsOnSlopeDnColor,arrowsOnSlopeUpCode,arrowsOnSlopeDnCode,arrowsOnSlopeUpSize,arrowsOnSlopeDnSize,2,y);
              trend1[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,ShortLimit,LongLimit,CfbNormLength,CfbDepth,CfbPrice,CfbSmooth,CfbSmoothLength,CfbSmoothPhase,CfbSmoothDouble,DmxPhase,DmxSmoothDouble,Smooth,SmoothPhase,SmoothDouble,alertsOn,alertsOnZeroCross,alertsOnSlope,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,
                          arrowsVisible,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsOnZeroCross,arrowsOnZeroCrossUpColor,arrowsOnZeroCrossDnColor,arrowsOnZeroCrossUpCode,arrowsOnZeroCrossDnCode,arrowsOnZeroCrossUpSize,arrowsOnZeroCrossDnSize,arrowsOnSlope,arrowsOnSlopeUpColor,arrowsOnSlopeDnColor,arrowsOnSlopeUpCode,arrowsOnSlopeDnCode,arrowsOnSlopeUpSize,arrowsOnSlopeDnSize,6,y);
              trend2[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,ShortLimit,LongLimit,CfbNormLength,CfbDepth,CfbPrice,CfbSmooth,CfbSmoothLength,CfbSmoothPhase,CfbSmoothDouble,DmxPhase,DmxSmoothDouble,Smooth,SmoothPhase,SmoothDouble,alertsOn,alertsOnZeroCross,alertsOnSlope,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,
                          arrowsVisible,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsOnZeroCross,arrowsOnZeroCrossUpColor,arrowsOnZeroCrossDnColor,arrowsOnZeroCrossUpCode,arrowsOnZeroCrossDnCode,arrowsOnZeroCrossUpSize,arrowsOnZeroCrossDnSize,arrowsOnSlope,arrowsOnSlopeUpColor,arrowsOnSlopeDnColor,arrowsOnSlopeUpCode,arrowsOnSlopeDnCode,arrowsOnSlopeUpSize,arrowsOnSlopeDnSize,7,y); 
              dmxUa[i] = EMPTY_VALUE;
              dmxUb[i] = EMPTY_VALUE;
              dmxUp[i] = EMPTY_VALUE;
              dmxDn[i] = EMPTY_VALUE;
              
              if (trend2[i] == 1) dmxUp[i] = dmx[i];
              if (trend2[i] ==-1) dmxDn[i] = dmx[i];
      
              //
              //
              //
              //
              //
      
              if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;

              //
              //
              //
              //
              //

              datetime time = iTime(NULL,TimeFrame,y);
                 for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
                 for(int j = 1; j < n; j++)  
                 { 
                    dmx[i+j] = dmx[i] + (dmx[i+n] - dmx[i]) * j/n; 
                    if (dmxUp[i]!= EMPTY_VALUE) dmxUp[i+j]  = dmx[i+j];
                    if (dmxDn[i]!= EMPTY_VALUE) dmxDn[i+j]  = dmx[i+j];
                 }
     }
     if (MultiColor) for (i=limit;i>=0;i--) if (trend1[i]==-1) PlotPoint(i,dmxUa,dmxUb,dmx);
return(0);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

double getPrice(int type, int i)
{
   switch (type)
   {
      case 7:     return((Open[i]+Close[i])/2.0);
      case 8:     return((Open[i]+High[i]+Low[i]+Close[i])/4.0);
      default :   return(iMA(NULL,0,1,0,MODE_SMA,type,i));
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int    Depths[] = {2,3,4,6,8,12,16,24,32,48,64,96,128,192};
double workCfb[][28];

//
//
//
//
//

double iCfb(double price, int depth, int smooth, int r)
{
   if (ArrayRange(workCfb,0) != Bars) ArrayResize(workCfb,Bars);
   int i = Bars-r-1;
         
   //
   //
   //
   //
   //

   double suma     = 0;
   double sumb     = 0;
   double tcfb     = 0;
   double evenCoef = 1;
   double oddCoef  = 1;
   double avg      = 0;
         
      if (i>=smooth)
         for (int k=depth-1; k>=0; k--)
         {
            workCfb[i][k]    = iCfbFunc(price,i,Depths[k],k);
            workCfb[i][k+14] = workCfb[i-1][k+14] + (workCfb[i][k]-workCfb[i-smooth][k])/smooth;

                  if ((k%2)==0)
                        { avg = oddCoef  * workCfb[i][k+14]; oddCoef  = oddCoef  * (1 - avg); }
                  else  { avg = evenCoef * workCfb[i][k+14]; evenCoef = evenCoef * (1 - avg); }
               
               suma += avg*avg*Depths[k];
               sumb += avg;
         }
      else for (k=depth-1; k>=0; k--) { workCfb[i][k] = 0; workCfb[i][k+14] = 0; }            

   //
   //
   //
   //
   //

   if (sumb != 0) tcfb = suma/sumb;
   return(tcfb);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

double  workCfbFunc[][70];
#define _prices 0
#define _roc    1
#define _value1 2
#define _value2 3
#define _value3 4

//
//
//
//

double iCfbFunc(double price, int r, int depth, int k)
{
   k *= 5;
      if (ArrayRange(workCfbFunc,0) != Bars) ArrayResize(workCfbFunc,Bars);
      if (r<=(depth+1))
      {
         workCfbFunc[r][k+_prices] = 0;
         workCfbFunc[r][k+_roc]    = 0;
         workCfbFunc[r][k+_value1] = 0;
         workCfbFunc[r][k+_value2] = 0;
         workCfbFunc[r][k+_value3] = 0;
         return(0);
      }         
      workCfbFunc[r][k+_prices] = price; 

   //
   //
   //
   //
   //

      workCfbFunc[r][k+_roc]    = MathAbs(workCfbFunc[r][k+_prices] - workCfbFunc[r-1][k+_prices]);
      workCfbFunc[r][k+_value1] = workCfbFunc[r-1][k+_value1] - workCfbFunc[r-depth][k+_roc] + workCfbFunc[r][k+_roc];
      workCfbFunc[r][k+_value2] = workCfbFunc[r-1][k+_value2] - workCfbFunc[r-1][k+_value1] + workCfbFunc[r][k+_roc]*depth;
      workCfbFunc[r][k+_value3] = workCfbFunc[r-1][k+_value3] - workCfbFunc[r-1-depth][k+_prices] + workCfbFunc[r-1][k+_prices];
   
      double dividend = MathAbs(depth*workCfbFunc[r][k+_prices]-workCfbFunc[r][k+_value3]);

      //
      //
      //
      //
      //
         
   if (workCfbFunc[r][k+_value2] != 0)
         return( dividend / workCfbFunc[r][k+_value2]);
   else  return(0.00);            
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

double wrk[][100];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

//
//
//
//
//

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0)
{
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Cfb adaptive dmx ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Cfb adaptive dmx "),message);
          if (alertsSound)   PlaySound(soundFile);
   }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void drawArrow(string nameAdd, double gapMul, int i,color theColor,int theCode,int theSize, bool up)
{
   string tname = arrowsIdentifier+":"+nameAdd+":"+Time[i];
   double gap   = iATR(NULL,0,20,i)*gapMul;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(tname,OBJ_ARROW,0,Time[i],0);
         ObjectSet(tname,OBJPROP_ARROWCODE,theCode);
         ObjectSet(tname,OBJPROP_COLOR,theColor);
         ObjectSet(tname,OBJPROP_WIDTH,theSize );  
         if (up)
               ObjectSet(tname,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(tname,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

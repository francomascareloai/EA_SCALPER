//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     clrDarkGray
#property indicator_color2     clrLimeGreen
#property indicator_color3     clrLimeGreen
#property indicator_color4     clrOrange
#property indicator_color5     clrOrange
#property indicator_width1     2
#property indicator_width2     3
#property indicator_width3     3
#property indicator_width4     3
#property indicator_width5     3
#property indicator_minimum   -0.1
#property indicator_maximum    1.1
#property strict

//
//
//
//
//

#define _fltPrc 0x01
#define _fltVal 0x10
enum enFltWhat
{
   flt_01 = _fltPrc,        // Filter the price
   flt_02 = _fltVal,        // Filter the value
   flt_03 = _fltPrc+_fltVal // Filter the price and the value
};
input int                 Length          = 30;           // Period
input ENUM_APPLIED_PRICE  Price           = PRICE_CLOSE;  // Price
input string              BaseSymbol      = "GBPUSD";     // Symbol to compare to
input double              TresholdUp      = 0.8;          // Upper treshlod
input double              TresholdDn      = 0.2;          // Lower treshlod
input int                 PreSmooth       = 8;            // Price smoothing period
input int                 PreSmoothPhase  = 0;            // Price smoothing phase
input int                 PosSmooth       = 0;            // Result smoothing period
input int                 PosSmoothPhase  = 0;            // Result smoothing phase
input double              Filter          = 0;            // Filter to use for filtering (<=0 - no filtering)
input enFltWhat           FilterWhat      = _fltVal;      // Filter on :
input bool                alertsOn        = true;         // Alerts true/false?
input bool                alertsOnCurrent = false;        // Alerts open bar true/false?
input bool                alertsMessage   = true;         // Alerts pop-up message true/false?
input bool                alertsSound     = false;        // Alerts sound true/false?
input bool                alertsNotify    = false;        // Alerts push notification true/false?
input bool                alertsEmail     = false;        // Alerts email true/false?
input string              soundFile        = "alert2.wav"; // Sound file

double stoch[],stochua[],stochub[],stochda[],stochdb[],stocha[],stochb[],stochc[],pricesa[],pricesb[],state[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
   IndicatorBuffers(11);
   SetIndexBuffer( 0, stoch,  INDICATOR_DATA); 
   SetIndexBuffer( 1, stochua,INDICATOR_DATA); 
   SetIndexBuffer( 2, stochub,INDICATOR_DATA); 
   SetIndexBuffer( 3, stochda,INDICATOR_DATA); 
   SetIndexBuffer( 4, stochdb,INDICATOR_DATA); 
   SetIndexBuffer( 5, stocha); 
   SetIndexBuffer( 6, stochb); 
   SetIndexBuffer( 7, stochc); 
   SetIndexBuffer( 8, pricesa); 
   SetIndexBuffer( 9, pricesb); 
   SetIndexBuffer(10, state); 
      SetLevelValue(0,0);
      SetLevelValue(1,1);
      SetLevelValue(2,TresholdUp);
      SetLevelValue(2,TresholdUp);
      SetLevelValue(3,TresholdDn);
   IndicatorShortName("ds - divergences "+_Symbol+" to : "+BaseSymbol+" ("+(string)Length+")");
   return(0);
}
int deinit()
{
   return(0);
}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         
   //
   //
   //
   //
   //

   double pfilter = ((FilterWhat&_fltPrc)==0) ? 0 : Filter;
   double vfilter = ((FilterWhat&_fltVal)==0) ? 0 : Filter;
   if (state[limit]== 1) CleanPoint(limit,stochua,stochub);
   if (state[limit]==-1) CleanPoint(limit,stochda,stochdb);
   for(int i=limit; i>=0; i--)
   {
      pricesa[i] = iSmooth(iFilter(iMA(NULL      ,0,1,0,MODE_SMA,Price,i),pfilter,Length,i,0),PreSmooth,PreSmoothPhase,i,0);
      pricesb[i] = iSmooth(iFilter(iMA(BaseSymbol,0,1,0,MODE_SMA,Price,i),pfilter,Length,i,1),PreSmooth,PreSmoothPhase,i,1);
      stochda[i] = stochdb[i] = EMPTY_VALUE;
      stochua[i] = stochub[i] = EMPTY_VALUE;
      double min=0,max=0;
         max = pricesa[ArrayMaximum(pricesa,Length,i)];
         min = pricesa[ArrayMinimum(pricesa,Length,i)];
            stocha[i] = (max!=min) ? (pricesa[i]-min)/(max-min) : 0.5;
         max = pricesb[ArrayMaximum(pricesb,Length,i)];
         min = pricesb[ArrayMinimum(pricesb,Length,i)];
            stochb[i] = (max!=min) ? (pricesb[i]-min)/(max-min) : 0.5;
            stochc[i] = stocha[i]-stochb[i];
         max = stochc[ArrayMaximum(stochc,Length*10,i)];
         min = stochc[ArrayMinimum(stochc,Length*10,i)];
            stoch[i] = (max!=min) ? iFilter(fmax(fmin(iSmooth((stochc[i]-min)/(max-min),PosSmooth,PosSmoothPhase,i,2),1),0),vfilter,Length,i,2) :
                                    iFilter(fmax(fmin(iSmooth(0.5                      ,PosSmooth,PosSmoothPhase,i,2),1),0),vfilter,Length,i,2);
            state[i] = (stoch[i]>TresholdUp) ? 1 : (stoch[i]<TresholdDn) ? -1 : 0;
        if (state[i] ==  1) PlotPoint(i,stochua,stochub,stoch);
        if (state[i] == -1) PlotPoint(i,stochda,stochdb,stoch);
   }
   if (alertsOn)
   {
      int whichBar = (alertsOnCurrent) ? 0 : 1;
      if (state[whichBar] != state[whichBar+1])
      {
         if (state[whichBar] == 1) doAlert(" crossing upper threshold");
         if (state[whichBar] ==-1) doAlert(" crossing lower threshold");       
      }         
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

#define _filterInstances 3
double workFil[][_filterInstances*3];

#define _fchange 0
#define _fachang 1
#define _fvalue  2

double iFilter(double value, double filter, int period, int i, int instanceNo=0)
{
   if (filter<=0 || period<=0) return(value); i=Bars-i-1;
   if (ArrayRange(workFil,0)!= Bars) ArrayResize(workFil,Bars); instanceNo*=3;
   
   //
   //
   //
   //
   //
   
   workFil[i][instanceNo+_fvalue] = value;
   if (i>0)
   {
      workFil[i][instanceNo+_fchange] = MathAbs(workFil[i][instanceNo+_fvalue]-workFil[i-1][instanceNo+_fvalue]);
      workFil[i][instanceNo+_fachang] = workFil[i][instanceNo+_fchange];

      double fdev=0;
      for (int k=1; k<period && (i-k)>=0; k++) workFil[i][instanceNo+_fachang] += workFil[i-k][instanceNo+_fchange]; workFil[i][instanceNo+_fachang] /= (double)period;
      for (int k=0; k<period && (i-k)>=0; k++) fdev += MathPow(workFil[i-k][instanceNo+_fchange]-workFil[i-k][instanceNo+_fachang],2); fdev = filter*MathSqrt(fdev/(double)period);
      if (MathAbs(workFil[i][instanceNo+_fvalue]-workFil[i-1][instanceNo+_fvalue])<fdev) 
                  workFil[i][instanceNo+_fvalue]=workFil[i-1][instanceNo+_fvalue];
   }
   return(workFil[i][instanceNo+_fvalue]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double wrk[][30];
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

double iSmooth(double tprice, double length, double phase, int i, int s=0)
{
   if (length <=1) return(tprice);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars); 
   
   int r = Bars-i-1; s *= 10;
      if (r==0) { int k; for(k=0; k<7; k++) wrk[0][k+s]=tprice; for(; k<10; k++) wrk[0][k+s]=0; return(tprice); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = tprice - wrk[r-1][bsmax+s];
      double del2   = tprice - wrk[r-1][bsmin+s];
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
            double dVolty = 0;
            if (wrk[r][avolty+s] > 0) dVolty = wrk[r][volty+s]/wrk[r][avolty+s];
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

         if (del1 > 0) wrk[r][bsmax+s] = tprice; else wrk[r][bsmax+s] = tprice - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = tprice; else wrk[r][bsmin+s] = tprice - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = tprice + alpha*(wrk[r-1][0+s]-tprice);
         wrk[r][1+s] = (tprice - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" dual stoch - dovergence "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" dual stoch - dovergence ",message);
             if (alertsSound)   PlaySound(soundFile);
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
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}
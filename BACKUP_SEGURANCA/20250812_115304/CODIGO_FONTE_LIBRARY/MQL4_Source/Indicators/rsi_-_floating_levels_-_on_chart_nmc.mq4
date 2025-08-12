//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1  DeepSkyBlue  
#property indicator_color2  DeepSkyBlue  
#property indicator_color3  DimGray
#property indicator_color4  PaleVioletRed
#property indicator_color5  PaleVioletRed
#property indicator_color6  LimeGreen
#property indicator_color7  PaleVioletRed
#property indicator_color8  PaleVioletRed
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT
#property indicator_style5  STYLE_DOT

//
//
//
//
//

extern string TimeFrame    = "Current time frame";
extern int    RsiPeriod    =  14;
extern int    RsiPrice     =  PRICE_CLOSE;
extern int    RsiMethod    =   0;
extern double T3Hot        = 0.7;
extern bool   T3Original   = false;
extern int    MinMaxPeriod = 100;
extern double LevelUp      =  80;
extern double LevelDown    =  20;
extern double LevelUp2     =  60;
extern double LevelDown2   =  40;
extern double SmoothPeriod =   8;
extern double SmoothPhase  =   0;
extern int    ChartAlignmentPeriod     = 20;
extern int    ChartAlignmentMaMode     = MODE_SMA;
extern int    ChartAlignmentPrice      = PRICE_TYPICAL;
extern double ChartAlignmentDeviations = 2;
extern bool   Interpolate  = true;

//
//
//
//
//

double rsiLUp[];
double rsiLUp2[];
double rsiLMi[];
double rsiLDn2[];
double rsiLDn[];
double rsi[];
double rsida[];
double rsidb[];

int    timeFrame;
string indicatorFileName;
bool   returnBars;
bool   calculateValue;
string shortName;

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
// 
//
//
//
//

int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,rsiLUp);
   SetIndexBuffer(1,rsiLUp2);
   SetIndexBuffer(2,rsiLMi);
   SetIndexBuffer(3,rsiLDn2);
   SetIndexBuffer(4,rsiLDn);
   SetIndexBuffer(5,rsi);
   SetIndexBuffer(6,rsida);
   SetIndexBuffer(7,rsidb);
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
   
      shortName = timeFrameToString(timeFrame)+" "+getRsiName(RsiMethod)+" ("+RsiPeriod+","+DoubleToStr(LevelDown,2)+","+DoubleToStr(LevelUp,2)+")";
      IndicatorShortName(shortName);
   return(0);
}
int deinit()
{
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

double slope[];
double pr[];
double rsitm[];

int start()
{
   int i,r,limit,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { rsiLUp[0] = limit+1; return(0); }
         if (ArraySize(slope)!=Bars) ArrayResize(slope,Bars);
         if (ArraySize(pr)!=Bars) ArrayResize(pr,Bars);
         if (ArraySize(rsitm)!=Bars) ArrayResize(rsitm,Bars);

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (slope[Bars-limit-1]==-1) CleanPoint(limit,rsida,rsidb);
      for(i=limit, r=Bars-i-1; i>=0; i--,r++) 
      {
         pr[r]      = iMA(NULL,0,1                   ,0,MODE_SMA            ,ChartAlignmentPrice,i);
         double mid = iMA(NULL,0,ChartAlignmentPeriod,0,ChartAlignmentMaMode,ChartAlignmentPrice,i);
         double dev = ChartAlignmentDeviations*iDeviation(pr,ChartAlignmentPeriod,mid,r)/(50.0/ChartAlignmentDeviations);
         rsitm[r] = iSmooth(iRsi(iMA(NULL,0,1,0,MODE_SMA,RsiPrice,i),RsiPeriod,RsiMethod,i,0),SmoothPeriod,SmoothPhase,i);
         rsida[i] = EMPTY_VALUE;
         rsidb[i] = EMPTY_VALUE;
            double rsiMin = rsitm[r];
            double rsiMax = rsitm[r];
            for (int m = 1; m < MinMaxPeriod; m++)
            {
               rsiMin = MathMin(rsitm[r-m],rsiMin);
               rsiMax = MathMax(rsitm[r-m],rsiMax);
            }  
            double range  = dev*(rsiMax-rsiMin);
            double rsili  = mid+(rsitm[r]-50)*dev;
               rsiMin     = mid+(rsiMin-50)*dev;
               rsi[i]     = rsili;
               rsiLDn[i]  = rsiMin+range*LevelDown /100.0;
               rsiLDn2[i] = rsiMin+range*LevelDown2/100.0;
               rsiLMi[i]  = rsiMin+range*50.0      /100.0;
               rsiLUp2[i] = rsiMin+range*LevelUp2  /100.0;
               rsiLUp[i]  = rsiMin+range*LevelUp   /100.0;
               slope[r]   = slope[r-1];
                  if (rsitm[r]>rsitm[r-1]) slope[r] =  1;
                  if (rsitm[r]<rsitm[r-1]) slope[r] = -1;
                  if (calculateValue)
                        rsida[i] = slope[r];
                  else  if (slope[r]==-1) PlotPoint(i,rsida,rsidb,rsi);
      }      
      return(0);
   }

   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (slope[Bars-limit-1]==-1) CleanPoint(limit,rsida,rsidb);
   for(i=limit, r=Bars-i-1; i>=0; i--,r++) 
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         rsiLUp[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiMethod,T3Hot,T3Original,MinMaxPeriod,LevelUp,LevelDown,LevelUp2,LevelDown2,SmoothPeriod,SmoothPhase,ChartAlignmentPeriod,ChartAlignmentMaMode,ChartAlignmentPrice,ChartAlignmentDeviations,0,y);
         rsiLUp2[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiMethod,T3Hot,T3Original,MinMaxPeriod,LevelUp,LevelDown,LevelUp2,LevelDown2,SmoothPeriod,SmoothPhase,ChartAlignmentPeriod,ChartAlignmentMaMode,ChartAlignmentPrice,ChartAlignmentDeviations,1,y);
         rsiLMi[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiMethod,T3Hot,T3Original,MinMaxPeriod,LevelUp,LevelDown,LevelUp2,LevelDown2,SmoothPeriod,SmoothPhase,ChartAlignmentPeriod,ChartAlignmentMaMode,ChartAlignmentPrice,ChartAlignmentDeviations,2,y);
         rsiLDn2[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiMethod,T3Hot,T3Original,MinMaxPeriod,LevelUp,LevelDown,LevelUp2,LevelDown2,SmoothPeriod,SmoothPhase,ChartAlignmentPeriod,ChartAlignmentMaMode,ChartAlignmentPrice,ChartAlignmentDeviations,3,y);
         rsiLDn[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiMethod,T3Hot,T3Original,MinMaxPeriod,LevelUp,LevelDown,LevelUp2,LevelDown2,SmoothPeriod,SmoothPhase,ChartAlignmentPeriod,ChartAlignmentMaMode,ChartAlignmentPrice,ChartAlignmentDeviations,4,y);
         rsi   [i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiMethod,T3Hot,T3Original,MinMaxPeriod,LevelUp,LevelDown,LevelUp2,LevelDown2,SmoothPeriod,SmoothPhase,ChartAlignmentPeriod,ChartAlignmentMaMode,ChartAlignmentPrice,ChartAlignmentDeviations,5,y);
         rsida[i]  = EMPTY_VALUE;
         rsidb[i]  = EMPTY_VALUE;
               slope[r] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,RsiPrice,RsiMethod,T3Hot,T3Original,MinMaxPeriod,LevelUp,LevelDown,LevelUp2,LevelDown2,SmoothPeriod,SmoothPhase,ChartAlignmentPeriod,ChartAlignmentMaMode,ChartAlignmentPrice,ChartAlignmentDeviations,6,y);
            
         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int k = 1; k < n; k++)
            {
               rsiLUp[i+k]  = rsiLUp[i]  + (rsiLUp[i+n]  - rsiLUp[i])*k/n;
               rsiLUp2[i+k] = rsiLUp2[i] + (rsiLUp2[i+n] - rsiLUp2[i])*k/n;
               rsiLMi[i+k]  = rsiLMi[i]  + (rsiLMi[i+n]  - rsiLMi[i])*k/n;
               rsiLDn2[i+k] = rsiLDn2[i] + (rsiLDn2[i+n] - rsiLDn2[i])*k/n;
               rsiLDn[i+k]  = rsiLDn[i]  + (rsiLDn[i+n]  - rsiLDn[i])*k/n;
               rsi[i+k]     = rsi[i]     + (rsi[i+n]     - rsi[i]   )*k/n;
            }
   }
   for(i=limit, r=Bars-i-1; i>=0; i--,r++) if (slope[r]==-1) PlotPoint(i,rsida,rsidb,rsi);
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

double iDeviation(double& array[], double period, double ma, int r)
{
   double sum = 0.00;
      for(int k=0; k<period; k++) sum += (array[r-k]-ma)*(array[r-k]-ma);
   return(MathSqrt(sum/period));
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
//

string rsiMethodNames[] = {"rsi","Wilders rsi","rsx","Cuttler RSI","T3 rsi"};
string getRsiName(int& method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=MathMax(MathMin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

double workRsi[][13];
#define _price  0
#define _change 1
#define _changa 2

double iRsi(double price, double period, int rsiMode, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*13; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case 0:
         double alpha = 1.0/period; 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
         
      //
      //
      //
      //
      //
      
      case 1 :
         workRsi[r][z+1] = iSmma(0.5*(MathAbs(workRsi[r][z+_price]-workRsi[r-1][z+_price])+(workRsi[r][z+_price]-workRsi[r-1][z+_price])),0.5*(period-1),Bars-i-1,instanceNo*2+0);
         workRsi[r][z+2] = iSmma(0.5*(MathAbs(workRsi[r][z+_price]-workRsi[r-1][z+_price])-(workRsi[r][z+_price]-workRsi[r-1][z+_price])),0.5*(period-1),Bars-i-1,instanceNo*2+1);
         if((workRsi[r][z+1] + workRsi[r][z+2]) != 0) 
               return(100.0 * workRsi[r][z+1]/(workRsi[r][z+1] + workRsi[r][z+2]));
         else  return(50);

      //
      //
      //
      //
      //

      case 2 :     
         double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
         if (r<period) { for (k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

         //
         //
         //
         //
         //
      
         double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
         double moa = MathAbs(mom);
         for (k=0; k<3; k++)
         {
            int kk = k*2;
            workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
            workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
            workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
            workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
         }
         if (moa != 0)
              return(MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00)); 
         else return(50);
            
      //
      //
      //
      //
      //
      
      case 3 :
         double sump = 0;
         double sumn = 0;
         for (k=0; k<period; k++)
         {
            double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
               if (diff > 0) sump += diff;
               if (diff < 0) sumn -= diff;
         }
         if (sumn > 0)
               return(100.0-100.0/(1.0+sump/sumn));
         else  return(50);
         
      //
      //
      //
      //
      //
               
      case 4 : 
         double chng   = workRsi[r][_price]-workRsi[r-1][_price];
         double changn = iT3(        chng ,period,T3Hot,T3Original,i,instanceNo*2+0);
         double changa = iT3(MathAbs(chng),period,T3Hot,T3Original,i,instanceNo*2+1);
            if (changn != 0)
                  return(MathMin(MathMax(50.0*(changn/MathMax(changa,0.0000001)+1.0),0),100));
            else  return(50.0);
   } 
   return(0);
}

//
//
//
//
//
//

double workSmma[][2];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workT3[][12];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int instanceNo=0)
{
   if (ArrayRange(workT3,0) != Bars)                ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);

   if (workT3Coeffs[instanceNo][_period] != period)
   {
     workT3Coeffs[instanceNo][_period] = period;
        double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = instanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
      }
   else
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

double wrk[][10];

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

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars); s*= 10;
   
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

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
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

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}


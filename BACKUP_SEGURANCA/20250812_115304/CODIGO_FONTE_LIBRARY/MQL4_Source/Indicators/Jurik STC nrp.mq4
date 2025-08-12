//+------------------------------------------------------------------+
//|                                           Schaff Trend Cycle.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  Red
#property indicator_color2  LimeGreen
#property indicator_color3  LimeGreen
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
#property indicator_level1  25
#property indicator_level2  75
#property indicator_levelcolor Magenta

//
//
//
//
//

extern int STCPeriod    = 10;
extern int FastMAPeriod = 23;
extern int FastMAPhase  = 0;
extern int SlowMAPeriod = 50;
extern int SlowMAPhase  = 0;
extern int FilterMode   = 3;

//
//
//
//
//

double stcBuffer[];
double stcBufferUA[];
double stcBufferUB[];
double macdBuffer[];
double fastKBuffer[];
double fastDBuffer[];
double fastKKBuffer[];
double trend[];


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
   IndicatorBuffers(8);
      SetIndexBuffer(0,stcBuffer);
      SetIndexBuffer(1,stcBufferUA);
      SetIndexBuffer(2,stcBufferUB);
      SetIndexBuffer(3,macdBuffer);
      SetIndexBuffer(4,fastKBuffer);
      SetIndexBuffer(5,fastDBuffer);
      SetIndexBuffer(6,fastKKBuffer);
      SetIndexBuffer(7,trend);
   IndicatorShortName("jurik STC ("+STCPeriod+","+FastMAPeriod+","+SlowMAPeriod+")");
   return(0);
}

int deinit()
{
   return(0);
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
   int      counted_bars=IndicatorCounted();
   int      limit,i;

   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         if (trend[limit]==1) CleanPoint(limit,stcBufferUA,stcBufferUB);

   //
   //
   //
   //
   //
   
   for(i = limit; i >= 0; i--)
   {
      macdBuffer[i] = iSmooth(Close[i],FastMAPeriod,FastMAPhase,FilterMode,i)-
                      iSmooth(Close[i],SlowMAPeriod,SlowMAPhase,FilterMode,i,10);

      //
      //
      //
      //
      //
      
      double lowMacd  = minValue(macdBuffer,i);
      double highMacd = maxValue(macdBuffer,i)-lowMacd;
         if (highMacd > 0)
               fastKBuffer[i] = 100*((macdBuffer[i]-lowMacd)/highMacd);
         else  fastKBuffer[i] = fastKBuffer[i+1];
               fastDBuffer[i] = fastDBuffer[i+1]+0.5*(fastKBuffer[i]-fastDBuffer[i+1]);
               
      //
      //
      //
      //
      //
                     
      double lowStoch  = minValue(fastDBuffer,i);
      double highStoch = maxValue(fastDBuffer,i)-lowStoch;
         if (highStoch > 0)
               fastKKBuffer[i] = 100*((fastDBuffer[i]-lowStoch)/highStoch);
         else  fastKKBuffer[i] = fastKKBuffer[i+1];
               stcBuffer[i]    = stcBuffer[i+1]+0.5*(fastKKBuffer[i]-stcBuffer[i+1]);
      
         //
         //
         //
         //
         //

         trend[i]=trend[i+1];      
         stcBufferUA[i] = EMPTY_VALUE;
         stcBufferUB[i] = EMPTY_VALUE;
            if (stcBuffer[i] > stcBuffer[i+1]) trend[i] = 1;
            if (stcBuffer[i] < stcBuffer[i+1]) trend[i] =-1;
            if (trend[i] == 1) PlotPoint(i,stcBufferUA,stcBufferUB,stcBuffer);
   }   
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double wrk[][20];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9


double iSmooth(double price, double length, double phase, int filterMode, int i, int s=0)
{
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[0][k+s]= price; for(; k<10; k++) wrk[0][k+s]= 0; return(price); }

   //
   //
   //
   //
   //
   
      double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1 = MathMax(len1-2.0,0.5);
      double del1 = price - wrk[r-1][bsmax+s];
      double del2 = price - wrk[r-1][bsmin+s];
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + 0.1*(wrk[r][volty+s]-wrk[r-10][volty+s]);
   
         //
         //
         //
         //
         //
      
         double avgLen = MathMin(MathMax(4.0*length,30),150);

         //
         //
         // comment out the previous line and uncomment the following line
         // if you want completely same results as the jurik filter
         //
         //
         // double avgLen = 65;
         
            if (r<avgLen)
            {
               double avg = wrk[r][vsum+s];  for (k=1; k<avgLen && (r-k)>=0 ; k++) avg += wrk[r-k][vsum+s];
                                                                                   avg /= k;
            }
            else avg = (wrk[r-1][avolty+s]*avgLen-wrk[r-toInt(avgLen)][vsum+s]+wrk[r][vsum+s])/avgLen;
            
         //
         //
         //
         //
         //
                                                           
         wrk[r][avolty+s] = avg;                                           
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
         if (filterMode == 3) 
         wrk[r][2+s] = price;
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   if(filterMode == 1) return(wrk[r][0+s]);
   if(filterMode == 2) return(wrk[r][2+s]);
                       return(wrk[r][4+s]);
}
int toInt(double value) { return(value); }   

double minValue(double& array[],int shift)
{
   double minValue = array[shift];
            for (int i=1; i<STCPeriod; i++) minValue = MathMin(minValue,array[shift+i]);
   return(minValue);
}
double maxValue(double& array[],int shift)
{
   double maxValue = array[shift];
            for (int i=1; i<STCPeriod; i++) maxValue = MathMax(maxValue,array[shift+i]);
   return(maxValue);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
         }
      else {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
         }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}
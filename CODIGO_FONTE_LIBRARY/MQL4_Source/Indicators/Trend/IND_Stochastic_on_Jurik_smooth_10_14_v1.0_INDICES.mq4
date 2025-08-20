//+------------------------------------------------------------------+
//|                                                   Stochastic.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    2
#property indicator_color1     DimGray
#property indicator_width1     1
#property indicator_color2     Blue
#property indicator_style2     STYLE_DOT
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_level1     80
#property indicator_level2     20

//
//
//
//
//

#define MODE_JSM 4

extern int  KPeriod             =  10;
extern int  DPeriod             =  14;
extern int  DPeriodMode         =  MODE_SMA;
extern int  DPeriodPhase        =   0;
extern int  SlowingPeriod       =   3;
extern int  SlowingPeriodPhase  =   0;
extern int  PriceSmoothing      =   6;
extern int  PriceSmoothingPhase =   0;
extern bool CloseClose          = true;

//
//
//
//
//

double MainBuffer[];
double SignalBuffer[];
double HighesBuffer[];
double LowesBuffer[];
double MainBuffera[];
double HiBuffer[];
double LoBuffer[];
double ClBuffer[];


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
   SetIndexBuffer(0, MainBuffer);   SetIndexLabel(0,"%K");
   SetIndexBuffer(1, SignalBuffer); SetIndexLabel(1,"%D");
   SetIndexBuffer(2, HighesBuffer);
   SetIndexBuffer(3, LowesBuffer);
   SetIndexBuffer(4, MainBuffera);
   SetIndexBuffer(5, HiBuffer);
   SetIndexBuffer(6, LoBuffer);
   SetIndexBuffer(7, ClBuffer);

   //
   //
   //
   //
   //
   
   KPeriod  = MathMax(KPeriod,1);
   DPeriod  = MathMax(DPeriod,1);
   
   IndicatorShortName("Stochastic ("+KPeriod+","+DPeriod+","+SlowingPeriod+")");
   return(0);
}
int deinit() { return(0); }



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
         limit = Bars-counted_bars;

   //
   //
   //
   //
   //
   
   for(i = limit; i >= 0 ; i--)
   {
      ClBuffer[i] = iSmooth(Close[i],PriceSmoothing,PriceSmoothingPhase,i, 0);
      if (!CloseClose)
         {
            LoBuffer[i]     = iSmooth(Low[i] ,PriceSmoothing,PriceSmoothingPhase,i,10);
            HiBuffer[i]     = iSmooth(High[i],PriceSmoothing,PriceSmoothingPhase,i,20);
            LowesBuffer[i]  = LoBuffer[ArrayMinimum(LoBuffer,KPeriod,i)];
            HighesBuffer[i] = HiBuffer[ArrayMaximum(HiBuffer,KPeriod,i)]; 
          }
      else
         {
            LowesBuffer[i]  = ClBuffer[ArrayMinimum(ClBuffer,KPeriod,i)];
            HighesBuffer[i] = ClBuffer[ArrayMaximum(ClBuffer,KPeriod,i)];
         }
      
      //
      //
      //
      //
      //

      if (LowesBuffer[i] != HighesBuffer[i])
            MainBuffera[i] = 100.00*(ClBuffer[i]-LowesBuffer[i])/(HighesBuffer[i]-LowesBuffer[i]);
      else  MainBuffera[i] = 50.00;
      MainBuffer[i] = iSmooth(MainBuffera[i],SlowingPeriod,SlowingPeriodPhase,i,30);
      
      //
      //
      //
      //
      //
      
      if (DPeriodMode==MODE_JSM)
            SignalBuffer[i] = iSmooth(MainBuffer[i],DPeriod,DPeriodPhase,i,40);
      else  SignalBuffer[i] = iStochastic(NULL,0,KPeriod,DPeriod,SlowingPeriod,DPeriodMode,CloseClose,MODE_SIGNAL,i);
   }
   
   //
   //
   //
   //
   //
   
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

double wrk[][50];

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
         wrk[r][vsum] =	wrk[r-1][vsum+s] + 0.1*(wrk[r][volty+s]-wrk[r-10][volty+s]);
   
         //
         //
         //
         //
         //
      
         double avgLen = MathMin(MathMax(4.0*length,30),150);
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
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
}
int toInt(double value) { return(value); }   
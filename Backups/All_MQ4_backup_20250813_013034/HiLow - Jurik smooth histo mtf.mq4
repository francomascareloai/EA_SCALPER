//+------------------------------------------------------------------+
//|                                 HiLow channel - Jurik smooth.mq4 |
//|                                                           mladen |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "copyleft mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_minimum 0
#property indicator_maximum 1
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame     = PERIOD_CURRENT;    // Timeframe to use
extern int             SmoothPeriod  = 10;                // Jurik period
extern int             SmoothPhase   = 0;                 // Jurik phase
extern bool            Invert        = false;             // Invert signals
extern int             HistoWidth    = 3;                 // Histogram bars width
extern color           UpHistoColor  = clrLimeGreen;      // Up histogram color
extern color           DnHistoColor  = clrRed;            // Down histogram color

double bard[];
double baru[];
double Hlv[];
double multiplier=1;
string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(3);
   SetIndexBuffer(0,baru); SetIndexStyle(0, DRAW_HISTOGRAM,EMPTY,HistoWidth,UpHistoColor);
   SetIndexBuffer(1,bard); SetIndexStyle(1, DRAW_HISTOGRAM,EMPTY,HistoWidth,DnHistoColor);
   SetIndexBuffer(2,Hlv);
   
      if (Invert)  multiplier = -1;  
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame == -99;
      TimeFrame         = fmax(TimeFrame,_Period);
      
   IndicatorShortName(timeFrameToString(TimeFrame)+" HiLow jurik smooth Histo");
return(0);
}

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
           limit=fmin(Bars-counted_bars,Bars-1);
           if (returnBars) { bard[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
     for(i=limit;i>=0;i--)
     {
        if (i<Bars-1)
        {
          double hiPrice = iSmooth(iMA(NULL,0,1,0,MODE_SMA,PRICE_HIGH,i+1),SmoothPeriod,SmoothPhase,i+1,0);
          double loPrice = iSmooth(iMA(NULL,0,1,0,MODE_SMA,PRICE_LOW,i+1) ,SmoothPeriod,SmoothPhase,i+1,1);
          double clPrice = iSmooth(iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,i), SmoothPeriod,SmoothPhase,i  ,2);

          //
          //
          //
          //
          //

          baru[i] = EMPTY_VALUE;
          bard[i] = EMPTY_VALUE;
          Hlv[i] = (i<Bars-1) ? (clPrice<loPrice) ? 1*multiplier : (clPrice>hiPrice) ? -1*multiplier : Hlv[i+1] : 0;
          if (Hlv[i] == 1) baru[i] = 1;  
          if (Hlv[i] ==-1) bard[i] = 1;  
       }
     }
    return(0);
    }
    
   //
   //
   //
   //
   //
   
   limit = (int)fmax(limit,fmin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for (i=limit;i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         baru[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SmoothPeriod,SmoothPhase,0,UpHistoColor,DnHistoColor,0,y);
         bard[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SmoothPeriod,SmoothPhase,0,UpHistoColor,DnHistoColor,1,y);
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

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length<=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars); 
   
   int r = Bars-i-1; s *= 10;
      if (r==0) { int k=0; for(; k<7; k++) wrk[0][k+s]=price; for(; k<10; k++) wrk[0][k+s]=0; return(price); }

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
               double dVolty = (wrk[r][avolty+s] > 0) ? wrk[r][volty+s]/wrk[r][avolty+s] : 0;   
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


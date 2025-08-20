//+------------------------------------------------------------------+
//|                                              precision trend.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers  2
#property indicator_color1   clrGreen
#property indicator_color2   clrRed
#property indicator_width1   2
#property indicator_width2   2
#property indicator_minimum  0
#property indicator_maximum  1
#property strict

//
//
//
//
//

extern int                rsiPeriod   = 14;          // RSI period
extern ENUM_APPLIED_PRICE rsiPrice    = PRICE_CLOSE; // RSI price
extern int                rsiHighLow  = 5;           // RSI high low period (must be > 1)
extern int                avgPeriod   = 30;          // Average period
extern double             sensitivity = 3;           // Sensitivity

double upBuffer[],dnBuffer[],rsi[];

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
   IndicatorBuffers(3);
   SetIndexBuffer(0,upBuffer); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,dnBuffer); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,rsi); 
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }
int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& btime[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] )
{
   int counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit=MathMin(rates_total-counted_bars,rates_total-1);

   //
   //
   //
   //
   //
            
   for(int i=limit; i>=0 && !_StopFlag; i--)
   {
      upBuffer[i] = EMPTY_VALUE;
      dnBuffer[i] = EMPTY_VALUE;
         rsi[i] = iRSI(NULL,0,rsiPeriod,rsiPrice,i);
         double rhigh = rsi[ArrayMaximum(rsi,rsiHighLow,i)];
         double rlow  = rsi[ArrayMinimum(rsi,rsiHighLow,i)];
         double trend = iPrecisionTrend(rhigh,rlow,rsi[i],avgPeriod,sensitivity,i,rates_total);
            if (trend ==  1) upBuffer[i] = 1;
            if (trend == -1) dnBuffer[i] = 1;
   }
   return(rates_total);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _ptInstances     1
#define _ptInstancesSize 8
double  _ptWork[][_ptInstances*_ptInstancesSize];
#define __range 0
#define __trend 1
#define __avgr  2
#define __avgd  3
#define __avgu  4
#define __minc  5
#define __maxc  6
#define __close 7
double iPrecisionTrend(double _high, double _low, double _close, int _period, double _sensitivity, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(_ptWork,0)!=bars) ArrayResize(_ptWork,bars); instanceNo*=_ptInstancesSize; int r=bars-i-1;
   
   //
   //
   //
   //
   //

   _ptWork[r][instanceNo+__close] = _close;
   _ptWork[r][instanceNo+__range] = _high-_low;
   _ptWork[r][instanceNo+__avgr]  = _ptWork[r][instanceNo+__range];
   int k=1; for (; k<_period && (r-k)>=0; k++) _ptWork[r][instanceNo+__avgr] += _ptWork[r-k][instanceNo+__range];
                                               _ptWork[r][instanceNo+__avgr] /= k;
                                               _ptWork[r][instanceNo+__avgr] *= _sensitivity;

      //
      //
      //
      //
      //
               
      if (r==0)
      {
         _ptWork[r][instanceNo+__trend] = 0;
         _ptWork[r][instanceNo+__avgd] = _close-_ptWork[r][instanceNo+__avgr];
         _ptWork[r][instanceNo+__avgu] = _close+_ptWork[r][instanceNo+__avgr];
         _ptWork[r][instanceNo+__minc] = _close;
         _ptWork[r][instanceNo+__maxc] = _close;
      }
      else
      {
         _ptWork[r][instanceNo+__trend] = _ptWork[r-1][instanceNo+__trend];
         _ptWork[r][instanceNo+__avgd]  = _ptWork[r-1][instanceNo+__avgd];
         _ptWork[r][instanceNo+__avgu]  = _ptWork[r-1][instanceNo+__avgu];
         _ptWork[r][instanceNo+__minc]  = _ptWork[r-1][instanceNo+__minc];
         _ptWork[r][instanceNo+__maxc]  = _ptWork[r-1][instanceNo+__maxc];
         
         //
         //
         //
         //
         //
         
         switch((int)_ptWork[r-1][instanceNo+__trend])
         {
            case 0 :
                  if (_close>_ptWork[r-1][instanceNo+__avgu])
                  {
                     _ptWork[r][instanceNo+__minc]  = _close;
                     _ptWork[r][instanceNo+__avgd]  = _close-_ptWork[r][instanceNo+__avgr];
                     _ptWork[r][instanceNo+__trend] =  1;
                  }
                  if (_close<_ptWork[r-1][instanceNo+__avgd])
                  {
                     _ptWork[r][instanceNo+__maxc]  = _close;
                     _ptWork[r][instanceNo+__avgu]  = _close+_ptWork[r][instanceNo+__avgr];
                     _ptWork[r][instanceNo+__trend] = -1;
                  }
                  break;
           case 1 :
                  _ptWork[r][instanceNo+__avgd] = _ptWork[r-1][instanceNo+__minc] - _ptWork[r][instanceNo+__avgr];
                     if (_close>_ptWork[r-1][instanceNo+__minc]) _ptWork[r][instanceNo+__minc] = _close;
                     if (_close<_ptWork[r-1][instanceNo+__avgd])
                     {
                        _ptWork[r][instanceNo+__maxc] = _close;
                        _ptWork[r][instanceNo+__avgu] = _close+_ptWork[r][instanceNo+__avgr];
                        _ptWork[r][instanceNo+__trend] = -1;
                     }
                  break;                  
            case -1 :
                  _ptWork[r][instanceNo+__avgu] = _ptWork[r-1][instanceNo+__maxc] + _ptWork[r][instanceNo+__avgr];
                     if (_close<_ptWork[r-1][instanceNo+__maxc]) _ptWork[r][instanceNo+__maxc] = _close;
                     if (_close>_ptWork[r-1][instanceNo+__avgu])
                     {
                        _ptWork[r][instanceNo+__minc]  = _close;
                        _ptWork[r][instanceNo+__avgd]  = _close-_ptWork[r][instanceNo+__avgr];
                        _ptWork[r][instanceNo+__trend] = 1;
                     }
         }
      }            
   return(_ptWork[r][instanceNo+__trend]);
}
//------------------------------------------------------------------
#property copyright "Copyright 2016, mladen - MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrOrange
#property indicator_color3 clrOrange
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property strict

extern ENUM_TIMEFRAMES TimeFrame   = PERIOD_CURRENT;  // Time frame
extern int             period      = 10;              // Super trend period
extern double          multiplier  = 4.0;             // Super trend multiplier
extern bool            Interpolate = true;            // Interpolate in multi time frame mode?

double Trend[],TrendDoA[],TrendDoB[],Direction[],Up[],Dn[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,period,multiplier,_buff,_y)

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
   for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   IndicatorBuffers(7);
      SetIndexBuffer(0, Trend);
      SetIndexBuffer(1, TrendDoA);
      SetIndexBuffer(2, TrendDoB);
      SetIndexBuffer(3, Direction);
      SetIndexBuffer(4, Up);
      SetIndexBuffer(5, Dn);
      SetIndexBuffer(6, count); 
            indicatorFileName = WindowExpertName();
            TimeFrame         = fmax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" SuperTrend");
   return(0);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int i,counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         int limit=fmin(rates_total-counted_bars,rates_total-1); count[0] = limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)MathMax(limit,MathMin(rates_total-1,_mtfCall(6,0)*TimeFrame/_Period));
            if (Direction[limit] == -1) CleanPoint(limit,TrendDoA,TrendDoB);
            for (i=limit;i>=0 && !_StopFlag; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                  Trend[i]     = _mtfCall(0,y);
                  Direction[i] = _mtfCall(3,y);
                  Up[i]        = _mtfCall(4,y);
                  Dn[i]        = _mtfCall(5,y);
                  TrendDoA[i]  = EMPTY_VALUE;
                  TrendDoB[i]  = EMPTY_VALUE;
      
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                  int n,k; datetime ttime = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<rates_total && time[i+n] >= ttime; n++) continue;	
                     for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
                     {
                       _interpolate(Trend);  
                       _interpolate(Up);  
                       _interpolate(Dn);     
                     }                     
            }
            for(i=limit; i>=0; i--) if (Direction[i] == -1) PlotPoint(i,TrendDoA,TrendDoB,Trend); 
   return(rates_total);
   }               
         

   //
   //
   //
   //
   //

   if (Direction[limit] == -1) CleanPoint(limit,TrendDoA,TrendDoB);
   for(i = limit; i >= 0; i--)
   {
      double atr    = iATR(NULL,0,period,i);
      double cprice =  close[i];
      double mprice = (high[i]+low[i])/2;
         Up[i]  = mprice+multiplier*atr;
         Dn[i]  = mprice-multiplier*atr;
         
         //
         //
         //
         //
         //
         
         Direction[i] = (i<rates_total-1) ? (cprice > Up[i+1]) ? 1 : (cprice < Dn[i+1]) ? -1 : Direction[i+1] : 0;
         TrendDoA[i]  = EMPTY_VALUE;
         TrendDoB[i]  = EMPTY_VALUE;
            if (Direction[i] ==  1) { Dn[i] = fmax(Dn[i],Dn[i+1]); Trend[i] = Dn[i]; }
            if (Direction[i] == -1) { Up[i] = fmin(Up[i],Up[i+1]); Trend[i] = Up[i]; PlotPoint(i,TrendDoA,TrendDoB,Trend); }
   }
   return(rates_total);
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
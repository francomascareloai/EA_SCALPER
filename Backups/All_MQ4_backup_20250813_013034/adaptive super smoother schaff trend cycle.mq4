//+------------------------------------------------------------------+
//|                                           Schaff Trend Cycle.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_label1  "STC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  2
#property indicator_label2  "STC"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_width2  2
#property indicator_label3  "STC"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_width3  2
#property strict

//
//
//
//
//

input int                STCPeriod       = 10;               // Schaff period
input int                FastMAPeriod    = 23;               // Fast ema period
input int                SlowMAPeriod    = 50;               // Slow ema period
input ENUM_APPLIED_PRICE Price           = PRICE_CLOSE;      // Price to use
input int                AdaptPeriod     = 25;               // Adapt period

double stc[],stcUA[],stcUB[],macd[],fastK[],fastD[],fastKK[],trend[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(8);
      SetIndexBuffer(0,stc,   INDICATOR_DATA); 
      SetIndexBuffer(1,stcUA, INDICATOR_DATA);
      SetIndexBuffer(2,stcUB, INDICATOR_DATA);
      SetIndexBuffer(3,macd,  INDICATOR_CALCULATIONS);
      SetIndexBuffer(4,fastK, INDICATOR_CALCULATIONS);
      SetIndexBuffer(5,fastD, INDICATOR_CALCULATIONS);
      SetIndexBuffer(6,fastKK,INDICATOR_CALCULATIONS);
      SetIndexBuffer(7,trend, INDICATOR_CALCULATIONS);
   IndicatorShortName("Schaff Trend Cycle ("+(string)STCPeriod+","+(string)FastMAPeriod+","+(string)SlowMAPeriod+")");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int counted_bars=prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(rates_total-counted_bars,rates_total-1);

   //
   //
   //
   //
   //
   
   if (trend[limit]==1) CleanPoint(limit,stcUA,stcUB);
   for(int i = limit; i >= 0; i--)
   {
      double price = iMA(NULL,0,1,0,MODE_SMA,Price,i);
      double dev   = iStdDev(NULL,0,AdaptPeriod,0,MODE_SMA,Price,i);
      double avg   = iSma(dev,AdaptPeriod,i,rates_total);
      double coeff = 1;
         if (dev!=0) coeff = avg/dev;
         
      macd[i] =    iSsm(price,coeff*FastMAPeriod,i,rates_total,0)-iSsm(price,coeff*SlowMAPeriod,i,rates_total,1);
   

      double loMacd   = macd[ArrayMinimum(macd,STCPeriod,i)];
      double hiMacd   = macd[ArrayMaximum(macd,STCPeriod,i)]-loMacd;
             fastK[i] = (hiMacd > 0) ? 100*((macd[i]-loMacd)/hiMacd) : (i<rates_total-1) ? fastK[i+1] : 0;
             fastD[i] = (i<rates_total-1) ? fastD[i+1]+0.5*(fastK[i]-fastD[i+1]) : fastK[i];
               
      double loStoch   = fastD[ArrayMinimum(fastD,STCPeriod,i)];
      double hiStoch   = fastD[ArrayMaximum(fastD,STCPeriod,i)]-loStoch;
             fastKK[i] = (hiStoch > 0) ? 100*((fastD[i]-loStoch)/hiStoch) : (i<rates_total-1) ? fastKK[i+1] : 0;
             stc[i]    = (i<rates_total-1) ? stc[i+1]+0.5*(fastKK[i]-stc[i+1]) : fastKK[i];
             stcUA[i]  = EMPTY_VALUE;
             stcUB[i]  = EMPTY_VALUE;
             trend[i]  = (i<rates_total-1) ? (stc[i] > stc[i+1]) ? 1 : (stc[i] < stc[i+1]) ? -1 : trend[i+1] : 0;      
             if (trend[i] == 1) PlotPoint(i,stcUA,stcUB,stc);
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

#define SsmInstances 2
double workSsm[][SsmInstances*2];
#define _tprice  0
#define _ssm     1

double workSsmCoeffs[][SsmInstances*4];
#define _speriod 0
#define _sc1    1
#define _sc2    2
#define _sc3    3

double iSsm(double price, double period, int i, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSsm,0) !=bars)                 ArrayResize(workSsm,bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_speriod] != period)
   {
      workSsmCoeffs[instanceNo][_speriod] = period;
      double a1 = exp(-1.414*M_PI/period);
      double b1 = 2.0*a1*cos(1.414*M_PI/period);
         workSsmCoeffs[instanceNo][_sc2] = b1;
         workSsmCoeffs[instanceNo][_sc3] = -a1*a1;
         workSsmCoeffs[instanceNo][_sc1] = 1.0 - workSsmCoeffs[instanceNo][_sc2] - workSsmCoeffs[instanceNo][_sc3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2; i=bars-i-1;
      workSsm[i][s+_ssm]    = price;
      workSsm[i][s+_tprice] = price;
      if (i>1)
      {  
          workSsm[i][s+_ssm] = workSsmCoeffs[instanceNo][_sc1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0 + 
                               workSsmCoeffs[instanceNo][_sc2]*workSsm[i-1][s+_ssm]                                + 
                               workSsmCoeffs[instanceNo][_sc3]*workSsm[i-2][s+_ssm]; }
   return(workSsm[i][s+_ssm]);
}

//
//
//
//
//

double workSma[][2];
double iSma(double price, int period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= bars) ArrayResize(workSma,bars); instanceNo *= 2; r = bars-r-1;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(int k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= period; }
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

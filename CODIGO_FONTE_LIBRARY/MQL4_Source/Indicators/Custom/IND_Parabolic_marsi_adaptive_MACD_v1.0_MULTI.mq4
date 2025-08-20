//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 10
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrLimeGreen
#property indicator_color3  clrPaleVioletRed
#property indicator_color4  clrPaleVioletRed
#property indicator_color5  clrDimGray  
#property indicator_color6  clrGold
#property indicator_color7  clrBlue
#property indicator_color8  clrRed
#property indicator_color9  clrBlue
#property indicator_color10 clrRed
#property indicator_width1  2
#property indicator_width3  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width9  3
#property indicator_width10 3
#property strict

//
//
//
//
//

enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma,   // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
};

extern int                RsiPeriod1   = 14;           // First rsi period
extern double             Speed1       = 1.2;          // First rsi speed
extern ENUM_APPLIED_PRICE RsiPrice1    = PRICE_CLOSE;  // First rsi price
extern int                RsiPeriod2   = 34;           // Second rsi period
extern double             Speed2       = 0.8;          // Second rsi speed
extern ENUM_APPLIED_PRICE RsiPrice2    = PRICE_CLOSE;  // Second rsi price
extern int                SignalPeriod = 9;            // Signal period
extern enMaTypes          SignalMethod = ma_sma;       // Signal average type
extern double             AccStep      = 0.01;         // Accumulation step
extern double             AccLimit     = 0.1;          // Accumulation limit

double machuu[];
double machud[];
double machdd[];
double machdu[];
double macd[];
double signal[];
double sarUp[];
double sarDn[];
double saraUp[];
double saraDn[];
double slope[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
// 
//
//
//
//

int init()
{
   IndicatorBuffers(11);
   SetIndexBuffer(0, machuu); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1, machud); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2, machdd); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3, machdu); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4, macd); 
   SetIndexBuffer(5, signal); 
   SetIndexBuffer(6, sarUp);  SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,159);
   SetIndexBuffer(7, sarDn);  SetIndexStyle(7,DRAW_ARROW); SetIndexArrow(7,159);
   SetIndexBuffer(8, saraUp); SetIndexStyle(8,DRAW_ARROW); SetIndexArrow(8,159);
   SetIndexBuffer(9, saraDn); SetIndexStyle(9,DRAW_ARROW); SetIndexArrow(9,159);
   SetIndexBuffer(10,slope);
   IndicatorShortName("Parabolic marsi adaptive Macd("+(string)RsiPeriod1+","+DoubleToStr(Speed1,2)+","+(string)RsiPeriod2+","+DoubleToStr(Speed2,2)+")");
   return(0);
}
int start()
{
   int i,limit,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         limit = fmin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--) 
   {
      double sarClose;
      double sarOpen;
      double sarPosition;
      double sarChange;
      double macdHi = iMaRsi((int)High[i],RsiPeriod1,Speed1,i,0) - iMaRsi((int)High[i],RsiPeriod2,Speed2,i,1);
      double macdLo = iMaRsi((int)Low[i], RsiPeriod1,Speed1,i,2) - iMaRsi((int)Low[i], RsiPeriod2,Speed2,i,3);
      double macdMi = (macdHi+macdLo)*0.5;
      macd[i]       = iMaRsi((int)macdMi,RsiPeriod1,Speed1,i,4)-iMaRsi((int)macdMi,RsiPeriod2,Speed2,i,5);
      signal[i]     = iCustomMa(SignalMethod,macd[i],SignalPeriod,i);
      iParabolic(macd[i],macd[i],AccStep,AccLimit,sarClose,sarOpen,sarPosition,sarChange,i);
      
      sarUp[i]  = EMPTY_VALUE;
      sarDn[i]  = EMPTY_VALUE;
      saraUp[i] = EMPTY_VALUE;
      saraDn[i] = EMPTY_VALUE;
      machuu[i] = EMPTY_VALUE;
      machud[i] = EMPTY_VALUE;
      machdd[i] = EMPTY_VALUE;
      machdu[i] = EMPTY_VALUE;
      slope[i] = (i<Bars-1) ? (macd[i]>macd[i+1]) ? 1 : (macd[i]<macd[i+1]) ? -1 : slope[i+1] : 0;
      
      if (macd[i]>0)
      if (slope[i]==1)
            machuu[i] = macd[i];
      else  machud[i] = macd[i];
      if (macd[i]<0)
      if (slope[i]==1)
            machdu[i] = macd[i];
      else  machdd[i] = macd[i];
      
      if (sarPosition==1)
            sarUp[i] = sarClose;
      else  sarDn[i] = sarClose;
      if (sarChange!=0)
         if (sarPosition==1)
               saraUp[i] = sarClose;
         else  saraDn[i] = sarClose;
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

double workMaRsi[][6];
double iMaRsi(int price, int rsiPeriod, double speed, int i, int instanceNo=0)
{
   if (ArrayRange(workMaRsi,0)!=Bars) ArrayResize(workMaRsi,Bars); int r = Bars-i-1;

   //
   //
   //
   //
   //
   
   double tprice = iMA(NULL,0,1,0,MODE_SMA,price,i);
      if (r<rsiPeriod)
            workMaRsi[r][instanceNo] = tprice;
      else  workMaRsi[r][instanceNo] = workMaRsi[r-1][instanceNo]+(speed*fabs(iRSI(NULL,0,rsiPeriod,price,i)/100.0-0.5))*(tprice-workMaRsi[r-1][instanceNo]);
   return(workMaRsi[r][instanceNo]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][7];
#define _high     0
#define _low      1
#define _ohigh    2
#define _olow     3
#define _open     4
#define _position 5
#define _af       6


void iParabolic(double high, double low, double step, double limit, double& pClose, double& pOpen, double& pPosition, double& pChange, int i)
{
   if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars); i = Bars-i-1;
   
   //
   //
   //
   //
   //
   
      pChange = 0;
         work[i][_ohigh]    = high;
         work[i][_olow]     = low;
            if (i<1)
               {
                  work[i][_high]     = high;
                  work[i][_low]      = low;
                  work[i][_open]     = high;
                  work[i][_position] = -1;
                  return;
               }
         work[i][_open]     = work[i-1][_open];
         work[i][_af]       = work[i-1][_af];
         work[i][_position] = work[i-1][_position];
         work[i][_high]     = fmax(work[i-1][_high],high);
         work[i][_low]      = fmin(work[i-1][_low] ,low );
      
   //
   //
   //
   //
   //
            
   if (work[i][_position] == 1)
      if (low<=work[i][_open])
         {
            work[i][_position] = -1;
               pChange = -1;
               pClose  = work[i][_high];
                         work[i][_high] = high;
                         work[i][_low]  = low;
                         work[i][_af]   = step;
                         work[i][_open] = pClose + work[i][_af]*(work[i][_low]-pClose);
                            if (work[i][_open]<work[i  ][_ohigh]) work[i][_open] = work[i  ][_ohigh];
                            if (work[i][_open]<work[i-1][_ohigh]) work[i][_open] = work[i-1][_ohigh];
         }
      else
         {
               pClose = work[i][_open];
                    if (work[i][_high]>work[i-1][_high] && work[i][_af]<limit) work[i][_af] = fmin(work[i][_af]+step,limit);
                        work[i][_open] = pClose + work[i][_af]*(work[i][_high]-pClose);
                            if (work[i][_open]>work[i  ][_olow]) work[i][_open] = work[i  ][_olow];
                            if (work[i][_open]>work[i-1][_olow]) work[i][_open] = work[i-1][_olow];
         }
   else
      if (high>=work[i][_open])
         {
            work[i][_position] = 1;
               pChange = 1;
               pClose  = work[i][_low];
                         work[i][_low]  = low;
                         work[i][_high] = high;
                         work[i][_af]   = step;
                         work[i][_open] = pClose + work[i][_af]*(work[i][_high]-pClose);
                            if (work[i][_open]>work[i  ][_olow]) work[i][_open] = work[i  ][_olow];
                            if (work[i][_open]>work[i-1][_olow]) work[i][_open] = work[i-1][_olow];
         }
      else
         {
               pClose = work[i][_open];
               if (work[i][_low]<work[i-1][_low] && work[i][_af]<limit) work[i][_af] = fmin(work[i][_af]+step,limit);
                   work[i][_open] = pClose + work[i][_af]*(work[i][_low]-pClose);
                            if (work[i][_open]<work[i  ][_ohigh]) work[i][_open] = work[i  ][_ohigh];
                            if (work[i][_open]<work[i-1][_ohigh]) work[i][_open] = work[i-1][_ohigh];
         }

   //
   //
   //
   //
   //
   
   pOpen     = work[i][_open];
   pPosition = work[i][_position];
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int instanceNo=0)
{
   int bars = Bars; r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workTema,0)!= bars) ArrayResize(workTema,bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
   {
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}


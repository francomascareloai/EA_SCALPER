//+------------------------------------------------------------------+
//|                                                        rsx on oma|
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_minimum -2
#property indicator_maximum 2
#property indicator_buffers 4
#property indicator_color2 Aqua
#property indicator_color3 Crimson
#property indicator_width2 3
#property indicator_width3 3
#property indicator_level1 0
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor Magenta


//
//
//
//
//

extern int    RsxLength   = 14;
extern int    Price       = 0;
extern int    uptrendlevel= 51;
extern int    dntrendlevel= 49;
extern int    uptradelevel= 25;
extern int    dntradelevel= 75;
extern int    OmaLength   = 5;
extern double OmaSpeed    = 8.0;
extern bool   OmaAdaptive = true;

//
//
//
//
//

double rsx[];
double UpBuffer[];
double DnBuffer[];
double TrBuffer[];
double wrkBuffer[][13];
double stored[][7];

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
   SetIndexBuffer(0,rsx);      SetIndexStyle(0,DRAW_NONE,NULL);
   SetIndexBuffer(1,UpBuffer); SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"UpTrend");
   SetIndexBuffer(2,DnBuffer); SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexLabel(2,"DownTrend");
   SetIndexBuffer(3,TrBuffer); SetIndexStyle(3,DRAW_NONE,NULL);

   IndicatorShortName("rsx on oma filter("+RsxLength+")");
   SetIndexDrawBegin(1,RsxLength);
   SetIndexDrawBegin(2,RsxLength);
      OmaLength = MathMax(OmaLength,   1);
      OmaSpeed  = MathMax(OmaSpeed ,-1.5);
      IndicatorShortName("rsx on oma filter ("+RsxLength+","+OmaLength+","+DoubleToStr(OmaSpeed,2)+")");
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
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         if (ArrayRange(wrkBuffer,0) != Bars) { ArrayResize(wrkBuffer,Bars); ArrayResize(stored,Bars); }

   //
   //
   //
   //
   //
   
   double Kg = (3.0)/(2.0+RsxLength);
   double Hg = 1.0-Kg;
   for(i=limit, r=Bars-i-1; i>=0; i--, r++)
   {
      wrkBuffer[r][12] = iAverage(iMA(NULL,0,1,0,MODE_SMA,Price,i),OmaLength,OmaSpeed,OmaAdaptive,r);

         if (i==(Bars-1)) { for (int c=0; c<12; c++) wrkBuffer[r][c] = 0; continue; }  

      //
      //
      //
      //
      //
      
      double roc = wrkBuffer[r][12]-wrkBuffer[r-1][12];
      double roa = MathAbs(roc);
      for (int k=0; k<3; k++)
      {
         int kk = k*2;
            wrkBuffer[r][kk+0] = Kg*roc                + Hg*wrkBuffer[r-1][kk+0];
            wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; roc = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
            wrkBuffer[r][kk+6] = Kg*roa                + Hg*wrkBuffer[r-1][kk+6];
            wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; roa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
      }
      if (roa != 0)
           rsx[i] = MathMax(MathMin((roc/roa+1.0)*50.0,100.00),0.00); 
      else rsx[i] = 50.0;
      
      TrBuffer[i] = TrBuffer[i+1];
      DnBuffer[i] = EMPTY_VALUE;
      UpBuffer[i] = EMPTY_VALUE;
      
      if (rsx[i] > uptrendlevel) TrBuffer[i] =  1; 
      if (rsx[i] < dntrendlevel) TrBuffer[i] = -1;
	  
      if (TrBuffer[i]>0 && rsx[i] > uptradelevel) UpBuffer[i] =  1.0;
      if (TrBuffer[i]<0 && rsx[i] < dntradelevel) DnBuffer[i] = -1.0;
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

#define E1  0
#define E2  1
#define E3  2
#define E4  3
#define E5  4
#define E6  5
#define res 6

//
//
//
//
//

double iAverage(double price, double averagePeriod, double const, bool adaptive, int r, int ashift=0)
{
   double e1=stored[r-1][E1+ashift];  double e2=stored[r-1][E2+ashift];
   double e3=stored[r-1][E3+ashift];  double e4=stored[r-1][E4+ashift];
   double e5=stored[r-1][E5+ashift];  double e6=stored[r-1][E6+ashift];

   //
   //
   //
   //
   //

      if (adaptive && (averagePeriod > 1))
      {
         double minPeriod = averagePeriod/2.0;
         double maxPeriod = minPeriod*5.0;
         int    endPeriod = MathCeil(maxPeriod);
         double signal    = MathAbs((price-stored[r-endPeriod][res]));
         double noise     = 0.00000000001;

            for(int k=1; k<endPeriod; k++) noise=noise+MathAbs(price-stored[r-k][res]);

         averagePeriod = ((signal/noise)*(maxPeriod-minPeriod))+minPeriod;
      }
      
      //
      //
      //
      //
      //
      
      double alpha = (2.0+const)/(1.0+const+averagePeriod);

      e1 = e1 + alpha*(price-e1); e2 = e2 + alpha*(e1-e2); double v1 = 1.5 * e1 - 0.5 * e2;
      e3 = e3 + alpha*(v1   -e3); e4 = e4 + alpha*(e3-e4); double v2 = 1.5 * e3 - 0.5 * e4;
      e5 = e5 + alpha*(v2   -e5); e6 = e6 + alpha*(e5-e6); double v3 = 1.5 * e5 - 0.5 * e6;

   //
   //
   //
   //
   //

   stored[r][E1+ashift]  = e1;  stored[r][E2+ashift] = e2;
   stored[r][E3+ashift]  = e3;  stored[r][E4+ashift] = e4;
   stored[r][E5+ashift]  = e5;  stored[r][E6+ashift] = e6;
   stored[r][res+ashift] = price;
   return(v3);
}
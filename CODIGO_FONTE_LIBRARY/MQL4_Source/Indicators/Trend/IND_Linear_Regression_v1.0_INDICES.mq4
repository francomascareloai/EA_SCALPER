//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  DimGray
#property indicator_color2  DimGray
#property indicator_color3  DimGray
#property indicator_color4  DimGray
#property indicator_color5  PaleVioletRed
#property indicator_color6  DeepSkyBlue
#property indicator_color7  DeepSkyBlue
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT

//
//
//
//
//

extern int    Length             = 30;
extern int    Price              = PRICE_CLOSE;
extern int    ProjectionLength   = 50;
extern bool   ShowLrLine         = true;
extern bool   ShowLrChannel      = true;
extern double ChannelMultiplier  = 1.0;
extern bool   ShowHighLowChannel = false;
extern bool   MultiColor         = true;
extern bool   ColorOnLrLine      = true;

double lr[];
double lrUa[];
double lrUb[];
double lrLine[];
double lrChu[];
double lrChd[];
double lrProj[];
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
   int drawStyle1 = DRAW_NONE; if (ShowLrLine)    drawStyle1 = DRAW_LINE;
   int drawStyle2 = DRAW_NONE; if (MultiColor)    drawStyle2 = DRAW_LINE;
   int drawStyle3 = DRAW_NONE; if (ShowLrChannel) drawStyle3 = DRAW_LINE;

      //
      //
      //
      //
      //
      
      ProjectionLength = MathMax(ProjectionLength,0);
      IndicatorBuffers(8);
         SetIndexBuffer(0,lrLine); SetIndexStyle(0,drawStyle1);
         SetIndexBuffer(1,lrProj); SetIndexShift(1,ProjectionLength);
         SetIndexBuffer(2,lrChu);  SetIndexShift(2,ProjectionLength);
         SetIndexBuffer(3,lrChd);  SetIndexShift(3,ProjectionLength);
         SetIndexBuffer(4,lr);
         SetIndexBuffer(5,lrUa); SetIndexStyle(3,drawStyle2);
         SetIndexBuffer(6,lrUb); SetIndexStyle(4,drawStyle2);
         SetIndexBuffer(7,slope);
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

int start()
{
   int k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

      //
      //
      //
      //
      //

      if (slope[limit]==1) CleanPoint(limit,lrUa,lrUb);
      for(int i=limit; i>=0; i--)
      {
         double tslope,error;
            lr[i]    = iLrValue(iMA(NULL,0,1,0,MODE_SMA,Price,i),Length,tslope,error,i);
            lrUa[i]  = EMPTY_VALUE;
            lrUb[i]  = EMPTY_VALUE;
            slope[i] = slope[i+1];

            if (ColorOnLrLine)
                  { if (tslope>0)      slope[i] = 1; if (tslope<0)      slope[i] = -1; }
            else  { if (lr[i]>lr[i+1]) slope[i] = 1; if (lr[i]<lr[i+1]) slope[i] = -1; }
            if (slope[i]==1) PlotPoint(i,lrUa,lrUb,lr);
               
            //
            //
            //
            //
            //
               
            if (i==0)
            {
               for (k=0; k<Length; k++) lrLine[k] = lr[0]-tslope*k;
               for (k=-Length; k<=ProjectionLength; k++) 
               {
                     lrProj[ProjectionLength-k] = lr[0]+tslope*k;
                     lrChu[ProjectionLength-k]  = lrProj[ProjectionLength-k]+ChannelMultiplier*error;
                     lrChd[ProjectionLength-k]  = lrProj[ProjectionLength-k]-ChannelMultiplier*error;
               }                     
            }
      }
      
      //
      //
      //
      //
      //
      
      SetIndexDrawBegin(0,Bars-Length);
      SetIndexDrawBegin(1,Bars-ProjectionLength-1);
      SetIndexDrawBegin(2,Bars-ProjectionLength-Length);
      SetIndexDrawBegin(3,Bars-ProjectionLength-Length);
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

double workLr[];
double iLrValue(double value, int period, double& lrslope, double& error, int r)
{
   if (ArraySize(workLr)!=Bars) ArrayResize(workLr,Bars); r = Bars-r-1; workLr[r] = value;
   if (r<period || period<2) return(value);

   //
   //
   //
   //
   //

      double sumx=0, sumxx=0, sumxy=0, sumy=0, sumyy=0;
         for (int k=0; k<period; k++)
         {
            double price = workLr[r-k];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
                   sumyy +=   price*price;
         }
         lrslope = (period*sumxy-sumx*sumy)/(sumx*sumx-period*sumxx);
         error   = MathSqrt((period*sumyy-sumy*sumy-lrslope*lrslope*(period*sumxx-sumx*sumx))/(period*(period-2)));

   //
   //
   //
   //
   //
         
   return((sumy + lrslope*sumx)/period);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i] != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE)) second[i+1] = EMPTY_VALUE;
   else if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE)) first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i]; second[i]   = EMPTY_VALUE; }
}
//+------------------------------------------------------------------+
//|                                                         DCE.mq4  |
//|                                               PriceMasterPro.Com |
//|                                    http://www.pricemasterpro.com |
//+------------------------------------------------------------------+
#property copyright "2011(c) - PriceMasterPro.Com"
#property link      "http://www.pricemasterpro.com/"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  PaleVioletRed
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3

extern int Period1 = 44;
extern int Period2 = 22;
extern int Period3 = 66;
extern int Period4 = 33;
extern int Period5 = 29;
extern int Period6 = 14;
extern int Price   = PRICE_CLOSE;
extern color textColor = White;
extern string CommentID = "CycleExplorer";

double Map[];
double MapDa[];
double MapDb[];
double prices[];
double slope[];

int    maxPeriod;
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
   IndicatorBuffers(5);
   SetIndexBuffer(0,Map);
   SetIndexBuffer(1,MapDa);
   SetIndexBuffer(2,MapDb);
   SetIndexBuffer(3,prices);
   SetIndexBuffer(4,slope);
   SetIndexStyle (0,DRAW_LINE);
   SetIndexStyle (1,DRAW_LINE);
   SetIndexStyle (2,DRAW_LINE);
   
   IndicatorShortName("DCE"+Period1+","+Period2);
      maxPeriod = MathMax(Period1,Period2);
      maxPeriod = MathMax(Period3,maxPeriod);
      maxPeriod = MathMax(Period4,maxPeriod);
      maxPeriod = MathMax(Period5,maxPeriod);
      maxPeriod = MathMax(Period6,maxPeriod);
   return(0);
}

int deinit()
{
   ObjectDelete(CommentID);
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
   int i,counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(MathMax(Bars-counted_bars,maxPeriod),Bars-1);
         
   //
   //
   //
   //
   //
    
   if (slope[limit]== 1) CleanPoint(limit,MapDa,MapDb);
   for (i=limit; i>=0; i--) prices[i] = iMA(NULL,0,1,0,MODE_SMA,Price,i);
   for (i=limit; i>=0; i--)
   {
      Map[i]   = icTma(Period2,i)-icTma(Period1,i)+icTma(Period4,i)-icTma(Period3,i)+icTma(Period6,i)-icTma(Period5,i);
      MapDa[i] = EMPTY_VALUE;
      MapDb[i] = EMPTY_VALUE;
      slope[i] = slope[i+1];
         
         if (Map[i]>Map[i+1]) slope[i] = 1;
         if (Map[i]<Map[i+1]) slope[i] =-1;
         if (slope[i]==-1) PlotPoint(i,MapDa,MapDb,Map);
   }   
   
   //
   //
   //
   //
   //
   
   for (i=0; i<Bars-1; i++) if (slope[i]!=slope[i+1]) break; SetComment("Slope changed : "+(i+1)+" bars ago",textColor);
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

double icTma(int period, int i)
{
   int j,k;
   double sum  = (period+1)*prices[i];
   double sumw = (period+1);

      //
      //
      //
      //
      //
      
      for(j=1, k=period; j<period; j++,k--)
      {
         sum  += prices[i+j]*k;
         sumw += k;
         if (j<=i)
         {
               sum  += prices[i-j]*k;
               sumw += k;
         }
      }
   return(sum/sumw);
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

void SetComment(string value,color clr)
{
   string name = CommentID;
      ObjectCreate(name,OBJ_LABEL,0,0,0);
         ObjectSet(name,OBJPROP_CORNER,3);
         ObjectSet(name,OBJPROP_COLOR,clr);
         ObjectSet(name,OBJPROP_XDISTANCE,15);
         ObjectSet(name,OBJPROP_YDISTANCE,15);
         ObjectSetText(name,value,12,"Arial bold");
         
}


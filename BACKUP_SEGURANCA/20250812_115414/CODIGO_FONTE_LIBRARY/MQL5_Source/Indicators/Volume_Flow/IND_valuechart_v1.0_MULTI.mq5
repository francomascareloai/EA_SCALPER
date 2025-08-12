//+------------------------------------------------------------------+
//|                                                  value chart.mq5 |
//|                                                                  |
//| Helweg/Stendahl value charts                                     |
//+------------------------------------------------------------------+

#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers   12
#property indicator_plots     5

//
//
//
//
//

#property indicator_label1  "price"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Lime
#property indicator_width1  1
#property indicator_label2  "upper zone"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'41,42,43'
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label3  "upper zone"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  C'41,42,43'
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
#property indicator_label4  "High;Low;Open;Close"
#property indicator_type4   DRAW_BARS
#property indicator_color4  DimGray
#property indicator_width4  0
#property indicator_label5  "Open;Close"
#property indicator_type5   DRAW_COLOR_HISTOGRAM2
#property indicator_color5  Green,Red,DimGray
#property indicator_width5  1

//
//
//
//
//

enum chartTypes
{
   chtBars,  // bars
   chtLine   // line
};

input int                inpBars      = 10;          // Number of bars
input chartTypes         inpChartType = chtBars;     // Show chart as :
input string             _1           = "";          // Only valied when chart type == line
input ENUM_APPLIED_PRICE inpLinePrice = PRICE_CLOSE; // Price for line chart type

//
//
//
//
//

double vcboBuffer[];
double vcbhBuffer[];
double vcblBuffer[];
double vcbcBuffer[];
double vchoBuffer[];
double vchcBuffer[];
double colsBuffer[];
double prcsBuffer[];
double fluaBuffer[];
double flubBuffer[];
double fldaBuffer[];
double fldbBuffer[];
int    nVarP;
int    nBars;

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
   SetIndexBuffer( 0,prcsBuffer,INDICATOR_DATA);        ArraySetAsSeries(prcsBuffer,true);
   SetIndexBuffer( 1,fluaBuffer,INDICATOR_DATA);        ArraySetAsSeries(fluaBuffer,true);
   SetIndexBuffer( 2,flubBuffer,INDICATOR_DATA);        ArraySetAsSeries(flubBuffer,true);
   SetIndexBuffer( 3,fldaBuffer,INDICATOR_DATA);        ArraySetAsSeries(fldaBuffer,true);
   SetIndexBuffer( 4,fldbBuffer,INDICATOR_DATA);        ArraySetAsSeries(fldbBuffer,true);
   SetIndexBuffer( 5,vcboBuffer,INDICATOR_DATA);        ArraySetAsSeries(vcboBuffer,true);
   SetIndexBuffer( 6,vcbhBuffer,INDICATOR_DATA);        ArraySetAsSeries(vcbhBuffer,true);
   SetIndexBuffer( 7,vcblBuffer,INDICATOR_DATA);        ArraySetAsSeries(vcblBuffer,true);
   SetIndexBuffer( 8,vcbcBuffer,INDICATOR_DATA);        ArraySetAsSeries(vcbcBuffer,true);
   SetIndexBuffer( 9,vchoBuffer,INDICATOR_DATA);        ArraySetAsSeries(vchoBuffer,true);
   SetIndexBuffer(10,vchcBuffer,INDICATOR_DATA);        ArraySetAsSeries(vchcBuffer,true);
   SetIndexBuffer(11,colsBuffer,INDICATOR_COLOR_INDEX); ArraySetAsSeries(colsBuffer,true);

   string PriceType = "";

      if (inpChartType == chtLine)
      {
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
         PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);
         PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
         switch(inpLinePrice)
         {
            case PRICE_CLOSE:    PriceType = ",Close";    break;  // 0
            case PRICE_OPEN:     PriceType = ",Open";     break;  // 1
            case PRICE_HIGH:     PriceType = ",High";     break;  // 2
            case PRICE_LOW:      PriceType = ",Low";      break;  // 3
            case PRICE_MEDIAN:   PriceType = ",Median";   break;  // 4
            case PRICE_TYPICAL:  PriceType = ",Typical";  break;  // 5
            case PRICE_WEIGHTED: PriceType = ",Weighted"; break;  // 6
         }      
      }
   else
      {
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
         PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_BARS);
         PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_COLOR_HISTOGRAM2);
      }

   
   
   //
   //
   //
   //
   //
   
   nBars = inpBars>7 ? inpBars : 8;
   nVarP = (int)MathRound(nBars/5.0);
      IndicatorSetString(INDICATOR_SHORTNAME,"Value chart ("+(string)inpBars+PriceType+")");
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

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{

   //
   //
   //
   //
   //

      int limit = rates_total-prev_calculated;
         if (prev_calculated > 0) limit++;
         if (prev_calculated ==0)
         {
            int last = (inpBars>5) ? inpBars : 5;
            limit -= last;
         }


         if (!ArrayGetAsSeries(high))  ArraySetAsSeries(high ,true);
         if (!ArrayGetAsSeries(low))   ArraySetAsSeries(low  ,true);
         if (!ArrayGetAsSeries(open))  ArraySetAsSeries(open ,true);
         if (!ArrayGetAsSeries(close)) ArraySetAsSeries(close,true);
               int highSize  = ArraySize(high);
               int lowSize   = ArraySize(low);
               int openSize  = ArraySize(open);
               int closeSize = ArraySize(close);

      //
      //
      //
      //
      //

      double nVar0,nVarA,nVarB,nVarC,nVarD,nVarE;
      double nVarR1,nVarR2,nVarR3,nVarR4,nVarR5;
      double nLRange;
         for (int i=limit; i>=0; i--)
         {
         
            //
            //
            //
            //
            //
            
            nVarA = iHighest(high,highSize,nVarP,i)-iLowest(low,lowSize,nVarP,i);
                        if  (nVarA == 0 && nVarP == 1)
                             nVarR1 = MathAbs(close[i]-close[i+nVarP]);
                        else nVarR1 = nVarA;                      
                     
            nVarB = iHighest(high,highSize,nVarP,i+nVarP)-iLowest(low,lowSize,nVarP,i+nVarP);
                        if (nVarB == 0 && nVarP == 1)
                             nVarR2 = MathAbs(close[i+nVarP]-close[i+nVarP*2]);
                        else nVarR2 = nVarB;

            nVarC = iHighest(high,highSize,nVarP,i+nVarP*2)-iLowest(low,lowSize,nVarP,i+nVarP*2);
                        if (nVarC == 0 && nVarP == 1)
                             nVarR3 = MathAbs(close[i+nVarP*2]-close[i+nVarP*3]);
                        else nVarR3 = nVarC;

            nVarD = iHighest(high,highSize,nVarP,i+nVarP*3)-iLowest(low,lowSize,nVarP,i+nVarP*3);
                        if (nVarD == 0 && nVarP == 1)
                             nVarR4 = MathAbs(close[i+nVarP*3]-close[i+nVarP*4]);
                        else nVarR4 = nVarD;

            nVarE = iHighest(high,highSize,nVarP,i+nVarP*4)-iLowest(low,lowSize,nVarP,i+nVarP*4);
                        if (nVarE == 0 && nVarP == 1)
                             nVarR5 = MathAbs(close[i+nVarP*4]-close[i+nVarP*5]);
                        else nVarR5 = nVarE;

            nLRange = ((nVarR1+nVarR2+nVarR3+nVarR4+nVarR5)/5.0)*0.2;
   	         
            //
            //
            //
            //
            //
               	         
	         if ( nLRange <= 0 ) continue;
            double hlAverage = 0;
               for (int k=0;(i+k)<highSize && k<nBars; k++) hlAverage += (high[i+k]+low[i+k])/2.0;
                                                            hlAverage /= nBars;
            
            double nOpen  = (open[i]  - hlAverage) / nLRange;
	         double nHigh  = (high[i]  - hlAverage) / nLRange;
	         double nLow   = (low[i]   - hlAverage) / nLRange;
	         double nClose = (close[i] - hlAverage) / nLRange;	

                  vcbhBuffer[i] = nHigh;
                  vcblBuffer[i] = nLow;
                  vcboBuffer[i] = nOpen;
                  vcbcBuffer[i] = nClose;
                  vchoBuffer[i] = nOpen;
                  vchcBuffer[i] = nClose;
            if (nOpen <nClose) colsBuffer[i] = 0;
            if (nOpen >nClose) colsBuffer[i] = 1;
            if (nOpen==nClose) colsBuffer[i] = 2;
            
               fluaBuffer[i] =  8;
               flubBuffer[i] =  4;
               fldaBuffer[i] = -4;
               fldbBuffer[i] = -8;
      
         //
         //
         //
         //
         //
         
         if (inpChartType==chtLine)
         {
            double price = 0;
            switch (inpLinePrice)
            {
               case PRICE_CLOSE    : price = nClose; break;
               case PRICE_OPEN     : price = nOpen;  break;
               case PRICE_HIGH     : price = nHigh;  break;
               case PRICE_LOW      : price = nLow;   break;
               case PRICE_MEDIAN   : price = (nHigh+nLow)/2.0; break;
               case PRICE_TYPICAL  : price = (nHigh+nLow+nClose)/3.0; break;
               case PRICE_WEIGHTED : price = (nHigh+nLow+nClose+nClose)/4.0; break;
            }               
            prcsBuffer[i] = price;
         }            
   }
   
   //
   //
   //
   //
   //
   
   return(rates_total);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double iHighest(const double& array[], int size, int period, int i)
{
   if (i>=size) return(0);
   double max  = array[i];
         for (int k=1;(i+k)<size && k<period; k++) if (max<array[i+k]) max = array[i+k];
   return(max);
}
double iLowest(const double& array[],int size, int period, int i)
{
   if (i>=size) return(0);
   double min  = array[i];
         for (int k=1;(i+k)<size && k<period; k++) if (min>array[i+k]) min = array[i+k];
   return(min);
}
//+------------------------------------------------------------------+
//|                                         DoubleStochastic RSI.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "ww.forex-station.com"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrSilver
#property indicator_color2  clrSilver
#property indicator_color3  clrSilver
#property indicator_style2  STYLE_DOT
#property indicator_minimum  -1
#property indicator_maximum 101
#property strict

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_highlow,    // High/low
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_hahighlow   // Heiken ashi high/low
};

enum enRsiTypes
{
   rsi_rsi,  // Regular RSI
   rsi_wil,  // Slow RSI
   rsi_rap,  // Rapid RSI
   rsi_har,  // Harris RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
};
enum enColorOn
{
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
};

extern int        RSIPeriod   = 14;             // RSI period
extern enRsiTypes RsiMethod   = rsi_rsx;        // Rsi type
extern enPrices   Price       = pr_close;       // RSI applied to price
extern int        StoPeriod1  = 55;             // Stochastic period 1 (less than 2 - no stochastic)
extern int        StoPeriod2  = 55;             // Stochastic period 2 (less than 2 - no stochastic)
extern int        EMAPeriod   = 15;             // Smoothing period (less than 2 - no smoothing)
extern int        flLookBack  = 25;             // Floating levels look back period
extern double     flLevelUp   = 90;             // Floating levels up level %
extern double     flLevelDown = 10;             // Floating levels down level %
extern enColorOn  ColorOn     = cc_onLevels;    // Color change on :
extern color      ColorNu     = clrDodgerBlue;  // Color for nuetral
extern color      ColorUp     = clrDodgerBlue;  // Color for up
extern color      ColorDown   = clrSandyBrown;  // Color for down
extern int        LineWidth   = 3;              // Main line width


//
//
//
//
//

double RsiBuffer[],Stoch[],StcBuffer[],levup[],levmi[],levdn[],valUa[],valUb[],valDa[],valDb[],trend[];

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
   SetIndexBuffer(0,levup);
   SetIndexBuffer(1,levmi);
   SetIndexBuffer(2,levdn);
   SetIndexBuffer(3,Stoch);   SetIndexStyle(3,EMPTY,EMPTY,LineWidth,ColorNu);
   SetIndexBuffer(4,valUa);   SetIndexStyle(4,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(5,valUb);   SetIndexStyle(5,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(6,valDa);   SetIndexStyle(6,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(7,valDb);   SetIndexStyle(7,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(8,RsiBuffer);
   SetIndexBuffer(9,StcBuffer);
   SetIndexBuffer(10,trend); 

      string strSmooth = (EMAPeriod>1) ? "smoothed " : "";
      string strStoch  = (StoPeriod1>1 || StoPeriod2>1) ? "stochastic " : "";
             strStoch  = (StoPeriod1>1 && StoPeriod2>1) ? "double stochastic " : strStoch;
   IndicatorShortName(strSmooth+strStoch+""+getRsiName((int)RsiMethod)+"("+(string)RSIPeriod+","+(string)StoPeriod1+","+(string)StoPeriod2+","+(string)EMAPeriod+")");
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

int start()
{
   int counted_bars=IndicatorCounted();
   int i,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = fmin(Bars-counted_bars,Bars-1);
   //
   //
   //
   //
   //
   
   if (trend[limit]== 1) CleanPoint(limit,valUa,valUb);
   if (trend[limit]==-1) CleanPoint(limit,valDa,valDb); 
   double alpha = 2.0/(1.0+EMAPeriod);
   for (i=limit; i >= 0; i--)
   {
      RsiBuffer[i] = iRsi(RsiMethod,getPrice(Price,Open,Close,High,Low,i),RSIPeriod,i);
            double max = RsiBuffer[i]; for(k=0; k<StoPeriod1 && (i+k)<Bars; k++) max = MathMax(max,RsiBuffer[i+k]);
            double min = RsiBuffer[i]; for(k=0; k<StoPeriod1 && (i+k)<Bars; k++) min = MathMin(min,RsiBuffer[i+k]);
                         StcBuffer[i] = (max!=min) ? (RsiBuffer[i]-min)/(max-min)*100.00 : RsiBuffer[i];
         
            //
            //
            //
            //
            //
            
            max = StcBuffer[i]; for(k=0; k<StoPeriod2 && (i+k)<Bars; k++) max = MathMax(max,StcBuffer[i+k]);
            min = StcBuffer[i]; for(k=0; k<StoPeriod2 && (i+k)<Bars; k++) min = MathMin(min,StcBuffer[i+k]);
            double sto = (max!=min) ? (StcBuffer[i]-min)/(max-min)*100.00 : StcBuffer[i] ;
            Stoch[i] = (i<Bars-1) ? Stoch[i+1]+alpha*(sto-Stoch[i+1]) : sto;
                   min  = Stoch[ArrayMinimum(Stoch,flLookBack,i)];
                   max  = Stoch[ArrayMaximum(Stoch,flLookBack,i)];
                   double range = max-min;
                   levdn[i] = min+range*flLevelDown/100.0;
                   levup[i] = min+range*flLevelUp/100.0;
                   levmi[i] = min+range*0.5;
                   valDa[i] = EMPTY_VALUE;
                   valDb[i] = EMPTY_VALUE;
                   valUa[i] = EMPTY_VALUE;
                   valUb[i] = EMPTY_VALUE;
         
                   //
                   //
                   //
                   //
                   //
            
                   switch(ColorOn)
                   {
                      case cc_onLevels:         trend[i] = (Stoch[i]>levup[i])   ? 1 : (Stoch[i]<levdn[i])   ? -1 : 0; break;
                      case cc_onMiddle:         trend[i] = (Stoch[i]>levmi[i])   ? 1 : (Stoch[i]<levmi[i])   ? -1 : 0; break;
                      default :  if (i<Bars-1)  trend[i] = (Stoch[i]>Stoch[i+1]) ? 1 : (Stoch[i]<Stoch[i+1]) ? -1 : trend[i+1];
                   }                  
                   if (trend[i] ==  1) PlotPoint(i,valUa,valUb,Stoch); 
                   if (trend[i] == -1) PlotPoint(i,valDa,valDb,Stoch); 
   }
   return(i);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//
//

string rsiMethodNames[] = {"RSI","Slow RSI","Rapid RSI","Harris RSI","RSX","Cuttler RSI"};
string getRsiName(int method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=fmax(fmin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

#define rsiInstances 1
double workRsi[][rsiInstances*13];
#define _price  0
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1

double iRsi(int rsiMode, double price, double period, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*13; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case rsi_rsi:
         {
         double alpha = 1.0/fmax(period,1); 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += fabs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/fmax(k,1);
                  workRsi[r][z+_changa] =                                         sum/fmax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(     change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(fabs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
         }
         
      //
      //
      //
      //
      //
      
      case rsi_wil :
         {         
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if (r<1)
                  workRsi[r][z+_rsival] = 50;
            else               
               if(up + dn == 0)
                     workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/fmax(period,1))*(50            -workRsi[r-1][z+_rsival]);
               else  workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/fmax(period,1))*(100*up/(up+dn)-workRsi[r-1][z+_rsival]);
            return(workRsi[r][z+_rsival]);      
         }
      
      //
      //
      //
      //
      //

      case rsi_rap :
         {
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if(up + dn == 0)
                  return(50);
            else  return(100 * up / (up + dn));      
         }            

      //
      //
      //
      //
      //

      
      case rsi_har :
         {
            double avgUp=0,avgDn=0; double up=0; double dn=0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][instanceNo+_price]- workRsi[r-k-1][instanceNo+_price];
               if(diff>0)
                     { avgUp += diff; up++; }
               else  { avgDn -= diff; dn++; }
            }
            if (up!=0) avgUp /= up;
            if (dn!=0) avgDn /= dn;
            double rs = 1;
               if (avgDn!=0) rs = avgUp/avgDn;
               return(100-100/(1.0+rs));
         }               

      //
      //
      //
      //
      //
      
      case rsi_rsx :  
         {   
            double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
            if (r<period) { for (int k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

            //
            //
            //
            //
            //
      
            double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
            double moa = fabs(mom);
            for (int k=0; k<3; k++)
            {
               int kk = k*2;
               workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
               workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
               workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
               workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
            }
            if (moa != 0)
                 return(fmax(fmin((mom/moa+1.0)*50.0,100.00),0.00)); 
            else return(50);
         }            
            
      //
      //
      //
      //
      //
      
      case rsi_cut :
         {
            double sump = 0;
            double sumn = 0;
            for (int k=0; k<(int)period && r-k-1>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
                  if (diff > 0) sump += diff;
                  if (diff < 0) sumn -= diff;
            }
            if (sumn > 0)
                  return(100.0-100.0/(1.0+sump/sumn));
            else  return(50);
         }            
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
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = fmax(high[i],fmax(haOpen,haClose));
         double haLow   = fmin(low[i] ,fmin(haOpen,haClose));

         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
return(0);
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
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}


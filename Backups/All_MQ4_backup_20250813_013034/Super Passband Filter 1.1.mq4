//------------------------------------------------------------------
#property copyright   "www.forex-tsd.com"
#property link        "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrSilver
#property indicator_color2  clrSilver
#property indicator_color3  clrSilver
#property indicator_color4  clrGainsboro
#property indicator_style2  STYLE_DOT
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
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enColorOn
{
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
};

extern ENUM_TIMEFRAMES TimeFrame     = PERIOD_CURRENT;    // Time frame
extern string          ForSymbol     = "";                // For symbol (leave empty for current chart symbol)
extern double          Period1       = 40;                // Period 1
extern double          Period2       = 60;                // Period 2
extern int             RmsCount      = 50;                // Calculation count
extern enPrices        Price         = pr_close;          // Price to use
extern enColorOn       ColorOn       = cc_onLevels;       // Color change :
extern color           ColorUp       = clrDeepSkyBlue;    // Color for up
extern color           ColorDown     = clrSandyBrown;     // Color for down
extern int             LineWidth     = 3;                 // Main line width
extern string          IndicatorID   = "spassbf1";        // Unique ID for the indicator
extern bool            Interpolate   = true;              // Interpolate in multi time frame?

//
//
//
//
//

double spbf[];
double spbfUa[];
double spbfUb[];
double spbfDa[];
double spbfDb[];
double levup[];
double levmi[];
double levdn[];
double trend[],price[];

string indicatorFileName,shortName;
bool   returnBars;

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
   IndicatorBuffers(10);
   SetIndexBuffer(0,levup);
   SetIndexBuffer(1,levmi);
   SetIndexBuffer(2,levdn);
   SetIndexBuffer(3,spbf);   SetIndexStyle(3,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(4,spbfUa); SetIndexStyle(4,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(5,spbfUb); SetIndexStyle(5,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(6,spbfDa); SetIndexStyle(6,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(7,spbfDb); SetIndexStyle(7,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(8,trend); 
   SetIndexBuffer(9,price); 
   
       //
       //
       //
       //
       //
      
       indicatorFileName = WindowExpertName();
       returnBars        = (TimeFrame==-99);
       TimeFrame         = MathMax(TimeFrame,_Period);
       if (ForSymbol=="") ForSymbol = _Symbol;
         shortName = IndicatorID+" "+ForSymbol+" "+timeFrameToString(TimeFrame)+" Super passband filter ("+(string)Period1+","+(string)Period2+","+(string)RmsCount+")";
   IndicatorShortName(shortName);
   return(0);
}
int deinit()
{
   string lookFor       = IndicatorID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
      if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return (0);
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
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
            color colorUp = ColorUp;
            color colorDn = ColorDown;
            int window = WindowFind(shortName);
            int limit  = MathMin(Bars-counted_bars,Bars-1);
            if (returnBars) { levup[0] = limit+1; return(0); }
            if (TimeFrame != Period() || ForSymbol!=_Symbol)
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(ForSymbol,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period())); 
               if (trend[limit]== 1) CleanPoint(limit,spbfUa,spbfUb);
               if (trend[limit]==-1) CleanPoint(limit,spbfDa,spbfDb);
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     levup[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",Period1,Period2,RmsCount,Price,ColorOn,ColorUp,ColorDown,-1,IndicatorID,0,y);
                     levmi[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",Period1,Period2,RmsCount,Price,ColorOn,ColorUp,ColorDown,-1,IndicatorID,1,y); 
                     levdn[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",Period1,Period2,RmsCount,Price,ColorOn,ColorUp,ColorDown,-1,IndicatorID,2,y);
                     spbf[i]   = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",Period1,Period2,RmsCount,Price,ColorOn,ColorUp,ColorDown,-1,IndicatorID,3,y);
                     trend[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",Period1,Period2,RmsCount,Price,ColorOn,ColorUp,ColorDown,-1,IndicatorID,8,y); 
                     spbfDa[i] = EMPTY_VALUE;
                     spbfDb[i] = EMPTY_VALUE;
                     spbfUa[i] = EMPTY_VALUE;
                     spbfUb[i] = EMPTY_VALUE;
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                        int n,j; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(j = 1; j<n && (i+n)<Bars && (i+j)<Bars; j++)
                           {
                              levup[i+j] = levup[i] + (levup[i+n] - levup[i])*j/n;
                              levmi[i+j] = levmi[i] + (levmi[i+n] - levmi[i])*j/n;
                              levdn[i+j] = levdn[i] + (levdn[i+n] - levdn[i])*j/n;
                              spbf[i+j]  = spbf[i]  + (spbf[i+n]  - spbf[i] )*j/n;
                           }
               }
               for(int i=limit; i>=0; i--)
               {
                  if (i<Bars-1 && trend[i] ==  1) { PlotPoint(i,spbfUa,spbfUb,spbf); drawFill(IndicatorID,window,Time[i],Time[i+1],spbf[i],MathMax(spbf[i+1],levup[i+1]),levup[i],levup[i+1],colorUp); }
                  if (i<Bars-1 && trend[i] == -1) { PlotPoint(i,spbfDa,spbfDb,spbf); drawFill(IndicatorID,window,Time[i],Time[i+1],spbf[i],MathMin(spbf[i+1],levdn[i+1]),levdn[i],levdn[i+1],colorDn); }
               }
               return(0);
            }

   //
   //
   //
   //
   //

   double a1 = 5.0 / Period1 ;
   double a2 = 5.0 / Period2 ;
     if (trend[limit]== 1) CleanPoint(limit,spbfUa,spbfUb);
     if (trend[limit]==-1) CleanPoint(limit,spbfDa,spbfDb);
     for (int i=limit; i>=0; i--)
     {  
         price[i] = getPrice(Price,Open,Close,High,Low,i);
            if (i>=Bars-3) { spbf[i] = price[i]; continue; }
            spbf[i]  = (a1-a2)*price[i] + (a2*(1-a1)-a1*(1-a2))*price[i+1] + ((1-a1)+(1-a2))*spbf[i+1]-(1-a1)*(1-a2)*spbf[i+2];
            double rms = 0; for (int k=0; k<RmsCount && (i+k)<Bars; k++) rms += spbf[i+k]*spbf[i+k];
                   rms = MathSqrt(rms/RmsCount);
            
            levup[i]  = rms;
            levmi[i]  = 0;
            levdn[i]  = -rms;
            spbfDa[i] = EMPTY_VALUE;
            spbfDb[i] = EMPTY_VALUE;
            spbfUa[i] = EMPTY_VALUE;
            spbfUb[i] = EMPTY_VALUE;
            trend[i]   = 0;
            switch(ColorOn)
            {
               case cc_onLevels:
                  if (spbf[i]>levup[i]) trend[i] =  1;
                  if (spbf[i]<levdn[i]) trend[i] = -1;
                  break;
               case cc_onMiddle:                  
                  if (spbf[i]>levmi[i]) trend[i] =  1;
                  if (spbf[i]<levmi[i]) trend[i] = -1;
                  break;
               default :
                  if (i<Bars-1)
                  {
                     if (spbf[i]>spbf[i+1]) trend[i] =  1;
                     if (spbf[i]<spbf[i+1]) trend[i] = -1;
                  }                  
            }                  
         
         //
         //
         //
         //
         //
         
         string oname = IndicatorID+":u"+(string)Time[i]; ObjectDelete(oname);
                oname = IndicatorID+":d"+(string)Time[i]; ObjectDelete(oname);
         if (trend[i] ==  1) { PlotPoint(i,spbfUa,spbfUb,spbf); if (LineWidth>=0) drawFill(IndicatorID,window,Time[i],Time[i+1],spbf[i],MathMax(spbf[i+1],levup[i+1]),levup[i],levup[i+1],colorUp); }
         if (trend[i] == -1) { PlotPoint(i,spbfDa,spbfDb,spbf); if (LineWidth>=0) drawFill(IndicatorID,window,Time[i],Time[i+1],spbf[i],MathMin(spbf[i+1],levdn[i+1]),levdn[i],levdn[i+1],colorDn); }
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

void drawFill(string name, int window, datetime time1, datetime time2, double priceu1, double priceu2, double priced1, double priced2, color fillColor)
{
   string oname = name+":u"+(string)time1;
            ObjectDelete(oname);
               ObjectCreate(0,oname,OBJ_TRIANGLE,window,time1,priceu1,time2,priceu2,time1,priced1);
               ObjectSet(oname,OBJPROP_COLOR,fillColor);
               ObjectSet(oname,OBJPROP_BORDER_COLOR,fillColor);
               ObjectSet(oname,OBJPROP_BACK,true);
               ObjectSet(oname,OBJPROP_SELECTABLE,false);
               ObjectSet(oname,OBJPROP_HIDDEN,true);
         oname = name+":d"+(string)time1;
            ObjectDelete(oname);
               ObjectCreate(0,oname,OBJ_TRIANGLE,window,time1,priced1,time2,priced2,time2,priceu2);
               ObjectSet(oname,OBJPROP_COLOR,fillColor);
               ObjectSet(oname,OBJPROP_BACK,true);
               ObjectSet(oname,OBJPROP_BORDER_COLOR,fillColor);
               ObjectSet(oname,OBJPROP_SELECTABLE,false);
               ObjectSet(oname,OBJPROP_HIDDEN,true);
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
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
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

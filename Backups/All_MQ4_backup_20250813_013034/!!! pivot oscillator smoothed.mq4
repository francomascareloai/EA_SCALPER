//+------------------------------------------------------------------+
//|                                                 pivot points.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 DimGray
#property indicator_color2 DeepSkyBlue
#property indicator_color3 PaleVioletRed
#property indicator_color4 DeepSkyBlue
#property indicator_color5 PaleVioletRed
#property indicator_color6 DeepSkyBlue
#property indicator_color7 PaleVioletRed
#property indicator_color8 PaleVioletRed
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT
#property indicator_style6 STYLE_DOT
#property indicator_style7 STYLE_DOT
#property indicator_width8 2

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
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen ,   // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};

input int             T3Period              = 10;
extern int            PivotLevel            = 3;
extern enPrices       PivotPrice            = pr_close;
input double          inpT3Hot              = 0.5;              // T3 hot
enum  enT3Type
      {
         t3_tillson,                                                    // Tim Tillson way of calculation
         t3_fulksmat                                                    // Fulks/Matulich way of calculation
      };
input enT3Type         inpT3Type             = t3_fulksmat;      // T3 type
extern string          PivotId               = "pivot oscialltor 1";
extern string          TimeFrame             = "D1";
extern int             HourShift             = 0;
extern bool            FixSundays            = true;
extern bool            ShowLabels            = true;
extern bool            ShowValues            = false;
extern color           LabelsColor           = clrDimGray;
extern int             LabelsFontSize        =  10;
extern int             LabelsShiftHorizontal = -15;
extern int             LabelsShiftVertical   =  10;


//
//
//
//
//

double PBuffer[];
double S1Buffer[];
double R1Buffer[];
double S2Buffer[];
double R2Buffer[];
double S3Buffer[];
double R3Buffer[];
double Price[];

//
//
//
//
//

string labels[7] = {"pivot" ,"S1","R1","S2","R2","S3","R3"};
int    timeFrame;
int    lookupTimeFrame;
string Description;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   lookupTimeFrame = PERIOD_H1;
   timeFrame       = stringToTimeFrame(TimeFrame);
            if (timeFrame<PERIOD_D1)
            {
               HourShift=0;
               lookupTimeFrame = timeFrame;
            }         
            if (timeFrame==PERIOD_W1)
            {
               if (HourShift<0) HourShift -= 24;
               if (HourShift>0) HourShift += 24;
            }
            PivotLevel = MathMax(MathMin(PivotLevel,3),1);
   
   //
   //
   //
   //
   //
   
      SetIndexBuffer(0,PBuffer);  SetIndexLabel(0,Description+labels[0]);
      SetIndexBuffer(1,S1Buffer); SetIndexLabel(1,Description+labels[1]);
      SetIndexBuffer(2,R1Buffer); SetIndexLabel(2,Description+labels[2]);
      SetIndexBuffer(3,S2Buffer); SetIndexLabel(3,Description+labels[3]);
      SetIndexBuffer(4,R2Buffer); SetIndexLabel(4,Description+labels[4]);
      SetIndexBuffer(5,S3Buffer); SetIndexLabel(5,Description+labels[5]);
      SetIndexBuffer(6,R3Buffer); SetIndexLabel(6,Description+labels[6]);
      SetIndexBuffer(7,Price); 
   IndicatorShortName(PivotId);
   return(0);
}

int deinit()
{
   for (int i = 7; i>0; i--) ObjectDelete(StringConcatenate(PivotId,"-",i));
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

double work[][7];
#define _p  0
#define _s1 1
#define _s2 2
#define _s3 3
#define _r1 4
#define _r2 5
#define _r3 6

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;

   if (Period() >= timeFrame) return(-1);
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
      limit = MathMin(Bars-counted_bars,Bars-1);
      if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);

   //
   //
   //
   //
   //

   double P =  work[Bars-limit-2][_p];
   double S1 = work[Bars-limit-2][_s1];
   double R1 = work[Bars-limit-2][_r1];
   double S2 = work[Bars-limit-2][_s2];
   double R2 = work[Bars-limit-2][_r2];
   double S3 = work[Bars-limit-2][_s3];
   double R3 = work[Bars-limit-2][_r3];
   
   for (i=limit,r=Bars-i-1; i>=0; i--,r++)
   {
      int x = iBarShift(NULL,timeFrame,Time[i+1]-HourShift*3600,true);
      int y = iBarShift(NULL,timeFrame,Time[i]  -HourShift*3600,true);
      if (x!=y)
      {
         int k = i;
         if (FixSundays && timeFrame==PERIOD_D1)
         {
            while (k<Bars && TimeDayOfWeek(Time[k+1]-HourShift*3600)==0) k++;
         }
         int z = iBarShift(NULL,lookupTimeFrame,Time[k+1]-timeFrame*60-HourShift*3600);
             x = iBarShift(NULL,lookupTimeFrame,Time[k+1]             -HourShift*3600);
               
             //
             //
             //
             //
             //

             double LastHigh  = iHigh (NULL,lookupTimeFrame,iHighest(NULL,lookupTimeFrame,MODE_HIGH,z-x,x));
             double LastLow   = iLow  (NULL,lookupTimeFrame,iLowest( NULL,lookupTimeFrame,MODE_LOW ,z-x,x));
             double LastClose = Close[k+1];
               
             //
             //
             //
             //
             //
               
             P  = (LastHigh+LastLow+LastClose)/3;
             R1 = (2*P)-LastLow;
             S1 = (2*P)-LastHigh;
             R2 = P+(LastHigh - LastLow);
             S2 = P-(LastHigh - LastLow);
             R3 = (2*P)+(LastHigh-(2*LastLow));
             S3 = (2*P)-((2* LastHigh)-LastLow); 
      }
                  
      //
      //
      //
      //
      //

         work[r][_p] =P;
         work[r][_s1]=S1;
         work[r][_r1]=R1;
         work[r][_s2]=S2;
         work[r][_r2]=R2;
         work[r][_s3]=S3;
         work[r][_r3]=R3;

         //
         //
         //
         //
         //
         
         double range;
         double lower;
         switch (PivotLevel)
         {
            case 1 : 
               lower = work[r][_s1];
               range = work[r][_r1]-work[r][_s1];
               if (range!=0)
               {
                  R1Buffer[i] =  1;
                  S1Buffer[i] = -1;
               }                  
               break;
               
               //
               //
               //
               //
               //
               
            case 2 : 
               lower = work[r][_s2];
               range = work[r][_r2]-work[r][_s2];
               if (range!=0)
               {
                  R2Buffer[i] =  1;
                  S2Buffer[i] = -1;
                  R1Buffer[i] = 2.0*((work[r][_r1]-lower)/range-0.5);
                  S1Buffer[i] = 2.0*((work[r][_s1]-lower)/range-0.5);
               }
               break;
               
               //
               //
               //
               //
               //
                              
            case 3 : 
               lower = work[r][_s3];
               range = work[r][_r3]-work[r][_s3];
               if (range!=0)
               {
                  R3Buffer[i] =  1;
                  S3Buffer[i] = -1;
                  R1Buffer[i] = 2.0*((work[r][_r1]-lower)/range-0.5);
                  S1Buffer[i] = 2.0*((work[r][_s1]-lower)/range-0.5);
                  R2Buffer[i] = 2.0*((work[r][_r2]-lower)/range-0.5);
                  S2Buffer[i] = 2.0*((work[r][_s2]-lower)/range-0.5);
               }
               break;
         }

         //
         //
         //
         //
         //
         
         if (range !=0)
         {
            PBuffer[i] = 2.0*((work[r][_p]-lower)/range-0.5);
            Price[i]   = 2.0*iT3(((getPrice(PivotPrice,Open,Close,High,Low,i,Bars)-lower)/range-0.5),T3Period,inpT3Hot,inpT3Type==t3_fulksmat,i,Bars);
         }
   }
   if (ShowLabels) DisplayLabels();
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

#define t3Instances 1
double workT3[][t3Instances*6];
double workT3Coeffs[][6];
#define _tperiod 0
#define _c1      1
#define _c2      2
#define _c3      3
#define _c4      4
#define _alpha   5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int bars, int tinstanceNo=0)
{
   if (ArrayRange(workT3,0) != bars)                 ArrayResize(workT3,bars);
   if (ArrayRange(workT3Coeffs,0) < (tinstanceNo+1)) ArrayResize(workT3Coeffs,tinstanceNo+1);

   if (workT3Coeffs[tinstanceNo][_tperiod] != period)
   {
     workT3Coeffs[tinstanceNo][_tperiod] = period;
        double a = hot;
            workT3Coeffs[tinstanceNo][_c1] = -a*a*a;
            workT3Coeffs[tinstanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[tinstanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[tinstanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[tinstanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[tinstanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int instanceNo = tinstanceNo*6;
   int r = bars-i-1;
   if (r == 0)
      {
         workT3[r][0+instanceNo] = price;
         workT3[r][1+instanceNo] = price;
         workT3[r][2+instanceNo] = price;
         workT3[r][3+instanceNo] = price;
         workT3[r][4+instanceNo] = price;
         workT3[r][5+instanceNo] = price;
      }
   else
      {
         workT3[r][0+instanceNo] = workT3[r-1][0+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(price                  -workT3[r-1][0+instanceNo]);
         workT3[r][1+instanceNo] = workT3[r-1][1+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][0+instanceNo]-workT3[r-1][1+instanceNo]);
         workT3[r][2+instanceNo] = workT3[r-1][2+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][1+instanceNo]-workT3[r-1][2+instanceNo]);
         workT3[r][3+instanceNo] = workT3[r-1][3+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][2+instanceNo]-workT3[r-1][3+instanceNo]);
         workT3[r][4+instanceNo] = workT3[r-1][4+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][3+instanceNo]-workT3[r-1][4+instanceNo]);
         workT3[r][5+instanceNo] = workT3[r-1][5+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][4+instanceNo]-workT3[r-1][5+instanceNo]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[tinstanceNo][_c1]*workT3[r][5+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c2]*workT3[r][4+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c3]*workT3[r][3+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c4]*workT3[r][2+instanceNo]);
}

//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

int barTime(int a)
{
   if(a<0)
         return(Time[0]+Period()*60*MathAbs(a));
   else  return(Time[a]);   
}

//
//
//
//
//

void DisplayLabels()
{
   ShowLabel(1,PBuffer ,Description+labels[0]);
   ShowLabel(2,S1Buffer,Description+labels[1]);
   ShowLabel(3,R1Buffer,Description+labels[2]);
   ShowLabel(4,S2Buffer,Description+labels[3]);
   ShowLabel(5,R2Buffer,Description+labels[4]);
   ShowLabel(6,S3Buffer,Description+labels[5]);
   ShowLabel(7,R3Buffer,Description+labels[6]);
}
void ShowLabel(string ID, double& forLine[],string label)
{
   string finalLabel = "";
   
   if (ShowLabels) finalLabel = label;
   if (ShowValues) finalLabel = finalLabel+" "+DoubleToStr(forLine[0],Digits);
         SetLabel(ID,forLine[0],finalLabel);
}

//
//
//
//
//

void SetLabel(string ID,double forLine,string label)
{
   datetime theTime = barTime(LabelsShiftHorizontal);
   string   name    = PivotId+"-"+ID;
   int      window = WindowFind(PivotId);
   
   if(ObjectFind(name)==-1) {
      ObjectCreate(name,OBJ_TEXT,window,0,0);
      ObjectSetText(name,label,LabelsFontSize,"Arial",LabelsColor); }
      ObjectMove(name,0,theTime,forLine+LabelsShiftVertical/100.0);
   
}

//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringUpperCase(tfs);
         if (tfs=="M1" || tfs=="1")     { tf=PERIOD_M1;  Description = "";}
         if (tfs=="M5" || tfs=="5")     { tf=PERIOD_M5;  Description = "5 minutes "; }
         if (tfs=="M15"|| tfs=="15")    { tf=PERIOD_M15; Description = "15 minutes ";}
         if (tfs=="M30"|| tfs=="30")    { tf=PERIOD_M30; Description = "half hour "; }
         if (tfs=="H1" || tfs=="60")    { tf=PERIOD_H1;  Description = "hourly ";    }
         if (tfs=="H4" || tfs=="240")   { tf=PERIOD_H4;  Description = "4 hourly ";  }
         if (tfs=="D1" || tfs=="1440")  { tf=PERIOD_D1;  Description = "daily ";     }
         if (tfs=="W1" || tfs=="10080") { tf=PERIOD_W1;  Description = "weekly ";    }
         if (tfs=="MN" || tfs=="43200") { tf=PERIOD_MN1; Description = "monthly ";   }
  return(tf);
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;
   int      length = StringLen(str) - 1;
   int      tchar;
   
   while(length >= 0)
      {
         tchar = StringGetChar(s, length);
         
         //
         //
         //
         //
         //
         
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                  s = StringSetChar(s, length, tchar - 32);
         else 
              if(tchar > -33 && tchar < 0)
                  s = StringSetChar(s, length, tchar + 224);
         length--;
   }
   return(s);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------

#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*fabs((close[i]-open[i])/2.0));
               else  haClose = (open[i]+close[i])/2.0; 
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         //
         //
         //
         //
         //
         
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
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:   
            case pr_habopen:     return(haOpen);
            case pr_hahigh: 
            case pr_habhigh:     return(haHigh);
            case pr_halow:    
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh+haLow)/2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen+haClose)/2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:  
            case pr_habaverage:  return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
            case pr_habtbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
            case pr_habtbiased2:
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
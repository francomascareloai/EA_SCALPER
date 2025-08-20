//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  PaleVioletRed
#property indicator_style1  STYLE_DASH
#property indicator_color2  Red
#property indicator_style2  STYLE_DOT
#property indicator_color3  Green
#property indicator_style3  STYLE_DOT 
#property indicator_color4  Aqua
#property indicator_width4  2   
#property indicator_color5  Magenta
#property indicator_width5  2    

//
//
//
//
//

extern string TimeFrame       = "current time frame";
extern int    FilterPeriod    = 30;
extern int    FilterPrice     = PRICE_CLOSE;
extern int    FilterType      = 0;
extern double FrequencyCutoff = 0.01;
extern bool   Causal          = false;
extern int    rangePeriod     = 5;
extern int    MaMethod        = 8;
extern double UpDeviation     = 2.0;
extern double DnDeviation     = 2.0;
extern bool   Interpolate     = true;
extern bool   ShowArrows      = true;

extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = false;
extern bool   alertsOnHighLow = true;
extern bool   alertsOnArrows  = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;
extern bool   alertsNotify    = true;

//
//
//
//
//

double ma[];
double buffer1[];
double buffer2[];
double upArrow[];
double dnArrow[];
double trend[];
double pr[];
double coeffs[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

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
   IndicatorBuffers(7);
   SetIndexBuffer(0,ma);
   SetIndexBuffer(1,buffer1);
   SetIndexBuffer(2,buffer2);
   SetIndexBuffer(3,dnArrow);
   SetIndexBuffer(4,upArrow);
   SetIndexBuffer(5,pr);
   SetIndexBuffer(6,trend);
   
   if (ShowArrows)
            {
               SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,159);
               SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,159);
            }
            else
            {
               SetIndexStyle(3,DRAW_NONE);
               SetIndexStyle(4,DRAW_NONE);
            }
         
      //
      //
      //
      //
      //

      FrequencyCutoff = MathMax(MathMin(FrequencyCutoff,0.4999999),0.00000001);
      FilterType      = MathMax(MathMin(FilterType,13),0);
      FilterPeriod    = MathMax(FilterPeriod,1);
                      if (FilterPeriod%2==0) FilterPeriod += 1; 
                           fillCoeffs(coeffs,FrequencyCutoff,FilterPeriod,FilterType);
      //
      //
      //
      //
      //
   
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame=="returnBars";     if (returnBars)     return(0);
      calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
      
    IndicatorShortName(timeFrameToString(timeFrame)+"  Sync filters-low pass apz bands "+getAverageName(MaMethod)+" ("+rangePeriod+")");
         
   return(0);
}

//
//
//
//
//

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
   int i,x,counted_bars=IndicatorCounted(),half = MathFloor(FilterPeriod/2.0);
      if (counted_bars<0) return(-1);
      if (counted_bars>0) counted_bars--;
         int limit = MathMin(MathMax(Bars-counted_bars,half),Bars-1);
         if (returnBars)  { ma[0] = limit+1; return(0);  } 
         
         //
         //
         //
         //
         //
         
         if (calculateValue || timeFrame==Period())
         {
         
         for (i=limit; i>=0 ; i--) pr[i] = iMA(NULL,0,1,0,MODE_SMA,FilterPrice,i);
         for (i=limit; i>=0 ; i--)
         {
               double sum = 0; ma[i] = 0;
                  
               for (int k=0; k<FilterPeriod; k++) 
                  if (Causal) ma[i] += pr[i+k]*coeffs[k];
                  else                        
                     if ((i+k-half)>=0 && (i+k-half)<Bars)
                     {
                           ma[i] += pr[i+k-half]*coeffs[k];
                           sum   += coeffs[k];
                     }

               //
               //
               //
               //
               //
                                       
               if (sum!=0) ma[i] /= sum;
               double range      = CalculateRange(rangePeriod,i);
                      buffer1[i] = ma[i] + UpDeviation * range;
                      buffer2[i] = ma[i] - DnDeviation * range;
                      upArrow[i] = EMPTY_VALUE;
                      dnArrow[i] = EMPTY_VALUE; 
         
         if (High[i+1]>buffer1[i+1] && Close[i+1]>Open[i+1] && Close[i]<Open[i]) upArrow[i] = High[i]+iATR(NULL,0,20,i)/2.0;
         if ( Low[i+1]<buffer2[i+1] && Close[i+1]<Open[i+1] && Close[i]>Open[i]) dnArrow[i] = Low[i] -iATR(NULL,0,20,i)/2.0;
      
      
         trend[i] = 0;                     
            if (alertsOnHighLow)       
            {
               if (High[i] > buffer1[i]) trend[i] = -1;
               if (Low[i]  < buffer2[i]) trend[i] =  1;
            }
            else
            {
               if (Close[i] > buffer1[i]) trend[i] = -1;
               if (Close[i] < buffer2[i]) trend[i] =  1;
            }
      }
      if (!calculateValue) manageAlerts();
      return(0);            
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y      = iBarShift(NULL,timeFrame,Time[i]);
      ma[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FilterPeriod,FilterPrice,FilterType,FrequencyCutoff,Causal,rangePeriod,MaMethod,UpDeviation,DnDeviation,0,y);
      buffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FilterPeriod,FilterPrice,FilterType,FrequencyCutoff,Causal,rangePeriod,MaMethod,UpDeviation,DnDeviation,1,y);
      buffer2[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FilterPeriod,FilterPrice,FilterType,FrequencyCutoff,Causal,rangePeriod,MaMethod,UpDeviation,DnDeviation,2,y);
      trend[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FilterPeriod,FilterPrice,FilterType,FrequencyCutoff,Causal,rangePeriod,MaMethod,UpDeviation,DnDeviation,6,y);
      upArrow[i] = EMPTY_VALUE;
      dnArrow[i] = EMPTY_VALUE; 
      
      if (High[i+1]>buffer1[i+1] && Close[i+1]>Open[i+1] && Close[i]<Open[i]) upArrow[i] = High[i]+iATR(NULL,0,20,i)/2.0;
      if ( Low[i+1]<buffer2[i+1] && Close[i+1]<Open[i+1] && Close[i]>Open[i]) dnArrow[i] = Low[i] -iATR(NULL,0,20,i)/2.0;

      //
      //
      //
      //
      //
            
      if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

      //
      //
      //
      //
      //

      datetime time = iTime(NULL,timeFrame,y);
         for(x = 1; i+x < Bars && Time[i+x] >= time; x++) continue;	
         for(k = 1; k < x; k++)
         {
            ma[i+k]      = ma[i]      + (ma[i+x]      - ma[i])     * k/x;
            buffer1[i+k] = buffer1[i] + (buffer1[i+x] - buffer1[i])* k/x;
            buffer2[i+k] = buffer2[i] + (buffer2[i+x] - buffer2[i])* k/x;
   
         }               
   }

   //
   //
   //
   //
   //
      
   manageAlerts();
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

#define Pi 3.141592653589793238462643383279502884197169399375105820974944592

void fillCoeffs(double& tcoeffs[], double frequencyCutoff, double filterPeriod, int filterType, double multiplier=1)
{
   ArrayResize(coeffs,filterPeriod);
   
   //
   //
   //
   //
   //
   
   int N = filterPeriod-1; double sum = 0;  
   for (int n=0; n<filterPeriod; n++)
   {
      double div = (n-N/2.0);
         if (div==0) tcoeffs[n]  = 2.0*Pi*frequencyCutoff;
         else        tcoeffs[n]  = MathSin(2.0*Pi*frequencyCutoff*div)/div;

      //
      //
      //
      //
      //

      switch(filterType)
      {
         case 0 :  tcoeffs[n] *= (0.54-0.46*MathCos(2*Pi*n/N));                                                                     break; // Hamming
         case 1 :  tcoeffs[n] *= (0.50-0.50*MathCos(2*Pi*n/N));                                                                     break; // Hanning
         case 2 :  tcoeffs[n] *= (0.42-0.50*MathCos(2*Pi*n/N)+0.08*MathCos(4*Pi*n/N));                                              break; // Blackman
         case 3 :  tcoeffs[n] *= (0.35875-0.48829*MathCos(2*Pi*n/N)+0.14128*MathCos(4*Pi*n/N)+0.01168*MathCos(6*Pi*n/N));           break; // Blackman Harris
         case 4 :  tcoeffs[n] *= (0.3635819-0.4891775*MathCos(2*Pi*n/N)+0.1365995*MathCos(4*Pi*n/N)+0.0106411*MathCos(6*Pi*n/N));   break; // Blackman Nutall
         case 5 :  tcoeffs[n] *= (0.355768-0.487396*MathCos(2*Pi*n/N)+0.144232*MathCos(4*Pi*n/N)+0.012604*MathCos(6*Pi*n/N));       break; // Nutall
         case 6 :  tcoeffs[n] *= (2.0/N*(N/2.0-MathAbs(n-N/2)));                                                                    break; // Bartlet zero end points
         case 7 :  tcoeffs[n] *= (0.62-0.48*MathAbs(n/N-0.5)*0.38*MathCos(2.0*Pi*n/N));                                             break; // Bartlet-Hann
         case 8 :  tcoeffs[n] *= (0.50*(1.0-MathCos(2.0*Pi*n/N)));                                                                  break; // Hann
         case 9 :  tcoeffs[n] *= (MathSin(Pi*n/N));                                                                                 break; // Sine
         case 10:  
                double ttx = ((n/N)-1.0);
                   if (ttx==0)
                         tcoeffs[n] *= 0;
                   else  tcoeffs[n] *= (MathSin(ttx)/(ttx));                                                                        break; // Lanczos
         case 11:  tcoeffs[n] *= (1-1.93*MathCos(2*Pi*n/N)+1.29*MathCos(4*Pi*n/N)+0.388*MathCos(6*Pi*n/N)+0.388*MathCos(8*Pi*n/N)); break; // Flat top
      }
      
      //
      //
      //
      //
      //
      
      sum += tcoeffs[n];
   }
   for (int k=0; k<filterPeriod; k++) { tcoeffs[k] = tcoeffs[k]/sum; tcoeffs[k] = tcoeffs[k]*multiplier; }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      static datetime time1=0;
      static string   mess1="";
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(time1,mess1,whichBar,"Sync filters bands price penetrated lower band");
         if (trend[whichBar] ==-1) doAlert(time1,mess1,whichBar,"Sync filters bands price penetrated upper band");
      }         
      static datetime time2=0;
      static string   mess2="";
      if (alertsOnArrows)
      {
         if (upArrow[whichBar] != EMPTY_VALUE) doAlert(time2,mess2,whichBar,"Sync filters bands upp arrow formed");
         if (dnArrow[whichBar] != EMPTY_VALUE) doAlert(time2,mess2,whichBar,"Sync filters bands down arrow formed");
      }         
   }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," "+timeFrameToString(timeFrame)+doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Sync filters bands "),message);
          if (alertsNotify)  SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());

//
//
//
//
//
                                                      
}
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

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}   
 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double CalculateRange(int pFilterPeriod,int i)
{
   int j,k;
   double lsum   = (FilterPeriod+1)*iCustomMA(iMA(NULL,0,1,0,MODE_SMA,PRICE_LOW, i),rangePeriod,MaMethod,i);
   double hsum   = (FilterPeriod+1)*iCustomMA(iMA(NULL,0,1,0,MODE_SMA,PRICE_HIGH,i),rangePeriod,MaMethod,i);
   double sumw   = (FilterPeriod+1);
   
   //
   //
   //
   //
   //
      
   for(j=1, k=pFilterPeriod; j<=pFilterPeriod; j++, k--)
   {
      lsum += k*iCustomMA(iMA(NULL,0,1,0,MODE_SMA,PRICE_LOW, i+j),rangePeriod,MaMethod,i+j);
      hsum += k*iCustomMA(iMA(NULL,0,1,0,MODE_SMA,PRICE_HIGH,i+j),rangePeriod,MaMethod,i+j);
      sumw += k;

      if (j<=i)
      {
         lsum += k*iCustomMA(iMA(NULL,0,1,0,MODE_SMA,PRICE_LOW, i-j),rangePeriod,MaMethod,i-j);
         hsum += k*iCustomMA(iMA(NULL,0,1,0,MODE_SMA,PRICE_HIGH,i-j),rangePeriod,MaMethod,i-j);
         sumw += k;
      }
   }
   return (hsum/sumw - lsum/sumw);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double workPrices[];
double workResult[];
int    r;

double iCustomMA(double price, int period, int method, int i)
{
   if (ArraySize(workPrices)!= Bars) ArrayResize(workPrices,Bars);
            r = Bars-i-1;
   workPrices[r] = price;

   //
   //
   //
   //
   //
   
      switch(method)
      {
         case  0: return(iSma(price,period,i));
         case  1: return(iEma(price,period,i));
         case  2: return(iSmma(price,period,i));
         case  3: return(iLwma(price,period,i));
         case  4: return(iLsma(price,period,i));
         case  5: return(iTma(price,period,i));
         case  6: return(iSineWMA(price,period,i));
         case  7: return(iVolumeWMA(price,period,i));
         case  8: return(iHma(price,period,i));
         case  9: return(iNonLagMa(price,period,i));
         case 10: return(iLwmp(price,period,i));
      }
   return(EMPTY_VALUE);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double iSma(double price, double period, int i)
{
   double sum = 0;
   for(int k=0; k<period && (r-k)>=0; k++) sum += workPrices[r-k];  
   if (k!=0)
         return(sum/k);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

double iEma(double price, double period, int i)
{
   if (ArraySize(workResult)!= Bars) ArrayResize(workResult,Bars);
   double alpha = 2.0 / (1.0+period);
          workResult[r] = workResult[r-1]+alpha*(price-workResult[r-1]);
   return(workResult[r]);
}
//
//
//
//
//

double iSmma(double price, double period, int i)
{
   if (ArraySize(workResult)!= Bars) ArrayResize(workResult,Bars);
   if (i>=(Bars-period))
   {
      double sum = 0; 
         for(int k=0; k<period && (r-k)>=0; k++) sum += workPrices[r-k];  
         if (k!=0)
               workResult[i] = sum/k;
         else  workResult[i] = EMPTY_VALUE;
   }      
   else   workResult[r] = (workResult[r-1]*(period-1)+price)/period;
   return(workResult[r]);
}

//
//
//
//
//

double iLwma_prices[][3];
double iLwma(double price, double period, int i,int forValue=0)
{
   if (ArrayRange(iLwma_prices,0)!= Bars) ArrayResize(iLwma_prices,Bars);
   
   //
   //
   //
   //
   //
   
   iLwma_prices[r][forValue] = price;
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*iLwma_prices[r-k][forValue];  
      }             
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

double iLwmp_prices[][3];
double iLwmp(double price, double period, int i,int forValue=0)
{
   if (ArrayRange(iLwmp_prices,0)!= Bars) ArrayResize(iLwmp_prices,Bars);
   
   //
   //
   //
   //
   //
   
   iLwmp_prices[r][forValue] = price;
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<period && (r-k)>=0; k++)
      {
         double weight = (period-k)*(period-k);
                sumw  += weight;
                sum   += weight*iLwmp_prices[r-k][forValue];  
      }             
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

double iLsma(double price, double period, int i)
{
   return(3.0*iLwma(price,period,i)-2.0*iSma(price,period,i));
}

//
//
//
//
//

double iHma(double price, double period, int i)
{
   int HalfPeriod = MathFloor(period/2);
   int HullPeriod = MathFloor(MathSqrt(period));
            double price1 = 2.0*iLwma(price,HalfPeriod,i,0)-iLwma(price,period,i,1);
   return (iLwma(price1,HullPeriod,i,2));
}

//
//
//
//
//

double iTma(double price, double period, int i)
{
   double half = (period+1.0)/2.0;
   double sum  = 0;
   double sumw = 0;

   for(int k=0; k<period && (r-k)>=0; k++)
   {
      double weight = k+1; if (weight > half) weight = period-k;
             sumw  += weight;
             sum   += weight*workPrices[r-k];  
   }             
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

double iSineWMA(double price, int period, int i)
{
   double sum  = 0;
   double sumw = 0;
  
   for(int k=0; k<period && (r-k)>=0; k++)
   { 
      double weight = MathSin(Pi*(k+1)/(period+1));
             sumw  += weight;
             sum   += weight*workPrices[r-k]; 
   }
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

double iVolumeWMA(double price, int period, int i)
{
   double sum  = 0;
   double sumw = 0;
  
   for(int k=0; k<period && (r-k)>=0; k++)
   { 
      double weight = Volume[i+k];
             sumw  += weight;
             sum   += weight*workPrices[r-k]; 
   }
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}


//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

#define _length  0
#define _len     1
#define _weight  2

#define numOfSeparateCalculations 1
double  nlmvalues[numOfSeparateCalculations][3];
double  nlmprices[ ][numOfSeparateCalculations];
double  nlmalphas[ ][numOfSeparateCalculations];

//
//
//
//
//

double iNonLagMa(double price, double length, int i, int instanceNo=0)
{
   r = Bars-r-1;
   if (ArrayRange(nlmprices,0) != Bars)         ArrayResize(nlmprices,Bars);
   if (ArrayRange(nlmvalues,0) <  instanceNo+1) ArrayResize(nlmvalues,instanceNo+1);
                               nlmprices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlmprices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[instanceNo][_length] != length  || ArraySize(nlmalphas)==0)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;
      
         nlmvalues[instanceNo][_length] = length;
         nlmvalues[instanceNo][_len   ] = length*4 + Phase;  
         nlmvalues[instanceNo][_weight] = 0;

         if (ArrayRange(nlmalphas,0) < nlmvalues[instanceNo][_len]) ArrayResize(nlmalphas,nlmvalues[instanceNo][_len]);
         for (int k=0; k<nlmvalues[instanceNo][_len]; k++)
         {
            if (k<=Phase-1) 
                 double t = 1.0 * k/(Phase-1);
            else        t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlmalphas[k][instanceNo]        = g * beta;
            nlmvalues[instanceNo][_weight] += nlmalphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[instanceNo][_weight]>0)
   {
      double sum = 0;
           for (k=0; k < nlmvalues[instanceNo][_len]; k++) sum += nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
           return( sum / nlmvalues[instanceNo][_weight]);
   }
   else return(0);           
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string methodNames[] = {"SMA","EMA","SMMA","LWMA","LSMA","TriMA","SWMA","VWMA","HullMA","NonLagMA","LWM parabolic"};
string getAverageName(int& method)
{
   method=MathMax(MathMin(method,10),0); return(methodNames[method]);
}

//
//
//
//
//
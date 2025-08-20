//+------------------------------------------------------------------+

#property link      "www.forex-tsd.com"  
#property copyright "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    3
#property indicator_color1     LimeGreen
#property indicator_color2     PaleVioletRed
#property indicator_color3     PaleVioletRed
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_levelcolor DarkSlateGray

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    RsiPeriod       = 21;
extern int    NlmPeriod       = 5;
extern int    Price           = 0;
extern double PctFilter       = 0;
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;
extern bool   alertsNotify    = false;
extern double levelOb         = 70;
extern double levelOs         = 30;

//
//
//
//
//

double rsi[];
double nlmDa[];
double nlmDb[];
double trend[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
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
   IndicatorBuffers(4);
   SetIndexBuffer(0,rsi); 
   SetIndexBuffer(1,nlmDa);
   SetIndexBuffer(2,nlmDb);
   SetIndexBuffer(3,trend);

      //
      //
      //
      //
      //
         
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
   
      //
      //
      //
      //
      //
      
   SetLevelValue(0,levelOb);
   SetLevelValue(1,50);
   SetLevelValue(2,levelOs);
   IndicatorShortName(timeFrameToString(timeFrame)+"   NonLagRsi ("+RsiPeriod+")");
return(0);
}
  
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//

int deinit()  {   return(0);  }

//
//
//
//
//

double work[][2];
#define _bchang 0
#define _achang 1

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { rsi[0] = MathMin(limit+1,Bars-1); return(0); }

   
   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {
      if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);
      if (trend[limit]==-1) CleanPoint(limit,nlmDa,nlmDb);
      for(i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         rsi[i]   = iNonLagMa(iRsi(iMA(NULL,0,1,0,MODE_SMA,Price,i),RsiPeriod,i),NlmPeriod,i,0);
         nlmDa[i] = EMPTY_VALUE;
         nlmDb[i] = EMPTY_VALUE;
         trend[i] = trend[i+1];

         //
         //
         //
         //
         //
               
         if (PctFilter>0)
         {
            work[r][_bchang] = MathAbs(rsi[i]-rsi[i+1]);
            work[r][_achang] = work[r][_bchang];
            for (int k=1; k<NlmPeriod; k++) work[r][_achang] += work[r-k][_bchang];
                                            work[r][_achang] /= 1.0*NlmPeriod;
    
            double stddev = 0; for (k=0; k<NlmPeriod; k++) stddev += MathPow(work[r-k][_bchang]-work[r-k][_achang],2);
                   stddev = MathSqrt(stddev/NlmPeriod); 
            double filter = PctFilter * stddev;
            if(MathAbs(rsi[i]-rsi[i+1]) < filter) rsi[i]=rsi[i+1];
         }

         //
         //
         //
         //
         //
               
         if (rsi[i]>rsi[i+1]) trend[i] =  1;
         if (rsi[i]<rsi[i+1]) trend[i] = -1;
         if (trend[i] == -1)  PlotPoint(i,nlmDa,nlmDb,rsi);
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,nlmDa,nlmDb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         rsi[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,NlmPeriod,Price,PctFilter,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,0,y);
         nlmDa[i] = EMPTY_VALUE;
         nlmDb[i] = EMPTY_VALUE;
         trend[i] = trend[i+1];
         if (rsi[i]>rsi[i+1]) trend[i] =  1;
         if (rsi[i]<rsi[i+1]) trend[i] = -1;
         if (trend[i] == -1) PlotPoint(i,nlmDa,nlmDb,rsi);
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

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

        message =  StringConcatenate(Symbol()," ",timeFrameToString(Period())," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," NonLagRsi slope changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)  SendMail(StringConcatenate(Symbol(),"NonLag Rsi"),message);
          if (alertsNotify)  SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

#define Pi       3.14159265358979323846264338327950288
#define _length  0
#define _len     1
#define _weight  2

double  nlmvalues[3][1];
double  nlmprices[ ][1];
double  nlmalphas[ ][1];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int instanceNo=0)
{
   r = Bars-r-1;
   if (ArrayRange(nlmprices,0) != Bars) ArrayResize(nlmprices,Bars);
                               nlmprices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlmprices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[_length][instanceNo] != length)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;
      
         nlmvalues[_length][instanceNo] = length;
         nlmvalues[_len   ][instanceNo] = length*4 + Phase;  
         nlmvalues[_weight][instanceNo] = 0;

         if (ArrayRange(nlmalphas,0) < nlmvalues[_len][instanceNo]) ArrayResize(nlmalphas,nlmvalues[_len][instanceNo]);
         for (int k=0; k<nlmvalues[_len][instanceNo]; k++)
         {
            if (k<=Phase-1) 
                 double t = 1.0 * k/(Phase-1);
            else        t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlmalphas[k][instanceNo]        = g * beta;
            nlmvalues[_weight][instanceNo] += nlmalphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[_weight][instanceNo]>0)
   {
      double sum = 0;
           for (k=0; k < nlmvalues[_len][instanceNo]; k++) sum += nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
           return( sum / nlmvalues[_weight][instanceNo]);
   }
   else return(0);           
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

double workRsi[][3];
#define _price  0
#define _change 1
#define _changa 2

//
//
//
//

double iRsi(double price, double period, int shift, int forz=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int    z     = forz*3; 
      int    i     = Bars-shift-1;
      double alpha = 1.0/period; 

   //
   //
   //
   //
   //
   
   workRsi[i][_price+z] = price;
   if (i<period)
      {
         int k; double sum = 0; for (k=0; k<period && (i-k-1)>=0; k++) sum += MathAbs(workRsi[i-k][_price+z]-workRsi[i-k-1][_price+z]);
            workRsi[i][_change+z] = (workRsi[i][_price+z]-workRsi[0][_price+z])/MathMax(k,1);
            workRsi[i][_changa+z] =                                         sum/MathMax(k,1);
      }
   else
      {
         double change = workRsi[i][_price+z]-workRsi[i-1][_price+z];
                         workRsi[i][_change+z] = workRsi[i-1][_change+z] + alpha*(        change  - workRsi[i-1][_change+z]);
                         workRsi[i][_changa+z] = workRsi[i-1][_changa+z] + alpha*(MathAbs(change) - workRsi[i-1][_changa+z]);
      }
   if (workRsi[i][_changa+z] != 0)
         return(50.0*(workRsi[i][_change+z]/workRsi[i][_changa+z]+1));
   else  return(0);
}

//
//
//
//
//

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

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
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

string stringUpperCase(string str)
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
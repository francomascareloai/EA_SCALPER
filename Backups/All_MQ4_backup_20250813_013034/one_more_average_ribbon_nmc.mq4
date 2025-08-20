//+------------------------------------------------------------------+
//|                                                   Oma ribbon.mq4 |
//|                                               mladenfx@gmail.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DodgerBlue
#property indicator_color2 HotPink
#property indicator_color3 Aqua
#property indicator_color4 Yellow
#property indicator_width1 20
#property indicator_width2 20
#property indicator_width3 1
#property indicator_width4 1

//
//
//
//
//

extern string TimeFrame     = "current time frame";
extern double Oma1Period    = 20.55;
extern double Oma1Speed     = 2.0;
extern int    Oma1Price     = PRICE_CLOSE;
extern bool   Oma1Adaptive  = true;
extern double Oma2Period    = 50.85;
extern double Oma2Speed     = 0.0;
extern int    Oma2Price     = PRICE_CLOSE;
extern bool   Oma2Adaptive  = true;
extern bool   Interpolate   = true;

//
//
//
//
//

extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = false;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double trend[];

//
//
//
//
//

string indicatorFileName;
int    timeFrame;
bool   calculateValue;
bool   returnBars;

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
   IndicatorBuffers(5);
   SetIndexBuffer(0,buffer3); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,buffer4); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,buffer1);
   SetIndexBuffer(3,buffer2);
   SetIndexBuffer(4,trend);
      if (Oma1Period>Oma2Period)
      {
         double temp = Oma1Period;
                       Oma1Period = Oma2Period;
                       Oma2Period = temp;
      }                    

      //
      //
      //
      //
      //
         
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame=="returnBars");      if (returnBars)     return(0);
      calculateValue    = (TimeFrame=="calculateValue");  if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
   return(0);
}
int deinit()
{
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
   int limit,i;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars)  { buffer1[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      for(i=limit; i>=0; i--)
      {
         buffer1[i] = iSmooth(iMA(NULL,0,1,0,MODE_SMA,Oma1Price,i),Oma1Period,Oma1Speed,Oma1Adaptive,i,0);
         buffer2[i] = iSmooth(iMA(NULL,0,1,0,MODE_SMA,Oma2Price,i),Oma2Period,Oma2Speed,Oma2Adaptive,i,7);
         buffer3[i] = buffer1[i];
         buffer4[i] = buffer2[i];
         trend[i]   = trend[i+1];
      
            if (buffer1[i]>buffer2[i]) trend[i] =  1;
            if (buffer1[i]<buffer2[i]) trend[i] = -1;
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
      int y = iBarShift(NULL,timeFrame,Time[i]);
         buffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Oma1Period,Oma1Speed,Oma1Price,Oma1Adaptive,Oma2Period,Oma2Speed,Oma2Price,Oma2Adaptive,0,y);
         buffer2[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Oma1Period,Oma1Speed,Oma1Price,Oma1Adaptive,Oma2Period,Oma2Speed,Oma2Price,Oma2Adaptive,1,y);
         buffer3[i] = buffer1[i];
         buffer4[i] = buffer2[i];
         trend[i]   = trend[i+1];
            if (buffer1[i]>buffer2[i]) trend[i] =  1;
            if (buffer1[i]<buffer2[i]) trend[i] = -1;

         //
         //
         //
         //
         //
      
         if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            double factor = 1.0 / n;
            for(int k = 1; k < n; k++)
            {
               buffer1[i+k] = k*factor*buffer1[i+n] + (1.0-k*factor)*buffer1[i];
               buffer2[i+k] = k*factor*buffer2[i+n] + (1.0-k*factor)*buffer2[i];
               buffer3[i+k] = buffer1[i+k];
               buffer4[i+k] = buffer2[i+k];
            }
   }
   manageAlerts();

   //
   //
   //
   //
   //
      
   return(0);
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," oma "+Oma1Period+" crossed oma "+Oma2Period+" ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Oma ribbon "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double stored[][14];

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

double iSmooth(double price, double averagePeriod, double tconst, bool adaptive, int i, int ashift=0)
{
   if (ArrayRange(stored,0) != Bars) ArrayResize(stored,Bars);
   if (averagePeriod <=1) return(price);
   int r = Bars-i-1; 
   
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
         double signal    = MathAbs((price-stored[r-endPeriod][res+ashift]));
         double noise     = 0.00000000001;

            for(int k=1; k<endPeriod; k++) noise=noise+MathAbs(price-stored[r-k][res+ashift]);

         averagePeriod = ((signal/noise)*(maxPeriod-minPeriod))+minPeriod;
      }
      
      //
      //
      //
      //
      //
      
      double alpha = (2.0+tconst)/(1.0+tconst+averagePeriod);

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
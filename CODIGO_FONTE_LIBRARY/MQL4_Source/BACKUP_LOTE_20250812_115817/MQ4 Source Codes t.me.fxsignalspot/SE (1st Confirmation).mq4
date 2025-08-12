#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  Lime
#property indicator_color2  Red

extern string TimeFrame       = "current time frame";
extern int    HalfLength      = 35;
extern int    Price           = PRICE_CLOSE;
extern int    EnvelopeShift   = 0;
extern double Deviation       = 0.35;

extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = false;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;
extern string soundfile       = "news.wav";

double UpEnv[];
double DnEnv[];
double tmBuffer[];
double trend[];

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

int init()
{
   IndicatorBuffers(4);
   HalfLength=MathMax(HalfLength,1);
   SetIndexBuffer(0,UpEnv);  SetIndexDrawBegin(0,HalfLength); 
   SetIndexBuffer(1,DnEnv);  SetIndexDrawBegin(1,HalfLength);
   SetIndexBuffer(2,tmBuffer);
   SetIndexBuffer(3,trend);
   
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame=="returnBars";     if (returnBars)     return(0);
      calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
      SetIndexShift(0,EnvelopeShift * timeFrame/Period());
      SetIndexShift(1,EnvelopeShift * timeFrame/Period());

   return(0);
}

int deinit() { return(0); }

int start()
{
   int counted_bars=IndicatorCounted();
   int i,j,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit=MathMin(Bars-1,Bars-counted_bars+HalfLength);
         if (returnBars)  { UpEnv[0] = limit+1; return(0); }
   
   if (calculateValue || timeFrame==Period())
   {
      for (i=limit; i>=0; i--)
      {
         double sum  = (HalfLength+1)*iMA(NULL,0,1,0,MODE_SMA,Price,i);
         double sumw = (HalfLength+1);
         for (j=1, k=HalfLength; j<=HalfLength; j++, k--)
         {
            sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i+j);
            sumw += k;

            if (j<=i)
            {
              sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i-j);
              sumw += k;
            }
      }
      
      tmBuffer[i] = sum/sumw;
      UpEnv[i] = (1+Deviation/100)*tmBuffer[i];
      DnEnv[i] = (1-Deviation/100)*tmBuffer[i];
      trend[i] = trend[i+1];
         if (Close[i]>DnEnv[i] && Close[i+1]<=DnEnv[i+1]) trend[i] = 1;
         if (Close[i]<UpEnv[i] && Close[i+1]>=UpEnv[i+1]) trend[i] =-1;
      }

     manageAlerts();    
     return(0);
     }

     limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
     for(i=limit; i>=0; i--)
     {
        int y = iBarShift(NULL,timeFrame,Time[i]);
           UpEnv[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateTma",HalfLength,Price,EnvelopeShift,Deviation,0,y);
           DnEnv[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateTma",HalfLength,Price,EnvelopeShift,Deviation,1,y);
           trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateTma",HalfLength,Price,EnvelopeShift,Deviation,3,y);
     }      
     manageAlerts();
     return(0);
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

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

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int char1 = StringGetChar(s, length);
         if((char1 > 96 && char1 < 123) || (char1 > 223 && char1 < 256))
                     s = StringSetChar(s, length, char1 - 32);
         else if(char1 > -33 && char1 < 0)
                     s = StringSetChar(s, length, char1 + 224);
   }
   return(s);
}

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"trend");
         if (trend[whichBar] ==-1) doAlert(whichBar,"no trend");
      }  
   }
}

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," - ",timeFrameToString(timeFrame)+" Tma centered envelopes ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Tma centered envelopes "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}
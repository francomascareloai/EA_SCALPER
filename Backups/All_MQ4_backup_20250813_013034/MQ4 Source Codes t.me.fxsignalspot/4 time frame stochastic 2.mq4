//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  LimeGreen
#property indicator_color4  PaleVioletRed
#property indicator_color5  LimeGreen
#property indicator_color6  PaleVioletRed
#property indicator_color7  LimeGreen
#property indicator_color8  PaleVioletRed
#property indicator_minimum 0
#property indicator_maximum 5

extern string TimeFrame1            = "Current time frame";
extern string TimeFrame2            = "next1";
extern string TimeFrame3            = "next2";
extern string TimeFrame4            = "next3";
extern int    StochasticK           = 14;
extern int    StochasticD           =  3;
extern int    StochasticSlowing     =  3;
extern int    StochasticPrice       =  0;
extern int    SignalLineMaMethod    = MODE_SMA;
extern string UniqueID              = "4 Time Stochastic 1";
extern int    LinesWidth            =  0;
extern color  LabelsColor           = DarkGray;
extern int    LabelsHorizontalShift = 5;
extern double LabelsVerticalShift   = 1.5;
extern bool   alertsOn              = false;
extern int    alertsLevel           = 3;
extern bool   alertsMessage         = true;
extern bool   alertsSound           = false;
extern bool   alertsEmail           = false;

double sto1u[];
double sto1d[];
double sto2u[];
double sto2d[];
double sto3u[];
double sto3d[];
double sto4u[];
double sto4d[];

int    timeFrames[4];
bool   returnBars;
string indicatorFileName;

//------------------------------------------------------------------

int init()
{
   SetIndexBuffer(0,sto1u);
   SetIndexBuffer(1,sto1d);
   SetIndexBuffer(2,sto2u);
   SetIndexBuffer(3,sto2d);
   SetIndexBuffer(4,sto3u);
   SetIndexBuffer(5,sto3d);
   SetIndexBuffer(6,sto4u);
   SetIndexBuffer(7,sto4d);
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame1=="returnBars"); if (returnBars) return(0);
      
      for (int i=0; i<8; i++) 
      {
         SetIndexStyle(i,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(i,167); 
      }
      timeFrames[0] = stringToTimeFrame(TimeFrame1);
      timeFrames[1] = stringToTimeFrame(TimeFrame2);
      timeFrames[2] = stringToTimeFrame(TimeFrame3);
      timeFrames[3] = stringToTimeFrame(TimeFrame4);
      alertsLevel = MathMin(MathMax(alertsLevel,3),4);
      IndicatorShortName(UniqueID);
   return(0);
}
int deinit()
{
   for (int t=0; t<4; t++) ObjectDelete(UniqueID+t);
   return(0); 
}
//------------------------------------------------------------------

double trend[][2];
#define _up 0
#define _dn 1
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { sto1u[0] = limit+1; return(0); }

         if (timeFrames[0] != Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[0],indicatorFileName,"returnBars",0,0)*timeFrames[0]/Period()));
         if (timeFrames[1] != Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[1],indicatorFileName,"returnBars",0,0)*timeFrames[1]/Period()));
         if (timeFrames[2] != Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[2],indicatorFileName,"returnBars",0,0)*timeFrames[2]/Period()));
         if (timeFrames[3] != Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[3],indicatorFileName,"returnBars",0,0)*timeFrames[3]/Period()));
         if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);

         bool initialized = false;
         if (!initialized)
         {
            initialized = true;
            int window = WindowFind(UniqueID);
            for (int t=0; t<4; t++)
            {
               string label = timeFrameToString(timeFrames[t]);
               ObjectCreate(UniqueID+t,OBJ_TEXT,window,0,0);
                  ObjectSet(UniqueID+t,OBJPROP_COLOR,LabelsColor);
                  ObjectSet(UniqueID+t,OBJPROP_PRICE1,t+LabelsVerticalShift);
                  ObjectSetText(UniqueID+t,label,8,"Arial");
            }               
         }
         for (t=0; t<4; t++) ObjectSet(UniqueID+t,OBJPROP_TIME1,Time[0]+Period()*LabelsHorizontalShift*60);

   for(i = limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      trend[r][_up] = 0;
      trend[r][_dn] = 0;
      for (int k=0; k<4; k++)
      {
         int y = iBarShift(NULL,timeFrames[k],Time[i]);
            double stochm = iStochastic(NULL,timeFrames[k],StochasticK,StochasticD,StochasticSlowing,SignalLineMaMethod,StochasticPrice,MODE_MAIN  ,y);
            double stochs = iStochastic(NULL,timeFrames[k],StochasticK,StochasticD,StochasticSlowing,SignalLineMaMethod,StochasticPrice,MODE_SIGNAL,y);
            bool isUp = (stochm>stochs);
            switch (k)
            {
               case 0 : if (isUp) { sto1u[i] = k+1; sto1d[i] = EMPTY_VALUE;}  else { sto1d[i] = k+1; sto1u[i] = EMPTY_VALUE; } break;
               case 1 : if (isUp) { sto2u[i] = k+1; sto2d[i] = EMPTY_VALUE;}  else { sto2d[i] = k+1; sto2u[i] = EMPTY_VALUE; } break;
               case 2 : if (isUp) { sto3u[i] = k+1; sto3d[i] = EMPTY_VALUE;}  else { sto3d[i] = k+1; sto3u[i] = EMPTY_VALUE; } break;
               case 3 : if (isUp) { sto4u[i] = k+1; sto4d[i] = EMPTY_VALUE;}  else { sto4d[i] = k+1; sto4u[i] = EMPTY_VALUE; } break;
            }
            if (isUp)
                  trend[r][_up] += 1;
            else  trend[r][_dn] += 1;
      }
   }
   manageAlerts();
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
      int whichBar = Bars-1;
      if (trend[whichBar][_up] >= alertsLevel || trend[whichBar][_dn] >= alertsLevel)
      {
         if (trend[whichBar][_up] >= alertsLevel) doAlert("up"  ,trend[whichBar][_up]);
         if (trend[whichBar][_dn] >= alertsLevel) doAlert("down",trend[whichBar][_dn]);
      }
   }
}

//
//
//
//
//

void doAlert(string doWhat, int howMany)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" "+howMany+" time frames of stochastic are aligned "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" 4 time frame stochastic",message);
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int toInt(double value) { return(value); }
int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   int max = ArraySize(iTfTable)-1, add=0;
   int nxt = (StringFind(tfs,"NEXT1")>-1); if (nxt>0) { tfs = ""+Period(); add=1; }
       nxt = (StringFind(tfs,"NEXT2")>-1); if (nxt>0) { tfs = ""+Period(); add=2; }
       nxt = (StringFind(tfs,"NEXT3")>-1); if (nxt>0) { tfs = ""+Period(); add=3; }

      //
      //
      //
      //
      //
         
      for (int i=max; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[toInt(MathMin(max,i+add))],Period()));
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
      int schar = StringGetChar(s, length);
         if((schar > 96 && schar < 123) || (schar > 223 && schar < 256))
                     s = StringSetChar(s, length, schar - 32);
         else if(schar > -33 && schar < 0)
                     s = StringSetChar(s, length, schar + 224);
   }
   return(s);
}
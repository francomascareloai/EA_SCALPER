//+------------------------------------------------------------------+
//|                                                              rsi |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers  7
#property indicator_color1   DeepSkyBlue
#property indicator_color2   PaleVioletRed
#property indicator_color3   DimGray
#property indicator_color4   DeepSkyBlue
#property indicator_color5   DeepSkyBlue
#property indicator_color6   PaleVioletRed
#property indicator_color7   PaleVioletRed
#property indicator_width1   1
#property indicator_width2   1
#property indicator_width4   3
#property indicator_width5   3
#property indicator_width6   3
#property indicator_width7   3
#property indicator_minimum  -50
#property indicator_maximum   50

//
//
//
//
//

extern string TimeFrame              = "Current time frame";
extern int    Length                 = 14;
extern ENUM_APPLIED_PRICE Price      = PRICE_CLOSE;
extern double RSIModifier            = 1.0;
extern double LevelUp                =  10;
extern double LevelDown              = -10;
extern double SmoothLength           =   5;
extern double SmoothPhase            =   0;
extern bool   ShowHistogram          = false;
extern bool   Interpolate            = true;
extern bool   alertsOn               = false;
extern bool   alertsOnZoneEnter      = true;
extern bool   alertsOnZoneExit       = true;
extern bool   alertsOnCurrent        = true;
extern bool   alertsMessage          = true;
extern bool   alertsSound            = false;
extern bool   alertsEmail            = false;
extern bool   verticalLinesVisible   = false;
extern string verticalLinesID        = "RsiSmoothLines";
extern bool   verticalLinesShowBreak   = true;
extern bool   verticalLinesShowRetrace = false;
extern color  verticalLinesUpColor   = DeepSkyBlue;
extern color  verticalLinesDownColor = PaleVioletRed;
extern ENUM_LINE_STYLE verticalLinesStyle = STYLE_DOT;
extern int    verticalLinesWidth     = 0;

//
//
//
//
//

double rsi[];
double rsiUa[];
double rsiUb[];
double rsiDa[];
double rsiDb[];
double rsiHu[];
double rsiHd[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

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
   IndicatorBuffers(8);
      SetIndexBuffer(0,rsiHu); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,rsiHd); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,rsi);
      SetIndexBuffer(3,rsiUa);
      SetIndexBuffer(4,rsiUb);
      SetIndexBuffer(5,rsiDa);
      SetIndexBuffer(6,rsiDb);
      SetIndexBuffer(7,trend);
         Length = fmax(Length ,1);

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
         
         string PriceType;
         switch(Price)
         {
            case PRICE_CLOSE:    PriceType = "Close";    break;  // 0
            case PRICE_OPEN:     PriceType = "Open";     break;  // 1
            case PRICE_HIGH:     PriceType = "High";     break;  // 2
            case PRICE_LOW:      PriceType = "Low";      break;  // 3
            case PRICE_MEDIAN:   PriceType = "Median";   break;  // 4
            case PRICE_TYPICAL:  PriceType = "Typical";  break;  // 5
            case PRICE_WEIGHTED: PriceType = "Weighted"; break;  // 6
         }      

   //
   //
   //
   //
   //

   SetLevelValue(0,LevelUp);
   SetLevelValue(1,LevelDown);
   IndicatorShortName(timeFrameToString(timeFrame)+" RSI ("+Length+","+PriceType+")");
   return(0);
}

//
//
//
//
//

int deinit()
{
   string lookFor       = verticalLinesID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
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
   int i,k,n,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { rsiHu[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == _Period)
   {
      if (!calculateValue && trend[limit]== 1) CleanPoint(limit,rsiUa,rsiUb);
      if (!calculateValue && trend[limit]==-1) CleanPoint(limit,rsiDa,rsiDb);
      for(i=limit; i >= 0; i--)
      {
         rsi[i] = iSmooth(RSIModifier*(iRSI(NULL,0,Length,Price,i)-50.0),SmoothLength,SmoothPhase,i);
         if (ShowHistogram)
         {
            rsiHu[i] = EMPTY_VALUE;
            rsiHd[i] = EMPTY_VALUE;
            if (rsi[i]>0) rsiHu[i] = rsi[i];
            if (rsi[i]<0) rsiHd[i] = rsi[i];
         } 
         rsiUa[i] = rsiUb[i] = EMPTY_VALUE;
         rsiDa[i] = rsiDb[i] = EMPTY_VALUE;           
         trend[i] = trend[i+1];
            if (rsi[i]>LevelUp)                     trend[i]= 1;
            if (rsi[i]<LevelDown)                   trend[i]=-1;
            if (rsi[i]<LevelUp && rsi[i]>LevelDown) trend[i]= 0;
            if (!calculateValue && trend[i] ==  1) PlotPoint(i,rsiUa,rsiUb,rsi);
            if (!calculateValue && trend[i] == -1) PlotPoint(i,rsiDa,rsiDb,rsi);
         manageLines(i);
      }
      manageAlerts();
      return(0);
   }   
   
   //
   //
   //
   //
   //
   
   limit = fmax(limit,fmin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/_Period));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         rsi[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,RSIModifier,LevelUp,LevelDown,SmoothLength,SmoothPhase,2,y);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,RSIModifier,LevelUp,LevelDown,SmoothLength,SmoothPhase,7,y);
         rsiUa[i] = rsiUb[i] = EMPTY_VALUE;
         rsiDa[i] = rsiDb[i] = EMPTY_VALUE;
         if (ShowHistogram)
         {
            rsiHu[i] = EMPTY_VALUE;
            rsiHd[i] = EMPTY_VALUE;
               if (rsi[i]>0) rsiHu[i] = rsi[i];
               if (rsi[i]<0) rsiHd[i] = rsi[i];
         }            
         manageLines(i);

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
            for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k < n; k++)
            {
               rsi[i+k] = rsi[i] + (rsi[i+n]-rsi[i])*k/n;
               if (rsiHu[i+k]!=EMPTY_VALUE) rsiHu[i+k] = rsi[i+k];
               if (rsiHd[i+k]!=EMPTY_VALUE) rsiHd[i+k] = rsi[i+k];
            }               
   }
   for (i=limit;i>=0;i--)
   {
      if (trend[i]== 1) PlotPoint(i,rsiUa,rsiUb,rsi);
      if (trend[i]==-1) PlotPoint(i,rsiDa,rsiDb,rsi);
   }
   
   //
   //
   //
   //
   //
   
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
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (alertsOnZoneEnter && trend[whichBar]   ==  1) doAlert(whichBar,DoubleToStr(LevelUp,2)  +" broken up");
         if (alertsOnZoneEnter && trend[whichBar]   == -1) doAlert(whichBar,DoubleToStr(LevelDown,2)+" broken down");
         if (alertsOnZoneExit  && trend[whichBar+1] == -1) doAlert(whichBar,DoubleToStr(LevelDown,2)+" broken up");
         if (alertsOnZoneExit  && trend[whichBar+1] ==  1) doAlert(whichBar,DoubleToStr(LevelUp,2)  +" broken down");
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS),"rsi level ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"rsi"),message);
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

void manageLines(int i)
{
   if (!calculateValue && verticalLinesVisible)
   {
         deleteLine(Time[i]);
         if (trend[i]!=trend[i+1])
         {
            if (verticalLinesShowBreak)
            {
               if (trend[i] == 1) drawLine(i,verticalLinesUpColor);
               if (trend[i] ==-1) drawLine(i,verticalLinesDownColor);
            }               
            if (verticalLinesShowRetrace)
            {
               if (trend[i] == 0 && trend[i+1]==-1) drawLine(i,verticalLinesUpColor);
               if (trend[i] == 0 && trend[i+1]== 1) drawLine(i,verticalLinesDownColor);
            }
         }
   }
}               

//
//
//
//
//

void drawLine(int i,color theColor)
{
   string name = verticalLinesID+":"+Time[i];
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_VLINE,0,Time[i],0);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_STYLE,verticalLinesStyle);
         ObjectSet(name,OBJPROP_WIDTH,verticalLinesWidth);
         ObjectSet(name,OBJPROP_BACK,true);
}

//
//
//
//
//

void deleteLine(datetime time)
{
   string lookFor = verticalLinesID+":"+time; ObjectDelete(lookFor);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

double wrk[][10];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
}


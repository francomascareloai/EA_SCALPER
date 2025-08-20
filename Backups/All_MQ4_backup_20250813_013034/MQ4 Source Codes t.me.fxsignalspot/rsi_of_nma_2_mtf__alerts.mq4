//+------------------------------------------------------------------+
//|                                                     smoothed rsi |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers  5
#property indicator_color1   Gray
#property indicator_color2   LimeGreen
#property indicator_color3   LimeGreen
#property indicator_color4   Orange
#property indicator_color5   Orange
#property indicator_width2   3
#property indicator_width3   3
#property indicator_width4   3
#property indicator_width5   3
#property indicator_minimum  -5
#property indicator_maximum  +105

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame       = PERIOD_CURRENT;
extern int                Length          = 14;
extern ENUM_APPLIED_PRICE Price           = PRICE_CLOSE;
extern double             LevelUp         = 80;
extern double             LevelDown       = 20;
extern int                NmaLength       = 14;
extern double             PreSmooth       =  0;
extern double             PreSmoothPhase  =  0;
extern double             PosSmooth       = 10;
extern double             PosSmoothPhase  = 100;
extern bool               alertsOn        = true;
extern bool               alertsOnCurrent = false;
extern bool               alertsMessage   = true;
extern bool               alertsSound     = false;
extern bool               alertsNotify    = true;
extern bool               alertsEmail     = true;
extern bool               Interpolate     = true;

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
double prc[];
double trend[];
string indicatorFileName;
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
   IndicatorBuffers(7);
      SetIndexBuffer(0,rsi);
      SetIndexBuffer(1,rsiUa);
      SetIndexBuffer(2,rsiUb);
      SetIndexBuffer(3,rsiDa);
      SetIndexBuffer(4,rsiDb);
      SetIndexBuffer(5,prc);
      SetIndexBuffer(6,trend);
         Length = MathMax(Length ,1);
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
   
      string addName = "";
         if (PreSmooth>1) addName = "smoothed ";
         
         indicatorFileName = WindowExpertName();
         returnBars        = (TimeFrame==-99);
         TimeFrame         = MathMax(TimeFrame,_Period); 
   IndicatorShortName(timeFrameToString(TimeFrame)+" RSI "+addName+"("+Length+","+PriceType+")");
   return(0);
}

int deinit(){ return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double tBuffer[][2];
#define iPrc 0
#define iMom 1
int start()
{
   int countedBars = IndicatorCounted();
      if(countedBars<0) return(-1);
      if(countedBars>0) countedBars--;
         int i,r,limit = MathMin(Bars-countedBars,Bars-1);
            if (returnBars) { rsi[0] = limit+1; return(0); }
            if (TimeFrame!=Period())
            {
               limit = MathMax(limit,MathMin(Bars,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
               if (trend[limit]== 1) CleanPoint(limit,rsiUa,rsiUb);
               if (trend[limit]==-1) CleanPoint(limit,rsiDa,rsiDb);
                  for(i=limit; i>=0; i--)
                  {
                     int y = iBarShift(NULL,TimeFrame,Time[i]);
                     rsi[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Length,Price,LevelUp,LevelDown,NmaLength,PreSmooth,PreSmoothPhase,PosSmooth,PosSmoothPhase,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,0,y);
                     trend[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Length,Price,LevelUp,LevelDown,NmaLength,PreSmooth,PreSmoothPhase,PosSmooth,PosSmoothPhase,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,6,y);
                     rsiUa[i] = EMPTY_VALUE;
                     rsiUb[i] = EMPTY_VALUE;
                     rsiDa[i] = EMPTY_VALUE;
                     rsiDb[i] = EMPTY_VALUE;

                     //
                     //
                     //
                     //
                     //
                        
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                           
                     //
                     //
                     //
                     //
                     //
                           
                     datetime time = iTime(NULL,TimeFrame,y);
                        for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
                        for(int l = 1; l < n && (i+l<Bars) && (i+n)<Bars; l++)
                           rsi[i+l]  = rsi[i]  + (rsi[i+n] - rsi[i])*l/n;
                  }                           
                  for(i=limit; i>=0; i--)
                  {
                     if (trend[i] ==  1) PlotPoint(i,rsiUa,rsiUb,rsi);
                     if (trend[i] == -1) PlotPoint(i,rsiDa,rsiDb,rsi);
                  }                              
         return(0);
      }

      //
      //
      //
      //
      //
      //
      
      if (ArrayRange(tBuffer,0) != Bars) ArrayResize(tBuffer,Bars);
      if (trend[limit]== 1) CleanPoint(limit,rsiUa,rsiUb);
      if (trend[limit]==-1) CleanPoint(limit,rsiDa,rsiDb);
      for(i=limit, r=Bars-i-1; i >= 0; i--,r++)
      {
         double rawPrice = iMA(NULL,0,1,0,MODE_SMA,Price,i);
         tBuffer[r][iPrc] = iSmooth(rawPrice,PreSmooth,PreSmoothPhase,i,0);
         tBuffer[r][iMom] = tBuffer[r][iPrc]-tBuffer[r-1][iPrc];
   
         //
         //
         //
         //
         //
                      
            double momRatio = 0.00;
            double sumMomen = 0.00;
            double ratio    = 0.00;
      
            for (int k = 0; k<NmaLength; k++)
            {
               sumMomen += MathAbs(tBuffer[r-k][iMom]);
               momRatio +=         tBuffer[r-k][iMom]*(MathSqrt(k+1)-MathSqrt(k));
            }
            if (sumMomen != 0) ratio = MathAbs(momRatio)/sumMomen;
      
         //
         //
         //
         //
         //
                 
         prc[i] = iSmooth(prc[i+1]+ratio*(rawPrice-prc[i+1]),PosSmooth,PosSmoothPhase,i,1);
      }
      for(i=limit; i >= 0; i--)
      {
         rsi[i]   = iRSIOnArray(prc,0,Length,i);
         rsiUa[i] = EMPTY_VALUE;
         rsiUb[i] = EMPTY_VALUE;
         rsiDa[i] = EMPTY_VALUE;
         rsiDb[i] = EMPTY_VALUE;

         //
         //
         //
         //
         //
         
         trend[i] = trend[i+1];
            if (rsi[i]>LevelUp)                     trend[i]= 1;
            if (rsi[i]<LevelDown)                   trend[i]=-1;
            if (rsi[i]<LevelUp && rsi[i]>LevelDown) trend[i]= 0;
            if (trend[i] ==  1) PlotPoint(i,rsiUa,rsiUb,rsi);
            if (trend[i] == -1) PlotPoint(i,rsiDa,rsiDb,rsi);
      }
      
      //
      //
      //
      //
      //
      
      if (alertsOn)
      {
         if (alertsOnCurrent)
              int whichBar = 0;
         else     whichBar = 1; 
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1)                          doAlert(whichBar,"crossed upper level up");
            if (trend[whichBar] ==-1)                          doAlert(whichBar,"crossed lower level down");
            if (trend[whichBar] == 0 && trend[whichBar+1]== 1) doAlert(whichBar,"crossed upper level down");
            if (trend[whichBar] == 0 && trend[whichBar+1]==-1) doAlert(whichBar,"crossed lower level up");
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double wrk[][20];
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
   if (length<=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars); 
   
   int r = Bars-i-1; s *= 10;
      if (r==0) { for(int k=0; k<7; k++) wrk[0][k+s]=price; for(; k<10; k++) wrk[0][k+s]=0; return(price); }

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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

           message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," RSI of nma ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), " RSI of nma "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

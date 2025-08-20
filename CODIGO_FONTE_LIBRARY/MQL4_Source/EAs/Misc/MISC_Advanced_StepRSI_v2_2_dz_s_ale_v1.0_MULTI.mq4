//------------------------------------------------------------------
#property copyright "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 LimeGreen
#property indicator_color2 Orange
#property indicator_color3 DarkGray
#property indicator_color4 DarkGreen
#property indicator_color5 Crimson
#property indicator_color6 LimeGreen  
#property indicator_color7 DimGray
#property indicator_color8 PaleVioletRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_style6 STYLE_DOT
#property indicator_style7 STYLE_DOT
#property indicator_style8 STYLE_DOT

//
//
//
//
//

#import "dynamicZone.dll"
   double dzBuyP(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i,double precision);
   double dzSellP(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i,double precision);
#import

//
//
//
//
//

enum enRsiTypes
{
   rsi_rsi,  // Regular RSI
   rsi_wil,  // Wilders RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
};


extern string             TimeFrame        = "Current time frame";
extern enRsiTypes         RsiType          = rsi_rsx;
extern int                PeriodRSI              = 14;
extern ENUM_APPLIED_PRICE Price                  = PRICE_CLOSE;
extern int                StepSizeFast           =  5;
extern int                StepSizeSlow           = 15;
extern double             OverSold               = 10;
extern double             OverBought             = 90;
input int                 DzLookBackBars         = 34;             // Dynamic zone look back
input double              DzStartBuyProbability  = 0.05;           // Dynamic zone buy probability
input double              DzStartSellProbability = 0.05;           // Dynamic zone sell probability
extern bool               alertsOn               = false;    // Turn alerts on?
extern bool               alertsOnCurrent        = true;     // Alerts on current (still opened) bar?
extern bool               alertsMessage          = true;     // Alerts should show pop-up message?
extern bool               alertsPushNotif        = false;    // Alerts should send push notification?
extern bool               alertsSound            = false;    // Alerts should play a sound?
extern bool               alertsEmail            = false;    // Alerts should send email?
extern bool               arrowsVisible          = false;            // Arrows visible?
extern bool               arrowsOnNewest         = false;            // Arrows drawn on newst bar of higher time frame bar?
extern string             arrowsIdentifier       = "asesi Arrows1";  // Unique ID for arrows
extern double             arrowsUpperGap         = 1.0;              // Upper arrow gap
extern double             arrowsLowerGap         = 1.0;              // Lower arrow gap
extern color              arrowsUpColor          = LimeGreen;        // Up arrow color
extern color              arrowsDnColor          = Orange;           // Down arrow color
extern int                arrowsUpCode           = 241;              // Up arrow code
extern int                arrowsDnCode           = 242;              // Down arrow code
extern bool               Interpolate            = true;

double Line1Buffer[];
double Line2Buffer[];
double Line3Buffer[];
double trendf[];
double trends[];
double arrup[];
double arrdn[];
double trend[];
double maxf[];
double minf[];
double maxs[];
double mins[];
double levelUp[];
double levelMi[];
double levelDn[];

string indicatorFileName;
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
   if (!IsDllsAllowed())
   {
      Alert("and then attach it to the chart again");
      Alert("Please enable DLL imports in the indicator properties");
      Alert("This indicator needs dlls to work");
      return(INIT_FAILED);
   }
   IndicatorBuffers(15);
   SetIndexBuffer(0,Line2Buffer); SetIndexLabel(0,"StepRSI fast");
   SetIndexBuffer(1,Line3Buffer); SetIndexLabel(1,"StepRSI slow");
   SetIndexBuffer(2,Line1Buffer); SetIndexLabel(2,"RSI");
   SetIndexBuffer(3,arrup);       SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,159);
   SetIndexBuffer(4,arrdn);       SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,159);
   SetIndexBuffer(5,levelUp);
   SetIndexBuffer(6,levelMi);
   SetIndexBuffer(7,levelDn);
   SetIndexBuffer(8,trendf);
   SetIndexBuffer(9,trends);
   SetIndexBuffer(10,minf);
   SetIndexBuffer(11,mins);
   SetIndexBuffer(12,maxf);
   SetIndexBuffer(13,maxs);
   SetIndexBuffer(14,trend);
   
      timeFrame         = stringToTimeFrame(TimeFrame);   
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame == "returnBars");
   
   IndicatorShortName(timeFrameToString(timeFrame)+" advanced step "+getRsiName((int)RsiType)+" ("+PeriodRSI+","+StepSizeFast+","+StepSizeSlow+")");
   return(0);
}
int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars)  { Line2Buffer[0] = limit+1; return(0);  } 
                  if (timeFrame!=Period())
                  {
                     limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
                     for(int i=limit; i>=0; i--)
                     {
                        int n,l,x,y = iBarShift(NULL,timeFrame,Time[i]);
                           Line2Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,0,y);
                           Line3Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,1,y);
                           Line1Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,2,y);
                           levelUp[i]     = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,5,y);
                           levelMi[i]     = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,6,y);
                           levelDn[i]     = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,7,y);
                           trend[i]       = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,14,y);
                           arrup[i]       = EMPTY_VALUE;
                           arrdn[i]       = EMPTY_VALUE;
                           if (!Interpolate || (i>0 && y==iBarShift(NULL,timeFrame,Time[i-1]))) continue;
                           datetime time = iTime(NULL,timeFrame,y);
                              for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
                              for(l = 1; l < n && (i+l<Bars) && (i+n)<Bars; l++)
                              {
                                 Line2Buffer[i+l] = Line2Buffer[i] + (Line2Buffer[i+n]-Line2Buffer[i])*l/n;
                                 Line3Buffer[i+l] = Line3Buffer[i] + (Line3Buffer[i+n]-Line3Buffer[i])*l/n;
                                 Line1Buffer[i+l] = Line1Buffer[i] + (Line1Buffer[i+n]-Line1Buffer[i])*l/n;
                                 levelUp[i+l]     = levelUp[i]     + (levelUp[i+n]    -levelUp[i])    *l/n;
                                 levelMi[i+l]     = levelMi[i]     + (levelMi[i+n]    -levelMi[i])    *l/n;
                                 levelDn[i+l]     = levelDn[i]     + (levelDn[i+n]    -levelDn[i])    *l/n;
                              }                                 
                        }                           
                        for(i=limit; i>=0; i--)
                        {
                           y = iBarShift(NULL,timeFrame,Time[i]);
                           x = iBarShift(NULL,timeFrame,Time[i+1]); if (arrowsOnNewest) x = iBarShift(NULL,timeFrame,Time[i-1]);
                              if (x!=y)
                              {
                                 arrup[i] = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,3,y);
                                 arrdn[i] = iCustom(NULL,timeFrame,indicatorFileName,"",RsiType,PeriodRSI,Price,StepSizeFast,StepSizeSlow,OverSold,OverBought,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,4,y);
                              }
                        }
                        return(0);
                  }

   //
   //
   //
   //
   //
   
   for(i=limit; i>=0; i--)
   {	
      double rsi=iRsi(iMA(NULL,0,1,0,MODE_SMA,Price,i),PeriodRSI,RsiType,i);
   	   maxf[i] = rsi+2*StepSizeFast;
	      minf[i] = rsi-2*StepSizeFast;
   	   maxs[i] = rsi+2*StepSizeSlow;
	      mins[i] = rsi-2*StepSizeSlow;
         if (i>(Bars-2)) continue;

	      trendf[i] = trendf[i+1];
	         if (rsi > maxf[i+1]) trendf[i] = 1; 
	         if (rsi < minf[i+1]) trendf[i] =-1;
	         if (trendf[i]>0 && minf[i]<minf[i+1]) minf[i]=minf[i+1];
	         if (trendf[i]<0 && maxf[i]>maxf[i+1]) maxf[i]=maxf[i+1];

	      trends[i] = trends[i+1];
	         if (rsi>maxs[i+1]) trends[i] = 1; 
	         if (rsi<mins[i+1]) trends[i] =-1;
	         if (trends[i]>0 && mins[i]<mins[i+1]) mins[i]=mins[i+1];
	         if (trends[i]<0 && maxs[i]>maxs[i+1]) maxs[i]=maxs[i+1];
	  
	         Line1Buffer[i] = rsi;
	         levelUp[i] = dzBuyP (Line1Buffer,DzStartBuyProbability, DzLookBackBars,Bars,i,0.0001);
            levelDn[i] = dzSellP(Line1Buffer,DzStartSellProbability,DzLookBackBars,Bars,i,0.0001);
            levelMi[i] = dzSellP(Line1Buffer,0.5,                   DzLookBackBars,Bars,i,0.0001);
            
	         if (trendf[i]>0) Line2Buffer[i]=minf[i]+StepSizeFast;
	         if (trendf[i]<0) Line2Buffer[i]=maxf[i]-StepSizeFast;
	         if (trends[i]>0) Line3Buffer[i]=mins[i]+StepSizeSlow;
	         if (trends[i]<0) Line3Buffer[i]=maxs[i]-StepSizeSlow;
	         
	         trend[i] = trend[i+1];
            arrup[i] = EMPTY_VALUE;
            arrdn[i] = EMPTY_VALUE;
	            if (Line2Buffer[i]>Line3Buffer[i]) trend[i] =  1;
	            if (Line2Buffer[i]<Line3Buffer[i]) trend[i] = -1;
               if (trend[i] != trend[i+1])
               {
                  if (trend[i] == 1) arrup[i] = MathMin(MathMin(Line1Buffer[i],Line2Buffer[i]),Line3Buffer[i]);
                  if (trend[i] ==-1) arrdn[i] = MathMax(MathMax(Line1Buffer[i],Line2Buffer[i]),Line3Buffer[i]);
               }
               if (arrowsVisible)
               {
                 string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
                     if (trend[i] != trend[i+1])
                     {
                        if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                        if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
                     }
               }
   }
   manageAlerts();
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

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      datetime time = Time[i]; if (arrowsOnNewest) time += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,time,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs) {
   StringToUpper(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar]== 1) doAlert(whichBar,"trend changed to up");
         if (trend[whichBar]==-1) doAlert(whichBar,"trend changed to down");
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

       message = Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+"advanced step "+getRsiName((int)RsiType)+" "+doWhat;
          if (alertsMessage)   Alert(message);
          if (alertsEmail)     SendMail(StringConcatenate(Symbol(),"advanced step "+getRsiName((int)RsiType)+" "),message);
          if (alertsPushNotif) SendNotification(StringConcatenate(Symbol(),"advanced step "+getRsiName((int)RsiType)+" "+message));
          if (alertsSound)     PlaySound("alert2.wav");
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
//

string rsiMethodNames[] = {"rsi","Wilders rsi","rsx","Cuttler RSI"};
string getRsiName(int method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=MathMax(MathMin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

double workRsi[][13];
#define _price  0
#define _change 1
#define _changa 2

double iRsi(double price, double period, int rsiMode, int i, int instanceNo=0)
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
      case 0:
         double alpha = 1.0/period; 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
         
      //
      //
      //
      //
      //
      
      case 1 :
         workRsi[r][z+1] = iSmma(0.5*(MathAbs(workRsi[r][z+_price]-workRsi[r-1][z+_price])+(workRsi[r][z+_price]-workRsi[r-1][z+_price])),0.5*(period-1),Bars-i-1,instanceNo*2+0);
         workRsi[r][z+2] = iSmma(0.5*(MathAbs(workRsi[r][z+_price]-workRsi[r-1][z+_price])-(workRsi[r][z+_price]-workRsi[r-1][z+_price])),0.5*(period-1),Bars-i-1,instanceNo*2+1);
         if((workRsi[r][z+1] + workRsi[r][z+2]) != 0) 
               return(100.0 * workRsi[r][z+1]/(workRsi[r][z+1] + workRsi[r][z+2]));
         else  return(50);

      //
      //
      //
      //
      //

      case 2 :     
         double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
         if (r<period) { for (k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

         //
         //
         //
         //
         //
      
         double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
         double moa = MathAbs(mom);
         for (k=0; k<3; k++)
         {
            int kk = k*2;
            workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
            workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
            workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
            workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
         }
         if (moa != 0)
              return(MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00)); 
         else return(50);
            
      //
      //
      //
      //
      //
      
      case 3 :
         double sump = 0;
         double sumn = 0;
         for (k=0; k<period; k++)
         {
            double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
               if (diff > 0) sump += diff;
               if (diff < 0) sumn -= diff;
         }
         if (sumn > 0)
               return(100.0-100.0/(1.0+sump/sumn));
         else  return(50);
   } 
   return(0);
}

//
//
//
//
//
//

double workSmma[][2];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//+------------------------------------------------------------------+
//|                                                 dynamic zone cci |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  DeepSkyBlue
#property indicator_color2  LimeGreen
#property indicator_color3  Red
#property indicator_color4  DimGray
#property indicator_width1  2
#property indicator_style4  STYLE_DOT

//
//
//
//
//

#import "dynamicZone.dll"
   double dzBuy(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i );
   double dzSell(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i );
#import

//
//
//
//
//

extern int    CciLength              = 10;
extern int    CciPrice               = PRICE_TYPICAL;
extern int    CciSmooth              = 3;
extern int    DzLookBackBars         = 70;
extern double DzStartBuyProbability  = 0.05;
extern double DzStartSellProbability = 0.05;

extern bool   alertsOn               = false;
extern bool   alertsOnZeroCross      = false;
extern bool   alertsOnUpLowCross     = true;
extern bool   alertsOnCurrent        = true;
extern bool   alertsMessage          = true;
extern bool   alertsSound            = false;
extern bool   alertsEmail            = false;

extern string arrowsIdentifier       = "Dz cci Arrows";
extern bool   arrowsVisible          = TRUE;
extern double arrowsDisplacement     = 1.0;

extern bool   arrowsOnZeroCross      = false;
extern color  arrowsZeroCrossUpColor = Lime;
extern color  arrowsZeroCrossDnColor = Red;
extern int    arrowsZeroCrossUpCode  = 233;
extern int    arrowsZeroCrossDnCode  = 234;
extern int    arrowsZeroCrossUpSize  = 1;
extern int    arrowsZeroCrossDnSize  = 1;

extern bool   arrowsOnUpLowCross     = true;
extern color  arrowsUpLowCrossUpColor= PaleGreen;
extern color  arrowsUpLowCrossDnColor= Red;
extern int    arrowsUpLowCrossUpCode = 233;
extern int    arrowsUpLowCrossDnCode = 234;
extern int    arrowsUpLowCrossUpSize = 1;
extern int    arrowsUpLowCrossDnSize = 1;  

//
//
//
//
//

double cci[];
double ccs[];
double ccw[];
double cen[];
double bli[];
double sli[];
double trend1[];
double trend2[];
double alpha;

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
   SetIndexBuffer(0,ccs);
   SetIndexBuffer(1,bli);
   SetIndexBuffer(2,sli);
   SetIndexBuffer(3,cen);
   SetIndexBuffer(4,cci);
   SetIndexBuffer(5,ccw);
   SetIndexBuffer(6,trend1);
   SetIndexBuffer(7,trend2);

   //
   //
   //
   //
   //
   
   string PriceType;
      switch(CciPrice)
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

   CciLength = MathMax(CciLength ,1);
       alpha = 2.0 /(1.0+MathSqrt(CciSmooth));
   
   IndicatorShortName ("Dynamic zone CCI ("+CciLength+","+PriceType+","+DzLookBackBars+","+DoubleToStr(DzStartBuyProbability,3)+","+DoubleToStr(DzStartSellProbability,3)+")");
   return(0);
}
int deinit()
{
   if (arrowsVisible) deleteArrows();
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
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
   //

   for(i=limit; i >= 0; i--)
   {
      cci[i] = iCCI(NULL,0,CciLength,CciPrice,i);
         if (i==Bars-1)
         {
            ccw[i] = cci[i];
            ccs[i] = cci[i];
            continue;
         }
      
      //
      //
      //
      //
      //
      
      if (CciSmooth>1)
      {
            ccw[i] = ccw[i+1]+alpha*(cci[i]-ccw[i+1]);
            ccs[i] = ccs[i+1]+alpha*(ccw[i]-ccs[i+1]);
      }
      else  ccs[i] = cci[i];         
      bli[i] = dzBuy (ccs, DzStartBuyProbability,  DzLookBackBars, Bars, i);
      sli[i] = dzSell(ccs, DzStartSellProbability, DzLookBackBars, Bars, i);
      cen[i] = dzSell(ccs, 0.5,                    DzLookBackBars, Bars, i);
      trend1[i] = trend1[i+1];
      trend2[i] = trend2[i+1];
         if (ccs[i]>cen[i])                        trend1[i] =  1;
         if (ccs[i]<cen[i])                        trend1[i] = -1;
         if (ccs[i]>bli[i] && ccs[i+1]<= bli[i+1]) trend2[i] =  1;
         if (ccs[i]<sli[i] && ccs[i+1]>= sli[i+1]) trend2[i] = -1;
         manageArrow(i);
   }
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

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,0,whichBar));
      
      //
      //
      //
      //
      //
      
      static datetime time1 = 0;
      static string   mess1 = "";
         if (alertsOnZeroCross && trend1[whichBar] != trend1[whichBar+1])
         {
            if (trend1[whichBar] ==  1) doAlert(time1,mess1,whichBar,"  zero line cross");
            if (trend1[whichBar] == -1) doAlert(time1,mess1,whichBar,"  zero line cross");
         }            
      static datetime time2 = 0;
      static string   mess2 = "";
         if (alertsOnUpLowCross && trend2[whichBar] != trend2[whichBar+1])
         {
            if (trend2[whichBar] ==  1) doAlert(time2,mess2,whichBar," lower line cross up");
            if (trend2[whichBar] == -1) doAlert(time2,mess2,whichBar," upper line cross down");
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," DZ CCI ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," DZ CCI "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//
//
//
//
//

void manageArrow(int i)
{
   if (arrowsVisible)
   {
      deleteArrow(Time[i]);
      if (arrowsOnZeroCross && trend1[i]!= trend1[i+1])
      {
         if (trend1[i] == 1) drawArrow(i,arrowsZeroCrossUpColor,arrowsZeroCrossUpCode,arrowsZeroCrossUpSize,false);
         if (trend1[i] ==-1) drawArrow(i,arrowsZeroCrossDnColor,arrowsZeroCrossDnCode,arrowsZeroCrossDnSize, true);
      }
      if (arrowsOnUpLowCross && trend2[i]!= trend2[i+1])
      {
         if (trend2[i] == 1) drawArrow(i,arrowsUpLowCrossUpColor,arrowsUpLowCrossUpCode,arrowsUpLowCrossUpSize,false);
         if (trend2[i] ==-1) drawArrow(i,arrowsUpLowCrossDnColor,arrowsUpLowCrossDnCode,arrowsUpLowCrossDnSize, true);
      }
      
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,int theSize, bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,   theColor);
         ObjectSet(name,OBJPROP_WIDTH,    theSize);      
         
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsDisplacement * gap);
         else  ObjectSet(name,OBJPROP_PRICE1, Low[i] - arrowsDisplacement * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}


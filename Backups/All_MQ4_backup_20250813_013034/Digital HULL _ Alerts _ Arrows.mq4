//------------------------------------------------------------------
// original idea and first version using hull by sohocool
// this version by mladen
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  PaleVioletRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

//
//
//
//
//

extern string TimeFrame        = "Current time frame";  
extern int    hullPeriod       = 12;
extern int    appliedPrice     = PRICE_MEDIAN;
extern int    atrPeriod        = 12;
extern double atrMultiplier    = 0.66;
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;
extern bool   ShowArrows       = false;
extern string arrowsIdentifier = "sthull Arrows1";
extern double arrowsUpperGap   = 1.0;
extern double arrowsLowerGap   = 1.0;
extern color  arrowsUpColor    = LimeGreen;
extern color  arrowsDnColor    = Red;
extern int    arrowsUpCode     = 241;
extern int    arrowsDnCode     = 242;



//
//
//
//
//

double Trend[];
double TrendDa[];
double TrendDb[];
double Up[];
double Dn[];
double Direction[];

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
   IndicatorBuffers(6);
      SetIndexBuffer(0,Trend);
      SetIndexBuffer(1,TrendDa);
      SetIndexBuffer(2,TrendDb);
      SetIndexBuffer(3,Up);
      SetIndexBuffer(4,Dn);
      SetIndexBuffer(5,Direction);
      
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
   return(0);
}
int deinit() 
{  
   deleteArrows(); 
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
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { Trend[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      if (Direction[limit]==-1) CleanPoint(limit,TrendDa,TrendDb);
      for(int i=limit; i>=0; i--)
      {
         double atr    = iATR(NULL,0,atrPeriod,i);
         double cprice = Close[i];
         double mprice = iHull(iMA(NULL,0,1,0,MODE_SMA,appliedPrice,i),hullPeriod,i);
                Up[i]  = mprice+atrMultiplier*atr;
                Dn[i]  = mprice-atrMultiplier*atr;
         
         //
         //
         //
         //
         //

         TrendDa[i] = EMPTY_VALUE;
         TrendDb[i] = EMPTY_VALUE;
         Direction[i] = Direction[i+1];
            if (cprice > Up[i+1]) Direction[i] =  1;
            if (cprice < Dn[i+1]) Direction[i] = -1;
            if (Direction[i] > 0) { Dn[i] = MathMax(Dn[i],Dn[i+1]); Trend[i] = Dn[i]; }
            else                  { Up[i] = MathMin(Up[i],Up[i+1]); Trend[i] = Up[i]; }
            if (Direction[i]==-1) PlotPoint(i,TrendDa,TrendDb,Trend);
            
            //
            //
            //
            //
            //
       
            if (ShowArrows)
            {
               deleteArrow(Time[i]);
               if (Direction[i] != Direction[i+1])
               {
                 if (Direction[i] == 1)  drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                 if (Direction[i] ==-1)  drawArrow(i,arrowsDnColor,arrowsDnCode, true);
               }
            }
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
   if (Direction[limit]==-1) CleanPoint(limit,TrendDa,TrendDb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Trend[i]     = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",hullPeriod,appliedPrice,atrPeriod,atrMultiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,0,y);
         Direction[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",hullPeriod,appliedPrice,atrPeriod,atrMultiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,5,y);
         TrendDa[i]   = EMPTY_VALUE;
         TrendDb[i]   = EMPTY_VALUE;
         if (Direction[i]==-1) PlotPoint(i,TrendDa,TrendDb,Trend);
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
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
         }
      else {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
         }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
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

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar=0;
      if (Direction[whichBar] != Direction[whichBar+1])
      {
         if (Direction[whichBar] ==  1) doAlert("up"  );
         if (Direction[whichBar] == -1) doAlert("down");
      }
   }
}

//
//
//
//
//

void doAlert(string doWhat)
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

       message =  timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" super trend changed to "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" super trend",message);
          if (alertsSound)   PlaySound("alert2.wav");
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

double workHull[][2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workHull,0)!= Bars) ArrayResize(workHull,Bars); r=Bars-r-1;

   //
   //
   //
   //
   //

      int HmaPeriod  = MathMax(period,2);
      int HalfPeriod = MathFloor(HmaPeriod/2);
      int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
      double hma,hmw,weight; instanceNo *= 2;

         workHull[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         hmw = HalfPeriod; hma = hmw*price; 
            for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
            {
               weight = HalfPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];  
            }             
            workHull[r][instanceNo+1] = 2.0*hma/hmw;

         hmw = HmaPeriod; hma = hmw*price; 
            for(k=1; k<period && (r-k)>=0; k++)
            {
               weight = HmaPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];
            }             
            workHull[r][instanceNo+1] -= hma/hmw;

         //
         //
         //
         //
         //
         
         hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
            for(k=1; k<HullPeriod && (r-k)>=0; k++)
            {
               weight = HullPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][1+instanceNo];  
            }
   return(hma/hmw);
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

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
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
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
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



//+------------------------------------------------------------------+
//|                                                  cmf 4 color mtf |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     Red
#property indicator_color2     DarkGreen
#property indicator_color3     LimeGreen
#property indicator_color4     Maroon
#property indicator_color5     DimGray
#property indicator_width1     5
#property indicator_width2     5
#property indicator_width3     5
#property indicator_width4     5
#property indicator_width5     2
#property indicator_level3     0
#property indicator_levelcolor MediumOrchid

//
//
//
//
//

extern string TimeFrame                  = "Current time frame";
extern double CmfPeriod                  = 15;
extern double T3Hot                      = 1.0;
extern bool   T3Original                 = false;
extern double levelOs                    = -0.20;
extern double levelOb                    = 0.20; 
extern bool   HistogramOnSlope           = true;

extern bool   alertsOn                   = false;
extern bool   alertsOnSlope              = false;
extern bool   alertsOnCurrent            = false;
extern bool   alertsMessage              = false;
extern bool   alertsSound                = false;
extern bool   alertsEmail                = false;

extern bool   arrowsVisible              = true;
extern string arrowsIdentifier           = "cmf Arrows1";
extern double arrowsUpDisplacement       = 0.5;
extern double arrowsDnDisplacement       = 0.5;

extern bool   arrowsOnSlope              = True;
extern color  arrowsOnSlopeUpColor       = Blue;
extern color  arrowsOnSlopeDnColor       = Red;
extern int    arrowsOnSlopeUpCode        = 241;
extern int    arrowsOnSlopeDnCode        = 242;
extern int    arrowsOnSlopeUpSize        = 2;
extern int    arrowsOnSlopeDnSize        = 2;

extern bool   arrowsOnZeroCross          = True;
extern color  arrowsOnOnZeroCrossUpColor = White;
extern color  arrowsOnOnZeroCrossDnColor = White;
extern int    arrowsOnOnZeroCrossUpCode  = 233;
extern int    arrowsOnOnZeroCrossDnCode  = 234;
extern int    arrowsOnOnZeroCrossUpSize  = 3;
extern int    arrowsOnOnZeroCrossDnSize  = 3;

//
//
//
//
//

double cmf[];
double cmfUpa[];
double cmfUpb[];
double cmfDna[];
double cmfDnb[];
double trend[];
double slope[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
// 
//
//
//
//

int init()
{
   IndicatorBuffers(7);
   SetIndexBuffer(0,cmfDna); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,cmfDnb); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,cmfUpa); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,cmfUpb); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,cmf);
   SetIndexBuffer(5,trend);
   SetIndexBuffer(6,slope);
   
   SetLevelValue(0,levelOs);
   SetLevelValue(1,levelOb);
   SetLevelValue(2,0);
   
         //
         //
         //
         //
         //
      
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame=="returnBars";        if (returnBars)     return(0);
         calculateValue    = TimeFrame=="calculateValue";    if (calculateValue) return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);

         //
         //
         //
         //
         //
            
   
   IndicatorShortName(timeFrameToString(timeFrame)+" Cmf T3 Smoothed");
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

//
//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { cmfDna[0] = limit+1; return(0); }

   
   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {
      for (i=limit;i>=0;i--)
      {
          if((High[i]-Low[i]) != 0 && Volume[i] !=0)
               cmf[i] = iT3((Volume[i]*(Close[i]-Open[i])/(High[i]-Low[i]))/Volume[i],CmfPeriod,T3Hot,T3Original,i);
          else cmf[i] = iT3(0,                                                         CmfPeriod,T3Hot,T3Original,i);
               
               //
               //
               //
               //
               //
               
               cmfDna[i] = EMPTY_VALUE;
               cmfDnb[i] = EMPTY_VALUE;
               cmfUpa[i] = EMPTY_VALUE;
               cmfUpb[i] = EMPTY_VALUE; 
               trend[i]  = trend[i+1];
               slope[i]  = slope[i+1];
                if (cmf[i] > 0)        trend[i] =  1;
                if (cmf[i] < 0)        trend[i] = -1;
                if (cmf[i] > cmf[i+1]) slope[i] =  1;
                if (cmf[i] < cmf[i+1]) slope[i] = -1;
         
                                     
                if (HistogramOnSlope)
                {
                   if (trend[i]== 1 && slope[i] == 1) cmfUpa[i] = cmf[i];
                   if (trend[i]== 1 && slope[i] ==-1) cmfUpb[i] = cmf[i];
                   if (trend[i]==-1 && slope[i] ==-1) cmfDna[i] = cmf[i];
                   if (trend[i]==-1 && slope[i] == 1) cmfDnb[i] = cmf[i];
                }
                else
                {                  
                   if (trend[i]== 1) cmfUpa[i] = cmf[i];
                   if (trend[i]==-1) cmfDna[i] = cmf[i];
               }
               manageArrow(i);
               
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
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         cmf[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",CmfPeriod,T3Hot,T3Original,4,y);
         trend[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",CmfPeriod,T3Hot,T3Original,5,y);
         slope[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",CmfPeriod,T3Hot,T3Original,6,y);
         cmfDna[i] = EMPTY_VALUE;
         cmfDnb[i] = EMPTY_VALUE;
         cmfUpa[i] = EMPTY_VALUE;
         cmfUpb[i] = EMPTY_VALUE;
         manageArrow(i);

   }
        
   for (i=limit;i>=0;i--)
   {
      if (HistogramOnSlope)
      {
         if (trend[i]== 1 && slope[i] == 1) cmfUpa[i] = cmf[i];
         if (trend[i]== 1 && slope[i] ==-1) cmfUpb[i] = cmf[i];
         if (trend[i]==-1 && slope[i] ==-1) cmfDna[i] = cmf[i];
         if (trend[i]==-1 && slope[i] == 1) cmfDnb[i] = cmf[i];
      }
      else
      {                  
         if (trend[i]== 1) cmfUpa[i] = cmf[i];
         if (trend[i]==-1) cmfDna[i] = cmf[i];
      } 
                               
   }
   
   manageAlerts();
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

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      
      //
      //
      //
      //
      //
      
      if (alertsOnSlope)
      {
         if (slope[whichBar] != slope[whichBar+1])
         {
            if (slope[whichBar] == 1) doAlert(whichBar,"slope changed to up");
            if (slope[whichBar] ==-1) doAlert(whichBar,"slope changed to down");
         }         
      }
      else
      {
         if (trend[whichBar] != trend[whichBar-1])
         {
            if (trend[whichBar] == 1) doAlert(whichBar,"crossed zero line up");
            if (trend[whichBar] ==-1) doAlert(whichBar,"crossed zero line down");
         }         
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

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Chalkin Money Flow ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Chalkin Money Flow "),message);
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

void manageArrow(int i)
{
   if (arrowsVisible)
   {
      deleteArrow(Time[i]);
      if (arrowsOnSlope && slope[i] != slope[i+1])
      {
         if (slope[i] == 1) drawArrow(i,arrowsOnSlopeUpColor,arrowsOnSlopeUpCode,arrowsOnSlopeUpSize,false);
         if (slope[i] ==-1) drawArrow(i,arrowsOnSlopeDnColor,arrowsOnSlopeDnCode,arrowsOnSlopeDnSize,true);
      }
      
      if (arrowsOnZeroCross && trend[i]!= trend[i+1])
      {
         if (trend[i] == 1) drawArrow(i,arrowsOnOnZeroCrossUpColor,arrowsOnOnZeroCrossUpCode,arrowsOnOnZeroCrossUpSize,false);
         if (trend[i] ==-1) drawArrow(i,arrowsOnOnZeroCrossDnColor,arrowsOnOnZeroCrossDnCode,arrowsOnOnZeroCrossDnSize,true);
      }   
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,int theSize,bool up)
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
         ObjectSet(name,OBJPROP_WIDTH,theSize ); 
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpDisplacement * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsDnDisplacement * gap);
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   StringToUpper(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

double workT3[][6];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int forInstance=0)
{
   if (ArrayRange(workT3,0) !=Bars)                  ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (forInstance+1)) ArrayResize(workT3Coeffs,forInstance+1);

   if (workT3Coeffs[forInstance][_period] != period)
   {
     workT3Coeffs[forInstance][_period] = period;
        double a = hot;
            workT3Coeffs[forInstance][_c1] = -a*a*a;
            workT3Coeffs[forInstance][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[forInstance][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[forInstance][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[forInstance][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[forInstance][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = forInstance*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
      }
   else
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[forInstance][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[forInstance][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[forInstance][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[forInstance][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[forInstance][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[forInstance][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[forInstance][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[forInstance][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[forInstance][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[forInstance][_c4]*workT3[r][2+buffer]);
}



  



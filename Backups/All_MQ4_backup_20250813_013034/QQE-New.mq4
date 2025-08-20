#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     Green
#property indicator_color2     Aqua
#property indicator_color3     Yellow
#property indicator_color4     Lime
#property indicator_color5     Red
#property indicator_width1     1
#property indicator_width2     1
#property indicator_width3     1
#property indicator_width4     2
#property indicator_width5     2
#property indicator_levelcolor DimGray

//
//
//
//
//

extern int    SF                     = 5;
extern int    RSIPeriod              = 6;
extern double WP                     = 4.236;
extern double UpperBound             = 60; 
extern double LowerBound             = 40; 

extern string _                      = "Alerts Settings";
extern bool   alertsOn               = true;
extern bool   alertsOnZeroCross      = false;
extern bool   alertsOnSignalCross    = true;
extern bool   alertsOnCurrent        = false;
extern bool   alertsMessage          = true;
extern bool   alertsSound            = true;
extern bool   alertsNotify           = false;
extern bool   alertsEmail            = false;
extern string soundFile              = "alert2.wav"; 

extern bool   arrowsVisible          = true;
extern string arrowsIdentifier       = "qqe Arrows1";
extern double arrowsDisplacement     = 1.0;

extern bool   arrowsOnZeroCross      = false;
extern color  arrowsUpZeroCrossColor = DeepSkyBlue;
extern color  arrowsDnZeroCrossColor = Red;
extern int    arrowsUpZeroCrossCode  = 233;
extern int    arrowsDnZeroCrossCode  = 234;
extern int    arrowsUpZeroCrossSize  = 1;
extern int    arrowsDnZeroCrossSize  = 1;

extern bool   arrowsOnSignalCross    = true;
extern color  arrowsUpSignalColor    = Lime;
extern color  arrowsDnSignalColor    = Red;
extern int    arrowsUpSignalCode     = 241;
extern int    arrowsDnSignalCode     = 242;
extern int    arrowsUpSignalSize     = 3;
extern int    arrowsDnSignalSize     = 3;

//
//
//
//
//

double RsiMa[];
double Trend[];
double HistoU[];
double HistoM[];
double HistoD[];
double trend1[];
double trend2[];
double work[][4];

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
   SetIndexBuffer(0,HistoU); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,HistoM); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,HistoD); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,RsiMa);  SetIndexLabel(0, "QQE");
   SetIndexBuffer(4,Trend);  SetIndexLabel(1, "QQE trend");
   SetIndexBuffer(5,trend1); 
   SetIndexBuffer(6,trend2); 
      SetLevelValue(0,UpperBound-50);
      SetLevelValue(1,LowerBound-50);
      SetLevelValue(2,0);
   return(0);
}
int deinit() 
{  
   deleteArrows(); 
   
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

#define iEma 0
#define iEmm 1
#define iQqe 2
#define iRsi 3

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;
   
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1);
           if (ArrayRange(work,0) != Bars) ArrayResize(work,Bars); 

   //
   //
   //
   //
   //

   double alpha1 = 2.0/(SF+1.0);
   double alpha2 = 2.0/(RSIPeriod*2.0);
      
   for (i=limit, r=Bars-i-1; i>=0; i--,r++)
   {  
      work[r][iRsi] = work[r-1][iRsi] + alpha1*(iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i)   - work[r-1][iRsi]);
      work[r][iEma] = work[r-1][iEma] + alpha2*(MathAbs(work[r-1][iRsi]-work[r][iRsi]) - work[r-1][iEma]);
      work[r][iEmm] = work[r-1][iEmm] + alpha2*(work[r][iEma] - work[r-1][iEmm]);

      //
      //
      //
      //
      //

         double rsi0 = work[r  ][iRsi];
         double rsi1 = work[r-1][iRsi];
         double dar  = work[r  ][iEmm]*WP;
         double tr   = work[r-1][iQqe];
         double dv   = tr;
   
            if (rsi0 < tr) { tr = rsi0 + dar; if ((rsi1 < dv) && (tr > dv)) tr = dv; }
            if (rsi0 > tr) { tr = rsi0 - dar; if ((rsi1 > dv) && (tr < dv)) tr = dv; }
         
      //
      //
      //
      //
      //
         
         work[r][iQqe] = tr;
         trend1[i]     = trend1[i+1];
         trend2[i]     = trend2[i+1];
         RsiMa[i]      = work[r][iRsi]-50;
         Trend[i]      = tr           -50;
         HistoU[i]     =  EMPTY_VALUE;
         HistoM[i]     =  EMPTY_VALUE;
         HistoD[i]     =  EMPTY_VALUE;
   
         if (RsiMa[i] > (UpperBound-50))                           HistoU[i] = RsiMa[i];
         if (RsiMa[i] < (LowerBound-50))                           HistoD[i] = RsiMa[i];
         if (HistoU[i] == EMPTY_VALUE && HistoD[i] == EMPTY_VALUE) HistoM[i] = RsiMa[i];

      //
      //
      //
      //
      //
               
         if (RsiMa[i] > 0)        trend1[i] =  1;
         if (RsiMa[i] < 0)        trend1[i] = -1;
         if (RsiMa[i] > Trend[i]) trend2[i] =  1;
         if (RsiMa[i] < Trend[i]) trend2[i] = -1;
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

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 

      //
      //
      //
      //
      //
            
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnZeroCross && trend1[whichBar] != trend1[whichBar+1])
      {
         if (trend1[whichBar] ==  1) doAlert(time1,mess1,whichBar,"Crossed zero line up");
         if (trend1[whichBar] == -1) doAlert(time1,mess1,whichBar,"Crossed zero line down");
      }
      
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnSignalCross && trend2[whichBar] != trend2[whichBar+1])
      {
         if (trend2[whichBar] ==  1) doAlert(time2,mess2,whichBar,"Signal cross up");
         if (trend2[whichBar] == -1) doAlert(time2,mess2,whichBar,"Signal cross down");
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

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," " +" "+message));
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," "),message);
          if (alertsSound)   PlaySound(soundFile);
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
      if (arrowsOnZeroCross && trend1[i] != trend1[i+1])
      {
         if (trend1[i] == 1) drawArrow(i,arrowsUpZeroCrossColor,arrowsUpZeroCrossCode,arrowsUpZeroCrossSize,false);
         if (trend1[i] ==-1) drawArrow(i,arrowsDnZeroCrossColor,arrowsDnZeroCrossCode,arrowsDnZeroCrossSize,true);
      }
      
      if (arrowsOnSignalCross && trend2[i]!= trend2[i+1])
      {
         if (trend2[i] == 1) drawArrow(i,arrowsUpSignalColor,arrowsUpSignalCode,arrowsUpSignalSize,false);
         if (trend2[i] ==-1) drawArrow(i,arrowsDnSignalColor,arrowsDnSignalCode,arrowsDnSignalSize,true);
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
         ObjectSet(name,OBJPROP_ARROWCODE,theCode );
         ObjectSet(name,OBJPROP_COLOR,    theColor);
         ObjectSet(name,OBJPROP_WIDTH,    theSize );      
         
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



#property copyright "FILTER-EXTRA"


#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_width1 3
#property indicator_width2 3

extern int    timeFrame          = 1440;
extern int    Length             = 1;
extern int    barsback           = 500;
extern bool   alertsOn           = true;
extern bool   alertsOnCurrent    = true;
extern bool   alertsMessage      = true;
extern bool   alertsSound        = true;
extern bool   alertsNotify       = false;
extern bool   alertsEmail        = false;
extern string soundfile          = "alert2.wav"; 
extern bool   arrowsVisible      = true;
extern string arrowsIdentifier   = "filterArrows";
extern double arrowsDisplacement = 0.1;
extern color  arrowsUpColor      = DeepSkyBlue;
extern color  arrowsDnColor      = Red;
extern int    arrowsUpCode       = 233;
extern int    arrowsDnCode       = 234;
extern int    arrowsUpSize       = 1;
extern int    arrowsDnSize       = 1;

double buffer1[];
double buffer2[];
bool cer;
bool cer2;
bool cer3 = TRUE;
string fileName;

int init() {
   cer3 = TRUE;
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, buffer1);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, buffer2);
   fileName=WindowExpertName();
   timeFrame = MathMax(timeFrame,Period());
   return (0);
}

int deinit() {
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return (0);
}

int start() {

   if (timeFrame!=Period())
   {
      int limit = MathMin(Bars-1,barsback*timeFrame/Period());
      for (int i = limit; i >= 0; i--)
      {
         int y = iBarShift(NULL,timeFrame,Time[i]);
         buffer1[i] = iCustom(NULL,timeFrame,fileName,0,Length,barsback,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundfile,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,0,y);
         buffer2[i] = iCustom(NULL,timeFrame,fileName,0,Length,barsback,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundfile,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,1,y);
      }
      return(0);
   }
   
   
   double low1;
   double high1;
   double cero[10000][3];
   if (!cer3) return (0);
   
  
   int pep = 0;
   int bep = 0;
   int tep = 0;
  
   double high60 = High[barsback];
   double low68 = Low[barsback];
   
   int li3 = barsback;
   int li6 = barsback;
   for (int li2 = barsback; li2 >= 0; li2--) {
      low1 = 10000000;
      high1 = -100000000;
      for (int li8 = li2 + Length; li8 >= li2 + 1; li8--) {
         if (Low[li8] < low1) low1 = Low[li8];
         if (High[li8] > high1) high1 = High[li8];
      }
      if (Low[li2] < low1 && High[li2] > high1) {
         bep = 2;
         if (pep == 1) li3 = li2 + 1;
         if (pep == -1) li6 = li2 + 1;
      } else {
         if (Low[li2] < low1) bep = -1;
         if (High[li2] > high1)bep  = 1;
      }
      if (bep != pep && pep != 0) {
         if (bep == 2) {
            bep = -pep;
            high60 = High[li2];
            low68 = Low[li2];
            cer = FALSE;
            cer2 = FALSE;
         }
         tep++;
         if (bep == 1) {
            cero[tep][1] = li6;
            cero[tep][2] = low68;
            cer = FALSE;
            cer2 = TRUE;
         }
         if (bep == -1) {
            cero[tep][1] = li3;
            cero[tep][2] = high60;
            cer = TRUE;
            cer2 = FALSE;
         }
         high60 = High[li2];
         low68 = Low[li2];
      }
      if (bep == 1) {
         if (High[li2] >= high60) {
            high60 = High[li2];
            li3 = li2;
         }
      }
      if (bep == -1) {
         if (Low[li2] <= low68) {
            low68 = Low[li2];
            li6 = li2;
         }
      }
      pep = bep;
      if (cer2 == TRUE) {
         buffer2[li2] = 1;
         buffer1[li2] = 0;
      }
      if (cer == TRUE) {
         buffer2[li2] = 0;
         buffer1[li2] = 1;
      }
      manageArrow(li2);
   }
   manageAlerts();
   return (0);
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
      ObjectDelete(arrowsIdentifier+":"+Time[i]);
      
      if (buffer2[i] == 1 && buffer2[i+1] == 0) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
      if (buffer1[i] == 1 && buffer1[i+1] == 0) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize,true);
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
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
      
      if (buffer2[whichBar] == 1 && buffer2[whichBar+1] == 0) doAlert(whichBar,"up");
      if (buffer1[whichBar] == 1 && buffer1[whichBar+1] == 0) doAlert(whichBar,"down");       
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," FILTER-EXTRA ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," FILTER-EXTRA "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}


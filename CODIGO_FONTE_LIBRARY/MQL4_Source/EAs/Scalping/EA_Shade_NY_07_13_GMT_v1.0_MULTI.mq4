//+------------------------------------------------------------------+
//|                                                      ShadeNY.mq4 |
//|                                         Copyright © 2006, sx ted |
//| Purpose: shade New York or other sessions for chart time frames  |
//|          M1 to H4 (at a push).                                   |
//| version: 2 - enhanced for speed but with MT4 beeing so fast no   |
//|              difference will be noticed, all the sessions are    |
//|              shaded in the init(), last session if it is current |
//|              is widened in the start() in lieu of repainting all.|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, sx ted"
#property link      ""

#property indicator_chart_window

//---- input parameters
extern color     ShadeColor=Yellow;

/*
// if in Moscow
#define NY_OPEN_HH   17 // NY session open hour
#define NY_OPEN_MM   30 // NY session open minutes
#define NY_CLOSE_HH  00 // NY session close hour
#define NY_CLOSE_MM  05 // NY session close minutes
*/


// if in 07:00 - 13:00 GMT
#define NY_OPEN_HH   07 // NY session open hour
#define NY_OPEN_MM   00 // NY session open minutes
#define NY_CLOSE_HH  13 // NY session close hour
#define NY_CLOSE_MM  00 // NY session close minutes



/*
// if in London
#define NY_OPEN_HH   14 // NY session open hour
#define NY_OPEN_MM   30 // NY session open minutes
#define NY_CLOSE_HH  21 // NY session close hour
#define NY_CLOSE_MM  05 // NY session close minutes
*/

/*
// if in New York
#define NY_OPEN_HH   08 // NY session open hour
#define NY_OPEN_MM   30 // NY session open minutes
#define NY_CLOSE_HH  14 // NY session close hour
#define NY_CLOSE_MM  05 // NY session close minutes
*/

#define MAX_DAYS_TO_SHADE  5 // maximum number of days back from last chart date to be shaded

//---- global variables to program
string obj[]; //array of object names
int    iPrevious=0, iStart=-1, iEnd;
double dLow, dHigh;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if(Period()>PERIOD_H4) return(0); // no shading required
   int iMaxBarsOnChart=iBars(NULL,0), i, iBarDay, iBarTime;
   // find approximate start of first day to shade
   int iBarsToDo=MathMin((MAX_DAYS_TO_SHADE*PERIOD_D1)/Period(),iMaxBarsOnChart);
   // find start of first day to shade
   for(i=iBarsToDo; i<iMaxBarsOnChart; i++)
     {
      iBarDay=TimeYear(Time[i])*PERIOD_MN1*12+TimeMonth(Time[i])*PERIOD_MN1+TimeDay(Time[i])*PERIOD_D1;
      iBarTime=iBarDay+TimeHour(Time[i])*60+TimeMinute(Time[i]);
      if(iBarTime>=iBarDay+NY_OPEN_HH*60+NY_OPEN_MM && iBarTime<=iBarDay+NY_CLOSE_HH*60+NY_CLOSE_MM) iStart=i;
      else if(iStart>-1) break;
     }
   if(iStart>-1) iBarsToDo=iStart;
   iStart=-1;
   // shade previous sessions and current session if started
   for(i=iBarsToDo; i>=0; i--)
     {
      iBarDay=TimeYear(Time[i])*PERIOD_MN1*12+TimeMonth(Time[i])*PERIOD_MN1+TimeDay(Time[i])*PERIOD_D1;
      iBarTime=iBarDay+TimeHour(Time[i])*60+TimeMinute(Time[i]);
      if(iBarTime>=iBarDay+NY_OPEN_HH*60+NY_OPEN_MM && iBarTime<=iBarDay+NY_CLOSE_HH*60+NY_CLOSE_MM)
        {
         if(iBarDay==iPrevious)   // current NY session
           {
            dLow =MathMin(dLow,  Low[i]);
            dHigh=MathMax(dHigh, High[i]);
           }
         else                     // new NY session
           {
            dLow=Low[i];
            dHigh=High[i];
            iStart=i;
            iPrevious=iBarDay;
           }      
         iEnd=i;
        }
      else if(iStart>-1)
        {
         PaintRectangle();
         iStart=-1;
        }  
     }
   if(iStart>-1) PaintRectangle(); // paint the last one if session not closed
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int iaCount=ArraySize(obj);
   for(int i=0; i<iaCount; i++)
     {
      if(ObjectFind(obj[i])>-1) ObjectDelete(obj[i]);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i=0, iBarDay, iBarTime;
   iBarDay=TimeYear(Time[i])*PERIOD_MN1*12+TimeMonth(Time[i])*PERIOD_MN1+TimeDay(Time[i])*PERIOD_D1;
   iBarTime=iBarDay+TimeHour(Time[i])*60+TimeMinute(Time[i]);
   if(iBarTime>=iBarDay+NY_OPEN_HH*60+NY_OPEN_MM && iBarTime<=iBarDay+NY_CLOSE_HH*60+NY_CLOSE_MM)
     {
      if(iBarDay==iPrevious)   // current NY session
        {
         dLow =MathMin(dLow,  Low[i]);
         dHigh=MathMax(dHigh, High[i]);
        }
      else                     // new NY session
        {
         dLow=Low[i];
         dHigh=High[i];
         iStart=i;
         iPrevious=iBarDay;
        }      
      iEnd=i;
      PaintRectangle();
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Paint rectangle                                                  |
//+------------------------------------------------------------------+
void PaintRectangle()
  {
   string sObj="ShadeNY_"+DoubleToStr(iPrevious, 0); // name for the object
   if(ObjectFind(sObj)>-1)
     {
      // current session object found, so just widen it
      ObjectSet(sObj,OBJPROP_PRICE1,dLow-Point);
      ObjectSet(sObj,OBJPROP_TIME2 ,Time[iEnd]);
      ObjectSet(sObj,OBJPROP_PRICE2,dHigh+Point);
     }
   else
     {
      // otherwise create new object for the session
      int iaCount=ArraySize(obj);
      ArrayResize(obj, iaCount+1);
      obj[iaCount]=sObj;
      ObjectCreate(sObj,OBJ_RECTANGLE,0,Time[iStart],dLow-Point,Time[iEnd],dHigh+Point);
      ObjectSet(sObj,OBJPROP_COLOR,ShadeColor); 
     }
  }     
//+------------------------------------------------------------------+
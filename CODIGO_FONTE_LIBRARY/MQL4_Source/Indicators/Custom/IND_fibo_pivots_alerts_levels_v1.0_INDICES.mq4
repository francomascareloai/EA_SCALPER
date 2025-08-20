//+------------------------------------------------------------------+
//|                                                  fibo pivots.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 0

//
//
//
//
//

extern string Levels                = "0.382;0.618;1";
extern string TimeFrame             = "D1";
extern int    HourShift             =  0;
extern bool   FixSundays            = true;
extern bool   ShowLabels            = false;
extern bool   ShowLevels            = true;
extern bool   ShowPrices            = false;
extern bool   ShowMiddleValues      = false;
extern int    ShowTotalPivots       = 5;
extern int    MainLinesWidth        = 2;
extern color  UpperValuesColor      = DeepSkyBlue;
extern color  LowerValuesColor      = Red;
extern color  PivotValuesColor      = Gray;
extern color  LabelsColor           = Gray;
extern int    LabelsFontSize        =  10;
extern int    LabelsShiftHorizontal = -15;
extern int    LabelsShiftVertical   =   1;
extern string PivotIdentifier       = "fiboPivot1";

extern bool   alertsOn              = false;
extern bool   alertsOnCurrent       = true;
extern bool   alertsMessage         = true;
extern bool   alertsSound           = false;
extern bool   alertsEmail           = false;

//
//
//
//
//

double   Pivot[];
double   Range[];
double   Dates[];

//
//
//
//
//

datetime alertTimes[];
string   alertEvents[];
double   levels[];
int      levelsCount;

int    timeFrame;
int    lookupTimeFrame;
string Description;


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
   lookupTimeFrame = PERIOD_H1;
   timeFrame       = stringToTimeFrame(TimeFrame);
         if (timeFrame<PERIOD_D1)
         {
            HourShift=0;
            lookupTimeFrame = timeFrame;
         }         
         if (timeFrame==PERIOD_W1)
         {
            if (HourShift<0) HourShift -= 24;
            if (HourShift>0) HourShift += 24;
         }
         if (ShowTotalPivots==0) ShowTotalPivots = 99999;
                                 ShowTotalPivots = MathMax(1,ShowTotalPivots);
                                 
   //
   //
   //
   //
   //
   
      Levels = StringTrimLeft(StringTrimRight(Levels));
      if (StringSubstr(Levels,StringLen(Levels),1) != ";")
                       Levels = StringConcatenate(Levels,";");

         //
         //
         //
         //
         //                                   
            
         int s = 0;
         int i = StringFind(Levels,";",s);
            while (i > 0)
            {
               string current = StringSubstr(Levels,s,i-s);
               double value   = StrToDouble(current);
               if (value > 0) {
                     ArrayResize(levels,ArraySize(levels)+1);
                                 levels[ArraySize(levels)-1] = value; }
                                 s = i + 1;
                                     i = StringFind(Levels,";",s);
            }
            ArraySort(levels);
            levelsCount = ArraySize(levels);
      ArrayResize(alertTimes,levelsCount*4+1);
      ArrayResize(alertEvents,levelsCount*4+1);
   
   //
   //
   //
   //
   //
   
      IndicatorBuffers(3);   
         SetIndexBuffer(0,Pivot); SetIndexStyle(0,DRAW_NONE);
         SetIndexBuffer(1,Range);
         SetIndexBuffer(2,Dates);
   return(0);
}

//
//
//
//
//

int deinit()
{
   string lookFor       = PivotIdentifier+"-";
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
   int i,limit,drawLimit;

      if (Period() >= timeFrame) return(-1);
      if (counted_bars<0) return(-1);
      if (counted_bars>0) counted_bars--;
         limit     = MathMin(Bars-counted_bars,Bars-1);
         drawLimit = MathMin(limit,iBarShift(NULL,0,iTime(NULL,timeFrame,ShowTotalPivots-1)));
               if (timeFrame==PERIOD_W1) while(TimeDayOfWeek(Time[drawLimit])==5) drawLimit--;

   //
   //
   //
   //
   //

      double   pivot = Pivot[limit+1];
      double   range = Range[limit+1];
      datetime dates = Dates[limit+1];
   
   //
   //
   //
   //
   //
      
   for (i=limit; i>=0; i--)
   {
      int x = iBarShift(NULL,timeFrame,Time[i+1]-HourShift*3600,true);
      int y = iBarShift(NULL,timeFrame,Time[i]  -HourShift*3600,true);
      if (x!=y)
      {
         int k = i;
         if (FixSundays && timeFrame==PERIOD_D1)
            while (k<Bars && TimeDayOfWeek(Time[k+1]-HourShift*3600)==0) k++;
            int z = iBarShift(NULL,lookupTimeFrame,Time[k+1]-timeFrame*60-HourShift*3600);
                x = iBarShift(NULL,lookupTimeFrame,Time[k+1]             -HourShift*3600);
                dates = Time[k];
               
                //
                //
                //
                //
                //

                double LastHigh  = iHigh(NULL,lookupTimeFrame,iHighest(NULL,lookupTimeFrame,MODE_HIGH,z-x,x));
                double LastLow   = iLow (NULL,lookupTimeFrame,iLowest( NULL,lookupTimeFrame,MODE_LOW ,z-x,x));
                double LastClose = Close[k+1];
               
                //
                //
                //
                //
                //
                  
                pivot = (LastHigh+LastLow+LastClose)/3;
                range = LastHigh-LastLow;
      }
                  
      //
      //
      //
      //
      //

         if (i<=drawLimit)
         {      
            datetime datee = MathMax(dates+Period()*60,Time[i]);
               
            SetLevel("p",dates,datee,pivot-range*levels[k],PivotValuesColor,MainLinesWidth);
            for(k=0; k<levelsCount; k++)
            {
               SetLevel((k+1)+"r",dates,datee,pivot+range*levels[k],UpperValuesColor,MainLinesWidth);
               SetLevel((k+1)+"s",dates,datee,pivot-range*levels[k],LowerValuesColor,MainLinesWidth);
               if (ShowMiddleValues)
               {
                  SetLevel((k+1)+"rm",dates,datee,pivot+range*(levels[k]+levels[k-1])/2.0,UpperValuesColor,0,STYLE_DOT);
                  SetLevel((k+1)+"sm",dates,datee,pivot-range*(levels[k]+levels[k-1])/2.0,LowerValuesColor,0,STYLE_DOT);
               }                  
            }            
         }               
         Pivot[i] = pivot;
         Range[i] = range;
         Dates[i] = dates;
   }

   if (ShowLabels || ShowLevels || ShowPrices) DisplayLabels();
   if (alertsOn) CheckCrossings();

   //
   //
   //
   //
   //
   
   return(0);
}



//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

void DisplayLabels()
{
   ShowLabel(0+"p",Pivot[0],0,"fibo pivot"  );
      for (int k=0; k<levelsCount; k++)
      {
         ShowLabel((k+1)+"lr",Pivot[0]+Range[0]*levels[k],levels[k],"fibo R"+(k+1));
         ShowLabel((k+1)+"ls",Pivot[0]-Range[0]*levels[k],levels[k],"fibo S"+(k+1));
      }      
}
void ShowLabel(string ID, double price, double level, string label)
{
   string finalLabel = "";
   
   if (ShowLabels) finalLabel = label+" ";
   if (ShowLevels) finalLabel = finalLabel+"lvl : "+DoubleToStr(level,3)+" ";
   if (ShowPrices) finalLabel = finalLabel+DoubleToStr(price,Digits);
         SetLabel(ID,price,Description+finalLabel);
}
int barTime(int a)
{
   if(a<0)
         return(Time[0]+Period()*60*MathAbs(a));
   else  return(Time[a]);   
}

//
//
//
//
//

void SetLabel(string ID,double forLine,string label)
{
   datetime theTime = barTime(LabelsShiftHorizontal);
   string   name    = PivotIdentifier+"-"+ID;
   
   if(ObjectFind(name)==-1) {
      ObjectCreate(name,OBJ_TEXT,0,0,0);
         ObjectMove(name,0,theTime,forLine+LabelsShiftVertical*Point);
         ObjectSetText(name,label,LabelsFontSize,"Arial",LabelsColor); }
   
}

//
//
//
//
//
//

void SetLevel(string ID,datetime startTime, datetime endTime, double value, color theColor,int theWidth, int theStyle = STYLE_SOLID)
{
   string name = PivotIdentifier+"-"+startTime+"-"+ID;
   
      if(ObjectFind(name)==-1)
         ObjectCreate(name,OBJ_TREND,0,0,0);
            ObjectSet(name,OBJPROP_TIME1,startTime);
            ObjectSet(name,OBJPROP_TIME2,endTime);
            ObjectSet(name,OBJPROP_PRICE1,value);
            ObjectSet(name,OBJPROP_PRICE2,value);
            ObjectSet(name,OBJPROP_COLOR,theColor);
            ObjectSet(name,OBJPROP_RAY,false);
            ObjectSet(name,OBJPROP_STYLE,theStyle);
            ObjectSet(name,OBJPROP_WIDTH,theWidth);
}

//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

void CheckCrossings()
{
   int    forBar    = (alertsOnCurrent != true);
   double currPrice = Close[forBar];
   double prevPrice = Close[forBar+1];
   double pivot     = Pivot[forBar];
   double range     = Range[forBar];
   string level     = "";
   
   CheckIfCrossed(currPrice,prevPrice,pivot,"pivot",levelsCount*4);
   for(int k=0; k<levelsCount; k++)
   {
      if (ShowLevels) 
            level = DoubleToStr(levels[k],3);
      else  level = k+1;            
      CheckIfCrossed(currPrice,prevPrice,pivot+range*levels[k],"resistance "+level,k);
      CheckIfCrossed(currPrice,prevPrice,pivot-range*levels[k],"support "   +level,k+levelsCount);
      if (ShowMiddleValues)
      {
         if (ShowLevels) 
               level = DoubleToStr((levels[k]+levels[k-1])/2.0,3);
         else  level = k+1;            
         CheckIfCrossed(currPrice,prevPrice,pivot+range*(levels[k]+levels[k-1])/2.0,"minor resistance "+level,k+levelsCount*2);
         CheckIfCrossed(currPrice,prevPrice,pivot-range*(levels[k]+levels[k-1])/2.0,"minor support "   +level,k+levelsCount*3);
      }
   }         
}

//
//
//
//
//

void CheckIfCrossed(double curr, double prev, double price, string what, int forWhat)
{
   if (curr > price && prev < price) doAlert(Description+what+" line crossed up"  ,forWhat);
   if (curr < price && prev > price) doAlert(Description+what+" line crossed down",forWhat);
}

//
//
//
//
//

void doAlert(string doWhat, int forWhat)
{
   string message;
   
      if (alertEvents[forWhat] != doWhat || alertTimes[forWhat] != Time[0]) {
          alertEvents[forWhat]  = doWhat;
          alertTimes[forWhat]   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," fibo pivot ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," fibo pivot line crossing"),message);
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

int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringUpperCase(tfs);
         if (tfs=="M1" || tfs=="1")     { tf=PERIOD_M1;  Description = "";}
         if (tfs=="M5" || tfs=="5")     { tf=PERIOD_M5;  Description = "5 minutes "; }
         if (tfs=="M15"|| tfs=="15")    { tf=PERIOD_M15; Description = "15 minutes ";}
         if (tfs=="M30"|| tfs=="30")    { tf=PERIOD_M30; Description = "half hour "; }
         if (tfs=="H1" || tfs=="60")    { tf=PERIOD_H1;  Description = "hourly ";    }
         if (tfs=="H4" || tfs=="240")   { tf=PERIOD_H4;  Description = "4 hourly ";  }
         if (tfs=="D1" || tfs=="1440")  { tf=PERIOD_D1;  Description = "daily ";     }
         if (tfs=="W1" || tfs=="10080") { tf=PERIOD_W1;  Description = "weekly ";    }
         if (tfs=="MN" || tfs=="43200") { tf=PERIOD_MN1; Description = "monthly ";   }
  return(tf);
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;
   int      length = StringLen(str) - 1;
   int      tchar;
   
   while(length >= 0)
      {
         tchar = StringGetChar(s, length);
         
         //
         //
         //
         //
         //
         
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                  s = StringSetChar(s, length, tchar - 32);
         else 
              if(tchar > -33 && tchar < 0)
                  s = StringSetChar(s, length, tchar + 224);
         length--;
   }
   return(s);
}
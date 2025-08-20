//+------------------------------------------------------------------+
//|                              Custom candles - any time frame.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window

//
//
//
//
//

extern string TimeFrame               = "Current time frame";
extern color  UpCandleColor           = DeepSkyBlue;
extern color  DownCandleColor         = Red;
extern color  NeutralCandleColor      = DimGray;
extern int    DrawingWidth            = 1;
extern bool   FilledCandles           = false;
extern string UniqueCandlesIdentifier = "CustomCandleAny";
extern string timeFrames              = "time frames notations";
extern string timeFramesAsString      = "M1,M2,M3,M4,M5,M6,M10,M12,M15,M20,M30,H1,H2,H3,H4,H6,H8,H12,D1,W1,MN";
extern string timeFramesAsNumber      = "1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200";

//
//
//
//
//

int timeFrame;

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
   timeFrame = stringToTimeFrame(TimeFrame);
         if (MathFloor(timeFrame/Period())*Period() != timeFrame) timeFrame = Period();
   return(0);
}
int deinit() { deleteCandles(); return(0); }


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
   static int oldBars = 0;
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (oldBars!=Bars)
           {
               deleteCandles();
                  oldBars = Bars;
                  limit   = Bars-1;
           }               

   //
   //
   //
   //
   //
   
   for (i=limit; i>= 0; i--)
   {
      datetime startingTime;
      int      barsPassed;
      int      startOfThisBar;

         while (true)
         {
            if (timeFrame<60)
            {
               startingTime   = StrToTime(TimeToStr(Time[i],TIME_DATE)+toHour(TimeHour(Time[i])));
               barsPassed     = MathFloor((Time[i]-startingTime)/(timeFrame*60));
               startOfThisBar = iBarShift(NULL,0,startingTime+barsPassed*timeFrame*60);
               break;
            }
            if (timeFrame<1440)
            {
               startingTime   = StrToTime(TimeToStr(Time[i],TIME_DATE)+" 00:00");
               barsPassed     = MathFloor((Time[i]-startingTime)/(timeFrame*60));
               startOfThisBar = iBarShift(NULL,0,startingTime+barsPassed*timeFrame*60);
               break;
            }
            startingTime   = iTime(NULL,timeFrame,iBarShift(NULL,timeFrame,Time[i]));
            startOfThisBar = iBarShift(NULL,0,startingTime);
            break;
         }         

         //
         //
         //
         //
         //
         
            datetime startTime  = Time[startOfThisBar];
            datetime endTime    = startTime+(timeFrame-1)*60;
            double   openPrice  = Open[startOfThisBar];
            double   closePrice = Close[startOfThisBar];
            double   highPrice  = High[startOfThisBar];
            double   lowPrice   = Low[startOfThisBar];
         
            for (int k=1; Time[startOfThisBar-k]>0 && Time[startOfThisBar-k]<=endTime; k++)
               {
                  closePrice = Close[startOfThisBar-k];
                  highPrice  = MathMax(highPrice,High[startOfThisBar-k]);
                  lowPrice   = MathMin(lowPrice,Low[startOfThisBar-k]);
               }

         //
         //
         //
         //
         //
         
         drawCandle(startTime,endTime,openPrice,closePrice,highPrice,lowPrice);
   }

   //
   //
   //
   //
   //
   
   Comment("Current "+Symbol()+" "+timeFrameToString(timeFrame)+" candle : ",DoubleToStr(openPrice,Digits),",",DoubleToStr(highPrice,Digits),",",DoubleToStr(lowPrice,Digits),",",DoubleToStr(closePrice,Digits));
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

string toHour(int hour)
{
   if (hour<10)
         return(" 0"+hour+":00");
   else  return(" " +hour+":00");
}

//
//
//
//
//

void deleteCandles()
{
   int searchLength = StringLen(UniqueCandlesIdentifier);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string name = ObjectName(i);
         if (StringSubstr(name,0,searchLength) == UniqueCandlesIdentifier)  ObjectDelete(name);
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

void drawCandle(datetime startTime, datetime endTime, double openPrice, double closePrice, double highPrice, double lowPrice)
{
   color candleColor = NeutralCandleColor;
   
      if (closePrice>openPrice) candleColor = UpCandleColor;
      if (closePrice<openPrice) candleColor = DownCandleColor;

   //
   //
   //
   //
   //
         
      string name = UniqueCandlesIdentifier+":"+startTime;
      if (ObjectFind(name)==-1)
          ObjectCreate(name,OBJ_RECTANGLE,0,startTime,openPrice,endTime,closePrice);
             ObjectSet(name,OBJPROP_PRICE1,openPrice);
             ObjectSet(name,OBJPROP_PRICE2,closePrice);
             ObjectSet(name,OBJPROP_TIME2 ,endTime);
             ObjectSet(name,OBJPROP_COLOR ,candleColor);
             ObjectSet(name,OBJPROP_STYLE ,STYLE_SOLID);
             ObjectSet(name,OBJPROP_BACK  ,FilledCandles);
             ObjectSet(name,OBJPROP_WIDTH ,DrawingWidth);
             
      //
      //
      //
      //
      //
                   
      datetime wickTime = startTime+(endTime-startTime)/2;
      double   upPrice  = MathMax(closePrice,openPrice);
      double   dnPrice  = MathMin(closePrice,openPrice);
      
      string   wname = name+":+";
      if (ObjectFind(wname)==-1)
          ObjectCreate(wname,OBJ_TREND,0,wickTime,highPrice,wickTime,upPrice);
             ObjectSet(wname,OBJPROP_PRICE1,highPrice);
             ObjectSet(wname,OBJPROP_PRICE2,upPrice);
             ObjectSet(wname,OBJPROP_TIME1 ,wickTime);
             ObjectSet(wname,OBJPROP_TIME2 ,wickTime);
             ObjectSet(wname,OBJPROP_COLOR ,candleColor);
             ObjectSet(wname,OBJPROP_STYLE ,STYLE_SOLID);
             ObjectSet(wname,OBJPROP_RAY   ,false);
             ObjectSet(wname,OBJPROP_WIDTH ,DrawingWidth);

      wname = name+":-";
      if (ObjectFind(wname)==-1)
          ObjectCreate(wname,OBJ_TREND,0,wickTime,dnPrice,wickTime,lowPrice);
             ObjectSet(wname,OBJPROP_PRICE1,dnPrice);
             ObjectSet(wname,OBJPROP_PRICE2,lowPrice);
             ObjectSet(wname,OBJPROP_TIME1 ,wickTime);
             ObjectSet(wname,OBJPROP_TIME2 ,wickTime);
             ObjectSet(wname,OBJPROP_COLOR ,candleColor);
             ObjectSet(wname,OBJPROP_STYLE ,STYLE_SOLID);
             ObjectSet(wname,OBJPROP_RAY   ,false);
             ObjectSet(wname,OBJPROP_WIDTH ,DrawingWidth);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M2","M3","M4","M5","M6","M10","M12","M15","M20","M30","H1","H2","H3","H4","H6","H8","H12","D1","W1","MN"};
int    iTfTable[] = {1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
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

string StringUpperCase(string str)
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
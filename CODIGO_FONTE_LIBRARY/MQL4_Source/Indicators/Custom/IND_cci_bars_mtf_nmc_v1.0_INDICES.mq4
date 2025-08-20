//------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  DarkGray
#property indicator_color4  DarkGray

//
//
//
//
//

extern string TimeFrame = "Current time frame";
extern int    Length    = 50;
extern int    Price     = PRICE_TYPICAL;
extern double LevelUp   =  100;
extern double LevelDown = -100;

//
//
//
//
//

double barnu[];
double barnd[];
double bartu[];
double bartd[];
double trend[];
bool   returnBars;
int    timeFrame;
string indicatorFileName;

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
      SetIndexBuffer(0,bartu); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,bartd); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,barnu); SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(3,barnd); SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexBuffer(4,trend);
         timeFrame  = stringToTimeFrame(TimeFrame);
         returnBars = (TimeFrame=="returnBars");
         indicatorFileName = WindowExpertName();
         IndicatorShortName("Rsi ("+Length+")");
   return(0);
}
int deinit() { return(0); }

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { bartu[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   for(int i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
      double cci = iCCI(NULL,timeFrame,Length,Price,y); 
      
      //
      //
      //
      //
      //

      bartu[i] = EMPTY_VALUE;
      bartd[i] = EMPTY_VALUE;
      barnu[i] = EMPTY_VALUE;
      barnd[i] = EMPTY_VALUE;
      trend[i] = 0;
         if (cci>LevelUp)   trend[i] =  1;
         if (cci<LevelDown) trend[i] = -1;
            if (trend[i]== 1) { bartu[i] = High[i]; bartd[i] = Low[i]; }
            if (trend[i]==-1) { bartd[i] = High[i]; bartu[i] = Low[i]; }
            if (trend[i]== 0) { barnu[i] = High[i]; barnd[i] = Low[i]; }
   }
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
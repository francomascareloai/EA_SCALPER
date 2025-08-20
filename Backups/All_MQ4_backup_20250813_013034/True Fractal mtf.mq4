//+------------------------------------------------------------------+
//|                                          True_Fractals_Level.mq4 |
//|                                                      TO StatBars |
//|                                            http://tradexperts.ru |
//+------------------------------------------------------------------+
#property copyright "TO StatBars"
#property link      "http://tradexperts.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 OrangeRed
//---- input parameters
extern string TimeFrame         = "Current time frame";   
extern int    Level             = 5;
extern bool   FractalOnFirstBar = true;

//---- indicator buffers
double Upper[];
double Lower[];

string indicatorFileName;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- additional buffers are used for counting
   IndicatorBuffers(2);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,Upper);
   SetIndexBuffer(1,Lower);
//---- drawing settings
   SetIndexStyle( 0, DRAW_ARROW, 1, 1);
   SetIndexStyle( 1, DRAW_ARROW, 1, 1);
   SetIndexArrow( 0, 217) ;
   SetIndexArrow( 1, 218) ;
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame == "returnBars";     if (returnBars)     return(0);
   timeFrame         = stringToTimeFrame(TimeFrame);
   return(0);
  }
//+------------------------------------------------------------------+
//| Bill Williams' Alligator                                         |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { Upper[0] = limit+1; return(0); }
   
            if (timeFrame!=Period())
            {
               int shift = -1; if (FractalOnFirstBar) shift=1;
               limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
               for (int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,timeFrame,Time[i]);   
                  int x = iBarShift(NULL,timeFrame,Time[i+shift]);               
                  if (x!=y)
                  {
                     Upper[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Level,0,y);
                     Lower[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Level,1,y);
                  }
               }
               return(0);
            }
   for(i=0; i<limit; i++)
   {
      if( iHighest( Symbol(),0, MODE_HIGH, Level, i - Level/2) == i )
         Upper[i] = High[i];
      else Upper[i] = EMPTY_VALUE;
      
      if( iLowest( Symbol(),0, MODE_LOW, Level, i - Level/2) == i )
         Lower[i] = Low[i];
      else Lower[i] = EMPTY_VALUE;
   }
//---- done
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



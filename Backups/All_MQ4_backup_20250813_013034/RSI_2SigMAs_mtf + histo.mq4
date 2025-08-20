//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright ""
#property link      ""
#property indicator_separate_window

#property indicator_buffers 8
#property indicator_color1  LimeGreen
#property indicator_color2  LimeGreen
#property indicator_color3  PaleVioletRed
#property indicator_color4  PaleVioletRed
#property indicator_color5  DimGray
#property indicator_color6  RoyalBlue
#property indicator_color7  Green
#property indicator_color8  Red
#property indicator_width1  2
#property indicator_width3  2
#property indicator_width6  3
#property indicator_width7  2
#property indicator_width8  2
#property indicator_level1  20
#property indicator_level2   0
#property indicator_level3 -20
#property indicator_levelcolor DarkOliveGreen

//
//
//
//
//

extern string TimeFrame   = "Current time frame";
extern int    RSI_Period  = 14;
extern int    RSI_Price   =  0;
extern int    MA1_Period  =  3;
extern int    MA1_Mode    =  1;
extern int    MA2_Period  =  5;
extern int    MA2_Mode    =  1;
extern string TimeFrames="M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN|0-CurrentTF";
extern string MA_Method_Price="SMA0 EMA1 SMMA2 LWMA3||0C,1O 2H3L,4Md 5Tp 6WghC: Md(HL/2)4,Tp(HLC/3)5,Wgh(HLCC/4)6";

//
//
//
//
//

double RSI_Buffer[];
double MA1_Buffer[];
double MA2_Buffer[];
double hiUu[];
double hiUd[];
double hiDd[];
double hiDu[];
double hiLi[];

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
   SetIndexBuffer(0, hiUu); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1, hiUd); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2, hiDd); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3, hiDu); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4, hiLi);
   SetIndexBuffer(5, RSI_Buffer);
   SetIndexBuffer(6, MA1_Buffer);
   SetIndexBuffer(7, MA2_Buffer);
   
      //
      //
      //
      //
      //
      
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
   IndicatorShortName(timeFrameToString(timeFrame)+" RSI_2SigMA ("+RSI_Period+","+MA1_Period+","+MA2_Period+")");
   return(0);
}
int deinit()
{
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

double work[][2];
#define _trend 0
#define _slope 1
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { hiUu[0] = MathMin(limit+1,Bars-1); return(0); }
           if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      for(i=limit;           i>=0;i--)      RSI_Buffer[i] = iRSI(NULL, TimeFrame, RSI_Period, RSI_Price,  i)-50;
      for(i=limit;           i>=0;i--)      MA1_Buffer[i] = iMAOnArray(RSI_Buffer,0,MA1_Period,0,MA1_Mode,i);
      for(i=limit,r=Bars-i-1;i>=0;i--,r++){ MA2_Buffer[i] = iMAOnArray(MA1_Buffer,0,MA2_Period,0,MA2_Mode,i);
         hiLi[i] = MA1_Buffer[i]-MA2_Buffer[i];
         hiUu[i] = EMPTY_VALUE;
         hiUd[i] = EMPTY_VALUE;
         hiDd[i] = EMPTY_VALUE;
         hiDu[i] = EMPTY_VALUE;
            work[r][_trend] = work[r-1][_trend];
            work[r][_slope] = work[r-1][_slope];
               if (hiLi[i]>0)         work[r][_trend] =  1;
               if (hiLi[i]<0)         work[r][_trend] = -1;
               if (hiLi[i]>hiLi[i+1]) work[r][_slope] =  1;
               if (hiLi[i]<hiLi[i+1]) work[r][_slope] = -1;
               if (work[r][_trend]==1)
                  if (work[r][_slope]==1) 
                        hiUu[i] = hiLi[i];
                  else  hiUd[i] = hiLi[i];    
               if (work[r][_trend]==-1)
                  if (work[r][_slope]==-1) 
                        hiDd[i] = hiLi[i];
                  else  hiDu[i] = hiLi[i];    
      }
      return(0);
   }      
   
   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for(i=limit,r=Bars-i-1;i>=0;i--,r++)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         RSI_Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RSI_Period,RSI_Price,MA1_Period,MA1_Mode,MA2_Period,MA2_Mode,5,y);
         MA1_Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RSI_Period,RSI_Price,MA1_Period,MA1_Mode,MA2_Period,MA2_Mode,6,y);
         MA2_Buffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RSI_Period,RSI_Price,MA1_Period,MA1_Mode,MA2_Period,MA2_Mode,7,y);
         hiLi[i] = MA1_Buffer[i]-MA2_Buffer[i];
         hiUu[i] = EMPTY_VALUE;
         hiUd[i] = EMPTY_VALUE;
         hiDd[i] = EMPTY_VALUE;
         hiDu[i] = EMPTY_VALUE;
            work[r][_trend] = work[r-1][_trend];
            work[r][_slope] = work[r-1][_slope];
               if (hiLi[i]>0)         work[r][_trend] =  1;
               if (hiLi[i]<0)         work[r][_trend] = -1;
               if (hiLi[i]>hiLi[i+1]) work[r][_slope] =  1;
               if (hiLi[i]<hiLi[i+1]) work[r][_slope] = -1;
               if (work[r][_trend]==1)
                  if (work[r][_slope]==1) 
                        hiUu[i] = hiLi[i];
                  else  hiUd[i] = hiLi[i];    
               if (work[r][_trend]==-1)
                  if (work[r][_slope]==-1) 
                        hiDd[i] = hiLi[i];
                  else  hiDu[i] = hiLi[i];    
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



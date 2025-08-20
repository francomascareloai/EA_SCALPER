//+------------------------------------------------------------------+
//|                                     Fractals - adjustable period |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

//2021.09.25
//can u set a rule if the blue line is downwards trending and there is a break to upside then enter buy 
//if  the red line is. upward trending and there is a break to to the down side then enter a sell

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrPaleVioletRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property strict


input ENUM_TIMEFRAMES TimeFrames             = PERIOD_CURRENT;       // Time frame
ENUM_TIMEFRAMES TimeFrame = TimeFrames;
input int             FractalPeriods         = 5;                   // Fractal period default 25
int FractalPeriod = FractalPeriods;
input double          UpperArrowDisplacement = 0.2;                  // Upper fractal displacement
input double          LowerArrowDisplacement = 0.2;                  // Lower fractal displacement
input color           UpperCompletedColor    = clrDeepSkyBlue;       // Upper trend line completed color 
input color           UpperUnCompletedColor  = clrAqua;              // Upper trend line uncompleted color
input color           LowerCompletedColor    = clrPaleVioletRed;     // Lower trend line completed color
input color           LowerUnCompletedColor  = clrHotPink;           // Lower trend line uncompleted color
input int             CompletedWidth         = 2;                    // Completed trend line width 
input int             UnCompletedWidth       = 2;                    // Uncompleted trend line width
input string          UniqueID               = "FractalTrendLines1"; // Trend line unique ID.

double UpperBuffer[],LowerBuffer[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,FractalPeriod,UpperArrowDisplacement,LowerArrowDisplacement,UpperCompletedColor,UpperUnCompletedColor,LowerCompletedColor,LowerUnCompletedColor,CompletedWidth,UnCompletedWidth,UniqueID,_buff,_ind)

double ArrowUp[];
double ArrowDown[];

int OnInit()
{
   if (fmod(FractalPeriod,2)==0) FractalPeriod = FractalPeriod+1;
   IndicatorBuffers(3);
   SetIndexBuffer(0,UpperBuffer); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,159);
   SetIndexBuffer(1,LowerBuffer); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159);
   SetIndexBuffer(2,ArrowUp); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,233);
   SetIndexBuffer(3,ArrowDown); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,234);
   
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   
   return(INIT_SUCCEEDED);
}
void OnDeinit(int const reason)
{
   ObjectDelete(UniqueID+"up1");
   ObjectDelete(UniqueID+"up2");
   ObjectDelete(UniqueID+"dn1");
   ObjectDelete(UniqueID+"dn2");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int half = FractalPeriod/2;
   int i,counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=fmin(fmax(Bars-counted_bars,FractalPeriod),Bars-1);
   if (TimeFrame != _Period)
   {
      limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(2,0)*TimeFrame/_Period));
      for (i=limit;i>=1 && !_StopFlag; i--)
      {
         int y = iBarShift(NULL,TimeFrame,Time[i]);
         int x = iBarShift(NULL,TimeFrame,Time[i-1]); 
         if (x!=y)
         {
            UpperBuffer[i] = _mtfCall(0,y);
            LowerBuffer[i] = _mtfCall(1,y);
         } else
         {
            UpperBuffer[i] = EMPTY_VALUE;
            LowerBuffer[i] = EMPTY_VALUE; 
         } 
      }   
      return(rates_total);
   }
               
   for(i=limit; i>=0; i--)
   {
      if (i<Bars-1)
      {
         int k;
         bool   found     = true;
         double compareTo = High[i];
         double RSI = iRSI(NULL,0,14,PRICE_CLOSE,0);
         for (k=1;k<=half;k++)
         {
            if ((i+k)<Bars && High[i+k]> compareTo) { found=false; break; }
            if ((i-k)>=0   && High[i-k]>=compareTo) { found=false; break; }
         }
         if (found ) UpperBuffer[i]=High[i]+iATR(NULL,0,20,i)*UpperArrowDisplacement;
         else  UpperBuffer[i]=EMPTY_VALUE;

         found     = true;
         compareTo = Low[i];
         for (k=1;k<=half;k++)
         {
            if ((i+k)<Bars && Low[i+k]< compareTo) { found=false; break; }
            if ((i-k)>=0   && Low[i-k]<=compareTo) { found=false; break; }
         }
         if (found ) LowerBuffer[i]=Low[i]-iATR(NULL,0,20,i)*LowerArrowDisplacement;
         else LowerBuffer[i]=EMPTY_VALUE;
      }
   }
 
    
   int lastUp[4];
   int lastDn[4];
   int dnInd = -1;
   int upInd = -1;
   for (i=0; i<Bars; i++)
   {
      if (upInd<3 && UpperBuffer[i] != EMPTY_VALUE) { upInd++; lastUp[upInd] = i; }
      if (dnInd<3 && LowerBuffer[i] != EMPTY_VALUE) { dnInd++; lastDn[dnInd] = i; }
      if (upInd==3 && dnInd==3) break;
   }
   //  createLine("up1",High[lastUp[1]],Time[lastUp[1]],High[lastUp[0]],Time[lastUp[0]],UpperUnCompletedColor,UnCompletedWidth);
   createLine("up2",High[lastUp[3]],Time[lastUp[3]],High[lastUp[0]],Time[lastUp[0]],UpperCompletedColor,CompletedWidth);
   //  createLine("dn1",Low[lastDn[1]] ,Time[lastDn[1]],Low[lastDn[0]] ,Time[lastDn[0]],LowerUnCompletedColor,UnCompletedWidth);
   createLine("dn2",Low[lastDn[3]] ,Time[lastDn[3]],Low[lastDn[0]] ,Time[lastDn[0]],LowerCompletedColor,CompletedWidth);
   
   double Up = ObjectGetValueByShift(UniqueID+"up2",1);
   double Up2 = ObjectGetValueByShift(UniqueID+"up2",2);
   double Dn = ObjectGetValueByShift(UniqueID+"dn2",1);
   double Dn2 = ObjectGetValueByShift(UniqueID+"dn2",2);
   
 if (Low[1] <= Dn && /*open[0] > Dn &&*/ Dn > Dn2 /*&& Up < Up2*/ ) ArrowUp[0] = low[0];
 if (High[1] >= Up && /*open[0] < Up && */Up < Up2/*&& Dn > Dn2 */) ArrowDown[0] = high[0];
 //  if (/*open[1] >  Dn && close[1] > Dn &&*/ Up > Up2 /*&& Dn > Dn2*/)  ArrowUp[0] = low[0];
 //  if (/*open[1] < Up && close[1] < Up && */Dn < Dn2 /*&&Up < Up2*/ ) ArrowDown[0] = high[0];
   return(rates_total);
   
}

void createLine(string add, double price1, datetime time1, double price2, datetime time2, color theColor, int width)
{
   string name = UniqueID+add;
   ObjectDelete(name);
   ObjectCreate(name,OBJ_TREND,0,time1,price1,time2,price2);
   ObjectSet(name,OBJPROP_COLOR,theColor);
   ObjectSet(name,OBJPROP_WIDTH,width);
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

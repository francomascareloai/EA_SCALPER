//+------------------------------------------------------------------+
//|                                     Fractals - adjustable period |
//+------------------------------------------------------------------+
#property link      "www.forex-station.com"
#property copyright "www.forex-station.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrPaleVioletRed
#property indicator_width1  2
#property indicator_width2  2
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame              = PERIOD_CURRENT;       // Time frame
extern int             FractalPeriod          = 25;                   // Fractal period
extern double          UpperArrowDisplacement = 0.2;                  // Upper fractal displacement
extern double          LowerArrowDisplacement = 0.2;                  // Lower fractal displacement
extern color           UpperCompletedColor    = clrDeepSkyBlue;       // Upper trend line completed color 
extern color           UpperUnCompletedColor  = clrAqua;              // Upper trend line uncompleted color
extern color           LowerCompletedColor    = clrPaleVioletRed;     // Lower trend line completed color
extern color           LowerUnCompletedColor  = clrHotPink;           // Lower trend line uncompleted color
extern int             CompletedWidth         = 2;                    // Completed trend line width 
extern int             UnCompletedWidth       = 1;                    // Uncompleted trend line width
extern string          UniqueID               = "FractalTrendLines1"; // Trend line unique ID.

double UpperBuffer[],LowerBuffer[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,FractalPeriod,UpperArrowDisplacement,LowerArrowDisplacement,UpperCompletedColor,UpperUnCompletedColor,LowerCompletedColor,LowerUnCompletedColor,CompletedWidth,UnCompletedWidth,UniqueID,_buff,_ind)

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
   if (fmod(FractalPeriod,2)==0) FractalPeriod = FractalPeriod+1;
   IndicatorBuffers(3);
   SetIndexBuffer(0,UpperBuffer); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,159);
   SetIndexBuffer(1,LowerBuffer); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159);
   SetIndexBuffer(2,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   
return(0);
}
int deinit()
{
   ObjectDelete(UniqueID+"up1");
   ObjectDelete(UniqueID+"up2");
   ObjectDelete(UniqueID+"dn1");
   ObjectDelete(UniqueID+"dn2");
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
   int half = FractalPeriod/2;
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit=fmin(fmax(Bars-counted_bars,FractalPeriod),Bars-1);
         if (TimeFrame != _Period)
         {
            limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(2,0)*TimeFrame/_Period));
            for (i=limit;i>=0 && !_StopFlag; i--)
            {
                int y = iBarShift(NULL,TimeFrame,Time[i]);
                int x = iBarShift(NULL,TimeFrame,Time[i-1]); 
                if (x!=y)
                {
                   UpperBuffer[i] = _mtfCall(0,y);
                   LowerBuffer[i] = _mtfCall(1,y);
                }
                else
                {
                    UpperBuffer[i] = EMPTY_VALUE;
                    LowerBuffer[i] = EMPTY_VALUE; 
                } 
            }   
          return(0);
          }
                     
   
   
   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--)
   {
      if (i<Bars-1)
      {
         int k;
         bool   found     = true;
         double compareTo = High[i];
         for (k=1;k<=half;k++)
            {
               if ((i+k)<Bars && High[i+k]> compareTo) { found=false; break; }
               if ((i-k)>=0   && High[i-k]>=compareTo) { found=false; break; }
            }
         if (found) 
               UpperBuffer[i]=High[i]+iATR(NULL,0,20,i)*UpperArrowDisplacement;
         else  UpperBuffer[i]=EMPTY_VALUE;

      //
      //
      //
      //
      //
      
         found     = true;
         compareTo = Low[i];
         for (k=1;k<=half;k++)
            {
               if ((i+k)<Bars && Low[i+k]< compareTo) { found=false; break; }
               if ((i-k)>=0   && Low[i-k]<=compareTo) { found=false; break; }
            }
         if (found)
              LowerBuffer[i]=Low[i]-iATR(NULL,0,20,i)*LowerArrowDisplacement;
         else LowerBuffer[i]=EMPTY_VALUE;
      }
   }
 
 
   //
   //
   //
   //
   //

      int lastUp[3];
      int lastDn[3];
         int dnInd = -1;
         int upInd = -1;
         for (i=0; i<Bars; i++)
         {
            if (upInd<2 && UpperBuffer[i] != EMPTY_VALUE) { upInd++; lastUp[upInd] = i; }
            if (dnInd<2 && LowerBuffer[i] != EMPTY_VALUE) { dnInd++; lastDn[dnInd] = i; }
               if (upInd==2 && dnInd==2) break;
         }
         createLine("up1",High[lastUp[1]],Time[lastUp[1]],High[lastUp[0]],Time[lastUp[0]],UpperUnCompletedColor,UnCompletedWidth);
         createLine("up2",High[lastUp[2]],Time[lastUp[2]],High[lastUp[1]],Time[lastUp[1]],UpperCompletedColor,CompletedWidth);
         createLine("dn1",Low[lastDn[1]] ,Time[lastDn[1]],Low[lastDn[0]] ,Time[lastDn[0]],LowerUnCompletedColor,UnCompletedWidth);
         createLine("dn2",Low[lastDn[2]] ,Time[lastDn[2]],Low[lastDn[1]] ,Time[lastDn[1]],LowerCompletedColor,CompletedWidth);
   return(0);
}

//
//
//
//
//

void createLine(string add, double price1, datetime time1, double price2, datetime time2, color theColor, int width)
{
   string name = UniqueID+add;
      ObjectDelete(name);
      ObjectCreate(name,OBJ_TREND,0,time1,price1,time2,price2);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,width);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

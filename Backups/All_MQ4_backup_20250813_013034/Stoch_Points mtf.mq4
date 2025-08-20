//+------------------------------------------------------------------+
//|                                              StochWithPoints.mq4 |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "*"
#property link      "*"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 6
#property indicator_color1 DeepSkyBlue
#property indicator_width1 0
#property indicator_color2 Goldenrod
#property indicator_width2 0
#property indicator_color3 Yellow
#property indicator_width3 1
#property indicator_color4 Yellow
#property indicator_width4 1
#property indicator_color5 Red
#property indicator_width5 0
#property indicator_color6 Lime
#property indicator_width6 0
//---#property indicator_level1 20
//---#property indicator_level2 80
//---- input parameters
extern string TimeFrame       = "Current time frame";
extern int       K=14;//5;
extern int       D=3;
extern int       S=8;//3;
extern int       Method=0;
extern int       Price=0;
extern int       MainHP=3;
extern int       SignalHP=3;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
string indicatorFileName;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,234);//(4,159);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,233);//(5,159);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexDrawBegin(0,K+D+S);
   SetIndexDrawBegin(1,K+D+S);   
   SetIndexDrawBegin(2,K+D+S);   
   SetIndexDrawBegin(3,K+D+S);   
   SetIndexDrawBegin(4,K+D+S);   
   SetIndexDrawBegin(5,K+D+S);   
   IndicatorShortName("S_p");
         timeFrame         = stringToTimeFrame(TimeFrame);
         indicatorFileName = WindowExpertName();
         returnBars        = (TimeFrame=="returnBars"); if (returnBars) return(0);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(MathMax(Bars-counted_bars,MathMax(MainHP,SignalHP)*2+1),Bars-1);
           if (returnBars) { ExtMapBuffer1[0] = limit+1; return(0); }
           if (timeFrame!=Period())
           {
               limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
               for(int i=limit;i>=0;i--)
               {
                  int y = iBarShift(NULL,timeFrame,Time[i]);
                  int x = iBarShift(NULL,timeFrame,Time[i+1]);
                     ExtMapBuffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"",K,D,S,Method,Price,MainHP,SignalHP,0,y);
                     ExtMapBuffer2[i] = iCustom(NULL,timeFrame,indicatorFileName,"",K,D,S,Method,Price,MainHP,SignalHP,1,y);
                     if (x!=y)
                     {
                        ExtMapBuffer3[i] = iCustom(NULL,timeFrame,indicatorFileName,"",K,D,S,Method,Price,MainHP,SignalHP,2,y);
                        ExtMapBuffer4[i] = iCustom(NULL,timeFrame,indicatorFileName,"",K,D,S,Method,Price,MainHP,SignalHP,3,y);
                        ExtMapBuffer5[i] = iCustom(NULL,timeFrame,indicatorFileName,"",K,D,S,Method,Price,MainHP,SignalHP,4,y);
                        ExtMapBuffer6[i] = iCustom(NULL,timeFrame,indicatorFileName,"",K,D,S,Method,Price,MainHP,SignalHP,5,y);
                     }
                     else
                     {
                        ExtMapBuffer3[i] = EMPTY_VALUE;
                        ExtMapBuffer4[i] = EMPTY_VALUE;
                        ExtMapBuffer5[i] = EMPTY_VALUE;
                        ExtMapBuffer6[i] = EMPTY_VALUE;
                     }
               }
               return(0);     

           }

      //
      //
      //
      //
      //
        
      for(i=limit;i>=0;i--){
         ExtMapBuffer1[i]=iStochastic(NULL,0,K,D,S,Method,Price,0,i);
         ExtMapBuffer2[i]=iStochastic(NULL,0,K,D,S,Method,Price,1,i);         
         ExtMapBuffer3[i+MainHP]   = EMPTY_VALUE;
         ExtMapBuffer4[i+MainHP]   = EMPTY_VALUE;
         ExtMapBuffer5[i+SignalHP] = EMPTY_VALUE;
         ExtMapBuffer6[i+SignalHP] = EMPTY_VALUE;
         if(ArrayMaximum(ExtMapBuffer1,MainHP*2+1,i)==i+MainHP)
         ExtMapBuffer3[i+MainHP]=ExtMapBuffer1[i+MainHP];
         if(ArrayMinimum(ExtMapBuffer1,MainHP*2+1,i)==i+MainHP)
         ExtMapBuffer4[i+MainHP]=ExtMapBuffer1[i+MainHP];     
         
         if(ArrayMaximum(ExtMapBuffer2,SignalHP*2+1,i)==i+SignalHP)
         ExtMapBuffer5[i+SignalHP]=ExtMapBuffer2[i+SignalHP];
         if(ArrayMinimum(ExtMapBuffer2,SignalHP*2+1,i)==i+SignalHP)
         ExtMapBuffer6[i+SignalHP]=ExtMapBuffer2[i+SignalHP];             
      }
   return(0);
  }
//+------------------------------------------------------------------+

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

//
//
//
//
//

int stringToTimeFrame(string tfs) {
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str) {
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--) {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}
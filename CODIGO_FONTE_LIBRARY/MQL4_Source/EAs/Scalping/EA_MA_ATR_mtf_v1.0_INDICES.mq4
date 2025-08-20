//+------------------------------------------------------------------+
//|                                                       MA-ATR.mq4 |
//|                                         Copyright 2014, RasoulFX |
//|                                     http://rasoulfx.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, RasoulFX"
#property link      "http://rasoulfx.blogspot.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  clrBlack
#property indicator_color2  clrRed
#property indicator_color3  clrRed
#property indicator_color4  clrGreen
#property indicator_color5  clrGreen
#property strict

extern ENUM_TIMEFRAMES   TimeFrame               = PERIOD_CURRENT;  // Time frame
input string             InpMovingAverageComment ="~~~Settings for Moving Average~~~";
input int                InpMAPeriod             = 10;              // Ma period
input ENUM_MA_METHOD     InpMAMethod             = MODE_LWMA;       // Ma type
input ENUM_APPLIED_PRICE InpMAPrice              = PRICE_TYPICAL;   // Ma price
input string             InpATRComment           ="~~~Settings for ATR~~~";
input int                InpATRPeriod            = 5;               // Atr period
input double             InpFirstATRBandRatio    = 1.5;             // First Atr distance between bands
input double             InpSecondATRBandRatio   = 2.0;             // Second Atr distance between bands
input string             InpSignalComment        ="~~~Settings for BUY/SELL Signal~~~";
input int                InpGapMA                = 3;               // Ma gap
input bool               Interpolate             = true;            // Interpolate in multi time frame mode?

double ExtMABuffer[],ExtMAplusATR2Buffer[],ExtMAplusATR1Buffer[],ExtMAminusATR1Buffer[],ExtMAminusATR2Buffer[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",InpMAPeriod,InpMAMethod,InpMAPrice,"",InpATRPeriod,InpFirstATRBandRatio,InpSecondATRBandRatio,"",InpGapMA,_buff,_y)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   if(InpATRPeriod < 2 || InpMAPeriod < 2) return(INIT_FAILED);
   IndicatorBuffers(6);   
   SetIndexBuffer(0,ExtMABuffer);           SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);  SetIndexLabel(0,"MA");
   SetIndexBuffer(1,ExtMAplusATR2Buffer);   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);  SetIndexLabel(1,"MA+1.5ATR");
   SetIndexBuffer(2,ExtMAplusATR1Buffer);   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);    SetIndexLabel(2,"MA+1.0ATR");
   SetIndexBuffer(3,ExtMAminusATR1Buffer);  SetIndexStyle(3,DRAW_LINE,STYLE_DOT);    SetIndexLabel(3,"MA-1.0ATR");
   SetIndexBuffer(4,ExtMAminusATR2Buffer);  SetIndexStyle(4,DRAW_LINE,STYLE_SOLID);  SetIndexLabel(4,"MA-1.5ATR");
   SetIndexBuffer(5,count); 
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
      
   IndicatorShortName(timeFrameToString(TimeFrame)+" MAATR("+string(InpMAPeriod)+")");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& btime[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] )
{

   int i,counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
            int limit=MathMin(rates_total-counted_bars,rates_total-1); count[0] = limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(5,0)*TimeFrame/_Period));
               for (i=limit;i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,btime[i]);
                     ExtMABuffer[i]          = _mtfCall(0,y);
                     ExtMAplusATR2Buffer[i]  = _mtfCall(1,y);
                     ExtMAplusATR1Buffer[i]  = _mtfCall(2,y);
                     ExtMAminusATR1Buffer[i] = _mtfCall(3,y);
                     ExtMAminusATR2Buffer[i] = _mtfCall(4,y);
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,btime[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<rates_total && btime[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
                        {
                           _interpolate(ExtMABuffer);
                           _interpolate(ExtMAplusATR2Buffer);
                           _interpolate(ExtMAplusATR1Buffer);
                           _interpolate(ExtMAminusATR1Buffer);
                           _interpolate(ExtMAminusATR2Buffer);
                        }                  
               }
              
   return(rates_total);
   }               
   
   //
   //
   //
   //
   //
   
   for(i=limit; i>=0; i--)
   {
      ExtMABuffer[i] = iMA(NULL,0,InpMAPeriod,0,InpMAMethod,InpMAPrice,i);
      double curATR  = iATR(NULL,0,InpATRPeriod,i);
      ExtMAplusATR1Buffer[i]  = ExtMABuffer[i]+InpFirstATRBandRatio*curATR;
      ExtMAminusATR1Buffer[i] = ExtMABuffer[i]-InpFirstATRBandRatio*curATR;
      ExtMAplusATR2Buffer[i]  = ExtMABuffer[i]+InpSecondATRBandRatio*curATR;
      ExtMAminusATR2Buffer[i] = ExtMABuffer[i]-InpSecondATRBandRatio*curATR;      
   }
return(rates_total);
}

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


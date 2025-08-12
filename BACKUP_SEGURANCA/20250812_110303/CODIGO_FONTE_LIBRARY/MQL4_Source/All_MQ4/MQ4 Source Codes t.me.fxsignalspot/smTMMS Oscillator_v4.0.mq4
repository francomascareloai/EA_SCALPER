//+------------------------------------------------------------------+
//|                                       smTMMS Oscillator_vX
//+------------------------------------------------------------------+
#property copyright "Copyright 16.08.2019, SwingMan"
#property strict
#property indicator_separate_window

//16.08.2019   -  v4.0  -  with Alerts

#property indicator_buffers 8

#property indicator_color1 clrSienna      //lines
#property indicator_color2 clrLime
#property indicator_color3 clrSlateGray 
#property indicator_color4 clrGreen       //histograms
#property indicator_color5 clrRed
#property indicator_color6 clrDarkGray
#property indicator_color7 clrLime        //arrows
#property indicator_color8 clrOrange

#property indicator_width1 1              //lines
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 3              //histograms
#property indicator_width5 3
#property indicator_width6 3
#property indicator_width7 1              //arrows
#property indicator_width8 1

#property indicator_level1 20
#property indicator_level2 0
#property indicator_level3 -20
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1

#property indicator_maximum 50
#property indicator_minimum -50
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ARROW_TYPE
  {
   Circle,
   Rectangle
  };

//--- inputs
//+------------------------------------------------------------------+
input bool           Draw_Oscillator_Lines=false;
sinput string        sRSI="RSI"; //=================================     
input int            RSI_Period=14;
input ENUM_APPLIED_PRICE      RSI_AppliedPrice=PRICE_CLOSE;
//
sinput string        sStochastic="STOCHASTIC"; //=================================    
input int            Stochastic_1_Period_K  = 8;
input int            Stochastic_1_Period_D  = 3;
input int            Stochastic_1_Slowing   = 3;
input ENUM_STO_PRICE Stochastic_1_PriceField = STO_LOWHIGH;
input ENUM_MA_METHOD Stochastic_1_MAmethod   = MODE_SMMA;
input int            Stochastic_2_Period_K  = 14;
input int            Stochastic_2_Period_D  = 3;
input int            Stochastic_2_Slowing   = 3;
input ENUM_STO_PRICE Stochastic_2_PriceField = STO_LOWHIGH;
input ENUM_MA_METHOD Stochastic_2_MAmethod   = MODE_SMMA;
//
sinput string             sHullAverage="HULL MovingAverage"; //=================================  
input bool                Draw_HullTrend  =true;
input int                 Hull_Period     =12;
input double              Hull_Divisor    =2;
input ENUM_APPLIED_PRICE  Hull_AppliedPrice=PRICE_CLOSE;
input ENUM_ARROW_TYPE     Arrow_Type=Circle;
//
sinput string             sAlerts="Alerts"; //=================================  
extern double Alert_Threshold_Line=20;
extern bool SendSignal_Alerts =true;
extern bool SendSignal_Emails =false;
//extern bool Send_Notifications=false;
//+------------------------------------------------------------------+

//---- buffers
double bufRSI[],bufStoch1[],bufStoch2[];
double bufHistUP[],bufHistDN[],bufHistNO[];
double bufHullUP[],bufHullDN[],bufHull[],buffHullAvg[],trend[];
double oscAlert[],oscSignal[];
//--- variables
datetime thisTime,oldTime;
bool newBar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int iArrow=108;
//--- indicator buffers mapping
   int iBuff=-1;
//--- lines   
   iBuff++; SetIndexBuffer(iBuff,bufRSI);     SetIndexStyle(iBuff,DRAW_LINE); SetIndexLabel(iBuff,"RSI"); if(Draw_Oscillator_Lines==false) SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++; SetIndexBuffer(iBuff,bufStoch1);  SetIndexStyle(iBuff,DRAW_LINE); SetIndexLabel(iBuff,"Stochastic ("+(string)Stochastic_1_Period_K+")"); if(Draw_Oscillator_Lines==false) SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++; SetIndexBuffer(iBuff,bufStoch2);  SetIndexStyle(iBuff,DRAW_LINE); SetIndexLabel(iBuff,"Stochastic ("+(string)Stochastic_2_Period_K+")");
//--- histograms
   iBuff++; SetIndexBuffer(iBuff,bufHistUP);  SetIndexStyle(iBuff,DRAW_HISTOGRAM);  SetIndexLabel(iBuff,NULL);
   iBuff++; SetIndexBuffer(iBuff,bufHistDN);  SetIndexStyle(iBuff,DRAW_HISTOGRAM);  SetIndexLabel(iBuff,NULL);
   iBuff++; SetIndexBuffer(iBuff,bufHistNO);  SetIndexStyle(iBuff,DRAW_HISTOGRAM);  SetIndexLabel(iBuff,NULL);
//--- arrows - HULL moving average
   if(Arrow_Type==Circle) iArrow=108; else if(Arrow_Type==Rectangle) iArrow=110;
   iBuff++; SetIndexBuffer(iBuff,bufHullUP);  SetIndexStyle(iBuff,DRAW_ARROW); SetIndexArrow(iBuff,iArrow); SetIndexLabel(iBuff,"HMA_Trend UP");   if(Draw_HullTrend==false) SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++; SetIndexBuffer(iBuff,bufHullDN);  SetIndexStyle(iBuff,DRAW_ARROW); SetIndexArrow(iBuff,iArrow); SetIndexLabel(iBuff,"HMA_Trend DOWN"); if(Draw_HullTrend==false) SetIndexStyle(iBuff,DRAW_NONE);

//--- more buffers
   IndicatorBuffers(13);
   iBuff++; SetIndexBuffer(iBuff,bufHull);
   iBuff++; SetIndexBuffer(iBuff,buffHullAvg);
   iBuff++; SetIndexBuffer(iBuff,trend);
   iBuff++; SetIndexBuffer(iBuff,oscAlert);  SetIndexEmptyValue(iBuff,EMPTY_VALUE);
   iBuff++; SetIndexBuffer(iBuff,oscSignal); SetIndexEmptyValue(iBuff,EMPTY_VALUE);
//---
   IndicatorDigits(2);
   return(INIT_SUCCEEDED);
  }
//---

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
   int    i,pos;
   double threshold=50,limit=0;

//---
   if(rates_total<=10)
      return(0);

   thisTime=Time[0];
   if(thisTime!=oldTime) {oldTime=thisTime; newBar=true;} else newBar=false;

   pos=0;

//--- main loop of calculations
   for(i=pos; i<rates_total; i++)
     {
      //--- oscillators
      bufRSI[i]=iRSI(Symbol(),Period(),RSI_Period,RSI_AppliedPrice,i);
      bufStoch1[i]=iStochastic(Symbol(),Period(),
                               Stochastic_1_Period_K,Stochastic_1_Period_D,Stochastic_1_Slowing,
                               Stochastic_1_MAmethod,Stochastic_1_PriceField,MODE_MAIN,i);
      bufStoch2[i]=iStochastic(Symbol(),Period(),
                               Stochastic_2_Period_K,Stochastic_2_Period_D,Stochastic_2_Slowing,
                               Stochastic_2_MAmethod,Stochastic_2_PriceField,MODE_MAIN,i);
      bufRSI[i]=bufRSI[i]-threshold;
      bufStoch1[i]=bufStoch1[i]-threshold;
      bufStoch2[i]=bufStoch2[i]-threshold;

      //--- histograms; Alerts
      bufHistUP[i]=EMPTY_VALUE;
      bufHistDN[i]=EMPTY_VALUE;
      bufHistNO[i]=EMPTY_VALUE;
      oscAlert[i] =EMPTY_VALUE;
      if(bufRSI[i]>limit && bufStoch1[i]>limit && bufStoch2[i]>limit)
        {
         bufHistUP[i]=bufStoch2[i];
         if(bufHistUP[i]>Alert_Threshold_Line) oscAlert[i]=1;
        }
      else
      if(bufRSI[i]<limit && bufStoch1[i]<limit && bufStoch2[i]<limit)
        {
         bufHistDN[i]=bufStoch2[i];
         if(bufHistUP[i]<-Alert_Threshold_Line) oscAlert[i]=-1;
        }
      else
        {
         bufHistNO[i]=bufStoch2[i];
        }
     }

//==========================
//--- Last bar; Alerts at previous bar
   i=0;
   if(newBar==true)
     {
      if(oscAlert[i+2]==EMPTY_VALUE && oscAlert[i+1]==1 && oscSignal[i]==EMPTY_VALUE)
        {
         SendAlerts(i,OP_BUY,Symbol(),Period());
         oscSignal[i]=1;
        }
      else
      if(oscAlert[i+2]==EMPTY_VALUE && oscAlert[i+1]==-1 && oscSignal[i]==EMPTY_VALUE)
        {
         SendAlerts(i,OP_SELL,Symbol(),Period());
         oscSignal[i]=1;
        }
     }

//--- Hull Moving Average   
   if(Draw_HullTrend==true)
      Get_HullMovingAverage(rates_total,bufHullUP,bufHullDN);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Get_HullMovingAverage(int limitX,double &hullUP[],double &hullDN[])
  {
   double zero=0;
//-- Hull moving average current TF -------------
   int MA_period1=(int)(Hull_Period/Hull_Divisor);
   int pPeriod=(int)MathSqrt(Hull_Period);

   for(int i=0; i<limitX; i++)
      bufHull[i]=2*iMA(Symbol(),Period(),MA_period1,0,MODE_LWMA,Hull_AppliedPrice,i)-
                 iMA(Symbol(),Period(),Hull_Period,0,MODE_LWMA,Hull_AppliedPrice,i);

   for(int i=0; i<limitX-Hull_Period; i++)
      buffHullAvg[i]=iMAOnArray(bufHull,0,pPeriod,0,MODE_LWMA,i);

//-- Arrows Hull moving average trend -----------
   for(int i=limitX-Hull_Period-1; i>=0; i--)
     {
      //trend[i]=trend[i+1];
      if(buffHullAvg[i]>=buffHullAvg[i+1]) trend[i]=1; else trend[i]=-1;

      if(trend[i]>0)
        {
         hullUP[i]=zero;
         hullDN[i]=EMPTY_VALUE;
        }
      else
      if(trend[i]<0)
        {
         hullUP[i]=EMPTY_VALUE;
         hullDN[i]=zero;
        }
     }
  }
//                            *****************************                          
//                            **       ALERTS            **
//                            *****************************
//+------------------------------------------------------------------+
//    Send Alerts 
//+------------------------------------------------------------------+
void SendAlerts(int iBar,int iSignalDirection,string sSymbol,int iPeriod)
  {
   if(SendSignal_Alerts == false && SendSignal_Emails == false) return;
//---
   string subjectEmailAlert="TMMS Oscillator";

   string   sPeriod     = " ("+Get_PeriodString(iPeriod)+") ";
   double   dEntryPrice = iOpen(sSymbol,iPeriod,iBar);
   string   sEntryPrice = " "+DoubleToString(dEntryPrice,Digits);
   string   sTime       = "  " + TimeToStr(TimeCurrent(),TIME_MINUTES|TIME_SECONDS) + "  ";
   string   sBarTime    = "  Bar: " + TimeToStr(Time[iBar],TIME_MINUTES|TIME_SECONDS) + "  ";

   string sText,sTextAlert;

//--- LONG Entry Signal ------------------------------------------
   if(iSignalDirection==OP_BUY)
     {
      sText=" LONG entry";
     }
   else

//--- SHORT Entry Signal -----------------------------------------
   if(iSignalDirection==OP_SELL)
     {
      sText=" SHORT entry";
     }

//--- Send alerts
   sTextAlert=sSymbol+sPeriod+sText+sTime+"  TMMS Oscillator: "+sEntryPrice;

   if(SendSignal_Alerts==true) Alert(sTextAlert);

   if(SendSignal_Emails==true) SendMail(subjectEmailAlert,sTextAlert);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_PeriodString(int iPeriod)
  {
   string sPeriod;
   switch(iPeriod)
     {
      case PERIOD_M1:   sPeriod="M1"; break;
      case PERIOD_M5:   sPeriod="M5"; break;
      case PERIOD_M15:  sPeriod="M15"; break;
      case PERIOD_M30:  sPeriod="M30"; break;
      case PERIOD_H1:   sPeriod="H1"; break;
      case PERIOD_H4:   sPeriod="H4"; break;
      case PERIOD_D1:   sPeriod="D1"; break;
      case PERIOD_W1:   sPeriod="W1"; break;
      case PERIOD_MN1:  sPeriod="MN1"; break;
     }
   return(sPeriod);
  }
//+------------------------------------------------------------------+

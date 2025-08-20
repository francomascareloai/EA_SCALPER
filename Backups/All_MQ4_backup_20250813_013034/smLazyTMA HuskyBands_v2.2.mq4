//+------------------------------------------------------------------+
//|                                        smLazyTMA HuskyBands_vX
//+------------------------------------------------------------------+
#property copyright "Copyright 29.11.2020, SwingMan"
#property strict
#property indicator_chart_window

/*-------------------------------------------------------------------
Source code: Signals_v3.1
10.06.2019  v1 - Bands calculation with StdDev
12.06.2019  v2.1 - TMA calculate like TMAcentered (@mladen); Entry/Exit on Open
13.06.2019  v2.2 - Signal offset = 25% from ATR for Close1/Close0
14.06.2019  v3.1 - Signal filter with AvgSlope on last 5 bars;  one signal for last 10 bars; available signals remains
Husky Bands
18.06.2019  v1   -  Separate Bands for TMA(Highs) and TMA(Lows))
21.06.2019  v1.3 -  Correction: Bands drawing and for variables Bars, Total_Bars and limit
22.06.2019  v2.1 -  Alerts for signals
29.11.2020  v2.2 -  Notification Alerts for signals
--------------------------------------------------------------------*/

#property indicator_buffers 16

//---
#property indicator_color1  clrDodgerBlue       //TMA
#property indicator_color2  clrTomato

#property indicator_color3  clrChocolate        //upper bands
#property indicator_color4  clrHotPink
#property indicator_color5  clrMagenta
#property indicator_color6  clrMagenta

#property indicator_color7  clrChocolate        //lower bands
#property indicator_color8  clrSpringGreen
#property indicator_color9  clrMediumSeaGreen
#property indicator_color10 clrMediumSeaGreen

#property indicator_color15  clrMagenta            //TMA Highs/Lows
#property indicator_color16  clrMediumSeaGreen

//---
#property indicator_width1  4
#property indicator_width2  4

#property indicator_width3  1
#property indicator_width4  2
#property indicator_width5  1
#property indicator_width6  1

#property indicator_width7  1
#property indicator_width8  2
#property indicator_width9  1
#property indicator_width10 1

#property indicator_width15  2   //TMA Highs/Lows
#property indicator_width16  2

//---
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID

#property indicator_style3  STYLE_DASH
#property indicator_style4  STYLE_SOLID
#property indicator_style5  STYLE_SOLID
#property indicator_style6  STYLE_DOT

#property indicator_style7  STYLE_DASH
#property indicator_style8  STYLE_SOLID
#property indicator_style9  STYLE_SOLID
#property indicator_style10 STYLE_DOT
//---
//          ******************************
//                   ENUMS
//          ******************************
enum ENUM_THRESHOLD_BANDS
  {
   Band1,
   Band2,
   Band3,
   Band4
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_BAND_TYPE
  {
   Median_Band,
   HighLow_Bands
  };
//---

//+------------------------------------------------------------------+
//|         INPUTS
//+------------------------------------------------------------------+
input ENUM_BAND_TYPE         Band_Type       = Median_Band;
extern int                   HalfLength      =  34;            // Half Length
input int                    ma_period       =  4;             // MA averaging period
input ENUM_MA_METHOD         ma_method=MODE_LWMA;     // MA averaging method
//input ENUM_APPLIED_PRICE     applied_price=PRICE_MEDIAN;    // Applied Price
input int                    ATR_Period=144;           // ATR Period
extern int                   Total_Bars      =  1000;
input string ___Bands_Deviation_Multiplier="----------------------------------------------";
input double ATR_Multiplier_Band1   =1.0;
input double ATR_Multiplier_Band2   =1.618;
input double ATR_Multiplier_Band3   =2.236;
input double ATR_Multiplier_Band4   =2.854;
//
input string ___Bands_To_Draw="----------------------------------------------";
input bool Draw_HighLow_TMA         =true;
input bool Draw_Band1               =true;
input bool Draw_Band2               =true;
input bool Draw_Band3               =true;
input bool Draw_Band4               =true;
//
input string ___Signal_Arrows="----------------------------------------------";
input bool Draw_SignalArrows=true;
input ENUM_THRESHOLD_BANDS Threshold_Band=Band1;
extern bool SendSignal_Alerts=true;
extern bool SendSignal_Emails=false;
extern bool SendSignal_Notifications=false;
input int  ArrowCode_EntrySignal    = 181;
input int  ArrowCode_ExitSignal     = 203;
input int  Arrow_Width              = 1;
input color ArrowColor_SignalUP     = clrAqua;
input color ArrowColor_SignalDOWN   = clrMagenta;
input bool  Show_Comments   =  false;
/*====================================================================
--- more inputs:
Signals only in trend direction / countertrend signals
====================================================================*/
//
//--- constants
string CR="\n";
#define OP_NONE -1
string subjectEmailAlert="smLazyTMA HuskyBands";

#define LONG_ENTRY_TREND     1
#define LONG_ENTRY_COUNTER   2
#define LONG_EXIT_TREND      3
#define SHORT_ENTRY_TREND   -1
#define SHORT_ENTRY_COUNTER -2
#define SHORT_EXIT_TREND    -3

//---
//--- buffers
double tmaUP[],tmaDN[],tmaCentered[];
double bandUP1[],bandUP2[],bandUP3[],bandUP4[];
double bandDN1[],bandDN2[],bandDN3[],bandDN4[];
double slope[];
double arrowUP[],arrowDN[],exitUP[],exitDN[];
//--- High/Low buffers
double tmaCenteredHighs[],tmaCenteredLows[];
//---
double weights[];
double signalSended[];

//---
#define nSlopes 2000

double buffMomentum[nSlopes],slopeLine[nSlopes],arrSlopeSorted[nSlopes];

//---
//--- variables
datetime thisTime,oldTime;
bool newBar,newRedraw;

//--- TMA -----------------------------
double sumWeights=0;
int    fullLength;
int    applied_price;

//--- SlopeAverage --------------------
int MAvg3_Period=3;
int MAvg_Shift=1;
int MAvg_Mode=MODE_SMA;
int MAvg1_Period=1;
ENUM_APPLIED_PRICE MAvg_Price=PRICE_TYPICAL;
double slopeLimitValue;
int iMomentum_Direction;
string sMomentum_Direction;
//---
//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  ChartSetInteger(0,CHART_SHOW_GRID,0,false);
//--- Slopes
   ArraySetAsSeries(buffMomentum,true);
   ArraySetAsSeries(slopeLine,true);
   ArraySetAsSeries(arrSlopeSorted,true);
//---

   IndicatorBuffers(19);

   HalfLength=MathMax(HalfLength,1);
   fullLength=HalfLength*2+1;
   ArrayResize(weights,fullLength);
//---
   sumWeights          = HalfLength+1;
   weights[HalfLength] = HalfLength+1;
   for(int i=0; i<HalfLength; i++)
     {
      weights[i]              = i+1;
      weights[fullLength-i-1] = i+1;
      sumWeights             += i+i+2;
     }

//--- Band type
   string sBandUP,sBandDN;
   switch(Band_Type)
     {
      case Median_Band:
         sBandUP=" Middle";
         sBandDN=" Middle";
         break;
      case HighLow_Bands:
         sBandUP=" Highs";
         sBandDN=" Lows";
         break;
     }

//--- indicator buffers mapping
   int iBuff=-1;
   iBuff++;
   SetIndexBuffer(iBuff,tmaUP);
   SetIndexLabel(iBuff,"TMA UP");
   iBuff++;
   SetIndexBuffer(iBuff,tmaDN);
   SetIndexLabel(iBuff,"TMA DOWN");

//--- dont draw bands
   iBuff++;
   SetIndexBuffer(iBuff,bandUP1);
   SetIndexLabel(iBuff,"Upper Band 1"+sBandUP);
   if(Draw_Band1==false)
      SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++;
   SetIndexBuffer(iBuff,bandUP2);
   SetIndexLabel(iBuff,"Upper Band 2"+sBandUP);
   if(Draw_Band2==false)
      SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++;
   SetIndexBuffer(iBuff,bandUP3);
   SetIndexLabel(iBuff,"Upper Band 3"+sBandUP);
   if(Draw_Band3==false)
      SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++;
   SetIndexBuffer(iBuff,bandUP4);
   SetIndexLabel(iBuff,"Upper Band 4"+sBandUP);
   if(Draw_Band4==false)
      SetIndexStyle(iBuff,DRAW_NONE);

   iBuff++;
   SetIndexBuffer(iBuff,bandDN1);
   SetIndexLabel(iBuff,"Lower Band 1"+sBandDN);
   if(Draw_Band1==false)
      SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++;
   SetIndexBuffer(iBuff,bandDN2);
   SetIndexLabel(iBuff,"Lower Band 2"+sBandDN);
   if(Draw_Band2==false)
      SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++;
   SetIndexBuffer(iBuff,bandDN3);
   SetIndexLabel(iBuff,"Lower Band 3"+sBandDN);
   if(Draw_Band3==false)
      SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++;
   SetIndexBuffer(iBuff,bandDN4);
   SetIndexLabel(iBuff,"Lower Band 4"+sBandDN);
   if(Draw_Band4==false)
      SetIndexStyle(iBuff,DRAW_NONE);

   iBuff++;
   SetIndexBuffer(iBuff,arrowUP);
   SetIndexLabel(iBuff,"LONG entry");
   SetIndexStyle(iBuff,DRAW_ARROW,EMPTY,Arrow_Width,ArrowColor_SignalUP);
   SetIndexArrow(iBuff,ArrowCode_EntrySignal);
   iBuff++;
   SetIndexBuffer(iBuff,arrowDN);
   SetIndexLabel(iBuff,"SHORT entry");
   SetIndexStyle(iBuff,DRAW_ARROW,EMPTY,Arrow_Width,ArrowColor_SignalDOWN);
   SetIndexArrow(iBuff,ArrowCode_EntrySignal);
   iBuff++;
   SetIndexBuffer(iBuff,exitUP);
   SetIndexLabel(iBuff,"LONG exit");
   SetIndexStyle(iBuff,DRAW_ARROW,EMPTY,Arrow_Width,ArrowColor_SignalUP);
   SetIndexArrow(iBuff,ArrowCode_ExitSignal);
   iBuff++;
   SetIndexBuffer(iBuff,exitDN);
   SetIndexLabel(iBuff,"SHORT exit");
   SetIndexStyle(iBuff,DRAW_ARROW,EMPTY,Arrow_Width,ArrowColor_SignalDOWN);
   SetIndexArrow(iBuff,ArrowCode_ExitSignal);

//--- dont draw Highs/Lows
   iBuff++;
   SetIndexBuffer(iBuff,tmaCenteredHighs);
   SetIndexLabel(iBuff,"TMA Highs");
   if(Draw_HighLow_TMA==false)
      SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++;
   SetIndexBuffer(iBuff,tmaCenteredLows);
   SetIndexLabel(iBuff,"TMA Lows");
   if(Draw_HighLow_TMA==false)
      SetIndexStyle(iBuff,DRAW_NONE);

//--- more buffers --------------------
   iBuff++;
   SetIndexBuffer(iBuff,tmaCentered);
   iBuff++;
   SetIndexBuffer(iBuff,slope);
   iBuff++;
   SetIndexBuffer(iBuff,signalSended);

//--- array settings ------------------
   for(int ii=0; ii<=iBuff; ii++)
     {
      SetIndexEmptyValue(ii,EMPTY_VALUE);
      SetIndexDrawBegin(ii,HalfLength+ATR_Period+10);
     }
//---

   IndicatorDigits(Digits+2);

//----   Indicator name -----------------------------------
   string shortName=WindowExpertName()+" ("+(string)HalfLength+") ";
   IndicatorShortName(shortName);
   if(Show_Comments)
      Comment(shortName,CR,"===========================");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(Show_Comments==true)
      Comment("");
  }
//
//
//
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
   int i;
   int limit;

//-- 1. check new bar -------------------------------------
   thisTime=iTime(Symbol(),Period(),0);
   if(thisTime!=oldTime)
     {
      newBar=true;
      oldTime=thisTime;
      newRedraw=true;
     }
   else
     {
      newBar=false;
      newRedraw=false;
     }

//---

   int counted_bars=IndicatorCounted();

   if(counted_bars<0)
      return(-1);
   if(counted_bars>0)
      counted_bars--;
   limit=Bars-counted_bars;

   if(Bars<Total_Bars-ATR_Period)
      Total_Bars=Bars-ATR_Period-10;

   if(limit>Total_Bars)
      limit=Total_Bars;

//--- colored TMA -----------------------------------------
   if(newBar==true)
     {
      Calculate_TMA_AVERAGE(limit,PRICE_MEDIAN,tmaCentered,tmaUP,tmaDN,slope);

      switch(Band_Type)
        {
         case Median_Band:
            //Calculate_TMA_AVERAGE(PRICE_MEDIAN,tmaCentered,tmaUP,tmaDN,slope);
            break;
         case HighLow_Bands:
            Calculate_TMA_AVERAGE(limit,PRICE_HIGH,tmaCenteredHighs,tmaUP,tmaDN,slope);
            Calculate_TMA_AVERAGE(limit,PRICE_LOW,tmaCenteredLows,tmaUP,tmaDN,slope);
            break;
        }

      Calculate_TMA_BANDS(limit,tmaCentered,tmaCenteredHighs,tmaCenteredLows,
                          bandUP1,bandUP2,bandUP3,bandUP4,
                          bandDN1,bandDN2,bandDN3,bandDN4);

      //                *******************************************
      //                            DRAW SIGNALS
      //                *******************************************
      if(Draw_SignalArrows==true)
        {
         //--- Entry Signals ---------------------------------------  FOR NEW BAR-0 / Check BAR-1 / Signal on BAR-0 on OPEN
         for(i=limit; i>=0 && !IsStopped(); i--)
           {
            Get_SlopeMomentumValues(Symbol(),Period(),i);
            double dATRoffset=0;

            double dClose0=Close[i+1];
            double dClose1=Close[i+1+1];

            //--- last bar
            if(i==0)
              {
               arrowUP[i]=EMPTY_VALUE;
               arrowDN[i]=EMPTY_VALUE;
              }

            bool signalOK;
            int nBarsCheckClosesAtBands=5;      //### input...
            int nBarsCheckOldSignals   =1;      //### input...
            //
            //===================================================
            //--- LONG signals ----------------------------------
            if(iMomentum_Direction==OP_BUY)
              {
               signalOK=true;
               for(int j=1; j<=nBarsCheckOldSignals; j++)
                 {
                  if(arrowUP[i+j]!=EMPTY_VALUE)
                    {
                     signalOK=false;
                     break;
                    }
                 }

               if(signalOK==true)
                 {
                  if(Open[i]<tmaCentered[i] && Open[i]<bandDN1[i])
                    {
                     //--- check band threshold
                     bool bThresholdBand=true;
                     if(Threshold_Band==Band2 && Open[i]>bandDN2[i])
                        bThresholdBand=false;
                     else
                        if(Threshold_Band==Band3 && Open[i]>bandDN3[i])
                           bThresholdBand=false;
                        else
                           if(Threshold_Band==Band4 && Open[i]>bandDN4[i])
                              bThresholdBand=false;

                     if(bThresholdBand==true)
                        for(int k=1; k<=nBarsCheckClosesAtBands; k++)
                          {
                           if(Close[i+k]<bandDN4[i+k] || Close[i+k]<bandDN3[i+k] || Close[i+k]<bandDN2[i+k] || Close[i+k]<bandDN1[i+k])
                             {
                              arrowUP[i]=Open[i];
                              if(i==0)
                                 SendAlerts(i,OP_BUY,Symbol(),Period(),slope);
                              break;
                             }
                          }
                    }
                 }
              }

            //====================================================
            //--- SHORT signals ----------------------------------
            //if(slope[i]<0 && iMomentum_Direction==OP_SELL)
            if(iMomentum_Direction==OP_SELL)
              {
               signalOK=true;
               for(int j=1; j<=nBarsCheckOldSignals; j++)
                 {
                  if(arrowDN[i+j]!=EMPTY_VALUE)
                    {
                     signalOK=false;
                     break;
                    }
                 }

               if(signalOK==true)
                 {
                  if(Open[i]>tmaCentered[i] && Open[i]>bandUP1[i])
                    {
                     //--- check band threshold
                     bool bThresholdBand=true;
                     if(Threshold_Band==Band2 && Open[i]<bandUP2[i])
                        bThresholdBand=false;
                     else
                        if(Threshold_Band==Band3 && Open[i]<bandUP3[i])
                           bThresholdBand=false;
                        else
                           if(Threshold_Band==Band4 && Open[i]<bandUP4[i])
                              bThresholdBand=false;
                     if(bThresholdBand==true)
                        for(int k=1; k<=nBarsCheckClosesAtBands; k++)
                          {
                           if(Close[i+k]>bandUP4[i+k] || Close[i+k]>bandUP3[i+k] || Close[i+k]>bandUP2[i+k] || Close[i+k]>bandUP1[i+k])
                             {
                              arrowDN[i]=Open[i];
                              if(i==0)
                                 SendAlerts(i,OP_SELL,Symbol(),Period(),slope);
                              break;
                             }
                          }
                    }
                 }
              }
           }//Entry Signals

         //==========================================================
         //--- Exit Signals ----------------------------------------- FOR NEW BAR-0 / on OPEN / for color change
         for(i=limit; i>=0 && !IsStopped(); i--)
           {
            double dSlope0=slope[i+1];
            double dSlope1=slope[i+1+1];
            exitUP[i]=EMPTY_VALUE;
            exitDN[i]=EMPTY_VALUE;

            //--- LONG signals ----------------------------------
            if(dSlope0<0 && dSlope1>=0)
              {
               exitUP[i]=Open[i];
              }

            //--- SHORT signals ----------------------------------
            if(dSlope0>=0 && dSlope1<0)
              {
               exitDN[i]=Open[i];
              }
           }//Exit Signals
        }//if(Draw_SignalArrows==true)
     }
//--- return value of prev_calculated for next call
   WindowRedraw();

   return(rates_total);
  }
//+------------------------------------------------------------------+
//    Send Alerts
//+------------------------------------------------------------------+
void SendAlerts(int iBar,int iSignalDirection,string sSymbol,int iPeriod,double &slopeX[])
  {
   if(SendSignal_Alerts == false && SendSignal_Emails == false)
      return;
   if(signalSended[iBar]!=0 && signalSended[iBar]!=EMPTY_VALUE)
      return;

   string   sPeriod     = " ("+Get_PeriodString(iPeriod)+") ";
   double   dEntryPrice = iOpen(sSymbol,iPeriod,iBar);
   string   sEntryPrice = " "+DoubleToString(dEntryPrice,Digits);
   string   sTime       = "  " + TimeToStr(TimeCurrent(),TIME_MINUTES|TIME_SECONDS) + "  ";
   string   sBarTime    = "  Bar: " + TimeToStr(Time[iBar],TIME_MINUTES|TIME_SECONDS) + "  ";

   int iBandPosition=0,iSignalType=0;
   string sText,sTextAlert;
   double dSlope=slopeX[iBar];

//--- LONG Entry Signal ------------------------------------------
   if(iSignalDirection==OP_BUY)
     {
      if(dEntryPrice<bandDN4[iBar])
         iBandPosition=4;
      else
         if(dEntryPrice<bandDN3[iBar])
            iBandPosition=3;
         else
            if(dEntryPrice<bandDN2[iBar])
               iBandPosition=2;
            else
               if(dEntryPrice<bandDN1[iBar])
                  iBandPosition=1;

      if(dSlope>0)
        {
         iSignalType=LONG_ENTRY_TREND;
         sText=" LONG entry Trend";
        }
      else
         if(dSlope<0)
           {
            iSignalType=LONG_ENTRY_COUNTER;
            sText=" LONG entry CounterTrend";
           }
     }
   else

      //--- SHORT Entry Signal -----------------------------------------
      if(iSignalDirection==OP_SELL)
        {
         if(dEntryPrice>bandUP4[iBar])
            iBandPosition=4;
         else
            if(dEntryPrice>bandUP3[iBar])
               iBandPosition=3;
            else
               if(dEntryPrice>bandUP2[iBar])
                  iBandPosition=2;
               else
                  if(dEntryPrice>bandUP1[iBar])
                     iBandPosition=1;

         if(dSlope<0)
           {
            iSignalType=SHORT_ENTRY_TREND;
            sText=" SHORT entry Trend";
           }
         else
            if(dSlope>0)
              {
               iSignalType=SHORT_ENTRY_COUNTER;
               sText=" SHORT entry CounterTrend";
              }
        }

//--- Send alerts
   sTextAlert=sSymbol+sPeriod+sText+sTime+"  HuskyBand: "+(string)iBandPosition;

   if(SendSignal_Alerts==true)
      Alert(sTextAlert);

   if(SendSignal_Emails==true)
      SendMail(subjectEmailAlert,sTextAlert);


   if(SendSignal_Notifications==true)
      SendNotification(sTextAlert);

   signalSended[iBar]=iSignalType;
  }
//                   ****************************************
//                   ****************************************
//                        CALCULATE TMA, BANDS, SIGNALS
//                   ****************************************
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_TMA_AVERAGE(int limitX,int applied_priceX,double &tmaCenteredX[],double &tmaUPX[],double &tmaDNX[],double &slopeX[])
  {
//--- Calculate TMA values
   Calculate_TMA_centered(applied_priceX,limitX,tmaCenteredX);

   if(applied_priceX!=PRICE_MEDIAN)
      return;

//--- Draw colored TMA median lines for UP and DOWN trend
   for(int i=limitX-2; i>=0 && !IsStopped(); i--)
     {
      if(tmaCenteredX[i+1]!=0)
         slopeX[i]=10000*(tmaCenteredX[i]-tmaCenteredX[i+1])/tmaCenteredX[i+1];
     }

   for(int i=limitX-3; i>=0 && !IsStopped(); i--)
     {
      int ii=i+1;

      tmaUPX[i]=EMPTY_VALUE;
      tmaDNX[i]=EMPTY_VALUE;

      if(slopeX[ii]>=0)
        {
         tmaUPX[i]=tmaCenteredX[i];
         if(slopeX[ii+1]<0)
           {
            tmaUPX[i+1]=tmaCenteredX[i+1];
           }
        }
      else
         if(slopeX[ii]<0)
           {
            tmaDNX[i]=tmaCenteredX[i];
            if(slopeX[ii+1]>0)
               tmaDNX[i+1]=tmaCenteredX[i+1];
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_TMA_BANDS(int limitX,double &tmaCenteredX[],double &tmaCenteredHighsX[],double &tmaCenteredLowsX[],
                         double &bandUP1X[],double &bandUP2X[],double &bandUP3X[],double &bandUP4X[],
                         double &bandDN1X[],double &bandDN2X[],double &bandDN3X[],double &bandDN4X[])
  {
   double deviation=0;

   for(int i=limitX; i>=0 && !IsStopped(); i--)
     {
      //--- calculate StdDev / Close and TMA median -----------------
      int iError=0;
      double dClose=0;
      double StdDev_dTmp=0;
      for(int ij=0; ij<ATR_Period; ij++)
        {
         dClose=iClose(Symbol(),Period(),i+ij);
         StdDev_dTmp+=MathPow(dClose-tmaCenteredX[i+ij],2);
        }

      deviation=MathSqrt(StdDev_dTmp/ATR_Period);

      ////--- Band distances --------------------------------
      double bandDistance1=deviation*ATR_Multiplier_Band1;
      double bandDistance2=deviation*ATR_Multiplier_Band2;
      double bandDistance3=deviation*ATR_Multiplier_Band3;
      double bandDistance4=deviation*ATR_Multiplier_Band4;

      double tmaValue;

      switch(Band_Type)
        {
         case Median_Band:
            tmaValue=tmaCenteredX[i];
            Set_BandValues(i,tmaValue,"plus",bandDistance1,bandDistance2,bandDistance3,bandDistance4,
                           bandUP1X,bandUP2X,bandUP3X,bandUP4X);
            Set_BandValues(i,tmaValue,"minus",bandDistance1,bandDistance2,bandDistance3,bandDistance4,
                           bandDN1X,bandDN2X,bandDN3X,bandDN4X);
            break;
         case HighLow_Bands:
            tmaValue=tmaCenteredHighsX[i];
            Set_BandValues(i,tmaValue,"plus",bandDistance1,bandDistance2,bandDistance3,bandDistance4,
                           bandUP1X,bandUP2X,bandUP3X,bandUP4X);
            tmaValue=tmaCenteredLowsX[i];
            Set_BandValues(i,tmaValue,"minus",bandDistance1,bandDistance2,bandDistance3,bandDistance4,
                           bandDN1X,bandDN2X,bandDN3X,bandDN4X);
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Set_BandValues(int iBar,double tmaValueX,string code,
                    double distance1,double distance2,double distance3,double distance4,
                    double &band1X[],double &band2X[],double &band3X[],double &band4X[])
  {
   int sign=0;
   if(code=="plus")
      sign=1;
   else
      if(code=="minus")
         sign=-1;

   band1X[iBar]=tmaValueX+distance1*sign;
   band2X[iBar]=tmaValueX+distance2*sign;
   band3X[iBar]=tmaValueX+distance3*sign;
   band4X[iBar]=tmaValueX+distance4*sign;
  }
//                   ****************************************
//                   ****************************************
//                               FUNCTIONS
//                   ****************************************
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_TMA_centered(int applied_priceX,int limitX,double &buffer1[])
  {
   double sum,sumw;
   int i,j,k;

   if(limitX<5)
      limitX=fullLength+1;

   for(i=limitX-HalfLength-1; i>=0; i--)
     {
      for(sum=0.0,j=0; j<fullLength; j++)
         sum+=iMA(NULL,0,ma_period,0,ma_method,applied_priceX,i+j)*weights[j];
      buffer1[i+HalfLength]=sum/sumWeights;
     }

//---

   for(i=HalfLength-1; i>=0; i--)
     {
      sum  = (HalfLength+1)*iMA(NULL,0,ma_period,0,ma_method,applied_priceX,i);
      sumw = (HalfLength+1);

      for(j=1,k=HalfLength; j<HalfLength; j++,k--)
        {
         sum  += iMA(NULL,0,ma_period,0,ma_method,applied_priceX,i+j)*k;
         sumw += k;
         if(j<=i)
           {
            sum  += iMA(NULL,0,ma_period,0,ma_method,applied_priceX,i-j)*k;
            sumw += k;
           }
        }
      buffer1[i]=sum/sumw;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Get_SlopeMomentumValues(string symbol,int timeFrame,int iBar)
  {
   double slopeMA;

   double slopeM=0;
   int SlopeBarsBack=1;
   int PivotsAverage_Period=21;
   double Factor_SlopeFiltering=0.40;

   ArrayFill(buffMomentum,0,nSlopes,0.0);
   ArrayFill(slopeLine,0,nSlopes,0.0);

//-- Slope line -------------------------------------------
   for(int i=0; i<PivotsAverage_Period+1; i++)
     {
      buffMomentum[i]=iMA(symbol,timeFrame,MAvg3_Period,MAvg_Shift,MAvg_Mode,MAvg_Price,iBar+i);
     }

   for(int i=0; i<PivotsAverage_Period+1; i++)
     {
      if(buffMomentum[i+SlopeBarsBack]!=0)
        {
         slopeM=(buffMomentum[i]/buffMomentum[i+SlopeBarsBack]);
         slopeLine[i]=1000*MathLog10(slopeM);
        }
      else
         slopeMA=EMPTY_VALUE;
     }
//-- previous bar
   int prevBar=1;
   slopeMA=slopeLine[0+prevBar];

//-- Limits for Slope line --------------------------------
   int iPosition=(int)MathFloor(PivotsAverage_Period*Factor_SlopeFiltering);

   for(int i=0; i<PivotsAverage_Period; i++)
      arrSlopeSorted[i]=MathAbs(slopeLine[i]);

   ArraySort(arrSlopeSorted,PivotsAverage_Period,0,MODE_ASCEND);

   slopeLimitValue=arrSlopeSorted[iPosition];

//--- Slope Momentum conditions ---------------------------------
   iMomentum_Direction=OP_NONE;

   if(MathAbs(slopeMA)>=slopeLimitValue)
     {
      if(slopeMA>0 && slopeLine[0]<slopeLine[1] && slopeLine[1]>slopeLine[2]) //--weak momentum UP
        {
         iMomentum_Direction=OP_SELL;
        }
      else
         if(slopeMA<0 && slopeLine[0]>slopeLine[1] && slopeLine[1]<slopeLine[2]) //--weak momentum DN
           {
            iMomentum_Direction=OP_BUY;
           }
     }

   sMomentum_Direction=Get_DirectionString(iMomentum_Direction);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_DirectionString(int iCondition)
  {
   string sCondition="NONE";

   switch(iCondition)
     {
      case OP_BUY:
         sCondition="LONG";
         break;
      case OP_SELL:
         sCondition="SHORT";
         break;
      case OP_NONE:
         sCondition="NONE";
         break;
     }
   return(sCondition);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Get_PeriodString(int iPeriod)
  {
   string sPeriod;
   switch(iPeriod)
     {
      case PERIOD_M1:
         sPeriod="M1";
         break;
      case PERIOD_M5:
         sPeriod="M5";
         break;
      case PERIOD_M15:
         sPeriod="M15";
         break;
      case PERIOD_M30:
         sPeriod="M30";
         break;
      case PERIOD_H1:
         sPeriod="H1";
         break;
      case PERIOD_H4:
         sPeriod="H4";
         break;
      case PERIOD_D1:
         sPeriod="D1";
         break;
      case PERIOD_W1:
         sPeriod="W1";
         break;
      case PERIOD_MN1:
         sPeriod="MN1";
         break;
     }
   return(sPeriod);
  }
//+------------------------------------------------------------------+

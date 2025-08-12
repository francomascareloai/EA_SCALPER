//+------------------------------------------------------------------+
//|                                              smLazyTMA Signals_vX
//+------------------------------------------------------------------+
#property copyright "Copyright 13.06.2019, SwingMan"
#property strict
#property indicator_chart_window

/*-------------------------------------------------------------------
10.06.2019  v1 - Bands calculation with StdDev 
12.06.2019  v2.1 - TMA calculate like TMAcentered (@mladen); Entry/Exit on Open
13.06.2019  v2.2 - Signal offset = 25% from ATR for Close1/Close0
14.06.2019  v3.1 - Signal filter with AvgSlope on last 5 bars;  one signal for last 10 bars; available signals remains
--------------------------------------------------------------------*/

#property indicator_buffers 14

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

#property indicator_color11  clrAqua       //Entry signal arrows
#property indicator_color12  clrTomato
#property indicator_color13  clrAqua       //Exit arrows
#property indicator_color14  clrTomato

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

#property indicator_width11  2
#property indicator_width12  2
#property indicator_width13  1
#property indicator_width14  1

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


//+------------------------------------------------------------------+
//|         INPUTS
//+------------------------------------------------------------------+
extern int                   HalfLength      =  89;            // Half Length
input int                    ma_period       =  6;             // MA averaging period
                                                               //input int                    ma_shift        =  6;             // MA shift at right
input ENUM_MA_METHOD         ma_method       =  MODE_LWMA;     // MA averaging method
input ENUM_APPLIED_PRICE     applied_price   =PRICE_MEDIAN;    // Applied Price
input int                    ATR_Period      =  144;           // ATR Period
input bool                   Show_Comments   =  true;
input int                    Total_Bars      = 2000;
input string ___Bands_Deviation_Multiplier="----------------------------------------------";
input double ATR_Multiplier_Band1   =1.0;
input double ATR_Multiplier_Band2   =2.0;
input double ATR_Multiplier_Band3   =3.0;
input double ATR_Multiplier_Band4   =4.0;
//
input string ___Bands_To_Draw="----------------------------------------------";
input bool Draw_Band1               =true;
input bool Draw_Band2               =true;
input bool Draw_Band3               =true;
input bool Draw_Band4               =true;
//
input bool Draw_SignalArrows=true;

//====================================================================
//
//--- constants
string CR="\n";
#define OP_NONE -1
//---
//--- buffers
double tmaUP[],tmaDN[],tmaCentered[];
double bandUP1[],bandUP2[],bandUP3[],bandUP4[];
double bandDN1[],bandDN2[],bandDN3[],bandDN4[];
double slope[];
double arrowUP[],arrowDN[],exitUP[],exitDN[];
//---
double weights[];
//---
#define nSlopes 200

double buffMomentum[nSlopes],slopeLine[nSlopes],arrSlopeSorted[nSlopes];

//---
//--- variables
//--- TMA
double sumWeights=0;
int    fullLength;
//--- SlopeAverage
int MAvg3_Period=3;
int MAvg_Shift=1;
int MAvg_Mode=MODE_SMA;
int MAvg1_Period=1;
ENUM_APPLIED_PRICE MAvg_Price=PRICE_TYPICAL;
double slopeLimitValue;
int iMomentum_Direction;
string sMomentum_Direction;

datetime thisTime,oldTime;
bool newBar;
//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Slopes
   ArraySetAsSeries(buffMomentum,true);
   ArraySetAsSeries(slopeLine,true);
   ArraySetAsSeries(arrSlopeSorted,true);
//---

   IndicatorBuffers(16);

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

//--- indicator buffers mapping
   SetIndexBuffer(0,tmaUP);     SetIndexLabel(0,"TMA UP");
   SetIndexBuffer(1,tmaDN);     SetIndexLabel(1,"TMA DOWN");

   SetIndexBuffer(2,bandUP1);   SetIndexLabel(2,"Upper Band 1");
   SetIndexBuffer(3,bandUP2);   SetIndexLabel(3,"Upper Band 2");
   SetIndexBuffer(4,bandUP3);   SetIndexLabel(4,"Upper Band 3");
   SetIndexBuffer(5,bandUP4);   SetIndexLabel(5,"Upper Band 4");

   SetIndexBuffer(6,bandDN1);   SetIndexLabel(6,"Lower Band 1");
   SetIndexBuffer(7,bandDN2);   SetIndexLabel(7,"Lower Band 2");
   SetIndexBuffer(8,bandDN3);   SetIndexLabel(8,"Lower Band 3");
   SetIndexBuffer(9,bandDN4);   SetIndexLabel(9,"Lower Band 4");

//--- entry ---------------------------
   int iArrowUP=164; //159;233;
   int iArrowDN=164; //159;234;
//--- exit ----------------------------
   int iExitUP =203; //251;
   int iExitDN =203; //251;
//---

   SetIndexBuffer(10,arrowUP); SetIndexLabel(10,"LONG entry");  SetIndexStyle(10,DRAW_ARROW); SetIndexArrow(10,iArrowUP);
   SetIndexBuffer(11,arrowDN); SetIndexLabel(11,"SHORT entry"); SetIndexStyle(11,DRAW_ARROW); SetIndexArrow(11,iArrowDN);
   SetIndexBuffer(12,exitUP);  SetIndexLabel(12,"LONG exit");   SetIndexStyle(12,DRAW_ARROW); SetIndexArrow(12,iExitUP);
   SetIndexBuffer(13,exitDN);  SetIndexLabel(13,"SHORT exit");  SetIndexStyle(13,DRAW_ARROW); SetIndexArrow(13,iExitDN);

//--- more buffers --------------------
   SetIndexBuffer(14,tmaCentered);
   SetIndexBuffer(15,slope);

//--- array settings ------------------
   for(int ii=0; ii<=15; ii++)
     {
      //SetIndexShift(ii,ma_shift);
      SetIndexEmptyValue(ii,EMPTY_VALUE);
      SetIndexDrawBegin(ii,HalfLength+ATR_Period+10);
     }
//---

   IndicatorDigits(Digits+3);

//----
   string shortName=StringConcatenate(WindowExpertName(),CR,"================",CR);
   IndicatorShortName(shortName);
   if(Show_Comments)
      Comment(shortName);
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
   static int limit;

//-- 1. check new bar -------------------------------------
   thisTime=iTime(Symbol(),Period(),0);
   if(thisTime!=oldTime)
     {newBar=true; oldTime=thisTime;}
   else
      newBar=false;

//---

   int counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   if(limit<fullLength)
      limit=MathMax(limit,limit+fullLength);

//Comment(
//        "limit= ",limit,CR,
//        "Bars= ",Bars,CR,
//        "counted_bars= ",counted_bars
//        );
newBar=true;
//--- colored TMA -----------------------------------------
   if(newBar==true)
     {
      Calculate_TMA_centered(limit,tmaCentered);

      for(i=limit-2; i>=0 && !IsStopped(); i--)
        {
         if(tmaCentered[i+1]!=0)
            slope[i]=10000*(tmaCentered[i]-tmaCentered[i+1])/tmaCentered[i+1];
        }

      for(i=limit-3; i>=0 && !IsStopped(); i--)
        {
         int ii=i+1;

         tmaUP[i]=EMPTY_VALUE;
         tmaDN[i]=EMPTY_VALUE;

         if(slope[ii]>=0)
           {
            tmaUP[i]=tmaCentered[i];
            if(slope[ii+1]<0)
              {
               tmaUP[i+1]=tmaCentered[i+1];
              }
           }
         else
         if(slope[ii]<0)
           {
            tmaDN[i]=tmaCentered[i];
            if(slope[ii+1]>0)
               tmaDN[i+1]=tmaCentered[i+1];
           }
        }

      //                *******************************************
      //                            DRAW BANDS
      //                *******************************************
      //--- TMA bands -------------------------------------------
      double deviation=0;

      for(i=limit-ATR_Period; i>=0 && !IsStopped(); i--)
        {
         //--- calculate StdDev ------------------------------
         double StdDev_dTmp=0;
         for(int ij=0; ij<ATR_Period; ij++)
            StdDev_dTmp+=MathPow(Close[i+ij]-tmaCentered[i+ij],2);
         deviation=MathSqrt(StdDev_dTmp/ATR_Period);

         //--- Band distances --------------------------------
         double bandDistance1=deviation*ATR_Multiplier_Band1;
         double bandDistance2=deviation*ATR_Multiplier_Band2;
         double bandDistance3=deviation*ATR_Multiplier_Band3;
         double bandDistance4=deviation*ATR_Multiplier_Band4;

         double tmaValue=tmaCentered[i];

         bandUP1[i]=tmaValue+bandDistance1;
         bandUP2[i]=tmaValue+bandDistance2;
         bandUP3[i]=tmaValue+bandDistance3;
         bandUP4[i]=tmaValue+bandDistance4;

         bandDN1[i]=tmaValue-bandDistance1;
         bandDN2[i]=tmaValue-bandDistance2;
         bandDN3[i]=tmaValue-bandDistance3;
         bandDN4[i]=tmaValue-bandDistance4;
        }

      //                *******************************************
      //                            DRAW SIGNALS
      //                *******************************************
      if(Draw_SignalArrows==true)
        {
//Comment("limit= ",limit);        
         //--- Entry Signals ---------------------------------------  FOR NEW BAR-0 / Check BAR-1 / Signal on BAR-0 on OPEN
         for(i=limit-ATR_Period; i>=0 && !IsStopped(); i--)
           {
            Get_SlopeMomentumValues(Symbol(),Period(),i);
            double dATRoffset=0;

            double dClose0=Close[i+1];
            double dClose1=Close[i+1+1];

            if(i==0)
              {
               arrowUP[i]=EMPTY_VALUE;
               arrowDN[i]=EMPTY_VALUE;
              }

            bool signalOK;
            int nBarsCheckCloses=5;
            int nBarsCheckOldSignals=10;

            //--- LONG signals ----------------------------------
            if(slope[i]>=0 && iMomentum_Direction==OP_BUY)
              {
               signalOK=true;
               for(int j=1;j<=nBarsCheckOldSignals;j++)
                 {
                  if(arrowUP[i+j]!=EMPTY_VALUE)
                    {
                     signalOK=false;
                     break;
                    }
                 }

                  //if(Time[i]==D'2019.06.13 01:57')
                  //  {
                  //   Comment(
                  //           "i+1= ",DoubleToString(arrowUP[i+1],Digits()),CR,
                  //           "i+2= ",DoubleToString(arrowUP[i+2],Digits()),CR,
                  //           "i+3= ",DoubleToString(arrowUP[i+3],Digits()),CR,
                  //           "signalOK= ",signalOK
                  //           );
                  //  }
                  
               if(signalOK==true)
                 {
                  if(Open[i]<tmaCentered[i] && tmaCentered[i]>tmaCentered[i+1] && Open[i]<bandDN1[i])
                    {
                     for(int k=1;k<=nBarsCheckCloses;k++)
                       {
                        if(Close[i+k]<bandDN4[i+k] || Close[i+k]<bandDN3[i+k] || Close[i+k]<bandDN2[i+k] || Close[i+k]<bandDN1[i+k])
                          {
                           arrowUP[i]=Open[i];
                           break;
                          }
                       }
                    }
                 }
              }

            //--- SHORT signals ----------------------------------
            if(slope[i]<0 && iMomentum_Direction==OP_SELL)
              {
               signalOK=true;
               for(int j=1;j<=nBarsCheckOldSignals;j++)
                 {
                  if(arrowDN[i+j]!=EMPTY_VALUE)
                    {
                     signalOK=false;
                     break;
                    }
                 }

               if(signalOK==true && Open[i]>tmaCentered[i] && tmaCentered[i]<tmaCentered[i+1] && Open[i]>bandUP1[i])
                  for(int k=1;k<=nBarsCheckCloses;k++)
                    {
                     if(Close[i+k]>bandUP4[i+k] || Close[i+k]>bandUP3[i+k] || Close[i+k]>bandUP2[i+k] || Close[i+k]>bandUP1[i+k])
                       {
                        arrowDN[i]=Open[i];
                        break;
                       }
                    }
              }
           }

         //--- Exit Signals ----------------------------------------  FOR NEW BAR-0 / on OPEN / for color change
         for(i=limit-ATR_Period; i>=0 && !IsStopped(); i--)
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
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculate_TMA_centered(int limitX,double &buffer1[])
  {
   double sum,sumw;
   int i,j,k;

   for(i=limitX-HalfLength-1;i>=0;i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //for(i=limitX;i>=0;i--)
     {
      for(sum=0.0,j=0; j<fullLength; j++)
         sum+=iMA(NULL,0,ma_period,0,ma_method,applied_price,i+j)*weights[j];
      buffer1[i+HalfLength]=sum/sumWeights;
     }

//---

   for(i=HalfLength-1;i>=0;i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      sum  = (HalfLength+1)*iMA(NULL,0,ma_period,0,ma_method,applied_price,i);
      sumw = (HalfLength+1);

      for(j=1,k=HalfLength; j<HalfLength; j++,k--)
        {
         sum  += iMA(NULL,0,ma_period,0,ma_method,applied_price,i+j)*k;
         sumw += k;
         if(j<=i)
           {
            sum  += iMA(NULL,0,ma_period,0,ma_method,applied_price,i-j)*k;
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
   for(int i=0;i<PivotsAverage_Period+1;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      buffMomentum[i]=iMA(symbol,timeFrame,MAvg3_Period,MAvg_Shift,MAvg_Mode,MAvg_Price,iBar+i);
     }

   for(int i=0;i<PivotsAverage_Period+1;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(buffMomentum[i+SlopeBarsBack]!=0)
        {
         slopeM=(buffMomentum[i]/buffMomentum[i+SlopeBarsBack]);
         slopeLine[i]=1000*MathLog10(slopeM);
        }
      else slopeMA=EMPTY_VALUE;
     }
//-- previous bar
   int prevBar=1;
   slopeMA=slopeLine[0+prevBar];

//-- Limits for Slope line --------------------------------
   int iPosition=(int)MathFloor(PivotsAverage_Period*Factor_SlopeFiltering);

   for(int i=0;i<PivotsAverage_Period;i++)
      arrSlopeSorted[i]=MathAbs(slopeLine[i]);

   ArraySort(arrSlopeSorted,PivotsAverage_Period,0,MODE_ASCEND);

   slopeLimitValue=arrSlopeSorted[iPosition];

//if(iBar==0)
//  {
//   int uu=3;
//   Comment("slopeMA at bar1= ",DoubleToString(slopeMA,Digits),CR,
//           "bar6= ",DoubleToString(slopeLine[6],Digits),CR,
//           "bar5= ",DoubleToString(slopeLine[5],Digits),CR,
//           "slopeLimitValue= ",DoubleToString(slopeLimitValue,Digits)
//           );
//  }

//--- Slope Momentum conditions ---------------------------------
   iMomentum_Direction=OP_NONE;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(MathAbs(slopeMA)>=slopeLimitValue)
     {
      if(slopeMA>0 && slopeLine[0]<slopeLine[1]) //--weak momentum UP
        {
         iMomentum_Direction=OP_SELL;
        }
      else
      if(slopeMA<0 && slopeLine[0]>slopeLine[1]) //--weak momentum DN
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(iCondition)
     {
      case OP_BUY:  sCondition="LONG"; break;
      case OP_SELL: sCondition="SHORT"; break;
      case OP_NONE: sCondition="NONE"; break;
     }
   return(sCondition);
  }
//+------------------------------------------------------------------+

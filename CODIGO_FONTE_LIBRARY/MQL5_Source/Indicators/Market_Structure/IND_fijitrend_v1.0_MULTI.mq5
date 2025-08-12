//+------------------------------------------------------------------+
//|                                           Volty_Channel_Stop.mq5 |
//|                                                        avoitenko |
//|                        https://login.mql5.com/en/users/avoitenko |
//+------------------------------------------------------------------+
#property copyright "avoitenko"
#property link      "https://login.mql5.com/en/users/avoitenko"
#property version   "2.00"
#property description "Author: TrendLaboratory"

#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots 4

#property indicator_label1 "UpTrend"
#property indicator_color1 clrAqua
#property indicator_width1 1

#property indicator_label2 "DnTrend"
#property indicator_color2 clrYellow
#property indicator_width2 1

#property indicator_label3 "UpSignal"
#property indicator_color3 clrLimeGreen
#property indicator_width3 1

#property indicator_label4 "DnSignal"
#property indicator_color4 clrRed
#property indicator_width4 1
//+------------------------------------------------------------------+
//|   ENUM_VISUAL_MODE                                               |
//+------------------------------------------------------------------+
enum ENUM_VISUAL_MODE
  {
   VISUAL_LINES,// Lines
   VISUAL_DOTS  // Dots
  };

//--- input parameters
input ENUM_VISUAL_MODE     InpVisualMode  =  VISUAL_DOTS;   // Visual Mode
input ushort               InpMaPeriod    =  5;             // MA Period 
input ENUM_MA_METHOD       InpMaMethod    =  MODE_SMMA;     // MA Method
input ENUM_APPLIED_PRICE   InpMaPrice     =  PRICE_CLOSE;   // MA Price

input ushort               InpAtrPeriod   =  11;            // ATR Period
input double               InpVolFactor   =  1.3;           // Volatility Factor
input double               InpMoneyRisk   =  0.15;          // Offset Factor 
input bool                 InpUseBreak    =  true;          // Use Break
input bool                 InpUseEnvelopes=  false;         // Use Envelopes
input bool                 InpUseAlert    =  true;          // Use Alert

//--- buffers
double UpBuffer[];
double DnBuffer[];
double UpSignal[];
double DnSignal[];
double smin[];
double smax[];
double trend[];
double MaUpBuffer[];
double MaDnBuffer[];
double AtrBuffer[];

//--- global variables
int atr_handle;
int ma_up_handle;
int ma_dn_handle;
datetime time_up_alert,time_dn_alert;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- set buffers
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,UpSignal);
   SetIndexBuffer(3,DnSignal);
   SetIndexBuffer(4,smin,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,smax,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,MaUpBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,MaDnBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,AtrBuffer,INDICATOR_CALCULATIONS);
//--- set direction
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);
   ArraySetAsSeries(UpSignal,true);
   ArraySetAsSeries(DnSignal,true);
   ArraySetAsSeries(smin,true);
   ArraySetAsSeries(smax,true);
   ArraySetAsSeries(trend,true);
   ArraySetAsSeries(MaUpBuffer,true);
   ArraySetAsSeries(MaDnBuffer,true);
   ArraySetAsSeries(AtrBuffer,true);
//---
   if(InpVisualMode==VISUAL_LINES)
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
     }
   else
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_ARROW);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_ARROW);
      PlotIndexSetInteger(0,PLOT_ARROW,246);
      PlotIndexSetInteger(1,PLOT_ARROW,248);
     }
//----
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(2,PLOT_ARROW,233);
   PlotIndexSetInteger(3,PLOT_ARROW,234);
//---
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMaPeriod+InpAtrPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpMaPeriod+InpAtrPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpMaPeriod+InpAtrPeriod);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,InpMaPeriod+InpAtrPeriod);

//--- get handles
   atr_handle=iATR(_Symbol,_Period,fmax(InpAtrPeriod,1));
   if(atr_handle==INVALID_HANDLE)return(-1);

   if(InpUseEnvelopes)
     {
      ma_up_handle = iMA(_Symbol,_Period,fmax(InpMaPeriod,1),0,InpMaMethod,PRICE_HIGH);
      ma_dn_handle = iMA(_Symbol,_Period,fmax(InpMaPeriod,1),0,InpMaMethod,PRICE_LOW);
     }
   else
     {
      ma_up_handle = iMA(_Symbol,_Period,fmax(InpMaPeriod,1),0,InpMaMethod,InpMaPrice);
      ma_dn_handle = iMA(_Symbol,_Period,fmax(InpMaPeriod,1),0,InpMaMethod,InpMaPrice);
     }

   if(ma_up_handle==INVALID_HANDLE || ma_dn_handle==INVALID_HANDLE)return(-1);

//---
   string short_name=StringFormat("Fiji Trend(%u,%u,%.2f)",InpMaPeriod,InpAtrPeriod,InpVolFactor);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   return(INIT_SUCCEEDED);
  }
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
//----
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);

   if(rates_total<(int)InpMaPeriod+1) return(0);
   int limit;

//--- first calc
   if(rates_total<prev_calculated || prev_calculated<=0)
     {
      time_dn_alert=time[0];
      time_up_alert=time[0];

      limit=rates_total-InpMaPeriod-2;
      ArrayInitialize(UpBuffer,EMPTY_VALUE);
      ArrayInitialize(DnBuffer,EMPTY_VALUE);
      ArrayInitialize(UpSignal,EMPTY_VALUE);
      ArrayInitialize(DnSignal,EMPTY_VALUE);
     }
   else limit=rates_total-prev_calculated;

//--- get data
   if(CopyBuffer(atr_handle,  0,0,limit+1,AtrBuffer)  != limit+1) return(0);
   if(CopyBuffer(ma_up_handle,0,0,limit+1,MaUpBuffer) != limit+1) return(0);
   if(CopyBuffer(ma_dn_handle,0,0,limit+1,MaDnBuffer) != limit+1) return(0);

//--- main cycle
   for(int bar=limit; bar>=0 && !_StopFlag; bar--)
     {

      smax[bar]=MaUpBuffer[bar] + InpVolFactor*AtrBuffer[bar];
      smin[bar]=MaDnBuffer[bar] - InpVolFactor*AtrBuffer[bar];
      trend[bar]=trend[bar+1];

      if(InpUseBreak)
        {
         if(high[bar] > smax[bar+1])trend[bar] =  1;
         if(low[bar]  < smin[bar+1])trend[bar] = -1;
        }
      else
        {
         if(MaUpBuffer[bar] > smax[bar+1]) trend[bar]= 1;
         if(MaDnBuffer[bar] < smin[bar+1]) trend[bar]=-1;
        }

      if(trend[bar]>0)
        {
         if(smin[bar]<smin[bar+1]) smin[bar]=smin[bar+1];

         UpBuffer[bar]=smin[bar]-(InpMoneyRisk-1)*AtrBuffer[bar];

         if(UpBuffer[bar]<UpBuffer[bar+1] && UpBuffer[bar+1]!=EMPTY_VALUE) UpBuffer[bar]=UpBuffer[bar+1];

         if(trend[bar+1]!=trend[bar]) UpSignal[bar]=UpBuffer[bar];
         else UpSignal[bar]=EMPTY_VALUE;

         DnBuffer[bar]=EMPTY_VALUE;
         DnSignal[bar]=EMPTY_VALUE;
        }
      else
      if(trend[bar]<0)
        {
         if(smax[bar]>smax[bar+1]) smax[bar]=smax[bar+1];

         DnBuffer[bar]=smax[bar]+(InpMoneyRisk-1)*AtrBuffer[bar];

         if(DnBuffer[bar]>DnBuffer[bar+1]) DnBuffer[bar]=DnBuffer[bar+1];

         if(trend[bar+1]!=trend[bar]) DnSignal[bar]=DnBuffer[bar];
         else DnSignal[bar]=EMPTY_VALUE;

         UpBuffer[bar]=EMPTY_VALUE;
         UpSignal[bar]=EMPTY_VALUE;
        }
     }

//---- alert
   if(InpUseAlert)
     {
      if(trend[2]<0 && trend[1]>0 && time_up_alert!=time[0])
        {
         string msg=StringFormat("%s %s %s",_Symbol,PeriodToString(),": VCS Signal for BUY");
         Alert(msg);
         time_up_alert=time[0];
        }
      if(trend[2]>0 && trend[1]<0 && time_dn_alert!=time[0])
        {
         string msg=StringFormat("%s %s %s",_Symbol,PeriodToString(),": VCS Signal for SELL");
         Alert(msg);
         time_dn_alert=time[0];
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|   PeriodToString                                                 |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period=PERIOD_CURRENT)
  {
   if(period==PERIOD_CURRENT)period=_Period;
   string str=EnumToString(period);
   if(StringLen(str)>7) return(StringSubstr(str,7));
   return("");
  }
//+------------------------------------------------------------------+

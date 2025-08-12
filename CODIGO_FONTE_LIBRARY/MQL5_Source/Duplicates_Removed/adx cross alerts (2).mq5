//+------------------------------------------------------------------+
//|                                                     ma cross.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3 
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLightSeaGreen
#property indicator_width1  2
#property indicator_label1  "Bull ADX Cross"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  2
#property indicator_label2 "Bear ADX Cross"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

input int    AdxPeriod        = 14;          // ADX period
input bool   alertsOn         = true;        // Turn alerts on?
input bool   alertsOnCurrent  = false;       // Alert on current bar?
input bool   alertsMessage    = true;        // Display messages on alerts?
input bool   alertsSound      = false;       // Play sound on alerts?
input bool   alertsEmail      = false;       // Send email on alerts?
input bool   alertsNotify     = false;       // Send push notification on alerts?

double crossUp[],crossDn[],cross[];
//--- indicator handles
int _adxHandle;
int _atrHandle;

int OnInit()
  {
//--- indicator buffers mapping
    SetIndexBuffer(0,crossUp,INDICATOR_DATA);  PlotIndexSetInteger(0,PLOT_ARROW,233);
    SetIndexBuffer(1,crossDn,INDICATOR_DATA);  PlotIndexSetInteger(1,PLOT_ARROW,234);
    SetIndexBuffer(2,cross);
   _adxHandle=iADX(_Symbol,0,AdxPeriod); if(_adxHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   _atrHandle=iATR(_Symbol,0,15);        if(_atrHandle==INVALID_HANDLE) { return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"ADX cross "+(string)AdxPeriod+")");
return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(BarsCalculated(_adxHandle)<rates_total)  return(prev_calculated);
   double _adxVal[1],_adxpVal[1],_adxmVal[1],_atr[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
   {
      int _adxCopied =CopyBuffer(_adxHandle,0,time[i],1,_adxVal);
      int _adxpCopied=CopyBuffer(_adxHandle,1,time[i],1,_adxpVal);
      int _adxmCopied=CopyBuffer(_adxHandle,2,time[i],1,_adxmVal);
      int _atrCopied=CopyBuffer( _atrHandle,0,time[i],1,_atr);
      cross[i] = (i>0) ? (_adxpVal[0]>_adxmVal[0]) ? 1 : (_adxpVal[0]<_adxmVal[0]) ? 2 : cross[i-1] : 0;  
      crossUp[i] = EMPTY_VALUE;
      crossDn[i] = EMPTY_VALUE;
      if (i>0 && cross[i]!=cross[i-1])
      {
         if (cross[i] == 1) crossUp[i] =  low[i]-_atr[0];
         if (cross[i] == 2) crossDn[i] = high[i]+_atr[0];
      }
//---
   }
   manageAlerts(time,cross,rates_total);
return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void manageAlerts(const datetime& _time[], double& _trend[], int bars)
{
   if (alertsOn)
   {
      int whichBar = bars-1; if (!alertsOnCurrent) whichBar = bars-2; datetime time1 = _time[whichBar];
      if (_trend[whichBar] != _trend[whichBar-1])
      {          
         if (_trend[whichBar] == 1) doAlert(time1," plus DI crossing minus DI up");
         if (_trend[whichBar] == 2) doAlert(time1," plus DI crossing minus DI down");
      }         
   }
}   

//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      string message = TimeToString(TimeLocal(),TIME_SECONDS)+" "+_Symbol+" Adx "+doWhat;
         if (alertsMessage) Alert(message);
         if (alertsEmail)   SendMail(_Symbol+"Adx",message);
         if (alertsNotify)  SendNotification(message);
         if (alertsSound)   PlaySound("alert2.wav");
   }
}



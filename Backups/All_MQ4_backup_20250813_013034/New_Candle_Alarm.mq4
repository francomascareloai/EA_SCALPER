//+------------------------------------------------------------------+
//|                                             New_Candle_Alarm.mq4 |
//|                                                         Zen_Leow |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Zen_Leow"
#property link      ""

#property indicator_chart_window

datetime LastAlertTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
   LastAlertTime = TimeCurrent();
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
   if (LastAlertTime < Time[0])
   {
      Alert("New Candle Forming on ",Symbol()," TimeFrame: ",Period());
      LastAlertTime = Time[0];
   }
   return(0);
}
//+------------------------------------------------------------------+